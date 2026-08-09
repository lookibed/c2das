options gen2

def c2da_min_int(a : int; b : int) : int {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int(a : int; b : int) : int {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint(a : uint; b : uint) : uint {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint(a : uint; b : uint) : uint {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_int64(a : int64; b : int64) : int64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_int64(a : int64; b : int64) : int64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_min_uint64(a : uint64; b : uint64) : uint64 {
    if (a < b) {
        return a
    } else {
        return b
    }
}
def c2da_max_uint64(a : uint64; b : uint64) : uint64 {
    if (a > b) {
        return a
    } else {
        return b
    }
}
def c2da_clip_uint(v : int) : uint {
    if (v < 0) {
        return 0x0
    }
    if (v > 255) {
        return 0xff
    }
    return uint(v)
}
def c2da_bool_to_uint(v : bool) : uint {
    if (v == true) {
        return 0x1
    } else {
        return 0x0
    }
}
def c2da___assert_fail(expr : void?; file : void?; line : uint; func : void?) {
}
typedef size_t = uint64
typedef int16_t = int16
typedef int32_t = int
typedef int64_t = int64
typedef uint8_t = uint8
typedef uint16_t = uint16
typedef uint32_t = uint
typedef intptr_t = int64
struct HeapHeader {
    size : size_t
}
struct plm_t {
    demux : plm_demux_t?
    time : double
    has_ended : int
    loop : int
    has_decoders : int
    video_enabled : int
    video_packet_type : int
    video_buffer : plm_buffer_t?
    video_decoder : plm_video_t?
    audio_enabled : int
    audio_stream_index : int
    audio_packet_type : int
    audio_lead_time : double
    audio_buffer : plm_buffer_t?
    audio_decoder : plm_audio_t?
    video_decode_callback : plm_video_decode_callback
    video_decode_callback_user_data : uint64
    audio_decode_callback : plm_audio_decode_callback
    audio_decode_callback_user_data : uint64
}
typedef plm_audio_decode_callback = function?
struct plm_samples_t {
    time : double
    count : uint
    interleaved : array<float>
}
typedef plm_video_decode_callback = function?
struct plm_frame_t {
    time : double
    width : uint
    height : uint
    y : plm_plane_t
    cr : plm_plane_t
    cb : plm_plane_t
}
struct plm_plane_t {
    width : uint
    height : uint
    data : uint8?
}
struct plm_audio_t {
    time : double
    samples_decoded : int
    samplerate_index : int
    bitrate_index : int
    version : int
    layer : int
    mode : int
    bound : int
    v_pos : int
    next_frame_data_size : int
    has_header : int
    buffer : plm_buffer_t?
    destroy_buffer_when_done : int
    allocation : array<array<plm_quantizer_spec_t const?>>
    scale_factor_info : array<array<uint8>>
    scale_factor : array<array<array<int>>>
    sample : array<array<array<int>>>
    samples : plm_samples_t
    D : array<float>
    V : array<array<float>>
    U : array<float>
}
struct plm_quantizer_spec_t {
    levels : int
    group : uint8
    bits : uint8
}
struct plm_buffer_t {
    bit_index : size_t
    capacity : size_t
    length : size_t
    total_size : size_t
    discard_read_bytes : int
    has_ended : int
    free_when_done : int
    load_callback : plm_buffer_load_callback
    seek_callback : plm_buffer_seek_callback
    tell_callback : plm_buffer_tell_callback
    load_callback_user_data : uint64
    bytes : uint8?
    mode : plm_buffer_mode
}
enum plm_buffer_mode : uint {
    PLM_BUFFER_MODE_FILE = 0
    PLM_BUFFER_MODE_FIXED_MEM = 1
    PLM_BUFFER_MODE_RING = 2
    PLM_BUFFER_MODE_APPEND = 3
}
typedef plm_buffer_tell_callback = function?
typedef plm_buffer_seek_callback = function?
typedef plm_buffer_load_callback = function?
struct plm_video_t {
    framerate : double
    pixel_aspect_ratio : double
    time : double
    frames_decoded : int
    width : int
    height : int
    mb_width : int
    mb_height : int
    mb_size : int
    luma_width : int
    luma_height : int
    chroma_width : int
    chroma_height : int
    start_code : int
    picture_type : int
    motion_forward : plm_video_motion_t
    motion_backward : plm_video_motion_t
    has_sequence_header : int
    quantizer_scale : int
    slice_begin : int
    macroblock_address : int
    mb_row : int
    mb_col : int
    macroblock_type : int
    macroblock_intra : int
    dc_predictor : array<int>
    buffer : plm_buffer_t?
    destroy_buffer_when_done : int
    frame_current : plm_frame_t
    frame_forward : plm_frame_t
    frame_backward : plm_frame_t
    frames_data : uint8?
    block_data : array<int>
    intra_quant_matrix : array<uint8>
    non_intra_quant_matrix : array<uint8>
    has_reference_frame : int
    assume_no_b_frames : int
}
struct plm_video_motion_t {
    full_px : int
    is_set : int
    r_size : int
    h : int
    v : int
}
struct plm_demux_t {
    buffer : plm_buffer_t?
    destroy_buffer_when_done : int
    system_clock_ref : double
    last_file_size : size_t
    last_decoded_pts : double
    start_time : double
    duration : double
    start_code : int
    has_pack_header : int
    has_system_header : int
    has_headers : int
    num_audio_streams : int
    num_video_streams : int
    current_packet : plm_packet_t
    next_packet : plm_packet_t
}
struct plm_packet_t {
    type_0 : int
    pts : double
    length : size_t
    data : uint8?
}
struct plm_vlc_uint_t {
    index : int16
    value : uint16
}
struct plm_vlc_t {
    index : int16
    value : int16
}
struct DecodeSummary {
    combined_hash : uint
    first_hash : uint
    last_hash : uint
    frame_count : int
    width : int
    height : int
}
var heap : array<uint8>

var heap_offset : size_t = unsafe(reinterpret<size_t>(8))

[export]
def shim_reset_heap() {
    heap_offset = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(8))))
    return
}
[export]
def malloc(var size : size_t) : uint64 {
    var aligned_header : size_t const = unsafe(reinterpret<size_t>(0))
    var aligned_size : size_t const = unsafe(reinterpret<size_t>(0))
    var total : size_t const = unsafe(reinterpret<size_t>(0))
    var header : HeapHeader? = cast<HeapHeader?>(0)
    aligned_header = 4 + int(int(uint64(0x7))) & int(~unsafe(reinterpret<size_t>(0x7)))
    aligned_size = unsafe(reinterpret<size_t>(size)) + unsafe(reinterpret<size_t>(0x7)) & ~unsafe(reinterpret<size_t>(0x7))
    total = unsafe(reinterpret<size_t>(aligned_header)) + unsafe(reinterpret<size_t>(aligned_size))
    header = null
    if (unsafe(reinterpret<size_t>(heap_offset)) + unsafe(reinterpret<size_t>(total)) > unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(4))))) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
    } else {
        header = unsafe(unsafe(reinterpret<HeapHeader?>(unsafe(unsafe(addr(heap[0])) + unsafe(reinterpret<size_t>(heap_offset))))))
        header.size = unsafe(reinterpret<size_t>(size))
        heap_offset = unsafe(reinterpret<size_t>(heap_offset + total))
        return unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint64>(unsafe(header + unsafe(reinterpret<size_t>(aligned_header)))))))))
    }
}
[export]
def free(var ptr : uint64) {
    ptr
    return
}
[export]
def realloc(var ptr_0 : uint64; var size_0 : size_t) : uint64 {
    var result_0 : uint64 = uint64(0)
    var old_size : size_t = unsafe(reinterpret<size_t>(0))
    var copy_size : size_t = unsafe(reinterpret<size_t>(0))
    var i : size_t = unsafe(reinterpret<size_t>(0))
    var aligned_header_0 : size_t const = unsafe(reinterpret<size_t>(0))
    var dst : uint8? = cast<uint8?>(0)
    var src : uint8 const? = cast<uint8 const?>(0)
    var header_0 : HeapHeader const? = cast<HeapHeader const?>(0)
    result_0 = unsafe(malloc(size_0))
    old_size = unsafe(reinterpret<size_t>(0))
    copy_size = unsafe(reinterpret<size_t>(0))
    i = unsafe(reinterpret<size_t>(0))
    aligned_header_0 = 4 + int(int(uint64(0x7))) & int(~unsafe(reinterpret<size_t>(0x7)))
    if (uint64(result_0) == uint64(0)) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
    } elif (uint64(ptr_0) != uint64(0)) {
        dst = result_0
        src = ptr_0
        header_0 = unsafe(src - unsafe(reinterpret<size_t>(aligned_header_0)))
        old_size = unsafe(reinterpret<size_t>(header_0.size))
        var c2da_fresh0 : size_t = unsafe(reinterpret<size_t>(0))
        if (unsafe(reinterpret<size_t>(old_size)) < unsafe(reinterpret<size_t>(size_0))) {
            c2da_fresh0 = old_size
        } else {
            c2da_fresh0 = size_0
        }
        copy_size = unsafe(reinterpret<size_t>(c2da_fresh0))
        break
    } else {
        return unsafe(unsafe(reinterpret<uint64>(result_0)))
    }
}
[export]
def calloc(var count : size_t; var size_1 : size_t) : uint64 {
    var total_0 : size_t = unsafe(reinterpret<size_t>(0))
    var result_1 : uint64 = uint64(0)
    var i_0 : size_t = unsafe(reinterpret<size_t>(0))
    total_0 = unsafe(reinterpret<size_t>(count)) * unsafe(reinterpret<size_t>(size_1))
    result_1 = unsafe(malloc(total_0))
    i_0 = unsafe(reinterpret<size_t>(0))
    if (uint64(result_1) == uint64(0)) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
    } else {
        break
    }
}
[export]
def memset(var dest : uint64; var value : int; var count_0 : size_t) : uint64 {
    var bytes : uint8? = cast<uint8?>(0)
    var i_1 : size_t = unsafe(reinterpret<size_t>(0))
    bytes = dest
    i_1 = unsafe(reinterpret<size_t>(0))
    break
}
[export]
def memcpy(var dest_0 : uint64; var src_0 : uint64; var count_1 : size_t) : uint64 {
    var out : uint8? = cast<uint8?>(0)
    var in_0 : uint8 const? = cast<uint8 const?>(0)
    var i_2 : size_t = unsafe(reinterpret<size_t>(0))
    out = dest_0
    in_0 = src_0
    i_2 = unsafe(reinterpret<size_t>(0))
    break
}
[export]
def memmove(var dest_1 : uint64; var src_1 : uint64; var count_2 : size_t) : uint64 {
    var out_0 : uint8? = cast<uint8?>(0)
    var in_1 : uint8 const? = cast<uint8 const?>(0)
    var i_3 : size_t = unsafe(reinterpret<size_t>(0))
    out_0 = dest_1
    in_1 = src_1
    i_3 = unsafe(reinterpret<size_t>(0))
    if (unsafe(unsafe(reinterpret<uint64>(out_0)) == unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8?>(in_1)))))) || uint64(unsafe(reinterpret<size_t>(count_2))) == uint64(0)) {
        return unsafe(unsafe(reinterpret<uint64>(dest_1)))
    } elif (unsafe(unsafe(reinterpret<uint64>(out_0)) < unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8?>(in_1))))))) {
        break
    } else {
        break
    }
}
[export]
def memcmp(var lhs : uint64; var rhs : uint64; var count_3 : size_t) : int {
    var left : uint8 const? = cast<uint8 const?>(0)
    var right : uint8 const? = cast<uint8 const?>(0)
    var i_4 : size_t = unsafe(reinterpret<size_t>(0))
    left = lhs
    right = rhs
    i_4 = unsafe(reinterpret<size_t>(0))
    break
}
[export]
def abs(var value_0 : int) : int {
    var c2da_fresh1 : int = int(0)
    if (int(value_0) < 0) {
        c2da_fresh1 = -value_0
    } else {
        c2da_fresh1 = value_0
    }
    return c2da_fresh1
}
[export]
def plm_create_with_memory(var bytes_0 : uint8?; var length : size_t; var free_when_done : int) : plm_t? {
    var buffer : plm_buffer_t? = cast<plm_buffer_t?>(0)
    buffer = plm_buffer_create_with_memory(bytes_0, length, free_when_done)
    return unsafe(unsafe(reinterpret<plm_t?>(plm_create_with_buffer(buffer, 1))))
}
[export]
def plm_buffer_create_with_memory(var bytes_1 : uint8?; var length_0 : size_t; var free_when_done_0 : int) : plm_buffer_t? {
    var self : plm_buffer_t? = cast<plm_buffer_t?>(0)
    self = unsafe(malloc(4))
    memset(unsafe(unsafe(reinterpret<uint64>(self))), 0, uint64(4))
    self.capacity = unsafe(reinterpret<size_t>(length_0))
    self.length = unsafe(reinterpret<size_t>(length_0))
    self.total_size = unsafe(reinterpret<size_t>(length_0))
    self.free_when_done = free_when_done_0
    self.bytes = unsafe(unsafe(reinterpret<uint8?>(bytes_1)))
    self.mode = unsafe(reinterpret<plm_buffer_mode>(PLM_BUFFER_MODE_FIXED_MEM))
    self.discard_read_bytes = 0
    return unsafe(unsafe(reinterpret<plm_buffer_t?>(self)))
}
[export]
def plm_create_with_buffer(var buffer_0 : plm_buffer_t?; var destroy_when_done : int) : plm_t? {
    var self_0 : plm_t? = cast<plm_t?>(0)
    self_0 = unsafe(malloc(4))
    memset(unsafe(unsafe(reinterpret<uint64>(self_0))), 0, uint64(4))
    self_0.demux = unsafe(unsafe(reinterpret<plm_demux_t?>(plm_demux_create(buffer_0, destroy_when_done))))
    self_0.video_enabled = 1
    self_0.audio_enabled = 1
    plm_init_decoders(self_0)
    return unsafe(unsafe(reinterpret<plm_t?>(self_0)))
}
[export]
def plm_init_decoders(var self_1 : plm_t?) : int {
    if (uint64(self_1.has_decoders) != uint64(0)) {
        return 1
    } elif (uint64(plm_demux_has_headers(self_1.demux)) == uint64(0)) {
        return 0
    } else {
        if (plm_demux_get_num_video_streams(self_1.demux) > 0) {
            if (uint64(self_1.video_enabled) != uint64(0)) {
                self_1.video_packet_type = PLM_DEMUX_PACKET_VIDEO_1
            }
            if (self_1.video_decoder == null) {
                self_1.video_buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(plm_buffer_create_with_capacity(unsafe(reinterpret<size_t>(128 * 1024))))))
                plm_buffer_set_load_callback(self_1.video_buffer, plm_read_video_packet, unsafe(unsafe(reinterpret<uint64>(self_1))))
                self_1.video_decoder = unsafe(unsafe(reinterpret<plm_video_t?>(plm_video_create_with_buffer(self_1.video_buffer, 1))))
            }
        }
        if (plm_demux_get_num_audio_streams(self_1.demux) > 0) {
            if (uint64(self_1.audio_enabled) != uint64(0)) {
                self_1.audio_packet_type = int(PLM_DEMUX_PACKET_AUDIO_1) + int(self_1.audio_stream_index)
            }
            if (self_1.audio_decoder == null) {
                self_1.audio_buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(plm_buffer_create_with_capacity(unsafe(reinterpret<size_t>(128 * 1024))))))
                plm_buffer_set_load_callback(self_1.audio_buffer, plm_read_audio_packet, unsafe(unsafe(reinterpret<uint64>(self_1))))
                self_1.audio_decoder = unsafe(unsafe(reinterpret<plm_audio_t?>(plm_audio_create_with_buffer(self_1.audio_buffer, 1))))
            }
        }
        self_1.has_decoders = 1
        return 1
    }
}
[export]
def plm_audio_create_with_buffer(var buffer_1 : plm_buffer_t?; var destroy_when_done_0 : int) : plm_audio_t? {
    var self_2 : plm_audio_t? = cast<plm_audio_t?>(0)
    self_2 = unsafe(malloc(4))
    memset(unsafe(unsafe(reinterpret<uint64>(self_2))), 0, uint64(4))
    self_2.samples.count = uint(uint(1152))
    self_2.buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(buffer_1)))
    self_2.destroy_buffer_when_done = destroy_when_done_0
    self_2.samplerate_index = 3
    memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_2.D[0]))))), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(PLM_AUDIO_SYNTHESIS_WINDOW[0]))))), uint64(uint64(512) * uint64(4)))
    memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(self_2.D[0])) + 512)))), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(PLM_AUDIO_SYNTHESIS_WINDOW[0]))))), uint64(uint64(512) * uint64(4)))
    self_2.next_frame_data_size = plm_audio_decode_header(self_2)
    return unsafe(unsafe(reinterpret<plm_audio_t?>(self_2)))
}
[export]
def plm_audio_decode_header(var self_3 : plm_audio_t?) : int {
    var sync : int = int(0)
    var hasCRC : int = int(0)
    var bitrate_index : int = int(0)
    var samplerate_index : int = int(0)
    var padding : int = int(0)
    var mode : int = int(0)
    var bitrate : int = int(0)
    var samplerate : int = int(0)
    var frame_size : int = int(0)
    if (uint64(plm_buffer_has(self_3.buffer, unsafe(reinterpret<size_t>(48)))) == uint64(0)) {
        return 0
    } else {
        plm_buffer_skip_bytes(self_3.buffer, uint8(0))
        sync = plm_buffer_read(self_3.buffer, 11)
        if (int(sync) != int(PLM_AUDIO_FRAME_SYNC) && uint64(plm_audio_find_frame_sync(self_3)) == uint64(0)) {
            return 0
        } else {
            self_3.version = plm_buffer_read(self_3.buffer, 2)
            self_3.layer = plm_buffer_read(self_3.buffer, 2)
            hasCRC = uint64(plm_buffer_read(self_3.buffer, 1)) == uint64(0)
            if (int(self_3.version) != int(PLM_AUDIO_MPEG_1) || int(self_3.layer) != int(PLM_AUDIO_LAYER_II)) {
                return 0
            } else {
                bitrate_index = plm_buffer_read(self_3.buffer, 4) - 1
                if (int(bitrate_index) > 13) {
                    return 0
                } else {
                    samplerate_index = plm_buffer_read(self_3.buffer, 2)
                    if (int(samplerate_index) == 3) {
                        return 0
                    } else {
                        padding = plm_buffer_read(self_3.buffer, 1)
                        plm_buffer_skip(self_3.buffer, unsafe(reinterpret<size_t>(1)))
                        mode = plm_buffer_read(self_3.buffer, 2)
                        if (uint64(self_3.has_header) != uint64(0) && int(self_3.bitrate_index) != int(bitrate_index) || int(self_3.samplerate_index) != int(samplerate_index) || int(self_3.mode) != int(mode)) {
                            return 0
                        } else {
                            self_3.bitrate_index = bitrate_index
                            self_3.samplerate_index = samplerate_index
                            self_3.mode = mode
                            self_3.has_header = 1
                            if (int(mode) == int(PLM_AUDIO_MODE_JOINT_STEREO)) {
                                self_3.bound = uint(plm_buffer_read(self_3.buffer, 2) + 1) << uint(2)
                            } else {
                                plm_buffer_skip(self_3.buffer, unsafe(reinterpret<size_t>(2)))
                                var c2da_fresh2 : int = int(0)
                                if (int(mode) == int(PLM_AUDIO_MODE_MONO)) {
                                    c2da_fresh2 = 0
                                } else {
                                    c2da_fresh2 = 32
                                }
                                self_3.bound = c2da_fresh2
                            }
                            plm_buffer_skip(self_3.buffer, unsafe(reinterpret<size_t>(4)))
                            if (uint64(hasCRC) != uint64(0)) {
                                plm_buffer_skip(self_3.buffer, unsafe(reinterpret<size_t>(16)))
                            }
                            bitrate = unsafe(unsafe(addr(PLM_AUDIO_BIT_RATE[0]))[uint(self_3.bitrate_index)])
                            samplerate = unsafe(unsafe(addr(PLM_AUDIO_SAMPLE_RATE[0]))[uint(self_3.samplerate_index)])
                            frame_size = 144000 * int(bitrate) / int(samplerate) + int(padding)
                            var c2da_fresh3 : int = int(0)
                            if (uint64(hasCRC) != uint64(0)) {
                                c2da_fresh3 = 6
                            } else {
                                c2da_fresh3 = 4
                            }
                            return int(frame_size) - int(c2da_fresh3)
                        }
                    }
                }
            }
        }
    }
}
[export]
def plm_buffer_read(var self_4 : plm_buffer_t?; var count_4 : int) : int {
    var value_1 : int = int(0)
    var current_byte : int = int(0)
    var remaining : int = int(0)
    var read : int = int(0)
    var shift : int = int(0)
    var mask : int = int(0)
    if (uint64(plm_buffer_has(self_4, unsafe(reinterpret<size_t>(count_4)))) == uint64(0)) {
        return 0
    } else {
        value_1 = 0
        while (true) {
            if (!uint64(count_4) != uint64(0)) {
                break
            }
            current_byte = int(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_4.bytes)))[uint(unsafe(reinterpret<size_t>(self_4.bit_index)) >> unsafe(reinterpret<size_t>(3)))]))
            remaining = int(unsafe(reinterpret<size_t>(8)) - (unsafe(reinterpret<size_t>(self_4.bit_index)) & unsafe(reinterpret<size_t>(7))))
            var c2da_fresh4 : int = int(0)
            if (int(remaining) < int(count_4)) {
                c2da_fresh4 = remaining
            } else {
                c2da_fresh4 = count_4
            }
            read = c2da_fresh4
            shift = int(remaining) - int(read)
            mask = 255 >> 8 - int(read)
            value_1 = int(value_1) << int(read) | (int(current_byte) & int(mask) << int(shift)) >> int(shift)
            self_4.bit_index = unsafe(reinterpret<size_t>(self_4.bit_index + unsafe(reinterpret<size_t>(read))))
            count_4 = count_4 - read
        }
        return value_1
    }
}
[export]
def plm_buffer_has(var self_5 : plm_buffer_t?; var count_5 : size_t) : int {
    if ((unsafe(reinterpret<size_t>(self_5.length)) << unsafe(reinterpret<size_t>(3))) - unsafe(reinterpret<size_t>(self_5.bit_index)) >= unsafe(reinterpret<size_t>(count_5))) {
        return 1
    } else {
        if (self_5.load_callback != null) {
            self_5.load_callback(self_5, self_5.load_callback_user_data)
            if ((unsafe(reinterpret<size_t>(self_5.length)) << unsafe(reinterpret<size_t>(3))) - unsafe(reinterpret<size_t>(self_5.bit_index)) >= unsafe(reinterpret<size_t>(count_5))) {
                return 1
            }
        }
        if (uint64(unsafe(reinterpret<size_t>(self_5.total_size))) != uint64(0) && unsafe(reinterpret<size_t>(self_5.length)) == unsafe(reinterpret<size_t>(self_5.total_size))) {
            self_5.has_ended = 1
        }
        return 0
    }
}
var PLM_AUDIO_SAMPLE_RATE : array<int> const = [44100, 48000, 32000, int(0), 22050, 24000, 16000, int(0)]

var PLM_AUDIO_BIT_RATE : array<int> const = [32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160]

[export]
def plm_buffer_skip(var self_6 : plm_buffer_t?; var count_6 : size_t) {
    if (uint64(plm_buffer_has(self_6, count_6)) != uint64(0)) {
        self_6.bit_index = unsafe(reinterpret<size_t>(self_6.bit_index + count_6))
    }
    return
}
var PLM_AUDIO_MODE_MONO : int const = int(3)

var PLM_AUDIO_MODE_JOINT_STEREO : int const = int(1)

var PLM_AUDIO_LAYER_II : int const = int(2)

var PLM_AUDIO_MPEG_1 : int const = int(3)

[export]
def plm_audio_find_frame_sync(var self_7 : plm_audio_t?) : int {
    var i_5 : size_t = unsafe(reinterpret<size_t>(0))
    break
}
var PLM_AUDIO_FRAME_SYNC : int const = int(2047)

[export]
def plm_buffer_skip_bytes(var self_8 : plm_buffer_t?; var v : uint8) : int {
    var skipped : int = int(0)
    plm_buffer_align(self_8)
    skipped = 0
    while (true) {
        if (!uint64(plm_buffer_has(self_8, unsafe(reinterpret<size_t>(8)))) != uint64(0) && int(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_8.bytes)))[uint(unsafe(reinterpret<size_t>(self_8.bit_index)) >> unsafe(reinterpret<size_t>(3)))])) == int(v)) {
            break
        }
        self_8.bit_index = unsafe(reinterpret<size_t>(self_8.bit_index + unsafe(reinterpret<size_t>(8))))
        skipped = skipped + 1
        skipped
    }
    return skipped
}
[export]
def plm_buffer_align(var self_9 : plm_buffer_t?) {
    self_9.bit_index = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(self_9.bit_index)) + unsafe(reinterpret<size_t>(7)) >> unsafe(reinterpret<size_t>(3)) << unsafe(reinterpret<size_t>(3))))
    return
}
var PLM_AUDIO_SYNTHESIS_WINDOW : array<float> const = [float(double(0.0)), float(-double(0.5)), float(-double(0.5)), float(-double(0.5)), float(-double(0.5)), float(-double(0.5)), float(-double(0.5)), float(-double(1.0)), float(-double(1.0)), float(-double(1.0)), float(-double(1.0)), float(-double(1.5)), float(-double(1.5)), float(-double(2.0)), float(-double(2.0)), float(-double(2.5)), float(-double(2.5)), float(-double(3.0)), float(-double(3.5)), float(-double(3.5)), float(-double(4.0)), float(-double(4.5)), float(-double(5.0)), float(-double(5.5)), float(-double(6.5)), float(-double(7.0)), float(-double(8.0)), float(-double(8.5)), float(-double(9.5)), float(-double(10.5)), float(-double(12.0)), float(-double(13.0)), float(-double(14.5)), float(-double(15.5)), float(-double(17.5)), float(-double(19.0)), float(-double(20.5)), float(-double(22.5)), float(-double(24.5)), float(-double(26.5)), float(-double(29.0)), float(-double(31.5)), float(-double(34.0)), float(-double(36.5)), float(-double(39.5)), float(-double(42.5)), float(-double(45.5)), float(-double(48.5)), float(-double(52.0)), float(-double(55.5)), float(-double(58.5)), float(-double(62.5)), float(-double(66.0)), float(-double(69.5)), float(-double(73.5)), float(-double(77.0)), float(-double(80.5)), float(-double(84.5)), float(-double(88.0)), float(-double(91.5)), float(-double(95.0)), float(-double(98.0)), float(-double(101.0)), float(-double(104.0)), float(double(106.5)), float(double(109.0)), float(double(111.0)), float(double(112.5)), float(double(113.5)), float(double(114.0)), float(double(114.0)), float(double(113.5)), float(double(112.0)), float(double(110.5)), float(double(107.5)), float(double(104.0)), float(double(100.0)), float(double(94.5)), float(double(88.5)), float(double(81.5)), float(double(73.0)), float(double(63.5)), float(double(53.0)), float(double(41.5)), float(double(28.5)), float(double(14.5)), float(-double(1.0)), float(-double(18.0)), float(-double(36.0)), float(-double(55.5)), float(-double(76.5)), float(-double(98.5)), float(-double(122.0)), float(-double(147.0)), float(-double(173.5)), float(-double(200.5)), float(-double(229.5)), float(-double(259.5)), float(-double(290.5)), float(-double(322.5)), float(-double(355.5)), float(-double(389.5)), float(-double(424.0)), float(-double(459.5)), float(-double(495.5)), float(-double(532.0)), float(-double(568.5)), float(-double(605.0)), float(-double(641.5)), float(-double(678.0)), float(-double(714.0)), float(-double(749.0)), float(-double(783.5)), float(-double(817.0)), float(-double(849.0)), float(-double(879.5)), float(-double(908.5)), float(-double(935.0)), float(-double(959.5)), float(-double(981.0)), float(-double(1000.5)), float(-double(1016.0)), float(-double(1028.5)), float(-double(1037.5)), float(-double(1042.5)), float(-double(1043.5)), float(-double(1040.0)), float(-double(1031.5)), float(double(1018.5)), float(double(1000.0)), float(double(976.0)), float(double(946.5)), float(double(911.0)), float(double(869.5)), float(double(822.0)), float(double(767.5)), float(double(707.0)), float(double(640.0)), float(double(565.5)), float(double(485.0)), float(double(397.0)), float(double(302.5)), float(double(201.0)), float(double(92.5)), float(-double(22.5)), float(-double(144.0)), float(-double(272.5)), float(-double(407.0)), float(-double(547.5)), float(-double(694.0)), float(-double(846.0)), float(-double(1003.0)), float(-double(1165.0)), float(-double(1331.5)), float(-double(1502.0)), float(-double(1675.5)), float(-double(1852.5)), float(-double(2031.5)), float(-double(2212.5)), float(-double(2394.0)), float(-double(2576.5)), float(-double(2758.5)), float(-double(2939.5)), float(-double(3118.5)), float(-double(3294.5)), float(-double(3467.5)), float(-double(3635.5)), float(-double(3798.5)), float(-double(3955.0)), float(-double(4104.5)), float(-double(4245.5)), float(-double(4377.5)), float(-double(4499.0)), float(-double(4609.5)), float(-double(4708.0)), float(-double(4792.5)), float(-double(4863.5)), float(-double(4919.0)), float(-double(4958.0)), float(-double(4979.5)), float(-double(4983.0)), float(-double(4967.5)), float(-double(4931.5)), float(-double(4875.0)), float(-double(4796.0)), float(-double(4694.5)), float(-double(4569.5)), float(-double(4420.0)), float(-double(4246.0)), float(-double(4046.0)), float(-double(3820.0)), float(-double(3567.0)), float(double(3287.0)), float(double(2979.5)), float(double(2644.0)), float(double(2280.5)), float(double(1888.0)), float(double(1467.5)), float(double(1018.5)), float(double(541.0)), float(double(35.0)), float(-double(499.0)), float(-double(1061.0)), float(-double(1650.0)), float(-double(2266.5)), float(-double(2909.0)), float(-double(3577.0)), float(-double(4270.0)), float(-double(4987.5)), float(-double(5727.5)), float(-double(6490.0)), float(-double(7274.0)), float(-double(8077.5)), float(-double(8899.5)), float(-double(9739.0)), float(-double(10594.5)), float(-double(11464.5)), float(-double(12347.0)), float(-double(13241.0)), float(-double(14144.5)), float(-double(15056.0)), float(-double(15973.5)), float(-double(16895.5)), float(-double(17820.0)), float(-double(18744.5)), float(-double(19668.0)), float(-double(20588.0)), float(-double(21503.0)), float(-double(22410.5)), float(-double(23308.5)), float(-double(24195.0)), float(-double(25068.5)), float(-double(25926.5)), float(-double(26767.0)), float(-double(27589.0)), float(-double(28389.0)), float(-double(29166.5)), float(-double(29919.0)), float(-double(30644.5)), float(-double(31342.0)), float(-double(32009.5)), float(-double(32645.0)), float(-double(33247.0)), float(-double(33814.5)), float(-double(34346.0)), float(-double(34839.5)), float(-double(35295.0)), float(-double(35710.0)), float(-double(36084.5)), float(-double(36417.5)), float(-double(36707.5)), float(-double(36954.0)), float(-double(37156.5)), float(-double(37315.0)), float(-double(37428.0)), float(-double(37496.0)), float(double(37519.0)), float(double(37496.0)), float(double(37428.0)), float(double(37315.0)), float(double(37156.5)), float(double(36954.0)), float(double(36707.5)), float(double(36417.5)), float(double(36084.5)), float(double(35710.0)), float(double(35295.0)), float(double(34839.5)), float(double(34346.0)), float(double(33814.5)), float(double(33247.0)), float(double(32645.0)), float(double(32009.5)), float(double(31342.0)), float(double(30644.5)), float(double(29919.0)), float(double(29166.5)), float(double(28389.0)), float(double(27589.0)), float(double(26767.0)), float(double(25926.5)), float(double(25068.5)), float(double(24195.0)), float(double(23308.5)), float(double(22410.5)), float(double(21503.0)), float(double(20588.0)), float(double(19668.0)), float(double(18744.5)), float(double(17820.0)), float(double(16895.5)), float(double(15973.5)), float(double(15056.0)), float(double(14144.5)), float(double(13241.0)), float(double(12347.0)), float(double(11464.5)), float(double(10594.5)), float(double(9739.0)), float(double(8899.5)), float(double(8077.5)), float(double(7274.0)), float(double(6490.0)), float(double(5727.5)), float(double(4987.5)), float(double(4270.0)), float(double(3577.0)), float(double(2909.0)), float(double(2266.5)), float(double(1650.0)), float(double(1061.0)), float(double(499.0)), float(-double(35.0)), float(-double(541.0)), float(-double(1018.5)), float(-double(1467.5)), float(-double(1888.0)), float(-double(2280.5)), float(-double(2644.0)), float(-double(2979.5)), float(double(3287.0)), float(double(3567.0)), float(double(3820.0)), float(double(4046.0)), float(double(4246.0)), float(double(4420.0)), float(double(4569.5)), float(double(4694.5)), float(double(4796.0)), float(double(4875.0)), float(double(4931.5)), float(double(4967.5)), float(double(4983.0)), float(double(4979.5)), float(double(4958.0)), float(double(4919.0)), float(double(4863.5)), float(double(4792.5)), float(double(4708.0)), float(double(4609.5)), float(double(4499.0)), float(double(4377.5)), float(double(4245.5)), float(double(4104.5)), float(double(3955.0)), float(double(3798.5)), float(double(3635.5)), float(double(3467.5)), float(double(3294.5)), float(double(3118.5)), float(double(2939.5)), float(double(2758.5)), float(double(2576.5)), float(double(2394.0)), float(double(2212.5)), float(double(2031.5)), float(double(1852.5)), float(double(1675.5)), float(double(1502.0)), float(double(1331.5)), float(double(1165.0)), float(double(1003.0)), float(double(846.0)), float(double(694.0)), float(double(547.5)), float(double(407.0)), float(double(272.5)), float(double(144.0)), float(double(22.5)), float(-double(92.5)), float(-double(201.0)), float(-double(302.5)), float(-double(397.0)), float(-double(485.0)), float(-double(565.5)), float(-double(640.0)), float(-double(707.0)), float(-double(767.5)), float(-double(822.0)), float(-double(869.5)), float(-double(911.0)), float(-double(946.5)), float(-double(976.0)), float(-double(1000.0)), float(double(1018.5)), float(double(1031.5)), float(double(1040.0)), float(double(1043.5)), float(double(1042.5)), float(double(1037.5)), float(double(1028.5)), float(double(1016.0)), float(double(1000.5)), float(double(981.0)), float(double(959.5)), float(double(935.0)), float(double(908.5)), float(double(879.5)), float(double(849.0)), float(double(817.0)), float(double(783.5)), float(double(749.0)), float(double(714.0)), float(double(678.0)), float(double(641.5)), float(double(605.0)), float(double(568.5)), float(double(532.0)), float(double(495.5)), float(double(459.5)), float(double(424.0)), float(double(389.5)), float(double(355.5)), float(double(322.5)), float(double(290.5)), float(double(259.5)), float(double(229.5)), float(double(200.5)), float(double(173.5)), float(double(147.0)), float(double(122.0)), float(double(98.5)), float(double(76.5)), float(double(55.5)), float(double(36.0)), float(double(18.0)), float(double(1.0)), float(-double(14.5)), float(-double(28.5)), float(-double(41.5)), float(-double(53.0)), float(-double(63.5)), float(-double(73.0)), float(-double(81.5)), float(-double(88.5)), float(-double(94.5)), float(-double(100.0)), float(-double(104.0)), float(-double(107.5)), float(-double(110.5)), float(-double(112.0)), float(-double(113.5)), float(-double(114.0)), float(-double(114.0)), float(-double(113.5)), float(-double(112.5)), float(-double(111.0)), float(-double(109.0)), float(double(106.5)), float(double(104.0)), float(double(101.0)), float(double(98.0)), float(double(95.0)), float(double(91.5)), float(double(88.0)), float(double(84.5)), float(double(80.5)), float(double(77.0)), float(double(73.5)), float(double(69.5)), float(double(66.0)), float(double(62.5)), float(double(58.5)), float(double(55.5)), float(double(52.0)), float(double(48.5)), float(double(45.5)), float(double(42.5)), float(double(39.5)), float(double(36.5)), float(double(34.0)), float(double(31.5)), float(double(29.0)), float(double(26.5)), float(double(24.5)), float(double(22.5)), float(double(20.5)), float(double(19.0)), float(double(17.5)), float(double(15.5)), float(double(14.5)), float(double(13.0)), float(double(12.0)), float(double(10.5)), float(double(9.5)), float(double(8.5)), float(double(8.0)), float(double(7.0)), float(double(6.5)), float(double(5.5)), float(double(5.0)), float(double(4.5)), float(double(4.0)), float(double(3.5)), float(double(3.5)), float(double(3.0)), float(double(2.5)), float(double(2.5)), float(double(2.0)), float(double(2.0)), float(double(1.5)), float(double(1.5)), float(double(1.0)), float(double(1.0)), float(double(1.0)), float(double(1.0)), float(double(0.5)), float(double(0.5)), float(double(0.5)), float(double(0.5)), float(double(0.5)), float(double(0.5))]

[export]
def plm_read_audio_packet(var buffer_2 : plm_buffer_t?; var user : uint64) {
    var self_10 : plm_t? = cast<plm_t?>(0)
    buffer_2
    self_10 = user
    plm_read_packets(self_10, self_10.audio_packet_type)
    return
}
[export]
def plm_read_packets(var self_11 : plm_t?; var requested_type : int) {
    var packet : plm_packet_t? = cast<plm_packet_t?>(0)
    while (true) {
        packet = unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode(self_11.demux))))
        if (packet != null) {
            if (int(packet.type_0) == int(self_11.video_packet_type)) {
                plm_buffer_write(self_11.video_buffer, packet.data, packet.length)
            } elif (int(packet.type_0) == int(self_11.audio_packet_type)) {
                plm_buffer_write(self_11.audio_buffer, packet.data, packet.length)
            }
            if (int(packet.type_0) == int(requested_type)) {
                return
            }
        } else {
            if (uint64(plm_demux_has_ended(self_11.demux)) != uint64(0)) {
                if (self_11.video_buffer != null) {
                    plm_buffer_signal_end(self_11.video_buffer)
                }
                if (self_11.audio_buffer != null) {
                    plm_buffer_signal_end(self_11.audio_buffer)
                }
            }
            return
        }
    }
}
[export]
def plm_buffer_signal_end(var self_12 : plm_buffer_t?) {
    self_12.total_size = unsafe(reinterpret<size_t>(self_12.length))
    return
}
[export]
def plm_demux_has_ended(var self_13 : plm_demux_t?) : int {
    return plm_buffer_has_ended(self_13.buffer)
}
[export]
def plm_buffer_has_ended(var self_14 : plm_buffer_t?) : int {
    return self_14.has_ended
}
[export]
def plm_buffer_write(var self_15 : plm_buffer_t?; var bytes_2 : uint8?; var length_1 : size_t) : size_t {
    var bytes_available : size_t = unsafe(reinterpret<size_t>(0))
    var new_size : size_t = unsafe(reinterpret<size_t>(0))
    if (uint(self_15.mode) == uint(PLM_BUFFER_MODE_FIXED_MEM)) {
        return unsafe(reinterpret<size_t>(0))
    } else {
        if (uint64(self_15.discard_read_bytes) != uint64(0)) {
            plm_buffer_discard_read_bytes(self_15)
            if (uint(self_15.mode) == uint(PLM_BUFFER_MODE_RING)) {
                self_15.total_size = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            }
        }
        bytes_available = unsafe(reinterpret<size_t>(self_15.capacity)) - unsafe(reinterpret<size_t>(self_15.length))
        if (unsafe(reinterpret<size_t>(bytes_available)) < unsafe(reinterpret<size_t>(length_1))) {
            new_size = self_15.capacity
            while (true) {
                new_size = unsafe(reinterpret<size_t>(new_size * unsafe(reinterpret<size_t>(2))))
                if (!unsafe(reinterpret<size_t>(new_size)) - unsafe(reinterpret<size_t>(self_15.length)) < unsafe(reinterpret<size_t>(length_1))) {
                    break
                }
            }
            self_15.bytes = unsafe(unsafe(reinterpret<uint8?>(unsafe(realloc(unsafe(unsafe(reinterpret<uint64>(self_15.bytes))), new_size)))))
            self_15.capacity = unsafe(reinterpret<size_t>(new_size))
        }
        memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(self_15.bytes + unsafe(reinterpret<size_t>(self_15.length)))))), unsafe(unsafe(reinterpret<uint64>(bytes_2))), uint64(length_1))
        self_15.length = unsafe(reinterpret<size_t>(self_15.length + length_1))
        self_15.has_ended = 0
        return length_1
    }
}
[export]
def plm_buffer_discard_read_bytes(var self_16 : plm_buffer_t?) {
    var byte_pos : size_t = unsafe(reinterpret<size_t>(0))
    byte_pos = unsafe(reinterpret<size_t>(self_16.bit_index)) >> unsafe(reinterpret<size_t>(3))
    if (unsafe(reinterpret<size_t>(byte_pos)) == unsafe(reinterpret<size_t>(self_16.length))) {
        self_16.bit_index = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        self_16.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    } elif (unsafe(reinterpret<size_t>(byte_pos)) > unsafe(reinterpret<size_t>(0))) {
        memmove(unsafe(unsafe(reinterpret<uint64>(self_16.bytes))), unsafe(unsafe(reinterpret<uint64>(unsafe(self_16.bytes + unsafe(reinterpret<size_t>(byte_pos)))))), uint64(unsafe(reinterpret<size_t>(self_16.length)) - unsafe(reinterpret<size_t>(byte_pos))))
        self_16.bit_index = unsafe(reinterpret<size_t>(self_16.bit_index - (unsafe(reinterpret<size_t>(byte_pos)) << unsafe(reinterpret<size_t>(3)))))
        self_16.length = unsafe(reinterpret<size_t>(self_16.length - byte_pos))
    }
    return
}
[export]
def plm_demux_decode(var self_17 : plm_demux_t?) : plm_packet_t? {
    var bits_till_next_packet : size_t = unsafe(reinterpret<size_t>(0))
    if (uint64(plm_demux_has_headers(self_17)) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_packet_t?>(null)))
    } else {
        if (uint64(self_17.current_packet.length) != uint64(0)) {
            bits_till_next_packet = unsafe(reinterpret<size_t>(self_17.current_packet.length)) << unsafe(reinterpret<size_t>(3))
            if (uint64(plm_buffer_has(self_17.buffer, bits_till_next_packet)) == uint64(0)) {
                return unsafe(unsafe(reinterpret<plm_packet_t?>(null)))
            } else {
                plm_buffer_skip(self_17.buffer, bits_till_next_packet)
                self_17.current_packet.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            }
        }
        if (uint64(self_17.next_packet.length) != uint64(0)) {
            return unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_get_packet(self_17))))
        } elif (int(self_17.start_code) != -1) {
            return unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode_packet(self_17, self_17.start_code))))
        } else {
            while (true) {
                self_17.start_code = plm_buffer_next_start_code(self_17.buffer)
                if (int(self_17.start_code) == int(PLM_DEMUX_PACKET_VIDEO_1) || int(self_17.start_code) == int(PLM_DEMUX_PACKET_PRIVATE) || int(self_17.start_code) >= int(PLM_DEMUX_PACKET_AUDIO_1) && int(self_17.start_code) <= int(PLM_DEMUX_PACKET_AUDIO_4)) {
                    return unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode_packet(self_17, self_17.start_code))))
                } else {
                    if (int(self_17.start_code) != -1) {
                        continue
                    }
                    return unsafe(unsafe(reinterpret<plm_packet_t?>(null)))
                }
            }
        }
    }
}
[export]
def plm_demux_decode_packet(var self_18 : plm_demux_t?; var type_0 : int) : plm_packet_t? {
    var pts_dts_marker : int = int(0)
    if (uint64(plm_buffer_has(self_18.buffer, unsafe(reinterpret<size_t>(uint(16) << uint(3))))) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_packet_t?>(null)))
    } else {
        self_18.start_code = -1
        self_18.next_packet.type_0 = type_0
        self_18.next_packet.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(plm_buffer_read(self_18.buffer, 16)))))
        self_18.next_packet.length = unsafe(reinterpret<size_t>(self_18.next_packet.length - unsafe(reinterpret<size_t>(plm_buffer_skip_bytes(self_18.buffer, uint8(255))))))
        if (plm_buffer_read(self_18.buffer, 2) == 1) {
            plm_buffer_skip(self_18.buffer, unsafe(reinterpret<size_t>(16)))
            self_18.next_packet.length = unsafe(reinterpret<size_t>(self_18.next_packet.length - unsafe(reinterpret<size_t>(2))))
        }
        pts_dts_marker = plm_buffer_read(self_18.buffer, 2)
        if (int(pts_dts_marker) == 3) {
            self_18.next_packet.pts = plm_demux_decode_time(self_18)
            self_18.last_decoded_pts = self_18.next_packet.pts
            plm_buffer_skip(self_18.buffer, unsafe(reinterpret<size_t>(40)))
            self_18.next_packet.length = unsafe(reinterpret<size_t>(self_18.next_packet.length - unsafe(reinterpret<size_t>(10))))
        } elif (int(pts_dts_marker) == 2) {
            self_18.next_packet.pts = plm_demux_decode_time(self_18)
            self_18.last_decoded_pts = self_18.next_packet.pts
            self_18.next_packet.length = unsafe(reinterpret<size_t>(self_18.next_packet.length - unsafe(reinterpret<size_t>(5))))
        } elif (uint64(int(pts_dts_marker)) == uint64(0)) {
            self_18.next_packet.pts = double(-1)
            plm_buffer_skip(self_18.buffer, unsafe(reinterpret<size_t>(4)))
            self_18.next_packet.length = unsafe(reinterpret<size_t>(self_18.next_packet.length - unsafe(reinterpret<size_t>(1))))
        } else {
            return unsafe(unsafe(reinterpret<plm_packet_t?>(null)))
        }
        return unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_get_packet(self_18))))
    }
}
[export]
def plm_demux_get_packet(var self_19 : plm_demux_t?) : plm_packet_t? {
    if (uint64(plm_buffer_has(self_19.buffer, unsafe(reinterpret<size_t>(self_19.next_packet.length)) << unsafe(reinterpret<size_t>(3)))) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_packet_t?>(null)))
    } else {
        self_19.current_packet.data = unsafe(unsafe(reinterpret<uint8?>(unsafe(self_19.buffer.bytes + (unsafe(reinterpret<size_t>(self_19.buffer.bit_index)) >> unsafe(reinterpret<size_t>(3)))))))
        self_19.current_packet.length = unsafe(reinterpret<size_t>(self_19.next_packet.length))
        self_19.current_packet.type_0 = self_19.next_packet.type_0
        self_19.current_packet.pts = self_19.next_packet.pts
        self_19.next_packet.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        return unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(addr(self_19.current_packet)))))
    }
}
[export]
def plm_demux_decode_time(var self_20 : plm_demux_t?) : double {
    var clock : int64 = int64(0)
    clock = int64(uint(plm_buffer_read(self_20.buffer, 3)) << uint(30))
    plm_buffer_skip(self_20.buffer, unsafe(reinterpret<size_t>(1)))
    clock = int64(clock | int64(uint(plm_buffer_read(self_20.buffer, 15)) << uint(15)))
    plm_buffer_skip(self_20.buffer, unsafe(reinterpret<size_t>(1)))
    clock = int64(clock | int64(plm_buffer_read(self_20.buffer, 15)))
    plm_buffer_skip(self_20.buffer, unsafe(reinterpret<size_t>(1)))
    return double(clock) / double(90000.0)
}
var PLM_DEMUX_PACKET_AUDIO_4 : int const = int(195)

var PLM_DEMUX_PACKET_AUDIO_1 : int const = int(192)

var PLM_DEMUX_PACKET_PRIVATE : int const = int(189)

var PLM_DEMUX_PACKET_VIDEO_1 : int const = int(224)

[export]
def plm_buffer_next_start_code(var self_21 : plm_buffer_t?) : int {
    var byte_index : size_t = unsafe(reinterpret<size_t>(0))
    plm_buffer_align(self_21)
    while (true) {
        if (uint64(plm_buffer_has(self_21, unsafe(reinterpret<size_t>(uint(5) << uint(3))))) != uint64(0)) {
            byte_index = unsafe(reinterpret<size_t>(self_21.bit_index)) >> unsafe(reinterpret<size_t>(3))
            if (uint64(int(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_21.bytes)))[uint(byte_index)]))) == uint64(0) && uint64(int(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_21.bytes)))[uint(unsafe(reinterpret<size_t>(byte_index)) + unsafe(reinterpret<size_t>(1)))]))) == uint64(0) && int(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_21.bytes)))[uint(unsafe(reinterpret<size_t>(byte_index)) + unsafe(reinterpret<size_t>(2)))])) == 1) {
                self_21.bit_index = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(byte_index)) + unsafe(reinterpret<size_t>(4)) << unsafe(reinterpret<size_t>(3))))
                return int(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_21.bytes)))[uint(unsafe(reinterpret<size_t>(byte_index)) + unsafe(reinterpret<size_t>(3)))]))
            } else {
                self_21.bit_index = unsafe(reinterpret<size_t>(self_21.bit_index + unsafe(reinterpret<size_t>(8))))
            }
        } else {
            return -1
        }
    }
}
[export]
def plm_demux_has_headers(var self_22 : plm_demux_t?) : int {
    if (uint64(self_22.has_headers) != uint64(0)) {
        return 1
    } else {
        if (uint64(self_22.has_pack_header) == uint64(0)) {
            if (int(self_22.start_code) != int(PLM_START_PACK) && plm_buffer_find_start_code(self_22.buffer, PLM_START_PACK) == -1) {
                return 0
            } else {
                self_22.start_code = PLM_START_PACK
                if (uint64(plm_buffer_has(self_22.buffer, unsafe(reinterpret<size_t>(64)))) == uint64(0)) {
                    return 0
                } else {
                    self_22.start_code = -1
                    if (plm_buffer_read(self_22.buffer, 4) != 2) {
                        return 0
                    } else {
                        self_22.system_clock_ref = plm_demux_decode_time(self_22)
                        plm_buffer_skip(self_22.buffer, unsafe(reinterpret<size_t>(1)))
                        plm_buffer_skip(self_22.buffer, unsafe(reinterpret<size_t>(22)))
                        plm_buffer_skip(self_22.buffer, unsafe(reinterpret<size_t>(1)))
                        self_22.has_pack_header = 1
                    }
                }
            }
        }
        if (uint64(self_22.has_system_header) == uint64(0)) {
            if (int(self_22.start_code) != int(PLM_START_SYSTEM) && plm_buffer_find_start_code(self_22.buffer, PLM_START_SYSTEM) == -1) {
                return 0
            } else {
                self_22.start_code = PLM_START_SYSTEM
                if (uint64(plm_buffer_has(self_22.buffer, unsafe(reinterpret<size_t>(56)))) == uint64(0)) {
                    return 0
                } else {
                    self_22.start_code = -1
                    plm_buffer_skip(self_22.buffer, unsafe(reinterpret<size_t>(16)))
                    plm_buffer_skip(self_22.buffer, unsafe(reinterpret<size_t>(24)))
                    self_22.num_audio_streams = plm_buffer_read(self_22.buffer, 6)
                    plm_buffer_skip(self_22.buffer, unsafe(reinterpret<size_t>(5)))
                    self_22.num_video_streams = plm_buffer_read(self_22.buffer, 5)
                    self_22.has_system_header = 1
                }
            }
        }
        self_22.has_headers = 1
        return 1
    }
}
var PLM_START_SYSTEM : int const = int(187)

[export]
def plm_buffer_find_start_code(var self_23 : plm_buffer_t?; var code : int) : int {
    var current : int = int(0)
    current = 0
    while (true) {
        if (uint64(1) != uint64(0)) {
            current = plm_buffer_next_start_code(self_23)
            if (int(current) == int(code) || int(current) == -1) {
                return current
            }
        } else {
            return -1
        }
    }
}
var PLM_START_PACK : int const = int(186)

[export]
def plm_buffer_set_load_callback(var self_24 : plm_buffer_t?; var fp : plm_buffer_load_callback; var user_0 : uint64) {
    self_24.load_callback = fp
    self_24.load_callback_user_data = user_0
    return
}
[export]
def plm_buffer_create_with_capacity(var capacity : size_t) : plm_buffer_t? {
    var self_25 : plm_buffer_t? = cast<plm_buffer_t?>(0)
    self_25 = unsafe(malloc(4))
    memset(unsafe(unsafe(reinterpret<uint64>(self_25))), 0, uint64(4))
    self_25.capacity = unsafe(reinterpret<size_t>(capacity))
    self_25.free_when_done = 1
    self_25.bytes = unsafe(unsafe(reinterpret<uint8?>(unsafe(malloc(capacity)))))
    self_25.mode = unsafe(reinterpret<plm_buffer_mode>(PLM_BUFFER_MODE_RING))
    self_25.discard_read_bytes = 1
    return unsafe(unsafe(reinterpret<plm_buffer_t?>(self_25)))
}
[export]
def plm_demux_get_num_audio_streams(var self_26 : plm_demux_t?) : int {
    var c2da_fresh5 : int = int(0)
    if (uint64(plm_demux_has_headers(self_26)) != uint64(0)) {
        c2da_fresh5 = self_26.num_audio_streams
    } else {
        c2da_fresh5 = 0
    }
    return c2da_fresh5
}
[export]
def plm_video_create_with_buffer(var buffer_3 : plm_buffer_t?; var destroy_when_done_1 : int) : plm_video_t? {
    var self_27 : plm_video_t? = cast<plm_video_t?>(0)
    self_27 = unsafe(malloc(4))
    memset(unsafe(unsafe(reinterpret<uint64>(self_27))), 0, uint64(4))
    self_27.buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(buffer_3)))
    self_27.destroy_buffer_when_done = destroy_when_done_1
    self_27.start_code = plm_buffer_find_start_code(self_27.buffer, PLM_START_SEQUENCE)
    if (int(self_27.start_code) != -1) {
        plm_video_decode_sequence_header(self_27)
    }
    return unsafe(unsafe(reinterpret<plm_video_t?>(self_27)))
}
[export]
def plm_video_decode_sequence_header(var self_28 : plm_video_t?) : int {
    var max_header_size : int = int(0)
    var pixel_aspect_ratio_code : int = int(0)
    var par_last : int = int(0)
    var i_6 : int = int(0)
    var idx : int = int(0)
    var i_7 : int = int(0)
    var idx_0 : int = int(0)
    var luma_plane_size : size_t = unsafe(reinterpret<size_t>(0))
    var chroma_plane_size : size_t = unsafe(reinterpret<size_t>(0))
    var frame_data_size : size_t = unsafe(reinterpret<size_t>(0))
    max_header_size = 64 + 2 * 64 * 8
    if (uint64(plm_buffer_has(self_28.buffer, unsafe(reinterpret<size_t>(max_header_size)))) == uint64(0)) {
        return 0
    } else {
        self_28.width = plm_buffer_read(self_28.buffer, 12)
        self_28.height = plm_buffer_read(self_28.buffer, 12)
        if (int(self_28.width) <= 0 || int(self_28.height) <= 0) {
            return 0
        } else {
            pixel_aspect_ratio_code = plm_buffer_read(self_28.buffer, 4)
            pixel_aspect_ratio_code = pixel_aspect_ratio_code - 1
            if (int(pixel_aspect_ratio_code) < 0) {
                pixel_aspect_ratio_code = 0
            }
            par_last = int(4 / 4 - int(int(uint64(1))))
            if (int(pixel_aspect_ratio_code) > int(par_last)) {
                pixel_aspect_ratio_code = par_last
            }
            self_28.pixel_aspect_ratio = double(unsafe(unsafe(addr(PLM_VIDEO_PIXEL_ASPECT_RATIO[0]))[uint(pixel_aspect_ratio_code)]))
            self_28.framerate = unsafe(unsafe(addr(PLM_VIDEO_PICTURE_RATE[0]))[uint(plm_buffer_read(self_28.buffer, 4))])
            plm_buffer_skip(self_28.buffer, unsafe(reinterpret<size_t>(18 + 1 + 10 + 1)))
            if (uint64(plm_buffer_read(self_28.buffer, 1)) != uint64(0)) {
                break
            } else {
                memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_28.intra_quant_matrix[0]))))), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(PLM_VIDEO_INTRA_QUANT_MATRIX[0]))))), uint64(uint64(64)))
                if (uint64(plm_buffer_read(self_28.buffer, 1)) != uint64(0)) {
                    break
                } else {
                    memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_28.non_intra_quant_matrix[0]))))), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(PLM_VIDEO_NON_INTRA_QUANT_MATRIX[0]))))), uint64(uint64(64)))
                    self_28.mb_width = uint(int(self_28.width) + 15) >> uint(4)
                    self_28.mb_height = uint(int(self_28.height) + 15) >> uint(4)
                    self_28.mb_size = int(self_28.mb_width) * int(self_28.mb_height)
                    self_28.luma_width = uint(int(self_28.mb_width)) << uint(4)
                    self_28.luma_height = uint(int(self_28.mb_height)) << uint(4)
                    self_28.chroma_width = uint(int(self_28.mb_width)) << uint(3)
                    self_28.chroma_height = uint(int(self_28.mb_height)) << uint(3)
                    luma_plane_size = unsafe(reinterpret<size_t>(int(self_28.luma_width) * int(self_28.luma_height)))
                    chroma_plane_size = unsafe(reinterpret<size_t>(int(self_28.chroma_width) * int(self_28.chroma_height)))
                    frame_data_size = unsafe(reinterpret<size_t>(luma_plane_size)) + unsafe(reinterpret<size_t>(2)) * unsafe(reinterpret<size_t>(chroma_plane_size))
                    self_28.frames_data = unsafe(unsafe(reinterpret<uint8?>(unsafe(malloc(unsafe(reinterpret<size_t>(frame_data_size)) * unsafe(reinterpret<size_t>(3)))))))
                    plm_video_init_frame(self_28, unsafe(addr(self_28.frame_current)), unsafe(self_28.frames_data + unsafe(reinterpret<size_t>(frame_data_size)) * unsafe(reinterpret<size_t>(0))))
                    plm_video_init_frame(self_28, unsafe(addr(self_28.frame_forward)), unsafe(self_28.frames_data + unsafe(reinterpret<size_t>(frame_data_size)) * unsafe(reinterpret<size_t>(1))))
                    plm_video_init_frame(self_28, unsafe(addr(self_28.frame_backward)), unsafe(self_28.frames_data + unsafe(reinterpret<size_t>(frame_data_size)) * unsafe(reinterpret<size_t>(2))))
                    self_28.has_sequence_header = 1
                    return 1
                }
            }
        }
    }
}
[export]
def plm_video_init_frame(var self_29 : plm_video_t?; var frame : plm_frame_t?; var base : uint8?) {
    var luma_plane_size_0 : size_t = unsafe(reinterpret<size_t>(0))
    var chroma_plane_size_0 : size_t = unsafe(reinterpret<size_t>(0))
    luma_plane_size_0 = unsafe(reinterpret<size_t>(int(self_29.luma_width) * int(self_29.luma_height)))
    chroma_plane_size_0 = unsafe(reinterpret<size_t>(int(self_29.chroma_width) * int(self_29.chroma_height)))
    frame.width = uint(uint(self_29.width))
    frame.height = uint(uint(self_29.height))
    frame.y.width = uint(uint(self_29.luma_width))
    frame.y.height = uint(uint(self_29.luma_height))
    frame.y.data = unsafe(unsafe(reinterpret<uint8?>(base)))
    frame.cr.width = uint(uint(self_29.chroma_width))
    frame.cr.height = uint(uint(self_29.chroma_height))
    frame.cr.data = unsafe(unsafe(reinterpret<uint8?>(unsafe(base + unsafe(reinterpret<size_t>(luma_plane_size_0))))))
    frame.cb.width = uint(uint(self_29.chroma_width))
    frame.cb.height = uint(uint(self_29.chroma_height))
    frame.cb.data = unsafe(unsafe(reinterpret<uint8?>(unsafe(base + (unsafe(reinterpret<size_t>(luma_plane_size_0)) + unsafe(reinterpret<size_t>(chroma_plane_size_0)))))))
    return
}
var PLM_VIDEO_NON_INTRA_QUANT_MATRIX : array<uint8> const = [uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16)]

var PLM_VIDEO_ZIG_ZAG : array<uint8> const = [uint8(0), uint8(1), uint8(8), uint8(16), uint8(9), uint8(2), uint8(3), uint8(10), uint8(17), uint8(24), uint8(32), uint8(25), uint8(18), uint8(11), uint8(4), uint8(5), uint8(12), uint8(19), uint8(26), uint8(33), uint8(40), uint8(48), uint8(41), uint8(34), uint8(27), uint8(20), uint8(13), uint8(6), uint8(7), uint8(14), uint8(21), uint8(28), uint8(35), uint8(42), uint8(49), uint8(56), uint8(57), uint8(50), uint8(43), uint8(36), uint8(29), uint8(22), uint8(15), uint8(23), uint8(30), uint8(37), uint8(44), uint8(51), uint8(58), uint8(59), uint8(52), uint8(45), uint8(38), uint8(31), uint8(39), uint8(46), uint8(53), uint8(60), uint8(61), uint8(54), uint8(47), uint8(55), uint8(62), uint8(63)]

var PLM_VIDEO_INTRA_QUANT_MATRIX : array<uint8> const = [uint8(8), uint8(16), uint8(19), uint8(22), uint8(26), uint8(27), uint8(29), uint8(34), uint8(16), uint8(16), uint8(22), uint8(24), uint8(27), uint8(29), uint8(34), uint8(37), uint8(19), uint8(22), uint8(26), uint8(27), uint8(29), uint8(34), uint8(34), uint8(38), uint8(22), uint8(22), uint8(26), uint8(27), uint8(29), uint8(34), uint8(37), uint8(40), uint8(22), uint8(26), uint8(27), uint8(29), uint8(32), uint8(35), uint8(40), uint8(48), uint8(26), uint8(27), uint8(29), uint8(32), uint8(35), uint8(40), uint8(48), uint8(58), uint8(26), uint8(27), uint8(29), uint8(34), uint8(38), uint8(46), uint8(56), uint8(69), uint8(27), uint8(29), uint8(35), uint8(38), uint8(46), uint8(56), uint8(69), uint8(83)]

var PLM_VIDEO_PICTURE_RATE : array<double> const = [double(0.0), double(23.976), double(24.0), double(25.0), double(29.97), double(30.0), double(50.0), double(59.94), double(60.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0)]

var PLM_VIDEO_PIXEL_ASPECT_RATIO : array<float> const = [float(double(1.0)), float(double(0.6735)), float(double(0.7031)), float(double(0.7615)), float(double(0.8055)), float(double(0.8437)), float(double(0.8935)), float(double(0.9157)), float(double(0.9815)), float(double(1.0255)), float(double(1.0695)), float(double(1.095)), float(double(1.1575)), float(double(1.2051))]

var PLM_START_SEQUENCE : int const = int(179)

[export]
def plm_read_video_packet(var buffer_4 : plm_buffer_t?; var user_1 : uint64) {
    var self_30 : plm_t? = cast<plm_t?>(0)
    buffer_4
    self_30 = user_1
    plm_read_packets(self_30, self_30.video_packet_type)
    return
}
[export]
def plm_demux_get_num_video_streams(var self_31 : plm_demux_t?) : int {
    var c2da_fresh6 : int = int(0)
    if (uint64(plm_demux_has_headers(self_31)) != uint64(0)) {
        c2da_fresh6 = self_31.num_video_streams
    } else {
        c2da_fresh6 = 0
    }
    return c2da_fresh6
}
[export]
def plm_demux_create(var buffer_5 : plm_buffer_t?; var destroy_when_done_2 : int) : plm_demux_t? {
    var self_32 : plm_demux_t? = cast<plm_demux_t?>(0)
    self_32 = unsafe(malloc(4))
    memset(unsafe(unsafe(reinterpret<uint64>(self_32))), 0, uint64(4))
    self_32.buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(buffer_5)))
    self_32.destroy_buffer_when_done = destroy_when_done_2
    self_32.start_time = double(-1)
    self_32.duration = double(-1)
    self_32.start_code = -1
    plm_demux_has_headers(self_32)
    return unsafe(unsafe(reinterpret<plm_demux_t?>(self_32)))
}
[export]
def plm_destroy(var self_33 : plm_t?) {
    if (self_33.video_decoder != null) {
        plm_video_destroy(self_33.video_decoder)
    }
    if (self_33.audio_decoder != null) {
        plm_audio_destroy(self_33.audio_decoder)
    }
    plm_demux_destroy(self_33.demux)
    unsafe(free(unsafe(unsafe(reinterpret<uint64>(self_33)))))
    return
}
[export]
def plm_demux_destroy(var self_34 : plm_demux_t?) {
    if (uint64(self_34.destroy_buffer_when_done) != uint64(0)) {
        plm_buffer_destroy(self_34.buffer)
    }
    unsafe(free(unsafe(unsafe(reinterpret<uint64>(self_34)))))
    return
}
[export]
def plm_buffer_destroy(var self_35 : plm_buffer_t?) {
    if (uint64(self_35.free_when_done) != uint64(0)) {
        unsafe(free(unsafe(unsafe(reinterpret<uint64>(self_35.bytes)))))
    }
    unsafe(free(unsafe(unsafe(reinterpret<uint64>(self_35)))))
    return
}
[export]
def plm_audio_destroy(var self_36 : plm_audio_t?) {
    if (uint64(self_36.destroy_buffer_when_done) != uint64(0)) {
        plm_buffer_destroy(self_36.buffer)
    }
    unsafe(free(unsafe(unsafe(reinterpret<uint64>(self_36)))))
    return
}
[export]
def plm_video_destroy(var self_37 : plm_video_t?) {
    if (uint64(self_37.destroy_buffer_when_done) != uint64(0)) {
        plm_buffer_destroy(self_37.buffer)
    }
    if (uint64(self_37.has_sequence_header) != uint64(0)) {
        unsafe(free(unsafe(unsafe(reinterpret<uint64>(self_37.frames_data)))))
    }
    unsafe(free(unsafe(unsafe(reinterpret<uint64>(self_37)))))
    return
}
[export]
def plm_has_headers(var self_38 : plm_t?) : int {
    if (uint64(plm_demux_has_headers(self_38.demux)) == uint64(0)) {
        return 0
    } elif (uint64(plm_init_decoders(self_38)) == uint64(0)) {
        return 0
    } elif (self_38.video_decoder != null && uint64(plm_video_has_header(self_38.video_decoder)) == uint64(0) || self_38.audio_decoder != null && uint64(plm_audio_has_header(self_38.audio_decoder)) == uint64(0)) {
        return 0
    } else {
        return 1
    }
}
[export]
def plm_audio_has_header(var self_39 : plm_audio_t?) : int {
    if (uint64(self_39.has_header) != uint64(0)) {
        return 1
    } else {
        self_39.next_frame_data_size = plm_audio_decode_header(self_39)
        return self_39.has_header
    }
}
[export]
def plm_video_has_header(var self_40 : plm_video_t?) : int {
    if (uint64(self_40.has_sequence_header) != uint64(0)) {
        return 1
    } else {
        if (int(self_40.start_code) != int(PLM_START_SEQUENCE)) {
            self_40.start_code = plm_buffer_find_start_code(self_40.buffer, PLM_START_SEQUENCE)
        }
        if (int(self_40.start_code) == -1) {
            return 0
        } elif (uint64(plm_video_decode_sequence_header(self_40)) == uint64(0)) {
            return 0
        } else {
            return 1
        }
    }
}
[export]
def plm_probe(var self_41 : plm_t?; var probesize : size_t) : int {
    var found_streams : int = int(0)
    found_streams = plm_demux_probe(self_41.demux, probesize)
    if (uint64(found_streams) == uint64(0)) {
        return 0
    } else {
        self_41.has_decoders = 0
        self_41.video_packet_type = 0
        self_41.audio_packet_type = 0
        return plm_init_decoders(self_41)
    }
}
[export]
def plm_demux_probe(var self_42 : plm_demux_t?; var probesize_0 : size_t) : int {
    var previous_pos : int = int(0)
    var video_stream : int = int(0)
    var audio_streams : array<int> = cast<array<int>>(0)
    previous_pos = int(plm_buffer_tell(self_42.buffer))
    video_stream = 0
    audio_streams = [int(0), int(0), int(0), int(0)]
    while (true) {
        self_42.start_code = plm_buffer_next_start_code(self_42.buffer)
        if (int(self_42.start_code) == int(PLM_DEMUX_PACKET_VIDEO_1)) {
            video_stream = 1
        } elif (int(self_42.start_code) >= int(PLM_DEMUX_PACKET_AUDIO_1) && int(self_42.start_code) <= int(PLM_DEMUX_PACKET_AUDIO_4)) {
            unsafe(unsafe(addr(audio_streams[0]))[int(self_42.start_code) - int(PLM_DEMUX_PACKET_AUDIO_1)]) = 1
        }
        if (!int(self_42.start_code) != -1 && plm_buffer_tell(self_42.buffer) - unsafe(reinterpret<size_t>(previous_pos)) < unsafe(reinterpret<size_t>(probesize_0))) {
            break
        }
    }
    var c2da_fresh7 : int = int(0)
    if (uint64(video_stream) != uint64(0)) {
        c2da_fresh7 = 1
    } else {
        c2da_fresh7 = 0
    }
    self_42.num_video_streams = c2da_fresh7
    self_42.num_audio_streams = 0
    break
}
[export]
def plm_buffer_tell(var self_43 : plm_buffer_t?) : size_t {
    var c2da_fresh8 : size_t = unsafe(reinterpret<size_t>(0))
    if (uint64(self_43.tell_callback) != uint64(0)) {
        c2da_fresh8 = self_43.tell_callback(self_43, self_43.load_callback_user_data) + (unsafe(reinterpret<size_t>(self_43.bit_index)) >> unsafe(reinterpret<size_t>(3))) - unsafe(reinterpret<size_t>(self_43.length))
    } else {
        c2da_fresh8 = unsafe(reinterpret<size_t>(self_43.bit_index)) >> unsafe(reinterpret<size_t>(3))
    }
    return c2da_fresh8
}
[export]
def plm_demux_buffer_seek(var self_44 : plm_demux_t?; var pos : size_t) {
    plm_buffer_seek(self_44.buffer, pos)
    self_44.current_packet.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    self_44.next_packet.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    self_44.start_code = -1
    return
}
[export]
def plm_buffer_seek(var self_45 : plm_buffer_t?; var pos_0 : size_t) {
    self_45.has_ended = 0
    if (self_45.seek_callback != null) {
        self_45.seek_callback(self_45, pos_0, self_45.load_callback_user_data)
        self_45.bit_index = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        self_45.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    } elif (uint(self_45.mode) == uint(PLM_BUFFER_MODE_RING)) {
        if (uint64(unsafe(reinterpret<size_t>(pos_0))) != uint64(0)) {
            return
        } else {
            self_45.bit_index = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            self_45.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
            self_45.total_size = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
        }
    } elif (unsafe(reinterpret<size_t>(pos_0)) < unsafe(reinterpret<size_t>(self_45.length))) {
        self_45.bit_index = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(pos_0)) << unsafe(reinterpret<size_t>(3))))
    }
    return
}
[export]
def plm_get_video_enabled(var self_46 : plm_t?) : int {
    return self_46.video_enabled
}
[export]
def plm_set_video_enabled(var self_47 : plm_t?; var enabled : int) {
    self_47.video_enabled = enabled
    if (uint64(enabled) == uint64(0)) {
        self_47.video_packet_type = 0
        return
    } else {
        var c2da_fresh9 : int = int(0)
        if (uint64(plm_init_decoders(self_47)) != uint64(0) && self_47.video_decoder != null) {
            c2da_fresh9 = PLM_DEMUX_PACKET_VIDEO_1
        } else {
            c2da_fresh9 = 0
        }
        self_47.video_packet_type = c2da_fresh9
        return
    }
}
[export]
def plm_get_num_video_streams(var self_48 : plm_t?) : int {
    return plm_demux_get_num_video_streams(self_48.demux)
}
[export]
def plm_get_width(var self_49 : plm_t?) : int {
    var c2da_fresh10 : int = int(0)
    if (uint64(plm_init_decoders(self_49)) != uint64(0) && self_49.video_decoder != null) {
        c2da_fresh10 = plm_video_get_width(self_49.video_decoder)
    } else {
        c2da_fresh10 = 0
    }
    return c2da_fresh10
}
[export]
def plm_video_get_width(var self_50 : plm_video_t?) : int {
    var c2da_fresh11 : int = int(0)
    if (uint64(plm_video_has_header(self_50)) != uint64(0)) {
        c2da_fresh11 = self_50.width
    } else {
        c2da_fresh11 = 0
    }
    return c2da_fresh11
}
[export]
def plm_get_height(var self_51 : plm_t?) : int {
    var c2da_fresh12 : int = int(0)
    if (uint64(plm_init_decoders(self_51)) != uint64(0) && self_51.video_decoder != null) {
        c2da_fresh12 = plm_video_get_height(self_51.video_decoder)
    } else {
        c2da_fresh12 = 0
    }
    return c2da_fresh12
}
[export]
def plm_video_get_height(var self_52 : plm_video_t?) : int {
    var c2da_fresh13 : int = int(0)
    if (uint64(plm_video_has_header(self_52)) != uint64(0)) {
        c2da_fresh13 = self_52.height
    } else {
        c2da_fresh13 = 0
    }
    return c2da_fresh13
}
[export]
def plm_get_pixel_aspect_ratio(var self_53 : plm_t?) : double {
    var c2da_fresh14 : double = double(0)
    if (uint64(plm_init_decoders(self_53)) != uint64(0) && self_53.video_decoder != null) {
        c2da_fresh14 = plm_video_get_pixel_aspect_ratio(self_53.video_decoder)
    } else {
        c2da_fresh14 = double(0)
    }
    return c2da_fresh14
}
[export]
def plm_video_get_pixel_aspect_ratio(var self_54 : plm_video_t?) : double {
    var c2da_fresh15 : double = double(0)
    if (uint64(plm_video_has_header(self_54)) != uint64(0)) {
        c2da_fresh15 = self_54.pixel_aspect_ratio
    } else {
        c2da_fresh15 = double(0)
    }
    return c2da_fresh15
}
[export]
def plm_get_framerate(var self_55 : plm_t?) : double {
    var c2da_fresh16 : double = double(0)
    if (uint64(plm_init_decoders(self_55)) != uint64(0) && self_55.video_decoder != null) {
        c2da_fresh16 = plm_video_get_framerate(self_55.video_decoder)
    } else {
        c2da_fresh16 = double(0)
    }
    return c2da_fresh16
}
[export]
def plm_video_get_framerate(var self_56 : plm_video_t?) : double {
    var c2da_fresh17 : double = double(0)
    if (uint64(plm_video_has_header(self_56)) != uint64(0)) {
        c2da_fresh17 = self_56.framerate
    } else {
        c2da_fresh17 = double(0)
    }
    return c2da_fresh17
}
[export]
def plm_get_audio_enabled(var self_57 : plm_t?) : int {
    return self_57.audio_enabled
}
[export]
def plm_set_audio_enabled(var self_58 : plm_t?; var enabled_0 : int) {
    self_58.audio_enabled = enabled_0
    if (uint64(enabled_0) == uint64(0)) {
        self_58.audio_packet_type = 0
        return
    } else {
        var c2da_fresh18 : int = int(0)
        if (uint64(plm_init_decoders(self_58)) != uint64(0) && self_58.audio_decoder != null) {
            c2da_fresh18 = int(PLM_DEMUX_PACKET_AUDIO_1) + int(self_58.audio_stream_index)
        } else {
            c2da_fresh18 = 0
        }
        self_58.audio_packet_type = c2da_fresh18
        return
    }
}
[export]
def plm_get_num_audio_streams(var self_59 : plm_t?) : int {
    return plm_demux_get_num_audio_streams(self_59.demux)
}
[export]
def plm_set_audio_stream(var self_60 : plm_t?; var stream_index : int) {
    if (int(stream_index) < 0 || int(stream_index) > 3) {
        return
    } else {
        self_60.audio_stream_index = stream_index
        plm_set_audio_enabled(self_60, self_60.audio_enabled)
        return
    }
}
[export]
def plm_get_samplerate(var self_61 : plm_t?) : int {
    var c2da_fresh19 : int = int(0)
    if (uint64(plm_init_decoders(self_61)) != uint64(0) && self_61.audio_decoder != null) {
        c2da_fresh19 = plm_audio_get_samplerate(self_61.audio_decoder)
    } else {
        c2da_fresh19 = 0
    }
    return c2da_fresh19
}
[export]
def plm_audio_get_samplerate(var self_62 : plm_audio_t?) : int {
    var c2da_fresh20 : int = int(0)
    if (uint64(plm_audio_has_header(self_62)) != uint64(0)) {
        c2da_fresh20 = unsafe(unsafe(addr(PLM_AUDIO_SAMPLE_RATE[0]))[uint(self_62.samplerate_index)])
    } else {
        c2da_fresh20 = 0
    }
    return c2da_fresh20
}
[export]
def plm_get_audio_lead_time(var self_63 : plm_t?) : double {
    return self_63.audio_lead_time
}
[export]
def plm_set_audio_lead_time(var self_64 : plm_t?; var lead_time : double) {
    self_64.audio_lead_time = lead_time
    return
}
[export]
def plm_get_time(var self_65 : plm_t?) : double {
    return self_65.time
}
[export]
def plm_get_duration(var self_66 : plm_t?) : double {
    return plm_demux_get_duration(self_66.demux, PLM_DEMUX_PACKET_VIDEO_1)
}
[export]
def plm_demux_get_duration(var self_67 : plm_demux_t?; var type_1 : int) : double {
    var file_size : size_t = unsafe(reinterpret<size_t>(0))
    var previous_pos_0 : size_t = unsafe(reinterpret<size_t>(0))
    var previous_start_code : int = int(0)
    var start_range : int64 = int64(0)
    var max_range : int64 = int64(0)
    file_size = plm_buffer_get_size(self_67.buffer)
    if (double(self_67.duration) != double(-1) && unsafe(reinterpret<size_t>(self_67.last_file_size)) == unsafe(reinterpret<size_t>(file_size))) {
        return self_67.duration
    } else {
        previous_pos_0 = plm_buffer_tell(self_67.buffer)
        previous_start_code = self_67.start_code
        start_range = int64(64 * 1024)
        max_range = int64(4096 * 1024)
        break
    }
}
[export]
def plm_buffer_get_size(var self_68 : plm_buffer_t?) : size_t {
    var c2da_fresh21 : size_t = unsafe(reinterpret<size_t>(0))
    if (uint(self_68.mode) == uint(PLM_BUFFER_MODE_FILE)) {
        c2da_fresh21 = self_68.total_size
    } else {
        c2da_fresh21 = self_68.length
    }
    return c2da_fresh21
}
[export]
def plm_demux_get_start_time(var self_69 : plm_demux_t?; var type_2 : int) : double {
    var previous_pos_1 : int = int(0)
    var previous_start_code_0 : int = int(0)
    var packet_1 : plm_packet_t? = cast<plm_packet_t?>(0)
    if (double(self_69.start_time) != double(-1)) {
        return self_69.start_time
    } else {
        previous_pos_1 = int(plm_buffer_tell(self_69.buffer))
        previous_start_code_0 = self_69.start_code
        plm_demux_rewind(self_69)
        while (true) {
            packet_1 = plm_demux_decode(self_69)
            if (packet_1 == null) {
                break
                break
            } else {
                if (int(packet_1.type_0) == int(type_2)) {
                    self_69.start_time = packet_1.pts
                }
                if (!double(self_69.start_time) == double(-1)) {
                    break
                }
            }
        }
        plm_demux_buffer_seek(self_69, unsafe(reinterpret<size_t>(previous_pos_1)))
        self_69.start_code = previous_start_code_0
        return self_69.start_time
    }
}
[export]
def plm_demux_rewind(var self_70 : plm_demux_t?) {
    plm_buffer_rewind(self_70.buffer)
    self_70.current_packet.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    self_70.next_packet.length = unsafe(reinterpret<size_t>(unsafe(reinterpret<size_t>(0))))
    self_70.start_code = -1
    return
}
[export]
def plm_buffer_rewind(var self_71 : plm_buffer_t?) {
    plm_buffer_seek(self_71, unsafe(reinterpret<size_t>(0)))
    return
}
[export]
def plm_rewind(var self_72 : plm_t?) {
    if (self_72.video_decoder != null) {
        plm_video_rewind(self_72.video_decoder)
    }
    if (self_72.audio_decoder != null) {
        plm_audio_rewind(self_72.audio_decoder)
    }
    plm_demux_rewind(self_72.demux)
    self_72.time = double(0)
    self_72.has_ended = 0
    return
}
[export]
def plm_audio_rewind(var self_73 : plm_audio_t?) {
    plm_buffer_rewind(self_73.buffer)
    self_73.time = double(0)
    self_73.samples_decoded = 0
    self_73.next_frame_data_size = 0
    return
}
[export]
def plm_video_rewind(var self_74 : plm_video_t?) {
    plm_buffer_rewind(self_74.buffer)
    self_74.time = double(0)
    self_74.frames_decoded = 0
    self_74.has_reference_frame = 0
    self_74.start_code = -1
    return
}
[export]
def plm_get_loop(var self_75 : plm_t?) : int {
    return self_75.loop
}
[export]
def plm_set_loop(var self_76 : plm_t?; var loop : int) {
    self_76.loop = loop
    return
}
[export]
def plm_has_ended(var self_77 : plm_t?) : int {
    return self_77.has_ended
}
[export]
def plm_set_video_decode_callback(var self_78 : plm_t?; var fp_0 : plm_video_decode_callback; var user_2 : uint64) {
    self_78.video_decode_callback = fp_0
    self_78.video_decode_callback_user_data = user_2
    return
}
[export]
def plm_set_audio_decode_callback(var self_79 : plm_t?; var fp_1 : plm_audio_decode_callback; var user_3 : uint64) {
    self_79.audio_decode_callback = fp_1
    self_79.audio_decode_callback_user_data = user_3
    return
}
[export]
def plm_decode(var self_80 : plm_t?; var tick : double) {
    var decode_video : int = int(0)
    var decode_audio : int = int(0)
    var did_decode : int = int(0)
    var decode_video_failed : int = int(0)
    var decode_audio_failed : int = int(0)
    var video_target_time : double = double(0)
    var audio_target_time : double = double(0)
    var frame_0 : plm_frame_t? = cast<plm_frame_t?>(0)
    var samples : plm_samples_t? = cast<plm_samples_t?>(0)
    if (uint64(plm_init_decoders(self_80)) == uint64(0)) {
        return
    } else {
        decode_video = self_80.video_decode_callback != null && uint64(self_80.video_packet_type) != uint64(0)
        decode_audio = self_80.audio_decode_callback != null && uint64(self_80.audio_packet_type) != uint64(0)
        if (uint64(decode_video) == uint64(0) && uint64(decode_audio) == uint64(0)) {
            return
        } else {
            did_decode = 0
            decode_video_failed = 0
            decode_audio_failed = 0
            video_target_time = double(self_80.time) + double(tick)
            audio_target_time = double(self_80.time) + (double(tick) + double(self_80.audio_lead_time))
            while (true) {
                did_decode = 0
                if (uint64(decode_video) != uint64(0) && plm_video_get_time(self_80.video_decoder) < double(video_target_time)) {
                    frame_0 = plm_video_decode(self_80.video_decoder)
                    if (frame_0 != null) {
                        self_80.video_decode_callback(self_80, frame_0, self_80.video_decode_callback_user_data)
                        did_decode = 1
                    } else {
                        decode_video_failed = 1
                    }
                }
                if (uint64(decode_audio) != uint64(0) && plm_audio_get_time(self_80.audio_decoder) < double(audio_target_time)) {
                    samples = plm_audio_decode(self_80.audio_decoder)
                    if (samples != null) {
                        self_80.audio_decode_callback(self_80, samples, self_80.audio_decode_callback_user_data)
                        did_decode = 1
                    } else {
                        decode_audio_failed = 1
                    }
                }
                if (!uint64(did_decode) != uint64(0)) {
                    break
                }
            }
            if (uint64(decode_video) == uint64(0) || uint64(decode_video_failed) != uint64(0) && uint64(decode_audio) == uint64(0) || uint64(decode_audio_failed) != uint64(0) && uint64(plm_demux_has_ended(self_80.demux)) != uint64(0)) {
                plm_handle_end(self_80)
                return
            } else {
                self_80.time = self_80.time + tick
                return
            }
        }
    }
}
[export]
def plm_handle_end(var self_81 : plm_t?) {
    if (uint64(self_81.loop) != uint64(0)) {
        plm_rewind(self_81)
    } else {
        self_81.has_ended = 1
    }
    return
}
[export]
def plm_audio_decode(var self_82 : plm_audio_t?) : plm_samples_t? {
    if (uint64(self_82.next_frame_data_size) == uint64(0)) {
        if (uint64(plm_buffer_has(self_82.buffer, unsafe(reinterpret<size_t>(48)))) == uint64(0)) {
            return unsafe(unsafe(reinterpret<plm_samples_t?>(null)))
        } else {
            self_82.next_frame_data_size = plm_audio_decode_header(self_82)
        }
    }
    if (uint64(int(self_82.next_frame_data_size)) == uint64(0) || uint64(plm_buffer_has(self_82.buffer, unsafe(reinterpret<size_t>(uint(int(self_82.next_frame_data_size)) << uint(3))))) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_samples_t?>(null)))
    } else {
        plm_audio_decode_frame(self_82)
        self_82.next_frame_data_size = 0
        self_82.samples.time = self_82.time
        self_82.samples_decoded = self_82.samples_decoded + 1152
        self_82.time = double(self_82.samples_decoded) / double(unsafe(unsafe(addr(PLM_AUDIO_SAMPLE_RATE[0]))[uint(self_82.samplerate_index)]))
        return unsafe(unsafe(reinterpret<plm_samples_t?>(unsafe(addr(self_82.samples)))))
    }
}
[export]
def plm_audio_decode_frame(var self_83 : plm_audio_t?) {
    var tab3 : int = int(0)
    var sblimit : int = int(0)
    var tab1 : int = int(0)
    var tab2 : int = int(0)
    tab3 = 0
    sblimit = 0
    var c2da_fresh22 : int = int(0)
    if (int(self_83.mode) == int(PLM_AUDIO_MODE_MONO)) {
        c2da_fresh22 = 0
    } else {
        c2da_fresh22 = 1
    }
    tab1 = c2da_fresh22
    tab2 = int(unsafe(unsafe(addr(unsafe(unsafe(addr(PLM_AUDIO_QUANT_LUT_STEP_1[0]))[uint(tab1)])[0]))[uint(self_83.bitrate_index)]))
    tab3 = int(unsafe(unsafe(addr(unsafe(unsafe(addr(QUANT_LUT_STEP_2[0]))[uint(tab2)])[0]))[uint(self_83.samplerate_index)]))
    sblimit = uint(int(tab3)) & uint(63)
    tab3 = uint(tab3) >> uint(6)
    if (int(self_83.bound) > int(sblimit)) {
        self_83.bound = sblimit
        break
    } else {
        break
    }
}
[export]
def plm_audio_idct36(var s : array<int>?; var ss : int; var d : float?; var dp : int) {
    var t01 : float = float(0)
    var t02 : float = float(0)
    var t03 : float = float(0)
    var t04 : float = float(0)
    var t05 : float = float(0)
    var t06 : float = float(0)
    var t07 : float = float(0)
    var t08 : float = float(0)
    var t09 : float = float(0)
    var t10 : float = float(0)
    var t11 : float = float(0)
    var t12 : float = float(0)
    var t13 : float = float(0)
    var t14 : float = float(0)
    var t15 : float = float(0)
    var t16 : float = float(0)
    var t17 : float = float(0)
    var t18 : float = float(0)
    var t19 : float = float(0)
    var t20 : float = float(0)
    var t21 : float = float(0)
    var t22 : float = float(0)
    var t23 : float = float(0)
    var t24 : float = float(0)
    var t25 : float = float(0)
    var t26 : float = float(0)
    var t27 : float = float(0)
    var t28 : float = float(0)
    var t29 : float = float(0)
    var t30 : float = float(0)
    var t31 : float = float(0)
    var t32 : float = float(0)
    var t33 : float = float(0)
    t01 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[0])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[31])[0]))[uint(ss)]))
    t02 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[0])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[31])[0]))[uint(ss)]))) * double(0.5006030201911926)
    t03 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[1])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[30])[0]))[uint(ss)]))
    t04 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[1])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[30])[0]))[uint(ss)]))) * double(0.5054709315299988)
    t05 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[2])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[29])[0]))[uint(ss)]))
    t06 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[2])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[29])[0]))[uint(ss)]))) * double(0.5154473185539246)
    t07 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[3])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[28])[0]))[uint(ss)]))
    t08 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[3])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[28])[0]))[uint(ss)]))) * double(0.5310425758361816)
    t09 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[4])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[27])[0]))[uint(ss)]))
    t10 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[4])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[27])[0]))[uint(ss)]))) * double(0.5531039237976074)
    t11 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[5])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[26])[0]))[uint(ss)]))
    t12 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[5])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[26])[0]))[uint(ss)]))) * double(0.5829349756240845)
    t13 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[6])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[25])[0]))[uint(ss)]))
    t14 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[6])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[25])[0]))[uint(ss)]))) * double(0.6225041151046753)
    t15 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[7])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[24])[0]))[uint(ss)]))
    t16 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[7])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[24])[0]))[uint(ss)]))) * double(0.6748083233833313)
    t17 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[8])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[23])[0]))[uint(ss)]))
    t18 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[8])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[23])[0]))[uint(ss)]))) * double(0.744536280632019)
    t19 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[9])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[22])[0]))[uint(ss)]))
    t20 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[9])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[22])[0]))[uint(ss)]))) * double(0.839349627494812)
    t21 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[10])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[21])[0]))[uint(ss)]))
    t22 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[10])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[21])[0]))[uint(ss)]))) * double(0.9725682139396667)
    t23 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[11])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[20])[0]))[uint(ss)]))
    t24 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[11])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[20])[0]))[uint(ss)]))) * double(1.1694399118423462)
    t25 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[12])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[19])[0]))[uint(ss)]))
    t26 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[12])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[19])[0]))[uint(ss)]))) * double(1.4841645956039429)
    t27 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[13])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[18])[0]))[uint(ss)]))
    t28 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[13])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[18])[0]))[uint(ss)]))) * double(2.0577809810638428)
    t29 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[14])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[17])[0]))[uint(ss)]))
    t30 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[14])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[17])[0]))[uint(ss)]))) * double(3.4076085090637207)
    t31 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[15])[0]))[uint(ss)]) + unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[16])[0]))[uint(ss)]))
    t32 = float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[15])[0]))[uint(ss)] - unsafe(unsafe(addr(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[16])[0]))[uint(ss)]))) * double(10.190008163452148)
    t33 = float(t01) + float(t31)
    t31 = (float(t01) - float(t31)) * double(0.5024192929267883)
    t01 = float(t03) + float(t29)
    t29 = (float(t03) - float(t29)) * double(0.522498607635498)
    t03 = float(t05) + float(t27)
    t27 = (float(t05) - float(t27)) * double(0.5669440627098083)
    t05 = float(t07) + float(t25)
    t25 = (float(t07) - float(t25)) * double(0.6468217968940735)
    t07 = float(t09) + float(t23)
    t23 = (float(t09) - float(t23)) * double(0.7881546020507813)
    t09 = float(t11) + float(t21)
    t21 = (float(t11) - float(t21)) * double(1.0606776475906372)
    t11 = float(t13) + float(t19)
    t19 = (float(t13) - float(t19)) * double(1.722447156906128)
    t13 = float(t15) + float(t17)
    t17 = (float(t15) - float(t17)) * double(5.10114860534668)
    t15 = float(t33) + float(t13)
    t13 = (float(t33) - float(t13)) * double(0.509795606136322)
    t33 = float(t01) + float(t11)
    t01 = (float(t01) - float(t11)) * double(0.601344883441925)
    t11 = float(t03) + float(t09)
    t09 = (float(t03) - float(t09)) * double(0.8999761939048767)
    t03 = float(t05) + float(t07)
    t07 = (float(t05) - float(t07)) * double(2.562915563583374)
    t05 = float(t15) + float(t03)
    t15 = (float(t15) - float(t03)) * double(0.5411961078643799)
    t03 = float(t33) + float(t11)
    t11 = (float(t33) - float(t11)) * double(1.3065630197525024)
    t33 = float(t05) + float(t03)
    t05 = (float(t05) - float(t03)) * double(0.7071067690849304)
    t03 = float(t15) + float(t11)
    t15 = (float(t15) - float(t11)) * double(0.7071067690849304)
    t03 = t03 + t15
    t11 = float(t13) + float(t07)
    t13 = (float(t13) - float(t07)) * double(0.5411961078643799)
    t07 = float(t01) + float(t09)
    t09 = (float(t01) - float(t09)) * double(1.3065630197525024)
    t01 = float(t11) + float(t07)
    t07 = (float(t11) - float(t07)) * double(0.7071067690849304)
    t11 = float(t13) + float(t09)
    t13 = (float(t13) - float(t09)) * double(0.7071067690849304)
    t11 = t11 + t13
    t01 = t01 + t11
    t11 = t11 + t07
    t07 = t07 + t13
    t09 = float(t31) + float(t17)
    t31 = (float(t31) - float(t17)) * double(0.509795606136322)
    t17 = float(t29) + float(t19)
    t29 = (float(t29) - float(t19)) * double(0.601344883441925)
    t19 = float(t27) + float(t21)
    t21 = (float(t27) - float(t21)) * double(0.8999761939048767)
    t27 = float(t25) + float(t23)
    t23 = (float(t25) - float(t23)) * double(2.562915563583374)
    t25 = float(t09) + float(t27)
    t09 = (float(t09) - float(t27)) * double(0.5411961078643799)
    t27 = float(t17) + float(t19)
    t19 = (float(t17) - float(t19)) * double(1.3065630197525024)
    t17 = float(t25) + float(t27)
    t27 = (float(t25) - float(t27)) * double(0.7071067690849304)
    t25 = float(t09) + float(t19)
    t19 = (float(t09) - float(t19)) * double(0.7071067690849304)
    t25 = t25 + t19
    t09 = float(t31) + float(t23)
    t31 = (float(t31) - float(t23)) * double(0.5411961078643799)
    t23 = float(t29) + float(t21)
    t21 = (float(t29) - float(t21)) * double(1.3065630197525024)
    t29 = float(t09) + float(t23)
    t23 = (float(t09) - float(t23)) * double(0.7071067690849304)
    t09 = float(t31) + float(t21)
    t31 = (float(t31) - float(t21)) * double(0.7071067690849304)
    t09 = t09 + t31
    t29 = t29 + t09
    t09 = t09 + t23
    t23 = t23 + t31
    t17 = t17 + t29
    t29 = t29 + t25
    t25 = t25 + t09
    t09 = t09 + t27
    t27 = t27 + t23
    t23 = t23 + t19
    t19 = t19 + t31
    t21 = float(t02) + float(t32)
    t02 = (float(t02) - float(t32)) * double(0.5024192929267883)
    t32 = float(t04) + float(t30)
    t04 = (float(t04) - float(t30)) * double(0.522498607635498)
    t30 = float(t06) + float(t28)
    t28 = (float(t06) - float(t28)) * double(0.5669440627098083)
    t06 = float(t08) + float(t26)
    t08 = (float(t08) - float(t26)) * double(0.6468217968940735)
    t26 = float(t10) + float(t24)
    t10 = (float(t10) - float(t24)) * double(0.7881546020507813)
    t24 = float(t12) + float(t22)
    t22 = (float(t12) - float(t22)) * double(1.0606776475906372)
    t12 = float(t14) + float(t20)
    t20 = (float(t14) - float(t20)) * double(1.722447156906128)
    t14 = float(t16) + float(t18)
    t16 = (float(t16) - float(t18)) * double(5.10114860534668)
    t18 = float(t21) + float(t14)
    t14 = (float(t21) - float(t14)) * double(0.509795606136322)
    t21 = float(t32) + float(t12)
    t32 = (float(t32) - float(t12)) * double(0.601344883441925)
    t12 = float(t30) + float(t24)
    t24 = (float(t30) - float(t24)) * double(0.8999761939048767)
    t30 = float(t06) + float(t26)
    t26 = (float(t06) - float(t26)) * double(2.562915563583374)
    t06 = float(t18) + float(t30)
    t18 = (float(t18) - float(t30)) * double(0.5411961078643799)
    t30 = float(t21) + float(t12)
    t12 = (float(t21) - float(t12)) * double(1.3065630197525024)
    t21 = float(t06) + float(t30)
    t30 = (float(t06) - float(t30)) * double(0.7071067690849304)
    t06 = float(t18) + float(t12)
    t12 = (float(t18) - float(t12)) * double(0.7071067690849304)
    t06 = t06 + t12
    t18 = float(t14) + float(t26)
    t26 = (float(t14) - float(t26)) * double(0.5411961078643799)
    t14 = float(t32) + float(t24)
    t24 = (float(t32) - float(t24)) * double(1.3065630197525024)
    t32 = float(t18) + float(t14)
    t14 = (float(t18) - float(t14)) * double(0.7071067690849304)
    t18 = float(t26) + float(t24)
    t24 = (float(t26) - float(t24)) * double(0.7071067690849304)
    t18 = t18 + t24
    t32 = t32 + t18
    t18 = t18 + t14
    t26 = float(t14) + float(t24)
    t14 = float(t02) + float(t16)
    t02 = (float(t02) - float(t16)) * double(0.509795606136322)
    t16 = float(t04) + float(t20)
    t04 = (float(t04) - float(t20)) * double(0.601344883441925)
    t20 = float(t28) + float(t22)
    t22 = (float(t28) - float(t22)) * double(0.8999761939048767)
    t28 = float(t08) + float(t10)
    t10 = (float(t08) - float(t10)) * double(2.562915563583374)
    t08 = float(t14) + float(t28)
    t14 = (float(t14) - float(t28)) * double(0.5411961078643799)
    t28 = float(t16) + float(t20)
    t20 = (float(t16) - float(t20)) * double(1.3065630197525024)
    t16 = float(t08) + float(t28)
    t28 = (float(t08) - float(t28)) * double(0.7071067690849304)
    t08 = float(t14) + float(t20)
    t20 = (float(t14) - float(t20)) * double(0.7071067690849304)
    t08 = t08 + t20
    t14 = float(t02) + float(t10)
    t02 = (float(t02) - float(t10)) * double(0.5411961078643799)
    t10 = float(t04) + float(t22)
    t22 = (float(t04) - float(t22)) * double(1.3065630197525024)
    t04 = float(t14) + float(t10)
    t10 = (float(t14) - float(t10)) * double(0.7071067690849304)
    t14 = float(t02) + float(t22)
    t02 = (float(t02) - float(t22)) * double(0.7071067690849304)
    t14 = t14 + t02
    t04 = t04 + t14
    t14 = t14 + t10
    t10 = t10 + t02
    t16 = t16 + t04
    t04 = t04 + t08
    t08 = t08 + t14
    t14 = t14 + t28
    t28 = t28 + t10
    t10 = t10 + t20
    t20 = t20 + t02
    t21 = t21 + t16
    t16 = t16 + t32
    t32 = t32 + t04
    t04 = t04 + t06
    t06 = t06 + t08
    t08 = t08 + t18
    t18 = t18 + t14
    t14 = t14 + t30
    t30 = t30 + t28
    t28 = t28 + t26
    t26 = t26 + t10
    t10 = t10 + t12
    t12 = t12 + t20
    t20 = t20 + t24
    t24 = t24 + t02
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 48]) = -t33
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 47]) = -t21
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 49]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 47])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 46]) = -t17
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 50]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 46])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 45]) = -t16
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 51]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 45])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 44]) = -t01
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 52]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 44])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 43]) = -t32
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 53]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 43])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 42]) = -t29
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 54]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 42])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 41]) = -t04
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 55]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 41])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 40]) = -t03
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 56]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 40])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 39]) = -t06
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 57]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 39])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 38]) = -t25
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 58]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 38])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 37]) = -t08
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 59]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 37])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 36]) = -t11
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 60]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 36])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 35]) = -t18
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 61]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 35])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 34]) = -t09
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 62]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 34])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 33]) = -t14
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 63]) = unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 33])
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 32]) = -t05
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 0]) = t05
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 31]) = -t30
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 1]) = t30
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 30]) = -t27
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 2]) = t27
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 29]) = -t28
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 3]) = t28
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 28]) = -t07
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 4]) = t07
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 27]) = -t26
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 5]) = t26
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 26]) = -t23
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 6]) = t23
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 25]) = -t10
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 7]) = t10
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 24]) = -t15
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 8]) = t15
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 23]) = -t12
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 9]) = t12
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 22]) = -t19
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 10]) = t19
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 21]) = -t20
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 11]) = t20
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 20]) = -t13
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 12]) = t13
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 19]) = -t24
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 13]) = t24
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 18]) = -t31
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 14]) = t31
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 17]) = -t02
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 15]) = t02
    unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 16]) = float(double(0.0))
    return
}
[export]
def plm_audio_read_samples(var self_84 : plm_audio_t?; var ch_2 : int; var sb_6 : int; var part_0 : int) {
    var q : plm_quantizer_spec_t const? = cast<plm_quantizer_spec_t const?>(0)
    var sf_0 : int = int(0)
    var sample : int? = cast<int?>(0)
    var val : int = int(0)
    var shift_0 : int = int(0)
    var adj : int = int(0)
    var scale : int = int(0)
    q = unsafe(unsafe(addr(unsafe(unsafe(addr(self_84.allocation[0]))[uint(ch_2)])[0]))[uint(sb_6)])
    sf_0 = unsafe(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(self_84.scale_factor[0]))[uint(ch_2)])[0]))[uint(sb_6)])[0]))[uint(part_0)])
    sample = unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(self_84.sample[0]))[uint(ch_2)])[0]))[uint(sb_6)])[0]))
    val = 0
    if (q == null) {
        unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2]) = 0
        unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1]) = unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2])
        unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0]) = unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1])
        return
    } else {
        if (int(sf_0) == 63) {
            sf_0 = 0
        } else {
            shift_0 = uint(int(sf_0) / 3) | uint(0)
            sf_0 = unsafe(unsafe(addr(PLM_AUDIO_SCALEFACTOR_BASE[0]))[int(sf_0) % 3]) + (uint(1 << int(shift_0)) >> uint(1)) >> int(shift_0)
        }
        adj = q.levels
        if (uint64(q.group) != uint64(0)) {
            val = plm_buffer_read(self_84.buffer, int(q.bits))
            unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0]) = int(val) % int(adj)
            val = val / adj
            unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1]) = int(val) % int(adj)
            unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2]) = int(val) / int(adj)
        } else {
            unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0]) = plm_buffer_read(self_84.buffer, int(q.bits))
            unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1]) = plm_buffer_read(self_84.buffer, int(q.bits))
            unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2]) = plm_buffer_read(self_84.buffer, int(q.bits))
        }
        scale = 65536 / (int(adj) + 1)
        adj = (uint(int(adj) + 1) >> uint(1)) - 1
        val = (int(adj) - unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0])) * int(scale)
        unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0]) = uint(int(val) * (uint(int(sf_0)) >> uint(12)) + (uint(int(val) * (uint(int(sf_0)) & uint(4095)) + 2048) >> uint(12))) >> uint(12)
        val = (int(adj) - unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1])) * int(scale)
        unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1]) = uint(int(val) * (uint(int(sf_0)) >> uint(12)) + (uint(int(val) * (uint(int(sf_0)) & uint(4095)) + 2048) >> uint(12))) >> uint(12)
        val = (int(adj) - unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2])) * int(scale)
        unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2]) = uint(int(val) * (uint(int(sf_0)) >> uint(12)) + (uint(int(val) * (uint(int(sf_0)) & uint(4095)) + 2048) >> uint(12))) >> uint(12)
        return
    }
}
var PLM_AUDIO_SCALEFACTOR_BASE : array<int> const = [33554432, 26632170, 21137968]

[export]
def plm_audio_read_allocation(var self_85 : plm_audio_t?; var sb_7 : int; var tab3_0 : int) : plm_quantizer_spec_t const? {
    var tab4 : int = int(0)
    var qtab : int = int(0)
    tab4 = int(unsafe(unsafe(addr(unsafe(unsafe(addr(PLM_AUDIO_QUANT_LUT_STEP_3[0]))[uint(tab3_0)])[0]))[uint(sb_7)]))
    qtab = int(unsafe(unsafe(addr(unsafe(unsafe(addr(PLM_AUDIO_QUANT_LUT_STEP_4[0]))[uint(int(tab4)) & uint(15)])[0]))[uint(plm_buffer_read(self_85.buffer, uint(int(tab4)) >> uint(4)))]))
    var c2da_fresh24 : plm_quantizer_spec_t const? = cast<plm_quantizer_spec_t const?>(0)
    if (uint64(qtab) != uint64(0)) {
        c2da_fresh24 = unsafe(addr(unsafe(unsafe(addr(PLM_AUDIO_QUANT_TAB[0]))[int(qtab) - 1])))
    } else {
        c2da_fresh24 = null
    }
    return unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(c2da_fresh24)))
}
var PLM_AUDIO_QUANT_LUT_STEP_3 : array<array<uint8>> const = [[uint8(68), uint8(68), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52)], [uint8(67), uint8(67), uint8(67), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(32), uint8(32), uint8(32), uint8(32), uint8(32), uint8(32), uint8(32)], [uint8(69), uint8(69), uint8(69), uint8(69), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36)]]

var PLM_AUDIO_QUANT_LUT_STEP_4 : array<array<uint8>> const = [[uint8(0), uint8(1), uint8(2), uint8(17)], [uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(6), uint8(17)], [uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(17)], [uint8(0), uint8(1), uint8(3), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(15), uint8(16), uint8(17)], [uint8(0), uint8(1), uint8(2), uint8(4), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(15), uint8(17)], [uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(15)]]

var PLM_AUDIO_QUANT_TAB : array<plm_quantizer_spec_t> const = [plm_quantizer_spec_t(levels = 3, group = uint8(1), bits = uint8(5)), plm_quantizer_spec_t(levels = 5, group = uint8(1), bits = uint8(7)), plm_quantizer_spec_t(levels = 7, group = uint8(0), bits = uint8(3)), plm_quantizer_spec_t(levels = 9, group = uint8(1), bits = uint8(10)), plm_quantizer_spec_t(levels = 15, group = uint8(0), bits = uint8(4)), plm_quantizer_spec_t(levels = 31, group = uint8(0), bits = uint8(5)), plm_quantizer_spec_t(levels = 63, group = uint8(0), bits = uint8(6)), plm_quantizer_spec_t(levels = 127, group = uint8(0), bits = uint8(7)), plm_quantizer_spec_t(levels = 255, group = uint8(0), bits = uint8(8)), plm_quantizer_spec_t(levels = 511, group = uint8(0), bits = uint8(9)), plm_quantizer_spec_t(levels = 1023, group = uint8(0), bits = uint8(10)), plm_quantizer_spec_t(levels = 2047, group = uint8(0), bits = uint8(11)), plm_quantizer_spec_t(levels = 4095, group = uint8(0), bits = uint8(12)), plm_quantizer_spec_t(levels = 8191, group = uint8(0), bits = uint8(13)), plm_quantizer_spec_t(levels = 16383, group = uint8(0), bits = uint8(14)), plm_quantizer_spec_t(levels = 32767, group = uint8(0), bits = uint8(15)), plm_quantizer_spec_t(levels = 65535, group = uint8(0), bits = uint8(16))]

var PLM_AUDIO_QUANT_LUT_STEP_1 : array<array<uint8>> const = [[uint8(0), uint8(0), uint8(1), uint8(1), uint8(1), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2)], [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(1), uint8(1), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2)]]

var QUANT_LUT_STEP_2 : array<array<uint8>> const = [[uint8(8), uint8(8), uint8(12)], [uint8(uint(27) | uint(64)), uint8(uint(27) | uint(64)), uint8(uint(27) | uint(64))], [uint8(uint(30) | uint(64)), uint8(uint(27) | uint(64)), uint8(uint(30) | uint(64))]]

[export]
def plm_audio_get_time(var self_86 : plm_audio_t?) : double {
    return self_86.time
}
[export]
def plm_video_decode(var self_87 : plm_video_t?) : plm_frame_t? {
    var frame_1 : plm_frame_t? = cast<plm_frame_t?>(0)
    if (uint64(plm_video_has_header(self_87)) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_frame_t?>(null)))
    } else {
        frame_1 = null
        while (true) {
            if (int(self_87.start_code) != int(PLM_START_PICTURE)) {
                self_87.start_code = plm_buffer_find_start_code(self_87.buffer, PLM_START_PICTURE)
                if (int(self_87.start_code) == -1) {
                    if (uint64(self_87.has_reference_frame) != uint64(0) && uint64(self_87.assume_no_b_frames) == uint64(0) && uint64(plm_buffer_has_ended(self_87.buffer)) != uint64(0) && int(self_87.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_INTRA) || int(self_87.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
                        self_87.has_reference_frame = 0
                        frame_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_87.frame_backward)))))
                        break
                        break
                    } else {
                        return unsafe(unsafe(reinterpret<plm_frame_t?>(null)))
                    }
                }
            }
            if (plm_buffer_has_start_code(self_87.buffer, PLM_START_PICTURE) == -1 && uint64(plm_buffer_has_ended(self_87.buffer)) == uint64(0)) {
                return unsafe(unsafe(reinterpret<plm_frame_t?>(null)))
            } else {
                plm_buffer_discard_read_bytes(self_87.buffer)
                plm_video_decode_picture(self_87)
                if (uint64(self_87.assume_no_b_frames) != uint64(0)) {
                    frame_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_87.frame_backward)))))
                } elif (int(self_87.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_B)) {
                    frame_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_87.frame_current)))))
                } elif (uint64(self_87.has_reference_frame) != uint64(0)) {
                    frame_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_87.frame_forward)))))
                } else {
                    self_87.has_reference_frame = 1
                }
                if (!frame_1 == null) {
                    break
                }
            }
        }
        frame_1.time = self_87.time
        self_87.frames_decoded = self_87.frames_decoded + 1
        self_87.frames_decoded
        self_87.time = double(self_87.frames_decoded) / double(self_87.framerate)
        return unsafe(unsafe(reinterpret<plm_frame_t?>(frame_1)))
    }
}
var PLM_VIDEO_PICTURE_TYPE_B : int const = int(3)

[export]
def plm_video_decode_picture(var self_88 : plm_video_t?) {
    var f_code : int = int(0)
    var f_code_0 : int = int(0)
    var frame_temp : plm_frame_t = plm_frame_t()
    plm_buffer_skip(self_88.buffer, unsafe(reinterpret<size_t>(10)))
    self_88.picture_type = plm_buffer_read(self_88.buffer, 3)
    plm_buffer_skip(self_88.buffer, unsafe(reinterpret<size_t>(16)))
    if (int(self_88.picture_type) <= 0 || int(self_88.picture_type) > int(PLM_VIDEO_PICTURE_TYPE_B)) {
        return
    } else {
        if (int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE) || int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_B)) {
            self_88.motion_forward.full_px = plm_buffer_read(self_88.buffer, 1)
            f_code = plm_buffer_read(self_88.buffer, 3)
            if (uint64(int(f_code)) == uint64(0)) {
                return
            } else {
                self_88.motion_forward.r_size = int(f_code) - 1
            }
        }
        if (int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_B)) {
            self_88.motion_backward.full_px = plm_buffer_read(self_88.buffer, 1)
            f_code_0 = plm_buffer_read(self_88.buffer, 3)
            if (uint64(int(f_code_0)) == uint64(0)) {
                return
            } else {
                self_88.motion_backward.r_size = int(f_code_0) - 1
            }
        }
        frame_temp = self_88.frame_forward
        if (int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_INTRA) || int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
            self_88.frame_forward = self_88.frame_backward
        }
        while (true) {
            self_88.start_code = plm_buffer_next_start_code(self_88.buffer)
            if (!int(self_88.start_code) == int(PLM_START_EXTENSION) || int(self_88.start_code) == int(PLM_START_USER_DATA)) {
                break
            }
        }
        while (true) {
            if (!int(self_88.start_code) >= int(PLM_START_SLICE_FIRST) && int(self_88.start_code) <= int(PLM_START_SLICE_LAST)) {
                break
            }
            plm_video_decode_slice(self_88, uint(int(self_88.start_code)) & uint(255))
            if (int(self_88.macroblock_address) >= int(self_88.mb_size) - 1) {
                break
                break
            } else {
                self_88.start_code = plm_buffer_next_start_code(self_88.buffer)
            }
        }
        if (int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_INTRA) || int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
            self_88.frame_backward = self_88.frame_current
            self_88.frame_current = frame_temp
        }
        return
    }
}
var PLM_VIDEO_PICTURE_TYPE_PREDICTIVE : int const = int(2)

var PLM_VIDEO_PICTURE_TYPE_INTRA : int const = int(1)

[export]
def plm_video_decode_slice(var self_89 : plm_video_t?; var slice : int) {
    self_89.slice_begin = 1
    self_89.macroblock_address = (int(slice) - 1) * int(self_89.mb_width) - 1
    self_89.motion_forward.h = 0
    self_89.motion_backward.h = self_89.motion_forward.h
    self_89.motion_forward.v = 0
    self_89.motion_backward.v = self_89.motion_forward.v
    unsafe(unsafe(addr(self_89.dc_predictor[0]))[0]) = 128
    unsafe(unsafe(addr(self_89.dc_predictor[0]))[1]) = 128
    unsafe(unsafe(addr(self_89.dc_predictor[0]))[2]) = 128
    self_89.quantizer_scale = plm_buffer_read(self_89.buffer, 5)
    while (true) {
        if (!uint64(plm_buffer_read(self_89.buffer, 1)) != uint64(0)) {
            break
        }
        plm_buffer_skip(self_89.buffer, unsafe(reinterpret<size_t>(8)))
    }
    while (true) {
        plm_video_decode_macroblock(self_89)
        if (!int(self_89.macroblock_address) < int(self_89.mb_size) - 1 && uint64(plm_buffer_peek_non_zero(self_89.buffer, 23)) != uint64(0)) {
            break
        }
    }
    return
}
[export]
def plm_buffer_peek_non_zero(var self_90 : plm_buffer_t?; var bit_count : int) : int {
    var val_0 : int = int(0)
    if (uint64(plm_buffer_has(self_90, unsafe(reinterpret<size_t>(bit_count)))) == uint64(0)) {
        return 0
    } else {
        val_0 = plm_buffer_read(self_90, bit_count)
        self_90.bit_index = unsafe(reinterpret<size_t>(self_90.bit_index - unsafe(reinterpret<size_t>(bit_count))))
        return uint64(int(val_0)) != uint64(0)
    }
}
[export]
def plm_video_decode_macroblock(var self_91 : plm_video_t?) {
    var increment : int = int(0)
    var t : int = int(0)
    var table_0 : plm_vlc_t const? = cast<plm_vlc_t const?>(0)
    var cbp : int = int(0)
    increment = 0
    t = int(plm_buffer_read_vlc(self_91.buffer, unsafe(addr(PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT[0]))))
    while (true) {
        if (!int(t) == 34) {
            break
        }
        t = int(plm_buffer_read_vlc(self_91.buffer, unsafe(addr(PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT[0]))))
    }
    while (true) {
        if (!int(t) == 35) {
            break
        }
        increment = increment + 33
        t = int(plm_buffer_read_vlc(self_91.buffer, unsafe(addr(PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT[0]))))
    }
    increment = increment + t
    if (uint64(self_91.slice_begin) != uint64(0)) {
        self_91.slice_begin = 0
        self_91.macroblock_address = self_91.macroblock_address + increment
    } elif (int(self_91.macroblock_address) + int(increment) >= int(self_91.mb_size)) {
        return
    } else {
        if (int(increment) > 1) {
            unsafe(unsafe(addr(self_91.dc_predictor[0]))[0]) = 128
            unsafe(unsafe(addr(self_91.dc_predictor[0]))[1]) = 128
            unsafe(unsafe(addr(self_91.dc_predictor[0]))[2]) = 128
            if (int(self_91.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
                self_91.motion_forward.h = 0
                self_91.motion_forward.v = 0
            }
        }
        while (true) {
            if (!int(increment) > 1) {
                break
            }
            self_91.macroblock_address = self_91.macroblock_address + 1
            self_91.macroblock_address
            self_91.mb_row = int(self_91.macroblock_address) / int(self_91.mb_width)
            self_91.mb_col = int(self_91.macroblock_address) % int(self_91.mb_width)
            plm_video_predict_macroblock(self_91)
            increment = increment - 1
            increment
        }
        self_91.macroblock_address = self_91.macroblock_address + 1
        self_91.macroblock_address
    }
    self_91.mb_row = int(self_91.macroblock_address) / int(self_91.mb_width)
    self_91.mb_col = int(self_91.macroblock_address) % int(self_91.mb_width)
    if (int(self_91.mb_col) >= int(self_91.mb_width) || int(self_91.mb_row) >= int(self_91.mb_height)) {
        return
    } else {
        table_0 = unsafe(unsafe(addr(PLM_VIDEO_MACROBLOCK_TYPE[0]))[uint(self_91.picture_type)])
        self_91.macroblock_type = int(plm_buffer_read_vlc(self_91.buffer, table_0))
        self_91.macroblock_intra = uint(int(self_91.macroblock_type)) & uint(1)
        self_91.motion_forward.is_set = uint(int(self_91.macroblock_type)) & uint(8)
        self_91.motion_backward.is_set = uint(int(self_91.macroblock_type)) & uint(4)
        if (uint64(uint(int(self_91.macroblock_type)) & uint(16)) != uint64(0)) {
            self_91.quantizer_scale = plm_buffer_read(self_91.buffer, 5)
        }
        if (uint64(self_91.macroblock_intra) != uint64(0)) {
            self_91.motion_forward.h = 0
            self_91.motion_backward.h = self_91.motion_forward.h
            self_91.motion_forward.v = 0
            self_91.motion_backward.v = self_91.motion_forward.v
        } else {
            unsafe(unsafe(addr(self_91.dc_predictor[0]))[0]) = 128
            unsafe(unsafe(addr(self_91.dc_predictor[0]))[1]) = 128
            unsafe(unsafe(addr(self_91.dc_predictor[0]))[2]) = 128
            plm_video_decode_motion_vectors(self_91)
            plm_video_predict_macroblock(self_91)
        }
        var c2da_fresh25 : int = int(0)
        if (uint64(self_91.macroblock_intra) != uint64(0)) {
            c2da_fresh25 = 63
        } else {
            c2da_fresh25 = 0
        }
        var c2da_fresh26 : int = int(0)
        if (uint64(uint(int(self_91.macroblock_type)) & uint(2)) != uint64(0)) {
            c2da_fresh26 = int(plm_buffer_read_vlc(self_91.buffer, unsafe(addr(PLM_VIDEO_CODE_BLOCK_PATTERN[0]))))
        } else {
            c2da_fresh26 = c2da_fresh25
        }
        cbp = c2da_fresh26
        break
    }
}
[export]
def plm_video_decode_block(var self_92 : plm_video_t?; var block_1 : int) {
    var n : int = int(0)
    var quant_matrix : uint8? = cast<uint8?>(0)
    var predictor : int = int(0)
    var dct_size : int = int(0)
    var plane_index : int = int(0)
    var differential : int = int(0)
    var level : int = int(0)
    var run : int = int(0)
    var coeff : uint16 = uint16(0)
    var de_zig_zagged : int = int(0)
    var d_0 : uint8? = cast<uint8?>(0)
    var dw : int = int(0)
    var di : int = int(0)
    var s_0 : int? = cast<int?>(0)
    var si : int = int(0)
    var clamped : int = int(0)
    var dest_scan : int = int(0)
    var source_scan : int = int(0)
    var dest_scan_0 : int = int(0)
    var source_scan_0 : int = int(0)
    var value_2 : int = int(0)
    var dest_scan_1 : int = int(0)
    var source_scan_1 : int = int(0)
    var dest_scan_2 : int = int(0)
    var source_scan_2 : int = int(0)
    n = 0
    if (uint64(self_92.macroblock_intra) != uint64(0)) {
        var c2da_fresh27 : int = int(0)
        if (int(block_1) > 3) {
            c2da_fresh27 = int(block_1) - 3
        } else {
            c2da_fresh27 = 0
        }
        plane_index = c2da_fresh27
        predictor = unsafe(unsafe(addr(self_92.dc_predictor[0]))[uint(plane_index)])
        dct_size = int(plm_buffer_read_vlc(self_92.buffer, unsafe(unsafe(addr(PLM_VIDEO_DCT_SIZE[0]))[uint(plane_index)])))
        if (int(dct_size) > 0) {
            differential = plm_buffer_read(self_92.buffer, dct_size)
            if (uint64(int(differential) & 1 << int(dct_size) - 1) != uint64(0)) {
                unsafe(unsafe(addr(self_92.block_data[0]))[0]) = int(predictor) + int(differential)
            } else {
                unsafe(unsafe(addr(self_92.block_data[0]))[0]) = int(predictor) + (-1 << int(dct_size) | int(differential) + 1)
            }
        } else {
            unsafe(unsafe(addr(self_92.block_data[0]))[0]) = predictor
        }
        unsafe(unsafe(addr(self_92.dc_predictor[0]))[uint(plane_index)]) = unsafe(unsafe(addr(self_92.block_data[0]))[0])
        unsafe(unsafe(addr(self_92.block_data[0]))[0]) = unsafe(unsafe(addr(self_92.block_data[0]))[0]) << 3 + 5
        quant_matrix = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(self_92.intra_quant_matrix[0])))))
        n = 1
    } else {
        quant_matrix = unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(self_92.non_intra_quant_matrix[0])))))
    }
    level = 0
    while (true) {
        if (!uint64(1) != uint64(0)) {
            break
        }
        run = 0
        coeff = plm_buffer_read_vlc_uint(self_92.buffer, unsafe(addr(PLM_VIDEO_DCT_COEFF[0])))
        if (int(coeff) == 1 && int(n) > 0 && uint64(plm_buffer_read(self_92.buffer, 1)) == uint64(0)) {
            break
            break
        } else {
            if (int(coeff) == 65535) {
                run = plm_buffer_read(self_92.buffer, 6)
                level = plm_buffer_read(self_92.buffer, 8)
                if (uint64(int(level)) == uint64(0)) {
                    level = plm_buffer_read(self_92.buffer, 8)
                } elif (int(level) == 128) {
                    level = plm_buffer_read(self_92.buffer, 8) - 256
                } elif (int(level) > 128) {
                    level = int(level) - 256
                }
            } else {
                run = uint(int(coeff)) >> uint(8)
                level = uint(int(coeff)) & uint(255)
                if (uint64(plm_buffer_read(self_92.buffer, 1)) != uint64(0)) {
                    level = -level
                }
            }
            n = n + run
            if (int(n) < 0 || int(n) >= 64) {
                return
            } else {
                de_zig_zagged = int(unsafe(unsafe(addr(PLM_VIDEO_ZIG_ZAG[0]))[uint(n)]))
                n = n + 1
                n
                level = int(uint(uint(level)) << uint(uint(1)))
                if (uint64(self_92.macroblock_intra) == uint64(0)) {
                    var c2da_fresh28 : int = int(0)
                    if (int(level) < 0) {
                        c2da_fresh28 = -1
                    } else {
                        c2da_fresh28 = 1
                    }
                    level = level + c2da_fresh28
                }
                level = uint(int(level) * int(self_92.quantizer_scale) * int(unsafe(unsafe(unsafe(reinterpret<uint8?>(quant_matrix)))[uint(de_zig_zagged)]))) >> uint(4)
                if (uint64(uint(int(level)) & uint(1)) == uint64(0)) {
                    var c2da_fresh29 : int = int(0)
                    if (int(level) > 0) {
                        c2da_fresh29 = 1
                    } else {
                        c2da_fresh29 = -1
                    }
                    level = level - c2da_fresh29
                }
                if (int(level) > 2047) {
                    level = 2047
                } elif (int(level) < -2048) {
                    level = -2048
                }
                unsafe(unsafe(addr(self_92.block_data[0]))[uint(de_zig_zagged)]) = int(level) * int(unsafe(unsafe(addr(PLM_VIDEO_PREMULTIPLIER_MATRIX[0]))[uint(de_zig_zagged)]))
            }
        }
    }
    if (int(block_1) < 4) {
        d_0 = unsafe(unsafe(reinterpret<uint8?>(self_92.frame_current.y.data)))
        dw = self_92.luma_width
        di = uint(int(self_92.mb_row) * int(self_92.luma_width) + int(self_92.mb_col)) << uint(4)
        if (uint64(uint(int(block_1)) & uint(1)) != uint64(0)) {
            di = di + 8
        }
        if (uint64(uint(int(block_1)) & uint(2)) != uint64(0)) {
            di = di + (uint(int(self_92.luma_width)) << uint(3))
        }
    } else {
        var c2da_fresh30 : uint8? = cast<uint8?>(0)
        if (int(block_1) == 4) {
            c2da_fresh30 = self_92.frame_current.cb.data
        } else {
            c2da_fresh30 = self_92.frame_current.cr.data
        }
        d_0 = unsafe(unsafe(reinterpret<uint8?>(c2da_fresh30)))
        dw = self_92.chroma_width
        di = (uint(int(self_92.mb_row) * int(self_92.luma_width)) << uint(2)) + (uint(int(self_92.mb_col)) << uint(3))
    }
    s_0 = unsafe(addr(self_92.block_data[0]))
    si = 0
    if (uint64(self_92.macroblock_intra) != uint64(0)) {
        if (int(n) == 1) {
            clamped = int(plm_clamp(uint(unsafe(unsafe(unsafe(reinterpret<int?>(s_0)))[0]) + 128) >> uint(8)))
            dest_scan = int(dw) - 8
            source_scan = 8 - 8
            break
        } else {
            plm_video_idct(s_0)
            dest_scan_0 = int(dw) - 8
            source_scan_0 = 8 - 8
            break
        }
    } elif (int(n) == 1) {
        value_2 = uint(unsafe(unsafe(unsafe(reinterpret<int?>(s_0)))[0]) + 128) >> uint(8)
        dest_scan_1 = int(dw) - 8
        source_scan_1 = 8 - 8
        break
    } else {
        plm_video_idct(s_0)
        dest_scan_2 = int(dw) - 8
        source_scan_2 = 8 - 8
        break
    }
}
[export]
def plm_clamp(var n_0 : int) : uint8 {
    if (int(n_0) > 255) {
        n_0 = 255
    } elif (int(n_0) < 0) {
        n_0 = 0
    }
    return uint8(n_0)
}
[export]
def plm_video_idct(var block_2 : int?) {
    var b1 : int = int(0)
    var b3 : int = int(0)
    var b4 : int = int(0)
    var b6 : int = int(0)
    var b7 : int = int(0)
    var tmp1 : int = int(0)
    var tmp2 : int = int(0)
    var m0 : int = int(0)
    var x0 : int = int(0)
    var x1 : int = int(0)
    var x2 : int = int(0)
    var x3 : int = int(0)
    var x4 : int = int(0)
    var y3 : int = int(0)
    var y4 : int = int(0)
    var y5 : int = int(0)
    var y6 : int = int(0)
    var y7 : int = int(0)
    break
}
var PLM_VIDEO_PREMULTIPLIER_MATRIX : array<uint8> const = [uint8(32), uint8(44), uint8(42), uint8(38), uint8(32), uint8(25), uint8(17), uint8(9), uint8(44), uint8(62), uint8(58), uint8(52), uint8(44), uint8(35), uint8(24), uint8(12), uint8(42), uint8(58), uint8(55), uint8(49), uint8(42), uint8(33), uint8(23), uint8(12), uint8(38), uint8(52), uint8(49), uint8(44), uint8(38), uint8(30), uint8(20), uint8(10), uint8(32), uint8(44), uint8(42), uint8(38), uint8(32), uint8(25), uint8(17), uint8(9), uint8(25), uint8(35), uint8(33), uint8(30), uint8(25), uint8(20), uint8(14), uint8(7), uint8(17), uint8(24), uint8(23), uint8(20), uint8(17), uint8(14), uint8(9), uint8(5), uint8(9), uint8(12), uint8(12), uint8(10), uint8(9), uint8(7), uint8(5), uint8(2)]

var PLM_VIDEO_DCT_COEFF : array<plm_vlc_uint_t> const = [plm_vlc_uint_t(index = int16(uint(1) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(1)), plm_vlc_uint_t(index = int16(uint(2) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(3) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(4) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(5) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(6) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(257)), plm_vlc_uint_t(index = int16(uint(7) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(8) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(9) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(10) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(2)), plm_vlc_uint_t(index = int16(0), value = uint16(513)), plm_vlc_uint_t(index = int16(uint(11) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(12) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(13) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(14) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(15) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(3)), plm_vlc_uint_t(index = int16(0), value = uint16(1025)), plm_vlc_uint_t(index = int16(0), value = uint16(769)), plm_vlc_uint_t(index = int16(uint(16) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(65535)), plm_vlc_uint_t(index = int16(uint(17) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(18) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(1793)), plm_vlc_uint_t(index = int16(0), value = uint16(1537)), plm_vlc_uint_t(index = int16(0), value = uint16(258)), plm_vlc_uint_t(index = int16(0), value = uint16(1281)), plm_vlc_uint_t(index = int16(uint(19) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(20) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(21) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(22) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(514)), plm_vlc_uint_t(index = int16(0), value = uint16(2305)), plm_vlc_uint_t(index = int16(0), value = uint16(4)), plm_vlc_uint_t(index = int16(0), value = uint16(2049)), plm_vlc_uint_t(index = int16(uint(23) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(24) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(25) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(26) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(27) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(28) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(29) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(30) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(3329)), plm_vlc_uint_t(index = int16(0), value = uint16(6)), plm_vlc_uint_t(index = int16(0), value = uint16(3073)), plm_vlc_uint_t(index = int16(0), value = uint16(2817)), plm_vlc_uint_t(index = int16(0), value = uint16(770)), plm_vlc_uint_t(index = int16(0), value = uint16(259)), plm_vlc_uint_t(index = int16(0), value = uint16(5)), plm_vlc_uint_t(index = int16(0), value = uint16(2561)), plm_vlc_uint_t(index = int16(uint(31) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(32) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(33) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(34) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(35) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(36) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(37) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(38) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(39) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(40) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(41) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(42) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(43) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(44) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(45) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(46) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(4097)), plm_vlc_uint_t(index = int16(0), value = uint16(1282)), plm_vlc_uint_t(index = int16(0), value = uint16(7)), plm_vlc_uint_t(index = int16(0), value = uint16(515)), plm_vlc_uint_t(index = int16(0), value = uint16(260)), plm_vlc_uint_t(index = int16(0), value = uint16(3841)), plm_vlc_uint_t(index = int16(0), value = uint16(3585)), plm_vlc_uint_t(index = int16(0), value = uint16(1026)), plm_vlc_uint_t(index = int16(uint(47) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(48) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(49) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(50) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(51) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(52) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(53) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(54) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(55) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(56) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(57) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(58) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(59) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(60) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(61) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(62) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(-1), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(63) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(64) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(65) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(66) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(67) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(68) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(69) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(70) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(71) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(72) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(73) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(74) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(75) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(76) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(77) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(11)), plm_vlc_uint_t(index = int16(0), value = uint16(2050)), plm_vlc_uint_t(index = int16(0), value = uint16(1027)), plm_vlc_uint_t(index = int16(0), value = uint16(10)), plm_vlc_uint_t(index = int16(0), value = uint16(516)), plm_vlc_uint_t(index = int16(0), value = uint16(1794)), plm_vlc_uint_t(index = int16(0), value = uint16(5377)), plm_vlc_uint_t(index = int16(0), value = uint16(5121)), plm_vlc_uint_t(index = int16(0), value = uint16(9)), plm_vlc_uint_t(index = int16(0), value = uint16(4865)), plm_vlc_uint_t(index = int16(0), value = uint16(4609)), plm_vlc_uint_t(index = int16(0), value = uint16(261)), plm_vlc_uint_t(index = int16(0), value = uint16(771)), plm_vlc_uint_t(index = int16(0), value = uint16(8)), plm_vlc_uint_t(index = int16(0), value = uint16(1538)), plm_vlc_uint_t(index = int16(0), value = uint16(4353)), plm_vlc_uint_t(index = int16(uint(78) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(79) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(80) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(81) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(82) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(83) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(84) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(85) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(86) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(87) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(88) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(89) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(90) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(91) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(2562)), plm_vlc_uint_t(index = int16(0), value = uint16(2306)), plm_vlc_uint_t(index = int16(0), value = uint16(1283)), plm_vlc_uint_t(index = int16(0), value = uint16(772)), plm_vlc_uint_t(index = int16(0), value = uint16(517)), plm_vlc_uint_t(index = int16(0), value = uint16(263)), plm_vlc_uint_t(index = int16(0), value = uint16(262)), plm_vlc_uint_t(index = int16(0), value = uint16(15)), plm_vlc_uint_t(index = int16(0), value = uint16(14)), plm_vlc_uint_t(index = int16(0), value = uint16(13)), plm_vlc_uint_t(index = int16(0), value = uint16(12)), plm_vlc_uint_t(index = int16(0), value = uint16(6657)), plm_vlc_uint_t(index = int16(0), value = uint16(6401)), plm_vlc_uint_t(index = int16(0), value = uint16(6145)), plm_vlc_uint_t(index = int16(0), value = uint16(5889)), plm_vlc_uint_t(index = int16(0), value = uint16(5633)), plm_vlc_uint_t(index = int16(uint(92) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(93) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(94) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(95) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(96) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(97) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(98) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(99) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(100) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(101) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(102) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(103) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(31)), plm_vlc_uint_t(index = int16(0), value = uint16(30)), plm_vlc_uint_t(index = int16(0), value = uint16(29)), plm_vlc_uint_t(index = int16(0), value = uint16(28)), plm_vlc_uint_t(index = int16(0), value = uint16(27)), plm_vlc_uint_t(index = int16(0), value = uint16(26)), plm_vlc_uint_t(index = int16(0), value = uint16(25)), plm_vlc_uint_t(index = int16(0), value = uint16(24)), plm_vlc_uint_t(index = int16(0), value = uint16(23)), plm_vlc_uint_t(index = int16(0), value = uint16(22)), plm_vlc_uint_t(index = int16(0), value = uint16(21)), plm_vlc_uint_t(index = int16(0), value = uint16(20)), plm_vlc_uint_t(index = int16(0), value = uint16(19)), plm_vlc_uint_t(index = int16(0), value = uint16(18)), plm_vlc_uint_t(index = int16(0), value = uint16(17)), plm_vlc_uint_t(index = int16(0), value = uint16(16)), plm_vlc_uint_t(index = int16(uint(104) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(105) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(106) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(107) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(108) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(109) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(110) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(uint(111) << uint(1)), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(40)), plm_vlc_uint_t(index = int16(0), value = uint16(39)), plm_vlc_uint_t(index = int16(0), value = uint16(38)), plm_vlc_uint_t(index = int16(0), value = uint16(37)), plm_vlc_uint_t(index = int16(0), value = uint16(36)), plm_vlc_uint_t(index = int16(0), value = uint16(35)), plm_vlc_uint_t(index = int16(0), value = uint16(34)), plm_vlc_uint_t(index = int16(0), value = uint16(33)), plm_vlc_uint_t(index = int16(0), value = uint16(32)), plm_vlc_uint_t(index = int16(0), value = uint16(270)), plm_vlc_uint_t(index = int16(0), value = uint16(269)), plm_vlc_uint_t(index = int16(0), value = uint16(268)), plm_vlc_uint_t(index = int16(0), value = uint16(267)), plm_vlc_uint_t(index = int16(0), value = uint16(266)), plm_vlc_uint_t(index = int16(0), value = uint16(265)), plm_vlc_uint_t(index = int16(0), value = uint16(264)), plm_vlc_uint_t(index = int16(0), value = uint16(274)), plm_vlc_uint_t(index = int16(0), value = uint16(273)), plm_vlc_uint_t(index = int16(0), value = uint16(272)), plm_vlc_uint_t(index = int16(0), value = uint16(271)), plm_vlc_uint_t(index = int16(0), value = uint16(1539)), plm_vlc_uint_t(index = int16(0), value = uint16(4098)), plm_vlc_uint_t(index = int16(0), value = uint16(3842)), plm_vlc_uint_t(index = int16(0), value = uint16(3586)), plm_vlc_uint_t(index = int16(0), value = uint16(3330)), plm_vlc_uint_t(index = int16(0), value = uint16(3074)), plm_vlc_uint_t(index = int16(0), value = uint16(2818)), plm_vlc_uint_t(index = int16(0), value = uint16(7937)), plm_vlc_uint_t(index = int16(0), value = uint16(7681)), plm_vlc_uint_t(index = int16(0), value = uint16(7425)), plm_vlc_uint_t(index = int16(0), value = uint16(7169)), plm_vlc_uint_t(index = int16(0), value = uint16(6913))]

[export]
def plm_buffer_read_vlc_uint(var self_93 : plm_buffer_t?; var table_1 : plm_vlc_uint_t const?) : uint16 {
    return uint16(plm_buffer_read_vlc(self_93, table_1))
}
[export]
def plm_buffer_read_vlc(var self_94 : plm_buffer_t?; var table_2 : plm_vlc_t const?) : int16 {
    var state : plm_vlc_t = plm_vlc_t()
    state = plm_vlc_t(index = int16(0), value = int16(0))
    while (true) {
        state = unsafe(unsafe(unsafe(reinterpret<plm_vlc_t const?>(table_2)))[int(state.index) + plm_buffer_read(self_94, 1)])
        if (!int(state.index) > 0) {
            break
        }
    }
    return state.value
}
var PLM_VIDEO_DCT_SIZE : array<plm_vlc_t const?> = [unsafe(addr(PLM_VIDEO_DCT_SIZE_LUMINANCE[0])), unsafe(addr(PLM_VIDEO_DCT_SIZE_CHROMINANCE[0])), unsafe(addr(PLM_VIDEO_DCT_SIZE_CHROMINANCE[0]))]

var PLM_VIDEO_DCT_SIZE_CHROMINANCE : array<plm_vlc_t> const = [plm_vlc_t(index = int16(uint(1) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(2) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(uint(3) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(uint(4) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(uint(5) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(uint(6) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(uint(7) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(uint(8) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(-1), value = int16(0))]

var PLM_VIDEO_DCT_SIZE_LUMINANCE : array<plm_vlc_t> const = [plm_vlc_t(index = int16(uint(1) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(2) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(uint(3) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(4) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(uint(5) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(uint(6) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(uint(7) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(uint(8) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(-1), value = int16(0))]

var PLM_VIDEO_CODE_BLOCK_PATTERN : array<plm_vlc_t> const = [plm_vlc_t(index = int16(uint(1) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(2) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(3) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(4) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(5) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(6) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(7) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(8) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(9) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(10) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(11) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(12) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(13) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(60)), plm_vlc_t(index = int16(uint(14) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(15) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(16) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(17) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(18) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(19) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(20) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(21) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(22) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(23) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(32)), plm_vlc_t(index = int16(0), value = int16(16)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(uint(24) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(25) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(26) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(27) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(28) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(29) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(30) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(31) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(62)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(0), value = int16(61)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(0), value = int16(56)), plm_vlc_t(index = int16(0), value = int16(52)), plm_vlc_t(index = int16(0), value = int16(44)), plm_vlc_t(index = int16(0), value = int16(28)), plm_vlc_t(index = int16(0), value = int16(40)), plm_vlc_t(index = int16(0), value = int16(20)), plm_vlc_t(index = int16(0), value = int16(48)), plm_vlc_t(index = int16(0), value = int16(12)), plm_vlc_t(index = int16(uint(32) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(33) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(34) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(35) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(36) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(37) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(38) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(39) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(40) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(41) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(42) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(43) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(63)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(0), value = int16(36)), plm_vlc_t(index = int16(0), value = int16(24)), plm_vlc_t(index = int16(uint(44) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(45) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(46) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(47) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(48) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(49) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(50) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(51) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(52) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(53) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(54) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(55) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(56) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(57) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(58) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(59) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(34)), plm_vlc_t(index = int16(0), value = int16(18)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(0), value = int16(33)), plm_vlc_t(index = int16(0), value = int16(17)), plm_vlc_t(index = int16(0), value = int16(9)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(uint(60) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(61) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(62) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(58)), plm_vlc_t(index = int16(0), value = int16(54)), plm_vlc_t(index = int16(0), value = int16(46)), plm_vlc_t(index = int16(0), value = int16(30)), plm_vlc_t(index = int16(0), value = int16(57)), plm_vlc_t(index = int16(0), value = int16(53)), plm_vlc_t(index = int16(0), value = int16(45)), plm_vlc_t(index = int16(0), value = int16(29)), plm_vlc_t(index = int16(0), value = int16(38)), plm_vlc_t(index = int16(0), value = int16(26)), plm_vlc_t(index = int16(0), value = int16(37)), plm_vlc_t(index = int16(0), value = int16(25)), plm_vlc_t(index = int16(0), value = int16(43)), plm_vlc_t(index = int16(0), value = int16(23)), plm_vlc_t(index = int16(0), value = int16(51)), plm_vlc_t(index = int16(0), value = int16(15)), plm_vlc_t(index = int16(0), value = int16(42)), plm_vlc_t(index = int16(0), value = int16(22)), plm_vlc_t(index = int16(0), value = int16(50)), plm_vlc_t(index = int16(0), value = int16(14)), plm_vlc_t(index = int16(0), value = int16(41)), plm_vlc_t(index = int16(0), value = int16(21)), plm_vlc_t(index = int16(0), value = int16(49)), plm_vlc_t(index = int16(0), value = int16(13)), plm_vlc_t(index = int16(0), value = int16(35)), plm_vlc_t(index = int16(0), value = int16(19)), plm_vlc_t(index = int16(0), value = int16(11)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(0), value = int16(39)), plm_vlc_t(index = int16(0), value = int16(27)), plm_vlc_t(index = int16(0), value = int16(59)), plm_vlc_t(index = int16(0), value = int16(55)), plm_vlc_t(index = int16(0), value = int16(47)), plm_vlc_t(index = int16(0), value = int16(31))]

[export]
def plm_video_predict_macroblock(var self_95 : plm_video_t?) {
    var fw_h : int = int(0)
    var fw_v : int = int(0)
    var bw_h : int = int(0)
    var bw_v : int = int(0)
    fw_h = self_95.motion_forward.h
    fw_v = self_95.motion_forward.v
    if (uint64(self_95.motion_forward.full_px) != uint64(0)) {
        fw_h = uint(fw_h) << uint(1)
        fw_v = uint(fw_v) << uint(1)
    }
    if (int(self_95.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_B)) {
        bw_h = self_95.motion_backward.h
        bw_v = self_95.motion_backward.v
        if (uint64(self_95.motion_backward.full_px) != uint64(0)) {
            bw_h = uint(bw_h) << uint(1)
            bw_v = uint(bw_v) << uint(1)
        }
        if (uint64(self_95.motion_forward.is_set) != uint64(0)) {
            plm_video_copy_macroblock(self_95, unsafe(addr(self_95.frame_forward)), fw_h, fw_v)
            if (uint64(self_95.motion_backward.is_set) != uint64(0)) {
                plm_video_interpolate_macroblock(self_95, unsafe(addr(self_95.frame_backward)), bw_h, bw_v)
            }
        } else {
            plm_video_copy_macroblock(self_95, unsafe(addr(self_95.frame_backward)), bw_h, bw_v)
        }
    } else {
        plm_video_copy_macroblock(self_95, unsafe(addr(self_95.frame_forward)), fw_h, fw_v)
    }
    return
}
[export]
def plm_video_copy_macroblock(var self_96 : plm_video_t?; var s_1 : plm_frame_t?; var motion_h : int; var motion_v : int) {
    var d_1 : plm_frame_t? = cast<plm_frame_t?>(0)
    d_1 = unsafe(addr(self_96.frame_current))
    plm_video_process_macroblock(self_96, s_1.y.data, d_1.y.data, motion_h, motion_v, 16, 0)
    plm_video_process_macroblock(self_96, s_1.cr.data, d_1.cr.data, int(motion_h) / 2, int(motion_v) / 2, 8, 0)
    plm_video_process_macroblock(self_96, s_1.cb.data, d_1.cb.data, int(motion_h) / 2, int(motion_v) / 2, 8, 0)
    return
}
[export]
def plm_video_process_macroblock(var self_97 : plm_video_t?; var s_2 : uint8?; var d_2 : uint8?; var motion_h_0 : int; var motion_v_0 : int; var block_size : int; var interpolate : int) {
    var dw_0 : int = int(0)
    var hp : int = int(0)
    var vp : int = int(0)
    var odd_h : int = int(0)
    var odd_v : int = int(0)
    var si_0 : uint = uint(0)
    var di_0 : uint = uint(0)
    var max_address : uint = uint(0)
    var dest_scan_3 : int = int(0)
    var source_scan_3 : int = int(0)
    dw_0 = int(self_97.mb_width) * int(block_size)
    hp = uint(int(motion_h_0)) >> uint(1)
    vp = uint(int(motion_v_0)) >> uint(1)
    odd_h = (uint(int(motion_h_0)) & uint(1)) == 1
    odd_v = (uint(int(motion_v_0)) & uint(1)) == 1
    si_0 = uint((int(self_97.mb_row) * int(block_size) + int(vp)) * int(dw_0) + int(self_97.mb_col) * int(block_size) + int(hp))
    di_0 = uint((int(self_97.mb_row) * int(dw_0) + int(self_97.mb_col)) * int(block_size))
    max_address = uint(int(dw_0) * (int(self_97.mb_height) * int(block_size) - int(block_size) + 1) - int(block_size))
    if (uint(si_0) > uint(max_address) || uint(di_0) > uint(max_address)) {
        return
    } else {
        uint(int(interpolate)) << uint(2) | uint(int(odd_h)) << uint(1) | int(odd_v)
        dest_scan_3 = int(dw_0) - int(block_size)
        source_scan_3 = int(dw_0) - int(block_size)
        break
    }
}
[export]
def plm_video_interpolate_macroblock(var self_98 : plm_video_t?; var s_3 : plm_frame_t?; var motion_h_1 : int; var motion_v_1 : int) {
    var d_3 : plm_frame_t? = cast<plm_frame_t?>(0)
    d_3 = unsafe(addr(self_98.frame_current))
    plm_video_process_macroblock(self_98, s_3.y.data, d_3.y.data, motion_h_1, motion_v_1, 16, 1)
    plm_video_process_macroblock(self_98, s_3.cr.data, d_3.cr.data, int(motion_h_1) / 2, int(motion_v_1) / 2, 8, 1)
    plm_video_process_macroblock(self_98, s_3.cb.data, d_3.cb.data, int(motion_h_1) / 2, int(motion_v_1) / 2, 8, 1)
    return
}
[export]
def plm_video_decode_motion_vectors(var self_99 : plm_video_t?) {
    var r_size : int = int(0)
    var r_size_0 : int = int(0)
    if (uint64(self_99.motion_forward.is_set) != uint64(0)) {
        r_size = self_99.motion_forward.r_size
        self_99.motion_forward.h = plm_video_decode_motion_vector(self_99, r_size, self_99.motion_forward.h)
        self_99.motion_forward.v = plm_video_decode_motion_vector(self_99, r_size, self_99.motion_forward.v)
    } elif (int(self_99.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
        self_99.motion_forward.h = 0
        self_99.motion_forward.v = 0
    }
    if (uint64(self_99.motion_backward.is_set) != uint64(0)) {
        r_size_0 = self_99.motion_backward.r_size
        self_99.motion_backward.h = plm_video_decode_motion_vector(self_99, r_size_0, self_99.motion_backward.h)
        self_99.motion_backward.v = plm_video_decode_motion_vector(self_99, r_size_0, self_99.motion_backward.v)
    }
    return
}
[export]
def plm_video_decode_motion_vector(var self_100 : plm_video_t?; var r_size_1 : int; var motion : int) : int {
    var fscale : int = int(0)
    var m_code : int = int(0)
    var r : int = int(0)
    var d_4 : int = int(0)
    fscale = 1 << int(r_size_1)
    m_code = int(plm_buffer_read_vlc(self_100.buffer, unsafe(addr(PLM_VIDEO_MOTION[0]))))
    r = 0
    if (uint64(int(m_code)) != uint64(0) && int(fscale) != 1) {
        r = plm_buffer_read(self_100.buffer, r_size_1)
        d_4 = (abs(m_code) - 1 << int(r_size_1)) + int(r) + 1
        if (int(m_code) < 0) {
            d_4 = -d_4
        }
    } else {
        d_4 = m_code
    }
    motion = motion + d_4
    if (int(motion) > (uint(int(fscale)) << uint(4)) - 1) {
        motion = motion - (uint(int(fscale)) << uint(5))
    } elif (int(motion) < int(uint(uint(-fscale)) << uint(uint(4)))) {
        motion = motion + (uint(int(fscale)) << uint(5))
    }
    return motion
}
var PLM_VIDEO_MOTION : array<plm_vlc_t> const = [plm_vlc_t(index = int16(uint(1) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(0)), plm_vlc_t(index = int16(uint(2) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(3) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(4) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(5) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(0), value = int16(-1)), plm_vlc_t(index = int16(uint(6) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(7) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(0), value = int16(-2)), plm_vlc_t(index = int16(uint(8) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(9) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(0), value = int16(-3)), plm_vlc_t(index = int16(uint(10) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(11) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(12) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(13) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(uint(14) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(15) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(16) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(17) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(18) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(0), value = int16(-4)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(uint(19) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(20) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(21) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(0), value = int16(-7)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(0), value = int16(-6)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(0), value = int16(-5)), plm_vlc_t(index = int16(uint(22) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(23) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(24) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(25) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(26) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(27) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(28) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(29) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(30) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(31) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(32) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(33) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(0), value = int16(-10)), plm_vlc_t(index = int16(0), value = int16(9)), plm_vlc_t(index = int16(0), value = int16(-9)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(0), value = int16(-8)), plm_vlc_t(index = int16(0), value = int16(16)), plm_vlc_t(index = int16(0), value = int16(-16)), plm_vlc_t(index = int16(0), value = int16(15)), plm_vlc_t(index = int16(0), value = int16(-15)), plm_vlc_t(index = int16(0), value = int16(14)), plm_vlc_t(index = int16(0), value = int16(-14)), plm_vlc_t(index = int16(0), value = int16(13)), plm_vlc_t(index = int16(0), value = int16(-13)), plm_vlc_t(index = int16(0), value = int16(12)), plm_vlc_t(index = int16(0), value = int16(-12)), plm_vlc_t(index = int16(0), value = int16(11)), plm_vlc_t(index = int16(0), value = int16(-11))]

var PLM_VIDEO_MACROBLOCK_TYPE : array<plm_vlc_t const?> = [null, unsafe(addr(PLM_VIDEO_MACROBLOCK_TYPE_INTRA[0])), unsafe(addr(PLM_VIDEO_MACROBLOCK_TYPE_PREDICTIVE[0])), unsafe(addr(PLM_VIDEO_MACROBLOCK_TYPE_B[0]))]

var PLM_VIDEO_MACROBLOCK_TYPE_B : array<plm_vlc_t> const = [plm_vlc_t(index = int16(uint(1) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(2) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(3) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(4) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(12)), plm_vlc_t(index = int16(0), value = int16(14)), plm_vlc_t(index = int16(uint(5) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(6) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(uint(7) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(8) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(uint(9) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(10) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(30)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(17)), plm_vlc_t(index = int16(0), value = int16(22)), plm_vlc_t(index = int16(0), value = int16(26))]

var PLM_VIDEO_MACROBLOCK_TYPE_PREDICTIVE : array<plm_vlc_t> const = [plm_vlc_t(index = int16(uint(1) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(uint(2) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(uint(3) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(uint(4) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(5) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(6) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(18)), plm_vlc_t(index = int16(0), value = int16(26)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(17))]

var PLM_VIDEO_MACROBLOCK_TYPE_INTRA : array<plm_vlc_t> const = [plm_vlc_t(index = int16(uint(1) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(17))]

var PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT : array<plm_vlc_t> const = [plm_vlc_t(index = int16(uint(1) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(uint(2) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(3) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(4) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(5) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(uint(6) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(7) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(uint(8) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(9) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(uint(10) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(11) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(12) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(13) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(14) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(15) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(16) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(17) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(18) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(19) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(9)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(uint(20) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(uint(21) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(22) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(23) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(15)), plm_vlc_t(index = int16(0), value = int16(14)), plm_vlc_t(index = int16(0), value = int16(13)), plm_vlc_t(index = int16(0), value = int16(12)), plm_vlc_t(index = int16(0), value = int16(11)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(uint(24) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(25) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(26) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(27) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(28) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(29) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(30) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(31) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(32) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(uint(33) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(34) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(35) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(36) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(37) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(38) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(uint(39) << uint(1)), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(21)), plm_vlc_t(index = int16(0), value = int16(20)), plm_vlc_t(index = int16(0), value = int16(19)), plm_vlc_t(index = int16(0), value = int16(18)), plm_vlc_t(index = int16(0), value = int16(17)), plm_vlc_t(index = int16(0), value = int16(16)), plm_vlc_t(index = int16(0), value = int16(35)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(34)), plm_vlc_t(index = int16(0), value = int16(33)), plm_vlc_t(index = int16(0), value = int16(32)), plm_vlc_t(index = int16(0), value = int16(31)), plm_vlc_t(index = int16(0), value = int16(30)), plm_vlc_t(index = int16(0), value = int16(29)), plm_vlc_t(index = int16(0), value = int16(28)), plm_vlc_t(index = int16(0), value = int16(27)), plm_vlc_t(index = int16(0), value = int16(26)), plm_vlc_t(index = int16(0), value = int16(25)), plm_vlc_t(index = int16(0), value = int16(24)), plm_vlc_t(index = int16(0), value = int16(23)), plm_vlc_t(index = int16(0), value = int16(22))]

var PLM_START_SLICE_LAST : int const = int(175)

var PLM_START_SLICE_FIRST : int const = int(1)

var PLM_START_USER_DATA : int const = int(178)

var PLM_START_EXTENSION : int const = int(181)

var PLM_START_PICTURE : int const = int(0)

[export]
def plm_buffer_has_start_code(var self_101 : plm_buffer_t?; var code_0 : int) : int {
    var previous_bit_index : size_t = unsafe(reinterpret<size_t>(0))
    var previous_discard_read_bytes : int = int(0)
    var current_0 : int = int(0)
    previous_bit_index = self_101.bit_index
    previous_discard_read_bytes = self_101.discard_read_bytes
    self_101.discard_read_bytes = 0
    current_0 = plm_buffer_find_start_code(self_101, code_0)
    self_101.bit_index = unsafe(reinterpret<size_t>(previous_bit_index))
    self_101.discard_read_bytes = previous_discard_read_bytes
    return current_0
}
[export]
def plm_video_get_time(var self_102 : plm_video_t?) : double {
    return self_102.time
}
[export]
def plm_decode_video(var self_103 : plm_t?) : plm_frame_t? {
    var frame_2 : plm_frame_t? = cast<plm_frame_t?>(0)
    if (uint64(plm_init_decoders(self_103)) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_frame_t?>(null)))
    } elif (uint64(self_103.video_packet_type) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_frame_t?>(null)))
    } else {
        frame_2 = plm_video_decode(self_103.video_decoder)
        if (frame_2 != null) {
            self_103.time = frame_2.time
        } elif (uint64(plm_demux_has_ended(self_103.demux)) != uint64(0)) {
            plm_handle_end(self_103)
        }
        return unsafe(unsafe(reinterpret<plm_frame_t?>(frame_2)))
    }
}
[export]
def plm_decode_audio(var self_104 : plm_t?) : plm_samples_t? {
    var samples_0 : plm_samples_t? = cast<plm_samples_t?>(0)
    if (uint64(plm_init_decoders(self_104)) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_samples_t?>(null)))
    } elif (uint64(self_104.audio_packet_type) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_samples_t?>(null)))
    } else {
        samples_0 = plm_audio_decode(self_104.audio_decoder)
        if (samples_0 != null) {
            self_104.time = samples_0.time
        } elif (uint64(plm_demux_has_ended(self_104.demux)) != uint64(0)) {
            plm_handle_end(self_104)
        }
        return unsafe(unsafe(reinterpret<plm_samples_t?>(samples_0)))
    }
}
[export]
def plm_seek(var self_105 : plm_t?; var time : double; var seek_exact : int) : int {
    var frame_3 : plm_frame_t? = cast<plm_frame_t?>(0)
    var start_time : double = double(0)
    var packet_2 : plm_packet_t? = cast<plm_packet_t?>(0)
    frame_3 = plm_seek_frame(self_105, time, seek_exact)
    if (frame_3 == null) {
        return 0
    } else {
        if (self_105.video_decode_callback != null) {
            self_105.video_decode_callback(self_105, frame_3, self_105.video_decode_callback_user_data)
        }
        if (uint64(self_105.audio_packet_type) == uint64(0)) {
            return 1
        } else {
            start_time = plm_demux_get_start_time(self_105.demux, self_105.video_packet_type)
            plm_audio_rewind(self_105.audio_decoder)
            packet_2 = null
            while (true) {
                packet_2 = unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode(self_105.demux))))
                if (!packet_2 != null) {
                    break
                }
                if (int(packet_2.type_0) == int(self_105.video_packet_type)) {
                    plm_buffer_write(self_105.video_buffer, packet_2.data, packet_2.length)
                } elif (int(packet_2.type_0) == int(self_105.audio_packet_type) && double(packet_2.pts) - double(start_time) > double(self_105.time)) {
                    plm_audio_set_time(self_105.audio_decoder, double(packet_2.pts) - double(start_time))
                    plm_buffer_write(self_105.audio_buffer, packet_2.data, packet_2.length)
                    plm_decode(self_105, double(0))
                    break
                    break
                }
            }
            return 1
        }
    }
}
[export]
def plm_audio_set_time(var self_106 : plm_audio_t?; var time_0 : double) {
    self_106.samples_decoded = int(double(time_0) * double(unsafe(unsafe(addr(PLM_AUDIO_SAMPLE_RATE[0]))[uint(self_106.samplerate_index)])))
    self_106.time = time_0
    return
}
[export]
def plm_seek_frame(var self_107 : plm_t?; var time_1 : double; var seek_exact_0 : int) : plm_frame_t? {
    var type_3 : int = int(0)
    var start_time_0 : double = double(0)
    var duration : double = double(0)
    var packet_3 : plm_packet_t? = cast<plm_packet_t?>(0)
    var previous_audio_packet_type : int = int(0)
    var frame_4 : plm_frame_t? = cast<plm_frame_t?>(0)
    if (uint64(plm_init_decoders(self_107)) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_frame_t?>(null)))
    } elif (uint64(self_107.video_packet_type) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_frame_t?>(null)))
    } else {
        type_3 = self_107.video_packet_type
        start_time_0 = plm_demux_get_start_time(self_107.demux, type_3)
        duration = plm_demux_get_duration(self_107.demux, type_3)
        if (double(time_1) < double(0)) {
            time_1 = double(0)
        } elif (double(time_1) > double(duration)) {
            time_1 = duration
        }
        packet_3 = plm_demux_seek(self_107.demux, time_1, type_3, 1)
        if (packet_3 == null) {
            return unsafe(unsafe(reinterpret<plm_frame_t?>(null)))
        } else {
            previous_audio_packet_type = self_107.audio_packet_type
            self_107.audio_packet_type = 0
            plm_video_rewind(self_107.video_decoder)
            plm_video_set_time(self_107.video_decoder, double(packet_3.pts) - double(start_time_0))
            plm_buffer_write(self_107.video_buffer, packet_3.data, packet_3.length)
            frame_4 = plm_video_decode(self_107.video_decoder)
            if (uint64(seek_exact_0) != uint64(0)) {
                while (true) {
                    if (!frame_4 != null && double(frame_4.time) < double(time_1)) {
                        break
                    }
                    frame_4 = unsafe(unsafe(reinterpret<plm_frame_t?>(plm_video_decode(self_107.video_decoder))))
                }
            }
            self_107.audio_packet_type = previous_audio_packet_type
            if (frame_4 != null) {
                self_107.time = frame_4.time
            }
            self_107.has_ended = 0
            return unsafe(unsafe(reinterpret<plm_frame_t?>(frame_4)))
        }
    }
}
[export]
def plm_demux_seek(var self_108 : plm_demux_t?; var seek_time : double; var type_4 : int; var force_intra : int) : plm_packet_t? {
    var duration_0 : double = double(0)
    var file_size_0 : int64 = int64(0)
    var byterate : int64 = int64(0)
    var cur_time : double = double(0)
    var scan_span : double = double(0)
    if (uint64(plm_demux_has_headers(self_108)) == uint64(0)) {
        return unsafe(unsafe(reinterpret<plm_packet_t?>(null)))
    } else {
        duration_0 = plm_demux_get_duration(self_108, type_4)
        file_size_0 = int64(plm_buffer_get_size(self_108.buffer))
        byterate = int64(double(file_size_0) / double(duration_0))
        cur_time = self_108.last_decoded_pts
        scan_span = double(1)
        if (double(seek_time) > double(duration_0)) {
            seek_time = duration_0
        } elif (double(seek_time) < double(0)) {
            seek_time = double(0)
        }
        seek_time = seek_time + self_108.start_time
        break
    }
}
[export]
def plm_video_set_time(var self_109 : plm_video_t?; var time_2 : double) {
    self_109.frames_decoded = int(double(self_109.framerate) * double(time_2))
    self_109.time = time_2
    return
}
[export]
def plm_buffer_create_with_callbacks(var load_callback : plm_buffer_load_callback; var seek_callback : plm_buffer_seek_callback; var tell_callback : plm_buffer_tell_callback; var length_2 : size_t; var user_4 : uint64) : plm_buffer_t? {
    var self_110 : plm_buffer_t? = cast<plm_buffer_t?>(0)
    self_110 = plm_buffer_create_with_capacity(unsafe(reinterpret<size_t>(128 * 1024)))
    self_110.mode = unsafe(reinterpret<plm_buffer_mode>(PLM_BUFFER_MODE_FILE))
    self_110.total_size = unsafe(reinterpret<size_t>(length_2))
    self_110.load_callback = load_callback
    self_110.seek_callback = seek_callback
    self_110.tell_callback = tell_callback
    self_110.load_callback_user_data = user_4
    return unsafe(unsafe(reinterpret<plm_buffer_t?>(self_110)))
}
[export]
def plm_buffer_create_for_appending(var initial_capacity : size_t) : plm_buffer_t? {
    var self_111 : plm_buffer_t? = cast<plm_buffer_t?>(0)
    self_111 = plm_buffer_create_with_capacity(initial_capacity)
    self_111.mode = unsafe(reinterpret<plm_buffer_mode>(PLM_BUFFER_MODE_APPEND))
    self_111.discard_read_bytes = 0
    return unsafe(unsafe(reinterpret<plm_buffer_t?>(self_111)))
}
[export]
def plm_buffer_get_remaining(var self_112 : plm_buffer_t?) : size_t {
    return unsafe(reinterpret<size_t>(self_112.length)) - (unsafe(reinterpret<size_t>(self_112.bit_index)) >> unsafe(reinterpret<size_t>(3)))
}
[export]
def plm_video_set_no_delay(var self_113 : plm_video_t?; var no_delay : int) {
    self_113.assume_no_b_frames = no_delay
    return
}
[export]
def plm_video_has_ended(var self_114 : plm_video_t?) : int {
    return plm_buffer_has_ended(self_114.buffer)
}
[export]
def plm_frame_to_rgb(var frame_5 : plm_frame_t?; var dest_2 : uint8?; var stride : int) {
    var cols : int = int(0)
    var rows : int = int(0)
    var yw : int = int(0)
    var cw : int = int(0)
    cols = int(uint(uint(frame_5.width)) >> uint(uint(1)))
    rows = int(uint(uint(frame_5.height)) >> uint(uint(1)))
    yw = int(frame_5.y.width)
    cw = int(frame_5.cb.width)
    break
}
[export]
def plm_frame_to_bgr(var frame_6 : plm_frame_t?; var dest_3 : uint8?; var stride_0 : int) {
    var cols_0 : int = int(0)
    var rows_0 : int = int(0)
    var yw_0 : int = int(0)
    var cw_0 : int = int(0)
    cols_0 = int(uint(uint(frame_6.width)) >> uint(uint(1)))
    rows_0 = int(uint(uint(frame_6.height)) >> uint(uint(1)))
    yw_0 = int(frame_6.y.width)
    cw_0 = int(frame_6.cb.width)
    break
}
[export]
def plm_frame_to_rgba(var frame_7 : plm_frame_t?; var dest_4 : uint8?; var stride_1 : int) {
    var cols_1 : int = int(0)
    var rows_1 : int = int(0)
    var yw_1 : int = int(0)
    var cw_1 : int = int(0)
    cols_1 = int(uint(uint(frame_7.width)) >> uint(uint(1)))
    rows_1 = int(uint(uint(frame_7.height)) >> uint(uint(1)))
    yw_1 = int(frame_7.y.width)
    cw_1 = int(frame_7.cb.width)
    break
}
[export]
def plm_frame_to_bgra(var frame_8 : plm_frame_t?; var dest_5 : uint8?; var stride_2 : int) {
    var cols_2 : int = int(0)
    var rows_2 : int = int(0)
    var yw_2 : int = int(0)
    var cw_2 : int = int(0)
    cols_2 = int(uint(uint(frame_8.width)) >> uint(uint(1)))
    rows_2 = int(uint(uint(frame_8.height)) >> uint(uint(1)))
    yw_2 = int(frame_8.y.width)
    cw_2 = int(frame_8.cb.width)
    break
}
[export]
def plm_frame_to_argb(var frame_9 : plm_frame_t?; var dest_6 : uint8?; var stride_3 : int) {
    var cols_3 : int = int(0)
    var rows_3 : int = int(0)
    var yw_3 : int = int(0)
    var cw_3 : int = int(0)
    cols_3 = int(uint(uint(frame_9.width)) >> uint(uint(1)))
    rows_3 = int(uint(uint(frame_9.height)) >> uint(uint(1)))
    yw_3 = int(frame_9.y.width)
    cw_3 = int(frame_9.cb.width)
    break
}
[export]
def plm_frame_to_abgr(var frame_10 : plm_frame_t?; var dest_7 : uint8?; var stride_4 : int) {
    var cols_4 : int = int(0)
    var rows_4 : int = int(0)
    var yw_4 : int = int(0)
    var cw_4 : int = int(0)
    cols_4 = int(uint(uint(frame_10.width)) >> uint(uint(1)))
    rows_4 = int(uint(uint(frame_10.height)) >> uint(uint(1)))
    yw_4 = int(frame_10.y.width)
    cw_4 = int(frame_10.cb.width)
    break
}
[export]
def plm_audio_has_ended(var self_115 : plm_audio_t?) : int {
    return plm_buffer_has_ended(self_115.buffer)
}
var sample_mpg_len : uint const = uint(0x5991)

var sample_mpg_bytes : array<uint8> const = [uint8(0), uint8(0), uint8(1), uint8(179), uint8(6), uint8(0), uint8(64), uint8(19), uint8(255), uint8(255), uint8(224), uint8(24), uint8(0), uint8(0), uint8(1), uint8(184), uint8(0), uint8(8), uint8(0), uint8(64), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(15), uint8(255), uint8(248), uint8(0), uint8(0), uint8(1), uint8(1), uint8(19), uint8(249), uint8(193), uint8(49), uint8(0), uint8(11), uint8(128), uint8(52), uint8(0), uint8(116), uint8(5), uint8(0), uint8(78), uint8(1), uint8(126), uint8(25), uint8(201), uint8(161), uint8(184), uint8(132), uint8(134), uint8(0), uint8(172), uint8(176), uint8(210), uint8(105), uint8(52), uint8(178), uint8(106), uint8(74), uint8(12), uint8(38), uint8(19), uint8(8), uint8(68), uint8(33), uint8(161), uint8(161), uint8(161), uint8(189), uint8(148), uint8(128), uint8(194), uint8(186), uint8(91), uint8(126), uint8(205), uint8(191), uint8(180), uint8(32), uint8(1), uint8(248), uint8(1), uint8(0), uint8(5), uint8(152), uint8(7), uint8(105), uint8(40), uint8(97), uint8(48), uint8(2), uint8(190), uint8(3), uint8(14), uint8(176), uint8(13), uint8(121), uint8(15), uint8(0), uint8(239), uint8(36), uint8(96), uint8(5), uint8(64), uint8(7), uint8(131), uint8(0), uint8(15), uint8(192), uint8(45), uint8(26), uint8(8), uint8(128), uint8(128), uint8(96), uint8(104), uint8(192), uint8(150), uint8(24), uint8(187), uint8(120), uint8(3), uint8(48), uint8(194), uint8(105), uint8(48), uint8(16), uint8(72), uint8(192), uint8(49), uint8(1), uint8(184), uint8(1), uint8(208), uint8(20), uint8(1), uint8(208), uint8(32), uint8(245), uint8(144), uint8(131), uint8(64), uint8(51), uint8(229), uint8(96), uint8(210), uint8(128), uint8(64), uint8(77), uint8(0), uint8(212), uint8(51), uint8(147), uint8(0), uint8(116), uint8(77), uint8(13), uint8(43), uint8(168), uint8(148), uint8(3), uint8(118), uint8(116), uint8(150), uint8(193), uint8(155), uint8(182), uint8(45), uint8(57), uint8(238), uint8(209), uint8(52), uint8(132), uint8(3), uint8(30), uint8(0), uint8(99), uint8(192), uint8(22), uint8(128), uint8(30), uint8(184), uint8(6), uint8(138), uint8(1), uint8(0), uint8(32), uint8(244), uint8(128), uint8(216), uint8(160), uint8(11), uint8(56), uint8(12), uint8(112), uint8(5), uint8(216), uint8(4), uint8(220), uint8(6), uint8(32), uint8(54), uint8(113), uint8(128), uint8(22), uint8(0), uint8(30), uint8(168), uint8(150), uint8(8), uint8(97), uint8(3), uint8(66), uint8(9), uint8(109), uint8(121), uint8(192), uint8(128), uint8(94), uint8(8), uint8(6), uint8(224), uint8(24), uint8(0), uint8(36), uint8(0), uint8(211), uint8(134), uint8(6), uint8(0), uint8(239), uint8(224), uint8(212), uint8(144), uint8(182), uint8(38), uint8(144), uint8(200), uint8(69), uint8(96), uint8(29), uint8(0), uint8(86), uint8(26), uint8(3), uint8(2), uint8(195), uint8(67), uint8(16), uint8(25), uint8(208), uint8(82), uint8(11), uint8(114), uint8(105), uint8(107), uint8(13), uint8(195), uint8(67), uint8(67), uint8(75), uint8(196), uint8(181), uint8(6), uint8(115), uint8(253), uint8(245), uint8(120), uint8(134), uint8(2), uint8(0), uint8(6), uint8(32), uint8(38), uint8(0), uint8(200), uint8(52), uint8(10), uint8(128), uint8(56), uint8(1), uint8(1), uint8(52), uint8(150), uint8(24), uint8(5), uint8(27), uint8(19), uint8(73), uint8(129), uint8(132), uint8(212), uint8(147), uint8(16), uint8(3), uint8(178), uint8(16), uint8(97), uint8(101), uint8(129), uint8(81), uint8(169), uint8(24), uint8(229), uint8(35), uint8(132), uint8(37), uint8(208), uint8(132), uint8(126), uint8(133), uint8(151), uint8(142), uint8(190), uint8(32), uint8(5), uint8(192), uint8(128), uint8(88), uint8(8), uint8(6), uint8(32), uint8(14), uint8(67), uint8(18), uint8(26), uint8(2), uint8(96), uint8(16), uint8(1), uint8(148), uint8(20), uint8(90), uint8(67), uint8(11), uint8(220), uint8(134), uint8(1), uint8(120), uint8(97), uint8(97), uint8(129), uint8(165), uint8(118), uint8(73), uint8(65), uint8(161), uint8(129), uint8(164), uint8(212), uint8(22), uint8(82), uint8(112), uint8(18), uint8(74), uint8(55), uint8(102), uint8(231), uint8(120), uint8(0), uint8(98), uint8(8), uint8(5), uint8(192), uint8(128), uint8(94), uint8(0), uint8(240), uint8(152), uint8(130), uint8(104), uint8(12), uint8(64), uint8(52), uint8(37), uint8(33), uint8(33), uint8(165), uint8(19), uint8(10), uint8(216), uint8(10), uint8(128), uint8(98), uint8(26), uint8(88), uint8(104), uint8(104), uint8(111), uint8(100), uint8(6), uint8(6), uint8(6), uint8(6), uint8(19), uint8(82), uint8(26), uint8(26), uint8(90), uint8(76), uint8(65), uint8(72), uint8(253), uint8(183), uint8(231), uint8(107), uint8(96), uint8(2), uint8(194), uint8(96), uint8(5), uint8(165), uint8(128), uint8(33), uint8(1), uint8(137), uint8(55), uint8(6), uint8(128), uint8(94), uint8(2), uint8(96), uint8(29), uint8(129), uint8(64), uint8(29), uint8(16), uint8(128), uint8(110), uint8(66), uint8(40), uint8(103), uint8(0), uint8(199), uint8(128), uint8(192), uint8(4), uint8(197), uint8(147), uint8(0), uint8(98), uint8(1), uint8(81), uint8(69), uint8(37), uint8(31), uint8(141), uint8(45), uint8(208), uint8(142), uint8(87), uint8(37), uint8(116), uint8(246), uint8(41), uint8(42), uint8(170), uint8(0), uint8(106), uint8(87), uint8(2), uint8(133), uint8(128), uint8(21), uint8(0), uint8(132), uint8(152), uint8(6), uint8(64), uint8(30), uint8(0), uint8(128), uint8(6), uint8(0), uint8(80), uint8(4), uint8(224), uint8(80), uint8(2), uint8(210), uint8(24), uint8(96), uint8(222), uint8(0), uint8(249), uint8(32), uint8(33), uint8(1), uint8(2), uint8(9), uint8(128), uint8(48), uint8(0), uint8(63), uint8(40), uint8(180), uint8(167), uint8(225), uint8(133), uint8(178), uint8(11), uint8(225), uint8(188), uint8(149), uint8(147), uint8(152), uint8(178), uint8(243), uint8(222), uint8(74), uint8(64), uint8(14), uint8(240), uint8(12), uint8(64), uint8(192), uint8(0), uint8(148), uint8(3), uint8(49), uint8(140), uint8(224), uint8(135), uint8(244), uint8(26), uint8(238), uint8(1), uint8(80), uint8(25), uint8(3), uint8(3), uint8(92), uint8(105), uint8(44), uint8(150), uint8(2), uint8(128), uint8(67), uint8(5), uint8(119), uint8(3), uint8(206), uint8(17), uint8(124), uint8(89), uint8(8), uint8(16), uint8(49), uint8(128), uint8(19), uint8(134), uint8(128), uint8(100), uint8(1), uint8(111), uint8(1), uint8(216), uint8(12), uint8(113), uint8(111), uint8(179), uint8(224), uint8(19), uint8(129), uint8(81), uint8(131), uint8(56), uint8(8), uint8(113), uint8(8), uint8(2), uint8(210), uint8(87), uint8(13), uint8(24), uint8(3), uint8(108), uint8(24), uint8(8), uint8(95), uint8(78), uint8(1), uint8(91), uint8(54), uint8(36), uint8(140), uint8(9), uint8(190), uint8(208), uint8(32), uint8(161), uint8(130), uint8(2), uint8(72), uint8(1), uint8(240), uint8(1), uint8(248), uint8(0), uint8(136), uint8(11), uint8(0), uint8(90), uint8(0), uint8(124), uint8(192), uint8(7), uint8(96), uint8(12), uint8(192), uint8(110), uint8(1), uint8(88), uint8(209), uint8(128), uint8(21), uint8(0), uint8(84), uint8(0), uint8(126), uint8(1), uint8(88), uint8(13), uint8(220), uint8(17), uint8(1), uint8(9), uint8(67), uint8(88), uint8(37), uint8(153), uint8(117), uint8(64), uint8(32), uint8(4), uint8(5), uint8(0), uint8(64), uint8(65), uint8(0), uint8(188), uint8(51), uint8(134), uint8(129), uint8(64), uint8(6), uint8(196), uint8(188), uint8(130), uint8(210), uint8(24), uint8(157), uint8(192), uint8(66), uint8(0), uint8(228), uint8(162), uint8(202), uint8(13), uint8(43), uint8(178), uint8(74), uint8(44), uint8(162), uint8(192), uint8(98), uint8(130), uint8(202), uint8(78), uint8(2), uint8(73), uint8(70), uint8(236), uint8(220), uint8(239), uint8(18), uint8(192), uint8(64), uint8(3), uint8(28), uint8(0), uint8(159), uint8(128), uint8(49), uint8(64), uint8(14), uint8(198), uint8(128), uint8(100), uint8(224), uint8(6), uint8(192), uint8(131), uint8(210), uint8(3), uint8(98), uint8(176), uint8(20), uint8(0), uint8(61), uint8(0), uint8(50), uint8(0), uint8(60), uint8(0), uint8(63), uint8(3), uint8(14), uint8(48), uint8(2), uint8(192), uint8(3), uint8(208), uint8(128), uint8(50), uint8(8), uint8(97), uint8(3), uint8(84), uint8(6), uint8(90), uint8(231), uint8(128), uint8(54), uint8(33), uint8(114), uint8(106), uint8(64), uint8(18), uint8(128), uint8(156), uint8(135), uint8(131), uint8(64), uint8(47), uint8(1), uint8(48), uint8(14), uint8(200), uint8(64), uint8(80), uint8(10), uint8(0), uint8(90), uint8(76), uint8(40), uint8(103), uint8(0), uint8(197), uint8(32), uint8(38), uint8(1), uint8(50), uint8(73), uint8(128), uint8(49), uint8(0), uint8(168), uint8(162), uint8(147), uint8(156), uint8(105), uint8(110), uint8(132), uint8(112), uint8(206), uint8(74), uint8(233), uint8(236), uint8(82), uint8(123), uint8(92), uint8(128), uint8(84), uint8(3), uint8(16), uint8(11), uint8(195), uint8(10), uint8(26), uint8(128), uint8(6), uint8(32), uint8(15), uint8(255), uint8(229), uint8(20), uint8(144), uint8(67), uint8(245), uint8(33), uint8(168), uint8(180), uint8(151), uint8(183), uint8(2), uint8(141), uint8(250), uint8(0), uint8(82), uint8(82), uint8(63), uint8(79), uint8(116), uint8(161), uint8(45), uint8(150), uint8(86), uint8(62), uint8(247), uint8(128), uint8(116), uint8(1), uint8(152), uint8(21), uint8(13), uint8(38), uint8(146), uint8(131), uint8(64), uint8(76), uint8(24), uint8(141), uint8(131), uint8(67), uint8(74), uint8(36), uint8(102), uint8(72), uint8(97), uint8(69), uint8(37), uint8(40), uint8(1), uint8(142), uint8(78), uint8(44), uint8(176), uint8(66), uint8(6), uint8(13), uint8(78), uint8(197), uint8(110), uint8(132), uint8(22), uint8(83), uint8(165), uint8(68), uint8(212), uint8(245), uint8(95), uint8(135), uint8(0), uint8(122), uint8(3), uint8(176), uint8(7), uint8(0), uint8(12), uint8(136), uint8(72), uint8(33), uint8(128), uint8(133), uint8(32), uint8(97), uint8(5), uint8(147), uint8(67), uint8(8), uint8(65), uint8(155), uint8(98), uint8(24), uint8(104), uint8(105), uint8(52), uint8(154), uint8(77), uint8(72), uint8(194), uint8(137), uint8(132), uint8(194), uint8(97), uint8(51), uint8(22), uint8(77), uint8(38), uint8(134), uint8(167), uint8(156), uint8(80), uint8(98), uint8(18), uint8(150), uint8(223), uint8(179), uint8(111), uint8(94), uint8(8), uint8(60), uint8(160), uint8(8), uint8(0), uint8(13), uint8(128), uint8(13), uint8(192), uint8(43), uint8(0), uint8(160), uint8(0), uint8(244), uint8(0), uint8(208), uint8(96), uint8(24), uint8(1), uint8(136), uint8(1), uint8(248), uint8(1), uint8(201), uint8(44), uint8(148), uint8(0), uint8(116), uint8(0), uint8(112), uint8(74), uint8(0), uint8(59), uint8(0), uint8(63), uint8(117), uint8(128), uint8(216), uint8(6), uint8(196), uint8(177), uint8(128), uint8(93), uint8(134), uint8(46), uint8(235), uint8(128), uint8(33), uint8(33), uint8(0), uint8(29), uint8(6), uint8(130), uint8(1), uint8(104), uint8(6), uint8(32), uint8(83), uint8(16), uint8(192), uint8(24), uint8(0), uint8(96), uint8(2), uint8(0), uint8(24), uint8(0), uint8(106), uint8(3), uint8(0), uint8(3), uint8(240), uint8(29), uint8(147), uint8(9), uint8(105), uint8(0), uint8(104), uint8(144), uint8(12), uint8(192), uint8(46), uint8(40), uint8(10), uint8(0), uint8(100), uint8(0), uint8(118), uint8(76), uint8(13), uint8(73), uint8(127), uint8(1), uint8(128), uint8(209), uint8(133), uint8(6), uint8(242), uint8(106), uint8(64), uint8(194), uint8(11), uint8(204), uint8(77), uint8(47), uint8(59), uint8(221), uint8(176), uint8(3), uint8(224), uint8(13), uint8(65), uint8(7), uint8(84), uint8(16), uint8(119), uint8(192), uint8(13), uint8(193), uint8(8), uint8(64), uint8(16), uint8(196), uint8(1), uint8(7), uint8(128), uint8(2), uint8(160), uint8(192), uint8(3), uint8(224), uint8(3), uint8(112), uint8(65), uint8(21), uint8(0), uint8(52), uint8(0), uint8(55), uint8(0), uint8(169), uint8(198), uint8(0), uint8(31), uint8(0), uint8(27), uint8(168), uint8(6), uint8(224), uint8(134), uint8(22), uint8(52), uint8(32), uint8(6), uint8(237), uint8(125), uint8(224), uint8(3), uint8(160), uint8(64), uint8(67), uint8(0), uint8(40), uint8(1), uint8(8), uint8(12), uint8(0), uint8(200), uint8(104), uint8(12), uint8(0), uint8(64), uint8(142), uint8(1), uint8(80), uint8(14), uint8(200), uint8(96), uint8(134), uint8(20), uint8(5), uint8(54), uint8(44), uint8(154), uint8(76), uint8(2), uint8(161), uint8(161), uint8(133), uint8(0), uint8(97), uint8(178), uint8(0), uint8(96), uint8(77), uint8(70), uint8(1), uint8(217), uint8(53), uint8(8), uint8(193), uint8(184), uint8(96), uint8(104), uint8(104), uint8(107), uint8(36), uint8(32), uint8(10), uint8(23), uint8(130), uint8(125), uint8(206), uint8(1), uint8(168), uint8(2), uint8(16), uint8(12), uint8(192), uint8(116), uint8(67), uint8(37), uint8(32), uint8(167), uint8(192), uint8(55), uint8(38), uint8(6), uint8(31), uint8(248), uint8(194), uint8(131), uint8(73), uint8(136), uint8(45), uint8(32), uint8(39), uint8(255), uint8(134), uint8(149), uint8(249), uint8(48), uint8(164), uint8(167), uint8(149), uint8(220), uint8(162), uint8(138), uint8(124), uint8(178), uint8(106), uint8(58), uint8(175), uint8(130), uint8(1), uint8(112), uint8(2), uint8(160), uint8(2), uint8(96), uint8(7), uint8(36), uint8(196), uint8(147), uint8(64), uint8(76), uint8(5), uint8(0), uint8(202), uint8(10), uint8(13), uint8(44), uint8(152), uint8(94), uint8(225), uint8(160), uint8(33), uint8(12), uint8(13), uint8(12), uint8(38), uint8(134), uint8(118), uint8(44), uint8(48), uint8(154), uint8(76), uint8(13), uint8(44), uint8(160), uint8(208), uint8(194), uint8(209), uint8(207), uint8(65), uint8(104), uint8(71), uint8(111), uint8(187), uint8(55), uint8(212), uint8(0), uint8(188), uint8(1), uint8(80), uint8(1), uint8(48), uint8(3), uint8(130), uint8(98), uint8(9), uint8(160), uint8(39), uint8(2), uint8(128), uint8(97), uint8(5), uint8(134), uint8(148), uint8(76), uint8(43), uint8(96), uint8(208), uint8(16), uint8(134), uint8(134), uint8(134), uint8(147), uint8(67), uint8(123), uint8(20), uint8(24), uint8(76), uint8(38), uint8(6), uint8(22), uint8(88), uint8(104), uint8(105), uint8(105), uint8(231), uint8(32), uint8(164), uint8(39), uint8(182), uint8(253), uint8(155), uint8(123), uint8(162), uint8(0), uint8(92), uint8(26), uint8(1), uint8(96), uint8(9), uint8(192), uint8(16), uint8(128), uint8(53), uint8(33), uint8(129), uint8(80), uint8(10), uint8(192), uint8(65), uint8(195), uint8(0), uint8(50), uint8(192), uint8(2), uint8(124), uint8(24), uint8(48), uint8(160), uint8(24), uint8(164), uint8(2), uint8(224), uint8(19), uint8(36), uint8(160), uint8(19), uint8(144), uint8(195), uint8(3), uint8(10), uint8(127), uint8(202), uint8(197), uint8(238), uint8(220), uint8(51), uint8(36), uint8(175), uint8(223), uint8(6), uint8(116), uint8(181), uint8(88), uint8(1), uint8(136), uint8(12), uint8(64), uint8(15), uint8(192), uint8(53), uint8(0), uint8(46), uint8(0), uint8(110), uint8(24), uint8(3), uint8(176), uint8(3), uint8(224), uint8(19), uint8(32), uint8(48), uint8(3), uint8(20), uint8(0), uint8(9), uint8(120), uint8(96), uint8(210), uint8(128), uint8(96), uint8(144), uint8(7), uint8(224), uint8(32), uint8(65), uint8(64), uint8(32), uint8(33), uint8(134), uint8(134), uint8(23), uint8(179), uint8(20), uint8(6), uint8(122), uint8(31), uint8(134), uint8(236), uint8(25), uint8(187), uint8(96), uint8(222), uint8(135), uint8(177), uint8(72), uint8(32), uint8(26), uint8(0), uint8(56), uint8(64), uint8(3), uint8(240), uint8(11), uint8(48), uint8(14), uint8(136), uint8(92), uint8(10), uint8(18), uint8(186), uint8(122), uint8(64), uint8(15), uint8(138), uint8(26), uint8(6), uint8(64), uint8(14), uint8(0), uint8(43), uint8(0), uint8(60), uint8(26), uint8(1), uint8(103), uint8(0), uint8(164), uint8(150), uint8(8), uint8(64), uint8(192), uint8(134), uint8(10), uint8(75), uint8(26), uint8(176), uint8(27), uint8(56), uint8(69), uint8(233), uint8(16), uint8(192), uint8(16), uint8(0), uint8(96), uint8(24), uint8(1), uint8(112), uint8(1), uint8(234), uint8(0), uint8(48), uint8(0), uint8(184), uint8(180), uint8(228), uint8(164), uint8(105), uint8(64), uint8(7), uint8(128), uint8(83), uint8(124), uint8(76), uint8(192), uint8(59), uint8(228), uint8(204), uint8(3), uint8(188), uint8(141), uint8(210), uint8(228), uint8(206), uint8(140), uint8(6), uint8(95), uint8(22), uint8(51), uint8(110), uint8(3), uint8(159), uint8(130), uint8(111), uint8(168), uint8(8), uint8(37), uint8(160), uint8(128), uint8(126), uint8(0), uint8(120), uint8(0), uint8(122), uint8(0), uint8(112), uint8(5), uint8(128), uint8(43), uint8(0), uint8(60), uint8(24), uint8(1), uint8(104), uint8(3), uint8(144), uint8(11), uint8(64), uint8(15), uint8(198), uint8(140), uint8(0), uint8(168), uint8(0), uint8(248), uint8(6), uint8(224), uint8(7), uint8(224), uint8(22), uint8(184), uint8(34), uint8(2), uint8(1), uint8(129), uint8(163), uint8(2), uint8(88), uint8(98), uint8(232), uint8(8), uint8(37), uint8(160), uint8(128), uint8(126), uint8(0), uint8(120), uint8(0), uint8(122), uint8(0), uint8(112), uint8(5), uint8(128), uint8(43), uint8(0), uint8(60), uint8(24), uint8(1), uint8(104), uint8(3), uint8(144), uint8(11), uint8(64), uint8(15), uint8(198), uint8(140), uint8(0), uint8(168), uint8(0), uint8(248), uint8(6), uint8(224), uint8(7), uint8(224), uint8(22), uint8(184), uint8(34), uint8(2), uint8(1), uint8(129), uint8(163), uint8(2), uint8(88), uint8(98), uint8(237), uint8(96), uint8(22), uint8(0), uint8(196), uint8(16), uint8(120), uint8(1), uint8(7), uint8(156), uint8(0), uint8(244), uint8(16), uint8(131), uint8(1), uint8(12), uint8(44), uint8(16), uint8(122), uint8(64), uint8(108), uint8(80), uint8(5), uint8(128), uint8(7), uint8(160), uint8(2), uint8(96), uint8(3), uint8(160), uint8(3), uint8(208), uint8(27), uint8(56), uint8(192), uint8(11), uint8(0), uint8(15), uint8(84), uint8(75), uint8(4), uint8(48), uint8(129), uint8(161), uint8(4), uint8(182), uint8(160), uint8(5), uint8(128), uint8(49), uint8(4), uint8(30), uint8(0), uint8(65), uint8(231), uint8(0), uint8(61), uint8(4), uint8(32), uint8(192), uint8(67), uint8(11), uint8(4), uint8(30), uint8(144), uint8(27), uint8(20), uint8(1), uint8(96), uint8(1), uint8(232), uint8(0), uint8(152), uint8(0), uint8(232), uint8(0), uint8(244), uint8(6), uint8(206), uint8(48), uint8(2), uint8(192), uint8(3), uint8(213), uint8(18), uint8(193), uint8(12), uint8(32), uint8(104), uint8(65), uint8(45), uint8(175), uint8(44), uint8(16), uint8(76), uint8(64), uint8(25), uint8(0), uint8(75), uint8(129), uint8(12), uint8(40), uint8(0), uint8(252), uint8(144), uint8(128), uint8(67), uint8(250), uint8(4), uint8(81), uint8(0), uint8(67), uint8(9), uint8(4), uint8(63), uint8(128), uint8(74), uint8(251), uint8(4), uint8(96), uint8(155), uint8(230), uint8(65), uint8(6), uint8(224), uint8(0), uint8(148), uint8(17), uint8(126), uint8(0), uint8(66), uint8(8), uint8(126), uint8(160), uint8(7), uint8(128), uint8(135), uint8(238), uint8(67), uint8(4), uint8(48), uint8(112), uint8(69), uint8(238), uint8(4), uint8(63), uint8(64), uint8(67), uint8(9), uint8(20), uint8(8), uint8(96), uint8(192), uint8(141), uint8(237), uint8(126), uint8(12), uint8(1), uint8(32), uint8(98), uint8(11), uint8(0), uint8(112), uint8(3), uint8(167), uint8(206), uint8(1), uint8(56), uint8(240), uint8(69), uint8(251), uint8(46), uint8(0), uint8(49), uint8(0), uint8(116), uint8(95), uint8(43), uint8(242), uint8(146), uint8(53), uint8(42), uint8(100), uint8(54), uint8(206), uint8(188), uint8(111), uint8(75), uint8(64), uint8(1), uint8(0), uint8(33), uint8(137), uint8(128), uint8(232), uint8(18), uint8(63), uint8(1), uint8(47), uint8(236), uint8(187), uint8(28), uint8(200), uint8(100), uint8(210), uint8(195), uint8(0), uint8(98), uint8(67), uint8(232), uint8(224), uint8(137), uint8(246), uint8(90), uint8(184), uint8(10), uint8(253), uint8(245), uint8(96), uint8(5), uint8(132), uint8(50), uint8(201), uint8(128), uint8(12), uint8(128), uint8(29), uint8(116), uint8(112), uint8(68), uint8(12), uint8(1), uint8(50), uint8(186), uint8(240), uint8(33), uint8(131), uint8(20), uint8(3), uint8(75), uint8(237), uint8(226), uint8(97), uint8(97), uint8(140), uint8(55), uint8(51), uint8(139), uint8(196), uint8(74), uint8(144), uint8(202), uint8(168), uint8(140), uint8(206), uint8(246), uint8(41), uint8(38), uint8(141), uint8(63), uint8(5), uint8(95), uint8(22), uint8(76), uint8(0), uint8(203), uint8(1), uint8(78), uint8(16), uint8(159), uint8(240), uint8(228), uint8(158), uint8(23), uint8(136), uint8(26), uint8(231), uint8(159), uint8(214), uint8(96), uint8(12), uint8(242), uint8(123), uint8(116), uint8(12), uint8(195), uint8(221), uint8(201), uint8(205), uint8(38), uint8(13), uint8(64), uint8(107), uint8(140), uint8(238), uint8(194), uint8(72), uint8(183), uint8(104), uint8(3), uint8(210), uint8(16), uint8(106), uint8(55), uint8(79), uint8(43), uint8(176), uint8(243), uint8(240), uint8(229), uint8(252), uint8(173), uint8(100), uint8(3), uint8(160), uint8(19), uint8(129), uint8(66), uint8(26), uint8(138), uint8(13), uint8(71), uint8(231), uint8(49), uint8(201), uint8(237), uint8(157), uint8(72), uint8(237), uint8(253), uint8(230), uint8(0), uint8(208), uint8(4), uint8(32), uint8(84), uint8(48), uint8(172), uint8(82), uint8(11), uint8(100), uint8(103), uint8(108), uint8(49), uint8(6), uint8(255), uint8(205), uint8(206), uint8(125), uint8(206), uint8(38), uint8(0), uint8(196), uint8(12), uint8(129), uint8(230), uint8(15), uint8(114), uint8(37), uint8(213), uint8(1), uint8(128), uint8(6), uint8(247), uint8(60), uint8(6), uint8(0), uint8(27), uint8(222), uint8(216), uint8(8), uint8(67), uint8(16), uint8(255), uint8(182), uint8(117), uint8(156), uint8(171), uint8(80), uint8(12), uint8(73), uint8(133), uint8(63), uint8(227), uint8(54), uint8(235), uint8(94), uint8(81), uint8(227), uint8(216), uint8(240), uint8(251), uint8(208), uint8(3), uint8(16), uint8(19), uint8(22), uint8(133), uint8(252), uint8(223), uint8(139), uint8(203), uint8(56), uint8(90), uint8(154), uint8(176), uint8(152), uint8(76), uint8(45), uint8(5), uint8(239), uint8(242), uint8(150), uint8(110), uint8(29), uint8(115), uint8(3), uint8(109), uint8(33), uint8(168), uint8(206), uint8(242), uint8(38), uint8(0), uint8(102), uint8(95), uint8(40), uint8(149), uint8(246), uint8(59), uint8(231), uint8(89), uint8(220), uint8(62), uint8(245), uint8(128), uint8(169), uint8(12), uint8(10), uint8(128), uint8(152), uint8(10), uint8(36), uint8(10), uint8(33), uint8(40), uint8(44), uint8(51), uint8(163), uint8(163), uint8(1), uint8(157), uint8(249), uint8(104), uint8(71), uint8(204), uint8(217), uint8(59), uint8(237), uint8(216), uint8(199), uint8(66), uint8(142), uint8(190), uint8(165), uint8(112), uint8(6), uint8(96), uint8(23), uint8(128), uint8(192), uint8(1), uint8(240), uint8(102), uint8(13), uint8(1), uint8(216), uint8(105), uint8(41), uint8(9), uint8(44), uint8(162), uint8(97), uint8(91), uint8(32), uint8(178), uint8(203), uint8(13), uint8(13), uint8(47), uint8(178), uint8(3), uint8(3), uint8(3), uint8(3), uint8(16), uint8(144), uint8(208), uint8(210), uint8(249), uint8(136), uint8(41), uint8(31), uint8(182), uint8(252), uint8(237), uint8(98), uint8(72), uint8(6), uint8(9), uint8(200), uint8(253), uint8(9), uint8(27), uint8(199), uint8(51), uint8(56), uint8(127), uint8(77), uint8(222), uint8(4), uint8(13), uint8(64), uint8(24), uint8(0), uint8(236), uint8(4), uint8(192), uint8(15), uint8(192), uint8(22), uint8(0), uint8(106), uint8(89), uint8(96), uint8(7), uint8(4), uint8(34), uint8(96), uint8(0), uint8(156), uint8(132), uint8(88), uint8(6), uint8(189), uint8(8), uint8(13), uint8(40), uint8(4), uint8(196), uint8(208), uint8(19), uint8(128), uint8(235), uint8(19), uint8(0), uint8(160), uint8(104), uint8(106), uint8(29), uint8(137), uint8(64), uint8(55), uint8(103), uint8(73), uint8(108), uint8(25), uint8(187), uint8(98), uint8(211), uint8(158), uint8(243), uint8(192), uint8(27), uint8(0), uint8(192), uint8(48), uint8(3), uint8(16), uint8(24), uint8(160), uint8(49), uint8(41), uint8(232), uint8(71), uint8(65), uint8(53), uint8(42), uint8(61), uint8(60), uint8(162), uint8(97), uint8(101), uint8(160), uint8(49), uint8(1), uint8(9), uint8(227), uint8(67), uint8(82), uint8(140), uint8(82), uint8(25), uint8(9), uint8(238), uint8(149), uint8(33), uint8(61), uint8(87), uint8(152), uint8(2), uint8(112), uint8(4), uint8(96), uint8(48), uint8(192), uint8(38), uint8(73), uint8(52), uint8(4), uint8(196), uint8(210), uint8(97), uint8(52), uint8(55), uint8(6), uint8(147), uint8(10), uint8(197), uint8(36), uint8(35), uint8(236), uint8(88), uint8(105), uint8(72), uint8(44), uint8(155), uint8(202), uint8(47), uint8(147), uint8(63), uint8(40), uint8(152), uint8(82), uint8(120), uint8(106), uint8(123), uint8(161), uint8(12), uint8(142), uint8(229), uint8(163), uint8(63), uint8(215), uint8(199), uint8(0), uint8(96), uint8(0), uint8(196), uint8(3), uint8(0), uint8(19), uint8(0), uint8(96), uint8(66), uint8(38), uint8(19), uint8(72), uint8(99), uint8(11), uint8(65), uint8(45), uint8(241), uint8(40), uint8(55), uint8(179), uint8(134), uint8(167), uint8(229), uint8(160), uint8(175), uint8(142), uint8(227), uint8(236), uint8(192), uint8(131), uint8(194), uint8(0), uint8(224), uint8(17), uint8(126), uint8(1), uint8(40), uint8(16), uint8(134), uint8(9), uint8(160), uint8(151), uint8(165), uint8(165), uint8(224), uint8(134), uint8(128), uint8(52), uint8(2), uint8(129), uint8(165), uint8(164), uint8(190), uint8(144), uint8(215), uint8(74), uint8(122), uint8(123), uint8(116), uint8(51), uint8(254), uint8(224), uint8(74), uint8(253), uint8(132), uint8(4), uint8(0), uint8(129), uint8(134), uint8(0), uint8(220), uint8(3), uint8(64), uint8(24), uint8(1), uint8(64), uint8(29), uint8(20), uint8(66), uint8(0), uint8(203), uint8(148), uint8(5), uint8(9), uint8(129), uint8(132), uint8(196), uint8(116), uint8(134), uint8(16), uint8(250), uint8(122), uint8(3), uint8(17), uint8(145), uint8(186), uint8(88), uint8(10), uint8(236), uint8(237), uint8(150), uint8(219), uint8(94), uint8(96), uint8(65), uint8(194), uint8(0), uint8(36), uint8(4), uint8(95), uint8(0), uint8(74), uint8(9), uint8(1), uint8(8), uint8(38), uint8(131), uint8(208), uint8(16), uint8(112), uint8(128), uint8(9), uint8(1), uint8(23), uint8(192), uint8(18), uint8(130), uint8(64), uint8(66), uint8(9), uint8(160), uint8(247), uint8(208), uint8(0), uint8(30), uint8(2), uint8(39), uint8(224), uint8(8), uint8(136), uint8(180), uint8(0), uint8(122), uint8(8), uint8(128), uint8(128), uint8(35), uint8(34), uint8(88), uint8(128), uint8(26), uint8(0), uint8(92), uint8(8), uint8(60), uint8(96), uint8(130), uint8(44), uint8(74), uint8(1), uint8(56), uint8(35), uint8(252), uint8(128), uint8(31), uint8(147), uint8(1), uint8(20), uint8(32), uint8(2), uint8(208), uint8(9), uint8(128), uint8(15), uint8(0), uint8(68), uint8(3), uint8(145), uint8(119), uint8(243), uint8(248), uint8(0), uint8(136), uint8(1), uint8(192), uint8(32), uint8(238), uint8(2), uint8(8), uint8(232), uint8(24), uint8(0), uint8(204), uint8(17), uint8(254), uint8(0), uint8(14), uint8(200), uint8(64), uint8(138), uint8(20), uint8(0), uint8(126), uint8(8), uint8(96), uint8(160), uint8(6), uint8(192), uint8(34), uint8(1), uint8(200), uint8(177), uint8(87), uint8(231), uint8(1), uint8(6), uint8(140), uint8(16), uint8(14), uint8(65), uint8(23), uint8(160), uint8(18), uint8(131), uint8(64), uint8(30), uint8(130), uint8(104), uint8(93), uint8(1), uint8(6), uint8(140), uint8(16), uint8(14), uint8(65), uint8(23), uint8(160), uint8(18), uint8(131), uint8(64), uint8(30), uint8(130), uint8(104), uint8(93), uint8(246), uint8(218), uint8(95), uint8(34), uint8(8), uint8(40), uint8(192), uint8(12), uint8(1), uint8(23), uint8(228), uint8(2), uint8(240), uint8(73), uint8(252), uint8(2), uint8(128), uint8(154), uint8(17), uint8(125), uint8(200), uint8(1), uint8(184), uint8(104), uint8(228), uint8(5), uint8(114), uint8(13), uint8(254), uint8(76), uint8(47), uint8(128), uint8(96), uint8(26), uint8(95), uint8(45), uint8(43), uint8(79), uint8(103), uint8(224), uint8(41), uint8(51), uint8(49), uint8(138), uint8(58), uint8(33), uint8(133), uint8(129), uint8(64), uint8(192), uint8(68), uint8(251), uint8(112), uint8(72), uint8(3), uint8(78), uint8(180), uint8(210), uint8(254), uint8(159), uint8(4), uint8(27), uint8(96), uint8(5), uint8(172), uint8(192), uint8(22), uint8(0), uint8(96), uint8(194), uint8(195), uint8(0), uint8(175), uint8(4), uint8(207), uint8(139), uint8(195), uint8(0), uint8(169), uint8(76), uint8(75), uint8(13), uint8(248), uint8(119), uint8(251), uint8(156), uint8(57), uint8(74), uint8(14), uint8(176), uint8(66), uint8(0), uint8(37), uint8(0), uint8(96), uint8(1), uint8(142), uint8(47), uint8(129), uint8(64), uint8(24), uint8(146), uint8(192), uint8(192), uint8(193), uint8(160), uint8(20), uint8(1), uint8(84), uint8(48), uint8(211), uint8(137), uint8(33), uint8(153), uint8(206), uint8(231), uint8(87), uint8(0), uint8(236), uint8(0), uint8(180), uint8(1), uint8(176), uint8(97), uint8(36), uint8(6), uint8(44), uint8(9), uint8(0), uint8(164), uint8(49), uint8(67), uint8(131), uint8(47), uint8(121), uint8(38), uint8(1), uint8(217), uint8(55), uint8(21), uint8(138), uint8(26), uint8(17), uint8(142), uint8(205), uint8(141), uint8(238), uint8(57), uint8(207), uint8(188), uint8(156), uint8(8), uint8(26), uint8(224), uint8(14), uint8(209), uint8(194), uint8(10), uint8(0), uint8(211), uint8(225), uint8(220), uint8(48), uint8(154), uint8(225), uint8(96), uint8(21), uint8(172), uint8(43), uint8(95), uint8(163), uint8(150), uint8(8), uint8(22), uint8(192), uint8(33), uint8(2), uint8(164), uint8(198), uint8(38), uint8(128), uint8(128), uint8(10), uint8(32), uint8(154), uint8(221), uint8(203), uint8(40), uint8(151), uint8(202), uint8(79), uint8(117), uint8(0), uint8(163), uint8(151), uint8(146), uint8(140), uint8(48), uint8(254), uint8(6), uint8(82), uint8(188), uint8(114), uint8(213), uint8(126), uint8(52), uint8(160), uint8(64), uint8(215), uint8(0), uint8(89), uint8(206), uint8(1), uint8(56), uint8(37), uint8(3), uint8(1), uint8(80), uint8(77), uint8(5), uint8(170), uint8(40), uint8(0), uint8(164), uint8(1), uint8(151), uint8(56), uint8(6), uint8(32), uint8(148), uint8(10), uint8(67), uint8(4), uint8(208), uint8(75), uint8(234), uint8(96), uint8(23), uint8(2), uint8(6), uint8(56), uint8(20), uint8(44), uint8(10), uint8(148), uint8(80), uint8(14), uint8(192), uint8(96), uint8(0), uint8(124), uint8(76), uint8(227), uint8(70), uint8(144), uint8(192), uint8(110), uint8(144), uint8(209), uint8(140), uint8(143), uint8(240), uint8(22), uint8(40), uint8(10), uint8(13), uint8(239), uint8(217), uint8(10), uint8(57), uint8(222), uint8(243), uint8(224), uint8(11), uint8(128), uint8(22), uint8(128), uint8(92), uint8(0), uint8(204), uint8(12), uint8(128), uint8(27), uint8(16), uint8(192), uint8(45), uint8(1), uint8(176), uint8(194), uint8(88), uint8(22), uint8(13), uint8(40), uint8(97), uint8(44), uint8(104), uint8(192), uint8(9), uint8(202), uint8(67), uint8(184), uint8(206), uint8(115), uint8(223), uint8(46), uint8(0), uint8(68), uint8(1), uint8(153), uint8(12), uint8(3), uint8(80), uint8(208), uint8(194), uint8(96), uint8(9), uint8(241), uint8(48), uint8(152), uint8(90), uint8(64), uint8(241), uint8(93), uint8(191), uint8(53), uint8(78), uint8(89), uint8(111), uint8(113), uint8(130), uint8(6), uint8(144), uint8(6), uint8(0), uint8(129), uint8(110), uint8(8), uint8(6), uint8(97), uint8(137), uint8(33), uint8(128), uint8(49), uint8(0), uint8(38), uint8(224), uint8(48), uint8(2), uint8(133), uint8(6), uint8(20), uint8(77), uint8(44), uint8(4), uint8(37), uint8(16), uint8(131), uint8(64), uint8(78), uint8(1), uint8(161), uint8(49), uint8(1), uint8(164), uint8(208), uint8(27), uint8(21), uint8(137), uint8(160), uint8(26), uint8(128), uint8(104), uint8(2), uint8(114), uint8(24), uint8(9), uint8(137), uint8(133), uint8(164), uint8(53), uint8(145), uint8(131), uint8(11), uint8(13), uint8(64), uint8(107), uint8(165), uint8(1), uint8(1), uint8(40), uint8(123), uint8(230), uint8(210), uint8(148), uint8(190), uint8(34), uint8(253), uint8(18), uint8(253), uint8(184), uint8(3), uint8(192), uint8(68), uint8(252), uint8(1), uint8(17), uint8(22), uint8(128), uint8(15), uint8(65), uint8(16), uint8(16), uint8(4), uint8(100), uint8(75), uint8(77), uint8(47), uint8(56), uint8(16), uint8(72), uint8(65), uint8(11), uint8(140), uint8(16), uint8(122), uint8(128), uint8(15), uint8(193), uint8(32), uint8(28), uint8(6), uint8(192), uint8(140), uint8(16), uint8(1), uint8(96), uint8(4), uint8(224), uint8(100), uint8(4), uint8(96), uint8(56), uint8(21), uint8(127), uint8(36), uint8(130), uint8(9), uint8(80), uint8(33), uint8(110), uint8(2), uint8(15), uint8(32), uint8(1), uint8(200), uint8(36), uint8(4), uint8(0), uint8(88), uint8(8), uint8(193), uint8(64), uint8(7), uint8(192), uint8(135), uint8(246), uint8(3), uint8(112), uint8(17), uint8(128), uint8(224), uint8(80), uint8(187), uint8(250), uint8(13), uint8(41), uint8(75), uint8(225), uint8(175), uint8(214), uint8(47), uint8(242), uint8(181), uint8(41), uint8(75), uint8(251), uint8(130), uint8(249), uint8(187), uint8(250), uint8(13), uint8(41), uint8(75), uint8(230), uint8(111), uint8(220), uint8(47), uint8(232), uint8(20), uint8(165), uint8(47), uint8(155), uint8(191), uint8(140), uint8(96), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(87), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(153), uint8(144), uint8(64), uint8(100), uint8(60), uint8(114), uint8(199), uint8(241), uint8(218), uint8(78), uint8(25), uint8(202), uint8(47), uint8(244), uint8(140), uint8(249), uint8(178), uint8(16), uint8(190), uint8(53), uint8(207), uint8(207), uint8(142), uint8(108), uint8(61), uint8(117), uint8(142), uint8(193), uint8(70), uint8(54), uint8(51), uint8(57), uint8(24), uint8(112), uint8(141), uint8(208), uint8(240), uint8(16), uint8(39), uint8(0), uint8(212), uint8(158), uint8(108), uint8(160), uint8(179), uint8(67), uint8(135), uint8(158), uint8(73), uint8(196), uint8(225), uint8(47), uint8(167), uint8(32), uint8(115), uint8(12), uint8(90), uint8(220), uint8(73), uint8(236), uint8(44), uint8(110), uint8(72), uint8(74), uint8(42), uint8(96), uint8(71), uint8(97), uint8(172), uint8(123), uint8(227), uint8(241), uint8(134), uint8(31), uint8(190), uint8(248), uint8(215), uint8(99), uint8(206), uint8(36), uint8(39), uint8(196), uint8(103), uint8(2), uint8(3), uint8(205), uint8(19), uint8(197), uint8(18), uint8(126), uint8(177), uint8(252), uint8(242), uint8(57), uint8(198), uint8(9), uint8(49), uint8(190), uint8(18), uint8(149), uint8(165), uint8(18), uint8(77), uint8(1), uint8(118), uint8(24), uint8(133), uint8(10), uint8(86), uint8(63), uint8(236), uint8(161), uint8(166), uint8(37), uint8(52), uint8(0), uint8(61), uint8(99), uint8(192), uint8(103), uint8(28), uint8(30), uint8(172), uint8(78), uint8(111), uint8(204), uint8(216), uint8(64), uint8(238), uint8(221), uint8(56), uint8(147), uint8(83), uint8(0), uint8(131), uint8(26), uint8(224), uint8(53), uint8(56), uint8(225), uint8(74), uint8(136), uint8(139), uint8(117), uint8(242), uint8(126), uint8(253), uint8(223), uint8(115), uint8(220), uint8(121), uint8(196), uint8(143), uint8(224), uint8(26), uint8(143), uint8(39), uint8(129), uint8(192), uint8(60), uint8(46), uint8(67), uint8(191), uint8(78), uint8(199), uint8(230), uint8(86), uint8(22), uint8(20), uint8(28), uint8(181), uint8(143), uint8(61), uint8(58), uint8(204), uint8(83), uint8(246), uint8(110), uint8(111), uint8(24), uint8(227), uint8(17), uint8(220), uint8(227), uint8(88), uint8(243), uint8(76), uint8(217), uint8(246), uint8(150), uint8(178), uint8(118), uint8(49), uint8(248), uint8(207), uint8(212), uint8(194), uint8(183), uint8(248), uint8(86), uint8(125), uint8(153), uint8(134), uint8(212), uint8(204), uint8(156), uint8(98), uint8(135), uint8(138), uint8(193), uint8(102), uint8(11), uint8(1), uint8(238), uint8(128), uint8(232), uint8(176), uint8(25), uint8(152), uint8(123), uint8(24), uint8(208), uint8(112), uint8(226), uint8(122), uint8(143), uint8(88), uint8(243), uint8(86), uint8(102), uint8(26), uint8(180), uint8(98), uint8(224), uint8(15), uint8(28), uint8(140), uint8(120), uint8(163), uint8(212), uint8(112), uint8(77), uint8(11), uint8(52), uint8(40), uint8(229), uint8(17), uint8(178), uint8(151), uint8(217), uint8(240), uint8(15), uint8(52), uint8(2), uint8(254), uint8(114), uint8(132), uint8(43), uint8(11), uint8(29), uint8(197), uint8(140), uint8(169), uint8(128), uint8(64), uint8(136), uint8(22), uint8(79), uint8(39), uint8(167), uint8(192), uint8(64), uint8(136), uint8(22), uint8(79), uint8(39), uint8(39), uint8(64), uint8(64), uint8(3), uint8(183), uint8(21), uint8(206), uint8(115), uint8(218), uint8(3), uint8(107), uint8(231), uint8(14), uint8(118), uint8(81), uint8(17), uint8(135), uint8(156), uint8(240), uint8(11), uint8(4), uint8(227), uint8(22), uint8(225), uint8(98), uint8(98), uint8(113), uint8(162), uint8(71), uint8(97), uint8(93), uint8(205), uint8(20), uint8(204), uint8(16), uint8(237), uint8(83), uint8(0), uint8(98), uint8(3), uint8(0), uint8(19), uint8(16), uint8(192), uint8(79), uint8(201), uint8(160), uint8(22), uint8(33), uint8(4), uint8(160), uint8(29), uint8(0), uint8(232), uint8(10), uint8(128), uint8(156), uint8(6), uint8(36), uint8(50), uint8(105), uint8(12), uint8(152), uint8(3), uint8(160), uint8(29), uint8(0), uint8(152), uint8(4), uint8(192), uint8(48), uint8(71), uint8(44), uint8(7), uint8(96), uint8(59), uint8(1), uint8(56), uint8(12), uint8(64), uint8(118), uint8(26), uint8(76), uint8(1), uint8(128), uint8(9), uint8(128), uint8(116), uint8(76), uint8(70), uint8(26), uint8(89), uint8(12), uint8(10), uint8(147), uint8(67), uint8(10), uint8(202), uint8(195), uint8(73), uint8(105), uint8(70), uint8(243), uint8(4), uint8(147), uint8(0), uint8(160), uint8(21), uint8(64), uint8(72), uint8(20), uint8(1), uint8(57), uint8(51), uint8(16), uint8(192), uint8(96), uint8(67), uint8(203), uint8(12), uint8(1), uint8(217), uint8(9), uint8(37), uint8(164), uint8(172), uint8(77), uint8(2), uint8(133), uint8(128), uint8(224), uint8(154), uint8(76), uint8(229), uint8(148), uint8(94), uint8(193), uint8(165), uint8(116), uint8(238), uint8(146), uint8(147), uint8(156), uint8(106), uint8(62), uint8(128), uint8(27), uint8(128), uint8(232), uint8(2), uint8(236), uint8(0), uint8(212), uint8(1), uint8(144), uint8(2), uint8(240), uint8(11), uint8(146), uint8(3), uint8(16), uint8(29), uint8(22), uint8(76), uint8(66), uint8(64), uint8(27), uint8(0), uint8(57), uint8(2), uint8(160), uint8(10), uint8(0), uint8(66), uint8(76), uint8(13), uint8(224), uint8(48), uint8(0), uint8(74), uint8(3), uint8(160), uint8(5), uint8(192), uint8(33), uint8(0), uint8(51), uint8(1), uint8(137), uint8(8), uint8(154), uint8(26), uint8(24), uint8(1), uint8(168), uint8(6), uint8(5), uint8(140), uint8(1), uint8(1), uint8(9), uint8(1), uint8(160), uint8(59), uint8(0), uint8(62), uint8(65), uint8(52), uint8(176), uint8(10), uint8(193), uint8(15), uint8(236), uint8(2), uint8(192), uint8(42), uint8(0), uint8(117), uint8(2), uint8(8), uint8(193), uint8(12), uint8(49), uint8(0), uint8(128), uint8(114), uint8(8), uint8(5), uint8(160), uint8(14), uint8(0), uint8(40), uint8(1), uint8(208), uint8(12), uint8(64), uint8(48), uint8(38), uint8(128), uint8(20), uint8(147), uint8(72), uint8(96), uint8(13), uint8(16), uint8(148), uint8(147), uint8(64), uint8(168), uint8(2), uint8(192), uint8(40), uint8(0), uint8(220), uint8(1), uint8(154), uint8(64), uint8(47), uint8(0), uint8(184), uint8(3), uint8(0), uint8(11), uint8(201), uint8(169), uint8(13), uint8(47), uint8(240), uint8(16), uint8(240), uint8(29), uint8(23), uint8(128), uint8(118), uint8(196), uint8(210), uint8(128), uint8(116), uint8(3), uint8(180), uint8(0), uint8(152), uint8(134), uint8(3), uint8(14), uint8(3), uint8(176), uint8(40), uint8(87), uint8(74), uint8(0), uint8(168), uint8(21), uint8(136), uint8(64), uint8(101), uint8(241), uint8(99), uint8(57), uint8(44), uint8(52), uint8(160), uint8(6), uint8(160), uint8(48), uint8(0), uint8(200), uint8(178), uint8(22), uint8(38), uint8(23), uint8(128), uint8(44), uint8(1), uint8(48), uint8(21), uint8(0), uint8(104), uint8(1), uint8(136), uint8(5), uint8(224), uint8(6), uint8(165), uint8(134), uint8(167), uint8(185), uint8(121), uint8(32), uint8(49), uint8(1), uint8(129), uint8(64), uint8(32), uint8(220), uint8(48), uint8(10), uint8(0), uint8(29), uint8(6), uint8(114), uint8(246), uint8(72), uint8(6), uint8(60), uint8(4), uint8(37), uint8(128), uint8(27), uint8(6), uint8(68), uint8(48), uint8(49), uint8(242), uint8(67), uint8(50), uint8(113), uint8(40), uint8(48), uint8(52), uint8(1), uint8(128), uint8(9), uint8(192), uint8(47), uint8(12), uint8(2), uint8(188), uint8(154), uint8(142), uint8(1), uint8(104), uint8(8), uint8(64), uint8(116), uint8(0), uint8(188), uint8(2), uint8(224), uint8(7), uint8(192), uint8(2), uint8(98), uint8(131), uint8(17), uint8(152), uint8(51), uint8(160), uint8(4), uint8(192), uint8(33), uint8(44), uint8(3), uint8(62), uint8(6), uint8(64), uint8(168), uint8(1), uint8(184), uint8(110), uint8(12), uint8(252), uint8(160), uint8(7), uint8(200), uint8(0), uint8(208), uint8(48), uint8(0), uint8(212), uint8(54), uint8(160), uint8(75), uint8(224), uint8(134), uint8(220), uint8(103), uint8(30), uint8(31), uint8(35), uint8(141), uint8(26), uint8(134), uint8(64), uint8(212), uint8(113), uint8(163), uint8(82), uint8(249), uint8(4), uint8(165), uint8(41), uint8(93), uint8(125), uint8(214), uint8(21), uint8(82), uint8(200), uint8(160), uint8(45), uint8(39), uint8(219), uint8(252), uint8(20), uint8(68), uint8(11), uint8(39), uint8(212), uint8(37), uint8(147), uint8(159), uint8(160), uint8(212), uint8(1), uint8(185), uint8(49), uint8(138), uint8(212), uint8(21), uint8(196), uint8(41), uint8(70), uint8(10), uint8(226), uint8(200), uint8(214), uint8(80), uint8(55), uint8(106), uint8(110), uint8(60), uint8(61), uint8(100), uint8(227), uint8(34), uint8(12), uint8(144), uint8(176), uint8(58), uint8(122), uint8(135), uint8(217), uint8(61), uint8(78), uint8(35), uint8(59), uint8(44), uint8(220), uint8(177), uint8(67), uint8(135), uint8(235), uint8(115), uint8(8), uint8(105), uint8(38), uint8(240), uint8(208), uint8(222), uint8(26), uint8(77), uint8(1), uint8(79), uint8(238), uint8(52), uint8(15), uint8(45), uint8(190), uint8(3), uint8(200), uint8(101), uint8(43), uint8(135), uint8(73), uint8(67), uint8(58), uint8(251), uint8(55), uint8(192), uint8(27), uint8(64), uint8(3), uint8(216), uint8(0), uint8(123), uint8(77), uint8(177), uint8(217), uint8(142), uint8(1), uint8(246), uint8(84), uint8(141), uint8(182), uint8(57), uint8(71), uint8(43), uint8(0), uint8(240), uint8(118), uint8(59), uint8(7), uint8(106), uint8(129), uint8(103), uint8(207), uint8(240), uint8(31), uint8(65), uint8(248), uint8(140), uint8(179), uint8(142), uint8(129), uint8(143), uint8(254), uint8(86), uint8(202), uint8(208), uint8(224), uint8(15), uint8(0), uint8(209), uint8(242), uint8(22), uint8(2), uint8(178), uint8(73), uint8(217), uint8(148), uint8(102), uint8(60), uint8(112), uint8(15), uint8(69), uint8(146), uint8(25), uint8(26), uint8(194), uint8(230), uint8(0), uint8(232), uint8(4), uint8(192), uint8(134), uint8(10), uint8(2), uint8(52), uint8(145), uint8(226), uint8(16), uint8(14), uint8(192), uint8(118), uint8(5), uint8(0), uint8(64), uint8(5), uint8(3), uint8(64), uint8(98), uint8(3), uint8(18), uint8(241), uint8(48), uint8(132), uint8(76), uint8(206), uint8(146), uint8(251), uint8(243), uint8(248), uint8(196), uint8(20), uint8(130), uint8(144), uint8(229), uint8(134), uint8(134), uint8(150), uint8(95), uint8(197), uint8(19), uint8(3), uint8(3), uint8(17), uint8(195), uint8(73), uint8(161), uint8(169), uint8(64), uint8(96), uint8(102), uint8(73), uint8(105), uint8(218), uint8(1), uint8(209), uint8(72), uint8(13), uint8(33), uint8(19), uint8(50), uint8(10), uint8(64), uint8(13), uint8(215), uint8(223), uint8(186), uint8(3), uint8(8), uint8(238), uint8(240), uint8(6), uint8(64), uint8(59), uint8(0), uint8(188), uint8(1), uint8(96), uint8(6), uint8(137), uint8(64), uint8(104), uint8(2), uint8(210), uint8(24), uint8(6), uint8(128), uint8(80), uint8(160), uint8(204), uint8(5), uint8(120), uint8(20), uint8(72), uint8(6), uint8(160), uint8(97), uint8(138), uint8(0), uint8(199), uint8(128), uint8(96), uint8(3), uint8(16), uint8(3), uint8(192), uint8(10), uint8(185), uint8(121), uint8(128), uint8(14), uint8(194), uint8(120), uint8(13), uint8(185), uint8(48), uint8(2), uint8(156), uint8(19), uint8(247), uint8(216), uint8(108), uint8(148), uint8(190), uint8(255), uint8(129), uint8(130), uint8(104), uint8(21), uint8(1), uint8(207), uint8(196), uint8(192), uint8(41), uint8(156), uint8(10), uint8(144), uint8(219), uint8(37), uint8(56), uint8(152), uint8(24), uint8(164), uint8(129), uint8(114), uint8(217), uint8(176), uint8(22), uint8(45), uint8(159), uint8(240), uint8(48), uint8(91), uint8(125), uint8(0), uint8(98), uint8(2), uint8(18), uint8(184), uint8(14), uint8(192), uint8(118), uint8(3), uint8(176), uint8(29), uint8(144), uint8(131), uint8(72), uint8(88), uint8(132), uint8(67), uint8(2), uint8(160), uint8(49), uint8(33), uint8(224), uint8(29), uint8(134), uint8(150), uint8(229), uint8(0), uint8(192), uint8(7), uint8(64), uint8(21), uint8(178), uint8(64), uint8(78), uint8(2), uint8(112), uint8(204), uint8(88), uint8(5), uint8(160), uint8(80), uint8(132), uint8(81), uint8(45), uint8(5), uint8(130), uint8(23), uint8(208), uint8(1), uint8(230), uint8(75), uint8(176), uint8(25), uint8(66), uint8(18), uint8(53), uint8(21), uint8(18), uint8(1), uint8(254), uint8(60), uint8(89), uint8(3), uint8(203), uint8(1), uint8(244), uint8(79), uint8(1), uint8(100), uint8(28), uint8(3), uint8(65), uint8(230), uint8(254), uint8(20), uint8(231), uint8(108), uint8(117), uint8(68), uint8(192), uint8(78), uint8(77), uint8(4), uint8(48), uint8(128), uint8(24), uint8(2), uint8(71), uint8(208), uint8(37), uint8(254), uint8(192), uint8(39), uint8(38), uint8(2), uint8(24), uint8(64), uint8(12), uint8(65), uint8(32), uint8(24), uint8(18), uint8(255), uint8(96), uint8(7), uint8(128), uint8(2), uint8(80), uint8(66), uint8(9), uint8(0), uint8(63), uint8(0), uint8(168), uint8(17), uint8(59), uint8(128), uint8(4), uint8(132), uint8(162), uint8(88), uint8(35), uint8(116), uint8(2), uint8(8), uint8(168), uint8(5), uint8(163), uint8(64), uint8(192), uint8(36), uint8(124), uint8(129), uint8(134), uint8(4), uint8(96), uint8(66), uint8(89), uint8(176), uint8(3), uint8(0), uint8(65), uint8(235), uint8(4), uint8(32), uint8(176), uint8(3), uint8(144), uint8(3), uint8(224), uint8(68), uint8(233), uint8(4), uint8(17), uint8(81), uint8(128), uint8(100), uint8(17), uint8(184), uint8(129), uint8(4), uint8(112), uint8(2), uint8(177), uint8(160), uint8(96), uint8(18), uint8(62), uint8(0), uint8(108), uint8(9), uint8(0), uint8(160), uint8(100), uint8(17), uint8(62), uint8(170), uint8(45), uint8(221), uint8(135), uint8(212), uint8(72), uint8(133), uint8(137), uint8(136), uint8(12), uint8(38), uint8(1), uint8(128), uint8(41), uint8(192), uint8(109), uint8(128), uint8(247), uint8(90), uint8(89), uint8(210), uint8(52), uint8(226), uint8(248), uint8(153), uint8(103), uint8(50), uint8(195), uint8(192), uint8(228), uint8(180), uint8(243), uint8(194), uint8(64), uint8(91), uint8(215), uint8(45), uint8(201), uint8(61), uint8(197), uint8(240), uint8(30), uint8(143), uint8(255), uint8(63), uint8(15), uint8(245), uint8(2), uint8(129), uint8(82), uint8(192), uint8(116), uint8(67), uint8(38), uint8(16), uint8(136), uint8(64), uint8(59), uint8(78), uint8(4), uint8(32), uint8(96), uint8(19), uint8(128), uint8(220), uint8(2), uint8(194), uint8(194), uint8(56), uint8(208), uint8(11), uint8(11), uint8(3), uint8(1), uint8(161), uint8(4), uint8(148), uint8(50), uint8(91), uint8(1), uint8(124), uint8(78), uint8(167), uint8(209), uint8(97), uint8(161), uint8(188), uint8(134), uint8(27), uint8(195), uint8(73), uint8(160), uint8(93), uint8(60), uint8(245), uint8(33), uint8(7), uint8(102), uint8(3), uint8(219), uint8(99), uint8(182), uint8(172), uint8(55), uint8(117), uint8(179), uint8(63), uint8(30), uint8(143), uint8(177), uint8(152), uint8(15), uint8(231), uint8(31), uint8(201), uint8(195), uint8(160), uint8(212), uint8(128), uint8(219), uint8(128), uint8(77), uint8(139), uint8(41), uint8(68), uint8(204), uint8(48), uint8(191), uint8(137), uint8(168), uint8(26), uint8(74), uint8(4), uint8(47), uint8(146), uint8(192), uint8(206), uint8(193), uint8(132), uint8(164), uint8(0), uint8(90), uint8(178), uint8(97), uint8(48), uint8(6), uint8(193), uint8(169), uint8(3), uint8(5), uint8(183), uint8(33), uint8(254), uint8(66), uint8(26), uint8(3), uint8(186), uint8(152), uint8(2), uint8(219), uint8(128), uint8(118), uint8(24), uint8(24), uint8(3), uint8(162), uint8(192), uint8(160), uint8(14), uint8(203), uint8(13), uint8(1), uint8(136), uint8(13), uint8(128), uint8(168), uint8(96), uint8(5), uint8(128), uint8(7), uint8(192), uint8(48), uint8(0), uint8(176), uint8(176), uint8(208), uint8(3), uint8(210), uint8(89), uint8(105), uint8(196), uint8(208), uint8(20), uint8(239), uint8(138), uint8(38), uint8(0), uint8(219), uint8(96), uint8(50), uint8(5), uint8(192), uint8(39), uint8(113), uint8(152), uint8(145), uint8(224), uint8(16), uint8(134), uint8(128), uint8(104), uint8(3), uint8(178), uint8(96), uint8(14), uint8(128), uint8(96), uint8(2), uint8(16), uint8(208), uint8(193), uint8(128), uint8(58), uint8(0), uint8(212), uint8(2), uint8(208), uint8(3), uint8(226), uint8(198), uint8(163), uint8(128), uint8(220), uint8(0), uint8(240), uint8(176), uint8(48), uint8(5), uint8(66), uint8(16), uint8(146), uint8(90), uint8(9), uint8(69), uint8(246), uint8(2), uint8(232), uint8(40), uint8(231), uint8(202), uint8(139), uint8(70), uint8(233), uint8(26), uint8(219), uint8(241), uint8(140), uint8(53), uint8(71), uint8(28), uint8(128), uint8(165), uint8(158), uint8(189), uint8(0), uint8(104), uint8(0), uint8(35), uint8(1), uint8(2), uint8(0), uint8(168), uint8(1), uint8(224), uint8(105), uint8(12), uint8(0), uint8(248), uint8(155), uint8(192), uint8(51), uint8(192), uint8(15), uint8(8), uint8(69), uint8(0), uint8(156), uint8(48), uint8(154), uint8(2), uint8(96), uint8(3), uint8(80), uint8(16), uint8(128), uint8(8), uint8(184), uint8(3), uint8(94), uint8(66), uint8(0), uint8(121), uint8(192), uint8(98), uint8(128), uint8(196), uint8(0), uint8(55), uint8(24), uint8(1), uint8(114), uint8(8), uint8(96), uint8(84), uint8(178), uint8(192), uint8(46), uint8(44), uint8(4), uint8(228), uint8(194), uint8(128), uint8(14), uint8(128), uint8(51), uint8(12), uint8(13), uint8(45), uint8(1), uint8(160), uint8(23), uint8(0), uint8(94), uint8(128), uint8(29), uint8(77), uint8(18), uint8(1), uint8(57), uint8(52), uint8(16), uint8(194), uint8(0), uint8(96), uint8(9), uint8(31), uint8(64), uint8(151), uint8(251), uint8(0), uint8(156), uint8(152), uint8(8), uint8(97), uint8(0), uint8(49), uint8(4), uint8(128), uint8(96), uint8(75), uint8(253), uint8(128), uint8(30), uint8(0), uint8(8), uint8(129), uint8(8), uint8(40), uint8(0), uint8(248), uint8(2), uint8(208), uint8(68), uint8(238), uint8(0), uint8(18), uint8(146), uint8(192), uint8(192), uint8(35), uint8(116), uint8(2), uint8(15), uint8(88), uint8(13), uint8(152), uint8(150), uint8(9), uint8(0), uint8(224), uint8(101), uint8(193), uint8(27), uint8(240), uint8(148), uint8(100), uint8(0), uint8(200), uint8(16), uint8(69), uint8(129), uint8(8), uint8(48), uint8(0), uint8(232), uint8(2), uint8(176), uint8(68), uint8(233), uint8(4), uint8(30), uint8(178), uint8(88), uint8(13), uint8(129), uint8(27), uint8(136), uint8(16), uint8(121), uint8(0), uint8(42), uint8(24), uint8(6), uint8(65), uint8(32), uint8(32), uint8(12), uint8(130), uint8(71), uint8(216), uint8(24), uint8(4), uint8(64), uint8(104), uint8(206), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(151), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(152), uint8(3), uint8(162), uint8(17), uint8(72), uint8(73), uint8(48), uint8(164), uint8(165), uint8(127), uint8(186), uint8(223), uint8(172), uint8(36), uint8(76), uint8(67), uint8(44), uint8(152), uint8(86), uint8(232), uint8(64), uint8(96), uint8(111), uint8(13), uint8(47), uint8(246), uint8(24), uint8(3), uint8(98), uint8(208), uint8(156), uint8(151), uint8(24), uint8(205), uint8(205), uint8(227), uint8(135), uint8(139), uint8(84), uint8(6), uint8(11), uint8(74), uint8(6), uint8(116), uint8(118), uint8(24), uint8(236), uint8(113), uint8(174), uint8(231), uint8(135), uint8(201), uint8(45), uint8(41), uint8(13), uint8(79), uint8(74), uint8(120), uint8(223), uint8(205), uint8(102), uint8(16), uint8(114), uint8(140), uint8(51), uint8(64), uint8(12), uint8(64), uint8(12), uint8(64), uint8(17), uint8(128), uint8(53), uint8(0), uint8(45), uint8(0), uint8(102), uint8(5), uint8(64), uint8(51), uint8(0), uint8(212), uint8(6), uint8(32), uint8(33), uint8(0), uint8(56), uint8(224), uint8(59), uint8(0), uint8(122), uint8(5), uint8(64), uint8(52), uint8(0), uint8(200), uint8(134), uint8(0), uint8(252), uint8(10), uint8(128), uint8(106), uint8(76), uint8(0), uint8(185), uint8(0), uint8(24), uint8(128), uint8(157), uint8(5), uint8(148), uint8(2), uint8(96), uint8(40), uint8(81), uint8(52), uint8(152), uint8(81), uint8(72), uint8(40), uint8(152), uint8(66), uint8(12), uint8(38), uint8(6), uint8(18), uint8(192), uint8(160), uint8(5), uint8(88), uint8(32), uint8(12), uint8(96), uint8(192), uint8(48), uint8(141), uint8(224), uint8(12), uint8(0), uint8(31), uint8(0), uint8(58), uint8(1), uint8(128), uint8(3), uint8(160), uint8(24), uint8(19), uint8(0), uint8(160), uint8(14), uint8(131), uint8(8), uint8(69), uint8(23), uint8(137), uint8(128), uint8(58), uint8(40), uint8(134), uint8(5), uint8(73), uint8(128), uint8(48), uint8(38), uint8(16), uint8(139), uint8(1), uint8(58), uint8(64), uint8(161), uint8(48), uint8(148), uint8(6), uint8(73), uint8(191), uint8(58), uint8(123), uint8(150), uint8(148), uint8(165), uint8(101), uint8(129), uint8(247), uint8(229), uint8(175), uint8(212), uint8(204), uint8(227), uint8(199), uint8(129), uint8(206), uint8(44), uint8(248), uint8(0), uint8(117), uint8(39), uint8(39), uint8(231), uint8(192), uint8(77), uint8(92), uint8(88), uint8(15), uint8(248), uint8(153), uint8(204), uint8(30), uint8(60), uint8(5), uint8(144), uint8(246), uint8(1), uint8(144), uint8(16), uint8(105), uint8(61), uint8(153), uint8(92), uint8(75), uint8(137), uint8(30), uint8(105), uint8(239), uint8(255), uint8(25), uint8(143), uint8(213), uint8(19), uint8(66), uint8(58), uint8(88), uint8(105), uint8(120), uint8(97), uint8(163), uint8(9), uint8(63), uint8(5), uint8(5), uint8(145), uint8(38), uint8(3), uint8(164), uint8(1), uint8(97), uint8(114), uint8(185), uint8(4), uint8(6), uint8(85), uint8(190), uint8(236), uint8(96), uint8(213), uint8(173), uint8(73), uint8(0), uint8(139), uint8(132), uint8(184), uint8(112), uint8(85), uint8(76), uint8(112), uint8(23), uint8(192), uint8(30), uint8(192), uint8(228), uint8(3), uint8(3), uint8(96), uint8(12), uint8(13), uint8(31), uint8(224), uint8(112), uint8(227), uint8(160), uint8(115), uint8(255), uint8(169), uint8(113), uint8(48), uint8(7), uint8(85), uint8(48), uint8(4), uint8(0), uint8(59), uint8(0), uint8(204), uint8(10), uint8(0), uint8(192), uint8(154), uint8(2), uint8(96), uint8(29), uint8(6), uint8(128), uint8(220), uint8(176), uint8(19), uint8(128), uint8(98), uint8(77), uint8(0), uint8(176), uint8(3), uint8(32), uint8(16), uint8(0), uint8(152), uint8(6), uint8(0), uint8(49), uint8(0), uint8(204), uint8(3), uint8(80), uint8(19), uint8(134), uint8(228), uint8(18), uint8(250), uint8(0), uint8(160), uint8(8), uint8(0), uint8(52), uint8(38), uint8(1), uint8(80), uint8(24), uint8(147), uint8(73), uint8(72), uint8(1), uint8(207), uint8(65), uint8(51), uint8(160), uint8(174), uint8(89), uint8(88), uint8(191), uint8(185), uint8(101), uint8(100), uint8(206), uint8(16), uint8(26), uint8(5), uint8(72), uint8(73), uint8(195), uint8(8), uint8(96), uint8(38), uint8(38), uint8(240), uint8(40), uint8(3), uint8(18), uint8(103), uint8(81), uint8(52), uint8(7), uint8(64), uint8(85), uint8(8), uint8(66), uint8(121), uint8(8), uint8(10), uint8(148), uint8(73), uint8(38), uint8(6), uint8(228), uint8(22), uint8(82), uint8(120), uint8(97), uint8(99), uint8(19), uint8(144), uint8(90), uint8(59), uint8(50), uint8(116), uint8(0), uint8(224), uint8(134), uint8(0), uint8(228), uint8(152), uint8(0), uint8(216), uint8(1), uint8(56), uint8(2), uint8(2), uint8(203), uint8(2), uint8(128), uint8(59), uint8(2), uint8(128), uint8(84), uint8(6), uint8(37), uint8(128), uint8(59), uint8(0), uint8(208), uint8(6), uint8(0), uint8(6), uint8(32), uint8(25), uint8(0), uint8(156), uint8(10), uint8(0), uint8(152), uint8(3), uint8(48), uint8(5), uint8(201), uint8(1), uint8(216), uint8(6), uint8(9), uint8(41), uint8(32), uint8(48), uint8(0), uint8(208), uint8(52), uint8(3), uint8(16), uint8(11), uint8(128), uint8(27), uint8(128), uint8(58), uint8(64), uint8(14), uint8(192), uint8(23), uint8(160), uint8(16), uint8(130), uint8(112), uint8(105), uint8(52), uint8(3), uint8(34), uint8(192), uint8(49), uint8(66), uint8(8), uint8(73), uint8(64), uint8(3), uint8(194), uint8(104), uint8(20), uint8(72), uint8(105), uint8(15), uint8(196), uint8(48), uint8(12), uint8(74), uint8(96), uint8(4), uint8(224), uint8(5), uint8(100), uint8(220), uint8(66), uint8(38), uint8(146), uint8(128), uint8(118), uint8(0), uint8(148), uint8(4), uint8(36), uint8(50), uint8(96), uint8(3), uint8(240), uint8(222), uint8(232), uint8(0), uint8(86), uint8(24), uint8(3), uint8(96), uint8(29), uint8(19), uint8(48), uint8(3), uint8(112), uint8(41), uint8(202), uint8(12), uint8(12), uint8(1), uint8(130), uint8(73), uint8(137), uint8(225), uint8(156), uint8(3), uint8(47), uint8(192), uint8(50), uint8(64), uint8(1), uint8(224), uint8(5), uint8(96), uint8(25), uint8(16), uint8(198), uint8(100), uint8(6), uint8(129), uint8(144), uint8(194), uint8(162), uint8(105), uint8(101), uint8(114), uint8(128), uint8(15), uint8(156), uint8(152), uint8(146), uint8(138), uint8(33), uint8(128), uint8(62), uint8(38), uint8(128), uint8(197), uint8(4), uint8(212), uint8(147), uint8(73), uint8(156), uint8(2), uint8(210), uint8(24), uint8(96), uint8(3), uint8(240), uint8(3), uint8(142), uint8(128), uint8(192), uint8(196), uint8(44), uint8(162), uint8(17), uint8(68), uint8(192), uint8(69), uint8(252), uint8(13), uint8(72), uint8(9), uint8(195), uint8(72), uint8(120), uint8(180), uint8(128), uint8(31), uint8(32), uint8(4), uint8(8), uint8(40), uint8(7), uint8(97), uint8(177), uint8(8), uint8(48), uint8(55), uint8(6), uint8(224), uint8(19), uint8(177), uint8(52), uint8(162), uint8(203), uint8(1), uint8(208), uint8(3), uint8(210), uint8(16), uint8(9), uint8(146), uint8(66), uint8(65), uint8(48), uint8(155), uint8(128), uint8(44), uint8(33), uint8(19), uint8(64), uint8(28), uint8(0), uint8(28), uint8(228), uint8(134), uint8(134), uint8(165), uint8(240), uint8(105), uint8(12), uint8(178), uint8(107), uint8(172), uint8(48), uint8(49), uint8(0), uint8(32), uint8(40), uint8(10), uint8(112), uint8(196), uint8(112), uint8(19), uint8(150), uint8(1), uint8(169), uint8(101), uint8(128), uint8(232), uint8(50), uint8(160), uint8(68), uint8(55), uint8(115), uint8(212), uint8(57), uint8(156), uint8(139), uint8(0), uint8(195), uint8(129), uint8(94), uint8(82), uint8(11), uint8(44), uint8(10), uint8(134), uint8(0), uint8(216), uint8(48), uint8(161), uint8(129), uint8(35), uint8(64), uint8(203), uint8(186), uint8(142), uint8(43), uint8(57), uint8(236), uint8(23), uint8(114), uint8(93), uint8(137), uint8(59), uint8(124), uint8(7), uint8(64), uint8(93), uint8(228), uint8(228), uint8(224), uint8(62), uint8(140), uint8(156), uint8(20), uint8(144), uint8(238), uint8(112), uint8(122), uint8(119), uint8(17), uint8(80), uint8(50), uint8(16), uint8(156), uint8(94), uint8(26), uint8(142), uint8(251), uint8(138), uint8(226), uint8(36), uint8(36), uint8(164), uint8(37), uint8(159), uint8(59), uint8(86), uint8(209), uint8(194), uint8(4), uint8(210), uint8(57), uint8(110), uint8(18), uint8(192), uint8(43), uint8(65), uint8(61), uint8(202), uint8(228), uint8(129), uint8(64), uint8(92), uint8(186), uint8(153), uint8(72), uint8(73), uint8(72), uint8(45), uint8(134), uint8(231), uint8(97), uint8(108), uint8(124), uint8(67), uint8(3), uint8(8), uint8(125), uint8(131), uint8(3), uint8(64), uint8(207), uint8(230), uint8(12), uint8(24), uint8(202), uint8(31), uint8(212), uint8(185), uint8(61), uint8(28), uint8(174), uint8(201), uint8(80), uint8(7), uint8(208), uint8(194), uint8(25), uint8(40), uint8(188), uint8(74), uint8(13), uint8(225), uint8(133), uint8(229), uint8(161), uint8(156), uint8(48), uint8(53), uint8(137), uint8(15), uint8(142), uint8(47), uint8(27), uint8(158), uint8(72), uint8(104), uint8(20), uint8(253), uint8(28), uint8(150), uint8(86), uint8(44), uint8(48), uint8(104), uint8(206), uint8(72), uint8(13), uint8(33), uint8(116), uint8(128), uint8(229), uint8(134), uint8(226), uint8(88), uint8(103), uint8(251), uint8(55), uint8(103), uint8(35), uint8(90), uint8(152), uint8(67), uint8(37), uint8(147), uint8(0), uint8(109), uint8(144), uint8(1), uint8(99), uint8(6), uint8(231), uint8(112), uint8(208), uint8(51), uint8(214), uint8(191), uint8(201), uint8(7), uint8(28), uint8(162), uint8(124), uint8(77), uint8(98), uint8(144), uint8(90), uint8(6), uint8(22), uint8(55), uint8(30), uint8(72), uint8(250), uint8(0), uint8(30), uint8(192), uint8(3), uint8(217), uint8(27), uint8(14), uint8(252), uint8(143), uint8(137), uint8(228), uint8(109), uint8(20), uint8(204), uint8(119), uint8(230), uint8(139), uint8(203), uint8(18), uint8(112), uint8(132), uint8(125), uint8(80), uint8(50), uint8(10), uint8(74), uint8(3), uint8(115), uint8(148), uint8(188), uint8(31), uint8(20), uint8(146), uint8(144), uint8(91), uint8(13), uint8(206), uint8(194), uint8(100), uint8(0), uint8(250), uint8(200), uint8(166), uint8(117), uint8(176), uint8(142), uint8(65), uint8(196), uint8(232), uint8(173), uint8(211), uint8(148), uint8(145), uint8(134), uint8(97), uint8(168), uint8(115), uint8(112), uint8(79), uint8(37), uint8(44), uint8(102), uint8(115), uint8(130), uint8(75), uint8(50), uint8(160), uint8(114), uint8(103), uint8(2), uint8(165), uint8(96), uint8(19), uint8(128), uint8(100), uint8(1), uint8(130), uint8(49), uint8(52), uint8(134), uint8(1), uint8(152), uint8(3), uint8(210), uint8(106), uint8(72), uint8(64), uint8(25), uint8(0), uint8(104), uint8(3), uint8(0), uint8(29), uint8(1), uint8(80), uint8(16), uint8(128), uint8(156), uint8(6), uint8(37), uint8(148), uint8(25), uint8(200), uint8(100), uint8(222), uint8(24), uint8(3), uint8(160), uint8(24), uint8(6), uint8(19), uint8(72), uint8(96), uint8(54), uint8(2), uint8(132), uint8(196), uint8(114), uint8(104), uint8(12), uint8(64), uint8(175), uint8(40), uint8(2), uint8(160), uint8(24), uint8(6), uint8(1), uint8(112), uint8(42), uint8(26), uint8(25), uint8(190), uint8(120), uint8(10), uint8(96), uint8(222), uint8(141), uint8(210), uint8(67), uint8(40), uint8(6), uint8(200), uint8(192), uint8(61), uint8(37), uint8(159), uint8(192), uint8(120), uint8(184), uint8(152), uint8(1), uint8(144), uint8(2), uint8(112), uint8(12), uint8(192), uint8(50), uint8(0), uint8(74), uint8(0), uint8(88), uint8(1), uint8(160), uint8(3), uint8(32), uint8(29), uint8(164), uint8(3), uint8(32), uint8(42), uint8(0), uint8(204), uint8(3), uint8(20), uint8(20), uint8(5), uint8(64), uint8(28), uint8(164), uint8(151), uint8(128), uint8(52), uint8(0), uint8(124), uint8(0), uint8(208), uint8(6), uint8(0), uint8(49), uint8(1), uint8(50), uint8(64), uint8(30), uint8(128), uint8(196), uint8(3), uint8(92), uint8(172), uint8(77), uint8(41), uint8(139), uint8(12), uint8(40), uint8(132), uint8(5), uint8(0), uint8(98), uint8(48), uint8(3), uint8(64), uint8(208), uint8(42), uint8(146), uint8(128), uint8(14), uint8(195), uint8(113), uint8(72), uint8(197), uint8(19), uint8(100), uint8(146), uint8(139), uint8(72), uint8(13), uint8(240), uint8(97), uint8(72), uint8(13), uint8(45), uint8(0), uint8(58), uint8(1), uint8(57), uint8(15), uint8(33), uint8(36), uint8(208), uint8(27), uint8(21), uint8(128), uint8(42), uint8(1), uint8(209), uint8(52), uint8(134), uint8(6), uint8(75), uint8(45), uint8(4), uint8(192), uint8(42), uint8(144), uint8(48), uint8(66), uint8(197), uint8(1), uint8(146), uint8(208), uint8(81), uint8(49), uint8(36), uint8(208), uint8(208), uint8(196), uint8(112), uint8(194), uint8(99), uint8(6), uint8(150), uint8(142), uint8(136), uint8(52), uint8(134), uint8(76), uint8(224), uint8(58), uint8(37), uint8(36), uint8(10), uint8(141), uint8(40), uint8(7), uint8(92), uint8(3), uint8(48), uint8(13), uint8(0), uint8(76), uint8(144), uint8(42), uint8(5), uint8(10), uint8(40), uint8(3), uint8(82), uint8(184), uint8(104), uint8(9), uint8(200), uint8(100), uint8(36), uint8(32), uint8(7), uint8(68), uint8(194), uint8(202), uint8(1), uint8(217), uint8(48), uint8(6), uint8(28), uint8(7), uint8(100), uint8(212), uint8(19), uint8(112), uint8(97), uint8(68), uint8(176), uint8(24), uint8(226), uint8(136), uint8(73), uint8(45), uint8(4), uint8(210), uint8(24), uint8(10), uint8(10), uint8(13), uint8(213), uint8(93), uint8(52), uint8(119), uint8(64), uint8(106), uint8(74), uint8(113), uint8(157), uint8(156), uint8(84), uint8(132), uint8(148), uint8(130), uint8(247), uint8(65), uint8(104), uint8(197), uint8(163), uint8(158), uint8(132), uint8(236), uint8(157), uint8(205), uint8(94), uint8(249), uint8(164), uint8(161), uint8(41), uint8(43), uint8(141), uint8(43), uint8(140), uint8(78), uint8(57), uint8(40), uint8(253), uint8(31), uint8(24), uint8(126), uint8(239), uint8(81), uint8(34), uint8(102), uint8(40), uint8(134), uint8(3), uint8(113), uint8(160), uint8(22), uint8(128), uint8(80), uint8(8), uint8(160), uint8(192), uint8(54), uint8(64), uint8(18), uint8(110), uint8(5), uint8(192), uint8(115), uint8(220), uint8(181), uint8(200), uint8(3), uint8(63), uint8(111), uint8(195), uint8(74), uint8(3), uint8(27), uint8(11), uint8(26), uint8(60), uint8(115), uint8(201), uint8(252), uint8(123), uint8(5), uint8(55), uint8(39), uint8(17), uint8(251), uint8(201), uint8(253), uint8(207), uint8(216), uint8(57), uint8(93), uint8(66), uint8(15), uint8(226), uint8(211), uint8(189), uint8(76), uint8(33), uint8(128), uint8(196), uint8(6), uint8(4), uint8(48), uint8(12), uint8(136), uint8(101), uint8(128), uint8(192), uint8(6), uint8(33), uint8(128), uint8(54), uint8(33), uint8(134), uint8(12), uint8(37), uint8(148), uint8(75), uint8(40), uint8(176), uint8(28), uint8(149), uint8(131), uint8(80), uint8(18), uint8(24), uint8(148), uint8(161), uint8(104), uint8(47), uint8(117), uint8(114), uint8(125), uint8(64), uint8(39), uint8(1), uint8(128), uint8(6), uint8(96), uint8(49), uint8(1), uint8(0), uint8(25), uint8(192), uint8(58), uint8(13), uint8(3), uint8(0), uint8(55), uint8(24), uint8(75), uint8(2), uint8(193), uint8(137), uint8(114), uint8(83), uint8(140), uint8(1), uint8(202), uint8(18), uint8(204), uint8(55), uint8(156), uint8(194), uint8(224), uint8(215), uint8(40), uint8(12), uint8(100), uint8(1), uint8(128), uint8(20), uint8(154), uint8(77), uint8(37), uint8(165), uint8(99), uint8(130), uint8(14), uint8(205), uint8(148), uint8(79), uint8(138), uint8(71), uint8(44), uint8(4), uint8(185), uint8(9), uint8(36), uint8(4), uint8(148), uint8(249), uint8(248), uint8(31), uint8(79), uint8(12), uint8(228), uint8(140), uint8(231), uint8(108), uint8(26), uint8(27), uint8(0), uint8(236), uint8(134), uint8(128), uint8(19), uint8(36), uint8(36), uint8(6), uint8(5), uint8(147), uint8(67), uint8(1), uint8(15), uint8(233), uint8(32), uint8(22), uint8(0), uint8(199), uint8(100), uint8(146), uint8(144), uint8(6), uint8(65), uint8(8), uint8(32), uint8(152), uint8(80), uint8(12), uint8(72), uint8(76), uint8(0), uint8(118), uint8(77), uint8(228), uint8(198), uint8(225), uint8(161), uint8(165), uint8(128), uint8(104), uint8(1), uint8(112), uint8(102), uint8(47), uint8(39), uint8(100), uint8(55), uint8(213), uint8(3), uint8(147), uint8(3), uint8(64), uint8(160), uint8(97), uint8(13), uint8(128), uint8(202), uint8(6), uint8(140), uint8(118), uint8(90), uint8(113), uint8(231), uint8(157), uint8(240), uint8(232), uint8(1), uint8(74), uint8(64), uint8(28), uint8(1), uint8(64), uint8(42), uint8(5), uint8(64), uint8(116), uint8(2), uint8(96), uint8(5), uint8(192), uint8(24), uint8(130), uint8(15), uint8(96), uint8(14), uint8(192), uint8(118), uint8(3), uint8(119), uint8(12), uint8(0), uint8(60), uint8(44), uint8(3), uint8(0), uint8(48), uint8(6), uint8(10), uint8(37), uint8(128), uint8(228), uint8(6), uint8(37), uint8(226), uint8(146), uint8(52), uint8(172), uint8(27), uint8(201), uint8(42), uint8(3), uint8(12), uint8(122), uint8(116), uint8(3), uint8(16), uint8(13), uint8(64), uint8(52), uint8(1), uint8(136), uint8(3), uint8(224), uint8(29), uint8(150), uint8(2), uint8(0), uint8(13), uint8(67), uint8(0), uint8(44), uint8(1), uint8(217), uint8(48), uint8(97), uint8(44), uint8(161), uint8(161), uint8(133), uint8(140), uint8(37), uint8(148), uint8(128), uint8(210), uint8(130), uint8(67), uint8(18), uint8(89), uint8(75), uint8(41), uint8(40), uint8(234), uint8(79), uint8(61), uint8(186), uint8(239), uint8(35), uint8(19), uint8(74), uint8(37), uint8(140), uint8(79), uint8(43), uint8(129), uint8(50), uint8(147), uint8(135), uint8(240), uint8(148), uint8(6), uint8(163), uint8(12), uint8(234), uint8(59), uint8(174), uint8(0), uint8(92), uint8(0), uint8(216), uint8(0), uint8(148), uint8(1), uint8(192), uint8(6), uint8(96), uint8(59), uint8(33), uint8(16), uint8(128), uint8(48), uint8(0), uint8(126), uint8(144), uint8(19), uint8(0), uint8(53), uint8(38), uint8(128), uint8(96), uint8(77), uint8(0), uint8(118), uint8(24), uint8(0), uint8(216), uint8(3), uint8(80), uint8(192), uint8(16), uint8(128), uint8(42), uint8(0), uint8(66), uint8(128), uint8(7), uint8(197), uint8(0), uint8(156), uint8(176), uint8(7), uint8(133), uint8(128), uint8(94), uint8(88), uint8(2), uint8(128), uint8(6), uint8(228), uint8(32), uint8(12), uint8(0), uint8(21), uint8(128), uint8(192), uint8(3), uint8(78), uint8(3), uint8(20), uint8(36), uint8(7), uint8(72), uint8(1), uint8(57), uint8(12), uint8(3), uint8(34), uint8(96), uint8(20), uint8(38), uint8(186), uint8(0), uint8(108), uint8(26), uint8(90), uint8(9), uint8(161), uint8(157), uint8(48), uint8(240), uint8(227), uint8(160), uint8(48), uint8(12), uint8(0), uint8(208), uint8(6), uint8(4), uint8(32), uint8(29), uint8(128), uint8(156), uint8(4), uint8(33), uint8(129), uint8(131), uint8(0), uint8(118), uint8(1), uint8(152), uint8(5), uint8(64), uint8(7), uint8(165), uint8(146), uint8(203), uint8(224), uint8(100), uint8(0), uint8(240), uint8(174), uint8(24), uint8(66), uint8(8), uint8(233), uint8(229), uint8(20), uint8(74), uint8(43), uint8(252), uint8(2), uint8(132), uint8(32), uint8(104), uint8(9), uint8(70), uint8(249), uint8(71), uint8(10), uint8(94), uint8(21), uint8(254), uint8(251), uint8(176), uint8(229), uint8(127), uint8(132), uint8(127), uint8(16), uint8(201), uint8(128), uint8(49), uint8(1), uint8(216), uint8(20), uint8(40), uint8(6), uint8(36), uint8(194), uint8(16), uint8(21), uint8(33), uint8(147), uint8(3), uint8(0), uint8(53), uint8(33), uint8(96), uint8(24), uint8(0), uint8(106), uint8(24), uint8(76), uint8(38), uint8(150), uint8(81), uint8(64), uint8(39), uint8(1), uint8(210), uint8(0), uint8(118), uint8(5), uint8(0), uint8(66), uint8(128), uint8(40), uint8(3), uint8(20), uint8(35), uint8(236), uint8(5), uint8(72), uint8(72), uint8(1), uint8(8), uint8(9), uint8(128), uint8(76), uint8(2), uint8(124), uint8(76), uint8(38), uint8(228), uint8(149), uint8(128), uint8(118), uint8(3), uint8(0), uint8(40), uint8(67), uint8(96), uint8(50), uint8(66), uint8(12), uint8(74), uint8(32), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(215), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(152), uint8(106), uint8(217), uint8(133), uint8(105), uint8(35), uint8(59), uint8(37), uint8(32), uint8(121), uint8(31), uint8(100), uint8(175), uint8(101), uint8(164), uint8(145), uint8(155), uint8(241), uint8(165), uint8(157), uint8(201), uint8(25), uint8(219), uint8(29), uint8(88), uint8(225), uint8(96), uint8(118), uint8(1), uint8(248), uint8(182), uint8(128), uint8(63), uint8(80), uint8(26), uint8(3), uint8(94), uint8(6), uint8(191), uint8(243), uint8(221), uint8(99), uint8(206), uint8(245), uint8(1), uint8(3), uint8(48), uint8(8), uint8(122), uint8(237), uint8(92), uint8(236), uint8(51), uint8(9), uint8(112), uint8(26), uint8(192), uint8(207), uint8(255), uint8(41), uint8(78), uint8(78), uint8(32), uint8(84), uint8(122), uint8(124), uint8(251), uint8(1), uint8(254), uint8(225), uint8(236), uint8(123), uint8(15), uint8(35), uint8(216), uint8(7), uint8(171), uint8(96), uint8(245), uint8(145), uint8(101), uint8(225), uint8(249), uint8(68), uint8(227), uint8(186), uint8(199), uint8(41), uint8(149), uint8(197), uint8(77), uint8(3), uint8(151), uint8(131), uint8(63), uint8(12), uint8(1), uint8(136), uint8(21), uint8(2), uint8(197), uint8(1), uint8(64), uint8(12), uint8(128), uint8(96), uint8(77), uint8(0), uint8(204), uint8(4), uint8(224), uint8(84), uint8(154), uint8(26), uint8(80), uint8(20), uint8(1), uint8(208), uint8(12), uint8(0), uint8(76), uint8(5), uint8(51), uint8(134), uint8(144), uint8(192), uint8(168), uint8(21), uint8(38), uint8(150), uint8(24), uint8(24), uint8(24), uint8(86), uint8(124), uint8(82), uint8(6), uint8(165), uint8(0), uint8(55), uint8(33), uint8(134), uint8(147), uint8(0), uint8(160), uint8(96), uint8(210), uint8(25), uint8(52), uint8(152), uint8(24), uint8(152), uint8(180), uint8(240), uint8(147), uint8(198), uint8(145), uint8(186), uint8(154), uint8(0), uint8(118), uint8(148), uint8(128), uint8(48), uint8(44), uint8(16), uint8(14), uint8(129), uint8(3), uint8(24), uint8(1), uint8(160), uint8(5), uint8(224), uint8(58), uint8(0), uint8(200), uint8(3), uint8(16), uint8(24), uint8(128), uint8(156), uint8(3), uint8(32), uint8(12), uint8(0), uint8(66), uint8(0), uint8(208), uint8(1), uint8(144), uint8(9), uint8(195), uint8(67), uint8(9), uint8(132), uint8(48), uint8(7), uint8(96), uint8(59), uint8(0), uint8(104), uint8(144), uint8(12), uint8(192), uint8(53), uint8(1), uint8(136), uint8(14), uint8(128), uint8(29), uint8(16), uint8(201), uint8(184), uint8(110), uint8(0), uint8(119), uint8(192), uint8(64), uint8(1), uint8(104), uint8(1), uint8(225), uint8(64), uint8(38), uint8(112), uint8(7), uint8(105), uint8(220), uint8(55), uint8(128), uint8(96), uint8(76), uint8(38), uint8(242), uint8(139), uint8(218), uint8(38), uint8(19), uint8(75), uint8(229), uint8(0), uint8(88), uint8(193), uint8(133), uint8(134), uint8(129), uint8(144), uint8(16), uint8(128), uint8(92), uint8(5), uint8(11), uint8(193), uint8(136), uint8(201), uint8(73), uint8(48), uint8(152), uint8(3), uint8(16), uint8(13), uint8(72), uint8(64), uint8(58), uint8(2), uint8(160), uint8(84), uint8(36), uint8(52), uint8(153), uint8(152), uint8(4), uint8(196), uint8(192), uint8(212), uint8(129), uint8(82), uint8(201), uint8(101), uint8(134), uint8(6), uint8(98), uint8(131), uint8(19), uint8(195), uint8(73), uint8(164), uint8(196), uint8(100), uint8(167), uint8(73), uint8(12), uint8(24), uint8(88), uint8(103), uint8(47), uint8(241), uint8(133), uint8(128), uint8(216), uint8(176), uint8(212), uint8(20), uint8(149), uint8(35), uint8(146), uint8(128), uint8(160), uint8(104), uint8(104), uint8(206), uint8(144), uint8(28), uint8(228), uint8(164), uint8(55), uint8(6), uint8(19), uint8(16), uint8(196), uint8(36), uint8(244), uint8(146), uint8(201), uint8(3), uint8(118), uint8(41), uint8(53), uint8(3), uint8(16), uint8(201), uint8(160), uint8(80), uint8(52), uint8(132), uint8(128), uint8(24), uint8(36), uint8(180), uint8(0), uint8(160), uint8(3), uint8(80), uint8(19), uint8(0), uint8(232), uint8(3), uint8(16), uint8(16), uint8(6), uint8(238), uint8(130), uint8(195), uint8(0), uint8(98), uint8(1), uint8(160), uint8(8), uint8(73), uint8(152), uint8(134), uint8(3), uint8(160), uint8(24), uint8(129), uint8(64), uint8(210), uint8(134), uint8(148), uint8(77), uint8(33), uint8(19), uint8(74), uint8(78), uint8(248), uint8(178), uint8(147), uint8(217), uint8(57), uint8(33), uint8(137), uint8(96), uint8(212), uint8(22), uint8(132), uint8(64), uint8(4), uint8(232), uint8(0), uint8(45), uint8(1), uint8(128), uint8(9), uint8(129), uint8(1), uint8(32), uint8(1), uint8(16), uint8(1), uint8(48), uint8(3), uint8(160), uint8(3), uint8(34), uint8(128), uint8(21), uint8(128), uint8(236), uint8(1), uint8(176), uint8(96), uint8(25), uint8(0), uint8(92), uint8(3), uint8(16), uint8(24), uint8(128), uint8(28), uint8(144), uint8(128), uint8(20), uint8(0), uint8(233), uint8(32), uint8(25), uint8(128), uint8(104), uint8(1), uint8(159), uint8(224), uint8(24), uint8(128), uint8(30), uint8(19), uint8(72), uint8(64), uint8(15), uint8(195), uint8(64), uint8(27), uint8(128), uint8(60), uint8(0), uint8(208), uint8(10), uint8(128), uint8(232), uint8(0), uint8(248), uint8(3), uint8(2), uint8(192), uint8(118), uint8(2), uint8(97), uint8(132), uint8(208), uint8(19), uint8(147), uint8(18), uint8(0), uint8(172), uint8(49), uint8(8), uint8(38), uint8(144), uint8(137), uint8(132), uint8(216), uint8(1), uint8(232), uint8(3), uint8(254), uint8(0), uint8(184), uint8(96), uint8(3), uint8(160), uint8(40), uint8(0), uint8(184), uint8(10), uint8(128), uint8(221), uint8(0), uint8(38), uint8(0), uint8(96), uint8(0), uint8(248), uint8(7), uint8(64), uint8(15), uint8(209), uint8(249), uint8(101), uint8(134), uint8(129), uint8(64), uint8(7), uint8(56), uint8(152), uint8(6), uint8(64), uint8(98), uint8(76), uint8(33), uint8(129), uint8(82), uint8(25), uint8(88), uint8(6), uint8(32), uint8(59), uint8(38), uint8(167), uint8(6), uint8(134), uint8(0), uint8(199), uint8(129), uint8(80), uint8(24), uint8(147), uint8(64), uint8(118), uint8(89), uint8(120), uint8(7), uint8(104), uint8(1), uint8(176), uint8(21), uint8(0), uint8(60), uint8(0), uint8(168), uint8(152), uint8(76), uint8(128), uint8(52), uint8(2), uint8(128), uint8(84), uint8(6), uint8(41), uint8(73), uint8(53), uint8(0), uint8(84), uint8(3), uint8(66), uint8(25), uint8(49), uint8(128), uint8(31), uint8(128), uint8(63), uint8(1), uint8(49), uint8(8), uint8(55), uint8(110), uint8(146), uint8(137), uint8(160), uint8(32), uint8(0), uint8(192), uint8(52), uint8(12), uint8(6), uint8(0), uint8(94), uint8(26), uint8(206), uint8(128), uint8(29), uint8(20), uint8(2), uint8(20), uint8(132), uint8(0), uint8(233), uint8(24), uint8(52), uint8(134), uint8(76), uint8(13), uint8(24), uint8(90), uint8(67), uint8(0), uint8(98), uint8(156), uint8(6), uint8(48), uint8(108), uint8(1), uint8(136), uint8(12), uint8(64), uint8(96), uint8(2), uint8(2), uint8(144), uint8(66), uint8(44), uint8(7), uint8(64), uint8(24), uint8(144), uint8(136), uint8(99), uint8(64), uint8(30), uint8(0), uint8(58), uint8(1), uint8(56), uint8(14), uint8(201), uint8(159), uint8(140), uint8(13), uint8(33), uint8(0), uint8(106), uint8(1), uint8(120), uint8(96), uint8(13), uint8(195), uint8(64), uint8(31), uint8(6), uint8(13), uint8(25), uint8(192), uint8(98), uint8(26), uint8(1), uint8(146), uint8(51), uint8(128), uint8(197), uint8(60), uint8(48), uint8(10), uint8(16), uint8(200), uint8(68), uint8(178), uint8(138), uint8(13), uint8(1), uint8(1), uint8(92), uint8(12), uint8(129), uint8(138), uint8(129), uint8(3), uint8(62), uint8(78), uint8(67), uint8(160), uint8(39), uint8(142), uint8(82), uint8(30), uint8(38), uint8(114), uint8(208), uint8(132), uint8(148), uint8(87), uint8(236), uint8(144), uint8(209), uint8(163), uint8(48), uint8(241), uint8(139), uint8(72), uint8(246), uint8(103), uint8(171), uint8(204), uint8(56), uint8(136), uint8(96), uint8(243), uint8(137), uint8(214), uint8(227), uint8(200), uint8(0), uint8(30), uint8(48), uint8(125), uint8(64), uint8(192), uint8(3), uint8(209), uint8(245), uint8(182), uint8(126), uint8(147), uint8(82), uint8(47), uint8(144), uint8(96), uint8(178), uint8(116), uint8(226), uint8(166), uint8(115), uint8(113), uint8(166), uint8(1), uint8(213), uint8(191), uint8(20), uint8(224), uint8(43), uint8(168), uint8(30), uint8(25), uint8(134), uint8(254), uint8(106), uint8(68), uint8(152), uint8(31), uint8(99), uint8(63), uint8(201), uint8(78), uint8(57), uint8(7), uint8(240), uint8(34), uint8(184), uint8(42), uint8(178), uint8(73), uint8(59), uint8(36), uint8(7), uint8(137), uint8(100), uint8(152), uint8(73), uint8(100), uint8(225), uint8(196), uint8(132), uint8(206), uint8(81), uint8(32), uint8(106), uint8(0), uint8(122), uint8(87), uint8(248), uint8(73), uint8(78), uint8(143), uint8(192), uint8(70), uint8(135), uint8(192), uint8(61), uint8(195), uint8(234), uint8(97), uint8(53), uint8(32), uint8(54), uint8(13), uint8(38), uint8(171), uint8(0), uint8(31), uint8(6), uint8(113), uint8(105), uint8(33), uint8(140), uint8(80), uint8(182), uint8(253), uint8(253), uint8(139), uint8(28), uint8(207), uint8(195), uint8(225), uint8(97), uint8(240), uint8(176), uint8(250), uint8(56), uint8(64), uint8(181), uint8(147), uint8(248), uint8(72), uint8(127), uint8(173), uint8(152), uint8(123), uint8(41), uint8(73), uint8(238), uint8(112), uint8(190), uint8(18), uint8(31), uint8(255), uint8(168), uint8(24), uint8(5), uint8(193), uint8(210), uint8(27), uint8(111), uint8(211), uint8(143), uint8(75), uint8(27), uint8(88), uint8(105), uint8(190), uint8(219), uint8(25), uint8(200), uint8(39), uint8(17), uint8(3), uint8(171), uint8(126), uint8(110), uint8(30), uint8(104), uint8(181), uint8(59), uint8(183), uint8(56), uint8(204), uint8(45), uint8(106), uint8(213), uint8(19), uint8(71), uint8(47), uint8(110), uint8(132), uint8(115), uint8(203), uint8(36), uint8(26), uint8(236), uint8(194), uint8(148), uint8(207), uint8(0), uint8(61), uint8(0), uint8(200), uint8(4), uint8(192), uint8(26), uint8(19), uint8(67), uint8(0), uint8(98), uint8(3), uint8(16), uint8(11), uint8(192), uint8(98), uint8(2), uint8(18), uint8(16), uint8(14), uint8(128), uint8(76), uint8(1), uint8(96), uint8(194), uint8(96), uint8(6), uint8(65), uint8(128), uint8(133), uint8(242), uint8(1), uint8(168), uint8(12), uint8(75), uint8(74), uint8(82), uint8(66), uint8(1), uint8(6), uint8(1), uint8(137), uint8(12), uint8(4), uint8(192), uint8(49), uint8(0), uint8(200), uint8(4), uint8(4), uint8(192), uint8(212), uint8(1), uint8(66), uint8(104), uint8(1), uint8(233), uint8(52), uint8(10), uint8(160), uint8(2), uint8(190), uint8(3), uint8(4), uint8(19), uint8(112), uint8(5), uint8(196), uint8(196), uint8(129), uint8(92), uint8(3), uint8(112), uint8(29), uint8(69), uint8(6), uint8(134), uint8(226), uint8(97), uint8(92), uint8(191), uint8(147), uint8(246), uint8(232), uint8(70), uint8(197), uint8(33), uint8(37), uint8(167), uint8(242), uint8(211), uint8(138), uint8(219), uint8(33), uint8(27), uint8(158), uint8(158), uint8(190), uint8(72), uint8(65), uint8(37), uint8(35), uint8(17), uint8(186), uint8(116), uint8(67), uint8(12), uint8(1), uint8(208), uint8(104), uint8(105), uint8(101), uint8(101), uint8(20), uint8(6), uint8(74), uint8(44), uint8(188), uint8(144), uint8(223), uint8(131), uint8(3), uint8(56), uint8(96), uint8(97), uint8(44), uint8(150), uint8(94), uint8(44), uint8(177), uint8(153), uint8(59), uint8(1), uint8(130), uint8(240), uint8(71), uint8(255), uint8(150), uint8(142), uint8(24), uint8(82), uint8(18), uint8(26), uint8(5), uint8(188), uint8(209), uint8(48), uint8(24), uint8(128), uint8(106), uint8(8), uint8(127), uint8(1), uint8(160), uint8(34), uint8(0), uint8(26), uint8(104), uint8(6), uint8(32), uint8(26), uint8(2), uint8(31), uint8(192), uint8(96), uint8(8), uint8(192), uint8(6), uint8(158), uint8(0), uint8(116), uint8(0), uint8(37), uint8(4), uint8(33), uint8(128), uint8(65), uint8(234), uint8(1), uint8(176), uint8(34), uint8(8), uint8(128), uint8(9), uint8(64), uint8(42), uint8(3), uint8(32), uint8(140), uint8(20), uint8(0), uint8(126), uint8(3), uint8(96), uint8(50), uint8(74), uint8(4), uint8(128), uint8(48), uint8(50), uint8(6), uint8(5), uint8(146), uint8(140), uint8(128), uint8(23), uint8(2), uint8(15), uint8(88), uint8(33), uint8(15), uint8(130), uint8(15), uint8(32), uint8(5), uint8(64), uint8(136), uint8(46), uint8(8), uint8(61), uint8(96), uint8(7), uint8(64), uint8(55), uint8(4), uint8(96), uint8(192), uint8(3), uint8(144), uint8(10), uint8(128), uint8(45), uint8(3), uint8(0), uint8(144), uint8(6), uint8(3), uint8(112), uint8(11), uint8(0), uint8(122), uint8(6), uint8(0), uint8(245), uint8(71), uint8(82), uint8(55), uint8(252), uint8(140), uint8(234), uint8(64), uint8(130), uint8(4), uint8(251), uint8(118), uint8(125), uint8(148), uint8(188), uint8(230), uint8(24), uint8(171), uint8(127), uint8(142), uint8(255), uint8(58), uint8(187), uint8(115), uint8(241), uint8(37), uint8(132), uint8(84), uint8(72), uint8(133), uint8(128), uint8(110), uint8(76), uint8(38), uint8(45), uint8(32), uint8(7), uint8(228), uint8(212), uint8(26), uint8(16), uint8(76), uint8(26), uint8(18), uint8(30), uint8(140), uint8(49), uint8(30), uint8(40), uint8(150), uint8(140), uint8(89), uint8(69), uint8(114), uint8(72), uint8(104), uint8(209), uint8(130), uint8(198), uint8(47), uint8(152), uint8(44), uint8(217), uint8(110), uint8(126), uint8(10), uint8(108), uint8(0), uint8(46), uint8(14), uint8(107), uint8(113), uint8(251), uint8(56), uint8(252), uint8(200), uint8(60), uint8(64), uint8(70), uint8(194), uint8(182), uint8(15), uint8(29), uint8(83), uint8(41), uint8(120), uint8(7), uint8(241), uint8(12), uint8(176), uint8(29), uint8(144), uint8(195), uint8(72), uint8(64), uint8(80), uint8(10), uint8(22), uint8(91), uint8(144), uint8(128), uint8(96), uint8(6), uint8(64), uint8(44), uint8(41), uint8(144), uint8(16), uint8(1), uint8(106), uint8(73), uint8(97), uint8(161), uint8(57), uint8(3), uint8(82), uint8(53), uint8(43), uint8(9), uint8(233), uint8(1), uint8(226), uint8(164), uint8(134), uint8(240), uint8(196), uint8(151), uint8(248), uint8(98), uint8(0), uint8(44), uint8(40), uint8(194), uint8(134), uint8(240), uint8(214), uint8(102), uint8(117), uint8(243), uint8(223), uint8(191), uint8(39), uint8(75), uint8(230), uint8(224), uint8(38), uint8(72), uint8(94), uint8(96), uint8(60), uint8(123), uint8(119), uint8(232), uint8(49), uint8(148), uint8(4), uint8(192), uint8(156), uint8(89), uint8(104), uint8(41), uint8(124), uint8(48), uint8(52), uint8(110), uint8(0), uint8(160), uint8(32), uint8(52), uint8(162), uint8(80), uint8(104), uint8(212), uint8(134), uint8(2), uint8(23), uint8(211), uint8(55), uint8(13), uint8(12), uint8(3), uint8(4), uint8(194), uint8(107), uint8(134), uint8(98), uint8(210), uint8(77), uint8(65), uint8(97), uint8(165), uint8(112), uint8(194), uint8(104), uint8(13), uint8(138), uint8(26), uint8(88), uint8(97), uint8(10), uint8(160), uint8(116), uint8(18), uint8(144), uint8(53), uint8(41), uint8(101), uint8(150), uint8(195), uint8(122), uint8(192), uint8(246), uint8(109), uint8(0), uint8(196), uint8(48), uint8(3), uint8(64), uint8(29), uint8(147), uint8(64), uint8(160), uint8(14), uint8(192), uint8(78), uint8(24), uint8(80), uint8(208), uint8(40), uint8(1), uint8(160), uint8(13), uint8(128), uint8(15), uint8(75), uint8(26), uint8(86), uint8(3), uint8(0), uint8(21), uint8(150), uint8(74), uint8(33), uint8(4), uint8(36), uint8(188), uint8(90), uint8(73), uint8(105), uint8(204), uint8(5), uint8(145), uint8(216), uint8(15), uint8(182), uint8(250), uint8(76), uint8(91), uint8(102), uint8(30), uint8(196), uint8(224), uint8(14), uint8(162), uint8(97), uint8(8), uint8(3), uint8(82), uint8(17), uint8(52), uint8(176), uint8(16), uint8(144), uint8(128), uint8(116), uint8(3), uint8(16), uint8(192), uint8(210), uint8(192), uint8(96), uint8(26), uint8(128), uint8(16), uint8(0), uint8(98), uint8(76), uint8(38), uint8(19), uint8(80), uint8(146), uint8(192), uint8(116), uint8(77), uint8(73), uint8(48), uint8(6), uint8(0), uint8(24), uint8(160), uint8(6), uint8(0), uint8(33), uint8(40), uint8(164), uint8(185), uint8(48), uint8(53), uint8(32), uint8(80), uint8(10), uint8(128), uint8(104), uint8(1), uint8(170), uint8(9), uint8(132), uint8(61), uint8(147), uint8(200), uint8(68), uint8(48), uint8(24), uint8(0), uint8(199), uint8(32), uint8(12), uint8(6), uint8(147), uint8(19), uint8(230), uint8(137), uint8(0), uint8(196), uint8(3), uint8(80), uint8(67), uint8(248), uint8(13), uint8(1), uint8(16), uint8(0), uint8(211), uint8(64), uint8(49), uint8(0), uint8(208), uint8(16), uint8(254), uint8(3), uint8(0), uint8(70), uint8(0), uint8(52), uint8(240), uint8(3), uint8(160), uint8(1), uint8(32), uint8(33), uint8(12), uint8(2), uint8(8), uint8(168), uint8(5), uint8(160), uint8(136), uint8(36), uint8(0), uint8(36), uint8(0), uint8(63), uint8(37), uint8(2), uint8(48), uint8(72), uint8(1), uint8(240), uint8(13), uint8(192), uint8(108), uint8(75), uint8(4), uint8(143), uint8(208), uint8(48), uint8(3), uint8(113), uint8(68), uint8(179), uint8(96), uint8(6), uint8(0), uint8(130), uint8(42), uint8(8), uint8(67), uint8(192), uint8(130), uint8(54), uint8(1), uint8(88), uint8(34), uint8(11), uint8(130), uint8(8), uint8(168), uint8(1), uint8(232), uint8(24), uint8(4), uint8(96), uint8(192), uint8(3), uint8(128), uint8(10), uint8(192), uint8(44), uint8(3), uint8(32), uint8(145), uint8(250), uint8(6), uint8(0), uint8(45), uint8(1), uint8(224), uint8(25), uint8(54), uint8(52), uint8(116), uint8(6), uint8(33), uint8(160), uint8(25), uint8(128), uint8(196), uint8(134), uint8(3), uint8(160), uint8(19), uint8(0), uint8(128), uint8(52), uint8(52), uint8(104), uint8(14), uint8(128), uint8(50), uint8(0), uint8(172), uint8(0), uint8(240), uint8(162), uint8(81), uint8(88), uint8(12), uint8(0), uint8(30), uint8(151), uint8(131), uint8(72), uint8(97), uint8(57), uint8(24), uint8(178), uint8(201), uint8(101), uint8(231), uint8(1), uint8(74), uint8(82), uint8(192), uint8(120), uint8(102), uint8(130), uint8(126), uint8(113), uint8(106), uint8(226), uint8(243), uint8(228), uint8(172), uint8(122), uint8(246), uint8(226), uint8(118), uint8(136), uint8(68), uint8(208), uint8(24), uint8(0), uint8(232), uint8(10), uint8(150), uint8(3), uint8(2), uint8(105), uint8(12), uint8(10), uint8(16), uint8(137), uint8(161), uint8(160), uint8(26), uint8(16), uint8(248), uint8(12), uint8(64), uint8(52), uint8(13), uint8(38), uint8(147), uint8(10), uint8(44), uint8(176), uint8(19), uint8(0), uint8(237), uint8(32), uint8(58), uint8(2), uint8(160), uint8(32), uint8(72), uint8(21), uint8(1), uint8(130), uint8(83), uint8(191), uint8(2), uint8(132), uint8(52), uint8(128), uint8(128), uint8(4), uint8(224), uint8(39), uint8(1), uint8(55), uint8(38), uint8(147), uint8(58), uint8(11), uint8(224), uint8(58), uint8(1), uint8(136), uint8(21), uint8(33), uint8(56), uint8(24), uint8(33), uint8(134), uint8(161), uint8(48), uint8(0), uint8(0), uint8(1), uint8(0), uint8(1), uint8(23), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(152), uint8(183), uint8(0), uint8(232), uint8(6), uint8(146), uint8(73), uint8(73), uint8(25), uint8(139), uint8(108), uint8(201), uint8(125), uint8(150), uint8(143), uint8(223), uint8(30), uint8(119), uint8(125), uint8(215), uint8(187), uint8(11), uint8(115), uint8(151), uint8(88), uint8(224), uint8(185), uint8(33), uint8(132), uint8(210), uint8(200), uint8(69), uint8(224), uint8(208), uint8(206), uint8(48), uint8(55), uint8(29), uint8(219), uint8(118), uint8(116), uint8(12), uint8(234), uint8(249), uint8(142), uint8(236), uint8(188), uint8(47), uint8(67), uint8(93), uint8(99), uint8(24), uint8(86), uint8(238), uint8(20), uint8(3), uint8(193), uint8(45), uint8(196), uint8(67), uint8(92), uint8(15), uint8(51), uint8(225), uint8(230), uint8(135), uint8(231), uint8(249), uint8(205), uint8(225), uint8(60), uint8(85), uint8(68), uint8(195), uint8(73), uint8(99), uint8(70), uint8(164), uint8(188), uint8(55), uint8(241), uint8(139), uint8(36), uint8(29), uint8(152), uint8(204), uint8(194), uint8(136), uint8(215), uint8(192), uint8(62), uint8(58), uint8(159), uint8(142), uint8(3), uint8(103), uint8(137), uint8(104), uint8(191), uint8(177), uint8(137), uint8(55), uint8(159), uint8(190), uint8(78), uint8(91), uint8(103), uint8(3), uint8(199), uint8(45), uint8(178), uint8(82), uint8(193), uint8(213), uint8(30), uint8(64), uint8(220), uint8(115), uint8(175), uint8(109), uint8(198), uint8(28), uint8(219), uint8(156), uint8(239), uint8(149), uint8(217), uint8(99), uint8(15), uint8(159), uint8(124), uint8(126), uint8(248), uint8(56), uint8(202), uint8(223), uint8(36), uint8(145), uint8(198), uint8(136), uint8(1), uint8(119), uint8(60), uint8(217), uint8(162), uint8(33), uint8(112), uint8(181), uint8(158), uint8(204), uint8(129), uint8(7), uint8(144), uint8(96), uint8(14), uint8(204), uint8(3), uint8(166), uint8(105), uint8(177), uint8(225), uint8(59), uint8(54), uint8(28), uint8(144), uint8(158), uint8(228), uint8(140), uint8(174), uint8(176), uint8(62), uint8(182), uint8(59), uint8(176), uint8(75), uint8(35), uint8(212), uint8(196), uint8(146), uint8(147), uint8(136), uint8(68), uint8(208), uint8(24), uint8(164), uint8(148), uint8(24), uint8(5), uint8(8), uint8(73), uint8(1), uint8(208), uint8(96), uint8(105), uint8(12), uint8(52), uint8(52), uint8(162), uint8(96), uint8(96), uint8(5), uint8(160), uint8(33), uint8(38), uint8(224), uint8(40), uint8(2), uint8(96), uint8(40), uint8(82), uint8(75), uint8(78), uint8(196), uint8(208), uint8(29), uint8(128), uint8(236), uint8(55), uint8(177), uint8(8), uint8(7), uint8(68), uint8(194), uint8(89), uint8(12), uint8(55), uint8(20), uint8(77), uint8(44), uint8(162), uint8(137), uint8(68), uint8(34), uint8(111), uint8(42), uint8(1), uint8(136), uint8(14), uint8(192), uint8(64), uint8(3), uint8(16), uint8(16), uint8(36), uint8(152), uint8(128), uint8(24), uint8(147), uint8(18), uint8(76), uint8(0), uint8(172), uint8(7), uint8(64), uint8(80), uint8(4), uint8(36), uint8(33), uint8(167), uint8(19), uint8(64), uint8(96), uint8(3), uint8(18), uint8(176), uint8(105), uint8(8), uint8(154), uint8(87), uint8(223), uint8(228), uint8(161), uint8(40), uint8(230), uint8(44), uint8(162), uint8(208), uint8(88), uint8(97), uint8(121), uint8(1), uint8(161), uint8(133), uint8(161), uint8(16), uint8(3), uint8(192), uint8(208), uint8(5), uint8(200), uint8(0), uint8(204), uint8(1), uint8(88), uint8(2), uint8(128), uint8(6), uint8(32), uint8(39), uint8(44), uint8(4), uint8(33), uint8(128), uint8(15), uint8(0), uint8(21), uint8(0), uint8(8), uint8(192), uint8(15), uint8(64), uint8(13), uint8(48), uint8(102), uint8(1), uint8(216), uint8(21), uint8(1), uint8(136), uint8(5), uint8(224), uint8(38), uint8(200), uint8(0), uint8(192), uint8(3), uint8(64), uint8(11), uint8(64), uint8(98), uint8(3), uint8(160), uint8(29), uint8(128), uint8(192), uint8(7), uint8(68), uint8(192), uint8(29), uint8(240), uint8(29), uint8(16), uint8(192), uint8(15), uint8(73), uint8(169), uint8(40), uint8(52), uint8(6), uint8(56), uint8(6), uint8(5), uint8(19), uint8(64), uint8(13), uint8(137), uint8(128), uint8(22), uint8(177), uint8(12), uint8(10), uint8(68), uint8(192), uint8(192), uint8(12), uint8(192), uint8(11), uint8(64), uint8(49), uint8(72), uint8(12), uint8(64), uint8(168), uint8(1), uint8(126), uint8(94), uint8(1), uint8(8), uint8(12), uint8(72), uint8(64), uint8(11), uint8(19), uint8(131), uint8(0), uint8(161), uint8(8), uint8(152), uint8(88), uint8(2), uint8(32), uint8(40), uint8(77), uint8(72), uint8(96), uint8(5), uint8(192), uint8(22), uint8(16), uint8(128), uint8(76), uint8(48), uint8(6), uint8(4), uint8(194), uint8(96), uint8(103), uint8(196), uint8(48), uint8(24), uint8(18), uint8(137), uint8(132), uint8(194), uint8(18), uint8(200), uint8(73), uint8(0), uint8(172), uint8(51), uint8(128), uint8(196), uint8(2), uint8(178), uint8(104), uint8(109), uint8(164), uint8(51), uint8(128), uint8(80), uint8(88), uint8(96), uint8(12), uint8(64), uint8(76), uint8(88), uint8(96), uint8(24), uint8(229), uint8(128), uint8(156), uint8(48), uint8(177), uint8(164), uint8(192), uint8(29), uint8(134), uint8(19), uint8(67), uint8(72), uint8(97), uint8(164), uint8(192), uint8(40), uint8(3), uint8(0), uint8(29), uint8(103), uint8(74), uint8(0), uint8(78), uint8(156), uint8(24), uint8(5), uint8(0), uint8(13), uint8(192), uint8(98), uint8(94), uint8(37), uint8(18), uint8(136), uint8(64), uint8(33), uint8(1), uint8(130), uint8(16), uint8(76), uint8(73), uint8(40), uint8(154), uint8(67), uint8(76), uint8(130), uint8(137), uint8(160), uint8(135), uint8(244), uint8(81), uint8(52), uint8(4), uint8(192), uint8(33), uint8(40), uint8(52), uint8(6), uint8(248), uint8(160), uint8(16), uint8(16), uint8(202), uint8(37), uint8(19), uint8(64), uint8(96), uint8(77), uint8(33), uint8(6), uint8(16), uint8(137), uint8(132), uint8(208), uint8(29), uint8(128), uint8(156), uint8(7), uint8(105), uint8(100), uint8(22), uint8(2), uint8(4), uint8(36), uint8(154), uint8(5), uint8(112), uint8(6), uint8(64), uint8(38), uint8(43), uint8(129), uint8(144), uint8(50), uint8(5), uint8(64), uint8(52), uint8(1), uint8(56), uint8(106), uint8(72), uint8(120), uint8(12), uint8(147), uint8(9), uint8(136), uint8(169), uint8(136), uint8(9), uint8(202), uint8(103), uint8(192), uint8(77), uint8(241), uint8(22), uint8(38), uint8(20), uint8(5), uint8(67), uint8(3), uint8(127), uint8(197), uint8(37), uint8(198), uint8(51), uint8(132), uint8(36), uint8(208), uint8(17), uint8(99), uint8(53), uint8(197), uint8(6), uint8(134), uint8(20), uint8(67), uint8(43), uint8(134), uint8(6), uint8(225), uint8(165), uint8(37), uint8(159), uint8(63), uint8(199), uint8(119), uint8(203), uint8(205), uint8(207), uint8(214), uint8(248), uint8(228), uint8(184), uint8(148), uint8(30), uint8(45), uint8(64), uint8(117), uint8(18), uint8(80), uint8(48), uint8(15), uint8(238), uint8(2), uint8(180), uint8(9), uint8(90), uint8(141), uint8(11), uint8(40), uint8(129), uint8(106), uint8(102), uint8(0), uint8(63), uint8(184), uint8(162), uint8(83), uint8(109), uint8(138), uint8(228), uint8(173), uint8(133), uint8(59), uint8(133), uint8(204), uint8(231), uint8(53), uint8(176), uint8(239), uint8(35), uint8(39), uint8(156), uint8(148), uint8(48), uint8(142), uint8(53), uint8(14), uint8(43), uint8(158), uint8(216), uint8(7), uint8(165), uint8(21), uint8(103), uint8(2), uint8(73), uint8(70), uint8(72), uint8(66), uint8(87), uint8(188), uint8(76), uint8(37), uint8(12), uint8(81), uint8(51), uint8(129), uint8(129), uint8(234), uint8(26), uint8(225), uint8(112), uint8(105), uint8(100), uint8(194), uint8(208), uint8(51), uint8(165), uint8(10), uint8(231), uint8(47), uint8(16), uint8(100), uint8(134), uint8(19), uint8(82), uint8(141), uint8(137), uint8(73), uint8(124), uint8(73), uint8(25), uint8(246), uint8(13), uint8(12), uint8(26), uint8(72), uint8(1), uint8(194), uint8(70), uint8(134), uint8(39), uint8(152), uint8(188), uint8(59), uint8(153), uint8(32), uint8(52), uint8(10), uint8(47), uint8(129), uint8(144), uint8(206), uint8(128), uint8(214), uint8(200), uint8(233), uint8(9), uint8(12), uint8(33), uint8(228), uint8(18), uint8(88), uint8(150), uint8(129), uint8(129), uint8(187), uint8(58), uint8(216), uint8(105), uint8(30), uint8(202), uint8(97), uint8(15), uint8(160), uint8(152), uint8(6), uint8(6), uint8(226), uint8(104), uint8(10), uint8(93), uint8(100), uint8(194), uint8(82), uint8(85), uint8(159), uint8(128), uint8(148), uint8(238), uint8(172), uint8(228), uint8(232), uint8(52), uint8(12), uint8(22), uint8(81), uint8(104), uint8(27), uint8(128), uint8(254), uint8(55), uint8(15), uint8(128), uint8(7), uint8(182), uint8(0), uint8(63), uint8(145), uint8(148), uint8(7), uint8(195), uint8(184), uint8(28), uint8(3), uint8(178), uint8(51), uint8(129), uint8(55), uint8(194), uint8(200), uint8(140), uint8(69), uint8(127), uint8(80), uint8(50), uint8(206), uint8(88), uint8(130), uint8(40), uint8(92), uint8(76), uint8(3), uint8(3), uint8(25), uint8(1), uint8(156), uint8(12), uint8(108), uint8(230), uint8(57), uint8(31), uint8(208), uint8(112), uint8(124), uint8(226), uint8(142), uint8(10), uint8(0), uint8(231), uint8(197), uint8(35), uint8(153), uint8(202), uint8(24), uint8(176), uint8(60), uint8(178), uint8(186), uint8(122), uint8(210), uint8(223), uint8(44), uint8(147), uint8(251), uint8(165), uint8(37), uint8(33), uint8(253), uint8(31), uint8(205), uint8(98), uint8(26), uint8(26), uint8(81), uint8(48), uint8(164), uint8(134), uint8(134), uint8(165), uint8(5), uint8(20), uint8(82), uint8(58), uint8(82), uint8(90), uint8(126), uint8(66), uint8(16), uint8(132), uint8(103), uint8(233), uint8(79), uint8(234), uint8(219), uint8(101), uint8(255), uint8(213), uint8(161), uint8(116), uint8(0), uint8(17), uint8(128), uint8(58), uint8(44), uint8(1), uint8(249), uint8(68), uint8(46), uint8(144), uint8(16), uint8(144), uint8(128), uint8(160), uint8(12), uint8(0), uint8(116), uint8(148), uint8(144), uint8(192), uint8(118), uint8(66), uint8(1), uint8(217), uint8(11), uint8(147), uint8(64), uint8(116), uint8(5), uint8(73), uint8(91), uint8(36), uint8(174), uint8(5), uint8(70), uint8(0), uint8(236), uint8(7), uint8(92), uint8(12), uint8(19), uint8(62), uint8(229), uint8(244), uint8(114), uint8(192), uint8(194), uint8(123), uint8(114), uint8(247), uint8(200), uint8(181), uint8(1), uint8(48), uint8(97), uint8(48), uint8(134), uint8(67), uint8(40), uint8(162), uint8(104), uint8(104), uint8(5), uint8(133), uint8(126), uint8(18), uint8(88), uint8(196), uint8(151), uint8(243), uint8(103), uint8(108), uint8(130), uint8(183), uint8(253), uint8(41), uint8(36), uint8(32), uint8(199), uint8(249), uint8(254), uint8(203), uint8(188), uint8(112), uint8(16), uint8(147), uint8(73), uint8(164), uint8(32), uint8(40), uint8(89), uint8(100), uint8(34), uint8(96), uint8(5), uint8(161), uint8(187), uint8(4), uint8(20), uint8(75), uint8(65), uint8(91), uint8(191), uint8(217), uint8(210), uint8(146), uint8(254), uint8(217), uint8(8), uint8(36), uint8(164), uint8(214), uint8(221), uint8(183), uint8(234), uint8(146), uint8(36), uint8(48), uint8(190), uint8(142), uint8(53), uint8(29), uint8(190), uint8(21), uint8(6), uint8(146), uint8(223), uint8(254), uint8(26), uint8(128), uint8(51), uint8(248), uint8(8), uint8(152), uint8(42), uint8(12), uint8(44), uint8(48), uint8(162), uint8(207), uint8(61), uint8(134), uint8(18), uint8(208), uint8(5), uint8(139), uint8(103), uint8(117), uint8(6), uint8(149), uint8(240), uint8(110), uint8(14), uint8(228), uint8(88), uint8(178), uint8(137), uint8(161), uint8(165), uint8(43), uint8(36), uint8(33), uint8(198), uint8(129), uint8(132), uint8(226), uint8(88), uint8(96), uint8(223), uint8(134), uint8(13), uint8(225), uint8(137), uint8(112), uint8(207), uint8(216), uint8(126), uint8(51), uint8(14), uint8(213), uint8(2), uint8(134), uint8(98), uint8(201), uint8(160), uint8(55), uint8(37), uint8(114), uint8(16), uint8(5), uint8(0), uint8(139), uint8(244), uint8(75), uint8(65), uint8(185), uint8(192), uint8(38), uint8(203), uint8(193), uint8(33), uint8(4), uint8(248), uint8(6), uint8(0), uint8(32), uint8(0), uint8(188), uint8(4), uint8(192), uint8(24), uint8(228), uint8(164), uint8(4), uint8(196), uint8(208), uint8(51), uint8(144), uint8(206), uint8(2), uint8(130), uint8(106), uint8(15), uint8(125), uint8(128), uint8(114), uint8(132), uint8(0), uint8(73), uint8(227), uint8(98), uint8(192), uint8(183), uint8(220), uint8(33), uint8(146), uint8(166), uint8(74), uint8(18), uint8(216), uint8(88), uint8(210), uint8(155), uint8(141), uint8(117), uint8(18), uint8(18), uint8(24), uint8(193), uint8(77), uint8(37), uint8(195), uint8(62), uint8(72), uint8(22), uint8(227), uint8(84), uint8(51), uint8(163), uint8(132), uint8(41), uint8(198), uint8(242), uint8(202), uint8(74), uint8(18), uint8(53), uint8(212), uint8(72), uint8(72), uint8(99), uint8(44), uint8(33), uint8(117), uint8(49), uint8(232), uint8(62), uint8(0), uint8(122), uint8(144), uint8(12), uint8(80), uint8(3), uint8(178), uint8(104), uint8(21), uint8(2), uint8(160), uint8(15), uint8(64), uint8(160), uint8(1), uint8(152), uint8(21), uint8(33), uint8(129), uint8(128), uint8(20), uint8(129), uint8(158), uint8(3), uint8(2), uint8(80), uint8(24), uint8(196), uint8(160), uint8(28), uint8(1), uint8(68), uint8(33), uint8(29), uint8(208), uint8(130), uint8(177), uint8(216), uint8(96), uint8(193), uint8(255), uint8(197), uint8(242), uint8(138), uint8(37), uint8(13), uint8(37), uint8(129), uint8(126), uint8(8), uint8(128), uint8(131), uint8(58), uint8(150), uint8(192), uint8(57), uint8(227), uint8(242), uint8(226), uint8(144), uint8(158), uint8(113), uint8(101), uint8(114), uint8(184), uint8(66), uint8(220), uint8(150), uint8(87), uint8(230), uint8(183), uint8(108), uint8(150), uint8(71), uint8(53), uint8(37), uint8(20), uint8(240), uint8(21), uint8(38), uint8(129), uint8(64), uint8(204), uint8(18), uint8(3), uint8(160), uint8(24), uint8(160), uint8(134), uint8(80), uint8(5), uint8(45), uint8(139), uint8(43), uint8(128), uint8(232), uint8(7), uint8(104), uint8(12), uint8(40), uint8(52), uint8(96), uint8(103), uint8(33), uint8(134), uint8(39), uint8(164), uint8(132), uint8(3), uint8(114), uint8(26), uint8(24), uint8(55), uint8(16), uint8(128), uint8(76), uint8(2), uint8(112), uint8(13), uint8(70), uint8(45), uint8(28), uint8(183), uint8(213), uint8(2), uint8(18), uint8(202), uint8(193), uint8(168), uint8(232), uint8(72), uint8(74), uint8(56), uint8(113), uint8(0), uint8(116), uint8(3), uint8(160), uint8(11), uint8(18), uint8(132), uint8(33), uint8(0), uint8(58), uint8(13), uint8(0), uint8(179), uint8(103), uint8(80), uint8(192), uint8(50), uint8(239), uint8(220), uint8(4), uint8(189), uint8(76), uint8(69), uint8(128), uint8(29), uint8(128), uint8(98), uint8(0), uint8(208), uint8(2), uint8(240), uint8(7), uint8(64), uint8(96), uint8(0), uint8(212), uint8(7), uint8(64), uint8(22), uint8(0), uint8(86), uint8(75), uint8(1), uint8(176), uint8(5), uint8(36), uint8(32), uint8(209), uint8(160), uint8(96), uint8(96), uint8(208), uint8(67), uint8(5), uint8(13), uint8(45), uint8(152), uint8(151), uint8(143), uint8(97), uint8(78), uint8(222), uint8(81), uint8(65), uint8(187), uint8(39), uint8(119), uint8(66), uint8(78), uint8(44), uint8(164), uint8(145), uint8(139), uint8(66), uint8(194), uint8(162), uint8(16), uint8(3), uint8(64), uint8(5), uint8(96), uint8(32), uint8(0), uint8(118), uint8(1), uint8(160), uint8(20), uint8(0), uint8(196), uint8(1), uint8(112), uint8(3), uint8(176), uint8(12), uint8(128), uint8(26), uint8(128), uint8(56), uint8(38), uint8(134), uint8(134), uint8(134), uint8(128), uint8(232), uint8(10), uint8(128), uint8(104), uint8(3), uint8(176), uint8(24), uint8(0), uint8(57), uint8(0), uint8(112), uint8(5), uint8(73), uint8(161), uint8(156), uint8(52), uint8(4), uint8(196), uint8(210), uint8(202), uint8(229), uint8(36), uint8(7), uint8(96), uint8(26), uint8(16), uint8(203), uint8(38), uint8(22), uint8(80), uint8(104), uint8(20), uint8(79), uint8(9), uint8(225), uint8(129), uint8(165), uint8(36), uint8(174), uint8(197), uint8(149), uint8(15), uint8(14), uint8(36), uint8(3), uint8(160), uint8(208), uint8(16), uint8(0), uint8(232), uint8(154), uint8(3), uint8(176), uint8(24), uint8(0), uint8(156), uint8(178), uint8(156), uint8(10), uint8(128), uint8(104), uint8(3), uint8(112), uint8(3), uint8(226), uint8(198), uint8(151), uint8(128), uint8(192), uint8(5), uint8(101), uint8(1), uint8(130), uint8(104), uint8(70), uint8(78), uint8(65), uint8(99), uint8(80), uint8(160), uint8(47), uint8(146), uint8(48), uint8(244), uint8(55), uint8(128), uint8(96), uint8(24), uint8(76), uint8(1), uint8(138), uint8(0), uint8(98), uint8(2), uint8(112), uint8(208), uint8(208), uint8(19), uint8(128), uint8(220), uint8(7), uint8(68), uint8(208), uint8(10), uint8(128), uint8(15), uint8(0), uint8(96), uint8(1), uint8(97), uint8(69), uint8(0), uint8(28), uint8(1), uint8(130), uint8(190), uint8(33), uint8(130), uint8(23), uint8(210), uint8(0), uint8(184), uint8(21), uint8(0), uint8(173), uint8(44), uint8(88), uint8(10), uint8(118), uint8(3), uint8(4), uint8(130), uint8(149), uint8(40), uint8(229), uint8(240), uint8(142), uint8(231), uint8(246), uint8(118), uint8(101), uint8(227), uint8(146), uint8(120), uint8(31), uint8(117), uint8(183), uint8(63), uint8(111), uint8(160), uint8(13), uint8(64), uint8(4), uint8(160), uint8(33), uint8(0), uint8(168), uint8(0), uint8(240), uint8(178), uint8(104), uint8(5), uint8(100), uint8(44), uint8(1), uint8(160), uint8(0), uint8(144), uint8(132), uint8(80), uint8(12), uint8(67), uint8(9), uint8(128), uint8(39), uint8(0), uint8(52), uint8(1), uint8(0), uint8(0), uint8(140), uint8(16), uint8(122), uint8(249), uint8(48), uint8(1), uint8(210), uint8(64), uint8(98), uint8(81), uint8(53), uint8(32), uint8(13), uint8(134), uint8(128), uint8(95), uint8(201), uint8(160), uint8(84), uint8(176), uint8(208), uint8(7), uint8(156), uint8(6), uint8(4), uint8(210), uint8(192), uint8(14), uint8(64), uint8(47), uint8(38), uint8(22), uint8(95), uint8(33), uint8(0), uint8(63), uint8(0), uint8(196), uint8(48), uint8(7), uint8(112), uint8(0), uint8(0), uint8(1), uint8(0), uint8(1), uint8(87), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(152), uint8(135), uint8(64), uint8(222), uint8(74), uint8(75), uint8(229), uint8(25), uint8(225), uint8(70), uint8(128), uint8(202), uint8(65), uint8(76), uint8(133), uint8(179), uint8(190), uint8(22), uint8(122), uint8(246), uint8(10), uint8(16), uint8(40), uint8(93), uint8(254), uint8(231), uint8(102), uint8(86), uint8(11), uint8(101), uint8(128), uint8(70), uint8(180), uint8(177), uint8(142), uint8(198), uint8(69), uint8(129), uint8(80), uint8(222), uint8(148), uint8(147), uint8(10), uint8(12), uint8(195), uint8(3), uint8(10), uint8(64), uint8(96), uint8(212), uint8(128), uint8(216), uint8(7), uint8(72), uint8(3), uint8(41), uint8(65), uint8(8), uint8(148), uint8(94), uint8(72), uint8(110), uint8(192), uint8(22), uint8(172), uint8(134), uint8(228), uint8(215), uint8(57), uint8(182), uint8(117), uint8(171), uint8(69), uint8(20), uint8(24), uint8(6), uint8(9), uint8(111), uint8(249), uint8(105), uint8(253), uint8(59), uint8(13), uint8(44), uint8(182), uint8(64), uint8(23), uint8(124), uint8(16), uint8(228), uint8(162), uint8(67), uint8(33), uint8(72), uint8(204), uint8(254), uint8(165), uint8(195), uint8(150), uint8(1), uint8(249), uint8(30), uint8(18), uint8(120), uint8(17), uint8(1), uint8(165), uint8(71), uint8(129), uint8(192), uint8(6), uint8(0), uint8(29), uint8(147), uint8(224), uint8(55), uint8(166), uint8(136), uint8(144), uint8(184), uint8(21), uint8(40), uint8(0), uint8(228), uint8(2), uint8(224), uint8(7), uint8(133), uint8(32), uint8(134), uint8(5), uint8(64), uint8(31), uint8(128), uint8(53), uint8(33), uint8(150), uint8(5), uint8(0), uint8(46), uint8(0), uint8(192), uint8(4), uint8(0), uint8(48), uint8(1), uint8(216), uint8(6), uint8(96), uint8(26), uint8(128), uint8(156), uint8(178), uint8(97), uint8(51), uint8(129), uint8(80), uint8(43), uint8(195), uint8(0), uint8(96), uint8(2), uint8(0), uint8(194), uint8(25), uint8(12), uint8(2), uint8(160), uint8(24), uint8(16), uint8(138), uint8(228), uint8(208), uint8(24), uint8(128), uint8(197), uint8(37), uint8(96), uint8(40), uint8(2), uint8(96), uint8(192), uint8(46), uint8(3), uint8(178), uint8(104), uint8(98), uint8(59), uint8(248), uint8(160), uint8(16), uint8(0), uint8(41), uint8(0), uint8(110), uint8(0), uint8(224), uint8(0), uint8(164), uint8(0), uint8(152), uint8(2), uint8(224), uint8(6), uint8(0), uint8(49), uint8(44), uint8(2), uint8(224), uint8(24), uint8(128), uint8(47), uint8(0), uint8(126), uint8(76), uint8(12), uint8(1), uint8(56), uint8(3), uint8(50), uint8(255), uint8(64), uint8(6), uint8(0), uint8(13), uint8(128), uint8(23), uint8(0), uint8(152), uint8(4), uint8(224), uint8(26), uint8(22), uint8(0), uint8(236), uint8(6), uint8(32), uint8(24), uint8(228), uint8(39), uint8(0), uint8(86), uint8(129), uint8(129), uint8(164), uint8(34), uint8(128), uint8(160), uint8(12), uint8(0), uint8(99), uint8(208), uint8(1), uint8(129), uint8(52), uint8(7), uint8(105), uint8(40), uint8(0), uint8(220), uint8(155), uint8(138), uint8(70), uint8(12), uint8(33), uint8(201), uint8(200), uint8(45), uint8(40), uint8(38), uint8(129), uint8(130), uint8(144), uint8(89), uint8(101), uint8(0), uint8(192), uint8(4), uint8(228), uint8(52), uint8(96), uint8(210), uint8(104), uint8(5), uint8(65), uint8(152), uint8(2), uint8(192), uint8(29), uint8(6), uint8(144), uint8(248), uint8(104), uint8(105), uint8(120), uint8(132), uint8(5), uint8(120), uint8(24), uint8(33), uint8(98), uint8(185), uint8(52), uint8(52), uint8(48), uint8(162), uint8(98), uint8(73), uint8(164), uint8(208), uint8(194), uint8(146), uint8(66), uint8(38), uint8(49), uint8(52), uint8(178), uint8(190), uint8(157), uint8(37), uint8(97), uint8(156), uint8(53), uint8(36), uint8(173), uint8(195), uint8(72), uint8(69), uint8(28), uint8(55), uint8(254), uint8(26), uint8(77), uint8(12), uint8(38), uint8(20), uint8(82), uint8(48), uint8(210), uint8(177), uint8(44), uint8(55), uint8(150), uint8(6), uint8(10), uint8(26), uint8(94), uint8(70), uint8(79), uint8(201), uint8(75), uint8(229), uint8(122), uint8(152), uint8(76), uint8(12), uint8(2), uint8(164), uint8(194), uint8(31), uint8(1), uint8(218), uint8(10), uint8(45), uint8(203), uint8(0), uint8(208), uint8(4), uint8(32), uint8(49), uint8(0), uint8(184), uint8(4), uint8(228), uint8(196), uint8(238), uint8(81), uint8(52), uint8(6), uint8(0), uint8(26), uint8(128), uint8(128), uint8(155), uint8(200), uint8(64), uint8(59), uint8(1), uint8(128), uint8(21), uint8(12), uint8(13), uint8(24), uint8(26), uint8(76), uint8(38), uint8(134), uint8(6), uint8(163), uint8(225), uint8(133), uint8(236), uint8(232), uint8(232), uint8(45), uint8(3), uint8(67), uint8(11), uint8(41), uint8(41), uint8(128), uint8(116), uint8(3), uint8(160), uint8(19), uint8(128), uint8(192), uint8(4), uint8(56), uint8(155), uint8(192), uint8(96), uint8(77), uint8(65), uint8(52), uint8(2), uint8(160), uint8(29), uint8(129), uint8(80), uint8(16), uint8(16), uint8(198), uint8(30), uint8(76), uint8(1), uint8(136), uint8(12), uint8(11), uint8(225), uint8(132), uint8(50), uint8(97), uint8(123), uint8(183), uint8(65), uint8(104), uint8(78), uint8(52), uint8(7), uint8(37), uint8(36), uint8(160), uint8(210), uint8(134), uint8(134), uint8(6), uint8(148), uint8(148), uint8(201), uint8(33), uint8(128), uint8(192), uint8(4), uint8(192), uint8(58), uint8(1), uint8(216), uint8(1), uint8(72), uint8(104), uint8(3), uint8(34), uint8(139), uint8(1), uint8(136), uint8(20), uint8(33), uint8(0), uint8(43), uint8(0), uint8(110), uint8(81), uint8(52), uint8(3), uint8(80), uint8(24), uint8(129), uint8(64), uint8(12), uint8(192), uint8(98), uint8(88), uint8(14), uint8(192), uint8(51), uint8(0), uint8(122), uint8(2), uint8(18), uint8(104), uint8(20), uint8(12), uint8(0), uint8(82), uint8(5), uint8(64), uint8(194), uint8(64), uint8(76), uint8(3), uint8(16), uint8(7), uint8(96), uint8(48), uint8(224), uint8(39), uint8(33), uint8(129), uint8(66), uint8(105), uint8(96), uint8(14), uint8(64), uint8(161), uint8(96), uint8(130), uint8(42), uint8(224), uint8(21), uint8(6), uint8(6), uint8(128), uint8(196), uint8(160), uint8(19), uint8(112), uint8(192), uint8(200), uint8(1), uint8(226), uint8(0), uint8(30), uint8(19), uint8(0), uint8(76), uint8(0), uint8(148), uint8(1), uint8(216), uint8(6), uint8(96), uint8(58), uint8(9), uint8(38), uint8(0), uint8(61), uint8(0), uint8(100), uint8(0), uint8(65), uint8(192), uint8(169), uint8(53), uint8(14), uint8(81), uint8(48), uint8(176), uint8(6), uint8(32), uint8(32), uint8(0), uint8(116), uint8(88), uint8(12), uint8(0), uint8(25), uint8(224), uint8(29), uint8(1), uint8(66), uint8(105), uint8(97), uint8(160), uint8(59), uint8(33), uint8(16), uint8(176), uint8(14), uint8(209), uint8(131), uint8(80), uint8(130), uint8(195), uint8(72), uint8(101), uint8(100), uint8(147), uint8(82), uint8(0), uint8(124), uint8(5), uint8(67), uint8(73), uint8(155), uint8(98), uint8(160), uint8(42), uint8(24), uint8(0), uint8(116), uint8(77), uint8(64), uint8(14), uint8(254), uint8(224), uint8(84), uint8(49), uint8(37), uint8(0), uint8(232), uint8(162), uint8(24), uint8(14), uint8(144), uint8(77), uint8(70), uint8(206), uint8(26), uint8(75), uint8(0), uint8(208), uint8(150), uint8(3), uint8(0), uint8(42), uint8(134), uint8(1), uint8(65), uint8(12), uint8(2), uint8(160), uint8(13), uint8(64), uint8(14), uint8(209), uint8(134), uint8(141), uint8(196), uint8(194), uint8(103), uint8(1), uint8(71), uint8(201), uint8(37), uint8(134), uint8(64), uint8(80), uint8(52), uint8(0), uint8(236), uint8(152), uint8(88), uint8(12), uint8(51), uint8(0), uint8(232), uint8(53), uint8(5), uint8(128), uint8(196), uint8(52), uint8(132), uint8(3), uint8(190), uint8(66), uint8(79), uint8(251), uint8(6), uint8(1), uint8(128), uint8(12), uint8(120), uint8(96), uint8(8), uint8(64), uint8(167), uint8(4), uint8(79), uint8(192), uint8(29), uint8(0), uint8(31), uint8(128), uint8(100), uint8(0), uint8(112), uint8(95), uint8(24), uint8(74), uint8(228), uint8(210), uint8(110), uint8(1), uint8(74), uint8(57), uint8(64), uint8(96), uint8(186), uint8(152), uint8(76), uint8(201), uint8(24), uint8(129), uint8(161), uint8(184), uint8(148), uint8(206), uint8(167), uint8(118), uint8(126), uint8(3), uint8(202), uint8(168), uint8(49), uint8(36), uint8(194), uint8(146), uint8(146), uint8(139), uint8(232), uint8(9), uint8(12), uint8(26), uint8(74), uint8(235), uint8(196), uint8(157), uint8(178), uint8(85), uint8(187), uint8(28), uint8(210), uint8(115), uint8(112), uint8(31), uint8(136), uint8(87), uint8(32), uint8(201), uint8(125), uint8(197), uint8(30), uint8(114), uint8(196), uint8(43), uint8(128), uint8(12), uint8(64), uint8(237), uint8(68), uint8(208), uint8(183), uint8(235), uint8(80), uint8(18), uint8(28), uint8(30), uint8(124), uint8(206), uint8(105), uint8(30), uint8(35), uint8(205), uint8(206), uint8(83), uint8(113), uint8(102), uint8(177), uint8(170), uint8(5), uint8(96), uint8(43), uint8(112), uint8(42), uint8(58), uint8(16), uint8(159), uint8(191), uint8(203), uint8(65), uint8(203), uint8(248), uint8(112), uint8(234), uint8(100), uint8(175), uint8(187), uint8(160), uint8(196), uint8(49), uint8(193), uint8(243), uint8(193), uint8(60), uint8(83), uint8(28), uint8(182), uint8(234), uint8(113), uint8(170), uint8(114), uint8(66), uint8(220), uint8(229), uint8(159), uint8(128), uint8(253), uint8(12), uint8(67), uint8(185), uint8(221), uint8(198), uint8(246), uint8(83), uint8(246), uint8(25), uint8(134), uint8(179), uint8(13), uint8(8), uint8(101), uint8(117), uint8(18), uint8(56), uint8(30), uint8(213), uint8(3), uint8(16), uint8(249), uint8(48), uint8(5), uint8(36), uint8(162), uint8(18), uint8(64), uint8(45), uint8(220), uint8(144), uint8(145), uint8(128), uint8(97), uint8(194), uint8(7), uint8(39), uint8(170), uint8(76), uint8(154), uint8(206), uint8(114), uint8(248), uint8(0), uint8(212), uint8(156), uint8(216), uint8(157), uint8(164), uint8(103), uint8(198), uint8(184), uint8(157), uint8(134), uint8(133), uint8(230), uint8(192), uint8(16), uint8(53), uint8(64), uint8(196), uint8(74), uint8(206), uint8(183), uint8(239), uint8(148), uint8(166), uint8(56), uint8(62), uint8(183), uint8(246), uint8(193), uint8(224), uint8(50), uint8(3), uint8(84), uint8(225), uint8(221), uint8(100), uint8(231), uint8(88), uint8(229), uint8(146), uint8(86), uint8(182), uint8(231), uint8(31), uint8(114), uint8(3), uint8(128), uint8(193), uint8(32), uint8(39), uint8(38), uint8(32), uint8(3), uint8(48), uint8(11), uint8(128), uint8(28), uint8(100), uint8(0), uint8(236), uint8(134), uint8(1), uint8(120), uint8(3), uint8(116), uint8(144), uint8(208), uint8(1), uint8(128), uint8(8), uint8(0), uint8(64), uint8(1), uint8(160), uint8(6), uint8(160), uint8(26), uint8(144), uint8(192), uint8(99), uint8(192), uint8(116), uint8(140), uint8(26), uint8(3), uint8(191), uint8(138), uint8(1), uint8(0), uint8(20), uint8(2), uint8(189), uint8(5), uint8(16), uint8(131), uint8(56), uint8(5), uint8(161), uint8(169), uint8(47), uint8(32), uint8(48), uint8(48), uint8(133), uint8(146), uint8(26), uint8(158), uint8(74), uint8(40), uint8(191), uint8(162), uint8(176), uint8(104), uint8(103), uint8(237), uint8(139), uint8(43), uint8(241), uint8(217), uint8(57), uint8(224), uint8(16), uint8(16), uint8(192), uint8(49), uint8(0), uint8(200), uint8(3), uint8(0), uint8(19), uint8(128), uint8(100), uint8(144), uint8(24), uint8(128), uint8(156), uint8(152), uint8(1), uint8(112), uint8(21), uint8(1), uint8(56), uint8(1), uint8(232), uint8(6), uint8(64), uint8(48), uint8(0), uint8(204), uint8(10), uint8(164), uint8(0), uint8(232), uint8(132), uint8(86), uint8(1), uint8(136), uint8(102), uint8(192), uint8(49), uint8(1), uint8(129), uint8(12), uint8(1), uint8(216), uint8(105), uint8(40), uint8(4), uint8(192), uint8(25), uint8(6), uint8(0), uint8(196), uint8(152), uint8(80), uint8(23), uint8(64), uint8(12), uint8(64), uint8(78), uint8(3), uint8(162), uint8(96), uint8(12), uint8(80), uint8(24), uint8(192), uint8(41), uint8(193), uint8(133), uint8(242), uint8(162), uint8(105), uint8(48), uint8(51), uint8(134), uint8(151), uint8(202), uint8(197), uint8(19), uint8(73), uint8(169), uint8(228), uint8(192), uint8(29), uint8(242), uint8(138), uint8(38), uint8(56), uint8(208), uint8(51), uint8(128), uint8(161), uint8(53), uint8(36), uint8(207), uint8(198), uint8(16), uint8(128), uint8(118), uint8(144), uint8(27), uint8(6), uint8(6), uint8(160), uint8(162), uint8(192), uint8(168), uint8(194), uint8(17), uint8(105), uint8(0), uint8(177), uint8(1), uint8(189), uint8(24), uint8(108), uint8(128), uint8(24), uint8(141), uint8(1), uint8(134), uint8(201), uint8(38), uint8(165), uint8(0), uint8(48), uint8(70), uint8(38), uint8(128), uint8(192), uint8(150), uint8(144), uint8(29), uint8(161), uint8(176), uint8(13), uint8(146), uint8(3), uint8(176), uint8(196), uint8(19), uint8(70), uint8(18), uint8(200), uint8(96), uint8(48), uint8(64), uint8(13), uint8(195), uint8(67), uint8(56), uint8(104), uint8(96), uint8(14), uint8(134), uint8(144), uint8(195), uint8(10), uint8(224), uint8(59), uint8(225), uint8(153), uint8(60), uint8(99), uint8(234), uint8(143), uint8(128), uint8(50), uint8(0), uint8(78), uint8(8), uint8(98), uint8(128), uint8(39), uint8(4), uint8(128), uint8(96), uint8(75), uint8(248), uint8(38), uint8(69), uint8(16), uint8(203), uint8(1), uint8(177), uint8(48), uint8(134), uint8(77), uint8(103), uint8(3), uint8(4), uint8(192), uint8(208), uint8(209), uint8(142), uint8(206), uint8(49), uint8(9), uint8(72), uint8(195), uint8(146), uint8(195), uint8(141), uint8(15), uint8(128), uint8(49), uint8(0), uint8(112), uint8(2), uint8(0), uint8(1), uint8(24), uint8(3), uint8(176), uint8(7), uint8(192), uint8(15), uint8(9), uint8(96), uint8(54), uint8(0), uint8(51), uint8(0), uint8(204), uint8(4), uint8(192), uint8(25), uint8(0), uint8(90), uint8(48), uint8(12), uint8(128), uint8(216), uint8(0), uint8(236), uint8(10), uint8(134), uint8(1), uint8(64), uint8(50), uint8(74), uint8(37), uint8(134), uint8(18), uint8(201), uint8(68), uint8(178), uint8(88), uint8(193), uint8(168), uint8(37), uint8(156), uint8(55), uint8(59), uint8(233), uint8(195), uint8(196), uint8(128), uint8(76), uint8(0), uint8(208), uint8(3), uint8(84), uint8(16), uint8(192), uint8(50), uint8(12), uint8(2), uint8(160), uint8(48), uint8(13), uint8(26), uint8(76), uint8(38), uint8(146), uint8(194), uint8(70), uint8(124), uint8(228), uint8(162), uint8(104), uint8(105), uint8(93), uint8(65), uint8(168), uint8(201), uint8(204), uint8(156), uint8(147), uint8(52), uint8(151), uint8(40), uint8(98), uint8(202), uint8(9), uint8(0), uint8(148), uint8(111), uint8(0), uint8(26), uint8(51), uint8(72), uint8(13), uint8(40), uint8(152), uint8(26), uint8(90), uint8(75), uint8(37), uint8(116), uint8(58), uint8(70), uint8(168), uint8(180), uint8(226), uint8(213), uint8(248), uint8(204), uint8(146), uint8(202), uint8(37), uint8(18), uint8(219), uint8(41), uint8(120), uint8(103), uint8(2), uint8(90), uint8(128), uint8(77), uint8(200), uint8(100), uint8(32), uint8(24), uint8(1), uint8(64), uint8(40), uint8(26), uint8(26), uint8(130), uint8(106), uint8(73), uint8(132), uint8(36), uint8(19), uint8(18), uint8(144), uint8(27), uint8(12), uint8(38), uint8(13), uint8(24), uint8(128), uint8(50), uint8(89), uint8(8), uint8(132), uint8(77), uint8(44), uint8(10), uint8(128), uint8(85), uint8(139), uint8(78), uint8(27), uint8(176), uint8(13), uint8(195), uint8(75), uint8(40), uint8(224), uint8(27), uint8(151), uint8(243), uint8(250), uint8(129), uint8(64), uint8(76), uint8(67), uint8(0), uint8(204), uint8(48), uint8(4), uint8(0), uint8(32), uint8(72), uint8(8), uint8(64), uint8(51), uint8(4), uint8(32), uint8(162), uint8(138), uint8(96), uint8(50), uint8(121), uint8(12), uint8(148), uint8(52), uint8(55), uint8(6), uint8(20), uint8(8), uint8(96), uint8(168), uint8(74), uint8(82), uint8(55), uint8(164), uint8(163), uint8(183), uint8(61), uint8(106), uint8(92), uint8(91), uint8(72), uint8(229), uint8(33), uint8(208), uint8(159), uint8(150), uint8(83), uint8(140), uint8(1), uint8(26), uint8(189), uint8(241), uint8(131), uint8(153), uint8(33), uint8(34), uint8(208), uint8(204), uint8(17), uint8(182), uint8(225), uint8(57), uint8(187), uint8(186), uint8(121), uint8(105), uint8(113), uint8(202), uint8(227), uint8(100), uint8(164), uint8(103), uint8(199), uint8(12), uint8(75), uint8(165), uint8(219), uint8(186), uint8(25), uint8(177), uint8(41), uint8(8), uint8(65), uint8(39), uint8(125), uint8(198), uint8(186), uint8(120), uint8(106), uint8(95), uint8(124), uint8(160), uint8(44), uint8(5), uint8(237), uint8(76), uint8(192), uint8(7), uint8(208), uint8(0), uint8(242), uint8(38), uint8(165), uint8(33), uint8(132), uint8(162), uint8(102), uint8(65), uint8(48), uint8(148), uint8(89), uint8(89), uint8(32), uint8(55), uint8(13), uint8(37), uint8(254), uint8(1), uint8(111), uint8(229), uint8(186), uint8(56), uint8(206), uint8(162), uint8(134), uint8(20), uint8(197), uint8(54), uint8(61), uint8(134), uint8(245), uint8(201), uint8(47), uint8(35), uint8(39), uint8(226), uint8(146), uint8(6), uint8(81), uint8(128), uint8(248), uint8(206), uint8(135), uint8(36), uint8(25), uint8(196), uint8(122), uint8(220), uint8(87), uint8(199), uint8(142), uint8(48), uint8(90), uint8(31), uint8(97), uint8(166), uint8(58), uint8(192), uint8(120), uint8(123), uint8(73), uint8(44), uint8(162), uint8(81), uint8(32), uint8(176), uint8(194), uint8(110), uint8(0), uint8(163), uint8(242), uint8(87), uint8(78), uint8(88), uint8(104), uint8(97), uint8(44), uint8(148), uint8(74), uint8(13), uint8(197), uint8(6), uint8(185), uint8(48), uint8(36), uint8(48), uint8(154), uint8(148), uint8(21), uint8(201), uint8(152), uint8(188), uint8(16), uint8(26), uint8(89), uint8(73), uint8(12), uint8(44), uint8(54), uint8(160), uint8(84), uint8(116), uint8(33), uint8(41), uint8(66), uint8(126), uint8(9), uint8(65), uint8(203), uint8(230), uint8(136), uint8(244), uint8(49), uint8(35), uint8(83), uint8(249), uint8(97), uint8(10), uint8(100), uint8(54), uint8(195), uint8(20), uint8(60), uint8(15), uint8(141), uint8(62), uint8(76), uint8(88), uint8(204), uint8(0), uint8(56), uint8(107), uint8(1), uint8(185), uint8(99), uint8(6), uint8(116), uint8(186), uint8(9), uint8(68), uint8(172), uint8(53), uint8(146), uint8(74), uint8(40), uint8(12), uint8(129), uint8(150), uint8(38), uint8(13), uint8(26), uint8(6), uint8(0), uint8(184), uint8(223), uint8(249), uint8(48), uint8(103), uint8(227), uint8(67), uint8(115), uint8(177), uint8(97), uint8(187), uint8(212), uint8(116), uint8(1), uint8(144), uint8(2), uint8(112), uint8(67), uint8(20), uint8(1), uint8(56), uint8(36), uint8(3), uint8(2), uint8(95), uint8(193), uint8(50), uint8(12), uint8(33), uint8(134), uint8(0), uint8(220), uint8(132), uint8(77), uint8(38), uint8(56), uint8(192), uint8(27), uint8(134), uint8(22), uint8(24), uint8(231), uint8(177), uint8(45), uint8(29), uint8(14), uint8(202), uint8(118), uint8(115), uint8(159), uint8(64), uint8(24), uint8(128), uint8(56), uint8(0), uint8(212), uint8(0), uint8(68), uint8(0), uint8(236), uint8(1), uint8(240), uint8(3), uint8(240), uint8(48), uint8(1), uint8(104), uint8(1), uint8(144), uint8(6), uint8(32), uint8(32), uint8(0), uint8(212), uint8(6), uint8(196), uint8(176), uint8(48), uint8(3), uint8(112), uint8(3), uint8(192), uint8(42), uint8(81), uint8(12), uint8(12), uint8(18), uint8(198), uint8(22), uint8(74), uint8(37), uint8(146), uint8(134), uint8(13), uint8(37), uint8(36), uint8(99), uint8(184), uint8(206), uint8(116), uint8(225), uint8(227), uint8(192), uint8(6), uint8(0), uint8(128), uint8(82), uint8(8), uint8(99), uint8(192), uint8(24), uint8(2), uint8(71), uint8(184), uint8(37), uint8(250), uint8(0), uint8(238), uint8(13), uint8(33), uint8(134), uint8(0), uint8(88), uint8(67), uint8(38), uint8(147), uint8(28), uint8(104), uint8(13), uint8(131), uint8(75), uint8(12), uint8(118), uint8(103), uint8(37), uint8(39), uint8(161), uint8(217), uint8(108), uint8(236), uint8(115), uint8(192), uint8(24), uint8(0), uint8(56), uint8(0), uint8(212), uint8(0), uint8(70), uint8(0), uint8(232), uint8(1), uint8(240), uint8(3), uint8(240), uint8(48), uint8(3), uint8(96), uint8(3), uint8(48), uint8(12), uint8(0), uint8(64), uint8(1), uint8(168), uint8(13), uint8(134), uint8(129), uint8(144), uint8(27), uint8(0), uint8(30), uint8(129), uint8(66), uint8(136), uint8(96), uint8(96), uint8(150), uint8(48), uint8(162), uint8(89), uint8(40), uint8(150), uint8(48), uint8(105), uint8(41), uint8(3), uint8(89), uint8(198), uint8(99), uint8(164), uint8(137), uint8(0), uint8(236), uint8(48), uint8(4), uint8(32), uint8(59), uint8(38), uint8(0), uint8(232), uint8(6), uint8(32), uint8(38), uint8(40), uint8(182), uint8(2), uint8(128), uint8(26), uint8(128), uint8(88), uint8(0), uint8(126), uint8(80), uint8(194), uint8(184), uint8(25), uint8(0), uint8(168), uint8(176), uint8(50), uint8(76), uint8(9), uint8(232), uint8(233), uint8(64), uint8(196), uint8(172), uint8(11), uint8(116), uint8(13), uint8(57), uint8(47), uint8(160), uint8(19), uint8(147), uint8(72), uint8(96), uint8(58), uint8(72), uint8(12), uint8(0), uint8(76), uint8(24), uint8(24), uint8(2), uint8(96), uint8(27), uint8(0), uint8(236), uint8(152), uint8(1), uint8(104), uint8(1), uint8(232), uint8(12), uint8(64), uint8(45), uint8(44), uint8(176), uint8(3), uint8(112), uint8(50), uint8(27), uint8(185), uint8(8), uint8(16), uint8(129), uint8(146), uint8(5), uint8(128), uint8(160), uint8(5), uint8(72), uint8(220), uint8(160), uint8(20), uint8(126), uint8(3), uint8(114), uint8(73), uint8(107), uint8(188), uint8(159), uint8(157), uint8(152), uint8(39), uint8(49), uint8(200), uint8(234), uint8(119), uint8(83), uint8(184), uint8(206), uint8(16), uint8(122), uint8(25), uint8(79), uint8(142), uint8(255), uint8(120), uint8(3), uint8(64), uint8(1), uint8(16), uint8(6), uint8(128), uint8(21), uint8(128), uint8(30), uint8(148), uint8(76), uint8(0), uint8(168), uint8(135), uint8(192), uint8(53), uint8(0), uint8(18), uint8(144), uint8(203), uint8(1), uint8(128), uint8(105), uint8(52), uint8(4), uint8(0), uint8(6), uint8(160), uint8(33), uint8(0), uint8(17), uint8(2), uint8(8), uint8(182), uint8(38), uint8(128), uint8(59), uint8(64), uint8(12), uint8(11), uint8(38), uint8(32), uint8(1), uint8(184), uint8(192), uint8(11), uint8(177), uint8(48), uint8(10), uint8(20), uint8(24), uint8(0), uint8(247), uint8(0), uint8(196), uint8(152), uint8(80), uint8(1), uint8(192), uint8(5), uint8(196), uint8(210), uint8(138), uint8(196), uint8(48), uint8(7), uint8(192), uint8(24), uint8(6), uint8(128), uint8(234), uint8(0), uint8(0), uint8(1), uint8(0), uint8(1), uint8(151), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(152), uint8(56), uint8(81), uint8(156), uint8(24), uint8(63), uint8(224), uint8(1), uint8(248), uint8(233), uint8(8), uint8(6), uint8(175), uint8(246), uint8(180), uint8(116), uint8(110), uint8(233), uint8(64), uint8(220), uint8(197), uint8(132), uint8(13), uint8(52), uint8(103), uint8(66), uint8(18), uint8(2), uint8(36), uint8(178), uint8(88), uint8(15), uint8(179), uint8(26), uint8(241), uint8(235), uint8(20), uint8(177), uint8(98), uint8(0), uint8(220), uint8(1), uint8(216), uint8(29), uint8(3), uint8(117), uint8(19), uint8(44), uint8(11), uint8(115), uint8(70), uint8(43), uint8(40), uint8(146), uint8(253), uint8(150), uint8(33), uint8(217), uint8(201), uint8(214), uint8(204), uint8(176), uint8(116), uint8(255), uint8(129), uint8(239), uint8(254), uint8(250), uint8(4), uint8(124), uint8(99), uint8(14), uint8(202), uint8(127), uint8(143), uint8(206), uint8(3), uint8(221), uint8(149), uint8(197), uint8(188), uint8(144), uint8(56), uint8(62), uint8(128), uint8(196), uint8(19), uint8(68), uint8(51), uint8(176), uint8(0), uint8(250), uint8(182), uint8(9), uint8(236), uint8(7), uint8(207), uint8(95), uint8(48), uint8(156), uint8(4), uint8(38), uint8(52), uint8(156), uint8(1), uint8(200), uint8(254), uint8(160), uint8(249), uint8(134), uint8(55), uint8(9), uint8(30), uint8(49), uint8(178), uint8(59), uint8(165), uint8(219), uint8(239), uint8(198), uint8(161), uint8(155), uint8(56), uint8(19), uint8(9), uint8(8), uint8(99), uint8(254), uint8(169), uint8(128), uint8(59), uint8(1), uint8(128), uint8(9), uint8(136), uint8(96), uint8(33), uint8(228), uint8(60), uint8(66), uint8(200), uint8(96), uint8(29), uint8(0), uint8(232), uint8(10), uint8(128), uint8(132), uint8(6), uint8(36), uint8(50), uint8(105), uint8(52), uint8(152), uint8(3), uint8(160), uint8(29), uint8(0), uint8(152), uint8(4), uint8(0), uint8(38), uint8(43), uint8(134), uint8(128), uint8(236), uint8(4), uint8(224), uint8(39), uint8(1), uint8(136), uint8(14), uint8(210), uint8(66), uint8(1), uint8(128), uint8(9), uint8(128), uint8(116), uint8(66), uint8(43), uint8(56), uint8(105), uint8(12), uint8(7), uint8(97), uint8(161), uint8(133), uint8(96), uint8(140), uint8(238), uint8(156), uint8(240), uint8(192), uint8(146), uint8(96), uint8(20), uint8(2), uint8(168), uint8(9), uint8(2), uint8(128), uint8(49), uint8(38), uint8(96), uint8(42), uint8(3), uint8(2), uint8(110), uint8(89), uint8(48), uint8(7), uint8(96), uint8(81), uint8(41), uint8(74), uint8(49), uint8(12), uint8(10), uint8(22), uint8(72), uint8(38), uint8(147), uint8(18), uint8(146), uint8(139), uint8(70), uint8(13), uint8(12), uint8(26), uint8(25), uint8(210), uint8(82), uint8(112), uint8(215), uint8(71), uint8(128), uint8(27), uint8(128), uint8(232), uint8(2), uint8(236), uint8(0), uint8(212), uint8(1), uint8(144), uint8(2), uint8(240), uint8(12), uint8(18), uint8(3), uint8(176), uint8(29), uint8(22), uint8(24), uint8(132), uint8(128), uint8(54), uint8(0), uint8(110), uint8(5), uint8(64), uint8(19), uint8(0), uint8(132), uint8(152), uint8(90), uint8(64), uint8(116), uint8(0), uint8(148), uint8(6), uint8(0), uint8(11), uint8(128), uint8(51), uint8(0), uint8(53), uint8(1), uint8(217), uint8(48), uint8(134), uint8(89), uint8(48), uint8(3), uint8(80), uint8(12), uint8(3), uint8(70), uint8(0), uint8(152), uint8(10), uint8(32), uint8(52), uint8(7), uint8(96), uint8(7), uint8(200), uint8(33), uint8(150), uint8(1), uint8(88), uint8(4), uint8(224), uint8(7), uint8(192), uint8(87), uint8(0), uint8(192), uint8(100), uint8(8), uint8(35), uint8(4), uint8(210), uint8(98), uint8(1), uint8(0), uint8(232), uint8(16), uint8(11), uint8(64), uint8(29), uint8(0), uint8(80), uint8(5), uint8(0), uint8(98), uint8(1), uint8(129), uint8(52), uint8(0), uint8(164), uint8(10), uint8(144), uint8(192), uint8(26), uint8(33), uint8(41), uint8(13), uint8(1), uint8(216), uint8(2), uint8(192), uint8(29), uint8(0), uint8(57), uint8(0), uint8(94), uint8(144), uint8(12), uint8(64), uint8(46), uint8(0), uint8(200), uint8(2), uint8(240), uint8(222), uint8(88), uint8(111), uint8(224), uint8(33), uint8(224), uint8(38), uint8(13), uint8(64), uint8(14), uint8(201), uint8(68), uint8(60), uint8(3), uint8(160), uint8(24), uint8(160), uint8(6), uint8(4), uint8(48), uint8(29), uint8(0), uint8(31), uint8(128), uint8(192), uint8(174), uint8(148), uint8(19), uint8(64), uint8(172), uint8(66), uint8(196), uint8(215), uint8(64), uint8(104), uint8(206), uint8(52), uint8(178), uint8(128), uint8(27), uint8(128), uint8(192), uint8(3), uint8(2), uint8(200), uint8(88), uint8(152), uint8(94), uint8(228), uint8(192), uint8(24), uint8(1), uint8(80), uint8(6), uint8(128), uint8(25), uint8(128), uint8(98), uint8(0), uint8(106), uint8(88), uint8(106), uint8(83), uint8(146), uint8(88), uint8(208), uint8(24), uint8(128), uint8(192), uint8(160), uint8(16), uint8(96), uint8(48), uint8(66), uint8(0), uint8(58), uint8(43), uint8(151), uint8(144), uint8(88), uint8(6), uint8(105), uint8(1), uint8(9), uint8(96), uint8(6), uint8(197), uint8(64), uint8(87), uint8(147), uint8(25), uint8(33), uint8(152), uint8(188), uint8(74), uint8(12), uint8(13), uint8(0), uint8(96), uint8(2), uint8(112), uint8(11), uint8(202), uint8(2), uint8(169), uint8(38), uint8(148), uint8(144), uint8(11), uint8(64), uint8(66), uint8(3), uint8(0), uint8(6), uint8(32), uint8(23), uint8(0), uint8(62), uint8(224), uint8(23), uint8(20), uint8(24), uint8(86), uint8(24), uint8(87), uint8(40), uint8(4), uint8(192), uint8(33), uint8(13), uint8(0), uint8(207), uint8(129), uint8(144), uint8(42), uint8(0), uint8(110), uint8(27), uint8(138), uint8(252), uint8(160), uint8(11), uint8(144), uint8(1), uint8(160), uint8(96), uint8(1), uint8(169), uint8(54), uint8(166), uint8(6), uint8(13), uint8(219), uint8(226), uint8(141), uint8(171), uint8(128), uint8(96), uint8(0), uint8(121), uint8(144), uint8(128), uint8(220), uint8(3), uint8(174), uint8(1), uint8(96), uint8(105), uint8(99), uint8(0), uint8(82), uint8(178), uint8(107), uint8(12), uint8(224), uint8(72), uint8(180), uint8(183), uint8(124), uint8(248), uint8(159), uint8(37), uint8(70), uint8(132), uint8(11), uint8(61), uint8(0), uint8(29), uint8(38), uint8(78), uint8(25), uint8(213), uint8(221), uint8(7), uint8(11), uint8(66), uint8(207), uint8(26), uint8(110), uint8(194), uint8(16), uint8(27), uint8(106), uint8(6), uint8(0), uint8(30), uint8(197), uint8(1), uint8(116), uint8(48), uint8(34), uint8(126), uint8(15), uint8(234), uint8(65), uint8(58), uint8(141), uint8(23), uint8(62), uint8(23), uint8(88), uint8(183), uint8(2), uint8(120), uint8(78), uint8(30), uint8(96), uint8(208), uint8(28), uint8(112), uint8(17), uint8(39), uint8(137), uint8(168), uint8(145), uint8(48), uint8(2), uint8(196), uint8(21), uint8(184), uint8(13), uint8(128), uint8(183), uint8(230), uint8(146), uint8(64), uint8(6), uint8(169), uint8(131), uint8(0), uint8(185), uint8(77), uint8(128), uint8(39), uint8(230), uint8(240), uint8(130), uint8(160), uint8(212), uint8(19), uint8(126), uint8(1), uint8(206), uint8(65), uint8(15), uint8(30), uint8(197), uint8(238), uint8(181), uint8(12), uint8(0), uint8(157), uint8(29), uint8(4), uint8(54), uint8(53), uint8(177), uint8(121), uint8(14), uint8(30), uint8(241), uint8(48), uint8(2), uint8(196), uint8(108), uint8(2), uint8(129), uint8(164), uint8(37), uint8(12), uint8(192), uint8(99), uint8(178), uint8(50), uint8(198), uint8(255), uint8(137), uint8(156), uint8(105), uint8(9), uint8(249), uint8(195), uint8(121), uint8(51), uint8(165), uint8(137), uint8(213), uint8(1), uint8(19), uint8(64), uint8(42), uint8(13), uint8(3), uint8(0), uint8(55), uint8(24), uint8(2), uint8(128), uint8(38), uint8(248), uint8(9), uint8(140), uint8(234), uint8(113), uint8(170), uint8(74), uint8(142), uint8(23), uint8(37), uint8(37), uint8(165), uint8(39), uint8(247), uint8(10), uint8(160), uint8(156), uint8(123), uint8(124), uint8(60), uint8(226), uint8(11), uint8(147), uint8(164), uint8(44), uint8(87), uint8(16), uint8(232), uint8(32), uint8(141), uint8(0), uint8(130), uint8(160), uint8(109), uint8(212), uint8(112), uint8(120), uint8(28), uint8(54), uint8(38), uint8(0), uint8(165), uint8(12), uint8(8), uint8(159), uint8(157), uint8(107), uint8(8), uint8(40), uint8(157), uint8(80), uint8(88), uint8(7), uint8(132), uint8(24), uint8(164), uint8(115), uint8(212), uint8(90), uint8(63), uint8(111), uint8(201), uint8(98), uint8(246), uint8(86), uint8(235), uint8(65), uint8(198), uint8(6), uint8(37), uint8(157), uint8(249), uint8(37), uint8(234), uint8(7), uint8(38), uint8(128), uint8(88), uint8(88), uint8(1), uint8(208), uint8(21), uint8(0), uint8(207), uint8(242), uint8(96), uint8(96), uint8(12), uint8(0), uint8(96), uint8(67), uint8(1), uint8(0), uint8(20), uint8(38), uint8(134), uint8(147), uint8(64), uint8(168), uint8(20), uint8(33), uint8(2), uint8(23), uint8(200), uint8(6), uint8(33), uint8(169), uint8(38), uint8(0), uint8(128), uint8(132), uint8(76), uint8(40), uint8(154), uint8(90), uint8(3), uint8(64), uint8(169), uint8(52), uint8(134), uint8(90), uint8(18), uint8(132), uint8(6), uint8(16), uint8(144), uint8(26), uint8(88), uint8(71), uint8(255), uint8(108), uint8(184), uint8(24), uint8(255), uint8(224), uint8(7), uint8(128), uint8(49), uint8(13), uint8(0), uint8(118), uint8(128), uint8(11), uint8(192), uint8(29), uint8(20), uint8(3), uint8(0), uint8(29), uint8(16), uint8(131), uint8(64), uint8(30), uint8(6), uint8(128), uint8(27), uint8(130), uint8(15), uint8(104), uint8(21), uint8(47), uint8(163), uint8(6), uint8(128), uint8(232), uint8(97), uint8(9), uint8(28), uint8(3), uint8(64), uint8(11), uint8(55), uint8(2), uint8(165), uint8(56), uint8(5), uint8(164), uint8(55), uint8(40), uint8(53), uint8(136), uint8(64), uint8(85), uint8(144), uint8(120), uint8(24), uint8(36), uint8(201), uint8(40), uint8(49), uint8(36), uint8(222), uint8(48), uint8(164), uint8(147), uint8(10), uint8(108), uint8(144), uint8(223), uint8(200), uint8(124), uint8(98), uint8(56), uint8(96), uint8(20), uint8(71), uint8(33), uint8(147), uint8(74), uint8(223), uint8(165), uint8(12), uint8(67), uint8(33), uint8(134), uint8(20), uint8(146), uint8(96), uint8(14), uint8(137), uint8(32), uint8(133), uint8(242), uint8(88), uint8(96), uint8(10), uint8(9), uint8(170), uint8(41), uint8(49), uint8(69), uint8(147), uint8(80), uint8(76), uint8(64), uint8(210), uint8(195), uint8(9), uint8(161), uint8(175), uint8(208), uint8(76), uint8(216), uint8(152), uint8(129), uint8(191), uint8(6), uint8(129), uint8(84), uint8(224), uint8(40), uint8(76), uint8(13), uint8(74), uint8(6), uint8(37), uint8(192), uint8(161), uint8(8), uint8(52), uint8(53), uint8(4), uint8(48), uint8(24), uint8(146), uint8(1), uint8(8), uint8(36), uint8(160), uint8(208), uint8(10), uint8(73), uint8(128), uint8(135), uint8(246), uint8(137), uint8(34), uint8(68), uint8(222), uint8(77), uint8(229), uint8(140), uint8(225), uint8(160), uint8(41), uint8(70), uint8(118), uint8(192), uint8(56), uint8(60), uint8(5), uint8(91), uint8(10), uint8(10), uint8(29), uint8(6), uint8(128), uint8(161), uint8(63), uint8(172), uint8(12), uint8(97), uint8(203), uint8(73), uint8(62), uint8(12), uint8(228), uint8(199), uint8(1), uint8(199), uint8(44), uint8(153), uint8(217), uint8(183), uint8(12), uint8(248), uint8(35), uint8(56), uint8(208), uint8(9), uint8(146), uint8(130), uint8(201), uint8(139), uint8(53), uint8(60), uint8(49), uint8(197), uint8(142), uint8(131), uint8(64), uint8(45), uint8(79), uint8(0), uint8(157), uint8(136), uint8(107), uint8(126), uint8(6), uint8(87), uint8(211), uint8(201), uint8(68), uint8(165), uint8(134), uint8(238), uint8(128), uint8(42), uint8(216), uint8(194), uint8(176), uint8(110), uint8(65), uint8(207), uint8(170), uint8(5), uint8(0), uint8(101), uint8(128), uint8(20), uint8(128), uint8(54), uint8(72), uint8(3), uint8(94), uint8(0), uint8(168), uint8(0), uint8(244), uint8(16), uint8(187), uint8(138), uint8(97), uint8(160), uint8(48), uint8(0), uint8(176), uint8(7), uint8(96), uint8(124), uint8(7), uint8(64), uint8(7), uint8(120), uint8(16), uint8(190), uint8(128), uint8(44), uint8(0), uint8(62), uint8(4), uint8(48), uint8(112), uint8(46), uint8(1), uint8(58), uint8(137), uint8(10), uint8(44), uint8(34), uint8(198), uint8(36), uint8(8), uint8(232), uint8(6), uint8(0), uint8(38), uint8(0), uint8(208), uint8(7), uint8(64), uint8(26), uint8(110), uint8(128), uint8(24), uint8(6), uint8(18), uint8(178), uint8(79), uint8(2), uint8(225), uint8(169), uint8(57), uint8(248), uint8(9), uint8(75), uint8(224), uint8(79), uint8(193), uint8(169), uint8(0), uint8(177), uint8(40), uint8(196), uint8(172), uint8(77), uint8(43), uint8(140), uint8(70), uint8(249), uint8(41), uint8(193), uint8(185), uint8(37), uint8(128), uint8(149), uint8(59), uint8(228), uint8(19), uint8(0), uint8(108), uint8(128), uint8(9), uint8(3), uint8(6), uint8(19), uint8(121), uint8(156), uint8(52), uint8(216), uint8(154), uint8(88), uint8(5), uint8(95), uint8(96), uint8(49), uint8(136), uint8(97), uint8(137), uint8(37), uint8(20), uint8(228), uint8(180), uint8(148), uint8(77), uint8(65), uint8(100), uint8(208), uint8(68), uint8(252), uint8(44), uint8(105), uint8(40), uint8(10), uint8(114), uint8(97), uint8(71), uint8(112), uint8(194), uint8(96), uint8(192), uint8(43), uint8(204), uint8(228), uint8(222), uint8(125), uint8(169), uint8(128), uint8(3), uint8(201), uint8(192), uint8(54), uint8(128), uint8(47), uint8(4), uint8(32), uint8(208), uint8(29), uint8(150), uint8(5), uint8(75), uint8(26), uint8(0), uint8(38), uint8(40), uint8(35), uint8(129), uint8(64), uint8(29), uint8(49), uint8(52), uint8(4), uint8(239), uint8(141), uint8(64), uint8(25), uint8(8), uint8(248), uint8(96), uint8(204), uint8(180), uint8(158), uint8(52), uint8(84), uint8(27), uint8(202), uint8(72), uint8(24), uint8(26), uint8(7), uint8(190), uint8(87), uint8(124), uint8(96), uint8(204), uint8(61), uint8(207), uint8(212), uint8(132), uint8(228), uint8(182), uint8(251), uint8(161), uint8(42), uint8(82), uint8(112), uint8(245), uint8(182), uint8(74), uint8(202), uint8(45), uint8(141), uint8(37), uint8(22), uint8(156), uint8(46), uint8(38), uint8(144), uint8(192), uint8(116), uint8(88), uint8(99), uint8(165), uint8(5), uint8(144), uint8(128), uint8(169), uint8(49), uint8(201), uint8(163), uint8(8), uint8(96), uint8(80), uint8(177), uint8(174), uint8(130), uint8(97), uint8(100), uint8(174), uint8(77), uint8(73), uint8(9), uint8(36), uint8(160), uint8(24), uint8(129), uint8(64), uint8(194), uint8(251), uint8(112), uint8(192), uint8(3), uint8(176), uint8(40), uint8(5), uint8(11), uint8(74), uint8(62), uint8(228), uint8(165), uint8(212), uint8(8), uint8(66), uint8(0), uint8(62), uint8(197), uint8(35), uint8(226), uint8(16), uint8(10), uint8(19), uint8(192), uint8(248), uint8(14), uint8(89), uint8(133), uint8(39), uint8(142), uint8(128), uint8(117), uint8(248), uint8(14), uint8(201), uint8(136), uint8(70), uint8(65), uint8(64), uint8(7), uint8(169), uint8(238), uint8(233), uint8(114), uint8(137), uint8(135), uint8(113), uint8(203), uint8(30), uint8(192), uint8(34), uint8(147), uint8(36), uint8(96), uint8(208), uint8(62), uint8(151), uint8(31), uint8(190), uint8(0), uint8(25), uint8(186), uint8(2), uint8(222), uint8(1), uint8(56), uint8(1), uint8(200), uint8(106), uint8(123), uint8(129), uint8(92), uint8(24), uint8(2), uint8(16), uint8(46), uint8(75), uint8(72), uint8(1), uint8(254), uint8(233), uint8(44), uint8(190), uint8(6), uint8(0), uint8(198), uint8(37), uint8(128), uint8(156), uint8(174), uint8(24), uint8(2), uint8(17), uint8(155), uint8(55), uint8(64), uint8(102), uint8(1), uint8(222), uint8(40), uint8(110), uint8(67), uint8(163), uint8(174), uint8(169), uint8(1), uint8(116), uint8(211), uint8(65), uint8(204), uint8(6), uint8(7), uint8(207), uint8(249), uint8(97), uint8(196), uint8(128), uint8(116), uint8(26), uint8(80), uint8(14), uint8(210), uint8(5), uint8(64), uint8(96), uint8(89), uint8(64), uint8(49), uint8(37), uint8(1), uint8(66), uint8(96), uint8(5), uint8(160), uint8(7), uint8(224), uint8(48), uint8(0), uint8(176), uint8(164), uint8(128), uint8(29), uint8(146), uint8(209), uint8(177), uint8(48), uint8(16), uint8(190), uint8(184), uint8(23), uint8(33), uint8(0), uint8(88), uint8(88), uint8(23), uint8(2), uint8(206), uint8(6), uint8(73), uint8(9), uint8(84), uint8(3), uint8(2), uint8(97), uint8(52), uint8(6), uint8(37), uint8(128), uint8(196), uint8(4), uint8(225), uint8(132), uint8(208), uint8(19), uint8(0), uint8(216), uint8(7), uint8(68), uint8(192), uint8(10), uint8(128), uint8(14), uint8(128), uint8(98), uint8(1), uint8(105), uint8(65), uint8(160), uint8(6), uint8(228), uint8(176), uint8(199), uint8(33), uint8(130), uint8(16), uint8(54), uint8(196), uint8(176), uint8(40), uint8(1), uint8(81), uint8(123), uint8(20), uint8(2), uint8(151), uint8(1), uint8(185), uint8(37), uint8(10), uint8(209), uint8(234), uint8(100), uint8(182), uint8(221), uint8(249), uint8(32), uint8(37), uint8(76), uint8(221), uint8(247), uint8(8), uint8(127), uint8(147), uint8(134), uint8(125), uint8(221), uint8(24), uint8(199), uint8(222), uint8(0), uint8(212), uint8(0), uint8(213), uint8(200), uint8(64), uint8(21), uint8(19), uint8(64), uint8(64), uint8(1), uint8(160), uint8(105), uint8(40), uint8(3), uint8(64), uint8(3), uint8(96), uint8(24), uint8(19), uint8(64), uint8(42), uint8(0), uint8(62), uint8(2), uint8(160), uint8(38), uint8(4), uint8(46), uint8(240), uint8(1), uint8(31), uint8(1), uint8(9), uint8(44), uint8(3), uint8(36), uint8(128), uint8(192), uint8(0), uint8(78), uint8(1), uint8(154), uint8(70), uint8(128), uint8(236), uint8(3), uint8(0), uint8(10), uint8(192), uint8(24), uint8(224), uint8(7), uint8(99), uint8(0), uint8(30), uint8(0), uint8(236), uint8(0), uint8(240), uint8(49), uint8(5), uint8(0), uint8(27), uint8(0), uint8(54), uint8(44), uint8(2), uint8(232), uint8(0), uint8(0), uint8(1), uint8(0), uint8(1), uint8(215), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(152), uint8(146), uint8(208), uint8(146), uint8(146), uint8(51), uint8(229), uint8(137), uint8(194), uint8(64), uint8(93), uint8(14), uint8(6), uint8(224), uint8(24), uint8(12), uint8(12), uint8(237), uint8(147), uint8(198), uint8(101), uint8(186), uint8(89), uint8(216), uint8(243), uint8(13), uint8(91), uint8(98), uint8(58), uint8(164), uint8(151), uint8(138), uint8(201), uint8(98), uint8(139), uint8(37), uint8(161), uint8(76), uint8(150), uint8(229), uint8(59), uint8(225), uint8(111), uint8(213), uint8(192), uint8(125), uint8(105), uint8(38), uint8(148), uint8(216), uint8(10), uint8(98), uint8(18), uint8(0), uint8(110), uint8(48), uint8(111), uint8(33), uint8(146), uint8(128), uint8(119), uint8(242), uint8(88), uint8(53), uint8(108), uint8(146), uint8(94), uint8(1), uint8(134), uint8(79), uint8(64), uint8(22), uint8(197), uint8(4), uint8(150), uint8(8), uint8(159), uint8(139), uint8(199), uint8(72), uint8(25), uint8(247), uint8(233), uint8(229), uint8(167), uint8(158), uint8(5), uint8(144), uint8(74), uint8(216), uint8(144), uint8(163), uint8(247), uint8(45), uint8(73), uint8(89), uint8(37), uint8(128), uint8(241), uint8(143), uint8(81), uint8(49), uint8(98), uint8(129), uint8(175), uint8(254), uint8(124), uint8(36), uint8(138), uint8(0), uint8(61), uint8(168), uint8(240), uint8(102), uint8(1), uint8(146), uint8(72), uint8(136), uint8(1), uint8(180), uint8(69), uint8(169), uint8(128), uint8(32), uint8(1), uint8(216), uint8(6), uint8(32), uint8(58), uint8(1), uint8(129), uint8(12), uint8(4), uint8(0), uint8(58), uint8(44), uint8(6), uint8(229), uint8(128), uint8(196), uint8(2), uint8(242), uint8(111), uint8(33), uint8(0), uint8(104), uint8(2), uint8(0), uint8(19), uint8(0), uint8(152), uint8(6), uint8(32), uint8(25), uint8(128), uint8(106), uint8(2), uint8(114), uint8(110), uint8(64), uint8(212), uint8(160), uint8(10), uint8(0), uint8(104), uint8(1), uint8(161), uint8(48), uint8(7), uint8(96), uint8(39), uint8(38), uint8(146), uint8(176), uint8(14), uint8(121), uint8(68), uint8(206), uint8(130), uint8(186), uint8(74), uint8(197), uint8(252), uint8(146), uint8(195), uint8(50), uint8(97), uint8(161), uint8(1), uint8(160), uint8(84), uint8(132), uint8(144), uint8(128), uint8(42), uint8(3), uint8(2), uint8(111), uint8(2), uint8(128), uint8(49), uint8(33), uint8(117), uint8(19), uint8(64), uint8(116), uint8(5), uint8(80), uint8(132), uint8(39), uint8(144), uint8(128), uint8(169), uint8(68), uint8(146), uint8(97), uint8(55), uint8(32), uint8(178), uint8(147), uint8(195), uint8(3), uint8(70), uint8(22), uint8(48), uint8(180), uint8(118), uint8(100), uint8(232), uint8(1), uint8(176), uint8(21), uint8(0), uint8(114), uint8(66), uint8(0), uint8(108), uint8(0), uint8(156), uint8(1), uint8(1), uint8(105), uint8(2), uint8(128), uint8(84), uint8(10), uint8(1), uint8(80), uint8(24), uint8(150), uint8(0), uint8(236), uint8(3), uint8(64), uint8(24), uint8(0), uint8(24), uint8(128), uint8(104), uint8(2), uint8(114), uint8(16), uint8(8), uint8(0), uint8(51), uint8(0), uint8(92), uint8(144), uint8(29), uint8(128), uint8(92), uint8(146), uint8(139), uint8(1), uint8(128), uint8(6), uint8(65), uint8(160), uint8(23), uint8(128), uint8(92), uint8(0), uint8(228), uint8(1), uint8(194), uint8(0), uint8(168), uint8(2), uint8(253), uint8(192), uint8(15), uint8(177), uint8(100), uint8(208), uint8(12), uint8(139), uint8(0), uint8(188), uint8(164), uint8(19), uint8(18), uint8(128), uint8(7), uint8(132), uint8(208), uint8(40), uint8(88), uint8(105), uint8(15), uint8(248), uint8(154), uint8(1), uint8(138), uint8(24), uint8(1), uint8(56), uint8(1), uint8(72), uint8(110), uint8(38), uint8(6), uint8(146), uint8(128), uint8(118), uint8(0), uint8(156), uint8(4), uint8(36), uint8(50), uint8(96), uint8(3), uint8(240), uint8(222), uint8(53), uint8(0), uint8(10), uint8(195), uint8(0), uint8(108), uint8(3), uint8(162), uint8(102), uint8(0), uint8(114), uint8(5), uint8(18), uint8(128), uint8(194), uint8(96), uint8(12), uint8(18), uint8(76), uint8(79), uint8(38), uint8(112), uint8(13), uint8(63), uint8(0), uint8(201), uint8(0), uint8(7), uint8(64), uint8(21), uint8(128), uint8(100), uint8(67), uint8(24), uint8(48), uint8(52), uint8(12), uint8(134), uint8(21), uint8(19), uint8(67), uint8(67), uint8(0), uint8(192), uint8(1), uint8(227), uint8(147), uint8(11), uint8(66), uint8(0), uint8(168), uint8(5), uint8(196), uint8(208), uint8(19), uint8(160), uint8(154), uint8(146), uint8(105), uint8(51), uint8(128), uint8(220), uint8(154), uint8(24), uint8(0), uint8(244), uint8(0), uint8(235), uint8(160), uint8(48), uint8(49), uint8(0), uint8(56), uint8(33), uint8(32), uint8(152), uint8(97), uint8(101), uint8(240), uint8(19), uint8(150), uint8(67), uint8(197), uint8(164), uint8(0), uint8(248), uint8(160), uint8(13), uint8(16), uint8(128), uint8(29), uint8(151), uint8(16), uint8(137), uint8(133), uint8(146), uint8(240), uint8(9), uint8(216), uint8(154), uint8(81), uint8(101), uint8(128), uint8(232), uint8(1), uint8(217), uint8(8), uint8(4), uint8(9), uint8(33), uint8(32), uint8(152), uint8(67), uint8(64), uint8(5), uint8(132), uint8(34), uint8(104), uint8(3), uint8(160), uint8(3), uint8(156), uint8(144), uint8(208), uint8(212), uint8(190), uint8(44), uint8(10), uint8(150), uint8(67), uint8(52), uint8(160), uint8(204), uint8(2), uint8(0), uint8(192), uint8(41), uint8(195), uint8(10), uint8(0), uint8(61), uint8(44), uint8(3), uint8(52), uint8(150), uint8(3), uint8(160), uint8(202), uint8(152), uint8(24), uint8(24), uint8(90), uint8(18), uint8(140), uint8(148), uint8(117), uint8(119), uint8(51), uint8(153), uint8(197), uint8(233), uint8(162), uint8(186), uint8(49), uint8(104), uint8(24), uint8(149), uint8(238), uint8(65), uint8(21), uint8(20), uint8(156), uint8(146), uint8(89), uint8(73), uint8(193), uint8(163), uint8(16), uint8(129), uint8(160), uint8(100), uint8(161), uint8(155), uint8(146), uint8(223), uint8(4), uint8(4), uint8(245), uint8(160), uint8(149), uint8(214), uint8(45), uint8(218), uint8(213), uint8(248), uint8(227), uint8(200), uint8(39), uint8(229), uint8(147), uint8(164), uint8(169), uint8(207), uint8(101), uint8(254), uint8(176), uint8(255), uint8(150), uint8(131), uint8(67), uint8(177), uint8(2), uint8(196), uint8(140), uint8(0), uint8(30), uint8(205), uint8(254), uint8(94), uint8(87), uint8(3), uint8(114), uint8(22), uint8(110), uint8(15), uint8(82), uint8(201), uint8(243), uint8(46), uint8(201), uint8(244), uint8(78), uint8(238), uint8(32), uint8(225), uint8(196), uint8(26), uint8(129), uint8(80), uint8(221), uint8(243), uint8(118), uint8(192), uint8(127), uint8(51), uint8(189), uint8(111), uint8(251), uint8(132), uint8(40), uint8(196), uint8(141), uint8(60), uint8(58), uint8(99), uint8(32), uint8(145), uint8(91), uint8(169), uint8(151), uint8(151), uint8(187), uint8(141), uint8(112), uint8(134), uint8(126), uint8(96), uint8(75), uint8(132), uint8(8), uint8(64), uint8(201), uint8(29), uint8(11), uint8(87), uint8(249), uint8(111), uint8(199), uint8(18), uint8(6), uint8(48), uint8(78), uint8(227), uint8(51), uint8(172), uint8(11), uint8(12), uint8(9), uint8(53), uint8(105), uint8(27), uint8(80), uint8(49), uint8(100), uint8(208), uint8(194), uint8(200), uint8(69), uint8(146), uint8(131), uint8(115), uint8(39), uint8(24), uint8(251), uint8(153), uint8(190), uint8(59), uint8(252), uint8(119), uint8(31), uint8(6), uint8(228), uint8(242), uint8(184), uint8(212), uint8(43), uint8(231), uint8(34), uint8(201), uint8(172), uint8(97), uint8(17), uint8(64), uint8(104), uint8(2), uint8(63), uint8(88), uint8(110), uint8(82), uint8(91), uint8(139), uint8(96), uint8(1), uint8(151), uint8(118), uint8(0), uint8(143), uint8(212), uint8(78), uint8(223), uint8(173), uint8(74), uint8(82), uint8(220), uint8(147), uint8(55), uint8(222), uint8(216), uint8(240), uint8(14), uint8(102), uint8(251), uint8(144), uint8(4), uint8(118), uint8(1), uint8(113), uint8(221), uint8(123), uint8(191), uint8(176), uint8(185), uint8(128), uint8(58), uint8(1), uint8(48), uint8(33), uint8(130), uint8(128), uint8(141), uint8(36), uint8(120), uint8(2), uint8(224), uint8(16), uint8(128), uint8(59), uint8(1), uint8(0), uint8(6), uint8(64), uint8(84), uint8(3), uint8(64), uint8(19), uint8(16), uint8(248), uint8(21), uint8(224), uint8(49), uint8(0), uint8(191), uint8(147), uint8(112), uint8(6), uint8(128), uint8(58), uint8(1), uint8(128), uint8(6), uint8(128), uint8(26), uint8(128), uint8(102), uint8(5), uint8(64), uint8(118), uint8(144), uint8(41), uint8(138), uint8(73), uint8(55), uint8(6), uint8(19), uint8(0), uint8(52), uint8(2), uint8(128), uint8(84), uint8(191), uint8(202), uint8(197), uint8(163), uint8(179), uint8(103), uint8(207), uint8(243), uint8(140), uint8(75), uint8(64), uint8(48), uint8(1), uint8(0), uint8(33), uint8(130), uint8(135), uint8(248), uint8(134), uint8(3), uint8(160), uint8(5), uint8(224), uint8(130), uint8(62), uint8(3), uint8(176), uint8(29), uint8(0), uint8(51), uint8(98), uint8(98), uint8(120), uint8(9), uint8(128), uint8(118), uint8(5), uint8(6), uint8(0), uint8(86), uint8(88), uint8(24), uint8(33), uint8(18), uint8(192), uint8(169), uint8(52), uint8(160), uint8(24), uint8(6), uint8(36), uint8(53), uint8(33), uint8(1), uint8(8), uint8(44), uint8(135), uint8(147), uint8(209), uint8(146), uint8(87), uint8(13), uint8(96), uint8(49), uint8(131), uint8(67), uint8(58), uint8(73), uint8(122), uint8(195), uint8(120), uint8(192), uint8(11), uint8(82), uint8(128), uint8(40), uint8(144), uint8(19), uint8(134), uint8(226), uint8(128), uint8(175), uint8(33), uint8(0), uint8(232), uint8(48), uint8(10), uint8(148), uint8(3), uint8(4), uint8(144), uint8(192), uint8(168), uint8(24), uint8(44), uint8(0), uint8(248), uint8(48), uint8(2), uint8(210), uint8(201), uint8(128), uint8(85), uint8(5), uint8(100), uint8(144), uint8(192), uint8(193), uint8(47), uint8(164), uint8(51), uint8(129), uint8(103), uint8(206), uint8(87), uint8(248), uint8(180), uint8(64), uint8(25), uint8(128), uint8(63), uint8(66), uint8(18), uint8(0), uint8(228), uint8(4), uint8(249), uint8(32), uint8(49), uint8(40), uint8(3), uint8(66), uint8(96), uint8(32), uint8(246), uint8(150), uint8(1), uint8(88), uint8(12), uint8(67), uint8(64), uint8(161), uint8(96), uint8(49), uint8(64), uint8(20), uint8(1), uint8(208), uint8(1), uint8(184), uint8(33), uint8(123), uint8(134), uint8(128), uint8(31), uint8(6), uint8(16), uint8(192), uint8(116), uint8(88), uint8(106), uint8(112), uint8(20), uint8(3), uint8(60), uint8(173), uint8(137), uint8(184), uint8(11), uint8(140), uint8(236), uint8(94), uint8(192), uint8(97), uint8(53), uint8(31), uint8(0), uint8(100), uint8(1), uint8(168), uint8(33), uint8(246), uint8(0), uint8(46), uint8(4), uint8(143), uint8(0), uint8(75), uint8(8), uint8(68), uint8(76), uint8(38), uint8(147), uint8(64), uint8(108), uint8(140), uint8(150), uint8(26), uint8(225), uint8(164), uint8(32), uint8(198), uint8(118), uint8(4), uint8(63), uint8(178), uint8(105), uint8(68), uint8(199), uint8(118), uint8(48), uint8(104), uint8(210), uint8(1), uint8(240), uint8(6), uint8(32), uint8(15), uint8(128), uint8(50), uint8(0), uint8(19), uint8(129), uint8(82), uint8(200), uint8(64), uint8(55), uint8(1), uint8(177), uint8(40), uint8(3), uint8(32), uint8(7), uint8(32), uint8(26), uint8(141), uint8(37), uint8(18), uint8(220), uint8(0), uint8(68), uint8(0), uint8(240), uint8(4), uint8(224), uint8(15), uint8(192), uint8(192), uint8(193), uint8(168), uint8(4), uint8(63), uint8(176), uint8(3), uint8(192), uint8(27), uint8(18), uint8(220), uint8(5), uint8(3), uint8(73), uint8(99), uint8(18), uint8(48), uint8(98), uint8(103), uint8(15), uint8(18), uint8(1), uint8(128), uint8(3), uint8(192), uint8(13), uint8(72), uint8(64), uint8(33), uint8(1), uint8(0), uint8(96), uint8(12), uint8(112), uint8(33), uint8(124), uint8(148), uint8(77), uint8(26), uint8(74), uint8(44), uint8(36), uint8(48), uint8(7), uint8(4), uint8(210), uint8(202), uint8(225), uint8(29), uint8(8), uint8(231), uint8(148), uint8(199), uint8(99), uint8(156), uint8(15), uint8(174), uint8(72), uint8(196), uint8(12), uint8(114), uint8(88), uint8(72), uint8(18), uint8(24), uint8(44), uint8(124), uint8(80), uint8(104), uint8(97), uint8(73), uint8(74), uint8(75), uint8(43), uint8(150), uint8(76), uint8(221), uint8(35), uint8(70), uint8(100), uint8(228), uint8(225), uint8(152), uint8(224), uint8(206), uint8(53), uint8(4), uint8(163), uint8(143), uint8(229), uint8(20), uint8(25), uint8(255), uint8(29), uint8(0), uint8(31), uint8(114), uint8(105), uint8(64), uint8(58), uint8(33), uint8(19), uint8(0), uint8(168), uint8(5), uint8(128), uint8(59), uint8(13), uint8(12), uint8(2), uint8(152), uint8(48), uint8(178), uint8(104), uint8(13), uint8(146), uint8(76), uint8(26), uint8(26), uint8(200), uint8(37), uint8(144), uint8(209), uint8(177), uint8(52), uint8(176), uint8(213), uint8(150), uint8(252), uint8(162), uint8(128), uint8(168), uint8(21), uint8(1), uint8(216), uint8(24), uint8(201), uint8(25), uint8(210), uint8(89), uint8(245), uint8(48), uint8(4), uint8(0), uint8(14), uint8(128), uint8(30), uint8(128), uint8(104), uint8(0), uint8(204), uint8(3), uint8(34), uint8(96), uint8(3), uint8(240), uint8(7), uint8(132), uint8(48), uint8(3), uint8(240), uint8(16), uint8(0), uint8(236), uint8(12), uint8(128), uint8(216), uint8(154), uint8(6), uint8(9), uint8(164), uint8(193), uint8(160), uint8(54), uint8(13), uint8(44), uint8(132), uint8(88), uint8(22), uint8(33), uint8(148), uint8(76), uint8(38), uint8(230), uint8(13), uint8(12), uint8(47), uint8(45), uint8(25), uint8(217), uint8(243), uint8(229), uint8(217), uint8(135), uint8(64), uint8(80), uint8(6), uint8(32), uint8(48), uint8(2), uint8(128), uint8(26), uint8(129), uint8(66), uint8(192), uint8(96), uint8(3), uint8(18), uint8(128), uint8(201), uint8(8), uint8(52), uint8(97), uint8(44), uint8(161), uint8(169), uint8(67), uint8(146), uint8(147), uint8(139), uint8(64), uint8(73), uint8(93), uint8(9), uint8(204), uint8(148), uint8(110), uint8(174), uint8(78), uint8(174), uint8(239), uint8(130), uint8(91), uint8(1), uint8(252), uint8(206), uint8(52), uint8(9), uint8(44), uint8(198), uint8(146), uint8(89), uint8(41), uint8(255), uint8(12), uint8(26), uint8(140), uint8(75), uint8(75), uint8(20), uint8(95), uint8(197), uint8(140), uint8(40), uint8(4), uint8(142), uint8(77), uint8(217), uint8(0), uint8(100), uint8(176), uint8(39), uint8(192), uint8(44), uint8(12), uint8(64), uint8(31), uint8(96), uint8(150), uint8(68), uint8(88), uint8(104), uint8(24), uint8(255), uint8(164), uint8(153), uint8(139), uint8(43), uint8(18), uint8(203), uint8(24), uint8(24), uint8(27), uint8(241), uint8(124), uint8(162), uint8(96), uint8(34), uint8(2), uint8(96), uint8(11), uint8(74), uint8(197), uint8(1), uint8(146), uint8(250), uint8(208), uint8(95), uint8(0), uint8(168), uint8(132), uint8(133), uint8(13), uint8(204), uint8(75), uint8(98), uint8(170), uint8(7), uint8(92), uint8(26), uint8(26), uint8(24), uint8(76), uint8(196), uint8(194), uint8(17), uint8(101), uint8(16), uint8(192), uint8(201), uint8(53), uint8(32), uint8(100), uint8(6), uint8(228), uint8(192), uint8(48), uint8(148), uint8(0), uint8(84), uint8(51), uint8(236), uint8(80), uint8(10), uint8(120), uint8(65), uint8(52), uint8(12), uint8(224), uint8(149), uint8(96), uint8(131), uint8(172), uint8(52), uint8(48), uint8(178), uint8(97), uint8(99), uint8(11), uint8(64), uint8(196), uint8(227), uint8(242), uint8(133), uint8(14), uint8(115), uint8(60), uint8(223), uint8(113), uint8(248), uint8(252), uint8(220), uint8(35), uint8(168), uint8(35), uint8(129), uint8(188), uint8(162), uint8(116), uint8(148), uint8(134), uint8(6), uint8(134), uint8(31), uint8(145), uint8(243), uint8(19), uint8(2), uint8(74), uint8(74), uint8(9), uint8(165), uint8(96), uint8(11), uint8(74), uint8(3), uint8(37), uint8(110), uint8(88), uint8(103), uint8(74), uint8(48), uint8(104), uint8(199), uint8(112), uint8(196), uint8(252), uint8(26), uint8(24), uint8(148), uint8(22), uint8(81), uint8(104), uint8(65), uint8(97), uint8(133), uint8(161), uint8(21), uint8(2), uint8(161), uint8(110), uint8(143), uint8(146), uint8(200), uint8(196), uint8(148), uint8(49), uint8(36), uint8(60), uint8(87), uint8(145), uint8(134), uint8(186), uint8(119), uint8(64), uint8(70), uint8(102), uint8(72), uint8(220), uint8(18), uint8(248), uint8(113), uint8(141), uint8(105), uint8(146), uint8(148), uint8(97), uint8(4), uint8(82), uint8(116), uint8(94), uint8(44), uint8(15), uint8(114), uint8(138), uint8(72), uint8(65), uint8(41), uint8(28), uint8(99), uint8(37), uint8(0), uint8(41), uint8(3), uint8(35), uint8(64), uint8(176), uint8(192), uint8(50), uint8(89), uint8(225), uint8(142), uint8(67), uint8(3), uint8(44), uint8(25), uint8(217), uint8(177), uint8(40), uint8(152), uint8(50), uint8(163), uint8(160), uint8(12), uint8(128), uint8(53), uint8(4), uint8(62), uint8(192), uint8(5), uint8(192), uint8(145), uint8(224), uint8(9), uint8(97), uint8(8), uint8(137), uint8(132), uint8(48), uint8(192), uint8(27), uint8(160), uint8(99), uint8(179), uint8(6), uint8(144), uint8(131), uint8(92), uint8(240), uint8(67), uint8(5), uint8(33), uint8(148), uint8(77), uint8(99), uint8(192), uint8(249), uint8(41), uint8(158), uint8(0), uint8(204), uint8(1), uint8(240), uint8(6), uint8(96), uint8(2), uint8(96), uint8(42), uint8(88), uint8(21), uint8(3), uint8(0), uint8(55), uint8(26), uint8(1), uint8(128), uint8(3), uint8(144), uint8(13), uint8(9), uint8(67), uint8(73), uint8(76), uint8(0), uint8(37), uint8(0), uint8(120), uint8(2), uint8(112), uint8(7), uint8(192), uint8(100), uint8(104), uint8(194), uint8(193), uint8(12), uint8(24), uint8(0), uint8(244), uint8(6), uint8(227), uint8(24), uint8(5), uint8(36), uint8(162), uint8(80), uint8(212), uint8(57), uint8(47), uint8(78), uint8(30), uint8(60), uint8(0), uint8(92), uint8(8), uint8(5), uint8(32), uint8(134), uint8(58), uint8(1), uint8(128), uint8(36), uint8(123), uint8(130), uint8(95), uint8(160), uint8(14), uint8(226), uint8(105), uint8(12), uint8(48), uint8(2), uint8(194), uint8(25), uint8(52), uint8(132), uint8(227), uint8(64), uint8(108), uint8(26), uint8(88), uint8(96), uint8(214), uint8(24), uint8(228), uint8(164), uint8(244), uint8(59), uint8(58), uint8(156), uint8(79), uint8(104), uint8(3), uint8(0), uint8(7), uint8(0), uint8(25), uint8(128), uint8(8), uint8(192), uint8(29), uint8(0), uint8(62), uint8(0), uint8(126), uint8(6), uint8(0), uint8(44), uint8(0), uint8(51), uint8(0), uint8(200), uint8(4), uint8(0), uint8(26), uint8(128), uint8(216), uint8(150), uint8(6), uint8(64), uint8(192), uint8(1), uint8(232), uint8(20), uint8(40), uint8(154), uint8(6), uint8(9), uint8(99), uint8(10), uint8(37), uint8(146), uint8(137), uint8(99), uint8(6), uint8(146), uint8(138), uint8(118), uint8(113), uint8(152), uint8(233), uint8(34), uint8(64), uint8(49), uint8(12), uint8(13), uint8(1), uint8(210), uint8(0), uint8(116), uint8(3), uint8(18), uint8(131), uint8(64), uint8(96), uint8(6), uint8(64), uint8(169), uint8(52), uint8(6), uint8(192), uint8(7), uint8(192), uint8(49), uint8(0), uint8(180), uint8(180), uint8(0), uint8(29), uint8(18), uint8(147), uint8(210), uint8(77), uint8(4), uint8(32), uint8(108), uint8(5), uint8(136), uint8(96), uint8(22), uint8(148), uint8(5), uint8(128), uint8(187), uint8(1), uint8(130), uint8(74), uint8(23), uint8(0), uint8(156), uint8(134), uint8(24), uint8(3), uint8(4), uint8(0), uint8(152), uint8(4), uint8(193), uint8(164), uint8(192), uint8(16), uint8(128), uint8(220), uint8(7), uint8(100), uint8(48), uint8(10), uint8(192), uint8(14), uint8(192), uint8(76), uint8(1), uint8(96), uint8(104), uint8(96), uint8(1), uint8(177), uint8(40), uint8(53), uint8(136), uint8(64), uint8(133), uint8(244), uint8(144), uint8(44), uint8(5), uint8(64), uint8(43), uint8(40), uint8(5), uint8(32), uint8(89), uint8(128), uint8(108), uint8(72), uint8(74), uint8(252), uint8(156), uint8(147), uint8(243), uint8(13), uint8(124), uint8(216), uint8(240), uint8(133), uint8(187), uint8(230), uint8(78), uint8(9), uint8(61), uint8(0), uint8(92), uint8(106), uint8(25), uint8(60), uint8(209), uint8(159), uint8(64), uint8(25), uint8(0), uint8(26), uint8(49), uint8(12), uint8(2), uint8(178), uint8(96), uint8(8), uint8(64), uint8(53), uint8(38), uint8(18), uint8(192), uint8(51), uint8(0), uint8(53), uint8(1), uint8(137), uint8(48), uint8(2), uint8(176), uint8(3), uint8(240), uint8(40), uint8(2), uint8(112), uint8(66), uint8(17), uint8(0), uint8(17), uint8(96), uint8(16), uint8(18), uint8(128), uint8(51), uint8(64), uint8(12), uint8(64), uint8(4), uint8(192), uint8(25), uint8(32), uint8(96), uint8(14), uint8(128), uint8(49), uint8(0), uint8(168), uint8(1), uint8(135), uint8(0), uint8(116), uint8(52), uint8(1), uint8(232), uint8(14), uint8(128), uint8(15), uint8(67), uint8(82), uint8(88), uint8(1), uint8(184), uint8(3), uint8(114), uint8(128), uint8(47), uint8(128), uint8(0), uint8(0), uint8(1), uint8(0), uint8(2), uint8(23), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(137), uint8(179), uint8(171), uint8(113), uint8(108), uint8(71), uint8(48), uint8(124), uint8(26), uint8(25), uint8(138), uint8(72), uint8(110), uint8(64), uint8(104), uint8(104), uint8(13), uint8(138), uint8(91), uint8(134), uint8(146), uint8(185), uint8(108), uint8(167), uint8(1), uint8(198), uint8(89), uint8(225), uint8(4), uint8(249), uint8(249), uint8(56), uint8(79), uint8(80), uint8(166), uint8(52), uint8(82), uint8(196), uint8(70), uint8(63), uint8(231), uint8(97), uint8(219), uint8(242), uint8(115), uint8(63), uint8(16), uint8(21), uint8(81), uint8(224), uint8(208), uint8(48), uint8(190), uint8(48), uint8(11), uint8(236), uint8(203), uint8(102), uint8(0), uint8(131), uint8(205), uint8(240), uint8(7), uint8(146), uint8(122), uint8(58), uint8(9), uint8(235), uint8(125), uint8(247), uint8(110), uint8(103), uint8(207), uint8(184), uint8(157), uint8(248), uint8(159), uint8(36), uint8(124), uint8(1), uint8(232), uint8(6), uint8(0), uint8(26), uint8(0), uint8(100), uint8(77), uint8(12), uint8(1), uint8(216), uint8(8), uint8(64), uint8(30), uint8(128), uint8(196), uint8(3), uint8(48), uint8(29), uint8(0), uint8(152), uint8(3), uint8(64), uint8(11), uint8(24), uint8(132), uint8(0), uint8(248), uint8(152), uint8(128), uint8(3), uint8(176), uint8(7), uint8(224), uint8(39), uint8(38), uint8(244), uint8(150), uint8(3), uint8(0), uint8(12), uint8(176), uint8(8), uint8(64), uint8(118), uint8(1), uint8(160), uint8(6), uint8(160), uint8(23), uint8(0), uint8(96), uint8(66), uint8(38), uint8(224), uint8(40), uint8(67), uint8(224), uint8(39), uint8(33), uint8(129), uint8(82), uint8(184), uint8(12), uint8(120), uint8(9), uint8(144), uint8(5), uint8(112), uint8(3), uint8(226), uint8(17), uint8(96), uint8(59), uint8(192), uint8(22), uint8(128), uint8(194), uint8(40), uint8(52), uint8(180), uint8(6), uint8(21), uint8(203), uint8(72), uint8(213), uint8(54), uint8(98), uint8(138), uint8(44), uint8(180), uint8(244), uint8(244), uint8(228), uint8(33), uint8(27), uint8(21), uint8(191), uint8(95), uint8(251), uint8(57), uint8(33), uint8(14), uint8(229), uint8(244), uint8(21), uint8(146), uint8(148), uint8(65), uint8(164), uint8(192), uint8(192), uint8(11), uint8(82), uint8(49), uint8(208), uint8(128), uint8(44), uint8(26), uint8(151), uint8(45), uint8(35), uint8(16), uint8(196), uint8(194), uint8(146), uint8(26), uint8(156), uint8(253), uint8(79), uint8(241), uint8(95), uint8(20), uint8(106), uint8(75), uint8(24), uint8(140), uint8(73), uint8(168), uint8(28), uint8(5), uint8(242), uint8(0), uint8(27), uint8(0), uint8(53), uint8(0), uint8(86), uint8(1), uint8(160), uint8(3), uint8(96), uint8(64), uint8(213), uint8(0), uint8(200), uint8(3), uint8(48), uint8(40), uint8(5), uint8(10), uint8(0), uint8(122), uint8(0), uint8(82), uint8(0), uint8(223), uint8(144), uint8(192), uint8(23), uint8(32), uint8(4), uint8(57), uint8(8), uint8(0), uint8(124), uint8(88), uint8(2), uint8(128), uint8(16), uint8(0), uint8(59), uint8(70), uint8(224), uint8(13), uint8(67), uint8(0), uint8(52), uint8(0), uint8(184), uint8(10), uint8(144), uint8(137), uint8(164), uint8(176), uint8(7), uint8(216), uint8(16), uint8(130), uint8(192), uint8(48), uint8(1), uint8(0), uint8(6), uint8(9), uint8(0), uint8(124), uint8(0), uint8(248), uint8(0), uint8(237), uint8(96), uint8(13), uint8(195), uint8(18), uint8(67), uint8(229), uint8(128), uint8(31), uint8(192), uint8(15), uint8(64), uint8(31), uint8(240), uint8(6), uint8(27), uint8(0), uint8(58), uint8(33), uint8(0), uint8(48), uint8(33), uint8(128), uint8(221), uint8(0), uint8(38), uint8(0), uint8(100), uint8(0), uint8(248), uint8(7), uint8(64), uint8(15), uint8(209), uint8(248), uint8(105), uint8(97), uint8(160), uint8(80), uint8(1), uint8(184), uint8(13), uint8(128), uint8(200), uint8(12), uint8(73), uint8(132), uint8(48), uint8(42), uint8(67), uint8(70), uint8(1), uint8(136), uint8(21), uint8(38), uint8(167), uint8(6), uint8(134), uint8(0), uint8(239), uint8(129), uint8(80), uint8(24), uint8(147), uint8(64), uint8(98), uint8(89), uint8(120), uint8(7), uint8(104), uint8(3), uint8(4), uint8(48), uint8(3), uint8(204), uint8(5), uint8(9), uint8(132), uint8(200), uint8(160), uint8(222), uint8(77), uint8(38), uint8(0), uint8(237), uint8(36), uint8(36), uint8(134), uint8(18), uint8(208), uint8(3), uint8(116), uint8(148), uint8(24), uint8(3), uint8(16), uint8(24), uint8(22), uint8(0), uint8(126), uint8(2), uint8(98), uint8(195), uint8(3), uint8(0), uint8(96), uint8(3), uint8(162), uint8(201), uint8(164), uint8(62), uint8(26), uint8(132), uint8(32), uint8(6), uint8(200), uint8(0), uint8(59), uint8(33), uint8(150), uint8(1), uint8(145), uint8(51), uint8(22), uint8(1), uint8(57), uint8(96), uint8(48), uint8(33), uint8(255), uint8(195), uint8(3), uint8(88), uint8(10), uint8(69), uint8(134), uint8(0), uint8(88), uint8(67), uint8(1), uint8(209), uint8(64), uint8(84), uint8(162), uint8(105), uint8(41), uint8(32), uint8(22), uint8(32), uint8(176), uint8(208), uint8(24), uint8(0), uint8(196), uint8(160), uint8(3), uint8(192), uint8(19), uint8(134), uint8(6), uint8(134), uint8(128), uint8(156), uint8(6), uint8(33), uint8(132), uint8(192), uint8(40), uint8(128), uint8(196), uint8(151), uint8(249), uint8(15), uint8(128), uint8(27), uint8(1), uint8(64), uint8(192), uint8(12), uint8(72), uint8(124), uint8(160), uint8(9), uint8(138), uint8(1), uint8(57), uint8(11), uint8(35), uint8(16), uint8(195), uint8(1), uint8(11), uint8(226), uint8(160), uint8(100), uint8(25), uint8(32), uint8(12), uint8(20), uint8(52), uint8(104), uint8(197), uint8(137), uint8(228), uint8(24), uint8(4), uint8(195), uint8(0), uint8(98), uint8(76), uint8(41), uint8(41), uint8(26), uint8(0), uint8(118), uint8(144), uint8(130), uint8(81), uint8(49), uint8(138), uint8(33), uint8(26), uint8(201), uint8(9), uint8(94), uint8(59), uint8(184), uint8(8), uint8(154), uint8(78), uint8(9), uint8(3), uint8(235), uint8(255), uint8(41), uint8(34), uint8(251), uint8(30), uint8(72), uint8(15), uint8(253), uint8(17), uint8(109), uint8(146), uint8(7), uint8(219), uint8(246), uint8(36), uint8(139), uint8(81), uint8(231), uint8(7), uint8(167), uint8(149), uint8(170), uint8(3), uint8(195), uint8(206), uint8(58), uint8(40), uint8(150), uint8(219), uint8(18), uint8(194), uint8(56), uint8(227), uint8(229), uint8(40), uint8(232), uint8(97), uint8(123), uint8(157), uint8(204), uint8(202), uint8(57), uint8(40), uint8(117), uint8(173), uint8(4), uint8(156), uint8(61), uint8(189), uint8(184), uint8(145), uint8(11), uint8(98), uint8(106), uint8(55), uint8(2), uint8(224), uint8(55), uint8(99), uint8(144), uint8(49), uint8(5), uint8(19), uint8(226), uint8(96), uint8(25), uint8(24), uint8(192), uint8(55), uint8(1), uint8(67), uint8(152), uint8(73), uint8(35), uint8(65), uint8(168), uint8(45), uint8(7), uint8(19), uint8(73), uint8(155), uint8(231), uint8(95), uint8(12), uint8(224), uint8(54), uint8(45), uint8(153), uint8(178), uint8(14), uint8(44), uint8(153), uint8(177), uint8(174), uint8(3), uint8(111), uint8(197), uint8(196), uint8(194), uint8(82), uint8(81), uint8(128), uint8(80), uint8(77), uint8(78), uint8(8), uint8(100), uint8(96), uint8(208), uint8(66), uint8(249), uint8(65), uint8(37), uint8(198), uint8(247), uint8(248), uint8(155), uint8(251), uint8(41), uint8(128), uint8(43), uint8(200), uint8(1), uint8(229), uint8(68), uint8(201), uint8(160), uint8(22), uint8(147), uint8(73), uint8(88), uint8(132), uint8(75), uint8(1), uint8(65), uint8(152), uint8(98), uint8(13), uint8(238), uint8(57), uint8(207), uint8(139), uint8(72), uint8(206), uint8(114), uint8(6), uint8(5), uint8(210), uint8(205), uint8(96), uint8(15), uint8(64), uint8(236), uint8(141), uint8(199), uint8(133), uint8(163), uint8(145), uint8(206), uint8(39), uint8(61), uint8(68), uint8(49), uint8(248), uint8(120), uint8(27), uint8(18), uint8(124), uint8(24), uint8(75), uint8(102), uint8(3), uint8(56), uint8(149), uint8(251), uint8(168), uint8(7), uint8(32), uint8(3), uint8(73), uint8(243), uint8(16), uint8(71), uint8(197), uint8(35), uint8(149), uint8(206), uint8(63), uint8(132), uint8(165), uint8(76), uint8(151), uint8(102), uint8(221), uint8(40), uint8(237), uint8(206), uint8(200), uint8(203), uint8(206), uint8(78), uint8(168), uint8(138), uint8(70), uint8(57), uint8(73), uint8(13), uint8(116), uint8(50), uint8(11), uint8(64), uint8(99), uint8(1), uint8(146), uint8(177), uint8(127), uint8(151), uint8(131), uint8(126), uint8(24), uint8(76), uint8(26), uint8(3), uint8(114), uint8(208), uint8(193), uint8(137), uint8(3), uint8(33), uint8(168), uint8(41), uint8(37), uint8(6), uint8(126), uint8(24), uint8(128), uint8(222), uint8(142), uint8(77), uint8(38), uint8(13), uint8(128), uint8(22), uint8(6), uint8(128), uint8(58), uint8(33), uint8(0), uint8(53), uint8(4), uint8(12), uint8(240), uint8(64), uint8(54), uint8(0), uint8(208), uint8(4), uint8(224), uint8(26), uint8(164), uint8(1), uint8(128), uint8(8), uint8(9), uint8(160), uint8(49), uint8(0), uint8(83), uint8(128), uint8(168), uint8(2), uint8(178), uint8(128), uint8(44), uint8(65), uint8(96), uint8(25), uint8(18), uint8(128), uint8(24), uint8(19), uint8(64), uint8(174), uint8(1), uint8(129), uint8(65), uint8(160), uint8(24), uint8(226), uint8(24), uint8(3), uint8(162), uint8(146), uint8(0), uint8(255), uint8(16), uint8(146), uint8(76), uint8(71), uint8(1), uint8(56), uint8(12), uint8(8), uint8(101), uint8(238), uint8(24), uint8(75), uint8(1), uint8(214), uint8(2), uint8(193), uint8(165), uint8(6), uint8(196), uint8(210), uint8(97), uint8(72), uint8(44), uint8(2), uint8(222), uint8(26), uint8(77), uint8(0), uint8(176), uint8(48), uint8(10), uint8(0), uint8(128), uint8(2), uint8(240), uint8(13), uint8(75), uint8(44), uint8(6), uint8(197), uint8(144), uint8(216), uint8(160), uint8(11), uint8(128), uint8(52), uint8(2), uint8(160), uint8(25), uint8(165), uint8(24), uint8(48), uint8(160), uint8(46), uint8(146), uint8(94), uint8(2), uint8(128), uint8(99), uint8(1), uint8(140), uint8(26), uint8(26), uint8(18), uint8(225), uint8(132), uint8(32), uint8(42), uint8(150), uint8(38), uint8(23), uint8(19), uint8(8), uint8(101), uint8(150), uint8(80), uint8(5), uint8(136), uint8(12), uint8(33), uint8(0), uint8(86), uint8(26), uint8(3), uint8(16), uint8(12), uint8(192), uint8(46), uint8(0), uint8(184), uint8(48), uint8(48), uint8(6), uint8(229), uint8(16), uint8(156), uint8(176), uint8(7), uint8(224), uint8(24), uint8(129), uint8(64), uint8(12), uint8(10), uint8(72), uint8(13), uint8(195), uint8(119), uint8(12), uint8(70), uint8(12), uint8(72), uint8(14), uint8(192), uint8(207), uint8(3), uint8(60), uint8(48), uint8(48), uint8(33), uint8(131), uint8(72), uint8(96), uint8(80), uint8(161), uint8(164), uint8(50), uint8(170), uint8(104), uint8(59), uint8(128), uint8(192), uint8(62), uint8(170), uint8(206), uint8(168), uint8(145), uint8(52), uint8(2), uint8(130), uint8(198), uint8(12), uint8(64), uint8(13), uint8(176), uint8(75), uint8(165), uint8(210), uint8(89), uint8(57), uint8(92), uint8(240), uint8(26), uint8(64), uint8(25), uint8(128), uint8(232), uint8(2), uint8(224), uint8(29), uint8(128), uint8(107), uint8(203), uint8(0), uint8(56), uint8(40), uint8(6), uint8(248), uint8(49), uint8(137), uint8(125), uint8(208), uint8(24), uint8(73), uint8(113), uint8(128), uint8(19), uint8(150), uint8(83), uint8(187), uint8(115), uint8(158), uint8(0), uint8(208), uint8(4), uint8(228), uint8(192), uint8(13), uint8(82), uint8(66), uint8(13), uint8(192), uint8(15), uint8(128), uint8(98), uint8(66), uint8(1), uint8(128), uint8(12), uint8(126), uint8(70), uint8(33), uint8(22), uint8(1), uint8(168), uint8(12), uint8(11), uint8(0), uint8(188), uint8(6), uint8(8), uint8(224), uint8(100), uint8(105), uint8(105), uint8(38), uint8(129), uint8(64), uint8(192), uint8(16), uint8(128), uint8(92), uint8(3), uint8(176), uint8(215), uint8(12), uint8(26), uint8(24), uint8(129), uint8(128), uint8(24), uint8(144), uint8(178), uint8(56), uint8(192), uint8(214), uint8(72), uint8(206), uint8(82), uint8(96), uint8(19), uint8(129), uint8(66), uint8(24), uint8(9), uint8(128), uint8(45), uint8(43), uint8(128), uint8(94), uint8(3), uint8(160), uint8(208), uint8(42), uint8(5), uint8(31), uint8(128), uint8(221), uint8(0), uint8(25), uint8(16), uint8(195), uint8(0), uint8(46), uint8(2), uint8(169), uint8(0), uint8(163), uint8(160), uint8(164), uint8(6), uint8(19), uint8(82), uint8(3), uint8(0), uint8(13), uint8(64), uint8(116), uint8(76), uint8(70), uint8(13), uint8(24), uint8(90), uint8(65), uint8(8), uint8(56), uint8(53), uint8(37), uint8(236), uint8(146), uint8(134), uint8(163), uint8(164), uint8(150), uint8(138), uint8(153), uint8(180), uint8(159), uint8(129), uint8(176), uint8(6), uint8(0), uint8(104), uint8(8), uint8(35), uint8(96), uint8(14), uint8(176), uint8(3), uint8(148), uint8(128), uint8(45), uint8(192), uint8(48), uint8(4), uint8(46), uint8(244), uint8(179), uint8(128), uint8(236), uint8(2), uint8(208), uint8(29), uint8(173), uint8(128), uint8(160), uint8(1), uint8(230), uint8(4), uint8(32), uint8(96), uint8(11), uint8(64), uint8(42), uint8(4), uint8(48), uint8(112), uint8(44), uint8(1), uint8(54), uint8(115), uint8(248), uint8(23), uint8(92), uint8(3), uint8(160), uint8(40), uint8(80), uint8(12), uint8(74), uint8(66), uint8(112), uint8(21), uint8(1), uint8(136), uint8(1), uint8(239), uint8(83), uint8(112), uint8(11), uint8(3), uint8(8), uint8(76), uint8(123), uint8(168), uint8(167), uint8(119), uint8(34), uint8(65), uint8(169), uint8(193), uint8(138), uint8(229), uint8(23), uint8(248), uint8(66), uint8(58), uint8(113), uint8(97), uint8(132), uint8(164), uint8(146), uint8(248), uint8(14), uint8(80), uint8(24), uint8(74), uint8(72), uint8(106), uint8(18), uint8(82), uint8(0), uint8(37), uint8(74), uint8(67), uint8(19), uint8(204), uint8(12), uint8(199), uint8(65), uint8(165), uint8(160), uint8(152), uint8(206), uint8(76), uint8(38), uint8(165), uint8(32), uint8(88), uint8(174), uint8(148), uint8(6), uint8(134), uint8(18), uint8(146), uint8(6), uint8(120), uint8(14), uint8(80), uint8(24), uint8(74), uint8(73), uint8(53), uint8(5), uint8(148), uint8(80), uint8(34), uint8(254), uint8(23), uint8(201), uint8(137), uint8(74), uint8(129), uint8(8), uint8(27), uint8(47), uint8(90), uint8(153), uint8(128), uint8(15), uint8(163), uint8(22), uint8(104), uint8(26), uint8(128), uint8(49), uint8(0), uint8(54), uint8(73), uint8(97), uint8(160), uint8(84), uint8(0), uint8(216), uint8(176), uint8(3), uint8(208), uint8(40), uint8(5), uint8(58), uint8(28), uint8(134), uint8(48), uint8(2), uint8(167), uint8(71), uint8(102), uint8(72), uint8(24), uint8(38), uint8(164), uint8(110), uint8(1), uint8(194), uint8(84), uint8(179), uint8(133), uint8(232), uint8(88), uint8(11), uint8(138), uint8(164), uint8(22), uint8(130), uint8(206), uint8(74), uint8(212), uint8(232), uint8(111), uint8(146), uint8(129), uint8(171), uint8(206), uint8(87), uint8(100), uint8(160), uint8(66), uint8(81), uint8(188), uint8(26), uint8(67), uint8(1), uint8(208), uint8(21), uint8(2), uint8(159), uint8(0), uint8(90), uint8(24), uint8(200), uint8(229), uint8(134), uint8(226), uint8(137), uint8(168), uint8(98), uint8(192), uint8(161), uint8(55), uint8(144), uint8(139), uint8(225), uint8(133), uint8(240), uint8(40), uint8(3), uint8(178), uint8(186), uint8(72), uint8(64), uint8(84), uint8(172), uint8(94), uint8(96), uint8(50), uint8(5), uint8(11), uint8(44), uint8(174), uint8(98), uint8(87), uint8(83), uint8(8), uint8(67), uint8(0), uint8(169), uint8(89), uint8(63), uint8(164), uint8(2), uint8(212), uint8(168), uint8(98), uint8(25), uint8(1), uint8(130), uint8(86), uint8(113), uint8(221), uint8(224), uint8(5), uint8(192), uint8(15), uint8(192), uint8(18), uint8(128), uint8(60), uint8(0), uint8(97), uint8(128), uint8(167), uint8(0), uint8(106), uint8(67), uint8(0), uint8(52), uint8(72), uint8(14), uint8(192), uint8(200), uint8(13), uint8(144), uint8(6), uint8(8), uint8(96), uint8(59), uint8(112), uint8(11), uint8(57), uint8(64), uint8(101), uint8(96), uint8(48), uint8(38), uint8(6), uint8(179), uint8(1), uint8(146), uint8(137), uint8(44), uint8(228), uint8(181), uint8(29), uint8(228), uint8(215), uint8(36), uint8(112), uint8(226), uint8(37), uint8(16), uint8(208), uint8(77), uint8(225), uint8(137), uint8(0), uint8(62), uint8(38), uint8(148), uint8(24), uint8(77), uint8(3), uint8(201), uint8(38), uint8(147), uint8(0), uint8(45), uint8(38), uint8(99), uint8(156), uint8(105), uint8(8), uint8(160), uint8(208), uint8(40), uint8(89), uint8(111), uint8(159), uint8(97), uint8(132), uint8(208), uint8(198), uint8(236), uint8(147), uint8(6), uint8(120), uint8(1), uint8(184), uint8(6), uint8(0), uint8(39), uint8(0), uint8(121), uint8(192), uint8(78), uint8(76), uint8(44), uint8(1), uint8(88), uint8(3), uint8(224), uint8(42), uint8(1), uint8(168), uint8(6), uint8(131), uint8(75), uint8(72), uint8(14), uint8(195), uint8(0), uint8(26), uint8(0), uint8(106), uint8(5), uint8(0), uint8(20), uint8(0), uint8(98), uint8(27), uint8(128), uint8(42), uint8(72), uint8(97), uint8(48), uint8(48), uint8(7), uint8(64), uint8(39), uint8(44), uint8(1), uint8(240), uint8(3), uint8(80), uint8(7), uint8(192), uint8(48), uint8(40), uint8(160), uint8(42), uint8(6), uint8(0), uint8(169), uint8(55), uint8(240), uint8(5), uint8(64), uint8(84), uint8(178), uint8(26), uint8(16), uint8(26), uint8(76), uint8(193), uint8(161), uint8(137), uint8(38), uint8(128), uint8(90), uint8(76), uint8(170), uint8(69), uint8(0), uint8(14), uint8(166), uint8(164), uint8(26), uint8(128), uint8(102), uint8(218), uint8(70), uint8(164), uint8(102), uint8(67), uint8(171), uint8(28), uint8(71), uint8(184), uint8(113), uint8(32), uint8(29), uint8(19), uint8(73), uint8(160), uint8(59), uint8(64), uint8(21), uint8(1), uint8(49), uint8(48), uint8(160), uint8(24), uint8(0), uint8(220), uint8(7), uint8(65), uint8(160), uint8(22), uint8(128), uint8(31), uint8(128), uint8(196), uint8(2), uint8(210), uint8(144), uint8(0), uint8(116), uint8(49), uint8(25), uint8(36), uint8(192), uint8(66), uint8(6), uint8(248), uint8(150), uint8(67), uint8(0), uint8(180), uint8(176), uint8(44), uint8(5), uint8(190), uint8(3), uint8(4), uint8(148), uint8(170), uint8(1), uint8(1), uint8(64), uint8(25), uint8(128), uint8(192), uint8(10), uint8(129), uint8(80), uint8(13), uint8(64), uint8(64), uint8(24), uint8(77), uint8(26), uint8(3), uint8(176), uint8(12), uint8(128), uint8(15), uint8(128), uint8(14), uint8(195), uint8(6), uint8(23), uint8(128), uint8(192), uint8(1), uint8(249), uint8(64), uint8(100), uint8(132), uint8(18), uint8(148), uint8(98), uint8(139), uint8(37), uint8(149), uint8(156), uint8(11), uint8(37), uint8(35), uint8(14), uint8(75), uint8(117), uint8(121), uint8(105), uint8(83), uint8(51), uint8(56), uint8(75), uint8(227), uint8(243), uint8(29), uint8(153), uint8(40), uint8(25), uint8(220), uint8(98), uint8(95), uint8(146), uint8(243), uint8(62), uint8(108), uint8(55), uint8(37), uint8(16), uint8(6), uint8(96), uint8(21), uint8(128), uint8(101), uint8(200), uint8(68), uint8(160), uint8(208), uint8(12), uint8(6), uint8(16), uint8(201), uint8(128), uint8(25), uint8(0), uint8(88), uint8(5), uint8(8), uint8(96), uint8(38), uint8(1), uint8(136), uint8(104), uint8(96), uint8(13), uint8(192), uint8(53), uint8(0), uint8(17), uint8(128), uint8(30), uint8(240), uint8(12), uint8(64), uint8(29), uint8(147), uint8(0), uint8(99), uint8(128), uint8(51), uint8(64), uint8(14), uint8(193), uint8(8), uint8(64), uint8(178), uint8(24), uint8(3), uint8(162), uint8(128), uint8(96), uint8(0), uint8(251), uint8(128), uint8(48), uint8(12), uint8(192), uint8(96), uint8(2), uint8(224), uint8(13), uint8(75), uint8(225), uint8(164), uint8(48), uint8(40), uint8(1), uint8(138), uint8(0), uint8(27), uint8(192), uint8(0), uint8(0), uint8(1), uint8(0), uint8(2), uint8(87), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(129), uint8(128), uint8(127), uint8(124), uint8(52), uint8(178), uint8(26), uint8(70), uint8(165), uint8(46), uint8(148), uint8(178), uint8(251), uint8(96), uint8(30), uint8(10), uint8(219), uint8(1), uint8(184), uint8(134), uint8(0), uint8(124), uint8(77), uint8(193), uint8(156), uint8(134), uint8(74), uint8(0), uint8(163), uint8(114), uint8(81), uint8(47), uint8(45), uint8(14), uint8(28), uint8(126), uint8(252), uint8(32), uint8(110), uint8(1), uint8(67), uint8(168), uint8(105), uint8(148), uint8(6), uint8(73), uint8(129), uint8(128), uint8(135), uint8(245), uint8(217), uint8(41), uint8(82), uint8(0), uint8(82), uint8(132), uint8(56), uint8(111), uint8(36), uint8(35), uint8(110), uint8(135), uint8(13), uint8(115), uint8(54), uint8(24), uint8(148), uint8(215), uint8(26), uint8(40), uint8(88), uint8(31), uint8(56), uint8(252), uint8(143), uint8(152), uint8(59), uint8(179), uint8(138), uint8(168), uint8(242), uint8(185), uint8(230), uint8(119), uint8(216), uint8(91), uint8(30), uint8(198), uint8(158), uint8(161), uint8(47), uint8(3), uint8(167), uint8(252), uint8(166), uint8(61), uint8(240), uint8(0), uint8(248), uint8(112), uint8(243), uint8(244), uint8(145), uint8(48), uint8(220), uint8(3), uint8(128), uint8(208), uint8(17), uint8(74), uint8(223), uint8(141), uint8(28), uint8(112), uint8(121), uint8(228), uint8(232), uint8(137), uint8(131), uint8(204), uint8(34), uint8(246), uint8(121), uint8(5), uint8(36), uint8(106), uint8(67), uint8(81), uint8(212), uint8(6), uint8(59), uint8(58), uint8(187), uint8(240), uint8(27), uint8(32), uint8(53), uint8(3), uint8(153), uint8(250), uint8(70), uint8(118), uint8(118), uint8(203), uint8(95), uint8(8), uint8(169), uint8(137), uint8(37), uint8(124), uint8(66), uint8(38), uint8(128), uint8(197), uint8(60), uint8(162), uint8(128), uint8(161), uint8(9), uint8(32), uint8(58), uint8(38), uint8(22), uint8(77), uint8(13), uint8(13), uint8(40), uint8(48), uint8(160), uint8(11), uint8(64), uint8(78), uint8(77), uint8(196), uint8(32), uint8(24), uint8(0), uint8(233), uint8(9), uint8(45), uint8(40), uint8(193), uint8(160), uint8(59), uint8(1), uint8(216), uint8(111), uint8(98), uint8(16), uint8(14), uint8(131), uint8(6), uint8(144), uint8(195), uint8(114), uint8(9), uint8(165), uint8(160), uint8(174), uint8(81), uint8(48), uint8(154), uint8(146), uint8(160), uint8(29), uint8(128), uint8(236), uint8(4), uint8(192), uint8(49), uint8(1), uint8(2), uint8(73), uint8(136), uint8(1), uint8(217), uint8(49), uint8(36), uint8(192), uint8(10), uint8(192), uint8(116), uint8(5), uint8(0), uint8(66), uint8(5), uint8(6), uint8(156), uint8(77), uint8(1), uint8(128), uint8(12), uint8(74), uint8(193), uint8(164), uint8(34), uint8(105), uint8(95), uint8(62), uint8(73), uint8(73), uint8(71), uint8(48), uint8(7), uint8(5), uint8(160), uint8(176), uint8(194), uint8(198), uint8(6), uint8(134), uint8(22), uint8(132), uint8(64), uint8(15), uint8(3), uint8(64), uint8(23), uint8(96), uint8(12), uint8(192), uint8(21), uint8(128), uint8(40), uint8(0), uint8(98), uint8(2), uint8(114), uint8(192), uint8(78), uint8(80), uint8(3), uint8(192), uint8(5), uint8(64), uint8(2), uint8(16), uint8(3), uint8(240), uint8(3), uint8(44), uint8(76), uint8(192), uint8(84), uint8(10), uint8(128), uint8(196), uint8(2), uint8(240), uint8(16), uint8(100), uint8(0), uint8(100), uint8(1), uint8(160), uint8(5), uint8(96), uint8(49), uint8(1), uint8(208), uint8(14), uint8(192), uint8(96), uint8(3), uint8(162), uint8(96), uint8(14), uint8(248), uint8(14), uint8(136), uint8(96), uint8(7), uint8(161), uint8(169), uint8(40), uint8(52), uint8(7), uint8(120), uint8(6), uint8(8), uint8(33), uint8(128), uint8(28), uint8(19), uint8(57), uint8(12), uint8(16), uint8(190), uint8(64), uint8(164), uint8(76), uint8(12), uint8(0), uint8(204), uint8(0), uint8(188), uint8(2), uint8(254), uint8(3), uint8(18), uint8(24), uint8(1), uint8(126), uint8(94), uint8(1), uint8(8), uint8(12), uint8(72), uint8(64), uint8(11), uint8(19), uint8(131), uint8(0), uint8(116), uint8(66), uint8(12), uint8(44), uint8(1), uint8(16), uint8(20), uint8(13), uint8(72), uint8(96), uint8(5), uint8(192), uint8(22), uint8(16), uint8(128), uint8(76), uint8(192), uint8(48), uint8(12), uint8(38), uint8(19), uint8(62), uint8(2), uint8(160), uint8(58), uint8(197), uint8(16), uint8(137), uint8(128), uint8(83), uint8(184), uint8(20), uint8(72), uint8(5), uint8(161), uint8(156), uint8(6), uint8(32), uint8(22), uint8(147), uint8(67), uint8(100), uint8(150), uint8(76), uint8(224), uint8(20), uint8(22), uint8(24), uint8(3), uint8(16), uint8(19), uint8(22), uint8(86), uint8(38), uint8(114), uint8(192), uint8(78), uint8(76), uint8(44), uint8(104), uint8(96), uint8(14), uint8(195), uint8(9), uint8(161), uint8(164), uint8(208), uint8(208), uint8(192), uint8(40), uint8(3), uint8(0), uint8(41), uint8(130), uint8(80), uint8(3), uint8(20), uint8(160), uint8(48), uint8(10), uint8(112), uint8(13), uint8(64), uint8(98), uint8(94), uint8(3), uint8(0), uint8(96), uint8(152), uint8(2), uint8(16), uint8(24), uint8(35), uint8(6), uint8(0), uint8(160), uint8(154), uint8(77), uint8(76), uint8(130), uint8(137), uint8(160), uint8(135), uint8(244), uint8(81), uint8(52), uint8(4), uint8(192), uint8(33), uint8(12), uint8(13), uint8(228), uint8(209), uint8(128), uint8(32), uint8(38), uint8(149), uint8(138), uint8(33), uint8(128), uint8(192), uint8(154), uint8(76), uint8(40), uint8(132), uint8(76), uint8(38), uint8(129), uint8(80), uint8(19), uint8(128), uint8(199), uint8(178), uint8(18), uint8(2), uint8(4), uint8(36), uint8(154), uint8(5), uint8(112), uint8(6), uint8(0), uint8(38), uint8(12), uint8(2), uint8(224), uint8(100), uint8(134), uint8(1), uint8(160), uint8(9), uint8(203), uint8(73), uint8(13), uint8(0), uint8(55), uint8(38), uint8(16), uint8(138), uint8(169), uint8(133), uint8(99), uint8(43), uint8(68), uint8(32), uint8(27), uint8(100), uint8(6), uint8(18), uint8(137), uint8(128), uint8(40), uint8(99), uint8(186), uint8(210), uint8(203), uint8(126), uint8(73), uint8(235), uint8(120), uint8(51), uint8(242), uint8(241), uint8(101), uint8(33), uint8(5), uint8(13), uint8(41), uint8(35), uint8(73), uint8(101), uint8(141), uint8(200), uint8(3), uint8(13), uint8(130), uint8(2), uint8(15), uint8(73), uint8(47), uint8(190), uint8(1), uint8(228), uint8(150), uint8(203), uint8(110), uint8(4), uint8(207), uint8(8), uint8(49), uint8(192), uint8(131), uint8(145), uint8(36), uint8(179), uint8(184), uint8(207), uint8(141), uint8(60), uint8(32), uint8(229), uint8(154), uint8(17), uint8(128), uint8(35), uint8(252), uint8(139), uint8(80), uint8(26), uint8(215), uint8(67), uint8(114), uint8(241), uint8(184), uint8(241), uint8(83), uint8(203), uint8(220), uint8(238), uint8(36), uint8(78), uint8(80), uint8(94), uint8(58), uint8(162), uint8(80), uint8(78), uint8(248), uint8(33), uint8(247), uint8(63), uint8(185), uint8(32), uint8(131), uint8(89), uint8(59), uint8(190), uint8(3), uint8(250), uint8(221), uint8(3), uint8(132), uint8(125), uint8(205), uint8(119), uint8(126), uint8(121), uint8(129), uint8(13), uint8(134), uint8(25), uint8(199), uint8(141), uint8(144), uint8(221), uint8(212), uint8(147), uint8(95), uint8(238), uint8(56), uint8(97), uint8(33), uint8(4), uint8(134), uint8(9), uint8(9), uint8(116), uint8(146), uint8(192), uint8(248), uint8(15), uint8(6), uint8(84), uint8(120), uint8(135), uint8(201), uint8(188), uint8(154), uint8(88), uint8(25), uint8(33), uint8(128), uint8(167), uint8(242), uint8(73), uint8(200), uint8(117), uint8(49), uint8(154), uint8(179), uint8(154), uint8(120), uint8(165), uint8(226), uint8(39), uint8(39), uint8(106), uint8(206), uint8(110), uint8(98), uint8(126), uint8(34), uint8(112), uint8(8), uint8(42), uint8(32), uint8(58), uint8(178), uint8(81), uint8(223), uint8(26), uint8(134), uint8(14), uint8(39), uint8(65), uint8(64), uint8(45), uint8(15), uint8(141), uint8(118), uint8(99), uint8(216), uint8(131), uint8(132), uint8(230), uint8(39), uint8(53), uint8(71), uint8(192), uint8(25), uint8(128), uint8(104), uint8(2), uint8(0), uint8(12), uint8(8), uint8(96), uint8(13), uint8(0), uint8(23), uint8(128), uint8(156), uint8(10), uint8(128), uint8(196), uint8(12), uint8(0), uint8(102), uint8(2), uint8(0), uint8(1), uint8(32), uint8(0), uint8(144), uint8(7), uint8(64), uint8(21), uint8(144), uint8(138), uint8(0), uint8(61), uint8(0), uint8(63), uint8(1), uint8(218), uint8(67), uint8(0), uint8(66), uint8(1), uint8(65), uint8(104), uint8(228), uint8(210), uint8(24), uint8(5), uint8(132), uint8(45), uint8(139), uint8(4), uint8(32), uint8(100), uint8(224), uint8(48), uint8(73), uint8(13), uint8(125), uint8(224), uint8(194), uint8(25), uint8(53), uint8(0), uint8(83), uint8(98), uint8(203), uint8(37), uint8(183), uint8(13), uint8(2), uint8(132), uint8(192), uint8(44), uint8(130), uint8(95), uint8(26), uint8(3), uint8(178), uint8(24), uint8(96), uint8(20), uint8(41), uint8(89), uint8(108), uint8(52), uint8(52), uint8(11), uint8(243), uint8(138), uint8(67), uint8(151), uint8(201), uint8(17), uint8(52), uint8(132), uint8(76), uint8(44), uint8(10), uint8(151), uint8(202), uint8(43), uint8(149), uint8(190), uint8(33), uint8(1), uint8(82), uint8(24), uint8(23), uint8(78), uint8(43), uint8(12), uint8(1), uint8(208), uint8(20), uint8(13), uint8(1), uint8(217), uint8(121), uint8(248), uint8(31), uint8(229), uint8(19), uint8(62), uint8(41), uint8(0), uint8(37), uint8(75), uint8(20), uint8(122), uint8(106), uint8(62), uint8(0), uint8(192), uint8(4), uint8(0), uint8(135), uint8(214), uint8(0), uint8(188), uint8(18), uint8(4), uint8(1), uint8(44), uint8(35), uint8(193), uint8(129), uint8(161), uint8(164), uint8(174), uint8(66), uint8(204), uint8(224), uint8(22), uint8(147), uint8(120), uint8(99), uint8(187), uint8(12), uint8(98), uint8(96), uint8(105), uint8(53), uint8(206), uint8(238), uint8(1), uint8(51), uint8(48), uint8(123), uint8(153), uint8(0), uint8(98), uint8(2), uint8(0), uint8(13), uint8(0), uint8(15), uint8(64), uint8(160), uint8(3), uint8(146), uint8(24), uint8(25), uint8(37), uint8(0), uint8(8), uint8(128), uint8(50), uint8(40), uint8(3), uint8(49), uint8(132), uint8(161), uint8(160), uint8(22), uint8(146), uint8(192), uint8(30), uint8(128), uint8(92), uint8(0), uint8(251), uint8(6), uint8(56), uint8(212), uint8(1), uint8(128), uint8(67), uint8(242), uint8(1), uint8(184), uint8(208), uint8(46), uint8(1), uint8(49), uint8(40), uint8(96), uint8(23), uint8(26), uint8(85), uint8(74), uint8(204), uint8(192), uint8(70), uint8(18), uint8(214), uint8(30), uint8(36), uint8(5), uint8(0), uint8(46), uint8(1), uint8(136), uint8(14), uint8(128), uint8(47), uint8(1), uint8(49), uint8(64), uint8(39), uint8(12), uint8(38), uint8(176), uint8(96), uint8(104), uint8(210), uint8(87), uint8(37), uint8(6), uint8(172), uint8(96), uint8(106), uint8(67), uint8(11), uint8(82), uint8(80), uint8(87), uint8(203), uint8(43), uint8(229), uint8(226), uint8(39), uint8(240), uint8(9), uint8(240), uint8(5), uint8(192), uint8(39), uint8(0), uint8(62), uint8(192), uint8(26), uint8(128), uint8(216), uint8(16), uint8(130), uint8(123), uint8(128), uint8(164), uint8(12), uint8(134), uint8(24), uint8(144), uint8(48), uint8(3), uint8(129), uint8(160), uint8(100), uint8(7), uint8(32), uint8(60), uint8(39), uint8(64), uint8(32), uint8(1), uint8(57), uint8(8), uint8(7), uint8(101), uint8(242), uint8(184), uint8(6), uint8(64), uint8(84), uint8(132), uint8(3), uint8(172), uint8(0), uint8(122), uint8(24), uint8(146), uint8(105), uint8(64), uint8(39), uint8(1), uint8(209), uint8(96), uint8(26), uint8(224), uint8(3), uint8(108), uint8(52), uint8(12), uint8(129), uint8(66), uint8(23), uint8(38), uint8(0), uint8(196), uint8(3), uint8(4), uint8(147), uint8(0), uint8(118), uint8(91), uint8(160), uint8(148), uint8(2), uint8(112), uint8(222), uint8(3), uint8(176), uint8(194), uint8(134), uint8(127), uint8(192), uint8(52), uint8(44), uint8(107), uint8(34), uint8(33), uint8(128), uint8(101), uint8(200), uint8(69), uint8(1), uint8(65), uint8(128), uint8(15), uint8(195), uint8(11), uint8(1), uint8(56), uint8(21), uint8(0), uint8(54), uint8(72), uint8(102), uint8(2), uint8(160), uint8(26), uint8(19), uint8(64), uint8(4), uint8(219), uint8(128), uint8(94), uint8(197), uint8(12), uint8(1), uint8(137), uint8(52), uint8(132), uint8(67), uint8(38), uint8(0), uint8(61), uint8(220), uint8(4), uint8(200), uint8(73), uint8(44), uint8(16), uint8(131), uint8(67), uint8(11), uint8(33), uint8(6), uint8(167), uint8(37), uint8(8), uint8(0), uint8(51), uint8(221), uint8(29), uint8(41), uint8(176), uint8(169), uint8(128), uint8(108), uint8(19), uint8(63), uint8(72), uint8(30), uint8(3), uint8(172), uint8(79), uint8(73), uint8(2), uint8(0), uint8(184), uint8(132), uint8(0), uint8(248), uint8(152), uint8(1), uint8(144), uint8(5), uint8(193), uint8(128), uint8(15), uint8(128), uint8(28), uint8(112), uint8(3), uint8(34), uint8(97), uint8(9), uint8(5), uint8(20), uint8(5), uint8(20), uint8(144), uint8(29), uint8(129), uint8(128), uint8(204), uint8(26), uint8(52), uint8(180), uint8(2), uint8(23), uint8(201), uint8(105), uint8(73), uint8(100), uint8(180), uint8(36), uint8(52), uint8(167), uint8(73), uint8(127), uint8(160), uint8(150), uint8(55), uint8(45), uint8(26), uint8(24), uint8(81), uint8(101), uint8(150), uint8(81), uint8(72), uint8(195), uint8(120), uint8(105), uint8(123), uint8(31), uint8(178), uint8(250), uint8(123), uint8(101), uint8(243), uint8(121), uint8(108), uint8(29), uint8(37), uint8(40), uint8(67), uint8(240), uint8(48), uint8(95), uint8(74), uint8(6), uint8(253), uint8(137), uint8(120), uint8(148), uint8(89), uint8(43), uint8(18), uint8(18), uint8(90), uint8(6), uint8(150), uint8(82), uint8(58), uint8(112), uint8(30), uint8(64), uint8(105), uint8(109), uint8(247), uint8(206), uint8(119), uint8(242), uint8(67), uint8(113), uint8(89), uint8(192), uint8(193), uint8(100), uint8(178), uint8(137), uint8(101), uint8(228), uint8(18), uint8(202), uint8(3), uint8(4), uint8(222), uint8(86), uint8(89), uint8(69), uint8(150), uint8(86), uint8(72), uint8(104), uint8(98), uint8(9), uint8(120), uint8(4), uint8(136), uint8(33), uint8(134), uint8(178), uint8(114), uint8(115), uint8(146), uint8(18), uint8(154), uint8(153), uint8(67), uint8(48), uint8(232), uint8(53), uint8(32), uint8(58), uint8(38), uint8(134), uint8(19), uint8(8), uint8(68), uint8(52), uint8(160), uint8(5), uint8(0), uint8(84), uint8(12), uint8(128), uint8(217), uint8(35), uint8(81), uint8(201), uint8(96), uint8(99), uint8(140), uint8(45), uint8(91), uint8(141), uint8(64), uint8(79), uint8(101), uint8(237), uint8(49), uint8(147), uint8(55), uint8(59), uint8(190), uint8(18), uint8(110), uint8(237), uint8(240), uint8(157), uint8(13), uint8(40), uint8(176), uint8(196), uint8(236), uint8(89), uint8(73), uint8(41), uint8(61), uint8(8), uint8(78), uint8(201), uint8(205), uint8(201), uint8(68), uint8(212), uint8(96), uint8(210), uint8(147), uint8(183), uint8(3), uint8(197), uint8(134), uint8(116), uint8(22), uint8(132), uint8(146), uint8(18), uint8(142), uint8(130), uint8(243), uint8(163), uint8(239), uint8(80), uint8(42), uint8(2), uint8(70), uint8(237), uint8(144), uint8(55), uint8(119), uint8(27), uint8(223), uint8(4), uint8(14), uint8(87), uint8(95), uint8(27), uint8(223), uint8(64), uint8(38), uint8(12), uint8(0), uint8(204), uint8(4), uint8(192), uint8(84), uint8(6), uint8(32), uint8(39), uint8(0), uint8(208), uint8(48), uint8(52), uint8(104), uint8(14), uint8(192), uint8(48), uint8(0), uint8(168), uint8(0), uint8(244), uint8(48), uint8(148), uint8(26), uint8(2), uint8(128), uint8(3), uint8(208), uint8(192), uint8(27), uint8(144), uint8(130), uint8(82), uint8(140), uint8(82), uint8(73), uint8(97), uint8(153), uint8(192), uint8(80), uint8(148), uint8(140), uint8(57), uint8(43), uint8(134), uint8(157), uint8(192), uint8(95), uint8(58), uint8(19), uint8(250), uint8(6), uint8(125), uint8(176), uint8(31), uint8(116), uint8(116), uint8(190), uint8(100), uint8(157), uint8(198), uint8(160), uint8(103), uint8(26), uint8(51), uint8(191), uint8(37), uint8(168), uint8(106), uint8(6), uint8(4), uint8(146), uint8(209), uint8(0), uint8(236), uint8(48), uint8(176), uint8(19), uint8(18), uint8(136), uint8(120), uint8(134), uint8(3), uint8(160), uint8(212), uint8(134), uint8(240), uint8(40), uint8(130), uint8(128), uint8(64), uint8(26), uint8(5), uint8(0), uint8(119), uint8(137), uint8(136), uint8(12), uint8(1), uint8(136), uint8(1), uint8(217), uint8(48), uint8(190), uint8(5), uint8(64), uint8(53), uint8(12), uint8(13), uint8(1), uint8(208), uint8(12), uint8(64), uint8(14), uint8(201), uint8(128), uint8(6), uint8(128), uint8(7), uint8(160), uint8(38), uint8(64), uint8(14), uint8(128), uint8(160), uint8(104), uint8(3), uint8(228), uint8(160), uint8(134), uint8(88), uint8(12), uint8(0), uint8(78), uint8(1), uint8(90), uint8(80), uint8(3), uint8(2), uint8(24), uint8(12), uint8(0), uint8(51), uint8(168), uint8(232), uint8(3), uint8(0), uint8(16), uint8(2), uint8(31), uint8(88), uint8(2), uint8(240), uint8(72), uint8(16), uint8(4), uint8(176), uint8(143), uint8(6), uint8(22), uint8(24), uint8(75), uint8(73), uint8(11), uint8(187), uint8(0), uint8(88), uint8(27), uint8(195), uint8(78), uint8(119), uint8(4), uint8(32), uint8(98), uint8(105), uint8(49), uint8(143), uint8(80), uint8(4), uint8(227), uint8(77), uint8(58), uint8(0), uint8(196), uint8(4), uint8(0), uint8(26), uint8(128), uint8(29), uint8(1), uint8(64), uint8(7), uint8(32), uint8(80), uint8(12), uint8(18), uint8(192), uint8(4), uint8(32), uint8(24), uint8(20), uint8(1), uint8(160), uint8(210), uint8(88), uint8(192), uint8(11), uint8(6), uint8(0), uint8(61), uint8(0), uint8(124), uint8(0), uint8(252), uint8(12), uint8(177), uint8(43), uint8(129), uint8(151), uint8(0), uint8(50), uint8(1), uint8(176), uint8(199), uint8(41), uint8(128), uint8(110), uint8(75), uint8(26), uint8(5), uint8(137), uint8(69), uint8(206), uint8(30), uint8(60), uint8(0), uint8(96), uint8(8), uint8(5), uint8(64), uint8(134), uint8(58), uint8(1), uint8(128), uint8(36), uint8(123), uint8(130), uint8(95), uint8(160), uint8(14), uint8(224), uint8(210), uint8(25), uint8(48), uint8(2), uint8(194), uint8(25), uint8(52), uint8(152), uint8(238), uint8(3), uint8(96), uint8(210), uint8(195), uint8(6), uint8(146), uint8(28), uint8(148), uint8(158), uint8(135), uint8(103), uint8(236), uint8(236), uint8(114), uint8(224), uint8(12), uint8(128), uint8(27), uint8(0), uint8(106), uint8(0), uint8(35), uint8(0), uint8(116), uint8(0), uint8(248), uint8(1), uint8(248), uint8(24), uint8(0), uint8(176), uint8(0), uint8(204), uint8(3), uint8(32), uint8(19), uint8(0), uint8(106), uint8(3), uint8(97), uint8(160), uint8(100), uint8(12), uint8(0), uint8(30), uint8(129), uint8(66), uint8(136), uint8(96), uint8(96), uint8(12), uint8(140), uint8(40), uint8(105), uint8(40), uint8(150), uint8(48), uint8(150), uint8(74), uint8(67), uint8(179), uint8(140), uint8(199), uint8(77), uint8(42), uint8(146), uint8(203), uint8(225), uint8(169), uint8(233), uint8(45), uint8(127), uint8(158), uint8(173), uint8(133), uint8(25), uint8(164), uint8(228), uint8(167), uint8(110), uint8(140), uint8(148), uint8(228), uint8(37), uint8(134), uint8(163), uint8(126), uint8(201), uint8(99), uint8(159), uint8(26), uint8(207), uint8(217), uint8(199), uint8(212), uint8(72), uint8(6), uint8(36), uint8(192), uint8(192), uint8(29), uint8(36), uint8(10), uint8(0), uint8(196), uint8(52), uint8(52), uint8(6), uint8(32), uint8(54), uint8(2), uint8(161), uint8(128), uint8(22), uint8(0), uint8(31), uint8(0), uint8(192), uint8(2), uint8(194), uint8(210), uint8(0), uint8(118), uint8(75), uint8(72), uint8(194), uint8(104), uint8(33), uint8(125), uint8(96), uint8(44), uint8(66), uint8(0), uint8(177), uint8(0), uint8(92), uint8(11), uint8(184), uint8(25), uint8(113), uint8(136), uint8(92), uint8(3), uint8(16), uint8(42), uint8(1), uint8(144), uint8(12), uint8(64), uint8(160), uint8(8), uint8(0), uint8(76), uint8(2), uint8(16), uint8(208), uint8(193), uint8(128), uint8(58), uint8(0), uint8(204), uint8(2), uint8(208), uint8(3), uint8(194), uint8(198), uint8(149), uint8(192), uint8(200), uint8(1), uint8(225), uint8(55), uint8(6), uint8(16), uint8(194), uint8(50), uint8(121), uint8(104), uint8(37), uint8(23), uint8(246), uint8(2), uint8(232), uint8(64), uint8(211), uint8(208), uint8(250), uint8(47), uint8(39), uint8(55), uint8(125), uint8(220), uint8(96), uint8(67), uint8(37), uint8(153), uint8(35), uint8(79), uint8(72), uint8(66), uint8(70), uint8(225), uint8(131), uint8(80), uint8(216), uint8(148), uint8(182), uint8(72), uint8(208), uint8(142), uint8(132), uint8(192), uint8(25), uint8(0), uint8(84), uint8(1), uint8(170), uint8(0), uint8(174), uint8(44), uint8(48), uint8(3), uint8(18), uint8(89), uint8(8), uint8(52), uint8(3), uint8(48), uint8(10), uint8(200), uint8(96), uint8(80), uint8(4), uint8(224), uint8(48), uint8(12), uint8(13), uint8(1), uint8(176), uint8(8), uint8(0), uint8(4), uint8(64), uint8(7), uint8(128), uint8(6), uint8(64), uint8(14), uint8(137), uint8(160), uint8(48), uint8(224), uint8(25), uint8(36), uint8(7), uint8(64), uint8(133), uint8(224), uint8(81), uint8(8), uint8(1), uint8(217), uint8(96), uint8(49), uint8(0), uint8(127), uint8(128), uint8(24), uint8(134), uint8(128), uint8(164), uint8(1), uint8(248), uint8(6), uint8(133), uint8(96), uint8(194), uint8(16), uint8(21), uint8(0), uint8(193), uint8(32), uint8(13), uint8(160), uint8(0), uint8(0), uint8(1), uint8(0), uint8(2), uint8(151), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(137), uint8(160), uint8(53), uint8(44), uint8(76), uint8(116), uint8(6), uint8(18), uint8(210), uint8(131), uint8(243), uint8(177), uint8(45), uint8(98), uint8(0), uint8(242), uint8(2), uint8(216), uint8(125), uint8(163), uint8(127), uint8(246), uint8(31), uint8(217), uint8(125), uint8(27), uint8(110), uint8(115), uint8(141), uint8(255), uint8(109), uint8(156), uint8(223), uint8(219), uint8(27), uint8(224), uint8(27), uint8(128), uint8(160), uint8(7), uint8(64), uint8(55), uint8(87), uint8(224), uint8(20), uint8(224), uint8(48), uint8(104), uint8(5), uint8(8), uint8(71), uint8(199), uint8(18), uint8(203), uint8(9), uint8(229), uint8(182), uint8(2), uint8(192), uint8(120), uint8(32), uint8(106), uint8(70), uint8(163), uint8(67), uint8(28), uint8(110), uint8(71), uint8(8), uint8(206), uint8(133), uint8(137), uint8(233), uint8(115), uint8(118), uint8(59), uint8(110), uint8(190), uint8(183), uint8(91), uint8(84), uint8(183), uint8(192), uint8(136), uint8(17), uint8(88), uint8(114), uint8(135), uint8(92), uint8(144), uint8(56), uint8(6), uint8(96), uint8(48), uint8(0), uint8(124), uint8(3), uint8(16), uint8(16), uint8(147), uint8(0), uint8(53), uint8(1), uint8(136), uint8(102), uint8(33), uint8(6), uint8(0), uint8(128), uint8(1), uint8(225), uint8(8), uint8(0), uint8(252), uint8(2), uint8(240), uint8(12), uint8(192), uint8(66), uint8(2), uint8(16), uint8(16), uint8(0), uint8(62), uint8(0), uint8(184), uint8(3), uint8(66), uint8(23), uint8(73), uint8(43), uint8(22), uint8(3), uint8(16), uint8(12), uint8(64), uint8(47), uint8(33), uint8(128), uint8(232), uint8(4), uint8(4), uint8(34), uint8(90), uint8(73), uint8(8), uint8(44), uint8(134), uint8(142), uint8(156), uint8(81), uint8(105), uint8(70), uint8(248), uint8(48), uint8(190), uint8(136), uint8(162), uint8(102), uint8(2), uint8(200), uint8(8), uint8(24), uint8(122), uint8(132), uint8(167), uint8(252), uint8(20), uint8(32), uint8(76), uint8(1), uint8(144), uint8(6), uint8(160), uint8(5), uint8(0), uint8(23), uint8(128), uint8(33), uint8(3), uint8(4), uint8(48), uint8(40), uint8(128), uint8(12), uint8(128), uint8(53), uint8(0), uint8(184), uint8(1), uint8(96), uint8(208), uint8(7), uint8(224), uint8(13), uint8(64), uint8(23), uint8(0), uint8(94), uint8(5), uint8(0), uint8(118), uint8(2), uint8(112), uint8(12), uint8(128), uint8(31), uint8(149), uint8(153), uint8(0), uint8(58), uint8(38), uint8(128), uint8(102), uint8(2), uint8(96), uint8(7), uint8(192), uint8(11), uint8(64), uint8(21), uint8(0), uint8(57), uint8(1), uint8(216), uint8(6), uint8(64), uint8(15), uint8(136), uint8(96), uint8(133), uint8(236), uint8(67), uint8(40), uint8(10), uint8(0), uint8(237), uint8(32), uint8(32), uint8(193), uint8(184), uint8(10), uint8(6), uint8(128), uint8(59), uint8(43), uint8(128), uint8(232), uint8(172), uint8(80), uint8(109), uint8(252), uint8(66), uint8(197), uint8(252), uint8(77), uint8(0), uint8(212), uint8(48), uint8(3), uint8(66), uint8(102), uint8(45), uint8(184), uint8(12), uint8(67), uint8(73), uint8(128), uint8(22), uint8(161), uint8(73), uint8(204), uint8(24), uint8(130), uint8(98), uint8(8), uint8(96), uint8(81), uint8(200), uint8(96), uint8(59), uint8(4), uint8(48), uint8(128), uint8(24), uint8(56), uint8(21), uint8(40), uint8(153), uint8(128), uint8(118), uint8(77), uint8(12), uint8(72), uint8(105), uint8(96), uint8(54), uint8(201), uint8(159), uint8(22), uint8(188), uint8(76), uint8(2), uint8(132), uint8(208), uint8(24), uint8(150), uint8(188), uint8(6), uint8(9), uint8(159), uint8(33), uint8(44), uint8(2), uint8(82), uint8(106), uint8(122), uint8(70), uint8(236), uint8(76), uint8(2), uint8(133), uint8(56), uint8(14), uint8(192), uint8(171), uint8(100), uint8(150), uint8(1), uint8(97), uint8(48), uint8(52), uint8(12), uint8(33), uint8(37), uint8(146), uint8(181), uint8(76), uint8(101), uint8(144), uint8(128), uint8(160), uint8(21), uint8(193), uint8(32), uint8(80), uint8(6), uint8(36), uint8(204), uint8(5), uint8(64), uint8(96), uint8(67), uint8(192), uint8(134), uint8(10), uint8(3), uint8(176), uint8(40), uint8(148), uint8(164), uint8(164), uint8(16), uint8(192), uint8(160), uint8(105), uint8(32), uint8(134), uint8(76), uint8(73), uint8(101), uint8(22), uint8(140), uint8(26), uint8(25), uint8(210), uint8(142), uint8(146), uint8(147), uint8(183), uint8(8), uint8(240), uint8(14), uint8(128), uint8(116), uint8(2), uint8(16), uint8(24), uint8(0), uint8(135), uint8(19), uint8(120), uint8(14), uint8(137), uint8(168), uint8(38), uint8(128), uint8(84), uint8(3), uint8(176), uint8(42), uint8(2), uint8(2), uint8(24), uint8(195), uint8(201), uint8(128), uint8(59), uint8(1), uint8(129), uint8(124), uint8(48), uint8(134), uint8(76), uint8(47), uint8(118), uint8(232), uint8(44), uint8(164), uint8(227), uint8(73), uint8(40), uint8(74), uint8(3), uint8(74), uint8(26), uint8(24), uint8(89), uint8(73), uint8(76), uint8(80), uint8(6), uint8(64), uint8(55), uint8(4), uint8(18), uint8(96), uint8(5), uint8(69), uint8(148), uint8(0), uint8(124), uint8(26), uint8(144), uint8(12), uint8(0), uint8(16), uint8(0), uint8(104), uint8(1), uint8(160), uint8(21), uint8(0), uint8(187), uint8(19), uint8(8), uint8(96), uint8(85), uint8(32), uint8(5), uint8(128), uint8(59), uint8(0), uint8(204), uint8(134), uint8(2), uint8(114), uint8(16), uint8(12), uint8(0), uint8(96), uint8(2), uint8(16), uint8(13), uint8(0), uint8(160), uint8(8), uint8(65), uint8(7), uint8(180), uint8(148), uint8(2), uint8(96), uint8(29), uint8(128), uint8(196), uint8(10), uint8(0), uint8(94), uint8(88), uint8(104), uint8(6), uint8(97), uint8(165), uint8(0), uint8(88), uint8(80), uint8(6), uint8(96), uint8(25), uint8(32), uint8(2), uint8(242), uint8(30), uint8(1), uint8(129), uint8(52), uint8(132), uint8(146), uint8(28), uint8(0), uint8(243), uint8(0), uint8(60), uint8(12), uint8(1), uint8(48), uint8(2), uint8(48), uint8(7), uint8(96), uint8(24), uint8(128), uint8(232), uint8(36), uint8(152), uint8(0), uint8(236), uint8(1), uint8(144), uint8(1), uint8(7), uint8(1), uint8(217), uint8(53), uint8(25), uint8(33), uint8(132), uint8(196), uint8(128), uint8(51), uint8(0), uint8(208), uint8(1), uint8(209), uint8(96), uint8(58), uint8(0), uint8(103), uint8(128), uint8(160), uint8(20), uint8(13), uint8(44), uint8(176), uint8(42), uint8(5), uint8(9), uint8(128), uint8(7), uint8(232), uint8(65), uint8(121), uint8(1), uint8(161), uint8(164), uint8(50), uint8(134), uint8(144), uint8(210), uint8(0), uint8(124), uint8(5), uint8(67), uint8(73), uint8(155), uint8(100), uint8(64), uint8(84), uint8(172), uint8(5), uint8(28), uint8(1), uint8(248), uint8(97), uint8(101), uint8(167), uint8(6), uint8(128), uint8(193), uint8(32), uint8(87), uint8(0), uint8(235), uint8(224), uint8(28), uint8(6), uint8(164), uint8(10), uint8(0), uint8(102), uint8(5), uint8(0), uint8(160), uint8(5), uint8(65), uint8(163), uint8(78), uint8(33), uint8(164), uint8(4), uint8(0), uint8(59), uint8(192), uint8(33), uint8(220), uint8(164), uint8(244), uint8(114), uint8(131), uint8(19), uint8(195), uint8(49), uint8(12), uint8(132), uint8(90), uint8(8), uint8(122), uint8(2), uint8(133), uint8(164), uint8(134), uint8(192), uint8(15), uint8(3), uint8(74), uint8(41), uint8(28), uint8(48), uint8(4), uint8(232), uint8(1), uint8(128), uint8(1), uint8(238), uint8(79), uint8(96), uint8(208), uint8(196), uint8(1), uint8(80), uint8(11), uint8(128), uint8(118), uint8(3), uint8(176), uint8(3), uint8(242), uint8(99), uint8(56), uint8(208), uint8(40), uint8(128), uint8(13), uint8(64), uint8(96), uint8(144), uint8(13), uint8(56), uint8(25), uint8(70), uint8(248), uint8(178), uint8(106), uint8(49), uint8(55), uint8(147), uint8(8), uint8(97), uint8(137), uint8(2), uint8(137), uint8(169), uint8(146), uint8(14), uint8(1), uint8(108), uint8(60), uint8(5), uint8(146), uint8(25), uint8(35), uint8(64), uint8(39), uint8(8), uint8(206), uint8(16), uint8(51), uint8(14), uint8(30), uint8(38), uint8(1), uint8(128), uint8(1), uint8(250), uint8(74), uint8(197), uint8(147), uint8(64), uint8(98), uint8(76), uint8(0), uint8(168), uint8(162), uint8(152), uint8(36), uint8(151), uint8(137), uint8(174), uint8(53), uint8(71), uint8(20), uint8(179), uint8(216), uint8(195), uint8(94), uint8(75), uint8(13), uint8(36), uint8(49), uint8(138), uint8(52), uint8(245), uint8(102), uint8(55), uint8(128), uint8(168), uint8(108), uint8(27), uint8(144), uint8(55), uint8(132), uint8(55), uint8(239), uint8(153), uint8(0), uint8(125), uint8(125), uint8(182), uint8(216), uint8(244), uint8(241), uint8(69), uint8(13), uint8(180), uint8(128), uint8(137), uint8(201), uint8(249), uint8(216), uint8(208), uint8(59), uint8(36), uint8(119), uint8(22), uint8(228), uint8(250), uint8(65), uint8(121), uint8(43), uint8(210), uint8(155), uint8(173), uint8(87), uint8(146), uint8(248), uint8(241), uint8(168), uint8(3), uint8(203), uint8(124), uint8(223), uint8(186), uint8(140), uint8(88), uint8(170), uint8(129), uint8(73), uint8(128), uint8(55), uint8(237), uint8(249), uint8(52), uint8(160), uint8(49), uint8(177), uint8(163), uint8(114), uint8(64), uint8(6), uint8(149), uint8(147), uint8(146), uint8(180), uint8(47), uint8(0), uint8(125), uint8(35), uint8(134), uint8(32), uint8(182), uint8(27), uint8(156), uint8(157), uint8(6), uint8(163), uint8(147), uint8(18), uint8(1), uint8(62), uint8(44), uint8(161), uint8(233), uint8(12), uint8(9), uint8(204), uint8(198), uint8(6), uint8(6), uint8(244), uint8(116), uint8(247), uint8(91), uint8(240), uint8(43), uint8(141), uint8(8), uint8(84), uint8(76), uint8(98), uint8(25), uint8(88), uint8(33), uint8(40), uint8(38), uint8(168), uint8(224), uint8(220), uint8(74), uint8(79), uint8(79), uint8(73), uint8(252), uint8(154), uint8(76), uint8(223), uint8(108), uint8(49), uint8(91), uint8(96), uint8(29), uint8(57), uint8(193), uint8(43), uint8(245), uint8(19), uint8(33), uint8(141), uint8(12), uint8(3), uint8(12), uint8(3), uint8(96), uint8(20), uint8(130), uint8(47), uint8(224), uint8(25), uint8(72), uint8(240), uint8(36), uint8(72), uint8(193), uint8(10), uint8(146), uint8(150), uint8(199), uint8(119), uint8(161), uint8(166), uint8(51), uint8(19), uint8(200), uint8(36), uint8(250), uint8(26), uint8(230), uint8(55), uint8(1), uint8(171), uint8(172), uint8(56), uint8(107), uint8(84), uint8(64), uint8(0), uint8(127), uint8(33), uint8(9), uint8(201), uint8(206), uint8(142), uint8(160), uint8(253), uint8(103), uint8(86), uint8(251), uint8(183), uint8(221), uint8(247), uint8(90), uint8(150), uint8(30), uint8(170), uint8(152), uint8(3), uint8(0), uint8(16), uint8(128), uint8(132), uint8(6), uint8(0), uint8(24), uint8(0), uint8(232), uint8(154), uint8(1), uint8(168), uint8(8), uint8(72), uint8(104), uint8(33), uint8(0), uint8(192), uint8(10), uint8(32), uint8(150), uint8(26), uint8(77), uint8(45), uint8(217), uint8(24), uint8(236), uint8(166), uint8(26), uint8(148), uint8(165), uint8(63), uint8(20), uint8(24), uint8(82), uint8(55), uint8(44), uint8(52), uint8(190), uint8(130), uint8(138), uint8(66), uint8(75), uint8(78), uint8(222), uint8(64), uint8(14), uint8(139), uint8(64), uint8(12), uint8(64), uint8(48), uint8(192), uint8(14), uint8(67), uint8(11), uint8(40), uint8(0), uint8(77), uint8(208), uint8(1), uint8(146), uint8(112), uint8(14), uint8(201), uint8(169), uint8(192), uint8(80), uint8(164), uint8(128), uint8(8), uint8(210), uint8(82), uint8(0), uint8(46), uint8(12), uint8(64), uint8(5), uint8(96), uint8(54), uint8(74), uint8(64), uint8(118), uint8(3), uint8(30), uint8(94), uint8(0), uint8(176), uint8(4), uint8(219), uint8(0), uint8(30), uint8(167), uint8(32), uint8(154), uint8(156), uint8(24), uint8(48), uint8(132), uint8(77), uint8(25), uint8(0), uint8(22), uint8(2), uint8(6), uint8(168), uint8(0), uint8(152), uint8(16), uint8(71), uint8(128), uint8(30), uint8(128), uint8(25), uint8(128), uint8(28), uint8(2), uint8(24), uint8(80), uint8(8), uint8(64), uint8(13), uint8(128), uint8(14), uint8(64), uint8(44), uint8(4), uint8(63), uint8(16), uint8(3), uint8(128), uint8(29), uint8(128), uint8(31), uint8(0), uint8(30), uint8(0), uint8(90), uint8(8), uint8(158), uint8(164), uint8(144), uint8(11), uint8(0), uint8(108), uint8(8), uint8(95), uint8(68), uint8(146), uint8(81), uint8(176), uint8(32), uint8(25), uint8(128), uint8(48), uint8(0), uint8(196), uint8(3), uint8(30), uint8(1), uint8(128), uint8(1), uint8(23), uint8(0), uint8(108), uint8(81), uint8(48), uint8(3), uint8(16), uint8(7), uint8(200), uint8(0), uint8(96), uint8(144), uint8(11), uint8(128), uint8(23), uint8(134), uint8(148), uint8(5), uint8(9), uint8(160), uint8(15), uint8(201), uint8(128), uint8(13), uint8(128), uint8(53), uint8(44), uint8(1), uint8(208), uint8(6), uint8(132), uint8(192), uint8(7), uint8(64), uint8(59), uint8(1), uint8(9), uint8(64), uint8(23), uint8(16), uint8(201), uint8(128), uint8(49), uint8(2), uint8(128), uint8(7), uint8(64), uint8(23), uint8(134), uint8(148), uint8(128), uint8(208), uint8(27), uint8(147), uint8(73), uint8(128), uint8(32), uint8(43), uint8(129), uint8(80), uint8(192), uint8(192), uint8(12), uint8(70), uint8(98), uint8(104), uint8(20), uint8(128), uint8(26), uint8(147), uint8(0), uint8(30), uint8(0), uint8(90), uint8(0), uint8(233), uint8(0), uint8(33), uint8(43), uint8(165), uint8(4), uint8(208), uint8(3), uint8(114), uint8(105), uint8(49), uint8(60), uint8(154), uint8(5), uint8(128), uint8(117), uint8(200), uint8(68), uint8(32), uint8(24), uint8(112), uint8(29), uint8(129), uint8(128), uint8(196), uint8(158), uint8(0), uint8(118), uint8(67), uint8(37), uint8(36), uint8(132), uint8(5), uint8(22), uint8(220), uint8(10), uint8(134), uint8(147), uint8(3), uint8(49), uint8(49), uint8(32), uint8(126), uint8(0), uint8(92), uint8(26), uint8(0), uint8(228), uint8(2), uint8(160), uint8(6), uint8(229), uint8(128), uint8(104), uint8(90), uint8(10), uint8(44), uint8(152), uint8(0), uint8(108), uint8(76), uint8(38), uint8(148), uint8(130), uint8(19), uint8(164), uint8(6), uint8(40), uint8(2), uint8(164), uint8(48), uint8(19), uint8(224), uint8(19), uint8(0), uint8(220), uint8(134), uint8(135), uint8(25), uint8(128), uint8(64), uint8(3), uint8(160), uint8(50), uint8(80), uint8(14), uint8(192), uint8(171), uint8(97), uint8(184), uint8(7), uint8(65), uint8(132), uint8(48), uint8(208), uint8(11), uint8(74), uint8(203), uint8(69), uint8(82), uint8(12), uint8(224), uint8(53), uint8(28), uint8(71), uint8(70), uint8(231), uint8(145), uint8(101), uint8(169), uint8(133), uint8(29), uint8(67), uint8(48), uint8(120), uint8(243), uint8(78), uint8(168), uint8(20), uint8(6), uint8(33), uint8(128), uint8(48), uint8(72), uint8(12), uint8(72), uint8(97), uint8(128), uint8(80), uint8(4), uint8(0), uint8(133), uint8(242), uint8(26), uint8(26), uint8(75), uint8(24), uint8(134), uint8(37), uint8(0), uint8(225), uint8(29), uint8(61), uint8(97), uint8(169), uint8(70), uint8(36), uint8(100), uint8(158), uint8(199), uint8(40), uint8(248), uint8(10), uint8(144), uint8(192), uint8(161), uint8(52), uint8(6), uint8(4), uint8(212), uint8(129), uint8(66), uint8(26), uint8(9), uint8(68), uint8(210), uint8(153), uint8(208), uint8(232), uint8(231), uint8(236), uint8(156), uint8(178), uint8(191), uint8(65), uint8(35), uint8(129), uint8(24), uint8(4), uint8(32), uint8(38), uint8(0), uint8(196), uint8(4), uint8(224), uint8(25), uint8(13), uint8(224), uint8(48), uint8(38), uint8(129), uint8(130), uint8(91), uint8(13), uint8(2), uint8(193), uint8(133), uint8(184), uint8(193), uint8(172), uint8(1), uint8(58), uint8(18), uint8(4), uint8(210), uint8(116), uint8(0), uint8(240), uint8(4), uint8(32), uint8(131), uint8(212), uint8(24), uint8(75), uint8(13), uint8(0), uint8(124), uint8(0), uint8(38), uint8(1), uint8(59), uint8(1), uint8(77), uint8(137), uint8(128), uint8(26), uint8(0), uint8(99), uint8(192), uint8(168), uint8(6), uint8(64), uint8(100), uint8(6), uint8(32), uint8(21), uint8(160), uint8(104), uint8(104), uint8(104), uint8(3), uint8(112), uint8(29), uint8(6), uint8(0), uint8(99), uint8(137), uint8(132), uint8(36), uint8(0), uint8(152), uint8(151), uint8(144), uint8(5), uint8(16), uint8(0), uint8(176), uint8(134), uint8(89), uint8(96), uint8(85), uint8(8), uint8(112), uint8(29), uint8(148), uint8(82), uint8(120), uint8(200), uint8(1), uint8(232), uint8(20), uint8(72), uint8(3), uint8(64), uint8(220), uint8(128), uint8(192), uint8(13), uint8(74), uint8(0), uint8(196), uint8(4), uint8(5), uint8(128), uint8(87), uint8(210), uint8(88), uint8(8), uint8(64), uint8(52), uint8(0), uint8(176), uint8(3), uint8(80), uint8(194), uint8(128), uint8(96), uint8(0), uint8(124), uint8(156), uint8(130), uint8(96), uint8(96), uint8(3), uint8(128), uint8(29), uint8(164), uint8(4), uint8(5), uint8(134), uint8(129), uint8(82), uint8(192), uint8(79), uint8(144), uint8(146), uint8(192), uint8(98), uint8(144), uint8(5), uint8(97), uint8(133), uint8(20), uint8(5), uint8(18), uint8(157), uint8(128), uint8(76), uint8(148), uint8(149), uint8(186), uint8(106), uint8(98), uint8(111), uint8(190), uint8(39), uint8(64), uint8(14), uint8(48), uint8(12), uint8(0), uint8(28), uint8(128), uint8(8), uint8(120), uint8(12), uint8(120), uint8(3), uint8(87), uint8(0), uint8(124), uint8(166), uint8(0), uint8(112), uint8(0), uint8(100), uint8(5), uint8(2), uint8(24), uint8(10), uint8(18), uint8(184), uint8(33), uint8(121), uint8(184), uint8(5), uint8(125), uint8(200), uint8(96), uint8(133), uint8(242), uint8(180), uint8(40), uint8(16), uint8(193), uint8(64), uint8(113), uint8(19), uint8(9), uint8(132), uint8(50), uint8(104), uint8(105), uint8(92), uint8(2), uint8(176), uint8(29), uint8(0), uint8(30), uint8(37), uint8(77), uint8(128), uint8(110), uint8(130), uint8(104), uint8(31), uint8(230), uint8(149), uint8(182), uint8(82), uint8(130), uint8(226), uint8(210), uint8(80), uint8(198), uint8(248), uint8(52), uint8(48), uint8(53), uint8(72), uint8(252), uint8(148), uint8(53), uint8(31), uint8(116), uint8(240), uint8(28), uint8(124), uint8(90), uint8(10), uint8(74), uint8(82), uint8(131), uint8(146), uint8(6), uint8(0), uint8(201), uint8(64), uint8(2), uint8(148), uint8(229), uint8(197), uint8(150), uint8(24), uint8(74), uint8(100), uint8(160), uint8(154), uint8(76), uint8(13), uint8(196), uint8(164), uint8(37), uint8(35), uint8(9), uint8(104), uint8(225), uint8(156), uint8(183), uint8(1), uint8(66), uint8(80), uint8(67), uint8(64), uint8(98), uint8(120), uint8(105), uint8(64), uint8(127), uint8(147), uint8(0), uint8(110), uint8(25), uint8(140), uint8(13), uint8(78), uint8(169), uint8(136), uint8(249), uint8(9), uint8(60), uint8(56), uint8(252), uint8(120), uint8(16), uint8(160), uint8(33), uint8(22), uint8(3), uint8(16), uint8(29), uint8(16), uint8(192), uint8(76), uint8(77), uint8(44), uint8(7), uint8(64), uint8(59), uint8(40), uint8(12), uint8(19), uint8(74), uint8(24), uint8(53), uint8(14), uint8(82), uint8(88), uint8(110), uint8(66), uint8(114), uint8(208), uint8(148), uint8(226), uint8(66), uint8(119), uint8(60), uint8(141), uint8(228), uint8(1), uint8(217), uint8(190), uint8(78), uint8(221), uint8(31), uint8(37), uint8(28), uint8(228), uint8(229), uint8(230), uint8(63), uint8(44), uint8(93), uint8(22), uint8(24), uint8(89), uint8(48), uint8(154), uint8(88), uint8(97), uint8(52), uint8(49), uint8(36), uint8(194), uint8(105), uint8(69), uint8(146), uint8(137), uint8(165), uint8(22), uint8(132), uint8(134), uint8(6), uint8(226), uint8(202), uint8(8), uint8(73), uint8(65), uint8(168), uint8(251), uint8(39), uint8(37), uint8(29), uint8(247), uint8(66), uint8(87), uint8(142), uint8(50), uint8(166), uint8(0), uint8(100), uint8(3), uint8(16), uint8(11), uint8(195), uint8(0), uint8(48), uint8(1), uint8(129), uint8(52), uint8(4), uint8(32), uint8(23), uint8(130), uint8(16), uint8(80), uint8(12), uint8(8), uint8(68), uint8(162), uint8(88), uint8(106), uint8(201), uint8(160), uint8(57), uint8(47), uint8(19), uint8(16), uint8(5), uint8(136), uint8(72), uint8(44), uint8(176), uint8(28), uint8(164), uint8(172), uint8(164), uint8(118), uint8(119), uint8(57), uint8(112), uint8(9), uint8(128), uint8(50), uint8(0), uint8(204), uint8(6), uint8(0), uint8(15), uint8(192), uint8(96), uint8(24), uint8(1), uint8(168), uint8(8), uint8(9), uint8(160), uint8(55), uint8(1), uint8(209), uint8(12), uint8(150), uint8(74), uint8(13), uint8(37), uint8(6), uint8(134), uint8(57), uint8(40), uint8(52), uint8(176), uint8(196), uint8(132), uint8(6), uint8(148), uint8(81), uint8(106), uint8(44), uint8(162), uint8(242), uint8(246), uint8(57), uint8(242), uint8(154), uint8(76), uint8(0), uint8(200), uint8(1), uint8(184), uint8(2), uint8(160), uint8(7), uint8(0), uint8(12), uint8(64), uint8(44), uint8(224), uint8(15), uint8(64), uint8(96), uint8(0), uint8(126), uint8(0), uint8(120), uint8(75), uint8(0), uint8(176), uint8(16), uint8(190), uint8(128), uint8(118), uint8(76), uint8(37), uint8(0), uint8(90), uint8(6), uint8(0), uint8(200), uint8(33), uint8(131), uint8(147), uint8(67), uint8(6), uint8(141), uint8(37), uint8(20), uint8(73), uint8(118), uint8(96), uint8(134), uint8(127), uint8(6), uint8(16), uint8(240), uint8(14), uint8(246), uint8(74), uint8(64), uint8(117), uint8(136), uint8(69), uint8(167), uint8(96), uint8(130), uint8(17), uint8(12), uint8(176), uint8(210), uint8(22), uint8(233), uint8(233), uint8(199), uint8(128), uint8(236), uint8(49), uint8(0), uint8(59), uint8(229), uint8(35), uint8(20), uint8(53), uint8(64), uint8(7), uint8(65), uint8(163), uint8(82), uint8(193), uint8(56), uint8(200), uint8(1), uint8(24), uint8(6), uint8(5), uint8(128), uint8(19), uint8(0), uint8(237), uint8(1), uint8(132), uint8(32), uint8(6), uint8(225), uint8(128), uint8(11), uint8(192), uint8(28), uint8(19), uint8(75), uint8(0), uint8(204), uint8(180), uint8(129), uint8(80), uint8(7), uint8(32), uint8(13), uint8(56), uint8(9), uint8(128), uint8(26), uint8(128), uint8(232), uint8(10), uint8(0), uint8(62), uint8(64), uint8(6), uint8(73), uint8(193), uint8(128), uint8(38), uint8(2), uint8(128), uint8(5), uint8(64), uint8(23), uint8(134), uint8(128), uint8(56), uint8(2), uint8(160), uint8(84), uint8(3), uint8(50), uint8(104), uint8(3), uint8(220), uint8(24), uint8(88), uint8(104), uint8(5), uint8(225), uint8(160), uint8(129), uint8(166), uint8(66), uint8(2), uint8(132), uint8(192), uint8(16), uint8(6), uint8(134), uint8(228), uint8(0), uint8(58), uint8(38), uint8(147), uint8(74), uint8(40), uint8(12), uint8(197), uint8(140), uint8(73), uint8(5), uint8(20), uint8(80), uint8(97), uint8(100), uint8(208), uint8(212), uint8(20), uint8(81), uint8(44), uint8(134), uint8(74), uint8(3), uint8(41), uint8(229), uint8(33), uint8(61), uint8(32), uint8(99), uint8(49), uint8(68), uint8(157), uint8(206), uint8(195), uint8(152), uint8(93), uint8(108), uint8(219), uint8(63), uint8(27), uint8(199), uint8(171), uint8(56), uint8(118), uint8(208), uint8(241), uint8(166), uint8(143), uint8(16), uint8(112), uint8(152), uint8(118), uint8(64), uint8(30), uint8(65), uint8(44), uint8(98), uint8(0), uint8(242), uint8(0), uint8(201), uint8(100), uint8(178), uint8(254), uint8(65), uint8(219), uint8(164), uint8(176), uint8(158), uint8(156), uint8(183), uint8(233), uint8(238), uint8(19), uint8(238), uint8(192), uint8(160), uint8(80), uint8(154), uint8(2), uint8(16), uint8(29), uint8(19), uint8(0), uint8(168), uint8(12), uint8(0), uint8(64), uint8(26), uint8(26), uint8(192), uint8(84), uint8(4), uint8(32), uint8(22), uint8(128), uint8(30), uint8(6), uint8(18), uint8(139), uint8(224), uint8(100), uint8(2), uint8(164), uint8(1), uint8(146), uint8(24), uint8(78), uint8(221), uint8(8), uint8(24), uint8(134), uint8(72), uint8(23), uint8(74), uint8(28), uint8(15), uint8(63), uint8(158), uint8(1), uint8(129), uint8(48), uint8(3), uint8(32), uint8(24), uint8(16), uint8(128), uint8(118), uint8(2), uint8(112), uint8(16), uint8(134), uint8(6), uint8(12), uint8(1), uint8(216), uint8(6), uint8(96), uint8(21), uint8(0), uint8(30), uint8(150), uint8(75), uint8(13), uint8(224), uint8(100), uint8(0), uint8(240), uint8(48), uint8(12), uint8(1), uint8(64), uint8(132), uint8(167), uint8(148), uint8(80), uint8(194), uint8(187), uint8(0), uint8(161), uint8(8), uint8(26), uint8(121), uint8(111), uint8(224), uint8(148), uint8(190), uint8(82), uint8(62), uint8(252), uint8(39), uint8(191), uint8(195), uint8(16), uint8(74), uint8(235), uint8(219), uint8(100), uint8(146), uint8(249), uint8(45), uint8(179), uint8(126), uint8(86), uint8(25), uint8(250), uint8(93), uint8(208), uint8(49), uint8(48), uint8(6), uint8(96), uint8(132), uint8(34), uint8(146), uint8(16), uint8(34), uint8(121), uint8(129), uint8(64), uint8(24), uint8(147), uint8(0), uint8(52), uint8(28), uint8(5), uint8(0), uint8(53), uint8(33), uint8(0), uint8(98), uint8(0), uint8(244), uint8(0), uint8(67), uint8(129), uint8(28), uint8(56), uint8(176), uint8(6), uint8(64), uint8(26), uint8(32), uint8(1), uint8(129), uint8(96), uint8(141), uint8(206), uint8(5), uint8(67), uint8(64), uint8(30), uint8(128), uint8(104), uint8(8), uint8(128), uint8(128), uint8(48), uint8(0), uint8(118), uint8(8), uint8(66), uint8(176), uint8(0), uint8(0), uint8(1), uint8(0), uint8(2), uint8(215), uint8(255), uint8(248), uint8(128), uint8(0), uint8(0), uint8(1), uint8(1), uint8(18), uint8(137), uint8(134), uint8(141), uint8(12), uint8(13), uint8(13), uint8(118), uint8(0), uint8(62), uint8(12), uint8(230), uint8(63), uint8(38), uint8(140), uint8(108), uint8(23), uint8(221), uint8(56), uint8(57), uint8(224), uint8(1), uint8(236), uint8(20), uint8(179), uint8(216), uint8(13), uint8(7), uint8(156), uint8(241), uint8(167), uint8(169), uint8(70), uint8(152), uint8(228), uint8(229), uint8(49), uint8(158), uint8(52), uint8(14), uint8(6), uint8(160), uint8(31), uint8(10), uint8(175), uint8(219), uint8(63), uint8(56), uint8(44), uint8(118), uint8(196), uint8(241), uint8(208), uint8(129), uint8(108), uint8(62), uint8(243), uint8(244), uint8(178), uint8(51), uint8(247), uint8(100), uint8(35), uint8(31), uint8(192), uint8(59), uint8(169), uint8(128), uint8(49), uint8(1), uint8(208), uint8(9), uint8(128), uint8(168), uint8(8), uint8(121), uint8(55), uint8(16), uint8(178), uint8(6), uint8(1), uint8(64), uint8(29), uint8(16), uint8(192), uint8(53), uint8(1), uint8(137), uint8(52), uint8(154), uint8(77), uint8(33), uint8(0), uint8(232), uint8(6), uint8(0), uint8(38), uint8(1), uint8(0), uint8(12), uint8(10), uint8(225), uint8(160), uint8(84), uint8(4), uint8(224), uint8(39), uint8(1), uint8(56), uint8(14), uint8(203), uint8(38), uint8(0), uint8(192), uint8(4), uint8(192), uint8(58), uint8(33), uint8(21), uint8(191), uint8(44), uint8(10), uint8(129), uint8(82), uint8(104), uint8(97), uint8(51), uint8(41), uint8(3), uint8(70), uint8(167), uint8(34), uint8(24), uint8(18), uint8(76), uint8(2), uint8(128), uint8(85), uint8(1), uint8(32), uint8(80), uint8(6), uint8(36), uint8(204), uint8(3), uint8(176), uint8(29), uint8(16), uint8(242), uint8(201), uint8(128), uint8(59), uint8(33), uint8(37), uint8(41), uint8(70), uint8(33), uint8(129), uint8(66), uint8(201), uint8(4), uint8(210), uint8(103), uint8(73), uint8(69), uint8(163), uint8(6), uint8(134), uint8(126), uint8(87), uint8(229), uint8(124), uint8(234), uint8(240), uint8(3), uint8(144), uint8(24), uint8(0), uint8(93), uint8(128), uint8(26), uint8(128), uint8(50), uint8(0), uint8(98), uint8(1), uint8(130), uint8(64), uint8(98), uint8(3), uint8(162), uint8(195), uint8(16), uint8(144), uint8(6), uint8(192), uint8(13), uint8(192), uint8(168), uint8(2), uint8(96), uint8(19), uint8(147), uint8(3), uint8(120), uint8(12), uint8(0), uint8(18), uint8(128), uint8(232), uint8(1), uint8(112), uint8(6), uint8(160), uint8(6), uint8(160), uint8(49), uint8(38), uint8(16), uint8(195), uint8(73), uint8(128), uint8(26), uint8(128), uint8(92), uint8(88), uint8(192), uint8(16), uint8(1), uint8(68), uint8(6), uint8(128), uint8(236), uint8(0), uint8(241), uint8(4), uint8(52), uint8(128), uint8(90), uint8(1), uint8(56), uint8(1), uint8(240), uint8(21), uint8(0), uint8(60), uint8(104), uint8(16), uint8(70), uint8(9), uint8(164), uint8(194), uint8(129), uint8(0), uint8(232), uint8(16), uint8(11), uint8(64), uint8(29), uint8(0), uint8(80), uint8(3), uint8(160), uint8(24), uint8(128), uint8(92), uint8(77), uint8(0), uint8(41), uint8(33), uint8(144), uint8(192), uint8(26), uint8(32), uint8(180), uint8(147), uint8(64), uint8(168), uint8(2), uint8(224), uint8(40), uint8(0), uint8(220), uint8(1), uint8(121), uint8(96), uint8(25), uint8(128), uint8(92), uint8(1), uint8(144), uint8(6), uint8(33), uint8(169), uint8(13), uint8(13), uint8(79), uint8(1), uint8(56), uint8(1), uint8(225), uint8(104), uint8(1), uint8(137), uint8(40), uint8(154), uint8(128), uint8(29), uint8(0), uint8(196), uint8(160), uint8(24), uint8(16), uint8(192), uint8(116), uint8(0), uint8(126), uint8(3), uint8(2), uint8(186), uint8(80), uint8(77), uint8(33), uint8(196), uint8(32), uint8(50), uint8(55), uint8(6), uint8(140), uint8(228), uint8(176), uint8(210), uint8(128), uint8(26), uint8(128), uint8(192), uint8(3), uint8(2), uint8(200), uint8(72), uint8(38), uint8(39), uint8(0), uint8(88), uint8(2), uint8(98), uint8(24), uint8(3), uint8(64), uint8(12), uint8(64), uint8(49), uint8(0), uint8(53), uint8(44), uint8(55), uint8(253), uint8(203), uint8(26), uint8(3), uint8(16), uint8(24), uint8(6), uint8(0), uint8(131), uint8(1), uint8(130), uint8(16), uint8(1), uint8(193), uint8(92), uint8(189), uint8(146), uint8(1), uint8(159), uint8(1), uint8(8), uint8(110), uint8(0), uint8(208), uint8(50), uint8(2), uint8(188), uint8(152), uint8(49), uint8(36), uint8(204), uint8(148), uint8(18), uint8(137), uint8(129), uint8(160), uint8(12), uint8(0), uint8(78), uint8(0), uint8(252), uint8(160), uint8(43), uint8(201), uint8(165), uint8(112), uint8(11), uint8(64), uint8(78), uint8(5), uint8(0), uint8(23), uint8(128), uint8(92), uint8(0), uint8(248), uint8(0), uint8(200), uint8(162), uint8(97), uint8(89), uint8(131), uint8(58), uint8(0), uint8(76), uint8(2), uint8(18), uint8(192), uint8(53), uint8(224), uint8(100), uint8(10), uint8(128), uint8(26), uint8(151), uint8(131), uint8(63), uint8(64), uint8(5), uint8(200), uint8(0), uint8(208), uint8(51), uint8(128), uint8(102), uint8(27), uint8(83), uint8(10), uint8(199), uint8(0), uint8(127), uint8(35), uint8(31), uint8(1), uint8(76), uint8(130), uint8(104), uint8(97), uint8(51), uint8(44), uint8(2), uint8(176), uint8(220), uint8(41), uint8(4), uint8(194), uint8(91), uint8(164), uint8(41), uint8(3), uint8(52), uint8(76), uint8(225), uint8(165), uint8(20), uint8(89), uint8(65), uint8(159), uint8(178), uint8(67), uint8(70), uint8(129), uint8(140), uint8(220), uint8(36), uint8(148), uint8(180), uint8(153), uint8(246), uint8(25), uint8(190), uint8(60), uint8(249), uint8(45), uint8(215), uint8(176), uint8(73), uint8(236), uint8(48), uint8(214), uint8(119), uint8(237), uint8(194), uint8(88), uint8(211), uint8(177), uint8(30), uint8(75), uint8(45), uint8(65), uint8(36), uint8(147), uint8(141), uint8(108), uint8(255), uint8(183), uint8(9), uint8(102), uint8(30), uint8(140), uint8(109), uint8(68), uint8(183), uint8(237), uint8(179), uint8(171), uint8(56), uint8(233), uint8(107), uint8(130), uint8(172), uint8(252), uint8(61), uint8(66), uint8(78), uint8(205), uint8(131), uint8(181), uint8(64), uint8(72), uint8(26), uint8(223), uint8(99), uint8(82), uint8(72), uint8(22), uint8(193), uint8(202), uint8(144), uint8(217), uint8(248), uint8(177), uint8(98), uint8(172), uint8(32), uint8(94), uint8(225), uint8(201), uint8(91), uint8(135), uint8(12), uint8(195), uint8(1), uint8(31), uint8(245), uint8(120), uint8(7), uint8(161), uint8(18), uint8(2), uint8(69), uint8(116), uint8(13), uint8(16), uint8(200), uint8(24), uint8(30), uint8(75), uint8(73), uint8(44), uint8(5), uint8(65), uint8(0), uint8(42), uint8(9), uint8(168), uint8(241), uint8(53), uint8(32), uint8(96), uint8(176), uint8(208), uint8(132), uint8(0), uint8(88), uint8(80), uint8(231), uint8(225), uint8(163), uint8(27), uint8(15), uint8(87), uint8(235), uint8(172), uint8(179), uint8(247), uint8(194), uint8(64), uint8(226), uint8(130), uint8(171), uint8(8), uint8(248), uint8(87), uint8(32), uint8(224), uint8(128), uint8(175), uint8(81), uint8(38), uint8(61), uint8(191), uint8(138), uint8(13), uint8(223), uint8(149), uint8(246), uint8(61), uint8(68), uint8(123), uint8(206), uint8(132), uint8(238), uint8(59), uint8(238), uint8(31), uint8(151), uint8(36), uint8(152), uint8(95), uint8(12), uint8(38), uint8(148), uint8(67), uint8(71), uint8(223), uint8(134), uint8(36), uint8(162), uint8(209), uint8(184), uint8(14), uint8(28), uint8(164), uint8(190), uint8(57), uint8(97), uint8(61), uint8(92), uint8(36), uint8(237), uint8(152), uint8(98), uint8(234), uint8(34), uint8(156), uint8(87), uint8(225), uint8(128), uint8(59), uint8(38), uint8(186), uint8(16), uint8(66), uint8(1), uint8(48), uint8(12), uint8(9), uint8(160), uint8(33), uint8(1), uint8(56), uint8(21), uint8(38), uint8(150), uint8(24), uint8(66), uint8(33), uint8(0), uint8(232), uint8(7), uint8(68), uint8(44), uint8(2), uint8(146), uint8(105), uint8(12), uint8(154), uint8(67), uint8(74), uint8(9), uint8(129), uint8(136), uint8(126), uint8(130), uint8(144), uint8(53), uint8(32), uint8(41), uint8(38), uint8(150), uint8(24), uint8(66), uint8(12), uint8(201), uint8(33), uint8(147), uint8(74), uint8(71), uint8(128), uint8(31), uint8(150), uint8(88), uint8(3), uint8(96), uint8(208), uint8(64), uint8(49), uint8(4), uint8(12), uint8(224), uint8(7), uint8(128), uint8(23), uint8(144), uint8(128), uint8(64), uint8(1), uint8(152), uint8(12), uint8(64), uint8(98), uint8(2), uint8(0), uint8(13), uint8(0), uint8(98), uint8(0), uint8(240), uint8(1), uint8(192), uint8(14), uint8(203), uint8(40), uint8(152), uint8(77), uint8(0), uint8(122), uint8(5), uint8(64), uint8(28), uint8(112), uint8(16), uint8(128), uint8(156), uint8(134), uint8(5), uint8(0), uint8(31), uint8(6), uint8(150), uint8(18), uint8(0), uint8(35), uint8(0), uint8(60), uint8(37), uint8(128), uint8(84), uint8(80), uint8(12), uint8(28), uint8(2), uint8(244), uint8(224), uint8(50), uint8(144), uint8(19), uint8(6), uint8(6), uint8(240), uint8(194), uint8(198), uint8(69), uint8(6), uint8(167), uint8(160), uint8(2), uint8(198), uint8(40), uint8(178), uint8(201), uint8(96), uint8(39), uint8(0), uint8(200), uint8(10), uint8(22), uint8(74), uint8(217), uint8(60), uint8(162), uint8(96), uint8(14), uint8(192), uint8(66), uint8(5), uint8(0), uint8(160), uint8(21), uint8(2), uint8(173), uint8(210), uint8(24), uint8(129), uint8(128), uint8(58), uint8(12), uint8(13), uint8(72), uint8(21), uint8(47), uint8(134), uint8(147), uint8(67), uint8(3), uint8(50), uint8(3), uint8(63), uint8(13), uint8(13), uint8(41), uint8(3), uint8(83), uint8(160), uint8(208), uint8(194), uint8(176), uint8(104), uint8(5), uint8(174), uint8(26), uint8(81), uint8(64), uint8(96), uint8(3), uint8(32), uint8(12), uint8(64), uint8(118), uint8(80), uint8(25), uint8(79), uint8(66), uint8(3), uint8(73), uint8(160), uint8(38), uint8(0), uint8(200), uint8(10), uint8(128), uint8(196), uint8(10), uint8(1), uint8(71), uint8(197), uint8(22), uint8(145), uint8(160), uint8(49), uint8(38), uint8(147), uint8(10), uint8(1), uint8(209), uint8(88), uint8(48), uint8(152), uint8(26), uint8(27), uint8(203), uint8(13), uint8(70), uint8(12), uint8(38), uint8(6), uint8(151), uint8(208), uint8(87), uint8(168), uint8(248), uint8(3), uint8(32), uint8(4), uint8(192), uint8(134), uint8(42), uint8(3), uint8(0), uint8(72), uint8(250), uint8(4), uint8(191), uint8(130), uint8(28), uint8(76), uint8(225), uint8(172), uint8(67), uint8(12), uint8(33), uint8(48), uint8(14), uint8(73), uint8(132), uint8(210), uint8(221), uint8(206), uint8(3), uint8(28), uint8(132), uint8(131), uint8(135), uint8(164), uint8(6), uint8(227), uint8(243), uint8(49), uint8(176), uint8(6), uint8(33), uint8(128), uint8(25), uint8(18), uint8(192), uint8(29), uint8(0), uint8(132), uint8(1), uint8(248), uint8(25), uint8(96), uint8(3), uint8(160), uint8(12), uint8(192), uint8(30), uint8(0), uint8(104), uint8(3), uint8(98), uint8(80), uint8(14), uint8(64), uint8(12), uint8(192), uint8(160), uint8(3), uint8(178), uint8(25), uint8(44), uint8(12), uint8(141), uint8(2), uint8(192), uint8(54), uint8(0), uint8(17), uint8(12), uint8(24), uint8(74), uint8(72), uint8(25), uint8(1), uint8(187), uint8(185), uint8(64), uint8(97), uint8(139), uint8(168), uint8(212), uint8(217), uint8(221), uint8(151), uint8(52), uint8(97), uint8(219), uint8(97), uint8(24), uint8(159), uint8(199), uint8(129), uint8(27), uint8(15), uint8(48), uint8(176), uint8(6), uint8(64), uint8(80), uint8(52), uint8(1), uint8(56), uint8(20), uint8(224), uint8(39), uint8(0), uint8(109), uint8(128), uint8(15), uint8(64), uint8(166), uint8(1), uint8(43), uint8(160), uint8(132), uint8(193), uint8(33), uint8(165), uint8(18), uint8(0), uint8(118), uint8(3), uint8(98), uint8(201), uint8(36), uint8(192), uint8(220), uint8(72), uint8(49), uint8(206), uint8(232), uint8(254), uint8(37), uint8(97), uint8(165), uint8(236), uint8(131), uint8(251), uint8(176), uint8(118), uint8(113), uint8(23), uint8(0), uint8(135), uint8(0), uint8(94), uint8(2), uint8(20), uint8(0), uint8(235), uint8(0), uint8(155), uint8(19), uint8(65), uint8(8), uint8(31), uint8(59), uint8(20), uint8(74), uint8(12), uint8(52), uint8(176), uint8(51), uint8(194), uint8(73), uint8(68), uint8(190), uint8(5), uint8(197), uint8(192), uint8(14), uint8(0), uint8(98), uint8(80), uint8(3), uint8(148), uint8(16), uint8(198), uint8(128), uint8(105), uint8(128), uint8(48), uint8(2), uint8(160), uint8(48), uint8(44), uint8(6), uint8(32), uint8(58), uint8(192), uint8(22), uint8(0), uint8(196), uint8(176), uint8(42), uint8(2), uint8(96), uint8(42), uint8(3), uint8(0), uint8(13), uint8(2), uint8(112), uint8(9), uint8(201), uint8(160), uint8(7), uint8(100), uint8(192), uint8(192), uint8(13), uint8(74), uint8(0), uint8(126), uint8(3), uint8(188), uint8(197), uint8(112), uint8(29), uint8(0), uint8(232), uint8(0), uint8(224), uint8(1), uint8(208), uint8(98), uint8(113), uint8(45), uint8(5), uint8(128), uint8(157), uint8(10), uint8(76), uint8(1), uint8(168), uint8(14), uint8(128), uint8(4), uint8(201), uint8(0), uint8(208), uint8(49), uint8(0), uint8(39), uint8(44), uint8(4), uint8(36), uint8(192), uint8(7), uint8(225), uint8(128), uint8(32), uint8(2), uint8(160), uint8(22), uint8(128), uint8(196), uint8(6), uint8(5), uint8(16), uint8(128), uint8(168), uint8(6), uint8(128), uint8(25), uint8(128), uint8(94), uint8(16), uint8(0), uint8(120), uint8(80), uint8(96), uint8(6), uint8(4), uint8(210), uint8(104), uint8(12), uint8(0), uint8(168), uint8(3), uint8(32), uint8(16), uint8(112), uint8(20), uint8(128), uint8(86), uint8(77), uint8(72), uint8(3), uint8(240), uint8(5), uint8(164), uint8(52), uint8(1), uint8(110), uint8(81), uint8(49), uint8(33), uint8(58), uint8(194), uint8(166), uint8(92), uint8(208), uint8(85), uint8(253), uint8(32), uint8(121), uint8(141), uint8(1), uint8(168), uint8(223), uint8(160), uint8(11), uint8(137), uint8(133), uint8(0), uint8(102), uint8(2), uint8(96), uint8(12), uint8(3), uint8(10), uint8(38), uint8(147), uint8(65), uint8(7), uint8(172), uint8(3), uint8(52), uint8(100), uint8(32), uint8(52), uint8(134), uint8(74), uint8(33), uint8(0), uint8(96), uint8(0), uint8(127), uint8(210), uint8(90), uint8(114), uint8(67), uint8(64), uint8(194), uint8(6), uint8(147), uint8(9), uint8(132), uint8(162), uint8(131), uint8(121), uint8(100), uint8(164), uint8(18), uint8(64), uint8(195), uint8(101), uint8(166), uint8(24), uint8(127), uint8(18), uint8(160), uint8(73), uint8(253), uint8(79), uint8(34), uint8(235), uint8(74), uint8(6), uint8(117), uint8(36), uint8(162), uint8(202), uint8(26), uint8(148), uint8(98), uint8(208), uint8(236), uint8(145), uint8(140), uint8(19), uint8(144), uint8(94), uint8(64), uint8(106), uint8(17), uint8(207), uint8(71), uint8(44), uint8(48), uint8(160), uint8(180), uint8(125), uint8(172), uint8(178), uint8(137), uint8(67), uint8(88), uint8(178), uint8(137), uint8(168), uint8(201), uint8(45), uint8(24), uint8(176), uint8(207), uint8(216), uint8(178), uint8(83), uint8(57), uint8(121), uint8(5), uint8(226), uint8(136), uint8(120), uint8(164), uint8(171), uint8(163), uint8(134), uint8(147), uint8(3), uint8(56), uint8(161), uint8(168), uint8(78), uint8(213), uint8(50), uint8(108), uint8(238), uint8(7), uint8(249), uint8(225), uint8(213), uint8(135), uint8(57), uint8(58), uint8(64), uint8(6), uint8(213), uint8(143), uint8(214), uint8(2), uint8(226), uint8(112), uint8(168), uint8(163), uint8(142), uint8(204), uint8(121), uint8(63), uint8(172), uint8(158), uint8(40), uint8(247), uint8(31), uint8(80), uint8(40), uint8(12), uint8(3), uint8(64), uint8(66), uint8(3), uint8(2), uint8(16), uint8(14), uint8(192), uint8(76), uint8(2), uint8(96), uint8(210), uint8(198), uint8(1), uint8(80), uint8(12), uint8(192), uint8(45), uint8(0), uint8(60), uint8(40), uint8(96), uint8(106), uint8(73), uint8(96), uint8(7), uint8(197), uint8(96), uint8(210), uint8(24), uint8(74), uint8(17), uint8(202), uint8(64), uint8(194), uint8(187), uint8(129), uint8(116), uint8(160), uint8(105), uint8(217), uint8(251), uint8(237), uint8(3), uint8(159), uint8(252), uint8(2), uint8(98), uint8(128), uint8(50), uint8(1), uint8(128), uint8(20), uint8(1), uint8(216), uint8(8), uint8(64), uint8(51), uint8(38), uint8(6), uint8(12), uint8(1), uint8(56), uint8(6), uint8(32), uint8(21), uint8(0), uint8(30), uint8(134), uint8(146), uint8(195), uint8(120), uint8(13), uint8(192), uint8(15), uint8(138), uint8(0), uint8(176), uint8(132), uint8(5), uint8(146), uint8(95), uint8(12), uint8(65), uint8(40), uint8(49), uint8(208), uint8(2), uint8(132), uint8(32), uint8(105), uint8(229), uint8(186), uint8(97), uint8(168), uint8(45), uint8(67), uint8(6), uint8(39), uint8(56), uint8(75), uint8(254), uint8(134), uint8(64), uint8(195), uint8(208), uint8(16), uint8(146), uint8(90), uint8(73), uint8(99), uint8(2), uint8(0), uint8(80), uint8(5), uint8(191), uint8(227), uint8(66), uint8(6), uint8(23), uint8(0), uint8(98), uint8(8), uint8(66), uint8(69), uint8(144), uint8(129), uint8(19), uint8(200), uint8(7), uint8(64), uint8(39), uint8(12), uint8(0), uint8(200), uint8(17), uint8(129), uint8(192), uint8(53), uint8(2), uint8(128), uint8(24), uint8(128), uint8(61), uint8(224), uint8(15), uint8(65), uint8(32), uint8(60), uint8(52), uint8(1), uint8(160), uint8(6), uint8(72), uint8(0), uint8(96), uint8(89), uint8(224), uint8(133), uint8(204), uint8(5), uint8(67), uint8(64), uint8(30), uint8(128), uint8(104), uint8(8), uint8(128), uint8(128), uint8(48), uint8(0), uint8(118), uint8(224), uint8(12), uint8(170), uint8(58), uint8(0), uint8(200), uint8(1), uint8(48), uint8(33), uint8(138), uint8(128), uint8(192), uint8(18), uint8(62), uint8(129), uint8(47), uint8(224), uint8(135), uint8(19), uint8(56), uint8(96), uint8(210), uint8(25), uint8(68), uint8(49), uint8(160), uint8(56), uint8(12), uint8(38), uint8(134), uint8(12), uint8(99), uint8(192), uint8(110), uint8(146), uint8(18), uint8(93), uint8(204), uint8(24), uint8(3), uint8(102), uint8(56), uint8(15), uint8(192), uint8(24), uint8(148), uint8(1), uint8(169), uint8(40), uint8(1), uint8(208), uint8(8), uint8(64), uint8(31), uint8(0), uint8(217), uint8(192), uint8(14), uint8(192), uint8(49), uint8(0), uint8(124), uint8(1), uint8(168), uint8(5), uint8(164), uint8(182), uint8(37), uint8(0), uint8(9), uint8(128), uint8(160), uint8(3), uint8(146), uint8(16), uint8(24), uint8(3), uint8(3), uint8(56), uint8(208), uint8(27), uint8(128), uint8(8), uint8(198), uint8(141), uint8(37), uint8(160), uint8(148), uint8(1), uint8(99), uint8(12), uint8(44), uint8(12), uint8(185), uint8(83), uint8(135), uint8(136), uint8(112), uint8(1), uint8(128), uint8(32), uint8(21), uint8(2), uint8(24), uint8(240), uint8(6), uint8(0), uint8(145), uint8(238), uint8(9), uint8(126), uint8(160), uint8(59), uint8(137), uint8(164), uint8(48), uint8(192), uint8(11), uint8(8), uint8(100), uint8(210), uint8(99), uint8(141), uint8(1), uint8(176), uint8(105), uint8(97), uint8(131), uint8(70), uint8(51), uint8(146), uint8(146), uint8(48), uint8(144), uint8(179), uint8(199), uint8(60), uint8(1), uint8(128), uint8(3), uint8(128), uint8(13), uint8(64), uint8(4), uint8(96), uint8(14), uint8(128), uint8(31), uint8(0), uint8(61), uint8(3), uint8(0), uint8(54), uint8(0), uint8(51), uint8(0), uint8(192), uint8(4), uint8(192), uint8(26), uint8(128), uint8(88), uint8(75), uint8(37), uint8(129), uint8(128), uint8(3), uint8(208), uint8(40), uint8(81), uint8(12), uint8(148), uint8(6), uint8(73), uint8(69), uint8(18), uint8(201), uint8(68), uint8(177), uint8(131), uint8(73), uint8(72), uint8(26), uint8(206), uint8(51), uint8(29), uint8(52), uint8(72), uint8(52), uint8(178), uint8(24), uint8(104), uint8(104), uint8(97), uint8(8), uint8(152), uint8(158), uint8(5), uint8(128), uint8(160), uint8(25), uint8(3), uint8(25), uint8(182), uint8(24), uint8(3), uint8(126), uint8(52), uint8(176), uint8(157), uint8(157), uint8(124), uint8(127), uint8(226), uint8(175), uint8(183), uint8(75), uint8(228), uint8(18), uint8(176), uint8(231), uint8(26), uint8(202), uint8(31), uint8(54), uint8(216), uint8(237), uint8(143), uint8(118), uint8(30), uint8(228), uint8(151), uint8(146), uint8(146), uint8(203), uint8(44), uint8(7), uint8(41), uint8(233), uint8(224), uint8(40), uint8(195), uint8(83), uint8(221), uint8(44), uint8(66), uint8(40), uint8(12), uint8(6), uint8(35), uint8(39), uint8(175), uint8(33), uint8(1), uint8(140), uint8(140), uint8(82), uint8(144), uint8(200), uint8(43), uint8(48), uint8(22), uint8(69), uint8(64), uint8(160), uint8(49), uint8(12), uint8(1), uint8(0), uint8(14), uint8(200), uint8(96), uint8(58), uint8(1), uint8(136), uint8(8), uint8(67), uint8(10), uint8(112), uint8(40), uint8(1), uint8(160), uint8(5), uint8(128), uint8(7), uint8(165), uint8(146), uint8(202), uint8(192), uint8(96), uint8(0), uint8(252), uint8(176), uint8(48), uint8(66), uint8(87), uint8(78), uint8(74), uint8(70), uint8(167), uint8(124), uint8(5), uint8(144), uint8(150), uint8(3), uint8(237), uint8(143), uint8(137), uint8(100), uint8(143), uint8(0), uint8(196), uint8(134), uint8(1), uint8(152), uint8(12), uint8(64), uint8(168), uint8(12), uint8(0), uint8(76), uint8(1), uint8(161), uint8(52), uint8(52), uint8(104), uint8(12), uint8(0), uint8(50), uint8(0), uint8(172), uint8(0), uint8(240), uint8(48), uint8(96), uint8(102), uint8(3), uint8(0), uint8(7), uint8(161), uint8(160), uint8(100), uint8(10), uint8(132), uint8(163), uint8(98), uint8(203), uint8(26), uint8(94), uint8(112), uint8(20), uint8(165), uint8(35), uint8(14), uint8(67), uint8(104), uint8(154), uint8(232), uint8(100), uint8(184), uint8(221), uint8(216), uint8(33), uint8(155), uint8(141), uint8(73), uint8(47), uint8(43), uint8(173), uint8(28), uint8(172), uint8(74), uint8(27), uint8(220), uint8(11), uint8(132), uint8(236), uint8(134), uint8(100), uint8(141), uint8(42), uint8(0), uint8(203), uint8(0), uint8(8), uint8(208), uint8(5), uint8(92), uint8(16), uint8(131), uint8(64), uint8(168), uint8(12), uint8(3), uint8(64), uint8(51), uint8(4), uint8(111), uint8(144), uint8(13), uint8(8), uint8(96), uint8(24), uint8(0), uint8(60), uint8(192), uint8(15), uint8(1), uint8(35), uint8(200), uint8(160), uint8(6), uint8(96), uint8(25), uint8(150), uint8(0), uint8(196), uint8(48), uint8(17), uint8(134), uint8(128), uint8(160), uint8(96), uint8(3), uint8(192), uint8(13), uint8(65), uint8(19), uint8(240), uint8(6), uint8(32), uint8(14), uint8(129), uint8(11), uint8(174)]

var REAL_WORLD_PLMPEG_START_SEQUENCE : int const = int(179)

var host_bytes : uint8? = null

var host_length : int = 0

var host_rgb : uint8? = null

var host_rgb_size : int = 0

var host_width : int = 0

var host_height : int = 0

var host_stream_video : plm_video_t? = null

var host_stream_rgb : uint8? = null

var host_stream_rgb_size : int = 0

var host_stream_width : int = 0

var host_stream_height : int = 0

var host_stream_frame_index : int = -1

[export]
def rotl32(var value_3 : uint; var shift_1 : uint) : uint {
    return uint(value_3) << uint(shift_1) | uint(value_3) >> 0x20 - uint(shift_1)
}
[export]
def fold_bytes(var bytes_3 : uint8 const?; var length_3 : int) : uint {
    var hash : uint = uint(0)
    var index : int = int(0)
    hash = 0x811c9dc5
    index = 0
    break
}
[export]
def create_decoder(var bytes_4 : uint8?; var length_4 : size_t) : plm_video_t? {
    var buffer_6 : plm_buffer_t? = cast<plm_buffer_t?>(0)
    var video : plm_video_t? = cast<plm_video_t?>(0)
    buffer_6 = plm_buffer_create_with_memory(bytes_4, length_4, 0)
    video = null
    if (buffer_6 == null) {
        return unsafe(unsafe(reinterpret<plm_video_t?>(null)))
    } else {
        video = unsafe(unsafe(reinterpret<plm_video_t?>(plm_video_create_with_buffer(buffer_6, 1))))
        if (video == null) {
            plm_buffer_destroy(buffer_6)
            return unsafe(unsafe(reinterpret<plm_video_t?>(null)))
        } else {
            plm_video_set_no_delay(video, 1)
            return unsafe(unsafe(reinterpret<plm_video_t?>(video)))
        }
    }
}
[export]
def decode_summary(var bytes_5 : uint8?; var length_5 : size_t; var frame_limit : int; var summary : DecodeSummary?) : int {
    var video_0 : plm_video_t? = cast<plm_video_t?>(0)
    var rgb_size : int = int(0)
    var rgb : uint8? = cast<uint8?>(0)
    var frame_index : int = int(0)
    var frame_11 : plm_frame_t? = cast<plm_frame_t?>(0)
    var frame_hash : uint = uint(0)
    video_0 = create_decoder(bytes_5, length_5)
    rgb_size = 0
    rgb = null
    frame_index = 0
    if (video_0 == null) {
        return 0
    } else {
        summary.combined_hash = uint(0x811c9dc5)
        summary.first_hash = uint(0x0)
        summary.last_hash = uint(0x0)
        summary.frame_count = 0
        summary.width = plm_video_get_width(video_0)
        summary.height = plm_video_get_height(video_0)
        if (int(summary.width) <= 0 || int(summary.height) <= 0) {
            plm_video_destroy(video_0)
            return 0
        } else {
            rgb_size = int(summary.width) * int(summary.height) * 3
            rgb = unsafe(unsafe(reinterpret<uint8?>(unsafe(malloc(unsafe(reinterpret<size_t>(rgb_size)))))))
            if (rgb == null) {
                plm_video_destroy(video_0)
                return 0
            } else {
                while (true) {
                    if (!uint64(1) != uint64(0)) {
                        break
                    }
                    frame_11 = plm_video_decode(video_0)
                    frame_hash = 0x0
                    if (frame_11 == null) {
                        break
                        break
                    } else {
                        plm_frame_to_rgb(frame_11, rgb, int(summary.width) * 3)
                        frame_hash = uint(fold_bytes(rgb, rgb_size))
                        if (uint64(int(frame_index)) == uint64(0)) {
                            summary.first_hash = uint(frame_hash)
                        }
                        summary.last_hash = uint(frame_hash)
                        summary.combined_hash = uint(summary.combined_hash ^ uint(frame_hash) + uint(frame_index) * 0x9e3779b9)
                        summary.combined_hash = uint(rotl32(summary.combined_hash, 0x7))
                        summary.combined_hash = uint(summary.combined_hash + 0x7f4a7c15)
                        summary.frame_count = int(frame_index) + 1
                        frame_index = frame_index + 1
                        if (int(frame_limit) > 0 && int(frame_index) >= int(frame_limit)) {
                            break
                            break
                        }
                    }
                }
                summary.combined_hash = uint(summary.combined_hash ^ uint(summary.width))
                summary.combined_hash = uint(rotl32(summary.combined_hash, 0x3))
                summary.combined_hash = uint(summary.combined_hash ^ uint(summary.height))
                summary.combined_hash = uint(rotl32(summary.combined_hash, 0x3))
                summary.combined_hash = uint(summary.combined_hash ^ uint(summary.frame_count))
                plm_video_destroy(video_0)
                return 1
            }
        }
    }
}
[export]
def decode_frame_rgb(var bytes_6 : uint8?; var length_6 : size_t; var frame_index_0 : int; var rgb_ptr : uint8??; var rgb_size_0 : int?; var width : int?; var height : int?) : int {
    var video_1 : plm_video_t? = cast<plm_video_t?>(0)
    var rgb_0 : uint8? = cast<uint8?>(0)
    var local_width : int = int(0)
    var local_height : int = int(0)
    var local_size : int = int(0)
    var current_1 : int = int(0)
    var frame_12 : plm_frame_t? = cast<plm_frame_t?>(0)
    video_1 = create_decoder(bytes_6, length_6)
    rgb_0 = null
    local_width = 0
    local_height = 0
    local_size = 0
    current_1 = 0
    if (video_1 == null) {
        return 0
    } else {
        local_width = plm_video_get_width(video_1)
        local_height = plm_video_get_height(video_1)
        if (int(local_width) <= 0 || int(local_height) <= 0) {
            plm_video_destroy(video_1)
            return 0
        } else {
            local_size = int(local_width) * int(local_height) * 3
            rgb_0 = unsafe(unsafe(reinterpret<uint8?>(unsafe(malloc(unsafe(reinterpret<size_t>(local_size)))))))
            if (rgb_0 == null) {
                plm_video_destroy(video_1)
                return 0
            } else {
                while (true) {
                    if (uint64(1) != uint64(0)) {
                        frame_12 = plm_video_decode(video_1)
                        if (frame_12 == null) {
                            plm_video_destroy(video_1)
                            return 0
                        } elif (int(current_1) == int(frame_index_0)) {
                            plm_frame_to_rgb(frame_12, rgb_0, int(local_width) * 3)
                            *rgb_ptr = unsafe(unsafe(reinterpret<uint8?>(rgb_0)))
                            *rgb_size_0 = local_size
                            *width = local_width
                            *height = local_height
                            plm_video_destroy(video_1)
                            return 1
                        } else {
                            current_1 = current_1 + 1
                        }
                    } else {
                        return
                    }
                }
            }
        }
    }
}
[export]
def host_stream_end_internal() {
    if (host_stream_video != null) {
        plm_video_destroy(host_stream_video)
    }
    host_stream_video = null
    host_stream_rgb = null
    host_stream_rgb_size = 0
    host_stream_width = 0
    host_stream_height = 0
    host_stream_frame_index = -1
    return
}
[export]
def plmpeg_decode_hash(var frame_limit_0 : int) : int {
    var summary_0 : DecodeSummary = DecodeSummary()
    shim_reset_heap()
    if (uint64(decode_summary(unsafe(addr(sample_mpg_bytes[0])), unsafe(reinterpret<size_t>(sample_mpg_len)), frame_limit_0, unsafe(addr(summary_0)))) == uint64(0)) {
        return -1
    } else {
        return int(summary_0.combined_hash)
    }
}
[export]
def plmpeg_probe_width() : int {
    var summary_1 : DecodeSummary = DecodeSummary()
    shim_reset_heap()
    if (uint64(decode_summary(unsafe(addr(sample_mpg_bytes[0])), unsafe(reinterpret<size_t>(sample_mpg_len)), 1, unsafe(addr(summary_1)))) == uint64(0)) {
        return -1
    } else {
        return summary_1.width
    }
}
[export]
def plmpeg_probe_height() : int {
    var summary_2 : DecodeSummary = DecodeSummary()
    shim_reset_heap()
    if (uint64(decode_summary(unsafe(addr(sample_mpg_bytes[0])), unsafe(reinterpret<size_t>(sample_mpg_len)), 1, unsafe(addr(summary_2)))) == uint64(0)) {
        return -1
    } else {
        return summary_2.height
    }
}
[export]
def plmpeg_probe_frame_count(var frame_limit_1 : int) : int {
    var summary_3 : DecodeSummary = DecodeSummary()
    shim_reset_heap()
    if (uint64(decode_summary(unsafe(addr(sample_mpg_bytes[0])), unsafe(reinterpret<size_t>(sample_mpg_len)), frame_limit_1, unsafe(addr(summary_3)))) == uint64(0)) {
        return -1
    } else {
        return summary_3.frame_count
    }
}
[export]
def plmpeg_probe_first_frame_hash() : int {
    var summary_4 : DecodeSummary = DecodeSummary()
    shim_reset_heap()
    if (uint64(decode_summary(unsafe(addr(sample_mpg_bytes[0])), unsafe(reinterpret<size_t>(sample_mpg_len)), 1, unsafe(addr(summary_4)))) == uint64(0)) {
        return -1
    } else {
        return int(summary_4.first_hash)
    }
}
[export]
def plmpeg_probe_last_frame_hash(var frame_limit_2 : int) : int {
    var summary_5 : DecodeSummary = DecodeSummary()
    shim_reset_heap()
    if (uint64(decode_summary(unsafe(addr(sample_mpg_bytes[0])), unsafe(reinterpret<size_t>(sample_mpg_len)), frame_limit_2, unsafe(addr(summary_5)))) == uint64(0)) {
        return -1
    } else {
        return int(summary_5.last_hash)
    }
}
[export]
def plmpeg_probe_sequence_start_code() : int {
    var buffer_7 : plm_buffer_t? = cast<plm_buffer_t?>(0)
    var code_1 : int = int(0)
    buffer_7 = null
    code_1 = -1
    shim_reset_heap()
    buffer_7 = unsafe(unsafe(reinterpret<plm_buffer_t?>(plm_buffer_create_with_memory(unsafe(addr(sample_mpg_bytes[0])), unsafe(reinterpret<size_t>(sample_mpg_len)), 0))))
    if (buffer_7 == null) {
        return -2
    } else {
        code_1 = plm_buffer_find_start_code(buffer_7, REAL_WORLD_PLMPEG_START_SEQUENCE)
        plm_buffer_destroy(buffer_7)
        return code_1
    }
}
[export]
def plmpeg_probe_video_has_header() : int {
    var video_2 : plm_video_t? = cast<plm_video_t?>(0)
    var result_2 : int = int(0)
    video_2 = null
    result_2 = 0
    shim_reset_heap()
    video_2 = unsafe(unsafe(reinterpret<plm_video_t?>(create_decoder(unsafe(addr(sample_mpg_bytes[0])), unsafe(reinterpret<size_t>(sample_mpg_len))))))
    if (video_2 == null) {
        return -1
    } else {
        result_2 = plm_video_has_header(video_2)
        plm_video_destroy(video_2)
        return result_2
    }
}
[export]
def plmpeg_host_alloc(var size_2 : int) : int {
    var result_3 : uint64 = uint64(0)
    result_3 = uint64(0x0)
    if (int(size_2) <= 0) {
        return 0
    } else {
        result_3 = unsafe(malloc(unsafe(reinterpret<size_t>(size_2))))
        return int(unsafe(reinterpret<intptr_t>(result_3)))
    }
}
[export]
def plmpeg_host_load(var bytes_ptr : int; var bytes_len : int) : int {
    if (uint64(int(bytes_ptr)) == uint64(0) || int(bytes_len) <= 0) {
        return 0
    } else {
        host_bytes = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(reinterpret<intptr_t>(bytes_ptr))))))))
        host_length = bytes_len
        host_rgb = null
        host_rgb_size = 0
        host_width = 0
        host_height = 0
        host_stream_end_internal()
        return 1
    }
}
[export]
def plmpeg_host_decode_frame(var frame_index_1 : int) : int {
    var rgb_1 : uint8? = cast<uint8?>(0)
    var rgb_size_1 : int = int(0)
    var width_0 : int = int(0)
    var height_0 : int = int(0)
    rgb_1 = null
    rgb_size_1 = 0
    width_0 = 0
    height_0 = 0
    if (host_bytes == null || int(host_length) <= 0 || int(frame_index_1) < 0) {
        return 0
    } elif (uint64(decode_frame_rgb(host_bytes, unsafe(reinterpret<size_t>(host_length)), frame_index_1, unsafe(addr(rgb_1)), unsafe(addr(rgb_size_1)), unsafe(addr(width_0)), unsafe(addr(height_0)))) == uint64(0)) {
        return 0
    } else {
        host_rgb = unsafe(unsafe(reinterpret<uint8?>(rgb_1)))
        host_rgb_size = rgb_size_1
        host_width = width_0
        host_height = height_0
        return 1
    }
}
[export]
def plmpeg_host_get_rgb_ptr() : int {
    return int(unsafe(reinterpret<intptr_t>(host_rgb)))
}
[export]
def plmpeg_host_get_rgb_size() : int {
    return host_rgb_size
}
[export]
def plmpeg_host_get_width() : int {
    return host_width
}
[export]
def plmpeg_host_get_height() : int {
    return host_height
}
[export]
def plmpeg_host_stream_begin() : int {
    var width_1 : int = int(0)
    var height_1 : int = int(0)
    var rgb_size_2 : int = int(0)
    var rgb_2 : uint8? = cast<uint8?>(0)
    width_1 = 0
    height_1 = 0
    rgb_size_2 = 0
    rgb_2 = null
    if (host_bytes == null || int(host_length) <= 0) {
        return 0
    } else {
        host_stream_end_internal()
        host_stream_video = unsafe(unsafe(reinterpret<plm_video_t?>(create_decoder(host_bytes, unsafe(reinterpret<size_t>(host_length))))))
        if (host_stream_video == null) {
            return 0
        } else {
            width_1 = plm_video_get_width(host_stream_video)
            height_1 = plm_video_get_height(host_stream_video)
            if (int(width_1) <= 0 || int(height_1) <= 0) {
                host_stream_end_internal()
                return 0
            } else {
                rgb_size_2 = int(width_1) * int(height_1) * 3
                rgb_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(malloc(unsafe(reinterpret<size_t>(rgb_size_2)))))))
                if (rgb_2 == null) {
                    host_stream_end_internal()
                    return 0
                } else {
                    host_stream_rgb = unsafe(unsafe(reinterpret<uint8?>(rgb_2)))
                    host_stream_rgb_size = rgb_size_2
                    host_stream_width = width_1
                    host_stream_height = height_1
                    host_stream_frame_index = -1
                    return 1
                }
            }
        }
    }
}
[export]
def plmpeg_host_stream_decode_next() : int {
    var frame_13 : plm_frame_t? = cast<plm_frame_t?>(0)
    frame_13 = null
    if (host_stream_video == null || host_stream_rgb == null) {
        return 0
    } else {
        frame_13 = unsafe(unsafe(reinterpret<plm_frame_t?>(plm_video_decode(host_stream_video))))
        if (frame_13 == null) {
            return 0
        } else {
            plm_frame_to_rgb(frame_13, host_stream_rgb, int(host_stream_width) * 3)
            host_stream_frame_index = host_stream_frame_index + 1
            host_rgb = unsafe(unsafe(reinterpret<uint8?>(host_stream_rgb)))
            host_rgb_size = host_stream_rgb_size
            host_width = host_stream_width
            host_height = host_stream_height
            return 1
        }
    }
}
[export]
def plmpeg_host_stream_end() : int {
    host_stream_end_internal()
    return 1
}
[export]
def plmpeg_host_stream_get_frame_index() : int {
    return host_stream_frame_index
}
[export]
def plmpeg_host_probe_video_has_header() : int {
    var video_3 : plm_video_t? = cast<plm_video_t?>(0)
    var result_4 : int = int(0)
    video_3 = null
    result_4 = 0
    if (host_bytes == null || int(host_length) <= 0) {
        return -1
    } else {
        video_3 = unsafe(unsafe(reinterpret<plm_video_t?>(create_decoder(host_bytes, unsafe(reinterpret<size_t>(host_length))))))
        if (video_3 == null) {
            return -2
        } else {
            result_4 = plm_video_has_header(video_3)
            plm_video_destroy(video_3)
            return result_4
        }
    }
}
[export]
def plmpeg_host_probe_width() : int {
    var video_4 : plm_video_t? = cast<plm_video_t?>(0)
    var result_5 : int = int(0)
    video_4 = null
    result_5 = 0
    if (host_bytes == null || int(host_length) <= 0) {
        return -1
    } else {
        video_4 = unsafe(unsafe(reinterpret<plm_video_t?>(create_decoder(host_bytes, unsafe(reinterpret<size_t>(host_length))))))
        if (video_4 == null) {
            return -2
        } else {
            result_5 = plm_video_get_width(video_4)
            plm_video_destroy(video_4)
            return result_5
        }
    }
}
[export]
def plmpeg_host_probe_height() : int {
    var video_5 : plm_video_t? = cast<plm_video_t?>(0)
    var result_6 : int = int(0)
    video_5 = null
    result_6 = 0
    if (host_bytes == null || int(host_length) <= 0) {
        return -1
    } else {
        video_5 = unsafe(unsafe(reinterpret<plm_video_t?>(create_decoder(host_bytes, unsafe(reinterpret<size_t>(host_length))))))
        if (video_5 == null) {
            return -2
        } else {
            result_6 = plm_video_get_height(video_5)
            plm_video_destroy(video_5)
            return result_6
        }
    }
}
var PLM_BUFFER_MODE_APPEND : int = 3

var PLM_BUFFER_MODE_RING : int = 2

var PLM_BUFFER_MODE_FIXED_MEM : int = 1

var PLM_BUFFER_MODE_FILE : int = 0

