//! Structured back end: C loops and branches as daslang `while`/`if`/`break`/
//! `continue`/`return`.
//!
//! The flat back end ([`super::labels`]) renders every edge of the CFG as a
//! `label`/`goto`, which is total but slow in daslang's interpreter: a taken
//! `goto` restarts the enclosing `SimNode_BlockWithLabels` through
//! `stopFlags`, so a loop pays a jump per iteration and a `break`/`continue`
//! a chain of them.  A C function body without `goto` is already structured,
//! so this back end walks its C statements directly instead of building a
//! CFG, and emits the daslang construct that nests the same way:
//!
//! * `if`/`else` → `if`/`else`; a constant condition keeps only its arm;
//! * `while (c)` → `while c { … }`; a condition that needs statements of its
//!   own becomes `while true { stmts; if !c { break }; … }`;
//! * `for (init; c; step)` → `init` then the `while`, with `step` as the last
//!   statements of the body.  A `continue` runs the step first (a fresh
//!   conversion of the same C expression — C evaluates it exactly there,
//!   C11 6.8.5.3) and then continues;
//! * `do … while (c)` → `while true { …; stmts; if !c { break } }`, its
//!   `continue` a fresh conversion of the condition followed by `continue`;
//!   `do … while (0)` with no `break`/`continue` is its body alone, with one
//!   it is `while true { …; break }` and its `continue` is that `break`;
//! * `break` → `break` in a loop; `return` → `return` anywhere;
//! * a counted loop — `do … while (count--)` with `count` unnamed in the
//!   body and dead after, `for (…; i < b; i++)` with `i` unwritten and `b`
//!   invariant — → `for (v in range(…))`, one fused interpreter node
//!   ([`Builder::counted_do_while`], [`Builder::counted_for`]; the rules
//!   are in the translator `ARCHITECTURE.md`, "Counted loops").
//!
//! # `switch`
//!
//! daslang has no `switch`.  A C `switch` of at most [`CHAIN_MAX`] case
//! values whose arms never fall into each other is an `if`/`elif`/`else`
//! chain with the arms inline ([`switch_chain`]): the scrutinee, evaluated
//! once into a hoisted temporary unless it is a plain read, is compared in
//! the promoted type against each arm's values (`x == 1 || x == 2`), and
//! `default`, wherever it stands, is the final `else`.  A `break` of the
//! switch at the end of an arm is dropped, one that ends a branch of an `if`
//! makes the statements after the `if` the other branch ([`lift_breaks`]); a
//! `continue` of the enclosing loop stays what it is, since the chain is no
//! loop.  Any other `switch` keeps the dispatch the flat back end uses
//! ([`super::labels::DispatchTree`]: equality tests, a median split or a
//! computed-`goto` jump table) and places its arms, in source order, as a
//! *label region* in the statement list that contains the `switch`: the
//! dispatch, then `label A:` before each arm, then `label END:`.  Fall-through
//! between arms is fall-through between statements, and a `break` of the
//! `switch` is `goto` END.  Labels inside a `while` body are legal; every jump
//! of a region stays inside the statement list that holds its labels, because
//! the interpreter gives each block with labels a label table of its own and
//! fails a jump to a label outside it (`SimNode_BlockWithLabels::eval`,
//! `src/simulate/simulate.cpp`).  A `break`/`continue` of the enclosing loop
//! and a `return` inside an arm are daslang's own, which leave the labelled
//! block as any statement does.
//!
//! Three daslang behaviours constrain a label region, and each is handled on
//! the intermediate tree before anything is printed:
//!
//! 1. **A label needs a node after it** (`dead_tail_labels` in the flat back
//!    end).  A label with nothing after it in its list — END of a `switch`
//!    that ends a block — is resolved by what falling off that list means:
//!    `continue` at the end of a loop body, `return` at the end of a void
//!    function (whose closing `return` daslang deletes).  Every jump to it
//!    becomes that statement; a jump-table entry to it lands on a
//!    trampoline (`label N: continue`) behind the dispatch.  At the end of an
//!    `if` arm that some statement follows, falling off has no statement of
//!    its own, so that one `if` is spliced into its parent list as
//!    `if !c { goto ELSE }; then…; goto JOIN; label ELSE: else…; label JOIN:`
//!    and the question moves one level up.
//! 2. **If-return folding** (lookibed/daScript#8, `move_crossed_early_exits`
//!    in the flat back end): an `if (c) { … return/break/continue }` that a
//!    jump of its list crosses, with labels below it, moves out of line
//!    behind a label of its own, into a slot that nothing falls into.
//! 3. **AOT** prints a `var` as an initialised C++ declaration, past which C++
//!    forbids a forward `goto` in the same scope, so the statement lowering's
//!    site temporaries at the top level of a list with labels are hoisted to
//!    the top of the function (C declarations always are; see below).
//!
//! A checker then re-verifies, on the final tree, that every jump lands in the
//! innermost labelled list around it, that no label is dangling and that no
//! early exit is crossed; a violation is an internal error, never a silent
//! approximation.
//!
//! # What stays flat
//!
//! [`fallback_reason`] decides on the C AST, before any conversion, because
//! converting has effects that must happen once (a function-scope `static` is
//! hoisted to module scope; `musttail` reports itself).  A body stays on the
//! flat back end when it contains a `goto` (its labels can form any graph,
//! irreducible ones included), a `case`/`default` label below the top level
//! of its `switch` body (Duff's device: the arms do not nest), statements
//! before the first `case` of a `switch`, or statements nested deeper than
//! [`MAX_NESTING`] (daslang's AOT prints each `elif` as a nested `else { if … }`
//! and clang stops at 256 brackets).
//!
//! # Declarations
//!
//! Every C local is hoisted to the top of the function exactly as in the flat
//! back end — its `var` (bare when daslang's zero-fill is its default value)
//! at the top, its C initializer as an assignment where the declaration
//! stood, so a loop body re-initialises it on every pass.  The function's
//! storage of a block-scope object is then one variable, as in the flat back
//! end, whose behaviour for address-taken locals this keeps.  Site
//! temporaries stay where the lowering put them unless rule 3 applies.

use super::labels::{self as flat, DispatchTree, Tail};
use super::*;
use crate::c_ast::iterators::{DFExpr, SomeId};
use das_ast::{DaBlock, DaExpr, DaStmt, DaType};
use std::collections::{HashMap, HashSet};

/// The deepest statement nesting the structured back end emits.  Each C `if`,
/// `else if`, loop and `switch` is one level; daslang's AOT adds a few
/// brackets of its own per level, and clang's default limit is 256.
const MAX_NESTING: usize = 64;

/// A label of the intermediate tree, numbered only when printed.
type Sym = u64;

/// What falling off the end of a statement list means.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Ctx {
    /// The body of a void function: `return`.
    TopVoid,
    /// The body of a function with a value: it ends on its own trap.
    TopValue,
    /// A `while` body: `continue`.
    LoopEnd,
    /// An `if` arm with statements after the `if`: no statement of its own.
    Unknown,
}

/// A statement that leaves a list for good, as a jump target.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
enum Exit {
    Continue,
    Return,
}

impl Exit {
    fn node(self) -> Node {
        match self {
            Exit::Continue => Node::Continue,
            Exit::Return => Node::Stmt(DaStmt::Expr(DaExpr::Return(None))),
        }
    }

    fn stmt(self) -> DaStmt {
        match self {
            Exit::Continue => DaStmt::Expr(DaExpr::Continue),
            Exit::Return => DaStmt::Expr(DaExpr::Return(None)),
        }
    }

    /// The pseudo-label a dispatch arm of this exit is planned with.
    fn label(self) -> Label {
        match self {
            Exit::Continue => Label::Synthetic(u64::MAX),
            Exit::Return => Label::Synthetic(u64::MAX - 1),
        }
    }

    fn of_label(label: &Label) -> Option<Exit> {
        match label {
            Label::Synthetic(u64::MAX) => Some(Exit::Continue),
            Label::Synthetic(id) if *id == u64::MAX - 1 => Some(Exit::Return),
            _ => None,
        }
    }
}

#[derive(Clone, Debug)]
enum Target {
    Label(Sym),
    Exit(Exit),
}

/// The intermediate tree: daslang's statement structure with symbolic labels.
#[derive(Clone, Debug)]
enum Node {
    Stmt(DaStmt),
    /// A C declaration's site: its initializer, once the declaration is hoisted.
    Decl(CDeclId),
    If {
        cond: DaExpr,
        then: Vec<Node>,
        else_: Vec<Node>,
    },
    /// `while cond { body }`; `None` is `while true`.
    Loop {
        cond: Option<DaExpr>,
        body: Vec<Node>,
    },
    /// `for var in source { body }`: a counted C loop (see `counted_loops`).
    For {
        var: String,
        source: DaExpr,
        body: Vec<Node>,
    },
    Break,
    Continue,
    Label(Sym),
    Goto(Sym),
    /// A `switch` dispatch; every arm transfers, so nothing falls out of it.
    Dispatch {
        scrutinee: DaExpr,
        cases: Vec<(DaExpr, Target)>,
        default: Target,
    },
}

// ===== Eligibility =====

/// Why a function body has to use the flat back end, or `None` when the
/// structured back end handles it exactly.  Decided on the C AST alone.
pub(crate) fn fallback_reason(tr: &Translation, stmts: &[CStmtId]) -> Option<&'static str> {
    // A jump inside a GNU statement expression never reaches either back
    // end: `convert_gnu_statement_expression` refuses it.
    let mut scan = Scan { tr, reason: None };
    for &sid in stmts {
        scan.stmt(sid, 0, false);
    }
    scan.reason
}

struct Scan<'a> {
    tr: &'a Translation<'a>,
    reason: Option<&'static str>,
}

impl Scan<'_> {
    fn fail(&mut self, reason: &'static str) {
        self.reason.get_or_insert(reason);
    }

    /// `case_ok`: this statement is a top-level statement of a `switch` body,
    /// where a `case`/`default` label opens an arm.
    fn stmt(&mut self, sid: CStmtId, depth: usize, case_ok: bool) {
        if self.reason.is_some() {
            return;
        }
        if depth > MAX_NESTING {
            return self.fail("statements nest too deeply");
        }
        match &self.tr.ast_context[sid].kind {
            CStmtKind::Goto(_) => self.fail("goto"),
            CStmtKind::Label(sub) => self.stmt(*sub, depth, false),
            CStmtKind::Case(_, sub, _) | CStmtKind::Default(sub) => {
                if !case_ok {
                    return self.fail("a case label below the top level of its switch");
                }
                self.stmt(*sub, depth, true)
            }
            CStmtKind::Compound(kids) => {
                for &kid in kids {
                    self.stmt(kid, depth, false);
                }
            }
            CStmtKind::If {
                true_variant,
                false_variant,
                ..
            } => {
                self.stmt(*true_variant, depth + 1, false);
                if let Some(fv) = false_variant {
                    self.stmt(*fv, depth + 1, false);
                }
            }
            CStmtKind::While { body, .. } | CStmtKind::DoWhile { body, .. } => {
                self.stmt(*body, depth + 1, false)
            }
            CStmtKind::ForLoop { init, body, .. } => {
                if let Some(init) = init {
                    self.stmt(*init, depth, false);
                }
                self.stmt(*body, depth + 1, false)
            }
            CStmtKind::Switch { body, .. } => {
                let kids = switch_children(self.tr, *body);
                if let Some(&first) = kids.first() {
                    if !is_case_label(self.tr, first) {
                        return self.fail("statements before the first case label of a switch");
                    }
                }
                for kid in kids {
                    self.stmt(kid, depth + 1, true);
                }
            }
            CStmtKind::Attributed { substatement, .. } => self.stmt(*substatement, depth, false),
            _ => {}
        }
    }
}

fn switch_children(tr: &Translation, body: CStmtId) -> Vec<CStmtId> {
    match &tr.ast_context[body].kind {
        CStmtKind::Compound(kids) => kids.clone(),
        _ => vec![body],
    }
}

fn is_case_label(tr: &Translation, sid: CStmtId) -> bool {
    matches!(
        tr.ast_context[sid].kind,
        CStmtKind::Case(..) | CStmtKind::Default(_)
    )
}

// ===== Building the tree =====

#[derive(Clone, Copy)]
enum Breakable {
    Loop,
    Switch(Sym),
}

/// How a `continue` of the innermost loop is spelled.
#[derive(Clone, Copy)]
enum LoopKind {
    While,
    /// A `for` loop and its step.
    For(Option<CExprId>),
    /// A `do`/`while` loop, its condition and the condition's constant value.
    DoWhile(CExprId, Option<bool>),
    /// A counted loop over a daslang range: the range steps the counter, so
    /// `continue` is daslang's own.
    Range,
}

