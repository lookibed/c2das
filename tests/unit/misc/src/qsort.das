options gen2

def c2da_min_int(a : int; b : int) : int {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int(a : int; b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint(a : uint; b : uint) : uint {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint(a : uint; b : uint) : uint {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_int64(a : int64; b : int64) : int64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int64(a : int64; b : int64) : int64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint64(a : uint64; b : uint64) : uint64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint64(a : uint64; b : uint64) : uint64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_clip_uint(v : int) : uint {
    if (v < 0) {
        return 0x0
    }
    if (v > 255) {
        return 0xff
    }
    return uint(v)
}
def c2da_bool_to_uint(v : bool) : uint {
    if (v) {
        return 0x1
    } else {
        return 0x0
    }
}
def c2da___assert_fail(expr : void?; file : void?; line : uint; func : void?) {
}
[export]
def swap(var a : int?; var b : int?) {
    var t : int = int(0)
    t = *a
    *a = *b
    *b = t
    return
}
[export]
def partition(var arr : int?; var low : int; var high : int) : int {
    var pivot : int = int(0)
    var i : int = int(0)
    pivot = unsafe(unsafe(unsafe(reinterpret<int?>(arr)))[uint(high)])
    i = int(low) - 1
    if (false) {
    }
}
[export]
def quickSort(var arr_0 : int?; var low_0 : int; var high_0 : int) {
    var i_0 : int = int(0)
    if (int(low_0) < int(high_0)) {
        i_0 = partition(arr_0, low_0, high_0)
        quickSort(arr_0, low_0, int(i_0) - 1)
        quickSort(arr_0, int(i_0) + 1, high_0)
    }
    return
}
[export] def main() : int {
    return 0
}
