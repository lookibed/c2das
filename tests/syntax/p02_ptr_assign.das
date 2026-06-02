options gen2

[export]
def main() : int {
    var x : int = 10
    var p : int? = unsafe(addr(x))
    *p = 20
    return x
}
