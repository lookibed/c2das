//! `--libc std`: the libc replacement table.
//!
//! In `LibcMode::Std` a body-less external call to one of the C entry points
//! registered here is lowered to a translator-emitted `c2da_std_*` helper that
//! stands on daslib/daslang. Like `runtime.rs`, this module builds
//! `DaDecl`/`DaExpr` values and never repairs printed text: every ABI crossing
//! (C pointer <-> raw address, C string <-> daslang `string`, C variadic tail
//! <-> `array<C2daVaArg>`) is an explicit node in the generated AST.
//!
//! Nothing here is reachable in `LibcMode::NoStd`, which is the default: the
//! helper set is empty, the `require` list stays empty, and the generated
//! module is byte for byte what it was before this module existed.
use super::runtime::RuntimeArgKind;
use super::*;
use std::cell::Cell;
use std::cell::RefCell;
use std::collections::BTreeMap;

// Per-translation-unit arenas, drained by `translate_impl`, exactly like the
// builtin prelude helpers:
//
// * `REQUIRED_HELPERS` — the helpers this unit needs, built once each and keyed
//   by name so the emitted order is stable.
// * `ENTRY_DECLARATIONS` — the exported zero-argument `main` wrapper, when the
//   unit has a C `main(argc, argv)`. It calls a function declared later in the
//   module, so it is emitted after every value declaration.
// * `PRELUDE_USED` — whether anything pulled in the std prelude at all, which
//   is what decides the module's `require` lines.
thread_local! {
    static REQUIRED_HELPERS: RefCell<BTreeMap<String, DaDecl>> = RefCell::new(BTreeMap::new());
    static ENTRY_DECLARATIONS: RefCell<Vec<DaDecl>> = const { RefCell::new(Vec::new()) };
    static PRELUDE_USED: Cell<bool> = const { Cell::new(false) };
}

/// Module names the std prelude stands on. They are added to the generated
/// module's `require` list only when a std helper is actually emitted.
///
/// `strings` provides `to_char`/`character_at`, `daslib/fio` the file API.
/// `fmt`, `print`, `get_command_line_arguments` and `ref_time_ticks` are
/// builtins and need no `require` of their own.
pub(crate) const STD_MODULE_REQUIRES: &[&str] = &["strings", "daslib/fio"];

// Helper names. One constant per emitted `def`, so a caller can never name a
// helper the module does not build.
const BYTE: &str = "c2da_std_byte";
const STRING: &str = "c2da_std_string";
const STORE: &str = "c2da_std_store";
const ARG_I64: &str = "c2da_std_arg_i64";
const ARG_U64: &str = "c2da_std_arg_u64";
const ARG_F64: &str = "c2da_std_arg_f64";
const PAD: &str = "c2da_std_pad";
const FORMAT: &str = "c2da_std_format";
const PRINTF: &str = "c2da_std_printf";
const FILE_OF: &str = "c2da_std_file";
const FOPEN: &str = "c2da_std_fopen";
const FCLOSE: &str = "c2da_std_fclose";
const FFLUSH: &str = "c2da_std_fflush";
const FREAD: &str = "c2da_std_fread";
const FSEEK: &str = "c2da_std_fseek";
const FTELL: &str = "c2da_std_ftell";
const SETVBUF: &str = "c2da_std_setvbuf";
const CLOCK_GETTIME: &str = "c2da_std_clock_gettime";
const EXIT: &str = "c2da_std_exit";
const STDOUT: &str = "c2da_std_stdout";
const STDERR: &str = "c2da_std_stderr";
const STDIN: &str = "c2da_std_stdin";

/// A C library entry point the `std` policy replaces.
///
/// This is the sole registry shared by call lowering and helper generation; a
/// name that is not here stays an unsupported external call, whatever the
/// mode.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum StdFunction {
    Printf,
    Fopen,
    Fread,
    Fclose,
    Fflush,
    Fseek,
    Ftell,
    Setvbuf,
    ClockGettime,
    Exit,
}

impl StdFunction {
    pub(crate) fn target_name(self) -> &'static str {
        match self {
            Self::Printf => PRINTF,
            Self::Fopen => FOPEN,
            Self::Fread => FREAD,
            Self::Fclose => FCLOSE,
            Self::Fflush => FFLUSH,
            Self::Fseek => FSEEK,
            Self::Ftell => FTELL,
            Self::Setvbuf => SETVBUF,
            Self::ClockGettime => CLOCK_GETTIME,
            Self::Exit => EXIT,
        }
    }

    /// The conversion the argument at `index` crosses on the way into the
    /// helper. Only C pointers cross: everything the helper takes as a pointer
    /// is a raw `uint64` address, exactly like the raw-memory runtime.
    pub(crate) fn arg_kind(self, index: usize) -> Option<RuntimeArgKind> {
        let raw = match self {
            Self::Printf | Self::Fopen | Self::Exit => &[][..],
            Self::Fread => &[0usize, 3][..],
            Self::Fclose | Self::Fflush | Self::Fseek | Self::Ftell => &[0][..],
            Self::Setvbuf => &[0, 1][..],
            Self::ClockGettime => &[1][..],
        };
        raw.contains(&index).then_some(RuntimeArgKind::RawAddress)
    }

    /// True when the helper returns an address the call site has to materialize
    /// as the C pointer type the call expression demands.
    pub(crate) fn returns_raw_address(self) -> bool {
        matches!(self, Self::Fopen)
    }
}

/// The `std` replacement for a C entry point, or `None` when the name is not
/// part of the table.
pub(crate) fn std_function(name: &str) -> Option<StdFunction> {
    match name {
        "printf" | "__builtin_printf" => Some(StdFunction::Printf),
        "fopen" | "__builtin_fopen" => Some(StdFunction::Fopen),
        "fread" => Some(StdFunction::Fread),
        "fclose" => Some(StdFunction::Fclose),
        "fflush" | "__builtin_fflush" => Some(StdFunction::Fflush),
        "fseek" => Some(StdFunction::Fseek),
        "ftell" => Some(StdFunction::Ftell),
        "setvbuf" => Some(StdFunction::Setvbuf),
        "clock_gettime" => Some(StdFunction::ClockGettime),
        "exit" | "__builtin_exit" => Some(StdFunction::Exit),
        _ => None,
    }
}

