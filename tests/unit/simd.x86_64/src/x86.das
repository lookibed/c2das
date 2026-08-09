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
typedef size_t = uint64
struct c2da___mm_loadh_pi_struct {
    c2da___u : int64
}
struct c2da___mm_loadl_pi_struct {
    c2da___u : int64
}
struct c2da___mm_load_ss_struct {
    c2da___u : float
}
struct c2da___mm_load1_ps_struct {
    c2da___u : float
}
struct c2da___loadu_ps {
    c2da___v : int64
}
struct c2da___mm_storeh_pi_struct {
    c2da___u : int64
}
struct c2da___mm_store_ss_struct {
    c2da___u : float
}
struct c2da___storeu_ps {
    c2da___v : int64
}
struct c2da___mm_load1_pd_struct {
    c2da___u : double
}
struct c2da___loadu_pd {
    c2da___v : int64
}
struct c2da___loadu_si64 {
    c2da___v : int64
}
struct c2da___loadu_si32 {
    c2da___v : int
}
struct c2da___loadu_si16 {
    c2da___v : int
}
struct c2da___mm_load_sd_struct {
    c2da___u : double
}
struct c2da___mm_loadh_pd_struct {
    c2da___u : double
}
struct c2da___mm_loadl_pd_struct {
    c2da___u : double
}
struct c2da___mm_store_sd_struct {
    c2da___u : double
}
struct c2da___storeu_pd {
    c2da___v : int64
}
struct c2da___mm_storeh_pd_struct {
    c2da___u : double
}
struct c2da___loadu_si128 {
    c2da___v : int64
}
struct c2da___mm_loadl_epi64_struct {
    c2da___u : int64
}
struct c2da___storeu_si128 {
    c2da___v : int64
}
struct c2da___storeu_si64 {
    c2da___v : int64
}
struct c2da___storeu_si32 {
    c2da___v : int
}
struct c2da___storeu_si16 {
    c2da___v : int
}
struct c2da___mm_storel_epi64_struct {
    c2da___u : int64
}
struct c2da___mm_broadcast_ss_struct {
    c2da___f : float
}
struct c2da___mm256_broadcast_sd_struct {
    c2da___d : double
}
struct c2da___mm256_broadcast_ss_struct {
    c2da___f : float
}
struct c2da___loadu_si256 {
    c2da___v : int64
}
struct c2da___storeu_si256 {
    c2da___v : int64
}
struct c2da___loadu_si512 {
    c2da___v : int64
}
struct c2da___loadu_epi32 {
    c2da___v : int64
}
struct c2da___loadu_epi64 {
    c2da___v : int64
}
struct c2da___storeu_epi64 {
    c2da___v : int64
}
struct c2da___storeu_si512 {
    c2da___v : int64
}
struct c2da___storeu_epi32 {
    c2da___v : int64
}
struct c2da___loadu_epi16 {
    c2da___v : int64
}
struct c2da___loadu_epi8 {
    c2da___v : int64
}
struct c2da___storeu_epi16 {
    c2da___v : int64
}
struct c2da___storeu_epi8 {
    c2da___v : int64
}
struct c2da___mm_load_sh_struct {
    c2da___u : int64
}
struct c2da___loadu_ph {
    c2da___v : int64
}
struct c2da___mm_store_sh_struct {
    c2da___u : int64
}
struct c2da___storeu_ph {
    c2da___v : int64
}
struct c2da___loadu_i16 {
    c2da___v : int
}
struct c2da___storeu_i16 {
    c2da___v : int
}
struct c2da___loadu_i32 {
    c2da___v : uint
}
struct c2da___storeu_i32 {
    c2da___v : uint
}
struct c2da___loadu_i64 {
    c2da___v : uint64
}
struct c2da___storeu_i64 {
    c2da___v : uint64
}
typedef _tile1024i = auto
struct c2da___tile1024i_str {
    row : int const
    col : int const
    tile : _tile1024i
}
struct ShuffleVectors {
    b : auto
    c : auto
    d : auto
    e : auto
    ep : auto
    f : auto
    g : auto
    h : auto
    o : auto
    m : auto
    r : auto
}
struct VectorInitLists {
    a : auto
    b : auto
    c : auto
    d : auto
    e : auto
    f : auto
}
[export]
def _mm_cvtsi64_m64(var c2da___i_0 : int64) : auto {
    return unsafe(reinterpret<auto>(c2da___i_0))
}
[export]
def _mm_cvtm64_si64(var c2da___m_0 : auto) : int64 {
    return unsafe(reinterpret<int64>(c2da___m_0))
}
[export]
def _mm_setzero_si64() : auto {
    return [0]
}
[export]
def _mm_set1_pi32(var c2da___i_1 : int) : auto {
    return _mm_set_pi32(c2da___i_1, c2da___i_1)
}
[export]
def _mm_set1_pi16(var c2da___w : int) : auto {
    return _mm_set_pi16(c2da___w, c2da___w, c2da___w, c2da___w)
}
[export]
def _mm_set1_pi8(var c2da___b : int8) : auto {
    return _mm_set_pi8(c2da___b, c2da___b, c2da___b, c2da___b, c2da___b, c2da___b, c2da___b, c2da___b)
}
[export]
def _mm_setr_pi32(var c2da___i0_0 : int; var c2da___i1_0 : int) : auto {
    return _mm_set_pi32(c2da___i1_0, c2da___i0_0)
}
[export]
def _mm_setr_pi16(var c2da___w0 : int; var c2da___w1 : int; var c2da___w2 : int; var c2da___w3 : int) : auto {
    return _mm_set_pi16(c2da___w3, c2da___w2, c2da___w1, c2da___w0)
}
[export]
def _mm_setr_pi8(var c2da___b0_0 : int8; var c2da___b1_0 : int8; var c2da___b2_0 : int8; var c2da___b3_0 : int8; var c2da___b4_0 : int8; var c2da___b5_0 : int8; var c2da___b6_0 : int8; var c2da___b7_0 : int8) : auto {
    return _mm_set_pi8(c2da___b7_0, c2da___b6_0, c2da___b5_0, c2da___b4_0, c2da___b3_0, c2da___b2_0, c2da___b1_0, c2da___b0_0)
}
[export]
def c2da___bswap_16(var c2da___bsx : uint16) : uint16 {
    return uint16(uint(uint(int(c2da___bsx)) >> uint(8)) & uint(255) | uint(int(uint(int(c2da___bsx)) & uint(255) << uint(8))))
}
[export]
def c2da___bswap_32(var c2da___bsx_0 : uint) : uint {
    return uint(uint(uint(c2da___bsx_0)) & uint(0xff000000)) >> uint(uint(24)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff0000)) >> uint(uint(8)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff00)) << uint(uint(8)) | uint(uint(uint(c2da___bsx_0)) & uint(0xff)) << uint(uint(24))
}
[export]
def c2da___bswap_64(var c2da___bsx_1 : uint64) : uint64 {
    return uint64(uint64(c2da___bsx_1) & uint64(0xff00000000000000uL)) >> uint64(uint64(56)) | uint64(uint64(c2da___bsx_1) & uint64(0xff000000000000uL)) >> uint64(uint64(40)) | uint64(uint64(c2da___bsx_1) & uint64(0xff0000000000uL)) >> uint64(uint64(24)) | uint64(uint64(c2da___bsx_1) & uint64(0xff00000000uL)) >> uint64(uint64(8)) | uint64(uint64(c2da___bsx_1) & uint64(0xff000000)) << uint64(uint64(8)) | uint64(uint64(c2da___bsx_1) & uint64(0xff0000)) << uint64(uint64(24)) | uint64(uint64(c2da___bsx_1) & uint64(0xff00)) << uint64(uint64(40)) | uint64(uint64(c2da___bsx_1) & uint64(0xff)) << uint64(uint64(56))
}
[export]
def c2da___uint16_identity(var c2da___x : uint16) : uint16 {
    return c2da___x
}
[export]
def c2da___uint32_identity(var c2da___x_0 : uint) : uint {
    return c2da___x_0
}
[export]
def c2da___uint64_identity(var c2da___x_1 : uint64) : uint64 {
    return c2da___x_1
}
[export]
def _mm_malloc(var c2da___size : size_t; var c2da___align : size_t) : uint64 {
    var c2da___mallocedMemory : uint64 = uint64(0)
    if (unsafe(reinterpret<size_t>(c2da___align)) == unsafe(reinterpret<size_t>(1))) {
        return unsafe(unsafe(reinterpret<uint64>(unsafe(malloc(c2da___size)))))
    } else {
        if (uint64(unsafe(reinterpret<size_t>(c2da___align)) & unsafe(reinterpret<size_t>(c2da___align)) - unsafe(reinterpret<size_t>(1))) == uint64(0) && unsafe(reinterpret<size_t>(c2da___align)) < unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4)))) {
            c2da___align = unsafe(reinterpret<size_t>(4))
        }
        if (uint64(posix_memalign(unsafe(addr(c2da___mallocedMemory)), c2da___align, c2da___size)) != uint64(0)) {
            return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
        } else {
            return unsafe(unsafe(reinterpret<uint64>(c2da___mallocedMemory)))
        }
    }
}
[export]
def _mm_free(var c2da___p : uint64) {
    unsafe(free(c2da___p))
    return
}
[export]
def _mm_add_ss(var c2da___a : auto; var c2da___b_0 : auto) : auto {
    unsafe(c2da___a[0]) = unsafe(c2da___a[0]) + unsafe(c2da___b_0[0])
    return c2da___a
}
[export]
def _mm_add_ps(var c2da___a_0 : auto; var c2da___b_1 : auto) : auto {
    return c2da___a_0 + c2da___b_1
}
[export]
def _mm_sub_ss(var c2da___a_1 : auto; var c2da___b_2 : auto) : auto {
    unsafe(c2da___a_1[0]) = unsafe(c2da___a_1[0]) - unsafe(c2da___b_2[0])
    return c2da___a_1
}
[export]
def _mm_sub_ps(var c2da___a_2 : auto; var c2da___b_3 : auto) : auto {
    return c2da___a_2 - c2da___b_3
}
[export]
def _mm_mul_ss(var c2da___a_3 : auto; var c2da___b_4 : auto) : auto {
    unsafe(c2da___a_3[0]) = unsafe(c2da___a_3[0]) * unsafe(c2da___b_4[0])
    return c2da___a_3
}
[export]
def _mm_mul_ps(var c2da___a_4 : auto; var c2da___b_5 : auto) : auto {
    return c2da___a_4 * c2da___b_5
}
[export]
def _mm_div_ss(var c2da___a_5 : auto; var c2da___b_6 : auto) : auto {
    unsafe(c2da___a_5[0]) = unsafe(c2da___a_5[0]) / unsafe(c2da___b_6[0])
    return c2da___a_5
}
[export]
def _mm_div_ps(var c2da___a_6 : auto; var c2da___b_7 : auto) : auto {
    return c2da___a_6 / c2da___b_7
}
[export]
def _mm_and_ps(var c2da___a_17 : auto; var c2da___b_12 : auto) : auto {
    return c2da___a_17 & c2da___b_12
}
[export]
def _mm_andnot_ps(var c2da___a_18 : auto; var c2da___b_13 : auto) : auto {
    return ~c2da___a_18 & c2da___b_13
}
[export]
def _mm_or_ps(var c2da___a_19 : auto; var c2da___b_14 : auto) : auto {
    return c2da___a_19 | c2da___b_14
}
[export]
def _mm_xor_ps(var c2da___a_20 : auto; var c2da___b_15 : auto) : auto {
    return c2da___a_20 ^ c2da___b_15
}
[export]
def _mm_cvt_ss2si(var c2da___a_58 : auto) : int {
    return _mm_cvtss_si32(c2da___a_58)
}
[export]
def _mm_cvt_ps2pi(var c2da___a_61 : auto) : auto {
    return _mm_cvtps_pi32(c2da___a_61)
}
[export]
def _mm_cvtt_ss2si(var c2da___a_63 : auto) : int {
    return _mm_cvttss_si32(c2da___a_63)
}
[export]
def _mm_cvtt_ps2pi(var c2da___a_66 : auto) : auto {
    return _mm_cvttps_pi32(c2da___a_66)
}
[export]
def _mm_cvtsi32_ss(var c2da___a_67 : auto; var c2da___b_52 : int) : auto {
    unsafe(c2da___a_67[0]) = float(c2da___b_52)
    return c2da___a_67
}
[export]
def _mm_cvt_si2ss(var c2da___a_68 : auto; var c2da___b_53 : int) : auto {
    return _mm_cvtsi32_ss(c2da___a_68, c2da___b_53)
}
[export]
def _mm_cvtsi64_ss(var c2da___a_69 : auto; var c2da___b_54 : int64) : auto {
    unsafe(c2da___a_69[0]) = float(c2da___b_54)
    return c2da___a_69
}
[export]
def _mm_cvt_pi2ps(var c2da___a_71 : auto; var c2da___b_56 : auto) : auto {
    return _mm_cvtpi32_ps(c2da___a_71, c2da___b_56)
}
[export]
def _mm_cvtss_f32(var c2da___a_72 : auto) : float {
    return unsafe(c2da___a_72[0])
}
[export]
def _mm_load_ss(var c2da___p_2 : float const?) : auto {
    var c2da___u : float = float(0)
    c2da___u = c2da___p_2.c2da___u
    return [c2da___u, float(0), float(0), float(0)]
}
[export]
def _mm_load1_ps(var c2da___p_3 : float const?) : auto {
    var c2da___u_0 : float = float(0)
    c2da___u_0 = c2da___p_3.c2da___u
    return [c2da___u_0, c2da___u_0, c2da___u_0, c2da___u_0]
}
[export]
def _mm_load_ps(var c2da___p_4 : float const?) : auto {
    return *c2da___p_4
}
[export]
def _mm_loadu_ps(var c2da___p_5 : float const?) : auto {
    return c2da___p_5.c2da___v
}
[export]
def _mm_set_ss(var c2da___w_0 : float) : auto {
    return [c2da___w_0, float(0), float(0), float(0)]
}
[export]
def _mm_set1_ps(var c2da___w_1 : float) : auto {
    return [c2da___w_1, c2da___w_1, c2da___w_1, c2da___w_1]
}
[export]
def _mm_set_ps1(var c2da___w_2 : float) : auto {
    return _mm_set1_ps(c2da___w_2)
}
[export]
def _mm_set_ps(var c2da___z : float; var c2da___y : float; var c2da___x_2 : float; var c2da___w_3 : float) : auto {
    return [c2da___w_3, c2da___x_2, c2da___y, c2da___z]
}
[export]
def _mm_setr_ps(var c2da___z_0 : float; var c2da___y_0 : float; var c2da___x_3 : float; var c2da___w_4 : float) : auto {
    return [c2da___z_0, c2da___y_0, c2da___x_3, c2da___w_4]
}
[export]
def _mm_setzero_ps() : auto {
    return [double(0.0), double(0.0), double(0.0), double(0.0)]
}
[export]
def _mm_store_ss(var c2da___p_9 : float?; var c2da___a_78 : auto) {
    c2da___p_9.c2da___u = unsafe(c2da___a_78[0])
    return
}
[export]
def _mm_storeu_ps(var c2da___p_10 : float?; var c2da___a_79 : auto) {
    c2da___p_10.c2da___v = c2da___a_79
    return
}
[export]
def _mm_store_ps(var c2da___p_11 : float?; var c2da___a_80 : auto) {
    *c2da___p_11 = c2da___a_80
    return
}
[export]
def _mm_store_ps1(var c2da___p_13 : float?; var c2da___a_82 : auto) {
    _mm_store1_ps(c2da___p_13, c2da___a_82)
    return
}
[export]
def _mm_move_ss(var c2da___a_97 : auto; var c2da___b_69 : auto) : auto {
    unsafe(c2da___a_97[0]) = unsafe(c2da___b_69[0])
    return c2da___a_97
}
[export]
def _mm_cvtpi16_ps(var c2da___a_100 : auto) : auto {
    var c2da___b_72 : auto = cast<auto>(0)
    var c2da___c : auto = cast<auto>(0)
    var c2da___r : auto = cast<auto>(0)
    c2da___b_72 = _mm_setzero_si64()
    c2da___b_72 = _mm_cmpgt_pi16(c2da___b_72, c2da___a_100)
    c2da___c = _mm_unpackhi_pi16(c2da___a_100, c2da___b_72)
    c2da___r = _mm_setzero_ps()
    c2da___r = _mm_cvtpi32_ps(c2da___r, c2da___c)
    c2da___r = _mm_movelh_ps(c2da___r, c2da___r)
    c2da___c = _mm_unpacklo_pi16(c2da___a_100, c2da___b_72)
    c2da___r = _mm_cvtpi32_ps(c2da___r, c2da___c)
    return c2da___r
}
[export]
def _mm_cvtpu16_ps(var c2da___a_101 : auto) : auto {
    var c2da___b_73 : auto = cast<auto>(0)
    var c2da___c_0 : auto = cast<auto>(0)
    var c2da___r_0 : auto = cast<auto>(0)
    c2da___b_73 = _mm_setzero_si64()
    c2da___c_0 = _mm_unpackhi_pi16(c2da___a_101, c2da___b_73)
    c2da___r_0 = _mm_setzero_ps()
    c2da___r_0 = _mm_cvtpi32_ps(c2da___r_0, c2da___c_0)
    c2da___r_0 = _mm_movelh_ps(c2da___r_0, c2da___r_0)
    c2da___c_0 = _mm_unpacklo_pi16(c2da___a_101, c2da___b_73)
    c2da___r_0 = _mm_cvtpi32_ps(c2da___r_0, c2da___c_0)
    return c2da___r_0
}
[export]
def _mm_cvtpi8_ps(var c2da___a_102 : auto) : auto {
    var c2da___b_74 : auto = cast<auto>(0)
    c2da___b_74 = _mm_setzero_si64()
    c2da___b_74 = _mm_cmpgt_pi8(c2da___b_74, c2da___a_102)
    c2da___b_74 = _mm_unpacklo_pi8(c2da___a_102, c2da___b_74)
    return _mm_cvtpi16_ps(c2da___b_74)
}
[export]
def _mm_cvtpu8_ps(var c2da___a_103 : auto) : auto {
    var c2da___b_75 : auto = cast<auto>(0)
    c2da___b_75 = _mm_setzero_si64()
    c2da___b_75 = _mm_unpacklo_pi8(c2da___a_103, c2da___b_75)
    return _mm_cvtpi16_ps(c2da___b_75)
}
[export]
def _mm_cvtpi32x2_ps(var c2da___a_104 : auto; var c2da___b_76 : auto) : auto {
    var c2da___c_1 : auto = cast<auto>(0)
    c2da___c_1 = _mm_setzero_ps()
    c2da___c_1 = _mm_cvtpi32_ps(c2da___c_1, c2da___b_76)
    c2da___c_1 = _mm_movelh_ps(c2da___c_1, c2da___c_1)
    return _mm_cvtpi32_ps(c2da___c_1, c2da___a_104)
}
[export]
def _mm_cvtps_pi16(var c2da___a_105 : auto) : auto {
    var c2da___b_77 : auto = cast<auto>(0)
    var c2da___c_2 : auto = cast<auto>(0)
    c2da___b_77 = _mm_cvtps_pi32(c2da___a_105)
    c2da___a_105 = _mm_movehl_ps(c2da___a_105, c2da___a_105)
    c2da___c_2 = _mm_cvtps_pi32(c2da___a_105)
    return _mm_packs_pi32(c2da___b_77, c2da___c_2)
}
[export]
def _mm_cvtps_pi8(var c2da___a_106 : auto) : auto {
    var c2da___b_78 : auto = cast<auto>(0)
    var c2da___c_3 : auto = cast<auto>(0)
    c2da___b_78 = _mm_cvtps_pi16(c2da___a_106)
    c2da___c_3 = _mm_setzero_si64()
    return _mm_packs_pi16(c2da___b_78, c2da___c_3)
}
[export]
def _mm_add_sd(var c2da___a_108 : auto; var c2da___b_79 : auto) : auto {
    unsafe(c2da___a_108[0]) = unsafe(c2da___a_108[0]) + unsafe(c2da___b_79[0])
    return c2da___a_108
}
[export]
def _mm_add_pd(var c2da___a_109 : auto; var c2da___b_80 : auto) : auto {
    return c2da___a_109 + c2da___b_80
}
[export]
def _mm_sub_sd(var c2da___a_110 : auto; var c2da___b_81 : auto) : auto {
    unsafe(c2da___a_110[0]) = unsafe(c2da___a_110[0]) - unsafe(c2da___b_81[0])
    return c2da___a_110
}
[export]
def _mm_sub_pd(var c2da___a_111 : auto; var c2da___b_82 : auto) : auto {
    return c2da___a_111 - c2da___b_82
}
[export]
def _mm_mul_sd(var c2da___a_112 : auto; var c2da___b_83 : auto) : auto {
    unsafe(c2da___a_112[0]) = unsafe(c2da___a_112[0]) * unsafe(c2da___b_83[0])
    return c2da___a_112
}
[export]
def _mm_mul_pd(var c2da___a_113 : auto; var c2da___b_84 : auto) : auto {
    return c2da___a_113 * c2da___b_84
}
[export]
def _mm_div_sd(var c2da___a_114 : auto; var c2da___b_85 : auto) : auto {
    unsafe(c2da___a_114[0]) = unsafe(c2da___a_114[0]) / unsafe(c2da___b_85[0])
    return c2da___a_114
}
[export]
def _mm_div_pd(var c2da___a_115 : auto; var c2da___b_86 : auto) : auto {
    return c2da___a_115 / c2da___b_86
}
[export]
def _mm_and_pd(var c2da___a_122 : auto; var c2da___b_92 : auto) : auto {
    return c2da___a_122 & c2da___b_92
}
[export]
def _mm_andnot_pd(var c2da___a_123 : auto; var c2da___b_93 : auto) : auto {
    return ~c2da___a_123 & c2da___b_93
}
[export]
def _mm_or_pd(var c2da___a_124 : auto; var c2da___b_94 : auto) : auto {
    return c2da___a_124 | c2da___b_94
}
[export]
def _mm_xor_pd(var c2da___a_125 : auto; var c2da___b_95 : auto) : auto {
    return c2da___a_125 ^ c2da___b_95
}
[export]
def _mm_cvtsi32_sd(var c2da___a_168 : auto; var c2da___b_133 : int) : auto {
    unsafe(c2da___a_168[0]) = double(c2da___b_133)
    return c2da___a_168
}
[export]
def _mm_cvtss_sd(var c2da___a_169 : auto; var c2da___b_134 : auto) : auto {
    unsafe(c2da___a_169[0]) = double(unsafe(c2da___b_134[0]))
    return c2da___a_169
}
[export]
def _mm_cvtsd_f64(var c2da___a_175 : auto) : double {
    return unsafe(c2da___a_175[0])
}
[export]
def _mm_load_pd(var c2da___dp : double const?) : auto {
    return *c2da___dp
}
[export]
def _mm_load1_pd(var c2da___dp_0 : double const?) : auto {
    var c2da___u_1 : double = double(0)
    c2da___u_1 = c2da___dp_0.c2da___u
    return [c2da___u_1, c2da___u_1]
}
[export]
def _mm_loadu_pd(var c2da___dp_2 : double const?) : auto {
    return c2da___dp_2.c2da___v
}
[export]
def _mm_loadu_si64(var c2da___a_176 : uint64) : auto {
    var c2da___u_3 : int64 = int64(0)
    c2da___u_3 = c2da___a_176.c2da___v
    return [c2da___u_3, 0]
}
[export]
def _mm_loadu_si32(var c2da___a_177 : uint64) : auto {
    var c2da___u_4 : int = int(0)
    c2da___u_4 = c2da___a_177.c2da___v
    return [c2da___u_4, 0, 0, 0]
}
[export]
def _mm_loadu_si16(var c2da___a_178 : uint64) : auto {
    var c2da___u_5 : int = int(0)
    c2da___u_5 = c2da___a_178.c2da___v
    return [c2da___u_5, 0, 0, 0, 0, 0, 0, 0]
}
[export]
def _mm_load_sd(var c2da___dp_3 : double const?) : auto {
    var c2da___u_6 : double = double(0)
    c2da___u_6 = c2da___dp_3.c2da___u
    return [c2da___u_6, double(0)]
}
[export]
def _mm_loadh_pd(var c2da___a_179 : auto; var c2da___dp_4 : double const?) : auto {
    var c2da___u_7 : double = double(0)
    c2da___u_7 = c2da___dp_4.c2da___u
    return [unsafe(c2da___a_179[0]), c2da___u_7]
}
[export]
def _mm_loadl_pd(var c2da___a_180 : auto; var c2da___dp_5 : double const?) : auto {
    var c2da___u_8 : double = double(0)
    c2da___u_8 = c2da___dp_5.c2da___u
    return [c2da___u_8, unsafe(c2da___a_180[1])]
}
[export]
def _mm_set_sd(var c2da___w_5 : double) : auto {
    return [c2da___w_5, double(0)]
}
[export]
def _mm_set1_pd(var c2da___w_6 : double) : auto {
    return [c2da___w_6, c2da___w_6]
}
[export]
def _mm_set_pd1(var c2da___w_7 : double) : auto {
    return _mm_set1_pd(c2da___w_7)
}
[export]
def _mm_set_pd(var c2da___w_8 : double; var c2da___x_4 : double) : auto {
    return [c2da___x_4, c2da___w_8]
}
[export]
def _mm_setr_pd(var c2da___w_9 : double; var c2da___x_5 : double) : auto {
    return [c2da___w_9, c2da___x_5]
}
[export]
def _mm_setzero_pd() : auto {
    return [double(0.0), double(0.0)]
}
[export]
def _mm_move_sd(var c2da___a_181 : auto; var c2da___b_135 : auto) : auto {
    unsafe(c2da___a_181[0]) = unsafe(c2da___b_135[0])
    return c2da___a_181
}
[export]
def _mm_store_sd(var c2da___dp_6 : double?; var c2da___a_182 : auto) {
    c2da___dp_6.c2da___u = unsafe(c2da___a_182[0])
    return
}
[export]
def _mm_store_pd(var c2da___dp_7 : double?; var c2da___a_183 : auto) {
    *c2da___dp_7 = c2da___a_183
    return
}
[export]
def _mm_store_pd1(var c2da___dp_9 : double?; var c2da___a_185 : auto) {
    _mm_store1_pd(c2da___dp_9, c2da___a_185)
    return
}
[export]
def _mm_storeu_pd(var c2da___dp_10 : double?; var c2da___a_186 : auto) {
    c2da___dp_10.c2da___v = c2da___a_186
    return
}
[export]
def _mm_storeh_pd(var c2da___dp_12 : double?; var c2da___a_188 : auto) {
    c2da___dp_12.c2da___u = unsafe(c2da___a_188[1])
    return
}
[export]
def _mm_storel_pd(var c2da___dp_13 : double?; var c2da___a_189 : auto) {
    c2da___dp_13.c2da___u = unsafe(c2da___a_189[0])
    return
}
[export]
def _mm_add_epi8(var c2da___a_190 : auto; var c2da___b_136 : auto) : auto {
    return c2da___a_190 + c2da___b_136
}
[export]
def _mm_add_epi16(var c2da___a_191 : auto; var c2da___b_137 : auto) : auto {
    return c2da___a_191 + c2da___b_137
}
[export]
def _mm_add_epi32(var c2da___a_192 : auto; var c2da___b_138 : auto) : auto {
    return c2da___a_192 + c2da___b_138
}
[export]
def _mm_add_epi64(var c2da___a_194 : auto; var c2da___b_140 : auto) : auto {
    return c2da___a_194 + c2da___b_140
}
[export]
def _mm_mullo_epi16(var c2da___a_208 : auto; var c2da___b_154 : auto) : auto {
    return c2da___a_208 * c2da___b_154
}
[export]
def _mm_sub_epi8(var c2da___a_212 : auto; var c2da___b_158 : auto) : auto {
    return c2da___a_212 - c2da___b_158
}
[export]
def _mm_sub_epi16(var c2da___a_213 : auto; var c2da___b_159 : auto) : auto {
    return c2da___a_213 - c2da___b_159
}
[export]
def _mm_sub_epi32(var c2da___a_214 : auto; var c2da___b_160 : auto) : auto {
    return c2da___a_214 - c2da___b_160
}
[export]
def _mm_sub_epi64(var c2da___a_216 : auto; var c2da___b_162 : auto) : auto {
    return c2da___a_216 - c2da___b_162
}
[export]
def _mm_and_si128(var c2da___a_221 : auto; var c2da___b_167 : auto) : auto {
    return c2da___a_221 & c2da___b_167
}
[export]
def _mm_andnot_si128(var c2da___a_222 : auto; var c2da___b_168 : auto) : auto {
    return ~c2da___a_222 & c2da___b_168
}
[export]
def _mm_or_si128(var c2da___a_223 : auto; var c2da___b_169 : auto) : auto {
    return c2da___a_223 | c2da___b_169
}
[export]
def _mm_xor_si128(var c2da___a_224 : auto; var c2da___b_170 : auto) : auto {
    return c2da___a_224 ^ c2da___b_170
}
[export]
def _mm_cmpeq_epi8(var c2da___a_241 : auto; var c2da___b_171 : auto) : auto {
    return c2da___a_241 == c2da___b_171
}
[export]
def _mm_cmpeq_epi16(var c2da___a_242 : auto; var c2da___b_172 : auto) : auto {
    return c2da___a_242 == c2da___b_172
}
[export]
def _mm_cmpeq_epi32(var c2da___a_243 : auto; var c2da___b_173 : auto) : auto {
    return c2da___a_243 == c2da___b_173
}
[export]
def _mm_cmpgt_epi8(var c2da___a_244 : auto; var c2da___b_174 : auto) : auto {
    return c2da___a_244 > c2da___b_174
}
[export]
def _mm_cmpgt_epi16(var c2da___a_245 : auto; var c2da___b_175 : auto) : auto {
    return c2da___a_245 > c2da___b_175
}
[export]
def _mm_cmpgt_epi32(var c2da___a_246 : auto; var c2da___b_176 : auto) : auto {
    return c2da___a_246 > c2da___b_176
}
[export]
def _mm_cmplt_epi8(var c2da___a_247 : auto; var c2da___b_177 : auto) : auto {
    return _mm_cmpgt_epi8(c2da___b_177, c2da___a_247)
}
[export]
def _mm_cmplt_epi16(var c2da___a_248 : auto; var c2da___b_178 : auto) : auto {
    return _mm_cmpgt_epi16(c2da___b_178, c2da___a_248)
}
[export]
def _mm_cmplt_epi32(var c2da___a_249 : auto; var c2da___b_179 : auto) : auto {
    return _mm_cmpgt_epi32(c2da___b_179, c2da___a_249)
}
[export]
def _mm_cvtsi64_sd(var c2da___a_250 : auto; var c2da___b_180 : int64) : auto {
    unsafe(c2da___a_250[0]) = double(c2da___b_180)
    return c2da___a_250
}
[export]
def _mm_cvtsi32_si128(var c2da___a_256 : int) : auto {
    return [c2da___a_256, 0, 0, 0]
}
[export]
def _mm_cvtsi64_si128(var c2da___a_257 : int64) : auto {
    return [c2da___a_257, int64(0)]
}
[export]
def _mm_cvtsi128_si32(var c2da___a_258 : auto) : int {
    var c2da___b_181 : auto = cast<auto>(0)
    c2da___b_181 = c2da___a_258
    return unsafe(c2da___b_181[0])
}
[export]
def _mm_cvtsi128_si64(var c2da___a_259 : auto) : int64 {
    return unsafe(c2da___a_259[0])
}
[export]
def _mm_load_si128(var c2da___p_18 : auto const?) : auto {
    return *c2da___p_18
}
[export]
def _mm_loadu_si128(var c2da___p_19 : auto const?) : auto {
    return c2da___p_19.c2da___v
}
[export]
def _mm_loadl_epi64(var c2da___p_20 : auto const?) : auto {
    return [c2da___p_20.c2da___u, int64(0)]
}
[export]
def _mm_set_epi64x(var c2da___q1 : int64; var c2da___q0 : int64) : auto {
    return [c2da___q0, c2da___q1]
}
[export]
def _mm_set_epi64(var c2da___q1_0 : auto; var c2da___q0_0 : auto) : auto {
    return _mm_set_epi64x(unsafe(reinterpret<int64>(c2da___q1_0)), unsafe(reinterpret<int64>(c2da___q0_0)))
}
[export]
def _mm_set_epi32(var c2da___i3 : int; var c2da___i2 : int; var c2da___i1_1 : int; var c2da___i0_1 : int) : auto {
    return [c2da___i0_1, c2da___i1_1, c2da___i2, c2da___i3]
}
[export]
def _mm_set_epi16(var c2da___w7 : int; var c2da___w6 : int; var c2da___w5 : int; var c2da___w4 : int; var c2da___w3_0 : int; var c2da___w2_0 : int; var c2da___w1_0 : int; var c2da___w0_0 : int) : auto {
    return [c2da___w0_0, c2da___w1_0, c2da___w2_0, c2da___w3_0, c2da___w4, c2da___w5, c2da___w6, c2da___w7]
}
[export]
def _mm_set_epi8(var c2da___b15 : int8; var c2da___b14 : int8; var c2da___b13 : int8; var c2da___b12 : int8; var c2da___b11 : int8; var c2da___b10 : int8; var c2da___b9 : int8; var c2da___b8 : int8; var c2da___b7_1 : int8; var c2da___b6_1 : int8; var c2da___b5_1 : int8; var c2da___b4_1 : int8; var c2da___b3_1 : int8; var c2da___b2_1 : int8; var c2da___b1_1 : int8; var c2da___b0_1 : int8) : auto {
    return [c2da___b0_1, c2da___b1_1, c2da___b2_1, c2da___b3_1, c2da___b4_1, c2da___b5_1, c2da___b6_1, c2da___b7_1, c2da___b8, c2da___b9, c2da___b10, c2da___b11, c2da___b12, c2da___b13, c2da___b14, c2da___b15]
}
[export]
def _mm_set1_epi64x(var c2da___q : int64) : auto {
    return _mm_set_epi64x(c2da___q, c2da___q)
}
[export]
def _mm_set1_epi64(var c2da___q_0 : auto) : auto {
    return _mm_set_epi64(c2da___q_0, c2da___q_0)
}
[export]
def _mm_set1_epi32(var c2da___i_2 : int) : auto {
    return _mm_set_epi32(c2da___i_2, c2da___i_2, c2da___i_2, c2da___i_2)
}
[export]
def _mm_set1_epi16(var c2da___w_10 : int) : auto {
    return _mm_set_epi16(c2da___w_10, c2da___w_10, c2da___w_10, c2da___w_10, c2da___w_10, c2da___w_10, c2da___w_10, c2da___w_10)
}
[export]
def _mm_set1_epi8(var c2da___b_182 : int8) : auto {
    return _mm_set_epi8(c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182, c2da___b_182)
}
[export]
def _mm_setr_epi64(var c2da___q0_1 : auto; var c2da___q1_1 : auto) : auto {
    return _mm_set_epi64(c2da___q1_1, c2da___q0_1)
}
[export]
def _mm_setr_epi32(var c2da___i0_2 : int; var c2da___i1_2 : int; var c2da___i2_0 : int; var c2da___i3_0 : int) : auto {
    return _mm_set_epi32(c2da___i3_0, c2da___i2_0, c2da___i1_2, c2da___i0_2)
}
[export]
def _mm_setr_epi16(var c2da___w0_1 : int; var c2da___w1_1 : int; var c2da___w2_1 : int; var c2da___w3_1 : int; var c2da___w4_0 : int; var c2da___w5_0 : int; var c2da___w6_0 : int; var c2da___w7_0 : int) : auto {
    return _mm_set_epi16(c2da___w7_0, c2da___w6_0, c2da___w5_0, c2da___w4_0, c2da___w3_1, c2da___w2_1, c2da___w1_1, c2da___w0_1)
}
[export]
def _mm_setr_epi8(var c2da___b0_2 : int8; var c2da___b1_2 : int8; var c2da___b2_2 : int8; var c2da___b3_2 : int8; var c2da___b4_2 : int8; var c2da___b5_2 : int8; var c2da___b6_2 : int8; var c2da___b7_2 : int8; var c2da___b8_0 : int8; var c2da___b9_0 : int8; var c2da___b10_0 : int8; var c2da___b11_0 : int8; var c2da___b12_0 : int8; var c2da___b13_0 : int8; var c2da___b14_0 : int8; var c2da___b15_0 : int8) : auto {
    return _mm_set_epi8(c2da___b15_0, c2da___b14_0, c2da___b13_0, c2da___b12_0, c2da___b11_0, c2da___b10_0, c2da___b9_0, c2da___b8_0, c2da___b7_2, c2da___b6_2, c2da___b5_2, c2da___b4_2, c2da___b3_2, c2da___b2_2, c2da___b1_2, c2da___b0_2)
}
[export]
def _mm_setzero_si128() : auto {
    return [0, 0]
}
[export]
def _mm_store_si128(var c2da___p_21 : auto?; var c2da___b_183 : auto) {
    *c2da___p_21 = c2da___b_183
    return
}
[export]
def _mm_storeu_si128(var c2da___p_22 : auto?; var c2da___b_184 : auto) {
    c2da___p_22.c2da___v = c2da___b_184
    return
}
[export]
def _mm_storeu_si64(var c2da___p_23 : uint64; var c2da___b_185 : auto) {
    c2da___p_23.c2da___v = int64(unsafe(c2da___b_185[0]))
    return
}
[export]
def _mm_storeu_si32(var c2da___p_24 : uint64; var c2da___b_186 : auto) {
    c2da___p_24.c2da___v = unsafe(c2da___b_186[0])
    return
}
[export]
def _mm_storeu_si16(var c2da___p_25 : uint64; var c2da___b_187 : auto) {
    c2da___p_25.c2da___v = unsafe(c2da___b_187[0])
    return
}
[export]
def _mm_storel_epi64(var c2da___p_27 : auto?; var c2da___a_260 : auto) {
    c2da___p_27.c2da___u = int64(unsafe(c2da___a_260[0]))
    return
}
[export]
def _mm_movepi64_pi64(var c2da___a_277 : auto) : auto {
    return unsafe(reinterpret<auto>(unsafe(c2da___a_277[0])))
}
[export]
def _mm_movpi64_epi64(var c2da___a_278 : auto) : auto {
    return [unsafe(reinterpret<int64>(c2da___a_278)), int64(0)]
}
[export]
def _mm_castpd_ps(var c2da___a_283 : auto) : auto {
    return c2da___a_283
}
[export]
def _mm_castpd_si128(var c2da___a_284 : auto) : auto {
    return c2da___a_284
}
[export]
def _mm_castps_pd(var c2da___a_285 : auto) : auto {
    return c2da___a_285
}
[export]
def _mm_castps_si128(var c2da___a_286 : auto) : auto {
    return c2da___a_286
}
[export]
def _mm_castsi128_ps(var c2da___a_287 : auto) : auto {
    return c2da___a_287
}
[export]
def _mm_castsi128_pd(var c2da___a_288 : auto) : auto {
    return c2da___a_288
}
[export]
def _mm_mullo_epi32(var c2da___V1_2 : auto; var c2da___V2_2 : auto) : auto {
    return c2da___V1_2 * c2da___V2_2
}
[export]
def _mm_cmpeq_epi64(var c2da___V1_12 : auto; var c2da___V2_12 : auto) : auto {
    return c2da___V1_12 == c2da___V2_12
}
[export]
def _mm_cmpgt_epi64(var c2da___V1_14 : auto; var c2da___V2_14 : auto) : auto {
    return c2da___V1_14 > c2da___V2_14
}
[export]
def _mm_popcnt_u32(var c2da___A_9 : uint) : int {
    return 0
}
[export]
def _mm_popcnt_u64(var c2da___A_10 : uint64) : int64 {
    return int64(0)
}
[export]
def _mm256_add_pd(var c2da___a_329 : auto; var c2da___b_231 : auto) : auto {
    return c2da___a_329 + c2da___b_231
}
[export]
def _mm256_add_ps(var c2da___a_330 : auto; var c2da___b_232 : auto) : auto {
    return c2da___a_330 + c2da___b_232
}
[export]
def _mm256_sub_pd(var c2da___a_331 : auto; var c2da___b_233 : auto) : auto {
    return c2da___a_331 - c2da___b_233
}
[export]
def _mm256_sub_ps(var c2da___a_332 : auto; var c2da___b_234 : auto) : auto {
    return c2da___a_332 - c2da___b_234
}
[export]
def _mm256_div_pd(var c2da___a_335 : auto; var c2da___b_237 : auto) : auto {
    return c2da___a_335 / c2da___b_237
}
[export]
def _mm256_div_ps(var c2da___a_336 : auto; var c2da___b_238 : auto) : auto {
    return c2da___a_336 / c2da___b_238
}
[export]
def _mm256_mul_pd(var c2da___a_341 : auto; var c2da___b_243 : auto) : auto {
    return c2da___a_341 * c2da___b_243
}
[export]
def _mm256_mul_ps(var c2da___a_342 : auto; var c2da___b_244 : auto) : auto {
    return c2da___a_342 * c2da___b_244
}
[export]
def _mm256_and_pd(var c2da___a_347 : auto; var c2da___b_245 : auto) : auto {
    return c2da___a_347 & c2da___b_245
}
[export]
def _mm256_and_ps(var c2da___a_348 : auto; var c2da___b_246 : auto) : auto {
    return c2da___a_348 & c2da___b_246
}
[export]
def _mm256_andnot_pd(var c2da___a_349 : auto; var c2da___b_247 : auto) : auto {
    return ~c2da___a_349 & c2da___b_247
}
[export]
def _mm256_andnot_ps(var c2da___a_350 : auto; var c2da___b_248 : auto) : auto {
    return ~c2da___a_350 & c2da___b_248
}
[export]
def _mm256_or_pd(var c2da___a_351 : auto; var c2da___b_249 : auto) : auto {
    return c2da___a_351 | c2da___b_249
}
[export]
def _mm256_or_ps(var c2da___a_352 : auto; var c2da___b_250 : auto) : auto {
    return c2da___a_352 | c2da___b_250
}
[export]
def _mm256_xor_pd(var c2da___a_353 : auto; var c2da___b_251 : auto) : auto {
    return c2da___a_353 ^ c2da___b_251
}
[export]
def _mm256_xor_ps(var c2da___a_354 : auto; var c2da___b_252 : auto) : auto {
    return c2da___a_354 ^ c2da___b_252
}
[export]
def _mm256_cvtsd_f64(var c2da___a_373 : auto) : double {
    return unsafe(c2da___a_373[0])
}
[export]
def _mm256_cvtsi256_si32(var c2da___a_374 : auto) : int {
    var c2da___b_259 : auto = cast<auto>(0)
    c2da___b_259 = c2da___a_374
    return unsafe(c2da___b_259[0])
}
[export]
def _mm256_cvtss_f32(var c2da___a_375 : auto) : float {
    return unsafe(c2da___a_375[0])
}
[export]
def _mm_broadcast_ss(var c2da___a_400 : float const?) : auto {
    var c2da___f : float = float(0)
    c2da___f = c2da___a_400.c2da___f
    return [c2da___f, c2da___f, c2da___f, c2da___f]
}
[export]
def _mm256_broadcast_sd(var c2da___a_401 : double const?) : auto {
    var c2da___d_1 : double = double(0)
    c2da___d_1 = c2da___a_401.c2da___d
    return [c2da___d_1, c2da___d_1, c2da___d_1, c2da___d_1]
}
[export]
def _mm256_broadcast_ss(var c2da___a_402 : float const?) : auto {
    var c2da___f_0 : float = float(0)
    c2da___f_0 = c2da___a_402.c2da___f
    return [c2da___f_0, c2da___f_0, c2da___f_0, c2da___f_0, c2da___f_0, c2da___f_0, c2da___f_0, c2da___f_0]
}
[export]
def _mm256_load_pd(var c2da___p_35 : double const?) : auto {
    return *c2da___p_35
}
[export]
def _mm256_load_ps(var c2da___p_36 : float const?) : auto {
    return *c2da___p_36
}
[export]
def _mm256_loadu_pd(var c2da___p_37 : double const?) : auto {
    return c2da___p_37.c2da___v
}
[export]
def _mm256_loadu_ps(var c2da___p_38 : float const?) : auto {
    return c2da___p_38.c2da___v
}
[export]
def _mm256_load_si256(var c2da___p_39 : auto const?) : auto {
    return *c2da___p_39
}
[export]
def _mm256_loadu_si256(var c2da___p_40 : auto const?) : auto {
    return c2da___p_40.c2da___v
}
[export]
def _mm256_store_pd(var c2da___p_42 : double?; var c2da___a_405 : auto) {
    *c2da___p_42 = c2da___a_405
    return
}
[export]
def _mm256_store_ps(var c2da___p_43 : float?; var c2da___a_406 : auto) {
    *c2da___p_43 = c2da___a_406
    return
}
[export]
def _mm256_storeu_pd(var c2da___p_44 : double?; var c2da___a_407 : auto) {
    c2da___p_44.c2da___v = c2da___a_407
    return
}
[export]
def _mm256_storeu_ps(var c2da___p_45 : float?; var c2da___a_408 : auto) {
    c2da___p_45.c2da___v = c2da___a_408
    return
}
[export]
def _mm256_store_si256(var c2da___p_46 : auto?; var c2da___a_409 : auto) {
    *c2da___p_46 = c2da___a_409
    return
}
[export]
def _mm256_storeu_si256(var c2da___p_47 : auto?; var c2da___a_410 : auto) {
    c2da___p_47.c2da___v = c2da___a_410
    return
}
[export]
def _mm256_set_pd(var c2da___a_418 : double; var c2da___b_283 : double; var c2da___c_15 : double; var c2da___d_2 : double) : auto {
    return [c2da___d_2, c2da___c_15, c2da___b_283, c2da___a_418]
}
[export]
def _mm256_set_ps(var c2da___a_419 : float; var c2da___b_284 : float; var c2da___c_16 : float; var c2da___d_3 : float; var c2da___e : float; var c2da___f_1 : float; var c2da___g : float; var c2da___h : float) : auto {
    return [c2da___h, c2da___g, c2da___f_1, c2da___e, c2da___d_3, c2da___c_16, c2da___b_284, c2da___a_419]
}
[export]
def _mm256_set_epi32(var c2da___i0_3 : int; var c2da___i1_3 : int; var c2da___i2_1 : int; var c2da___i3_1 : int; var c2da___i4 : int; var c2da___i5 : int; var c2da___i6 : int; var c2da___i7 : int) : auto {
    return [c2da___i7, c2da___i6, c2da___i5, c2da___i4, c2da___i3_1, c2da___i2_1, c2da___i1_3, c2da___i0_3]
}
[export]
def _mm256_set_epi16(var c2da___w15 : int; var c2da___w14 : int; var c2da___w13 : int; var c2da___w12 : int; var c2da___w11 : int; var c2da___w10 : int; var c2da___w09 : int; var c2da___w08 : int; var c2da___w07 : int; var c2da___w06 : int; var c2da___w05 : int; var c2da___w04 : int; var c2da___w03 : int; var c2da___w02 : int; var c2da___w01 : int; var c2da___w00 : int) : auto {
    return [c2da___w00, c2da___w01, c2da___w02, c2da___w03, c2da___w04, c2da___w05, c2da___w06, c2da___w07, c2da___w08, c2da___w09, c2da___w10, c2da___w11, c2da___w12, c2da___w13, c2da___w14, c2da___w15]
}
[export]
def _mm256_set_epi8(var c2da___b31 : int8; var c2da___b30 : int8; var c2da___b29 : int8; var c2da___b28 : int8; var c2da___b27 : int8; var c2da___b26 : int8; var c2da___b25 : int8; var c2da___b24 : int8; var c2da___b23 : int8; var c2da___b22 : int8; var c2da___b21 : int8; var c2da___b20 : int8; var c2da___b19 : int8; var c2da___b18 : int8; var c2da___b17 : int8; var c2da___b16 : int8; var c2da___b15_1 : int8; var c2da___b14_1 : int8; var c2da___b13_1 : int8; var c2da___b12_1 : int8; var c2da___b11_1 : int8; var c2da___b10_1 : int8; var c2da___b09 : int8; var c2da___b08 : int8; var c2da___b07 : int8; var c2da___b06 : int8; var c2da___b05 : int8; var c2da___b04 : int8; var c2da___b03 : int8; var c2da___b02 : int8; var c2da___b01 : int8; var c2da___b00 : int8) : auto {
    return [c2da___b00, c2da___b01, c2da___b02, c2da___b03, c2da___b04, c2da___b05, c2da___b06, c2da___b07, c2da___b08, c2da___b09, c2da___b10_1, c2da___b11_1, c2da___b12_1, c2da___b13_1, c2da___b14_1, c2da___b15_1, c2da___b16, c2da___b17, c2da___b18, c2da___b19, c2da___b20, c2da___b21, c2da___b22, c2da___b23, c2da___b24, c2da___b25, c2da___b26, c2da___b27, c2da___b28, c2da___b29, c2da___b30, c2da___b31]
}
[export]
def _mm256_set_epi64x(var c2da___a_420 : int64; var c2da___b_285 : int64; var c2da___c_17 : int64; var c2da___d_4 : int64) : auto {
    return [c2da___d_4, c2da___c_17, c2da___b_285, c2da___a_420]
}
[export]
def _mm256_setr_pd(var c2da___a_421 : double; var c2da___b_286 : double; var c2da___c_18 : double; var c2da___d_5 : double) : auto {
    return _mm256_set_pd(c2da___d_5, c2da___c_18, c2da___b_286, c2da___a_421)
}
[export]
def _mm256_setr_ps(var c2da___a_422 : float; var c2da___b_287 : float; var c2da___c_19 : float; var c2da___d_6 : float; var c2da___e_0 : float; var c2da___f_2 : float; var c2da___g_0 : float; var c2da___h_0 : float) : auto {
    return _mm256_set_ps(c2da___h_0, c2da___g_0, c2da___f_2, c2da___e_0, c2da___d_6, c2da___c_19, c2da___b_287, c2da___a_422)
}
[export]
def _mm256_setr_epi32(var c2da___i0_4 : int; var c2da___i1_4 : int; var c2da___i2_2 : int; var c2da___i3_2 : int; var c2da___i4_0 : int; var c2da___i5_0 : int; var c2da___i6_0 : int; var c2da___i7_0 : int) : auto {
    return _mm256_set_epi32(c2da___i7_0, c2da___i6_0, c2da___i5_0, c2da___i4_0, c2da___i3_2, c2da___i2_2, c2da___i1_4, c2da___i0_4)
}
[export]
def _mm256_setr_epi16(var c2da___w15_0 : int; var c2da___w14_0 : int; var c2da___w13_0 : int; var c2da___w12_0 : int; var c2da___w11_0 : int; var c2da___w10_0 : int; var c2da___w09_0 : int; var c2da___w08_0 : int; var c2da___w07_0 : int; var c2da___w06_0 : int; var c2da___w05_0 : int; var c2da___w04_0 : int; var c2da___w03_0 : int; var c2da___w02_0 : int; var c2da___w01_0 : int; var c2da___w00_0 : int) : auto {
    return _mm256_set_epi16(c2da___w00_0, c2da___w01_0, c2da___w02_0, c2da___w03_0, c2da___w04_0, c2da___w05_0, c2da___w06_0, c2da___w07_0, c2da___w08_0, c2da___w09_0, c2da___w10_0, c2da___w11_0, c2da___w12_0, c2da___w13_0, c2da___w14_0, c2da___w15_0)
}
[export]
def _mm256_setr_epi8(var c2da___b31_0 : int8; var c2da___b30_0 : int8; var c2da___b29_0 : int8; var c2da___b28_0 : int8; var c2da___b27_0 : int8; var c2da___b26_0 : int8; var c2da___b25_0 : int8; var c2da___b24_0 : int8; var c2da___b23_0 : int8; var c2da___b22_0 : int8; var c2da___b21_0 : int8; var c2da___b20_0 : int8; var c2da___b19_0 : int8; var c2da___b18_0 : int8; var c2da___b17_0 : int8; var c2da___b16_0 : int8; var c2da___b15_2 : int8; var c2da___b14_2 : int8; var c2da___b13_2 : int8; var c2da___b12_2 : int8; var c2da___b11_2 : int8; var c2da___b10_2 : int8; var c2da___b09_0 : int8; var c2da___b08_0 : int8; var c2da___b07_0 : int8; var c2da___b06_0 : int8; var c2da___b05_0 : int8; var c2da___b04_0 : int8; var c2da___b03_0 : int8; var c2da___b02_0 : int8; var c2da___b01_0 : int8; var c2da___b00_0 : int8) : auto {
    return _mm256_set_epi8(c2da___b00_0, c2da___b01_0, c2da___b02_0, c2da___b03_0, c2da___b04_0, c2da___b05_0, c2da___b06_0, c2da___b07_0, c2da___b08_0, c2da___b09_0, c2da___b10_2, c2da___b11_2, c2da___b12_2, c2da___b13_2, c2da___b14_2, c2da___b15_2, c2da___b16_0, c2da___b17_0, c2da___b18_0, c2da___b19_0, c2da___b20_0, c2da___b21_0, c2da___b22_0, c2da___b23_0, c2da___b24_0, c2da___b25_0, c2da___b26_0, c2da___b27_0, c2da___b28_0, c2da___b29_0, c2da___b30_0, c2da___b31_0)
}
[export]
def _mm256_setr_epi64x(var c2da___a_423 : int64; var c2da___b_288 : int64; var c2da___c_20 : int64; var c2da___d_7 : int64) : auto {
    return _mm256_set_epi64x(c2da___d_7, c2da___c_20, c2da___b_288, c2da___a_423)
}
[export]
def _mm256_set1_pd(var c2da___w_11 : double) : auto {
    return _mm256_set_pd(c2da___w_11, c2da___w_11, c2da___w_11, c2da___w_11)
}
[export]
def _mm256_set1_ps(var c2da___w_12 : float) : auto {
    return _mm256_set_ps(c2da___w_12, c2da___w_12, c2da___w_12, c2da___w_12, c2da___w_12, c2da___w_12, c2da___w_12, c2da___w_12)
}
[export]
def _mm256_set1_epi32(var c2da___i_3 : int) : auto {
    return _mm256_set_epi32(c2da___i_3, c2da___i_3, c2da___i_3, c2da___i_3, c2da___i_3, c2da___i_3, c2da___i_3, c2da___i_3)
}
[export]
def _mm256_set1_epi16(var c2da___w_13 : int) : auto {
    return _mm256_set_epi16(c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13, c2da___w_13)
}
[export]
def _mm256_set1_epi8(var c2da___b_289 : int8) : auto {
    return _mm256_set_epi8(c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289, c2da___b_289)
}
[export]
def _mm256_set1_epi64x(var c2da___q_1 : int64) : auto {
    return _mm256_set_epi64x(c2da___q_1, c2da___q_1, c2da___q_1, c2da___q_1)
}
[export]
def _mm256_setzero_pd() : auto {
    return [double(0.0), double(0.0), double(0.0), double(0.0)]
}
[export]
def _mm256_setzero_ps() : auto {
    return [double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0)]
}
[export]
def _mm256_setzero_si256() : auto {
    return [int64(0), int64(0), int64(0), int64(0)]
}
[export]
def _mm256_castpd_ps(var c2da___a_424 : auto) : auto {
    return c2da___a_424
}
[export]
def _mm256_castpd_si256(var c2da___a_425 : auto) : auto {
    return c2da___a_425
}
[export]
def _mm256_castps_pd(var c2da___a_426 : auto) : auto {
    return c2da___a_426
}
[export]
def _mm256_castps_si256(var c2da___a_427 : auto) : auto {
    return c2da___a_427
}
[export]
def _mm256_castsi256_ps(var c2da___a_428 : auto) : auto {
    return c2da___a_428
}
[export]
def _mm256_castsi256_pd(var c2da___a_429 : auto) : auto {
    return c2da___a_429
}
[export]
def _mm256_setr_m128(var c2da___lo_2 : auto; var c2da___hi_2 : auto) : auto {
    return _mm256_set_m128(c2da___hi_2, c2da___lo_2)
}
[export]
def _mm256_setr_m128d(var c2da___lo_3 : auto; var c2da___hi_3 : auto) : auto {
    return _mm256_set_m128d(c2da___hi_3, c2da___lo_3)
}
[export]
def _mm256_setr_m128i(var c2da___lo_4 : auto; var c2da___hi_4 : auto) : auto {
    return _mm256_set_m128i(c2da___hi_4, c2da___lo_4)
}
[export]
def _mm256_loadu2_m128(var c2da___addr_hi : float const?; var c2da___addr_lo : float const?) : auto {
    return _mm256_set_m128(_mm_loadu_ps(c2da___addr_hi), _mm_loadu_ps(c2da___addr_lo))
}
[export]
def _mm256_loadu2_m128d(var c2da___addr_hi_0 : double const?; var c2da___addr_lo_0 : double const?) : auto {
    return _mm256_set_m128d(_mm_loadu_pd(c2da___addr_hi_0), _mm_loadu_pd(c2da___addr_lo_0))
}
[export]
def _mm256_loadu2_m128i(var c2da___addr_hi_1 : auto const?; var c2da___addr_lo_1 : auto const?) : auto {
    return _mm256_set_m128i(_mm_loadu_si128(c2da___addr_hi_1), _mm_loadu_si128(c2da___addr_lo_1))
}
[export]
def _mm256_add_epi8(var c2da___a_448 : auto; var c2da___b_293 : auto) : auto {
    return c2da___a_448 + c2da___b_293
}
[export]
def _mm256_add_epi16(var c2da___a_449 : auto; var c2da___b_294 : auto) : auto {
    return c2da___a_449 + c2da___b_294
}
[export]
def _mm256_add_epi32(var c2da___a_450 : auto; var c2da___b_295 : auto) : auto {
    return c2da___a_450 + c2da___b_295
}
[export]
def _mm256_add_epi64(var c2da___a_451 : auto; var c2da___b_296 : auto) : auto {
    return c2da___a_451 + c2da___b_296
}
[export]
def _mm256_and_si256(var c2da___a_456 : auto; var c2da___b_301 : auto) : auto {
    return c2da___a_456 & c2da___b_301
}
[export]
def _mm256_andnot_si256(var c2da___a_457 : auto; var c2da___b_302 : auto) : auto {
    return ~c2da___a_457 & c2da___b_302
}
[export]
def _mm256_cmpeq_epi8(var c2da___a_460 : auto; var c2da___b_305 : auto) : auto {
    return c2da___a_460 == c2da___b_305
}
[export]
def _mm256_cmpeq_epi16(var c2da___a_461 : auto; var c2da___b_306 : auto) : auto {
    return c2da___a_461 == c2da___b_306
}
[export]
def _mm256_cmpeq_epi32(var c2da___a_462 : auto; var c2da___b_307 : auto) : auto {
    return c2da___a_462 == c2da___b_307
}
[export]
def _mm256_cmpeq_epi64(var c2da___a_463 : auto; var c2da___b_308 : auto) : auto {
    return c2da___a_463 == c2da___b_308
}
[export]
def _mm256_cmpgt_epi8(var c2da___a_464 : auto; var c2da___b_309 : auto) : auto {
    return c2da___a_464 > c2da___b_309
}
[export]
def _mm256_cmpgt_epi16(var c2da___a_465 : auto; var c2da___b_310 : auto) : auto {
    return c2da___a_465 > c2da___b_310
}
[export]
def _mm256_cmpgt_epi32(var c2da___a_466 : auto; var c2da___b_311 : auto) : auto {
    return c2da___a_466 > c2da___b_311
}
[export]
def _mm256_cmpgt_epi64(var c2da___a_467 : auto; var c2da___b_312 : auto) : auto {
    return c2da___a_467 > c2da___b_312
}
[export]
def _mm256_mullo_epi16(var c2da___a_493 : auto; var c2da___b_337 : auto) : auto {
    return c2da___a_493 * c2da___b_337
}
[export]
def _mm256_mullo_epi32(var c2da___a_494 : auto; var c2da___b_338 : auto) : auto {
    return c2da___a_494 * c2da___b_338
}
[export]
def _mm256_or_si256(var c2da___a_496 : auto; var c2da___b_340 : auto) : auto {
    return c2da___a_496 | c2da___b_340
}
[export]
def _mm256_sub_epi8(var c2da___a_518 : auto; var c2da___b_346 : auto) : auto {
    return c2da___a_518 - c2da___b_346
}
[export]
def _mm256_sub_epi16(var c2da___a_519 : auto; var c2da___b_347 : auto) : auto {
    return c2da___a_519 - c2da___b_347
}
[export]
def _mm256_sub_epi32(var c2da___a_520 : auto; var c2da___b_348 : auto) : auto {
    return c2da___a_520 - c2da___b_348
}
[export]
def _mm256_sub_epi64(var c2da___a_521 : auto; var c2da___b_349 : auto) : auto {
    return c2da___a_521 - c2da___b_349
}
[export]
def _mm256_xor_si256(var c2da___a_534 : auto; var c2da___b_362 : auto) : auto {
    return c2da___a_534 ^ c2da___b_362
}
[export]
def c2da___andn_u32(var c2da___X_34 : uint; var c2da___Y_13 : uint) : uint {
    return ~c2da___X_34 & uint(c2da___Y_13)
}
[export]
def c2da___blsi_u32(var c2da___X_38 : uint) : uint {
    return uint(c2da___X_38) & -c2da___X_38
}
[export]
def c2da___blsmsk_u32(var c2da___X_39 : uint) : uint {
    return uint(c2da___X_39) ^ uint(c2da___X_39) - uint(1)
}
[export]
def c2da___blsr_u32(var c2da___X_40 : uint) : uint {
    return uint(c2da___X_40) & uint(c2da___X_40) - uint(1)
}
[export]
def c2da___andn_u64(var c2da___X_41 : uint64; var c2da___Y_17 : uint64) : uint64 {
    return ~c2da___X_41 & uint64(c2da___Y_17)
}
[export]
def c2da___blsi_u64(var c2da___X_45 : uint64) : uint64 {
    return uint64(c2da___X_45) & -c2da___X_45
}
[export]
def c2da___blsmsk_u64(var c2da___X_46 : uint64) : uint64 {
    return uint64(c2da___X_46) ^ uint64(c2da___X_46) - uint64(1)
}
[export]
def c2da___blsr_u64(var c2da___X_47 : uint64) : uint64 {
    return uint64(c2da___X_47) & uint64(c2da___X_47) - uint64(1)
}
[export]
def _mulx_u32(var c2da___X_51 : uint; var c2da___Y_24 : uint; var c2da___P_1 : uint?) : uint {
    var c2da___res : uint64 = uint64(0)
    c2da___res = uint64(c2da___X_51) * uint64(c2da___Y_24)
    *c2da___P_1 = uint(uint(uint64(uint64(c2da___res)) >> uint64(uint64(32))))
    return uint(c2da___res)
}
[export]
def _mulx_u64(var c2da___X_55 : uint64; var c2da___Y_28 : uint64; var c2da___P_2 : uint64?) : uint64 {
    var c2da___res_0 : uint = uint(0)
    c2da___res_0 = uint(c2da___X_55) * uint(c2da___Y_28)
    *c2da___P_2 = uint64(uint64(uint(c2da___res_0) >> uint(64)))
    return uint64(c2da___res_0)
}
[export]
def _mm512_setzero_si512() : auto {
    return [int64(0), int64(0), int64(0), int64(0), int64(0), int64(0), int64(0), int64(0)]
}
[export]
def _mm512_setzero_ps() : auto {
    return [double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0)]
}
[export]
def _mm512_setzero_pd() : auto {
    return [double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0)]
}
[export]
def _mm512_set1_ps(var c2da___w_14 : float) : auto {
    return [c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14, c2da___w_14]
}
[export]
def _mm512_set1_pd(var c2da___w_15 : double) : auto {
    return [c2da___w_15, c2da___w_15, c2da___w_15, c2da___w_15, c2da___w_15, c2da___w_15, c2da___w_15, c2da___w_15]
}
[export]
def _mm512_set1_epi8(var c2da___w_16 : int8) : auto {
    return [c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16, c2da___w_16]
}
[export]
def _mm512_set1_epi16(var c2da___w_17 : int) : auto {
    return [c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17, c2da___w_17]
}
[export]
def _mm512_set1_epi32(var c2da___s : int) : auto {
    return [c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s, c2da___s]
}
[export]
def _mm512_set1_epi64(var c2da___d_8 : int64) : auto {
    return [c2da___d_8, c2da___d_8, c2da___d_8, c2da___d_8, c2da___d_8, c2da___d_8, c2da___d_8, c2da___d_8]
}
[export]
def _mm512_set4_epi32(var c2da___A_52 : int; var c2da___B_40 : int; var c2da___C_35 : int; var c2da___D_3 : int) : auto {
    return [c2da___D_3, c2da___C_35, c2da___B_40, c2da___A_52, c2da___D_3, c2da___C_35, c2da___B_40, c2da___A_52, c2da___D_3, c2da___C_35, c2da___B_40, c2da___A_52, c2da___D_3, c2da___C_35, c2da___B_40, c2da___A_52]
}
[export]
def _mm512_set4_epi64(var c2da___A_53 : int64; var c2da___B_41 : int64; var c2da___C_36 : int64; var c2da___D_4 : int64) : auto {
    return [c2da___D_4, c2da___C_36, c2da___B_41, c2da___A_53, c2da___D_4, c2da___C_36, c2da___B_41, c2da___A_53]
}
[export]
def _mm512_set4_pd(var c2da___A_54 : double; var c2da___B_42 : double; var c2da___C_37 : double; var c2da___D_5 : double) : auto {
    return [c2da___D_5, c2da___C_37, c2da___B_42, c2da___A_54, c2da___D_5, c2da___C_37, c2da___B_42, c2da___A_54]
}
[export]
def _mm512_set4_ps(var c2da___A_55 : float; var c2da___B_43 : float; var c2da___C_38 : float; var c2da___D_6 : float) : auto {
    return [c2da___D_6, c2da___C_38, c2da___B_43, c2da___A_55, c2da___D_6, c2da___C_38, c2da___B_43, c2da___A_55, c2da___D_6, c2da___C_38, c2da___B_43, c2da___A_55, c2da___D_6, c2da___C_38, c2da___B_43, c2da___A_55]
}
[export]
def _mm512_castpd_ps(var c2da___A_59 : auto) : auto {
    return c2da___A_59
}
[export]
def _mm512_castpd_si512(var c2da___A_60 : auto) : auto {
    return c2da___A_60
}
[export]
def _mm512_castps_pd(var c2da___A_62 : auto) : auto {
    return c2da___A_62
}
[export]
def _mm512_castps_si512(var c2da___A_63 : auto) : auto {
    return c2da___A_63
}
[export]
def _mm512_castsi512_ps(var c2da___A_67 : auto) : auto {
    return c2da___A_67
}
[export]
def _mm512_castsi512_pd(var c2da___A_68 : auto) : auto {
    return c2da___A_68
}
[export]
def _mm512_int2mask(var c2da___a_545 : int) : int {
    return c2da___a_545
}
[export]
def _mm512_mask2int(var c2da___a_546 : int) : int {
    return c2da___a_546
}
[export]
def _mm512_and_epi32(var c2da___a_553 : auto; var c2da___b_365 : auto) : auto {
    return c2da___a_553 & c2da___b_365
}
[export]
def _mm512_maskz_and_epi32(var c2da___k_0 : int; var c2da___a_555 : auto; var c2da___b_367 : auto) : auto {
    return _mm512_mask_and_epi32(_mm512_setzero_si512(), c2da___k_0, c2da___a_555, c2da___b_367)
}
[export]
def _mm512_and_epi64(var c2da___a_556 : auto; var c2da___b_368 : auto) : auto {
    return c2da___a_556 & c2da___b_368
}
[export]
def _mm512_maskz_and_epi64(var c2da___k_2 : uint8; var c2da___a_558 : auto; var c2da___b_370 : auto) : auto {
    return _mm512_mask_and_epi64(_mm512_setzero_si512(), c2da___k_2, c2da___a_558, c2da___b_370)
}
[export]
def _mm512_andnot_si512(var c2da___A_71 : auto; var c2da___B_47 : auto) : auto {
    return ~c2da___A_71 & c2da___B_47
}
[export]
def _mm512_andnot_epi32(var c2da___A_72 : auto; var c2da___B_48 : auto) : auto {
    return ~c2da___A_72 & c2da___B_48
}
[export]
def _mm512_maskz_andnot_epi32(var c2da___U_0 : int; var c2da___A_74 : auto; var c2da___B_50 : auto) : auto {
    return _mm512_mask_andnot_epi32(_mm512_setzero_si512(), c2da___U_0, c2da___A_74, c2da___B_50)
}
[export]
def _mm512_andnot_epi64(var c2da___A_75 : auto; var c2da___B_51 : auto) : auto {
    return ~c2da___A_75 & c2da___B_51
}
[export]
def _mm512_maskz_andnot_epi64(var c2da___U_2 : uint8; var c2da___A_77 : auto; var c2da___B_53 : auto) : auto {
    return _mm512_mask_andnot_epi64(_mm512_setzero_si512(), c2da___U_2, c2da___A_77, c2da___B_53)
}
[export]
def _mm512_or_epi32(var c2da___a_559 : auto; var c2da___b_371 : auto) : auto {
    return c2da___a_559 | c2da___b_371
}
[export]
def _mm512_maskz_or_epi32(var c2da___k_4 : int; var c2da___a_561 : auto; var c2da___b_373 : auto) : auto {
    return _mm512_mask_or_epi32(_mm512_setzero_si512(), c2da___k_4, c2da___a_561, c2da___b_373)
}
[export]
def _mm512_or_epi64(var c2da___a_562 : auto; var c2da___b_374 : auto) : auto {
    return c2da___a_562 | c2da___b_374
}
[export]
def _mm512_maskz_or_epi64(var c2da___k_6 : uint8; var c2da___a_564 : auto; var c2da___b_376 : auto) : auto {
    return _mm512_mask_or_epi64(_mm512_setzero_si512(), c2da___k_6, c2da___a_564, c2da___b_376)
}
[export]
def _mm512_xor_epi32(var c2da___a_565 : auto; var c2da___b_377 : auto) : auto {
    return c2da___a_565 ^ c2da___b_377
}
[export]
def _mm512_maskz_xor_epi32(var c2da___k_8 : int; var c2da___a_567 : auto; var c2da___b_379 : auto) : auto {
    return _mm512_mask_xor_epi32(_mm512_setzero_si512(), c2da___k_8, c2da___a_567, c2da___b_379)
}
[export]
def _mm512_xor_epi64(var c2da___a_568 : auto; var c2da___b_380 : auto) : auto {
    return c2da___a_568 ^ c2da___b_380
}
[export]
def _mm512_maskz_xor_epi64(var c2da___k_10 : uint8; var c2da___a_570 : auto; var c2da___b_382 : auto) : auto {
    return _mm512_mask_xor_epi64(_mm512_setzero_si512(), c2da___k_10, c2da___a_570, c2da___b_382)
}
[export]
def _mm512_and_si512(var c2da___a_571 : auto; var c2da___b_383 : auto) : auto {
    return c2da___a_571 & c2da___b_383
}
[export]
def _mm512_or_si512(var c2da___a_572 : auto; var c2da___b_384 : auto) : auto {
    return c2da___a_572 | c2da___b_384
}
[export]
def _mm512_xor_si512(var c2da___a_573 : auto; var c2da___b_385 : auto) : auto {
    return c2da___a_573 ^ c2da___b_385
}
[export]
def _mm512_add_pd(var c2da___a_574 : auto; var c2da___b_386 : auto) : auto {
    return c2da___a_574 + c2da___b_386
}
[export]
def _mm512_add_ps(var c2da___a_575 : auto; var c2da___b_387 : auto) : auto {
    return c2da___a_575 + c2da___b_387
}
[export]
def _mm512_mul_pd(var c2da___a_576 : auto; var c2da___b_388 : auto) : auto {
    return c2da___a_576 * c2da___b_388
}
[export]
def _mm512_mul_ps(var c2da___a_577 : auto; var c2da___b_389 : auto) : auto {
    return c2da___a_577 * c2da___b_389
}
[export]
def _mm512_sub_pd(var c2da___a_578 : auto; var c2da___b_390 : auto) : auto {
    return c2da___a_578 - c2da___b_390
}
[export]
def _mm512_sub_ps(var c2da___a_579 : auto; var c2da___b_391 : auto) : auto {
    return c2da___a_579 - c2da___b_391
}
[export]
def _mm512_add_epi64(var c2da___A_78 : auto; var c2da___B_54 : auto) : auto {
    return c2da___A_78 + c2da___B_54
}
[export]
def _mm512_sub_epi64(var c2da___A_81 : auto; var c2da___B_57 : auto) : auto {
    return c2da___A_81 - c2da___B_57
}
[export]
def _mm512_add_epi32(var c2da___A_84 : auto; var c2da___B_60 : auto) : auto {
    return c2da___A_84 + c2da___B_60
}
[export]
def _mm512_sub_epi32(var c2da___A_87 : auto; var c2da___B_63 : auto) : auto {
    return c2da___A_87 - c2da___B_63
}
[export]
def _mm512_mullo_epi32(var c2da___A_134 : auto; var c2da___B_110 : auto) : auto {
    return c2da___A_134 * c2da___B_110
}
[export]
def _mm512_mullox_epi64(var c2da___A_137 : auto; var c2da___B_113 : auto) : auto {
    return c2da___A_137 * c2da___B_113
}
[export]
def _mm512_div_pd(var c2da___a_580 : auto; var c2da___b_392 : auto) : auto {
    return c2da___a_580 / c2da___b_392
}
[export]
def _mm512_div_ps(var c2da___a_581 : auto; var c2da___b_393 : auto) : auto {
    return c2da___a_581 / c2da___b_393
}
[export]
def _mm512_cvtepi32lo_pd(var c2da___A_284 : auto) : auto {
    return _mm512_cvtepi32_pd(_mm512_castsi512_si256(c2da___A_284))
}
[export]
def _mm512_mask_cvtepi32lo_pd(var c2da___W_64 : auto; var c2da___U_140 : uint8; var c2da___A_285 : auto) : auto {
    return _mm512_mask_cvtepi32_pd(c2da___W_64, c2da___U_140, _mm512_castsi512_si256(c2da___A_285))
}
[export]
def _mm512_cvtepu32lo_pd(var c2da___A_292 : auto) : auto {
    return _mm512_cvtepu32_pd(_mm512_castsi512_si256(c2da___A_292))
}
[export]
def _mm512_mask_cvtepu32lo_pd(var c2da___W_67 : auto; var c2da___U_145 : uint8; var c2da___A_293 : auto) : auto {
    return _mm512_mask_cvtepu32_pd(c2da___W_67, c2da___U_145, _mm512_castsi512_si256(c2da___A_293))
}
[export]
def _mm512_cvtsd_f64(var c2da___a_584 : auto) : double {
    return unsafe(c2da___a_584[0])
}
[export]
def _mm512_cvtss_f32(var c2da___a_585 : auto) : float {
    return unsafe(c2da___a_585[0])
}
[export]
def _mm512_loadu_si512(var c2da___P_3 : uint64) : auto {
    return c2da___P_3.c2da___v
}
[export]
def _mm512_loadu_epi32(var c2da___P_4 : uint64) : auto {
    return c2da___P_4.c2da___v
}
[export]
def _mm512_loadu_epi64(var c2da___P_7 : uint64) : auto {
    return c2da___P_7.c2da___v
}
[export]
def _mm512_loadu_pd(var c2da___p_57 : uint64) : auto {
    return c2da___p_57.c2da___v
}
[export]
def _mm512_loadu_ps(var c2da___p_58 : uint64) : auto {
    return c2da___p_58.c2da___v
}
[export]
def _mm512_load_ps(var c2da___p_59 : uint64) : auto {
    return *c2da___p_59
}
[export]
def _mm512_load_pd(var c2da___p_60 : uint64) : auto {
    return *c2da___p_60
}
[export]
def _mm512_load_si512(var c2da___P_18 : uint64) : auto {
    return *c2da___P_18
}
[export]
def _mm512_load_epi32(var c2da___P_19 : uint64) : auto {
    return *c2da___P_19
}
[export]
def _mm512_load_epi64(var c2da___P_20 : uint64) : auto {
    return *c2da___P_20
}
[export]
def _mm512_storeu_epi64(var c2da___P_21 : uint64; var c2da___A_338 : auto) {
    c2da___P_21.c2da___v = c2da___A_338
    return
}
[export]
def _mm512_storeu_si512(var c2da___P_23 : uint64; var c2da___A_340 : auto) {
    c2da___P_23.c2da___v = c2da___A_340
    return
}
[export]
def _mm512_storeu_epi32(var c2da___P_24 : uint64; var c2da___A_341 : auto) {
    c2da___P_24.c2da___v = c2da___A_341
    return
}
[export]
def _mm512_storeu_pd(var c2da___P_27 : uint64; var c2da___A_344 : auto) {
    c2da___P_27.c2da___v = c2da___A_344
    return
}
[export]
def _mm512_storeu_ps(var c2da___P_29 : uint64; var c2da___A_346 : auto) {
    c2da___P_29.c2da___v = c2da___A_346
    return
}
[export]
def _mm512_store_pd(var c2da___P_31 : uint64; var c2da___A_348 : auto) {
    *c2da___P_31 = c2da___A_348
    return
}
[export]
def _mm512_store_ps(var c2da___P_33 : uint64; var c2da___A_350 : auto) {
    *c2da___P_33 = c2da___A_350
    return
}
[export]
def _mm512_store_si512(var c2da___P_34 : uint64; var c2da___A_351 : auto) {
    *c2da___P_34 = c2da___A_351
    return
}
[export]
def _mm512_store_epi32(var c2da___P_35 : uint64; var c2da___A_352 : auto) {
    *c2da___P_35 = c2da___A_352
    return
}
[export]
def _mm512_store_epi64(var c2da___P_36 : uint64; var c2da___A_353 : auto) {
    *c2da___P_36 = c2da___A_353
    return
}
[export]
def _mm512_kmov(var c2da___A_417 : int) : int {
    return c2da___A_417
}
[export]
def _mm512_cvtpslo_pd(var c2da___A_646 : auto) : auto {
    return _mm512_cvtps_pd(_mm512_castps512_ps256(c2da___A_646))
}
[export]
def _mm512_mask_cvtpslo_pd(var c2da___W_182 : auto; var c2da___U_377 : uint8; var c2da___A_647 : auto) : auto {
    return _mm512_mask_cvtps_pd(c2da___W_182, c2da___U_377, _mm512_castps512_ps256(c2da___A_647))
}
[export]
def _mm_cvtu32_sd(var c2da___A_660 : auto; var c2da___B_357 : uint) : auto {
    unsafe(c2da___A_660[0]) = double(c2da___B_357)
    return c2da___A_660
}
[export]
def _mm_cvtu64_sd(var c2da___A_661 : auto; var c2da___B_358 : uint64) : auto {
    unsafe(c2da___A_661[0]) = double(c2da___B_358)
    return c2da___A_661
}
[export]
def _mm_cvtu32_ss(var c2da___A_662 : auto; var c2da___B_359 : uint) : auto {
    unsafe(c2da___A_662[0]) = float(c2da___B_359)
    return c2da___A_662
}
[export]
def _mm_cvtu64_ss(var c2da___A_663 : auto; var c2da___B_360 : uint64) : auto {
    unsafe(c2da___A_663[0]) = float(c2da___B_360)
    return c2da___A_663
}
[export]
def _mm512_set_epi8(var c2da___e63 : int8; var c2da___e62 : int8; var c2da___e61 : int8; var c2da___e60 : int8; var c2da___e59 : int8; var c2da___e58 : int8; var c2da___e57 : int8; var c2da___e56 : int8; var c2da___e55 : int8; var c2da___e54 : int8; var c2da___e53 : int8; var c2da___e52 : int8; var c2da___e51 : int8; var c2da___e50 : int8; var c2da___e49 : int8; var c2da___e48 : int8; var c2da___e47 : int8; var c2da___e46 : int8; var c2da___e45 : int8; var c2da___e44 : int8; var c2da___e43 : int8; var c2da___e42 : int8; var c2da___e41 : int8; var c2da___e40 : int8; var c2da___e39 : int8; var c2da___e38 : int8; var c2da___e37 : int8; var c2da___e36 : int8; var c2da___e35 : int8; var c2da___e34 : int8; var c2da___e33 : int8; var c2da___e32 : int8; var c2da___e31 : int8; var c2da___e30 : int8; var c2da___e29 : int8; var c2da___e28 : int8; var c2da___e27 : int8; var c2da___e26 : int8; var c2da___e25 : int8; var c2da___e24 : int8; var c2da___e23 : int8; var c2da___e22 : int8; var c2da___e21 : int8; var c2da___e20 : int8; var c2da___e19 : int8; var c2da___e18 : int8; var c2da___e17 : int8; var c2da___e16 : int8; var c2da___e15 : int8; var c2da___e14 : int8; var c2da___e13 : int8; var c2da___e12 : int8; var c2da___e11 : int8; var c2da___e10 : int8; var c2da___e9 : int8; var c2da___e8 : int8; var c2da___e7 : int8; var c2da___e6 : int8; var c2da___e5 : int8; var c2da___e4 : int8; var c2da___e3 : int8; var c2da___e2 : int8; var c2da___e1 : int8; var c2da___e0 : int8) : auto {
    return [c2da___e0, c2da___e1, c2da___e2, c2da___e3, c2da___e4, c2da___e5, c2da___e6, c2da___e7, c2da___e8, c2da___e9, c2da___e10, c2da___e11, c2da___e12, c2da___e13, c2da___e14, c2da___e15, c2da___e16, c2da___e17, c2da___e18, c2da___e19, c2da___e20, c2da___e21, c2da___e22, c2da___e23, c2da___e24, c2da___e25, c2da___e26, c2da___e27, c2da___e28, c2da___e29, c2da___e30, c2da___e31, c2da___e32, c2da___e33, c2da___e34, c2da___e35, c2da___e36, c2da___e37, c2da___e38, c2da___e39, c2da___e40, c2da___e41, c2da___e42, c2da___e43, c2da___e44, c2da___e45, c2da___e46, c2da___e47, c2da___e48, c2da___e49, c2da___e50, c2da___e51, c2da___e52, c2da___e53, c2da___e54, c2da___e55, c2da___e56, c2da___e57, c2da___e58, c2da___e59, c2da___e60, c2da___e61, c2da___e62, c2da___e63]
}
[export]
def _mm512_set_epi16(var c2da___e31_0 : int; var c2da___e30_0 : int; var c2da___e29_0 : int; var c2da___e28_0 : int; var c2da___e27_0 : int; var c2da___e26_0 : int; var c2da___e25_0 : int; var c2da___e24_0 : int; var c2da___e23_0 : int; var c2da___e22_0 : int; var c2da___e21_0 : int; var c2da___e20_0 : int; var c2da___e19_0 : int; var c2da___e18_0 : int; var c2da___e17_0 : int; var c2da___e16_0 : int; var c2da___e15_0 : int; var c2da___e14_0 : int; var c2da___e13_0 : int; var c2da___e12_0 : int; var c2da___e11_0 : int; var c2da___e10_0 : int; var c2da___e9_0 : int; var c2da___e8_0 : int; var c2da___e7_0 : int; var c2da___e6_0 : int; var c2da___e5_0 : int; var c2da___e4_0 : int; var c2da___e3_0 : int; var c2da___e2_0 : int; var c2da___e1_0 : int; var c2da___e0_0 : int) : auto {
    return [c2da___e0_0, c2da___e1_0, c2da___e2_0, c2da___e3_0, c2da___e4_0, c2da___e5_0, c2da___e6_0, c2da___e7_0, c2da___e8_0, c2da___e9_0, c2da___e10_0, c2da___e11_0, c2da___e12_0, c2da___e13_0, c2da___e14_0, c2da___e15_0, c2da___e16_0, c2da___e17_0, c2da___e18_0, c2da___e19_0, c2da___e20_0, c2da___e21_0, c2da___e22_0, c2da___e23_0, c2da___e24_0, c2da___e25_0, c2da___e26_0, c2da___e27_0, c2da___e28_0, c2da___e29_0, c2da___e30_0, c2da___e31_0]
}
[export]
def _mm512_set_epi32(var c2da___A_666 : int; var c2da___B_361 : int; var c2da___C_102 : int; var c2da___D_7 : int; var c2da___E : int; var c2da___F : int; var c2da___G : int; var c2da___H : int; var c2da___I_15 : int; var c2da___J : int; var c2da___K : int; var c2da___L : int; var c2da___M_106 : int; var c2da___N : int; var c2da___O_24 : int; var c2da___P_74 : int) : auto {
    return [c2da___P_74, c2da___O_24, c2da___N, c2da___M_106, c2da___L, c2da___K, c2da___J, c2da___I_15, c2da___H, c2da___G, c2da___F, c2da___E, c2da___D_7, c2da___C_102, c2da___B_361, c2da___A_666]
}
[export]
def _mm512_set_epi64(var c2da___A_667 : int64; var c2da___B_362 : int64; var c2da___C_103 : int64; var c2da___D_8 : int64; var c2da___E_0 : int64; var c2da___F_0 : int64; var c2da___G_0 : int64; var c2da___H_0 : int64) : auto {
    return [c2da___H_0, c2da___G_0, c2da___F_0, c2da___E_0, c2da___D_8, c2da___C_103, c2da___B_362, c2da___A_667]
}
[export]
def _mm512_set_pd(var c2da___A_668 : double; var c2da___B_363 : double; var c2da___C_104 : double; var c2da___D_9 : double; var c2da___E_1 : double; var c2da___F_1 : double; var c2da___G_1 : double; var c2da___H_1 : double) : auto {
    return [c2da___H_1, c2da___G_1, c2da___F_1, c2da___E_1, c2da___D_9, c2da___C_104, c2da___B_363, c2da___A_668]
}
[export]
def _mm512_set_ps(var c2da___A_669 : float; var c2da___B_364 : float; var c2da___C_105 : float; var c2da___D_10 : float; var c2da___E_2 : float; var c2da___F_2 : float; var c2da___G_2 : float; var c2da___H_2 : float; var c2da___I_16 : float; var c2da___J_0 : float; var c2da___K_0 : float; var c2da___L_0 : float; var c2da___M_107 : float; var c2da___N_0 : float; var c2da___O_25 : float; var c2da___P_75 : float) : auto {
    return [c2da___P_75, c2da___O_25, c2da___N_0, c2da___M_107, c2da___L_0, c2da___K_0, c2da___J_0, c2da___I_16, c2da___H_2, c2da___G_2, c2da___F_2, c2da___E_2, c2da___D_10, c2da___C_105, c2da___B_364, c2da___A_669]
}
[export]
def _mm512_abs_ps(var c2da___A_670 : auto) : auto {
    return _mm512_and_epi32(_mm512_set1_epi32(2147483647), c2da___A_670)
}
[export]
def _mm512_mask_abs_ps(var c2da___W_187 : auto; var c2da___K_1 : int; var c2da___A_671 : auto) : auto {
    return _mm512_mask_and_epi32(c2da___W_187, c2da___K_1, _mm512_set1_epi32(2147483647), c2da___A_671)
}
[export]
def _mm512_abs_pd(var c2da___A_672 : auto) : auto {
    return _mm512_and_epi64(_mm512_set1_epi64(0x7fffffffffffffffuL), c2da___A_672)
}
[export]
def _mm512_mask_abs_pd(var c2da___W_188 : auto; var c2da___K_2 : uint8; var c2da___A_673 : auto) : auto {
    return _mm512_mask_and_epi64(c2da___W_188, c2da___K_2, _mm512_set1_epi64(0x7fffffffffffffffuL), c2da___A_673)
}
[export]
def _mm512_cvtsi512_si32(var c2da___A_674 : auto) : int {
    var c2da___b_398 : auto = cast<auto>(0)
    c2da___b_398 = c2da___A_674
    return unsafe(c2da___b_398[0])
}
[export]
def _mm256_and_epi32(var c2da___a_590 : auto; var c2da___b_399 : auto) : auto {
    return c2da___a_590 & c2da___b_399
}
[export]
def _mm256_maskz_and_epi32(var c2da___U_407 : uint8; var c2da___A_696 : auto; var c2da___B_386 : auto) : auto {
    return _mm256_mask_and_epi32(_mm256_setzero_si256(), c2da___U_407, c2da___A_696, c2da___B_386)
}
[export]
def _mm_and_epi32(var c2da___a_591 : auto; var c2da___b_400 : auto) : auto {
    return c2da___a_591 & c2da___b_400
}
[export]
def _mm_maskz_and_epi32(var c2da___U_409 : uint8; var c2da___A_698 : auto; var c2da___B_388 : auto) : auto {
    return _mm_mask_and_epi32(_mm_setzero_si128(), c2da___U_409, c2da___A_698, c2da___B_388)
}
[export]
def _mm256_andnot_epi32(var c2da___A_699 : auto; var c2da___B_389 : auto) : auto {
    return ~c2da___A_699 & c2da___B_389
}
[export]
def _mm256_maskz_andnot_epi32(var c2da___U_411 : uint8; var c2da___A_701 : auto; var c2da___B_391 : auto) : auto {
    return _mm256_mask_andnot_epi32(_mm256_setzero_si256(), c2da___U_411, c2da___A_701, c2da___B_391)
}
[export]
def _mm_andnot_epi32(var c2da___A_702 : auto; var c2da___B_392 : auto) : auto {
    return ~c2da___A_702 & c2da___B_392
}
[export]
def _mm_maskz_andnot_epi32(var c2da___U_413 : uint8; var c2da___A_704 : auto; var c2da___B_394 : auto) : auto {
    return _mm_mask_andnot_epi32(_mm_setzero_si128(), c2da___U_413, c2da___A_704, c2da___B_394)
}
[export]
def _mm256_or_epi32(var c2da___a_592 : auto; var c2da___b_401 : auto) : auto {
    return c2da___a_592 | c2da___b_401
}
[export]
def _mm256_maskz_or_epi32(var c2da___U_415 : uint8; var c2da___A_706 : auto; var c2da___B_396 : auto) : auto {
    return _mm256_mask_or_epi32(_mm256_setzero_si256(), c2da___U_415, c2da___A_706, c2da___B_396)
}
[export]
def _mm_or_epi32(var c2da___a_593 : auto; var c2da___b_402 : auto) : auto {
    return c2da___a_593 | c2da___b_402
}
[export]
def _mm_maskz_or_epi32(var c2da___U_417 : uint8; var c2da___A_708 : auto; var c2da___B_398 : auto) : auto {
    return _mm_mask_or_epi32(_mm_setzero_si128(), c2da___U_417, c2da___A_708, c2da___B_398)
}
[export]
def _mm256_xor_epi32(var c2da___a_594 : auto; var c2da___b_403 : auto) : auto {
    return c2da___a_594 ^ c2da___b_403
}
[export]
def _mm256_maskz_xor_epi32(var c2da___U_419 : uint8; var c2da___A_710 : auto; var c2da___B_400 : auto) : auto {
    return _mm256_mask_xor_epi32(_mm256_setzero_si256(), c2da___U_419, c2da___A_710, c2da___B_400)
}
[export]
def _mm_xor_epi32(var c2da___a_595 : auto; var c2da___b_404 : auto) : auto {
    return c2da___a_595 ^ c2da___b_404
}
[export]
def _mm_maskz_xor_epi32(var c2da___U_421 : uint8; var c2da___A_712 : auto; var c2da___B_402 : auto) : auto {
    return _mm_mask_xor_epi32(_mm_setzero_si128(), c2da___U_421, c2da___A_712, c2da___B_402)
}
[export]
def _mm256_and_epi64(var c2da___a_596 : auto; var c2da___b_405 : auto) : auto {
    return c2da___a_596 & c2da___b_405
}
[export]
def _mm256_maskz_and_epi64(var c2da___U_423 : uint8; var c2da___A_714 : auto; var c2da___B_404 : auto) : auto {
    return _mm256_mask_and_epi64(_mm256_setzero_si256(), c2da___U_423, c2da___A_714, c2da___B_404)
}
[export]
def _mm_and_epi64(var c2da___a_597 : auto; var c2da___b_406 : auto) : auto {
    return c2da___a_597 & c2da___b_406
}
[export]
def _mm_maskz_and_epi64(var c2da___U_425 : uint8; var c2da___A_716 : auto; var c2da___B_406 : auto) : auto {
    return _mm_mask_and_epi64(_mm_setzero_si128(), c2da___U_425, c2da___A_716, c2da___B_406)
}
[export]
def _mm256_andnot_epi64(var c2da___A_717 : auto; var c2da___B_407 : auto) : auto {
    return ~c2da___A_717 & c2da___B_407
}
[export]
def _mm256_maskz_andnot_epi64(var c2da___U_427 : uint8; var c2da___A_719 : auto; var c2da___B_409 : auto) : auto {
    return _mm256_mask_andnot_epi64(_mm256_setzero_si256(), c2da___U_427, c2da___A_719, c2da___B_409)
}
[export]
def _mm_andnot_epi64(var c2da___A_720 : auto; var c2da___B_410 : auto) : auto {
    return ~c2da___A_720 & c2da___B_410
}
[export]
def _mm_maskz_andnot_epi64(var c2da___U_429 : uint8; var c2da___A_722 : auto; var c2da___B_412 : auto) : auto {
    return _mm_mask_andnot_epi64(_mm_setzero_si128(), c2da___U_429, c2da___A_722, c2da___B_412)
}
[export]
def _mm256_or_epi64(var c2da___a_598 : auto; var c2da___b_407 : auto) : auto {
    return c2da___a_598 | c2da___b_407
}
[export]
def _mm256_maskz_or_epi64(var c2da___U_431 : uint8; var c2da___A_724 : auto; var c2da___B_414 : auto) : auto {
    return _mm256_mask_or_epi64(_mm256_setzero_si256(), c2da___U_431, c2da___A_724, c2da___B_414)
}
[export]
def _mm_or_epi64(var c2da___a_599 : auto; var c2da___b_408 : auto) : auto {
    return c2da___a_599 | c2da___b_408
}
[export]
def _mm_maskz_or_epi64(var c2da___U_433 : uint8; var c2da___A_726 : auto; var c2da___B_416 : auto) : auto {
    return _mm_mask_or_epi64(_mm_setzero_si128(), c2da___U_433, c2da___A_726, c2da___B_416)
}
[export]
def _mm256_xor_epi64(var c2da___a_600 : auto; var c2da___b_409 : auto) : auto {
    return c2da___a_600 ^ c2da___b_409
}
[export]
def _mm256_maskz_xor_epi64(var c2da___U_435 : uint8; var c2da___A_728 : auto; var c2da___B_418 : auto) : auto {
    return _mm256_mask_xor_epi64(_mm256_setzero_si256(), c2da___U_435, c2da___A_728, c2da___B_418)
}
[export]
def _mm_xor_epi64(var c2da___a_601 : auto; var c2da___b_410 : auto) : auto {
    return c2da___a_601 ^ c2da___b_410
}
[export]
def _mm_maskz_xor_epi64(var c2da___U_437 : uint8; var c2da___A_730 : auto; var c2da___B_420 : auto) : auto {
    return _mm_mask_xor_epi64(_mm_setzero_si128(), c2da___U_437, c2da___A_730, c2da___B_420)
}
[export]
def _mm_load_epi32(var c2da___P_100 : uint64) : auto {
    return *c2da___P_100
}
[export]
def _mm256_load_epi32(var c2da___P_103 : uint64) : auto {
    return *c2da___P_103
}
[export]
def _mm_store_epi32(var c2da___P_106 : uint64; var c2da___A_1173 : auto) {
    *c2da___P_106 = c2da___A_1173
    return
}
[export]
def _mm256_store_epi32(var c2da___P_108 : uint64; var c2da___A_1175 : auto) {
    *c2da___P_108 = c2da___A_1175
    return
}
[export]
def _mm_load_epi64(var c2da___P_110 : uint64) : auto {
    return *c2da___P_110
}
[export]
def _mm256_load_epi64(var c2da___P_113 : uint64) : auto {
    return *c2da___P_113
}
[export]
def _mm_store_epi64(var c2da___P_116 : uint64; var c2da___A_1181 : auto) {
    *c2da___P_116 = c2da___A_1181
    return
}
[export]
def _mm256_store_epi64(var c2da___P_118 : uint64; var c2da___A_1183 : auto) {
    *c2da___P_118 = c2da___A_1183
    return
}
[export]
def _mm_loadu_epi64(var c2da___P_128 : uint64) : auto {
    return c2da___P_128.c2da___v
}
[export]
def _mm256_loadu_epi64(var c2da___P_131 : uint64) : auto {
    return c2da___P_131.c2da___v
}
[export]
def _mm_loadu_epi32(var c2da___P_134 : uint64) : auto {
    return c2da___P_134.c2da___v
}
[export]
def _mm256_loadu_epi32(var c2da___P_137 : uint64) : auto {
    return c2da___P_137.c2da___v
}
[export]
def _mm_storeu_epi64(var c2da___P_152 : uint64; var c2da___A_1201 : auto) {
    c2da___P_152.c2da___v = c2da___A_1201
    return
}
[export]
def _mm256_storeu_epi64(var c2da___P_154 : uint64; var c2da___A_1203 : auto) {
    c2da___P_154.c2da___v = c2da___A_1203
    return
}
[export]
def _mm_storeu_epi32(var c2da___P_156 : uint64; var c2da___A_1205 : auto) {
    c2da___P_156.c2da___v = c2da___A_1205
    return
}
[export]
def _mm256_storeu_epi32(var c2da___P_158 : uint64; var c2da___A_1207 : auto) {
    c2da___P_158.c2da___v = c2da___A_1207
    return
}
[export]
def _mm512_add_epi8(var c2da___A_1505 : auto; var c2da___B_769 : auto) : auto {
    return c2da___A_1505 + c2da___B_769
}
[export]
def _mm512_sub_epi8(var c2da___A_1508 : auto; var c2da___B_772 : auto) : auto {
    return c2da___A_1508 - c2da___B_772
}
[export]
def _mm512_add_epi16(var c2da___A_1511 : auto; var c2da___B_775 : auto) : auto {
    return c2da___A_1511 + c2da___B_775
}
[export]
def _mm512_sub_epi16(var c2da___A_1514 : auto; var c2da___B_778 : auto) : auto {
    return c2da___A_1514 - c2da___B_778
}
[export]
def _mm512_mullo_epi16(var c2da___A_1517 : auto; var c2da___B_781 : auto) : auto {
    return c2da___A_1517 * c2da___B_781
}
[export]
def _mm512_loadu_epi16(var c2da___P_197 : uint64) : auto {
    return c2da___P_197.c2da___v
}
[export]
def _mm512_loadu_epi8(var c2da___P_200 : uint64) : auto {
    return c2da___P_200.c2da___v
}
[export]
def _mm512_storeu_epi16(var c2da___P_203 : uint64; var c2da___A_1678 : auto) {
    c2da___P_203.c2da___v = c2da___A_1678
    return
}
[export]
def _mm512_storeu_epi8(var c2da___P_205 : uint64; var c2da___A_1680 : auto) {
    c2da___P_205.c2da___v = c2da___A_1680
    return
}
[export]
def _mm512_maskz_popcnt_epi16(var c2da___U_1106 : uint; var c2da___B_923 : auto) : auto {
    return _mm512_mask_popcnt_epi16(_mm512_setzero_si512(), c2da___U_1106, c2da___B_923)
}
[export]
def _mm512_maskz_popcnt_epi8(var c2da___U_1108 : uint64; var c2da___B_925 : auto) : auto {
    return _mm512_mask_popcnt_epi8(_mm512_setzero_si512(), c2da___U_1108, c2da___B_925)
}
[export]
def _mm512_bitshuffle_epi64_mask(var c2da___A_1711 : auto; var c2da___B_927 : auto) : uint64 {
    return _mm512_mask_bitshuffle_epi64_mask(uint64(-1), c2da___A_1711, c2da___B_927)
}
[export]
def _mm512_broadcastmb_epi64(var c2da___A_1724 : uint8) : auto {
    return _mm512_set1_epi64(int64(c2da___A_1724))
}
[export]
def _mm512_broadcastmw_epi32(var c2da___A_1725 : int) : auto {
    return _mm512_set1_epi32(c2da___A_1725)
}
[export]
def _mm512_maskz_popcnt_epi64(var c2da___U_1119 : uint8; var c2da___A_1728 : auto) : auto {
    return _mm512_mask_popcnt_epi64(_mm512_setzero_si512(), c2da___U_1119, c2da___A_1728)
}
[export]
def _mm512_maskz_popcnt_epi32(var c2da___U_1121 : int; var c2da___A_1731 : auto) : auto {
    return _mm512_mask_popcnt_epi32(_mm512_setzero_si512(), c2da___U_1121, c2da___A_1731)
}
[export]
def _mm_maskz_popcnt_epi64(var c2da___U_1123 : uint8; var c2da___A_1734 : auto) : auto {
    return _mm_mask_popcnt_epi64(_mm_setzero_si128(), c2da___U_1123, c2da___A_1734)
}
[export]
def _mm_maskz_popcnt_epi32(var c2da___U_1125 : uint8; var c2da___A_1737 : auto) : auto {
    return _mm_mask_popcnt_epi32(_mm_setzero_si128(), c2da___U_1125, c2da___A_1737)
}
[export]
def _mm256_maskz_popcnt_epi64(var c2da___U_1127 : uint8; var c2da___A_1740 : auto) : auto {
    return _mm256_mask_popcnt_epi64(_mm256_setzero_si256(), c2da___U_1127, c2da___A_1740)
}
[export]
def _mm256_maskz_popcnt_epi32(var c2da___U_1129 : uint8; var c2da___A_1743 : auto) : auto {
    return _mm256_mask_popcnt_epi32(_mm256_setzero_si256(), c2da___U_1129, c2da___A_1743)
}
[export]
def _mm512_mullo_epi64(var c2da___A_1800 : auto; var c2da___B_981 : auto) : auto {
    return c2da___A_1800 * c2da___B_981
}
[export]
def _mm512_xor_pd(var c2da___A_1803 : auto; var c2da___B_984 : auto) : auto {
    return c2da___A_1803 ^ c2da___B_984
}
[export]
def _mm512_xor_ps(var c2da___A_1806 : auto; var c2da___B_987 : auto) : auto {
    return c2da___A_1806 ^ c2da___B_987
}
[export]
def _mm512_or_pd(var c2da___A_1809 : auto; var c2da___B_990 : auto) : auto {
    return c2da___A_1809 | c2da___B_990
}
[export]
def _mm512_or_ps(var c2da___A_1812 : auto; var c2da___B_993 : auto) : auto {
    return c2da___A_1812 | c2da___B_993
}
[export]
def _mm512_and_pd(var c2da___A_1815 : auto; var c2da___B_996 : auto) : auto {
    return c2da___A_1815 & c2da___B_996
}
[export]
def _mm512_and_ps(var c2da___A_1818 : auto; var c2da___B_999 : auto) : auto {
    return c2da___A_1818 & c2da___B_999
}
[export]
def _mm512_andnot_pd(var c2da___A_1821 : auto; var c2da___B_1002 : auto) : auto {
    return ~c2da___A_1821 & c2da___B_1002
}
[export]
def _mm512_andnot_ps(var c2da___A_1824 : auto; var c2da___B_1005 : auto) : auto {
    return ~c2da___A_1824 & c2da___B_1005
}
[export]
def _mm256_maskz_popcnt_epi16(var c2da___U_1197 : int; var c2da___B_1009 : auto) : auto {
    return _mm256_mask_popcnt_epi16(_mm256_setzero_si256(), c2da___U_1197, c2da___B_1009)
}
[export]
def _mm_maskz_popcnt_epi16(var c2da___U_1199 : uint8; var c2da___B_1011 : auto) : auto {
    return _mm_mask_popcnt_epi16(_mm_setzero_si128(), c2da___U_1199, c2da___B_1011)
}
[export]
def _mm256_maskz_popcnt_epi8(var c2da___U_1201 : uint; var c2da___B_1013 : auto) : auto {
    return _mm256_mask_popcnt_epi8(_mm256_setzero_si256(), c2da___U_1201, c2da___B_1013)
}
[export]
def _mm_maskz_popcnt_epi8(var c2da___U_1203 : int; var c2da___B_1015 : auto) : auto {
    return _mm_mask_popcnt_epi8(_mm_setzero_si128(), c2da___U_1203, c2da___B_1015)
}
[export]
def _mm256_bitshuffle_epi64_mask(var c2da___A_1894 : auto; var c2da___B_1017 : auto) : uint {
    return _mm256_mask_bitshuffle_epi64_mask(uint(-1), c2da___A_1894, c2da___B_1017)
}
[export]
def _mm_bitshuffle_epi64_mask(var c2da___A_1896 : auto; var c2da___B_1019 : auto) : int {
    return _mm_mask_bitshuffle_epi64_mask(-1, c2da___A_1896, c2da___B_1019)
}
[export]
def _mm_loadu_epi16(var c2da___P_213 : uint64) : auto {
    return c2da___P_213.c2da___v
}
[export]
def _mm256_loadu_epi16(var c2da___P_216 : uint64) : auto {
    return c2da___P_216.c2da___v
}
[export]
def _mm_loadu_epi8(var c2da___P_219 : uint64) : auto {
    return c2da___P_219.c2da___v
}
[export]
def _mm256_loadu_epi8(var c2da___P_222 : uint64) : auto {
    return c2da___P_222.c2da___v
}
[export]
def _mm_storeu_epi16(var c2da___P_225 : uint64; var c2da___A_2143 : auto) {
    c2da___P_225.c2da___v = c2da___A_2143
    return
}
[export]
def _mm256_storeu_epi16(var c2da___P_227 : uint64; var c2da___A_2145 : auto) {
    c2da___P_227.c2da___v = c2da___A_2145
    return
}
[export]
def _mm_storeu_epi8(var c2da___P_229 : uint64; var c2da___A_2147 : auto) {
    c2da___P_229.c2da___v = c2da___A_2147
    return
}
[export]
def _mm256_storeu_epi8(var c2da___P_231 : uint64; var c2da___A_2149 : auto) {
    c2da___P_231.c2da___v = c2da___A_2149
    return
}
[export]
def _mm_broadcastmb_epi64(var c2da___A_2193 : uint8) : auto {
    return _mm_set1_epi64x(int64(c2da___A_2193))
}
[export]
def _mm256_broadcastmb_epi64(var c2da___A_2194 : uint8) : auto {
    return _mm256_set1_epi64x(int64(c2da___A_2194))
}
[export]
def _mm_broadcastmw_epi32(var c2da___A_2195 : int) : auto {
    return _mm_set1_epi32(c2da___A_2195)
}
[export]
def _mm256_broadcastmw_epi32(var c2da___A_2196 : int) : auto {
    return _mm256_set1_epi32(c2da___A_2196)
}
[export]
def _mm256_mullo_epi64(var c2da___A_2221 : auto; var c2da___B_1232 : auto) : auto {
    return c2da___A_2221 * c2da___B_1232
}
[export]
def _mm_mullo_epi64(var c2da___A_2224 : auto; var c2da___B_1235 : auto) : auto {
    return c2da___A_2224 * c2da___B_1235
}
[export]
def _mm512_cvtsh_h(var c2da___a_602 : auto) : auto {
    return unsafe(c2da___a_602[0])
}
[export]
def _mm_setzero_ph() : auto {
    return [cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0))]
}
[export]
def _mm256_setzero_ph() : auto {
    return [cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0))]
}
[export]
def _mm512_setzero_ph() : auto {
    return [cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0))]
}
[export]
def _mm512_set1_ph(var c2da___h_1 : auto) : auto {
    return [c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1, c2da___h_1]
}
[export]
def _mm512_set_ph(var c2da___h1 : auto; var c2da___h2 : auto; var c2da___h3 : auto; var c2da___h4 : auto; var c2da___h5 : auto; var c2da___h6 : auto; var c2da___h7 : auto; var c2da___h8 : auto; var c2da___h9 : auto; var c2da___h10 : auto; var c2da___h11 : auto; var c2da___h12 : auto; var c2da___h13 : auto; var c2da___h14 : auto; var c2da___h15 : auto; var c2da___h16 : auto; var c2da___h17 : auto; var c2da___h18 : auto; var c2da___h19 : auto; var c2da___h20 : auto; var c2da___h21 : auto; var c2da___h22 : auto; var c2da___h23 : auto; var c2da___h24 : auto; var c2da___h25 : auto; var c2da___h26 : auto; var c2da___h27 : auto; var c2da___h28 : auto; var c2da___h29 : auto; var c2da___h30 : auto; var c2da___h31 : auto; var c2da___h32 : auto) : auto {
    return [c2da___h32, c2da___h31, c2da___h30, c2da___h29, c2da___h28, c2da___h27, c2da___h26, c2da___h25, c2da___h24, c2da___h23, c2da___h22, c2da___h21, c2da___h20, c2da___h19, c2da___h18, c2da___h17, c2da___h16, c2da___h15, c2da___h14, c2da___h13, c2da___h12, c2da___h11, c2da___h10, c2da___h9, c2da___h8, c2da___h7, c2da___h6, c2da___h5, c2da___h4, c2da___h3, c2da___h2, c2da___h1]
}
[export]
def _mm512_set1_pch(var h : auto) : auto {
    return _mm512_set1_ps(unsafe(reinterpret<float>(h)))
}
[export]
def _mm_castph_ps(var c2da___a_603 : auto) : auto {
    return c2da___a_603
}
[export]
def _mm256_castph_ps(var c2da___a_604 : auto) : auto {
    return c2da___a_604
}
[export]
def _mm512_castph_ps(var c2da___a_605 : auto) : auto {
    return c2da___a_605
}
[export]
def _mm_castph_pd(var c2da___a_606 : auto) : auto {
    return c2da___a_606
}
[export]
def _mm256_castph_pd(var c2da___a_607 : auto) : auto {
    return c2da___a_607
}
[export]
def _mm512_castph_pd(var c2da___a_608 : auto) : auto {
    return c2da___a_608
}
[export]
def _mm_castph_si128(var c2da___a_609 : auto) : auto {
    return c2da___a_609
}
[export]
def _mm256_castph_si256(var c2da___a_610 : auto) : auto {
    return c2da___a_610
}
[export]
def _mm512_castph_si512(var c2da___a_611 : auto) : auto {
    return c2da___a_611
}
[export]
def _mm_castps_ph(var c2da___a_612 : auto) : auto {
    return c2da___a_612
}
[export]
def _mm256_castps_ph(var c2da___a_613 : auto) : auto {
    return c2da___a_613
}
[export]
def _mm512_castps_ph(var c2da___a_614 : auto) : auto {
    return c2da___a_614
}
[export]
def _mm_castpd_ph(var c2da___a_615 : auto) : auto {
    return c2da___a_615
}
[export]
def _mm256_castpd_ph(var c2da___a_616 : auto) : auto {
    return c2da___a_616
}
[export]
def _mm512_castpd_ph(var c2da___a_617 : auto) : auto {
    return c2da___a_617
}
[export]
def _mm_castsi128_ph(var c2da___a_618 : auto) : auto {
    return c2da___a_618
}
[export]
def _mm256_castsi256_ph(var c2da___a_619 : auto) : auto {
    return c2da___a_619
}
[export]
def _mm512_castsi512_ph(var c2da___a_620 : auto) : auto {
    return c2da___a_620
}
[export]
def _mm512_add_ph(var c2da___A_2429 : auto; var c2da___B_1345 : auto) : auto {
    return c2da___A_2429 + c2da___B_1345
}
[export]
def _mm512_sub_ph(var c2da___A_2432 : auto; var c2da___B_1348 : auto) : auto {
    return c2da___A_2432 - c2da___B_1348
}
[export]
def _mm512_mul_ph(var c2da___A_2435 : auto; var c2da___B_1351 : auto) : auto {
    return c2da___A_2435 * c2da___B_1351
}
[export]
def _mm512_div_ph(var c2da___A_2438 : auto; var c2da___B_1354 : auto) : auto {
    return c2da___A_2438 / c2da___B_1354
}
[export]
def _mm512_abs_ph(var c2da___A_2447 : auto) : auto {
    return _mm512_and_epi32(_mm512_set1_epi32(2147450879), c2da___A_2447)
}
[export]
def _mm512_conj_pch(var c2da___A_2448 : auto) : auto {
    return _mm512_xor_ps(c2da___A_2448, _mm512_set1_ps(-double(0.0)))
}
[export]
def _mm_add_sh(var c2da___A_2451 : auto; var c2da___B_1363 : auto) : auto {
    unsafe(c2da___A_2451[0]) = unsafe(c2da___A_2451[0]) + unsafe(c2da___B_1363[0])
    return c2da___A_2451
}
[export]
def _mm_sub_sh(var c2da___A_2454 : auto; var c2da___B_1366 : auto) : auto {
    unsafe(c2da___A_2454[0]) = unsafe(c2da___A_2454[0]) - unsafe(c2da___B_1366[0])
    return c2da___A_2454
}
[export]
def _mm_mul_sh(var c2da___A_2457 : auto; var c2da___B_1369 : auto) : auto {
    unsafe(c2da___A_2457[0]) = unsafe(c2da___A_2457[0]) * unsafe(c2da___B_1369[0])
    return c2da___A_2457
}
[export]
def _mm_div_sh(var c2da___A_2460 : auto; var c2da___B_1372 : auto) : auto {
    unsafe(c2da___A_2460[0]) = unsafe(c2da___A_2460[0]) / unsafe(c2da___B_1372[0])
    return c2da___A_2460
}
[export]
def _mm_load_sh(var c2da___dp_14 : uint64) : auto {
    var c2da___u_9 : auto = cast<auto>(0)
    c2da___u_9 = c2da___dp_14.c2da___u
    return [c2da___u_9, cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0)]
}
[export]
def _mm512_load_ph(var c2da___p_61 : uint64) : auto {
    return *c2da___p_61
}
[export]
def _mm256_load_ph(var c2da___p_62 : uint64) : auto {
    return *c2da___p_62
}
[export]
def _mm_load_ph(var c2da___p_63 : uint64) : auto {
    return *c2da___p_63
}
[export]
def _mm512_loadu_ph(var c2da___p_64 : uint64) : auto {
    return c2da___p_64.c2da___v
}
[export]
def _mm256_loadu_ph(var c2da___p_65 : uint64) : auto {
    return c2da___p_65.c2da___v
}
[export]
def _mm_loadu_ph(var c2da___p_66 : uint64) : auto {
    return c2da___p_66.c2da___v
}
[export]
def _mm_store_sh(var c2da___dp_15 : uint64; var c2da___a_630 : auto) {
    c2da___dp_15.c2da___u = unsafe(c2da___a_630[0])
    return
}
[export]
def _mm512_store_ph(var c2da___P_251 : uint64; var c2da___A_2472 : auto) {
    *c2da___P_251 = c2da___A_2472
    return
}
[export]
def _mm256_store_ph(var c2da___P_252 : uint64; var c2da___A_2473 : auto) {
    *c2da___P_252 = c2da___A_2473
    return
}
[export]
def _mm_store_ph(var c2da___P_253 : uint64; var c2da___A_2474 : auto) {
    *c2da___P_253 = c2da___A_2474
    return
}
[export]
def _mm512_storeu_ph(var c2da___P_254 : uint64; var c2da___A_2475 : auto) {
    c2da___P_254.c2da___v = c2da___A_2475
    return
}
[export]
def _mm256_storeu_ph(var c2da___P_255 : uint64; var c2da___A_2476 : auto) {
    c2da___P_255.c2da___v = c2da___A_2476
    return
}
[export]
def _mm_storeu_ph(var c2da___P_256 : uint64; var c2da___A_2477 : auto) {
    c2da___P_256.c2da___v = c2da___A_2477
    return
}
[export]
def _mm_move_sh(var c2da___a_631 : auto; var c2da___b_412 : auto) : auto {
    unsafe(c2da___a_631[0]) = unsafe(c2da___b_412[0])
    return c2da___a_631
}
[export]
def _mm_cvtsi16_si128(var c2da___a_632 : int) : auto {
    return [c2da___a_632, 0, 0, 0, 0, 0, 0, 0]
}
[export]
def _mm_cvtsi128_si16(var c2da___a_633 : auto) : int {
    var c2da___b_413 : auto = cast<auto>(0)
    c2da___b_413 = c2da___a_633
    return unsafe(c2da___b_413[0])
}
[export]
def _mm_cvtu32_sh(var c2da___A_2586 : auto; var c2da___B_1413 : uint) : auto {
    unsafe(c2da___A_2586[0]) = cast<auto>(c2da___B_1413)
    return c2da___A_2586
}
[export]
def _mm_cvtu64_sh(var c2da___A_2587 : auto; var c2da___B_1414 : uint64) : auto {
    unsafe(c2da___A_2587[0]) = cast<auto>(c2da___B_1414)
    return c2da___A_2587
}
[export]
def _mm_cvti32_sh(var c2da___A_2588 : auto; var c2da___B_1415 : int) : auto {
    unsafe(c2da___A_2588[0]) = cast<auto>(c2da___B_1415)
    return c2da___A_2588
}
[export]
def _mm_cvti64_sh(var c2da___A_2589 : auto; var c2da___B_1416 : int64) : auto {
    unsafe(c2da___A_2589[0]) = cast<auto>(c2da___B_1416)
    return c2da___A_2589
}
[export]
def _mm_cvtsh_h(var c2da___a_634 : auto) : auto {
    return unsafe(c2da___a_634[0])
}
[export]
def _mm256_cvtsh_h(var c2da___a_635 : auto) : auto {
    return unsafe(c2da___a_635[0])
}
[export]
def _mm_set_sh(var c2da___h_2 : auto) : auto {
    return [c2da___h_2, cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0)]
}
[export]
def _mm_set1_ph(var c2da___h_3 : auto) : auto {
    return [c2da___h_3, c2da___h_3, c2da___h_3, c2da___h_3, c2da___h_3, c2da___h_3, c2da___h_3, c2da___h_3]
}
[export]
def _mm256_set1_ph(var c2da___h_4 : auto) : auto {
    return [c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4, c2da___h_4]
}
[export]
def _mm_set_ph(var c2da___h1_0 : auto; var c2da___h2_0 : auto; var c2da___h3_0 : auto; var c2da___h4_0 : auto; var c2da___h5_0 : auto; var c2da___h6_0 : auto; var c2da___h7_0 : auto; var c2da___h8_0 : auto) : auto {
    return [c2da___h8_0, c2da___h7_0, c2da___h6_0, c2da___h5_0, c2da___h4_0, c2da___h3_0, c2da___h2_0, c2da___h1_0]
}
[export]
def _mm256_set1_pch(var h_0 : auto) : auto {
    return _mm256_set1_ps(unsafe(reinterpret<float>(h_0)))
}
[export]
def _mm_set1_pch(var h_1 : auto) : auto {
    return _mm_set1_ps(unsafe(reinterpret<float>(h_1)))
}
[export]
def _mm256_set_ph(var c2da___h1_1 : auto; var c2da___h2_1 : auto; var c2da___h3_1 : auto; var c2da___h4_1 : auto; var c2da___h5_1 : auto; var c2da___h6_1 : auto; var c2da___h7_1 : auto; var c2da___h8_1 : auto; var c2da___h9_0 : auto; var c2da___h10_0 : auto; var c2da___h11_0 : auto; var c2da___h12_0 : auto; var c2da___h13_0 : auto; var c2da___h14_0 : auto; var c2da___h15_0 : auto; var c2da___h16_0 : auto) : auto {
    return [c2da___h16_0, c2da___h15_0, c2da___h14_0, c2da___h13_0, c2da___h12_0, c2da___h11_0, c2da___h10_0, c2da___h9_0, c2da___h8_1, c2da___h7_1, c2da___h6_1, c2da___h5_1, c2da___h4_1, c2da___h3_1, c2da___h2_1, c2da___h1_1]
}
[export]
def _mm256_add_ph(var c2da___A_2667 : auto; var c2da___B_1483 : auto) : auto {
    return c2da___A_2667 + c2da___B_1483
}
[export]
def _mm_add_ph(var c2da___A_2670 : auto; var c2da___B_1486 : auto) : auto {
    return c2da___A_2670 + c2da___B_1486
}
[export]
def _mm256_sub_ph(var c2da___A_2673 : auto; var c2da___B_1489 : auto) : auto {
    return c2da___A_2673 - c2da___B_1489
}
[export]
def _mm_sub_ph(var c2da___A_2676 : auto; var c2da___B_1492 : auto) : auto {
    return c2da___A_2676 - c2da___B_1492
}
[export]
def _mm256_mul_ph(var c2da___A_2679 : auto; var c2da___B_1495 : auto) : auto {
    return c2da___A_2679 * c2da___B_1495
}
[export]
def _mm_mul_ph(var c2da___A_2682 : auto; var c2da___B_1498 : auto) : auto {
    return c2da___A_2682 * c2da___B_1498
}
[export]
def _mm256_div_ph(var c2da___A_2685 : auto; var c2da___B_1501 : auto) : auto {
    return c2da___A_2685 / c2da___B_1501
}
[export]
def _mm_div_ph(var c2da___A_2688 : auto; var c2da___B_1504 : auto) : auto {
    return c2da___A_2688 / c2da___B_1504
}
[export]
def _mm256_abs_ph(var c2da___A_2703 : auto) : auto {
    return _mm256_and_epi32(_mm256_set1_epi32(2147450879), c2da___A_2703)
}
[export]
def _mm_abs_ph(var c2da___A_2704 : auto) : auto {
    return _mm_and_epi32(_mm_set1_epi32(2147450879), c2da___A_2704)
}
[export]
def _mm256_conj_pch(var c2da___A_2705 : auto) : auto {
    return _mm256_xor_ps(c2da___A_2705, _mm256_set1_ps(-double(0.0)))
}
[export]
def _mm_conj_pch(var c2da___A_2708 : auto) : auto {
    return _mm_xor_ps(c2da___A_2708, _mm_set1_ps(-double(0.0)))
}
[export]
def _mm512_cvtpbh_ps(var c2da___A_2963 : auto) : auto {
    return _mm512_castsi512_ps(_mm512_slli_epi32(_mm512_cvtepi16_epi32(c2da___A_2963), uint(16)))
}
[export]
def _mm512_maskz_cvtpbh_ps(var c2da___U_1937 : int; var c2da___A_2964 : auto) : auto {
    return _mm512_castsi512_ps(_mm512_slli_epi32(_mm512_maskz_cvtepi16_epi32(c2da___U_1937, c2da___A_2964), uint(16)))
}
[export]
def _mm512_mask_cvtpbh_ps(var c2da___S_53 : auto; var c2da___U_1938 : int; var c2da___A_2965 : auto) : auto {
    return _mm512_castsi512_ps(_mm512_mask_slli_epi32(c2da___S_53, c2da___U_1938, _mm512_cvtepi16_epi32(c2da___A_2965), uint(16)))
}
[export]
def _mm_cvtpbh_ps(var c2da___A_2983 : auto) : auto {
    return _mm_castsi128_ps(_mm_slli_epi32(_mm_cvtepi16_epi32(c2da___A_2983), 16))
}
[export]
def _mm256_cvtpbh_ps(var c2da___A_2984 : auto) : auto {
    return _mm256_castsi256_ps(_mm256_slli_epi32(_mm256_cvtepi16_epi32(c2da___A_2984), 16))
}
[export]
def _mm_maskz_cvtpbh_ps(var c2da___U_1951 : uint8; var c2da___A_2985 : auto) : auto {
    return _mm_castsi128_ps(_mm_slli_epi32(_mm_maskz_cvtepi16_epi32(c2da___U_1951, c2da___A_2985), 16))
}
[export]
def _mm256_maskz_cvtpbh_ps(var c2da___U_1952 : uint8; var c2da___A_2986 : auto) : auto {
    return _mm256_castsi256_ps(_mm256_slli_epi32(_mm256_maskz_cvtepi16_epi32(c2da___U_1952, c2da___A_2986), 16))
}
[export]
def _mm_mask_cvtpbh_ps(var c2da___S_54 : auto; var c2da___U_1953 : uint8; var c2da___A_2987 : auto) : auto {
    return _mm_castsi128_ps(_mm_mask_slli_epi32(c2da___S_54, c2da___U_1953, _mm_cvtepi16_epi32(c2da___A_2987), uint(16)))
}
[export]
def _mm256_mask_cvtpbh_ps(var c2da___S_55 : auto; var c2da___U_1954 : uint8; var c2da___A_2988 : auto) : auto {
    return _mm256_castsi256_ps(_mm256_mask_slli_epi32(c2da___S_55, c2da___U_1954, _mm256_cvtepi16_epi32(c2da___A_2988), uint(16)))
}
[export]
def _mm512_maskz_gf2p8mul_epi8(var c2da___U_1956 : uint64; var c2da___A_3001 : auto; var c2da___B_1635 : auto) : auto {
    return _mm512_mask_gf2p8mul_epi8(_mm512_setzero_si512(), c2da___U_1956, c2da___A_3001, c2da___B_1635)
}
[export]
def _mm_maskz_gf2p8mul_epi8(var c2da___U_1958 : int; var c2da___A_3003 : auto; var c2da___B_1637 : auto) : auto {
    return _mm_mask_gf2p8mul_epi8(_mm_setzero_si128(), c2da___U_1958, c2da___A_3003, c2da___B_1637)
}
[export]
def _mm256_maskz_gf2p8mul_epi8(var c2da___U_1960 : uint; var c2da___A_3005 : auto; var c2da___B_1639 : auto) : auto {
    return _mm256_mask_gf2p8mul_epi8(_mm256_setzero_si256(), c2da___U_1960, c2da___A_3005, c2da___B_1639)
}
[export]
def _loadbe_i16(var c2da___P_257 : uint64) : int {
    return 0
}
[export]
def _storebe_i16(var c2da___P_258 : uint64; var c2da___D_50 : int) {
    c2da___P_258.c2da___v = int(0)
    return
}
[export]
def _loadbe_i32(var c2da___P_259 : uint64) : int {
    return int(0)
}
[export]
def _storebe_i32(var c2da___P_260 : uint64; var c2da___D_51 : int) {
    c2da___P_260.c2da___v = uint(0)
    return
}
[export]
def _loadbe_i64(var c2da___P_261 : uint64) : int64 {
    return int64(0)
}
[export]
def _storebe_i64(var c2da___P_262 : uint64; var c2da___D_52 : int64) {
    c2da___P_262.c2da___v = uint64(0)
    return
}
[export]
def c2da___tile_loadd(var dst_5 : c2da___tile1024i_str?; var base_2 : uint64; var stride_2 : uint64) {
    dst_5.tile = _tile_loadd_internal(dst_5.row, dst_5.col, base_2, stride_2)
    return
}
[export]
def c2da___tile_stream_loadd(var dst_6 : c2da___tile1024i_str?; var base_3 : uint64; var stride_3 : uint64) {
    dst_6.tile = _tile_loaddt1_internal(dst_6.row, dst_6.col, base_3, stride_3)
    return
}
[export]
def c2da___tile_dpbssd(var dst_7 : c2da___tile1024i_str?; var src0 : c2da___tile1024i_str; var src1_5 : c2da___tile1024i_str) {
    dst_7.tile = _tile_dpbssd_internal(src0.row, src1_5.col, src0.col, dst_7.tile, src0.tile, src1_5.tile)
    return
}
[export]
def c2da___tile_dpbsud(var dst_8 : c2da___tile1024i_str?; var src0_0 : c2da___tile1024i_str; var src1_6 : c2da___tile1024i_str) {
    dst_8.tile = _tile_dpbsud_internal(src0_0.row, src1_6.col, src0_0.col, dst_8.tile, src0_0.tile, src1_6.tile)
    return
}
[export]
def c2da___tile_dpbusd(var dst_9 : c2da___tile1024i_str?; var src0_1 : c2da___tile1024i_str; var src1_7 : c2da___tile1024i_str) {
    dst_9.tile = _tile_dpbusd_internal(src0_1.row, src1_7.col, src0_1.col, dst_9.tile, src0_1.tile, src1_7.tile)
    return
}
[export]
def c2da___tile_dpbuud(var dst_10 : c2da___tile1024i_str?; var src0_2 : c2da___tile1024i_str; var src1_8 : c2da___tile1024i_str) {
    dst_10.tile = _tile_dpbuud_internal(src0_2.row, src1_8.col, src0_2.col, dst_10.tile, src0_2.tile, src1_8.tile)
    return
}
[export]
def c2da___tile_stored(var base_4 : uint64; var stride_4 : uint64; var src_2 : c2da___tile1024i_str) {
    _tile_stored_internal(src_2.row, src_2.col, base_4, stride_4, src_2.tile)
    return
}
[export]
def c2da___tile_dpbf16ps(var dst_12 : c2da___tile1024i_str?; var src0_3 : c2da___tile1024i_str; var src1_9 : c2da___tile1024i_str) {
    dst_12.tile = _tile_dpbf16ps_internal(src0_3.row, src1_9.col, src0_3.col, dst_12.tile, src0_3.tile, src1_9.tile)
    return
}
[export]
def c2da___tile_dpfp16ps(var dst_13 : c2da___tile1024i_str?; var src0_4 : c2da___tile1024i_str; var src1_10 : c2da___tile1024i_str) {
    dst_13.tile = _tile_dpfp16ps_internal(src0_4.row, src1_10.col, src0_4.col, dst_13.tile, src0_4.tile, src1_10.tile)
    return
}
[export]
def c2da___tile_cmmimfp16ps(var dst_16 : c2da___tile1024i_str?; var src0_5 : c2da___tile1024i_str; var src1_13 : c2da___tile1024i_str) {
    dst_16.tile = _tile_cmmimfp16ps_internal(src0_5.row, src1_13.col, src0_5.col, dst_16.tile, src0_5.tile, src1_13.tile)
    return
}
[export]
def c2da___tile_cmmrlfp16ps(var dst_17 : c2da___tile1024i_str?; var src0_6 : c2da___tile1024i_str; var src1_14 : c2da___tile1024i_str) {
    dst_17.tile = _tile_cmmrlfp16ps_internal(src0_6.row, src1_14.col, src0_6.col, dst_17.tile, src0_6.tile, src1_14.tile)
    return
}
[export]
def unpack_128_2x128(var data : auto; var data_lo : auto?; var data_hi : auto?) {
    *data_lo = _mm_unpacklo_epi8(data, _mm_setzero_si128())
    *data_hi = _mm_unpackhi_epi8(data, _mm_setzero_si128())
    return
}
[export]
def zero_init_all() {
    var a : auto = cast<auto>(0)
    var b : auto = cast<auto>(0)
    var c : auto = cast<auto>(0)
    var d : auto = cast<auto>(0)
    var ep : auto = cast<auto>(0)
    var e : auto = cast<auto>(0)
    var f : auto = cast<auto>(0)
    return
}
[export]
def vector_init_lists() : VectorInitLists {
    var il : VectorInitLists = VectorInitLists()
    il = VectorInitLists(a = [double(1.2999999523162842), double(2.299999952316284), double(3.4000000953674316), double(4.400000095367432)], b = [double(2.200000047683716), double(4.400000095367432), double(5.599999904632568), double(4.300000190734863), double(6.699999809265137), double(6.599999904632568), double(5.5), double(8.800000190734863)], c = [double(2.2), double(4.4)], d = [double(2.2), double(3.3), double(4.4), double(5.5)], e = [45, 32], f = [12, 34, 56, 78])
    return il
}
[export]
def vector_init_lists_used() : VectorInitLists {
    var a_1 : auto = cast<auto>(0)
    var b_2 : auto = cast<auto>(0)
    var c_1 : auto = cast<auto>(0)
    var d_2 : auto = cast<auto>(0)
    var e_2 : auto = cast<auto>(0)
    var f_2 : auto = cast<auto>(0)
    var il_0 : VectorInitLists = VectorInitLists()
    a_1 = [double(1.2999999523162842), double(2.299999952316284), double(3.4000000953674316), double(4.400000095367432)]
    b_2 = [double(2.200000047683716), double(4.400000095367432), double(5.599999904632568), double(4.300000190734863), double(6.699999809265137), double(6.599999904632568), double(5.5), double(8.800000190734863)]
    c_1 = [double(2.2), double(4.4)]
    d_2 = [double(2.2), double(3.3), double(4.4), double(5.5)]
    e_2 = [45, 32]
    f_2 = [12, 34, 56, 78]
    il_0 = VectorInitLists(a = a_1, b = b_2, c = c_1, d = d_2, e = e_2, f = f_2)
    return il_0
}
var static_m128 : auto = [double(1.2999999523162842), double(2.299999952316284), double(3.4000000953674316), double(4.400000095367432)]

var static_m256 : auto = [double(2.200000047683716), double(4.400000095367432), double(5.599999904632568), double(4.300000190734863), double(6.699999809265137), double(6.599999904632568), double(5.5), double(8.800000190734863)]

var static_m128d : auto = [double(2.2), double(4.4)]

var static_m256d : auto = [double(2.2), double(3.3), double(4.4), double(5.5)]

var static_m128i : auto = [45, 32]

var static_m256i : auto = [12, 34, 56, 78]

var static_uninit_m128 : auto

var static_uninit_m256 : auto

var static_uninit_m128d : auto

var static_uninit_m256d : auto

var static_uninit_m128i : auto

var static_uninit_m256i : auto

var _MM_CMPINT_NLE : int = 6

var _MM_CMPINT_NLT : int = 5

var _MM_CMPINT_NE : int = 4

var _MM_CMPINT_UNUSED : int = 3

var _MM_CMPINT_LE : int = 2

var _MM_CMPINT_LT : int = 1

var _MM_CMPINT_EQ : int = 0
[export] def main() : int {
    return 0
}
