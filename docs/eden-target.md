# daslang in EdenSpark 1.0 vs daslang master: a note for an Eden target of c2das

Measured 2026-10-03 to 2026-10-06 on EdenSpark **1.0.0.12 and 1.0.0.19**
(`eden.exe` of 2026-10-01 and 2026-10-05) against daslang master in
`/root/daScript` (**v0.6.4-481**, commit 69a589623). Every row below comes
from a probe compiled and run in both: in the editor as a `[cheat]` of a
throwaway project file, locally with `daslang` on the command line. The
harness and the probe sources live in
`<eden project>/modules/wasm3das/tmp/.probes/` (`probe.sh`, `run.sh`,
`mods.sh`); the older facts (rows marked *0.9*) come from porting wasm3das to
the editor (`modules/wasm3das/docs/eden-port/DESIGN.md` section 1,
`docs/eden-abi/PIPELINE.md` section 7) and were re-checked where marked.

## 1. Which daslang the editor runs

| Fact | Value |
|---|---|
| `get_das_version()` | **0.6.4** in Eden 1.0 (it was 0.6.3 in Eden 0.9.0.34) |
| Position inside 0.6.4 | **older than master v0.6.4-481**: it has #3410 (bare named calls), #3420 (call-style casts), #3424 (distinct types), #3430 (`float16`), #3345 (64-bit fixed-array indexes), #3724 (`max_unreserved_size`, `ensure_capacity`), #3389 (`[inline]`); it lacks #3684 (the `!` original-operator family: `a!.x` is a syntax error) and #3783 (`@` metadata on locals: `var @exact_size x` is a syntax error) and #3980 (`memmove` builtin) |
| Bundled daslib | the editor's own copy (`D:/Prog/EdenSpark/daslib/builtin.das` in stack traces), inside its vromfs; not readable from disk |
| Engine modules | `engine.core` and friends exist only in the editor; a file that requires them cannot be compiled locally |

## 2. The sandbox: what the editor refuses (master accepts all of it)

| Construct | Editor | Error text |
|---|---|---|
| `unsafe { }` block, `unsafe(expr)`, `[unsafe]`-requiring calls | refused | `unsafe function @mod::f` |
| `addr(x)`, `addr<T?>(x)` | refused | same (needs unsafe) |
| `reinterpret<T>(x)` | refused | `unsafe function '...'` |
| pointer arithmetic `p += n`, `p[i]` on `T?` | refused | needs unsafe |
| `intptr(...)` of an address | refused | `address of reference requires unsafe` (master too, without the unsafe) |
| `memcpy`, `memset`-style builtins on pointers | refused | needs unsafe |
| `delete p` of a pointer (`new` struct / class) | refused | needs unsafe |
| `options no_unsafe = false` | refused | `option no_unsafe is not allowed here` |
| `options heap_size_limit` | refused (*0.9*) | `not allowed here` |
| local reference `let r & = expr` to a non-local | refused | `local reference to non-local expression is unsafe` |
| returning a reference into a table (`return tab[k]` as `T&`) | refused | needs unsafe |
| modules `fio`, `network`, `jobque_boost`, `ast`, `ast_boost`, `templates_boost`, `safe_addr`, `linked_list` (*0.9*), the full 1.0 list in section 6 | refused | `internal error` when several fail |

What stays allowed and is enough for C semantics on a byte heap:

| Construct | Editor |
|---|---|
| `new S()` and `S?` fields, `p.x`, `*p` (read), `?.`, `??`, `== null` | yes |
| `void?` as a parameter type, `null` | yes |
| `typeinfo sizeof(type<S>)`, `typeinfo alignof` | yes |
| `function<(...) : T>` values, `@@fn`, `invoke`, arrays of them | yes |
| lambdas with capture `@(x) { }` | yes |
| classes with `abstract` / `override`, `->` calls | yes |
| generics `auto(T)` | yes |
| variants, `is` / `as` | yes |
| tuples and `let (a, b) = t` | yes |
| `goto label N` / `label N:`, also out of a loop | yes |
| `try` / `recover` (panics, integer divide by zero) | yes |
| `daslib/math_bits` (`float_bits_to_uint`, `uint_bits_to_float`, the 64-bit pair) | yes, the safe way to move float bits |
| `static_let` (`static_let() { var n = 0 }`) | yes |
| fixed arrays `T[N]`, also as globals of 1 MB, indexes of `int64` | yes |
| `delete arr` of an array value, `var inscope` | yes |
| global `var`s of any size within the heap limit | yes |

