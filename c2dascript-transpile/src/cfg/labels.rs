//! Flat `label`/`goto` back end: a CFG rendered as daScript statements.
//!
//! daslang has first-class numeric labels and jumps — `label 3:` marks a point in
//! a function body and `goto label 3` transfers control to it (daslang reference,
//! `language/statements.rst`, section "label and goto").  Jumps out of, into and
//! across `while` bodies and past local `var` declarations are all legal, which
//! makes this the one lowering that is *total*: every C control-flow graph,
//! reducible or not, has an exact rendering.
//!
//! Rendering has these steps:
//!
//! 1. **Layout** — a depth-first walk from the entry block that prefers the
//!    successor which can fall through (the `false` arm of a branch, a `switch`'s
//!    default arm), so most edges cost no `goto` at all.
//! 2. **Terminator planning** — each block's terminator is turned into a [`Tail`],
//!    which records exactly which edges still need an explicit jump.
//! 3. **Emission** — labels are numbered in layout order and only assigned to
//!    blocks that a planned jump actually targets, then the statements are
//!    concatenated.
//! 4. **Dead-tail repair** — a label that no executable statement follows is
//!    turned back into a plain `return`; see [`dead_tail_labels`].  A `return`
//!    left directly after another one by that repair is dropped
//!    ([`drop_returns_after_return`]).
//! 5. **Early-exit placement** — an `if (c) { … return }` that a jump
//!    crosses, with labels after it, would be folded by daslang into an
//!    `else` block whose label table the interpreter cannot jump across; its
//!    arm moves out of line behind a label of its own
//!    ([`move_crossed_early_exits`]).
//!
//! A hoisted declaration carries no initializer when daslang's own zero-fill
//! of a bare `var x : T` is the value it would be given — numbers, pointers,
//! function values, aliases of them and plain structs and fixed arrays of
//! them (`Translation::declaration_zero_fills` for C declarations,
//! `Translation::da_type_zero_fills` for site temporaries).  A C local
//! without an initializer is indeterminate, so that zero is daslang's, never
//! a store the program relies on; a C initializer is an assignment at the C
//! declaration point and runs every time control passes it.  The one
//! exception is the body's first statement: when it stores the last hoisted
//! declaration, nothing lies between the two and the value moves into the
//! declaration ([`initialise_last_declaration`]).  AOT prints a bare `var` as
//! an initialised C++ declaration too (`int32_t x = 0;`, `das_zero(x)`), so the
//! hoisting below is still what keeps a forward `goto` legal C++.
//!
//! Everything a block declares lands in the function's own scope: daScript
//! scopes a `var` to its enclosing block, and here that block is the function
//! body.  Two kinds of declaration still get hoisted to the top of that body,
//! for two different readers:
//!
//! * C declarations, in [`render`] step 1, because C gives a block-scope object
//!   storage for the whole block however control enters it;
//! * the translator's own site temporaries (`c2da_fresh*`, `___inl*_res`,
//!   `__c2da_postinc_*`, ...), in [`hoist_site_temporaries`], because daslang's
//!   AOT emits a `var` as a C++ declaration at the same position, and C++
//!   forbids a `goto` that jumps forward past an initialised declaration in the
//!   same scope (`error: cannot jump from this goto statement to its label`).
//!   The interpreter, the JIT and `-exe` never minded; AOT is a fourth back end
//!   of the same text and has to compile too.

use super::*;
use das_ast::{DaBlock, DaExpr, DaStmt, DaType, DaTypeKind};

/// What has to be emitted after a block's own statements.
enum Tail {
    /// The terminator's successor is the next block in layout order.
    FallThrough,
    /// The block ends the function (its body already returned or trapped).
    End,
    Goto(Label),
    /// `if cond { goto target }`, falling through otherwise.
    IfGoto(DaExpr, Label),
    /// `if cond { goto then } else { goto else }`.
    IfElseGoto(DaExpr, Label, Label),
    /// A `switch` dispatch: find the arm of the scrutinee's value through
    /// `tree`, and take the default arm when no case matches.  `default` is
    /// `None` when the default arm is the next block in layout order.
    Dispatch {
        scrutinee: DaExpr,
        tree: DispatchTree,
        default: Option<Label>,
    },
}

impl Tail {
    /// Every label this tail jumps to by name, and therefore needs a
    /// `label N:` on.  A jump table reaches its targets by number instead,
    /// through the aliases numbered after these (see [`render_once`]).
    fn targets(&self) -> Vec<&Label> {
        match self {
            Tail::FallThrough | Tail::End => vec![],
            Tail::Goto(l) | Tail::IfGoto(_, l) => vec![l],
            Tail::IfElseGoto(_, t, f) => vec![t, f],
            Tail::Dispatch { tree, default, .. } => {
                let mut targets = Vec::new();
                tree.named_targets(&mut targets);
                targets.extend(default.iter());
                targets
            }
        }
    }
}

/// How a `switch` dispatch finds the arm of the scrutinee's value.
///
/// C gives a `switch` no evaluation order among its case comparisons — the
/// controlling expression is evaluated once (a plain read or a temporary, see
/// `CfgBuilder`'s `Switch`) and control goes to the one matching label, the
/// values being distinct after conversion to the promoted type (C11 6.8.4.2).
/// So the dispatch may test the values in any order and shape, and it is
/// shaped for the daslang interpreter, which pays one node per comparison:
///
/// * a range of cases dense enough ([`TABLE_SPAN_PER_CASE`]) is one bounds
///   test and one computed `goto` — daslang's `goto <int expr>` — whose
///   operand is the scrutinee's offset into a run of consecutive label
///   numbers, one per value of the range, placed on the arms (holes on the
///   default arm);
/// * a short run ([`TESTS_MAX`] cases or fewer) is an `if`/`elif` chain of
///   equality tests;
/// * anything else is split at its median value, `if x < pivot`, so a sparse
///   switch costs O(log n) comparisons.
///
/// None of the three nests deeper than the logarithm of the case count, so
/// daslang's AOT — which prints each `elif` as a nested `else { if … }` —
/// stays within a C++ compiler's bracket-nesting limit (256 for clang) for any
/// `switch` (a 256-case `switch` used to exceed it).
enum DispatchTree {
    /// `if x == k0 { goto L0 } elif x == k1 { goto L1 } …`
    Tests(Vec<(DaExpr, Label)>),
    /// `if low <= x && x <= high { goto <number of the label for x> }`.
    Table {
        /// The lowest and highest case value, as the typed case constants.
        low: DaExpr,
        high: DaExpr,
        /// The lowest case value as a number, in the dispatch type.
        low_key: i128,
        /// The arm of each value `low_key + i`, in order.
        entries: Vec<Label>,
        /// The label number of `entries[0]`'s alias; assigned once the
        /// named labels are numbered.
        base: Option<u64>,
    },
    /// `if x < pivot { below } else { above }`.
    Split {
        pivot: DaExpr,
        below: Box<DispatchTree>,
        above: Box<DispatchTree>,
    },
}

