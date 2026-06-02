options gen2

[export]
def main() : int {
    var x : int = 5
    var r : int = 0
    if (x == 1) {
        r = 10
    } elif (x == 2) {
        r = 20
    } else {
        r = 99
    }
    return r
}
