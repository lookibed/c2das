@echo off
rem Run dasQUAKE as a desktop SDL3 window program through dasSDL3 (Windows).
rem
rem   sdl\run.bat [jit^|interp] [--fullscreen] [--timedemo [--frames N] [--no-present]]
rem
rem   jit (default)  daslang -jit quake\quake_sdl.das: the LLVM JIT
rem   interp         the daslang interpreter (slow: the game plays slowed down)
rem   (no option)    play: the attract demos at real time; any key opens the menu,
rem                  New Game starts episode 1.  Keyboard and mouse (mouse look while
rem                  playing).  Close the window to quit.
rem   --fullscreen   start full screen
rem   --timedemo     +timedemo demo1 as fast as possible for N recorded frames (default
rem                  100), then one hash per frame and the timing (setup_us, loop_frames,
rem                  loop_us, fps).  The 100 hashes must equal quake\expected_frames.txt.
rem   --no-present   with --timedemo: no window, engine and palette conversion only
rem
rem Environment:
rem   DASLANG        daslang.exe built with LLVM (default: daslang.exe on PATH)
rem   DASSDL3_PROJ   project root whose modules\dasSDL3 holds the built dasSDL3 module
rem                  (dasSDL3.shared_module and the dassdl3 scripts; required)
rem   QUAKE_BASEDIR  the directory holding id1\pak0.pak (default: the repository root,
rem                  tools/get_pak.sh)
rem   DASQUAKE_WORK  working directory for the JIT's cache (default: %TEMP%\dasquake-sdl)
rem   VCVARS         vcvars64.bat, for -jit when cl.exe is not on PATH (the JIT's link step
rem                  needs the MSVC library paths; default: found through vswhere.exe)
setlocal
set "HERE=%~dp0"
set "MODE=jit"
if /i "%~1"=="jit" (set "MODE=jit" & shift)
if /i "%~1"=="interp" (set "MODE=interp" & shift)
set ARGS=
:collect
if "%~1"=="" goto :collected
set ARGS=%ARGS% %1
shift
goto :collect
:collected
if "%QUAKE_BASEDIR%"=="" set "QUAKE_BASEDIR=%HERE%.."
for %%I in ("%QUAKE_BASEDIR%") do set "QUAKE_BASEDIR=%%~fI"
if not exist "%QUAKE_BASEDIR%\id1\pak0.pak" (echo no "%QUAKE_BASEDIR%\id1\pak0.pak": run tools/get_pak.sh or set QUAKE_BASEDIR & exit /b 1)
if "%DASLANG%"=="" for %%I in (daslang.exe) do set "DASLANG=%%~$PATH:I"
if "%DASLANG%"=="" (echo DASLANG is not set and daslang.exe is not on PATH & exit /b 1)
if "%DASSDL3_PROJ%"=="" (echo DASSDL3_PROJ is not set ^(project root with modules\dasSDL3^) & exit /b 1)
if not exist "%DASSDL3_PROJ%\modules\dasSDL3" (echo no modules\dasSDL3 under "%DASSDL3_PROJ%" & exit /b 1)
for %%I in ("%HERE%..\quake\quake_sdl.das") do set "HOST=%%~fI"
if "%DASQUAKE_WORK%"=="" set "DASQUAKE_WORK=%TEMP%\dasquake-sdl"
if not exist "%DASQUAKE_WORK%" mkdir "%DASQUAKE_WORK%"
cd /d "%DASQUAKE_WORK%"
if "%MODE%"=="interp" goto :interp

where cl >nul 2>nul || call :vcvars || exit /b 1
rem The engine's console goes to stderr (dropped); the JIT's "[I] " progress lines too.
"%DASLANG%" -jit -project-root "%DASSDL3_PROJ%" "%HOST%" -- %ARGS% "%QUAKE_BASEDIR%" 2>nul | findstr /v /b /l /c:"[I] "
exit /b 0

:interp
"%DASLANG%" -project-root "%DASSDL3_PROJ%" "%HOST%" -- %ARGS% "%QUAKE_BASEDIR%" 2>nul
exit /b %ERRORLEVEL%

:vcvars
if not "%VCVARS%"=="" goto :vcvars_call
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (echo cl.exe is not on PATH; set VCVARS to vcvars64.bat & exit /b 1)
for /f "usebackq delims=" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VCVARS=%%I\VC\Auxiliary\Build\vcvars64.bat"
:vcvars_call
if not exist "%VCVARS%" (echo no vcvars64.bat at "%VCVARS%" & exit /b 1)
call "%VCVARS%" >nul || exit /b 1
exit /b 0
