options gen2

typedef uint64_t = __uint64_t
typedef U64 = uint64_t
struct fn_ptrs {
    v : void?
    fn1 : function?
    fn2 : function?
}
def test_fn_macro(var x : int) : int {
    return x * x
}
def reference_define() : int {
    var x : int = 1
    x += 2
    if (3 < 2 + 1 * 3) {
        x += 2 + 1 * 3
    }
    return x
}
var fns : fn_ptrs const = [cast<void?>(0), null, null]

var p : fn_ptrs? = unsafe(addr(fns))

def test_switch(var x : int) : int {
    if (x == 1) {
        return 10
    } elif (x == 2) {
        return 20
    }
    return 0
}
def returns_longdouble() : double {
    return 0
}
def returns_int() : int {
    return 1
}
def long_doubles() {
    var ld : double = 0.5
    var ld2 : double = returns_longdouble() + returns_int()
}
