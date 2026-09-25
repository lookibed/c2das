//! Canonical C variadic ABI lowering.
//!
//! daScript does not expose the platform `va_list` ABI.  A C variadic call
//! instead carries an explicit array of promoted tagged values; a local
//! `va_list` is a cursor over that array.  This module owns that boundary.
use super::*;
use crate::format_translation_err;

const VA_ARGS_PARAM: &str = "c2da_va_args";

/// The cursor index a `va_list` object carries between `va_start`/`va_copy`
/// and its matching `va_end`: the first promoted argument this cursor has not
/// consumed yet.
const VA_CURSOR_FIRST: i64 = 0;

/// The cursor index `va_end` leaves behind.  C99 7.15.1.3 ends the object's
/// lifetime there — any later `va_arg` is undefined — so the cursor is poisoned
/// with an index no argument array can hold.  A use after `va_end` then fails
/// as a located daScript "array index out of range" instead of reading whatever
/// the cursor happened to point at.
const VA_CURSOR_ENDED: i64 = -1;

#[derive(Copy, Clone, Debug)]
pub enum VaPart {
    Start(CDeclId),
    End(CDeclId),
    Copy(CDeclId, CDeclId),
}

impl<'c> Translation<'c> {
    pub fn va_arg_type(&self) -> DaType {
        DaType::named("C2daVaArg")
    }
    pub(crate) fn va_cursor_type(&self) -> DaType {
        DaType::named("C2daVaCursor")
    }

    pub fn is_va_decl(&self, decl_id: CDeclId) -> bool {
        self.function_context
            .borrow()
            .va_list_decl_ids
            .as_ref()
            .map_or(false, |ids| ids.contains(&decl_id))
    }

    /// True for a C function parameter that receives a `va_list`.
    ///
    /// On x86-64 `va_list` is `struct __va_list_tag[1]`, so a parameter of that
    /// type has already decayed to a pointer by the time Clang records it;
    /// `is_va_list` accounts for the decay, which is why the parameter must be
    /// recognized by *type* rather than by the declaration's spelling.
    pub(crate) fn is_va_list_param(&self, param_id: CDeclId) -> bool {
        match self.ast_context[param_id].kind {
            CDeclKind::Variable { typ, .. } => self.ast_context.is_va_list(typ.ctype),
            _ => false,
        }
    }

    /// The `va_list` parameters of a C function, in declaration order.
    pub(crate) fn va_list_params(&self, parameters: &[CDeclId]) -> Vec<CDeclId> {
        parameters
            .iter()
            .copied()
            .filter(|id| self.is_va_list_param(*id))
            .collect()
    }

    /// Records this function's canonical variadic context: the name of the
    /// promoted-argument array parameter and every declaration that is a cursor
    /// over it.
    ///
    /// `va_list_params` are the cursors the *caller* owns and this function
    /// received; the body's own `va_list` declarations are found by walking it.
    pub fn register_va_decls(&self, body: CStmtId, va_list_params: &[CDeclId]) -> String {
        let mut decls: IndexSet<CDeclId> = va_list_params.iter().copied().collect();
        for node in DFExpr::new(&self.ast_context, body.into()) {
            if let SomeId::Stmt(stmt) = node {
                if let CStmtKind::Decls(ids) = &self.ast_context[stmt].kind {
                    for id in ids {
                        if let CDeclKind::Variable { typ, .. } = &self.ast_context[*id].kind {
                            if self.ast_context.is_va_list(typ.ctype) {
                                decls.insert(*id);
                            }
                        }
                    }
                }
            }
            if let SomeId::Expr(expr) = node {
                // VAArgExpr is the authoritative Clang node even on targets
                // where the `va_start` builtin declaration is implicit.
                if let CExprKind::VAArg(_, cursor) = &self.ast_context[expr].kind {
                    if let Some(id) = self.va_decl_from_expr(*cursor) {
                        decls.insert(id);
                    }
                }
                if let CExprKind::Call(_, func, args) = &self.ast_context[expr].kind {
                    if let Some(part) = self.match_vapart(*func, args) {
                        match part {
                            VaPart::Start(id) | VaPart::End(id) => {
                                decls.insert(id);
                            }
                            VaPart::Copy(dst, _) => {
                                decls.insert(dst);
                            }
                        }
                    }
                }
            }
        }
        self.function_context
            .borrow_mut()
            .set_va_list_context(VA_ARGS_PARAM.into(), decls);
        VA_ARGS_PARAM.into()
    }

