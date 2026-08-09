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
struct c2da___va_list_tag {
    gp_offset : uint
    fp_offset : uint
    overflow_arg_area : uint64
    reg_save_area : uint64
}
typedef va_list = array<c2da___va_list_tag>
typedef char_to_int = function
typedef char_to_int_fp = function?
typedef va_char_to_int_fp = function?
typedef char_int_to_int_fp = function?
typedef knr = function
struct pointer_st {
    fn : function?
}
[export]
def intval(c : int8 const) : int {
    return int(c)
}
[export]
def negintval(c_0 : int8 const) : int {
    return -int(c_0)
}
[export]
def varargs_intval(c_1 : int8 const) : int {
    return int(c_1)
}
[export]
def entry3(sz : uint const; var buffer : int?) {
    var i : int = int(0)
    var p0 : char_to_int? = null
    var p1 : char_to_int? = null
    var p2 : char_to_int? = null
    var p3 : char_to_int? = null
    var p4 : char_to_int_fp = unsafe(reinterpret<char_to_int_fp>(0))
    var p5 : char_to_int_fp = unsafe(reinterpret<char_to_int_fp>(0))
    var p6 : char_to_int_fp = unsafe(reinterpret<char_to_int_fp>(0))
    var p7 : char_to_int_fp = unsafe(reinterpret<char_to_int_fp>(0))
    var funs : array<char_to_int_fp> = []
    i = 0
    p1 = null
    p2 = intval
    p3 = unsafe(addr(intval))
    p3 = unsafe(unsafe(reinterpret<char_to_int?>(intval)))
    p3 = unsafe(unsafe(reinterpret<char_to_int?>(unsafe(addr(intval)))))
    if (p1 == null && p3 != null && !(p3 == null) && unsafe(uint64(unsafe(reinterpret<uint64>(p3))) != uint64(0)) {
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = p3(int8(97))
    }
    i = i + 1
    i
    p5 = null
    p6 = intval
    p7 = unsafe(addr(intval))
    p7 = intval
    p7 = unsafe(addr(intval))
    if (p5 == null && p7 != null && !(p7 == null) && unsafe(uint64(unsafe(reinterpret<uint64>(p7))) != uint64(0)) {
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = *p7(int8(97))
    }
    i = i + 1
    i
    funs = [intval, negintval]
    if (false) {
    }
}
[export] def main() : int {
    return 0
}
