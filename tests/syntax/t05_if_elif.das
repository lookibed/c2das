options gen2

def classify(x : int) : int {
    if (x > 0) {
        return 1
    } else {
        if (x < 0) {
            return -1
        } else {
            return 0
        }
    }
}
[export]
def main() : int {
    return classify(5) + classify(0) + classify(-3)
}
