/* The `eden_gpu` ABI v0 variant of the interactive platform layer
 * `qg_eden_play.c`: the same host API (`qg_eden.h`), but the engine hands
 * every frame and palette to the host itself through the host imports of
 * `qg_eden_gpu.h` instead of the host polling `qge_screen`/`qge_palette`.
 * `QG_DrawFrame` calls `eden_gpu_present(pixels, 320, 240)` and
 * `QG_SetPalette` calls `eden_gpu_palette(rgb768)`; both are bound to
 * `eden/eden_gpu.das` with `--host-import-prefix eden_gpu_=eden_gpu`.  The
 * rest (`qge_init`, `qge_tick`, `qge_key`, `qge_mouse`) is unchanged; see
 * `qg_eden_play.c` for what each function does. */
#include <stdint.h>

#include "quakedef.h"
#include "qg_eden_gpu.h"
#include "quakegeneric.h"

#define QGE_KEY_QUEUE 64

static int qge_frame_count = 0;
static unsigned char *qge_screen_pixels = 0;
static unsigned char qge_palette_rgb[768];
static unsigned qge_clock_ms = 0;
static int qge_key_down[QGE_KEY_QUEUE];
static int qge_key_code[QGE_KEY_QUEUE];
static int qge_key_head = 0;
static int qge_key_tail = 0;
static int qge_mouse_dx = 0;
static int qge_mouse_dy = 0;
static char *qge_argv[8];

/* M2a: the world polygons of cl.worldmodel, batched per texture */
#define QGE_WORLD_VERTS 16384
#define QGE_WORLD_INDICES (QGE_WORLD_VERTS * 3)

static model_t *qge_world_sent = 0;
static float qge_world_verts[QGE_WORLD_VERTS * 8];
static int qge_world_idx[QGE_WORLD_INDICES];
static int qge_world_nverts = 0;
static int qge_world_nidx = 0;

static void qge_world_flush(int tex)
{
    if (qge_world_nidx > 0) {
        eden_gpu_world_mesh(tex, qge_world_verts, qge_world_nverts, qge_world_idx, qge_world_nidx);
    }
    qge_world_nverts = 0;
    qge_world_nidx = 0;
}

/* one surface as a triangle fan; its vertices come from the surfedges
 * (a negative surfedge is the edge walked backwards) */
static void qge_world_surface(model_t *m, msurface_t *s, int tex)
{
    mtexinfo_t *ti = s->texinfo;
    float sw = (float)ti->texture->width;
    float th = (float)ti->texture->height;
    float nx = s->plane->normal[0];
    float ny = s->plane->normal[1];
    float nz = s->plane->normal[2];
    int base = 0;
    int i = 0;

    if (s->numedges < 3 || s->numedges > QGE_WORLD_VERTS) {
        return;
    }
    if (qge_world_nverts + s->numedges > QGE_WORLD_VERTS ||
        qge_world_nidx + (s->numedges - 2) * 3 > QGE_WORLD_INDICES) {
        qge_world_flush(tex);
    }
    if (s->flags & SURF_PLANEBACK) {
        nx = -nx;
        ny = -ny;
        nz = -nz;
    }
    base = qge_world_nverts;
    for (i = 0; i < s->numedges; i++) {
        int e = m->surfedges[s->firstedge + i];
        float *p = 0;
        float *out = &qge_world_verts[qge_world_nverts * 8];

        if (e >= 0) {
            p = m->vertexes[m->edges[e].v[0]].position;
        } else {
            p = m->vertexes[m->edges[-e].v[1]].position;
        }
        out[0] = p[0];
        out[1] = p[1];
        out[2] = p[2];
        out[3] = nx;
        out[4] = ny;
        out[5] = nz;
        out[6] = (DotProduct(p, ti->vecs[0]) + ti->vecs[0][3]) / sw;
        out[7] = (DotProduct(p, ti->vecs[1]) + ti->vecs[1][3]) / th;
        qge_world_nverts += 1;
    }
    for (i = 2; i < s->numedges; i++) {
        qge_world_idx[qge_world_nidx] = base;
        qge_world_idx[qge_world_nidx + 1] = base + i - 1;
        qge_world_idx[qge_world_nidx + 2] = base + i;
        qge_world_nidx += 3;
    }
}

/* the world brush model (submodel 0: not doors, lifts or other brush
 * entities) to the host, one texture at a time; sky is skipped */
