options gen2

require shim
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
typedef plm_audio_decode_callback = function<(arg0:plm_t?; arg1:plm_samples_t?; arg2:uint64):void>
struct plm_samples_t {
    time : double
    count : uint
    interleaved : array<float>
}
typedef plm_video_decode_callback = function<(arg0:plm_t?; arg1:plm_frame_t?; arg2:uint64):void>
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
    bit_index : uint64
    capacity : uint64
    length : uint64
    total_size : uint64
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
typedef plm_buffer_tell_callback = function<(arg0:plm_buffer_t?; arg1:uint64):uint64>
typedef plm_buffer_seek_callback = function<(arg0:plm_buffer_t?; arg1:uint64; arg2:uint64):void>
typedef plm_buffer_load_callback = function<(arg0:plm_buffer_t?; arg1:uint64):void>
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
    last_file_size : uint64
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
    length : uint64
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
var PLM_VIDEO_MACROBLOCK_TYPE_PREDICTIVE : array<plm_vlc_t> const = [plm_vlc_t(index = int16(1 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(2 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(3 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(4 << 1), value = int16(0)), plm_vlc_t(index = int16(5 << 1), value = int16(0)), plm_vlc_t(index = int16(6 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(18)), plm_vlc_t(index = int16(0), value = int16(26)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(17))]

var PLM_VIDEO_PICTURE_RATE : array<double> const = [double(0.0), double(23.976), double(24.0), double(25.0), double(29.97), double(30.0), double(50.0), double(59.94), double(60.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0), double(0.0)]

var PLM_DEMUX_PACKET_AUDIO_4 : int const = int(195)

var PLM_AUDIO_SCALEFACTOR_BASE : array<int> const = [33554432, 26632170, 21137968]

var PLM_VIDEO_DCT_SIZE_CHROMINANCE : array<plm_vlc_t> const = [plm_vlc_t(index = int16(1 << 1), value = int16(0)), plm_vlc_t(index = int16(2 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(3 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(4 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(5 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(6 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(7 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(8 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(-1), value = int16(0))]

var PLM_VIDEO_DCT_SIZE_LUMINANCE : array<plm_vlc_t> const = [plm_vlc_t(index = int16(1 << 1), value = int16(0)), plm_vlc_t(index = int16(2 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(3 << 1), value = int16(0)), plm_vlc_t(index = int16(4 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(5 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(6 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(7 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(8 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(-1), value = int16(0))]

var PLM_VIDEO_DCT_SIZE : array<plm_vlc_t const?> = [unsafe(addr(PLM_VIDEO_DCT_SIZE_LUMINANCE[0])), unsafe(addr(PLM_VIDEO_DCT_SIZE_CHROMINANCE[0])), unsafe(addr(PLM_VIDEO_DCT_SIZE_CHROMINANCE[0]))]

var PLM_VIDEO_MACROBLOCK_TYPE_INTRA : array<plm_vlc_t> const = [plm_vlc_t(index = int16(1 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(17))]

var PLM_VIDEO_PICTURE_TYPE_INTRA : int const = int(1)

var PLM_AUDIO_MODE_JOINT_STEREO : int const = int(1)

var PLM_AUDIO_SYNTHESIS_WINDOW : array<float> const = [float(double(0.0)), float(-double(0.5)), float(-double(0.5)), float(-double(0.5)), float(-double(0.5)), float(-double(0.5)), float(-double(0.5)), float(-double(1.0)), float(-double(1.0)), float(-double(1.0)), float(-double(1.0)), float(-double(1.5)), float(-double(1.5)), float(-double(2.0)), float(-double(2.0)), float(-double(2.5)), float(-double(2.5)), float(-double(3.0)), float(-double(3.5)), float(-double(3.5)), float(-double(4.0)), float(-double(4.5)), float(-double(5.0)), float(-double(5.5)), float(-double(6.5)), float(-double(7.0)), float(-double(8.0)), float(-double(8.5)), float(-double(9.5)), float(-double(10.5)), float(-double(12.0)), float(-double(13.0)), float(-double(14.5)), float(-double(15.5)), float(-double(17.5)), float(-double(19.0)), float(-double(20.5)), float(-double(22.5)), float(-double(24.5)), float(-double(26.5)), float(-double(29.0)), float(-double(31.5)), float(-double(34.0)), float(-double(36.5)), float(-double(39.5)), float(-double(42.5)), float(-double(45.5)), float(-double(48.5)), float(-double(52.0)), float(-double(55.5)), float(-double(58.5)), float(-double(62.5)), float(-double(66.0)), float(-double(69.5)), float(-double(73.5)), float(-double(77.0)), float(-double(80.5)), float(-double(84.5)), float(-double(88.0)), float(-double(91.5)), float(-double(95.0)), float(-double(98.0)), float(-double(101.0)), float(-double(104.0)), float(double(106.5)), float(double(109.0)), float(double(111.0)), float(double(112.5)), float(double(113.5)), float(double(114.0)), float(double(114.0)), float(double(113.5)), float(double(112.0)), float(double(110.5)), float(double(107.5)), float(double(104.0)), float(double(100.0)), float(double(94.5)), float(double(88.5)), float(double(81.5)), float(double(73.0)), float(double(63.5)), float(double(53.0)), float(double(41.5)), float(double(28.5)), float(double(14.5)), float(-double(1.0)), float(-double(18.0)), float(-double(36.0)), float(-double(55.5)), float(-double(76.5)), float(-double(98.5)), float(-double(122.0)), float(-double(147.0)), float(-double(173.5)), float(-double(200.5)), float(-double(229.5)), float(-double(259.5)), float(-double(290.5)), float(-double(322.5)), float(-double(355.5)), float(-double(389.5)), float(-double(424.0)), float(-double(459.5)), float(-double(495.5)), float(-double(532.0)), float(-double(568.5)), float(-double(605.0)), float(-double(641.5)), float(-double(678.0)), float(-double(714.0)), float(-double(749.0)), float(-double(783.5)), float(-double(817.0)), float(-double(849.0)), float(-double(879.5)), float(-double(908.5)), float(-double(935.0)), float(-double(959.5)), float(-double(981.0)), float(-double(1000.5)), float(-double(1016.0)), float(-double(1028.5)), float(-double(1037.5)), float(-double(1042.5)), float(-double(1043.5)), float(-double(1040.0)), float(-double(1031.5)), float(double(1018.5)), float(double(1000.0)), float(double(976.0)), float(double(946.5)), float(double(911.0)), float(double(869.5)), float(double(822.0)), float(double(767.5)), float(double(707.0)), float(double(640.0)), float(double(565.5)), float(double(485.0)), float(double(397.0)), float(double(302.5)), float(double(201.0)), float(double(92.5)), float(-double(22.5)), float(-double(144.0)), float(-double(272.5)), float(-double(407.0)), float(-double(547.5)), float(-double(694.0)), float(-double(846.0)), float(-double(1003.0)), float(-double(1165.0)), float(-double(1331.5)), float(-double(1502.0)), float(-double(1675.5)), float(-double(1852.5)), float(-double(2031.5)), float(-double(2212.5)), float(-double(2394.0)), float(-double(2576.5)), float(-double(2758.5)), float(-double(2939.5)), float(-double(3118.5)), float(-double(3294.5)), float(-double(3467.5)), float(-double(3635.5)), float(-double(3798.5)), float(-double(3955.0)), float(-double(4104.5)), float(-double(4245.5)), float(-double(4377.5)), float(-double(4499.0)), float(-double(4609.5)), float(-double(4708.0)), float(-double(4792.5)), float(-double(4863.5)), float(-double(4919.0)), float(-double(4958.0)), float(-double(4979.5)), float(-double(4983.0)), float(-double(4967.5)), float(-double(4931.5)), float(-double(4875.0)), float(-double(4796.0)), float(-double(4694.5)), float(-double(4569.5)), float(-double(4420.0)), float(-double(4246.0)), float(-double(4046.0)), float(-double(3820.0)), float(-double(3567.0)), float(double(3287.0)), float(double(2979.5)), float(double(2644.0)), float(double(2280.5)), float(double(1888.0)), float(double(1467.5)), float(double(1018.5)), float(double(541.0)), float(double(35.0)), float(-double(499.0)), float(-double(1061.0)), float(-double(1650.0)), float(-double(2266.5)), float(-double(2909.0)), float(-double(3577.0)), float(-double(4270.0)), float(-double(4987.5)), float(-double(5727.5)), float(-double(6490.0)), float(-double(7274.0)), float(-double(8077.5)), float(-double(8899.5)), float(-double(9739.0)), float(-double(10594.5)), float(-double(11464.5)), float(-double(12347.0)), float(-double(13241.0)), float(-double(14144.5)), float(-double(15056.0)), float(-double(15973.5)), float(-double(16895.5)), float(-double(17820.0)), float(-double(18744.5)), float(-double(19668.0)), float(-double(20588.0)), float(-double(21503.0)), float(-double(22410.5)), float(-double(23308.5)), float(-double(24195.0)), float(-double(25068.5)), float(-double(25926.5)), float(-double(26767.0)), float(-double(27589.0)), float(-double(28389.0)), float(-double(29166.5)), float(-double(29919.0)), float(-double(30644.5)), float(-double(31342.0)), float(-double(32009.5)), float(-double(32645.0)), float(-double(33247.0)), float(-double(33814.5)), float(-double(34346.0)), float(-double(34839.5)), float(-double(35295.0)), float(-double(35710.0)), float(-double(36084.5)), float(-double(36417.5)), float(-double(36707.5)), float(-double(36954.0)), float(-double(37156.5)), float(-double(37315.0)), float(-double(37428.0)), float(-double(37496.0)), float(double(37519.0)), float(double(37496.0)), float(double(37428.0)), float(double(37315.0)), float(double(37156.5)), float(double(36954.0)), float(double(36707.5)), float(double(36417.5)), float(double(36084.5)), float(double(35710.0)), float(double(35295.0)), float(double(34839.5)), float(double(34346.0)), float(double(33814.5)), float(double(33247.0)), float(double(32645.0)), float(double(32009.5)), float(double(31342.0)), float(double(30644.5)), float(double(29919.0)), float(double(29166.5)), float(double(28389.0)), float(double(27589.0)), float(double(26767.0)), float(double(25926.5)), float(double(25068.5)), float(double(24195.0)), float(double(23308.5)), float(double(22410.5)), float(double(21503.0)), float(double(20588.0)), float(double(19668.0)), float(double(18744.5)), float(double(17820.0)), float(double(16895.5)), float(double(15973.5)), float(double(15056.0)), float(double(14144.5)), float(double(13241.0)), float(double(12347.0)), float(double(11464.5)), float(double(10594.5)), float(double(9739.0)), float(double(8899.5)), float(double(8077.5)), float(double(7274.0)), float(double(6490.0)), float(double(5727.5)), float(double(4987.5)), float(double(4270.0)), float(double(3577.0)), float(double(2909.0)), float(double(2266.5)), float(double(1650.0)), float(double(1061.0)), float(double(499.0)), float(-double(35.0)), float(-double(541.0)), float(-double(1018.5)), float(-double(1467.5)), float(-double(1888.0)), float(-double(2280.5)), float(-double(2644.0)), float(-double(2979.5)), float(double(3287.0)), float(double(3567.0)), float(double(3820.0)), float(double(4046.0)), float(double(4246.0)), float(double(4420.0)), float(double(4569.5)), float(double(4694.5)), float(double(4796.0)), float(double(4875.0)), float(double(4931.5)), float(double(4967.5)), float(double(4983.0)), float(double(4979.5)), float(double(4958.0)), float(double(4919.0)), float(double(4863.5)), float(double(4792.5)), float(double(4708.0)), float(double(4609.5)), float(double(4499.0)), float(double(4377.5)), float(double(4245.5)), float(double(4104.5)), float(double(3955.0)), float(double(3798.5)), float(double(3635.5)), float(double(3467.5)), float(double(3294.5)), float(double(3118.5)), float(double(2939.5)), float(double(2758.5)), float(double(2576.5)), float(double(2394.0)), float(double(2212.5)), float(double(2031.5)), float(double(1852.5)), float(double(1675.5)), float(double(1502.0)), float(double(1331.5)), float(double(1165.0)), float(double(1003.0)), float(double(846.0)), float(double(694.0)), float(double(547.5)), float(double(407.0)), float(double(272.5)), float(double(144.0)), float(double(22.5)), float(-double(92.5)), float(-double(201.0)), float(-double(302.5)), float(-double(397.0)), float(-double(485.0)), float(-double(565.5)), float(-double(640.0)), float(-double(707.0)), float(-double(767.5)), float(-double(822.0)), float(-double(869.5)), float(-double(911.0)), float(-double(946.5)), float(-double(976.0)), float(-double(1000.0)), float(double(1018.5)), float(double(1031.5)), float(double(1040.0)), float(double(1043.5)), float(double(1042.5)), float(double(1037.5)), float(double(1028.5)), float(double(1016.0)), float(double(1000.5)), float(double(981.0)), float(double(959.5)), float(double(935.0)), float(double(908.5)), float(double(879.5)), float(double(849.0)), float(double(817.0)), float(double(783.5)), float(double(749.0)), float(double(714.0)), float(double(678.0)), float(double(641.5)), float(double(605.0)), float(double(568.5)), float(double(532.0)), float(double(495.5)), float(double(459.5)), float(double(424.0)), float(double(389.5)), float(double(355.5)), float(double(322.5)), float(double(290.5)), float(double(259.5)), float(double(229.5)), float(double(200.5)), float(double(173.5)), float(double(147.0)), float(double(122.0)), float(double(98.5)), float(double(76.5)), float(double(55.5)), float(double(36.0)), float(double(18.0)), float(double(1.0)), float(-double(14.5)), float(-double(28.5)), float(-double(41.5)), float(-double(53.0)), float(-double(63.5)), float(-double(73.0)), float(-double(81.5)), float(-double(88.5)), float(-double(94.5)), float(-double(100.0)), float(-double(104.0)), float(-double(107.5)), float(-double(110.5)), float(-double(112.0)), float(-double(113.5)), float(-double(114.0)), float(-double(114.0)), float(-double(113.5)), float(-double(112.5)), float(-double(111.0)), float(-double(109.0)), float(double(106.5)), float(double(104.0)), float(double(101.0)), float(double(98.0)), float(double(95.0)), float(double(91.5)), float(double(88.0)), float(double(84.5)), float(double(80.5)), float(double(77.0)), float(double(73.5)), float(double(69.5)), float(double(66.0)), float(double(62.5)), float(double(58.5)), float(double(55.5)), float(double(52.0)), float(double(48.5)), float(double(45.5)), float(double(42.5)), float(double(39.5)), float(double(36.5)), float(double(34.0)), float(double(31.5)), float(double(29.0)), float(double(26.5)), float(double(24.5)), float(double(22.5)), float(double(20.5)), float(double(19.0)), float(double(17.5)), float(double(15.5)), float(double(14.5)), float(double(13.0)), float(double(12.0)), float(double(10.5)), float(double(9.5)), float(double(8.5)), float(double(8.0)), float(double(7.0)), float(double(6.5)), float(double(5.5)), float(double(5.0)), float(double(4.5)), float(double(4.0)), float(double(3.5)), float(double(3.5)), float(double(3.0)), float(double(2.5)), float(double(2.5)), float(double(2.0)), float(double(2.0)), float(double(1.5)), float(double(1.5)), float(double(1.0)), float(double(1.0)), float(double(1.0)), float(double(1.0)), float(double(0.5)), float(double(0.5)), float(double(0.5)), float(double(0.5)), float(double(0.5)), float(double(0.5))]

var PLM_VIDEO_ZIG_ZAG : array<uint8> const = [uint8(0), uint8(1), uint8(8), uint8(16), uint8(9), uint8(2), uint8(3), uint8(10), uint8(17), uint8(24), uint8(32), uint8(25), uint8(18), uint8(11), uint8(4), uint8(5), uint8(12), uint8(19), uint8(26), uint8(33), uint8(40), uint8(48), uint8(41), uint8(34), uint8(27), uint8(20), uint8(13), uint8(6), uint8(7), uint8(14), uint8(21), uint8(28), uint8(35), uint8(42), uint8(49), uint8(56), uint8(57), uint8(50), uint8(43), uint8(36), uint8(29), uint8(22), uint8(15), uint8(23), uint8(30), uint8(37), uint8(44), uint8(51), uint8(58), uint8(59), uint8(52), uint8(45), uint8(38), uint8(31), uint8(39), uint8(46), uint8(53), uint8(60), uint8(61), uint8(54), uint8(47), uint8(55), uint8(62), uint8(63)]

var PLM_AUDIO_QUANT_TAB : array<plm_quantizer_spec_t> const = [plm_quantizer_spec_t(levels = 3, group = uint8(1), bits = uint8(5)), plm_quantizer_spec_t(levels = 5, group = uint8(1), bits = uint8(7)), plm_quantizer_spec_t(levels = 7, group = uint8(0), bits = uint8(3)), plm_quantizer_spec_t(levels = 9, group = uint8(1), bits = uint8(10)), plm_quantizer_spec_t(levels = 15, group = uint8(0), bits = uint8(4)), plm_quantizer_spec_t(levels = 31, group = uint8(0), bits = uint8(5)), plm_quantizer_spec_t(levels = 63, group = uint8(0), bits = uint8(6)), plm_quantizer_spec_t(levels = 127, group = uint8(0), bits = uint8(7)), plm_quantizer_spec_t(levels = 255, group = uint8(0), bits = uint8(8)), plm_quantizer_spec_t(levels = 511, group = uint8(0), bits = uint8(9)), plm_quantizer_spec_t(levels = 1023, group = uint8(0), bits = uint8(10)), plm_quantizer_spec_t(levels = 2047, group = uint8(0), bits = uint8(11)), plm_quantizer_spec_t(levels = 4095, group = uint8(0), bits = uint8(12)), plm_quantizer_spec_t(levels = 8191, group = uint8(0), bits = uint8(13)), plm_quantizer_spec_t(levels = 16383, group = uint8(0), bits = uint8(14)), plm_quantizer_spec_t(levels = 32767, group = uint8(0), bits = uint8(15)), plm_quantizer_spec_t(levels = 65535, group = uint8(0), bits = uint8(16))]

var QUANT_LUT_STEP_2 : array<array<uint8>> const = [[uint8(8), uint8(8), uint8(12)], [uint8(27 | 64), uint8(27 | 64), uint8(27 | 64)], [uint8(30 | 64), uint8(27 | 64), uint8(30 | 64)]]

var PLM_START_SLICE_FIRST : int const = int(1)

var PLM_START_PACK : int const = int(186)

var PLM_BUFFER_MODE_APPEND : int = 3

var PLM_BUFFER_MODE_RING : int = 2

var PLM_VIDEO_PREMULTIPLIER_MATRIX : array<uint8> const = [uint8(32), uint8(44), uint8(42), uint8(38), uint8(32), uint8(25), uint8(17), uint8(9), uint8(44), uint8(62), uint8(58), uint8(52), uint8(44), uint8(35), uint8(24), uint8(12), uint8(42), uint8(58), uint8(55), uint8(49), uint8(42), uint8(33), uint8(23), uint8(12), uint8(38), uint8(52), uint8(49), uint8(44), uint8(38), uint8(30), uint8(20), uint8(10), uint8(32), uint8(44), uint8(42), uint8(38), uint8(32), uint8(25), uint8(17), uint8(9), uint8(25), uint8(35), uint8(33), uint8(30), uint8(25), uint8(20), uint8(14), uint8(7), uint8(17), uint8(24), uint8(23), uint8(20), uint8(17), uint8(14), uint8(9), uint8(5), uint8(9), uint8(12), uint8(12), uint8(10), uint8(9), uint8(7), uint8(5), uint8(2)]

var PLM_AUDIO_MPEG_1 : int const = int(3)

var PLM_VIDEO_MACROBLOCK_TYPE_B : array<plm_vlc_t> const = [plm_vlc_t(index = int16(1 << 1), value = int16(0)), plm_vlc_t(index = int16(2 << 1), value = int16(0)), plm_vlc_t(index = int16(3 << 1), value = int16(0)), plm_vlc_t(index = int16(4 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(12)), plm_vlc_t(index = int16(0), value = int16(14)), plm_vlc_t(index = int16(5 << 1), value = int16(0)), plm_vlc_t(index = int16(6 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(7 << 1), value = int16(0)), plm_vlc_t(index = int16(8 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(9 << 1), value = int16(0)), plm_vlc_t(index = int16(10 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(30)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(17)), plm_vlc_t(index = int16(0), value = int16(22)), plm_vlc_t(index = int16(0), value = int16(26))]

var PLM_AUDIO_QUANT_LUT_STEP_4 : array<array<uint8>> const = [[uint8(0), uint8(1), uint8(2), uint8(17)], [uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(6), uint8(17)], [uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(17)], [uint8(0), uint8(1), uint8(3), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(15), uint8(16), uint8(17)], [uint8(0), uint8(1), uint8(2), uint8(4), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(15), uint8(17)], [uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(15)]]

var PLM_DEMUX_PACKET_VIDEO_1 : int const = int(224)

var PLM_VIDEO_MOTION : array<plm_vlc_t> const = [plm_vlc_t(index = int16(1 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(0)), plm_vlc_t(index = int16(2 << 1), value = int16(0)), plm_vlc_t(index = int16(3 << 1), value = int16(0)), plm_vlc_t(index = int16(4 << 1), value = int16(0)), plm_vlc_t(index = int16(5 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(0), value = int16(-1)), plm_vlc_t(index = int16(6 << 1), value = int16(0)), plm_vlc_t(index = int16(7 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(0), value = int16(-2)), plm_vlc_t(index = int16(8 << 1), value = int16(0)), plm_vlc_t(index = int16(9 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(0), value = int16(-3)), plm_vlc_t(index = int16(10 << 1), value = int16(0)), plm_vlc_t(index = int16(11 << 1), value = int16(0)), plm_vlc_t(index = int16(12 << 1), value = int16(0)), plm_vlc_t(index = int16(13 << 1), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(14 << 1), value = int16(0)), plm_vlc_t(index = int16(15 << 1), value = int16(0)), plm_vlc_t(index = int16(16 << 1), value = int16(0)), plm_vlc_t(index = int16(17 << 1), value = int16(0)), plm_vlc_t(index = int16(18 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(0), value = int16(-4)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(19 << 1), value = int16(0)), plm_vlc_t(index = int16(20 << 1), value = int16(0)), plm_vlc_t(index = int16(21 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(0), value = int16(-7)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(0), value = int16(-6)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(0), value = int16(-5)), plm_vlc_t(index = int16(22 << 1), value = int16(0)), plm_vlc_t(index = int16(23 << 1), value = int16(0)), plm_vlc_t(index = int16(24 << 1), value = int16(0)), plm_vlc_t(index = int16(25 << 1), value = int16(0)), plm_vlc_t(index = int16(26 << 1), value = int16(0)), plm_vlc_t(index = int16(27 << 1), value = int16(0)), plm_vlc_t(index = int16(28 << 1), value = int16(0)), plm_vlc_t(index = int16(29 << 1), value = int16(0)), plm_vlc_t(index = int16(30 << 1), value = int16(0)), plm_vlc_t(index = int16(31 << 1), value = int16(0)), plm_vlc_t(index = int16(32 << 1), value = int16(0)), plm_vlc_t(index = int16(33 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(0), value = int16(-10)), plm_vlc_t(index = int16(0), value = int16(9)), plm_vlc_t(index = int16(0), value = int16(-9)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(0), value = int16(-8)), plm_vlc_t(index = int16(0), value = int16(16)), plm_vlc_t(index = int16(0), value = int16(-16)), plm_vlc_t(index = int16(0), value = int16(15)), plm_vlc_t(index = int16(0), value = int16(-15)), plm_vlc_t(index = int16(0), value = int16(14)), plm_vlc_t(index = int16(0), value = int16(-14)), plm_vlc_t(index = int16(0), value = int16(13)), plm_vlc_t(index = int16(0), value = int16(-13)), plm_vlc_t(index = int16(0), value = int16(12)), plm_vlc_t(index = int16(0), value = int16(-12)), plm_vlc_t(index = int16(0), value = int16(11)), plm_vlc_t(index = int16(0), value = int16(-11))]

var PLM_BUFFER_MODE_FIXED_MEM : int = 1

var PLM_START_SYSTEM : int const = int(187)

var PLM_AUDIO_MODE_MONO : int const = int(3)

var PLM_AUDIO_LAYER_II : int const = int(2)

var PLM_START_SLICE_LAST : int const = int(175)

var PLM_AUDIO_QUANT_LUT_STEP_3 : array<array<uint8>> const = [[uint8(68), uint8(68), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52)], [uint8(67), uint8(67), uint8(67), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(32), uint8(32), uint8(32), uint8(32), uint8(32), uint8(32), uint8(32)], [uint8(69), uint8(69), uint8(69), uint8(69), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(52), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36), uint8(36)]]

var PLM_VIDEO_NON_INTRA_QUANT_MATRIX : array<uint8> const = [uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16), uint8(16)]

var PLM_VIDEO_INTRA_QUANT_MATRIX : array<uint8> const = [uint8(8), uint8(16), uint8(19), uint8(22), uint8(26), uint8(27), uint8(29), uint8(34), uint8(16), uint8(16), uint8(22), uint8(24), uint8(27), uint8(29), uint8(34), uint8(37), uint8(19), uint8(22), uint8(26), uint8(27), uint8(29), uint8(34), uint8(34), uint8(38), uint8(22), uint8(22), uint8(26), uint8(27), uint8(29), uint8(34), uint8(37), uint8(40), uint8(22), uint8(26), uint8(27), uint8(29), uint8(32), uint8(35), uint8(40), uint8(48), uint8(26), uint8(27), uint8(29), uint8(32), uint8(35), uint8(40), uint8(48), uint8(58), uint8(26), uint8(27), uint8(29), uint8(34), uint8(38), uint8(46), uint8(56), uint8(69), uint8(27), uint8(29), uint8(35), uint8(38), uint8(46), uint8(56), uint8(69), uint8(83)]

var PLM_AUDIO_QUANT_LUT_STEP_1 : array<array<uint8>> const = [[uint8(0), uint8(0), uint8(1), uint8(1), uint8(1), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2)], [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(1), uint8(1), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2)]]

var PLM_AUDIO_FRAME_SYNC : int const = int(2047)

var PLM_VIDEO_PICTURE_TYPE_PREDICTIVE : int const = int(2)

var PLM_VIDEO_PICTURE_TYPE_B : int const = int(3)

var PLM_START_USER_DATA : int const = int(178)

var PLM_DEMUX_PACKET_PRIVATE : int const = int(189)

var PLM_VIDEO_CODE_BLOCK_PATTERN : array<plm_vlc_t> const = [plm_vlc_t(index = int16(1 << 1), value = int16(0)), plm_vlc_t(index = int16(2 << 1), value = int16(0)), plm_vlc_t(index = int16(3 << 1), value = int16(0)), plm_vlc_t(index = int16(4 << 1), value = int16(0)), plm_vlc_t(index = int16(5 << 1), value = int16(0)), plm_vlc_t(index = int16(6 << 1), value = int16(0)), plm_vlc_t(index = int16(7 << 1), value = int16(0)), plm_vlc_t(index = int16(8 << 1), value = int16(0)), plm_vlc_t(index = int16(9 << 1), value = int16(0)), plm_vlc_t(index = int16(10 << 1), value = int16(0)), plm_vlc_t(index = int16(11 << 1), value = int16(0)), plm_vlc_t(index = int16(12 << 1), value = int16(0)), plm_vlc_t(index = int16(13 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(60)), plm_vlc_t(index = int16(14 << 1), value = int16(0)), plm_vlc_t(index = int16(15 << 1), value = int16(0)), plm_vlc_t(index = int16(16 << 1), value = int16(0)), plm_vlc_t(index = int16(17 << 1), value = int16(0)), plm_vlc_t(index = int16(18 << 1), value = int16(0)), plm_vlc_t(index = int16(19 << 1), value = int16(0)), plm_vlc_t(index = int16(20 << 1), value = int16(0)), plm_vlc_t(index = int16(21 << 1), value = int16(0)), plm_vlc_t(index = int16(22 << 1), value = int16(0)), plm_vlc_t(index = int16(23 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(32)), plm_vlc_t(index = int16(0), value = int16(16)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(24 << 1), value = int16(0)), plm_vlc_t(index = int16(25 << 1), value = int16(0)), plm_vlc_t(index = int16(26 << 1), value = int16(0)), plm_vlc_t(index = int16(27 << 1), value = int16(0)), plm_vlc_t(index = int16(28 << 1), value = int16(0)), plm_vlc_t(index = int16(29 << 1), value = int16(0)), plm_vlc_t(index = int16(30 << 1), value = int16(0)), plm_vlc_t(index = int16(31 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(62)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(0), value = int16(61)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(0), value = int16(56)), plm_vlc_t(index = int16(0), value = int16(52)), plm_vlc_t(index = int16(0), value = int16(44)), plm_vlc_t(index = int16(0), value = int16(28)), plm_vlc_t(index = int16(0), value = int16(40)), plm_vlc_t(index = int16(0), value = int16(20)), plm_vlc_t(index = int16(0), value = int16(48)), plm_vlc_t(index = int16(0), value = int16(12)), plm_vlc_t(index = int16(32 << 1), value = int16(0)), plm_vlc_t(index = int16(33 << 1), value = int16(0)), plm_vlc_t(index = int16(34 << 1), value = int16(0)), plm_vlc_t(index = int16(35 << 1), value = int16(0)), plm_vlc_t(index = int16(36 << 1), value = int16(0)), plm_vlc_t(index = int16(37 << 1), value = int16(0)), plm_vlc_t(index = int16(38 << 1), value = int16(0)), plm_vlc_t(index = int16(39 << 1), value = int16(0)), plm_vlc_t(index = int16(40 << 1), value = int16(0)), plm_vlc_t(index = int16(41 << 1), value = int16(0)), plm_vlc_t(index = int16(42 << 1), value = int16(0)), plm_vlc_t(index = int16(43 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(63)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(0), value = int16(36)), plm_vlc_t(index = int16(0), value = int16(24)), plm_vlc_t(index = int16(44 << 1), value = int16(0)), plm_vlc_t(index = int16(45 << 1), value = int16(0)), plm_vlc_t(index = int16(46 << 1), value = int16(0)), plm_vlc_t(index = int16(47 << 1), value = int16(0)), plm_vlc_t(index = int16(48 << 1), value = int16(0)), plm_vlc_t(index = int16(49 << 1), value = int16(0)), plm_vlc_t(index = int16(50 << 1), value = int16(0)), plm_vlc_t(index = int16(51 << 1), value = int16(0)), plm_vlc_t(index = int16(52 << 1), value = int16(0)), plm_vlc_t(index = int16(53 << 1), value = int16(0)), plm_vlc_t(index = int16(54 << 1), value = int16(0)), plm_vlc_t(index = int16(55 << 1), value = int16(0)), plm_vlc_t(index = int16(56 << 1), value = int16(0)), plm_vlc_t(index = int16(57 << 1), value = int16(0)), plm_vlc_t(index = int16(58 << 1), value = int16(0)), plm_vlc_t(index = int16(59 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(34)), plm_vlc_t(index = int16(0), value = int16(18)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(0), value = int16(33)), plm_vlc_t(index = int16(0), value = int16(17)), plm_vlc_t(index = int16(0), value = int16(9)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(60 << 1), value = int16(0)), plm_vlc_t(index = int16(61 << 1), value = int16(0)), plm_vlc_t(index = int16(62 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(58)), plm_vlc_t(index = int16(0), value = int16(54)), plm_vlc_t(index = int16(0), value = int16(46)), plm_vlc_t(index = int16(0), value = int16(30)), plm_vlc_t(index = int16(0), value = int16(57)), plm_vlc_t(index = int16(0), value = int16(53)), plm_vlc_t(index = int16(0), value = int16(45)), plm_vlc_t(index = int16(0), value = int16(29)), plm_vlc_t(index = int16(0), value = int16(38)), plm_vlc_t(index = int16(0), value = int16(26)), plm_vlc_t(index = int16(0), value = int16(37)), plm_vlc_t(index = int16(0), value = int16(25)), plm_vlc_t(index = int16(0), value = int16(43)), plm_vlc_t(index = int16(0), value = int16(23)), plm_vlc_t(index = int16(0), value = int16(51)), plm_vlc_t(index = int16(0), value = int16(15)), plm_vlc_t(index = int16(0), value = int16(42)), plm_vlc_t(index = int16(0), value = int16(22)), plm_vlc_t(index = int16(0), value = int16(50)), plm_vlc_t(index = int16(0), value = int16(14)), plm_vlc_t(index = int16(0), value = int16(41)), plm_vlc_t(index = int16(0), value = int16(21)), plm_vlc_t(index = int16(0), value = int16(49)), plm_vlc_t(index = int16(0), value = int16(13)), plm_vlc_t(index = int16(0), value = int16(35)), plm_vlc_t(index = int16(0), value = int16(19)), plm_vlc_t(index = int16(0), value = int16(11)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(0), value = int16(39)), plm_vlc_t(index = int16(0), value = int16(27)), plm_vlc_t(index = int16(0), value = int16(59)), plm_vlc_t(index = int16(0), value = int16(55)), plm_vlc_t(index = int16(0), value = int16(47)), plm_vlc_t(index = int16(0), value = int16(31))]

var PLM_START_PICTURE : int const = int(0)

var PLM_AUDIO_SAMPLE_RATE : array<int> const = [44100, 48000, 32000, int(0), 22050, 24000, 16000, int(0)]

var PLM_BUFFER_MODE_FILE : int = 0

var PLM_VIDEO_PIXEL_ASPECT_RATIO : array<float> const = [float(double(1.0)), float(double(0.6735)), float(double(0.7031)), float(double(0.7615)), float(double(0.8055)), float(double(0.8437)), float(double(0.8935)), float(double(0.9157)), float(double(0.9815)), float(double(1.0255)), float(double(1.0695)), float(double(1.095)), float(double(1.1575)), float(double(1.2051))]

var PLM_START_SEQUENCE : int const = int(179)

var PLM_DEMUX_PACKET_AUDIO_1 : int const = int(192)

var PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT : array<plm_vlc_t> const = [plm_vlc_t(index = int16(1 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(1)), plm_vlc_t(index = int16(2 << 1), value = int16(0)), plm_vlc_t(index = int16(3 << 1), value = int16(0)), plm_vlc_t(index = int16(4 << 1), value = int16(0)), plm_vlc_t(index = int16(5 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(3)), plm_vlc_t(index = int16(0), value = int16(2)), plm_vlc_t(index = int16(6 << 1), value = int16(0)), plm_vlc_t(index = int16(7 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(5)), plm_vlc_t(index = int16(0), value = int16(4)), plm_vlc_t(index = int16(8 << 1), value = int16(0)), plm_vlc_t(index = int16(9 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(7)), plm_vlc_t(index = int16(0), value = int16(6)), plm_vlc_t(index = int16(10 << 1), value = int16(0)), plm_vlc_t(index = int16(11 << 1), value = int16(0)), plm_vlc_t(index = int16(12 << 1), value = int16(0)), plm_vlc_t(index = int16(13 << 1), value = int16(0)), plm_vlc_t(index = int16(14 << 1), value = int16(0)), plm_vlc_t(index = int16(15 << 1), value = int16(0)), plm_vlc_t(index = int16(16 << 1), value = int16(0)), plm_vlc_t(index = int16(17 << 1), value = int16(0)), plm_vlc_t(index = int16(18 << 1), value = int16(0)), plm_vlc_t(index = int16(19 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(9)), plm_vlc_t(index = int16(0), value = int16(8)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(20 << 1), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(21 << 1), value = int16(0)), plm_vlc_t(index = int16(22 << 1), value = int16(0)), plm_vlc_t(index = int16(23 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(15)), plm_vlc_t(index = int16(0), value = int16(14)), plm_vlc_t(index = int16(0), value = int16(13)), plm_vlc_t(index = int16(0), value = int16(12)), plm_vlc_t(index = int16(0), value = int16(11)), plm_vlc_t(index = int16(0), value = int16(10)), plm_vlc_t(index = int16(24 << 1), value = int16(0)), plm_vlc_t(index = int16(25 << 1), value = int16(0)), plm_vlc_t(index = int16(26 << 1), value = int16(0)), plm_vlc_t(index = int16(27 << 1), value = int16(0)), plm_vlc_t(index = int16(28 << 1), value = int16(0)), plm_vlc_t(index = int16(29 << 1), value = int16(0)), plm_vlc_t(index = int16(30 << 1), value = int16(0)), plm_vlc_t(index = int16(31 << 1), value = int16(0)), plm_vlc_t(index = int16(32 << 1), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(33 << 1), value = int16(0)), plm_vlc_t(index = int16(34 << 1), value = int16(0)), plm_vlc_t(index = int16(35 << 1), value = int16(0)), plm_vlc_t(index = int16(36 << 1), value = int16(0)), plm_vlc_t(index = int16(37 << 1), value = int16(0)), plm_vlc_t(index = int16(38 << 1), value = int16(0)), plm_vlc_t(index = int16(39 << 1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(21)), plm_vlc_t(index = int16(0), value = int16(20)), plm_vlc_t(index = int16(0), value = int16(19)), plm_vlc_t(index = int16(0), value = int16(18)), plm_vlc_t(index = int16(0), value = int16(17)), plm_vlc_t(index = int16(0), value = int16(16)), plm_vlc_t(index = int16(0), value = int16(35)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(-1), value = int16(0)), plm_vlc_t(index = int16(0), value = int16(34)), plm_vlc_t(index = int16(0), value = int16(33)), plm_vlc_t(index = int16(0), value = int16(32)), plm_vlc_t(index = int16(0), value = int16(31)), plm_vlc_t(index = int16(0), value = int16(30)), plm_vlc_t(index = int16(0), value = int16(29)), plm_vlc_t(index = int16(0), value = int16(28)), plm_vlc_t(index = int16(0), value = int16(27)), plm_vlc_t(index = int16(0), value = int16(26)), plm_vlc_t(index = int16(0), value = int16(25)), plm_vlc_t(index = int16(0), value = int16(24)), plm_vlc_t(index = int16(0), value = int16(23)), plm_vlc_t(index = int16(0), value = int16(22))]

var PLM_VIDEO_DCT_COEFF : array<plm_vlc_uint_t> const = [plm_vlc_uint_t(index = int16(1 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(1)), plm_vlc_uint_t(index = int16(2 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(3 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(4 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(5 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(6 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(257)), plm_vlc_uint_t(index = int16(7 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(8 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(9 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(10 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(2)), plm_vlc_uint_t(index = int16(0), value = uint16(513)), plm_vlc_uint_t(index = int16(11 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(12 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(13 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(14 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(15 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(3)), plm_vlc_uint_t(index = int16(0), value = uint16(1025)), plm_vlc_uint_t(index = int16(0), value = uint16(769)), plm_vlc_uint_t(index = int16(16 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(65535)), plm_vlc_uint_t(index = int16(17 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(18 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(1793)), plm_vlc_uint_t(index = int16(0), value = uint16(1537)), plm_vlc_uint_t(index = int16(0), value = uint16(258)), plm_vlc_uint_t(index = int16(0), value = uint16(1281)), plm_vlc_uint_t(index = int16(19 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(20 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(21 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(22 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(514)), plm_vlc_uint_t(index = int16(0), value = uint16(2305)), plm_vlc_uint_t(index = int16(0), value = uint16(4)), plm_vlc_uint_t(index = int16(0), value = uint16(2049)), plm_vlc_uint_t(index = int16(23 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(24 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(25 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(26 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(27 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(28 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(29 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(30 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(3329)), plm_vlc_uint_t(index = int16(0), value = uint16(6)), plm_vlc_uint_t(index = int16(0), value = uint16(3073)), plm_vlc_uint_t(index = int16(0), value = uint16(2817)), plm_vlc_uint_t(index = int16(0), value = uint16(770)), plm_vlc_uint_t(index = int16(0), value = uint16(259)), plm_vlc_uint_t(index = int16(0), value = uint16(5)), plm_vlc_uint_t(index = int16(0), value = uint16(2561)), plm_vlc_uint_t(index = int16(31 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(32 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(33 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(34 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(35 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(36 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(37 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(38 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(39 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(40 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(41 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(42 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(43 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(44 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(45 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(46 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(4097)), plm_vlc_uint_t(index = int16(0), value = uint16(1282)), plm_vlc_uint_t(index = int16(0), value = uint16(7)), plm_vlc_uint_t(index = int16(0), value = uint16(515)), plm_vlc_uint_t(index = int16(0), value = uint16(260)), plm_vlc_uint_t(index = int16(0), value = uint16(3841)), plm_vlc_uint_t(index = int16(0), value = uint16(3585)), plm_vlc_uint_t(index = int16(0), value = uint16(1026)), plm_vlc_uint_t(index = int16(47 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(48 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(49 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(50 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(51 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(52 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(53 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(54 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(55 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(56 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(57 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(58 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(59 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(60 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(61 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(62 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(-1), value = uint16(0)), plm_vlc_uint_t(index = int16(63 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(64 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(65 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(66 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(67 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(68 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(69 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(70 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(71 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(72 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(73 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(74 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(75 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(76 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(77 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(11)), plm_vlc_uint_t(index = int16(0), value = uint16(2050)), plm_vlc_uint_t(index = int16(0), value = uint16(1027)), plm_vlc_uint_t(index = int16(0), value = uint16(10)), plm_vlc_uint_t(index = int16(0), value = uint16(516)), plm_vlc_uint_t(index = int16(0), value = uint16(1794)), plm_vlc_uint_t(index = int16(0), value = uint16(5377)), plm_vlc_uint_t(index = int16(0), value = uint16(5121)), plm_vlc_uint_t(index = int16(0), value = uint16(9)), plm_vlc_uint_t(index = int16(0), value = uint16(4865)), plm_vlc_uint_t(index = int16(0), value = uint16(4609)), plm_vlc_uint_t(index = int16(0), value = uint16(261)), plm_vlc_uint_t(index = int16(0), value = uint16(771)), plm_vlc_uint_t(index = int16(0), value = uint16(8)), plm_vlc_uint_t(index = int16(0), value = uint16(1538)), plm_vlc_uint_t(index = int16(0), value = uint16(4353)), plm_vlc_uint_t(index = int16(78 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(79 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(80 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(81 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(82 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(83 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(84 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(85 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(86 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(87 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(88 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(89 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(90 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(91 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(2562)), plm_vlc_uint_t(index = int16(0), value = uint16(2306)), plm_vlc_uint_t(index = int16(0), value = uint16(1283)), plm_vlc_uint_t(index = int16(0), value = uint16(772)), plm_vlc_uint_t(index = int16(0), value = uint16(517)), plm_vlc_uint_t(index = int16(0), value = uint16(263)), plm_vlc_uint_t(index = int16(0), value = uint16(262)), plm_vlc_uint_t(index = int16(0), value = uint16(15)), plm_vlc_uint_t(index = int16(0), value = uint16(14)), plm_vlc_uint_t(index = int16(0), value = uint16(13)), plm_vlc_uint_t(index = int16(0), value = uint16(12)), plm_vlc_uint_t(index = int16(0), value = uint16(6657)), plm_vlc_uint_t(index = int16(0), value = uint16(6401)), plm_vlc_uint_t(index = int16(0), value = uint16(6145)), plm_vlc_uint_t(index = int16(0), value = uint16(5889)), plm_vlc_uint_t(index = int16(0), value = uint16(5633)), plm_vlc_uint_t(index = int16(92 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(93 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(94 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(95 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(96 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(97 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(98 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(99 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(100 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(101 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(102 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(103 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(31)), plm_vlc_uint_t(index = int16(0), value = uint16(30)), plm_vlc_uint_t(index = int16(0), value = uint16(29)), plm_vlc_uint_t(index = int16(0), value = uint16(28)), plm_vlc_uint_t(index = int16(0), value = uint16(27)), plm_vlc_uint_t(index = int16(0), value = uint16(26)), plm_vlc_uint_t(index = int16(0), value = uint16(25)), plm_vlc_uint_t(index = int16(0), value = uint16(24)), plm_vlc_uint_t(index = int16(0), value = uint16(23)), plm_vlc_uint_t(index = int16(0), value = uint16(22)), plm_vlc_uint_t(index = int16(0), value = uint16(21)), plm_vlc_uint_t(index = int16(0), value = uint16(20)), plm_vlc_uint_t(index = int16(0), value = uint16(19)), plm_vlc_uint_t(index = int16(0), value = uint16(18)), plm_vlc_uint_t(index = int16(0), value = uint16(17)), plm_vlc_uint_t(index = int16(0), value = uint16(16)), plm_vlc_uint_t(index = int16(104 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(105 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(106 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(107 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(108 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(109 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(110 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(111 << 1), value = uint16(0)), plm_vlc_uint_t(index = int16(0), value = uint16(40)), plm_vlc_uint_t(index = int16(0), value = uint16(39)), plm_vlc_uint_t(index = int16(0), value = uint16(38)), plm_vlc_uint_t(index = int16(0), value = uint16(37)), plm_vlc_uint_t(index = int16(0), value = uint16(36)), plm_vlc_uint_t(index = int16(0), value = uint16(35)), plm_vlc_uint_t(index = int16(0), value = uint16(34)), plm_vlc_uint_t(index = int16(0), value = uint16(33)), plm_vlc_uint_t(index = int16(0), value = uint16(32)), plm_vlc_uint_t(index = int16(0), value = uint16(270)), plm_vlc_uint_t(index = int16(0), value = uint16(269)), plm_vlc_uint_t(index = int16(0), value = uint16(268)), plm_vlc_uint_t(index = int16(0), value = uint16(267)), plm_vlc_uint_t(index = int16(0), value = uint16(266)), plm_vlc_uint_t(index = int16(0), value = uint16(265)), plm_vlc_uint_t(index = int16(0), value = uint16(264)), plm_vlc_uint_t(index = int16(0), value = uint16(274)), plm_vlc_uint_t(index = int16(0), value = uint16(273)), plm_vlc_uint_t(index = int16(0), value = uint16(272)), plm_vlc_uint_t(index = int16(0), value = uint16(271)), plm_vlc_uint_t(index = int16(0), value = uint16(1539)), plm_vlc_uint_t(index = int16(0), value = uint16(4098)), plm_vlc_uint_t(index = int16(0), value = uint16(3842)), plm_vlc_uint_t(index = int16(0), value = uint16(3586)), plm_vlc_uint_t(index = int16(0), value = uint16(3330)), plm_vlc_uint_t(index = int16(0), value = uint16(3074)), plm_vlc_uint_t(index = int16(0), value = uint16(2818)), plm_vlc_uint_t(index = int16(0), value = uint16(7937)), plm_vlc_uint_t(index = int16(0), value = uint16(7681)), plm_vlc_uint_t(index = int16(0), value = uint16(7425)), plm_vlc_uint_t(index = int16(0), value = uint16(7169)), plm_vlc_uint_t(index = int16(0), value = uint16(6913))]

var PLM_AUDIO_BIT_RATE : array<int> const = [32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160]

var PLM_VIDEO_MACROBLOCK_TYPE : array<plm_vlc_t const?> = [unsafe(unsafe(reinterpret<plm_vlc_t const?>(0x0))), unsafe(addr(PLM_VIDEO_MACROBLOCK_TYPE_INTRA[0])), unsafe(addr(PLM_VIDEO_MACROBLOCK_TYPE_PREDICTIVE[0])), unsafe(addr(PLM_VIDEO_MACROBLOCK_TYPE_B[0]))]

var PLM_START_EXTENSION : int const = int(181)

[export]
def plm_demux_get_duration(var self_67 : plm_demux_t?; var type_1 : int) : double {
    var file_size : uint64 = uint64(uint64(uint64(0)))
    var previous_pos_0 : uint64 = uint64(uint64(uint64(0)))
    var previous_start_code : int = int(0)
    var start_range : int64 = int64(int64(int64(0)))
    var max_range : int64 = int64(int64(int64(0)))
    var range_0 : int64 = int64(int64(int64(0)))
    var seek_pos : int64 = int64(int64(int64(0)))
    var last_pts : double = double(0)
    var packet_0 : plm_packet_t? = null
    file_size = uint64(uint64(uint64(plm_buffer_get_size(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_67.buffer)))))))
    if (double(self_67.duration) != double(-1) && uint64(self_67.last_file_size) == uint64(file_size)) {
        return self_67.duration
    } else {
        previous_pos_0 = uint64(uint64(uint64(plm_buffer_tell(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_67.buffer)))))))
        previous_start_code = self_67.start_code
        start_range = int64(int64(int64(int64(int64(64) * int64(1024)))))
        max_range = int64(int64(int64(int64(int64(4096) * int64(1024)))))
        range_0 = int64(int64(int64(start_range)))
        while (true) {
            if (!(int64(range_0) <= int64(max_range))) {
                break
            }
            seek_pos = int64(int64(int64(int64(int64(uint64(file_size)) - int64(uint64(range_0))))))
            if (int64(seek_pos) < int64(0)) {
                seek_pos = int64(int64(int64(int64(0))))
                range_0 = int64(int64(int64(max_range)))
            }
            plm_demux_buffer_seek(unsafe(unsafe(reinterpret<plm_demux_t?>(self_67))), uint64(uint64(seek_pos)))
            self_67.current_packet.length = uint64(uint64(0))
            last_pts = double(-1)
            packet_0 = null
            while (true) {
                packet_0 = unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode(unsafe(unsafe(reinterpret<plm_demux_t?>(self_67))))))))))))))))
                if (!(packet_0 != null)) {
                    break
                }
                if (double(packet_0.pts) != double(-1) && int(packet_0.type_0) == int(type_1)) {
                    last_pts = packet_0.pts
                }
            }
            if (double(last_pts) != double(-1)) {
                self_67.duration = double(last_pts) - double(plm_demux_get_start_time(unsafe(unsafe(reinterpret<plm_demux_t?>(self_67))), type_1))
                break
            } else {
                range_0 = int64(int64(int64(int64(range_0) * int64(2))))
            }
        }
        plm_demux_buffer_seek(unsafe(unsafe(reinterpret<plm_demux_t?>(self_67))), uint64(previous_pos_0))
        self_67.start_code = previous_start_code
        self_67.last_file_size = uint64(file_size)
        return self_67.duration
    }
    return double(0)
}
[export]
def plm_get_width(var self_49 : plm_t?) : int {
    var c2da_fresh8 : int = int(0)
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_49))))) != uint64(0) && self_49.video_decoder != null) {
        c2da_fresh8 = plm_video_get_width(unsafe(unsafe(reinterpret<plm_video_t?>(self_49.video_decoder))))
    } else {
        c2da_fresh8 = 0
    }
    return c2da_fresh8
    return int(0)
}
[export]
def plm_set_audio_stream(var self_60 : plm_t?; var stream_index : int) {
    if (int(stream_index) < 0 || int(stream_index) > 3) {
        return
    } else {
        self_60.audio_stream_index = stream_index
        plm_set_audio_enabled(unsafe(unsafe(reinterpret<plm_t?>(self_60))), self_60.audio_enabled)
        return
    }
}
[export]
def plm_video_decode_sequence_header(var self_28 : plm_video_t?) : int {
    var max_header_size : int = int(0)
    var pixel_aspect_ratio_code : int = int(0)
    var par_last : int = int(0)
    var i_0 : int = int(0)
    var idx : int = int(0)
    var i_1 : int = int(0)
    var idx_0 : int = int(0)
    var luma_plane_size : uint64 = uint64(uint64(uint64(0)))
    var chroma_plane_size : uint64 = uint64(uint64(uint64(0)))
    var frame_data_size : uint64 = uint64(uint64(uint64(0)))
    max_header_size = 64 + 2 * 64 * 8
    if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), uint64(uint64(max_header_size)))) == uint64(0)) {
        return 0
    } else {
        self_28.width = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), 12)
        self_28.height = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), 12)
        if (int(self_28.width) <= 0 || int(self_28.height) <= 0) {
            return 0
        } else {
            pixel_aspect_ratio_code = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), 4)
            pixel_aspect_ratio_code = int(pixel_aspect_ratio_code) - 1
            if (int(pixel_aspect_ratio_code) < 0) {
                pixel_aspect_ratio_code = 0
            }
            par_last = int(int(int(uint64(int(uint64(int(uint64(int(uint64(int(uint64(4)))))))) / int(uint64(int(uint64(int(uint64(int(uint64(4)))))))))) - int(uint64(1))))
            if (int(pixel_aspect_ratio_code) > int(par_last)) {
                pixel_aspect_ratio_code = par_last
            }
            self_28.pixel_aspect_ratio = double(unsafe(unsafe(unsafe(addr(PLM_VIDEO_PIXEL_ASPECT_RATIO[0]))[uint(pixel_aspect_ratio_code)])))
            self_28.framerate = unsafe(unsafe(unsafe(addr(PLM_VIDEO_PICTURE_RATE[0]))[uint(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), 4))]))
            plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), uint64(uint64(uint64(18) + uint64(1) + uint64(10) + uint64(1))))
            if (uint64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), 1)) != uint64(0)) {
                i_0 = 0
                while (true) {
                    if (!(int(i_0) < 64)) {
                        break
                    }
                    idx = int(unsafe(unsafe(unsafe(addr(PLM_VIDEO_ZIG_ZAG[0]))[uint(i_0)])))
                    unsafe(unsafe(unsafe(addr(self_28.intra_quant_matrix[0]))[uint(idx)])) = uint8(uint8(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), 8)))
                    i_0 = int(i_0) + 1
                    i_0
                }
            } else {
                unsafe(memcpy(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_28.intra_quant_matrix[0])))))), uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(PLM_VIDEO_INTRA_QUANT_MATRIX[0])))))), uint64(uint64(64))))
            }
            if (uint64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), 1)) != uint64(0)) {
                i_1 = 0
                while (true) {
                    if (!(int(i_1) < 64)) {
                        break
                    }
                    idx_0 = int(unsafe(unsafe(unsafe(addr(PLM_VIDEO_ZIG_ZAG[0]))[uint(i_1)])))
                    unsafe(unsafe(unsafe(addr(self_28.non_intra_quant_matrix[0]))[uint(idx_0)])) = uint8(uint8(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_28.buffer))), 8)))
                    i_1 = int(i_1) + 1
                    i_1
                }
            } else {
                unsafe(memcpy(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_28.non_intra_quant_matrix[0])))))), uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(PLM_VIDEO_NON_INTRA_QUANT_MATRIX[0])))))), uint64(uint64(64))))
            }
            self_28.mb_width = int(int(self_28.width) + 15 >> 4)
            self_28.mb_height = int(int(self_28.height) + 15 >> 4)
            self_28.mb_size = int(self_28.mb_width) * int(self_28.mb_height)
            self_28.luma_width = int(int(self_28.mb_width) << 4)
            self_28.luma_height = int(int(self_28.mb_height) << 4)
            self_28.chroma_width = int(int(self_28.mb_width) << 3)
            self_28.chroma_height = int(int(self_28.mb_height) << 3)
            luma_plane_size = uint64(uint64(uint64(uint64(uint64(int(self_28.luma_width)) * uint64(int(self_28.luma_height))))))
            chroma_plane_size = uint64(uint64(uint64(uint64(uint64(int(self_28.chroma_width)) * uint64(int(self_28.chroma_height))))))
            frame_data_size = uint64(uint64(uint64(uint64(luma_plane_size) + uint64(2) * uint64(chroma_plane_size))))
            self_28.frames_data = unsafe(unsafe(reinterpret<uint8?>(c2da_malloc(uint64(uint64(frame_data_size) * uint64(3))))))
            plm_video_init_frame(unsafe(unsafe(reinterpret<plm_video_t?>(self_28))), unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_28.frame_current))))), unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(self_28.frames_data))), uint64(frame_data_size) * uint64(0), 1)))))))))
            plm_video_init_frame(unsafe(unsafe(reinterpret<plm_video_t?>(self_28))), unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_28.frame_forward))))), unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(self_28.frames_data))), uint64(frame_data_size) * uint64(1), 1)))))))))
            plm_video_init_frame(unsafe(unsafe(reinterpret<plm_video_t?>(self_28))), unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_28.frame_backward))))), unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(self_28.frames_data))), uint64(frame_data_size) * uint64(2), 1)))))))))
            self_28.has_sequence_header = 1
            return 1
        }
    }
    return int(0)
}
[export]
def plm_video_get_time(var self_102 : plm_video_t?) : double {
    return self_102.time
    return double(0)
}
[export]
def plm_audio_has_ended(var self_115 : plm_audio_t?) : int {
    return plm_buffer_has_ended(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_115.buffer))))
    return int(0)
}
[export]
def plm_audio_read_allocation(var self_85 : plm_audio_t?; var sb_7 : int; var tab3_0 : int) : plm_quantizer_spec_t const? {
    var tab4 : int = int(0)
    var qtab : int = int(0)
    tab4 = int(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(PLM_AUDIO_QUANT_LUT_STEP_3[0]))[uint(tab3_0)]))[0])))[uint(sb_7)])))
    qtab = int(int(int(int(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(PLM_AUDIO_QUANT_LUT_STEP_4[0]))[int(tab4) & 15]))[0])))[uint(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_85.buffer))), int(int(tab4) >> 4)))]))))))
    var c2da_fresh22 : plm_quantizer_spec_t const? = null
    if (uint64(qtab) != uint64(0)) {
        c2da_fresh22 = unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(addr(unsafe(unsafe(unsafe(addr(PLM_AUDIO_QUANT_TAB[0]))[int(qtab) - 1]))))))))))
    } else {
        c2da_fresh22 = null
    }
    return unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(c2da_fresh22)))
    return null
}
[export]
def plm_get_samplerate(var self_61 : plm_t?) : int {
    var c2da_fresh17 : int = int(0)
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_61))))) != uint64(0) && self_61.audio_decoder != null) {
        c2da_fresh17 = plm_audio_get_samplerate(unsafe(unsafe(reinterpret<plm_audio_t?>(self_61.audio_decoder))))
    } else {
        c2da_fresh17 = 0
    }
    return c2da_fresh17
    return int(0)
}
[export]
def plm_demux_decode(var self_17 : plm_demux_t?) : plm_packet_t? {
    var bits_till_next_packet : uint64 = uint64(uint64(uint64(0)))
    if (uint64(plm_demux_has_headers(unsafe(unsafe(reinterpret<plm_demux_t?>(self_17))))) == uint64(0)) {
        return null
    } else {
        if (uint64(self_17.current_packet.length) != uint64(0)) {
            bits_till_next_packet = uint64(uint64(uint64(uint64(self_17.current_packet.length) << uint64(3))))
            if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_17.buffer))), uint64(bits_till_next_packet))) == uint64(0)) {
                return null
            } else {
                plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_17.buffer))), uint64(bits_till_next_packet))
                self_17.current_packet.length = uint64(uint64(0))
            }
        }
        if (uint64(self_17.next_packet.length) != uint64(0)) {
            return unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_get_packet(unsafe(unsafe(reinterpret<plm_demux_t?>(self_17))))))))))
        } elif (int(self_17.start_code) != -1) {
            return unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode_packet(unsafe(unsafe(reinterpret<plm_demux_t?>(self_17))), self_17.start_code)))))))
        } else {
            while (true) {
                self_17.start_code = plm_buffer_next_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_17.buffer))))
                if (int(self_17.start_code) == int(PLM_DEMUX_PACKET_VIDEO_1) || int(self_17.start_code) == int(PLM_DEMUX_PACKET_PRIVATE) || int(self_17.start_code) >= int(PLM_DEMUX_PACKET_AUDIO_1) && int(self_17.start_code) <= int(PLM_DEMUX_PACKET_AUDIO_4)) {
                    return unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode_packet(unsafe(unsafe(reinterpret<plm_demux_t?>(self_17))), self_17.start_code)))))))
                } else {
                    if (int(self_17.start_code) != -1) {
                        continue
                    }
                    return null
                }
            }
        }
    }
    return null
}
[export]
def plm_init_decoders(var self_1 : plm_t?) : int {
    if (uint64(self_1.has_decoders) != uint64(0)) {
        return 1
    } elif (uint64(plm_demux_has_headers(unsafe(unsafe(reinterpret<plm_demux_t?>(self_1.demux))))) == uint64(0)) {
        return 0
    } else {
        if (plm_demux_get_num_video_streams(unsafe(unsafe(reinterpret<plm_demux_t?>(self_1.demux)))) > 0) {
            if (uint64(self_1.video_enabled) != uint64(0)) {
                self_1.video_packet_type = PLM_DEMUX_PACKET_VIDEO_1
            }
            if (self_1.video_decoder == null) {
                self_1.video_buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(plm_buffer_create_with_capacity(uint64(uint64(uint64(128) * uint64(1024))))))))))
                plm_buffer_set_load_callback(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_1.video_buffer))), unsafe(unsafe(reinterpret<function<(arg0:plm_buffer_t?; arg1:uint64):void>>(null))), unsafe(unsafe(reinterpret<uint64>(self_1))))
                self_1.video_decoder = unsafe(unsafe(reinterpret<plm_video_t?>(unsafe(unsafe(reinterpret<plm_video_t?>(plm_video_create_with_buffer(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_1.video_buffer))), 1)))))))
            }
        }
        if (plm_demux_get_num_audio_streams(unsafe(unsafe(reinterpret<plm_demux_t?>(self_1.demux)))) > 0) {
            if (uint64(self_1.audio_enabled) != uint64(0)) {
                self_1.audio_packet_type = int(PLM_DEMUX_PACKET_AUDIO_1) + int(self_1.audio_stream_index)
            }
            if (self_1.audio_decoder == null) {
                self_1.audio_buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(plm_buffer_create_with_capacity(uint64(uint64(uint64(128) * uint64(1024))))))))))
                plm_buffer_set_load_callback(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_1.audio_buffer))), unsafe(unsafe(reinterpret<function<(arg0:plm_buffer_t?; arg1:uint64):void>>(null))), unsafe(unsafe(reinterpret<uint64>(self_1))))
                self_1.audio_decoder = unsafe(unsafe(reinterpret<plm_audio_t?>(unsafe(unsafe(reinterpret<plm_audio_t?>(plm_audio_create_with_buffer(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_1.audio_buffer))), 1)))))))
            }
        }
        self_1.has_decoders = 1
        return 1
    }
    return int(0)
}
[export]
def plm_audio_read_samples(var self_84 : plm_audio_t?; var ch_2 : int; var sb_6 : int; var part_0 : int) {
    var q : plm_quantizer_spec_t const? = null
    var sf_0 : int = int(0)
    var sample : int? = null
    var val : int = int(0)
    var shift_0 : int = int(0)
    var adj : int = int(0)
    var scale : int = int(0)
    q = unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_84.allocation[0]))[uint(ch_2)]))[0])))[uint(sb_6)])))))))))))
    sf_0 = unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_84.scale_factor[0]))[uint(ch_2)]))[0])))[uint(sb_6)]))[0])))[uint(part_0)]))
    sample = unsafe(unsafe(reinterpret<int?>(unsafe(unsafe(reinterpret<int?>(unsafe(unsafe(reinterpret<int?>(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_84.sample[0]))[uint(ch_2)]))[0])))[uint(sb_6)]))[0]))))))))))))
    val = 0
    if (q == null) {
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2])) = 0
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1])) = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2]))
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0])) = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1]))
        return
    } else {
        if (int(sf_0) == 63) {
            sf_0 = 0
        } else {
            shift_0 = int(int(int(int(sf_0) / 3 | 0)))
            sf_0 = int(int(int(int(unsafe(unsafe(unsafe(addr(PLM_AUDIO_SCALEFACTOR_BASE[0]))[int(sf_0) % 3]))) + (1 << int(shift_0) >> 1) >> int(shift_0))))
        }
        adj = q.levels
        if (uint64(q.group) != uint64(0)) {
            val = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_84.buffer))), int(q.bits))
            unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0])) = int(val) % int(adj)
            val = int(val) / int(adj)
            unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1])) = int(val) % int(adj)
            unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2])) = int(val) / int(adj)
        } else {
            unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_84.buffer))), int(q.bits))
            unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_84.buffer))), int(q.bits))
            unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_84.buffer))), int(q.bits))
        }
        scale = 65536 / (int(adj) + 1)
        adj = int(int(int((int(adj) + 1 >> 1) - 1)))
        val = (int(adj) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0])))) * int(scale)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[0])) = int(int(val) * (int(sf_0) >> 12) + (int(val) * int((int(sf_0) & 4095)) + 2048 >> 12) >> 12)
        val = (int(adj) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1])))) * int(scale)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[1])) = int(int(val) * (int(sf_0) >> 12) + (int(val) * int((int(sf_0) & 4095)) + 2048 >> 12) >> 12)
        val = (int(adj) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2])))) * int(scale)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sample)))[2])) = int(int(val) * (int(sf_0) >> 12) + (int(val) * int((int(sf_0) & 4095)) + 2048 >> 12) >> 12)
        return
    }
}
[export]
def plm_video_interpolate_macroblock(var self_98 : plm_video_t?; var s_3 : plm_frame_t?; var motion_h_1 : int; var motion_v_1 : int) {
    var d_3 : plm_frame_t? = null
    d_3 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_98.frame_current)))))))))))
    plm_video_process_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_98))), unsafe(unsafe(reinterpret<uint8?>(s_3.y.data))), unsafe(unsafe(reinterpret<uint8?>(d_3.y.data))), motion_h_1, motion_v_1, 16, 1)
    plm_video_process_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_98))), unsafe(unsafe(reinterpret<uint8?>(s_3.cr.data))), unsafe(unsafe(reinterpret<uint8?>(d_3.cr.data))), int(motion_h_1) / 2, int(motion_v_1) / 2, 8, 1)
    plm_video_process_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_98))), unsafe(unsafe(reinterpret<uint8?>(s_3.cb.data))), unsafe(unsafe(reinterpret<uint8?>(d_3.cb.data))), int(motion_h_1) / 2, int(motion_v_1) / 2, 8, 1)
    return
}
[export]
def plm_frame_to_bgra(var frame_8 : plm_frame_t?; var dest_2 : uint8?; var stride_2 : int) {
    var cols_2 : int = int(0)
    var rows_2 : int = int(0)
    var yw_2 : int = int(0)
    var cw_2 : int = int(0)
    var row_2 : int = int(0)
    var c_index_2 : int = int(0)
    var y_index_2 : int = int(0)
    var d_index_3 : int = int(0)
    var col_2 : int = int(0)
    var y_14 : int = int(0)
    var cr_2 : int = int(0)
    var cb_2 : int = int(0)
    var r_3 : int = int(0)
    var g_2 : int = int(0)
    var b_2 : int = int(0)
    cols_2 = int(int(int(uint(uint(frame_8.width))) >> int(uint(uint(1)))))
    rows_2 = int(int(int(uint(uint(frame_8.height))) >> int(uint(uint(1)))))
    yw_2 = int(frame_8.y.width)
    cw_2 = int(frame_8.cb.width)
    row_2 = 0
    while (true) {
        if (!(int(row_2) < int(rows_2))) {
            break
        }
        c_index_2 = int(row_2) * int(cw_2)
        y_index_2 = int(row_2) * 2 * int(yw_2)
        d_index_3 = int(row_2) * 2 * int(stride_2)
        col_2 = 0
        while (true) {
            if (!(int(col_2) < int(cols_2))) {
                break
            }
            cr_2 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_8.cr.data)))[uint(c_index_2)]))) - 128
            cb_2 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_8.cb.data)))[uint(c_index_2)]))) - 128
            r_3 = int(int(int(int(cr_2) * 104597 >> 16)))
            g_2 = int(int(int(int(cb_2) * 25674 + int(cr_2) * 53278 >> 16)))
            b_2 = int(int(int(int(cb_2) * 132201 >> 16)))
            y_14 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_8.y.data)))[int(y_index_2) + 0]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (0 + 2)])) = uint8(plm_clamp(int(y_14) + int(r_3)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (0 + 1)])) = uint8(plm_clamp(int(y_14) - int(g_2)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (0 + 0)])) = uint8(plm_clamp(int(y_14) + int(b_2)))
            y_14 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_8.y.data)))[int(y_index_2) + 1]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (4 + 2)])) = uint8(plm_clamp(int(y_14) + int(r_3)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (4 + 1)])) = uint8(plm_clamp(int(y_14) - int(g_2)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (4 + 0)])) = uint8(plm_clamp(int(y_14) + int(b_2)))
            y_14 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_8.y.data)))[int(y_index_2) + int(yw_2)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (int(stride_2) + 2)])) = uint8(plm_clamp(int(y_14) + int(r_3)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (int(stride_2) + 1)])) = uint8(plm_clamp(int(y_14) - int(g_2)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (int(stride_2) + 0)])) = uint8(plm_clamp(int(y_14) + int(b_2)))
            y_14 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_8.y.data)))[int(y_index_2) + (int(yw_2) + 1)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (int(stride_2) + 4) + 2])) = uint8(plm_clamp(int(y_14) + int(r_3)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (int(stride_2) + 4) + 1])) = uint8(plm_clamp(int(y_14) - int(g_2)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_2)))[int(d_index_3) + (int(stride_2) + 4) + 0])) = uint8(plm_clamp(int(y_14) + int(b_2)))
            c_index_2 = int(c_index_2) + 1
            y_index_2 = int(y_index_2) + 2
            d_index_3 = int(d_index_3) + 2 * 4
            col_2 = int(col_2) + 1
            col_2
        }
        row_2 = int(row_2) + 1
        row_2
    }
    return
}
[export]
def plm_video_destroy(var self_37 : plm_video_t?) {
    if (uint64(self_37.destroy_buffer_when_done) != uint64(0)) {
        plm_buffer_destroy(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_37.buffer))))
    }
    if (uint64(self_37.has_sequence_header) != uint64(0)) {
        unsafe(c2da_free(uint64(unsafe(unsafe(reinterpret<uint64>(self_37.frames_data))))))
    }
    unsafe(c2da_free(uint64(unsafe(unsafe(reinterpret<uint64>(self_37))))))
    return
}
[export]
def plm_get_audio_enabled(var self_57 : plm_t?) : int {
    return self_57.audio_enabled
    return int(0)
}
[export]
def plm_get_framerate(var self_55 : plm_t?) : double {
    var c2da_fresh14 : double = double(0)
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_55))))) != uint64(0) && self_55.video_decoder != null) {
        c2da_fresh14 = plm_video_get_framerate(unsafe(unsafe(reinterpret<plm_video_t?>(self_55.video_decoder))))
    } else {
        c2da_fresh14 = double(0)
    }
    return c2da_fresh14
    return double(0)
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
    var i_5 : int = int(0)
    var i_6 : int = int(0)
    i_5 = 0
    while (true) {
        if (!(int(i_5) < 8)) {
            break
        }
        b1 = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[4 * 8 + int(i_5)]))
        b3 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[2 * 8 + int(i_5)]))) + int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[6 * 8 + int(i_5)])))
        b4 = unsafe(int(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[5 * 8 + int(i_5)])) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[3 * 8 + int(i_5)]))))
        tmp1 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[1 * 8 + int(i_5)]))) + int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[7 * 8 + int(i_5)])))
        tmp2 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[3 * 8 + int(i_5)]))) + int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[5 * 8 + int(i_5)])))
        b6 = unsafe(int(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[1 * 8 + int(i_5)])) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[7 * 8 + int(i_5)]))))
        b7 = int(tmp1) + int(tmp2)
        m0 = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[0 * 8 + int(i_5)]))
        x4 = int(int(int((int(b6) * 473 - int(b4) * 196 + 128 >> 8) - int(b7))))
        x0 = int(int(int(int(x4) - ((int(tmp1) - int(tmp2)) * 362 + 128 >> 8))))
        x1 = int(m0) - int(b1)
        x2 = int(int(int((unsafe(int(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[2 * 8 + int(i_5)])) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[6 * 8 + int(i_5)])))) * 362 + 128 >> 8) - int(b3))))
        x3 = int(m0) + int(b1)
        y3 = int(x1) + int(x2)
        y4 = int(x3) + int(b3)
        y5 = int(x1) - int(x2)
        y6 = int(x3) - int(b3)
        y7 = int(int(int(int(-x0) - (int(b4) * 473 + int(b6) * 196 + 128 >> 8))))
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[0 * 8 + int(i_5)])) = int(b7) + int(y4)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[1 * 8 + int(i_5)])) = int(x4) + int(y3)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[2 * 8 + int(i_5)])) = int(y5) - int(x0)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[3 * 8 + int(i_5)])) = int(y6) - int(y7)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[4 * 8 + int(i_5)])) = int(y6) + int(y7)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[5 * 8 + int(i_5)])) = int(x0) + int(y5)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[6 * 8 + int(i_5)])) = int(y3) - int(x4)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[7 * 8 + int(i_5)])) = int(y4) - int(b7)
        i_5 = int(i_5) + 1
        i_5
    }
    i_6 = 0
    while (true) {
        if (!(int(i_6) < 64)) {
            break
        }
        b1 = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[4 + int(i_6)]))
        b3 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[2 + int(i_6)]))) + int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[6 + int(i_6)])))
        b4 = unsafe(int(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[5 + int(i_6)])) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[3 + int(i_6)]))))
        tmp1 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[1 + int(i_6)]))) + int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[7 + int(i_6)])))
        tmp2 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[3 + int(i_6)]))) + int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[5 + int(i_6)])))
        b6 = unsafe(int(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[1 + int(i_6)])) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[7 + int(i_6)]))))
        b7 = int(tmp1) + int(tmp2)
        m0 = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[0 + int(i_6)]))
        x4 = int(int(int((int(b6) * 473 - int(b4) * 196 + 128 >> 8) - int(b7))))
        x0 = int(int(int(int(x4) - ((int(tmp1) - int(tmp2)) * 362 + 128 >> 8))))
        x1 = int(m0) - int(b1)
        x2 = int(int(int((unsafe(int(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[2 + int(i_6)])) - int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[6 + int(i_6)])))) * 362 + 128 >> 8) - int(b3))))
        x3 = int(m0) + int(b1)
        y3 = int(x1) + int(x2)
        y4 = int(x3) + int(b3)
        y5 = int(x1) - int(x2)
        y6 = int(x3) - int(b3)
        y7 = int(int(int(int(-x0) - (int(b4) * 473 + int(b6) * 196 + 128 >> 8))))
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[0 + int(i_6)])) = int(int(b7) + (int(y4) + 128) >> 8)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[1 + int(i_6)])) = int(int(x4) + (int(y3) + 128) >> 8)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[2 + int(i_6)])) = int(int(y5) - int(x0) + 128 >> 8)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[3 + int(i_6)])) = int(int(y6) - int(y7) + 128 >> 8)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[4 + int(i_6)])) = int(int(y6) + (int(y7) + 128) >> 8)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[5 + int(i_6)])) = int(int(x0) + (int(y5) + 128) >> 8)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[6 + int(i_6)])) = int(int(y3) - int(x4) + 128 >> 8)
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(block_2)))[7 + int(i_6)])) = int(int(y4) - int(b7) + 128 >> 8)
        i_6 = int(i_6) + 8
    }
    return
}
[export]
def plm_video_decode_motion_vectors(var self_99 : plm_video_t?) {
    var r_size : int = int(0)
    var r_size_0 : int = int(0)
    if (uint64(self_99.motion_forward.is_set) != uint64(0)) {
        r_size = self_99.motion_forward.r_size
        self_99.motion_forward.h = plm_video_decode_motion_vector(unsafe(unsafe(reinterpret<plm_video_t?>(self_99))), r_size, self_99.motion_forward.h)
        self_99.motion_forward.v = plm_video_decode_motion_vector(unsafe(unsafe(reinterpret<plm_video_t?>(self_99))), r_size, self_99.motion_forward.v)
    } elif (int(self_99.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
        self_99.motion_forward.h = 0
        self_99.motion_forward.v = 0
    }
    if (uint64(self_99.motion_backward.is_set) != uint64(0)) {
        r_size_0 = self_99.motion_backward.r_size
        self_99.motion_backward.h = plm_video_decode_motion_vector(unsafe(unsafe(reinterpret<plm_video_t?>(self_99))), r_size_0, self_99.motion_backward.h)
        self_99.motion_backward.v = plm_video_decode_motion_vector(unsafe(unsafe(reinterpret<plm_video_t?>(self_99))), r_size_0, self_99.motion_backward.v)
    }
    return
}
[export]
def plm_video_set_time(var self_109 : plm_video_t?; var time_2 : double) {
    self_109.frames_decoded = int(int(double(self_109.framerate)) * int(double(time_2)))
    self_109.time = time_2
    return
}
[export]
def plm_buffer_create_with_callbacks(var load_callback : plm_buffer_load_callback; var seek_callback : plm_buffer_seek_callback; var tell_callback : plm_buffer_tell_callback; var length_2 : uint64; var user_4 : uint64) : plm_buffer_t? {
    var self_110 : plm_buffer_t? = null
    self_110 = unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(plm_buffer_create_with_capacity(uint64(uint64(uint64(128) * uint64(1024))))))))))))))))
    self_110.mode = unsafe(reinterpret<plm_buffer_mode>(PLM_BUFFER_MODE_FILE))
    self_110.total_size = uint64(length_2)
    self_110.load_callback = load_callback
    self_110.seek_callback = seek_callback
    self_110.tell_callback = tell_callback
    self_110.load_callback_user_data = user_4
    return unsafe(unsafe(reinterpret<plm_buffer_t?>(self_110)))
    return null
}
[export]
def plm_set_video_enabled(var self_47 : plm_t?; var enabled : int) {
    self_47.video_enabled = enabled
    if (uint64(enabled) == uint64(0)) {
        self_47.video_packet_type = 0
        return
    } else {
        var c2da_fresh7 : int = int(0)
        if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_47))))) != uint64(0) && self_47.video_decoder != null) {
            c2da_fresh7 = PLM_DEMUX_PACKET_VIDEO_1
        } else {
            c2da_fresh7 = 0
        }
        self_47.video_packet_type = c2da_fresh7
        return
    }
}
[export]
def plm_get_num_video_streams(var self_48 : plm_t?) : int {
    return plm_demux_get_num_video_streams(unsafe(unsafe(reinterpret<plm_demux_t?>(self_48.demux))))
    return int(0)
}
[export]
def plm_video_decode_macroblock(var self_91 : plm_video_t?) {
    var increment : int = int(0)
    var t : int = int(0)
    var table_0 : plm_vlc_t const? = null
    var cbp : int = int(0)
    var block_0 : int = int(0)
    var mask_0 : int = int(0)
    increment = 0
    t = int(plm_buffer_read_vlc(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_91.buffer))), unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(addr(PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT[0])))))))
    while (true) {
        if (!(int(t) == 34)) {
            break
        }
        t = int(plm_buffer_read_vlc(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_91.buffer))), unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(addr(PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT[0])))))))
    }
    while (true) {
        if (!(int(t) == 35)) {
            break
        }
        increment = int(increment) + 33
        t = int(plm_buffer_read_vlc(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_91.buffer))), unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(addr(PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT[0])))))))
    }
    increment = int(increment) + int(t)
    if (uint64(self_91.slice_begin) != uint64(0)) {
        self_91.slice_begin = 0
        self_91.macroblock_address = int(self_91.macroblock_address) + int(increment)
    } elif (int(self_91.macroblock_address) + int(increment) >= int(self_91.mb_size)) {
        return
    } else {
        if (int(increment) > 1) {
            unsafe(unsafe(unsafe(addr(self_91.dc_predictor[0]))[0])) = 128
            unsafe(unsafe(unsafe(addr(self_91.dc_predictor[0]))[1])) = 128
            unsafe(unsafe(unsafe(addr(self_91.dc_predictor[0]))[2])) = 128
            if (int(self_91.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
                self_91.motion_forward.h = 0
                self_91.motion_forward.v = 0
            }
        }
        while (true) {
            if (!(int(increment) > 1)) {
                break
            }
            self_91.macroblock_address = self_91.macroblock_address + 1
            self_91.mb_row = int(self_91.macroblock_address) / int(self_91.mb_width)
            self_91.mb_col = int(self_91.macroblock_address) % int(self_91.mb_width)
            plm_video_predict_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_91))))
            increment = int(increment) - 1
        }
        self_91.macroblock_address = self_91.macroblock_address + 1
    }
    self_91.mb_row = int(self_91.macroblock_address) / int(self_91.mb_width)
    self_91.mb_col = int(self_91.macroblock_address) % int(self_91.mb_width)
    if (int(self_91.mb_col) >= int(self_91.mb_width) || int(self_91.mb_row) >= int(self_91.mb_height)) {
        return
    } else {
        table_0 = unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(unsafe(unsafe(addr(PLM_VIDEO_MACROBLOCK_TYPE[0]))[uint(self_91.picture_type)])))))))))))
        self_91.macroblock_type = int(plm_buffer_read_vlc(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_91.buffer))), unsafe(unsafe(reinterpret<plm_vlc_t const?>(table_0)))))
        self_91.macroblock_intra = int(int(self_91.macroblock_type) & 1)
        self_91.motion_forward.is_set = int(int(self_91.macroblock_type) & 8)
        self_91.motion_backward.is_set = int(int(self_91.macroblock_type) & 4)
        if (uint64(int(self_91.macroblock_type) & 16) != uint64(0)) {
            self_91.quantizer_scale = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_91.buffer))), 5)
        }
        if (uint64(self_91.macroblock_intra) != uint64(0)) {
            self_91.motion_forward.h = 0
            self_91.motion_backward.h = self_91.motion_forward.h
            self_91.motion_forward.v = 0
            self_91.motion_backward.v = self_91.motion_forward.v
        } else {
            unsafe(unsafe(unsafe(addr(self_91.dc_predictor[0]))[0])) = 128
            unsafe(unsafe(unsafe(addr(self_91.dc_predictor[0]))[1])) = 128
            unsafe(unsafe(unsafe(addr(self_91.dc_predictor[0]))[2])) = 128
            plm_video_decode_motion_vectors(unsafe(unsafe(reinterpret<plm_video_t?>(self_91))))
            plm_video_predict_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_91))))
        }
        var c2da_fresh23 : int = int(0)
        if (uint64(self_91.macroblock_intra) != uint64(0)) {
            c2da_fresh23 = 63
        } else {
            c2da_fresh23 = 0
        }
        var c2da_fresh24 : int = int(0)
        if (uint64(int(self_91.macroblock_type) & 2) != uint64(0)) {
            c2da_fresh24 = int(plm_buffer_read_vlc(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_91.buffer))), unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(addr(PLM_VIDEO_CODE_BLOCK_PATTERN[0])))))))
        } else {
            c2da_fresh24 = c2da_fresh23
        }
        cbp = c2da_fresh24
        block_0 = 0
        mask_0 = 32
        while (true) {
            if (!(int(block_0) < 6)) {
                break
            }
            if (uint64(int(cbp) & int(mask_0)) != uint64(0)) {
                plm_video_decode_block(unsafe(unsafe(reinterpret<plm_video_t?>(self_91))), block_0)
            }
            mask_0 = int(int(int(int(mask_0) >> 1)))
            block_0 = int(block_0) + 1
            block_0
        }
        return
    }
}
[export]
def plm_has_headers(var self_38 : plm_t?) : int {
    if (uint64(plm_demux_has_headers(unsafe(unsafe(reinterpret<plm_demux_t?>(self_38.demux))))) == uint64(0)) {
        return 0
    } elif (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_38))))) == uint64(0)) {
        return 0
    } elif (self_38.video_decoder != null && uint64(plm_video_has_header(unsafe(unsafe(reinterpret<plm_video_t?>(self_38.video_decoder))))) == uint64(0) || self_38.audio_decoder != null && uint64(plm_audio_has_header(unsafe(unsafe(reinterpret<plm_audio_t?>(self_38.audio_decoder))))) == uint64(0)) {
        return 0
    } else {
        return 1
    }
    return int(0)
}
[export]
def plm_video_predict_macroblock(var self_95 : plm_video_t?) {
    var fw_h : int = int(0)
    var fw_v : int = int(0)
    var bw_h : int = int(0)
    var bw_v : int = int(0)
    fw_h = self_95.motion_forward.h
    fw_v = self_95.motion_forward.v
    if (uint64(self_95.motion_forward.full_px) != uint64(0)) {
        fw_h = int(int(int(int(fw_h) << 1)))
        fw_v = int(int(int(int(fw_v) << 1)))
    }
    if (int(self_95.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_B)) {
        bw_h = self_95.motion_backward.h
        bw_v = self_95.motion_backward.v
        if (uint64(self_95.motion_backward.full_px) != uint64(0)) {
            bw_h = int(int(int(int(bw_h) << 1)))
            bw_v = int(int(int(int(bw_v) << 1)))
        }
        if (uint64(self_95.motion_forward.is_set) != uint64(0)) {
            plm_video_copy_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_95))), unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_95.frame_forward))))), fw_h, fw_v)
            if (uint64(self_95.motion_backward.is_set) != uint64(0)) {
                plm_video_interpolate_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_95))), unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_95.frame_backward))))), bw_h, bw_v)
            }
        } else {
            plm_video_copy_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_95))), unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_95.frame_backward))))), bw_h, bw_v)
        }
    } else {
        plm_video_copy_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_95))), unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_95.frame_forward))))), fw_h, fw_v)
    }
    return
}
[export]
def plm_read_audio_packet(var buffer_2 : plm_buffer_t?; var user : uint64) {
    var self_10 : plm_t? = null
    self_10 = unsafe(unsafe(reinterpret<plm_t?>(unsafe(unsafe(reinterpret<plm_t?>(unsafe(unsafe(reinterpret<plm_t?>(user)))))))))
    plm_read_packets(unsafe(unsafe(reinterpret<plm_t?>(self_10))), self_10.audio_packet_type)
    return
}
[export]
def plm_buffer_seek(var self_45 : plm_buffer_t?; var pos_0 : uint64) {
    self_45.has_ended = 0
    if (self_45.seek_callback != null) {
        self_45.seek_callback(self_45, pos_0, self_45.load_callback_user_data)
        self_45.bit_index = uint64(uint64(0))
        self_45.length = uint64(uint64(0))
    } elif (uint(self_45.mode) == uint(PLM_BUFFER_MODE_RING)) {
        if (uint64(uint64(pos_0)) != uint64(0)) {
            return
        } else {
            self_45.bit_index = uint64(uint64(0))
            self_45.length = uint64(uint64(0))
            self_45.total_size = uint64(uint64(0))
        }
    } elif (uint64(pos_0) < uint64(self_45.length)) {
        self_45.bit_index = uint64(uint64(pos_0) << uint64(3))
    }
    return
}
[export]
def plm_audio_find_frame_sync(var self_7 : plm_audio_t?) : int {
    var i : uint64 = uint64(uint64(uint64(0)))
    i = uint64(uint64(uint64(uint64(self_7.buffer.bit_index) >> uint64(3))))
    while (true) {
        if (uint64(i) < uint64(self_7.buffer.length) - uint64(1)) {
            if (int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_7.buffer.bytes)))[uint(i)]))) == 255 && (int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_7.buffer.bytes)))[uint(uint(uint64(i)) + uint(uint64(1)))]))) & 254) == 252) {
                self_7.buffer.bit_index = uint64((uint64(i) + uint64(1) << uint64(3)) + uint64(3))
                return 1
            } else {
                i = uint64(uint64(uint64(i) + uint64(1)))
                i
            }
        } else {
            self_7.buffer.bit_index = uint64(uint64(i) + uint64(1) << uint64(3))
            return 0
        }
    }
    return int(0)
}
[export]
def plm_buffer_read_vlc(var self_94 : plm_buffer_t?; var table_2 : plm_vlc_t const?) : int16 {
    var state : plm_vlc_t = plm_vlc_t()
    state = plm_vlc_t(index = int16(0), value = int16(0))
    while (true) {
        state = unsafe(unsafe(unsafe(unsafe(reinterpret<plm_vlc_t const?>(table_2)))[int(state.index) + plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_94))), 1)]))
        if (!(int(state.index) > 0)) {
            break
        }
    }
    return state.value
    return int16(0)
}
[export]
def plm_audio_rewind(var self_73 : plm_audio_t?) {
    plm_buffer_rewind(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_73.buffer))))
    self_73.time = double(0)
    self_73.samples_decoded = 0
    self_73.next_frame_data_size = 0
    return
}
[export]
def plm_buffer_has_start_code(var self_101 : plm_buffer_t?; var code_0 : int) : int {
    var previous_bit_index : uint64 = uint64(uint64(uint64(0)))
    var previous_discard_read_bytes : int = int(0)
    var current_0 : int = int(0)
    previous_bit_index = uint64(uint64(uint64(self_101.bit_index)))
    previous_discard_read_bytes = self_101.discard_read_bytes
    self_101.discard_read_bytes = 0
    current_0 = plm_buffer_find_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_101))), code_0)
    self_101.bit_index = uint64(previous_bit_index)
    self_101.discard_read_bytes = previous_discard_read_bytes
    return current_0
    return int(0)
}
[export]
def plm_get_video_enabled(var self_46 : plm_t?) : int {
    return self_46.video_enabled
    return int(0)
}
[export]
def plm_buffer_peek_non_zero(var self_90 : plm_buffer_t?; var bit_count : int) : int {
    var val_0 : int = int(0)
    if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_90))), uint64(uint64(bit_count)))) == uint64(0)) {
        return 0
    } else {
        val_0 = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_90))), bit_count)
        self_90.bit_index = uint64(uint64(self_90.bit_index) - uint64(bit_count))
        if (uint64(int(val_0)) != uint64(0)) {
            return 1
        } else {
            return 0
        }
    }
    return int(0)
}
[export]
def plm_video_decode_block(var self_92 : plm_video_t?; var block_1 : int) {
    var n : int = int(0)
    var quant_matrix : uint8? = null
    var predictor : int = int(0)
    var dct_size : int = int(0)
    var plane_index : int = int(0)
    var differential : int = int(0)
    var level : int = int(0)
    var run : int = int(0)
    var coeff : uint16 = uint16(uint16(uint16(0)))
    var de_zig_zagged : int = int(0)
    var d_0 : uint8? = null
    var dw : int = int(0)
    var di : int = int(0)
    var s_0 : int? = null
    var si : int = int(0)
    var dest_scan_2 : int = int(0)
    var source_scan_2 : int = int(0)
    var y_2 : int = int(0)
    var x_2 : int = int(0)
    var value_0 : int = int(0)
    var dest_scan_1 : int = int(0)
    var source_scan_1 : int = int(0)
    var y_1 : int = int(0)
    var x_1 : int = int(0)
    var clamped : int = int(0)
    var dest_scan : int = int(0)
    var source_scan : int = int(0)
    var y : int = int(0)
    var x : int = int(0)
    var dest_scan_0 : int = int(0)
    var source_scan_0 : int = int(0)
    var y_0 : int = int(0)
    var x_0 : int = int(0)
    n = 0
    if (uint64(self_92.macroblock_intra) != uint64(0)) {
        var c2da_fresh25 : int = int(0)
        if (int(block_1) > 3) {
            c2da_fresh25 = int(block_1) - 3
        } else {
            c2da_fresh25 = 0
        }
        plane_index = c2da_fresh25
        predictor = unsafe(unsafe(unsafe(addr(self_92.dc_predictor[0]))[uint(plane_index)]))
        dct_size = int(plm_buffer_read_vlc(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(unsafe(unsafe(addr(PLM_VIDEO_DCT_SIZE[0]))[uint(plane_index)])))))))
        if (int(dct_size) > 0) {
            differential = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), dct_size)
            if (uint64(int(differential) & 1 << int(dct_size) - 1) != uint64(0)) {
                unsafe(unsafe(unsafe(addr(self_92.block_data[0]))[0])) = int(predictor) + int(differential)
            } else {
                unsafe(unsafe(unsafe(addr(self_92.block_data[0]))[0])) = int(predictor) + (-1 << int(dct_size) | int(differential) + 1)
            }
        } else {
            unsafe(unsafe(unsafe(addr(self_92.block_data[0]))[0])) = predictor
        }
        unsafe(unsafe(unsafe(addr(self_92.dc_predictor[0]))[uint(plane_index)])) = unsafe(unsafe(unsafe(addr(self_92.block_data[0]))[0]))
        unsafe(unsafe(unsafe(addr(self_92.block_data[0]))[0])) = int(unsafe(unsafe(unsafe(addr(self_92.block_data[0]))[0]))) << 3 + 5
        quant_matrix = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(self_92.intra_quant_matrix[0])))))))))))
        n = 1
    } else {
        quant_matrix = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(addr(self_92.non_intra_quant_matrix[0])))))))))))
    }
    level = 0
    while (true) {
        if (!(uint64(1) != uint64(0))) {
            break
        }
        run = 0
        coeff = uint16(uint16(uint16(plm_buffer_read_vlc_uint(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), unsafe(unsafe(reinterpret<plm_vlc_uint_t const?>(unsafe(addr(PLM_VIDEO_DCT_COEFF[0])))))))))
        if (int(coeff) == 1 && n > 0 && uint64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), 1)) == uint64(0)) {
            break
        } else {
            if (int(coeff) == 65535) {
                run = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), 6)
                level = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), 8)
                if (uint64(int(level)) == uint64(0)) {
                    level = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), 8)
                } elif (int(level) == 128) {
                    level = int(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), 8)) - 256
                } elif (int(level) > 128) {
                    level = int(level) - 256
                }
            } else {
                run = int(int(int(int(coeff) >> 8)))
                level = int(int(int(int(coeff) & 255)))
                if (uint64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_92.buffer))), 1)) != uint64(0)) {
                    level = -level
                }
            }
            n = int(n) + int(run)
            if (n < 0 || n >= 64) {
                return
            } else {
                de_zig_zagged = int(unsafe(unsafe(unsafe(addr(PLM_VIDEO_ZIG_ZAG[0]))[uint(n)])))
                n = n + 1
                level = int(int(int(uint(uint(level))) << int(uint(uint(1)))))
                if (uint64(self_92.macroblock_intra) == uint64(0)) {
                    var c2da_fresh26 : int = int(0)
                    if (int(level) < 0) {
                        c2da_fresh26 = -1
                    } else {
                        c2da_fresh26 = 1
                    }
                    level = int(level) + int(c2da_fresh26)
                }
                level = int(int(int(int(level) * int(self_92.quantizer_scale) * int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(quant_matrix)))[uint(de_zig_zagged)]))) >> 4)))
                if (uint64(int(level) & 1) == uint64(0)) {
                    var c2da_fresh27 : int = int(0)
                    if (int(level) > 0) {
                        c2da_fresh27 = 1
                    } else {
                        c2da_fresh27 = -1
                    }
                    level = int(level) - int(c2da_fresh27)
                }
                if (int(level) > 2047) {
                    level = 2047
                } elif (int(level) < -2048) {
                    level = -2048
                }
                unsafe(unsafe(unsafe(addr(self_92.block_data[0]))[uint(de_zig_zagged)])) = int(level) * int(unsafe(unsafe(unsafe(addr(PLM_VIDEO_PREMULTIPLIER_MATRIX[0]))[uint(de_zig_zagged)])))
            }
        }
    }
    if (int(block_1) < 4) {
        d_0 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(self_92.frame_current.y.data)))))))))
        dw = self_92.luma_width
        di = int(int(int(int(self_92.mb_row) * int(self_92.luma_width) + int(self_92.mb_col) << 4)))
        if (uint64(int(block_1) & 1) != uint64(0)) {
            di = int(di) + 8
        }
        if (uint64(int(block_1) & 2) != uint64(0)) {
            di = int(int(int(int(di) + (int(self_92.luma_width) << 3))))
        }
    } else {
        var c2da_fresh28 : uint8? = null
        if (int(block_1) == 4) {
            c2da_fresh28 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(self_92.frame_current.cb.data))))))
        } else {
            c2da_fresh28 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(self_92.frame_current.cr.data))))))
        }
        d_0 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(c2da_fresh28)))))))))
        dw = self_92.chroma_width
        di = int(int(int((int(self_92.mb_row) * int(self_92.luma_width) << 2) + (int(self_92.mb_col) << 3))))
    }
    s_0 = unsafe(unsafe(reinterpret<int?>(unsafe(unsafe(reinterpret<int?>(unsafe(unsafe(reinterpret<int?>(unsafe(addr(self_92.block_data[0])))))))))))
    si = 0
    if (uint64(self_92.macroblock_intra) != uint64(0)) {
        if (n == 1) {
            clamped = int(int(int(int(plm_clamp(int(int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(s_0)))[0]))) + 128 >> 8))))))
            while (true) {
                dest_scan = int(dw) - 8
                source_scan = 8 - 8
                y = 0
                while (true) {
                    if (!(int(y) < 8)) {
                        break
                    }
                    x = 0
                    while (true) {
                        if (!(x < 8)) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_0)))[uint(di)])) = uint8(uint8(clamped))
                        si = int(si) + 1
                        di = int(di) + 1
                        x = x + 1
                        x
                    }
                    si = int(si) + int(source_scan)
                    di = int(di) + int(dest_scan)
                    y = int(y) + 1
                    y
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
            unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(s_0)))[0])) = 0
        } else {
            plm_video_idct(unsafe(unsafe(reinterpret<int?>(s_0))))
            while (true) {
                dest_scan_0 = int(dw) - 8
                source_scan_0 = 8 - 8
                y_0 = 0
                while (true) {
                    if (!(int(y_0) < 8)) {
                        break
                    }
                    x_0 = 0
                    while (true) {
                        if (!(int(x_0) < 8)) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_0)))[uint(di)])) = uint8(plm_clamp(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(s_0)))[uint(si)]))))
                        si = int(si) + 1
                        di = int(di) + 1
                        x_0 = int(x_0) + 1
                        x_0
                    }
                    si = int(si) + int(source_scan_0)
                    di = int(di) + int(dest_scan_0)
                    y_0 = int(y_0) + 1
                    y_0
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
            unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_92.block_data[0])))))))), int(0), int(4)))
        }
    } elif (n == 1) {
        value_0 = int(int(int(int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(s_0)))[0]))) + 128 >> 8)))
        while (true) {
            dest_scan_1 = int(dw) - 8
            source_scan_1 = 8 - 8
            y_1 = 0
            while (true) {
                if (!(int(y_1) < 8)) {
                    break
                }
                x_1 = 0
                while (true) {
                    if (!(int(x_1) < 8)) {
                        break
                    }
                    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_0)))[uint(di)])) = uint8(plm_clamp(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_0)))[uint(di)]))) + int(value_0)))
                    si = int(si) + 1
                    di = int(di) + 1
                    x_1 = int(x_1) + 1
                    x_1
                }
                si = int(si) + int(source_scan_1)
                di = int(di) + int(dest_scan_1)
                y_1 = int(y_1) + 1
                y_1
            }
            if (!(uint64(0) != uint64(0))) {
                break
            }
        }
        unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(s_0)))[0])) = 0
    } else {
        plm_video_idct(unsafe(unsafe(reinterpret<int?>(s_0))))
        while (true) {
            dest_scan_2 = int(dw) - 8
            source_scan_2 = 8 - 8
            y_2 = 0
            while (true) {
                if (!(int(y_2) < 8)) {
                    break
                }
                x_2 = 0
                while (true) {
                    if (!(int(x_2) < 8)) {
                        break
                    }
                    unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_0)))[uint(di)])) = uint8(plm_clamp(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_0)))[uint(di)]))) + int(unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(s_0)))[uint(si)])))))
                    si = int(si) + 1
                    di = int(di) + 1
                    x_2 = int(x_2) + 1
                    x_2
                }
                si = int(si) + int(source_scan_2)
                di = int(di) + int(dest_scan_2)
                y_2 = int(y_2) + 1
                y_2
            }
            if (!(uint64(0) != uint64(0))) {
                break
            }
        }
        unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_92.block_data[0])))))))), int(0), int(4)))
    }
    return
}
[export]
def plm_frame_to_abgr(var frame_10 : plm_frame_t?; var dest_4 : uint8?; var stride_4 : int) {
    var cols_4 : int = int(0)
    var rows_4 : int = int(0)
    var yw_4 : int = int(0)
    var cw_4 : int = int(0)
    var row_4 : int = int(0)
    var c_index_4 : int = int(0)
    var y_index_4 : int = int(0)
    var d_index_5 : int = int(0)
    var col_4 : int = int(0)
    var y_16 : int = int(0)
    var cr_4 : int = int(0)
    var cb_4 : int = int(0)
    var r_5 : int = int(0)
    var g_4 : int = int(0)
    var b_4 : int = int(0)
    cols_4 = int(int(int(uint(uint(frame_10.width))) >> int(uint(uint(1)))))
    rows_4 = int(int(int(uint(uint(frame_10.height))) >> int(uint(uint(1)))))
    yw_4 = int(frame_10.y.width)
    cw_4 = int(frame_10.cb.width)
    row_4 = 0
    while (true) {
        if (!(int(row_4) < int(rows_4))) {
            break
        }
        c_index_4 = int(row_4) * int(cw_4)
        y_index_4 = int(row_4) * 2 * int(yw_4)
        d_index_5 = int(row_4) * 2 * int(stride_4)
        col_4 = 0
        while (true) {
            if (!(int(col_4) < int(cols_4))) {
                break
            }
            cr_4 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_10.cr.data)))[uint(c_index_4)]))) - 128
            cb_4 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_10.cb.data)))[uint(c_index_4)]))) - 128
            r_5 = int(int(int(int(cr_4) * 104597 >> 16)))
            g_4 = int(int(int(int(cb_4) * 25674 + int(cr_4) * 53278 >> 16)))
            b_4 = int(int(int(int(cb_4) * 132201 >> 16)))
            y_16 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_10.y.data)))[int(y_index_4) + 0]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (0 + 3)])) = uint8(plm_clamp(int(y_16) + int(r_5)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (0 + 2)])) = uint8(plm_clamp(int(y_16) - int(g_4)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (0 + 1)])) = uint8(plm_clamp(int(y_16) + int(b_4)))
            y_16 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_10.y.data)))[int(y_index_4) + 1]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (4 + 3)])) = uint8(plm_clamp(int(y_16) + int(r_5)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (4 + 2)])) = uint8(plm_clamp(int(y_16) - int(g_4)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (4 + 1)])) = uint8(plm_clamp(int(y_16) + int(b_4)))
            y_16 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_10.y.data)))[int(y_index_4) + int(yw_4)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (int(stride_4) + 3)])) = uint8(plm_clamp(int(y_16) + int(r_5)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (int(stride_4) + 2)])) = uint8(plm_clamp(int(y_16) - int(g_4)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (int(stride_4) + 1)])) = uint8(plm_clamp(int(y_16) + int(b_4)))
            y_16 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_10.y.data)))[int(y_index_4) + (int(yw_4) + 1)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (int(stride_4) + 4) + 3])) = uint8(plm_clamp(int(y_16) + int(r_5)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (int(stride_4) + 4) + 2])) = uint8(plm_clamp(int(y_16) - int(g_4)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_4)))[int(d_index_5) + (int(stride_4) + 4) + 1])) = uint8(plm_clamp(int(y_16) + int(b_4)))
            c_index_4 = int(c_index_4) + 1
            y_index_4 = int(y_index_4) + 2
            d_index_5 = int(d_index_5) + 2 * 4
            col_4 = int(col_4) + 1
            col_4
        }
        row_4 = int(row_4) + 1
        row_4
    }
    return
}
[export]
def plm_video_init_frame(var self_29 : plm_video_t?; var frame : plm_frame_t?; var base : uint8?) {
    var luma_plane_size_0 : uint64 = uint64(uint64(uint64(0)))
    var chroma_plane_size_0 : uint64 = uint64(uint64(uint64(0)))
    luma_plane_size_0 = uint64(uint64(uint64(uint64(uint64(int(self_29.luma_width)) * uint64(int(self_29.luma_height))))))
    chroma_plane_size_0 = uint64(uint64(uint64(uint64(uint64(int(self_29.chroma_width)) * uint64(int(self_29.chroma_height))))))
    frame.width = uint(uint(self_29.width))
    frame.height = uint(uint(self_29.height))
    frame.y.width = uint(uint(self_29.luma_width))
    frame.y.height = uint(uint(self_29.luma_height))
    frame.y.data = unsafe(unsafe(reinterpret<uint8?>(base)))
    frame.cr.width = uint(uint(self_29.chroma_width))
    frame.cr.height = uint(uint(self_29.chroma_height))
    frame.cr.data = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(base))), uint64(luma_plane_size_0), 1))))))))
    frame.cb.width = uint(uint(self_29.chroma_width))
    frame.cb.height = uint(uint(self_29.chroma_height))
    frame.cb.data = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(base))), uint64(luma_plane_size_0), 1)))))))), uint64(chroma_plane_size_0), 1))))))))
    return
}
[export]
def plm_frame_to_bgr(var frame_6 : plm_frame_t?; var dest_0 : uint8?; var stride_0 : int) {
    var cols_0 : int = int(0)
    var rows_0 : int = int(0)
    var yw_0 : int = int(0)
    var cw_0 : int = int(0)
    var row_0 : int = int(0)
    var c_index_0 : int = int(0)
    var y_index_0 : int = int(0)
    var d_index_1 : int = int(0)
    var col_0 : int = int(0)
    var y_12 : int = int(0)
    var cr_0 : int = int(0)
    var cb_0 : int = int(0)
    var r_1 : int = int(0)
    var g_0 : int = int(0)
    var b_0 : int = int(0)
    cols_0 = int(int(int(uint(uint(frame_6.width))) >> int(uint(uint(1)))))
    rows_0 = int(int(int(uint(uint(frame_6.height))) >> int(uint(uint(1)))))
    yw_0 = int(frame_6.y.width)
    cw_0 = int(frame_6.cb.width)
    row_0 = 0
    while (true) {
        if (!(int(row_0) < int(rows_0))) {
            break
        }
        c_index_0 = int(row_0) * int(cw_0)
        y_index_0 = int(row_0) * 2 * int(yw_0)
        d_index_1 = int(row_0) * 2 * int(stride_0)
        col_0 = 0
        while (true) {
            if (!(int(col_0) < int(cols_0))) {
                break
            }
            cr_0 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_6.cr.data)))[uint(c_index_0)]))) - 128
            cb_0 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_6.cb.data)))[uint(c_index_0)]))) - 128
            r_1 = int(int(int(int(cr_0) * 104597 >> 16)))
            g_0 = int(int(int(int(cb_0) * 25674 + int(cr_0) * 53278 >> 16)))
            b_0 = int(int(int(int(cb_0) * 132201 >> 16)))
            y_12 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_6.y.data)))[int(y_index_0) + 0]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (0 + 2)])) = uint8(plm_clamp(int(y_12) + int(r_1)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (0 + 1)])) = uint8(plm_clamp(int(y_12) - int(g_0)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (0 + 0)])) = uint8(plm_clamp(int(y_12) + int(b_0)))
            y_12 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_6.y.data)))[int(y_index_0) + 1]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (3 + 2)])) = uint8(plm_clamp(int(y_12) + int(r_1)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (3 + 1)])) = uint8(plm_clamp(int(y_12) - int(g_0)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (3 + 0)])) = uint8(plm_clamp(int(y_12) + int(b_0)))
            y_12 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_6.y.data)))[int(y_index_0) + int(yw_0)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (int(stride_0) + 2)])) = uint8(plm_clamp(int(y_12) + int(r_1)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (int(stride_0) + 1)])) = uint8(plm_clamp(int(y_12) - int(g_0)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (int(stride_0) + 0)])) = uint8(plm_clamp(int(y_12) + int(b_0)))
            y_12 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_6.y.data)))[int(y_index_0) + (int(yw_0) + 1)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (int(stride_0) + 3) + 2])) = uint8(plm_clamp(int(y_12) + int(r_1)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (int(stride_0) + 3) + 1])) = uint8(plm_clamp(int(y_12) - int(g_0)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_0)))[int(d_index_1) + (int(stride_0) + 3) + 0])) = uint8(plm_clamp(int(y_12) + int(b_0)))
            c_index_0 = int(c_index_0) + 1
            y_index_0 = int(y_index_0) + 2
            d_index_1 = int(d_index_1) + 2 * 3
            col_0 = int(col_0) + 1
            col_0
        }
        row_0 = int(row_0) + 1
        row_0
    }
    return
}
[export]
def plm_demux_decode_packet(var self_18 : plm_demux_t?; var type_0 : int) : plm_packet_t? {
    var pts_dts_marker : int = int(0)
    if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_18.buffer))), uint64(uint64(uint64(16) << uint64(3))))) == uint64(0)) {
        return null
    } else {
        self_18.start_code = -1
        self_18.next_packet.type_0 = type_0
        self_18.next_packet.length = uint64(uint64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_18.buffer))), 16)))
        self_18.next_packet.length = uint64(uint64(self_18.next_packet.length) - uint64(plm_buffer_skip_bytes(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_18.buffer))), uint8(uint8(255)))))
        if (plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_18.buffer))), 2) == 1) {
            plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_18.buffer))), uint64(uint64(16)))
            self_18.next_packet.length = uint64(uint64(self_18.next_packet.length) - uint64(2))
        }
        pts_dts_marker = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_18.buffer))), 2)
        if (int(pts_dts_marker) == 3) {
            self_18.next_packet.pts = plm_demux_decode_time(unsafe(unsafe(reinterpret<plm_demux_t?>(self_18))))
            self_18.last_decoded_pts = self_18.next_packet.pts
            plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_18.buffer))), uint64(uint64(40)))
            self_18.next_packet.length = uint64(uint64(self_18.next_packet.length) - uint64(10))
        } elif (int(pts_dts_marker) == 2) {
            self_18.next_packet.pts = plm_demux_decode_time(unsafe(unsafe(reinterpret<plm_demux_t?>(self_18))))
            self_18.last_decoded_pts = self_18.next_packet.pts
            self_18.next_packet.length = uint64(uint64(self_18.next_packet.length) - uint64(5))
        } elif (uint64(int(pts_dts_marker)) == uint64(0)) {
            self_18.next_packet.pts = double(-1)
            plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_18.buffer))), uint64(uint64(4)))
            self_18.next_packet.length = uint64(uint64(self_18.next_packet.length) - uint64(1))
        } else {
            return null
        }
        return unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_get_packet(unsafe(unsafe(reinterpret<plm_demux_t?>(self_18))))))))))
    }
    return null
}
[export]
def plm_buffer_create_with_capacity(var capacity : uint64) : plm_buffer_t? {
    var self_25 : plm_buffer_t? = null
    self_25 = unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(c2da_malloc(uint64(4)))))))))))
    unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(self_25)))))), int(0), int(4)))
    self_25.capacity = uint64(capacity)
    self_25.free_when_done = 1
    self_25.bytes = unsafe(unsafe(reinterpret<uint8?>(c2da_malloc(uint64(capacity)))))
    self_25.mode = unsafe(reinterpret<plm_buffer_mode>(PLM_BUFFER_MODE_RING))
    self_25.discard_read_bytes = 1
    return unsafe(unsafe(reinterpret<plm_buffer_t?>(self_25)))
    return null
}
[export]
def plm_get_audio_lead_time(var self_63 : plm_t?) : double {
    return self_63.audio_lead_time
    return double(0)
}
[export]
def plm_video_copy_macroblock(var self_96 : plm_video_t?; var s_1 : plm_frame_t?; var motion_h : int; var motion_v : int) {
    var d_1 : plm_frame_t? = null
    d_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_96.frame_current)))))))))))
    plm_video_process_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_96))), unsafe(unsafe(reinterpret<uint8?>(s_1.y.data))), unsafe(unsafe(reinterpret<uint8?>(d_1.y.data))), motion_h, motion_v, 16, 0)
    plm_video_process_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_96))), unsafe(unsafe(reinterpret<uint8?>(s_1.cr.data))), unsafe(unsafe(reinterpret<uint8?>(d_1.cr.data))), int(motion_h) / 2, int(motion_v) / 2, 8, 0)
    plm_video_process_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_96))), unsafe(unsafe(reinterpret<uint8?>(s_1.cb.data))), unsafe(unsafe(reinterpret<uint8?>(d_1.cb.data))), int(motion_h) / 2, int(motion_v) / 2, 8, 0)
    return
}
[export]
def plm_buffer_create_with_memory(var bytes_0 : uint8?; var length_0 : uint64; var free_when_done_0 : int) : plm_buffer_t? {
    var self : plm_buffer_t? = null
    self = unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(c2da_malloc(uint64(4)))))))))))
    unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(self)))))), int(0), int(4)))
    self.capacity = uint64(length_0)
    self.length = uint64(length_0)
    self.total_size = uint64(length_0)
    self.free_when_done = free_when_done_0
    self.bytes = unsafe(unsafe(reinterpret<uint8?>(bytes_0)))
    self.mode = unsafe(reinterpret<plm_buffer_mode>(PLM_BUFFER_MODE_FIXED_MEM))
    self.discard_read_bytes = 0
    return unsafe(unsafe(reinterpret<plm_buffer_t?>(self)))
    return null
}
[export]
def plm_demux_seek(var self_108 : plm_demux_t?; var seek_time : double; var type_4 : int; var force_intra : int) : plm_packet_t? {
    var duration_0 : double = double(0)
    var file_size_0 : int64 = int64(int64(int64(0)))
    var byterate : int64 = int64(int64(int64(0)))
    var cur_time : double = double(0)
    var scan_span : double = double(0)
    var retry : int = int(0)
    var found_packet_with_pts : int = int(0)
    var found_packet_in_range : int = int(0)
    var last_valid_packet_start : int64 = int64(int64(int64(0)))
    var first_packet_time : double = double(0)
    var cur_pos : int64 = int64(int64(int64(0)))
    var offset : int64 = int64(int64(int64(0)))
    var seek_pos_0 : int64 = int64(int64(int64(0)))
    var packet_start : int64 = int64(int64(int64(0)))
    var packet_4 : plm_packet_t? = null
    var i_7 : uint64 = uint64(uint64(uint64(0)))
    if (uint64(plm_demux_has_headers(unsafe(unsafe(reinterpret<plm_demux_t?>(self_108))))) == uint64(0)) {
        return null
    } else {
        duration_0 = plm_demux_get_duration(unsafe(unsafe(reinterpret<plm_demux_t?>(self_108))), type_4)
        file_size_0 = int64(int64(int64(int64(plm_buffer_get_size(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_108.buffer))))))))
        byterate = int64(int64(int64(int64(int64(double(file_size_0)) / int64(double(duration_0))))))
        cur_time = self_108.last_decoded_pts
        scan_span = double(1)
        if (double(seek_time) > double(duration_0)) {
            seek_time = duration_0
        } elif (double(seek_time) < double(0)) {
            seek_time = double(0)
        }
        seek_time = double(seek_time) + double(self_108.start_time)
        retry = 0
        while (true) {
            if (int(retry) < 32) {
                found_packet_with_pts = 0
                found_packet_in_range = 0
                last_valid_packet_start = int64(int64(int64(int64(-1))))
                first_packet_time = double(-1)
                cur_pos = int64(int64(int64(int64(plm_buffer_tell(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_108.buffer))))))))
                offset = int64(int64(int64(int64(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(seek_time)))))))))))))))))))) - int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(int64(double(cur_time)))))))))))))))))))))))))))) - int64(double(int64(double(int64(double(int64(double(scan_span)))))))))) * int64(double(byterate))))))
                seek_pos_0 = int64(int64(int64(int64(cur_pos) + int64(offset))))
                if (int64(seek_pos_0) < int64(0)) {
                    seek_pos_0 = int64(int64(int64(int64(0))))
                } elif (int64(seek_pos_0) > int64(file_size_0) - int64(256)) {
                    seek_pos_0 = int64(int64(int64(int64(file_size_0) - int64(256))))
                }
                plm_demux_buffer_seek(unsafe(unsafe(reinterpret<plm_demux_t?>(self_108))), uint64(uint64(seek_pos_0)))
                while (true) {
                    if (!(plm_buffer_find_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_108.buffer))), type_4) != -1)) {
                        break
                    }
                    packet_start = int64(int64(int64(int64(plm_buffer_tell(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_108.buffer))))))))
                    packet_4 = unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode_packet(unsafe(unsafe(reinterpret<plm_demux_t?>(self_108))), type_4)))))))))))))
                    if (packet_4 == null || double(packet_4.pts) == double(-1)) {
                        continue
                    } elif (double(packet_4.pts) > double(seek_time) || double(packet_4.pts) < double(seek_time) - double(scan_span)) {
                        found_packet_with_pts = 1
                        byterate = int64(int64(int64(int64(int64(double(int64(double(int64(double(int64(double(int64(double(int64(seek_pos_0))))))))) - int64(double(int64(double(int64(double(int64(double(int64(cur_pos))))))))))) / int64(double(int64(double(int64(double(int64(double(int64(double(packet_4.pts)))))))) - int64(double(int64(double(int64(double(int64(double(cur_time))))))))))))))
                        cur_time = packet_4.pts
                        break
                    } else {
                        if (uint64(found_packet_in_range) == uint64(0)) {
                            found_packet_in_range = 1
                            first_packet_time = packet_4.pts
                        }
                        if (uint64(force_intra) != uint64(0)) {
                            i_7 = uint64(uint64(uint64(uint64(0))))
                            while (true) {
                                if (!(uint64(i_7) < uint64(packet_4.length) - uint64(6))) {
                                    break
                                }
                                if (uint64(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(packet_4.data)))[uint(i_7)])))) == uint64(0) && uint64(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(packet_4.data)))[uint(uint(uint64(i_7)) + uint(uint64(1)))])))) == uint64(0) && int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(packet_4.data)))[uint(uint(uint64(i_7)) + uint(uint64(2)))]))) == 1 && uint64(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(packet_4.data)))[uint(uint(uint64(i_7)) + uint(uint64(3)))])))) == uint64(0)) {
                                    if ((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(packet_4.data)))[uint(uint(uint64(i_7)) + uint(uint64(5)))]))) & 56) == 8) {
                                        last_valid_packet_start = int64(int64(int64(packet_start)))
                                    }
                                    break
                                } else {
                                    i_7 = uint64(uint64(uint64(i_7) + uint64(1)))
                                    i_7
                                }
                            }
                        } else {
                            last_valid_packet_start = int64(int64(int64(packet_start)))
                        }
                    }
                }
                if (int64(last_valid_packet_start) != int64(-1)) {
                    plm_demux_buffer_seek(unsafe(unsafe(reinterpret<plm_demux_t?>(self_108))), uint64(uint64(last_valid_packet_start)))
                    return unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode_packet(unsafe(unsafe(reinterpret<plm_demux_t?>(self_108))), type_4)))))))
                } else {
                    if (uint64(found_packet_in_range) != uint64(0)) {
                        scan_span = double(scan_span) * double(2)
                        seek_time = first_packet_time
                    } elif (uint64(found_packet_with_pts) == uint64(0)) {
                        byterate = int64(int64(int64(int64(int64(double(int64(double(int64(double(int64(double(int64(double(int64(seek_pos_0))))))))) - int64(double(int64(double(int64(double(int64(double(int64(cur_pos))))))))))) / int64(double(int64(double(int64(double(int64(double(int64(double(duration_0)))))))) - int64(double(int64(double(int64(double(int64(double(cur_time))))))))))))))
                        cur_time = duration_0
                    }
                    retry = int(retry) + 1
                    retry
                }
            } else {
                return null
            }
        }
    }
    return null
}
[export]
def plm_buffer_next_start_code(var self_21 : plm_buffer_t?) : int {
    var byte_index : uint64 = uint64(uint64(uint64(0)))
    plm_buffer_align(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_21))))
    while (true) {
        if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_21))), uint64(uint64(uint64(5) << uint64(3))))) != uint64(0)) {
            byte_index = uint64(uint64(uint64(uint64(self_21.bit_index) >> uint64(3))))
            if (uint64(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_21.bytes)))[uint(byte_index)])))) == uint64(0) && uint64(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_21.bytes)))[uint(uint(uint64(byte_index)) + uint(uint64(1)))])))) == uint64(0) && int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_21.bytes)))[uint(uint(uint64(byte_index)) + uint(uint64(2)))]))) == 1) {
                self_21.bit_index = uint64(uint64(byte_index) + uint64(4) << uint64(3))
                return int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_21.bytes)))[uint(uint(uint64(byte_index)) + uint(uint64(3)))])))
            } else {
                self_21.bit_index = uint64(uint64(self_21.bit_index) + uint64(8))
            }
        } else {
            return -1
        }
    }
    return int(0)
}
[export]
def plm_buffer_get_size(var self_68 : plm_buffer_t?) : uint64 {
    var c2da_fresh19 : uint64 = uint64(uint64(uint64(0)))
    if (uint(self_68.mode) == uint(PLM_BUFFER_MODE_FILE)) {
        c2da_fresh19 = uint64(uint64(self_68.total_size))
    } else {
        c2da_fresh19 = uint64(uint64(self_68.length))
    }
    return c2da_fresh19
    return uint64(0)
}
[export]
def plm_set_audio_decode_callback(var self_79 : plm_t?; var fp_1 : plm_audio_decode_callback; var user_3 : uint64) {
    self_79.audio_decode_callback = fp_1
    self_79.audio_decode_callback_user_data = user_3
    return
}
[export]
def plm_demux_create(var buffer_5 : plm_buffer_t?; var destroy_when_done_2 : int) : plm_demux_t? {
    var self_32 : plm_demux_t? = null
    self_32 = unsafe(unsafe(reinterpret<plm_demux_t?>(unsafe(unsafe(reinterpret<plm_demux_t?>(unsafe(unsafe(reinterpret<plm_demux_t?>(c2da_malloc(uint64(4)))))))))))
    unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(self_32)))))), int(0), int(4)))
    self_32.buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(buffer_5)))
    self_32.destroy_buffer_when_done = destroy_when_done_2
    self_32.start_time = double(-1)
    self_32.duration = double(-1)
    self_32.start_code = -1
    plm_demux_has_headers(unsafe(unsafe(reinterpret<plm_demux_t?>(self_32))))
    return unsafe(unsafe(reinterpret<plm_demux_t?>(self_32)))
    return null
}
[export]
def plm_seek(var self_105 : plm_t?; var time : double; var seek_exact : int) : int {
    var frame_3 : plm_frame_t? = null
    var start_time : double = double(0)
    var packet_2 : plm_packet_t? = null
    frame_3 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(plm_seek_frame(unsafe(unsafe(reinterpret<plm_t?>(self_105))), time, seek_exact)))))))))))))
    if (frame_3 == null) {
        return 0
    } else {
        if (self_105.video_decode_callback != null) {
            self_105.video_decode_callback(self_105, frame_3, self_105.video_decode_callback_user_data)
        }
        if (uint64(self_105.audio_packet_type) == uint64(0)) {
            return 1
        } else {
            start_time = plm_demux_get_start_time(unsafe(unsafe(reinterpret<plm_demux_t?>(self_105.demux))), self_105.video_packet_type)
            plm_audio_rewind(unsafe(unsafe(reinterpret<plm_audio_t?>(self_105.audio_decoder))))
            packet_2 = null
            while (true) {
                packet_2 = unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode(unsafe(unsafe(reinterpret<plm_demux_t?>(self_105.demux))))))))))))))))
                if (!(packet_2 != null)) {
                    break
                }
                if (int(packet_2.type_0) == int(self_105.video_packet_type)) {
                    plm_buffer_write(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_105.video_buffer))), unsafe(unsafe(reinterpret<uint8?>(packet_2.data))), uint64(packet_2.length))
                } elif (int(packet_2.type_0) == int(self_105.audio_packet_type) && double(packet_2.pts) - double(start_time) > double(self_105.time)) {
                    plm_audio_set_time(unsafe(unsafe(reinterpret<plm_audio_t?>(self_105.audio_decoder))), double(packet_2.pts) - double(start_time))
                    plm_buffer_write(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_105.audio_buffer))), unsafe(unsafe(reinterpret<uint8?>(packet_2.data))), uint64(packet_2.length))
                    plm_decode(unsafe(unsafe(reinterpret<plm_t?>(self_105))), double(0))
                    break
                }
            }
            return 1
        }
    }
    return int(0)
}
[export]
def plm_video_decode(var self_87 : plm_video_t?) : plm_frame_t? {
    var frame_1 : plm_frame_t? = null
    if (uint64(plm_video_has_header(unsafe(unsafe(reinterpret<plm_video_t?>(self_87))))) == uint64(0)) {
        return null
    } else {
        frame_1 = null
        while (true) {
            if (int(self_87.start_code) != int(PLM_START_PICTURE)) {
                self_87.start_code = plm_buffer_find_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_87.buffer))), PLM_START_PICTURE)
                if (int(self_87.start_code) == -1) {
                    if (uint64(self_87.has_reference_frame) != uint64(0) && uint64(self_87.assume_no_b_frames) == uint64(0) && uint64(plm_buffer_has_ended(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_87.buffer))))) != uint64(0) && int(self_87.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_INTRA) || int(self_87.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
                        self_87.has_reference_frame = 0
                        frame_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_87.frame_backward)))))))))))
                        break
                    } else {
                        return null
                    }
                }
            }
            if (plm_buffer_has_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_87.buffer))), PLM_START_PICTURE) == -1 && uint64(plm_buffer_has_ended(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_87.buffer))))) == uint64(0)) {
                return null
            } else {
                plm_buffer_discard_read_bytes(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_87.buffer))))
                plm_video_decode_picture(unsafe(unsafe(reinterpret<plm_video_t?>(self_87))))
                if (uint64(self_87.assume_no_b_frames) != uint64(0)) {
                    frame_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_87.frame_backward)))))))))))
                } elif (int(self_87.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_B)) {
                    frame_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_87.frame_current)))))))))))
                } elif (uint64(self_87.has_reference_frame) != uint64(0)) {
                    frame_1 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(addr(self_87.frame_forward)))))))))))
                } else {
                    self_87.has_reference_frame = 1
                }
                if (!(frame_1 == null)) {
                    break
                }
            }
        }
        frame_1.time = self_87.time
        self_87.frames_decoded = self_87.frames_decoded + 1
        self_87.time = double(self_87.frames_decoded) / double(self_87.framerate)
        return unsafe(unsafe(reinterpret<plm_frame_t?>(frame_1)))
    }
    return null
}
[export]
def plm_get_pixel_aspect_ratio(var self_53 : plm_t?) : double {
    var c2da_fresh12 : double = double(0)
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_53))))) != uint64(0) && self_53.video_decoder != null) {
        c2da_fresh12 = plm_video_get_pixel_aspect_ratio(unsafe(unsafe(reinterpret<plm_video_t?>(self_53.video_decoder))))
    } else {
        c2da_fresh12 = double(0)
    }
    return c2da_fresh12
    return double(0)
}
[export]
def plm_set_loop(var self_76 : plm_t?; var loop : int) {
    self_76.loop = loop
    return
}
[export]
def plm_buffer_destroy(var self_35 : plm_buffer_t?) {
    if (uint64(self_35.free_when_done) != uint64(0)) {
        unsafe(c2da_free(uint64(unsafe(unsafe(reinterpret<uint64>(self_35.bytes))))))
    }
    unsafe(c2da_free(uint64(unsafe(unsafe(reinterpret<uint64>(self_35))))))
    return
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
    if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), uint64(uint64(48)))) == uint64(0)) {
        return 0
    } else {
        plm_buffer_skip_bytes(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), uint8(uint8(0)))
        sync = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 11)
        if (int(sync) != int(PLM_AUDIO_FRAME_SYNC) && uint64(plm_audio_find_frame_sync(unsafe(unsafe(reinterpret<plm_audio_t?>(self_3))))) == uint64(0)) {
            return 0
        } else {
            self_3.version = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 2)
            self_3.layer = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 2)
            hasCRC = int(c2da_bool_to_int(uint64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 1)) == uint64(0)))
            if (int(self_3.version) != int(PLM_AUDIO_MPEG_1) || int(self_3.layer) != int(PLM_AUDIO_LAYER_II)) {
                return 0
            } else {
                bitrate_index = int(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 4)) - 1
                if (int(bitrate_index) > 13) {
                    return 0
                } else {
                    samplerate_index = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 2)
                    if (int(samplerate_index) == 3) {
                        return 0
                    } else {
                        padding = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 1)
                        plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), uint64(uint64(1)))
                        mode = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 2)
                        if (uint64(self_3.has_header) != uint64(0) && int(self_3.bitrate_index) != int(bitrate_index) || int(self_3.samplerate_index) != int(samplerate_index) || int(self_3.mode) != int(mode)) {
                            return 0
                        } else {
                            self_3.bitrate_index = bitrate_index
                            self_3.samplerate_index = samplerate_index
                            self_3.mode = mode
                            self_3.has_header = 1
                            if (int(mode) == int(PLM_AUDIO_MODE_JOINT_STEREO)) {
                                self_3.bound = int(int(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), 2)) + 1 << 2)
                            } else {
                                plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), uint64(uint64(2)))
                                var c2da_fresh0 : int = int(0)
                                if (int(mode) == int(PLM_AUDIO_MODE_MONO)) {
                                    c2da_fresh0 = 0
                                } else {
                                    c2da_fresh0 = 32
                                }
                                self_3.bound = c2da_fresh0
                            }
                            plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), uint64(uint64(4)))
                            if (uint64(hasCRC) != uint64(0)) {
                                plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_3.buffer))), uint64(uint64(16)))
                            }
                            bitrate = unsafe(unsafe(unsafe(addr(PLM_AUDIO_BIT_RATE[0]))[uint(self_3.bitrate_index)]))
                            samplerate = unsafe(unsafe(unsafe(addr(PLM_AUDIO_SAMPLE_RATE[0]))[uint(self_3.samplerate_index)]))
                            frame_size = 144000 * int(bitrate) / int(samplerate) + int(padding)
                            var c2da_fresh1 : int = int(0)
                            if (uint64(hasCRC) != uint64(0)) {
                                c2da_fresh1 = 6
                            } else {
                                c2da_fresh1 = 4
                            }
                            return int(frame_size) - int(c2da_fresh1)
                        }
                    }
                }
            }
        }
    }
    return int(0)
}
[export]
def plm_video_get_width(var self_50 : plm_video_t?) : int {
    var c2da_fresh9 : int = int(0)
    if (uint64(plm_video_has_header(unsafe(unsafe(reinterpret<plm_video_t?>(self_50))))) != uint64(0)) {
        c2da_fresh9 = self_50.width
    } else {
        c2da_fresh9 = 0
    }
    return c2da_fresh9
    return int(0)
}
[export]
def plm_destroy(var self_33 : plm_t?) {
    if (self_33.video_decoder != null) {
        plm_video_destroy(unsafe(unsafe(reinterpret<plm_video_t?>(self_33.video_decoder))))
    }
    if (self_33.audio_decoder != null) {
        plm_audio_destroy(unsafe(unsafe(reinterpret<plm_audio_t?>(self_33.audio_decoder))))
    }
    plm_demux_destroy(unsafe(unsafe(reinterpret<plm_demux_t?>(self_33.demux))))
    unsafe(c2da_free(uint64(unsafe(unsafe(reinterpret<uint64>(self_33))))))
    return
}
[export]
def plm_buffer_has_ended(var self_14 : plm_buffer_t?) : int {
    return self_14.has_ended
    return int(0)
}
[export]
def plm_demux_has_headers(var self_22 : plm_demux_t?) : int {
    if (uint64(self_22.has_headers) != uint64(0)) {
        return 1
    } else {
        if (uint64(self_22.has_pack_header) == uint64(0)) {
            if (int(self_22.start_code) != int(PLM_START_PACK) && plm_buffer_find_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), PLM_START_PACK) == -1) {
                return 0
            } else {
                self_22.start_code = PLM_START_PACK
                if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), uint64(uint64(64)))) == uint64(0)) {
                    return 0
                } else {
                    self_22.start_code = -1
                    if (plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), 4) != 2) {
                        return 0
                    } else {
                        self_22.system_clock_ref = plm_demux_decode_time(unsafe(unsafe(reinterpret<plm_demux_t?>(self_22))))
                        plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), uint64(uint64(1)))
                        plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), uint64(uint64(22)))
                        plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), uint64(uint64(1)))
                        self_22.has_pack_header = 1
                    }
                }
            }
        }
        if (uint64(self_22.has_system_header) == uint64(0)) {
            if (int(self_22.start_code) != int(PLM_START_SYSTEM) && plm_buffer_find_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), PLM_START_SYSTEM) == -1) {
                return 0
            } else {
                self_22.start_code = PLM_START_SYSTEM
                if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), uint64(uint64(56)))) == uint64(0)) {
                    return 0
                } else {
                    self_22.start_code = -1
                    plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), uint64(uint64(16)))
                    plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), uint64(uint64(24)))
                    self_22.num_audio_streams = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), 6)
                    plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), uint64(uint64(5)))
                    self_22.num_video_streams = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_22.buffer))), 5)
                    self_22.has_system_header = 1
                }
            }
        }
        self_22.has_headers = 1
        return 1
    }
    return int(0)
}
[export]
def plm_set_audio_lead_time(var self_64 : plm_t?; var lead_time : double) {
    self_64.audio_lead_time = lead_time
    return
}
[export]
def plm_video_create_with_buffer(var buffer_3 : plm_buffer_t?; var destroy_when_done_1 : int) : plm_video_t? {
    var self_27 : plm_video_t? = null
    self_27 = unsafe(unsafe(reinterpret<plm_video_t?>(unsafe(unsafe(reinterpret<plm_video_t?>(unsafe(unsafe(reinterpret<plm_video_t?>(c2da_malloc(uint64(4)))))))))))
    unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(self_27)))))), int(0), int(4)))
    self_27.buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(buffer_3)))
    self_27.destroy_buffer_when_done = destroy_when_done_1
    self_27.start_code = plm_buffer_find_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_27.buffer))), PLM_START_SEQUENCE)
    if (int(self_27.start_code) != -1) {
        plm_video_decode_sequence_header(unsafe(unsafe(reinterpret<plm_video_t?>(self_27))))
    }
    return unsafe(unsafe(reinterpret<plm_video_t?>(self_27)))
    return null
}
[export]
def plm_get_height(var self_51 : plm_t?) : int {
    var c2da_fresh10 : int = int(0)
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_51))))) != uint64(0) && self_51.video_decoder != null) {
        c2da_fresh10 = plm_video_get_height(unsafe(unsafe(reinterpret<plm_video_t?>(self_51.video_decoder))))
    } else {
        c2da_fresh10 = 0
    }
    return c2da_fresh10
    return int(0)
}
[export]
def plm_video_get_framerate(var self_56 : plm_video_t?) : double {
    var c2da_fresh15 : double = double(0)
    if (uint64(plm_video_has_header(unsafe(unsafe(reinterpret<plm_video_t?>(self_56))))) != uint64(0)) {
        c2da_fresh15 = self_56.framerate
    } else {
        c2da_fresh15 = double(0)
    }
    return c2da_fresh15
    return double(0)
}
[export]
def plm_video_process_macroblock(var self_97 : plm_video_t?; var s_2 : uint8?; var d_2 : uint8?; var motion_h_0 : int; var motion_v_0 : int; var block_size : int; var interpolate : int) {
    var dw_0 : int = int(0)
    var hp : int = int(0)
    var vp : int = int(0)
    var odd_h : int = int(0)
    var odd_v : int = int(0)
    var si_0 : uint = uint(uint(uint(0)))
    var di_0 : uint = uint(uint(uint(0)))
    var max_address : uint = uint(uint(uint(0)))
    var dest_scan_3 : int = int(0)
    var source_scan_3 : int = int(0)
    var y_3 : int = int(0)
    var x_3 : int = int(0)
    var dest_scan_4 : int = int(0)
    var source_scan_4 : int = int(0)
    var y_4 : int = int(0)
    var x_4 : int = int(0)
    var dest_scan_5 : int = int(0)
    var source_scan_5 : int = int(0)
    var y_5 : int = int(0)
    var x_5 : int = int(0)
    var dest_scan_6 : int = int(0)
    var source_scan_6 : int = int(0)
    var y_6 : int = int(0)
    var x_6 : int = int(0)
    var dest_scan_7 : int = int(0)
    var source_scan_7 : int = int(0)
    var y_7 : int = int(0)
    var x_7 : int = int(0)
    var dest_scan_8 : int = int(0)
    var source_scan_8 : int = int(0)
    var y_8 : int = int(0)
    var x_8 : int = int(0)
    var dest_scan_9 : int = int(0)
    var source_scan_9 : int = int(0)
    var y_9 : int = int(0)
    var x_9 : int = int(0)
    var dest_scan_10 : int = int(0)
    var source_scan_10 : int = int(0)
    var y_10 : int = int(0)
    var x_10 : int = int(0)
    dw_0 = int(self_97.mb_width) * int(block_size)
    hp = int(int(int(int(motion_h_0) >> 1)))
    vp = int(int(int(int(motion_v_0) >> 1)))
    odd_h = int(int(int(c2da_bool_to_int((int(motion_h_0) & 1) == 1))))
    odd_v = int(int(int(c2da_bool_to_int((int(motion_v_0) & 1) == 1))))
    si_0 = uint(uint(uint(uint((uint(int(self_97.mb_row)) * uint(int(block_size)) + uint(int(vp))) * uint(int(dw_0)) + uint(int(self_97.mb_col)) * uint(int(block_size)) + uint(int(hp))))))
    di_0 = uint(uint(uint(uint((uint(int(self_97.mb_row)) * uint(int(dw_0)) + uint(int(self_97.mb_col))) * uint(int(block_size))))))
    max_address = uint(uint(uint(uint(uint(int(dw_0)) * (uint(int(self_97.mb_height)) * uint(int(block_size)) - uint(int(block_size)) + uint(1)) - uint(int(block_size))))))
    if (uint(si_0) > uint(max_address) || uint(di_0) > uint(max_address)) {
        return
    } else {
        if (uint64(int(interpolate) << 2 | int(odd_h) << 1 | int(odd_v)) == uint64(0)) {
            while (true) {
                dest_scan_3 = int(dw_0) - int(block_size)
                source_scan_3 = int(dw_0) - int(block_size)
                y_3 = 0
                while (true) {
                    if (!(int(y_3) < int(block_size))) {
                        break
                    }
                    x_3 = 0
                    while (true) {
                        if (!(int(x_3) < int(block_size))) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)])) = uint8(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0)])))
                        si_0 = uint(uint(uint(si_0) + uint(1)))
                        di_0 = uint(uint(uint(di_0) + uint(1)))
                        x_3 = int(x_3) + 1
                        x_3
                    }
                    si_0 = uint(uint(uint(uint(si_0) + uint(source_scan_3))))
                    di_0 = uint(uint(uint(uint(di_0) + uint(dest_scan_3))))
                    y_3 = int(y_3) + 1
                    y_3
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
        } elif ((int(interpolate) << 2 | int(odd_h) << 1 | int(odd_v)) == 1) {
            while (true) {
                dest_scan_4 = int(dw_0) - int(block_size)
                source_scan_4 = int(dw_0) - int(block_size)
                y_4 = 0
                while (true) {
                    if (!(int(y_4) < int(block_size))) {
                        break
                    }
                    x_4 = 0
                    while (true) {
                        if (!(int(x_4) < int(block_size))) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)])) = uint8(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0)]))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + uint(dw_0)]))))))) + uint(uint8(1)))) >> uint(uint8(1))))
                        si_0 = uint(uint(uint(si_0) + uint(1)))
                        di_0 = uint(uint(uint(di_0) + uint(1)))
                        x_4 = int(x_4) + 1
                        x_4
                    }
                    si_0 = uint(uint(uint(uint(si_0) + uint(source_scan_4))))
                    di_0 = uint(uint(uint(uint(di_0) + uint(dest_scan_4))))
                    y_4 = int(y_4) + 1
                    y_4
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
        } elif ((int(interpolate) << 2 | int(odd_h) << 1 | int(odd_v)) == 2) {
            while (true) {
                dest_scan_5 = int(dw_0) - int(block_size)
                source_scan_5 = int(dw_0) - int(block_size)
                y_5 = 0
                while (true) {
                    if (!(int(y_5) < int(block_size))) {
                        break
                    }
                    x_5 = 0
                    while (true) {
                        if (!(int(x_5) < int(block_size))) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)])) = uint8(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0)]))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + uint(1)]))))))) + uint(uint8(1)))) >> uint(uint8(1))))
                        si_0 = uint(uint(uint(si_0) + uint(1)))
                        di_0 = uint(uint(uint(di_0) + uint(1)))
                        x_5 = int(x_5) + 1
                        x_5
                    }
                    si_0 = uint(uint(uint(uint(si_0) + uint(source_scan_5))))
                    di_0 = uint(uint(uint(uint(di_0) + uint(dest_scan_5))))
                    y_5 = int(y_5) + 1
                    y_5
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
        } elif ((int(interpolate) << 2 | int(odd_h) << 1 | int(odd_v)) == 3) {
            while (true) {
                dest_scan_6 = int(dw_0) - int(block_size)
                source_scan_6 = int(dw_0) - int(block_size)
                y_6 = 0
                while (true) {
                    if (!(int(y_6) < int(block_size))) {
                        break
                    }
                    x_6 = 0
                    while (true) {
                        if (!(int(x_6) < int(block_size))) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)])) = uint8(uint8(uint(uint8(uint(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0)]))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + uint(1)]))))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + uint(dw_0)]))))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + (uint(dw_0) + uint(1))]))))))) + uint(uint8(2)))) >> uint(uint8(2))))
                        si_0 = uint(uint(uint(si_0) + uint(1)))
                        di_0 = uint(uint(uint(di_0) + uint(1)))
                        x_6 = int(x_6) + 1
                        x_6
                    }
                    si_0 = uint(uint(uint(uint(si_0) + uint(source_scan_6))))
                    di_0 = uint(uint(uint(uint(di_0) + uint(dest_scan_6))))
                    y_6 = int(y_6) + 1
                    y_6
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
        } elif ((int(interpolate) << 2 | int(odd_h) << 1 | int(odd_v)) == 4) {
            while (true) {
                dest_scan_7 = int(dw_0) - int(block_size)
                source_scan_7 = int(dw_0) - int(block_size)
                y_7 = 0
                while (true) {
                    if (!(int(y_7) < int(block_size))) {
                        break
                    }
                    x_7 = 0
                    while (true) {
                        if (!(int(x_7) < int(block_size))) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)])) = uint8(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)]))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0)]))))))) + uint(uint8(1)))) >> uint(uint8(1))))
                        si_0 = uint(uint(uint(si_0) + uint(1)))
                        di_0 = uint(uint(uint(di_0) + uint(1)))
                        x_7 = int(x_7) + 1
                        x_7
                    }
                    si_0 = uint(uint(uint(uint(si_0) + uint(source_scan_7))))
                    di_0 = uint(uint(uint(uint(di_0) + uint(dest_scan_7))))
                    y_7 = int(y_7) + 1
                    y_7
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
        } elif ((int(interpolate) << 2 | int(odd_h) << 1 | int(odd_v)) == 5) {
            while (true) {
                dest_scan_8 = int(dw_0) - int(block_size)
                source_scan_8 = int(dw_0) - int(block_size)
                y_8 = 0
                while (true) {
                    if (!(int(y_8) < int(block_size))) {
                        break
                    }
                    x_8 = 0
                    while (true) {
                        if (!(int(x_8) < int(block_size))) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)])) = uint8(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)]))))) + uint(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0)]))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + uint(dw_0)]))))))) + uint(uint8(1)))) >> uint(uint8(1)))))) + uint(uint8(1)))) >> uint(uint8(1))))
                        si_0 = uint(uint(uint(si_0) + uint(1)))
                        di_0 = uint(uint(uint(di_0) + uint(1)))
                        x_8 = int(x_8) + 1
                        x_8
                    }
                    si_0 = uint(uint(uint(uint(si_0) + uint(source_scan_8))))
                    di_0 = uint(uint(uint(uint(di_0) + uint(dest_scan_8))))
                    y_8 = int(y_8) + 1
                    y_8
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
        } elif ((int(interpolate) << 2 | int(odd_h) << 1 | int(odd_v)) == 6) {
            while (true) {
                dest_scan_9 = int(dw_0) - int(block_size)
                source_scan_9 = int(dw_0) - int(block_size)
                y_9 = 0
                while (true) {
                    if (!(int(y_9) < int(block_size))) {
                        break
                    }
                    x_9 = 0
                    while (true) {
                        if (!(int(x_9) < int(block_size))) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)])) = uint8(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)]))))) + uint(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0)]))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + uint(1)]))))))) + uint(uint8(1)))) >> uint(uint8(1)))))) + uint(uint8(1)))) >> uint(uint8(1))))
                        si_0 = uint(uint(uint(si_0) + uint(1)))
                        di_0 = uint(uint(uint(di_0) + uint(1)))
                        x_9 = int(x_9) + 1
                        x_9
                    }
                    si_0 = uint(uint(uint(uint(si_0) + uint(source_scan_9))))
                    di_0 = uint(uint(uint(uint(di_0) + uint(dest_scan_9))))
                    y_9 = int(y_9) + 1
                    y_9
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
        } elif ((int(interpolate) << 2 | int(odd_h) << 1 | int(odd_v)) == 7) {
            while (true) {
                dest_scan_10 = int(dw_0) - int(block_size)
                source_scan_10 = int(dw_0) - int(block_size)
                y_10 = 0
                while (true) {
                    if (!(int(y_10) < int(block_size))) {
                        break
                    }
                    x_10 = 0
                    while (true) {
                        if (!(int(x_10) < int(block_size))) {
                            break
                        }
                        unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)])) = uint8(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(d_2)))[uint(di_0)]))))) + uint(uint8(uint(uint8(uint(uint8(uint(uint8(uint(uint8(uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0)]))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + uint(1)]))))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + uint(dw_0)]))))))) + uint(uint8(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(s_2)))[uint(si_0) + (uint(dw_0) + uint(1))]))))))) + uint(uint8(2)))) >> uint(uint8(2)))))) + uint(uint8(1)))) >> uint(uint8(1))))
                        si_0 = uint(uint(uint(si_0) + uint(1)))
                        di_0 = uint(uint(uint(di_0) + uint(1)))
                        x_10 = int(x_10) + 1
                        x_10
                    }
                    si_0 = uint(uint(uint(uint(si_0) + uint(source_scan_10))))
                    di_0 = uint(uint(uint(uint(di_0) + uint(dest_scan_10))))
                    y_10 = int(y_10) + 1
                    y_10
                }
                if (!(uint64(0) != uint64(0))) {
                    break
                }
            }
        }
        return
    }
}
[export]
def plm_decode_audio(var self_104 : plm_t?) : plm_samples_t? {
    var samples_0 : plm_samples_t? = null
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_104))))) == uint64(0)) {
        return null
    } elif (uint64(self_104.audio_packet_type) == uint64(0)) {
        return null
    } else {
        samples_0 = unsafe(unsafe(reinterpret<plm_samples_t?>(unsafe(unsafe(reinterpret<plm_samples_t?>(unsafe(unsafe(reinterpret<plm_samples_t?>(unsafe(unsafe(reinterpret<plm_samples_t?>(plm_audio_decode(unsafe(unsafe(reinterpret<plm_audio_t?>(self_104.audio_decoder))))))))))))))))
        if (samples_0 != null) {
            self_104.time = samples_0.time
        } elif (uint64(plm_demux_has_ended(unsafe(unsafe(reinterpret<plm_demux_t?>(self_104.demux))))) != uint64(0)) {
            plm_handle_end(unsafe(unsafe(reinterpret<plm_t?>(self_104))))
        }
        return unsafe(unsafe(reinterpret<plm_samples_t?>(samples_0)))
    }
    return null
}
[export]
def plm_buffer_create_for_appending(var initial_capacity : uint64) : plm_buffer_t? {
    var self_111 : plm_buffer_t? = null
    self_111 = unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(plm_buffer_create_with_capacity(uint64(initial_capacity))))))))))))))
    self_111.mode = unsafe(reinterpret<plm_buffer_mode>(PLM_BUFFER_MODE_APPEND))
    self_111.discard_read_bytes = 0
    return unsafe(unsafe(reinterpret<plm_buffer_t?>(self_111)))
    return null
}
[export]
def plm_audio_set_time(var self_106 : plm_audio_t?; var time_0 : double) {
    self_106.samples_decoded = int(int(double(time_0)) * int(double(unsafe(unsafe(unsafe(addr(PLM_AUDIO_SAMPLE_RATE[0]))[uint(self_106.samplerate_index)])))))
    self_106.time = time_0
    return
}
[export]
def plm_demux_get_start_time(var self_69 : plm_demux_t?; var type_2 : int) : double {
    var previous_pos_1 : int = int(0)
    var previous_start_code_0 : int = int(0)
    var packet_1 : plm_packet_t? = null
    if (double(self_69.start_time) != double(-1)) {
        return self_69.start_time
    } else {
        previous_pos_1 = int(plm_buffer_tell(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_69.buffer)))))
        previous_start_code_0 = self_69.start_code
        plm_demux_rewind(unsafe(unsafe(reinterpret<plm_demux_t?>(self_69))))
        while (true) {
            packet_1 = unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode(unsafe(unsafe(reinterpret<plm_demux_t?>(self_69))))))))))))))))
            if (packet_1 == null) {
                break
            } else {
                if (int(packet_1.type_0) == int(type_2)) {
                    self_69.start_time = packet_1.pts
                }
                if (!(double(self_69.start_time) == double(-1))) {
                    break
                }
            }
        }
        plm_demux_buffer_seek(unsafe(unsafe(reinterpret<plm_demux_t?>(self_69))), uint64(uint64(previous_pos_1)))
        self_69.start_code = previous_start_code_0
        return self_69.start_time
    }
    return double(0)
}
[export]
def plm_get_time(var self_65 : plm_t?) : double {
    return self_65.time
    return double(0)
}
[export]
def plm_buffer_write(var self_15 : plm_buffer_t?; var bytes_1 : uint8?; var length_1 : uint64) : uint64 {
    var bytes_available : uint64 = uint64(uint64(uint64(0)))
    var new_size : uint64 = uint64(uint64(uint64(0)))
    if (uint(self_15.mode) == uint(PLM_BUFFER_MODE_FIXED_MEM)) {
        return uint64(0)
    } else {
        if (uint64(self_15.discard_read_bytes) != uint64(0)) {
            plm_buffer_discard_read_bytes(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_15))))
            if (uint(self_15.mode) == uint(PLM_BUFFER_MODE_RING)) {
                self_15.total_size = uint64(uint64(0))
            }
        }
        bytes_available = uint64(uint64(uint64(uint64(self_15.capacity) - uint64(self_15.length))))
        if (uint64(bytes_available) < uint64(length_1)) {
            new_size = uint64(uint64(uint64(self_15.capacity)))
            while (true) {
                new_size = uint64(uint64(uint64(uint64(new_size) * uint64(2))))
                if (!(uint64(new_size) - uint64(self_15.length) < uint64(length_1))) {
                    break
                }
            }
            self_15.bytes = unsafe(unsafe(reinterpret<uint8?>(unsafe(realloc(uint64(unsafe(unsafe(reinterpret<uint64>(self_15.bytes)))), uint64(new_size))))))
            self_15.capacity = uint64(new_size)
        }
        unsafe(memcpy(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(self_15.bytes))), uint64(self_15.length), 1))))))))), uint64(unsafe(unsafe(reinterpret<uint64>(bytes_1)))), uint64(length_1)))
        self_15.length = uint64(uint64(self_15.length) + uint64(length_1))
        self_15.has_ended = 0
        return length_1
    }
    return uint64(0)
}
[export]
def plm_handle_end(var self_81 : plm_t?) {
    if (uint64(self_81.loop) != uint64(0)) {
        plm_rewind(unsafe(unsafe(reinterpret<plm_t?>(self_81))))
    } else {
        self_81.has_ended = 1
    }
    return
}
[export]
def plm_create_with_memory(var bytes : uint8?; var length : uint64; var free_when_done : int) : plm_t? {
    var buffer : plm_buffer_t? = null
    buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(unsafe(unsafe(reinterpret<plm_buffer_t?>(plm_buffer_create_with_memory(unsafe(unsafe(reinterpret<uint8?>(bytes))), uint64(length), free_when_done)))))))))))))
    return unsafe(unsafe(reinterpret<plm_t?>(unsafe(unsafe(reinterpret<plm_t?>(plm_create_with_buffer(unsafe(unsafe(reinterpret<plm_buffer_t?>(buffer))), 1)))))))
    return null
}
[export]
def plm_video_has_ended(var self_114 : plm_video_t?) : int {
    return plm_buffer_has_ended(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_114.buffer))))
    return int(0)
}
[export]
def plm_buffer_tell(var self_43 : plm_buffer_t?) : uint64 {
    var c2da_fresh6 : uint64 = uint64(uint64(uint64(0)))
    if (self_43.tell_callback != null) {
        c2da_fresh6 = uint64(uint64(uint64(self_43.tell_callback(self_43, self_43.load_callback_user_data)) + (uint64(self_43.bit_index) >> uint64(3)) - uint64(self_43.length)))
    } else {
        c2da_fresh6 = uint64(uint64(uint64(self_43.bit_index) >> uint64(3)))
    }
    return c2da_fresh6
    return uint64(0)
}
[export]
def plm_demux_get_num_audio_streams(var self_26 : plm_demux_t?) : int {
    var c2da_fresh3 : int = int(0)
    if (uint64(plm_demux_has_headers(unsafe(unsafe(reinterpret<plm_demux_t?>(self_26))))) != uint64(0)) {
        c2da_fresh3 = self_26.num_audio_streams
    } else {
        c2da_fresh3 = 0
    }
    return c2da_fresh3
    return int(0)
}
[export]
def plm_get_duration(var self_66 : plm_t?) : double {
    return plm_demux_get_duration(unsafe(unsafe(reinterpret<plm_demux_t?>(self_66.demux))), PLM_DEMUX_PACKET_VIDEO_1)
    return double(0)
}
[export]
def plm_decode_video(var self_103 : plm_t?) : plm_frame_t? {
    var frame_2 : plm_frame_t? = null
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_103))))) == uint64(0)) {
        return null
    } elif (uint64(self_103.video_packet_type) == uint64(0)) {
        return null
    } else {
        frame_2 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(plm_video_decode(unsafe(unsafe(reinterpret<plm_video_t?>(self_103.video_decoder))))))))))))))))
        if (frame_2 != null) {
            self_103.time = frame_2.time
        } elif (uint64(plm_demux_has_ended(unsafe(unsafe(reinterpret<plm_demux_t?>(self_103.demux))))) != uint64(0)) {
            plm_handle_end(unsafe(unsafe(reinterpret<plm_t?>(self_103))))
        }
        return unsafe(unsafe(reinterpret<plm_frame_t?>(frame_2)))
    }
    return null
}
[export]
def plm_set_video_decode_callback(var self_78 : plm_t?; var fp_0 : plm_video_decode_callback; var user_2 : uint64) {
    self_78.video_decode_callback = fp_0
    self_78.video_decode_callback_user_data = user_2
    return
}
[export]
def plm_buffer_discard_read_bytes(var self_16 : plm_buffer_t?) {
    var byte_pos : uint64 = uint64(uint64(uint64(0)))
    byte_pos = uint64(uint64(uint64(uint64(self_16.bit_index) >> uint64(3))))
    if (uint64(byte_pos) == uint64(self_16.length)) {
        self_16.bit_index = uint64(uint64(0))
        self_16.length = uint64(uint64(0))
    } elif (uint64(byte_pos) > uint64(0)) {
        unsafe(memmove(uint64(unsafe(unsafe(reinterpret<uint64>(self_16.bytes)))), uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(self_16.bytes))), uint64(byte_pos), 1))))))))), uint64(uint64(self_16.length) - uint64(byte_pos))))
        self_16.bit_index = uint64(uint64(self_16.bit_index) - (uint64(byte_pos) << uint64(3)))
        self_16.length = uint64(uint64(self_16.length) - uint64(byte_pos))
    }
    return
}
[export]
def plm_video_has_header(var self_40 : plm_video_t?) : int {
    if (uint64(self_40.has_sequence_header) != uint64(0)) {
        return 1
    } else {
        if (int(self_40.start_code) != int(PLM_START_SEQUENCE)) {
            self_40.start_code = plm_buffer_find_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_40.buffer))), PLM_START_SEQUENCE)
        }
        if (int(self_40.start_code) == -1) {
            return 0
        } elif (uint64(plm_video_decode_sequence_header(unsafe(unsafe(reinterpret<plm_video_t?>(self_40))))) == uint64(0)) {
            return 0
        } else {
            return 1
        }
    }
    return int(0)
}
[export]
def plm_probe(var self_41 : plm_t?; var probesize : uint64) : int {
    var found_streams : int = int(0)
    found_streams = plm_demux_probe(unsafe(unsafe(reinterpret<plm_demux_t?>(self_41.demux))), uint64(probesize))
    if (uint64(found_streams) == uint64(0)) {
        return 0
    } else {
        self_41.has_decoders = 0
        self_41.video_packet_type = 0
        self_41.audio_packet_type = 0
        return plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_41))))
    }
    return int(0)
}
[export]
def plm_video_decode_motion_vector(var self_100 : plm_video_t?; var r_size_1 : int; var motion : int) : int {
    var fscale : int = int(0)
    var m_code : int = int(0)
    var r : int = int(0)
    var d_4 : int = int(0)
    fscale = 1 << int(r_size_1)
    m_code = int(plm_buffer_read_vlc(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_100.buffer))), unsafe(unsafe(reinterpret<plm_vlc_t const?>(unsafe(addr(PLM_VIDEO_MOTION[0])))))))
    r = 0
    if (uint64(int(m_code)) != uint64(0) && int(fscale) != 1) {
        r = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_100.buffer))), r_size_1)
        d_4 = (int(abs(m_code)) - 1 << int(r_size_1)) + r + 1
        if (int(m_code) < 0) {
            d_4 = -d_4
        }
    } else {
        d_4 = m_code
    }
    motion = int(motion) + int(d_4)
    if (int(motion) > (int(fscale) << 4) - 1) {
        motion = int(int(int(int(motion) - (int(fscale) << 5))))
    } elif (int(motion) < int(int(uint(uint(-fscale))) << int(uint(uint(4))))) {
        motion = int(int(int(int(motion) + (int(fscale) << 5))))
    }
    return motion
    return int(0)
}
[export]
def plm_get_loop(var self_75 : plm_t?) : int {
    return self_75.loop
    return int(0)
}
[export]
def plm_buffer_skip(var self_6 : plm_buffer_t?; var count_1 : uint64) {
    if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_6))), uint64(count_1))) != uint64(0)) {
        self_6.bit_index = uint64(uint64(self_6.bit_index) + uint64(count_1))
    }
    return
}
[export]
def plm_buffer_signal_end(var self_12 : plm_buffer_t?) {
    self_12.total_size = uint64(self_12.length)
    return
}
[export]
def plm_create_with_buffer(var buffer_0 : plm_buffer_t?; var destroy_when_done : int) : plm_t? {
    var self_0 : plm_t? = null
    self_0 = unsafe(unsafe(reinterpret<plm_t?>(unsafe(unsafe(reinterpret<plm_t?>(unsafe(unsafe(reinterpret<plm_t?>(c2da_malloc(uint64(4)))))))))))
    unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(self_0)))))), int(0), int(4)))
    self_0.demux = unsafe(unsafe(reinterpret<plm_demux_t?>(unsafe(unsafe(reinterpret<plm_demux_t?>(plm_demux_create(unsafe(unsafe(reinterpret<plm_buffer_t?>(buffer_0))), destroy_when_done)))))))
    self_0.video_enabled = 1
    self_0.audio_enabled = 1
    plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_0))))
    return unsafe(unsafe(reinterpret<plm_t?>(self_0)))
    return null
}
[export]
def plm_video_get_pixel_aspect_ratio(var self_54 : plm_video_t?) : double {
    var c2da_fresh13 : double = double(0)
    if (uint64(plm_video_has_header(unsafe(unsafe(reinterpret<plm_video_t?>(self_54))))) != uint64(0)) {
        c2da_fresh13 = self_54.pixel_aspect_ratio
    } else {
        c2da_fresh13 = double(0)
    }
    return c2da_fresh13
    return double(0)
}
[export]
def plm_demux_decode_time(var self_20 : plm_demux_t?) : double {
    var clock : int64 = int64(int64(int64(0)))
    clock = int64(int64(int64(int64(int64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_20.buffer))), 3)) << int64(30)))))
    plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_20.buffer))), uint64(uint64(1)))
    clock = int64(int64(int64(int64(clock) | int64(int64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_20.buffer))), 15)) << int64(15)))))
    plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_20.buffer))), uint64(uint64(1)))
    clock = int64(int64(int64(int64(clock) | int64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_20.buffer))), 15)))))
    plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_20.buffer))), uint64(uint64(1)))
    return double(clock) / double(double(90000.0))
    return double(0)
}
[export]
def plm_frame_to_rgba(var frame_7 : plm_frame_t?; var dest_1 : uint8?; var stride_1 : int) {
    var cols_1 : int = int(0)
    var rows_1 : int = int(0)
    var yw_1 : int = int(0)
    var cw_1 : int = int(0)
    var row_1 : int = int(0)
    var c_index_1 : int = int(0)
    var y_index_1 : int = int(0)
    var d_index_2 : int = int(0)
    var col_1 : int = int(0)
    var y_13 : int = int(0)
    var cr_1 : int = int(0)
    var cb_1 : int = int(0)
    var r_2 : int = int(0)
    var g_1 : int = int(0)
    var b_1 : int = int(0)
    cols_1 = int(int(int(uint(uint(frame_7.width))) >> int(uint(uint(1)))))
    rows_1 = int(int(int(uint(uint(frame_7.height))) >> int(uint(uint(1)))))
    yw_1 = int(frame_7.y.width)
    cw_1 = int(frame_7.cb.width)
    row_1 = 0
    while (true) {
        if (!(int(row_1) < int(rows_1))) {
            break
        }
        c_index_1 = int(row_1) * int(cw_1)
        y_index_1 = int(row_1) * 2 * int(yw_1)
        d_index_2 = int(row_1) * 2 * int(stride_1)
        col_1 = 0
        while (true) {
            if (!(int(col_1) < int(cols_1))) {
                break
            }
            cr_1 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_7.cr.data)))[uint(c_index_1)]))) - 128
            cb_1 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_7.cb.data)))[uint(c_index_1)]))) - 128
            r_2 = int(int(int(int(cr_1) * 104597 >> 16)))
            g_1 = int(int(int(int(cb_1) * 25674 + int(cr_1) * 53278 >> 16)))
            b_1 = int(int(int(int(cb_1) * 132201 >> 16)))
            y_13 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_7.y.data)))[int(y_index_1) + 0]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (0 + 0)])) = uint8(plm_clamp(int(y_13) + int(r_2)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (0 + 1)])) = uint8(plm_clamp(int(y_13) - int(g_1)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (0 + 2)])) = uint8(plm_clamp(int(y_13) + int(b_1)))
            y_13 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_7.y.data)))[int(y_index_1) + 1]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (4 + 0)])) = uint8(plm_clamp(int(y_13) + int(r_2)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (4 + 1)])) = uint8(plm_clamp(int(y_13) - int(g_1)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (4 + 2)])) = uint8(plm_clamp(int(y_13) + int(b_1)))
            y_13 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_7.y.data)))[int(y_index_1) + int(yw_1)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (int(stride_1) + 0)])) = uint8(plm_clamp(int(y_13) + int(r_2)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (int(stride_1) + 1)])) = uint8(plm_clamp(int(y_13) - int(g_1)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (int(stride_1) + 2)])) = uint8(plm_clamp(int(y_13) + int(b_1)))
            y_13 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_7.y.data)))[int(y_index_1) + (int(yw_1) + 1)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (int(stride_1) + 4) + 0])) = uint8(plm_clamp(int(y_13) + int(r_2)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (int(stride_1) + 4) + 1])) = uint8(plm_clamp(int(y_13) - int(g_1)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_1)))[int(d_index_2) + (int(stride_1) + 4) + 2])) = uint8(plm_clamp(int(y_13) + int(b_1)))
            c_index_1 = int(c_index_1) + 1
            y_index_1 = int(y_index_1) + 2
            d_index_2 = int(d_index_2) + 2 * 4
            col_1 = int(col_1) + 1
            col_1
        }
        row_1 = int(row_1) + 1
        row_1
    }
    return
}
[export]
def plm_buffer_get_remaining(var self_112 : plm_buffer_t?) : uint64 {
    return uint64(self_112.length) - (uint64(self_112.bit_index) >> uint64(3))
    return uint64(0)
}
[export]
def plm_video_set_no_delay(var self_113 : plm_video_t?; var no_delay : int) {
    self_113.assume_no_b_frames = no_delay
    return
}
[export]
def plm_buffer_read_vlc_uint(var self_93 : plm_buffer_t?; var table_1 : plm_vlc_uint_t const?) : uint16 {
    return uint16(plm_buffer_read_vlc(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_93))), unsafe(unsafe(reinterpret<plm_vlc_t const?>(table_1)))))
    return uint16(0)
}
[export]
def plm_audio_decode_frame(var self_83 : plm_audio_t?) {
    var tab3 : int = int(0)
    var sblimit : int = int(0)
    var tab1 : int = int(0)
    var tab2 : int = int(0)
    var sb : int = int(0)
    var sb_0 : int = int(0)
    var channels : int = int(0)
    var sb_1 : int = int(0)
    var ch : int = int(0)
    var sb_2 : int = int(0)
    var ch_0 : int = int(0)
    var sf : int? = null
    var out_pos : int = int(0)
    var part : int = int(0)
    var granule : int = int(0)
    var sb_3 : int = int(0)
    var sb_4 : int = int(0)
    var sb_5 : int = int(0)
    var p : int = int(0)
    var ch_1 : int = int(0)
    var d_index : int = int(0)
    var v_index : int = int(0)
    var i_3 : int = int(0)
    var i_4 : int = int(0)
    var j : int = int(0)
    tab3 = 0
    sblimit = 0
    var c2da_fresh20 : int = int(0)
    if (int(self_83.mode) == int(PLM_AUDIO_MODE_MONO)) {
        c2da_fresh20 = 0
    } else {
        c2da_fresh20 = 1
    }
    tab1 = c2da_fresh20
    tab2 = int(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(PLM_AUDIO_QUANT_LUT_STEP_1[0]))[uint(tab1)]))[0])))[uint(self_83.bitrate_index)])))
    tab3 = int(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(QUANT_LUT_STEP_2[0]))[uint(tab2)]))[0])))[uint(self_83.samplerate_index)])))
    sblimit = int(int(int(int(tab3) & 63)))
    tab3 = int(int(int(int(tab3) >> 6)))
    if (int(self_83.bound) > int(sblimit)) {
        self_83.bound = sblimit
    }
    sb = 0
    while (true) {
        if (!(int(sb) < int(self_83.bound))) {
            break
        }
        unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.allocation[0]))[0]))[0])))[uint(sb)])) = unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(plm_audio_read_allocation(unsafe(unsafe(reinterpret<plm_audio_t?>(self_83))), sb, tab3)))))))
        unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.allocation[0]))[1]))[0])))[uint(sb)])) = unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(plm_audio_read_allocation(unsafe(unsafe(reinterpret<plm_audio_t?>(self_83))), sb, tab3)))))))
        sb = int(sb) + 1
        sb
    }
    sb_0 = self_83.bound
    while (true) {
        if (!(int(sb_0) < int(sblimit))) {
            break
        }
        unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.allocation[0]))[1]))[0])))[uint(sb_0)])) = unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(plm_audio_read_allocation(unsafe(unsafe(reinterpret<plm_audio_t?>(self_83))), sb_0, tab3)))))))
        unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.allocation[0]))[0]))[0])))[uint(sb_0)])) = unsafe(unsafe(reinterpret<plm_quantizer_spec_t const?>(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.allocation[0]))[1]))[0])))[uint(sb_0)])))))
        sb_0 = int(sb_0) + 1
        sb_0
    }
    var c2da_fresh21 : int = int(0)
    if (int(self_83.mode) == int(PLM_AUDIO_MODE_MONO)) {
        c2da_fresh21 = 1
    } else {
        c2da_fresh21 = 2
    }
    channels = c2da_fresh21
    sb_1 = 0
    while (true) {
        if (!(int(sb_1) < int(sblimit))) {
            break
        }
        ch = 0
        while (true) {
            if (!(int(ch) < int(channels))) {
                break
            }
            if (unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.allocation[0]))[uint(ch)]))[0])))[uint(sb_1)])) != null) {
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor_info[0]))[uint(ch)]))[0])))[uint(sb_1)])) = uint8(uint8(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 2)))
            }
            ch = int(ch) + 1
            ch
        }
        if (int(self_83.mode) == int(PLM_AUDIO_MODE_MONO)) {
            unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor_info[0]))[1]))[0])))[uint(sb_1)])) = uint8(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor_info[0]))[0]))[0])))[uint(sb_1)])))
        }
        sb_1 = int(sb_1) + 1
        sb_1
    }
    sb_2 = 0
    while (true) {
        if (!(int(sb_2) < int(sblimit))) {
            break
        }
        ch_0 = 0
        while (true) {
            if (!(int(ch_0) < int(channels))) {
                break
            }
            if (unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.allocation[0]))[uint(ch_0)]))[0])))[uint(sb_2)])) != null) {
                sf = unsafe(unsafe(reinterpret<int?>(unsafe(unsafe(reinterpret<int?>(unsafe(unsafe(reinterpret<int?>(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor[0]))[uint(ch_0)]))[0])))[uint(sb_2)]))[0]))))))))))))
                if (uint64(int(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor_info[0]))[uint(ch_0)]))[0])))[uint(sb_2)])))) == uint64(0)) {
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[0])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 6)
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[1])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 6)
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[2])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 6)
                } elif (int(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor_info[0]))[uint(ch_0)]))[0])))[uint(sb_2)]))) == 1) {
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[1])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 6)
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[0])) = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[1]))
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[2])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 6)
                } elif (int(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor_info[0]))[uint(ch_0)]))[0])))[uint(sb_2)]))) == 2) {
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[2])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 6)
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[1])) = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[2]))
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[0])) = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[1]))
                } elif (int(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor_info[0]))[uint(ch_0)]))[0])))[uint(sb_2)]))) == 3) {
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[0])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 6)
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[2])) = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))), 6)
                    unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[1])) = unsafe(unsafe(unsafe(unsafe(reinterpret<int?>(sf)))[2]))
                }
            }
            ch_0 = int(ch_0) + 1
            ch_0
        }
        if (int(self_83.mode) == int(PLM_AUDIO_MODE_MONO)) {
            unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor[0]))[1]))[0])))[uint(sb_2)]))[0])))[0])) = unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor[0]))[0]))[0])))[uint(sb_2)]))[0])))[0]))
            unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor[0]))[1]))[0])))[uint(sb_2)]))[0])))[1])) = unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor[0]))[0]))[0])))[uint(sb_2)]))[0])))[1]))
            unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor[0]))[1]))[0])))[uint(sb_2)]))[0])))[2])) = unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.scale_factor[0]))[0]))[0])))[uint(sb_2)]))[0])))[2]))
        }
        sb_2 = int(sb_2) + 1
        sb_2
    }
    out_pos = 0
    part = 0
    while (true) {
        if (!(int(part) < 3)) {
            break
        }
        granule = 0
        while (true) {
            if (!(int(granule) < 4)) {
                break
            }
            sb_3 = 0
            while (true) {
                if (!(int(sb_3) < int(self_83.bound))) {
                    break
                }
                plm_audio_read_samples(unsafe(unsafe(reinterpret<plm_audio_t?>(self_83))), 0, sb_3, part)
                plm_audio_read_samples(unsafe(unsafe(reinterpret<plm_audio_t?>(self_83))), 1, sb_3, part)
                sb_3 = int(sb_3) + 1
                sb_3
            }
            sb_4 = self_83.bound
            while (true) {
                if (!(int(sb_4) < int(sblimit))) {
                    break
                }
                plm_audio_read_samples(unsafe(unsafe(reinterpret<plm_audio_t?>(self_83))), 0, sb_4, part)
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[1]))[0])))[uint(sb_4)]))[0])))[0])) = unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[0]))[0])))[uint(sb_4)]))[0])))[0]))
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[1]))[0])))[uint(sb_4)]))[0])))[1])) = unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[0]))[0])))[uint(sb_4)]))[0])))[1]))
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[1]))[0])))[uint(sb_4)]))[0])))[2])) = unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[0]))[0])))[uint(sb_4)]))[0])))[2]))
                sb_4 = int(sb_4) + 1
                sb_4
            }
            sb_5 = sblimit
            while (true) {
                if (!(int(sb_5) < 32)) {
                    break
                }
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[0]))[0])))[uint(sb_5)]))[0])))[0])) = 0
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[0]))[0])))[uint(sb_5)]))[0])))[1])) = 0
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[0]))[0])))[uint(sb_5)]))[0])))[2])) = 0
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[1]))[0])))[uint(sb_5)]))[0])))[0])) = 0
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[1]))[0])))[uint(sb_5)]))[0])))[1])) = 0
                unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[1]))[0])))[uint(sb_5)]))[0])))[2])) = 0
                sb_5 = int(sb_5) + 1
                sb_5
            }
            p = 0
            while (true) {
                if (!(int(p) < 3)) {
                    break
                }
                self_83.v_pos = int(int(self_83.v_pos) - 64 & 1023)
                ch_1 = 0
                while (true) {
                    if (!(int(ch_1) < 2)) {
                        break
                    }
                    plm_audio_idct36(unsafe(unsafe(reinterpret<array<int>?>(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.sample[0]))[uint(ch_1)]))[0])))))), p, unsafe(unsafe(reinterpret<float?>(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.V[0]))[uint(ch_1)]))[0])))))), self_83.v_pos)
                    unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_83.U[0])))))))), int(0), int(4)))
                    d_index = int(int(int(512 - (int(self_83.v_pos) >> 1))))
                    v_index = int(int(int(int(self_83.v_pos) % 128 >> 1)))
                    while (true) {
                        if (!(int(v_index) < 1024)) {
                            break
                        }
                        i_3 = 0
                        while (true) {
                            if (!(int(i_3) < 32)) {
                                break
                            }
                            d_index = int(d_index) + 1
                            v_index = int(v_index) + 1
                            unsafe(unsafe(unsafe(addr(self_83.U[0]))[uint(i_3)])) = float(unsafe(unsafe(unsafe(addr(self_83.U[0]))[uint(i_3)]))) + float(unsafe(unsafe(unsafe(addr(self_83.D[0]))[uint(d_index)]))) * float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.V[0]))[uint(ch_1)]))[0])))[uint(v_index)])))
                            i_3 = int(i_3) + 1
                            i_3
                        }
                        v_index = int(v_index) + (128 - 32)
                        d_index = int(d_index) + (64 - 32)
                    }
                    d_index = int(d_index) - (512 - 32)
                    v_index = 128 - 32 + 1024 - int(v_index)
                    while (true) {
                        if (!(int(v_index) < 1024)) {
                            break
                        }
                        i_4 = 0
                        while (true) {
                            if (!(int(i_4) < 32)) {
                                break
                            }
                            d_index = int(d_index) + 1
                            v_index = int(v_index) + 1
                            unsafe(unsafe(unsafe(addr(self_83.U[0]))[uint(i_4)])) = float(unsafe(unsafe(unsafe(addr(self_83.U[0]))[uint(i_4)]))) + float(unsafe(unsafe(unsafe(addr(self_83.D[0]))[uint(d_index)]))) * float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(addr(self_83.V[0]))[uint(ch_1)]))[0])))[uint(v_index)])))
                            i_4 = int(i_4) + 1
                            i_4
                        }
                        v_index = int(v_index) + (128 - 32)
                        d_index = int(d_index) + (64 - 32)
                    }
                    j = 0
                    while (true) {
                        if (!(int(j) < 32)) {
                            break
                        }
                        unsafe(unsafe(unsafe(addr(self_83.samples.interleaved[0]))[(int(out_pos) + int(j) << 1) + int(ch_1)])) = float(unsafe(unsafe(unsafe(addr(self_83.U[0]))[uint(j)]))) / float(-double(1090519040.0))
                        j = int(j) + 1
                        j
                    }
                    ch_1 = int(ch_1) + 1
                    ch_1
                }
                out_pos = int(out_pos) + 32
                p = int(p) + 1
                p
            }
            granule = int(granule) + 1
            granule
        }
        part = int(part) + 1
        part
    }
    plm_buffer_align(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_83.buffer))))
    return
}
[export]
def plm_video_get_height(var self_52 : plm_video_t?) : int {
    var c2da_fresh11 : int = int(0)
    if (uint64(plm_video_has_header(unsafe(unsafe(reinterpret<plm_video_t?>(self_52))))) != uint64(0)) {
        c2da_fresh11 = self_52.height
    } else {
        c2da_fresh11 = 0
    }
    return c2da_fresh11
    return int(0)
}
[export]
def plm_demux_buffer_seek(var self_44 : plm_demux_t?; var pos : uint64) {
    plm_buffer_seek(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_44.buffer))), uint64(pos))
    self_44.current_packet.length = uint64(uint64(0))
    self_44.next_packet.length = uint64(uint64(0))
    self_44.start_code = -1
    return
}
[export]
def plm_get_num_audio_streams(var self_59 : plm_t?) : int {
    return plm_demux_get_num_audio_streams(unsafe(unsafe(reinterpret<plm_demux_t?>(self_59.demux))))
    return int(0)
}
[export]
def plm_demux_destroy(var self_34 : plm_demux_t?) {
    if (uint64(self_34.destroy_buffer_when_done) != uint64(0)) {
        plm_buffer_destroy(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_34.buffer))))
    }
    unsafe(c2da_free(uint64(unsafe(unsafe(reinterpret<uint64>(self_34))))))
    return
}
[export]
def plm_video_decode_slice(var self_89 : plm_video_t?; var slice : int) {
    self_89.slice_begin = 1
    self_89.macroblock_address = (int(slice) - 1) * int(self_89.mb_width) - 1
    self_89.motion_forward.h = 0
    self_89.motion_backward.h = self_89.motion_forward.h
    self_89.motion_forward.v = 0
    self_89.motion_backward.v = self_89.motion_forward.v
    unsafe(unsafe(unsafe(addr(self_89.dc_predictor[0]))[0])) = 128
    unsafe(unsafe(unsafe(addr(self_89.dc_predictor[0]))[1])) = 128
    unsafe(unsafe(unsafe(addr(self_89.dc_predictor[0]))[2])) = 128
    self_89.quantizer_scale = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_89.buffer))), 5)
    while (true) {
        if (!(uint64(plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_89.buffer))), 1)) != uint64(0))) {
            break
        }
        plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_89.buffer))), uint64(uint64(8)))
    }
    while (true) {
        plm_video_decode_macroblock(unsafe(unsafe(reinterpret<plm_video_t?>(self_89))))
        if (!(int(self_89.macroblock_address) < int(self_89.mb_size) - 1 && uint64(plm_buffer_peek_non_zero(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_89.buffer))), 23)) != uint64(0))) {
            break
        }
    }
    return
}
[export]
def plm_buffer_align(var self_9 : plm_buffer_t?) {
    self_9.bit_index = uint64(uint64(self_9.bit_index) + uint64(7) >> uint64(3) << uint64(3))
    return
}
[export]
def plm_demux_has_ended(var self_13 : plm_demux_t?) : int {
    return plm_buffer_has_ended(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_13.buffer))))
    return int(0)
}
[export]
def plm_set_audio_enabled(var self_58 : plm_t?; var enabled_0 : int) {
    self_58.audio_enabled = enabled_0
    if (uint64(enabled_0) == uint64(0)) {
        self_58.audio_packet_type = 0
        return
    } else {
        var c2da_fresh16 : int = int(0)
        if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_58))))) != uint64(0) && self_58.audio_decoder != null) {
            c2da_fresh16 = int(PLM_DEMUX_PACKET_AUDIO_1) + int(self_58.audio_stream_index)
        } else {
            c2da_fresh16 = 0
        }
        self_58.audio_packet_type = c2da_fresh16
        return
    }
}
[export]
def plm_audio_get_time(var self_86 : plm_audio_t?) : double {
    return self_86.time
    return double(0)
}
[export]
def plm_video_decode_picture(var self_88 : plm_video_t?) {
    var f_code : int = int(0)
    var f_code_0 : int = int(0)
    var frame_temp : plm_frame_t = plm_frame_t()
    plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))), uint64(uint64(10)))
    self_88.picture_type = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))), 3)
    plm_buffer_skip(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))), uint64(uint64(16)))
    if (int(self_88.picture_type) <= 0 || int(self_88.picture_type) > int(PLM_VIDEO_PICTURE_TYPE_B)) {
        return
    } else {
        if (int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE) || int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_B)) {
            self_88.motion_forward.full_px = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))), 1)
            f_code = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))), 3)
            if (uint64(int(f_code)) == uint64(0)) {
                return
            } else {
                self_88.motion_forward.r_size = int(f_code) - 1
            }
        }
        if (int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_B)) {
            self_88.motion_backward.full_px = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))), 1)
            f_code_0 = plm_buffer_read(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))), 3)
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
            self_88.start_code = plm_buffer_next_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))))
            if (!(int(self_88.start_code) == int(PLM_START_EXTENSION) || int(self_88.start_code) == int(PLM_START_USER_DATA))) {
                break
            }
        }
        while (true) {
            if (!(int(self_88.start_code) >= int(PLM_START_SLICE_FIRST) && int(self_88.start_code) <= int(PLM_START_SLICE_LAST))) {
                break
            }
            plm_video_decode_slice(unsafe(unsafe(reinterpret<plm_video_t?>(self_88))), int(int(self_88.start_code) & 255))
            if (int(self_88.macroblock_address) >= int(self_88.mb_size) - 1) {
                break
            } else {
                self_88.start_code = plm_buffer_next_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_88.buffer))))
            }
        }
        if (int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_INTRA) || int(self_88.picture_type) == int(PLM_VIDEO_PICTURE_TYPE_PREDICTIVE)) {
            self_88.frame_backward = self_88.frame_current
            self_88.frame_current = frame_temp
        }
        return
    }
}
[export]
def plm_frame_to_argb(var frame_9 : plm_frame_t?; var dest_3 : uint8?; var stride_3 : int) {
    var cols_3 : int = int(0)
    var rows_3 : int = int(0)
    var yw_3 : int = int(0)
    var cw_3 : int = int(0)
    var row_3 : int = int(0)
    var c_index_3 : int = int(0)
    var y_index_3 : int = int(0)
    var d_index_4 : int = int(0)
    var col_3 : int = int(0)
    var y_15 : int = int(0)
    var cr_3 : int = int(0)
    var cb_3 : int = int(0)
    var r_4 : int = int(0)
    var g_3 : int = int(0)
    var b_3 : int = int(0)
    cols_3 = int(int(int(uint(uint(frame_9.width))) >> int(uint(uint(1)))))
    rows_3 = int(int(int(uint(uint(frame_9.height))) >> int(uint(uint(1)))))
    yw_3 = int(frame_9.y.width)
    cw_3 = int(frame_9.cb.width)
    row_3 = 0
    while (true) {
        if (!(int(row_3) < int(rows_3))) {
            break
        }
        c_index_3 = int(row_3) * int(cw_3)
        y_index_3 = int(row_3) * 2 * int(yw_3)
        d_index_4 = int(row_3) * 2 * int(stride_3)
        col_3 = 0
        while (true) {
            if (!(int(col_3) < int(cols_3))) {
                break
            }
            cr_3 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_9.cr.data)))[uint(c_index_3)]))) - 128
            cb_3 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_9.cb.data)))[uint(c_index_3)]))) - 128
            r_4 = int(int(int(int(cr_3) * 104597 >> 16)))
            g_3 = int(int(int(int(cb_3) * 25674 + int(cr_3) * 53278 >> 16)))
            b_3 = int(int(int(int(cb_3) * 132201 >> 16)))
            y_15 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_9.y.data)))[int(y_index_3) + 0]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (0 + 1)])) = uint8(plm_clamp(int(y_15) + int(r_4)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (0 + 2)])) = uint8(plm_clamp(int(y_15) - int(g_3)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (0 + 3)])) = uint8(plm_clamp(int(y_15) + int(b_3)))
            y_15 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_9.y.data)))[int(y_index_3) + 1]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (4 + 1)])) = uint8(plm_clamp(int(y_15) + int(r_4)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (4 + 2)])) = uint8(plm_clamp(int(y_15) - int(g_3)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (4 + 3)])) = uint8(plm_clamp(int(y_15) + int(b_3)))
            y_15 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_9.y.data)))[int(y_index_3) + int(yw_3)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (int(stride_3) + 1)])) = uint8(plm_clamp(int(y_15) + int(r_4)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (int(stride_3) + 2)])) = uint8(plm_clamp(int(y_15) - int(g_3)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (int(stride_3) + 3)])) = uint8(plm_clamp(int(y_15) + int(b_3)))
            y_15 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_9.y.data)))[int(y_index_3) + (int(yw_3) + 1)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (int(stride_3) + 4) + 1])) = uint8(plm_clamp(int(y_15) + int(r_4)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (int(stride_3) + 4) + 2])) = uint8(plm_clamp(int(y_15) - int(g_3)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest_3)))[int(d_index_4) + (int(stride_3) + 4) + 3])) = uint8(plm_clamp(int(y_15) + int(b_3)))
            c_index_3 = int(c_index_3) + 1
            y_index_3 = int(y_index_3) + 2
            d_index_4 = int(d_index_4) + 2 * 4
            col_3 = int(col_3) + 1
            col_3
        }
        row_3 = int(row_3) + 1
        row_3
    }
    return
}
[export]
def plm_demux_get_num_video_streams(var self_31 : plm_demux_t?) : int {
    var c2da_fresh4 : int = int(0)
    if (uint64(plm_demux_has_headers(unsafe(unsafe(reinterpret<plm_demux_t?>(self_31))))) != uint64(0)) {
        c2da_fresh4 = self_31.num_video_streams
    } else {
        c2da_fresh4 = 0
    }
    return c2da_fresh4
    return int(0)
}
[export]
def plm_buffer_set_load_callback(var self_24 : plm_buffer_t?; var fp : plm_buffer_load_callback; var user_0 : uint64) {
    self_24.load_callback = fp
    self_24.load_callback_user_data = user_0
    return
}
[export]
def plm_audio_decode(var self_82 : plm_audio_t?) : plm_samples_t? {
    if (uint64(self_82.next_frame_data_size) == uint64(0)) {
        if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_82.buffer))), uint64(uint64(48)))) == uint64(0)) {
            return null
        } else {
            self_82.next_frame_data_size = plm_audio_decode_header(unsafe(unsafe(reinterpret<plm_audio_t?>(self_82))))
        }
    }
    if (uint64(int(self_82.next_frame_data_size)) == uint64(0) || uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_82.buffer))), uint64(uint64(uint64(int(self_82.next_frame_data_size)) << uint64(3))))) == uint64(0)) {
        return null
    } else {
        plm_audio_decode_frame(unsafe(unsafe(reinterpret<plm_audio_t?>(self_82))))
        self_82.next_frame_data_size = 0
        self_82.samples.time = self_82.time
        self_82.samples_decoded = int(self_82.samples_decoded) + 1152
        self_82.time = double(self_82.samples_decoded) / double(unsafe(unsafe(unsafe(addr(PLM_AUDIO_SAMPLE_RATE[0]))[uint(self_82.samplerate_index)])))
        return unsafe(unsafe(reinterpret<plm_samples_t?>(unsafe(addr(self_82.samples)))))
    }
    return null
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
    var frame_0 : plm_frame_t? = null
    var samples : plm_samples_t? = null
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_80))))) == uint64(0)) {
        return
    } else {
        decode_video = int(c2da_bool_to_int(self_80.video_decode_callback != null && uint64(self_80.video_packet_type) != uint64(0)))
        decode_audio = int(c2da_bool_to_int(self_80.audio_decode_callback != null && uint64(self_80.audio_packet_type) != uint64(0)))
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
                if (uint64(decode_video) != uint64(0) && plm_video_get_time(unsafe(unsafe(reinterpret<plm_video_t?>(self_80.video_decoder)))) < double(video_target_time)) {
                    frame_0 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(plm_video_decode(unsafe(unsafe(reinterpret<plm_video_t?>(self_80.video_decoder))))))))))))))))
                    if (frame_0 != null) {
                        self_80.video_decode_callback(self_80, frame_0, self_80.video_decode_callback_user_data)
                        did_decode = 1
                    } else {
                        decode_video_failed = 1
                    }
                }
                if (uint64(decode_audio) != uint64(0) && plm_audio_get_time(unsafe(unsafe(reinterpret<plm_audio_t?>(self_80.audio_decoder)))) < double(audio_target_time)) {
                    samples = unsafe(unsafe(reinterpret<plm_samples_t?>(unsafe(unsafe(reinterpret<plm_samples_t?>(unsafe(unsafe(reinterpret<plm_samples_t?>(unsafe(unsafe(reinterpret<plm_samples_t?>(plm_audio_decode(unsafe(unsafe(reinterpret<plm_audio_t?>(self_80.audio_decoder))))))))))))))))
                    if (samples != null) {
                        self_80.audio_decode_callback(self_80, samples, self_80.audio_decode_callback_user_data)
                        did_decode = 1
                    } else {
                        decode_audio_failed = 1
                    }
                }
                if (!(uint64(did_decode) != uint64(0))) {
                    break
                }
            }
            if (uint64(decode_video) == uint64(0) || uint64(decode_video_failed) != uint64(0) && uint64(decode_audio) == uint64(0) || uint64(decode_audio_failed) != uint64(0) && uint64(plm_demux_has_ended(unsafe(unsafe(reinterpret<plm_demux_t?>(self_80.demux))))) != uint64(0)) {
                plm_handle_end(unsafe(unsafe(reinterpret<plm_t?>(self_80))))
                return
            } else {
                self_80.time = double(self_80.time) + double(tick)
                return
            }
        }
    }
}
[export]
def plm_read_video_packet(var buffer_4 : plm_buffer_t?; var user_1 : uint64) {
    var self_30 : plm_t? = null
    self_30 = unsafe(unsafe(reinterpret<plm_t?>(unsafe(unsafe(reinterpret<plm_t?>(unsafe(unsafe(reinterpret<plm_t?>(user_1)))))))))
    plm_read_packets(unsafe(unsafe(reinterpret<plm_t?>(self_30))), self_30.video_packet_type)
    return
}
[export]
def plm_audio_destroy(var self_36 : plm_audio_t?) {
    if (uint64(self_36.destroy_buffer_when_done) != uint64(0)) {
        plm_buffer_destroy(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_36.buffer))))
    }
    unsafe(c2da_free(uint64(unsafe(unsafe(reinterpret<uint64>(self_36))))))
    return
}
[export]
def plm_audio_get_samplerate(var self_62 : plm_audio_t?) : int {
    var c2da_fresh18 : int = int(0)
    if (uint64(plm_audio_has_header(unsafe(unsafe(reinterpret<plm_audio_t?>(self_62))))) != uint64(0)) {
        c2da_fresh18 = unsafe(unsafe(unsafe(addr(PLM_AUDIO_SAMPLE_RATE[0]))[uint(self_62.samplerate_index)]))
    } else {
        c2da_fresh18 = 0
    }
    return c2da_fresh18
    return int(0)
}
[export]
def plm_clamp(var n_0 : int) : uint8 {
    if (int(n_0) > 255) {
        n_0 = 255
    } elif (int(n_0) < 0) {
        n_0 = 0
    }
    return uint8(n_0)
    return uint8(0)
}
[export]
def plm_frame_to_rgb(var frame_5 : plm_frame_t?; var dest : uint8?; var stride : int) {
    var cols : int = int(0)
    var rows : int = int(0)
    var yw : int = int(0)
    var cw : int = int(0)
    var row : int = int(0)
    var c_index : int = int(0)
    var y_index : int = int(0)
    var d_index_0 : int = int(0)
    var col : int = int(0)
    var y_11 : int = int(0)
    var cr : int = int(0)
    var cb : int = int(0)
    var r_0 : int = int(0)
    var g : int = int(0)
    var b : int = int(0)
    cols = int(int(int(uint(uint(frame_5.width))) >> int(uint(uint(1)))))
    rows = int(int(int(uint(uint(frame_5.height))) >> int(uint(uint(1)))))
    yw = int(frame_5.y.width)
    cw = int(frame_5.cb.width)
    row = 0
    while (true) {
        if (!(int(row) < int(rows))) {
            break
        }
        c_index = int(row) * int(cw)
        y_index = int(row) * 2 * int(yw)
        d_index_0 = int(row) * 2 * int(stride)
        col = 0
        while (true) {
            if (!(int(col) < int(cols))) {
                break
            }
            cr = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_5.cr.data)))[uint(c_index)]))) - 128
            cb = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_5.cb.data)))[uint(c_index)]))) - 128
            r_0 = int(int(int(int(cr) * 104597 >> 16)))
            g = int(int(int(int(cb) * 25674 + int(cr) * 53278 >> 16)))
            b = int(int(int(int(cb) * 132201 >> 16)))
            y_11 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_5.y.data)))[int(y_index) + 0]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (0 + 0)])) = uint8(plm_clamp(int(y_11) + int(r_0)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (0 + 1)])) = uint8(plm_clamp(int(y_11) - int(g)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (0 + 2)])) = uint8(plm_clamp(int(y_11) + int(b)))
            y_11 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_5.y.data)))[int(y_index) + 1]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (3 + 0)])) = uint8(plm_clamp(int(y_11) + int(r_0)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (3 + 1)])) = uint8(plm_clamp(int(y_11) - int(g)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (3 + 2)])) = uint8(plm_clamp(int(y_11) + int(b)))
            y_11 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_5.y.data)))[int(y_index) + int(yw)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (int(stride) + 0)])) = uint8(plm_clamp(int(y_11) + int(r_0)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (int(stride) + 1)])) = uint8(plm_clamp(int(y_11) - int(g)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (int(stride) + 2)])) = uint8(plm_clamp(int(y_11) + int(b)))
            y_11 = int(int(int((int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(frame_5.y.data)))[int(y_index) + (int(yw) + 1)]))) - 16) * 76309 >> 16)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (int(stride) + 3) + 0])) = uint8(plm_clamp(int(y_11) + int(r_0)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (int(stride) + 3) + 1])) = uint8(plm_clamp(int(y_11) - int(g)))
            unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(dest)))[int(d_index_0) + (int(stride) + 3) + 2])) = uint8(plm_clamp(int(y_11) + int(b)))
            c_index = int(c_index) + 1
            y_index = int(y_index) + 2
            d_index_0 = int(d_index_0) + 2 * 3
            col = int(col) + 1
            col
        }
        row = int(row) + 1
        row
    }
    return
}
[export]
def plm_buffer_find_start_code(var self_23 : plm_buffer_t?; var code : int) : int {
    var current : int = int(0)
    current = 0
    while (true) {
        if (uint64(1) != uint64(0)) {
            current = plm_buffer_next_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_23))))
            if (int(current) == int(code) || int(current) == -1) {
                return current
            }
        } else {
            return -1
        }
    }
    return int(0)
}
[export]
def plm_rewind(var self_72 : plm_t?) {
    if (self_72.video_decoder != null) {
        plm_video_rewind(unsafe(unsafe(reinterpret<plm_video_t?>(self_72.video_decoder))))
    }
    if (self_72.audio_decoder != null) {
        plm_audio_rewind(unsafe(unsafe(reinterpret<plm_audio_t?>(self_72.audio_decoder))))
    }
    plm_demux_rewind(unsafe(unsafe(reinterpret<plm_demux_t?>(self_72.demux))))
    self_72.time = double(0)
    self_72.has_ended = 0
    return
}
[export]
def plm_audio_create_with_buffer(var buffer_1 : plm_buffer_t?; var destroy_when_done_0 : int) : plm_audio_t? {
    var self_2 : plm_audio_t? = null
    self_2 = unsafe(unsafe(reinterpret<plm_audio_t?>(unsafe(unsafe(reinterpret<plm_audio_t?>(unsafe(unsafe(reinterpret<plm_audio_t?>(c2da_malloc(uint64(4)))))))))))
    unsafe(c2da_memset(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint64>(self_2)))))), int(0), int(4)))
    self_2.samples.count = uint(uint(1152))
    self_2.buffer = unsafe(unsafe(reinterpret<plm_buffer_t?>(buffer_1)))
    self_2.destroy_buffer_when_done = destroy_when_done_0
    self_2.samplerate_index = 3
    unsafe(memcpy(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(self_2.D[0])))))), uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(PLM_AUDIO_SYNTHESIS_WINDOW[0])))))), uint64(uint64(512) * uint64(4))))
    unsafe(memcpy(uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<float?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(addr(self_2.D[0]))))), 512, 4))))))))), uint64(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(PLM_AUDIO_SYNTHESIS_WINDOW[0])))))), uint64(uint64(512) * uint64(4))))
    self_2.next_frame_data_size = plm_audio_decode_header(unsafe(unsafe(reinterpret<plm_audio_t?>(self_2))))
    return unsafe(unsafe(reinterpret<plm_audio_t?>(self_2)))
    return null
}
[export]
def plm_video_rewind(var self_74 : plm_video_t?) {
    plm_buffer_rewind(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_74.buffer))))
    self_74.time = double(0)
    self_74.frames_decoded = 0
    self_74.has_reference_frame = 0
    self_74.start_code = -1
    return
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
    t01 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[0]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[31]))[0])))[uint(ss)]))))
    t02 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[0]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[31]))[0])))[uint(ss)]))))) * float(double(0.5006030201911926))
    t03 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[1]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[30]))[0])))[uint(ss)]))))
    t04 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[1]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[30]))[0])))[uint(ss)]))))) * float(double(0.5054709315299988))
    t05 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[2]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[29]))[0])))[uint(ss)]))))
    t06 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[2]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[29]))[0])))[uint(ss)]))))) * float(double(0.5154473185539246))
    t07 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[3]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[28]))[0])))[uint(ss)]))))
    t08 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[3]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[28]))[0])))[uint(ss)]))))) * float(double(0.5310425758361816))
    t09 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[4]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[27]))[0])))[uint(ss)]))))
    t10 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[4]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[27]))[0])))[uint(ss)]))))) * float(double(0.5531039237976074))
    t11 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[5]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[26]))[0])))[uint(ss)]))))
    t12 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[5]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[26]))[0])))[uint(ss)]))))) * float(double(0.5829349756240845))
    t13 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[6]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[25]))[0])))[uint(ss)]))))
    t14 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[6]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[25]))[0])))[uint(ss)]))))) * float(double(0.6225041151046753))
    t15 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[7]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[24]))[0])))[uint(ss)]))))
    t16 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[7]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[24]))[0])))[uint(ss)]))))) * float(double(0.6748083233833313))
    t17 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[8]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[23]))[0])))[uint(ss)]))))
    t18 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[8]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[23]))[0])))[uint(ss)]))))) * float(double(0.744536280632019))
    t19 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[9]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[22]))[0])))[uint(ss)]))))
    t20 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[9]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[22]))[0])))[uint(ss)]))))) * float(double(0.839349627494812))
    t21 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[10]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[21]))[0])))[uint(ss)]))))
    t22 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[10]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[21]))[0])))[uint(ss)]))))) * float(double(0.9725682139396667))
    t23 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[11]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[20]))[0])))[uint(ss)]))))
    t24 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[11]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[20]))[0])))[uint(ss)]))))) * float(double(1.1694399118423462))
    t25 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[12]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[19]))[0])))[uint(ss)]))))
    t26 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[12]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[19]))[0])))[uint(ss)]))))) * float(double(1.4841645956039429))
    t27 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[13]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[18]))[0])))[uint(ss)]))))
    t28 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[13]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[18]))[0])))[uint(ss)]))))) * float(double(2.0577809810638428))
    t29 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[14]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[17]))[0])))[uint(ss)]))))
    t30 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[14]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[17]))[0])))[uint(ss)]))))) * float(double(3.4076085090637207))
    t31 = float(float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[15]))[0])))[uint(ss)]))) + float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[16]))[0])))[uint(ss)]))))
    t32 = float(unsafe(float(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[15]))[0])))[uint(ss)])) - float(unsafe(unsafe(unsafe(addr(unsafe(unsafe(unsafe(unsafe(unsafe(reinterpret<array<int>?>(s)))[16]))[0])))[uint(ss)]))))) * float(double(10.190008163452148))
    t33 = float(t01) + float(t31)
    t31 = (float(t01) - float(t31)) * float(double(0.5024192929267883))
    t01 = float(t03) + float(t29)
    t29 = (float(t03) - float(t29)) * float(double(0.522498607635498))
    t03 = float(t05) + float(t27)
    t27 = (float(t05) - float(t27)) * float(double(0.5669440627098083))
    t05 = float(t07) + float(t25)
    t25 = (float(t07) - float(t25)) * float(double(0.6468217968940735))
    t07 = float(t09) + float(t23)
    t23 = (float(t09) - float(t23)) * float(double(0.7881546020507813))
    t09 = float(t11) + float(t21)
    t21 = (float(t11) - float(t21)) * float(double(1.0606776475906372))
    t11 = float(t13) + float(t19)
    t19 = (float(t13) - float(t19)) * float(double(1.722447156906128))
    t13 = float(t15) + float(t17)
    t17 = (float(t15) - float(t17)) * float(double(5.10114860534668))
    t15 = float(t33) + float(t13)
    t13 = (float(t33) - float(t13)) * float(double(0.509795606136322))
    t33 = float(t01) + float(t11)
    t01 = (float(t01) - float(t11)) * float(double(0.601344883441925))
    t11 = float(t03) + float(t09)
    t09 = (float(t03) - float(t09)) * float(double(0.8999761939048767))
    t03 = float(t05) + float(t07)
    t07 = (float(t05) - float(t07)) * float(double(2.562915563583374))
    t05 = float(t15) + float(t03)
    t15 = (float(t15) - float(t03)) * float(double(0.5411961078643799))
    t03 = float(t33) + float(t11)
    t11 = (float(t33) - float(t11)) * float(double(1.3065630197525024))
    t33 = float(t05) + float(t03)
    t05 = (float(t05) - float(t03)) * float(double(0.7071067690849304))
    t03 = float(t15) + float(t11)
    t15 = (float(t15) - float(t11)) * float(double(0.7071067690849304))
    t03 = float(t03) + float(t15)
    t11 = float(t13) + float(t07)
    t13 = (float(t13) - float(t07)) * float(double(0.5411961078643799))
    t07 = float(t01) + float(t09)
    t09 = (float(t01) - float(t09)) * float(double(1.3065630197525024))
    t01 = float(t11) + float(t07)
    t07 = (float(t11) - float(t07)) * float(double(0.7071067690849304))
    t11 = float(t13) + float(t09)
    t13 = (float(t13) - float(t09)) * float(double(0.7071067690849304))
    t11 = float(t11) + float(t13)
    t01 = float(t01) + float(t11)
    t11 = float(t11) + float(t07)
    t07 = float(t07) + float(t13)
    t09 = float(t31) + float(t17)
    t31 = (float(t31) - float(t17)) * float(double(0.509795606136322))
    t17 = float(t29) + float(t19)
    t29 = (float(t29) - float(t19)) * float(double(0.601344883441925))
    t19 = float(t27) + float(t21)
    t21 = (float(t27) - float(t21)) * float(double(0.8999761939048767))
    t27 = float(t25) + float(t23)
    t23 = (float(t25) - float(t23)) * float(double(2.562915563583374))
    t25 = float(t09) + float(t27)
    t09 = (float(t09) - float(t27)) * float(double(0.5411961078643799))
    t27 = float(t17) + float(t19)
    t19 = (float(t17) - float(t19)) * float(double(1.3065630197525024))
    t17 = float(t25) + float(t27)
    t27 = (float(t25) - float(t27)) * float(double(0.7071067690849304))
    t25 = float(t09) + float(t19)
    t19 = (float(t09) - float(t19)) * float(double(0.7071067690849304))
    t25 = float(t25) + float(t19)
    t09 = float(t31) + float(t23)
    t31 = (float(t31) - float(t23)) * float(double(0.5411961078643799))
    t23 = float(t29) + float(t21)
    t21 = (float(t29) - float(t21)) * float(double(1.3065630197525024))
    t29 = float(t09) + float(t23)
    t23 = (float(t09) - float(t23)) * float(double(0.7071067690849304))
    t09 = float(t31) + float(t21)
    t31 = (float(t31) - float(t21)) * float(double(0.7071067690849304))
    t09 = float(t09) + float(t31)
    t29 = float(t29) + float(t09)
    t09 = float(t09) + float(t23)
    t23 = float(t23) + float(t31)
    t17 = float(t17) + float(t29)
    t29 = float(t29) + float(t25)
    t25 = float(t25) + float(t09)
    t09 = float(t09) + float(t27)
    t27 = float(t27) + float(t23)
    t23 = float(t23) + float(t19)
    t19 = float(t19) + float(t31)
    t21 = float(t02) + float(t32)
    t02 = (float(t02) - float(t32)) * float(double(0.5024192929267883))
    t32 = float(t04) + float(t30)
    t04 = (float(t04) - float(t30)) * float(double(0.522498607635498))
    t30 = float(t06) + float(t28)
    t28 = (float(t06) - float(t28)) * float(double(0.5669440627098083))
    t06 = float(t08) + float(t26)
    t08 = (float(t08) - float(t26)) * float(double(0.6468217968940735))
    t26 = float(t10) + float(t24)
    t10 = (float(t10) - float(t24)) * float(double(0.7881546020507813))
    t24 = float(t12) + float(t22)
    t22 = (float(t12) - float(t22)) * float(double(1.0606776475906372))
    t12 = float(t14) + float(t20)
    t20 = (float(t14) - float(t20)) * float(double(1.722447156906128))
    t14 = float(t16) + float(t18)
    t16 = (float(t16) - float(t18)) * float(double(5.10114860534668))
    t18 = float(t21) + float(t14)
    t14 = (float(t21) - float(t14)) * float(double(0.509795606136322))
    t21 = float(t32) + float(t12)
    t32 = (float(t32) - float(t12)) * float(double(0.601344883441925))
    t12 = float(t30) + float(t24)
    t24 = (float(t30) - float(t24)) * float(double(0.8999761939048767))
    t30 = float(t06) + float(t26)
    t26 = (float(t06) - float(t26)) * float(double(2.562915563583374))
    t06 = float(t18) + float(t30)
    t18 = (float(t18) - float(t30)) * float(double(0.5411961078643799))
    t30 = float(t21) + float(t12)
    t12 = (float(t21) - float(t12)) * float(double(1.3065630197525024))
    t21 = float(t06) + float(t30)
    t30 = (float(t06) - float(t30)) * float(double(0.7071067690849304))
    t06 = float(t18) + float(t12)
    t12 = (float(t18) - float(t12)) * float(double(0.7071067690849304))
    t06 = float(t06) + float(t12)
    t18 = float(t14) + float(t26)
    t26 = (float(t14) - float(t26)) * float(double(0.5411961078643799))
    t14 = float(t32) + float(t24)
    t24 = (float(t32) - float(t24)) * float(double(1.3065630197525024))
    t32 = float(t18) + float(t14)
    t14 = (float(t18) - float(t14)) * float(double(0.7071067690849304))
    t18 = float(t26) + float(t24)
    t24 = (float(t26) - float(t24)) * float(double(0.7071067690849304))
    t18 = float(t18) + float(t24)
    t32 = float(t32) + float(t18)
    t18 = float(t18) + float(t14)
    t26 = float(t14) + float(t24)
    t14 = float(t02) + float(t16)
    t02 = (float(t02) - float(t16)) * float(double(0.509795606136322))
    t16 = float(t04) + float(t20)
    t04 = (float(t04) - float(t20)) * float(double(0.601344883441925))
    t20 = float(t28) + float(t22)
    t22 = (float(t28) - float(t22)) * float(double(0.8999761939048767))
    t28 = float(t08) + float(t10)
    t10 = (float(t08) - float(t10)) * float(double(2.562915563583374))
    t08 = float(t14) + float(t28)
    t14 = (float(t14) - float(t28)) * float(double(0.5411961078643799))
    t28 = float(t16) + float(t20)
    t20 = (float(t16) - float(t20)) * float(double(1.3065630197525024))
    t16 = float(t08) + float(t28)
    t28 = (float(t08) - float(t28)) * float(double(0.7071067690849304))
    t08 = float(t14) + float(t20)
    t20 = (float(t14) - float(t20)) * float(double(0.7071067690849304))
    t08 = float(t08) + float(t20)
    t14 = float(t02) + float(t10)
    t02 = (float(t02) - float(t10)) * float(double(0.5411961078643799))
    t10 = float(t04) + float(t22)
    t22 = (float(t04) - float(t22)) * float(double(1.3065630197525024))
    t04 = float(t14) + float(t10)
    t10 = (float(t14) - float(t10)) * float(double(0.7071067690849304))
    t14 = float(t02) + float(t22)
    t02 = (float(t02) - float(t22)) * float(double(0.7071067690849304))
    t14 = float(t14) + float(t02)
    t04 = float(t04) + float(t14)
    t14 = float(t14) + float(t10)
    t10 = float(t10) + float(t02)
    t16 = float(t16) + float(t04)
    t04 = float(t04) + float(t08)
    t08 = float(t08) + float(t14)
    t14 = float(t14) + float(t28)
    t28 = float(t28) + float(t10)
    t10 = float(t10) + float(t20)
    t20 = float(t20) + float(t02)
    t21 = float(t21) + float(t16)
    t16 = float(t16) + float(t32)
    t32 = float(t32) + float(t04)
    t04 = float(t04) + float(t06)
    t06 = float(t06) + float(t08)
    t08 = float(t08) + float(t18)
    t18 = float(t18) + float(t14)
    t14 = float(t14) + float(t30)
    t30 = float(t30) + float(t28)
    t28 = float(t28) + float(t26)
    t26 = float(t26) + float(t10)
    t10 = float(t10) + float(t12)
    t12 = float(t12) + float(t20)
    t20 = float(t20) + float(t24)
    t24 = float(t24) + float(t02)
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 48])) = -t33
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 47])) = -t21
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 49])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 47]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 46])) = -t17
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 50])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 46]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 45])) = -t16
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 51])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 45]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 44])) = -t01
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 52])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 44]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 43])) = -t32
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 53])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 43]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 42])) = -t29
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 54])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 42]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 41])) = -t04
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 55])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 41]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 40])) = -t03
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 56])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 40]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 39])) = -t06
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 57])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 39]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 38])) = -t25
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 58])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 38]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 37])) = -t08
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 59])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 37]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 36])) = -t11
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 60])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 36]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 35])) = -t18
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 61])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 35]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 34])) = -t09
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 62])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 34]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 33])) = -t14
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 63])) = unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 33]))
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 32])) = -t05
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 0])) = t05
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 31])) = -t30
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 1])) = t30
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 30])) = -t27
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 2])) = t27
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 29])) = -t28
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 3])) = t28
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 28])) = -t07
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 4])) = t07
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 27])) = -t26
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 5])) = t26
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 26])) = -t23
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 6])) = t23
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 25])) = -t10
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 7])) = t10
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 24])) = -t15
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 8])) = t15
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 23])) = -t12
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 9])) = t12
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 22])) = -t19
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 10])) = t19
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 21])) = -t20
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 11])) = t20
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 20])) = -t13
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 12])) = t13
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 19])) = -t24
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 13])) = t24
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 18])) = -t31
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 14])) = t31
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 17])) = -t02
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 15])) = t02
    unsafe(unsafe(unsafe(unsafe(reinterpret<float?>(d)))[int(dp) + 16])) = float(double(0.0))
    return
}
[export]
def plm_buffer_skip_bytes(var self_8 : plm_buffer_t?; var v : uint8) : int {
    var skipped : int = int(0)
    plm_buffer_align(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_8))))
    skipped = 0
    while (true) {
        if (!(uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_8))), uint64(uint64(8)))) != uint64(0) && int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_8.bytes)))[uint(uint(uint64(self_8.bit_index)) >> uint(uint64(3)))]))) == int(v))) {
            break
        }
        self_8.bit_index = uint64(uint64(self_8.bit_index) + uint64(8))
        skipped = int(skipped) + 1
    }
    return skipped
    return int(0)
}
[export]
def plm_read_packets(var self_11 : plm_t?; var requested_type : int) {
    var packet : plm_packet_t? = null
    while (true) {
        packet = unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_decode(unsafe(unsafe(reinterpret<plm_demux_t?>(self_11.demux))))))))))))))))
        if (packet != null) {
            if (int(packet.type_0) == int(self_11.video_packet_type)) {
                plm_buffer_write(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_11.video_buffer))), unsafe(unsafe(reinterpret<uint8?>(packet.data))), uint64(packet.length))
            } elif (int(packet.type_0) == int(self_11.audio_packet_type)) {
                plm_buffer_write(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_11.audio_buffer))), unsafe(unsafe(reinterpret<uint8?>(packet.data))), uint64(packet.length))
            }
            if (int(packet.type_0) == int(requested_type)) {
                return
            }
        } else {
            if (uint64(plm_demux_has_ended(unsafe(unsafe(reinterpret<plm_demux_t?>(self_11.demux))))) != uint64(0)) {
                if (self_11.video_buffer != null) {
                    plm_buffer_signal_end(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_11.video_buffer))))
                }
                if (self_11.audio_buffer != null) {
                    plm_buffer_signal_end(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_11.audio_buffer))))
                }
            }
            return
        }
    }
}
[export]
def plm_seek_frame(var self_107 : plm_t?; var time_1 : double; var seek_exact_0 : int) : plm_frame_t? {
    var type_3 : int = int(0)
    var start_time_0 : double = double(0)
    var duration : double = double(0)
    var packet_3 : plm_packet_t? = null
    var previous_audio_packet_type : int = int(0)
    var frame_4 : plm_frame_t? = null
    if (uint64(plm_init_decoders(unsafe(unsafe(reinterpret<plm_t?>(self_107))))) == uint64(0)) {
        return null
    } elif (uint64(self_107.video_packet_type) == uint64(0)) {
        return null
    } else {
        type_3 = self_107.video_packet_type
        start_time_0 = plm_demux_get_start_time(unsafe(unsafe(reinterpret<plm_demux_t?>(self_107.demux))), type_3)
        duration = plm_demux_get_duration(unsafe(unsafe(reinterpret<plm_demux_t?>(self_107.demux))), type_3)
        if (double(time_1) < double(0)) {
            time_1 = double(0)
        } elif (double(time_1) > double(duration)) {
            time_1 = duration
        }
        packet_3 = unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(unsafe(reinterpret<plm_packet_t?>(plm_demux_seek(unsafe(unsafe(reinterpret<plm_demux_t?>(self_107.demux))), time_1, type_3, 1)))))))))))))
        if (packet_3 == null) {
            return null
        } else {
            previous_audio_packet_type = self_107.audio_packet_type
            self_107.audio_packet_type = 0
            plm_video_rewind(unsafe(unsafe(reinterpret<plm_video_t?>(self_107.video_decoder))))
            plm_video_set_time(unsafe(unsafe(reinterpret<plm_video_t?>(self_107.video_decoder))), double(packet_3.pts) - double(start_time_0))
            plm_buffer_write(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_107.video_buffer))), unsafe(unsafe(reinterpret<uint8?>(packet_3.data))), uint64(packet_3.length))
            frame_4 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(plm_video_decode(unsafe(unsafe(reinterpret<plm_video_t?>(self_107.video_decoder))))))))))))))))
            if (uint64(seek_exact_0) != uint64(0)) {
                while (true) {
                    if (!(frame_4 != null && double(frame_4.time) < double(time_1))) {
                        break
                    }
                    frame_4 = unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(unsafe(unsafe(reinterpret<plm_frame_t?>(plm_video_decode(unsafe(unsafe(reinterpret<plm_video_t?>(self_107.video_decoder))))))))))))))))
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
    return null
}
[export]
def plm_demux_rewind(var self_70 : plm_demux_t?) {
    plm_buffer_rewind(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_70.buffer))))
    self_70.current_packet.length = uint64(uint64(0))
    self_70.next_packet.length = uint64(uint64(0))
    self_70.start_code = -1
    return
}
[export]
def plm_has_ended(var self_77 : plm_t?) : int {
    return self_77.has_ended
    return int(0)
}
[export]
def plm_demux_get_packet(var self_19 : plm_demux_t?) : plm_packet_t? {
    if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_19.buffer))), uint64(uint64(self_19.next_packet.length) << uint64(3)))) == uint64(0)) {
        return null
    } else {
        self_19.current_packet.data = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(self_19.buffer.bytes))), uint64(self_19.buffer.bit_index) >> uint64(3), 1))))))))
        self_19.current_packet.length = uint64(self_19.next_packet.length)
        self_19.current_packet.type_0 = self_19.next_packet.type_0
        self_19.current_packet.pts = self_19.next_packet.pts
        self_19.next_packet.length = uint64(uint64(0))
        return unsafe(unsafe(reinterpret<plm_packet_t?>(unsafe(addr(self_19.current_packet)))))
    }
    return null
}
[export]
def plm_buffer_rewind(var self_71 : plm_buffer_t?) {
    plm_buffer_seek(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_71))), uint64(uint64(0)))
    return
}
[export]
def plm_audio_has_header(var self_39 : plm_audio_t?) : int {
    if (uint64(self_39.has_header) != uint64(0)) {
        return 1
    } else {
        self_39.next_frame_data_size = plm_audio_decode_header(unsafe(unsafe(reinterpret<plm_audio_t?>(self_39))))
        return self_39.has_header
    }
    return int(0)
}
[export]
def plm_buffer_read(var self_4 : plm_buffer_t?; var count : int) : int {
    var value : int = int(0)
    var current_byte : int = int(0)
    var remaining : int = int(0)
    var read : int = int(0)
    var shift : int = int(0)
    var mask : int = int(0)
    if (uint64(plm_buffer_has(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_4))), uint64(uint64(count)))) == uint64(0)) {
        return 0
    } else {
        value = 0
        while (true) {
            if (!(uint64(count) != uint64(0))) {
                break
            }
            current_byte = int(int(int(int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(self_4.bytes)))[uint(uint(uint64(self_4.bit_index)) >> uint(uint64(3)))]))))))
            remaining = int(int(int(uint64(8)) - int(uint64(int(uint64(int(uint64(int(uint64(int(uint64(self_4.bit_index)))))))) & int(uint64(int(uint64(int(uint64(int(uint64(7))))))))))))
            var c2da_fresh2 : int = int(0)
            if (int(remaining) < int(count)) {
                c2da_fresh2 = remaining
            } else {
                c2da_fresh2 = count
            }
            read = c2da_fresh2
            shift = int(remaining) - int(read)
            mask = 255 >> 8 - int(read)
            value = int(value) << int(read) | (int(current_byte) & int(mask) << int(shift)) >> int(shift)
            self_4.bit_index = uint64(uint64(self_4.bit_index) + uint64(read))
            count = int(count) - int(read)
        }
        return value
    }
    return int(0)
}
[export]
def plm_buffer_has(var self_5 : plm_buffer_t?; var count_0 : uint64) : int {
    if ((uint64(self_5.length) << uint64(3)) - uint64(self_5.bit_index) >= uint64(count_0)) {
        return 1
    } else {
        if (self_5.load_callback != null) {
            self_5.load_callback(self_5, self_5.load_callback_user_data)
            if ((uint64(self_5.length) << uint64(3)) - uint64(self_5.bit_index) >= uint64(count_0)) {
                return 1
            }
        }
        if (uint64(uint64(self_5.total_size)) != uint64(0) && uint64(self_5.length) == uint64(self_5.total_size)) {
            self_5.has_ended = 1
        }
        return 0
    }
    return int(0)
}
[export]
def plm_demux_probe(var self_42 : plm_demux_t?; var probesize_0 : uint64) : int {
    var previous_pos : int = int(0)
    var video_stream : int = int(0)
    var audio_streams : array<int> = []
    var i_2 : int = int(0)
    previous_pos = int(plm_buffer_tell(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_42.buffer)))))
    video_stream = 0
    audio_streams = [int(0), int(0), int(0), int(0)]
    while (true) {
        self_42.start_code = plm_buffer_next_start_code(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_42.buffer))))
        if (int(self_42.start_code) == int(PLM_DEMUX_PACKET_VIDEO_1)) {
            video_stream = 1
        } elif (int(self_42.start_code) >= int(PLM_DEMUX_PACKET_AUDIO_1) && int(self_42.start_code) <= int(PLM_DEMUX_PACKET_AUDIO_4)) {
            unsafe(unsafe(unsafe(addr(audio_streams[0]))[int(self_42.start_code) - int(PLM_DEMUX_PACKET_AUDIO_1)])) = 1
        }
        if (!(int(self_42.start_code) != -1 && plm_buffer_tell(unsafe(unsafe(reinterpret<plm_buffer_t?>(self_42.buffer)))) - uint64(previous_pos) < uint64(probesize_0))) {
            break
        }
    }
    var c2da_fresh5 : int = int(0)
    if (uint64(video_stream) != uint64(0)) {
        c2da_fresh5 = 1
    } else {
        c2da_fresh5 = 0
    }
    self_42.num_video_streams = c2da_fresh5
    self_42.num_audio_streams = 0
    i_2 = 0
    while (true) {
        if (!(int(i_2) < 4)) {
            break
        }
        if (uint64(unsafe(unsafe(unsafe(addr(audio_streams[0]))[uint(i_2)]))) != uint64(0)) {
            self_42.num_audio_streams = self_42.num_audio_streams + 1
        }
        i_2 = int(i_2) + 1
        i_2
    }
    plm_demux_buffer_seek(unsafe(unsafe(reinterpret<plm_demux_t?>(self_42))), uint64(uint64(previous_pos)))
    if (uint64(self_42.num_video_streams) != uint64(0) || uint64(self_42.num_audio_streams) != uint64(0)) {
        return 1
    } else {
        return 0
    }
    return int(0)
}
[export] def main() : int {
    return 0
}
