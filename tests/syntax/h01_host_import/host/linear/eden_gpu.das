options gen2

// Hand-written host module of the h01 host-import fixture, --memory-model
// linear ABI: the translated module passes its heap `c2da_mem` first, and a C
// pointer is an int offset into it.  Same checksum as host_reference.c.
module eden_gpu public

var private g_sum : uint = 0u

def public eden_gpu_upload(mem : array<uint8>; data : int; len : int) {
    for (i in range(len)) {
        g_sum = g_sum * 31u + uint(mem[data + i])
    }
}

[unused_argument(mem)]
def public eden_gpu_frame(mem : array<uint8>; w : int; h : int) : int => int(g_sum ^ uint(w * h))
