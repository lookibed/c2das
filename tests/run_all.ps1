$root = "X:\c2dascript"
$daslang = "X:\..\daScript\bin\Release\daslang.exe"

$tests = @(
    @{n="t01_arith"; e=25},
    @{n="t02_mul_div"; e=21},
    @{n="t03_cmp"; e=10},
    @{n="t04_logical"; e=1},
    @{n="t05_if_elif"; e=0},
    @{n="t06_while"; e=55},
    @{n="t07_for"; e=55},
    @{n="t08_struct"; e=50},
    @{n="t09_enum"; e=40},
    @{n="t10_chain"; e=40},
    @{n="d01_basic"; e=5},
    @{n="d02_once"; e=11},
    @{n="d03_zero"; e=1},
    @{n="d04_break"; e=4},
    @{n="d05_continue"; e=9},
    @{n="d06_nested_do"; e=6},
    @{n="d07_do_while_var"; e=120},
    @{n="d08_do_in_while"; e=15},
    @{n="d09_continue_in_while"; e=4},
    @{n="d10_sum_do"; e=55},
    @{n="p01_ptr_deref"; e=42},
    @{n="p02_ptr_assign"; e=20},
    @{n="p04_arrow_basic"; e=30},
    @{n="p05_arrow_chain"; e=42},
    @{n="p06_ptr_to_ptr"; e=7},
    @{n="p08_arrow_func"; e=35},
    @{n="u01_unsafe_ptr"; e=42},
    @{n="u02_unsafe_write"; e=99},
    @{n="u03_unsafe_swap"; e=2010},
    @{n="s01_switch_basic"; e=20},
    @{n="s02_switch_default"; e=99},
    @{n="s03_switch_fallthrough"; e=20},
    @{n="g01_goto_basic"; e=0},
    @{n="g02_goto_loop"; e=15},
    @{n="g03_goto_forward"; e=1},
    @{n="t01_typedef_simple"; e=42},
    @{n="t02_typedef_ptr"; e=10},
    @{n="t03_typedef_struct"; e=12},
    @{n="c01_complex"; e=25},
    @{n="c01_const_int"; e=42},
    @{n="c02_const_ptr"; e=42},
    @{n="c03_ptr_to_const"; e=99},
    @{n="c05_const_struct_ptr"; e=25},
    @{n="c06_const_chain"; e=10},
    @{n="c07_const_assign"; e=10},
    @{n="c08_const_static"; e=100},
    @{n="c09_const_multi"; e=12},
    @{n="c10_const_mixed"; e=42}
)

Write-Host "=============================="
Write-Host "  c2dascript test suite"
Write-Host "=============================="

Write-Host "[1/3] Transpiling in WSL..."
wsl bash -c "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.cargo/bin && export LLVM_CONFIG_PATH=/usr/bin/llvm-config-18 && cd /root/c2dascript && cargo test -p c2dascript-transpile --test ten_tests 2>&1 | tail -5"

Write-Host "[2/3] Copying results..."
wsl bash /mnt/d/Backups/DockerTranslator/copy_das.sh

Write-Host "[3/3] Verifying with daslang..."
Write-Host ""

$pass = 0; $fail = 0
foreach ($t in $tests) {
    $name = $t.n
    $exp = $t.e
    $file = Join-Path $root "tests\syntax\$name.das"
    if (-not (Test-Path $file)) {
        Write-Host "  [SKIP] $name"
        continue
    }
    $p = Start-Process -FilePath $daslang -ArgumentList $file -NoNewWindow -Wait -PassThru
    if ($p.ExitCode -eq $exp) {
        Write-Host "  [PASS] $name = $($p.ExitCode)"
        $pass++
    } else {
        Write-Host "  [FAIL] $name = $($p.ExitCode) (expected $exp)"
        $fail++
    }
}

Write-Host ""
Write-Host "=============================="
if ($fail -eq 0) {
    Write-Host "  ALL $pass/$($tests.Count) PASSED"
} else {
    Write-Host "  $pass/$($tests.Count) passed, $fail failed"
}
Write-Host "=============================="
exit $fail