struct Builder<'a> {
    tr: &'a Translation<'a>,
    ret_ty: Option<CQualTypeId>,
    /// The function body, the scope a counter's liveness is decided in.
    body: &'a [CStmtId],
    store: DeclStmtStore,
    /// Declarations for the top of the function (`switch` scrutinee temporaries).
    prelude: Vec<DaStmt>,
    next_sym: Sym,
    breaks: Vec<Breakable>,
    loops: Vec<LoopKind>,
    /// C locals a range loop's variable replaced: no hoisted `var` for them.
    suppressed: HashSet<CDeclId>,
    /// The steps of the pointer inductions of the loops being converted,
    /// by the expression statement (or `for` step operand) that holds each
    /// (see "Pointer inductions" below).
    steps: HashMap<CExprId, Vec<InductionStep>>,
}

fn ctx() -> ExprContext {
    ExprContext::default()
}

fn stmt_nodes(stmts: Vec<DaStmt>) -> impl Iterator<Item = Node> {
    stmts.into_iter().map(Node::Stmt)
}

/// `if !cond { break }`.
fn break_unless(cond: &DaExpr) -> Node {
    Node::If {
        cond: flat::negate(cond),
        then: vec![Node::Break],
        else_: vec![],
    }
}

impl Builder<'_> {
    fn fresh(&mut self) -> Sym {
        let sym = self.next_sym;
        self.next_sym += 1;
        sym
    }

    fn stmt(&mut self, sid: CStmtId, out: &mut Vec<Node>) -> TranslationResult<()> {
        let tr = self.tr;
        match &tr.ast_context[sid].kind {
            CStmtKind::Empty => Ok(()),

            CStmtKind::Expr(eid) => self.expr_stmt(*eid, out),

            CStmtKind::Return(expr) => {
                out.extend(stmt_nodes(convert_return(tr, *expr, self.ret_ty)?));
                Ok(())
            }

            CStmtKind::Compound(kids) => {
                for &kid in kids {
                    self.stmt(kid, out)?;
                }
                Ok(())
            }

            CStmtKind::Decls(decls) => {
                for &decl in decls {
                    let info = tr.convert_decl_stmt_info(ctx(), decl)?;
                    self.store.store.insert(decl, info);
                    out.push(Node::Decl(decl));
                }
                Ok(())
            }

            CStmtKind::If {
                scrutinee,
                true_variant,
                false_variant,
            } => {
                let cond = tr.convert_condition(ctx().used(), true, *scrutinee)?;
                out.extend(stmt_nodes(cond.stmts));
                let mut then = Vec::new();
                self.stmt(*true_variant, &mut then)?;
                let mut else_ = Vec::new();
                if let Some(fv) = false_variant {
                    self.stmt(*fv, &mut else_)?;
                }
                match cond.val {
                    DaExpr::ConstBool(true) => out.extend(then),
                    DaExpr::ConstBool(false) => out.extend(else_),
                    val if then.is_empty() && else_.is_empty() => {
                        out.extend(tr.discard_value_stmt(val).map(Node::Stmt))
                    }
                    val if then.is_empty() => out.push(Node::If {
                        cond: flat::negate(&val),
                        then: else_,
                        else_: vec![],
                    }),
                    val => out.push(Node::If {
                        cond: val,
                        then,
                        else_,
                    }),
                }
                Ok(())
            }

            CStmtKind::While { .. } | CStmtKind::ForLoop { .. } | CStmtKind::DoWhile { .. } => {
                let inductions = self.pointer_inductions(sid)?;
                self.enter_inductions(&inductions, out);
                let result = self.loop_stmt(sid, out);
                self.leave_inductions(&inductions, out);
                result
            }

            CStmtKind::Switch { scrutinee, body } => self.switch(*scrutinee, *body, out),

            CStmtKind::Break => {
                match self.breaks.last() {
                    Some(Breakable::Loop) => out.push(Node::Break),
                    Some(Breakable::Switch(end)) => out.push(Node::Goto(*end)),
                    None => return Err(TranslationError::generic("break outside loop or switch")),
                }
                Ok(())
            }

            CStmtKind::Continue => {
                match self.loops.last().copied() {
                    Some(LoopKind::While)
                    | Some(LoopKind::DoWhile(_, Some(true)))
                    | Some(LoopKind::Range) => out.push(Node::Continue),
                    Some(LoopKind::For(step)) => {
                        if let Some(step) = step {
                            self.expr_stmt(step, out)?;
                        }
                        out.push(Node::Continue);
                    }
                    // `continue` of `do … while (0)` tests the condition and
                    // leaves.
                    Some(LoopKind::DoWhile(_, Some(false))) => out.push(Node::Break),
                    Some(LoopKind::DoWhile(condition, None)) => {
                        let cond = tr.convert_condition(ctx().used(), true, condition)?;
                        out.extend(stmt_nodes(cond.stmts));
                        out.push(break_unless(&cond.val));
                        out.push(Node::Continue);
                    }
                    None => return Err(TranslationError::generic("continue outside loop")),
                }
                Ok(())
            }

            // With no `goto` in the body (see `fallback_reason`) a label is
            // never jumped to.
            CStmtKind::Label(sub) => self.stmt(*sub, out),

            CStmtKind::Attributed {
                attributes,
                substatement,
            } => {
                let substatement = attributed_substatement(tr, sid, attributes, *substatement)?;
                self.stmt(substatement, out)
            }

            CStmtKind::Asm {
                asm,
                inputs,
                outputs,
                clobbers,
                is_volatile,
            } => {
                tr.convert_inline_assembly(sid, asm, inputs, outputs, clobbers, *is_volatile)?;
                unreachable!(
                    "inline assembly lowering always diagnoses or returns a real statement"
                )
            }

            CStmtKind::Goto(_) | CStmtKind::Case(..) | CStmtKind::Default(_) => {
                Err(TranslationError::generic(
                    "structured control flow: a goto or a nested case label \
                     reached the structured back end",
                ))
            }

            _ => Err(TranslationError::generic(
                "unsupported statement in the structured back end",
            )),
        }
    }

    /// An expression statement, or one operand of a statement-position
    /// comma (`i++, p++` as a `for` step): the pointer induction steps it
    /// holds are emitted around it (see "Pointer inductions").
    fn expr_stmt(&mut self, eid: CExprId, out: &mut Vec<Node>) -> TranslationResult<()> {
        let tr = self.tr;
        if let CExprKind::Binary(_, CBinOp::Comma, lhs, rhs, _, _) = tr.ast_context[eid].kind {
            self.expr_stmt(lhs, out)?;
            return self.expr_stmt(rhs, out);
        }
        let steps = self.steps.get(&eid).cloned().unwrap_or_default();
        let whole = steps
            .iter()
            .any(|step| matches!(step.place, StepPlace::Whole));
        for step in &steps {
            if matches!(step.place, StepPlace::Before(_)) {
                out.push(step.node(tr));
            }
        }
        if !whole {
            let mut stmts = Vec::new();
            convert_expr_in_stmt_position(tr, ctx(), eid, &mut stmts)?;
            out.extend(stmt_nodes(stmts));
        }
        for step in &steps {
            if matches!(step.place, StepPlace::Whole | StepPlace::After(_)) {
                out.push(step.node(tr));
            }
        }
        Ok(())
    }

    /// A C loop, its pointer inductions already entered.
    fn loop_stmt(&mut self, sid: CStmtId, out: &mut Vec<Node>) -> TranslationResult<()> {
        let tr = self.tr;
        match &tr.ast_context[sid].kind {
            CStmtKind::While { condition, body } => {
                let cond = tr.convert_condition(ctx().used(), true, *condition)?;
                let mut nodes = Vec::new();
                let header = self.loop_header(cond, &mut nodes, out);
                self.loop_body(LoopKind::While, *body, &mut nodes)?;
                if let Some(header) = header {
                    out.push(Node::Loop {
                        cond: header,
                        body: nodes,
                    });
                }
                Ok(())
            }

            CStmtKind::ForLoop {
                init,
                condition,
                increment,
                body,
            } => {
                if let Some(counted) = self.counted_for(sid, *init, *condition, *increment, *body)
                {
                    return self.range_loop(counted, *body, out);
                }
                if let Some(init) = init {
                    self.stmt(*init, out)?;
                }
                let mut nodes = Vec::new();
                let header = match condition {
                    Some(cid) => {
                        let cond = tr.convert_condition(ctx().used(), true, *cid)?;
                        self.loop_header(cond, &mut nodes, out)
                    }
                    None => Some(None),
                };
                self.loop_body(LoopKind::For(*increment), *body, &mut nodes)?;
                if let Some(step) = increment {
                    self.expr_stmt(*step, &mut nodes)?;
                }
                if let Some(header) = header {
                    out.push(Node::Loop {
                        cond: header,
                        body: nodes,
                    });
                }
                Ok(())
            }

            CStmtKind::DoWhile { body, condition } => {
                if let Some(counted) = self.counted_do_while(sid, *condition, *body) {
                    return self.range_loop(counted, *body, out);
                }
                let cond = tr.convert_condition(ctx().used(), true, *condition)?;
                let constant = match (&cond.stmts[..], &cond.val) {
                    ([], DaExpr::ConstBool(value)) => Some(*value),
                    _ => None,
                };
                let mut nodes = Vec::new();
                self.loop_body(LoopKind::DoWhile(*condition, constant), *body, &mut nodes)?;
                match constant {
                    Some(false) if !leaves_loop(&nodes) => out.extend(nodes),
                    Some(false) => {
                        nodes.push(Node::Break);
                        out.push(Node::Loop {
                            cond: None,
                            body: nodes,
                        });
                    }
                    Some(true) => out.push(Node::Loop {
                        cond: None,
                        body: nodes,
                    }),
                    None => {
                        nodes.extend(stmt_nodes(cond.stmts));
                        nodes.push(break_unless(&cond.val));
                        out.push(Node::Loop {
                            cond: None,
                            body: nodes,
                        });
                    }
                }
                Ok(())
            }

            _ => Err(internal("a statement that is not a loop reached loop_stmt")),
        }
    }

    /// Place a loop condition: `Some(Some(c))` is `while c`, `Some(None)` is
    /// `while true` (its test, if it has statements, is the head of
    /// `nodes`), and `None` means the loop never runs (the condition's
    /// statements still do, once).
    fn loop_header(
        &mut self,
        cond: crate::with_stmts::WithStmts<DaExpr>,
        nodes: &mut Vec<Node>,
        out: &mut Vec<Node>,
    ) -> Option<Option<DaExpr>> {
        match (cond.stmts.is_empty(), cond.val) {
            (true, DaExpr::ConstBool(true)) => Some(None),
            (_, DaExpr::ConstBool(false)) => {
                out.extend(stmt_nodes(cond.stmts));
                None
            }
            (true, val) => Some(Some(val)),
            (false, val) => {
                nodes.extend(stmt_nodes(cond.stmts));
                nodes.push(break_unless(&val));
                Some(None)
            }
        }
    }

    fn loop_body(
        &mut self,
        kind: LoopKind,
        body: CStmtId,
        nodes: &mut Vec<Node>,
    ) -> TranslationResult<()> {
        self.breaks.push(Breakable::Loop);
        self.loops.push(kind);
        let result = self.stmt(body, nodes);
        self.loops.pop();
        self.breaks.pop();
        result
    }

    // ===== Counted loops (`counted_loops` in the module documentation) =====

    /// `do { body } while (count--);` with `count` an `int` local the body
    /// never names and that is dead after the loop.
    fn counted_do_while(
        &self,
        sid: CStmtId,
        condition: CExprId,
        body: CStmtId,
    ) -> Option<CountedLoop> {
        let tr = self.tr;
        let CExprKind::Unary(_, CUnOp::PostDecrement, arg, _) = tr.ast_context[peel(tr, condition)].kind
        else {
            return None;
        };
        let (count, CTypeKind::Int) = self.counter(arg)? else {
            return None;
        };
        if references(tr, SomeId::Stmt(body), count) || !self.dead_after(sid, count) {
            return None;
        }
        Some(CountedLoop::Count(count))
    }

    /// `for (init; i < b; i++) body` with `i` an `int`/`unsigned` local the
    /// body never writes, `b` invariant over the body, and `i` either named
    /// nowhere outside the loop or dead after it.
    fn counted_for(
        &self,
        sid: CStmtId,
        init: Option<CStmtId>,
        condition: Option<CExprId>,
        increment: Option<CExprId>,
        body: CStmtId,
    ) -> Option<CountedLoop> {
        let tr = self.tr;
        let step = peel(tr, increment?);
        let CExprKind::Unary(_, CUnOp::PreIncrement | CUnOp::PostIncrement, arg, _) =
            tr.ast_context[step].kind
        else {
            return None;
        };
        let (var, kind) = self.counter(arg)?;
        let CExprKind::Binary(_, CBinOp::Less, lhs, rhs, _, _) =
            tr.ast_context[peel(tr, condition?)].kind
        else {
            return None;
        };
        // The comparison is in `i`'s own type: nothing but the lvalue
        // conversion stands between `i` and `<` (`peel` keeps an
        // `IntegralCast`).
        let lhs = peel(tr, lhs);
        if !matches!(tr.ast_context[lhs].kind, CExprKind::DeclRef(_, d, _) if d == var) {
            return None;
        }
        if references(tr, SomeId::Expr(rhs), var)
            || !self.invariant(rhs, body)
            || writes(tr, SomeId::Stmt(body), var)
        {
            return None;
        }
        let init = match init {
            None => CountedInit::Current,
            Some(init) => match &tr.ast_context[init].kind {
                CStmtKind::Decls(decls) if decls.as_slice() == [var] => CountedInit::Decl(var),
                CStmtKind::Expr(eid) => {
                    let CExprKind::Binary(_, CBinOp::Assign, target, _, _, _) =
                        tr.ast_context[peel(tr, *eid)].kind
                    else {
                        return None;
                    };
                    if !matches!(tr.ast_context[peel(tr, target)].kind, CExprKind::DeclRef(_, d, _) if d == var)
                    {
                        return None;
                    }
                    CountedInit::Assign(*eid)
                }
                _ => return None,
            },
        };
        let in_loop = count_references(tr, SomeId::Stmt(sid), var);
        let in_body: usize = self
            .body
            .iter()
            .map(|&s| count_references(tr, SomeId::Stmt(s), var))
            .sum();
        let only_in_loop = in_loop == in_body;
        if !only_in_loop && !self.dead_after(sid, var) {
            return None;
        }
        Some(CountedLoop::Index {
            var,
            unsigned: kind == CTypeKind::UInt,
            init,
            end: rhs,
            only_in_loop,
        })
    }

    /// The `int`/`unsigned` block-scope local `place` names, when nothing
    /// but this function's own statements can reach it.
    fn counter(&self, place: CExprId) -> Option<(CDeclId, CTypeKind)> {
        let tr = self.tr;
        let CExprKind::DeclRef(_, decl, _) = tr.ast_context[peel(tr, place)].kind else {
            return None;
        };
        let CDeclKind::Variable {
            has_static_duration: false,
            has_thread_duration: false,
            typ,
            ..
        } = &tr.ast_context[decl].kind
        else {
            return None;
        };
        if typ.qualifiers.is_volatile || tr.local_address_is_taken(decl) {
            return None;
        }
        match &tr.ast_context.resolve_type(typ.ctype).kind {
            CTypeKind::Int => Some((decl, CTypeKind::Int)),
            CTypeKind::UInt => Some((decl, CTypeKind::UInt)),
            _ => None,
        }
    }

    /// Whether `expr` has the same value on every test of the loop: constants,
    /// enumeration constants, `sizeof`, and locals of this function that
    /// `body` does not write and nothing else can reach, under conversions
    /// and arithmetic.  A memory read, a global or a call is not shown.
    fn invariant(&self, expr: CExprId, body: CStmtId) -> bool {
        let tr = self.tr;
        match &tr.ast_context[expr].kind {
            CExprKind::Literal(..) | CExprKind::UnaryType(..) => true,
            CExprKind::Paren(_, inner)
            | CExprKind::ConstantExpr(_, inner, _)
            | CExprKind::ImplicitCast(_, inner, CastKind::IntegralCast | CastKind::NoOp | CastKind::LValueToRValue, _, _)
            | CExprKind::ExplicitCast(_, inner, CastKind::IntegralCast | CastKind::NoOp, _, _)
            | CExprKind::Unary(_, CUnOp::Plus | CUnOp::Negate | CUnOp::Complement | CUnOp::Extension, inner, _) => {
                self.invariant(*inner, body)
            }
            CExprKind::Binary(
                _,
                CBinOp::Multiply
                | CBinOp::Divide
                | CBinOp::Modulus
                | CBinOp::Add
                | CBinOp::Subtract
                | CBinOp::ShiftLeft
                | CBinOp::ShiftRight
                | CBinOp::BitAnd
                | CBinOp::BitXor
                | CBinOp::BitOr,
                lhs,
                rhs,
                _,
                _,
            ) => self.invariant(*lhs, body) && self.invariant(*rhs, body),
            CExprKind::DeclRef(_, decl, _) => match &tr.ast_context[*decl].kind {
                CDeclKind::EnumConstant { .. } => true,
                CDeclKind::Variable {
                    has_static_duration: false,
                    has_thread_duration: false,
                    typ,
                    ..
                } => {
                    !typ.qualifiers.is_volatile
                        && !tr.local_address_is_taken(*decl)
                        && !writes(tr, SomeId::Stmt(body), *decl)
                }
                _ => false,
            },
            _ => false,
        }
    }

    /// Whether `decl` is dead once the loop `target` exits: on every path
    /// from the loop's end, `decl` is assigned before it is read.  Decided by
    /// walking the function's statements in order with a kill rule (a plain
    /// `decl = e` kills); an enclosing loop's condition, step and body top are
    /// walked when the path falls off the body's end; a `break`/`continue`
    /// after the loop, or any other read, counts as live.
    fn dead_after(&self, target: CStmtId, decl: CDeclId) -> bool {
        matches!(
            self.after_list(self.body, target, decl),
            Flow::Dead | Flow::FellOff
        )
    }

    fn after_list(&self, stmts: &[CStmtId], target: CStmtId, decl: CDeclId) -> Flow {
        for (k, &s) in stmts.iter().enumerate() {
            match self.after_stmt(s, target, decl) {
                Flow::NotFound => continue,
                Flow::FellOff => return self.rest(&stmts[k + 1..], decl),
                flow => return flow,
            }
        }
        Flow::NotFound
    }

    fn after_stmt(&self, sid: CStmtId, target: CStmtId, decl: CDeclId) -> Flow {
        if sid == target {
            return Flow::FellOff;
        }
        let tr = self.tr;
        match &tr.ast_context[sid].kind {
            CStmtKind::Compound(kids) => self.after_list(kids, target, decl),
            CStmtKind::If {
                true_variant,
                false_variant,
                ..
            } => match self.after_stmt(*true_variant, target, decl) {
                Flow::NotFound => match false_variant {
                    Some(fv) => self.after_stmt(*fv, target, decl),
                    None => Flow::NotFound,
                },
                flow => flow,
            },
            CStmtKind::While { condition, body } | CStmtKind::DoWhile { condition, body } => {
                match self.after_stmt(*body, target, decl) {
                    Flow::FellOff => {
                        if references(tr, SomeId::Expr(*condition), decl) {
                            Flow::Live
                        } else {
                            self.loop_head(*body, decl)
                        }
                    }
                    flow => flow,
                }
            }
            CStmtKind::ForLoop {
                condition,
                increment,
                body,
                ..
            } => match self.after_stmt(*body, target, decl) {
                Flow::FellOff => {
                    let reads = |e: &Option<CExprId>| {
                        e.map_or(false, |e| references(tr, SomeId::Expr(e), decl))
                    };
                    if reads(increment) || reads(condition) {
                        Flow::Live
                    } else {
                        self.loop_head(*body, decl)
                    }
                }
                flow => flow,
            },
            CStmtKind::Switch { body, .. } => self.after_stmt(*body, target, decl),
            CStmtKind::Label(sub) | CStmtKind::Case(_, sub, _) | CStmtKind::Default(sub) => {
                self.after_stmt(*sub, target, decl)
            }
            CStmtKind::Attributed { substatement, .. } => {
                self.after_stmt(*substatement, target, decl)
            }
            _ => Flow::NotFound,
        }
    }

    /// Coming back around an enclosing loop: its body from the top.
    fn loop_head(&self, body: CStmtId, decl: CDeclId) -> Flow {
        match self.rest(&[body], decl) {
            Flow::Dead => Flow::Dead,
            _ => Flow::Live,
        }
    }

    /// The statements a path runs after the loop, in order.
    fn rest(&self, stmts: &[CStmtId], decl: CDeclId) -> Flow {
        let tr = self.tr;
        for &s in stmts {
            match &tr.ast_context[s].kind {
                CStmtKind::Compound(kids) => match self.rest(kids, decl) {
                    Flow::FellOff => continue,
                    flow => return flow,
                },
                CStmtKind::Expr(eid) if kills(tr, *eid, decl) => return Flow::Dead,
                CStmtKind::Return(_) => {
                    return if references(tr, SomeId::Stmt(s), decl) {
                        Flow::Live
                    } else {
                        Flow::Dead
                    }
                }
                _ => {
                    if references(tr, SomeId::Stmt(s), decl) || escapes(tr, s) {
                        return Flow::Live;
                    }
                }
            }
        }
        Flow::FellOff
    }

    /// Emit a counted loop as daslang's `for` over a range.
    fn range_loop(
        &mut self,
        counted: CountedLoop,
        body: CStmtId,
        out: &mut Vec<Node>,
    ) -> TranslationResult<()> {
        let tr = self.tr;
        let (var, source, rebound) = match counted {
            // `count + 1` passes of the body for `count >= 0`, and by the
            // two's-complement wrap the fallback loop performs as well,
            // `2^32 + count + 1` for `count < 0`: `uint64(uint(count)) + 1`
            // is that number in both cases, with no overflow at `INT_MAX`.
            CountedLoop::Count(count) => {
                let name = tr.renamer.borrow_mut().pick_name("c2da_iter");
                let count = DaExpr::Var(
                    tr.renamer
                        .borrow()
                        .get(&count)
                        .ok_or_else(|| internal("an unnamed loop counter"))?,
                );
                let u64_of = |e: DaExpr| DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(e),
                    to: DaType::uint64(),
                };
                let passes = DaExpr::Op2 {
                    op: "+",
                    left: Box::new(u64_of(DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(count),
                        to: DaType::uint(),
                    })),
                    right: Box::new(u64_of(DaExpr::ConstInt(1))),
                };
                let source = DaExpr::Call(
                    Box::new(DaExpr::Var("urange64".into())),
                    vec![u64_of(DaExpr::ConstInt(0)), passes],
                );
                (name, source, None)
            }
            CountedLoop::Index {
                var,
                unsigned,
                init,
                end,
                only_in_loop,
            } => {
                // The start: the initializer's value when the C variable is
                // replaced by the loop variable, else the variable after its
                // initialization, as today.
                let mut start: Option<DaExpr> = None;
                match init {
                    CountedInit::Current => {}
                    CountedInit::Decl(decl) => {
                        let info = tr.convert_decl_stmt_info(ctx(), decl)?;
                        if only_in_loop {
                            start = single_assignment(info.assign.as_deref());
                        }
                        if start.is_none() {
                            self.store.store.insert(decl, info);
                            out.push(Node::Decl(decl));
                        }
                    }
                    CountedInit::Assign(eid) => {
                        let mut stmts = Vec::new();
                        convert_expr_in_stmt_position(tr, ctx(), eid, &mut stmts)?;
                        // The variable's own declaration is dropped with
                        // it, so it must carry no initializer to evaluate.
                        let declared_bare = matches!(
                            tr.ast_context[var].kind,
                            CDeclKind::Variable {
                                initializer: None,
                                ..
                            }
                        );
                        if only_in_loop && declared_bare {
                            start = single_assignment(Some(&stmts));
                        }
                        if start.is_none() {
                            out.extend(stmt_nodes(stmts));
                        }
                    }
                }
                let c_name = tr
                    .renamer
                    .borrow()
                    .get(&var)
                    .ok_or_else(|| internal("an unnamed loop variable"))?;
                let (name, start, rebound) = match start {
                    Some(start) => {
                        self.suppressed.insert(var);
                        (c_name, start, None)
                    }
                    None => {
                        let name = tr
                            .renamer
                            .borrow_mut()
                            .pick_name(&format!("c2da_{c_name}"));
                        let former = tr.renamer.borrow_mut().rebind(var, name.clone());
                        (name, DaExpr::Var(c_name), Some((var, former)))
                    }
                };
                let end = tr.convert_expr(ctx().used(), end, None)?;
                if !end.stmts.is_empty() {
                    return Err(internal("a loop bound with statements was taken as invariant"));
                }
                let (range, args) = match (unsigned, &start) {
                    (false, DaExpr::ConstInt(0)) => ("range", vec![end.val]),
                    (false, _) => ("range", vec![start, end.val]),
                    (true, _) => ("urange", vec![start, end.val]),
                };
                let source = DaExpr::Call(Box::new(DaExpr::Var(range.into())), args);
                (name, source, rebound)
            }
        };
        let mut nodes = Vec::new();
        let result = self.loop_body(LoopKind::Range, body, &mut nodes);
        if let Some((decl, former)) = rebound {
            let mut renamer = tr.renamer.borrow_mut();
            match former {
                Some(former) => {
                    renamer.rebind(decl, former);
                }
                None => unreachable!("a loop variable had a name before it was rebound"),
            }
        }
        result?;
        out.push(Node::For {
            var,
            source,
            body: nodes,
        });
        Ok(())
    }

    fn switch(
        &mut self,
        scrutinee: CExprId,
        body: CStmtId,
        out: &mut Vec<Node>,
    ) -> TranslationResult<()> {
        let tr = self.tr;
        let SwitchScrutinee {
            stmts,
            value,
            temporary,
            case_ty,
        } = convert_switch_scrutinee(tr, ctx(), scrutinee)?;
        out.extend(stmt_nodes(stmts));
        self.prelude.extend(temporary);
        let end = self.fresh();
        // Each arm: its label and its statements, up to the next arm.
        let mut arms: Vec<(Sym, Vec<Node>)> = Vec::new();
        let mut cases: Vec<(DaExpr, Target)> = Vec::new();
        let mut default: Option<Sym> = None;
        self.breaks.push(Breakable::Switch(end));
        let mut result = Ok(());
        for kid in switch_children(tr, body) {
            // `case 1: case 2: default: stmt` is one arm with three entries.
            let mut sid = kid;
            let mut arm: Option<Sym> = None;
            loop {
                match &tr.ast_context[sid].kind {
                    CStmtKind::Case(_, sub, cst) => {
                        let label = match arm {
                            Some(label) => label,
                            None => *arm.insert(self.fresh()),
                        };
                        cases.push((case_value(cst, &case_ty), Target::Label(label)));
                        sid = *sub;
                    }
                    CStmtKind::Default(sub) => {
                        let label = match arm {
                            Some(label) => label,
                            None => *arm.insert(self.fresh()),
                        };
                        if default.replace(label).is_some() {
                            result = Err(TranslationError::generic(
                                "switch has more than one default label",
                            ));
                        }
                        sid = *sub;
                    }
                    _ => break,
                }
            }
            if let Some(label) = arm {
                arms.push((label, Vec::new()));
            }
            // `fallback_reason` admits a `switch` only when its body opens
            // with a `case`/`default` label, so there is always an arm here.
            let Some((_, nodes)) = arms.last_mut() else {
                result = Err(internal("a switch statement before its first arm"));
                break;
            };
            if result.is_ok() {
                result = self.stmt(sid, nodes);
            }
            if result.is_err() {
                break;
            }
        }
        self.breaks.pop();
        result?;
        let function = tr.function_context.borrow().get_name().to_owned();
        match switch_chain(&value, &cases, default, &arms, end) {
            Ok(chain) => {
                diag!(
                    Diagnostic::ControlFlow,
                    "`{function}`: switch as an inline chain"
                );
                out.extend(chain);
                return Ok(());
            }
            Err(reason) => diag!(
                Diagnostic::ControlFlow,
                "`{function}`: switch as a label region ({reason})"
            ),
        }
        out.push(Node::Dispatch {
            scrutinee: value,
            cases,
            default: Target::Label(default.unwrap_or(end)),
        });
        for (label, nodes) in arms {
            out.push(Node::Label(label));
            out.extend(nodes);
        }
        out.push(Node::Label(end));
        Ok(())
    }
}

