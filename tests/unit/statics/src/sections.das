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
typedef uintptr_t = uint64
struct Foo {
    a : uint
    b : int
    c : float
}
struct Bar {
    bar : int?
}
struct stat {
    f : int??
}
struct stat2 {
    f : int?
}
typedef void_fn_ptr = function?
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
var params : array<Foo> = [Foo(a = uint(1), b = 0, c = float(double(1.3))), Foo(a = uint(1), b = 0, c = float(double(1.2)))]

var dont_section_a : int = 0

var dont_section_b : int = -1

var dont_section_c : int? = unsafe(unsafe(reinterpret<int?>(unsafe(addr(dont_section_a)))))

var dont_section_d : int? = unsafe(unsafe(reinterpret<int?>(unsafe(addr(dont_section_d)))))

var dont_section_foo : Foo

var dont_section_me : uint = uint(1 + 1)

var bar : Bar

var int_to_pointer : uint64 = unsafe(unsafe(reinterpret<uint64>(-1)))

var null_to_ptr_ty : uintptr_t = unsafe(reinterpret<uintptr_t>(uint64(0)))

var section_me : uint = -0x1

var section_me2 : int = unsafe(unsafe(reinterpret<int>(uint64(0))))

var section_me3 : uint = 0x1 + 0x2

var section_me4 : uint = uint(1) + 0x1

var section_me5 : uint = 0x1 + uint(1)

var section_foo_b_field : Foo = Foo(a = uint(1), b = int(-0x1), c = float(double(1.2)))

var section_num_params : uint const = uint(uint(4 / 4))

var if_expr : size_t const = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(c2da_fresh0))))

var s : stat = stat(f = unsafe(addr(bar.bar)))

var s2 : stat2 = stat2(f = unsafe(unsafe(reinterpret<int?>(unsafe(addr(bar.bar))))))

var int_to_fn_ptr : function? = unsafe(unsafe(reinterpret<function?>(-1)))

var int_to_fn_ptr2 : function? = unsafe(unsafe(reinterpret<function?>(-1)))

var int_to_fn_ptr3 : void_fn_ptr = unsafe(unsafe(reinterpret<void_fn_ptr>(-1)))

[export]
def fn_scoped_static_init() : size_t {
    var fn_scoped_extern : size_t
    var sectioned_scoped_init : size_t = unsafe(unsafe(reinterpret<size_t>(unsafe(addr(section_me)))))
    var not_sectioned : uint = uint(1)
    section_me = unsafe(reinterpret<size_t>(section_me - fn_scoped_extern))
    return sectioned_scoped_init
}
var fn_scoped_extern_0 : size_t = unsafe(reinterpret<size_t>(1))

var sectioned_array : array<size_t> = [unsafe(addr(unsafe(unsafe(reinterpret<Foo?>(0))).a))]

[export]
def use_sectioned_array() {
    var f : size_t = unsafe(reinterpret<size_t>(0))
    f = unsafe(unsafe(addr(sectioned_array[0]))[0])
    return
}
[export] def main() : int {
    return 0
}
