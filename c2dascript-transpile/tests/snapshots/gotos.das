options gen2

def c2da_min_int(a : int; b : int) : int {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int(a : int; b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint(a : uint; b : uint) : uint {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint(a : uint; b : uint) : uint {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_int64(a : int64; b : int64) : int64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int64(a : int64; b : int64) : int64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint64(a : uint64; b : uint64) : uint64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint64(a : uint64; b : uint64) : uint64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_clip_uint(v : int) : uint {
    if (v < 0) {
        return 0x0
    }
    if (v > 255) {
        return 0xff
    }
    return uint(v)
}
def c2da_bool_to_uint(v : bool) : uint {
    if (v) {
        return 0x1
    } else {
        return 0x0
    }
}
def c2da___assert_fail(expr : void?; file : void?; line : uint; func : void?) {
}
[export]
def sum(var count : int) : int {
    goto _a
}
[export]
def goto_error_simple(var x_0 : int) : int {
    if (uint64(x_0) != uint64(0)) {
        x_0 = x_0 + 1
        if (uint64(x_0) != uint64(0)) {
            x_0 = x_0 + 2
            goto _error
        }
    } else {
        x_0 = x_0 + 3
        if (uint64(x_0) != uint64(0)) {
            x_0 = x_0 + 4
            goto _error
        }
    }
    return int(x_0) + 5
}
[export]
def goto_error_minimal(var x_1 : int) : int {
    if (uint64(x_1) != uint64(0)) {
        if (uint64(x_1) != uint64(0)) {
            goto _error
        }
    } elif (uint64(x_1) != uint64(0)) {
        goto _error
    }
    return int(x_1) + 1
}
[export]
def multi_goto_error(var x_2 : int) : int {
    if (uint64(x_2) != uint64(0)) {
        x_2 = x_2 + 1
        if (uint64(x_2) != uint64(0)) {
            if (uint64(x_2) != uint64(0)) {
                goto _bad
            }
        }
        x_2 = x_2 + 2
        if (uint64(x_2) != uint64(0)) {
            goto _also_bad
        }
    }
    if (uint64(x_2) != uint64(0)) {
        x_2 = x_2 + 3
        if (uint64(x_2) != uint64(0)) {
            if (uint64(x_2) != uint64(0)) {
                goto _bad
            }
        }
        x_2 = x_2 + 4
        if (uint64(x_2) != uint64(0)) {
            goto _also_bad
        }
    }
    return x_2
}
[export]
def multi_goto_error_common(var x_3 : int) : int {
    if (uint64(x_3) != uint64(0)) {
        x_3 = x_3 + 1
        if (uint64(x_3) != uint64(0)) {
            if (uint64(x_3) != uint64(0)) {
                goto _bad
            }
        }
        x_3 = x_3 + 2
        if (uint64(x_3) != uint64(0)) {
            goto _also_bad
        }
    }
    if (uint64(x_3) != uint64(0)) {
        x_3 = x_3 + 3
        if (uint64(x_3) != uint64(0)) {
            if (uint64(x_3) != uint64(0)) {
                goto _bad
            }
        }
        x_3 = x_3 + 4
        if (uint64(x_3) != uint64(0)) {
            goto _also_bad
        }
    }
    return x_3
}
[export] def main() : int {
    return 0
}