static void qge_world_send(model_t *m)
{
    int t = 0;
    int i = 0;

    eden_gpu_world_begin(m->numtextures);
    for (t = 0; t < m->numtextures; t++) {
        texture_t *tx = m->textures[t];

        if (!tx) {
            continue;
        }
        eden_gpu_world_texture(t, (unsigned char *)tx + tx->offsets[0], (int)tx->width, (int)tx->height, host_basepal);
        qge_world_nverts = 0;
        qge_world_nidx = 0;
        for (i = 0; i < m->nummodelsurfaces; i++) {
            msurface_t *s = &m->surfaces[m->firstmodelsurface + i];

            if (s->texinfo->texture != tx || (s->flags & SURF_DRAWSKY)) {
                continue;
            }
            qge_world_surface(m, s, t);
        }
        qge_world_flush(t);
    }
    eden_gpu_world_end();
}

/* map load (a new cl.worldmodel) sends the world; every frame the view */
static void qge_gpu_frame(void)
{
    if (cls.state == ca_connected && cl.worldmodel && cl.worldmodel != qge_world_sent) {
        qge_world_sent = cl.worldmodel;
        qge_world_send(cl.worldmodel);
    }
    if (qge_world_sent) {
        eden_gpu_camera(r_refdef.vieworg[0], r_refdef.vieworg[1], r_refdef.vieworg[2],
                        r_refdef.viewangles[0], r_refdef.viewangles[1], r_refdef.viewangles[2],
                        r_refdef.fov_x, r_refdef.fov_y);
    }
}

void QG_Init(void)
{
}

void QG_Quit(void)
{
}

void QG_DrawFrame(void *pixels)
{
    qge_screen_pixels = (unsigned char *)pixels;
    qge_frame_count += 1;
    eden_gpu_present(qge_screen_pixels, QUAKEGENERIC_RES_X, QUAKEGENERIC_RES_Y);
    qge_gpu_frame();
}

void QG_SetPalette(unsigned char palette[768])
{
    int i = 0;

    for (i = 0; i < 768; i++) {
        qge_palette_rgb[i] = palette[i];
    }
    eden_gpu_palette(qge_palette_rgb);
}

int QG_GetKey(int *down, int *key)
{
    if (qge_key_head == qge_key_tail) {
        return 0;
    }
    *down = qge_key_down[qge_key_head];
    *key = qge_key_code[qge_key_head];
    qge_key_head = (qge_key_head + 1) % QGE_KEY_QUEUE;
    return 1;
}

void QG_GetMouseMove(int *x, int *y)
{
    *x = qge_mouse_dx;
    *y = qge_mouse_dy;
    qge_mouse_dx = 0;
    qge_mouse_dy = 0;
}

void QG_GetJoyAxes(float *axes)
{
    int i = 0;

    for (i = 0; i < QUAKEGENERIC_JOY_MAX_AXES; i++) {
        axes[i] = 0.0f;
    }
}

static int qge_start(int argc)
{
    qge_argv[0] = "quake";
    qge_argv[1] = "-basedir";
    qge_argv[2] = QGE_BASEDIR;
    qge_argv[argc] = 0;
    qge_clock_ms = 0;
    QG_Create(argc, qge_argv);
    return qge_frame_count;
}

int qge_init(void)
{
    return qge_start(3);
}

int qge_init_map(void)
{
    qge_argv[3] = "+map";
    qge_argv[4] = "start";
    return qge_start(5);
}

void qge_tick(unsigned ms)
{
    unsigned elapsed = ms - qge_clock_ms;

    qge_clock_ms = ms;
    QG_Tick((double)elapsed / 1000.0);
}

void qge_key(int pressed, int qkey)
{
    int next = (qge_key_tail + 1) % QGE_KEY_QUEUE;

    if (next == qge_key_head) {
        return;
    }
    qge_key_down[qge_key_tail] = pressed ? 1 : 0;
    qge_key_code[qge_key_tail] = qkey;
    qge_key_tail = next;
}

void qge_mouse(int dx, int dy)
{
    qge_mouse_dx += dx;
    qge_mouse_dy += dy;
}

unsigned qge_screen(void)
{
    return (unsigned)(uintptr_t)qge_screen_pixels;
}

unsigned qge_palette(void)
{
    return (unsigned)(uintptr_t)qge_palette_rgb;
}

int qge_frames(void)
{
    return qge_frame_count;
}

int qge_width(void)
{
    return QUAKEGENERIC_RES_X;
}

int qge_height(void)
{
    return QUAKEGENERIC_RES_Y;
}
