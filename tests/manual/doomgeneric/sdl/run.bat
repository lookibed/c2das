@echo off
rem Run one variant of the SDL3 harness once.
rem
rem   run.bat c <build>   [--no-present] [--frames N]   doom_sdl_<build>.exe from the current directory
rem                                                       (build_c.bat: msvc_O2, msvc_avx2, clang_O2,
rem                                                       clang_native)
rem   run.bat interp <dir> [--no-present] [--frames N]   daslang <dir>\doom_sdl.das
rem   run.bat jit    <dir> [--no-present] [--frames N]   daslang -jit <dir>\doom_sdl.das
rem   run.bat aot    <dir> [--no-present] [--frames N]   daslang -use-aot <dir>\doom_sdl.das
rem
rem <dir> is translate.sh's <out-dir>\default for interp and jit, <out-dir>\aot for aot (built
rem with build_aot.bat from the current directory).  Prints the program's stdout (the engine's
rem log on stderr and the JIT's "[I] " progress lines are dropped).  The window path uses SDL's
rem default video driver; set SDL_VIDEODRIVER=dummy to run it headless.
rem
rem Environment:
rem   DOOM_WAD        the IWAD (default: ..\fixtures\doom1.wad next to this script)
rem   DASLANG         daslang.exe (default: daslang.exe on PATH)
rem   DASSDL3_PROJ    project root whose modules\dasSDL3 holds the dasSDL3 module, for interp and
rem                   jit (required for those)
rem   DASSDL3_AOT_PROJ  project root with the AOT build of the module (default: aot-proj in the
rem                   current directory, where build_aot.bat stages it)
rem   VCVARS          vcvars64.bat, for -jit when cl.exe is not on PATH (its lld-link step needs
rem                   the MSVC library paths; default: via vswhere.exe)
setlocal
set HERE=%~dp0
set MODE=%~1
set TARGET=%~2
if "%TARGET%"=="" goto :usage
shift
shift
set ARGS=
:collect
if "%~1"=="" goto :collected
set ARGS=%ARGS% %1
shift
goto :collect
:collected
if "%DOOM_WAD%"=="" set "DOOM_WAD=%HERE%..\fixtures\doom1.wad"
for %%I in ("%DOOM_WAD%") do set "DOOM_WAD=%%~fI"
if not exist "%DOOM_WAD%" (echo no IWAD at "%DOOM_WAD%" & exit /b 1)

if "%MODE%"=="c" goto :c
if "%DASLANG%"=="" for %%I in (daslang.exe) do set "DASLANG=%%~$PATH:I"
if "%DASLANG%"=="" (echo DASLANG is not set and daslang.exe is not on PATH & exit /b 1)
for %%I in ("%TARGET%") do set "TARGET=%%~fI"
if not exist "%TARGET%\doom_sdl.das" (echo no "%TARGET%\doom_sdl.das" & exit /b 1)
if "%MODE%"=="aot" goto :aot
if "%DASSDL3_PROJ%"=="" (echo DASSDL3_PROJ is not set ^(project root with modules\dasSDL3^) & exit /b 1)
if "%MODE%"=="interp" goto :interp
if "%MODE%"=="jit" goto :jit
goto :usage

:c
if not exist "%CD%\doom_sdl_%TARGET%.exe" (echo no "%CD%\doom_sdl_%TARGET%.exe" ^(build_c.bat^) & exit /b 1)
"%CD%\doom_sdl_%TARGET%.exe" %ARGS% "%DOOM_WAD%" 2>nul
exit /b %ERRORLEVEL%

:interp
"%DASLANG%" -project-root "%DASSDL3_PROJ%" "%TARGET%\doom_sdl.das" -- %ARGS% "%DOOM_WAD%" 2>nul
exit /b %ERRORLEVEL%

:jit
rem The JIT caches its DLL under .jitted_scripts\ in the current directory.
where cl >nul 2>nul || call :vcvars || exit /b 1
"%DASLANG%" -jit -project-root "%DASSDL3_PROJ%" "%TARGET%\doom_sdl.das" -- %ARGS% "%DOOM_WAD%" 2>nul | findstr /v /b /l /c:"[I] "
exit /b 0

:aot
if "%DASSDL3_AOT_PROJ%"=="" set "DASSDL3_AOT_PROJ=%CD%\aot-proj"
if not exist "%DASSDL3_AOT_PROJ%\modules\dasSDL3\dasSDL3.shared_module" (echo no AOT module under "%DASSDL3_AOT_PROJ%" ^(build_aot.bat^) & exit /b 1)
"%DASLANG%" -use-aot -project-root "%DASSDL3_AOT_PROJ%" "%TARGET%\doom_sdl.das" -- %ARGS% "%DOOM_WAD%" 2>nul
exit /b %ERRORLEVEL%

:usage
echo usage: run.bat c ^<build^> ^| interp ^<dir^> ^| jit ^<dir^> ^| aot ^<dir^>   [--no-present] [--frames N]
exit /b 2

:vcvars
if not "%VCVARS%"=="" goto :vcvars_call
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (echo cl.exe is not on PATH; set VCVARS to vcvars64.bat & exit /b 1)
for /f "usebackq delims=" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VCVARS=%%I\VC\Auxiliary\Build\vcvars64.bat"
:vcvars_call
if not exist "%VCVARS%" (echo no vcvars64.bat at "%VCVARS%" & exit /b 1)
call "%VCVARS%" >nul || exit /b 1
exit /b 0
