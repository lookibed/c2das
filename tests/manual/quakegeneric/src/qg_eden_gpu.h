/* The host API of the quakegeneric platform layer `qg_eden_gpu.c` (the
 * `eden_gpu` ABI v0 variant of `qg_eden_play.c`): the same `qge_*` calls the
 * player makes, plus the two host imports the engine calls itself.  The
 * imports are defined nowhere in C; the translator binds them with
 * `--host-import-prefix eden_gpu_=eden_gpu` to the hand-written daslang
 * module `eden/eden_gpu.das`. */
#ifndef QG_EDEN_GPU_H
#define QG_EDEN_GPU_H

#include "qg_eden.h"

/* the 8-bit screen, one palette index per pixel, row-major, w*h bytes */
extern void eden_gpu_present(const unsigned char *pixels, int w, int h);
/* 256 RGB triples; valid only during the call */
extern void eden_gpu_palette(const unsigned char *rgb768);

#endif /* QG_EDEN_GPU_H */
