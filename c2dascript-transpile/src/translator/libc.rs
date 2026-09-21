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
use crate::format_translation_err;
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
    static LAYOUT: Cell<StdLayout> = const { Cell::new(StdLayout::UNKNOWN) };
}

/// The C object-layout facts the helpers need, taken from the translation
/// unit's own Clang-exported types rather than assumed (see `layout.rs`).
///
/// `pointer` is the layout of a C data pointer — an `argv` slot, and the
/// alignment every raw block the helpers allocate is rounded to. `timespec`
/// is the byte offset and width of `struct timespec`'s two fields, in the
/// order C declares them, and is only consulted by `clock_gettime`.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct StdLayout {
    pointer_size: u64,
    pointer_align: u64,
    timespec_sec: (u64, u64),
    timespec_nsec: (u64, u64),
}

impl StdLayout {
    /// The value a helper built outside a translation unit sees. No helper
    /// that reads these fields can be built without
    /// `Translation::require_std_function` or
    /// `Translation::require_std_main_wrapper` installing the unit's real
    /// facts first, and both refuse the helpers that need them when the unit's
    /// Clang facts do not carry them.
    const UNKNOWN: Self = Self {
        pointer_size: 0,
        pointer_align: 0,
        timespec_sec: (0, 0),
        timespec_nsec: (0, 0),
    };
}

fn layout() -> StdLayout {
    LAYOUT.with(|facts| facts.get())
}

/// Module names the std prelude stands on. They are added to the generated
/// module's `require` list only when a std helper is actually emitted.
///
/// `strings` provides `to_char`/`character_at`/`ends_with`, `daslib/fio` the
/// file API and `exit_now`/`funbuffered`. `fmt`, `print`, `panic`,
/// `get_command_line_arguments`, `ref_time_ticks` and `get_clock` are builtins
/// and need no `require` of their own.
///
/// Every one of those names is spelled unqualified by the helpers, so every
/// one of them is reserved in the module's value namespace — see
/// `renamer.rs`'s `DASCRIPT_STD_LIBC_VALUE_NAMESPACE`, which a new helper that
/// names a new daslib symbol has to extend.
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
const REPEAT: &str = "c2da_std_repeat";
const UTOA: &str = "c2da_std_utoa";
const NUMBER: &str = "c2da_std_number";
const TAKE: &str = "c2da_std_take";
const LOST_CELL: &str = "c2da_std_lost_bytes";
const VFORMAT: &str = "c2da_std_vformat";
const FORMAT: &str = "c2da_std_format";
const PRINTF: &str = "c2da_std_printf";
const RAW_BYTE: &str = "c2da_std_raw_byte";
const RAW_PUT: &str = "c2da_std_raw_put";
const RAW_STRING: &str = "c2da_std_raw_string";
const STORE_ADDR: &str = "c2da_std_store_addr";
const WRITE: &str = "c2da_std_write";
const PLACE: &str = "c2da_std_place";
const STRLEN: &str = "c2da_std_strlen";
const STRCMP: &str = "c2da_std_strcmp";
const STRNCMP: &str = "c2da_std_strncmp";
const STRCPY: &str = "c2da_std_strcpy";
const STRNCPY: &str = "c2da_std_strncpy";
const STRCAT: &str = "c2da_std_strcat";
const STRCHR: &str = "c2da_std_strchr";
const STRRCHR: &str = "c2da_std_strrchr";
const STRSTR: &str = "c2da_std_strstr";
const DIGIT: &str = "c2da_std_digit";
const STRTO: &str = "c2da_std_strto";
const STRTOLL: &str = "c2da_std_strtoll";
const STRTOULL: &str = "c2da_std_strtoull";
const ATOI: &str = "c2da_std_atoi";
const ERRNO_CELL: &str = "c2da_std_errno_cell";
const ERRNO_LOCATION: &str = "c2da_std_errno_location";
const SET_ERRNO: &str = "c2da_std_set_errno";
const ABORT: &str = "c2da_std_abort";
const PUTS: &str = "c2da_std_puts";
const FPUTS: &str = "c2da_std_fputs";
const PUTCHAR: &str = "c2da_std_putchar";
const FPRINTF: &str = "c2da_std_fprintf";
const SNPRINTF: &str = "c2da_std_snprintf";
const VSNPRINTF: &str = "c2da_std_vsnprintf";
const FWRITE: &str = "c2da_std_fwrite";
const ISSPACE: &str = "c2da_std_isspace";
const ISDIGIT: &str = "c2da_std_isdigit";
const ISALPHA: &str = "c2da_std_isalpha";
const ISALNUM: &str = "c2da_std_isalnum";
const ISUPPER: &str = "c2da_std_isupper";
const ISLOWER: &str = "c2da_std_islower";
const ISPRINT: &str = "c2da_std_isprint";
const ISXDIGIT: &str = "c2da_std_isxdigit";
const TOLOWER: &str = "c2da_std_tolower";
const TOUPPER: &str = "c2da_std_toupper";

/// `errno` values the `strto*` family reports, spelled as glibc defines them
/// so a translated program's `#include <errno.h>` comparison still matches.
const ERANGE: i64 = 34;
const EINVAL: i64 = 22;
const ENOMEM: i64 = 12;

/// The signed and unsigned magnitude caps the shared `strto*` engine clamps to.
/// C's `long` is 64 bits on every target this translator supports, so
/// `strtol`/`strtoll` and `strtoul`/`strtoull` share one implementation.
const INT64_MAX_MAGNITUDE: u64 = 0x7fff_ffff_ffff_ffff;
const INT64_MIN_MAGNITUDE: u64 = 0x8000_0000_0000_0000;
const UINT64_MAX_MAGNITUDE: u64 = 0xffff_ffff_ffff_ffff;

/// The exit status `abort()` leaves behind: 128 + SIGABRT, which is what a
/// shell reports for a C program that really aborted.
const ABORT_STATUS: i64 = 134;
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
    Abort,
    Strlen,
    Strcmp,
    Strncmp,
    Strcpy,
    Strncpy,
    Strcat,
    Strchr,
    Strrchr,
    Strstr,
    /// `strtol` and `strtoll` alike: C's `long` is 64 bits here.
    Strtol,
    /// `strtoul` and `strtoull` alike.
    Strtoul,
    Atoi,
    Puts,
    Fputs,
    Putchar,
    Fprintf,
    Snprintf,
    Vsnprintf,
    Fwrite,
    Isspace,
    Isdigit,
    Isalpha,
    Isalnum,
    Isupper,
    Islower,
    Isprint,
    Isxdigit,
    Tolower,
    Toupper,
    ErrnoLocation,
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
            Self::Abort => ABORT,
            Self::Strlen => STRLEN,
            Self::Strcmp => STRCMP,
            Self::Strncmp => STRNCMP,
            Self::Strcpy => STRCPY,
            Self::Strncpy => STRNCPY,
            Self::Strcat => STRCAT,
            Self::Strchr => STRCHR,
            Self::Strrchr => STRRCHR,
            Self::Strstr => STRSTR,
            Self::Strtol => STRTOLL,
            Self::Strtoul => STRTOULL,
            Self::Atoi => ATOI,
            Self::Puts => PUTS,
            Self::Fputs => FPUTS,
            Self::Putchar => PUTCHAR,
            Self::Fprintf => FPRINTF,
            Self::Snprintf => SNPRINTF,
            Self::Vsnprintf => VSNPRINTF,
            Self::Fwrite => FWRITE,
            Self::Isspace => ISSPACE,
            Self::Isdigit => ISDIGIT,
            Self::Isalpha => ISALPHA,
            Self::Isalnum => ISALNUM,
            Self::Isupper => ISUPPER,
            Self::Islower => ISLOWER,
            Self::Isprint => ISPRINT,
            Self::Isxdigit => ISXDIGIT,
            Self::Tolower => TOLOWER,
            Self::Toupper => TOUPPER,
            Self::ErrnoLocation => ERRNO_LOCATION,
        }
    }

    /// The conversion the argument at `index` crosses on the way into the
    /// helper. Only C pointers cross: everything the helper takes as a pointer
    /// is a raw `uint64` address, exactly like the raw-memory runtime.
    pub(crate) fn arg_kind(self, index: usize) -> Option<RuntimeArgKind> {
        let raw = match self {
            Self::Printf | Self::Fopen | Self::Exit | Self::Abort | Self::Putchar => &[][..],
            Self::Isspace
            | Self::Isdigit
            | Self::Isalpha
            | Self::Isalnum
            | Self::Isupper
            | Self::Islower
            | Self::Isprint
            | Self::Isxdigit
            | Self::Tolower
            | Self::Toupper
            | Self::ErrnoLocation => &[][..],
            Self::Fread => &[0usize, 3][..],
            Self::Fwrite => &[0, 3][..],
            Self::Fclose | Self::Fflush | Self::Fseek | Self::Ftell => &[0][..],
            Self::Setvbuf => &[0, 1][..],
            Self::ClockGettime => &[1][..],
            // The NUL-terminated string family reads and writes the module's
            // raw memory, exactly like the `mem*` runtime: every C `char *`
            // crosses as the address it is.
            Self::Strlen | Self::Strchr | Self::Strrchr | Self::Atoi | Self::Puts => &[0][..],
            Self::Strcmp | Self::Strcpy | Self::Strcat | Self::Strstr | Self::Fputs => &[0, 1][..],
            Self::Strncmp | Self::Strncpy => &[0, 1][..],
            // `nptr` and the `char **endptr` the conversion stores through.
            Self::Strtol | Self::Strtoul => &[0, 1][..],
            // The format string itself stays a typed C pointer, as `printf`'s
            // does; only the stream handle and the output buffer are addresses.
            Self::Fprintf => &[0][..],
            Self::Snprintf | Self::Vsnprintf => &[0][..],
        };
        raw.contains(&index).then_some(RuntimeArgKind::RawAddress)
    }

    /// True when the helper, or one it calls, reads a C object whose layout
    /// the Clang facts own: the `errno` cell every conversion writes through,
    /// and `struct timespec`.
    fn reads_c_layout(self) -> bool {
        matches!(
            self,
            Self::ErrnoLocation
                | Self::Strtol
                | Self::Strtoul
                | Self::Atoi
                | Self::Fopen
                | Self::Fread
                | Self::ClockGettime
        )
    }

    /// The index of the `printf`-style format string among the call's
    /// arguments, for the conversions this engine checks at translation time.
    fn format_argument(self) -> Option<usize> {
        match self {
            Self::Printf => Some(0),
            Self::Fprintf => Some(1),
            Self::Snprintf | Self::Vsnprintf => Some(2),
            _ => None,
        }
    }

    /// True when the helper returns an address the call site has to materialize
    /// as the C pointer type the call expression demands.
    pub(crate) fn returns_raw_address(self) -> bool {
        matches!(
            self,
            Self::Fopen
                | Self::Strcpy
                | Self::Strncpy
                | Self::Strcat
                | Self::Strchr
                | Self::Strrchr
                | Self::Strstr
                | Self::ErrnoLocation
        )
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
        "abort" | "__builtin_abort" => Some(StdFunction::Abort),
        "strlen" | "__builtin_strlen" => Some(StdFunction::Strlen),
        "strcmp" | "__builtin_strcmp" => Some(StdFunction::Strcmp),
        "strncmp" | "__builtin_strncmp" => Some(StdFunction::Strncmp),
        "strcpy" | "__builtin_strcpy" => Some(StdFunction::Strcpy),
        "strncpy" | "__builtin_strncpy" => Some(StdFunction::Strncpy),
        "strcat" | "__builtin_strcat" => Some(StdFunction::Strcat),
        "strchr" | "__builtin_strchr" => Some(StdFunction::Strchr),
        "strrchr" | "__builtin_strrchr" => Some(StdFunction::Strrchr),
        "strstr" | "__builtin_strstr" => Some(StdFunction::Strstr),
        // `long` and `long long` are both 64 bits on every supported target.
        "strtol" | "strtoll" | "__builtin_strtol" | "__builtin_strtoll" => {
            Some(StdFunction::Strtol)
        }
        "strtoul" | "strtoull" | "__builtin_strtoul" | "__builtin_strtoull" => {
            Some(StdFunction::Strtoul)
        }
        "atoi" | "__builtin_atoi" => Some(StdFunction::Atoi),
        "puts" | "__builtin_puts" => Some(StdFunction::Puts),
        "fputs" | "__builtin_fputs" => Some(StdFunction::Fputs),
        "putchar" | "__builtin_putchar" => Some(StdFunction::Putchar),
        "fprintf" | "__builtin_fprintf" => Some(StdFunction::Fprintf),
        "snprintf" | "__builtin_snprintf" => Some(StdFunction::Snprintf),
        "vsnprintf" | "__builtin_vsnprintf" => Some(StdFunction::Vsnprintf),
        "fwrite" => Some(StdFunction::Fwrite),
        "isspace" => Some(StdFunction::Isspace),
        "isdigit" => Some(StdFunction::Isdigit),
        "isalpha" => Some(StdFunction::Isalpha),
        "isalnum" => Some(StdFunction::Isalnum),
        "isupper" => Some(StdFunction::Isupper),
        "islower" => Some(StdFunction::Islower),
        "isprint" => Some(StdFunction::Isprint),
        "isxdigit" => Some(StdFunction::Isxdigit),
        "tolower" => Some(StdFunction::Tolower),
        "toupper" => Some(StdFunction::Toupper),
        // glibc's `errno` *is* this function: the data symbol is
        // `GLIBC_PRIVATE`, so no C program can reach the variable directly.
        "__errno_location" => Some(StdFunction::ErrnoLocation),
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
    LAYOUT.with(|facts| facts.set(StdLayout::UNKNOWN));
}

