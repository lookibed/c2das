options gen2

[export]
def main() : int {
    var x : int = 1
    var r : int = 0
    if (x == 1 || x == 2) {
        r = 20
    } elif (x == 3) {
        r = 30
    }
    return r
}
