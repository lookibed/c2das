options gen2

enum a {
    B = 2
}
def entry6(buffer_size : uint const; var buffer : int?) {
    unsafe {
        if (buffer_size < 1) {
            return
        }
        buffer[0] = [B]
    }
}
