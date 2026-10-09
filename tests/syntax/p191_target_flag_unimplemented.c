/* Negative: a target switch the translator cannot honour in the selected
 * combination is refused by name before any output is written, never
 * accepted silently.  The case passes `--heap-reserve 4096` without
 * `--memory-model linear` (docs/eden-flags.md flag 1): there is no linear
 * heap for the reserve to size.  The C program is irrelevant; any
 * translation unit must be refused under the flag. */

int target_flag_unimplemented(int x)
{
	return x + 1;
}
