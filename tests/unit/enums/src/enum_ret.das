options gen2

enum Color : uint {
    Red = 1
    Green = 2
    Blue = 3
}
enum Color : uint {
    Purple = 1
    Yellow = 2
    Green = 3
}
def red() : Color {
    var bar : Color = Red
    return bar
}
def entry2(buffer_size : uint const; var buffer : int?) {
    unsafe {
        if (buffer_size < 5) {
            return
        }
        buffer[0] = red()
        buffer[1] = Red + 1
        var b : Color = Blue
        if (b == Blue) {
            buffer[2] = -1
        }
        enum Color : uint {
    Purple = 1
    Yellow = 2
    Green = 3
}        buffer[3] = Purple
        if (Purple == Red) {
            buffer[4] = -2
        }
        var c : Color = Red
        buffer[5] = c
        var invalid : Color = 6
        buffer[6] = invalid
    }
}
