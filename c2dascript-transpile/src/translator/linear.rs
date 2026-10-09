//! `--memory-model linear`: C memory as one module-global `array<uint8>`.
//!
//! An address is an `int` offset into `c2da_mem`; NULL is 0 and the first 16
//! bytes are never handed out.  A data pointer's daScript type is `int`; in
//! memory it occupies Clang's 8 bytes, the offset in the low 4 (little
//! endian) and zero in the high 4.  Every load and store through a pointer is
//! written in place: a byte is `c2da_mem[a]`, a wider integer is assembled
//! from bytes with shifts, `float`/`double` go through `daslib/math_bits`.
//! Pointer arithmetic is integer arithmetic scaled by Clang's pointee size;
//! a field through a pointer is the base plus Clang's field offset.
//!
//! String literals whose address is taken live in a static block written into
//! the heap by an `[init]` function; their offsets are translation-time
//! constants.  `malloc`/`calloc`/`realloc`/`free` and the byte functions
//! (`memcpy`, `memmove`, `memset`, `memcmp`, `strlen`) are the `c2da_lin_*`
//! runtime appended to the module ([`runtime_source`]).
//!
//! What this file does not lower is refused with a located
//! "not supported under --memory-model linear yet" error, and module assembly
//! refuses any `unsafe` construct left in a linear module
//! (`target_check.rs check_linear`), so no raw-pointer form can slip through.
use super::*;
use crate::target::MemoryModel;
use crate::translator::layout::NaturalMember;
use std::collections::HashMap as StdHashMap;

/// The heap: one module global.
pub(crate) const MEM: &str = "c2da_mem";
/// Bytes at the bottom of the heap that no object occupies, so 0 is NULL.
const RESERVED: usize = 16;

thread_local! {
    /// The static block: string-literal bytes, deduplicated, from offset 16.
    static STATIC: RefCell<(Vec<u8>, StdHashMap<Vec<u8>, i64>)> =
        RefCell::new((vec![0; RESERVED], StdHashMap::new()));
}

thread_local! {
    /// The C stack frame of the function being translated: each local whose
    /// address is taken (or whose array decays to a pointer), at its offset
    /// from the frame pointer `c2da_fp`.
    static FRAME: RefCell<StdHashMap<CDeclId, i64>> = RefCell::new(StdHashMap::new());
}

/// The frame pointer parameter of a function body with a C stack frame.
pub(crate) const FP: &str = "c2da_fp";
/// Bytes of the C stack region (`c2da_lin_enter` panics past it).
const STACK_BYTES: usize = 1 << 20;

thread_local! {
    /// Whether a printf-family call was lowered: the formatter section of the
    /// runtime is appended only then (it writes through `c2da_std_write`,
    /// which the call site registers).
    static FORMAT_USED: std::cell::Cell<bool> = std::cell::Cell::new(false);
    /// Whether `fopen`/`fread` were lowered (the `--libc eden` file section).
    static FILE_USED: std::cell::Cell<bool> = std::cell::Cell::new(false);
    /// Whether the `main` wrapper builds argv in the heap.
    static ARGV_USED: std::cell::Cell<bool> = std::cell::Cell::new(false);
}

/// Clears the static block at the start of a translation unit.
pub fn reset() {
    STATIC.with(|s| *s.borrow_mut() = (vec![0; RESERVED], StdHashMap::new()));
    FRAME.with(|f| f.borrow_mut().clear());
    GLOBALS.with(|g| g.borrow_mut().clear());
    SIGS.with(|s| s.borrow_mut().clear());
    FUNCS.with(|f| f.borrow_mut().clear());
    FN_DECLS.with(|f| f.borrow_mut().clear());
    FORMAT_USED.with(|u| u.set(false));
    FILE_USED.with(|u| u.set(false));
    ARGV_USED.with(|u| u.set(false));
    IN_LINK.with(|l| *l.borrow_mut() = None);
}

/// The first conversion of a printf format the linear formatter does not
/// implement (`c2da_lin_vfmt`), as its C spelling.
fn unsupported_linear_conversion(format: &[u8]) -> Option<String> {
    let mut i = 0;
    while i < format.len() {
        if format[i] != b'%' {
            i += 1;
            continue;
        }
        let start = i;
        i += 1;
        while i < format.len() && b"-+ #0123456789.*hljztqL".contains(&format[i]) {
            i += 1;
        }
        let Some(&conv) = format.get(i) else {
            return Some(String::from_utf8_lossy(&format[start..]).into_owned());
        };
        i += 1;
        if !b"diuxXocsp%".contains(&conv) {
            return Some(String::from_utf8_lossy(&format[start..i]).into_owned());
        }
    }
    None
}

fn frame_offset(decl: CDeclId) -> Option<i64> {
    FRAME.with(|f| f.borrow().get(&decl).copied())
}

thread_local! {
    /// Objects of static duration whose address is taken (or whose array
    /// decays to a pointer): their offset in the static block.
    static GLOBALS: RefCell<StdHashMap<CDeclId, i64>> = RefCell::new(StdHashMap::new());
}

fn global_offset(decl: CDeclId) -> Option<i64> {
    GLOBALS.with(|g| g.borrow().get(&decl).copied())
}

/// True for a static-duration object the linear model keeps in the heap; its
/// daslang declaration is not emitted.
pub(crate) fn is_heap_global(decl: CDeclId) -> bool {
    global_offset(decl).is_some()
}

/// Appends `bytes` to the static block at a 16-byte boundary (never shared:
/// the object is writable) and answers its offset.
fn place_static(bytes: &[u8]) -> i64 {
    STATIC.with(|s| {
        let mut s = s.borrow_mut();
        let at = (s.0.len() + 15) & !15;
        s.0.resize(at, 0);
        s.0.extend_from_slice(bytes);
        at as i64
    })
}

/// The offset of a string literal's bytes (with its NUL) in the static block.
fn intern(bytes: Vec<u8>) -> i64 {
    STATIC.with(|s| {
        let mut s = s.borrow_mut();
        if let Some(&at) = s.1.get(&bytes) {
            return at;
        }
        let at = s.0.len() as i64;
        s.0.extend_from_slice(&bytes);
        s.1.insert(bytes, at);
        at
    })
}

/// A scalar as it sits in linear memory.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Scalar {
    Bool,
    I8,
    U8,
    I16,
    U16,
    I32,
    U32,
    I64,
    U64,
    F32,
    F64,
    /// A data pointer: `int` offset, 8 bytes in memory.
    Ptr,
    /// A function pointer in the heap: its index (8 bytes, like `Ptr`) into
    /// the table of signature `n` (`SIGS`); as a daslang value it stays the
    /// `function<…>` the default model uses.
    Fn(usize),
}

thread_local! {
    /// The `function<…>` types of function pointers held in the heap.
    static SIGS: RefCell<Vec<DaType>> = RefCell::new(Vec::new());
    /// Every function whose address is taken: its daslang name and the
    /// signature of the pointer it decays to; its index is position + 1.
    static FUNCS: RefCell<Vec<(String, DaType)>> = RefCell::new(Vec::new());
}

thread_local! {
    /// `--fnptr-model table`: every function pointer, not only one in the
    /// heap, is its `int` index into the table of its signature.
    static FN_TABLE: std::cell::Cell<bool> = std::cell::Cell::new(false);
    /// The numbered functions (`FUNCS` position) by declaration.
    static FN_DECLS: RefCell<StdHashMap<CDeclId, usize>> = RefCell::new(StdHashMap::new());
}

/// Selects `--fnptr-model table` for the unit being translated.
pub fn set_fn_table(on: bool) {
    FN_TABLE.with(|t| t.set(on));
}

pub(crate) fn fn_table() -> bool {
    FN_TABLE.with(|t| t.get())
}

fn sig_id(t: &DaType) -> usize {
    SIGS.with(|s| {
        let mut s = s.borrow_mut();
        match s.iter().position(|x| x == t) {
            Some(i) => i,
            None => {
                s.push(t.clone());
                s.len() - 1
            }
        }
    })
}

impl Scalar {
    fn da_type(self) -> DaType {
        match self {
            Scalar::Bool => DaType::bool(),
            Scalar::I8 => DaType::int8(),
            Scalar::U8 => DaType::uint8(),
            Scalar::I16 => DaType::int16(),
            Scalar::U16 => DaType::uint16(),
            Scalar::I32 | Scalar::Ptr => DaType::int(),
            Scalar::U32 => DaType::uint(),
            Scalar::I64 => DaType::int64(),
            Scalar::U64 => DaType::uint64(),
            Scalar::F32 => DaType::float(),
            Scalar::F64 => DaType::double(),
            Scalar::Fn(_) if fn_table() => DaType::int(),
            Scalar::Fn(n) => SIGS.with(|s| s.borrow()[n].clone()),
        }
    }
}

fn cast(to: DaType, expr: DaExpr) -> DaExpr {
    DaExpr::Cast {
        kind: das_ast::CastKind::Cast,
        expr: Box::new(expr),
        to,
    }
}

fn op2(op: &'static str, left: DaExpr, right: DaExpr) -> DaExpr {
    DaExpr::Op2 {
        op,
        left: Box::new(left),
        right: Box::new(right),
    }
}

/// `a + k` for a constant `k`, folded when `a` is a constant.
fn plus(a: &DaExpr, k: i64) -> DaExpr {
    if k == 0 {
        return a.clone();
    }
    match a {
        DaExpr::ConstInt(base) => DaExpr::ConstInt(base + k),
        DaExpr::Op2 { op: "+", left, right } => match &**right {
            DaExpr::ConstInt(c) => op2("+", (**left).clone(), DaExpr::ConstInt(c + k)),
            _ => op2("+", a.clone(), DaExpr::ConstInt(k)),
        },
        _ => op2("+", a.clone(), DaExpr::ConstInt(k)),
    }
}

fn byte_at(a: &DaExpr, k: i64) -> DaExpr {
    DaExpr::Index(Box::new(DaExpr::Var(MEM.into())), Box::new(plus(a, k)))
}

/// Little-endian assembly of `n` bytes at `a` into `uint` (n <= 4).
fn assemble32(a: &DaExpr, base: i64, n: i64) -> DaExpr {
    let mut acc = cast(DaType::uint(), byte_at(a, base));
    for k in 1..n {
        let b = op2(
            "<<",
            cast(DaType::uint(), byte_at(a, base + k)),
            DaExpr::ConstUInt((8 * k) as u64),
        );
        acc = op2("|", acc, b);
    }
    acc
}

/// The value of a scalar of kind `s` at the stable address `a`.
fn load(s: Scalar, a: &DaExpr) -> DaExpr {
    match s {
        Scalar::U8 => byte_at(a, 0),
        Scalar::I8 => cast(DaType::int8(), byte_at(a, 0)),
        Scalar::Bool => op2("!=", byte_at(a, 0), cast(DaType::uint8(), DaExpr::ConstInt(0))),
        Scalar::U16 => cast(DaType::uint16(), assemble32(a, 0, 2)),
        Scalar::I16 => cast(DaType::int16(), assemble32(a, 0, 2)),
        Scalar::U32 => assemble32(a, 0, 4),
        Scalar::I32 | Scalar::Ptr => cast(DaType::int(), assemble32(a, 0, 4)),
        Scalar::Fn(_) if fn_table() => cast(DaType::int(), assemble32(a, 0, 4)),
        Scalar::Fn(n) => DaExpr::Index(
            Box::new(DaExpr::Var(format!("c2da_fn_table{n}"))),
            Box::new(cast(DaType::int(), assemble32(a, 0, 4))),
        ),
        Scalar::F32 => DaExpr::Call(
            Box::new(DaExpr::Var("uint_bits_to_float".into())),
            vec![assemble32(a, 0, 4)],
        ),
        Scalar::U64 | Scalar::I64 | Scalar::F64 => {
            let bits = op2(
                "|",
                cast(DaType::uint64(), assemble32(a, 0, 4)),
                op2(
                    "<<",
                    cast(DaType::uint64(), assemble32(a, 4, 4)),
                    DaExpr::ConstUInt(32),
                ),
            );
            match s {
                Scalar::U64 => bits,
                Scalar::I64 => cast(DaType::int64(), bits),
                _ => DaExpr::Call(
                    Box::new(DaExpr::Var("uint64_bits_to_double".into())),
                    vec![bits],
                ),
            }
        }
    }
}

/// The statements that store the stable value `v` of kind `s` at the
/// stable address `a`.
fn store(s: Scalar, a: &DaExpr, v: &DaExpr, fresh: &mut dyn FnMut() -> String) -> Vec<DaStmt> {
    let set = |k: i64, byte: DaExpr| {
        DaStmt::Expr(DaExpr::Assign(Box::new(byte_at(a, k)), Box::new(byte)))
    };
    let u8_of = |e: DaExpr| cast(DaType::uint8(), e);
    match s {
        Scalar::Fn(_) if fn_table() => store(Scalar::Ptr, a, v, fresh),
        Scalar::Fn(n) => {
            let index = DaExpr::Call(Box::new(DaExpr::Var(format!("c2da_fn_index{n}"))), vec![v.clone()]);
            let name = fresh();
            let mut out = vec![DaStmt::Let { name: name.clone(), var_type: Some(DaType::int()), init: Some(index) }];
            out.extend(store(Scalar::Ptr, a, &DaExpr::Var(name), fresh));
            out
        }
        Scalar::U8 => vec![set(0, v.clone())],
        Scalar::I8 => vec![set(0, u8_of(v.clone()))],
        Scalar::Bool => vec![set(
            0,
            DaExpr::Op3 {
                cond: Box::new(v.clone()),
                then: Box::new(u8_of(DaExpr::ConstInt(1))),
                else_: Box::new(u8_of(DaExpr::ConstInt(0))),
            },
        )],
        _ => {
            let (bits_ty, bits, n) = match s {
                Scalar::U16 | Scalar::I16 => (DaType::uint(), cast(DaType::uint(), v.clone()), 2),
                Scalar::U32 => (DaType::uint(), v.clone(), 4),
                Scalar::I32 | Scalar::Ptr => (DaType::uint(), cast(DaType::uint(), v.clone()), 4),
                Scalar::F32 => (
                    DaType::uint(),
                    DaExpr::Call(Box::new(DaExpr::Var("float_bits_to_uint".into())), vec![v.clone()]),
                    4,
                ),
                Scalar::U64 => (DaType::uint64(), v.clone(), 8),
                Scalar::I64 => (DaType::uint64(), cast(DaType::uint64(), v.clone()), 8),
                Scalar::F64 => (
                    DaType::uint64(),
                    DaExpr::Call(
                        Box::new(DaExpr::Var("double_bits_to_uint64".into())),
                        vec![v.clone()],
                    ),
                    8,
                ),
                _ => unreachable!(),
            };
            let name = fresh();
            let mut out = vec![DaStmt::Let {
                name: name.clone(),
                var_type: Some(bits_ty),
                init: Some(bits),
            }];
            for k in 0..n {
                let shifted = if k == 0 {
                    DaExpr::Var(name.clone())
                } else {
                    op2(">>", DaExpr::Var(name.clone()), DaExpr::ConstUInt((8 * k) as u64))
                };
                out.push(set(k, u8_of(shifted)));
            }
            if s == Scalar::Ptr {
                for k in 4..8 {
                    out.push(set(k, u8_of(DaExpr::ConstInt(0))));
                }
            }
            out
        }
    }
}

/// An address expression that may be written more than once.
fn is_stable(e: &DaExpr) -> bool {
    match e {
        DaExpr::Var(_) | DaExpr::ConstInt(_) => true,
        DaExpr::Op2 { op: "+" | "-" | "*", left, right } => is_stable(left) && is_stable(right),
        DaExpr::Cast { expr, .. } => is_stable(expr),
        _ => false,
    }
}

impl<'c> Translation<'c> {
    pub(crate) fn is_linear(&self) -> bool {
        self.tcfg.target.memory_model == MemoryModel::Linear
    }

    fn linear_refuse(&self, expr_id: CExprId, what: &str) -> TranslationError {
        format_translation_err!(
            self.ast_context.display_loc(&self.ast_context[expr_id].loc),
            "not supported under --memory-model linear yet: {what}"
        )
    }

    fn qual_of(&self, expr_id: CExprId) -> TranslationResult<CQualTypeId> {
        self.ast_context[expr_id]
            .kind
            .get_qual_type()
            .ok_or_else(|| TranslationError::generic("C expression has no type"))
    }

