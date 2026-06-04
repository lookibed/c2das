options gen2

typedef size_t = uint64
def setmem(var size : uint; var buffer : int?) {
    memset(reinterpret<uint64>(buffer), 1, size * 4)
}
