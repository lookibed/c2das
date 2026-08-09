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
def entry(var buffer_size : uint; var buffer : int?) {
    var i : int = int(0)
    if (uint(buffer_size) >= uint(70)) {
        i = 0
        while (true) {
            if (!(uint64(1) != uint64(0))) {
                if (false) {
                }
            }
            if (i > 7) {
                if (false) {
                }
                if (false) {
                }
            } else {
                i = i + 1
                unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 2
            if (!i <= 15) {
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 3
            if (i > 20) {
                if (false) {
                }
                if (false) {
                }
            } elif (!(uint64(1) != uint64(0))) {
                if (false) {
                }
            }
        }
        while (true) {
            if (!(uint64(1) != uint64(0))) {
                if (false) {
                }
            }
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 4
            if (i < 30) {
                continue
            } else {
                if (false) {
                }
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 5
            if (i < 40) {
                continue
            }
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
    } else {
        return
    }
}
[export] def main() : int {
    return 0
}
