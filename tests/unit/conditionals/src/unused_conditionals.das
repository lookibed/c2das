options gen2

def unused_conditional1() : int {
    var i : int = 2
    0 < inc(unsafe(addr(i)))
    return i
}
def unused_conditional2() : int {
    var i : int = 2
    0 || inc(unsafe(addr(i)))
    return i
}
def unused_conditional3() : int {
    var i : int = 2
    0 && inc(unsafe(addr(i)))
    return i
}
