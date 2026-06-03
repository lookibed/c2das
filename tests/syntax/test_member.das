options gen2

struct Point {
    x : int
    y : int
}
[export]
def main() : int {
    var p : Point
    p.x = 10
    p.y = 20
    return p.x + p.y
}
