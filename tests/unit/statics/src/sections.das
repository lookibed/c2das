options gen2

struct Foo {
    a : uint
    b : int
    c : float
}
typedef Foo = Foo
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
var params : array<Foo> = [[1, 0, cast<float>(double(1.3))], [1, 0, cast<float>(double(1.2))]]

var dont_section_a : int = 0

var dont_section_b : int = -1

var dont_section_c : int? = unsafe(addr(dont_section_a))

var dont_section_d : int? = unsafe(addr(dont_section_d))

var dont_section_foo : Foo

var dont_section_me : uint = 1 + 1

var bar : Bar

var int_to_pointer : void? = -1

var null_to_ptr_ty : uintptr_t = cast<uintptr_t>(cast<void?>(0))

var section_me : uint = -1

var section_me2 : int = cast<void?>(0)

var section_me3 : uint = 1 + 2

var section_me4 : uint = 1 + 1

var section_me5 : uint = 1 + 1

var section_foo_b_field : Foo = [1, -1, cast<float>(double(1.2))]

var section_num_params : uint const = 4 / 4

var s : stat = [unsafe(addr(bar.bar))]

var s2 : stat2 = [unsafe(addr(bar.bar))]

var int_to_fn_ptr : function? = -1

var int_to_fn_ptr2 : function? = -1

var int_to_fn_ptr3 : void_fn_ptr = -1

def fn_scoped_static_init() : size_t {
    var fn_scoped_extern : size_t
    var sectioned_scoped_init : size_t = unsafe(addr(section_me))
    var not_sectioned : uint = 1
    section_me -= fn_scoped_extern
    return sectioned_scoped_init
}
var fn_scoped_extern : size_t = 1

var sectioned_array : array<size_t> = [cast<size_t>(unsafe(addr(cast<Foo?>(0).a)))]

def use_sectioned_array() {
    var f : size_t = unsafe(addr(sectioned_array[0]))[0]
}
