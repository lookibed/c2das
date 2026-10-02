/* The host API of `dg_host.c`, for the C host `doom_sdl_host.c`, which is a
 * separate translation unit from the engine (SDL's and Doom's headers do not
 * mix). */
#ifndef DG_HOST_H
#define DG_HOST_H

#include <stdint.h>

int dg_host_width(void);
int dg_host_height(void);
void dg_host_start(char *iwad);
void dg_host_tick(void);
int dg_host_frame_count(void);
int dg_host_frame_hash(int index);
uint32_t *dg_host_frame_argb(void);

#endif
