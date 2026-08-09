int check_nal(int nal, int ref_idc) {
    if ((nal == 7 || nal == 8 || nal == 5) && ref_idc == 0) {
        return 1;
    }
    return 0;
}

int main() {
    return check_nal(7, 3) + check_nal(5, 0);
}
