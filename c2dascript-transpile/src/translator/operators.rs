//! Operator translation — полный порт c2rust operators.rs
use super::*;

impl<'c> Translation<'c> {
    /// Main binary expression handler.
    pub fn convert_binary_expr(
        &self,
        mut ctx: ExprContext,
        expr_type_id: CQualTypeId,
        op: CBinOp,
        lhs: CExprId,
        rhs: CExprId,
        opt_lhs_type_id: Option<CQualTypeId>,
        opt_rhs_type_id: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        use CBinOp::*;

        // Comma: value of LHS is discarded
        if matches!(op, Comma) {
            let _lhs = self.convert_expr(ctx.unused(), lhs, None)?;
            return self.convert_expr(ctx, rhs, Some(expr_type_id));
        }

        // Logical ops: &&, ||
        if op.is_logical() {
            let lhs_val = self.convert_condition(ctx, true, lhs)?;
            let rhs_val = self.convert_condition(ctx, true, rhs)?;
            let das_op = convert_binop(op).map_err(TranslationError::generic)?;
            return Ok(lhs_val
                .zip(rhs_val)
                .map(|(l, r)| mk().binary_op(das_op, l, r)));
        }

        // Assignment ops: =, +=, -=, etc.
        if op.is_assignment() {
            return self.convert_assignment_operator(
                ctx,
                op,
                expr_type_id,
                lhs,
                rhs,
                opt_lhs_type_id,
                opt_rhs_type_id,
            );
        }

        // Regular binary ops
        let is_ptr = self.is_pointer_type(expr_type_id.ctype);

        // daScript требует matching типов для всех операторов.
        // Если int + uint → cast<int>(uint) или cast<uint>(int)
        let lhs_expr_type_id = self.ast_context[lhs].kind.get_qual_type();
        let rhs_expr_type_id = self.ast_context[rhs].kind.get_qual_type();
        let lhs_type_id = lhs_expr_type_id
            .or_else(|| self.expr_operand_type(lhs))
            .or(opt_lhs_type_id);
        let rhs_type_id = rhs_expr_type_id
            .or_else(|| self.expr_operand_type(rhs))
            .or(opt_rhs_type_id);
        let lhs_kind = lhs_type_id.map(|q| self.ast_context.resolve_type(q.ctype).kind.clone());
        let rhs_kind = rhs_type_id.map(|q| self.ast_context.resolve_type(q.ctype).kind.clone());
        let lhs_is_uint = lhs_kind
            .as_ref()
            .map_or(false, |k| k.is_unsigned_integral_type());
        let rhs_is_uint = rhs_kind
            .as_ref()
            .map_or(false, |k| k.is_unsigned_integral_type());
        let lhs_is_int = lhs_kind
            .as_ref()
            .map_or(false, |k| k.is_signed_integral_type());
        let rhs_is_int = rhs_kind
            .as_ref()
            .map_or(false, |k| k.is_signed_integral_type());
        let needs_coerce = (lhs_is_uint && rhs_is_int) || (rhs_is_uint && lhs_is_int);

        let lhs_val = self.convert_expr(ctx, lhs, lhs_type_id)?;
        let rhs_val = self.convert_expr(ctx, rhs, rhs_type_id)?;
        let lhs_da_from_c = lhs_type_id
            .map(|q| self.convert_type(q).map(writable_type))
            .transpose()?;
        let rhs_da_from_c = rhs_type_id
            .map(|q| self.convert_type(q).map(writable_type))
            .transpose()?;
        let lhs_val = materialize_expr_type(lhs_val, lhs_da_from_c.as_ref());
        let rhs_val = materialize_expr_type(rhs_val, rhs_da_from_c.as_ref());
        // Storage bytes are not numeric daScript operands.  The canonical ABI
        // promotes them to uint before arithmetic and comparison operators.
        let lhs_val = self.lower_to_c_value(
            lhs_val,
            self.storage_byte_source_type(lhs).or(lhs_type_id),
            DaType::uint(),
            ValueSite::BinaryOperand,
        )?;
        let rhs_val = self.lower_to_c_value(
            rhs_val,
            self.storage_byte_source_type(rhs).or(rhs_type_id),
            DaType::uint(),
            ValueSite::BinaryOperand,
        )?;

        // Infer daScript types from the actual converted expressions (more accurate than C AST types,
        // because C type promotion can hide type mismatches that daScript rejects).
        let lhs_da = Self::infer_type(&lhs_val.val)
            .or(lhs_da_from_c.clone())
            .or_else(|| lhs_kind.as_ref().map(|k| type_kind_to_datype(k)));
        let rhs_da = Self::infer_type(&rhs_val.val)
            .or(rhs_da_from_c.clone())
            .or_else(|| rhs_kind.as_ref().map(|k| type_kind_to_datype(k)));

        // Check if either operand is a pointer (ptr - ptr returns int64, not pointer)
        let lhs_is_ptr = lhs_kind.as_ref().map_or(false, |k| k.is_pointer());
        let rhs_is_ptr = rhs_kind.as_ref().map_or(false, |k| k.is_pointer());
        let any_ptr = lhs_is_ptr || rhs_is_ptr;

        let width_mismatch = lhs_da.is_some()
            && rhs_da.is_some()
            && lhs_da != rhs_da
            && !is_ptr
            && !any_ptr
            && !matches!(op, CBinOp::Comma);

        let coerce_target = if width_mismatch { lhs_da.clone() } else { None };
        let (lhs_val, rhs_val) = if let Some(ref target) = coerce_target {
            (
                lhs_val,
                rhs_val.map(|v| DaExpr::Cast {
                    kind: das_ast::CastKind::Cast,
                    expr: Box::new(v),
                    to: target.clone(),
                }),
            )
        } else if needs_coerce {
            if lhs_is_uint {
                (
                    lhs_val,
                    rhs_val.map(|v| DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(v),
                        to: DaType::uint(),
                    }),
                )
            } else {
                (
                    lhs_val.map(|v| DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(v),
                        to: DaType::uint(),
                    }),
                    rhs_val,
                )
            }
        } else {
            (lhs_val, rhs_val)
        };
        // C comparison results are integer-like, whereas daScript comparison
        // expressions are bool.  A numeric coercion above may therefore have
        // produced `int(bool)`, which daScript rejects.  Lower it here, at the
        // binary-expression owner, before the enclosing operator consumes it.
        let lhs_val = self.bool_to_integer(lhs_val);
        let rhs_val = self.bool_to_integer(rhs_val);

        // Fallback: if LHS and RHS map to different daScript types, cast RHS to LHS type
        let type_diff =
            lhs_da.is_some() && rhs_da.is_some() && lhs_da != rhs_da && !is_ptr && !any_ptr;

        match op {
            EqualEqual | NotEqual if any_ptr => {
                let das_op = convert_binop(op).map_err(TranslationError::generic)?;
                Ok(lhs_val.zip(rhs_val).map(|(l, r)| {
                    DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                        op: das_op,
                        left: Box::new(self.abi_pointer_comparison_operand(l, lhs_is_ptr)),
                        right: Box::new(self.abi_pointer_comparison_operand(r, rhs_is_ptr)),
                    }))
                }))
            }
            Less | Greater | LessEqual | GreaterEqual if any_ptr => {
                let das_op = convert_binop(op).map_err(TranslationError::generic)?;
                Ok(lhs_val.zip(rhs_val).map(|(l, r)| {
                    DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                        op: das_op,
                        left: Box::new(self.abi_pointer_comparison_operand(l, lhs_is_ptr)),
                        right: Box::new(self.abi_pointer_comparison_operand(r, rhs_is_ptr)),
                    }))
                }))
            }
            Add => {
                let result = self.convert_addition(lhs_val, rhs_val, expr_type_id, lhs_is_ptr)?;
                if type_diff && !matches!(result.val, DaExpr::Unsafe(_)) {
                    let target = lhs_da.clone().unwrap();
                    Ok(result.map(|v| match v {
                        DaExpr::Op2 { op, left, right } => {
                            let right_cast = DaExpr::Cast {
                                kind: das_ast::CastKind::Cast,
                                expr: right,
                                to: target,
                            };
                            DaExpr::Op2 {
                                op,
                                left,
                                right: Box::new(right_cast),
                            }
                        }
                        v => v,
                    }))
                } else {
                    Ok(result)
                }
            }
            Subtract => {
                let sub = self.convert_subtraction(lhs_val, rhs_val, expr_type_id, lhs_is_ptr)?;
                let needs_unsafe = any_ptr && !matches!(sub.val, DaExpr::Unsafe(_));
                let sub = if needs_unsafe {
                    sub.map(|v| DaExpr::Unsafe(Box::new(v)))
                } else {
                    sub
                };
                if type_diff && !matches!(sub.val, DaExpr::Unsafe(_)) {
                    let target = lhs_da.clone().unwrap();
                    Ok(sub.map(|v| match v {
                        DaExpr::Op2 { op, left, right } => {
                            let right_cast = DaExpr::Cast {
                                kind: das_ast::CastKind::Cast,
                                expr: right,
                                to: target,
                            };
                            DaExpr::Op2 {
                                op,
                                left,
                                right: Box::new(right_cast),
                            }
                        }
                        v => v,
                    }))
                } else {
                    Ok(sub)
                }
            }
            ShiftLeft | ShiftRight => {
                // daScript << / >> требуют ОДИНАКОВЫЙ тип для обоих операндов,
                // и определены только для int/uint/int64/uint64.
                // Если LHS — меньший тип (int8, uint16...), поднимаем оба до int/uint.
                // Если типы разные (uint64 >> uint), приводим RHS к типу LHS.
                let das_op = convert_binop(op).map_err(TranslationError::generic)?;
                let target_da_type = coerce_shift_types(&lhs_kind, &rhs_kind);
                let (lhs_val, rhs_val) = if let Some(ty) = target_da_type {
                    let lhs_casted = lhs_val.map(|v| DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(v),
                        to: ty.clone(),
                    });
                    let rhs_casted = rhs_val.map(|v| DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(v),
                        to: ty,
                    });
                    (lhs_casted, rhs_casted)
                } else {
                    (lhs_val, rhs_val)
                };
                let combined = lhs_val
                    .zip(rhs_val)
                    .map(|(l, r)| mk().binary_op(das_op, l, r));
                Ok(if is_ptr {
                    combined.map(|v| DaExpr::Unsafe(Box::new(v)))
                } else {
                    combined
                })
            }
            _ => {
                let das_op = convert_binop(op).map_err(TranslationError::generic)?;
                // Late coercion: if inferred daScript types differ after all C-level
                // coercions, cast RHS to match LHS. This catches cases where C type
                // promotion hides the actual daScript type difference (e.g., uint == 0
                // where both sides are `uint` in C but `uint` vs `int` in daScript).
                let lhs_inf = Self::infer_type(&lhs_val.val)
                    .or(lhs_da_from_c.clone())
                    .or_else(|| lhs_kind.as_ref().map(|k| type_kind_to_datype(k)));
                let rhs_inf = Self::infer_type(&rhs_val.val)
                    .or(rhs_da_from_c.clone())
                    .or_else(|| rhs_kind.as_ref().map(|k| type_kind_to_datype(k)));
                let (lhs_val, rhs_val) = if let (Some(ref lt), Some(ref rt)) = (lhs_inf, rhs_inf) {
                    if lt != rt && !is_ptr && !matches!(op, CBinOp::Comma) {
                        (
                            lhs_val,
                            rhs_val.map(|v| DaExpr::Cast {
                                kind: das_ast::CastKind::Cast,
                                expr: Box::new(v),
                                to: lt.clone(),
                            }),
                        )
                    } else {
                        (lhs_val, rhs_val)
                    }
                } else {
                    (lhs_val, rhs_val)
                };
                let combined = lhs_val
                    .zip(rhs_val)
                    .map(|(l, r)| mk().binary_op(das_op, l, r));
                Ok(if is_ptr {
                    combined.map(|v| DaExpr::Unsafe(Box::new(v)))
                } else {
                    combined
                })
            }
        }
    }

    fn expr_operand_type(&self, expr_id: CExprId) -> Option<CQualTypeId> {
        match &self.ast_context[expr_id].kind {
            CExprKind::Member(_, _, field_id, _, _) => match &self.ast_context[*field_id].kind {
                CDeclKind::Field { typ, .. } => Some(*typ),
                _ => self.ast_context[expr_id].kind.get_qual_type(),
            },
            CExprKind::DeclRef(_, decl_id, _) => match &self.ast_context[*decl_id].kind {
                CDeclKind::Variable { typ, .. } | CDeclKind::Field { typ, .. } => Some(*typ),
                _ => self.ast_context[expr_id].kind.get_qual_type(),
            },
            _ => self.ast_context[expr_id].kind.get_qual_type(),
        }
    }

    fn storage_byte_source_type(&self, expr_id: CExprId) -> Option<CQualTypeId> {
        let source = match &self.ast_context[expr_id].kind {
            CExprKind::ImplicitCast(_, inner, _, _, _) => self.storage_byte_source_type(*inner),
            _ => self.ast_context[expr_id].kind.get_qual_type(),
        }?;
        matches!(
            self.ast_context.resolve_type(source.ctype).kind,
            CTypeKind::UInt8 | CTypeKind::UChar
        )
        .then_some(source)
    }

    /// Handle assignment operator.
    /// Разворачивает chain assignment (a=b=c) и if-as-expression (x=if(c)a else b)
    fn convert_assignment_operator(
        &self,
        ctx: ExprContext,
        op: CBinOp,
        expr_type_id: CQualTypeId,
        lhs: CExprId,
        rhs: CExprId,
        compute_lhs_type_id: Option<CQualTypeId>,
        _compute_res_type_id: Option<CQualTypeId>,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let is_used = ctx.used;
        let lhs_type_id = compute_lhs_type_id
            .or_else(|| self.ast_context[lhs].kind.get_qual_type())
            .unwrap_or(expr_type_id);
        let lhs_kind = self
            .ast_context
            .resolve_type(lhs_type_id.ctype)
            .kind
            .clone();
        let lhs_da_type = self.convert_type(lhs_type_id)?;

        // Address-backed member writes need their own store operation: a
        // packed C field cannot be represented by a daScript lvalue at all.
        // Keep the address as a first-class object until `raw_store` selects
        // typed indexing or statement-level memcpy.
        if let CExprKind::Member(_, base_expr, field, MemberKind::Arrow, _) = self.ast_context[lhs].kind {
            let rhs_id = rhs;
            let base_ty = self.ast_context[base_expr].kind.get_qual_type()
                .ok_or_else(|| TranslationError::generic("member pointer has no C type"))?;
            let base = self.convert_expr(ctx.used(), base_expr, Some(base_ty))?;
            let address = self.pointer_member_address(base.clone(), base_ty, field)?;
            let is_bitfield = matches!(self.ast_context[field].kind, CDeclKind::Field { bitfield_width: Some(_), .. });
            if op == CBinOp::Assign {
                let rhs = self.convert_expr(ctx.used(), rhs_id, Some(lhs_type_id))?;
                let rhs = self.lower_to_c_value(
                    rhs,
                    self.ast_context[rhs_id].kind.get_qual_type(),
                    lhs_da_type,
                    ValueSite::Assignment,
                )?;
                return if is_bitfield { self.bitfield_store(address, field, rhs) } else { self.raw_store(address, rhs) };
            }
            let inner_op = op.underlying_assignment()
                .ok_or_else(|| TranslationError::generic("not a compound assignment"))?;
            let das_op = convert_binop(inner_op).map_err(TranslationError::generic)?;
            let current = if is_bitfield { self.bitfield_load(address, field)? } else { self.raw_load(address)? };
            let rhs = self.convert_expr(ctx.used(), rhs_id, Some(lhs_type_id))?;
            let value = current.zip(rhs).map(|(left, right)| mk().binary_op(das_op, left, right));
            // Reconstruct the field address from the single evaluated base.
            // `raw_store` is given the same C address facts, never a
            // daScript field expression.
            let address = self.pointer_member_address(base, base_ty, field)?;
            return if is_bitfield { self.bitfield_store(address, field, value) } else { self.raw_store(address, value) };
        }
        let lhs_val = self.convert_expr(ctx, lhs, Some(lhs_type_id))?;

        if op != CBinOp::Assign {
            // Compound: a += b → a = a + b
            let inner_op = op
                .underlying_assignment()
                .ok_or_else(|| TranslationError::generic("not a compound assignment"))?;
            let das_op = convert_binop(inner_op).map_err(TranslationError::generic)?;
            let is_ptr_op = lhs_kind.is_pointer() || self.is_pointer_type(lhs_type_id.ctype);
            let rhs_val =
                self.convert_expr(ctx, rhs, if is_ptr_op { None } else { Some(lhs_type_id) })?;
            return Ok(lhs_val.zip(rhs_val).and_then(|(l, r)| {
                let binop = mk().binary_op(das_op, l.clone(), r);
                let assigned_value = if is_ptr_op {
                    self.coerce_assignment_value(
                        DaExpr::Unsafe(Box::new(binop)),
                        &lhs_kind,
                        &lhs_da_type,
                    )
                } else {
                    self.coerce_assignment_value(binop, &lhs_kind, &lhs_da_type)
                };
                let assign = DaExpr::Assign(Box::new(l.clone()), Box::new(assigned_value));
                lower_assignment_expr(assign, l, is_used)
            }));
        }

        // Chain assignment: a = b = c → b = c; a = b
        let mut rhs_val = self.convert_expr(ctx, rhs, Some(lhs_type_id))?;
        if let Some(stripped_rhs) =
            self.strip_const_deref_assignment_rhs(ctx, rhs, lhs_type_id, &lhs_da_type)?
        {
            rhs_val = stripped_rhs;
        }
        rhs_val = self.lower_to_c_value(
            rhs_val,
            self.ast_context[rhs].kind.get_qual_type(),
            lhs_da_type.clone(),
            ValueSite::Assignment,
        )?;
        if let DaExpr::Assign(inner_lhs, inner_rhs) = &rhs_val.val {
            let mut stmts = lhs_val.stmts;
            stmts.extend(rhs_val.stmts.clone());
            stmts.push(DaStmt::Expr(DaExpr::Assign(
                Box::new(*inner_lhs.clone()),
                Box::new(*inner_rhs.clone()),
            )));
            let lhs_expr = lhs_val.val;
            let assign = DaExpr::Assign(Box::new(lhs_expr.clone()), Box::new(*inner_lhs.clone()));
            return Ok(lower_assignment_expr(assign, lhs_expr, is_used)
                .prepend_stmts(stmts)
                .merge_unsafe(lhs_val.is_unsafe || rhs_val.is_unsafe));
        }

        // if-as-expression в RHS: x = if (c) a else b
        // → var __tmp; if (c) __tmp = a else __tmp = b; x = __tmp
        if let DaExpr::IfThenElse {
            cond,
            then,
            elifs,
            else_,
        } = &rhs_val.val
        {
            let mut stmts = lhs_val.stmts;
            stmts.extend(rhs_val.stmts.clone());
            let tmp = "_tmp_assign";
            let tmp_var = DaExpr::Var(tmp.to_string());
            // Создаём if-else STATEMENT (не expression) с присваиванием во временную
            let then_assign = DaStmt::Expr(DaExpr::Assign(
                Box::new(tmp_var.clone()),
                Box::new(*then.clone()),
            ));
            let else_assign = else_.as_ref().map(|el| {
                DaStmt::Expr(DaExpr::Assign(
                    Box::new(tmp_var.clone()),
                    Box::new(*el.clone()),
                ))
            });

            if let Some(el_assign) = else_assign {
                stmts.push(DaStmt::Var {
                    name: tmp.to_string(),
                    var_type: DaType::int(),
                    init: Some(*then.clone()),
                });
                stmts.push(DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(*cond.clone()),
                    then: Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![then_assign],
                    })),
                    elifs: elifs.clone(),
                    else_: Some(Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![el_assign],
                    }))),
                }));
            } else {
                stmts.push(DaStmt::Expr(DaExpr::IfThenElse {
                    cond: Box::new(*cond.clone()),
                    then: Box::new(DaExpr::Block(DaBlock {
                        stmts: vec![then_assign],
                    })),
                    elifs: elifs.clone(),
                    else_: None,
                }));
            }

            let lhs_expr = lhs_val.val;
            let assign = DaExpr::Assign(Box::new(lhs_expr.clone()), Box::new(tmp_var));
            return Ok(lower_assignment_expr(assign, lhs_expr, is_used)
                .prepend_stmts(stmts)
                .merge_unsafe(lhs_val.is_unsafe || rhs_val.is_unsafe));
        }

        let mut stmts = lhs_val.stmts;
        stmts.extend(rhs_val.stmts);
        let lhs_expr = lhs_val.val;
        let rhs_expr = self.coerce_assignment_value(rhs_val.val, &lhs_kind, &lhs_da_type);
        let assign = DaExpr::Assign(Box::new(lhs_expr.clone()), Box::new(rhs_expr));
        Ok(lower_assignment_expr(assign, lhs_expr, is_used)
            .prepend_stmts(stmts)
            .merge_unsafe(lhs_val.is_unsafe || rhs_val.is_unsafe))
    }

    fn strip_const_deref_assignment_rhs(
        &self,
        ctx: ExprContext,
        rhs: CExprId,
        expr_type_id: CQualTypeId,
        lhs_da_type: &DaType,
    ) -> TranslationResult<Option<WithStmts<DaExpr>>> {
        if !matches!(lhs_da_type.kind, DaTypeKind::Named(_)) {
            return Ok(None);
        }
        let Some(ptr_expr) = self.const_deref_pointer_expr(rhs) else {
            return Ok(None);
        };
        let Some(ptr_qty) = self.ast_context[ptr_expr].kind.get_qual_type() else {
            return Ok(None);
        };
        let CTypeKind::Pointer(pointee) = self.ast_context.resolve_type(ptr_qty.ctype).kind else {
            return Ok(None);
        };
        if !pointee.qualifiers.is_const {
            return Ok(None);
        }
        let target_ty = self.convert_type(expr_type_id)?;
        if writable_type(target_ty.clone()) != writable_type(lhs_da_type.clone()) {
            return Ok(None);
        }
        let ptr_val = self.convert_expr(ctx.used(), ptr_expr, None)?;
        let mutable_ptr_ty = DaType::pointer(writable_type(target_ty));
        Ok(Some(
            WithStmts::new_val(DaExpr::Unsafe(Box::new(DaExpr::Deref(Box::new(
                self.abi_pointer_cast(ptr_val.val, mutable_ptr_ty),
            )))))
            .prepend_stmts(ptr_val.stmts)
            .merge_unsafe(true),
        ))
    }

    fn const_deref_pointer_expr(&self, expr: CExprId) -> Option<CExprId> {
        match self.ast_context[expr].kind {
            CExprKind::Unary(_, CUnOp::Deref, ptr_expr, _) => Some(ptr_expr),
            CExprKind::ImplicitCast(_, inner, _, _, _)
            | CExprKind::ExplicitCast(_, inner, _, _, _)
            | CExprKind::Paren(_, inner) => self.const_deref_pointer_expr(inner),
            _ => None,
        }
    }

    /// Addition with pointer arithmetic support and type coercion.
    fn convert_addition(
        &self,
        lhs: WithStmts<DaExpr>,
        rhs: WithStmts<DaExpr>,
        expr_type_id: CQualTypeId,
        lhs_is_ptr: bool,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let is_ptr_lhs = lhs_is_ptr || self.is_pointer_type(expr_type_id.ctype);
        if is_ptr_lhs {
            Ok(lhs.zip(rhs).map(|(l, r)| {
                if let DaExpr::Unsafe(inner) = l {
                    if let DaExpr::Op2 {
                        op: "+",
                        left,
                        right,
                    } = *inner
                    {
                        return DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                            op: "+",
                            left,
                            right: Box::new(DaExpr::Op2 {
                                op: "+",
                                left: right,
                                right: Box::new(r),
                            }),
                        }));
                    }
                    return DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                        op: "+",
                        left: Box::new(DaExpr::Unsafe(inner)),
                        right: Box::new(r),
                    }));
                }
                DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                    op: "+",
                    left: Box::new(l),
                    right: Box::new(normalize_numeric_binop_tree(r)),
                }))
            }))
        } else {
            // Inline type coercion: if RHS is clearly a different type than LHS, wrap RHS in cast
            let lhs_ty = Self::infer_type(&lhs.val);
            let rhs_ty = Self::infer_type(&rhs.val);
            if let (Some(lt), Some(rt)) = (&lhs_ty, &rhs_ty) {
                if lt != rt {
                    return Ok(lhs.zip(rhs).map(|(l, r)| {
                        let r_casted = DaExpr::Cast {
                            kind: das_ast::CastKind::Cast,
                            expr: Box::new(r),
                            to: lt.clone(),
                        };
                        mk().binary_op("+", l, r_casted)
                    }));
                }
            }
            Ok(lhs.zip(rhs).map(|(l, r)| mk().binary_op("+", l, r)))
        }
    }

    pub(crate) fn infer_type(expr: &DaExpr) -> Option<DaType> {
        match expr {
            DaExpr::ConstInt(_) => Some(DaType::int()),
            DaExpr::ConstUInt(_) => Some(DaType::uint()),
            DaExpr::Cast { to, .. } => Some(to.clone()),
            DaExpr::Unsafe(inner) => Self::infer_type(inner),
            DaExpr::Op2 { op, left, .. }
                if matches!(*op, "==" | "!=" | "<" | ">" | "<=" | ">=" | "&&" | "||") =>
            {
                Some(DaType::bool())
            }
            DaExpr::Op2 { left, .. } => Self::infer_type(left),
            DaExpr::Op1 { expr: inner, .. } => Self::infer_type(inner),
            _ => None,
        }
    }

    /// Subtraction with pointer arithmetic support.
    /// `is_ptr_op` is true if either operand is a pointer type.
    fn convert_subtraction(
        &self,
        lhs: WithStmts<DaExpr>,
        rhs: WithStmts<DaExpr>,
        expr_type_id: CQualTypeId,
        lhs_is_ptr: bool,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let is_ptr_ret = lhs_is_ptr || self.is_pointer_type(expr_type_id.ctype);
        if matches!(lhs.val, DaExpr::Unsafe(_)) {
            return Ok(lhs.zip(rhs).map(|(l, r)| match l {
                DaExpr::Unsafe(inner) => match *inner {
                    DaExpr::Op2 {
                        op: "+",
                        left,
                        right,
                    } => DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                        op: "+",
                        left,
                        right: Box::new(DaExpr::Op2 {
                            op: "-",
                            left: right,
                            right: Box::new(r),
                        }),
                    })),
                    inner => DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                        op: "-",
                        left: Box::new(inner),
                        right: Box::new(r),
                    })),
                },
                l => DaExpr::Op2 {
                    op: "-",
                    left: Box::new(l),
                    right: Box::new(r),
                },
            }));
        }
        if is_ptr_ret {
            Ok(lhs.zip(rhs).map(|(l, r)| {
                if let DaExpr::Unsafe(inner) = l {
                    if let DaExpr::Op2 {
                        op: "+",
                        left,
                        right,
                    } = *inner
                    {
                        return DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                            op: "+",
                            left,
                            right: Box::new(DaExpr::Op2 {
                                op: "-",
                                left: right,
                                right: Box::new(r),
                            }),
                        }));
                    }
                    return DaExpr::Unsafe(inner);
                }
                DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                    op: "-",
                    left: Box::new(l),
                    right: Box::new(r),
                }))
            }))
        } else {
            let lhs_ty = Self::infer_type(&lhs.val);
            let rhs_ty = Self::infer_type(&rhs.val);
            if let (Some(lt), Some(rt)) = (&lhs_ty, &rhs_ty) {
                if lt != rt {
                    return Ok(lhs.zip(rhs).map(|(l, r)| {
                        let r_casted = DaExpr::Cast {
                            kind: das_ast::CastKind::Cast,
                            expr: Box::new(r),
                            to: lt.clone(),
                        };
                        mk().binary_op("-", l, r_casted)
                    }));
                }
            }
            Ok(lhs.zip(rhs).map(|(l, r)| mk().binary_op("-", l, r)))
        }
    }

    pub fn convert_unary_operator(
        &self,
        ctx: ExprContext,
        name: CUnOp,
        cqual_type: CQualTypeId,
        arg: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        use CUnOp::*;
        match name {
            AddressOf => {
                let inner = self.convert_expr(ctx, arg, Some(cqual_type))?;
                // Simplify addr(*ptr) → ptr: cancel the Deref+Addr pair.
                // This avoids broken unsafe() scoping where daslang can't see
                // that a pointer index inside Deref(Addr(...)) is actually
                // inside unsafe(). Without this, 31023 fires on nested patterns
                // like unsafe(addr(*blockDc[0])).
                let val = match inner.val {
                    DaExpr::Deref(ptr) => *ptr,
                    _ => DaExpr::Addr(Box::new(inner.val)),
                };
                Ok(WithStmts::new_val(DaExpr::Unsafe(Box::new(val))).prepend_stmts(inner.stmts))
            }
            Deref => {
                let inner = self.convert_expr(ctx, arg, Some(cqual_type))?;
                Ok(WithStmts::new_val(DaExpr::Deref(Box::new(inner.val)))
                    .prepend_stmts(inner.stmts))
            }
            Negate => self.convert_negate_operator(ctx, cqual_type, arg),
            Plus => self.convert_expr(ctx.used(), arg, Some(cqual_type)),
            Not => {
                // daScript `!` works only on bool. For non-bool, generate `expr == 0` / `expr == null`.
                let arg_ty_opt = self.ast_context[arg].kind.get_qual_type();
                let val = self.convert_expr(ctx.used(), arg, arg_ty_opt)?;
                if let Some(qty) = arg_ty_opt {
                    if self.is_pointer_type(qty.ctype) {
                        let null = self.null_for_type(qty)?;
                        return Ok(val.map(|v| DaExpr::Op2 {
                            op: "==",
                            left: Box::new(v),
                            right: Box::new(null),
                        }));
                    }
                    let resolved_kind = self.ast_context.resolve_type(qty.ctype).kind.clone();
                    if resolved_kind.is_integral_type() {
                        return Ok(val.map(|v| DaExpr::Op2 {
                            op: "==",
                            left: Box::new(v),
                            right: Box::new(DaExpr::ConstInt(0)),
                        }));
                    }
                    if matches!(resolved_kind, CTypeKind::Enum(_)) {
                        return Ok(val.map(|v| DaExpr::Op2 {
                            op: "==",
                            left: Box::new(DaExpr::Cast {
                                kind: das_ast::CastKind::Cast,
                                expr: Box::new(v),
                                to: DaType::uint(),
                            }),
                            right: Box::new(DaExpr::Cast {
                                kind: das_ast::CastKind::Cast,
                                expr: Box::new(DaExpr::ConstInt(0)),
                                to: DaType::uint(),
                            }),
                        }));
                    }
                }
                // bool or unknown: apply `!` directly
                Ok(val.map(|v| mk().unary_op("!", v)))
            }
            Complement => {
                let inner = self.convert_expr(ctx, arg, Some(cqual_type))?;
                Ok(inner.map(|v| mk().unary_op("~", v)))
            }
            Extension => self.convert_expr(ctx, arg, Some(cqual_type)),
            PreIncrement => self.convert_pre_increment(ctx, cqual_type, CBinOp::AssignAdd, arg),
            PreDecrement => {
                self.convert_pre_increment(ctx, cqual_type, CBinOp::AssignSubtract, arg)
            }
            PostIncrement => self.convert_post_increment(ctx, cqual_type, CBinOp::AssignAdd, arg),
            PostDecrement => {
                self.convert_post_increment(ctx, cqual_type, CBinOp::AssignSubtract, arg)
            }
            Real | Imag | Coawait => Err(TranslationError::generic("unsupported unary operator")),
        }
    }

    /// Negation with literal optimization.
    fn convert_negate_operator(
        &self,
        ctx: ExprContext,
        expr_type_id: CQualTypeId,
        arg_id: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let val = self.convert_expr(ctx.used(), arg_id, Some(expr_type_id))?;
        Ok(val.map(|v| mk().unary_op("-", v)))
    }

    pub fn convert_pre_increment(
        &self,
        ctx: ExprContext,
        ty: CQualTypeId,
        op: CBinOp,
        arg: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        let inner = self.convert_expr(ctx.used(), arg, Some(ty))?;
        // daScript requires matching types: if target is uint64/size_t, 1 must be uint64(1)
        let resolved = self.ast_context.resolve_type(ty.ctype);
        let target_da = type_kind_to_datype(&resolved.kind);
        let is_ptr = self.is_pointer_type(ty.ctype);
        let one = if matches!(
            target_da.kind,
            DaTypeKind::Int | DaTypeKind::Int8 | DaTypeKind::Int16
        ) {
            DaExpr::ConstInt(1)
        } else {
            DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(DaExpr::ConstInt(1)),
                to: target_da,
            }
        };
        let das_op = match op {
            CBinOp::AssignAdd => "+",
            CBinOp::AssignSubtract => "-",
            _ => return Err(TranslationError::generic("invalid pre-increment op")),
        };
        let rhs = if is_ptr {
            DaExpr::Unsafe(Box::new(DaExpr::Op2 {
                op: das_op,
                left: Box::new(inner.val.clone()),
                right: Box::new(one),
            }))
        } else {
            DaExpr::Op2 {
                op: das_op,
                left: Box::new(inner.val.clone()),
                right: Box::new(one),
            }
        };
        let inc_stmt = DaStmt::Expr(DaExpr::Assign(Box::new(inner.val.clone()), Box::new(rhs)));
        Ok(WithStmts {
            stmts: vec![inc_stmt],
            val: inner.val,
            is_unsafe: inner.is_unsafe,
        })
    }

    pub fn convert_post_increment(
        &self,
        ctx: ExprContext,
        ty: CQualTypeId,
        op: CBinOp,
        arg: CExprId,
    ) -> TranslationResult<WithStmts<DaExpr>> {
        // Для x++ достаточно x += 1 (значение редко используется)
        // C post-increment returns the old value. Materialize it before the
        // assignment, rather than treating x++ as pre-increment.
        let inner = self.convert_expr(ctx.used(), arg, Some(ty))?;
        let target_da = type_kind_to_datype(&self.ast_context.resolve_type(ty.ctype).kind);
        let old_name = self.renamer.borrow_mut().pick_name("c2da_postinc");
        let old = DaExpr::Var(old_name.clone());
        let one = if matches!(target_da.kind, DaTypeKind::Int | DaTypeKind::Int8 | DaTypeKind::Int16) {
            DaExpr::ConstInt(1)
        } else {
            DaExpr::Cast { kind: das_ast::CastKind::Cast, expr: Box::new(DaExpr::ConstInt(1)), to: target_da.clone() }
        };
        let das_op = match op {
            CBinOp::AssignAdd => "+",
            CBinOp::AssignSubtract => "-",
            _ => return Err(TranslationError::generic("invalid post-increment op")),
        };
        let rhs = if self.is_pointer_type(ty.ctype) {
            DaExpr::Unsafe(Box::new(DaExpr::Op2 { op: das_op, left: Box::new(inner.val.clone()), right: Box::new(one) }))
        } else {
            DaExpr::Op2 { op: das_op, left: Box::new(inner.val.clone()), right: Box::new(one) }
        };
        let mut stmts = inner.stmts;
        stmts.push(DaStmt::Var { name: old_name, var_type: target_da, init: Some(inner.val.clone()) });
        stmts.push(DaStmt::Expr(DaExpr::Assign(Box::new(inner.val), Box::new(rhs))));
        Ok(WithStmts { stmts, val: old, is_unsafe: inner.is_unsafe })
    }
}

