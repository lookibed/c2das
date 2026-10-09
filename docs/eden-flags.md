# Translator flags for an EdenSpark target

**What this is.** A plan of the switches c2das needs so its output compiles and runs in the
EdenSpark editor's daslang. Written 2026-10-09. Step 1 of the order of work is in place: the
CLI switches (`src/target.rs`), `--float-compare nan-safe`, the `--dialect eden-0.6.4` and
`--no-unsafe` checkers, and `scripts/eden_check.py`. Step 2 adds `--libc eden` and runs the
checkers on the shared runtime module too. Step 3 adds the core of `--memory-model linear`
and `--heap-reserve` (see "`--memory-model linear` as built" below). The Status column says
which flag is implemented; every other flag, and so the `--target eden` preset, is refused
by name.

**Sources.**

- [`eden-target.md`](eden-target.md): the measured sandbox rules of EdenSpark 1.0.
- The wasm3das Eden port in the EdenSpark project
  `launcher/projects/01a0d5aa-8f9a-77c4-ab6c-0f56f3921a0e/modules/wasm3das`, branch `eden`,
  commit `b854781`. In particular:
  - `docs/eden-port/DESIGN.md`, `RESULT.md`, `BENCH_EDITOR.md`;
  - `docs/eden-abi/PLAN.md`;
  - `source/m3_exec_defs.das`;
  - `scripts/eden/sandbox.das_project`.

**How the wasm3das port differs from c2das.** The port is a hand re-expression of the
pointer port: arenas, handles and byte loads. A translator target has to produce the same
kind of code mechanically.

## Why an Eden target matters, and why interpreter speed is the whole game

- **The editor only interprets.** It runs scripts with `llvm_jit_enabled:b=no` (not
  overridable) and `aot lib size=0`. This holds in the editor and in exported builds alike
  (`eden-target.md` §3). The JIT and AOT columns of the README do not exist there; only the
  interpreter column does.
- **Running C today means interpreting wasm inside the interpreter.** The executor is
  wasm3das: C is compiled to wasm and then interpreted by wasm3das, itself interpreted by
  daslang.
  - binjgb runs at about 1 250 ms/frame in the editor, 75× over the 16.7 ms budget
    (`docs/eden-abi/PLAN.md` §2).
  - That plan names a direct translator ("Tier C") as the way out.
- **A c2das translation of the same C would be much closer to real time** (estimate, not
  measured in the editor).
  - binjgb runs at 13.5 ms/frame in the master interpreter: 4 044 ms for 300 frames, README
    snapshot at `712474e26`.
  - wasm3das paid about 1.8× for the move from raw pointers to array memory
    (`BENCH_EDITOR.md`).
  - So about 25 ms/frame is a plausible order for binjgb under an Eden memory model.
  - This is the case for doing the target at all.

## The flags

The current defaults are the master-daslang model. Every Eden switch is opt-in. A preset
`--target eden` turns on the whole set, and each switch also works alone so it can be tested
on master daslang first. In the table, a reference like "§2" points to a section of
`eden-target.md`.

