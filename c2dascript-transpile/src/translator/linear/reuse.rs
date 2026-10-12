//! Heap load reuse within a straight-line run of statements (`--memory-model
//! linear`).
//!
//! A 4-byte heap load is a byte assembly of four bounds-checked `c2da_mem`
//! reads (about 45 ns in the interpreter, against 7 ns for an `array<float>`
//! element).  C code such as Quake's `DotProduct`/`VectorMA` macros reads the
//! same field several times in a row, and reads back a value it has just
//! stored.  This pass, run over a function body right after it is lowered,
//! removes those repeats where C semantics make them provably equal:
//!
//! - **Reuse.** Within one block, a `float` or `int`/pointer load
//!   (`load(F32|I32|Ptr, a)` as `linear.rs` writes it) whose address `a` was
//!   loaded by an earlier statement of the same run reads the same value when
//!   nothing in between can change it: no heap store that may overlap it, no
//!   call other than the `math_bits` conversions, no write to a variable `a`
//!   mentions, and no control flow (a nested block, label, loop, `return`, …)
//!   in between.  The first load becomes `let c2da_freshN = …` right before
//!   its statement and every repeat reads the `let`.
//! - **Store forwarding.** A `float` store of a named value `v` at `a` (the
//!   `let t = float_bits_to_uint(v)` plus four byte stores of `store`) makes a
//!   following `float` load at `a` read `v`, under the same conditions.
//! - **`if` branches.** The loads known right after an `if` condition (no
//!   `elif`) are known on entry to both branches.
//! - **Copies.** A site temporary (`let`, or a `var` never written) whose
//!   whole initializer became a `let` of this pass is dropped and its reads
//!   read that `let`.  The pass's names are taken in source order.
//!
//! The rule is deliberately syntactic and conservative.  Addresses are
//! compared as `base + constant`; a heap store keeps a remembered load only
//! when both have the same base, the base reads no heap, and the constant
//! byte ranges are disjoint (`p->a` survives a store to `p->b`, nothing
//! survives a store through another pointer, which may alias).  Any statement
//! that is not a plain assignment, `let`/`var`, `++`/`--` of a variable,
//! `return` or `if` condition ends the run, a statement whose expression
//! contains a call or an inner assignment ends it, and a first load only under
//! `&&`/`||`/`?:` is never hoisted.  A function with a `volatile` heap access
//! is left untouched (the translator marks it while lowering, `VOLATILE` in
//! `linear.rs`).
use super::{load, store, Scalar, MEM};
use crate::cfg::labels::{collect_written, is_site_temporary, rename_vars};
use das_ast::{DaBlock, DaExpr, DaStmt, DaType, DaTypeKind};
use std::collections::{BTreeSet, HashMap, HashSet};

/// The calls that neither read nor write memory and cannot fail.
const PURE_CALLS: &[&str] = &[
    "uint_bits_to_float",
    "float_bits_to_uint",
    "uint64_bits_to_double",
    "double_bits_to_uint64",
];

/// A load the pass knows: its kind (as the key prefix) and stable address.
fn match_load(e: &DaExpr) -> Option<(Scalar, DaExpr)> {
    let (s, inner) = match e {
        DaExpr::Call(f, args) if args.len() == 1 => match &**f {
            DaExpr::Var(n) if n == "uint_bits_to_float" => (Scalar::F32, &args[0]),
            _ => return None,
        },
        DaExpr::Cast { expr, .. } => (Scalar::I32, &**expr),
        _ => return None,
    };
    let mut first = inner;
    while let DaExpr::Op2 { op: "|", left, .. } = first {
        first = left;
    }
    let DaExpr::Cast { expr, .. } = first else {
        return None;
    };
    let DaExpr::Index(base, a) = &**expr else {
        return None;
    };
    if !matches!(&**base, DaExpr::Var(n) if n == MEM) || !address_ok(a) {
        return None;
    }
    if !matches!(inner, DaExpr::Op2 { op: "|", .. }) {
        return None;
    }
    let canonical = load(s, a);
    (format!("{canonical:?}") == format!("{e:?}")).then(|| (s, (**a).clone()))
}

