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
def long_double_ops(var a : double?) : double {
    var b : double = double(0)
    var rounder : double = double(0)
    var realvalue : double = double(0)
    b = double(1.3)
    rounder = double(0.0)
    realvalue = double(double(0.0))
    rounder = rounder + double(realvalue) * double(double(0.0000000000000003))
    *a = *a + double(1)
    *a
    *a = *a + double(1)
    *a
    b = b + double(1)
    b
    b = b + double(1)
    b
    *a = *a - b
    b = b + *a
    *a = *a / double(2)
    b = b / double(2)
    *a = *a - double(1)
    *a
    *a = *a - double(1)
    *a
    b = b - double(1)
    b
    b = b - double(1)
    b
    *a = *a * double(3)
    b = b * double(3)
    *a = *a + double(1)
    b = b + double(1)
    *a = *a + double(1)
    b = *a
    *a = *a + double(1)
    b = *a
    b = b - double(1)
    *a = b
    b = b - double(1)
    *a = b
    return b
}
[export]
def cast2double(var a_0 : double) : double {
    return a_0
}
[export]
def cast2float(var a_1 : double) : float {
    return float(a_1)
}
[export]
def cast2uint(var a_2 : double) : uint {
    return uint(float(a_2))
}
var ld1 : double const = double(double(double(1.0)))

var ld2 : double const = double(double(ld1) + double(double(2.0)))
[export] def main() : int {
    return 0
}
