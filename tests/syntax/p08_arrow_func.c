struct Rect {
    int w;
    int h;
};

int area(struct Rect* r) {
    return r->w * r->h;
}

int main() {
    struct Rect r;
    r.w = 5;
    r.h = 7;
    return area(&r);
}