/// The helper that yields the address of a standard stream, for the three
/// `extern FILE *` objects C programs reference by name.
pub(crate) fn std_stream(name: &str) -> Option<&'static str> {
    match name {
        "stdout" => Some(STDOUT),
        "stderr" => Some(STDERR),
        "stdin" => Some(STDIN),
        _ => None,
    }
}

/// Clears the helper set at the start of a translation unit.
pub(crate) fn reset() {
    REQUIRED_HELPERS.with(|helpers| helpers.borrow_mut().clear());
    ENTRY_DECLARATIONS.with(|entries| entries.borrow_mut().clear());
    PRELUDE_USED.with(|used| used.set(false));
}

/// The prelude declarations for every std helper this translation unit used,
/// emptying the set. Module-level objects come first: a daScript global has to
/// be declared before the initializer that names it.
pub(crate) fn take_declarations() -> Vec<DaDecl> {
    REQUIRED_HELPERS.with(|helpers| {
        let taken = std::mem::take(&mut *helpers.borrow_mut());
        let (objects, functions): (Vec<DaDecl>, Vec<DaDecl>) = taken
            .into_values()
            .partition(|decl| matches!(decl, DaDecl::Variable(_)));
        objects.into_iter().chain(functions).collect()
    })
}

/// The exported entry points the `std` policy adds, emptying the set. They
/// call translated C functions, so they are emitted after every one of them.
pub(crate) fn take_entry_declarations() -> Vec<DaDecl> {
    ENTRY_DECLARATIONS.with(|entries| std::mem::take(&mut *entries.borrow_mut()))
}

/// The `require` lines the std prelude needs, or nothing when this translation
/// unit emitted no std helper at all.
pub(crate) fn module_requires() -> Vec<String> {
    if PRELUDE_USED.with(|used| used.get()) {
        STD_MODULE_REQUIRES
            .iter()
            .map(|m| (*m).to_string())
            .collect()
    } else {
        vec![]
    }
}

/// Registers `name` and everything it calls, building each declaration once.
fn require(name: &str) {
    PRELUDE_USED.with(|used| used.set(true));
    if REQUIRED_HELPERS.with(|helpers| helpers.borrow().contains_key(name)) {
        return;
    }
    for dependency in dependencies(name) {
        require(dependency);
    }
    let decl = build(name);
    REQUIRED_HELPERS.with(|helpers| {
        helpers.borrow_mut().insert(name.to_owned(), decl);
    });
}

/// Registers the helper a `std` call lowers to, and returns its daScript name.
pub(crate) fn require_function(function: StdFunction) -> &'static str {
    let name = function.target_name();
    require(name);
    name
}

/// Registers the helper a standard-stream reference lowers to.
pub(crate) fn require_stream(helper: &'static str) -> &'static str {
    require(helper);
    helper
}

/// Records the exported zero-argument `main` wrapper for a C `main(argc, argv)`.
///
/// C's `main` keeps the name the renamer gave it (`main_0`); the wrapper is the
/// process entry point daslang runs, and it is the only thing that knows how a
/// daslang command line becomes a C `argv`.
pub(crate) fn require_main_wrapper(translated_main: &str) {
    require(STORE);
    let entry = build_main_wrapper(translated_main);
    ENTRY_DECLARATIONS.with(|entries| entries.borrow_mut().push(entry));
}

fn dependencies(name: &str) -> &'static [&'static str] {
    match name {
        STRING => &[BYTE],
        FORMAT => &[BYTE, STRING, PAD, ARG_I64, ARG_U64, ARG_F64],
        PRINTF => &[FORMAT],
        FOPEN => &[STRING],
        FCLOSE | FFLUSH | FREAD | FSEEK | FTELL => &[FILE_OF],
        _ => &[],
    }
}

fn build(name: &str) -> DaDecl {
    match name {
        BYTE => build_byte(),
        STRING => build_string(),
        STORE => build_store(),
        ARG_I64 => build_arg_i64(),
        ARG_U64 => build_arg_u64(),
        ARG_F64 => build_arg_f64(),
        PAD => build_pad(),
        FORMAT => build_format(),
        PRINTF => build_printf(),
        FILE_OF => build_file_of(),
        FOPEN => build_fopen(),
        FCLOSE => build_fclose(),
        FFLUSH => build_fflush(),
        FREAD => build_fread(),
        FSEEK => build_fseek(),
        FTELL => build_ftell(),
        SETVBUF => build_setvbuf(),
        CLOCK_GETTIME => build_clock_gettime(),
        EXIT => build_exit(),
        STDOUT => build_stream(STDOUT, "fstdout"),
        STDERR => build_stream(STDERR, "fstderr"),
        STDIN => build_stream(STDIN, "fstdin"),
        other => unreachable!("unregistered std helper: {other}"),
    }
}

impl<'c> Translation<'c> {
    /// True when `--libc std` is in force for this translation unit.
    pub(crate) fn libc_std(&self) -> bool {
        self.tcfg.libc == crate::LibcMode::Std
    }

    /// The `std` replacement for a direct call, or `None` when the callee is
    /// not a body-less external declaration of a name in the table.
    ///
    /// A translation unit that defines a function of its own by one of these
    /// names keeps its own definition: the policy replaces libc, never the
    /// program.
    pub(crate) fn std_libc_call(&self, func: CExprId) -> Option<StdFunction> {
        if !self.libc_std() {
            return None;
        }
        let mut callee = func;
        while let CExprKind::ImplicitCast(_, inner, _, _, _) = &self.ast_context[callee].kind {
            callee = *inner;
        }
        let CExprKind::DeclRef(_, decl_id, _) = self.ast_context[callee].kind else {
            return None;
        };
        let CDeclKind::Function {
            ref name, body: None, ..
        } = self.ast_context[decl_id].kind
        else {
            return None;
        };
        if self.ast_context.iter_decls().any(|(_, decl)| {
            matches!(&decl.kind, CDeclKind::Function { name: other, body: Some(_), .. }
                if other == name)
        }) {
            return None;
        }
        std_function(name)
    }

