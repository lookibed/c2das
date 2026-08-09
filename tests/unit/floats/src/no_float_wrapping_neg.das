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
typedef f32 = float
typedef f64 = double
[export]
def no_wrapping_neg() : double {
    var a : double = double(0)
    a = -double(1.0)
    return a
}
[export]
def float_inc_dec() : float {
    var a_0 : float = float(0)
    var b : float = float(0)
    var c : float = float(0)
    a_0 = float(double(1.1))
    b = float(double(2.2))
    c = float(double(3.3))
    a_0 = a_0 + float(1)
    a_0
    b = b - float(1)
    b
    a_0 = a_0 + float(1)
    a_0
    b = b - float(1)
    b
    b = b + float(1)
    a_0 = b
    b = b + float(1)
    a_0 = b
    a_0 = a_0 - float(1)
    b = a_0
    a_0 = a_0 - float(1)
    b = a_0
    c = c + float(1)
    c
    c = c + float(1)
    c
    c = c - float(1)
    c
    c = c - float(1)
    c
    return a_0
}
[export]
def double_inc_dec() : double {
    var a_1 : double = double(0)
    var b_0 : double = double(0)
    var c_0 : double = double(0)
    a_1 = double(1.1)
    b_0 = double(2.2)
    c_0 = double(3.3)
    a_1 = a_1 + double(1)
    a_1
    b_0 = b_0 - double(1)
    b_0
    a_1 = a_1 + double(1)
    a_1
    b_0 = b_0 - double(1)
    b_0
    b_0 = b_0 + double(1)
    a_1 = b_0
    b_0 = b_0 + double(1)
    a_1 = b_0
    a_1 = a_1 - double(1)
    b_0 = a_1
    a_1 = a_1 - double(1)
    b_0 = a_1
    c_0 = c_0 + double(1)
    c_0
    c_0 = c_0 + double(1)
    c_0
    c_0 = c_0 - double(1)
    c_0
    c_0 = c_0 - double(1)
    c_0
    return a_1
}
[export] def main() : int {
    return 0
}
