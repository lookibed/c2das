options gen2

module minimp4
var c2da_heap : array<uint8>

var c2da_heap_offset : uint64 = uint64(uint64(uint64(0x8)))

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
def c2da_bool_to_int(v : bool) : int {
    if (v) {
        return 1
    } else {
        return 0
    }
}
def c2da_bool_to_uint(v : bool) : uint {
    if (v) {
        return 0x1
    } else {
        return 0x0
    }
}
def c2da___assert_fail(expr : void?; file : void?; line : uint; func : void?) {
}
def c2da_reset_heap() {
    c2da_heap_offset = uint64(0x8)
}
def c2da_malloc(size : uint64) : uint64 {
    if (uint64(length(c2da_heap)) == uint64(0)) {
        resize(c2da_heap, 33554432)
    }
    var aligned_size : uint64 = uint64(uint64(uint64(size) + uint64(0x7) & uint64(0xfffffffffffffff8uL)))
    var new_offset : uint64 = uint64(uint64(uint64(c2da_heap_offset) + uint64(0x8) + uint64(aligned_size)))
    if (new_offset >= uint64(length(c2da_heap))) {
        return uint64(0x0)
    }
    var result : uint64 = uint64(uint64(c2da_heap_offset))
    unsafe(*unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(c2da_heap[uint(result)])))))) = size
    c2da_heap_offset = new_offset
    return intptr(unsafe(addr(c2da_heap[uint(uint(result) + uint(uint64(0x8)))])))
}
def c2da_free(ptr : uint64) {
}
def realloc(ptr : uint64; size : uint64) : uint64 {
    var old_size : uint64 = uint64(uint64(uint64(0x0)))
    var copy_size : uint64 = uint64(uint64(uint64(0x0)))
    var new_ptr : uint64 = uint64(uint64(c2da_malloc(size)))
    if (uint64(new_ptr) != uint64(0) && uint64(ptr) != uint64(0)) {
        old_size = uint64(uint64(unsafe(*unsafe(unsafe(reinterpret<uint64?>(ptr - uint64(0x8)))))))
        copy_size = uint64(uint64(c2da_min_uint64(old_size, size)))
        unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(new_ptr))), unsafe(unsafe(reinterpret<void?>(ptr))), int(copy_size)))
    }
    return new_ptr
}
def c2da_memset(dst : void?; value : int; size : int) : void? {
    var bytes : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(dst)))))))))
    var i : int = 0
    while (i < size) {
        unsafe(bytes[uint(i)]) = uint8(value)
        i = int(i) + 1
    }
    return dst
}
def c2da_memchr(ptr : void?; value : int; size : int) : uint64 {
    return uint64(0x0)
}
def c2da_strdup(src : void?) : int8? {
    return unsafe(unsafe(reinterpret<int8?>(src)))
}
def c2da_strlen(src : int8 const?) : int {
    return 0
}
struct MP4E_mux_tag {
    tracks : minimp4::minimp4_vector_t
    write_pos : int64
    write_callback : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>
    token : uint64
    text_comment : int8?
    sequential_mode_flag : int
    enable_fragmentation : int
    fragments_count : int
}
struct minimp4_vector_t {
    data : uint8?
    bytes : int
    capacity : int
}
struct MP4E_mux_t {
    tracks : minimp4::minimp4_vector_t
    write_pos : int64
    write_callback : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>
    token : uint64
    text_comment : int8?
    sequential_mode_flag : int
    enable_fragmentation : int
    fragments_count : int
}
enum track_media_kind_t {
    e_audio = 0
    e_video = 1
    e_private = 2
}
struct Unnamed {
    a : minimp4::Unnamed_0
    v : minimp4::Unnamed_1
}
struct Unnamed_1 {
    width : int
    height : int
}
struct Unnamed_0 {
    channelcount : uint
}
struct MP4E_track_t {
    object_type_indication : uint
    language : uint8 [4]
    track_media_kind : minimp4::track_media_kind_t
    time_scale : uint
    default_duration : uint
    u : minimp4::Unnamed
}
struct MP4D_sample_to_chunk_t_tag {
    first_chunk : uint
    samples_per_chunk : uint
}
struct MP4D_sample_to_chunk_t {
    first_chunk : uint
    samples_per_chunk : uint
}
struct Unnamed_2 {
    audio : minimp4::Unnamed_3
    video : minimp4::Unnamed_4
}
struct Unnamed_4 {
    width : uint
    height : uint
}
struct Unnamed_3 {
    channelcount : uint
    samplerate_hz : uint
}
struct MP4D_track_t {
    sample_count : uint
    dsi : uint8?
    dsi_bytes : uint
    object_type_indication : uint
    handler_type : uint
    duration_hi : uint
    duration_lo : uint
    timescale : uint
    avg_bitrate_bps : uint
    language : uint8 [4]
    stream_type : uint
    SampleDescription : minimp4::Unnamed_2
    entry_size : uint?
    sample_to_chunk_count : uint
    sample_to_chunk : minimp4::MP4D_sample_to_chunk_t_tag?
    chunk_count : uint
    chunk_offset : uint64?
    timestamp : uint?
    duration : uint?
}
struct MP4D_demux_tag {
    read_pos : int64
    read_size : int64
    track : minimp4::MP4D_track_t?
    read_callback : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>
    token : uint64
    track_count : uint
    duration_hi : uint
    duration_lo : uint
    timescale : uint
    tag : minimp4::Unnamed_5
}
struct Unnamed_5 {
    title : uint8?
    artist : uint8?
    album : uint8?
    year : uint8?
    comment : uint8?
    genre : uint8?
}
struct MP4D_demux_t {
    read_pos : int64
    read_size : int64
    track : minimp4::MP4D_track_t?
    read_callback : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>
    token : uint64
    track_count : uint
    duration_hi : uint
    duration_lo : uint
    timescale : uint
    tag : minimp4::Unnamed_5
}
struct h264_sps_id_patcher_t {
    sps_cache : uint64 [32]
    pps_cache : uint64 [256]
    sps_bytes : int [32]
    pps_bytes : int [256]
    map_sps : int [32]
    map_pps : int [256]
}
struct mp4_h26x_writer_tag {
    sps_patcher : minimp4::h264_sps_id_patcher_t
    mux : minimp4::MP4E_mux_tag?
    mux_track_id : int
    is_hevc : int
    need_vps : int
    need_sps : int
    need_pps : int
    need_idr : int
}
struct mp4_h26x_writer_t {
    sps_patcher : minimp4::h264_sps_id_patcher_t
    mux : minimp4::MP4E_mux_tag?
    mux_track_id : int
    is_hevc : int
    need_vps : int
    need_sps : int
    need_pps : int
    need_idr : int
}
struct track_t {
    info : minimp4::MP4E_track_t
    smpl : minimp4::minimp4_vector_t
    pending_sample : minimp4::minimp4_vector_t
    vsps : minimp4::minimp4_vector_t
    vpps : minimp4::minimp4_vector_t
    vvps : minimp4::minimp4_vector_t
}
struct sample_t {
    size : uint64
    offset : uint64
    duration : uint
    flag_random_access : uint
}
struct bit_reader_t {
    cache : uint
    cache_free_bits : int
    buf : uint16 const?
    origin : uint16 const?
    origin_bytes : uint
}
struct bs_t {
    shift : int
    cache : uint
    buf : uint?
    origin : uint?
}
struct Unnamed_6 {
    bytes : uint64
    format : minimp4::boxtype_t
}
enum boxtype_t {
    BOX_ATOM = 0
    BOX_OD = 1
}
struct Unnamed_7 {
    name : uint
    type_0 : minimp4::boxtype_t
}
struct Unnamed_8 {
    name : uint
    max_version : uint
    use_track_flag : uint
}
var BOX_tfdt : int = 1952867444

var BOX_ipir : int = 1768974706

var BOX_titl : int = 1953068140

var BOX_trak : int = 1953653099

var BOX_btrt : int = 1651798644

var BOX_mpod : int = 1836085092

var BOX_pgap : int = 1885823344

var BOX_gnre : int = 1735291493

var BOX_skip : int = 1936419184

var BOX_trkn : int = 1953655662

var BOX_ctoo : int = int(0xa9746f6f)

var BOX_moof : int = 1836019558

var BOX_tkhd : int = 1953196132

var BOX_urn_ : int = 1970433568

var BOX_mfhd : int = 1835427940

var BOX_esds : int = 1702061171

var BOX_avc1 : int = 1635148593

var OD_BASE : int = 606348336

var BOX_tref : int = 1953654118

var BOX_dscp : int = 1685283696

var BOX_desc : int = 1684370275

var BOX_cwrt : int = int(0xa9777274)

var BOX_tvsh : int = 1953919848

var BOX_egid : int = 1701276004

var BOX_stss : int = 1937011571

var BOX_sdhd : int = 1935960164

var BOX_hvc1 : int = 1752589105

var BOX_dref : int = 1685218662

var BOX_cgen : int = int(0xa967656e)

var BOX_cprt : int = 1668313716

var BOX_iods : int = 1768907891

var OD_DCD : int = 606348340

var BOX_data : int = 1684108385

var BOX_traf : int = 1953653094

var BOX_purl : int = 1886745196

var BOX_hmhd : int = 1752000612

var BOX_tvsn : int = 1953919854

var BOX_cart : int = int(0xa9617274)

var BOX_urn : int = 1970433568

var BOX_cgrp : int = int(0xa9677270)

var BOX_nmhd : int = 1852663908

var BOX_elst : int = 1701606260

var BOX_edts : int = 1701082227

var BOX_rtng : int = 1920233063

var BOX_smhd : int = 1936549988

var BOX_s263 : int = 1932670515

var BOX_gnrv : int = 1735291510

var BOX_stdp : int = 1937007728

var BOX_mp4a : int = 1836069985

var BOX_svc1 : int = 1937138481

var BOX_seib : int = 1936025954

var BOX_calb : int = int(0xa9616c62)

var BOX_cpil : int = 1668311404

var BOX_purd : int = 1886745188

var BOX_ftyp : int = 1718909296

var BOX_url : int = 1970433056

var BOX_gnra : int = 1735291489

var OD_ESD : int = 606348339

var BOX_odhd : int = 1868851300

var BOX_cday : int = int(0xa9646179)

var BOX_hint : int = 1751740020

var BOX_keyw : int = 1801812343

var BOX_perf : int = 1885696614

var BOX_pcst : int = 1885565812

var BOX_auth : int = 1635087464

var BOX_yrrc : int = 2037543523

var BOX_m4ds : int = 1832150131

var BOX_mdat : int = 1835295092

var BOX_udta : int = 1969517665

var BOX_uuid : int = 1970628964

var BOX_avcC : int = 1635148611

var BOX_ctts : int = 1668576371

var BOX_padb : int = 1885430882

var BOX_mean : int = 1835360622

var default_sample_duration_present : int = 8

var BOX_ATOM : int = 0

var BOX_avc2 : int = 1635148594

var e_private : int = 2

var e_video : int = 1

var BOX_moov : int = 1836019574

var BOX_mdia : int = 1835297121

var BOX_mp4s : int = 1836070003

var box_ftyp : uint8 [24] const = fixed_array<uint8>(uint8(0), uint8(0), uint8(0), uint8(uint8(24)), uint8(uint8(102)), uint8(uint8(116)), uint8(uint8(121)), uint8(uint8(112)), uint8(uint8(109)), uint8(uint8(112)), uint8(uint8(52)), uint8(uint8(50)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(109)), uint8(uint8(112)), uint8(uint8(52)), uint8(uint8(50)), uint8(uint8(105)), uint8(uint8(115)), uint8(uint8(111)), uint8(uint8(109)))

var BOX_mp4v : int = 1836070006

var BOX_mvhd : int = 1836476516

var BOX_covr : int = 1668249202

var BOX_disk : int = 1684632427

var BOX_hdlr : int = 1751411826

var BOX_free : int = 1718773093

var BOX_name : int = 1851878757

var BOX_stsd : int = 1937011556

var BOX_stsz : int = 1937011578

var BOX_co64 : int = 1668232756

var BOX_d263 : int = 1681012275

var BOX_mvex : int = 1836475768

var BOX_tven : int = 1953916270

var BOX_cnam : int = int(0xa96e616d)

var BOX_stsc : int = 1937011555

var BOX_trun : int = 1953658222

var BOX_trex : int = 1953654136

var e_audio : int = 0

var BOX_stco : int = 1937007471

var BOX_stts : int = 1937011827

var BOX_hvcC : int = 1752589123

var default_sample_flags_present : int = 32

var BOX_stbl : int = 1937007212

var BOX_dinf : int = 1684631142

var BOX_tvnn : int = 1953918574

var BOX_mdhd : int = 1835296868

var BOX_vmhd : int = 1986881636

var OD_DSI : int = 606348341

var BOX_clyr : int = int(0xa96c7972)

var BOX_mehd : int = 1835362404

var BOX_catg : int = 1667331175

var BOX_svcC : int = 1937138499

var BOX_tmpo : int = 1953329263

var BOX_dpnd : int = 1685089892

var BOX_crhd : int = 1668442212

var OD_SLC : int = 606348342

var BOX_ccmt : int = int(0xa9636d74)

var BOX_meta : int = 1835365473

var BOX_ilst : int = 1768715124

var BOX_OD : int = 1

var BOX_stz2 : int = 1937013298

var BOX_albm : int = 1634493037

var BOX_cART : int = int(0xa9415254)

var BOX_hev1 : int = 1751479857

var BOX_url_ : int = 1970433056

var BOX_stsh : int = 1937011560

var BOX_tves : int = 1953916275

var BOX_sawb : int = 1935767394

var BOX_sync : int = 1937337955

var BOX_minf : int = 1835626086

var BOX_aART : int = 1631670868

var BOX_samr : int = 1935764850

var BOX_tfhd : int = 1952868452

var BOX_stik : int = 1937009003

var BOX_damr : int = 1684106610