    /// The pointee of a data pointer type; `None` for anything else,
    /// including a pointer to a function.
    pub(crate) fn linear_pointee(&self, ty: CTypeId) -> Option<CQualTypeId> {
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::Pointer(inner) => {
                if matches!(
                    self.ast_context.resolve_type(inner.ctype).kind,
                    CTypeKind::Function(..)
                ) {
                    None
                } else {
                    Some(inner)
                }
            }
            _ => None,
        }
    }

    fn is_data_pointer(&self, ty: CTypeId) -> bool {
        self.linear_pointee(ty).is_some()
    }

    /// Clang's step for pointer arithmetic over `pointee` (`void *` steps by 1).
    fn step_size(&self, pointee: CQualTypeId) -> TranslationResult<i64> {
        if matches!(self.ast_context.resolve_type(pointee.ctype).kind, CTypeKind::Void) {
            return Ok(1);
        }
        self.sizeof_type(pointee.ctype)
    }

    /// The `function<…>` type of the table a function pointer of C type
    /// `ptr` indexes: its pointee converted (parameters that are themselves
    /// function pointers follow the model, as the functions' own do).
    fn fn_sig(&self, ptr: CTypeId) -> TranslationResult<DaType> {
        match self.ast_context.resolve_type(ptr).kind {
            CTypeKind::Pointer(inner) => self.convert_type_inner(self.ast_context.resolve_type_id(inner.ctype)),
            _ => self.convert_type_inner(self.ast_context.resolve_type_id(ptr)),
        }
    }

    /// `--fnptr-model table`: the index of function designator `f` (a
    /// `DeclRef`, parentheses allowed), or a located refusal for a function
    /// with no table slot (a library function).
    fn fn_index_of(&self, expr_id: CExprId, f: CExprId) -> TranslationResult<DaExpr> {
        let mut f = f;
        while let CExprKind::Paren(_, i) = self.ast_context[f].kind {
            f = i;
        }
        let slot = match self.ast_context[f].kind {
            CExprKind::DeclRef(_, decl, _) => FN_DECLS.with(|d| d.borrow().get(&decl).copied()),
            _ => None,
        };
        match slot {
            Some(k) => Ok(DaExpr::ConstInt((linked_fn_base() + k + 1) as i64)),
            None => Err(self.linear_refuse(
                expr_id,
                "the address of a function with no table slot (a library function) under --fnptr-model table",
            )),
        }
    }

    /// `--fnptr-model table`: the callee of an indirect call, `value` being
    /// the converted pointer (an index), as the table element `invoke` takes.
    pub(crate) fn linear_fn_callee(&self, callee: CExprId, value: DaExpr) -> TranslationResult<DaExpr> {
        let ty = self.qual_of(callee)?;
        let n = sig_id(&self.fn_sig(ty.ctype)?);
        Ok(DaExpr::Index(
            Box::new(DaExpr::Var(format!("c2da_fn_table{n}"))),
            Box::new(value),
        ))
    }

    fn is_fn_pointer(&self, ty: CTypeId) -> bool {
        matches!(self.ast_context.resolve_type(ty).kind,
            CTypeKind::Pointer(p) if matches!(self.ast_context.resolve_type(p.ctype).kind, CTypeKind::Function(..)))
    }

    fn scalar_of(&self, ty: CTypeId) -> Option<Scalar> {
        use CTypeKind::*;
        if self.is_data_pointer(ty) {
            return Some(Scalar::Ptr);
        }
        if let CTypeKind::Pointer(inner) = self.ast_context.resolve_type(ty).kind {
            if matches!(self.ast_context.resolve_type(inner.ctype).kind, CTypeKind::Function(..)) {
                return self.fn_sig(ty).ok().map(|t| Scalar::Fn(sig_id(&t)));
            }
        }
        Some(match self.ast_context.resolve_type(ty).kind {
            Bool => Scalar::Bool,
            Int | Int32 => Scalar::I32,
            SChar | Char | Int8 => Scalar::I8,
            Short | Int16 => Scalar::I16,
            Int64 | Long | LongLong | IntPtr | SSize | PtrDiff | IntMax => Scalar::I64,
            UChar | UInt8 => Scalar::U8,
            UShort | UInt16 => Scalar::U16,
            UInt | UInt32 => Scalar::U32,
            UInt64 | ULong | ULongLong | UIntPtr | Size | WChar | UIntMax => Scalar::U64,
            Float => Scalar::F32,
            Double => Scalar::F64,
            // An enumeration is its compatible integer type under the model.
            Enum(id) => {
                let integral = match self.ast_context[id].kind {
                    CDeclKind::Enum { integral_type, .. } => integral_type,
                    _ => None,
                };
                return match integral {
                    Some(q) => self.scalar_of(q.ctype),
                    None => Some(Scalar::I32),
                };
            }
            _ => return None,
        })
    }

    /// The local object an lvalue names: a variable, a field of one, an
    /// element of a declared array.  `None` for anything reached through a
    /// pointer.
    fn object_root(&self, e: CExprId) -> Option<CDeclId> {
        match &self.ast_context[e].kind {
            CExprKind::Paren(_, inner) => self.object_root(*inner),
            CExprKind::DeclRef(_, decl, _) => Some(*decl),
            CExprKind::Member(_, base, _, MemberKind::Dot, _) => self.object_root(*base),
            CExprKind::ArraySubscript(_, lhs, rhs, _) => {
                let array = self.decayed_array(*lhs).or_else(|| self.decayed_array(*rhs))?;
                self.object_root(array)
            }
            _ => None,
        }
    }

    /// The C stack frame of a function body: every local (not a parameter,
    /// not a `static`) whose address is taken or whose array decays to a
    /// pointer other than as the base of `a[i]`, at a 16-byte aligned
    /// offset.  Returns the frame's map and size.
    pub(crate) fn linear_plan_frame(
        &self,
        body: CStmtId,
        parameters: &[CDeclId],
    ) -> TranslationResult<(StdHashMap<CDeclId, i64>, i64)> {
        let nodes: Vec<CExprId> = DFExpr::new(&self.ast_context, SomeId::Stmt(body))
            .filter_map(|n| match n {
                SomeId::Expr(e) => Some(e),
                _ => None,
            })
            .collect();
        let mut subscript_bases = std::collections::HashSet::new();
        for &e in &nodes {
            if let CExprKind::ArraySubscript(_, lhs, rhs, _) = self.ast_context[e].kind {
                for side in [lhs, rhs] {
                    let mut s = side;
                    while let CExprKind::Paren(_, i) = self.ast_context[s].kind {
                        s = i;
                    }
                    subscript_bases.insert(s);
                }
            }
        }
        let mut map = StdHashMap::new();
        let mut size = 0i64;
        for &e in &nodes {
            let root = match &self.ast_context[e].kind {
                CExprKind::Unary(_, CUnOp::AddressOf, arg, _) => self.object_root(*arg),
                CExprKind::ImplicitCast(_, inner, CastKind::ArrayToPointerDecay, _, _)
                    if !subscript_bases.contains(&e) =>
                {
                    self.object_root(*inner)
                }
                _ => None,
            };
            let Some(decl) = root else { continue };
            if map.contains_key(&decl) {
                continue;
            }
            // A parameter whose address is taken is spilled to its slot on
            // entry (`linear_param_spills`); only scalars are.
            if parameters.contains(&decl) {
                if let CDeclKind::Variable { typ, .. } = self.ast_context[decl].kind {
                    if self.is_aggregate(typ.ctype) || self.scalar_of(typ.ctype).is_none() {
                        return Err(self.linear_refuse(
                            e,
                            "the address of a parameter of record or array type (only scalar parameters are spilled to the C stack)",
                        ));
                    }
                }
            }
            let CDeclKind::Variable {
                has_static_duration: false,
                has_thread_duration: false,
                typ,
                ..
            } = self.ast_context[decl].kind
            else {
                continue;
            };
            // A `va_list` decays at va_start/va_end/vsnprintf but is the
            // variadic cursor (variadic.rs), never C memory.
            if self.ast_context.is_va_list(typ.ctype) {
                continue;
            }
            let bytes = self.sizeof_type(typ.ctype).map_err(|_| {
                self.linear_refuse(e, "a local of this type in the C stack (--locals-in-heap)")
            })?;
            map.insert(decl, size);
            size += (bytes + 15) & !15;
        }
        Ok((map, size))
    }

    /// Places in the static block every object of static duration (a global
    /// or a function-scope `static`) whose address is taken or whose array
    /// decays to a pointer in any function body, with its initial bytes.
    /// Every use of such an object is then a heap access (`heap_place`) and
    /// its daslang declaration is not emitted.
    pub(crate) fn linear_plan_globals(&self) -> TranslationResult<()> {
        // Every function whose address is taken anywhere gets an index into
        // the table of its pointer's signature (a function pointer in the
        // heap is that index; `c2da_relink` fills the tables).
        let roots: Vec<CExprId> = self
            .ast_context
            .iter_decls()
            .filter_map(|(_, d)| match d.kind {
                CDeclKind::Function { body: Some(b), .. } => Some(SomeId::Stmt(b)),
                CDeclKind::Variable { initializer: Some(i), .. } => Some(SomeId::Expr(i)),
                _ => None,
            })
            .flat_map(|root| {
                DFExpr::new(&self.ast_context, root)
                    .filter_map(|n| match n {
                        SomeId::Expr(e) => Some(e),
                        _ => None,
                    })
                    .collect::<Vec<_>>()
            })
            .collect();
        // A direct call's callee decays too; it is not an address taken.
        let callees: std::collections::HashSet<CExprId> = roots
            .iter()
            .filter_map(|&e| match self.ast_context[e].kind {
                CExprKind::Call(_, func, _) => Some(func),
                _ => None,
            })
            .collect();
        let mut seen: Vec<CDeclId> = Vec::new();
        for e in roots {
            if callees.contains(&e) {
                continue;
            }
            // `f` decayed, or `&f` (no decay; its type is the pointer too).
            let (ty, inner) = match self.ast_context[e].kind {
                CExprKind::ImplicitCast(ty, inner, CastKind::FunctionToPointerDecay, _, _) => (ty, inner),
                CExprKind::Unary(ty, CUnOp::AddressOf, inner, _)
                    if matches!(
                        self.ast_context.resolve_type(ty.ctype).kind,
                        CTypeKind::Pointer(p) if matches!(self.ast_context.resolve_type(p.ctype).kind, CTypeKind::Function(..))
                    ) =>
                {
                    (ty, inner)
                }
                _ => continue,
            };
            let mut f = inner;
            while let CExprKind::Paren(_, i) = self.ast_context[f].kind {
                f = i;
            }
            let CExprKind::DeclRef(_, decl, _) = self.ast_context[f].kind else { continue };
            // A library function has no daslang function to point at; storing
            // its address in the heap panics at `c2da_fn_index`.
            // A function another unit of a source-layout program defines is
            // numbered here too (this module requires its owner); one
            // numbered by both units has two slots holding the same value.
            let CDeclKind::Function { ref name, ref body, typ: fn_typ, .. } = self.ast_context[decl].kind else { continue };
            let foreign = self.link.as_ref().map_or(false, |link| link.owners.contains_key(name));
            if body.is_none() && !foreign {
                continue;
            }
            if seen.contains(&decl) {
                continue;
            }
            seen.push(decl);
            // The definition's own signature: a decay through an unprototyped
            // declaration (`void A_Light0();`) has the type `void (*)()`.
            let _ = ty;
            let sig = self.fn_sig(fn_typ)?;
            sig_id(&sig);
            let da_name = self.declare_value_name(decl, name);
            FUNCS.with(|fs| {
                let mut fs = fs.borrow_mut();
                FN_DECLS.with(|d| d.borrow_mut().insert(decl, fs.len()));
                fs.push((da_name, sig));
            });
        }
        let mut order: Vec<CDeclId> = Vec::new();
        // Function bodies, and the initializers of static-duration objects
        // (`&g[k]` in a global's initializer puts `g` in the heap too).
        let bodies: Vec<SomeId> = self
            .ast_context
            .iter_decls()
            .filter_map(|(_, d)| match d.kind {
                CDeclKind::Function { body: Some(b), .. } => Some(SomeId::Stmt(b)),
                CDeclKind::Variable { has_static_duration: true, initializer: Some(i), .. } => Some(SomeId::Expr(i)),
                _ => None,
            })
            .collect();
        for body in bodies {
            let nodes: Vec<CExprId> = DFExpr::new(&self.ast_context, body)
                .filter_map(|n| match n {
                    SomeId::Expr(e) => Some(e),
                    _ => None,
                })
                .collect();
            let mut subscript_bases = std::collections::HashSet::new();
            for &e in &nodes {
                if let CExprKind::ArraySubscript(_, lhs, rhs, _) = self.ast_context[e].kind {
                    for side in [lhs, rhs] {
                        let mut s = side;
                        while let CExprKind::Paren(_, i) = self.ast_context[s].kind {
                            s = i;
                        }
                        subscript_bases.insert(s);
                    }
                }
            }
            for &e in &nodes {
                let root = match &self.ast_context[e].kind {
                    CExprKind::Unary(_, CUnOp::AddressOf, arg, _) => self.object_root(*arg),
                    CExprKind::ImplicitCast(_, inner, CastKind::ArrayToPointerDecay, _, _)
                        if !subscript_bases.contains(&e) =>
                    {
                        self.object_root(*inner)
                    }
                    _ => None,
                };
                let Some(decl) = root else { continue };
                if matches!(
                    self.ast_context[decl].kind,
                    CDeclKind::Variable { has_static_duration: true, has_thread_duration: false, .. }
                ) && !order.contains(&decl)
                {
                    order.push(decl);
                }
            }
        }
        let mut inits: Vec<(CExprId, CTypeId, i64, usize)> = Vec::new();
        for decl in order {
            // The definition carries the initializer; `extern` redeclarations
            // share the object.
            let is_defn = matches!(self.ast_context[decl].kind, CDeclKind::Variable { is_defn: true, .. });
            let def = if is_defn {
                Some(decl)
            } else {
                // An `extern` declaration: the file-scope definition of that
                // name (function-scope statics are always definitions).
                self.ast_context.iter_decls().find_map(|(&id, d)| match &d.kind {
                    CDeclKind::Variable { is_defn: true, has_static_duration: true, ident, .. }
                        if Some(ident) == self.ast_context[decl].kind.get_name()
                            && self.ast_context.parents.get(&id).is_none() =>
                    {
                        Some(id)
                    }
                    _ => None,
                })
            };
            let src = def.unwrap_or(decl);
            let CDeclKind::Variable { typ, initializer, .. } = self.ast_context[src].kind else {
                continue;
            };
            let size = self.sizeof_type(typ.ctype).map_err(|_| {
                format_translation_err!(
                    self.ast_context.display_loc(&self.ast_context[src].loc),
                    "not supported under --memory-model linear yet: a global of this type in the heap"
                )
            })?;
            // An `extern` declaration and its definition are one object.
            if let Some(at) = global_offset(src) {
                GLOBALS.with(|g| g.borrow_mut().insert(decl, at));
                continue;
            }
            let at = place_static(&vec![0u8; size as usize]);
            GLOBALS.with(|g| {
                let mut g = g.borrow_mut();
                g.insert(decl, at);
                g.insert(src, at);
            });
            if let Some(init) = initializer {
                inits.push((init, typ.ctype, at, size as usize));
            }
        }
        // Every heap global is placed before any initializer is written, so
        // an initializer may hold the address of any of them.
        for (init, ty, at, size) in inits {
            let mut bytes = vec![0u8; size];
            self.static_init_bytes(init, ty, &mut bytes, 0)?;
            STATIC.with(|s| s.borrow_mut().0[at as usize..at as usize + size].copy_from_slice(&bytes));
        }
        Ok(())
    }

    /// The constant heap address (or `--fnptr-model table` function index) a
    /// static initializer of pointer type denotes: NULL, a string literal, the
    /// address of (an element or field of) a heap global, a decayed heap
    /// array, such an address plus or minus a constant, or a function.
    fn static_address(&self, e: CExprId) -> TranslationResult<Option<i64>> {
        match self.ast_context[e].kind {
            CExprKind::Paren(_, i) | CExprKind::ConstantExpr(_, i, _) => self.static_address(i),
            CExprKind::ImplicitCast(_, inner, CastKind::ArrayToPointerDecay, _, _) => self.static_lvalue_address(inner),
            CExprKind::ImplicitCast(_, inner, CastKind::FunctionToPointerDecay, _, _) if fn_table() => {
                self.static_fn_index(inner)
            }
            CExprKind::ImplicitCast(ty, inner, _, _, _) | CExprKind::ExplicitCast(ty, inner, _, _, _)
                if self.ast_context.resolve_type(ty.ctype).kind.is_pointer() =>
            {
                match self.static_int(inner) {
                    Some(0) => Ok(Some(0)),
                    Some(_) => Ok(None),
                    None => self.static_address(inner),
                }
            }
            CExprKind::Unary(_, CUnOp::AddressOf, arg, _) => {
                let mut a = arg;
                while let CExprKind::Paren(_, i) = self.ast_context[a].kind {
                    a = i;
                }
                if let CExprKind::DeclRef(_, d, _) = self.ast_context[a].kind {
                    if matches!(self.ast_context[d].kind, CDeclKind::Function { .. }) {
                        return if fn_table() { self.static_fn_index(a) } else { Ok(None) };
                    }
                }
                self.static_lvalue_address(arg)
            }
            CExprKind::Binary(ty, op @ (CBinOp::Add | CBinOp::Subtract), l, r, _, _) => {
                let CTypeKind::Pointer(p) = self.ast_context.resolve_type(ty.ctype).kind else { return Ok(None) };
                let Ok(scale) = self.sizeof_type(p.ctype) else { return Ok(None) };
                let (ptr, k) = match (self.static_int(l), self.static_int(r)) {
                    (None, Some(k)) => (l, k),
                    (Some(k), None) if op == CBinOp::Add => (r, k),
                    _ => return Ok(None),
                };
                let k = if op == CBinOp::Subtract { -k } else { k };
                Ok(self.static_address(ptr)?.map(|a| a + k * scale as i64))
            }
            _ => Ok(self.static_int(e).filter(|&v| v == 0)),
        }
    }

    /// The constant heap address of an lvalue: a string literal, a heap
    /// global, or a constant-index element or field of one.
    fn static_lvalue_address(&self, e: CExprId) -> TranslationResult<Option<i64>> {
        match self.ast_context[e].kind {
            CExprKind::Paren(_, i) => self.static_lvalue_address(i),
            CExprKind::Literal(_, CLiteral::String(..)) => match self.array_address(ExprContext::default(), e)? {
                Some(WithStmts { val: DaExpr::ConstInt(at), .. }) => Ok(Some(at)),
                _ => Ok(None),
            },
            CExprKind::DeclRef(_, d, _) => Ok(global_offset(d)),
            CExprKind::Member(_, base, field, kind, _) => {
                let base_at = match kind {
                    MemberKind::Dot => self.static_lvalue_address(base)?,
                    MemberKind::Arrow => self.static_address(base)?,
                };
                let off = self.field_offset(field)? as i64;
                Ok(base_at.map(|a| a + off))
            }
            CExprKind::ArraySubscript(ty, lhs, rhs, _) => {
                let (ptr, idx) = match (self.static_int(lhs), self.static_int(rhs)) {
                    (None, Some(k)) => (lhs, k),
                    (Some(k), None) => (rhs, k),
                    _ => return Ok(None),
                };
                let Ok(scale) = self.sizeof_type(ty.ctype) else { return Ok(None) };
                Ok(self.static_address(ptr)?.map(|a| a + idx * scale as i64))
            }
            CExprKind::Unary(_, CUnOp::Deref, p, _) => self.static_address(p),
            _ => Ok(None),
        }
    }

    /// `--fnptr-model table`: the table index of function designator `f`.
    fn static_fn_index(&self, f: CExprId) -> TranslationResult<Option<i64>> {
        match self.fn_index_of(f, f) {
            Ok(DaExpr::ConstInt(k)) => Ok(Some(k)),
            Ok(_) => Ok(None),
            Err(e) => Err(e),
        }
    }

    /// The constant value of a floating static initializer element.
    fn static_float(&self, e: CExprId) -> Option<f64> {
        match &self.ast_context[e].kind {
            CExprKind::Literal(_, CLiteral::Floating(v, _)) => Some(*v),
            CExprKind::ConstantExpr(_, inner, _) | CExprKind::Paren(_, inner) => self.static_float(*inner),
            CExprKind::ImplicitCast(ty, inner, _, _, _) | CExprKind::ExplicitCast(ty, inner, _, _, _) => {
                let v = self.static_float(*inner)?;
                Some(match self.ast_context.resolve_type(ty.ctype).kind {
                    CTypeKind::Float => v as f32 as f64,
                    _ => v,
                })
            }
            CExprKind::Unary(_, CUnOp::Negate, inner, _) => self.static_float(*inner).map(|v| -v),
            CExprKind::Binary(ty, op, l, r, _, _)
                if matches!(
                    self.ast_context.resolve_type(ty.ctype).kind,
                    CTypeKind::Float | CTypeKind::Double
                ) =>
            {
                let (a, b) = (self.static_float(*l)?, self.static_float(*r)?);
                let v = match op {
                    CBinOp::Add => a + b,
                    CBinOp::Subtract => a - b,
                    CBinOp::Multiply => a * b,
                    CBinOp::Divide => a / b,
                    _ => return None,
                };
                // A `float` operation rounds to single precision.
                Some(match self.ast_context.resolve_type(ty.ctype).kind {
                    CTypeKind::Float => v as f32 as f64,
                    _ => v,
                })
            }
            _ => self.static_int(e).map(|v| v as f64),
        }
    }

    /// The constant integer value of a static initializer element.
    fn static_int(&self, e: CExprId) -> Option<i64> {
        match &self.ast_context[e].kind {
            CExprKind::Literal(_, CLiteral::Integer(v, _)) => Some(*v as i64),
            CExprKind::Literal(_, CLiteral::Character(v)) => Some(*v as i64),
            CExprKind::ConstantExpr(_, _, Some(ConstIntExpr::I(v))) => Some(*v),
            CExprKind::ConstantExpr(_, _, Some(ConstIntExpr::U(v))) => Some(*v as i64),
            // C converts a floating value to an integer by truncation.
            CExprKind::ImplicitCast(_, inner, CastKind::FloatingToIntegral, _, _)
            | CExprKind::ExplicitCast(_, inner, CastKind::FloatingToIntegral, _, _) => {
                let v = self.static_float(*inner)?.trunc();
                (v >= i64::MIN as f64 && v <= i64::MAX as f64).then_some(v as i64)
            }
            CExprKind::ConstantExpr(_, inner, None)
            | CExprKind::Paren(_, inner)
            | CExprKind::ImplicitCast(_, inner, _, _, _)
            | CExprKind::ExplicitCast(_, inner, _, _, _) => self.static_int(*inner),
            CExprKind::Unary(_, CUnOp::Negate, inner, _) => self.static_int(*inner).map(|v| v.wrapping_neg()),
            CExprKind::Unary(_, CUnOp::Plus, inner, _) => self.static_int(*inner),
            CExprKind::Unary(_, CUnOp::Complement, inner, _) => self.static_int(*inner).map(|v| !v),
            CExprKind::Unary(_, CUnOp::Not, inner, _) => self.static_int(*inner).map(|v| (v == 0) as i64),
            CExprKind::UnaryType(_, CUnTypeOp::SizeOf, _, arg) => self.sizeof_type(arg.ctype).ok().map(|v| v as i64),
            CExprKind::OffsetOf(_, OffsetOfKind::Constant(v)) => Some(*v as i64),
            CExprKind::Conditional(_, c, t, f) => {
                if self.static_int(*c)? != 0 {
                    self.static_int(*t)
                } else {
                    self.static_int(*f)
                }
            }
            // Integer arithmetic on constants.  On unsigned operands division,
            // remainder, right shift and comparisons are folded only for
            // non-negative values, where they agree with i64 arithmetic; signed
            // ones truncate towards zero as C does.  The store truncates to the
            // element width.
            CExprKind::Binary(_, op, l, r, _, _) => {
                let (a, b) = (self.static_int(*l)?, self.static_int(*r)?);
                let signed = self.ast_context[*l]
                    .kind
                    .get_type()
                    .map_or(false, |t| self.ast_context.resolve_type(t).kind.is_signed_integral_type());
                let nonneg = signed || (a >= 0 && b >= 0);
                Some(match op {
                    CBinOp::Add => a.wrapping_add(b),
                    CBinOp::Subtract => a.wrapping_sub(b),
                    CBinOp::Multiply => a.wrapping_mul(b),
                    CBinOp::Divide if nonneg && b != 0 => a.wrapping_div(b),
                    CBinOp::Modulus if nonneg && b != 0 => a.wrapping_rem(b),
                    CBinOp::ShiftLeft if (0..63).contains(&b) => a.wrapping_shl(b as u32),
                    CBinOp::ShiftRight if nonneg && (0..63).contains(&b) => a >> b,
                    CBinOp::BitAnd => a & b,
                    CBinOp::BitOr => a | b,
                    CBinOp::BitXor => a ^ b,
                    CBinOp::EqualEqual => (a == b) as i64,
                    CBinOp::NotEqual => (a != b) as i64,
                    CBinOp::Less if nonneg => (a < b) as i64,
                    CBinOp::Greater if nonneg => (a > b) as i64,
                    CBinOp::LessEqual if nonneg => (a <= b) as i64,
                    CBinOp::GreaterEqual if nonneg => (a >= b) as i64,
                    CBinOp::And => (a != 0 && b != 0) as i64,
                    CBinOp::Or => (a != 0 || b != 0) as i64,
                    _ => return None,
                })
            }
            CExprKind::DeclRef(_, d, _) => match self.ast_context[*d].kind {
                CDeclKind::EnumConstant { value: ConstIntExpr::I(v), .. } => Some(v),
                CDeclKind::EnumConstant { value: ConstIntExpr::U(v), .. } => Some(v as i64),
                _ => None,
            },
            _ => None,
        }
    }

    /// Writes the bytes of a static initializer of C type `ty` at `at`:
    /// integer scalars and arrays of them (also from a string literal);
    /// anything else is refused, located.
    fn static_init_bytes(&self, init: CExprId, ty: CTypeId, out: &mut [u8], at: usize) -> TranslationResult<()> {
        let refuse = || {
            format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[init].loc),
                "not supported under --memory-model linear yet: this initializer of a global in the heap"
            )
        };
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::ConstantArray(elem, n) => {
                let esize = self.sizeof_type(elem).map_err(|_| refuse())? as usize;
                let mut e = init;
                while let CExprKind::Paren(_, i) | CExprKind::ImplicitCast(_, i, _, _, _) = self.ast_context[e].kind {
                    e = i;
                }
                match &self.ast_context[e].kind {
                    CExprKind::InitList(_, items, None, _) => {
                        if items.len() > n {
                            return Err(refuse());
                        }
                        for (k, item) in items.iter().enumerate() {
                            if matches!(self.ast_context[*item].kind, CExprKind::ImplicitValueInit(_)) {
                                continue;
                            }
                            self.static_init_bytes(*item, elem, out, at + k * esize)?;
                        }
                        Ok(())
                    }
                    CExprKind::Literal(_, CLiteral::String(bytes, 1)) if esize == 1 => {
                        for (k, b) in bytes.iter().take(n).enumerate() {
                            out[at + k] = *b;
                        }
                        Ok(())
                    }
                    _ => Err(refuse()),
                }
            }
            // A union: the one initialized member, at offset 0.
            CTypeKind::Union(_) => {
                let mut e = init;
                while let CExprKind::Paren(_, i) | CExprKind::ImplicitCast(_, i, _, _, _) = self.ast_context[e].kind {
                    e = i;
                }
                match &self.ast_context[e].kind {
                    CExprKind::InitList(_, items, _, _) if items.is_empty() => Ok(()),
                    CExprKind::InitList(_, items, Some(field), _) if items.len() == 1 => {
                        let CDeclKind::Field { typ: fty, bitfield_width: None, .. } = self.ast_context[*field].kind
                        else {
                            return Err(refuse());
                        };
                        if matches!(self.ast_context[items[0]].kind, CExprKind::ImplicitValueInit(_)) {
                            return Ok(());
                        }
                        self.static_init_bytes(items[0], fty.ctype, out, at)
                    }
                    _ => Err(refuse()),
                }
            }
            CTypeKind::Struct(rec) => {
                let CDeclKind::Struct { fields: Some(ref fields), .. } = self.ast_context[rec].kind else {
                    return Err(refuse());
                };
                let mut e = init;
                while let CExprKind::Paren(_, i) | CExprKind::ImplicitCast(_, i, _, _, _) = self.ast_context[e].kind {
                    e = i;
                }
                let CExprKind::InitList(_, items, None, _) = &self.ast_context[e].kind else {
                    return Err(refuse());
                };
                if items.len() > fields.len() {
                    return Err(refuse());
                }
                for (item, field) in items.iter().zip(fields.iter()) {
                    let CDeclKind::Field { typ: fty, bitfield_width: None, .. } = self.ast_context[*field].kind else {
                        return Err(refuse());
                    };
                    if matches!(self.ast_context[*item].kind, CExprKind::ImplicitValueInit(_)) {
                        continue;
                    }
                    let off = self.field_offset(*field)? as usize;
                    self.static_init_bytes(*item, fty.ctype, out, at + off)?;
                }
                Ok(())
            }
            _ => {
                let Some(scalar) = self.scalar_of(ty) else { return Err(refuse()) };
                let v = match scalar {
                    Scalar::F32 => (self.static_float(init).ok_or_else(refuse)? as f32).to_bits() as i64,
                    Scalar::F64 => self.static_float(init).ok_or_else(refuse)?.to_bits() as i64,
                    // A pointer element: a constant address (or function index).
                    Scalar::Ptr | Scalar::Fn(_) => self.static_address(init)?.ok_or_else(refuse)?,
                    _ => self.static_int(init).ok_or_else(refuse)?,
                };
                let width = self.sizeof_type(ty).map_err(|_| refuse())? as usize;
                for k in 0..width {
                    out[at + k] = (v >> (8 * k)) as u8;
                }
                Ok(())
            }
        }
    }

    /// The stores that copy each scalar parameter whose address is taken
    /// into its C stack slot, first thing in the body; every later use of
    /// the parameter is a heap access at that slot.
    pub(crate) fn linear_param_spills(
        &self,
        bindings: &[(CDeclId, String, CQualTypeId, String)],
    ) -> TranslationResult<Vec<DaStmt>> {
        let mut out = Vec::new();
        for (decl, _, typ, pname) in bindings {
            let Some(off) = frame_offset(*decl) else { continue };
            let Some(s) = self.scalar_of(typ.ctype) else { continue };
            let a = plus(&DaExpr::Var(FP.into()), off);
            let stored = self.emit_store(s, WithStmts::new_val(a), WithStmts::new_val(DaExpr::Var(pname.clone())));
            let (stmts, _) = stored.into_stmts_and_val();
            out.extend(stmts);
        }
        Ok(out)
    }

    /// Makes `frame` the frame the following lowering reads.
    pub(crate) fn linear_set_frame(&self, frame: StdHashMap<CDeclId, i64>) {
        FRAME.with(|f| *f.borrow_mut() = frame);
    }

    /// The declaration of a local that lives in the C stack: no daScript
    /// variable, only the store of its initializer at its frame slot.
    pub(crate) fn linear_frame_decl(
        &self,
        ctx: ExprContext,
        decl_id: CDeclId,
        initializer: Option<CExprId>,
        typ: CQualTypeId,
    ) -> TranslationResult<Option<crate::cfg::DeclStmtInfo>> {
        let Some(off) = frame_offset(decl_id) else {
            return Ok(None);
        };
        let Some(init) = initializer else {
            return Ok(Some(crate::cfg::DeclStmtInfo::new(vec![], vec![], vec![])));
        };
        let a = plus(&DaExpr::Var(FP.into()), off);
        // A constant aggregate initializer (of any layout, packed records
        // and unions included) is written byte by byte.
        if self.is_aggregate(typ.ctype) {
            if let Ok(size) = self.sizeof_type(typ.ctype) {
                let mut bytes = vec![0u8; size as usize];
                if size <= 1024 && self.static_init_bytes(init, typ.ctype, &mut bytes, 0).is_ok() {
                    let stmts: Vec<DaStmt> = bytes
                        .iter()
                        .enumerate()
                        .map(|(k, b)| {
                            DaStmt::Expr(DaExpr::Assign(
                                Box::new(DaExpr::Index(
                                    Box::new(DaExpr::Var("c2da_mem".into())),
                                    Box::new(plus(&a, k as i64)),
                                )),
                                Box::new(cast(DaType::uint8(), DaExpr::ConstInt(*b as i64))),
                            ))
                        })
                        .collect();
                    return Ok(Some(crate::cfg::DeclStmtInfo::new(vec![], stmts.clone(), stmts)));
                }
            }
        }
        let value = self.convert_expr(ctx.used(), init, Some(typ))?;
        let stored = if self.is_aggregate(typ.ctype) {
            self.store_aggregate(init, typ, &a, value)?
        } else {
            let s = self.scalar_or_refuse(init, typ.ctype)?;
            let value = self.force_temp(value, s.da_type());
            self.emit_store(s, WithStmts::new_val(a), value)
        };
        let (stmts, _) = stored.into_stmts_and_val();
        Ok(Some(crate::cfg::DeclStmtInfo::new(vec![], stmts.clone(), stmts)))
    }

    /// Splits a function with a C stack frame into the body, which takes the
    /// frame pointer as its last parameter, and a wrapper under the C name
    /// that pushes the frame, calls the body and pops the frame, so every
    /// return path of the body restores the stack pointer.
    pub(crate) fn linear_frame_wrap(&self, func: DaDecl, frame: i64) -> TranslationResult<(DaDecl, DaDecl)> {
        let DaDecl::Function(f) = func else {
            return Err(TranslationError::generic("a C stack frame on a non-function"));
        };
        let body_name = format!("{}_c2da_frame", f.name);
        let mut args: Vec<DaExpr> = f
            .params
            .iter()
            .filter_map(|p| match p {
                DaStmt::Param { name, .. } => Some(DaExpr::Var(name.clone())),
                _ => None,
            })
            .collect();
        let mut inner = f.clone();
        inner.name = body_name.clone();
        inner.annotations.clear();
        inner.params.push(DaStmt::Param {
            name: FP.into(),
            param_type: DaType::int(),
            default: None,
            is_mutable: false,
        });
        args.push(DaExpr::Call(
            Box::new(DaExpr::Var("c2da_lin_enter".into())),
            vec![DaExpr::ConstInt(frame)],
        ));
        let call = DaExpr::Call(Box::new(DaExpr::Var(body_name)), args);
        let saved = "c2da_saved_sp".to_owned();
        let mut stmts = vec![DaStmt::Let {
            name: saved.clone(),
            var_type: Some(DaType::int()),
            init: Some(DaExpr::Var("c2da_lin_sp".into())),
        }];
        let restore = DaStmt::Expr(DaExpr::Assign(
            Box::new(DaExpr::Var("c2da_lin_sp".into())),
            Box::new(DaExpr::Var(saved)),
        ));
        if matches!(f.ret_type.kind, DaTypeKind::Void) {
            stmts.push(DaStmt::Expr(call));
            stmts.push(restore);
        } else {
            stmts.push(DaStmt::Let {
                name: "c2da_result".into(),
                var_type: Some(f.ret_type.clone()),
                init: Some(call),
            });
            stmts.push(restore);
            stmts.push(DaStmt::Expr(DaExpr::Return(Some(Box::new(DaExpr::Var("c2da_result".into()))))));
        }
        let mut outer = f;
        outer.body = Some(DaExpr::Block(DaBlock { stmts }));
        Ok((DaDecl::Function(inner), DaDecl::Function(outer)))
    }

    /// A struct or array whose whole value is copied to or from the heap.
    fn is_aggregate(&self, ty: CTypeId) -> bool {
        matches!(
            self.ast_context.resolve_type(ty).kind,
            CTypeKind::Struct(_) | CTypeKind::Union(_) | CTypeKind::ConstantArray(..)
        )
    }

    /// The scalar leaves of an aggregate value: for each, its kind, its
    /// daScript place below `place`, and its byte offset from the start of
    /// the value (Clang's field offsets).  A union, a storage-backed record
    /// or a leaf with no heap form is refused at `at`.
    fn aggregate_leaves(
        &self,
        at: CExprId,
        ty: CTypeId,
        place: DaExpr,
        offset: i64,
        out: &mut Vec<(Scalar, DaExpr, i64)>,
    ) -> TranslationResult<()> {
        /// More leaves than this are refused rather than unrolled.
        const MAX_LEAVES: usize = 4096;
        if out.len() > MAX_LEAVES {
            return Err(self.linear_refuse(at, "a record or array value of more than 4096 scalars through a pointer"));
        }
        if let Some(s) = self.scalar_of(ty) {
            out.push((s, place, offset));
            return Ok(());
        }
        match self.ast_context.resolve_type(ty).kind {
            CTypeKind::Struct(record) if !self.is_storage_backed_record(record) => {
                let Some(members) = self.natural_members(record) else {
                    return Err(self.linear_refuse(at, "a record value with no natural layout through a pointer"));
                };
                for member in members {
                    match member {
                        NaturalMember::Field(fid) => {
                            let CDeclKind::Field { typ, .. } = &self.ast_context[fid].kind else {
                                return Err(TranslationError::generic("C record member is not a field"));
                            };
                            let name = self.natural_field_name(record, fid).ok_or_else(|| {
                                TranslationError::generic("record field name not declared yet")
                            })?;
                            let field = DaExpr::Field(Box::new(place.clone()), name);
                            self.aggregate_leaves(at, typ.ctype, field, offset + self.field_offset(fid)?, out)?;
                        }
                        // A bitfield of a daScript record value is itself
                        // still raw-memory lowered under the model.
                        NaturalMember::BitfieldUnit { .. } => {
                            return Err(self.linear_refuse(at, "a record value with bitfields through a pointer"));
                        }
                    }
                }
                Ok(())
            }
            CTypeKind::ConstantArray(elem, n) => {
                let size = self.sizeof_type(elem)?;
                for i in 0..n {
                    let item = DaExpr::Index(Box::new(place.clone()), Box::new(DaExpr::ConstInt(i as i64)));
                    self.aggregate_leaves(at, elem, item, offset + i as i64 * size, out)?;
                }
                Ok(())
            }
            _ => Err(self.linear_refuse(
                at,
                "a value of this type through a pointer (unions, enumerations and function pointers in the heap are read field by field only)",
            )),
        }
    }

    /// The whole aggregate at the stable heap address `a`, read into a
    /// fresh daScript value field by field.
    fn load_aggregate(&self, at: CExprId, ty: CQualTypeId, a: &DaExpr) -> TranslationResult<WithStmts<DaExpr>> {
        let name = self.fresh_name();
        let mut leaves = vec![];
        self.aggregate_leaves(at, ty.ctype, DaExpr::Var(name.clone()), 0, &mut leaves)?;
        let mut stmts = vec![DaStmt::Var {
            name: name.clone(),
            var_type: self.convert_type(ty)?,
            init: None,
        }];
        for (s, place, off) in leaves {
            stmts.push(DaStmt::Expr(DaExpr::Assign(Box::new(place), Box::new(load(s, &plus(a, off))))));
        }
        Ok(WithStmts::new(stmts, DaExpr::Var(name)))
    }

    /// Stores the aggregate `value` (a daScript value) at the stable heap
    /// address `a` field by field; the expression is the stored value.
    fn store_aggregate(
        &self,
        at: CExprId,
        ty: CQualTypeId,
        a: &DaExpr,
        value: WithStmts<DaExpr>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let (mut stmts, v) = value.into_stmts_and_val();
        let v = match v {
            DaExpr::Var(_) => v,
            other => {
                let name = self.fresh_name();
                stmts.push(DaStmt::Var {
                    name: name.clone(),
                    var_type: self.convert_type(ty)?,
                    init: Some(other),
                });
                DaExpr::Var(name)
            }
        };
        let mut leaves = vec![];
        self.aggregate_leaves(at, ty.ctype, v.clone(), 0, &mut leaves)?;
        let mut fresh = || self.fresh_name();
        for (s, place, off) in leaves {
            stmts.extend(store(s, &plus(a, off), &place, &mut fresh));
        }
        Ok(WithStmts::new(stmts, v))
    }

    /// The heap address of `expr_id` when it is an lvalue-to-rvalue read of
    /// a heap place (parentheses stripped).
    fn heap_read_source(&self, ctx: ExprContext, expr_id: CExprId) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let mut e = expr_id;
        loop {
            match &self.ast_context[e].kind {
                CExprKind::Paren(_, inner) => e = *inner,
                CExprKind::ImplicitCast(_, inner, CastKind::LValueToRValue, _, _) => {
                    return self.heap_place(ctx, *inner);
                }
                _ => return Ok(None),
            }
        }
    }

    fn scalar_or_refuse(&self, expr_id: CExprId, ty: CTypeId) -> TranslationResult<Scalar> {
        self.scalar_of(ty).ok_or_else(|| {
            self.linear_refuse(
                expr_id,
                "a value of this type through a pointer (records, arrays, enumerations and function pointers in the heap are read field by field only)",
            )
        })
    }

    /// Binds `value` to a fresh `let` unless it may be repeated.
    fn stable(&self, value: WithStmts<DaExpr>, ty: DaType) -> WithStmts<DaExpr> {
        if is_stable(&value.val) {
            return value;
        }
        let name = self.renamer.borrow_mut().fresh();
        let (mut stmts, val) = value.into_stmts_and_val();
        stmts.push(DaStmt::Let {
            name: name.clone(),
            var_type: Some(ty),
            init: Some(val),
        });
        WithStmts::new(stmts, DaExpr::Var(name))
    }

    fn fresh_name(&self) -> String {
        self.renamer.borrow_mut().fresh()
    }

    /// `int(e)` unless `e` already is an `int`.
    fn as_int(e: DaExpr) -> DaExpr {
        match &e {
            DaExpr::ConstInt(v) if *v >= i32::MIN as i64 && *v <= i32::MAX as i64 => e,
            _ => match Self::infer_type(&e) {
                Some(t) if matches!(t.kind, DaTypeKind::Int) => e,
                _ => cast(DaType::int(), e),
            },
        }
    }

    /// `base + index * size` with constant folding.
    fn offset_by(base: DaExpr, index: DaExpr, size: i64, negate: bool) -> DaExpr {
        let index = Self::as_int(index);
        let scaled = match index {
            DaExpr::ConstInt(i) => DaExpr::ConstInt(i * size),
            other if size == 1 => other,
            other => op2("*", other, DaExpr::ConstInt(size)),
        };
        match (scaled, negate) {
            (DaExpr::ConstInt(k), false) => plus(&base, k),
            (DaExpr::ConstInt(k), true) => plus(&base, -k),
            (s, false) => op2("+", base, s),
            (s, true) => op2("-", base, s),
        }
    }

    /// The address of a C lvalue that lives in linear memory, or `None` for
    /// an lvalue that is a daScript variable (a local, a global, a field of
    /// one).
    fn heap_place(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        use CExprKind::*;
        match &self.ast_context[expr_id].kind {
            Paren(_, inner) => self.heap_place(ctx, *inner),
            DeclRef(_, decl, _) => Ok(frame_offset(*decl)
                .map(|off| WithStmts::new_val(plus(&DaExpr::Var(FP.into()), off)))
                .or_else(|| global_offset(*decl).map(|at| WithStmts::new_val(DaExpr::ConstInt(at))))),
            Unary(_, CUnOp::Deref, ptr, _) => {
                let ptr_ty = self.qual_of(*ptr)?;
                if !self.is_data_pointer(ptr_ty.ctype) {
                    return Ok(None);
                }
                Ok(Some(self.convert_expr(ctx.used(), *ptr, None)?))
            }
            ArraySubscript(_, lhs, rhs, _) => {
                let (lhs, rhs) = (*lhs, *rhs);
                let (ptr, idx) = if self.is_data_pointer(self.qual_of(lhs)?.ctype) {
                    (lhs, rhs)
                } else if self.is_data_pointer(self.qual_of(rhs)?.ctype) {
                    (rhs, lhs)
                } else {
                    return Ok(None);
                };
                let pointee = self.linear_pointee(self.qual_of(ptr)?.ctype).unwrap();
                let size = self.step_size(pointee)?;
                // A declared array decays to its address: it is in the heap
                // only when the array itself is (a field array through a
                // pointer, a string literal).
                let base = match self.decayed_array(ptr) {
                    Some(array) => match self.array_address(ctx, array)? {
                        Some(address) => address,
                        None => return Ok(None),
                    },
                    None => self.convert_expr(ctx.used(), ptr, None)?,
                };
                let index = self.convert_expr(ctx.used(), idx, None)?;
                Ok(Some(base.zip(index).map(|(b, i)| Self::offset_by(b, i, size, false))))
            }
            Member(_, base, field, kind, _) => {
                let base_address = match kind {
                    MemberKind::Arrow => self.convert_expr(ctx.used(), *base, None)?,
                    MemberKind::Dot => match self.heap_place(ctx, *base)? {
                        Some(address) => address,
                        None => return Ok(None),
                    },
                };
                if let CDeclKind::Field {
                    bitfield_width: Some(_),
                    ..
                } = self.ast_context[*field].kind
                {
                    return Err(self.linear_refuse(expr_id, "a bitfield through a pointer"));
                }
                let offset = self.field_offset(*field)?;
                Ok(Some(base_address.map(|b| plus(&b, offset))))
            }
            _ => Ok(None),
        }
    }

    /// `a[i]` over a declared array that is a daScript value (a local, a
    /// global, a field of one): plain daScript indexing, the decay never
    /// becomes an address.  `None` for anything else.
    fn linear_daslang_index(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let CExprKind::ArraySubscript(_, lhs, rhs, _) = self.ast_context[expr_id].kind else {
            return Ok(None);
        };
        let (array, idx) = match (self.decayed_array(lhs), self.decayed_array(rhs)) {
            (Some(array), _) => (array, rhs),
            (None, Some(array)) => (array, lhs),
            _ => return Ok(None),
        };
        if matches!(self.ast_context[array].kind, CExprKind::Literal(..)) {
            return Ok(None);
        }
        let base = self.convert_expr(ctx.used(), array, None)?;
        let index = self.convert_expr(ctx.used(), idx, None)?;
        Ok(Some(base.zip(index).map(|(b, i)| {
            DaExpr::Index(Box::new(b), Box::new(Self::as_int(i)))
        })))
    }

    /// The array operand of an array-to-pointer decay, parentheses stripped.
    fn decayed_array(&self, expr_id: CExprId) -> Option<CExprId> {
        let mut e = expr_id;
        loop {
            match &self.ast_context[e].kind {
                CExprKind::Paren(_, inner) => e = *inner,
                CExprKind::ImplicitCast(_, inner, CastKind::ArrayToPointerDecay, _, _) => {
                    let mut a = *inner;
                    while let CExprKind::Paren(_, i) = &self.ast_context[a].kind {
                        a = *i;
                    }
                    return Some(a);
                }
                _ => return None,
            }
        }
    }

    /// The heap address of an array object: a string literal's static
    /// offset, or an array that is itself a heap place.
    fn array_address(
        &self,
        ctx: ExprContext,
        array: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        if let CExprKind::Literal(_, CLiteral::String(bytes, width)) = &self.ast_context[array].kind {
            if *width != 1 {
                return Err(self.linear_refuse(array, "a wide string literal"));
            }
            let mut bytes = bytes.clone();
            // Clang's literal may carry its array extent; C adds the NUL.
            let ty = self.qual_of(array)?;
            let size = match self.ast_context.resolve_type(ty.ctype).kind {
                CTypeKind::ConstantArray(_, n) => n,
                _ => bytes.len() + 1,
            };
            bytes.resize(size.max(bytes.len() + 1), 0);
            return Ok(Some(WithStmts::new_val(DaExpr::ConstInt(intern(bytes)))));
        }
        self.heap_place(ctx, array)
    }

    /// The `--memory-model linear` form of `expr_id`, or `None` when the
    /// ordinary lowering is the linear one too (no pointer involved).
    pub(crate) fn linear_expr(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        use CExprKind::*;
        let kind = self.ast_context[expr_id].kind.clone();
        match kind {
            Unary(ty, CUnOp::Deref, ..) | ArraySubscript(ty, ..) | Member(ty, ..) => {
                let Some(address) = self.heap_place(ctx, expr_id)? else {
                    return self.linear_daslang_index(ctx, expr_id);
                };
                if self.is_aggregate(ty.ctype) {
                    let (mut stmts, a) = self.stable(address, DaType::int()).into_stmts_and_val();
                    let value = self.load_aggregate(expr_id, ty, &a)?;
                    let (vstmts, v) = value.into_stmts_and_val();
                    stmts.extend(vstmts);
                    return Ok(Some(WithStmts::new(stmts, v)));
                }
                let s = self.scalar_or_refuse(expr_id, ty.ctype)?;
                let address = self.stable(address, DaType::int());
                Ok(Some(address.map(|a| load(s, &a))))
            }
            ImplicitCast(ty, inner, ck, _, _) | ExplicitCast(ty, inner, ck, _, _) => {
                self.linear_cast(ctx, expr_id, ty, inner, ck)
            }
            Unary(_, CUnOp::AddressOf, arg, _) => {
                let arg_ty = self.qual_of(arg)?;
                if matches!(
                    self.ast_context.resolve_type(arg_ty.ctype).kind,
                    CTypeKind::Function(..)
                ) {
                    if fn_table() {
                        return Ok(Some(WithStmts::new_val(self.fn_index_of(expr_id, arg)?)));
                    }
                    return Ok(None);
                }
                match self.heap_place(ctx, arg)? {
                    Some(address) => Ok(Some(address)),
                    None => match self.array_address(ctx, arg)? {
                        Some(address) => Ok(Some(address)),
                        None => Err(self.linear_refuse(
                            expr_id,
                            "the address of a global object or a parameter (only locals live in the C stack)",
                        )),
                    },
                }
            }
            // `++`/`--` and binary operators: `operators.rs` calls
            // `linear_incdec` / `linear_binary` itself, so a condition or a
            // `for` step that converts them directly is covered too.
            Call(_, func, args) => self.linear_call(ctx, expr_id, func, &args),
            // Reads, writes and addresses of a C-stack local go through
            // `heap_place`; any other use of its name has no daScript object.
            DeclRef(_, decl, _) if frame_offset(decl).is_some() => Err(self.linear_refuse(
                expr_id,
                "this use of a local that lives in the C stack (--locals-in-heap)",
            )),
            Literal(_, CLiteral::String(..)) => Ok(None),
            _ => Ok(None),
        }
    }

    fn linear_cast(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        ty: CQualTypeId,
        inner: CExprId,
        ck: CastKind,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let to_ptr = self.is_data_pointer(ty.ctype);
        let inner_ty = self.qual_of(inner)?;
        let from_ptr = self.is_data_pointer(inner_ty.ctype);
        // `--fnptr-model table`: a function pointer is an `int` index.
        if fn_table() {
            let to_fn = self.is_fn_pointer(ty.ctype);
            let from_fn = self.is_fn_pointer(inner_ty.ctype);
            match ck {
                CastKind::FunctionToPointerDecay | CastKind::BuiltinFnToFnPtr => {
                    return Ok(Some(WithStmts::new_val(self.fn_index_of(expr_id, inner)?)));
                }
                CastKind::NullToPointer if to_fn => {
                    return Ok(Some(WithStmts::new_val(DaExpr::ConstInt(0))));
                }
                CastKind::PointerToBoolean if from_fn => {
                    return Ok(Some(
                        self.convert_expr(ctx.used(), inner, None)?
                            .map(|v| op2("!=", v, DaExpr::ConstInt(0))),
                    ));
                }
                CastKind::BitCast | CastKind::NoOp | CastKind::ConstCast if to_fn && from_fn => {
                    // Indices are program-wide and every signature's table
                    // spans all of them (a slot is empty where the function
                    // has another signature), so a cast keeps the index: a
                    // round trip back to the function's own type calls it, as
                    // in C, and a call through a mismatched type finds an
                    // empty slot and panics.
                    return Ok(Some(self.convert_expr(ctx.used(), inner, None)?));
                }
                // An integer as a function pointer is that index (a sentinel
                // such as `(actionf_v)(-1)` is in no table; calling it panics).
                CastKind::IntegralToPointer if to_fn => {
                    let v = self.convert_expr(ctx.used(), inner, None)?;
                    return Ok(Some(v.map(|v| if Self::infer_type(&v) == Some(DaType::int()) { v } else { cast(DaType::int(), v) })));
                }
                CastKind::BitCast if to_fn && from_ptr && self.ast_context.is_null_expr(inner) => {
                    return Ok(Some(WithStmts::new_val(DaExpr::ConstInt(0))));
                }
                // A function pointer through `void *` and back (a callback
                // passed as `void *routine`): both are `int`, the index
                // travels unchanged, and only a call through the restored
                // function type uses it.
                CastKind::BitCast if (to_fn && from_ptr) || (from_fn && to_ptr) => {
                    return Ok(Some(self.convert_expr(ctx.used(), inner, None)?));
                }
                _ if to_fn || from_fn => {
                    if matches!(ck, CastKind::LValueToRValue) {
                        // Falls through to the heap load below.
                    } else {
                        return Err(self.linear_refuse(
                            expr_id,
                            &format!("function pointer cast {ck:?} under --fnptr-model table"),
                        ));
                    }
                }
                _ => {}
            }
        }
        match ck {
            CastKind::NullToPointer if to_ptr => {
                // Side effects of a null pointer constant are impossible.
                Ok(Some(WithStmts::new_val(DaExpr::ConstInt(0))))
            }
            CastKind::NullToPointer if matches!(self.scalar_of(ty.ctype), Some(Scalar::Fn(_))) => {
                Ok(Some(WithStmts::new_val(DaExpr::DefaultValue(self.convert_type(ty)?))))
            }
            CastKind::LValueToRValue => {
                let Some(address) = self.heap_place(ctx, inner)? else {
                    return Ok(None);
                };
                if self.is_aggregate(ty.ctype) {
                    let (mut stmts, a) = self.stable(address, DaType::int()).into_stmts_and_val();
                    let (vstmts, v) = self.load_aggregate(expr_id, ty, &a)?.into_stmts_and_val();
                    stmts.extend(vstmts);
                    return Ok(Some(WithStmts::new(stmts, v)));
                }
                let s = self.scalar_or_refuse(expr_id, ty.ctype)?;
                let address = self.stable(address, DaType::int());
                Ok(Some(address.map(|a| load(s, &a))))
            }
            CastKind::ArrayToPointerDecay => {
                let mut array = inner;
                while let CExprKind::Paren(_, i) = &self.ast_context[array].kind {
                    array = *i;
                }
                match self.array_address(ctx, array)? {
                    Some(address) => Ok(Some(address)),
                    None => Err(self.linear_refuse(
                        expr_id,
                        "a global array, or an array in a parameter or a call result, used as a pointer (only locals live in the C stack)",
                    )),
                }
            }
            CastKind::BitCast | CastKind::NoOp | CastKind::ConstCast if to_ptr || from_ptr => {
                // `(ReadFn)NULL` (`NULL` is `(void *)0`): the null function value.
                if from_ptr && !to_ptr && self.ast_context.is_null_expr(inner) {
                    if let Some(Scalar::Fn(_)) = self.scalar_of(ty.ctype) {
                        return Ok(Some(WithStmts::new_val(DaExpr::DefaultValue(self.convert_type(ty)?))));
                    }
                }
                if to_ptr && from_ptr {
                    Ok(Some(self.convert_expr(ctx.used(), inner, None)?))
                } else if matches!(ck, CastKind::NoOp | CastKind::ConstCast) {
                    Ok(None)
                } else {
                    Err(self.linear_refuse(expr_id, "a cast between a data pointer and a function pointer"))
                }
            }
            CastKind::PointerToIntegral if from_ptr => {
                let to = self.convert_type(ty)?;
                Ok(Some(self.convert_expr(ctx.used(), inner, None)?.map(|v| cast(to, v))))
            }
            CastKind::IntegralToPointer if to_ptr => {
                Ok(Some(self.convert_expr(ctx.used(), inner, None)?.map(|v| cast(DaType::int(), v))))
            }
            CastKind::PointerToBoolean if from_ptr => Ok(Some(
                self.convert_expr(ctx.used(), inner, None)?
                    .map(|v| op2("!=", v, DaExpr::ConstInt(0))),
            )),
            // `(void)p` discards an `int` offset like any other value.
            CastKind::ToVoid => Ok(None),
            _ if to_ptr || from_ptr => {
                if matches!(ck, CastKind::FunctionToPointerDecay | CastKind::BuiltinFnToFnPtr) {
                    return Ok(None);
                }
                Err(self.linear_refuse(expr_id, &format!("pointer cast {ck:?}")))
            }
            _ => Ok(None),
        }
    }

    /// The new value of `old` after C's `op` with the converted right operand.
    fn arith(
        &self,
        op: CBinOp,
        old: DaExpr,
        rhs: DaExpr,
        result: DaType,
        compute: DaType,
    ) -> TranslationResult<DaExpr> {
        let das_op: &'static str = match op {
            CBinOp::AssignAdd | CBinOp::Add => "+",
            CBinOp::AssignSubtract | CBinOp::Subtract => "-",
            CBinOp::AssignMultiply => "*",
            CBinOp::AssignDivide => "/",
            CBinOp::AssignModulus => "%",
            CBinOp::AssignBitXor => "^",
            CBinOp::AssignBitOr => "|",
            CBinOp::AssignBitAnd => "&",
            CBinOp::AssignShiftLeft => "<<",
            CBinOp::AssignShiftRight => ">>",
            _ => return Err(TranslationError::generic("not an arithmetic compound operator")),
        };
        let same = result == compute;
        let left = if same { old } else { cast(compute.clone(), old) };
        let value = op2(das_op, left, cast(compute.clone(), rhs));
        Ok(if same { value } else { cast(result, value) })
    }

    #[allow(clippy::too_many_arguments)]
    pub(crate) fn linear_binary(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        ty: CQualTypeId,
        op: CBinOp,
        lhs: CExprId,
        rhs: CExprId,
        lty: Option<CQualTypeId>,
        _rty: Option<CQualTypeId>,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let lhs_ty = self.qual_of(lhs)?;
        let rhs_ty = self.qual_of(rhs)?;
        let lp = self.is_data_pointer(lhs_ty.ctype);
        let rp = self.is_data_pointer(rhs_ty.ctype);
        match op {
            CBinOp::Assign => {
                let Some(address) = self.heap_place(ctx, lhs)? else {
                    return Ok(None);
                };
                if self.is_aggregate(lhs_ty.ctype) {
                    let (mut stmts, a) = self.stable(address, DaType::int()).into_stmts_and_val();
                    // Heap to heap: one byte copy (memmove: C allows the
                    // exact overlap of `*p = *p`).
                    if let Some(source) = self.heap_read_source(ctx, rhs)? {
                        let (sstmts, src) = source.into_stmts_and_val();
                        stmts.extend(sstmts);
                        let size = self.sizeof_type(lhs_ty.ctype)?;
                        let copy = DaExpr::Call(
                            Box::new(DaExpr::Var("c2da_lin_memmove".into())),
                            vec![a.clone(), src, cast(DaType::uint64(), DaExpr::ConstInt(size))],
                        );
                        if !ctx.is_used() {
                            return Ok(Some(WithStmts::new(stmts, copy)));
                        }
                        stmts.push(DaStmt::Expr(copy));
                        let (vstmts, v) = self.load_aggregate(expr_id, lhs_ty, &a)?.into_stmts_and_val();
                        stmts.extend(vstmts);
                        return Ok(Some(WithStmts::new(stmts, v)));
                    }
                    let value = self.convert_expr(ctx.used(), rhs, Some(lhs_ty))?;
                    let (vstmts, v) = self.store_aggregate(expr_id, lhs_ty, &a, value)?.into_stmts_and_val();
                    stmts.extend(vstmts);
                    return Ok(Some(WithStmts::new(stmts, v)));
                }
                let s = self.scalar_or_refuse(lhs, lhs_ty.ctype)?;
                let address = self.stable(address, DaType::int());
                let value = self.convert_expr(ctx.used(), rhs, Some(lhs_ty))?;
                let value = self.force_temp(value, s.da_type());
                Ok(Some(self.emit_store(s, address, value)))
            }
            CBinOp::AssignAdd | CBinOp::AssignSubtract if lp => {
                let pointee = self.linear_pointee(lhs_ty.ctype).unwrap();
                let size = self.step_size(pointee)?;
                let negate = op == CBinOp::AssignSubtract;
                if let Some(address) = self.heap_place(ctx, lhs)? {
                    let address = self.stable(address, DaType::int());
                    let n = self.convert_expr(ctx.used(), rhs, None)?;
                    let new = address
                        .zip(n)
                        .map(|(a, n)| (Self::offset_by(load(Scalar::Ptr, &a), n, size, negate), a));
                    let (stmts, (new, a)) = new.into_stmts_and_val();
                    let value = self.force_temp(WithStmts::new(stmts, new), DaType::int());
                    return Ok(Some(self.emit_store(Scalar::Ptr, WithStmts::new_val(a), value)));
                }
                let place = self.convert_expr(ctx.used(), lhs, None)?;
                let n = self.convert_expr(ctx.used(), rhs, None)?;
                Ok(Some(place.zip(n).map(|(p, n)| {
                    let new = Self::offset_by(p.clone(), n, size, negate);
                    DaExpr::Assign(Box::new(p), Box::new(new))
                })))
            }
            CBinOp::AssignAdd
            | CBinOp::AssignSubtract
            | CBinOp::AssignMultiply
            | CBinOp::AssignDivide
            | CBinOp::AssignModulus
            | CBinOp::AssignBitXor
            | CBinOp::AssignBitOr
            | CBinOp::AssignBitAnd
            | CBinOp::AssignShiftLeft
            | CBinOp::AssignShiftRight => {
                let Some(address) = self.heap_place(ctx, lhs)? else {
                    return Ok(None);
                };
                let s = self.scalar_or_refuse(lhs, lhs_ty.ctype)?;
                if matches!(s, Scalar::Bool) {
                    return Err(self.linear_refuse(expr_id, "compound assignment to a `_Bool` in the heap"));
                }
                let compute = match lty {
                    Some(t) => self.convert_type(t)?,
                    None => s.da_type(),
                };
                let address = self.stable(address, DaType::int());
                let n = self.convert_expr(ctx.used(), rhs, None)?;
                let combined = address.zip(n);
                let (stmts, (a, n)) = combined.into_stmts_and_val();
                let new = self.arith(op, load(s, &a), n, s.da_type(), compute)?;
                let value = self.force_temp(WithStmts::new(stmts, new), s.da_type());
                Ok(Some(self.emit_store(s, WithStmts::new_val(a), value)))
            }
            CBinOp::Add | CBinOp::Subtract if lp || rp => {
                if lp && rp {
                    // Pointer difference: element count, `ptrdiff_t`.
                    let pointee = self.linear_pointee(lhs_ty.ctype).unwrap();
                    let size = self.step_size(pointee)?;
                    let l = self.convert_expr(ctx.used(), lhs, None)?;
                    let r = self.convert_expr(ctx.used(), rhs, None)?;
                    let to = self.convert_type(ty)?;
                    return Ok(Some(l.zip(r).map(|(l, r)| {
                        let diff = op2("-", l, r);
                        let diff = if size == 1 { diff } else { op2("/", diff, DaExpr::ConstInt(size)) };
                        cast(to, diff)
                    })));
                }
                let (ptr, idx, ptr_ty) = if lp { (lhs, rhs, lhs_ty) } else { (rhs, lhs, rhs_ty) };
                let pointee = self.linear_pointee(ptr_ty.ctype).unwrap();
                let size = self.step_size(pointee)?;
                let p = self.convert_expr(ctx.used(), ptr, None)?;
                let i = self.convert_expr(ctx.used(), idx, None)?;
                let negate = op == CBinOp::Subtract;
                Ok(Some(p.zip(i).map(|(p, i)| Self::offset_by(p, i, size, negate))))
            }
            CBinOp::Less
            | CBinOp::Greater
            | CBinOp::LessEqual
            | CBinOp::GreaterEqual
            | CBinOp::EqualEqual
            | CBinOp::NotEqual
                if lp || rp =>
            {
                let das_op: &'static str = match op {
                    CBinOp::Less => "<",
                    CBinOp::Greater => ">",
                    CBinOp::LessEqual => "<=",
                    CBinOp::GreaterEqual => ">=",
                    CBinOp::EqualEqual => "==",
                    _ => "!=",
                };
                let l = self.convert_expr(ctx.used(), lhs, None)?;
                let r = self.convert_expr(ctx.used(), rhs, None)?;
                // A `bool`, as `convert_binary_expr` answers any comparison;
                // its callers lower it to C's `int` where one is needed.
                let _ = ty;
                Ok(Some(l.zip(r).map(|(l, r)| op2(das_op, l, r))))
            }
            _ => Ok(None),
        }
    }

    /// Binds a value to a fresh `let` (always: the store and the C value of
    /// the assignment both read it).
    fn force_temp(&self, value: WithStmts<DaExpr>, ty: DaType) -> WithStmts<DaExpr> {
        if matches!(value.val, DaExpr::Var(_) | DaExpr::ConstInt(_)) {
            return value;
        }
        let name = self.fresh_name();
        let (mut stmts, val) = value.into_stmts_and_val();
        stmts.push(DaStmt::Let {
            name: name.clone(),
            var_type: Some(ty),
            init: Some(val),
        });
        WithStmts::new(stmts, DaExpr::Var(name))
    }

    /// The stores of `value` at `address`; the expression is the stored value.
    fn emit_store(
        &self,
        s: Scalar,
        address: WithStmts<DaExpr>,
        value: WithStmts<DaExpr>,
    ) -> WithStmts<DaExpr> {
        let (mut stmts, a) = address.into_stmts_and_val();
        let (vstmts, v) = value.into_stmts_and_val();
        stmts.extend(vstmts);
        let mut fresh = || self.fresh_name();
        stmts.extend(store(s, &a, &v, &mut fresh));
        WithStmts::new(stmts, v)
    }

    pub(crate) fn linear_incdec(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        _ty: CQualTypeId,
        op: CUnOp,
        arg: CExprId,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let arg_ty = self.qual_of(arg)?;
        let is_ptr = self.is_data_pointer(arg_ty.ctype);
        let inc = matches!(op, CUnOp::PreIncrement | CUnOp::PostIncrement);
        let pre = matches!(op, CUnOp::PreIncrement | CUnOp::PreDecrement);
        let das_op: &'static str = if inc { "+" } else { "-" };
        let heap = self.heap_place(ctx, arg)?;
        if heap.is_none() && !is_ptr {
            return Ok(None);
        }
        let s = self.scalar_or_refuse(arg, arg_ty.ctype)?;
        let ty = s.da_type();
        let step = |old: DaExpr| -> TranslationResult<DaExpr> {
            Ok(match s {
                Scalar::Ptr => {
                    let size = self.step_size(self.linear_pointee(arg_ty.ctype).unwrap())?;
                    op2(das_op, old, DaExpr::ConstInt(size))
                }
                Scalar::I8 | Scalar::U8 | Scalar::I16 | Scalar::U16 => cast(
                    ty.clone(),
                    op2(das_op, cast(DaType::int(), old), DaExpr::ConstInt(1)),
                ),
                Scalar::I32 => op2(das_op, old, DaExpr::ConstInt(1)),
                Scalar::Bool => return Err(self.linear_refuse(expr_id, "`++`/`--` on a `_Bool`")),
                _ => op2(das_op, old, cast(ty.clone(), DaExpr::ConstInt(1))),
            })
        };
        match heap {
            Some(address) => {
                let address = self.stable(address, DaType::int());
                let (stmts, a) = address.into_stmts_and_val();
                let old = self.force_temp(WithStmts::new(stmts, load(s, &a)), ty.clone());
                let (stmts, old) = old.into_stmts_and_val();
                let new = self.force_temp(WithStmts::new(stmts, step(old.clone())?), ty.clone());
                let stored = self.emit_store(s, WithStmts::new_val(a), new);
                Ok(Some(if pre { stored } else { stored.map(|_| old) }))
            }
            None => {
                // A pointer variable: integer arithmetic on its offset.
                let place = self.convert_expr(ctx.used(), arg, None)?;
                let (mut stmts, p) = place.into_stmts_and_val();
                // A variable or a field path of a daslang record value
                // (`++iter.state` on a by-value parameter): side-effect free,
                // so it may be read and written again.
                fn plain_place(e: &DaExpr) -> bool {
                    match e {
                        DaExpr::Var(_) => true,
                        DaExpr::Field(base, _) => plain_place(base),
                        _ => false,
                    }
                }
                if !plain_place(&p) {
                    return Err(self.linear_refuse(expr_id, "`++`/`--` on this pointer lvalue"));
                }
                if pre {
                    stmts.push(DaStmt::Expr(DaExpr::Assign(Box::new(p.clone()), Box::new(step(p.clone())?))));
                    return Ok(Some(WithStmts::new(stmts, p)));
                }
                let old = self.fresh_name();
                stmts.push(DaStmt::Let {
                    name: old.clone(),
                    var_type: Some(DaType::int()),
                    init: Some(p.clone()),
                });
                stmts.push(DaStmt::Expr(DaExpr::Assign(Box::new(p.clone()), Box::new(step(p)?))));
                Ok(Some(WithStmts::new(stmts, DaExpr::Var(old))))
            }
        }
    }

    fn callee_name(&self, func: CExprId) -> Option<(String, bool)> {
        let mut e = func;
        loop {
            match &self.ast_context[e].kind {
                CExprKind::Paren(_, i) | CExprKind::ImplicitCast(_, i, _, _, _) => e = *i,
                CExprKind::DeclRef(_, decl, _) => {
                    return match &self.ast_context[*decl].kind {
                        CDeclKind::Function { name, body, .. } => Some((name.clone(), body.is_some())),
                        _ => None,
                    };
                }
                _ => return None,
            }
        }
    }

    fn is_string_literal_arg(&self, arg: CExprId) -> bool {
        matches!(
            self.decayed_array(arg).map(|a| &self.ast_context[a].kind),
            Some(CExprKind::Literal(_, CLiteral::String(..)))
        )
    }

    /// The printf family over C memory: the format and every `%s`/`%p`
    /// argument are heap offsets, the output is built by `c2da_lin_vfmt` and
    /// leaves through `c2da_std_write` (a stream) or is placed in the heap
    /// with C's `snprintf` truncation rule (a buffer).
    ///
    /// Argument roles: `H` a stream (`uint64` handle), `D` a destination
    /// offset, `N` a size, `F` the format.  `printf` is `fprintf` on handle
    /// 1 (stdout) and `sprintf` is `snprintf` without a limit.
    fn linear_format_call(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        base: &str,
        args: &[CExprId],
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let (runtime, roles, va_list) = match base {
            "printf" => ("c2da_lin_printf", "F", false),
            "fprintf" => ("c2da_lin_printf", "HF", false),
            "sprintf" => ("c2da_lin_snprintf", "DF", false),
            "snprintf" => ("c2da_lin_snprintf", "DNF", false),
            "vprintf" => ("c2da_lin_vprintf", "F", true),
            "vfprintf" => ("c2da_lin_vprintf", "HF", true),
            "vsprintf" => ("c2da_lin_vsnprintf", "DF", true),
            "vsnprintf" => ("c2da_lin_vsnprintf", "DNF", true),
            _ => return Ok(None),
        };
        let fixed = roles.len();
        if args.len() < fixed || (va_list && args.len() != fixed + 1) {
            return Err(self.linear_refuse(expr_id, &format!("`{base}` with {} arguments", args.len())));
        }
        let format_arg = args[fixed - 1];
        if let Some(lit) = self.decayed_array(format_arg) {
            if let CExprKind::Literal(_, CLiteral::String(bytes, 1)) = &self.ast_context[lit].kind {
                if let Some(conv) = unsupported_linear_conversion(bytes) {
                    return Err(self.linear_refuse(
                        format_arg,
                        &format!("printf conversion `{conv}` over C memory"),
                    ));
                }
            }
        }
        let mut out = WithStmts::new_val(Vec::new());
        if roles == "F" {
            out.val.push(cast(DaType::uint64(), DaExpr::ConstInt(1)));
        }
        for (arg, role) in args.iter().zip(roles.chars()) {
            let v = self.convert_expr(ctx.used(), *arg, None)?;
            let t = if role == 'H' || role == 'N' { DaType::uint64() } else { DaType::int() };
            out = out.zip(v).map(|(mut list, v)| {
                list.push(if Self::infer_type(&v).as_ref() == Some(&t) { v } else { cast(t, v) });
                list
            });
        }
        if roles == "DF" {
            out.val.insert(1, cast(DaType::uint64(), DaExpr::ConstInt(0x7fff_ffff)));
        }
        if va_list {
            let cursor = self.va_list_call_argument(args[fixed])?;
            let forwarded = self.forwarded_va_args(expr_id)?;
            out = out.map(|mut list| {
                list.push(cursor);
                list.push(forwarded);
                list
            });
        } else {
            let mut tail = Vec::new();
            for arg in &args[fixed..] {
                let v = self.convert_expr(ctx.used(), *arg, None)?;
                let ty = self.ast_context[*arg].kind.get_qual_type();
                out.stmts.extend(v.stmts);
                out.is_unsafe |= v.is_unsafe;
                tail.push(self.pack_variadic_argument(*arg, v.val, ty)?);
            }
            out = out.map(|mut list| {
                list.push(DaExpr::MakeArray(tail));
                list
            });
        }
        libc::require_write();
        FORMAT_USED.with(|u| u.set(true));
        Ok(Some(out.map(|list| DaExpr::Call(Box::new(DaExpr::Var(runtime.into())), list))))
    }

    /// `<stdio.h>` files under `--libc eden`: a `FILE *` is its handle as an
    /// `int`.  `fopen` reads the path and mode from the heap, `fread` copies
    /// the registered file's bytes into the heap (`c2da_lin_fopen`,
    /// `c2da_lin_fread`); `fclose`/`fflush`/`fseek`/`ftell`/`feof` take no
    /// other pointer and are the `--libc eden` helpers on the handle.
    fn linear_stdio_call(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        base: &str,
        args: &[CExprId],
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let (runtime, types): (&str, &str) = match base {
            "fopen" => ("c2da_lin_fopen", "II"),
            "fread" => ("c2da_lin_fread", "IUUH"),
            "fwrite" => ("c2da_lin_fwrite", "IUUH"),
            "fclose" | "fflush" | "fseek" | "ftell" | "feof" => match libc::std_function(base) {
                Some(function) => (self.require_std_function(function, expr_id)?, "H**"),
                None => return Ok(None),
            },
            "fputc" | "putc" => ("c2da_lin_fputc", "IH"),
            // The buffer is only tested against NULL: `--libc eden` streams
            // are line buffers whatever the program supplies.
            "setvbuf" => match libc::std_function(base) {
                Some(function) => (self.require_std_function(function, expr_id)?, "HU*U"),
                None => return Ok(None),
            },
            _ => return Ok(None),
        };
        let fixed = types.trim_end_matches('*').len();
        if args.len() < fixed || args.len() > types.len() {
            return Err(self.linear_refuse(expr_id, &format!("`{base}` with {} arguments", args.len())));
        }
        if runtime.starts_with("c2da_lin_") {
            libc::require_eden_files();
            libc::require_write();
            FILE_USED.with(|u| u.set(true));
        }
        let mut out = WithStmts::new_val(Vec::new());
        for (arg, t) in args.iter().zip(types.chars()) {
            let v = self.convert_expr(ctx.used(), *arg, None)?;
            let t = match t {
                'I' => Some(DaType::int()),
                'U' | 'H' => Some(DaType::uint64()),
                _ => None,
            };
            out = out.zip(v).map(|(mut list, v)| {
                list.push(match t {
                    Some(t) if Self::infer_type(&v).as_ref() != Some(&t) => cast(t, v),
                    _ => v,
                });
                list
            });
        }
        Ok(Some(out.map(|list| DaExpr::Call(Box::new(DaExpr::Var(runtime.into())), list))))
    }

    fn linear_call(
        &self,
        ctx: ExprContext,
        expr_id: CExprId,
        func: CExprId,
        args: &[CExprId],
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        let Some((name, has_body)) = self.callee_name(func) else {
            return Ok(None);
        };
        // va_start/va_end/va_copy act on the variadic cursor, not on memory.
        if has_body || self.match_vapart(func, args).is_some() {
            return Ok(None);
        }
        // A function another unit of a source-layout program defines is
        // translated C like this unit's own, not a library function.
        if self.link.as_ref().map_or(false, |link| link.owners.contains_key(&name)) {
            return Ok(None);
        }
        let base = name.strip_prefix("__builtin_").unwrap_or(&name);
        if let Some(lowered) = self.linear_format_call(ctx, expr_id, base, args)? {
            return Ok(Some(lowered));
        }
        if self.tcfg.libc == crate::LibcMode::Eden {
            if let Some(lowered) = self.linear_stdio_call(ctx, expr_id, base, args)? {
                return Ok(Some(lowered));
            }
        }
        // `errno` is the heap cell the helpers write (`libc.rs`).
        if base == "__errno_location" && args.is_empty() {
            return Ok(Some(WithStmts::new_val(DaExpr::ConstInt(libc::LINEAR_ERRNO_AT as i64))));
        }
        // `sscanf` with a literal format of up to four `%d %u %x %X %o`
        // conversions (no width, no length modifier) into `int`s.
        if base == "sscanf" {
            let bytes = self
                .decayed_array(args.get(1).copied().unwrap_or(expr_id))
                .and_then(|lit| match &self.ast_context[lit].kind {
                    CExprKind::Literal(_, CLiteral::String(bytes, 1)) => Some(bytes.clone()),
                    _ => None,
                })
                .ok_or_else(|| self.linear_refuse(expr_id, "`sscanf` without a string literal format"))?;
            let mut convs = 0;
            let mut k = 0;
            while k < bytes.len() {
                if bytes[k] == b'%' {
                    match bytes.get(k + 1) {
                        Some(b'd' | b'i' | b'u' | b'x' | b'X' | b'o') => convs += 1,
                        other => {
                            return Err(self.linear_refuse(
                                expr_id,
                                &format!(
                                    "sscanf conversion `%{}` over C memory",
                                    other.map_or(String::new(), |c| (*c as char).to_string())
                                ),
                            ))
                        }
                    }
                    k += 1;
                }
                k += 1;
            }
            if convs + 2 != args.len() || convs > 4 {
                return Err(self.linear_refuse(expr_id, "`sscanf` with more than four conversions or a mismatched argument count"));
            }
            let mut out = WithStmts::new_val(Vec::new());
            for arg in args {
                let v = self.convert_expr(ctx.used(), *arg, None)?;
                out = out.zip(v).map(|(mut list, v)| {
                    list.push(if Self::infer_type(&v) == Some(DaType::int()) { v } else { cast(DaType::int(), v) });
                    list
                });
            }
            return Ok(Some(out.map(|mut list| {
                while list.len() < 6 {
                    list.push(DaExpr::ConstInt(0));
                }
                DaExpr::Call(Box::new(DaExpr::Var("c2da_lin_sscanf".into())), list)
            })));
        }
        // (runtime function, argument types: `I` int, `U` uint64)
        let sig: Option<(&str, &str)> = match base {
            "malloc" => Some(("c2da_lin_malloc", "U")),
            "calloc" => Some(("c2da_lin_calloc", "UU")),
            "realloc" => Some(("c2da_lin_realloc", "IU")),
            "free" => Some(("c2da_lin_free", "I")),
            "memcpy" => Some(("c2da_lin_memcpy", "IIU")),
            "memmove" => Some(("c2da_lin_memmove", "IIU")),
            "memset" => Some(("c2da_lin_memset", "IIU")),
            "memcmp" => Some(("c2da_lin_memcmp", "IIU")),
            "strlen" => Some(("c2da_lin_strlen", "I")),
            "strchr" => Some(("c2da_lin_strchr", "II")),
            "strrchr" => Some(("c2da_lin_strrchr", "II")),
            "strcmp" => Some(("c2da_lin_strcmp", "II")),
            "strncmp" => Some(("c2da_lin_strncmp", "IIU")),
            "strcpy" => Some(("c2da_lin_strcpy", "II")),
            "strncpy" => Some(("c2da_lin_strncpy", "IIU")),
            "strcat" => Some(("c2da_lin_strcat", "II")),
            "strstr" => Some(("c2da_lin_strstr", "II")),
            "memchr" => Some(("c2da_lin_memchr", "IIU")),
            "strcasecmp" => Some(("c2da_lin_strcasecmp", "II")),
            "strncasecmp" => Some(("c2da_lin_strncasecmp", "IIU")),
            "strdup" => Some(("c2da_lin_strdup", "I")),
            "atoi" => Some(("c2da_lin_atoi", "I")),
            "atof" => Some(("c2da_lin_atof", "I")),
            // `--libc eden` has no command processor and writes no files:
            // `system(NULL)` answers 0 and every request fails with -1.
            "system" if self.tcfg.libc == crate::LibcMode::Eden => Some(("c2da_lin_system", "I")),
            "remove" if self.tcfg.libc == crate::LibcMode::Eden => Some(("c2da_lin_remove", "I")),
            "mkdir" if self.tcfg.libc == crate::LibcMode::Eden && args.len() == 2 => Some(("c2da_lin_mkdir", "IU")),
            "rename" if self.tcfg.libc == crate::LibcMode::Eden => Some(("c2da_lin_rename", "II")),
            _ => None,
        };
        if let Some((runtime, types)) = sig {
            if args.len() != types.len() {
                return Err(self.linear_refuse(expr_id, &format!("`{name}` with {} arguments", args.len())));
            }
            let mut out = WithStmts::new_val(Vec::new());
            for (arg, t) in args.iter().zip(types.chars()) {
                let v = self.convert_expr(ctx.used(), *arg, None)?;
                let t = if t == 'I' { DaType::int() } else { DaType::uint64() };
                out = out.zip(v).map(|(mut list, v)| {
                    list.push(if Self::infer_type(&v).as_ref() == Some(&t) { v } else { cast(t, v) });
                    list
                });
            }
            return Ok(Some(out.map(|list| {
                DaExpr::Call(Box::new(DaExpr::Var(runtime.into())), list)
            })));
        }
        // Any other library function that takes or returns C memory would
        // read it through the raw-pointer prelude.  A string literal passed
        // as a format or a text stays the libc lowering's own business.
        let ret_ptr = self
            .qual_of(expr_id)
            .map(|t| self.is_data_pointer(t.ctype))
            .unwrap_or(false);
        let ptr_arg = args.iter().any(|a| {
            self.qual_of(*a)
                .map(|t| {
                    self.is_data_pointer(t.ctype) || (fn_table() && self.is_fn_pointer(t.ctype))
                })
                .unwrap_or(false)
                && !self.is_string_literal_arg(*a)
        });
        if ret_ptr || ptr_arg {
            return Err(self.linear_refuse(
                expr_id,
                &format!("library function `{name}` over C memory"),
            ));
        }
        Ok(None)
    }
}

