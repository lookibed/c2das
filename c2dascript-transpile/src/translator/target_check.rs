//! Checkers over the finished daScript module for a target other than master
//! daslang: `--dialect eden-0.6.4` and `--no-unsafe` (`docs/eden-flags.md`
//! flags 8 and 11).
//!
//! Both read the module the translator is about to print — its `options`,
//! `require` lines and declarations — and never rewrite it.  A refused
//! construct is a `TranslationError` located at the C declaration whose
//! lowering produced it (a function or object of the C program), or named as
//! a translator-generated helper when no C declaration owns it.  daScript AST
//! nodes carry no C location of their own, so the declaration is the finest
//! location the checker can give.
use super::*;
use crate::c_ast::DisplaySrcSpan;
use crate::target::{Dialect, NoUnsafe};
use std::collections::{BTreeMap, HashMap};

/// The `options` the EdenSpark sandbox admits (`docs/eden-target.md` §2).
const EDEN_OPTIONS: &[&str] = &[
    "gen2",
    "indenting",
    "stack",
    "rtti",
    "no_global_variables",
    "no_aot",
    "solid_context",
    "strict_smart_pointers",
];

/// The daslib modules the editor sandbox accepts (`docs/eden-target.md` §6).
const EDEN_DASLIB: &[&str] = &[
    "algorithm",
    "ansi_colors",
    "apply",
    "archive",
    "array_boost",
    "assert_once",
    "ast_verify",
    "async_boost",
    "base64",
    "bitfield_boost",
    "bitfield_trait",
    "bool_array",
    "build_const",
    "builtin",
    "clargs",
    "class_boost",
    "command_line",
    "constant_expression",
    "consume",
    "contracts",
    "coroutines",
    "coverage",
    "cuckoo_hash_table",
    "dap",
    "debug",
    "debug_eval",
    "debugger",
    "decs",
    "decs_boost",
    "decs_state",
    "defer",
    "delegate",
    "dynamic_cast_rtti",
    "enum_trait",
    "faker",
    "flat_hash_table",
    "flatten",
    "flatten_opt",
    "flatten_opt_common",
    "flatten_opt_fold",
    "flatten_opt_fuse",
    "flatten_opt_pack",
    "flatten_opt_preshade",
    "flatten_opt_straightline",
    "flatten_opt_swizzle",
    "fts5_query",
    "functional",
    "fuzzer",
    "generic_return",
    "if_not_null",
    "instance_function",
    "interfaces",
    "json",
    "json_boost",
    "jsonrpc",
    "linq",
    "linq_boost",
    "lint",
    "lint_everything",
    "lpipe",
    "match",
    "math_bits",
    "math_boost",
    "md_boost",
    "option",
    "perf_lint",
    "random",
    "regex",
    "regex_boost",
    "remove_call_args",
    "result",
    "rtti",
    "sha_256",
    "shader_block_layout",
    "shader_lingua_franca",
    "soa",
    "sort_boost",
    "sql",
    "static_let",
    "stringify",
    "strings_boost",
    "strings_convert",
    "stub",
    "temp_strings",
    "templates",
    "toml",
    "tty",
    "type_traits",
    "unroll",
    "utf8_utils",
    "validate_code",
    "with_boost",
];

/// Builtin (C++) modules a translated unit may `require` in the sandbox.
/// Any other bare name is a module of the translated program itself.
const EDEN_REFUSED_BARE: &[&str] = &["fio", "network", "jobque", "ast", "uriparser"];

/// How many sites a `--no-unsafe` failure names.
const FIRST_SITES: usize = 10;

/// A construct the sandbox refuses, found in the declaration `owner`.
struct Site {
    construct: &'static str,
    owner: String,
}

