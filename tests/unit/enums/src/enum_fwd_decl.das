options gen2

enum _Evas_Filter_Support {
}
typedef Evas_Filter_Support = _Evas_Filter_Support
struct _Evas_Func {
    gfx_filter_supports : function?
}
def foo(i : _Evas_Func) : _Evas_Func {
    return i
}
