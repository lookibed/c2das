options gen2

[export]
def main_0() : int {
    var i : int = 0
    var s : int = 0
    label 27652:
    s = s + i
    s
    i = i + 1
    i
    if (i <= 5) {
        goto label 27652
    }
    return s
}
