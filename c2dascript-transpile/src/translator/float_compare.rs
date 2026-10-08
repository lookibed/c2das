//! `--float-compare nan-safe`: C floating comparisons for a runtime whose own
//! comparisons are not IEEE.
//!
//! The EdenSpark editor's daslang answers `NaN == NaN` true, `NaN < 1` true
//! and `NaN != NaN` false (`docs/eden-target.md` §3).  Under this mode every
//! `==`, `!=`, `<`, `<=`, `>`, `>=` the translator writes over two `float` or
//! two `double` operands — a C comparison, and the `x != 0` / `x == 0` that C
//! truthiness and `!x` stand for — is a call to a helper that decides NaN by a
//! bit test (`math_bits`) before it compares, so the result is C's IEEE one
//! whatever the runtime's comparison does with a NaN:
//!
//! - `eq(a, b) = !isnan(a) && !isnan(b) && a == b`
//! - `ne(a, b) = isnan(a) || isnan(b) || a != b`
//! - an ordered compare is false when either side is NaN.
//!
//! `isnan` is a bit test, never `x != x`, which is the comparison in question.
//! The helpers are emitted only into a module that uses them, with
//! `require daslib/math_bits`; under the default `ieee` mode nothing here is
//! reachable and the output is unchanged.
use das_ast::{DaBlock, DaDecl, DaExpr, DaFunction, DaStmt, DaType, DaTypeKind};
use std::cell::RefCell;
use std::collections::BTreeMap;

// Per translation unit, like `builtins.rs`'s helper set: reset at the start of
// `translate_impl`, drained into the module after the bodies are lowered.
thread_local! {
    static REQUIRED: RefCell<BTreeMap<String, DaDecl>> = RefCell::new(BTreeMap::new());
}

/// Clears the helper set at the start of a translation unit.
pub fn reset() {
    REQUIRED.with(|helpers| helpers.borrow_mut().clear());
}

/// The helper declarations this unit used, emptied.
pub fn take_declarations() -> Vec<DaDecl> {
    REQUIRED.with(|helpers| {
        std::mem::take(&mut *helpers.borrow_mut())
            .into_values()
            .collect()
    })
}

/// The `require` line the helpers stand on, when any is in the unit.  Must be
/// called before [`take_declarations`].
pub fn module_requires() -> Vec<String> {
    let used = REQUIRED.with(|helpers| !helpers.borrow().is_empty());
    if used {
        vec!["daslib/math_bits".to_owned()]
    } else {
        vec![]
    }
}

/// The NaN-guarded form of `left op right` when both operands have the
/// floating daScript type `ty`, or `None` when `op` is not a comparison or
/// `ty` is not floating (the caller then writes the plain operator).
pub fn guarded(
    op: &str,
    ty: &DaType,
    left: DaExpr,
    right: DaExpr,
) -> Result<DaExpr, (DaExpr, DaExpr)> {
    let suffix = match ty.kind {
        DaTypeKind::Float => "f",
        DaTypeKind::Double => "d",
        _ => return Err((left, right)),
    };
    let name = match op {
        "==" => "eq",
        "!=" => "ne",
        "<" => "lt",
        "<=" => "le",
        ">" => "gt",
        ">=" => "ge",
        _ => return Err((left, right)),
    };
    let op: &'static str = match name {
        "eq" => "==",
        "ne" => "!=",
        "lt" => "<",
        "le" => "<=",
        "gt" => ">",
        _ => ">=",
    };
    let isnan = isnan_helper(suffix, ty);
    let helper = format!("c2da_fcmp_{name}_{suffix}");
    REQUIRED.with(|helpers| {
        helpers
            .borrow_mut()
            .entry(helper.clone())
            .or_insert_with(|| compare_helper(&helper, &isnan, op, ty));
    });
    Ok(DaExpr::Call(
        Box::new(DaExpr::Var(helper)),
        vec![left, right],
    ))
}

/// Whether `expr` is a call [`guarded`] built: a C comparison whose daScript
/// value is a `bool`, like the plain operator it stands for.
pub fn is_guarded_compare(expr: &DaExpr) -> bool {
    matches!(expr, DaExpr::Call(callee, _)
        if matches!(&**callee, DaExpr::Var(name) if name.starts_with("c2da_fcmp_")))
}

/// Registers `c2da_isnan_<suffix>` and returns its name.
fn isnan_helper(suffix: &str, ty: &DaType) -> String {
    let name = format!("c2da_isnan_{suffix}");
    REQUIRED.with(|helpers| {
        helpers.borrow_mut().entry(name.clone()).or_insert_with(|| {
            // A NaN has every exponent bit set and a non-zero mantissa: its
            // magnitude bits compare above the infinity pattern.
            let (bits_fn, word, abs_mask, inf) = if suffix == "f" {
                (
                    "float_bits_to_uint",
                    DaType::uint(),
                    0x7fff_ffffu64,
                    0x7f80_0000u64,
                )
            } else {
                (
                    "double_bits_to_uint64",
                    DaType::uint64(),
                    0x7fff_ffff_ffff_ffffu64,
                    0x7ff0_0000_0000_0000u64,
                )
            };
            let bits = DaExpr::Call(Box::new(var(bits_fn)), vec![var("x")]);
            let magnitude = op2("&", bits, typed_uint(abs_mask, &word));
            function(
                &name,
                vec![param("x", ty.clone())],
                ret(op2(">", magnitude, typed_uint(inf, &word))),
            )
        });
    });
    name
}

fn compare_helper(name: &str, isnan: &str, op: &'static str, ty: &DaType) -> DaDecl {
    let nan = |arg: &str| DaExpr::Call(Box::new(var(isnan)), vec![var(arg)]);
    let compare = op2(op, var("a"), var("b"));
    let body = if op == "!=" {
        op2("||", op2("||", nan("a"), nan("b")), compare)
    } else {
        let not = |e: DaExpr| DaExpr::Op1 {
            op: "!",
            expr: Box::new(e),
        };
        op2("&&", op2("&&", not(nan("a")), not(nan("b"))), compare)
    };
    function(
        name,
        vec![param("a", ty.clone()), param("b", ty.clone())],
        ret(body),
    )
}

fn function(name: &str, params: Vec<DaStmt>, body: DaStmt) -> DaDecl {
    DaDecl::Function(DaFunction {
        name: name.to_owned(),
        params,
        ret_type: DaType::bool(),
        body: Some(DaExpr::Block(DaBlock { stmts: vec![body] })),
        annotations: vec!["inline".to_owned()],
        is_public: false,
        is_unsafe: false,
    })
}

fn param(name: &str, param_type: DaType) -> DaStmt {
    DaStmt::Param {
        name: name.to_owned(),
        param_type,
        default: None,
        is_mutable: false,
    }
}

fn var(name: &str) -> DaExpr {
    DaExpr::Var(name.to_owned())
}

fn op2(op: &'static str, left: DaExpr, right: DaExpr) -> DaExpr {
    DaExpr::Op2 {
        op,
        left: Box::new(left),
        right: Box::new(right),
    }
}

fn typed_uint(value: u64, ty: &DaType) -> DaExpr {
    DaExpr::Cast {
        kind: das_ast::CastKind::Cast,
        expr: Box::new(DaExpr::ConstUInt(value)),
        to: ty.clone(),
    }
}

fn ret(value: DaExpr) -> DaStmt {
    DaStmt::Expr(DaExpr::Return(Some(Box::new(value))))
}
