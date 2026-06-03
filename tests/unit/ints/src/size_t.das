options gen2

def entry(n : uint; var buf : int?) {
    unsafe {
        if (n < 10) {
            return
        }
        var z : size_t = 5
        buf[z] = 8
    }
}
