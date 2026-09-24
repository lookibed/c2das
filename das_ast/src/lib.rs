pub mod expr;
pub mod stmt;
pub mod r#type;

pub use expr::*;
pub use r#type::*;
pub use stmt::*;

use std::fmt;

/// Top-level module (a `.das` file).
#[derive(Clone, Debug)]
pub struct DaModule {
    pub name: Option<String>,
    /// Print `module <name> public` after the options.  Without it the file
    /// is an anonymous module: `require`-able by file name, but daslang's
    /// AOT emits bodies only for a named public module's unexported
    /// functions, and other tooling keys on the declaration too.
    pub public: bool,
    pub requires: Vec<String>,
    pub options: Vec<String>,
    pub decls: Vec<DaDecl>,
}

impl DaModule {
    pub fn new() -> Self {
        DaModule {
            name: None,
            public: false,
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
        if let (true, Some(name)) = (self.public, &self.name) {
            writeln!(f, "module {} public", name)?;
        }
        if !self.options.is_empty() || self.public {
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
