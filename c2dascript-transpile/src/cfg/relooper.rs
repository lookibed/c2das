use super::*;

pub fn reloop(
    cfg: Cfg<Label, StmtOrDecl>,
    mut store: DeclStmtStore,
    use_c_loop_info: bool,
    use_c_multiple_info: bool,
    live_in: IndexSet<CDeclId>,
) -> (Vec<DaStmt>, Vec<Structure<StmtOrDecl>>) {
    let entries = indexset![cfg.entries.clone()];
    let blocks: BasicBlocks = cfg
        .nodes
        .into_iter()
        .map(|(lbl, bb)| {
            let terminator = bb
                .terminator
                .map_labels(|l| StructureLabel::GoTo(l.clone()));
            (
                lbl,
                BasicBlock {
                    body: bb.body,
                    terminator,
                    defined: bb.defined,
                    live: bb.live,
                },
            )
        })
        .collect();

    let mut relooped_with_decls: Vec<Structure<StmtOrDecl>> = vec![];
    let loop_info = if use_c_loop_info {
        Some(cfg.loops)
    } else {
        None
    };
    let multiple_info = if use_c_multiple_info {
        Some(cfg.multiples)
    } else {
        None
    };

    let successors = blocks
        .iter()
        .map(|(lbl, bb)| (lbl.clone(), bb.successors()))
        .collect();
    let global_predecessors = flip_edges(successors);
    let domination_sets = flip_edges(compute_dominators(&cfg.entries, &global_predecessors));

    let mut state = RelooperState {
        scopes: vec![live_in],
        lifted: IndexSet::new(),
        loop_info,
        _multiple_info: multiple_info,
        domination_sets,
        global_predecessors,
    };
    state.relooper(entries, blocks, &mut relooped_with_decls);

    let lift_me = state.lifted;
    let lifted_stmts: Vec<DaStmt> = lift_me
        .iter()
        .flat_map(|&decl: &CDeclId| store.extract_decl(decl).unwrap())
        .collect();

    let relooped = relooped_with_decls
        .into_iter()
        .map(|s| s.place_decls(&lift_me, &mut store))
        .collect();

    (lifted_stmts, relooped)
}

struct RelooperState {
    scopes: Vec<IndexSet<CDeclId>>,
    lifted: IndexSet<CDeclId>,
    loop_info: Option<LoopInfo<Label>>,
    _multiple_info: Option<MultipleInfo<Label>>,
    domination_sets: AdjacencyList,
    global_predecessors: AdjacencyList,
}

impl RelooperState {
    pub fn open_scope(&mut self) {
        self.scopes.push(IndexSet::new());
    }

    pub fn close_scope(&mut self) {
        self.scopes.pop();
    }

    pub fn in_scope(&self, decl: CDeclId) -> bool {
        self.scopes.iter().any(|scope| scope.contains(&decl))
    }

    pub fn add_to_scope(&mut self, decl: CDeclId) {
        self.scopes
            .last_mut()
            .expect("add_to_scope: no scopes found")
            .insert(decl);
    }

    pub fn add_to_top_scope(&mut self, decl: CDeclId) {
        self.scopes
            .first_mut()
            .expect("add_to_top_scope: no scopes found")
            .insert(decl);
    }
}

type BasicBlocks = IndexMap<Label, BasicBlock<StructureLabel<StmtOrDecl>, StmtOrDecl>>;
type AdjacencyList = IndexMap<Label, IndexSet<Label>>;