| # | Flag | What it changes in the output | Eden rule it answers | c2das today | Status |
|---|---|---|---|---|---|
| 1 | `--memory-model linear` | An address is an `int`/`uint` offset into one `array<uint8>` heap; NULL is 0, with the first bytes reserved. Loads and stores are `[inline]` byte helpers (`load_u32`, `store_u32`, …), shaped like wasm3das `m3_exec_defs.das`. Floats go through `math_bits`. Pointer-backed records become an offset plus Clang's field offsets. | `unsafe`, `addr`, `reinterpret`, pointer arithmetic and `intptr` are refused in every form (§2) | Raw host addresses: `c2da_rt_heap` plus `reinterpret<T?>(address)[i]`; 16 675 `unsafe` across the generated files (§5). The biggest piece of work. | **Core implemented** (`translator/linear.rs`): `int` offsets, in-place byte loads and stores, records through pointers, string literals, allocator and byte functions; what it does not cover fails closed. Cases `p193`, `p194`, `p195` |
| 2 | `--locals-in-heap` (part of 1) | A local whose address is taken lives in a C stack region of the heap, with a stack pointer global, as clang's wasm lowering does. Other locals stay daslang locals. | No `addr(local)` (§2) | Uses `addr(local)` | **Locals implemented, implied by `--memory-model linear`** (no separate flag; see "C stack (step 4)" below); case `p199`. Globals whose address is taken are in the static block (`p203`); parameters whose address is taken are still refused (`p195`) |
| 3 | `--fnptr-model table` | A function pointer is an index into a per-signature global `array<function<…>>`, filled by an init function. `c2da_relink()` refills the tables after a hot reload. Calls are `invoke(table[i], …)`. | Function values whose type mentions a struct become null on hot reload (§3; wasm3das rebuilds its op tables in `m3_NewRuntime`) | `@@f` values stored as host function values | **Implemented** with `--memory-model linear` (refused by name without it): every function pointer — local, parameter, record field, global, heap — is its `int` index; calls are `invoke(c2da_fn_table<n>[i], …)`; NULL is 0; `c2da_relink()` (one module) or `c2da_relink_<stem>()` (source layout) refills the tables. Cases `p207-linear-fnptr-table`, `binjgb-cgb-acid2-eden-linear-source`. Without the switch, linear keeps the heap-only half (`p204`) |
| 4 | `--float-compare nan-safe` | Every float comparison is guarded by a bit-test `isnan` from `math_bits`: `eq = !isnan(a) && !isnan(b) && a == b`, and so on. | NaN comparisons are not IEEE in the editor: `NaN == NaN` is true, `NaN < 1` is true (§3) | Plain `==`, `<` | **Implemented** (`translator/float_compare.rs`): `[inline]` `c2da_fcmp_*` helpers over binary operators, truthiness and `!x`; case `p190-float-compare-nan-safe`. Not covered: the `--libc std` helpers' own floating compares |
| 5 | `--libc eden` | A libc prelude with:<ul><li>no `fio`; stdout and stderr go to `print` line buffers;</li><li>files read from project assets through a host callback (`request_text` plus `get_binary_asset`); no writes;</li><li>no `exit` (the program ends by returning);</li><li>`memcpy`/`memset`/`memmove`/`memcmp` as byte loops over the heap.</li></ul> | `fio`, `network` and `jobque_boost` are refused; `memmove` is missing; `memcpy` on pointers needs `unsafe` (§2, §4, §6) | `--libc std` uses `fio` and the `memcpy`/`memmove` builtins | **Implemented** (`translator/libc.rs`; under flag 1 `memcpy`/`memmove`/`memset`/`memcmp`/`strlen` are the `c2da_lin_*` heap byte loops, and the std formatter behind `printf` is still refused there), see "`--libc eden` as built" below); cases `p72/p76/p81/p82-eden-*`, `binjgb-cgb-acid2-eden` |
| 6 | `--varargs-model heap` | Variadic arguments are written into the C stack region of the heap, as clang's wasm ABI does, instead of a daslang array literal per call. | Garbage is collected only between engine frames; a long call that allocates an array per `printf` grows towards the 100 MiB cap (§3) | `[C2daVaArg(…), …]`, an array per call | Not yet: parsed, refused by name. binjgb under `--memory-model linear` passes without it (its variadic calls are the printf family at start and end); the per-call array is legal in the sandbox |
| 7 | `--heap-reserve <bytes>` | The heap is reserved at its final size before `resize`, and the translator refuses a program whose static data plus heap exceed a set limit (default about 80 MB). | `max_unreserved_size` panics past 64 MB; the per-context heap cap is 100 MiB (§3) | Grows on demand | **Implemented** with `--memory-model linear` (refused without it): the heap is reserved at this size (default 80 MiB) before any `resize`; an allocation past it returns NULL. No static check of the limit yet |
| 8 | `--dialect eden-0.6.4` | Emitted syntax limited to what the editor's 0.6.4 parses, with located errors otherwise. Excluded:<ul><li>no `!` original operators;</li><li>no `@` metadata on locals;</li><li>no `memmove`;</li><li>options limited to the sandbox list: `gen2`, `indenting`, `stack`, `rtti`, `no_global_variables`, `no_aot`, `solid_context`, `strict_smart_pointers`;</li><li>no `heap_size_limit`.</li></ul> | The editor's daslang is older than master v0.6.4-481 (§1, §4) | Emits only `options gen2`, `solid_context` and case options; uses no `!` operators today, but nothing enforces it | **Implemented** as a checker (`translator/target_check.rs`): options, requires (§6 lists), `!` operators, `memmove`; case `p192-dialect-eden-refuses-option`. Local `@` metadata is not checked: `das_ast` has no node for it |
| 9 | `--entry eden` | No `[export] def main` with an `argv` wrapper. Instead a module API the project's `main.das` calls from `on_initialize`/`on_update` or a `[cheat]`. A frame-driven program (Doom, binjgb) exposes `init`/`tick`/framebuffer access, like wasm3das `eden/abi_*_player.das`. | Entry points are `[export] on_initialize/on_update` and `[cheat]` in the project's `main.das` (DESIGN §1) | `main` wrapper with a C `argv` | **Implemented** with `--memory-model linear --libc eden` (refused without them): the host API `c2da_eden_start(args : array<string>) : int`, see "`--entry eden` as built"; cases `p206-linear-entry-eden`, `binjgb-cgb-acid2-eden-linear-source`. Splitting a frame-driven program into `init`/`tick` is per-program host code |
| 10 | `--module-layout source` (exists) plus project placement | One `.das` per C file under a non-dot folder of the project. Generated scratch goes under dot-folders, which the editor skips. | The editor compiles every non-hidden `.das` in the project tree and reports only the first error of the first failing file (DESIGN §1) | `--module-layout source` exists (acyclic programs); the cyclic case is still open | Exists (clusters too), also with `--memory-model linear` (one shared heap module; cases `binjgb-cgb-acid2-eden-linear-source`, `m02`/`m03-…-eden-linear`) |
| 11 | `--no-unsafe` (check, implied by the preset) | The translator fails closed, with a source-located diagnostic, on any construct that would need `unsafe` under the other flags. The output is then also checked locally under `sandbox.das_project`. | A sandbox refusal in the editor names only the first error | No such check | **Implemented** as a checker: `--no-unsafe` fails naming the first 10 sites by C declaration; `--no-unsafe=report` prints a census. `scripts/eden_check.py` runs the sandbox model |

