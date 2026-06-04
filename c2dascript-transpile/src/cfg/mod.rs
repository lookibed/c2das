//! Control Flow Graph analysis — ported from c2rust.
//! Converts C statements into a CFG, runs the Relooper algorithm to produce
//! structured control flow, then converts to daScript statements.

use crate::c_ast::iterators::{DFExpr, SomeId};
use crate::c_ast::*;
use crate::diagnostics::TranslationResult;
use crate::translator::*;
use crate::with_stmts::WithStmts;
use das_ast::{DaBlock, DaExpr, DaStmt};
use indexmap::{indexset, IndexMap, IndexSet};
use std::collections::BTreeSet;
use std::collections::hash_map::DefaultHasher;
use std::rc::Rc;
use std::fmt::{self, Debug, Display, Formatter};
use std::hash::{Hash, Hasher};
use std::ops::Index;

mod inc_cleanup;
pub mod loops;
pub mod multiples;
pub mod relooper;
pub mod structures;

use crate::cfg::inc_cleanup::IncCleanup;
use crate::cfg::loops::*;
use crate::cfg::multiples::*;

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Label {
    FromC(CLabelId, Option<Rc<str>>),
    Synthetic(u64),
}

impl Display for Label {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        match self {
            Self::FromC(_, Some(name)) => write!(f, "_{name}"),
            Self::FromC(id, None) => write!(f, "c_{}", id.0),
            Self::Synthetic(id) => write!(f, "s_{id}"),
        }
    }
}

impl Debug for Label {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        Display::fmt(self, f)
    }
}

impl Label {
    pub fn pretty_print(&self) -> String {
        self.to_string()
    }

    fn debug_print(&self) -> String {
        String::from(self.pretty_print().trim_start_matches('\''))
    }

    fn to_num_expr(&self) -> DaExpr {
        let mut s = DefaultHasher::new();
        self.hash(&mut s);
        let as_num = s.finish();
        DaExpr::ConstUInt(as_num)
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
    body: Vec<S>,
    terminator: GenTerminator<L>,
    live: IndexSet<CDeclId>,
    defined: IndexSet<CDeclId>,
}

impl<L: Clone, S1> BasicBlock<L, S1> {
    fn map_stmts<S2, F: Fn(&S1) -> S2>(&self, f: F) -> BasicBlock<L, S2> {
        BasicBlock {
            body: self.body.iter().map(f).collect(),
            terminator: self.terminator.clone(),
            live: self.live.clone(),
            defined: self.defined.clone(),
        }
    }
}

impl<L, S> BasicBlock<L, S> {
    fn new(terminator: GenTerminator<L>) -> Self {
        BasicBlock {
            body: vec![],
            terminator,
            live: IndexSet::new(),
            defined: IndexSet::new(),
        }
    }

    fn new_jump(target: L) -> Self {
        BasicBlock::new(GenTerminator::Jump(target))
    }
}

impl Structure<StmtOrDecl> {
    fn place_decls(
        self,
        lift_me: &IndexSet<CDeclId>,
        store: &mut DeclStmtStore,
    ) -> Structure<DaStmt> {
        match self {
            Structure::Simple {
                entries,
                body,
                terminator,
            } => {
                let body = body
                    .into_iter()
                    .flat_map(|s: StmtOrDecl| -> Vec<DaStmt> { s.place_decls(lift_me, store) })
                    .collect();
                Structure::Simple {
                    entries,
                    body,
                    terminator: terminator.place_decls(lift_me, store),
                }
            }
            Structure::Loop { entries, body } => {
                let body = body
                    .into_iter()
                    .map(|s| s.place_decls(lift_me, store))
                    .collect();
                Structure::Loop { entries, body }
            }
            Structure::Multiple { entries, branches } => {
                let branches = branches
                    .into_iter()
                    .map(|(lbl, vs)| {
                        (
                            lbl,
                            vs.into_iter()
                                .map(|s| s.place_decls(lift_me, store))
                                .collect(),
                        )
                    })
                    .collect();
                Structure::Multiple { entries, branches }
            }
        }
    }
}

impl<S1, S2> BasicBlock<StructureLabel<S1>, S2> {
    fn successors(&self) -> IndexSet<Label> {
        self.terminator
            .get_labels()
            .iter()
            .filter_map(|slbl| match slbl {
                StructureLabel::GoTo(tgt) => Some(tgt.clone()),
                _ => None,
            })
            .collect()
    }
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
    fn map_labels<F: Fn(&L) -> N, N>(&self, func: F) -> GenTerminator<N> {
        match self {
            End => End,
            Jump(l) => Jump(func(l)),
            Branch(e, l1, l2) => Branch(e.clone(), func(l1), func(l2)),
            Switch { expr, cases } => Switch {
                expr: expr.clone(),
                cases: cases.iter().map(|(e, l)| (e.clone(), func(l))).collect(),
            },
        }
    }

    fn get_labels(&self) -> Vec<&L> {
        match self {
            End => vec![],
            Jump(l) => vec![l],
            Branch(_, l1, l2) => vec![l1, l2],
            Switch { cases, .. } => cases.iter().map(|(_, l)| l).collect(),
        }
    }