// ===== Pointer inductions =====
//
// A pointer local a loop steps by compile-time constants (`p += C`, `p++`,
// `*p++ = v`) and otherwise only reads through (`*p`, `p[i]`, `p->f`) is
// mirrored in a `uint64` address for the loop: `var p_addr = reinterpret<
// uint64>(p)` before it, every read of `p` inside `reinterpret<T?>(p_addr)`,
// each step `p_addr += C * sizeof(T)`, and `p = reinterpret<T?>(p_addr)`
// after the loop when `p` is read again.  The interpreter runs daslang's
// pointer `+=` as an `i_das_ptr_set_add` call node with three operands; the
// address form is one fused `SetAddLocConst<uint64>`, and a dereference of
// the mirror is `Ptr2Ref(GetLocalR2V<uint64>)`, the same two nodes as of the
// pointer itself.  Measured (2026-10-08, Doom's column loop shape, 20 M
// pixels, per-process runs): 18.3–18.7 ns per pixel today, 15.9 with the
// address, 16.3–16.9 with an `int` index over the base pointer
// (`base[k]`, `k += 320`), 20.7 for `p = p + 320`; the span loop (stride 1)
// 25.6 → 23.8.  C's pointer arithmetic on an object pointer is the byte
// arithmetic (C11 6.5.6p8), scaled by Clang's size of the pointee from
// `layout.rs`, and the mirror is stepped in place wherever `p` would be, so
// a `break`, a `continue` or an early `return` see the address `p` would
// hold; a negative step subtracts.
//
// Decided on the C AST: `p` a block-scope local (not static, not thread,
// not `volatile`, address never taken) of pointer type to a complete
// scalar or record type, named before the loop (a `for`-init declaration
// is not); every reference to `p` in the loop statement — init, condition,
// step and body — is one of: the operand of `*`, the base of `[]` or `->`,
// a step.  A step is an expression statement at the body's top level or an
// operand of the `for` step (through commas): `p++`/`p--`/`++p`/`--p`,
// `p += C`/`p -= C` with `C` an integer literal (negated, cast); or `*p++`
// / `*++p` (and `--`) anywhere in such a statement whose only reference to
// `p` that is, emitted as the statement with `p++` read as `p` and the step
// after it (before it for the prefix forms).  A step under an `if` or a
// nested loop, a comparison of `p`, `p` passed to a call, assigned, read as
// a value or stepped by a variable keeps today's form.  `p` is stored back
// after the loop when it is named outside the loop and not dead after it
// (`dead_after`).  A nested loop stepping `p` at its own top level is that
// loop's induction, the outer loop keeping `p` as it is.

