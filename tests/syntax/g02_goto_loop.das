options gen2

[export]
def main() : int {
    var i : int = 0
    var s : int = 0
    label 27652:
    s = s + i
    i = i + 1
    if (i <= 5) {
        goto label 27652
    }
    return s
}
