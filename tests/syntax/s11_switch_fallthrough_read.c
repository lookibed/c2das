int switch_fallthrough_read(int nb) {
    int v = 0;
    switch (nb) {
    case 4:
        v = (v << 8) | 1;
    case 3:
        v = (v << 8) | 2;
    case 2:
        v = (v << 8) | 3;
    default:
    case 1:
        v = (v << 8) | 4;
    }
    return v;
}