/// Runs the checkers `tcfg.target` selects over one finished module.
pub(super) fn check_module(
    t: &Translation,
    main_file: &Path,
    requires: &[String],
    options: &[String],
    decls: &[DaDecl],
) -> TranslationResult<()> {
    let target = &t.tcfg.target;
    if target.dialect == Dialect::Master && target.no_unsafe == NoUnsafe::Off {
        return Ok(());
    }
    let c_locs = c_declaration_locations(t);
    let locate = |owner: &str| c_locs.get(owner).cloned().flatten();
    let describe = |owner: &str| match locate(owner) {
        Some(_) => format!("`{owner}`"),
        None => format!("translator-generated `{owner}`"),
    };
    let unit = main_file.display();

    if target.dialect == Dialect::Eden064 {
        for option in options {
            let name = option
                .split(|c: char| c == '=' || c.is_whitespace())
                .next()
                .unwrap_or("");
            if !EDEN_OPTIONS.contains(&name) {
                return Err(format_translation_err!(
                    None,
                    "{unit}: --dialect eden-0.6.4 refuses `options {option}`: the sandbox admits only {}",
                    EDEN_OPTIONS.join(", ")
                ));
            }
        }
        for require in requires {
            let refused = match require.strip_prefix("daslib/") {
                Some(module) => !EDEN_DASLIB.contains(&module),
                None => EDEN_REFUSED_BARE.contains(&require.as_str()),
            };
            if refused {
                return Err(format_translation_err!(
                    None,
                    "{unit}: --dialect eden-0.6.4 refuses `require {require}`: the module is refused by the EdenSpark sandbox (docs/eden-target.md §6)"
                ));
            }
        }
        let mut sites = Vec::new();
        for decl in decls {
            walk_decl(decl, &mut |owner, expr| {
                dialect_sites(owner, expr, &mut sites)
            });
        }
        if let Some(site) = sites.first() {
            return Err(format_translation_err!(
                locate(&site.owner),
                "--dialect eden-0.6.4 refuses {} in {}",
                site.construct,
                describe(&site.owner)
            ));
        }
    }

    if target.no_unsafe != NoUnsafe::Off {
        let mut sites = Vec::new();
        for decl in decls {
            if let DaDecl::Function(function) = unwrap_private(decl) {
                if function.is_unsafe {
                    sites.push(Site {
                        construct: "`def unsafe`",
                        owner: function.name.clone(),
                    });
                }
            }
            walk_decl(decl, &mut |owner, expr| {
                unsafe_sites(owner, expr, &mut sites)
            });
        }
        match target.no_unsafe {
            NoUnsafe::Report => print_census(&unit.to_string(), &sites, &locate),
            NoUnsafe::Fail if !sites.is_empty() => {
                let mut lines = Vec::new();
                for site in sites.iter().take(FIRST_SITES) {
                    let at = locate(&site.owner)
                        .map(|loc| format!("{loc}: "))
                        .unwrap_or_default();
                    lines.push(format!(
                        "  {at}{} in {}",
                        site.construct,
                        describe(&site.owner)
                    ));
                }
                return Err(format_translation_err!(
                    locate(&sites[0].owner),
                    "--no-unsafe: {} construct(s) of the output need `unsafe`; first {}:\n{}",
                    sites.len(),
                    lines.len(),
                    lines.join("\n")
                ));
            }
            _ => {}
        }
    }
    Ok(())
}

/// The C source location of every C function and file-scope object, by name.
fn c_declaration_locations(t: &Translation) -> HashMap<String, Option<DisplaySrcSpan>> {
    let mut locs = HashMap::new();
    for (_, decl) in t.ast_context.iter_decls() {
        let name = match &decl.kind {
            CDeclKind::Function { name, .. } => name,
            CDeclKind::Variable { ident, .. } => ident,
            _ => continue,
        };
        locs.entry(name.clone())
            .or_insert_with(|| t.ast_context.display_loc(&decl.loc));
    }
    locs
}

