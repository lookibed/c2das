module array_ctor_probe2

def main() {
    var a : uint8 [2] [3] = [[uint8 [2] [3] fixed_array<uint8>(uint8(1), uint8(2), uint8(3)); fixed_array<uint8>(uint8(4), uint8(5), uint8(6))]]
    var b : uint8 [2] [3] = [[uint8 [2] [3] [uint8(1), uint8(2), uint8(3)]; [uint8(4), uint8(5), uint8(6)]]]
    var c : uint8 [2] [3] = [[uint8 [2] [3] [uint8(1); uint8(2); uint8(3)]; [uint8(4); uint8(5); uint8(6)]]]
}