impl RelooperState {
    fn relooper(
        &mut self,
        entries: IndexSet<Label>,
        mut blocks: BasicBlocks,
        result: &mut Vec<Structure<StmtOrDecl>>,
    ) {
        if entries.is_empty() || blocks.is_empty() {
            return;
        }

        let local_successors = blocks
            .iter()
            .map(|(lbl, bb)| (lbl.clone(), bb.successors()))
            .collect();

        let strict_reachable_from = flip_edges(transitive_closure(&local_successors));

        if entries.len() == 1 {
            let entry = entries.first().unwrap();
            if !strict_reachable_from.contains_key(entry) {
                let bb = blocks
                    .swap_remove(entry)
                    .expect("Entry not present in current blocks");
                let new_entries = bb.successors();
                let BasicBlock {
                    body,
                    mut terminator,
                    live,
                    defined,
                } = bb;

                for l in live {
                    if !self.in_scope(l) {
                        self.add_to_top_scope(l);
                        self.lifted.insert(l);
                    }
                }

                for d in defined {
                    self.add_to_scope(d);
                }

                for lbl in terminator.get_labels_mut() {
                    if let StructureLabel::GoTo(label) = lbl {
                        *lbl = StructureLabel::ExitTo(label.clone())
                    }
                }

                result.push(Structure::Simple {
                    entries,
                    body,
                    terminator,
                });

                self.relooper(new_entries, blocks, result);
            } else {
                self.make_loop(&strict_reachable_from, blocks, entries, result);
            }
            return;
        }

        if !entries.iter().any(|entry| blocks.contains_key(entry)) {
            panic!(
                "No entries are in our current set of blocks, entries: {entries:?}, blocks: {:?}",
                blocks.keys().collect::<Vec<_>>(),
            );
        }

        let mut reachable_from = strict_reachable_from.clone();
        for entry in &entries {
            reachable_from
                .entry(entry.clone())
                .or_default()
                .insert(entry.clone());
        }

        let singly_reached: AdjacencyList = flip_edges(
            reachable_from
                .into_iter()
                .map(|(lbl, reached_from)| (lbl, &reached_from & &entries))
                .filter(|(_, reached_from)| reached_from.len() == 1)
                .collect(),
        );

        if !singly_reached.is_empty() {
            let handled_entries: IndexMap<Label, BasicBlocks> = singly_reached
                .into_iter()
                .filter(|(lbl, _)| entries.contains(lbl) && blocks.contains_key(lbl))
                .map(|(lbl, within)| {
                    let val = blocks
                        .iter()
                        .filter(|(k, _)| within.contains(*k))
                        .map(|(k, v)| (k.clone(), v.clone()))
                        .collect();
                    (lbl, val)
                })
                .collect();

            let unhandled_entries: IndexSet<Label> = entries
                .iter()
                .filter(|&e| !handled_entries.contains_key(e))
                .cloned()
                .collect();

            let handled_blocks: BasicBlocks = handled_entries
                .values()
                .flatten()
                .map(|(k, v)| (k.clone(), v.clone()))
                .collect();

            let follow_blocks: BasicBlocks = blocks
                .into_iter()
                .filter(|(lbl, _)| !handled_blocks.contains_key(lbl))
                .collect();

            let follow_entries: IndexSet<Label> = &unhandled_entries | &out_edges(&handled_blocks);

            let branches: IndexMap<_, _> = handled_entries
                .into_iter()
                .map(|(lbl, blocks)| {
                    let entries = indexset![lbl.clone()];
                    let mut structs = vec![];
                    self.open_scope();
                    self.relooper(entries, blocks, &mut structs);
                    self.close_scope();
                    (lbl, structs)
                })
                .collect();

            result.push(Structure::Multiple { entries, branches });

            self.relooper(follow_entries, follow_blocks, result);
            return;
        }

        self.make_loop(&strict_reachable_from, blocks, entries, result);
    }

