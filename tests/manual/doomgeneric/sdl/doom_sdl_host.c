/* C host of the SDL3 harness: runs the doomgeneric corpus engine (the
 * headless build of `doom_host_all.c`, linked in as a separate translation
 * unit) as an SDL3 window application and measures its frame rate.  It is
 * the native reference of `doom_sdl.das`, which does the same SDL work
 * around the translated engine; the measured loop of the two is the same
 * sequence of calls.
 *
 *   doom_sdl_host [--no-present] [--frames N] <doom1.wad>
 *
 * - The engine starts as the corpus entries start it (`dg_host_start`:
 *   `-iwad <wad> -nosound -nomusic -timedemo demo1`, virtual clock, the
 *   first 41 frames rendered inside `doomgeneric_Create`); `setup_us` times
 *   that.
 * - The loop then runs until the engine has rendered N frames (default
 *   1000, the corpus benchmark's count; DEMO1 has 5026 tics and the engine
 *   exits when the demo ends).  One iteration: poll SDL events (closing the
 *   window or Escape stops the run early), one engine tic and frame
 *   (`dg_host_tick`), palette conversion of the frame to ARGB8888
 *   (`dg_host_frame_argb`), upload to a 320x200 streaming texture, render it
 *   scaled to the window, present.  vsync is off.  `loop_us` times the loop
 *   with SDL's performance counter and `fps` = loop frames / loop seconds.
 * - `--no-present` runs the same loop without SDL video: no window, no
 *   events, no upload, no present; the tic and the palette conversion stay.
 *   It shows what the engine (plus conversion) costs on its own.
 * - Set `SDL_VIDEODRIVER=dummy` to run the window path headless (SDL's
 *   dummy video driver and software renderer).
 *
 * Output (stdout; the engine's own log goes to stderr): the video driver
 * and renderer, then after the loop `frame[i]=<hash>` for every recorded
 * frame (the platform layer's per-frame hash, the corpus oracle's first 70),
 * `frames=`, `setup_us=`, `loop_frames=`, `loop_us=`, `fps=`.  Exit 0. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "dg_host.h"

/* The platform layer records at most this many hashes (`DG_MAX_FRAMES`). */
#define HASH_LIMIT 4096
#define WINDOW_SCALE 3

int main(int argc, char **argv)
{
    int present = 1;
    int frame_limit = 1000;
    char *iwad = NULL;
    int i = 0;

    setvbuf(stdout, NULL, _IONBF, 0);
    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--no-present") == 0) {
            present = 0;
        } else if (strcmp(argv[i], "--frames") == 0 && i + 1 < argc) {
            frame_limit = atoi(argv[++i]);
        } else {
            iwad = argv[i];
        }
    }
    if (iwad == NULL) {
        printf("load=0\n");
        return 2;
    }

    const int width = dg_host_width();
    const int height = dg_host_height();
    SDL_Window *window = NULL;
    SDL_Renderer *renderer = NULL;
    SDL_Texture *texture = NULL;
    if (present) {
        if (!SDL_Init(SDL_INIT_VIDEO)) {
            printf("SDL_Init failed: %s\n", SDL_GetError());
            return 1;
        }
        window = SDL_CreateWindow("doomgeneric (C)", width * WINDOW_SCALE, height * WINDOW_SCALE, 0);
        if (window == NULL) {
            printf("SDL_CreateWindow failed: %s\n", SDL_GetError());
            return 1;
        }
        renderer = SDL_CreateRenderer(window, NULL);
        if (renderer == NULL) {
            printf("SDL_CreateRenderer failed: %s\n", SDL_GetError());
            return 1;
        }
        SDL_SetRenderVSync(renderer, 0);
        texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, width, height);
        if (texture == NULL) {
            printf("SDL_CreateTexture failed: %s\n", SDL_GetError());
            return 1;
        }
        SDL_SetTextureScaleMode(texture, SDL_SCALEMODE_NEAREST);
        printf("video driver: %s, renderer: %s\n", SDL_GetCurrentVideoDriver(), SDL_GetRendererName(renderer));
    } else {
        printf("video driver: none (--no-present)\n");
    }

    const double freq = (double)SDL_GetPerformanceFrequency();
    const Uint64 t0 = SDL_GetPerformanceCounter();
    dg_host_start(iwad);
    const Uint64 t1 = SDL_GetPerformanceCounter();
    const int first_frame = dg_host_frame_count();
    int running = 1;
    SDL_Event event;
    while (running && dg_host_frame_count() < frame_limit) {
        if (present) {
            while (SDL_PollEvent(&event)) {
                if (event.type == SDL_EVENT_QUIT || (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)) {
                    running = 0;
                }
            }
        }
        dg_host_tick();
        uint32_t *pixels = dg_host_frame_argb();
        if (present) {
            SDL_UpdateTexture(texture, NULL, pixels, width * 4);
            SDL_RenderClear(renderer);
            SDL_RenderTexture(renderer, texture, NULL, NULL);
            SDL_RenderPresent(renderer);
        }
    }
    const Uint64 t2 = SDL_GetPerformanceCounter();

    const int frames = dg_host_frame_count();
    const int loop_frames = frames - first_frame;
    const double loop_s = (double)(t2 - t1) / freq;
    for (i = 0; i < frames && i < HASH_LIMIT; i++) {
        printf("frame[%d]=%d\n", i, dg_host_frame_hash(i));
    }
    printf("frames=%d\n", frames);
    printf("setup_us=%lld\n", (long long)((double)(t1 - t0) * 1000000.0 / freq));
    printf("loop_frames=%d\n", loop_frames);
    printf("loop_us=%lld\n", (long long)(loop_s * 1000000.0));
    printf("fps=%.1f\n", loop_s > 0.0 ? (double)loop_frames / loop_s : 0.0);

    if (present) {
        SDL_DestroyTexture(texture);
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
    }
    return 0;
}
