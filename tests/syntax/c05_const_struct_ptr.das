options gen2

struct Point {
    x : int
    y : int
}
def dot(var p : Point const?) : int {
    return p.x * p.x + p.y * p.y
}
[export]
def main() : int {
    var pt : Point
    pt.x = 3
    pt.y = 4
    return dot(unsafe(addr(pt)))
}
