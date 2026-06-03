options gen2

def idiomatic_switch(var x : int) : int {
    if (1 + x == 0 || 1 + x == 2) {
        x += 2
    } elif (1 + x == 1) {
        x += 1
    } else {
        x += 3
    }
    return x
}
