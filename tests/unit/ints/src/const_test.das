options gen2

def constant_arguments(x : int const) : int {
    var y : int const = x + 2
    return y
}
def constant_pointer(var x : int? const) {
    *x += 1
}
def pointer_to_constant(var x : int const?) : int {
    unsafe {
        return x[1] + 1
    }
}
def entry4(buffer_size : uint const; var buffer : int?) {
    unsafe {
        buffer[0] = constant_arguments(1)
        constant_pointer(unsafe(addr(buffer[1])))
        buffer[1] = pointer_to_constant(buffer)
    }
}
def addr_of_const() {
    var ci : int const = 0
    var i : int = 0
    var p1 : int const? = unsafe(addr(ci))
    var p2 : int const? = unsafe(addr(i))
    var p3 : int? = unsafe(addr(i))
}