/// A pointer local one loop mirrors in a `uint64` address.
struct PointerInduction {
    decl: CDeclId,
    /// The C local's daslang name.
    name: String,
    /// The mirror's name.
    addr: String,
    /// The pointer's daslang type: what the mirror is read back as.
    pointer_type: DaType,
    /// `p` may be read after the loop: the mirror is stored back to it.
    live_after: bool,
    /// Each step, keyed by the expression statement (or `for` step operand)
    /// that holds it.
    steps: Vec<(CExprId, InductionStep)>,
}

#[derive(Clone)]
struct InductionStep {
    addr: String,
    /// The byte offset, `C * sizeof(T)`.
    bytes: i64,
    place: StepPlace,
}

#[derive(Clone, Copy)]
enum StepPlace {
    /// The statement is the step (`p += C`): nothing else is emitted.
    Whole,
    /// `*p++ …`: the statement with this `p++` read as `p`, then the step.
    After(CExprId),
    /// `*++p …`: the step, then the statement with `++p` read as `p`.
    Before(CExprId),
}

impl InductionStep {
    fn node(&self, tr: &Translation) -> Node {
        let (op, bytes) = if self.bytes < 0 {
            ("-=", self.bytes.unsigned_abs())
        } else {
            ("+=", self.bytes as u64)
        };
        Node::Stmt(DaStmt::Expr(DaExpr::AssignOp {
            op,
            left: Box::new(DaExpr::Var(self.addr.clone())),
            right: Box::new(
                tr.integer_literal_for_type(DaExpr::ConstInt(bytes as i64), DaType::uint64()),
            ),
        }))
    }
}

/// The operands of a statement-position comma, in order, as
/// `convert_expr_in_stmt_position` flattens them.
fn comma_operands(tr: &Translation, eid: CExprId, out: &mut Vec<CExprId>) {
    if let CExprKind::Binary(_, CBinOp::Comma, lhs, rhs, _, _) = tr.ast_context[eid].kind {
        comma_operands(tr, lhs, out);
        comma_operands(tr, rhs, out);
    } else {
        out.push(eid);
    }
}

/// An integer literal, negated or cast.
fn integer_constant(tr: &Translation, eid: CExprId) -> Option<i64> {
    match &tr.ast_context[peel(tr, eid)].kind {
        CExprKind::Literal(_, CLiteral::Integer(value, _)) => i64::try_from(*value).ok(),
        CExprKind::ConstantExpr(_, inner, _)
        | CExprKind::ImplicitCast(_, inner, CastKind::IntegralCast, _, _)
        | CExprKind::ExplicitCast(_, inner, CastKind::IntegralCast | CastKind::NoOp, _, _) => {
            integer_constant(tr, *inner)
        }
        CExprKind::Unary(_, CUnOp::Negate, inner, _) => {
            integer_constant(tr, *inner).and_then(i64::checked_neg)
        }
        _ => None,
    }
}

fn step_sign(op: CUnOp) -> Option<i64> {
    match op {
        CUnOp::PreIncrement | CUnOp::PostIncrement => Some(1),
        CUnOp::PreDecrement | CUnOp::PostDecrement => Some(-1),
        _ => None,
    }
}