/// Drops the raw-memory runtime prelude (`c2da_rt_*`, which every module
/// carries) unless a declaration of the module still names it; a helper that
/// stays is then refused by `target_check.rs check_linear` if it is raw.
pub fn prune_raw_runtime(decls: &mut Vec<DaDecl>) {
    fn name(decl: &DaDecl) -> Option<&str> {
        match decl {
            DaDecl::Function(f) => Some(&f.name),
            DaDecl::Variable(v) => Some(&v.name),
            DaDecl::Private(inner) => name(inner),
            _ => None,
        }
    }
    let is_raw = |d: &DaDecl| name(d).map_or(false, |n| n.starts_with("c2da_rt_"));
    let mut keep: Vec<bool> = decls.iter().map(|d| !is_raw(d)).collect();
    let mut text: String = decls
        .iter()
        .zip(&keep)
        .filter(|(_, k)| **k)
        .map(|(d, _)| d.to_string())
        .collect();
    loop {
        let mut changed = false;
        for (i, decl) in decls.iter().enumerate() {
            if keep[i] {
                continue;
            }
            let n = name(decl).unwrap();
            let used = text.match_indices(n).any(|(at, _)| {
                !text[at + n.len()..]
                    .chars()
                    .next()
                    .map_or(false, |c| c.is_alphanumeric() || c == '_')
            });
            if used {
                keep[i] = true;
                text.push_str(&decl.to_string());
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }
    let mut i = 0;
    decls.retain(|_| {
        i += 1;
        keep[i - 1]
    });
}

/// The `c2da_lin_*` runtime and the static block, appended to a linear
/// module's text.  `reserve` is the heap capacity in bytes: the heap is
/// reserved at that size before any `resize`, so daslang's
/// `max_unreserved_size` panic cannot trigger, and an allocation past it
/// answers C NULL.
pub fn runtime_source(reserve: u64) -> String {
    let bytes = STATIC.with(|s| s.borrow().0.clone());
    let mut init = String::new();
    let n = bytes.len();
    if n > RESERVED {
        let list: Vec<String> = bytes[RESERVED..].iter().map(|b| format!("0x{b:x}")).collect();
        init.push_str(&format!(
            "let private c2da_lin_static = fixed_array<uint8>({})\n",
            list.join(", ")
        ));
    }
    let copy = if n > RESERVED {
        format!(
            "    for (i in range({})) {{\n        c2da_mem[{RESERVED} + i] = c2da_lin_static[i]\n    }}\n",
            n - RESERVED
        )
    } else {
        String::new()
    };
    // The C stack: a fixed region above the static block, growing down
    // from its top; `c2da_lin_enter` pushes a frame, the function wrapper
    // pops it.
    let stack_base = (n + 15) & !15;
    let stack_top = stack_base + STACK_BYTES;
    let brk = stack_top;
    let format_section = if FORMAT_USED.with(|u| u.get()) { FORMAT_RUNTIME } else { "" };
    let file_section = if FILE_USED.with(|u| u.get()) { FILE_RUNTIME } else { "" };
    let argv_section = if ARGV_USED.with(|u| u.get()) { ARGV_RUNTIME } else { "" };
    let fn_section = function_tables_source();
    format!(
        r#"
// --memory-model linear runtime: C memory is c2da_mem, an address is an int offset.
var c2da_mem : array<uint8>
var private c2da_lin_brk : int = 0
var private c2da_lin_free_list : int = 0
var c2da_lin_sp : int = {stack_top}
let private c2da_lin_limit : int64 = {reserve}l
{init}
[init]
def private c2da_lin_init() {{
    reserve(c2da_mem, c2da_lin_limit)
    resize(c2da_mem, {brk})
{copy}    c2da_lin_brk = {brk}
}}
{body}{format_section}{file_section}{argv_section}{fn_section}"#,
        body = heap_runtime_body(stack_base)
    )
}

/// The program-wide program state of `--memory-model linear` under
/// `--module-layout source`, handed from one unit to the next in link order
/// (`UnitLink::linear`, `UnitOutput::linear`): the end of the static blocks
/// placed so far (the next unit's block starts at the following 16-byte
/// boundary), the function-pointer signatures numbered so far (one table each,
/// program-wide), the functions numbered so far, and which optional runtime
/// sections some unit needs.
#[derive(Clone, Debug, Default)]
pub struct LinearLink {
    pub static_end: usize,
    pub sigs: Vec<DaType>,
    pub fn_count: usize,
    pub format: bool,
    pub file: bool,
    pub argv: bool,
}

thread_local! {
    /// The state the unit being translated started from (source layout).
    static IN_LINK: RefCell<Option<LinearLink>> = RefCell::new(None);
}

/// Starts a unit of a source-layout program at the program-wide state
/// `link`: its static block begins past every earlier unit's, and its
/// function-pointer signatures and indices continue theirs.
pub fn start_linked_unit(link: &LinearLink) {
    let base = (link.static_end.max(RESERVED) + 15) & !15;
    STATIC.with(|s| *s.borrow_mut() = (vec![0; base], StdHashMap::new()));
    SIGS.with(|s| *s.borrow_mut() = link.sigs.clone());
    IN_LINK.with(|l| *l.borrow_mut() = Some(link.clone()));
}

fn linked_base() -> usize {
    IN_LINK.with(|l| {
        l.borrow()
            .as_ref()
            .map_or(RESERVED, |link| (link.static_end.max(RESERVED) + 15) & !15)
    })
}

fn linked_fn_base() -> usize {
    IN_LINK.with(|l| l.borrow().as_ref().map_or(0, |link| link.fn_count))
}

/// The program-wide state after this unit (source layout).
pub fn linked_state() -> LinearLink {
    let input = IN_LINK.with(|l| l.borrow().clone()).unwrap_or_default();
    LinearLink {
        static_end: STATIC.with(|s| s.borrow().0.len()),
        sigs: SIGS.with(|s| s.borrow().clone()),
        fn_count: input.fn_count + FUNCS.with(|f| f.borrow().len()),
        format: input.format || FORMAT_USED.with(|u| u.get()),
        file: input.file || FILE_USED.with(|u| u.get()),
        argv: input.argv || ARGV_USED.with(|u| u.get()),
    }
}

/// A unit's own part of the linear runtime under the source layout: its
/// static block, copied into the shared heap at the unit's program-wide
/// offset by its `[init]`, and the filling of its slots in the shared
/// function tables (`c2da_relink_<module>`, which a host calls again after a
/// hot reload).  `c2da_lin_setup` sizes the heap first; daslang runs
/// `[init]` functions entry module first, so the unit cannot rely on the
/// shared module's own `[init]` having run.
pub fn unit_runtime_source(module: &str) -> String {
    let bytes = STATIC.with(|s| s.borrow().0.clone());
    let base = linked_base();
    // Every name carries the unit's stem: two fragments of one cluster share
    // a module.
    let stem: String = module
        .chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '_' })
        .collect();
    let mut text = String::new();
    if bytes.len() > base {
        let list: Vec<String> = bytes[base..].iter().map(|b| format!("0x{b:x}")).collect();
        text.push_str(&format!(
            "\n// This unit's static data, at heap offset {base}.\nlet private c2da_lin_static_{stem} = fixed_array<uint8>({})\n\n\
             [init]\ndef private c2da_lin_init_static_{stem}() {{\n    c2da_lin_setup()\n    \
             for (i in range({})) {{\n        c2da_mem[{base} + i] = c2da_lin_static_{stem}[i]\n    }}\n}}\n",
            list.join(", "),
            bytes.len() - base
        ));
    }
    let funcs = FUNCS.with(|f| f.borrow().clone());
    if !funcs.is_empty() {
        let sigs = SIGS.with(|s| s.borrow().clone());
        let fn_base = linked_fn_base();
        let count = fn_base + funcs.len() + 1;
        text.push_str(&format!(
            "\n// Fills this module's slots of the shared function tables (at start, and after a hot reload).\ndef c2da_relink_{stem}() {{\n"
        ));
        for (n, t) in sigs.iter().enumerate() {
            if !funcs.iter().any(|(_, sig)| sig == t) {
                continue;
            }
            text.push_str(&format!(
                "    if (length(c2da_fn_table{n}) < {count}) {{\n        resize(c2da_fn_table{n}, {count})\n    }}\n"
            ));
            for (k, (name, sig)) in funcs.iter().enumerate() {
                if sig == t {
                    text.push_str(&format!(
                        "    c2da_fn_table{n}[{}] = @@{name}\n",
                        fn_base + k + 1
                    ));
                }
            }
        }
        text.push_str(&format!(
            "}}\n\n[init]\ndef private c2da_lin_relink_init_{stem}() {{\n    c2da_relink_{stem}()\n}}\n"
        ));
    }
    text
}

