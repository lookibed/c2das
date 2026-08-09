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
typedef ushort = int
typedef uint32_t = uint
typedef uchar = uint8
struct three_byte_date {
    day : uint8
    month : uint8
    year : int
}
struct padded_bitfield {
    x : int64
    c2da_unnamed : int
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
    f5 : uint
    c2da_unnamed : uint
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
[export]
def zeroed_three_byte_date() : three_byte_date {
    var tbd : three_byte_date = three_byte_date()
    tbd = three_byte_date(day = uint8(0), month = uint8(0), year = 0)
    return tbd
}
[export]
def size_of_three_byte_date() : size_t {
    return 4
}
[export]
def compare_three_byte_date(var tbd_0 : three_byte_date const?; var d : uint8; var m : uint8; var y : int) : uint8 {
    if (int(tbd_0.day) != int(d)) {
        return uint8(1)
    } elif (int(tbd_0.month) != int(m)) {
        return uint8(2)
    } elif (int(tbd_0.year) != int(y)) {
        return uint8(3)
    } else {
        return uint8(0)
    }
}
[export]
def write_three_byte_date(var tbd_1 : three_byte_date?; var d_0 : uint8; var m_0 : uint8; var y_0 : int) {
    tbd_1.day = uint8(d_0)
    tbd_1.month = uint8(m_0)
    tbd_1.year = int(y_0)
    return
}
[export]
def zeroed_padded_bitfield() : padded_bitfield {
    var pb : padded_bitfield = padded_bitfield()
    pb = padded_bitfield(x = int64(0), c2da_unnamed = uint64(0))
    return pb
}
[export]
def size_of_padded_bitfield() : size_t {
    return 4
}
[export]
def ops_padded_bitfield(var bf : padded_bitfield?) {
    bf.x = int64(bf.x % 2)
    bf.x = int64(bf.x + 1)
    bf.x = int64(bf.x * 2)
    bf.x = int64(bf.x - 1)
    bf.x = int64(bf.x / 2)
    bf.x = int64(uint(bf.x) ^ uint(1))
    bf.x = uint(bf.x) >> uint(2)
    bf.x = uint(bf.x) << uint(1)
    bf.x = int64(uint(bf.x) & uint(1))
    bf.x = int64(uint(bf.x) | uint(2))
    bf.x = bf.x + int64(1)
    bf.x
    bf.x = bf.x - int64(1)
    bf.x
    bf.x = bf.x % 2
    bf.x = bf.x + 1
    bf.x = bf.x * 2
    bf.x = bf.x - 1
    bf.x = bf.x / 2
    bf.x = uint(bf.x) ^ uint(1)
    bf.x = uint(bf.x) >> uint(2)
    bf.x = uint(bf.x) << uint(1)
    bf.x = uint(bf.x) & uint(1)
    bf.x = uint(bf.x) | uint(2)
    return
}
[export]
def ops_padded_bitfield_init() : padded_bitfield {
    var bf_0 : padded_bitfield = padded_bitfield()
    bf_0 = padded_bitfield(x = int64(13), c2da_unnamed = uint64(0))
    bf_0.x = int64(bf_0.x % 2)
    bf_0.x = int64(bf_0.x + 1)
    bf_0.x = int64(bf_0.x * 2)
    bf_0.x = int64(bf_0.x - 1)
    bf_0.x = int64(bf_0.x / 2)
    bf_0.x = int64(uint(bf_0.x) ^ uint(1))
    bf_0.x = uint(bf_0.x) >> uint(2)
    bf_0.x = uint(bf_0.x) << uint(1)
    bf_0.x = int64(uint(bf_0.x) & uint(1))
    bf_0.x = int64(uint(bf_0.x) | uint(2))
    bf_0.x = bf_0.x + int64(1)
    bf_0.x
    bf_0.x = bf_0.x - int64(1)
    bf_0.x
    bf_0.x = bf_0.x % 2
    bf_0.x = bf_0.x + 1
    bf_0.x = bf_0.x * 2
    bf_0.x = bf_0.x - 1
    bf_0.x = bf_0.x / 2
    bf_0.x = uint(bf_0.x) ^ uint(1)
    bf_0.x = uint(bf_0.x) >> uint(2)
    bf_0.x = uint(bf_0.x) << uint(1)
    bf_0.x = uint(bf_0.x) & uint(1)
    bf_0.x = uint(bf_0.x) | uint(2)
    return bf_0
}
var static_date : three_byte_date = three_byte_date(day = uint8(13), month = uint8(12), year = 2018)

[export]
def size_of_mixed_bitfields() : size_t {
    return 4
}
[export]
def init_bitfield_array(var bfs : mixed_bitfields?; var size : size_t) : double? {
}
[export]
def zeroed_mixed_bitfields() : mixed_bitfields {
    var mb : mixed_bitfields = mixed_bitfields()
    mb = mixed_bitfields(x = uint64(0), y = double(0.0))
    return mb
}
[export]
def size_of_from_csmith() : size_t {
    return 4
}
[export]
def init_from_csmith() : from_csmith {
    var fc : from_csmith = from_csmith()
    fc = from_csmith(f0 = 1, f1 = uint(2), f2 = uint(3), f3 = uint(4), f4 = uint(5), f5 = uint(6), c2da_unnamed = 7)
    return fc
}
var s : S

[export]
def get_bf_ptr() : S? {
    return unsafe(unsafe(reinterpret<S?>(unsafe(addr(s)))))
}
[export]
def modify_bf_ptr() {
    get_bf_ptr().a = 1
    get_bf_ptr().a = get_bf_ptr().a + 1
    return
}
[export]
def size_of_two_eight_bits() : size_t {
    return 4
}
[export]
def two_eight_bits_init() : two_eight_bits {
    var teb : two_eight_bits = two_eight_bits()
    teb = two_eight_bits(a = 0, b = 0)
    return teb
}
var ma_results : array<uint8> = [uint8(0)]

[export]
def multiple_assignments() {
    var a : uint8 = uint8(0)
    var b : uint8 = uint8(0)
    var tbd_2 : three_byte_date = three_byte_date()
    a = uint8(3)
    b = uint8(2)
    tbd_2 = three_byte_date(day = uint8(0), month = uint8(0), year = 0)
    a = uint8(uint8(4))
    tbd_2.day = a
    unsafe(unsafe(addr(ma_results[0]))[0]) = uint8(tbd_2.day)
    unsafe(unsafe(addr(ma_results[0]))[1]) = uint8(a)
    tbd_2.day = uint8(b)
    tbd_2.month = tbd_2.day
    unsafe(unsafe(addr(ma_results[0]))[2]) = uint8(tbd_2.day)
    unsafe(unsafe(addr(ma_results[0]))[3]) = uint8(tbd_2.month)
    tbd_2.month = uint8(uint8(tbd_2.year = int(8)))
    tbd_2.day = tbd_2.month
    tbd_2.month = tbd_2.day
    unsafe(unsafe(addr(ma_results[0]))[4]) = uint8(tbd_2.day)
    unsafe(unsafe(addr(ma_results[0]))[5]) = uint8(tbd_2.month)
    unsafe(unsafe(addr(ma_results[0]))[6]) = uint8(uint8(tbd_2.year))
    tbd_2.month = uint8(uint8(9))
    b = uint8(tbd_2.month)
    a = b
    unsafe(unsafe(addr(ma_results[0]))[7]) = uint8(a)
    unsafe(unsafe(addr(ma_results[0]))[8]) = uint8(b)
    tbd_2.day = uint8(tbd_2.month)
    b = tbd_2.day
    unsafe(unsafe(addr(ma_results[0]))[9]) = uint8(b)
    unsafe(unsafe(addr(ma_results[0]))[10]) = uint8(tbd_2.day)
    tbd_2.day = uint8(uint8(5))
    a = tbd_2.day
    unsafe(unsafe(addr(ma_results[0]))[11]) = uint8(tbd_2.day)
    unsafe(unsafe(addr(ma_results[0]))[12]) = uint8(a)
    tbd_2.year = int(int(a = uint8(b)))
    unsafe(unsafe(addr(ma_results[0]))[13]) = uint8(uint8(tbd_2.year))
    unsafe(unsafe(addr(ma_results[0]))[14]) = uint8(a)
    tbd_2.day = tbd_2.day + int(tbd_2.month = tbd_2.month + 1)
    unsafe(unsafe(addr(ma_results[0]))[15]) = uint8(tbd_2.day)
    unsafe(unsafe(addr(ma_results[0]))[16]) = uint8(tbd_2.month)
    return
}
[export]
def use_renamed_field() {
    var rr : renamer_required = renamer_required()
    rr.use = uint(uint(0))
    return
}
[export] def main() : int {
    return 0
}
