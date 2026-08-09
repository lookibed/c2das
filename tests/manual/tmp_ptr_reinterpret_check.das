options gen2

def main() {
    var data : array<uint8>
    resize(data, 1)
    var p : uint8? = unsafe(addr(data[0]))
    var x : uint64 = unsafe(reinterpret<uint64>(p))
    var y : uint64 = unsafe(reinterpret<uint64>(unsafe(addr(data[0]))))
    print("ok")
}
