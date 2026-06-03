options gen2

def triggers_label_break() {
    label 6934:
    if (0 < 1) {
        return
    } else {
        if (0 < 1) {
            goto label 6934
        }
    }
    return
}