    /// Rejects a `va_list` object whose *address* outlives the frame it was
    /// created in.
    ///
    /// This is a lifetime check, not an address-taken check.  A cursor crosses
    /// a call as the `var` record it is declared to be, i.e. by reference, so
    /// `&ap` handed straight to a callee — musl's
    /// `printf_core(…, va_list *ap, …)`, picolibc's struct wrapper — names
    /// storage that is alive for the whole call, and is the one forwarding
    /// shape C itself defines (C99 7.15.1p1 exempts "a function that receives a
    /// pointer to the object").  Storing that address anywhere else — a global,
    /// a struct field, the heap, a return value — hands out a reference that
    /// daScript cannot keep alive past the call, and today it also
    /// reinterprets a 4-byte cursor as a pointer to a 24-byte
    /// `struct __va_list_tag`.  That fails closed here, at the C source
    /// location of the `&`.
    pub(crate) fn check_va_list_address_lifetimes(&self, body: CStmtId) -> TranslationResult<()> {
        let mut passed_to_call: IndexSet<CExprId> = IndexSet::new();
        for node in DFExpr::new(&self.ast_context, body.into()) {
            let SomeId::Expr(expr) = node else { continue };
            if let CExprKind::Call(_, _, args) = &self.ast_context[expr].kind {
                for arg in args {
                    let arg = super::functions::strip_implicit_casts(&self.ast_context, *arg);
                    if self.va_list_address_operand(arg).is_some() {
                        passed_to_call.insert(arg);
                    }
                }
            }
        }
        for node in DFExpr::new(&self.ast_context, body.into()) {
            let SomeId::Expr(expr) = node else { continue };
            if self.va_list_address_operand(expr).is_some() && !passed_to_call.contains(&expr) {
                return Err(format_translation_err!(
                    self.ast_context.display_loc(&self.ast_context[expr].loc),
                    "va_list address escapes its frame: the address of a va_list object may only be passed directly as a call argument"
                ));
            }
        }
        Ok(())
    }

    /// The `va_list` declaration `expr` takes the address of, if `expr` is
    /// `&<va_list object>`.
    fn va_list_address_operand(&self, expr: CExprId) -> Option<CDeclId> {
        let CExprKind::Unary(_, CUnOp::AddressOf, target, _) = self.ast_context[expr].kind else {
            return None;
        };
        let id = self.va_decl_from_expr(target)?;
        self.is_va_decl(id).then_some(id)
    }

    pub(crate) fn va_decl_from_expr(&self, mut expr: CExprId) -> Option<CDeclId> {
        while let CExprKind::ImplicitCast(_, inner, _, _, _) = &self.ast_context[expr].kind {
            expr = *inner;
        }
        match self.ast_context[expr].kind {
            CExprKind::DeclRef(_, id, _) => Some(id),
            _ => None,
        }
    }

    pub fn match_vapart(&self, func: CExprId, args: &[CExprId]) -> Option<VaPart> {
        match self.direct_call_name(func)?.as_str() {
            "__builtin_va_start" if args.len() == 2 => {
                self.va_decl_from_expr(args[0]).map(VaPart::Start)
            }
            "__builtin_va_end" if args.len() == 1 => {
                self.va_decl_from_expr(args[0]).map(VaPart::End)
            }
            "__builtin_va_copy" if args.len() == 2 => self
                .va_decl_from_expr(args[0])
                .zip(self.va_decl_from_expr(args[1]))
                .map(|(a, b)| VaPart::Copy(a, b)),
            _ => None,
        }
    }

    pub fn convert_va_list_variable(
        &self,
        decl_id: CDeclId,
        name: &str,
        init: Option<CExprId>,
    ) -> TranslationResult<DaDecl> {
        if init.is_some() {
            return Err(TranslationError::generic("unsupported initialized va_list"));
        }
        let name = self.declare_value_name(decl_id, name);
        Ok(DaDecl::Variable(DaVariable {
            name,
            var_type: self.va_cursor_type(),
            annotations: vec![],
            init: Some(DaExpr::MakeStruct {
                type_name: "C2daVaCursor".into(),
                fields: vec![("index".into(), DaExpr::ConstInt(VA_CURSOR_FIRST))],
            }),
        }))
    }

    pub(crate) fn va_cursor_initializer(&self) -> DaExpr {
        DaExpr::MakeStruct {
            type_name: "C2daVaCursor".into(),
            fields: vec![("index".into(), DaExpr::ConstInt(VA_CURSOR_FIRST))],
        }
    }

    pub(crate) fn cursor_expr(&self, id: CDeclId) -> TranslationResult<DaExpr> {
        let CDeclKind::Variable { ident, .. } = &self.ast_context[id].kind else { return Err(TranslationError::generic("unsupported va_list declaration")); };
        Ok(DaExpr::Var(self.declare_value_name(id, ident)))
    }

