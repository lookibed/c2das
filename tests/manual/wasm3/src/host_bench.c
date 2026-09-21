/* Benchmark entrypoint over a .wasm module named by the last argument.
 *
 * The same values as `src/host.c` plus the time spent parsing and loading the
 * module (setup_us) and the time of the call loop (decode_us), measured with
 * `clock_gettime(CLOCK_MONOTONIC)`.  Results are collected first and printed
 * after the timed loop, and the file is read before any timer starts, so the
 * two numbers cover the interpreter and nothing else.
 *
 * Through `src/all_host_bench.c` this is also a translation input under
 * `--libc std`: `include/stdio.h` and `include/time.h` declare the libc
 * subset with the glibc ABI.  See `src/host.c` for why the module's bytes
 * live in a static buffer.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

#include "wasm3.h"

#define MAX_WASM_BYTES (1024 * 1024)
#define M3_STACK_BYTES (64 * 1024)

static uint8_t wasm_bytes[MAX_WASM_BYTES];

static const int fib_inputs[] = {1, 2, 5, 10, 15, 20, 24};
#define FIB_INPUT_COUNT ((int)(sizeof(fib_inputs) / sizeof(fib_inputs[0])))

static int64_t results[FIB_INPUT_COUNT];

static int64_t now_us(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000 + ts.tv_nsec / 1000;
}

static int32_t load_last_argument(int argc, char **argv) {
    FILE *f = 0;
    size_t got = 0;

    if (argc < 2) {
        return 0;
    }
    f = fopen(argv[argc - 1], "rb");
    if (!f) {
        return 0;
    }
    got = fread(wasm_bytes, 1, MAX_WASM_BYTES, f);
    fclose(f);
    return (int32_t)got;
}

static M3Result call_fib(IM3Function fib, int n, int64_t *out) {
    M3Result result = m3Err_none;

    if (m3_GetArgType(fib, 0) == c_m3Type_i64) {
        uint64_t value = 0;
        result = m3_CallV(fib, (uint64_t)n);
        if (result) {
            return result;
        }
        result = m3_GetResultsV(fib, &value);
        *out = (int64_t)value;
    } else {
        uint32_t value = 0;
        result = m3_CallV(fib, (uint32_t)n);
        if (result) {
            return result;
        }
        result = m3_GetResultsV(fib, &value);
        *out = (int64_t)value;
    }
    return result;
}

int main(int argc, char **argv) {
    IM3Environment env = 0;
    IM3Runtime runtime = 0;
    IM3Module module = 0;
    IM3Function fib = 0;
    M3Result result = m3Err_none;
    int32_t length = 0;
    int count = 0;
    int i = 0;
    int64_t t0 = 0;
    int64_t t1 = 0;
    int64_t t2 = 0;

    setvbuf(stdout, NULL, _IONBF, 0);

    length = load_last_argument(argc, argv);
    if (length <= 0) {
        printf("load=0\n");
        return 2;
    }

    env = m3_NewEnvironment();
    if (!env) {
        printf("error=environment\n");
        return 1;
    }
    runtime = m3_NewRuntime(env, M3_STACK_BYTES, NULL);
    if (!runtime) {
        printf("error=runtime\n");
        return 1;
    }

    t0 = now_us();
    result = m3_ParseModule(env, &module, wasm_bytes, (uint32_t)length);
    if (result) {
        printf("error=%s\n", result);
        return 1;
    }
    result = m3_LoadModule(runtime, module);
    if (result) {
        printf("error=%s\n", result);
        return 1;
    }
    result = m3_FindFunction(&fib, runtime, "fib");
    if (result) {
        printf("error=%s\n", result);
        return 1;
    }
    t1 = now_us();

    for (i = 0; i < FIB_INPUT_COUNT; i++) {
        result = call_fib(fib, fib_inputs[i], &results[i]);
        if (result) {
            printf("error=%s\n", result);
            return 1;
        }
        count += 1;
    }
    t2 = now_us();

    printf("bytes=%d\n", (int)length);
    for (i = 0; i < count; i++) {
        printf("fib[%d]=%lld\n", fib_inputs[i], (long long)results[i]);
    }
    printf("count=%d\n", count);
    printf("setup_us=%lld\n", (long long)(t1 - t0));
    printf("decode_us=%lld\n", (long long)(t2 - t1));

    m3_FreeRuntime(runtime);
    m3_FreeEnvironment(env);
    return count == FIB_INPUT_COUNT ? 0 : 1;
}
