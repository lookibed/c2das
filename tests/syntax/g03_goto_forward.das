options gen2

[export]
def main_0() : int {
    var a : int = 1
    var b : int = 2
    if (a < b) {
        goto label 571
    }
    a = 99
    a
    label 571:
    return a
}