/// The shared module's part of the linear runtime under the source layout:
/// the heap, the allocator, the C stack (above every unit's static block),
/// the byte functions, the optional sections some unit needs and the
/// program-wide function tables, all public so every unit module reaches
/// them through its `require`.
pub fn shared_runtime_source(reserve: u64, link: &LinearLink) -> String {
    let stack_base = (link.static_end.max(RESERVED) + 15) & !15;
    let stack_top = stack_base + STACK_BYTES;
    let brk = stack_top;
    let format_section = if link.format { FORMAT_RUNTIME } else { "" };
    let file_section = if link.file { FILE_RUNTIME } else { "" };
    let argv_section = if link.argv { ARGV_RUNTIME } else { "" };
    let mut tables = String::new();
    if !link.sigs.is_empty() {
        tables.push_str("\n// Function pointers in the heap are indices into these tables (0 is NULL).\n");
        for (n, t) in link.sigs.iter().enumerate() {
            tables.push_str(&function_table_decl(n, t));
        }
    }
    format!(
        r#"
// --memory-model linear runtime: C memory is c2da_mem, an address is an int offset.
var c2da_mem : array<uint8>
var private c2da_lin_brk : int = 0
var private c2da_lin_free_list : int = 0
var c2da_lin_sp : int = {stack_top}
let private c2da_lin_limit : int64 = {reserve}l
var private c2da_lin_ready : bool = false

// Reserves and sizes the heap once; every module's [init] calls it before
// copying its static block in.
def c2da_lin_setup() {{
    if (c2da_lin_ready) {{
        return
    }}
    c2da_lin_ready = true
    reserve(c2da_mem, c2da_lin_limit)
    resize(c2da_mem, {brk})
    c2da_lin_brk = {brk}
}}

[init]
def private c2da_lin_init() {{
    c2da_lin_setup()
}}
{body}{format_section}{file_section}{argv_section}{tables}"#,
        body = heap_runtime_body(stack_base)
    )
}

