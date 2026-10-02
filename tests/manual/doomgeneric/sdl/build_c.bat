@echo off
rem Build the native C reference of the SDL3 harness on Windows, four ways:
rem   doom_sdl_msvc_O2.exe        cl /O2
rem   doom_sdl_msvc_avx2.exe      cl /O2 /arch:AVX2
rem   doom_sdl_clang_O2.exe       clang-cl /O2
rem   doom_sdl_clang_native.exe   clang-cl /O2 /clang:-march=native (what daslang -jit targets: the host CPU)
rem Each is the engine translation unit doom_host_all.c plus the host doom_sdl_host.c, linked
rem against static SDL3.  Outputs and logs go to the current directory (run it from a scratch
rem directory, never from the checkout).  Compilers run at low priority, one at a time.
rem
rem Environment:
rem   SDL3_DIR   SDL3 install prefix holding include\SDL3 and lib\SDL3-static.lib (required)
rem   VCVARS     vcvars64.bat; only needed when cl.exe is not already on PATH
rem              (default: found through vswhere.exe)
rem   CLANG_CL   clang-cl.exe (default: clang-cl on PATH, else %ProgramFiles%\LLVM\bin\clang-cl.exe)
setlocal
set HERE=%~dp0
set CORPUS=%HERE%..
if "%SDL3_DIR%"=="" (echo SDL3_DIR is not set ^(SDL3 install prefix^) & exit /b 1)
if not exist "%SDL3_DIR%\lib\SDL3-static.lib" (echo no "%SDL3_DIR%\lib\SDL3-static.lib" & exit /b 1)
where cl >nul 2>nul || call :vcvars || exit /b 1
if "%CLANG_CL%"=="" (
  where clang-cl >nul 2>nul && set CLANG_CL=clang-cl
)
if "%CLANG_CL%"=="" set "CLANG_CL=%ProgramFiles%\LLVM\bin\clang-cl.exe"
set ENGINE_INC=/I"%CORPUS%\include" /I"%CORPUS%\upstream\doomgeneric\doomgeneric" /I"%CORPUS%\src" /I"%HERE%."
set SYSLIBS=user32.lib gdi32.lib winmm.lib imm32.lib ole32.lib oleaut32.lib version.lib uuid.lib advapi32.lib setupapi.lib shell32.lib kernel32.lib
set FAILED=0
call :build msvc_O2 cl "/O2" || set FAILED=1
call :build msvc_avx2 cl "/O2 /arch:AVX2" || set FAILED=1
call :build clang_O2 "%CLANG_CL%" "/O2" || set FAILED=1
call :build clang_native "%CLANG_CL%" "/O2 /clang:-march=native" || set FAILED=1
if "%FAILED%"=="1" (echo === some builds FAILED ^(see build_*.log^) === & exit /b 1)
echo === done ===
exit /b 0

:build
rem :build <name> <compiler> "<optimisation flags>"
set NAME=%~1
set CC=%~2
set OPT=%~3
set LOG=%CD%\build_%NAME%.log
if exist doom_sdl_%NAME%.exe del doom_sdl_%NAME%.exe
echo building doom_sdl_%NAME%.exe
start "" /low /wait /b cmd /c ""%CC%" /nologo /c /w %OPT% /MD %ENGINE_INC% "%HERE%doom_host_all.c" /Fo:doom_host_all_%NAME%.obj > "%LOG%" 2>&1"
if not exist doom_host_all_%NAME%.obj (echo   engine compile FAILED, see %LOG% & exit /b 1)
start "" /low /wait /b cmd /c ""%CC%" /nologo /c %OPT% /MD /I"%SDL3_DIR%\include" /I"%HERE%." "%HERE%doom_sdl_host.c" /Fo:doom_sdl_host_%NAME%.obj >> "%LOG%" 2>&1"
if not exist doom_sdl_host_%NAME%.obj (echo   host compile FAILED, see %LOG% & exit /b 1)
start "" /low /wait /b cmd /c ""%CC%" /nologo doom_sdl_host_%NAME%.obj doom_host_all_%NAME%.obj /Fe:doom_sdl_%NAME%.exe /link /SUBSYSTEM:CONSOLE "%SDL3_DIR%\lib\SDL3-static.lib" %SYSLIBS% >> "%LOG%" 2>&1"
if not exist doom_sdl_%NAME%.exe (echo   link FAILED, see %LOG% & exit /b 1)
exit /b 0

:vcvars
if not "%VCVARS%"=="" goto :vcvars_call
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (echo cl.exe is not on PATH; set VCVARS to vcvars64.bat & exit /b 1)
for /f "usebackq delims=" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VCVARS=%%I\VC\Auxiliary\Build\vcvars64.bat"
:vcvars_call
if not exist "%VCVARS%" (echo no vcvars64.bat at "%VCVARS%" & exit /b 1)
call "%VCVARS%" >nul || exit /b 1
exit /b 0
