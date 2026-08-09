options gen2

module shim
require minimp4
struct HeapHeader {
    size : uint64
}
var heap : uint8 [33554432]

var heap_offset : uint64 = uint64(uint64(uint64(uint64(8))))

[export]
def free(var ptr : uint64) {
    return
}
[export]
def shim_reset_heap() {
    heap_offset = uint64(uint64(uint64(8)))
}
[export]
def memcpy(var dest_0 : uint64; var src_0 : uint64; var count_0 : uint64) : uint64 {
    return dest_0
}
[export]
def memchr(var c2da___s : uint64; var c2da___c : int; var c2da___n_1 : uint64) : uint64 {
    return uint64(0)
}
[export]
def strdup(var src_2 : int8 const?) : int8? {
    return null
}
[export]
def mallocz(var size_2 : uint64) : uint64 {
    return unsafe(unsafe(reinterpret<uint64>(unsafe(calloc(uint64(uint64(uint64(0x1))), uint64(size_2))))))
    return unsafe(unsafe(reinterpret<uint64>(null)))
}
[export]
def calloc(var c2da___nmemb : uint64; var c2da___size : uint64) : uint64 {
    return uint64(0)
}
[export]
def memmove(var c2da___dest : uint64; var c2da___src : uint64; var c2da___n : uint64) : uint64 {
    return c2da___dest
}
[export]
def memset(var dest : uint64; var value : int; var count : uint64) : uint64 {
    return dest
}
[export]
def malloc(var size : uint64) : uint64 {
    return uint64(0)
}
[export]
def memcmp(var c2da___s1 : uint64; var c2da___s2 : uint64; var c2da___n_0 : uint64) : int {
    return 0
}
[export]
def strlen(var src_1 : int8 const?) : uint64 {
    return uint64(0)
}
[export]
def realloc(var ptr_0 : uint64; var size_0 : uint64) : uint64 {
    return uint64(0)
}