//! Target switches for runtimes other than master daslang (`docs/eden-flags.md`).
//!
//! Every switch defaults to the master-daslang model, so a default
//! [`TargetOptions`] leaves the output byte-identical.  A switch whose lowering
//! is not implemented yet is accepted by the parser only so it can be refused
//! by name ([`TargetOptions::unimplemented`]): a partially honoured target is
//! indistinguishable from a wrong one in the generated module.

/// Declares a two-valued switch with its command-line spellings.
macro_rules! switch {
    ($(#[$meta:meta])* $name:ident { $default:ident = $dtext:literal, $other:ident = $otext:literal }) => {
        $(#[$meta])*
        #[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
        pub enum $name {
            #[default]
            $default,
            $other,
        }

        impl $name {
            /// The spelling the flag accepts, or `None` for an unknown value.
            pub fn parse(text: &str) -> Option<Self> {
                match text {
                    $dtext => Some(Self::$default),
                    $otext => Some(Self::$other),
                    _ => None,
                }
            }

            /// The spelling this value is written with on the command line.
            pub fn as_str(self) -> &'static str {
                match self {
                    Self::$default => $dtext,
                    Self::$other => $otext,
                }
            }

            /// Every spelling the flag accepts, default first.
            pub const ALL: [Self; 2] = [Self::$default, Self::$other];
        }

        impl std::fmt::Display for $name {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                f.write_str(self.as_str())
            }
        }
    };
}

switch!(
    /// `--memory-model`: raw host addresses (today) or offsets into one
    /// `array<uint8>` heap.  `linear` is `translator/linear.rs`.
    MemoryModel { Raw = "raw", Linear = "linear" }
);
switch!(
    /// `--fnptr-model`: `@@f` function values (today) or indices into
    /// per-signature tables.  `table` is not implemented yet.
    FnPtrModel { Value = "value", Table = "table" }
);
switch!(
    /// `--float-compare`: daslang's own comparison operators, or every
    /// floating comparison routed through a NaN-guarded helper
    /// (`translator/float_compare.rs`), for a runtime whose comparisons are
    /// not IEEE (`docs/eden-target.md` §3).
    FloatCompare { Ieee = "ieee", NanSafe = "nan-safe" }
);
switch!(
    /// `--varargs-model`: an array literal per variadic call (today) or a C
    /// stack region of the `--memory-model linear` heap
    /// (`translator/linear/va_heap.rs`; refused without that model).
    VarargsModel { Array = "array", Heap = "heap" }
);
switch!(
    /// `--dialect`: master daslang, or the subset the EdenSpark editor's
    /// daslang 0.6.4 parses and its sandbox admits, enforced by a checker
    /// over the finished module (`translator/target_check.rs`).
    Dialect { Master = "master", Eden064 = "eden-0.6.4" }
);
switch!(
    /// `--entry`: a `[export] def main` wrapper (today) or a module API for
    /// an engine host.  `eden` is not implemented yet.
    EntryModel { Main = "main", Eden = "eden" }
);
switch!(
    /// `--records`: C records in the memory model's natural form (today) or
    /// non-escaping records as typed `new T` objects (`typed` needs
    /// `--memory-model linear`; `translator/linear/typed_records.rs`).
    RecordsModel { Natural = "natural", Typed = "typed" }
);

/// `--no-unsafe`: what to do with a construct in the output that needs
/// `unsafe` (`translator/target_check.rs`).
#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub enum NoUnsafe {
    /// No check (default).
    #[default]
    Off,
    /// `--no-unsafe`: a `TranslationError` naming the first sites.
    Fail,
    /// `--no-unsafe=report`: print a per-construct census to stderr and
    /// write the module as usual.
    Report,
}

/// The target switches of one translation run.  `Default` is master daslang.
#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct TargetOptions {
    pub memory_model: MemoryModel,
    pub fnptr_model: FnPtrModel,
    pub float_compare: FloatCompare,
    pub varargs_model: VarargsModel,
    /// `--heap-reserve <bytes>`: the `--memory-model linear` heap capacity
    /// (default [`EDEN_DEFAULT_HEAP_RESERVE`]); refused without that model.
    pub heap_reserve: Option<u64>,
    pub dialect: Dialect,
    pub entry: EntryModel,
    pub records: RecordsModel,
    pub no_unsafe: NoUnsafe,
}

impl TargetOptions {
    /// What `--target eden` sets (`docs/eden-flags.md`, "The flags").  The
    /// libc half of the preset (`--libc eden`) lives in `LibcMode`.
    pub fn eden() -> Self {
        TargetOptions {
            memory_model: MemoryModel::Linear,
            fnptr_model: FnPtrModel::Table,
            float_compare: FloatCompare::NanSafe,
            varargs_model: VarargsModel::Heap,
            heap_reserve: Some(EDEN_DEFAULT_HEAP_RESERVE),
            dialect: Dialect::Eden064,
            entry: EntryModel::Eden,
            records: RecordsModel::Typed,
            no_unsafe: NoUnsafe::Fail,
        }
    }

    /// The command-line spelling of every selected switch whose lowering is
    /// not implemented yet, in flag-table order.
    pub fn unimplemented(&self) -> Vec<String> {
        let mut missing = Vec::new();
        // `--fnptr-model table` indexes the tables of the linear heap model.
        if let (FnPtrModel::Table, MemoryModel::Raw) = (self.fnptr_model, self.memory_model) {
            missing.push(format!("--fnptr-model {} (needs --memory-model linear)", self.fnptr_model));
        }
        // `--varargs-model heap` writes the arguments into the linear heap's
        // C stack.
        if let (VarargsModel::Heap, MemoryModel::Raw) = (self.varargs_model, self.memory_model) {
            missing.push(format!("--varargs-model {} (needs --memory-model linear)", self.varargs_model));
        }
        // `--heap-reserve` sizes the linear heap; without that model there is
        // no heap it could size.
        if let (Some(bytes), MemoryModel::Raw) = (self.heap_reserve, self.memory_model) {
            missing.push(format!("--heap-reserve {bytes} (needs --memory-model linear)"));
        }
        // `--entry eden` builds argv in the linear heap.
        if let (EntryModel::Eden, MemoryModel::Raw) = (self.entry, self.memory_model) {
            missing.push(format!("--entry {} (needs --memory-model linear)", self.entry));
        }
        // `--records typed` chooses between the linear heap's byte form and
        // a typed object; without that model there is no byte form.
        if let (RecordsModel::Typed, MemoryModel::Raw) = (self.records, self.memory_model) {
            missing.push(format!("--records {} (needs --memory-model linear)", self.records));
        }
        missing
    }
}

/// The `--target eden` heap limit: under the 100 MiB per-context cap with room
/// for the rest of the script's arrays (`docs/eden-target.md` §3).
pub const EDEN_DEFAULT_HEAP_RESERVE: u64 = 80 * 1024 * 1024;
