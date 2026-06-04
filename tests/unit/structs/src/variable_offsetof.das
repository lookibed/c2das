options gen2

typedef size_t = uint64
struct use {
    a : int
    mod : array<float>
}
struct yield {
    a : int
    mod : array<float>
}
def get_offset(var idx : size_t) : size_t {
    return cast<uint64>(0)
}
def get_offset2(var idx : size_t) : size_t {
    return cast<uint64>(0)
}
