@echo off
rem Run dasDOOM as a desktop SDL3 window program through dasSDL3 (Windows).
rem
rem   sdl\run.bat [jit^|interp] [--realtime] [--frames N] [--no-present]
rem
rem   jit (default)  daslang -jit doom\doom_sdl.das: the LLVM JIT, about C speed
rem   interp         the daslang interpreter (about Doom's own 35 frames per second)
rem   --realtime     play the demo back at Doom's 35 tics per second (for watching)
rem   --frames N     stop after N rendered frames (default 1000; DEMO1 has 5026 tics)
rem   --no-present   no window: engine and palette conversion only
rem
rem It plays -timedemo demo1 of the shareware IWAD, then prints one hash per frame
rem and the timing (setup_us, loop_frames, loop_us, fps).  The first 70 hashes must
rem equal doom\expected_frames.txt.  Escape or closing the window stops the run.
rem
rem Environment:
rem   DASLANG       daslang.exe built with LLVM (default: daslang.exe on PATH)
rem   DASSDL3_PROJ  project root whose modules\dasSDL3 holds the built dasSDL3 module
rem                 (dasSDL3.shared_module and the dassdl3 scripts; required)
rem   DOOM_WAD      the IWAD (default: doom1.wad in the repository root, tools/get_wad.sh)
rem   DASDOOM_WORK  working directory for the engine's .savegame\ and the JIT's cache
rem                 (default: %TEMP%\dasdoom-sdl)
rem   VCVARS        vcvars64.bat, for -jit when cl.exe is not on PATH (the JIT's link step
rem                 needs the MSVC library paths; default: found through vswhere.exe)
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
if "%DOOM_WAD%"=="" set "DOOM_WAD=%HERE%..\doom1.wad"
for %%I in ("%DOOM_WAD%") do set "DOOM_WAD=%%~fI"
if not exist "%DOOM_WAD%" (echo no IWAD at "%DOOM_WAD%": run tools/get_wad.sh or set DOOM_WAD & exit /b 1)
if "%DASLANG%"=="" for %%I in (daslang.exe) do set "DASLANG=%%~$PATH:I"
if "%DASLANG%"=="" (echo DASLANG is not set and daslang.exe is not on PATH & exit /b 1)
if "%DASSDL3_PROJ%"=="" (echo DASSDL3_PROJ is not set ^(project root with modules\dasSDL3^) & exit /b 1)
if not exist "%DASSDL3_PROJ%\modules\dasSDL3" (echo no modules\dasSDL3 under "%DASSDL3_PROJ%" & exit /b 1)
for %%I in ("%HERE%..\doom\doom_sdl.das") do set "HOST=%%~fI"
if "%DASDOOM_WORK%"=="" set "DASDOOM_WORK=%TEMP%\dasdoom-sdl"
if not exist "%DASDOOM_WORK%" mkdir "%DASDOOM_WORK%"
cd /d "%DASDOOM_WORK%"
if "%MODE%"=="interp" goto :interp

where cl >nul 2>nul || call :vcvars || exit /b 1
rem The engine's console goes to stderr (dropped); the JIT's "[I] " progress lines too.
"%DASLANG%" -jit -project-root "%DASSDL3_PROJ%" "%HOST%" -- %ARGS% "%DOOM_WAD%" 2>nul | findstr /v /b /l /c:"[I] "
exit /b 0

:interp
"%DASLANG%" -project-root "%DASSDL3_PROJ%" "%HOST%" -- %ARGS% "%DOOM_WAD%" 2>nul
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
