options gen2

struct Rect {
    w : int
    h : int
}
def area(var r : Rect?) : int {
    return r.w * r.h
}
[export]
def main() : int {
    var r : Rect
    r.w = 5
    r.h = 7
    return area(unsafe(addr(r)))
}