/// Installs the C layout facts the helpers of this translation unit are built
/// from. Called before every `require`, and idempotent: the facts are a
/// property of the unit, not of the helper.
fn set_layout(facts: StdLayout) {
    LAYOUT.with(|current| current.set(facts));
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
///
/// The unit's C layout facts are installed first: a helper that reads memory
/// the C program declared (`struct timespec`, an `argv` slot) is built from
/// the Clang-exported layout of those very types, never from an assumed ABI.
fn require_function_with(facts: StdLayout, function: StdFunction) -> &'static str {
    set_layout(facts);
    let name = function.target_name();
    require(name);
    name
}

/// Registers the helper a standard-stream reference lowers to.
pub(crate) fn require_stream(helper: &'static str) -> &'static str {
    require(helper);
    helper
}

/// Records the exported zero-argument `main` wrapper for a C `main`.
///
/// C's `main` keeps the name the renamer gave it (`main_0`); the wrapper is the
/// process entry point daslang runs, and it is the only thing that knows how a
/// daslang command line becomes a C `argv`.
fn require_main_wrapper_with(facts: StdLayout, translated_main: &str, arity: usize) {
    set_layout(facts);
    if arity >= 2 {
        require(STORE);
    }
    let entry = build_main_wrapper(translated_main, arity);
    ENTRY_DECLARATIONS.with(|entries| entries.borrow_mut().push(entry));
}

fn dependencies(name: &str) -> &'static [&'static str] {
    match name {
        STRING => &[BYTE],
        TAKE => &[BYTE],
        PAD => &[REPEAT],
        NUMBER => &[UTOA, REPEAT],
        VFORMAT => &[
            BYTE, STRING, TAKE, PAD, NUMBER, UTOA, ARG_I64, ARG_U64, ARG_F64, LOST_CELL,
        ],
        FORMAT => &[VFORMAT],
        PRINTF => &[FORMAT, LOST_CELL],
        FOPEN => &[STRING, SET_ERRNO],
        FFLUSH => &[FILE_OF, STDOUT, STDERR],
        SETVBUF => &[FILE_OF],
        CLOCK_GETTIME => &[SET_ERRNO],
        FREAD => &[FILE_OF, SET_ERRNO],
        FCLOSE | FSEEK | FTELL | FWRITE => &[FILE_OF],
        RAW_STRING => &[RAW_BYTE],
        WRITE => &[FILE_OF],
        PLACE => &[RAW_PUT],
        STRLEN | STRCHR | STRRCHR | STRSTR => &[RAW_BYTE],
        STRCMP | STRNCMP => &[RAW_BYTE],
        STRCPY | STRNCPY => &[RAW_BYTE, RAW_PUT],
        STRCAT => &[RAW_BYTE, RAW_PUT, STRLEN, STRCPY],
        STRTO => &[RAW_BYTE, DIGIT, ISSPACE, STORE_ADDR, SET_ERRNO],
        STRTOLL | STRTOULL | ATOI => &[STRTO],
        ERRNO_LOCATION => &[ERRNO_CELL, RAW_PUT],
        SET_ERRNO => &[ERRNO_LOCATION],
        ABORT => &[WRITE, STDERR],
        PUTS => &[RAW_STRING, WRITE, STDOUT],
        PUTCHAR => &[WRITE, STDOUT],
        FPUTS => &[RAW_STRING, WRITE],
        FPRINTF => &[FORMAT, WRITE, LOST_CELL],
        SNPRINTF => &[FORMAT, PLACE, LOST_CELL],
        VSNPRINTF => &[VFORMAT, PLACE, LOST_CELL],
        ISALNUM => &[ISALPHA, ISDIGIT],
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
        REPEAT => build_repeat(),
        UTOA => build_utoa(),
        NUMBER => build_number(),
        TAKE => build_take(),
        LOST_CELL => build_lost_cell(),
        VFORMAT => build_vformat(),
        FORMAT => build_format(),
        PRINTF => build_printf(),
        RAW_BYTE => build_raw_byte(),
        RAW_PUT => build_raw_put(),
        RAW_STRING => build_raw_string(),
        STORE_ADDR => build_store_addr(),
        WRITE => build_write(),
        PLACE => build_place(),
        STRLEN => build_strlen(),
        STRCMP => build_strcmp(),
        STRNCMP => build_strncmp(),
        STRCPY => build_strcpy(),
        STRNCPY => build_strncpy(),
        STRCAT => build_strcat(),
        STRCHR => build_strchr(),
        STRRCHR => build_strrchr(),
        STRSTR => build_strstr(),
        DIGIT => build_digit(),
        STRTO => build_strto(),
        STRTOLL => build_strtoll(),
        STRTOULL => build_strtoull(),
        ATOI => build_atoi(),
        ERRNO_CELL => build_errno_cell(),
        ERRNO_LOCATION => build_errno_location(),
        SET_ERRNO => build_set_errno(),
        ABORT => build_abort(),
        PUTS => build_puts(),
        FPUTS => build_fputs(),
        PUTCHAR => build_putchar(),
        FPRINTF => build_fprintf(),
        SNPRINTF => build_snprintf(),
        VSNPRINTF => build_vsnprintf(),
        FWRITE => build_fwrite(),
        ISSPACE => build_isspace(),
        ISDIGIT => build_ctype(ISDIGIT, in_range(48, 57)),
        ISALPHA => build_ctype(ISALPHA, letter()),
        ISALNUM => build_isalnum(),
        ISUPPER => build_ctype(ISUPPER, in_range(65, 90)),
        ISLOWER => build_ctype(ISLOWER, in_range(97, 122)),
        ISPRINT => build_ctype(ISPRINT, in_range(32, 126)),
        ISXDIGIT => build_ctype(
            ISXDIGIT,
            op2(
                "||",
                in_range(48, 57),
                op2("||", in_range(97, 102), in_range(65, 70)),
            ),
        ),
        TOLOWER => build_tolower(),
        TOUPPER => build_toupper(),
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

    /// The C layout facts the std helpers are built from, read off the
    /// translation unit's own Clang-exported types.
    ///
    /// The pointer layout comes from a C data pointer the unit declares —
    /// every std helper that touches memory is reached through one — and the
    /// `struct timespec` offsets from that record's own fields. A unit whose
    /// Clang facts carry neither fails closed rather than assuming LP64.
    fn std_layout_facts(&self) -> TranslationResult<StdLayout> {
        let mut pointer_ids: Vec<CTypeId> = self
            .ast_context
            .iter_types()
            .filter(|(_, ty)| matches!(ty.kind, CTypeKind::Pointer(_)))
            .map(|(id, _)| *id)
            .collect();
        // `iter_types` walks a hash map: sorting makes the fact the translator
        // picks a property of the C unit rather than of this run.
        pointer_ids.sort();
        let pointer = pointer_ids
            .into_iter()
            .find_map(|id| self.layout_of(id).ok())
            .ok_or_else(|| {
                TranslationError::generic(
                    "--libc std: the translation unit declares no C pointer to take the target pointer layout from",
                )
            })?;
        let (timespec_sec, timespec_nsec) = self.timespec_fields()?;
        Ok(StdLayout {
            pointer_size: pointer.size_bytes,
            pointer_align: pointer.align_bytes,
            timespec_sec,
            timespec_nsec,
        })
    }

    /// `struct timespec`'s two fields as (offset, width) pairs, or zeroes when
    /// the unit never declares the record. `clock_gettime` is the only helper
    /// that reads them, and it cannot be called without the declaration.
    fn timespec_fields(&self) -> TranslationResult<((u64, u64), (u64, u64))> {
        let record = self.ast_context.iter_decls().find_map(|(id, decl)| {
            matches!(&decl.kind, CDeclKind::Struct { name: Some(n), fields: Some(_), .. } if n == "timespec")
                .then_some(*id)
        });
        let Some(record) = record else {
            return Ok(((0, 0), (0, 0)));
        };
        let layout = self.record_layout(record)?;
        let mut found: Vec<(u64, u64)> = vec![];
        for (field_id, offset_bits) in &layout.field_offsets_bits {
            let CDeclKind::Field { typ, .. } = self.ast_context[*field_id].kind else {
                continue;
            };
            if offset_bits % 8 != 0 {
                return Err(TranslationError::generic(
                    "--libc std: struct timespec has a bitfield member",
                ));
            }
            let offset = offset_bits / 8;
            let width = self.layout_of(typ.ctype)?.size_bytes;
            // The helper addresses a member as an index into an array of its
            // own type, which is only the same byte for a naturally placed
            // member. Every C ABI places `tv_sec` and `tv_nsec` that way.
            if width == 0 || offset % width != 0 {
                return Err(TranslationError::generic(
                    "--libc std: struct timespec has an unnaturally placed member",
                ));
            }
            found.push((offset, width));
        }
        if found.len() < 2 {
            return Err(TranslationError::generic(
                "--libc std: struct timespec does not declare tv_sec and tv_nsec",
            ));
        }
        Ok((found[0], found[1]))
    }

    /// Registers the helper a `std` call lowers to, and returns its daScript
    /// name.
    pub(crate) fn require_std_function(
        &self,
        function: StdFunction,
    ) -> TranslationResult<&'static str> {
        let facts = match self.std_layout_facts() {
            Ok(facts) => facts,
            // A helper that reads no C object — `exit`, the ctype table, the
            // pure string comparisons — needs no layout fact at all, so a unit
            // that declares no pointer type still translates.
            Err(_) if !function.reads_c_layout() => StdLayout::UNKNOWN,
            Err(error) => return Err(error),
        };
        if function == StdFunction::ClockGettime && facts.timespec_sec.1 == 0 {
            return Err(TranslationError::generic(
                "--libc std: clock_gettime needs the C declaration of struct timespec",
            ));
        }
        Ok(require_function_with(facts, function))
    }

    /// Records the exported zero-argument `main` wrapper for this unit's C
    /// `main`, whatever its parameter list.
    pub(crate) fn require_std_main_wrapper(
        &self,
        translated_main: &str,
        decl_id: CDeclId,
        arity: usize,
    ) -> TranslationResult<()> {
        if arity > 2 {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[decl_id].loc),
                "--libc std: unsupported C main signature with {} parameters",
                arity
            ));
        }
        // A `main(void)` or `main(argc)` wrapper builds no `argv` block, so it
        // reads no C layout fact; only the two-parameter form does.
        let facts = if arity >= 2 {
            self.std_layout_facts()?
        } else {
            StdLayout::UNKNOWN
        };
        require_main_wrapper_with(facts, translated_main, arity);
        Ok(())
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

    /// Fails closed on a conversion `c2da_std_vformat` does not implement.
    ///
    /// Only a literal format can be checked here, and only a literal format
    /// needs to be: a conversion the engine does not know would otherwise have
    /// to guess how many variadic arguments it consumes, and every later
    /// conversion in the same call would read the wrong one. A computed format
    /// is checked by the helper itself, at run time, where it fails loudly for
    /// the same reason.
    pub(crate) fn check_std_format(
        &self,
        function: Option<StdFunction>,
        args: &[CExprId],
    ) -> TranslationResult<()> {
        let Some(index) = function.and_then(StdFunction::format_argument) else {
            return Ok(());
        };
        let Some(&arg) = args.get(index) else {
            return Ok(());
        };
        let Some(bytes) = self.string_literal_bytes(arg) else {
            return Ok(());
        };
        if let Some(spelled) = unsupported_conversion(&bytes) {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[arg].loc),
                "--libc std: printf conversion `{}` is not implemented",
                spelled
            ));
        }
        Ok(())
    }

    /// The bytes of a narrow C string literal, through the casts that decay it
    /// to `const char *`.
    fn string_literal_bytes(&self, expr: CExprId) -> Option<Vec<u8>> {
        let mut current = expr;
        loop {
            match &self.ast_context[current].kind {
                CExprKind::ImplicitCast(_, inner, _, _, _)
                | CExprKind::ExplicitCast(_, inner, _, _, _) => current = *inner,
                CExprKind::Literal(_, CLiteral::String(bytes, 1)) => return Some(bytes.clone()),
                _ => return None,
            }
        }
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

/// The first conversion specification in `format` that `c2da_std_vformat`
/// does not implement, spelled as the C source spells it.
///
/// The grammar the engine implements, in full:
///
/// ```text
/// %[-0+ #]* [ digits | * ] [ . [ digits | * ] ] [h|hh|l|ll|z|j|t] [diuxXofFeEgG]
/// %[-0+ #]* [ digits | * ] [ . [ digits | * ] ] [csp]
/// %%
/// ```
///
/// Everything else — `%n`, `%a`, `%A`, the `'` and `I` flags, `%m`, the wide
/// `%ls`/`%lc`, `long double`'s `L` — is reported here, and a call that uses
/// one never reaches the helper.
fn unsupported_conversion(format: &[u8]) -> Option<String> {
    let mut i = 0;
    while i < format.len() {
        if format[i] != b'%' {
            i += 1;
            continue;
        }
        let start = i;
        i += 1;
        while i < format.len() && matches!(format[i], b'-' | b'0' | b'+' | b' ' | b'#') {
            i += 1;
        }
        if i < format.len() && format[i] == b'*' {
            i += 1;
        } else {
            while i < format.len() && format[i].is_ascii_digit() {
                i += 1;
            }
        }
        if i < format.len() && format[i] == b'.' {
            i += 1;
            if i < format.len() && format[i] == b'*' {
                i += 1;
            } else {
                while i < format.len() && format[i].is_ascii_digit() {
                    i += 1;
                }
            }
        }
        let modifiers = i;
        while i < format.len() && matches!(format[i], b'h' | b'l' | b'z' | b'j' | b't') {
            i += 1;
        }
        let has_modifier = i > modifiers;
        let Some(&conversion) = format.get(i) else {
            return Some(String::from_utf8_lossy(&format[start..]).into_owned());
        };
        i += 1;
        let accepted = match conversion {
            b'd' | b'i' | b'u' | b'x' | b'X' | b'o' => true,
            b'f' | b'F' | b'e' | b'E' | b'g' | b'G' => true,
            // A length modifier in front of these is the wide-character
            // family, which the canonical variadic payload cannot carry.
            b'c' | b's' | b'p' | b'%' => !has_modifier,
            _ => false,
        };
        if !accepted {
            return Some(String::from_utf8_lossy(&format[start..i]).into_owned());
        }
    }
    None
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
            local(
                "spaces",
                DaType::string(),
                call(REPEAT, vec![text(" "), var("gap")]),
            ),
            if_then(var("left"), vec![ret(op2("+", var("body"), var("spaces")))]),
            ret(op2("+", var("spaces"), var("body"))),
        ],
    )
}

