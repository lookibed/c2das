options gen2

enum e {
    A = 0
    B = 0
    C = -10
    D = -9
}
def entry3(sz : uint const; var buffer : int?) {
    unsafe {
        buffer[0] = A
        buffer[1] = B
        buffer[2] = C
        buffer[3] = D
    }
}
