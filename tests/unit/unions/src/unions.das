options gen2

def c2da_min_int(a : int; b : int) : int {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int(a : int; b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint(a : uint; b : uint) : uint {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint(a : uint; b : uint) : uint {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_int64(a : int64; b : int64) : int64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int64(a : int64; b : int64) : int64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint64(a : uint64; b : uint64) : uint64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint64(a : uint64; b : uint64) : uint64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_clip_uint(v : int) : uint {
    if (v < 0) {
        return 0x0
    }
    if (v > 255) {
        return 0xff
    }
    return uint(v)
}
def c2da_bool_to_uint(v : bool) : uint {
    if (v) {
        return 0x1
    } else {
        return 0x0
    }
}
def c2da___assert_fail(expr : void?; file : void?; line : uint; func : void?) {
}
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
    c2da_unnamed : Unnamed
}
struct Unnamed {
    a : int
}
struct packed_union {
    as_int : int
    as_chars : array<int8>
}
[export]
def entry(buffer_size : uint const; var buffer : int?) {
    var i : int = int(0)
    var u1 : my_union = my_union()
    var u2 : my_union = my_union()
    var u3 : my_union = my_union()
    var u4 : my_union_flipped = my_union_flipped()
    var u5 : my_union_flipped = my_union_flipped()
    var u6 : my_union_flipped = my_union_flipped()
    var anon : union_with_anon_struct = union_with_anon_struct()
    var u7 : my_union = my_union()
    i = 0
    u1 = my_union(as_int = 1)
    u2 = my_union(as_int = 2)
    u3 = my_union(as_int = [int8(3), int8(4)])
    u4 = my_union_flipped(as_int = 5)
    u5 = my_union_flipped(as_int = 6)
    u6 = my_union_flipped(as_int = [int8(7), int8(8)])
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(4)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(4)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(4)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(4)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = u1.as_int
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = u2.as_int
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(u3.as_chars[0]))[0]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(u3.as_chars[0]))[1]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(u3.as_chars[0]))[2]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = u4.as_int
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = u5.as_int
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(u6.as_chars[0]))[0]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(u6.as_chars[0]))[1]))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(u6.as_chars[0]))[2]))
    u1.as_int = 8
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = u1.as_int
    unsafe(unsafe(addr(u1.as_chars[0]))[0]) = int8(9)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(u1.as_chars[0]))[0]))
    u4.as_int = 10
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = u4.as_int
    unsafe(unsafe(addr(u4.as_chars[0]))[1]) = int8(12)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = int(unsafe(unsafe(addr(u4.as_chars[0]))[1]))
    u7 = unsafe(reinterpret<my_union>(i))
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = u7.as_int
    return
}
[export] def main() : int {
    return 0
}
