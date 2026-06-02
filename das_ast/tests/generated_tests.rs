use das_ast::*;

fn normalize_newlines(s: &str) -> String {
    s.replace("\r\n", "\n")
}

fn assert_output(name: &str, module: DaModule) {
    let das_path = format!("{}/../tests/syntax/{}.das", env!("CARGO_MANIFEST_DIR"), name);
    let expected = normalize_newlines(&std::fs::read_to_string(&das_path)
        .unwrap_or_else(|_| panic!("missing syntax file: {}", das_path)));
    let actual = module.to_string();
    if actual != expected {
        eprintln!("=== EXPECTED ({}) === bytes: {:?}", das_path, expected.as_bytes());
        eprintln!("{}", expected);
        eprintln!("=== ACTUAL === bytes: {:?}", actual.as_bytes());
        eprintln!("{}", actual);
        panic!("output mismatch for {}", name);
    }
}

#[test]
fn test_00_const() {
    let module = DaModule {
        name: None,
        options: vec!["gen2".into()],
        requires: vec![],
        decls: vec![DaDecl::Function(DaFunction {
            name: "add".into(),
            params: vec![
                DaStmt::Param { name: "a".into(), param_type: DaType::Int, default: None },
                DaStmt::Param { name: "b".into(), param_type: DaType::Int, default: None },
            ],
            ret_type: DaType::Int,
            body: Some(DaExpr::Block(DaBlock {
                stmts: vec![
                    DaStmt::Expr(DaExpr::Return(Some(Box::new(DaExpr::Op2 {
                        op: "+",
                        left: Box::new(DaExpr::Var("a".into())),
                        right: Box::new(DaExpr::Var("b".into())),
                    })))),
                ],
            })),
            annotations: vec![],
            is_public: false,
            is_unsafe: false,
        })],
    };
    assert_output("00_const", module);
}
