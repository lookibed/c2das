options gen2

enum E : uint {
    A = 0
    B = 1
}
var e : E = B

def entry4(buffer_size : uint const; var buffer : int?) {
    unsafe {
        buffer[0] = e
    }
}