impl Builder<'_> {
    /// The pointer local `place` names when it can be mirrored: a
    /// block-scope local nothing but this function's statements can reach,
    /// of pointer type to a complete scalar or record type.  With the
    /// pointee's Clang size.
    fn induction_pointer(&self, place: CExprId) -> Option<(CDeclId, i64)> {
        let tr = self.tr;
        let CExprKind::DeclRef(_, decl, _) = tr.ast_context[peel(tr, place)].kind else {
            return None;
        };
        let CDeclKind::Variable {
            has_static_duration: false,
            has_thread_duration: false,
            typ,
            ..
        } = &tr.ast_context[decl].kind
        else {
            return None;
        };
        if typ.qualifiers.is_volatile || tr.local_address_is_taken(decl) {
            return None;
        }
        let CTypeKind::Pointer(pointee) = tr.ast_context.resolve_type(typ.ctype).kind else {
            return None;
        };
        let pointee_kind = &tr.ast_context.resolve_type(pointee.ctype).kind;
        if !(pointee_kind.is_scalar()
            || matches!(pointee_kind, CTypeKind::Struct(_) | CTypeKind::Union(_)))
        {
            return None;
        }
        let size = tr.sizeof_type(pointee.ctype).ok()?;
        (size > 0).then_some((decl, size))
    }

    /// The steps one expression statement (or `for` step operand) holds:
    /// the pointer, the step in elements, and where the step goes.
    fn induction_steps(&self, eid: CExprId) -> Vec<(CDeclId, i64, i64, StepPlace)> {
        let tr = self.tr;
        let top = peel(tr, eid);
        match tr.ast_context[top].kind {
            CExprKind::Unary(_, op, arg, _) if step_sign(op).is_some() => {
                return self
                    .induction_pointer(arg)
                    .map(|(decl, size)| (decl, step_sign(op).unwrap(), size, StepPlace::Whole))
                    .into_iter()
                    .collect();
            }
            CExprKind::Binary(_, op @ (CBinOp::AssignAdd | CBinOp::AssignSubtract), lhs, rhs, _, _) => {
                let Some((decl, size)) = self.induction_pointer(lhs) else {
                    return vec![];
                };
                let Some(count) = integer_constant(tr, rhs) else {
                    return vec![];
                };
                let count = if op == CBinOp::AssignSubtract {
                    match count.checked_neg() {
                        Some(count) => count,
                        None => return vec![],
                    }
                } else {
                    count
                };
                return vec![(decl, count, size, StepPlace::Whole)];
            }
            _ => {}
        }
        // `*p++` inside the statement: the one reference to `p` it holds.
        // The walk can reach one node twice (`(u8)(*p++)`), so each `p++`
        // is taken once.
        let mut steps = Vec::new();
        let mut seen: HashSet<CExprId> = HashSet::new();
        for node in DFExpr::new(&tr.ast_context, SomeId::Expr(eid)) {
            let SomeId::Expr(x) = node else {
                // A statement inside the expression is a statement expression.
                return vec![];
            };
            let CExprKind::Unary(_, CUnOp::Deref, inner, _) = tr.ast_context[x].kind else {
                continue;
            };
            let inner = peel(tr, inner);
            if !seen.insert(inner) {
                continue;
            }
            let CExprKind::Unary(_, op, arg, _) = tr.ast_context[inner].kind else {
                continue;
            };
            let Some(sign) = step_sign(op) else { continue };
            let Some((decl, size)) = self.induction_pointer(arg) else {
                continue;
            };
            if count_references(tr, SomeId::Expr(eid), decl) != 1 {
                continue;
            }
            let place = match op {
                CUnOp::PostIncrement | CUnOp::PostDecrement => StepPlace::After(inner),
                _ => StepPlace::Before(inner),
            };
            steps.push((decl, sign, size, place));
        }
        steps
    }

    /// The pointer inductions of the loop `sid` (see "Pointer inductions").
    fn pointer_inductions(&self, sid: CStmtId) -> TranslationResult<Vec<PointerInduction>> {
        let tr = self.tr;
        let (body, increment) = match &tr.ast_context[sid].kind {
            CStmtKind::While { body, .. } | CStmtKind::DoWhile { body, .. } => (*body, None),
            CStmtKind::ForLoop {
                body, increment, ..
            } => (*body, *increment),
            _ => return Ok(vec![]),
        };
        // The statements whose steps count: the body's top level, through
        // commas, and the `for` step.
        let mut top: Vec<CExprId> = Vec::new();
        let kids: Vec<CStmtId> = match &tr.ast_context[body].kind {
            CStmtKind::Compound(kids) => kids.clone(),
            _ => vec![body],
        };
        for kid in kids {
            if let CStmtKind::Expr(eid) = tr.ast_context[kid].kind {
                comma_operands(tr, eid, &mut top);
            }
        }
        if let Some(increment) = increment {
            comma_operands(tr, increment, &mut top);
        }
        let mut candidates: IndexMap<CDeclId, (i64, Vec<(CExprId, i64, StepPlace)>)> =
            IndexMap::new();
        for &eid in &top {
            for (decl, count, size, place) in self.induction_steps(eid) {
                candidates
                    .entry(decl)
                    .or_insert_with(|| (size, Vec::new()))
                    .1
                    .push((eid, count, place));
            }
        }
        let mut inductions = Vec::new();
        for (decl, (size, steps)) in candidates {
            // Every reference to `p` in the loop statement is a read through
            // it or one of the steps found above.
            let step_ids: HashSet<CExprId> = steps
                .iter()
                .map(|(eid, _, place)| match place {
                    StepPlace::Whole => peel(tr, *eid),
                    StepPlace::After(inner) | StepPlace::Before(inner) => *inner,
                })
                .collect();
            let names = |place: CExprId| {
                matches!(tr.ast_context[peel(tr, place)].kind, CExprKind::DeclRef(_, d, _) if d == decl)
            };
            let allowed = DFExpr::new(&tr.ast_context, SomeId::Stmt(sid))
                .filter(|node| {
                    let SomeId::Expr(x) = node else { return false };
                    if step_ids.contains(x) {
                        return true;
                    }
                    match tr.ast_context[*x].kind {
                        CExprKind::Unary(_, CUnOp::Deref, inner, _) => names(inner),
                        CExprKind::ArraySubscript(_, base, _, _) => names(base),
                        CExprKind::Member(_, base, _, MemberKind::Arrow, _) => names(base),
                        _ => false,
                    }
                })
                .count();
            let in_loop = count_references(tr, SomeId::Stmt(sid), decl);
            if allowed != in_loop {
                continue;
            }
            let Some(name) = tr.renamer.borrow().get(&decl) else {
                continue;
            };
            let CDeclKind::Variable { typ, .. } = &tr.ast_context[decl].kind else {
                continue;
            };
            let pointer_type = tr.convert_type(*typ)?;
            let mut byte_steps = Vec::new();
            let mut fits = true;
            for (eid, count, place) in steps {
                match count.checked_mul(size) {
                    Some(bytes) => byte_steps.push((eid, bytes, place)),
                    None => fits = false,
                }
            }
            if !fits {
                continue;
            }
            // Stored back unless every path from the loop's exit assigns
            // `p` before reading it.  A pointer named nowhere else in the
            // function is still read on an enclosing loop's next pass, by
            // this loop's own mirror (`dead_after` walks that back edge).
            let live_after = !self.dead_after(sid, decl);
            let addr = tr
                .renamer
                .borrow_mut()
                .pick_name(&format!("c2da_{name}_addr"));
            inductions.push(PointerInduction {
                decl,
                name,
                steps: byte_steps
                    .into_iter()
                    .map(|(eid, bytes, place)| {
                        (
                            eid,
                            InductionStep {
                                addr: addr.clone(),
                                bytes,
                                place,
                            },
                        )
                    })
                    .collect(),
                addr,
                pointer_type,
                live_after,
            });
        }
        Ok(inductions)
    }

    /// Declare each mirror from the pointer's value and route the loop's
    /// reads of the pointer through it.
    fn enter_inductions(&mut self, inductions: &[PointerInduction], out: &mut Vec<Node>) {
        let tr = self.tr;
        for induction in inductions {
            out.push(Node::Stmt(DaStmt::Var {
                name: induction.addr.clone(),
                var_type: DaType::uint64(),
                init: Some(tr.pointer_to_raw_address(DaExpr::Var(induction.name.clone()))),
            }));
            let mirrored = tr.raw_address_to_pointer(
                DaExpr::Var(induction.addr.clone()),
                induction.pointer_type.clone(),
            );
            tr.pointer_inductions
                .borrow_mut()
                .insert(induction.decl, mirrored.clone());
            for (eid, step) in &induction.steps {
                if let StepPlace::After(inner) | StepPlace::Before(inner) = step.place {
                    tr.expr_overrides.borrow_mut().insert(inner, mirrored.clone());
                }
                self.steps.entry(*eid).or_default().push(step.clone());
            }
        }
    }

    /// Undo [`Self::enter_inductions`] and store each live pointer back.
    fn leave_inductions(&mut self, inductions: &[PointerInduction], out: &mut Vec<Node>) {
        let tr = self.tr;
        for induction in inductions {
            tr.pointer_inductions.borrow_mut().remove(&induction.decl);
            for (eid, step) in &induction.steps {
                if let StepPlace::After(inner) | StepPlace::Before(inner) = step.place {
                    tr.expr_overrides.borrow_mut().remove(&inner);
                }
                self.steps.remove(eid);
            }
            if induction.live_after {
                out.push(Node::Stmt(DaStmt::Expr(DaExpr::Assign(
                    Box::new(DaExpr::Var(induction.name.clone())),
                    Box::new(tr.raw_address_to_pointer(
                        DaExpr::Var(induction.addr.clone()),
                        induction.pointer_type.clone(),
                    )),
                ))));
            }
        }
    }
}

// ===== Counted loops: the C facts =====

/// A C loop the structured back end writes as daslang's `for` over a range.
enum CountedLoop {
    /// `do { … } while (count--)`: `count + 1` passes, nothing names the
    /// loop variable.
    Count(CDeclId),
    /// `for (init; i < end; i++)`: `i` is the loop variable.
    Index {
        var: CDeclId,
        unsigned: bool,
        init: CountedInit,
        end: CExprId,
        /// `i` is named nowhere outside the loop, so the loop variable can
        /// replace it under its own name.
        only_in_loop: bool,
    },
}

enum CountedInit {
    /// No init clause: the loop starts at `i`'s current value.
    Current,
    /// `for (int i = a; …)`.
    Decl(CDeclId),
    /// `for (i = a; …)`.
    Assign(CExprId),
}

/// The liveness walk's answer for one statement.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Flow {
    /// The loop is not inside this statement.
    NotFound,
    /// Every path from the loop's exit assigns the counter before reading it.
    Dead,
    /// Some path may read it.
    Live,
    /// The path left the statement's end without an answer.
    FellOff,
}

/// Through parentheses, GNU `__extension__`, and the casts that change no
/// value (`LValueToRValue`, `NoOp`).
fn peel(tr: &Translation, mut eid: CExprId) -> CExprId {
    loop {
        match tr.ast_context[eid].kind {
            CExprKind::Paren(_, inner)
            | CExprKind::Unary(_, CUnOp::Extension, inner, _)
            | CExprKind::ImplicitCast(_, inner, CastKind::LValueToRValue | CastKind::NoOp, _, _) => {
                eid = inner
            }
            _ => return eid,
        }
    }
}

/// Whether `decl` is named anywhere under `root`.
fn references(tr: &Translation, root: SomeId, decl: CDeclId) -> bool {
    count_references(tr, root, decl) > 0
}

fn count_references(tr: &Translation, root: SomeId, decl: CDeclId) -> usize {
    DFExpr::new(&tr.ast_context, root)
        .filter(|node| {
            matches!(node, SomeId::Expr(e)
                if matches!(tr.ast_context[*e].kind, CExprKind::DeclRef(_, d, _) if d == decl))
        })
        .count()
}

/// Whether anything under `root` stores to `decl` or takes its address: an
/// assignment to it, `++`/`--` on it, or `&decl`.  A local whose address is
/// never taken is written by nothing else.
fn writes(tr: &Translation, root: SomeId, decl: CDeclId) -> bool {
    let names = |place: CExprId| {
        matches!(tr.ast_context[peel(tr, place)].kind, CExprKind::DeclRef(_, d, _) if d == decl)
    };
    DFExpr::new(&tr.ast_context, root).any(|node| {
        let SomeId::Expr(e) = node else { return false };
        match tr.ast_context[e].kind {
            CExprKind::Binary(_, op, lhs, _, _, _) if op.is_assignment() => names(lhs),
            CExprKind::Unary(
                _,
                CUnOp::AddressOf
                | CUnOp::PreIncrement
                | CUnOp::PostIncrement
                | CUnOp::PreDecrement
                | CUnOp::PostDecrement,
                arg,
                _,
            ) => names(arg),
            _ => false,
        }
    })
}

/// `decl = e` with `e` not naming `decl`: the statement kills `decl`.
fn kills(tr: &Translation, eid: CExprId, decl: CDeclId) -> bool {
    let CExprKind::Binary(_, CBinOp::Assign, lhs, rhs, _, _) = tr.ast_context[peel(tr, eid)].kind
    else {
        return false;
    };
    matches!(tr.ast_context[peel(tr, lhs)].kind, CExprKind::DeclRef(_, d, _) if d == decl)
        && !references(tr, SomeId::Expr(rhs), decl)
}

/// Whether a `break` or `continue` stands anywhere under `sid`.
fn escapes(tr: &Translation, sid: CStmtId) -> bool {
    DFExpr::new(&tr.ast_context, SomeId::Stmt(sid)).any(|node| {
        matches!(node, SomeId::Stmt(s)
            if matches!(tr.ast_context[s].kind, CStmtKind::Break | CStmtKind::Continue))
    })
}

/// The value of `[name = value]`, the one statement an initializer lowered
/// to.
fn single_assignment(stmts: Option<&[DaStmt]>) -> Option<DaExpr> {
    match stmts? {
        [DaStmt::Expr(DaExpr::Assign(place, value))] if matches!(**place, DaExpr::Var(_)) => {
            Some((**value).clone())
        }
        _ => None,
    }
}

/// The most case values a `switch` is written as an `if`/`elif` chain with
/// its arms inline ([`switch_chain`]); more keep the flat dispatch (a jump
/// table or a median split over labels).  Measured in the interpreter
/// (20 M passes, a dense switch hit uniformly, one `acc += k` per arm; see
/// the translator `ARCHITECTURE.md`, "Control-flow back ends"): with a
/// statement after the switch the chain is 314 ms against the table's
/// 397 ms at 8 cases, 410 against 396 at 12, 520 against 377 at 16; with
/// the switch ending the loop body (the table's `break` is `continue`) 280
/// against 271 at 8, 380 against 283 at 12.
const CHAIN_MAX: usize = 8;

/// A `switch` whose arms never fall into each other, as an `if`/`elif`
/// chain with each arm inline: no label and no jump at all.
///
/// Taken for [`CHAIN_MAX`] case values or fewer when every arm but the last
/// ends in a statement that leaves it (its `break`, a `return`, the loop's
/// `break`/`continue`) and every `break` of the switch can be folded away
/// ([`lift_breaks`]).  The values are distinct (C11 6.8.4.2p3), so the order
/// of the tests does not matter, and `default`, wherever it stands, is the
/// final `else`.
fn switch_chain(
    scrutinee: &DaExpr,
    cases: &[(DaExpr, Target)],
    default: Option<Sym>,
    arms: &[(Sym, Vec<Node>)],
    end: Sym,
) -> Result<Vec<Node>, &'static str> {
    if cases.len() > CHAIN_MAX {
        return Err("more than eight case values");
    }
    let mut bodies: Vec<(Sym, Vec<Node>)> = Vec::with_capacity(arms.len());
    for (index, (label, nodes)) in arms.iter().enumerate() {
        let mut body = nodes.clone();
        drop_dead(&mut body);
        let last = index + 1 == arms.len();
        if !last && !ends(&body) {
            return Err("fall-through");
        }
        let body = lift_breaks(body, end).ok_or("a break the chain cannot fold")?;
        let mut jumped = HashSet::new();
        targets(&body, &mut jumped);
        if jumped.contains(&end) {
            return Err("a break the chain cannot fold");
        }
        if has_label(&body) {
            return Err("a label region inside an arm");
        }
        bodies.push((*label, body));
    }
    let test = |label: Sym| -> Option<DaExpr> {
        cases
            .iter()
            .filter(|(_, target)| matches!(target, Target::Label(l) if *l == label))
            .map(|(value, _)| DaExpr::Op2 {
                op: "==",
                left: Box::new(scrutinee.clone()),
                right: Box::new(value.clone()),
            })
            .reduce(|left, right| DaExpr::Op2 {
                op: "||",
                left: Box::new(left),
                right: Box::new(right),
            })
    };
    let mut chain: Vec<Node> = bodies
        .iter()
        .find(|(label, _)| Some(*label) == default)
        .map(|(_, body)| body.clone())
        .unwrap_or_default();
    for (label, body) in bodies.into_iter().rev() {
        if Some(label) == default {
            continue;
        }
        let cond = test(label).ok_or("an arm without a case value")?;
        chain = vec![Node::If {
            cond,
            then: body,
            else_: chain,
        }];
    }
    // Without case arms the chain is the default arm alone (or nothing).
    Ok(chain)
}

