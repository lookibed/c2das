use super::*;
use indexmap::{IndexMap, IndexSet};

pub fn match_loop_body(
    mut desired_body: IndexSet<Label>,
    strict_reachable_from: &IndexMap<Label, IndexSet<Label>>,
    body_blocks: &mut IndexMap<Label, BasicBlock<StructureLabel<StmtOrDecl>, StmtOrDecl>>,
    follow_blocks: &mut IndexMap<Label, BasicBlock<StructureLabel<StmtOrDecl>, StmtOrDecl>>,
    follow_entries: &mut IndexSet<Label>,
) -> bool {
    let mut something_happened = true;
    while something_happened {
        something_happened = false;
        let to_move: Vec<Label> = follow_entries
            .intersection(&desired_body)
            .cloned()
            .collect();
        for following in to_move {
            let bb = if let Some(bb) = follow_blocks.swap_remove(&following) {
                bb
            } else {
                continue;
            };
            something_happened = true;
            desired_body.swap_remove(&following);
            follow_entries.swap_remove(&following);
            follow_entries.extend(bb.successors());
            follow_entries.retain(|e| !body_blocks.contains_key(e));
            body_blocks.insert(following, bb);
        }
    }
    desired_body.is_empty()
        && body_blocks.keys().all(|body_lbl| {
            match strict_reachable_from.get(body_lbl) {
                None => true,
                Some(reachable_froms) => reachable_froms
                    .iter()
                    .all(|lbl| body_blocks.contains_key(lbl)),
            }
        })
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, Debug, Hash)]
pub struct LoopId(u64);

impl LoopId {
    pub fn new(id: u64) -> LoopId {
        LoopId(id)
    }

    pub fn pretty_print(&self) -> String {
        let LoopId(loop_id) = self;
        format!("l_{}", loop_id)
    }
}

#[derive(Clone, Debug)]
pub struct LoopInfo<Lbl: Hash + Eq> {
    node_loops: IndexMap<Lbl, LoopId>,
    loops: IndexMap<LoopId, (IndexSet<Lbl>, Option<LoopId>)>,
}

impl<Lbl: Hash + Eq> Default for LoopInfo<Lbl> {
    fn default() -> Self {
        Self {
            node_loops: Default::default(),
            loops: Default::default(),
        }
    }
}

impl<Lbl: Hash + Eq + Clone> LoopInfo<Lbl> {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn absorb(&mut self, other: LoopInfo<Lbl>) {
        self.node_loops.extend(other.node_loops);
        self.loops.extend(other.loops);
    }

    pub fn tightest_common_loop<E: Iterator<Item = Lbl>>(&self, mut entries: E) -> Option<LoopId> {
        let first = entries.next()?;
        let mut loop_id = *self.node_loops.get(&first)?;
        for entry in entries {
            loop {
                match self.loops.get(&loop_id) {
                    Some((ref in_loop, parent_id)) => {
                        if in_loop.contains(&entry) {
                            break;
                        }
                        loop_id = if let Some(i) = parent_id {
                            *i
                        } else {
                            return None;
                        };
                    }
                    None => return None,
                }
            }
        }
        Some(loop_id)
    }

    pub fn filter_unreachable(&mut self, reachable: &IndexSet<Lbl>) {
        self.node_loops.retain(|lbl, _| reachable.contains(lbl));
        for (_, &mut (ref mut set, _)) in self.loops.iter_mut() {
            set.retain(|lbl| reachable.contains(lbl));
        }
    }

    pub fn rewrite_blocks(&mut self, rewrites: &IndexMap<Lbl, Lbl>) {
        self.node_loops.retain(|lbl, _| rewrites.get(lbl).is_none());
        for (_, &mut (ref mut set, _)) in self.loops.iter_mut() {
            set.retain(|lbl| rewrites.get(lbl).is_none());
        }
    }

    pub fn add_loop(&mut self, id: LoopId, contents: IndexSet<Lbl>, outer_id: Option<LoopId>) {
        for elem in &contents {
            if !self.node_loops.contains_key(elem) {
                self.node_loops.insert(elem.clone(), id);
            }
        }
        self.loops.insert(id, (contents, outer_id));
    }

    pub fn enclosing_loops(&self, lbl: &Lbl) -> Vec<LoopId> {
        let mut loop_id_opt: Option<LoopId> = self.node_loops.get(lbl).cloned();
        let mut loop_ids = vec![];
        while let Some(loop_id) = loop_id_opt {
            loop_ids.push(loop_id);
            loop_id_opt = self.loops[&loop_id].1;
        }
        loop_ids
    }

    pub fn get_loop_contents(&self, id: LoopId) -> &IndexSet<Lbl> {
        &self
            .loops
            .get(&id)
            .unwrap_or_else(|| panic!("There is no loop with id {:?}", id))
            .0
    }
}
