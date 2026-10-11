/* C entry of the quakegeneric corpus: plays back `demo1` of the shareware
 * `id1/pak0.pak` under the base directory named by the last command-line
 * argument for a fixed number of rendered frames and prints one hash per
 * frame.
 *
 * The engine runs as `quake -basedir <dir> +timedemo demo1`.  `-basedir`
 * replaces `QG_Create`'s "." as the directory holding `id1/`; the `+`
 * argument is queued by the `stuffcmds` line of the pak's `quake.rc`.
 * `timedemo` is Quake's demo benchmark: the client reads one demo message
 * per frame whatever the clock says, so the demo's recorded input is the
 * only input.  With the virtual clock of `qg_platform.c` nothing in the run
 * depends on the host.
 *
 * The entry never calls `Host_Shutdown`: that writes `id1/config.cfg` into
 * the base directory, and the next run would read it back.
 *
 * `main` lives in this file alone so that, compiled unit by unit, no
 * dependency cycle of engine units contains it.  `quake_all.c` includes it
 * after the unity build `all.c` for the `--libc std` case. */
#include <stdint.h>
#include <stdio.h>

#include "quakegeneric.h"

/* The frame hashes go to stdout: the engine's console redirection of
 * `engine_config.h` (force-included when units are compiled on their own)
 * ends here.  The unity build `all.c` has already ended its own. */
#undef printf
#undef vprintf
#undef puts
#undef putchar

/* The platform layer's frame record and frame duration (`qg_platform.c`). */
extern int qg_frame_count;
extern int32_t qg_frame_hash[];
extern const double qg_frame_seconds;

/* Frames recorded. */
#define FRAME_LIMIT 100

/* Ticks allowed before the run gives up: startup and the level load render
 * nothing on some ticks, so this is a bound, not a count. */
#define TICK_LIMIT 2000

static char *quake_argv[6];

int main(int argc, char **argv)
{
    int i = 0;
    int ticks = 0;

    setvbuf(stdout, NULL, _IONBF, 0);

    if (argc < 2) {
        printf("load=0\n");
        return 2;
    }
    quake_argv[0] = "quake";
    quake_argv[1] = "-basedir";
    quake_argv[2] = argv[argc - 1];
    quake_argv[3] = "+timedemo";
    quake_argv[4] = "demo1";
    quake_argv[5] = NULL;

    QG_Create(5, quake_argv);
    while (qg_frame_count < FRAME_LIMIT && ticks < TICK_LIMIT) {
        QG_Tick(qg_frame_seconds);
        ticks += 1;
    }
    if (qg_frame_count < FRAME_LIMIT) {
        printf("frames=%d ticks=%d\n", qg_frame_count, ticks);
        return 1;
    }

    for (i = 0; i < FRAME_LIMIT; i++) {
        printf("frame[%d]=%d\n", i, (int)qg_frame_hash[i]);
    }
    printf("frames=%d\n", FRAME_LIMIT);
    return 0;
}
