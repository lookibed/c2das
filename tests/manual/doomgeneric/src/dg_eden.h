/* The functions the EdenSpark player's platform files call across each other:
 * `dg_eden_play.c` (the platform layer and host API) and `dg_eden_sound.c`
 * (the sound mixer).  Both include this header, so the play build is valid
 * both as the one translation unit `doom_eden_play_all.c` and as separate
 * translation units (`--module-layout source`). */
#ifndef DG_EDEN_H
#define DG_EDEN_H

/* mixes the sound effects of `ms` milliseconds of game time (`dg_eden_sound.c`) */
void dge_audio_mix(unsigned ms);

#endif /* DG_EDEN_H */
