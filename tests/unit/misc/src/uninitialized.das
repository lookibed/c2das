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
typedef myint = int
typedef myintp = int?
struct u {
    x : int
    y : int8
}
enum e : uint {
    foo = 1
    bar = 2
    baz = 3
}
struct s {
    a_u : u
    a_c : int8
    a_e : e
}
[export]
def entry2(sz : uint const; var buf : int?) {
    var x : int = int(0)
    var p : myintp = unsafe(reinterpret<myintp>(0))
    var q1 : int const? = null
    var q2 : int const? = null
    var q3 : int? = null
    var q4 : int? = null
    var f : function? = null
    var fs : array<function?> = []
    var xs : array<int> = []
    var ys : array<array<int>> = []
    var zs : array<int?> = []
    var my_s : s = s()
    var my_u : u = u()
    p = unsafe(addr(x))
    *p = 1
    if (uint(sz) > uint(0)) {
        *buf = x
    }
    return
}
var baz : int = 3

var bar : int = 2

var foo : int = 1
[export] def main() : int {
    return 0
}
