/* Read-modify-write through an address-backed place.
 *
 * `p->inner.m += k`, `p->slice->n++` and their bitfield/union/packed variants
 * name one C lvalue that is read and then written back.  The address of such a
 * place is not always a bare name: a nested aggregate reached through a
 * pointer, an array-of-one member that decays, an element chosen by an
 * expression with side effects — each needs statements of its own before the
 * place can be touched.  C evaluates that place exactly once, so those
 * statements must be emitted once and shared by the load and the store.
 *
 * Returns 0 on success, or the number of the first failed check.
 */

#include <stdint.h>
#include <stdlib.h>

struct rmw_inner {
    uint32_t n;
    uint32_t m;
};

struct rmw_outer {
    uint32_t tag;
    struct rmw_inner inner;
    /* An array of one: `outer->slice` decays, so the place's address is bound
     * to a temporary of its own (the h264bsd `pStorage->slice->...` shape). */
    struct rmw_inner slice[1];
};

union rmw_union {
    uint32_t word;
    uint16_t halves[2];
};

struct rmw_holder {
    uint32_t tag;
    union rmw_union u;
};

struct rmw_bits {
    unsigned a : 5;
    unsigned b : 7;
    int c : 4;
};

struct rmw_bits_outer {
    uint32_t tag;
    struct rmw_bits bits;
    struct rmw_bits slice[1];
};

struct __attribute__((packed)) rmw_packed_inner {
    uint32_t n;
    uint32_t m;
};

struct __attribute__((packed)) rmw_packed_outer {
    uint8_t tag;
    struct rmw_packed_inner inner;
    struct rmw_packed_inner elems[3];
};

static int nested_through_pointer(void) {
    struct rmw_outer *outer = calloc(1, sizeof *outer);
    int failed = 0;

    outer->inner.n = 100u;
    outer->inner.m = 8u;
    outer->inner.n += 5u;
    outer->inner.n -= 2u;
    outer->inner.m |= 3u;
    outer->inner.m <<= 2u;
    if (outer->inner.n != 103u) {
        failed = 1;
    } else if (outer->inner.m != 44u) {
        failed = 2;
    }

    free(outer);
    return failed;
}

static int decayed_array_of_one(void) {
    struct rmw_outer *outer = calloc(1, sizeof *outer);
    uint32_t post;
    uint32_t pre;
    int failed = 0;

    outer->slice->n = 7u;
    outer->slice->m = 1u;
    outer->slice->n += 3u;
    outer->slice->m <<= 4u;
    outer->slice->n++;
    ++outer->slice->m;
    if (outer->slice->n != 11u) {
        failed = 3;
    } else if (outer->slice->m != 17u) {
        failed = 4;
    }

    post = outer->slice->n++;
    pre = ++outer->slice->m;
    if (!failed && (post != 11u || outer->slice->n != 12u)) {
        failed = 5;
    }
    if (!failed && (pre != 18u || outer->slice->m != 18u)) {
        failed = 6;
    }

    post = outer->slice->n--;
    pre = --outer->slice->m;
    if (!failed && (post != 12u || outer->slice->n != 11u)) {
        failed = 7;
    }
    if (!failed && (pre != 17u || outer->slice->m != 17u)) {
        failed = 8;
    }

    /* The stored value is the expression's own value, and the place is still
     * read and written only once. */
    if (!failed && (outer->slice->n += 4u) != 15u) {
        failed = 9;
    }
    if (!failed && outer->slice->n != 15u) {
        failed = 10;
    }

    free(outer);
    return failed;
}

static int through_pointer_to_pointer(void) {
    struct rmw_outer *outer = calloc(1, sizeof *outer);
    struct rmw_outer **indirect = calloc(1, sizeof *indirect);
    int failed = 0;

    *indirect = outer;
    (*indirect)->inner.n = 3u;
    (*indirect)->inner.n += 7u;
    (*indirect)->slice->m = 17u;
    (*indirect)->slice->m -= 3u;
    (*indirect)->slice->n++;
    if (outer->inner.n != 10u) {
        failed = 11;
    } else if (outer->slice->m != 14u) {
        failed = 12;
    } else if (outer->slice->n != 1u) {
        failed = 13;
    }

    free(indirect);
    free(outer);
    return failed;
}

