options gen2

[export]
def main() : int {
    var x : int = 42
    var p : int const? = unsafe(addr(x))
    return *p
}