    fn get_labels_mut(&mut self) -> Vec<&mut L> {
        match self {
            End => vec![],
            Jump(l) => vec![l],
            Branch(_, l1, l2) => vec![l1, l2],
            Switch { cases, .. } => cases.iter_mut().map(|(_, l)| l).collect(),
        }
    }
}

impl GenTerminator<StructureLabel<StmtOrDecl>> {
    fn place_decls(
        self,
        lift_me: &IndexSet<CDeclId>,
        store: &mut DeclStmtStore,
    ) -> GenTerminator<StructureLabel<DaStmt>> {
        match self {
            End => End,
            Jump(l) => Jump(l.place_decls(lift_me, store)),
            Branch(e, l1, l2) => {
                Branch(e, l1.place_decls(lift_me, store), l2.place_decls(lift_me, store))
            }
            Switch { expr, cases } => {
                let cases = cases
                    .into_iter()
                    .map(|(e, l)| (e, l.place_decls(lift_me, store)))
                    .collect();
                Switch { expr, cases }
            }
        }
    }
}

impl StructureLabel<StmtOrDecl> {
    fn place_decls(
        self,
        lift_me: &IndexSet<CDeclId>,
        store: &mut DeclStmtStore,
    ) -> StructureLabel<DaStmt> {
        match self {
            StructureLabel::GoTo(l) => StructureLabel::GoTo(l),
            StructureLabel::ExitTo(l) => StructureLabel::ExitTo(l),
            StructureLabel::Nested(vs) => {
                let vs = vs
                    .into_iter()
                    .map(|s| s.place_decls(lift_me, store))
                    .collect();
                StructureLabel::Nested(vs)
            }
        }
    }
}

#[derive(Clone, Debug, Default)]
pub struct SwitchCases {
    cases: Vec<(DaExpr, Label)>,
    default: Option<Label>,
}

#[derive(Clone, Debug)]
pub enum StmtOrDecl {
    Stmt(DaStmt),
    Decl(CDeclId),
}

impl StmtOrDecl {
    fn place_decls(self, lift_me: &IndexSet<CDeclId>, store: &mut DeclStmtStore) -> Vec<DaStmt> {
        match self {
            StmtOrDecl::Stmt(s) => vec![s],
            StmtOrDecl::Decl(d) if lift_me.contains(&d) => {
                store.extract_assign(d).unwrap().into_iter().collect()
            }
            StmtOrDecl::Decl(d) => store
                .extract_decl_and_assign(d)
                .unwrap()
                .into_iter()
                .collect(),
        }
    }
}

#[derive(Clone, Debug)]
pub struct Cfg<Lbl: Ord + Hash, Stmt> {
    entries: Lbl,
    nodes: IndexMap<Lbl, BasicBlock<Lbl, Stmt>>,
    loops: LoopInfo<Lbl>,
    multiples: MultipleInfo<Lbl>,
}

impl<L: Clone + Ord + Hash, S1> Cfg<L, S1> {
    pub fn map_stmts<S2, F: Fn(&S1) -> S2>(&self, f: F) -> Cfg<L, S2> {
        let entries = self.entries.clone();
        let nodes = self
            .nodes
            .iter()
            .map(|(l, bb)| (l.clone(), bb.map_stmts(&f)))
            .collect();
        let loops = self.loops.clone();
        let multiples = self.multiples.clone();
        Cfg {
            entries,
            nodes,
            loops,
            multiples,
        }
    }
}

#[derive(Clone, Debug)]
pub enum ImplicitReturnType {
    Main,
    Void,
    NoImplicitReturnType,
    StmtExpr(ExprContext, CExprId, Label),
    StmtExprVoid,
}

impl Cfg<Label, StmtOrDecl> {
    pub fn from_stmts(
        translator: &Translation,
        ctx: ExprContext,
        stmt_ids: &[CStmtId],
        ret: ImplicitReturnType,
        ret_ty: Option<CQualTypeId>,
    ) -> TranslationResult<(Self, DeclStmtStore)> {
        let mut c_label_to_goto: IndexMap<CLabelId, IndexSet<CStmtId>> = IndexMap::new();
        for (target, x) in stmt_ids
            .iter()
            .flat_map(|&stmt_id| DFExpr::new(&translator.ast_context, stmt_id.into()))
            .flat_map(SomeId::stmt)
            .flat_map(|x| match translator.ast_context[x].kind {
                CStmtKind::Goto(target) => Some((target, x)),
                _ => None,
            })
        {
            c_label_to_goto.entry(target).or_default().insert(x);
        }

        let mut cfg_builder = CfgBuilder::new(c_label_to_goto);
        let entry = cfg_builder.entry.clone();
        cfg_builder.per_stmt_stack.push(PerStmt::new(
            stmt_ids.first().cloned(),
            entry.clone(),
            IndexSet::new(),
        ));

        translator.with_scope(|| -> TranslationResult<()> {
            let body_exit = cfg_builder.convert_stmts_help(
                translator,
                ctx,
                stmt_ids,
                Some(ret.clone()),
                entry,
                ret_ty,
            )?;

            if let Some(body_exit) = body_exit {
                let mut wip = cfg_builder.new_wip_block(body_exit);
                match ret {
                    ImplicitReturnType::Main => {
                        wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Return(Some(Box::new(DaExpr::ConstInt(0)))))));
                    }
                    ImplicitReturnType::Void => {
                        wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Return(None))));
                    }
                    ImplicitReturnType::NoImplicitReturnType => {
                        let ret_expr = translator.panic("Reached end of non-void function without returning");
                        wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Return(Some(ret_expr)))));
                    }
                    ImplicitReturnType::StmtExpr(ctx, expr_id, brk_label) => {
                        let (stmts, val) = translator
                            .convert_expr(ctx, expr_id, None)?
                            .discard_unsafe()
                            .into_stmts_and_val();
                        wip.body.extend(stmts.into_iter().map(StmtOrDecl::Stmt));
                        wip.body.push(StmtOrDecl::Stmt(DaStmt::Expr(DaExpr::Break)));
                    }
                    ImplicitReturnType::StmtExprVoid => (),
                };
                cfg_builder.add_wip_block(wip, End);
            }
            Ok(())
        })?;

        let last_per_stmt = cfg_builder.per_stmt_stack.pop().unwrap();
        let (graph, decls_seen, live_in) = last_per_stmt.into_cfg();
        assert!(live_in.is_empty(), "non-empty live_in");
        Ok((graph, decls_seen))
    }
}

