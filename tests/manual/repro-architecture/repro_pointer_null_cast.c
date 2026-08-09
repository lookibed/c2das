typedef struct Node Node;

struct Node {
    int value;
};

Node *explicit_zero_pointer(void) {
    return (Node *)0;
}

Node *implicit_zero_pointer(void) {
    Node *p = 0;
    return p;
}

Node *value_init_pointer(void) {
    Node *p = (Node *)0;
    p = 0;
    return p;
}