    fn make_loop(
        &mut self,
        strict_reachable_from: &AdjacencyList,
        blocks: BasicBlocks,
        entries: IndexSet<Label>,
        result: &mut Vec<Structure<StmtOrDecl>>,
    ) {
        let new_returns: IndexSet<Label> = strict_reachable_from
            .iter()
            .filter(|&(lbl, _)| blocks.contains_key(lbl) && entries.contains(lbl))
            .flat_map(|(_, reachable)| reachable.iter())
            .cloned()
            .collect();

        let (mut body_blocks, mut follow_blocks) =
            blocks.into_iter().partition::<BasicBlocks, _>(|(lbl, _)| {
                new_returns.contains(lbl) || entries.contains(lbl)
            });

        let mut follow_entries = out_edges(&body_blocks);

        let mut matched_existing_loop = false;
        if let Some(ref loop_info) = self.loop_info {
            let must_be_in_loop = entries.iter().chain(new_returns.iter()).cloned();
            if let Some(loop_id) = loop_info.tightest_common_loop(must_be_in_loop) {
                let mut desired_body: IndexSet<Label> =
                    loop_info.get_loop_contents(loop_id).clone();
                desired_body.retain(|l| !entries.contains(l));
                desired_body.retain(|l| !new_returns.contains(l));

                let mut body_blocks_copy = body_blocks.clone();
                let mut follow_blocks_copy = follow_blocks.clone();
                let mut follow_entries_copy = follow_entries.clone();

                if loops::match_loop_body(
                    desired_body,
                    strict_reachable_from,
                    &mut body_blocks_copy,
                    &mut follow_blocks_copy,
                    &mut follow_entries_copy,
                ) {
                    matched_existing_loop = true;
                    body_blocks = body_blocks_copy;
                    follow_blocks = follow_blocks_copy;
                    follow_entries = follow_entries_copy;
                }
            }
        }

        if !matched_existing_loop && follow_entries.len() > 1 {
            let inlined = follow_entries
                .iter()
                .filter(|&e| self.global_predecessors[e].len() == 1);

            for inlined in inlined {
                for dominated in &self.domination_sets[inlined] {
                    let block = follow_blocks
                        .remove(dominated)
                        .expect("Dominated node not in follow blocks");
                    body_blocks.insert(dominated.clone(), block);
                }
            }

            follow_entries = out_edges(&body_blocks);
        }

        for bb in body_blocks.values_mut() {
            for lbl in bb.terminator.get_labels_mut() {
                if let StructureLabel::GoTo(label) = lbl.clone() {
                    if entries.contains(&label) || follow_entries.contains(&label) {
                        *lbl = StructureLabel::ExitTo(label.clone());
                    }
                }
            }
        }

        let mut body = vec![];
        self.open_scope();
        self.relooper(entries.clone(), body_blocks, &mut body);
        self.close_scope();

        result.push(Structure::Loop { entries: entries.clone(), body });

        self.relooper(follow_entries, follow_blocks, result);
    }
}

