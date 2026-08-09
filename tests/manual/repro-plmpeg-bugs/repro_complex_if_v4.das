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
typedef size_t = uint64
struct buffer_t {
    bit_index : size_t
    capacity : size_t
    length : size_t
    total_size : size_t
    has_ended : int
}
[export]
def plm_buffer_has(var self : buffer_t?; var count : size_t) : int {
    if ((unsafe(reinterpret<size_t>(self.length)) << unsafe(reinterpret<size_t>(3))) - unsafe(reinterpret<size_t>(self.bit_index)) >= unsafe(reinterpret<size_t>(count))) {
        return 1
    } else {
        if (uint64(unsafe(reinterpret<size_t>(self.total_size))) != uint64(0) && unsafe(reinterpret<size_t>(self.length)) == unsafe(reinterpret<size_t>(self.total_size))) {
            self.has_ended = 1
        }
        return 0
    }
}
[export] def main() : int {
    return 0
}
