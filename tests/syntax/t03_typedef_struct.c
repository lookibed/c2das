typedef struct {
    int x;
    int y;
} Point;

int main() {
    Point p;
    p.x = 5;
    p.y = 7;
    return p.x + p.y;
}
