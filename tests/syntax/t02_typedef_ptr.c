typedef int* int_ptr;

int main() {
    int x = 10;
    int_ptr p = &x;
    return *p;
}
