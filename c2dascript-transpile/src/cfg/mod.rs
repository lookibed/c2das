//! Control Flow Graph — CfgBuilder + relooper pipeline.
//! Pipeline: C statements → CfgBuilder → Cfg → relooper → structures → DaStmt

use crate::c_ast::iterators::{DFExpr, SomeId};
use crate::c_ast::*;
use crate::diagnostics::TranslationResult;
use crate::translator::*;
use crate::with_stmts::WithStmts;
use crate::translator::value_lowering::ValueSite;
use das_ast::{DaBlock, DaExpr, DaStmt, DaType, DaTypeKind};
use indexmap::{indexset, IndexMap, IndexSet};
use std::collections::hash_map::DefaultHasher;
use std::fmt::{self, Debug, Display, Formatter};
use std::hash::{Hash, Hasher};
use std::rc::Rc;

pub mod inc_cleanup;
pub mod loops;
pub mod multiples;
pub mod relooper;
pub mod structures;

use crate::cfg::inc_cleanup::IncCleanup;
use crate::cfg::loops::*;
use crate::cfg::multiples::*;

// ===== Types (shared with submodules) =====

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Label {
    FromC(CLabelId, Option<Rc<str>>),
    Synthetic(u64),
}
impl Display for Label {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        match self {
            Self::FromC(_, Some(n)) => write!(f, "_{n}"),
            Self::FromC(id, None) => write!(f, "c_{}", id.0),
            Self::Synthetic(id) => write!(f, "s_{id}"),
        }
    }
}
impl fmt::Debug for Label {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        Display::fmt(self, f)
    }
}
impl Label {
    pub fn pretty_print(&self) -> String {
        self.to_string()
    }
    fn debug_print(&self) -> String {
        self.pretty_print().trim_start_matches('\'').to_string()
    }
    fn to_num_expr(&self) -> DaExpr {
        let mut s = DefaultHasher::new();
        self.hash(&mut s);
        DaExpr::ConstUInt(s.finish())
    }
}

#[derive(Clone, Debug)]
pub enum StructureLabel<S> {
    GoTo(Label),
    ExitTo(Label),
    Nested(Vec<Structure<S>>),
}

#[derive(Clone, Debug)]
pub enum Structure<Stmt> {
    Simple {
        entries: IndexSet<Label>,
        body: Vec<Stmt>,
        terminator: GenTerminator<StructureLabel<Stmt>>,
    },
    Loop {
        entries: IndexSet<Label>,
        body: Vec<Structure<Stmt>>,
    },
    Multiple {
        entries: IndexSet<Label>,
        branches: IndexMap<Label, Vec<Structure<Stmt>>>,
    },
}

#[derive(Clone, Debug)]
pub struct BasicBlock<L, S> {
    pub body: Vec<S>,
    pub terminator: GenTerminator<L>,
    pub live: IndexSet<CDeclId>,
    pub defined: IndexSet<CDeclId>,
}

#[derive(Clone, Debug)]
pub enum GenTerminator<Lbl> {
    End,
    Jump(Lbl),
    Branch(DaExpr, Lbl, Lbl),
    Switch {
        expr: DaExpr,
        cases: Vec<(DaExpr, Lbl)>,
    },
}
use self::GenTerminator::*;

impl<L> GenTerminator<L> {
    pub fn map_labels<F: Fn(&L) -> N, N>(&self, f: F) -> GenTerminator<N> {
        match self {
            End => End,
            Jump(l) => Jump(f(l)),
            Branch(e, l1, l2) => Branch(e.clone(), f(l1), f(l2)),
            Switch { expr, cases } => Switch {
                expr: expr.clone(),
                cases: cases.iter().map(|(e, l)| (e.clone(), f(l))).collect(),
            },
        }
    }
    pub fn get_labels(&self) -> Vec<&L> {
        match self {
            End => vec![],
            Jump(l) => vec![l],
            Branch(_, l1, l2) => vec![l1, l2],
            Switch { cases, .. } => cases.iter().map(|(_, l)| l).collect(),
        }
    }
    pub fn get_labels_mut(&mut self) -> Vec<&mut L> {
        match self {
            End => vec![],
            Jump(l) => vec![l],
            Branch(_, l1, l2) => vec![l1, l2],
            Switch { cases, .. } => cases.iter_mut().map(|(_, l)| l).collect(),
        }
    }
}

