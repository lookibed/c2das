options gen2

struct s {
    x : int
}
struct forward {
}
def forward(buffer_size : uint const; var buffer : int?) {
    unsafe {
        if (buffer_size < 1) {
            return
        }
        var foo : s = [1]
        buffer[0] = foo.x
        var initialized_null_ptr : forward?
    }
}
