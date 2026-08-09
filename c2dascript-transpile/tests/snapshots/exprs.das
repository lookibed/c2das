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
enum E : uint {
    EA = 0
}
typedef int_t = int
[export]
def side_effect() : int {
    puts(unsafe(addr("the return of side effect"[0])))
    return 10
}
[export]
def unary_without_side_effect() {
    var i : int = int(0)
    i = 5
    -i
    i
    ~i
    uint64(i) == uint64(0)
    unsafe(addr(i))
    *unsafe(addr(i))
    i = i + 1
    i
    i = i - 1
    i
    i = i - 1
    i
    i = i + 1
    i
    return
}
[export]
def unary_with_side_effect() {
    var arr : array<int8?> = []
    arr = [null]
    -side_effect()
    side_effect()
    ~side_effect()
    uint64(side_effect()) == uint64(0)
    unsafe(addr(unsafe(unsafe(addr(""[0]))[uint(side_effect())])))
    *unsafe(unsafe(addr(arr[0]))[uint(side_effect())])
    unsafe(unsafe(addr(arr[0]))[uint(side_effect())]) = unsafe(unsafe(unsafe(addr(arr[0]))[uint(side_effect())]) + uint64(1))
    unsafe(unsafe(addr(arr[0]))[uint(side_effect())])
    unsafe(unsafe(addr(arr[0]))[uint(side_effect())]) = unsafe(unsafe(unsafe(addr(arr[0]))[uint(side_effect())]) - uint64(1))
    unsafe(unsafe(addr(arr[0]))[uint(side_effect())])
    unsafe(unsafe(addr(arr[0]))[uint(side_effect())]) = unsafe(unsafe(unsafe(addr(arr[0]))[uint(side_effect())]) + uint64(1))
    unsafe(unsafe(addr(arr[0]))[uint(side_effect())])
    unsafe(unsafe(addr(arr[0]))[uint(side_effect())]) = unsafe(unsafe(unsafe(addr(arr[0]))[uint(side_effect())]) - uint64(1))
    unsafe(unsafe(addr(arr[0]))[uint(side_effect())])
    return
}
[export]
def unsigned_compound_desugaring() {
    var i_0 : int = int(0)
    var u : uint = uint(0)
    var e : E = unsafe(reinterpret<E>(0))
    i_0 = 0
    u = uint(0)
    e = unsafe(reinterpret<E>(EA))
    e = uint(e + u)
    i_0 = uint(i_0 + u)
    return
}
[export]
def cast_literals() {
    var i_1 : int = int(0)
    var it : int = int(0)
    var i_neg : int = int(0)
    var it_neg : int = int(0)
    i_1 = int(1)
    it = int(1)
    i_neg = int(-1)
    it_neg = int(-1)
    return
}
[export]
def compound_literal() {
    var i_2 : int = int(0)
    i_2 = int([unsafe(reinterpret<Unnamed>(1))])
    return
}
[export]
def statement_expr() {
    {
        puts(unsafe(addr("should execute"[0])))
        return
    }
    puts(unsafe(addr("should be unreachable!"[0])))
    return
}
var EA : int = 0

var C : int = 2

var B : int = 1

var A : int = 0
[export] def main() : int {
    return 0
}