fn normalize_numeric_binop_tree(expr: DaExpr) -> DaExpr {
    match expr {
        DaExpr::Op2 { op, left, right }
            if matches!(op, "+" | "-" | "*" | "/" | "%" | "<<" | ">>") =>
        {
            let left = normalize_numeric_binop_tree(*left);
            let right = normalize_numeric_binop_tree(*right);
            let right = match (
                Translation::infer_type(&left),
                Translation::infer_type(&right),
            ) {
                (Some(lt), Some(rt)) if lt.is_numeric() && rt.is_numeric() && lt != rt => {
                    DaExpr::Cast {
                        kind: das_ast::CastKind::Cast,
                        expr: Box::new(right),
                        to: lt,
                    }
                }
                _ => right,
            };
            DaExpr::Op2 {
                op,
                left: Box::new(left),
                right: Box::new(right),
            }
        }
        DaExpr::Unsafe(inner) => DaExpr::Unsafe(Box::new(normalize_numeric_binop_tree(*inner))),
        DaExpr::Cast { kind, expr, to } => DaExpr::Cast {
            kind,
            expr: Box::new(normalize_numeric_binop_tree(*expr)),
            to,
        },
        other => other,
    }
}

fn lower_assignment_expr(assign: DaExpr, result: DaExpr, is_used: bool) -> WithStmts<DaExpr> {
    if is_used {
        WithStmts::new(vec![DaStmt::Expr(assign)], result)
    } else {
        WithStmts::new_val(assign)
    }
}

