options gen2

[export]
def main() : int {
    var i : int = 0
    var s : int = 0
    while (i < 5) {
        i = i + 1
        var _dw_60 : bool = true
        while (_dw_60 || false) {
            _dw_60 = false
            if (i == 3) {
                continue
            }
            s = s + 1
        }
    }
    return s
}
