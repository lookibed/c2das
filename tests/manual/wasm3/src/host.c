/* C entrypoint over a .wasm module named by the last argument.
 *
 * Parses and loads the module into a wasm3 runtime, finds its `fib` export,
 * calls it for a fixed list of n and prints one line per value.  It is the C
 * reference program of the corpus and, through `src/all_host.c`, a
 * translation input under `--libc std`: `include/stdio.h` declares the libc
 * subset with the glibc ABI, so the same source links against the real libc.
 *
 * The module's bytes go into a static buffer, never into the fixture's bump
 * heap: `m3_ParseModule` keeps pointing into them for as long as the module
 * is loaded, and the translated graph's allocator is rewound underneath a
 * heap block (the same reason `tests/manual/plmpeg-stream` reads into a
 * static array).
 *
 * `fib` is i32 in `fixtures/fib32.wasm` and i64 in `fixtures/fib64.wasm`, so
 * the call is dispatched on the export's own argument type rather than
 * assuming one.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include "wasm3.h"

#define MAX_WASM_BYTES (1024 * 1024)
#define M3_STACK_BYTES (64 * 1024)

static uint8_t wasm_bytes[MAX_WASM_BYTES];

static const int fib_inputs[] = {1, 2, 5, 10, 15, 20, 24};
#define FIB_INPUT_COUNT ((int)(sizeof(fib_inputs) / sizeof(fib_inputs[0])))

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

    setvbuf(stdout, NULL, _IONBF, 0);

    length = load_last_argument(argc, argv);
    if (length <= 0) {
        printf("load=0\n");
        return 2;
    }
    printf("bytes=%d\n", (int)length);

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

    for (i = 0; i < FIB_INPUT_COUNT; i++) {
        int64_t value = 0;
        result = call_fib(fib, fib_inputs[i], &value);
        if (result) {
            printf("error=%s\n", result);
            return 1;
        }
        printf("fib[%d]=%lld\n", fib_inputs[i], (long long)value);
        count += 1;
    }
    printf("count=%d\n", count);

    m3_FreeRuntime(runtime);
    m3_FreeEnvironment(env);
    return count == FIB_INPUT_COUNT ? 0 : 1;
}
