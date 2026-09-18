/* AOT host for the real-world matrix (scripts/real_world_matrix.py, mode "aot").
 *
 * daslang's AOT is a two-stage build: `daslang -aot entry.das out.cpp` emits
 * C++ for every function of the program, and a host links that C++ next to
 * the daslang runtime and compiles the same script with policies.aot = 1, so
 * simulate() binds each function to its pre-compiled body instead of
 * interpreter nodes.  fail_on_no_aot = 1 turns any function that fell back
 * to the interpreter into a compile error, so an "aot" number can never be
 * a disguised interpreter number.
 *
 * usage: aot_host <das_root> <script.das> [entry]
 *   das_root  the daslang tree whose daslib/ the script resolves against
 *             (the parent of the bin/ that holds the daslang binary)
 *   entry     exported function to run; default "main"
 * exit code: the script's int result when it returns one, 0 otherwise;
 *            1 on host failure, 64 on usage error.
 */
#include <stdio.h>
#include <string.h>

#include "daScript/daScriptC.h"

int main(int argc, char **argv) {
    int rc = 1;
    das_program *program = NULL;
    das_context *ctx = NULL;
    const char *entry = "main";

    if (argc < 3) {
        fprintf(stderr, "usage: %s <das_root> <script.das> [entry]\n", argv[0]);
        return 64;
    }
    if (argc > 3) {
        entry = argv[3];
    }

    das_initialize();
    das_set_root(argv[1]);
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
            fprintf(stderr, "aot_host: compilation failed for %s\n", argv[2]);
        } else {
            ctx = das_context_make(das_program_context_stack_size(program));
            if (!das_program_simulate(program, ctx, tout)) {
                fprintf(stderr, "aot_host: simulation failed\n");
            } else {
                das_function *fn = das_context_find_function(ctx, entry);
                if (!fn) {
                    fprintf(stderr, "aot_host: entry '%s' not found\n", entry);
                } else if (!das_function_is_aot(fn)) {
                    fprintf(stderr, "aot_host: entry '%s' is not AOT-linked\n", entry);
                } else {
                    vec4f result = das_context_eval_with_catch(ctx, fn, NULL);
                    char *ex = das_context_get_exception(ctx);
                    if (ex) {
                        fprintf(stderr, "aot_host: exception: %s\n", ex);
                    } else {
                        int value = 0;
                        memcpy(&value, &result, sizeof(value));
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
