options gen2

struct Inner {
    val : int
}
struct Outer {
    inner : Inner?
}
[export]
def main() : int {
    var i : Inner
    i.val = 42
    var o : Outer
    o.inner = unsafe(addr(i))
    return o.inner.val
}
