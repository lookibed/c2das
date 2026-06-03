options gen2

def irreducible(x : int) : int {
    label 3397:
    if (x < 6) {
        x += 1
        goto label 3399
    }
    label 3398:
    if (x < 9) {
        x += 2
        goto label 3397
    }
    label 3399:
    if (x < 20) {
        x += 90
        goto label 3398
    }
    return x
}
