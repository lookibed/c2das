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
def while_loop(var x : int) : int {
    while (true) {
        if (!(uint64(x) != uint64(0))) {
            if (false) {
            }
        }
        x = x + 1
    }
    return x
}
[export]
def for_loop(var x_0 : int) : int {
}
[export]
def infinite_loop(var x_1 : int) {
}
[export]
def goto_loop(var x_2 : int) : int {
    if (false) {
    }
}
[export]
def do_while_loop(var x_3 : int) : int {
    while (true) {
        x_3 = x_3 + 1
        if (!(uint64(x_3) != uint64(0))) {
            if (false) {
            }
        }
    }
    return x_3
}
[export]
def break_while(var x_4 : int) : int {
    while (true) {
        if (!(uint64(x_4) != uint64(0))) {
            if (false) {
            }
        }
        if (uint64(x_4) != uint64(0)) {
            x_4 = x_4 + 1
            if (uint64(x_4) != uint64(0)) {
                if (false) {
                }
                if (false) {
                }
            }
        }
        x_4 = x_4 + 2
    }
    return x_4
}
[export]
def continue_while(var x_5 : int) : int {
    while (true) {
        if (!(uint64(x_5) != uint64(0))) {
            if (false) {
            }
        }
        if (uint64(x_5) != uint64(0)) {
            x_5 = x_5 + 1
            if (uint64(x_5) != uint64(0)) {
                continue
                continue
            }
        }
        x_5 = x_5 + 2
    }
    return x_5
}
[export]
def trivial_nested_while(var x_6 : int) {
    while (true) {
        if (!(uint64(x_6) != uint64(0))) {
            if (false) {
            }
        }
        while (true) {
            if (!(uint64(x_6) != uint64(0))) {
                if (false) {
                }
            }
            while (true) {
                if (!(uint64(x_6) != uint64(0))) {
                    if (false) {
                    }
                }
                x_6 = x_6 + 1
            }
        }
    }
    return
}
[export]
def nested_while(var x_7 : int) {
    while (true) {
        if (!(uint64(x_7) != uint64(0))) {
            if (false) {
            }
        }
        while (true) {
            if (!(uint64(x_7) != uint64(0))) {
                if (false) {
                }
            }
            while (true) {
                if (!(uint64(x_7) != uint64(0))) {
                    if (false) {
                    }
                }
                x_7 = x_7 + 1
            }
            x_7 = x_7 + 2
        }
        x_7 = x_7 + 3
    }
    return
}
[export]
def nested_for(var x_8 : int) {
}
[export]
def exit_nested_loops(var x_9 : int) : int {
    while (true) {
        if (uint64(x_9) != uint64(0)) {
            while (true) {
                if (uint64(x_9) != uint64(0)) {
                    if (uint64(x_9) != uint64(0)) {
                        goto _break_outer
                    } else {
                        x_9 = x_9 + 1
                        x_9
                    }
                } else {
                    if (false) {
                    }
                }
            }
        } else {
            if (false) {
            }
        }
    }
}
[export]
def continue_nested_loops(var x_10 : int) : int {
    if (false) {
    }
}
[export]
def break_and_continue_nested_loops(var x_11 : int) : int {
    if (false) {
    }
}
[export]
def for_loop_single_continue(var x_12 : int) : int {
}
[export]
def for_loop_multi_continue(var x_13 : int) : int {
}
[export]
def do_loop_single_continue(var x_14 : int) : int {
    while (true) {
        while (true) {
            if (uint64(x_14) != uint64(0)) {
                if (uint64(x_14) != uint64(0)) {
                    continue
                    if (false) {
                    }
                }
            }
            x_14 = x_14 + 1
        }
        if (!(uint64(x_14) != uint64(0))) {
            if (false) {
            }
        }
    }
    return x_14
}
[export]
def do_loop_multi_continue(var x_15 : int) : int {
    while (true) {
        while (true) {
            if (uint64(x_15) != uint64(0)) {
                if (uint64(x_15) != uint64(0)) {
                    continue
                    if (false) {
                    }
                }
            }
            x_15 = x_15 + 1
            if (uint64(x_15) != uint64(0)) {
                if (uint64(x_15) != uint64(0)) {
                    continue
                    if (false) {
                    }
                }
            }
            x_15 = x_15 + 2
        }
        if (!(uint64(x_15) != uint64(0))) {
            if (false) {
            }
        }
    }
    return x_15
}
[export]
def explicit_loop_multi_exit(var x_16 : int) : int {
}
[export]
def implicit_loop_multi_exit(var x_17 : int) : int {
    if (false) {
    }
}
[export]
def loop_returns(var x_18 : int) : int {
    while (true) {
        if (uint64(x_18) != uint64(0)) {
            x_18 = x_18 + 1
            if (uint64(x_18) != uint64(0)) {
                x_18 = x_18 + 2
                return x_18
            } else {
                x_18 = x_18 + 3
                if (uint64(x_18) != uint64(0)) {
                    x_18 = x_18 + 4
                    return x_18
                }
            }
        } else {
            return x_18
        }
    }
}
[export]
def loop_gotos(var x_19 : int) : int {
    while (true) {
        if (uint64(x_19) != uint64(0)) {
            x_19 = x_19 + 1
            if (uint64(x_19) != uint64(0)) {
                x_19 = x_19 + 2
                goto _exit
            } else {
                x_19 = x_19 + 3
                if (uint64(x_19) != uint64(0)) {
                    x_19 = x_19 + 4
                    goto _exit
                } else {
                    x_19 = x_19 + 5
                }
            }
        } else {
            return x_19
        }
    }
}
[export]
def loop_early_return(var x_20 : int) : int {
    while (true) {
        if (uint64(x_20) != uint64(0)) {
            x_20 = x_20 + 1
            if (uint64(x_20) != uint64(0)) {
                x_20 = x_20 + 2
                return x_20
            }
        } else {
            return -x_20
        }
    }
}
[export]
def if_else_loops(var x_21 : int) {
    if (uint64(x_21) != uint64(0)) {
        while (true) {
            if (!(uint64(x_21) != uint64(0))) {
                if (false) {
                }
            }
            x_21 = x_21 + 1
        }
    } else {
        while (true) {
            if (!(uint64(x_21) != uint64(0))) {
                if (false) {
                }
            }
            x_21 = x_21 + 2
        }
    }
    return
}
[export]
def goto_loops(var x_22 : int) : int {
    if (false) {
    }
}
[export]
def goto_into_loops(var x_23 : int) {
    if (false) {
    }
}
[export]
def goto_separate_loops(var x_24 : int) {
    if (false) {
    }
}
[export] def main() : int {
    return 0
}
