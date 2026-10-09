//! `--varargs-model heap` (with `--memory-model linear`): C variadic
//! arguments in the C stack region of `c2da_mem`, as clang's wasm ABI passes
//! them, instead of an `array<C2daVaArg>` literal per call.
//!
//! Every call site to a variadic function owns an outgoing-argument area in
//! its caller's C stack frame (`linear_plan_frame`), 8 bytes per variadic
//! argument: an integer is promoted and stored as `int64`, a `float`/`double`
//! as the 8 bytes of a `double`, a pointer as its offset (8 bytes, the high 4
//! zero).  The callee's extra parameter `c2da_va_args` is the area's address
//! and a `va_list` cursor's `index` is the address of its next slot, so
//! `va_arg` is one 8-byte load and `index += 8`; `va_end` poisons it with -1,
//! out of the heap's range.  A distinct area per call site keeps the stores of
//! one call from clobbering another whose arguments are being evaluated, and
//! a recursive call has its own frame.
use super::*;
use crate::target::VarargsModel;

/// Bytes per variadic argument slot.
const SLOT: i64 = 8;

thread_local! {
    /// The outgoing-argument area of each variadic call site, keyed by the
    /// call's callee expression: its offset from the frame pointer.
    static AREAS: RefCell<StdHashMap<CExprId, i64>> = RefCell::new(StdHashMap::new());
    /// Whether a printf-family call was lowered over heap arguments.
    static FORMAT_HEAP_USED: std::cell::Cell<bool> = std::cell::Cell::new(false);
}

pub(super) fn reset() {
    AREAS.with(|a| a.borrow_mut().clear());
    FORMAT_HEAP_USED.with(|u| u.set(false));
}

pub(super) fn format_heap_used() -> bool {
    FORMAT_HEAP_USED.with(|u| u.get())
}

/// The runtime section of the heap printf family (it uses the private
/// helpers of `FORMAT_RUNTIME`, which is always emitted alongside).
pub(super) fn runtime_section(on: bool) -> &'static str {
    if on {
        FORMAT_HEAP_RUNTIME
    } else {
        ""
    }
}

/// The heap counterpart of a `c2da_lin_*printf` runtime entry.
pub(super) fn heap_format_runtime(runtime: &str) -> &'static str {
    match runtime {
        "c2da_lin_printf" => "c2da_lin_printf_h",
        "c2da_lin_vprintf" => "c2da_lin_vprintf_h",
        "c2da_lin_snprintf" => "c2da_lin_snprintf_h",
        _ => "c2da_lin_vsnprintf_h",
    }
}

impl<'c> Translation<'c> {
    /// `--varargs-model heap` under `--memory-model linear` (the switch is
    /// refused without the linear model, `target.rs`).
    pub(crate) fn va_heap(&self) -> bool {
        self.is_linear() && self.tcfg.target.varargs_model == VarargsModel::Heap
    }

    /// Reserves, after `size` bytes of locals, the outgoing-argument area of
    /// every variadic call in `nodes`; answers the frame's new size.
    pub(super) fn va_heap_plan_areas(&self, nodes: &[CExprId], mut size: i64) -> i64 {
        if !self.va_heap() {
            return size;
        }
        for &e in nodes {
            let CExprKind::Call(_, func, ref args) = self.ast_context[e].kind else { continue };
            // `va_start`/`va_copy` are declared variadic but are cursor
            // operations (`variadic.rs`), not calls.
            if !self.is_variadic_callee(func) || self.match_vapart(func, args).is_some() {
                continue;
            }
            let extra = args.len().saturating_sub(self.call_arg_types(func).len()) as i64;
            if extra == 0 {
                continue;
            }
            AREAS.with(|a| a.borrow_mut().insert(func, size));
            size += (extra * SLOT + 15) & !15;
        }
        size
    }

    /// The stores of a variadic call's trailing arguments into its area; the
    /// expression is the area's address (0 when there are none).
    pub(crate) fn va_heap_area(
        &self,
        func: CExprId,
        tail: Vec<(CExprId, DaExpr)>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        if tail.is_empty() {
            return Ok(WithStmts::new_val(DaExpr::ConstInt(0)));
        }
        let Some(off) = AREAS.with(|a| a.borrow().get(&func).copied()) else {
            return Err(self.linear_refuse(
                func,
                "a variadic call outside a function body (--varargs-model heap)",
            ));
        };
        let base = plus(&DaExpr::Var(FP.into()), off);
        let mut stmts = Vec::new();
        for (k, (arg, value)) in tail.into_iter().enumerate() {
            let ty = self.qual_of(arg)?;
            let s = self.va_heap_slot_scalar(arg, ty.ctype)?;
            let value = match s {
                Scalar::I64 => cast(DaType::int64(), value),
                Scalar::F64 => cast(DaType::double(), value),
                _ => value,
            };
            let mut fresh = || self.fresh_name();
            stmts.extend(store(s, &plus(&base, k as i64 * SLOT), &value, &mut fresh));
        }
        Ok(WithStmts::new(stmts, base))
    }

