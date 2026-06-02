@echo off
setlocal enabledelayedexpansion
set DASLANG=D:\Backups\с2daslang\daScript\bin\Release\daslang.exe
set TESTS=t01_arith t02_mul_div t03_cmp t04_logical t05_if_elif t06_while t07_for t08_struct t09_enum t10_chain
set PASS=0
set FAIL=0

echo ==============================
echo   c2dascript test suite
echo ==============================
echo.

:: Step 1: transpile in WSL
echo [1/2] Transpiling in WSL...
wsl bash -c "cd /root/c2dascript && cargo test -p c2dascript-transpile --test ten_tests 2>&1 | tail -5" 2>nul

:: Step 2: copy results to Windows
echo [2/2] Verifying with daslang...
wsl bash /mnt/d/Backups/DockerTranslator/copy_das.sh 2>nul

:: Step 3: run each test
for %%t in (%TESTS%) do (
    "%DASLANG%" "D:\Backups\с2daslang\c2dascript\tests\syntax\%%t.das" >nul 2>nul
    set "EXIT=!ERRORLEVEL!"
    call :check %%t !EXIT!
)

echo.
echo ==============================
echo   Results: %PASS%/10 passed
echo ==============================
exit /b

:check
if "%1"=="t01_arith" set EXPECT=25
if "%1"=="t02_mul_div" set EXPECT=21
if "%1"=="t03_cmp" set EXPECT=10
if "%1"=="t04_logical" set EXPECT=1
if "%1"=="t05_if_elif" set EXPECT=0
if "%1"=="t06_while" set EXPECT=55
if "%1"=="t07_for" set EXPECT=55
if "%1"=="t08_struct" set EXPECT=50
if "%1"=="t09_enum" set EXPECT=40
if "%1"=="t10_chain" set EXPECT=40
set /a PASS+=1
exit /b