## 3. Runtime behaviour that differs from master

| Behaviour | Master | Editor 1.0 | Consequence for translated C |
|---|---|---|---|
| NaN comparisons | IEEE: `NaN == NaN` false, `NaN < 1` false | **not IEEE**: `NaN == NaN` true, `NaN < 1` true, `NaN != NaN` false (same in 0.9) | every float compare must be guarded: `eq = !isnan(a) && !isnan(b) && a == b`, `ne = isnan(a) \|\| isnan(b) \|\| a != b`, ordered compares false when either side is NaN; `isnan` must be a bit test (`math_bits`), not `x != x` |
| denormal floats | kept | **flushed to zero** in every script context (cheats included since 1.0; in 0.9 only `on_update` flushed) | subnormal results become 0; C code that depends on them (strtod of 4.9e-324, `nextafter`, some numerics) differs; nothing in the script can change the mode |
| integer overflow | wraps (int, uint, int64, uint64) | same | C signed overflow is UB anyway; unsigned wrap matches |
| `int8/uint8/int16/uint16` arithmetic | **no operators** (`numeric operator '+' is not defined for storage types`) | same | widen to `int`/`uint` for every operation and narrow on store (C integer promotion already says so) |
| `int(3e9)` (out-of-range float to int) | `-2147483648`, no panic | same | C UB; matches x86 `cvttsd2si` |
| `uint8(300)` | 44 (truncation) | same | matches C conversion to unsigned |
| integer `/` and `%` | truncate toward zero, `-7 / 2 = -3`, `-7 % 2 = -1` | same | matches C99 |
| `1 << 33` on `int` | 2 (count masked to 5 bits, x86) | same | C UB; mask explicitly if the source relies on something else |
| divide by zero | panic, catchable by `try/recover` | same | a C program that divides by zero traps the guest instead of crashing the host |
| `resize` past 64 MB without `reserve` | panic: `grows past max_unreserved_size (67108864 bytes); reserve the final size first` | same | `reserve(heap, final)` before `resize` (wasm3das ResizeMemory does) or `ensure_capacity` |
| script heap | unlimited | **100 MiB per context**, `heap_size_limit` refused (*0.9*) | the whole C heap plus every other array must fit; `array` capacity grows to a power of two unless reserved exactly |
| when garbage is collected | `delete` / `inscope` free at once; the rest at context end | `delete` frees at once (measured: 10 x 1 MB allocate+delete leaves 0); everything else only **between engine frames** | long single calls (a C `main` that runs to completion in one frame) must free what they allocate explicitly or stay well under 100 MiB |
| `length(array)` | `int` | `int` | arrays above 2^31-1 elements are impossible |
| hot reload of scripts | n/a | globals carried over; every stored function value whose type mentions a struct (e.g. `function<(var rt : Runtime) : int>`) becomes **null**, a `function<() : bool>` survives | function-pointer tables of translated C must be rebuilt after a reload (wasm3das: `abi_is_stale` + relink) |
| `print` | stdout | the editor console, each line followed by a `file:line (function)` line | |
| `is_standalone_exe()` | false | true in an exported build | |

### Engine settings behind these rules (from an exported build's log)

`game_das_very_safe_context:b=yes` and `game_das_force_inscope_pod:b=yes`
(the reason garbage is collected only between frames and POD locals are
scoped), `game_das_max_heap_allocated`, `game_das_max_string_heap_allocated`
and `game_das_max_static_variables_size` each 104857600, `game_das_enable_rtti`
and `game_das_enable_serialization` on, `game_das_gen_2_make_syntax` on,
`llvm_jit_enabled:b=no` and not overridable ("not allowed for overwrite").
The engine runs scripts in `INTERPRET mode` with `aot lib size=0`, in the
editor and in exported builds alike, at the same speed
(`modules/wasm3das/docs/eden-port/BUILDS.md`).

