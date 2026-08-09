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
def entry2(var buffer_size : uint; var buffer : int?) {
    var p : int? = null
    if (uint(buffer_size) < uint(100)) {
        return
    } else {
        p = buffer
        *p = 1
        p = unsafe(p + uint64(1))
        p
        p = unsafe(p + uint64(1))
        *p = 2
        p = unsafe(p + uint64(1))
        p
        *p = *p + 1
        *p
        p = unsafe(p + uint64(1))
        p
        *p = *p + 1
        *p
        p = unsafe(p + uint64(1))
        p
        p = unsafe(p + uint64(1))
        *p = 15 + 17
        p = unsafe(p + uint64(1))
        *p = 15 - 17
        p = unsafe(p + uint64(1))
        *p = 15 * 17
        p = unsafe(p + uint64(1))
        *p = 150 / 17
        p = unsafe(p + uint64(1))
        *p = 150 % 17
        p = unsafe(p + uint64(1))
        *p = uint(150) << uint(17)
        p = unsafe(p + uint64(1))
        *p = uint(150) >> uint(3)
        p = unsafe(p + uint64(1))
        *p = uint(150) | uint(3)
        p = unsafe(p + uint64(1))
        *p = uint(3) & uint(6)
        p = unsafe(p + uint64(1))
        *p = int(uint64(10) != uint64(0) && uint64(20) != uint64(0))
        p = unsafe(p + uint64(1))
        *p = int(uint64(0) != uint64(0) && uint64(20) != uint64(0))
        p = unsafe(p + uint64(1))
        *p = int(uint64(10) != uint64(0) && uint64(0) != uint64(0))
        p = unsafe(p + uint64(1))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]) = 100
        *p = int(uint64(0) != uint64(0) && uint64(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0])) != uint64(0))
        p = unsafe(p + uint64(1))
        *p = int(uint64(10) != uint64(0) || uint64(20) != uint64(0))
        p = unsafe(p + uint64(1))
        *p = int(uint64(0) != uint64(0) || uint64(20) != uint64(0))
        p = unsafe(p + uint64(1))
        *p = int(uint64(10) != uint64(0) || uint64(0) != uint64(0))
        p = unsafe(p + uint64(1))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]) = 100
        *p = int(uint64(1) != uint64(0) || uint64(unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0])) != uint64(0))
        p = unsafe(p + uint64(1))
        *p = uint(7) ^ uint(8)
        p = unsafe(p + uint64(1))
        *p = int(10 == 20)
        p = unsafe(p + uint64(1))
        *p = int(10 == 10)
        p = unsafe(p + uint64(1))
        *p = int(20 == 10)
        p = unsafe(p + uint64(1))
        *p = int(10 != 20)
        p = unsafe(p + uint64(1))
        *p = int(10 != 10)
        p = unsafe(p + uint64(1))
        *p = int(20 != 10)
        p = unsafe(p + uint64(1))
        *p = int(10 < 20)
        p = unsafe(p + uint64(1))
        *p = int(10 < 10)
        p = unsafe(p + uint64(1))
        *p = int(20 < 10)
        p = unsafe(p + uint64(1))
        *p = int(10 > 20)
        p = unsafe(p + uint64(1))
        *p = int(10 > 10)
        p = unsafe(p + uint64(1))
        *p = int(20 > 10)
        p = unsafe(p + uint64(1))
        *p = int(10 <= 20)
        p = unsafe(p + uint64(1))
        *p = int(10 <= 10)
        p = unsafe(p + uint64(1))
        *p = int(20 <= 10)
        p = unsafe(p + uint64(1))
        *p = int(10 >= 20)
        p = unsafe(p + uint64(1))
        *p = int(10 >= 10)
        p = unsafe(p + uint64(1))
        *p = int(20 >= 10)
        p = unsafe(p + uint64(1))
        *p = *p + 10
        p = unsafe(p + uint64(1))
        *p = *p - 10
        *p = 100
        p = unsafe(p + uint64(1))
        *p = *p * 9
        *p = 100
        p = unsafe(p + uint64(1))
        *p = *p / 9
        *p = 100
        p = unsafe(p + uint64(1))
        *p = *p % 9
        p = unsafe(p + uint64(1))
        *p = uint(*p) | uint(9)
        *p = 7
        p = unsafe(p + uint64(1))
        *p = uint(*p) & uint(9)
        *p = 7
        p = unsafe(p + uint64(1))
        *p = uint(*p) ^ uint(9)
        *p = 10
        p = unsafe(p + uint64(1))
        *p = uint(*p) << uint(3)
        *p = 1000
        p = unsafe(p + uint64(1))
        *p = uint(*p) >> uint(3)
        p = unsafe(p + uint64(1))
        *p = 98
        p = unsafe(p + uint64(1))
        *p = ~1000
        p = unsafe(p + uint64(1))
        *p = int(uint64(1000) == uint64(0))
        p = unsafe(p + uint64(1))
        *p = int(uint64(0) == uint64(0))
        p = unsafe(p + uint64(1))
        *p = -1000
        p = unsafe(p + uint64(1))
        *p = 1000
        return
    }
}
[export] def main() : int {
    return 0
}
