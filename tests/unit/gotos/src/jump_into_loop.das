options gen2

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
def jump_into_loop() : int {
    var x : int = 0
    while (x < 10) {
        if (x > 11) {
            label 1574:
            exit(x)
        }
    }
    x = 1
    goto label 1574
    return 1
}
