options gen2

[export]
def main() : int {
    var i : int = 10
    var _dw_50 : bool = true
    while (_dw_50 || i < 5) {
        _dw_50 = false
        i = i + 1
    }
    return i
}
