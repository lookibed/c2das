/* The EdenSpark play build (`doom_eden_play_all.c`) compiles the engine with
 * `FEATURE_SOUND`, upstream's switch for a sound backend, so that `i_sound.c`
 * lists the platform's `DG_sound_module`.  Under `FEATURE_SOUND` upstream
 * `i_sound.c` includes `<SDL_mixer.h>` for its SDL backend, but nothing in
 * `i_sound.c` uses it; the backend here is `dg_eden_sound.c`, not SDL.  This
 * empty header answers that include.  Only the play build puts this directory
 * on the include path (`-Isrc/eden_play_include`), so no other build sees it. */
#ifndef DG_EDEN_PLAY_SDL_MIXER_H
#define DG_EDEN_PLAY_SDL_MIXER_H
#endif
