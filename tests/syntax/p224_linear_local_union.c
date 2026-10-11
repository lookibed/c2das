/* A local union read back through another member — Quake's `FloatSwap` and
 * `MSG_ReadFloat` — under the linear model lives in the C stack. */
#include <stdio.h>

typedef unsigned char byte;

static float float_swap(float f) {
    union {
        float f;
        byte b[4];
    } dat1, dat2;
    dat1.f = f;
    dat2.b[0] = dat1.b[3];
    dat2.b[1] = dat1.b[2];
    dat2.b[2] = dat1.b[1];
    dat2.b[3] = dat1.b[0];
    return dat2.f;
}

static float read_float(const byte *data) {
    union {
        byte b[4];
        float f;
        int l;
    } dat;
    dat.b[0] = data[0];
    dat.b[1] = data[1];
    dat.b[2] = data[2];
    dat.b[3] = data[3];
    dat.l = dat.l + 0;
    return dat.f;
}

int main(void) {
    byte data[4] = {0x00, 0x00, 0xc0, 0x3f};
    float f = read_float(data);
    float s = float_swap(f);
    float back = float_swap(s);
    printf("%d %d %d\n", (int)(f * 100.0f), back == f, (int)(read_float(data) * 4.0f));
    return 0;
}
