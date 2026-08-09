options gen2

struct Pair {
    a : int
    b : int
}
[export]
def max_pair(var p : Pair?) : int {
    if (p.a > p.b) {
        return p.a
    } else {
        return p.b
    }
}
[export]
def main_0() : int {
    var p_0 : Pair
    p_0.a = 10
    p_0.a
    p_0.b = 25
    p_0.b
    return max_pair(unsafe(addr(p_0)))
}
