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
def simple_if_else(var x : int) : int {
    if (uint64(x) != uint64(0)) {
        x = x + 1
    } else {
        x = x + 2
    }
    return x
}
[export]
def if_no_else(var x_0 : int) : int {
    if (int(x_0) > 0) {
        x_0 = x_0 + 1
    }
    return x_0
}
[export]
def multiple_ifs(var x_1 : int) : int {
    if (uint64(x_1) != uint64(0)) {
        x_1 = x_1 + 1
    }
    if (uint64(x_1) != uint64(0)) {
        x_1 = x_1 + 2
    }
    return x_1
}
[export]
def nested_if_else(var x_2 : int) : int {
    if (int(x_2) > 0) {
        if (int(x_2) < 10) {
            x_2 = x_2 + 1
        } else {
            x_2 = x_2 + 2
        }
    } else {
        x_2 = x_2 - 1
    }
    return x_2
}
[export]
def nested_if_no_else(var x_3 : int) : int {
    if (int(x_3) > 0) {
        if (int(x_3) < 10) {
            x_3 = x_3 + 1
        }
        x_3 = x_3 + 2
    } else {
        x_3 = x_3 - 1
    }
    return x_3
}
[export]
def early_returns(var a : int) : int {
    if (a == 2) {
        return 2
    } else {
        if (a == 3) {
            a = a + 1
        }
        if (a == 4) {
            return 1
        } else {
            return 0
        }
    }
}
[export]
def nested_early_returns(var x_4 : int) : int {
    if (uint64(x_4) != uint64(0)) {
        if (uint64(x_4) != uint64(0)) {
            x_4 = x_4 + 1
            return x_4
        } else {
            x_4 = x_4 + 2
        }
    } elif (uint64(x_4) != uint64(0)) {
        x_4 = x_4 + 3
        return x_4
    } else {
        x_4 = x_4 + 4
    }
    return x_4
}
[export] def main() : int {
    return 0
}
