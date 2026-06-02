options gen2

struct Point {
    x : int
    y : int
}
[export]
def main() : int {
    var p : Point
    p.x = 5
    p.y = 7
    return p.x + p.y
}
