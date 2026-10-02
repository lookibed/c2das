# AOT profile of the SDL3 harness on Windows: daslang.exe + dasSDL3, neither checkout modified.
#
# dasSDL3's package module (src/package) does not define DASSDL3_AOT_HEADER, so its
# Module::aotRequire is the default and C++ AOT cannot reference its bindings.  This project
# compiles the same unmodified dasSDL3 sources into a shared module WITH DASSDL3_AOT_HEADER
# ("sdl3_aot.h", as dasSDL3's own SDK profile does in cmake/InstallSDK.cmake), and optionally
# links the C++ AOT output of the harness (the translated engine module and the host) into that
# same DLL, so the AOT code and the bindings share one static SDL instance.  `daslang -use-aot`
# then links the functions the DLL registered into libDaScriptDyn's AOT list when it loaded.
#
# Stage 1 (DASSDL3_AOT_SOURCES empty): the module only, loaded by `daslang -aot` to generate C++.
# Stage 2 (DASSDL3_AOT_SOURCES = the generated .cpp files): module + harness AOT.
# Driven by ../build_aot.bat.
cmake_minimum_required(VERSION 3.24)
project(c2das_doom_sdl_aot LANGUAGES C CXX)
if(NOT WIN32 OR NOT MSVC OR NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    message(FATAL_ERROR "MSVC x64 single-config Release only")
endif()
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
set(DASLANG_DIR "" CACHE PATH "daScript checkout/SDK the module is loaded into")
set(DASSDL3_DIR "" CACHE PATH "dasSDL3 checkout (sources are used unmodified)")
set(DASSDL3_AOT_SOURCES "" CACHE STRING "Generated AOT .cpp files to link into the module")
set(DASSDL3_MODULE_OUTPUT "${CMAKE_BINARY_DIR}/module" CACHE PATH "Module output folder")
find_package(SDL3 3.4.16 EXACT CONFIG REQUIRED COMPONENTS SDL3-static)

add_library(dasSDL3_aot_module SHARED "${DASSDL3_DIR}/src/module_sdl3.cpp" ${DASSDL3_AOT_SOURCES})
target_include_directories(dasSDL3_aot_module PRIVATE "${DASSDL3_DIR}/src"
    "${DASLANG_DIR}/include" "${DASLANG_DIR}/3rdparty/fmt/include")
# Same definitions as dasSDL3/src/package/CMakeLists.txt, plus the AOT header switch.
target_compile_definitions(dasSDL3_aot_module PRIVATE DAS_ENABLE_DLL=1 DAS_MOD_EXPORTS
    DAS_ENABLE_EXCEPTIONS=1 DAS_FUSION=2 DAS_NO_ASSERTIONS
    DASSDL3_TYPES_INCLUDE="generated/clangbind/sdl3_types.inc"
    DASSDL3_REGISTRATION_INCLUDE="generated/clangbind/sdl3_functions.inc"
    DASSDL3_AOT_HEADER="sdl3_aot.h")
# /arch:AVX2: the generated C++ targets an AVX2 host, as -jit targets the host CPU; compare the
# aot row with the C reference's AVX2 / -march=native rows.
target_compile_options(dasSDL3_aot_module PRIVATE /bigobj /arch:AVX2 /wd4251 /wd4275)
target_link_libraries(dasSDL3_aot_module PRIVATE SDL3::SDL3-static
    "${DASLANG_DIR}/lib/libDaScriptDyn.lib" "${DASLANG_DIR}/lib/libDaScriptDyn_runtime.lib")
set_target_properties(dasSDL3_aot_module PROPERTIES PREFIX "" SUFFIX ".shared_module"
    OUTPUT_NAME dasSDL3 RUNTIME_OUTPUT_DIRECTORY "${DASSDL3_MODULE_OUTPUT}")
