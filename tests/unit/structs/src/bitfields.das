options gen2

typedef size_t = uint64
typedef ushort = int
typedef uint32_t = uint64
typedef uchar = uint8
struct three_byte_date {
    day : uint8
    month : uint8
    year : int
}
struct padded_bitfield {
    x : int64
    _unnamed : int
    z : uint64
}
struct mixed_bitfields {
    x : uint64
    y : double
}
struct from_csmith {
    f0 : int
    f1 : uint
    f2 : uint
    f3 : uint const
    f4 : uint
    f5 : uint32_t
    _unnamed : uint
    f6 : int
}
struct S {
    a : int
}
struct two_eight_bits {
    a : int
    b : int
}
struct renamer_required {
    a : int
    use : uint
}
def _bswap_16(var _bsx : __uint16_t) : __uint16_t {
    return cast<__uint16_t>(__bsx >> 8 & 255 | __bsx & 255 << 8)
}
def _bswap_32(var _bsx : __uint32_t) : __uint32_t {
    return __bsx & 4278190080 >> 24 | __bsx & 16711680 >> 8 | __bsx & 65280 << 8 | __bsx & 255 << 24
}
def _bswap_64(var _bsx : __uint64_t) : __uint64_t {
    return __bsx & -72057594037927936 >> 56 | __bsx & 71776119061217280 >> 40 | __bsx & 280375465082880 >> 24 | __bsx & 1095216660480 >> 8 | __bsx & 4278190080 << 8 | __bsx & 16711680 << 24 | __bsx & 65280 << 40 | __bsx & 255 << 56
}
def _uint16_identity(var _x : __uint16_t) : __uint16_t {
    return __x
}
def _uint32_identity(var _x : __uint32_t) : __uint32_t {
    return __x
}
def _uint64_identity(var _x : __uint64_t) : __uint64_t {
    return __x
}
def zeroed_three_byte_date() : three_byte_date {
    var tbd : three_byte_date = [0, 0, 0]
    return tbd
}
def size_of_three_byte_date() : size_t {
    return 4
}
def compare_three_byte_date(var tbd : three_byte_date const?; var d : uchar; var m : uchar; var y : ushort) : uint8 {
    if (tbd.day != d) {
        return 1
    }
    if (tbd.month != m) {
        return 2
    }
    if (tbd.year != y) {
        return 3
    }
    return 0
}
def write_three_byte_date(var tbd : three_byte_date?; var d : uchar; var m : uchar; var y : ushort) {
    tbd.day = d
    tbd.month = m
    tbd.year = y
}
def zeroed_padded_bitfield() : padded_bitfield {
    var pb : padded_bitfield = [0, 0]
    return pb
}
def size_of_padded_bitfield() : size_t {
    return 4
}
var static_date : three_byte_date = [13, 12, 2018]

def size_of_mixed_bitfields() : size_t {
    return 4
}
def zeroed_mixed_bitfields() : mixed_bitfields {
    var mb : mixed_bitfields = [0, double(0.0)]
    return mb
}
def size_of_from_csmith() : size_t {
    return 4
}
def init_from_csmith() : from_csmith {
    var fc : from_csmith = [1, 2, 3, 4, 5, 6, 7]
    return fc
}
var s : S

def get_bf_ptr() : S? {
    return unsafe(addr(s))
}
def modify_bf_ptr() {
    get_bf_ptr().a = 1
    get_bf_ptr().a += 1
}
def size_of_two_eight_bits() : size_t {
    return 4
}
def two_eight_bits_init() : two_eight_bits {
    var teb : two_eight_bits = [0, 0]
    return teb
}
var ma_results : array<uint8> = [0]

def multiple_assignments() {
    unsafe {
        var a : uint8 = 3
        var b : uint8 = 2
        var tbd : three_byte_date = [0, 0, 0]
        tbd.day = a = 4
        unsafe(addr(ma_results[0]))[0] = tbd.day
        unsafe(addr(ma_results[0]))[1] = a
        tbd.month = tbd.day = b
        unsafe(addr(ma_results[0]))[2] = tbd.day
        unsafe(addr(ma_results[0]))[3] = tbd.month
        tbd.month = tbd.day = tbd.month = tbd.year = 8
        unsafe(addr(ma_results[0]))[4] = tbd.day
        unsafe(addr(ma_results[0]))[5] = tbd.month
        unsafe(addr(ma_results[0]))[6] = tbd.year
        tbd.month = 9
        a = b = tbd.month
        unsafe(addr(ma_results[0]))[7] = a
        unsafe(addr(ma_results[0]))[8] = b
        b = tbd.day = tbd.month
        unsafe(addr(ma_results[0]))[9] = b
        unsafe(addr(ma_results[0]))[10] = tbd.day
        a = tbd.day = 5
        unsafe(addr(ma_results[0]))[11] = tbd.day
        unsafe(addr(ma_results[0]))[12] = a
        tbd.year = a = b
        unsafe(addr(ma_results[0]))[13] = tbd.year
        unsafe(addr(ma_results[0]))[14] = a
        tbd.day += tbd.month += 1
        unsafe(addr(ma_results[0]))[15] = tbd.day
        unsafe(addr(ma_results[0]))[16] = tbd.month
    }
}
def use_renamed_field() {
    var rr : renamer_required
    rr.use = 0
}