/// The longest run of cases dispatched by comparing against each value.
const TESTS_MAX: usize = 4;

/// A run of cases longer than [`TESTS_MAX`] is a jump table when its range of
/// values is at most this many times its case count (at least half of the
/// range is cases).
const TABLE_SPAN_PER_CASE: u128 = 2;

/// A case value converted to the dispatch type, as a mathematical integer, and
/// the arm it selects.
struct KeyedCase {
    key: i128,
    value: DaExpr,
    target: Label,
}

impl DispatchTree {
    fn build(cases: &[KeyedCase], default: &Label) -> DispatchTree {
        let (Some(first), Some(last)) = (cases.first(), cases.last()) else {
            return DispatchTree::Tests(vec![]);
        };
        if cases.len() <= TESTS_MAX {
            return DispatchTree::Tests(
                cases
                    .iter()
                    .map(|case| (case.value.clone(), case.target.clone()))
                    .collect(),
            );
        }
        let span = (last.key - first.key) as u128 + 1;
        if span <= TABLE_SPAN_PER_CASE * cases.len() as u128 {
            let mut entries = vec![default.clone(); span as usize];
            for case in cases {
                entries[(case.key - first.key) as usize] = case.target.clone();
            }
            return DispatchTree::Table {
                low: first.value.clone(),
                high: last.value.clone(),
                low_key: first.key,
                entries,
                base: None,
            };
        }
        let middle = cases.len() / 2;
        DispatchTree::Split {
            pivot: cases[middle].value.clone(),
            below: Box::new(DispatchTree::build(&cases[..middle], default)),
            above: Box::new(DispatchTree::build(&cases[middle..], default)),
        }
    }

    fn named_targets<'a>(&'a self, out: &mut Vec<&'a Label>) {
        match self {
            DispatchTree::Tests(tests) => out.extend(tests.iter().map(|(_, l)| l)),
            DispatchTree::Table { .. } => {}
            DispatchTree::Split { below, above, .. } => {
                below.named_targets(out);
                above.named_targets(out);
            }
        }
    }

    fn tables_mut<'a>(&'a mut self, out: &mut Vec<(&'a [Label], &'a mut Option<u64>)>) {
        match self {
            DispatchTree::Tests(_) => {}
            DispatchTree::Table { entries, base, .. } => out.push((entries.as_slice(), base)),
            DispatchTree::Split { below, above, .. } => {
                below.tables_mut(out);
                above.tables_mut(out);
            }
        }
    }
}

/// The value of a case constant of the dispatch, converted to the dispatch
/// type, as a number: `CfgBuilder` builds every case value as a conversion of
/// the C case constant to the promoted scrutinee type.
fn case_key(value: &DaExpr) -> Option<(i128, DaType)> {
    let DaExpr::Cast {
        kind: das_ast::CastKind::Cast,
        expr,
        to,
    } = value
    else {
        return None;
    };
    let raw: i128 = match **expr {
        DaExpr::ConstInt(v) => v.into(),
        DaExpr::ConstUInt(v) => v.into(),
        _ => return None,
    };
    // daScript's conversion of an integer constant is modulo 2^width, as C's
    // conversion of a case constant to the promoted type is (C11 6.3.1.3).
    let key = match to.kind {
        DaTypeKind::Int => (raw as i32).into(),
        DaTypeKind::UInt => (raw as u32).into(),
        DaTypeKind::Int64 => (raw as i64).into(),
        DaTypeKind::UInt64 => (raw as u64).into(),
        _ => return None,
    };
    Some((key, to.clone()))
}

/// Render a pruned, edge-validated CFG as a flat daScript statement list.
///
/// `zero_fills` tells whether a bare `var x : T` already holds `T`'s default
/// value (`Translation::da_type_zero_fills`); a hoisted site temporary of such
/// a type is declared without an explicit one.
pub(crate) fn render(
    cfg: Cfg<Label, StmtOrDecl>,
    store: DeclStmtStore,
    zero_fills: &dyn Fn(&DaType) -> bool,
) -> TranslationResult<Vec<DaStmt>> {
    let has_dispatch = cfg
        .nodes
        .values()
        .any(|block| matches!(block.terminator, Switch { .. }));
    if !has_dispatch {
        return match render_once(cfg, store, zero_fills, &IndexSet::new())? {
            Rendered::Body(out) => Ok(out),
            Rendered::ReturnsThroughTable(_) => Err(TranslationError::generic(
                "label rendering: a jump table without a switch",
            )),
        };
    }
    // A jump-table alias that ends up above nothing but the function's
    // closing `return` cannot be jumped to (see `dead_tail_labels`), and a
    // computed jump cannot be rewritten to `return` the way a named one is.
    // Such an arm means "return", so it is rendered again with those entries
    // sent to a `return` trampoline instead; each round adds at least one
    // arm, so this ends.
    let mut returning: IndexSet<Label> = IndexSet::new();
    loop {
        match render_once(cfg.clone(), store.clone(), zero_fills, &returning)? {
            Rendered::Body(out) => return Ok(out),
            Rendered::ReturnsThroughTable(arms) => {
                let known = returning.len();
                returning.extend(arms);
                if returning.len() == known {
                    return Err(TranslationError::generic(
                        "label rendering: a jump-table arm still falls off the function",
                    ));
                }
            }
        }
    }
}

enum Rendered {
    Body(Vec<DaStmt>),
    /// These arms are reached through a jump table and mean "fall off the
    /// end of the function".
    ReturnsThroughTable(Vec<Label>),
}

