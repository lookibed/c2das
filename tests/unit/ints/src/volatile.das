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
struct some_struct {
    buffer : array<int8>
}
[export]
def mutate_buffer(var dest : int8?; var src : int8 const?; var size : int) {
    while (true) {
        size = size - 1
        if (!(uint64(int(size)) != uint64(0))) {
            if (false) {
            }
        }
        dest = unsafe(dest + uint64(1))
        src = unsafe(src + uint64(1))
        *dest = *src
    }
    return
}
[export]
def entry3(buffer_size : uint const; var buffer : int?) {
    var n : int = int(0)
    var p : int? = null
    var c : int8 = int8(0)
    var src_0 : array<int8> = []
    var s : some_struct = some_struct()
    if (uint(buffer_size) < uint(5)) {
        return
    } else {
        n = 0
        n = 5
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]) = n
        n = n + 4
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[1]) = int(n) + 2
        p = unsafe(addr(n))
        *p = 5
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[2]) = n
        *p = *p + 4
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[3]) = *p
        c = int8(10)
        c = c * double(9.9)
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[4]) = int(c)
        src_0 = "test"
        mutate_buffer(unsafe(addr(s.buffer[0])), unsafe(addr(src_0[0])), 4)
        unsafe(addr(s.buffer[0]))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[5]) = int(unsafe(unsafe(addr(s.buffer[0]))[0]))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[6]) = int(unsafe(unsafe(addr(s.buffer[0]))[1]))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[7]) = int(unsafe(unsafe(addr(s.buffer[0]))[2]))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[8]) = int(unsafe(unsafe(addr(s.buffer[0]))[3]))
        return
    }
}
[export] def main() : int {
    return 0
}