/// Remove every `break` of the switch (`goto end`) from an arm whose end is
/// the end of the switch, so the arm can stand inline in an `if`/`elif`
/// chain, or `None` when one cannot be removed without copying statements.
///
/// Falling off `nodes` reaches `end`, so a trailing `goto end` is dropped.
/// A `goto end` that ends one branch of an `if` makes the statements after
/// the `if` the other branch's continuation (`if (c) { a; break } b` is
/// `if c { a } else { b }`), and the question repeats inside both branches.
/// A `goto end` deeper in a branch that falls through to statements after
/// its `if` would need those statements twice; one inside a loop would need
/// a labelled `break` daslang does not have.  Both keep the label region.
fn lift_breaks(nodes: Vec<Node>, end: Sym) -> Option<Vec<Node>> {
    let mut out = Vec::new();
    let mut nodes = nodes.into_iter();
    while let Some(node) = nodes.next() {
        match node {
            // `drop_dead` left nothing after it.
            Node::Goto(target) if target == end => return Some(out),
            Node::If { cond, then, else_ } if mentions(&then, end) || mentions(&else_, end) => {
                let rest: Vec<Node> = nodes.collect();
                let then_exits = matches!(then.last(), Some(Node::Goto(t)) if *t == end);
                let else_exits = matches!(else_.last(), Some(Node::Goto(t)) if *t == end);
                let (then, else_) = match (then_exits, else_exits) {
                    (true, false) => (
                        lift_breaks(then, end)?,
                        lift_breaks(join(else_, rest), end)?,
                    ),
                    (false, true) => (
                        lift_breaks(join(then, rest), end)?,
                        lift_breaks(else_, end)?,
                    ),
                    (false, false) if !rest.is_empty() => return None,
                    // Both branches leave, so `rest` is dead and gone.
                    _ => (lift_breaks(then, end)?, lift_breaks(else_, end)?),
                };
                out.push(if then.is_empty() && !else_.is_empty() {
                    Node::If {
                        cond: flat::negate(&cond),
                        then: else_,
                        else_: vec![],
                    }
                } else {
                    Node::If { cond, then, else_ }
                });
                return Some(out);
            }
            Node::Loop { ref body, .. } | Node::For { ref body, .. } if mentions(body, end) => {
                return None
            }
            node => out.push(node),
        }
    }
    Some(out)
}

/// `head` then `rest`, minus what the end of `head` makes unreachable.
fn join(mut head: Vec<Node>, rest: Vec<Node>) -> Vec<Node> {
    head.extend(rest);
    drop_dead(&mut head);
    head
}

/// Whether a `goto target` stands anywhere under `nodes`.
fn mentions(nodes: &[Node], target: Sym) -> bool {
    let mut jumped = HashSet::new();
    targets(nodes, &mut jumped);
    jumped.contains(&target)
}

/// Whether a label stands anywhere under `nodes`.
fn has_label(nodes: &[Node]) -> bool {
    nodes.iter().any(|node| match node {
        Node::Label(_) => true,
        Node::If { then, else_, .. } => has_label(then) || has_label(else_),
        Node::Loop { body, .. } | Node::For { body, .. } => has_label(body),
        _ => false,
    })
}

/// Whether `nodes` leave the loop whose body they are: a `break` or
/// `continue` not inside a nested loop.
fn leaves_loop(nodes: &[Node]) -> bool {
    nodes.iter().any(|node| match node {
        Node::Break | Node::Continue => true,
        Node::If { then, else_, .. } => leaves_loop(then) || leaves_loop(else_),
        _ => false,
    })
}

/// Whether `nodes` contain a `break` of the loop whose body they are.
fn breaks_loop(nodes: &[Node]) -> bool {
    nodes.iter().any(|node| match node {
        Node::Break => true,
        Node::If { then, else_, .. } => breaks_loop(then) || breaks_loop(else_),
        _ => false,
    })
}

// ===== Entry point =====

/// Lower a function body that [`fallback_reason`] accepted.
pub(crate) fn convert(
    tr: &Translation,
    stmts: &[CStmtId],
    ret: ImplicitReturnType,
    ret_ty: Option<CQualTypeId>,
) -> TranslationResult<Vec<DaStmt>> {
    let mut builder = Builder {
        tr,
        ret_ty,
        body: stmts,
        store: DeclStmtStore::new(),
        prelude: Vec::new(),
        next_sym: 0,
        breaks: Vec::new(),
        loops: Vec::new(),
        suppressed: HashSet::new(),
        steps: HashMap::new(),
    };
    let mut body = Vec::new();
    for &sid in stmts {
        builder.stmt(sid, &mut body)?;
    }
    body.push(Node::Stmt(implicit_return(&ret)));
    let top = match ret {
        ImplicitReturnType::Void | ImplicitReturnType::StmtExprVoid => Ctx::TopVoid,
        _ => Ctx::TopValue,
    };
    let Builder {
        mut store,
        prelude,
        mut next_sym,
        suppressed,
        ..
    } = builder;

    // Every C local is hoisted (see the module documentation), in source
    // order, after the scrutinee temporaries.  A local a range loop's
    // variable replaced has no declaration of its own.
    strip_decls(&mut body, &suppressed);
    let mut declared: IndexSet<CDeclId> = IndexSet::new();
    collect_decls(&body, &mut declared);
    let mut hoisted: Vec<DaStmt> = prelude;
    for decl in &declared {
        hoisted.extend(
            store
                .extract_decl(*decl)?
                .into_iter()
                .map(flat::writable_decl),
        );
    }
    place_decls(&mut body, &declared, &mut store);

    // Resolving a label can make the statements after its jumps dead, and
    // dropping them can leave another label at the end of its list (an empty
    // last arm above a void function's closing `return`), so the two repeat
    // until the labels stop changing; `check` below rejects anything left.
    cleanup(&mut body);
    for _ in 0..16 {
        let before = label_count(&body);
        if resolve(&mut body, top, &mut next_sym)? {
            return Err(internal("a label at the end of the function body"));
        }
        cleanup(&mut body);
        if label_count(&body) == before {
            break;
        }
    }
    out_of_line(&mut body, &mut next_sym);
    check(&body, top)?;

    let mut renderer = Renderer::new(&body)?;
    let mut temps = Vec::new();
    let mut stored_at_site = HashSet::new();
    let rendered = renderer.list(&body, &mut temps, &mut stored_at_site);
    for temp in &mut temps {
        if let DaStmt::Var { var_type, init, .. } = temp {
            if tr.da_type_zero_fills(var_type) {
                *init = None;
            }
        }
    }

    let mut out = hoisted;
    let declarations_at = out.len();
    out.extend(temps);
    let body_start = out.len();
    out.extend(rendered);
    flat::coalesce_site_temporaries(&mut out, declarations_at, body_start, &stored_at_site);
    flat::initialise_last_declaration(&mut out);

    // daslang requires a function with a value to end on a path it sees
    // returning (`exprReturns`, `src/ast/ast_lint.cpp`); a C function that
    // only leaves through a `return` inside an endless loop does not look
    // like one.  The value after the trap is never produced.
    if top == Ctx::TopValue && !stmts_return(&out) {
        if !matches!(out.last(), Some(DaStmt::Expr(DaExpr::Call(..)))) {
            out.push(implicit_return(&ret));
        }
        let ret_da = match ret_ty {
            Some(ret_ty) => tr.convert_type(ret_ty)?,
            None => DaType::int(),
        };
        out.push(DaStmt::Expr(DaExpr::Return(Some(Box::new(
            crate::translator::default_initializer_for_datype(&ret_da),
        )))));
    }
    Ok(out)
}

fn label_count(nodes: &[Node]) -> usize {
    let mut labels = Vec::new();
    label_order(nodes, &mut labels);
    labels.len()
}

fn internal(what: &str) -> TranslationError {
    crate::format_translation_err!(None, "structured control flow: internal error: {what}")
}

