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
enum Color : uint {
    Red = 1
    Green = 2
    Blue = 3
}
[export]
def red() : Color {
    var bar : Color = unsafe(reinterpret<Color>(0))
    bar = unsafe(reinterpret<Color>(Red))
    return bar
}
[export]
def entry2(buffer_size : uint const; var buffer : int?) {
    var b : Color = unsafe(reinterpret<Color>(0))
    var c : Color_0 = unsafe(reinterpret<Color_0>(0))
    var invalid : Color = unsafe(reinterpret<Color>(0))
    if (uint(buffer_size) < uint(5)) {
        return
    } else {
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]) = int(red())
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[1]) = int(Red) + 1
        b = unsafe(reinterpret<Color>(Blue))
        if (ub == uint(Blue)) {
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[2]) = -1
        }
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[3]) = Purple
        if (int(Purple) == int(Red)) {
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[4]) = -2
        }
        c = unsafe(reinterpret<Color_0>(Red))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[5]) = int(c)
        invalid = unsafe(reinterpret<Color>(6))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[6]) = int(invalid)
        return
    }
}
var Blue : int = 3

var Green : int = 2

var Red : int = 1

var Green_0 : int = 3

var Yellow : int = 2

var Purple : int = 1
[export] def main() : int {
    return 0
}
