module array_ctor_probe3

var g : uint8 [2] [3] = unsafe(reinterpret<uint8 [2] [3]>(fixed_array<uint8 [3]>(fixed_array<uint8>(uint8(1), uint8(2), uint8(3)), fixed_array<uint8>(uint8(4), uint8(5), uint8(6)))))

def main() {
    var a : uint8 [2] [3] = unsafe(reinterpret<uint8 [2] [3]>(fixed_array<uint8 [3]>(fixed_array<uint8>(uint8(1), uint8(2), uint8(3)), fixed_array<uint8>(uint8(4), uint8(5), uint8(6)))))
    print("{a[0][0]} {a[0][1]} {a[0][2]} {a[1][0]} {a[1][1]} {a[1][2]}\n")
}
