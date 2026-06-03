options gen2

def goto_error_a(x : int) : int {
    if (x >= 10) {
        if (x == 20) {
            x += 1
            goto label 84904
        }
        x += 2
    } else {
        if (x == 0) {
            x -= 1
            goto label 84904
        }
        x -= 2
    }
    return x + 3
    label 84904:
    return x - 3
}
def goto_error_b(x : int) : int {
    if (x >= 10) {
        x += 2
        if (x == 20) {
            x += 1
            goto label 84904
        }
    } else {
        x -= 2
        if (x == 0) {
            x -= 1
            goto label 84904
        }
    }
    return x + 3
    label 84904:
    return x - 3
}
def goto_error_but_its_all_gotos(x : int) : int {
    if (x >= 10) {
        goto label 66
    } else {
        goto label 67
    }
    label 66:
    x += 2
    if (x == 20) {
        x += 1
        goto label 84904
    } else {
        goto label 68
    }
    label 67:
    x -= 2
    if (x == 0) {
        x -= 1
        goto label 84904
    } else {
        goto label 68
    }
    label 68:
    return x + 3
    label 84904:
    return x - 3
}
def goto_errors(x : int) : int {
    if (x >= 10) {
        x += 1
        if (x == 20) {
            x += 2
            goto label 95786
        }
    } else {
        x -= 1
        if (x == 0) {
            x -= 2
            goto label 95787
        }
    }
    return x + 4
    label 95786:
    x += 3
    goto label 82338
    label 95787:
    x -= 3
    label 82338:
    return x - 4
}
def goto_success(x : int) : int {
    if (x >= 10) {
        x += 1
        if (x != 20) {
            goto label 12611
        }
        x += 2
    } else {
        x -= 1
        if (x != 0) {
            goto label 12611
        }
        x -= 2
    }
    return x - 4
    label 12611:
    return x + 4
}
