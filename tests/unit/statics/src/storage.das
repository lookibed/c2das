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
struct StringStruct {
    string_0 : array<int8>
}
struct StringUnion {
    string_0 : array<int8>
    data : int
}
[export]
def baz() : int {
    var k : int = 0
    counter = counter + 1
    counter
    return int(k) + 1
}
var counter : int

var visible_everywhere : int const = int(9)

var hello : int8 const? = unsafe(unsafe(reinterpret<int8 const?>(unsafe(addr("hello"[0])))))

[export]
def entry(buffer_size : uint const; var buffer : int?) {
    var world : int8 const? = unsafe(unsafe(reinterpret<int8 const?>(unsafe(addr("world"[0])))))
    var Foo : StringStruct = StringStruct(string_0 = "foo")
    var Bar : StringUnion = StringUnion(string_0 = "foo")
    if (uint(buffer_size) < uint(11)) {
        return
    } else {
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[0]) = baz()
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[1]) = baz()
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[2]) = baz() + 1
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(baz())]) = 4
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[7]) = counter
        counter = counter - 1
        counter
        baz()
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[8]) = counter
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[9]) = int(unsafe(unsafe(unsafe(reinterpret<int8 const?>(hello)))[0]))
        unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[10]) = int(unsafe(unsafe(unsafe(reinterpret<int8 const?>(world)))[1]))
        return
    }
}
[export] def main() : int {
    return 0
}
