options gen2

def fallthrough_2(var x : int) : int {
    if (x == 0) {
        x += 1
    } else {
        x += 1
    }
    return x
}
def fallthrough_3(var x : int) : int {
    if (x == 0) {
        x += 1
    } elif (x == 1) {
        x += 1
    } else {
        x += 1
    }
    return x
}
def fallthrough_without_default(var x : int) : int {
    if (x == 0) {
        x += 1
    } elif (x == 1) {
        x += 1
    } elif (x == 2) {
        x += 1
    }
    return x
}
def fallthrough_with_early_return(var x : int) : int {
    if (x == 0) {
        x += 1
    } elif (x == 1) {
        x += 2
    } elif (x == 2) {
        x += 3
    } elif (x == 3) {
        x += 4
    } elif (x == 4) {
        x += 5
    } else {
        x += 6
    }
    x += 7
    return x
}
