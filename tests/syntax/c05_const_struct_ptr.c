struct Point {
    int x;
    int y;
};

int dot(const struct Point* p) {
    return p->x * p->x + p->y * p->y;
}

int main() {
    struct Point pt;
    pt.x = 3;
    pt.y = 4;
    return dot(&pt);
}
