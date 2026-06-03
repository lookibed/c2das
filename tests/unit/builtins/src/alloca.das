options gen2

var one : int = 1

def alloca_hello() : int {
    var p : int8?
    if (one) {
        p = null
    }
    strcpy(p, unsafe(addr("Hello, world!"[0])))
    puts(p)
    return 0
}
