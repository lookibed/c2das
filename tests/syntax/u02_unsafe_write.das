options gen2

def set_val(var p : int?; v : int) {
    *p = v
}
[export]
def main() : int {
    var x : int = 10
    set_val(unsafe(addr(x)), 99)
    return x
}
