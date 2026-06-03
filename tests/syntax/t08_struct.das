options gen2

struct Point {
    x : int
    y : int
}
def area(x1 : int; y1 : int; x2 : int; y2 : int) : int {
    var p1 : Point
    var p2 : Point
    p1.x = x1
    p1.y = y1
    p2.x = x2
    p2.y = y2
    var w : int = p2.x - p1.x
    var h : int = p2.y - p1.y
    return w * h
}
[export]
def main() : int {
    return area(0, 0, 10, 5)
}