fn materialize_expr_type(expr: WithStmts<DaExpr>, target: Option<&DaType>) -> WithStmts<DaExpr> {
    let Some(target) = target else {
        return expr;
    };
    if !target.is_numeric() || matches!(target.kind, DaTypeKind::Auto) {
        return expr;
    }
    if Translation::infer_type(&expr.val).is_some() {
        return expr;
    }
    let should_cast = matches!(
        expr.val,
        DaExpr::Var(_)
            | DaExpr::Field(_, _)
            | DaExpr::SafeField(_, _)
            | DaExpr::Index(_, _)
            | DaExpr::SafeIndex(_, _)
            | DaExpr::Deref(_)
            | DaExpr::DerefExplicit(_)
    );
    if should_cast {
        expr.map(|v| DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(v),
            to: target.clone(),
        })
    } else {
        expr
    }
}

/// Returns the daScript type to coerce both shift operands to, if needed.
/// daScript `<<`/`>>` only works for int32/uint32/int64/uint64 with matching types.
fn coerce_shift_types(lhs: &Option<CTypeKind>, rhs: &Option<CTypeKind>) -> Option<DaType> {
    use CTypeKind::*;
    let l = lhs.as_ref()?;
    // Determine the "width" of the LHS type — what daScript type should we use?
    // Smaller types (int8/uint8/int16/uint16) need widening to int or uint.
    // If LHS and RHS are different widths, coerce both to the wider type.
    if matches!(l, Int8 | SChar | Char | UInt8 | UChar | Int16 | UInt16) {
        // Small types: widen to 32-bit, preserving signedness
        Some(if l.is_unsigned_integral_type() {
            DaType::uint()
        } else {
            DaType::int()
        })
    } else if matches!(
        l,
        Int | Short | Int32 | UInt | UInt32 | Int64 | Long | LongLong | UInt64 | ULong | ULongLong
    ) {
        // Already a supported shift type. If RHS differs, coerce RHS to LHS.
        // Check if RHS matches the same daScript type.
        if let Some(r) = rhs {
            let lhs_da = type_kind_to_datype(l);
            let rhs_da = type_kind_to_datype(r);
            if lhs_da != rhs_da {
                Some(lhs_da)
            } else {
                None // already matching
            }
        } else {
            None
        }
    } else {
        None
    }
}

