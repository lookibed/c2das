options gen2

struct Foo {
    i : int
    unspec : array<int8>
}
[export]
def main() : int {
    printf(unsafe(addr("%s!"[0])), unsafe(addr(f1.unspec[0])))
}
