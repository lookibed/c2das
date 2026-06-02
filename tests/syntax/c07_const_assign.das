options gen2

[export]
def main() : int {
    var x : int = 10
    var p : int const? = unsafe(addr(x))
    var y : int = *p
    return y
}
