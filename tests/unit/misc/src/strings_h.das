options gen2

def setmem(var size : uint; var buffer : int?) {
    memset(buffer, 1, size * 4)
}
