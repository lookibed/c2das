/* An assignment that updates one place from itself — `x += y`, `x++` and a
 * C `x = x + y` alike — is written as daslang's compound assignment
 * `x op= y` when the operation is daslang's own on one builtin type (`int`,
 * `uint`, `int64`, `uint64`, `float`, `double`) and evaluating the place once
 * instead of twice cannot differ; a typed pointer stepped by an `int` or
 * `int64` (`p++`, `p += n`, `p = p - 1`) is `unsafe { p += n }`.  A value with a call or an assignment in
 * it, a place on the right, a narrow storage type computed in `int`, and a
 * conversion of the result keep the plain assignment. */
#include <stdio.h>

struct acc {
    int count;
    unsigned long long sum;
    double mean;
};

static int calls;
static int global_total;

static int twice(int v) {
    calls += 1;
    return 2 * v;
}

int main(void) {
    int x = 5;
    unsigned int u = 0xf0f0u;
    long long ll = -3;
    unsigned long long ull = 1;
    float f = 1.5f;
    double d = 10.0;
    int arr[4] = {1, 2, 3, 4};
    int i = 2;
    int *p = &arr[1];
    unsigned char b = 250;
    short s = 7;
    struct acc a = {0, 0, 0.0};
    struct acc *pa = &a;
    int *walk = arr;
    long long stride = 2;
    int k;

    x += 3;
    x = x * 4;
    x -= 1;
    x /= 3;
    x %= 7;
    x <<= 2;
    x >>= 1;
    x |= 64;
    x &= 0x7f;
    x ^= 5;
    u = u >> 4;
    u ^= 0xffu;
    ll *= -7;
    ll = ll - 100;
    ull <<= 40;
    ull = ull | 3;
    f *= 2.0f;
    f = f + 0.25f;
    d /= 4.0;
    d = d - 0.5;
    arr[i] += 10;
    arr[i] = arr[i] * 3;
    arr[i - 1] = arr[i - 1] + arr[i];
    *p *= 5;
    *p = *p - 1;
    walk++;
    walk += stride;
    walk = walk - 1;
    *walk += 1000;
    for (k = 0; k < 4; k++) {
        a.count += 1;
        pa->sum += (unsigned long long)k * 1000u;
        pa->mean = pa->mean + 0.5;
        global_total += k;
        global_total = global_total * 2;
    }
    b += 10;
    b = b + 1;
    s *= 3;
    x = x + twice(x);
    x = 1 - x;
    i = i + (k = 3);
    printf("x %d u %x ll %lld ull %llx f %.2f d %.3f\n", x, u, ll, ull, f, d);
    printf("arr %d %d %d %d p %d i %d k %d walk %d\n", arr[0], arr[1], arr[2], arr[3], *p, i, k,
           (int)(walk - arr));
    printf("acc %d %llu %.1f global %d b %u s %d calls %d\n", a.count, a.sum, a.mean, global_total,
           b, s, calls);
    return 0;
}
