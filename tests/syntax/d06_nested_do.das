options gen2

[export]
def main() : int {
    var i : int = 0
    var s : int = 0
    var _dw_51 : bool = true
    while (_dw_51 || i < 3) {
        _dw_51 = false
        var j : int = 0
        var _dw_65 : bool = true
        while (_dw_65 || j < 2) {
            _dw_65 = false
            s = s + 1
            j = j + 1
        }
        i = i + 1
    }
    return s
}
