options gen2

typedef my_fn = function
def identity(x : int) : int {
    return x
}
def implicit_int() {
    var t : my_fn? = unsafe(addr(identity))
    var u : my_fn? = identity
}
