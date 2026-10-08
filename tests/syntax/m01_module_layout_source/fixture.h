/* Shared header of the `--module-layout source` fixture: a record and an
 * enumeration every unit sees (one daslang type in the shared module), an
 * object one unit owns, and the functions the units call across modules. */
#ifndef FIXTURE_H
#define FIXTURE_H
struct pair { int lo; int hi; };
enum mode { MODE_A = 1, MODE_B = 2 };
extern int shared_counter;
int bump(int by);
struct pair split(int v);
int apply(int (*fn)(int), int v);
#endif
