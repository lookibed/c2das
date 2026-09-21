//! Ordering of module-level value declarations.
//!
//! C gives a file-scope object's initializer link-time constants, so an
//! initializer may name an object defined further down the translation unit:
//!
//! ```c
//! static const t a[] = { ... };
//! static const t *table[] = { a };   // fine in either order
//! ```
//!
//! daScript is stricter.  A module-level `var` is initialized in declaration
//! order, so an initializer that reads — or takes the address of — another
//! module-level `var` requires that variable to be *declared earlier*
//! (`error[30173]: global variable A is initialized after G`).  The check is
//! transitive through calls: an initializer written as `var G = ginit_G()`
//! inherits every global `ginit_G`'s body names, and a genuine cycle among
//! those names is rejected outright (`error[31104]: global variable
//! initialization loop`).  Taking a function's address with `@@f` is followed
//! the same way a call is: a table of `@@op_*` inherits everything those
//! bodies read, which is how an interpreter's two mutually recursive dispatch
//! tables end up on one cycle.
//!
//! Our declaration order is whatever order the Clang export produced, which is
//! neither C source order nor a dependency order.  This pass reorders the
//! module's value declarations so that every initializer's dependencies are
//! declared before it, and routes the initializers that cannot be ordered —
//! the ones on a dependency cycle — through an `[init]` function that assigns
//! the object after all module-level storage exists.

use das_ast::{DaBlock, DaDecl, DaExpr, DaFunction, DaStmt, DaVariable};
use std::collections::{HashMap, HashSet};

/// Reorder module-level value declarations into an initialization order
/// daScript accepts.
///
/// Only `var` declarations carry ordering constraints; a `def` is not
/// evaluated at module initialization, so functions keep their incoming
/// position and merely act as the bodies a `var`'s dependencies are traced
/// through.  The order is otherwise stable: a declaration moves only far
/// enough forward to precede the initializer that names it.
pub(crate) fn order_value_declarations(decls: Vec<DaDecl>) -> Vec<DaDecl> {
    let n = decls.len();
    if n == 0 {
        return decls;
    }

    // A name may be declared more than once in a malformed module; the first
    // declaration is the one an initializer would bind to.
    let mut var_index: HashMap<&str, usize> = HashMap::new();
    let mut fn_refs: HashMap<&str, Vec<String>> = HashMap::new();
    for (i, decl) in decls.iter().enumerate() {
        match decl {
            DaDecl::Variable(v) => {
                var_index.entry(v.name.as_str()).or_insert(i);
            }
            DaDecl::Function(f) => {
                let mut names = Vec::new();
                if let Some(body) = &f.body {
                    collect_names(body, &mut names);
                }
                fn_refs.insert(f.name.as_str(), names);
            }
            _ => {}
        }
    }

    let mut deps: Vec<Vec<usize>> = vec![Vec::new(); n];
    for (i, decl) in decls.iter().enumerate() {
        let DaDecl::Variable(v) = decl else { continue };
        let Some(init) = &v.init else { continue };
        let mut seed = Vec::new();
        collect_names(init, &mut seed);
        deps[i] = resolve_dependencies(&seed, i, &var_index, &fn_refs);
    }

    // Depth-first post-order over the dependency graph, entered in the
    // incoming declaration order.  A back edge is a cycle daScript would
    // reject; the declaration that closes it is the one whose initializer is
    // taken out of the graph, which breaks every cycle running through it.
    const UNVISITED: u8 = 0;
    const ON_STACK: u8 = 1;
    const DONE: u8 = 2;
    let mut state = vec![UNVISITED; n];
    let mut order: Vec<usize> = Vec::with_capacity(n);
    let mut cyclic: HashSet<usize> = HashSet::new();
    let mut stack: Vec<(usize, usize)> = Vec::new();
    for root in 0..n {
        if state[root] != UNVISITED {
            continue;
        }
        state[root] = ON_STACK;
        stack.push((root, 0));
        while let Some(top) = stack.last_mut() {
            let node = top.0;
            if top.1 < deps[node].len() {
                let next = deps[node][top.1];
                top.1 += 1;
                match state[next] {
                    UNVISITED => {
                        state[next] = ON_STACK;
                        stack.push((next, 0));
                    }
                    ON_STACK => {
                        cyclic.insert(node);
                    }
                    _ => {}
                }
            } else {
                state[node] = DONE;
                order.push(node);
                stack.pop();
            }
        }
    }

    // An object written by an `[init]` function counts as initialized after
    // every inline initializer, so an inline initializer may not name it
    // either: the whole component reachable backwards from a broken cycle
    // moves to `[init]` together.  That is sound because the only file-scope
    // initializer C lets participate in a cycle is an address, and a
    // module-level object's address does not depend on when its value is
    // written.
    if !cyclic.is_empty() {
        let mut users: HashMap<usize, Vec<usize>> = HashMap::new();
        for (i, node_deps) in deps.iter().enumerate() {
            for &d in node_deps {
                users.entry(d).or_default().push(i);
            }
        }
        let mut work: Vec<usize> = cyclic.iter().copied().collect();
        while let Some(node) = work.pop() {
            let Some(dependents) = users.get(&node) else {
                continue;
            };
            for &i in dependents {
                if cyclic.insert(i) {
                    work.push(i);
                }
            }
        }
    }

    let mut slots: Vec<Option<DaDecl>> = decls.into_iter().map(Some).collect();
    let mut out: Vec<DaDecl> = Vec::with_capacity(n);
    for &i in &order {
        let Some(mut decl) = slots[i].take() else {
            continue;
        };
        if cyclic.contains(&i) {
            if let DaDecl::Variable(v) = &mut decl {
                if let Some(init) = v.init.take() {
                    // The object still has module-level storage, so its
                    // address is stable and the other side of the cycle may
                    // take it; only the value it holds is written later, by
                    // an `[init]` function that runs before `main`.
                    v.var_type = super::writable_type(v.var_type.clone());
                    let assign = init_function(&v.name, init);
                    out.push(decl);
                    out.push(assign);
                    continue;
                }
            }
        }
        out.push(decl);
    }
    out
}

