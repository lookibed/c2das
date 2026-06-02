options gen2

[export]
def main() : int {
    var a : int = 1
    var b : int = 0
    var r : int = 0
    if (a != 0 && b == 0) {
        r = 1
    }
    if (r != 0) {
        return 1
    }
    return 0
}