impl<'c> Translation<'c> {
fn coerce_assignment_value(
    &self,
    expr: DaExpr,
    target_kind: &CTypeKind,
    target_da_type: &DaType,
) -> DaExpr {
    if matches!(target_da_type.kind, DaTypeKind::Pointer(_)) && !matches!(expr, DaExpr::ConstNull) {
        return self.abi_pointer_cast(expr, target_da_type.clone());
    }
    if target_da_type.is_numeric() && !matches!(target_da_type.kind, DaTypeKind::Auto) {
        let mut target = target_da_type.clone();
        target.is_const = false;
        target.is_ref = false;
        target.is_temporary = false;
        if Translation::infer_type(&expr)
            .map(|mut inferred| {
                inferred.is_const = false;
                inferred.is_ref = false;
                inferred.is_temporary = false;
                inferred != target
            })
            .unwrap_or(false)
        {
            return DaExpr::Cast {
                kind: das_ast::CastKind::Cast,
                expr: Box::new(expr),
                to: target,
            };
        }
    }
    // Only cast when target type differs from default int32 (the type of integer literals).
    // This avoids redundant `cast<int>(10)` while still catching `uint = 10` → `uint(10)`.
    let needs_cast = target_kind.is_integral_type()
        && !matches!(
            target_kind,
            CTypeKind::Bool
                | CTypeKind::Int
                | CTypeKind::SChar
                | CTypeKind::Char
                | CTypeKind::Short
                | CTypeKind::Int32
                | CTypeKind::Int8
                | CTypeKind::Int16
        );
    if needs_cast {
        DaExpr::Cast {
            kind: das_ast::CastKind::Cast,
            expr: Box::new(expr),
            to: target_da_type.clone(),
        }
    } else {
        expr
    }
}
}

