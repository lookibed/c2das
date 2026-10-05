/* A call whose result is unused still happens, and `(T *) 0` is null.
 *
 * daslang removes a call to a function it infers to have no side effects when
 * the result is unused, and its inference misses a store through a pointer
 * computed from a raw address and held in a local — the shape every C pointer
 * write is lowered to.  Doom's `DecreaseAmmo` (`player->ammo[k] -= n` or
 * `player->maxammo[k - NUMAMMO] -= n`) vanished that way once `NUMAMMO` was a
 * literal, from frame 124 of demo1.  The translator marks every function
 * `[sideeffects]`.
 *
 * A null pointer constant converted explicitly — `(state_t *) S_NULL` with an
 * enumeration constant 0 — is the null pointer (C11 6.3.2.3p3), not the bits of
 * a four-byte `int` read as an eight-byte address. */
#include <stdio.h>

enum { NUMAMMO = 4, S_NULL = 0 };

typedef struct {
    int pad[3];
    int ammo[NUMAMMO];
    int maxammo[NUMAMMO];
} player_t;

typedef struct state { int tics; } state_t;

typedef struct {
    state_t *state;
    int health;
} mobj_t;

static void decrease_ammo(player_t *player, int ammonum, int amount) {
    if (ammonum < NUMAMMO) {
        player->ammo[ammonum] -= amount;
    } else {
        player->maxammo[ammonum - NUMAMMO] -= amount;
    }
}

static void bump(int *cell, int k) {
    int *slot = cell + k;
    *slot += 10;
}

static int clear_state(mobj_t *mobj, int state) {
    if (state == S_NULL) {
        mobj->state = (state_t *) S_NULL;
        return 0;
    }
    return 1;
}

int main(void) {
    static const int picks[7] = {1, 1, 0, 3, 5, 1, 2};
    player_t player;
    int cells[4] = {0, 0, 0, 0};
    state_t some = {7};
    mobj_t mobj = {&some, 100};
    int i;

    for (i = 0; i < NUMAMMO; i++) {
        player.ammo[i] = 50;
        player.maxammo[i] = 200;
    }
    for (i = 0; i < 7; i++) {
        decrease_ammo(&player, picks[i], 1);
        bump(cells, picks[i] & 3);
    }
    printf("ammo %d %d %d %d max %d %d\n", player.ammo[0], player.ammo[1], player.ammo[2],
           player.ammo[3], player.maxammo[0], player.maxammo[1]);
    printf("cells %d %d %d %d\n", cells[0], cells[1], cells[2], cells[3]);
    printf("cleared %d null %d\n", clear_state(&mobj, S_NULL), mobj.state == 0);
    return 0;
}
