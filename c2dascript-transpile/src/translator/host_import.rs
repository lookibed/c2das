//! Host imports (experimental): a C function the program declares but defines
//! nowhere becomes a call to a hand-written daslang function
//! (`--host-import`, `--host-import-prefix`; `docs/eden-flags.md`, "Host
//! imports (experimental)").
//!
//! The binding is decided from the C declaration at the call site.  Only a
//! name nothing else claims binds: a name the program also defines, or one the
//! translator lowers itself (the raw runtime, `--libc std`, libm), is refused
//! by name rather than silently taking one of the two meanings.
//!
//! ABI: every parameter and the result keep the type the translator already
//! gives them, so a C pointer is the `int` heap offset under
//! `--memory-model linear` and a daslang pointer under `raw`.  Under `linear`
//! the call passes the heap `c2da_mem` by reference as an extra first
//! argument: the host module then never `require`s the translated module (or
//! `c2da_runtime` under `--module-layout source`), so no `require` cycle can
//! form.  Function pointers, variadic and unprototyped imports, and any
//! parameter or result type outside scalars and data pointers are refused.

use super::Translation;
use crate::c_ast::*;
use crate::diagnostics::{TranslationError, TranslationErrorKind, TranslationResult};
use crate::format_translation_err;
use das_ast::DaExpr;

/// What one `--host-import`/`--host-import-prefix` flag binds.
#[derive(Clone, Debug, Eq, PartialEq)]
pub enum HostImportName {
    /// `--host-import <c_name>=<module>::<function>`: one C name, any
    /// function name in the module.
    Exact { c_name: String, function: String },
    /// `--host-import-prefix <prefix>=<module>`: every C name starting with
    /// the prefix binds to the module function of the same name.
    Prefix(String),
}

/// One host-import binding: the C names it covers and the daslang module
/// that implements them.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HostImport {
    pub name: HostImportName,
    pub module: String,
}

fn is_identifier(text: &str) -> bool {
    let mut chars = text.chars();
    chars
        .next()
        .map_or(false, |c| c.is_ascii_alphabetic() || c == '_')
        && chars.all(|c| c.is_ascii_alphanumeric() || c == '_')
}

impl HostImport {
    /// Parses the value of `--host-import <c_name>=<module>::<function>`.
    pub fn parse_exact(text: &str) -> Result<Self, String> {
        let shape = || format!("--host-import '{text}': expected <c_name>=<module>::<function>");
        let (c_name, target) = text.split_once('=').ok_or_else(shape)?;
        let (module, function) = target.split_once("::").ok_or_else(shape)?;
        if ![c_name, module, function].iter().all(|s| is_identifier(s)) {
            return Err(shape());
        }
        Ok(HostImport {
            name: HostImportName::Exact {
                c_name: c_name.to_owned(),
                function: function.to_owned(),
            },
            module: module.to_owned(),
        })
    }

    /// Parses the value of `--host-import-prefix <prefix>=<module>`.
    pub fn parse_prefix(text: &str) -> Result<Self, String> {
        let shape = || format!("--host-import-prefix '{text}': expected <prefix>=<module>");
        let (prefix, module) = text.split_once('=').ok_or_else(shape)?;
        if !is_identifier(prefix) || !is_identifier(module) {
            return Err(shape());
        }
        Ok(HostImport {
            name: HostImportName::Prefix(prefix.to_owned()),
            module: module.to_owned(),
        })
    }
}

/// The `(module, function)` a C name binds to: an exact binding wins over a
/// prefix, and the longest prefix wins among prefixes.
pub fn bind<'a>(imports: &'a [HostImport], name: &'a str) -> Option<(&'a str, &'a str)> {
    let exact = imports.iter().find_map(|import| match &import.name {
        HostImportName::Exact { c_name, function } if c_name == name => {
            Some((import.module.as_str(), function.as_str()))
        }
        _ => None,
    });
    exact.or_else(|| {
        imports
            .iter()
            .filter_map(|import| match &import.name {
                HostImportName::Prefix(prefix) if name.starts_with(prefix.as_str()) => {
                    Some((prefix.len(), import.module.as_str()))
                }
                _ => None,
            })
            .max_by_key(|(len, _)| *len)
            .map(|(_, module)| (module, name))
    })
}