    /// The daScript expression a reference to `stdout`/`stderr`/`stdin` lowers
    /// to in `std` mode: the address of the daslib stream, materialized as the
    /// C pointer type the declaration carries.
    pub(crate) fn std_stream_reference(
        &self,
        decl_id: CDeclId,
    ) -> TranslationResult<Option<DaExpr>> {
        if !self.libc_std() {
            return Ok(None);
        }
        let CDeclKind::Variable {
            ref ident,
            is_defn: false,
            typ,
            ..
        } = self.ast_context[decl_id].kind
        else {
            return Ok(None);
        };
        let Some(stream) = std_stream(ident) else {
            return Ok(None);
        };
        if !self.is_pointer_type(typ.ctype) {
            return Ok(None);
        }
        let helper = require_stream(stream);
        Ok(Some(self.raw_address_to_pointer(
            call(helper, vec![]),
            self.convert_type(typ)?,
        )))
    }

    /// True for the `extern FILE *stdout;` style declarations `std` mode owns,
    /// which therefore must not become module objects.
    pub(crate) fn is_std_stream_declaration(&self, decl_id: CDeclId) -> bool {
        if !self.libc_std() {
            return false;
        }
        let CDeclKind::Variable {
            ref ident,
            is_defn: false,
            typ,
            ..
        } = self.ast_context[decl_id].kind
        else {
            return false;
        };
        std_stream(ident).is_some() && self.is_pointer_type(typ.ctype)
    }
}

// ── daScript AST shorthands ──────────────────────────────────────────

fn var(name: &str) -> DaExpr {
    DaExpr::Var(name.to_owned())
}

fn call(name: &str, args: Vec<DaExpr>) -> DaExpr {
    DaExpr::Call(Box::new(var(name)), args)
}

fn op2(op: &'static str, left: DaExpr, right: DaExpr) -> DaExpr {
    DaExpr::Op2 {
        op,
        left: Box::new(left),
        right: Box::new(right),
    }
}

fn not(expr: DaExpr) -> DaExpr {
    DaExpr::Op1 {
        op: "!",
        expr: Box::new(expr),
    }
}

fn cast(expr: DaExpr, to: DaType) -> DaExpr {
    DaExpr::Cast {
        kind: das_ast::CastKind::Cast,
        expr: Box::new(expr),
        to,
    }
}

/// `unsafe(reinterpret<T>(expr))` — the only bit reinterpretation the std
/// helpers perform, and always at a declared ABI boundary.
fn reinterpret(expr: DaExpr, to: DaType) -> DaExpr {
    DaExpr::Unsafe(Box::new(DaExpr::Cast {
        kind: das_ast::CastKind::Reinterpret,
        expr: Box::new(expr),
        to,
    }))
}

fn text(value: &str) -> DaExpr {
    DaExpr::ConstString(value.to_owned())
}

fn int64_const(value: i64) -> DaExpr {
    cast(DaExpr::ConstInt(value), DaType::int64())
}

fn uint64_const(value: u64) -> DaExpr {
    cast(DaExpr::ConstUInt(value), DaType::uint64())
}

fn assign(target: DaExpr, value: DaExpr) -> DaStmt {
    DaStmt::Expr(DaExpr::Assign(Box::new(target), Box::new(value)))
}

fn append(target: &str, value: DaExpr) -> DaStmt {
    DaStmt::Expr(DaExpr::AssignOp {
        op: "+=",
        left: Box::new(var(target)),
        right: Box::new(value),
    })
}

/// `name = name + 1` over an `int` counter.
fn advance(name: &str) -> DaStmt {
    assign(var(name), op2("+", var(name), DaExpr::ConstInt(1)))
}

fn ret(value: DaExpr) -> DaStmt {
    DaStmt::Expr(DaExpr::Return(Some(Box::new(value))))
}

fn block(stmts: Vec<DaStmt>) -> Box<DaExpr> {
    Box::new(DaExpr::Block(DaBlock { stmts }))
}

fn if_then(cond: DaExpr, then: Vec<DaStmt>) -> DaStmt {
    DaStmt::Expr(DaExpr::IfThenElse {
        cond: Box::new(cond),
        then: block(then),
        elifs: vec![],
        else_: None,
    })
}

fn if_chain(
    cond: DaExpr,
    then: Vec<DaStmt>,
    elifs: Vec<(DaExpr, Vec<DaStmt>)>,
    else_: Option<Vec<DaStmt>>,
) -> DaStmt {
    DaStmt::Expr(DaExpr::IfThenElse {
        cond: Box::new(cond),
        then: block(then),
        elifs: elifs
            .into_iter()
            .map(|(cond, body)| (cond, DaExpr::Block(DaBlock { stmts: body })))
            .collect(),
        else_: else_.map(|body| block(body)),
    })
}

fn while_true(body: Vec<DaStmt>) -> DaStmt {
    DaStmt::Expr(DaExpr::While(
        Box::new(DaExpr::ConstBool(true)),
        block(body),
    ))
}

fn while_(cond: DaExpr, body: Vec<DaStmt>) -> DaStmt {
    DaStmt::Expr(DaExpr::While(Box::new(cond), block(body)))
}

fn let_(name: &str, init: DaExpr) -> DaStmt {
    DaStmt::Let {
        name: name.to_owned(),
        init: Some(init),
    }
}

fn local(name: &str, var_type: DaType, init: DaExpr) -> DaStmt {
    DaStmt::Var {
        name: name.to_owned(),
        var_type,
        init: Some(init),
    }
}

fn param(name: &str, param_type: DaType) -> DaStmt {
    DaStmt::Param {
        name: name.to_owned(),
        param_type,
        default: None,
        is_mutable: false,
    }
}

fn helper(name: &str, params: Vec<DaStmt>, ret_type: DaType, stmts: Vec<DaStmt>) -> DaDecl {
    DaDecl::Function(DaFunction {
        name: name.to_owned(),
        params,
        ret_type,
        body: Some(DaExpr::Block(DaBlock { stmts })),
        annotations: vec![],
        is_public: false,
        is_unsafe: false,
    })
}

/// `int8 const?` — a C `const char *` as the translator spells it.
fn c_string_type() -> DaType {
    DaType::pointer(DaType::int8().const_())
}

