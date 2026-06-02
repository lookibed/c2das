options gen2

def swap(var a : int?; var b : int?) {
    var t : int = *a
    *a = *b
    *b = t
}
[export]
def main() : int {
    var x : int = 10
    var y : int = 20
    swap(unsafe(addr(x)), unsafe(addr(y)))
    return x * 100 + y
}
