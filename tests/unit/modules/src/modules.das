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
enum E_enum {
    E_variant1 = 1
    E_variant2 = 2
}
typedef char_to_int = function
[export]
def other_c_to_i(var c : int8) : int {
    var null_var : int? = null
    null_var = null
    return int(c)
}
var global_fn : function? = unsafe(unsafe(reinterpret<function?>(other_c_to_i)))

[export]
def use_enum() : E_enum {
    var x : int = int(0)
    x = E_variant1
    return unsafe(reinterpret<E_enum>(2))
}
[export]
def c_to_i(var c_0 : int8) : int {
    return int(c_0)
}
[export]
def modules() {
    var x_0 : int8 = int8(0)
    var ptr : char_to_int? = null
    var ptr2 : char_to_int? = null
    var ptr3 : char_to_int? = null
    x_0 = int8(10)
    ptr = null
    ptr2 = c_to_i
    ptr3 = other_c_to_i
    ptr2(x_0)
    return
}
var E_variant2 : int = 2

var E_variant1 : int = 1
[export] def main() : int {
    return 0
}
