# Canonical PLMPEG C graph

This fixture has one canonical **target** translation input and one explicit
C-reference graph:

```text
src/all.c
  -> src/pl_mpeg.c    (the only PL_MPEG_IMPLEMENTATION owner)
  -> src/module.c     (decoder-facing probe API)

src/all_reference.c
  -> src/shim.c       (reference-only fixture allocator/libc definitions)
  -> src/pl_mpeg.c
  -> src/module.c
```

`src/all.c` is an intentional C amalgamation, not a concatenation of generated
daScript files.  Clang parses it once and c2das must emit exactly one module:
`src/all.das`.  Individual `shim.c`, `pl_mpeg.c`, and `module.c` remain useful
for AST inventory and focused diagnosis, but are not a substitute for the
decoder graph.

## Ownership rules

- Only `src/pl_mpeg.c` defines `PL_MPEG_IMPLEMENTATION`.
- `src/all.c` includes `pl_mpeg.c`, then undefines `PL_MPEG_IMPLEMENTATION`,
  then includes `module.c`; it must never include `shim.c`.
- `src/all_reference.c` includes `shim.c`, then `pl_mpeg.c`, then undefines
  `PL_MPEG_IMPLEMENTATION`, then includes `module.c`.
- `PLM_NO_STDIO` is part of the graph contract and is supplied by the runner;
  source files guard their local definition to avoid a target-dependent macro
  redefinition warning.
- The fixture C allocator/libc bodies are reference-side graph content only.
  They must not enter the target AST or become alternate daScript libc
  implementations: call lowering owns the generated `c2da_rt_*` boundary.
- `module.c` uses the explicit `c2da_rt_reset()` test-runtime hook.  Its C
  reference definition delegates to `shim_reset_heap`; the target definition
  is emitted by `translator/runtime.rs`.
- `pl_mpeg.c` owns `plmpeg_abs`, a normal translated C helper selected for the
  single-header implementation with a local macro.  It is deliberately not a
  raw-memory runtime function and does not depend on `shim.c`.

## Commands

From the WSL checkout:

```sh
bash tests/manual/real-world-plmpeg-stream/check_c_graph.sh
bash tests/manual/real-world-plmpeg-stream/transpile_canonical_graph.sh
bash tests/manual/real-world-plmpeg-stream/run_end_to_end.sh
```

The first command is a graph/Clang gate. The second intentionally stops after
producing `src/all.das`; daScript execution and semantic comparison are the
third command's responsibility.  The end-to-end runner builds and executes
`all_reference.c` against `plmpeg_reference.expected`, transpiles a fresh
temporary copy of `all.c`, executes `plmpeg_entry.das` with WSL `daslang`, and
compares its scalar decoder probes against that same recorded C oracle.  The
initial oracle covers `sequence_start_code` and `video_has_header`: they are
the currently C-reference-safe decoder subset.  The decoding/hash probes are
intentionally excluded until their C-reference SIGSEGV is independently fixed;
`src/plmpeg_reference_probe.c` reproduces that boundary one probe at a time.

## First canonical transpile result (2026-08-27)

The target graph has passed the Clang gate and reached the translator as one
AST without parsing any fixture allocator/libc body.  Its current first
semantic diagnostic is:

```text
Skipping decl plm_audio_create_with_buffer:
aggregate C object rvalue from raw storage is not implemented
```

The process then exposes a separate fail-open bug: an assertion in
`translator/abi.rs::null_pointer` is reached for a non-pointer condition.
That assertion must become a location-rich translation error or be eliminated
by correct condition lowering; it is not a graph problem.  The next owner
layer is aggregate object copy / array-backed raw storage, followed by the
condition ABI boundary.  Neither result authorizes a post-render workaround.

No new `src/all.das` is emitted while that panic remains.  An existing file
from an older graph that contains `def malloc`, `def memcpy`, and similar
fixture bodies is stale output, not evidence for this target graph; it must
never be used as a validation artefact.