impl<Lbl: Clone + Ord + Hash + Debug, Stmt> Cfg<Lbl, Stmt> {
    pub fn prune_unreachable_blocks_mut(&mut self) {
        let visited: IndexSet<Lbl> = {
            let mut visited: IndexSet<Lbl> = IndexSet::new();
            let mut to_visit: Vec<Lbl> = vec![self.entries.clone()];
            while let Some(lbl) = to_visit.pop() {
                if visited.contains(&lbl) {
                    continue;
                }
                let blk = self.nodes.get(&lbl).unwrap_or_else(|| {
                    panic!("prune_unreachable_blocks: block not found")
                });
                visited.insert(lbl);
                for lbl in blk.terminator.get_labels() {
                    if !visited.contains(lbl) {
                        to_visit.push(lbl.clone());
                    }
                }
            }
            visited
        };
        self.nodes.retain(|lbl, _| visited.contains(lbl));
        self.loops.filter_unreachable(&visited);
    }

    pub fn prune_empty_blocks_mut(&mut self) {
        let mut proposed_rewrites: IndexMap<Lbl, Lbl> = self
            .nodes
            .iter()
            .filter_map(|(lbl, bb)| Cfg::empty_bb(bb).map(|tgt| (lbl.clone(), tgt)))
            .collect();
        let mut actual_rewrites: IndexMap<Lbl, Lbl> = IndexMap::new();
        while let Some((from, to)) = proposed_rewrites
            .iter()
            .map(|(f, t)| (f.clone(), t.clone()))
            .next()
        {
            proposed_rewrites.swap_remove(&from);
            let mut from_any: IndexSet<Lbl> = indexset![from];
            let mut to_intermediate: Lbl = to;
            while let Some(to_new) = proposed_rewrites.swap_remove(&to_intermediate) {
                from_any.insert(to_intermediate);
                to_intermediate = to_new;
            }
            let to_final = match actual_rewrites.get(&to_intermediate) {
                None => to_intermediate,
                Some(to_final) => {
                    from_any.insert(to_intermediate);
                    to_final.clone()
                }
            };
            for from in from_any {
                if from != to_final {
                    actual_rewrites.insert(from, to_final.clone());
                }
            }
        }
        self.entries = actual_rewrites
            .get(&self.entries)
            .unwrap_or(&self.entries)
            .clone();
        self.nodes
            .retain(|lbl, _| actual_rewrites.get(lbl).is_none());
        for bb in self.nodes.values_mut() {
            for lbl in bb.terminator.get_labels_mut() {
                if let Some(new_lbl) = actual_rewrites.get(lbl) {
                    *lbl = new_lbl.clone();
                }
            }
        }
        self.loops.rewrite_blocks(&actual_rewrites);
        self.multiples.rewrite_blocks(&actual_rewrites);
    }

    fn empty_bb(bb: &BasicBlock<Lbl, Stmt>) -> Option<Lbl> {
        match &bb.terminator {
            Jump(lbl) if bb.body.is_empty() => Some(lbl.clone()),
            _ => None,
        }
    }
}

#[derive(Clone, Debug)]
struct CfgBuilder {
    entry: Label,
    per_stmt_stack: Vec<PerStmt>,
    currently_live: Vec<IndexSet<CDeclId>>,
    break_labels: Vec<Label>,
    continue_labels: Vec<Label>,
    switch_expr_cases: Vec<SwitchCases>,
    prev_label: u64,
    prev_loop_id: u64,
    c_label_to_goto: IndexMap<CLabelId, IndexSet<CStmtId>>,
    loops: Vec<(LoopId, Vec<Label>)>,
    multiples: Vec<(Label, Vec<Label>)>,
}

#[derive(Debug, Clone)]
struct PerStmt {
    stmt_id: Option<CStmtId>,
    entry: Label,
    nodes: IndexMap<Label, BasicBlock<Label, StmtOrDecl>>,
    loop_info: LoopInfo<Label>,
    multiple_info: MultipleInfo<Label>,
    decls_seen: DeclStmtStore,
    saw_unmatched_break: bool,
    saw_unmatched_continue: bool,
    saw_unmatched_default: bool,
    saw_unmatched_case: bool,
    c_labels_defined: IndexSet<CLabelId>,
    c_labels_used: IndexMap<CLabelId, IndexSet<CStmtId>>,
    live_in: IndexSet<CDeclId>,
}

impl PerStmt {
    pub fn new(stmt_id: Option<CStmtId>, entry: Label, live_in: IndexSet<CDeclId>) -> PerStmt {
        PerStmt {
            stmt_id,
            entry,
            nodes: IndexMap::new(),
            loop_info: LoopInfo::new(),
            multiple_info: MultipleInfo::new(),
            decls_seen: DeclStmtStore::new(),
            saw_unmatched_break: false,
            saw_unmatched_continue: false,
            saw_unmatched_default: false,
            saw_unmatched_case: false,
            c_labels_defined: IndexSet::new(),
            c_labels_used: IndexMap::new(),
            live_in,
        }
    }

