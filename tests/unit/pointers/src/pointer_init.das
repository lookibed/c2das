options gen2

typedef ulp = uint64?
def foo() : ulp {
    return null
}
def simple(var x : int const??; var y : int??) : int {
    return *x == *y
}
def entry(buffer_size : uint const; var buffer : int?) {
    unsafe {
        var test : int8? = [unsafe(addr("string"[0]))]
        buffer[0] = test[0]
        buffer[1] = test[1]
        buffer[2] = test[2]
        buffer[3] = test[3]
        buffer[4] = test[4]
        foo()
    }
}