fn print_census(unit: &str, sites: &[Site], locate: &dyn Fn(&str) -> Option<DisplaySrcSpan>) {
    // construct -> (in translated C, in translator-generated helpers)
    let mut census: BTreeMap<&str, (usize, usize)> = BTreeMap::new();
    let mut by_owner: BTreeMap<&str, usize> = BTreeMap::new();
    for site in sites {
        let entry = census.entry(site.construct).or_default();
        if locate(&site.owner).is_some() {
            entry.0 += 1;
        } else {
            entry.1 += 1;
        }
        *by_owner.entry(site.owner.as_str()).or_default() += 1;
    }
    eprintln!("no-unsafe census {unit}: {} site(s)", sites.len());
    eprintln!("  {:<28} {:>10} {:>10}", "construct", "C code", "generated");
    for (construct, (c, generated)) in &census {
        eprintln!("  {construct:<28} {c:>10} {generated:>10}");
    }
    let mut owners: Vec<(&str, usize)> = by_owner.into_iter().collect();
    owners.sort_by(|a, b| b.1.cmp(&a.1).then(a.0.cmp(b.0)));
    for (owner, count) in owners.iter().take(FIRST_SITES) {
        let at = locate(owner)
            .map(|loc| loc.to_string())
            .unwrap_or_else(|| "generated".to_owned());
        eprintln!("  top: {count:>6}  {owner} ({at})");
    }
}

fn unwrap_private(decl: &DaDecl) -> &DaDecl {
    match decl {
        DaDecl::Private(inner) => unwrap_private(inner),
        decl => decl,
    }
}

/// Calls `visit(owner, expr)` for every expression of a declaration, with the
/// name of the declaration that owns it.
fn walk_decl(decl: &DaDecl, visit: &mut dyn FnMut(&str, &DaExpr)) {
    match unwrap_private(decl) {
        DaDecl::Function(function) => {
            for param in &function.params {
                walk_stmt(&function.name, param, visit);
            }
            if let Some(body) = &function.body {
                walk_expr(&function.name, body, visit);
            }
        }
        DaDecl::Variable(variable) => {
            if let Some(init) = &variable.init {
                walk_expr(&variable.name, init, visit);
            }
        }
        DaDecl::Structure(structure) => {
            for field in &structure.fields {
                if let Some(default) = &field.default {
                    walk_expr(&structure.name, default, visit);
                }
            }
        }
        DaDecl::Enumeration(_) | DaDecl::Alias(_) | DaDecl::Private(_) => {}
    }
}

fn walk_stmt(owner: &str, stmt: &DaStmt, visit: &mut dyn FnMut(&str, &DaExpr)) {
    match stmt {
        DaStmt::Var { init, .. } | DaStmt::Let { init, .. } => {
            if let Some(init) = init {
                walk_expr(owner, init, visit);
            }
        }
        DaStmt::Param { default, .. } => {
            if let Some(default) = default {
                walk_expr(owner, default, visit);
            }
        }
        DaStmt::Expr(expr) => walk_expr(owner, expr, visit),
        DaStmt::Decl(decl) => walk_decl(decl, visit),
    }
}

