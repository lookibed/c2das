options gen2

def sum_to(var n : int) : int {
    var s : int = 0
    var i : int = 0
    i = 0
    while (i <= n) {
        s = s + i
        i = i + 1
    }
    return s
}
[export]
def main() : int {
    return sum_to(10)
}
