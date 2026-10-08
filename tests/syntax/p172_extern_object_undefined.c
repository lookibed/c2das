/* Negative fixture: a file-scope object declared `extern` and defined in no
 * part of this translation unit names an object another unit owns.  The
 * translator has no program-wide symbol table, so it must refuse the
 * declaration with a located diagnostic instead of giving this unit a fresh
 * object of that name.
 *
 * The two shapes that *are* definitions stay accepted, as the first lines
 * show: `extern` followed by a definition in the same unit, and a tentative
 * definition (`int tentative;`).
 */

extern int defined_later;
int defined_later = 7;

int tentative;

extern int owned_elsewhere;

int read_them(void) {
    return defined_later + tentative + owned_elsewhere;
}
