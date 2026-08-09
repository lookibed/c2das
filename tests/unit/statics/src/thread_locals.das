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
var gssi : int = 17

var gesi : int

var gsti : int = 37

var geti : int

[export]
def thread_entry(buffer_size : uint const; var buffer : int?) {
    var fssi : int = 53
    var fesi : int
    var fsti : int = 59
    var feti : int
    var i : int = int(0)
    if (uint(buffer_size) < uint(16)) {
        return
    } else {
        i = 0
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = gssi
            gssi = gssi + 1337
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = gssi
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = gesi
            gesi = gesi + 1337
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = gesi
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = gsti
            gsti = gsti + 1337
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = gsti
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = geti
            geti = geti + 1337
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = geti
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = fssi
            fssi = fssi + 1337
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = fssi
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = fesi
            fesi = fesi + 1337
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = fesi
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = fsti
            fsti = fsti + 1337
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = fsti
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        while (true) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = feti
            feti = feti + 1337
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = feti
            if (!(uint64(0) != uint64(0))) {
                if (false) {
                }
            }
        }
        return
    }
}
[export] def main() : int {
    return 0
}
