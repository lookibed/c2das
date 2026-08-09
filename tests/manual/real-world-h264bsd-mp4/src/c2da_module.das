options gen2

module c2da_module
require h264bsd
require shim
require minimp4
struct DecodeSummary {
    combined_hash : uint
    first_hash : uint
    last_hash : uint
    frame_count : int
    width : int
    height : int
}
struct DecoderState {
    storage : h264bsd::storage?
    width : int
    height : int
    picture : uint8?
}
struct MemoryInput {
    bytes : uint8 const?
    length : int
}
var host_u_size : int = 0

var host_bytes : uint8? = null

var host_v_size : int = 0

var sample_mp4_bytes : uint8 [8044] const = fixed_array<uint8>(uint8(0), uint8(0), uint8(0), uint8(uint8(32)), uint8(uint8(102)), uint8(uint8(116)), uint8(uint8(121)), uint8(uint8(112)), uint8(uint8(105)), uint8(uint8(115)), uint8(uint8(111)), uint8(uint8(109)), uint8(0), uint8(0), uint8(uint8(2)), uint8(0), uint8(uint8(105)), uint8(uint8(115)), uint8(uint8(111)), uint8(uint8(109)), uint8(uint8(105)), uint8(uint8(115)), uint8(uint8(111)), uint8(uint8(50)), uint8(uint8(97)), uint8(uint8(118)), uint8(uint8(99)), uint8(uint8(49)), uint8(uint8(109)), uint8(uint8(112)), uint8(uint8(52)), uint8(uint8(49)), uint8(0), uint8(0), uint8(0), uint8(uint8(8)), uint8(uint8(102)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(101)), uint8(0), uint8(0), uint8(uint8(27)), uint8(uint8(241)), uint8(uint8(109)), uint8(uint8(100)), uint8(uint8(97)), uint8(uint8(116)), uint8(0), uint8(0), uint8(uint8(2)), uint8(uint8(113)), uint8(uint8(6)), uint8(uint8(5)), uint8(uint8(255)), uint8(uint8(255)), uint8(uint8(109)), uint8(uint8(220)), uint8(uint8(69)), uint8(uint8(233)), uint8(uint8(189)), uint8(uint8(230)), uint8(uint8(217)), uint8(uint8(72)), uint8(uint8(183)), uint8(uint8(150)), uint8(uint8(44)), uint8(uint8(216)), uint8(uint8(32)), uint8(uint8(217)), uint8(uint8(35)), uint8(uint8(238)), uint8(uint8(239)), uint8(uint8(120)), uint8(uint8(50)), uint8(uint8(54)), uint8(uint8(52)), uint8(uint8(32)), uint8(uint8(45)), uint8(uint8(32)), uint8(uint8(99)), uint8(uint8(111)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(32)), uint8(uint8(49)), uint8(uint8(54)), uint8(uint8(53)), uint8(uint8(32)), uint8(uint8(114)), uint8(uint8(51)), uint8(uint8(50)), uint8(uint8(50)), uint8(uint8(50)), uint8(uint8(32)), uint8(uint8(98)), uint8(uint8(51)), uint8(uint8(53)), uint8(uint8(54)), uint8(uint8(48)), uint8(uint8(53)), uint8(uint8(97)), uint8(uint8(32)), uint8(uint8(45)), uint8(uint8(32)), uint8(uint8(72)), uint8(uint8(46)), uint8(uint8(50)), uint8(uint8(54)), uint8(uint8(52)), uint8(uint8(47)), uint8(uint8(77)), uint8(uint8(80)), uint8(uint8(69)), uint8(uint8(71)), uint8(uint8(45)), uint8(uint8(52)), uint8(uint8(32)), uint8(uint8(65)), uint8(uint8(86)), uint8(uint8(67)), uint8(uint8(32)), uint8(uint8(99)), uint8(uint8(111)), uint8(uint8(100)), uint8(uint8(101)), uint8(uint8(99)), uint8(uint8(32)), uint8(uint8(45)), uint8(uint8(32)), uint8(uint8(67)), uint8(uint8(111)), uint8(uint8(112)), uint8(uint8(121)), uint8(uint8(108)), uint8(uint8(101)), uint8(uint8(102)), uint8(uint8(116)), uint8(uint8(32)), uint8(uint8(50)), uint8(uint8(48)), uint8(uint8(48)), uint8(uint8(51)), uint8(uint8(45)), uint8(uint8(50)), uint8(uint8(48)), uint8(uint8(50)), uint8(uint8(53)), uint8(uint8(32)), uint8(uint8(45)), uint8(uint8(32)), uint8(uint8(104)), uint8(uint8(116)), uint8(uint8(116)), uint8(uint8(112)), uint8(uint8(58)), uint8(uint8(47)), uint8(uint8(47)), uint8(uint8(119)), uint8(uint8(119)), uint8(uint8(119)), uint8(uint8(46)), uint8(uint8(118)), uint8(uint8(105)), uint8(uint8(100)), uint8(uint8(101)), uint8(uint8(111)), uint8(uint8(108)), uint8(uint8(97)), uint8(uint8(110)), uint8(uint8(46)), uint8(uint8(111)), uint8(uint8(114)), uint8(uint8(103)), uint8(uint8(47)), uint8(uint8(120)), uint8(uint8(50)), uint8(uint8(54)), uint8(uint8(52)), uint8(uint8(46)), uint8(uint8(104)), uint8(uint8(116)), uint8(uint8(109)), uint8(uint8(108)), uint8(uint8(32)), uint8(uint8(45)), uint8(uint8(32)), uint8(uint8(111)), uint8(uint8(112)), uint8(uint8(116)), uint8(uint8(105)), uint8(uint8(111)), uint8(uint8(110)), uint8(uint8(115)), uint8(uint8(58)), uint8(uint8(32)), uint8(uint8(99)), uint8(uint8(97)), uint8(uint8(98)), uint8(uint8(97)), uint8(uint8(99)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(102)), uint8(uint8(61)), uint8(uint8(51)), uint8(uint8(32)), uint8(uint8(100)), uint8(uint8(101)), uint8(uint8(98)), uint8(uint8(108)), uint8(uint8(111)), uint8(uint8(99)), uint8(uint8(107)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(58)), uint8(uint8(48)), uint8(uint8(58)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(97)), uint8(uint8(110)), uint8(uint8(97)), uint8(uint8(108)), uint8(uint8(121)), uint8(uint8(115)), uint8(uint8(101)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(120)), uint8(uint8(49)), uint8(uint8(58)), uint8(uint8(48)), uint8(uint8(120)), uint8(uint8(49)), uint8(uint8(49)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(109)), uint8(uint8(101)), uint8(uint8(61)), uint8(uint8(104)), uint8(uint8(101)), uint8(uint8(120)), uint8(uint8(32)), uint8(uint8(115)), uint8(uint8(117)), uint8(uint8(98)), uint8(uint8(109)), uint8(uint8(101)), uint8(uint8(61)), uint8(uint8(55)), uint8(uint8(32)), uint8(uint8(112)), uint8(uint8(115)), uint8(uint8(121)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(112)), uint8(uint8(115)), uint8(uint8(121)), uint8(uint8(95)), uint8(uint8(114)), uint8(uint8(100)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(46)), uint8(uint8(48)), uint8(uint8(48)), uint8(uint8(58)), uint8(uint8(48)), uint8(uint8(46)), uint8(uint8(48)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(109)), uint8(uint8(105)), uint8(uint8(120)), uint8(uint8(101)), uint8(uint8(100)), uint8(uint8(95)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(102)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(109)), uint8(uint8(101)), uint8(uint8(95)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(110)), uint8(uint8(103)), uint8(uint8(101)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(54)), uint8(uint8(32)), uint8(uint8(99)), uint8(uint8(104)), uint8(uint8(114)), uint8(uint8(111)), uint8(uint8(109)), uint8(uint8(97)), uint8(uint8(95)), uint8(uint8(109)), uint8(uint8(101)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(116)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(108)), uint8(uint8(108)), uint8(uint8(105)), uint8(uint8(115)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(56)), uint8(uint8(120)), uint8(uint8(56)), uint8(uint8(100)), uint8(uint8(99)), uint8(uint8(116)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(99)), uint8(uint8(113)), uint8(uint8(109)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(100)), uint8(uint8(101)), uint8(uint8(97)), uint8(uint8(100)), uint8(uint8(122)), uint8(uint8(111)), uint8(uint8(110)), uint8(uint8(101)), uint8(uint8(61)), uint8(uint8(50)), uint8(uint8(49)), uint8(uint8(44)), uint8(uint8(49)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(102)), uint8(uint8(97)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(95)), uint8(uint8(112)), uint8(uint8(115)), uint8(uint8(107)), uint8(uint8(105)), uint8(uint8(112)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(99)), uint8(uint8(104)), uint8(uint8(114)), uint8(uint8(111)), uint8(uint8(109)), uint8(uint8(97)), uint8(uint8(95)), uint8(uint8(113)), uint8(uint8(112)), uint8(uint8(95)), uint8(uint8(111)), uint8(uint8(102)), uint8(uint8(102)), uint8(uint8(115)), uint8(uint8(101)), uint8(uint8(116)), uint8(uint8(61)), uint8(uint8(45)), uint8(uint8(50)), uint8(uint8(32)), uint8(uint8(116)), uint8(uint8(104)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(97)), uint8(uint8(100)), uint8(uint8(115)), uint8(uint8(61)), uint8(uint8(50)), uint8(uint8(32)), uint8(uint8(108)), uint8(uint8(111)), uint8(uint8(111)), uint8(uint8(107)), uint8(uint8(97)), uint8(uint8(104)), uint8(uint8(101)), uint8(uint8(97)), uint8(uint8(100)), uint8(uint8(95)), uint8(uint8(116)), uint8(uint8(104)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(97)), uint8(uint8(100)), uint8(uint8(115)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(115)), uint8(uint8(108)), uint8(uint8(105)), uint8(uint8(99)), uint8(uint8(101)), uint8(uint8(100)), uint8(uint8(95)), uint8(uint8(116)), uint8(uint8(104)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(97)), uint8(uint8(100)), uint8(uint8(115)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(110)), uint8(uint8(114)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(100)), uint8(uint8(101)), uint8(uint8(99)), uint8(uint8(105)), uint8(uint8(109)), uint8(uint8(97)), uint8(uint8(116)), uint8(uint8(101)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(116)), uint8(uint8(101)), uint8(uint8(114)), uint8(uint8(108)), uint8(uint8(97)), uint8(uint8(99)), uint8(uint8(101)), uint8(uint8(100)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(98)), uint8(uint8(108)), uint8(uint8(117)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(121)), uint8(uint8(95)), uint8(uint8(99)), uint8(uint8(111)), uint8(uint8(109)), uint8(uint8(112)), uint8(uint8(97)), uint8(uint8(116)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(99)), uint8(uint8(111)), uint8(uint8(110)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(101)), uint8(uint8(100)), uint8(uint8(95)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(116)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(98)), uint8(uint8(102)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(109)), uint8(uint8(101)), uint8(uint8(115)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(119)), uint8(uint8(101)), uint8(uint8(105)), uint8(uint8(103)), uint8(uint8(104)), uint8(uint8(116)), uint8(uint8(112)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(107)), uint8(uint8(101)), uint8(uint8(121)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(116)), uint8(uint8(61)), uint8(uint8(50)), uint8(uint8(53)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(107)), uint8(uint8(101)), uint8(uint8(121)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(116)), uint8(uint8(95)), uint8(uint8(109)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(50)), uint8(uint8(32)), uint8(uint8(115)), uint8(uint8(99)), uint8(uint8(101)), uint8(uint8(110)), uint8(uint8(101)), uint8(uint8(99)), uint8(uint8(117)), uint8(uint8(116)), uint8(uint8(61)), uint8(uint8(52)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(116)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(95)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(102)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(115)), uint8(uint8(104)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(114)), uint8(uint8(99)), uint8(uint8(95)), uint8(uint8(108)), uint8(uint8(111)), uint8(uint8(111)), uint8(uint8(107)), uint8(uint8(97)), uint8(uint8(104)), uint8(uint8(101)), uint8(uint8(97)), uint8(uint8(100)), uint8(uint8(61)), uint8(uint8(52)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(114)), uint8(uint8(99)), uint8(uint8(61)), uint8(uint8(99)), uint8(uint8(114)), uint8(uint8(102)), uint8(uint8(32)), uint8(uint8(109)), uint8(uint8(98)), uint8(uint8(116)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(101)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(32)), uint8(uint8(99)), uint8(uint8(114)), uint8(uint8(102)), uint8(uint8(61)), uint8(uint8(50)), uint8(uint8(51)), uint8(uint8(46)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(113)), uint8(uint8(99)), uint8(uint8(111)), uint8(uint8(109)), uint8(uint8(112)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(46)), uint8(uint8(54)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(113)), uint8(uint8(112)), uint8(uint8(109)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(61)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(113)), uint8(uint8(112)), uint8(uint8(109)), uint8(uint8(97)), uint8(uint8(120)), uint8(uint8(61)), uint8(uint8(54)), uint8(uint8(57)), uint8(uint8(32)), uint8(uint8(113)), uint8(uint8(112)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(101)), uint8(uint8(112)), uint8(uint8(61)), uint8(uint8(52)), uint8(uint8(32)), uint8(uint8(105)), uint8(uint8(112)), uint8(uint8(95)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(116)), uint8(uint8(105)), uint8(uint8(111)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(46)), uint8(uint8(52)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(97)), uint8(uint8(113)), uint8(uint8(61)), uint8(uint8(49)), uint8(uint8(58)), uint8(uint8(49)), uint8(uint8(46)), uint8(uint8(48)), uint8(uint8(48)), uint8(0), uint8(uint8(128)), uint8(0), uint8(0), uint8(uint8(6)), uint8(uint8(205)), uint8(uint8(101)), uint8(uint8(136)), uint8(uint8(132)), uint8(uint8(55)), uint8(uint8(196)), uint8(uint8(34)), uint8(uint8(42)), uint8(uint8(224)), uint8(uint8(192)), uint8(uint8(133)), uint8(uint8(248)), uint8(uint8(8)), uint8(uint8(83)), uint8(uint8(34)), uint8(0), uint8(uint8(1)), uint8(0), uint8(uint8(154)), uint8(uint8(212)), uint8(uint8(24)), uint8(uint8(96)), uint8(0), uint8(uint8(241)), uint8(uint8(120)), uint8(uint8(206)), uint8(uint8(140)), uint8(uint8(104)), uint8(uint8(232)), uint8(uint8(23)), uint8(uint8(221)), uint8(uint8(255)), uint8(uint8(226)), uint8(uint8(103)), uint8(uint8(220)), uint8(uint8(153)), uint8(uint8(17)), uint8(uint8(138)), uint8(uint8(191)), uint8(uint8(176)), uint8(uint8(111)), uint8(uint8(254)), uint8(uint8(210)), uint8(uint8(94)), uint8(uint8(97)), uint8(uint8(162)), uint8(uint8(50)), uint8(uint8(176)), uint8(uint8(246)), uint8(uint8(207)), uint8(uint8(251)), uint8(uint8(8)), uint8(uint8(252)), uint8(uint8(69)), uint8(uint8(150)), uint8(uint8(100)), uint8(uint8(62)), uint8(uint8(206)), uint8(uint8(66)), uint8(uint8(95)), uint8(uint8(246)), uint8(uint8(11)), uint8(uint8(52)), uint8(uint8(184)), uint8(uint8(169)), uint8(uint8(4)), uint8(uint8(178)), uint8(uint8(39)), uint8(uint8(251)), uint8(uint8(107)), uint8(uint8(141)), uint8(uint8(67)), uint8(uint8(19)), uint8(uint8(147)), uint8(uint8(229)), uint8(uint8(225)), uint8(uint8(234)), uint8(uint8(245)), uint8(uint8(43)), uint8(uint8(140)), uint8(uint8(26)), uint8(uint8(50)), uint8(uint8(132)), uint8(uint8(221)), uint8(uint8(94)), uint8(uint8(160)), uint8(uint8(117)), uint8(uint8(153)), uint8(uint8(180)), uint8(uint8(112)), uint8(uint8(95)), uint8(uint8(143)), uint8(uint8(239)), uint8(uint8(148)), uint8(uint8(28)), uint8(uint8(84)), uint8(uint8(93)), uint8(uint8(84)), uint8(uint8(19)), uint8(uint8(55)), uint8(uint8(251)), uint8(uint8(224)), uint8(uint8(64)), uint8(0), uint8(uint8(88)), uint8(0), uint8(uint8(193)), uint8(uint8(77)), uint8(uint8(132)), uint8(0), uint8(uint8(9)), uint8(uint8(120)), uint8(0), uint8(uint8(8)), uint8(uint8(4)), uint8(0), uint8(uint8(9)), uint8(uint8(243)), uint8(uint8(48)), uint8(uint8(171)), uint8(uint8(49)), uint8(uint8(208)), uint8(uint8(33)), uint8(uint8(23)), uint8(uint8(202)), uint8(uint8(155)), uint8(uint8(7)), uint8(uint8(134)), uint8(uint8(185)), uint8(uint8(209)), uint8(uint8(164)), uint8(uint8(247)), uint8(uint8(32)), uint8(uint8(56)), uint8(uint8(159)), uint8(uint8(255)), uint8(uint8(180)), uint8(uint8(224)), uint8(uint8(87)), uint8(uint8(49)), uint8(uint8(37)), uint8(uint8(136)), uint8(uint8(210)), uint8(0), uint8(uint8(55)), uint8(uint8(92)), uint8(uint8(81)), uint8(uint8(85)), uint8(uint8(133)), uint8(uint8(69)), uint8(uint8(160)), uint8(uint8(2)), uint8(uint8(13)), uint8(uint8(42)), uint8(uint8(116)), uint8(uint8(189)), uint8(uint8(86)), uint8(uint8(192)), uint8(uint8(35)), uint8(uint8(13)), uint8(uint8(255)), uint8(uint8(251)), uint8(uint8(199)), uint8(uint8(1)), uint8(uint8(78)), uint8(uint8(229)), uint8(uint8(178)), uint8(uint8(35)), uint8(uint8(74)), uint8(uint8(34)), uint8(uint8(160)), uint8(uint8(35)), uint8(uint8(241)), uint8(uint8(118)), uint8(uint8(166)), uint8(uint8(80)), uint8(uint8(56)), uint8(uint8(128)), uint8(uint8(64)), uint8(uint8(51)), uint8(uint8(47)), uint8(uint8(249)), uint8(uint8(50)), uint8(uint8(18)), uint8(uint8(147)), uint8(uint8(188)), uint8(uint8(117)), uint8(uint8(131)), uint8(uint8(7)), uint8(uint8(192)), uint8(uint8(1)), uint8(uint8(226)), uint8(uint8(240)), uint8(uint8(206)), uint8(uint8(140)), uint8(uint8(108)), uint8(uint8(84)), uint8(uint8(11)), uint8(uint8(229)), uint8(uint8(127)), uint8(uint8(250)), uint8(uint8(227)), uint8(uint8(80)), uint8(uint8(198)), uint8(uint8(228)), uint8(uint8(249)), uint8(uint8(104)), uint8(uint8(61)), uint8(uint8(94)), uint8(uint8(6)), uint8(uint8(173)), uint8(uint8(98)), uint8(uint8(86)), uint8(uint8(43)), uint8(uint8(20)), uint8(uint8(33)), uint8(uint8(234)), uint8(uint8(244)), uint8(uint8(128)), uint8(uint8(53)), uint8(uint8(153)), uint8(uint8(146)), uint8(uint8(56)), uint8(uint8(63)), uint8(uint8(191)), uint8(uint8(191)), uint8(uint8(245)), uint8(uint8(194)), uint8(uint8(50)), uint8(uint8(43)), uint8(uint8(57)), uint8(uint8(74)), uint8(uint8(131)), uint8(uint8(168)), uint8(uint8(7)), uint8(uint8(235)), uint8(uint8(120)), uint8(uint8(179)), uint8(uint8(103)), uint8(uint8(124)), uint8(uint8(93)), uint8(uint8(148)), uint8(uint8(89)), uint8(uint8(102)), uint8(uint8(131)), uint8(uint8(169)), uint8(uint8(143)), uint8(uint8(33)), uint8(uint8(239)), uint8(uint8(244)), uint8(uint8(224)), uint8(uint8(134)), uint8(uint8(116)), uint8(uint8(33)), uint8(uint8(76)), uint8(uint8(232)), uint8(uint8(58)), uint8(uint8(172)), uint8(uint8(26)), uint8(uint8(124)), uint8(uint8(84)), uint8(uint8(176)), uint8(uint8(37)), uint8(uint8(186)), uint8(uint8(127)), uint8(uint8(190)), uint8(uint8(3)), uint8(uint8(3)), uint8(uint8(120)), uint8(uint8(72)), uint8(0), uint8(uint8(8)), uint8(uint8(24)), uint8(uint8(160)), uint8(0), uint8(uint8(8)), uint8(uint8(19)), uint8(uint8(134)), uint8(uint8(194)), uint8(uint8(236)), uint8(uint8(128)), uint8(uint8(51)), uint8(uint8(240)), uint8(uint8(122)), uint8(uint8(108)), uint8(uint8(85)), uint8(uint8(152)), uint8(uint8(6)), uint8(uint8(45)), uint8(uint8(3)), uint8(uint8(216)), uint8(uint8(75)), uint8(uint8(38)), uint8(uint8(82)), uint8(uint8(5)), uint8(uint8(165)), uint8(uint8(127)), uint8(uint8(223)), uint8(uint8(96)), uint8(uint8(212)), uint8(uint8(102)), uint8(uint8(122)), uint8(uint8(3)), uint8(uint8(214)), uint8(uint8(183)), uint8(uint8(239)), uint8(uint8(130)), uint8(uint8(108)), uint8(uint8(6)), uint8(uint8(214)), uint8(uint8(20)), uint8(uint8(160)), uint8(uint8(63)), uint8(uint8(39)), uint8(uint8(213)), uint8(uint8(80)), uint8(uint8(26)), uint8(uint8(248)), uint8(uint8(199)), uint8(uint8(1)), uint8(uint8(117)), uint8(uint8(62)), uint8(uint8(193)), uint8(uint8(184)), uint8(uint8(200)), uint8(uint8(217)), uint8(uint8(128)), uint8(uint8(253)), uint8(uint8(134)), uint8(uint8(253)), uint8(uint8(246)), uint8(uint8(4)), uint8(uint8(188)), uint8(uint8(140)), uint8(uint8(215)), uint8(uint8(40)), uint8(uint8(37)), uint8(uint8(194)), uint8(uint8(127)), uint8(uint8(252)), uint8(uint8(136)), uint8(uint8(171)), uint8(uint8(136)), uint8(uint8(168)), uint8(uint8(19)), uint8(uint8(101)), uint8(uint8(97)), uint8(uint8(224)), uint8(uint8(113)), uint8(0), uint8(uint8(128)), uint8(uint8(102)), uint8(uint8(95)), uint8(uint8(242)), uint8(uint8(100)), uint8(uint8(152)), uint8(uint8(93)), uint8(uint8(226)), uint8(uint8(252)), uint8(uint8(55)), uint8(uint8(17)), uint8(uint8(120)), uint8(uint8(203)), uint8(uint8(152)), uint8(uint8(145)), uint8(uint8(240)), uint8(uint8(254)), uint8(uint8(239)), uint8(uint8(255)), uint8(uint8(127)), uint8(uint8(201)), uint8(uint8(145)), uint8(uint8(24)), uint8(uint8(93)), uint8(uint8(239)), uint8(uint8(249)), uint8(uint8(3)), uint8(uint8(184)), uint8(uint8(212)), uint8(uint8(49)), uint8(uint8(185)), uint8(uint8(62)), uint8(uint8(90)), uint8(uint8(143)), uint8(uint8(87)), uint8(uint8(182)), uint8(uint8(82)), uint8(uint8(57)), uint8(uint8(32)), uint8(uint8(123)), uint8(uint8(59)), uint8(uint8(51)), uint8(uint8(255)), uint8(uint8(168)), uint8(uint8(15)), uint8(uint8(144)), uint8(uint8(140)), uint8(uint8(152)), uint8(uint8(160)), uint8(uint8(47)), uint8(uint8(223)), uint8(uint8(247)), uint8(uint8(203)), uint8(uint8(3)), uint8(uint8(206)), uint8(uint8(71)), uint8(uint8(74)), uint8(uint8(80)), uint8(uint8(36)), uint8(uint8(102)), uint8(uint8(255)), uint8(uint8(125)), uint8(uint8(113)), uint8(uint8(168)), uint8(uint8(99)), uint8(uint8(114)), uint8(uint8(124)), uint8(uint8(190)), uint8(uint8(61)), uint8(uint8(94)), uint8(uint8(6)), uint8(uint8(186)), uint8(uint8(197)), uint8(uint8(216)), uint8(uint8(172)), uint8(uint8(86)), uint8(uint8(61)), uint8(uint8(94)), uint8(uint8(160)), uint8(uint8(107)), uint8(uint8(146)), uint8(uint8(145)), uint8(uint8(7)), uint8(uint8(151)), uint8(uint8(239)), uint8(uint8(251)), uint8(uint8(211)), uint8(uint8(145)), uint8(uint8(147)), uint8(uint8(179)), uint8(uint8(151)), uint8(uint8(160)), uint8(uint8(234)), uint8(uint8(14)), uint8(uint8(96)), uint8(uint8(6)), uint8(uint8(4)), uint8(uint8(128)), uint8(uint8(72)), uint8(0), uint8(uint8(6)), uint8(uint8(105)), uint8(uint8(1)), uint8(uint8(212)), uint8(uint8(10)), uint8(uint8(88)), uint8(uint8(218)), uint8(uint8(152)), uint8(uint8(108)), uint8(0), uint8(uint8(249)), uint8(uint8(112)), uint8(uint8(57)), uint8(uint8(246)), uint8(uint8(15)), uint8(uint8(48)), uint8(uint8(5)), uint8(uint8(241)), uint8(uint8(13)), uint8(uint8(184)), uint8(uint8(218)), uint8(uint8(158)), uint8(uint8(9)), uint8(uint8(50)), uint8(uint8(52)), uint8(uint8(136)), uint8(uint8(41)), uint8(uint8(58)), uint8(uint8(254)), uint8(uint8(243)), uint8(uint8(62)), uint8(uint8(208)), uint8(uint8(37)), uint8(uint8(27)), uint8(uint8(83)), uint8(uint8(26)), uint8(uint8(248)), uint8(uint8(197)), uint8(uint8(159)), uint8(uint8(93)), uint8(uint8(140)), uint8(uint8(12)), uint8(uint8(215)), uint8(uint8(193)), uint8(uint8(101)), uint8(uint8(241)), uint8(uint8(189)), uint8(uint8(57)), uint8(uint8(129)), uint8(uint8(252)), uint8(uint8(232)), uint8(uint8(189)), uint8(uint8(69)), uint8(uint8(153)), uint8(uint8(174)), uint8(uint8(253)), uint8(uint8(236)), uint8(uint8(113)), uint8(uint8(21)), uint8(uint8(123)), uint8(uint8(36)), uint8(uint8(191)), uint8(uint8(6)), uint8(uint8(144)), uint8(0), uint8(uint8(16)), uint8(uint8(53)), uint8(uint8(101)), uint8(uint8(224)), uint8(0), uint8(uint8(240)), uint8(uint8(189)), uint8(uint8(56)), uint8(uint8(188)), uint8(uint8(167)), uint8(uint8(82)), uint8(uint8(248)), uint8(uint8(213)), uint8(uint8(157)), uint8(uint8(255)), uint8(uint8(239)), uint8(uint8(205)), uint8(uint8(72)), uint8(uint8(50)), uint8(uint8(51)), uint8(uint8(137)), uint8(uint8(107)), uint8(uint8(157)), uint8(uint8(218)), uint8(uint8(238)), uint8(uint8(33)), uint8(uint8(122)), uint8(uint8(113)), uint8(uint8(121)), uint8(uint8(78)), uint8(uint8(165)), uint8(uint8(241)), uint8(uint8(235)), uint8(uint8(59)), uint8(uint8(255)), uint8(uint8(192)), uint8(uint8(174)), uint8(uint8(47)), uint8(uint8(204)), uint8(uint8(198)), uint8(uint8(17)), uint8(uint8(78)), uint8(uint8(81)), uint8(uint8(234)), uint8(uint8(247)), uint8(uint8(59)), uint8(uint8(9)), uint8(uint8(31)), uint8(uint8(35)), uint8(uint8(15)), uint8(uint8(156)), uint8(uint8(182)), uint8(uint8(43)), uint8(uint8(255)), uint8(uint8(214)), uint8(uint8(28)), uint8(uint8(22)), uint8(uint8(31)), uint8(uint8(85)), uint8(uint8(156)), uint8(uint8(222)), uint8(uint8(151)), uint8(uint8(127)), uint8(uint8(172)), uint8(uint8(13)), uint8(uint8(186)), uint8(uint8(11)), uint8(uint8(211)), uint8(uint8(6)), uint8(uint8(105)), uint8(uint8(215)), uint8(uint8(253)), uint8(uint8(245)), uint8(uint8(168)), uint8(uint8(123)), uint8(uint8(28)), uint8(uint8(17)), uint8(uint8(77)), uint8(uint8(88)), uint8(uint8(222)), uint8(uint8(30)), uint8(uint8(175)), uint8(uint8(91)), uint8(uint8(133)), uint8(uint8(241)), uint8(uint8(193)), uint8(uint8(84)), uint8(uint8(197)), uint8(uint8(140)), uint8(uint8(233)), uint8(uint8(234)), uint8(uint8(244)), uint8(uint8(128)), uint8(0), uint8(uint8(243)), uint8(uint8(24)), uint8(uint8(205)), uint8(uint8(142)), uint8(0), uint8(uint8(171)), uint8(uint8(127)), uint8(uint8(127)), uint8(uint8(237)), uint8(0), uint8(uint8(120)), uint8(uint8(230)), uint8(uint8(59)), uint8(uint8(115)), uint8(uint8(128)), uint8(uint8(34)), uint8(uint8(151)), uint8(uint8(253)), uint8(uint8(240)), uint8(uint8(32)), uint8(uint8(64)), uint8(0), uint8(uint8(64)), uint8(uint8(33)), uint8(uint8(128)), uint8(0), uint8(uint8(160)), uint8(uint8(136)), uint8(uint8(6)), uint8(uint8(91)), uint8(uint8(147)), uint8(uint8(176)), uint8(uint8(9)), uint8(uint8(180)), uint8(uint8(229)), uint8(uint8(16)), uint8(uint8(42)), uint8(uint8(196)), uint8(uint8(196)), uint8(uint8(192)), uint8(uint8(9)), uint8(uint8(149)), uint8(uint8(128)), uint8(uint8(12)), uint8(uint8(54)), uint8(uint8(167)), uint8(uint8(128)), uint8(uint8(217)), uint8(uint8(14)), uint8(uint8(83)), uint8(uint8(169)), uint8(0), uint8(uint8(185)), uint8(uint8(54)), uint8(uint8(239)), uint8(uint8(223)), uint8(uint8(48)), uint8(0), uint8(uint8(4)), uint8(uint8(142)), uint8(uint8(193)), uint8(uint8(132)), uint8(uint8(82)), uint8(uint8(99)), uint8(uint8(106)), uint8(uint8(115)), uint8(uint8(86)), uint8(uint8(248)), uint8(uint8(131)), uint8(uint8(243)), uint8(uint8(236)), uint8(uint8(206)), uint8(uint8(53)), uint8(uint8(200)), uint8(uint8(56)), uint8(uint8(218)), uint8(uint8(158)), uint8(uint8(5)), uint8(uint8(251)), uint8(uint8(35)), uint8(uint8(101)), uint8(uint8(9)), uint8(uint8(113)), uint8(uint8(9)), uint8(uint8(253)), uint8(uint8(243)), uint8(0), uint8(uint8(2)), uint8(uint8(202)), uint8(uint8(41)), uint8(uint8(55)), uint8(uint8(3)), uint8(uint8(106)), uint8(uint8(113)), uint8(uint8(21)), uint8(uint8(1)), uint8(uint8(31)), uint8(uint8(109)), uint8(uint8(141)), uint8(uint8(51)), uint8(uint8(1)), uint8(uint8(208)), uint8(uint8(32)), uint8(uint8(102)), uint8(uint8(95)), uint8(uint8(114)), uint8(uint8(100)), uint8(uint8(152)), uint8(uint8(187)), uint8(uint8(175)), uint8(uint8(198)), uint8(uint8(255)), uint8(uint8(224)), uint8(uint8(248)), uint8(0), uint8(uint8(82)), uint8(uint8(241)), uint8(uint8(190)), uint8(uint8(98)), uint8(uint8(71)), uint8(uint8(194)), uint8(uint8(251)), uint8(uint8(191)), uint8(uint8(253)), uint8(uint8(75)), uint8(uint8(163)), uint8(uint8(4)), uint8(uint8(142)), uint8(uint8(161)), uint8(uint8(85)), uint8(uint8(171)), uint8(uint8(199)), uint8(uint8(157)), uint8(uint8(7)), uint8(uint8(230)), uint8(uint8(100)), uint8(uint8(135)), uint8(uint8(226)), uint8(uint8(207)), uint8(uint8(246)), uint8(uint8(192)), uint8(uint8(229)), uint8(uint8(198)), uint8(uint8(200)), uint8(uint8(74)), uint8(uint8(233)), uint8(uint8(171)), uint8(uint8(203)), uint8(uint8(105)), uint8(uint8(78)), uint8(uint8(80)), uint8(uint8(27)), uint8(uint8(16)), uint8(uint8(226)), uint8(uint8(111)), uint8(uint8(244)), uint8(uint8(9)), uint8(uint8(101)), uint8(uint8(180)), uint8(uint8(159)), uint8(uint8(165)), uint8(uint8(84)), uint8(uint8(30)), uint8(uint8(185)), uint8(uint8(210)), uint8(uint8(195)), uint8(uint8(113)), uint8(uint8(191)), uint8(uint8(190)), uint8(uint8(192)), uint8(uint8(193)), uint8(uint8(167)), uint8(uint8(10)), uint8(0), uint8(uint8(11)), uint8(uint8(129)), uint8(uint8(131)), uint8(uint8(16)), uint8(uint8(31)), uint8(uint8(42)), uint8(uint8(32)), uint8(uint8(75)), uint8(uint8(79)), uint8(uint8(171)), uint8(uint8(96)), uint8(uint8(116)), uint8(uint8(170)), uint8(uint8(129)), uint8(uint8(41)), uint8(uint8(62)), uint8(uint8(194)), uint8(uint8(45)), uint8(uint8(28)), uint8(uint8(161)), uint8(uint8(25)), uint8(uint8(41)), uint8(uint8(127)), uint8(uint8(252)), uint8(uint8(211)), uint8(uint8(22)), uint8(uint8(95)), uint8(uint8(245)), uint8(uint8(97)), uint8(uint8(242)), uint8(uint8(169)), uint8(uint8(15)), uint8(uint8(255)), uint8(uint8(21)), uint8(uint8(54)), uint8(uint8(4)), uint8(uint8(36)), uint8(uint8(79)), uint8(uint8(10)), uint8(uint8(30)), uint8(uint8(2)), uint8(uint8(18)), uint8(uint8(103)), uint8(uint8(128)), uint8(uint8(110)), uint8(uint8(115)), uint8(uint8(45)), uint8(uint8(227)), uint8(uint8(58)), uint8(uint8(194)), uint8(uint8(127)), uint8(uint8(249)), uint8(uint8(133)), uint8(uint8(229)), uint8(uint8(144)), uint8(uint8(210)), uint8(uint8(201)), uint8(uint8(143)), uint8(uint8(212)), uint8(uint8(69)), uint8(uint8(92)), uint8(uint8(69)), uint8(uint8(65)), uint8(uint8(220)), uint8(uint8(164)), uint8(uint8(62)), uint8(uint8(96)), uint8(uint8(58)), uint8(uint8(33)), uint8(uint8(153)), uint8(uint8(123)), uint8(uint8(197)), uint8(uint8(90)), uint8(uint8(219)), uint8(uint8(226)), uint8(uint8(223)), uint8(uint8(224)), uint8(uint8(40)), uint8(uint8(137)), uint8(uint8(200)), uint8(uint8(167)), uint8(uint8(15)), uint8(uint8(183)), uint8(uint8(127)), uint8(uint8(176)), uint8(uint8(26)), uint8(uint8(90)), uint8(uint8(76)), uint8(uint8(183)), uint8(uint8(186)), uint8(uint8(255)), uint8(uint8(237)), uint8(uint8(200)), uint8(uint8(156)), uint8(uint8(138)), uint8(uint8(112)), uint8(uint8(251)), uint8(uint8(119)), uint8(uint8(250)), uint8(uint8(185)), uint8(uint8(98)), uint8(uint8(77)), uint8(uint8(159)), uint8(uint8(151)), uint8(uint8(236)), uint8(uint8(84)), uint8(uint8(234)), uint8(uint8(58)), uint8(uint8(105)), uint8(uint8(95)), uint8(uint8(245)), uint8(uint8(15)), uint8(uint8(73)), uint8(uint8(83)), uint8(uint8(3)), uint8(uint8(251)), uint8(uint8(251)), uint8(uint8(229)), uint8(uint8(14)), uint8(uint8(105)), uint8(uint8(219)), uint8(uint8(2)), uint8(uint8(223)), uint8(uint8(251)), uint8(uint8(229)), uint8(uint8(106)), uint8(uint8(197)), uint8(uint8(151)), uint8(uint8(159)), uint8(uint8(106)), uint8(uint8(245)), uint8(uint8(102)), uint8(uint8(199)), uint8(uint8(147)), uint8(uint8(155)), uint8(uint8(234)), uint8(uint8(244)), uint8(uint8(131)), uint8(uint8(164)), uint8(uint8(169)), uint8(uint8(129)), uint8(uint8(247)), uint8(uint8(247)), uint8(uint8(254)), uint8(uint8(208)), uint8(uint8(230)), uint8(uint8(157)), uint8(uint8(176)), uint8(uint8(44)), uint8(uint8(191)), uint8(uint8(223)), uint8(uint8(4)), uint8(uint8(8)), uint8(uint8(116)), uint8(uint8(32)), uint8(0), uint8(uint8(8)), uint8(uint8(1)), uint8(uint8(128)), uint8(uint8(14)), uint8(uint8(154)), uint8(uint8(74)), uint8(uint8(240)), uint8(uint8(67)), uint8(uint8(106)), uint8(uint8(100)), uint8(uint8(165)), uint8(uint8(120)), uint8(uint8(33)), uint8(uint8(181)), uint8(uint8(54)), uint8(uint8(2)), uint8(uint8(185)), uint8(uint8(137)), uint8(uint8(40)), uint8(uint8(218)), uint8(uint8(152)), uint8(uint8(128)), uint8(uint8(174)), uint8(uint8(98)), uint8(uint8(74)), uint8(uint8(54)), uint8(uint8(166)), uint8(uint8(76)), uint8(uint8(3)), uint8(uint8(231)), uint8(uint8(14)), uint8(uint8(54)), uint8(uint8(166)), uint8(uint8(76)), uint8(uint8(3)), uint8(uint8(231)), uint8(uint8(14)), uint8(uint8(54)), uint8(uint8(166)), uint8(uint8(192)), uint8(uint8(10)), uint8(uint8(114)), uint8(uint8(158)), uint8(uint8(193)), uint8(uint8(181)), uint8(uint8(49)), uint8(0), uint8(uint8(41)), uint8(uint8(202)), uint8(uint8(123)), uint8(uint8(6)), uint8(uint8(212)), uint8(uint8(224)), uint8(0), uint8(uint8(2)), uint8(uint8(53)), uint8(uint8(8)), uint8(uint8(125)), uint8(uint8(134)), uint8(uint8(133)), uint8(uint8(185)), uint8(uint8(123)), uint8(uint8(55)), uint8(uint8(192)), uint8(uint8(31)), uint8(uint8(183)), uint8(uint8(130)), uint8(uint8(39)), uint8(uint8(213)), uint8(uint8(117)), uint8(uint8(3)), uint8(uint8(32)), uint8(uint8(48)), uint8(0), uint8(uint8(129)), uint8(uint8(89)), uint8(0), uint8(uint8(12)), uint8(uint8(72)), uint8(uint8(14)), uint8(uint8(5)), uint8(uint8(128)), uint8(uint8(124)), uint8(uint8(71)), uint8(uint8(128)), uint8(uint8(112)), uint8(uint8(28)), uint8(uint8(3)), uint8(uint8(96)), uint8(uint8(32)), uint8(uint8(138)), uint8(uint8(11)), uint8(uint8(64)), uint8(uint8(5)), uint8(uint8(96)), uint8(uint8(104)), uint8(uint8(226)), uint8(uint8(80)), uint8(uint8(28)), uint8(uint8(1)), uint8(uint8(176)), uint8(uint8(226)), uint8(uint8(32)), uint8(uint8(28)), uint8(uint8(48)), uint8(uint8(241)), uint8(uint8(197)), uint8(uint8(231)), uint8(uint8(182)), uint8(uint8(76)), uint8(uint8(203)), uint8(uint8(243)), uint8(uint8(223)), uint8(uint8(124)), uint8(uint8(12)), uint8(uint8(1)), uint8(uint8(57)), uint8(uint8(3)), uint8(uint8(8)), uint8(uint8(16)), uint8(0), uint8(uint8(148)), uint8(uint8(93)), uint8(uint8(248)), uint8(uint8(63)), uint8(uint8(104)), uint8(uint8(100)), uint8(uint8(212)), uint8(uint8(249)), uint8(uint8(192)), uint8(uint8(252)), uint8(uint8(155)), uint8(uint8(255)), uint8(uint8(235)), uint8(uint8(133)), uint8(uint8(13)), uint8(uint8(55)), uint8(uint8(127)), uint8(uint8(243)), uint8(uint8(254)), uint8(uint8(40)), uint8(uint8(28)), uint8(uint8(13)), uint8(uint8(6)), uint8(uint8(16)), uint8(uint8(52)), uint8(uint8(52)), uint8(uint8(125)), uint8(uint8(246)), uint8(uint8(15)), uint8(uint8(248)), uint8(uint8(135)), uint8(uint8(163)), uint8(uint8(158)), uint8(uint8(127)), uint8(uint8(128)), uint8(uint8(147)), uint8(uint8(225)), uint8(uint8(196)), uint8(uint8(127)), uint8(uint8(70)), uint8(uint8(187)), uint8(uint8(154)), uint8(uint8(239)), uint8(uint8(38)), uint8(uint8(62)), uint8(uint8(35)), uint8(uint8(254)), uint8(uint8(131)), uint8(uint8(66)), uint8(uint8(76)), uint8(uint8(251)), uint8(uint8(117)), uint8(uint8(127)), uint8(uint8(252)), uint8(uint8(129)), uint8(uint8(94)), uint8(uint8(155)), uint8(uint8(32)), uint8(uint8(78)), uint8(uint8(203)), uint8(uint8(206)), uint8(uint8(244)), uint8(uint8(195)), uint8(uint8(2)), uint8(uint8(112)), uint8(uint8(26)), uint8(uint8(32)), uint8(0), uint8(uint8(128)), uint8(uint8(150)), uint8(uint8(183)), uint8(uint8(73)), uint8(uint8(136)), uint8(uint8(151)), uint8(uint8(225)), uint8(uint8(111)), uint8(uint8(61)), uint8(uint8(225)), uint8(uint8(31)), uint8(uint8(255)), uint8(uint8(162)), uint8(uint8(53)), uint8(uint8(137)), uint8(uint8(126)), uint8(uint8(43)), uint8(uint8(84)), uint8(uint8(157)), uint8(uint8(88)), uint8(uint8(174)), uint8(uint8(59)), uint8(uint8(195)), uint8(uint8(30)), uint8(uint8(187)), uint8(uint8(160)), uint8(0), uint8(uint8(79)), uint8(uint8(134)), uint8(uint8(176)), uint8(uint8(169)), uint8(uint8(217)), uint8(uint8(37)), uint8(uint8(240)), uint8(uint8(206)), uint8(uint8(51)), uint8(uint8(104)), uint8(uint8(63)), uint8(uint8(156)), uint8(uint8(186)), uint8(uint8(146)), uint8(uint8(195)), uint8(0), uint8(uint8(20)), uint8(uint8(5)), uint8(uint8(132)), uint8(uint8(1)), uint8(uint8(87)), uint8(uint8(1)), uint8(uint8(155)), uint8(uint8(56)), uint8(uint8(104)), uint8(uint8(101)), uint8(uint8(17)), uint8(uint8(197)), uint8(uint8(104)), uint8(uint8(216)), uint8(uint8(60)), uint8(uint8(230)), uint8(uint8(92)), uint8(uint8(46)), uint8(uint8(202)), uint8(uint8(13)), uint8(uint8(33)), uint8(uint8(57)), uint8(uint8(91)), uint8(uint8(247)), uint8(uint8(119)), uint8(uint8(31)), uint8(uint8(52)), uint8(uint8(140)), uint8(uint8(93)), uint8(uint8(142)), uint8(uint8(80)), uint8(uint8(26)), uint8(uint8(122)), uint8(uint8(103)), uint8(uint8(56)), uint8(uint8(120)), uint8(uint8(96)), uint8(uint8(22)), uint8(uint8(4)), uint8(uint8(198)), uint8(uint8(30)), uint8(uint8(126)), uint8(uint8(171)), uint8(uint8(254)), uint8(uint8(160)), uint8(uint8(1)), uint8(uint8(75)), uint8(uint8(204)), uint8(uint8(121)), uint8(uint8(26)), uint8(uint8(46)), uint8(uint8(58)), uint8(uint8(147)), uint8(uint8(255)), uint8(uint8(218)), uint8(uint8(135)), uint8(uint8(125)), uint8(uint8(164)), uint8(uint8(167)), uint8(uint8(65)), uint8(uint8(163)), uint8(uint8(20)), uint8(uint8(219)), uint8(uint8(239)), uint8(uint8(86)), uint8(uint8(11)), uint8(uint8(107)), uint8(uint8(70)), uint8(uint8(160)), uint8(uint8(185)), uint8(uint8(175)), uint8(uint8(246)), uint8(uint8(193)), uint8(uint8(8)), uint8(uint8(1)), uint8(uint8(41)), uint8(uint8(128)), uint8(uint8(192)), uint8(uint8(3)), uint8(uint8(192)), uint8(uint8(14)), uint8(uint8(24)), uint8(uint8(204)), uint8(uint8(109)), uint8(uint8(180)), uint8(uint8(129)), uint8(uint8(236)), uint8(uint8(23)), uint8(uint8(146)), uint8(uint8(54)), uint8(uint8(226)), uint8(uint8(13)), uint8(uint8(13)), uint8(uint8(255)), uint8(uint8(251)), uint8(uint8(192)), uint8(uint8(195)), uint8(uint8(34)), uint8(uint8(248)), uint8(uint8(147)), uint8(uint8(105)), uint8(uint8(240)), uint8(uint8(2)), uint8(uint8(29)), uint8(uint8(93)), uint8(uint8(124)), uint8(uint8(7)), uint8(uint8(29)), uint8(uint8(194)), uint8(uint8(51)), uint8(uint8(22)), uint8(uint8(159)), uint8(uint8(41)), uint8(uint8(31)), uint8(uint8(206)), uint8(uint8(88)), uint8(uint8(97)), uint8(uint8(128)), uint8(uint8(127)), uint8(uint8(193)), uint8(uint8(88)), uint8(uint8(156)), uint8(uint8(4)), uint8(uint8(200)), uint8(uint8(157)), uint8(uint8(137)), uint8(uint8(90)), uint8(uint8(187)), uint8(uint8(3)), uint8(uint8(128)), uint8(uint8(1)), uint8(uint8(12)), uint8(uint8(3)), uint8(uint8(132)), uint8(uint8(16)), uint8(0), uint8(uint8(118)), uint8(uint8(128)), uint8(uint8(10)), uint8(0), uint8(uint8(202)), uint8(uint8(109)), uint8(uint8(158)), uint8(uint8(100)), uint8(uint8(96)), uint8(uint8(68)), uint8(uint8(100)), uint8(uint8(150)), uint8(uint8(30)), uint8(0), uint8(uint8(66)), uint8(uint8(104)), uint8(uint8(208)), uint8(uint8(106)), uint8(uint8(132)), uint8(uint8(27)), uint8(uint8(156)), uint8(uint8(89)), uint8(uint8(68)), uint8(0), uint8(uint8(8)), uint8(uint8(97)), uint8(uint8(50)), uint8(uint8(195)), uint8(uint8(248)), uint8(uint8(6)), uint8(0), uint8(uint8(28)), uint8(uint8(3)), uint8(uint8(97)), uint8(uint8(178)), uint8(uint8(96)), uint8(uint8(114)), uint8(uint8(3)), uint8(uint8(6)), uint8(uint8(101)), uint8(uint8(226)), uint8(uint8(128)), uint8(uint8(60)), uint8(uint8(72)), uint8(0), uint8(uint8(104)), uint8(uint8(72)), uint8(0), uint8(uint8(8)), uint8(uint8(1)), uint8(uint8(160)), uint8(uint8(228)), uint8(uint8(24)), uint8(uint8(146)), uint8(uint8(195)), uint8(uint8(144)), uint8(uint8(98)), uint8(uint8(75)), uint8(uint8(28)), uint8(uint8(32)), uint8(uint8(118)), uint8(uint8(7)), uint8(uint8(4)), uint8(uint8(12)), uint8(uint8(192)), uint8(uint8(112)), uint8(uint8(138)), uint8(uint8(68)), uint8(uint8(176)), uint8(uint8(225)), uint8(uint8(20)), uint8(uint8(137)), uint8(uint8(99)), uint8(uint8(128)), uint8(uint8(64)), uint8(uint8(43)), uint8(uint8(3)), uint8(uint8(128)), uint8(uint8(32)), uint8(uint8(17)), uint8(uint8(142)), uint8(uint8(1)), uint8(0), uint8(uint8(255)), uint8(uint8(193)), uint8(uint8(89)), uint8(uint8(48)), uint8(uint8(60)), uint8(uint8(24)), uint8(uint8(102)), uint8(uint8(88)), uint8(uint8(72)), uint8(uint8(16)), uint8(uint8(192)), uint8(uint8(240)), uint8(uint8(128)), uint8(uint8(64)), uint8(uint8(10)), uint8(uint8(192)), uint8(uint8(12)), uint8(uint8(14)), uint8(uint8(19)), uint8(uint8(141)), uint8(uint8(44)), uint8(uint8(128)), uint8(uint8(156)), uint8(uint8(105)), uint8(uint8(127)), uint8(uint8(174)), uint8(uint8(235)), uint8(uint8(190)), uint8(uint8(64)), uint8(uint8(1)), uint8(uint8(128)), uint8(uint8(127)), uint8(uint8(176)), uint8(uint8(86)), uint8(uint8(80)), uint8(uint8(21)), uint8(uint8(99)), uint8(uint8(14)), uint8(uint8(100)), uint8(uint8(74)), uint8(uint8(178)), uint8(uint8(40)), uint8(uint8(41)), uint8(uint8(149)), uint8(uint8(134)), uint8(0), uint8(uint8(2)), uint8(uint8(2)), uint8(uint8(108)), uint8(0), uint8(uint8(2)), uint8(uint8(4)), uint8(uint8(144)), uint8(uint8(200)), uint8(uint8(180)), uint8(uint8(28)), uint8(uint8(1)), uint8(uint8(16)), uint8(uint8(250)), uint8(uint8(160)), uint8(uint8(28)), uint8(uint8(4)), uint8(uint8(99)), uint8(uint8(98)), uint8(uint8(137)), uint8(uint8(145)), uint8(uint8(65)), uint8(uint8(73)), uint8(uint8(43)), uint8(uint8(122)), uint8(uint8(105)), uint8(uint8(158)), uint8(uint8(3)), uint8(uint8(128)), uint8(uint8(67)), uint8(uint8(190)), uint8(uint8(73)), uint8(uint8(48)), uint8(uint8(60)), uint8(uint8(6)), uint8(uint8(51)), uint8(uint8(35)), uint8(uint8(129)), uint8(uint8(35)), uint8(uint8(134)), uint8(uint8(204)), uint8(uint8(131)), uint8(uint8(182)), uint8(uint8(95)), uint8(uint8(162)), uint8(uint8(123)), uint8(uint8(224)), uint8(uint8(96)), uint8(uint8(3)), uint8(uint8(67)), uint8(uint8(132)), uint8(uint8(128)), uint8(0), uint8(uint8(128)), uint8(uint8(139)), uint8(0), uint8(0), uint8(uint8(128)), uint8(0), uint8(uint8(24)), uint8(uint8(240)), uint8(uint8(86)), uint8(uint8(207)), uint8(uint8(8)), uint8(uint8(66)), uint8(uint8(178)), uint8(uint8(207)), uint8(uint8(2)), uint8(uint8(206)), uint8(0), uint8(uint8(153)), uint8(0), uint8(uint8(150)), uint8(uint8(102)), uint8(uint8(88)), uint8(uint8(216)), uint8(uint8(233)), uint8(uint8(187)), uint8(uint8(74)), uint8(uint8(60)), uint8(uint8(65)), uint8(uint8(221)), uint8(uint8(156)), uint8(uint8(181)), uint8(uint8(102)), uint8(uint8(115)), uint8(uint8(157)), uint8(uint8(192)), uint8(uint8(32)), uint8(uint8(16)), uint8(uint8(130)), uint8(uint8(225)), uint8(uint8(39)), uint8(uint8(196)), uint8(uint8(241)), uint8(uint8(254)), uint8(uint8(92)), uint8(uint8(123)), uint8(uint8(138)), uint8(0), uint8(uint8(7)), uint8(uint8(160)), uint8(uint8(9)), uint8(uint8(237)), uint8(uint8(41)), uint8(uint8(85)), uint8(uint8(175)), uint8(uint8(159)), uint8(uint8(216)), uint8(uint8(66)), uint8(uint8(5)), uint8(uint8(134)), uint8(uint8(8)), uint8(0), uint8(uint8(10)), uint8(0), uint8(uint8(135)), uint8(uint8(135)), uint8(uint8(154)), uint8(uint8(135)), uint8(uint8(217)), uint8(uint8(202)), uint8(uint8(73)), uint8(uint8(164)), uint8(uint8(184)), uint8(uint8(85)), uint8(uint8(32)), uint8(uint8(209)), uint8(uint8(54)), uint8(uint8(16)), uint8(uint8(32)), uint8(uint8(150)), uint8(uint8(89)), uint8(uint8(2)), uint8(uint8(9)), uint8(uint8(229)), uint8(uint8(128)), uint8(uint8(172)), uint8(uint8(36)), uint8(uint8(206)), uint8(uint8(47)), uint8(uint8(163)), uint8(uint8(119)), uint8(uint8(179)), uint8(uint8(192)), uint8(uint8(35)), uint8(uint8(116)), uint8(uint8(100)), uint8(uint8(50)), uint8(uint8(24)), uint8(uint8(124)), uint8(uint8(41)), uint8(uint8(227)), uint8(uint8(17)), uint8(uint8(221)), uint8(uint8(163)), uint8(uint8(65)), uint8(uint8(44)), uint8(uint8(99)), uint8(uint8(24)), uint8(uint8(255)), uint8(uint8(240)), uint8(uint8(195)), uint8(uint8(176)), uint8(uint8(84)), uint8(uint8(9)), uint8(uint8(4)), uint8(0), uint8(uint8(2)), uint8(uint8(128)), uint8(uint8(168)), uint8(uint8(64)), uint8(0), uint8(uint8(52)), uint8(uint8(2)), uint8(uint8(172)), uint8(uint8(28)), uint8(uint8(64)), uint8(uint8(9)), uint8(uint8(128)), uint8(uint8(114)), uint8(0), uint8(uint8(108)), uint8(uint8(96)), uint8(uint8(224)), uint8(uint8(32)), uint8(uint8(102)), uint8(uint8(1)), uint8(uint8(192)), uint8(uint8(129)), uint8(uint8(216)), uint8(uint8(51)), uint8(uint8(4)), uint8(uint8(113)), uint8(uint8(172)), uint8(uint8(96)), uint8(uint8(3)), uint8(uint8(195)), uint8(0), uint8(uint8(255)), uint8(uint8(216)), uint8(uint8(43)), uint8(uint8(131)), uint8(uint8(145)), uint8(uint8(255)), uint8(uint8(68)), uint8(uint8(148)), uint8(uint8(92)), uint8(uint8(92)), uint8(uint8(92)), uint8(uint8(92)), uint8(uint8(92)), uint8(uint8(92)), uint8(uint8(92)), uint8(uint8(95)), uint8(uint8(12)), uint8(uint8(3)), uint8(uint8(255)), uint8(uint8(96)), uint8(uint8(174)), uint8(uint8(47)), uint8(uint8(196)), uint8(0), uint8(uint8(18)), uint8(uint8(68)), uint8(0), uint8(uint8(8)), uint8(uint8(145)), uint8(uint8(89)), uint8(uint8(108)), uint8(uint8(86)), uint8(uint8(43)), uint8(uint8(17)), uint8(uint8(96)), uint8(uint8(128)), uint8(uint8(4)), uint8(uint8(186)), uint8(uint8(225)), uint8(uint8(214)), uint8(uint8(3)), uint8(uint8(128)), uint8(uint8(37)), uint8(uint8(215)), uint8(uint8(32)), uint8(uint8(28)), uint8(uint8(63)), uint8(uint8(246)), uint8(uint8(10)), uint8(uint8(226)), uint8(uint8(191)), uint8(uint8(196)), uint8(0), uint8(uint8(1)), uint8(uint8(6)), uint8(uint8(80)), uint8(0), uint8(uint8(16)), uint8(uint8(68)), uint8(uint8(136)), uint8(0), uint8(uint8(2)), uint8(uint8(60)), uint8(0), uint8(0), uint8(uint8(35)), uint8(uint8(147)), uint8(uint8(45)), uint8(uint8(25)), uint8(uint8(96)), uint8(uint8(16)), uint8(0), uint8(uint8(16)), uint8(uint8(49)), uint8(uint8(96)), uint8(uint8(84)), uint8(uint8(99)), uint8(uint8(128)), uint8(uint8(64)), uint8(0), uint8(uint8(64)), uint8(uint8(197)), uint8(uint8(130)), uint8(0), uint8(uint8(151)), uint8(uint8(92)), uint8(uint8(32)), uint8(0), uint8(uint8(4)), uint8(uint8(35)), uint8(uint8(232)), uint8(0), uint8(uint8(8)), uint8(uint8(200)), uint8(uint8(92)), uint8(uint8(14)), uint8(uint8(4)), uint8(uint8(186)), uint8(uint8(224)), uint8(uint8(112)), uint8(0), uint8(uint8(16)), uint8(uint8(143)), uint8(uint8(160)), uint8(0), uint8(uint8(35)), uint8(uint8(33)), uint8(uint8(114)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(202)), uint8(uint8(65)), uint8(uint8(154)), uint8(uint8(56)), uint8(uint8(111)), uint8(uint8(227)), uint8(uint8(97)), uint8(uint8(110)), uint8(uint8(34)), uint8(uint8(31)), uint8(uint8(127)), uint8(uint8(2)), uint8(uint8(20)), uint8(uint8(241)), uint8(uint8(202)), uint8(uint8(12)), uint8(uint8(156)), uint8(uint8(247)), uint8(uint8(153)), uint8(uint8(35)), uint8(uint8(13)), uint8(uint8(60)), uint8(uint8(189)), uint8(uint8(247)), uint8(uint8(191)), uint8(uint8(132)), uint8(0), uint8(uint8(6)), uint8(uint8(65)), uint8(uint8(196)), uint8(uint8(162)), uint8(uint8(16)), uint8(uint8(1)), uint8(uint8(17)), uint8(uint8(72)), uint8(0), uint8(uint8(10)), uint8(uint8(72)), uint8(uint8(136)), uint8(uint8(129)), uint8(uint8(145)), uint8(uint8(133)), uint8(uint8(45)), uint8(uint8(5)), uint8(uint8(158)), uint8(uint8(123)), uint8(uint8(120)), uint8(uint8(189)), uint8(uint8(36)), uint8(uint8(210)), uint8(uint8(215)), uint8(uint8(126)), uint8(uint8(150)), uint8(uint8(219)), uint8(uint8(87)), uint8(uint8(141)), uint8(uint8(82)), uint8(uint8(169)), uint8(uint8(112)), uint8(0), uint8(uint8(103)), uint8(uint8(23)), uint8(uint8(137)), uint8(uint8(122)), uint8(uint8(17)), uint8(uint8(76)), uint8(uint8(35)), uint8(uint8(35)), uint8(uint8(159)), uint8(uint8(252)), uint8(uint8(186)), uint8(uint8(195)), uint8(uint8(121)), uint8(uint8(254)), uint8(uint8(22)), uint8(uint8(47)), uint8(uint8(33)), uint8(uint8(76)), uint8(uint8(195)), uint8(uint8(47)), uint8(uint8(8)), uint8(uint8(214)), uint8(uint8(151)), uint8(uint8(69)), uint8(uint8(127)), uint8(uint8(253)), uint8(uint8(59)), uint8(uint8(249)), uint8(uint8(226)), uint8(uint8(95)), uint8(uint8(218)), uint8(uint8(95)), uint8(uint8(225)), uint8(uint8(142)), uint8(uint8(18)), uint8(uint8(81)), uint8(uint8(175)), uint8(uint8(4)), uint8(uint8(93)), uint8(uint8(26)), uint8(uint8(171)), uint8(uint8(137)), uint8(uint8(151)), uint8(uint8(4)), uint8(uint8(126)), uint8(uint8(79)), uint8(uint8(222)), uint8(uint8(1)), uint8(uint8(15)), uint8(uint8(151)), uint8(uint8(57)), uint8(uint8(234)), uint8(uint8(94)), uint8(uint8(127)), uint8(uint8(111)), uint8(uint8(52)), uint8(uint8(104)), uint8(uint8(206)), uint8(0), uint8(uint8(21)), uint8(uint8(232)), uint8(uint8(148)), uint8(uint8(220)), uint8(uint8(126)), uint8(uint8(87)), uint8(uint8(221)), uint8(uint8(26)), uint8(uint8(166)), uint8(uint8(141)), uint8(uint8(124)), uint8(uint8(231)), uint8(uint8(187)), uint8(uint8(246)), uint8(uint8(110)), uint8(uint8(50)), uint8(uint8(40)), uint8(uint8(251)), uint8(uint8(246)), uint8(uint8(244)), uint8(uint8(9)), uint8(uint8(90)), uint8(uint8(53)), uint8(uint8(238)), uint8(uint8(118)), uint8(uint8(83)), uint8(uint8(250)), uint8(uint8(94)), uint8(uint8(100)), uint8(uint8(207)), uint8(uint8(1)), uint8(uint8(56)), uint8(uint8(227)), uint8(uint8(230)), uint8(uint8(6)), uint8(uint8(220)), uint8(uint8(53)), uint8(uint8(248)), uint8(uint8(163)), uint8(uint8(131)), uint8(uint8(84)), uint8(uint8(195)), uint8(uint8(197)), uint8(uint8(104)), uint8(uint8(186)), uint8(uint8(187)), uint8(uint8(162)), uint8(uint8(76)), uint8(uint8(246)), uint8(uint8(56)), uint8(uint8(191)), uint8(uint8(168)), uint8(uint8(10)), uint8(uint8(220)), uint8(uint8(18)), uint8(uint8(72)), uint8(uint8(195)), uint8(uint8(169)), uint8(uint8(119)), uint8(uint8(221)), uint8(uint8(75)), uint8(uint8(188)), uint8(uint8(45)), uint8(uint8(226)), uint8(uint8(254)), uint8(uint8(66)), uint8(uint8(162)), uint8(uint8(120)), uint8(uint8(125)), uint8(uint8(45)), uint8(uint8(231)), uint8(uint8(6)), uint8(uint8(165)), uint8(uint8(223)), uint8(uint8(106)), uint8(uint8(93)), uint8(uint8(232)), uint8(uint8(201)), uint8(uint8(127)), uint8(uint8(3)), uint8(uint8(34)), uint8(uint8(98)), uint8(uint8(134)), uint8(uint8(203)), uint8(uint8(63)), uint8(uint8(231)), uint8(uint8(120)), uint8(uint8(84)), uint8(uint8(90)), uint8(uint8(137)), uint8(uint8(231)), uint8(uint8(131)), uint8(uint8(73)), uint8(uint8(50)), uint8(uint8(23)), uint8(uint8(11)), uint8(uint8(22)), uint8(uint8(64)), uint8(uint8(173)), uint8(uint8(8)), uint8(uint8(180)), uint8(uint8(31)), uint8(uint8(245)), uint8(uint8(132)), uint8(uint8(154)), uint8(uint8(195)), uint8(uint8(208)), uint8(uint8(236)), uint8(uint8(120)), uint8(uint8(88)), uint8(uint8(248)), uint8(uint8(233)), uint8(uint8(98)), uint8(uint8(186)), uint8(uint8(90)), uint8(uint8(69)), uint8(uint8(242)), uint8(uint8(125)), uint8(uint8(207)), uint8(uint8(208)), uint8(uint8(66)), uint8(uint8(18)), uint8(uint8(130)), uint8(uint8(243)), uint8(uint8(96)), uint8(uint8(245)), uint8(uint8(159)), uint8(uint8(15)), uint8(uint8(120)), uint8(uint8(113)), uint8(uint8(128)), uint8(uint8(184)), uint8(uint8(74)), uint8(uint8(83)), uint8(uint8(107)), uint8(uint8(188)), uint8(uint8(255)), uint8(uint8(137)), uint8(uint8(69)), uint8(uint8(46)), uint8(uint8(120)), uint8(uint8(9)), uint8(uint8(127)), uint8(uint8(165)), uint8(uint8(242)), uint8(uint8(248)), uint8(uint8(75)), uint8(uint8(139)), uint8(uint8(225)), uint8(uint8(83)), uint8(uint8(129)), uint8(uint8(8)), uint8(uint8(36)), uint8(uint8(77)), uint8(uint8(4)), uint8(uint8(145)), uint8(uint8(163)), uint8(uint8(58)), uint8(uint8(92)), uint8(uint8(207)), uint8(uint8(3)), uint8(uint8(7)), uint8(uint8(28)), uint8(uint8(133)), uint8(uint8(184)), uint8(uint8(149)), uint8(uint8(209)), uint8(uint8(96)), uint8(uint8(220)), uint8(uint8(215)), uint8(uint8(239)), uint8(uint8(36)), uint8(uint8(191)), uint8(uint8(143)), uint8(uint8(161)), uint8(uint8(61)), uint8(uint8(247)), uint8(uint8(245)), uint8(uint8(137)), uint8(uint8(8)), uint8(uint8(133)), uint8(uint8(120)), uint8(uint8(48)), uint8(uint8(68)), uint8(uint8(203)), uint8(uint8(151)), uint8(uint8(250)), uint8(uint8(8)), uint8(uint8(129)), uint8(uint8(222)), uint8(uint8(63)), uint8(uint8(192)), uint8(uint8(70)), uint8(uint8(90)), uint8(uint8(107)), uint8(uint8(188)), uint8(uint8(255)), uint8(uint8(203)), uint8(uint8(248)), uint8(uint8(156)), uint8(uint8(34)), uint8(uint8(23)), uint8(uint8(8)), uint8(uint8(135)), uint8(uint8(6)), uint8(uint8(64)), uint8(uint8(5)), uint8(uint8(249)), uint8(uint8(214)), uint8(uint8(195)), uint8(uint8(65)), uint8(uint8(183)), uint8(uint8(183)), uint8(uint8(104)), uint8(uint8(62)), uint8(uint8(108)), uint8(uint8(93)), uint8(uint8(81)), uint8(uint8(244)), uint8(uint8(92)), uint8(uint8(226)), uint8(uint8(161)), uint8(uint8(119)), uint8(uint8(248)), uint8(uint8(4)), uint8(uint8(167)), uint8(uint8(159)), uint8(uint8(15)), uint8(uint8(159)), uint8(uint8(192)), uint8(uint8(20)), uint8(uint8(21)), uint8(uint8(233)), uint8(uint8(49)), uint8(uint8(201)), uint8(uint8(132)), uint8(uint8(32)), uint8(uint8(140)), uint8(uint8(114)), uint8(uint8(43)), uint8(uint8(113)), uint8(uint8(51)), uint8(uint8(152)), uint8(uint8(227)), uint8(uint8(224)), uint8(uint8(142)), uint8(uint8(189)), uint8(uint8(159)), uint8(uint8(4)), uint8(uint8(139)), uint8(uint8(182)), uint8(uint8(123)), uint8(uint8(9)), uint8(uint8(97)), uint8(0), uint8(uint8(74)), uint8(uint8(112)), uint8(uint8(85)), uint8(uint8(92)), uint8(uint8(152)), uint8(uint8(247)), uint8(uint8(242)), uint8(uint8(97)), uint8(uint8(32)), uint8(uint8(116)), uint8(uint8(117)), uint8(uint8(112)), uint8(uint8(140)), uint8(uint8(32)), uint8(uint8(30)), uint8(uint8(224)), uint8(uint8(192)), uint8(uint8(89)), uint8(uint8(144)), uint8(uint8(120)), uint8(uint8(102)), uint8(uint8(101)), uint8(uint8(202)), uint8(uint8(129)), uint8(uint8(199)), uint8(uint8(30)), uint8(uint8(77)), uint8(uint8(206)), uint8(uint8(16)), uint8(uint8(81)), uint8(uint8(152)), uint8(uint8(52)), uint8(uint8(166)), uint8(uint8(7)), uint8(uint8(4)), uint8(uint8(98)), uint8(uint8(229)), uint8(uint8(252)), uint8(uint8(56)), uint8(uint8(227)), uint8(uint8(69)), uint8(uint8(128)), uint8(uint8(19)), uint8(uint8(190)), uint8(uint8(247)), uint8(uint8(63)), uint8(uint8(189)), uint8(uint8(82)), uint8(uint8(8)), uint8(uint8(3)), uint8(uint8(8)), uint8(uint8(32)), uint8(uint8(52)), uint8(uint8(185)), uint8(uint8(102)), uint8(uint8(170)), uint8(uint8(171)), uint8(uint8(123)), uint8(uint8(132)), uint8(uint8(32)), uint8(uint8(241)), uint8(uint8(129)), uint8(uint8(10)), uint8(uint8(213)), uint8(uint8(247)), uint8(uint8(32)), uint8(uint8(35)), uint8(uint8(181)), uint8(uint8(220)), uint8(uint8(60)), uint8(uint8(59)), uint8(uint8(105)), uint8(uint8(77)), uint8(uint8(221)), uint8(uint8(231)), uint8(uint8(250)), uint8(uint8(97)), uint8(uint8(8)), uint8(uint8(70)), uint8(uint8(190)), uint8(uint8(145)), uint8(uint8(224)), uint8(uint8(196)), uint8(uint8(35)), uint8(uint8(128)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(220)), uint8(uint8(65)), uint8(uint8(154)), uint8(uint8(84)), uint8(uint8(27)), uint8(uint8(252)), uint8(uint8(110)), uint8(uint8(164)), uint8(uint8(254)), uint8(uint8(50)), uint8(uint8(166)), uint8(uint8(14)), uint8(uint8(177)), uint8(uint8(185)), uint8(uint8(62)), uint8(uint8(197)), uint8(uint8(81)), uint8(uint8(75)), uint8(uint8(77)), uint8(uint8(234)), uint8(uint8(248)), uint8(uint8(59)), uint8(uint8(177)), uint8(uint8(50)), uint8(0), uint8(uint8(29)), uint8(uint8(203)), uint8(uint8(170)), uint8(uint8(92)), uint8(uint8(135)), uint8(uint8(192)), uint8(uint8(247)), uint8(uint8(167)), uint8(uint8(145)), uint8(uint8(133)), uint8(uint8(183)), uint8(uint8(111)), uint8(uint8(229)), uint8(uint8(19)), uint8(uint8(218)), uint8(uint8(220)), uint8(uint8(132)), uint8(uint8(191)), uint8(uint8(99)), uint8(uint8(130)), uint8(uint8(243)), uint8(uint8(211)), uint8(uint8(225)), uint8(uint8(141)), uint8(uint8(247)), uint8(uint8(155)), uint8(uint8(157)), uint8(uint8(239)), uint8(uint8(165)), uint8(uint8(65)), uint8(uint8(254)), uint8(uint8(11)), uint8(uint8(187)), uint8(uint8(218)), uint8(uint8(255)), uint8(uint8(13)), uint8(uint8(240)), uint8(uint8(223)), uint8(uint8(167)), uint8(uint8(147)), uint8(uint8(248)), uint8(uint8(79)), uint8(uint8(229)), uint8(uint8(250)), uint8(uint8(47)), uint8(uint8(226)), uint8(uint8(120)), uint8(uint8(92)), uint8(uint8(34)), uint8(uint8(28)), uint8(uint8(34)), uint8(uint8(128)), uint8(uint8(11)), uint8(uint8(243)), uint8(uint8(172)), uint8(uint8(195)), uint8(uint8(97)), uint8(uint8(181)), uint8(uint8(27)), uint8(uint8(176)), uint8(0), uint8(uint8(231)), uint8(uint8(70)), uint8(uint8(136)), uint8(uint8(106)), uint8(uint8(137)), uint8(uint8(171)), uint8(uint8(210)), uint8(uint8(77)), uint8(uint8(139)), uint8(uint8(170)), uint8(uint8(23)), uint8(uint8(69)), uint8(uint8(206)), uint8(uint8(1)), uint8(uint8(4)), uint8(uint8(203)), uint8(uint8(128)), uint8(uint8(38)), uint8(uint8(107)), uint8(uint8(209)), uint8(uint8(223)), uint8(uint8(215)), uint8(uint8(196)), uint8(uint8(96)), uint8(0), uint8(uint8(59)), uint8(uint8(255)), uint8(uint8(205)), uint8(uint8(55)), uint8(uint8(233)), uint8(uint8(210)), uint8(uint8(123)), uint8(uint8(136)), uint8(uint8(154)), uint8(uint8(244)), uint8(uint8(52)), uint8(uint8(152)), uint8(0), uint8(uint8(151)), uint8(uint8(77)), uint8(uint8(15)), uint8(uint8(53)), uint8(uint8(211)), uint8(uint8(189)), uint8(uint8(190)), uint8(uint8(252)), uint8(uint8(2)), uint8(uint8(90)), uint8(uint8(49)), uint8(uint8(87)), uint8(uint8(154)), uint8(uint8(162)), uint8(uint8(224)), uint8(uint8(255)), uint8(uint8(5)), uint8(uint8(158)), uint8(uint8(36)), uint8(0), uint8(uint8(71)), uint8(uint8(109)), uint8(uint8(14)), uint8(uint8(117)), uint8(uint8(189)), uint8(uint8(61)), uint8(uint8(254)), uint8(uint8(133)), uint8(uint8(43)), uint8(uint8(202)), uint8(uint8(185)), uint8(uint8(141)), uint8(uint8(184)), uint8(uint8(214)), uint8(uint8(254)), uint8(uint8(141)), uint8(uint8(123)), uint8(uint8(228)), uint8(uint8(239)), uint8(uint8(107)), uint8(uint8(4)), uint8(uint8(78)), uint8(uint8(89)), uint8(uint8(210)), uint8(uint8(8)), uint8(uint8(133)), uint8(uint8(142)), uint8(uint8(249)), uint8(uint8(154)), uint8(uint8(239)), uint8(uint8(248)), uint8(uint8(127)), uint8(uint8(135)), uint8(uint8(221)), uint8(uint8(127)), uint8(uint8(75)), uint8(uint8(22)), uint8(uint8(164)), uint8(uint8(11)), uint8(uint8(141)), uint8(uint8(252)), uint8(uint8(3)), uint8(uint8(16)), uint8(uint8(75)), uint8(uint8(29)), uint8(uint8(249)), uint8(uint8(21)), uint8(uint8(229)), uint8(uint8(210)), uint8(uint8(10)), uint8(uint8(179)), uint8(uint8(216)), uint8(uint8(27)), uint8(uint8(220)), uint8(uint8(255)), uint8(uint8(59)), uint8(uint8(169)), uint8(uint8(101)), uint8(uint8(146)), uint8(uint8(105)), uint8(uint8(47)), uint8(uint8(87)), uint8(uint8(22)), uint8(uint8(196)), uint8(uint8(123)), uint8(uint8(214)), uint8(uint8(230)), uint8(uint8(3)), uint8(uint8(150)), uint8(uint8(181)), uint8(uint8(32)), uint8(uint8(38)), uint8(uint8(158)), uint8(uint8(254)), uint8(uint8(244)), uint8(uint8(162)), uint8(uint8(112)), uint8(uint8(254)), uint8(uint8(235)), uint8(uint8(234)), uint8(uint8(186)), uint8(uint8(79)), uint8(uint8(220)), uint8(uint8(37)), uint8(uint8(225)), uint8(uint8(16)), uint8(uint8(168)), uint8(uint8(182)), uint8(uint8(115)), uint8(uint8(102)), uint8(uint8(15)), uint8(uint8(89)), uint8(uint8(131)), uint8(uint8(1)), uint8(uint8(70)), uint8(uint8(89)), uint8(uint8(210)), uint8(uint8(13)), uint8(uint8(151)), uint8(uint8(124)), uint8(uint8(103)), uint8(uint8(189)), uint8(uint8(98)), uint8(uint8(186)), uint8(uint8(47)), uint8(uint8(35)), uint8(uint8(175)), uint8(uint8(51)), uint8(uint8(10)), uint8(uint8(240)), uint8(uint8(233)), uint8(uint8(238)), uint8(uint8(60)), uint8(uint8(176)), uint8(uint8(29)), uint8(uint8(89)), uint8(uint8(80)), uint8(uint8(172)), uint8(uint8(140)), uint8(uint8(14)), uint8(uint8(116)), uint8(uint8(4)), uint8(uint8(191)), uint8(uint8(155)), uint8(uint8(13)), uint8(uint8(6)), uint8(uint8(27)), uint8(uint8(157)), uint8(uint8(126)), uint8(uint8(254)), uint8(uint8(4)), uint8(uint8(185)), uint8(uint8(215)), uint8(uint8(236)), uint8(uint8(84)), uint8(uint8(53)), uint8(uint8(35)), uint8(uint8(82)), uint8(uint8(252)), uint8(uint8(191)), uint8(uint8(229)), uint8(uint8(240)), uint8(uint8(69)), uint8(uint8(252)), uint8(uint8(42)), uint8(uint8(92)), uint8(uint8(4)), uint8(uint8(194)), uint8(uint8(70)), uint8(uint8(85)), uint8(uint8(106)), uint8(uint8(45)), uint8(uint8(89)), uint8(uint8(131)), uint8(uint8(73)), uint8(uint8(178)), uint8(uint8(127)), uint8(uint8(1)), uint8(uint8(102)), uint8(uint8(47)), uint8(uint8(144)), uint8(uint8(118)), uint8(uint8(62)), uint8(uint8(102)), uint8(uint8(175)), uint8(uint8(231)), uint8(uint8(196)), uint8(uint8(221)), uint8(uint8(216)), uint8(uint8(255)), uint8(uint8(175)), uint8(uint8(56)), uint8(uint8(68)), uint8(uint8(51)), uint8(uint8(47)), uint8(uint8(254)), uint8(uint8(71)), uint8(uint8(254)), uint8(uint8(1)), uint8(uint8(159)), uint8(uint8(63)), uint8(uint8(170)), uint8(uint8(28)), uint8(uint8(31)), uint8(uint8(232)), uint8(uint8(21)), uint8(uint8(18)), uint8(uint8(9)), uint8(uint8(195)), uint8(uint8(131)), uint8(uint8(32)), uint8(uint8(2)), uint8(uint8(39)), uint8(uint8(167)), uint8(uint8(169)), uint8(uint8(247)), uint8(uint8(191)), uint8(uint8(208)), uint8(uint8(68)), uint8(uint8(109)), uint8(uint8(180)), uint8(uint8(154)), uint8(uint8(220)), uint8(uint8(239)), uint8(uint8(190)), uint8(uint8(126)), uint8(uint8(234)), uint8(uint8(93)), uint8(uint8(242)), uint8(uint8(47)), uint8(uint8(143)), uint8(uint8(143)), uint8(uint8(62)), uint8(uint8(212)), uint8(uint8(187)), uint8(uint8(228)), uint8(uint8(38)), uint8(uint8(207)), uint8(uint8(143)), uint8(uint8(19)), uint8(uint8(194)), uint8(uint8(16)), uint8(uint8(184)), uint8(uint8(75)), uint8(uint8(207)), uint8(uint8(13)), uint8(uint8(24)), uint8(uint8(248)), uint8(uint8(248)), uint8(uint8(11)), uint8(0), uint8(uint8(151)), uint8(uint8(5)), uint8(uint8(106)), uint8(uint8(125)), uint8(uint8(237)), uint8(uint8(143)), uint8(uint8(189)), uint8(uint8(124)), uint8(uint8(190)), uint8(uint8(16)), uint8(uint8(234)), uint8(uint8(38)), uint8(uint8(21)), uint8(uint8(18)), uint8(uint8(170)), uint8(uint8(6)), uint8(uint8(221)), uint8(uint8(197)), uint8(uint8(105)), uint8(uint8(150)), uint8(uint8(15)), uint8(uint8(7)), uint8(uint8(132)), uint8(uint8(145)), uint8(uint8(55)), uint8(uint8(142)), uint8(uint8(132)), uint8(uint8(90)), uint8(uint8(110)), uint8(uint8(132)), uint8(uint8(167)), uint8(uint8(231)), uint8(uint8(67)), uint8(uint8(139)), uint8(uint8(5)), uint8(uint8(108)), uint8(uint8(158)), uint8(uint8(207)), uint8(uint8(172)), uint8(uint8(193)), uint8(uint8(8)), uint8(uint8(68)), uint8(uint8(18)), uint8(uint8(85)), uint8(uint8(116)), uint8(uint8(202)), uint8(uint8(95)), uint8(uint8(195)), uint8(uint8(88)), uint8(uint8(68)), uint8(uint8(176)), uint8(uint8(174)), uint8(uint8(29)), uint8(uint8(247)), uint8(uint8(203)), uint8(uint8(18)), uint8(uint8(197)), uint8(uint8(197)), uint8(uint8(136)), uint8(uint8(41)), uint8(uint8(199)), uint8(uint8(3)), uint8(uint8(179)), uint8(uint8(187)), uint8(uint8(103)), uint8(0), uint8(uint8(12)), uint8(uint8(94)), uint8(uint8(238)), uint8(uint8(211)), uint8(uint8(116)), uint8(uint8(33)), uint8(uint8(71)), uint8(uint8(162)), uint8(uint8(105)), uint8(uint8(90)), uint8(uint8(15)), uint8(uint8(180)), uint8(uint8(95)), uint8(uint8(4)), uint8(uint8(1)), uint8(uint8(144)), uint8(uint8(66)), uint8(uint8(17)), uint8(uint8(130)), uint8(uint8(104)), uint8(uint8(38)), uint8(uint8(71)), uint8(uint8(74)), uint8(uint8(151)), uint8(uint8(17)), uint8(uint8(208)), uint8(uint8(129)), uint8(uint8(193)), uint8(uint8(121)), uint8(uint8(108)), uint8(uint8(46)), uint8(uint8(220)), uint8(uint8(147)), uint8(uint8(183)), uint8(uint8(61)), uint8(uint8(64)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(159)), uint8(uint8(65)), uint8(uint8(154)), uint8(uint8(96)), uint8(uint8(223)), uint8(uint8(225)), uint8(uint8(254)), uint8(uint8(121)), uint8(uint8(75)), uint8(uint8(58)), uint8(uint8(220)), uint8(uint8(38)), uint8(uint8(255)), uint8(uint8(215)), uint8(uint8(6)), uint8(uint8(124)), uint8(0), uint8(uint8(78)), uint8(uint8(105)), uint8(uint8(121)), uint8(uint8(244)), uint8(uint8(96)), uint8(uint8(191)), uint8(uint8(235)), uint8(uint8(94)), uint8(uint8(142)), uint8(uint8(21)), uint8(uint8(111)), uint8(uint8(50)), uint8(uint8(240)), uint8(uint8(96)), uint8(uint8(64)), uint8(uint8(255)), uint8(uint8(206)), uint8(uint8(239)), uint8(uint8(102)), uint8(uint8(110)), uint8(uint8(151)), uint8(uint8(240)), uint8(uint8(222)), uint8(uint8(222)), uint8(uint8(124)), uint8(uint8(201)), uint8(uint8(80)), uint8(uint8(127)), uint8(uint8(227)), uint8(uint8(214)), uint8(uint8(183)), uint8(uint8(180)), uint8(uint8(190)), uint8(uint8(23)), uint8(uint8(39)), uint8(0), uint8(uint8(6)), uint8(uint8(156)), uint8(uint8(66)), uint8(uint8(93)), uint8(uint8(149)), uint8(uint8(115)), uint8(uint8(250)), uint8(uint8(72)), uint8(uint8(190)), uint8(uint8(98)), uint8(uint8(215)), uint8(uint8(95)), uint8(uint8(209)), uint8(uint8(185)), uint8(uint8(184)), uint8(uint8(92)), uint8(uint8(78)), uint8(0), uint8(uint8(113)), uint8(uint8(199)), uint8(uint8(165)), uint8(uint8(192)), uint8(uint8(205)), uint8(uint8(58)), uint8(uint8(225)), uint8(uint8(133)), uint8(uint8(128)), uint8(uint8(155)), uint8(uint8(124)), uint8(uint8(191)), uint8(uint8(23)), uint8(uint8(192)), uint8(uint8(204)), uint8(uint8(41)), uint8(uint8(98)), uint8(uint8(247)), uint8(uint8(101)), uint8(uint8(218)), uint8(uint8(183)), uint8(0), uint8(uint8(40)), uint8(uint8(205)), uint8(uint8(23)), uint8(uint8(99)), uint8(uint8(250)), uint8(uint8(254)), uint8(uint8(79)), uint8(uint8(91)), uint8(uint8(198)), uint8(uint8(215)), uint8(uint8(26)), uint8(uint8(76)), uint8(uint8(48)), uint8(uint8(3)), uint8(uint8(23)), uint8(uint8(239)), uint8(uint8(171)), uint8(uint8(238)), uint8(uint8(218)), uint8(uint8(189)), uint8(uint8(224)), uint8(uint8(105)), uint8(uint8(91)), uint8(uint8(47)), uint8(uint8(198)), uint8(uint8(252)), uint8(uint8(217)), uint8(uint8(35)), uint8(uint8(174)), uint8(uint8(188)), uint8(uint8(245)), uint8(uint8(160)), uint8(uint8(190)), uint8(uint8(237)), uint8(uint8(47)), uint8(uint8(27)), uint8(uint8(44)), uint8(uint8(159)), uint8(uint8(217)), uint8(uint8(67)), uint8(uint8(177)), uint8(uint8(106)), uint8(uint8(122)), uint8(uint8(190)), uint8(uint8(255)), uint8(uint8(154)), uint8(uint8(35)), uint8(uint8(230)), uint8(uint8(50)), uint8(uint8(189)), uint8(uint8(123)), uint8(uint8(103)), uint8(uint8(5)), uint8(uint8(48)), uint8(uint8(138)), uint8(uint8(251)), uint8(uint8(140)), uint8(uint8(214)), uint8(uint8(239)), uint8(uint8(131)), uint8(uint8(125)), uint8(uint8(128)), uint8(uint8(242)), uint8(uint8(179)), uint8(uint8(28)), uint8(uint8(31)), uint8(uint8(239)), uint8(uint8(136)), uint8(uint8(164)), uint8(uint8(33)), uint8(uint8(105)), uint8(uint8(117)), uint8(uint8(227)), uint8(uint8(247)), uint8(uint8(151)), uint8(uint8(202)), uint8(uint8(117)), uint8(uint8(172)), uint8(uint8(118)), uint8(uint8(183)), uint8(uint8(172)), uint8(uint8(13)), uint8(uint8(181)), uint8(uint8(99)), uint8(uint8(121)), uint8(uint8(52)), uint8(uint8(216)), uint8(uint8(9)), uint8(uint8(254)), uint8(uint8(111)), uint8(uint8(147)), uint8(uint8(242)), uint8(uint8(243)), uint8(uint8(220)), uint8(uint8(20)), uint8(uint8(141)), uint8(uint8(243)), uint8(uint8(3)), uint8(uint8(9)), uint8(uint8(244)), uint8(uint8(19)), uint8(uint8(123)), uint8(uint8(239)), uint8(uint8(201)), uint8(uint8(63)), uint8(uint8(124)), uint8(uint8(158)), uint8(uint8(17)), uint8(uint8(4)), uint8(uint8(34)), uint8(uint8(196)), uint8(uint8(122)), uint8(uint8(146)), uint8(uint8(114)), uint8(uint8(29)), uint8(uint8(89)), uint8(uint8(192)), uint8(uint8(118)), uint8(uint8(181)), uint8(uint8(242)), uint8(uint8(248)), uint8(uint8(46)), uint8(uint8(242)), uint8(uint8(225)), uint8(uint8(168)), uint8(uint8(158)), uint8(uint8(98)), uint8(uint8(56)), uint8(uint8(32)), uint8(uint8(61)), uint8(uint8(1)), uint8(uint8(250)), uint8(uint8(38)), uint8(uint8(129)), uint8(uint8(96)), uint8(uint8(244)), uint8(uint8(27)), uint8(uint8(151)), uint8(uint8(192)), uint8(uint8(192)), uint8(uint8(115)), uint8(uint8(133)), uint8(uint8(175)), uint8(uint8(151)), uint8(uint8(193)), uint8(uint8(135)), uint8(uint8(225)), uint8(uint8(16)), uint8(uint8(86)), uint8(uint8(47)), uint8(uint8(4)), uint8(uint8(109)), uint8(uint8(36)), uint8(uint8(189)), uint8(uint8(238)), uint8(uint8(247)), uint8(uint8(115)), uint8(uint8(43)), uint8(uint8(95)), uint8(uint8(133)), uint8(uint8(255)), uint8(uint8(146)), uint8(uint8(47)), uint8(uint8(181)), uint8(uint8(164)), uint8(uint8(255)), uint8(0), uint8(uint8(11)), uint8(uint8(231)), uint8(uint8(93)), uint8(uint8(223)), uint8(uint8(219)), uint8(uint8(131)), uint8(uint8(252)), uint8(uint8(159)), uint8(uint8(215)), uint8(uint8(227)), uint8(uint8(66)), uint8(uint8(33)), uint8(uint8(192)), uint8(uint8(132)), uint8(uint8(1)), uint8(uint8(10)), uint8(uint8(215)), uint8(uint8(61)), uint8(uint8(15)), uint8(uint8(237)), uint8(uint8(130)), uint8(uint8(150)), uint8(uint8(20)), uint8(uint8(46)), uint8(uint8(246)), uint8(uint8(10)), uint8(uint8(237)), uint8(uint8(253)), uint8(uint8(133)), uint8(uint8(171)), uint8(uint8(127)), uint8(uint8(224)), uint8(uint8(3)), uint8(uint8(32)), uint8(uint8(171)), uint8(uint8(231)), uint8(uint8(148)), uint8(uint8(63)), uint8(uint8(224)), uint8(uint8(1)), uint8(uint8(183)), uint8(uint8(167)), uint8(uint8(214)), uint8(uint8(72)), uint8(uint8(242)), uint8(uint8(159)), uint8(uint8(8)), uint8(uint8(118)), uint8(uint8(208)), uint8(uint8(32)), uint8(uint8(132)), uint8(uint8(73)), uint8(uint8(147)), uint8(uint8(215)), uint8(uint8(2)), uint8(uint8(135)), uint8(uint8(8)), uint8(uint8(240)), uint8(uint8(201)), uint8(uint8(143)), uint8(uint8(143)), uint8(uint8(128)), uint8(uint8(177)), uint8(uint8(22)), uint8(uint8(160)), uint8(uint8(118)), uint8(uint8(109)), uint8(uint8(121)), uint8(uint8(210)), uint8(uint8(141)), uint8(uint8(53)), uint8(uint8(242)), uint8(uint8(248)), uint8(uint8(91)), uint8(uint8(8)), uint8(uint8(112)), uint8(uint8(136)), uint8(uint8(100)), uint8(uint8(74)), uint8(uint8(168)), uint8(uint8(2)), uint8(uint8(22)), uint8(uint8(144)), uint8(uint8(34)), uint8(uint8(156)), uint8(uint8(106)), uint8(uint8(212)), uint8(uint8(210)), uint8(uint8(76)), uint8(uint8(52)), uint8(uint8(51)), uint8(uint8(230)), uint8(uint8(9)), uint8(uint8(109)), uint8(uint8(132)), uint8(uint8(183)), uint8(uint8(129)), uint8(uint8(41)), uint8(uint8(154)), uint8(uint8(200)), uint8(uint8(255)), uint8(uint8(83)), uint8(uint8(255)), uint8(uint8(128)), uint8(uint8(202)), uint8(uint8(99)), uint8(uint8(147)), uint8(uint8(43)), uint8(uint8(250)), uint8(uint8(223)), uint8(uint8(254)), uint8(uint8(179)), uint8(uint8(4)), uint8(uint8(20)), uint8(uint8(20)), uint8(uint8(107)), uint8(uint8(85)), uint8(uint8(93)), uint8(uint8(50)), uint8(uint8(172)), uint8(uint8(24)), uint8(uint8(112)), uint8(uint8(175)), uint8(uint8(54)), uint8(uint8(47)), uint8(uint8(224)), uint8(uint8(210)), uint8(uint8(76)), uint8(uint8(128)), uint8(uint8(192)), uint8(uint8(98)), uint8(uint8(1)), uint8(uint8(153)), uint8(uint8(129)), uint8(uint8(212)), uint8(uint8(57)), uint8(uint8(104)), uint8(uint8(251)), uint8(uint8(172)), uint8(uint8(95)), uint8(uint8(13)), uint8(uint8(139)), uint8(uint8(126)), uint8(uint8(164)), uint8(uint8(206)), uint8(uint8(191)), uint8(uint8(94)), uint8(uint8(17)), uint8(uint8(239)), uint8(uint8(253)), uint8(uint8(120)), uint8(uint8(67)), uint8(uint8(123)), uint8(uint8(162)), uint8(uint8(29)), uint8(uint8(48)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(135)), uint8(uint8(65)), uint8(uint8(154)), uint8(uint8(128)), uint8(uint8(223)), uint8(uint8(225)), uint8(uint8(254)), uint8(uint8(25)), uint8(uint8(123)), uint8(uint8(217)), uint8(uint8(77)), uint8(uint8(156)), uint8(uint8(9)), uint8(uint8(174)), uint8(uint8(217)), uint8(uint8(218)), uint8(uint8(87)), uint8(uint8(205)), uint8(uint8(9)), uint8(uint8(109)), uint8(uint8(52)), uint8(uint8(84)), uint8(uint8(7)), uint8(uint8(31)), uint8(uint8(20)), uint8(uint8(32)), uint8(uint8(2)), uint8(uint8(239)), uint8(uint8(249)), uint8(uint8(210)), uint8(uint8(12)), uint8(uint8(252)), uint8(uint8(107)), uint8(uint8(73)), uint8(uint8(159)), uint8(uint8(122)), uint8(uint8(56)), uint8(uint8(245)), uint8(uint8(183)), uint8(uint8(31)), uint8(uint8(248)), uint8(uint8(94)), uint8(uint8(31)), uint8(uint8(158)), uint8(uint8(177)), uint8(uint8(215)), uint8(uint8(8)), uint8(uint8(133)), uint8(uint8(250)), uint8(uint8(126)), uint8(uint8(223)), uint8(uint8(127)), uint8(uint8(4)), uint8(uint8(126)), uint8(uint8(251)), uint8(uint8(202)), uint8(uint8(215)), uint8(0), uint8(uint8(10)), uint8(uint8(252)), uint8(uint8(56)), uint8(uint8(72)), uint8(0), uint8(uint8(58)), uint8(uint8(99)), uint8(uint8(202)), uint8(uint8(196)), uint8(uint8(147)), uint8(uint8(185)), uint8(uint8(118)), uint8(uint8(189)), uint8(uint8(230)), uint8(uint8(154)), uint8(uint8(65)), uint8(uint8(36)), uint8(uint8(52)), uint8(uint8(149)), uint8(uint8(202)), uint8(uint8(63)), uint8(uint8(252)), uint8(uint8(6)), uint8(uint8(120)), uint8(uint8(4)), uint8(uint8(120)), uint8(0), uint8(uint8(215)), uint8(uint8(229)), uint8(uint8(87)), uint8(uint8(191)), uint8(uint8(62)), uint8(uint8(224)), uint8(uint8(7)), uint8(uint8(239)), uint8(uint8(114)), uint8(uint8(149)), uint8(uint8(235)), uint8(uint8(111)), uint8(uint8(13)), uint8(uint8(147)), uint8(uint8(93)), uint8(uint8(38)), uint8(uint8(156)), uint8(uint8(24)), uint8(uint8(88)), uint8(uint8(167)), uint8(uint8(95)), uint8(uint8(239)), uint8(uint8(128)), uint8(uint8(98)), uint8(uint8(165)), uint8(uint8(226)), uint8(uint8(150)), uint8(uint8(209)), uint8(uint8(95)), uint8(uint8(206)), uint8(uint8(124)), uint8(uint8(124)), uint8(uint8(172)), uint8(uint8(199)), uint8(uint8(7)), uint8(uint8(250)), uint8(uint8(248)), uint8(uint8(140)), uint8(uint8(174)), uint8(uint8(90)), uint8(uint8(212)), uint8(uint8(18)), uint8(uint8(209)), uint8(uint8(5)), uint8(uint8(77)), uint8(uint8(224)), uint8(uint8(230)), uint8(uint8(156)), uint8(uint8(96)), uint8(uint8(59)), uint8(uint8(209)), uint8(uint8(123)), uint8(uint8(111)), uint8(uint8(48)), uint8(uint8(62)), uint8(uint8(176)), uint8(uint8(85)), uint8(uint8(102)), uint8(uint8(178)), uint8(uint8(1)), uint8(uint8(76)), uint8(uint8(169)), uint8(uint8(237)), uint8(uint8(190)), uint8(uint8(190)), uint8(uint8(17)), uint8(uint8(12)), uint8(uint8(137)), uint8(uint8(103)), uint8(uint8(241)), uint8(uint8(122)), uint8(uint8(233)), uint8(uint8(252)), uint8(uint8(187)), uint8(uint8(79)), uint8(uint8(227)), uint8(uint8(184)), uint8(uint8(252)), uint8(uint8(190)), uint8(uint8(35)), uint8(uint8(160)), uint8(uint8(142)), uint8(uint8(27)), uint8(uint8(62)), uint8(uint8(95)), uint8(uint8(127)), uint8(uint8(234)), uint8(uint8(111)), uint8(uint8(47)), uint8(uint8(130)), uint8(uint8(239)), uint8(uint8(146)), uint8(uint8(21)), uint8(uint8(35)), uint8(uint8(87)), uint8(uint8(181)), uint8(uint8(17)), uint8(uint8(193)), uint8(uint8(60)), uint8(uint8(3)), uint8(uint8(12)), uint8(uint8(96)), uint8(uint8(114)), uint8(uint8(210)), uint8(uint8(96)), uint8(uint8(14)), uint8(uint8(142)), uint8(uint8(76)), uint8(uint8(164)), uint8(uint8(124)), uint8(uint8(191)), uint8(uint8(1)), uint8(uint8(164)), uint8(uint8(227)), uint8(uint8(120)), uint8(uint8(39)), uint8(uint8(203)), uint8(uint8(225)), uint8(uint8(14)), uint8(uint8(112)), uint8(uint8(140)), uint8(uint8(34)), uint8(uint8(81)), uint8(uint8(165)), uint8(uint8(199)), uint8(uint8(119)), uint8(uint8(175)), uint8(uint8(195)), uint8(uint8(38)), uint8(uint8(159)), uint8(uint8(254)), uint8(uint8(255)), uint8(0), uint8(uint8(33)), uint8(uint8(31)), uint8(uint8(239)), uint8(uint8(175)), uint8(uint8(251)), uint8(uint8(248)), uint8(uint8(127)), uint8(uint8(147)), uint8(uint8(211)), uint8(uint8(241)), uint8(uint8(60)), uint8(uint8(76)), uint8(uint8(56)), uint8(uint8(42)), uint8(0), uint8(uint8(100)), uint8(uint8(2)), uint8(uint8(191)), uint8(uint8(160)), uint8(uint8(47)), uint8(uint8(20)), uint8(uint8(238)), uint8(uint8(148)), uint8(uint8(62)), uint8(uint8(210)), uint8(uint8(99)), uint8(uint8(35)), uint8(uint8(129)), uint8(uint8(246)), uint8(uint8(195)), uint8(uint8(130)), uint8(uint8(101)), uint8(uint8(133)), uint8(uint8(61)), uint8(uint8(126)), uint8(0), uint8(uint8(31)), uint8(uint8(101)), uint8(uint8(177)), uint8(uint8(146)), uint8(uint8(217)), uint8(uint8(186)), uint8(uint8(127)), uint8(uint8(175)), uint8(uint8(192)), uint8(uint8(5)), uint8(uint8(231)), uint8(uint8(33)), uint8(uint8(22)), uint8(uint8(111)), uint8(uint8(226)), uint8(uint8(239)), uint8(uint8(170)), uint8(uint8(225)), uint8(0), uint8(uint8(134)), uint8(uint8(150)), uint8(uint8(225)), uint8(uint8(24)), uint8(uint8(84)), uint8(uint8(67)), uint8(uint8(190)), uint8(uint8(243)), uint8(uint8(224)), uint8(uint8(52)), uint8(uint8(134)), uint8(uint8(200)), uint8(uint8(36)), uint8(uint8(153)), uint8(uint8(5)), uint8(uint8(52)), uint8(uint8(99)), uint8(uint8(179)), uint8(uint8(64)), uint8(uint8(26)), uint8(uint8(156)), uint8(uint8(56)), uint8(uint8(200)), uint8(uint8(119)), uint8(uint8(251)), uint8(uint8(95)), uint8(uint8(154)), uint8(uint8(192)), uint8(uint8(13)), uint8(uint8(152)), uint8(uint8(177)), uint8(uint8(246)), uint8(uint8(79)), uint8(uint8(181)), uint8(uint8(250)), uint8(uint8(194)), uint8(uint8(1)), uint8(0), uint8(uint8(128)), uint8(uint8(68)), uint8(uint8(24)), uint8(uint8(9)), uint8(uint8(207)), uint8(uint8(225)), uint8(uint8(176)), uint8(uint8(81)), uint8(uint8(191)), uint8(uint8(144)), uint8(uint8(223)), uint8(uint8(255)), uint8(uint8(197)), uint8(uint8(47)), uint8(uint8(211)), uint8(uint8(173)), uint8(uint8(4)), uint8(uint8(20)), uint8(uint8(17)), uint8(uint8(241)), uint8(uint8(172)), uint8(uint8(73)), uint8(uint8(80)), uint8(uint8(218)), uint8(uint8(172)), uint8(uint8(24)), uint8(uint8(4)), uint8(uint8(18)), uint8(uint8(10)), uint8(uint8(241)), uint8(uint8(60)), uint8(uint8(95)), uint8(uint8(192)), uint8(uint8(225)), uint8(uint8(5)), uint8(uint8(57)), uint8(uint8(144)), uint8(uint8(129)), uint8(uint8(68)), uint8(uint8(16)), uint8(uint8(18)), uint8(uint8(144)), uint8(uint8(160)), uint8(uint8(210)), uint8(uint8(28)), uint8(uint8(185)), uint8(uint8(208)), uint8(uint8(185)), uint8(uint8(4)), uint8(uint8(127)), uint8(uint8(246)), uint8(uint8(190)), uint8(uint8(83)), uint8(uint8(5)), uint8(uint8(198)), uint8(uint8(35)), uint8(uint8(152)), uint8(uint8(38)), uint8(uint8(158)), uint8(uint8(72)), uint8(uint8(132)), uint8(uint8(55)), uint8(uint8(107)), uint8(uint8(245)), uint8(uint8(225)), uint8(uint8(29)), uint8(uint8(47)), uint8(uint8(250)), uint8(uint8(132)), uint8(uint8(54)), uint8(uint8(185)), uint8(uint8(100)), uint8(uint8(8)), uint8(uint8(132)), uint8(uint8(219)), uint8(uint8(205)), uint8(uint8(254)), uint8(uint8(218)), uint8(uint8(11)), uint8(uint8(29)), uint8(uint8(48)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(168)), uint8(uint8(65)), uint8(uint8(154)), uint8(uint8(160)), uint8(uint8(222)), uint8(uint8(171)), uint8(uint8(195)), uint8(uint8(16)), uint8(uint8(53)), uint8(uint8(109)), uint8(uint8(37)), uint8(uint8(19)), uint8(uint8(170)), uint8(uint8(6)), uint8(uint8(190)), uint8(uint8(224)), uint8(uint8(176)), uint8(uint8(152)), uint8(uint8(112)), uint8(uint8(128)), uint8(uint8(76)), uint8(uint8(217)), uint8(uint8(67)), uint8(uint8(70)), uint8(uint8(250)), uint8(uint8(4)), uint8(uint8(21)), uint8(uint8(89)), uint8(uint8(97)), uint8(uint8(19)), uint8(uint8(71)), uint8(uint8(48)), uint8(uint8(33)), uint8(uint8(181)), uint8(uint8(107)), uint8(uint8(192)), uint8(uint8(127)), uint8(uint8(57)), uint8(uint8(100)), uint8(uint8(219)), uint8(uint8(174)), uint8(uint8(122)), uint8(uint8(28)), uint8(uint8(78)), uint8(uint8(24)), uint8(uint8(33)), uint8(uint8(172)), uint8(uint8(196)), uint8(uint8(112)), uint8(uint8(254)), uint8(uint8(27)), uint8(uint8(243)), uint8(uint8(118)), uint8(uint8(112)), uint8(uint8(174)), uint8(uint8(191)), uint8(uint8(255)), uint8(uint8(193)), uint8(uint8(54)), uint8(uint8(71)), uint8(uint8(253)), uint8(uint8(110)), uint8(uint8(219)), uint8(uint8(120)), uint8(uint8(152)), uint8(uint8(96)), uint8(uint8(150)), uint8(uint8(231)), uint8(uint8(234)), uint8(0), uint8(uint8(29)), uint8(uint8(40)), uint8(uint8(140)), uint8(uint8(235)), uint8(uint8(234)), uint8(uint8(241)), uint8(uint8(112)), uint8(uint8(87)), uint8(uint8(127)), uint8(uint8(128)), uint8(uint8(36)), uint8(uint8(58)), uint8(uint8(172)), uint8(uint8(153)), uint8(uint8(63)), uint8(uint8(124)), uint8(uint8(189)), uint8(uint8(243)), uint8(uint8(165)), uint8(uint8(211)), uint8(uint8(59)), uint8(uint8(212)), uint8(uint8(192)), uint8(uint8(68)), uint8(uint8(195)), uint8(uint8(158)), uint8(0), uint8(uint8(1)), uint8(uint8(246)), uint8(uint8(155)), uint8(uint8(81)), uint8(uint8(162)), uint8(uint8(131)), uint8(uint8(221)), uint8(uint8(216)), uint8(uint8(30)), uint8(uint8(221)), uint8(uint8(192)), uint8(uint8(8)), uint8(uint8(107)), uint8(uint8(73)), uint8(uint8(211)), uint8(uint8(119)), uint8(uint8(239)), uint8(uint8(231)), uint8(uint8(182)), uint8(uint8(241)), uint8(uint8(81)), uint8(uint8(166)), uint8(uint8(1)), uint8(uint8(6)), uint8(uint8(146)), uint8(uint8(143)), uint8(uint8(7)), uint8(uint8(252)), uint8(0), uint8(uint8(115)), uint8(uint8(181)), uint8(uint8(29)), uint8(uint8(169)), uint8(uint8(102)), uint8(uint8(129)), uint8(uint8(176)), uint8(uint8(147)), uint8(uint8(235)), uint8(uint8(174)), uint8(uint8(250)), uint8(uint8(252)), uint8(uint8(8)), uint8(uint8(125)), uint8(uint8(182)), uint8(0), uint8(uint8(170)), uint8(uint8(35)), uint8(uint8(173)), uint8(uint8(175)), uint8(uint8(122)), uint8(uint8(254)), uint8(uint8(183)), uint8(uint8(52)), uint8(uint8(80)), uint8(uint8(237)), uint8(uint8(196)), uint8(uint8(113)), uint8(uint8(174)), uint8(uint8(183)), uint8(uint8(117)), uint8(uint8(83)), uint8(uint8(158)), uint8(uint8(153)), uint8(uint8(2)), uint8(uint8(204)), uint8(uint8(151)), uint8(uint8(251)), uint8(uint8(251)), uint8(uint8(33)), uint8(uint8(250)), uint8(uint8(70)), uint8(uint8(52)), uint8(uint8(69)), uint8(uint8(222)), uint8(uint8(176)), uint8(uint8(166)), uint8(uint8(50)), uint8(uint8(53)), uint8(uint8(129)), uint8(uint8(140)), uint8(uint8(197)), uint8(uint8(101)), uint8(uint8(160)), uint8(uint8(53)), uint8(uint8(92)), uint8(uint8(59)), uint8(uint8(87)), uint8(uint8(105)), uint8(uint8(58)), uint8(uint8(241)), uint8(uint8(233)), uint8(uint8(192)), uint8(uint8(1)), uint8(uint8(221)), uint8(uint8(223)), uint8(uint8(159)), uint8(uint8(189)), uint8(uint8(155)), uint8(uint8(13)), uint8(uint8(131)), uint8(uint8(86)), uint8(uint8(81)), uint8(uint8(68)), uint8(uint8(25)), uint8(uint8(40)), uint8(uint8(210)), uint8(uint8(168)), uint8(uint8(116)), uint8(uint8(92)), uint8(uint8(191)), uint8(uint8(136)), uint8(uint8(194)), uint8(uint8(40)), uint8(uint8(34)), uint8(uint8(9)), uint8(uint8(133)), uint8(uint8(206)), uint8(uint8(78)), uint8(uint8(178)), uint8(uint8(185)), uint8(uint8(226)), uint8(uint8(242)), uint8(uint8(188)), uint8(uint8(68)), uint8(uint8(42)), uint8(uint8(124)), uint8(uint8(75)), uint8(uint8(155)), uint8(uint8(191)), uint8(uint8(19)), uint8(uint8(175)), uint8(uint8(71)), uint8(uint8(31)), uint8(uint8(229)), uint8(uint8(240)), uint8(uint8(93)), uint8(uint8(241)), uint8(uint8(97)), uint8(uint8(16)), uint8(uint8(247)), uint8(uint8(49)), uint8(uint8(18)), uint8(uint8(199)), uint8(uint8(19)), uint8(uint8(197)), uint8(uint8(115)), uint8(uint8(17)), uint8(uint8(197)), uint8(uint8(104)), uint8(uint8(21)), uint8(uint8(66)), uint8(uint8(216)), uint8(uint8(17)), uint8(uint8(22)), uint8(uint8(78)), uint8(uint8(215)), uint8(uint8(224)), uint8(uint8(21)), uint8(uint8(180)), uint8(uint8(107)), uint8(uint8(163)), uint8(uint8(242)), uint8(uint8(255)), uint8(uint8(194)), uint8(uint8(48)), uint8(uint8(152)), uint8(uint8(43)), uint8(uint8(23)), uint8(uint8(203)), uint8(uint8(143)), uint8(uint8(110)), uint8(uint8(238)), uint8(uint8(231)), uint8(uint8(165)), uint8(uint8(182)), uint8(uint8(79)), uint8(uint8(174)), uint8(uint8(32)), uint8(uint8(78)), uint8(uint8(17)), uint8(uint8(116)), uint8(uint8(71)), uint8(uint8(221)), uint8(uint8(10)), uint8(uint8(184)), uint8(uint8(92)), uint8(uint8(33)), uint8(uint8(252)), uint8(0), uint8(uint8(41)), uint8(uint8(126)), uint8(uint8(83)), uint8(uint8(229)), uint8(uint8(233)), uint8(uint8(127)), uint8(uint8(253)), uint8(uint8(189)), uint8(uint8(81)), uint8(uint8(177)), uint8(uint8(43)), uint8(uint8(12)), uint8(uint8(67)), uint8(uint8(245)), uint8(uint8(240)), uint8(uint8(16)), uint8(uint8(66)), uint8(uint8(238)), uint8(uint8(208)), uint8(uint8(67)), uint8(uint8(122)), uint8(uint8(128)), uint8(uint8(116)), uint8(uint8(98)), uint8(uint8(53)), uint8(uint8(102)), uint8(uint8(191)), uint8(uint8(50)), uint8(uint8(35)), uint8(uint8(231)), uint8(uint8(255)), uint8(uint8(212)), uint8(uint8(2)), uint8(uint8(226)), uint8(uint8(181)), uint8(uint8(91)), uint8(uint8(244)), uint8(uint8(255)), uint8(uint8(190)), uint8(uint8(174)), uint8(uint8(16)), uint8(uint8(8)), uint8(uint8(104)), uint8(uint8(191)), uint8(uint8(133)), uint8(uint8(2)), uint8(uint8(1)), uint8(uint8(28)), uint8(uint8(34)), uint8(uint8(21)), uint8(uint8(17)), uint8(uint8(184)), uint8(uint8(45)), uint8(uint8(125)), uint8(uint8(138)), uint8(uint8(63)), uint8(uint8(72)), uint8(0), uint8(uint8(64)), uint8(uint8(238)), uint8(uint8(192)), uint8(uint8(8)), uint8(uint8(217)), uint8(uint8(190)), uint8(uint8(38)), uint8(uint8(223)), uint8(uint8(124)), uint8(uint8(12)), uint8(uint8(78)), uint8(uint8(186)), uint8(uint8(118)), uint8(uint8(135)), uint8(uint8(248)), uint8(0), uint8(uint8(200)), uint8(uint8(189)), uint8(uint8(41)), uint8(uint8(181)), uint8(uint8(126)), uint8(uint8(248)), uint8(uint8(25)), uint8(uint8(119)), uint8(uint8(109)), uint8(uint8(53)), uint8(uint8(143)), uint8(uint8(250)), uint8(uint8(208)), uint8(uint8(67)), uint8(uint8(5)), uint8(uint8(2)), uint8(uint8(220)), uint8(uint8(67)), uint8(uint8(157)), uint8(uint8(222)), uint8(uint8(218)), uint8(uint8(208)), uint8(uint8(64)), uint8(uint8(208)), uint8(uint8(74)), uint8(uint8(89)), uint8(uint8(51)), uint8(uint8(166)), uint8(uint8(211)), uint8(uint8(73)), uint8(uint8(21)), uint8(uint8(96)), uint8(uint8(186)), uint8(uint8(120)), uint8(uint8(100)), uint8(uint8(70)), uint8(uint8(108)), uint8(uint8(129)), uint8(uint8(181)), uint8(uint8(192)), uint8(uint8(149)), uint8(uint8(78)), uint8(uint8(176)), uint8(uint8(63)), uint8(uint8(255)), uint8(uint8(175)), uint8(uint8(8)), uint8(uint8(233)), uint8(uint8(127)), uint8(uint8(240)), uint8(uint8(65)), uint8(uint8(244)), uint8(uint8(32)), uint8(uint8(104)), uint8(uint8(118)), uint8(uint8(79)), uint8(uint8(216)), uint8(uint8(75)), uint8(uint8(140)), uint8(uint8(203)), uint8(uint8(255)), uint8(uint8(208)), uint8(uint8(225)), uint8(uint8(109)), uint8(uint8(128)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(179)), uint8(uint8(65)), uint8(uint8(154)), uint8(uint8(192)), uint8(uint8(223)), uint8(uint8(225)), uint8(uint8(184)), uint8(uint8(25)), uint8(uint8(111)), uint8(uint8(183)), uint8(uint8(250)), uint8(uint8(9)), uint8(uint8(134)), uint8(uint8(226)), uint8(uint8(65)), uint8(uint8(50)), uint8(uint8(204)), uint8(uint8(178)), uint8(uint8(7)), uint8(uint8(192)), uint8(uint8(44)), uint8(uint8(230)), uint8(uint8(221)), uint8(uint8(243)), uint8(uint8(9)), uint8(uint8(184)), uint8(uint8(200)), uint8(uint8(208)), uint8(uint8(106)), uint8(uint8(62)), uint8(uint8(27)), uint8(uint8(128)), uint8(uint8(155)), uint8(uint8(95)), uint8(uint8(30)), uint8(uint8(249)), uint8(uint8(107)), uint8(uint8(110)), uint8(uint8(216)), uint8(uint8(13)), uint8(uint8(112)), uint8(uint8(151)), uint8(uint8(181)), uint8(uint8(126)), uint8(uint8(180)), uint8(uint8(223)), uint8(uint8(145)), uint8(uint8(253)), uint8(uint8(31)), uint8(uint8(45)), uint8(uint8(186)), uint8(uint8(240)), uint8(uint8(65)), uint8(uint8(224)), uint8(0), uint8(uint8(203)), uint8(uint8(217)), uint8(uint8(17)), uint8(uint8(185)), uint8(uint8(54)), uint8(uint8(201)), uint8(uint8(19)), uint8(uint8(151)), uint8(uint8(147)), uint8(uint8(125)), uint8(uint8(236)), uint8(uint8(161)), uint8(uint8(169)), uint8(uint8(20)), uint8(uint8(67)), uint8(uint8(4)), uint8(uint8(63)), uint8(uint8(93)), uint8(uint8(184)), uint8(uint8(74)), uint8(uint8(38)), uint8(uint8(34)), uint8(uint8(134)), uint8(0), uint8(uint8(66)), uint8(uint8(247)), uint8(uint8(221)), uint8(uint8(110)), uint8(uint8(240)), uint8(uint8(236)), uint8(uint8(228)), uint8(uint8(136)), uint8(uint8(226)), uint8(uint8(46)), uint8(uint8(221)), uint8(uint8(219)), uint8(uint8(242)), uint8(uint8(26)), uint8(uint8(151)), uint8(uint8(72)), uint8(uint8(74)), uint8(uint8(92)), uint8(uint8(126)), uint8(uint8(3)), uint8(uint8(206)), uint8(uint8(155)), uint8(uint8(19)), uint8(uint8(221)), uint8(uint8(143)), uint8(uint8(122)), uint8(uint8(79)), uint8(uint8(164)), uint8(uint8(205)), uint8(uint8(23)), uint8(uint8(241)), uint8(uint8(162)), uint8(uint8(58)), uint8(uint8(95)), uint8(uint8(22)), uint8(uint8(141)), uint8(uint8(27)), uint8(uint8(127)), uint8(uint8(95)), uint8(uint8(104)), uint8(uint8(51)), uint8(uint8(229)), uint8(uint8(55)), uint8(uint8(203)), uint8(uint8(25)), uint8(uint8(133)), uint8(uint8(189)), uint8(uint8(104)), uint8(uint8(238)), uint8(uint8(139)), uint8(uint8(210)), uint8(uint8(238)), uint8(uint8(90)), uint8(uint8(11)), uint8(uint8(59)), uint8(uint8(151)), uint8(uint8(75)), uint8(uint8(121)), uint8(uint8(155)), uint8(uint8(97)), uint8(uint8(233)), uint8(uint8(134)), uint8(uint8(35)), uint8(uint8(223)), uint8(uint8(239)), uint8(uint8(4)), uint8(uint8(51)), uint8(uint8(35)), uint8(uint8(172)), uint8(uint8(21)), uint8(uint8(52)), uint8(uint8(109)), uint8(uint8(172)), uint8(uint8(217)), uint8(uint8(104)), uint8(uint8(50)), uint8(uint8(55)), uint8(uint8(195)), uint8(uint8(177)), uint8(uint8(187)), uint8(uint8(224)), uint8(uint8(223)), uint8(uint8(128)), uint8(uint8(113)), uint8(uint8(29)), uint8(uint8(206)), uint8(uint8(15)), uint8(uint8(247)), uint8(uint8(196)), uint8(uint8(180)), uint8(uint8(34)), uint8(uint8(144)), uint8(uint8(104)), uint8(uint8(64)), uint8(uint8(154)), uint8(uint8(54)), uint8(uint8(144)), uint8(uint8(211)), uint8(uint8(37)), uint8(uint8(111)), uint8(uint8(192)), uint8(uint8(107)), uint8(uint8(62)), uint8(uint8(19)), uint8(uint8(91)), uint8(uint8(238)), uint8(uint8(203)), uint8(uint8(178)), uint8(uint8(233)), uint8(uint8(217)), uint8(uint8(96)), uint8(uint8(54)), uint8(uint8(108)), uint8(uint8(91)), uint8(uint8(169)), uint8(uint8(23)), uint8(uint8(172)), uint8(uint8(127)), uint8(uint8(202)), uint8(uint8(174)), uint8(uint8(152)), uint8(uint8(111)), uint8(uint8(180)), uint8(uint8(222)), uint8(uint8(250)), uint8(uint8(190)), uint8(uint8(17)), uint8(uint8(26)), uint8(uint8(37)), uint8(uint8(98)), uint8(uint8(14)), uint8(uint8(86)), uint8(uint8(32)), uint8(uint8(144)), uint8(uint8(30)), uint8(uint8(211)), uint8(uint8(224)), uint8(uint8(240)), uint8(uint8(221)), uint8(uint8(151)), uint8(uint8(147)), uint8(uint8(80)), uint8(uint8(78)), uint8(uint8(146)), uint8(uint8(212)), uint8(uint8(156)), uint8(uint8(37)), uint8(uint8(59)), uint8(uint8(210)), uint8(uint8(2)), uint8(uint8(187)), uint8(uint8(175)), uint8(uint8(246)), uint8(uint8(66)), uint8(uint8(227)), uint8(uint8(97)), uint8(uint8(247)), uint8(uint8(151)), uint8(uint8(94)), uint8(uint8(188)), uint8(uint8(66)), uint8(uint8(12)), uint8(uint8(149)), uint8(uint8(4)), uint8(uint8(125)), uint8(uint8(233)), uint8(uint8(93)), uint8(uint8(192)), uint8(uint8(218)), uint8(uint8(58)), uint8(uint8(220)), uint8(uint8(105)), uint8(uint8(84)), uint8(uint8(162)), uint8(uint8(142)), uint8(uint8(126)), uint8(uint8(130)), uint8(uint8(90)), uint8(uint8(87)), uint8(uint8(229)), uint8(uint8(240)), uint8(uint8(109)), uint8(uint8(229)), uint8(uint8(18)), uint8(uint8(17)), uint8(uint8(13)), uint8(uint8(231)), uint8(uint8(143)), uint8(uint8(220)), uint8(uint8(17)), uint8(uint8(251)), uint8(uint8(219)), uint8(uint8(194)), uint8(uint8(47)), uint8(uint8(15)), uint8(uint8(125)), uint8(uint8(126)), uint8(uint8(81)), uint8(uint8(239)), uint8(uint8(119)), uint8(uint8(248)), uint8(uint8(100)), uint8(uint8(68)), uint8(uint8(30)), uint8(uint8(253)), uint8(uint8(208)), uint8(0), uint8(uint8(255)), uint8(uint8(129)), uint8(uint8(9)), uint8(uint8(201)), uint8(uint8(163)), uint8(uint8(70)), uint8(uint8(120)), uint8(uint8(63)), uint8(uint8(201)), uint8(uint8(233)), uint8(uint8(248)), uint8(uint8(159)), uint8(uint8(97)), uint8(uint8(192)), uint8(uint8(132)), uint8(0), uint8(uint8(217)), uint8(uint8(44)), uint8(uint8(237)), uint8(uint8(43)), uint8(uint8(165)), uint8(uint8(111)), uint8(uint8(16)), uint8(uint8(68)), uint8(uint8(99)), uint8(uint8(85)), uint8(uint8(32)), uint8(uint8(17)), uint8(0), uint8(uint8(255)), uint8(uint8(240)), uint8(uint8(2)), uint8(uint8(105)), uint8(uint8(249)), uint8(uint8(165)), uint8(uint8(95)), uint8(uint8(158)), uint8(uint8(255)), uint8(uint8(128)), uint8(uint8(18)), uint8(uint8(181)), uint8(uint8(17)), uint8(uint8(207)), uint8(uint8(255)), uint8(uint8(42)), uint8(uint8(225)), uint8(0), uint8(uint8(132)), uint8(uint8(152)), uint8(uint8(119)), uint8(uint8(223)), uint8(uint8(137)), uint8(uint8(32)), uint8(uint8(100)), uint8(uint8(172)), uint8(uint8(197)), uint8(uint8(248)), uint8(uint8(1)), uint8(uint8(240)), uint8(uint8(193)), uint8(uint8(128)), uint8(uint8(255)), uint8(uint8(47)), uint8(uint8(129)), uint8(uint8(4)), uint8(uint8(140)), uint8(uint8(32)), uint8(uint8(62)), uint8(uint8(16)), uint8(uint8(8)), uint8(uint8(134)), uint8(uint8(77)), uint8(uint8(169)), uint8(uint8(176)), uint8(uint8(41)), uint8(uint8(17)), uint8(uint8(112)), uint8(uint8(180)), uint8(uint8(222)), uint8(uint8(31)), uint8(uint8(253)), uint8(uint8(100)), uint8(uint8(8)), uint8(uint8(96)), uint8(uint8(160)), uint8(uint8(162)), uint8(uint8(183)), uint8(uint8(119)), uint8(uint8(63)), uint8(uint8(63)), uint8(uint8(45)), uint8(uint8(191)), uint8(uint8(154)), uint8(uint8(101)), uint8(uint8(47)), uint8(uint8(142)), uint8(uint8(230)), uint8(uint8(225)), uint8(uint8(146)), uint8(uint8(147)), uint8(uint8(21)), uint8(uint8(223)), uint8(uint8(47)), uint8(uint8(133)), uint8(uint8(47)), uint8(uint8(87)), uint8(uint8(30)), uint8(uint8(245)), uint8(uint8(131)), uint8(uint8(9)), uint8(uint8(194)), uint8(uint8(40)), uint8(uint8(197)), uint8(uint8(77)), uint8(uint8(120)), uint8(uint8(71)), uint8(uint8(75)), uint8(uint8(254)), uint8(uint8(240)), uint8(uint8(208)), uint8(uint8(118)), uint8(uint8(3)), uint8(uint8(169)), uint8(uint8(174)), uint8(uint8(237)), uint8(uint8(248)), uint8(0), uint8(uint8(135)), uint8(uint8(238)), uint8(uint8(231)), uint8(uint8(89)), uint8(uint8(249)), uint8(uint8(124)), uint8(uint8(225)), uint8(uint8(19)), uint8(uint8(125)), uint8(uint8(4)), uint8(uint8(146)), uint8(uint8(42)), uint8(uint8(198)), uint8(uint8(112)), uint8(uint8(208)), uint8(uint8(169)), uint8(uint8(188)), uint8(uint8(222)), uint8(uint8(181)), uint8(uint8(135)), uint8(uint8(240)), uint8(uint8(15)), uint8(uint8(128)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(30)), uint8(uint8(65)), uint8(uint8(154)), uint8(uint8(224)), uint8(uint8(71)), uint8(uint8(248)), uint8(uint8(111)), uint8(uint8(128)), uint8(uint8(160)), uint8(uint8(189)), uint8(uint8(170)), uint8(uint8(74)), uint8(uint8(114)), uint8(uint8(155)), uint8(uint8(156)), uint8(uint8(116)), uint8(uint8(57)), uint8(uint8(14)), uint8(uint8(55)), uint8(uint8(252)), uint8(uint8(55)), uint8(uint8(88)), uint8(uint8(113)), uint8(uint8(237)), uint8(uint8(112)), uint8(uint8(32)), uint8(uint8(255)), uint8(uint8(110)), uint8(uint8(231)), uint8(uint8(255)), uint8(uint8(4)), uint8(uint8(111)), uint8(uint8(143)), uint8(uint8(59)), uint8(uint8(144)), uint8(uint8(159)), uint8(uint8(118)), uint8(uint8(34)), uint8(uint8(39)), uint8(uint8(225)), uint8(uint8(99)), uint8(uint8(96)), uint8(uint8(1)), uint8(uint8(118)), uint8(uint8(251)), uint8(uint8(171)), uint8(uint8(254)), uint8(uint8(254)), uint8(uint8(239)), uint8(uint8(240)), uint8(uint8(1)), uint8(uint8(127)), uint8(uint8(25)), uint8(uint8(20)), uint8(uint8(125)), uint8(uint8(251)), uint8(uint8(122)), uint8(uint8(6)), uint8(uint8(164)), uint8(uint8(107)), uint8(uint8(220)), uint8(uint8(236)), uint8(uint8(171)), uint8(uint8(238)), uint8(uint8(142)), uint8(uint8(174)), uint8(uint8(18)), uint8(uint8(61)), uint8(uint8(119)), uint8(uint8(172)), uint8(uint8(243)), uint8(uint8(9)), uint8(uint8(96)), uint8(uint8(140)), uint8(uint8(250)), uint8(uint8(254)), uint8(uint8(79)), uint8(uint8(47)), uint8(uint8(227)), uint8(uint8(176)), uint8(uint8(138)), uint8(uint8(133)), uint8(uint8(68)), uint8(uint8(233)), uint8(uint8(249)), uint8(uint8(193)), uint8(uint8(160)), uint8(uint8(74)), uint8(uint8(203)), uint8(uint8(130)), uint8(uint8(150)), uint8(uint8(10)), uint8(uint8(93)), uint8(uint8(128)), uint8(uint8(228)), uint8(uint8(232)), uint8(uint8(198)), uint8(uint8(189)), uint8(uint8(243)), uint8(uint8(124)), uint8(uint8(239)), uint8(uint8(8)), uint8(uint8(42)), uint8(uint8(199)), uint8(uint8(86)), uint8(uint8(117)), uint8(uint8(255)), uint8(uint8(12)), uint8(uint8(209)), uint8(uint8(148)), uint8(uint8(14)), uint8(uint8(149)), uint8(uint8(238)), uint8(uint8(22)), uint8(uint8(73)), uint8(uint8(219)), uint8(uint8(246)), uint8(uint8(222)), uint8(uint8(245)), uint8(uint8(145)), uint8(uint8(31)), uint8(uint8(243)), uint8(uint8(59)), uint8(uint8(212)), uint8(uint8(181)), uint8(uint8(255)), uint8(uint8(151)), uint8(uint8(253)), uint8(uint8(132)), uint8(uint8(225)), uint8(uint8(16)), uint8(uint8(80)), uint8(uint8(115)), uint8(uint8(17)), uint8(uint8(93)), uint8(uint8(109)), uint8(uint8(107)), uint8(uint8(95)), uint8(uint8(130)), uint8(0), uint8(uint8(138)), uint8(uint8(61)), uint8(uint8(203)), uint8(uint8(232)), uint8(uint8(174)), uint8(uint8(250)), uint8(uint8(59)), uint8(uint8(252)), uint8(uint8(103)), uint8(uint8(180)), uint8(uint8(79)), uint8(uint8(107)), uint8(uint8(252)), uint8(uint8(34)), uint8(uint8(8)), uint8(uint8(122)), uint8(uint8(195)), uint8(uint8(65)), uint8(uint8(192)), uint8(uint8(105)), uint8(uint8(38)), uint8(uint8(72)), uint8(uint8(64)), uint8(uint8(247)), uint8(uint8(192)), uint8(uint8(2)), uint8(uint8(98)), uint8(uint8(93)), uint8(uint8(240)), uint8(uint8(84)), uint8(uint8(97)), uint8(uint8(254)), uint8(uint8(72)), uint8(uint8(100)), uint8(uint8(167)), uint8(uint8(243)), uint8(uint8(83)), uint8(uint8(137)), uint8(uint8(23)), uint8(uint8(173)), uint8(uint8(107)), uint8(uint8(62)), uint8(uint8(95)), uint8(uint8(132)), uint8(uint8(5)), uint8(uint8(4)), uint8(uint8(6)), uint8(uint8(20)), uint8(uint8(88)), uint8(uint8(68)), uint8(uint8(54)), uint8(uint8(104)), uint8(uint8(6)), uint8(uint8(188)), uint8(uint8(140)), uint8(uint8(46)), uint8(uint8(101)), uint8(uint8(184)), uint8(0), uint8(uint8(115)), uint8(uint8(180)), uint8(uint8(213)), uint8(uint8(223)), uint8(uint8(110)), uint8(uint8(252)), uint8(0), uint8(uint8(100)), uint8(uint8(178)), uint8(uint8(220)), uint8(uint8(209)), uint8(uint8(45)), uint8(uint8(255)), uint8(uint8(187)), uint8(uint8(151)), uint8(uint8(197)), uint8(uint8(4)), uint8(uint8(56)), uint8(uint8(68)), uint8(uint8(208)), uint8(uint8(70)), uint8(uint8(113)), uint8(uint8(88)), uint8(uint8(172)), uint8(uint8(119)), uint8(uint8(5)), uint8(uint8(188)), uint8(uint8(128)), uint8(uint8(198)), uint8(uint8(95)), uint8(uint8(21)), uint8(uint8(127)), uint8(uint8(10)), uint8(uint8(205)), uint8(uint8(154)), uint8(uint8(90)), uint8(uint8(170)), uint8(uint8(69)), uint8(uint8(227)), uint8(uint8(173)), uint8(uint8(87)), uint8(uint8(119)), uint8(uint8(215)), uint8(uint8(156)), uint8(uint8(34)), uint8(uint8(9)), uint8(uint8(13)), uint8(uint8(195)), uint8(uint8(126)), uint8(uint8(139)), uint8(uint8(175)), uint8(uint8(175)), uint8(uint8(175)), uint8(uint8(107)), uint8(uint8(156)), uint8(uint8(34)), uint8(uint8(26)), uint8(uint8(9)), uint8(uint8(159)), uint8(uint8(13)), uint8(uint8(244)), uint8(uint8(5)), uint8(uint8(192)), uint8(uint8(143)), uint8(uint8(85)), uint8(uint8(95)), uint8(uint8(136)), uint8(uint8(239)), uint8(uint8(240)), uint8(uint8(168)), uint8(uint8(133)), uint8(uint8(90)), uint8(uint8(75)), uint8(uint8(89)), uint8(uint8(208)), uint8(uint8(148)), uint8(uint8(191)), uint8(uint8(142)), uint8(uint8(172)), uint8(uint8(255)), uint8(uint8(130)), uint8(uint8(113)), uint8(uint8(78)), uint8(uint8(239)), uint8(uint8(89)), uint8(uint8(190)), uint8(uint8(59)), uint8(uint8(152)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(196)), uint8(uint8(65)), uint8(uint8(155)), uint8(0), uint8(uint8(71)), uint8(uint8(248)), uint8(uint8(111)), uint8(uint8(128)), uint8(uint8(180)), uint8(uint8(153)), uint8(uint8(213)), uint8(uint8(98)), uint8(uint8(198)), uint8(uint8(101)), uint8(uint8(141)), uint8(uint8(96)), uint8(uint8(5)), uint8(uint8(29)), uint8(uint8(127)), uint8(uint8(39)), uint8(uint8(195)), uint8(uint8(214)), uint8(uint8(27)), uint8(uint8(248)), uint8(uint8(201)), uint8(uint8(195)), uint8(uint8(96)), uint8(uint8(248)), uint8(uint8(111)), uint8(uint8(134)), uint8(uint8(60)), uint8(uint8(133)), uint8(uint8(229)), uint8(uint8(204)), uint8(uint8(162)), uint8(uint8(154)), uint8(uint8(77)), uint8(uint8(15)), uint8(uint8(157)), uint8(uint8(248)), uint8(uint8(12)), uint8(uint8(70)), uint8(uint8(229)), uint8(uint8(249)), uint8(uint8(236)), uint8(uint8(191)), uint8(uint8(139)), uint8(uint8(248)), uint8(uint8(92)), uint8(uint8(156)), uint8(0), uint8(uint8(62)), uint8(uint8(91)), uint8(uint8(250)), uint8(uint8(186)), uint8(uint8(223)), uint8(uint8(187)), uint8(uint8(232)), uint8(uint8(198)), uint8(uint8(115)), uint8(uint8(33)), uint8(uint8(162)), uint8(uint8(118)), uint8(uint8(173)), uint8(uint8(232)), uint8(uint8(136)), uint8(uint8(67)), uint8(uint8(86)), uint8(uint8(160)), uint8(uint8(17)), uint8(uint8(10)), uint8(uint8(218)), uint8(uint8(224)), uint8(uint8(7)), uint8(uint8(151)), uint8(uint8(237)), uint8(uint8(42)), uint8(uint8(170)), uint8(uint8(220)), uint8(0), uint8(uint8(160)), uint8(uint8(170)), uint8(uint8(139)), uint8(uint8(155)), uint8(uint8(87)), uint8(uint8(242)), uint8(uint8(122)), uint8(uint8(118)), uint8(uint8(42)), uint8(uint8(187)), uint8(uint8(141)), uint8(uint8(38)), uint8(uint8(30)), uint8(uint8(89)), uint8(uint8(233)), uint8(uint8(38)), uint8(uint8(109)), uint8(uint8(77)), uint8(uint8(248)), uint8(uint8(33)), uint8(uint8(252)), uint8(uint8(254)), uint8(uint8(170)), uint8(uint8(7)), uint8(0), uint8(uint8(16)), uint8(uint8(107)), uint8(uint8(235)), uint8(uint8(245)), uint8(uint8(115)), uint8(uint8(254)), uint8(uint8(227)), uint8(uint8(83)), uint8(uint8(70)), uint8(uint8(14)), uint8(uint8(186)), uint8(uint8(251)), uint8(uint8(251)), uint8(uint8(240)), uint8(uint8(70)), uint8(uint8(41)), uint8(uint8(10)), uint8(uint8(163)), uint8(uint8(221)), uint8(uint8(215)), uint8(uint8(213)), uint8(uint8(123)), uint8(uint8(150)), uint8(uint8(127)), uint8(uint8(2)), uint8(uint8(154)), uint8(uint8(30)), uint8(uint8(156)), uint8(uint8(253)), uint8(uint8(24)), uint8(0), uint8(uint8(215)), uint8(uint8(252)), uint8(uint8(85)), uint8(uint8(228)), uint8(uint8(254)), uint8(uint8(176)), uint8(uint8(65)), uint8(uint8(133)), uint8(uint8(68)), uint8(uint8(67)), uint8(uint8(162)), uint8(uint8(118)), uint8(uint8(208)), uint8(uint8(49)), uint8(uint8(156)), uint8(uint8(140)), uint8(uint8(255)), uint8(uint8(128)), uint8(uint8(246)), uint8(uint8(190)), uint8(uint8(103)), uint8(uint8(86)), uint8(uint8(121)), uint8(uint8(11)), uint8(uint8(204)), uint8(uint8(14)), uint8(uint8(90)), uint8(uint8(140)), uint8(uint8(49)), uint8(uint8(149)), uint8(uint8(175)), uint8(uint8(26)), uint8(uint8(151)), uint8(uint8(142)), uint8(uint8(255)), uint8(uint8(215)), uint8(uint8(210)), uint8(uint8(205)), uint8(uint8(175)), uint8(uint8(147)), uint8(uint8(245)), uint8(uint8(8)), uint8(uint8(255)), uint8(uint8(12)), uint8(uint8(252)), uint8(uint8(160)), uint8(uint8(134)), uint8(uint8(201)), uint8(uint8(56)), uint8(uint8(60)), uint8(uint8(21)), uint8(uint8(36)), uint8(uint8(197)), uint8(uint8(69)), uint8(uint8(106)), uint8(uint8(249)), uint8(uint8(95)), uint8(uint8(175)), uint8(uint8(249)), uint8(uint8(235)), uint8(uint8(71)), uint8(uint8(235)), uint8(uint8(225)), uint8(uint8(16)), uint8(uint8(192)), uint8(uint8(209)), uint8(uint8(165)), uint8(uint8(158)), uint8(uint8(179)), uint8(uint8(17)), uint8(uint8(39)), uint8(uint8(108)), uint8(uint8(165)), uint8(uint8(129)), uint8(uint8(23)), uint8(uint8(207)), uint8(uint8(172)), uint8(uint8(178)), uint8(uint8(184)), uint8(uint8(143)), uint8(uint8(175)), uint8(uint8(198)), uint8(uint8(135)), uint8(uint8(67)), uint8(uint8(197)), uint8(uint8(202)), uint8(uint8(113)), uint8(uint8(177)), uint8(uint8(91)), uint8(uint8(169)), uint8(uint8(67)), uint8(uint8(41)), uint8(uint8(144)), uint8(uint8(156)), uint8(uint8(207)), uint8(uint8(106)), uint8(uint8(45)), uint8(uint8(127)), uint8(uint8(92)), uint8(uint8(173)), uint8(uint8(2)), uint8(uint8(207)), uint8(uint8(24)), uint8(uint8(30)), uint8(uint8(15)), uint8(uint8(236)), uint8(uint8(57)), uint8(uint8(38)), uint8(uint8(87)), uint8(uint8(127)), uint8(uint8(27)), uint8(uint8(249)), uint8(uint8(38)), uint8(uint8(64)), uint8(uint8(156)), uint8(uint8(62)), uint8(uint8(99)), uint8(uint8(154)), uint8(uint8(104)), uint8(uint8(75)), uint8(uint8(30)), uint8(uint8(47)), uint8(uint8(58)), uint8(uint8(240)), uint8(uint8(248)), uint8(uint8(134)), uint8(uint8(203)), uint8(uint8(36)), uint8(uint8(5)), uint8(uint8(93)), uint8(uint8(226)), uint8(uint8(58)), uint8(uint8(185)), uint8(uint8(172)), uint8(uint8(50)), uint8(uint8(30)), uint8(uint8(75)), uint8(uint8(239)), uint8(uint8(253)), uint8(0), uint8(uint8(193)), uint8(uint8(234)), uint8(uint8(127)), uint8(uint8(236)), uint8(uint8(15)), uint8(uint8(255)), uint8(uint8(244)), uint8(uint8(144)), uint8(uint8(142)), uint8(uint8(28)), uint8(uint8(25)), uint8(0), uint8(uint8(11)), uint8(uint8(233)), uint8(uint8(154)), uint8(uint8(190)), uint8(uint8(166)), uint8(uint8(219)), uint8(uint8(235)), uint8(uint8(90)), uint8(uint8(46)), uint8(uint8(171)), uint8(uint8(67)), uint8(uint8(217)), uint8(uint8(41)), uint8(uint8(136)), uint8(uint8(93)), uint8(uint8(81)), uint8(uint8(67)), uint8(uint8(110)), uint8(uint8(171)), uint8(uint8(133)), uint8(uint8(2)), uint8(uint8(48)), uint8(uint8(175)), uint8(uint8(6)), uint8(uint8(211)), uint8(uint8(46)), uint8(uint8(80)), uint8(uint8(73)), uint8(uint8(146)), uint8(uint8(99)), uint8(uint8(218)), uint8(uint8(95)), uint8(uint8(29)), uint8(0), uint8(uint8(67)), uint8(uint8(241)), uint8(uint8(191)), uint8(uint8(159)), uint8(uint8(191)), uint8(uint8(240)), uint8(uint8(207)), uint8(uint8(179)), uint8(uint8(1)), uint8(uint8(210)), uint8(uint8(196)), uint8(0), uint8(uint8(248)), uint8(uint8(8)), uint8(uint8(134)), uint8(uint8(159)), uint8(uint8(117)), uint8(uint8(47)), uint8(uint8(252)), uint8(uint8(190)), uint8(uint8(40)), uint8(uint8(33)), uint8(uint8(8)), uint8(uint8(4)), uint8(uint8(10)), uint8(uint8(44)), uint8(uint8(34)), uint8(uint8(24)), uint8(uint8(33)), uint8(uint8(239)), uint8(0), uint8(uint8(79)), uint8(uint8(213)), uint8(uint8(174)), uint8(uint8(181)), uint8(uint8(125)), uint8(uint8(208)), uint8(uint8(22)), uint8(uint8(242)), uint8(uint8(248)), uint8(0), uint8(uint8(62)), uint8(uint8(169)), uint8(uint8(180)), uint8(uint8(190)), uint8(uint8(95)), uint8(uint8(135)), uint8(uint8(128)), uint8(uint8(5)), uint8(uint8(207)), uint8(uint8(210)), uint8(uint8(250)), uint8(uint8(106)), uint8(uint8(79)), uint8(uint8(254)), uint8(uint8(250)), uint8(uint8(200)), uint8(uint8(16)), uint8(uint8(52)), uint8(uint8(18)), uint8(uint8(156)), uint8(uint8(52)), uint8(uint8(243)), uint8(uint8(243)), uint8(uint8(221)), uint8(uint8(189)), uint8(uint8(155)), uint8(uint8(212)), uint8(uint8(240)), uint8(uint8(175)), uint8(uint8(38)), uint8(uint8(3)), uint8(uint8(137)), uint8(uint8(102)), uint8(uint8(108)), uint8(uint8(241)), uint8(uint8(66)), uint8(uint8(188)), uint8(uint8(213)), uint8(0), uint8(uint8(136)), uint8(uint8(106)), uint8(uint8(125)), uint8(uint8(210)), uint8(uint8(215)), uint8(uint8(127)), uint8(uint8(75)), uint8(uint8(194)), uint8(uint8(40)), uint8(uint8(197)), uint8(uint8(23)), uint8(uint8(125)), uint8(uint8(60)), uint8(uint8(33)), uint8(uint8(63)), uint8(uint8(207)), uint8(uint8(10)), uint8(uint8(139)), uint8(uint8(159)), uint8(uint8(49)), uint8(uint8(42)), uint8(uint8(133)), uint8(uint8(233)), uint8(uint8(196)), uint8(uint8(154)), uint8(uint8(74)), uint8(uint8(127)), uint8(uint8(91)), uint8(uint8(8)), uint8(uint8(194)), uint8(uint8(193)), uint8(uint8(158)), uint8(uint8(26)), uint8(uint8(73)), uint8(uint8(76)), uint8(uint8(246)), uint8(uint8(176)), uint8(uint8(133)), uint8(uint8(185)), uint8(uint8(255)), uint8(uint8(11)), uint8(uint8(138)), uint8(uint8(173)), uint8(uint8(93)), uint8(uint8(98)), uint8(uint8(124)), uint8(uint8(22)), uint8(uint8(169)), uint8(uint8(252)), uint8(uint8(94)), uint8(uint8(176)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(178)), uint8(uint8(65)), uint8(uint8(155)), uint8(uint8(32)), uint8(uint8(87)), uint8(uint8(87)), uint8(uint8(134)), uint8(uint8(235)), uint8(uint8(12)), uint8(uint8(123)), uint8(uint8(238)), uint8(uint8(2)), uint8(uint8(22)), uint8(uint8(166)), uint8(uint8(215)), uint8(uint8(251)), uint8(uint8(39)), uint8(uint8(223)), uint8(uint8(248)), uint8(uint8(68)), uint8(uint8(16)), uint8(uint8(135)), uint8(uint8(49)), uint8(uint8(112)), uint8(uint8(3)), uint8(uint8(20)), uint8(uint8(209)), uint8(uint8(13)), uint8(uint8(89)), uint8(uint8(53)), uint8(uint8(123)), uint8(uint8(192)), uint8(uint8(68)), uint8(uint8(37)), uint8(uint8(39)), uint8(uint8(192)), uint8(uint8(35)), uint8(uint8(220)), uint8(uint8(180)), uint8(uint8(95)), uint8(uint8(239)), uint8(uint8(128)), uint8(uint8(1)), uint8(uint8(255)), uint8(uint8(92)), uint8(uint8(168)), uint8(uint8(225)), uint8(uint8(39)), uint8(uint8(170)), uint8(uint8(106)), uint8(uint8(63)), uint8(uint8(110)), uint8(uint8(52)), uint8(uint8(152)), uint8(uint8(1)), uint8(uint8(247)), uint8(uint8(20)), uint8(uint8(105)), uint8(uint8(164)), uint8(uint8(189)), uint8(uint8(140)), uint8(uint8(127)), uint8(uint8(233)), uint8(uint8(199)), uint8(uint8(14)), uint8(uint8(111)), uint8(uint8(196)), uint8(uint8(40)), uint8(uint8(80)), uint8(uint8(122)), uint8(uint8(65)), uint8(uint8(26)), uint8(uint8(212)), uint8(uint8(7)), uint8(uint8(159)), uint8(uint8(147)), uint8(uint8(99)), uint8(uint8(124)), uint8(uint8(236)), uint8(uint8(204)), uint8(uint8(191)), uint8(uint8(140)), uint8(uint8(189)), uint8(uint8(231)), uint8(uint8(140)), uint8(uint8(165)), uint8(uint8(5)), uint8(uint8(148)), uint8(uint8(23)), uint8(uint8(239)), uint8(uint8(33)), uint8(uint8(86)), uint8(uint8(204)), uint8(uint8(103)), uint8(uint8(122)), uint8(uint8(246)), uint8(uint8(206)), uint8(uint8(10)), uint8(uint8(97)), uint8(uint8(21)), uint8(uint8(247)), uint8(uint8(25)), uint8(uint8(173)), uint8(uint8(223)), uint8(uint8(6)), uint8(uint8(251)), uint8(uint8(1)), uint8(uint8(229)), uint8(uint8(102)), uint8(uint8(56)), uint8(uint8(63)), uint8(uint8(223)), uint8(uint8(13)), uint8(uint8(52)), uint8(uint8(132)), uint8(uint8(232)), uint8(uint8(4)), uint8(uint8(47)), uint8(uint8(119)), uint8(uint8(187)), uint8(uint8(135)), uint8(uint8(51)), uint8(uint8(235)), uint8(uint8(51)), uint8(uint8(27)), uint8(uint8(94)), uint8(uint8(248)), uint8(uint8(54)), uint8(uint8(213)), uint8(uint8(141)), uint8(uint8(228)), uint8(uint8(211)), uint8(uint8(96)), uint8(uint8(4)), uint8(uint8(127)), uint8(uint8(157)), uint8(uint8(82)), uint8(uint8(15)), uint8(uint8(57)), uint8(uint8(59)), uint8(uint8(226)), uint8(uint8(19)), uint8(uint8(79)), uint8(uint8(224)), uint8(uint8(75)), uint8(uint8(122)), uint8(uint8(9)), uint8(uint8(191)), uint8(uint8(187)), uint8(uint8(223)), uint8(uint8(124)), uint8(uint8(58)), uint8(uint8(112)), uint8(uint8(32)), uint8(uint8(5)), uint8(uint8(230)), uint8(uint8(134)), uint8(uint8(69)), uint8(uint8(207)), uint8(uint8(57)), uint8(uint8(156)), uint8(uint8(24)), uint8(uint8(11)), uint8(uint8(178)), uint8(uint8(28)), uint8(uint8(23)), uint8(uint8(130)), uint8(uint8(197)), uint8(uint8(228)), uint8(uint8(16)), uint8(uint8(63)), uint8(uint8(147)), uint8(0), uint8(uint8(35)), uint8(uint8(103)), uint8(uint8(205)), uint8(uint8(26)), uint8(uint8(111)), uint8(uint8(247)), uint8(uint8(194)), uint8(uint8(151)), uint8(uint8(168)), uint8(uint8(72)), uint8(uint8(207)), uint8(uint8(117)), uint8(uint8(106)), uint8(uint8(254)), uint8(uint8(79)), uint8(uint8(92)), uint8(uint8(16)), uint8(uint8(255)), uint8(uint8(12)), uint8(uint8(248)), uint8(uint8(160)), uint8(0), uint8(uint8(70)), uint8(uint8(40)), uint8(0), uint8(uint8(48)), uint8(uint8(130)), uint8(uint8(204)), uint8(uint8(65)), uint8(uint8(67)), uint8(uint8(18)), uint8(uint8(3)), uint8(uint8(51)), uint8(uint8(255)), uint8(uint8(201)), uint8(uint8(235)), uint8(uint8(146)), uint8(uint8(19)), uint8(uint8(160)), uint8(uint8(136)), uint8(uint8(68)), uint8(uint8(62)), uint8(uint8(22)), uint8(uint8(8)), uint8(uint8(227)), uint8(uint8(213)), uint8(uint8(74)), uint8(uint8(124)), uint8(uint8(103)), uint8(uint8(252)), uint8(uint8(254)), uint8(uint8(9)), uint8(uint8(94)), uint8(uint8(94)), uint8(uint8(125)), uint8(uint8(181)), uint8(uint8(85)), uint8(uint8(10)), uint8(uint8(135)), uint8(uint8(2)), uint8(uint8(80)), uint8(0), uint8(uint8(111)), uint8(uint8(232)), uint8(uint8(98)), uint8(uint8(42)), uint8(uint8(46)), uint8(uint8(213)), uint8(uint8(63)), uint8(uint8(17)), uint8(uint8(212)), uint8(uint8(202)), uint8(uint8(140)), uint8(uint8(214)), uint8(uint8(102)), uint8(uint8(38)), uint8(uint8(175)), uint8(uint8(255)), uint8(uint8(47)), uint8(uint8(252)), uint8(uint8(1)), uint8(uint8(50)), uint8(uint8(157)), uint8(uint8(180)), uint8(uint8(248)), uint8(uint8(254)), uint8(uint8(255)), uint8(uint8(224)), uint8(uint8(2)), uint8(uint8(89)), uint8(uint8(167)), uint8(uint8(73)), uint8(uint8(245)), uint8(uint8(223)), uint8(uint8(233)), uint8(uint8(127)), uint8(uint8(25)), uint8(uint8(194)), uint8(uint8(48)), uint8(uint8(169)), uint8(0), uint8(uint8(122)), uint8(uint8(133)), uint8(uint8(199)), uint8(uint8(243)), uint8(uint8(248)), uint8(uint8(60)), uint8(uint8(176)), uint8(uint8(2)), uint8(uint8(110)), uint8(uint8(155)), uint8(uint8(21)), uint8(uint8(60)), uint8(uint8(1)), uint8(uint8(8)), uint8(uint8(189)), uint8(uint8(182)), uint8(uint8(26)), uint8(uint8(227)), uint8(uint8(246)), uint8(uint8(195)), uint8(uint8(141)), uint8(uint8(55)), uint8(uint8(173)), uint8(uint8(112)), uint8(uint8(200)), uint8(uint8(190)), uint8(uint8(10)), uint8(uint8(28)), uint8(uint8(52)), uint8(uint8(179)), uint8(uint8(206)), uint8(uint8(33)), uint8(uint8(101)), uint8(uint8(24)), uint8(uint8(159)), uint8(uint8(4)), uint8(uint8(34)), uint8(uint8(63)), uint8(0), uint8(uint8(217)), uint8(uint8(101)), uint8(uint8(141)), uint8(uint8(138)), uint8(uint8(223)), uint8(uint8(107)), uint8(uint8(255)), uint8(uint8(92)), uint8(uint8(32)), uint8(uint8(22)), uint8(uint8(8)), uint8(uint8(130)), uint8(uint8(241)), uint8(uint8(82)), uint8(uint8(101)), uint8(uint8(194)), uint8(uint8(17)), uint8(uint8(127)), uint8(uint8(222)), uint8(uint8(3)), uint8(uint8(98)), uint8(uint8(230)), uint8(uint8(101)), uint8(uint8(30)), uint8(uint8(178)), uint8(uint8(147)), uint8(uint8(145)), uint8(uint8(74)), uint8(uint8(112)), uint8(uint8(20)), uint8(uint8(238)), uint8(uint8(176)), uint8(0), uint8(uint8(109)), uint8(uint8(156)), uint8(uint8(86)), uint8(uint8(82)), uint8(uint8(255)), uint8(uint8(15)), uint8(uint8(4)), uint8(uint8(123)), uint8(uint8(216)), uint8(0), uint8(uint8(199)), uint8(uint8(34)), uint8(uint8(22)), uint8(uint8(70)), uint8(uint8(187)), uint8(uint8(190)), uint8(uint8(31)), uint8(uint8(52)), uint8(uint8(42)), uint8(uint8(81)), uint8(uint8(44)), uint8(uint8(31)), uint8(uint8(203)), uint8(uint8(226)), uint8(uint8(31)), uint8(uint8(18)), uint8(uint8(15)), uint8(uint8(227)), uint8(uint8(19)), uint8(uint8(135)), uint8(uint8(47)), uint8(uint8(130)), uint8(uint8(107)), uint8(uint8(148)), uint8(uint8(34)), uint8(uint8(224)), uint8(uint8(146)), uint8(uint8(170)), uint8(uint8(182)), uint8(uint8(240)), uint8(uint8(97)), uint8(uint8(57)), uint8(uint8(12)), uint8(uint8(159)), uint8(uint8(135)), uint8(uint8(116)), uint8(uint8(87)), uint8(uint8(254)), uint8(uint8(255)), uint8(uint8(240)), uint8(uint8(135)), uint8(uint8(120)), uint8(uint8(66)), uint8(uint8(112)), uint8(uint8(137)), uint8(uint8(202)), uint8(uint8(190)), uint8(uint8(25)), uint8(uint8(181)), uint8(uint8(127)), uint8(uint8(249)), uint8(uint8(124)), uint8(uint8(225)), uint8(uint8(18)), uint8(uint8(124)), uint8(uint8(18)), uint8(uint8(148)), uint8(uint8(60)), uint8(uint8(41)), uint8(uint8(23)), uint8(uint8(206)), uint8(uint8(191)), uint8(uint8(137)), uint8(uint8(21)), uint8(uint8(100)), uint8(uint8(210)), uint8(uint8(225)), uint8(uint8(172)), uint8(uint8(20)), uint8(uint8(236)), uint8(uint8(46)), uint8(uint8(33)), uint8(uint8(239)), uint8(uint8(171)), uint8(uint8(169)), uint8(uint8(83)), uint8(uint8(249)), uint8(uint8(161)), uint8(uint8(88)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(251)), uint8(uint8(65)), uint8(uint8(155)), uint8(uint8(64)), uint8(uint8(103)), uint8(uint8(41)), uint8(uint8(63)), uint8(uint8(173)), uint8(uint8(252)), uint8(uint8(47)), uint8(uint8(224)), uint8(uint8(7)), uint8(uint8(169)), uint8(uint8(234)), uint8(uint8(189)), uint8(uint8(63)), uint8(uint8(135)), uint8(uint8(1)), uint8(uint8(61)), uint8(uint8(38)), uint8(uint8(213)), uint8(uint8(245)), uint8(uint8(55)), uint8(uint8(25)), uint8(uint8(2)), uint8(uint8(175)), uint8(uint8(14)), uint8(uint8(195)), uint8(uint8(253)), uint8(uint8(224)), uint8(uint8(9)), uint8(uint8(95)), uint8(uint8(250)), uint8(uint8(113)), uint8(uint8(57)), uint8(uint8(39)), uint8(uint8(182)), uint8(uint8(154)), uint8(uint8(254)), uint8(uint8(22)), uint8(uint8(38)), uint8(uint8(4)), uint8(uint8(229)), uint8(uint8(71)), uint8(uint8(53)), uint8(uint8(228)), uint8(uint8(235)), uint8(uint8(251)), uint8(uint8(189)), uint8(uint8(100)), uint8(uint8(23)), uint8(uint8(102)), uint8(uint8(46)), uint8(uint8(144)), uint8(uint8(120)), uint8(uint8(12)), uint8(uint8(116)), uint8(uint8(29)), uint8(uint8(132)), uint8(uint8(17)), uint8(uint8(187)), uint8(uint8(189)), uint8(uint8(106)), uint8(uint8(23)), uint8(uint8(32)), uint8(uint8(5)), uint8(uint8(13)), uint8(uint8(220)), uint8(uint8(175)), uint8(uint8(8)), uint8(uint8(102)), uint8(uint8(241)), uint8(uint8(47)), uint8(uint8(235)), uint8(uint8(255)), uint8(uint8(223)), uint8(uint8(121)), uint8(uint8(235)), uint8(uint8(130)), uint8(uint8(53)), uint8(uint8(61)), uint8(uint8(64)), uint8(uint8(211)), uint8(uint8(35)), uint8(uint8(127)), uint8(uint8(247)), uint8(uint8(223)), uint8(uint8(47)), uint8(uint8(224)), uint8(uint8(219)), uint8(uint8(194)), uint8(uint8(33)), uint8(uint8(99)), uint8(uint8(128)), uint8(uint8(158)), uint8(uint8(145)), uint8(uint8(157)), uint8(uint8(106)), uint8(uint8(243)), uint8(uint8(233)), uint8(uint8(73)), uint8(uint8(148)), uint8(uint8(19)), uint8(uint8(101)), uint8(uint8(167)), uint8(uint8(217)), uint8(uint8(225)), uint8(uint8(1)), uint8(uint8(86)), uint8(uint8(112)), uint8(uint8(145)), uint8(uint8(116)), uint8(uint8(45)), uint8(uint8(140)), uint8(uint8(92)), uint8(uint8(188)), uint8(uint8(56)), uint8(uint8(194)), uint8(uint8(223)), uint8(uint8(250)), uint8(uint8(93)), uint8(uint8(126)), uint8(uint8(25)), uint8(uint8(131)), uint8(uint8(105)), uint8(uint8(144)), uint8(uint8(245)), uint8(uint8(156)), uint8(uint8(7)), uint8(uint8(64)), uint8(uint8(116)), uint8(uint8(58)), uint8(uint8(99)), uint8(uint8(151)), uint8(uint8(240)), uint8(uint8(106)), uint8(uint8(28)), uint8(uint8(190)), uint8(uint8(45)), uint8(uint8(224)), uint8(uint8(64)), uint8(uint8(227)), uint8(uint8(65)), uint8(uint8(56)), uint8(uint8(31)), uint8(uint8(166)), uint8(uint8(82)), uint8(uint8(95)), uint8(uint8(3)), uint8(uint8(244)), uint8(uint8(202)), uint8(uint8(75)), uint8(uint8(225)), uint8(uint8(147)), uint8(uint8(145)), uint8(uint8(220)), uint8(uint8(201)), uint8(uint8(197)), uint8(uint8(223)), uint8(uint8(208)), uint8(uint8(156)), uint8(uint8(142)), uint8(uint8(230)), uint8(uint8(78)), uint8(uint8(46)), uint8(uint8(254)), uint8(uint8(54)), uint8(uint8(135)), uint8(uint8(192)), uint8(uint8(16)), uint8(uint8(147)), uint8(uint8(83)), uint8(uint8(213)), uint8(uint8(127)), uint8(uint8(176)), uint8(uint8(244)), uint8(uint8(154)), uint8(uint8(158)), uint8(uint8(171)), uint8(uint8(253)), uint8(uint8(165)), uint8(uint8(28)), uint8(uint8(135)), uint8(uint8(106)), uint8(uint8(82)), uint8(uint8(142)), uint8(uint8(67)), uint8(uint8(181)), uint8(uint8(32)), uint8(uint8(23)), uint8(uint8(21)), uint8(uint8(201)), uint8(uint8(253)), uint8(uint8(50)), uint8(uint8(113)), uint8(uint8(92)), uint8(uint8(159)), uint8(uint8(211)), uint8(uint8(50)), uint8(uint8(223)), uint8(uint8(187)), uint8(uint8(226)), uint8(uint8(59)), uint8(uint8(126)), uint8(uint8(239)), uint8(uint8(134)), uint8(uint8(168)), uint8(uint8(78)), uint8(uint8(134)), uint8(uint8(130)), uint8(uint8(143)), uint8(uint8(192)), uint8(uint8(8)), uint8(uint8(143)), uint8(uint8(194)), uint8(uint8(142)), uint8(uint8(236)), uint8(uint8(126)), uint8(uint8(108)), uint8(uint8(49)), uint8(uint8(90)), uint8(uint8(70)), uint8(uint8(200)), uint8(uint8(181)), uint8(uint8(123)), uint8(uint8(225)), uint8(uint8(85)), uint8(uint8(25)), uint8(uint8(164)), uint8(uint8(64)), uint8(uint8(198)), uint8(uint8(92)), uint8(uint8(232)), uint8(uint8(62)), uint8(uint8(217)), uint8(uint8(26)), uint8(uint8(70)), uint8(uint8(12)), uint8(uint8(101)), uint8(uint8(206)), uint8(uint8(48)), uint8(uint8(132)), uint8(uint8(98)), uint8(uint8(38)), uint8(0), uint8(uint8(26)), uint8(uint8(156)), uint8(uint8(26)), uint8(uint8(246)), uint8(uint8(219)), uint8(uint8(201)), uint8(uint8(184)), uint8(uint8(31)), uint8(uint8(108)), uint8(uint8(137)), uint8(uint8(35)), uint8(uint8(4)), uint8(uint8(34)), uint8(uint8(231)), uint8(uint8(80)), uint8(uint8(204)), uint8(uint8(189)), uint8(uint8(106)), uint8(uint8(126)), uint8(uint8(253)), uint8(uint8(194)), uint8(uint8(16)), uint8(uint8(208)), uint8(uint8(128)), uint8(uint8(145)), uint8(uint8(1)), uint8(uint8(69)), uint8(uint8(234)), uint8(uint8(183)), uint8(uint8(209)), uint8(uint8(87)), uint8(uint8(71)), uint8(uint8(84)), uint8(uint8(130)), uint8(uint8(194)), uint8(uint8(245)), uint8(uint8(24)), uint8(uint8(241)), uint8(uint8(240)), uint8(uint8(239)), uint8(uint8(164)), uint8(uint8(17)), uint8(uint8(175)), uint8(uint8(226)), uint8(uint8(182)), uint8(uint8(233)), uint8(uint8(175)), uint8(uint8(220)), uint8(uint8(228)), uint8(uint8(156)), uint8(uint8(160)), uint8(uint8(253)), uint8(uint8(64)), uint8(uint8(198)), uint8(uint8(110)), uint8(uint8(112)), uint8(uint8(86)), uint8(uint8(55)), uint8(uint8(223)), uint8(uint8(210)), uint8(uint8(254)), uint8(uint8(12)), uint8(uint8(130)), uint8(uint8(24)), uint8(uint8(70)), uint8(uint8(30)), uint8(uint8(134)), uint8(uint8(166)), uint8(uint8(68)), uint8(uint8(107)), uint8(uint8(228)), uint8(uint8(30)), uint8(uint8(177)), uint8(uint8(85)), uint8(uint8(25)), uint8(uint8(226)), uint8(uint8(137)), uint8(uint8(50)), uint8(uint8(192)), uint8(uint8(93)), uint8(uint8(52)), uint8(uint8(25)), uint8(uint8(142)), uint8(uint8(106)), uint8(uint8(213)), uint8(uint8(241)), uint8(uint8(22)), uint8(uint8(131)), uint8(uint8(5)), uint8(uint8(59)), uint8(uint8(13)), uint8(uint8(225)), uint8(uint8(127)), uint8(uint8(128)), uint8(uint8(8)), uint8(uint8(141)), uint8(uint8(221)), uint8(uint8(175)), uint8(uint8(128)), uint8(uint8(140)), uint8(uint8(85)), uint8(uint8(118)), uint8(uint8(86)), uint8(uint8(114)), uint8(uint8(252)), uint8(0), uint8(uint8(40)), uint8(uint8(181)), uint8(uint8(145)), uint8(uint8(204)), uint8(uint8(153)), uint8(uint8(151)), uint8(uint8(6)), uint8(uint8(124)), uint8(uint8(190)), uint8(uint8(110)), uint8(uint8(18)), uint8(uint8(8)), uint8(uint8(216)), uint8(uint8(47)), uint8(uint8(196)), uint8(uint8(39)), uint8(uint8(137)), uint8(uint8(222)), uint8(uint8(238)), uint8(uint8(31)), uint8(uint8(48)), uint8(uint8(15)), uint8(uint8(210)), uint8(uint8(93)), uint8(uint8(192)), uint8(uint8(241)), uint8(uint8(121)), uint8(uint8(192)), uint8(uint8(159)), uint8(uint8(203)), uint8(uint8(201)), uint8(uint8(114)), uint8(uint8(190)), uint8(uint8(159)), uint8(uint8(175)), uint8(uint8(112)), uint8(uint8(85)), uint8(uint8(27)), uint8(uint8(91)), uint8(uint8(183)), uint8(uint8(203)), uint8(uint8(137)), uint8(uint8(67)), uint8(uint8(79)), uint8(uint8(123)), uint8(uint8(50)), uint8(uint8(249)), uint8(uint8(34)), uint8(uint8(236)), uint8(uint8(34)), uint8(uint8(231)), uint8(uint8(233)), uint8(uint8(151)), uint8(uint8(241)), uint8(uint8(123)), uint8(uint8(176)), uint8(uint8(117)), uint8(uint8(7)), uint8(uint8(12)), uint8(uint8(57)), uint8(uint8(192)), uint8(uint8(64)), uint8(uint8(143)), uint8(uint8(182)), uint8(uint8(173)), uint8(uint8(90)), uint8(uint8(196)), uint8(uint8(47)), uint8(uint8(193)), uint8(uint8(41)), uint8(uint8(63)), uint8(uint8(224)), uint8(uint8(4)), uint8(uint8(94)), uint8(uint8(186)), uint8(uint8(61)), uint8(uint8(62)), uint8(uint8(251)), uint8(uint8(248)), uint8(0), uint8(uint8(81)), uint8(uint8(50)), uint8(uint8(26)), uint8(uint8(35)), uint8(uint8(147)), uint8(uint8(185)), uint8(uint8(28)), uint8(uint8(143)), uint8(uint8(194)), uint8(uint8(58)), uint8(uint8(120)), uint8(uint8(46)), uint8(uint8(148)), uint8(uint8(120)), uint8(uint8(34)), uint8(uint8(196)), uint8(uint8(57)), uint8(uint8(225)), uint8(uint8(238)), uint8(uint8(21)), uint8(uint8(43)), uint8(uint8(138)), uint8(uint8(231)), uint8(uint8(199)), uint8(uint8(191)), uint8(uint8(168)), uint8(uint8(1)), uint8(uint8(34)), uint8(uint8(54)), uint8(uint8(175)), uint8(uint8(242)), uint8(uint8(249)), uint8(uint8(42)), uint8(uint8(94)), uint8(uint8(190)), uint8(uint8(201)), uint8(uint8(239)), uint8(uint8(96)), uint8(uint8(150)), uint8(uint8(10)), uint8(uint8(230)), uint8(uint8(8)), uint8(uint8(140)), uint8(uint8(97)), uint8(uint8(114)), uint8(uint8(123)), uint8(uint8(115)), uint8(uint8(113)), uint8(uint8(15)), uint8(uint8(63)), uint8(uint8(192)), uint8(uint8(27)), uint8(uint8(197)), uint8(uint8(216)), uint8(uint8(175)), uint8(uint8(68)), uint8(uint8(138)), uint8(uint8(178)), uint8(uint8(89)), uint8(uint8(135)), uint8(uint8(211)), uint8(uint8(1)), uint8(uint8(45)), uint8(uint8(204)), uint8(uint8(175)), uint8(uint8(238)), uint8(uint8(225)), uint8(uint8(192)), uint8(uint8(1)), uint8(uint8(243)), uint8(uint8(70)), uint8(uint8(37)), uint8(uint8(236)), uint8(uint8(92)), uint8(uint8(133)), uint8(uint8(202)), uint8(uint8(36)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(193)), uint8(uint8(65)), uint8(uint8(155)), uint8(uint8(96)), uint8(uint8(33)), uint8(uint8(203)), uint8(uint8(225)), uint8(uint8(204)), uint8(uint8(1)), uint8(uint8(144)), uint8(uint8(100)), uint8(uint8(201)), uint8(uint8(190)), uint8(uint8(212)), uint8(uint8(40)), uint8(uint8(180)), uint8(uint8(154)), uint8(uint8(96)), uint8(uint8(197)), uint8(uint8(237)), uint8(0), uint8(uint8(112)), uint8(uint8(17)), uint8(uint8(224)), uint8(uint8(6)), uint8(uint8(108)), uint8(uint8(157)), uint8(uint8(249)), uint8(uint8(206)), uint8(0), uint8(uint8(59)), uint8(uint8(47)), uint8(uint8(205)), uint8(uint8(114)), uint8(uint8(222)), uint8(uint8(253)), uint8(uint8(118)), uint8(uint8(234)), uint8(uint8(55)), uint8(uint8(154)), uint8(uint8(32)), uint8(0), uint8(uint8(217)), uint8(uint8(122)), uint8(uint8(49)), uint8(uint8(248)), uint8(uint8(141)), uint8(uint8(162)), uint8(uint8(252)), uint8(uint8(251)), uint8(uint8(155)), uint8(uint8(112)), uint8(uint8(69)), uint8(uint8(238)), uint8(uint8(157)), uint8(uint8(244)), uint8(uint8(110)), uint8(uint8(204)), uint8(uint8(54)), uint8(uint8(91)), uint8(uint8(109)), uint8(uint8(98)), uint8(uint8(103)), uint8(uint8(105)), uint8(uint8(149)), uint8(uint8(101)), uint8(uint8(24)), uint8(uint8(245)), uint8(uint8(201)), uint8(uint8(95)), uint8(uint8(238)), uint8(uint8(176)), uint8(uint8(155)), uint8(uint8(101)), uint8(uint8(98)), uint8(uint8(179)), uint8(uint8(22)), uint8(uint8(75)), uint8(uint8(185)), uint8(uint8(233)), uint8(uint8(144)), uint8(uint8(40)), uint8(uint8(201)), uint8(uint8(239)), uint8(uint8(239)), uint8(uint8(236)), uint8(uint8(135)), uint8(uint8(121)), uint8(uint8(16)), uint8(uint8(106)), uint8(uint8(171)), uint8(uint8(235)), uint8(uint8(175)), uint8(uint8(20)), uint8(uint8(176)), uint8(uint8(158)), uint8(uint8(130)), uint8(uint8(110)), uint8(uint8(252)), uint8(uint8(255)), uint8(uint8(142)), uint8(uint8(231)), uint8(uint8(52)), uint8(uint8(59)), uint8(uint8(217)), uint8(uint8(193)), uint8(uint8(72)), uint8(uint8(22)), uint8(uint8(113)), uint8(uint8(103)), uint8(uint8(252)), uint8(uint8(195)), uint8(uint8(107)), uint8(uint8(209)), uint8(uint8(206)), uint8(uint8(168)), uint8(uint8(111)), uint8(uint8(122)), uint8(uint8(248)), uint8(uint8(68)), uint8(uint8(16)), uint8(uint8(240)), uint8(uint8(20)), uint8(uint8(23)), uint8(uint8(156)), uint8(uint8(200)), uint8(uint8(123)), uint8(uint8(200)), uint8(uint8(144)), uint8(uint8(214)), uint8(uint8(225)), uint8(uint8(24)), uint8(uint8(116)), uint8(uint8(72)), uint8(uint8(58)), uint8(uint8(88)), uint8(uint8(14)), uint8(uint8(172)), uint8(uint8(7)), uint8(uint8(175)), uint8(uint8(224)), uint8(uint8(196)), uint8(uint8(208)), uint8(uint8(96)), uint8(uint8(218)), uint8(uint8(65)), uint8(uint8(219)), uint8(uint8(132)), uint8(uint8(15)), uint8(uint8(117)), uint8(uint8(7)), uint8(uint8(5)), uint8(uint8(192)), uint8(uint8(3)), uint8(uint8(96)), uint8(uint8(203)), uint8(uint8(242)), uint8(uint8(95)), uint8(uint8(73)), uint8(uint8(183)), uint8(uint8(54)), uint8(uint8(185)), uint8(uint8(237)), uint8(uint8(255)), uint8(uint8(128)), uint8(uint8(37)), uint8(uint8(55)), uint8(uint8(164)), uint8(uint8(125)), uint8(uint8(125)), uint8(uint8(26)), uint8(uint8(251)), uint8(uint8(60)), uint8(uint8(98)), uint8(uint8(29)), uint8(uint8(182)), uint8(uint8(205)), uint8(uint8(60)), uint8(uint8(27)), uint8(uint8(126)), uint8(uint8(62)), uint8(uint8(240)), uint8(uint8(247)), uint8(uint8(191)), uint8(uint8(80)), uint8(uint8(185)), uint8(uint8(191)), uint8(0), uint8(uint8(11)), uint8(uint8(212)), uint8(uint8(153)), uint8(uint8(158)), uint8(uint8(74)), uint8(uint8(190)), uint8(uint8(161)), uint8(uint8(63)), uint8(uint8(72)), uint8(uint8(208)), uint8(uint8(64)), uint8(uint8(191)), uint8(uint8(191)), uint8(uint8(80)), uint8(uint8(52)), uint8(uint8(177)), uint8(uint8(110)), uint8(uint8(221)), uint8(uint8(133)), uint8(uint8(173)), uint8(uint8(125)), uint8(uint8(216)), uint8(uint8(3)), uint8(uint8(129)), uint8(uint8(95)), uint8(uint8(213)), uint8(uint8(2)), uint8(uint8(184)), uint8(uint8(2)), uint8(uint8(93)), uint8(uint8(87)), uint8(uint8(48)), uint8(uint8(143)), uint8(uint8(63)), uint8(uint8(255)), uint8(uint8(244)), uint8(uint8(7)), uint8(uint8(229)), uint8(uint8(5)), uint8(uint8(112)), uint8(uint8(5)), uint8(uint8(233)), uint8(uint8(61)), uint8(uint8(205)), uint8(uint8(3)), uint8(uint8(38)), uint8(uint8(191)), uint8(uint8(253)), uint8(uint8(201)), uint8(uint8(250)), uint8(uint8(194)), uint8(uint8(8)), uint8(uint8(33)), uint8(uint8(194)), uint8(uint8(33)), uint8(uint8(157)), uint8(uint8(64)), uint8(uint8(58)), uint8(uint8(193)), uint8(uint8(83)), uint8(uint8(22)), uint8(uint8(64)), uint8(uint8(57)), uint8(0), uint8(uint8(232)), uint8(uint8(105)), uint8(uint8(2)), uint8(uint8(125)), uint8(uint8(132)), uint8(uint8(182)), uint8(uint8(192)), uint8(uint8(34)), uint8(uint8(25)), uint8(uint8(108)), uint8(uint8(175)), uint8(uint8(252)), uint8(uint8(254)), uint8(uint8(28)), uint8(uint8(1)), uint8(uint8(150)), uint8(uint8(229)), uint8(uint8(177)), uint8(uint8(95)), uint8(uint8(254)), uint8(uint8(127)), uint8(uint8(15)), uint8(uint8(194)), uint8(uint8(16)), uint8(uint8(220)), uint8(uint8(14)), uint8(uint8(132)), uint8(uint8(68)), uint8(uint8(25)), uint8(uint8(223)), uint8(uint8(10)), uint8(uint8(152)), uint8(uint8(194)), uint8(uint8(167)), uint8(uint8(224)), uint8(uint8(113)), uint8(uint8(12)), uint8(uint8(91)), uint8(uint8(159)), uint8(uint8(192)), uint8(uint8(26)), uint8(uint8(216)), uint8(uint8(246)), uint8(uint8(47)), uint8(uint8(61)), uint8(uint8(245)), uint8(uint8(226)), uint8(uint8(225)), uint8(uint8(89)), uint8(uint8(49)), uint8(uint8(117)), uint8(uint8(193)), uint8(uint8(246)), uint8(uint8(3)), uint8(uint8(45)), uint8(uint8(9)), uint8(uint8(144)), uint8(uint8(149)), uint8(uint8(40)), uint8(uint8(28)), uint8(uint8(228)), uint8(uint8(215)), uint8(uint8(134)), uint8(uint8(12)), uint8(uint8(237)), uint8(uint8(107)), uint8(uint8(95)), uint8(uint8(147)), uint8(uint8(223)), uint8(uint8(6)), uint8(uint8(159)), uint8(uint8(56)), uint8(uint8(68)), uint8(uint8(51)), uint8(uint8(120)), uint8(uint8(85)), uint8(uint8(209)), uint8(uint8(41)), uint8(uint8(218)), uint8(uint8(253)), uint8(uint8(171)), uint8(uint8(99)), uint8(uint8(93)), uint8(uint8(95)), uint8(uint8(130)), uint8(uint8(141)), uint8(uint8(86)), uint8(uint8(181)), uint8(uint8(246)), uint8(uint8(95)), uint8(uint8(240)), uint8(uint8(97)), uint8(uint8(132)), uint8(uint8(14)), uint8(uint8(76)), uint8(uint8(63)), uint8(uint8(4)), uint8(uint8(223)), uint8(uint8(217)), uint8(uint8(255)), uint8(uint8(84)), uint8(uint8(120)), uint8(uint8(84)), uint8(uint8(224)), uint8(uint8(245)), uint8(uint8(224)), uint8(uint8(245)), uint8(uint8(240)), uint8(uint8(117)), uint8(uint8(120)), uint8(uint8(58)), uint8(uint8(184)), uint8(uint8(128)), uint8(uint8(37)), uint8(uint8(66)), uint8(0), uint8(uint8(9)), uint8(uint8(208)), uint8(uint8(113)), uint8(uint8(12)), uint8(uint8(91)), uint8(uint8(129)), uint8(uint8(200)), uint8(uint8(102)), uint8(uint8(185)), uint8(uint8(228)), uint8(uint8(2)), uint8(uint8(43)), uint8(uint8(238)), uint8(uint8(7)), uint8(uint8(8)), uint8(uint8(174)), uint8(uint8(185)), uint8(uint8(252)), uint8(uint8(225)), uint8(uint8(20)), uint8(uint8(72)), uint8(uint8(181)), uint8(uint8(199)), uint8(uint8(236)), uint8(uint8(184)), uint8(uint8(17)), uint8(uint8(174)), uint8(uint8(35)), uint8(uint8(190)), uint8(uint8(31)), uint8(uint8(242)), uint8(uint8(250)), uint8(uint8(138)), uint8(uint8(8)), uint8(uint8(98)), uint8(uint8(170)), uint8(uint8(34)), uint8(uint8(179)), uint8(uint8(202)), uint8(uint8(16)), uint8(uint8(12)), uint8(uint8(19)), uint8(uint8(129)), uint8(uint8(224)), uint8(uint8(99)), uint8(uint8(50)), uint8(uint8(194)), uint8(0), uint8(uint8(44)), uint8(uint8(239)), uint8(uint8(43)), uint8(uint8(119)), uint8(uint8(224)), uint8(uint8(49)), uint8(uint8(8)), uint8(uint8(144)), uint8(uint8(215)), uint8(uint8(80)), uint8(uint8(35)), uint8(uint8(55)), uint8(uint8(207)), uint8(uint8(41)), uint8(uint8(233)), uint8(uint8(250)), uint8(uint8(192)), uint8(uint8(7)), uint8(uint8(52)), uint8(uint8(54)), uint8(uint8(55)), uint8(uint8(21)), uint8(uint8(108)), uint8(uint8(86)), uint8(uint8(237)), uint8(uint8(3)), uint8(uint8(228)), uint8(uint8(204)), uint8(uint8(72)), uint8(uint8(241)), uint8(uint8(99)), uint8(uint8(247)), uint8(uint8(231)), uint8(uint8(128)), uint8(0), uint8(0), uint8(uint8(3)), uint8(uint8(83)), uint8(uint8(109)), uint8(uint8(111)), uint8(uint8(111)), uint8(uint8(118)), uint8(0), uint8(0), uint8(0), uint8(uint8(108)), uint8(uint8(109)), uint8(uint8(118)), uint8(uint8(104)), uint8(uint8(100)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(3)), uint8(uint8(232)), uint8(0), uint8(0), uint8(uint8(3)), uint8(uint8(232)), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(64)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(2)), uint8(0), uint8(0), uint8(uint8(2)), uint8(uint8(126)), uint8(uint8(116)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(107)), uint8(0), uint8(0), uint8(0), uint8(uint8(92)), uint8(uint8(116)), uint8(uint8(107)), uint8(uint8(104)), uint8(uint8(100)), uint8(0), uint8(0), uint8(0), uint8(uint8(3)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(3)), uint8(uint8(232)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(64)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(96)), uint8(0), uint8(0), uint8(0), uint8(uint8(64)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(36)), uint8(uint8(101)), uint8(uint8(100)), uint8(uint8(116)), uint8(uint8(115)), uint8(0), uint8(0), uint8(0), uint8(uint8(28)), uint8(uint8(101)), uint8(uint8(108)), uint8(uint8(115)), uint8(uint8(116)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(uint8(3)), uint8(uint8(232)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(246)), uint8(uint8(109)), uint8(uint8(100)), uint8(uint8(105)), uint8(uint8(97)), uint8(0), uint8(0), uint8(0), uint8(uint8(32)), uint8(uint8(109)), uint8(uint8(100)), uint8(uint8(104)), uint8(uint8(100)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(48)), uint8(0), uint8(0), uint8(0), uint8(uint8(48)), uint8(0), uint8(uint8(85)), uint8(uint8(196)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(45)), uint8(uint8(104)), uint8(uint8(100)), uint8(uint8(108)), uint8(uint8(114)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(118)), uint8(uint8(105)), uint8(uint8(100)), uint8(uint8(101)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(86)), uint8(uint8(105)), uint8(uint8(100)), uint8(uint8(101)), uint8(uint8(111)), uint8(uint8(72)), uint8(uint8(97)), uint8(uint8(110)), uint8(uint8(100)), uint8(uint8(108)), uint8(uint8(101)), uint8(uint8(114)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(161)), uint8(uint8(109)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(102)), uint8(0), uint8(0), uint8(0), uint8(uint8(20)), uint8(uint8(118)), uint8(uint8(109)), uint8(uint8(104)), uint8(uint8(100)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(36)), uint8(uint8(100)), uint8(uint8(105)), uint8(uint8(110)), uint8(uint8(102)), uint8(0), uint8(0), uint8(0), uint8(uint8(28)), uint8(uint8(100)), uint8(uint8(114)), uint8(uint8(101)), uint8(uint8(102)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(12)), uint8(uint8(117)), uint8(uint8(114)), uint8(uint8(108)), uint8(uint8(32)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(97)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(98)), uint8(uint8(108)), uint8(0), uint8(0), uint8(0), uint8(uint8(185)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(115)), uint8(uint8(100)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(169)), uint8(uint8(97)), uint8(uint8(118)), uint8(uint8(99)), uint8(uint8(49)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(96)), uint8(0), uint8(uint8(64)), uint8(0), uint8(uint8(72)), uint8(0), uint8(0), uint8(0), uint8(uint8(72)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(21)), uint8(uint8(76)), uint8(uint8(97)), uint8(uint8(118)), uint8(uint8(99)), uint8(uint8(54)), uint8(uint8(50)), uint8(uint8(46)), uint8(uint8(49)), uint8(uint8(49)), uint8(uint8(46)), uint8(uint8(49)), uint8(uint8(48)), uint8(uint8(48)), uint8(uint8(32)), uint8(uint8(108)), uint8(uint8(105)), uint8(uint8(98)), uint8(uint8(120)), uint8(uint8(50)), uint8(uint8(54)), uint8(uint8(52)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(24)), uint8(uint8(255)), uint8(uint8(255)), uint8(0), uint8(0), uint8(0), uint8(uint8(47)), uint8(uint8(97)), uint8(uint8(118)), uint8(uint8(99)), uint8(uint8(67)), uint8(uint8(1)), uint8(uint8(66)), uint8(uint8(192)), uint8(uint8(10)), uint8(uint8(255)), uint8(uint8(225)), uint8(0), uint8(uint8(23)), uint8(uint8(103)), uint8(uint8(66)), uint8(uint8(192)), uint8(uint8(10)), uint8(uint8(217)), uint8(uint8(6)), uint8(uint8(38)), uint8(uint8(192)), uint8(uint8(68)), uint8(0), uint8(0), uint8(uint8(3)), uint8(0), uint8(uint8(4)), uint8(0), uint8(0), uint8(uint8(3)), uint8(0), uint8(uint8(96)), uint8(uint8(60)), uint8(uint8(72)), uint8(uint8(153)), uint8(uint8(32)), uint8(uint8(1)), uint8(0), uint8(uint8(5)), uint8(uint8(104)), uint8(uint8(203)), uint8(uint8(131)), uint8(uint8(203)), uint8(uint8(32)), uint8(0), uint8(0), uint8(0), uint8(uint8(16)), uint8(uint8(112)), uint8(uint8(97)), uint8(uint8(115)), uint8(uint8(112)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(20)), uint8(uint8(98)), uint8(uint8(116)), uint8(uint8(114)), uint8(uint8(116)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(223)), uint8(uint8(72)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(24)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(116)), uint8(uint8(115)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(12)), uint8(0), uint8(0), uint8(uint8(4)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(20)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(115)), uint8(uint8(115)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(28)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(115)), uint8(uint8(99)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(12)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(68)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(115)), uint8(uint8(122)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(12)), uint8(0), uint8(0), uint8(uint8(9)), uint8(uint8(70)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(206)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(224)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(163)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(139)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(172)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(183)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(34)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(200)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(182)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(255)), uint8(0), uint8(0), uint8(uint8(1)), uint8(uint8(197)), uint8(0), uint8(0), uint8(0), uint8(uint8(20)), uint8(uint8(115)), uint8(uint8(116)), uint8(uint8(99)), uint8(uint8(111)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(uint8(48)), uint8(0), uint8(0), uint8(0), uint8(uint8(97)), uint8(uint8(117)), uint8(uint8(100)), uint8(uint8(116)), uint8(uint8(97)), uint8(0), uint8(0), uint8(0), uint8(uint8(89)), uint8(uint8(109)), uint8(uint8(101)), uint8(uint8(116)), uint8(uint8(97)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(33)), uint8(uint8(104)), uint8(uint8(100)), uint8(uint8(108)), uint8(uint8(114)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(109)), uint8(uint8(100)), uint8(uint8(105)), uint8(uint8(114)), uint8(uint8(97)), uint8(uint8(112)), uint8(uint8(112)), uint8(uint8(108)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(44)), uint8(uint8(105)), uint8(uint8(108)), uint8(uint8(115)), uint8(uint8(116)), uint8(0), uint8(0), uint8(0), uint8(uint8(36)), uint8(uint8(169)), uint8(uint8(116)), uint8(uint8(111)), uint8(uint8(111)), uint8(0), uint8(0), uint8(0), uint8(uint8(28)), uint8(uint8(100)), uint8(uint8(97)), uint8(uint8(116)), uint8(uint8(97)), uint8(0), uint8(0), uint8(0), uint8(uint8(1)), uint8(0), uint8(0), uint8(0), uint8(0), uint8(uint8(76)), uint8(uint8(97)), uint8(uint8(118)), uint8(uint8(102)), uint8(uint8(54)), uint8(uint8(50)), uint8(uint8(46)), uint8(uint8(51)), uint8(uint8(46)), uint8(uint8(49)), uint8(uint8(48)), uint8(uint8(48)))

var host_height : int = 0

var sample_mp4_len : uint const = uint(uint(uint(0x1f6c)))

var host_length : int = 0

var host_picture : uint8? = null

var host_width : int = 0

var host_y_size : int = 0

[export]
def memory_read_callback(var offset : int64; var buffer : uint64; var size : uint64; var token : uint64) : int {
    var input : c2da_module::MemoryInput? = unsafe(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(unsafe(reinterpret<c2da_module::MemoryInput?>(token))))))))))))
    if (int64(offset) < int64(int64(0))) {
        return 1
    }
    if (int64(offset) + int64(size) > int64(unsafe(*input).length)) {
        return 1
    }
    unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(buffer))), unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*input).bytes))), uint64(offset), 1)))))))), int(size)))
    return 0
    return int(0)
}
[export]
def h264mp4_probe_minimp4_second_box_name() : int {
    var input_6 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    input_6.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_6.length = int(sample_mp4_len)
    return c2da_probe_minimp4_second_box_name(@@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_6))))), int64(int64(sample_mp4_len)))
    return int(0)
}
[export]
def output_picture_height(var storage_0 : h264bsd::storage?) : int {
    return int(h264bsd::h264bsdPicHeight(storage_0)) * 16
    return int(0)
}
[export]
def h264mp4_probe_header_size() : int {
    var input_17 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_10 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_9 : int = -1
    c2da_reset_heap()
    mp4_10 = minimp4::MP4D_demux_tag()
    input_17.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_17.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_10))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_17))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_9 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_10))))))))
    if (int(track_index_9) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_10))))))
        return -1
    }
    return header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_10))))))), track_index_9)
    return int(0)
}
[export]
def h264mp4_probe_memory_read_word0() : int {
    var input_1 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var bytes_1 : uint8 [4] = fixed_array<uint8>(uint8(0), uint8(0), uint8(0), uint8(0))
    input_1.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_1.length = int(sample_mp4_len)
    unsafe(bytes_1[0]) = uint8(uint8(uint8(0xff)))
    unsafe(bytes_1[1]) = uint8(uint8(uint8(0xff)))
    unsafe(bytes_1[2]) = uint8(uint8(uint8(0xff)))
    unsafe(bytes_1[3]) = uint8(uint8(uint8(0xff)))
    if (uint64(memory_read_callback(int64(int64(int64(0))), intptr(unsafe(reinterpret<uint8?>(unsafe(addr(bytes_1[0]))))), uint64(uint64(uint64(0x4))), intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_1))))))) != uint64(0)) {
        return -1
    }
    return int(unsafe(bytes_1[0])) << 24 | int(unsafe(bytes_1[1])) << 16 | int(unsafe(bytes_1[2])) << 8 | int(unsafe(bytes_1[3]))
    return int(0)
}
[export]
def h264mp4_probe_sample0_offset() : int {
    var input_15 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_8 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_7 : int = -1
    var frame_bytes_5 : uint = uint(uint(uint(uint(uint(0)))))
    var offset_9 : uint64 = uint64(uint64(uint64(uint64(uint64(0)))))
    c2da_reset_heap()
    mp4_8 = minimp4::MP4D_demux_tag()
    input_15.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_15.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_8))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_15))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_7 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_8))))))))
    if (int(track_index_7) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_8))))))
        return -1
    }
    offset_9 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_8))))))), uint(uint(track_index_7)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_5))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_8))))))
    return int(offset_9)
    return int(0)
}
[export]
def h264mp4_probe_dsi_word0() : int {
    var input_20 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_13 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_12 : int = -1
    var index_4 : int = 0
    var value_0 : int = 0
    c2da_reset_heap()
    mp4_13 = minimp4::MP4D_demux_tag()
    input_20.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_20.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_20))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_12 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))))))
    if (int(track_index_12) < 0 || unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_13.track)))[uint(track_index_12)])).dsi == null || uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_13.track)))[uint(track_index_12)])).dsi_bytes) < uint(uint(4))) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))))
        return -1
    }
    index_4 = 0
    while (int(index_4) < 4) {
        value_0 = int(int(int(int(value_0) << 8 | int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_13.track)))[uint(track_index_12)])).dsi)))[uint(index_4)]))))))
        var c2da_fresh11 : int = index_4
        index_4 = int(index_4) + 1
    }
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_13))))))
    return value_0
    return int(0)
}
[export]
def h264mp4_probe_sample0_idr_stage(var field_1 : int) : int {
    var input_27 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_20 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_19 : int = -1
    var track_length_size_6 : int = 0
    var prefix_bytes_6 : int = 0
    var max_sample_bytes_1 : int = 0
    var scratch_7 : uint8? = null
    var storage_3 : h264bsd::storage? = null
    var sample_length_6 : int = 0
    var decode_offset : int = 0
    var strm_1 : h264bsd::strmData_t = h264bsd::strmData_t()
    var nal_1 : h264bsd::nalUnit_t = h264bsd::nalUnit_t()
    var read_bytes_4 : uint = uint(uint(uint(uint(uint(0)))))
    var result_4 : uint = uint(uint(uint(uint(uint(0)))))
    var tmp_0 : uint = uint(uint(uint(uint(uint(0)))))
    var pps_id : uint = uint(uint(uint(uint(uint(0)))))
    var sps_id : uint = uint(uint(uint(uint(uint(0)))))
    var access_unit_boundary : uint = uint(uint(uint(uint(uint(0)))))
    c2da_reset_heap()
    mp4_20 = minimp4::MP4D_demux_tag()
    strm_1 = h264bsd::strmData_t()
    nal_1 = h264bsd::nalUnit_t()
    input_27.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_27.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_27))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_19 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))))
    if (int(track_index_19) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))
        return -3
    }
    track_length_size_6 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))), track_index_19, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    prefix_bytes_6 = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))), track_index_19)
    var sample_index_2 : int = 0
    sample_index_2 = 0
    while (int(sample_index_2) < int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_20.track)))[uint(track_index_19)])).sample_count)) {
        var frame_bytes_12 : uint = uint(uint(uint(uint(uint(0)))))
        var sample_offset : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))), uint(uint(track_index_19)), uint(uint(sample_index_2)), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_12))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
        var annexb_bytes_1 : int = sample_annexb_size(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(sample_offset), 1))))), int(frame_bytes_12), track_length_size_6)
        if (int(annexb_bytes_1) < 0) {
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))
            return -4
        }
        if (int(annexb_bytes_1) + int(prefix_bytes_6) > int(max_sample_bytes_1)) {
            max_sample_bytes_1 = int(annexb_bytes_1) + int(prefix_bytes_6)
        }
        var c2da_fresh13 : int = sample_index_2
        sample_index_2 = int(sample_index_2) + 1
    }
    scratch_7 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(max_sample_bytes_1))))))))))))))))
    storage_3 = unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(h264bsd::h264bsdAlloc()))))))))))))
    if (scratch_7 == null || storage_3 == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))
        return -5
    }
    if (h264bsd::h264bsdInit(storage_3, uint(0x0)) != uint(h264bsd::H264BSD_RDY)) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))
        return -6
    }
    var frame_bytes_13 : uint = uint(uint(uint(uint(uint(0)))))
    var sample_offset_0 : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))), uint(uint(track_index_19)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_13))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    sample_length_6 = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))), track_index_19, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(sample_offset_0), 1))))), int(frame_bytes_13), 1, scratch_7, max_sample_bytes_1, track_length_size_6)
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_20))))))
    if (int(sample_length_6) < 0) {
        return -7
    }
    while (int(decode_offset) < 665) {
        read_bytes_4 = uint(uint(uint(uint(uint(0)))))
        result_4 = uint(uint(uint(h264bsd::h264bsdDecode(storage_3, unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch_7))), int(decode_offset), 1))))), uint(uint(uint(int(sample_length_6)) - uint(int(decode_offset)))), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(read_bytes_4)))))))))
        if (uint(result_4) == uint(h264bsd::H264BSD_ERROR) || uint(result_4) == uint(h264bsd::H264BSD_PARAM_SET_ERROR) || uint(result_4) == uint(h264bsd::H264BSD_MEMALLOC_ERROR)) {
            return -10 - int(result_4)
        }
        if (uint64(uint(read_bytes_4)) == uint64(0) && uint(result_4) != uint(h264bsd::H264BSD_HDRS_RDY)) {
            return -20 - int(result_4)
        }
        decode_offset = int(decode_offset) + int(read_bytes_4)
    }
    if (uint64(int(field_1)) == uint64(0)) {
        return decode_offset
    }
    read_bytes_4 = uint(uint(uint(uint(uint(0)))))
    tmp_0 = uint(uint(uint(h264bsd::h264bsdExtractNalUnit(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch_7))), int(decode_offset), 1))))), uint(uint(uint(int(sample_length_6)) - uint(int(decode_offset)))), unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm_1))))), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(read_bytes_4)))))))))
    if (int(field_1) == 1) {
        return int(tmp_0)
    }
    if (int(field_1) == 2) {
        return int(read_bytes_4)
    }
    if (uint64(uint(tmp_0)) != uint64(0)) {
        return -30 - int(tmp_0)
    }
    tmp_0 = uint(uint(uint(h264bsd::h264bsdDecodeNalUnit(unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm_1))))), unsafe(unsafe(reinterpret<h264bsd::nalUnit_t?>(unsafe(addr(nal_1)))))))))
    if (int(field_1) == 3) {
        return int(tmp_0)
    }
    if (int(field_1) == 4) {
        return int(nal_1.nalUnitType)
    }
    if (int(field_1) == 5) {
        return int(nal_1.nalRefIdc)
    }
    if (uint64(uint(tmp_0)) != uint64(0)) {
        return -40 - int(tmp_0)
    }
    tmp_0 = uint(uint(uint(h264bsd::h264bsdCheckAccessUnitBoundary(unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm_1))))), unsafe(unsafe(reinterpret<h264bsd::nalUnit_t?>(unsafe(addr(nal_1))))), storage_3, unsafe(unsafe(reinterpret<uint?>(unsafe(addr(access_unit_boundary)))))))))
    if (int(field_1) == 10) {
        return int(tmp_0)
    }
    if (int(field_1) == 11) {
        return int(access_unit_boundary)
    }
    if (uint64(uint(tmp_0)) != uint64(0)) {
        return -50 - int(tmp_0)
    }
    if (int(field_1) == 12) {
        return int(h264bsd::h264bsdIsStartOfPicture(storage_3))
    }
    if (int(field_1) == 13) {
        return int(unsafe(*storage_3).pendingActivation)
    }
    if (int(field_1) == 14) {
        return int(c2da_bool_to_int(unsafe(uint64(intptr(unsafe(*storage_3).activeSps)) != uint64(0))))
    }
    if (int(field_1) == 15) {
        return int(c2da_bool_to_int(unsafe(uint64(intptr(unsafe(*storage_3).activePps)) != uint64(0))))
    }
    tmp_0 = uint(uint(uint(h264bsd::h264bsdCheckPpsId(unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm_1))))), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(pps_id)))))))))
    if (int(field_1) == 20) {
        return int(tmp_0)
    }
    if (int(field_1) == 21) {
        return int(pps_id)
    }
    if (uint64(uint(tmp_0)) != uint64(0)) {
        return -60 - int(tmp_0)
    }
    sps_id = uint(uint(uint(unsafe(*storage_3).activeSpsId)))
    tmp_0 = uint(uint(uint(h264bsd::h264bsdActivateParamSets(storage_3, uint(pps_id), uint(0x1)))))
    if (int(field_1) == 22) {
        return int(tmp_0)
    }
    if (int(field_1) == 23) {
        return int(sps_id)
    }
    if (int(field_1) == 24) {
        return int(unsafe(*storage_3).activeSpsId)
    }
    if (uint64(uint(tmp_0)) != uint64(0)) {
        return -70 - int(tmp_0)
    }
    tmp_0 = uint(uint(uint(h264bsd::h264bsdDecodeSliceHeader(unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm_1))))), unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))))), 1, 988))))), unsafe(*storage_3).activeSps, unsafe(*storage_3).activePps, unsafe(unsafe(reinterpret<h264bsd::nalUnit_t?>(unsafe(addr(nal_1)))))))))
    if (int(field_1) == 30) {
        return int(tmp_0)
    }
    if (int(field_1) == 31) {
        return int(unsafe(unsafe(unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))[1])).firstMbInSlice)
    }
    if (int(field_1) == 32) {
        return int(unsafe(unsafe(unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))[1])).sliceType)
    }
    if (int(field_1) == 33) {
        return int(unsafe(unsafe(unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))[1])).frameNum)
    }
    if (uint64(uint(tmp_0)) != uint64(0)) {
        return -80 - int(tmp_0)
    }
    unsafe(unsafe(unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))[0])) := unsafe(unsafe(unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))[1]))
    unsafe(*storage_3).validSliceInAccessUnit = uint(0x1)
    unsafe(unsafe(unsafe(unsafe(reinterpret<h264bsd::nalUnit_t?>(unsafe(addr(unsafe(*storage_3).prevNalUnit[0])))))[0])) := nal_1
    h264bsd::h264bsdComputeSliceGroupMap(storage_3, uint(unsafe(*unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))).sliceGroupChangeCycle))
    h264bsd::h264bsdInitRefPicList(unsafe(unsafe(reinterpret<h264bsd::dpbStorage_t?>(unsafe(addr(unsafe(*storage_3).dpb[0]))))))
    tmp_0 = uint(uint(uint(h264bsd::h264bsdReorderRefPicList(unsafe(unsafe(reinterpret<h264bsd::dpbStorage_t?>(unsafe(addr(unsafe(*storage_3).dpb[0]))))), unsafe(unsafe(reinterpret<h264bsd::refPicListReordering_t?>(unsafe(addr(unsafe(*unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))).refPicListReordering))))), uint(unsafe(*unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))).frameNum), uint(unsafe(*unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))).numRefIdxL0Active)))))
    if (int(field_1) == 40) {
        return int(tmp_0)
    }
    if (uint64(uint(tmp_0)) != uint64(0)) {
        return -90 - int(tmp_0)
    }
    if (uint64(h264bsd::h264bsdIsStartOfPicture(storage_3)) != uint64(0)) {
        unsafe(*unsafe(unsafe(reinterpret<h264bsd::image_t?>(unsafe(addr(unsafe(*storage_3).currImage[0])))))).data = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(h264bsd::h264bsdAllocateDpbImage(unsafe(unsafe(reinterpret<h264bsd::dpbStorage_t?>(unsafe(addr(unsafe(*storage_3).dpb[0]))))))))))))
    }
    tmp_0 = uint(uint(uint(h264bsd::h264bsdDecodeSliceData(unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm_1))))), storage_3, unsafe(unsafe(reinterpret<h264bsd::image_t?>(unsafe(addr(unsafe(*storage_3).currImage[0]))))), unsafe(unsafe(reinterpret<h264bsd::sliceHeader_t?>(unsafe(addr(unsafe(*storage_3).sliceHeader[0])))))))))
    if (int(field_1) == 50) {
        return int(tmp_0)
    }
    if (int(field_1) == 51) {
        return int(strm_1.strmBuffReadBits)
    }
    if (int(field_1) == 52) {
        return int(strm_1.bitPosInWord)
    }
    return -100
    return int(0)
}
[export]
def h264mp4_probe_annexb_word(var byte_index_0 : int) : int {
    var b0 : int = h264mp4_probe_annexb_byte(byte_index_0)
    var b1 : int = h264mp4_probe_annexb_byte(int(byte_index_0) + 1)
    var b2 : int = h264mp4_probe_annexb_byte(int(byte_index_0) + 2)
    var b3 : int = h264mp4_probe_annexb_byte(int(byte_index_0) + 3)
    if (int(b0) < 0 || int(b1) < 0 || int(b2) < 0 || int(b3) < 0) {
        return -1
    }
    return int(b0) << 24 | int(b1) << 16 | int(b2) << 8 | int(b3)
    return int(0)
}
[export]
def h264mp4_probe_width() : int {
    var summary_1 : c2da_module::DecodeSummary = c2da_module::DecodeSummary()
    c2da_reset_heap()
    if (uint64(decode_summary(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len), 1, unsafe(unsafe(reinterpret<c2da_module::DecodeSummary?>(unsafe(addr(summary_1))))))) == uint64(0)) {
        return -1
    }
    return summary_1.width
    return int(0)
}
[export]
def infer_length_size(var sample_0 : uint8 const?; var sample_bytes_0 : int) : int {
    var candidate : int = 0
    candidate = 4
    while (int(candidate) >= 1) {
        if (sample_annexb_size(sample_0, sample_bytes_0, candidate) >= 0) {
            return candidate
        }
        var c2da_fresh3 : int = candidate
        candidate = int(candidate) - 1
    }
    return 0
    return int(0)
}
[export]
def h264mp4_host_get_y_ptr() : int {
    return int(int(int64(intptr(host_picture))))
    return int(0)
}
[export]
def h264mp4_host_get_height() : int {
    return host_height
    return int(0)
}
[export]
def header_annexb_size(var mp4_1 : minimp4::MP4D_demux_tag const?; var track_index_0 : int) : int {
    var total_0 : int = 0
    var bytes_3 : int = 0
    var index_1 : int = 0
    var ptr : uint64 = uint64(uint64(uint64(0x0)))
    while (true) {
        ptr = uint64(uint64(minimp4::MP4D_read_sps(mp4_1, uint(uint(track_index_0)), index_1, unsafe(unsafe(reinterpret<int?>(unsafe(addr(bytes_3))))))))
        if (!(unsafe(uint64(unsafe(unsafe(reinterpret<uint64>(ptr)))) != uint64(0)))) {
            break
        }
        total_0 = int(total_0) + (4 + int(bytes_3))
        index_1 = int(index_1) + 1
    }
    index_1 = 0
    while (true) {
        ptr = uint64(uint64(minimp4::MP4D_read_pps(mp4_1, uint(uint(track_index_0)), index_1, unsafe(unsafe(reinterpret<int?>(unsafe(addr(bytes_3))))))))
        if (!(unsafe(uint64(unsafe(unsafe(reinterpret<uint64>(ptr)))) != uint64(0)))) {
            break
        }
        total_0 = int(total_0) + (4 + int(bytes_3))
        index_1 = int(index_1) + 1
    }
    return total_0
    return int(0)
}
[export]
def build_annexb_sample(var mp4_2 : minimp4::MP4D_demux_tag const?; var track_index_1 : int; var sample_1 : uint8 const?; var sample_bytes_1 : int; var include_headers : int; var scratch : uint8?; var scratch_capacity : int; var length_size_0 : int) : int {
    var out : int = 0
    var bytes_4 : int = 0
    var index_2 : int = 0
    var start_code : uint8 [4] = fixed_array<uint8>(uint8(0), uint8(0), uint8(0), uint8(uint8(0x1)))
    var offset_2 : int = 0
    var ptr_0 : uint64 = uint64(uint64(uint64(0x0)))
    if (uint64(include_headers) != uint64(0)) {
        while (true) {
            ptr_0 = uint64(uint64(minimp4::MP4D_read_sps(mp4_2, uint(uint(track_index_1)), index_2, unsafe(unsafe(reinterpret<int?>(unsafe(addr(bytes_4))))))))
            if (!(unsafe(uint64(unsafe(unsafe(reinterpret<uint64>(ptr_0)))) != uint64(0)))) {
                break
            }
            if (int(out) + 4 + int(bytes_4) > int(scratch_capacity)) {
                return -1
            }
            unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch))), int(out), 1)))))))), unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8 const?>(unsafe(addr(start_code[0])))))))), int(uint64(uint64(0x4)))))
            out = int(out) + 4
            unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch))), int(out), 1)))))))), unsafe(unsafe(reinterpret<void?>(ptr_0))), int(uint64(bytes_4))))
            out = int(out) + int(bytes_4)
            index_2 = int(index_2) + 1
        }
        index_2 = 0
        while (true) {
            ptr_0 = uint64(uint64(minimp4::MP4D_read_pps(mp4_2, uint(uint(track_index_1)), index_2, unsafe(unsafe(reinterpret<int?>(unsafe(addr(bytes_4))))))))
            if (!(unsafe(uint64(unsafe(unsafe(reinterpret<uint64>(ptr_0)))) != uint64(0)))) {
                break
            }
            if (int(out) + 4 + int(bytes_4) > int(scratch_capacity)) {
                return -1
            }
            unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch))), int(out), 1)))))))), unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8 const?>(unsafe(addr(start_code[0])))))))), int(uint64(uint64(0x4)))))
            out = int(out) + 4
            unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch))), int(out), 1)))))))), unsafe(unsafe(reinterpret<void?>(ptr_0))), int(uint64(bytes_4))))
            out = int(out) + int(bytes_4)
            index_2 = int(index_2) + 1
        }
    }
    while (int(offset_2) < int(sample_bytes_1)) {
        var nal_size_0 : int = 0
        var length_index_0 : int = 0
        if (int(sample_bytes_1) - int(offset_2) < int(length_size_0)) {
            return -1
        }
        length_index_0 = 0
        while (int(length_index_0) < int(length_size_0)) {
            nal_size_0 = int(int(int(int(nal_size_0) << 8 | int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(sample_1)))[int(offset_2) + int(length_index_0)]))))))
            var c2da_fresh5 : int = length_index_0
            length_index_0 = int(length_index_0) + 1
        }
        offset_2 = int(offset_2) + int(length_size_0)
        if (int(nal_size_0) < 0 || int(sample_bytes_1) - int(offset_2) < int(nal_size_0)) {
            return -1
        }
        if (int(out) + 4 + int(nal_size_0) > int(scratch_capacity)) {
            return -1
        }
        unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch))), int(out), 1)))))))), unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8 const?>(unsafe(addr(start_code[0])))))))), int(uint64(uint64(0x4)))))
        out = int(out) + 4
        unsafe(memcpy(unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch))), int(out), 1)))))))), unsafe(unsafe(reinterpret<void?>(intptr(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(sample_1))), int(offset_2), 1)))))))), int(uint64(nal_size_0))))
        out = int(out) + int(nal_size_0)
        offset_2 = int(offset_2) + int(nal_size_0)
    }
    return out
    return int(0)
}
[export]
def h264mp4_host_alloc(var size_0 : int) : int {
    var result_7 : uint64 = uint64(uint64(uint64(0x0)))
    if (int(size_0) <= 0) {
        return 0
    }
    result_7 = uint64(uint64(unsafe(c2da_malloc(uint64(uint64(size_0))))))
    return int(int(int64(result_7)))
    return int(0)
}
[export]
def h264mp4_host_load(var bytes_ptr : int; var bytes_len : int) : int {
    if (uint64(int(bytes_ptr)) == uint64(0) || int(bytes_len) <= 0) {
        return 0
    }
    host_bytes = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(int64(bytes_ptr)))))))
    host_length = bytes_len
    host_picture = null
    host_width = 0
    host_height = 0
    host_y_size = 0
    host_u_size = 0
    host_v_size = 0
    return 1
    return int(0)
}
[export]
def h264mp4_probe_annexb_byte(var byte_index : int) : int {
    var input_24 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_17 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_16 : int = -1
    var track_length_size_3 : int = 0
    var prefix_bytes_3 : int = 0
    var frame_bytes_9 : uint = uint(uint(uint(uint(uint(0)))))
    var offset_13 : uint64 = uint64(uint64(uint64(uint64(uint64(0)))))
    var scratch_4 : uint8? = null
    var sample_length_3 : int = 0
    var result_2 : int = -1
    if (int(byte_index) < 0) {
        return -1
    }
    c2da_reset_heap()
    input_24.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_24.length = int(sample_mp4_len)
    if (minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_24))))), int64(int64(sample_mp4_len))) != 1) {
        return -2
    }
    track_index_16 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))))))
    if (int(track_index_16) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))))
        return -3
    }
    track_length_size_3 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))))), track_index_16, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    prefix_bytes_3 = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))))), track_index_16)
    offset_13 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))))), uint(uint(track_index_16)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_9))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    scratch_4 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(frame_bytes_9) + uint64(prefix_bytes_3) + uint64(uint64(0x40)))))))))))))))))
    if (unsafe(uint64(intptr(scratch_4)) == uint64(0))) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))))
        return -4
    }
    sample_length_3 = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))))), track_index_16, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(offset_13), 1))))), int(frame_bytes_9), 1, scratch_4, int(frame_bytes_9) + int(prefix_bytes_3) + 64, track_length_size_3)
    if (int(sample_length_3) <= 0 || int(byte_index) >= int(sample_length_3)) {
        result_2 = -5
    } else {
        result_2 = int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(scratch_4)))[uint(byte_index)])))
    }
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_17))))))
    return result_2
    return int(0)
}
[export]
def decode_summary(var bytes_6 : uint8 const?; var length_1 : int; var frame_limit : int; var summary : c2da_module::DecodeSummary?) : int {
    var input_10 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_3 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_2 : int = -1
    var track_length_size : int = 0
    var prefix_bytes : int = 0
    var max_sample_bytes : int = 0
    var scratch_0 : uint8? = null
    var state_0 : c2da_module::DecoderState = c2da_module::DecoderState()
    var sample_index_0 : int = 0
    unsafe(*summary) = c2da_module::DecodeSummary()
    mp4_3 = minimp4::MP4D_demux_tag()
    input_10.bytes = unsafe(unsafe(reinterpret<uint8 const?>(bytes_6)))
    input_10.length = length_1
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_10))))), int64(int64(length_1)))) == uint64(0)) {
        return 0
    }
    track_index_2 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))))
    if (int(track_index_2) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
        return 0
    }
    track_length_size = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))), track_index_2, bytes_6, length_1)
    if (int(track_length_size) <= 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
        return 0
    }
    prefix_bytes = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))), track_index_2)
    sample_index_0 = 0
    while (int(sample_index_0) < int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_3.track)))[uint(track_index_2)])).sample_count)) {
        var frame_bytes_0 : uint = uint(uint(uint(uint(uint(0)))))
        var offset_4 : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))), uint(uint(track_index_2)), uint(uint(sample_index_0)), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_0))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
        var annexb_bytes : int = 0
        if (uint64(offset_4) + uint64(frame_bytes_0) > uint64(uint64(uint(length_1)))) {
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
            return 0
        }
        annexb_bytes = sample_annexb_size(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(bytes_6))), uint64(offset_4), 1))))), int(frame_bytes_0), track_length_size)
        if (int(annexb_bytes) < 0) {
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
            return 0
        }
        if (int(annexb_bytes) + int(prefix_bytes) > int(max_sample_bytes)) {
            max_sample_bytes = int(annexb_bytes) + int(prefix_bytes)
        }
        var c2da_fresh6 : int = sample_index_0
        sample_index_0 = int(sample_index_0) + 1
    }
    scratch_0 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(max_sample_bytes))))))))))))))))
    if (scratch_0 == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
        return 0
    }
    state_0 = c2da_module::DecoderState()
    state_0.storage = unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(h264bsd::h264bsdAlloc()))))))
    if (state_0.storage == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
        return 0
    }
    if (h264bsd::h264bsdInit(state_0.storage, uint(0x0)) != uint(h264bsd::H264BSD_RDY)) {
        h264bsd::h264bsdFree(state_0.storage)
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
        return 0
    }
    unsafe(*summary).combined_hash = uint(0x811c9dc5)
    sample_index_0 = 0
    while (int(sample_index_0) < int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_3.track)))[uint(track_index_2)])).sample_count)) {
        var frame_bytes_1 : uint = uint(uint(uint(uint(uint(0)))))
        var offset_5 : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))), uint(uint(track_index_2)), uint(uint(sample_index_0)), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_1))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
        var sample_length : int = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))), track_index_2, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(bytes_6))), uint64(offset_5), 1))))), int(frame_bytes_1), int(c2da_bool_to_int(uint64(int(sample_index_0)) == uint64(0))), scratch_0, max_sample_bytes, track_length_size)
        var picture_ready_0 : int = 0
        if (int(sample_length) < 0) {
            h264bsd::h264bsdShutdown(state_0.storage)
            h264bsd::h264bsdFree(state_0.storage)
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
            return 0
        }
        if (uint64(decode_access_unit(unsafe(unsafe(reinterpret<c2da_module::DecoderState?>(unsafe(addr(state_0))))), scratch_0, sample_length, unsafe(unsafe(reinterpret<int?>(unsafe(addr(picture_ready_0))))))) == uint64(0)) {
            h264bsd::h264bsdShutdown(state_0.storage)
            h264bsd::h264bsdFree(state_0.storage)
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
            return 0
        }
        if (uint64(picture_ready_0) != uint64(0)) {
            var picture_bytes : int = int(state_0.width) * int(state_0.height) * 3 / 2
            var frame_hash : uint = uint(uint(uint(fold_bytes(state_0.picture, picture_bytes))))
            if (uint64(int(unsafe(*summary).frame_count)) == uint64(0)) {
                unsafe(*summary).first_hash = uint(frame_hash)
                unsafe(*summary).width = state_0.width
                unsafe(*summary).height = state_0.height
            }
            unsafe(*summary).last_hash = uint(frame_hash)
            unsafe(*summary).combined_hash = uint(uint(unsafe(*summary).combined_hash) ^ uint(frame_hash) + uint(unsafe(*summary).frame_count) * 0x9e3779b9)
            unsafe(*summary).combined_hash = uint(rotl32(uint(unsafe(*summary).combined_hash), uint(0x7)))
            unsafe(*summary).combined_hash = uint(uint(unsafe(*summary).combined_hash) + 0x7f4a7c15)
            unsafe(*summary).frame_count = int(unsafe(*summary).frame_count) + 1
            if (int(frame_limit) > 0 && int(unsafe(*summary).frame_count) >= int(frame_limit)) {
                break
            }
        }
        var c2da_fresh7 : int = sample_index_0
        sample_index_0 = int(sample_index_0) + 1
    }
    unsafe(*summary).combined_hash = uint(uint(unsafe(*summary).combined_hash) ^ uint(unsafe(*summary).width))
    unsafe(*summary).combined_hash = uint(rotl32(uint(unsafe(*summary).combined_hash), uint(0x3)))
    unsafe(*summary).combined_hash = uint(uint(unsafe(*summary).combined_hash) ^ uint(unsafe(*summary).height))
    unsafe(*summary).combined_hash = uint(rotl32(uint(unsafe(*summary).combined_hash), uint(0x3)))
    unsafe(*summary).combined_hash = uint(uint(unsafe(*summary).combined_hash) ^ uint(unsafe(*summary).frame_count))
    h264bsd::h264bsdShutdown(state_0.storage)
    h264bsd::h264bsdFree(state_0.storage)
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_3))))))
    return int(c2da_bool_to_int(int(unsafe(*summary).frame_count) > 0))
    return int(0)
}
[export]
def h264mp4_probe_sample0_nal_at_offset(var nal_offset : int; var field_0 : int) : int {
    var input_26 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_19 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_18 : int = -1
    var track_length_size_5 : int = 0
    var prefix_bytes_5 : int = 0
    var frame_bytes_11 : uint = uint(uint(uint(uint(uint(0)))))
    var offset_15 : uint64 = uint64(uint64(uint64(uint64(uint64(0)))))
    var scratch_6 : uint8? = null
    var sample_length_5 : int = 0
    var read_bytes_3 : uint = uint(uint(uint(uint(uint(0)))))
    var strm_0 : h264bsd::strmData_t = h264bsd::strmData_t()
    var nal_0 : h264bsd::nalUnit_t = h264bsd::nalUnit_t()
    var extract_result : uint = uint(uint(uint(uint(uint(0)))))
    var nal_result : uint = uint(uint(uint(uint(uint(0)))))
    c2da_reset_heap()
    mp4_19 = minimp4::MP4D_demux_tag()
    strm_0 = h264bsd::strmData_t()
    nal_0 = h264bsd::nalUnit_t()
    input_26.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_26.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_26))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_18 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))))))
    if (int(track_index_18) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))))
        return -3
    }
    track_length_size_5 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))))), track_index_18, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    prefix_bytes_5 = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))))), track_index_18)
    offset_15 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))))), uint(uint(track_index_18)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_11))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    scratch_6 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(frame_bytes_11) + uint64(prefix_bytes_5) + uint64(uint64(0x40)))))))))))))))))
    if (scratch_6 == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))))
        return -4
    }
    sample_length_5 = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))))), track_index_18, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(offset_15), 1))))), int(frame_bytes_11), 1, scratch_6, int(frame_bytes_11) + int(prefix_bytes_5) + 64, track_length_size_5)
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_19))))))
    if (int(sample_length_5) < 0) {
        return -5
    }
    if (int(nal_offset) < 0 || int(nal_offset) >= int(sample_length_5)) {
        return -6
    }
    extract_result = uint(uint(uint(h264bsd::h264bsdExtractNalUnit(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch_6))), int(nal_offset), 1))))), uint(uint(uint(int(sample_length_5)) - uint(int(nal_offset)))), unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm_0))))), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(read_bytes_3)))))))))
    nal_result = uint(uint(uint(h264bsd::h264bsdDecodeNalUnit(unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm_0))))), unsafe(unsafe(reinterpret<h264bsd::nalUnit_t?>(unsafe(addr(nal_0)))))))))
    if (uint64(int(field_0)) == uint64(0)) {
        return sample_length_5
    } else {
        if (int(field_0) == 1) {
            return int(extract_result)
        } else {
            if (int(field_0) == 2) {
                return int(read_bytes_3)
            } else {
                if (int(field_0) == 3) {
                    return int(nal_result)
                } else {
                    if (int(field_0) == 4) {
                        return int(nal_0.nalUnitType)
                    } else {
                        if (int(field_0) == 5) {
                            return int(nal_0.nalRefIdc)
                        } else {
                            if (int(field_0) == 6) {
                                return int(strm_0.strmBuffReadBits)
                            } else {
                                if (int(field_0) == 7) {
                                    return int(strm_0.bitPosInWord)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return -100
    return int(0)
}
[export]
def h264mp4_probe_height() : int {
    var summary_2 : c2da_module::DecodeSummary = c2da_module::DecodeSummary()
    c2da_reset_heap()
    if (uint64(decode_summary(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len), 1, unsafe(unsafe(reinterpret<c2da_module::DecodeSummary?>(unsafe(addr(summary_2))))))) == uint64(0)) {
        return -1
    }
    return summary_2.height
    return int(0)
}
[export]
def h264mp4_probe_sample0_prefix() : int {
    var input_18 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_11 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_10 : int = -1
    var length_size_1 : int = 0
    var frame_bytes_6 : uint = uint(uint(uint(uint(uint(0)))))
    var offset_10 : uint64 = uint64(uint64(uint64(uint64(uint64(0)))))
    var index_3 : int = 0
    var prefix : int = 0
    c2da_reset_heap()
    mp4_11 = minimp4::MP4D_demux_tag()
    input_18.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_18.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_18))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_10 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))))))
    if (int(track_index_10) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))))
        return -1
    }
    length_size_1 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))))), track_index_10, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    offset_10 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))))), uint(uint(track_index_10)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_6))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    if (int(length_size_1) <= 0 || uint(frame_bytes_6) < uint(length_size_1)) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))))
        return -3
    }
    index_3 = 0
    while (int(index_3) < int(length_size_1)) {
        prefix = int(int(int(int(prefix) << 8 | int(unsafe(sample_mp4_bytes[uint(uint(uint64(offset_10)) + uint(uint64(index_3)))])))))
        var c2da_fresh10 : int = index_3
        index_3 = int(index_3) + 1
    }
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_11))))))
    return prefix
    return int(0)
}
[export]
def h264mp4_probe_decode_until_sample(var target_sample : int; var field_2 : int) : int {
    var input_28 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_21 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_20 : int = -1
    var track_length_size_7 : int = 0
    var prefix_bytes_7 : int = 0
    var max_sample_bytes_2 : int = 0
    var scratch_8 : uint8? = null
    var state_2 : c2da_module::DecoderState = c2da_module::DecoderState()
    var sample_index_3 : int = 0
    var last_sample_length : int = 0
    var last_ok : int = 0
    var last_picture_ready : int = 0
    var last_result : int = 0
    var last_read_bytes : int = 0
    var last_decode_offset : int = 0
    var frame_count : int = 0
    c2da_reset_heap()
    mp4_21 = minimp4::MP4D_demux_tag()
    state_2 = c2da_module::DecoderState()
    input_28.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_28.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_28))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_20 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))))
    if (int(track_index_20) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))
        return -3
    }
    track_length_size_7 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))), track_index_20, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    if (int(track_length_size_7) <= 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))
        return -4
    }
    prefix_bytes_7 = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))), track_index_20)
    sample_index_3 = 0
    while (int(sample_index_3) < int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_21.track)))[uint(track_index_20)])).sample_count)) {
        var frame_bytes_14 : uint = uint(uint(uint(uint(uint(0)))))
        var offset_16 : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))), uint(uint(track_index_20)), uint(uint(sample_index_3)), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_14))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
        var annexb_bytes_2 : int = sample_annexb_size(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(offset_16), 1))))), int(frame_bytes_14), track_length_size_7)
        if (int(annexb_bytes_2) < 0) {
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))
            return -5
        }
        if (int(annexb_bytes_2) + int(prefix_bytes_7) > int(max_sample_bytes_2)) {
            max_sample_bytes_2 = int(annexb_bytes_2) + int(prefix_bytes_7)
        }
        var c2da_fresh14 : int = sample_index_3
        sample_index_3 = int(sample_index_3) + 1
    }
    scratch_8 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(max_sample_bytes_2))))))))))))))))
    state_2.storage = unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(h264bsd::h264bsdAlloc()))))))
    if (scratch_8 == null || state_2.storage == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))
        return -6
    }
    if (h264bsd::h264bsdInit(state_2.storage, uint(0x0)) != uint(h264bsd::H264BSD_RDY)) {
        h264bsd::h264bsdFree(state_2.storage)
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))
        return -7
    }
    sample_index_3 = 0
    while (int(sample_index_3) < int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_21.track)))[uint(track_index_20)])).sample_count)) {
        var frame_bytes_15 : uint = uint(uint(uint(uint(uint(0)))))
        var offset_17 : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))), uint(uint(track_index_20)), uint(uint(sample_index_3)), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_15))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
        last_sample_length = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))), track_index_20, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(offset_17), 1))))), int(frame_bytes_15), int(c2da_bool_to_int(uint64(int(sample_index_3)) == uint64(0))), scratch_8, max_sample_bytes_2, track_length_size_7)
        if (int(last_sample_length) < 0) {
            h264bsd::h264bsdShutdown(state_2.storage)
            h264bsd::h264bsdFree(state_2.storage)
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))
            return -8
        }
        last_picture_ready = 0
        last_ok = 1
        last_decode_offset = 0
        while (int(last_decode_offset) < int(last_sample_length)) {
            var read_bytes_5 : uint = uint(uint(uint(uint(uint(0)))))
            var result_5 : uint = uint(uint(uint(h264bsd::h264bsdDecode(state_2.storage, unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(scratch_8))), int(last_decode_offset), 1))))), uint(uint(uint(int(last_sample_length)) - uint(int(last_decode_offset)))), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(read_bytes_5)))))))))
            last_result = int(result_5)
            last_read_bytes = int(read_bytes_5)
            if (uint(result_5) == uint(h264bsd::H264BSD_ERROR) || uint(result_5) == uint(h264bsd::H264BSD_PARAM_SET_ERROR) || uint(result_5) == uint(h264bsd::H264BSD_MEMALLOC_ERROR)) {
                last_ok = 0
                break
            }
            if (uint64(uint(read_bytes_5)) == uint64(0) && uint(result_5) != uint(h264bsd::H264BSD_HDRS_RDY)) {
                last_ok = 0
                break
            }
            last_decode_offset = int(last_decode_offset) + int(read_bytes_5)
            if (uint(result_5) == uint(h264bsd::H264BSD_HDRS_RDY)) {
                state_2.width = output_picture_width(state_2.storage)
                state_2.height = output_picture_height(state_2.storage)
            }
            if (uint(result_5) == uint(h264bsd::H264BSD_PIC_RDY)) {
                var pic_id_0 : uint = uint(uint(uint(uint(uint(0)))))
                var is_idr_pic_0 : uint = uint(uint(uint(uint(uint(0)))))
                var num_err_mbs_0 : uint = uint(uint(uint(uint(uint(0)))))
                state_2.picture = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(h264bsd::h264bsdNextOutputPicture(state_2.storage, unsafe(unsafe(reinterpret<uint?>(unsafe(addr(pic_id_0))))), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(is_idr_pic_0))))), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(num_err_mbs_0))))))))))))
                state_2.width = output_picture_width(state_2.storage)
                state_2.height = output_picture_height(state_2.storage)
                last_picture_ready = 1
            }
        }
        if (uint64(last_picture_ready) != uint64(0)) {
            frame_count = int(frame_count) + 1
        }
        if (int(sample_index_3) == int(target_sample) || uint64(last_ok) == uint64(0)) {
            var result_6 : int = 0
            if (uint64(int(field_2)) == uint64(0)) {
                result_6 = last_sample_length
            } else {
                if (int(field_2) == 1) {
                    result_6 = last_ok
                } else {
                    if (int(field_2) == 2) {
                        result_6 = last_picture_ready
                    } else {
                        if (int(field_2) == 3) {
                            result_6 = state_2.width
                        } else {
                            if (int(field_2) == 4) {
                                result_6 = state_2.height
                            } else {
                                if (int(field_2) == 5) {
                                    result_6 = frame_count
                                } else {
                                    if (int(field_2) == 6) {
                                        result_6 = last_result
                                    } else {
                                        if (int(field_2) == 7) {
                                            result_6 = last_read_bytes
                                        } else {
                                            result_6 = last_decode_offset
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            h264bsd::h264bsdShutdown(state_2.storage)
            h264bsd::h264bsdFree(state_2.storage)
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))
            return result_6
        }
        var c2da_fresh15 : int = sample_index_3
        sample_index_3 = int(sample_index_3) + 1
    }
    h264bsd::h264bsdShutdown(state_2.storage)
    h264bsd::h264bsdFree(state_2.storage)
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_21))))))
    return frame_count
    return int(0)
}
[export]
def rotl32(var value : uint; var shift : uint) : uint {
    return uint(value) << uint(shift) | uint(value) >> 0x20 - uint(shift)
    return uint(0)
}
[export]
def h264mp4_host_get_v_size() : int {
    return host_v_size
    return int(0)
}
[export]
def h264mp4_host_decode_frame(var frame_index_0 : int) : int {
    var picture_0 : uint8? = null
    var width_0 : int = 0
    var height_0 : int = 0
    if (host_bytes == null || int(host_length) <= 0 || int(frame_index_0) < 0) {
        return 0
    }
    if (uint64(decode_frame_yuv(host_bytes, host_length, frame_index_0, unsafe(unsafe(reinterpret<uint8??>(unsafe(addr(picture_0))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(width_0))))), unsafe(unsafe(reinterpret<int?>(unsafe(addr(height_0))))))) == uint64(0)) {
        return 0
    }
    host_picture = unsafe(unsafe(reinterpret<uint8?>(picture_0)))
    host_width = width_0
    host_height = height_0
    host_y_size = int(width_0) * int(height_0)
    host_u_size = int(host_y_size) / 4
    host_v_size = int(host_y_size) / 4
    return 1
    return int(0)
}
[export]
def h264mp4_probe_h264_stage(var field : int) : int {
    var input_25 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_18 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_17 : int = -1
    var track_length_size_4 : int = 0
    var prefix_bytes_4 : int = 0
    var frame_bytes_10 : uint = uint(uint(uint(uint(uint(0)))))
    var offset_14 : uint64 = uint64(uint64(uint64(uint64(uint64(0)))))
    var scratch_5 : uint8? = null
    var sample_length_4 : int = 0
    var strm : h264bsd::strmData_t = h264bsd::strmData_t()
    var nal : h264bsd::nalUnit_t = h264bsd::nalUnit_t()
    var sps : h264bsd::seqParamSet_t = h264bsd::seqParamSet_t()
    var read_bytes_2 : uint = uint(uint(uint(uint(uint(0)))))
    var tmp : uint = uint(uint(uint(uint(uint(0)))))
    var result_3 : int = -1
    c2da_reset_heap()
    input_25.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_25.length = int(sample_mp4_len)
    if (minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_25))))), int64(int64(sample_mp4_len))) != 1) {
        return -2
    }
    track_index_17 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))))
    if (int(track_index_17) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))
        return -3
    }
    track_length_size_4 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))), track_index_17, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    prefix_bytes_4 = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))), track_index_17)
    offset_14 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))), uint(uint(track_index_17)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_10))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    scratch_5 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(frame_bytes_10) + uint64(prefix_bytes_4) + uint64(uint64(0x40)))))))))))))))))
    if (unsafe(uint64(intptr(scratch_5)) == uint64(0))) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))
        return -4
    }
    sample_length_4 = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))), track_index_17, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(offset_14), 1))))), int(frame_bytes_10), 1, scratch_5, int(frame_bytes_10) + int(prefix_bytes_4) + 64, track_length_size_4)
    if (int(sample_length_4) <= 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))
        return -5
    }
    tmp = uint(uint(uint(h264bsd::h264bsdExtractNalUnit(scratch_5, uint(uint(sample_length_4)), unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm))))), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(read_bytes_2)))))))))
    if (uint64(int(field)) == uint64(0)) {
        result_3 = int(tmp)
    } else {
        if (int(field) == 1) {
            result_3 = int(read_bytes_2)
        } else {
            if (int(field) == 2) {
                result_3 = int(strm.strmBuffReadBits)
            } else {
                if (int(field) == 3) {
                    result_3 = int(strm.bitPosInWord)
                }
            }
        }
    }
    if (uint64(uint(tmp)) == uint64(0) && int(result_3) == -1) {
        tmp = uint(uint(uint(h264bsd::h264bsdDecodeNalUnit(unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm))))), unsafe(unsafe(reinterpret<h264bsd::nalUnit_t?>(unsafe(addr(nal)))))))))
        if (int(field) == 10) {
            result_3 = int(tmp)
        } else {
            if (int(field) == 11) {
                result_3 = int(nal.nalUnitType)
            } else {
                if (int(field) == 12) {
                    result_3 = int(nal.nalRefIdc)
                } else {
                    if (int(field) == 13) {
                        result_3 = int(strm.strmBuffReadBits)
                    } else {
                        if (int(field) == 14) {
                            result_3 = int(strm.bitPosInWord)
                        }
                    }
                }
            }
        }
        if (uint64(uint(tmp)) == uint64(0) && uint(nal.nalUnitType) == uint(h264bsd::NAL_SEQ_PARAM_SET) && int(result_3) == -1) {
            tmp = uint(uint(uint(h264bsd::h264bsdDecodeSeqParamSet(unsafe(unsafe(reinterpret<h264bsd::strmData_t?>(unsafe(addr(strm))))), unsafe(unsafe(reinterpret<h264bsd::seqParamSet_t?>(unsafe(addr(sps)))))))))
            if (int(field) == 20) {
                result_3 = int(tmp)
            } else {
                if (int(field) == 21) {
                    result_3 = int(sps.profileIdc)
                } else {
                    if (int(field) == 22) {
                        result_3 = int(sps.levelIdc)
                    } else {
                        if (int(field) == 23) {
                            result_3 = int(sps.seqParameterSetId)
                        } else {
                            if (int(field) == 24) {
                                result_3 = int(sps.picWidthInMbs)
                            } else {
                                if (int(field) == 25) {
                                    result_3 = int(sps.picHeightInMbs)
                                } else {
                                    if (int(field) == 26) {
                                        result_3 = int(sps.maxFrameNum)
                                    } else {
                                        if (int(field) == 27) {
                                            result_3 = int(sps.picOrderCntType)
                                        } else {
                                            if (int(field) == 28) {
                                                result_3 = int(strm.strmBuffReadBits)
                                            } else {
                                                if (int(field) == 29) {
                                                    result_3 = int(strm.bitPosInWord)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_18))))))
    return result_3
    return int(0)
}
[export]
def sample_annexb_size(var sample : uint8 const?; var sample_bytes : int; var length_size : int) : int {
    var offset_0 : int = 0
    var total : int = 0
    while (int(offset_0) < int(sample_bytes)) {
        var nal_size : int = 0
        var length_index : int = 0
        if (int(sample_bytes) - int(offset_0) < int(length_size)) {
            return -1
        }
        length_index = 0
        while (int(length_index) < int(length_size)) {
            nal_size = int(int(int(int(nal_size) << 8 | int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(sample)))[int(offset_0) + int(length_index)]))))))
            var c2da_fresh2 : int = length_index
            length_index = int(length_index) + 1
        }
        offset_0 = int(offset_0) + int(length_size)
        if (int(nal_size) < 0 || int(sample_bytes) - int(offset_0) < int(nal_size)) {
            return -1
        }
        total = int(total) + (4 + int(nal_size))
        offset_0 = int(offset_0) + int(nal_size)
    }
    return total
    return int(0)
}
[export]
def h264mp4_decode_hash(var frame_limit_0 : int) : int {
    var summary_0 : c2da_module::DecodeSummary = c2da_module::DecodeSummary()
    c2da_reset_heap()
    if (uint64(decode_summary(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len), frame_limit_0, unsafe(unsafe(reinterpret<c2da_module::DecodeSummary?>(unsafe(addr(summary_0))))))) == uint64(0)) {
        return -1
    }
    return int(summary_0.combined_hash)
    return int(0)
}
[export]
def h264mp4_host_get_width() : int {
    return host_width
    return int(0)
}
[export]
def h264mp4_probe_mp4d_open_track_count() : int {
    var input_9 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    input_9.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_9.length = int(sample_mp4_len)
    return c2da_probe_mp4d_open_track_count(@@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_9))))), int64(int64(sample_mp4_len)))
    return int(0)
}
[export]
def h264mp4_probe_sample_count() : int {
    var input_14 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_7 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_6 : int = -1
    c2da_reset_heap()
    mp4_7 = minimp4::MP4D_demux_tag()
    input_14.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_14.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_7))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_14))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_6 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_7))))))))
    if (int(track_index_6) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_7))))))
        return -1
    }
    return int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_7.track)))[uint(track_index_6)])).sample_count)
    return int(0)
}
[export]
def h264mp4_probe_minimp4_second_box_read_pos() : int {
    var input_7 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    input_7.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_7.length = int(sample_mp4_len)
    return c2da_probe_minimp4_second_box_read_pos(@@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_7))))), int64(int64(sample_mp4_len)))
    return int(0)
}
[export]
def h264mp4_probe_last_frame_hash(var frame_limit_2 : int) : int {
    var summary_5 : c2da_module::DecodeSummary = c2da_module::DecodeSummary()
    c2da_reset_heap()
    if (uint64(decode_summary(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len), frame_limit_2, unsafe(unsafe(reinterpret<c2da_module::DecodeSummary?>(unsafe(addr(summary_5))))))) == uint64(0)) {
        return -1
    }
    return int(summary_5.last_hash)
    return int(0)
}
[export]
def h264mp4_probe_sample0_size() : int {
    var input_13 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_6 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_5 : int = -1
    var frame_bytes_4 : uint = uint(uint(uint(uint(uint(0)))))
    var offset_8 : uint64 = uint64(uint64(uint64(uint64(uint64(0)))))
    c2da_reset_heap()
    mp4_6 = minimp4::MP4D_demux_tag()
    input_13.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_13.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_6))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_13))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_5 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_6))))))))
    if (int(track_index_5) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_6))))))
        return -1
    }
    offset_8 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_6))))))), uint(uint(track_index_5)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_4))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_6))))))
    if (uint64(offset_8) + uint64(frame_bytes_4) > uint64(sample_mp4_len)) {
        return -3
    }
    return int(frame_bytes_4)
    return int(0)
}
[export]
def h264mp4_probe_minimp4_first_box_name() : int {
    var input_3 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    input_3.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_3.length = int(sample_mp4_len)
    return c2da_probe_minimp4_first_box_name(@@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_3))))), int64(int64(sample_mp4_len)))
    return int(0)
}
[export]
def h264mp4_probe_minimp4_read4() : int {
    var input_2 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    input_2.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_2.length = int(sample_mp4_len)
    return c2da_probe_minimp4_read4(@@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_2))))), int64(int64(sample_mp4_len)))
    return int(0)
}
[export]
def find_avc_track(var mp4 : minimp4::MP4D_demux_tag const?) : int {
    var index_0 : uint = uint(uint(uint(uint(uint(0)))))
    index_0 = uint(uint(uint(uint(uint(0)))))
    while (uint(index_0) < uint(unsafe(*mp4).track_count)) {
        var track : minimp4::MP4D_track_t const? = unsafe(unsafe(reinterpret<minimp4::MP4D_track_t const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t const?>(unsafe(reinterpret<minimp4::MP4D_track_t const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(*mp4).track))), uint(index_0), 120))))))))))))))))
        if (uint(unsafe(*track).handler_type) == uint(uint(1986618469)) && uint(unsafe(*track).object_type_indication) == uint(uint(33))) {
            return int(index_0)
        }
        var c2da_fresh1 : uint = uint(uint(index_0))
        index_0 = uint(uint(uint(uint(index_0) + uint(1))))
    }
    return -1
    return int(0)
}
[export]
def h264mp4_probe_length_size() : int {
    var input_16 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_9 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_8 : int = -1
    c2da_reset_heap()
    mp4_9 = minimp4::MP4D_demux_tag()
    input_16.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_16.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_9))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_16))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_8 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_9))))))))
    if (int(track_index_8) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_9))))))
        return -1
    }
    return detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_9))))))), track_index_8, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    return int(0)
}
[export]
def h264mp4_probe_memory_read_status() : int {
    var input_0 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var bytes_0 : uint8 [4] = fixed_array<uint8>(uint8(0), uint8(0), uint8(0), uint8(0))
    input_0.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_0.length = int(sample_mp4_len)
    unsafe(bytes_0[0]) = uint8(uint8(uint8(0xff)))
    unsafe(bytes_0[1]) = uint8(uint8(uint8(0xff)))
    unsafe(bytes_0[2]) = uint8(uint8(uint8(0xff)))
    unsafe(bytes_0[3]) = uint8(uint8(uint8(0xff)))
    return memory_read_callback(int64(int64(int64(0))), intptr(unsafe(reinterpret<uint8?>(unsafe(addr(bytes_0[0]))))), uint64(uint64(uint64(0x4))), intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_0))))))
    return int(0)
}
[export]
def h264mp4_probe_first_frame_hash() : int {
    var summary_4 : c2da_module::DecodeSummary = c2da_module::DecodeSummary()
    c2da_reset_heap()
    if (uint64(decode_summary(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len), 1, unsafe(unsafe(reinterpret<c2da_module::DecodeSummary?>(unsafe(addr(summary_4))))))) == uint64(0)) {
        return -1
    }
    return int(summary_4.first_hash)
    return int(0)
}
[export]
def h264mp4_probe_dsi_bytes() : int {
    var input_19 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_12 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_11 : int = -1
    c2da_reset_heap()
    mp4_12 = minimp4::MP4D_demux_tag()
    input_19.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_19.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_12))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_19))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_11 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_12))))))))
    if (int(track_index_11) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_12))))))
        return -1
    }
    return int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_12.track)))[uint(track_index_11)])).dsi_bytes)
    return int(0)
}
[export]
def detect_track_length_size(var mp4_0 : minimp4::MP4D_demux_tag const?; var track_index : int; var bytes_2 : uint8 const?; var total_bytes : int) : int {
    var sample_index : uint = uint(uint(uint(uint(uint(0)))))
    sample_index = uint(uint(uint(uint(uint(0)))))
    while (uint(sample_index) < uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(unsafe(*mp4_0).track)))[uint(track_index)])).sample_count)) {
        var frame_bytes : uint = uint(uint(uint(uint(uint(0)))))
        var offset_1 : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(mp4_0, uint(uint(track_index)), uint(sample_index), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
        if (uint64(uint(frame_bytes)) == uint64(0)) {
            continue
        }
        if (uint64(offset_1) + uint64(frame_bytes) > uint64(uint64(uint(total_bytes)))) {
            return 0
        }
        return infer_length_size(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(bytes_2))), uint64(offset_1), 1))))), int(frame_bytes))
        var c2da_fresh4 : uint = uint(uint(sample_index))
        sample_index = uint(uint(uint(uint(sample_index) + uint(1))))
    }
    return 0
    return int(0)
}
[export]
def output_picture_width(var storage : h264bsd::storage?) : int {
    return int(h264bsd::h264bsdPicWidth(storage)) * 16
    return int(0)
}
[export]
def h264mp4_probe_first_decode_bytes() : int {
    var input_23 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_16 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_15 : int = -1
    var track_length_size_2 : int = 0
    var prefix_bytes_2 : int = 0
    var frame_bytes_8 : uint = uint(uint(uint(uint(uint(0)))))
    var offset_12 : uint64 = uint64(uint64(uint64(uint64(uint64(0)))))
    var storage_2 : h264bsd::storage? = null
    var scratch_3 : uint8? = null
    var sample_length_2 : int = 0
    var read_bytes_1 : uint = uint(uint(uint(uint(uint(0)))))
    c2da_reset_heap()
    input_23.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_23.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_23))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_15 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))))
    if (int(track_index_15) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))
        return -3
    }
    track_length_size_2 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))), track_index_15, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    prefix_bytes_2 = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))), track_index_15)
    offset_12 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))), uint(uint(track_index_15)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_8))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    scratch_3 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(frame_bytes_8) + uint64(prefix_bytes_2) + uint64(uint64(0x40)))))))))))))))))
    storage_2 = unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(h264bsd::h264bsdAlloc()))))))))))))
    if (scratch_3 == null || storage_2 == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))
        return -4
    }
    if (h264bsd::h264bsdInit(storage_2, uint(0x0)) != uint(h264bsd::H264BSD_RDY)) {
        h264bsd::h264bsdFree(storage_2)
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))
        return -5
    }
    sample_length_2 = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))), track_index_15, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(offset_12), 1))))), int(frame_bytes_8), 1, scratch_3, int(frame_bytes_8) + int(prefix_bytes_2) + 64, track_length_size_2)
    if (int(sample_length_2) <= 0) {
        h264bsd::h264bsdShutdown(storage_2)
        h264bsd::h264bsdFree(storage_2)
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))
        return -6
    }
    h264bsd::h264bsdDecode(storage_2, scratch_3, uint(uint(sample_length_2)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(read_bytes_1))))))
    h264bsd::h264bsdShutdown(storage_2)
    h264bsd::h264bsdFree(storage_2)
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_16))))))
    return int(read_bytes_1)
    return int(0)
}
[export]
def h264mp4_host_reset() : int {
    c2da_reset_heap()
    host_bytes = null
    host_length = 0
    host_picture = null
    host_width = 0
    host_height = 0
    host_y_size = 0
    host_u_size = 0
    host_v_size = 0
    return 1
    return int(0)
}
[export]
def h264mp4_probe_first_decode_result() : int {
    var input_22 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_15 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_14 : int = -1
    var track_length_size_1 : int = 0
    var prefix_bytes_1 : int = 0
    var frame_bytes_7 : uint = uint(uint(uint(uint(uint(0)))))
    var offset_11 : uint64 = uint64(uint64(uint64(uint64(uint64(0)))))
    var storage_1 : h264bsd::storage? = null
    var scratch_2 : uint8? = null
    var sample_length_1 : int = 0
    var read_bytes_0 : uint = uint(uint(uint(uint(uint(0)))))
    var result_1 : uint = uint(uint(uint(uint(uint(0)))))
    c2da_reset_heap()
    input_22.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_22.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_22))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_14 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))))
    if (int(track_index_14) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))
        return -3
    }
    track_length_size_1 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))), track_index_14, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len))
    prefix_bytes_1 = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))), track_index_14)
    offset_11 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))), uint(uint(track_index_14)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_7))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
    scratch_2 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(frame_bytes_7) + uint64(prefix_bytes_1) + uint64(uint64(0x40)))))))))))))))))
    storage_1 = unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(h264bsd::h264bsdAlloc()))))))))))))
    if (scratch_2 == null || storage_1 == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))
        return -4
    }
    if (h264bsd::h264bsdInit(storage_1, uint(0x0)) != uint(h264bsd::H264BSD_RDY)) {
        h264bsd::h264bsdFree(storage_1)
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))
        return -5
    }
    sample_length_1 = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))), track_index_14, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))))))), uint64(offset_11), 1))))), int(frame_bytes_7), 1, scratch_2, int(frame_bytes_7) + int(prefix_bytes_1) + 64, track_length_size_1)
    if (int(sample_length_1) <= 0) {
        h264bsd::h264bsdShutdown(storage_1)
        h264bsd::h264bsdFree(storage_1)
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))
        return -6
    }
    result_1 = uint(uint(uint(h264bsd::h264bsdDecode(storage_1, scratch_2, uint(uint(sample_length_1)), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(read_bytes_0)))))))))
    h264bsd::h264bsdShutdown(storage_1)
    h264bsd::h264bsdFree(storage_1)
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_15))))))
    return int(result_1)
    return int(0)
}
[export]
def h264mp4_host_get_y_size() : int {
    return host_y_size
    return int(0)
}
[export]
def fold_bytes(var bytes : uint8 const?; var length : int) : uint {
    var hash : uint = uint(uint(uint(0x811c9dc5)))
    var index : int = 0
    index = 0
    while (int(index) < int(length)) {
        hash = uint(uint(uint(uint(hash) ^ uint(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8 const?>(bytes)))[uint(index)]))))))
        hash = uint(uint(uint(uint(hash) * 0x1000193)))
        hash = uint(uint(uint(rotl32(uint(hash), uint(0x5)))))
        var c2da_fresh0 : int = index
        index = int(index) + 1
    }
    return hash
    return uint(0)
}
[export]
def h264mp4_probe_mp4d_open_read_pos() : int {
    var input_8 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    input_8.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_8.length = int(sample_mp4_len)
    return c2da_probe_mp4d_open_read_pos(@@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_8))))), int64(int64(sample_mp4_len)))
    return int(0)
}
[export]
def h264mp4_host_get_u_size() : int {
    return host_u_size
    return int(0)
}
[export]
def decode_frame_yuv(var bytes_7 : uint8 const?; var length_2 : int; var frame_index : int; var picture : uint8??; var width : int?; var height : int?) : int {
    var input_11 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_4 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_3 : int = -1
    var track_length_size_0 : int = 0
    var prefix_bytes_0 : int = 0
    var max_sample_bytes_0 : int = 0
    var scratch_1 : uint8? = null
    var state_1 : c2da_module::DecoderState = c2da_module::DecoderState()
    var sample_index_1 : int = 0
    var picture_index : int = 0
    mp4_4 = minimp4::MP4D_demux_tag()
    input_11.bytes = unsafe(unsafe(reinterpret<uint8 const?>(bytes_7)))
    input_11.length = length_2
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_11))))), int64(int64(length_2)))) == uint64(0)) {
        return 0
    }
    track_index_3 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))))
    if (int(track_index_3) < 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
        return 0
    }
    track_length_size_0 = detect_track_length_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))), track_index_3, bytes_7, length_2)
    if (int(track_length_size_0) <= 0) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
        return 0
    }
    prefix_bytes_0 = header_annexb_size(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))), track_index_3)
    sample_index_1 = 0
    while (int(sample_index_1) < int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_4.track)))[uint(track_index_3)])).sample_count)) {
        var frame_bytes_2 : uint = uint(uint(uint(uint(uint(0)))))
        var offset_6 : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))), uint(uint(track_index_3)), uint(uint(sample_index_1)), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_2))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
        var annexb_bytes_0 : int = sample_annexb_size(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(bytes_7))), uint64(offset_6), 1))))), int(frame_bytes_2), track_length_size_0)
        if (int(annexb_bytes_0) < 0) {
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
            return 0
        }
        if (int(annexb_bytes_0) + int(prefix_bytes_0) > int(max_sample_bytes_0)) {
            max_sample_bytes_0 = int(annexb_bytes_0) + int(prefix_bytes_0)
        }
        var c2da_fresh8 : int = sample_index_1
        sample_index_1 = int(sample_index_1) + 1
    }
    scratch_1 = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(c2da_malloc(uint64(uint64(max_sample_bytes_0))))))))))))))))
    if (scratch_1 == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
        return 0
    }
    state_1 = c2da_module::DecoderState()
    state_1.storage = unsafe(unsafe(reinterpret<h264bsd::storage?>(unsafe(unsafe(reinterpret<h264bsd::storage?>(h264bsd::h264bsdAlloc()))))))
    if (state_1.storage == null) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
        return 0
    }
    if (h264bsd::h264bsdInit(state_1.storage, uint(0x0)) != uint(h264bsd::H264BSD_RDY)) {
        h264bsd::h264bsdFree(state_1.storage)
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
        return 0
    }
    sample_index_1 = 0
    while (int(sample_index_1) < int(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_4.track)))[uint(track_index_3)])).sample_count)) {
        var frame_bytes_3 : uint = uint(uint(uint(uint(uint(0)))))
        var offset_7 : uint64 = uint64(uint64(uint64(minimp4::MP4D_frame_offset(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))), uint(uint(track_index_3)), uint(uint(sample_index_1)), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(frame_bytes_3))))), unsafe(unsafe(reinterpret<uint?>(null))), unsafe(unsafe(reinterpret<uint?>(null)))))))
        var sample_length_0 : int = build_annexb_sample(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))), track_index_3, unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(bytes_7))), uint64(offset_7), 1))))), int(frame_bytes_3), int(c2da_bool_to_int(uint64(int(sample_index_1)) == uint64(0))), scratch_1, max_sample_bytes_0, track_length_size_0)
        var picture_ready_1 : int = 0
        if (int(sample_length_0) < 0) {
            h264bsd::h264bsdShutdown(state_1.storage)
            h264bsd::h264bsdFree(state_1.storage)
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
            return 0
        }
        if (uint64(decode_access_unit(unsafe(unsafe(reinterpret<c2da_module::DecoderState?>(unsafe(addr(state_1))))), scratch_1, sample_length_0, unsafe(unsafe(reinterpret<int?>(unsafe(addr(picture_ready_1))))))) == uint64(0)) {
            h264bsd::h264bsdShutdown(state_1.storage)
            h264bsd::h264bsdFree(state_1.storage)
            minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
            return 0
        }
        if (uint64(picture_ready_1) != uint64(0)) {
            if (int(picture_index) == int(frame_index)) {
                *picture = unsafe(unsafe(reinterpret<uint8?>(state_1.picture)))
                *width = state_1.width
                *height = state_1.height
                h264bsd::h264bsdShutdown(state_1.storage)
                h264bsd::h264bsdFree(state_1.storage)
                minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
                return 1
            }
            picture_index = int(picture_index) + 1
        }
        var c2da_fresh9 : int = sample_index_1
        sample_index_1 = int(sample_index_1) + 1
    }
    h264bsd::h264bsdShutdown(state_1.storage)
    h264bsd::h264bsdFree(state_1.storage)
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_4))))))
    return 0
    return int(0)
}
[export]
def h264mp4_probe_minimp4_first_box_eof() : int {
    var input_5 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    input_5.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_5.length = int(sample_mp4_len)
    return c2da_probe_minimp4_first_box_eof(@@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_5))))), int64(int64(sample_mp4_len)))
    return int(0)
}
[export]
def h264mp4_probe_frame_count(var frame_limit_1 : int) : int {
    var summary_3 : c2da_module::DecodeSummary = c2da_module::DecodeSummary()
    c2da_reset_heap()
    if (uint64(decode_summary(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))), int(sample_mp4_len), frame_limit_1, unsafe(unsafe(reinterpret<c2da_module::DecodeSummary?>(unsafe(addr(summary_3))))))) == uint64(0)) {
        return -1
    }
    return summary_3.frame_count
    return int(0)
}
[export]
def h264mp4_host_get_u_ptr() : int {
    if (host_picture == null) {
        return 0
    }
    return int(int(int64(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(host_picture))), int(host_y_size), 1))))))))
    return int(0)
}
[export]
def h264mp4_host_get_v_ptr() : int {
    if (host_picture == null) {
        return 0
    }
    return int(int(int64(intptr(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(unsafe(unsafe(reinterpret<uint8?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(host_picture))), int(host_y_size), 1)))))))), int(host_u_size), 1))))))))
    return int(0)
}
[export]
def h264mp4_probe_track_index() : int {
    var input_12 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_5 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_4 : int = -1
    c2da_reset_heap()
    mp4_5 = minimp4::MP4D_demux_tag()
    input_12.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_12.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_5))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_12))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_4 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_5))))))))
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_5))))))
    return track_index_4
    return int(0)
}
[export]
def h264mp4_probe_dsi_word1() : int {
    var input_21 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    var mp4_14 : minimp4::MP4D_demux_tag = minimp4::MP4D_demux_tag()
    var track_index_13 : int = -1
    var index_5 : int = 0
    var value_1 : int = 0
    c2da_reset_heap()
    mp4_14 = minimp4::MP4D_demux_tag()
    input_21.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_21.length = int(sample_mp4_len)
    if (uint64(minimp4::MP4D_open(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))), @@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_21))))), int64(int64(sample_mp4_len)))) == uint64(0)) {
        return -2
    }
    track_index_13 = find_avc_track(unsafe(reinterpret<minimp4::MP4D_demux_tag const?>(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))))))
    if (int(track_index_13) < 0 || unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_14.track)))[uint(track_index_13)])).dsi == null || uint(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_14.track)))[uint(track_index_13)])).dsi_bytes) < uint(uint(8))) {
        minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))))
        return -1
    }
    index_5 = 4
    while (int(index_5) < 8) {
        value_1 = int(int(int(int(value_1) << 8 | int(unsafe(unsafe(unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(unsafe(unsafe(reinterpret<minimp4::MP4D_track_t?>(mp4_14.track)))[uint(track_index_13)])).dsi)))[uint(index_5)]))))))
        var c2da_fresh12 : int = index_5
        index_5 = int(index_5) + 1
    }
    minimp4::MP4D_close(unsafe(unsafe(reinterpret<minimp4::MP4D_demux_tag?>(unsafe(addr(mp4_14))))))
    return value_1
    return int(0)
}
[export]
def decode_access_unit(var state : c2da_module::DecoderState?; var bytes_5 : uint8 const?; var length_0 : int; var picture_ready : int?) : int {
    var offset_3 : int = 0
    *picture_ready = 0
    while (int(offset_3) < int(length_0)) {
        var read_bytes : uint = uint(uint(uint(uint(uint(0)))))
        var result_0 : uint = uint(uint(uint(h264bsd::h264bsdDecode(unsafe(*state).storage, unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(i_das_ptr_add(unsafe(unsafe(reinterpret<void?>(bytes_5))), int(offset_3), 1)))))))), uint(uint(uint(int(length_0)) - uint(int(offset_3)))), uint(0x0), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(read_bytes)))))))))
        if (uint(result_0) == uint(h264bsd::H264BSD_ERROR) || uint(result_0) == uint(h264bsd::H264BSD_PARAM_SET_ERROR) || uint(result_0) == uint(h264bsd::H264BSD_MEMALLOC_ERROR)) {
            return 0
        }
        if (uint64(uint(read_bytes)) == uint64(0) && uint(result_0) != uint(h264bsd::H264BSD_HDRS_RDY)) {
            return 0
        }
        offset_3 = int(offset_3) + int(read_bytes)
        if (uint(result_0) == uint(h264bsd::H264BSD_HDRS_RDY)) {
            unsafe(*state).width = output_picture_width(unsafe(*state).storage)
            unsafe(*state).height = output_picture_height(unsafe(*state).storage)
        }
        if (uint(result_0) == uint(h264bsd::H264BSD_PIC_RDY)) {
            var pic_id : uint = uint(uint(uint(uint(uint(0)))))
            var is_idr_pic : uint = uint(uint(uint(uint(uint(0)))))
            var num_err_mbs : uint = uint(uint(uint(uint(uint(0)))))
            unsafe(*state).picture = unsafe(unsafe(reinterpret<uint8?>(unsafe(unsafe(reinterpret<uint8?>(h264bsd::h264bsdNextOutputPicture(unsafe(*state).storage, unsafe(unsafe(reinterpret<uint?>(unsafe(addr(pic_id))))), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(is_idr_pic))))), unsafe(unsafe(reinterpret<uint?>(unsafe(addr(num_err_mbs))))))))))))
            unsafe(*state).width = output_picture_width(unsafe(*state).storage)
            unsafe(*state).height = output_picture_height(unsafe(*state).storage)
            *picture_ready = 1
        }
    }
    return 1
    return int(0)
}
[export]
def h264mp4_probe_minimp4_first_box_read_pos() : int {
    var input_4 : c2da_module::MemoryInput = c2da_module::MemoryInput()
    input_4.bytes = unsafe(unsafe(reinterpret<uint8 const?>(unsafe(unsafe(reinterpret<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))))))))
    input_4.length = int(sample_mp4_len)
    return c2da_probe_minimp4_first_box_read_pos(@@memory_read_callback, intptr(unsafe(reinterpret<c2da_module::MemoryInput?>(unsafe(addr(input_4))))), int64(int64(sample_mp4_len)))
    return int(0)
}