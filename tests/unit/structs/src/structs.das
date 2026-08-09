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
typedef size_t = uint64
struct int_pair_s {
    x : int
    y : int
}
struct Unnamed {
    y : int
}
struct Unnamed_0 {
    c2da_unnamed : Unnamed_1
    c2da_unnamed_0 : Unnamed
}
struct Unnamed_1 {
    x : int
}
struct Unnamed_2 {
    n : Unnamed_3
    z : int
}
struct Unnamed_3 {
    x : int
    y : int
}
struct Aligned8Struct {
    a : int
    b : int64
}
struct S1 {
    c : int8
    s : int
    ll : int64
}
struct S2 {
    c : int8
    s : int
    ll : int64
}
struct S3 {
    c : int8
    s : int
    ll : int64
}
struct S4 {
    c : int8
    s : int
    ll : int64
}
struct S5 {
    c : int8
    s : int
    ll : int64
}
struct S6 {
    c : int8
    s : int
    ll : int64
}
struct S7 {
    c : int8
    s : int
    ll : int64
}
struct S8 {
    c : int8
    s : int
    ll : int64
}
struct S9 {
    c : int8
    s : int
    ll : int64
}
struct S10 {
    c : int8
    s : int
    ll : int64
}
struct S11 {
    c : int8
    s : int
    ll : int64
}
struct S12 {
    c : int8
    s : int
    ll : int64
}
struct S13 {
    c : int8
    s : int
    ll : int64
}
struct S14 {
    c : int8
    s : int
    ll : int64
}
struct S15 {
    c : int8
    s : int
    ll : int64
}
struct S16 {
    c : int8
    s : int
    ll : int64
}
struct S17 {
    c : int8
    s : S7
}
struct S18 {
    c : int8
    s : S8
}
struct S19 {
    c : int8
    s : S9
}
struct S20 {
    c : int8
    s : S10
}
struct S21 {
    c : int8
    s : S11
}
struct S22 {
    c : int8
    s : S12
}
struct S23 {
    c : int8
    s : S13
}
struct S24 {
    c : int8
    s : S14
}
struct S25 {
    c : int8
    s : S15
}
struct S26 {
    c : int8
    s : S16
}
struct S27 {
    c : int8
    s : S7
}
struct S28 {
    c : int8
    s : S8
}
struct S29 {
    c : int8
    s : S9
}
struct S30 {
    c : int8
    s : S10
}
struct S31 {
    c : int8
    s : S11
}
struct S32 {
    c : int8
    s : S12
}
struct S33 {
    c : int8
    s : S13
}
struct S34 {
    c : int8
    s : S14
}
struct S35 {
    c : int8
    s : S15
}
struct S36 {
    c : int8
    s : S16
}
[export]
def entry(sz : uint const; var buf : int?) {
    var local : Unnamed_2 = Unnamed_2()
    var i : int = int(0)
    var pair1 : int_pair_s = int_pair_s()
    var pair2 : int_pair_s = int_pair_s()
    var uninit : int_pair_s = int_pair_s()
    var z : Unnamed_0 = Unnamed_0()
    local = Unnamed_2(n = Unnamed_3(x = 1, y = 2), z = 3)
    i = 0
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = local.n.x
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = local.n.y
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = local.z
    pair1.x = 10
    pair1.y = 20
    pair2 = pair1
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = pair2.x
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = pair2.y
    uninit = int_pair_s(x = 0, y = 0)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = uninit.x
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = uninit.y
    z = Unnamed_0(c2da_unnamed = Unnamed_1(x = 0), c2da_unnamed_0 = 0)
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = z.c2da_unnamed.x
    i = i + 1
    unsafe(unsafe(unsafe(reinterpret<int?>(buf)))[uint(i)]) = z.c2da_unnamed_0.y
    return
}
[export]
def alignment_of_aligned8_struct() : size_t {
    return 4
}
[export]
def alignment_entry(sz_0 : uint const; var buf_0 : int?) {
    var i_0 : int = int(0)
    var s : S1 = S1()
    var sz_1 : S1 = S1()
    var s_0 : S2 = S2()
    var sz_2 : S2 = S2()
    var s_1 : S3 = S3()
    var sz_3 : S3 = S3()
    var s_2 : S4 = S4()
    var sz_4 : S4 = S4()
    var s_3 : S5 = S5()
    var sz_5 : S5 = S5()
    var s_4 : S6 = S6()
    var sz_6 : S6 = S6()
    var s_5 : S7 = S7()
    var sz_7 : S7 = S7()
    var s_6 : S8 = S8()
    var sz_8 : S8 = S8()
    var s_7 : S9 = S9()
    var sz_9 : S9 = S9()
    var s_8 : S10 = S10()
    var sz_10 : S10 = S10()
    var s_9 : S11 = S11()
    var sz_11 : S11 = S11()
    var s_10 : S12 = S12()
    var sz_12 : S12 = S12()
    var s_11 : S13 = S13()
    var sz_13 : S13 = S13()
    var s_12 : S14 = S14()
    var sz_14 : S14 = S14()
    var s_13 : S15 = S15()
    var sz_15 : S15 = S15()
    var s_14 : S16 = S16()
    var sz_16 : S16 = S16()
    var s_15 : S17 = S17()
    var s_16 : S18 = S18()
    var s_17 : S19 = S19()
    var s_18 : S20 = S20()
    var s_19 : S21 = S21()
    var s_20 : S22 = S22()
    var s_21 : S23 = S23()
    var s_22 : S24 = S24()
    var s_23 : S25 = S25()
    var s_24 : S26 = S26()
    var s_25 : S27 = S27()
    var s_26 : S28 = S28()
    var s_27 : S29 = S29()
    var s_28 : S30 = S30()
    var s_29 : S31 = S31()
    var s_30 : S32 = S32()
    var s_31 : S33 = S33()
    var s_32 : S34 = S34()
    var s_33 : S35 = S35()
    var s_34 : S36 = S36()
    i_0 = 0
    while (true) {
        s = S1(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_1 = S1(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_1.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_1.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_1.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_0 = S2(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_0.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_0.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_0.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_2 = S2(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_2.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_2.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_2.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_1 = S3(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_1.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_1.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_1.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_3 = S3(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_3.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_3.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_3.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_2 = S4(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_2.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_2.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_2.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_4 = S4(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_4.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_4.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_4.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_3 = S5(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_3.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_3.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_3.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_5 = S5(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_5.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_5.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_5.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_4 = S6(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_4.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_4.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_4.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_6 = S6(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_6.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_6.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_6.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_5 = S7(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_5.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_5.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_5.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_7 = S7(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_7.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_7.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_7.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_6 = S8(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_6.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_6.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_6.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_8 = S8(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_8.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_8.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_8.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_7 = S9(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_7.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_7.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_7.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_9 = S9(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_9.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_9.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_9.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_8 = S10(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_8.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_8.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_8.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_10 = S10(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_10.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_10.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_10.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_9 = S11(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_9.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_9.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_9.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_11 = S11(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_11.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_11.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_11.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_10 = S12(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_10.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_10.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_10.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_12 = S12(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_12.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_12.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_12.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_11 = S13(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_11.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_11.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_11.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_13 = S13(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_13.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_13.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_13.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_12 = S14(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_12.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_12.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_12.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_14 = S14(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_14.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_14.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_14.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_13 = S15(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_13.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_13.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_13.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_15 = S15(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_15.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_15.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_15.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_14 = S16(c = int8(42), s = 1337, ll = int64(65537))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_14.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = s_14.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(s_14.ll)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        sz_16 = S16(c = 0, s = 0, ll = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_16.c)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = sz_16.s
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(sz_16.ll)
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_15 = S17(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_16 = S18(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_17 = S19(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_18 = S20(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_19 = S21(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_20 = S22(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_21 = S23(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_22 = S24(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_23 = S25(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_24 = S26(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_25 = S27(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_26 = S28(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_27 = S29(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_28 = S30(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_29 = S31(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_30 = S32(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_31 = S33(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_32 = S34(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_33 = S35(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    while (true) {
        s_34 = S36(c = 0, s = 0)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(4)
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        i_0 = i_0 + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buf_0)))[uint(i_0)]) = int(uint64(0))
        if (!(uint64(0) != uint64(0))) {
            if (false) {
            }
        }
    }
    return
}
[export] def main() : int {
    return 0
}
