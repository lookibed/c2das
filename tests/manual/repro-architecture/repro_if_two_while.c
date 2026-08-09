extern int next_sps(int index);
extern int next_pps(int index);

int repro_if_two_while(int include_headers) {
    int index = 0;
    int total = 0;

    if (include_headers) {
        while (next_sps(index)) {
            total += 10;
            index += 1;
        }

        index = 0;
        while (next_pps(index)) {
            total += 20;
            index += 1;
        }
    }

    return total + 1;
}
