use super::*;
use das_ast::{DaBlock, DaExpr, DaStmt};
use log::warn;

pub fn structured_cfg(
    root: &[Structure<DaStmt>],
    cfg_info: &CfgInfo,
    current_block: DaExpr,
    debug_labels: bool,
) -> TranslationResult<Vec<DaStmt>> {
    let loop_context = LoopContext::default();
    let mut ast = process_cfg(
        root,
        cfg_info,
        &IndexSet::new(),
        &loop_context,
        &mut IndexSet::new(),
    )?;

    cleanup_labels(&mut ast, &None, &mut IndexSet::new());

    let s = StructureState {
        debug_labels,
        current_block,
    };
    let (stmts, _) = s.to_stmt(ast);

    Ok(stmts)
}

fn cleanup_labels(
    ast: &mut StructuredAST<DaExpr, DaExpr, Label, DaStmt>,
    current_loop: &Option<Label>,
    encountered_labels: &mut IndexSet<Label>,
) {
    use StructuredASTKind::*;

    match &mut ast.node {
        Exit(_, label) => {
            if label == current_loop {
                *label = None;
            } else if let Some(label) = label {
                encountered_labels.insert(label.clone());
            }
        }
        Loop(label_place, body) => {
            let mut inner_labels = IndexSet::new();
            cleanup_labels(body, label_place, &mut inner_labels);
            if let Some(label) = label_place {
                if !inner_labels.contains(label) {
                    *label_place = None;
                }
            }
            encountered_labels.extend(inner_labels);
        }
        Block(label, body) => {
            let mut inner_labels = IndexSet::new();
            cleanup_labels(body, &None, &mut inner_labels);

            match &mut body.node {
                Loop(loop_label @ None, _) => {
                    *loop_label = Some(label.clone());
                    inner_labels.clear();
                    cleanup_labels(body, &None, &mut inner_labels);
                    *ast = std::mem::take(&mut *body);
                }
                Loop(Some(inner_label), _) => {
                    let inner_label = inner_label.clone();
                    merge_labels(body, &inner_label, label);
                    inner_labels.clear();
                    cleanup_labels(body, &None, &mut inner_labels);
                    *ast = std::mem::replace(&mut *body, dummy_spanned(StructuredASTKind::Empty));
                }
                Block(inner_label, _) => {
                    let inner_label = inner_label.clone();
                    merge_labels(body, &inner_label, label);
                    *ast = std::mem::replace(&mut *body, dummy_spanned(StructuredASTKind::Empty));
                }
                _ => {}
            }

            encountered_labels.extend(inner_labels);
        }
        Append(left, right) => {
            cleanup_labels(left, current_loop, encountered_labels);
            cleanup_labels(right, current_loop, encountered_labels);
        }
        Match(_, arms) => {
            for (_, arm) in arms {
                cleanup_labels(arm, current_loop, encountered_labels);
            }
        }
        If(_, then, else_) => {
            cleanup_labels(then, current_loop, encountered_labels);
            cleanup_labels(else_, current_loop, encountered_labels);
        }
        GotoTable(cases, then) => {
            for (_, case) in cases {
                cleanup_labels(case, current_loop, encountered_labels);
            }
            cleanup_labels(then, current_loop, encountered_labels);
        }
        Empty | Singleton(_) | Goto(_) => {}
    }
}

fn merge_labels(ast: &mut StructuredAST<DaExpr, DaExpr, Label, DaStmt>, old: &Label, new: &Label) {
    use StructuredASTKind::*;

    match &mut ast.node {
        Exit(_, Some(label)) => {
            if label == old {
                *label = new.clone();
            }
        }
        Block(label, body) | Loop(Some(label), body) => {
            if label == old {
                *label = new.clone();
            }
            merge_labels(body, old, new);
        }
        Loop(None, body) => merge_labels(body, old, new),
        Append(left, right) => {
            merge_labels(left, old, new);
            merge_labels(right, old, new);
        }
        Match(_, arms) => {
            for (_, arm) in arms {
                merge_labels(arm, old, new);
            }
        }
        If(_, then, else_) => {
            merge_labels(then, old, new);
            merge_labels(else_, old, new);
        }
        GotoTable(cases, then) => {
            for (_, case) in cases {
                merge_labels(case, old, new);
            }
            merge_labels(then, old, new);
        }
        Exit(_, None) | Empty | Singleton(_) | Goto(_) => {}
    }
}

