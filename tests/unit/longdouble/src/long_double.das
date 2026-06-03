options gen2

def cast2double(var a : double) : double {
    return cast<double>(a)
}
def cast2float(var a : double) : float {
    return cast<float>(a)
}
def cast2uint(var a : double) : uint {
    return cast<uint>(cast<float>(a))
}
var ld1 : double const = cast<double>(double(1.0))

var ld2 : double const = ld1 + cast<double>(double(2.0))