/// `array<C2daVaArg>` — the canonical C variadic payload (see `variadic.rs`).
fn va_args_type() -> DaType {
    DaType::array(DaType::named("C2daVaArg"))
}

/// The daslib file handle type. The C `FILE` record of the translation unit is
/// renamed away from this name in `std` mode (see `renamer.rs`), so the name is
/// unambiguous here.
fn das_file_type() -> DaType {
    DaType::pointer(DaType::named("FILE").const_())
}

// ── helper bodies ────────────────────────────────────────────────────

/// `def c2da_std_byte(s : int8 const?; index : int) : int`
fn build_byte() -> DaDecl {
    helper(
        BYTE,
        vec![param("s", c_string_type()), param("index", DaType::int())],
        DaType::int(),
        vec![
            if_then(
                op2("==", var("s"), DaExpr::ConstNull),
                vec![ret(DaExpr::ConstInt(0))],
            ),
            ret(op2(
                "&",
                cast(
                    DaExpr::Unsafe(Box::new(DaExpr::Index(
                        Box::new(var("s")),
                        Box::new(var("index")),
                    ))),
                    DaType::int(),
                ),
                DaExpr::ConstInt(255),
            )),
        ],
    )
}

/// `def c2da_std_string(s : int8 const?) : string` — a NUL-terminated C string
/// as a daslang string.
fn build_string() -> DaDecl {
    helper(
        STRING,
        vec![param("s", c_string_type())],
        DaType::string(),
        vec![
            local("out", DaType::string(), text("")),
            if_then(
                op2("==", var("s"), DaExpr::ConstNull),
                vec![ret(var("out"))],
            ),
            local("i", DaType::int(), DaExpr::ConstInt(0)),
            while_true(vec![
                let_("b", call(BYTE, vec![var("s"), var("i")])),
                if_then(
                    op2("==", var("b"), DaExpr::ConstInt(0)),
                    vec![DaStmt::Expr(DaExpr::Break)],
                ),
                append("out", call("to_char", vec![var("b")])),
                advance("i"),
            ]),
            ret(var("out")),
        ],
    )
}

/// `def c2da_std_store(s : string) : uint64` — a daslang string as a
/// NUL-terminated C string in the raw-memory heap.
fn build_store() -> DaDecl {
    let byte_at = |index: DaExpr| {
        DaExpr::Unsafe(Box::new(DaExpr::Index(
            Box::new(reinterpret(var("base"), DaType::pointer(DaType::uint8()))),
            Box::new(index),
        )))
    };
    helper(
        STORE,
        vec![param("s", DaType::string())],
        DaType::uint64(),
        vec![
            local("n", DaType::int(), call("length", vec![var("s")])),
            local(
                "base",
                DaType::uint64(),
                call(
                    "c2da_rt_malloc",
                    vec![cast(
                        op2("+", var("n"), DaExpr::ConstInt(1)),
                        DaType::uint64(),
                    )],
                ),
            ),
            local("i", DaType::int(), DaExpr::ConstInt(0)),
            while_(
                op2("<", var("i"), var("n")),
                vec![
                    assign(
                        byte_at(var("i")),
                        cast(
                            op2(
                                "&",
                                call("character_at", vec![var("s"), var("i")]),
                                DaExpr::ConstInt(255),
                            ),
                            DaType::uint8(),
                        ),
                    ),
                    advance("i"),
                ],
            ),
            assign(
                byte_at(var("n")),
                cast(DaExpr::ConstInt(0), DaType::uint8()),
            ),
            ret(var("base")),
        ],
    )
}

/// The out-of-range guard every variadic accessor opens with.
fn arg_bounds_guard(fallback: DaExpr) -> DaStmt {
    if_then(
        op2(
            "||",
            op2("<", var("index"), DaExpr::ConstInt(0)),
            op2(">=", var("index"), call("length", vec![var("args")])),
        ),
        vec![ret(fallback)],
    )
}

fn arg_params() -> Vec<DaStmt> {
    vec![param("args", va_args_type()), param("index", DaType::int())]
}

fn tag_is(tag: i64) -> DaExpr {
    op2(
        "==",
        DaExpr::Field(Box::new(var("item")), "tag".into()),
        DaExpr::ConstInt(tag),
    )
}

fn item_field(name: &str) -> DaExpr {
    DaExpr::Field(Box::new(var("item")), name.to_owned())
}

/// `def c2da_std_arg_i64(args : array<C2daVaArg>; index : int) : int64`
fn build_arg_i64() -> DaDecl {
    helper(
        ARG_I64,
        arg_params(),
        DaType::int64(),
        vec![
            arg_bounds_guard(int64_const(0)),
            let_(
                "item",
                DaExpr::Index(Box::new(var("args")), Box::new(var("index"))),
            ),
            if_then(
                tag_is(2),
                vec![ret(cast(item_field("f64"), DaType::int64()))],
            ),
            if_then(
                tag_is(3),
                vec![ret(cast(item_field("raw"), DaType::int64()))],
            ),
            ret(item_field("i64")),
        ],
    )
}

/// `def c2da_std_arg_u64(args : array<C2daVaArg>; index : int) : uint64`
fn build_arg_u64() -> DaDecl {
    helper(
        ARG_U64,
        arg_params(),
        DaType::uint64(),
        vec![
            arg_bounds_guard(uint64_const(0)),
            let_(
                "item",
                DaExpr::Index(Box::new(var("args")), Box::new(var("index"))),
            ),
            if_then(tag_is(3), vec![ret(item_field("raw"))]),
            if_then(
                tag_is(2),
                vec![ret(cast(item_field("f64"), DaType::uint64()))],
            ),
            ret(cast(item_field("i64"), DaType::uint64())),
        ],
    )
}

/// `def c2da_std_arg_f64(args : array<C2daVaArg>; index : int) : double`
fn build_arg_f64() -> DaDecl {
    helper(
        ARG_F64,
        arg_params(),
        DaType::double(),
        vec![
            arg_bounds_guard(DaExpr::ConstDouble(0.0)),
            let_(
                "item",
                DaExpr::Index(Box::new(var("args")), Box::new(var("index"))),
            ),
            if_then(tag_is(2), vec![ret(item_field("f64"))]),
            ret(cast(item_field("i64"), DaType::double())),
        ],
    )
}

