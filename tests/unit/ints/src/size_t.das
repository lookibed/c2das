options gen2

typedef size_t = uint64
def entry(var n : uint; var buf : int?) {
    unsafe {
        if (n < 10) {
            return
        }
        var z : size_t = 5
        buf[z] = 8
    }
}
