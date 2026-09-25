/* C entry of the doomgeneric corpus: plays back the first demo of the IWAD
 * named by the last command-line argument for a fixed number of rendered
 * frames and prints one hash per frame.
 *
 * The engine runs as `doom -iwad <wad> -nosound -nomusic -timedemo demo1`.
 * `-timedemo` is vanilla Doom's demo benchmark: the engine plays the demo
 * lump back with `singletics` set, so every `doomgeneric_Tick` runs exactly
 * one game tic and renders exactly one frame whatever the clock says, and
 * the demo's recorded input is the only input.  With the virtual clock of
 * `dg_platform.c` nothing in the run depends on the host.
 *
 * It is the C reference program of the corpus and, through `doom_all.c`, the
 * translation input under `--libc std`. */
#include <stdint.h>
#include <stdio.h>

#include "doomgeneric.h"

/* Frames recorded.  The first 41 are rendered inside `doomgeneric_Create`,
 * while `D_Display` runs the screen wipe (`f_wipe.c`'s melt) into DEMO1's
 * level, E1M5 of the shareware IWAD, one frame per virtual tic of the wipe.
 * The other 29 are the first demo tics, one frame each. */
#define FRAME_LIMIT 70

static char *doom_argv[8];

int main(int argc, char **argv)
{
    int i = 0;

    setvbuf(stdout, NULL, _IONBF, 0);

    if (argc < 2) {
        printf("load=0\n");
        return 2;
    }
    doom_argv[0] = "doom";
    doom_argv[1] = "-iwad";
    doom_argv[2] = argv[argc - 1];
    doom_argv[3] = "-nosound";
    doom_argv[4] = "-nomusic";
    doom_argv[5] = "-timedemo";
    doom_argv[6] = "demo1";
    doom_argv[7] = NULL;

    doomgeneric_Create(7, doom_argv);
    while (dg_frame_count < FRAME_LIMIT) {
        dg_advance_clock();
        doomgeneric_Tick();
    }

    for (i = 0; i < FRAME_LIMIT; i++) {
        printf("frame[%d]=%d\n", i, (int)dg_frame_hash[i]);
    }
    printf("frames=%d\n", FRAME_LIMIT);
    return 0;
}
