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
def goto_error_a(var x : int) : int {
    if (x >= 10) {
        if (x == 20) {
            x = x + 1
            goto _error
        } else {
            x = x + 2
        }
    } elif (x == 0) {
        x = x - 1
        goto _error
    } else {
        x = x - 2
    }
    return int(x) + 3
}
[export]
def goto_error_b(var x_0 : int) : int {
    if (int(x_0) >= 10) {
        x_0 = x_0 + 2
        if (int(x_0) == 20) {
            x_0 = x_0 + 1
            goto _error
        }
    } else {
        x_0 = x_0 - 2
        if (uint64(int(x_0)) == uint64(0)) {
            x_0 = x_0 - 1
            goto _error
        }
    }
    return int(x_0) + 3
}
[export]
def goto_error_but_its_all_gotos(var x_1 : int) : int {
    if (int(x_1) >= 10) {
        goto _B
    } else {
        goto _C
    }
}
[export]
def goto_errors(var x_2 : int) : int {
    if (int(x_2) >= 10) {
        x_2 = x_2 + 1
        if (int(x_2) == 20) {
            x_2 = x_2 + 2
            goto _error_a
        }
    } else {
        x_2 = x_2 - 1
        if (uint64(int(x_2)) == uint64(0)) {
            x_2 = x_2 - 2
            goto _error_b
        }
    }
    return int(x_2) + 4
}
[export]
def goto_success(var x_3 : int) : int {
    if (int(x_3) >= 10) {
        x_3 = x_3 + 1
        if (int(x_3) != 20) {
            goto _success
        } else {
            x_3 = x_3 + 2
        }
    } else {
        x_3 = x_3 - 1
        if (uint64(int(x_3)) != uint64(0)) {
            goto _success
        } else {
            x_3 = x_3 - 2
        }
    }
    return int(x_3) - 4
}
[export]
def goto_error_over_loop(var x_4 : int) : int {
    if (int(x_4) > 10) {
        x_4 = x_4 + 1
        x_4
        if (int(x_4) == 15) {
            goto _bad
        } else {
            x_4 = x_4 + 1
            x_4
            if (false) {
            }
        }
    } else {
        if (false) {
        }
    }
}
[export]
def multi_goto_error_over_loop(var x_5 : int) : int {
    if (int(x_5) > 10) {
        x_5 = x_5 + 1
        x_5
        if (int(x_5) == 15) {
            goto _bad
        } else {
            x_5 = x_5 + 1
            x_5
        }
    }
    if (int(x_5) > 10) {
        x_5 = x_5 + 1
        x_5
        if (int(x_5) == 15) {
            goto _also_bad
        } else {
            x_5 = x_5 + 1
            x_5
            if (false) {
            }
        }
    } else {
        if (false) {
        }
    }
}
[export]
def goto_out_of_labeled_block(var x_6 : int) : int {
    var c : int = int(0)
    c = 0
    if (c < 4) {
        c
        x_6 = x_6 + 1
        x_6
        if (int(x_6) == 5) {
            goto _error
        } else {
            x_6 = x_6 + 1
            x_6
            if (int(x_6) == 5) {
                goto _error
            } else {
                x_6 = x_6 + 1
                x_6
                if (false) {
                }
            }
        }
    } else {
        return x_6
    }
}
[export] def main() : int {
    return 0
}
