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
struct Unnamed {
    y : int
}
struct Unnamed_0 {
    x : int8?
    y : int
}
struct Unnamed_1 {
    x : int
    y : int
}
struct Unnamed_2 {
    x : int
    y : int
}
[export]
def c2da___bswap_16(var c2da___bsx : uint16) : uint16 {
    return uint16(uint(uint(int(c2da___bsx)) >> uint(8)) & uint(255) | uint(int(uint(int(c2da___bsx)) & uint(255) << uint(8))))
}
[export]
def c2da___bswap_32(var c2da___bsx_0 : uint) : uint {
    return uint(uint(uint(c2da___bsx_0)) & uint(0xff000000)) >> uint(uint(24)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff0000)) >> uint(uint(8)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff00)) << uint(uint(8)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff)) << uint(uint(24))
}
[export]
def c2da___bswap_64(var c2da___bsx_1 : uint64) : uint64 {
    return uint64(uint64(c2da___bsx_1) & uint64(0xff00000000000000uL)) >> uint64(uint64(56)) | uint64(uint64(c2da___bsx_1) & uint64(0xff000000000000uL)) >> uint64(uint64(40)) | uint64(uint64(c2da___bsx_1) & uint64(0xff0000000000uL)) >> uint64(uint64(24)) | uint64(uint64(c2da___bsx_1) & uint64(0xff00000000uL)) >> uint64(uint64(8)) | uint64(uint64(c2da___bsx_1) & uint64(0xff000000)) << uint64(uint64(8)) | uint64(uint64(c2da___bsx_1) & uint64(0xff0000)) << uint64(uint64(24)) | uint64(uint64(c2da___bsx_1) & uint64(0xff00)) << uint64(uint64(40)) | uint64(uint64(c2da___bsx_1) & uint64(0xff)) << uint64(uint64(56))
}
[export]
def c2da___uint16_identity(var c2da___x : uint16) : uint16 {
    return c2da___x
}
[export]
def c2da___uint32_identity(var c2da___x_0 : uint) : uint {
    return c2da___x_0
}
[export]
def c2da___uint64_identity(var c2da___x_1 : uint64) : uint64 {
    return c2da___x_1
}
var static_char_array : array<int8> = "mystring"

var static_char_ptr : int8? = unsafe(unsafe(reinterpret<int8?>(unsafe(addr("mystring"[0])))))

var static_void_ptr : uint64 = uint64(unsafe(addr(static_char_array[0])))

[export]
def entry() {
    var int_2d : array<array<int>> = []
    var int_empty_init : array<int> = []
    var int_too_long : array<int> = []
    var int_zero : array<int> = []
    var int_too_short : array<int> = []
    var struct_init_too_short : array<Unnamed_0> = []
    var struct_init_too_long : array<Unnamed> = []
    var char_with_string : array<int8> = []
    var char_with_chars : array<int8> = []
    var char_with_ints : array<int8> = []
    var char_with_init : array<int8> = []
    var char_too_long : array<int8> = []
    var char_too_short : array<int8> = []
    var int_var_ptr : int? = null
    var int_var_array_ptr : array<int>? = null
    var char_var_ptr : int8? = null
    var char_var_array_ptr : array<int8>? = null
    var const_char_lit_ptr : int8 const? = null
    var const_char_lit_array_ptr : array<int8> const? = null
    var char_lit_ptr : int8? = null
    var char_lit_array_ptr : array<int8>? = null
    var past_end : int8? = null
    int_2d = [[1]]
    unsafe(unsafe(addr(unsafe(unsafe(addr(int_2d[0]))[0])[0]))[0]) = unsafe(unsafe(addr(unsafe(unsafe(addr(int_2d[0]))[0])[0]))[0]) + 9
    int_empty_init = []
    unsafe(unsafe(addr(int_empty_init[0]))[15]) = unsafe(unsafe(addr(int_empty_init[0]))[15]) + 9
    int_too_long = [1, 2]
    int_zero = []
    int_too_short = [int(0)]
    unsafe(unsafe(addr(int_too_short[0]))[15]) = unsafe(unsafe(addr(int_too_short[0]))[15]) + 9
    struct_init_too_short = []
    unsafe(unsafe(addr(struct_init_too_short[0]))[0]).y = unsafe(unsafe(addr(struct_init_too_short[0]))[0]).y + 9
    struct_init_too_long = [Unnamed(y = 1)]
    unsafe(unsafe(addr(struct_init_too_long[0]))[0]).y = unsafe(unsafe(addr(struct_init_too_long[0]))[0]).y + 9
    char_with_string = "abc"
    char_with_chars = [int8(100), int8(101), int8(102)]
    char_with_ints = [int8(1)]
    char_with_init = ["abcd"]
    char_too_long = "abcde"
    char_too_short = "abc"
    int_var_ptr = unsafe(addr(int_empty_init[0]))
    int_var_array_ptr = unsafe(addr(int_empty_init))
    char_var_ptr = unsafe(addr(char_with_string[0]))
    char_var_array_ptr = unsafe(addr(char_with_string))
    const_char_lit_ptr = unsafe(addr("abc"[0]))
    const_char_lit_array_ptr = unsafe(addr("abc"))
    char_lit_ptr = unsafe(addr("abc"[0]))
    char_lit_array_ptr = unsafe(addr("abc"))
    past_end = unsafe(addr(unsafe(unsafe(addr(static_char_array[0]))[4])))
    past_end = unsafe(unsafe(reinterpret<int8?>(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<int8?>(static_char_ptr)))[8]))))))
    return
}
[export]
def short_initializer() {
    var empty_brackets : array<int> = []
    var brackets_with_zero : array<int> = []
    var brackets_with_one : array<int> = []
    var excess_elements_1 : array<int> = []
    var excess_elements_2 : array<int> = []
    var single_struct : array<Unnamed_2> = []
    var many_struct : array<Unnamed_1> = []
    empty_brackets = []
    brackets_with_zero = [int(0)]
    brackets_with_one = [1]
    excess_elements_1 = [1, 2]
    excess_elements_2 = []
    single_struct = [Unnamed_2(x = 1, y = 2)]
    many_struct = [Unnamed_1(x = 1, y = 2)]
    return
}
[export] def main() : int {
    return 0
}