    pub fn absorb(&mut self, other: PerStmt) {
        self.nodes.extend(other.nodes);
        self.loop_info.absorb(other.loop_info);
        self.multiple_info.absorb(other.multiple_info);
        self.decls_seen.absorb(other.decls_seen);
        self.saw_unmatched_break |= other.saw_unmatched_break;
        self.saw_unmatched_continue |= other.saw_unmatched_continue;
        self.saw_unmatched_default |= other.saw_unmatched_default;
        self.saw_unmatched_case |= other.saw_unmatched_case;
        self.c_labels_defined.extend(other.c_labels_defined);
        self.c_labels_used.extend(other.c_labels_used);
    }

    pub fn is_contained(
        &self,
        c_label_to_goto: &IndexMap<CLabelId, IndexSet<CStmtId>>,
        currently_live: &IndexSet<CDeclId>,
    ) -> bool {
        if self.saw_unmatched_break
            || self.saw_unmatched_continue
            || self.saw_unmatched_case
            || self.saw_unmatched_default
        {
            return false;
        }
        if self
            .c_labels_used
            .keys()
            .cloned()
            .collect::<IndexSet<CLabelId>>()
            != self.c_labels_defined
        {
            return false;
        }
        if self
            .c_labels_used
            .iter()
            .any(|(lbl, gotos)| c_label_to_goto.get(lbl) != Some(gotos))
        {
            return false;
        }
        if &self.live_in != currently_live {
            return false;
        }
        true
    }

    pub fn into_cfg(self) -> (Cfg<Label, StmtOrDecl>, DeclStmtStore, IndexSet<CDeclId>) {
        let mut graph = Cfg {
            entries: self.entry,
            nodes: self.nodes,
            loops: self.loop_info,
            multiples: self.multiple_info,
        };
        graph.prune_empty_blocks_mut();
        graph.prune_unreachable_blocks_mut();
        (graph, self.decls_seen, self.live_in)
    }
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
    pub fn new(decl: Vec<DaStmt>, assign: Vec<DaStmt>, decl_and_assign: Vec<DaStmt>) -> Self {
        Self {
            decl: Some(decl),
            assign: Some(assign),
            decl_and_assign: Some(decl_and_assign),
        }
    }

    pub fn empty() -> Self {
        Self {
            decl: Some(Vec::new()),
            assign: Some(Vec::new()),
            decl_and_assign: Some(Vec::new()),
        }
    }
}

impl DeclStmtStore {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn absorb(&mut self, other: DeclStmtStore) {
        self.store.extend(other.store);
    }

    pub fn extract_decl(&mut self, decl_id: CDeclId) -> TranslationResult<Vec<DaStmt>> {
        let DeclStmtInfo { decl, assign, .. } = self
            .store
            .swap_remove(&decl_id)
            .ok_or_else(|| TranslationError::generic("Cannot find information on declaration"))?;
        let decl: Vec<DaStmt> = decl.ok_or_else(|| {
            TranslationError::generic("Declaration has already been extracted")
        })?;
        let pruned = DeclStmtInfo {
            decl: None,
            assign,
            decl_and_assign: None,
        };
        self.store.insert(decl_id, pruned);
        Ok(decl)
    }

    pub fn extract_assign(&mut self, decl_id: CDeclId) -> TranslationResult<Vec<DaStmt>> {
        let DeclStmtInfo { decl, assign, .. } =
            self.store.swap_remove(&decl_id).ok_or_else(|| {
                TranslationError::generic("Cannot find information on declaration")
            })?;
        let assign: Vec<DaStmt> = assign.ok_or_else(|| {
            TranslationError::generic("Assignment has already been extracted")
        })?;
        let pruned = DeclStmtInfo {
            decl,
            assign: None,
            decl_and_assign: None,
        };
        self.store.insert(decl_id, pruned);
        Ok(assign)
    }

    pub fn extract_decl_and_assign(&mut self, decl_id: CDeclId) -> TranslationResult<Vec<DaStmt>> {
        let DeclStmtInfo {
            decl_and_assign, ..
        } = self
            .store
            .swap_remove(&decl_id)
            .ok_or_else(|| TranslationError::generic("Cannot find information on declaration"))?;
        let decl_and_assign: Vec<DaStmt> = decl_and_assign.ok_or_else(|| {
            TranslationError::generic("Declaration with assignment has already been extracted")
        })?;
        let pruned = DeclStmtInfo {
            decl: None,
            assign: None,
            decl_and_assign: None,
        };
        self.store.insert(decl_id, pruned);
        Ok(decl_and_assign)
    }
}

#[derive(Debug)]
struct WipBlock {
    label: Label,
    body: Vec<StmtOrDecl>,
    defined: IndexSet<CDeclId>,
    live: IndexSet<CDeclId>,
}

impl WipBlock {
    pub fn push_stmt(&mut self, stmt: DaStmt) {
        self.body.push(StmtOrDecl::Stmt(stmt))
    }

    pub fn push_decl(&mut self, decl: CDeclId) {
        self.body.push(StmtOrDecl::Decl(decl))
    }
}

impl CfgBuilder {
    fn last_per_stmt_mut(&mut self) -> &mut PerStmt {
        self.per_stmt_stack
            .last_mut()
            .expect("'per_stmt_stack' is empty")
    }

    fn add_block(&mut self, lbl: Label, bb: BasicBlock<Label, StmtOrDecl>) {
        let currently_live = self
            .currently_live
            .last_mut()
            .expect("Found no live currently live scope");
        for decl in &bb.defined {
            currently_live.insert(*decl);
        }
        match self
            .per_stmt_stack
            .last_mut()
            .expect("'per_stmt_stack' is empty")
            .nodes
            .insert(lbl.clone(), bb)
        {
            None => {}
            Some(_) => panic!("Label {:?} cannot identify two basic blocks", lbl),
        }
        if let Some((_, loop_vec)) = self.loops.last_mut() {
            loop_vec.push(lbl.clone());
        }
        if let Some((_, arm_vec)) = self.multiples.last_mut() {
            arm_vec.push(lbl);
        }
    }