    /// `<cursor>.index = <index>` — the only write the canonical model makes to
    /// a cursor outside `va_arg`.
    fn set_cursor_index(&self, id: CDeclId, index: i64) -> TranslationResult<DaStmt> {
        Ok(DaStmt::Expr(DaExpr::Assign(
            Box::new(DaExpr::Field(
                Box::new(self.cursor_expr(id)?),
                "index".into(),
            )),
            Box::new(DaExpr::ConstInt(index)),
        )))
    }

    /// The daScript argument a call passes for a C `va_list` parameter.
    ///
    /// C hands the callee the caller's cursor, and glibc's `va_list` is an
    /// array type, so what the callee advances is the caller's own cursor.  The
    /// canonical model reproduces that exactly: the cursor record crosses as
    /// the `var` parameter it is declared to be, which daScript passes by
    /// reference.  A program that wants an independent cursor writes `va_copy`,
    /// which copies the record.
    pub(crate) fn va_list_call_argument(&self, arg: CExprId) -> TranslationResult<DaExpr> {
        let Some(id) = self.va_decl_from_expr(arg) else {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[arg].loc),
                "unsupported va_list argument: not a va_list object"
            ));
        };
        if !self.is_va_decl(id) {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[arg].loc),
                "va_list argument is neither started by va_start nor a va_list parameter"
            ));
        }
        self.cursor_expr(id)
    }

    /// The promoted-argument array a call that forwards a `va_list` passes
    /// alongside the cursor.
    ///
    /// A cursor is an index into exactly one such array, so the caller has to
    /// hand its own array over too; only a variadic function or a function that
    /// itself received a `va_list` has one.
    pub(crate) fn forwarded_va_args(&self, at: CExprId) -> TranslationResult<DaExpr> {
        let name = self.function_context.borrow().va_list_arg_name.clone();
        let Some(name) = name else {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[at].loc),
                "va_list forwarded from a function that has no variadic arguments"
            ));
        };
        Ok(DaExpr::Var(name))
    }

    pub fn convert_vapart(&self, part: VaPart) -> TranslationResult<WithStmts<DaExpr>> {
        match part {
            // C99 7.15.1.4p1: `va_start` *initialises* the object for
            // subsequent use, so a second `va_start` on the same `va_list`
            // rewinds it to the first variadic argument — the two-pass
            // "measure, then format" shape depends on exactly that.  The
            // declaration-site initialiser covers only the first `va_start`,
            // so every one of them rewinds the cursor here.
            VaPart::Start(id) => Ok(WithStmts::new(
                vec![self.set_cursor_index(id, VA_CURSOR_FIRST)?],
                DaExpr::ConstInt(0),
            )),
            // C99 7.15.1.3p2: the object may not be used again until a new
            // `va_start`/`va_copy` initialises it.  Poisoning the cursor turns
            // a use after `va_end` into a located daScript range error rather
            // than a silent read of a stale index.
            VaPart::End(id) => Ok(WithStmts::new(
                vec![self.set_cursor_index(id, VA_CURSOR_ENDED)?],
                DaExpr::ConstInt(0),
            )),
            VaPart::Copy(dst, src) => Ok(WithStmts::new(
                vec![DaStmt::Expr(DaExpr::Assign(
                    Box::new(self.cursor_expr(dst)?),
                    Box::new(self.cursor_expr(src)?),
                ))],
                DaExpr::ConstInt(0),
            )),
        }
    }

    pub fn convert_vaarg(
        &self,
        _ctx: ExprContext,
        ty: CQualTypeId,
        val_id: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let Some(id) = self.va_decl_from_expr(val_id) else {
            return Err(format_translation_err!(self.ast_context.display_loc(&self.ast_context[val_id].loc), "unsupported va_arg cursor"));
        };
        if !self.is_va_decl(id) {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[val_id].loc),
                "va_arg uses a va_list without va_start"
            ));
        }
        let kind = &self.ast_context.resolve_type(ty.ctype).kind;
        let (field, output) = if kind.is_integral_type() || kind.is_enum() {
            ("i64", self.convert_type(ty)?)
        } else if matches!(
            kind,
            CTypeKind::Float | CTypeKind::Double | CTypeKind::LongDouble
        ) {
            ("f64", self.convert_type(ty)?)
        } else if kind.is_pointer() {
            ("raw", self.convert_type(ty)?)
        } else {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[val_id].loc),
                "unsupported va_arg type: {:?}",
                kind,
            ));
        };
        let cursor = self.cursor_expr(id)?;
        let item_name = self.renamer.borrow_mut().pick_name("c2da_va_item");
        let item = DaExpr::Index(
            Box::new(DaExpr::Var(
                self.function_context.borrow().get_va_list_arg_name().into(),
            )),
            Box::new(DaExpr::Field(Box::new(cursor.clone()), "index".into())),
        );
        let advance = DaExpr::Assign(
            Box::new(DaExpr::Field(Box::new(cursor.clone()), "index".into())),
            Box::new(DaExpr::Op2 {
                op: "+",
                left: Box::new(DaExpr::Field(Box::new(cursor), "index".into())),
                right: Box::new(DaExpr::ConstInt(1)),
            }),
        );
        let raw = DaExpr::Field(Box::new(DaExpr::Var(item_name.clone())), field.into());
        let value = if kind.is_pointer() {
            self.raw_address_to_pointer(raw, output)
        } else {
            DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(raw),
                to: output,
            }
        };
        Ok(WithStmts::new(
            vec![
                DaStmt::Var {
                    name: item_name,
                    var_type: self.va_arg_type(),
                    init: Some(item),
                },
                DaStmt::Expr(advance),
            ],
            value,
        ))
    }

    pub fn pack_variadic_argument(
        &self,
        expr_id: CExprId,
        value: DaExpr,
        ty: Option<CQualTypeId>,
    ) -> TranslationResult<DaExpr> {
        let Some(ty) = ty else {
            return Err(format_translation_err!(self.ast_context.display_loc(&self.ast_context[expr_id].loc), "unsupported variadic argument without C type"));
        };
        let kind = &self.ast_context.resolve_type(ty.ctype).kind;
        // The payload field's own type needs no conversion: a C value of a
        // type the translator stores as exactly `int64` (or `double`) is
        // already one.  Any other type is converted.
        let promoted = |value: DaExpr, to: DaType| -> TranslationResult<DaExpr> {
            if self.convert_type(ty)?.kind == to.kind {
                Ok(value)
            } else {
                Ok(DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(value),
                    to,
                })
            }
        };
        let (tag, integer, float, raw) = if kind.is_integral_type() || kind.is_enum() {
            (
                DaExpr::ConstInt(1),
                promoted(value, DaType::int64())?,
                DaExpr::ConstDouble(0.0),
                DaExpr::ConstUInt(0),
            )
        } else if matches!(
            kind,
            CTypeKind::Float | CTypeKind::Double | CTypeKind::LongDouble
        ) {
            (
                DaExpr::ConstInt(2),
                DaExpr::ConstInt(0),
                promoted(value, DaType::double())?,
                DaExpr::ConstUInt(0),
            )
        } else if kind.is_pointer() {
            (
                DaExpr::ConstInt(3),
                DaExpr::ConstInt(0),
                DaExpr::ConstDouble(0.0),
                self.pointer_to_raw_address(value),
            )
        } else {
            return Err(format_translation_err!(
                self.ast_context.display_loc(&self.ast_context[expr_id].loc),
                "unsupported variadic ABI argument type: {:?}",
                kind,
            ));
        };
        Ok(DaExpr::MakeStruct {
            type_name: "C2daVaArg".into(),
            fields: vec![
                ("tag".into(), tag),
                ("i64".into(), integer),
                ("f64".into(), float),
                ("raw".into(), raw),
            ],
        })
    }

    /// Own the trailing half of a C variadic call.  `functions.rs` decides
    /// where the direct C call boundary is; this module alone decides how the
    /// values cross the canonical payload ABI.
    pub fn pack_variadic_call_tail(
        &self,
        fixed_arity: usize,
        args: Vec<(CExprId, DaExpr)>,
    ) -> TranslationResult<Vec<DaExpr>> {
        args.into_iter()
            .skip(fixed_arity)
            .map(|(expr_id, value)| {
                self.pack_variadic_argument(
                    expr_id,
                    value,
                    self.ast_context[expr_id].kind.get_qual_type(),
                )
            })
            .collect()
    }
}

pub fn declarations() -> Vec<DaDecl> {
    vec![
        DaDecl::Structure(DaStructure {
            name: "C2daVaArg".into(),
            annotations: vec![],
            fields: vec![
                DaField {
                    name: "tag".into(),
                    field_type: DaType::int(),
                    default: None,
                },
                DaField {
                    name: "i64".into(),
                    field_type: DaType::int64(),
                    default: None,
                },
                DaField {
                    name: "f64".into(),
                    field_type: DaType::double(),
                    default: None,
                },
                DaField {
                    name: "raw".into(),
                    field_type: DaType::uint64(),
                    default: None,
                },
            ],
        }),
        DaDecl::Structure(DaStructure {
            name: "C2daVaCursor".into(),
            annotations: vec![],
            fields: vec![DaField {
                name: "index".into(),
                field_type: DaType::int(),
                default: None,
            }],
        }),
    ]
}
