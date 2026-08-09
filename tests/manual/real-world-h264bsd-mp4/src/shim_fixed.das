options gen2

typedef size_t = uint64
struct HeapHeader {
    size : size_t
}
typedef HeapHeader = HeapHeader
var heap : array<uint8>  // 32MB heap (truncated from transpile)
var heap_offset : size_t = 8

def shim_reset_heap() {
    heap_offset = 8
}
def malloc(var size : size_t) : uint64 {
    var aligned_header : size_t const = 4 + 7 & ~cast<size_t>(7)
    var aligned_size : size_t const = size + 7 & ~cast<size_t>(7)
    var total : size_t const = aligned_header + aligned_size
    var header : HeapHeader? = null
    if (heap_offset + total > 4) {
        return null
    }
    header = reinterpret<HeapHeader?>(unsafe(addr(heap[0])) + heap_offset)
    header.size = size
    heap_offset += total
    return reinterpret<uint64>(reinterpret<uint8?>(header) + aligned_header)
}
def free(var ptr : uint64) {
    ptr
}
def strlen(var src : int8 const?) : size_t {
    var count : size_t = 0
    while (src[count] != 0) {
        count += 1
    }
    return count
}
def mallocz(var size : size_t) : uint64 {
    return calloc(1, size)
}
