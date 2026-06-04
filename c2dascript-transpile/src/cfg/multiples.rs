use super::*;
use indexmap::{IndexMap, IndexSet};
use std::collections::BTreeSet;

type MultipleKey<Lbl> = BTreeSet<Lbl>;

type MultipleValue<Lbl> = (
    Lbl,
    IndexMap<Lbl, IndexSet<Lbl>>,
);

#[derive(Clone, Debug)]
pub struct MultipleInfo<Lbl: Hash + Ord> {
    multiples: IndexMap<MultipleKey<Lbl>, MultipleValue<Lbl>>,
}

impl<Lbl: Hash + Ord> Default for MultipleInfo<Lbl> {
    fn default() -> Self {
        Self {
            multiples: Default::default(),
        }
    }
}

impl<Lbl: Hash + Ord + Clone> MultipleInfo<Lbl> {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn absorb(&mut self, other: MultipleInfo<Lbl>) {
        self.multiples.extend(other.multiples);
    }

    pub fn rewrite_blocks(&mut self, rewrites: &IndexMap<Lbl, Lbl>) {
        self.multiples = self
            .multiples
            .iter()
            .filter_map(|(entries, (join_lbl, arms))| {
                let entries: BTreeSet<Lbl> = entries
                    .iter()
                    .map(|lbl| rewrites.get(lbl).unwrap_or(lbl).clone())
                    .collect();
                let join_lbl: Lbl = rewrites.get(join_lbl).unwrap_or(join_lbl).clone();
                let arms: IndexMap<Lbl, IndexSet<Lbl>> = arms
                    .iter()
                    .map(|(arm_lbl, arm_body)| {
                        let arm_lbl: Lbl = rewrites.get(arm_lbl).unwrap_or(arm_lbl).clone();
                        let arm_body: IndexSet<Lbl> = arm_body
                            .iter()
                            .map(|lbl| rewrites.get(lbl).unwrap_or(lbl).clone())
                            .collect();
                        (arm_lbl, arm_body)
                    })
                    .collect();
                if arms.len() > 1 {
                    Some((entries, (join_lbl, arms)))
                } else {
                    None
                }
            })
            .collect();
    }

    pub fn add_multiple(&mut self, join: Lbl, arms: Vec<(Lbl, IndexSet<Lbl>)>) {
        let entry_set: BTreeSet<Lbl> = arms.iter().map(|(l, _)| l.clone()).collect();
        let arm_map: IndexMap<Lbl, IndexSet<Lbl>> = arms.into_iter().collect();
        if arm_map.len() > 1 {
            self.multiples.insert(entry_set, (join, arm_map));
        }
    }

    pub fn get_multiple<'a>(
        &'a self,
        entries: &BTreeSet<Lbl>,
    ) -> Option<&'a (Lbl, IndexMap<Lbl, IndexSet<Lbl>>)> {
        self.multiples.get(entries)
    }
}
