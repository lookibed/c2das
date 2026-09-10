/* Static-storage acceptance: a function-scope `static const` table of records
 * is a read-only module object built once, whatever spelling its element type
 * has — anonymous struct, named struct, nested array. Returns 0 on success,
 * N for the failed check. */

enum box_kind {
    BOX_MDHD = 100,
    BOX_MVHD = 101,
    BOX_HDLR = 102,
    BOX_STTS = 103
};

struct entry {
    unsigned name;
    unsigned max_version;
    unsigned use_track_flag;
};

/* File-scope const table of a named struct. */
static const struct entry g_named_table[4] = {
    { BOX_MDHD, 1u, 1u },
    { BOX_MVHD, 1u, 0u },
    { BOX_HDLR, 0u, 0u },
    { BOX_STTS, 0u, 1u }
};

/* File-scope const table of an anonymous struct. */
static const struct {
    int lo;
    int hi;
} g_ranges[3] = { { 0, 10 }, { 10, 20 }, { 20, 30 } };

/* The minimp4 shape: a function-scope static const array of an anonymous
 * struct, hoisted to a module global and indexed in a loop. */
static int anonymous_local_table(unsigned name) {
    static const struct {
        unsigned name;
        unsigned max_version;
        unsigned use_track_flag;
    } g_fullbox[] = {
        { BOX_MDHD, 1u, 1u },
        { BOX_MVHD, 1u, 0u },
        { BOX_HDLR, 0u, 0u },
        { BOX_STTS, 0u, 1u }
    };
    unsigned i;
    for (i = 0; i < sizeof(g_fullbox) / sizeof(g_fullbox[0]); i++) {
        if (g_fullbox[i].name == name) {
            return (int)(g_fullbox[i].max_version * 10u + g_fullbox[i].use_track_flag);
        }
    }
    return -1;
}

static int named_local_table(unsigned name) {
    static const struct entry table[] = {
        { BOX_STTS, 3u, 1u },
        { BOX_HDLR, 2u, 0u }
    };
    int i;
    int found = -1;
    for (i = 0; i < 2; i++) {
        if (table[i].name == name) found = (int)table[i].max_version;
    }
    return found;
}

/* A static const array of arrays, indexed twice. */
static int nested_table(int row, int col) {
    static const int grid[3][4] = {
        { 1, 2, 3, 4 },
        { 5, 6, 7, 8 },
        { 9, 10, 11, 12 }
    };
    return grid[row][col];
}

/* A struct whose own member is an array, in a static const table. */
static int table_of_array_members(int idx) {
    static const struct {
        char tag;
        int values[3];
    } rows[2] = {
        { 'a', { 1, 2, 3 } },
        { 'b', { 4, 5, 6 } }
    };
    return rows[idx].tag * 100 + rows[idx].values[2];
}

/* The table is read-only and shared: two calls see the same object. */
static const struct entry *table_address(void) {
    static const struct entry shared[2] = { { 1u, 2u, 3u }, { 4u, 5u, 6u } };
    return shared;
}

static int summed_over_file_scope(void) {
    int i;
    unsigned total = 0u;
    for (i = 0; i < 4; i++) {
        total += g_named_table[i].name + g_named_table[i].max_version * 1000u +
                 g_named_table[i].use_track_flag * 100000u;
    }
    for (i = 0; i < 3; i++) {
        total += (unsigned)(g_ranges[i].hi - g_ranges[i].lo);
    }
    return (int)total;
}

int const_static_table_runtime(void) {
    if (anonymous_local_table(BOX_MDHD) != 11) return 1;
    if (anonymous_local_table(BOX_MVHD) != 10) return 2;
    if (anonymous_local_table(BOX_HDLR) != 0) return 3;
    if (anonymous_local_table(BOX_STTS) != 1) return 4;
    if (anonymous_local_table(999u) != -1) return 5;
    if (named_local_table(BOX_STTS) != 3) return 6;
    if (named_local_table(BOX_HDLR) != 2) return 7;
    if (named_local_table(BOX_MDHD) != -1) return 8;
    if (nested_table(0, 0) != 1 || nested_table(1, 2) != 7 || nested_table(2, 3) != 12) return 9;
    if (table_of_array_members(0) != 'a' * 100 + 3) return 10;
    if (table_of_array_members(1) != 'b' * 100 + 6) return 11;
    if (table_address() != table_address()) return 12;
    if (table_address()[1].use_track_flag != 6u) return 13;
    if (summed_over_file_scope() != 202436) return 14;
    if (sizeof g_ranges != 3 * 2 * sizeof(int)) return 15;
    return 0;
}
