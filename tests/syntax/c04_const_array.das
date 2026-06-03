options gen2

def sum(var arr : int const?; n : int) : int {
    unsafe {
        var s : int = 0
        var i : int = 0
        while (i < n) {
            s = s + arr[i]
            i = i + 1
        }
        return s
    }
}
[export]
def main() : int {
    unsafe {
        var a : array<int> = [0, 0, 0]
        unsafe(addr(a[0]))[0] = 1
        unsafe(addr(a[0]))[1] = 2
        unsafe(addr(a[0]))[2] = 3
        return sum(unsafe(addr(a[0])), 3)
    }
}