/// An address the pass may remember: locals, constants, integer arithmetic,
/// conversions and heap loads (killed with every heap store).
fn address_ok(a: &DaExpr) -> bool {
    match a {
        DaExpr::Var(_) | DaExpr::ConstInt(_) | DaExpr::ConstUInt(_) => true,
        DaExpr::Op2 {
            op: "+" | "-" | "*" | "|" | "<<" | ">>" | "&",
            left,
            right,
        } => address_ok(left) && address_ok(right),
        DaExpr::Cast { expr, .. } => address_ok(expr),
        DaExpr::Index(base, i) => matches!(&**base, DaExpr::Var(n) if n == MEM) && address_ok(i),
        _ => false,
    }
}

/// The identity of a load: its kind and its address as `base + offset`, so
/// that `(p + 0 * 12) + 4` and `p + (0 * 12 + 4)` are one address.
fn key_of(s: Scalar, a: &DaExpr) -> String {
    let (base, off) = split(a);
    format!("{s:?}@{base}+{off}")
}

fn vars_of(e: &DaExpr, out: &mut BTreeSet<String>) {
    match e {
        DaExpr::Var(n) => {
            out.insert(n.clone());
        }
        DaExpr::Op2 { left, right, .. } => {
            vars_of(left, out);
            vars_of(right, out);
        }
        DaExpr::Cast { expr, .. } | DaExpr::Op1 { expr, .. } => vars_of(expr, out),
        DaExpr::Index(b, i) => {
            vars_of(b, out);
            vars_of(i, out);
        }
        _ => {}
    }
}

/// True when evaluating `e` has no effect besides its value: no assignment,
/// no call outside [`PURE_CALLS`], no block.
fn is_clean(e: &DaExpr) -> bool {
    match e {
        DaExpr::ConstInt(_)
        | DaExpr::ConstUInt(_)
        | DaExpr::ConstFloat(_)
        | DaExpr::ConstDouble(_)
        | DaExpr::ConstBool(_)
        | DaExpr::ConstNull
        | DaExpr::Var(_) => true,
        DaExpr::Field(b, _) => is_clean(b),
        DaExpr::Index(b, i) => is_clean(b) && is_clean(i),
        DaExpr::Op1 { expr, .. } | DaExpr::Cast { expr, .. } => is_clean(expr),
        DaExpr::Op2 { left, right, .. } => is_clean(left) && is_clean(right),
        DaExpr::Op3 { cond, then, else_ } => is_clean(cond) && is_clean(then) && is_clean(else_),
        DaExpr::Call(f, args) => {
            matches!(&**f, DaExpr::Var(n) if PURE_CALLS.contains(&n.as_str()))
                && args.iter().all(is_clean)
        }
        _ => false,
    }
}

/// The known loads of `e`: `(key, kind, address, unconditional)`.
fn loads_in(e: &DaExpr, cond: bool, out: &mut Vec<(String, Scalar, DaExpr, bool)>) {
    if let Some((s, a)) = match_load(e) {
        // The address's own loads are evaluated with this one.
        loads_in(&a, cond, out);
        out.push((key_of(s, &a), s, a, !cond));
        return;
    }
    match e {
        DaExpr::Field(b, _) => loads_in(b, cond, out),
        DaExpr::Index(b, i) => {
            loads_in(b, cond, out);
            loads_in(i, cond, out);
        }
        DaExpr::Op1 { expr, .. } | DaExpr::Cast { expr, .. } => loads_in(expr, cond, out),
        DaExpr::Op2 {
            op: "&&" | "||",
            left,
            right,
        } => {
            loads_in(left, cond, out);
            loads_in(right, true, out);
        }
        DaExpr::Op2 { left, right, .. } => {
            loads_in(left, cond, out);
            loads_in(right, cond, out);
        }
        DaExpr::Op3 {
            cond: c,
            then,
            else_,
        } => {
            loads_in(c, cond, out);
            loads_in(then, true, out);
            loads_in(else_, true, out);
        }
        DaExpr::Call(_, args) => args.iter().for_each(|a| loads_in(a, cond, out)),
        _ => {}
    }
}

