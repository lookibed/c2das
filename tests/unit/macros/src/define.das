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
typedef uint64_t = uint64
typedef U64 = uint64
struct fn_ptrs {
    v : uint64
    fn1 : function?
    fn2 : function?
}
[export]
def test_fn_macro(var x : int) : int {
    return x * x
}
[export]
def reference_define() : int {
    var x_0 : int = int(0)
    x_0 = 1
    x_0 = x_0 + 2
    if (3 < (2 + 1) * 3) {
        x_0 = x_0 + (2 + 1) * 3
    }
    return x_0
}
var fns : fn_ptrs const = fn_ptrs(v = uint64(0), fn1 = null, fn2 = null)

var p : fn_ptrs? = unsafe(unsafe(reinterpret<fn_ptrs?>(unsafe(addr(fns)))))

[export]
def test_zstd() : uint64 {
    4
    var c2da_fresh0 : int = int(0)
    if (4 == int(uint64(4))) {
        c2da_fresh0 = 30
    } else {
        c2da_fresh0 = 31
    }
    return uint64(c2da_fresh0)
}
[export]
def stmt_expr_inc() : int {
    var a : int = int(0)
    var b : int? = null
    a = 0
    b = unsafe(addr(a))
    {
        *b = *b + 1
        *b
        *b
    }
    return {
    *b = *b + 1
    *b
    *b
}
}
[export]
def test_switch(var x_1 : int) : int {
    x_1
    return 10
}
[export]
def returns_longdouble() : double {
    return double(0.0)
}
[export]
def returns_int() : int {
    return 1
}
[export]
def long_doubles() {
    var ld : double = double(0)
    var ld2 : double = double(0)
    ld = double(0.5)
    ld2 = returns_longdouble() + double(returns_int())
    return
}
[export] def main() : int {
    return 0
}