### `--libc eden` as built

The `--libc std` table, with every `daslib/fio` name replaced by an emitted `c2da_eden_*`
helper. The module `require`s only `strings`.

- **Console.** stdout and stderr are line buffers. A complete line of stdout goes to `print`,
  of stderr to `to_log(LOG_ERROR, …)`. Master daslang writes `to_log` to the process stderr,
  so stdout bytes equal the C program's, as the canonical runner compares them (it compares
  stdout only). What is left in a buffer is written by `fflush`, `exit`, or the return of
  `main`. `setvbuf` changes nothing visible.
- **Files.** Read-only byte arrays. The host calls
  `c2da_eden_add_file(name : string; var bytes : array<uint8>)` before the program runs; a
  name registered again is replaced. `fopen` with a mode other than `r…` without `+` fails
  with `EACCES`, a name never registered with `ENOENT`. `fread`, `fseek`, `ftell`, `feof`,
  `fgetc`, `fgets`, `rewind` work on the array. Writing to a file handle fails like a short
  write. `remove` and `rename` fail (`EACCES`/`ENOENT`). `getenv` answers NULL.
- **Host for tests.** `scripts/run_c2das_cases.py` writes, for a `"libc": "eden"` case with
  `program_args`, a host `c2da_eden_host.das` next to the generated module. It reads each
  argument file with `daslib/fio`, registers it under the path the C program gets in `argv`,
  and calls the module's `main`. It runs with `-main c2da_host_main`. The host is not
  translated output. In Eden the host reads assets with `request_text`/`get_binary_asset`.
- **`exit`.** `exit(n)` flushes, stores `n` and panics. The `main` wrapper runs C `main` in
  `try`/`recover` and returns `n`. A panic that is not `exit` (a trap) is raised again as
  `c2da: trap` after the flush; the original message is lost.
- **Time.** `clock_gettime` and `time` stay on the builtins `ref_time_ticks` and `get_clock`,
  which need no module. Not yet checked in the editor.
- **`memmove`.** A C `memmove` and an overlapping object copy call the `c2da_rt_memmove`
  byte loop, never the `memmove` builtin. `memcpy`/`memset`/`memcmp` keep today's forms over
  raw addresses; they become sandbox-legal with flag 1.
- **Still `unsafe`.** The stand-ins that copy bytes to or from C memory (`c2da_eden_read`,
  `c2da_eden_write_bytes`) index a raw pointer, as the rest of the std prelude does, until
  flag 1.
- **Fails closed.** A libc call outside the std table is refused by name as under `std`.

**Proof on master daslang (2026-10-09).** `p72-eden-file-io` (`fopen`/`fread` of a
registered file), `p76-eden-strings` (`puts`, `fputs`, `fprintf`, `fwrite` to stdout),
`p81-eden-printf-edge` (`fflush`, `fseek`/`ftell` on a registered file) and
`p82-eden-exit-status` (`exit(7)`) match the C reference. No eden case covers stderr output,
`fgetc`/`fgets`/`rewind` or a failing write yet. `binjgb-cgb-acid2-eden`
(`--libc eden --dialect eden-0.6.4`) passes the dialect checker and matches C: 60 frame
hashes, `ticks=5378896`.

**binjgb against the sandbox model** (`scripts/eden_check.py`): the module still fails. The
first error is `unsafe function 'c2da_rt_malloc'`: `intptr(addr(c2da_rt_heap[0]))`, the raw
heap. Census over the text: `unsafe` 5 153, `addr(` 405, `reinterpret<` 3 731, `intptr(` 3.
The only remaining blocker class is `unsafe` raw memory, which is flag 1.

### `--memory-model linear` as built (core, step 3)

The design is in `translator/ARCHITECTURE.md` ("Target switches", `linear.rs`). In short:

- **The heap.** One module global `c2da_mem : array<uint8>`. An address is an `int` offset;
  NULL is 0 and the first 16 bytes are reserved. The heap is reserved at `--heap-reserve`
  (default 80 MiB) in an `[init]` function before any `resize`, so `max_unreserved_size` is
  never reached. A `malloc` past the reservation returns NULL: with `--heap-reserve 65536`,
  a loop of `malloc(1000)` got 63 blocks, then NULL.