/// The C stack push, the allocator and the byte functions over `c2da_mem`.
fn heap_runtime_body(stack_base: usize) -> String {
    format!(
        r#"
// Pushes a C stack frame of `size` bytes and answers its address.
def c2da_lin_enter(size : int) : int {{
    let fp = c2da_lin_sp - size
    if (fp < {stack_base}) {{
        panic("c2da: C stack overflow")
    }}
    c2da_lin_sp = fp
    return fp
}}

def private c2da_lin_ld32(a : int) : int {{
    return int(uint(c2da_mem[a]) | (uint(c2da_mem[a + 1]) << 0x8) | (uint(c2da_mem[a + 2]) << 0x10) | (uint(c2da_mem[a + 3]) << 0x18))
}}

def private c2da_lin_st32(a : int; v : int) {{
    let u = uint(v)
    c2da_mem[a] = uint8(u)
    c2da_mem[a + 1] = uint8(u >> 0x8)
    c2da_mem[a + 2] = uint8(u >> 0x10)
    c2da_mem[a + 3] = uint8(u >> 0x18)
}}

// A block is a 16-byte header (capacity at -16) and a 16-byte aligned payload.
// A freed block's next link is its first 4 payload bytes; reuse is first fit.
def c2da_lin_malloc(n : uint64) : int {{
    if (n > uint64(0x7ffffff0)) {{
        return 0
    }}
    var cap = (int(n) + 15) & ~15
    if (cap == 0) {{
        cap = 16
    }}
    var prev = 0
    var cur = c2da_lin_free_list
    while (cur != 0) {{
        let next = c2da_lin_ld32(cur)
        if (c2da_lin_ld32(cur - 16) >= cap) {{
            if (prev == 0) {{
                c2da_lin_free_list = next
            }} else {{
                c2da_lin_st32(prev, next)
            }}
            return cur
        }}
        prev = cur
        cur = next
    }}
    let at = c2da_lin_brk
    let end = int64(at) + 16l + int64(cap)
    if (end > c2da_lin_limit) {{
        return 0
    }}
    resize(c2da_mem, int(end))
    c2da_lin_brk = int(end)
    c2da_lin_st32(at, cap)
    return at + 16
}}

def c2da_lin_free(p : int) {{
    if (p == 0) {{
        return
    }}
    c2da_lin_st32(p, c2da_lin_free_list)
    c2da_lin_free_list = p
}}

def c2da_lin_memset(d : int; c : int; n : uint64) : int {{
    let b = uint8(c)
    for (i in range(int(n))) {{
        c2da_mem[d + i] = b
    }}
    return d
}}

def c2da_lin_calloc(count : uint64; size : uint64) : int {{
    if (size != 0ul && count > uint64(0x7ffffff0) / size) {{
        return 0
    }}
    let n = count * size
    let p = c2da_lin_malloc(n)
    if (p != 0) {{
        c2da_lin_memset(p, 0, n)
    }}
    return p
}}

def c2da_lin_memcpy(d : int; s : int; n : uint64) : int {{
    for (i in range(int(n))) {{
        c2da_mem[d + i] = c2da_mem[s + i]
    }}
    return d
}}

def c2da_lin_memmove(d : int; s : int; n : uint64) : int {{
    let len = int(n)
    if (d <= s) {{
        for (i in range(len)) {{
            c2da_mem[d + i] = c2da_mem[s + i]
        }}
    }} else {{
        var i = len - 1
        while (i >= 0) {{
            c2da_mem[d + i] = c2da_mem[s + i]
            i--
        }}
    }}
    return d
}}

def c2da_lin_realloc(p : int; n : uint64) : int {{
    if (p == 0) {{
        return c2da_lin_malloc(n)
    }}
    if (n == 0ul) {{
        c2da_lin_free(p)
        return 0
    }}
    let cap = c2da_lin_ld32(p - 16)
    if (n <= uint64(cap)) {{
        return p
    }}
    let q = c2da_lin_malloc(n)
    if (q == 0) {{
        return 0
    }}
    c2da_lin_memcpy(q, p, uint64(cap))
    c2da_lin_free(p)
    return q
}}

def c2da_lin_memcmp(a : int; b : int; n : uint64) : int {{
    for (i in range(int(n))) {{
        let x = int(c2da_mem[a + i])
        let y = int(c2da_mem[b + i])
        if (x != y) {{
            return x - y
        }}
    }}
    return 0
}}

def c2da_lin_strlen(s : int) : uint64 {{
    var i = s
    while (c2da_mem[i] != uint8(0)) {{
        i++
    }}
    return uint64(i - s)
}}

def c2da_lin_memchr(s : int; c : int; n : uint64) : int {{
    let b = uint8(c & 0xff)
    for (i in range(int(n))) {{
        if (c2da_mem[s + i] == b) {{
            return s + i
        }}
    }}
    return 0
}}

// The C string functions over the heap; a character compares as unsigned char.
def c2da_lin_strchr(s : int; c : int) : int {{
    let b = uint8(c & 0xff)
    var i = s
    while (c2da_mem[i] != b) {{
        if (c2da_mem[i] == uint8(0)) {{
            return 0
        }}
        i++
    }}
    return i
}}

def c2da_lin_strrchr(s : int; c : int) : int {{
    let b = uint8(c & 0xff)
    var found = 0
    var i = s
    while (c2da_mem[i] != uint8(0)) {{
        if (c2da_mem[i] == b) {{
            found = i
        }}
        i++
    }}
    if (b == uint8(0)) {{
        return i
    }}
    return found
}}

def c2da_lin_strncmp(a : int; b : int; n : uint64) : int {{
    for (i in range(int(n))) {{
        let x = int(c2da_mem[a + i])
        let y = int(c2da_mem[b + i])
        if (x != y || x == 0) {{
            return x - y
        }}
    }}
    return 0
}}

def c2da_lin_strcmp(a : int; b : int) : int {{
    var i = 0
    var x = int(c2da_mem[a])
    var y = int(c2da_mem[b])
    while (x == y && x != 0) {{
        i++
        x = int(c2da_mem[a + i])
        y = int(c2da_mem[b + i])
    }}
    return x - y
}}

def c2da_lin_strcpy(d : int; s : int) : int {{
    var i = 0
    while (c2da_mem[s + i] != uint8(0)) {{
        c2da_mem[d + i] = c2da_mem[s + i]
        i++
    }}
    c2da_mem[d + i] = uint8(0)
    return d
}}

def c2da_lin_strncpy(d : int; s : int; n : uint64) : int {{
    let len = int(n)
    var i = 0
    while (i < len && c2da_mem[s + i] != uint8(0)) {{
        c2da_mem[d + i] = c2da_mem[s + i]
        i++
    }}
    while (i < len) {{
        c2da_mem[d + i] = uint8(0)
        i++
    }}
    return d
}}

def c2da_lin_strcat(d : int; s : int) : int {{
    c2da_lin_strcpy(d + int(c2da_lin_strlen(d)), s)
    return d
}}

def c2da_lin_lower(c : int) : int {{
    return c >= 65 && c <= 90 ? c + 32 : c
}}

def c2da_lin_strncasecmp(a : int; b : int; n : uint64) : int {{
    for (i in range(int(n))) {{
        let x = c2da_lin_lower(int(c2da_mem[a + i]))
        let y = c2da_lin_lower(int(c2da_mem[b + i]))
        if (x != y || x == 0) {{
            return x - y
        }}
    }}
    return 0
}}

def c2da_lin_strcasecmp(a : int; b : int) : int {{
    var i = 0
    while (true) {{
        let x = c2da_lin_lower(int(c2da_mem[a + i]))
        let y = c2da_lin_lower(int(c2da_mem[b + i]))
        if (x != y || x == 0) {{
            return x - y
        }}
        i++
    }}
    return 0
}}

def c2da_lin_strdup(s : int) : int {{
    let n = c2da_lin_strlen(s) + 1ul
    let d = c2da_lin_malloc(n)
    if (d != 0) {{
        c2da_lin_memcpy(d, s, n)
    }}
    return d
}}

def c2da_lin_isspace(c : int) : bool {{
    return c == 32 || (c >= 9 && c <= 13)
}}

// --libc eden: no command processor, no file writes.
def c2da_lin_system(cmd : int) : int {{
    return cmd == 0 ? 0 : -1
}}

def c2da_lin_remove(path : int) : int {{
    return -1
}}

def c2da_lin_rename(from : int; to : int) : int {{
    return -1
}}

def c2da_lin_mkdir(path : int; mode : uint64) : int {{
    return -1
}}

def c2da_lin_digit(c : int; base : int) : int {{
    var d = 99
    if (c >= 48 && c <= 57) {{
        d = c - 48
    }} elif (c >= 97 && c <= 102) {{
        d = c - 87
    }} elif (c >= 65 && c <= 70) {{
        d = c - 55
    }}
    return d < base ? d : -1
}}

// sscanf with `%d %u %x %X %o` into ints (the translator checks the format):
// blanks in the format skip blanks, other characters must match, and the
// result is the number of conversions stored (-1 when the input is empty
// before the first one).
def c2da_lin_sscanf(s : int; f : int; p0 : int; p1 : int; p2 : int; p3 : int) : int {{
    var i = s
    var k = f
    var n = 0
    while (int(c2da_mem[k]) != 0) {{
        let c = int(c2da_mem[k])
        if (c2da_lin_isspace(c)) {{
            while (c2da_lin_isspace(int(c2da_mem[i]))) {{
                i++
            }}
            k++
        }} elif (c != 37) {{
            if (int(c2da_mem[i]) != c) {{
                return n == 0 && int(c2da_mem[i]) == 0 ? -1 : n
            }}
            i++
            k++
        }} else {{
            let conv = int(c2da_mem[k + 1])
            k += 2
            while (c2da_lin_isspace(int(c2da_mem[i]))) {{
                i++
            }}
            if (n == 0 && int(c2da_mem[i]) == 0) {{
                return -1
            }}
            var neg = false
            if (int(c2da_mem[i]) == 45 || int(c2da_mem[i]) == 43) {{
                neg = int(c2da_mem[i]) == 45
                i++
            }}
            var base = conv == 120 || conv == 88 ? 16 : (conv == 111 ? 8 : 10)
            if (conv == 105 && int(c2da_mem[i]) == 48) {{
                // %i: a leading 0x is hexadecimal, a leading 0 octal.
                let x = int(c2da_mem[i + 1])
                if ((x == 120 || x == 88) && c2da_lin_digit(int(c2da_mem[i + 2]), 16) >= 0) {{
                    base = 16
                    i += 2
                }} else {{
                    base = 8
                }}
            }}
            var v = 0
            var digits = 0
            while (c2da_lin_digit(int(c2da_mem[i]), base) >= 0) {{
                v = v * base + c2da_lin_digit(int(c2da_mem[i]), base)
                i++
                digits++
            }}
            if (digits == 0) {{
                return n
            }}
            if (neg) {{
                v = -v
            }}
            let p = n == 0 ? p0 : (n == 1 ? p1 : (n == 2 ? p2 : p3))
            c2da_mem[p] = uint8(v & 255)
            c2da_mem[p + 1] = uint8((v >> 8) & 255)
            c2da_mem[p + 2] = uint8((v >> 16) & 255)
            c2da_mem[p + 3] = uint8((v >> 24) & 255)
            n++
        }}
    }}
    return n
}}

// atoi: optional blanks and sign, then decimal digits (wrapping like the
// 32-bit accumulation of common libcs; overflow is undefined in C).
def c2da_lin_atoi(s : int) : int {{
    var i = s
    while (c2da_lin_isspace(int(c2da_mem[i]))) {{
        i++
    }}
    var neg = false
    if (c2da_mem[i] == uint8(45) || c2da_mem[i] == uint8(43)) {{
        neg = c2da_mem[i] == uint8(45)
        i++
    }}
    var v = 0
    while (int(c2da_mem[i]) >= 48 && int(c2da_mem[i]) <= 57) {{
        v = v * 10 + int(c2da_mem[i]) - 48
        i++
    }}
    return neg ? -v : v
}}

// atof: decimal digits, a fraction and an exponent.  Exact (correctly
// rounded) while the digits fit 2^53 and the decimal exponent is within 22;
// beyond that the scaling rounds more than once.
def c2da_lin_atof(s : int) : double {{
    var i = s
    while (c2da_lin_isspace(int(c2da_mem[i]))) {{
        i++
    }}
    var neg = false
    if (int(c2da_mem[i]) == 45 || int(c2da_mem[i]) == 43) {{
        neg = int(c2da_mem[i]) == 45
        i++
    }}
    var m = 0.0lf
    var e = 0
    while (int(c2da_mem[i]) >= 48 && int(c2da_mem[i]) <= 57) {{
        m = m * 10.0lf + double(int(c2da_mem[i]) - 48)
        i++
    }}
    if (int(c2da_mem[i]) == 46) {{
        i++
        while (int(c2da_mem[i]) >= 48 && int(c2da_mem[i]) <= 57) {{
            m = m * 10.0lf + double(int(c2da_mem[i]) - 48)
            e--
            i++
        }}
    }}
    if (int(c2da_mem[i]) == 101 || int(c2da_mem[i]) == 69) {{
        var j = i + 1
        var eneg = false
        if (int(c2da_mem[j]) == 45 || int(c2da_mem[j]) == 43) {{
            eneg = int(c2da_mem[j]) == 45
            j++
        }}
        if (int(c2da_mem[j]) >= 48 && int(c2da_mem[j]) <= 57) {{
            var x = 0
            while (int(c2da_mem[j]) >= 48 && int(c2da_mem[j]) <= 57) {{
                if (x < 100000) {{
                    x = x * 10 + int(c2da_mem[j]) - 48
                }}
                j++
            }}
            e += eneg ? -x : x
        }}
    }}
    var p = 1.0lf
    for (_ in range(e < 0 ? -e : e)) {{
        p *= 10.0lf
    }}
    let v = e < 0 ? m / p : m * p
    return neg ? -v : v
}}

def c2da_lin_strstr(h : int; n : int) : int {{
    var i = h
    while (true) {{
        var k = 0
        while (c2da_mem[n + k] != uint8(0) && c2da_mem[i + k] == c2da_mem[n + k]) {{
            k++
        }}
        if (c2da_mem[n + k] == uint8(0)) {{
            return i
        }}
        if (c2da_mem[i] == uint8(0)) {{
            return 0
        }}
        i++
    }}
    return 0
}}
"#
    )
}