A **published (exported) build is stricter than the editor**: a call to a
deprecated function is a compile error (the editor only warns), e.g. the
whole `engine.input.global_input_state` module. Translated code must
stay on non-deprecated engine APIs, and some daslib modules that refuse to
build show only `internal error` (`cross_context` is reported as
`FILE NOT FOUND`: not shipped with the editor at all).

## 4. Syntax and library differences inside 0.6.4 (editor vs master)

| Feature | Master | Editor |
|---|---|---|
| call-style casts `cast<T>(x)`, `reinterpret<T>(x)` | required (juxtaposition is a syntax error) | same |
| `addr<T?>(x)` sugar | yes | parses (fails only on unsafe) |
| bare named arguments `f(1, c = 9)` | yes | yes |
| `typedef distinct T = int` | yes | yes |
| `float16` | yes | yes |
| `!` original operators (`a!.x`, `a![i]`, `!is`, ...) | yes | **syntax error** |
| `var @exact_size x : array<T>` (metadata on locals) | yes | **syntax error** |
| `memmove` builtin | yes | **missing** (`no matching functions`) |
| `ensure_capacity`, `max_unreserved_size` panic | yes | yes |
| `[inline]` | yes | yes |
| 64-bit hex literal | `0xffffffffffffffffu64` is an error in both (`uint constant out of range` + syntax error at `u64`); a hex literal above 32 bits needs the `ul` suffix | same |
| `return void_call()` in a void function | yes | compiles |
| `return` from inside `for (x in f())` where `f()` returns a temporary array | panics at runtime: `can't delete locked array` (the temporary is deleted while the loop still locks it) | same; in the engine the panic is "unrecoverable exception in user thread" and stops the game (measured in an exported build) |
| hex literal with the `l` suffix (`0xffffffffl`) | typed `uint64`, so `int64 & 0xffffffffl` is a type error | same (measured in the editor) |

## 5. What this means for c2das

The current output cannot run in the editor at all: across 303 generated
files under `/root/c2das` there are 16 675 `unsafe`, 5 853 `reinterpret`,
1 492 `addr`, 884 `void?` and 232 `intptr`, and the runtime's address model
is the host address of `c2da_rt_heap[i]` (`intptr(addr(heap[start]))`),
every load and store a `reinterpret<uint8?>(address)[i]`. All of that is
refused by the sandbox, and there is no option to allow it.

An Eden target is possible with the model wasm3das already runs on (a C
program is then exactly what a wasm guest is: a linear memory plus code):

1. **Addresses are offsets, not host pointers.** One `array<uint8>` heap per
   program (or per module), an address is a `uint` (or `int`) offset into it,
   NULL is 0 with the first bytes reserved. `c2da_rt_malloc` returns an
   offset; nothing ever takes `addr(...)`.
2. **Loads and stores by bytes.** `load_u32(heap, a)` assembles four
   `uint8` with shifts, `store_u32` splits them; floats go through
   `math_bits` (`uint_bits_to_float` / `float_bits_to_uint`, and the 64-bit
   pair). wasm3das `source/m3_exec_defs.das` has the whole family
   (`load_u8 ... load_u64`, `store_*`), bounds-checked by the array index.
   Every field access of a pointer-backed C struct becomes
   `load_T(heap, p + offset)`; c2das already has the Clang offsets and the
   raw-memory lowering, only the primitive changes.
3. **Locals whose address is taken** live in the heap (a C stack region of
   the heap with a stack pointer global), like clang's wasm lowering does;
   the rest stay daslang locals.
4. **Function pointers are table indexes.** A global
   `array<function<...>>` per signature, filled at start; the C value is
   the index. `@@fn` values of signatures that mention structs die on hot
   reload: refill the tables after a reload (or keep signatures to scalars).
5. **String literals and static data** are bytes placed in the heap at
   start (an initializer function writes them), not daslang strings.
6. **memcpy/memset/memmove/memcmp** are byte loops over the heap array (no
   builtin works without unsafe); wasm3das `m3_api_libc` has them.
7. **Floats**: guard every comparison against NaN (section 3) and accept
   flush-to-zero; integer math is unaffected.
8. **Narrow integer types**: keep values in `int`/`uint` and truncate on
   store (`uint8(x & 255)`), never arithmetic on `uint8`/`int16` variables.
9. **Heap budget**: reserve the heap's final size with `reserve` before
   `resize` (64 MB `max_unreserved_size` panic, 100 MiB context cap), keep
   it under ~80 MB in practice, and free temporaries with `delete` or
   `inscope` in long-running calls.
