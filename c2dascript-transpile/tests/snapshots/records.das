options gen2

def c2da_min_int(a : int; b : int) : int {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int(a : int; b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint(a : uint; b : uint) : uint {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint(a : uint; b : uint) : uint {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_int64(a : int64; b : int64) : int64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int64(a : int64; b : int64) : int64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint64(a : uint64; b : uint64) : uint64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint64(a : uint64; b : uint64) : uint64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_clip_uint(v : int) : uint {
    if (v < 0) {
        return 0x0
    }
    if (v > 255) {
        return 0xff
    }
    return uint(v)
}
def c2da_bool_to_uint(v : bool) : uint {
    if (v) {
        return 0x1
    } else {
        return 0x0
    }
}
def c2da___assert_fail(expr : void?; file : void?; line : uint; func : void?) {
}
struct AnonEnumInStruct {
}
struct AnonStructInStruct {
    c2da_unnamed : Unnamed
}
struct Unnamed {
    some_number : int
}
struct NestedStructInStruct {
}
struct InsideStruct {
    yup : int
}
struct AnonEnumInUnion {
    a : int
}
struct AnonStructInUnion {
    c2da_unnamed : Unnamed_0
    a : int
}
struct Unnamed_0 {
    some_number : int
}
struct NestedStructInUnion {
    a : int
}
struct InsideUnion {
    yup : int
}
[export]
def struct_declaration() {
    var value : int = int(0)
    var a : AnonEnumInStruct = AnonEnumInStruct()
    var b : AnonStructInStruct = AnonStructInStruct()
    var c : NestedStructInStruct = NestedStructInStruct()
    var d : InsideStruct = InsideStruct()
    value = VALUE2
    b.c2da_unnamed.some_number = 7
    return
}
[export]
def union_declaration() {
    var value_0 : int = int(0)
    var a_0 : AnonEnumInUnion = AnonEnumInUnion()
    var b_0 : AnonStructInUnion = AnonStructInUnion()
    var c_0 : NestedStructInUnion = NestedStructInUnion()
    var d_0 : InsideUnion = InsideUnion()
    value_0 = VALUE4
    b_0.c2da_unnamed.some_number = 99
    return
}
var VALUE2 : int = 1

var VALUE1 : int = 0

var VALUE4 : int = 1

var VALUE3 : int = 0
[export] def main() : int {
    return 0
}
