typedef int int4 __attribute__((vector_size(16)));

int4 unsupported_simd_shuffle(int4 left, int4 right) {
    return __builtin_shufflevector(left, right, 0, 5, 2, 7);
}
