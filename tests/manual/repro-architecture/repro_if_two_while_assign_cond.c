extern void *next_sps_ptr(int index, int *bytes);
extern void *next_pps_ptr(int index, int *bytes);

int repro_if_two_while_assign_cond(int include_headers) {
    int index = 0;
    int total = 0;
    int bytes = 0;
    void *ptr = 0;

    if (include_headers) {
        while ((ptr = next_sps_ptr(index, &bytes)) != 0) {
            total += 4 + bytes;
            index += 1;
        }

        index = 0;
        while ((ptr = next_pps_ptr(index, &bytes)) != 0) {
            total += 4 + bytes;
            index += 1;
        }
    }

    return total + 1;
}