pub fn simplify_structure<Stmt: Clone>(structures: Vec<Structure<Stmt>>) -> Vec<Structure<Stmt>> {
    let structures: Vec<Structure<Stmt>> = structures
        .into_iter()
        .map(|structure: Structure<Stmt>| -> Structure<Stmt> {
            use Structure::*;
            match structure {
                Loop { entries, body } => {
                    let body = simplify_structure(body);
                    Loop { entries, body }
                }
                Multiple { entries, branches } => {
                    let branches = branches
                        .into_iter()
                        .map(|(lbl, ss)| (lbl, simplify_structure(ss)))
                        .collect();
                    Multiple { entries, branches }
                }
                simple => simple,
            }
        })
        .collect();

    let mut acc_structures = Vec::new();

    for structure in structures.iter().rev() {
        match structure {
            Structure::Simple {
                entries,
                body,
                terminator,
            } => {
                let terminator: GenTerminator<StructureLabel<Stmt>> =
                    if let Switch { expr, cases } = terminator {
                        use StructureLabel::*;
                        type Merged = IndexMap<Label, Vec<DaExpr>>;
                        let mut merged_goto: Merged = IndexMap::new();
                        let mut merged_exit: Merged = IndexMap::new();

                        for (val, lbl) in cases {
                            match lbl {
                                GoTo(lbl) => {
                                    merged_goto
                                        .entry(lbl.clone())
                                        .or_default()
                                        .push(val.clone());
                                }
                                ExitTo(lbl) => {
                                    merged_exit
                                        .entry(lbl.clone())
                                        .or_default()
                                        .push(val.clone());
                                }
                                _ => panic!("simplify_structure: Nested precondition violated"),
                            };
                        }

                        let mut cases_new = Vec::new();
                        for (_, lbl) in cases.iter().rev() {
                            match lbl {
                                GoTo(lbl) => match merged_goto.swap_remove(lbl) {
                                    None => {}
                                    Some(mut vals) => {
                                        // Use the first value as representative
                                        let val = vals.swap_remove(0);
                                        cases_new.push((val, GoTo(lbl.clone())))
                                    }
                                },
                                ExitTo(lbl) => match merged_exit.swap_remove(lbl) {
                                    None => {}
                                    Some(mut vals) => {
                                        let val = vals.swap_remove(0);
                                        cases_new.push((val, ExitTo(lbl.clone())))
                                    }
                                },
                                _ => panic!("simplify_structure: Nested precondition violated"),
                            };
                        }
                        cases_new.reverse();

                        Switch {
                            expr: expr.clone(),
                            cases: cases_new,
                        }
                    } else {
                        terminator.clone()
                    };

                match acc_structures.pop() {
                    Some(Structure::Multiple {
                        entries: _,
                        branches,
                    }) => {
                        use StructureLabel::*;
                        let rewrite = |t: &StructureLabel<Stmt>| match t {
                            GoTo(to) => {
                                if let Some(branch) = branches.get(to) {
                                    Nested(branch.clone())
                                } else {
                                    GoTo(to.clone())
                                }
                            }
                            ExitTo(to) => {
                                if let Some(branch) = branches.get(to) {
                                    Nested(branch.clone())
                                } else {
                                    ExitTo(to.clone())
                                }
                            }
                            Nested(_) => panic!("simplify_structure: Nested precondition violated"),
                        };

                        let terminator = terminator.map_labels(rewrite);
                        let body = body.clone();
                        let entries = entries.clone();
                        acc_structures.push(Structure::Simple {
                            entries,
                            body,
                            terminator,
                        });
                    }
                    possibly_popped => {
                        if let Some(popped) = possibly_popped {
                            acc_structures.push(popped);
                        }
                        let entries = entries.clone();
                        let body = body.clone();
                        let terminator = terminator.clone();
                        acc_structures.push(Structure::Simple {
                            entries,
                            body,
                            terminator,
                        });
                    }
                }
            }
            other_structure => acc_structures.push(other_structure.clone()),
        }
    }

    acc_structures.reverse();
    acc_structures
}

fn out_edges(blocks: &BasicBlocks) -> IndexSet<Label> {
    blocks
        .iter()
        .flat_map(|(_, bb)| bb.successors())
        .filter(|lbl| !blocks.contains_key(lbl))
        .collect()
}

fn flip_edges(map: AdjacencyList) -> AdjacencyList {
    let mut flipped_map: AdjacencyList = IndexMap::new();
    for (lbl, vals) in map {
        for val in vals {
            flipped_map.entry(val).or_default().insert(lbl.clone());
        }
    }
    flipped_map
}

fn transitive_closure<V: Clone + Hash + Eq>(
    adjacency_list: &IndexMap<V, IndexSet<V>>,
) -> IndexMap<V, IndexSet<V>> {
    let mut edges: IndexSet<(V, V)> = IndexSet::new();
    let mut to_visit: Vec<(V, V)> = adjacency_list
        .keys()
        .map(|v| (v.clone(), v.clone()))
        .collect();

    while let Some((s, v)) = to_visit.pop() {
        for i in adjacency_list.get(&v).unwrap_or(&IndexSet::new()) {
            if edges.insert((s.clone(), i.clone())) {
                to_visit.push((s.clone(), i.clone()));
            }
        }
    }

    let mut closure: IndexMap<V, IndexSet<V>> = IndexMap::new();
    for (f, t) in edges {
        closure.entry(f).or_default().insert(t);
    }
    closure
}