impl<'c> Translation<'c> {
    /// The host binding of C function `name`, if a flag names it.
    pub(crate) fn host_import(&self, name: &str) -> Option<(String, String)> {
        bind(&self.tcfg.host_imports, name).map(|(m, f)| (m.to_owned(), f.to_owned()))
    }

    /// Refuse a C definition of a name a host import binds: the program would
    /// have two implementations of one function.
    pub(crate) fn check_host_import_definitions(&self) -> TranslationResult<()> {
        if self.tcfg.host_imports.is_empty() {
            return Ok(());
        }
        for (_, decl) in self.ast_context.iter_decls() {
            if let CDeclKind::Function {
                name,
                body: Some(_),
                ..
            } = &decl.kind
            {
                if let Some((module, function)) = self.host_import(name) {
                    return Err(format_translation_err!(
                        self.ast_context.display_loc(&decl.loc),
                        "host import {name} (bound to {module}::{function}) is also defined by the C program",
                    ));
                }
            }
        }
        Ok(())
    }

    /// Check that the C declaration of an imported function crosses the
    /// host-import ABI: prototyped, not variadic, scalars and data pointers
    /// only.
    pub(crate) fn check_host_import_signature(
        &self,
        func: CExprId,
        name: &str,
        typ: CFuncTypeId,
    ) -> TranslationResult<()> {
        let loc = || self.ast_context.display_loc(&self.ast_context[func].loc);
        let CTypeKind::Function(ret, ref params, is_variadic, _, has_proto) =
            self.ast_context.resolve_type(typ).kind
        else {
            return Err(format_translation_err!(
                loc(),
                "host import {name}: the declaration is not a function type",
            ));
        };
        if is_variadic {
            return Err(format_translation_err!(
                loc(),
                "host import {name}: a variadic function cannot be imported",
            ));
        }
        if !has_proto {
            return Err(format_translation_err!(
                loc(),
                "host import {name}: an unprototyped declaration cannot be imported",
            ));
        }
        let ret_is_void = matches!(
            self.ast_context.resolve_type(ret.ctype).kind,
            CTypeKind::Void
        );
        let crossing = params
            .iter()
            .enumerate()
            .map(|(idx, ty)| (format!("parameter {}", idx + 1), *ty))
            .chain((!ret_is_void).then(|| ("result".to_owned(), ret)));
        for (what, ty) in crossing {
            if self.ast_context.is_va_list(ty.ctype) {
                return Err(format_translation_err!(
                    loc(),
                    "host import {name}: {what} is a va_list, which has no host-import mapping",
                ));
            }
            let kind = &self.ast_context.resolve_type(ty.ctype).kind;
            if self.is_callable_type(ty.ctype) {
                return Err(format_translation_err!(
                    loc(),
                    "host import {name}: {what} is a function pointer, which has no host-import mapping",
                ));
            }
            let mapped = kind.is_integral_type()
                || kind.is_floating_type()
                || kind.is_bool()
                || kind.is_enum()
                || matches!(kind, CTypeKind::Pointer(_));
            if !mapped {
                return Err(format_translation_err!(
                    loc(),
                    "host import {name}: {what} has a C type with no host-import mapping (only scalars and data pointers cross)",
                ));
            }
        }
        Ok(())
    }

    /// The call to an imported function: `<module>::<function>(args)`, with
    /// the linear heap first under `--memory-model linear`.  Records the
    /// module for the unit's `require` lines.
    pub(crate) fn host_import_call(
        &self,
        module: &str,
        function: &str,
        das_args: Vec<DaExpr>,
    ) -> DaExpr {
        self.host_import_modules
            .borrow_mut()
            .insert(module.to_owned());
        let mut args = Vec::with_capacity(das_args.len() + 1);
        if self.is_linear() {
            args.push(DaExpr::Var(super::linear::MEM.to_owned()));
        }
        args.extend(das_args);
        c2dascript_ast_builder::mk().call_expr(DaExpr::Var(format!("{module}::{function}")), args)
    }
}
