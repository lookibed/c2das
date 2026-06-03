options gen2

def early_returns(var a : int) : int {
    if (a == 2) {
        return 2
    }
    if (a == 3) {
        a += 1
    }
    if (a == 4) {
        return 1
    }
    return 0
}
