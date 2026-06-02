use std::fmt;
use crate::DaExpr;
use crate::DaType;

/// daScript statement. Analogous to [`syn::Stmt`].
#[derive(Clone, Debug)]
pub enum DaStmt {
    /// `var name : type [= init]`
    Var { name: String, var_type: DaType, init: Option<DaExpr> },
    /// `let name [= init]` (immutable, type inferred)
    Let { name: String, init: Option<DaExpr> },
    /// `name : type [= init]` — в параметрах функции
    /// `is_mutable = true` → `var name : type`
    Param { name: String, param_type: DaType, default: Option<DaExpr>, is_mutable: bool },
    /// Expression statement (semicolon or newline terminated)
    Expr(DaExpr),
    /// Declaration (struct, enum, function, etc.)
    Decl(DaDecl),
}

/// daScript declaration. Analogous to [`syn::Item`].
#[derive(Clone, Debug)]
pub enum DaDecl {
    Function(DaFunction),
    Variable(DaVariable),
    Structure(DaStructure),
    Enumeration(DaEnumeration),
    Alias(DaAlias),
}

/// Type alias — `typedef name = type`
#[derive(Clone, Debug)]
pub struct DaAlias {
    pub name: String,
    pub aliased_type: DaType,
}

/// Function definition — `def name(params) : ret_type { body }`
#[derive(Clone, Debug)]
pub struct DaFunction {
    pub name: String,
    pub params: Vec<DaStmt>,
    pub ret_type: DaType,
    pub body: Option<DaExpr>,
    pub annotations: Vec<String>,
    pub is_public: bool,
    pub is_unsafe: bool,
}

/// Global/static variable definition.
#[derive(Clone, Debug)]
pub struct DaVariable {
    pub name: String,
    pub var_type: DaType,
    pub init: Option<DaExpr>,
    pub annotations: Vec<String>,
}

/// Struct definition — `struct Name { fields }`
#[derive(Clone, Debug)]
pub struct DaStructure {
    pub name: String,
    pub fields: Vec<DaField>,
    pub annotations: Vec<String>,
}

/// Struct field.
#[derive(Clone, Debug)]
pub struct DaField {
    pub name: String,
    pub field_type: DaType,
    pub default: Option<DaExpr>,
}

/// Enum definition — `enum Name [: base] { variants }`
#[derive(Clone, Debug)]
pub struct DaEnumeration {
    pub name: String,
    pub base_type: DaType,
    pub variants: Vec<DaEnumVariant>,
}

/// Enum variant.
#[derive(Clone, Debug)]
pub struct DaEnumVariant {
    pub name: String,
    pub value: Option<DaExpr>,
}

// ── Display ──

impl DaStmt {
    pub(crate) fn fmt_with_indent(&self, f: &mut fmt::Formatter, indent: usize) -> fmt::Result {
        match self {
            DaStmt::Var { name, var_type, init } => {
                if let Some(init_expr) = init {
                    writeln!(f, "var {} : {} = {}", name, var_type, init_expr)
                } else {
                    writeln!(f, "var {} : {}", name, var_type)
                }
            }
            DaStmt::Let { name, init } => {
                if let Some(init_expr) = init {
                    writeln!(f, "let {} = {}", name, init_expr)
                } else {
                    writeln!(f, "let {}", name)
                }
            }
            DaStmt::Param { name, param_type, default, is_mutable } => {
                if *is_mutable {
                    if let Some(def) = default {
                        write!(f, "var {} : {} = {}", name, param_type, def)
                    } else {
                        write!(f, "var {} : {}", name, param_type)
                    }
                } else {
                    if let Some(def) = default {
                        write!(f, "{} : {} = {}", name, param_type, def)
                    } else {
                        write!(f, "{} : {}", name, param_type)
                    }
                }
            }
            DaStmt::Expr(expr) => {
                expr.fmt_with_indent(f, indent)?;
                writeln!(f)
            }
            DaStmt::Decl(decl) => {
                write!(f, "{}", decl)
            }
        }
    }
}

impl fmt::Display for DaStmt {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        self.fmt_with_indent(f, 0)
    }
}

impl fmt::Display for DaDecl {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            DaDecl::Function(func) => write!(f, "{}", func),
            DaDecl::Variable(var) => write!(f, "{}", var),
            DaDecl::Structure(s) => write!(f, "{}", s),
            DaDecl::Enumeration(e) => write!(f, "{}", e),
            DaDecl::Alias(a) => write!(f, "typedef {} = {}", a.name, a.aliased_type),
        }
    }
}

impl fmt::Display for DaAlias {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "typedef {} = {}", self.name, self.aliased_type)
    }
}

impl fmt::Display for DaFunction {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for ann in &self.annotations {
            writeln!(f, "[{}]", ann)?;
        }
        let params_str: Vec<String> = self.params.iter().map(|p| format!("{}", p).trim().to_string()).collect();
        write!(f, "def {}({})", self.name, params_str.join("; "))?;
        if self.ret_type != DaType::Void {
            write!(f, " : {}", self.ret_type)?;
        }
        if let Some(body) = &self.body {
            write!(f, " ")?;
            body.fmt_with_indent(f, 0)?;
        }
        Ok(())
    }
}

impl fmt::Display for DaVariable {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for ann in &self.annotations {
            writeln!(f, "[{}]", ann)?;
        }
        if let Some(init_expr) = &self.init {
            writeln!(f, "var {} : {} = {}", self.name, self.var_type, init_expr)
        } else {
            writeln!(f, "var {} : {}", self.name, self.var_type)
        }
    }
}

impl fmt::Display for DaStructure {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for ann in &self.annotations {
            writeln!(f, "[{}]", ann)?;
        }
        writeln!(f, "struct {} {{", self.name)?;
        for field in &self.fields {
            if let Some(def) = &field.default {
                writeln!(f, "    {} : {} = {}", field.name, field.field_type, def)?;
            } else {
                writeln!(f, "    {} : {}", field.name, field.field_type)?;
            }
        }
        write!(f, "}}")
    }
}

impl fmt::Display for DaEnumeration {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        if self.base_type != DaType::Int {
            writeln!(f, "enum {} : {} {{", self.name, self.base_type)?;
        } else {
            writeln!(f, "enum {} {{", self.name)?;
        }
        for variant in &self.variants {
            if let Some(val) = &variant.value {
                writeln!(f, "    {} = {}", variant.name, val)?;
            } else {
                writeln!(f, "    {}", variant.name)?;
            }
        }
        write!(f, "}}")
    }
}