[export]
def mp4e_write_fragment_header(var mux_5 : minimp4::MP4E_mux_tag?; var track_num_0 : int; var data_bytes_1 : int; var duration_1 : int; var kind_1 : int) : int {
    var base_1 : uint8 [888] = fixed_array<uint8>(uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0))
    var p_4 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(base_1[0]))))))))))))))
    var stack_base : uint8? [20] = fixed_array<uint8?>(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    var stack : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(stack_base[0]))))))))))))))
    var pdata_offset : uint8? = null
    var flags : uint = uint(uint(uint(0)))
    var e : uint = uint(uint(uint(0)))
    var tr_4 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_5).tracks.data)))))), int(track_num_0), 112))))))))))))))
    var c2da_fresh23 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack))))))
    stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 1, 8)))))))))))
    *c2da_fresh23 = unsafe(unsafe(reinterpret<uint8?>(p_4)))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
    var c2da_fresh24 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh24 = uint8(uint8(uint8(uint(int(BOX_moof)) >> uint(8) * uint(3))))
    var c2da_fresh25 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh25 = uint8(uint8(uint8(uint(int(BOX_moof)) >> uint(8) * uint(2))))
    var c2da_fresh26 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh26 = uint8(uint8(uint8(uint(int(BOX_moof)) >> uint(8) * uint(1))))
    var c2da_fresh27 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh27 = uint8(uint8(uint8(uint(int(BOX_moof)) >> uint(8) * uint(0))))
    var c2da_fresh28 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack))))))
    stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 1, 8)))))))))))
    *c2da_fresh28 = unsafe(unsafe(reinterpret<uint8?>(p_4)))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
    var c2da_fresh29 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh29 = uint8(uint8(uint8(uint(int(BOX_mfhd)) >> uint(8) * uint(3))))
    var c2da_fresh30 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh30 = uint8(uint8(uint8(uint(int(BOX_mfhd)) >> uint(8) * uint(2))))
    var c2da_fresh31 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh31 = uint8(uint8(uint8(uint(int(BOX_mfhd)) >> uint(8) * uint(1))))
    var c2da_fresh32 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh32 = uint8(uint8(uint8(uint(int(BOX_mfhd)) >> uint(8) * uint(0))))
    var c2da_fresh33 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh33 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    var c2da_fresh34 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh34 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    var c2da_fresh35 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh35 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    var c2da_fresh36 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh36 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    var c2da_fresh37 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh37 = uint8(uint8(uint8(uint(int(unsafe(*mux_5).fragments_count)) >> uint(8) * uint(3))))
    var c2da_fresh38 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh38 = uint8(uint8(uint8(uint(int(unsafe(*mux_5).fragments_count)) >> uint(8) * uint(2))))
    var c2da_fresh39 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh39 = uint8(uint8(uint8(uint(int(unsafe(*mux_5).fragments_count)) >> uint(8) * uint(1))))
    var c2da_fresh40 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh40 = uint8(uint8(uint8(uint(int(unsafe(*mux_5).fragments_count)) >> uint(8) * uint(0))))
    stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 0 - int(uint64(1)), 8)))))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_4))) - int(int64(intptr(*stack)))))))))
    var c2da_fresh41 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack))))))
    stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 1, 8)))))))))))
    *c2da_fresh41 = unsafe(unsafe(reinterpret<uint8?>(p_4)))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
    var c2da_fresh42 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh42 = uint8(uint8(uint8(uint(int(BOX_traf)) >> uint(8) * uint(3))))
    var c2da_fresh43 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh43 = uint8(uint8(uint8(uint(int(BOX_traf)) >> uint(8) * uint(2))))
    var c2da_fresh44 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh44 = uint8(uint8(uint8(uint(int(BOX_traf)) >> uint(8) * uint(1))))
    var c2da_fresh45 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh45 = uint8(uint8(uint8(uint(int(BOX_traf)) >> uint(8) * uint(0))))
    flags = uint(uint(uint(uint(uint(0)))))
    if (uint(unsafe(*tr_4).info.track_media_kind) == uint(e_video)) {
        flags = uint(uint(uint(uint(flags) | uint(uint(32)))))
    } else {
        flags = uint(uint(uint(uint(flags) | uint(uint(8)))))
    }
    var c2da_fresh46 : int = int(0)
    if (uint(unsafe(*tr_4).info.track_media_kind) == uint(e_video)) {
        c2da_fresh46 = 131104
    } else {
        c2da_fresh46 = 131080
    }
    flags = uint(uint(uint(uint(c2da_fresh46))))
    var c2da_fresh47 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack))))))
    stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 1, 8)))))))))))
    *c2da_fresh47 = unsafe(unsafe(reinterpret<uint8?>(p_4)))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
    var c2da_fresh48 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh48 = uint8(uint8(uint8(uint(int(BOX_tfhd)) >> uint(8) * uint(3))))
    var c2da_fresh49 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh49 = uint8(uint8(uint8(uint(int(BOX_tfhd)) >> uint(8) * uint(2))))
    var c2da_fresh50 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh50 = uint8(uint8(uint8(uint(int(BOX_tfhd)) >> uint(8) * uint(1))))
    var c2da_fresh51 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh51 = uint8(uint8(uint8(uint(int(BOX_tfhd)) >> uint(8) * uint(0))))
    var c2da_fresh52 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh52 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(3))))))
    var c2da_fresh53 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh53 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(2))))))
    var c2da_fresh54 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh54 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(1))))))
    var c2da_fresh55 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh55 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(0))))))
    var c2da_fresh56 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh56 = uint8(uint8(uint8(uint(int(track_num_0)) + uint(1) >> uint(8) * uint(3))))
    var c2da_fresh57 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh57 = uint8(uint8(uint8(uint(int(track_num_0)) + uint(1) >> uint(8) * uint(2))))
    var c2da_fresh58 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh58 = uint8(uint8(uint8(uint(int(track_num_0)) + uint(1) >> uint(8) * uint(1))))
    var c2da_fresh59 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
    p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
    *c2da_fresh59 = uint8(uint8(uint8(uint(int(track_num_0)) + uint(1) >> uint(8) * uint(0))))
    if (uint(unsafe(*tr_4).info.track_media_kind) == uint(e_video)) {
        var c2da_fresh60 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh60 = uint8(uint8(uint8(uint(16842752) >> uint(8) * uint(3))))
        var c2da_fresh61 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh61 = uint8(uint8(uint8(uint(16842752) >> uint(8) * uint(2))))
        var c2da_fresh62 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh62 = uint8(uint8(uint8(uint(16842752) >> uint(8) * uint(1))))
        var c2da_fresh63 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh63 = uint8(uint8(uint8(uint(16842752) >> uint(8) * uint(0))))
    } else {
        var c2da_fresh64 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh64 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(3))))
        var c2da_fresh65 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh65 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(2))))
        var c2da_fresh66 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh66 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(1))))
        var c2da_fresh67 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh67 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(0))))
    }
    stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 0 - int(uint64(1)), 8)))))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_4))) - int(int64(intptr(*stack)))))))))
    if (uint(unsafe(*tr_4).info.track_media_kind) == uint(e_audio)) {
        flags = uint(uint(uint(uint(uint(0)))))
        flags = uint(uint(uint(uint(flags) | uint(uint(1)))))
        flags = uint(uint(uint(uint(flags) | uint(uint(512)))))
        var c2da_fresh68 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack))))))
        stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 1, 8)))))))))))
        *c2da_fresh68 = unsafe(unsafe(reinterpret<uint8?>(p_4)))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
        var c2da_fresh69 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh69 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(3))))
        var c2da_fresh70 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh70 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(2))))
        var c2da_fresh71 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh71 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(1))))
        var c2da_fresh72 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh72 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(0))))
        var c2da_fresh73 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh73 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(3))))))
        var c2da_fresh74 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh74 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(2))))))
        var c2da_fresh75 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh75 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(1))))))
        var c2da_fresh76 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh76 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(0))))))
        var c2da_fresh77 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh77 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
        var c2da_fresh78 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh78 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
        var c2da_fresh79 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh79 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
        var c2da_fresh80 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh80 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
        pdata_offset = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4)))))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
        var c2da_fresh81 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh81 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(3))))
        var c2da_fresh82 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh82 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(2))))
        var c2da_fresh83 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh83 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(1))))
        var c2da_fresh84 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
        p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
        *c2da_fresh84 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(0))))
        stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 0 - int(uint64(1)), 8)))))))))))
        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(3)))))))))
        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(2)))))))))
        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(1)))))))))
        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_4))) - int(int64(intptr(*stack)))))))))
    } else {
        if (int(kind_1) == 1) {
            flags = uint(uint(uint(uint(uint(0)))))
            flags = uint(uint(uint(uint(flags) | uint(uint(1)))))
            flags = uint(uint(uint(uint(flags) | uint(uint(4)))))
            flags = uint(uint(uint(uint(flags) | uint(uint(256)))))
            flags = uint(uint(uint(uint(flags) | uint(uint(512)))))
            var c2da_fresh85 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack))))))
            stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 1, 8)))))))))))
            *c2da_fresh85 = unsafe(unsafe(reinterpret<uint8?>(p_4)))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
            var c2da_fresh86 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh86 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(3))))
            var c2da_fresh87 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh87 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(2))))
            var c2da_fresh88 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh88 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(1))))
            var c2da_fresh89 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh89 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(0))))
            var c2da_fresh90 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh90 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(3))))))
            var c2da_fresh91 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh91 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(2))))))
            var c2da_fresh92 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh92 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(1))))))
            var c2da_fresh93 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh93 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(0))))))
            var c2da_fresh94 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh94 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
            var c2da_fresh95 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh95 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
            var c2da_fresh96 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh96 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
            var c2da_fresh97 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh97 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
            pdata_offset = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4)))))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
            var c2da_fresh98 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh98 = uint8(uint8(uint8(uint(33554432) >> uint(8) * uint(3))))
            var c2da_fresh99 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh99 = uint8(uint8(uint8(uint(33554432) >> uint(8) * uint(2))))
            var c2da_fresh100 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh100 = uint8(uint8(uint8(uint(33554432) >> uint(8) * uint(1))))
            var c2da_fresh101 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh101 = uint8(uint8(uint8(uint(33554432) >> uint(8) * uint(0))))
            var c2da_fresh102 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh102 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(3))))
            var c2da_fresh103 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh103 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(2))))
            var c2da_fresh104 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh104 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(1))))
            var c2da_fresh105 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh105 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(0))))
            var c2da_fresh106 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh106 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(3))))
            var c2da_fresh107 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh107 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(2))))
            var c2da_fresh108 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh108 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(1))))
            var c2da_fresh109 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh109 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(0))))
            stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 0 - int(uint64(1)), 8)))))))))))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(3)))))))))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(2)))))))))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(1)))))))))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_4))) - int(int64(intptr(*stack)))))))))
        } else {
            flags = uint(uint(uint(uint(uint(0)))))
            flags = uint(uint(uint(uint(flags) | uint(uint(1)))))
            flags = uint(uint(uint(uint(flags) | uint(uint(256)))))
            flags = uint(uint(uint(uint(flags) | uint(uint(512)))))
            var c2da_fresh110 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack))))))
            stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 1, 8)))))))))))
            *c2da_fresh110 = unsafe(unsafe(reinterpret<uint8?>(p_4)))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
            var c2da_fresh111 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh111 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(3))))
            var c2da_fresh112 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh112 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(2))))
            var c2da_fresh113 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh113 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(1))))
            var c2da_fresh114 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh114 = uint8(uint8(uint8(uint(int(BOX_trun)) >> uint(8) * uint(0))))
            var c2da_fresh115 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh115 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(3))))))
            var c2da_fresh116 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh116 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(2))))))
            var c2da_fresh117 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh117 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(1))))))
            var c2da_fresh118 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh118 = uint8(uint8(uint8(uint(uint(flags)) >> uint(uint(uint(8) * uint(0))))))
            var c2da_fresh119 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh119 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
            var c2da_fresh120 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh120 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
            var c2da_fresh121 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh121 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
            var c2da_fresh122 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh122 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
            pdata_offset = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4)))))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 4, 1))))))))))))))
            var c2da_fresh123 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh123 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(3))))
            var c2da_fresh124 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh124 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(2))))
            var c2da_fresh125 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh125 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(1))))
            var c2da_fresh126 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh126 = uint8(uint8(uint8(uint(int(duration_1)) >> uint(8) * uint(0))))
            var c2da_fresh127 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh127 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(3))))
            var c2da_fresh128 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh128 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(2))))
            var c2da_fresh129 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh129 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(1))))
            var c2da_fresh130 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_4))))))
            p_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_4))), 1, 1)))))))))))
            *c2da_fresh130 = uint8(uint8(uint8(uint(int(data_bytes_1)) >> uint(8) * uint(0))))
            stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 0 - int(uint64(1)), 8)))))))))))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(3)))))))))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(2)))))))))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(1)))))))))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_4))) - int(int64(intptr(*stack)))))))))
        }
    }
    stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 0 - int(uint64(1)), 8)))))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_4))) - int(int64(intptr(*stack)))))))))
    stack = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack))), 0 - int(uint64(1)), 8)))))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(*stack))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_4))) - int(int64(intptr(*stack)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(pdata_offset)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_1[0]))))))) + int64(int64(8)))) >> int(int64(int64(int64(8) * int64(3)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(pdata_offset)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_1[0]))))))) + int64(int64(8)))) >> int(int64(int64(int64(8) * int64(2)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(pdata_offset)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_4)) - int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_1[0]))))))) + int64(int64(8)))) >> int(int64(int64(int64(8) * int64(1)))))))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(pdata_offset)))[3])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(int(int64(intptr(p_4)))) - int64(int(int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_1[0]))))))))))) + int(int64(int64(8))))))))
    var err_10 : int = int(int(int(unsafe(*mux_5).write_callback(int64(unsafe(*mux_5).write_pos), intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_1[0]))))), uint64(uint64(unsafe(uint64(int64(intptr(p_4))) - uint64(int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_1[0])))))))))), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_5).token)))))))
    if (uint64(err_10) != uint64(0)) {
        return err_10
    }
    unsafe(*mux_5).write_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mux_5).write_pos))) + unsafe(int64(intptr(p_4)) - int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_1[0]))))))))
    return 0
    return int(0)
}
[export]
def MP4E_put_sample(var mux_1 : minimp4::MP4E_mux_tag?; var track_num : int; var data : uint64; var data_bytes : int; var duration : int; var kind : int) : int {
    var tr_1 : minimp4::track_t? = null
    if (mux_1 == null || uint64(data) == uint64(0)) {
        return -1
    }
    tr_1 = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_1).tracks.data)))))), int(track_num), 112))))))))))))))
    if (uint64(unsafe(*mux_1).enable_fragmentation) != uint64(0)) {
        var c2da_fresh5 : int = unsafe(*mux_1).fragments_count
        unsafe(*mux_1).fragments_count = int(unsafe(*mux_1).fragments_count) + 1
        if (uint64(c2da_fresh5) == uint64(0)) {
            var err_1 : int = mp4e_flush_index(mux_1)
            if (uint64(err_1) != uint64(0)) {
                return err_1
            }
        }
        var err_2 : int = mp4e_write_fragment_header(mux_1, track_num, data_bytes, duration, kind)
        if (uint64(err_2) != uint64(0)) {
            return err_2
        }
        var err_3 : int = int(int(int(mp4e_write_mdat_box(mux_1, uint(uint(uint(int(data_bytes)) + uint(8)))))))
        if (uint64(err_3) != uint64(0)) {
            return err_3
        }
        var err_4 : int = unsafe(*mux_1).write_callback(int64(unsafe(*mux_1).write_pos), data, uint64(uint64(data_bytes)), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_1).token))))
        if (uint64(err_4) != uint64(0)) {
            return err_4
        }
        unsafe(*mux_1).write_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mux_1).write_pos))) + int64(data_bytes))
        return 0
    }
    if (int(kind) != 2) {
        if (uint64(unsafe(*mux_1).sequential_mode_flag) != uint64(0)) {
            var err_5 : int = write_pending_data(mux_1, tr_1)
            if (uint64(err_5) != uint64(0)) {
                return err_5
            }
        }
        if (uint64(add_sample_descriptor(mux_1, tr_1, data_bytes, duration, kind)) == uint64(0)) {
            return -2
        }
    } else {
        if (uint64(unsafe(*mux_1).sequential_mode_flag) == uint64(0)) {
            var smpl_desc : minimp4::sample_t? = null
            if (uint64(unsafe(*tr_1).smpl.bytes) < uint64(0x18)) {
                return -2
            }
            smpl_desc = unsafe(unsafe(reinterpret<minimp4::sample_t?>(unsafe(unsafe(reinterpret<minimp4::sample_t?>(unsafe(unsafe(reinterpret<minimp4::sample_t?>(unsafe(unsafe(reinterpret<minimp4::sample_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(reinterpret<minimp4::sample_t?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*tr_1).smpl.data))), int(unsafe(*tr_1).smpl.bytes), 1)))))))))), -1, 24))))))))))))))
            unsafe(*smpl_desc).size = uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(*smpl_desc).size))) + uint64(data_bytes))
        }
    }
    if (uint64(unsafe(*mux_1).sequential_mode_flag) != uint64(0)) {
        if (unsafe(unsafe(reinterpret<uint8?>(minimp4_vector_put(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_1).pending_sample))))), data, data_bytes)))) == null) {
            return -2
        }
    } else {
        var err_6 : int = unsafe(*mux_1).write_callback(int64(unsafe(*mux_1).write_pos), data, uint64(uint64(data_bytes)), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_1).token))))
        if (uint64(err_6) != uint64(0)) {
            return err_6
        }
        unsafe(*mux_1).write_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mux_1).write_pos))) + int64(data_bytes))
    }
    return 0
    return int(0)
}
[export]
def show_bits(var bs_2 : minimp4::bit_reader_t?; var n_0 : int) : uint {
    var retval_0 : uint = uint(uint(uint(0)))
    retval_0 = uint(uint(uint(uint(uint(unsafe(*bs_2).cache)) >> uint(uint(uint(32) - uint(int(n_0)))))))
    return retval_0
    return uint(0)
}
[export]
def find_mem_cache(var cache : uint64?; var cache_bytes : int?; var cache_size : int; var mem_0 : uint64; var bytes_6 : int) : int {
    var i_6 : int = int(0)
    if (uint64(bytes_6) == uint64(0)) {
        return -1
    }
    i_6 = 0
    while (int(i_6) < int(cache_size)) {
        if (unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(cache_bytes)))[uint(i_6)])) == int(bytes_6) && uint64(unsafe(memcmp(unsafe(unsafe(reinterpret<void?>(mem_0))), unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(cache)))[uint(i_6)]))))), int(uint64(bytes_6))))) == uint64(0)) {
            return i_6
        }
        var c2da_fresh989 : int = i_6
        i_6 = int(i_6) + 1
    }
    i_6 = 0
    while (int(i_6) < int(cache_size)) {
        if (uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(cache_bytes)))[uint(i_6)]))) == uint64(0)) {
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(cache)))[uint(i_6)])) = unsafe(c2da_malloc(uint64(uint64(bytes_6))))
            if (uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(cache)))[uint(i_6)]))) != uint64(0)) {
                unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(cache)))[uint(i_6)]))))), unsafe(unsafe(reinterpret<void?>(mem_0))), int(uint64(bytes_6))))
                unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(cache_bytes)))[uint(i_6)])) = bytes_6
            }
            return i_6
        }
        var c2da_fresh990 : int = i_6
        i_6 = int(i_6) + 1
    }
    return -1
    return int(0)
}
[export]
def minimp4_vector_reset(var h_10 : minimp4::minimp4_vector_t?) {
    if (unsafe(*h_10).data != null) {
        unsafe(c2da_free(intptr(unsafe(*h_10).data)))
    }
    unsafe(*h_10) = minimp4::minimp4_vector_t()
}
[export]
def c2da_probe_minimp4_second_box_name(var read_callback_4 : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token_5 : uint64; var file_size_4 : int64) : int {
    var mp4_13 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var eof_flag_7 : int = 0
    var box_bytes_0 : uint64 = uint64(uint64(uint64(0)))
    var payload_bytes_1 : uint64 = uint64(uint64(uint64(0)))
    mp4_13 = minimp4::MP4D_demux_tag()
    mp4_13.read_callback = read_callback_4
    mp4_13.token = token_5
    mp4_13.read_size = int64(file_size_4)
    box_bytes_0 = uint64(uint64(uint64(uint64(minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_7))))))))))
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_7))))))
    payload_bytes_1 = uint64(uint64(uint64(uint64(box_bytes_0) - uint64(uint64(8)))))
    my_fseek(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))), uint64(payload_bytes_1), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_7))))))
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_7))))))
    return int(minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_7)))))))
    return int(0)
}
[export]
def mp4_h26x_write_close(var h_3 : minimp4::mp4_h26x_writer_tag?) {
    var p_1 : minimp4::h264_sps_id_patcher_t? = unsafe(unsafe(reinterpret<minimp4::h264_sps_id_patcher_t?>(unsafe(unsafe(reinterpret<minimp4::h264_sps_id_patcher_t?>(unsafe(unsafe(reinterpret<minimp4::h264_sps_id_patcher_t?>(unsafe(unsafe(reinterpret<minimp4::h264_sps_id_patcher_t?>(unsafe(addr(unsafe(*h_3).sps_patcher))))))))))))))
    var i : int = int(0)
    i = 0
    while (int(i) < 32) {
        if (uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(unsafe(*p_1).sps_cache[0])))))[uint(i)]))) != uint64(0)) {
            unsafe(c2da_free(uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(unsafe(*p_1).sps_cache[0])))))[uint(i)])))))
        }
        var c2da_fresh2 : int = i
        i = int(i) + 1
    }
    i = 0
    while (int(i) < 256) {
        if (uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(unsafe(*p_1).pps_cache[0])))))[uint(i)]))) != uint64(0)) {
            unsafe(c2da_free(uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(unsafe(*p_1).pps_cache[0])))))[uint(i)])))))
        }
        var c2da_fresh3 : int = i
        i = int(i) + 1
    }
    unsafe(*h_3) = minimp4::mp4_h26x_writer_tag()
}
[export]
def h264e_bs_byte_align(var bs_8 : minimp4::bs_t?) : uint {
    var pos : int = int(h264e_bs_get_pos_bits(bs_8))
    h264e_bs_put_bits(bs_8, uint(uint(uint(int(-pos)) & uint(7))), uint(uint(uint(0))))
    return uint(uint(int(pos)) + (uint(int(-pos)) & uint(7)))
    return uint(0)
}
[export]
def MP4D_read_spspps(var mp4_7 : minimp4::MP4D_demux_tag const?; var ntrack_1 : uint; var pps_flag : int; var nsps_0 : int; var sps_bytes_0 : int?) : uint64 {
    var sps_count : int = int(0)
    var skip_bytes : int = int(0)
    var bytepos : int = 0
    var p_10 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(*mp4_7).track)))[uint(ntrack_1)])).dsi)))))))))
    if (uint(ntrack_1) >= uint(unsafe(*mp4_7).track_count)) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
    }
    if (uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(*mp4_7).track)))[uint(ntrack_1)])).object_type_indication) != uint(uint(33))) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
    }
    if (uint64(pps_flag) != uint64(0)) {
        var c2da_fresh1051 : int = bytepos
        bytepos = int(bytepos) + 1
        sps_count = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(p_10)))[uint(c2da_fresh1051)])))
        skip_bytes = skip_spspps(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_10))), int(bytepos), 1))))))), int(int(uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(*mp4_7).track)))[uint(ntrack_1)])).dsi_bytes)) - int(uint(bytepos))), sps_count)
        if (int(skip_bytes) < 0) {
            return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
        }
        bytepos = int(bytepos) + int(skip_bytes)
    }
    var c2da_fresh1052 : int = bytepos
    bytepos = int(bytepos) + 1
    sps_count = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(p_10)))[uint(c2da_fresh1052)])))
    if (int(nsps_0) >= int(sps_count)) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
    }
    skip_bytes = skip_spspps(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_10))), int(bytepos), 1))))))), int(int(uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(*mp4_7).track)))[uint(ntrack_1)])).dsi_bytes)) - int(uint(bytepos))), nsps_0)
    if (int(skip_bytes) < 0) {
        return unsafe(unsafe(reinterpret<uint64>(uint64(0x0))))
    }
    bytepos = int(bytepos) + int(skip_bytes)
    *sps_bytes_0 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(p_10)))[uint(bytepos)]))) * 256 + int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(p_10)))[int(bytepos) + 1])))
    return unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_10))), int(bytepos), 1)))))))), 2, 1)))))))))))
    return unsafe(unsafe(reinterpret<uint64>(null)))
}
[export]
def minimp4_read(var mp4_3 : minimp4::MP4D_demux_tag?; var nb_0 : int; var eof_flag_2 : int?) : uint {
    label 0:
    var v_1 : uint = uint(uint(uint(uint(uint(0)))))
    goto label 2
    label 2:
    var last_byte : int = int(0)
    goto label 4
    label 4:
    if (nb_0 == 4) {
        goto label 50181
    }
    if (nb_0 == 3) {
        goto label 50183
    }
    if (nb_0 == 2) {
        goto label 50185
    }
    if (nb_0 == 1) {
        goto label 50189
    }
    goto label 50187
    label 50181:
    v_1 = uint(uint(uint(uint(uint(v_1)) << uint(uint(8)) | uint(minimp4_fgets(mp4_3)))))
    goto label 10
    label 10:
    goto label 50183
    label 50183:
    v_1 = uint(uint(uint(uint(uint(v_1)) << uint(uint(8)) | uint(minimp4_fgets(mp4_3)))))
    goto label 12
    label 12:
    goto label 50185
    label 50185:
    v_1 = uint(uint(uint(uint(uint(v_1)) << uint(uint(8)) | uint(minimp4_fgets(mp4_3)))))
    goto label 14
    label 14:
    goto label 50187
    label 50187:
    goto label 50189
    label 50189:
    last_byte = minimp4_fgets(mp4_3)
    v_1 = uint(uint(uint(uint(uint(v_1)) << uint(uint(8)) | uint(last_byte))))
    goto label 16
    label 16:
    goto label 6
    label 6:
    if (int(last_byte) < 0) {
        goto label 18
    } else {
        goto label 20
    }
    label 18:
    *eof_flag_2 = 1
    goto label 24
    label 24:
    goto label 22
    label 20:
    goto label 22
    label 22:
    return v_1
    return uint(0)
}
[export]
def h264e_bs_put_golomb(var bs_15 : minimp4::bs_t?; var val_1 : uint) {
    var size_3 : int = 0
    var t : uint = uint(uint(uint(uint(val_1) + uint(uint(1)))))
    while (true) {
        var c2da_fresh988 : int = size_3
        size_3 = int(size_3) + 1
        t = uint(uint(uint(uint(t) >> uint(1))))
        if (!(uint64(t) != uint64(0))) {
            break
        }
    }
    h264e_bs_put_bits(bs_15, uint(uint(uint(2) * uint(int(size_3)) - uint(1))), uint(uint(val_1) + uint(uint(1))))
}
[export]
def MP4E_set_pps(var mux_7 : minimp4::MP4E_mux_tag?; var track_id : int; var pps : uint64; var bytes_2 : int) : int {
    var tr_10 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_7).tracks.data)))))), int(track_id), 112))))))))))))))
    var c2da_fresh979 : int = int(0)
    if (uint64(append_mem(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_10).vpps))))), pps, bytes_2)) != uint64(0)) {
        c2da_fresh979 = 0
    } else {
        c2da_fresh979 = -2
    }
    return c2da_fresh979
    return int(0)
}
[export]
def minimp4_fgets(var mp4_4 : minimp4::MP4D_demux_tag?) : int {
    var c : uint8 = uint8(uint8(uint8(0)))
    if (uint64(unsafe(*mp4_4).read_callback(int64(unsafe(*mp4_4).read_pos), intptr(unsafe(reinterpret<uint8?>(unsafe(addr(c))))), uint64(uint64(uint64(1))), unsafe(unsafe(reinterpret<uint64>(unsafe(*mp4_4).token))))) != uint64(0)) {
        return -1
    }
    var c2da_fresh1047 : int64 = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mp4_4).read_pos))))
    unsafe(*mp4_4).read_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mp4_4).read_pos))) + int64(1))
    return int(c)
    return int(0)
}
[export]
def get_pos_bits(var bs_14 : minimp4::bit_reader_t const?) : uint {
    var pos_bits_1 : uint = uint(uint(uint(uint(unsafe(uint(int64(intptr(unsafe(*bs_14).buf))) - uint(int64(intptr(unsafe(*bs_14).origin))))) * uint(uint(16)))))
    pos_bits_1 = uint(uint(uint(uint(pos_bits_1) - uint(uint(16) - uint(int(unsafe(*bs_14).cache_free_bits))))))
    return pos_bits_1
    return uint(0)
}
[export]
def minimp4_vector_alloc_tail(var h_1 : minimp4::minimp4_vector_t?; var bytes : int) : uint8? {
    var p : uint8? = null
    if (unsafe(*h_1).data == null && uint64(minimp4_vector_init(h_1, 2 * int(bytes) + 1024)) == uint64(0)) {
        return null
    }
    if (int(unsafe(*h_1).capacity) - int(unsafe(*h_1).bytes) < int(bytes) && uint64(minimp4_vector_grow(h_1, bytes)) == uint64(0)) {
        return null
    }
    p = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*h_1).data))), int(unsafe(*h_1).bytes), 1))))))))))))))
    unsafe(*h_1).bytes = int(unsafe(*h_1).bytes) + int(bytes)
    return unsafe(unsafe(reinterpret<uint8?>(p)))
    return unsafe(unsafe(reinterpret<uint8?>(null)))
}
[export]
def MP4D_open(var mp4 : minimp4::MP4D_demux_tag?; var read_callback : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token : uint64; var file_size : int64) : int {
    label 0:
    var depth : int = 0
    goto label 2
    label 2:
    goto label 4
    label 4:
    var stack_1 : minimp4::Unnamed_6 [64] = fixed_array<minimp4::Unnamed_6>(minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6(), minimp4::Unnamed_6())
    goto label 6
    label 6:
    var eof_flag : int = 0
    goto label 8
    label 8:
    var i_9 : uint = uint(uint(uint(0)))
    goto label 10
    label 10:
    var tr_13 : minimp4::MP4D_track_t? = null
    goto label 12
    label 12:
    if (mp4 == null || read_callback == unsafe(unsafe(reinterpret<function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>>(null)))) {
        goto label 14
    } else {
        goto label 16
    }
    label 14:
    return 0
    label 16:
    goto label 18
    label 18:
    unsafe(*mp4) = minimp4::MP4D_demux_tag()
    goto label 20
    label 20:
    unsafe(*mp4).read_callback = read_callback
    goto label 22
    label 22:
    unsafe(*mp4).token = token
    goto label 24
    label 24:
    unsafe(*mp4).read_size = int64(file_size)
    goto label 26
    label 26:
    unsafe(stack_1[0]).format = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))
    goto label 28
    label 28:
    unsafe(stack_1[0]).bytes = uint64(uint64(uint64(0)))
    goto label 30
    label 30:
    goto label 32
    label 32:
    goto label 38
    label 38:
    var g_fullbox : minimp4::Unnamed_8 [13] const = fixed_array<minimp4::Unnamed_8>(minimp4::Unnamed_8(name = uint(BOX_mdhd), max_version = uint(uint(1)), use_track_flag = uint(uint(1))), minimp4::Unnamed_8(name = uint(BOX_mvhd), max_version = uint(uint(1)), use_track_flag = uint(uint(0))), minimp4::Unnamed_8(name = uint(BOX_hdlr), max_version = uint(uint(0)), use_track_flag = uint(uint(0))), minimp4::Unnamed_8(name = uint(BOX_meta), max_version = uint(uint(0)), use_track_flag = uint(uint(0))), minimp4::Unnamed_8(name = uint(BOX_stts), max_version = uint(uint(0)), use_track_flag = uint(uint(0))), minimp4::Unnamed_8(name = uint(BOX_ctts), max_version = uint(uint(0)), use_track_flag = uint(uint(0))), minimp4::Unnamed_8(name = uint(BOX_stz2), max_version = uint(uint(0)), use_track_flag = uint(uint(1))), minimp4::Unnamed_8(name = uint(BOX_stsz), max_version = uint(uint(0)), use_track_flag = uint(uint(1))), minimp4::Unnamed_8(name = uint(BOX_stsc), max_version = uint(uint(0)), use_track_flag = uint(uint(1))), minimp4::Unnamed_8(name = uint(BOX_stco), max_version = uint(uint(0)), use_track_flag = uint(uint(1))), minimp4::Unnamed_8(name = uint(BOX_co64), max_version = uint(uint(0)), use_track_flag = uint(uint(1))), minimp4::Unnamed_8(name = uint(BOX_stsd), max_version = uint(uint(0)), use_track_flag = uint(uint(0))), minimp4::Unnamed_8(name = uint(BOX_esds), max_version = uint(uint(0)), use_track_flag = uint(uint(1))))
    goto label 40
    label 40:
    goto label 42
    label 42:
    var g_envelope_box : minimp4::Unnamed_7 [20] const = fixed_array<minimp4::Unnamed_7>(minimp4::Unnamed_7(name = uint(BOX_esds), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_OD))), minimp4::Unnamed_7(name = uint(OD_ESD), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_OD))), minimp4::Unnamed_7(name = uint(OD_DCD), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_OD))), minimp4::Unnamed_7(name = uint(OD_DSI), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_OD))), minimp4::Unnamed_7(name = uint(BOX_trak), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_moov), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_mdia), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_tref), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_minf), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_dinf), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_stbl), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_stsd), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_mp4a), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_mp4s), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_mp4v), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_avc1), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_hvc1), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_udta), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_meta), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))), minimp4::Unnamed_7(name = uint(BOX_ilst), type_0 = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))))
    goto label 44
    label 44:
    var FullAtomVersionAndFlags : uint = uint(uint(uint(uint(uint(0)))))
    goto label 46
    label 46:
    var payload_bytes : uint64 = uint64(uint64(uint64(0)))
    goto label 48
    label 48:
    var box_bytes : uint64 = uint64(uint64(uint64(0)))
    goto label 50
    label 50:
    var box_name : uint = uint(uint(uint(0)))
    goto label 52
    label 52:
    var ptag : uint8?? = null
    goto label 54
    label 54:
    var read_bytes : int = 0
    goto label 56
    label 56:
    if (uint(unsafe(stack_1[uint(depth)]).format) == uint(BOX_ATOM)) {
        goto label 58
    } else {
        goto label 60
    }
    label 58:
    box_bytes = uint64(uint64(uint64(uint64(minimp4_read(mp4, 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))))
    goto label 64
    label 64:
    goto label 56217
    label 56217:
    if (uint64(eof_flag) != uint64(0)) {
        goto label 66
    } else {
        goto label 68
    }
    label 66:
    goto label 36
    label 68:
    goto label 70
    label 70:
    if (uint64(box_bytes) >= uint64(uint64(2)) && uint64(box_bytes) < uint64(uint64(8))) {
        goto label 72
    } else {
        goto label 74
    }
    label 72:
    if (uint64(depth) == uint64(0)) {
        goto label 78
    } else {
        goto label 80
    }
    label 78:
    goto label 36
    label 80:
    MP4D_close(mp4)
    goto label 84
    label 84:
    return 0
    label 74:
    goto label 76
    label 76:
    box_name = uint(uint(uint(minimp4_read(mp4, 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 86
    label 86:
    read_bytes = 8
    goto label 88
    label 88:
    if (uint64(uint64(box_bytes)) == uint64(0) || uint64(box_bytes) == uint64(uint64(0xffffffff))) {
        goto label 90
    } else {
        goto label 92
    }
    label 90:
    box_bytes = uint64(uint64(uint64(~uint64(uint64(0)))))
    goto label 96
    label 96:
    goto label 94
    label 92:
    goto label 94
    label 94:
    payload_bytes = uint64(uint64(uint64(uint64(box_bytes) - uint64(uint64(8)))))
    goto label 98
    label 98:
    if (uint64(box_bytes) == uint64(uint64(1))) {
        goto label 100
    } else {
        goto label 102
    }
    label 100:
    box_bytes = uint64(uint64(uint64(uint64(minimp4_read(mp4, 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))))
    goto label 106
    label 106:
    if (uint64(box_bytes) != uint64(0)) {
        goto label 108
    } else {
        goto label 110
    }
    label 108:
    if (uint64(depth) == uint64(0)) {
        goto label 114
    } else {
        goto label 116
    }
    label 114:
    goto label 36
    label 116:
    MP4D_close(mp4)
    goto label 120
    label 120:
    return 0
    label 110:
    goto label 112
    label 112:
    box_bytes = uint64(uint64(uint64(uint64(minimp4_read(mp4, 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))))
    goto label 122
    label 122:
    if (uint64(box_bytes) < uint64(uint64(16))) {
        goto label 124
    } else {
        goto label 126
    }
    label 124:
    if (uint64(depth) == uint64(0)) {
        goto label 130
    } else {
        goto label 132
    }
    label 130:
    goto label 36
    label 132:
    MP4D_close(mp4)
    goto label 136
    label 136:
    return 0
    label 126:
    goto label 128
    label 128:
    payload_bytes = uint64(uint64(uint64(uint64(box_bytes) - uint64(uint64(16)))))
    goto label 138
    label 138:
    goto label 104
    label 102:
    goto label 104
    label 104:
    goto label 146
    label 146:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 148
    label 148:
    goto label 140
    label 140:
    if (uint64(i_9) < uint64(0x9c) / uint64(0xc)) {
        goto label 142
    } else {
        goto label 144
    }
    label 142:
    if (uint(box_name) == uint(unsafe(g_fullbox[uint(i_9)]).name)) {
        goto label 150
    } else {
        goto label 152
    }
    label 150:
    FullAtomVersionAndFlags = uint(uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 156
    label 156:
    read_bytes = int(read_bytes) + 4
    goto label 158
    label 158:
    if (uint(box_name) == uint(BOX_meta)) {
        goto label 160
    } else {
        goto label 162
    }
    label 160:
    if (uint(FullAtomVersionAndFlags) >= uint(uint(8)) && uint64(FullAtomVersionAndFlags) < uint64(payload_bytes)) {
        goto label 166
    } else {
        goto label 168
    }
    label 166:
    if (uint64(box_bytes) > uint64(unsafe(stack_1[uint(depth)]).bytes)) {
        goto label 172
    } else {
        goto label 174
    }
    label 172:
    if (uint64(depth) == uint64(0)) {
        goto label 178
    } else {
        goto label 180
    }
    label 178:
    goto label 144
    label 180:
    MP4D_close(mp4)
    goto label 184
    label 184:
    return 0
    label 174:
    goto label 176
    label 176:
    unsafe(stack_1[uint(depth)]).bytes = uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(stack_1[uint(depth)]).bytes))) - uint64(box_bytes))
    goto label 186
    label 186:
    var c2da_fresh1000 : int = depth
    depth = int(depth) + 1
    goto label 188
    label 188:
    unsafe(stack_1[uint(depth)]).bytes = uint64(uint64(payload_bytes) + uint64(uint64(4)))
    goto label 190
    label 190:
    unsafe(stack_1[uint(depth)]).format = unsafe(reinterpret<minimp4::boxtype_t>(BOX_ATOM))
    goto label 192
    label 192:
    box_bytes = uint64(uint64(uint64(uint64(FullAtomVersionAndFlags))))
    goto label 194
    label 194:
    goto label 56217
    label 168:
    goto label 170
    label 170:
    goto label 164
    label 162:
    goto label 164
    label 164:
    if (uint(uint(FullAtomVersionAndFlags)) >> uint(uint(24)) > uint(unsafe(g_fullbox[uint(i_9)]).max_version)) {
        goto label 196
    } else {
        goto label 198
    }
    label 196:
    if (uint64(depth) == uint64(0)) {
        goto label 202
    } else {
        goto label 204
    }
    label 202:
    goto label 144
    label 204:
    MP4D_close(mp4)
    goto label 208
    label 208:
    return 0
    label 198:
    goto label 200
    label 200:
    if (uint64(unsafe(g_fullbox[uint(i_9)]).use_track_flag) != uint64(0) && tr_13 == null) {
        goto label 210
    } else {
        goto label 212
    }
    label 210:
    if (uint64(depth) == uint64(0)) {
        goto label 216
    } else {
        goto label 218
    }
    label 216:
    goto label 144
    label 218:
    MP4D_close(mp4)
    goto label 222
    label 222:
    return 0
    label 212:
    goto label 214
    label 214:
    goto label 154
    label 152:
    goto label 154
    label 154:
    var c2da_fresh1001 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 140
    label 144:
    goto label 62
    label 60:
    var val_2 : int = int(0)
    goto label 224
    label 224:
    box_name = uint(uint(uint(uint(OD_BASE) + uint(minimp4_read(mp4, 1, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))))
    goto label 226
    label 226:
    read_bytes = int(read_bytes) + 1
    goto label 228
    label 228:
    if (uint64(eof_flag) != uint64(0)) {
        goto label 230
    } else {
        goto label 232
    }
    label 230:
    goto label 36
    label 232:
    goto label 234
    label 234:
    payload_bytes = uint64(uint64(uint64(uint64(uint64(0)))))
    goto label 236
    label 236:
    box_bytes = uint64(uint64(uint64(uint64(uint64(1)))))
    goto label 238
    label 238:
    goto label 240
    label 240:
    val_2 = int(minimp4_read(mp4, 1, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 246
    label 246:
    read_bytes = int(read_bytes) + 1
    goto label 248
    label 248:
    if (uint64(eof_flag) != uint64(0)) {
        goto label 250
    } else {
        goto label 252
    }
    label 250:
    if (uint64(depth) == uint64(0)) {
        goto label 256
    } else {
        goto label 258
    }
    label 256:
    goto label 244
    label 258:
    MP4D_close(mp4)
    goto label 262
    label 262:
    return 0
    label 252:
    goto label 254
    label 254:
    payload_bytes = uint64(uint64(uint64(uint64(uint64(payload_bytes)) << uint64(uint64(7)) | uint64(uint64(int(val_2)) & uint64(127)))))
    goto label 264
    label 264:
    var c2da_fresh1002 : uint64 = uint64(uint64(box_bytes))
    box_bytes = uint64(uint64(uint64(uint64(box_bytes) + uint64(1))))
    goto label 266
    label 266:
    goto label 242
    label 242:
    if (uint64(int(val_2) & 128) != uint64(0)) {
        goto label 240
    } else {
        goto label 244
    }
    label 244:
    box_bytes = uint64(uint64(uint64(uint64(box_bytes) + uint64(payload_bytes))))
    goto label 268
    label 268:
    goto label 62
    label 62:
    if (uint64(depth) != uint64(0)) {
        goto label 270
    } else {
        goto label 272
    }
    label 270:
    goto label 276
    label 276:
    if (uint64(box_bytes) > uint64(unsafe(stack_1[uint(depth)]).bytes)) {
        goto label 278
    } else {
        goto label 280
    }
    label 278:
    box_bytes = uint64(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(stack_1[uint(depth)]).bytes)))))
    goto label 284
    label 284:
    box_name = uint(uint(uint(uint(uint(0)))))
    goto label 286
    label 286:
    payload_bytes = uint64(uint64(uint64(uint64(box_bytes) - uint64(read_bytes))))
    goto label 288
    label 288:
    goto label 282
    label 280:
    goto label 282
    label 282:
    unsafe(stack_1[uint(depth)]).bytes = uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(stack_1[uint(depth)]).bytes))) - uint64(box_bytes))
    goto label 290
    label 290:
    goto label 274
    label 272:
    goto label 274
    label 274:
    if (box_name == 0x73747a32) {
        goto label 50703
    }
    if (box_name == 0x7374737a) {
        goto label 55389
    }
    if (box_name == 0x73747363) {
        goto label 50707
    }
    if (box_name == 0x73747473) {
        goto label 50719
    }
    if (box_name == 0x63747473) {
        goto label 50723
    }
    if (box_name == 0x7374636f) {
        goto label 50727
    }
    if (box_name == 0x636f3634) {
        goto label 54385
    }
    if (box_name == 0x6d766864) {
        goto label 50739
    }
    if (box_name == 0x6d646864) {
        goto label 50755
    }
    if (box_name == 0x68646c72) {
        goto label 50769
    }
    if (box_name == 0x62747274) {
        goto label 50773
    }
    if (box_name == 0xa9616c62) {
        goto label 50783
    }
    if (box_name == 0xa9415254) {
        goto label 50787
    }
    if (box_name == 0xa96e616d) {
        goto label 50791
    }
    if (box_name == 0xa9646179) {
        goto label 50795
    }
    if (box_name == 0xa9636d74) {
        goto label 50799
    }
    if (box_name == 0xa967656e) {
        goto label 50803
    }
    if (box_name == 0x73747364) {
        goto label 50807
    }
    if (box_name == 0x6d703473) {
        goto label 50813
    }
    if (box_name == 0x6d703461) {
        goto label 50821
    }
    if (box_name == 0x61766331) {
        goto label 50837
    }
    if (box_name == 0x6d703476) {
        goto label 52375
    }
    if (box_name == 0x61766343) {
        goto label 50853
    }
    if (box_name == 0x24242433) {
        goto label 50863
    }
    if (box_name == 0x24242434) {
        goto label 50865
    }
    if (box_name == 0x24242435) {
        goto label 50879
    }
    goto label 50883
    label 50703:
    goto label 55389
    label 55389:
    var size_4 : int = 0
    goto label 296
    label 296:
    var sample_size : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 298
    label 298:
    unsafe(*tr_13).sample_count = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 300
    label 300:
    unsafe(*tr_13).entry_size = unsafe(unsafe(reinterpret<uint?>(unsafe(unsafe(reinterpret<uint?>(unsafe(c2da_malloc(uint64(uint64(uint64(uint(unsafe(*tr_13).sample_count)) * uint64(uint(uint(4)))))))))))))
    goto label 302
    label 302:
    if (unsafe(*tr_13).entry_size == null) {
        goto label 304
    } else {
        goto label 306
    }
    label 304:
    if (uint64(depth) == uint64(0)) {
        goto label 310
    } else {
        goto label 312
    }
    label 310:
    goto label 292
    label 312:
    MP4D_close(mp4)
    goto label 316
    label 316:
    return 0
    label 306:
    goto label 308
    label 308:
    goto label 324
    label 324:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 326
    label 326:
    goto label 318
    label 318:
    if (uint(i_9) < uint(unsafe(*tr_13).sample_count)) {
        goto label 320
    } else {
        goto label 322
    }
    label 320:
    if (uint(box_name) == uint(BOX_stsz)) {
        goto label 328
    } else {
        goto label 330
    }
    label 328:
    var c2da_fresh1003 : uint = uint(uint(uint(0)))
    if (uint64(sample_size) != uint64(0)) {
        c2da_fresh1003 = uint(uint(sample_size))
    } else {
        c2da_fresh1003 = uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))
    }
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_13).entry_size)))[uint(i_9)])) = uint(c2da_fresh1003)
    goto label 334
    label 334:
    goto label 332
    label 330:
    if ((uint(sample_size) & uint(uint(255))) == 0x10) {
        goto label 55431
    }
    if ((uint(sample_size) & uint(uint(255))) == 0x8) {
        goto label 55435
    }
    if ((uint(sample_size) & uint(uint(255))) == 0x4) {
        goto label 55439
    }
    goto label 336
    label 55431:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_13).entry_size)))[uint(i_9)])) = uint(read_payload(mp4, uint(uint(uint(2))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 340
    label 340:
    goto label 336
    label 55435:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_13).entry_size)))[uint(i_9)])) = uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 344
    label 344:
    goto label 336
    label 55439:
    if (uint64(uint(i_9) & uint(uint(1))) != uint64(0)) {
        goto label 348
    } else {
        goto label 350
    }
    label 348:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_13).entry_size)))[uint(i_9)])) = uint(uint(uint(int(size_4)) & uint(15)))
    goto label 354
    label 354:
    goto label 352
    label 350:
    size_4 = int(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 356
    label 356:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_13).entry_size)))[uint(i_9)])) = uint(uint(uint(int(size_4)) >> uint(4)))
    goto label 358
    label 358:
    goto label 352
    label 352:
    goto label 336
    label 336:
    goto label 332
    label 332:
    var c2da_fresh1004 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 318
    label 322:
    goto label 292
    label 50707:
    unsafe(*tr_13).sample_to_chunk_count = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 362
    label 362:
    unsafe(*tr_13).sample_to_chunk = unsafe(unsafe(reinterpret<minimp4::MP4D_sample_to_chunk_t_tag?>(unsafe(unsafe(reinterpret<minimp4::MP4D_sample_to_chunk_t_tag?>(unsafe(c2da_malloc(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(*tr_13).sample_to_chunk_count))) * uint64(0x8))))))))))
    goto label 364
    label 364:
    if (unsafe(*tr_13).sample_to_chunk == null) {
        goto label 366
    } else {
        goto label 368
    }
    label 366:
    if (uint64(depth) == uint64(0)) {
        goto label 372
    } else {
        goto label 374
    }
    label 372:
    goto label 292
    label 374:
    MP4D_close(mp4)
    goto label 378
    label 378:
    return 0
    label 368:
    goto label 370
    label 370:
    goto label 386
    label 386:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 388
    label 388:
    goto label 380
    label 380:
    if (uint(i_9) < uint(unsafe(*tr_13).sample_to_chunk_count)) {
        goto label 382
    } else {
        goto label 384
    }
    label 382:
    unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_sample_to_chunk_t_tag?>(unsafe(*tr_13).sample_to_chunk)))[uint(i_9)])).first_chunk = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 390
    label 390:
    unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_sample_to_chunk_t_tag?>(unsafe(*tr_13).sample_to_chunk)))[uint(i_9)])).samples_per_chunk = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 392
    label 392:
    var c2da_fresh1005 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(4))) {
        c2da_fresh1005 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1005 = uint64(uint64(uint64(uint64(4))))
    }
    var t_0 : uint64 = uint64(uint64(uint64(c2da_fresh1005)))
    goto label 394
    label 394:
    my_fseek(mp4, uint64(t_0), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 396
    label 396:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_0))))
    goto label 398
    label 398:
    var c2da_fresh1006 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 380
    label 384:
    goto label 292
    label 50719:
    var count_0 : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 402
    label 402:
    var j_1 : uint = uint(uint(uint(0)))
    goto label 404
    label 404:
    var k : uint = uint(uint(uint(uint(uint(0)))))
    goto label 406
    label 406:
    var ts : uint = uint(uint(uint(uint(uint(0)))))
    goto label 408
    label 408:
    var ts_count : uint = uint(uint(uint(count_0)))
    goto label 410
    label 410:
    unsafe(*tr_13).timestamp = unsafe(unsafe(reinterpret<uint?>(unsafe(unsafe(reinterpret<uint?>(unsafe(c2da_malloc(uint64(uint64(uint64(uint(ts_count)) * uint64(uint(uint(4)))))))))))))
    goto label 412
    label 412:
    if (unsafe(*tr_13).timestamp == null) {
        goto label 414
    } else {
        goto label 416
    }
    label 414:
    if (uint64(depth) == uint64(0)) {
        goto label 420
    } else {
        goto label 422
    }
    label 420:
    goto label 292
    label 422:
    MP4D_close(mp4)
    goto label 426
    label 426:
    return 0
    label 416:
    goto label 418
    label 418:
    unsafe(*tr_13).duration = unsafe(unsafe(reinterpret<uint?>(unsafe(unsafe(reinterpret<uint?>(unsafe(c2da_malloc(uint64(uint64(uint64(uint(ts_count)) * uint64(uint(uint(4)))))))))))))
    goto label 428
    label 428:
    if (unsafe(*tr_13).duration == null) {
        goto label 430
    } else {
        goto label 432
    }
    label 430:
    if (uint64(depth) == uint64(0)) {
        goto label 436
    } else {
        goto label 438
    }
    label 436:
    goto label 292
    label 438:
    MP4D_close(mp4)
    goto label 442
    label 442:
    return 0
    label 432:
    goto label 434
    label 434:
    goto label 450
    label 450:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 452
    label 452:
    goto label 444
    label 444:
    if (uint(i_9) < uint(count_0)) {
        goto label 446
    } else {
        goto label 448
    }
    label 446:
    var sc : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 454
    label 454:
    var d_0 : int = int(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 456
    label 456:
    if (uint(k) + uint(sc) > uint(ts_count)) {
        goto label 458
    } else {
        goto label 460
    }
    label 458:
    ts_count = uint(uint(uint(uint(k) + uint(sc))))
    goto label 464
    label 464:
    unsafe(*tr_13).timestamp = unsafe(unsafe(reinterpret<uint?>(unsafe(unsafe(reinterpret<uint?>(unsafe(realloc(intptr(unsafe(*tr_13).timestamp), uint64(uint64(ts_count) * uint64(0x4))))))))))
    goto label 466
    label 466:
    unsafe(*tr_13).duration = unsafe(unsafe(reinterpret<uint?>(unsafe(unsafe(reinterpret<uint?>(unsafe(realloc(intptr(unsafe(*tr_13).duration), uint64(uint64(ts_count) * uint64(0x4))))))))))
    goto label 468
    label 468:
    goto label 462
    label 460:
    goto label 462
    label 462:
    goto label 476
    label 476:
    j_1 = uint(uint(uint(uint(uint(0)))))
    goto label 478
    label 478:
    goto label 470
    label 470:
    if (uint(j_1) < uint(sc)) {
        goto label 472
    } else {
        goto label 474
    }
    label 472:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_13).duration)))[uint(k)])) = uint(uint(d_0))
    goto label 480
    label 480:
    var c2da_fresh1007 : uint = uint(uint(k))
    k = uint(uint(uint(uint(k) + uint(1))))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_13).timestamp)))[uint(c2da_fresh1007)])) = uint(ts)
    goto label 482
    label 482:
    ts = uint(uint(uint(uint(ts) + uint(d_0))))
    goto label 484
    label 484:
    var c2da_fresh1008 : uint = uint(uint(j_1))
    j_1 = uint(uint(uint(uint(j_1) + uint(1))))
    goto label 470
    label 474:
    var c2da_fresh1009 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 444
    label 448:
    goto label 292
    label 50723:
    var count_1 : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 488
    label 488:
    goto label 496
    label 496:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 498
    label 498:
    goto label 490
    label 490:
    if (uint(i_9) < uint(count_1)) {
        goto label 492
    } else {
        goto label 494
    }
    label 492:
    var sc_0 : int = int(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 500
    label 500:
    var d_1 : int = int(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 502
    label 502:
    goto label 504
    label 504:
    goto label 506
    label 506:
    var c2da_fresh1010 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 490
    label 494:
    goto label 292
    label 50727:
    goto label 54385
    label 54385:
    unsafe(*tr_13).chunk_count = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 510
    label 510:
    unsafe(*tr_13).chunk_offset = unsafe(unsafe(reinterpret<uint64?>(unsafe(unsafe(reinterpret<uint64?>(unsafe(c2da_malloc(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(*tr_13).chunk_count))) * uint64(0x8))))))))))
    goto label 512
    label 512:
    if (unsafe(*tr_13).chunk_offset == null) {
        goto label 514
    } else {
        goto label 516
    }
    label 514:
    if (uint64(depth) == uint64(0)) {
        goto label 520
    } else {
        goto label 522
    }
    label 520:
    goto label 292
    label 522:
    MP4D_close(mp4)
    goto label 526
    label 526:
    return 0
    label 516:
    goto label 518
    label 518:
    goto label 534
    label 534:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 536
    label 536:
    goto label 528
    label 528:
    if (uint(i_9) < uint(unsafe(*tr_13).chunk_count)) {
        goto label 530
    } else {
        goto label 532
    }
    label 530:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(*tr_13).chunk_offset)))[uint(i_9)])) = uint64(uint64(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))
    goto label 538
    label 538:
    if (uint(box_name) == uint(BOX_co64)) {
        goto label 540
    } else {
        goto label 542
    }
    label 540:
    if (uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(*tr_13).chunk_offset)))[uint(i_9)]))) != uint64(0)) {
        goto label 546
    } else {
        goto label 548
    }
    label 546:
    if (uint64(depth) == uint64(0)) {
        goto label 552
    } else {
        goto label 554
    }
    label 552:
    goto label 532
    label 554:
    MP4D_close(mp4)
    goto label 558
    label 558:
    return 0
    label 548:
    goto label 550
    label 550:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(*tr_13).chunk_offset)))[uint(i_9)])) = uint64(uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(*tr_13).chunk_offset)))[uint(i_9)]))) << uint64(32))
    goto label 560
    label 560:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(*tr_13).chunk_offset)))[uint(i_9)])) = uint64(uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(*tr_13).chunk_offset)))[uint(i_9)]))) | uint64(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))
    goto label 562
    label 562:
    goto label 544
    label 542:
    goto label 544
    label 544:
    var c2da_fresh1011 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 528
    label 532:
    goto label 292
    label 50739:
    var c2da_fresh1012 : int = int(0)
    if (uint(uint(FullAtomVersionAndFlags)) >> uint(uint(24)) == uint(uint(1))) {
        c2da_fresh1012 = 8 + 8
    } else {
        c2da_fresh1012 = 4 + 4
    }
    var c2da_fresh1013 : int = int(0)
    if (uint(uint(FullAtomVersionAndFlags)) >> uint(uint(24)) == uint(uint(1))) {
        c2da_fresh1013 = 8 + 8
    } else {
        c2da_fresh1013 = 4 + 4
    }
    var c2da_fresh1014 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(c2da_fresh1012)) {
        c2da_fresh1014 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1014 = uint64(uint64(uint64(c2da_fresh1013)))
    }
    var t_1 : uint64 = uint64(uint64(uint64(c2da_fresh1014)))
    goto label 566
    label 566:
    my_fseek(mp4, uint64(t_1), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 568
    label 568:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_1))))
    goto label 570
    label 570:
    unsafe(*mp4).timescale = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 572
    label 572:
    var c2da_fresh1015 : uint = uint(uint(uint(0)))
    if (uint(uint(FullAtomVersionAndFlags)) >> uint(uint(24)) == uint(uint(1))) {
        c2da_fresh1015 = uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))
    } else {
        c2da_fresh1015 = uint(uint(uint(uint(0))))
    }
    unsafe(*mp4).duration_hi = uint(c2da_fresh1015)
    goto label 574
    label 574:
    unsafe(*mp4).duration_lo = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 576
    label 576:
    var c2da_fresh1016 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(4) + uint64(2) + uint64(2) + uint64(4) * uint64(2) + uint64(4) * uint64(9) + uint64(4) * uint64(6) + uint64(4))) {
        c2da_fresh1016 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1016 = uint64(uint64(uint64(uint64(4) + uint64(2) + uint64(2) + uint64(4) * uint64(2) + uint64(4) * uint64(9) + uint64(4) * uint64(6) + uint64(4))))
    }
    var t_2 : uint64 = uint64(uint64(uint64(c2da_fresh1016)))
    goto label 578
    label 578:
    my_fseek(mp4, uint64(t_2), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 580
    label 580:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_2))))
    goto label 582
    label 582:
    goto label 292
    label 50755:
    var c2da_fresh1017 : int = int(0)
    if (uint(uint(FullAtomVersionAndFlags)) >> uint(uint(24)) == uint(uint(1))) {
        c2da_fresh1017 = 8 + 8
    } else {
        c2da_fresh1017 = 4 + 4
    }
    var c2da_fresh1018 : int = int(0)
    if (uint(uint(FullAtomVersionAndFlags)) >> uint(uint(24)) == uint(uint(1))) {
        c2da_fresh1018 = 8 + 8
    } else {
        c2da_fresh1018 = 4 + 4
    }
    var c2da_fresh1019 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(c2da_fresh1017)) {
        c2da_fresh1019 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1019 = uint64(uint64(uint64(c2da_fresh1018)))
    }
    var t_3 : uint64 = uint64(uint64(uint64(c2da_fresh1019)))
    goto label 586
    label 586:
    my_fseek(mp4, uint64(t_3), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 588
    label 588:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_3))))
    goto label 590
    label 590:
    unsafe(*tr_13).timescale = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 592
    label 592:
    var c2da_fresh1020 : uint = uint(uint(uint(0)))
    if (uint(uint(FullAtomVersionAndFlags)) >> uint(uint(24)) == uint(uint(1))) {
        c2da_fresh1020 = uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))
    } else {
        c2da_fresh1020 = uint(uint(uint(uint(0))))
    }
    unsafe(*tr_13).duration_hi = uint(c2da_fresh1020)
    goto label 594
    label 594:
    unsafe(*tr_13).duration_lo = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 596
    label 596:
    var ISO_639_2_T : int = int(read_payload(mp4, uint(uint(uint(2))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 598
    label 598:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(unsafe(*tr_13).language[0])))))[2])) = uint8(uint8(uint8((uint(int(ISO_639_2_T)) & uint(31)) + uint(96))))
    goto label 600
    label 600:
    ISO_639_2_T = int(int(int(int(ISO_639_2_T) >> 5)))
    goto label 602
    label 602:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(unsafe(*tr_13).language[0])))))[1])) = uint8(uint8(uint8((uint(int(ISO_639_2_T)) & uint(31)) + uint(96))))
    goto label 604
    label 604:
    ISO_639_2_T = int(int(int(int(ISO_639_2_T) >> 5)))
    goto label 606
    label 606:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(unsafe(*tr_13).language[0])))))[0])) = uint8(uint8(uint8((uint(int(ISO_639_2_T)) & uint(31)) + uint(96))))
    goto label 608
    label 608:
    goto label 292
    label 50769:
    if (tr_13 != null) {
        goto label 612
    } else {
        goto label 614
    }
    label 612:
    var c2da_fresh1021 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(4))) {
        c2da_fresh1021 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1021 = uint64(uint64(uint64(uint64(4))))
    }
    var t_4 : uint64 = uint64(uint64(uint64(c2da_fresh1021)))
    goto label 618
    label 618:
    my_fseek(mp4, uint64(t_4), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 620
    label 620:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_4))))
    goto label 622
    label 622:
    unsafe(*tr_13).handler_type = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 624
    label 624:
    goto label 616
    label 614:
    goto label 616
    label 616:
    goto label 292
    label 50773:
    if (tr_13 == null) {
        goto label 628
    } else {
        goto label 630
    }
    label 628:
    if (uint64(depth) == uint64(0)) {
        goto label 634
    } else {
        goto label 636
    }
    label 634:
    goto label 292
    label 636:
    MP4D_close(mp4)
    goto label 640
    label 640:
    return 0
    label 630:
    goto label 632
    label 632:
    var c2da_fresh1022 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(4) + uint64(4))) {
        c2da_fresh1022 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1022 = uint64(uint64(uint64(uint64(4) + uint64(4))))
    }
    var t_5 : uint64 = uint64(uint64(uint64(c2da_fresh1022)))
    goto label 642
    label 642:
    my_fseek(mp4, uint64(t_5), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 644
    label 644:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_5))))
    goto label 646
    label 646:
    unsafe(*tr_13).avg_bitrate_bps = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 648
    label 648:
    goto label 292
    label 50783:
    ptag = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(unsafe(*mp4).tag.album))))))))))))))
    goto label 652
    label 652:
    goto label 292
    label 50787:
    ptag = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(unsafe(*mp4).tag.artist))))))))))))))
    goto label 656
    label 656:
    goto label 292
    label 50791:
    ptag = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(unsafe(*mp4).tag.title))))))))))))))
    goto label 660
    label 660:
    goto label 292
    label 50795:
    ptag = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(unsafe(*mp4).tag.year))))))))))))))
    goto label 664
    label 664:
    goto label 292
    label 50799:
    ptag = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(unsafe(*mp4).tag.comment))))))))))))))
    goto label 668
    label 668:
    goto label 292
    label 50803:
    ptag = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(unsafe(*mp4).tag.genre))))))))))))))
    goto label 672
    label 672:
    goto label 292
    label 50807:
    var c2da_fresh1023 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(4))) {
        c2da_fresh1023 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1023 = uint64(uint64(uint64(uint64(4))))
    }
    var t_6 : uint64 = uint64(uint64(uint64(c2da_fresh1023)))
    goto label 676
    label 676:
    my_fseek(mp4, uint64(t_6), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 678
    label 678:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_6))))
    goto label 680
    label 680:
    goto label 292
    label 50813:
    if (tr_13 == null) {
        goto label 684
    } else {
        goto label 686
    }
    label 684:
    if (uint64(depth) == uint64(0)) {
        goto label 690
    } else {
        goto label 692
    }
    label 690:
    goto label 292
    label 692:
    MP4D_close(mp4)
    goto label 696
    label 696:
    return 0
    label 686:
    goto label 688
    label 688:
    var c2da_fresh1024 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(6) * uint64(1) + uint64(2))) {
        c2da_fresh1024 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1024 = uint64(uint64(uint64(uint64(6) * uint64(1) + uint64(2))))
    }
    var t_7 : uint64 = uint64(uint64(uint64(c2da_fresh1024)))
    goto label 698
    label 698:
    my_fseek(mp4, uint64(t_7), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 700
    label 700:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_7))))
    goto label 702
    label 702:
    goto label 292
    label 50821:
    if (tr_13 == null) {
        goto label 706
    } else {
        goto label 708
    }
    label 706:
    if (uint64(depth) == uint64(0)) {
        goto label 712
    } else {
        goto label 714
    }
    label 712:
    goto label 292
    label 714:
    MP4D_close(mp4)
    goto label 718
    label 718:
    return 0
    label 708:
    goto label 710
    label 710:
    var c2da_fresh1025 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(6) * uint64(1) + uint64(2) + uint64(4) * uint64(2))) {
        c2da_fresh1025 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1025 = uint64(uint64(uint64(uint64(6) * uint64(1) + uint64(2) + uint64(4) * uint64(2))))
    }
    var t_8 : uint64 = uint64(uint64(uint64(c2da_fresh1025)))
    goto label 720
    label 720:
    my_fseek(mp4, uint64(t_8), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 722
    label 722:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_8))))
    goto label 724
    label 724:
    unsafe(*tr_13).SampleDescription.audio.channelcount = uint(read_payload(mp4, uint(uint(uint(2))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 726
    label 726:
    var c2da_fresh1026 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(2) + uint64(2) + uint64(2))) {
        c2da_fresh1026 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1026 = uint64(uint64(uint64(uint64(2) + uint64(2) + uint64(2))))
    }
    var t_9 : uint64 = uint64(uint64(uint64(c2da_fresh1026)))
    goto label 728
    label 728:
    my_fseek(mp4, uint64(t_9), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 730
    label 730:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_9))))
    goto label 732
    label 732:
    unsafe(*tr_13).SampleDescription.audio.samplerate_hz = uint(uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))) >> uint(uint(16)))
    goto label 734
    label 734:
    goto label 292
    label 50837:
    goto label 52375
    label 52375:
    if (tr_13 == null) {
        goto label 738
    } else {
        goto label 740
    }
    label 738:
    if (uint64(depth) == uint64(0)) {
        goto label 744
    } else {
        goto label 746
    }
    label 744:
    goto label 292
    label 746:
    MP4D_close(mp4)
    goto label 750
    label 750:
    return 0
    label 740:
    goto label 742
    label 742:
    var c2da_fresh1027 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(6) * uint64(1) + uint64(2) + uint64(2) + uint64(2) + uint64(4) * uint64(3))) {
        c2da_fresh1027 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1027 = uint64(uint64(uint64(uint64(6) * uint64(1) + uint64(2) + uint64(2) + uint64(2) + uint64(4) * uint64(3))))
    }
    var t_10 : uint64 = uint64(uint64(uint64(c2da_fresh1027)))
    goto label 752
    label 752:
    my_fseek(mp4, uint64(t_10), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 754
    label 754:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_10))))
    goto label 756
    label 756:
    unsafe(*tr_13).SampleDescription.video.width = uint(read_payload(mp4, uint(uint(uint(2))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 758
    label 758:
    unsafe(*tr_13).SampleDescription.video.height = uint(read_payload(mp4, uint(uint(uint(2))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 760
    label 760:
    var c2da_fresh1028 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(4) + uint64(4) + uint64(4) + uint64(2) + uint64(32) + uint64(2) + uint64(2))) {
        c2da_fresh1028 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1028 = uint64(uint64(uint64(uint64(4) + uint64(4) + uint64(4) + uint64(2) + uint64(32) + uint64(2) + uint64(2))))
    }
    var t_11 : uint64 = uint64(uint64(uint64(c2da_fresh1028)))
    goto label 762
    label 762:
    my_fseek(mp4, uint64(t_11), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 764
    label 764:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_11))))
    goto label 766
    label 766:
    goto label 292
    label 50853:
    unsafe(*tr_13).object_type_indication = uint(uint(uint(33)))
    goto label 770
    label 770:
    unsafe(*tr_13).dsi = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(box_bytes)))))))))
    goto label 772
    label 772:
    unsafe(*tr_13).dsi_bytes = uint(uint(box_bytes))
    goto label 774
    label 774:
    var spspps : int = int(0)
    goto label 776
    label 776:
    var p_9 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_13).dsi)))))))))
    goto label 778
    label 778:
    var configurationVersion : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 780
    label 780:
    var AVCProfileIndication : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 782
    label 782:
    var profile_compatibility : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 784
    label 784:
    var AVCLevelIndication : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 786
    label 786:
    var lengthSizeMinusOne : uint = uint(uint(uint(uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))) & uint(uint(3)))))
    goto label 788
    label 788:
    goto label 790
    label 790:
    goto label 792
    label 792:
    goto label 794
    label 794:
    goto label 796
    label 796:
    goto label 798
    label 798:
    goto label 806
    label 806:
    spspps = 0
    goto label 808
    label 808:
    goto label 800
    label 800:
    if (int(spspps) < 2) {
        goto label 802
    } else {
        goto label 804
    }
    label 802:
    var numOfSequenceParameterSets_0 : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 810
    label 810:
    if (uint64(spspps) == uint64(0)) {
        goto label 812
    } else {
        goto label 814
    }
    label 812:
    numOfSequenceParameterSets_0 = uint(uint(uint(uint(numOfSequenceParameterSets_0) & uint(uint(31)))))
    goto label 818
    label 818:
    goto label 816
    label 814:
    goto label 816
    label 816:
    var c2da_fresh1029 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_9))))))
    p_9 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_9))), 1, 1)))))))))))
    *c2da_fresh1029 = uint8(uint8(numOfSequenceParameterSets_0))
    goto label 820
    label 820:
    goto label 828
    label 828:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 830
    label 830:
    goto label 822
    label 822:
    if (uint(i_9) < uint(numOfSequenceParameterSets_0)) {
        goto label 824
    } else {
        goto label 826
    }
    label 824:
    var k_0 : uint = uint(uint(uint(0)))
    goto label 832
    label 832:
    var sequenceParameterSetLength : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(2))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 834
    label 834:
    var c2da_fresh1030 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_9))))))
    p_9 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_9))), 1, 1)))))))))))
    *c2da_fresh1030 = uint8(uint8(uint8(uint(uint(sequenceParameterSetLength)) >> uint(uint(8)))))
    goto label 836
    label 836:
    var c2da_fresh1031 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_9))))))
    p_9 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_9))), 1, 1)))))))))))
    *c2da_fresh1031 = uint8(uint8(sequenceParameterSetLength))
    goto label 838
    label 838:
    goto label 846
    label 846:
    k_0 = uint(uint(uint(uint(uint(0)))))
    goto label 848
    label 848:
    goto label 840
    label 840:
    if (uint(k_0) < uint(sequenceParameterSetLength)) {
        goto label 842
    } else {
        goto label 844
    }
    label 842:
    var c2da_fresh1032 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_9))))))
    p_9 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_9))), 1, 1)))))))))))
    *c2da_fresh1032 = uint8(uint8(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))
    goto label 850
    label 850:
    var c2da_fresh1033 : uint = uint(uint(k_0))
    k_0 = uint(uint(uint(uint(k_0) + uint(1))))
    goto label 840
    label 844:
    var c2da_fresh1034 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 822
    label 826:
    var c2da_fresh1035 : int = spspps
    spspps = int(spspps) + 1
    goto label 800
    label 804:
    goto label 292
    label 50863:
    var flags_0 : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(3))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 854
    label 854:
    if (uint64(uint(flags_0) & uint(uint(128))) != uint64(0)) {
        goto label 856
    } else {
        goto label 858
    }
    label 856:
    var c2da_fresh1036 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(2))) {
        c2da_fresh1036 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1036 = uint64(uint64(uint64(uint64(2))))
    }
    var t_12 : uint64 = uint64(uint64(uint64(c2da_fresh1036)))
    goto label 862
    label 862:
    my_fseek(mp4, uint64(t_12), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 864
    label 864:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_12))))
    goto label 866
    label 866:
    goto label 860
    label 858:
    goto label 860
    label 860:
    if (uint64(uint(flags_0) & uint(uint(64))) != uint64(0)) {
        goto label 868
    } else {
        goto label 870
    }
    label 868:
    var bytecount : uint = uint(uint(uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))))
    goto label 874
    label 874:
    var c2da_fresh1037 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(bytecount)) {
        c2da_fresh1037 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1037 = uint64(uint64(uint64(bytecount)))
    }
    var t_13 : uint64 = uint64(uint64(uint64(c2da_fresh1037)))
    goto label 876
    label 876:
    my_fseek(mp4, uint64(t_13), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 878
    label 878:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_13))))
    goto label 880
    label 880:
    goto label 872
    label 870:
    goto label 872
    label 872:
    if (uint64(uint(flags_0) & uint(uint(32))) != uint64(0)) {
        goto label 882
    } else {
        goto label 884
    }
    label 882:
    var c2da_fresh1038 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(2))) {
        c2da_fresh1038 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1038 = uint64(uint64(uint64(uint64(2))))
    }
    var t_14 : uint64 = uint64(uint64(uint64(c2da_fresh1038)))
    goto label 888
    label 888:
    my_fseek(mp4, uint64(t_14), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 890
    label 890:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_14))))
    goto label 892
    label 892:
    goto label 886
    label 884:
    goto label 886
    label 886:
    goto label 292
    label 50865:
    goto label 896
    label 896:
    unsafe(*tr_13).object_type_indication = uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 898
    label 898:
    unsafe(*tr_13).stream_type = uint(uint(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))) >> uint(uint(2)))
    goto label 900
    label 900:
    var c2da_fresh1039 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(3) + uint64(4))) {
        c2da_fresh1039 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1039 = uint64(uint64(uint64(uint64(3) + uint64(4))))
    }
    var t_15 : uint64 = uint64(uint64(uint64(c2da_fresh1039)))
    goto label 902
    label 902:
    my_fseek(mp4, uint64(t_15), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 904
    label 904:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_15))))
    goto label 906
    label 906:
    unsafe(*tr_13).avg_bitrate_bps = uint(read_payload(mp4, uint(uint(uint(4))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag)))))))
    goto label 908
    label 908:
    goto label 292
    label 50879:
    goto label 912
    label 912:
    if (unsafe(*tr_13).dsi == null && uint64(payload_bytes) != uint64(0)) {
        goto label 914
    } else {
        goto label 916
    }
    label 914:
    unsafe(*tr_13).dsi = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(uint64(int(payload_bytes))))))))))))
    goto label 920
    label 920:
    if (unsafe(*tr_13).dsi == null) {
        goto label 922
    } else {
        goto label 924
    }
    label 922:
    if (uint64(depth) == uint64(0)) {
        goto label 928
    } else {
        goto label 930
    }
    label 928:
    goto label 292
    label 930:
    MP4D_close(mp4)
    goto label 934
    label 934:
    return 0
    label 924:
    goto label 926
    label 926:
    goto label 942
    label 942:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 944
    label 944:
    goto label 936
    label 936:
    if (uint64(i_9) < uint64(payload_bytes)) {
        goto label 938
    } else {
        goto label 940
    }
    label 938:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_13).dsi)))[uint(i_9)])) = uint8(uint8(minimp4_read(mp4, 1, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))
    goto label 946
    label 946:
    var c2da_fresh1040 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 936
    label 940:
    unsafe(*tr_13).dsi_bytes = uint(i_9)
    goto label 948
    label 948:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(i_9))))
    goto label 950
    label 950:
    goto label 292
    label 916:
    goto label 918
    label 918:
    goto label 50883
    label 50883:
    goto label 292
    label 292:
    if (ptag != null && *ptag == null && uint64(payload_bytes) > uint64(uint64(16))) {
        goto label 952
    } else {
        goto label 954
    }
    label 952:
    var c2da_fresh1041 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(uint64(4) + uint64(4) + uint64(4) + uint64(4))) {
        c2da_fresh1041 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1041 = uint64(uint64(uint64(uint64(4) + uint64(4) + uint64(4) + uint64(4))))
    }
    var t_16 : uint64 = uint64(uint64(uint64(c2da_fresh1041)))
    goto label 958
    label 958:
    my_fseek(mp4, uint64(t_16), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 960
    label 960:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_16))))
    goto label 962
    label 962:
    *ptag = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(uint64(uint(payload_bytes)) + uint64(uint(uint(1)))))))))))))
    goto label 964
    label 964:
    if (*ptag == null) {
        goto label 966
    } else {
        goto label 968
    }
    label 966:
    if (uint64(depth) == uint64(0)) {
        goto label 972
    } else {
        goto label 974
    }
    label 972:
    goto label 36
    label 974:
    MP4D_close(mp4)
    goto label 978
    label 978:
    return 0
    label 968:
    goto label 970
    label 970:
    goto label 986
    label 986:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 988
    label 988:
    goto label 980
    label 980:
    if (uint64(uint64(payload_bytes)) != uint64(0)) {
        goto label 982
    } else {
        goto label 984
    }
    label 982:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*ptag)))[uint(i_9)])) = uint8(uint8(read_payload(mp4, uint(uint(uint(1))), unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(payload_bytes))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))))
    goto label 990
    label 990:
    var c2da_fresh1042 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 980
    label 984:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*ptag)))[uint(i_9)])) = uint8(uint8(uint8(0)))
    goto label 992
    label 992:
    goto label 956
    label 954:
    goto label 956
    label 956:
    if (uint(box_name) == uint(BOX_trak)) {
        goto label 994
    } else {
        goto label 996
    }
    label 994:
    var mem_1 : uint64 = uint64(uint64(unsafe(realloc(intptr(unsafe(*mp4).track), uint64(uint64(uint64(uint(unsafe(*mp4).track_count)) + uint64(uint(uint(1)))) * uint64(0x78))))))
    goto label 1000
    label 1000:
    if (uint64(mem_1) == uint64(0)) {
        goto label 1002
    } else {
        goto label 1004
    }
    label 1002:
    if (uint64(depth) == uint64(0)) {
        goto label 1008
    } else {
        goto label 1010
    }
    label 1008:
    goto label 36
    label 1010:
    MP4D_close(mp4)
    goto label 1014
    label 1014:
    return 0
    label 1004:
    goto label 1006
    label 1006:
    unsafe(*mp4).track = unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mem_1))))))
    goto label 1016
    label 1016:
    var c2da_fresh1043 : uint = uint(uint(unsafe(*mp4).track_count))
    unsafe(*mp4).track_count = uint(uint(unsafe(*mp4).track_count) + uint(1))
    tr_13 = unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*mp4).track))), uint(c2da_fresh1043), 120))))))))))))))
    goto label 1018
    label 1018:
    unsafe(*tr_13) = minimp4::MP4D_track_t()
    goto label 1020
    label 1020:
    goto label 998
    label 996:
    if (uint(box_name) == uint(BOX_meta)) {
        goto label 1022
    } else {
        goto label 1024
    }
    label 1022:
    tr_13 = null
    goto label 1028
    label 1028:
    goto label 1026
    label 1024:
    goto label 1026
    label 1026:
    goto label 998
    label 998:
    goto label 1036
    label 1036:
    i_9 = uint(uint(uint(uint(uint(0)))))
    goto label 1038
    label 1038:
    goto label 1030
    label 1030:
    if (uint64(i_9) < uint64(0xa0) / uint64(0x8)) {
        goto label 1032
    } else {
        goto label 1034
    }
    label 1032:
    if (uint(box_name) == uint(unsafe(g_envelope_box[uint(i_9)]).name)) {
        goto label 1040
    } else {
        goto label 1042
    }
    label 1040:
    depth = int(depth) + 1
    goto label 1052
    label 1052:
    if (int(depth) >= 64) {
        goto label 1046
    } else {
        goto label 1048
    }
    label 1046:
    if (uint64(depth) == uint64(0)) {
        goto label 1054
    } else {
        goto label 1056
    }
    label 1054:
    goto label 1034
    label 1056:
    MP4D_close(mp4)
    goto label 1060
    label 1060:
    return 0
    label 1048:
    goto label 1050
    label 1050:
    unsafe(stack_1[uint(depth)]).bytes = uint64(payload_bytes)
    goto label 1062
    label 1062:
    unsafe(stack_1[uint(depth)]).format = unsafe(g_envelope_box[uint(i_9)]).type_0
    goto label 1064
    label 1064:
    goto label 1034
    label 1042:
    goto label 1044
    label 1044:
    var c2da_fresh1044 : uint = uint(uint(i_9))
    i_9 = uint(uint(uint(uint(i_9) + uint(1))))
    goto label 1030
    label 1034:
    if (uint64(i_9) == uint64(0xa0) / uint64(0x8)) {
        goto label 1066
    } else {
        goto label 1068
    }
    label 1066:
    if (uint64(payload_bytes) > uint64(file_size)) {
        goto label 1072
    } else {
        goto label 1074
    }
    label 1072:
    eof_flag = 1
    goto label 1078
    label 1078:
    goto label 1076
    label 1074:
    var c2da_fresh1045 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(payload_bytes) < uint64(payload_bytes)) {
        c2da_fresh1045 = uint64(uint64(payload_bytes))
    } else {
        c2da_fresh1045 = uint64(uint64(payload_bytes))
    }
    var t_17 : uint64 = uint64(uint64(uint64(c2da_fresh1045)))
    goto label 1080
    label 1080:
    my_fseek(mp4, uint64(t_17), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag))))))
    goto label 1082
    label 1082:
    payload_bytes = uint64(uint64(uint64(uint64(payload_bytes) - uint64(t_17))))
    goto label 1084
    label 1084:
    goto label 1076
    label 1076:
    goto label 1070
    label 1068:
    goto label 1070
    label 1070:
    goto label 1086
    label 1086:
    if (int(depth) > 0 && uint64(unsafe(stack_1[uint(depth)]).bytes) == uint64(0)) {
        goto label 1088
    } else {
        goto label 1090
    }
    label 1088:
    var c2da_fresh1046 : int = depth
    depth = int(depth) - 1
    goto label 1092
    label 1092:
    goto label 1086
    label 1090:
    goto label 34
    label 34:
    if (uint64(eof_flag) == uint64(0)) {
        goto label 32
    } else {
        goto label 36
    }
    label 36:
    if (uint64(unsafe(*mp4).track_count) == uint64(0)) {
        goto label 1094
    } else {
        goto label 1096
    }
    label 1094:
    MP4D_close(mp4)
    goto label 1100
    label 1100:
    return 0
    label 1096:
    goto label 1098
    label 1098:
    return 1
    return int(0)
}
[export]
def MP4E_set_text_comment(var mux_13 : minimp4::MP4E_mux_tag?; var comment : int8 const?) : int {
    if (mux_13 == null || comment == null) {
        return -1
    }
    if (unsafe(*mux_13).text_comment != null) {
        unsafe(c2da_free(intptr(unsafe(*mux_13).text_comment)))
    }
    unsafe(*mux_13).text_comment = unsafe(unsafe(reinterpret<int8?>(unsafe(unsafe(reinterpret<int8?>(c2da_strdup(unsafe(unsafe(reinterpret<void?>(intptr(comment)))))))))))
    if (unsafe(*mux_13).text_comment == null) {
        return -2
    }
    return 0
    return int(0)
}
[export]
def add_sample_descriptor(var mux_2 : minimp4::MP4E_mux_tag?; var tr_2 : minimp4::track_t?; var data_bytes_0 : int; var duration_0 : int; var kind_0 : int) : int {
    var smp : minimp4::sample_t = minimp4::sample_t()
    smp.size = uint64(uint64(data_bytes_0))
    smp.offset = uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_2).write_pos))))
    var c2da_fresh6 : uint = uint(uint(uint(0)))
    if (uint64(duration_0) != uint64(0)) {
        c2da_fresh6 = uint(uint(uint(duration_0)))
    } else {
        c2da_fresh6 = uint(uint(unsafe(*tr_2).info.default_duration))
    }
    smp.duration = uint(c2da_fresh6)
    smp.flag_random_access = uint(uint(uint(c2da_bool_to_uint(int(kind_0) == 1))))
    return int(c2da_bool_to_int(unsafe(uint64(0) != intptr(unsafe(reinterpret<uint8?>(minimp4_vector_put(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_2).smpl))))), intptr(unsafe(reinterpret<minimp4::sample_t?>(unsafe(addr(smp))))), int(int(0x18)))))))))
    return int(0)
}
[export]
def MP4E_set_sps(var mux_8 : minimp4::MP4E_mux_tag?; var track_id_0 : int; var sps : uint64; var bytes_4 : int) : int {
    var tr_11 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_8).tracks.data)))))), int(track_id_0), 112))))))))))))))
    var c2da_fresh980 : int = int(0)
    if (uint64(append_mem(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_11).vsps))))), sps, bytes_4)) != uint64(0)) {
        c2da_fresh980 = 0
    } else {
        c2da_fresh980 = -2
    }
    return c2da_fresh980
    return int(0)
}
[export]
def MP4D_close(var mp4_0 : minimp4::MP4D_demux_tag?) {
    while (uint64(unsafe(*mp4_0).track_count) != uint64(0)) {
        unsafe(*mp4_0).track_count = unsafe(*mp4_0).track_count - uint(1)
        var tr_14 : minimp4::MP4D_track_t? = unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*mp4_0).track))), uint(unsafe(*mp4_0).track_count), 120))))))))))))))
        if (unsafe(*tr_14).entry_size != null) {
            unsafe(c2da_free(intptr(unsafe(*tr_14).entry_size)))
            unsafe(*tr_14).entry_size = null
        }
        if (unsafe(*tr_14).timestamp != null) {
            unsafe(c2da_free(intptr(unsafe(*tr_14).timestamp)))
            unsafe(*tr_14).timestamp = null
        }
        if (unsafe(*tr_14).duration != null) {
            unsafe(c2da_free(intptr(unsafe(*tr_14).duration)))
            unsafe(*tr_14).duration = null
        }
        if (unsafe(*tr_14).sample_to_chunk != null) {
            unsafe(c2da_free(intptr(unsafe(*tr_14).sample_to_chunk)))
            unsafe(*tr_14).sample_to_chunk = null
        }
        if (unsafe(*tr_14).chunk_offset != null) {
            unsafe(c2da_free(intptr(unsafe(*tr_14).chunk_offset)))
            unsafe(*tr_14).chunk_offset = null
        }
        if (unsafe(*tr_14).dsi != null) {
            unsafe(c2da_free(intptr(unsafe(*tr_14).dsi)))
            unsafe(*tr_14).dsi = null
        }
    }
    if (unsafe(*mp4_0).track != null) {
        unsafe(c2da_free(intptr(unsafe(*mp4_0).track)))
        unsafe(*mp4_0).track = null
    }
    if (unsafe(*mp4_0).tag.title != null) {
        unsafe(c2da_free(intptr(unsafe(*mp4_0).tag.title)))
        unsafe(*mp4_0).tag.title = null
    }
    if (unsafe(*mp4_0).tag.artist != null) {
        unsafe(c2da_free(intptr(unsafe(*mp4_0).tag.artist)))
        unsafe(*mp4_0).tag.artist = null
    }
    if (unsafe(*mp4_0).tag.album != null) {
        unsafe(c2da_free(intptr(unsafe(*mp4_0).tag.album)))
        unsafe(*mp4_0).tag.album = null
    }
    if (unsafe(*mp4_0).tag.year != null) {
        unsafe(c2da_free(intptr(unsafe(*mp4_0).tag.year)))
        unsafe(*mp4_0).tag.year = null
    }
    if (unsafe(*mp4_0).tag.comment != null) {
        unsafe(c2da_free(intptr(unsafe(*mp4_0).tag.comment)))
        unsafe(*mp4_0).tag.comment = null
    }
    if (unsafe(*mp4_0).tag.genre != null) {
        unsafe(c2da_free(intptr(unsafe(*mp4_0).tag.genre)))
        unsafe(*mp4_0).tag.genre = null
    }
}
[export]
def get_duration(var tr_9 : minimp4::track_t const?) : uint {
    var i_1 : uint = uint(uint(uint(0)))
    var sum_duration : uint = uint(uint(uint(uint(uint(0)))))
    var s : minimp4::sample_t const? = unsafe(unsafe(reinterpret<minimp4::sample_t const?>(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(unsafe(*tr_9).smpl.data))))))))))))
    i_1 = uint(uint(uint(uint(uint(0)))))
    while (uint64(i_1) < unsafe(unsafe(reinterpret<uint64>(unsafe(*tr_9).smpl.bytes))) / uint64(0x18)) {
        sum_duration = uint(uint(uint(uint(sum_duration) + uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(s)))[uint(i_1)])).duration))))
        var c2da_fresh973 : uint = uint(uint(i_1))
        i_1 = uint(uint(uint(uint(i_1) + uint(1))))
    }
    return sum_duration
    return uint(0)
}
[export]
def transcode_nalu(var h_6 : minimp4::h264_sps_id_patcher_t?; var src : uint8 const?; var nalu_bytes : int; var dst : uint8?) : int {
    label 0:
    var old_id : int = int(0)
    goto label 2
    label 2:
    var bst : minimp4::bit_reader_t [1] = fixed_array<minimp4::bit_reader_t>(minimp4::bit_reader_t())
    goto label 4
    label 4:
    var bdt : minimp4::bs_t [1] = fixed_array<minimp4::bs_t>(minimp4::bs_t())
    goto label 6
    label 6:
    var bs_6 : minimp4::bit_reader_t [1] = fixed_array<minimp4::bit_reader_t>(minimp4::bit_reader_t())
    goto label 8
    label 8:
    var bd : minimp4::bs_t [1] = fixed_array<minimp4::bs_t>(minimp4::bs_t())
    goto label 10
    label 10:
    var payload_type_0 : int = int(int(int(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(src)))[0]))) & 31)))
    goto label 12
    label 12:
    *dst = uint8(*src)
    goto label 14
    label 14:
    h264e_bs_init_bits(unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bd[0]))))), intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(dst))), 1, 1))))))
    goto label 16
    label 16:
    init_bits(unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bs_6[0]))))), intptr(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(src))), 1, 1))))), uint(uint(uint(int(nalu_bytes)) - uint(1))))
    goto label 18
    label 18:
    h264e_bs_init_bits(unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bdt[0]))))), intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(dst))), 1, 1))))))
    goto label 20
    label 20:
    init_bits(unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bst[0]))))), intptr(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(src))), 1, 1))))), uint(uint(uint(int(nalu_bytes)) - uint(1))))
    goto label 22
    label 22:
    if (payload_type_0 == 7) {
        goto label 44631
    }
    if (payload_type_0 == 8) {
        goto label 44635
    }
    if (payload_type_0 == 1) {
        goto label 44639
    }
    if (payload_type_0 == 2) {
        goto label 44679
    }
    if (payload_type_0 == 5) {
        goto label 44683
    }
    goto label 44643
    label 44631:
    var cb_1 : int = change_sps_id(unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bst[0]))))), unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bdt[0]))))), 0, unsafe(unsafe(reinterpret<int?>(unsafe(addr(old_id))))))
    goto label 28
    label 28:
    var id : int = find_mem_cache(unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(unsafe(*h_6).sps_cache[0]))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(unsafe(*h_6).sps_bytes[0]))))), 32, intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(dst))), 1, 1))))), cb_1)
    goto label 30
    label 30:
    if (int(id) == -1) {
        goto label 32
    } else {
        goto label 34
    }
    label 32:
    return 0
    label 34:
    goto label 36
    label 36:
    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(unsafe(addr(unsafe(*h_6).map_sps[0])))))[uint(old_id)])) = id
    goto label 38
    label 38:
    change_sps_id(unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bs_6[0]))))), unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bd[0]))))), id, unsafe(unsafe(reinterpret<int?>(unsafe(addr(old_id))))))
    goto label 40
    label 40:
    goto label 24
    label 44635:
    var cb_2 : int = patch_pps(h_6, unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bst[0]))))), unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bdt[0]))))), 0, unsafe(unsafe(reinterpret<int?>(unsafe(addr(old_id))))))
    goto label 44
    label 44:
    var id_0 : int = find_mem_cache(unsafe(unsafe(reinterpret<uint64?>(unsafe(addr(unsafe(*h_6).pps_cache[0]))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(unsafe(*h_6).pps_bytes[0]))))), 256, intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(dst))), 1, 1))))), cb_2)
    goto label 46
    label 46:
    if (int(id_0) == -1) {
        goto label 48
    } else {
        goto label 50
    }
    label 48:
    return 0
    label 50:
    goto label 52
    label 52:
    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(unsafe(addr(unsafe(*h_6).map_pps[0])))))[uint(old_id)])) = id_0
    goto label 54
    label 54:
    patch_pps(h_6, unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bs_6[0]))))), unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bd[0]))))), id_0, unsafe(unsafe(reinterpret<int?>(unsafe(addr(old_id))))))
    goto label 56
    label 56:
    goto label 24
    label 44639:
    goto label 44679
    label 44679:
    goto label 44683
    label 44683:
    patch_slice_header(h_6, unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bs_6[0]))))), unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bd[0]))))))
    goto label 60
    label 60:
    goto label 24
    label 44643:
    unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(dst)))), unsafe(unsafe(reinterpret<void?>(intptr(src)))), int(uint64(nalu_bytes))))
    goto label 64
    label 64:
    return nalu_bytes
    label 24:
    nalu_bytes = int(int(int(int(int(uint(uint(1))) + int(uint(uint(int(uint(h264e_bs_byte_align(unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bd[0]))))))))) / uint(int(uint(uint(8))))))))))
    goto label 66
    label 66:
    h264e_bs_flush(unsafe(unsafe(reinterpret<minimp4::bs_t?>(unsafe(addr(bd[0]))))))
    goto label 68
    label 68:
    return nalu_bytes
    return int(0)
}
[export]
def c2da_probe_minimp4_read4(var read_callback_0 : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token_1 : uint64; var file_size_0 : int64) : int {
    var mp4_9 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var eof_flag_3 : int = 0
    mp4_9 = minimp4::MP4D_demux_tag()
    mp4_9.read_callback = read_callback_0
    mp4_9.token = token_1
    mp4_9.read_size = int64(file_size_0)
    return int(minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_9))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_3)))))))
    return int(0)
}
[export]
def h264e_bs_get_pos_bits(var bs_9 : minimp4::bs_t const?) : uint {
    var pos_bits_0 : uint = uint(uint(uint(uint(uint(int64(unsafe(int64(uint(int64(intptr(unsafe(*bs_9).buf)))) - int64(uint(int64(intptr(unsafe(*bs_9).origin))))))) * uint(int64(int64(32)))))))
    pos_bits_0 = uint(uint(uint(uint(pos_bits_0) + uint(uint(32) - uint(int(unsafe(*bs_9).shift))))))
    return pos_bits_0
    return uint(0)
}
[export]
def c2da_probe_minimp4_first_box_read_pos(var read_callback_2 : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token_3 : uint64; var file_size_2 : int64) : int {
    var mp4_11 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var eof_flag_5 : int = 0
    mp4_11 = minimp4::MP4D_demux_tag()
    mp4_11.read_callback = read_callback_2
    mp4_11.token = token_3
    mp4_11.read_size = int64(file_size_2)
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_5))))))
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_5))))))
    return int(mp4_11.read_pos)
    return int(0)
}
[export]
def MP4D_read_sps(var mp4_6 : minimp4::MP4D_demux_tag const?; var ntrack_0 : uint; var nsps : int; var sps_bytes : int?) : uint64 {
    return unsafe(unsafe(reinterpret<uint64>(MP4D_read_spspps(mp4_6, uint(ntrack_0), 0, nsps, sps_bytes))))
    return unsafe(unsafe(reinterpret<uint64>(null)))
}
[export]
def next_dsi(var p_12 : uint8 const?; var end : uint8 const?; var bytes_10 : int?) : uint8 const? {
    if (unsafe(intptr(p_12) < intptr(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(end))), 2, 1))))))) {
        *bytes_10 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_12)))[0]))) * 256 + int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_12)))[1])))
        return unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_12))), 2, 1))))))))
    } else {
        return null
    }
    return unsafe(unsafe(reinterpret<uint8 const?>(null)))
}
[export]
def MP4D_frame_offset(var mp4_5 : minimp4::MP4D_demux_tag const?; var ntrack : uint; var nsample : uint; var frame_bytes : uint?; var timestamp : uint?; var duration_4 : uint?) : uint64 {
    var tr_15 : minimp4::MP4D_track_t? = unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*mp4_5).track))), uint(ntrack), 120))))))))))))))
    var ns : uint = uint(uint(uint(0)))
    var nchunk : int = sample_to_chunk(tr_15, uint(nsample), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(ns))))))
    var offset : uint64 = uint64(uint64(uint64(0)))
    if (int(nchunk) < 0) {
        *frame_bytes = uint(uint(uint(0)))
        return uint64(uint64(0))
    }
    offset = uint64(uint64(uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint64?>(unsafe(*tr_15).chunk_offset)))[uint(nchunk)])))))
    while (uint(ns) < uint(nsample)) {
        offset = uint64(uint64(uint64(uint64(offset) + uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_15).entry_size)))[uint(ns)]))))))
        var c2da_fresh1048 : uint = uint(uint(ns))
        ns = uint(uint(uint(uint(ns) + uint(1))))
    }
    *frame_bytes = uint(unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_15).entry_size)))[uint(ns)])))
    if (timestamp != null) {
        *timestamp = uint(unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_15).timestamp)))[uint(ns)])))
    }
    if (duration_4 != null) {
        *duration_4 = uint(unsafe(unsafe(unsafe(unsafe(reinterpret<uint?>(unsafe(*tr_15).duration)))[uint(ns)])))
    }
    return offset
    return uint64(0)
}
[export]
def read_payload(var mp4_2 : minimp4::MP4D_demux_tag?; var nb : uint; var payload_bytes_0 : uint64?; var eof_flag_1 : int?) : uint {
    if (uint64(*payload_bytes_0) < uint64(nb)) {
        *eof_flag_1 = 1
        nb = uint(uint(uint(uint(uint(int(*payload_bytes_0))))))
    }
    *payload_bytes_0 = uint64(uint64(*payload_bytes_0) - uint64(nb))
    return minimp4_read(mp4_2, int(nb), eof_flag_1)
    return uint(0)
}
[export]
def c2da_probe_minimp4_second_box_read_pos(var read_callback_5 : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token_6 : uint64; var file_size_5 : int64) : int {
    var mp4_14 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var eof_flag_8 : int = 0
    var box_bytes_1 : uint64 = uint64(uint64(uint64(0)))
    var payload_bytes_2 : uint64 = uint64(uint64(uint64(0)))
    mp4_14 = minimp4::MP4D_demux_tag()
    mp4_14.read_callback = read_callback_5
    mp4_14.token = token_6
    mp4_14.read_size = int64(file_size_5)
    box_bytes_1 = uint64(uint64(uint64(uint64(minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_8))))))))))
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_8))))))
    payload_bytes_2 = uint64(uint64(uint64(uint64(box_bytes_1) - uint64(uint64(8)))))
    my_fseek(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))), uint64(payload_bytes_2), unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_8))))))
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_8))))))
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_8))))))
    return int(mp4_14.read_pos)
    return int(0)
}
[export]
def init_bits(var bs_4 : minimp4::bit_reader_t?; var data_0 : uint64; var data_bytes_2 : uint) {
    unsafe(*bs_4).origin = unsafe(unsafe(reinterpret<uint16 const?>(unsafe(unsafe(reinterpret<uint16 const?>(data_0))))))
    unsafe(*bs_4).origin_bytes = uint(data_bytes_2)
    set_pos_bits(bs_4, uint(uint(uint(0))))
}
[export]
def minimp4_vector_put(var h_5 : minimp4::minimp4_vector_t?; var buf : uint64; var bytes_1 : int) : uint8? {
    var tail : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(minimp4_vector_alloc_tail(h_5, bytes_1)))))))))))))
    if (tail != null) {
        unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(tail)))), unsafe(unsafe(reinterpret<void?>(buf))), int(uint64(bytes_1))))
    }
    return unsafe(unsafe(reinterpret<uint8?>(tail)))
    return unsafe(unsafe(reinterpret<uint8?>(null)))
}
[export]
def change_sps_id(var bs_17 : minimp4::bit_reader_t?; var bd_3 : minimp4::bs_t?; var new_id : int; var old_id_1 : int?) : int {
    var bits_0 : uint = uint(uint(uint(0)))
    var sps_id_0 : uint = uint(uint(uint(0)))
    var i_7 : uint = uint(uint(uint(0)))
    var bytes_7 : uint = uint(uint(uint(0)))
    i_7 = uint(uint(uint(uint(uint(0)))))
    while (uint(i_7) < uint(uint(3))) {
        bits_0 = uint(uint(uint(get_bits(bs_17, 8))))
        h264e_bs_put_bits(bd_3, uint(uint(uint(8))), uint(bits_0))
        var c2da_fresh991 : uint = uint(uint(i_7))
        i_7 = uint(uint(uint(uint(i_7) + uint(1))))
    }
    sps_id_0 = uint(uint(uint(uint(ue_bits(bs_17)))))
    *old_id_1 = int(sps_id_0)
    sps_id_0 = uint(uint(uint(uint(new_id))))
    h264e_bs_put_golomb(bd_3, uint(sps_id_0))
    copy_bits(bs_17, bd_3)
    bytes_7 = uint(uint(uint(uint(h264e_bs_byte_align(bd_3)) / uint(uint(8)))))
    h264e_bs_flush(bd_3)
    return int(bytes_7)
    return int(0)
}
[export]
def h264e_bs_init_bits(var bs_18 : minimp4::bs_t?; var data_1 : uint64) {
    unsafe(*bs_18).origin = unsafe(unsafe(reinterpret<uint?>(unsafe(unsafe(reinterpret<uint?>(data_1))))))
    unsafe(*bs_18).buf = unsafe(unsafe(reinterpret<uint?>(unsafe(*bs_18).origin)))
    unsafe(*bs_18).shift = 32
    unsafe(*bs_18).cache = uint(uint(uint(0)))
}
[export]
def copy_bits(var bs_12 : minimp4::bit_reader_t?; var bd_1 : minimp4::bs_t?) {
    var cb_3 : uint = uint(uint(uint(0)))
    var bits : uint = uint(uint(uint(0)))
    var bit_count : int = remaining_bits(bs_12)
    while (int(bit_count) > 7) {
        cb_3 = uint(uint(uint(uint(c2da_min_int(int(int(bit_count) - 7), int(8))))))
        bits = uint(uint(uint(get_bits(bs_12, int(cb_3)))))
        h264e_bs_put_bits(bd_1, uint(cb_3), uint(bits))
        bit_count = int(bit_count) - int(cb_3)
    }
    bits = uint(uint(uint(get_bits(bs_12, bit_count))))
    while (uint64(bit_count) != uint64(0) && uint64(uint(~bits) & uint(uint(1))) != uint64(0)) {
        bits = uint(uint(uint(uint(bits) >> uint(1))))
        var c2da_fresh987 : int = bit_count
        bit_count = int(bit_count) - 1
    }
    if (uint64(bit_count) != uint64(0)) {
        h264e_bs_put_bits(bd_1, uint(uint(bit_count)), uint(bits))
    }
}
[export]
def c2da_probe_minimp4_first_box_name(var read_callback_1 : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token_2 : uint64; var file_size_1 : int64) : int {
    var mp4_10 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var eof_flag_4 : int = 0
    mp4_10 = minimp4::MP4D_demux_tag()
    mp4_10.read_callback = read_callback_1
    mp4_10.token = token_2
    mp4_10.read_size = int64(file_size_1)
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_10))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_4))))))
    return int(minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_10))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_4)))))))
    return int(0)
}
[export]
def MP4E_open(var sequential_mode_flag : int; var enable_fragmentation : int; var token_0 : uint64; var write_callback : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>) : minimp4::MP4E_mux_tag? {
    if (uint64(write_callback(int64(int64(int64(0))), intptr(unsafe(reinterpret<uint8 const?>(unsafe(addr(box_ftyp[0]))))), uint64(0x18), token_0)) != uint64(0)) {
        return null
    }
    var mux_10 : minimp4::MP4E_mux_tag? = unsafe(unsafe(reinterpret<minimp4::MP4E_mux_tag?>(unsafe(unsafe(reinterpret<minimp4::MP4E_mux_tag?>(unsafe(unsafe(reinterpret<minimp4::MP4E_mux_tag?>(unsafe(unsafe(reinterpret<minimp4::MP4E_mux_tag?>(unsafe(c2da_malloc(uint64(0x40)))))))))))))))
    if (mux_10 == null) {
        return unsafe(unsafe(reinterpret<minimp4::MP4E_mux_tag?>(mux_10)))
    }
    unsafe(*mux_10).sequential_mode_flag = int(c2da_bool_to_int(uint64(sequential_mode_flag) != uint64(0) || uint64(enable_fragmentation) != uint64(0)))
    unsafe(*mux_10).enable_fragmentation = enable_fragmentation
    unsafe(*mux_10).fragments_count = 0
    unsafe(*mux_10).write_callback = write_callback
    unsafe(*mux_10).token = token_0
    unsafe(*mux_10).text_comment = null
    unsafe(*mux_10).write_pos = int64(int64(int64(0x18)))
    if (uint64(unsafe(*mux_10).sequential_mode_flag) == uint64(0)) {
        if (uint64(unsafe(*mux_10).write_callback(int64(unsafe(*mux_10).write_pos), intptr(unsafe(reinterpret<uint8 const?>(unsafe(addr(box_ftyp[0]))))), uint64(uint64(uint64(8))), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_10).token))))) != uint64(0)) {
            unsafe(c2da_free(intptr(mux_10)))
            return null
        }
        unsafe(*mux_10).write_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mux_10).write_pos))) + int64(int64(16)))
    }
    minimp4_vector_init(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*mux_10).tracks))))), int(int(uint64(uint64(2))) * int(uint64(0x70))))
    return unsafe(unsafe(reinterpret<minimp4::MP4E_mux_tag?>(mux_10)))
    return unsafe(unsafe(reinterpret<minimp4::MP4E_mux_tag?>(null)))
}
[export]
def remaining_bits(var bs_13 : minimp4::bit_reader_t const?) : int {
    return int(int(uint(unsafe(*bs_13).origin_bytes)) * int(uint(uint(8))) - int(get_pos_bits(bs_13)))
    return int(0)
}
[export]
def mp4_h26x_write_init(var h : minimp4::mp4_h26x_writer_tag?; var mux : minimp4::MP4E_mux_tag?; var width : int; var height : int; var is_hevc : int) : int {
    var tr : minimp4::MP4E_track_t = minimp4::MP4E_track_t()
    tr.track_media_kind = unsafe(reinterpret<minimp4::track_media_kind_t>(e_video))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(tr.language[0])))))[0])) = uint8(uint8(uint8(117)))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(tr.language[0])))))[1])) = uint8(uint8(uint8(110)))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(tr.language[0])))))[2])) = uint8(uint8(uint8(100)))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(tr.language[0])))))[3])) = uint8(uint8(uint8(0)))
    var c2da_fresh0 : int = int(0)
    if (uint64(is_hevc) != uint64(0)) {
        c2da_fresh0 = 35
    } else {
        c2da_fresh0 = 33
    }
    tr.object_type_indication = uint(uint(c2da_fresh0))
    tr.time_scale = uint(uint(uint(90000)))
    tr.default_duration = uint(uint(uint(0)))
    tr.u.v.width = width
    tr.u.v.height = height
    unsafe(*h).mux_track_id = MP4E_add_track(mux, unsafe(reinterpret<minimp4::MP4E_track_t const?>(unsafe(unsafe(reinterpret<minimp4::MP4E_track_t?>(unsafe(addr(tr))))))))
    unsafe(*h).mux = unsafe(unsafe(reinterpret<minimp4::MP4E_mux_tag?>(mux)))
    unsafe(*h).is_hevc = is_hevc
    unsafe(*h).need_vps = is_hevc
    unsafe(*h).need_sps = 1
    unsafe(*h).need_pps = 1
    unsafe(*h).need_idr = 1
    unsafe(*h).sps_patcher = minimp4::h264_sps_id_patcher_t()
    return 0
    return int(0)
}
[export]
def c2da_probe_mp4d_open_read_pos(var read_callback_6 : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token_7 : uint64; var file_size_6 : int64) : int {
    var mp4_15 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    if (uint64(MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))), read_callback_6, token_7, int64(file_size_6))) != uint64(0)) {
        MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))
        return -1
    }
    return int(mp4_15.read_pos)
    return int(0)
}
[export]
def MP4D_read_pps(var mp4_8 : minimp4::MP4D_demux_tag const?; var ntrack_2 : uint; var npps : int; var pps_bytes : int?) : uint64 {
    return unsafe(unsafe(reinterpret<uint64>(MP4D_read_spspps(mp4_8, uint(ntrack_2), 1, npps, pps_bytes))))
    return unsafe(unsafe(reinterpret<uint64>(null)))
}
[export]
def MP4E_close(var mux_11 : minimp4::MP4E_mux_tag?) : int {
    var err_15 : int = 0
    var ntr_1 : uint = uint(uint(uint(0)))
    var ntracks_0 : uint = uint(uint(uint(0)))
    if (mux_11 == null) {
        return -1
    }
    if (uint64(unsafe(*mux_11).enable_fragmentation) == uint64(0)) {
        err_15 = mp4e_flush_index(mux_11)
    }
    if (unsafe(*mux_11).text_comment != null) {
        unsafe(c2da_free(intptr(unsafe(*mux_11).text_comment)))
    }
    ntracks_0 = uint(uint(uint(uint(uint(unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_11).tracks.bytes)))) / uint(uint64(0x70))))))
    ntr_1 = uint(uint(uint(uint(uint(0)))))
    while (uint(ntr_1) < uint(ntracks_0)) {
        var tr_17 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_11).tracks.data)))))), uint(ntr_1), 112))))))))))))))
        minimp4_vector_reset(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_17).vsps))))))
        minimp4_vector_reset(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_17).vpps))))))
        minimp4_vector_reset(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_17).smpl))))))
        minimp4_vector_reset(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_17).pending_sample))))))
        var c2da_fresh1054 : uint = uint(uint(ntr_1))
        ntr_1 = uint(uint(uint(uint(ntr_1) + uint(1))))
    }
    minimp4_vector_reset(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*mux_11).tracks))))))
    unsafe(c2da_free(intptr(mux_11)))
    return err_15
    return int(0)
}
[export]
def mp4e_write_mdat_box(var mux_4 : minimp4::MP4E_mux_tag?; var size : uint) : int {
    var base_0 : uint8 [8] = fixed_array<uint8>(uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0))
    var p_3 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(base_0[0]))))))))))))))
    var c2da_fresh15 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_3))))))
    p_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_3))), 1, 1)))))))))))
    *c2da_fresh15 = uint8(uint8(uint8(uint(uint(size)) >> uint(uint(uint(8) * uint(3))))))
    var c2da_fresh16 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_3))))))
    p_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_3))), 1, 1)))))))))))
    *c2da_fresh16 = uint8(uint8(uint8(uint(uint(size)) >> uint(uint(uint(8) * uint(2))))))
    var c2da_fresh17 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_3))))))
    p_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_3))), 1, 1)))))))))))
    *c2da_fresh17 = uint8(uint8(uint8(uint(uint(size)) >> uint(uint(uint(8) * uint(1))))))
    var c2da_fresh18 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_3))))))
    p_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_3))), 1, 1)))))))))))
    *c2da_fresh18 = uint8(uint8(uint8(uint(uint(size)) >> uint(uint(uint(8) * uint(0))))))
    var c2da_fresh19 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_3))))))
    p_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_3))), 1, 1)))))))))))
    *c2da_fresh19 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(3))))
    var c2da_fresh20 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_3))))))
    p_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_3))), 1, 1)))))))))))
    *c2da_fresh20 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(2))))
    var c2da_fresh21 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_3))))))
    p_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_3))), 1, 1)))))))))))
    *c2da_fresh21 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(1))))
    var c2da_fresh22 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_3))))))
    p_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_3))), 1, 1)))))))))))
    *c2da_fresh22 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(0))))
    var err_9 : int = int(int(int(unsafe(*mux_4).write_callback(int64(unsafe(*mux_4).write_pos), intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_0[0]))))), uint64(uint64(unsafe(uint64(int64(intptr(p_3))) - uint64(int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_0[0])))))))))), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_4).token)))))))
    if (uint64(err_9) != uint64(0)) {
        return err_9
    }
    unsafe(*mux_4).write_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mux_4).write_pos))) + unsafe(int64(intptr(p_3)) - int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base_0[0]))))))))
    return 0
    return int(0)
}
[export]
def od_size_of_size(var size_1 : int) : int {
    var i_3 : int = int(0)
    var size_of_size : int = 1
    i_3 = size_1
    while (int(i_3) > 127) {
        var c2da_fresh975 : int = size_of_size
        size_of_size = int(size_of_size) + 1
        i_3 = int(i_3) - 127
    }
    return size_of_size
    return int(0)
}
[export]
def flush_bits(var bs_3 : minimp4::bit_reader_t?; var n_1 : int) {
    unsafe(*bs_3).cache = uint(uint(unsafe(*bs_3).cache) << uint(n_1))
    unsafe(*bs_3).cache_free_bits = int(unsafe(*bs_3).cache_free_bits) + int(n_1)
    if (int(unsafe(*bs_3).cache_free_bits) >= 0) {
        unsafe(*bs_3).cache = uint(uint(unsafe(*bs_3).cache) | uint(uint(uint(int(int(uint16(uint16(uint(int(*unsafe(*bs_3).buf)) << uint(8)))))) | uint(int(*unsafe(*bs_3).buf)) >> uint(8))) << uint(uint(int(unsafe(*bs_3).cache_free_bits))))
        var c2da_fresh978 : uint16 const? = unsafe(unsafe(reinterpret<uint16 const?>(unsafe(unsafe(reinterpret<uint16 const?>(unsafe(*bs_3).buf))))))
        unsafe(*bs_3).buf = unsafe(unsafe(reinterpret<uint16 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*bs_3).buf))), 1, 2)))))
        unsafe(*bs_3).cache_free_bits = int(unsafe(*bs_3).cache_free_bits) - 16
    }
}
[export]
def skip_spspps(var p_11 : uint8 const?; var nbytes : int; var nskip : int) : int {
    var i_10 : int = int(0)
    var k_1 : int = 0
    i_10 = 0
    while (int(i_10) < int(nskip)) {
        var segmbytes : uint = uint(uint(uint(0)))
        if (int(k_1) > int(nbytes) - 2) {
            return -1
        }
        segmbytes = uint(uint(uint(uint(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_11)))[uint(k_1)])))) * uint(256) + uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_11)))[int(k_1) + 1]))))))))
        k_1 = int(int(k_1) + (int(uint(uint(2))) + int(uint(segmbytes))))
        var c2da_fresh1053 : int = i_10
        i_10 = int(i_10) + 1
    }
    return k_1
    return int(0)
}
[export]
def MP4E_set_dsi(var mux_12 : minimp4::MP4E_mux_tag?; var track_id_2 : int; var dsi : uint64; var bytes_9 : int) : int {
    var tr_18 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_12).tracks.data)))))), int(track_id_2), 112))))))))))))))
    if (uint64(unsafe(*tr_18).vsps.bytes) != uint64(0)) {
        return -4
    }
    var c2da_fresh1055 : int = int(0)
    if (uint64(append_mem(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_18).vsps))))), dsi, bytes_9)) != uint64(0)) {
        c2da_fresh1055 = 0
    } else {
        c2da_fresh1055 = -2
    }
    return c2da_fresh1055
    return int(0)
}
[export]
def find_nal_unit(var h264_data : uint8 const?; var h264_data_bytes_0 : int; var pnal_unit_bytes : int?) : uint8 const? {
    var eof_0 : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(h264_data))), int(h264_data_bytes_0), 1))))))))))))))
    var zcount : int = int(0)
    var start : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(find_start_code(h264_data, h264_data_bytes_0, unsafe(unsafe(reinterpret<int?>(unsafe(addr(zcount))))))))))))))))))
    var stop : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(start)))))))))
    if (start != null) {
        stop = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(find_start_code(start, int(unsafe(int(int64(intptr(eof_0))) - int(int64(intptr(start))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(zcount))))))))))))))))))
        while (unsafe(intptr(stop) > intptr(start)) && uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(stop)))[-1]))) == uint64(0)) {
            var c2da_fresh997 : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(stop))))))
            stop = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stop))), -1, 1)))))))))))
        }
    }
    *pnal_unit_bytes = int(unsafe(int(int64(int64(int(int64(intptr(stop)))) - int64(int(int64(intptr(start)))))) - int(int64(zcount))))
    return unsafe(unsafe(reinterpret<uint8 const?>(start)))
    return unsafe(unsafe(reinterpret<uint8 const?>(null)))
}
[export]
def my_fseek(var mp4_1 : minimp4::MP4D_demux_tag?; var pos_0 : uint64; var eof_flag_0 : int?) {
    unsafe(*mp4_1).read_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mp4_1).read_pos))) + int64(pos_0))
    if (int64(unsafe(*mp4_1).read_pos) >= int64(unsafe(*mp4_1).read_size)) {
        *eof_flag_0 = 1
    }
}
[export]
def c2da_probe_mp4d_open_track_count(var read_callback_7 : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token_8 : uint64; var file_size_7 : int64) : int {
    var mp4_16 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    if (uint64(MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))), read_callback_7, token_8, int64(file_size_7))) == uint64(0)) {
        return -1
    }
    MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))
    return int(mp4_16.track_count)
    return int(0)
}
[export]
def MP4E_add_track(var mux_0 : minimp4::MP4E_mux_tag?; var track_data : minimp4::MP4E_track_t const?) : int {
    var tr_0 : minimp4::track_t? = null
    var ntr : int = int(int(unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_0).tracks.bytes)))) / int(uint64(0x70)))
    if (mux_0 == null || track_data == null) {
        return -1
    }
    tr_0 = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<uint8?>(minimp4_vector_alloc_tail(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*mux_0).tracks))))), int(int(0x70))))))))))))))))))
    if (tr_0 == null) {
        return -2
    }
    unsafe(*tr_0) = minimp4::track_t()
    unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<minimp4::MP4E_track_t?>(unsafe(addr(unsafe(*tr_0).info)))))))), unsafe(unsafe(reinterpret<void?>(intptr(track_data)))), int(0x1c)))
    if (uint64(minimp4_vector_init(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_0).smpl))))), 256)) == uint64(0)) {
        return -2
    }
    minimp4_vector_init(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_0).vsps))))), 0)
    minimp4_vector_init(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_0).vpps))))), 0)
    minimp4_vector_init(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_0).pending_sample))))), 0)
    return ntr
    return int(0)
}
[export]
def mp4e_flush_index(var mux_6 : minimp4::MP4E_mux_tag?) : int {
    label 0:
    var stack_base_0 : uint8? [20] = fixed_array<uint8?>(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null)
    goto label 2
    label 2:
    var stack_0 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(stack_base_0[0]))))))))))))))
    goto label 4
    label 4:
    var base_2 : uint8? = null
    goto label 6
    label 6:
    var p_5 : uint8? = null
    goto label 8
    label 8:
    var ntr_0 : uint = uint(uint(uint(0)))
    goto label 10
    label 10:
    var index_bytes : uint = uint(uint(uint(0)))
    goto label 12
    label 12:
    var ntracks : uint = uint(uint(uint(uint(uint(unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_6).tracks.bytes)))) / uint(uint64(0x70))))))
    goto label 14
    label 14:
    var i_0 : int = int(0)
    goto label 16
    label 16:
    var err_11 : int = int(0)
    goto label 18
    label 18:
    index_bytes = uint(uint(uint(uint(uint(256)))))
    goto label 20
    label 20:
    if (unsafe(*mux_6).text_comment != null) {
        goto label 22
    } else {
        goto label 24
    }
    label 22:
    index_bytes = uint(uint(uint(uint(index_bytes) + (uint(uint64(uint64(128))) + uint(c2da_strlen(unsafe(*mux_6).text_comment))))))
    goto label 28
    label 28:
    goto label 26
    label 24:
    goto label 26
    label 26:
    goto label 36
    label 36:
    ntr_0 = uint(uint(uint(uint(uint(0)))))
    goto label 38
    label 38:
    goto label 30
    label 30:
    if (uint(ntr_0) < uint(ntracks)) {
        goto label 32
    } else {
        goto label 34
    }
    label 32:
    var tr_5 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_6).tracks.data)))))), uint(ntr_0), 112))))))))))))))
    goto label 40
    label 40:
    index_bytes = uint(uint(uint(uint(index_bytes) + uint(uint(512)))))
    goto label 42
    label 42:
    index_bytes = uint(uint(uint(uint(index_bytes) + uint(uint64(uint64(uint(unsafe(unsafe(reinterpret<uint64>(unsafe(*tr_5).smpl.bytes))))) * uint64(uint(uint64(uint64(0x18) + uint64(uint(uint(uint64(uint64(4))))) + uint64(uint(uint(uint64(uint64(4)))))))))) / uint(uint64(0x18)))))
    goto label 44
    label 44:
    index_bytes = uint(uint(uint(uint(index_bytes) + uint(unsafe(*tr_5).vsps.bytes))))
    goto label 46
    label 46:
    index_bytes = uint(uint(uint(uint(index_bytes) + uint(unsafe(*tr_5).vpps.bytes))))
    goto label 48
    label 48:
    var err_12 : int = write_pending_data(mux_6, tr_5)
    goto label 50
    label 50:
    if (uint64(err_12) != uint64(0)) {
        goto label 52
    } else {
        goto label 54
    }
    label 52:
    return err_12
    label 54:
    goto label 56
    label 56:
    var c2da_fresh131 : uint = uint(uint(ntr_0))
    ntr_0 = uint(uint(uint(uint(ntr_0) + uint(1))))
    goto label 30
    label 34:
    base_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(index_bytes))))))))))))))))
    goto label 58
    label 58:
    if (base_2 == null) {
        goto label 60
    } else {
        goto label 62
    }
    label 60:
    return -2
    label 62:
    goto label 64
    label 64:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(base_2)))))))))
    goto label 66
    label 66:
    if (uint64(unsafe(*mux_6).sequential_mode_flag) == uint64(0)) {
        goto label 68
    } else {
        goto label 70
    }
    label 68:
    var size_0 : int64 = int64(int64(int64(int64(int64(unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_6).write_pos)))) - int64(uint64(uint64(0x18)))))))
    goto label 74
    label 74:
    var size_limit : int64 = int64(int64(int64(int64(int64(uint64(uint64(0xfffffffe)))))))
    goto label 76
    label 76:
    if (int64(size_0) > int64(size_limit)) {
        goto label 78
    } else {
        goto label 80
    }
    label 78:
    var c2da_fresh132 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh132 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 84
    label 84:
    var c2da_fresh133 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh133 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 86
    label 86:
    var c2da_fresh134 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh134 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 88
    label 88:
    var c2da_fresh135 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh135 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 90
    label 90:
    var c2da_fresh136 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh136 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(3))))
    goto label 92
    label 92:
    var c2da_fresh137 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh137 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(2))))
    goto label 94
    label 94:
    var c2da_fresh138 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh138 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(1))))
    goto label 96
    label 96:
    var c2da_fresh139 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh139 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(0))))
    goto label 98
    label 98:
    var c2da_fresh140 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh140 = uint8(uint8(uint8(uint(int64(int64(int64(size_0)) >> int64(int64(32)) & int64(int64(0xffffffff)))) >> uint(int64(int64(int64(8) * int64(3)))))))
    goto label 100
    label 100:
    var c2da_fresh141 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh141 = uint8(uint8(uint8(uint(int64(int64(int64(size_0)) >> int64(int64(32)) & int64(int64(0xffffffff)))) >> uint(int64(int64(int64(8) * int64(2)))))))
    goto label 102
    label 102:
    var c2da_fresh142 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh142 = uint8(uint8(uint8(uint(int64(int64(int64(size_0)) >> int64(int64(32)) & int64(int64(0xffffffff)))) >> uint(int64(int64(int64(8) * int64(1)))))))
    goto label 104
    label 104:
    var c2da_fresh143 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh143 = uint8(uint8(uint8(uint(int64(int64(int64(size_0)) >> int64(int64(32)) & int64(int64(0xffffffff)))) >> uint(int64(int64(int64(8) * int64(0)))))))
    goto label 106
    label 106:
    var c2da_fresh144 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh144 = uint8(uint8(uint8(uint(int64(int64(size_0) & int64(int64(0xffffffff)))) >> uint(int64(int64(int64(8) * int64(3)))))))
    goto label 108
    label 108:
    var c2da_fresh145 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh145 = uint8(uint8(uint8(uint(int64(int64(size_0) & int64(int64(0xffffffff)))) >> uint(int64(int64(int64(8) * int64(2)))))))
    goto label 110
    label 110:
    var c2da_fresh146 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh146 = uint8(uint8(uint8(uint(int64(int64(size_0) & int64(int64(0xffffffff)))) >> uint(int64(int64(int64(8) * int64(1)))))))
    goto label 112
    label 112:
    var c2da_fresh147 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh147 = uint8(uint8(uint8(uint(int64(int64(size_0) & int64(int64(0xffffffff)))) >> uint(int64(int64(int64(8) * int64(0)))))))
    goto label 114
    label 114:
    goto label 82
    label 80:
    var c2da_fresh148 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh148 = uint8(uint8(uint8(uint(8) >> uint(8) * uint(3))))
    goto label 116
    label 116:
    var c2da_fresh149 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh149 = uint8(uint8(uint8(uint(8) >> uint(8) * uint(2))))
    goto label 118
    label 118:
    var c2da_fresh150 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh150 = uint8(uint8(uint8(uint(8) >> uint(8) * uint(1))))
    goto label 120
    label 120:
    var c2da_fresh151 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh151 = uint8(uint8(uint8(uint(8) >> uint(8) * uint(0))))
    goto label 122
    label 122:
    var c2da_fresh152 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh152 = uint8(uint8(uint8(uint(int(BOX_free)) >> uint(8) * uint(3))))
    goto label 124
    label 124:
    var c2da_fresh153 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh153 = uint8(uint8(uint8(uint(int(BOX_free)) >> uint(8) * uint(2))))
    goto label 126
    label 126:
    var c2da_fresh154 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh154 = uint8(uint8(uint8(uint(int(BOX_free)) >> uint(8) * uint(1))))
    goto label 128
    label 128:
    var c2da_fresh155 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh155 = uint8(uint8(uint8(uint(int(BOX_free)) >> uint(8) * uint(0))))
    goto label 130
    label 130:
    var c2da_fresh156 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh156 = uint8(uint8(uint8(uint(int64(int64(size_0) - int64(int64(8)))) >> uint(int64(int64(int64(8) * int64(3)))))))
    goto label 132
    label 132:
    var c2da_fresh157 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh157 = uint8(uint8(uint8(uint(int64(int64(size_0) - int64(int64(8)))) >> uint(int64(int64(int64(8) * int64(2)))))))
    goto label 134
    label 134:
    var c2da_fresh158 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh158 = uint8(uint8(uint8(uint(int64(int64(size_0) - int64(int64(8)))) >> uint(int64(int64(int64(8) * int64(1)))))))
    goto label 136
    label 136:
    var c2da_fresh159 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh159 = uint8(uint8(uint8(uint(int64(int64(size_0) - int64(int64(8)))) >> uint(int64(int64(int64(8) * int64(0)))))))
    goto label 138
    label 138:
    var c2da_fresh160 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh160 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(3))))
    goto label 140
    label 140:
    var c2da_fresh161 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh161 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(2))))
    goto label 142
    label 142:
    var c2da_fresh162 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh162 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(1))))
    goto label 144
    label 144:
    var c2da_fresh163 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh163 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(0))))
    goto label 146
    label 146:
    goto label 82
    label 82:
    var err_13 : int = int(int(int(unsafe(*mux_6).write_callback(int64(int64(int64(0x18))), unsafe(unsafe(reinterpret<uint64>(base_2))), uint64(uint64(unsafe(uint64(int64(intptr(p_5))) - uint64(int64(intptr(base_2)))))), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_6).token)))))))
    goto label 148
    label 148:
    if (uint64(err_13) != uint64(0)) {
        goto label 150
    } else {
        goto label 152
    }
    label 150:
    return err_13
    label 152:
    goto label 154
    label 154:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(base_2)))))))))
    goto label 156
    label 156:
    goto label 72
    label 70:
    goto label 72
    label 72:
    var c2da_fresh164 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh164 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 158
    label 158:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 160
    label 160:
    var c2da_fresh165 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh165 = uint8(uint8(uint8(uint(int(BOX_moov)) >> uint(8) * uint(3))))
    goto label 162
    label 162:
    var c2da_fresh166 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh166 = uint8(uint8(uint8(uint(int(BOX_moov)) >> uint(8) * uint(2))))
    goto label 164
    label 164:
    var c2da_fresh167 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh167 = uint8(uint8(uint8(uint(int(BOX_moov)) >> uint(8) * uint(1))))
    goto label 166
    label 166:
    var c2da_fresh168 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh168 = uint8(uint8(uint8(uint(int(BOX_moov)) >> uint(8) * uint(0))))
    goto label 168
    label 168:
    var c2da_fresh169 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh169 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 170
    label 170:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 172
    label 172:
    var c2da_fresh170 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh170 = uint8(uint8(uint8(uint(int(BOX_mvhd)) >> uint(8) * uint(3))))
    goto label 174
    label 174:
    var c2da_fresh171 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh171 = uint8(uint8(uint8(uint(int(BOX_mvhd)) >> uint(8) * uint(2))))
    goto label 176
    label 176:
    var c2da_fresh172 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh172 = uint8(uint8(uint8(uint(int(BOX_mvhd)) >> uint(8) * uint(1))))
    goto label 178
    label 178:
    var c2da_fresh173 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh173 = uint8(uint8(uint8(uint(int(BOX_mvhd)) >> uint(8) * uint(0))))
    goto label 180
    label 180:
    var c2da_fresh174 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh174 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 182
    label 182:
    var c2da_fresh175 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh175 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 184
    label 184:
    var c2da_fresh176 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh176 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 186
    label 186:
    var c2da_fresh177 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh177 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 188
    label 188:
    var c2da_fresh178 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh178 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 190
    label 190:
    var c2da_fresh179 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh179 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 192
    label 192:
    var c2da_fresh180 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh180 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 194
    label 194:
    var c2da_fresh181 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh181 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 196
    label 196:
    var c2da_fresh182 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh182 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 198
    label 198:
    var c2da_fresh183 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh183 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 200
    label 200:
    var c2da_fresh184 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh184 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 202
    label 202:
    var c2da_fresh185 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh185 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 204
    label 204:
    if (uint64(ntracks) != uint64(0)) {
        goto label 206
    } else {
        goto label 208
    }
    label 206:
    var tr_6 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_6).tracks.data)))))), 0, 112))))))))))))))
    goto label 212
    label 212:
    var duration_2 : uint = uint(uint(uint(get_duration(tr_6))))
    goto label 214
    label 214:
    duration_2 = uint(uint(uint(uint(uint(int64(int64(uint(int64(int64(uint(int64(duration_2))) * int64(uint(int64(1)))))) * int64(uint(int64(int64(1000)))))) / uint(unsafe(unsafe(reinterpret<int64>(unsafe(*tr_6).info.time_scale))))))))
    goto label 216
    label 216:
    var c2da_fresh186 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh186 = uint8(uint8(uint8(uint(1000) >> uint(8) * uint(3))))
    goto label 218
    label 218:
    var c2da_fresh187 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh187 = uint8(uint8(uint8(uint(1000) >> uint(8) * uint(2))))
    goto label 220
    label 220:
    var c2da_fresh188 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh188 = uint8(uint8(uint8(uint(1000) >> uint(8) * uint(1))))
    goto label 222
    label 222:
    var c2da_fresh189 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh189 = uint8(uint8(uint8(uint(1000) >> uint(8) * uint(0))))
    goto label 224
    label 224:
    var c2da_fresh190 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh190 = uint8(uint8(uint8(uint(uint(duration_2)) >> uint(uint(uint(8) * uint(3))))))
    goto label 226
    label 226:
    var c2da_fresh191 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh191 = uint8(uint8(uint8(uint(uint(duration_2)) >> uint(uint(uint(8) * uint(2))))))
    goto label 228
    label 228:
    var c2da_fresh192 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh192 = uint8(uint8(uint8(uint(uint(duration_2)) >> uint(uint(uint(8) * uint(1))))))
    goto label 230
    label 230:
    var c2da_fresh193 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh193 = uint8(uint8(uint8(uint(uint(duration_2)) >> uint(uint(uint(8) * uint(0))))))
    goto label 232
    label 232:
    goto label 210
    label 208:
    goto label 210
    label 210:
    var c2da_fresh194 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh194 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(3))))
    goto label 234
    label 234:
    var c2da_fresh195 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh195 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(2))))
    goto label 236
    label 236:
    var c2da_fresh196 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh196 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(1))))
    goto label 238
    label 238:
    var c2da_fresh197 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh197 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(0))))
    goto label 240
    label 240:
    var c2da_fresh198 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh198 = uint8(uint8(uint8(uint(256) >> uint(8) * uint(1))))
    goto label 242
    label 242:
    var c2da_fresh199 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh199 = uint8(uint8(uint8(uint(256) >> uint(8) * uint(0))))
    goto label 244
    label 244:
    var c2da_fresh200 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh200 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 246
    label 246:
    var c2da_fresh201 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh201 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 248
    label 248:
    var c2da_fresh202 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh202 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 250
    label 250:
    var c2da_fresh203 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh203 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 252
    label 252:
    var c2da_fresh204 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh204 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 254
    label 254:
    var c2da_fresh205 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh205 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 256
    label 256:
    var c2da_fresh206 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh206 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 258
    label 258:
    var c2da_fresh207 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh207 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 260
    label 260:
    var c2da_fresh208 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh208 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 262
    label 262:
    var c2da_fresh209 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh209 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 264
    label 264:
    var c2da_fresh210 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh210 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(3))))
    goto label 266
    label 266:
    var c2da_fresh211 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh211 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(2))))
    goto label 268
    label 268:
    var c2da_fresh212 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh212 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(1))))
    goto label 270
    label 270:
    var c2da_fresh213 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh213 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(0))))
    goto label 272
    label 272:
    var c2da_fresh214 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh214 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 274
    label 274:
    var c2da_fresh215 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh215 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 276
    label 276:
    var c2da_fresh216 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh216 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 278
    label 278:
    var c2da_fresh217 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh217 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 280
    label 280:
    var c2da_fresh218 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh218 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 282
    label 282:
    var c2da_fresh219 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh219 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 284
    label 284:
    var c2da_fresh220 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh220 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 286
    label 286:
    var c2da_fresh221 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh221 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 288
    label 288:
    var c2da_fresh222 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh222 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 290
    label 290:
    var c2da_fresh223 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh223 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 292
    label 292:
    var c2da_fresh224 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh224 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 294
    label 294:
    var c2da_fresh225 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh225 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 296
    label 296:
    var c2da_fresh226 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh226 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(3))))
    goto label 298
    label 298:
    var c2da_fresh227 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh227 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(2))))
    goto label 300
    label 300:
    var c2da_fresh228 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh228 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(1))))
    goto label 302
    label 302:
    var c2da_fresh229 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh229 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(0))))
    goto label 304
    label 304:
    var c2da_fresh230 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh230 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 306
    label 306:
    var c2da_fresh231 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh231 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 308
    label 308:
    var c2da_fresh232 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh232 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 310
    label 310:
    var c2da_fresh233 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh233 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 312
    label 312:
    var c2da_fresh234 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh234 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 314
    label 314:
    var c2da_fresh235 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh235 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 316
    label 316:
    var c2da_fresh236 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh236 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 318
    label 318:
    var c2da_fresh237 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh237 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 320
    label 320:
    var c2da_fresh238 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh238 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 322
    label 322:
    var c2da_fresh239 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh239 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 324
    label 324:
    var c2da_fresh240 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh240 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 326
    label 326:
    var c2da_fresh241 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh241 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 328
    label 328:
    var c2da_fresh242 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh242 = uint8(uint8(uint8(uint(1073741824) >> uint(8) * uint(3))))
    goto label 330
    label 330:
    var c2da_fresh243 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh243 = uint8(uint8(uint8(uint(1073741824) >> uint(8) * uint(2))))
    goto label 332
    label 332:
    var c2da_fresh244 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh244 = uint8(uint8(uint8(uint(1073741824) >> uint(8) * uint(1))))
    goto label 334
    label 334:
    var c2da_fresh245 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh245 = uint8(uint8(uint8(uint(1073741824) >> uint(8) * uint(0))))
    goto label 336
    label 336:
    var c2da_fresh246 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh246 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 338
    label 338:
    var c2da_fresh247 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh247 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 340
    label 340:
    var c2da_fresh248 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh248 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 342
    label 342:
    var c2da_fresh249 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh249 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 344
    label 344:
    var c2da_fresh250 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh250 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 346
    label 346:
    var c2da_fresh251 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh251 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 348
    label 348:
    var c2da_fresh252 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh252 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 350
    label 350:
    var c2da_fresh253 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh253 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 352
    label 352:
    var c2da_fresh254 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh254 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 354
    label 354:
    var c2da_fresh255 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh255 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 356
    label 356:
    var c2da_fresh256 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh256 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 358
    label 358:
    var c2da_fresh257 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh257 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 360
    label 360:
    var c2da_fresh258 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh258 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 362
    label 362:
    var c2da_fresh259 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh259 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 364
    label 364:
    var c2da_fresh260 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh260 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 366
    label 366:
    var c2da_fresh261 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh261 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 368
    label 368:
    var c2da_fresh262 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh262 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 370
    label 370:
    var c2da_fresh263 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh263 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 372
    label 372:
    var c2da_fresh264 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh264 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 374
    label 374:
    var c2da_fresh265 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh265 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 376
    label 376:
    var c2da_fresh266 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh266 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 378
    label 378:
    var c2da_fresh267 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh267 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 380
    label 380:
    var c2da_fresh268 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh268 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 382
    label 382:
    var c2da_fresh269 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh269 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 384
    label 384:
    var c2da_fresh270 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh270 = uint8(uint8(uint8(uint(uint(ntracks) + uint(uint(1))) >> uint(uint(uint(8) * uint(3))))))
    goto label 386
    label 386:
    var c2da_fresh271 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh271 = uint8(uint8(uint8(uint(uint(ntracks) + uint(uint(1))) >> uint(uint(uint(8) * uint(2))))))
    goto label 388
    label 388:
    var c2da_fresh272 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh272 = uint8(uint8(uint8(uint(uint(ntracks) + uint(uint(1))) >> uint(uint(uint(8) * uint(1))))))
    goto label 390
    label 390:
    var c2da_fresh273 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh273 = uint8(uint8(uint8(uint(uint(ntracks) + uint(uint(1))) >> uint(uint(uint(8) * uint(0))))))
    goto label 392
    label 392:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 394
    label 394:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 396
    label 396:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 398
    label 398:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 400
    label 400:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 402
    label 402:
    goto label 410
    label 410:
    ntr_0 = uint(uint(uint(uint(uint(0)))))
    goto label 412
    label 412:
    goto label 404
    label 404:
    if (uint(ntr_0) < uint(ntracks)) {
        goto label 406
    } else {
        goto label 408
    }
    label 406:
    var tr_7 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_6).tracks.data)))))), uint(ntr_0), 112))))))))))))))
    goto label 414
    label 414:
    var duration_3 : uint = uint(uint(uint(get_duration(tr_7))))
    goto label 416
    label 416:
    var samples_count : int = int(int(unsafe(unsafe(reinterpret<uint64>(unsafe(*tr_7).smpl.bytes)))) / int(uint64(0x18)))
    goto label 418
    label 418:
    var sample : minimp4::sample_t const? = unsafe(unsafe(reinterpret<minimp4::sample_t const?>(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(unsafe(*tr_7).smpl.data))))))))))))
    goto label 420
    label 420:
    var handler_type : uint = uint(uint(uint(0)))
    goto label 422
    label 422:
    var handler_ascii : int8 const? = null
    goto label 424
    label 424:
    if (uint64(unsafe(*mux_6).enable_fragmentation) != uint64(0)) {
        goto label 426
    } else {
        goto label 428
    }
    label 426:
    samples_count = 0
    goto label 432
    label 432:
    goto label 430
    label 428:
    if (int(samples_count) <= 0) {
        goto label 434
    } else {
        goto label 436
    }
    label 434:
    goto label 404
    label 436:
    goto label 438
    label 438:
    goto label 430
    label 430:
    if (uint64(uint(unsafe(*tr_7).info.track_media_kind)) == uint64(0)) {
        goto label 37485
    }
    if (uint(unsafe(*tr_7).info.track_media_kind) == 0x1) {
        goto label 37491
    }
    if (uint(unsafe(*tr_7).info.track_media_kind) == 0x2) {
        goto label 37497
    }
    goto label 37501
    label 37485:
    handler_type = uint(uint(uint(uint(uint(1936684398)))))
    goto label 444
    label 444:
    handler_ascii = null
    goto label 446
    label 446:
    goto label 440
    label 37491:
    handler_type = uint(uint(uint(uint(uint(1986618469)))))
    goto label 450
    label 450:
    handler_ascii = null
    goto label 452
    label 452:
    goto label 440
    label 37497:
    handler_type = uint(uint(uint(uint(uint(1734701933)))))
    goto label 456
    label 456:
    goto label 440
    label 37501:
    return -1
    label 440:
    var c2da_fresh274 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh274 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 460
    label 460:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 462
    label 462:
    var c2da_fresh275 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh275 = uint8(uint8(uint8(uint(int(BOX_trak)) >> uint(8) * uint(3))))
    goto label 464
    label 464:
    var c2da_fresh276 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh276 = uint8(uint8(uint8(uint(int(BOX_trak)) >> uint(8) * uint(2))))
    goto label 466
    label 466:
    var c2da_fresh277 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh277 = uint8(uint8(uint8(uint(int(BOX_trak)) >> uint(8) * uint(1))))
    goto label 468
    label 468:
    var c2da_fresh278 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh278 = uint8(uint8(uint8(uint(int(BOX_trak)) >> uint(8) * uint(0))))
    goto label 470
    label 470:
    var c2da_fresh279 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh279 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 472
    label 472:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 474
    label 474:
    var c2da_fresh280 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh280 = uint8(uint8(uint8(uint(int(BOX_tkhd)) >> uint(8) * uint(3))))
    goto label 476
    label 476:
    var c2da_fresh281 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh281 = uint8(uint8(uint8(uint(int(BOX_tkhd)) >> uint(8) * uint(2))))
    goto label 478
    label 478:
    var c2da_fresh282 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh282 = uint8(uint8(uint8(uint(int(BOX_tkhd)) >> uint(8) * uint(1))))
    goto label 480
    label 480:
    var c2da_fresh283 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh283 = uint8(uint8(uint8(uint(int(BOX_tkhd)) >> uint(8) * uint(0))))
    goto label 482
    label 482:
    var c2da_fresh284 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh284 = uint8(uint8(uint8(uint(7) >> uint(8) * uint(3))))
    goto label 484
    label 484:
    var c2da_fresh285 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh285 = uint8(uint8(uint8(uint(7) >> uint(8) * uint(2))))
    goto label 486
    label 486:
    var c2da_fresh286 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh286 = uint8(uint8(uint8(uint(7) >> uint(8) * uint(1))))
    goto label 488
    label 488:
    var c2da_fresh287 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh287 = uint8(uint8(uint8(uint(7) >> uint(8) * uint(0))))
    goto label 490
    label 490:
    var c2da_fresh288 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh288 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 492
    label 492:
    var c2da_fresh289 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh289 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 494
    label 494:
    var c2da_fresh290 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh290 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 496
    label 496:
    var c2da_fresh291 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh291 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 498
    label 498:
    var c2da_fresh292 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh292 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 500
    label 500:
    var c2da_fresh293 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh293 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 502
    label 502:
    var c2da_fresh294 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh294 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 504
    label 504:
    var c2da_fresh295 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh295 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 506
    label 506:
    var c2da_fresh296 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh296 = uint8(uint8(uint8(uint(uint(ntr_0) + uint(uint(1))) >> uint(uint(uint(8) * uint(3))))))
    goto label 508
    label 508:
    var c2da_fresh297 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh297 = uint8(uint8(uint8(uint(uint(ntr_0) + uint(uint(1))) >> uint(uint(uint(8) * uint(2))))))
    goto label 510
    label 510:
    var c2da_fresh298 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh298 = uint8(uint8(uint8(uint(uint(ntr_0) + uint(uint(1))) >> uint(uint(uint(8) * uint(1))))))
    goto label 512
    label 512:
    var c2da_fresh299 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh299 = uint8(uint8(uint8(uint(uint(ntr_0) + uint(uint(1))) >> uint(uint(uint(8) * uint(0))))))
    goto label 514
    label 514:
    var c2da_fresh300 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh300 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 516
    label 516:
    var c2da_fresh301 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh301 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 518
    label 518:
    var c2da_fresh302 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh302 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 520
    label 520:
    var c2da_fresh303 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh303 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 522
    label 522:
    var c2da_fresh304 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh304 = uint8(uint8(uint8(uint(uint(uint(int64(int64(uint(int64(int64(uint(int64(duration_3))) * int64(uint(int64(1)))))) * int64(uint(int64(int64(1000)))))) / uint(unsafe(unsafe(reinterpret<int64>(unsafe(*tr_7).info.time_scale)))))) >> uint(uint(uint(8) * uint(3))))))
    goto label 524
    label 524:
    var c2da_fresh305 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh305 = uint8(uint8(uint8(uint(uint(uint(int64(int64(uint(int64(int64(uint(int64(duration_3))) * int64(uint(int64(1)))))) * int64(uint(int64(int64(1000)))))) / uint(unsafe(unsafe(reinterpret<int64>(unsafe(*tr_7).info.time_scale)))))) >> uint(uint(uint(8) * uint(2))))))
    goto label 526
    label 526:
    var c2da_fresh306 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh306 = uint8(uint8(uint8(uint(uint(uint(int64(int64(uint(int64(int64(uint(int64(duration_3))) * int64(uint(int64(1)))))) * int64(uint(int64(int64(1000)))))) / uint(unsafe(unsafe(reinterpret<int64>(unsafe(*tr_7).info.time_scale)))))) >> uint(uint(uint(8) * uint(1))))))
    goto label 528
    label 528:
    var c2da_fresh307 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh307 = uint8(uint8(uint8(uint(uint(uint(int64(int64(uint(int64(int64(uint(int64(duration_3))) * int64(uint(int64(1)))))) * int64(uint(int64(int64(1000)))))) / uint(unsafe(unsafe(reinterpret<int64>(unsafe(*tr_7).info.time_scale)))))) >> uint(uint(uint(8) * uint(0))))))
    goto label 530
    label 530:
    var c2da_fresh308 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh308 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 532
    label 532:
    var c2da_fresh309 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh309 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 534
    label 534:
    var c2da_fresh310 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh310 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 536
    label 536:
    var c2da_fresh311 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh311 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 538
    label 538:
    var c2da_fresh312 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh312 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 540
    label 540:
    var c2da_fresh313 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh313 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 542
    label 542:
    var c2da_fresh314 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh314 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 544
    label 544:
    var c2da_fresh315 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh315 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 546
    label 546:
    var c2da_fresh316 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh316 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 548
    label 548:
    var c2da_fresh317 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh317 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 550
    label 550:
    var c2da_fresh318 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh318 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 552
    label 552:
    var c2da_fresh319 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh319 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 554
    label 554:
    var c2da_fresh320 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh320 = uint8(uint8(uint8(uint(256) >> uint(8) * uint(1))))
    goto label 556
    label 556:
    var c2da_fresh321 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh321 = uint8(uint8(uint8(uint(256) >> uint(8) * uint(0))))
    goto label 558
    label 558:
    var c2da_fresh322 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh322 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 560
    label 560:
    var c2da_fresh323 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh323 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 562
    label 562:
    var c2da_fresh324 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh324 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(3))))
    goto label 564
    label 564:
    var c2da_fresh325 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh325 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(2))))
    goto label 566
    label 566:
    var c2da_fresh326 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh326 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(1))))
    goto label 568
    label 568:
    var c2da_fresh327 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh327 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(0))))
    goto label 570
    label 570:
    var c2da_fresh328 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh328 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 572
    label 572:
    var c2da_fresh329 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh329 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 574
    label 574:
    var c2da_fresh330 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh330 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 576
    label 576:
    var c2da_fresh331 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh331 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 578
    label 578:
    var c2da_fresh332 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh332 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 580
    label 580:
    var c2da_fresh333 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh333 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 582
    label 582:
    var c2da_fresh334 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh334 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 584
    label 584:
    var c2da_fresh335 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh335 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 586
    label 586:
    var c2da_fresh336 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh336 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 588
    label 588:
    var c2da_fresh337 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh337 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 590
    label 590:
    var c2da_fresh338 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh338 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 592
    label 592:
    var c2da_fresh339 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh339 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 594
    label 594:
    var c2da_fresh340 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh340 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(3))))
    goto label 596
    label 596:
    var c2da_fresh341 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh341 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(2))))
    goto label 598
    label 598:
    var c2da_fresh342 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh342 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(1))))
    goto label 600
    label 600:
    var c2da_fresh343 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh343 = uint8(uint8(uint8(uint(65536) >> uint(8) * uint(0))))
    goto label 602
    label 602:
    var c2da_fresh344 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh344 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 604
    label 604:
    var c2da_fresh345 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh345 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 606
    label 606:
    var c2da_fresh346 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh346 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 608
    label 608:
    var c2da_fresh347 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh347 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 610
    label 610:
    var c2da_fresh348 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh348 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 612
    label 612:
    var c2da_fresh349 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh349 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 614
    label 614:
    var c2da_fresh350 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh350 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 616
    label 616:
    var c2da_fresh351 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh351 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 618
    label 618:
    var c2da_fresh352 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh352 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 620
    label 620:
    var c2da_fresh353 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh353 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 622
    label 622:
    var c2da_fresh354 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh354 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 624
    label 624:
    var c2da_fresh355 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh355 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 626
    label 626:
    var c2da_fresh356 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh356 = uint8(uint8(uint8(uint(1073741824) >> uint(8) * uint(3))))
    goto label 628
    label 628:
    var c2da_fresh357 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh357 = uint8(uint8(uint8(uint(1073741824) >> uint(8) * uint(2))))
    goto label 630
    label 630:
    var c2da_fresh358 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh358 = uint8(uint8(uint8(uint(1073741824) >> uint(8) * uint(1))))
    goto label 632
    label 632:
    var c2da_fresh359 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh359 = uint8(uint8(uint8(uint(1073741824) >> uint(8) * uint(0))))
    goto label 634
    label 634:
    if (uint(unsafe(*tr_7).info.track_media_kind) == uint(e_audio) || uint(unsafe(*tr_7).info.track_media_kind) == uint(e_private)) {
        goto label 636
    } else {
        goto label 638
    }
    label 636:
    var c2da_fresh360 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh360 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 642
    label 642:
    var c2da_fresh361 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh361 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 644
    label 644:
    var c2da_fresh362 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh362 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 646
    label 646:
    var c2da_fresh363 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh363 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 648
    label 648:
    var c2da_fresh364 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh364 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 650
    label 650:
    var c2da_fresh365 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh365 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 652
    label 652:
    var c2da_fresh366 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh366 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 654
    label 654:
    var c2da_fresh367 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh367 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 656
    label 656:
    goto label 640
    label 638:
    var c2da_fresh368 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh368 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.width)) * uint(65536) >> uint(8) * uint(3))))
    goto label 658
    label 658:
    var c2da_fresh369 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh369 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.width)) * uint(65536) >> uint(8) * uint(2))))
    goto label 660
    label 660:
    var c2da_fresh370 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh370 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.width)) * uint(65536) >> uint(8) * uint(1))))
    goto label 662
    label 662:
    var c2da_fresh371 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh371 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.width)) * uint(65536) >> uint(8) * uint(0))))
    goto label 664
    label 664:
    var c2da_fresh372 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh372 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.height)) * uint(65536) >> uint(8) * uint(3))))
    goto label 666
    label 666:
    var c2da_fresh373 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh373 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.height)) * uint(65536) >> uint(8) * uint(2))))
    goto label 668
    label 668:
    var c2da_fresh374 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh374 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.height)) * uint(65536) >> uint(8) * uint(1))))
    goto label 670
    label 670:
    var c2da_fresh375 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh375 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.height)) * uint(65536) >> uint(8) * uint(0))))
    goto label 672
    label 672:
    goto label 640
    label 640:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 674
    label 674:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 676
    label 676:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 678
    label 678:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 680
    label 680:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 682
    label 682:
    var c2da_fresh376 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh376 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 684
    label 684:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 686
    label 686:
    var c2da_fresh377 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh377 = uint8(uint8(uint8(uint(int(BOX_mdia)) >> uint(8) * uint(3))))
    goto label 688
    label 688:
    var c2da_fresh378 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh378 = uint8(uint8(uint8(uint(int(BOX_mdia)) >> uint(8) * uint(2))))
    goto label 690
    label 690:
    var c2da_fresh379 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh379 = uint8(uint8(uint8(uint(int(BOX_mdia)) >> uint(8) * uint(1))))
    goto label 692
    label 692:
    var c2da_fresh380 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh380 = uint8(uint8(uint8(uint(int(BOX_mdia)) >> uint(8) * uint(0))))
    goto label 694
    label 694:
    var c2da_fresh381 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh381 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 696
    label 696:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 698
    label 698:
    var c2da_fresh382 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh382 = uint8(uint8(uint8(uint(int(BOX_mdhd)) >> uint(8) * uint(3))))
    goto label 700
    label 700:
    var c2da_fresh383 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh383 = uint8(uint8(uint8(uint(int(BOX_mdhd)) >> uint(8) * uint(2))))
    goto label 702
    label 702:
    var c2da_fresh384 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh384 = uint8(uint8(uint8(uint(int(BOX_mdhd)) >> uint(8) * uint(1))))
    goto label 704
    label 704:
    var c2da_fresh385 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh385 = uint8(uint8(uint8(uint(int(BOX_mdhd)) >> uint(8) * uint(0))))
    goto label 706
    label 706:
    var c2da_fresh386 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh386 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 708
    label 708:
    var c2da_fresh387 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh387 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 710
    label 710:
    var c2da_fresh388 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh388 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 712
    label 712:
    var c2da_fresh389 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh389 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 714
    label 714:
    var c2da_fresh390 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh390 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 716
    label 716:
    var c2da_fresh391 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh391 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 718
    label 718:
    var c2da_fresh392 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh392 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 720
    label 720:
    var c2da_fresh393 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh393 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 722
    label 722:
    var c2da_fresh394 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh394 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 724
    label 724:
    var c2da_fresh395 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh395 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 726
    label 726:
    var c2da_fresh396 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh396 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 728
    label 728:
    var c2da_fresh397 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh397 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 730
    label 730:
    var c2da_fresh398 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh398 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.time_scale)) >> uint(uint(uint(8) * uint(3))))))
    goto label 732
    label 732:
    var c2da_fresh399 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh399 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.time_scale)) >> uint(uint(uint(8) * uint(2))))))
    goto label 734
    label 734:
    var c2da_fresh400 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh400 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.time_scale)) >> uint(uint(uint(8) * uint(1))))))
    goto label 736
    label 736:
    var c2da_fresh401 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh401 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.time_scale)) >> uint(uint(uint(8) * uint(0))))))
    goto label 738
    label 738:
    var c2da_fresh402 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh402 = uint8(uint8(uint8(uint(uint(duration_3)) >> uint(uint(uint(8) * uint(3))))))
    goto label 740
    label 740:
    var c2da_fresh403 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh403 = uint8(uint8(uint8(uint(uint(duration_3)) >> uint(uint(uint(8) * uint(2))))))
    goto label 742
    label 742:
    var c2da_fresh404 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh404 = uint8(uint8(uint8(uint(uint(duration_3)) >> uint(uint(uint(8) * uint(1))))))
    goto label 744
    label 744:
    var c2da_fresh405 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh405 = uint8(uint8(uint8(uint(uint(duration_3)) >> uint(uint(uint(8) * uint(0))))))
    goto label 746
    label 746:
    var lang_code : int = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(unsafe(*tr_7).info.language[0])))))[0]))) & 31) << 10 | (int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(unsafe(*tr_7).info.language[0])))))[1]))) & 31) << 5 | int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(unsafe(*tr_7).info.language[0])))))[2]))) & 31)))
    goto label 748
    label 748:
    var c2da_fresh406 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh406 = uint8(uint8(uint8(uint(int(lang_code)) >> uint(8) * uint(1))))
    goto label 750
    label 750:
    var c2da_fresh407 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh407 = uint8(uint8(uint8(uint(int(lang_code)) >> uint(8) * uint(0))))
    goto label 752
    label 752:
    var c2da_fresh408 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh408 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 754
    label 754:
    var c2da_fresh409 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh409 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 756
    label 756:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 758
    label 758:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 760
    label 760:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 762
    label 762:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 764
    label 764:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 766
    label 766:
    var c2da_fresh410 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh410 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 768
    label 768:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 770
    label 770:
    var c2da_fresh411 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh411 = uint8(uint8(uint8(uint(int(BOX_hdlr)) >> uint(8) * uint(3))))
    goto label 772
    label 772:
    var c2da_fresh412 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh412 = uint8(uint8(uint8(uint(int(BOX_hdlr)) >> uint(8) * uint(2))))
    goto label 774
    label 774:
    var c2da_fresh413 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh413 = uint8(uint8(uint8(uint(int(BOX_hdlr)) >> uint(8) * uint(1))))
    goto label 776
    label 776:
    var c2da_fresh414 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh414 = uint8(uint8(uint8(uint(int(BOX_hdlr)) >> uint(8) * uint(0))))
    goto label 778
    label 778:
    var c2da_fresh415 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh415 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 780
    label 780:
    var c2da_fresh416 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh416 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 782
    label 782:
    var c2da_fresh417 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh417 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 784
    label 784:
    var c2da_fresh418 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh418 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 786
    label 786:
    var c2da_fresh419 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh419 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 788
    label 788:
    var c2da_fresh420 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh420 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 790
    label 790:
    var c2da_fresh421 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh421 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 792
    label 792:
    var c2da_fresh422 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh422 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 794
    label 794:
    var c2da_fresh423 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh423 = uint8(uint8(uint8(uint(uint(handler_type)) >> uint(uint(uint(8) * uint(3))))))
    goto label 796
    label 796:
    var c2da_fresh424 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh424 = uint8(uint8(uint8(uint(uint(handler_type)) >> uint(uint(uint(8) * uint(2))))))
    goto label 798
    label 798:
    var c2da_fresh425 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh425 = uint8(uint8(uint8(uint(uint(handler_type)) >> uint(uint(uint(8) * uint(1))))))
    goto label 800
    label 800:
    var c2da_fresh426 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh426 = uint8(uint8(uint8(uint(uint(handler_type)) >> uint(uint(uint(8) * uint(0))))))
    goto label 802
    label 802:
    var c2da_fresh427 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh427 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 804
    label 804:
    var c2da_fresh428 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh428 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 806
    label 806:
    var c2da_fresh429 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh429 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 808
    label 808:
    var c2da_fresh430 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh430 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 810
    label 810:
    var c2da_fresh431 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh431 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 812
    label 812:
    var c2da_fresh432 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh432 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 814
    label 814:
    var c2da_fresh433 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh433 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 816
    label 816:
    var c2da_fresh434 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh434 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 818
    label 818:
    var c2da_fresh435 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh435 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 820
    label 820:
    var c2da_fresh436 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh436 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 822
    label 822:
    var c2da_fresh437 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh437 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 824
    label 824:
    var c2da_fresh438 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh438 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 826
    label 826:
    if (handler_ascii != null) {
        goto label 828
    } else {
        goto label 830
    }
    label 828:
    goto label 840
    label 840:
    i_0 = 0
    goto label 842
    label 842:
    goto label 834
    label 834:
    if (int(i_0) < int(c2da_strlen(handler_ascii)) + 1) {
        goto label 836
    } else {
        goto label 838
    }
    label 836:
    var c2da_fresh439 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh439 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<int8 const?>(handler_ascii)))[uint(i_0)])))) >> uint(8) * uint(0))))
    goto label 844
    label 844:
    var c2da_fresh440 : int = i_0
    i_0 = int(i_0) + 1
    goto label 834
    label 838:
    goto label 832
    label 830:
    var c2da_fresh441 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh441 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 846
    label 846:
    var c2da_fresh442 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh442 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 848
    label 848:
    var c2da_fresh443 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh443 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 850
    label 850:
    var c2da_fresh444 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh444 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 852
    label 852:
    goto label 832
    label 832:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 854
    label 854:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 856
    label 856:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 858
    label 858:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 860
    label 860:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 862
    label 862:
    var c2da_fresh445 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh445 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 864
    label 864:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 866
    label 866:
    var c2da_fresh446 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh446 = uint8(uint8(uint8(uint(int(BOX_minf)) >> uint(8) * uint(3))))
    goto label 868
    label 868:
    var c2da_fresh447 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh447 = uint8(uint8(uint8(uint(int(BOX_minf)) >> uint(8) * uint(2))))
    goto label 870
    label 870:
    var c2da_fresh448 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh448 = uint8(uint8(uint8(uint(int(BOX_minf)) >> uint(8) * uint(1))))
    goto label 872
    label 872:
    var c2da_fresh449 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh449 = uint8(uint8(uint8(uint(int(BOX_minf)) >> uint(8) * uint(0))))
    goto label 874
    label 874:
    if (uint(unsafe(*tr_7).info.track_media_kind) == uint(e_audio)) {
        goto label 876
    } else {
        goto label 878
    }
    label 876:
    var c2da_fresh450 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh450 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 882
    label 882:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 884
    label 884:
    var c2da_fresh451 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh451 = uint8(uint8(uint8(uint(int(BOX_smhd)) >> uint(8) * uint(3))))
    goto label 886
    label 886:
    var c2da_fresh452 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh452 = uint8(uint8(uint8(uint(int(BOX_smhd)) >> uint(8) * uint(2))))
    goto label 888
    label 888:
    var c2da_fresh453 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh453 = uint8(uint8(uint8(uint(int(BOX_smhd)) >> uint(8) * uint(1))))
    goto label 890
    label 890:
    var c2da_fresh454 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh454 = uint8(uint8(uint8(uint(int(BOX_smhd)) >> uint(8) * uint(0))))
    goto label 892
    label 892:
    var c2da_fresh455 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh455 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 894
    label 894:
    var c2da_fresh456 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh456 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 896
    label 896:
    var c2da_fresh457 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh457 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 898
    label 898:
    var c2da_fresh458 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh458 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 900
    label 900:
    var c2da_fresh459 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh459 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 902
    label 902:
    var c2da_fresh460 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh460 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 904
    label 904:
    var c2da_fresh461 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh461 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 906
    label 906:
    var c2da_fresh462 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh462 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 908
    label 908:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 910
    label 910:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 912
    label 912:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 914
    label 914:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 916
    label 916:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 918
    label 918:
    goto label 880
    label 878:
    goto label 880
    label 880:
    if (uint(unsafe(*tr_7).info.track_media_kind) == uint(e_video)) {
        goto label 920
    } else {
        goto label 922
    }
    label 920:
    var c2da_fresh463 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh463 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 926
    label 926:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 928
    label 928:
    var c2da_fresh464 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh464 = uint8(uint8(uint8(uint(int(BOX_vmhd)) >> uint(8) * uint(3))))
    goto label 930
    label 930:
    var c2da_fresh465 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh465 = uint8(uint8(uint8(uint(int(BOX_vmhd)) >> uint(8) * uint(2))))
    goto label 932
    label 932:
    var c2da_fresh466 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh466 = uint8(uint8(uint8(uint(int(BOX_vmhd)) >> uint(8) * uint(1))))
    goto label 934
    label 934:
    var c2da_fresh467 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh467 = uint8(uint8(uint8(uint(int(BOX_vmhd)) >> uint(8) * uint(0))))
    goto label 936
    label 936:
    var c2da_fresh468 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh468 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 938
    label 938:
    var c2da_fresh469 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh469 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 940
    label 940:
    var c2da_fresh470 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh470 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 942
    label 942:
    var c2da_fresh471 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh471 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 944
    label 944:
    var c2da_fresh472 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh472 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 946
    label 946:
    var c2da_fresh473 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh473 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 948
    label 948:
    var c2da_fresh474 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh474 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 950
    label 950:
    var c2da_fresh475 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh475 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 952
    label 952:
    var c2da_fresh476 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh476 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 954
    label 954:
    var c2da_fresh477 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh477 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 956
    label 956:
    var c2da_fresh478 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh478 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 958
    label 958:
    var c2da_fresh479 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh479 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 960
    label 960:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 962
    label 962:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 964
    label 964:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 966
    label 966:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 968
    label 968:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 970
    label 970:
    goto label 924
    label 922:
    goto label 924
    label 924:
    var c2da_fresh480 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh480 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 972
    label 972:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 974
    label 974:
    var c2da_fresh481 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh481 = uint8(uint8(uint8(uint(int(BOX_dinf)) >> uint(8) * uint(3))))
    goto label 976
    label 976:
    var c2da_fresh482 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh482 = uint8(uint8(uint8(uint(int(BOX_dinf)) >> uint(8) * uint(2))))
    goto label 978
    label 978:
    var c2da_fresh483 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh483 = uint8(uint8(uint8(uint(int(BOX_dinf)) >> uint(8) * uint(1))))
    goto label 980
    label 980:
    var c2da_fresh484 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh484 = uint8(uint8(uint8(uint(int(BOX_dinf)) >> uint(8) * uint(0))))
    goto label 982
    label 982:
    var c2da_fresh485 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh485 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 984
    label 984:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 986
    label 986:
    var c2da_fresh486 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh486 = uint8(uint8(uint8(uint(int(BOX_dref)) >> uint(8) * uint(3))))
    goto label 988
    label 988:
    var c2da_fresh487 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh487 = uint8(uint8(uint8(uint(int(BOX_dref)) >> uint(8) * uint(2))))
    goto label 990
    label 990:
    var c2da_fresh488 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh488 = uint8(uint8(uint8(uint(int(BOX_dref)) >> uint(8) * uint(1))))
    goto label 992
    label 992:
    var c2da_fresh489 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh489 = uint8(uint8(uint8(uint(int(BOX_dref)) >> uint(8) * uint(0))))
    goto label 994
    label 994:
    var c2da_fresh490 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh490 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 996
    label 996:
    var c2da_fresh491 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh491 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 998
    label 998:
    var c2da_fresh492 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh492 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1000
    label 1000:
    var c2da_fresh493 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh493 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1002
    label 1002:
    var c2da_fresh494 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh494 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 1004
    label 1004:
    var c2da_fresh495 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh495 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 1006
    label 1006:
    var c2da_fresh496 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh496 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1008
    label 1008:
    var c2da_fresh497 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh497 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1010
    label 1010:
    var c2da_fresh498 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh498 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1012
    label 1012:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1014
    label 1014:
    var c2da_fresh499 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh499 = uint8(uint8(uint8(uint(int(BOX_url)) >> uint(8) * uint(3))))
    goto label 1016
    label 1016:
    var c2da_fresh500 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh500 = uint8(uint8(uint8(uint(int(BOX_url)) >> uint(8) * uint(2))))
    goto label 1018
    label 1018:
    var c2da_fresh501 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh501 = uint8(uint8(uint8(uint(int(BOX_url)) >> uint(8) * uint(1))))
    goto label 1020
    label 1020:
    var c2da_fresh502 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh502 = uint8(uint8(uint8(uint(int(BOX_url)) >> uint(8) * uint(0))))
    goto label 1022
    label 1022:
    var c2da_fresh503 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh503 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 1024
    label 1024:
    var c2da_fresh504 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh504 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 1026
    label 1026:
    var c2da_fresh505 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh505 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1028
    label 1028:
    var c2da_fresh506 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh506 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1030
    label 1030:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1032
    label 1032:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1034
    label 1034:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1036
    label 1036:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1038
    label 1038:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1040
    label 1040:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1042
    label 1042:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1044
    label 1044:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1046
    label 1046:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1048
    label 1048:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1050
    label 1050:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1052
    label 1052:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1054
    label 1054:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1056
    label 1056:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1058
    label 1058:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1060
    label 1060:
    var c2da_fresh507 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh507 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1062
    label 1062:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1064
    label 1064:
    var c2da_fresh508 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh508 = uint8(uint8(uint8(uint(int(BOX_stbl)) >> uint(8) * uint(3))))
    goto label 1066
    label 1066:
    var c2da_fresh509 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh509 = uint8(uint8(uint8(uint(int(BOX_stbl)) >> uint(8) * uint(2))))
    goto label 1068
    label 1068:
    var c2da_fresh510 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh510 = uint8(uint8(uint8(uint(int(BOX_stbl)) >> uint(8) * uint(1))))
    goto label 1070
    label 1070:
    var c2da_fresh511 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh511 = uint8(uint8(uint8(uint(int(BOX_stbl)) >> uint(8) * uint(0))))
    goto label 1072
    label 1072:
    var c2da_fresh512 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh512 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1074
    label 1074:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1076
    label 1076:
    var c2da_fresh513 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh513 = uint8(uint8(uint8(uint(int(BOX_stsd)) >> uint(8) * uint(3))))
    goto label 1078
    label 1078:
    var c2da_fresh514 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh514 = uint8(uint8(uint8(uint(int(BOX_stsd)) >> uint(8) * uint(2))))
    goto label 1080
    label 1080:
    var c2da_fresh515 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh515 = uint8(uint8(uint8(uint(int(BOX_stsd)) >> uint(8) * uint(1))))
    goto label 1082
    label 1082:
    var c2da_fresh516 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh516 = uint8(uint8(uint8(uint(int(BOX_stsd)) >> uint(8) * uint(0))))
    goto label 1084
    label 1084:
    var c2da_fresh517 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh517 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1086
    label 1086:
    var c2da_fresh518 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh518 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1088
    label 1088:
    var c2da_fresh519 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh519 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1090
    label 1090:
    var c2da_fresh520 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh520 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1092
    label 1092:
    var c2da_fresh521 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh521 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 1094
    label 1094:
    var c2da_fresh522 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh522 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 1096
    label 1096:
    var c2da_fresh523 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh523 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1098
    label 1098:
    var c2da_fresh524 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh524 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1100
    label 1100:
    if (uint(unsafe(*tr_7).info.track_media_kind) == uint(e_audio) || uint(unsafe(*tr_7).info.track_media_kind) == uint(e_private)) {
        goto label 1102
    } else {
        goto label 1104
    }
    label 1102:
    if (uint(unsafe(*tr_7).info.track_media_kind) == uint(e_audio)) {
        goto label 1108
    } else {
        goto label 1110
    }
    label 1108:
    var c2da_fresh525 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh525 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1114
    label 1114:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1116
    label 1116:
    var c2da_fresh526 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh526 = uint8(uint8(uint8(uint(int(BOX_mp4a)) >> uint(8) * uint(3))))
    goto label 1118
    label 1118:
    var c2da_fresh527 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh527 = uint8(uint8(uint8(uint(int(BOX_mp4a)) >> uint(8) * uint(2))))
    goto label 1120
    label 1120:
    var c2da_fresh528 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh528 = uint8(uint8(uint8(uint(int(BOX_mp4a)) >> uint(8) * uint(1))))
    goto label 1122
    label 1122:
    var c2da_fresh529 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh529 = uint8(uint8(uint8(uint(int(BOX_mp4a)) >> uint(8) * uint(0))))
    goto label 1124
    label 1124:
    goto label 1112
    label 1110:
    var c2da_fresh530 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh530 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1126
    label 1126:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1128
    label 1128:
    var c2da_fresh531 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh531 = uint8(uint8(uint8(uint(int(BOX_mp4s)) >> uint(8) * uint(3))))
    goto label 1130
    label 1130:
    var c2da_fresh532 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh532 = uint8(uint8(uint8(uint(int(BOX_mp4s)) >> uint(8) * uint(2))))
    goto label 1132
    label 1132:
    var c2da_fresh533 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh533 = uint8(uint8(uint8(uint(int(BOX_mp4s)) >> uint(8) * uint(1))))
    goto label 1134
    label 1134:
    var c2da_fresh534 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh534 = uint8(uint8(uint8(uint(int(BOX_mp4s)) >> uint(8) * uint(0))))
    goto label 1136
    label 1136:
    goto label 1112
    label 1112:
    var c2da_fresh535 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh535 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1138
    label 1138:
    var c2da_fresh536 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh536 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1140
    label 1140:
    var c2da_fresh537 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh537 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1142
    label 1142:
    var c2da_fresh538 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh538 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1144
    label 1144:
    var c2da_fresh539 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh539 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1146
    label 1146:
    var c2da_fresh540 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh540 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1148
    label 1148:
    var c2da_fresh541 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh541 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1150
    label 1150:
    var c2da_fresh542 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh542 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1152
    label 1152:
    if (uint(unsafe(*tr_7).info.track_media_kind) == uint(e_audio)) {
        goto label 1154
    } else {
        goto label 1156
    }
    label 1154:
    var c2da_fresh543 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh543 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1160
    label 1160:
    var c2da_fresh544 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh544 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1162
    label 1162:
    var c2da_fresh545 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh545 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1164
    label 1164:
    var c2da_fresh546 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh546 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1166
    label 1166:
    var c2da_fresh547 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh547 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1168
    label 1168:
    var c2da_fresh548 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh548 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1170
    label 1170:
    var c2da_fresh549 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh549 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1172
    label 1172:
    var c2da_fresh550 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh550 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1174
    label 1174:
    var c2da_fresh551 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh551 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.u.a.channelcount)) >> uint(uint(uint(8) * uint(1))))))
    goto label 1176
    label 1176:
    var c2da_fresh552 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh552 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.u.a.channelcount)) >> uint(uint(uint(8) * uint(0))))))
    goto label 1178
    label 1178:
    var c2da_fresh553 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh553 = uint8(uint8(uint8(uint(16) >> uint(8) * uint(1))))
    goto label 1180
    label 1180:
    var c2da_fresh554 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh554 = uint8(uint8(uint8(uint(16) >> uint(8) * uint(0))))
    goto label 1182
    label 1182:
    var c2da_fresh555 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh555 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1184
    label 1184:
    var c2da_fresh556 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh556 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1186
    label 1186:
    var c2da_fresh557 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh557 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1188
    label 1188:
    var c2da_fresh558 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh558 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1190
    label 1190:
    var c2da_fresh559 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh559 = uint8(uint8(uint8(uint(uint(uint(unsafe(*tr_7).info.time_scale)) << uint(uint(16))) >> uint(uint(uint(8) * uint(3))))))
    goto label 1192
    label 1192:
    var c2da_fresh560 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh560 = uint8(uint8(uint8(uint(uint(uint(unsafe(*tr_7).info.time_scale)) << uint(uint(16))) >> uint(uint(uint(8) * uint(2))))))
    goto label 1194
    label 1194:
    var c2da_fresh561 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh561 = uint8(uint8(uint8(uint(uint(uint(unsafe(*tr_7).info.time_scale)) << uint(uint(16))) >> uint(uint(uint(8) * uint(1))))))
    goto label 1196
    label 1196:
    var c2da_fresh562 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh562 = uint8(uint8(uint8(uint(uint(uint(unsafe(*tr_7).info.time_scale)) << uint(uint(16))) >> uint(uint(uint(8) * uint(0))))))
    goto label 1198
    label 1198:
    goto label 1158
    label 1156:
    goto label 1158
    label 1158:
    var c2da_fresh563 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh563 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1200
    label 1200:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1202
    label 1202:
    var c2da_fresh564 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh564 = uint8(uint8(uint8(uint(int(BOX_esds)) >> uint(8) * uint(3))))
    goto label 1204
    label 1204:
    var c2da_fresh565 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh565 = uint8(uint8(uint8(uint(int(BOX_esds)) >> uint(8) * uint(2))))
    goto label 1206
    label 1206:
    var c2da_fresh566 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh566 = uint8(uint8(uint8(uint(int(BOX_esds)) >> uint(8) * uint(1))))
    goto label 1208
    label 1208:
    var c2da_fresh567 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh567 = uint8(uint8(uint8(uint(int(BOX_esds)) >> uint(8) * uint(0))))
    goto label 1210
    label 1210:
    var c2da_fresh568 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh568 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1212
    label 1212:
    var c2da_fresh569 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh569 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1214
    label 1214:
    var c2da_fresh570 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh570 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1216
    label 1216:
    var c2da_fresh571 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh571 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1218
    label 1218:
    if (int(unsafe(*tr_7).vsps.bytes) > 0) {
        goto label 1220
    } else {
        goto label 1222
    }
    label 1220:
    var dsi_bytes : int = int(unsafe(*tr_7).vsps.bytes) - 2
    goto label 1226
    label 1226:
    var dsi_size_size : int = od_size_of_size(dsi_bytes)
    goto label 1228
    label 1228:
    var dcd_bytes : int = int(dsi_bytes) + int(dsi_size_size) + 1 + (1 + 1 + 3 + 4 + 4)
    goto label 1230
    label 1230:
    var dcd_size_size : int = od_size_of_size(dcd_bytes)
    goto label 1232
    label 1232:
    var esd_bytes : int = int(dcd_bytes) + int(dcd_size_size) + 1 + 3
    goto label 1234
    label 1234:
    var c2da_fresh572 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh572 = uint8(uint8(uint8(uint(3) >> uint(8) * uint(0))))
    goto label 1236
    label 1236:
    if (int(esd_bytes) > 127) {
        goto label 1238
    } else {
        goto label 1240
    }
    label 1238:
    goto label 1244
    label 1244:
    esd_bytes = int(esd_bytes) - 127
    goto label 1250
    label 1250:
    var c2da_fresh573 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh573 = uint8(uint8(uint8(uint(255) >> uint(8) * uint(0))))
    goto label 1252
    label 1252:
    goto label 1246
    label 1246:
    if (int(esd_bytes) > 127) {
        goto label 1244
    } else {
        goto label 1248
    }
    label 1248:
    goto label 1242
    label 1240:
    goto label 1242
    label 1242:
    var c2da_fresh574 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh574 = uint8(uint8(uint8(uint(int(esd_bytes)) >> uint(8) * uint(0))))
    goto label 1254
    label 1254:
    var c2da_fresh575 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh575 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1256
    label 1256:
    var c2da_fresh576 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh576 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1258
    label 1258:
    var c2da_fresh577 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh577 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1260
    label 1260:
    var c2da_fresh578 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh578 = uint8(uint8(uint8(uint(4) >> uint(8) * uint(0))))
    goto label 1262
    label 1262:
    if (int(dcd_bytes) > 127) {
        goto label 1264
    } else {
        goto label 1266
    }
    label 1264:
    goto label 1270
    label 1270:
    dcd_bytes = int(dcd_bytes) - 127
    goto label 1276
    label 1276:
    var c2da_fresh579 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh579 = uint8(uint8(uint8(uint(255) >> uint(8) * uint(0))))
    goto label 1278
    label 1278:
    goto label 1272
    label 1272:
    if (int(dcd_bytes) > 127) {
        goto label 1270
    } else {
        goto label 1274
    }
    label 1274:
    goto label 1268
    label 1266:
    goto label 1268
    label 1268:
    var c2da_fresh580 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh580 = uint8(uint8(uint8(uint(int(dcd_bytes)) >> uint(8) * uint(0))))
    goto label 1280
    label 1280:
    if (uint(unsafe(*tr_7).info.track_media_kind) == uint(e_audio)) {
        goto label 1282
    } else {
        goto label 1284
    }
    label 1282:
    var c2da_fresh581 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh581 = uint8(uint8(uint8(uint(64) >> uint(8) * uint(0))))
    goto label 1288
    label 1288:
    var c2da_fresh582 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh582 = uint8(uint8(uint8(uint(5) << uint(2) >> uint(8) * uint(0))))
    goto label 1290
    label 1290:
    goto label 1286
    label 1284:
    var c2da_fresh583 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh583 = uint8(uint8(uint8(uint(208) >> uint(8) * uint(0))))
    goto label 1292
    label 1292:
    var c2da_fresh584 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh584 = uint8(uint8(uint8(uint(32) << uint(2) >> uint(8) * uint(0))))
    goto label 1294
    label 1294:
    goto label 1286
    label 1286:
    var c2da_fresh585 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh585 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.u.a.channelcount) * uint(uint(6144)) / uint(uint(8))) >> uint(uint(uint(8) * uint(2))))))
    goto label 1296
    label 1296:
    var c2da_fresh586 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh586 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.u.a.channelcount) * uint(uint(6144)) / uint(uint(8))) >> uint(uint(uint(8) * uint(1))))))
    goto label 1298
    label 1298:
    var c2da_fresh587 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh587 = uint8(uint8(uint8(uint(uint(unsafe(*tr_7).info.u.a.channelcount) * uint(uint(6144)) / uint(uint(8))) >> uint(uint(uint(8) * uint(0))))))
    goto label 1300
    label 1300:
    var c2da_fresh588 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh588 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1302
    label 1302:
    var c2da_fresh589 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh589 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1304
    label 1304:
    var c2da_fresh590 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh590 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1306
    label 1306:
    var c2da_fresh591 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh591 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1308
    label 1308:
    var c2da_fresh592 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh592 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1310
    label 1310:
    var c2da_fresh593 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh593 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1312
    label 1312:
    var c2da_fresh594 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh594 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1314
    label 1314:
    var c2da_fresh595 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh595 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1316
    label 1316:
    var c2da_fresh596 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh596 = uint8(uint8(uint8(uint(5) >> uint(8) * uint(0))))
    goto label 1318
    label 1318:
    if (int(dsi_bytes) > 127) {
        goto label 1320
    } else {
        goto label 1322
    }
    label 1320:
    goto label 1326
    label 1326:
    dsi_bytes = int(dsi_bytes) - 127
    goto label 1332
    label 1332:
    var c2da_fresh597 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh597 = uint8(uint8(uint8(uint(255) >> uint(8) * uint(0))))
    goto label 1334
    label 1334:
    goto label 1328
    label 1328:
    if (int(dsi_bytes) > 127) {
        goto label 1326
    } else {
        goto label 1330
    }
    label 1330:
    goto label 1324
    label 1322:
    goto label 1324
    label 1324:
    var c2da_fresh598 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh598 = uint8(uint8(uint8(uint(int(dsi_bytes)) >> uint(8) * uint(0))))
    goto label 1336
    label 1336:
    goto label 1344
    label 1344:
    i_0 = 0
    goto label 1346
    label 1346:
    goto label 1338
    label 1338:
    if (int(i_0) < int(dsi_bytes)) {
        goto label 1340
    } else {
        goto label 1342
    }
    label 1340:
    var c2da_fresh599 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh599 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vsps.data)))[2 + int(i_0)])))) >> uint(8) * uint(0))))
    goto label 1348
    label 1348:
    var c2da_fresh600 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1338
    label 1342:
    goto label 1224
    label 1222:
    goto label 1224
    label 1224:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1350
    label 1350:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1352
    label 1352:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1354
    label 1354:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1356
    label 1356:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1358
    label 1358:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1360
    label 1360:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1362
    label 1362:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1364
    label 1364:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1366
    label 1366:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1368
    label 1368:
    goto label 1106
    label 1104:
    goto label 1106
    label 1106:
    if (uint(unsafe(*tr_7).info.track_media_kind) == uint(e_video) && (uint(uint(33)) == uint(unsafe(*tr_7).info.object_type_indication) || uint(uint(35)) == uint(unsafe(*tr_7).info.object_type_indication))) {
        goto label 1370
    } else {
        goto label 1372
    }
    label 1370:
    var numOfSequenceParameterSets : int = items_count(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_7).vsps))))))
    goto label 1376
    label 1376:
    var numOfPictureParameterSets : int = items_count(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_7).vpps))))))
    goto label 1378
    label 1378:
    if (uint(uint(33)) == uint(unsafe(*tr_7).info.object_type_indication)) {
        goto label 1380
    } else {
        goto label 1382
    }
    label 1380:
    var c2da_fresh601 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh601 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1386
    label 1386:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1388
    label 1388:
    var c2da_fresh602 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh602 = uint8(uint8(uint8(uint(int(BOX_avc1)) >> uint(8) * uint(3))))
    goto label 1390
    label 1390:
    var c2da_fresh603 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh603 = uint8(uint8(uint8(uint(int(BOX_avc1)) >> uint(8) * uint(2))))
    goto label 1392
    label 1392:
    var c2da_fresh604 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh604 = uint8(uint8(uint8(uint(int(BOX_avc1)) >> uint(8) * uint(1))))
    goto label 1394
    label 1394:
    var c2da_fresh605 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh605 = uint8(uint8(uint8(uint(int(BOX_avc1)) >> uint(8) * uint(0))))
    goto label 1396
    label 1396:
    goto label 1384
    label 1382:
    var c2da_fresh606 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh606 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1398
    label 1398:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1400
    label 1400:
    var c2da_fresh607 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh607 = uint8(uint8(uint8(uint(int(BOX_hvc1)) >> uint(8) * uint(3))))
    goto label 1402
    label 1402:
    var c2da_fresh608 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh608 = uint8(uint8(uint8(uint(int(BOX_hvc1)) >> uint(8) * uint(2))))
    goto label 1404
    label 1404:
    var c2da_fresh609 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh609 = uint8(uint8(uint8(uint(int(BOX_hvc1)) >> uint(8) * uint(1))))
    goto label 1406
    label 1406:
    var c2da_fresh610 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh610 = uint8(uint8(uint8(uint(int(BOX_hvc1)) >> uint(8) * uint(0))))
    goto label 1408
    label 1408:
    goto label 1384
    label 1384:
    var c2da_fresh611 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh611 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1410
    label 1410:
    var c2da_fresh612 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh612 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1412
    label 1412:
    var c2da_fresh613 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh613 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1414
    label 1414:
    var c2da_fresh614 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh614 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1416
    label 1416:
    var c2da_fresh615 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh615 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1418
    label 1418:
    var c2da_fresh616 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh616 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1420
    label 1420:
    var c2da_fresh617 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh617 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1422
    label 1422:
    var c2da_fresh618 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh618 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1424
    label 1424:
    var c2da_fresh619 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh619 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1426
    label 1426:
    var c2da_fresh620 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh620 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1428
    label 1428:
    var c2da_fresh621 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh621 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1430
    label 1430:
    var c2da_fresh622 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh622 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1432
    label 1432:
    var c2da_fresh623 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh623 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1434
    label 1434:
    var c2da_fresh624 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh624 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1436
    label 1436:
    var c2da_fresh625 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh625 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1438
    label 1438:
    var c2da_fresh626 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh626 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1440
    label 1440:
    var c2da_fresh627 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh627 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1442
    label 1442:
    var c2da_fresh628 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh628 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1444
    label 1444:
    var c2da_fresh629 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh629 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1446
    label 1446:
    var c2da_fresh630 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh630 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1448
    label 1448:
    var c2da_fresh631 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh631 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1450
    label 1450:
    var c2da_fresh632 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh632 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1452
    label 1452:
    var c2da_fresh633 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh633 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1454
    label 1454:
    var c2da_fresh634 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh634 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1456
    label 1456:
    var c2da_fresh635 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh635 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.width)) >> uint(8) * uint(1))))
    goto label 1458
    label 1458:
    var c2da_fresh636 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh636 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.width)) >> uint(8) * uint(0))))
    goto label 1460
    label 1460:
    var c2da_fresh637 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh637 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.height)) >> uint(8) * uint(1))))
    goto label 1462
    label 1462:
    var c2da_fresh638 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh638 = uint8(uint8(uint8(uint(int(unsafe(*tr_7).info.u.v.height)) >> uint(8) * uint(0))))
    goto label 1464
    label 1464:
    var c2da_fresh639 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh639 = uint8(uint8(uint8(uint(4718592) >> uint(8) * uint(3))))
    goto label 1466
    label 1466:
    var c2da_fresh640 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh640 = uint8(uint8(uint8(uint(4718592) >> uint(8) * uint(2))))
    goto label 1468
    label 1468:
    var c2da_fresh641 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh641 = uint8(uint8(uint8(uint(4718592) >> uint(8) * uint(1))))
    goto label 1470
    label 1470:
    var c2da_fresh642 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh642 = uint8(uint8(uint8(uint(4718592) >> uint(8) * uint(0))))
    goto label 1472
    label 1472:
    var c2da_fresh643 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh643 = uint8(uint8(uint8(uint(4718592) >> uint(8) * uint(3))))
    goto label 1474
    label 1474:
    var c2da_fresh644 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh644 = uint8(uint8(uint8(uint(4718592) >> uint(8) * uint(2))))
    goto label 1476
    label 1476:
    var c2da_fresh645 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh645 = uint8(uint8(uint8(uint(4718592) >> uint(8) * uint(1))))
    goto label 1478
    label 1478:
    var c2da_fresh646 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh646 = uint8(uint8(uint8(uint(4718592) >> uint(8) * uint(0))))
    goto label 1480
    label 1480:
    var c2da_fresh647 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh647 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1482
    label 1482:
    var c2da_fresh648 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh648 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1484
    label 1484:
    var c2da_fresh649 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh649 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1486
    label 1486:
    var c2da_fresh650 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh650 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1488
    label 1488:
    var c2da_fresh651 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh651 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1490
    label 1490:
    var c2da_fresh652 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh652 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1492
    label 1492:
    goto label 1500
    label 1500:
    i_0 = 0
    goto label 1502
    label 1502:
    goto label 1494
    label 1494:
    if (int(i_0) < 32) {
        goto label 1496
    } else {
        goto label 1498
    }
    label 1496:
    var c2da_fresh653 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh653 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1504
    label 1504:
    var c2da_fresh654 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1494
    label 1498:
    var c2da_fresh655 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh655 = uint8(uint8(uint8(uint(24) >> uint(8) * uint(1))))
    goto label 1506
    label 1506:
    var c2da_fresh656 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh656 = uint8(uint8(uint8(uint(24) >> uint(8) * uint(0))))
    goto label 1508
    label 1508:
    var c2da_fresh657 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh657 = uint8(uint8(uint8(uint(-1) >> uint(8) * uint(1))))
    goto label 1510
    label 1510:
    var c2da_fresh658 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh658 = uint8(uint8(uint8(uint(-1) >> uint(8) * uint(0))))
    goto label 1512
    label 1512:
    if (uint(uint(33)) == uint(unsafe(*tr_7).info.object_type_indication)) {
        goto label 1514
    } else {
        goto label 1516
    }
    label 1514:
    var c2da_fresh659 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh659 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1520
    label 1520:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1522
    label 1522:
    var c2da_fresh660 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh660 = uint8(uint8(uint8(uint(int(BOX_avcC)) >> uint(8) * uint(3))))
    goto label 1524
    label 1524:
    var c2da_fresh661 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh661 = uint8(uint8(uint8(uint(int(BOX_avcC)) >> uint(8) * uint(2))))
    goto label 1526
    label 1526:
    var c2da_fresh662 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh662 = uint8(uint8(uint8(uint(int(BOX_avcC)) >> uint(8) * uint(1))))
    goto label 1528
    label 1528:
    var c2da_fresh663 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh663 = uint8(uint8(uint8(uint(int(BOX_avcC)) >> uint(8) * uint(0))))
    goto label 1530
    label 1530:
    var c2da_fresh664 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh664 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1532
    label 1532:
    var c2da_fresh665 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh665 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vsps.data)))[2 + 1])))) >> uint(8) * uint(0))))
    goto label 1534
    label 1534:
    var c2da_fresh666 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh666 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vsps.data)))[2 + 2])))) >> uint(8) * uint(0))))
    goto label 1536
    label 1536:
    var c2da_fresh667 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh667 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vsps.data)))[2 + 3])))) >> uint(8) * uint(0))))
    goto label 1538
    label 1538:
    var c2da_fresh668 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh668 = uint8(uint8(uint8(uint(255) >> uint(8) * uint(0))))
    goto label 1540
    label 1540:
    var c2da_fresh669 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh669 = uint8(uint8(uint8((uint(224) | uint(int(numOfSequenceParameterSets))) >> uint(8) * uint(0))))
    goto label 1542
    label 1542:
    goto label 1550
    label 1550:
    i_0 = 0
    goto label 1552
    label 1552:
    goto label 1544
    label 1544:
    if (int(i_0) < int(unsafe(*tr_7).vsps.bytes)) {
        goto label 1546
    } else {
        goto label 1548
    }
    label 1546:
    var c2da_fresh670 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh670 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vsps.data)))[uint(i_0)])))) >> uint(8) * uint(0))))
    goto label 1554
    label 1554:
    var c2da_fresh671 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1544
    label 1548:
    var c2da_fresh672 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh672 = uint8(uint8(uint8(uint(int(numOfPictureParameterSets)) >> uint(8) * uint(0))))
    goto label 1556
    label 1556:
    goto label 1564
    label 1564:
    i_0 = 0
    goto label 1566
    label 1566:
    goto label 1558
    label 1558:
    if (int(i_0) < int(unsafe(*tr_7).vpps.bytes)) {
        goto label 1560
    } else {
        goto label 1562
    }
    label 1560:
    var c2da_fresh673 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh673 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vpps.data)))[uint(i_0)])))) >> uint(8) * uint(0))))
    goto label 1568
    label 1568:
    var c2da_fresh674 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1558
    label 1562:
    goto label 1518
    label 1516:
    var numOfVPS : int = items_count(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_7).vpps))))))
    goto label 1570
    label 1570:
    var c2da_fresh675 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh675 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1572
    label 1572:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1574
    label 1574:
    var c2da_fresh676 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh676 = uint8(uint8(uint8(uint(int(BOX_hvcC)) >> uint(8) * uint(3))))
    goto label 1576
    label 1576:
    var c2da_fresh677 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh677 = uint8(uint8(uint8(uint(int(BOX_hvcC)) >> uint(8) * uint(2))))
    goto label 1578
    label 1578:
    var c2da_fresh678 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh678 = uint8(uint8(uint8(uint(int(BOX_hvcC)) >> uint(8) * uint(1))))
    goto label 1580
    label 1580:
    var c2da_fresh679 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh679 = uint8(uint8(uint8(uint(int(BOX_hvcC)) >> uint(8) * uint(0))))
    goto label 1582
    label 1582:
    var c2da_fresh680 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh680 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1584
    label 1584:
    var c2da_fresh681 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh681 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1586
    label 1586:
    var c2da_fresh682 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh682 = uint8(uint8(uint8(uint(1610612736) >> uint(8) * uint(3))))
    goto label 1588
    label 1588:
    var c2da_fresh683 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh683 = uint8(uint8(uint8(uint(1610612736) >> uint(8) * uint(2))))
    goto label 1590
    label 1590:
    var c2da_fresh684 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh684 = uint8(uint8(uint8(uint(1610612736) >> uint(8) * uint(1))))
    goto label 1592
    label 1592:
    var c2da_fresh685 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh685 = uint8(uint8(uint8(uint(1610612736) >> uint(8) * uint(0))))
    goto label 1594
    label 1594:
    var c2da_fresh686 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh686 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1596
    label 1596:
    var c2da_fresh687 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh687 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1598
    label 1598:
    var c2da_fresh688 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh688 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1600
    label 1600:
    var c2da_fresh689 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh689 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1602
    label 1602:
    var c2da_fresh690 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh690 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1604
    label 1604:
    var c2da_fresh691 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh691 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1606
    label 1606:
    var c2da_fresh692 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh692 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1608
    label 1608:
    var c2da_fresh693 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh693 = uint8(uint8(uint8(uint(61440) >> uint(8) * uint(1))))
    goto label 1610
    label 1610:
    var c2da_fresh694 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh694 = uint8(uint8(uint8(uint(61440) >> uint(8) * uint(0))))
    goto label 1612
    label 1612:
    var c2da_fresh695 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh695 = uint8(uint8(uint8(uint(252) >> uint(8) * uint(0))))
    goto label 1614
    label 1614:
    var c2da_fresh696 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh696 = uint8(uint8(uint8(uint(252) >> uint(8) * uint(0))))
    goto label 1616
    label 1616:
    var c2da_fresh697 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh697 = uint8(uint8(uint8(uint(248) >> uint(8) * uint(0))))
    goto label 1618
    label 1618:
    var c2da_fresh698 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh698 = uint8(uint8(uint8(uint(248) >> uint(8) * uint(0))))
    goto label 1620
    label 1620:
    var c2da_fresh699 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh699 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1622
    label 1622:
    var c2da_fresh700 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh700 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1624
    label 1624:
    var c2da_fresh701 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh701 = uint8(uint8(uint8(uint(3) >> uint(8) * uint(0))))
    goto label 1626
    label 1626:
    var c2da_fresh702 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh702 = uint8(uint8(uint8(uint(3) >> uint(8) * uint(0))))
    goto label 1628
    label 1628:
    var c2da_fresh703 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh703 = uint8(uint8(uint8((uint(1) << uint(7) | uint(32) & uint(63)) >> uint(8) * uint(0))))
    goto label 1630
    label 1630:
    var c2da_fresh704 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh704 = uint8(uint8(uint8(uint(int(numOfVPS)) >> uint(8) * uint(1))))
    goto label 1632
    label 1632:
    var c2da_fresh705 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh705 = uint8(uint8(uint8(uint(int(numOfVPS)) >> uint(8) * uint(0))))
    goto label 1634
    label 1634:
    goto label 1642
    label 1642:
    i_0 = 0
    goto label 1644
    label 1644:
    goto label 1636
    label 1636:
    if (int(i_0) < int(unsafe(*tr_7).vvps.bytes)) {
        goto label 1638
    } else {
        goto label 1640
    }
    label 1638:
    var c2da_fresh706 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh706 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vvps.data)))[uint(i_0)])))) >> uint(8) * uint(0))))
    goto label 1646
    label 1646:
    var c2da_fresh707 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1636
    label 1640:
    var c2da_fresh708 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh708 = uint8(uint8(uint8((uint(1) << uint(7) | uint(33) & uint(63)) >> uint(8) * uint(0))))
    goto label 1648
    label 1648:
    var c2da_fresh709 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh709 = uint8(uint8(uint8(uint(int(numOfSequenceParameterSets)) >> uint(8) * uint(1))))
    goto label 1650
    label 1650:
    var c2da_fresh710 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh710 = uint8(uint8(uint8(uint(int(numOfSequenceParameterSets)) >> uint(8) * uint(0))))
    goto label 1652
    label 1652:
    goto label 1660
    label 1660:
    i_0 = 0
    goto label 1662
    label 1662:
    goto label 1654
    label 1654:
    if (int(i_0) < int(unsafe(*tr_7).vsps.bytes)) {
        goto label 1656
    } else {
        goto label 1658
    }
    label 1656:
    var c2da_fresh711 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh711 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vsps.data)))[uint(i_0)])))) >> uint(8) * uint(0))))
    goto label 1664
    label 1664:
    var c2da_fresh712 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1654
    label 1658:
    var c2da_fresh713 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh713 = uint8(uint8(uint8((uint(1) << uint(7) | uint(34) & uint(63)) >> uint(8) * uint(0))))
    goto label 1666
    label 1666:
    var c2da_fresh714 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh714 = uint8(uint8(uint8(uint(int(numOfPictureParameterSets)) >> uint(8) * uint(1))))
    goto label 1668
    label 1668:
    var c2da_fresh715 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh715 = uint8(uint8(uint8(uint(int(numOfPictureParameterSets)) >> uint(8) * uint(0))))
    goto label 1670
    label 1670:
    goto label 1678
    label 1678:
    i_0 = 0
    goto label 1680
    label 1680:
    goto label 1672
    label 1672:
    if (int(i_0) < int(unsafe(*tr_7).vpps.bytes)) {
        goto label 1674
    } else {
        goto label 1676
    }
    label 1674:
    var c2da_fresh716 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh716 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(*tr_7).vpps.data)))[uint(i_0)])))) >> uint(8) * uint(0))))
    goto label 1682
    label 1682:
    var c2da_fresh717 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1672
    label 1676:
    goto label 1518
    label 1518:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1684
    label 1684:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1686
    label 1686:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1688
    label 1688:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1690
    label 1690:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1692
    label 1692:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1694
    label 1694:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1696
    label 1696:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1698
    label 1698:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1700
    label 1700:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1702
    label 1702:
    goto label 1374
    label 1372:
    goto label 1374
    label 1374:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1704
    label 1704:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1706
    label 1706:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1708
    label 1708:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1710
    label 1710:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1712
    label 1712:
    var c2da_fresh718 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh718 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1714
    label 1714:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1716
    label 1716:
    var c2da_fresh719 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh719 = uint8(uint8(uint8(uint(int(BOX_stts)) >> uint(8) * uint(3))))
    goto label 1718
    label 1718:
    var c2da_fresh720 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh720 = uint8(uint8(uint8(uint(int(BOX_stts)) >> uint(8) * uint(2))))
    goto label 1720
    label 1720:
    var c2da_fresh721 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh721 = uint8(uint8(uint8(uint(int(BOX_stts)) >> uint(8) * uint(1))))
    goto label 1722
    label 1722:
    var c2da_fresh722 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh722 = uint8(uint8(uint8(uint(int(BOX_stts)) >> uint(8) * uint(0))))
    goto label 1724
    label 1724:
    var c2da_fresh723 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh723 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1726
    label 1726:
    var c2da_fresh724 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh724 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1728
    label 1728:
    var c2da_fresh725 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh725 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1730
    label 1730:
    var c2da_fresh726 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh726 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1732
    label 1732:
    var pentry_count : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5)))))))))
    goto label 1734
    label 1734:
    var cnt : int = 1
    goto label 1736
    label 1736:
    var entry_count : int = 0
    goto label 1738
    label 1738:
    var c2da_fresh727 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh727 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1740
    label 1740:
    var c2da_fresh728 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh728 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1742
    label 1742:
    var c2da_fresh729 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh729 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1744
    label 1744:
    var c2da_fresh730 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh730 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1746
    label 1746:
    goto label 1754
    label 1754:
    i_0 = 0
    goto label 1756
    label 1756:
    goto label 1748
    label 1748:
    if (int(i_0) < int(samples_count)) {
        goto label 1750
    } else {
        goto label 1752
    }
    label 1750:
    if (int(i_0) == int(samples_count) - 1 || uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).duration) != uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[int(i_0) + 1])).duration)) {
        goto label 1758
    } else {
        goto label 1760
    }
    label 1758:
    var c2da_fresh731 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh731 = uint8(uint8(uint8(uint(int(cnt)) >> uint(8) * uint(3))))
    goto label 1764
    label 1764:
    var c2da_fresh732 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh732 = uint8(uint8(uint8(uint(int(cnt)) >> uint(8) * uint(2))))
    goto label 1766
    label 1766:
    var c2da_fresh733 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh733 = uint8(uint8(uint8(uint(int(cnt)) >> uint(8) * uint(1))))
    goto label 1768
    label 1768:
    var c2da_fresh734 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh734 = uint8(uint8(uint8(uint(int(cnt)) >> uint(8) * uint(0))))
    goto label 1770
    label 1770:
    var c2da_fresh735 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh735 = uint8(uint8(uint8(uint(uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).duration)) >> uint(uint(uint(8) * uint(3))))))
    goto label 1772
    label 1772:
    var c2da_fresh736 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh736 = uint8(uint8(uint8(uint(uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).duration)) >> uint(uint(uint(8) * uint(2))))))
    goto label 1774
    label 1774:
    var c2da_fresh737 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh737 = uint8(uint8(uint8(uint(uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).duration)) >> uint(uint(uint(8) * uint(1))))))
    goto label 1776
    label 1776:
    var c2da_fresh738 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh738 = uint8(uint8(uint8(uint(uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).duration)) >> uint(uint(uint(8) * uint(0))))))
    goto label 1778
    label 1778:
    cnt = 0
    goto label 1780
    label 1780:
    var c2da_fresh739 : int = entry_count
    entry_count = int(entry_count) + 1
    goto label 1782
    label 1782:
    goto label 1762
    label 1760:
    goto label 1762
    label 1762:
    var c2da_fresh741 : int = cnt
    cnt = int(cnt) + 1
    goto label 1748
    label 1752:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(pentry_count)))[0])) = uint8(uint8(uint8(int8(int8(int(entry_count) >> 8 * 3)))))
    goto label 1784
    label 1784:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(pentry_count)))[1])) = uint8(uint8(uint8(int8(int8(int(entry_count) >> 8 * 2)))))
    goto label 1786
    label 1786:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(pentry_count)))[2])) = uint8(uint8(uint8(int8(int8(int(entry_count) >> 8 * 1)))))
    goto label 1788
    label 1788:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(pentry_count)))[3])) = uint8(uint8(uint8(int8(entry_count))))
    goto label 1790
    label 1790:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1792
    label 1792:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1794
    label 1794:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1796
    label 1796:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1798
    label 1798:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1800
    label 1800:
    var c2da_fresh742 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh742 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1802
    label 1802:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1804
    label 1804:
    var c2da_fresh743 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh743 = uint8(uint8(uint8(uint(int(BOX_stsc)) >> uint(8) * uint(3))))
    goto label 1806
    label 1806:
    var c2da_fresh744 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh744 = uint8(uint8(uint8(uint(int(BOX_stsc)) >> uint(8) * uint(2))))
    goto label 1808
    label 1808:
    var c2da_fresh745 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh745 = uint8(uint8(uint8(uint(int(BOX_stsc)) >> uint(8) * uint(1))))
    goto label 1810
    label 1810:
    var c2da_fresh746 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh746 = uint8(uint8(uint8(uint(int(BOX_stsc)) >> uint(8) * uint(0))))
    goto label 1812
    label 1812:
    var c2da_fresh747 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh747 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1814
    label 1814:
    var c2da_fresh748 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh748 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1816
    label 1816:
    var c2da_fresh749 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh749 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1818
    label 1818:
    var c2da_fresh750 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh750 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1820
    label 1820:
    if (uint64(unsafe(*mux_6).enable_fragmentation) != uint64(0)) {
        goto label 1822
    } else {
        goto label 1824
    }
    label 1822:
    var c2da_fresh751 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh751 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1828
    label 1828:
    var c2da_fresh752 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh752 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1830
    label 1830:
    var c2da_fresh753 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh753 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1832
    label 1832:
    var c2da_fresh754 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh754 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1834
    label 1834:
    goto label 1826
    label 1824:
    var c2da_fresh755 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh755 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 1836
    label 1836:
    var c2da_fresh756 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh756 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 1838
    label 1838:
    var c2da_fresh757 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh757 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1840
    label 1840:
    var c2da_fresh758 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh758 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1842
    label 1842:
    var c2da_fresh759 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh759 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 1844
    label 1844:
    var c2da_fresh760 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh760 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 1846
    label 1846:
    var c2da_fresh761 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh761 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1848
    label 1848:
    var c2da_fresh762 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh762 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1850
    label 1850:
    var c2da_fresh763 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh763 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 1852
    label 1852:
    var c2da_fresh764 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh764 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 1854
    label 1854:
    var c2da_fresh765 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh765 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1856
    label 1856:
    var c2da_fresh766 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh766 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1858
    label 1858:
    var c2da_fresh767 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh767 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 1860
    label 1860:
    var c2da_fresh768 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh768 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 1862
    label 1862:
    var c2da_fresh769 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh769 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 1864
    label 1864:
    var c2da_fresh770 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh770 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 1866
    label 1866:
    goto label 1826
    label 1826:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1868
    label 1868:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1870
    label 1870:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1872
    label 1872:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1874
    label 1874:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1876
    label 1876:
    var c2da_fresh771 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh771 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1878
    label 1878:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1880
    label 1880:
    var c2da_fresh772 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh772 = uint8(uint8(uint8(uint(int(BOX_stsz)) >> uint(8) * uint(3))))
    goto label 1882
    label 1882:
    var c2da_fresh773 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh773 = uint8(uint8(uint8(uint(int(BOX_stsz)) >> uint(8) * uint(2))))
    goto label 1884
    label 1884:
    var c2da_fresh774 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh774 = uint8(uint8(uint8(uint(int(BOX_stsz)) >> uint(8) * uint(1))))
    goto label 1886
    label 1886:
    var c2da_fresh775 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh775 = uint8(uint8(uint8(uint(int(BOX_stsz)) >> uint(8) * uint(0))))
    goto label 1888
    label 1888:
    var c2da_fresh776 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh776 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1890
    label 1890:
    var c2da_fresh777 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh777 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1892
    label 1892:
    var c2da_fresh778 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh778 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1894
    label 1894:
    var c2da_fresh779 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh779 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1896
    label 1896:
    var c2da_fresh780 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh780 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1898
    label 1898:
    var c2da_fresh781 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh781 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1900
    label 1900:
    var c2da_fresh782 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh782 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1902
    label 1902:
    var c2da_fresh783 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh783 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1904
    label 1904:
    var c2da_fresh784 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh784 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(3))))
    goto label 1906
    label 1906:
    var c2da_fresh785 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh785 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(2))))
    goto label 1908
    label 1908:
    var c2da_fresh786 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh786 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(1))))
    goto label 1910
    label 1910:
    var c2da_fresh787 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh787 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(0))))
    goto label 1912
    label 1912:
    goto label 1920
    label 1920:
    i_0 = 0
    goto label 1922
    label 1922:
    goto label 1914
    label 1914:
    if (int(i_0) < int(samples_count)) {
        goto label 1916
    } else {
        goto label 1918
    }
    label 1916:
    var c2da_fresh788 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh788 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).size))))) >> uint(uint64(uint64(uint64(8) * uint64(3)))))))
    goto label 1924
    label 1924:
    var c2da_fresh789 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh789 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).size))))) >> uint(uint64(uint64(uint64(8) * uint64(2)))))))
    goto label 1926
    label 1926:
    var c2da_fresh790 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh790 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).size))))) >> uint(uint64(uint64(uint64(8) * uint64(1)))))))
    goto label 1928
    label 1928:
    var c2da_fresh791 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh791 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).size))))) >> uint(uint64(uint64(uint64(8) * uint64(0)))))))
    goto label 1930
    label 1930:
    var c2da_fresh792 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1914
    label 1918:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 1932
    label 1932:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 1934
    label 1934:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 1936
    label 1936:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 1938
    label 1938:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 1940
    label 1940:
    var is_64_bit : int = 0
    goto label 1942
    label 1942:
    if (uint64(samples_count) != uint64(0) && uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[int(samples_count) - 1])).offset) > uint64(uint64(0xffffffff))) {
        goto label 1944
    } else {
        goto label 1946
    }
    label 1944:
    is_64_bit = 1
    goto label 1950
    label 1950:
    goto label 1948
    label 1946:
    goto label 1948
    label 1948:
    if (uint64(is_64_bit) == uint64(0)) {
        goto label 1952
    } else {
        goto label 1954
    }
    label 1952:
    var c2da_fresh793 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh793 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 1958
    label 1958:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 1960
    label 1960:
    var c2da_fresh794 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh794 = uint8(uint8(uint8(uint(int(BOX_stco)) >> uint(8) * uint(3))))
    goto label 1962
    label 1962:
    var c2da_fresh795 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh795 = uint8(uint8(uint8(uint(int(BOX_stco)) >> uint(8) * uint(2))))
    goto label 1964
    label 1964:
    var c2da_fresh796 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh796 = uint8(uint8(uint8(uint(int(BOX_stco)) >> uint(8) * uint(1))))
    goto label 1966
    label 1966:
    var c2da_fresh797 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh797 = uint8(uint8(uint8(uint(int(BOX_stco)) >> uint(8) * uint(0))))
    goto label 1968
    label 1968:
    var c2da_fresh798 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh798 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 1970
    label 1970:
    var c2da_fresh799 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh799 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 1972
    label 1972:
    var c2da_fresh800 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh800 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 1974
    label 1974:
    var c2da_fresh801 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh801 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 1976
    label 1976:
    var c2da_fresh802 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh802 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(3))))
    goto label 1978
    label 1978:
    var c2da_fresh803 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh803 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(2))))
    goto label 1980
    label 1980:
    var c2da_fresh804 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh804 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(1))))
    goto label 1982
    label 1982:
    var c2da_fresh805 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh805 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(0))))
    goto label 1984
    label 1984:
    goto label 1992
    label 1992:
    i_0 = 0
    goto label 1994
    label 1994:
    goto label 1986
    label 1986:
    if (int(i_0) < int(samples_count)) {
        goto label 1988
    } else {
        goto label 1990
    }
    label 1988:
    var c2da_fresh806 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh806 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset))))) >> uint(uint64(uint64(uint64(8) * uint64(3)))))))
    goto label 1996
    label 1996:
    var c2da_fresh807 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh807 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset))))) >> uint(uint64(uint64(uint64(8) * uint64(2)))))))
    goto label 1998
    label 1998:
    var c2da_fresh808 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh808 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset))))) >> uint(uint64(uint64(uint64(8) * uint64(1)))))))
    goto label 2000
    label 2000:
    var c2da_fresh809 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh809 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset))))) >> uint(uint64(uint64(uint64(8) * uint64(0)))))))
    goto label 2002
    label 2002:
    var c2da_fresh810 : int = i_0
    i_0 = int(i_0) + 1
    goto label 1986
    label 1990:
    goto label 1956
    label 1954:
    var c2da_fresh811 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh811 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2004
    label 2004:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2006
    label 2006:
    var c2da_fresh812 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh812 = uint8(uint8(uint8(uint(int(BOX_co64)) >> uint(8) * uint(3))))
    goto label 2008
    label 2008:
    var c2da_fresh813 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh813 = uint8(uint8(uint8(uint(int(BOX_co64)) >> uint(8) * uint(2))))
    goto label 2010
    label 2010:
    var c2da_fresh814 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh814 = uint8(uint8(uint8(uint(int(BOX_co64)) >> uint(8) * uint(1))))
    goto label 2012
    label 2012:
    var c2da_fresh815 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh815 = uint8(uint8(uint8(uint(int(BOX_co64)) >> uint(8) * uint(0))))
    goto label 2014
    label 2014:
    var c2da_fresh816 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh816 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2016
    label 2016:
    var c2da_fresh817 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh817 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2018
    label 2018:
    var c2da_fresh818 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh818 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2020
    label 2020:
    var c2da_fresh819 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh819 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2022
    label 2022:
    var c2da_fresh820 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh820 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(3))))
    goto label 2024
    label 2024:
    var c2da_fresh821 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh821 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(2))))
    goto label 2026
    label 2026:
    var c2da_fresh822 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh822 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(1))))
    goto label 2028
    label 2028:
    var c2da_fresh823 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh823 = uint8(uint8(uint8(uint(int(samples_count)) >> uint(8) * uint(0))))
    goto label 2030
    label 2030:
    goto label 2038
    label 2038:
    i_0 = 0
    goto label 2040
    label 2040:
    goto label 2032
    label 2032:
    if (int(i_0) < int(samples_count)) {
        goto label 2034
    } else {
        goto label 2036
    }
    label 2034:
    var c2da_fresh824 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh824 = uint8(uint8(uint8(uint(uint64(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset)))) >> uint64(uint64(32)) & uint64(uint64(0xffffffff)))) >> uint(uint64(uint64(uint64(8) * uint64(3)))))))
    goto label 2042
    label 2042:
    var c2da_fresh825 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh825 = uint8(uint8(uint8(uint(uint64(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset)))) >> uint64(uint64(32)) & uint64(uint64(0xffffffff)))) >> uint(uint64(uint64(uint64(8) * uint64(2)))))))
    goto label 2044
    label 2044:
    var c2da_fresh826 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh826 = uint8(uint8(uint8(uint(uint64(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset)))) >> uint64(uint64(32)) & uint64(uint64(0xffffffff)))) >> uint(uint64(uint64(uint64(8) * uint64(1)))))))
    goto label 2046
    label 2046:
    var c2da_fresh827 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh827 = uint8(uint8(uint8(uint(uint64(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset)))) >> uint64(uint64(32)) & uint64(uint64(0xffffffff)))) >> uint(uint64(uint64(uint64(8) * uint64(0)))))))
    goto label 2048
    label 2048:
    var c2da_fresh828 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh828 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset))) & uint64(uint64(0xffffffff)))) >> uint(uint64(uint64(uint64(8) * uint64(3)))))))
    goto label 2050
    label 2050:
    var c2da_fresh829 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh829 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset))) & uint64(uint64(0xffffffff)))) >> uint(uint64(uint64(uint64(8) * uint64(2)))))))
    goto label 2052
    label 2052:
    var c2da_fresh830 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh830 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset))) & uint64(uint64(0xffffffff)))) >> uint(uint64(uint64(uint64(8) * uint64(1)))))))
    goto label 2054
    label 2054:
    var c2da_fresh831 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh831 = uint8(uint8(uint8(uint(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).offset))) & uint64(uint64(0xffffffff)))) >> uint(uint64(uint64(uint64(8) * uint64(0)))))))
    goto label 2056
    label 2056:
    var c2da_fresh832 : int = i_0
    i_0 = int(i_0) + 1
    goto label 2032
    label 2036:
    goto label 1956
    label 1956:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2058
    label 2058:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2060
    label 2060:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2062
    label 2062:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2064
    label 2064:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2066
    label 2066:
    var ra_count : int = 0
    goto label 2068
    label 2068:
    goto label 2076
    label 2076:
    i_0 = 0
    goto label 2078
    label 2078:
    goto label 2070
    label 2070:
    if (int(i_0) < int(samples_count)) {
        goto label 2072
    } else {
        goto label 2074
    }
    label 2072:
    ra_count = int(ra_count) + int(c2da_bool_to_int(!(uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).flag_random_access) == uint64(0))))
    goto label 2080
    label 2080:
    var c2da_fresh833 : int = i_0
    i_0 = int(i_0) + 1
    goto label 2070
    label 2074:
    if (int(ra_count) != int(samples_count)) {
        goto label 2082
    } else {
        goto label 2084
    }
    label 2082:
    var c2da_fresh834 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh834 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2088
    label 2088:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2090
    label 2090:
    var c2da_fresh835 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh835 = uint8(uint8(uint8(uint(int(BOX_stss)) >> uint(8) * uint(3))))
    goto label 2092
    label 2092:
    var c2da_fresh836 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh836 = uint8(uint8(uint8(uint(int(BOX_stss)) >> uint(8) * uint(2))))
    goto label 2094
    label 2094:
    var c2da_fresh837 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh837 = uint8(uint8(uint8(uint(int(BOX_stss)) >> uint(8) * uint(1))))
    goto label 2096
    label 2096:
    var c2da_fresh838 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh838 = uint8(uint8(uint8(uint(int(BOX_stss)) >> uint(8) * uint(0))))
    goto label 2098
    label 2098:
    var c2da_fresh839 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh839 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2100
    label 2100:
    var c2da_fresh840 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh840 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2102
    label 2102:
    var c2da_fresh841 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh841 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2104
    label 2104:
    var c2da_fresh842 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh842 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2106
    label 2106:
    var c2da_fresh843 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh843 = uint8(uint8(uint8(uint(int(ra_count)) >> uint(8) * uint(3))))
    goto label 2108
    label 2108:
    var c2da_fresh844 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh844 = uint8(uint8(uint8(uint(int(ra_count)) >> uint(8) * uint(2))))
    goto label 2110
    label 2110:
    var c2da_fresh845 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh845 = uint8(uint8(uint8(uint(int(ra_count)) >> uint(8) * uint(1))))
    goto label 2112
    label 2112:
    var c2da_fresh846 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh846 = uint8(uint8(uint8(uint(int(ra_count)) >> uint(8) * uint(0))))
    goto label 2114
    label 2114:
    goto label 2122
    label 2122:
    i_0 = 0
    goto label 2124
    label 2124:
    goto label 2116
    label 2116:
    if (int(i_0) < int(samples_count)) {
        goto label 2118
    } else {
        goto label 2120
    }
    label 2118:
    if (uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::sample_t const?>(sample)))[uint(i_0)])).flag_random_access) != uint64(0)) {
        goto label 2126
    } else {
        goto label 2128
    }
    label 2126:
    var c2da_fresh847 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh847 = uint8(uint8(uint8(uint(int(i_0)) + uint(1) >> uint(8) * uint(3))))
    goto label 2132
    label 2132:
    var c2da_fresh848 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh848 = uint8(uint8(uint8(uint(int(i_0)) + uint(1) >> uint(8) * uint(2))))
    goto label 2134
    label 2134:
    var c2da_fresh849 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh849 = uint8(uint8(uint8(uint(int(i_0)) + uint(1) >> uint(8) * uint(1))))
    goto label 2136
    label 2136:
    var c2da_fresh850 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh850 = uint8(uint8(uint8(uint(int(i_0)) + uint(1) >> uint(8) * uint(0))))
    goto label 2138
    label 2138:
    goto label 2130
    label 2128:
    goto label 2130
    label 2130:
    var c2da_fresh851 : int = i_0
    i_0 = int(i_0) + 1
    goto label 2116
    label 2120:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2140
    label 2140:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2142
    label 2142:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2144
    label 2144:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2146
    label 2146:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2148
    label 2148:
    goto label 2086
    label 2084:
    goto label 2086
    label 2086:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2150
    label 2150:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2152
    label 2152:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2154
    label 2154:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2156
    label 2156:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2158
    label 2158:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2160
    label 2160:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2162
    label 2162:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2164
    label 2164:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2166
    label 2166:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2168
    label 2168:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2170
    label 2170:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2172
    label 2172:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2174
    label 2174:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2176
    label 2176:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2178
    label 2178:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2180
    label 2180:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2182
    label 2182:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2184
    label 2184:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2186
    label 2186:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2188
    label 2188:
    var c2da_fresh852 : uint = uint(uint(ntr_0))
    ntr_0 = uint(uint(uint(uint(ntr_0) + uint(1))))
    goto label 404
    label 408:
    if (unsafe(*mux_6).text_comment != null) {
        goto label 2190
    } else {
        goto label 2192
    }
    label 2190:
    var c2da_fresh853 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh853 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2196
    label 2196:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2198
    label 2198:
    var c2da_fresh854 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh854 = uint8(uint8(uint8(uint(int(BOX_udta)) >> uint(8) * uint(3))))
    goto label 2200
    label 2200:
    var c2da_fresh855 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh855 = uint8(uint8(uint8(uint(int(BOX_udta)) >> uint(8) * uint(2))))
    goto label 2202
    label 2202:
    var c2da_fresh856 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh856 = uint8(uint8(uint8(uint(int(BOX_udta)) >> uint(8) * uint(1))))
    goto label 2204
    label 2204:
    var c2da_fresh857 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh857 = uint8(uint8(uint8(uint(int(BOX_udta)) >> uint(8) * uint(0))))
    goto label 2206
    label 2206:
    var c2da_fresh858 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh858 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2208
    label 2208:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2210
    label 2210:
    var c2da_fresh859 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh859 = uint8(uint8(uint8(uint(int(BOX_meta)) >> uint(8) * uint(3))))
    goto label 2212
    label 2212:
    var c2da_fresh860 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh860 = uint8(uint8(uint8(uint(int(BOX_meta)) >> uint(8) * uint(2))))
    goto label 2214
    label 2214:
    var c2da_fresh861 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh861 = uint8(uint8(uint8(uint(int(BOX_meta)) >> uint(8) * uint(1))))
    goto label 2216
    label 2216:
    var c2da_fresh862 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh862 = uint8(uint8(uint8(uint(int(BOX_meta)) >> uint(8) * uint(0))))
    goto label 2218
    label 2218:
    var c2da_fresh863 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh863 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2220
    label 2220:
    var c2da_fresh864 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh864 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2222
    label 2222:
    var c2da_fresh865 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh865 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2224
    label 2224:
    var c2da_fresh866 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh866 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2226
    label 2226:
    var c2da_fresh867 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh867 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2228
    label 2228:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2230
    label 2230:
    var c2da_fresh868 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh868 = uint8(uint8(uint8(uint(int(BOX_hdlr)) >> uint(8) * uint(3))))
    goto label 2232
    label 2232:
    var c2da_fresh869 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh869 = uint8(uint8(uint8(uint(int(BOX_hdlr)) >> uint(8) * uint(2))))
    goto label 2234
    label 2234:
    var c2da_fresh870 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh870 = uint8(uint8(uint8(uint(int(BOX_hdlr)) >> uint(8) * uint(1))))
    goto label 2236
    label 2236:
    var c2da_fresh871 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh871 = uint8(uint8(uint8(uint(int(BOX_hdlr)) >> uint(8) * uint(0))))
    goto label 2238
    label 2238:
    var c2da_fresh872 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh872 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2240
    label 2240:
    var c2da_fresh873 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh873 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2242
    label 2242:
    var c2da_fresh874 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh874 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2244
    label 2244:
    var c2da_fresh875 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh875 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2246
    label 2246:
    var c2da_fresh876 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh876 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2248
    label 2248:
    var c2da_fresh877 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh877 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2250
    label 2250:
    var c2da_fresh878 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh878 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2252
    label 2252:
    var c2da_fresh879 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh879 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2254
    label 2254:
    var c2da_fresh880 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh880 = uint8(uint8(uint8(uint(1835297138) >> uint(8) * uint(3))))
    goto label 2256
    label 2256:
    var c2da_fresh881 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh881 = uint8(uint8(uint8(uint(1835297138) >> uint(8) * uint(2))))
    goto label 2258
    label 2258:
    var c2da_fresh882 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh882 = uint8(uint8(uint8(uint(1835297138) >> uint(8) * uint(1))))
    goto label 2260
    label 2260:
    var c2da_fresh883 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh883 = uint8(uint8(uint8(uint(1835297138) >> uint(8) * uint(0))))
    goto label 2262
    label 2262:
    var c2da_fresh884 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh884 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2264
    label 2264:
    var c2da_fresh885 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh885 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2266
    label 2266:
    var c2da_fresh886 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh886 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2268
    label 2268:
    var c2da_fresh887 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh887 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2270
    label 2270:
    var c2da_fresh888 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh888 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2272
    label 2272:
    var c2da_fresh889 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh889 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2274
    label 2274:
    var c2da_fresh890 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh890 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2276
    label 2276:
    var c2da_fresh891 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh891 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2278
    label 2278:
    var c2da_fresh892 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh892 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2280
    label 2280:
    var c2da_fresh893 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh893 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2282
    label 2282:
    var c2da_fresh894 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh894 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2284
    label 2284:
    var c2da_fresh895 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh895 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2286
    label 2286:
    var c2da_fresh896 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh896 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2288
    label 2288:
    var c2da_fresh897 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh897 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2290
    label 2290:
    var c2da_fresh898 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh898 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2292
    label 2292:
    var c2da_fresh899 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh899 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2294
    label 2294:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2296
    label 2296:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2298
    label 2298:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2300
    label 2300:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2302
    label 2302:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2304
    label 2304:
    var c2da_fresh900 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh900 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2306
    label 2306:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2308
    label 2308:
    var c2da_fresh901 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh901 = uint8(uint8(uint8(uint(int(BOX_ilst)) >> uint(8) * uint(3))))
    goto label 2310
    label 2310:
    var c2da_fresh902 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh902 = uint8(uint8(uint8(uint(int(BOX_ilst)) >> uint(8) * uint(2))))
    goto label 2312
    label 2312:
    var c2da_fresh903 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh903 = uint8(uint8(uint8(uint(int(BOX_ilst)) >> uint(8) * uint(1))))
    goto label 2314
    label 2314:
    var c2da_fresh904 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh904 = uint8(uint8(uint8(uint(int(BOX_ilst)) >> uint(8) * uint(0))))
    goto label 2316
    label 2316:
    var c2da_fresh905 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh905 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2318
    label 2318:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2320
    label 2320:
    var c2da_fresh906 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh906 = uint8(uint8(uint8(uint(uint(BOX_ccmt)) >> uint(uint(uint(8) * uint(3))))))
    goto label 2322
    label 2322:
    var c2da_fresh907 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh907 = uint8(uint8(uint8(uint(uint(BOX_ccmt)) >> uint(uint(uint(8) * uint(2))))))
    goto label 2324
    label 2324:
    var c2da_fresh908 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh908 = uint8(uint8(uint8(uint(uint(BOX_ccmt)) >> uint(uint(uint(8) * uint(1))))))
    goto label 2326
    label 2326:
    var c2da_fresh909 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh909 = uint8(uint8(uint8(uint(uint(BOX_ccmt)) >> uint(uint(uint(8) * uint(0))))))
    goto label 2328
    label 2328:
    var c2da_fresh910 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh910 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2330
    label 2330:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2332
    label 2332:
    var c2da_fresh911 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh911 = uint8(uint8(uint8(uint(int(BOX_data)) >> uint(8) * uint(3))))
    goto label 2334
    label 2334:
    var c2da_fresh912 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh912 = uint8(uint8(uint8(uint(int(BOX_data)) >> uint(8) * uint(2))))
    goto label 2336
    label 2336:
    var c2da_fresh913 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh913 = uint8(uint8(uint8(uint(int(BOX_data)) >> uint(8) * uint(1))))
    goto label 2338
    label 2338:
    var c2da_fresh914 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh914 = uint8(uint8(uint8(uint(int(BOX_data)) >> uint(8) * uint(0))))
    goto label 2340
    label 2340:
    var c2da_fresh915 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh915 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 2342
    label 2342:
    var c2da_fresh916 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh916 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 2344
    label 2344:
    var c2da_fresh917 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh917 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 2346
    label 2346:
    var c2da_fresh918 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh918 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 2348
    label 2348:
    var c2da_fresh919 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh919 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2350
    label 2350:
    var c2da_fresh920 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh920 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2352
    label 2352:
    var c2da_fresh921 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh921 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2354
    label 2354:
    var c2da_fresh922 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh922 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2356
    label 2356:
    goto label 2364
    label 2364:
    i_0 = 0
    goto label 2366
    label 2366:
    goto label 2358
    label 2358:
    if (int(i_0) < int(c2da_strlen(unsafe(*mux_6).text_comment)) + 1) {
        goto label 2360
    } else {
        goto label 2362
    }
    label 2360:
    var c2da_fresh923 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh923 = uint8(uint8(uint8(uint(int(unsafe(unsafe(unsafe(unsafe(reinterpret<int8?>(unsafe(*mux_6).text_comment)))[uint(i_0)])))) >> uint(8) * uint(0))))
    goto label 2368
    label 2368:
    var c2da_fresh924 : int = i_0
    i_0 = int(i_0) + 1
    goto label 2358
    label 2362:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2370
    label 2370:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2372
    label 2372:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2374
    label 2374:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2376
    label 2376:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2378
    label 2378:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2380
    label 2380:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2382
    label 2382:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2384
    label 2384:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2386
    label 2386:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2388
    label 2388:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2390
    label 2390:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2392
    label 2392:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2394
    label 2394:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2396
    label 2396:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2398
    label 2398:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2400
    label 2400:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2402
    label 2402:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2404
    label 2404:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2406
    label 2406:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2408
    label 2408:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2410
    label 2410:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2412
    label 2412:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2414
    label 2414:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2416
    label 2416:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2418
    label 2418:
    goto label 2194
    label 2192:
    goto label 2194
    label 2194:
    if (uint64(unsafe(*mux_6).enable_fragmentation) != uint64(0)) {
        goto label 2420
    } else {
        goto label 2422
    }
    label 2420:
    var tr_8 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_6).tracks.data)))))), 0, 112))))))))))))))
    goto label 2426
    label 2426:
    var movie_duration : uint = uint(uint(uint(get_duration(tr_8))))
    goto label 2428
    label 2428:
    var c2da_fresh925 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh925 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2430
    label 2430:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2432
    label 2432:
    var c2da_fresh926 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh926 = uint8(uint8(uint8(uint(int(BOX_mvex)) >> uint(8) * uint(3))))
    goto label 2434
    label 2434:
    var c2da_fresh927 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh927 = uint8(uint8(uint8(uint(int(BOX_mvex)) >> uint(8) * uint(2))))
    goto label 2436
    label 2436:
    var c2da_fresh928 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh928 = uint8(uint8(uint8(uint(int(BOX_mvex)) >> uint(8) * uint(1))))
    goto label 2438
    label 2438:
    var c2da_fresh929 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh929 = uint8(uint8(uint8(uint(int(BOX_mvex)) >> uint(8) * uint(0))))
    goto label 2440
    label 2440:
    var c2da_fresh930 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh930 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2442
    label 2442:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2444
    label 2444:
    var c2da_fresh931 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh931 = uint8(uint8(uint8(uint(int(BOX_mehd)) >> uint(8) * uint(3))))
    goto label 2446
    label 2446:
    var c2da_fresh932 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh932 = uint8(uint8(uint8(uint(int(BOX_mehd)) >> uint(8) * uint(2))))
    goto label 2448
    label 2448:
    var c2da_fresh933 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh933 = uint8(uint8(uint8(uint(int(BOX_mehd)) >> uint(8) * uint(1))))
    goto label 2450
    label 2450:
    var c2da_fresh934 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh934 = uint8(uint8(uint8(uint(int(BOX_mehd)) >> uint(8) * uint(0))))
    goto label 2452
    label 2452:
    var c2da_fresh935 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh935 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2454
    label 2454:
    var c2da_fresh936 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh936 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2456
    label 2456:
    var c2da_fresh937 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh937 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2458
    label 2458:
    var c2da_fresh938 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh938 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2460
    label 2460:
    var c2da_fresh939 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh939 = uint8(uint8(uint8(uint(uint(movie_duration)) >> uint(uint(uint(8) * uint(3))))))
    goto label 2462
    label 2462:
    var c2da_fresh940 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh940 = uint8(uint8(uint8(uint(uint(movie_duration)) >> uint(uint(uint(8) * uint(2))))))
    goto label 2464
    label 2464:
    var c2da_fresh941 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh941 = uint8(uint8(uint8(uint(uint(movie_duration)) >> uint(uint(uint(8) * uint(1))))))
    goto label 2466
    label 2466:
    var c2da_fresh942 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh942 = uint8(uint8(uint8(uint(uint(movie_duration)) >> uint(uint(uint(8) * uint(0))))))
    goto label 2468
    label 2468:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2470
    label 2470:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2472
    label 2472:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2474
    label 2474:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2476
    label 2476:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2478
    label 2478:
    goto label 2486
    label 2486:
    ntr_0 = uint(uint(uint(uint(uint(0)))))
    goto label 2488
    label 2488:
    goto label 2480
    label 2480:
    if (uint(ntr_0) < uint(ntracks)) {
        goto label 2482
    } else {
        goto label 2484
    }
    label 2482:
    var c2da_fresh943 : uint8?? = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(stack_0))))))
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 1, 8)))))))))))
    *c2da_fresh943 = unsafe(unsafe(reinterpret<uint8?>(p_5)))
    goto label 2490
    label 2490:
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 4, 1))))))))))))))
    goto label 2492
    label 2492:
    var c2da_fresh944 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh944 = uint8(uint8(uint8(uint(int(BOX_trex)) >> uint(8) * uint(3))))
    goto label 2494
    label 2494:
    var c2da_fresh945 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh945 = uint8(uint8(uint8(uint(int(BOX_trex)) >> uint(8) * uint(2))))
    goto label 2496
    label 2496:
    var c2da_fresh946 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh946 = uint8(uint8(uint8(uint(int(BOX_trex)) >> uint(8) * uint(1))))
    goto label 2498
    label 2498:
    var c2da_fresh947 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh947 = uint8(uint8(uint8(uint(int(BOX_trex)) >> uint(8) * uint(0))))
    goto label 2500
    label 2500:
    var c2da_fresh948 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh948 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2502
    label 2502:
    var c2da_fresh949 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh949 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2504
    label 2504:
    var c2da_fresh950 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh950 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2506
    label 2506:
    var c2da_fresh951 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh951 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2508
    label 2508:
    var c2da_fresh952 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh952 = uint8(uint8(uint8(uint(uint(ntr_0) + uint(uint(1))) >> uint(uint(uint(8) * uint(3))))))
    goto label 2510
    label 2510:
    var c2da_fresh953 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh953 = uint8(uint8(uint8(uint(uint(ntr_0) + uint(uint(1))) >> uint(uint(uint(8) * uint(2))))))
    goto label 2512
    label 2512:
    var c2da_fresh954 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh954 = uint8(uint8(uint8(uint(uint(ntr_0) + uint(uint(1))) >> uint(uint(uint(8) * uint(1))))))
    goto label 2514
    label 2514:
    var c2da_fresh955 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh955 = uint8(uint8(uint8(uint(uint(ntr_0) + uint(uint(1))) >> uint(uint(uint(8) * uint(0))))))
    goto label 2516
    label 2516:
    var c2da_fresh956 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh956 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(3))))
    goto label 2518
    label 2518:
    var c2da_fresh957 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh957 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(2))))
    goto label 2520
    label 2520:
    var c2da_fresh958 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh958 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(1))))
    goto label 2522
    label 2522:
    var c2da_fresh959 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh959 = uint8(uint8(uint8(uint(1) >> uint(8) * uint(0))))
    goto label 2524
    label 2524:
    var c2da_fresh960 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh960 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2526
    label 2526:
    var c2da_fresh961 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh961 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2528
    label 2528:
    var c2da_fresh962 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh962 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2530
    label 2530:
    var c2da_fresh963 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh963 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2532
    label 2532:
    var c2da_fresh964 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh964 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2534
    label 2534:
    var c2da_fresh965 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh965 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2536
    label 2536:
    var c2da_fresh966 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh966 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2538
    label 2538:
    var c2da_fresh967 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh967 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2540
    label 2540:
    var c2da_fresh968 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh968 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(3))))
    goto label 2542
    label 2542:
    var c2da_fresh969 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh969 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(2))))
    goto label 2544
    label 2544:
    var c2da_fresh970 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh970 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(1))))
    goto label 2546
    label 2546:
    var c2da_fresh971 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_5))))))
    p_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_5))), 1, 1)))))))))))
    *c2da_fresh971 = uint8(uint8(uint8(uint(0) >> uint(8) * uint(0))))
    goto label 2548
    label 2548:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2550
    label 2550:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2552
    label 2552:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2554
    label 2554:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2556
    label 2556:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2558
    label 2558:
    var c2da_fresh972 : uint = uint(uint(ntr_0))
    ntr_0 = uint(uint(uint(uint(ntr_0) + uint(1))))
    goto label 2480
    label 2484:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2560
    label 2560:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2562
    label 2562:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2564
    label 2564:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2566
    label 2566:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2568
    label 2568:
    goto label 2424
    label 2422:
    goto label 2424
    label 2424:
    stack_0 = unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(unsafe(reinterpret<uint8??>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(stack_0))), 0 - int(uint64(1)), 8)))))))))))
    goto label 2570
    label 2570:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[0])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(3)))))))))
    goto label 2572
    label 2572:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[1])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(2)))))))))
    goto label 2574
    label 2574:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[2])) = uint8(uint8(uint8(int8(int8(int(int64(unsafe(int64(intptr(p_5)) - int64(intptr(*stack_0))))) >> int(int64(int64(int64(8) * int64(1)))))))))
    goto label 2576
    label 2576:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(*stack_0)))[3])) = uint8(uint8(uint8(int8(int8(unsafe(int(int64(intptr(p_5))) - int(int64(intptr(*stack_0)))))))))
    goto label 2578
    label 2578:
    goto label 2580
    label 2580:
    err_11 = int(int(int(unsafe(*mux_6).write_callback(int64(unsafe(*mux_6).write_pos), unsafe(unsafe(reinterpret<uint64>(base_2))), uint64(uint64(unsafe(uint64(int64(intptr(p_5))) - uint64(int64(intptr(base_2)))))), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_6).token)))))))
    goto label 2582
    label 2582:
    unsafe(*mux_6).write_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mux_6).write_pos))) + unsafe(int64(intptr(p_5)) - int64(intptr(base_2))))
    goto label 2584
    label 2584:
    unsafe(c2da_free(intptr(base_2)))
    goto label 2586
    label 2586:
    return err_11
    return int(0)
}
[export]
def write_pending_data(var mux_3 : minimp4::MP4E_mux_tag?; var tr_3 : minimp4::track_t?) : int {
    if (int(unsafe(*tr_3).pending_sample.bytes) > 0 && uint64(unsafe(*tr_3).smpl.bytes) >= uint64(0x18)) {
        var smpl_desc_0 : minimp4::sample_t? = null
        var base : uint8 [8] = fixed_array<uint8>(uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0))
        var p_2 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(base[0]))))))))))))))
        var c2da_fresh7 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_2))))))
        p_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_2))), 1, 1)))))))))))
        *c2da_fresh7 = uint8(uint8(uint8(uint(int(unsafe(*tr_3).pending_sample.bytes)) + uint(8) >> uint(8) * uint(3))))
        var c2da_fresh8 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_2))))))
        p_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_2))), 1, 1)))))))))))
        *c2da_fresh8 = uint8(uint8(uint8(uint(int(unsafe(*tr_3).pending_sample.bytes)) + uint(8) >> uint(8) * uint(2))))
        var c2da_fresh9 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_2))))))
        p_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_2))), 1, 1)))))))))))
        *c2da_fresh9 = uint8(uint8(uint8(uint(int(unsafe(*tr_3).pending_sample.bytes)) + uint(8) >> uint(8) * uint(1))))
        var c2da_fresh10 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_2))))))
        p_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_2))), 1, 1)))))))))))
        *c2da_fresh10 = uint8(uint8(uint8(uint(int(unsafe(*tr_3).pending_sample.bytes)) + uint(8) >> uint(8) * uint(0))))
        var c2da_fresh11 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_2))))))
        p_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_2))), 1, 1)))))))))))
        *c2da_fresh11 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(3))))
        var c2da_fresh12 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_2))))))
        p_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_2))), 1, 1)))))))))))
        *c2da_fresh12 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(2))))
        var c2da_fresh13 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_2))))))
        p_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_2))), 1, 1)))))))))))
        *c2da_fresh13 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(1))))
        var c2da_fresh14 : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_2))))))
        p_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_2))), 1, 1)))))))))))
        *c2da_fresh14 = uint8(uint8(uint8(uint(int(BOX_mdat)) >> uint(8) * uint(0))))
        var err_7 : int = int(int(int(unsafe(*mux_3).write_callback(int64(unsafe(*mux_3).write_pos), intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base[0]))))), uint64(uint64(unsafe(uint64(int64(intptr(p_2))) - uint64(int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base[0])))))))))), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_3).token)))))))
        if (uint64(err_7) != uint64(0)) {
            return err_7
        }
        unsafe(*mux_3).write_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mux_3).write_pos))) + unsafe(int64(intptr(p_2)) - int64(intptr(unsafe(reinterpret<uint8?>(unsafe(addr(base[0]))))))))
        smpl_desc_0 = unsafe(unsafe(reinterpret<minimp4::sample_t?>(unsafe(unsafe(reinterpret<minimp4::sample_t?>(unsafe(unsafe(reinterpret<minimp4::sample_t?>(unsafe(unsafe(reinterpret<minimp4::sample_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(reinterpret<minimp4::sample_t?>(unsafe(unsafe(reinterpret<uint8?>(minimp4_vector_alloc_tail(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_3).smpl))))), 0))))))))), -1, 24))))))))))))))
        unsafe(*smpl_desc_0).size = uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(*tr_3).pending_sample.bytes))))
        unsafe(*smpl_desc_0).offset = uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_3).write_pos))))
        var err_8 : int = unsafe(*mux_3).write_callback(int64(unsafe(*mux_3).write_pos), unsafe(unsafe(reinterpret<uint64>(unsafe(*tr_3).pending_sample.data))), uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(*tr_3).pending_sample.bytes)))), unsafe(unsafe(reinterpret<uint64>(unsafe(*mux_3).token))))
        if (uint64(err_8) != uint64(0)) {
            return err_8
        }
        unsafe(*mux_3).write_pos = int64(unsafe(unsafe(reinterpret<int64>(unsafe(*mux_3).write_pos))) + unsafe(unsafe(reinterpret<int64>(unsafe(*tr_3).pending_sample.bytes))))
        unsafe(*tr_3).pending_sample.bytes = 0
    }
    return 0
    return int(0)
}
[export]
def sample_to_chunk(var tr_16 : minimp4::MP4D_track_t?; var nsample_0 : uint; var nfirst_sample_in_chunk : uint?) : int {
    var chunk_group : uint = uint(uint(uint(uint(uint(0)))))
    var nc : uint = uint(uint(uint(0)))
    var sum : uint = uint(uint(uint(uint(uint(0)))))
    *nfirst_sample_in_chunk = uint(uint(uint(0)))
    if (uint(unsafe(*tr_16).chunk_count) <= uint(uint(1))) {
        return 0
    }
    nc = uint(uint(uint(uint(uint(0)))))
    while (uint(nc) < uint(unsafe(*tr_16).chunk_count)) {
        if (uint(chunk_group) + uint(uint(1)) < uint(unsafe(*tr_16).sample_to_chunk_count) && uint(nc) + uint(uint(1)) == uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_sample_to_chunk_t_tag?>(unsafe(*tr_16).sample_to_chunk)))[uint(chunk_group) + uint(uint(1))])).first_chunk)) {
            var c2da_fresh1049 : uint = uint(uint(chunk_group))
            chunk_group = uint(uint(uint(uint(chunk_group) + uint(1))))
        }
        sum = uint(uint(uint(uint(sum) + uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_sample_to_chunk_t_tag?>(unsafe(*tr_16).sample_to_chunk)))[uint(chunk_group)])).samples_per_chunk))))
        if (uint(nsample_0) < uint(sum)) {
            return int(nc)
        }
        *nfirst_sample_in_chunk = uint(sum)
        var c2da_fresh1050 : uint = uint(uint(nc))
        nc = uint(uint(uint(uint(nc) + uint(1))))
    }
    return -1
    return int(0)
}
[export]
def patch_pps(var h_8 : minimp4::h264_sps_id_patcher_t?; var bs_16 : minimp4::bit_reader_t?; var bd_2 : minimp4::bs_t?; var new_pps_id : int; var old_id_0 : int?) : int {
    var bytes_5 : int = int(0)
    var pps_id_0 : uint = uint(uint(uint(uint(ue_bits(bs_16)))))
    var sps_id : uint = uint(uint(uint(uint(ue_bits(bs_16)))))
    *old_id_0 = int(pps_id_0)
    sps_id = uint(uint(uint(uint(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(unsafe(addr(unsafe(*h_8).map_sps[0])))))[uint(sps_id)]))))))
    pps_id_0 = uint(uint(uint(uint(new_pps_id))))
    h264e_bs_put_golomb(bd_2, uint(pps_id_0))
    h264e_bs_put_golomb(bd_2, uint(sps_id))
    copy_bits(bs_16, bd_2)
    bytes_5 = int(int(uint(h264e_bs_byte_align(bd_2))) / int(uint(uint(8))))
    h264e_bs_flush(bd_2)
    return bytes_5
    return int(0)
}
[export]
def set_pos_bits(var bs_5 : minimp4::bit_reader_t?; var pos_bits : uint) {
    unsafe(*bs_5).buf = unsafe(unsafe(reinterpret<uint16 const?>(unsafe(unsafe(reinterpret<uint16 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*bs_5).origin))), uint(pos_bits) / uint(uint(16)), 2))))))))
    unsafe(*bs_5).cache = uint(uint(uint(0)))
    unsafe(*bs_5).cache_free_bits = 16
    flush_bits(bs_5, 0)
    flush_bits(bs_5, int(int(uint(pos_bits)) & int(uint(uint(15)))))
}
[export]
def mp4_h26x_write_nal(var h_4 : minimp4::mp4_h26x_writer_tag?; var nal : uint8 const?; var length : int; var timeStamp90kHz_next : uint) : int {
    label 0:
    var eof : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(nal))), int(length), 1))))))))))))))
    goto label 2
    label 2:
    var payload_type : int = int(0)
    goto label 4
    label 4:
    var sizeof_nal : int = int(0)
    goto label 6
    label 6:
    var err : int = 0
    goto label 8
    label 8:
    goto label 10
    label 10:
    goto label 12
    label 12:
    var nal1 : uint8? = null
    goto label 16
    label 16:
    var nal2 : uint8? = null
    goto label 18
    label 18:
    nal = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(find_nal_unit(nal, int(unsafe(int(int64(intptr(eof))) - int(int64(intptr(nal))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(sizeof_nal))))))))))))))))))
    goto label 20
    label 20:
    if (uint64(sizeof_nal) == uint64(0)) {
        goto label 22
    } else {
        goto label 24
    }
    label 22:
    goto label 14
    label 24:
    goto label 26
    label 26:
    if (uint64(unsafe(*h_4).is_hevc) != uint64(0)) {
        goto label 28
    } else {
        goto label 30
    }
    label 28:
    var err_0 : int = mp4_h265_write_nal(h_4, nal, sizeof_nal, uint(timeStamp90kHz_next))
    goto label 34
    label 34:
    if (uint64(err_0) != uint64(0)) {
        goto label 36
    } else {
        goto label 38
    }
    label 36:
    return err_0
    label 38:
    goto label 40
    label 40:
    goto label 10
    label 30:
    goto label 32
    label 32:
    payload_type = int(int(int(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(nal)))[0]))) & 31)))
    goto label 42
    label 42:
    if (9 == int(payload_type)) {
        goto label 44
    } else {
        goto label 46
    }
    label 44:
    goto label 10
    label 46:
    goto label 48
    label 48:
    nal1 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(uint64(int(sizeof_nal)) * uint64(17) / uint64(16) + uint64(32)))))))))))))))))
    goto label 50
    label 50:
    if (nal1 == null) {
        goto label 52
    } else {
        goto label 54
    }
    label 52:
    return -2
    label 54:
    goto label 56
    label 56:
    nal2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(uint64(int(sizeof_nal)) * uint64(17) / uint64(16) + uint64(32)))))))))))))))))
    goto label 58
    label 58:
    if (nal2 == null) {
        goto label 60
    } else {
        goto label 62
    }
    label 60:
    unsafe(c2da_free(intptr(nal1)))
    goto label 66
    label 66:
    return -2
    label 62:
    goto label 64
    label 64:
    sizeof_nal = remove_nal_escapes(nal2, nal, sizeof_nal)
    goto label 68
    label 68:
    if (uint64(sizeof_nal) == uint64(0)) {
        goto label 70
    } else {
        goto label 72
    }
    label 70:
    goto label 42981
    label 42981:
    unsafe(c2da_free(intptr(nal1)))
    goto label 76
    label 76:
    unsafe(c2da_free(intptr(nal2)))
    goto label 78
    label 78:
    return -1
    label 72:
    goto label 74
    label 74:
    sizeof_nal = transcode_nalu(unsafe(unsafe(reinterpret<minimp4::h264_sps_id_patcher_t?>(unsafe(addr(unsafe(*h_4).sps_patcher))))), nal2, sizeof_nal, nal1)
    goto label 80
    label 80:
    sizeof_nal = nal_put_esc(nal2, nal1, sizeof_nal)
    goto label 82
    label 82:
    if (payload_type == 7) {
        goto label 2297
    }
    if (payload_type == 8) {
        goto label 2303
    }
    if (payload_type == 5) {
        goto label 2311
    }
    goto label 2315
    label 2297:
    MP4E_set_sps(unsafe(*h_4).mux, unsafe(*h_4).mux_track_id, intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(nal2))), 4, 1))))), int(sizeof_nal) - 4)
    goto label 88
    label 88:
    unsafe(*h_4).need_sps = 0
    goto label 90
    label 90:
    goto label 84
    label 2303:
    if (uint64(unsafe(*h_4).need_sps) != uint64(0)) {
        goto label 94
    } else {
        goto label 96
    }
    label 94:
    goto label 42981
    label 96:
    goto label 98
    label 98:
    MP4E_set_pps(unsafe(*h_4).mux, unsafe(*h_4).mux_track_id, intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(nal2))), 4, 1))))), int(sizeof_nal) - 4)
    goto label 100
    label 100:
    unsafe(*h_4).need_pps = 0
    goto label 102
    label 102:
    goto label 84
    label 2311:
    if (uint64(unsafe(*h_4).need_sps) != uint64(0)) {
        goto label 106
    } else {
        goto label 108
    }
    label 106:
    goto label 42981
    label 108:
    goto label 110
    label 110:
    unsafe(*h_4).need_idr = 0
    goto label 112
    label 112:
    goto label 2315
    label 2315:
    if (uint64(unsafe(*h_4).need_sps) != uint64(0)) {
        goto label 114
    } else {
        goto label 116
    }
    label 114:
    goto label 42981
    label 116:
    goto label 118
    label 118:
    if (uint64(unsafe(*h_4).need_pps) == uint64(0) && uint64(unsafe(*h_4).need_idr) == uint64(0)) {
        goto label 120
    } else {
        goto label 122
    }
    label 120:
    var bs : minimp4::bit_reader_t [1] = fixed_array<minimp4::bit_reader_t>(minimp4::bit_reader_t())
    goto label 126
    label 126:
    init_bits(unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bs[0]))))), intptr(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(nal))), 1, 1))))), uint(uint(uint(int(sizeof_nal)) - uint(4) - uint(1))))
    goto label 128
    label 128:
    var first_mb_in_slice : uint = uint(uint(uint(uint(ue_bits(unsafe(unsafe(reinterpret<minimp4::bit_reader_t?>(unsafe(addr(bs[0]))))))))))
    goto label 130
    label 130:
    var sample_kind : int = 0
    goto label 132
    label 132:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(nal2)))[0])) = uint8(uint8(uint8(uint(int(sizeof_nal)) - uint(4) >> uint(24))))
    goto label 134
    label 134:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(nal2)))[1])) = uint8(uint8(uint8(uint(int(sizeof_nal)) - uint(4) >> uint(16))))
    goto label 136
    label 136:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(nal2)))[2])) = uint8(uint8(uint8(uint(int(sizeof_nal)) - uint(4) >> uint(8))))
    goto label 138
    label 138:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(nal2)))[3])) = uint8(uint8(uint8(uint(int(sizeof_nal)) - uint(4))))
    goto label 140
    label 140:
    if (uint64(first_mb_in_slice) != uint64(0)) {
        goto label 142
    } else {
        goto label 144
    }
    label 142:
    sample_kind = 2
    goto label 148
    label 148:
    goto label 146
    label 144:
    if (int(payload_type) == 5) {
        goto label 150
    } else {
        goto label 152
    }
    label 150:
    sample_kind = 1
    goto label 156
    label 156:
    goto label 154
    label 152:
    goto label 154
    label 154:
    goto label 146
    label 146:
    err = MP4E_put_sample(unsafe(*h_4).mux, unsafe(*h_4).mux_track_id, unsafe(unsafe(reinterpret<uint64>(nal2))), sizeof_nal, int(timeStamp90kHz_next), sample_kind)
    goto label 158
    label 158:
    goto label 124
    label 122:
    goto label 124
    label 124:
    goto label 84
    label 84:
    unsafe(c2da_free(intptr(nal1)))
    goto label 160
    label 160:
    unsafe(c2da_free(intptr(nal2)))
    goto label 162
    label 162:
    if (uint64(err) != uint64(0)) {
        goto label 164
    } else {
        goto label 166
    }
    label 164:
    goto label 14
    label 166:
    goto label 168
    label 168:
    var c2da_fresh4 : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(nal))))))
    nal = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(nal))), 1, 1)))))))))))
    goto label 10
    label 14:
    return err
    return int(0)
}
[export]
def get_bits(var bs_1 : minimp4::bit_reader_t?; var n : int) : uint {
    var retval : uint = uint(uint(uint(show_bits(bs_1, n))))
    flush_bits(bs_1, n)
    return retval
    return uint(0)
}
[export]
def h264e_bs_flush(var bs_7 : minimp4::bs_t?) {
    *unsafe(*bs_7).buf = uint(uint(uint(unsafe(*bs_7).cache)) >> uint(uint(24)) & uint(uint(255)) | uint(uint(unsafe(*bs_7).cache)) >> uint(uint(8)) & uint(uint(65280)) | uint(uint(unsafe(*bs_7).cache)) << uint(uint(8)) & uint(uint(16711680)) | uint(uint(unsafe(*bs_7).cache) & uint(uint(255))) << uint(uint(24)))
}
[export]
def minimp4_vector_grow(var h_2 : minimp4::minimp4_vector_t?; var bytes_0 : int) : int {
    var p_0 : uint64 = uint64(uint64(unsafe(unsafe(reinterpret<uint64>(null)))))
    var new_size : int = int(unsafe(*h_2).capacity) * 2 + 1024
    if (int(new_size) < int(unsafe(*h_2).capacity) + int(bytes_0)) {
        new_size = int(unsafe(*h_2).capacity) + int(bytes_0) + 1024
    }
    p_0 = uint64(uint64(unsafe(realloc(intptr(unsafe(*h_2).data), uint64(uint64(new_size))))))
    if (uint64(p_0) == uint64(0)) {
        return 0
    }
    unsafe(*h_2).data = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(p_0))))))
    unsafe(*h_2).capacity = new_size
    return 1
    return int(0)
}
[export]
def remove_nal_escapes(var dst_0 : uint8?; var src_0 : uint8 const?; var h264_data_bytes : int) : int {
    var i_8 : int = 0
    var j_0 : int = 0
    var zero_cnt : int = 0
    j_0 = 0
    while (int(j_0) < int(h264_data_bytes)) {
        if (int(zero_cnt) == 2 && int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(src_0)))[uint(j_0)]))) <= 3) {
            if (int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(src_0)))[uint(j_0)]))) == 3) {
                if (int(j_0) == int(h264_data_bytes) - 1) {
                } else {
                    if (int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(src_0)))[int(j_0) + 1]))) <= 3) {
                        var c2da_fresh992 : int = j_0
                        j_0 = int(j_0) + 1
                        zero_cnt = 0
                    } else {
                    }
                }
            } else {
                return 0
            }
        }
        var c2da_fresh993 : int = i_8
        i_8 = int(i_8) + 1
        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dst_0)))[uint(c2da_fresh993)])) = uint8(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(src_0)))[uint(j_0)])))
        if (uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(src_0)))[uint(j_0)]))) != uint64(0)) {
            zero_cnt = 0
        } else {
            var c2da_fresh994 : int = zero_cnt
            zero_cnt = int(zero_cnt) + 1
        }
        var c2da_fresh995 : int = j_0
        j_0 = int(j_0) + 1
    }
    return i_8
    return int(0)
}
[export]
def nal_put_esc(var d : uint8?; var s_0 : uint8 const?; var n_2 : int) : int {
    var i_5 : int = int(0)
    var j : int = 4
    var cntz : int = 0
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d)))[2])) = uint8(uint8(uint8(0)))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d)))[1])) = uint8(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d)))[2])))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d)))[0])) = uint8(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d)))[1])))
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d)))[3])) = uint8(uint8(uint8(1)))
    i_5 = 0
    while (int(i_5) < int(n_2)) {
        var c2da_fresh981 : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(s_0))))))
        s_0 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(s_0))), 1, 1)))))))))))
        var byte : uint8 = uint8(uint8(uint8(*c2da_fresh981)))
        if (int(cntz) == 2 && int(byte) <= 3) {
            var c2da_fresh982 : int = j
            j = int(j) + 1
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d)))[uint(c2da_fresh982)])) = uint8(uint8(uint8(3)))
            cntz = 0
        }
        if (uint64(byte) != uint64(0)) {
            cntz = 0
        } else {
            var c2da_fresh983 : int = cntz
            cntz = int(cntz) + 1
        }
        var c2da_fresh984 : int = j
        j = int(j) + 1
        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d)))[uint(c2da_fresh984)])) = uint8(byte)
        var c2da_fresh985 : int = i_5
        i_5 = int(i_5) + 1
    }
    return j
    return int(0)
}
[export]
def patch_slice_header(var h_7 : minimp4::h264_sps_id_patcher_t?; var bs_11 : minimp4::bit_reader_t?; var bd_0 : minimp4::bs_t?) {
    var first_mb_in_slice_0 : uint = uint(uint(uint(uint(ue_bits(bs_11)))))
    var slice_type : uint = uint(uint(uint(uint(ue_bits(bs_11)))))
    var pps_id : uint = uint(uint(uint(uint(ue_bits(bs_11)))))
    pps_id = uint(uint(uint(uint(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(unsafe(addr(unsafe(*h_7).map_pps[0])))))[uint(pps_id)]))))))
    h264e_bs_put_golomb(bd_0, uint(first_mb_in_slice_0))
    h264e_bs_put_golomb(bd_0, uint(slice_type))
    h264e_bs_put_golomb(bd_0, uint(pps_id))
    copy_bits(bs_11, bd_0)
}
[export]
def MP4E_set_vps(var mux_9 : minimp4::MP4E_mux_tag?; var track_id_1 : int; var vps : uint64; var bytes_8 : int) : int {
    var tr_12 : minimp4::track_t? = unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<minimp4::track_t?>(unsafe(*mux_9).tracks.data)))))), int(track_id_1), 112))))))))))))))
    var c2da_fresh996 : int = int(0)
    if (uint64(append_mem(unsafe(unsafe(reinterpret<minimp4::minimp4_vector_t?>(unsafe(addr(unsafe(*tr_12).vvps))))), vps, bytes_8)) != uint64(0)) {
        c2da_fresh996 = 0
    } else {
        c2da_fresh996 = -2
    }
    return c2da_fresh996
    return int(0)
}
[export]
def ue_bits(var bs_0 : minimp4::bit_reader_t?) : int {
    var clz : int = int(0)
    var val : int = int(0)
    clz = 0
    while (uint64(get_bits(bs_0, 1)) == uint64(0)) {
        var c2da_fresh976 : int = clz
        clz = int(clz) + 1
    }
    var c2da_fresh977 : uint = uint(uint(uint(0)))
    if (uint64(clz) != uint64(0)) {
        c2da_fresh977 = uint(uint(get_bits(bs_0, clz)))
    } else {
        c2da_fresh977 = uint(uint(uint(uint(0))))
    }
    val = int(int(int(int(int(uint((uint(1) << uint(int(clz))) - uint(1))) + int(uint(c2da_fresh977))))))
    return val
    return int(0)
}
[export]
def c2da_probe_minimp4_first_box_eof(var read_callback_3 : function<(var arg0:int64; var arg1:uint64; var arg2:uint64; var arg3:uint64):int>; var token_4 : uint64; var file_size_3 : int64) : int {
    var mp4_12 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var eof_flag_6 : int = 0
    mp4_12 = minimp4::MP4D_demux_tag()
    mp4_12.read_callback = read_callback_3
    mp4_12.token = token_4
    mp4_12.read_size = int64(file_size_3)
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_12))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_6))))))
    minimp4_read(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_12))))), 4, unsafe(unsafe(reinterpret<int?>(unsafe(addr(eof_flag_6))))))
    return eof_flag_6
    return int(0)
}
[export]
def items_count(var v : minimp4::minimp4_vector_t?) : int {
    var i_2 : int = int(0)
    var count : int = 0
    var p_6 : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(*v).data)))))))))
    i_2 = 0
    while (int(i_2) + 2 < int(unsafe(*v).bytes)) {
        var cb : int = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_6)))[uint(i_2)]))) * 256 + int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_6)))[int(i_2) + 1])))
        var c2da_fresh974 : int = count
        count = int(count) + 1
        i_2 = int(i_2) + (2 + int(cb))
    }
    return count
    return int(0)
}
[export]
def h264e_bs_put_bits(var bs_10 : minimp4::bs_t?; var n_3 : uint; var val_0 : uint) {
    unsafe(*bs_10).shift = int(unsafe(*bs_10).shift) - int(n_3)
    if (int(unsafe(*bs_10).shift) < 0) {
        unsafe(*bs_10).cache = uint(uint(unsafe(*bs_10).cache) | uint(uint(val_0)) >> uint(uint(-unsafe(*bs_10).shift)))
        var c2da_fresh986 : uint? = unsafe(unsafe(reinterpret<uint?>(unsafe(unsafe(reinterpret<uint?>(unsafe(*bs_10).buf))))))
        unsafe(*bs_10).buf = unsafe(unsafe(reinterpret<uint?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*bs_10).buf))), 1, 4)))))
        *c2da_fresh986 = uint(uint(uint(unsafe(*bs_10).cache)) >> uint(uint(24)) & uint(uint(255)) | uint(uint(unsafe(*bs_10).cache)) >> uint(uint(8)) & uint(uint(65280)) | uint(uint(unsafe(*bs_10).cache)) << uint(uint(8)) & uint(uint(16711680)) | uint(uint(unsafe(*bs_10).cache) & uint(uint(255))) << uint(uint(24)))
        unsafe(*bs_10).shift = 32 + int(unsafe(*bs_10).shift)
        unsafe(*bs_10).cache = uint(uint(uint(0)))
    }
    unsafe(*bs_10).cache = uint(uint(unsafe(*bs_10).cache) | uint(uint(val_0)) << uint(uint(int(unsafe(*bs_10).shift))))
}
[export]
def mp4_h265_write_nal(var h_9 : minimp4::mp4_h26x_writer_tag?; var nal_0 : uint8 const?; var sizeof_nal_0 : int; var timeStamp90kHz_next_0 : uint) : int {
    label 0:
    var payload_type_1 : int = int(int(int(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(nal_0)))[0]))) >> 1 & 63)))
    goto label 2
    label 2:
    var is_intra : int = int(c2da_bool_to_int(int(payload_type_1) >= 16 && int(payload_type_1) <= 21))
    goto label 4
    label 4:
    var err_14 : int = 0
    goto label 6
    label 6:
    if (uint64(is_intra) != uint64(0) && uint64(unsafe(*h_9).need_sps) == uint64(0) && uint64(unsafe(*h_9).need_pps) == uint64(0) && uint64(unsafe(*h_9).need_vps) == uint64(0)) {
        goto label 8
    } else {
        goto label 10
    }
    label 8:
    unsafe(*h_9).need_idr = 0
    goto label 14
    label 14:
    goto label 12
    label 10:
    goto label 12
    label 12:
    if (payload_type_1 == 32) {
        goto label 47071
    }
    if (payload_type_1 == 33) {
        goto label 47077
    }
    if (payload_type_1 == 34) {
        goto label 47083
    }
    goto label 47089
    label 47071:
    MP4E_set_vps(unsafe(*h_9).mux, unsafe(*h_9).mux_track_id, unsafe(unsafe(reinterpret<uint64>(nal_0))), sizeof_nal_0)
    goto label 20
    label 20:
    unsafe(*h_9).need_vps = 0
    goto label 22
    label 22:
    goto label 16
    label 47077:
    MP4E_set_sps(unsafe(*h_9).mux, unsafe(*h_9).mux_track_id, unsafe(unsafe(reinterpret<uint64>(nal_0))), sizeof_nal_0)
    goto label 26
    label 26:
    unsafe(*h_9).need_sps = 0
    goto label 28
    label 28:
    goto label 16
    label 47083:
    MP4E_set_pps(unsafe(*h_9).mux, unsafe(*h_9).mux_track_id, unsafe(unsafe(reinterpret<uint64>(nal_0))), sizeof_nal_0)
    goto label 32
    label 32:
    unsafe(*h_9).need_pps = 0
    goto label 34
    label 34:
    goto label 16
    label 47089:
    if (uint64(unsafe(*h_9).need_vps) != uint64(0) || uint64(unsafe(*h_9).need_sps) != uint64(0) || uint64(unsafe(*h_9).need_pps) != uint64(0) || uint64(unsafe(*h_9).need_idr) != uint64(0)) {
        goto label 38
    } else {
        goto label 40
    }
    label 38:
    return -1
    label 40:
    goto label 42
    label 42:
    var tmp : uint8? = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(uint64(4) + uint64(int(sizeof_nal_0))))))))))))))))))
    goto label 44
    label 44:
    if (tmp == null) {
        goto label 46
    } else {
        goto label 48
    }
    label 46:
    return -2
    label 48:
    goto label 50
    label 50:
    var sample_kind_0 : int = 0
    goto label 52
    label 52:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(tmp)))[0])) = uint8(uint8(uint8(uint(int(sizeof_nal_0)) >> uint(24))))
    goto label 54
    label 54:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(tmp)))[1])) = uint8(uint8(uint8(uint(int(sizeof_nal_0)) >> uint(16))))
    goto label 56
    label 56:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(tmp)))[2])) = uint8(uint8(uint8(uint(int(sizeof_nal_0)) >> uint(8))))
    goto label 58
    label 58:
    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(tmp)))[3])) = uint8(uint8(sizeof_nal_0))
    goto label 60
    label 60:
    unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(tmp))), 4, 1)))))))), unsafe(unsafe(reinterpret<void?>(intptr(nal_0)))), int(uint64(sizeof_nal_0))))
    goto label 62
    label 62:
    if (uint64(is_intra) != uint64(0)) {
        goto label 64
    } else {
        goto label 66
    }
    label 64:
    sample_kind_0 = 1
    goto label 70
    label 70:
    goto label 68
    label 66:
    goto label 68
    label 68:
    err_14 = MP4E_put_sample(unsafe(*h_9).mux, unsafe(*h_9).mux_track_id, unsafe(unsafe(reinterpret<uint64>(tmp))), 4 + int(sizeof_nal_0), int(timeStamp90kHz_next_0), sample_kind_0)
    goto label 72
    label 72:
    unsafe(c2da_free(intptr(tmp)))
    goto label 74
    label 74:
    goto label 16
    label 16:
    return err_14
    return int(0)
}
[export]
def append_mem(var v_0 : minimp4::minimp4_vector_t?; var mem : uint64; var bytes_3 : int) : int {
    var i_4 : int = int(0)
    var size_2 : uint8 [2] = fixed_array<uint8>(uint8(0), uint8(0))
    var p_7 : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(*v_0).data)))))))))
    i_4 = 0
    while (int(i_4) + 2 < int(unsafe(*v_0).bytes)) {
        var cb_0 : int = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_7)))[uint(i_4)]))) * 256 + int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_7)))[int(i_4) + 1])))
        if (int(cb_0) == int(bytes_3) && uint64(unsafe(memcmp(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_7))), int(i_4), 1)))))))), 2, 1)))))))), unsafe(unsafe(reinterpret<void?>(mem))), int(uint64(cb_0))))) == uint64(0)) {
            return 1
        }
        i_4 = int(i_4) + (2 + int(cb_0))
    }
    unsafe(size_2[0]) = uint8(uint8(uint8(uint(int(bytes_3)) >> uint(8))))
    unsafe(size_2[1]) = uint8(uint8(bytes_3))
    return int(c2da_bool_to_int(unsafe(unsafe(reinterpret<uint8?>(minimp4_vector_put(v_0, intptr(unsafe(reinterpret<uint8?>(unsafe(addr(size_2[0]))))), 2)))) != null && unsafe(unsafe(reinterpret<uint8?>(minimp4_vector_put(v_0, mem, bytes_3)))) != null))
    return int(0)
}
[export]
def minimp4_vector_init(var h_0 : minimp4::minimp4_vector_t?; var capacity : int) : int {
    unsafe(*h_0).bytes = 0
    unsafe(*h_0).capacity = capacity
    var c2da_fresh1 : uint8? = null
    if (uint64(capacity) != uint64(0)) {
        c2da_fresh1 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(capacity)))))))))))))
    } else {
        c2da_fresh1 = null
    }
    unsafe(*h_0).data = unsafe(unsafe(reinterpret<uint8?>(c2da_fresh1)))
    return int(c2da_bool_to_int(uint64(capacity) == uint64(0) || !(unsafe(*h_0).data == null)))
    return int(0)
}
[export]
def find_start_code(var h264_data_0 : uint8 const?; var h264_data_bytes_1 : int; var zcount_0 : int?) : uint8 const? {
    var eof_1 : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(h264_data_0))), int(h264_data_bytes_1), 1))))))))))))))
    var p_8 : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(h264_data_0)))))))))
    while (true) {
        var zero_cnt_0 : int = 1
        var found : uint8 const? = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_memchr(unsafe(unsafe(reinterpret<void?>(intptr(p_8)))), 0, int(uint64(unsafe(uint64(int64(intptr(eof_1))) - uint64(int64(intptr(p_8))))))))))))))))))))))
        var c2da_fresh998 : uint8 const? = null
        if (found != null) {
            c2da_fresh998 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(found))))))
        } else {
            c2da_fresh998 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(eof_1))))))
        }
        p_8 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(c2da_fresh998)))))))))
        while (unsafe(intptr(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_8))), int(zero_cnt_0), 1))))) < intptr(eof_1)) && uint64(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_8)))[uint(zero_cnt_0)]))) == uint64(0)) {
            var c2da_fresh999 : int = zero_cnt_0
            zero_cnt_0 = int(zero_cnt_0) + 1
        }
        if (int(zero_cnt_0) >= 2 && int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(p_8)))[uint(zero_cnt_0)]))) == 1) {
            *zcount_0 = int(zero_cnt_0) + 1
            return unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_8))), int(zero_cnt_0), 1)))))))), 1, 1))))))))
        }
        p_8 = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(p_8))), zero_cnt_0, 1))))))))))))))
        if (!(unsafe(intptr(p_8) < intptr(eof_1)))) {
            break
        }
    }
    *zcount_0 = 0
    return unsafe(unsafe(reinterpret<uint8 const?>(eof_1)))
    return unsafe(unsafe(reinterpret<uint8 const?>(null)))
}