/// Every known load in `e` whose key is in `names` reads that name.
fn rewrite(e: &mut DaExpr, names: &[(String, String)]) {
    if let Some((s, a)) = match_load(e) {
        let key = key_of(s, &a);
        if let Some((_, name)) = names.iter().find(|(k, _)| *k == key) {
            *e = DaExpr::Var(name.clone());
            return;
        }
    }
    match e {
        DaExpr::Field(b, _) => rewrite(b, names),
        DaExpr::Index(b, i) => {
            rewrite(b, names);
            rewrite(i, names);
        }
        DaExpr::Op1 { expr, .. } | DaExpr::Cast { expr, .. } => rewrite(expr, names),
        DaExpr::Op2 { left, right, .. } => {
            rewrite(left, names);
            rewrite(right, names);
        }
        DaExpr::Op3 { cond, then, else_ } => {
            rewrite(cond, names);
            rewrite(then, names);
            rewrite(else_, names);
        }
        DaExpr::Call(_, args) => args.iter_mut().for_each(|a| rewrite(a, names)),
        _ => {}
    }
}

struct Group {
    name: String,
    /// The statement the first load is hoisted before; `None` when the value
    /// is forwarded from a store.
    def: Option<(usize, DaExpr, DaType)>,
    uses: usize,
    /// The type of the name when it is a `let` of this pass (here or in an
    /// enclosing block), never written: a later temporary that only copies it
    /// is renamed to it.
    let_ty: Option<DaType>,
}

/// The pass's state for one function body.
struct Pass<'f> {
    fresh: &'f mut dyn FnMut() -> String,
    /// Every name the body assigns, steps or takes the address of.
    written: HashSet<String>,
}

/// A load whose value is known at the current statement.
#[derive(Clone)]
struct Avail {
    key: String,
    /// The variables its address (and forwarded value) reads.
    vars: BTreeSet<String>,
    /// Its address as `base + off`, and whether the base reads no heap.
    base: String,
    off: i64,
    width: i64,
    stable_base: bool,
    group: usize,
    /// The name holding the value, when inherited from an enclosing block.
    name: Option<String>,
    /// That name's type when it is a `let` of this pass ([`Group::let_ty`]).
    let_ty: Option<DaType>,
}

impl Avail {
    fn new(key: String, a: &DaExpr, value: Option<String>, group: usize) -> Avail {
        let mut vars = BTreeSet::new();
        vars_of(a, &mut vars);
        vars.extend(value);
        let (base, off) = split(a);
        Avail {
            key,
            vars,
            stable_base: !base.contains("Index("),
            base,
            off,
            width: 4,
            group,
            name: None,
            let_ty: None,
        }
    }
}

