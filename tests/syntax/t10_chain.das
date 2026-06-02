options gen2

def max(a : int; b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def min(a : int; b : int) : int {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def clamp(v : int; lo : int; hi : int) : int {
    var r : int = v
    if (r < lo) {
        r = lo
    } else {
        if (r > hi) {
            r = hi
        }
    }
    return r
}
[export]
def main() : int {
    var m : int = max(10, 20)
    var n : int = min(10, 20)
    var c : int = clamp(15, 0, 10)
    return m + n + c
}
