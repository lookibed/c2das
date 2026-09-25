/* The c2das target graph: the binjgb core (`upstream/binjgb/src`, revision in
 * `UPSTREAM.md`) as one translation unit.
 *
 * `common.c` (file and FileData helpers), `emulator.c` (CPU, memory map, PPU,
 * APU, timers, cartridge mappers) and `joypad.c` (the input recording buffer)
 * are the three translation units of upstream's emulator library; the SDL
 * host, debugger, rewind buffer and option parser are not vendored.  The
 * build defines `NDEBUG` (see the case's clang flags): upstream's `assert`s
 * compile to nothing, as in a release build of binjgb, in the C reference and
 * the translation alike. */
#include "common.c"
#include "emulator.c"
#include "joypad.c"
