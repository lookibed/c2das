typedef int int4 __attribute__((vector_size(16)));
typedef float float4 __attribute__((vector_size(16)));

float4 unsupported_simd_convert(int4 value) {
    return __builtin_convertvector(value, float4);
}
