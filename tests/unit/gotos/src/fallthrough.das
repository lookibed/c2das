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
def fallthrough_2(var x : int) : int {
    x
    x = x + 1
    x = x + 1
    if (false) {
    }
}
[export]
def fallthrough_3(var x_0 : int) : int {
    x_0
    x_0 = x_0 + 1
    x_0 = x_0 + 1
    x_0 = x_0 + 1
    if (false) {
    }
}
[export]
def fallthrough_without_default(var x_1 : int) : int {
    x_1
    x_1 = x_1 + 1
    x_1 = x_1 + 1
    x_1 = x_1 + 1
    if (false) {
    }
}
[export]
def fallthrough_with_early_return(var x_2 : int) : int {
    x_2
    x_2 = x_2 + 1
    x_2 = x_2 + 2
    x_2 = x_2 + 3
    return x_2
}
[export] def main() : int {
    return 0
}
