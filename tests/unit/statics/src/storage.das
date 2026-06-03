options gen2

struct StringStruct {
    string : array<int8>
}
struct StringUnion {
    string : array<int8>
    data : int
}
typedef StringUnion = StringUnion
var counter : int

var visible_everywhere : int const = 9

var hello : int8 const? = unsafe(addr("hello"[0]))