/// `def c2da_std_pad(text : string; width : int; left : bool) : string` — the
/// field width of a `%s`/`%c` conversion, which daslang's `fmt` left-aligns.
fn build_pad() -> DaDecl {
    helper(
        PAD,
        vec![
            param("body", DaType::string()),
            param("width", DaType::int()),
            param("left", DaType::bool()),
        ],
        DaType::string(),
        vec![
            local(
                "gap",
                DaType::int(),
                op2("-", var("width"), call("length", vec![var("body")])),
            ),
            if_then(
                op2("<=", var("gap"), DaExpr::ConstInt(0)),
                vec![ret(var("body"))],
            ),
            local("spaces", DaType::string(), text("")),
            local("i", DaType::int(), DaExpr::ConstInt(0)),
            while_(
                op2("<", var("i"), var("gap")),
                vec![append("spaces", text(" ")), advance("i")],
            ),
            if_then(var("left"), vec![ret(op2("+", var("body"), var("spaces")))]),
            ret(op2("+", var("spaces"), var("body"))),
        ],
    )
}

/// One byte of the format string at the cursor `j`.
fn format_byte(cursor: &str) -> DaExpr {
    call(BYTE, vec![var("f"), var(cursor)])
}

fn is_byte(name: &str, code: i64) -> DaExpr {
    op2("==", var(name), DaExpr::ConstInt(code))
}

/// `def c2da_std_format(f : int8 const?; args : array<C2daVaArg>) : string`
///
/// One C conversion specification at a time: flags, width, precision and the
/// length modifier are read off the C format, then re-spelled as a daslang
/// `fmt` specification over the promoted variadic value. A specification this
/// function cannot place is copied out verbatim and consumes no argument.
fn build_format() -> DaDecl {
    // %d %i — signed, narrowed to C `int` unless the spec carried a length
    // modifier, because the canonical payload always promotes to 64 bits.
    let signed_arm = vec![
        local(
            "value",
            DaType::int64(),
            call(ARG_I64, vec![var("args"), var("next")]),
        ),
        if_then(
            not(var("wide")),
            vec![assign(
                var("value"),
                cast(cast(var("value"), DaType::int()), DaType::int64()),
            )],
        ),
        append("out", call("fmt", vec![var("spec"), var("value")])),
        advance("next"),
    ];
    // %u %x %X %o — unsigned, narrowed the same way.
    let unsigned_arm = vec![
        local(
            "uvalue",
            DaType::uint64(),
            call(ARG_U64, vec![var("args"), var("next")]),
        ),
        if_then(
            not(var("wide")),
            vec![assign(
                var("uvalue"),
                cast(cast(var("uvalue"), DaType::uint()), DaType::uint64()),
            )],
        ),
        if_then(
            op2("!=", var("conv"), DaExpr::ConstInt(117)),
            vec![append("spec", call("to_char", vec![var("conv")]))],
        ),
        append("out", call("fmt", vec![var("spec"), var("uvalue")])),
        advance("next"),
    ];
    // %c — daslang's `fmt` left-aligns a character, C right-aligns it, so the
    // field width is applied here rather than in the specification.
    let char_arm = vec![
        append(
            "out",
            call(
                PAD,
                vec![
                    call(
                        "to_char",
                        vec![op2(
                            "&",
                            cast(call(ARG_I64, vec![var("args"), var("next")]), DaType::int()),
                            DaExpr::ConstInt(255),
                        )],
                    ),
                    var("width"),
                    var("left"),
                ],
            ),
        ),
        advance("next"),
    ];
    let float_arm = vec![
        append(
            "out",
            call(
                "fmt",
                vec![
                    op2("+", var("spec"), call("to_char", vec![var("conv")])),
                    call(ARG_F64, vec![var("args"), var("next")]),
                ],
            ),
        ),
        advance("next"),
    ];
    // %s — the argument is a raw address of NUL-terminated bytes.
    let string_arm = vec![
        append(
            "out",
            call(
                PAD,
                vec![
                    call(
                        STRING,
                        vec![reinterpret(
                            call(ARG_U64, vec![var("args"), var("next")]),
                            c_string_type(),
                        )],
                    ),
                    var("width"),
                    var("left"),
                ],
            ),
        ),
        advance("next"),
    ];

    let one_of = |name: &'static str, codes: &[i64]| -> DaExpr {
        codes
            .iter()
            .map(|code| is_byte(name, *code))
            .reduce(|left, right| op2("||", left, right))
            .expect("at least one conversion character")
    };

    let conversion = if_chain(
        one_of("conv", &[100, 105]),
        signed_arm,
        vec![
            (one_of("conv", &[117, 120, 88, 111]), unsigned_arm),
            (is_byte("conv", 99), char_arm),
            (one_of("conv", &[102, 70, 101, 69, 103, 71]), float_arm),
            (is_byte("conv", 115), string_arm),
        ],
        Some(vec![append("out", var("verbatim"))]),
    );

    let flag_loop = while_true(vec![
        let_("fc", format_byte("j")),
        if_chain(
            is_byte("fc", 45),
            vec![assign(var("left"), DaExpr::ConstBool(true))],
            vec![
                (
                    is_byte("fc", 48),
                    vec![assign(var("zero"), DaExpr::ConstBool(true))],
                ),
                (
                    is_byte("fc", 43),
                    vec![assign(var("plus"), DaExpr::ConstBool(true))],
                ),
                (
                    is_byte("fc", 32),
                    vec![assign(var("blank"), DaExpr::ConstBool(true))],
                ),
                (
                    is_byte("fc", 35),
                    vec![assign(var("alt"), DaExpr::ConstBool(true))],
                ),
            ],
            Some(vec![DaStmt::Expr(DaExpr::Break)]),
        ),
        append("verbatim", call("to_char", vec![var("fc")])),
        advance("j"),
    ]);

    let digit_guard = |name: &str| {
        op2(
            "||",
            op2("<", var(name), DaExpr::ConstInt(48)),
            op2(">", var(name), DaExpr::ConstInt(57)),
        )
    };

    let width_loop = while_true(vec![
        let_("wc", format_byte("j")),
        if_then(digit_guard("wc"), vec![DaStmt::Expr(DaExpr::Break)]),
        assign(
            var("width"),
            op2(
                "+",
                op2("*", var("width"), DaExpr::ConstInt(10)),
                op2("-", var("wc"), DaExpr::ConstInt(48)),
            ),
        ),
        append("digits", call("to_char", vec![var("wc")])),
        append("verbatim", call("to_char", vec![var("wc")])),
        advance("j"),
    ]);

    let precision_block = if_then(
        op2("==", format_byte("j"), DaExpr::ConstInt(46)),
        vec![
            assign(var("precision"), text(".")),
            append("verbatim", text(".")),
            advance("j"),
            while_true(vec![
                let_("pc", format_byte("j")),
                if_then(digit_guard("pc"), vec![DaStmt::Expr(DaExpr::Break)]),
                append("precision", call("to_char", vec![var("pc")])),
                append("verbatim", call("to_char", vec![var("pc")])),
                advance("j"),
            ]),
        ],
    );

    // `l`, `ll`, `z`, `j`, `t` keep the promoted 64-bit value; `h`/`hh` are
    // read and dropped, because C already promoted the argument to `int`.
    let length_loop = while_true(vec![
        let_("lc", format_byte("j")),
        if_chain(
            one_of("lc", &[108, 122, 106, 116]),
            vec![assign(var("wide"), DaExpr::ConstBool(true))],
            vec![(
                op2("!=", var("lc"), DaExpr::ConstInt(104)),
                vec![DaStmt::Expr(DaExpr::Break)],
            )],
            None,
        ),
        append("verbatim", call("to_char", vec![var("lc")])),
        advance("j"),
    ]);

    let body = vec![
        local("out", DaType::string(), text("")),
        if_then(
            op2("==", var("f"), DaExpr::ConstNull),
            vec![ret(var("out"))],
        ),
        local("i", DaType::int(), DaExpr::ConstInt(0)),
        local("next", DaType::int(), DaExpr::ConstInt(0)),
        while_true(vec![
            let_("ch", format_byte("i")),
            if_then(is_byte("ch", 0), vec![DaStmt::Expr(DaExpr::Break)]),
            if_then(
                op2("!=", var("ch"), DaExpr::ConstInt(37)),
                vec![
                    append("out", call("to_char", vec![var("ch")])),
                    advance("i"),
                    DaStmt::Expr(DaExpr::Continue),
                ],
            ),
            local("j", DaType::int(), op2("+", var("i"), DaExpr::ConstInt(1))),
            local("verbatim", DaType::string(), text("%")),
            local("left", DaType::bool(), DaExpr::ConstBool(false)),
            local("zero", DaType::bool(), DaExpr::ConstBool(false)),
            local("plus", DaType::bool(), DaExpr::ConstBool(false)),
            local("blank", DaType::bool(), DaExpr::ConstBool(false)),
            local("alt", DaType::bool(), DaExpr::ConstBool(false)),
            local("width", DaType::int(), DaExpr::ConstInt(0)),
            local("digits", DaType::string(), text("")),
            local("precision", DaType::string(), text("")),
            local("wide", DaType::bool(), DaExpr::ConstBool(false)),
            flag_loop,
            width_loop,
            precision_block,
            length_loop,
            let_("conv", format_byte("j")),
            if_then(
                is_byte("conv", 37),
                vec![
                    append("out", text("%")),
                    assign(var("i"), op2("+", var("j"), DaExpr::ConstInt(1))),
                    DaStmt::Expr(DaExpr::Continue),
                ],
            ),
            if_then(
                is_byte("conv", 0),
                vec![
                    append("out", var("verbatim")),
                    assign(var("i"), var("j")),
                    DaStmt::Expr(DaExpr::Continue),
                ],
            ),
            append("verbatim", call("to_char", vec![var("conv")])),
            local("spec", DaType::string(), text(":")),
            if_then(var("left"), vec![append("spec", text("<"))]),
            if_chain(
                var("plus"),
                vec![append("spec", text("+"))],
                vec![(var("blank"), vec![append("spec", text(" "))])],
                None,
            ),
            if_then(var("alt"), vec![append("spec", text("#"))]),
            if_then(
                op2("&&", var("zero"), not(var("left"))),
                vec![append("spec", text("0"))],
            ),
            append("spec", var("digits")),
            append("spec", var("precision")),
            conversion,
            assign(var("i"), op2("+", var("j"), DaExpr::ConstInt(1))),
        ]),
        ret(var("out")),
    ];

    helper(
        FORMAT,
        vec![param("f", c_string_type()), param("args", va_args_type())],
        DaType::string(),
        body,
    )
}