/// The per-signature function tables for function pointers held in the heap:
/// `c2da_fn_table<n>[i]` is the function of index `i` (0 is NULL), filled by
/// `c2da_relink`, which a host calls again after a hot reload (daslang
/// function values do not survive one; the indices in the heap do).
fn function_tables_source() -> String {
    let sigs = SIGS.with(|s| s.borrow().clone());
    if sigs.is_empty() {
        return String::new();
    }
    let funcs = FUNCS.with(|f| f.borrow().clone());
    let count = funcs.len() + 1;
    let mut text = String::from("\n// Function pointers in the heap are indices into these tables (0 is NULL).\n");
    for (n, t) in sigs.iter().enumerate() {
        text.push_str(&function_table_decl(n, t));
    }
    text.push_str("// Refills the function tables (at start, and after a hot reload).\ndef c2da_relink() {\n");
    for (n, t) in sigs.iter().enumerate() {
        text.push_str(&format!("    resize(c2da_fn_table{n}, {count})\n"));
        for (k, (name, sig)) in funcs.iter().enumerate() {
            if sig == t {
                text.push_str(&format!("    c2da_fn_table{n}[{}] = @@{name}\n", k + 1));
            }
        }
    }
    text.push_str("}\n\n[init]\ndef private c2da_lin_relink_init() {\n    c2da_relink()\n}\n");
    text
}

