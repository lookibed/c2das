options gen2

struct Point {
    x : int
    y : int
}
[export]
def main_0() : int {
    var p : Point
    p.x = 5
    p.x
    p.y = 7
    p.y
    return p.x + p.y
}
