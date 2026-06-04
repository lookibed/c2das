options gen2

struct __va_list_tag {
    gp_offset : uint
    fp_offset : uint
    overflow_arg_area : uint64
    reg_save_area : uint64
}
typedef va_list = array<__va_list_tag>
typedef char_to_int = function
typedef char_to_int_fp = function?
typedef va_char_to_int_fp = function?
typedef char_int_to_int_fp = function?
typedef knr = function
struct pointer_st {
    fn : function?
}
def intval(c : int8 const) : int {
    return c
}
def negintval(c : int8 const) : int {
    return -c
}
def varargs_intval(c : int8 const) : int {
    return c
}
