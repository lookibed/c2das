options gen2

[export]
def main() : int {
    var x : int = 7
    var p : int? = unsafe(addr(x))
    var pp : int?? = unsafe(addr(p))
    return **pp
}
