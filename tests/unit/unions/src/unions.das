options gen2

struct my_union {
    as_int : int
    as_chars : array<int8>
}
struct my_union_flipped {
    as_int : int
    as_chars : array<int8>
}
struct empty_union {
}
struct union_with_anon_struct {
    _unnamed : int64
}
struct packed_union {
    as_int : int
    as_chars : array<int8>
}