#[derive(Clone, Debug)]
pub enum StmtOrDecl {
    Stmt(DaStmt),
    Decl(CDeclId),
}
impl StmtOrDecl {
    pub fn place_decls(self, lf: &IndexSet<CDeclId>, st: &mut DeclStmtStore) -> Vec<DaStmt> {
        match self {
            StmtOrDecl::Stmt(s) => vec![s],
            StmtOrDecl::Decl(d) if lf.contains(&d) => {
                st.extract_assign(d).unwrap().into_iter().collect()
            }
            StmtOrDecl::Decl(d) => st.extract_decl_and_assign(d).unwrap().into_iter().collect(),
        }
    }
}
impl Structure<StmtOrDecl> {
    pub fn place_decls(self, lf: &IndexSet<CDeclId>, st: &mut DeclStmtStore) -> Structure<DaStmt> {
        match self {
            Structure::Simple {
                entries,
                body,
                terminator,
            } => Structure::Simple {
                entries,
                body: body
                    .into_iter()
                    .flat_map(|s| s.place_decls(lf, st))
                    .collect(),
                terminator: terminator.place_decls(lf, st),
            },
            Structure::Loop { entries, body } => Structure::Loop {
                entries,
                body: body.into_iter().map(|s| s.place_decls(lf, st)).collect(),
            },
            Structure::Multiple { entries, branches } => Structure::Multiple {
                entries,
                branches: branches
                    .into_iter()
                    .map(|(l, vs)| (l, vs.into_iter().map(|s| s.place_decls(lf, st)).collect()))
                    .collect(),
            },
        }
    }
}
impl GenTerminator<StructureLabel<StmtOrDecl>> {
    pub fn place_decls(
        self,
        lf: &IndexSet<CDeclId>,
        st: &mut DeclStmtStore,
    ) -> GenTerminator<StructureLabel<DaStmt>> {
        match self {
            End => End,
            Jump(l) => Jump(l.place_decls(lf, st)),
            Branch(e, l1, l2) => Branch(e, l1.place_decls(lf, st), l2.place_decls(lf, st)),
            Switch { expr, cases } => Switch {
                expr,
                cases: cases
                    .into_iter()
                    .map(|(e, l)| (e, l.place_decls(lf, st)))
                    .collect(),
            },
        }
    }
}
impl StructureLabel<StmtOrDecl> {
    pub fn place_decls(
        self,
        lf: &IndexSet<CDeclId>,
        st: &mut DeclStmtStore,
    ) -> StructureLabel<DaStmt> {
        match self {
            StructureLabel::GoTo(l) => StructureLabel::GoTo(l),
            StructureLabel::ExitTo(l) => StructureLabel::ExitTo(l),
            StructureLabel::Nested(vs) => {
                StructureLabel::Nested(vs.into_iter().map(|s| s.place_decls(lf, st)).collect())
            }
        }
    }
}
impl<S1, S2> BasicBlock<StructureLabel<S1>, S2> {
    pub fn successors(&self) -> IndexSet<Label> {
        self.terminator
            .get_labels()
            .iter()
            .filter_map(|sl| match sl {
                StructureLabel::GoTo(t) => Some(t.clone()),
                _ => None,
            })
            .collect()
    }
}

#[derive(Clone, Debug)]
pub struct Cfg<Lbl: Ord + Hash, Stmt> {
    pub entries: Lbl,
    pub nodes: IndexMap<Lbl, BasicBlock<Lbl, Stmt>>,
    pub loops: LoopInfo<Lbl>,
    pub multiples: MultipleInfo<Lbl>,
}

