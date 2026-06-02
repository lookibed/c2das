options gen2

typedef int_ptr = int?
[export]
def main() : int {
    var x : int = 10
    var p : int_ptr = unsafe(addr(x))
    return *p
}