fn collect_decls(nodes: &[Node], out: &mut IndexSet<CDeclId>) {
    for node in nodes {
        match node {
            Node::Decl(decl) => {
                out.insert(*decl);
            }
            Node::If { then, else_, .. } => {
                collect_decls(then, out);
                collect_decls(else_, out);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => collect_decls(body, out),
            _ => {}
        }
    }
}

/// Drop the declaration sites of locals a range loop's variable replaced.
fn strip_decls(nodes: &mut Vec<Node>, suppressed: &HashSet<CDeclId>) {
    if suppressed.is_empty() {
        return;
    }
    nodes.retain(|node| !matches!(node, Node::Decl(decl) if suppressed.contains(decl)));
    for node in nodes.iter_mut() {
        match node {
            Node::If { then, else_, .. } => {
                strip_decls(then, suppressed);
                strip_decls(else_, suppressed);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => strip_decls(body, suppressed),
            _ => {}
        }
    }
}

/// Replace each declaration site by its initializer's assignments.
fn place_decls(nodes: &mut Vec<Node>, declared: &IndexSet<CDeclId>, store: &mut DeclStmtStore) {
    let old = std::mem::take(nodes);
    for mut node in old {
        match &mut node {
            Node::Decl(decl) => {
                nodes.extend(stmt_nodes(
                    StmtOrDecl::Decl(*decl).place_decls(declared, store),
                ));
                continue;
            }
            Node::If { then, else_, .. } => {
                place_decls(then, declared, store);
                place_decls(else_, declared, store);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => place_decls(body, declared, store),
            _ => {}
        }
        nodes.push(node);
    }
}

// ===== Tree passes =====

fn is_return(node: &Node) -> bool {
    matches!(node, Node::Stmt(DaStmt::Expr(DaExpr::Return(_))))
}

/// Whether control never continues after `node` in sequence.
fn terminates(node: &Node) -> bool {
    match node {
        Node::Break | Node::Continue | Node::Goto(_) | Node::Dispatch { .. } => true,
        Node::Stmt(_) => is_return(node),
        Node::If { then, else_, .. } => !else_.is_empty() && ends(then) && ends(else_),
        Node::Loop { cond: None, body } => !breaks_loop(body),
        _ => false,
    }
}

fn ends(nodes: &[Node]) -> bool {
    nodes.last().map_or(false, terminates)
}

/// Every label some jump names.
fn targets(nodes: &[Node], out: &mut HashSet<Sym>) {
    for node in nodes {
        match node {
            Node::Goto(sym) => {
                out.insert(*sym);
            }
            Node::Dispatch { cases, default, .. } => {
                for target in cases.iter().map(|(_, t)| t).chain(std::iter::once(default)) {
                    if let Target::Label(sym) = target {
                        out.insert(*sym);
                    }
                }
            }
            Node::If { then, else_, .. } => {
                targets(then, out);
                targets(else_, out);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => targets(body, out),
            _ => {}
        }
    }
}

/// Drop unreachable statements (after a statement that transfers, up to the
/// next label) and labels nothing jumps to, until neither changes anything.
/// C dead code never reaches daslang, which would reject some of it.
fn cleanup(nodes: &mut Vec<Node>) {
    loop {
        drop_dead(nodes);
        let mut jumped = HashSet::new();
        targets(nodes, &mut jumped);
        if !drop_unjumped_labels(nodes, &jumped) {
            return;
        }
    }
}

fn drop_dead(nodes: &mut Vec<Node>) {
    // A jump to a label among the ones right after it is a fall-through.
    let mut index = 0;
    while index < nodes.len() {
        if let Node::Goto(target) = nodes[index] {
            let lands_next = nodes[index + 1..]
                .iter()
                .map_while(|node| match node {
                    Node::Label(sym) => Some(*sym),
                    _ => None,
                })
                .any(|sym| sym == target);
            if lands_next {
                nodes.remove(index);
                continue;
            }
        }
        index += 1;
    }
    let old = std::mem::take(nodes);
    let mut dead = false;
    for mut node in old {
        if dead && !matches!(node, Node::Label(_)) {
            continue;
        }
        match &mut node {
            Node::If { then, else_, .. } => {
                drop_dead(then);
                drop_dead(else_);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => drop_dead(body),
            _ => {}
        }
        dead = !matches!(node, Node::Label(_)) && terminates(&node);
        nodes.push(node);
    }
}

fn drop_unjumped_labels(nodes: &mut Vec<Node>, jumped: &HashSet<Sym>) -> bool {
    let before = nodes.len();
    nodes.retain(|node| !matches!(node, Node::Label(sym) if !jumped.contains(sym)));
    let mut changed = nodes.len() != before;
    for node in nodes.iter_mut() {
        match node {
            Node::If { then, else_, .. } => {
                changed |= drop_unjumped_labels(then, jumped);
                changed |= drop_unjumped_labels(else_, jumped);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => {
                changed |= drop_unjumped_labels(body, jumped)
            }
            _ => {}
        }
    }
    changed
}

/// The labels at the end of a list that no statement follows.  A void
/// function's closing `return` does not count: daslang deletes it.
fn dangling_labels(nodes: &[Node], ctx: Ctx) -> Vec<Sym> {
    let mut end = nodes.len();
    if ctx == Ctx::TopVoid
        && matches!(
            nodes.last(),
            Some(Node::Stmt(DaStmt::Expr(DaExpr::Return(None))))
        )
    {
        end -= 1;
    }
    nodes[..end]
        .iter()
        .rev()
        .map_while(|node| match node {
            Node::Label(sym) => Some(*sym),
            _ => None,
        })
        .collect()
}

/// Resolve every dangling label (rule 1 of the module documentation).
/// Returns whether `nodes` still has one, which only an `Unknown` list can:
/// its parent then splices the `if` that holds it.
fn resolve(nodes: &mut Vec<Node>, ctx: Ctx, next: &mut Sym) -> TranslationResult<bool> {
    let mut index = 0;
    while index < nodes.len() {
        // An `if` followed by nothing, or only by the statement that falling
        // off this list means anyway, ends this list.
        let rest = &nodes[index + 1..];
        let last = match (ctx, rest) {
            (_, []) => true,
            (Ctx::TopVoid, [Node::Stmt(DaStmt::Expr(DaExpr::Return(None)))]) => true,
            (Ctx::LoopEnd, [Node::Continue]) => true,
            _ => false,
        };
        let mut splice = false;
        match &mut nodes[index] {
            Node::If { then, else_, .. } => {
                let arm_ctx = if last { ctx } else { Ctx::Unknown };
                let then_dangles = resolve(then, arm_ctx, next)?;
                let else_dangles = resolve(else_, arm_ctx, next)?;
                // An arm whose own labels would trap a jump out of it (the
                // outer `switch`'s `break` next to an inner `switch` region)
                // is spliced too: its labels then join the jump's target's.
                splice = then_dangles || else_dangles || jumps_out(then) || jumps_out(else_);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => {
                if resolve(body, Ctx::LoopEnd, next)? {
                    return Err(internal("a dangling label in a loop body"));
                }
            }
            _ => {}
        }
        if splice {
            let Node::If { cond, then, else_ } = nodes.remove(index) else {
                unreachable!("only an `if` is spliced");
            };
            let spliced = splice_if(cond, then, else_, next);
            let len = spliced.len();
            nodes.splice(index..index, spliced);
            index += len;
        } else {
            index += 1;
        }
    }
    let dangling = dangling_labels(nodes, ctx);
    if dangling.is_empty() {
        return Ok(false);
    }
    let exit = match ctx {
        Ctx::LoopEnd => Exit::Continue,
        Ctx::TopVoid => Exit::Return,
        Ctx::Unknown => return Ok(true),
        Ctx::TopValue => return Err(internal("a label after the closing trap")),
    };
    for sym in &dangling {
        retarget(nodes, *sym, exit)?;
    }
    nodes.retain(|node| !matches!(node, Node::Label(sym) if dangling.contains(sym)));
    Ok(false)
}

/// Whether a list with labels of its own holds a jump to a label outside it,
/// which the interpreter's label table of that list would refuse.
fn jumps_out(nodes: &[Node]) -> bool {
    if !nodes.iter().any(|node| matches!(node, Node::Label(_))) {
        return false;
    }
    let mut jumped = HashSet::new();
    targets(nodes, &mut jumped);
    let mut defined = Vec::new();
    label_order(nodes, &mut defined);
    jumped.iter().any(|sym| !defined.contains(sym))
}

/// `if !c { goto ELSE }; then…; goto JOIN; label ELSE: else…; label JOIN:`
/// (without `else`: `if !c { goto JOIN }; then…; label JOIN:`).
fn splice_if(cond: DaExpr, then: Vec<Node>, else_: Vec<Node>, next: &mut Sym) -> Vec<Node> {
    let mut fresh = || {
        let sym = *next;
        *next += 1;
        sym
    };
    let join = fresh();
    let mut out = Vec::new();
    if else_.is_empty() {
        out.push(Node::If {
            cond: flat::negate(&cond),
            then: vec![Node::Goto(join)],
            else_: vec![],
        });
        out.extend(then);
    } else {
        let otherwise = fresh();
        out.push(Node::If {
            cond: flat::negate(&cond),
            then: vec![Node::Goto(otherwise)],
            else_: vec![],
        });
        let then_ends = ends(&then);
        out.extend(then);
        if !then_ends {
            out.push(Node::Goto(join));
        }
        out.push(Node::Label(otherwise));
        out.extend(else_);
    }
    out.push(Node::Label(join));
    out
}

/// Turn every jump to `sym` into `exit`.
fn retarget(nodes: &mut [Node], sym: Sym, exit: Exit) -> TranslationResult<()> {
    for node in nodes.iter_mut() {
        match node {
            Node::Goto(target) if *target == sym => *node = exit.node(),
            Node::Dispatch { cases, default, .. } => {
                for target in cases
                    .iter_mut()
                    .map(|(_, t)| t)
                    .chain(std::iter::once(default))
                {
                    if matches!(target, Target::Label(s) if *s == sym) {
                        *target = Target::Exit(exit);
                    }
                }
            }
            Node::If { then, else_, .. } => {
                retarget(then, sym, exit)?;
                retarget(else_, sym, exit)?;
            }
            Node::Loop { body, .. } | Node::For { body, .. } => {
                let mut inner = HashSet::new();
                targets(body, &mut inner);
                if inner.contains(&sym) {
                    return Err(internal("a jump out of a loop to a dangling label"));
                }
            }
            _ => {}
        }
    }
    Ok(())
}

/// Whether daslang's if-return folding treats `node` as an early exit: an
/// `if` without `else` whose arm ends in `return`/`break`/`continue` (a
/// dispatch that may print as one counts too).
fn early_exit(node: &Node) -> bool {
    let Node::If { then, else_, .. } = node else {
        return false;
    };
    else_.is_empty()
        && match then.last() {
            Some(Node::Break | Node::Continue) => true,
            Some(last @ Node::Stmt(_)) => is_return(last),
            Some(Node::Dispatch { cases, default, .. }) => cases
                .iter()
                .map(|(_, t)| t)
                .chain(std::iter::once(default))
                .any(|t| matches!(t, Target::Exit(_))),
            _ => false,
        }
}

fn direct_labels(nodes: &[Node]) -> HashSet<Sym> {
    nodes
        .iter()
        .filter_map(|node| match node {
            Node::Label(sym) => Some(*sym),
            _ => None,
        })
        .collect()
}

/// Whether the early exit at `nodes[k]` has a label after it that a jump
/// crosses.
fn crossed_early_exit(nodes: &[Node], k: usize) -> bool {
    if k + 1 == nodes.len() || !early_exit(&nodes[k]) {
        return false;
    }
    let (above, below) = nodes.split_at(k + 1);
    let below_labels = direct_labels(below);
    if below_labels.is_empty() {
        return false;
    }
    let above_labels = direct_labels(above);
    let mut from_below = HashSet::new();
    targets(below, &mut from_below);
    let mut from_above = HashSet::new();
    targets(above, &mut from_above);
    from_below.iter().any(|sym| above_labels.contains(sym))
        || from_above.iter().any(|sym| below_labels.contains(sym))
}

/// Rule 2 of the module documentation, in every list with labels.
fn out_of_line(nodes: &mut Vec<Node>, next: &mut Sym) {
    for node in nodes.iter_mut() {
        match node {
            Node::If { then, else_, .. } => {
                out_of_line(then, next);
                out_of_line(else_, next);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => out_of_line(body, next),
            _ => {}
        }
    }
    while let Some(k) = (0..nodes.len()).find(|&k| crossed_early_exit(nodes, k)) {
        let arm_label = *next;
        *next += 1;
        let Node::If { then, .. } = &mut nodes[k] else {
            unreachable!("crossed_early_exit only accepts an `if`");
        };
        let arm = std::mem::replace(then, vec![Node::Goto(arm_label)]);
        let mut moved = vec![Node::Label(arm_label)];
        moved.extend(arm);
        let slot = (k + 1..nodes.len())
            .chain(1..k)
            .find(|&p| terminates(&nodes[p - 1]) && matches!(nodes[p], Node::Label(_)));
        match slot {
            Some(p) => {
                nodes.splice(p..p, moved);
            }
            None => {
                let resume = *next;
                *next += 1;
                let mut prologue = vec![Node::Goto(resume)];
                prologue.extend(moved);
                prologue.push(Node::Label(resume));
                nodes.splice(0..0, prologue);
            }
        }
    }
}

/// Re-verify the three label rules on the final tree.
fn check(nodes: &[Node], top: Ctx) -> TranslationResult<()> {
    let mut seen = HashSet::new();
    check_list(nodes, &HashSet::new(), top, &mut seen)
}

fn check_list(
    nodes: &[Node],
    inherited: &HashSet<Sym>,
    ctx: Ctx,
    seen: &mut HashSet<Sym>,
) -> TranslationResult<()> {
    let own = direct_labels(nodes);
    for sym in &own {
        if !seen.insert(*sym) {
            return Err(internal("a label defined twice"));
        }
    }
    // A block without labels passes a jump up to its parent; one with labels
    // only reaches its own.
    let scope = if own.is_empty() { inherited } else { &own };
    if !dangling_labels(nodes, ctx).is_empty() {
        return Err(internal("a label with no statement after it"));
    }
    if !own.is_empty() && (0..nodes.len()).any(|k| crossed_early_exit(nodes, k)) {
        return Err(internal("an early exit crossed by a jump"));
    }
    for node in nodes {
        match node {
            Node::Goto(sym) if !scope.contains(sym) => {
                return Err(internal("a jump out of its labelled block"));
            }
            Node::Dispatch { cases, default, .. } => {
                for target in cases.iter().map(|(_, t)| t).chain(std::iter::once(default)) {
                    if matches!(target, Target::Label(sym) if !scope.contains(sym)) {
                        return Err(internal("a dispatch out of its labelled block"));
                    }
                }
            }
            Node::If { then, else_, .. } => {
                check_list(then, scope, Ctx::Unknown, seen)?;
                check_list(else_, scope, Ctx::Unknown, seen)?;
            }
            // A jump never leaves a loop body.
            Node::Loop { body, .. } | Node::For { body, .. } => {
                check_list(body, &HashSet::new(), Ctx::LoopEnd, seen)?
            }
            _ => {}
        }
    }
    Ok(())
}

// ===== Rendering =====

struct Renderer {
    /// The planned dispatches, in tree order.
    dispatches: Vec<Tail>,
    next_dispatch: usize,
    /// The number of each label some jump names.
    named: HashMap<Sym, u64>,
    /// The jump-table alias numbers of each label.
    aliases: HashMap<Sym, Vec<u64>>,
    /// Per dispatch: the alias numbers of each exit its tables reach.
    trampolines: Vec<Vec<(Exit, Vec<u64>)>>,
}

fn sym_label(sym: Sym) -> Label {
    Label::Synthetic(sym)
}

fn target_label(target: &Target) -> Label {
    match target {
        Target::Label(sym) => sym_label(*sym),
        Target::Exit(exit) => exit.label(),
    }
}

fn label_sym(label: &Label) -> Option<Sym> {
    match label {
        Label::Synthetic(sym) if Exit::of_label(label).is_none() => Some(*sym),
        _ => None,
    }
}

impl Renderer {
    fn new(body: &[Node]) -> TranslationResult<Renderer> {
        let mut dispatches = Vec::new();
        plan_dispatches(body, &mut dispatches)?;
        // Named labels are numbered in the order they appear.
        let mut jumped: HashSet<Sym> = HashSet::new();
        let mut gotos = HashSet::new();
        targets_by_goto(body, &mut gotos);
        jumped.extend(gotos);
        for tail in &dispatches {
            jumped.extend(tail.targets().into_iter().filter_map(label_sym));
        }
        let mut order = Vec::new();
        label_order(body, &mut order);
        let mut named = HashMap::new();
        for sym in order {
            if jumped.contains(&sym) {
                let id = named.len() as u64;
                named.insert(sym, id);
            }
        }
        // Each jump table owns a run of numbers after the named labels.
        let mut next_id = named.len() as u64;
        let mut aliases: HashMap<Sym, Vec<u64>> = HashMap::new();
        let mut trampolines = Vec::new();
        for tail in dispatches.iter_mut() {
            let mut exits: Vec<(Exit, Vec<u64>)> = Vec::new();
            if let Tail::Dispatch { tree, .. } = tail {
                let mut tables = Vec::new();
                tree.tables_mut(&mut tables);
                for (entries, base) in tables {
                    *base = Some(next_id);
                    for entry in entries {
                        let id = next_id;
                        next_id += 1;
                        match (Exit::of_label(entry), label_sym(entry)) {
                            (Some(exit), _) => match exits.iter_mut().find(|(e, _)| *e == exit) {
                                Some((_, ids)) => ids.push(id),
                                None => exits.push((exit, vec![id])),
                            },
                            (None, Some(sym)) => aliases.entry(sym).or_default().push(id),
                            (None, None) => {
                                return Err(internal("a jump-table entry to a C label"))
                            }
                        }
                    }
                }
            }
            trampolines.push(exits);
        }
        Ok(Renderer {
            dispatches,
            next_dispatch: 0,
            named,
            aliases,
            trampolines,
        })
    }

    fn goto(&self, label: &Label) -> DaStmt {
        if let Some(exit) = Exit::of_label(label) {
            return exit.stmt();
        }
        let sym = label_sym(label).expect("dispatch targets are symbols or exits");
        DaStmt::Expr(DaExpr::Goto(flat::alias_text(self.named[&sym])))
    }

    /// Render a list; `temps` receives the site temporaries hoisted out of a
    /// list with labels (rule 3), `stored_at_site` those that left a store.
    fn list(
        &mut self,
        nodes: &[Node],
        temps: &mut Vec<DaStmt>,
        stored_at_site: &mut HashSet<String>,
    ) -> Vec<DaStmt> {
        let has_labels = nodes.iter().any(|node| matches!(node, Node::Label(_)));
        let mut out = Vec::new();
        for node in nodes {
            match node {
                Node::Stmt(DaStmt::Var {
                    name,
                    var_type,
                    init,
                }) if has_labels && flat::hoistable(var_type, init.as_ref()) => {
                    let mut declared = var_type.clone();
                    declared.is_const = false;
                    let default = crate::translator::default_initializer_for_datype(&declared);
                    temps.push(DaStmt::Var {
                        name: name.clone(),
                        var_type: declared,
                        init: Some(default),
                    });
                    if let Some(value) = init {
                        stored_at_site.insert(name.clone());
                        out.push(DaStmt::Expr(DaExpr::Assign(
                            Box::new(DaExpr::Var(name.clone())),
                            Box::new(value.clone()),
                        )));
                    }
                }
                Node::Stmt(stmt) => out.push(stmt.clone()),
                Node::Decl(_) => unreachable!("declarations are placed before rendering"),
                Node::If { cond, then, else_ } => {
                    let then = self.block(then, temps, stored_at_site);
                    let mut elifs = Vec::new();
                    let mut rest = else_.as_slice();
                    // `else { if … }` is `elif …`.
                    while let [Node::If {
                        cond: inner_cond,
                        then: inner_then,
                        else_: inner_else,
                    }] = rest
                    {
                        elifs.push((
                            inner_cond.clone(),
                            self.block(inner_then, temps, stored_at_site),
                        ));
                        rest = inner_else.as_slice();
                    }
                    let else_ = if rest.is_empty() {
                        None
                    } else {
                        Some(Box::new(self.block(rest, temps, stored_at_site)))
                    };
                    out.push(DaStmt::Expr(DaExpr::IfThenElse {
                        cond: Box::new(cond.clone()),
                        then: Box::new(then),
                        elifs,
                        else_,
                    }));
                }
                Node::Loop { cond, body } => {
                    let body = self.block(body, temps, stored_at_site);
                    out.push(DaStmt::Expr(DaExpr::While(
                        Box::new(cond.clone().unwrap_or(DaExpr::ConstBool(true))),
                        Box::new(body),
                    )));
                }
                Node::For { var, source, body } => {
                    let body = self.block(body, temps, stored_at_site);
                    out.push(DaStmt::Expr(DaExpr::For {
                        vars: vec![var.clone()],
                        sources: vec![source.clone()],
                        body: Box::new(body),
                    }));
                }
                Node::Break => out.push(DaStmt::Expr(DaExpr::Break)),
                Node::Continue => out.push(DaStmt::Expr(DaExpr::Continue)),
                Node::Label(sym) => {
                    if let Some(id) = self.named.get(sym) {
                        out.push(DaStmt::Expr(DaExpr::Label(flat::alias_text(*id))));
                    }
                    for id in self.aliases.get(sym).into_iter().flatten() {
                        out.push(DaStmt::Expr(DaExpr::Label(flat::alias_text(*id))));
                    }
                }
                Node::Goto(sym) => out.push(DaStmt::Expr(DaExpr::Goto(flat::alias_text(
                    self.named[sym],
                )))),
                Node::Dispatch { .. } => {
                    let index = self.next_dispatch;
                    self.next_dispatch += 1;
                    let Tail::Dispatch {
                        scrutinee,
                        tree,
                        default,
                    } = &self.dispatches[index]
                    else {
                        unreachable!("every dispatch is planned as one");
                    };
                    out.extend(dispatch(self, scrutinee, tree, default.as_ref()));
                    for (exit, ids) in &self.trampolines[index] {
                        for id in ids {
                            out.push(DaStmt::Expr(DaExpr::Label(flat::alias_text(*id))));
                        }
                        out.push(exit.stmt());
                    }
                }
            }
        }
        out
    }

    fn block(
        &mut self,
        nodes: &[Node],
        temps: &mut Vec<DaStmt>,
        stored_at_site: &mut HashSet<String>,
    ) -> DaExpr {
        DaExpr::Block(DaBlock {
            stmts: self.list(nodes, temps, stored_at_site),
        })
    }
}

fn dispatch(
    renderer: &Renderer,
    scrutinee: &DaExpr,
    tree: &DispatchTree,
    default: Option<&Label>,
) -> Vec<DaStmt> {
    flat::dispatch_stmts(scrutinee, tree, &|label| renderer.goto(label), default)
}

/// Plan every dispatch, in tree order, as the flat back end plans a `switch`
/// terminator whose default arm is not the next block.
fn plan_dispatches(nodes: &[Node], out: &mut Vec<Tail>) -> TranslationResult<()> {
    for node in nodes {
        match node {
            Node::Dispatch {
                scrutinee,
                cases,
                default,
            } => {
                let mut arms: Vec<(DaExpr, Label)> = cases
                    .iter()
                    .map(|(value, target)| (value.clone(), target_label(target)))
                    .collect();
                arms.push((DaExpr::ConstBool(true), target_label(default)));
                out.push(flat::plan(
                    &GenTerminator::Switch {
                        expr: scrutinee.clone(),
                        cases: arms,
                    },
                    None,
                )?);
            }
            Node::If { then, else_, .. } => {
                plan_dispatches(then, out)?;
                plan_dispatches(else_, out)?;
            }
            Node::Loop { body, .. } | Node::For { body, .. } => plan_dispatches(body, out)?,
            _ => {}
        }
    }
    Ok(())
}

fn targets_by_goto(nodes: &[Node], out: &mut HashSet<Sym>) {
    for node in nodes {
        match node {
            Node::Goto(sym) => {
                out.insert(*sym);
            }
            Node::If { then, else_, .. } => {
                targets_by_goto(then, out);
                targets_by_goto(else_, out);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => targets_by_goto(body, out),
            _ => {}
        }
    }
}

fn label_order(nodes: &[Node], out: &mut Vec<Sym>) {
    for node in nodes {
        match node {
            Node::Label(sym) => out.push(*sym),
            Node::If { then, else_, .. } => {
                label_order(then, out);
                label_order(else_, out);
            }
            Node::Loop { body, .. } | Node::For { body, .. } => label_order(body, out),
            _ => {}
        }
    }
}

// ===== daslang's `exprReturns` =====

/// daslang's `exprReturns` (`src/ast/ast_lint.cpp`) over a statement list.
fn stmts_return(stmts: &[DaStmt]) -> bool {
    if stmts
        .iter()
        .any(|stmt| matches!(stmt, DaStmt::Expr(DaExpr::Label(_))))
    {
        return true;
    }
    for stmt in stmts {
        let DaStmt::Expr(expr) = stmt else {
            continue;
        };
        if matches!(
            expr,
            DaExpr::Break | DaExpr::Continue | DaExpr::Goto(_) | DaExpr::GotoComputed(_)
        ) {
            return false;
        }
        if expr_returns(expr) {
            return true;
        }
    }
    false
}

fn expr_returns(expr: &DaExpr) -> bool {
    match expr {
        DaExpr::Return(_) => true,
        DaExpr::Block(block) => stmts_return(&block.stmts),
        DaExpr::IfThenElse {
            then, elifs, else_, ..
        } => {
            let Some(else_) = else_ else {
                return false;
            };
            expr_returns(then)
                && elifs.iter().all(|(_, arm)| expr_returns(arm))
                && expr_returns(else_)
        }
        DaExpr::While(_, body) => expr_returns(body),
        DaExpr::Unsafe(body) => expr_returns(body),
        _ => false,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn call(name: &str) -> Node {
        Node::Stmt(DaStmt::Expr(DaExpr::Call(
            Box::new(DaExpr::Var(name.to_string())),
            vec![],
        )))
    }

    fn case(value: i64, sym: Sym) -> (DaExpr, Target) {
        (
            DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(DaExpr::ConstInt(value)),
                to: DaType::int(),
            },
            Target::Label(sym),
        )
    }

    /// `switch (x) { case 1: f(); break; }` as the whole body of a loop.
    fn region() -> Vec<Node> {
        vec![
            Node::Dispatch {
                scrutinee: DaExpr::Var("x".into()),
                cases: vec![case(1, 0)],
                default: Target::Label(1),
            },
            Node::Label(0),
            call("f"),
            Node::Goto(1),
            Node::Label(1),
        ]
    }

    #[test]
    fn a_region_that_ends_a_loop_body_ends_in_continue() {
        let mut body = region();
        let mut next = 2;
        cleanup(&mut body);
        assert!(!resolve(&mut body, Ctx::LoopEnd, &mut next).unwrap());
        assert!(matches!(
            &body[0],
            Node::Dispatch {
                default: Target::Exit(Exit::Continue),
                ..
            }
        ));
        // The arm's `break` fell through to the end, which is gone.
        assert!(!body
            .iter()
            .any(|node| matches!(node, Node::Label(1) | Node::Goto(_))));
        assert!(check_list(&body, &HashSet::new(), Ctx::LoopEnd, &mut HashSet::new()).is_ok());
    }

    #[test]
    fn a_region_that_ends_an_if_arm_splices_the_if() {
        // `if (c) { switch … } g();` — falling off the arm has no statement.
        let mut body = vec![
            Node::If {
                cond: DaExpr::Var("c".into()),
                then: region(),
                else_: vec![],
            },
            call("g"),
            Node::Stmt(DaStmt::Expr(DaExpr::Return(None))),
        ];
        let mut next = 2;
        cleanup(&mut body);
        assert!(!resolve(&mut body, Ctx::TopVoid, &mut next).unwrap());
        cleanup(&mut body);
        // The arm's labels now sit in the body, the region's end with them.
        assert!(matches!(&body[0], Node::If { then, .. } if matches!(then[..], [Node::Goto(_)])));
        assert!(body.iter().any(|node| matches!(node, Node::Label(1))));
        assert!(check(&body, Ctx::TopVoid).is_ok());
    }

    #[test]
    fn the_checker_refuses_a_jump_out_of_a_labelled_arm() {
        let body = vec![
            Node::If {
                cond: DaExpr::Var("c".into()),
                then: vec![Node::Label(0), call("f"), Node::Goto(1)],
                else_: vec![],
            },
            Node::Label(1),
            Node::Stmt(DaStmt::Expr(DaExpr::Return(Some(Box::new(
                DaExpr::ConstInt(0),
            ))))),
        ];
        assert!(check(&body, Ctx::TopValue).is_err());
    }
}
