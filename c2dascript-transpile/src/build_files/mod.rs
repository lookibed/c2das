/// Build files module — not implemented for daScript yet.
use crate::TranspilerConfig;
use std::path::Path;

pub struct CrateConfig;

pub fn get_build_dir(_tcfg: &TranspilerConfig, _cc_db: &Path) -> PathBuf {
    PathBuf::from(".")
}

pub fn emit_build_files(
    _tcfg: &TranspilerConfig,
    _build_dir: &Path,
    _ccfg: Option<CrateConfig>,
    _workspace_members: Option<Vec<String>>,
) -> Option<PathBuf> {
    None
}

use std::path::PathBuf;
