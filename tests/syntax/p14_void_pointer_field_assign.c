struct Holder {
    void *token;
};

void set_token(struct Holder *holder, void *token) {
    holder->token = token;
}
