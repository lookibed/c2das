options gen2

struct Point {
    x : int
    y : int
}
[export]
def area(var x1 : int; var y1 : int; var x2 : int; var y2 : int) : int {
    var p1 : Point
    var p2 : Point
    p1.x = x1
    p1.x
    p1.y = y1
    p1.y
    p2.x = x2
    p2.x
    p2.y = y2
    p2.y
    var w : int = p2.x - p1.x
    var h : int = p2.y - p1.y
    return w * h
}
[export]
def main_0() : int {
    return area(0, 0, 10, 5)
}
