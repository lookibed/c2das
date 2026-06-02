options gen2

def sum_to(n : int) : int {
    var i : int = 0
    var s : int = 0
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