/// The table of function-pointer signature `n` and its index search.
fn function_table_decl(n: usize, t: &DaType) -> String {
    format!(
        "var c2da_fn_table{n} : array<{t}>\n\n\
         def c2da_fn_index{n}(f : {t}) : int {{\n    \
         for (k in range(length(c2da_fn_table{n}))) {{\n        \
         if (c2da_fn_table{n}[k] == f) {{\n            return k\n        }}\n    }}\n    \
         panic(\"c2da: a function pointer outside the function table\")\n    \
         return 0\n}}\n\n"
    )
}

/// The `main` wrapper's argv builder (appended when `main` takes argv).
const ARGV_RUNTIME: &str = r#"
// The main wrapper's argv: argument `index` copied into the heap as a C string.
def c2da_lin_put_arg(argv : int; index : int; s : string) {
    let n = length(s)
    let p = c2da_lin_malloc(uint64(n + 1))
    for (j in range(n)) {
        c2da_mem[p + j] = uint8(character_at(s, j))
    }
    c2da_mem[p + n] = uint8(0)
    c2da_lin_st32(argv + index * 8, p)
}
"#;

/// Records that the `main` wrapper builds argv in the heap.
pub(crate) fn note_argv() {
    ARGV_USED.with(|u| u.set(true));
}

