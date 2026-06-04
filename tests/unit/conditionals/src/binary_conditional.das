options gen2

def id(var i : int) : int {
    return i
}
def add(var p : int?; var i : int; var r : int) : int {
    *p += i
    return r
}
def entry3(sz : uint const; var buf : int?) {
    unsafe {
        buf[0] = if (id(0)) id(0) else id(1)
        buf[1] = if (id(2)) id(2) else id(3)
        if (add(buf + 2, 2, 0)) add(buf + 2, 2, 0) else add(buf + 3, 3, 0)
        if (add(buf + 4, 4, 1)) add(buf + 4, 4, 1) else add(buf + 5, 5, 0)
    }
}
