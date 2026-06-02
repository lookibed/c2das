options gen2

[export]
def main() : int {
    var i : int = 0
    var s : int = 0
    while (i < 5) {
        var j : int = 0
        var _dw_60 : bool = true
        while (_dw_60 || j < 3) {
            _dw_60 = false
            s = s + 1
            j = j + 1
        }
        i = i + 1
    }
    return s
}
