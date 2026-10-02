@echo off
rem Build the AOT variant of the SDL3 harness on Windows.
rem
rem   build_aot.bat <aot-dir>
rem
rem <aot-dir> is translate.sh's <out-dir>\aot (doom_host_all.das with the AOT header, and
rem doom_sdl.das with `options disable_auto_inline`).  Work directories go to the current
rem directory (run it from a scratch directory, never from the checkout):
rem   aot-build-gen\, aotgen-proj\   stage 1: dasSDL3 built AOT-capable (aot\CMakeLists.txt, no
rem                                  harness code), staged as aotgen-proj\modules\dasSDL3; built
rem                                  once, `daslang -aot` loads it to generate C++
rem   aot-build-run\, aot-proj\      stage 2: the same module with the generated C++ of
rem                                  doom_host_all.das and doom_sdl.das linked in, staged as
rem                                  aot-proj\modules\dasSDL3
rem Then run:  daslang -use-aot -project-root <cwd>\aot-proj <aot-dir>\doom_sdl.das -- ...
rem (run.bat aot does this).  Compilers run at low priority with 2 jobs.
rem
rem Environment:
rem   DASLANG      daslang.exe (default: daslang.exe on PATH)
rem   DASROOT      daScript root holding include\ and lib\libDaScriptDyn*.lib
rem                (default: the parent of DASLANG's bin directory)
rem   DASSDL3_DIR  dasSDL3 checkout (its src\ and dassdl3\ are used unmodified; required)
rem   SDL3_DIR     SDL3 install prefix (lib\SDL3-static.lib, cmake\; required)
rem   VCVARS       vcvars64.bat, when cl.exe is not already on PATH (default: via vswhere.exe)
setlocal
set HERE=%~dp0
if "%~1"=="" (echo usage: build_aot.bat ^<aot-dir^> & exit /b 2)
set GEN=%~f1
if not exist "%GEN%\doom_host_all.das" (echo no "%GEN%\doom_host_all.das" & exit /b 1)
if "%DASLANG%"=="" for %%I in (daslang.exe) do set "DASLANG=%%~$PATH:I"
if "%DASLANG%"=="" (echo DASLANG is not set and daslang.exe is not on PATH & exit /b 1)
if "%DASROOT%"=="" for %%I in ("%DASLANG%") do set "DASROOT=%%~dpI.."
for %%I in ("%DASROOT%") do set "DASROOT=%%~fI"
if "%DASSDL3_DIR%"=="" (echo DASSDL3_DIR is not set ^(dasSDL3 checkout^) & exit /b 1)
if "%SDL3_DIR%"=="" (echo SDL3_DIR is not set ^(SDL3 install prefix^) & exit /b 1)
where cl >nul 2>nul || call :vcvars || exit /b 1
set WORK=%CD%
set "CM_DASROOT=%DASROOT:\=/%"
set "CM_DASSDL3=%DASSDL3_DIR:\=/%"
set "CM_SDL3=%SDL3_DIR:\=/%/cmake"
set "CM_SRC=%HERE%aot"

if exist "%WORK%\aotgen-proj\modules\dasSDL3\dasSDL3.shared_module" goto :generate
echo stage 1: AOT-capable dasSDL3 module
cmake -S "%CM_SRC%" -B "%WORK%\aot-build-gen" -G Ninja -DCMAKE_BUILD_TYPE=Release "-DDASLANG_DIR=%CM_DASROOT%" "-DDASSDL3_DIR=%CM_DASSDL3%" "-DSDL3_DIR=%CM_SDL3%" > "%WORK%\aot_gen_configure.log" 2>&1 || (echo CONFIGURE FAILED, see aot_gen_configure.log & exit /b 1)
start "" /low /wait /b cmake --build "%WORK%\aot-build-gen" --parallel 2 > "%WORK%\aot_gen_build.log" 2>&1
if not exist "%WORK%\aot-build-gen\module\dasSDL3.shared_module" (echo BUILD FAILED, see aot_gen_build.log & exit /b 1)
call :stage "%WORK%\aot-build-gen\module\dasSDL3.shared_module" "%WORK%\aotgen-proj\modules\dasSDL3" || exit /b 1

:generate
echo generating C++ (daslang -aot)
if not exist "%WORK%\aot-build-run" mkdir "%WORK%\aot-build-run"
"%DASLANG%" -aot "%GEN%\doom_host_all.das" "%WORK%\aot-build-run\doom_host_all.das.cpp" -project-root "%WORK%\aotgen-proj" > "%WORK%\aot_generate_engine.log" 2>&1 || (echo AOT GENERATE FAILED, see aot_generate_engine.log & exit /b 1)
"%DASLANG%" -aot "%GEN%\doom_sdl.das" "%WORK%\aot-build-run\doom_sdl.das.cpp" -project-root "%WORK%\aotgen-proj" > "%WORK%\aot_generate_host.log" 2>&1 || (echo AOT GENERATE FAILED, see aot_generate_host.log & exit /b 1)
set "CM_RUN=%WORK:\=/%/aot-build-run"
echo stage 2: module + harness AOT
cmake -S "%CM_SRC%" -B "%WORK%\aot-build-run" -G Ninja -DCMAKE_BUILD_TYPE=Release "-DDASLANG_DIR=%CM_DASROOT%" "-DDASSDL3_DIR=%CM_DASSDL3%" "-DSDL3_DIR=%CM_SDL3%" "-DDASSDL3_AOT_SOURCES=%CM_RUN%/doom_host_all.das.cpp;%CM_RUN%/doom_sdl.das.cpp" > "%WORK%\aot_run_configure.log" 2>&1 || (echo CONFIGURE FAILED, see aot_run_configure.log & exit /b 1)
if exist "%WORK%\aot-build-run\module\dasSDL3.shared_module" del "%WORK%\aot-build-run\module\dasSDL3.shared_module"
start "" /low /wait /b cmake --build "%WORK%\aot-build-run" --parallel 2 > "%WORK%\aot_run_build.log" 2>&1
if not exist "%WORK%\aot-build-run\module\dasSDL3.shared_module" (echo BUILD FAILED, see aot_run_build.log & exit /b 1)
call :stage "%WORK%\aot-build-run\module\dasSDL3.shared_module" "%WORK%\aot-proj\modules\dasSDL3" || exit /b 1
echo === done ===
exit /b 0

:stage
rem :stage <module dll> <destination folder>: the DLL, dasSDL3's boost scripts, the descriptor
if not exist "%~2\dassdl3" mkdir "%~2\dassdl3"
copy /y "%~1" "%~2\dasSDL3.shared_module" >nul || exit /b 1
copy /y "%DASSDL3_DIR%\dassdl3\*.das" "%~2\dassdl3\" >nul || exit /b 1
copy /y "%HERE%aot\dasSDL3.das_module" "%~2\.das_module" >nul || exit /b 1
echo staged %~2
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