    /// How a promoted variadic value of C type `ty` sits in its slot.
    fn va_heap_slot_scalar(&self, at: CExprId, ty: CTypeId) -> TranslationResult<Scalar> {
        let kind = &self.ast_context.resolve_type(ty).kind;
        if kind.is_integral_type() || kind.is_enum() {
            Ok(Scalar::I64)
        } else if matches!(kind, CTypeKind::Float | CTypeKind::Double) {
            Ok(Scalar::F64)
        } else if self.is_data_pointer(ty) || (kind.is_pointer() && fn_table()) {
            Ok(Scalar::Ptr)
        } else {
            Err(self.linear_refuse(
                at,
                &format!("a variadic argument of this type under --varargs-model heap: {kind:?}"),
            ))
        }
    }

    /// `va_arg(ap, T)`: the slot at the cursor, then the cursor advanced.
    pub(crate) fn va_heap_vaarg(
        &self,
        cursor: DaExpr,
        ty: CQualTypeId,
        at: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let s = self.va_heap_slot_scalar(at, ty.ctype)?;
        let index = DaExpr::Field(Box::new(cursor), "index".into());
        let item = self.fresh_name();
        let output = self.convert_type(ty)?;
        let value = if s.da_type() == output {
            DaExpr::Var(item.clone())
        } else {
            cast(output, DaExpr::Var(item.clone()))
        };
        Ok(WithStmts::new(
            vec![
                DaStmt::Let {
                    name: item,
                    var_type: Some(s.da_type()),
                    init: Some(load(s, &index)),
                },
                DaStmt::Expr(DaExpr::Assign(Box::new(index.clone()), Box::new(plus(&index, SLOT)))),
            ],
            value,
        ))
    }

    /// The printf family's trailing arguments over the heap: the area's
    /// address, and the heap formatter section marked as used.
    pub(super) fn va_heap_format_tail(
        &self,
        call: CExprId,
        tail: Vec<(CExprId, DaExpr)>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let CExprKind::Call(_, func, _) = self.ast_context[call].kind else {
            return Err(self.linear_refuse(call, "a printf-family call that is not a call"));
        };
        FORMAT_HEAP_USED.with(|u| u.set(true));
        self.va_heap_area(func, tail)
    }

    pub(super) fn mark_format_heap_used(&self) {
        FORMAT_HEAP_USED.with(|u| u.set(true));
    }
}

/// The printf family over heap arguments: `c2da_lin_vfmt_h` is
/// `c2da_lin_vfmt` with each argument read from its 8-byte slot at address
/// `k` instead of `args[k]`.
const FORMAT_HEAP_RUNTIME: &str = r#"
// --varargs-model heap: a variadic argument is an 8-byte slot in the C stack, a va_list the address of the next one.
def private c2da_lin_va_i64(a : int) : int64 {
    return int64(uint64(uint(c2da_lin_ld32(a))) | (uint64(uint(c2da_lin_ld32(a + 4))) << 32ul))
}

// Appends the conversion of format f over the slots from address k; answers the address of the first slot it did not consume.
def c2da_lin_vfmt_h(f : int; start : int; var out : array<uint8>) : int {
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
            width = int(c2da_lin_va_i64(k))
            k += 8
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
                prec = int(c2da_lin_va_i64(k))
                k += 8
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
            var v = c2da_lin_va_i64(k)
            k += 8
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
            var m = uint64(c2da_lin_va_i64(k))
            k += 8
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
            let b = int(c2da_lin_va_i64(k) & 255l)
            k += 8
            let fill = width > 1 ? width - 1 : 0
            if ((flags & 1) == 0) {
                c2da_lin_pad(out, 32, fill)
            }
            push(out, uint8(b))
            if ((flags & 1) != 0) {
                c2da_lin_pad(out, 32, fill)
            }
        } elif (conv == 115) {
            let s = int(c2da_lin_va_i64(k))
            k += 8
            if (s == 0) {
                // glibc's "(null)"
                let fill = width > 6 ? width - 6 : 0
                if ((flags & 1) == 0) {
                    c2da_lin_pad(out, 32, fill)
                }
                push(out, uint8(40))
                push(out, uint8(110))
                push(out, uint8(117))
                push(out, uint8(108))
                push(out, uint8(108))
                push(out, uint8(41))
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
            let p = uint64(c2da_lin_va_i64(k))
            k += 8
            c2da_lin_fmt_int(out, false, p, 16ul, false, flags | 8, width, prec)
        } else {
            panic("c2da: printf conversion not supported under --memory-model linear")
        }
    }
    return k
}

def c2da_lin_printf_h(h : uint64; f : int; args : int) : int {
    var out : array<uint8>
    c2da_lin_vfmt_h(f, args, out)
    c2da_std_write(h, c2da_lin_text(out))
    return length(out)
}

def c2da_lin_vprintf_h(h : uint64; f : int; var ap : C2daVaCursor) : int {
    var out : array<uint8>
    ap.index = c2da_lin_vfmt_h(f, ap.index, out)
    c2da_std_write(h, c2da_lin_text(out))
    return length(out)
}

def c2da_lin_snprintf_h(d : int; n : uint64; f : int; args : int) : int {
    var out : array<uint8>
    c2da_lin_vfmt_h(f, args, out)
    return c2da_lin_place(d, n, out)
}

def c2da_lin_vsnprintf_h(d : int; n : uint64; f : int; var ap : C2daVaCursor) : int {
    var out : array<uint8>
    ap.index = c2da_lin_vfmt_h(f, ap.index, out)
    return c2da_lin_place(d, n, out)
}
"#;