/// One rendering of the graph; `returning` are the jump-table arms to send to
/// a `return` trampoline.
fn render_once(
    cfg: Cfg<Label, StmtOrDecl>,
    mut store: DeclStmtStore,
    zero_fills: &dyn Fn(&DaType) -> bool,
    returning: &IndexSet<Label>,
) -> TranslationResult<Rendered> {
    let order = layout(&cfg);

    // Every local declaration is split: the `var` is hoisted to the top of the
    // function (bare, or with its default value when daslang's zero-fill is
    // not that value), and only the C initializer stays where
    // the declaration was.  C gives a block-scope object storage for the whole
    // block regardless of where control enters, and a `goto` may well jump over
    // a declaration and then read the object; hoisting is what makes that
    // behave.  Declarations are hoisted in the order the CFG built them, which
    // is source order.
    let declared: IndexSet<CDeclId> = cfg
        .nodes
        .values()
        .flat_map(|block| block.body.iter())
        .filter_map(|item| match item {
            StmtOrDecl::Decl(decl_id) => Some(*decl_id),
            StmtOrDecl::Stmt(_) => None,
        })
        .collect();
    let mut hoisted: Vec<DaStmt> = cfg.prelude.clone();
    for decl_id in &declared {
        hoisted.extend(store.extract_decl(*decl_id)?.into_iter().map(writable_decl));
    }

    // Step 2: plan every terminator against its fall-through successor.
    // (Hoisted declarations were made writable by `writable_decl` above.)
    let mut tails: Vec<Tail> = Vec::with_capacity(order.len());
    for (index, label) in order.iter().enumerate() {
        let next = order.get(index + 1);
        let block = cfg
            .nodes
            .get(label)
            .expect("layout only visits blocks that exist");
        tails.push(plan(&block.terminator, next)?);
    }

    // Step 3: number only the labels a planned jump targets.
    let jumped_to: IndexSet<&Label> = tails.iter().flat_map(Tail::targets).collect();
    let mut label_ids: IndexMap<Label, u64> = IndexMap::new();
    for label in &order {
        // Numbering follows layout order so the emitted labels read top to
        // bottom, which is what a reader of the generated file expects.
        if jumped_to.contains(label) {
            let id = label_ids.len() as u64;
            label_ids.insert(label.clone(), id);
        }
    }
    drop(jumped_to);

    // Step 3b: number the jump tables.  Each table owns a run of consecutive
    // label numbers after the named ones, one per value of its range, and
    // each number is an alias label on the arm of that value.  An arm in
    // `returning` gets its alias on the `return` trampoline instead.
    let mut next_id = label_ids.len() as u64;
    let mut aliases: IndexMap<Label, Vec<u64>> = IndexMap::new();
    let mut alias_arm: IndexMap<String, Label> = IndexMap::new();
    let mut trampoline_aliases: Vec<u64> = Vec::new();
    for tail in tails.iter_mut() {
        let Tail::Dispatch { tree, .. } = tail else {
            continue;
        };
        let mut tables = Vec::new();
        tree.tables_mut(&mut tables);
        for (entries, base) in tables {
            *base = Some(next_id);
            for arm in entries {
                let id = next_id;
                next_id += 1;
                if returning.contains(arm) {
                    trampoline_aliases.push(id);
                } else {
                    aliases.entry(arm.clone()).or_default().push(id);
                    alias_arm.insert(alias_text(id), arm.clone());
                }
            }
        }
    }

    let goto =
        |label: &Label| -> DaStmt { DaStmt::Expr(DaExpr::Goto(label_text(&label_ids, label))) };
    let goto_block = |label: &Label| -> DaExpr {
        DaExpr::Block(DaBlock {
            stmts: vec![goto(label)],
        })
    };

    let hoisted_len = hoisted.len();
    let mut out: Vec<DaStmt> = hoisted;
    // The `return` trampoline sits at the top of the body, where no closing
    // `return` can be folded away under it; the body jumps past it.
    if !trampoline_aliases.is_empty() {
        let resume = alias_text(next_id);
        out.push(DaStmt::Expr(DaExpr::Goto(resume.clone())));
        for id in &trampoline_aliases {
            out.push(DaStmt::Expr(DaExpr::Label(alias_text(*id))));
        }
        out.push(DaStmt::Expr(DaExpr::Return(None)));
        out.push(DaStmt::Expr(DaExpr::Label(resume)));
    }
    let has_labels = !label_ids.is_empty() || !aliases.is_empty() || !trampoline_aliases.is_empty();
    for (index, label) in order.iter().enumerate() {
        if label_ids.contains_key(label) {
            out.push(DaStmt::Expr(DaExpr::Label(label_text(&label_ids, label))));
        }
        for id in aliases.get(label).into_iter().flatten() {
            out.push(DaStmt::Expr(DaExpr::Label(alias_text(*id))));
        }
        let block = cfg
            .nodes
            .get(label)
            .expect("layout only visits blocks that exist");
        for item in block.body.clone() {
            out.extend(item.place_decls(&declared, &mut store));
        }
        match &tails[index] {
            Tail::FallThrough | Tail::End => {}
            // A block whose statements end in `return` (a C `return` inside
            // `do { … } while (0)`) never reaches its jump.
            Tail::Goto(_) if matches!(out.last(), Some(DaStmt::Expr(DaExpr::Return(_)))) => {}
            Tail::Goto(target) => out.push(goto(target)),
            Tail::IfGoto(cond, target) => out.push(DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(cond.clone()),
                then: Box::new(goto_block(target)),
                elifs: vec![],
                else_: None,
            })),
            Tail::IfElseGoto(cond, then_target, else_target) => {
                out.push(DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(cond.clone()),
                    then: Box::new(goto_block(then_target)),
                    elifs: vec![],
                    else_: Some(Box::new(goto_block(else_target))),
                }))
            }
            Tail::Dispatch {
                scrutinee,
                tree,
                default,
            } => out.extend(dispatch_stmts(scrutinee, tree, &goto, default.as_ref())),
        }
    }

    // The last laid-out block never falls through — its tail is either the end
    // of the function or an unconditional jump — but daScript checks statically
    // that a value-returning function ends on a `return` and cannot see that.
    // Close such a body with an explicitly unreachable trap.
    if !matches!(tails.last(), Some(Tail::End) | None)
        && !matches!(out.last(), Some(DaStmt::Expr(DaExpr::Return(_))))
    {
        out.push(DaStmt::Expr(unreachable_trap(
            "unreachable: fell out of a translated control-flow graph",
        )));
    }

    // Step 4: a body with jumps in it must also be valid C++ once daslang's AOT
    // has emitted it; see `hoist_site_temporaries`.
    let mut body_start = hoisted_len;
    if has_labels {
        body_start = hoist_site_temporaries(&mut out, hoisted_len, zero_fills);
    }

    // Step 5: repair labels daScript would leave dangling at the end of the
    // body.  Dropping a label can put two `return`s next to each other, and
    // dropping the second of those can leave a label above nothing but the
    // body's closing `return` again, so the two alternate until neither
    // changes anything.  A dangling jump-table alias cannot be repaired
    // here (a computed jump names no label to rewrite); its arm is handed
    // back to `render` for the trampoline.
    loop {
        drop_returns_after_return(&mut out);
        let dangling = dead_tail_labels(&out);
        if dangling.is_empty() {
            break;
        }
        let through_table: Vec<Label> = dangling
            .iter()
            .filter_map(|name| alias_arm.get(name).cloned())
            .collect();
        if !through_table.is_empty() {
            return Ok(Rendered::ReturnsThroughTable(through_table));
        }
        for label in dangling {
            retarget_to_return(&mut out, &label);
        }
    }

    // Step 5b: no early exit may leave a jump target where daslang's
    // if-return folding would carry it into a nested block; see
    // `move_crossed_early_exits`.
    move_crossed_early_exits(&mut out, body_start);

    // Step 6: the body's first statement may be the store that initialises
    // the last hoisted declaration; see `initialise_last_declaration`.
    initialise_last_declaration(&mut out);

    Ok(Rendered::Body(out))
}

