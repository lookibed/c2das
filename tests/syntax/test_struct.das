options gen2

struct Point {
    x : int
    y : int
}
enum Color : uint {
    RED = 0
    GREEN = 1
    BLUE = 5
}
def use_types() : int {
    var p : Point
    p.x = 1
    p.y = 2
    var c : Color = RED
    return p.x + p.y + c
}
