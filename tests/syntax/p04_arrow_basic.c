struct Point {
    int x;
    int y;
};

int main() {
    struct Point pt;
    struct Point* p = &pt;
    p->x = 10;
    p->y = 20;
    return p->x + p->y;
}
