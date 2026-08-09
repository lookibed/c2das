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
def long_double_test() {
    var one : double = double(0)
    var zero : double = double(0)
    var add : double = double(0)
    var huge : double = double(0)
    var i : int = int(0)
    var f : float = float(0)
    var cast_from_int : double = double(0)
    var cast_from_float : double = double(0)
    var is_inf : bool = bool(0)
    var dummy : int = int(0)
    one = double(1.0)
    add = double(one) + double(zero)
    huge = 0.0
    i = int(one)
    f = float(one)
    cast_from_int = double(i)
    cast_from_float = double(f)
    is_inf = 0
    one
    return
}
[export]
def float128_test() {
    var one_0 : double = double(0)
    var zero_0 : double = double(0)
    var add_0 : double = double(0)
    var huge_0 : double = double(0)
    var i_0 : int = int(0)
    var f_0 : float = float(0)
    var cast_from_int_0 : double = double(0)
    var cast_from_float_0 : double = double(0)
    var ld_from_float128 : double = double(0)
    var is_inf_0 : bool = bool(0)
    var dummy_0 : int = int(0)
    one_0 = double(1.0)
    add_0 = double(one_0) + double(zero_0)
    huge_0 = double(0.0)
    i_0 = int(one_0)
    f_0 = float(one_0)
    cast_from_int_0 = double(i_0)
    cast_from_float_0 = double(f_0)
    ld_from_float128 = double(one_0)
    is_inf_0 = 0
    one_0
    return
}
[export] def main() : int {
    return 0
}
