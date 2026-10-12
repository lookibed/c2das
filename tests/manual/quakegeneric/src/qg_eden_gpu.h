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

/* M2a: the world model as static GPU meshes, sent once per map load.
 * world_begin opens a new world (the host drops the previous one);
 * world_texture hands one miptex (level 0, w*h palette indices) with the
 * 768-byte base palette; world_mesh hands a batch of triangles of texture
 * `tex`: `verts` is nverts * 8 floats (x y z nx ny nz u v, Quake
 * coordinates, u/v in texture repeats), `idx` is nidx vertex indices;
 * world_end closes the world (the host builds its meshes then). */
extern void eden_gpu_world_begin(int ntextures);
extern void eden_gpu_world_texture(int tex, const unsigned char *pixels, int w, int h, const unsigned char *rgb768);
extern void eden_gpu_world_mesh(int tex, const float *verts, int nverts, const int *idx, int nidx);
extern void eden_gpu_world_end(void);
/* per frame: the view origin, the view angles (pitch yaw roll, degrees)
 * and the horizontal / vertical fov (degrees) of r_refdef */
extern void eden_gpu_camera(float x, float y, float z, float pitch, float yaw, float roll, float fov_x, float fov_y);

#endif /* QG_EDEN_GPU_H */
