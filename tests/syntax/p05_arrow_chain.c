struct Inner {
    int val;
};

struct Outer {
    struct Inner* inner;
};

int main() {
    struct Inner i;
    i.val = 42;
    struct Outer o;
    o.inner = &i;
    return o.inner->val;
}
