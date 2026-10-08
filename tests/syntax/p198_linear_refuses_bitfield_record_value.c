/* `--memory-model linear`: a whole record value with bitfields read through
 * a pointer is refused, located at the read: bitfields of a daScript record
 * value are not lowered under the model yet. */
struct flags {
	unsigned on : 1;
	unsigned mode : 3;
};

int read_flags(struct flags *p)
{
	struct flags copy = *p;
	return 0;
}
