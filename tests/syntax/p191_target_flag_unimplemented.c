/* Negative: a target switch whose lowering is not implemented yet
 * (`--varargs-model heap`, docs/eden-flags.md flag 6) is refused by name
 * before any output is written, never accepted silently.  The C program is
 * irrelevant; any translation unit must be refused under the flag. */

int target_flag_unimplemented(int x)
{
	return x + 1;
}