#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum ExitStyle {
    Continue,
    Break,
}

pub trait StructuredStatement: Sized {
    type E;
    type P;
    type L;
    type S;

    fn empty() -> Self;
    fn mk_singleton(stmt: Self::S) -> Self;
    fn mk_append(self, second: Self) -> Self;
    fn mk_goto(to: Self::L) -> Self;
    fn mk_match(cond: Self::E, cases: Vec<(Self::P, Self)>) -> Self;
    fn mk_if(cond: Self::E, then: Self, else_: Self) -> Self;
    fn mk_goto_table(cases: Vec<(Self::L, Self)>, then: Self) -> Self;
    fn mk_loop(lbl: Option<Self::L>, body: Self) -> Self;
    fn mk_block(lbl: Self::L, body: Self) -> Self;
    fn mk_exit(exit_style: ExitStyle, label: Option<Self::L>) -> Self;
}

#[derive(Debug, Clone)]
pub struct Spanned<T> {
    pub node: T,
}

impl<T: Default> Default for Spanned<T> {
    fn default() -> Self {
        Self { node: T::default() }
    }
}

pub type StructuredAST<E, P, L, S> = Spanned<StructuredASTKind<E, P, L, S>>;

fn dummy_spanned<T>(inner: T) -> Spanned<T> {
    Spanned { node: inner }
}

#[derive(Debug)]
pub enum StructuredASTKind<E, P, L, S> {
    Empty,
    Singleton(S),
    Append(
        Box<StructuredAST<E, P, L, S>>,
        Box<StructuredAST<E, P, L, S>>,
    ),
    Goto(L),
    Match(E, Vec<(P, StructuredAST<E, P, L, S>)>),
    If(
        E,
        Box<StructuredAST<E, P, L, S>>,
        Box<StructuredAST<E, P, L, S>>,
    ),
    GotoTable(
        Vec<(L, StructuredAST<E, P, L, S>)>,
        Box<StructuredAST<E, P, L, S>>,
    ),
    Loop(Option<L>, Box<StructuredAST<E, P, L, S>>),
    Block(L, Box<StructuredAST<E, P, L, S>>),
    Exit(ExitStyle, Option<L>),
}

impl<E, P, L, S> Default for StructuredASTKind<E, P, L, S> {
    fn default() -> Self {
        Self::Empty
    }
}

impl<E, P, L, S> StructuredStatement for StructuredAST<E, P, L, S> {
    type E = E;
    type P = P;
    type L = L;
    type S = S;

    fn empty() -> Self {
        dummy_spanned(StructuredASTKind::Empty)
    }

    fn mk_singleton(stmt: Self::S) -> Self {
        dummy_spanned(StructuredASTKind::Singleton(stmt))
    }

    fn mk_append(self, second: Self) -> Self {
        dummy_spanned(StructuredASTKind::Append(Box::new(self), Box::new(second)))
    }

    fn mk_goto(to: Self::L) -> Self {
        dummy_spanned(StructuredASTKind::Goto(to))
    }

    fn mk_match(cond: Self::E, cases: Vec<(Self::P, Self)>) -> Self {
        dummy_spanned(StructuredASTKind::Match(cond, cases))
    }

    fn mk_if(cond: Self::E, then: Self, else_: Self) -> Self {
        dummy_spanned(StructuredASTKind::If(cond, Box::new(then), Box::new(else_)))
    }

    fn mk_goto_table(cases: Vec<(Self::L, Self)>, then: Self) -> Self {
        dummy_spanned(StructuredASTKind::GotoTable(cases, Box::new(then)))
    }

    fn mk_loop(lbl: Option<Self::L>, body: Self) -> Self {
        dummy_spanned(StructuredASTKind::Loop(lbl, Box::new(body)))
    }

    fn mk_block(lbl: Self::L, body: Self) -> Self {
        dummy_spanned(StructuredASTKind::Block(lbl, Box::new(body)))
    }