fn compute_dominators(entry: &Label, predecessor_map: &AdjacencyList) -> AdjacencyList {
    let nodes: Vec<Label> = predecessor_map
        .keys()
        .filter(|k| *k != entry)
        .cloned()
        .collect();

    let initial_dom: IndexSet<Label> = nodes
        .iter()
        .cloned()
        .chain(std::iter::once(entry.clone()))
        .collect();

    let mut dominators = IndexMap::new();
    dominators.insert(entry.clone(), indexset! { entry.clone() });
    for node in &nodes {
        dominators.insert(node.clone(), initial_dom.clone());
    }

    let mut changed = true;
    while changed {
        changed = false;
        for node in &nodes {
            let preds = &predecessor_map[node];
            let mut new_dom = initial_dom.clone();
            for pred in preds {
                let pred_dom = &dominators[pred];
                new_dom.retain(|x| pred_dom.contains(x));
            }
            new_dom.insert(node.clone());
            if dominators.get(node) != Some(&new_dom) {
                dominators.insert(node.clone(), new_dom);
                changed = true;
            }
        }
    }
    dominators
}

#[cfg(test)]
mod tests {
    use super::*;

    fn label(id: u64) -> Label {
        Label::Synthetic(id)
    }

    fn build_successor_map(edges: &[(u64, u64)]) -> AdjacencyList {
        let mut graph: AdjacencyList = IndexMap::new();
        for &(from, to) in edges {
            graph.entry(label(from)).or_default().insert(label(to));
        }
        for &(_, to) in edges {
            graph.entry(label(to)).or_default();
        }
        graph
    }

    fn build_predecessor_map(edges: &[(u64, u64)]) -> AdjacencyList {
        flip_edges(build_successor_map(edges))
    }

    #[test]
    fn test_dominators_linear_chain() {
        let predecessors = build_predecessor_map(&[(1, 2), (2, 3), (3, 4)]);
        let entry = label(1);
        let doms = compute_dominators(&entry, &predecessors);
        assert_eq!(doms.get(&label(1)), Some(&indexset! { label(1) }));
        assert_eq!(doms.get(&label(2)), Some(&indexset! { label(1), label(2) }));
        assert_eq!(doms.get(&label(3)), Some(&indexset! { label(1), label(2), label(3) }));
        assert_eq!(doms.get(&label(4)), Some(&indexset! { label(1), label(2), label(3), label(4) }));
    }

    #[test]
    fn test_dominators_diamond() {
        let predecessors = build_predecessor_map(&[(1, 2), (1, 3), (2, 4), (3, 4)]);
        let entry = label(1);
        let doms = compute_dominators(&entry, &predecessors);
        assert_eq!(doms.get(&label(1)), Some(&indexset! { label(1) }));
        assert_eq!(doms.get(&label(2)), Some(&indexset! { label(1), label(2) }));
        assert_eq!(doms.get(&label(3)), Some(&indexset! { label(1), label(3) }));
        assert_eq!(doms.get(&label(4)), Some(&indexset! { label(1), label(4) }));
    }

    #[test]
    fn test_dominators_loop() {
        let predecessors = build_predecessor_map(&[(1, 2), (2, 3), (3, 2)]);
        let entry = label(1);
        let doms = compute_dominators(&entry, &predecessors);
        assert_eq!(doms.get(&label(1)), Some(&indexset! { label(1) }));
        assert_eq!(doms.get(&label(2)), Some(&indexset! { label(1), label(2) }));
        assert_eq!(doms.get(&label(3)), Some(&indexset! { label(1), label(2), label(3) }));
    }

    #[test]
    fn test_dominators_single_node() {
        let predecessors: AdjacencyList = IndexMap::new();
        let entry = label(1);
        let doms = compute_dominators(&entry, &predecessors);
        assert_eq!(doms.get(&label(1)), Some(&indexset! { label(1) }));
    }

    #[test]
    fn test_dominators_self_loop() {
        let predecessors = build_predecessor_map(&[(1, 2), (2, 2)]);
        let entry = label(1);
        let doms = compute_dominators(&entry, &predecessors);
        assert_eq!(doms.get(&label(1)), Some(&indexset! { label(1) }));
        assert_eq!(doms.get(&label(2)), Some(&indexset! { label(1), label(2) }));
    }
}
