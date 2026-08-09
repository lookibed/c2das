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
struct py_flag {
    a : int
}
[export]
def entry2(buffer_size : uint const; var buffer : int?) {
    var i : int = int(0)
    var f0 : function? = null
    var f1 : function? = null
    var p0 : uint64 = uint64(0)
    var p1 : uint64 = uint64(0)
    if (uint(buffer_size) < uint(30)) {
        return
    } else {
        i = 0
        f0 = null
        f1 = entry2
        if (f0 != null) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (f1 != null) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (f0 == null) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (f1 == null) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(double(0.0)) != uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(double(1.0)) != uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(0) != uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(1) != uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        p0 = uint64(0x0)
        p1 = unsafe(unsafe(reinterpret<uint64>(unsafe(addr(buffer_size)))))
        if (uint64(p0) != uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(p1) != uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(0) == uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(p1) != uint64(0) && 0 > -3) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(p0) == uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(p1) == uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(p0) != uint64(0) && uint64(p0) == uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(p0) != uint64(0) || uint64(p0) == uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(p1) != uint64(0) && uint64(p1) == uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        if (uint64(p1) != uint64(0) || uint64(p1) == uint64(0)) {
            i = i + 1
            unsafe(unsafe(unsafe(reinterpret<int?>(buffer)))[uint(i)]) = 1
        }
        return
    }
}
var abc : int = uint(int(c2da_fresh0)) | uint(2)

var def_0 : int = int(c2da_fresh1)

var hij : int = int(c2da_fresh2) + 2

[export]
def ternaries() {
    var i_0 : int = int(0)
    var pf : py_flag = py_flag()
    var c2da_fresh3 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh3 = 1
    } else {
        c2da_fresh3 = 2
    }
    var c2da_fresh4 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh4 = uint(int(c2da_fresh3)) | uint(1)
    } else {
        c2da_fresh4 = 1
    }
    i_0 = c2da_fresh4
    var c2da_fresh5 : int = int(0)
    if (uint64(i_0) != uint64(0)) {
        c2da_fresh5 = 1
    } else {
        c2da_fresh5 = 2
    }
    var c2da_fresh6 : int = int(0)
    if (uint64(i_0) != uint64(0)) {
        c2da_fresh6 = c2da_fresh5
    } else {
        c2da_fresh6 = 1
    }
    i_0 = c2da_fresh6
    var c2da_fresh7 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh7 = 1
    } else {
        c2da_fresh7 = 2
    }
    i_0 = c2da_fresh7
    var c2da_fresh8 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh8 = 1
    } else {
        c2da_fresh8 = 2
    }
    i_0 = uint(int(c2da_fresh8)) | uint(3)
    var c2da_fresh9 : int = int(0)
    if (uint64(1) != uint64(0)) {
        c2da_fresh9 = 1
    } else {
        c2da_fresh9 = 2
    }
    i_0 = int(c2da_fresh9) + 3
    pf = py_flag(a = 1)
    var c2da_fresh10 : int = int(0)
    if (uint64(uint(int(unsafe(addr(pf)).a)) & uint(1)) != uint64(0)) {
        c2da_fresh10 = 2
    } else {
        c2da_fresh10 = 0
    }
    var c2da_fresh11 : int = int(0)
    if (uint64(uint(int(unsafe(addr(pf)).a)) & uint(3)) != uint64(0)) {
        c2da_fresh11 = 4
    } else {
        c2da_fresh11 = 0
    }
    var c2da_fresh12 : int = int(0)
    if (uint64(uint(int(unsafe(addr(pf)).a)) & uint(5)) != uint64(0)) {
        c2da_fresh12 = 6
    } else {
        c2da_fresh12 = 0
    }
    var c2da_fresh13 : int = int(0)
    if (uint64(unsafe(addr(pf))) != uint64(0)) {
        c2da_fresh13 = int(c2da_fresh10) | int(c2da_fresh11) | int(c2da_fresh12)
    } else {
        c2da_fresh13 = 0
    }
    i_0 = c2da_fresh13
    return
}
[export] def main() : int {
    return 0
}
