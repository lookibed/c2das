use crate::TranspilerConfig;
use crate::CrateSet;
use indexmap::IndexSet;
use std::collections::HashSet;

pub struct TypeConverter {
    pub translate_valist: bool,
    features: HashSet<&'static str>,
    pub extern_crates: CrateSet,
}

impl TypeConverter {
    pub fn new(tcfg: &TranspilerConfig) -> TypeConverter {
        TypeConverter {
            translate_valist: tcfg.translate_valist,
            features: HashSet::new(),
            extern_crates: IndexSet::new(),
        }
    }

    pub fn features_used(&self) -> &HashSet<&'static str> {
        &self.features
    }

    pub fn extern_crates_used(&self) -> &CrateSet {
        &self.extern_crates
    }
}