    fn mk_exit(exit_style: ExitStyle, label: Option<Self::L>) -> Self {
        dummy_spanned(StructuredASTKind::Exit(exit_style, label))
    }
}

#[derive(Debug, Default)]
pub struct CfgInfo {
    pub checked_entries: IndexSet<Label>,
    pub entry_to_loop: IndexMap<Label, Label>,
}

pub fn gather_cfg_info(structures: &[Structure<DaStmt>], info: &mut CfgInfo) {
    for structure in structures {
        match structure {
            Structure::Loop { entries, body } => {
                if entries.len() > 1 {
                    info.checked_entries.extend(entries.iter().cloned());
                }
                let loop_label = entries.first().expect("Loop must have at least one entry");
                for entry in entries {
                    info.entry_to_loop.insert(entry.clone(), loop_label.clone());
                }
                gather_cfg_info(body, info);
            }
            Structure::Multiple { branches, .. } => {
                for branch in branches.values() {
                    gather_cfg_info(branch, info);
                }
            }
            Structure::Simple { terminator, .. } => {
                for label in terminator.get_labels() {
                    if let StructureLabel::Nested(nested) = label {
                        gather_cfg_info(nested, info);
                    }
                }
            }
        }
    }
}

#[derive(Clone, Debug, Default)]
struct LoopContext {
    current_loop_entries: IndexSet<Label>,
    innermost_loop: Option<Label>,
    innermost_loop_exits: IndexSet<Label>,
}

