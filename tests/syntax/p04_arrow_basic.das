options gen2

struct Point {
    x : int
    y : int
}
[export]
def main() : int {
    var pt : Point
    var p : Point? = unsafe(addr(pt))
    p.x = 10
    p.y = 20
    return p.x + p.y
}