#[derive(Clone, Debug)]
pub enum ImplicitReturnType {
    Main,
    Void,
    NoImplicitReturnType,
    StmtExpr(ExprContext, CExprId, Label),
    StmtExprVoid,
}
#[derive(Clone, Debug, Default)]
pub struct SwitchCases {
    cases: Vec<(DaExpr, Label)>,
    default: Option<Label>,
}
#[derive(Clone, Debug, Default)]
pub struct DeclStmtStore {
    store: IndexMap<CDeclId, DeclStmtInfo>,
}
#[derive(Clone, Debug)]
pub struct DeclStmtInfo {
    pub decl: Option<Vec<DaStmt>>,
    pub assign: Option<Vec<DaStmt>>,
    pub decl_and_assign: Option<Vec<DaStmt>>,
}
impl DeclStmtInfo {
    pub fn new(d: Vec<DaStmt>, a: Vec<DaStmt>, da: Vec<DaStmt>) -> Self {
        Self {
            decl: Some(d),
            assign: Some(a),
            decl_and_assign: Some(da),
        }
    }
    pub fn empty() -> Self {
        Self {
            decl: Some(vec![]),
            assign: Some(vec![]),
            decl_and_assign: Some(vec![]),
        }
    }
}
impl DeclStmtStore {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn absorb(&mut self, o: Self) {
        self.store.extend(o.store);
    }
    pub fn extract_decl(&mut self, id: CDeclId) -> TranslationResult<Vec<DaStmt>> {
        let DeclStmtInfo {
            decl,
            assign,
            ..
        } = self
            .store
            .swap_remove(&id)
            .ok_or_else(|| TranslationError::generic("decl info not found"))?;

        let decl = decl.ok_or_else(|| TranslationError::generic("decl already extracted"))?;

        self.store.insert(
            id,
            DeclStmtInfo {
                decl: None,
                assign,
                decl_and_assign: None,
            },
        );
        Ok(decl)
    }
    pub fn extract_assign(&mut self, id: CDeclId) -> TranslationResult<Vec<DaStmt>> {
        let DeclStmtInfo {
            decl,
            assign,
            ..
        } = self
            .store
            .swap_remove(&id)
            .ok_or_else(|| TranslationError::generic("assign info not found"))?;

        let assign =
            assign.ok_or_else(|| TranslationError::generic("assign already extracted"))?;

        self.store.insert(
            id,
            DeclStmtInfo {
                decl,
                assign: None,
                decl_and_assign: None,
            },
        );
        Ok(assign)
    }
    pub fn extract_decl_and_assign(&mut self, id: CDeclId) -> TranslationResult<Vec<DaStmt>> {
        let DeclStmtInfo {
            decl_and_assign, ..
        } = self
            .store
            .swap_remove(&id)
            .ok_or_else(|| TranslationError::generic("decl+assign info not found"))?;

        let decl_and_assign = decl_and_assign
            .ok_or_else(|| TranslationError::generic("decl+assign already extracted"))?;

        self.store.insert(
            id,
            DeclStmtInfo {
                decl: None,
                assign: None,
                decl_and_assign: None,
            },
        );
        Ok(decl_and_assign)
    }
}

// ===== CfgBuilder =====

/// Builds a CFG from C statements. Each label/goto boundary splits into a BasicBlock.
struct CfgBuilder {
    nodes: IndexMap<Label, BasicBlock<Label, StmtOrDecl>>,
    decls_seen: DeclStmtStore,
    loops: LoopInfo<Label>,
    multiples: MultipleInfo<Label>,
    break_labels: Vec<Label>,
    continue_labels: Vec<Label>,
    currently_live: Vec<IndexSet<CDeclId>>,
    next: u64,
}

/// A WIP block under construction.
struct WipBlock {
    label: Label,
    body: Vec<StmtOrDecl>,
    defined: IndexSet<CDeclId>,
    live: IndexSet<CDeclId>,
}

impl CfgBuilder {
    fn new(entry: Label) -> Self {
        CfgBuilder {
            nodes: IndexMap::new(),
            decls_seen: DeclStmtStore::new(),
            loops: LoopInfo::new(),
            multiples: MultipleInfo::new(),
            break_labels: vec![],
            continue_labels: vec![],
            currently_live: vec![IndexSet::new()],
            next: 1,
        }
    }

    fn fresh_label(&mut self) -> Label {
        let lbl = Label::Synthetic(self.next);
        self.next += 1;
        lbl
    }

    fn new_wip(&mut self, lbl: Label) -> WipBlock {
        WipBlock {
            label: lbl,
            body: vec![],
            defined: IndexSet::new(),
            live: self.currently_live.last().cloned().unwrap_or_default(),
        }
    }

    fn with_scope<T, F>(&mut self, f: F) -> TranslationResult<T>
    where
        F: FnOnce(&mut Self) -> TranslationResult<T>,
    {
        self.currently_live.push(IndexSet::new());
        let result = f(self);
        self.currently_live.pop();
        result
    }

    fn add_decl_to_scope(&mut self, decl: CDeclId) {
        for live in &mut self.currently_live {
            live.insert(decl);
        }
    }

    fn add_block(&mut self, wip: WipBlock, term: GenTerminator<Label>) {
        self.nodes.insert(
            wip.label,
            BasicBlock {
                body: wip.body,
                terminator: term,
                live: wip.live,
                defined: wip.defined,
            },
        );
    }

