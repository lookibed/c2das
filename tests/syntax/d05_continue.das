options gen2

[export]
def main() : int {
    var i : int = 0
    var s : int = 0
    var _dw_51 : bool = true
    while (_dw_51 || i < 5) {
        _dw_51 = false
        i = i + 1
        if (i % 2 == 0) {
            continue
        }
        s = s + i
    }
    return s
}
