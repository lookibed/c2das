options gen2

struct Pair {
    a : int
    b : int
}
def max_pair(var p : Pair?) : int {
    if (p.a > p.b) {
        return p.a
    } else {
        return p.b
    }
}
[export]
def main() : int {
    var p : Pair
    p.a = 10
    p.b = 25
    return max_pair(unsafe(addr(p)))
}
