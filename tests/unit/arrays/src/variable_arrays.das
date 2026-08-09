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
def use_arrays(n : int const; m : int const; var a : array<array<int>>?) {
    var counter : int = int(0)
    counter = 1
    if (false) {
    }
}
[export]
def use_arrays2(n_0 : int const; m_0 : int const; var a_0 : array<array<int>>?) {
    var counter_0 : int = int(0)
    counter_0 = 1
    if (false) {
    }
}
[export]
def variable_arrays(var buf : int?) {
    var grid : array<array<array<int>>> = []
    var counter_1 : int = int(0)
    use_arrays(2, 5, unsafe(unsafe(reinterpret<array<array<int>>?>(unsafe(addr(grid[0]))))))
    use_arrays(2, 5, unsafe(unsafe(reinterpret<array<array<int>>?>(unsafe(unsafe(addr(grid[0])) + 2)))))
    counter_1 = 0
    if (false) {
    }
}
[export]
def alloca_arrays(var buf_0 : int?) {
    var grid_0 : array<array<array<int>>> = []
    var counter_2 : int = int(0)
    use_arrays(2, 5, unsafe(unsafe(reinterpret<array<array<int>>?>(unsafe(addr(grid_0[0]))))))
    use_arrays(2, 5, unsafe(unsafe(reinterpret<array<array<int>>?>(unsafe(unsafe(addr(grid_0[0])) + 2)))))
    counter_2 = 0
    if (false) {
    }
}
[export] def main() : int {
    return 0
}
