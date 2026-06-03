options gen2

enum E_enum {
    E_variant1 = 1
    E_variant2 = 2
}
typedef char_to_int = function
def other_c_to_i(c : int8) : int {
    var null_var : int? = null
    return cast<int>(c)
}
var global_fn : function? = other_c_to_i

def use_enum() : E_enum {
    var x : int = E_variant1
    return cast<E_enum>(2)
}
def c_to_i(c : int8) : int {
    return cast<int>(c)
}
def modules() {
    var x : int8 = 10
    var ptr : char_to_int? = null
    var ptr2 : char_to_int? = c_to_i
    var ptr3 : char_to_int? = other_c_to_i
    ptr2(x)
}