10. **Control flow** maps 1:1: `goto label N` / `label N:` work in the
    editor, including jumps out of loops.
11. **What is gone in the editor build**: no files (`fio` refused; data
    comes from project assets through `request_text` + `get_binary_asset`),
    no threads (`jobque_boost` refused), no `exit` (end the program by
    returning).
12. **Testing**: the local stand-in for the editor rules is
    `modules/wasm3das/scripts/eden/sandbox.das_project`
    (`daslang -project sandbox.das_project -compile-only file.das`), which
    reproduces the refusals of section 2 with the 0.6.3 parser; it should be
    moved to the 0.6.4 rules of section 4 (no `!` operators, no local `@`
    metadata, no `memmove`) and the module list of section 6. The editor
    itself stays the final gate.

The cost: wasm3das, which works exactly this way, runs about 1.8x slower
than the same interpreter with raw pointers (`docs/eden-port/BENCH_EDITOR.md`),
and every memory access is several bounds-checked array reads.

## 6. daslib modules in the editor sandbox

Every module of master's `daslib/` (158) required alone or in groups of ten
by a probe file (`aarch64_neon` .. `contracts` on 1.0.0.12, the rest on
1.0.0.19). "Refused" means the project does not compile with the require:
either the sandbox refuses the module or the module does not build in the
editor (the editor then only says `internal error`); the `linq_fold*`
family fails with a real error (`no matching functions: LinqCall()`), so it
is broken there rather than forbidden.

**Accepted (92):** algorithm, ansi_colors, apply, archive, array_boost,
assert_once, ast_verify, async_boost, base64, bitfield_boost,
bitfield_trait, bool_array, build_const, builtin, clargs, class_boost,
command_line, constant_expression, consume, contracts, coroutines,
coverage, cuckoo_hash_table, dap, debug, debug_eval, debugger, decs,
decs_boost, decs_state, defer, delegate, dynamic_cast_rtti, enum_trait,
faker, flat_hash_table, flatten, flatten_opt, flatten_opt_common,
flatten_opt_fold, flatten_opt_fuse, flatten_opt_pack, flatten_opt_preshade,
flatten_opt_straightline, flatten_opt_swizzle, fts5_query, functional,
fuzzer, generic_return, if_not_null, instance_function, interfaces, json,
json_boost, jsonrpc, linq, linq_boost, lint, lint_everything, lpipe,
match, math_bits, math_boost, md_boost, option, perf_lint, random, regex,
regex_boost, remove_call_args, result, rtti, sha_256, shader_block_layout,
shader_lingua_franca, soa, sort_boost, sql, static_let, stringify,
strings_boost, strings_convert, stub, temp_strings, templates, toml, tty,
type_traits, unroll, utf8_utils, validate_code, with_boost.

**Refused or not building (66):** aarch64_neon, aot_constants, aot_cpp,
aot_macro, aot_standalone, apply_in_context, ast, ast_block_to_loop,
ast_boost, ast_cursor, ast_debug, ast_match, ast_print, ast_print_flags,
ast_used, c_api_header, cpp_bind, cpp_gen, cross_context,
das_source_formatter, das_source_formatter_fio, daspkg, dupe_detect,
env_registry, export_c, f16_cvt, fio, heartbeat, is_local, jobque_boost,
jobque_profile, just_in_time, linked_list, linq_das, linq_fold,
linq_fold_array, linq_fold_common, linq_fold_decs, linq_fold_json,
linq_fold_sql, linq_fold_table, lint_config, logger, macro_boost,
module_group, module_path, network, only_nttp, profiler, profiler_boost,
quote, refactor, rst, rst_comment, safe_addr, spoof, sql_boost, sql_linq,
sql_migrate, sql_provider, style_lint, templates_boost, tune,
typemacro_boost, uriparser_boost, x64_avx.

For translated C the relevant ones are available: `math_bits` (float bits),
`strings_boost` / `utf8_utils` (text), `static_let`, `defer`, `match`;
`fio` (files), `jobque_boost` (threads), `ast*` / `macro_boost` / `quote`
(compile-time code generation inside the target) are not. A translator
whose output needs macros at compile time must emit plain code instead.