/// `def c2da_std_printf(f : int8 const?; args : array<C2daVaArg>) : int`
fn build_printf() -> DaDecl {
    helper(
        PRINTF,
        vec![param("f", c_string_type()), param("args", va_args_type())],
        DaType::int(),
        vec![
            local(
                "body",
                DaType::string(),
                call(FORMAT, vec![var("f"), var("args")]),
            ),
            DaStmt::Expr(call("print", vec![var("body")])),
            ret(call("length", vec![var("body")])),
        ],
    )
}

/// `def c2da_std_file(handle : uint64) : FILE const?` — a C `FILE *` value back
/// as the daslib handle it was made from.
fn build_file_of() -> DaDecl {
    helper(
        FILE_OF,
        vec![param("handle", DaType::uint64())],
        das_file_type(),
        vec![ret(reinterpret(var("handle"), das_file_type()))],
    )
}

/// `def c2da_std_fopen(path : int8 const?; mode : int8 const?) : uint64`
fn build_fopen() -> DaDecl {
    helper(
        FOPEN,
        vec![
            param("path", c_string_type()),
            param("mode", c_string_type()),
        ],
        DaType::uint64(),
        vec![
            local(
                "opened",
                das_file_type(),
                call(
                    "fopen",
                    vec![
                        call(STRING, vec![var("path")]),
                        call(STRING, vec![var("mode")]),
                    ],
                ),
            ),
            if_then(
                op2("==", var("opened"), DaExpr::ConstNull),
                vec![ret(uint64_const(0))],
            ),
            ret(reinterpret(var("opened"), DaType::uint64())),
        ],
    )
}