/// Give the last hoisted `var` its value when the body opens by storing it.
///
/// Hoisting leaves `var x : T` (daslang's zero, see
/// `translator::zero_filled_by_declaration`) at the top and `x = init` where
/// the C declaration stood.  When that store is the very first statement after
/// the declarations, nothing — no label, no other statement — lies between
/// the two, so `var x : T = init` runs the same code once, at the same moment,
/// and every `goto` in the body still lands after it.  Only a declaration with
/// no initializer of its own qualifies (anything else would lose a store), and
/// only when `init` does not name `x` itself, which a declaration's own
/// initializer cannot read.
fn initialise_last_declaration(out: &mut Vec<DaStmt>) {
    let Some(first) = out
        .iter()
        .position(|stmt| !matches!(stmt, DaStmt::Var { .. }))
    else {
        return;
    };
    if first == 0 {
        return;
    }
    let (DaStmt::Var {
        name, init: None, ..
    }, DaStmt::Expr(DaExpr::Assign(target, value))) = (&out[first - 1], &out[first])
    else {
        return;
    };
    if !matches!(target.as_ref(), DaExpr::Var(assigned) if assigned == name) {
        return;
    }
    let mut read: Vec<String> = Vec::new();
    crate::translator::collect_names(value, &mut read);
    if read.iter().any(|read| read == name) {
        return;
    }
    let value = (**value).clone();
    out.remove(first);
    if let DaStmt::Var { init, .. } = &mut out[first - 1] {
        *init = Some(value);
    }
}

/// Remove a top-level `return` that directly follows another one.
///
/// A block that ends the function lays out as its own `return`, and the next
/// block in layout order is reached only through a jump, i.e. through a
/// `label N:` of its own.  Two adjacent `return`s therefore arise where
/// [`dead_tail_labels`] dropped the label between them: a C `return;` laid out
/// last, after the function's own closing `return`, is such a label's only
/// node.  With the label gone the second `return` can never run, daScript
/// reports it as unreachable code, and the body is the same program without
/// it.
fn drop_returns_after_return(out: &mut Vec<DaStmt>) {
    let mut previous_returns = false;
    out.retain(|stmt| {
        let returns = matches!(stmt, DaStmt::Expr(DaExpr::Return(_)));
        let keep = !(returns && previous_returns);
        previous_returns = returns;
        keep
    });
}

/// Move every `var` the statement lowering left at its use site to the top of
/// the body, keeping only the assignment where the declaration was.
///
/// Statement lowering hands each block a prologue of temporaries — the value
/// of a `&&` chain, an inlined callee's result, a post-increment's old value —
/// as `var name : T = init` right before the statement that uses them.  Under
/// the interpreter, the JIT and `-exe` that is fine anywhere in the body.
/// daslang's AOT, though, prints the body as C++ with the same layout, and C++
/// rejects a `goto` whose label lies past an initialised declaration of the
/// same scope, so a function with a single forward jump over such a temporary
/// fails to compile ahead of time.  Splitting the declaration the way step 1
/// already splits C declarations — `var name : T` at the top, `name = init` at
/// the site — makes the jump legal without changing what runs: the site still
/// stores the same value at the same moment, and a hoisted `T` default is the
/// value the object had anyway before its first store.
///
/// Nested blocks are visited too: a structured region the relooper kept
/// inside a jump-rendered body (an `if` arm or a `while` body with statements
/// of its own) declares its temporaries at its own level, and a jump inside
/// that region past one of them is the same C++ error.  Every name is already
/// unique in the function (the renamer sees to that), so moving a declaration
/// up a few scopes cannot capture or shadow anything.
///
/// The hoisted `var` is bare when daslang's own zero-fill is the type's
/// default value (`zero_fills`, `Translation::da_type_zero_fills`: numbers,
/// pointers, function values, aliases of them and plain structs of them), as
/// for a C declaration.  Any other type carries
/// `default_initializer_for_datype` explicitly: daslang refuses a bare `var`
/// of a record with field initializers — a storage-backed wrapper allocates
/// its bytes in one — and does not zero-fill an enumeration with no zero
/// member.
///
/// A `var` without an explicit type or with a reference type is left alone —
/// it could not be redeclared without its initializer — and so is a container
/// initializer, whose declaration-only spelling differs from its assignment
/// spelling (`typed_initializer_text` in `das_ast`).
///
/// Returns the index of the first body statement after the declarations.
fn hoist_site_temporaries(
    out: &mut Vec<DaStmt>,
    at: usize,
    zero_fills: &dyn Fn(&DaType) -> bool,
) -> usize {
    let mut declarations: Vec<DaStmt> = Vec::new();
    let body: Vec<DaStmt> = out.drain(at..).collect();
    let body = hoist_in_stmts(body, &mut declarations);
    for declaration in &mut declarations {
        if let DaStmt::Var { var_type, init, .. } = declaration {
            if zero_fills(var_type) {
                *init = None;
            }
        }
    }
    let body_start = at + declarations.len();
    out.extend(declarations);
    out.extend(body);
    body_start
}

fn hoist_in_stmts(stmts: Vec<DaStmt>, declarations: &mut Vec<DaStmt>) -> Vec<DaStmt> {
    let mut result: Vec<DaStmt> = Vec::with_capacity(stmts.len());
    for stmt in stmts {
        match stmt {
            DaStmt::Var {
                name,
                var_type,
                init,
            } if hoistable(&var_type, init.as_ref()) => {
                let mut declared = var_type.clone();
                declared.is_const = false;
                let default = crate::translator::default_initializer_for_datype(&declared);
                declarations.push(DaStmt::Var {
                    name: name.clone(),
                    var_type: declared,
                    init: Some(default),
                });
                if let Some(value) = init {
                    result.push(DaStmt::Expr(DaExpr::Assign(
                        Box::new(DaExpr::Var(name)),
                        Box::new(value),
                    )));
                }
            }
            DaStmt::Expr(expr) => result.push(DaStmt::Expr(hoist_in_expr(expr, declarations))),
            other => result.push(other),
        }
    }
    result
}

