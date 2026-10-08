/* Unit 1: owns the shared object and a function the other units call; its
 * `static helper` shares its name with the other units' statics, which the
 * source layout keeps apart as `private`. */
#include "fixture.h"

int shared_counter = 10;

static int helper(int x) { return x * 2; }

int bump(int by) {
    shared_counter += helper(by);
    return shared_counter;
}