    fn add_wip_block(&mut self, wip: WipBlock, terminator: GenTerminator<Label>) {
        let WipBlock {
            label,
            body,
            defined,
            live,
        } = wip;
        self.add_block(
            label,
            BasicBlock {
                body,
                terminator,
                defined,
                live,
            },
        );
    }

    fn update_terminator(&mut self, lbl: Label, new_term: GenTerminator<Label>) {
        match self.last_per_stmt_mut().nodes.get_mut(&lbl) {
            None => panic!("Cannot find label {:?} to update", lbl),
            Some(bb) => bb.terminator = new_term,
        }
    }

    fn open_loop(&mut self) {
        let loop_id: LoopId = self.fresh_loop_id();
        self.loops.push((loop_id, vec![]));
    }

    fn close_loop(&mut self) {
        let (loop_id, loop_contents) = self.loops.pop().expect("No loop to close.");
        let outer_loop_id: Option<LoopId> = self.loops.last().map(|&(i, _)| i);
        if let Some((_, outer_loop)) = self.loops.last_mut() {
            outer_loop.extend(loop_contents.iter().cloned());
        }
        self.last_per_stmt_mut().loop_info.add_loop(
            loop_id,
            loop_contents.into_iter().collect(),
            outer_loop_id,
        );
    }

    fn open_arm(&mut self, arm_start: Label) {
        self.multiples.push((arm_start, vec![]));
    }

    fn close_arm(&mut self) -> (Label, IndexSet<Label>) {
        let (arm_start, arm_contents) = self.multiples.pop().expect("No arm to close.");
        if let Some((_, outer_arm)) = self.multiples.last_mut() {
            outer_arm.extend(arm_contents.iter().cloned());
        }
        (arm_start, arm_contents.into_iter().collect())
    }

    fn with_scope<B, F: FnOnce(&mut Self) -> B>(
        &mut self,
        _translator: &Translation,
        cont: F,
    ) -> B {
        let new_vars = self.current_variables();
        self.currently_live.push(new_vars);
        let b = cont(self);
        self.currently_live
            .pop()
            .expect("Found no live currently live scope to close");
        b
    }

    fn current_variables(&self) -> IndexSet<CDeclId> {
        self.currently_live
            .last()
            .expect("Found no live currently live scope")
            .clone()
    }

    fn new_wip_block(&mut self, new_label: Label) -> WipBlock {
        WipBlock {
            label: new_label,
            body: vec![],
            defined: IndexSet::new(),
            live: self.current_variables(),
        }
    }

    fn fresh_label(&mut self) -> Label {
        self.prev_label += 1;
        Label::Synthetic(self.prev_label)
    }

    fn fresh_loop_id(&mut self) -> LoopId {
        self.prev_loop_id += 1;
        LoopId::new(self.prev_loop_id)
    }

    fn new(c_label_to_goto: IndexMap<CLabelId, IndexSet<CStmtId>>) -> CfgBuilder {
        let entry = Label::Synthetic(0);
        CfgBuilder {
            entry,
            per_stmt_stack: vec![],
            prev_label: 0,
            prev_loop_id: 0,
            c_label_to_goto,
            break_labels: vec![],
            continue_labels: vec![],
            switch_expr_cases: vec![],
            currently_live: vec![IndexSet::new()],
            loops: vec![],
            multiples: vec![],
        }
    }