/// One run of the pass over the statements of a block, then over every block
/// nested in them.  `entry` are the loads known on entry to the block.
fn reuse_block(stmts: &mut Vec<DaStmt>, pass: &mut Pass, entry: &[Avail]) {
    let mut groups: Vec<Group> = Vec::new();
    let mut avail: Vec<Avail> = Vec::new();
    for av in entry {
        groups.push(Group {
            name: av.name.clone().unwrap_or_default(),
            def: None,
            uses: 0,
            let_ty: av.let_ty.clone(),
        });
        avail.push(Avail {
            group: groups.len() - 1,
            name: None,
            ..av.clone()
        });
    }
    // Per statement: (key, group) of its known loads.
    let mut uses: Vec<Vec<(String, usize)>> = vec![Vec::new(); stmts.len()];
    // Per `if` statement: the loads known on entry to its branches.
    let mut inherit: Vec<Vec<Avail>> = vec![Vec::new(); stmts.len()];
    let mut i = 0;
    while i < stmts.len() {
        // The pieces of statement `i` that are read, and what it writes.
        let (reads, write): (Vec<&DaExpr>, Write) = match &stmts[i] {
            DaStmt::Let { name, init, .. } | DaStmt::Var { name, init, .. } => {
                (init.iter().collect(), Write::Local(name.clone()))
            }
            DaStmt::Expr(DaExpr::Assign(lhs, rhs)) => assign_parts(lhs, rhs),
            DaStmt::Expr(DaExpr::AssignOp { left, right, .. }) => assign_parts(left, right),
            DaStmt::Expr(DaExpr::IncDec { place, .. }) => match &**place {
                DaExpr::Var(n) => (Vec::new(), Write::Local(n.clone())),
                _ => (Vec::new(), Write::Barrier),
            },
            DaStmt::Expr(DaExpr::IfThenElse { cond, .. }) => (vec![&**cond], Write::Barrier),
            DaStmt::Expr(DaExpr::Return(Some(v))) => (vec![&**v], Write::Barrier),
            _ => (Vec::new(), Write::Barrier),
        };
        let clean = reads.iter().all(|e| is_clean(e));
        let if_branches = match &stmts[i] {
            DaStmt::Expr(DaExpr::IfThenElse {
                then, elifs, else_, ..
            }) if clean && elifs.is_empty() => Some((then, else_)),
            _ => None,
        };
        if clean {
            let mut found = Vec::new();
            for e in &reads {
                loads_in(e, false, &mut found);
            }
            for (key, s, a, unconditional) in found {
                if uses[i].iter().any(|(k, _)| *k == key) {
                    let g = uses[i].iter().find(|(k, _)| *k == key).unwrap().1;
                    groups[g].uses += 1;
                    continue;
                }
                if let Some(av) = avail.iter().find(|av| av.key == key) {
                    groups[av.group].uses += 1;
                    uses[i].push((key, av.group));
                } else if unconditional {
                    let ty = match s {
                        Scalar::F32 => DaType::float(),
                        _ => DaType::int(),
                    };
                    groups.push(Group {
                        name: String::new(),
                        def: Some((i, load(s, &a), ty.clone())),
                        uses: 1,
                        let_ty: Some(ty),
                    });
                    let g = groups.len() - 1;
                    avail.push(Avail::new(key.clone(), &a, None, g));
                    uses[i].push((key, g));
                }
            }
        }
        // The loads known after an `if` condition are still valid on entry
        // to either branch.
        if let Some((then, else_)) = if_branches {
            let mut keys = BTreeSet::new();
            all_keys(then, &mut keys);
            if let Some(e) = else_ {
                all_keys(e, &mut keys);
            }
            for av in avail.iter().filter(|av| keys.contains(&av.key)) {
                groups[av.group].uses += 2;
                inherit[i].push(av.clone());
            }
        }
        match write {
            _ if !clean => avail.clear(),
            Write::Local(name) => avail.retain(|av| !av.vars.contains(&name)),
            Write::Heap(a) => {
                if let Some((a, v, len)) = forwarded_store(stmts, i) {
                    kill_overlapping(&mut avail, &a, 4);
                    groups.push(Group {
                        name: v.clone(),
                        def: None,
                        uses: 0,
                        let_ty: None,
                    });
                    let key = key_of(Scalar::F32, &a);
                    avail.push(Avail::new(key, &a, Some(v), groups.len() - 1));
                    // The other three bytes of the same store.
                    i += len;
                    continue;
                }
                kill_overlapping(&mut avail, &a, 1);
            }
            Write::Barrier => avail.clear(),
        }
        i += 1;
    }

    let mut out = Vec::with_capacity(stmts.len());
    // Temporaries that only copy a `let` of this pass: their uses read it.
    let mut renamed: HashMap<String, String> = HashMap::new();
    for (i, mut stmt) in std::mem::take(stmts).into_iter().enumerate() {
        // Groups worth a name (a repeat of a load) are named in source order:
        // at the statement their `let` goes before, ahead of the blocks
        // nested in it.
        for g in groups.iter_mut() {
            if let Some((at, init, ty)) = &g.def {
                if *at == i && g.uses >= 2 {
                    g.name = (pass.fresh)();
                    out.push(DaStmt::Let {
                        name: g.name.clone(),
                        var_type: Some(ty.clone()),
                        init: Some(init.clone()),
                    });
                }
            }
        }
        let names: Vec<(String, String)> = uses
            .get(i)
            .map(|u| {
                u.iter()
                    .filter(|(_, g)| {
                        let g = &groups[*g];
                        !g.name.is_empty() && (g.def.is_none() || g.uses >= 2)
                    })
                    .map(|(k, g)| (k.clone(), groups[*g].name.clone()))
                    .collect()
            })
            .unwrap_or_default();
        if !names.is_empty() {
            rewrite_stmt(&mut stmt, &names);
        }
        let entry: Vec<Avail> = inherit
            .get(i)
            .map(|v| {
                v.iter()
                    .filter(|av| !groups[av.group].name.is_empty())
                    .map(|av| Avail {
                        name: Some(groups[av.group].name.clone()),
                        let_ty: groups[av.group].let_ty.clone(),
                        ..av.clone()
                    })
                    .collect()
            })
            .unwrap_or_default();
        match &mut stmt {
            DaStmt::Expr(DaExpr::IfThenElse {
                then, elifs, else_, ..
            }) if !entry.is_empty() && elifs.is_empty() => {
                nested_in_expr(then, pass, &entry);
                if let Some(e) = else_ {
                    nested_in_expr(e, pass, &entry);
                }
            }
            _ => nested_blocks(&mut stmt, pass),
        }
        if let Some((alias, target)) = copy_of_let(&stmt, &groups, &pass.written) {
            renamed.insert(alias, target);
            continue;
        }
        out.push(stmt);
    }
    // The block's statements, nested blocks included, are rewritten by now;
    // an alias is declared once and read only after its declaration.
    if !renamed.is_empty() {
        for stmt in &mut out {
            match stmt {
                DaStmt::Expr(e)
                | DaStmt::Let { init: Some(e), .. }
                | DaStmt::Var { init: Some(e), .. } => rename_vars(e, &renamed),
                _ => {}
            }
        }
    }
    *stmts = out;
}