- **Pointers as integers.** In memory a pointer takes 8 bytes (offset, then 4 zero bytes),
  as Clang lays out records. `(uintptr_t)p` is the offset: small, non-negative and
  heap-relative, not a host address. Comparisons and differences work on offsets.
- **Access.** Loads and stores are written in place, without helper calls: bytes for
  8-bit values, little-endian shifts for wider ones, `math_bits` for floating values. A
  field through a pointer is at Clang's offset. Records reached only by value stay
  daslang structs; under the model they carry no layout proof.
- **Static data.** String literals whose address is taken are placed in the heap by the
  `[init]` function.
- **C stack (step 4).** A local (not a parameter, not a `static`) whose address is taken
  (`&x`, `&s.f`, `&a[i]`) or whose array decays to a pointer other than as the base of
  `a[i]` gets a 16-byte aligned slot in its function's frame; every read, write and
  address of it is a heap access at `c2da_fp + offset`, and its initializer is a store
  there. Other locals stay daslang locals. The stack is a fixed 1 MiB region right above
  the static block (not at the top of the heap: the heap grows by `resize`), growing down
  from `c2da_lin_sp`; `c2da_lin_enter` panics with `c2da: C stack overflow` below it. A
  function with a frame becomes two functions: `f_c2da_frame`, the body with an extra
  `c2da_fp` parameter, and `f` itself, which saves `c2da_lin_sp`, calls the body with
  `c2da_lin_enter(size)` and restores it, so every return path of the body (early returns,
  returns inside loops, recursion) pops the frame. Such a function is never inlined.
  Not done: an `exit` or a trap that unwinds through frames leaves `c2da_lin_sp` lowered;
  the program ends there, so it matters only if the host calls the entry again.
  Case `p199-linear-locals-in-heap` (C == daslang; `--no-unsafe` and `eden_check.py` ok).
- **Record values (step 4).** A whole struct read through a pointer (`s = *p`, `return
  p[i]`, an argument `f(*p)`) is read into a fresh daslang value field by field at Clang's
  offsets; a struct assigned through a pointer is written the same way; heap to heap
  (`*p = *q`, `a->in = b->in`) is one `c2da_lin_memmove` of `sizeof`. Nested structs and
  array fields are unrolled (more than 4096 scalars is refused). `a[i]` over a declared
  array that is a daslang value (a local, a field of a record value) is plain daslang
  indexing. Case `p197-linear-record-values` (C == daslang; `--no-unsafe` and
  `eden_check.py` ok); `p198` is the located refusal of a record with bitfields. Still
  open: a by-value parameter of a record with a pointer field stays raw-memory lowered
  (the `unsafe` net refuses it), and an array field of a call result (`f().arr[i]`) is emitted
  as `cast<int[3]>(f()).arr[i]`, which daslang rejects at compile time; the fixture avoids
  both.
- **Library.** `malloc`/`calloc`/`realloc`/`free`, `memcpy`/`memmove`/`memset`/`memcmp`/
  `strlen` are `c2da_lin_*` byte loops over the heap. Step 4 added `strchr`/`strrchr`/
  `strcmp`/`strncmp`/`strcpy`/`strncpy`/`strcat`/`strstr` the same way (case
  `p196-linear-strings`; `--no-unsafe` and `eden_check.py` ok).
