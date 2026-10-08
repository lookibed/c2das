/* Header of the `--module-layout source` fixture whose cycle units declare
 * same-named file-scope statics and a same-named file-local typedef: the two
 * units `left.c` and `right.c` call each other and share one daslang module,
 * where each static keeps its own storage. */
#ifndef CYCLE_H
#define CYCLE_H
int left_step(int v);
int right_step(int v);
int left_total(void);
int right_total(void);
extern int shared_count;
#endif