/// `let t = n` (or a `var t` never written) of a site temporary `t` whose
/// whole initializer reads `n`, a `let` of this pass of the same type:
/// `(t, n)`.  Both are immutable, so every read of `t` may read `n`.
fn copy_of_let(
    stmt: &DaStmt,
    groups: &[Group],
    written: &HashSet<String>,
) -> Option<(String, String)> {
    let (name, ty, init) = match stmt {
        DaStmt::Let {
            name,
            var_type,
            init: Some(DaExpr::Var(n)),
        } => (name, var_type.as_ref(), n),
        DaStmt::Var {
            name,
            var_type,
            init: Some(DaExpr::Var(n)),
        } => (name, Some(var_type), n),
        _ => return None,
    };
    if !is_site_temporary(name) || written.contains(name) {
        return None;
    }
    let group = groups.iter().find(|g| g.name == *init)?;
    let let_ty = group.let_ty.as_ref()?;
    ty.map_or(true, |t| t == let_ty)
        .then(|| (name.clone(), init.clone()))
}

enum Write {
    /// A daslang local or global named so.
    Local(String),
    /// A byte store into `c2da_mem` at this address.
    Heap(DaExpr),
    /// Anything else: control flow, a store through a daslang reference.
    Barrier,
}

fn assign_parts<'e>(lhs: &'e DaExpr, rhs: &'e DaExpr) -> (Vec<&'e DaExpr>, Write) {
    match lhs {
        DaExpr::Var(n) => (vec![rhs], Write::Local(n.clone())),
        DaExpr::Index(base, a) if matches!(&**base, DaExpr::Var(n) if n == MEM) => {
            (vec![&**a, rhs], Write::Heap((**a).clone()))
        }
        _ => (Vec::new(), Write::Barrier),
    }
}

