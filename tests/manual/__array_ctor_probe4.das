module array_ctor_probe4

var tbl : uint8 [2] [3] = unsafe(reinterpret<uint8 [2] [3]>(fixed_array<uint8 [3]>(fixed_array<uint8>(uint8(0x1), uint8(0x2), uint8(0x3)), fixed_array<uint8>(uint8(0x4), uint8(0x5), uint8(0x6)))))

def probe() : int {
    return int(tbl[0][0]) + int(tbl[0][1]) + int(tbl[0][2]) + int(tbl[1][0]) + int(tbl[1][1]) + int(tbl[1][2])
}
