options gen2

[export]
def main() : int {
    var i : int = 0
    var _dw_50 : bool = true
    while (_dw_50 || i < 10) {
        _dw_50 = false
        i = i + 1
        if (i > 3) {
            break
        }
    }
    return i
}
