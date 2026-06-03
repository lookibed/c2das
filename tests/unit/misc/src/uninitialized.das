options gen2

typedef myint = int
typedef myintp = myint?
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
def entry2(sz : uint const; buf : int? const) {
    var x : myint
    var p : myintp
    p = unsafe(addr(x))
    *p = 1
    if (sz > 0) {
        *buf = x
    }
    var q1 : int const? const
    var q2 : int const?
    var q3 : int? const
    var q4 : int?
    var f : function?
    var fs : array<function?> = [0, 0]
    var xs : array<int> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var ys : array<array<int>> = [0, 0, 0, 0]
    var zs : array<int?> = [0, 0, 0, 0]
    var my_s : s
    var my_u : u
}
