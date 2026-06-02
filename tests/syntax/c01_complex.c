typedef struct {
    int a;
    int b;
} Pair;

int max_pair(Pair* p) {
    if (p->a > p->b) {
        return p->a;
    } else {
        return p->b;
    }
}

int main() {
    Pair p;
    p.a = 10;
    p.b = 25;
    return max_pair(&p);
}