fn null_handle_guard(fallback: DaExpr) -> DaStmt {
    if_then(
        op2("==", var("handle"), uint64_const(0)),
        vec![ret(fallback)],
    )
}

/// `def c2da_std_fclose(handle : uint64) : int`
fn build_fclose() -> DaDecl {
    helper(
        FCLOSE,
        vec![param("handle", DaType::uint64())],
        DaType::int(),
        vec![
            null_handle_guard(DaExpr::ConstInt(-1)),
            DaStmt::Expr(call("fclose", vec![call(FILE_OF, vec![var("handle")])])),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_fflush(handle : uint64) : int` — `fflush(NULL)` is a no-op
/// rather than an error, as C defines it.
fn build_fflush() -> DaDecl {
    helper(
        FFLUSH,
        vec![param("handle", DaType::uint64())],
        DaType::int(),
        vec![
            if_then(
                op2("!=", var("handle"), uint64_const(0)),
                vec![DaStmt::Expr(call(
                    "fflush",
                    vec![call(FILE_OF, vec![var("handle")])],
                ))],
            ),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_fread(dst : uint64; size : uint64; count : uint64; handle : uint64) : uint64`
fn build_fread() -> DaDecl {
    helper(
        FREAD,
        vec![
            param("dst", DaType::uint64()),
            param("size", DaType::uint64()),
            param("count", DaType::uint64()),
            param("handle", DaType::uint64()),
        ],
        DaType::uint64(),
        vec![
            if_then(
                op2(
                    "||",
                    op2("==", var("handle"), uint64_const(0)),
                    op2("==", var("dst"), uint64_const(0)),
                ),
                vec![ret(uint64_const(0))],
            ),
            local(
                "total",
                DaType::uint64(),
                op2("*", var("size"), var("count")),
            ),
            if_then(
                op2("==", var("total"), uint64_const(0)),
                vec![ret(uint64_const(0))],
            ),
            local(
                "buffer",
                DaType::pointer(DaType::uint8()),
                reinterpret(var("dst"), DaType::pointer(DaType::uint8())),
            ),
            local(
                "got",
                DaType::int(),
                DaExpr::Unsafe(Box::new(call(
                    "_builtin_read",
                    vec![
                        call(FILE_OF, vec![var("handle")]),
                        var("buffer"),
                        cast(var("total"), DaType::int()),
                    ],
                ))),
            ),
            if_then(
                op2("<=", var("got"), DaExpr::ConstInt(0)),
                vec![ret(uint64_const(0))],
            ),
            ret(op2("/", cast(var("got"), DaType::uint64()), var("size"))),
        ],
    )
}

/// `def c2da_std_fseek(handle : uint64; offset : int64; whence : int) : int`
fn build_fseek() -> DaDecl {
    helper(
        FSEEK,
        vec![
            param("handle", DaType::uint64()),
            param("offset", DaType::int64()),
            param("whence", DaType::int()),
        ],
        DaType::int(),
        vec![
            null_handle_guard(DaExpr::ConstInt(-1)),
            // C's SEEK_SET/SEEK_CUR/SEEK_END are 0/1/2; daslib names its own
            // constants, and the mapping is spelled out rather than assumed.
            local("mode", DaType::int(), var("seek_set")),
            if_chain(
                op2("==", var("whence"), DaExpr::ConstInt(1)),
                vec![assign(var("mode"), var("seek_cur"))],
                vec![(
                    op2("==", var("whence"), DaExpr::ConstInt(2)),
                    vec![assign(var("mode"), var("seek_end"))],
                )],
                None,
            ),
            DaStmt::Expr(call(
                "fseek",
                vec![
                    call(FILE_OF, vec![var("handle")]),
                    var("offset"),
                    var("mode"),
                ],
            )),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_ftell(handle : uint64) : int64`
fn build_ftell() -> DaDecl {
    helper(
        FTELL,
        vec![param("handle", DaType::uint64())],
        DaType::int64(),
        vec![
            null_handle_guard(int64_const(-1)),
            ret(call("ftell", vec![call(FILE_OF, vec![var("handle")])])),
        ],
    )
}

/// `def c2da_std_setvbuf(handle : uint64; buffer : uint64; mode : int; size : uint64) : int`
///
/// Buffering is the host runtime's business; C only promises that a successful
/// call changes nothing an conforming program can observe, so this reports
/// success and does nothing.
fn build_setvbuf() -> DaDecl {
    helper(
        SETVBUF,
        vec![
            param("handle", DaType::uint64()),
            param("buffer", DaType::uint64()),
            param("mode", DaType::int()),
            param("size", DaType::uint64()),
        ],
        DaType::int(),
        vec![ret(DaExpr::ConstInt(0))],
    )
}

/// `def c2da_std_clock_gettime(clock_id : int; ts : uint64) : int`
///
/// `ref_time_ticks` is a monotonic nanosecond counter on every platform, so the
/// two `long` fields of `struct timespec` are written straight from it. The
/// origin is arbitrary, exactly as C allows for `CLOCK_MONOTONIC`.
fn build_clock_gettime() -> DaDecl {
    let field = |index: i64| {
        DaExpr::Unsafe(Box::new(DaExpr::Index(
            Box::new(reinterpret(var("ts"), DaType::pointer(DaType::int64()))),
            Box::new(DaExpr::ConstInt(index)),
        )))
    };
    helper(
        CLOCK_GETTIME,
        vec![
            param("clock_id", DaType::int()),
            param("ts", DaType::uint64()),
        ],
        DaType::int(),
        vec![
            if_then(
                op2("==", var("ts"), uint64_const(0)),
                vec![ret(DaExpr::ConstInt(-1))],
            ),
            local("ns", DaType::int64(), call("ref_time_ticks", vec![])),
            assign(field(0), op2("/", var("ns"), int64_const(1000000000))),
            assign(field(1), op2("%", var("ns"), int64_const(1000000000))),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_exit(code : int)`
fn build_exit() -> DaDecl {
    helper(
        EXIT,
        vec![param("code", DaType::int())],
        DaType::void(),
        vec![DaStmt::Expr(DaExpr::Unsafe(Box::new(call(
            "exit",
            vec![var("code")],
        ))))],
    )
}

/// `def c2da_std_stdout() : uint64` and its two siblings — a standard stream's
/// daslib handle as the address a C `FILE *` carries.
fn build_stream(name: &str, daslib_name: &str) -> DaDecl {
    helper(
        name,
        vec![],
        DaType::uint64(),
        vec![
            local("stream", das_file_type(), call(daslib_name, vec![])),
            ret(reinterpret(var("stream"), DaType::uint64())),
        ],
    )
}

/// `[export] def main() : int` — the process entry point for a C
/// `main(argc, argv)`.
///
/// daslang hands the whole command line to the program, including its own
/// arguments. The C program sees element 0 and, when the command line has a
/// `--` separator, everything after it; without a separator it sees the whole
/// list. `daslang prog.das -- input` and `./prog input` therefore both reach
/// C as `argv = [program, input]`.
fn build_main_wrapper(translated_main: &str) -> DaDecl {
    let slot = |index: DaExpr| {
        DaExpr::Unsafe(Box::new(DaExpr::Index(
            Box::new(reinterpret(
                var("argv_bytes"),
                DaType::pointer(DaType::uint64()),
            )),
            Box::new(index),
        )))
    };
    let argv_pointer = reinterpret(
        var("argv_bytes"),
        DaType::pointer(DaType::pointer(DaType::int8())),
    );
    DaDecl::Function(DaFunction {
        name: "main".to_owned(),
        params: vec![],
        ret_type: DaType::int(),
        body: Some(DaExpr::Block(DaBlock {
            stmts: vec![
                let_("raw", call("get_command_line_arguments", vec![])),
                if_then(
                    op2("==", call("length", vec![var("raw")]), DaExpr::ConstInt(0)),
                    vec![ret(call(
                        translated_main,
                        vec![DaExpr::ConstInt(0), DaExpr::ConstNull],
                    ))],
                ),
                local("first", DaType::int(), DaExpr::ConstInt(1)),
                local("i", DaType::int(), DaExpr::ConstInt(0)),
                while_(
                    op2("<", var("i"), call("length", vec![var("raw")])),
                    vec![
                        if_then(
                            op2(
                                "==",
                                DaExpr::Index(Box::new(var("raw")), Box::new(var("i"))),
                                text("--"),
                            ),
                            vec![
                                assign(var("first"), op2("+", var("i"), DaExpr::ConstInt(1))),
                                DaStmt::Expr(DaExpr::Break),
                            ],
                        ),
                        advance("i"),
                    ],
                ),
                local(
                    "argc",
                    DaType::int(),
                    op2(
                        "+",
                        DaExpr::ConstInt(1),
                        op2("-", call("length", vec![var("raw")]), var("first")),
                    ),
                ),
                if_then(
                    op2("<", var("argc"), DaExpr::ConstInt(1)),
                    vec![assign(var("argc"), DaExpr::ConstInt(1))],
                ),
                local(
                    "argv_bytes",
                    DaType::uint64(),
                    call(
                        "c2da_rt_malloc",
                        vec![op2(
                            "*",
                            cast(var("argc"), DaType::uint64()),
                            uint64_const(8),
                        )],
                    ),
                ),
                assign(
                    slot(DaExpr::ConstInt(0)),
                    call(
                        STORE,
                        vec![DaExpr::Index(
                            Box::new(var("raw")),
                            Box::new(DaExpr::ConstInt(0)),
                        )],
                    ),
                ),
                local("slot", DaType::int(), DaExpr::ConstInt(1)),
                assign(var("i"), var("first")),
                while_(
                    op2("<", var("i"), call("length", vec![var("raw")])),
                    vec![
                        assign(
                            slot(var("slot")),
                            call(
                                STORE,
                                vec![DaExpr::Index(Box::new(var("raw")), Box::new(var("i")))],
                            ),
                        ),
                        advance("slot"),
                        advance("i"),
                    ],
                ),
                ret(call(translated_main, vec![var("argc"), argv_pointer])),
            ],
        })),
        annotations: vec!["export".to_owned()],
        is_public: false,
        is_unsafe: false,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn std_table_names_match_their_helpers() {
        for (source, target) in [
            ("printf", PRINTF),
            ("fopen", FOPEN),
            ("fread", FREAD),
            ("fclose", FCLOSE),
            ("fflush", FFLUSH),
            ("fseek", FSEEK),
            ("ftell", FTELL),
            ("setvbuf", SETVBUF),
            ("clock_gettime", CLOCK_GETTIME),
            ("exit", EXIT),
        ] {
            let function = std_function(source).expect("registered std symbol");
            assert_eq!(function.target_name(), target);
        }
        assert_eq!(std_function("qsort"), None);
    }

    #[test]
    fn only_pointer_arguments_cross_as_raw_addresses() {
        assert_eq!(StdFunction::Printf.arg_kind(0), None);
        assert_eq!(
            StdFunction::Fread.arg_kind(0),
            Some(RuntimeArgKind::RawAddress)
        );
        assert_eq!(StdFunction::Fread.arg_kind(1), None);
        assert_eq!(
            StdFunction::Fread.arg_kind(3),
            Some(RuntimeArgKind::RawAddress)
        );
        assert_eq!(
            StdFunction::ClockGettime.arg_kind(1),
            Some(RuntimeArgKind::RawAddress)
        );
        assert!(StdFunction::Fopen.returns_raw_address());
        assert!(!StdFunction::Ftell.returns_raw_address());
    }

    #[test]
    fn every_registered_helper_can_be_built() {
        reset();
        for name in [
            PRINTF,
            FOPEN,
            FREAD,
            FCLOSE,
            FFLUSH,
            FSEEK,
            FTELL,
            SETVBUF,
            CLOCK_GETTIME,
            EXIT,
            STDOUT,
            STDERR,
            STDIN,
            STORE,
        ] {
            require(name);
        }
        let declarations = take_declarations();
        assert!(declarations.len() >= 14);
        assert_eq!(module_requires(), vec!["strings", "daslib/fio"]);
        reset();
        assert!(module_requires().is_empty());
    }
}