    fn add_condition_branch(
        &mut self,
        entry: Label,
        cond_ws: WithStmts<DaExpr>,
        true_entry: Label,
        false_entry: Label,
    ) {
        if cond_ws.stmts.is_empty() {
            let wip = self.new_wip(entry);
            self.add_block(wip, Branch(cond_ws.val, true_entry, false_entry));
            return;
        }

        let cond_entry = self.fresh_label();
        let mut prelude = self.new_wip(entry);
        prelude
            .body
            .extend(cond_ws.stmts.into_iter().map(StmtOrDecl::Stmt));
        self.add_block(prelude, Jump(cond_entry.clone()));

        let wip = self.new_wip(cond_entry);
        self.add_block(wip, Branch(cond_ws.val, true_entry, false_entry));
    }

    /// Process a sequence of C statements and build the CFG.
    /// Returns the label after the last statement (for fallthrough).
    fn convert_stmts(
        &mut self,
        tr: &Translation,
        ctx: ExprContext,
        stmts: &[CStmtId],
        in_tail: Option<&ImplicitReturnType>,
        entry: Label,
        ret_ty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<Label>> {
        self.with_scope(|slf| {
            let mut lbl = Some(entry);
            let last = stmts.last().copied();
            for &sid in stmts {
                let new_entry = lbl.unwrap_or_else(|| slf.fresh_label());
                let tail = in_tail.filter(|_| Some(sid) == last);
                lbl = slf.convert_stmt(tr, ctx, sid, tail, new_entry, ret_ty)?;
            }
            Ok(lbl)
        })
    }

    /// Process a single C statement. Returns Some(label) for fallthrough, None if terminated.
    fn convert_stmt(
        &mut self,
        tr: &Translation,
        ctx: ExprContext,
        sid: CStmtId,
        in_tail: Option<&ImplicitReturnType>,
        entry: Label,
        ret_ty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<Label>> {
        let sk = &tr.ast_context[sid].kind;
        match sk {
            CStmtKind::Empty => Ok(Some(entry)),

            CStmtKind::Expr(eid) => {
                let ws = tr.convert_expr(
                    ExprContext {
                        used: false,
                        is_const: false,
                        ..Default::default()
                    },
                    *eid,
                    None,
                )?;
                let mut wip = self.new_wip(entry);
                wip.body.extend(ws.stmts.into_iter().map(StmtOrDecl::Stmt));
                wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(ws.val)));
                let next = self.fresh_label();
                self.add_block(wip, Jump(next.clone()));
                Ok(Some(next))
            }

            CStmtKind::Return(ref expr_opt) => {
                let mut wip = self.new_wip(entry);
                let val: Option<Box<DaExpr>> = match expr_opt {
                    Some(e) => {
                        let ws = tr.convert_expr(ExprContext::default().used(), *e, None)?;
                        let val = if let Some(ret_ty) = ret_ty {
                            let ret_da = tr.convert_type(ret_ty)?;
                            let ws = tr.lower_to_c_value(
                                ws,
                                tr.ast_context[*e].kind.get_qual_type(),
                                ret_da.clone(),
                                ValueSite::Return,
                            )?;
                            wip.body.extend(ws.stmts.into_iter().map(StmtOrDecl::Stmt));
                            let expr_is_ptr = tr.ast_context[*e]
                                .kind
                                .get_qual_type()
                                .map_or(false, |qty| tr.is_pointer_type(qty.ctype));
                            if matches!(ret_da.kind, DaTypeKind::UInt64) && expr_is_ptr {
                                DaExpr::Unsafe(Box::new(DaExpr::Cast {
                                    kind: das_ast::CastKind::Reinterpret,
                                    expr: Box::new(ws.val),
                                    to: DaType::uint64(),
                                }))
                            } else if matches!(ret_da.kind, DaTypeKind::Pointer(_)) {
                                DaExpr::Unsafe(Box::new(DaExpr::Cast {
                                    kind: das_ast::CastKind::Reinterpret,
                                    expr: Box::new(ws.val),
                                    to: ret_da,
                                }))
                            } else {
                                ws.val
                            }
                        } else {
                            wip.body.extend(ws.stmts.into_iter().map(StmtOrDecl::Stmt));
                            ws.val
                        };
                        Some(Box::new(val))
                    }
                    None => None,
                };
                wip.body
                    .push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Return(val))));
                self.add_block(wip, End);
                Ok(None)
            }

            CStmtKind::Compound(ref kids) => {
                self.convert_stmts(tr, ctx, kids, in_tail, entry, ret_ty)
            }

            CStmtKind::Decls(ref decls) => {
                let mut current_entry = entry;
                for &d in decls {
                    let info = tr.convert_decl_stmt_info(ctx, d)?;
                    self.decls_seen.store.insert(d, info);
                    let mut wip = self.new_wip(current_entry);
                    wip.body.push(StmtOrDecl::Decl(d));
                    wip.defined.insert(d);
                    self.add_decl_to_scope(d);
                    wip.live = self.currently_live.last().cloned().unwrap_or_default();
                    let next = self.fresh_label();
                    self.add_block(wip, Jump(next.clone()));
                    current_entry = next;
                }
                Ok(Some(current_entry))
            }

            CStmtKind::If {
                scrutinee,
                true_variant,
                false_variant,
            } => {
                let cond_ws = tr.convert_condition(ctx.used(), true, *scrutinee)?;

                let then_entry = self.fresh_label();
                let else_entry = self.fresh_label();
                let next_entry = self.fresh_label();

                // Condition block: Branch(cond, then_entry, else_entry)
                self.add_condition_branch(entry, cond_ws, then_entry.clone(), else_entry.clone());

                // Then block
                let then_ends =
                    self.convert_stmt(tr, ctx, *true_variant, in_tail, then_entry, ret_ty)?;
                if let Some(end) = then_ends {
                    let wip = self.new_wip(end);
                    self.add_block(wip, Jump(next_entry.clone()));
                }

                // Else block
                let else_ends = match false_variant {
                    Some(fv) => self.convert_stmt(tr, ctx, *fv, in_tail, else_entry, ret_ty)?,
                    None => Some(else_entry),
                };
                if let Some(end) = else_ends {
                    let wip = self.new_wip(end);
                    self.add_block(wip, Jump(next_entry.clone()));
                }

                Ok(Some(next_entry))
            }

            CStmtKind::While { condition, body } => {
                let cond_entry = self.fresh_label();
                let body_entry = self.fresh_label();
                let post = self.fresh_label();
                self.break_labels.push(post.clone());
                self.continue_labels.push(cond_entry.clone());

                // Entry → cond_entry
                let wip0 = self.new_wip(entry);
                self.add_block(wip0, Jump(cond_entry.clone()));

                // cond_entry: convert condition, Branch to body or post
                let cond_ws = tr.convert_condition(ctx.used(), true, *condition)?;
                self.add_condition_branch(
                    cond_entry.clone(),
                    cond_ws,
                    body_entry.clone(),
                    post.clone(),
                );

                // body
                let body_end = self.convert_stmt(tr, ctx, *body, None, body_entry, ret_ty)?;
                if let Some(end) = body_end {
                    let wip = self.new_wip(end);
                    self.add_block(wip, Jump(cond_entry.clone()));
                }

                self.break_labels.pop();
                self.continue_labels.pop();
                Ok(Some(post))
            }

            CStmtKind::DoWhile { body, condition } => {
                let body_entry = self.fresh_label();
                let cond_entry = self.fresh_label();
                let post = self.fresh_label();
                self.break_labels.push(post.clone());
                self.continue_labels.push(cond_entry.clone());

                // Entry → body_entry
                let wip0 = self.new_wip(entry);
                self.add_block(wip0, Jump(body_entry.clone()));

                // body
                let body_end =
                    self.convert_stmt(tr, ctx, *body, None, body_entry.clone(), ret_ty)?;
                if let Some(end) = body_end {
                    let wip = self.new_wip(end);
                    self.add_block(wip, Jump(cond_entry.clone()));
                }

                // cond_entry: convert condition, Branch to body or post
                let cond_ws = tr.convert_condition(ctx.used(), true, *condition)?;
                self.add_condition_branch(cond_entry, cond_ws, body_entry.clone(), post.clone());

                self.break_labels.pop();
                self.continue_labels.pop();
                Ok(Some(post))
            }

            CStmtKind::ForLoop {
                init,
                condition,
                increment,
                body,
            } => {
                // Init
                if let Some(iid) = init {
                    let ientry = self.fresh_label();
                    let wip = self.new_wip(ientry.clone());
                    self.add_block(wip, Jump(entry.clone()));
                    let r = self.convert_stmt(tr, ctx, *iid, None, ientry, ret_ty)?;
                }

                let cond_entry = self.fresh_label();
                let body_entry = self.fresh_label();
                let post_body = self.fresh_label();
                let after = self.fresh_label();
                self.break_labels.push(after.clone());
                self.continue_labels.push(cond_entry.clone());

                // cond_entry: Branch(condition, body_entry, after) or Jump(body_entry)
                let _cond_next: Option<()> = match condition {
                    Some(cid) => {
                        let cond_ws = tr.convert_condition(ctx.used(), true, *cid)?;
                        let next_after = after.clone();
                        self.add_condition_branch(
                            cond_entry.clone(),
                            cond_ws,
                            body_entry.clone(),
                            next_after,
                        );
                        None
                    }
                    None => {
                        let wip = self.new_wip(cond_entry.clone());
                        self.add_block(wip, Jump(body_entry.clone()));
                        None
                    }
                };

                // body
                let body_end = self.convert_stmt(tr, ctx, *body, None, body_entry, ret_ty)?;
                if let Some(end) = body_end {
                    // Increment at end of body
                    let mut wip = self.new_wip(end);
                    if let Some(inc_id) = increment {
                        let inc_ws = tr.convert_expr(ctx.unused(), *inc_id, None)?;
                        wip.body
                            .extend(inc_ws.stmts.into_iter().map(StmtOrDecl::Stmt));
                        wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(inc_ws.val)));
                    }
                    self.add_block(wip, Jump(cond_entry.clone()));
                }

                self.break_labels.pop();
                self.continue_labels.pop();
                Ok(Some(after))
            }

            CStmtKind::Switch { scrutinee, body } => {
                let scrut_ws = tr.convert_expr(ctx.used(), *scrutinee, None)?;
                let switch_end = self.fresh_label();
                self.break_labels.push(switch_end.clone());

                let body_entry = self.fresh_label();
                // scrutinee block
                {
                    let mut wip = self.new_wip(entry);
                    wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(scrut_ws.val)));
                    self.add_block(wip, Jump(body_entry.clone()));
                }

                // body (cases/default are inside)
                let _body_end = self.convert_stmt(tr, ctx, *body, None, body_entry, ret_ty)?;

                let brk = self.break_labels.pop().unwrap();
                Ok(Some(brk))
            }

            CStmtKind::Case(_expr, sub_stmt, _) => {
                // daScript doesn't have switch/case, handled by convert_stmt directly
                self.convert_stmt(tr, ctx, *sub_stmt, in_tail, entry, ret_ty)
            }

            CStmtKind::Default(sub_stmt) => {
                self.convert_stmt(tr, ctx, *sub_stmt, in_tail, entry, ret_ty)
            }

            CStmtKind::Goto(target) => {
                let target_lbl =
                    Label::FromC(*target, tr.ast_context.label_names.get(target).cloned());
                let mut wip = self.new_wip(entry);
                wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Goto(
                    target_lbl.pretty_print(),
                ))));
                self.add_block(wip, End);
                Ok(None)
            }

            CStmtKind::Label(sub_stmt) => {
                let clbl: CLabelId = sid.into();
                let lbl = Label::FromC(clbl, tr.ast_context.label_names.get(&clbl).cloned());
                let mut wip = self.new_wip(entry);
                let next = self.fresh_label();
                self.add_block(wip, Jump(next.clone()));
                self.convert_stmt(tr, ctx, *sub_stmt, in_tail, lbl, ret_ty)
            }

            CStmtKind::Break => {
                let brk = self
                    .break_labels
                    .last()
                    .cloned()
                    .ok_or_else(|| TranslationError::generic("break outside loop"))?;
                let mut wip = self.new_wip(entry);
                wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Break)));
                self.add_block(wip, Jump(brk));
                Ok(None)
            }

            CStmtKind::Continue => {
                let cont = self
                    .continue_labels
                    .last()
                    .cloned()
                    .ok_or_else(|| TranslationError::generic("continue outside loop"))?;
                let mut wip = self.new_wip(entry);
                wip.body
                    .push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Continue)));
                self.add_block(wip, Jump(cont));
                Ok(None)
            }

            _ => Err(TranslationError::generic(
                "unsupported statement in CfgBuilder",
            )),
        }
    }
}