fn hoist_in_expr(expr: DaExpr, declarations: &mut Vec<DaStmt>) -> DaExpr {
    match expr {
        DaExpr::Block(block) => DaExpr::Block(DaBlock {
            stmts: hoist_in_stmts(block.stmts, declarations),
        }),
        DaExpr::IfThenElse {
            cond,
            then,
            elifs,
            else_,
        } => DaExpr::IfThenElse {
            cond,
            then: Box::new(hoist_in_expr(*then, declarations)),
            elifs: elifs
                .into_iter()
                .map(|(test, arm)| (test, hoist_in_expr(arm, declarations)))
                .collect(),
            else_: else_.map(|arm| Box::new(hoist_in_expr(*arm, declarations))),
        },
        DaExpr::While(cond, body) => {
            DaExpr::While(cond, Box::new(hoist_in_expr(*body, declarations)))
        }
        other => other,
    }
}

fn hoistable(var_type: &das_ast::DaType, init: Option<&DaExpr>) -> bool {
    if var_type.is_ref {
        return false;
    }
    if matches!(
        var_type.kind,
        DaTypeKind::Auto | DaTypeKind::Array(_) | DaTypeKind::FixedArray(_, _)
    ) {
        return false;
    }
    !matches!(
        init,
        Some(DaExpr::MakeArray(_)) | Some(DaExpr::MakeFixedArray { .. })
    )
}

/// Labels that no executable statement follows, and which daScript therefore
/// cannot jump to at run time.
///
/// A label compiles to no node of its own: `sv_collectExpressions`
/// (`ast_simulate.cpp`) merely records the index the *next* node will get, and
/// `SimNode_BlockWithLabels::eval` (`simulate.cpp`) rejects a jump whose
/// recorded index is not inside the block, reporting `jump to label N failed`.
/// So a label needs a node after it, and two foldings can take the last one
/// away: `ast_block_folding.cpp` deletes a bare `return` that closes a *void*
/// function's body ("remove trailing return on the void function"), and the
/// dead-code pass in the same file drops whatever follows a `return` up to the
/// next label.  `label N:` sitting at the very end of a void function above
/// nothing but `return` is exactly the shape a C function with an early
/// `if (!x) return;` lowers to, and it faults on the first such jump.
///
/// A label in that position can only mean "fall off the end of the function",
/// so the jumps to it are rewritten to `return` and the label is dropped.
fn dead_tail_labels(out: &[DaStmt]) -> Vec<String> {
    let mut live = out.len();
    if matches!(out.last(), Some(DaStmt::Expr(DaExpr::Return(None)))) {
        live -= 1;
    }
    let mut dangling: Vec<String> = Vec::new();
    for stmt in &out[..live] {
        match stmt {
            DaStmt::Expr(DaExpr::Label(name)) => dangling.push(name.clone()),
            // Anything else compiles to a node, so every label up to here has
            // one to land on.
            _ => dangling.clear(),
        }
    }
    dangling
}

/// Drop `label`'s definition and turn every jump to it into a bare `return`.
fn retarget_to_return(out: &mut Vec<DaStmt>, label: &str) {
    out.retain(|stmt| !matches!(stmt, DaStmt::Expr(DaExpr::Label(name)) if name == label));
    for stmt in out.iter_mut() {
        if let DaStmt::Expr(expr) = stmt {
            goto_to_return(expr, label);
        }
    }
}

/// Rewrite `goto label` to `return` inside the `if`/`else` nests that
/// [`render`] wraps conditional jumps in.
fn goto_to_return(expr: &mut DaExpr, label: &str) {
    match expr {
        DaExpr::Goto(name) if name == label => *expr = DaExpr::Return(None),
        DaExpr::Block(block) => {
            for stmt in &mut block.stmts {
                if let DaStmt::Expr(inner) = stmt {
                    goto_to_return(inner, label);
                }
            }
        }
        DaExpr::IfThenElse {
            then, elifs, else_, ..
        } => {
            goto_to_return(then, label);
            for (_, arm) in elifs.iter_mut() {
                goto_to_return(arm, label);
            }
            if let Some(arm) = else_ {
                goto_to_return(arm, label);
            }
        }
        _ => {}
    }
}

/// Move the arm of every early-exit `if` that daslang's if-return folding
/// would turn into a broken jump out of line, behind a label of its own.
///
/// daslang's `CondFolding` (`ast_block_folding.cpp`, `visit(ExprBlock*)`)
/// rewrites `if (c) { … return } rest` — an `if` without `else` whose arm is a
/// block ending in `return`, `break` or `continue` — into
/// `if (c) { … return } else { rest }`, labels included.  A label then
/// belongs to the new nested block: the interpreter simulates each block with
/// labels as one `SimNode_BlockWithLabels` whose label table covers only its
/// own statements (`sv_simulateLabels`, `ast_simulate.cpp`), and
/// `SimNode_BlockWithLabels::eval` (`simulate.cpp`) raises
/// `jump to label N failed` for a jump to a label outside it — a `goto` from
/// `rest` back to a label above the `if` (a loop head), or from above the
/// `if` forward into `rest` (when nothing above the `if` has a label, that
/// one leaves the function silently instead).  A block without labels
/// passes the jump on to its parent, so only a jump that crosses the `if`
/// with labels on the `rest` side fails.  The JIT, AOT and `-exe` compile the same folded tree
/// correctly, and `options optimize = false` (no folding) runs it correctly
/// in the interpreter too.  daslang issue: <placeholder>.
///
/// Such an arm (in practice the `if (c) { return }` that
/// [`retarget_to_return`] leaves, or a structured `if` arm the relooper kept)
/// becomes `if (c) { goto label X }`, which the folding leaves alone, and its
/// statements move, verbatim and after `label X:`, into a slot that nothing
/// falls into: right after a top-level `goto` or `return` and before the
/// label that follows it.  The arm still ends in its own `return`, so nothing
/// after it runs, and the slot is never the end of the body, so the closing
/// `return` a void function's folding deletes is never the arm's.  A body
/// with no such slot gets one at its top: `goto label R`, the arm, `label R:`.
/// Arms whose `if` no jump crosses are left as they are: `return` is one node
/// cheaper than `goto` plus `return` on the exit path.
///
/// An arm can only end in `break`/`continue` inside a loop body, where the
/// flat back end puts no labels; only `return` arms are moved.
fn move_crossed_early_exits(out: &mut Vec<DaStmt>, body_start: usize) {
    while let Some(index) = (body_start..out.len()).find(|&k| crossed_early_exit(out, k)) {
        let fresh = out
            .iter()
            .filter_map(|stmt| match stmt {
                DaStmt::Expr(DaExpr::Label(name)) => label_number(name),
                _ => None,
            })
            .max()
            .map_or(0, |max| max + 1);
        let arm_label = alias_text(fresh);
        let DaStmt::Expr(DaExpr::IfThenElse { then, .. }) = &mut out[index] else {
            unreachable!("crossed_early_exit only accepts an `if`");
        };
        let DaExpr::Block(arm) = std::mem::replace(
            then.as_mut(),
            DaExpr::Block(DaBlock {
                stmts: vec![DaStmt::Expr(DaExpr::Goto(arm_label.clone()))],
            }),
        ) else {
            unreachable!("crossed_early_exit only accepts a block arm");
        };
        let mut moved = vec![DaStmt::Expr(DaExpr::Label(arm_label))];
        moved.extend(arm.stmts);
        let slot = (index + 1..out.len())
            .chain(body_start + 1..index)
            .find(|&p| p > body_start && transfers(&out[p - 1]) && is_label(&out[p]));
        match slot {
            Some(p) => {
                out.splice(p..p, moved);
            }
            None => {
                let resume = alias_text(fresh + 1);
                let mut prologue = vec![DaStmt::Expr(DaExpr::Goto(resume.clone()))];
                prologue.extend(moved);
                prologue.push(DaStmt::Expr(DaExpr::Label(resume)));
                out.splice(body_start..body_start, prologue);
            }
        }
    }
}