/// `fopen`/`fread` over the heap under `--libc eden` (appended when used):
/// the `c2da_eden_*` file table the host fills with `c2da_eden_add_file`.
const FILE_RUNTIME: &str = r#"
// <stdio.h> files over C memory: a FILE * is the --libc eden handle as an int.
def private c2da_lin_cstr(p : int) : string {
    return build_string() $(var w) {
        var i = p
        while (c2da_mem[i] != uint8(0)) {
            write_char(w, int(c2da_mem[i]))
            i++
        }
    }
}

def c2da_lin_fopen(path : int; mode : int) : int {
    return int(c2da_eden_fopen(c2da_lin_cstr(path), c2da_lin_cstr(mode)))
}

def c2da_lin_fread(d : int; size : uint64; count : uint64; handle : uint64) : uint64 {
    if (size == 0ul || count == 0ul || handle < 16ul) {
        return 0ul
    }
    let slot = int(handle - 16ul)
    if (slot >= length(c2da_eden_open_file) || c2da_eden_open_file[slot] < 0) {
        return 0ul
    }
    let file = c2da_eden_open_file[slot]
    let avail = int64(length(c2da_eden_file_data[file]))
    let total = int64(size * count)
    var pos = c2da_eden_open_pos[slot]
    var n = 0l
    while (n < total && pos < avail) {
        c2da_mem[d + int(n)] = c2da_eden_file_data[file][pos]
        n++
        pos++
    }
    c2da_eden_open_pos[slot] = pos
    return uint64(n) / size
}

// Only stdout and stderr are writable (--libc eden): any other handle writes nothing.
def c2da_lin_fputc(c : int; handle : uint64) : int {
    if (handle != 1ul && handle != 2ul) {
        return -1
    }
    c2da_std_write(handle, build_string() $(var w) {
        write_char(w, c & 255)
    })
    return c & 255
}

def c2da_lin_fwrite(s : int; size : uint64; count : uint64; handle : uint64) : uint64 {
    if (size == 0ul || count == 0ul || (handle != 1ul && handle != 2ul)) {
        return 0ul
    }
    let total = int(size * count)
    c2da_std_write(handle, build_string() $(var w) {
        for (j in range(total)) {
            write_char(w, int(c2da_mem[s + j]))
        }
    })
    return count
}
"#;

/// The printf family over the heap (appended when a call uses it).  Flags in
/// `c2da_lin_vfmt`: 1 `-`, 2 `+`, 4 space, 8 `#`, 16 `0`.  Length modifiers
/// truncate the promoted `int64` to C's width; `%s` and `%p` read offsets.
/// The translator refuses a literal format with any other conversion; a
/// computed one panics at run time.
const FORMAT_RUNTIME: &str = r#"
// printf family over C memory: the format and %s/%p arguments are heap offsets.
def private c2da_lin_pad(var out : array<uint8>; c : int; n : int) {
    for (i in range(n)) {
        push(out, uint8(c))
    }
}

def private c2da_lin_fmt_int(var out : array<uint8>; neg : bool; mag : uint64; base : uint64; upper : bool; flags : int; width : int; prec : int) {
    var digits : array<uint8>
    var m = mag
    while (m != 0ul) {
        let d = int(m % base)
        if (d < 10) {
            push(digits, uint8(48 + d))
        } elif (upper) {
            push(digits, uint8(55 + d))
        } else {
            push(digits, uint8(87 + d))
        }
        m /= base
    }
    let nd = length(digits)
    var p = prec < 0 ? 1 : prec
    if ((flags & 8) != 0 && base == 8ul && p <= nd) {
        p = nd + 1
    }
    let zeros = p > nd ? p - nd : 0
    var prefix : array<uint8>
    if (neg) {
        push(prefix, uint8(45))
    } elif ((flags & 2) != 0) {
        push(prefix, uint8(43))
    } elif ((flags & 4) != 0) {
        push(prefix, uint8(32))
    }
    if ((flags & 8) != 0 && base == 16ul && mag != 0ul) {
        push(prefix, uint8(48))
        push(prefix, upper ? uint8(88) : uint8(120))
    }
    let body = length(prefix) + zeros + nd
    let fill = width > body ? width - body : 0
    let zero_fill = (flags & 1) == 0 && (flags & 16) != 0 && prec < 0
    if ((flags & 1) == 0 && !zero_fill) {
        c2da_lin_pad(out, 32, fill)
    }
    for (b in prefix) {
        push(out, b)
    }
    if (zero_fill) {
        c2da_lin_pad(out, 48, fill)
    }
    c2da_lin_pad(out, 48, zeros)
    var i = nd - 1
    while (i >= 0) {
        push(out, digits[i])
        i--
    }
    if ((flags & 1) != 0) {
        c2da_lin_pad(out, 32, fill)
    }
}

def private c2da_lin_fmt_bytes(var out : array<uint8>; s : int; n : int; flags : int; width : int) {
    let fill = width > n ? width - n : 0
    if ((flags & 1) == 0) {
        c2da_lin_pad(out, 32, fill)
    }
    for (j in range(n)) {
        push(out, c2da_mem[s + j])
    }
    if ((flags & 1) != 0) {
        c2da_lin_pad(out, 32, fill)
    }
}

// Appends the conversion of format f over args[start..] to out; answers the
// index of the first argument it did not consume.
def c2da_lin_vfmt(f : int; args : array<C2daVaArg>; start : int; var out : array<uint8>) : int {
    var k = start
    var i = f
    while (c2da_mem[i] != uint8(0)) {
        let c = int(c2da_mem[i])
        i++
        if (c != 37) {
            push(out, uint8(c))
            continue
        }
        var flags = 0
        while (true) {
            let g = int(c2da_mem[i])
            if (g == 45) {
                flags |= 1
            } elif (g == 43) {
                flags |= 2
            } elif (g == 32) {
                flags |= 4
            } elif (g == 35) {
                flags |= 8
            } elif (g == 48) {
                flags |= 16
            } else {
                break
            }
            i++
        }
        var width = 0
        if (int(c2da_mem[i]) == 42) {
            width = int(args[k].i64)
            k++
            i++
            if (width < 0) {
                flags |= 1
                width = -width
            }
        } else {
            while (int(c2da_mem[i]) >= 48 && int(c2da_mem[i]) <= 57) {
                width = width * 10 + int(c2da_mem[i]) - 48
                i++
            }
        }
        var prec = -1
        if (int(c2da_mem[i]) == 46) {
            i++
            prec = 0
            if (int(c2da_mem[i]) == 42) {
                prec = int(args[k].i64)
                k++
                i++
            } else {
                while (int(c2da_mem[i]) >= 48 && int(c2da_mem[i]) <= 57) {
                    prec = prec * 10 + int(c2da_mem[i]) - 48
                    i++
                }
            }
        }
        // 0: int, 1: hh, 2: h, 3: 64-bit
        var size = 0
        while (true) {
            let g = int(c2da_mem[i])
            if (g == 104) {
                size = size == 2 ? 1 : 2
            } elif (g == 108 || g == 106 || g == 122 || g == 116 || g == 113 || g == 76) {
                size = 3
            } else {
                break
            }
            i++
        }
        let conv = int(c2da_mem[i])
        i++
        if (conv == 37) {
            push(out, uint8(37))
        } elif (conv == 100 || conv == 105) {
            var v = args[k].i64
            k++
            if (size == 0) {
                v = ((v & 4294967295l) ^ 2147483648l) - 2147483648l
            } elif (size == 1) {
                v = ((v & 255l) ^ 128l) - 128l
            } elif (size == 2) {
                v = ((v & 65535l) ^ 32768l) - 32768l
            }
            let neg = v < 0l
            c2da_lin_fmt_int(out, neg, neg ? uint64(-v) : uint64(v), 10ul, false, flags, width, prec)
        } elif (conv == 117 || conv == 120 || conv == 88 || conv == 111) {
            var m = uint64(args[k].i64)
            k++
            if (size == 0) {
                m &= 0xfffffffful
            } elif (size == 1) {
                m &= 0xfful
            } elif (size == 2) {
                m &= 0xfffful
            }
            let base = conv == 117 ? 10ul : (conv == 111 ? 8ul : 16ul)
            c2da_lin_fmt_int(out, false, m, base, conv == 88, flags & ~6, width, prec)
        } elif (conv == 99) {
            let b = int(args[k].i64 & 255l)
            k++
            let fill = width > 1 ? width - 1 : 0
            if ((flags & 1) == 0) {
                c2da_lin_pad(out, 32, fill)
            }
            push(out, uint8(b))
            if ((flags & 1) != 0) {
                c2da_lin_pad(out, 32, fill)
            }
        } elif (conv == 115) {
            let s = int(args[k].raw)
            k++
            if (s == 0) {
                // glibc's "(null)"
                var t : array<uint8>
                push(t, uint8(40))
                push(t, uint8(110))
                push(t, uint8(117))
                push(t, uint8(108))
                push(t, uint8(108))
                push(t, uint8(41))
                let fill = width > 6 ? width - 6 : 0
                if ((flags & 1) == 0) {
                    c2da_lin_pad(out, 32, fill)
                }
                for (b in t) {
                    push(out, b)
                }
                if ((flags & 1) != 0) {
                    c2da_lin_pad(out, 32, fill)
                }
            } else {
                var n = 0
                while ((prec < 0 || n < prec) && c2da_mem[s + n] != uint8(0)) {
                    n++
                }
                c2da_lin_fmt_bytes(out, s, n, flags, width)
            }
        } elif (conv == 112) {
            let p = args[k].raw
            k++
            c2da_lin_fmt_int(out, false, p, 16ul, false, flags | 8, width, prec)
        } else {
            panic("c2da: printf conversion not supported under --memory-model linear")
        }
    }
    return k
}

def private c2da_lin_text(out : array<uint8>) : string {
    return build_string() $(var w) {
        for (b in out) {
            write_char(w, int(b))
        }
    }
}

// C's snprintf truncation: at most n - 1 bytes and a NUL; answers the full length.
def private c2da_lin_place(d : int; n : uint64; out : array<uint8>) : int {
    let len = length(out)
    if (n != 0ul) {
        let m = uint64(len) < n ? len : int(n) - 1
        for (j in range(m)) {
            c2da_mem[d + j] = out[j]
        }
        c2da_mem[d + m] = uint8(0)
    }
    return len
}

def c2da_lin_printf(h : uint64; f : int; args : array<C2daVaArg>) : int {
    var out : array<uint8>
    c2da_lin_vfmt(f, args, 0, out)
    c2da_std_write(h, c2da_lin_text(out))
    return length(out)
}

def c2da_lin_vprintf(h : uint64; f : int; var ap : C2daVaCursor; args : array<C2daVaArg>) : int {
    var out : array<uint8>
    ap.index = c2da_lin_vfmt(f, args, ap.index, out)
    c2da_std_write(h, c2da_lin_text(out))
    return length(out)
}

def c2da_lin_snprintf(d : int; n : uint64; f : int; args : array<C2daVaArg>) : int {
    var out : array<uint8>
    c2da_lin_vfmt(f, args, 0, out)
    return c2da_lin_place(d, n, out)
}

def c2da_lin_vsnprintf(d : int; n : uint64; f : int; var ap : C2daVaCursor; args : array<C2daVaArg>) : int {
    var out : array<uint8>
    ap.index = c2da_lin_vfmt(f, args, ap.index, out)
    return c2da_lin_place(d, n, out)
}
"#;
