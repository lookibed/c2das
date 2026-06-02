struct Point {
    int x;
    int y;
};

int area(int x1, int y1, int x2, int y2) {
    struct Point p1;
    struct Point p2;
    p1.x = x1;
    p1.y = y1;
    p2.x = x2;
    p2.y = y2;
    int w = p2.x - p1.x;
    int h = p2.y - p1.y;
    return w * h;
}

int main() {
    return area(0, 0, 10, 5);
}