- **printf family (step 5).** `printf`, `fprintf`, `sprintf`, `snprintf`, `vprintf`,
  `vfprintf`, `vsprintf` and `vsnprintf` are `c2da_lin_printf`/`c2da_lin_vprintf`/
  `c2da_lin_snprintf`/`c2da_lin_vsnprintf`, appended only when a call uses them. One
  formatter, `c2da_lin_vfmt`, reads the format from the heap and appends the bytes to a
  local `array<uint8>`; a `%s` argument is a heap offset (`raw` of its `C2daVaArg`), NULL
  prints `(null)`. It covers the flags `-+ #0`, width and precision (also `*`), the length
  modifiers `hh h l ll j z t q L` (the promoted `int64` is cut to C's width), and `%d %i
  %u %x %X %o %c %s %p %%`. A stream call writes through `c2da_std_write` (stdout is
  handle 1; `stdout`/`stderr` themselves are their handles as `int`); a buffer call places
  the bytes with `snprintf`'s rule (at most `n - 1` bytes and a NUL, answering the full
  length; `sprintf` has no limit). A literal format with any other conversion (`%f`,
  `%e`, `%g`, `%a`, `%n`, …) is refused, located at the format; a computed format with
  one panics at run time. Variadic arguments are still a `[C2daVaArg(…)]` array per call
  (a pointer argument is its offset widened to `uint64`); a `va_list` local is the
  variadic cursor, never a C stack slot. A byte 0 produced by `%c` cannot cross a
  daslang string on the stream path. Case `p200-linear-printf` (C == daslang;
  `--no-unsafe --dialect eden-0.6.4` and `eden_check.py` ok).
- **Files, argv, errno (step 5, `--libc eden`).** A `FILE *` is the `--libc eden` handle
  as an `int`. `fopen` reads its path and mode from the heap (`c2da_lin_fopen`); `fread`
  copies the registered file's bytes into the heap (`c2da_lin_fread`); `fwrite` sends
  heap bytes to stdout/stderr and writes nothing elsewhere (`c2da_lin_fwrite`);
  `fclose`/`fflush`/`fseek`/`ftell`/`feof` are the `--libc eden` helpers on the handle.
  The `main` wrapper builds `argv` and its strings in the heap (`c2da_lin_put_arg`,
  `argv[argc]` NULL). `errno` is 4 bytes at heap offset 8, inside the reserved first 16.
  `fopen` does not set `errno` under the model. Case `p201-linear-stdio` (C == daslang;
  `--no-unsafe --dialect eden-0.6.4` and `eden_check.py` ok).
- **Enumerations (step 5).** Under the model a C enumeration object (and a typedef of
  one) is its compatible integer type, not a daslang `enum`: a daslang `enum` has no
  numeric conversion except `reinterpret`, which the sandbox refuses. Enumeration
  constants were already integer literals; casts to an enumeration are integer
  conversions; in the heap an enumeration is that integer's bytes. The `enum` declaration
  is still emitted for a hand-written caller. Case `p202-linear-enums` (C == daslang;
  `--no-unsafe --dialect eden-0.6.4` and `eden_check.py` ok).
- **Globals in the heap (step 5).** Before any function is lowered, a pass over every
  function body finds the objects of static duration (globals and function-scope
  `static`s) whose address is taken or whose array decays to a pointer other than as the
  base of `a[i]`. Each gets a 16-byte aligned, unshared place in the static block with
  its initial bytes, written by the same `[init]` copy as the string literals; every use
  of the name is then a heap access at that constant offset, and no daslang global is
  emitted for it. Initializers covered: none (zero), integer and enumeration scalars,
  arrays and records of them (designated and partial lists), `char` arrays from a string
  literal, and pointers that are NULL or a string literal. Any other initializer (floating
  point, the address of another object, a bitfield or union) is refused, located. An
  address taken only in a file-scope initializer is not seen by the pass. Case
  `p203-linear-globals` (C == daslang; `--no-unsafe --dialect eden-0.6.4` and
  `eden_check.py` ok). `p195` now refuses `&` of a parameter, which is still not in the heap.
- **Function pointers in the heap (step 5; the heap half of `--fnptr-model table`).**
  The same pre-pass numbers every function with a body whose address is taken (a
  decay that is not a direct call's callee), from 1. A function pointer stored in the
  heap is that index (8 bytes, like a data pointer; NULL is 0) into the table of its
  pointer's signature (typedefs resolved): `c2da_fn_table<n> : array<function<…>>`,
  read as `c2da_fn_table<n>[index]` and written through `c2da_fn_index<n>(f)`, a
  linear search (stores are rare; loads are one index). `c2da_relink()` resizes and fills
  every table and runs from `[init]`; a host calls it again after a hot reload, since the
  indices in the heap survive one and daslang function values do not. Function pointers
  held in daslang locals, parameters and record values stay `function<…>` values as in
  the default model, so the `--fnptr-model table` switch itself is still refused by name.
  Storing a function that is in no table of that signature (a library function, a
  pointer cast to another signature) panics with `c2da: a function pointer outside the
  function table`. Case `p204-linear-function-pointers` (a record of callbacks in
  malloc'd memory, NULL, compare, copy, call; C == daslang; `--no-unsafe --dialect
  eden-0.6.4` and `eden_check.py` ok).
- **Smaller step 5 pieces.** `memchr` is `c2da_lin_memchr` (in `p196`). A by-value record
  parameter with pointer fields is a plain record copy under the model (its pointer
  fields are `int`s), `++`/`--` works on a pointer field of a daslang record value
  (`++iter.state`), `(void)p` discards an offset, and `setvbuf` is the `--libc eden`
  helper with its buffer tested against NULL only (case `p205-linear-record-iterators`;
  C == daslang; `--no-unsafe --dialect eden-0.6.4` and `eden_check.py` ok). Under
  `--libc eden` (either memory model) `exit` no longer wraps the stand-in in `unsafe`.
- **Several modules (`--module-layout source`).** The heap, allocator, C stack, byte and
  printf/file/argv functions, `--libc eden` state and the function tables live once in
  the shared runtime module (`c2da_runtime.das`, public); every unit module requires it.
  The layout is program-wide and decided in the link pass: units are translated in
  compilation-database order and each one's static block starts past the earlier
  ones' (so every static address stays a translation-time constant); function-pointer
  signatures and indices continue across units the same way; the C stack sits above
  the last block. Each unit copies its block into the heap from its own `[init]` and
  fills its slots of the shared tables from `c2da_relink_<stem>` (a host calls each one
  again after a hot reload; there is no single program-wide `c2da_relink` in this
  layout). daslang runs `[init]` functions entry module first, so each calls the
  idempotent `c2da_lin_setup` (reserve and size the heap) first. Case
  `binjgb-cgb-acid2-eden-linear-source`: binjgb as `common.das`, `emulator.das`,
  `joypad.das`, `platform.das`, `entry.das` plus `c2da_runtime.das` (static blocks at
  16, 288, 21568, 21840, 21872); C == daslang; translated with `--no-unsafe --dialect
  eden-0.6.4`, and `eden_check.py` reports `ok` with 0 `unsafe`/`addr`/`reinterpret`/
  `intptr` for each of the six modules. A whole run (compile, 60 frames) took 3.64 s
  best of 3 in the interpreter, the same as the single-module `binjgb-cgb-acid2-eden-linear`
  (3.64 s best of 3) on the same loaded machine. Units on a reference cycle (one
  cluster module of `include`d fragments) work the same way: a fragment's static block
  and table slots are appended to its `.das.inc`, every name suffixed with its stem
  (cases `m02-module-layout-cycle-eden-linear`, `m03-module-layout-cycle-statics-eden-linear`;
  C == daslang, `--no-unsafe --dialect eden-0.6.4`, `eden_check.py` ok on every `.das`).
- **`--fnptr-model table` as built (flag 3).** With the switch (it needs `--memory-model
  linear`), a pointer to a function has the daslang type `int` everywhere, not only in
  the heap: a typedef of one is `typedef binop = int`, a record field, a parameter, a
  local and a global array hold indices. `f` or `&f` as a value is the constant index
  the pre-pass gave it; a call through a pointer is `invoke(c2da_fn_table<n>[p], …)`,
  `n` its signature (a parameter that is itself a function pointer is `int` in the
  signature too); NULL is 0, `if (p)` is `p != 0`, comparisons compare indices. The
  heap stores the index as it is (no `c2da_fn_index` search). Refused, located: a cast
  between function pointer types of different signatures (each signature has its own
  table), any other cast to or from a function pointer, the address of a function with
  no slot (a library function), and a library call taking a function pointer (`qsort`,
  `atexit`, …). Case `p207-linear-fnptr-table` (callbacks through locals, parameters,
  `(*f)(…)`, record values, a global table, malloc'd records, NULL, `==`/`!=`, a
  returned pointer; C == daslang; `--no-unsafe --dialect eden-0.6.4` and
  `eden_check.py` ok). `binjgb-cgb-acid2-eden-linear-source` translates with it: no
  `function<…>` value is left outside the tables in the shared module, and a whole run
  took 3.73 s best of 3 against 3.74 s for the single-module `binjgb-cgb-acid2-eden-linear`
  (noisy, loaded machine; both include compilation).
- **`--entry eden` as built (flag 9).** The unit defining C `main` gets no `[export] def
  main` and reads no command line. It declares `def c2da_eden_start(args : array<string>)
  : int` instead: `args` is C's whole `argv` (`args[0]` is the program name the host
  picks; no elements gives `argc == 0`), copied into the heap with `argv[argc]` NULL;
  C `main` runs under the `--libc eden` `try`/`recover`, so `exit` anywhere answers its
  status and any other panic is raised again after the console flush. The host
  registers files with `c2da_eden_add_file` (in the shared module under the source
  layout) and calls `c2da_eden_start`; the local runner's host
  (`scripts/run_c2das_cases.py`, `c2da_eden_host.das`) does exactly that. Splitting a
  frame-driven program into `init`/`tick` is not generated: it is host code per program
  that calls the translated C functions. Covered: one start per loaded context (an
  `exit` leaves `c2da_lin_sp` and the exit flag as they were). It needs
  `--memory-model linear` (refused by name without it) and `--libc eden` (refused,
  naming both). Cases `p206-linear-entry-eden` (argc/argv, NULL terminator, `exit(7)`
  from a nested call; C == daslang, exit 7; `--no-unsafe --dialect eden-0.6.4` and
  `eden_check.py` ok) and `binjgb-cgb-acid2-eden-linear-source`.
- **Fails closed** with "not supported under --memory-model linear yet: …", located at the
  C source:
  - `&` of a parameter, an array in a parameter or a call result used as a pointer, and
    a heap global whose initializer is outside the covered forms (see "Globals in the
    heap");
  - a record value with bitfields read or assigned through a pointer (step 4 copies
    every other record value: see below), and a bitfield through a pointer;
  - a wide string literal;
  - a cast between data and function pointers;
  - any other libc function over C memory (string-literal arguments aside);
  - `--runtime-module` without `--module-layout source`;
  - as a net, any construct that needs `unsafe` in the finished module. This catches, for
    example, a by-value struct parameter whose pointer field is indexed.

**Proof on master daslang (2026-10-09).** All of these use `--memory-model linear --libc eden`.

- `p193-linear-scalars` and `p194-linear-records` return C's result (0).
  - p193 covers every scalar width through a pointer: negative values, float and double bit
    patterns, compound assignment and `++`/`--` in the heap, pointer arithmetic, differences
    and comparisons, `uintptr_t` and NULL.
  - p194 covers structs through pointers, including a nested struct and `&p->in`, an array
    of structs from `calloc`, a linked list built and freed, string literals,
    `strlen`/`memcmp`/`memset`/`memcpy` and an overlapping `memmove`, `realloc` growth, and
    `malloc` of an impossible size answering NULL.
- `p195-linear-refuses-local-address` is the located refusal of `&` of a global (it
  refused `&x` of a local until step 4).
- With `--no-unsafe --dialect eden-0.6.4 --float-compare nan-safe` added, both fixtures
  translate. `scripts/eden_check.py` against the wasm3das `sandbox.das_project` reports
  `ok` for both, with 0 `unsafe`, `addr`, `reinterpret` and `intptr`.
- Default output is unchanged (`cargo test --test snapshots`: 50 passed).

**Interpreter cost, one kernel.** The kernel is Doom's `R_DrawColumn` inner loop
(`*dest = colormap[src[(frac >> 16) & 127]]; dest += pitch;`) over a 320×200 byte screen for
100 frames, plus one checksum pass. It ran under `--libc eden`, on master daslang in the
interpreter, 3 runs each:

| model | time |
|---|---|
| raw | 136–137 ms |
| linear | 162–167 ms |

Linear is about 1.2× raw here. Byte accesses are the cheap case (see the table below); u32
and f64 accesses cost more.

### Already compatible, no flag needed

- `goto label N` / `label N:`, including jumps out of loops.
- `try`/`recover` for traps.
- Fixed arrays as globals.
- Wrapping integer arithmetic.
- Widening of narrow integer types: c2das already never does arithmetic on `uint8`/`int16`.
- `static_let`.
- `[inline]`.

Things the target cannot fix and has to document:

- Denormals are flushed to zero in every script context (§3).
- The array length limit of 2³¹ elements.

## Order of work

1. **`--dialect eden-0.6.4` checks and `--no-unsafe` as a report only.** Translate the corpora
   and list every construct that would be refused. This gives the size of the rest of the
   work per corpus.
   - Done. binjgb (`binjgb-cgb-acid2-std`: `src/binjgb_all.c`, `--libc std`), 2026-10-09,
     `--no-unsafe=report`: 9 502 sites, 9 135 of them in C-owned declarations and 367 in
     translator-generated helpers. By construct (C / generated): `unsafe` 4 965 / 189,
     `reinterpret` 3 873 / 42, `addr` 272 / 133, pointer arithmetic 25 / 0, `intptr` 0 / 3.
     `execute_instruction` alone holds 4 250. `--dialect eden-0.6.4` stops first at
     `require daslib/fio` (the `--libc std` prelude), and the sandbox model refuses the same
     module for `fio`.
2. **`--memory-model linear` with `--locals-in-heap`,** proved on master daslang first.
   - Every fixture and corpus must keep its frame hashes.
   - The interpreter cost has to be measured against today's model before the flag goes
     further. wasm3das saw about 1.8×. The recent interpreter mappings (range loops, unit
     words, typed stores, address mirrors) carry over: an address mirror becomes an `int`
     index.
   - Core of `--memory-model linear` done (above): fixtures p193/p194 match C, the
     sandbox model accepts them, and the column kernel costs about 1.2× raw. Still to do:
     - `--locals-in-heap`: locals done in step 4 (p199); `&global` and global arrays used
       as pointers done in step 5 (p203); `&param` still to do;
     - record and array values through pointers: done in step 4 (p197), except records
       with bitfields;
     - `<string.h>` string functions: done in step 4 (p196); the printf family over
       `c2da_mem`: done in step 5 (p200). binjgb under `--libc eden --memory-model linear
       --dialect eden-0.6.4 --no-unsafe` (case `binjgb-cgb-acid2-eden-linear`, known-red)
       then stopped at `fopen`; the `<stdio.h>` file functions, argv and errno over the
       heap: done in step 5 (p201); enumerations through pointers: done in step 5
       (p202); globals in the heap: done in step 5 (p203); function pointers in the
       heap: done in step 5 (p204); `memchr`, by-value iterator records, `(void)p`,
       `setvbuf`: done in step 5 (p196, p205). A storage-backed record type (the
       default model's raw-byte form, e.g. a union) is still declared under the model
       but its wrapper no longer allocates (`c2da_storage = 0`): its objects are in the
       heap, and a daslang value of it that reached raw storage operations would be
       refused by the `unsafe` net;
     - **binjgb passes** (step 5, 2026-10-09): case `binjgb-cgb-acid2-eden-linear`
       (`--libc eden --memory-model linear --dialect eden-0.6.4 --no-unsafe`,
       `das_options` `stack = 1048576`, which the case runner now also writes into the
       eden host, the program file whose options set the context) prints C's stdout:
       all 60 frame hashes and `ticks=5378896`, on master daslang. `eden_check.py`
       against the wasm3das `sandbox.das_project` reports `ok`, 0 `unsafe`/`addr`/
       `reinterpret`/`intptr`. Interpreter, one run each, run time = wall time minus
       a `-compile-only` run: linear 6.14 s − 2.57 s ≈ 3.57 s, about 59 ms/frame; the
       raw `binjgb-cgb-acid2-eden` build 2.10 s − 1.00 s ≈ 1.10 s, about 18 ms/frame.
       Linear is about 3.2× raw here (the column kernel above was 1.2×: binjgb's
       accesses are mostly multi-byte fields of the emulator record in the heap);
     - still open: `&param`, by-value parameters of storage-backed records, the
       `--varargs-model heap` and the daslang-value half of `--fnptr-model table`.
3. **`--fnptr-model table`, `--float-compare nan-safe`, `--libc eden`, `--varargs-model heap`,
   `--heap-reserve`.**
   - `--float-compare nan-safe` done in step 1; `--libc eden` done (above), with the
     `--dialect`/`--no-unsafe` checkers now also run on the shared runtime module.
4. **`--entry eden`,** then an Eden host for one corpus.
   - binjgb comes first: small, 5 units, acyclic for `--module-layout source`, and a
     wasm3das baseline exists to compare against.
   - Gates:
     - the local `sandbox.das_project`;
     - frame hashes equal to C;
     - the editor itself, through the EdenSpark MCP tools (`eden_build`, the console log).
     - ms/frame in the editor against the wasm3das Tier I number.
5. **Doom** once the cyclic `--module-layout source` lands.

## Measured on master daslang (2026-10-09)

Interpreter micro-benchmarks and the local sandbox model, master daslang `c4e4906eb`.

**Cost per memory access**, in ns, including about 7 ns of loop overhead:

| access | raw pointer (today) | byte heap `array<uint8>`, global | word heap `array<uint>` |
|---|---|---|---|
| u8 load / store | 12.1 / 13.6 | **9.1 / 8.3** | 12.4 / 24.8 (read-modify-write) |
| u32 load / store | 10.4 / 14.7 | 31.8 / 32.9 | **6.7 / 9.4** |
| f64 load | 10.4 | 78.3 | 25.4 |

**What the numbers show:**
- `[inline]` helpers do inline, but each argument becomes a local. Writing the access in place
  is 25% faster on Doom's column kernel.
- A fixed global array is no faster than a global `array`.
- A heap kept as a struct field (`rt.mem`, the wasm3das way) costs 10–35% more than a module
  global.

**Kernels, linear heap against today's raw pointers:**

| kernel | byte heap, accesses in place | word heap, accesses in place | typed `new T` object |
|---|---|---|---|
| Doom `R_DrawColumn` | **1.46×** | 3.9× | — |
| binjgb-like step: `e.state.*` fields, u64 ticks | 5.4–6.2× | 2.3× | **0.96×** |

**Sandbox model check:** the byte, word and in-place forms, `new T`, `[inline]` and
`options solid_context` are all accepted. `log_nodes` and `heap_size_limit` are refused.

### Decisions this changes

- **Flag 1 uses one module-global `array<uint8>` heap,** with accesses written in place: no
  helper calls, no struct-field heap. Static data (string literals, initialised globals whose
  address is taken) is placed into that heap at start.
- **New flag 12, `--records typed`.** An allocation of a known struct type whose interior
  addresses never escape as byte pointers becomes a `new T` daslang object. Its fields stay
  typed (`p.f`), at raw speed and legal in the sandbox. Records that escape into byte memory
  keep the heap form. Without this flag binjgb is estimated at 27–54 ms/frame in the
  interpreter, over the 16.7 ms budget.
- **The local sandbox model only checks the modules its name prefixes match,** so generated
  sub-modules need their own check.

## Open questions to measure before building

- **`options solid_context` in the editor.** It is in the local sandbox model's allowed list,
  but no editor probe is recorded in the port's docs.
- **Fused interpreter nodes for array memory.** What do `rt.mem[at]`-style byte loads cost in
  the 0.6.4 editor interpreter compared with master? Do `load_u32` helpers inline (`[inline]`
  exists in both)? Or does a `uint` word heap (`array<uint>`, 4 bytes per element, aligned
  loads in one read) beat byte assembly for aligned 32-bit access? The Spider measurements
  that `PLAN.md` cites suggest memory layout matters as much as translation.
- **Calls into engine modules.** A translated program that calls engine modules
  (`engine.core`) cannot be compiled locally. The host boundary has to stay a thin
  hand-written module.
