options gen2

def swap(var a : int?; var b : int?) {
    var t : int = *a
    *a = *b
    *b = t
}
def quickSort(var arr : int?; low : int; high : int) {
    if (low < high) {
        var i : int = partition(arr, low, high)
        quickSort(arr, low, i - 1)
        quickSort(arr, i + 1, high)
    }
}
