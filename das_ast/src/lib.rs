pub mod r#type;
pub mod expr;
pub mod stmt;

pub use r#type::*;
pub use expr::*;
pub use stmt::*;

use std::fmt;

/// Top-level module (a `.das` file).
#[derive(Clone, Debug)]
pub struct DaModule {
    pub name: Option<String>,
    pub requires: Vec<String>,
    pub options: Vec<String>,
    pub decls: Vec<DaDecl>,
}

impl DaModule {
    pub fn new() -> Self {
        DaModule {
            name: None,
            requires: vec![],
            options: vec!["gen2".into()],
            decls: vec![],
        }
    }
}

impl fmt::Display for DaModule {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for opt in &self.options {
            writeln!(f, "options {}", opt)?;
        }
        if !self.options.is_empty() {
            writeln!(f)?;
        }
        for req in &self.requires {
            writeln!(f, "require {}", req)?;
        }
        for decl in &self.decls {
            writeln!(f, "{}", decl)?;
        }
        Ok(())
    }
}
