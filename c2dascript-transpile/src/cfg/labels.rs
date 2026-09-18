//! Flat `label`/`goto` back end: a CFG rendered as daScript statements.
//!
//! daslang has first-class numeric labels and jumps — `label 3:` marks a point in
//! a function body and `goto label 3` transfers control to it (daslang reference,
//! `language/statements.rst`, section "label and goto").  Jumps out of, into and
//! across `while` bodies and past local `var` declarations are all legal, which
//! makes this the one lowering that is *total*: every C control-flow graph,
//! reducible or not, has an exact rendering.
//!
//! Rendering has three steps:
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
//!    turned back into a plain `return`; see [`dead_tail_labels`].
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
use das_ast::{DaBlock, DaExpr, DaStmt, DaTypeKind};

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
    /// A `switch` dispatch: compare the scrutinee against each case value in
    /// turn, and take the default arm otherwise.  `default` is `None` when the
    /// default arm is the next block in layout order.
    Dispatch {
        scrutinee: DaExpr,
        cases: Vec<(DaExpr, Label)>,
        default: Option<Label>,
    },
}

impl Tail {
    /// Every label this tail jumps to, and therefore needs a `label N:` on.
    fn targets(&self) -> Vec<&Label> {
        match self {
            Tail::FallThrough | Tail::End => vec![],
            Tail::Goto(l) | Tail::IfGoto(_, l) => vec![l],
            Tail::IfElseGoto(_, t, f) => vec![t, f],
            Tail::Dispatch { cases, default, .. } => cases
                .iter()
                .map(|(_, l)| l)
                .chain(default.iter())
                .collect(),
        }
    }
}

/// Render a pruned, edge-validated CFG as a flat daScript statement list.
pub(crate) fn render(
    cfg: Cfg<Label, StmtOrDecl>,
    mut store: DeclStmtStore,
) -> TranslationResult<Vec<DaStmt>> {
    let order = layout(&cfg);

    // Every local declaration is split: the `var` is hoisted to the top of the
    // function with its default value, and only the C initializer stays where
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
        tails.push(plan(&block.terminator, next));
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

    let goto = |label: &Label| -> DaStmt {
        DaStmt::Expr(DaExpr::Goto(label_text(&label_ids, label)))
    };
    let goto_block = |label: &Label| -> DaExpr {
        DaExpr::Block(DaBlock {
            stmts: vec![goto(label)],
        })
    };

    let hoisted_len = hoisted.len();
    let mut out: Vec<DaStmt> = hoisted;
    for (index, label) in order.iter().enumerate() {
        if label_ids.contains_key(label) {
            out.push(DaStmt::Expr(DaExpr::Label(label_text(&label_ids, label))));
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
                cases,
                default,
            } => {
                let mut arms = cases.iter();
                let Some((first_value, first_target)) = arms.next() else {
                    // A `switch` with no `case` labels at all: only the default
                    // arm can ever run.
                    if let Some(default) = default {
                        out.push(goto(default));
                    }
                    continue;
                };
                let elifs = arms
                    .map(|(value, target)| (case_test(scrutinee, value), goto_block(target)))
                    .collect();
                out.push(DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(case_test(scrutinee, first_value)),
                    then: Box::new(goto_block(first_target)),
                    elifs,
                    else_: default.as_ref().map(|d| Box::new(goto_block(d))),
                }));
            }
        }
    }

    // The last laid-out block never falls through — its tail is either the end
    // of the function or an unconditional jump — but daScript checks statically
    // that a value-returning function ends on a `return` and cannot see that.
    // Close such a body with an explicitly unreachable trap.
    if !matches!(tails.last(), Some(Tail::End) | None) {
        out.push(DaStmt::Expr(unreachable_trap(
            "unreachable: fell out of a translated control-flow graph",
        )));
    }

    // Step 4: a body with jumps in it must also be valid C++ once daslang's AOT
    // has emitted it; see `hoist_site_temporaries`.
    if !label_ids.is_empty() {
        hoist_site_temporaries(&mut out, hoisted_len);
    }

    // Step 5: repair labels daScript would leave dangling at the end of the body.
    for label in dead_tail_labels(&out) {
        retarget_to_return(&mut out, &label);
    }

    Ok(out)
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
/// up a few scopes cannot capture or shadow anything.  The hoisted `var`
/// carries the type's default value — the same `default_initializer_for_datype`
/// the C declarations get — because daslang refuses an uninitialised `var` of
/// a record type outright.
///
/// A `var` without an explicit type or with a reference type is left alone —
/// it could not be redeclared without its initializer — and so is a container
/// initializer, whose declaration-only spelling differs from its assignment
/// spelling (`typed_initializer_text` in `das_ast`).
fn hoist_site_temporaries(out: &mut Vec<DaStmt>, at: usize) {
    let mut declarations: Vec<DaStmt> = Vec::new();
    let body: Vec<DaStmt> = out.drain(at..).collect();
    let body = hoist_in_stmts(body, &mut declarations);
    out.extend(declarations);
    out.extend(body);
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
fn plan(terminator: &GenTerminator<Label>, next: Option<&Label>) -> Tail {
    match terminator {
        End => Tail::End,
        Jump(target) => {
            if Some(target) == next {
                Tail::FallThrough
            } else {
                Tail::Goto(target.clone())
            }
        }
        Branch(cond, then_target, else_target) => {
            let then_falls = Some(then_target) == next;
            let else_falls = Some(else_target) == next;
            match (then_falls, else_falls) {
                // Both arms continue at the same place: the condition was built
                // by `convert_condition`, whose side effects are already in this
                // block's statements, so nothing is lost by dropping the test.
                (true, true) => Tail::FallThrough,
                (_, true) => Tail::IfGoto(cond.clone(), then_target.clone()),
                (true, _) => Tail::IfGoto(negate(cond), else_target.clone()),
                (false, false) => Tail::IfElseGoto(
                    cond.clone(),
                    then_target.clone(),
                    else_target.clone(),
                ),
            }
        }
        Switch { expr, cases } => {
            let Some((_, default)) = cases.last() else {
                return Tail::End;
            };
            let default = if Some(default) == next {
                None
            } else {
                Some(default.clone())
            };
            Tail::Dispatch {
                scrutinee: expr.clone(),
                cases: cases
                    .iter()
                    .take(cases.len() - 1)
                    .map(|(value, target)| (value.clone(), target.clone()))
                    .collect(),
                default,
            }
        }
    }
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
