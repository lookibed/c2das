options gen2

def setmem(size : uint; var buffer : int?) {
    memset(buffer, 1, size * 4)
}