/// The `[init]` function that assigns a cyclic object once every module-level
/// object exists.
fn init_function(name: &str, init: DaExpr) -> DaDecl {
    let assign = DaExpr::Assign(Box::new(DaExpr::Var(name.to_string())), Box::new(init));
    DaDecl::Function(DaFunction {
        name: format!("c2da_ginit_{name}"),
        params: vec![],
        ret_type: das_ast::DaType::void(),
        // Taking the address of another module-level object is an unsafe
        // operation in daScript, and a cyclic initializer is address-carrying
        // by construction.
        body: Some(DaExpr::Block(DaBlock {
            stmts: vec![DaStmt::Expr(DaExpr::Unsafe(Box::new(DaExpr::Block(
                DaBlock {
                    stmts: vec![DaStmt::Expr(assign)],
                },
            ))))],
        })),
        annotations: vec!["init".to_string()],
        is_public: false,
        is_unsafe: false,
    })
}

/// Expand the names an initializer mentions into the module-level variables it
/// depends on, following calls the way daScript's own check does.
fn resolve_dependencies(
    seed: &[String],
    self_index: usize,
    var_index: &HashMap<&str, usize>,
    fn_refs: &HashMap<&str, Vec<String>>,
) -> Vec<usize> {
    let mut pending: Vec<&str> = seed.iter().map(String::as_str).collect();
    let mut seen: HashSet<&str> = HashSet::new();
    let mut out: Vec<usize> = Vec::new();
    while let Some(name) = pending.pop() {
        if !seen.insert(name) {
            continue;
        }
        if let Some(&idx) = var_index.get(name) {
            if idx != self_index && !out.contains(&idx) {
                out.push(idx);
            }
            continue;
        }
        if let Some(refs) = fn_refs.get(name) {
            pending.extend(refs.iter().map(String::as_str));
        }
    }
    out
}

