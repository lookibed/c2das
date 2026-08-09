#include <stddef.h>
#include <stdint.h>

typedef struct allocation_header_s {
    size_t size;
} allocation_header;

static unsigned char heap[2 * 1024 * 1024];
static size_t heap_offset = 0;

static size_t min_size(size_t lhs, size_t rhs) {
    return lhs < rhs ? lhs : rhs;
}

void miniz_secret_reset(void) {
    heap_offset = 0;
}

void *memset(void *dest, int value, size_t count);
void *memcpy(void *dest, const void *src, size_t count);
int memcmp(const void *lhs, const void *rhs, size_t count);
size_t strlen(const char *text);

void *malloc(size_t size) {
    size_t total = sizeof(allocation_header) + size;
    size_t aligned = (total + 7u) & ~(size_t)7u;
    allocation_header *header = 0;

    if ((heap_offset + aligned) > sizeof(heap)) {
        return 0;
    }

    header = (allocation_header *)(heap + heap_offset);
    header->size = size;
    heap_offset += aligned;
    return (void *)(header + 1);
}

void free(void *ptr) {
    (void)ptr;
}

void *realloc(void *ptr, size_t size) {
    allocation_header *old_header = 0;
    void *result = 0;

    if (!ptr) {
        return malloc(size);
    }

    result = malloc(size);
    if (!result) {
        return 0;
    }

    old_header = ((allocation_header *)ptr) - 1;
    memcpy(result, ptr, min_size(old_header->size, size));
    return result;
}

void *calloc(size_t count, size_t size) {
    size_t total = count * size;
    void *result = malloc(total);
    if (result) {
        memset(result, 0, total);
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

size_t strlen(const char *text) {
	size_t length = 0;
	while (text[length] != '\0') {
		length++;
	}
	return length;
}
