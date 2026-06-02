options gen2

def read_val(var p : int const?) : int {
    return *p
}
[export]
def main() : int {
    var x : int = 99
    return read_val(unsafe(addr(x)))
}