fn process_cfg(
    structures: &[Structure<DaStmt>],
    cfg_info: &CfgInfo,
    followup_entries: &IndexSet<Label>,
    loop_context: &LoopContext,
    break_targets: &mut IndexSet<Label>,
) -> TranslationResult<StructuredAST<DaExpr, DaExpr, Label, DaStmt>> {
    use Structure::*;

    type S = StructuredAST<DaExpr, DaExpr, Label, DaStmt>;

    fn sort_branches(branches: &IndexMap<Label, Vec<Structure<DaStmt>>>) -> Vec<Label> {
        let (named, mut rest) = branches
            .keys()
            .cloned()
            .partition::<Vec<_>, _>(|lbl| matches!(lbl, Label::FromC(_, Some(_))));
        rest.extend(named);
        rest
    }

    let get_entries = |i: usize| {
        if i < structures.len() {
            match &structures[i] {
                Simple { entries, .. } => entries.clone(),
                Loop { entries, .. } => entries.clone(),
                Multiple { branches, .. } => {
                    indexset! { sort_branches(branches).first().unwrap().clone() }
                }
            }
        } else {
            followup_entries.clone()
        }
    };

    let mut ast = S::empty();
    let mut i = 0;
    while i < structures.len() {
        let structure = &structures[i];
        let next_entries = get_entries(i + 1);

        let mut structure_ast = match structure {
            Simple {
                body, terminator, ..
            } => {
                let mut body_ast: S = S::empty();
                for s in body.clone() {
                    body_ast = S::mk_append(body_ast, S::mk_singleton(s));
                }

                let mut branch = |slbl: &StructureLabel<DaStmt>| -> TranslationResult<S> {
                    use StructureLabel::*;

                    match slbl {
                        Nested(nested) => process_cfg(
                            nested,
                            cfg_info,
                            &next_entries,
                            loop_context,
                            break_targets,
                        ),
                        ExitTo(target) => {
                            let mut new_ast = if cfg_info.checked_entries.contains(target) {
                                S::mk_goto(target.clone())
                            } else {
                                S::empty()
                            };

                            let is_back_edge = loop_context.current_loop_entries.contains(target);

                            let exit = if is_back_edge {
                                let loop_label = cfg_info.entry_to_loop.get(target).expect(
                                    "target in current_loop_entries but not in entry_to_loop",
                                );

                                if loop_context.innermost_loop_exits.contains(loop_label) {
                                    let break_label = loop_context.innermost_loop.as_ref().expect(
                                        "innermost_loop_exits set but innermost_loop is None",
                                    );
                                    Some((ExitStyle::Break, break_label.clone()))
                                } else if !next_entries.contains(loop_label) {
                                    Some((ExitStyle::Continue, loop_label.clone()))
                                } else {
                                    None
                                }
                            } else if !next_entries.contains(target) {
                                Some((ExitStyle::Break, target.clone()))
                            } else {
                                None
                            };

                            if let Some((style, label)) = exit {
                                break_targets.insert(label.clone());
                                new_ast = S::mk_append(new_ast, S::mk_exit(style, Some(label)));
                            }

                            Ok(new_ast)
                        }
                        GoTo(to) => panic!("Encountered GoTo({to:?}) in structured AST"),
                    }
                };

                S::mk_append(
                    body_ast,
                    match terminator {
                        End => S::empty(),
                        Jump(to) => branch(to)?,
                        Branch(c, t, f) => S::mk_if(c.clone(), branch(t)?, branch(f)?),
                        Switch { expr, cases } => {
                            let branched_cases = cases
                                .iter()
                                .map(|(val, slbl)| Ok((val.clone(), branch(slbl)?)))
                                .collect::<TranslationResult<_>>()?;
                            S::mk_match(expr.clone(), branched_cases)
                        }
                    },
                )
            }

            Loop { entries, body } => {
                let label = entries.first().expect("There must be at least one entry");

                let inner_loop_context = LoopContext {
                    current_loop_entries: loop_context
                        .current_loop_entries
                        .iter()
                        .cloned()
                        .chain(entries.iter().cloned())
                        .collect(),
                    innermost_loop: Some(label.clone()),
                    innermost_loop_exits: next_entries.clone(),
                };

                let body =
                    process_cfg(body, cfg_info, entries, &inner_loop_context, break_targets)?;
                S::mk_loop(Some(label.clone()), body)
            }

            Multiple { entries, branches } => {
                let mut branch_entries = branches.keys();
                let then = if entries.iter().all(|entry| branches.contains_key(entry)) {
                    let then_entry = branch_entries
                        .next()
                        .expect("There must be at least one branch");
                    process_cfg(
                        &branches[then_entry],
                        cfg_info,
                        &next_entries,
                        loop_context,
                        break_targets,
                    )?
                } else {
                    S::empty()
                };

                let cases = branch_entries
                    .map(|entry| {
                        let stmts = process_cfg(
                            &branches[entry],
                            cfg_info,
                            &next_entries,
                            loop_context,
                            break_targets,
                        )?;
                        Ok((entry.clone(), stmts))
                    })
                    .collect::<TranslationResult<_>>()?;

                S::mk_goto_table(cases, then)
            }
        };

        i += 1;

        while let Some(Multiple { branches, .. }) = structures.get(i) {
            let next_entries = get_entries(i + 1);

            for (branch_idx, entry) in sort_branches(branches).iter().enumerate() {
                let branch = &branches[entry];

                let empty = IndexSet::new();
                let branch_next_entries = if branch_idx == branches.len() - 1 {
                    &next_entries
                } else {
                    &empty
                };

                let branch_ast = process_cfg(
                    branch,
                    cfg_info,
                    branch_next_entries,
                    loop_context,
                    break_targets,
                )?;

                if break_targets.contains(entry) {
                    structure_ast = S::mk_block(entry.clone(), structure_ast);
                }

                structure_ast = S::mk_append(structure_ast, branch_ast);
            }

            i += 1;
        }

        match structures.get(i) {
            Some(Simple { entries, .. }) | Some(Loop { entries, .. }) => {
                for entry in entries {
                    if break_targets.contains(entry) {
                        structure_ast = S::mk_block(entry.clone(), structure_ast);
                    }
                }
            }
            Some(Multiple { .. }) => {
                unreachable!("We should have already handled followup multiples");
            }
            None => {}
        }

        ast = S::mk_append(ast, structure_ast);
    }

    Ok(ast)
}

struct StructureState {
    debug_labels: bool,
    current_block: DaExpr,
}

