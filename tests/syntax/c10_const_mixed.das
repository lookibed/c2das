options gen2

def apply(var result : int?; var input : int const?) : int {
    *result = *input * 2
    return 0
}
[export]
def main() : int {
    var x : int = 21
    var r : int = 0
    apply(unsafe(addr(r)), unsafe(addr(x)))
    return r
}