fn walk_expr(owner: &str, expr: &DaExpr, visit: &mut dyn FnMut(&str, &DaExpr)) {
    visit(owner, expr);
    let mut sub = |e: &DaExpr| walk_expr(owner, e, visit);
    match expr {
        DaExpr::ConstInt(_)
        | DaExpr::ConstUInt(_)
        | DaExpr::ConstFloat(_)
        | DaExpr::ConstDouble(_)
        | DaExpr::ConstBool(_)
        | DaExpr::ConstString(_)
        | DaExpr::ConstNull
        | DaExpr::Var(_)
        | DaExpr::Break
        | DaExpr::Continue
        | DaExpr::Goto(_)
        | DaExpr::Label(_)
        | DaExpr::FuncRef(_)
        | DaExpr::DefaultValue(_)
        | DaExpr::TypeInfo { .. } => {}
        DaExpr::Field(e, _)
        | DaExpr::SafeField(e, _)
        | DaExpr::Op1 { expr: e, .. }
        | DaExpr::IncDec { place: e, .. }
        | DaExpr::GotoComputed(e)
        | DaExpr::Cast { expr: e, .. }
        | DaExpr::Delete(e)
        | DaExpr::Addr(e)
        | DaExpr::Deref(e)
        | DaExpr::DerefExplicit(e)
        | DaExpr::Unsafe(e) => sub(e),
        DaExpr::Index(a, b)
        | DaExpr::SafeIndex(a, b)
        | DaExpr::Assign(a, b)
        | DaExpr::Pipe(a, b)
        | DaExpr::While(a, b)
        | DaExpr::Op2 {
            left: a, right: b, ..
        }
        | DaExpr::AssignOp {
            left: a, right: b, ..
        } => {
            sub(a);
            sub(b);
        }
        DaExpr::Op3 { cond, then, else_ } => {
            sub(cond);
            sub(then);
            sub(else_);
        }
        DaExpr::Return(value) => {
            if let Some(value) = value {
                sub(value);
            }
        }
        DaExpr::Call(callee, args) | DaExpr::New(callee, args) => {
            sub(callee);
            args.iter().for_each(&mut sub);
        }
        DaExpr::Block(block) => {
            for stmt in &block.stmts {
                walk_stmt(owner, stmt, visit);
            }
        }
        DaExpr::MakeBlock { params, body } => {
            for stmt in params.iter().chain(&body.stmts) {
                walk_stmt(owner, stmt, visit);
            }
        }
        DaExpr::IfThenElse {
            cond,
            then,
            elifs,
            else_,
        } => {
            sub(cond);
            sub(then);
            for (c, b) in elifs {
                sub(c);
                sub(b);
            }
            if let Some(e) = else_ {
                sub(e);
            }
        }
        DaExpr::For { sources, body, .. } => {
            sources.iter().for_each(&mut sub);
            sub(body);
        }
        DaExpr::MakeStruct { fields, .. } => {
            for (_, value) in fields {
                sub(value);
            }
        }
        DaExpr::MakeArray(items) | DaExpr::MakeFixedArray { items, .. } => {
            items.iter().for_each(&mut sub);
        }
    }
}

/// Constructs the 0.6.4 editor does not parse or does not provide (§4).
fn dialect_sites(owner: &str, expr: &DaExpr, sites: &mut Vec<Site>) {
    let construct = match expr {
        DaExpr::Op1 { op, .. } | DaExpr::Op2 { op, .. } | DaExpr::AssignOp { op, .. }
            if op.contains('!') && *op != "!" && *op != "!=" =>
        {
            Some("a `!` original operator")
        }
        DaExpr::Call(callee, _) if matches!(&**callee, DaExpr::Var(name) if name == "memmove") => {
            Some("the `memmove` builtin")
        }
        _ => None,
    };
    if let Some(construct) = construct {
        sites.push(Site {
            construct,
            owner: owner.to_owned(),
        });
    }
}

/// Constructs that need `unsafe` in daslang, which the sandbox refuses in
/// every form (§2).  Pointer arithmetic is counted where the translator wraps
/// a `+`/`-` in `unsafe` itself, the form every pointer offset takes today.
fn unsafe_sites(owner: &str, expr: &DaExpr, sites: &mut Vec<Site>) {
    let mut push = |construct| {
        sites.push(Site {
            construct,
            owner: owner.to_owned(),
        })
    };
    match expr {
        DaExpr::Unsafe(inner) => {
            push("`unsafe`");
            if matches!(&**inner, DaExpr::Op2 { op: "+" | "-", .. }) {
                push("pointer arithmetic");
            }
        }
        DaExpr::Addr(_) => push("`addr`"),
        DaExpr::Cast {
            kind: das_ast::CastKind::Reinterpret,
            ..
        } => push("`reinterpret`"),
        DaExpr::Call(callee, _) if matches!(&**callee, DaExpr::Var(name) if name == "intptr") => {
            push("`intptr`")
        }
        DaExpr::Delete(_) => push("`delete`"),
        _ => {}
    }
}
