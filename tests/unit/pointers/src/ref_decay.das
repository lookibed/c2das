options gen2

struct ThreeFields {
    a : int?
    b : int const?
    c : uint64
}
struct OneInt {
    i : int
}
struct Page {
    idx : uint8?
}
typedef Page = Page
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
def f(var a : int?; var b : int const?) {
}
def bar(var a : int const?) {
    var arr : array<int> = [1, 2, 3]
    var p_arr : array<int>? = reinterpret<array<int>?>(unsafe(addr(arr)))
    f(unsafe(addr(unsafe(addr(arr[0]))[0])), a)
}
def bitcast(var a : uint64) {
}
def foobar(var a : uint?) {
}
def address_cast(var a : uint64) {
}
def cmp_ref(var a : int; var b : int??) : int {
    return unsafe(addr(a)) != *b
}
def takesPtr(var p : uint8 const?) {
}
def calls_all() {
    unsafe {
        var i : int = 1
        var j : int const = 2
        f(unsafe(addr(i)), unsafe(addr(i)))
        bar(unsafe(addr(j)))
        foobar(reinterpret<uint?>(unsafe(addr(i))))
        bitcast(reinterpret<uint64>(unsafe(addr(i))))
        var k : int? = unsafe(addr(i))
        var m : uint64 = reinterpret<uint64>(unsafe(addr(i)))
        var tf : ThreeFields = [unsafe(addr(i)), unsafe(addr(i)), reinterpret<uint64>(unsafe(addr(i)))]
        var l : array<int> = [0, 0]
        sscanf(reinterpret<int8 const?>(k), unsafe(addr("%u,%u"[0])), unsafe(addr(unsafe(addr(l[0]))[0])), unsafe(addr(unsafe(addr(l[0]))[1])))
        var ul : uint64 = 0
        address_cast(reinterpret<uint64>(unsafe(addr(ul))))
        var oi : OneInt?
        var n : int? = unsafe(addr(oi.i))
        if (unsafe(addr(i)) == k) {
        }
        cmp_ref(i, unsafe(addr(n)))
        var o : int = 1
        var p : int = unsafe(addr(o)) - unsafe(addr(i))
        var q : int? = unsafe(addr(o)) + 0
        q = unsafe(addr(o)) - 0
        var r : Page?
        takesPtr(reinterpret<uint8 const?>(unsafe(addr(r.idx[0]))[0]))
    }
}
