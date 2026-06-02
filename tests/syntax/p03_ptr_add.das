options gen2

[export]
def main() : int {
    var arr : array<int>
    unsafe(addr(arr[0]))[0] = 10
    unsafe(addr(arr[0]))[1] = 20
    unsafe(addr(arr[0]))[2] = 30
    var p : int? = unsafe(addr(arr[0]))
    return p[0] + p[1] + p[2]
}
