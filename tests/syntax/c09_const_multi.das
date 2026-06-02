options gen2

def add(var a : int const?; var b : int const?) : int {
    return *a + *b
}
[export]
def main() : int {
    var x : int = 5
    var y : int = 7
    return add(unsafe(addr(x)), unsafe(addr(y)))
}