/// Every name an expression reads, in no particular order.
///
/// `@@f` is collected like a call: daScript's own initialization check follows
/// a function's address into its body and on to the globals that body reads.
/// An interpreter's two mutually recursive dispatch tables — wasm3's
/// `c_operations` of `@@op_*` and `c_compilers` of `@@Compile_*`, each reached
/// from the other's bodies — are a cycle through nothing but `@@`, and
/// daScript rejects it (`error[31104]: global variable initialization loop`)
/// unless one of the two is routed through `[init]`.
fn collect_names(expr: &DaExpr, out: &mut Vec<String>) {
    use DaExpr::*;
    match expr {
        ConstInt(_) | ConstUInt(_) | ConstFloat(_) | ConstDouble(_) | ConstBool(_)
        | ConstString(_) | ConstNull | Break | Continue | Goto(_) | Label(_)
        | DefaultValue(_) | TypeInfo { .. } => {}
        Var(name) | FuncRef(name) => out.push(name.clone()),
        Field(e, _) | SafeField(e, _) => collect_names(e, out),
        Index(a, b) | SafeIndex(a, b) | Assign(a, b) | Pipe(a, b) | While(a, b) => {
            collect_names(a, out);
            collect_names(b, out);
        }
        Op1 { expr, .. } => collect_names(expr, out),
        Op2 { left, right, .. } | AssignOp { left, right, .. } => {
            collect_names(left, out);
            collect_names(right, out);
        }
        Op3 { cond, then, else_ } => {
            collect_names(cond, out);
            collect_names(then, out);
            collect_names(else_, out);
        }
        Call(callee, args) => {
            collect_names(callee, out);
            for a in args {
                collect_names(a, out);
            }
        }
        Block(b) => collect_block(b, out),
        IfThenElse {
            cond,
            then,
            elifs,
            else_,
        } => {
            collect_names(cond, out);
            collect_names(then, out);
            for (c, e) in elifs {
                collect_names(c, out);
                collect_names(e, out);
            }
            if let Some(e) = else_ {
                collect_names(e, out);
            }
        }
        For { sources, body, .. } => {
            for s in sources {
                collect_names(s, out);
            }
            collect_names(body, out);
        }
        Return(v) => {
            if let Some(v) = v {
                collect_names(v, out);
            }
        }
        Cast { expr, .. } => collect_names(expr, out),
        New(e, args) => {
            collect_names(e, out);
            for a in args {
                collect_names(a, out);
            }
        }
        Delete(e) | Addr(e) | Deref(e) | DerefExplicit(e) | Unsafe(e) => collect_names(e, out),
        MakeStruct { fields, .. } => {
            for (_, e) in fields {
                collect_names(e, out);
            }
        }
        MakeArray(items) => {
            for e in items {
                collect_names(e, out);
            }
        }
        MakeFixedArray { items, .. } => {
            for e in items {
                collect_names(e, out);
            }
        }
    }
}

fn collect_block(block: &DaBlock, out: &mut Vec<String>) {
    for stmt in &block.stmts {
        match stmt {
            DaStmt::Var { init, .. } | DaStmt::Let { init, .. } => {
                if let Some(e) = init {
                    collect_names(e, out);
                }
            }
            DaStmt::Param { default, .. } => {
                if let Some(e) = default {
                    collect_names(e, out);
                }
            }
            DaStmt::Expr(e) => collect_names(e, out),
            DaStmt::Decl(d) => collect_decl(d, out),
        }
    }
}

fn collect_decl(decl: &DaDecl, out: &mut Vec<String>) {
    match decl {
        DaDecl::Function(DaFunction { body: Some(b), .. }) => collect_names(b, out),
        DaDecl::Variable(DaVariable { init: Some(e), .. }) => collect_names(e, out),
        _ => {}
    }
}