/// `def c2da_std_repeat(unit : string; count : int) : string`
fn build_repeat() -> DaDecl {
    helper(
        REPEAT,
        vec![
            param("unit", DaType::string()),
            param("count", DaType::int()),
        ],
        DaType::string(),
        vec![
            local("out", DaType::string(), text("")),
            local("i", DaType::int(), DaExpr::ConstInt(0)),
            while_(
                op2("<", var("i"), var("count")),
                vec![append("out", var("unit")), advance("i")],
            ),
            ret(var("out")),
        ],
    )
}

/// `def c2da_std_utoa(value : uint64; base : int; upper : bool) : string` —
/// the digits of an unsigned value, with no sign, prefix, padding or
/// precision. This is the one place the std prelude turns an integer into
/// text: daslang's own `fmt` cannot express C's precision rule (see
/// `build_number`), so no integer conversion goes through it.
fn build_utoa() -> DaDecl {
    let digit_char = if_chain(
        op2("<", var("d"), DaExpr::ConstInt(10)),
        vec![assign(
            var("code"),
            op2("+", DaExpr::ConstInt(48), var("d")),
        )],
        vec![(
            var("upper"),
            vec![assign(
                var("code"),
                op2("+", DaExpr::ConstInt(55), var("d")),
            )],
        )],
        Some(vec![assign(
            var("code"),
            op2("+", DaExpr::ConstInt(87), var("d")),
        )]),
    );
    helper(
        UTOA,
        vec![
            param("value", DaType::uint64()),
            param("base", DaType::int()),
            param("upper", DaType::bool()),
        ],
        DaType::string(),
        vec![
            if_then(
                op2("==", var("value"), uint64_const(0)),
                vec![ret(text("0"))],
            ),
            local(
                "radix",
                DaType::uint64(),
                cast(var("base"), DaType::uint64()),
            ),
            local("rest", DaType::uint64(), var("value")),
            local("out", DaType::string(), text("")),
            while_(
                op2("!=", var("rest"), uint64_const(0)),
                vec![
                    local(
                        "d",
                        DaType::int(),
                        cast(op2("%", var("rest"), var("radix")), DaType::int()),
                    ),
                    local("code", DaType::int(), DaExpr::ConstInt(48)),
                    digit_char,
                    assign(
                        var("out"),
                        op2("+", call("to_char", vec![var("code")]), var("out")),
                    ),
                    assign(var("rest"), op2("/", var("rest"), var("radix"))),
                ],
            ),
            ret(var("out")),
        ],
    )
}

/// `def c2da_std_number(value : uint64; base : int; upper : bool; sign : string;
///                      alt : bool; has_precision : bool; precision : int;
///                      width : int; left : bool; zero : bool) : string`
///
/// One whole C integer conversion field, as C99 7.19.6.1 defines it and glibc
/// implements it:
///
/// * the precision is the *minimum* number of digits, zero-filled on the left;
///   a precision of zero prints nothing at all for the value zero;
/// * a precision makes the `0` flag inoperative;
/// * `#` prefixes `0x`/`0X` to a non-zero hexadecimal value and forces a
///   leading `0` on an octal one, after the precision has been applied;
/// * the sign — `-`, or `+`/space when the conversion is signed and the flag
///   asked for one — sits in front of the zero padding, never behind it;
/// * the field width pads with spaces, on the right when `-` was given.
///
/// daslang's `fmt` has no precision for integers (it throws on `%.5d`) and
/// would print a sign for an unsigned value, so none of this can be delegated.
fn build_number() -> DaDecl {
    let octal_prefix = if_then(
        op2("==", var("base"), DaExpr::ConstInt(8)),
        vec![if_chain(
            op2(
                "==",
                call("length", vec![var("digits")]),
                DaExpr::ConstInt(0),
            ),
            vec![assign(var("digits"), text("0"))],
            vec![(
                op2(
                    "!=",
                    call("character_at", vec![var("digits"), DaExpr::ConstInt(0)]),
                    DaExpr::ConstInt(48),
                ),
                vec![assign(var("digits"), op2("+", text("0"), var("digits")))],
            )],
            None,
        )],
    );
    let hex_prefix = if_then(
        op2(
            "&&",
            op2("==", var("base"), DaExpr::ConstInt(16)),
            op2("!=", var("value"), uint64_const(0)),
        ),
        vec![if_chain(
            var("upper"),
            vec![append("prefix", text("0X"))],
            vec![],
            Some(vec![append("prefix", text("0x"))]),
        )],
    );
    helper(
        NUMBER,
        vec![
            param("value", DaType::uint64()),
            param("base", DaType::int()),
            param("upper", DaType::bool()),
            param("sign", DaType::string()),
            param("alt", DaType::bool()),
            param("has_precision", DaType::bool()),
            param("precision", DaType::int()),
            param("width", DaType::int()),
            param("left", DaType::bool()),
            param("zero", DaType::bool()),
        ],
        DaType::string(),
        vec![
            local(
                "digits",
                DaType::string(),
                call(UTOA, vec![var("value"), var("base"), var("upper")]),
            ),
            if_then(
                var("has_precision"),
                vec![if_chain(
                    op2(
                        "&&",
                        op2("==", var("precision"), DaExpr::ConstInt(0)),
                        op2("==", var("value"), uint64_const(0)),
                    ),
                    vec![assign(var("digits"), text(""))],
                    vec![(
                        op2("<", call("length", vec![var("digits")]), var("precision")),
                        vec![assign(
                            var("digits"),
                            op2(
                                "+",
                                call(
                                    REPEAT,
                                    vec![
                                        text("0"),
                                        op2(
                                            "-",
                                            var("precision"),
                                            call("length", vec![var("digits")]),
                                        ),
                                    ],
                                ),
                                var("digits"),
                            ),
                        )],
                    )],
                    None,
                )],
            ),
            local("prefix", DaType::string(), var("sign")),
            if_then(var("alt"), vec![hex_prefix, octal_prefix]),
            local(
                "body",
                DaType::string(),
                op2("+", var("prefix"), var("digits")),
            ),
            local(
                "gap",
                DaType::int(),
                op2("-", var("width"), call("length", vec![var("body")])),
            ),
            if_then(
                op2("<=", var("gap"), DaExpr::ConstInt(0)),
                vec![ret(var("body"))],
            ),
            if_then(
                var("left"),
                vec![ret(op2(
                    "+",
                    var("body"),
                    call(REPEAT, vec![text(" "), var("gap")]),
                ))],
            ),
            if_then(
                op2("&&", var("zero"), not(var("has_precision"))),
                vec![ret(op2(
                    "+",
                    op2(
                        "+",
                        var("prefix"),
                        call(REPEAT, vec![text("0"), var("gap")]),
                    ),
                    var("digits"),
                ))],
            ),
            ret(op2(
                "+",
                call(REPEAT, vec![text(" "), var("gap")]),
                var("body"),
            )),
        ],
    )
}

/// `def c2da_std_take(s : int8 const?; limit : int) : string` — at most
/// `limit` bytes of a C string, stopping at the terminator.
///
/// C's `%.Ns` does not require the argument to be NUL-terminated at all past
/// the `N`th byte, so the precision is a read limit here, not a truncation of
/// something already read.
fn build_take() -> DaDecl {
    helper(
        TAKE,
        vec![param("s", c_string_type()), param("limit", DaType::int())],
        DaType::string(),
        vec![
            local("out", DaType::string(), text("")),
            if_then(
                op2("==", var("s"), DaExpr::ConstNull),
                vec![ret(var("out"))],
            ),
            local("i", DaType::int(), DaExpr::ConstInt(0)),
            while_(
                op2("<", var("i"), var("limit")),
                vec![
                    let_("ch", call(BYTE, vec![var("s"), var("i")])),
                    if_then(is_byte("ch", 0), vec![DaStmt::Expr(DaExpr::Break)]),
                    append("out", call("to_char", vec![var("ch")])),
                    advance("i"),
                ],
            ),
            ret(var("out")),
        ],
    )
}

/// `var c2da_std_lost_bytes : int = 0` — how many bytes the last conversion
/// produced that a daslang `string` cannot carry.
///
/// A daslang string is NUL-terminated C storage: `to_char(0)` is the empty
/// string, and appending it is a no-op (measured). C's `%c` of `'\0'` writes
/// one NUL byte, so the byte itself is lost — but `printf`'s *return value* is
/// the number of bytes the conversion produced, and that stays exact because
/// every conversion that drops a byte counts it here. This is the one C
/// behaviour the std engine reproduces in the count and not in the stream.
fn build_lost_cell() -> DaDecl {
    DaDecl::Variable(DaVariable {
        name: LOST_CELL.to_owned(),
        var_type: DaType::int(),
        init: Some(DaExpr::ConstInt(0)),
        annotations: vec![],
    })
}

/// One byte of the format string at the cursor `j`.
fn format_byte(cursor: &str) -> DaExpr {
    call(BYTE, vec![var("f"), var(cursor)])
}

fn is_byte(name: &str, code: i64) -> DaExpr {
    op2("==", var(name), DaExpr::ConstInt(code))
}

/// `def c2da_std_format(f : int8 const?; args : array<C2daVaArg>) : string` —
/// the whole promoted-argument array, from its first element.
fn build_format() -> DaDecl {
    helper(
        FORMAT,
        vec![param("f", c_string_type()), param("args", va_args_type())],
        DaType::string(),
        vec![ret(call(
            VFORMAT,
            vec![var("f"), var("args"), DaExpr::ConstInt(0)],
        ))],
    )
}

