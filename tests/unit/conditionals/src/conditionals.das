options gen2

struct py_flag {
    a : int
}
var abc : int = if (1) 1 else 2 | 2

var def : int = if (1) 1 else 2

var hij : int = if (1) 1 else 2 + 2

def ternaries() {
    var i : int = if (1) if (1) 1 else 2 | 1 else 1
    i = if (i) if (i) 1 else 2 else 1
    i = if (1) 1 else 2
    i = if (1) 1 else 2 | 3
    i = if (1) 1 else 2 + 3
    var pf : py_flag = [1]
    i = if (unsafe(addr(pf))) if (unsafe(addr(pf)).a & 1) 2 else 0 | if (unsafe(addr(pf)).a & 3) 4 else 0 | if (unsafe(addr(pf)).a & 5) 6 else 0 else 0
}
