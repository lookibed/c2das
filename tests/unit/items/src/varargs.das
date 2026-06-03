options gen2

struct __va_list_tag {
    gp_offset : uint
    fp_offset : uint
    overflow_arg_area : void?
    reg_save_area : void?
}
typedef va_list = __builtin_va_list
struct vastruct {
    args : va_list
}
def call_printf() {
    printf(unsafe(addr("%d, %f
"[0])), 10, double(1.5))
}
def my_vprintf(var format : int8 const?; var ap : __va_list_tag?) {
    vprintf(format, ap)
}