// ===== Cfg::from_stmts =====

impl Cfg<Label, StmtOrDecl> {
    /// Build a CFG from a list of C statements.
    /// Uses CfgBuilder internally.
    pub fn from_stmts(
        translator: &Translation,
        ctx: ExprContext,
        stmt_ids: &[CStmtId],
        ret: ImplicitReturnType,
        ret_ty: Option<CQualTypeId>,
    ) -> TranslationResult<(Self, DeclStmtStore)> {
        let entry = Label::Synthetic(0);
        let mut builder = CfgBuilder::new(entry.clone());

        let last_lbl =
            builder.convert_stmts(translator, ctx, stmt_ids, Some(&ret), entry.clone(), ret_ty)?;

        // Add implicit return at the end
        let exit_lbl = last_lbl.unwrap_or_else(|| builder.fresh_label());
        let _term: Option<()> = match &ret {
            ImplicitReturnType::Main => {
                let mut wip = builder.new_wip(exit_lbl);
                wip.body
                    .push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Return(Some(
                        Box::new(DaExpr::ConstInt(0)),
                    )))));
                builder.add_block(wip, End);
                None
            }
            ImplicitReturnType::Void => {
                let mut wip = builder.new_wip(exit_lbl);
                wip.body
                    .push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Return(None))));
                builder.add_block(wip, End);
                None
            }
            _ => {
                let mut wip = builder.new_wip(exit_lbl);
                wip.body
                    .push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Return(None))));
                builder.add_block(wip, End);
                None
            }
        };

        let cfg = Cfg {
            entries: entry,
            nodes: builder.nodes,
            loops: builder.loops,
            multiples: builder.multiples,
        };

        Ok((cfg, builder.decls_seen))
    }
}