/// Whether `out[k]` is an early-exit `if` (see [`move_crossed_early_exits`])
/// with a label after it and a jump across it.
fn crossed_early_exit(out: &[DaStmt], k: usize) -> bool {
    let DaStmt::Expr(DaExpr::IfThenElse {
        then,
        elifs,
        else_: None,
        ..
    }) = &out[k]
    else {
        return false;
    };
    let DaExpr::Block(arm) = then.as_ref() else {
        return false;
    };
    if !elifs.is_empty()
        || k + 1 == out.len()
        || !matches!(arm.stmts.last(), Some(DaStmt::Expr(DaExpr::Return(_))))
    {
        return false;
    }
    let labels = |stmts: &[DaStmt]| -> IndexSet<String> {
        stmts
            .iter()
            .filter_map(|stmt| match stmt {
                DaStmt::Expr(DaExpr::Label(name)) => Some(name.clone()),
                _ => None,
            })
            .collect()
    };
    let (above, below) = out.split_at(k + 1);
    let below_labels = labels(below);
    if below_labels.is_empty() {
        return false;
    }
    let above_labels = labels(above);
    let crosses = |from: &[DaStmt], to: &IndexSet<String>| -> bool {
        let mut jumps = JumpTargets::default();
        for stmt in from {
            jumps.stmt(stmt);
        }
        !to.is_empty() && (jumps.computed || jumps.named.iter().any(|name| to.contains(name)))
    };
    crosses(below, &above_labels) || crosses(above, &below_labels)
}

/// The labels the jumps of some statements name, and whether any of them
/// is a computed jump (which can reach any label).
#[derive(Default)]
struct JumpTargets {
    named: IndexSet<String>,
    computed: bool,
}

impl JumpTargets {
    fn stmt(&mut self, stmt: &DaStmt) {
        if let DaStmt::Expr(expr) = stmt {
            self.expr(expr);
        }
    }

    fn expr(&mut self, expr: &DaExpr) {
        match expr {
            DaExpr::Goto(name) => {
                self.named.insert(name.clone());
            }
            DaExpr::GotoComputed(_) => self.computed = true,
            DaExpr::Block(block) => block.stmts.iter().for_each(|stmt| self.stmt(stmt)),
            DaExpr::IfThenElse {
                then, elifs, else_, ..
            } => {
                self.expr(then);
                elifs.iter().for_each(|(_, arm)| self.expr(arm));
                if let Some(arm) = else_ {
                    self.expr(arm);
                }
            }
            DaExpr::While(_, body) => self.expr(body),
            DaExpr::For { body, .. } => self.expr(body),
            _ => {}
        }
    }
}

/// A top-level statement after which control never continues in sequence.
fn transfers(stmt: &DaStmt) -> bool {
    matches!(
        stmt,
        DaStmt::Expr(DaExpr::Goto(_) | DaExpr::GotoComputed(_) | DaExpr::Return(_))
    )
}

fn is_label(stmt: &DaStmt) -> bool {
    matches!(stmt, DaStmt::Expr(DaExpr::Label(_)))
}

/// The number of a `label N` name.
fn label_number(name: &str) -> Option<u64> {
    name.strip_prefix("label ")?.parse().ok()
}

/// Depth-first layout that keeps as many edges as possible implicit.
fn layout(cfg: &Cfg<Label, StmtOrDecl>) -> Vec<Label> {
    let mut order: Vec<Label> = Vec::with_capacity(cfg.nodes.len());
    let mut seen: IndexSet<Label> = IndexSet::new();
    let mut stack: Vec<Label> = vec![cfg.entries.clone()];
    while let Some(label) = stack.pop() {
        if seen.contains(&label) || !cfg.nodes.contains_key(&label) {
            continue;
        }
        seen.insert(label.clone());
        order.push(label.clone());
        // Pushed in reverse preference, so the preferred successor is popped —
        // and therefore laid out — first, and its edge needs no `goto`.
        for successor in preferred_successors(&cfg.nodes[&label].terminator)
            .into_iter()
            .rev()
        {
            if !seen.contains(&successor) {
                stack.push(successor);
            }
        }
    }
    order
}

/// Successors in the order we would most like to place them, best first.
fn preferred_successors(terminator: &GenTerminator<Label>) -> Vec<Label> {
    match terminator {
        End => vec![],
        Jump(target) => vec![target.clone()],
        // The `false` arm falls through, matching `if cond { goto then }`.
        Branch(_, then_target, else_target) => vec![else_target.clone(), then_target.clone()],
        Switch { cases, .. } => {
            // The last pair is the default arm (see `CfgBuilder`'s `Switch`
            // construction) and it is the only one that can fall through.
            let mut preferred: Vec<Label> = Vec::with_capacity(cases.len());
            if let Some((_, default)) = cases.last() {
                preferred.push(default.clone());
            }
            for (_, target) in cases.iter().take(cases.len().saturating_sub(1)) {
                preferred.push(target.clone());
            }
            preferred
        }
    }
}

