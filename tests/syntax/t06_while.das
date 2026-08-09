options gen2

[export]
def sum_to(var n : int) : int {
    var i : int = 0
    var s : int = 0
    while (i <= n) {
        s = s + i
        s
        i = i + 1
        i
    }
    return s
}
[export]
def main_0() : int {
    return sum_to(10)
}
