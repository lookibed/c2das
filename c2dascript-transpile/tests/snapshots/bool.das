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
def test_bool() {
    var int0 : bool = bool(0)
    var ident0 : bool = bool(0)
    var macro_int0 : bool = bool(0)
    var macro_ident0 : bool = bool(0)
    var int1 : bool = bool(0)
    var ident1 : bool = bool(0)
    var macro_int1 : bool = bool(0)
    var macro_ident1 : bool = bool(0)
    int0 = 0
    ident0 = 0
    macro_int0 = 0
    macro_ident0 = 0
    int1 = 1
    ident1 = 1
    macro_int1 = 1
    macro_ident1 = 1
    var c2da_fresh0 : int = int(0)
    if (uint64(0) != uint64(0)) {
        c2da_fresh0 = 2
    } else {
        c2da_fresh0 = 3
    }
    c2da_fresh0
    var c2da_fresh1 : int = int(0)
    if (uint64(0) != uint64(0)) {
        c2da_fresh1 = 2
    } else {
        c2da_fresh1 = 3
    }
    c2da_fresh1
    var c2da_fresh2 : int = int(0)
    if (uint64(0) != uint64(0)) {
        c2da_fresh2 = 2
    } else {
        c2da_fresh2 = 3
    }
    c2da_fresh2
    var c2da_fresh3 : int = int(0)
    if (uint64(0) != uint64(0)) {
        c2da_fresh3 = 2
    } else {
        c2da_fresh3 = 3
    }
    c2da_fresh3
    var c2da_fresh4 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh4 = 2
    } else {
        c2da_fresh4 = 3
    }
    c2da_fresh4
    var c2da_fresh5 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh5 = 2
    } else {
        c2da_fresh5 = 3
    }
    c2da_fresh5
    var c2da_fresh6 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh6 = 2
    } else {
        c2da_fresh6 = 3
    }
    c2da_fresh6
    var c2da_fresh7 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh7 = 2
    } else {
        c2da_fresh7 = 3
    }
    c2da_fresh7
    int0 = int0 | int(int1)
    return
}
[export] def main() : int {
    return 0
}