/// Reorder the module's `typedef` declarations so that every alias is declared
/// after the aliases its own type names.
///
/// daScript resolves an alias whose body names a *later* alias to a type that
/// is structurally right but carries different mutability flags on the
/// resolved components.  The two spellings then stop comparing equal:
///
/// ```text
/// typedef Fn = function<(var a:pc_t; var b:sp_t):ret_t>   // pc_t not declared yet
/// typedef pc_t = uint8? const?
/// …
/// error[30915]: can't initialize field ops;
///   function<(var a:uint8? const?; var b:uint?):uint8?> aka Fn[2]
/// = function<(var a:pc_t -const; var b:sp_t -const):ret_t> aka Fn[2]
/// not the same type
/// ```
///
/// C already requires a typedef to be declared before it is used, so the
/// source order is always orderable; what this undoes is the Clang export's
/// own declaration order, which is neither source order nor dependency order.
/// Only aliases move, and only into the slots aliases already occupy, so
/// records and enumerations keep their incoming position.
pub(crate) fn order_type_aliases(decls: Vec<DaDecl>) -> Vec<DaDecl> {
    let slots: Vec<usize> = decls
        .iter()
        .enumerate()
        .filter(|(_, decl)| matches!(decl, DaDecl::Alias(_)))
        .map(|(i, _)| i)
        .collect();
    if slots.len() < 2 {
        return decls;
    }
    // The alias names this module declares, so a dependency is only ever on
    // another alias of this module and never on a record or a builtin type.
    let names: Vec<&str> = slots
        .iter()
        .map(|&i| match &decls[i] {
            DaDecl::Alias(alias) => alias.name.as_str(),
            _ => unreachable!("slot is an alias"),
        })
        .collect();
    let mut position: HashMap<&str, usize> = HashMap::new();
    for (slot, name) in names.iter().enumerate() {
        position.entry(*name).or_insert(slot);
    }
    // A daScript function type is a single `function<…>` *name*, so the type's
    // rendered text is what names its components.  Matching on identifier
    // boundaries keeps `pc_t` from being found inside `my_pc_t`.
    let deps: Vec<Vec<usize>> = slots
        .iter()
        .enumerate()
        .map(|(slot, &i)| {
            let DaDecl::Alias(alias) = &decls[i] else {
                unreachable!("slot is an alias")
            };
            let text = alias.aliased_type.to_string();
            let mut found: Vec<usize> = names
                .iter()
                .filter(|name| mentions_identifier(&text, name))
                .filter_map(|name| position.get(*name).copied())
                .filter(|&other| other != slot)
                .collect();
            found.sort_unstable();
            found.dedup();
            found
        })
        .collect();

    const UNVISITED: u8 = 0;
    const ON_STACK: u8 = 1;
    const DONE: u8 = 2;
    let mut state = vec![UNVISITED; slots.len()];
    let mut order: Vec<usize> = Vec::with_capacity(slots.len());
    // Iterative post-order, entered in the incoming order, so a slot moves
    // only as far forward as its dependencies require.  A cycle — which C
    // cannot express between typedefs — leaves the closing slot where the walk
    // reached it rather than looping.
    for start in 0..slots.len() {
        if state[start] != UNVISITED {
            continue;
        }
        let mut stack = vec![(start, 0usize)];
        state[start] = ON_STACK;
        while let Some((slot, next)) = stack.pop() {
            if next < deps[slot].len() {
                stack.push((slot, next + 1));
                let child = deps[slot][next];
                if state[child] == UNVISITED {
                    state[child] = ON_STACK;
                    stack.push((child, 0));
                }
                continue;
            }
            state[slot] = DONE;
            order.push(slot);
        }
    }

    let mut aliases: Vec<Option<DaDecl>> = Vec::with_capacity(slots.len());
    let mut decls = decls;
    for &i in &slots {
        aliases.push(Some(std::mem::replace(
            &mut decls[i],
            DaDecl::Alias(das_ast::DaAlias {
                name: String::new(),
                aliased_type: das_ast::DaType::auto(),
            }),
        )));
    }
    for (position, slot) in order.into_iter().enumerate() {
        let alias = aliases[slot].take().expect("each alias is placed once");
        decls[slots[position]] = alias;
    }
    decls
}

/// True when `name` occurs in `text` as a whole identifier.
fn mentions_identifier(text: &str, name: &str) -> bool {
    if name.is_empty() {
        return false;
    }
    let bytes = text.as_bytes();
    let is_word = |b: u8| b.is_ascii_alphanumeric() || b == b'_';
    let mut from = 0usize;
    while let Some(found) = text[from..].find(name) {
        let start = from + found;
        let end = start + name.len();
        let before_ok = start == 0 || !is_word(bytes[start - 1]);
        let after_ok = end == bytes.len() || !is_word(bytes[end]);
        if before_ok && after_ok {
            return true;
        }
        from = start + 1;
    }
    false
}
