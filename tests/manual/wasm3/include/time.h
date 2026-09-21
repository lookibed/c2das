#ifndef WASM3_FIXTURE_TIME_H
#define WASM3_FIXTURE_TIME_H

/* Fixture time.h: `clock_gettime` with the Linux x86-64 glibc ABI for
 * `struct timespec` (two 64-bit fields), so the C build links against the
 * real libc and the translator's `--libc std` table can lower the call. */

typedef long time_t;

struct timespec {
    time_t tv_sec;
    long tv_nsec;
};

#define CLOCK_REALTIME 0
#define CLOCK_MONOTONIC 1

int clock_gettime(int clock_id, struct timespec *ts);

#endif
