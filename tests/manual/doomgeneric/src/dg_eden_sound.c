/* The sound platform of the EdenSpark player: doomgeneric's `DG_sound_module`
 * (the `sound_module_t` upstream's `i_sound.c` lists under `FEATURE_SOUND`)
 * as a small software mixer, plus a silent `DG_music_module` (the player
 * passes `-nomusic`, so no music call reaches it).
 *
 * - A started sound is a DMX sound lump (`ds*`): format 3, the sample rate,
 *   the sample count, then 8-bit unsigned PCM whose first and last 16 bytes
 *   DMX skips (as upstream's `i_sdlsound.c` does).
 * - Each of `DGE_VOICES` voices plays one lump, resampled to
 *   `DGE_AUDIO_RATE` by a 16.16 step, with the left and right gains
 *   upstream's SDL backend derives from `vol` and `sep`.
 * - `dge_audio_mix(ms)` (called by `dge_tick` with the game time that
 *   passed) mixes `DGE_AUDIO_RATE * ms / 1000` stereo frames into the
 *   interleaved int16 buffer `dge_audio_buf`, so the audio follows the game
 *   clock and not the host's wall clock.
 * - The host reads `dge_audio_frames()` frames at `dge_audio_buffer()` (a
 *   heap offset under `--memory-model linear`) and then calls
 *   `dge_audio_consume()`.  Frames mixed while the buffer is full are
 *   dropped (counted by `dge_audio_dropped`). */
#include <stdint.h>

#include "doomtype.h"
#include "i_sound.h"
#include "w_wad.h"
#include "z_zone.h"

#define DGE_AUDIO_RATE 11025
#define DGE_VOICES 16
#define DGE_AUDIO_MAX_FRAMES 4096

/* the libsamplerate settings `i_sound.c` binds under FEATURE_SOUND (unused) */
int use_libsamplerate = 0;
float libsamplerate_scale = 0.65f;

typedef struct {
    const unsigned char *data; /* 8-bit unsigned PCM; NULL when the voice is idle */
    unsigned length;           /* samples */
    unsigned pos;              /* whole samples played */
    unsigned frac;             /* 16-bit fraction of the next sample */
    unsigned step;             /* 16.16 source samples per output frame */
    int left;                  /* 0..255 */
    int right;                 /* 0..255 */
} dge_voice_t;

static dge_voice_t dge_voices[DGE_VOICES];
static boolean dge_sfx_prefix = true;
static short dge_audio_buf[DGE_AUDIO_MAX_FRAMES * 2];
static int dge_audio_count = 0;
static unsigned dge_audio_acc = 0;
static int dge_audio_peak_abs = 0;
static unsigned dge_audio_total = 0;
static unsigned dge_audio_drop = 0;
static int dge_sound_starts = 0;

static snddevice_t dge_sound_devices[] = {
    SNDDEVICE_SB,
    SNDDEVICE_PAS,
    SNDDEVICE_GUS,
    SNDDEVICE_WAVEBLASTER,
    SNDDEVICE_SOUNDCANVAS,
    SNDDEVICE_AWE32,
};

static boolean dge_sound_init(boolean use_sfx_prefix)
{
    int i;

    dge_sfx_prefix = use_sfx_prefix;
    for (i = 0; i < DGE_VOICES; ++i) {
        dge_voices[i].data = NULL;
    }
    return true;
}

static void dge_sound_shutdown(void)
{
}

/* the lump of `sfx` (or of the sound it links to), "ds" + name; -1 when the
 * IWAD has none */
static int dge_sound_lump(sfxinfo_t *sfx)
{
    char name[9];
    int at = 0;
    int i;

    if (sfx->link != NULL) {
        sfx = sfx->link;
    }
    if (dge_sfx_prefix) {
        name[at++] = 'd';
        name[at++] = 's';
    }
    for (i = 0; sfx->name[i] != '\0' && at < 8; ++i) {
        name[at++] = sfx->name[i];
    }
    name[at] = '\0';
    return W_CheckNumForName(name);
}

static void dge_sound_update(void)
{
}

static void dge_sound_params(int channel, int vol, int sep)
{
    int left;
    int right;

    if (channel < 0 || channel >= DGE_VOICES) {
        return;
    }
    left = ((254 - sep) * vol) / 127;
    right = (sep * vol) / 127;
    dge_voices[channel].left = left < 0 ? 0 : (left > 255 ? 255 : left);
    dge_voices[channel].right = right < 0 ? 0 : (right > 255 ? 255 : right);
}

static int dge_sound_start(sfxinfo_t *sfxinfo, int channel, int vol, int sep)
{
    const unsigned char *data;
    unsigned lumplen;
    unsigned rate;
    unsigned length;

    if (channel < 0 || channel >= DGE_VOICES) {
        return -1;
    }
    dge_voices[channel].data = NULL;
    if (sfxinfo->lumpnum < 0) {
        return -1;
    }
    lumplen = (unsigned)W_LumpLength((unsigned)sfxinfo->lumpnum);
    data = W_CacheLumpNum(sfxinfo->lumpnum, PU_STATIC);
    if (lumplen < 8 || data[0] != 0x03 || data[1] != 0x00) {
        return -1;
    }
    rate = (unsigned)data[2] | ((unsigned)data[3] << 8);
    length = (unsigned)data[4] | ((unsigned)data[5] << 8) | ((unsigned)data[6] << 16)
             | ((unsigned)data[7] << 24);
    if (length > lumplen - 8 || length <= 48 || rate == 0) {
        return -1;
    }
    dge_voices[channel].data = data + 8 + 16;
    dge_voices[channel].length = length - 32;
    dge_voices[channel].pos = 0;
    dge_voices[channel].frac = 0;
    dge_voices[channel].step = (rate << 16) / DGE_AUDIO_RATE;
    dge_sound_params(channel, vol, sep);
    dge_sound_starts += 1;
    return channel;
}