/// Turn one terminator into the statements it still has to emit.
fn plan(terminator: &GenTerminator<Label>, next: Option<&Label>) -> TranslationResult<Tail> {
    match terminator {
        End => Ok(Tail::End),
        Jump(target) => Ok(if Some(target) == next {
            Tail::FallThrough
        } else {
            Tail::Goto(target.clone())
        }),
        // A constant condition (`while (1)`, `do … while (0)`, whose C
        // integer constant `convert_condition` gives as a `bool` constant)
        // always takes the same edge; testing it would print `if (true)`.
        Branch(DaExpr::ConstBool(taken), then_target, else_target) => {
            let target = if *taken { then_target } else { else_target };
            Ok(if Some(target) == next {
                Tail::FallThrough
            } else {
                Tail::Goto(target.clone())
            })
        }
        Branch(cond, then_target, else_target) => {
            let then_falls = Some(then_target) == next;
            let else_falls = Some(else_target) == next;
            Ok(match (then_falls, else_falls) {
                // Both arms continue at the same place: the condition was built
                // by `convert_condition`, whose side effects are already in this
                // block's statements, so nothing is lost by dropping the test.
                (true, true) => Tail::FallThrough,
                (_, true) => Tail::IfGoto(cond.clone(), then_target.clone()),
                (true, _) => Tail::IfGoto(negate(cond), else_target.clone()),
                (false, false) => {
                    Tail::IfElseGoto(cond.clone(), then_target.clone(), else_target.clone())
                }
            })
        }
        Switch { expr, cases } => {
            let Some((_, default_target)) = cases.last() else {
                return Ok(Tail::End);
            };
            let default = if Some(default_target) == next {
                None
            } else {
                Some(default_target.clone())
            };
            let mut keyed: Vec<KeyedCase> = Vec::with_capacity(cases.len() - 1);
            let mut dispatch_type: Option<DaType> = None;
            for (value, target) in cases.iter().take(cases.len() - 1) {
                let Some((key, ty)) = case_key(value) else {
                    return Err(TranslationError::generic(
                        "switch dispatch: a case value is not an integer constant \
                         of the promoted scrutinee type",
                    ));
                };
                if dispatch_type.get_or_insert_with(|| ty.clone()) != &ty {
                    return Err(TranslationError::generic(
                        "switch dispatch: case values of different types",
                    ));
                }
                keyed.push(KeyedCase {
                    key,
                    value: value.clone(),
                    target: target.clone(),
                });
            }
            keyed.sort_by_key(|case| case.key);
            if keyed.windows(2).any(|pair| pair[0].key == pair[1].key) {
                return Err(TranslationError::generic(
                    "switch dispatch: duplicate case value",
                ));
            }
            Ok(Tail::Dispatch {
                scrutinee: expr.clone(),
                tree: DispatchTree::build(&keyed, default_target),
                default,
            })
        }
    }
}

/// The statements of one dispatch subtree: each jumps to the arm of a
/// matching value; when none matches they jump to `default`, or fall out of
/// the tree when `default` is `None`.
fn dispatch_stmts(
    scrutinee: &DaExpr,
    tree: &DispatchTree,
    goto: &dyn Fn(&Label) -> DaStmt,
    default: Option<&Label>,
) -> Vec<DaStmt> {
    let goto_block = |label: &Label| -> DaExpr {
        DaExpr::Block(DaBlock {
            stmts: vec![goto(label)],
        })
    };
    match tree {
        DispatchTree::Tests(tests) => {
            let mut arms = tests.iter();
            let Some((first_value, first_target)) = arms.next() else {
                // A `switch` with no `case` labels at all: only the default
                // arm can ever run.
                return default.map(goto).into_iter().collect();
            };
            vec![DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(case_test(scrutinee, first_value)),
                then: Box::new(goto_block(first_target)),
                elifs: arms
                    .map(|(value, target)| (case_test(scrutinee, value), goto_block(target)))
                    .collect(),
                else_: default.map(|d| Box::new(goto_block(d))),
            })]
        }
        DispatchTree::Table {
            low,
            high,
            low_key,
            base,
            ..
        } => {
            let base = base.expect("jump tables are numbered before emission");
            let mut stmts = vec![DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(table_bounds_test(scrutinee, low, high, *low_key)),
                then: Box::new(DaExpr::Block(DaBlock {
                    stmts: vec![DaStmt::Expr(DaExpr::GotoComputed(Box::new(
                        table_label_number(scrutinee, low, *low_key, base),
                    )))],
                })),
                elifs: vec![],
                else_: None,
            })];
            stmts.extend(default.map(goto));
            stmts
        }
        DispatchTree::Split {
            pivot,
            below,
            above,
        } => {
            let arm = |tree: &DispatchTree| {
                DaExpr::Block(DaBlock {
                    stmts: dispatch_stmts(scrutinee, tree, goto, None),
                })
            };
            let mut stmts = vec![DaStmt::Expr(DaExpr::IfThenElse {
                cond: Box::new(DaExpr::Op2 {
                    op: "<",
                    left: Box::new(scrutinee.clone()),
                    right: Box::new(pivot.clone()),
                }),
                then: Box::new(arm(below)),
                elifs: vec![],
                else_: Some(Box::new(arm(above))),
            })];
            stmts.extend(default.map(goto));
            stmts
        }
    }
}

/// `low <= x && x <= high`; only `x <= high` when `low` is the smallest value
/// of an unsigned dispatch type.
fn table_bounds_test(scrutinee: &DaExpr, low: &DaExpr, high: &DaExpr, low_key: i128) -> DaExpr {
    let at_most_high = DaExpr::Op2 {
        op: "<=",
        left: Box::new(scrutinee.clone()),
        right: Box::new(high.clone()),
    };
    let unsigned = matches!(
        case_key(low).map(|(_, ty)| ty.kind),
        Some(DaTypeKind::UInt | DaTypeKind::UInt64)
    );
    if unsigned && low_key == 0 {
        return at_most_high;
    }
    DaExpr::Op2 {
        op: "&&",
        left: Box::new(DaExpr::Op2 {
            op: ">=",
            left: Box::new(scrutinee.clone()),
            right: Box::new(low.clone()),
        }),
        right: Box::new(at_most_high),
    }
}

