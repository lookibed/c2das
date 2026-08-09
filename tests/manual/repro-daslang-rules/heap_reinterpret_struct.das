options gen2

struct Pair {
    a : int
    b : int
}

var heap : array<uint8>

[export]
def main() {
    resize(heap, 1024)
    var raw = intptr(unsafe(addr(heap[8])))
    var p = unsafe(reinterpret<Pair?>(raw))
    unsafe(*p).a = 11
    unsafe(*p).b = 17
    print("a={unsafe(*p).a} b={unsafe(*p).b}\n")
}