impl StructureState {
    pub fn to_stmt(&self, ast: StructuredAST<DaExpr, DaExpr, Label, DaStmt>) -> (Vec<DaStmt>, ()) {
        use crate::cfg::structures::StructuredASTKind::*;

        let stmt = match ast.node {
            Empty => return (vec![], ()),

            Singleton(s) => {
                return (vec![s], ());
            }

            Append(spanned, rhs) if matches!(spanned.node, Empty) => {
                let (stmts, _) = self.to_stmt(*rhs);
                return (stmts, ());
            }

            Append(lhs, rhs) => {
                let (mut stmts, _) = self.to_stmt(*lhs);
                let (rhs_stmts, _) = self.to_stmt(*rhs);
                stmts.extend(rhs_stmts);
                return (stmts, ());
            }

            Goto(to) => {
                // current_block = label_hash
                let lbl_expr = if self.debug_labels {
                    DaExpr::ConstString(to.debug_print())
                } else {
                    to.to_num_expr()
                };
                DaStmt::Expr(DaExpr::Assign(
                    Box::new(self.current_block.clone()),
                    Box::new(lbl_expr),
                ))
            }

            Match(cond, cases) => {
                let mut cases_iter = cases.into_iter();
                let if_expr = if let Some((first_val, first_body_ast)) = cases_iter.next() {
                    let (first_stmts, _) = self.to_stmt(first_body_ast);
                    let first_cond = DaExpr::Op2 {
                        op: "==",
                        left: Box::new(cond.clone()),
                        right: Box::new(first_val),
                    };
                    let mut elifs = vec![];
                    for (val, body_ast) in cases_iter {
                        let (body_stmts, _) = self.to_stmt(body_ast);
                        let case_cond = DaExpr::Op2 {
                            op: "==",
                            left: Box::new(cond.clone()),
                            right: Box::new(val),
                        };
                        elifs.push((case_cond, DaExpr::Block(DaBlock { stmts: body_stmts })));
                    }
                    DaExpr::IfThenElse {
                        cond: Box::new(first_cond),
                        then: Box::new(DaExpr::Block(DaBlock { stmts: first_stmts })),
                        elifs,
                        else_: None,
                    }
                } else {
                    DaExpr::Block(DaBlock { stmts: vec![] })
                };
                DaStmt::Expr(if_expr)
            }

            If(cond, then, els) => {
                let (then_stmts, _) = self.to_stmt(*then);
                let (els_stmts, _) = self.to_stmt(*els);

                let if_expr = match (then_stmts.is_empty(), els_stmts.is_empty()) {
                    (true, true) => cond,
                    (false, true) => DaExpr::IfThenElse {
                        cond: Box::new(cond),
                        then: Box::new(DaExpr::Block(DaBlock { stmts: then_stmts })),
                        elifs: vec![],
                        else_: None,
                    },
                    (true, false) => DaExpr::IfThenElse {
                        cond: Box::new(DaExpr::Op1 {
                            op: "!",
                            expr: Box::new(cond.clone()),
                        }),
                        then: Box::new(DaExpr::Block(DaBlock { stmts: els_stmts })),
                        elifs: vec![],
                        else_: None,
                    },
                    (false, false) => {
                        if els_stmts.len() == 1 {
                            if let DaStmt::Expr(DaExpr::IfThenElse {
                                cond: elif_cond,
                                then: elif_then,
                                elifs,
                                else_,
                            }) = &els_stmts[0]
                            {
                                let mut flat_elifs =
                                    vec![((**elif_cond).clone(), (**elif_then).clone())];
                                flat_elifs.extend(elifs.iter().cloned());
                                DaExpr::IfThenElse {
                                    cond: Box::new(cond),
                                    then: Box::new(DaExpr::Block(DaBlock { stmts: then_stmts })),
                                    elifs: flat_elifs,
                                    else_: else_.clone(),
                                }
                            } else {
                                DaExpr::IfThenElse {
                                    cond: Box::new(cond),
                                    then: Box::new(DaExpr::Block(DaBlock { stmts: then_stmts })),
                                    elifs: vec![],
                                    else_: Some(Box::new(DaExpr::Block(DaBlock { stmts: els_stmts }))),
                                }
                            }
                        } else {
                            DaExpr::IfThenElse {
                                cond: Box::new(cond),
                                then: Box::new(DaExpr::Block(DaBlock { stmts: then_stmts })),
                                elifs: vec![],
                                else_: Some(Box::new(DaExpr::Block(DaBlock { stmts: els_stmts }))),
                            }
                        }
                    }
                };
                DaStmt::Expr(if_expr)
            }

            GotoTable(cases, then) => {
                // Dispatch based on current_block value
                let arms: Vec<(DaExpr, Vec<DaStmt>)> = cases
                    .into_iter()
                    .map(|(lbl, body_ast)| {
                        let (stmts, _) = self.to_stmt(body_ast);
                        let lbl_lit = if self.debug_labels {
                            DaExpr::ConstString(lbl.debug_print())
                        } else {
                            lbl.to_num_expr()
                        };
                        (lbl_lit, stmts)
                    })
                    .collect();

                let (then_stmts, _) = self.to_stmt(*then);

                let default_block = DaExpr::Block(DaBlock { stmts: then_stmts });
                let mut arms_iter = arms.into_iter();
                let full_expr = if let Some((first_lbl_val, first_body_stmts)) = arms_iter.next() {
                    let first_cond = DaExpr::Op2 {
                        op: "==",
                        left: Box::new(self.current_block.clone()),
                        right: Box::new(first_lbl_val),
                    };
                    let mut elifs = vec![];
                    for (lbl_val, body_stmts) in arms_iter {
                        let cond = DaExpr::Op2 {
                            op: "==",
                            left: Box::new(self.current_block.clone()),
                            right: Box::new(lbl_val),
                        };
                        elifs.push((cond, DaExpr::Block(DaBlock { stmts: body_stmts })));
                    }
                    DaExpr::IfThenElse {
                        cond: Box::new(first_cond),
                        then: Box::new(DaExpr::Block(DaBlock {
                            stmts: first_body_stmts,
                        })),
                        elifs,
                        else_: Some(Box::new(default_block)),
                    }
                } else {
                    default_block
                };
                DaStmt::Expr(full_expr)
            }

            Loop(lbl, body) => {
                let (body_stmts, _) = self.to_stmt(*body);

                // Try to detect while pattern: loop { if cond { break } ... }
                // → while cond { ... }
                let mut use_while = false;
                let mut while_cond = DaExpr::ConstBool(true);
                if let Some(DaStmt::Expr(DaExpr::IfThenElse {
                    cond,
                    then,
                    else_: None,
                    ..
                })) = body_stmts.first()
                {
                    if let DaExpr::Block(ref block) = **then {
                        if block.stmts.len() == 1 {
                            if let DaStmt::Expr(DaExpr::Break) = block.stmts[0] {
                                use_while = true;
                                while_cond = DaExpr::Op2 {
                                    op: "!",
                                    left: Box::new(DaExpr::ConstBool(false)),
                                    right: Box::new(cond.as_ref().clone()),
                                };
                                // Actually daScript doesn't have while with complex cond,
                                // but we can use: while true { if !cond { break } ... }
                                // Actually simpler: just keep as loop with if break
                            }
                        }
                    }
                }

                let loop_expr = if use_while {
                    // In daScript, use `while !cond { ... }`
                    // But our DaExpr only has While(DaExpr, DaExpr) where cond is truthy
                    // Actually, let's keep it simple: just use while true with if break
                    DaExpr::While(
                        Box::new(DaExpr::ConstBool(true)),
                        Box::new(DaExpr::Block(DaBlock { stmts: body_stmts })),
                    )
                } else {
                    DaExpr::While(
                        Box::new(DaExpr::ConstBool(true)),
                        Box::new(DaExpr::Block(DaBlock { stmts: body_stmts })),
                    )
                };
                DaStmt::Expr(loop_expr)
            }

            Block(lbl, body) => {
                let (body_stmts, _) = self.to_stmt(*body);
                let wrapped = DaExpr::While(
                    Box::new(DaExpr::ConstBool(true)),
                    Box::new(DaExpr::Block(DaBlock { stmts: body_stmts })),
                );
                DaStmt::Expr(wrapped)
            }

            Exit(exit_style, lbl) => match exit_style {
                ExitStyle::Break => DaStmt::Expr(DaExpr::Break),
                ExitStyle::Continue => DaStmt::Expr(DaExpr::Continue),
            },
        };

        (vec![stmt], ())
    }
}
