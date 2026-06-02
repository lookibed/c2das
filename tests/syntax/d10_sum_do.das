options gen2

[export]
def main() : int {
    var i : int = 1
    var s : int = 0
    var _dw_51 : bool = true
    while (_dw_51 || i <= 10) {
        _dw_51 = false
        s = s + i
        i = i + 1
    }
    return s
}
