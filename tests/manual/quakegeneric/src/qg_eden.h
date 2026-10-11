/* The host API of the interactive quakegeneric platform layer
 * `qg_eden_play.c`, which the EdenSpark player
 * (`eden/c2das_quake_player.das`) calls once per frame.  See
 * `qg_eden_play.c` for what each function does. */
#ifndef QG_EDEN_H
#define QG_EDEN_H

/* the base directory the engine is started with: the host registers the
 * shareware pak as QGE_PAK_NAME with `c2da_eden_add_file` */
#define QGE_BASEDIR "quake"
#define QGE_PAK_NAME "quake/id1/pak0.pak"

int qge_init(void);
int qge_init_map(void);
void qge_tick(unsigned ms);
void qge_key(int pressed, int qkey);
void qge_mouse(int dx, int dy);
unsigned qge_screen(void);
unsigned qge_palette(void);
int qge_frames(void);
int qge_width(void);
int qge_height(void);

#endif /* QG_EDEN_H */
