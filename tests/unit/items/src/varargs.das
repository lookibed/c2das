options gen2

struct __va_list_tag {
    gp_offset : uint
    fp_offset : uint
    overflow_arg_area : uint64
    reg_save_area : uint64
}
typedef va_list = array<__va_list_tag>
typedef size_t = uint64
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
