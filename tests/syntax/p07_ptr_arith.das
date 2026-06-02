options gen2

[export]
def main() : int {
    var arr : array<int>
    unsafe(addr(arr[0]))[0] = 1
    unsafe(addr(arr[0]))[1] = 2
    unsafe(addr(arr[0]))[2] = 3
    var p : int? = unsafe(addr(arr[0]))
    var a : int = *p
    p = p + 1
    var b : int = *p
    p = p + 1
    var c : int = *p
    return a + b + c
}
