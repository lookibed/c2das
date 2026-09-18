#include <stddef.h>
#include <stdint.h>

static unsigned char heap[1024 * 1024 * 32];
static size_t heap_offset = 8;

typedef struct HeapHeader {
    size_t size;
} HeapHeader;

void shim_reset_heap(void) {
    heap_offset = 8;
}

void *malloc(size_t size) {
    const size_t aligned_header = (sizeof(HeapHeader) + 7u) & ~(size_t)7u;
    const size_t aligned_size = (size + 7u) & ~(size_t)7u;
    const size_t total = aligned_header + aligned_size;
    HeapHeader *header = 0;

    if ((heap_offset + total) > sizeof(heap)) {
        return 0;
    }

    header = (HeapHeader *)(heap + heap_offset);
    header->size = size;
    heap_offset += total;
    return (unsigned char *)header + aligned_header;
}

void free(void *ptr) {
    (void)ptr;
}

void *realloc(void *ptr, size_t size) {
    void *result = malloc(size);
    size_t old_size = 0;
    size_t copy_size = 0;
    size_t i = 0;
    const size_t aligned_header = (sizeof(HeapHeader) + 7u) & ~(size_t)7u;

    if (!result) {
        return 0;
    }

    if (ptr) {
        unsigned char *dst = (unsigned char *)result;
        const unsigned char *src = (const unsigned char *)ptr;
        const HeapHeader *header = (const HeapHeader *)(src - aligned_header);

        old_size = header->size;
        copy_size = old_size < size ? old_size : size;

        for (i = 0; i < copy_size; i++) {
            dst[i] = src[i];
        }
    }

    return result;
}

void *calloc(size_t count, size_t size) {
    size_t total = count * size;
    void *result = malloc(total);
    size_t i = 0;

    if (!result) {
        return 0;
    }

    for (i = 0; i < total; i++) {
        ((unsigned char *)result)[i] = 0;
    }

    return result;
}

void *memset(void *dest, int value, size_t count) {
    unsigned char *bytes = (unsigned char *)dest;
    size_t i = 0;
    for (i = 0; i < count; i++) {
        bytes[i] = (unsigned char)value;
    }
    return dest;
}

void *memcpy(void *dest, const void *src, size_t count) {
    unsigned char *out = (unsigned char *)dest;
    const unsigned char *in = (const unsigned char *)src;
    size_t i = 0;
    for (i = 0; i < count; i++) {
        out[i] = in[i];
    }
    return dest;
}

void *memmove(void *dest, const void *src, size_t count) {
    unsigned char *out = (unsigned char *)dest;
    const unsigned char *in = (const unsigned char *)src;
    size_t i = 0;

    if (out == in || count == 0) {
        return dest;
    }

    if (out < in) {
        for (i = 0; i < count; i++) {
            out[i] = in[i];
        }
    } else {
        for (i = count; i > 0; i--) {
            out[i - 1] = in[i - 1];
        }
    }

    return dest;
}

int memcmp(const void *lhs, const void *rhs, size_t count) {
    const unsigned char *left = (const unsigned char *)lhs;
    const unsigned char *right = (const unsigned char *)rhs;
    size_t i = 0;
    for (i = 0; i < count; i++) {
        if (left[i] != right[i]) {
            return (int)left[i] - (int)right[i];
        }
    }
    return 0;
}

void *memchr(const void *src, int value, size_t count) {
    const unsigned char *bytes = (const unsigned char *)src;
    size_t i = 0;

    for (i = 0; i < count; i++) {
        if (bytes[i] == (unsigned char)value) {
            return (void *)(bytes + i);
        }
    }

    return 0;
}

size_t strlen(const char *src) {
    size_t count = 0;

    while (src[count] != '\0') {
        count += 1;
    }

    return count;
}

char *strdup(const char *src) {
    size_t length = strlen(src);
    char *copy = (char *)malloc(length + 1u);
    size_t index = 0;

    if (!copy) {
        return 0;
    }

    for (index = 0; index < length; index++) {
        copy[index] = src[index];
    }

    copy[length] = '\0';
    return copy;
}

void *mallocz(size_t size) {
    return calloc(1u, size);
}
