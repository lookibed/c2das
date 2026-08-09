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
struct s {
    x : int
}
struct t {
    y : int
}
[export]
def foo() {
    var x : int = int(0)
    var y : double = double(0)
    var z : float = float(0)
    var n : int = int(0)
    var m : int = int(0)
    var s : s = s()
    var p1 : s? = null
    var p2 : s const? = null
    var t1 : t? = null
    var t2 : t const? = null
    var cx : int const = int(0)
    var ut_y : int = int(0)
    x = 42 + 1
    y = double(42.0) + double(1.0)
    z = double(42.0) + double(1.0)
    n = 0
    n
    m = 0
    n = m
    p1 = unsafe(addr(s))
    p2 = unsafe(addr(s))
    t1 = p1
    t2 = p2
    cx = n
    ut_y = cx
    return
}
[export] def main() : int {
    return 0
}
