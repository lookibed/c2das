options gen2

struct some_struct {
    buffer : array<int8>
}
typedef some_struct = some_struct
def entry3(buffer_size : uint const; var buffer : int?) {
    unsafe {
        if (buffer_size < 5) {
            return
        }
        var n : int = 0
        buffer[0] = n = 5
        n += 4
        buffer[1] = n + 2
        var p : int? = unsafe(addr(n))
        *p = 5
        buffer[2] = n
        *p += 4
        buffer[3] = *p
        var c : int8 = 10
        c *= double(9.9)
        buffer[4] = c
        var src : array<int8> = "test"
        var s : some_struct
        mutate_buffer(unsafe(addr(s.buffer[0])), unsafe(addr(src[0])), 4)
        cast<void>(unsafe(addr(s.buffer[0])))
        buffer[5] = unsafe(addr(s.buffer[0]))[0]
        buffer[6] = unsafe(addr(s.buffer[0]))[1]
        buffer[7] = unsafe(addr(s.buffer[0]))[2]
        buffer[8] = unsafe(addr(s.buffer[0]))[3]
    }
}
