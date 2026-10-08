/* Negative: `--dialect eden-0.6.4` refuses a module option outside the
 * EdenSpark sandbox list (docs/eden-target.md §2): here the case asks for
 * `--das-option heap_size_limit = 1`, which the sandbox refuses.  The checker
 * reads the finished module's header and fails with a diagnostic naming the
 * translation unit and the option; no output is written. */

int dialect_eden_refuses_option(int x)
{
	return x * 2;
}
