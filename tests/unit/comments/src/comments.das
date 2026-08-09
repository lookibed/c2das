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
[export]
def test_fn() : int {
    var x : int = int(0)
    x = 0
    x
    while (true) {
        if (!x < 5) {
            if (false) {
            }
        }
        x = x + 1
        x
    }
    if (x > 100) {
        x = 10
    } elif (x > 200) {
        x = 12
    } else {
        x = x
    }
    if (x > 50) {
        x = 20
    } elif (x > 75) {
        x = 13
    }
    return x + 1
}
[export]
def a_function() : int {
    return 1
}
[export]
def header_fn2(var x_0 : int) : int {
    return x_0
}
[export]
def header_fn(var x_1 : int) : int {
    return x_1
}
[export] def main() : int {
    return 0
}