static int indexed_by_side_effect(void) {
    struct rmw_outer *natural = calloc(3, sizeof *natural);
    struct rmw_packed_outer *packed = calloc(1, sizeof *packed);
    /* Element addresses of a packed record are computed, so the place's
     * address is bound to a temporary before it can be read and written. */
    struct rmw_packed_inner *elem = packed->elems;
    unsigned i = 0;
    unsigned j = 0;
    int failed = 0;

    /* The index runs once per assignment, so each one hits its own element. */
    natural[i++].inner.m += 1u;
    natural[i++].inner.m += 10u;
    if (i != 2u) {
        failed = 14;
    } else if (natural[0].inner.m != 1u || natural[1].inner.m != 10u) {
        failed = 15;
    } else if (natural[2].inner.m != 0u) {
        failed = 16;
    }

    elem[j++].n += 5u;
    elem[j++].n |= 6u;
    if (!failed && j != 2u) {
        failed = 17;
    }
    if (!failed && (elem[0].n != 5u || elem[1].n != 6u || elem[2].n != 0u)) {
        failed = 18;
    }
    if (!failed && packed->tag != 0u) {
        failed = 19;
    }

    free(packed);
    free(natural);
    return failed;
}

static int packed_parent(void) {
    struct rmw_packed_outer *packed = calloc(1, sizeof *packed);
    uint32_t post;
    int failed = 0;

    packed->tag = 0xa5u;
    packed->inner.n = 5u;
    packed->inner.n += 6u;
    packed->inner.m = 2u;
    packed->inner.m <<= 3u;
    post = packed->inner.n++;
    if (packed->inner.n != 12u) {
        failed = 20;
    } else if (post != 11u) {
        failed = 21;
    } else if (packed->inner.m != 16u) {
        failed = 22;
    } else if (packed->tag != 0xa5u) {
        failed = 23;
    }

    free(packed);
    return failed;
}

static int union_member_through_pointer(void) {
    struct rmw_holder *holder = calloc(1, sizeof *holder);
    int failed = 0;

    holder->u.word = 0x00010002u;
    holder->u.word += 0x00020001u;
    if (holder->u.word != 0x00030003u) {
        failed = 24;
    }
    holder->u.word |= 0x0000f000u;
    if (!failed && holder->u.word != 0x0003f003u) {
        failed = 25;
    }
    holder->u.halves[0]++;
    if (!failed && holder->u.halves[0] != 0xf004u) {
        failed = 26;
    }
    if (!failed && holder->tag != 0u) {
        failed = 27;
    }

    free(holder);
    return failed;
}

static int nested_bitfields(void) {
    struct rmw_bits_outer *object = calloc(1, sizeof *object);
    unsigned post;
    int failed = 0;

    object->bits.a = 3u;
    object->bits.a += 4u;
    object->bits.b = 100u;
    object->bits.b -= 36u;
    object->bits.c = -2;
    object->bits.c += 1;
    if (object->bits.a != 7u) {
        failed = 28;
    } else if (object->bits.b != 64u) {
        failed = 29;
    } else if (object->bits.c != -1) {
        failed = 30;
    }

    /* The same bitfield, but behind a decayed array member: the address needs
     * a statement before the read-modify-write can run. */
    object->slice->a = 3u;
    object->slice->a += 4u;
    object->slice->b = 100u;
    post = object->slice->b--;
    ++object->slice->a;
    if (!failed && object->slice->a != 8u) {
        failed = 31;
    }
    if (!failed && (post != 100u || object->slice->b != 99u)) {
        failed = 32;
    }
    if (!failed && object->tag != 0u) {
        failed = 33;
    }

    free(object);
    return failed;
}

int nested_place_rmw_runtime(void) {
    int failed = nested_through_pointer();
    if (failed) {
        return failed;
    }
    failed = decayed_array_of_one();
    if (failed) {
        return failed;
    }
    failed = through_pointer_to_pointer();
    if (failed) {
        return failed;
    }
    failed = indexed_by_side_effect();
    if (failed) {
        return failed;
    }
    failed = packed_parent();
    if (failed) {
        return failed;
    }
    failed = union_member_through_pointer();
    if (failed) {
        return failed;
    }
    return nested_bitfields();
}
