options gen2

// Hand-written host module of the m06 host-import fixture, --memory-model
// linear ABI: the translated unit passes the heap `c2da_mem` (owned by
// `c2da_runtime` under --module-layout source) first, and a C pointer is an
// int offset into it.  This module requires neither, so no cycle forms.
module eden_gpu public

var private g_sum : uint = 0u

def public upload(mem : array<uint8>; data : int; len : int) {
    for (i in range(len)) {
        g_sum = g_sum * 31u + uint(mem[data + i])
    }
}

def public frame(mem : array<uint8>; w : int; h : int) : int {
    return int(g_sum ^ uint(w * h))
}