/// Prune unreachable and empty blocks from the CFG.
impl<Lbl: Clone + Ord + Hash + Debug, Stmt> Cfg<Lbl, Stmt> {
    fn prune_unreachable(&mut self) {
        let visited: IndexSet<Lbl> = {
            let mut v = IndexSet::new();
            let mut q = vec![self.entries.clone()];
            while let Some(l) = q.pop() {
                if !v.insert(l.clone()) {
                    continue;
                }
                if let Some(bb) = self.nodes.get(&l) {
                    for n in bb.terminator.get_labels() {
                        if !v.contains(n) {
                            q.push(n.clone());
                        }
                    }
                }
            }
            v
        };
        self.nodes.retain(|l, _| visited.contains(l));
        self.loops.filter_unreachable(&visited);
    }
}

// ===== Public entry point =====

/// Convert a function body — simple path.
/// daScript has native goto/label/break/continue, so the relooper
/// is not needed for control flow restructuring.
/// The CFG types and submodule algorithms (relooper, structures, etc.)
/// are available for future optimizations if needed.
pub fn convert_function_body(
    translator: &Translation,
    _body_id: CStmtId,
    stmts: &[CStmtId],
    ret: ImplicitReturnType,
    ret_ty: Option<CQualTypeId>,
) -> TranslationResult<Vec<DaStmt>> {
    let (mut graph, store) = Cfg::from_stmts(translator, ExprContext::default(), stmts, ret, ret_ty)?;
    graph.prune_unreachable();

    let (lifted_stmts, mut relooped) =
        crate::cfg::relooper::reloop(graph, store, true, true, IndexSet::new());
    relooped = crate::cfg::relooper::simplify_structure(relooped);

    let mut cfg_info = crate::cfg::structures::CfgInfo::default();
    crate::cfg::structures::gather_cfg_info(&relooped, &mut cfg_info);

    let current_block_name = translator.renamer.borrow_mut().pick_name("c2da_current_block");
    let current_block_expr = DaExpr::Var(current_block_name.clone());

    let mut stmts_out = lifted_stmts;
    if !cfg_info.checked_entries.is_empty() {
        stmts_out.push(DaStmt::Var {
            name: current_block_name,
            var_type: DaType::uint64(),
            init: None,
        });
    }

    stmts_out.extend(crate::cfg::structures::structured_cfg(
        &relooped,
        &cfg_info,
        current_block_expr,
        false,
    )?);
    Ok(stmts_out)
}

fn has_gotos(ctx: &TypedAstContext, stmt: CStmtId) -> bool {
    for id in DFExpr::new(ctx, stmt.into()).flat_map(SomeId::stmt) {
        if matches!(ctx[id].kind, CStmtKind::Goto(_)) {
            return true;
        }
    }
    false
}
