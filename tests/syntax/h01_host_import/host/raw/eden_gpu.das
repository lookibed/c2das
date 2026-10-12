options gen2

// Hand-written host module of the h01 host-import fixture, --memory-model raw
// ABI: a C pointer stays a daslang pointer.  Same checksum as
// host_reference.c.
module eden_gpu public

var private g_sum : uint = 0u

def public eden_gpu_upload(data : uint8 const?; len : int) {
    for (i in range(len)) {
        g_sum = g_sum * 31u + uint(unsafe(data[i]))
    }
}

def public eden_gpu_frame(w : int; h : int) : int => int(g_sum ^ uint(w * h))
