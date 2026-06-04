options gen2

typedef my_int = int
typedef int_ptr = my_int?
typedef const_int_ptr = my_int?
typedef indirectly_const_ptr = my_int?
typedef my_fn = function
typedef shadowed = int64
def identity(var x : int) : int {
    return x
}
def entry() : int {
    var x : my_int = 1
    var y : my_int const = 1
    var z : int_ptr = unsafe(addr(x))
    var w : const_int_ptr const = unsafe(addr(x))
    var v : const_int_ptr const = unsafe(addr(x))
    var u : indirectly_const_ptr const = unsafe(addr(x))
    var t : my_fn? = unsafe(addr(identity))
    typedef shadowed = int    var n : shadowed = 1
    typedef shadowed = int64    var n : shadowed = 2
    return 0
}