    fn convert_stmts_help(
        &mut self,
        translator: &Translation,
        ctx: ExprContext,
        stmt_ids: &[CStmtId],
        in_tail: Option<ImplicitReturnType>,
        entry: Label,
        ret_ty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<Label>> {
        self.with_scope(translator, |slf| -> TranslationResult<Option<Label>> {
            let mut lbl = Some(entry);
            let last = stmt_ids.last();
            for stmt in stmt_ids {
                let new_label: Label = lbl.unwrap_or_else(|| slf.fresh_label());
                let sub_in_tail = in_tail.clone().filter(|_| Some(stmt) == last);
                lbl = slf.convert_stmt_help(translator, ctx, *stmt, sub_in_tail, new_label, ret_ty)?;
            }
            Ok(lbl)
        })
    }

    fn convert_stmt_help(
        &mut self,
        translator: &Translation,
        ctx: ExprContext,
        stmt_id: CStmtId,
        in_tail: Option<ImplicitReturnType>,
        entry: Label,
        ret_ty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<Label>> {
        let live_in: IndexSet<CDeclId> = self.currently_live.last().unwrap().clone();
        self.per_stmt_stack
            .push(PerStmt::new(Some(stmt_id), entry.clone(), live_in));
        let mut wip = self.new_wip_block(entry.clone());

        let out_wip: TranslationResult<Option<WipBlock>> = match translator
            .ast_context
            .index(stmt_id)
            .kind
        {
            CStmtKind::Empty => Ok(Some(wip)),

            CStmtKind::Decls(ref decls) => {
                for decl in decls {
                    let info = translator.convert_decl_stmt_info(ctx, *decl)?;
                    self.last_per_stmt_mut()
                        .decls_seen
                        .store
                        .insert(*decl, info);
                    wip.push_decl(*decl);
                    wip.defined.insert(*decl);
                }
                Ok(Some(wip))
            }

            CStmtKind::Return(expr) => {
                let val = match expr.map(|i| translator.convert_expr(ctx.used(), i, ret_ty)) {
                    Some(r) => Some(r?),
                    None => None,
                };
                let (stmts, ret_val) = WithStmts::with_stmts_opt(val).discard_unsafe().into_stmts_and_val();
                wip.body.extend(stmts.into_iter().map(StmtOrDecl::Stmt));
                wip.push_stmt(DaStmt::Expr(DaExpr::Return(ret_val.map(Box::new))));
                self.add_wip_block(wip, End);
                Ok(None)
            }

            CStmtKind::If {
                scrutinee,
                true_variant,
                false_variant,
            } => {
                let next_entry = self.fresh_label();
                let then_entry = self.fresh_label();
                let else_entry = if false_variant.is_none() {
                    next_entry.clone()
                } else {
                    self.fresh_label()
                };

                let (stmts, val) = translator
                    .convert_condition(ctx, true, scrutinee)?
                    .discard_unsafe()
                    .into_stmts_and_val();
                wip.body.extend(stmts.into_iter().map(StmtOrDecl::Stmt));

                let cond_val = translator.ast_context[scrutinee].kind.get_bool();
                self.add_wip_block(
                    wip,
                    match cond_val {
                        Some(true) => Jump(then_entry.clone()),
                        Some(false) => Jump(else_entry.clone()),
                        None => Branch(val, then_entry.clone(), else_entry.clone()),
                    },
                );

                self.open_arm(then_entry.clone());
                let then_stuff = self.convert_stmt_help(
                    translator, ctx, true_variant, in_tail.clone(), then_entry, ret_ty,
                )?;
                if let Some(then_end) = then_stuff {
                    let wip_then = self.new_wip_block(then_end);
                    self.add_wip_block(wip_then, Jump(next_entry.clone()));
                }
                let then_arm = self.close_arm();
                self.last_per_stmt_mut().multiple_info.add_multiple(
                    next_entry.clone(),
                    vec![then_arm],
                );

                self.open_arm(else_entry.clone());
                if let Some(false_var) = false_variant {
                    let else_stuff = self.convert_stmt_help(
                        translator, ctx, false_var, in_tail, else_entry, ret_ty,
                    )?;
                    if let Some(else_end) = else_stuff {
                        let wip_else = self.new_wip_block(else_end);
                        self.add_wip_block(wip_else, Jump(next_entry.clone()));
                    }
                } else {
                    self.add_wip_block(
                        self.new_wip_block(else_entry.clone()),
                        Jump(next_entry.clone()),
                    );
                }
                let else_arm = self.close_arm();
                self.last_per_stmt_mut().multiple_info.add_multiple(
                    next_entry.clone(),
                    vec![else_arm],
                );

                self.per_stmt_stack.push(PerStmt::new(None, next_entry.clone(), live_in));
                Ok(Some(self.new_wip_block(next_entry)))
            }

            CStmtKind::While { condition, body } => {
                let cond_after = self.fresh_label();
                let body_entry = self.fresh_label();
                let post_body = self.fresh_label();
                self.break_labels.push(post_body.clone());
                self.continue_labels.push(cond_after.clone());
                self.open_loop();

                let (stmts, val) = translator
                    .convert_condition(ctx, true, condition)?
                    .discard_unsafe()
                    .into_stmts_and_val();
                wip.body.extend(stmts.into_iter().map(StmtOrDecl::Stmt));
                let cond_val = translator.ast_context[condition].kind.get_bool();
                self.add_wip_block(
                    wip,
                    match cond_val {
                        Some(true) => Jump(body_entry.clone()),
                        Some(false) => Jump(post_body.clone()),
                        None => Branch(val, body_entry.clone(), post_body.clone()),
                    },
                );

                self.open_arm(body_entry.clone());
                let body_stuff = self.convert_stmt_help(
                    translator, ctx, body, None, body_entry, ret_ty,
                )?;
                if let Some(body_end) = body_stuff {
                    let wip_body = self.new_wip_block(body_end);
                    self.add_wip_block(wip_body, Jump(cond_after.clone()));
                }
                let body_arm = self.close_arm();

                // cond_after: jump to body_entry (the actual loop)
                let wip_cond_after = self.new_wip_block(cond_after);
                self.add_wip_block(wip_cond_after, Jump(body_entry.clone()));

                let _body_set = body_arm.1;
                self.close_loop();
                self.break_labels.pop();
                self.continue_labels.pop();
                self.per_stmt_stack.push(PerStmt::new(None, post_body.clone(), live_in));
                Ok(Some(self.new_wip_block(post_body)))
            }

            CStmtKind::DoWhile { body, condition } => {
                let body_entry = self.fresh_label();
                let cond_entry = self.fresh_label();
                let post_body = self.fresh_label();
                self.break_labels.push(post_body.clone());
                self.continue_labels.push(cond_entry.clone());
                self.open_loop();

                self.add_wip_block(wip, Jump(body_entry.clone()));

                self.open_arm(body_entry.clone());
                let body_stuff = self.convert_stmt_help(
                    translator, ctx, body, None, body_entry, ret_ty,
                )?;
                if let Some(body_end) = body_stuff {
                    let wip_body_end = self.new_wip_block(body_end);
                    self.add_wip_block(wip_body_end, Jump(cond_entry.clone()));
                }
                let body_arm = self.close_arm();

                let cond_stmt_ws = translator.convert_expr(
                    ExprContext { used: true, is_const: false, ..Default::default() },
                    condition, None,
                )?;
                let cond_val = translator.ast_context[condition].kind.get_bool();
                let wip_cond = self.new_wip_block(cond_entry);
                let (cond_stmts, cond_expr) = cond_stmt_ws.discard_unsafe().into_stmts_and_val();
                let mut wip_cond_stmts = cond_stmts.into_iter().map(StmtOrDecl::Stmt).collect::<Vec<_>>();
                wip_cond.body.extend(wip_cond_stmts);
                self.add_wip_block(
                    wip_cond,
                    match cond_val {
                        Some(true) => Jump(body_entry.clone()),
                        Some(false) => Jump(post_body.clone()),
                        None => Branch(cond_expr, body_entry.clone(), post_body.clone()),
                    },
                );

                self.close_loop();
                self.break_labels.pop();
                self.continue_labels.pop();
                self.per_stmt_stack.push(PerStmt::new(None, post_body.clone(), live_in));
                Ok(Some(self.new_wip_block(post_body)))
            }

            CStmtKind::ForLoop { init, condition, increment, body } => {
                let (init_stmts, init_exit) = match init {
                    Some(init_id) => {
                        let init_lbl = self.fresh_label();
                        let mut init_wip = self.new_wip_block(init_lbl.clone());
                        let init_ws = translator.convert_stmt(init_id)?;
                        let (stmts, _) = init_ws.discard_unsafe().into_stmts_and_val();
                        init_wip.body.extend(stmts.into_iter().map(StmtOrDecl::Stmt));
                        self.add_wip_block(init_wip, Jump(self.fresh_label()));
                        (vec![], Some(init_lbl))
                    }
                    None => (vec![], None),
                };

                let cond_entry = self.fresh_label();
                let body_entry = self.fresh_label();
                let post_body = self.fresh_label();
                let after_for = self.fresh_label();
                self.break_labels.push(post_body.clone());
                self.continue_labels.push(cond_entry.clone());
                self.open_loop();

                let cond_ws = match condition {
                    Some(cond_id) => {
                        let cond = translator.convert_expr(
                            ExprContext { used: true, is_const: false, ..Default::default() },
                            cond_id, None,
                        )?;
                        Some(cond)
                    }
                    None => None,
                };
                let wip_cond = self.new_wip_block(cond_entry.clone());
                self.add_wip_block(
                    wip_cond,
                    match cond_ws {
                        Some(ws) => {
                            let (stmts, val) = ws.discard_unsafe().into_stmts_and_val();
                            Branch(val, body_entry.clone(), after_for.clone())
                        }
                        None => Jump(body_entry.clone()),
                    },
                );

                self.open_arm(body_entry.clone());
                let body_stuff = self.convert_stmt_help(
                    translator, ctx, body, None, body_entry, ret_ty,
                )?;
                if let Some(body_end) = body_stuff {
                    // Add increment at end of body
                    let mut inc_wip = self.new_wip_block(body_end);
                    if let Some(inc_id) = increment {
                        let inc = translator.convert_expr(
                            ExprContext { used: false, is_const: false, ..Default::default() },
                            inc_id, None,
                        )?;
                        let (inc_stmts, inc_val) = inc.discard_unsafe().into_stmts_and_val();
                        inc_wip.body.extend(inc_stmts.into_iter().map(StmtOrDecl::Stmt));
                        inc_wip.push_stmt(DaStmt::Expr(inc_val));
                    }
                    self.add_wip_block(inc_wip, Jump(cond_entry.clone()));
                }
                let body_arm = self.close_arm();

                self.add_wip_block(self.new_wip_block(post_body.clone()), Jump(after_for.clone()));
                self.close_loop();
                self.break_labels.pop();
                self.continue_labels.pop();
                self.per_stmt_stack.push(PerStmt::new(None, after_for.clone(), live_in));
                Ok(Some(self.new_wip_block(after_for)))
            }

            CStmtKind::Switch { scrutinee, body } => {
                let switch_expr = translator.convert_expr(
                    ExprContext { used: true, is_const: false, ..Default::default() },
                    scrutinee, None,
                )?;
                let (mut cond_stmts, cond_val) = switch_expr.discard_unsafe().into_stmts_and_val();
                wip.body.extend(cond_stmts.drain(..).map(StmtOrDecl::Stmt));

                let switch_end = self.fresh_label();
                let default_entry = self.fresh_label();
                self.switch_expr_cases.push(SwitchCases::default());
                self.break_labels.push(switch_end.clone());

                let body_entry = self.fresh_label();
                self.add_wip_block(wip, Jump(body_entry.clone()));

                self.per_stmt_stack.push(PerStmt::new(None, body_entry.clone(), self.current_variables()));
                let body_exit = self.convert_stmt_help(translator, ctx, body, None, body_entry, ret_ty)?;

                let mut cases = self.switch_expr_cases.pop().unwrap();
                if cases.default.is_none() {
                    cases.default = Some(switch_end.clone());
                }
                let brk = self.break_labels.pop().unwrap();
                assert_eq!(brk, switch_end);

                // Build a Branch/Switch terminator from the cases
                if body_exit.is_some() {
                    let mut wip_end = self.new_wip_block(self.fresh_label());
                    self.add_wip_block(wip_end, Jump(switch_end.clone()));
                }

                // Rewrite: jump to body_entry → actually enter switch with the value matching
                // We need to update the body_entry block's terminator to be the actual switch
                let mut switch_cases: Vec<(DaExpr, Label)> = cases.cases.into_iter()
                    .map(|(val, lbl)| (val, lbl))
                    .collect();
                let default_lbl = cases.default.unwrap_or(switch_end.clone());
                // Add default as a wildcard case at the end (compared as last elif)
                // For CFG purposes, use the default label for the last case
                // Actually, gen-terminator handles this via Branch patterns
                self.update_terminator(body_entry, Switch {
                    expr: cond_val,
                    cases: switch_cases,
                });

                self.per_stmt_stack.push(PerStmt::new(None, switch_end.clone(), live_in));
                Ok(Some(self.new_wip_block(switch_end)))
            }

            CStmtKind::Case(expr, sub_stmt, _) => {
                let case_val = translator.convert_expr(
                    ExprContext { used: true, is_const: false, ..Default::default() },
                    expr, None,
                )?;
                let label = self.fresh_label();
                let switch_cases = self.switch_expr_cases.last_mut().unwrap();
                switch_cases.cases.push((case_val.val, label.clone()));
                self.per_stmt_stack.push(PerStmt::new(None, label.clone(), live_in));
                let result = self.convert_stmt_help(translator, ctx, sub_stmt, in_tail.clone(), label, ret_ty)?;
                Ok(result.map(|l| self.new_wip_block(l)))
            }

            CStmtKind::Default(sub_stmt) => {
                let label = self.fresh_label();
                self.switch_expr_cases.last_mut().unwrap().default = Some(label.clone());
                self.per_stmt_stack.push(PerStmt::new(None, label.clone(), live_in));
                let result = self.convert_stmt_help(translator, ctx, sub_stmt, in_tail, label, ret_ty)?;
                Ok(result.map(|l| self.new_wip_block(l)))
            }

            CStmtKind::Goto(label_id) => {
                let target_label = Label::FromC(label_id, translator.ast_context.label_names.get(&label_id).cloned());
                self.last_per_stmt_mut()
                    .c_labels_used
                    .entry(label_id)
                    .or_default()
                    .insert(stmt_id);
                self.add_wip_block(wip, Jump(target_label));
                Ok(None)
            }

            CStmtKind::Label(sub_stmt) => {
                let label = Label::FromC(stmt_id.into(), translator.ast_context.label_names.get(&stmt_id.into()).cloned());
                self.last_per_stmt_mut()
                    .c_labels_defined
                    .insert(stmt_id.into());
                let result = self.convert_stmt_help(translator, ctx, sub_stmt, in_tail, label, ret_ty)?;
                Ok(result.map(|l| self.new_wip_block(l)))
            }

            CStmtKind::Break => {
                let brk = self.break_labels.last().unwrap().clone();
                self.last_per_stmt_mut().saw_unmatched_break = true;
                self.add_wip_block(wip, Jump(brk));
                Ok(None)
            }

            CStmtKind::Continue => {
                let cont = self.continue_labels.last().unwrap().clone();
                self.last_per_stmt_mut().saw_unmatched_continue = true;
                self.add_wip_block(wip, Jump(cont));
                Ok(None)
            }

            CStmtKind::Expr(expr_id) => {
                let v = translator.convert_expr(
                    ExprContext { used: false, is_const: false, ..Default::default() },
                    *expr_id, None,
                )?;
                let (stmts, val) = v.discard_unsafe().into_stmts_and_val();
                wip.body.extend(stmts.into_iter().map(StmtOrDecl::Stmt));
                wip.push_stmt(DaStmt::Expr(val));
                Ok(Some(wip))
            }

            CStmtKind::Compound(ref children) => {
                let mut lbl = Some(entry);
                let last = children.last();
                let mut i = 0;
                for child in children {
                    let new_label: Label = lbl.clone().unwrap_or_else(|| self.fresh_label());
                    let child_in_tail = in_tail.clone().filter(|_| Some(child) == last);
                    let per_stmt_before = self.per_stmt_stack.len();
                    lbl = self.convert_stmt_help(translator, ctx, *child, child_in_tail, new_label, ret_ty)?;
                    // Merge the child's PerStmt into the parent
                    if self.per_stmt_stack.len() > per_stmt_before + 1 {
                        let child_per_stmt = self.per_stmt_stack.pop().unwrap();
                        if child_per_stmt.stmt_id.is_some() {
                            self.last_per_stmt_mut().absorb(child_per_stmt);
                        }
                    }
                    i += 1;
                }
                Ok(lbl.map(|l| self.new_wip_block(l)))
            }

            _ => Err(TranslationError::generic("unsupported cfg stmt kind")),
        };

        let out_wip = out_wip?;
        let lbl = if let Some(mut wip) = out_wip {
            if !wip.body.is_empty() {
                let next_lbl = self.fresh_label();
                self.add_wip_block(wip, Jump(next_lbl.clone()));
                Some(next_lbl)
            } else {
                None
            }
        } else {
            None
        };

        // Pop self from per_stmt_stack and merge into parent
        let self_per_stmt = self.per_stmt_stack.pop().unwrap();
        if let Some(parent_per_stmt) = self.per_stmt_stack.last_mut() {
            parent_per_stmt.absorb(self_per_stmt);
        }

        Ok(lbl)
    }
}

pub fn convert_function_body(
    translator: &Translation,
    stmt_ids: &[CStmtId],
    ret: ImplicitReturnType,
    ret_ty: Option<CQualTypeId>,
) -> TranslationResult<(Vec<DaStmt>, DeclStmtStore)> {
    let ctx = ExprContext { used: true, is_const: false, ..Default::default() };
    let (cfg, store) = Cfg::from_stmts(translator, ctx, stmt_ids, ret, ret_ty)?;

    // Use C loop info for better translations
    let use_c_loop_info = true;
    let use_c_multiple_info = true;

    let (lifted_stmts, structures) = relooper::reloop(
        cfg,
        store,
        use_c_loop_info,
        use_c_multiple_info,
        IndexSet::new(),
    );

    let simplified = relooper::simplify_structure(structures);

    let mut cfg_info = structures::CfgInfo::default();
    structures::gather_cfg_info(&simplified, &mut cfg_info);

    let stmts = structures::structured_cfg(
        &simplified,
        &cfg_info,
        DaExpr::Var("__current_block".to_string()),
        false,
    )?;

    let mut all_stmts = lifted_stmts;
    all_stmts.extend(stmts);
    Ok((all_stmts, DeclStmtStore::new()))
}