/// The `int` label number `base + (x - low)` of the alias for the value `x`,
/// which the bounds test has already placed in `[low, high]`.
///
/// For an `int` dispatch the offset folds into one constant, `x + (base -
/// low)`, when that constant is an `int`; every other type (and an `int`
/// whose constant would not be one) subtracts `low` in its own type first —
/// that difference is below the table's length — and converts it.
fn table_label_number(scrutinee: &DaExpr, low: &DaExpr, low_key: i128, base: u64) -> DaExpr {
    let int_dispatch = matches!(case_key(low).map(|(_, ty)| ty.kind), Some(DaTypeKind::Int));
    let base = i128::from(base);
    let plus = |left: DaExpr, offset: i128| -> DaExpr {
        match offset.cmp(&0) {
            std::cmp::Ordering::Equal => left,
            std::cmp::Ordering::Greater => DaExpr::Op2 {
                op: "+",
                left: Box::new(left),
                right: Box::new(DaExpr::ConstInt(offset as i64)),
            },
            std::cmp::Ordering::Less => DaExpr::Op2 {
                op: "-",
                left: Box::new(left),
                right: Box::new(DaExpr::ConstInt((-offset) as i64)),
            },
        }
    };
    let offset = base - low_key;
    if int_dispatch && i32::try_from(offset).is_ok() {
        return plus(scrutinee.clone(), offset);
    }
    let from_low = if low_key == 0 {
        scrutinee.clone()
    } else {
        DaExpr::Op2 {
            op: "-",
            left: Box::new(scrutinee.clone()),
            right: Box::new(low.clone()),
        }
    };
    let index = if int_dispatch {
        from_low
    } else {
        DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(from_low),
            to: DaType::int(),
        }
    };
    plus(index, base)
}

fn case_test(scrutinee: &DaExpr, value: &DaExpr) -> DaExpr {
    DaExpr::Op2 {
        op: "==",
        left: Box::new(scrutinee.clone()),
        right: Box::new(value.clone()),
    }
}

fn negate(cond: &DaExpr) -> DaExpr {
    // `!(a == b)` is `a != b`; keeping the comparison flat reads better and
    // avoids a redundant parenthesised negation in the printed source.
    if let DaExpr::Op2 { op, left, right } = cond {
        if let Some(inverse) = inverse_comparison(op) {
            return DaExpr::Op2 {
                op: inverse,
                left: left.clone(),
                right: right.clone(),
            };
        }
    }
    if let DaExpr::Op1 { op: "!", expr } = cond {
        return (**expr).clone();
    }
    DaExpr::Op1 {
        op: "!",
        expr: Box::new(cond.clone()),
    }
}

fn inverse_comparison(op: &str) -> Option<&'static str> {
    match op {
        "==" => Some("!="),
        "!=" => Some("=="),
        "<" => Some(">="),
        "<=" => Some(">"),
        ">" => Some("<="),
        ">=" => Some("<"),
        _ => None,
    }
}

/// A hoisted declaration is assigned later, at the point where the C
/// declaration stood, so it cannot keep a `const` qualifier: `const int x = 42;`
/// becomes `var x : int` at the top of the function and `x = 42` in place.
fn writable_decl(stmt: DaStmt) -> DaStmt {
    match stmt {
        DaStmt::Var {
            name,
            mut var_type,
            init,
        } => {
            var_type.is_const = false;
            DaStmt::Var {
                name,
                var_type,
                init,
            }
        }
        other => other,
    }
}

fn label_text(label_ids: &IndexMap<Label, u64>, label: &Label) -> String {
    let id = label_ids
        .get(label)
        .expect("every jump target is numbered before emission");
    format!("label {id}")
}

/// The label of a number that no named jump uses: a jump-table alias or the
/// trampoline's resume point.
fn alias_text(id: u64) -> String {
    format!("label {id}")
}

#[cfg(test)]
mod tests {
    use super::*;

    fn stmt(expr: DaExpr) -> DaStmt {
        DaStmt::Expr(expr)
    }
    fn label(n: u64) -> DaStmt {
        stmt(DaExpr::Label(alias_text(n)))
    }
    fn goto(n: u64) -> DaStmt {
        stmt(DaExpr::Goto(alias_text(n)))
    }
    fn call(name: &str) -> DaStmt {
        stmt(DaExpr::Call(
            Box::new(DaExpr::Var(name.to_string())),
            vec![],
        ))
    }
    fn if_then(cond: &str, arm: Vec<DaStmt>) -> DaStmt {
        stmt(DaExpr::IfThenElse {
            cond: Box::new(DaExpr::Var(cond.to_string())),
            then: Box::new(DaExpr::Block(DaBlock { stmts: arm })),
            elifs: vec![],
            else_: None,
        })
    }
    fn ret() -> DaStmt {
        stmt(DaExpr::Return(None))
    }
    fn text(out: &[DaStmt]) -> String {
        out.iter()
            .map(|s| s.to_string())
            .collect::<Vec<_>>()
            .join("\n")
            .split_whitespace()
            .collect::<Vec<_>>()
            .join(" ")
    }

    #[test]
    fn an_exit_no_jump_crosses_stays_a_return() {
        // `R_DrawColumn`: nothing above the `if` is jumped to or jumps.
        let mut out = vec![
            call("setup"),
            if_then("empty", vec![ret()]),
            label(0),
            call("step"),
            if_then("more", vec![goto(0)]),
            ret(),
        ];
        let before = text(&out);
        move_crossed_early_exits(&mut out, 0);
        assert_eq!(text(&out), before);
    }

    #[test]
    fn a_backward_jump_across_an_exit_moves_the_exit_into_a_dead_slot() {
        // `Z_CheckHeap`: the loop head is above the exit, the back edge below.
        let mut out = vec![
            label(0),
            if_then("done", vec![call("finish"), ret()]),
            if_then("bad", vec![goto(2)]),
            label(1),
            call("step"),
            goto(0),
            label(2),
            call("report"),
            goto(1),
            ret(),
        ];
        move_crossed_early_exits(&mut out, 0);
        let expected = vec![
            label(0),
            if_then("done", vec![goto(3)]),
            if_then("bad", vec![goto(2)]),
            label(1),
            call("step"),
            goto(0),
            label(3),
            call("finish"),
            ret(),
            label(2),
            call("report"),
            goto(1),
            ret(),
        ];
        assert_eq!(text(&out), text(&expected));
    }

    #[test]
    fn a_forward_jump_across_an_exit_without_a_dead_slot_gets_one_on_top() {
        let mut out = vec![
            if_then("skip", vec![goto(0)]),
            if_then("done", vec![ret()]),
            call("prepare"),
            label(0),
            call("work"),
            ret(),
        ];
        move_crossed_early_exits(&mut out, 0);
        let expected = vec![
            goto(2),
            label(1),
            ret(),
            label(2),
            if_then("skip", vec![goto(0)]),
            if_then("done", vec![goto(1)]),
            call("prepare"),
            label(0),
            call("work"),
            ret(),
        ];
        assert_eq!(text(&out), text(&expected));
    }
}
