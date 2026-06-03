options gen2

def foo(var a : int) {
    unsafe {
        if (a == 1) {
            var buf : array<int8> = [0, 0, 0]
            unsafe(addr(buf[0]))[0] = 97
        } elif (a == 2) {
            var buf : array<int8> = [0, 0]
            unsafe(addr(buf[0]))[0] = 97
        } else {
            var buf : array<int8> = [0]
            unsafe(addr(buf[0]))[0] = 97
        }
    }
}
