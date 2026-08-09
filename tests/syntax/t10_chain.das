options gen2

[export]
def max(var a : int; var b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
[export]
def min(var a_0 : int; var b_0 : int) : int {
    if (a_0 < b_0) {
        return a_0
    } else {
        return b_0
    }
}
[export]
def clamp(var v : int; var lo : int; var hi : int) : int {
    var r : int = v
    if (r < lo) {
        r = lo
        r
    } else {
        if (r > hi) {
            r = hi
            r
        }
    }
    return r
}
[export]
def main_0() : int {
    var m : int = max(10, 20)
    var n : int = min(10, 20)
    var c : int = clamp(15, 0, 10)
    return m + n + c
}