static void dge_sound_stop(int channel)
{
    if (channel >= 0 && channel < DGE_VOICES) {
        dge_voices[channel].data = NULL;
    }
}

static boolean dge_sound_playing(int channel)
{
    if (channel < 0 || channel >= DGE_VOICES) {
        return false;
    }
    return dge_voices[channel].data != NULL;
}

sound_module_t DG_sound_module = {
    dge_sound_devices,
    (int)(sizeof(dge_sound_devices) / sizeof(dge_sound_devices[0])),
    dge_sound_init,
    dge_sound_shutdown,
    dge_sound_lump,
    dge_sound_update,
    dge_sound_params,
    dge_sound_start,
    dge_sound_stop,
    dge_sound_playing,
    NULL,
};

/* music: none (the player passes -nomusic); the module only has to exist */
static boolean dge_music_init(void)
{
    return false;
}

static void dge_music_void(void)
{
}

static void dge_music_volume(int volume)
{
    (void)volume;
}

static void *dge_music_register(void *data, int len)
{
    (void)data;
    (void)len;
    return NULL;
}

static void dge_music_unregister(void *handle)
{
    (void)handle;
}

static void dge_music_play(void *handle, boolean looping)
{
    (void)handle;
    (void)looping;
}

static boolean dge_music_playing(void)
{
    return false;
}

music_module_t DG_music_module = {
    NULL,
    0,
    dge_music_init,
    dge_music_void,
    dge_music_volume,
    dge_music_void,
    dge_music_void,
    dge_music_register,
    dge_music_unregister,
    dge_music_play,
    dge_music_void,
    dge_music_playing,
    dge_music_void,
};

/* the unclamped sums of the frames being mixed */
static int dge_audio_sum[DGE_AUDIO_MAX_FRAMES * 2];

/* mixes the frames of `ms` milliseconds of game time.  Voice by voice, with
 * the voice's state in locals for the inner loop: the player runs this in an
 * interpreter, where every access to a static is a heap access. */
static void dge_audio_mix(unsigned ms)
{
    int frames;
    int kept;
    int active = 0;
    int f;
    int i;

    if (ms > 1000u) {
        ms = 1000u;
    }
    dge_audio_acc += ms * DGE_AUDIO_RATE;
    frames = (int)(dge_audio_acc / 1000u);
    dge_audio_acc %= 1000u;
    kept = DGE_AUDIO_MAX_FRAMES - dge_audio_count;
    if (kept > frames) {
        kept = frames;
    }
    for (i = 0; i < DGE_VOICES; ++i) {
        const unsigned char *data = dge_voices[i].data;
        unsigned length;
        unsigned pos;
        unsigned frac;
        unsigned step;
        int left;
        int right;

        if (data == NULL) {
            continue;
        }
        if (active == 0) {
            for (f = 0; f < kept * 2; ++f) {
                dge_audio_sum[f] = 0;
            }
            active = 1;
        }
        length = dge_voices[i].length;
        pos = dge_voices[i].pos;
        frac = dge_voices[i].frac;
        step = dge_voices[i].step;
        left = dge_voices[i].left;
        right = dge_voices[i].right;
        /* frames past `kept` are dropped, but the voice still plays through them */
        for (f = 0; f < frames; ++f) {
            int sample = (int)data[pos] - 128;

            if (f < kept) {
                dge_audio_sum[f * 2] += sample * left;
                dge_audio_sum[f * 2 + 1] += sample * right;
            }
            frac += step;
            pos += frac >> 16;
            frac &= 0xffffu;
            if (pos >= length) {
                data = NULL;
                break;
            }
        }
        dge_voices[i].data = data;
        dge_voices[i].pos = pos;
        dge_voices[i].frac = frac;
    }
    for (f = 0; f < kept * 2; ++f) {
        int value = 0;
        int magnitude;

        if (active) {
            value = dge_audio_sum[f];
            value = value < -32768 ? -32768 : (value > 32767 ? 32767 : value);
        }
        dge_audio_buf[dge_audio_count * 2 + f] = (short)value;
        magnitude = value < 0 ? -value : value;
        if (magnitude > dge_audio_peak_abs) {
            dge_audio_peak_abs = magnitude;
        }
    }
    dge_audio_count += kept;
    dge_audio_drop += (unsigned)(frames - kept);
    dge_audio_total += (unsigned)frames;
}

int dge_audio_rate(void)
{
    return DGE_AUDIO_RATE;
}

/* the address of the interleaved int16 stereo frames mixed since the last
 * `dge_audio_consume` (a heap offset under --memory-model linear) */
unsigned dge_audio_buffer(void)
{
    return (unsigned)(uintptr_t)dge_audio_buf;
}

int dge_audio_frames(void)
{
    return dge_audio_count;
}

void dge_audio_consume(void)
{
    dge_audio_count = 0;
}

/* statistics: the largest |sample| so far, frames mixed, frames dropped
 * while the buffer was full, sounds started */
int dge_audio_peak(void)
{
    return dge_audio_peak_abs;
}

unsigned dge_audio_mixed(void)
{
    return dge_audio_total;
}

unsigned dge_audio_dropped(void)
{
    return dge_audio_drop;
}

int dge_audio_starts(void)
{
    return dge_sound_starts;
}
