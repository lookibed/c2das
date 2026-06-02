options gen2

[export]
def main() : int {
    var n : int = 5
    var f : int = 1
    var _dw_51 : bool = true
    while (_dw_51 || n > 1) {
        _dw_51 = false
        f = f * n
        n = n - 1
    }
    return f
}
