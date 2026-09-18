/* AOT host for the corpus matrix (scripts/corpus_matrix.py, mode "aot").
 *
 * daslang's AOT is a two-stage build: `daslang -aot entry.das out.cpp` emits
 * C++ for every function of the program, and a host links that C++ next to
 * the daslang runtime and compiles the same script with policies.aot = 1, so
 * simulate() binds each function to its pre-compiled body instead of
 * interpreter nodes.  fail_on_no_aot = 1 turns any function that fell back
 * to the interpreter into a compile error, so an "aot" number can never be
 * a disguised interpreter number.
 *
 * The host is C++ only for one call the C API does not expose:
 * das::setCommandLineArguments, which is what the script's
 * get_command_line_arguments() reads.  The whole host argv is handed over,
 * so an entry that takes "the last argument" sees the same thing it sees
 * under `daslang entry.das -- <arg>` and under the -exe binary.
 *
 * usage: aot_host <das_root> <script.das> <entry> [args...]
 *   das_root  the daslang tree whose daslib/ the script resolves against
 *             (the parent of the bin/ that holds the daslang binary)
 *   entry     exported function to run ("main" for the corpus entries)
 *   args      passed through to the script's command line
 * exit code: the script's int result when it returns one, 0 otherwise;
 *            1 on host failure, 64 on usage error.
 */
#include <cstdio>
#include <cstring>

#include "daScript/daScript.h"
#include "daScript/daScriptC.h"
#include "daScript/simulate/aot_builtin.h"

int main(int argc, char **argv) {
    int rc = 1;
    das_program *program = nullptr;
    das_context *ctx = nullptr;

    if (argc < 4) {
        std::fprintf(stderr, "usage: %s <das_root> <script.das> <entry> [args...]\n", argv[0]);
        return 64;
    }
    const char *entry = argv[3];

    das_initialize();
    das_set_root(argv[1]);
    das::setCommandLineArguments(argc, argv);
    {
        das_text_writer *tout = das_text_make_printer();
        das_module_group *libgrp = das_modulegroup_make();
        das_file_access *fa = das_fileaccess_make_default();
        das_policies *pol = das_policies_make();

        das_policies_set_bool(pol, DAS_POLICY_AOT, 1);
        das_policies_set_bool(pol, DAS_POLICY_FAIL_ON_NO_AOT, 1);
        program = das_program_compile_policies(argv[2], fa, tout, libgrp, pol);
        das_policies_release(pol);

        if (!program || das_program_err_count(program)) {
            std::fprintf(stderr, "aot_host: compilation failed for %s\n", argv[2]);
        } else {
            ctx = das_context_make(das_program_context_stack_size(program));
            if (!das_program_simulate(program, ctx, tout)) {
                std::fprintf(stderr, "aot_host: simulation failed\n");
            } else {
                das_function *fn = das_context_find_function(ctx, entry);
                if (!fn) {
                    std::fprintf(stderr, "aot_host: entry '%s' not found\n", entry);
                } else if (!das_function_is_aot(fn)) {
                    std::fprintf(stderr, "aot_host: entry '%s' is not AOT-linked\n", entry);
                } else {
                    vec4f result = das_context_eval_with_catch(ctx, fn, nullptr);
                    char *ex = das_context_get_exception(ctx);
                    if (ex) {
                        std::fprintf(stderr, "aot_host: exception: %s\n", ex);
                    } else {
                        int value = 0;
                        std::memcpy(&value, &result, sizeof(value));
                        rc = value;
                    }
                }
            }
            das_context_release(ctx);
        }
        if (program) {
            das_program_release(program);
        }
        das_fileaccess_release(fa);
        das_modulegroup_release(libgrp);
        das_text_release(tout);
    }
    das_shutdown();
    return rc;
}