/// `def c2da_std_vformat(f : int8 const?; args : array<C2daVaArg>; start : int) : string`
///
/// One C conversion specification at a time: flags, width, precision and the
/// length modifier are read off the C format and applied to the promoted
/// variadic value.
///
/// Integer conversions are formatted by `c2da_std_number`, not by daslang's
/// `fmt`: `fmt` has no precision for integers and prints a sign for unsigned
/// ones, neither of which is what C says. Floating-point conversions still go
/// through `fmt`, whose specification is re-spelled here.
///
/// A conversion this engine does not implement never reaches here from a
/// literal format — `Translation::check_std_format` fails closed on it at
/// translation time. From a computed format it raises a daslang error rather
/// than printing something whose later conversions would read the wrong
/// arguments.
///
/// `start` is the index the first conversion reads, which is what makes the
/// `v*printf` family work: a forwarded `va_list` is a cursor into this very
/// array (see `variadic.rs`), and the cursor's index is where its arguments
/// begin.
fn build_vformat() -> DaDecl {
    // %d %i — signed, narrowed to C `int` unless the spec carried a length
    // modifier, because the canonical payload always promotes to 64 bits.
    // The magnitude is taken on the raw bits so that LONG_MIN, whose negation
    // does not fit a signed 64-bit value, still prints its digits.
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
        local(
            "magnitude",
            DaType::uint64(),
            reinterpret(var("value"), DaType::uint64()),
        ),
        local("sign", DaType::string(), text("")),
        if_chain(
            op2("<", var("value"), int64_const(0)),
            vec![
                assign(var("sign"), text("-")),
                assign(
                    var("magnitude"),
                    op2("-", uint64_const(0), var("magnitude")),
                ),
            ],
            vec![
                (var("plus"), vec![assign(var("sign"), text("+"))]),
                (var("blank"), vec![assign(var("sign"), text(" "))]),
            ],
            None,
        ),
        append(
            "out",
            call(
                NUMBER,
                vec![
                    var("magnitude"),
                    DaExpr::ConstInt(10),
                    DaExpr::ConstBool(false),
                    var("sign"),
                    DaExpr::ConstBool(false),
                    var("has_precision"),
                    var("precision"),
                    var("width"),
                    var("left"),
                    var("zero"),
                ],
            ),
        ),
        advance("next"),
    ];
    // %u %x %X %o — unsigned, narrowed the same way. C prints no sign for an
    // unsigned conversion, so `+` and space are read and ignored, exactly as
    // glibc ignores them.
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
        local("radix", DaType::int(), DaExpr::ConstInt(10)),
        if_chain(
            op2("||", is_byte("conv", 120), is_byte("conv", 88)),
            vec![assign(var("radix"), DaExpr::ConstInt(16))],
            vec![(
                is_byte("conv", 111),
                vec![assign(var("radix"), DaExpr::ConstInt(8))],
            )],
            None,
        ),
        append(
            "out",
            call(
                NUMBER,
                vec![
                    var("uvalue"),
                    var("radix"),
                    is_byte("conv", 88),
                    text(""),
                    var("alt"),
                    var("has_precision"),
                    var("precision"),
                    var("width"),
                    var("left"),
                    var("zero"),
                ],
            ),
        ),
        advance("next"),
    ];
    // %c — daslang's `fmt` left-aligns a character, C right-aligns it, so the
    // field width is applied here rather than in the specification. A `'\0'`
    // is one byte C writes and a daslang string cannot carry, so the byte is
    // counted (see `build_lost_cell`) and the field one byte narrower.
    let char_arm = vec![
        local(
            "code",
            DaType::int(),
            op2(
                "&",
                cast(call(ARG_I64, vec![var("args"), var("next")]), DaType::int()),
                DaExpr::ConstInt(255),
            ),
        ),
        local("field", DaType::int(), var("width")),
        if_then(
            is_byte("code", 0),
            vec![
                assign(
                    var(LOST_CELL),
                    op2("+", var(LOST_CELL), DaExpr::ConstInt(1)),
                ),
                assign(var("field"), op2("-", var("field"), DaExpr::ConstInt(1))),
            ],
        ),
        append(
            "out",
            call(
                PAD,
                vec![
                    call("to_char", vec![var("code")]),
                    var("field"),
                    var("left"),
                ],
            ),
        ),
        advance("next"),
    ];
    // %f %F %e %E %g %G — the one family daslang's `fmt` spells exactly as C
    // does, so the C specification is re-spelled and handed over.
    let float_arm = vec![
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
        if_then(
            op2(">", var("width"), DaExpr::ConstInt(0)),
            vec![append(
                "spec",
                call(
                    UTOA,
                    vec![
                        cast(var("width"), DaType::uint64()),
                        DaExpr::ConstInt(10),
                        DaExpr::ConstBool(false),
                    ],
                ),
            )],
        ),
        if_then(
            var("has_precision"),
            vec![
                append("spec", text(".")),
                append(
                    "spec",
                    call(
                        UTOA,
                        vec![
                            cast(var("precision"), DaType::uint64()),
                            DaExpr::ConstInt(10),
                            DaExpr::ConstBool(false),
                        ],
                    ),
                ),
            ],
        ),
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
    // %s — the argument is a raw address of NUL-terminated bytes. glibc
    // prints `(null)` for a null pointer, and nothing at all when a precision
    // shorter than `(null)` was asked for.
    let string_arm = vec![
        local(
            "address",
            DaType::uint64(),
            call(ARG_U64, vec![var("args"), var("next")]),
        ),
        local("body", DaType::string(), text("")),
        if_chain(
            op2("==", var("address"), uint64_const(0)),
            vec![if_then(
                not(op2(
                    "&&",
                    var("has_precision"),
                    op2("<", var("precision"), DaExpr::ConstInt(6)),
                )),
                vec![assign(var("body"), text("(null)"))],
            )],
            vec![(
                var("has_precision"),
                vec![assign(
                    var("body"),
                    call(
                        TAKE,
                        vec![
                            reinterpret(var("address"), c_string_type()),
                            var("precision"),
                        ],
                    ),
                )],
            )],
            Some(vec![assign(
                var("body"),
                call(STRING, vec![reinterpret(var("address"), c_string_type())]),
            )]),
        ),
        append(
            "out",
            call(PAD, vec![var("body"), var("width"), var("left")]),
        ),
        advance("next"),
    ];
    // %p — glibc prints `0x` and the lowercase hexadecimal of the value, and
    // `(nil)` for a null pointer.
    let pointer_arm = vec![
        local(
            "target",
            DaType::uint64(),
            call(ARG_U64, vec![var("args"), var("next")]),
        ),
        local("body", DaType::string(), text("(nil)")),
        if_then(
            op2("!=", var("target"), uint64_const(0)),
            vec![assign(
                var("body"),
                op2(
                    "+",
                    text("0x"),
                    call(
                        UTOA,
                        vec![
                            var("target"),
                            DaExpr::ConstInt(16),
                            DaExpr::ConstBool(false),
                        ],
                    ),
                ),
            )],
        ),
        append(
            "out",
            call(PAD, vec![var("body"), var("width"), var("left")]),
        ),
        advance("next"),
    ];
    // %n — the translation-time check refuses it for a literal format, which
    // is the only place a C program can be told about it. Reached from a
    // computed format it writes nothing and consumes the pointer argument, so
    // every later conversion still reads its own argument.
    let store_count_arm = vec![advance("next")];

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
            (is_byte("conv", 112), pointer_arm),
            (is_byte("conv", 110), store_count_arm),
        ],
        Some(vec![DaStmt::Expr(call(
            "panic",
            vec![op2(
                "+",
                text("--libc std: printf conversion is not implemented: "),
                var("verbatim"),
            )],
        ))]),
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

    // `%*d` takes the field width from the argument list; a negative one means
    // "left-adjusted, this wide", exactly as a `-` flag would.
    let width_block = if_chain(
        op2("==", format_byte("j"), DaExpr::ConstInt(42)),
        vec![
            local(
                "given",
                DaType::int(),
                cast(call(ARG_I64, vec![var("args"), var("next")]), DaType::int()),
            ),
            advance("next"),
            append("verbatim", text("*")),
            advance("j"),
            if_chain(
                op2("<", var("given"), DaExpr::ConstInt(0)),
                vec![
                    assign(var("left"), DaExpr::ConstBool(true)),
                    assign(var("width"), op2("-", DaExpr::ConstInt(0), var("given"))),
                ],
                vec![],
                Some(vec![assign(var("width"), var("given"))]),
            ),
        ],
        vec![],
        Some(vec![while_true(vec![
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
            append("verbatim", call("to_char", vec![var("wc")])),
            advance("j"),
        ])]),
    );

    // A `.` with no digits is a precision of zero; a negative `.*` is C's way
    // of saying there is no precision at all.
    let precision_block = if_then(
        op2("==", format_byte("j"), DaExpr::ConstInt(46)),
        vec![
            append("verbatim", text(".")),
            advance("j"),
            assign(var("has_precision"), DaExpr::ConstBool(true)),
            if_chain(
                op2("==", format_byte("j"), DaExpr::ConstInt(42)),
                vec![
                    local(
                        "given",
                        DaType::int(),
                        cast(call(ARG_I64, vec![var("args"), var("next")]), DaType::int()),
                    ),
                    advance("next"),
                    append("verbatim", text("*")),
                    advance("j"),
                    if_chain(
                        op2("<", var("given"), DaExpr::ConstInt(0)),
                        vec![assign(var("has_precision"), DaExpr::ConstBool(false))],
                        vec![],
                        Some(vec![assign(var("precision"), var("given"))]),
                    ),
                ],
                vec![],
                Some(vec![while_true(vec![
                    let_("pc", format_byte("j")),
                    if_then(digit_guard("pc"), vec![DaStmt::Expr(DaExpr::Break)]),
                    assign(
                        var("precision"),
                        op2(
                            "+",
                            op2("*", var("precision"), DaExpr::ConstInt(10)),
                            op2("-", var("pc"), DaExpr::ConstInt(48)),
                        ),
                    ),
                    append("verbatim", call("to_char", vec![var("pc")])),
                    advance("j"),
                ])]),
            ),
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
        assign(var(LOST_CELL), DaExpr::ConstInt(0)),
        if_then(
            op2("==", var("f"), DaExpr::ConstNull),
            vec![ret(var("out"))],
        ),
        local("i", DaType::int(), DaExpr::ConstInt(0)),
        local("next", DaType::int(), var("start")),
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
            local("has_precision", DaType::bool(), DaExpr::ConstBool(false)),
            local("precision", DaType::int(), DaExpr::ConstInt(0)),
            local("wide", DaType::bool(), DaExpr::ConstBool(false)),
            flag_loop,
            width_block,
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
            conversion,
            assign(var("i"), op2("+", var("j"), DaExpr::ConstInt(1))),
        ]),
        ret(var("out")),
    ];

    helper(
        VFORMAT,
        vec![
            param("f", c_string_type()),
            param("args", va_args_type()),
            param("start", DaType::int()),
        ],
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
            // C's answer is the number of bytes the conversion produced, which
            // includes the ones a daslang string cannot carry.
            ret(op2("+", call("length", vec![var("body")]), var(LOST_CELL))),
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
///
/// C's mode string is wider than the one daslib accepts, and daslib *throws*
/// on a mode it does not recognise (`is_valid_fopen_mode` is `[rwa][+btx]*`).
/// glibc's own extensions — `e` (close-on-exec), `m` (mmap), `c`/`noncancel`,
/// and the `,ccs=` encoding suffix — say nothing about the file's contents, so
/// they are dropped and the rest of the mode is passed on unchanged. A first
/// character that is not `r`, `w` or `a` is not a C mode at all: that fails
/// the way C does, with a null result and `EINVAL`.
fn build_fopen() -> DaDecl {
    let kept = |code: i64| op2("==", var("letter"), DaExpr::ConstInt(code));
    let sanitize = vec![
        local("spelled", DaType::string(), call(STRING, vec![var("mode")])),
        if_then(
            op2(
                "==",
                call("length", vec![var("spelled")]),
                DaExpr::ConstInt(0),
            ),
            vec![
                DaStmt::Expr(call(SET_ERRNO, vec![DaExpr::ConstInt(EINVAL)])),
                ret(uint64_const(0)),
            ],
        ),
        let_(
            "head",
            call("character_at", vec![var("spelled"), DaExpr::ConstInt(0)]),
        ),
        if_then(
            op2(
                "&&",
                op2("!=", var("head"), DaExpr::ConstInt(114)),
                op2(
                    "&&",
                    op2("!=", var("head"), DaExpr::ConstInt(119)),
                    op2("!=", var("head"), DaExpr::ConstInt(97)),
                ),
            ),
            vec![
                DaStmt::Expr(call(SET_ERRNO, vec![DaExpr::ConstInt(EINVAL)])),
                ret(uint64_const(0)),
            ],
        ),
        local(
            "accepted",
            DaType::string(),
            call("to_char", vec![var("head")]),
        ),
        local("k", DaType::int(), DaExpr::ConstInt(1)),
        while_(
            op2("<", var("k"), call("length", vec![var("spelled")])),
            vec![
                let_(
                    "letter",
                    call("character_at", vec![var("spelled"), var("k")]),
                ),
                // `,ccs=<encoding>` is a suffix, not a flag: everything from
                // the comma on belongs to it.
                if_then(
                    op2("==", var("letter"), DaExpr::ConstInt(44)),
                    vec![DaStmt::Expr(DaExpr::Break)],
                ),
                if_then(
                    op2(
                        "||",
                        kept(43),
                        op2("||", kept(98), op2("||", kept(116), kept(120))),
                    ),
                    vec![append("accepted", call("to_char", vec![var("letter")]))],
                ),
                advance("k"),
            ],
        ),
    ];
    let mut body = sanitize;
    body.extend(vec![
        local(
            "opened",
            das_file_type(),
            call(
                "fopen",
                vec![call(STRING, vec![var("path")]), var("accepted")],
            ),
        ),
        if_then(
            op2("==", var("opened"), DaExpr::ConstNull),
            vec![ret(uint64_const(0))],
        ),
        ret(reinterpret(var("opened"), DaType::uint64())),
    ]);
    helper(
        FOPEN,
        vec![
            param("path", c_string_type()),
            param("mode", c_string_type()),
        ],
        DaType::uint64(),
        body,
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

/// `def c2da_std_fflush(handle : uint64) : int`
///
/// C7.21.5.2p3: `fflush(NULL)` flushes *every* output stream, which for a
/// translated module is the two standard ones it can name. daslib's `fflush`
/// throws on a null handle, so the null case never reaches it.
fn build_fflush() -> DaDecl {
    let flush = |stream: DaExpr| DaStmt::Expr(call("fflush", vec![stream]));
    helper(
        FFLUSH,
        vec![param("handle", DaType::uint64())],
        DaType::int(),
        vec![
            if_chain(
                op2("==", var("handle"), uint64_const(0)),
                vec![
                    flush(call(FILE_OF, vec![call(STDOUT, vec![])])),
                    flush(call(FILE_OF, vec![call(STDERR, vec![])])),
                ],
                vec![],
                Some(vec![flush(call(FILE_OF, vec![var("handle")]))]),
            ),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_fread(dst : uint64; size : uint64; count : uint64; handle : uint64) : uint64`
///
/// `size * count` is a `size_t` product C never promises fits, so the overflow
/// is detected before it happens and reported as a failure with `ENOMEM`
/// rather than wrapping into a short read. The transfer itself goes through
/// daslib's 64-bit `_builtin_read64`, so a count past 2GiB is a real read.
fn build_fread() -> DaDecl {
    let too_large = vec![
        DaStmt::Expr(call(SET_ERRNO, vec![DaExpr::ConstInt(ENOMEM)])),
        ret(uint64_const(0)),
    ];
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
            if_then(
                op2(
                    "||",
                    op2("==", var("size"), uint64_const(0)),
                    op2("==", var("count"), uint64_const(0)),
                ),
                vec![ret(uint64_const(0))],
            ),
            if_then(
                op2(
                    ">",
                    var("count"),
                    op2("/", uint64_const(u64::MAX), var("size")),
                ),
                too_large.clone(),
            ),
            local(
                "total",
                DaType::uint64(),
                op2("*", var("size"), var("count")),
            ),
            // `_builtin_read64` counts in a signed 64-bit value, so a request
            // beyond its range is the same overflow one step later.
            if_then(
                op2(">", var("total"), uint64_const(INT64_MAX_MAGNITUDE)),
                too_large,
            ),
            local(
                "buffer",
                DaType::pointer(DaType::uint8()),
                reinterpret(var("dst"), DaType::pointer(DaType::uint8())),
            ),
            local(
                "got",
                DaType::int64(),
                DaExpr::Unsafe(Box::new(call(
                    "_builtin_read64",
                    vec![
                        call(FILE_OF, vec![var("handle")]),
                        var("buffer"),
                        cast(var("total"), DaType::int64()),
                    ],
                ))),
            ),
            if_then(
                op2("<=", var("got"), int64_const(0)),
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
            // daslib's `fseek` is `fseeko`: zero on success, -1 on failure,
            // which is the answer C's `fseek` gives too.
            local(
                "moved",
                DaType::int64(),
                call(
                    "fseek",
                    vec![
                        call(FILE_OF, vec![var("handle")]),
                        var("offset"),
                        var("mode"),
                    ],
                ),
            ),
            if_then(
                op2("!=", var("moved"), int64_const(0)),
                vec![ret(DaExpr::ConstInt(-1))],
            ),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_ftell(handle : uint64) : int64` — daslib's `ftell` is
/// `ftello`, so a stream that cannot report a position already answers -1, as
/// C's `ftell` does.
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
/// The one buffering change a C program makes that another part of the same
/// program can observe is turning buffering *off*: `setvbuf(stdout, NULL,
/// _IONBF, 0)` is how a program promises its output is interleaved with a
/// child's. daslib spells that `funbuffered`, so `_IONBF` (glibc's mode 2) is
/// passed on. `_IOFBF` and `_IOLBF` ask for a buffer size and a buffer the
/// module cannot hand the host runtime, and C lets an implementation choose
/// both, so they are accepted and left alone.
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
        vec![
            null_handle_guard(DaExpr::ConstInt(-1)),
            if_then(
                op2("==", var("mode"), DaExpr::ConstInt(2)),
                vec![DaStmt::Expr(call(
                    "funbuffered",
                    vec![call(FILE_OF, vec![var("handle")])],
                ))],
            ),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_clock_gettime(clock_id : int; ts : uint64) : int`
///
/// Two clocks, told apart because they measure different things:
///
/// * `CLOCK_MONOTONIC` (1), and the `_RAW`/`_COARSE`/`BOOTTIME` spellings of
///   the same counter, are `ref_time_ticks()` — a monotonic nanosecond count
///   from an arbitrary origin, which is exactly what C promises for them;
/// * `CLOCK_REALTIME` (0) and `CLOCK_REALTIME_COARSE` (5) are wall-clock time,
///   which daslib spells `get_clock()`. That builtin is C's `time()`, so its
///   resolution is one second and `tv_nsec` is always zero: a program that
///   *times* something with `CLOCK_REALTIME` sees a coarse answer, and one
///   that asks what time it is sees the right one. This is the only place the
///   std prelude is less precise than the C library, and it is a resolution
///   limit, not a wrong epoch.
///
/// Any other clock is a clock the module cannot read: it fails the way C does,
/// with -1 and `EINVAL`, rather than answering with a different clock.
///
/// The two fields are written at the offsets and widths Clang exported for the
/// unit's own `struct timespec` (see `Translation::timespec_fields`).
fn build_clock_gettime() -> DaDecl {
    let facts = layout();
    let field = |at: (u64, u64), value: DaExpr| -> DaStmt {
        let (offset, width) = at;
        let element = if width == 4 {
            DaType::int()
        } else {
            DaType::int64()
        };
        // A `struct timespec` member sits at a multiple of its own width —
        // `timespec_fields` refuses anything else — so the offset is an index
        // into the array of members the pointer reinterpretation makes.
        let index = if width == 0 {
            0
        } else {
            i64::try_from(offset / width).unwrap_or(0)
        };
        let target = DaExpr::Unsafe(Box::new(DaExpr::Index(
            Box::new(reinterpret(var("ts"), DaType::pointer(element.clone()))),
            Box::new(DaExpr::ConstInt(index)),
        )));
        assign(target, cast(value, element))
    };
    let seconds = facts.timespec_sec;
    let nanoseconds = facts.timespec_nsec;
    let monotonic = vec![
        local("ns", DaType::int64(), call("ref_time_ticks", vec![])),
        field(seconds, op2("/", var("ns"), int64_const(1000000000))),
        field(nanoseconds, op2("%", var("ns"), int64_const(1000000000))),
        ret(DaExpr::ConstInt(0)),
    ];
    let realtime = vec![
        local(
            "epoch",
            DaType::int64(),
            cast(call("get_clock", vec![]), DaType::int64()),
        ),
        field(seconds, var("epoch")),
        field(nanoseconds, int64_const(0)),
        ret(DaExpr::ConstInt(0)),
    ];
    let one_of = |codes: &[i64]| -> DaExpr {
        codes
            .iter()
            .map(|code| op2("==", var("clock_id"), DaExpr::ConstInt(*code)))
            .reduce(|left, right| op2("||", left, right))
            .expect("at least one clock id")
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
                vec![
                    DaStmt::Expr(call(SET_ERRNO, vec![DaExpr::ConstInt(EINVAL)])),
                    ret(DaExpr::ConstInt(-1)),
                ],
            ),
            if_chain(
                // CLOCK_MONOTONIC, CLOCK_MONOTONIC_RAW, CLOCK_MONOTONIC_COARSE
                // and CLOCK_BOOTTIME.
                one_of(&[1, 4, 6, 7]),
                monotonic,
                vec![(one_of(&[0, 5]), realtime)],
                Some(vec![
                    DaStmt::Expr(call(SET_ERRNO, vec![DaExpr::ConstInt(EINVAL)])),
                    ret(DaExpr::ConstInt(-1)),
                ]),
            ),
            ret(DaExpr::ConstInt(-1)),
        ],
    )
}

/// `def c2da_std_exit(code : int)`
///
/// daslib has two: `exit` prints `exit(N) called from ...` and a stack walk
/// and leaves the process with status 1, which is a debugging aid rather than
/// C's `exit`; `exit_now` flushes the standard streams and `_exit`s with the
/// status it was given, which is what C promises. A C program's exit status is
/// observable, so the silent one is the only correct choice.
fn build_exit() -> DaDecl {
    helper(
        EXIT,
        vec![param("code", DaType::int())],
        DaType::void(),
        vec![DaStmt::Expr(DaExpr::Unsafe(Box::new(call(
            "exit_now",
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

/// `[export] def main() : int` — the process entry point for this unit's C
/// `main`, whatever its parameter list.
///
/// A C `main(void)` or `main(int)` is still not a daslang entry point: daslang
/// calls a zero-argument exported function, so the wrapper exists for every C
/// `main` and simply passes fewer arguments.
///
/// ## How a daslang command line becomes a C `argv`
///
/// `get_command_line_arguments()` answers the *whole process* command line,
/// launcher and launcher flags included; every one of the four ways a
/// translated module runs spells that differently:
///
/// | launcher | the process argv |
/// |---|---|
/// | `daslang prog.das [-- args]` | `daslang prog.das [-- args]` |
/// | `daslang -jit prog.das [-- args]` | `daslang -jit prog.das [-- args]` |
/// | `daslang -exe` binary | `./prog args` |
/// | `aot_host` | `aot_host <root> prog.das <entry> [-- args]` |
///
/// One rule covers all four:
///
/// * `argv[0]` is the first element that names a daslang script (`*.das`) —
///   the program the C code was translated from — or element 0 when there is
///   none, which is the standalone binary's own path;
/// * the arguments are everything after a `--` separator; without one, they
///   are everything after the script, or the whole tail when there is no
///   script either.
///
/// `daslang prog.das -- input`, `./prog input` and `aot_host root prog.das
/// main -- input` therefore all reach C as `argv = [program, "input"]` with
/// `argc == 2`, which is what the native program sees for `./prog input`.
/// A launcher flag that follows the script (`-main`, `-jit` after the script)
/// is why an argument-less run still wants the separator: without it those
/// flags would be C arguments.
///
/// `argv[argc]` is a null pointer, as C guarantees, so `argv[argc] == NULL` is
/// the loop bound a C program is entitled to use. The slot width is the
/// target's own `sizeof(char *)`, from the Clang facts of this unit.
fn build_main_wrapper(translated_main: &str, arity: usize) -> DaDecl {
    if arity == 0 {
        return main_wrapper_decl(vec![ret(call(translated_main, vec![]))]);
    }
    let slot_bytes = layout().pointer_size;
    let slot_align = layout().pointer_align.max(1);
    let slot_type = if slot_bytes == 4 {
        DaType::uint()
    } else {
        DaType::uint64()
    };
    let slot = move |index: DaExpr| {
        DaExpr::Unsafe(Box::new(DaExpr::Index(
            Box::new(reinterpret(
                var("argv_bytes"),
                DaType::pointer(slot_type.clone()),
            )),
            Box::new(index),
        )))
    };
    let stored = move |value: DaExpr| {
        if slot_bytes == 4 {
            cast(call(STORE, vec![value]), DaType::uint())
        } else {
            call(STORE, vec![value])
        }
    };
    let null_slot = if slot_bytes == 4 {
        cast(DaExpr::ConstUInt(0), DaType::uint())
    } else {
        uint64_const(0)
    };
    let argv_pointer = reinterpret(
        var("argv_bytes"),
        DaType::pointer(DaType::pointer(DaType::int8())),
    );
    // `main(int argc)` is legal C the translator has no argv slot to fill for.
    let call_main = if arity == 1 {
        ret(call(translated_main, vec![var("argc")]))
    } else {
        ret(call(translated_main, vec![var("argc"), argv_pointer]))
    };
    let mut stmts = vec![
        let_("raw", call("get_command_line_arguments", vec![])),
        if_then(
            op2("==", call("length", vec![var("raw")]), DaExpr::ConstInt(0)),
            vec![if arity == 1 {
                ret(call(translated_main, vec![DaExpr::ConstInt(0)]))
            } else {
                ret(call(
                    translated_main,
                    vec![DaExpr::ConstInt(0), DaExpr::ConstNull],
                ))
            }],
        ),
        // The script's own place on the command line: `argv[0]`, and the
        // fallback start of the arguments when no `--` separates them.
        local("script", DaType::int(), DaExpr::ConstInt(0)),
        local("i", DaType::int(), DaExpr::ConstInt(1)),
        while_(
            op2("<", var("i"), call("length", vec![var("raw")])),
            vec![
                if_then(
                    call(
                        "ends_with",
                        vec![
                            DaExpr::Index(Box::new(var("raw")), Box::new(var("i"))),
                            text(".das"),
                        ],
                    ),
                    vec![assign(var("script"), var("i")), DaStmt::Expr(DaExpr::Break)],
                ),
                advance("i"),
            ],
        ),
        local(
            "first",
            DaType::int(),
            op2("+", var("script"), DaExpr::ConstInt(1)),
        ),
        assign(var("i"), DaExpr::ConstInt(0)),
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
    ];
    if arity == 1 {
        stmts.push(call_main);
        return main_wrapper_decl(stmts);
    }
    stmts.extend(vec![
        // One slot per argument and one more for the terminator C promises.
        // The raw-memory runtime is a bump allocator with no alignment
        // promise, and a slot is written as a whole pointer-wide word, so the
        // block is over-allocated and its base rounded up the way the `errno`
        // cell is.
        local(
            "argv_raw",
            DaType::uint64(),
            call(
                "c2da_rt_malloc",
                vec![op2(
                    "+",
                    op2(
                        "*",
                        cast(op2("+", var("argc"), DaExpr::ConstInt(1)), DaType::uint64()),
                        uint64_const(slot_bytes),
                    ),
                    uint64_const(slot_align - 1),
                )],
            ),
        ),
        local(
            "argv_bytes",
            DaType::uint64(),
            op2(
                "*",
                op2(
                    "/",
                    op2("+", var("argv_raw"), uint64_const(slot_align - 1)),
                    uint64_const(slot_align),
                ),
                uint64_const(slot_align),
            ),
        ),
        assign(
            slot(DaExpr::ConstInt(0)),
            stored(DaExpr::Index(Box::new(var("raw")), Box::new(var("script")))),
        ),
        local("at", DaType::int(), DaExpr::ConstInt(1)),
        assign(var("i"), var("first")),
        while_(
            op2("<", var("i"), call("length", vec![var("raw")])),
            vec![
                assign(
                    slot(var("at")),
                    stored(DaExpr::Index(Box::new(var("raw")), Box::new(var("i")))),
                ),
                advance("at"),
                advance("i"),
            ],
        ),
        assign(slot(var("argc")), null_slot),
        call_main,
    ]);
    main_wrapper_decl(stmts)
}

fn main_wrapper_decl(stmts: Vec<DaStmt>) -> DaDecl {
    DaDecl::Function(DaFunction {
        name: "main".to_owned(),
        params: vec![],
        ret_type: DaType::int(),
        body: Some(DaExpr::Block(DaBlock { stmts })),
        annotations: vec!["export".to_owned()],
        is_public: false,
        is_unsafe: false,
    })
}

// ── raw-memory access ────────────────────────────────────────────────
//
// The NUL-terminated string family works on the same raw addresses as the
// `c2da_rt_mem*` runtime: a C `char *` crosses as the address it is, and the
// helpers below are the only place these helpers touch a byte.

/// `unsafe(reinterpret<uint8?>(base))[index]` — one byte of the raw heap.
fn raw_slot(base: DaExpr, index: DaExpr) -> DaExpr {
    DaExpr::Unsafe(Box::new(DaExpr::Index(
        Box::new(reinterpret(base, DaType::pointer(DaType::uint8()))),
        Box::new(cast(index, DaType::int())),
    )))
}

fn ret_void() -> DaStmt {
    DaStmt::Expr(DaExpr::Return(None))
}

/// `name = name + 1` over a `uint64` cursor.
fn advance_u64(name: &str) -> DaStmt {
    assign(var(name), op2("+", var(name), uint64_const(1)))
}

fn u64_param(name: &str) -> DaStmt {
    param(name, DaType::uint64())
}

fn byte_of(base: &str, index: DaExpr) -> DaExpr {
    call(RAW_BYTE, vec![var(base), index])
}

/// `def c2da_std_raw_byte(base : uint64; index : uint64) : int`
///
/// C compares and classifies string bytes as `unsigned char`, so the byte is
/// widened, never sign-extended. A null address reads as the terminator, which
/// keeps every loop below finite on a C program that passes `NULL`.
fn build_raw_byte() -> DaDecl {
    helper(
        RAW_BYTE,
        vec![u64_param("base"), u64_param("index")],
        DaType::int(),
        vec![
            if_then(
                op2("==", var("base"), uint64_const(0)),
                vec![ret(DaExpr::ConstInt(0))],
            ),
            ret(op2(
                "&",
                cast(raw_slot(var("base"), var("index")), DaType::int()),
                DaExpr::ConstInt(255),
            )),
        ],
    )
}

/// `def c2da_std_raw_put(base : uint64; index : uint64; value : int)`
fn build_raw_put() -> DaDecl {
    helper(
        RAW_PUT,
        vec![
            u64_param("base"),
            u64_param("index"),
            param("value", DaType::int()),
        ],
        DaType::void(),
        vec![
            if_then(op2("==", var("base"), uint64_const(0)), vec![ret_void()]),
            assign(
                raw_slot(var("base"), var("index")),
                cast(
                    op2("&", var("value"), DaExpr::ConstInt(255)),
                    DaType::uint8(),
                ),
            ),
        ],
    )
}

/// `def c2da_std_raw_string(base : uint64) : string` — NUL-terminated raw
/// bytes as a daslang string, for the helpers that hand a whole string to
/// daslib.
fn build_raw_string() -> DaDecl {
    helper(
        RAW_STRING,
        vec![u64_param("base")],
        DaType::string(),
        vec![
            local("out", DaType::string(), text("")),
            if_then(
                op2("==", var("base"), uint64_const(0)),
                vec![ret(var("out"))],
            ),
            local("i", DaType::uint64(), uint64_const(0)),
            while_true(vec![
                let_("b", byte_of("base", var("i"))),
                if_then(
                    op2("==", var("b"), DaExpr::ConstInt(0)),
                    vec![DaStmt::Expr(DaExpr::Break)],
                ),
                append("out", call("to_char", vec![var("b")])),
                advance_u64("i"),
            ]),
            ret(var("out")),
        ],
    )
}

/// `def c2da_std_store_addr(cell : uint64; value : uint64)` — one C pointer
/// written through a `T **`, the same eight raw bytes the `main` wrapper
/// writes an `argv` slot with.
fn build_store_addr() -> DaDecl {
    helper(
        STORE_ADDR,
        vec![u64_param("cell"), u64_param("value")],
        DaType::void(),
        vec![
            if_then(op2("==", var("cell"), uint64_const(0)), vec![ret_void()]),
            assign(
                DaExpr::Unsafe(Box::new(DaExpr::Index(
                    Box::new(reinterpret(var("cell"), DaType::pointer(DaType::uint64()))),
                    Box::new(DaExpr::ConstInt(0)),
                ))),
                var("value"),
            ),
        ],
    )
}

/// `def c2da_std_write(handle : uint64; body : string)` — every byte a C
/// program prints leaves through here.
///
/// `fprint` and the builtin `print` share one stdout, in order (measured), so
/// routing `printf` through `print` and `fputs(…, stdout)` through `fprint`
/// cannot reorder a program's output.
fn build_write() -> DaDecl {
    helper(
        WRITE,
        vec![u64_param("handle"), param("body", DaType::string())],
        DaType::void(),
        vec![
            if_then(op2("==", var("handle"), uint64_const(0)), vec![ret_void()]),
            DaStmt::Expr(call(
                "fprint",
                vec![call(FILE_OF, vec![var("handle")]), var("body")],
            )),
        ],
    )
}

/// `def c2da_std_place(dst : uint64; size : uint64; body : string) : int`
///
/// The `snprintf` truncation rule: at most `size - 1` bytes plus a NUL are
/// written, `size == 0` writes nothing at all, and the return value is the
/// length the whole conversion *would* have had.
fn build_place() -> DaDecl {
    helper(
        PLACE,
        vec![
            u64_param("dst"),
            u64_param("size"),
            param("body", DaType::string()),
        ],
        DaType::int(),
        vec![
            local("n", DaType::int(), call("length", vec![var("body")])),
            if_then(
                op2(
                    "&&",
                    op2("!=", var("size"), uint64_const(0)),
                    op2("!=", var("dst"), uint64_const(0)),
                ),
                vec![
                    local(
                        "cap",
                        DaType::int(),
                        op2("-", cast(var("size"), DaType::int()), DaExpr::ConstInt(1)),
                    ),
                    local("i", DaType::int(), DaExpr::ConstInt(0)),
                    while_(
                        op2(
                            "&&",
                            op2("<", var("i"), var("n")),
                            op2("<", var("i"), var("cap")),
                        ),
                        vec![
                            DaStmt::Expr(call(
                                RAW_PUT,
                                vec![
                                    var("dst"),
                                    cast(var("i"), DaType::uint64()),
                                    call("character_at", vec![var("body"), var("i")]),
                                ],
                            )),
                            advance("i"),
                        ],
                    ),
                    DaStmt::Expr(call(
                        RAW_PUT,
                        vec![
                            var("dst"),
                            cast(var("i"), DaType::uint64()),
                            DaExpr::ConstInt(0),
                        ],
                    )),
                ],
            ),
            ret(var("n")),
        ],
    )
}

// ── the NUL-terminated string family ─────────────────────────────────

/// `def c2da_std_strlen(s : uint64) : uint64`
fn build_strlen() -> DaDecl {
    helper(
        STRLEN,
        vec![u64_param("s")],
        DaType::uint64(),
        vec![
            local("n", DaType::uint64(), uint64_const(0)),
            while_(
                op2("!=", byte_of("s", var("n")), DaExpr::ConstInt(0)),
                vec![advance_u64("n")],
            ),
            ret(var("n")),
        ],
    )
}

/// The `-1 / 0 / +1` answer C's `strcmp` family gives for two `unsigned char`
/// values that already differ.
fn order_of(left: DaExpr, right: DaExpr) -> Vec<DaStmt> {
    vec![
        if_then(op2("<", left, right), vec![ret(DaExpr::ConstInt(-1))]),
        ret(DaExpr::ConstInt(1)),
    ]
}

/// `def c2da_std_strcmp(a : uint64; b : uint64) : int`
fn build_strcmp() -> DaDecl {
    helper(
        STRCMP,
        vec![u64_param("a"), u64_param("b")],
        DaType::int(),
        vec![
            local("i", DaType::uint64(), uint64_const(0)),
            while_true(vec![
                let_("ca", byte_of("a", var("i"))),
                let_("cb", byte_of("b", var("i"))),
                if_then(
                    op2("!=", var("ca"), var("cb")),
                    order_of(var("ca"), var("cb")),
                ),
                if_then(
                    op2("==", var("ca"), DaExpr::ConstInt(0)),
                    vec![ret(DaExpr::ConstInt(0))],
                ),
                advance_u64("i"),
            ]),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_strncmp(a : uint64; b : uint64; n : uint64) : int`
fn build_strncmp() -> DaDecl {
    helper(
        STRNCMP,
        vec![u64_param("a"), u64_param("b"), u64_param("n")],
        DaType::int(),
        vec![
            local("i", DaType::uint64(), uint64_const(0)),
            while_(
                op2("<", var("i"), var("n")),
                vec![
                    let_("ca", byte_of("a", var("i"))),
                    let_("cb", byte_of("b", var("i"))),
                    if_then(
                        op2("!=", var("ca"), var("cb")),
                        order_of(var("ca"), var("cb")),
                    ),
                    if_then(
                        op2("==", var("ca"), DaExpr::ConstInt(0)),
                        vec![ret(DaExpr::ConstInt(0))],
                    ),
                    advance_u64("i"),
                ],
            ),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_strcpy(dst : uint64; src : uint64) : uint64`
fn build_strcpy() -> DaDecl {
    helper(
        STRCPY,
        vec![u64_param("dst"), u64_param("src")],
        DaType::uint64(),
        vec![
            local("i", DaType::uint64(), uint64_const(0)),
            while_true(vec![
                let_("c", byte_of("src", var("i"))),
                DaStmt::Expr(call(RAW_PUT, vec![var("dst"), var("i"), var("c")])),
                if_then(
                    op2("==", var("c"), DaExpr::ConstInt(0)),
                    vec![DaStmt::Expr(DaExpr::Break)],
                ),
                advance_u64("i"),
            ]),
            ret(var("dst")),
        ],
    )
}

/// `def c2da_std_strncpy(dst : uint64; src : uint64; n : uint64) : uint64`
///
/// C's rule in full: at most `n` bytes are copied, the destination is *not*
/// terminated when the source is longer, and the remainder is padded with NUL.
fn build_strncpy() -> DaDecl {
    helper(
        STRNCPY,
        vec![u64_param("dst"), u64_param("src"), u64_param("n")],
        DaType::uint64(),
        vec![
            local("i", DaType::uint64(), uint64_const(0)),
            while_(
                op2("<", var("i"), var("n")),
                vec![
                    let_("c", byte_of("src", var("i"))),
                    DaStmt::Expr(call(RAW_PUT, vec![var("dst"), var("i"), var("c")])),
                    if_then(
                        op2("==", var("c"), DaExpr::ConstInt(0)),
                        vec![DaStmt::Expr(DaExpr::Break)],
                    ),
                    advance_u64("i"),
                ],
            ),
            while_(
                op2("<", var("i"), var("n")),
                vec![
                    DaStmt::Expr(call(
                        RAW_PUT,
                        vec![var("dst"), var("i"), DaExpr::ConstInt(0)],
                    )),
                    advance_u64("i"),
                ],
            ),
            ret(var("dst")),
        ],
    )
}

/// `def c2da_std_strcat(dst : uint64; src : uint64) : uint64`
fn build_strcat() -> DaDecl {
    helper(
        STRCAT,
        vec![u64_param("dst"), u64_param("src")],
        DaType::uint64(),
        vec![
            DaStmt::Expr(call(
                STRCPY,
                vec![
                    op2("+", var("dst"), call(STRLEN, vec![var("dst")])),
                    var("src"),
                ],
            )),
            ret(var("dst")),
        ],
    )
}

/// `def c2da_std_strchr(s : uint64; ch : int) : uint64` — C searches for
/// `(char)ch`, and the terminating NUL is part of the string it searches.
fn build_strchr() -> DaDecl {
    helper(
        STRCHR,
        vec![u64_param("s"), param("ch", DaType::int())],
        DaType::uint64(),
        vec![
            if_then(
                op2("==", var("s"), uint64_const(0)),
                vec![ret(uint64_const(0))],
            ),
            local(
                "target",
                DaType::int(),
                op2("&", var("ch"), DaExpr::ConstInt(255)),
            ),
            local("i", DaType::uint64(), uint64_const(0)),
            while_true(vec![
                let_("b", byte_of("s", var("i"))),
                if_then(
                    op2("==", var("b"), var("target")),
                    vec![ret(op2("+", var("s"), var("i")))],
                ),
                if_then(
                    op2("==", var("b"), DaExpr::ConstInt(0)),
                    vec![DaStmt::Expr(DaExpr::Break)],
                ),
                advance_u64("i"),
            ]),
            ret(uint64_const(0)),
        ],
    )
}

/// `def c2da_std_strrchr(s : uint64; ch : int) : uint64`
fn build_strrchr() -> DaDecl {
    helper(
        STRRCHR,
        vec![u64_param("s"), param("ch", DaType::int())],
        DaType::uint64(),
        vec![
            if_then(
                op2("==", var("s"), uint64_const(0)),
                vec![ret(uint64_const(0))],
            ),
            local(
                "target",
                DaType::int(),
                op2("&", var("ch"), DaExpr::ConstInt(255)),
            ),
            local("found", DaType::uint64(), uint64_const(0)),
            local("seen", DaType::bool(), DaExpr::ConstBool(false)),
            local("i", DaType::uint64(), uint64_const(0)),
            while_true(vec![
                let_("b", byte_of("s", var("i"))),
                if_then(
                    op2("==", var("b"), var("target")),
                    vec![
                        assign(var("found"), op2("+", var("s"), var("i"))),
                        assign(var("seen"), DaExpr::ConstBool(true)),
                    ],
                ),
                if_then(
                    op2("==", var("b"), DaExpr::ConstInt(0)),
                    vec![DaStmt::Expr(DaExpr::Break)],
                ),
                advance_u64("i"),
            ]),
            if_then(not(var("seen")), vec![ret(uint64_const(0))]),
            ret(var("found")),
        ],
    )
}

/// `def c2da_std_strstr(h : uint64; n : uint64) : uint64` — an empty needle
/// matches at the front, as C says it does.
fn build_strstr() -> DaDecl {
    helper(
        STRSTR,
        vec![u64_param("h"), u64_param("n")],
        DaType::uint64(),
        vec![
            if_then(
                op2("==", var("h"), uint64_const(0)),
                vec![ret(uint64_const(0))],
            ),
            if_then(
                op2("==", byte_of("n", uint64_const(0)), DaExpr::ConstInt(0)),
                vec![ret(var("h"))],
            ),
            local("i", DaType::uint64(), uint64_const(0)),
            while_(
                op2("!=", byte_of("h", var("i")), DaExpr::ConstInt(0)),
                vec![
                    local("j", DaType::uint64(), uint64_const(0)),
                    while_(
                        op2(
                            "&&",
                            op2("!=", byte_of("n", var("j")), DaExpr::ConstInt(0)),
                            op2(
                                "==",
                                byte_of("h", op2("+", var("i"), var("j"))),
                                byte_of("n", var("j")),
                            ),
                        ),
                        vec![advance_u64("j")],
                    ),
                    if_then(
                        op2("==", byte_of("n", var("j")), DaExpr::ConstInt(0)),
                        vec![ret(op2("+", var("h"), var("i")))],
                    ),
                    advance_u64("i"),
                ],
            ),
            ret(uint64_const(0)),
        ],
    )
}

// ── string → integer ─────────────────────────────────────────────────

/// `def c2da_std_digit(ch : int; base : int) : int` — the value of one digit
/// in `base`, or `-1` when the byte is not one.
fn build_digit() -> DaDecl {
    helper(
        DIGIT,
        vec![param("ch", DaType::int()), param("base", DaType::int())],
        DaType::int(),
        vec![
            local("v", DaType::int(), DaExpr::ConstInt(-1)),
            if_chain(
                between("ch", 48, 57),
                vec![assign(var("v"), op2("-", var("ch"), DaExpr::ConstInt(48)))],
                vec![
                    (
                        between("ch", 97, 122),
                        vec![assign(
                            var("v"),
                            op2(
                                "+",
                                op2("-", var("ch"), DaExpr::ConstInt(97)),
                                DaExpr::ConstInt(10),
                            ),
                        )],
                    ),
                    (
                        between("ch", 65, 90),
                        vec![assign(
                            var("v"),
                            op2(
                                "+",
                                op2("-", var("ch"), DaExpr::ConstInt(65)),
                                DaExpr::ConstInt(10),
                            ),
                        )],
                    ),
                ],
                None,
            ),
            if_then(
                op2(
                    "||",
                    op2("<", var("v"), DaExpr::ConstInt(0)),
                    op2(">=", var("v"), var("base")),
                ),
                vec![ret(DaExpr::ConstInt(-1))],
            ),
            ret(var("v")),
        ],
    )
}

/// `def c2da_std_strto(nptr : uint64; endptr : uint64; base : int;
///                     pos_limit : uint64; neg_limit : uint64) : uint64`
///
/// The one C `strto*` conversion, as the standard spells it: leading
/// whitespace, an optional sign, the `0x`/`0` base prefix when `base` is 0 or
/// 16, digits in `base`, `*endptr` left at the first unconverted byte (or at
/// `nptr` when nothing converted), `EINVAL` for a base outside 2..36 and
/// `ERANGE` plus the saturated limit on overflow.
///
/// The result is the raw 64 bits; the signed wrapper reinterprets them, which
/// is why the negative limit is passed separately — `|LONG_MIN|` is one more
/// than `LONG_MAX`.
fn build_strto() -> DaDecl {
    let limit_over = op2("/", var("limit"), var("radix"));
    helper(
        STRTO,
        vec![
            u64_param("nptr"),
            u64_param("endptr"),
            param("base", DaType::int()),
            u64_param("pos_limit"),
            u64_param("neg_limit"),
        ],
        DaType::uint64(),
        vec![
            // An unusable base is rejected before anything is stored through
            // `endptr`, which is what glibc does: the caller's pointer keeps
            // whatever it held.
            if_then(
                op2(
                    "&&",
                    op2("!=", var("base"), DaExpr::ConstInt(0)),
                    op2(
                        "||",
                        op2("<", var("base"), DaExpr::ConstInt(2)),
                        op2(">", var("base"), DaExpr::ConstInt(36)),
                    ),
                ),
                vec![
                    DaStmt::Expr(call(SET_ERRNO, vec![DaExpr::ConstInt(EINVAL)])),
                    ret(uint64_const(0)),
                ],
            ),
            DaStmt::Expr(call(STORE_ADDR, vec![var("endptr"), var("nptr")])),
            if_then(
                op2("==", var("nptr"), uint64_const(0)),
                vec![ret(uint64_const(0))],
            ),
            local("i", DaType::uint64(), uint64_const(0)),
            while_(
                op2(
                    "!=",
                    call(ISSPACE, vec![byte_of("nptr", var("i"))]),
                    DaExpr::ConstInt(0),
                ),
                vec![advance_u64("i")],
            ),
            local("neg", DaType::bool(), DaExpr::ConstBool(false)),
            let_("sign", byte_of("nptr", var("i"))),
            if_chain(
                op2("==", var("sign"), DaExpr::ConstInt(45)),
                vec![
                    assign(var("neg"), DaExpr::ConstBool(true)),
                    advance_u64("i"),
                ],
                vec![(
                    op2("==", var("sign"), DaExpr::ConstInt(43)),
                    vec![advance_u64("i")],
                )],
                None,
            ),
            local("radix", DaType::uint64(), uint64_const(10)),
            // `0x` only introduces hexadecimal when a hexadecimal digit really
            // follows; otherwise C converts the `0` and stops.
            if_chain(
                op2(
                    "&&",
                    op2(
                        "||",
                        op2("==", var("base"), DaExpr::ConstInt(0)),
                        op2("==", var("base"), DaExpr::ConstInt(16)),
                    ),
                    op2(
                        "&&",
                        op2("==", byte_of("nptr", var("i")), DaExpr::ConstInt(48)),
                        op2(
                            "&&",
                            op2(
                                "==",
                                op2(
                                    "|",
                                    byte_of("nptr", op2("+", var("i"), uint64_const(1))),
                                    DaExpr::ConstInt(32),
                                ),
                                DaExpr::ConstInt(120),
                            ),
                            op2(
                                ">=",
                                call(
                                    DIGIT,
                                    vec![
                                        byte_of("nptr", op2("+", var("i"), uint64_const(2))),
                                        DaExpr::ConstInt(16),
                                    ],
                                ),
                                DaExpr::ConstInt(0),
                            ),
                        ),
                    ),
                ),
                vec![
                    assign(var("i"), op2("+", var("i"), uint64_const(2))),
                    assign(var("radix"), uint64_const(16)),
                ],
                vec![
                    (
                        op2("!=", var("base"), DaExpr::ConstInt(0)),
                        vec![assign(var("radix"), cast(var("base"), DaType::uint64()))],
                    ),
                    (
                        op2("==", byte_of("nptr", var("i")), DaExpr::ConstInt(48)),
                        vec![assign(var("radix"), uint64_const(8))],
                    ),
                ],
                None,
            ),
            local("limit", DaType::uint64(), var("pos_limit")),
            if_then(var("neg"), vec![assign(var("limit"), var("neg_limit"))]),
            local("acc", DaType::uint64(), uint64_const(0)),
            local("any", DaType::bool(), DaExpr::ConstBool(false)),
            local("over", DaType::bool(), DaExpr::ConstBool(false)),
            while_true(vec![
                let_(
                    "d",
                    call(
                        DIGIT,
                        vec![byte_of("nptr", var("i")), cast(var("radix"), DaType::int())],
                    ),
                ),
                if_then(
                    op2("<", var("d"), DaExpr::ConstInt(0)),
                    vec![DaStmt::Expr(DaExpr::Break)],
                ),
                assign(var("any"), DaExpr::ConstBool(true)),
                let_("dv", cast(var("d"), DaType::uint64())),
                if_chain(
                    op2(
                        "||",
                        op2(">", var("acc"), limit_over.clone()),
                        op2(
                            "&&",
                            op2("==", var("acc"), limit_over),
                            op2(">", var("dv"), op2("%", var("limit"), var("radix"))),
                        ),
                    ),
                    vec![assign(var("over"), DaExpr::ConstBool(true))],
                    vec![],
                    Some(vec![assign(
                        var("acc"),
                        op2("+", op2("*", var("acc"), var("radix")), var("dv")),
                    )]),
                ),
                advance_u64("i"),
            ]),
            if_then(not(var("any")), vec![ret(uint64_const(0))]),
            DaStmt::Expr(call(
                STORE_ADDR,
                vec![var("endptr"), op2("+", var("nptr"), var("i"))],
            )),
            if_then(
                var("over"),
                vec![
                    DaStmt::Expr(call(SET_ERRNO, vec![DaExpr::ConstInt(ERANGE)])),
                    ret(var("limit")),
                ],
            ),
            if_then(var("neg"), vec![ret(op2("-", uint64_const(0), var("acc")))]),
            ret(var("acc")),
        ],
    )
}

fn strto_call(signed: bool) -> DaExpr {
    let (pos, neg) = if signed {
        (INT64_MAX_MAGNITUDE, INT64_MIN_MAGNITUDE)
    } else {
        (UINT64_MAX_MAGNITUDE, UINT64_MAX_MAGNITUDE)
    };
    call(
        STRTO,
        vec![
            var("nptr"),
            var("endptr"),
            var("base"),
            uint64_const(pos),
            uint64_const(neg),
        ],
    )
}

fn strto_params() -> Vec<DaStmt> {
    vec![
        u64_param("nptr"),
        u64_param("endptr"),
        param("base", DaType::int()),
    ]
}

/// `def c2da_std_strtoll(nptr : uint64; endptr : uint64; base : int) : int64`
/// — also C's `strtol`, whose `long` is 64 bits here.
fn build_strtoll() -> DaDecl {
    helper(
        STRTOLL,
        strto_params(),
        DaType::int64(),
        vec![ret(cast(strto_call(true), DaType::int64()))],
    )
}

/// `def c2da_std_strtoull(nptr : uint64; endptr : uint64; base : int) : uint64`
fn build_strtoull() -> DaDecl {
    helper(
        STRTOULL,
        strto_params(),
        DaType::uint64(),
        vec![ret(strto_call(false))],
    )
}

/// `def c2da_std_atoi(nptr : uint64) : int` — `(int)strtol(nptr, NULL, 10)`,
/// which is what C says `atoi` is.
fn build_atoi() -> DaDecl {
    helper(
        ATOI,
        vec![u64_param("nptr")],
        DaType::int(),
        vec![ret(cast(
            cast(
                call(
                    STRTO,
                    vec![
                        var("nptr"),
                        uint64_const(0),
                        DaExpr::ConstInt(10),
                        uint64_const(INT64_MAX_MAGNITUDE),
                        uint64_const(INT64_MIN_MAGNITUDE),
                    ],
                ),
                DaType::int64(),
            ),
            DaType::int(),
        ))],
    )
}

// ── errno ────────────────────────────────────────────────────────────

/// `var c2da_std_errno_cell : uint64 = 0x0` — the address of the module's one
/// `errno` object, allocated on first use.
fn build_errno_cell() -> DaDecl {
    DaDecl::Variable(DaVariable {
        name: ERRNO_CELL.to_owned(),
        var_type: DaType::uint64(),
        init: Some(uint64_const(0)),
        annotations: vec![],
    })
}

/// `def c2da_std_errno_location() : uint64`
///
/// glibc's `errno` *is* `*__errno_location()`, so the translated program reads
/// and writes this cell through an ordinary C `int *`. The address is rounded
/// up to the target's pointer alignment — the strictest the Clang facts give
/// this unit — because the raw-memory runtime is a bump allocator that makes
/// no alignment promise of its own.
fn build_errno_location() -> DaDecl {
    let align = layout().pointer_align.max(4);
    let zero_byte = |index: u64| {
        DaStmt::Expr(call(
            RAW_PUT,
            vec![var("aligned"), uint64_const(index), DaExpr::ConstInt(0)],
        ))
    };
    helper(
        ERRNO_LOCATION,
        vec![],
        DaType::uint64(),
        vec![
            if_then(
                op2("==", var(ERRNO_CELL), uint64_const(0)),
                vec![
                    local(
                        "raw",
                        DaType::uint64(),
                        call("c2da_rt_malloc", vec![uint64_const(align + 4)]),
                    ),
                    if_then(
                        op2("==", var("raw"), uint64_const(0)),
                        vec![ret(uint64_const(0))],
                    ),
                    local(
                        "aligned",
                        DaType::uint64(),
                        op2(
                            "*",
                            op2(
                                "/",
                                op2("+", var("raw"), uint64_const(align - 1)),
                                uint64_const(align),
                            ),
                            uint64_const(align),
                        ),
                    ),
                    zero_byte(0),
                    zero_byte(1),
                    zero_byte(2),
                    zero_byte(3),
                    assign(var(ERRNO_CELL), var("aligned")),
                ],
            ),
            ret(var(ERRNO_CELL)),
        ],
    )
}

/// `def c2da_std_set_errno(code : int)`
fn build_set_errno() -> DaDecl {
    helper(
        SET_ERRNO,
        vec![param("code", DaType::int())],
        DaType::void(),
        vec![
            local("cell", DaType::uint64(), call(ERRNO_LOCATION, vec![])),
            if_then(op2("==", var("cell"), uint64_const(0)), vec![ret_void()]),
            assign(
                DaExpr::Unsafe(Box::new(DaExpr::Index(
                    Box::new(reinterpret(var("cell"), DaType::pointer(DaType::int()))),
                    Box::new(DaExpr::ConstInt(0)),
                ))),
                var("code"),
            ),
        ],
    )
}

// ── output and abnormal termination ──────────────────────────────────

/// `def c2da_std_abort()` — `exit` after the diagnostic C's `abort` leaves on
/// stderr. The process status is 128 + SIGABRT; a daslang module cannot raise
/// a real signal, so the *status* is reproduced rather than the mechanism.
fn build_abort() -> DaDecl {
    helper(
        ABORT,
        vec![],
        DaType::void(),
        vec![
            DaStmt::Expr(call(WRITE, vec![call(STDERR, vec![]), text("abort()\n")])),
            DaStmt::Expr(DaExpr::Unsafe(Box::new(call(
                "exit_now",
                vec![DaExpr::ConstInt(ABORT_STATUS)],
            )))),
        ],
    )
}

/// `def c2da_std_puts(s : uint64) : int`
fn build_puts() -> DaDecl {
    helper(
        PUTS,
        vec![u64_param("s")],
        DaType::int(),
        vec![
            DaStmt::Expr(call(
                WRITE,
                vec![
                    call(STDOUT, vec![]),
                    op2("+", call(RAW_STRING, vec![var("s")]), text("\n")),
                ],
            )),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_fputs(s : uint64; handle : uint64) : int`
fn build_fputs() -> DaDecl {
    helper(
        FPUTS,
        vec![u64_param("s"), u64_param("handle")],
        DaType::int(),
        vec![
            DaStmt::Expr(call(
                WRITE,
                vec![var("handle"), call(RAW_STRING, vec![var("s")])],
            )),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

/// `def c2da_std_putchar(c : int) : int` — C returns the byte it wrote.
fn build_putchar() -> DaDecl {
    helper(
        PUTCHAR,
        vec![param("c", DaType::int())],
        DaType::int(),
        vec![
            local(
                "byte",
                DaType::int(),
                op2("&", var("c"), DaExpr::ConstInt(255)),
            ),
            DaStmt::Expr(call(
                WRITE,
                vec![call(STDOUT, vec![]), call("to_char", vec![var("byte")])],
            )),
            ret(var("byte")),
        ],
    )
}

/// `def c2da_std_fprintf(handle : uint64; f : int8 const?; args : array<C2daVaArg>) : int`
fn build_fprintf() -> DaDecl {
    helper(
        FPRINTF,
        vec![
            u64_param("handle"),
            param("f", c_string_type()),
            param("args", va_args_type()),
        ],
        DaType::int(),
        vec![
            local(
                "body",
                DaType::string(),
                call(FORMAT, vec![var("f"), var("args")]),
            ),
            DaStmt::Expr(call(WRITE, vec![var("handle"), var("body")])),
            ret(op2("+", call("length", vec![var("body")]), var(LOST_CELL))),
        ],
    )
}

/// `def c2da_std_snprintf(dst : uint64; size : uint64; f : int8 const?; args : array<C2daVaArg>) : int`
fn build_snprintf() -> DaDecl {
    helper(
        SNPRINTF,
        vec![
            u64_param("dst"),
            u64_param("size"),
            param("f", c_string_type()),
            param("args", va_args_type()),
        ],
        DaType::int(),
        vec![
            local(
                "placed",
                DaType::int(),
                call(
                    PLACE,
                    vec![
                        var("dst"),
                        var("size"),
                        call(FORMAT, vec![var("f"), var("args")]),
                    ],
                ),
            ),
            ret(op2("+", var("placed"), var(LOST_CELL))),
        ],
    )
}

/// `def c2da_std_vsnprintf(dst : uint64; size : uint64; f : int8 const?;
///                         ap : C2daVaCursor; args : array<C2daVaArg>) : int`
///
/// The forwarded `va_list` is a cursor into `args` (see `variadic.rs`), which
/// the call site passes alongside it; the conversion therefore starts at the
/// cursor's own index.
fn build_vsnprintf() -> DaDecl {
    helper(
        VSNPRINTF,
        vec![
            u64_param("dst"),
            u64_param("size"),
            param("f", c_string_type()),
            param("ap", DaType::named("C2daVaCursor")),
            param("args", va_args_type()),
        ],
        DaType::int(),
        vec![
            local(
                "placed",
                DaType::int(),
                call(
                    PLACE,
                    vec![
                        var("dst"),
                        var("size"),
                        call(
                            VFORMAT,
                            vec![
                                var("f"),
                                var("args"),
                                DaExpr::Field(Box::new(var("ap")), "index".into()),
                            ],
                        ),
                    ],
                ),
            ),
            ret(op2("+", var("placed"), var(LOST_CELL))),
        ],
    )
}

/// `def c2da_std_fwrite(src : uint64; size : uint64; count : uint64; handle : uint64) : uint64`
fn build_fwrite() -> DaDecl {
    helper(
        FWRITE,
        vec![
            u64_param("src"),
            u64_param("size"),
            u64_param("count"),
            u64_param("handle"),
        ],
        DaType::uint64(),
        vec![
            if_then(
                op2(
                    "||",
                    op2("==", var("handle"), uint64_const(0)),
                    op2("==", var("src"), uint64_const(0)),
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
                reinterpret(var("src"), DaType::pointer(DaType::uint8())),
            ),
            local(
                "wrote",
                DaType::int(),
                DaExpr::Unsafe(Box::new(call(
                    "_builtin_write",
                    vec![
                        call(FILE_OF, vec![var("handle")]),
                        var("buffer"),
                        cast(var("total"), DaType::int()),
                    ],
                ))),
            ),
            if_then(
                op2("<=", var("wrote"), DaExpr::ConstInt(0)),
                vec![ret(uint64_const(0))],
            ),
            ret(op2("/", cast(var("wrote"), DaType::uint64()), var("size"))),
        ],
    )
}

// ── ctype, in the C locale ───────────────────────────────────────────

fn between(name: &str, lo: i64, hi: i64) -> DaExpr {
    op2(
        "&&",
        op2(">=", var(name), DaExpr::ConstInt(lo)),
        op2("<=", var(name), DaExpr::ConstInt(hi)),
    )
}

fn in_range(lo: i64, hi: i64) -> DaExpr {
    between("c", lo, hi)
}

fn letter() -> DaExpr {
    op2("||", in_range(65, 90), in_range(97, 122))
}

/// `def c2da_std_is…(c : int) : int` — the C locale, which is the only locale
/// a translated module has.
fn build_ctype(name: &str, cond: DaExpr) -> DaDecl {
    helper(
        name,
        vec![param("c", DaType::int())],
        DaType::int(),
        vec![
            if_then(cond, vec![ret(DaExpr::ConstInt(1))]),
            ret(DaExpr::ConstInt(0)),
        ],
    )
}

fn build_isspace() -> DaDecl {
    build_ctype(
        ISSPACE,
        op2(
            "||",
            op2("==", var("c"), DaExpr::ConstInt(32)),
            in_range(9, 13),
        ),
    )
}

fn build_isalnum() -> DaDecl {
    build_ctype(
        ISALNUM,
        op2(
            "||",
            op2("!=", call(ISALPHA, vec![var("c")]), DaExpr::ConstInt(0)),
            op2("!=", call(ISDIGIT, vec![var("c")]), DaExpr::ConstInt(0)),
        ),
    )
}

fn build_case_shift(name: &str, lo: i64, hi: i64, delta: i64) -> DaDecl {
    helper(
        name,
        vec![param("c", DaType::int())],
        DaType::int(),
        vec![
            if_then(
                in_range(lo, hi),
                vec![ret(op2("+", var("c"), DaExpr::ConstInt(delta)))],
            ),
            ret(var("c")),
        ],
    )
}

fn build_tolower() -> DaDecl {
    build_case_shift(TOLOWER, 65, 90, 32)
}

fn build_toupper() -> DaDecl {
    build_case_shift(TOUPPER, 97, 122, -32)
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
            ("abort", ABORT),
            ("strlen", STRLEN),
            ("strcmp", STRCMP),
            ("strncmp", STRNCMP),
            ("strcpy", STRCPY),
            ("strncpy", STRNCPY),
            ("strcat", STRCAT),
            ("strchr", STRCHR),
            ("strrchr", STRRCHR),
            ("strstr", STRSTR),
            // `long` and `long long` are the same 64-bit type here, so the
            // four conversions share two helpers.
            ("strtol", STRTOLL),
            ("strtoll", STRTOLL),
            ("strtoul", STRTOULL),
            ("strtoull", STRTOULL),
            ("atoi", ATOI),
            ("puts", PUTS),
            ("fputs", FPUTS),
            ("putchar", PUTCHAR),
            ("fprintf", FPRINTF),
            ("snprintf", SNPRINTF),
            ("vsnprintf", VSNPRINTF),
            ("fwrite", FWRITE),
            ("isspace", ISSPACE),
            ("isdigit", ISDIGIT),
            ("isalpha", ISALPHA),
            ("isalnum", ISALNUM),
            ("isupper", ISUPPER),
            ("islower", ISLOWER),
            ("isprint", ISPRINT),
            ("isxdigit", ISXDIGIT),
            ("tolower", TOLOWER),
            ("toupper", TOUPPER),
            ("__errno_location", ERRNO_LOCATION),
        ] {
            let function = std_function(source).expect("registered std symbol");
            assert_eq!(function.target_name(), target);
        }
        assert_eq!(std_function("qsort"), None);
        assert_eq!(std_function("strtod"), None);
        assert_eq!(std_function("__ctype_b_loc"), None);
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
        // The string family reads and writes raw addresses; a `size_t` count
        // and a `ctype` code point do not.
        assert_eq!(
            StdFunction::Strncmp.arg_kind(1),
            Some(RuntimeArgKind::RawAddress)
        );
        assert_eq!(StdFunction::Strncmp.arg_kind(2), None);
        assert_eq!(StdFunction::Isspace.arg_kind(0), None);
        assert_eq!(StdFunction::Strchr.arg_kind(1), None);
        // `fprintf`'s format string stays a typed C pointer, as `printf`'s is.
        assert_eq!(
            StdFunction::Fprintf.arg_kind(0),
            Some(RuntimeArgKind::RawAddress)
        );
        assert_eq!(StdFunction::Fprintf.arg_kind(1), None);
        assert!(StdFunction::Strchr.returns_raw_address());
        assert!(StdFunction::ErrnoLocation.returns_raw_address());
        assert!(!StdFunction::Strlen.returns_raw_address());
    }

    #[test]
    fn the_format_engine_knows_what_it_implements() {
        // Everything `build_vformat` has an arm for, and the flags, widths,
        // precisions and length modifiers it parses.
        for accepted in [
            "plain text, no conversion at all",
            "%d %i %u %x %X %o %c %s %p %%",
            "%5d %-5d %05d %+d % d %#x %#o %.5d %5.2d %.0d %.8x",
            "%*d %-*d %.*f %.*s %.3s %5.2s",
            "%ld %lld %lu %llu %zu %zd %jd %td %hd %hhd",
            "%f %F %e %E %g %G %10.3f %08.3f",
        ] {
            assert_eq!(
                unsupported_conversion(accepted.as_bytes()),
                None,
                "rejected {accepted}"
            );
        }
        // `%n` stores through a pointer, `%a` is hexadecimal floating point,
        // `%'d` groups digits, `%m` is glibc's `strerror(errno)`, `%ls` and
        // `%lc` are the wide-character family, `%Lf` is `long double`.
        for (rejected, spelled) in [
            ("x%ny", "%n"),
            ("%a", "%a"),
            ("%A", "%A"),
            ("%'d", "%'"),
            ("%m", "%m"),
            ("%ls", "%ls"),
            ("%lc", "%lc"),
            ("%Lf", "%L"),
            ("%5", "%5"),
        ] {
            assert_eq!(
                unsupported_conversion(rejected.as_bytes()).as_deref(),
                Some(spelled),
                "accepted {rejected}"
            );
        }
    }

    #[test]
    fn every_registered_helper_can_be_built() {
        reset();
        // The helpers that read a C object are built from the unit's Clang
        // facts; this stands in for a translation unit's LP64 ones.
        set_layout(StdLayout {
            pointer_size: 8,
            pointer_align: 8,
            timespec_sec: (0, 8),
            timespec_nsec: (8, 8),
        });
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
            ABORT,
            STRLEN,
            STRCMP,
            STRNCMP,
            STRCPY,
            STRNCPY,
            STRCAT,
            STRCHR,
            STRRCHR,
            STRSTR,
            STRTOLL,
            STRTOULL,
            ATOI,
            PUTS,
            FPUTS,
            PUTCHAR,
            FPRINTF,
            SNPRINTF,
            VSNPRINTF,
            FWRITE,
            ISSPACE,
            ISDIGIT,
            ISALPHA,
            ISALNUM,
            ISUPPER,
            ISLOWER,
            ISPRINT,
            ISXDIGIT,
            TOLOWER,
            TOUPPER,
            ERRNO_LOCATION,
            REPEAT,
            UTOA,
            NUMBER,
            TAKE,
            LOST_CELL,
        ] {
            require(name);
        }
        // Every `main` arity the translator accepts builds a wrapper too.
        for arity in 0..=2 {
            build_main_wrapper("main_0", arity);
        }
        let declarations = take_declarations();
        assert!(declarations.len() >= 14);
        assert_eq!(module_requires(), vec!["strings", "daslib/fio"]);
        reset();
        assert!(module_requires().is_empty());
    }
}