/// The value of an integer constant expression.
fn const_eval(e: &DaExpr) -> Option<i64> {
    match e {
        DaExpr::ConstInt(v) => Some(*v),
        // The typed `int` literal `int(k)`.
        DaExpr::Cast { expr, to, .. } if to.kind == DaTypeKind::Int => match **expr {
            DaExpr::ConstInt(v) if i32::try_from(v).is_ok() => Some(v),
            _ => None,
        },
        DaExpr::Op2 { op, left, right } => {
            let (l, r) = (const_eval(left)?, const_eval(right)?);
            match *op {
                "+" => l.checked_add(r),
                "-" => l.checked_sub(r),
                "*" => l.checked_mul(r),
                _ => None,
            }
        }
        _ => None,
    }
}

/// `a` as `base + offset`, the base spelled out (empty for a constant).
fn split(a: &DaExpr) -> (String, i64) {
    if let Some(c) = const_eval(a) {
        return (String::new(), c);
    }
    if let DaExpr::Op2 {
        op: "+",
        left,
        right,
    } = a
    {
        if let Some(c) = const_eval(right) {
            let (base, k) = split(left);
            return (base, k + c);
        }
    }
    (format!("{a:?}"), 0)
}

/// After a store of `width` bytes at `a`: keeps only the loads it provably
/// misses — same base, disjoint constant offsets, no heap load in the base.
fn kill_overlapping(avail: &mut Vec<Avail>, a: &DaExpr, width: i64) {
    let (base, off) = split(a);
    avail.retain(|av| {
        av.stable_base && av.base == base && (off + width <= av.off || av.off + av.width <= off)
    });
}

/// Every known load key anywhere in `e`, nested blocks included.
fn all_keys(e: &DaExpr, out: &mut BTreeSet<String>) {
    if let Some((s, a)) = match_load(e) {
        out.insert(key_of(s, &a));
    }
    let stmt_keys = |s: &DaStmt, out: &mut BTreeSet<String>| match s {
        DaStmt::Expr(e) | DaStmt::Let { init: Some(e), .. } | DaStmt::Var { init: Some(e), .. } => {
            all_keys(e, out)
        }
        _ => {}
    };
    match e {
        DaExpr::Field(b, _) | DaExpr::Op1 { expr: b, .. } | DaExpr::Cast { expr: b, .. } => {
            all_keys(b, out)
        }
        DaExpr::Index(l, r)
        | DaExpr::Op2 {
            left: l, right: r, ..
        }
        | DaExpr::Assign(l, r)
        | DaExpr::AssignOp {
            left: l, right: r, ..
        }
        | DaExpr::While(l, r) => {
            all_keys(l, out);
            all_keys(r, out);
        }
        DaExpr::Op3 { cond, then, else_ } => {
            all_keys(cond, out);
            all_keys(then, out);
            all_keys(else_, out);
        }
        DaExpr::Call(_, args) => args.iter().for_each(|a| all_keys(a, out)),
        DaExpr::IncDec { place, .. } => all_keys(place, out),
        DaExpr::Return(Some(v)) => all_keys(v, out),
        DaExpr::Block(DaBlock { stmts }) => stmts.iter().for_each(|s| stmt_keys(s, out)),
        DaExpr::IfThenElse {
            cond,
            then,
            elifs,
            else_,
        } => {
            all_keys(cond, out);
            all_keys(then, out);
            for (c, b) in elifs {
                all_keys(c, out);
                all_keys(b, out);
            }
            if let Some(b) = else_ {
                all_keys(b, out);
            }
        }
        DaExpr::For { sources, body, .. } => {
            sources.iter().for_each(|s| all_keys(s, out));
            all_keys(body, out);
        }
        _ => {}
    }
}

