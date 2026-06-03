options gen2

struct __mm_loadh_pi_struct {
    __u : __mm_loadh_pi_v2f32
}
struct __mm_loadl_pi_struct {
    __u : __mm_loadl_pi_v2f32
}
struct __mm_load_ss_struct {
    __u : float
}
struct __mm_load1_ps_struct {
    __u : float
}
struct __loadu_ps {
    __v : __m128_u
}
struct __mm_storeh_pi_struct {
    __u : __mm_storeh_pi_v2f32
}
struct __mm_storeh_pi_struct {
    __u : __mm_storeh_pi_v2f32
}
struct __mm_store_ss_struct {
    __u : float
}
struct __storeu_ps {
    __v : __m128_u
}
struct __mm_load1_pd_struct {
    __u : double
}
struct __loadu_pd {
    __v : __m128d_u
}
struct __loadu_si64 {
    __v : int64
}
struct __loadu_si32 {
    __v : int
}
struct __loadu_si16 {
    __v : int
}
struct __mm_load_sd_struct {
    __u : double
}
struct __mm_loadh_pd_struct {
    __u : double
}
struct __mm_loadl_pd_struct {
    __u : double
}
struct __mm_store_sd_struct {
    __u : double
}
struct __storeu_pd {
    __v : __m128d_u
}
struct __mm_storeh_pd_struct {
    __u : double
}
struct __mm_storeh_pd_struct {
    __u : double
}
struct __loadu_si128 {
    __v : __m128i_u
}
struct __mm_loadl_epi64_struct {
    __u : int64
}
struct __storeu_si128 {
    __v : __m128i_u
}
struct __storeu_si64 {
    __v : int64
}
struct __storeu_si32 {
    __v : int
}
struct __storeu_si16 {
    __v : int
}
struct __mm_storel_epi64_struct {
    __u : int64
}
struct __mm_broadcast_ss_struct {
    __f : float
}
struct __mm256_broadcast_sd_struct {
    __d : double
}
struct __mm256_broadcast_ss_struct {
    __f : float
}
struct __loadu_pd {
    __v : __m256d_u
}
struct __loadu_ps {
    __v : __m256_u
}
struct __loadu_si256 {
    __v : __m256i_u
}
struct __storeu_pd {
    __v : __m256d_u
}
struct __storeu_ps {
    __v : __m256_u
}
struct __storeu_si256 {
    __v : __m256i_u
}
struct __loadu_si512 {
    __v : __m512i_u
}
struct __loadu_epi32 {
    __v : __m512i_u
}
struct __loadu_epi64 {
    __v : __m512i_u
}
struct __loadu_pd {
    __v : __m512d_u
}
struct __loadu_ps {
    __v : __m512_u
}
struct __storeu_epi64 {
    __v : __m512i_u
}
struct __storeu_si512 {
    __v : __m512i_u
}
struct __storeu_epi32 {
    __v : __m512i_u
}
struct __storeu_pd {
    __v : __m512d_u
}
struct __storeu_ps {
    __v : __m512_u
}
struct __loadu_epi64 {
    __v : __m128i_u
}
struct __loadu_epi64 {
    __v : __m256i_u
}
struct __loadu_epi32 {
    __v : __m128i_u
}
struct __loadu_epi32 {
    __v : __m256i_u
}
struct __storeu_epi64 {
    __v : __m128i_u
}
struct __storeu_epi64 {
    __v : __m256i_u
}
struct __storeu_epi32 {
    __v : __m128i_u
}
struct __storeu_epi32 {
    __v : __m256i_u
}
struct __loadu_epi16 {
    __v : __m512i_u
}
struct __loadu_epi8 {
    __v : __m512i_u
}
struct __storeu_epi16 {
    __v : __m512i_u
}
struct __storeu_epi8 {
    __v : __m512i_u
}
struct __loadu_epi16 {
    __v : __m128i_u
}
struct __loadu_epi16 {
    __v : __m256i_u
}
struct __loadu_epi8 {
    __v : __m128i_u
}
struct __loadu_epi8 {
    __v : __m256i_u
}
struct __storeu_epi16 {
    __v : __m128i_u
}
struct __storeu_epi16 {
    __v : __m256i_u
}
struct __storeu_epi8 {
    __v : __m128i_u
}
struct __storeu_epi8 {
    __v : __m256i_u
}
struct __mm_load_sh_struct {
    __u : auto
}
struct __loadu_ph {
    __v : __m512h_u
}
struct __loadu_ph {
    __v : __m256h_u
}
struct __loadu_ph {
    __v : __m128h_u
}
struct __mm_store_sh_struct {
    __u : auto
}
struct __storeu_ph {
    __v : __m512h_u
}
struct __storeu_ph {
    __v : __m256h_u
}
struct __storeu_ph {
    __v : __m128h_u
}
struct __loadu_i16 {
    __v : int
}
struct __storeu_i16 {
    __v : int
}
struct __loadu_i32 {
    __v : uint
}
struct __storeu_i32 {
    __v : uint
}
struct __loadu_i64 {
    __v : uint64
}
struct __storeu_i64 {
    __v : uint64
}
struct __tile1024i_str {
    row : int const
    col : int const
    tile : _tile1024i
}
struct ShuffleVectors {
    b : __m128
    c : __m128d
    d : __m256
    e : __m256d
    ep : __m256d
    f : __m128i
    g : __m128i
    h : __m128i
    o : __m128i
    m : __m128i
    r : __m128i
}
struct VectorInitLists {
    a : __m128
    b : __m256
    c : __m128d
    d : __m256d
    e : __m128i
    f : __m256i
}
def _mm_cvtsi64_m64(var _i : int64) : __m64 {
    return cast<__m64>(__i)
}
def _mm_cvtm64_si64(var _m : __m64) : int64 {
    return cast<int64>(__m)
}
def _mm_setzero_si64() : __m64 {
    return [0]
}
def _mm_set1_pi32(var _i : int) : __m64 {
    return _mm_set_pi32(__i, __i)
}
def _mm_set1_pi16(var _w : int) : __m64 {
    return _mm_set_pi16(__w, __w, __w, __w)
}
def _mm_set1_pi8(var _b : int8) : __m64 {
    return _mm_set_pi8(__b, __b, __b, __b, __b, __b, __b, __b)
}
def _mm_setr_pi32(var _i0 : int; var _i1 : int) : __m64 {
    return _mm_set_pi32(__i1, __i0)
}
def _mm_setr_pi16(var _w0 : int; var _w1 : int; var _w2 : int; var _w3 : int) : __m64 {
    return _mm_set_pi16(__w3, __w2, __w1, __w0)
}
def _mm_setr_pi8(var _b0 : int8; var _b1 : int8; var _b2 : int8; var _b3 : int8; var _b4 : int8; var _b5 : int8; var _b6 : int8; var _b7 : int8) : __m64 {
    return _mm_set_pi8(__b7, __b6, __b5, __b4, __b3, __b2, __b1, __b0)
}
def _bswap_16(var _bsx : __uint16_t) : __uint16_t {
    return cast<__uint16_t>(__bsx >> 8 & 255 | __bsx & 255 << 8)
}
def _bswap_32(var _bsx : __uint32_t) : __uint32_t {
    return __bsx & 4278190080 >> 24 | __bsx & 16711680 >> 8 | __bsx & 65280 << 8 | __bsx & 255 << 24
}
def _bswap_64(var _bsx : __uint64_t) : __uint64_t {
    return __bsx & -72057594037927936 >> 56 | __bsx & 71776119061217280 >> 40 | __bsx & 280375465082880 >> 24 | __bsx & 1095216660480 >> 8 | __bsx & 4278190080 << 8 | __bsx & 16711680 << 24 | __bsx & 65280 << 40 | __bsx & 255 << 56
}
def _uint16_identity(var _x : __uint16_t) : __uint16_t {
    return __x
}
def _uint32_identity(var _x : __uint32_t) : __uint32_t {
    return __x
}
def _uint64_identity(var _x : __uint64_t) : __uint64_t {
    return __x
}
def _mm_malloc(var _size : size_t; var _align : size_t) : void? {
    if (__align == 1) {
        return malloc(__size)
    }
    if (!__align & __align - 1 && __align < 4) {
        __align = 4
    }
    var __mallocedMemory : void?
    if (posix_memalign(unsafe(addr(__mallocedMemory)), __align, __size)) {
        return null
    }
    return __mallocedMemory
}
def _mm_free(var _p : void?) {
    free(__p)
}
def _mm_add_ss(var _a : __m128; var _b : __m128) : __m128 {
    __a[0] += __b[0]
    return __a
}
def _mm_add_ps(var _a : __m128; var _b : __m128) : __m128 {
    return cast<__m128>(cast<__v4sf>(__a) + cast<__v4sf>(__b))
}
def _mm_sub_ss(var _a : __m128; var _b : __m128) : __m128 {
    __a[0] -= __b[0]
    return __a
}
def _mm_sub_ps(var _a : __m128; var _b : __m128) : __m128 {
    return cast<__m128>(cast<__v4sf>(__a) - cast<__v4sf>(__b))
}
def _mm_mul_ss(var _a : __m128; var _b : __m128) : __m128 {
    __a[0] *= __b[0]
    return __a
}
def _mm_mul_ps(var _a : __m128; var _b : __m128) : __m128 {
    return cast<__m128>(cast<__v4sf>(__a) * cast<__v4sf>(__b))
}
def _mm_div_ss(var _a : __m128; var _b : __m128) : __m128 {
    __a[0] /= __b[0]
    return __a
}
def _mm_div_ps(var _a : __m128; var _b : __m128) : __m128 {
    return cast<__m128>(cast<__v4sf>(__a) / cast<__v4sf>(__b))
}
def _mm_and_ps(var _a : __m128; var _b : __m128) : __m128 {
    return cast<__m128>(cast<__v4su>(__a) & cast<__v4su>(__b))
}
def _mm_andnot_ps(var _a : __m128; var _b : __m128) : __m128 {
    return cast<__m128>(~cast<__v4su>(__a) & cast<__v4su>(__b))
}
def _mm_or_ps(var _a : __m128; var _b : __m128) : __m128 {
    return cast<__m128>(cast<__v4su>(__a) | cast<__v4su>(__b))
}
def _mm_xor_ps(var _a : __m128; var _b : __m128) : __m128 {
    return cast<__m128>(cast<__v4su>(__a) ^ cast<__v4su>(__b))
}
def _mm_cvt_ss2si(var _a : __m128) : int {
    return _mm_cvtss_si32(__a)
}
def _mm_cvt_ps2pi(var _a : __m128) : __m64 {
    return _mm_cvtps_pi32(__a)
}
def _mm_cvtt_ss2si(var _a : __m128) : int {
    return _mm_cvttss_si32(__a)
}
def _mm_cvtt_ps2pi(var _a : __m128) : __m64 {
    return _mm_cvttps_pi32(__a)
}
def _mm_cvtsi32_ss(var _a : __m128; var _b : int) : __m128 {
    __a[0] = cast<float>(__b)
    return __a
}
def _mm_cvt_si2ss(var _a : __m128; var _b : int) : __m128 {
    return _mm_cvtsi32_ss(__a, __b)
}
def _mm_cvtsi64_ss(var _a : __m128; var _b : int64) : __m128 {
    __a[0] = cast<float>(__b)
    return __a
}
def _mm_cvt_pi2ps(var _a : __m128; var _b : __m64) : __m128 {
    return _mm_cvtpi32_ps(__a, __b)
}
def _mm_cvtss_f32(var _a : __m128) : float {
    return __a[0]
}
def _mm_load_ss(var _p : float const?) : __m128 {
    struct __mm_load_ss_struct {
    __u : float
}    var __u : float = cast<__mm_load_ss_struct const?>(__p).__u
    return [__u, cast<float>(0), cast<float>(0), cast<float>(0)]
}
def _mm_load1_ps(var _p : float const?) : __m128 {
    struct __mm_load1_ps_struct {
    __u : float
}    var __u : float = cast<__mm_load1_ps_struct const?>(__p).__u
    return [__u, __u, __u, __u]
}
def _mm_load_ps(var _p : float const?) : __m128 {
    return *cast<__m128 const?>(__p)
}
def _mm_loadu_ps(var _p : float const?) : __m128 {
    struct __loadu_ps {
    __v : __m128_u
}    return cast<__loadu_ps const?>(__p).__v
}
def _mm_set_ss(var _w : float) : __m128 {
    return [__w, cast<float>(0), cast<float>(0), cast<float>(0)]
}
def _mm_set1_ps(var _w : float) : __m128 {
    return [__w, __w, __w, __w]
}
def _mm_set_ps1(var _w : float) : __m128 {
    return _mm_set1_ps(__w)
}
def _mm_set_ps(var _z : float; var _y : float; var _x : float; var _w : float) : __m128 {
    return [__w, __x, __y, __z]
}
def _mm_setr_ps(var _z : float; var _y : float; var _x : float; var _w : float) : __m128 {
    return [__z, __y, __x, __w]
}
def _mm_setzero_ps() : __m128 {
    return [double(0.0), double(0.0), double(0.0), double(0.0)]
}
def _mm_store_ss(var _p : float?; var _a : __m128) {
    struct __mm_store_ss_struct {
    __u : float
}    cast<__mm_store_ss_struct?>(__p).__u = __a[0]
}
def _mm_storeu_ps(var _p : float?; var _a : __m128) {
    struct __storeu_ps {
    __v : __m128_u
}    cast<__storeu_ps?>(__p).__v = __a
}
def _mm_store_ps(var _p : float?; var _a : __m128) {
    *cast<__m128?>(__p) = __a
}
def _mm_store_ps1(var _p : float?; var _a : __m128) {
    _mm_store1_ps(__p, __a)
}
def _mm_move_ss(var _a : __m128; var _b : __m128) : __m128 {
    __a[0] = __b[0]
    return __a
}
def _mm_cvtpi16_ps(var _a : __m64) : __m128 {
    var __b : __m64
    var __c : __m64
    var __r : __m128
    __b = _mm_setzero_si64()
    __b = _mm_cmpgt_pi16(__b, __a)
    __c = _mm_unpackhi_pi16(__a, __b)
    __r = _mm_setzero_ps()
    __r = _mm_cvtpi32_ps(__r, __c)
    __r = _mm_movelh_ps(__r, __r)
    __c = _mm_unpacklo_pi16(__a, __b)
    __r = _mm_cvtpi32_ps(__r, __c)
    return __r
}
def _mm_cvtpu16_ps(var _a : __m64) : __m128 {
    var __b : __m64
    var __c : __m64
    var __r : __m128
    __b = _mm_setzero_si64()
    __c = _mm_unpackhi_pi16(__a, __b)
    __r = _mm_setzero_ps()
    __r = _mm_cvtpi32_ps(__r, __c)
    __r = _mm_movelh_ps(__r, __r)
    __c = _mm_unpacklo_pi16(__a, __b)
    __r = _mm_cvtpi32_ps(__r, __c)
    return __r
}
def _mm_cvtpi8_ps(var _a : __m64) : __m128 {
    var __b : __m64
    __b = _mm_setzero_si64()
    __b = _mm_cmpgt_pi8(__b, __a)
    __b = _mm_unpacklo_pi8(__a, __b)
    return _mm_cvtpi16_ps(__b)
}
def _mm_cvtpu8_ps(var _a : __m64) : __m128 {
    var __b : __m64
    __b = _mm_setzero_si64()
    __b = _mm_unpacklo_pi8(__a, __b)
    return _mm_cvtpi16_ps(__b)
}
def _mm_cvtpi32x2_ps(var _a : __m64; var _b : __m64) : __m128 {
    var __c : __m128
    __c = _mm_setzero_ps()
    __c = _mm_cvtpi32_ps(__c, __b)
    __c = _mm_movelh_ps(__c, __c)
    return _mm_cvtpi32_ps(__c, __a)
}
def _mm_cvtps_pi16(var _a : __m128) : __m64 {
    var __b : __m64
    var __c : __m64
    __b = _mm_cvtps_pi32(__a)
    __a = _mm_movehl_ps(__a, __a)
    __c = _mm_cvtps_pi32(__a)
    return _mm_packs_pi32(__b, __c)
}
def _mm_cvtps_pi8(var _a : __m128) : __m64 {
    var __b : __m64
    var __c : __m64
    __b = _mm_cvtps_pi16(__a)
    __c = _mm_setzero_si64()
    return _mm_packs_pi16(__b, __c)
}
def _mm_add_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    __a[0] += __b[0]
    return __a
}
def _mm_add_pd(var _a : __m128d; var _b : __m128d) : __m128d {
    return cast<__m128d>(cast<__v2df>(__a) + cast<__v2df>(__b))
}
def _mm_sub_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    __a[0] -= __b[0]
    return __a
}
def _mm_sub_pd(var _a : __m128d; var _b : __m128d) : __m128d {
    return cast<__m128d>(cast<__v2df>(__a) - cast<__v2df>(__b))
}
def _mm_mul_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    __a[0] *= __b[0]
    return __a
}
def _mm_mul_pd(var _a : __m128d; var _b : __m128d) : __m128d {
    return cast<__m128d>(cast<__v2df>(__a) * cast<__v2df>(__b))
}
def _mm_div_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    __a[0] /= __b[0]
    return __a
}
def _mm_div_pd(var _a : __m128d; var _b : __m128d) : __m128d {
    return cast<__m128d>(cast<__v2df>(__a) / cast<__v2df>(__b))
}
def _mm_sqrt_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    return [__c[0], __a[1]]
}
def _mm_and_pd(var _a : __m128d; var _b : __m128d) : __m128d {
    return cast<__m128d>(cast<__v2du>(__a) & cast<__v2du>(__b))
}
def _mm_andnot_pd(var _a : __m128d; var _b : __m128d) : __m128d {
    return cast<__m128d>(~cast<__v2du>(__a) & cast<__v2du>(__b))
}
def _mm_or_pd(var _a : __m128d; var _b : __m128d) : __m128d {
    return cast<__m128d>(cast<__v2du>(__a) | cast<__v2du>(__b))
}
def _mm_xor_pd(var _a : __m128d; var _b : __m128d) : __m128d {
    return cast<__m128d>(cast<__v2du>(__a) ^ cast<__v2du>(__b))
}
def _mm_cmpgt_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    return [__c[0], __a[1]]
}
def _mm_cmpge_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    return [__c[0], __a[1]]
}
def _mm_cmpngt_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    return [__c[0], __a[1]]
}
def _mm_cmpnge_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    return [__c[0], __a[1]]
}
def _mm_cvtsi32_sd(var _a : __m128d; var _b : int) : __m128d {
    __a[0] = cast<double>(__b)
    return __a
}
def _mm_cvtss_sd(var _a : __m128d; var _b : __m128) : __m128d {
    __a[0] = cast<double>(__b[0])
    return __a
}
def _mm_cvtsd_f64(var _a : __m128d) : double {
    return __a[0]
}
def _mm_load_pd(var _dp : double const?) : __m128d {
    return *cast<__m128d const?>(__dp)
}
def _mm_load1_pd(var _dp : double const?) : __m128d {
    struct __mm_load1_pd_struct {
    __u : double
}    var __u : double = cast<__mm_load1_pd_struct const?>(__dp).__u
    return [__u, __u]
}
def _mm_loadu_pd(var _dp : double const?) : __m128d {
    struct __loadu_pd {
    __v : __m128d_u
}    return cast<__loadu_pd const?>(__dp).__v
}
def _mm_loadu_si64(var _a : void const?) : __m128i {
    struct __loadu_si64 {
    __v : int64
}    var __u : int64 = cast<__loadu_si64 const?>(__a).__v
    return cast<__m128i>([__u, 0])
}
def _mm_loadu_si32(var _a : void const?) : __m128i {
    struct __loadu_si32 {
    __v : int
}    var __u : int = cast<__loadu_si32 const?>(__a).__v
    return cast<__m128i>([__u, 0, 0, 0])
}
def _mm_loadu_si16(var _a : void const?) : __m128i {
    struct __loadu_si16 {
    __v : int
}    var __u : int = cast<__loadu_si16 const?>(__a).__v
    return cast<__m128i>([__u, 0, 0, 0, 0, 0, 0, 0])
}
def _mm_load_sd(var _dp : double const?) : __m128d {
    struct __mm_load_sd_struct {
    __u : double
}    var __u : double = cast<__mm_load_sd_struct const?>(__dp).__u
    return [__u, cast<double>(0)]
}
def _mm_loadh_pd(var _a : __m128d; var _dp : double const?) : __m128d {
    struct __mm_loadh_pd_struct {
    __u : double
}    var __u : double = cast<__mm_loadh_pd_struct const?>(__dp).__u
    return [__a[0], __u]
}
def _mm_loadl_pd(var _a : __m128d; var _dp : double const?) : __m128d {
    struct __mm_loadl_pd_struct {
    __u : double
}    var __u : double = cast<__mm_loadl_pd_struct const?>(__dp).__u
    return [__u, __a[1]]
}
def _mm_set_sd(var _w : double) : __m128d {
    return [__w, cast<double>(0)]
}
def _mm_set1_pd(var _w : double) : __m128d {
    return [__w, __w]
}
def _mm_set_pd1(var _w : double) : __m128d {
    return _mm_set1_pd(__w)
}
def _mm_set_pd(var _w : double; var _x : double) : __m128d {
    return [__x, __w]
}
def _mm_setr_pd(var _w : double; var _x : double) : __m128d {
    return [__w, __x]
}
def _mm_setzero_pd() : __m128d {
    return [double(0.0), double(0.0)]
}
def _mm_move_sd(var _a : __m128d; var _b : __m128d) : __m128d {
    __a[0] = __b[0]
    return __a
}
def _mm_store_sd(var _dp : double?; var _a : __m128d) {
    struct __mm_store_sd_struct {
    __u : double
}    cast<__mm_store_sd_struct?>(__dp).__u = __a[0]
}
def _mm_store_pd(var _dp : double?; var _a : __m128d) {
    *cast<__m128d?>(__dp) = __a
}
def _mm_store_pd1(var _dp : double?; var _a : __m128d) {
    _mm_store1_pd(__dp, __a)
}
def _mm_storeu_pd(var _dp : double?; var _a : __m128d) {
    struct __storeu_pd {
    __v : __m128d_u
}    cast<__storeu_pd?>(__dp).__v = __a
}
def _mm_storeh_pd(var _dp : double?; var _a : __m128d) {
    struct __mm_storeh_pd_struct {
    __u : double
}    cast<__mm_storeh_pd_struct?>(__dp).__u = __a[1]
}
def _mm_storel_pd(var _dp : double?; var _a : __m128d) {
    struct __mm_storeh_pd_struct {
    __u : double
}    cast<__mm_storeh_pd_struct?>(__dp).__u = __a[0]
}
def _mm_add_epi8(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v16qu>(__a) + cast<__v16qu>(__b))
}
def _mm_add_epi16(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v8hu>(__a) + cast<__v8hu>(__b))
}
def _mm_add_epi32(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v4su>(__a) + cast<__v4su>(__b))
}
def _mm_add_epi64(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__a) + cast<__v2du>(__b))
}
def _mm_mullo_epi16(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v8hu>(__a) * cast<__v8hu>(__b))
}
def _mm_sub_epi8(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v16qu>(__a) - cast<__v16qu>(__b))
}
def _mm_sub_epi16(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v8hu>(__a) - cast<__v8hu>(__b))
}
def _mm_sub_epi32(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v4su>(__a) - cast<__v4su>(__b))
}
def _mm_sub_epi64(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__a) - cast<__v2du>(__b))
}
def _mm_and_si128(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__a) & cast<__v2du>(__b))
}
def _mm_andnot_si128(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(~cast<__v2du>(__a) & cast<__v2du>(__b))
}
def _mm_or_si128(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__a) | cast<__v2du>(__b))
}
def _mm_xor_si128(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__a) ^ cast<__v2du>(__b))
}
def _mm_cmpeq_epi8(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v16qi>(__a) == cast<__v16qi>(__b))
}
def _mm_cmpeq_epi16(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v8hi>(__a) == cast<__v8hi>(__b))
}
def _mm_cmpeq_epi32(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v4si>(__a) == cast<__v4si>(__b))
}
def _mm_cmpgt_epi8(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v16qs>(__a) > cast<__v16qs>(__b))
}
def _mm_cmpgt_epi16(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v8hi>(__a) > cast<__v8hi>(__b))
}
def _mm_cmpgt_epi32(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v4si>(__a) > cast<__v4si>(__b))
}
def _mm_cmplt_epi8(var _a : __m128i; var _b : __m128i) : __m128i {
    return _mm_cmpgt_epi8(__b, __a)
}
def _mm_cmplt_epi16(var _a : __m128i; var _b : __m128i) : __m128i {
    return _mm_cmpgt_epi16(__b, __a)
}
def _mm_cmplt_epi32(var _a : __m128i; var _b : __m128i) : __m128i {
    return _mm_cmpgt_epi32(__b, __a)
}
def _mm_cvtsi64_sd(var _a : __m128d; var _b : int64) : __m128d {
    __a[0] = cast<double>(__b)
    return __a
}
def _mm_cvtsi32_si128(var _a : int) : __m128i {
    return cast<__m128i>([__a, 0, 0, 0])
}
def _mm_cvtsi64_si128(var _a : int64) : __m128i {
    return cast<__m128i>([__a, 0])
}
def _mm_cvtsi128_si32(var _a : __m128i) : int {
    var __b : __v4si = cast<__v4si>(__a)
    return __b[0]
}
def _mm_cvtsi128_si64(var _a : __m128i) : int64 {
    return __a[0]
}
def _mm_load_si128(var _p : __m128i const?) : __m128i {
    return *__p
}
def _mm_loadu_si128(var _p : __m128i_u const?) : __m128i {
    struct __loadu_si128 {
    __v : __m128i_u
}    return cast<__loadu_si128 const?>(__p).__v
}
def _mm_loadl_epi64(var _p : __m128i_u const?) : __m128i {
    struct __mm_loadl_epi64_struct {
    __u : int64
}    return [cast<__mm_loadl_epi64_struct const?>(__p).__u, 0]
}
def _mm_set_epi64x(var _q1 : int64; var _q0 : int64) : __m128i {
    return cast<__m128i>([__q0, __q1])
}
def _mm_set_epi64(var _q1 : __m64; var _q0 : __m64) : __m128i {
    return _mm_set_epi64x(cast<int64>(__q1), cast<int64>(__q0))
}
def _mm_set_epi32(var _i3 : int; var _i2 : int; var _i1 : int; var _i0 : int) : __m128i {
    return cast<__m128i>([__i0, __i1, __i2, __i3])
}
def _mm_set_epi16(var _w7 : int; var _w6 : int; var _w5 : int; var _w4 : int; var _w3 : int; var _w2 : int; var _w1 : int; var _w0 : int) : __m128i {
    return cast<__m128i>([__w0, __w1, __w2, __w3, __w4, __w5, __w6, __w7])
}
def _mm_set_epi8(var _b15 : int8; var _b14 : int8; var _b13 : int8; var _b12 : int8; var _b11 : int8; var _b10 : int8; var _b9 : int8; var _b8 : int8; var _b7 : int8; var _b6 : int8; var _b5 : int8; var _b4 : int8; var _b3 : int8; var _b2 : int8; var _b1 : int8; var _b0 : int8) : __m128i {
    return cast<__m128i>([__b0, __b1, __b2, __b3, __b4, __b5, __b6, __b7, __b8, __b9, __b10, __b11, __b12, __b13, __b14, __b15])
}
def _mm_set1_epi64x(var _q : int64) : __m128i {
    return _mm_set_epi64x(__q, __q)
}
def _mm_set1_epi64(var _q : __m64) : __m128i {
    return _mm_set_epi64(__q, __q)
}
def _mm_set1_epi32(var _i : int) : __m128i {
    return _mm_set_epi32(__i, __i, __i, __i)
}
def _mm_set1_epi16(var _w : int) : __m128i {
    return _mm_set_epi16(__w, __w, __w, __w, __w, __w, __w, __w)
}
def _mm_set1_epi8(var _b : int8) : __m128i {
    return _mm_set_epi8(__b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b)
}
def _mm_setr_epi64(var _q0 : __m64; var _q1 : __m64) : __m128i {
    return _mm_set_epi64(__q1, __q0)
}
def _mm_setr_epi32(var _i0 : int; var _i1 : int; var _i2 : int; var _i3 : int) : __m128i {
    return _mm_set_epi32(__i3, __i2, __i1, __i0)
}
def _mm_setr_epi16(var _w0 : int; var _w1 : int; var _w2 : int; var _w3 : int; var _w4 : int; var _w5 : int; var _w6 : int; var _w7 : int) : __m128i {
    return _mm_set_epi16(__w7, __w6, __w5, __w4, __w3, __w2, __w1, __w0)
}
def _mm_setr_epi8(var _b0 : int8; var _b1 : int8; var _b2 : int8; var _b3 : int8; var _b4 : int8; var _b5 : int8; var _b6 : int8; var _b7 : int8; var _b8 : int8; var _b9 : int8; var _b10 : int8; var _b11 : int8; var _b12 : int8; var _b13 : int8; var _b14 : int8; var _b15 : int8) : __m128i {
    return _mm_set_epi8(__b15, __b14, __b13, __b12, __b11, __b10, __b9, __b8, __b7, __b6, __b5, __b4, __b3, __b2, __b1, __b0)
}
def _mm_setzero_si128() : __m128i {
    return cast<__m128i>([0, 0])
}
def _mm_store_si128(var _p : __m128i?; var _b : __m128i) {
    *__p = __b
}
def _mm_storeu_si128(var _p : __m128i_u?; var _b : __m128i) {
    struct __storeu_si128 {
    __v : __m128i_u
}    cast<__storeu_si128?>(__p).__v = __b
}
def _mm_storeu_si64(var _p : void?; var _b : __m128i) {
    struct __storeu_si64 {
    __v : int64
}    cast<__storeu_si64?>(__p).__v = cast<__v2di>(__b)[0]
}
def _mm_storeu_si32(var _p : void?; var _b : __m128i) {
    struct __storeu_si32 {
    __v : int
}    cast<__storeu_si32?>(__p).__v = cast<__v4si>(__b)[0]
}
def _mm_storeu_si16(var _p : void?; var _b : __m128i) {
    struct __storeu_si16 {
    __v : int
}    cast<__storeu_si16?>(__p).__v = cast<__v8hi>(__b)[0]
}
def _mm_storel_epi64(var _p : __m128i_u?; var _a : __m128i) {
    struct __mm_storel_epi64_struct {
    __u : int64
}    cast<__mm_storel_epi64_struct?>(__p).__u = __a[0]
}
def _mm_movepi64_pi64(var _a : __m128i) : __m64 {
    return cast<__m64>(__a[0])
}
def _mm_movpi64_epi64(var _a : __m64) : __m128i {
    return cast<__m128i>([cast<int64>(__a), 0])
}
def _mm_castpd_ps(var _a : __m128d) : __m128 {
    return cast<__m128>(__a)
}
def _mm_castpd_si128(var _a : __m128d) : __m128i {
    return cast<__m128i>(__a)
}
def _mm_castps_pd(var _a : __m128) : __m128d {
    return cast<__m128d>(__a)
}
def _mm_castps_si128(var _a : __m128) : __m128i {
    return cast<__m128i>(__a)
}
def _mm_castsi128_ps(var _a : __m128i) : __m128 {
    return cast<__m128>(__a)
}
def _mm_castsi128_pd(var _a : __m128i) : __m128d {
    return cast<__m128d>(__a)
}
def _mm_mullo_epi32(var _V1 : __m128i; var _V2 : __m128i) : __m128i {
    return cast<__m128i>(cast<__v4su>(__V1) * cast<__v4su>(__V2))
}
def _mm_cmpeq_epi64(var _V1 : __m128i; var _V2 : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2di>(__V1) == cast<__v2di>(__V2))
}
def _mm_cmpgt_epi64(var _V1 : __m128i; var _V2 : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2di>(__V1) > cast<__v2di>(__V2))
}
def _mm_popcnt_u32(var _A : uint) : int {
    return 0
}
def _mm_popcnt_u64(var _A : uint64) : int64 {
    return 0
}
def _mm256_add_pd(var _a : __m256d; var _b : __m256d) : __m256d {
    return cast<__m256d>(cast<__v4df>(__a) + cast<__v4df>(__b))
}
def _mm256_add_ps(var _a : __m256; var _b : __m256) : __m256 {
    return cast<__m256>(cast<__v8sf>(__a) + cast<__v8sf>(__b))
}
def _mm256_sub_pd(var _a : __m256d; var _b : __m256d) : __m256d {
    return cast<__m256d>(cast<__v4df>(__a) - cast<__v4df>(__b))
}
def _mm256_sub_ps(var _a : __m256; var _b : __m256) : __m256 {
    return cast<__m256>(cast<__v8sf>(__a) - cast<__v8sf>(__b))
}
def _mm256_div_pd(var _a : __m256d; var _b : __m256d) : __m256d {
    return cast<__m256d>(cast<__v4df>(__a) / cast<__v4df>(__b))
}
def _mm256_div_ps(var _a : __m256; var _b : __m256) : __m256 {
    return cast<__m256>(cast<__v8sf>(__a) / cast<__v8sf>(__b))
}
def _mm256_mul_pd(var _a : __m256d; var _b : __m256d) : __m256d {
    return cast<__m256d>(cast<__v4df>(__a) * cast<__v4df>(__b))
}
def _mm256_mul_ps(var _a : __m256; var _b : __m256) : __m256 {
    return cast<__m256>(cast<__v8sf>(__a) * cast<__v8sf>(__b))
}
def _mm256_and_pd(var _a : __m256d; var _b : __m256d) : __m256d {
    return cast<__m256d>(cast<__v4du>(__a) & cast<__v4du>(__b))
}
def _mm256_and_ps(var _a : __m256; var _b : __m256) : __m256 {
    return cast<__m256>(cast<__v8su>(__a) & cast<__v8su>(__b))
}
def _mm256_andnot_pd(var _a : __m256d; var _b : __m256d) : __m256d {
    return cast<__m256d>(~cast<__v4du>(__a) & cast<__v4du>(__b))
}
def _mm256_andnot_ps(var _a : __m256; var _b : __m256) : __m256 {
    return cast<__m256>(~cast<__v8su>(__a) & cast<__v8su>(__b))
}
def _mm256_or_pd(var _a : __m256d; var _b : __m256d) : __m256d {
    return cast<__m256d>(cast<__v4du>(__a) | cast<__v4du>(__b))
}
def _mm256_or_ps(var _a : __m256; var _b : __m256) : __m256 {
    return cast<__m256>(cast<__v8su>(__a) | cast<__v8su>(__b))
}
def _mm256_xor_pd(var _a : __m256d; var _b : __m256d) : __m256d {
    return cast<__m256d>(cast<__v4du>(__a) ^ cast<__v4du>(__b))
}
def _mm256_xor_ps(var _a : __m256; var _b : __m256) : __m256 {
    return cast<__m256>(cast<__v8su>(__a) ^ cast<__v8su>(__b))
}
def _mm256_cvtsd_f64(var _a : __m256d) : double {
    return __a[0]
}
def _mm256_cvtsi256_si32(var _a : __m256i) : int {
    var __b : __v8si = cast<__v8si>(__a)
    return __b[0]
}
def _mm256_cvtss_f32(var _a : __m256) : float {
    return __a[0]
}
def _mm_broadcast_ss(var _a : float const?) : __m128 {
    struct __mm_broadcast_ss_struct {
    __f : float
}    var __f : float = cast<__mm_broadcast_ss_struct const?>(__a).__f
    return [__f, __f, __f, __f]
}
def _mm256_broadcast_sd(var _a : double const?) : __m256d {
    struct __mm256_broadcast_sd_struct {
    __d : double
}    var __d : double = cast<__mm256_broadcast_sd_struct const?>(__a).__d
    return cast<__m256d>([__d, __d, __d, __d])
}
def _mm256_broadcast_ss(var _a : float const?) : __m256 {
    struct __mm256_broadcast_ss_struct {
    __f : float
}    var __f : float = cast<__mm256_broadcast_ss_struct const?>(__a).__f
    return cast<__m256>([__f, __f, __f, __f, __f, __f, __f, __f])
}
def _mm256_load_pd(var _p : double const?) : __m256d {
    return *cast<__m256d const?>(__p)
}
def _mm256_load_ps(var _p : float const?) : __m256 {
    return *cast<__m256 const?>(__p)
}
def _mm256_loadu_pd(var _p : double const?) : __m256d {
    struct __loadu_pd {
    __v : __m256d_u
}    return cast<__loadu_pd const?>(__p).__v
}
def _mm256_loadu_ps(var _p : float const?) : __m256 {
    struct __loadu_ps {
    __v : __m256_u
}    return cast<__loadu_ps const?>(__p).__v
}
def _mm256_load_si256(var _p : __m256i const?) : __m256i {
    return *__p
}
def _mm256_loadu_si256(var _p : __m256i_u const?) : __m256i {
    struct __loadu_si256 {
    __v : __m256i_u
}    return cast<__loadu_si256 const?>(__p).__v
}
def _mm256_store_pd(var _p : double?; var _a : __m256d) {
    *cast<__m256d?>(__p) = __a
}
def _mm256_store_ps(var _p : float?; var _a : __m256) {
    *cast<__m256?>(__p) = __a
}
def _mm256_storeu_pd(var _p : double?; var _a : __m256d) {
    struct __storeu_pd {
    __v : __m256d_u
}    cast<__storeu_pd?>(__p).__v = __a
}
def _mm256_storeu_ps(var _p : float?; var _a : __m256) {
    struct __storeu_ps {
    __v : __m256_u
}    cast<__storeu_ps?>(__p).__v = __a
}
def _mm256_store_si256(var _p : __m256i?; var _a : __m256i) {
    *__p = __a
}
def _mm256_storeu_si256(var _p : __m256i_u?; var _a : __m256i) {
    struct __storeu_si256 {
    __v : __m256i_u
}    cast<__storeu_si256?>(__p).__v = __a
}
def _mm256_set_pd(var _a : double; var _b : double; var _c : double; var _d : double) : __m256d {
    return [__d, __c, __b, __a]
}
def _mm256_set_ps(var _a : float; var _b : float; var _c : float; var _d : float; var _e : float; var _f : float; var _g : float; var _h : float) : __m256 {
    return [__h, __g, __f, __e, __d, __c, __b, __a]
}
def _mm256_set_epi32(var _i0 : int; var _i1 : int; var _i2 : int; var _i3 : int; var _i4 : int; var _i5 : int; var _i6 : int; var _i7 : int) : __m256i {
    return cast<__m256i>([__i7, __i6, __i5, __i4, __i3, __i2, __i1, __i0])
}
def _mm256_set_epi16(var _w15 : int; var _w14 : int; var _w13 : int; var _w12 : int; var _w11 : int; var _w10 : int; var _w09 : int; var _w08 : int; var _w07 : int; var _w06 : int; var _w05 : int; var _w04 : int; var _w03 : int; var _w02 : int; var _w01 : int; var _w00 : int) : __m256i {
    return cast<__m256i>([__w00, __w01, __w02, __w03, __w04, __w05, __w06, __w07, __w08, __w09, __w10, __w11, __w12, __w13, __w14, __w15])
}
def _mm256_set_epi8(var _b31 : int8; var _b30 : int8; var _b29 : int8; var _b28 : int8; var _b27 : int8; var _b26 : int8; var _b25 : int8; var _b24 : int8; var _b23 : int8; var _b22 : int8; var _b21 : int8; var _b20 : int8; var _b19 : int8; var _b18 : int8; var _b17 : int8; var _b16 : int8; var _b15 : int8; var _b14 : int8; var _b13 : int8; var _b12 : int8; var _b11 : int8; var _b10 : int8; var _b09 : int8; var _b08 : int8; var _b07 : int8; var _b06 : int8; var _b05 : int8; var _b04 : int8; var _b03 : int8; var _b02 : int8; var _b01 : int8; var _b00 : int8) : __m256i {
    return cast<__m256i>([__b00, __b01, __b02, __b03, __b04, __b05, __b06, __b07, __b08, __b09, __b10, __b11, __b12, __b13, __b14, __b15, __b16, __b17, __b18, __b19, __b20, __b21, __b22, __b23, __b24, __b25, __b26, __b27, __b28, __b29, __b30, __b31])
}
def _mm256_set_epi64x(var _a : int64; var _b : int64; var _c : int64; var _d : int64) : __m256i {
    return cast<__m256i>([__d, __c, __b, __a])
}
def _mm256_setr_pd(var _a : double; var _b : double; var _c : double; var _d : double) : __m256d {
    return _mm256_set_pd(__d, __c, __b, __a)
}
def _mm256_setr_ps(var _a : float; var _b : float; var _c : float; var _d : float; var _e : float; var _f : float; var _g : float; var _h : float) : __m256 {
    return _mm256_set_ps(__h, __g, __f, __e, __d, __c, __b, __a)
}
def _mm256_setr_epi32(var _i0 : int; var _i1 : int; var _i2 : int; var _i3 : int; var _i4 : int; var _i5 : int; var _i6 : int; var _i7 : int) : __m256i {
    return _mm256_set_epi32(__i7, __i6, __i5, __i4, __i3, __i2, __i1, __i0)
}
def _mm256_setr_epi16(var _w15 : int; var _w14 : int; var _w13 : int; var _w12 : int; var _w11 : int; var _w10 : int; var _w09 : int; var _w08 : int; var _w07 : int; var _w06 : int; var _w05 : int; var _w04 : int; var _w03 : int; var _w02 : int; var _w01 : int; var _w00 : int) : __m256i {
    return _mm256_set_epi16(__w00, __w01, __w02, __w03, __w04, __w05, __w06, __w07, __w08, __w09, __w10, __w11, __w12, __w13, __w14, __w15)
}
def _mm256_setr_epi8(var _b31 : int8; var _b30 : int8; var _b29 : int8; var _b28 : int8; var _b27 : int8; var _b26 : int8; var _b25 : int8; var _b24 : int8; var _b23 : int8; var _b22 : int8; var _b21 : int8; var _b20 : int8; var _b19 : int8; var _b18 : int8; var _b17 : int8; var _b16 : int8; var _b15 : int8; var _b14 : int8; var _b13 : int8; var _b12 : int8; var _b11 : int8; var _b10 : int8; var _b09 : int8; var _b08 : int8; var _b07 : int8; var _b06 : int8; var _b05 : int8; var _b04 : int8; var _b03 : int8; var _b02 : int8; var _b01 : int8; var _b00 : int8) : __m256i {
    return _mm256_set_epi8(__b00, __b01, __b02, __b03, __b04, __b05, __b06, __b07, __b08, __b09, __b10, __b11, __b12, __b13, __b14, __b15, __b16, __b17, __b18, __b19, __b20, __b21, __b22, __b23, __b24, __b25, __b26, __b27, __b28, __b29, __b30, __b31)
}
def _mm256_setr_epi64x(var _a : int64; var _b : int64; var _c : int64; var _d : int64) : __m256i {
    return _mm256_set_epi64x(__d, __c, __b, __a)
}
def _mm256_set1_pd(var _w : double) : __m256d {
    return _mm256_set_pd(__w, __w, __w, __w)
}
def _mm256_set1_ps(var _w : float) : __m256 {
    return _mm256_set_ps(__w, __w, __w, __w, __w, __w, __w, __w)
}
def _mm256_set1_epi32(var _i : int) : __m256i {
    return _mm256_set_epi32(__i, __i, __i, __i, __i, __i, __i, __i)
}
def _mm256_set1_epi16(var _w : int) : __m256i {
    return _mm256_set_epi16(__w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w)
}
def _mm256_set1_epi8(var _b : int8) : __m256i {
    return _mm256_set_epi8(__b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b, __b)
}
def _mm256_set1_epi64x(var _q : int64) : __m256i {
    return _mm256_set_epi64x(__q, __q, __q, __q)
}
def _mm256_setzero_pd() : __m256d {
    return [double(0.0), double(0.0), double(0.0), double(0.0)]
}
def _mm256_setzero_ps() : __m256 {
    return [double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0)]
}
def _mm256_setzero_si256() : __m256i {
    return cast<__m256i>([0, 0, 0, 0])
}
def _mm256_castpd_ps(var _a : __m256d) : __m256 {
    return cast<__m256>(__a)
}
def _mm256_castpd_si256(var _a : __m256d) : __m256i {
    return cast<__m256i>(__a)
}
def _mm256_castps_pd(var _a : __m256) : __m256d {
    return cast<__m256d>(__a)
}
def _mm256_castps_si256(var _a : __m256) : __m256i {
    return cast<__m256i>(__a)
}
def _mm256_castsi256_ps(var _a : __m256i) : __m256 {
    return cast<__m256>(__a)
}
def _mm256_castsi256_pd(var _a : __m256i) : __m256d {
    return cast<__m256d>(__a)
}
def _mm256_setr_m128(var _lo : __m128; var _hi : __m128) : __m256 {
    return _mm256_set_m128(__hi, __lo)
}
def _mm256_setr_m128d(var _lo : __m128d; var _hi : __m128d) : __m256d {
    return cast<__m256d>(_mm256_set_m128d(__hi, __lo))
}
def _mm256_setr_m128i(var _lo : __m128i; var _hi : __m128i) : __m256i {
    return cast<__m256i>(_mm256_set_m128i(__hi, __lo))
}
def _mm256_loadu2_m128(var _addr_hi : float const?; var _addr_lo : float const?) : __m256 {
    return _mm256_set_m128(_mm_loadu_ps(__addr_hi), _mm_loadu_ps(__addr_lo))
}
def _mm256_loadu2_m128d(var _addr_hi : double const?; var _addr_lo : double const?) : __m256d {
    return _mm256_set_m128d(_mm_loadu_pd(__addr_hi), _mm_loadu_pd(__addr_lo))
}
def _mm256_loadu2_m128i(var _addr_hi : __m128i_u const?; var _addr_lo : __m128i_u const?) : __m256i {
    return _mm256_set_m128i(_mm_loadu_si128(__addr_hi), _mm_loadu_si128(__addr_lo))
}
def _mm256_add_epi8(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v32qu>(__a) + cast<__v32qu>(__b))
}
def _mm256_add_epi16(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v16hu>(__a) + cast<__v16hu>(__b))
}
def _mm256_add_epi32(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v8su>(__a) + cast<__v8su>(__b))
}
def _mm256_add_epi64(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__a) + cast<__v4du>(__b))
}
def _mm256_and_si256(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__a) & cast<__v4du>(__b))
}
def _mm256_andnot_si256(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(~cast<__v4du>(__a) & cast<__v4du>(__b))
}
def _mm256_cmpeq_epi8(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v32qi>(__a) == cast<__v32qi>(__b))
}
def _mm256_cmpeq_epi16(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v16hi>(__a) == cast<__v16hi>(__b))
}
def _mm256_cmpeq_epi32(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v8si>(__a) == cast<__v8si>(__b))
}
def _mm256_cmpeq_epi64(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4di>(__a) == cast<__v4di>(__b))
}
def _mm256_cmpgt_epi8(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v32qs>(__a) > cast<__v32qs>(__b))
}
def _mm256_cmpgt_epi16(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v16hi>(__a) > cast<__v16hi>(__b))
}
def _mm256_cmpgt_epi32(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v8si>(__a) > cast<__v8si>(__b))
}
def _mm256_cmpgt_epi64(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4di>(__a) > cast<__v4di>(__b))
}
def _mm256_mullo_epi16(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v16hu>(__a) * cast<__v16hu>(__b))
}
def _mm256_mullo_epi32(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v8su>(__a) * cast<__v8su>(__b))
}
def _mm256_or_si256(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__a) | cast<__v4du>(__b))
}
def _mm256_sub_epi8(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v32qu>(__a) - cast<__v32qu>(__b))
}
def _mm256_sub_epi16(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v16hu>(__a) - cast<__v16hu>(__b))
}
def _mm256_sub_epi32(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v8su>(__a) - cast<__v8su>(__b))
}
def _mm256_sub_epi64(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__a) - cast<__v4du>(__b))
}
def _mm256_xor_si256(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__a) ^ cast<__v4du>(__b))
}
def _cvtsh_ss(var _a : int) : float {
    var __v : __v8hi = [cast<int>(__a), 0, 0, 0, 0, 0, 0, 0]
    return __r[0]
}
def _andn_u32(var _X : uint; var _Y : uint) : uint {
    return ~__X & __Y
}
def _blsi_u32(var _X : uint) : uint {
    return __X & -__X
}
def _blsmsk_u32(var _X : uint) : uint {
    return __X ^ __X - 1
}
def _blsr_u32(var _X : uint) : uint {
    return __X & __X - 1
}
def _andn_u64(var _X : uint64; var _Y : uint64) : uint64 {
    return ~__X & __Y
}
def _blsi_u64(var _X : uint64) : uint64 {
    return __X & -__X
}
def _blsmsk_u64(var _X : uint64) : uint64 {
    return __X ^ __X - 1
}
def _blsr_u64(var _X : uint64) : uint64 {
    return __X & __X - 1
}
def _mulx_u32(var _X : uint; var _Y : uint; var _P : uint?) : uint {
    var __res : uint64 = cast<uint64>(__X) * __Y
    *__P = cast<uint>(__res >> 32)
    return cast<uint>(__res)
}
def _mulx_u64(var _X : uint64; var _Y : uint64; var _P : uint64?) : uint64 {
    var __res : uint = cast<uint>(__X) * __Y
    *__P = cast<uint64>(__res >> 64)
    return cast<uint64>(__res)
}
def _mm512_setzero_si512() : __m512i {
    return cast<__m512i>([0, 0, 0, 0, 0, 0, 0, 0])
}
def _mm512_setzero_ps() : __m512 {
    return [double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0)]
}
def _mm512_setzero_pd() : __m512d {
    return [double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0)]
}
def _mm512_set1_ps(var _w : float) : __m512 {
    return [__w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w]
}
def _mm512_set1_pd(var _w : double) : __m512d {
    return [__w, __w, __w, __w, __w, __w, __w, __w]
}
def _mm512_set1_epi8(var _w : int8) : __m512i {
    return cast<__m512i>([__w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w])
}
def _mm512_set1_epi16(var _w : int) : __m512i {
    return cast<__m512i>([__w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w, __w])
}
def _mm512_set1_epi32(var _s : int) : __m512i {
    return cast<__m512i>([__s, __s, __s, __s, __s, __s, __s, __s, __s, __s, __s, __s, __s, __s, __s, __s])
}
def _mm512_set1_epi64(var _d : int64) : __m512i {
    return cast<__m512i>([__d, __d, __d, __d, __d, __d, __d, __d])
}
def _mm512_set4_epi32(var _A : int; var _B : int; var _C : int; var _D : int) : __m512i {
    return cast<__m512i>([__D, __C, __B, __A, __D, __C, __B, __A, __D, __C, __B, __A, __D, __C, __B, __A])
}
def _mm512_set4_epi64(var _A : int64; var _B : int64; var _C : int64; var _D : int64) : __m512i {
    return cast<__m512i>([__D, __C, __B, __A, __D, __C, __B, __A])
}
def _mm512_set4_pd(var _A : double; var _B : double; var _C : double; var _D : double) : __m512d {
    return [__D, __C, __B, __A, __D, __C, __B, __A]
}
def _mm512_set4_ps(var _A : float; var _B : float; var _C : float; var _D : float) : __m512 {
    return [__D, __C, __B, __A, __D, __C, __B, __A, __D, __C, __B, __A, __D, __C, __B, __A]
}
def _mm512_castpd_ps(var _A : __m512d) : __m512 {
    return cast<__m512>(__A)
}
def _mm512_castpd_si512(var _A : __m512d) : __m512i {
    return cast<__m512i>(__A)
}
def _mm512_castps_pd(var _A : __m512) : __m512d {
    return cast<__m512d>(__A)
}
def _mm512_castps_si512(var _A : __m512) : __m512i {
    return cast<__m512i>(__A)
}
def _mm512_castsi512_ps(var _A : __m512i) : __m512 {
    return cast<__m512>(__A)
}
def _mm512_castsi512_pd(var _A : __m512i) : __m512d {
    return cast<__m512d>(__A)
}
def _mm512_int2mask(var _a : int) : __mmask16 {
    return cast<__mmask16>(__a)
}
def _mm512_mask2int(var _a : __mmask16) : int {
    return cast<int>(__a)
}
def _mm512_and_epi32(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v16su>(__a) & cast<__v16su>(__b))
}
def _mm512_maskz_and_epi32(var _k : __mmask16; var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(_mm512_mask_and_epi32(_mm512_setzero_si512(), __k, __a, __b))
}
def _mm512_and_epi64(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__a) & cast<__v8du>(__b))
}
def _mm512_maskz_and_epi64(var _k : __mmask8; var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(_mm512_mask_and_epi64(_mm512_setzero_si512(), __k, __a, __b))
}
def _mm512_andnot_si512(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(~cast<__v8du>(__A) & cast<__v8du>(__B))
}
def _mm512_andnot_epi32(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(~cast<__v16su>(__A) & cast<__v16su>(__B))
}
def _mm512_maskz_andnot_epi32(var _U : __mmask16; var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(_mm512_mask_andnot_epi32(_mm512_setzero_si512(), __U, __A, __B))
}
def _mm512_andnot_epi64(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(~cast<__v8du>(__A) & cast<__v8du>(__B))
}
def _mm512_maskz_andnot_epi64(var _U : __mmask8; var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(_mm512_mask_andnot_epi64(_mm512_setzero_si512(), __U, __A, __B))
}
def _mm512_or_epi32(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v16su>(__a) | cast<__v16su>(__b))
}
def _mm512_maskz_or_epi32(var _k : __mmask16; var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(_mm512_mask_or_epi32(_mm512_setzero_si512(), __k, __a, __b))
}
def _mm512_or_epi64(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__a) | cast<__v8du>(__b))
}
def _mm512_maskz_or_epi64(var _k : __mmask8; var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(_mm512_mask_or_epi64(_mm512_setzero_si512(), __k, __a, __b))
}
def _mm512_xor_epi32(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v16su>(__a) ^ cast<__v16su>(__b))
}
def _mm512_maskz_xor_epi32(var _k : __mmask16; var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(_mm512_mask_xor_epi32(_mm512_setzero_si512(), __k, __a, __b))
}
def _mm512_xor_epi64(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__a) ^ cast<__v8du>(__b))
}
def _mm512_maskz_xor_epi64(var _k : __mmask8; var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(_mm512_mask_xor_epi64(_mm512_setzero_si512(), __k, __a, __b))
}
def _mm512_and_si512(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__a) & cast<__v8du>(__b))
}
def _mm512_or_si512(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__a) | cast<__v8du>(__b))
}
def _mm512_xor_si512(var _a : __m512i; var _b : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__a) ^ cast<__v8du>(__b))
}
def _mm512_add_pd(var _a : __m512d; var _b : __m512d) : __m512d {
    return cast<__m512d>(cast<__v8df>(__a) + cast<__v8df>(__b))
}
def _mm512_add_ps(var _a : __m512; var _b : __m512) : __m512 {
    return cast<__m512>(cast<__v16sf>(__a) + cast<__v16sf>(__b))
}
def _mm512_mul_pd(var _a : __m512d; var _b : __m512d) : __m512d {
    return cast<__m512d>(cast<__v8df>(__a) * cast<__v8df>(__b))
}
def _mm512_mul_ps(var _a : __m512; var _b : __m512) : __m512 {
    return cast<__m512>(cast<__v16sf>(__a) * cast<__v16sf>(__b))
}
def _mm512_sub_pd(var _a : __m512d; var _b : __m512d) : __m512d {
    return cast<__m512d>(cast<__v8df>(__a) - cast<__v8df>(__b))
}
def _mm512_sub_ps(var _a : __m512; var _b : __m512) : __m512 {
    return cast<__m512>(cast<__v16sf>(__a) - cast<__v16sf>(__b))
}
def _mm512_add_epi64(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__A) + cast<__v8du>(__B))
}
def _mm512_sub_epi64(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__A) - cast<__v8du>(__B))
}
def _mm512_add_epi32(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v16su>(__A) + cast<__v16su>(__B))
}
def _mm512_sub_epi32(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v16su>(__A) - cast<__v16su>(__B))
}
def _mm512_mullo_epi32(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v16su>(__A) * cast<__v16su>(__B))
}
def _mm512_mullox_epi64(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__A) * cast<__v8du>(__B))
}
def _mm512_div_pd(var _a : __m512d; var _b : __m512d) : __m512d {
    return cast<__m512d>(cast<__v8df>(__a) / cast<__v8df>(__b))
}
def _mm512_div_ps(var _a : __m512; var _b : __m512) : __m512 {
    return cast<__m512>(cast<__v16sf>(__a) / cast<__v16sf>(__b))
}
def _mm512_cvtepi32lo_pd(var _A : __m512i) : __m512d {
    return cast<__m512d>(_mm512_cvtepi32_pd(_mm512_castsi512_si256(__A)))
}
def _mm512_mask_cvtepi32lo_pd(var _W : __m512d; var _U : __mmask8; var _A : __m512i) : __m512d {
    return cast<__m512d>(_mm512_mask_cvtepi32_pd(__W, __U, _mm512_castsi512_si256(__A)))
}
def _mm512_cvtepu32lo_pd(var _A : __m512i) : __m512d {
    return cast<__m512d>(_mm512_cvtepu32_pd(_mm512_castsi512_si256(__A)))
}
def _mm512_mask_cvtepu32lo_pd(var _W : __m512d; var _U : __mmask8; var _A : __m512i) : __m512d {
    return cast<__m512d>(_mm512_mask_cvtepu32_pd(__W, __U, _mm512_castsi512_si256(__A)))
}
def _mm512_cvtsd_f64(var _a : __m512d) : double {
    return __a[0]
}
def _mm512_cvtss_f32(var _a : __m512) : float {
    return __a[0]
}
def _mm512_loadu_si512(var _P : void const?) : __m512i {
    struct __loadu_si512 {
    __v : __m512i_u
}    return cast<__loadu_si512 const?>(__P).__v
}
def _mm512_loadu_epi32(var _P : void const?) : __m512i {
    struct __loadu_epi32 {
    __v : __m512i_u
}    return cast<__loadu_epi32 const?>(__P).__v
}
def _mm512_loadu_epi64(var _P : void const?) : __m512i {
    struct __loadu_epi64 {
    __v : __m512i_u
}    return cast<__loadu_epi64 const?>(__P).__v
}
def _mm512_loadu_pd(var _p : void const?) : __m512d {
    struct __loadu_pd {
    __v : __m512d_u
}    return cast<__loadu_pd const?>(__p).__v
}
def _mm512_loadu_ps(var _p : void const?) : __m512 {
    struct __loadu_ps {
    __v : __m512_u
}    return cast<__loadu_ps const?>(__p).__v
}
def _mm512_load_ps(var _p : void const?) : __m512 {
    return *cast<__m512 const?>(__p)
}
def _mm512_load_pd(var _p : void const?) : __m512d {
    return *cast<__m512d const?>(__p)
}
def _mm512_load_si512(var _P : void const?) : __m512i {
    return *cast<__m512i const?>(__P)
}
def _mm512_load_epi32(var _P : void const?) : __m512i {
    return *cast<__m512i const?>(__P)
}
def _mm512_load_epi64(var _P : void const?) : __m512i {
    return *cast<__m512i const?>(__P)
}
def _mm512_storeu_epi64(var _P : void?; var _A : __m512i) {
    struct __storeu_epi64 {
    __v : __m512i_u
}    cast<__storeu_epi64?>(__P).__v = __A
}
def _mm512_storeu_si512(var _P : void?; var _A : __m512i) {
    struct __storeu_si512 {
    __v : __m512i_u
}    cast<__storeu_si512?>(__P).__v = __A
}
def _mm512_storeu_epi32(var _P : void?; var _A : __m512i) {
    struct __storeu_epi32 {
    __v : __m512i_u
}    cast<__storeu_epi32?>(__P).__v = __A
}
def _mm512_storeu_pd(var _P : void?; var _A : __m512d) {
    struct __storeu_pd {
    __v : __m512d_u
}    cast<__storeu_pd?>(__P).__v = __A
}
def _mm512_storeu_ps(var _P : void?; var _A : __m512) {
    struct __storeu_ps {
    __v : __m512_u
}    cast<__storeu_ps?>(__P).__v = __A
}
def _mm512_store_pd(var _P : void?; var _A : __m512d) {
    *cast<__m512d?>(__P) = __A
}
def _mm512_store_ps(var _P : void?; var _A : __m512) {
    *cast<__m512?>(__P) = __A
}
def _mm512_store_si512(var _P : void?; var _A : __m512i) {
    *cast<__m512i?>(__P) = __A
}
def _mm512_store_epi32(var _P : void?; var _A : __m512i) {
    *cast<__m512i?>(__P) = __A
}
def _mm512_store_epi64(var _P : void?; var _A : __m512i) {
    *cast<__m512i?>(__P) = __A
}
def _mm512_kmov(var _A : __mmask16) : __mmask16 {
    return __A
}
def _mm512_cvtpslo_pd(var _A : __m512) : __m512d {
    return cast<__m512d>(_mm512_cvtps_pd(_mm512_castps512_ps256(__A)))
}
def _mm512_mask_cvtpslo_pd(var _W : __m512d; var _U : __mmask8; var _A : __m512) : __m512d {
    return cast<__m512d>(_mm512_mask_cvtps_pd(__W, __U, _mm512_castps512_ps256(__A)))
}
def _mm_cvtu32_sd(var _A : __m128d; var _B : uint) : __m128d {
    __A[0] = cast<double>(__B)
    return __A
}
def _mm_cvtu64_sd(var _A : __m128d; var _B : uint64) : __m128d {
    __A[0] = cast<double>(__B)
    return __A
}
def _mm_cvtu32_ss(var _A : __m128; var _B : uint) : __m128 {
    __A[0] = cast<float>(__B)
    return __A
}
def _mm_cvtu64_ss(var _A : __m128; var _B : uint64) : __m128 {
    __A[0] = cast<float>(__B)
    return __A
}
def _mm512_set_epi8(var _e63 : int8; var _e62 : int8; var _e61 : int8; var _e60 : int8; var _e59 : int8; var _e58 : int8; var _e57 : int8; var _e56 : int8; var _e55 : int8; var _e54 : int8; var _e53 : int8; var _e52 : int8; var _e51 : int8; var _e50 : int8; var _e49 : int8; var _e48 : int8; var _e47 : int8; var _e46 : int8; var _e45 : int8; var _e44 : int8; var _e43 : int8; var _e42 : int8; var _e41 : int8; var _e40 : int8; var _e39 : int8; var _e38 : int8; var _e37 : int8; var _e36 : int8; var _e35 : int8; var _e34 : int8; var _e33 : int8; var _e32 : int8; var _e31 : int8; var _e30 : int8; var _e29 : int8; var _e28 : int8; var _e27 : int8; var _e26 : int8; var _e25 : int8; var _e24 : int8; var _e23 : int8; var _e22 : int8; var _e21 : int8; var _e20 : int8; var _e19 : int8; var _e18 : int8; var _e17 : int8; var _e16 : int8; var _e15 : int8; var _e14 : int8; var _e13 : int8; var _e12 : int8; var _e11 : int8; var _e10 : int8; var _e9 : int8; var _e8 : int8; var _e7 : int8; var _e6 : int8; var _e5 : int8; var _e4 : int8; var _e3 : int8; var _e2 : int8; var _e1 : int8; var _e0 : int8) : __m512i {
    return cast<__m512i>([__e0, __e1, __e2, __e3, __e4, __e5, __e6, __e7, __e8, __e9, __e10, __e11, __e12, __e13, __e14, __e15, __e16, __e17, __e18, __e19, __e20, __e21, __e22, __e23, __e24, __e25, __e26, __e27, __e28, __e29, __e30, __e31, __e32, __e33, __e34, __e35, __e36, __e37, __e38, __e39, __e40, __e41, __e42, __e43, __e44, __e45, __e46, __e47, __e48, __e49, __e50, __e51, __e52, __e53, __e54, __e55, __e56, __e57, __e58, __e59, __e60, __e61, __e62, __e63])
}
def _mm512_set_epi16(var _e31 : int; var _e30 : int; var _e29 : int; var _e28 : int; var _e27 : int; var _e26 : int; var _e25 : int; var _e24 : int; var _e23 : int; var _e22 : int; var _e21 : int; var _e20 : int; var _e19 : int; var _e18 : int; var _e17 : int; var _e16 : int; var _e15 : int; var _e14 : int; var _e13 : int; var _e12 : int; var _e11 : int; var _e10 : int; var _e9 : int; var _e8 : int; var _e7 : int; var _e6 : int; var _e5 : int; var _e4 : int; var _e3 : int; var _e2 : int; var _e1 : int; var _e0 : int) : __m512i {
    return cast<__m512i>([__e0, __e1, __e2, __e3, __e4, __e5, __e6, __e7, __e8, __e9, __e10, __e11, __e12, __e13, __e14, __e15, __e16, __e17, __e18, __e19, __e20, __e21, __e22, __e23, __e24, __e25, __e26, __e27, __e28, __e29, __e30, __e31])
}
def _mm512_set_epi32(var _A : int; var _B : int; var _C : int; var _D : int; var _E : int; var _F : int; var _G : int; var _H : int; var _I : int; var _J : int; var _K : int; var _L : int; var _M : int; var _N : int; var _O : int; var _P : int) : __m512i {
    return cast<__m512i>([__P, __O, __N, __M, __L, __K, __J, __I, __H, __G, __F, __E, __D, __C, __B, __A])
}
def _mm512_set_epi64(var _A : int64; var _B : int64; var _C : int64; var _D : int64; var _E : int64; var _F : int64; var _G : int64; var _H : int64) : __m512i {
    return cast<__m512i>([__H, __G, __F, __E, __D, __C, __B, __A])
}
def _mm512_set_pd(var _A : double; var _B : double; var _C : double; var _D : double; var _E : double; var _F : double; var _G : double; var _H : double) : __m512d {
    return [__H, __G, __F, __E, __D, __C, __B, __A]
}
def _mm512_set_ps(var _A : float; var _B : float; var _C : float; var _D : float; var _E : float; var _F : float; var _G : float; var _H : float; var _I : float; var _J : float; var _K : float; var _L : float; var _M : float; var _N : float; var _O : float; var _P : float) : __m512 {
    return [__P, __O, __N, __M, __L, __K, __J, __I, __H, __G, __F, __E, __D, __C, __B, __A]
}
def _mm512_abs_ps(var _A : __m512) : __m512 {
    return cast<__m512>(_mm512_and_epi32(_mm512_set1_epi32(2147483647), cast<__m512i>(__A)))
}
def _mm512_mask_abs_ps(var _W : __m512; var _K : __mmask16; var _A : __m512) : __m512 {
    return cast<__m512>(_mm512_mask_and_epi32(cast<__m512i>(__W), __K, _mm512_set1_epi32(2147483647), cast<__m512i>(__A)))
}
def _mm512_abs_pd(var _A : __m512d) : __m512d {
    return cast<__m512d>(_mm512_and_epi64(_mm512_set1_epi64(9223372036854775807), cast<__v8di>(__A)))
}
def _mm512_mask_abs_pd(var _W : __m512d; var _K : __mmask8; var _A : __m512d) : __m512d {
    return cast<__m512d>(_mm512_mask_and_epi64(cast<__v8di>(__W), __K, _mm512_set1_epi64(9223372036854775807), cast<__v8di>(__A)))
}
def _mm512_cvtsi512_si32(var _A : __m512i) : int {
    var __b : __v16si = cast<__v16si>(__A)
    return __b[0]
}
def _mm256_and_epi32(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v8su>(__a) & cast<__v8su>(__b))
}
def _mm256_maskz_and_epi32(var _U : __mmask8; var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(_mm256_mask_and_epi32(_mm256_setzero_si256(), __U, __A, __B))
}
def _mm_and_epi32(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v4su>(__a) & cast<__v4su>(__b))
}
def _mm_maskz_and_epi32(var _U : __mmask8; var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(_mm_mask_and_epi32(_mm_setzero_si128(), __U, __A, __B))
}
def _mm256_andnot_epi32(var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(~cast<__v8su>(__A) & cast<__v8su>(__B))
}
def _mm256_maskz_andnot_epi32(var _U : __mmask8; var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(_mm256_mask_andnot_epi32(_mm256_setzero_si256(), __U, __A, __B))
}
def _mm_andnot_epi32(var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(~cast<__v4su>(__A) & cast<__v4su>(__B))
}
def _mm_maskz_andnot_epi32(var _U : __mmask8; var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(_mm_mask_andnot_epi32(_mm_setzero_si128(), __U, __A, __B))
}
def _mm256_or_epi32(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v8su>(__a) | cast<__v8su>(__b))
}
def _mm256_maskz_or_epi32(var _U : __mmask8; var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(_mm256_mask_or_epi32(_mm256_setzero_si256(), __U, __A, __B))
}
def _mm_or_epi32(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v4su>(__a) | cast<__v4su>(__b))
}
def _mm_maskz_or_epi32(var _U : __mmask8; var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(_mm_mask_or_epi32(_mm_setzero_si128(), __U, __A, __B))
}
def _mm256_xor_epi32(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v8su>(__a) ^ cast<__v8su>(__b))
}
def _mm256_maskz_xor_epi32(var _U : __mmask8; var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(_mm256_mask_xor_epi32(_mm256_setzero_si256(), __U, __A, __B))
}
def _mm_xor_epi32(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v4su>(__a) ^ cast<__v4su>(__b))
}
def _mm_maskz_xor_epi32(var _U : __mmask8; var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(_mm_mask_xor_epi32(_mm_setzero_si128(), __U, __A, __B))
}
def _mm256_and_epi64(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__a) & cast<__v4du>(__b))
}
def _mm256_maskz_and_epi64(var _U : __mmask8; var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(_mm256_mask_and_epi64(_mm256_setzero_si256(), __U, __A, __B))
}
def _mm_and_epi64(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__a) & cast<__v2du>(__b))
}
def _mm_maskz_and_epi64(var _U : __mmask8; var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(_mm_mask_and_epi64(_mm_setzero_si128(), __U, __A, __B))
}
def _mm256_andnot_epi64(var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(~cast<__v4du>(__A) & cast<__v4du>(__B))
}
def _mm256_maskz_andnot_epi64(var _U : __mmask8; var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(_mm256_mask_andnot_epi64(_mm256_setzero_si256(), __U, __A, __B))
}
def _mm_andnot_epi64(var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(~cast<__v2du>(__A) & cast<__v2du>(__B))
}
def _mm_maskz_andnot_epi64(var _U : __mmask8; var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(_mm_mask_andnot_epi64(_mm_setzero_si128(), __U, __A, __B))
}
def _mm256_or_epi64(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__a) | cast<__v4du>(__b))
}
def _mm256_maskz_or_epi64(var _U : __mmask8; var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(_mm256_mask_or_epi64(_mm256_setzero_si256(), __U, __A, __B))
}
def _mm_or_epi64(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__a) | cast<__v2du>(__b))
}
def _mm_maskz_or_epi64(var _U : __mmask8; var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(_mm_mask_or_epi64(_mm_setzero_si128(), __U, __A, __B))
}
def _mm256_xor_epi64(var _a : __m256i; var _b : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__a) ^ cast<__v4du>(__b))
}
def _mm256_maskz_xor_epi64(var _U : __mmask8; var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(_mm256_mask_xor_epi64(_mm256_setzero_si256(), __U, __A, __B))
}
def _mm_xor_epi64(var _a : __m128i; var _b : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__a) ^ cast<__v2du>(__b))
}
def _mm_maskz_xor_epi64(var _U : __mmask8; var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(_mm_mask_xor_epi64(_mm_setzero_si128(), __U, __A, __B))
}
def _mm_load_epi32(var _P : void const?) : __m128i {
    return *cast<__m128i const?>(__P)
}
def _mm256_load_epi32(var _P : void const?) : __m256i {
    return *cast<__m256i const?>(__P)
}
def _mm_store_epi32(var _P : void?; var _A : __m128i) {
    *cast<__m128i?>(__P) = __A
}
def _mm256_store_epi32(var _P : void?; var _A : __m256i) {
    *cast<__m256i?>(__P) = __A
}
def _mm_load_epi64(var _P : void const?) : __m128i {
    return *cast<__m128i const?>(__P)
}
def _mm256_load_epi64(var _P : void const?) : __m256i {
    return *cast<__m256i const?>(__P)
}
def _mm_store_epi64(var _P : void?; var _A : __m128i) {
    *cast<__m128i?>(__P) = __A
}
def _mm256_store_epi64(var _P : void?; var _A : __m256i) {
    *cast<__m256i?>(__P) = __A
}
def _mm_loadu_epi64(var _P : void const?) : __m128i {
    struct __loadu_epi64 {
    __v : __m128i_u
}    return cast<__loadu_epi64 const?>(__P).__v
}
def _mm256_loadu_epi64(var _P : void const?) : __m256i {
    struct __loadu_epi64 {
    __v : __m256i_u
}    return cast<__loadu_epi64 const?>(__P).__v
}
def _mm_loadu_epi32(var _P : void const?) : __m128i {
    struct __loadu_epi32 {
    __v : __m128i_u
}    return cast<__loadu_epi32 const?>(__P).__v
}
def _mm256_loadu_epi32(var _P : void const?) : __m256i {
    struct __loadu_epi32 {
    __v : __m256i_u
}    return cast<__loadu_epi32 const?>(__P).__v
}
def _mm_storeu_epi64(var _P : void?; var _A : __m128i) {
    struct __storeu_epi64 {
    __v : __m128i_u
}    cast<__storeu_epi64?>(__P).__v = __A
}
def _mm256_storeu_epi64(var _P : void?; var _A : __m256i) {
    struct __storeu_epi64 {
    __v : __m256i_u
}    cast<__storeu_epi64?>(__P).__v = __A
}
def _mm_storeu_epi32(var _P : void?; var _A : __m128i) {
    struct __storeu_epi32 {
    __v : __m128i_u
}    cast<__storeu_epi32?>(__P).__v = __A
}
def _mm256_storeu_epi32(var _P : void?; var _A : __m256i) {
    struct __storeu_epi32 {
    __v : __m256i_u
}    cast<__storeu_epi32?>(__P).__v = __A
}
def _mm512_add_epi8(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v64qu>(__A) + cast<__v64qu>(__B))
}
def _mm512_sub_epi8(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v64qu>(__A) - cast<__v64qu>(__B))
}
def _mm512_add_epi16(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v32hu>(__A) + cast<__v32hu>(__B))
}
def _mm512_sub_epi16(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v32hu>(__A) - cast<__v32hu>(__B))
}
def _mm512_mullo_epi16(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v32hu>(__A) * cast<__v32hu>(__B))
}
def _mm512_loadu_epi16(var _P : void const?) : __m512i {
    struct __loadu_epi16 {
    __v : __m512i_u
}    return cast<__loadu_epi16 const?>(__P).__v
}
def _mm512_loadu_epi8(var _P : void const?) : __m512i {
    struct __loadu_epi8 {
    __v : __m512i_u
}    return cast<__loadu_epi8 const?>(__P).__v
}
def _mm512_storeu_epi16(var _P : void?; var _A : __m512i) {
    struct __storeu_epi16 {
    __v : __m512i_u
}    cast<__storeu_epi16?>(__P).__v = __A
}
def _mm512_storeu_epi8(var _P : void?; var _A : __m512i) {
    struct __storeu_epi8 {
    __v : __m512i_u
}    cast<__storeu_epi8?>(__P).__v = __A
}
def _mm512_maskz_popcnt_epi16(var _U : __mmask32; var _B : __m512i) : __m512i {
    return _mm512_mask_popcnt_epi16(cast<__m512i>(_mm512_setzero_si512()), __U, __B)
}
def _mm512_maskz_popcnt_epi8(var _U : __mmask64; var _B : __m512i) : __m512i {
    return _mm512_mask_popcnt_epi8(cast<__m512i>(_mm512_setzero_si512()), __U, __B)
}
def _mm512_bitshuffle_epi64_mask(var _A : __m512i; var _B : __m512i) : __mmask64 {
    return _mm512_mask_bitshuffle_epi64_mask(cast<__mmask64>(-1), __A, __B)
}
def _mm512_broadcastmb_epi64(var _A : __mmask8) : __m512i {
    return cast<__m512i>(_mm512_set1_epi64(cast<int64>(__A)))
}
def _mm512_broadcastmw_epi32(var _A : __mmask16) : __m512i {
    return cast<__m512i>(_mm512_set1_epi32(cast<int>(__A)))
}
def _mm512_maskz_popcnt_epi64(var _U : __mmask8; var _A : __m512i) : __m512i {
    return _mm512_mask_popcnt_epi64(cast<__m512i>(_mm512_setzero_si512()), __U, __A)
}
def _mm512_maskz_popcnt_epi32(var _U : __mmask16; var _A : __m512i) : __m512i {
    return _mm512_mask_popcnt_epi32(cast<__m512i>(_mm512_setzero_si512()), __U, __A)
}
def _mm_maskz_popcnt_epi64(var _U : __mmask8; var _A : __m128i) : __m128i {
    return _mm_mask_popcnt_epi64(cast<__m128i>(_mm_setzero_si128()), __U, __A)
}
def _mm_maskz_popcnt_epi32(var _U : __mmask8; var _A : __m128i) : __m128i {
    return _mm_mask_popcnt_epi32(cast<__m128i>(_mm_setzero_si128()), __U, __A)
}
def _mm256_maskz_popcnt_epi64(var _U : __mmask8; var _A : __m256i) : __m256i {
    return _mm256_mask_popcnt_epi64(cast<__m256i>(_mm256_setzero_si256()), __U, __A)
}
def _mm256_maskz_popcnt_epi32(var _U : __mmask8; var _A : __m256i) : __m256i {
    return _mm256_mask_popcnt_epi32(cast<__m256i>(_mm256_setzero_si256()), __U, __A)
}
def _mm512_mullo_epi64(var _A : __m512i; var _B : __m512i) : __m512i {
    return cast<__m512i>(cast<__v8du>(__A) * cast<__v8du>(__B))
}
def _mm512_xor_pd(var _A : __m512d; var _B : __m512d) : __m512d {
    return cast<__m512d>(cast<__v8du>(__A) ^ cast<__v8du>(__B))
}
def _mm512_xor_ps(var _A : __m512; var _B : __m512) : __m512 {
    return cast<__m512>(cast<__v16su>(__A) ^ cast<__v16su>(__B))
}
def _mm512_or_pd(var _A : __m512d; var _B : __m512d) : __m512d {
    return cast<__m512d>(cast<__v8du>(__A) | cast<__v8du>(__B))
}
def _mm512_or_ps(var _A : __m512; var _B : __m512) : __m512 {
    return cast<__m512>(cast<__v16su>(__A) | cast<__v16su>(__B))
}
def _mm512_and_pd(var _A : __m512d; var _B : __m512d) : __m512d {
    return cast<__m512d>(cast<__v8du>(__A) & cast<__v8du>(__B))
}
def _mm512_and_ps(var _A : __m512; var _B : __m512) : __m512 {
    return cast<__m512>(cast<__v16su>(__A) & cast<__v16su>(__B))
}
def _mm512_andnot_pd(var _A : __m512d; var _B : __m512d) : __m512d {
    return cast<__m512d>(~cast<__v8du>(__A) & cast<__v8du>(__B))
}
def _mm512_andnot_ps(var _A : __m512; var _B : __m512) : __m512 {
    return cast<__m512>(~cast<__v16su>(__A) & cast<__v16su>(__B))
}
def _mm256_maskz_popcnt_epi16(var _U : __mmask16; var _B : __m256i) : __m256i {
    return _mm256_mask_popcnt_epi16(cast<__m256i>(_mm256_setzero_si256()), __U, __B)
}
def _mm_maskz_popcnt_epi16(var _U : __mmask8; var _B : __m128i) : __m128i {
    return _mm_mask_popcnt_epi16(cast<__m128i>(_mm_setzero_si128()), __U, __B)
}
def _mm256_maskz_popcnt_epi8(var _U : __mmask32; var _B : __m256i) : __m256i {
    return _mm256_mask_popcnt_epi8(cast<__m256i>(_mm256_setzero_si256()), __U, __B)
}
def _mm_maskz_popcnt_epi8(var _U : __mmask16; var _B : __m128i) : __m128i {
    return _mm_mask_popcnt_epi8(cast<__m128i>(_mm_setzero_si128()), __U, __B)
}
def _mm256_bitshuffle_epi64_mask(var _A : __m256i; var _B : __m256i) : __mmask32 {
    return _mm256_mask_bitshuffle_epi64_mask(cast<__mmask32>(-1), __A, __B)
}
def _mm_bitshuffle_epi64_mask(var _A : __m128i; var _B : __m128i) : __mmask16 {
    return _mm_mask_bitshuffle_epi64_mask(cast<__mmask16>(-1), __A, __B)
}
def _mm_loadu_epi16(var _P : void const?) : __m128i {
    struct __loadu_epi16 {
    __v : __m128i_u
}    return cast<__loadu_epi16 const?>(__P).__v
}
def _mm256_loadu_epi16(var _P : void const?) : __m256i {
    struct __loadu_epi16 {
    __v : __m256i_u
}    return cast<__loadu_epi16 const?>(__P).__v
}
def _mm_loadu_epi8(var _P : void const?) : __m128i {
    struct __loadu_epi8 {
    __v : __m128i_u
}    return cast<__loadu_epi8 const?>(__P).__v
}
def _mm256_loadu_epi8(var _P : void const?) : __m256i {
    struct __loadu_epi8 {
    __v : __m256i_u
}    return cast<__loadu_epi8 const?>(__P).__v
}
def _mm_storeu_epi16(var _P : void?; var _A : __m128i) {
    struct __storeu_epi16 {
    __v : __m128i_u
}    cast<__storeu_epi16?>(__P).__v = __A
}
def _mm256_storeu_epi16(var _P : void?; var _A : __m256i) {
    struct __storeu_epi16 {
    __v : __m256i_u
}    cast<__storeu_epi16?>(__P).__v = __A
}
def _mm_storeu_epi8(var _P : void?; var _A : __m128i) {
    struct __storeu_epi8 {
    __v : __m128i_u
}    cast<__storeu_epi8?>(__P).__v = __A
}
def _mm256_storeu_epi8(var _P : void?; var _A : __m256i) {
    struct __storeu_epi8 {
    __v : __m256i_u
}    cast<__storeu_epi8?>(__P).__v = __A
}
def _mm_broadcastmb_epi64(var _A : __mmask8) : __m128i {
    return cast<__m128i>(_mm_set1_epi64x(cast<int64>(__A)))
}
def _mm256_broadcastmb_epi64(var _A : __mmask8) : __m256i {
    return cast<__m256i>(_mm256_set1_epi64x(cast<int64>(__A)))
}
def _mm_broadcastmw_epi32(var _A : __mmask16) : __m128i {
    return cast<__m128i>(_mm_set1_epi32(cast<int>(__A)))
}
def _mm256_broadcastmw_epi32(var _A : __mmask16) : __m256i {
    return cast<__m256i>(_mm256_set1_epi32(cast<int>(__A)))
}
def _mm256_mullo_epi64(var _A : __m256i; var _B : __m256i) : __m256i {
    return cast<__m256i>(cast<__v4du>(__A) * cast<__v4du>(__B))
}
def _mm_mullo_epi64(var _A : __m128i; var _B : __m128i) : __m128i {
    return cast<__m128i>(cast<__v2du>(__A) * cast<__v2du>(__B))
}
def _mm512_cvtsh_h(var _a : __m512h) : auto {
    return __a[0]
}
def _mm_setzero_ph() : __m128h {
    return [cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0))]
}
def _mm256_setzero_ph() : __m256h {
    return [cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0))]
}
def _mm512_setzero_ph() : __m512h {
    return [cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0)), cast<auto>(double(0.0))]
}
def _mm512_set1_ph(var _h : auto) : __m512h {
    return cast<__m512h>([__h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h])
}
def _mm512_set_ph(var _h1 : auto; var _h2 : auto; var _h3 : auto; var _h4 : auto; var _h5 : auto; var _h6 : auto; var _h7 : auto; var _h8 : auto; var _h9 : auto; var _h10 : auto; var _h11 : auto; var _h12 : auto; var _h13 : auto; var _h14 : auto; var _h15 : auto; var _h16 : auto; var _h17 : auto; var _h18 : auto; var _h19 : auto; var _h20 : auto; var _h21 : auto; var _h22 : auto; var _h23 : auto; var _h24 : auto; var _h25 : auto; var _h26 : auto; var _h27 : auto; var _h28 : auto; var _h29 : auto; var _h30 : auto; var _h31 : auto; var _h32 : auto) : __m512h {
    return cast<__m512h>([__h32, __h31, __h30, __h29, __h28, __h27, __h26, __h25, __h24, __h23, __h22, __h21, __h20, __h19, __h18, __h17, __h16, __h15, __h14, __h13, __h12, __h11, __h10, __h9, __h8, __h7, __h6, __h5, __h4, __h3, __h2, __h1])
}
def _mm512_set1_pch(var h : auto) : __m512h {
    return cast<__m512h>(_mm512_set1_ps(cast<float>(h)))
}
def _mm_castph_ps(var _a : __m128h) : __m128 {
    return cast<__m128>(__a)
}
def _mm256_castph_ps(var _a : __m256h) : __m256 {
    return cast<__m256>(__a)
}
def _mm512_castph_ps(var _a : __m512h) : __m512 {
    return cast<__m512>(__a)
}
def _mm_castph_pd(var _a : __m128h) : __m128d {
    return cast<__m128d>(__a)
}
def _mm256_castph_pd(var _a : __m256h) : __m256d {
    return cast<__m256d>(__a)
}
def _mm512_castph_pd(var _a : __m512h) : __m512d {
    return cast<__m512d>(__a)
}
def _mm_castph_si128(var _a : __m128h) : __m128i {
    return cast<__m128i>(__a)
}
def _mm256_castph_si256(var _a : __m256h) : __m256i {
    return cast<__m256i>(__a)
}
def _mm512_castph_si512(var _a : __m512h) : __m512i {
    return cast<__m512i>(__a)
}
def _mm_castps_ph(var _a : __m128) : __m128h {
    return cast<__m128h>(__a)
}
def _mm256_castps_ph(var _a : __m256) : __m256h {
    return cast<__m256h>(__a)
}
def _mm512_castps_ph(var _a : __m512) : __m512h {
    return cast<__m512h>(__a)
}
def _mm_castpd_ph(var _a : __m128d) : __m128h {
    return cast<__m128h>(__a)
}
def _mm256_castpd_ph(var _a : __m256d) : __m256h {
    return cast<__m256h>(__a)
}
def _mm512_castpd_ph(var _a : __m512d) : __m512h {
    return cast<__m512h>(__a)
}
def _mm_castsi128_ph(var _a : __m128i) : __m128h {
    return cast<__m128h>(__a)
}
def _mm256_castsi256_ph(var _a : __m256i) : __m256h {
    return cast<__m256h>(__a)
}
def _mm512_castsi512_ph(var _a : __m512i) : __m512h {
    return cast<__m512h>(__a)
}
def _mm512_add_ph(var _A : __m512h; var _B : __m512h) : __m512h {
    return cast<__m512h>(cast<__v32hf>(__A) + cast<__v32hf>(__B))
}
def _mm512_sub_ph(var _A : __m512h; var _B : __m512h) : __m512h {
    return cast<__m512h>(cast<__v32hf>(__A) - cast<__v32hf>(__B))
}
def _mm512_mul_ph(var _A : __m512h; var _B : __m512h) : __m512h {
    return cast<__m512h>(cast<__v32hf>(__A) * cast<__v32hf>(__B))
}
def _mm512_div_ph(var _A : __m512h; var _B : __m512h) : __m512h {
    return cast<__m512h>(cast<__v32hf>(__A) / cast<__v32hf>(__B))
}
def _mm512_abs_ph(var _A : __m512h) : __m512h {
    return cast<__m512h>(_mm512_and_epi32(_mm512_set1_epi32(2147450879), cast<__m512i>(__A)))
}
def _mm512_conj_pch(var _A : __m512h) : __m512h {
    return cast<__m512h>(_mm512_xor_ps(cast<__m512>(__A), _mm512_set1_ps(-double(0.0))))
}
def _mm_add_sh(var _A : __m128h; var _B : __m128h) : __m128h {
    __A[0] += __B[0]
    return __A
}
def _mm_sub_sh(var _A : __m128h; var _B : __m128h) : __m128h {
    __A[0] -= __B[0]
    return __A
}
def _mm_mul_sh(var _A : __m128h; var _B : __m128h) : __m128h {
    __A[0] *= __B[0]
    return __A
}
def _mm_div_sh(var _A : __m128h; var _B : __m128h) : __m128h {
    __A[0] /= __B[0]
    return __A
}
def _mm_load_sh(var _dp : void const?) : __m128h {
    struct __mm_load_sh_struct {
    __u : auto
}    var __u : auto = cast<__mm_load_sh_struct const?>(__dp).__u
    return [__u, cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0)]
}
def _mm512_load_ph(var _p : void const?) : __m512h {
    return *cast<__m512h const?>(__p)
}
def _mm256_load_ph(var _p : void const?) : __m256h {
    return *cast<__m256h const?>(__p)
}
def _mm_load_ph(var _p : void const?) : __m128h {
    return *cast<__m128h const?>(__p)
}
def _mm512_loadu_ph(var _p : void const?) : __m512h {
    struct __loadu_ph {
    __v : __m512h_u
}    return cast<__loadu_ph const?>(__p).__v
}
def _mm256_loadu_ph(var _p : void const?) : __m256h {
    struct __loadu_ph {
    __v : __m256h_u
}    return cast<__loadu_ph const?>(__p).__v
}
def _mm_loadu_ph(var _p : void const?) : __m128h {
    struct __loadu_ph {
    __v : __m128h_u
}    return cast<__loadu_ph const?>(__p).__v
}
def _mm_store_sh(var _dp : void?; var _a : __m128h) {
    struct __mm_store_sh_struct {
    __u : auto
}    cast<__mm_store_sh_struct?>(__dp).__u = __a[0]
}
def _mm512_store_ph(var _P : void?; var _A : __m512h) {
    *cast<__m512h?>(__P) = __A
}
def _mm256_store_ph(var _P : void?; var _A : __m256h) {
    *cast<__m256h?>(__P) = __A
}
def _mm_store_ph(var _P : void?; var _A : __m128h) {
    *cast<__m128h?>(__P) = __A
}
def _mm512_storeu_ph(var _P : void?; var _A : __m512h) {
    struct __storeu_ph {
    __v : __m512h_u
}    cast<__storeu_ph?>(__P).__v = __A
}
def _mm256_storeu_ph(var _P : void?; var _A : __m256h) {
    struct __storeu_ph {
    __v : __m256h_u
}    cast<__storeu_ph?>(__P).__v = __A
}
def _mm_storeu_ph(var _P : void?; var _A : __m128h) {
    struct __storeu_ph {
    __v : __m128h_u
}    cast<__storeu_ph?>(__P).__v = __A
}
def _mm_move_sh(var _a : __m128h; var _b : __m128h) : __m128h {
    __a[0] = __b[0]
    return __a
}
def _mm_cvtsi16_si128(var _a : int) : __m128i {
    return cast<__m128i>([__a, 0, 0, 0, 0, 0, 0, 0])
}
def _mm_cvtsi128_si16(var _a : __m128i) : int {
    var __b : __v8hi = cast<__v8hi>(__a)
    return __b[0]
}
def _mm_cvtu32_sh(var _A : __m128h; var _B : uint) : __m128h {
    __A[0] = cast<auto>(__B)
    return __A
}
def _mm_cvtu64_sh(var _A : __m128h; var _B : uint64) : __m128h {
    __A[0] = cast<auto>(__B)
    return __A
}
def _mm_cvti32_sh(var _A : __m128h; var _B : int) : __m128h {
    __A[0] = cast<auto>(__B)
    return __A
}
def _mm_cvti64_sh(var _A : __m128h; var _B : int64) : __m128h {
    __A[0] = cast<auto>(__B)
    return __A
}
def _mm_cvtsh_h(var _a : __m128h) : auto {
    return __a[0]
}
def _mm256_cvtsh_h(var _a : __m256h) : auto {
    return __a[0]
}
def _mm_set_sh(var _h : auto) : __m128h {
    return [__h, cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0), cast<auto>(0)]
}
def _mm_set1_ph(var _h : auto) : __m128h {
    return cast<__m128h>([__h, __h, __h, __h, __h, __h, __h, __h])
}
def _mm256_set1_ph(var _h : auto) : __m256h {
    return cast<__m256h>([__h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h, __h])
}
def _mm_set_ph(var _h1 : auto; var _h2 : auto; var _h3 : auto; var _h4 : auto; var _h5 : auto; var _h6 : auto; var _h7 : auto; var _h8 : auto) : __m128h {
    return cast<__m128h>([__h8, __h7, __h6, __h5, __h4, __h3, __h2, __h1])
}
def _mm256_set1_pch(var h : auto) : __m256h {
    return cast<__m256h>(_mm256_set1_ps(cast<float>(h)))
}
def _mm_set1_pch(var h : auto) : __m128h {
    return cast<__m128h>(_mm_set1_ps(cast<float>(h)))
}
def _mm256_set_ph(var _h1 : auto; var _h2 : auto; var _h3 : auto; var _h4 : auto; var _h5 : auto; var _h6 : auto; var _h7 : auto; var _h8 : auto; var _h9 : auto; var _h10 : auto; var _h11 : auto; var _h12 : auto; var _h13 : auto; var _h14 : auto; var _h15 : auto; var _h16 : auto) : __m256h {
    return cast<__m256h>([__h16, __h15, __h14, __h13, __h12, __h11, __h10, __h9, __h8, __h7, __h6, __h5, __h4, __h3, __h2, __h1])
}
def _mm256_add_ph(var _A : __m256h; var _B : __m256h) : __m256h {
    return cast<__m256h>(cast<__v16hf>(__A) + cast<__v16hf>(__B))
}
def _mm_add_ph(var _A : __m128h; var _B : __m128h) : __m128h {
    return cast<__m128h>(cast<__v8hf>(__A) + cast<__v8hf>(__B))
}
def _mm256_sub_ph(var _A : __m256h; var _B : __m256h) : __m256h {
    return cast<__m256h>(cast<__v16hf>(__A) - cast<__v16hf>(__B))
}
def _mm_sub_ph(var _A : __m128h; var _B : __m128h) : __m128h {
    return cast<__m128h>(cast<__v8hf>(__A) - cast<__v8hf>(__B))
}
def _mm256_mul_ph(var _A : __m256h; var _B : __m256h) : __m256h {
    return cast<__m256h>(cast<__v16hf>(__A) * cast<__v16hf>(__B))
}
def _mm_mul_ph(var _A : __m128h; var _B : __m128h) : __m128h {
    return cast<__m128h>(cast<__v8hf>(__A) * cast<__v8hf>(__B))
}
def _mm256_div_ph(var _A : __m256h; var _B : __m256h) : __m256h {
    return cast<__m256h>(cast<__v16hf>(__A) / cast<__v16hf>(__B))
}
def _mm_div_ph(var _A : __m128h; var _B : __m128h) : __m128h {
    return cast<__m128h>(cast<__v8hf>(__A) / cast<__v8hf>(__B))
}
def _mm256_abs_ph(var _A : __m256h) : __m256h {
    return cast<__m256h>(_mm256_and_epi32(_mm256_set1_epi32(2147450879), cast<__m256i>(__A)))
}
def _mm_abs_ph(var _A : __m128h) : __m128h {
    return cast<__m128h>(_mm_and_epi32(_mm_set1_epi32(2147450879), cast<__m128i>(__A)))
}
def _mm256_conj_pch(var _A : __m256h) : __m256h {
    return cast<__m256h>(_mm256_xor_ps(cast<__m256>(__A), _mm256_set1_ps(-double(0.0))))
}
def _mm_conj_pch(var _A : __m128h) : __m128h {
    return cast<__m128h>(_mm_xor_ps(cast<__m128>(__A), _mm_set1_ps(-double(0.0))))
}
def _mm512_cvtpbh_ps(var _A : __m256bh) : __m512 {
    return _mm512_castsi512_ps(cast<__m512i>(_mm512_slli_epi32(cast<__m512i>(_mm512_cvtepi16_epi32(cast<__m256i>(__A))), 16)))
}
def _mm512_maskz_cvtpbh_ps(var _U : __mmask16; var _A : __m256bh) : __m512 {
    return _mm512_castsi512_ps(cast<__m512i>(_mm512_slli_epi32(cast<__m512i>(_mm512_maskz_cvtepi16_epi32(cast<__mmask16>(__U), cast<__m256i>(__A))), 16)))
}
def _mm512_mask_cvtpbh_ps(var _S : __m512; var _U : __mmask16; var _A : __m256bh) : __m512 {
    return _mm512_castsi512_ps(cast<__m512i>(_mm512_mask_slli_epi32(cast<__m512i>(__S), cast<__mmask16>(__U), cast<__m512i>(_mm512_cvtepi16_epi32(cast<__m256i>(__A))), 16)))
}
def _mm_cvtness_sbh(var _A : float) : auto {
    var __V : __v4sf = [__A, cast<float>(0), cast<float>(0), cast<float>(0)]
    return cast<auto>(__R[0])
}
def _mm_cvtpbh_ps(var _A : __m128bh) : __m128 {
    return _mm_castsi128_ps(cast<__m128i>(_mm_slli_epi32(cast<__m128i>(_mm_cvtepi16_epi32(cast<__m128i>(__A))), 16)))
}
def _mm256_cvtpbh_ps(var _A : __m128bh) : __m256 {
    return _mm256_castsi256_ps(cast<__m256i>(_mm256_slli_epi32(cast<__m256i>(_mm256_cvtepi16_epi32(cast<__m128i>(__A))), 16)))
}
def _mm_maskz_cvtpbh_ps(var _U : __mmask8; var _A : __m128bh) : __m128 {
    return _mm_castsi128_ps(cast<__m128i>(_mm_slli_epi32(cast<__m128i>(_mm_maskz_cvtepi16_epi32(cast<__mmask8>(__U), cast<__m128i>(__A))), 16)))
}
def _mm256_maskz_cvtpbh_ps(var _U : __mmask8; var _A : __m128bh) : __m256 {
    return _mm256_castsi256_ps(cast<__m256i>(_mm256_slli_epi32(cast<__m256i>(_mm256_maskz_cvtepi16_epi32(cast<__mmask8>(__U), cast<__m128i>(__A))), 16)))
}
def _mm_mask_cvtpbh_ps(var _S : __m128; var _U : __mmask8; var _A : __m128bh) : __m128 {
    return _mm_castsi128_ps(cast<__m128i>(_mm_mask_slli_epi32(cast<__m128i>(__S), cast<__mmask8>(__U), cast<__m128i>(_mm_cvtepi16_epi32(cast<__m128i>(__A))), 16)))
}
def _mm256_mask_cvtpbh_ps(var _S : __m256; var _U : __mmask8; var _A : __m128bh) : __m256 {
    return _mm256_castsi256_ps(cast<__m256i>(_mm256_mask_slli_epi32(cast<__m256i>(__S), cast<__mmask8>(__U), cast<__m256i>(_mm256_cvtepi16_epi32(cast<__m128i>(__A))), 16)))
}
def _mm512_maskz_gf2p8mul_epi8(var _U : __mmask64; var _A : __m512i; var _B : __m512i) : __m512i {
    return _mm512_mask_gf2p8mul_epi8(cast<__m512i>(_mm512_setzero_si512()), __U, __A, __B)
}
def _mm_maskz_gf2p8mul_epi8(var _U : __mmask16; var _A : __m128i; var _B : __m128i) : __m128i {
    return _mm_mask_gf2p8mul_epi8(cast<__m128i>(_mm_setzero_si128()), __U, __A, __B)
}
def _mm256_maskz_gf2p8mul_epi8(var _U : __mmask32; var _A : __m256i; var _B : __m256i) : __m256i {
    return _mm256_mask_gf2p8mul_epi8(cast<__m256i>(_mm256_setzero_si256()), __U, __A, __B)
}
def _loadbe_i16(var _P : void const?) : int {
    struct __loadu_i16 {
    __v : int
}    return cast<int>(0)
}
def _storebe_i16(var _P : void?; var _D : int) {
    struct __storeu_i16 {
    __v : int
}    cast<__storeu_i16?>(__P).__v = 0
}
def _loadbe_i32(var _P : void const?) : int {
    struct __loadu_i32 {
    __v : uint
}    return cast<int>(0)
}
def _storebe_i32(var _P : void?; var _D : int) {
    struct __storeu_i32 {
    __v : uint
}    cast<__storeu_i32?>(__P).__v = 0
}
def _loadbe_i64(var _P : void const?) : int64 {
    struct __loadu_i64 {
    __v : uint64
}    return cast<int64>(0)
}
def _storebe_i64(var _P : void?; var _D : int64) {
    struct __storeu_i64 {
    __v : uint64
}    cast<__storeu_i64?>(__P).__v = 0
}
def _tile_loadd(var dst : __tile1024i?; var base : void const?; var stride : uint64) {
    dst.tile = _tile_loadd_internal(dst.row, dst.col, base, stride)
}
def _tile_stream_loadd(var dst : __tile1024i?; var base : void const?; var stride : uint64) {
    dst.tile = _tile_loaddt1_internal(dst.row, dst.col, base, stride)
}
def _tile_dpbssd(var dst : __tile1024i?; var src0 : __tile1024i; var src1 : __tile1024i) {
    dst.tile = _tile_dpbssd_internal(src0.row, src1.col, src0.col, dst.tile, src0.tile, src1.tile)
}
def _tile_dpbsud(var dst : __tile1024i?; var src0 : __tile1024i; var src1 : __tile1024i) {
    dst.tile = _tile_dpbsud_internal(src0.row, src1.col, src0.col, dst.tile, src0.tile, src1.tile)
}
def _tile_dpbusd(var dst : __tile1024i?; var src0 : __tile1024i; var src1 : __tile1024i) {
    dst.tile = _tile_dpbusd_internal(src0.row, src1.col, src0.col, dst.tile, src0.tile, src1.tile)
}
def _tile_dpbuud(var dst : __tile1024i?; var src0 : __tile1024i; var src1 : __tile1024i) {
    dst.tile = _tile_dpbuud_internal(src0.row, src1.col, src0.col, dst.tile, src0.tile, src1.tile)
}
def _tile_stored(var base : void?; var stride : uint64; var src : __tile1024i) {
    _tile_stored_internal(src.row, src.col, base, stride, src.tile)
}
def _tile_dpbf16ps(var dst : __tile1024i?; var src0 : __tile1024i; var src1 : __tile1024i) {
    dst.tile = _tile_dpbf16ps_internal(src0.row, src1.col, src0.col, dst.tile, src0.tile, src1.tile)
}
def _tile_dpfp16ps(var dst : __tile1024i?; var src0 : __tile1024i; var src1 : __tile1024i) {
    dst.tile = _tile_dpfp16ps_internal(src0.row, src1.col, src0.col, dst.tile, src0.tile, src1.tile)
}
def _tile_cmmimfp16ps(var dst : __tile1024i?; var src0 : __tile1024i; var src1 : __tile1024i) {
    dst.tile = _tile_cmmimfp16ps_internal(src0.row, src1.col, src0.col, dst.tile, src0.tile, src1.tile)
}
def _tile_cmmrlfp16ps(var dst : __tile1024i?; var src0 : __tile1024i; var src1 : __tile1024i) {
    dst.tile = _tile_cmmrlfp16ps_internal(src0.row, src1.col, src0.col, dst.tile, src0.tile, src1.tile)
}
def unpack_128_2x128(var data : __m128i; var data_lo : __m128i?; var data_hi : __m128i?) {
    *data_lo = _mm_unpacklo_epi8(data, _mm_setzero_si128())
    *data_hi = _mm_unpackhi_epi8(data, _mm_setzero_si128())
}
def zero_init_all() {
    var a : __m128
    var b : __m256
    var c : __m128d
    var d : __m128i
    var ep : __m256d
    var e : __m256d
    var f : __m256i
}
def call_all() : ShuffleVectors {
    var a : __m128 = _mm_setr_ps(cast<float>(double(7.8)), cast<float>(double(5.6)), cast<float>(double(3.4)), cast<float>(double(1.2)))
    var b : __m128d = _mm_set1_pd(double(4.13))
    var d : __m256 = _mm256_set1_ps(cast<float>(double(45.2)))
    var e : __m256d = _mm256_set_pd(double(1.1), double(2.2), double(3.3), double(4.4))
    var f : __m128i = _mm_set1_epi8(123)
    var g : __m256i = _mm256_set_epi32(14, 18, 22, 33, -11, -3, 8, 300)
    var h : __m256d = _mm256_set_pd(double(5.5), double(6.6), double(7.7), double(8.8))
    return sv
}
def vector_init_lists() : VectorInitLists {
    var il : VectorInitLists = [[double(1.2999999523162842), double(2.299999952316284), double(3.4000000953674316), double(4.400000095367432)], [double(2.200000047683716), double(4.400000095367432), double(5.599999904632568), double(4.300000190734863), double(6.699999809265137), double(6.599999904632568), double(5.5), double(8.800000190734863)], [double(2.2), double(4.4)], [double(2.2), double(3.3), double(4.4), double(5.5)], [45, 32], [12, 34, 56, 78]]
    return il
}
def vector_init_lists_used() : VectorInitLists {
    var a : __m128 = [double(1.2999999523162842), double(2.299999952316284), double(3.4000000953674316), double(4.400000095367432)]
    var b : __m256 = [double(2.200000047683716), double(4.400000095367432), double(5.599999904632568), double(4.300000190734863), double(6.699999809265137), double(6.599999904632568), double(5.5), double(8.800000190734863)]
    var c : __m128d = [double(2.2), double(4.4)]
    var d : __m256d = [double(2.2), double(3.3), double(4.4), double(5.5)]
    var e : __m128i = [45, 32]
    var f : __m256i = [12, 34, 56, 78]
    var il : VectorInitLists = [a, b, c, d, e, f]
    return il
}
var static_m128 : __m128 = [double(1.2999999523162842), double(2.299999952316284), double(3.4000000953674316), double(4.400000095367432)]

var static_m256 : __m256 = [double(2.200000047683716), double(4.400000095367432), double(5.599999904632568), double(4.300000190734863), double(6.699999809265137), double(6.599999904632568), double(5.5), double(8.800000190734863)]

var static_m128d : __m128d = [double(2.2), double(4.4)]

var static_m256d : __m256d = [double(2.2), double(3.3), double(4.4), double(5.5)]

var static_m128i : __m128i = [45, 32]

var static_m256i : __m256i = [12, 34, 56, 78]

var static_uninit_m128 : __m128

var static_uninit_m256 : __m256

var static_uninit_m128d : __m128d

var static_uninit_m256d : __m256d

var static_uninit_m128i : __m128i

var static_uninit_m256i : __m256i

