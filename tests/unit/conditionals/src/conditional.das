options gen2

def entry(sz : uint const; var buf : int?) {
    unsafe {
        var x : int? = unsafe(addr(buf[0]))
        var y : int? = unsafe(addr(buf[1]))
        *if (0) unsafe(addr(y)) else unsafe(addr(x)) = reinterpret<int?>(10)
        buf[2] = if (1) 2 else 3
        buf[3] = if (0) 2 else 3
    }
}