/// `stmts[i]` is the first byte store of `store(F32, a, v)` for a named `v`
/// (with the `let` of its bits right before it): `(a, v, number of byte
/// stores)`.
fn forwarded_store(stmts: &[DaStmt], i: usize) -> Option<(DaExpr, String, usize)> {
    let DaStmt::Let {
        name: bits,
        init: Some(DaExpr::Call(f, args)),
        ..
    } = stmts.get(i.checked_sub(1)?)?
    else {
        return None;
    };
    if !matches!(&**f, DaExpr::Var(n) if n == "float_bits_to_uint") || args.len() != 1 {
        return None;
    }
    let DaExpr::Var(v) = &args[0] else {
        return None;
    };
    let DaStmt::Expr(DaExpr::Assign(lhs, _)) = &stmts[i] else {
        return None;
    };
    let DaExpr::Index(_, a) = &**lhs else {
        return None;
    };
    if !address_ok(a) {
        return None;
    }
    let bits_name = bits.clone();
    let expected = store(Scalar::F32, a, &DaExpr::Var(v.clone()), &mut || {
        bits_name.clone()
    });
    let n = expected.len();
    let got = stmts.get(i - 1..i - 1 + n)?;
    (format!("{expected:?}") == format!("{got:?}")).then(|| ((**a).clone(), v.clone(), n - 1))
}

fn rewrite_stmt(stmt: &mut DaStmt, names: &[(String, String)]) {
    match stmt {
        DaStmt::Let { init: Some(e), .. } | DaStmt::Var { init: Some(e), .. } => rewrite(e, names),
        DaStmt::Expr(DaExpr::Assign(lhs, rhs))
        | DaStmt::Expr(DaExpr::AssignOp {
            left: lhs,
            right: rhs,
            ..
        }) => {
            if let DaExpr::Index(_, a) = &mut **lhs {
                rewrite(a, names);
            }
            rewrite(rhs, names);
        }
        DaStmt::Expr(DaExpr::IfThenElse { cond, .. }) => rewrite(cond, names),
        DaStmt::Expr(DaExpr::Return(Some(v))) => rewrite(v, names),
        _ => {}
    }
}

/// Runs the pass over every block nested in `stmt`, each on its own.
fn nested_blocks(stmt: &mut DaStmt, pass: &mut Pass) {
    match stmt {
        DaStmt::Expr(e) => nested_in_expr(e, pass, &[]),
        DaStmt::Let { init: Some(e), .. } | DaStmt::Var { init: Some(e), .. } => {
            nested_in_expr(e, pass, &[])
        }
        _ => {}
    }
}

/// Runs the pass over the blocks of `e`; `entry` are the loads known when a
/// block `e` itself starts.
fn nested_in_expr(e: &mut DaExpr, pass: &mut Pass, entry: &[Avail]) {
    match e {
        DaExpr::Block(DaBlock { stmts }) => reuse_block(stmts, pass, entry),
        DaExpr::IfThenElse {
            then, elifs, else_, ..
        } => {
            nested_in_expr(then, pass, &[]);
            for (_, b) in elifs.iter_mut() {
                nested_in_expr(b, pass, &[]);
            }
            if let Some(b) = else_ {
                nested_in_expr(b, pass, &[]);
            }
        }
        DaExpr::While(_, body) | DaExpr::For { body, .. } => nested_in_expr(body, pass, &[]),
        DaExpr::TryRecover(body, handler) => {
            nested_in_expr(body, pass, &[]);
            nested_in_expr(handler, pass, &[]);
        }
        _ => {}
    }
}

/// The pass over a lowered function body.
pub(crate) fn reuse_loads(stmts: &mut Vec<DaStmt>, fresh: &mut dyn FnMut() -> String) {
    let mut written = HashSet::new();
    for stmt in stmts.iter_mut() {
        match stmt {
            DaStmt::Expr(e)
            | DaStmt::Let { init: Some(e), .. }
            | DaStmt::Var { init: Some(e), .. } => collect_written(e, &mut written),
            _ => {}
        }
    }
    let mut pass = Pass { fresh, written };
    reuse_block(stmts, &mut pass, &[]);
}
