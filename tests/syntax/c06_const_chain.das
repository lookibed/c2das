options gen2

def min_ptr(var a : int const?; var b : int const?) : int const? {
    if (*a < *b) {
        return a
    } else {
        return b
    }
}
[export]
def main() : int {
    var x : int = 10
    var y : int = 20
    var p : int const? = min_ptr(unsafe(addr(x)), unsafe(addr(y)))
    return *p
}
