//! Canonical C variadic ABI lowering.
//!
//! daScript does not expose the platform `va_list` ABI.  A C variadic call
//! instead carries an explicit array of promoted tagged values; a local
//! `va_list` is a cursor over that array.  This module owns that boundary.
use super::*;
use crate::format_translation_err;

const VA_ARGS_PARAM: &str = "c2da_va_args";

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

    pub fn register_va_decls(&self, body: CStmtId) -> String {
        let mut decls = IndexSet::new();
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

    fn va_decl_from_expr(&self, mut expr: CExprId) -> Option<CDeclId> {
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
                fields: vec![("index".into(), DaExpr::ConstInt(0))],
            }),
        }))
    }

    pub(crate) fn va_cursor_initializer(&self) -> DaExpr {
        DaExpr::MakeStruct {
            type_name: "C2daVaCursor".into(),
            fields: vec![("index".into(), DaExpr::ConstInt(0))],
        }
    }

    fn cursor_expr(&self, id: CDeclId) -> TranslationResult<DaExpr> {
        let CDeclKind::Variable { ident, .. } = &self.ast_context[id].kind else { return Err(TranslationError::generic("unsupported va_list declaration")); };
        Ok(DaExpr::Var(self.declare_value_name(id, ident)))
    }

    pub fn convert_vapart(&self, part: VaPart) -> TranslationResult<WithStmts<DaExpr>> {
        match part {
            VaPart::Start(_) | VaPart::End(_) => Ok(WithStmts::new_val(DaExpr::ConstInt(0))),
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
        let (tag, integer, float, raw) = if kind.is_integral_type() || kind.is_enum() {
            (
                DaExpr::ConstInt(1),
                DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(value),
                    to: DaType::int64(),
                },
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
                DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(value),
                    to: DaType::double(),
                },
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
