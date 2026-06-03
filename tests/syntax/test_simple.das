options gen2

def add(a : int; b : int) : int {
    return a + b
}
[export]
def main() : int {
    var x : int = 42
    return add(x, 1)
}
