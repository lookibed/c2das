options gen2

def max(var a : int; var b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def sum_to_n(var n : int) : int {
    var i : int = 0
    var s : int = 0
    while (i <= n) {
        s = s + i
        i = i + 1
    }
    return s
}
