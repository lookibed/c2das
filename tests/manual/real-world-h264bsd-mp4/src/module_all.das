options gen2


typedef size_t = uint64
struct HeapHeader {
    size : size_t
}
var heap : array<uint8>

var heap_offset : size_t = cast<size_t>(8)

[export]
def shim_reset_heap() {
    heap_offset = uint64(cast<size_t>(8))
    heap_offset
}
[export]
def malloc(var size : size_t) : uint64 {
    var aligned_header : size_t const = 4 + uint64(0x7) & ~cast<size_t>(0x7)
    var aligned_size : size_t const = size + cast<size_t>(0x7) & ~cast<size_t>(0x7)
    var total : size_t const = aligned_header + aligned_size
    var header : HeapHeader? = null
    if (heap_offset + total > 4) {
        return null
    }
    header = unsafe(reinterpret<HeapHeader?>(unsafe(unsafe(addr(heap[0])) + heap_offset)))
    header
    header.size = uint64(size)
    header.size
    heap_offset = uint64(heap_offset + total)
    heap_offset
    return unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(reinterpret<uint8?>(header)) + aligned_header))))
}
[export]
def free(var ptr : uint64) {
    ptr
}
[export]
def realloc(var ptr_0 : uint64; var size_0 : size_t) : uint64 {
    var result_0 : uint64 = malloc(size_0)
    var old_size : size_t = cast<size_t>(0)
    var copy_size : size_t = cast<size_t>(0)
    var i : size_t = cast<size_t>(0)
    var aligned_header_0 : size_t const = 4 + uint64(0x7) & ~cast<size_t>(0x7)
    if (result_0 == null) {
        return null
    }
    if (ptr_0 != null) {
        var dst : uint8? = unsafe(reinterpret<uint8?>(result_0))
        var src : uint8 const? = unsafe(reinterpret<uint8 const?>(ptr_0))
        var header_0 : HeapHeader const? = unsafe(reinterpret<HeapHeader const?>(unsafe(src - aligned_header_0)))
        old_size = uint64(header_0.size)
        old_size
        var c2da_fresh0_shim : int = 0
        if (old_size < size_0) {
            c2da_fresh0_shim = old_size
        } else {
            c2da_fresh0_shim = size_0
        }
        copy_size = uint64(c2da_fresh0_shim)
        copy_size
        i = uint64(cast<size_t>(0))
        i
        while (i < copy_size) {
            unsafe(dst[i]) = uint8(unsafe(src[i]))
            unsafe(dst[i])
            i = i + 1
        }
    }
    return result_0
}
[export]
def calloc(var count : size_t; var size_1 : size_t) : uint64 {
    var total_0 : size_t = count * size_1
    var result_1 : uint64 = malloc(total_0)
    var i_0 : size_t = cast<size_t>(0)
    if (result_1 == null) {
        return null
    }
    i_0 = uint64(cast<size_t>(0))
    i_0
    while (i_0 < total_0) {
        unsafe(unsafe(reinterpret<uint8?>(result_1))[i_0]) = uint8(uint8(0))
        unsafe(unsafe(reinterpret<uint8?>(result_1))[i_0])
        i_0 = i_0 + 1
    }
    return result_1
}
[export]
def memset(var dest : uint64; var value : int; var count_0 : size_t) : uint64 {
    var bytes : uint8? = unsafe(reinterpret<uint8?>(dest))
    var i_1 : size_t = cast<size_t>(0)
    i_1 = uint64(cast<size_t>(0))
    i_1
    while (i_1 < count_0) {
        unsafe(bytes[i_1]) = uint8(uint8(value))
        unsafe(bytes[i_1])
        i_1 = i_1 + 1
    }
    return dest
}
[export]
def memcpy(var dest_0 : uint64; var src_0 : uint64; var count_1 : size_t) : uint64 {
    var out : uint8? = unsafe(reinterpret<uint8?>(dest_0))
    var in_0 : uint8 const? = unsafe(reinterpret<uint8 const?>(src_0))
    var i_2 : size_t = cast<size_t>(0)
    i_2 = uint64(cast<size_t>(0))
    i_2
    while (i_2 < count_1) {
        unsafe(out[i_2]) = uint8(unsafe(in_0[i_2]))
        unsafe(out[i_2])
        i_2 = i_2 + 1
    }
    return dest_0
}
[export]
def memmove(var dest_1 : uint64; var src_1 : uint64; var count_2 : size_t) : uint64 {
    var out_0 : uint8? = unsafe(reinterpret<uint8?>(dest_1))
    var in_1 : uint8 const? = unsafe(reinterpret<uint8 const?>(src_1))
    var i_3 : size_t = cast<size_t>(0)
    if (out_0 == unsafe(unsafe(reinterpret<uint8?>(in_1))) || count_2 == cast<size_t>(0)) {
        return dest_1
    }
    if (out_0 < unsafe(unsafe(reinterpret<uint8?>(in_1)))) {
        i_3 = uint64(cast<size_t>(0))
        i_3
        while (i_3 < count_2) {
            unsafe(out_0[i_3]) = uint8(unsafe(in_1[i_3]))
            unsafe(out_0[i_3])
            i_3 = i_3 + 1
        }
    } else {
        i_3 = uint64(count_2)
        i_3
        while (i_3 > cast<size_t>(0)) {
            unsafe(out_0[i_3 - cast<size_t>(1)]) = uint8(unsafe(in_1[i_3 - cast<size_t>(1)]))
            unsafe(out_0[i_3 - cast<size_t>(1)])
            i_3 = i_3 - 1
        }
    }
    return dest_1
}
[export]
def memcmp(var lhs : uint64; var rhs : uint64; var count_3 : size_t) : int {
    var left : uint8 const? = unsafe(reinterpret<uint8 const?>(lhs))
    var right : uint8 const? = unsafe(reinterpret<uint8 const?>(rhs))
    var i_4 : size_t = cast<size_t>(0)
    i_4 = uint64(cast<size_t>(0))
    i_4
    while (i_4 < count_3) {
        if (int(unsafe(left[i_4])) != int(unsafe(right[i_4]))) {
            return int(unsafe(left[i_4])) - int(unsafe(right[i_4]))
        }
        i_4 = i_4 + 1
    }
    return 0
}
[export]
def memchr(var src_2 : uint64; var value_0 : int; var count_4 : size_t) : uint64 {
    var bytes_0 : uint8 const? = unsafe(reinterpret<uint8 const?>(src_2))
    var i_5 : size_t = cast<size_t>(0)
    i_5 = uint64(cast<size_t>(0))
    i_5
    while (i_5 < count_4) {
        if (int(unsafe(bytes_0[i_5])) == int(uint8(value_0))) {
            return unsafe(reinterpret<uint64>(unsafe(bytes_0 + i_5)))
        }
        i_5 = i_5 + 1
    }
    return null
}
[export]
def strlen(var src_3 : int8 const?) : size_t {
    var count_5 : size_t = cast<size_t>(0)
    while (int(unsafe(src_3[count_5])) != 0) {
        count_5 = uint64(count_5 + cast<size_t>(1))
        count_5
    }
    return count_5
}
[export]
def strdup(var src_4 : int8 const?) : int8? {
    var length : size_t = strlen(src_4)
    var copy : int8? = unsafe(reinterpret<int8?>(malloc(length + cast<size_t>(0x1))))
    var index : size_t = cast<size_t>(0)
    if (copy == null) {
        return null
    }
    index = uint64(cast<size_t>(0))
    index
    while (index < length) {
        unsafe(copy[index]) = unsafe(src_4[index])
        unsafe(copy[index])
        index = index + 1
    }
    unsafe(copy[length]) = int8(0)
    unsafe(copy[length])
    return copy
}
[export]
def mallocz(var size_2 : size_t) : uint64 {
    return calloc(uint64(0x1), size_2)
}


typedef u8 = uint8
typedef u16 = int
typedef i16 = int
typedef u32 = uint
typedef i32 = int
struct strmData_t {
    pStrmBuffStart : uint8?
    pStrmCurrPos : uint8?
    bitPosInWord : uint
    strmBuffSize : uint
    strmBuffReadBits : uint
}
typedef uintptr_t = uint64
struct hrdParameters_t {
    cpbCnt : uint
    bitRateScale : uint
    cpbSizeScale : uint
    bitRateValue : array<uint>
    cpbSizeValue : array<uint>
    cbrFlag : array<uint>
    initialCpbRemovalDelayLength : uint
    cpbRemovalDelayLength : uint
    dpbOutputDelayLength : uint
    timeOffsetLength : uint
}
struct vuiParameters_t {
    aspectRatioPresentFlag : uint
    aspectRatioIdc : uint
    sarWidth : uint
    sarHeight : uint
    overscanInfoPresentFlag : uint
    overscanAppropriateFlag : uint
    videoSignalTypePresentFlag : uint
    videoFormat : uint
    videoFullRangeFlag : uint
    colourDescriptionPresentFlag : uint
    colourPrimaries : uint
    transferCharacteristics : uint
    matrixCoefficients : uint
    chromaLocInfoPresentFlag : uint
    chromaSampleLocTypeTopField : uint
    chromaSampleLocTypeBottomField : uint
    timingInfoPresentFlag : uint
    numUnitsInTick : uint
    timeScale : uint
    fixedFrameRateFlag : uint
    nalHrdParametersPresentFlag : uint
    nalHrdParameters : hrdParameters_t
    vclHrdParametersPresentFlag : uint
    vclHrdParameters : hrdParameters_t
    lowDelayHrdFlag : uint
    picStructPresentFlag : uint
    bitstreamRestrictionFlag : uint
    motionVectorsOverPicBoundariesFlag : uint
    maxBytesPerPicDenom : uint
    maxBitsPerMbDenom : uint
    log2MaxMvLengthHorizontal : uint
    log2MaxMvLengthVertical : uint
    numReorderFrames : uint
    maxDecFrameBuffering : uint
}
struct seqParamSet_t {
    profileIdc : uint
    levelIdc : uint
    seqParameterSetId : uint
    maxFrameNum : uint
    picOrderCntType : uint
    maxPicOrderCntLsb : uint
    deltaPicOrderAlwaysZeroFlag : uint
    offsetForNonRefPic : int
    offsetForTopToBottomField : int
    numRefFramesInPicOrderCntCycle : uint
    offsetForRefFrame : int?
    numRefFrames : uint
    gapsInFrameNumValueAllowedFlag : uint
    picWidthInMbs : uint
    picHeightInMbs : uint
    frameCroppingFlag : uint
    frameCropLeftOffset : uint
    frameCropRightOffset : uint
    frameCropTopOffset : uint
    frameCropBottomOffset : uint
    vuiParametersPresentFlag : uint
    vuiParameters : vuiParameters_t?
    maxDpbSize : uint
}
struct picParamSet_t {
    picParameterSetId : uint
    seqParameterSetId : uint
    picOrderPresentFlag : uint
    numSliceGroups : uint
    sliceGroupMapType : uint
    runLength : uint?
    topLeft : uint?
    bottomRight : uint?
    sliceGroupChangeDirectionFlag : uint
    sliceGroupChangeRate : uint
    picSizeInMapUnits : uint
    sliceGroupId : uint?
    numRefIdxL0Active : uint
    picInitQp : uint
    chromaQpIndexOffset : int
    deblockingFilterControlPresentFlag : uint
    constrainedIntraPredFlag : uint
    redundantPicCntPresentFlag : uint
}
enum nalUnitType_e {
    NAL_CODED_SLICE = 1
    NAL_CODED_SLICE_IDR = 5
    NAL_SEI = 6
    NAL_SEQ_PARAM_SET = 7
    NAL_PIC_PARAM_SET = 8
    NAL_ACCESS_UNIT_DELIMITER = 9
    NAL_END_OF_SEQUENCE = 10
    NAL_END_OF_STREAM = 11
    NAL_FILLER_DATA = 12
    NAL_MAX_TYPE_VALUE = 31
}
struct nalUnit_t {
    nalUnitType : nalUnitType_e
    nalRefIdc : uint
}
struct refPicListReorderingOperation_t {
    reorderingOfPicNumsIdc : uint
    absDiffPicNum : uint
    longTermPicNum : uint
}
struct refPicListReordering_t {
    refPicListReorderingFlagL0 : uint
    command : array<refPicListReorderingOperation_t>
}
struct memoryManagementOperation_t {
    memoryManagementControlOperation : uint
    differenceOfPicNums : uint
    longTermPicNum : uint
    longTermFrameIdx : uint
    maxLongTermFrameIdx : uint
}
struct decRefPicMarking_t {
    noOutputOfPriorPicsFlag : uint
    longTermReferenceFlag : uint
    adaptiveRefPicMarkingModeFlag : uint
    operation : array<memoryManagementOperation_t>
}
struct sliceHeader_t {
    firstMbInSlice : uint
    sliceType : uint
    picParameterSetId : uint
    frameNum : uint
    idrPicId : uint
    picOrderCntLsb : uint
    deltaPicOrderCntBottom : int
    deltaPicOrderCnt : array<int>
    redundantPicCnt : uint
    numRefIdxActiveOverrideFlag : uint
    numRefIdxL0Active : uint
    sliceQpDelta : int
    disableDeblockingFilterIdc : uint
    sliceAlphaC0Offset : int
    sliceBetaOffset : int
    sliceGroupChangeCycle : uint
    refPicListReordering : refPicListReordering_t
    decRefPicMarking : decRefPicMarking_t
}
enum dpbPictureStatus_e {
    UNUSED = 0
    NON_EXISTING = 1
    SHORT_TERM = 2
    LONG_TERM = 3
}
struct dpbPicture_t {
    data : uint8?
    pAllocatedData : uint8?
    picNum : int
    frameNum : uint
    picOrderCnt : int
    status : dpbPictureStatus_e
    toBeDisplayed : uint
    picId : uint
    numErrMbs : uint
    isIdr : uint
}
struct dpbOutPicture_t {
    data : uint8?
    picId : uint
    numErrMbs : uint
    isIdr : uint
}
struct dpbStorage_t {
    buffer : dpbPicture_t?
    list : dpbPicture_t??
    currentOut : dpbPicture_t?
    outBuf : dpbOutPicture_t?
    numOut : uint
    outIndex : uint
    maxRefFrames : uint
    dpbSize : uint
    maxFrameNum : uint
    maxLongTermFrameIdx : uint
    numRefFrames : uint
    fullness : uint
    prevRefFrameNum : uint
    lastContainsMmco5 : uint
    noReordering : uint
    flushed : uint
}
enum mbType_e {
    P_Skip = 0
    P_L0_16x16 = 1
    P_L0_L0_16x8 = 2
    P_L0_L0_8x16 = 3
    P_8x8 = 4
    P_8x8ref0 = 5
    I_4x4 = 6
    I_16x16_0_0_0 = 7
    I_16x16_1_0_0 = 8
    I_16x16_2_0_0 = 9
    I_16x16_3_0_0 = 10
    I_16x16_0_1_0 = 11
    I_16x16_1_1_0 = 12
    I_16x16_2_1_0 = 13
    I_16x16_3_1_0 = 14
    I_16x16_0_2_0 = 15
    I_16x16_1_2_0 = 16
    I_16x16_2_2_0 = 17
    I_16x16_3_2_0 = 18
    I_16x16_0_0_1 = 19
    I_16x16_1_0_1 = 20
    I_16x16_2_0_1 = 21
    I_16x16_3_0_1 = 22
    I_16x16_0_1_1 = 23
    I_16x16_1_1_1 = 24
    I_16x16_2_1_1 = 25
    I_16x16_3_1_1 = 26
    I_16x16_0_2_1 = 27
    I_16x16_1_2_1 = 28
    I_16x16_2_2_1 = 29
    I_16x16_3_2_1 = 30
    I_PCM = 31
}
enum subMbType_e {
    P_L0_8x8 = 0
    P_L0_8x4 = 1
    P_L0_4x8 = 2
    P_L0_4x4 = 3
}
enum subMbPartMode_e {
    MB_SP_8x8 = 0
    MB_SP_8x4 = 1
    MB_SP_4x8 = 2
    MB_SP_4x4 = 3
}
enum mbPartPredMode_e {
    PRED_MODE_INTRA4x4 = 0
    PRED_MODE_INTRA16x16 = 1
    PRED_MODE_INTER = 2
}
struct mv_t {
    hor : int
    ver : int
}
struct mbPred_t {
    prevIntra4x4PredModeFlag : array<uint>
    remIntra4x4PredMode : array<uint>
    intraChromaPredMode : uint
    refIdxL0 : array<uint>
    mvdL0 : array<mv_t>
}
struct subMbPred_t {
    subMbType : array<subMbType_e>
    refIdxL0 : array<uint>
    mvdL0 : array<array<mv_t>>
}
struct residual_t {
    totalCoeff : array<int>
    level : array<array<int>>
    coeffMap : array<uint>
}
struct macroblockLayer_t {
    mbType : mbType_e
    codedBlockPattern : uint
    mbQpDelta : int
    mbPred : mbPred_t
    subMbPred : subMbPred_t
    residual : residual_t
}
struct mbStorage {
    mbType : mbType_e
    sliceId : uint
    disableDeblockingFilterIdc : uint
    filterOffsetA : int
    filterOffsetB : int
    qpY : uint
    chromaQpIndexOffset : int
    totalCoeff : array<int>
    intra4x4PredMode : array<uint8>
    refPic : array<uint>
    refAddr : array<uint8?>
    mv : array<mv_t>
    decoded : uint
    mbA : mbStorage?
    mbB : mbStorage?
    mbC : mbStorage?
    mbD : mbStorage?
}
struct mbStorage_t {
    mbType : mbType_e
    sliceId : uint
    disableDeblockingFilterIdc : uint
    filterOffsetA : int
    filterOffsetB : int
    qpY : uint
    chromaQpIndexOffset : int
    totalCoeff : array<int>
    intra4x4PredMode : array<uint8>
    refPic : array<uint>
    refAddr : array<uint8?>
    mv : array<mv_t>
    decoded : uint
    mbA : mbStorage?
    mbB : mbStorage?
    mbC : mbStorage?
    mbD : mbStorage?
}
enum neighbourMb_e {
    MB_A = 0
    MB_B = 1
    MB_C = 2
    MB_D = 3
    MB_CURR = 4
    MB_NA = 255
}
struct neighbour_t {
    mb : neighbourMb_e
    index : uint8
}
struct interNeighbour_t {
    available : uint
    refIndex : uint
    mv : mv_t
}
struct pocStorage_t {
    prevPicOrderCntLsb : uint
    prevPicOrderCntMsb : int
    prevFrameNum : uint
    prevFrameNumOffset : uint
}
struct sliceStorage_t {
    sliceId : uint
    numDecodedMbs : uint
    lastMbAddr : uint
}
struct aubCheck_t {
    nuPrev : array<nalUnit_t>
    prevFrameNum : uint
    prevIdrPicId : uint
    prevPicOrderCntLsb : uint
    prevDeltaPicOrderCntBottom : int
    prevDeltaPicOrderCnt : array<int>
    firstCallFlag : uint
}
struct storage {
    oldSpsId : uint
    activePpsId : uint
    activeSpsId : uint
    activePps : picParamSet_t?
    activeSps : seqParamSet_t?
    sps : array<seqParamSet_t?>
    pps : array<picParamSet_t?>
    sliceGroupMap : uint?
    picSizeInMbs : uint
    skipRedundantSlices : uint
    picStarted : uint
    validSliceInAccessUnit : uint
    slice : array<sliceStorage_t>
    numConcealedMbs : uint
    currentPicId : uint
    mb : mbStorage_t?
    noReordering : uint
    dpb : array<dpbStorage_t>
    poc : array<pocStorage_t>
    aub : array<aubCheck_t>
    currImage : array<image_t>
    prevNalUnit : array<nalUnit_t>
    sliceHeader : array<sliceHeader_t>
    prevBufNotFinished : uint
    prevBufPointer : uint8?
    prevBytesConsumed : uint
    strm : array<strmData_t>
    mbLayer : macroblockLayer_t?
    pendingActivation : uint
    intraConcealmentFlag : uint
    conversionBuffer : uint?
    conversionBufferSize : size_t
}
struct storage_t {
    oldSpsId : uint
    activePpsId : uint
    activeSpsId : uint
    activePps : picParamSet_t?
    activeSps : seqParamSet_t?
    sps : array<seqParamSet_t?>
    pps : array<picParamSet_t?>
    sliceGroupMap : uint?
    picSizeInMbs : uint
    skipRedundantSlices : uint
    picStarted : uint
    validSliceInAccessUnit : uint
    slice : array<sliceStorage_t>
    numConcealedMbs : uint
    currentPicId : uint
    mb : mbStorage_t?
    noReordering : uint
    dpb : array<dpbStorage_t>
    poc : array<pocStorage_t>
    aub : array<aubCheck_t>
    currImage : array<image_t>
    prevNalUnit : array<nalUnit_t>
    sliceHeader : array<sliceHeader_t>
    prevBufNotFinished : uint
    prevBufPointer : uint8?
    prevBytesConsumed : uint
    strm : array<strmData_t>
    mbLayer : macroblockLayer_t?
    pendingActivation : uint
    intraConcealmentFlag : uint
    conversionBuffer : uint?
    conversionBufferSize : size_t
}
struct edgeThreshold_t {
    tc0 : uint8 const?
    alpha : uint
    beta : uint
}
struct bS_t {
    top : uint
    left : uint
}
struct seiBufferingPeriod_t {
    seqParameterSetId : uint
    initialCpbRemovalDelay : array<uint>
    initialCpbRemovalDelayOffset : array<uint>
}
struct seiPicTiming_t {
    cpbRemovalDelay : uint
    dpbOutputDelay : uint
    picStruct : uint
    clockTimeStampFlag : array<uint>
    clockTimeStamp : array<uint>
    ctType : array<uint>
    nuitFieldBasedFlag : array<uint>
    countingType : array<uint>
    fullTimeStampFlag : array<uint>
    discontinuityFlag : array<uint>
    cntDroppedFlag : array<uint>
    nFrames : array<uint>
    secondsFlag : array<uint>
    secondsValue : array<uint>
    minutesFlag : array<uint>
    minutesValue : array<uint>
    hoursFlag : array<uint>
    hoursValue : array<uint>
    timeOffset : array<int>
}
struct seiPanScanRect_t {
    panScanRectId : uint
    panScanRectCancelFlag : uint
    panScanCnt : uint
    panScanRectLeftOffset : array<int>
    panScanRectRightOffset : array<int>
    panScanRectTopOffset : array<int>
    panScanRectBottomOffset : array<int>
    panScanRectRepetitionPeriod : uint
}
struct seiUserDataRegisteredItuTT35_t {
    ituTT35CountryCode : uint
    ituTT35CountryCodeExtensionByte : uint
    ituTT35PayloadByte : uint8?
    numPayloadBytes : uint
}
struct seiUserDataUnregistered_t {
    uuidIsoIec11578 : array<uint>
    userDataPayloadByte : uint8?
    numPayloadBytes : uint
}
struct seiRecoveryPoint_t {
    recoveryFrameCnt : uint
    exactMatchFlag : uint
    brokenLinkFlag : uint
    changingSliceGroupIdc : uint
}
struct seiDecRefPicMarkingRepetition_t {
    originalIdrFlag : uint
    originalFrameNum : uint
    decRefPicMarking : decRefPicMarking_t
}
struct seiSparePic_t {
    targetFrameNum : uint
    spareFieldFlag : uint
    targetBottomFieldFlag : uint
    numSparePics : uint
    deltaSpareFrameNum : array<uint>
    spareBottomFieldFlag : array<uint>
    spareAreaIdc : array<uint>
    spareUnitFlag : array<uint?>
    zeroRunLength : array<uint?>
}
struct seiSceneInfo_t {
    sceneInfoPresentFlag : uint
    sceneId : uint
    sceneTransitionType : uint
    secondSceneId : uint
}
struct seiSubSeqInfo_t {
    subSeqLayerNum : uint
    subSeqId : uint
    firstRefPicFlag : uint
    leadingNonRefPicFlag : uint
    lastPicFlag : uint
    subSeqFrameNumFlag : uint
    subSeqFrameNum : uint
}
struct seiSubSeqLayerCharacteristics_t {
    numSubSeqLayers : uint
    accurateStatisticsFlag : array<uint>
    averageBitRate : array<uint>
    averageFrameRate : array<uint>
}
struct seiSubSeqCharacteristics_t {
    subSeqLayerNum : uint
    subSeqId : uint
    durationFlag : uint
    subSeqDuration : uint
    averageRateFlag : uint
    accurateStatisticsFlag : uint
    averageBitRate : uint
    averageFrameRate : uint
    numReferencedSubseqs : uint
    refSubSeqLayerNum : array<uint>
    refSubSeqId : array<uint>
    refSubSeqDirection : array<uint>
}
struct seiFullFrameFreeze_t {
    fullFrameFreezeRepetitionPeriod : uint
}
struct seiFullFrameSnapshot_t {
    snapShotId : uint
}
struct seiProgressiveRefinementSegmentStart_t {
    progressiveRefinementId : uint
    numRefinementSteps : uint
}
struct seiProgressiveRefinementSegmentEnd_t {
    progressiveRefinementId : uint
}
struct seiMotionConstrainedSliceGroupSet_t {
    numSliceGroupsInSet : uint
    sliceGroupId : array<uint>
    exactSampleValueMatchFlag : uint
    panScanRectFlag : uint
    panScanRectId : uint
}
struct seiReservedSeiMessage_t {
    reservedSeiMessagePayloadByte : uint8?
    numPayloadBytes : uint
}
struct seiMessage_t {
    payloadType : uint
    bufferingPeriod : seiBufferingPeriod_t
    picTiming : seiPicTiming_t
    panScanRect : seiPanScanRect_t
    userDataRegisteredItuTT35 : seiUserDataRegisteredItuTT35_t
    userDataUnregistered : seiUserDataUnregistered_t
    recoveryPoint : seiRecoveryPoint_t
    decRefPicMarkingRepetition : seiDecRefPicMarkingRepetition_t
    sparePic : seiSparePic_t
    sceneInfo : seiSceneInfo_t
    subSeqInfo : seiSubSeqInfo_t
    subSeqLayerCharacteristics : seiSubSeqLayerCharacteristics_t
    subSeqCharacteristics : seiSubSeqCharacteristics_t
    fullFrameFreeze : seiFullFrameFreeze_t
    fullFrameSnapshot : seiFullFrameSnapshot_t
    progressiveRefinementSegmentStart : seiProgressiveRefinementSegmentStart_t
    progressiveRefinementSegmentEnd : seiProgressiveRefinementSegmentEnd_t
    motionConstrainedSliceGroupSet : seiMotionConstrainedSliceGroupSet_t
    reservedSeiMessage : seiReservedSeiMessage_t
}
[export]
def h264bsdGetBits(var pStrmData : strmData_t?; var numBits : uint) : uint {
}
[export]
def h264bsdFlushBits(var pStrmData_0 : strmData_t?; var numBits_0 : uint) : uint {
    pStrmData_0.strmBuffReadBits = uint(pStrmData_0.strmBuffReadBits + numBits_0)
    pStrmData_0.strmBuffReadBits
    pStrmData_0.bitPosInWord = uint(pStrmData_0.strmBuffReadBits & uint(7))
    pStrmData_0.bitPosInWord
    if (pStrmData_0.strmBuffReadBits <= uint(8) * pStrmData_0.strmBuffSize) {
        pStrmData_0.pStrmCurrPos = unsafe(pStrmData_0.pStrmBuffStart + uint(pStrmData_0.strmBuffReadBits) >> uint(uint(3)))
        pStrmData_0.pStrmCurrPos
        return uint(0)
    } else {
        return 0xffffffff
    }
}
[export]
def h264bsdShowBits32(var pStrmData_1 : strmData_t?) : uint {
    var bits : int
    var shift : int
}
[export]
def h264bsdIsByteAligned(var pStrmData_2 : strmData_t?) : uint {
    if (pStrmData_2.bitPosInWord == 0) {
        return uint(1)
    } else {
        return uint(0)
    }
}
[export]
def h264bsdExtractNalUnit(var pByteStream : uint8?; var len : uint; var pStrmData_3 : strmData_t?; var readBytes : uint?) : uint {
    pStrmData_3.pStrmBuffStart = unsafe(pByteStream + initByteCount)
    pStrmData_3.pStrmBuffStart
    pStrmData_3.pStrmCurrPos = pStrmData_3.pStrmBuffStart
    pStrmData_3.pStrmCurrPos
    pStrmData_3.bitPosInWord = uint(uint(0))
    pStrmData_3.bitPosInWord
    pStrmData_3.strmBuffReadBits = uint(uint(0))
    pStrmData_3.strmBuffReadBits
    *readBytes = uint(pStrmData_3.strmBuffSize + initByteCount + zeroCount)
    *readBytes
    if (invalidStream != 0x0) {
        return uint(1)
    }
    if (hasEmulation != 0x0) {
        tmp_0 = uint(pStrmData_3.strmBuffSize)
        tmp_0
        writePtr = pStrmData_3.pStrmBuffStart
        readPtr = writePtr
        readPtr
        zeroCount = uint(uint(0))
        zeroCount
        i = uint(tmp_0)
        i
        while (i != 0x0) {
            if (zeroCount == uint(2) && int(*readPtr) == 3) {
                if (i == uint(0) || int(*unsafe(readPtr + 1)) > 3) {
                    return uint(1)
                }
                readPtr = readPtr + 1
                readPtr
                zeroCount = uint(uint(0))
                zeroCount
            } else {
                if (zeroCount == uint(2) && int(*readPtr) <= 2) {
                    return uint(1)
                }
                if (int(*readPtr) == 0) {
                    zeroCount = zeroCount + 1
                    zeroCount
                } else {
                    zeroCount = uint(uint(0))
                    zeroCount
                }
                writePtr = writePtr + 1
                readPtr = readPtr + 1
                *writePtr = uint8(*readPtr)
                *writePtr
            }
        }
        pStrmData_3.strmBuffSize = uint(pStrmData_3.strmBuffSize - uint(readPtr - writePtr))
        pStrmData_3.strmBuffSize
    }
    return uint(0)
}
[export]
def c2da___bswap_16(var c2da___bsx : uint16) : uint16 {
    return uint16(int(c2da___bsx) >> 8 & 255 | int(c2da___bsx) & 255 << 8)
}
[export]
def c2da___bswap_32(var c2da___bsx_0 : uint) : uint {
    return uint(c2da___bsx_0 & 0xff000000) >> uint(uint(24)) | uint(c2da___bsx_0 & 0xff0000) >> uint(uint(8)) | uint(c2da___bsx_0 & 0xff00) << uint(uint(8)) | uint(c2da___bsx_0 & 0xff) << uint(uint(24))
}
[export]
def c2da___bswap_64(var c2da___bsx_1 : uint64) : uint64 {
    return uint64(c2da___bsx_1 & 0xff00000000000000uL) >> uint64(uint64(56)) | uint64(c2da___bsx_1 & 0xff000000000000uL) >> uint64(uint64(40)) | uint64(c2da___bsx_1 & 0xff0000000000uL) >> uint64(uint64(24)) | uint64(c2da___bsx_1 & 0xff00000000uL) >> uint64(uint64(8)) | uint64(c2da___bsx_1 & uint64(0xff000000)) << uint64(uint64(8)) | uint64(c2da___bsx_1 & uint64(0xff0000)) << uint64(uint64(24)) | uint64(c2da___bsx_1 & uint64(0xff00)) << uint64(uint64(40)) | uint64(c2da___bsx_1 & uint64(0xff)) << uint64(uint64(56))
}
[export]
def c2da___uint16_identity(var c2da___x : uint16) : uint16 {
    return c2da___x
}
[export]
def c2da___uint32_identity(var c2da___x_0 : uint) : uint {
    return c2da___x_0
}
[export]
def c2da___uint64_identity(var c2da___x_1 : uint64) : uint64 {
    return c2da___x_1
}
[export]
def h264bsdWriteMacroblock(var image : image_t?; var data : uint8?) {
    width = uint(width >> 1)
    width
    i_0 = uint(uint(8))
    i_0
    while (i_0 != 0x0) {
        ptr = ptr + 1
        tmp1 = uint(*ptr)
        tmp1
        ptr = ptr + 1
        tmp2 = uint(*ptr)
        tmp2
        cb = cb + 1
        *cb = uint(tmp1)
        *cb
        cb = cb + 1
        *cb = uint(tmp2)
        *cb
        cb = cb + width - uint(2)
        cb
        i_0 = i_0 - 1
    }
    i_0 = uint(uint(8))
    i_0
    while (i_0 != 0x0) {
        ptr = ptr + 1
        tmp1 = uint(*ptr)
        tmp1
        ptr = ptr + 1
        tmp2 = uint(*ptr)
        tmp2
        cr = cr + 1
        *cr = uint(tmp1)
        *cr
        cr = cr + 1
        *cr = uint(tmp2)
        *cr
        cr = cr + width - uint(2)
        cr
        i_0 = i_0 - 1
    }
}
[export]
def h264bsdWriteOutputBlocks(var image_0 : image_t?; var mbNum : uint; var data_0 : uint8?; var residual : array<int>?) {
    picWidth = uint(picWidth / uint(2))
    picWidth
    block_0 = uint(uint(16))
    block_0
    while (block_0 <= uint(23)) {
        x = uint(unsafe(unsafe(addr(h264bsdBlockX[0]))[block_0 & uint(3)]))
        x
        y = uint(unsafe(unsafe(addr(h264bsdBlockY[0]))[block_0 & uint(3)]))
        y
        pRes = unsafe(addr(unsafe(residual[block_0])[0]))
        pRes
        tmp_1 = unsafe(data_0 + 256)
        tmp_1
        imageBlock = cb_0
        imageBlock
        if (block_0 >= uint(20)) {
            imageBlock = cr_0
            imageBlock
            tmp_1 = tmp_1 + 64
            tmp_1
        }
        tmp_1 = tmp_1 + y * uint(8) + x
        tmp_1
        imageBlock = imageBlock + y * picWidth + x
        imageBlock
        if (unsafe(pRes[0]) == 16777215) {
            var in32_0 : int? = unsafe(reinterpret<int?>(tmp_1))
            var out32_0 : int? = unsafe(reinterpret<int?>(imageBlock))
            tmp1_0 = *in32_0
            tmp1_0
            in32_0 = in32_0 + 2
            in32_0
            tmp2_0 = *in32_0
            tmp2_0
            in32_0 = in32_0 + 2
            in32_0
            *out32_0 = tmp1_0
            *out32_0
            out32_0 = out32_0 + picWidth / uint(4)
            out32_0
            *out32_0 = tmp2_0
            *out32_0
            out32_0 = out32_0 + picWidth / uint(4)
            out32_0
            tmp1_0 = *in32_0
            tmp1_0
            in32_0 = in32_0 + 2
            in32_0
            tmp2_0 = *in32_0
            tmp2_0
            *out32_0 = tmp1_0
            *out32_0
            out32_0 = out32_0 + picWidth / uint(4)
            out32_0
            *out32_0 = tmp2_0
            *out32_0
        } else {
            i_1 = uint(uint(4))
            i_1
            while (i_1 != 0x0) {
                tmp1_0 = int(unsafe(tmp_1[0]))
                tmp1_0
                pRes = pRes + 1
                tmp2_0 = *pRes
                tmp2_0
                tmp3 = int(unsafe(tmp_1[1]))
                tmp3
                tmp1_0 = int(unsafe(clp[tmp1_0 + tmp2_0]))
                tmp1_0
                pRes = pRes + 1
                tmp4 = *pRes
                tmp4
                unsafe(imageBlock[0]) = uint8(uint8(tmp1_0))
                unsafe(imageBlock[0])
                tmp3 = int(unsafe(clp[tmp3 + tmp4]))
                tmp3
                tmp1_0 = int(unsafe(tmp_1[2]))
                tmp1_0
                pRes = pRes + 1
                tmp2_0 = *pRes
                tmp2_0
                unsafe(imageBlock[1]) = uint8(uint8(tmp3))
                unsafe(imageBlock[1])
                tmp1_0 = int(unsafe(clp[tmp1_0 + tmp2_0]))
                tmp1_0
                tmp3 = int(unsafe(tmp_1[3]))
                tmp3
                pRes = pRes + 1
                tmp4 = *pRes
                tmp4
                unsafe(imageBlock[2]) = uint8(uint8(tmp1_0))
                unsafe(imageBlock[2])
                tmp3 = int(unsafe(clp[tmp3 + tmp4]))
                tmp3
                tmp_1 = tmp_1 + 8
                tmp_1
                unsafe(imageBlock[3]) = uint8(uint8(tmp3))
                unsafe(imageBlock[3])
                imageBlock = imageBlock + picWidth
                imageBlock
                i_1 = i_1 - 1
            }
        }
        block_0 = block_0 + 1
    }
}
var h264bsdClip : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(11), uint8(12), uint8(13), uint8(14), uint8(15), uint8(16), uint8(17), uint8(18), uint8(19), uint8(20), uint8(21), uint8(22), uint8(23), uint8(24), uint8(25), uint8(26), uint8(27), uint8(28), uint8(29), uint8(30), uint8(31), uint8(32), uint8(33), uint8(34), uint8(35), uint8(36), uint8(37), uint8(38), uint8(39), uint8(40), uint8(41), uint8(42), uint8(43), uint8(44), uint8(45), uint8(46), uint8(47), uint8(48), uint8(49), uint8(50), uint8(51), uint8(52), uint8(53), uint8(54), uint8(55), uint8(56), uint8(57), uint8(58), uint8(59), uint8(60), uint8(61), uint8(62), uint8(63), uint8(64), uint8(65), uint8(66), uint8(67), uint8(68), uint8(69), uint8(70), uint8(71), uint8(72), uint8(73), uint8(74), uint8(75), uint8(76), uint8(77), uint8(78), uint8(79), uint8(80), uint8(81), uint8(82), uint8(83), uint8(84), uint8(85), uint8(86), uint8(87), uint8(88), uint8(89), uint8(90), uint8(91), uint8(92), uint8(93), uint8(94), uint8(95), uint8(96), uint8(97), uint8(98), uint8(99), uint8(100), uint8(101), uint8(102), uint8(103), uint8(104), uint8(105), uint8(106), uint8(107), uint8(108), uint8(109), uint8(110), uint8(111), uint8(112), uint8(113), uint8(114), uint8(115), uint8(116), uint8(117), uint8(118), uint8(119), uint8(120), uint8(121), uint8(122), uint8(123), uint8(124), uint8(125), uint8(126), uint8(127), uint8(128), uint8(129), uint8(130), uint8(131), uint8(132), uint8(133), uint8(134), uint8(135), uint8(136), uint8(137), uint8(138), uint8(139), uint8(140), uint8(141), uint8(142), uint8(143), uint8(144), uint8(145), uint8(146), uint8(147), uint8(148), uint8(149), uint8(150), uint8(151), uint8(152), uint8(153), uint8(154), uint8(155), uint8(156), uint8(157), uint8(158), uint8(159), uint8(160), uint8(161), uint8(162), uint8(163), uint8(164), uint8(165), uint8(166), uint8(167), uint8(168), uint8(169), uint8(170), uint8(171), uint8(172), uint8(173), uint8(174), uint8(175), uint8(176), uint8(177), uint8(178), uint8(179), uint8(180), uint8(181), uint8(182), uint8(183), uint8(184), uint8(185), uint8(186), uint8(187), uint8(188), uint8(189), uint8(190), uint8(191), uint8(192), uint8(193), uint8(194), uint8(195), uint8(196), uint8(197), uint8(198), uint8(199), uint8(200), uint8(201), uint8(202), uint8(203), uint8(204), uint8(205), uint8(206), uint8(207), uint8(208), uint8(209), uint8(210), uint8(211), uint8(212), uint8(213), uint8(214), uint8(215), uint8(216), uint8(217), uint8(218), uint8(219), uint8(220), uint8(221), uint8(222), uint8(223), uint8(224), uint8(225), uint8(226), uint8(227), uint8(228), uint8(229), uint8(230), uint8(231), uint8(232), uint8(233), uint8(234), uint8(235), uint8(236), uint8(237), uint8(238), uint8(239), uint8(240), uint8(241), uint8(242), uint8(243), uint8(244), uint8(245), uint8(246), uint8(247), uint8(248), uint8(249), uint8(250), uint8(251), uint8(252), uint8(253), uint8(254), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255), uint8(255)]

var h264bsdBlockY : array<uint> const = [uint(0), uint(0), uint(4), uint(4), uint(0), uint(0), uint(4), uint(4), uint(8), uint(8), uint(12), uint(12), uint(8), uint(8), uint(12), uint(12)]

var h264bsdBlockX : array<uint> const = [uint(0), uint(4), uint(0), uint(4), uint(8), uint(12), uint(8), uint(12), uint(0), uint(4), uint(0), uint(4), uint(8), uint(12), uint(8), uint(12)]

var h264bsdQpC : array<uint> const = [uint(0), uint(1), uint(2), uint(3), uint(4), uint(5), uint(6), uint(7), uint(8), uint(9), uint(10), uint(11), uint(12), uint(13), uint(14), uint(15), uint(16), uint(17), uint(18), uint(19), uint(20), uint(21), uint(22), uint(23), uint(24), uint(25), uint(26), uint(27), uint(28), uint(29), uint(29), uint(30), uint(31), uint(32), uint(32), uint(33), uint(34), uint(34), uint(35), uint(35), uint(36), uint(36), uint(37), uint(37), uint(37), uint(38), uint(38), uint(38), uint(39), uint(39), uint(39), uint(39)]

[export]
def h264bsdCountLeadingZeros(var value : uint; var length : uint) : uint {
    var zeros : uint = uint(0)
    var mask : uint = uint(int(1) << int(int(length - uint(1))))
    while (mask != 0x0 && value & mask == 0) {
        zeros = zeros + 1
        zeros
        mask = uint(mask >> 1)
        mask
    }
    return zeros
}
[export]
def h264bsdRbspTrailingBits(var pStrmData_4 : strmData_t?) : uint {
    var stuffing : uint
    var stuffingLength : uint
    stuffingLength = uint(uint(8) - pStrmData_4.bitPosInWord)
    stuffingLength
    stuffing = uint(h264bsdGetBits(pStrmData_4, stuffingLength))
    stuffing
    if (stuffing == 0xffffffff) {
        return uint(1)
    }
    if (stuffing != unsafe(unsafe(addr(stuffingTable[0]))[stuffingLength - uint(1)])) {
        return uint(1)
    } else {
        return uint(0)
    }
}
var stuffingTable : array<uint> const = [uint(1), uint(2), uint(4), uint(8), uint(16), uint(32), uint(64), uint(128)]

[export]
def h264bsdMoreRbspData(var pStrmData_5 : strmData_t?) : uint {
    var bits_0 : uint
    bits_0 = uint(pStrmData_5.strmBuffSize * uint(8) - pStrmData_5.strmBuffReadBits)
    bits_0
    if (bits_0 == uint(0)) {
        return uint(0)
    }
    if (bits_0 > uint(8) || uint64(h264bsdShowBits32(pStrmData_5) >> uint(32) - bits_0) != uint64(uint64(0x1)) << uint64(uint64(bits_0 - uint(1)))) {
        return uint(1)
    } else {
        return uint(0)
    }
}
[export]
def h264bsdNextMbAddress(var pSliceGroupMap : uint?; var picSizeInMbs : uint; var currMbAddr : uint) : uint {
    if (i_2 == picSizeInMbs) {
        i_2 = uint(uint(0))
        i_2
    }
    return i_2
}
[export]
def h264bsdSetCurrImageMbPointers(var image_1 : image_t?; var mbNum_0 : uint) {
    var width_0 : uint
    var height : uint
    var picSize_0 : uint
    var row_0 : uint
    var col_0 : uint
    var tmp_2 : uint
    width_0 = uint(image_1.width)
    width_0
    height = uint(image_1.height)
    height
    row_0 = uint(mbNum_0 / width_0)
    row_0
    col_0 = uint(mbNum_0 % width_0)
    col_0
    tmp_2 = uint(row_0 * width_0)
    tmp_2
    picSize_0 = uint(width_0 * height)
    picSize_0
    image_1.luma = cast<uint8?>(unsafe(unsafe(image_1.data + col_0 * uint(16)) + tmp_2 * uint(256)))
    image_1.luma
    image_1.cb = cast<uint8?>(unsafe(unsafe(unsafe(image_1.data + picSize_0 * uint(256)) + tmp_2 * uint(64)) + col_0 * uint(8)))
    image_1.cb
    image_1.cr = cast<uint8?>(unsafe(image_1.cb + picSize_0 * uint(64)))
    image_1.cr
}
[export]
def h264bsdDecodeResidualBlockCavlc(var pStrmData_6 : strmData_t?; var coeffLevel : int?; var nc : int; var maxNumCoeff : uint) : uint {
    bit = uint(uint(bufferValue) >> uint(uint(32 - 16)))
    bit
    tmp_3 = uint(DecodeCoeffToken(bit, uint(nc)))
    tmp_3
    if (tmp_3 == 0) {
        return uint(1)
    }
    bufferValue = uint(bufferValue << tmp_3 & uint(31))
    bufferValue
    bufferBits = uint(bufferBits - tmp_3 & uint(31))
    bufferBits
    totalCoeff = uint(uint(tmp_3) >> uint(uint(11)) & uint(31))
    totalCoeff
    if (totalCoeff > maxNumCoeff) {
        return uint(1)
    }
    trailingOnes = uint(uint(tmp_3) >> uint(uint(5)) & uint(63))
    trailingOnes
    if (totalCoeff != uint(0)) {
        i_3 = uint(uint(0))
        i_3
        if (trailingOnes != 0x0) {
            if (bufferBits < trailingOnes) {
                if (h264bsdFlushBits(pStrmData_6, uint(32) - bufferBits) == 0xffffffff) {
                    return uint(1)
                }
                bufferValue = uint(h264bsdShowBits32(pStrmData_6))
                bufferValue
                bufferBits = uint(uint(32))
                bufferBits
            }
            bit = uint(bufferValue >> uint(32) - trailingOnes)
            bit
            bufferValue = uint(bufferValue << trailingOnes)
            bufferValue
            bufferBits = uint(bufferBits - trailingOnes)
            bufferBits
            tmp_3 = uint(uint(int(1) << int(int(trailingOnes - uint(1)))))
            tmp_3
            while (tmp_3 != 0x0) {
                var c2da_fresh1_h264bsd : int = 0
                if (bit & tmp_3) {
                    c2da_fresh1_h264bsd = -1
                } else {
                    c2da_fresh1_h264bsd = 1
                }
                unsafe(unsafe(addr(level[0]))[i_3]) = c2da_fresh1_h264bsd
                unsafe(unsafe(addr(level[0]))[i_3])
                tmp_3 = uint(tmp_3 >> 1)
                tmp_3
                i_3 = i_3 + 1
            }
        }
        if (totalCoeff > uint(10) && trailingOnes < uint(3)) {
            suffixLength = uint(uint(1))
            suffixLength
        } else {
            suffixLength = uint(uint(0))
            suffixLength
        }
        while (i_3 < totalCoeff) {
            if (bufferBits < uint(16)) {
                if (h264bsdFlushBits(pStrmData_6, uint(32) - bufferBits) == 0xffffffff) {
                    return uint(1)
                }
                bufferValue = uint(h264bsdShowBits32(pStrmData_6))
                bufferValue
                bufferBits = uint(uint(32))
                bufferBits
            }
            bit = uint(uint(bufferValue) >> uint(uint(32 - 16)))
            bit
            levelPrefix = uint(DecodeLevelPrefix(bit))
            levelPrefix
            if (levelPrefix == 0xfffffffe) {
                return uint(1)
            }
            bufferValue = uint(bufferValue << levelPrefix + uint(1))
            bufferValue
            bufferBits = uint(bufferBits - levelPrefix + uint(1))
            bufferBits
            if (levelPrefix < uint(14)) {
                tmp_3 = uint(suffixLength)
                tmp_3
            } else {
                if (levelPrefix == uint(14)) {
                    var c2da_fresh2_h264bsd : int = 0
                    if (suffixLength) {
                        c2da_fresh2_h264bsd = suffixLength
                    } else {
                        c2da_fresh2_h264bsd = uint(4)
                    }
                    tmp_3 = uint(c2da_fresh2_h264bsd)
                    tmp_3
                } else {
                    if (suffixLength == 0) {
                        suffixLength = uint(uint(1))
                        suffixLength
                    }
                    tmp_3 = uint(uint(12))
                    tmp_3
                }
            }
            if (suffixLength != 0x0) {
                levelPrefix = uint(levelPrefix << suffixLength)
                levelPrefix
            }
            if (tmp_3 != 0x0) {
                if (bufferBits < tmp_3) {
                    if (h264bsdFlushBits(pStrmData_6, uint(32) - bufferBits) == 0xffffffff) {
                        return uint(1)
                    }
                    bufferValue = uint(h264bsdShowBits32(pStrmData_6))
                    bufferValue
                    bufferBits = uint(uint(32))
                    bufferBits
                }
                levelSuffix = uint(bufferValue >> uint(32) - tmp_3)
                levelSuffix
                bufferValue = uint(bufferValue << tmp_3)
                bufferValue
                bufferBits = uint(bufferBits - tmp_3)
                bufferBits
                levelPrefix = uint(levelPrefix + levelSuffix)
                levelPrefix
            }
            tmp_3 = uint(levelPrefix)
            tmp_3
            if (i_3 == trailingOnes && trailingOnes < uint(3)) {
                tmp_3 = uint(tmp_3 + uint(2))
                tmp_3
            }
            unsafe(unsafe(addr(level[0]))[i_3]) = int(uint(tmp_3 + uint(2)) >> uint(uint(1)))
            unsafe(unsafe(addr(level[0]))[i_3])
            if (suffixLength == uint(0)) {
                suffixLength = uint(uint(1))
                suffixLength
            }
            if (unsafe(unsafe(addr(level[0]))[i_3]) > int(3) << int(int(suffixLength - uint(1))) && suffixLength < uint(6)) {
                suffixLength = suffixLength + 1
                suffixLength
            }
            if (tmp_3 & uint(1) != 0x0) {
                unsafe(unsafe(addr(level[0]))[i_3]) = -unsafe(unsafe(addr(level[0]))[i_3])
                unsafe(unsafe(addr(level[0]))[i_3])
            }
            i_3 = i_3 + 1
        }
        if (totalCoeff < maxNumCoeff) {
            if (bufferBits < uint(9)) {
                if (h264bsdFlushBits(pStrmData_6, uint(32) - bufferBits) == 0xffffffff) {
                    return uint(1)
                }
                bufferValue = uint(h264bsdShowBits32(pStrmData_6))
                bufferValue
                bufferBits = uint(uint(32))
                bufferBits
            }
            bit = uint(uint(bufferValue) >> uint(uint(32 - 9)))
            bit
            zerosLeft = uint(DecodeTotalZeros(bit, totalCoeff, uint(maxNumCoeff == uint(4))))
            zerosLeft
            if (zerosLeft == 0) {
                return uint(1)
            }
            bufferValue = uint(bufferValue << zerosLeft & uint(15))
            bufferValue
            bufferBits = uint(bufferBits - zerosLeft & uint(15))
            bufferBits
            zerosLeft = uint(uint(zerosLeft) >> uint(uint(4)) & uint(15))
            zerosLeft
        } else {
            zerosLeft = uint(uint(0))
            zerosLeft
        }
        i_3 = uint(uint(0))
        i_3
        while (i_3 < totalCoeff - uint(1)) {
            if (zerosLeft > uint(0)) {
                if (bufferBits < uint(11)) {
                    if (h264bsdFlushBits(pStrmData_6, uint(32) - bufferBits) == 0xffffffff) {
                        return uint(1)
                    }
                    bufferValue = uint(h264bsdShowBits32(pStrmData_6))
                    bufferValue
                    bufferBits = uint(uint(32))
                    bufferBits
                }
                bit = uint(uint(bufferValue) >> uint(uint(32 - 11)))
                bit
                tmp_3 = uint(DecodeRunBefore(bit, zerosLeft))
                tmp_3
                if (tmp_3 == 0) {
                    return uint(1)
                }
                bufferValue = uint(bufferValue << tmp_3 & uint(15))
                bufferValue
                bufferBits = uint(bufferBits - tmp_3 & uint(15))
                bufferBits
                unsafe(unsafe(addr(run[0]))[i_3]) = uint(uint(tmp_3) >> uint(uint(4)) & uint(15))
                unsafe(unsafe(addr(run[0]))[i_3])
                unsafe(unsafe(addr(run[0]))[i_3]) = unsafe(unsafe(addr(run[0]))[i_3]) + 1
                zerosLeft = uint(zerosLeft - unsafe(unsafe(addr(run[0]))[i_3]))
                zerosLeft
            } else {
                unsafe(unsafe(addr(run[0]))[i_3]) = uint(uint(1))
                unsafe(unsafe(addr(run[0]))[i_3])
            }
            i_3 = i_3 + 1
        }
        tmp_3 = uint(zerosLeft)
        tmp_3
        unsafe(coeffLevel[tmp_3]) = unsafe(unsafe(addr(level[0]))[totalCoeff - uint(1)])
        unsafe(coeffLevel[tmp_3])
        levelSuffix = uint(uint(int(1) << int(int(tmp_3))))
        levelSuffix
        i_3 = uint(totalCoeff - uint(1))
        i_3
        while (i_3 != 0x0) {
            tmp_3 = uint(tmp_3 + unsafe(unsafe(addr(run[0]))[i_3]))
            tmp_3
            levelSuffix = uint(levelSuffix | uint(int(1) << int(int(tmp_3))))
            levelSuffix
            unsafe(coeffLevel[tmp_3]) = unsafe(unsafe(addr(level[0]))[i_3])
            unsafe(coeffLevel[tmp_3])
        }
    } else {
        levelSuffix = uint(uint(0))
        levelSuffix
    }
    if (h264bsdFlushBits(pStrmData_6, uint(32) - bufferBits) != uint(0)) {
        return uint(1)
    }
    return uint(totalCoeff) << uint(uint(4)) | uint(levelSuffix) << uint(uint(16))
}
[export]
def DecodeRunBefore(var bits_1 : uint; var zerosLeft_0 : uint) : uint {
    var value_0 : uint = uint(0)
    if (zerosLeft_0 == uint(1)) {
        value_0 = uint(uint(unsafe(unsafe(addr(runBefore_1[0]))[uint(bits_1) >> uint(uint(10))])))
        value_0
    } elif (zerosLeft_0 == uint(2)) {
        value_0 = uint(uint(unsafe(unsafe(addr(runBefore_2[0]))[uint(bits_1) >> uint(uint(9))])))
        value_0
    } elif (zerosLeft_0 == uint(3)) {
        value_0 = uint(uint(unsafe(unsafe(addr(runBefore_3[0]))[uint(bits_1) >> uint(uint(9))])))
        value_0
    } elif (zerosLeft_0 == uint(4)) {
        value_0 = uint(uint(unsafe(unsafe(addr(runBefore_4[0]))[uint(bits_1) >> uint(uint(8))])))
        value_0
    } elif (zerosLeft_0 == uint(5)) {
        value_0 = uint(uint(unsafe(unsafe(addr(runBefore_5[0]))[uint(bits_1) >> uint(uint(8))])))
        value_0
    } elif (zerosLeft_0 == uint(6)) {
        value_0 = uint(uint(unsafe(unsafe(addr(runBefore_6[0]))[uint(bits_1) >> uint(uint(8))])))
        value_0
    } else {
        if (bits_1 >= uint(256)) {
            value_0 = uint(uint(uint(7) - uint(bits_1) >> uint(uint(8))) << uint(uint(4)) + uint(3))
            value_0
        } else {
            if (bits_1 >= uint(128)) {
                value_0 = uint(uint(116))
                value_0
            } else {
                if (bits_1 >= uint(64)) {
                    value_0 = uint(uint(133))
                    value_0
                } else {
                    if (bits_1 >= uint(32)) {
                        value_0 = uint(uint(150))
                        value_0
                    } else {
                        if (bits_1 >= uint(16)) {
                            value_0 = uint(uint(167))
                            value_0
                        } else {
                            if (bits_1 >= uint(8)) {
                                value_0 = uint(uint(184))
                                value_0
                            } else {
                                if (bits_1 >= uint(4)) {
                                    value_0 = uint(uint(201))
                                    value_0
                                } else {
                                    if (bits_1 >= uint(2)) {
                                        value_0 = uint(uint(218))
                                        value_0
                                    } else {
                                        if (bits_1 != 0x0) {
                                            value_0 = uint(uint(235))
                                            value_0
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
    return value_0
}
var runBefore_6 : array<uint8> const = [uint8(19), uint8(35), uint8(67), uint8(51), uint8(99), uint8(83), uint8(2), uint8(2)]

var runBefore_5 : array<uint8> const = [uint8(83), uint8(67), uint8(51), uint8(35), uint8(18), uint8(18), uint8(2), uint8(2)]

var runBefore_4 : array<uint8> const = [uint8(67), uint8(51), uint8(34), uint8(34), uint8(18), uint8(18), uint8(2), uint8(2)]

var runBefore_3 : array<uint8> const = [uint8(50), uint8(34), uint8(18), uint8(2)]

var runBefore_2 : array<uint8> const = [uint8(34), uint8(18), uint8(1), uint8(1)]

var runBefore_1 : array<uint8> const = [uint8(17), uint8(1)]

[export]
def DecodeTotalZeros(var bits_2 : uint; var totalCoeff_0 : uint; var isChromaDC : uint) : uint {
    var value_1 : uint = uint(0)
    if (isChromaDC == 0) {
        if (totalCoeff_0 == uint(1)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_1_0[0]))[uint(bits_2) >> uint(uint(4))])))
            value_1
        } elif (totalCoeff_0 == uint(2)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_2[0]))[uint(bits_2) >> uint(uint(3))])))
            value_1
        } elif (totalCoeff_0 == uint(3)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_3[0]))[uint(bits_2) >> uint(uint(3))])))
            value_1
        } elif (totalCoeff_0 == uint(4)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_4[0]))[uint(bits_2) >> uint(uint(4))])))
            value_1
        } elif (totalCoeff_0 == uint(5)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_5[0]))[uint(bits_2) >> uint(uint(4))])))
            value_1
        } elif (totalCoeff_0 == uint(6)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_6[0]))[uint(bits_2) >> uint(uint(3))])))
            value_1
        } elif (totalCoeff_0 == uint(7)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_7[0]))[uint(bits_2) >> uint(uint(3))])))
            value_1
        } elif (totalCoeff_0 == uint(8)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_8[0]))[uint(bits_2) >> uint(uint(3))])))
            value_1
        } elif (totalCoeff_0 == uint(9)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_9[0]))[uint(bits_2) >> uint(uint(3))])))
            value_1
        } elif (totalCoeff_0 == uint(10)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_10[0]))[uint(bits_2) >> uint(uint(4))])))
            value_1
        } elif (totalCoeff_0 == uint(11)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_11[0]))[uint(bits_2) >> uint(uint(5))])))
            value_1
        } elif (totalCoeff_0 == uint(12)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_12[0]))[uint(bits_2) >> uint(uint(5))])))
            value_1
        } elif (totalCoeff_0 == uint(13)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_13[0]))[uint(bits_2) >> uint(uint(6))])))
            value_1
        } elif (totalCoeff_0 == uint(14)) {
            value_1 = uint(uint(unsafe(unsafe(addr(totalZeros_14[0]))[uint(bits_2) >> uint(uint(7))])))
            value_1
        } else {
            var c2da_fresh3_h264bsd : int = 0
            if (uint(bits_2) >> uint(uint(8))) {
                c2da_fresh3_h264bsd = 17
            } else {
                c2da_fresh3_h264bsd = 1
            }
            value_1 = uint(uint(c2da_fresh3_h264bsd))
            value_1
        }
    } else {
        bits_2 = uint(bits_2 >> 6)
        bits_2
        if (bits_2 > uint(3)) {
            value_1 = uint(uint(1))
            value_1
        } else {
            if (totalCoeff_0 == uint(3)) {
                value_1 = uint(uint(17))
                value_1
            } else {
                if (bits_2 > uint(1)) {
                    value_1 = uint(uint(18))
                    value_1
                } else {
                    if (totalCoeff_0 == uint(2)) {
                        value_1 = uint(uint(34))
                        value_1
                    } else {
                        if (bits_2 != 0x0) {
                            value_1 = uint(uint(35))
                            value_1
                        } else {
                            value_1 = uint(uint(51))
                            value_1
                        }
                    }
                }
            }
        }
    }
    return value_1
}
var totalZeros_14 : array<uint8> const = [uint8(2), uint8(18), uint8(33), uint8(33)]

var totalZeros_13 : array<uint8> const = [uint8(3), uint8(19), uint8(50), uint8(50), uint8(33), uint8(33), uint8(33), uint8(33)]

var totalZeros_12 : array<uint8> const = [uint8(4), uint8(20), uint8(67), uint8(67), uint8(34), uint8(34), uint8(34), uint8(34), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49), uint8(49)]

var totalZeros_11 : array<uint8> const = [uint8(4), uint8(20), uint8(35), uint8(35), uint8(51), uint8(51), uint8(83), uint8(83), uint8(65), uint8(65), uint8(65), uint8(65), uint8(65), uint8(65), uint8(65), uint8(65)]

var totalZeros_10 : array<uint8> const = [uint8(21), uint8(5), uint8(100), uint8(100), uint8(35), uint8(35), uint8(35), uint8(35), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50)]

var totalZeros_9 : array<uint8> const = [uint8(22), uint8(6), uint8(117), uint8(117), uint8(36), uint8(36), uint8(36), uint8(36), uint8(83), uint8(83), uint8(83), uint8(83), uint8(83), uint8(83), uint8(83), uint8(83), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(98), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50), uint8(50)]

var totalZeros_8 : array<uint8> const = [uint8(134), uint8(6), uint8(37), uint8(37), uint8(20), uint8(20), uint8(20), uint8(20), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66), uint8(66)]

var totalZeros_7 : array<uint8> const = [uint8(150), uint8(6), uint8(21), uint8(21), uint8(116), uint8(116), uint8(116), uint8(116), uint8(131), uint8(131), uint8(131), uint8(131), uint8(131), uint8(131), uint8(131), uint8(131), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82), uint8(82)]

var totalZeros_6 : array<uint8> const = [uint8(166), uint8(6), uint8(21), uint8(21), uint8(132), uint8(132), uint8(132), uint8(132), uint8(147), uint8(147), uint8(147), uint8(147), uint8(147), uint8(147), uint8(147), uint8(147), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(83), uint8(83), uint8(83), uint8(83), uint8(83), uint8(83), uint8(83), uint8(83), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35)]

var totalZeros_5 : array<uint8> const = [uint8(181), uint8(149), uint8(164), uint8(164), uint8(132), uint8(132), uint8(36), uint8(36), uint8(20), uint8(20), uint8(4), uint8(4), uint8(115), uint8(115), uint8(115), uint8(115), uint8(99), uint8(99), uint8(99), uint8(99), uint8(83), uint8(83), uint8(83), uint8(83), uint8(67), uint8(67), uint8(67), uint8(67), uint8(51), uint8(51), uint8(51), uint8(51)]

var totalZeros_4 : array<uint8> const = [uint8(197), uint8(181), uint8(165), uint8(5), uint8(148), uint8(148), uint8(116), uint8(116), uint8(52), uint8(52), uint8(36), uint8(36), uint8(131), uint8(131), uint8(131), uint8(131), uint8(99), uint8(99), uint8(99), uint8(99), uint8(83), uint8(83), uint8(83), uint8(83), uint8(67), uint8(67), uint8(67), uint8(67), uint8(19), uint8(19), uint8(19), uint8(19)]

var totalZeros_3 : array<uint8> const = [uint8(214), uint8(182), uint8(197), uint8(197), uint8(165), uint8(165), uint8(149), uint8(149), uint8(132), uint8(132), uint8(132), uint8(132), uint8(84), uint8(84), uint8(84), uint8(84), uint8(68), uint8(68), uint8(68), uint8(68), uint8(4), uint8(4), uint8(4), uint8(4), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(115), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(99), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(19), uint8(19), uint8(19), uint8(19), uint8(19), uint8(19), uint8(19), uint8(19)]

var totalZeros_2 : array<uint8> const = [uint8(230), uint8(214), uint8(198), uint8(182), uint8(165), uint8(165), uint8(149), uint8(149), uint8(132), uint8(132), uint8(132), uint8(132), uint8(116), uint8(116), uint8(116), uint8(116), uint8(100), uint8(100), uint8(100), uint8(100), uint8(84), uint8(84), uint8(84), uint8(84), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(67), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(51), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(35), uint8(19), uint8(19), uint8(19), uint8(19), uint8(19), uint8(19), uint8(19), uint8(19), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3)]

var totalZeros_1_1 : array<uint8> const = [uint8(0), uint8(249), uint8(233), uint8(217), uint8(200), uint8(200), uint8(184), uint8(184), uint8(167), uint8(167), uint8(167), uint8(167), uint8(151), uint8(151), uint8(151), uint8(151), uint8(134), uint8(134), uint8(134), uint8(134), uint8(134), uint8(134), uint8(134), uint8(134), uint8(118), uint8(118), uint8(118), uint8(118), uint8(118), uint8(118), uint8(118), uint8(118)]

var totalZeros_1_0 : array<uint8> const = [uint8(0), uint8(0), uint8(101), uint8(85), uint8(68), uint8(68), uint8(52), uint8(52), uint8(35), uint8(35), uint8(35), uint8(35), uint8(19), uint8(19), uint8(19), uint8(19), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1)]

[export]
def DecodeLevelPrefix(var bits_3 : uint) : uint {
    var numZeros : uint
    if (bits_3 >= uint(32768)) {
        numZeros = uint(uint(0))
        numZeros
    } else {
        if (bits_3 >= uint(16384)) {
            numZeros = uint(uint(1))
            numZeros
        } else {
            if (bits_3 >= uint(8192)) {
                numZeros = uint(uint(2))
                numZeros
            } else {
                if (bits_3 >= uint(4096)) {
                    numZeros = uint(uint(3))
                    numZeros
                } else {
                    if (bits_3 >= uint(2048)) {
                        numZeros = uint(uint(4))
                        numZeros
                    } else {
                        if (bits_3 >= uint(1024)) {
                            numZeros = uint(uint(5))
                            numZeros
                        } else {
                            if (bits_3 >= uint(512)) {
                                numZeros = uint(uint(6))
                                numZeros
                            } else {
                                if (bits_3 >= uint(256)) {
                                    numZeros = uint(uint(7))
                                    numZeros
                                } else {
                                    if (bits_3 >= uint(128)) {
                                        numZeros = uint(uint(8))
                                        numZeros
                                    } else {
                                        if (bits_3 >= uint(64)) {
                                            numZeros = uint(uint(9))
                                            numZeros
                                        } else {
                                            if (bits_3 >= uint(32)) {
                                                numZeros = uint(uint(10))
                                                numZeros
                                            } else {
                                                if (bits_3 >= uint(16)) {
                                                    numZeros = uint(uint(11))
                                                    numZeros
                                                } else {
                                                    if (bits_3 >= uint(8)) {
                                                        numZeros = uint(uint(12))
                                                        numZeros
                                                    } else {
                                                        if (bits_3 >= uint(4)) {
                                                            numZeros = uint(uint(13))
                                                            numZeros
                                                        } else {
                                                            if (bits_3 >= uint(2)) {
                                                                numZeros = uint(uint(14))
                                                                numZeros
                                                            } else {
                                                                if (bits_3 >= uint(1)) {
                                                                    numZeros = uint(uint(15))
                                                                    numZeros
                                                                } else {
                                                                    return 0xfffffffe
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
                }
            }
        }
    }
    return numZeros
}
[export]
def DecodeCoeffToken(var bits_4 : uint; var nc_0 : uint) : uint {
    var value_2 : uint
    if (nc_0 < uint(2)) {
        if (bits_4 >= uint(32768)) {
            value_2 = uint(uint(1))
            value_2
        } else {
            if (bits_4 >= uint(3072)) {
                value_2 = uint(uint(unsafe(unsafe(addr(coeffToken0_0[0]))[uint(bits_4) >> uint(uint(10))])))
                value_2
            } else {
                if (bits_4 >= uint(256)) {
                    value_2 = uint(uint(unsafe(unsafe(addr(coeffToken0_1[0]))[uint(bits_4) >> uint(uint(6))])))
                    value_2
                } else {
                    if (bits_4 >= uint(32)) {
                        value_2 = uint(uint(unsafe(unsafe(addr(coeffToken0_2[0]))[uint(bits_4) >> uint(uint(2)) - uint(8)])))
                        value_2
                    } else {
                        value_2 = uint(uint(unsafe(unsafe(addr(coeffToken0_3[0]))[bits_4])))
                        value_2
                    }
                }
            }
        }
    } else {
        if (nc_0 < uint(4)) {
            if (bits_4 >= uint(32768)) {
                var c2da_fresh4_h264bsd : int = 0
                if (bits_4 & uint(16384)) {
                    c2da_fresh4_h264bsd = 2
                } else {
                    c2da_fresh4_h264bsd = 2082
                }
                value_2 = uint(uint(c2da_fresh4_h264bsd))
                value_2
            } else {
                if (bits_4 >= uint(4096)) {
                    value_2 = uint(uint(unsafe(unsafe(addr(coeffToken2_0[0]))[uint(bits_4) >> uint(uint(10))])))
                    value_2
                } else {
                    if (bits_4 >= uint(512)) {
                        value_2 = uint(uint(unsafe(unsafe(addr(coeffToken2_1[0]))[uint(bits_4) >> uint(uint(7))])))
                        value_2
                    } else {
                        value_2 = uint(uint(unsafe(unsafe(addr(coeffToken2_2[0]))[uint(bits_4) >> uint(uint(2))])))
                        value_2
                    }
                }
            }
        } else {
            if (nc_0 < uint(8)) {
                value_2 = uint(uint(unsafe(unsafe(addr(coeffToken4_0[0]))[uint(bits_4) >> uint(uint(10))])))
                value_2
                if (value_2 == 0) {
                    value_2 = uint(uint(unsafe(unsafe(addr(coeffToken4_1[0]))[uint(bits_4) >> uint(uint(6))])))
                    value_2
                }
            } else {
                if (nc_0 <= uint(16)) {
                    value_2 = uint(uint(unsafe(unsafe(addr(coeffToken8[0]))[uint(bits_4) >> uint(uint(10))])))
                    value_2
                } else {
                    value_2 = uint(uint(unsafe(unsafe(addr(coeffTokenMinus1_0[0]))[uint(bits_4) >> uint(uint(13))])))
                    value_2
                    if (value_2 == 0) {
                        value_2 = uint(uint(unsafe(unsafe(addr(coeffTokenMinus1_1[0]))[uint(bits_4) >> uint(uint(8))])))
                        value_2
                    }
                }
            }
        }
    }
    return value_2
}
var coeffTokenMinus1_1 : array<int> const = [8295, 8295, 8264, 8232, 6215, 6215, 6183, 6183, 8198, 8198, 8198, 8198, 6150, 6150, 6150, 6150, 4102, 4102, 4102, 4102, 6246, 6246, 6246, 6246, 4134, 4134, 4134, 4134, 2054, 2054, 2054, 2054]

var coeffTokenMinus1_0 : array<int> const = [0, 4163, 2, 2, 2081, 2081, 2081, 2081]

var coeffToken8 : array<int> const = [2054, 2086, 0, 6, 4102, 4134, 4166, 0, 6150, 6182, 6214, 6246, 8198, 8230, 8262, 8294, 10246, 10278, 10310, 10342, 12294, 12326, 12358, 12390, 14342, 14374, 14406, 14438, 16390, 16422, 16454, 16486, 18438, 18470, 18502, 18534, 20486, 20518, 20550, 20582, 22534, 22566, 22598, 22630, 24582, 24614, 24646, 24678, 26630, 26662, 26694, 26726, 28678, 28710, 28742, 28774, 30726, 30758, 30790, 30822, 32774, 32806, 32838, 32870]

var coeffToken4_1 : array<int> const = [0, 32778, 32874, 32842, 32810, 30730, 30826, 30794, 30762, 28682, 28778, 28746, 28714, 26634, 26665, 26665, 24585, 24585, 26697, 26697, 24617, 24617, 22537, 22537, 26729, 26729, 24649, 24649, 22569, 22569, 20489, 20489, 24680, 24680, 24680, 24680, 22600, 22600, 22600, 22600, 20520, 20520, 20520, 20520, 18440, 18440, 18440, 18440, 22632, 22632, 22632, 22632, 20552, 20552, 20552, 20552, 18472, 18472, 18472, 18472, 16392, 16392, 16392, 16392, 14343, 14343, 14343, 14343, 14343, 14343, 14343, 14343, 12295, 12295, 12295, 12295, 12295, 12295, 12295, 12295, 18503, 18503, 18503, 18503, 18503, 18503, 18503, 18503, 10247, 10247, 10247, 10247, 10247, 10247, 10247, 10247, 20583, 20583, 20583, 20583, 20583, 20583, 20583, 20583, 16455, 16455, 16455, 16455, 16455, 16455, 16455, 16455, 16423, 16423, 16423, 16423, 16423, 16423, 16423, 16423, 8199, 8199, 8199, 8199, 8199, 8199, 8199, 8199]

var coeffToken4_0 : array<int> const = [0, 0, 0, 0, 0, 0, 0, 0, 6150, 14406, 14374, 4102, 18534, 12358, 12326, 2054, 10277, 10277, 10309, 10309, 8229, 8229, 8261, 8261, 6181, 6181, 16485, 16485, 6213, 6213, 4133, 4133, 14436, 14436, 14436, 14436, 12388, 12388, 12388, 12388, 10340, 10340, 10340, 10340, 8292, 8292, 8292, 8292, 6244, 6244, 6244, 6244, 4164, 4164, 4164, 4164, 2084, 2084, 2084, 2084, 4, 4, 4, 4]

var coeffToken2_2 : array<int> const = [0, 0, 30829, 30829, 32878, 32846, 32814, 32782, 30766, 30734, 30798, 28718, 28749, 28749, 28685, 28685, 28781, 28781, 26701, 26701, 26669, 26669, 26637, 26637, 26733, 26733, 24653, 24653, 24621, 24621, 24589, 24589, 22540, 22540, 22540, 22540, 22604, 22604, 22604, 22604, 22572, 22572, 22572, 22572, 20492, 20492, 20492, 20492, 24684, 24684, 24684, 24684, 20556, 20556, 20556, 20556, 20524, 20524, 20524, 20524, 18444, 18444, 18444, 18444, 22635, 22635, 22635, 22635, 22635, 22635, 22635, 22635, 18507, 18507, 18507, 18507, 18507, 18507, 18507, 18507, 18475, 18475, 18475, 18475, 18475, 18475, 18475, 18475, 16395, 16395, 16395, 16395, 16395, 16395, 16395, 16395, 20587, 20587, 20587, 20587, 20587, 20587, 20587, 20587, 16459, 16459, 16459, 16459, 16459, 16459, 16459, 16459, 16427, 16427, 16427, 16427, 16427, 16427, 16427, 16427, 14347, 14347, 14347, 14347, 14347, 14347, 14347, 14347]

var coeffToken2_1 : array<int> const = [0, 0, 0, 0, 18537, 14409, 14377, 12297, 10248, 10248, 12360, 12360, 12328, 12328, 8200, 8200, 16487, 16487, 16487, 16487, 10311, 10311, 10311, 10311, 10279, 10279, 10279, 10279, 6151, 6151, 6151, 6151]

var coeffToken2_0 : array<int> const = [0, 0, 0, 0, 14438, 8262, 8230, 4102, 12390, 6214, 6182, 2054, 10341, 10341, 4133, 4133, 8292, 8292, 8292, 8292, 6244, 6244, 6244, 6244, 4163, 4163, 4163, 4163, 4163, 4163, 4163, 4163]

var coeffToken0_3 : array<int> const = [0, 0, 26671, 26671, 32784, 32848, 32816, 30736, 32880, 30800, 30768, 28688, 30832, 28752, 28720, 26640, 28783, 28783, 26703, 26703, 24623, 24623, 24591, 24591, 26735, 26735, 24655, 24655, 22575, 22575, 22543, 22543]

var coeffToken0_2 : array<int> const = [24686, 22606, 20526, 20494, 22638, 20558, 18478, 18446, 16397, 16397, 18509, 18509, 16429, 16429, 14349, 14349, 20589, 20589, 16461, 16461, 14381, 14381, 12301, 12301, 18539, 18539, 18539, 18539, 18539, 18539, 18539, 18539, 14411, 14411, 14411, 14411, 14411, 14411, 14411, 14411, 12331, 12331, 12331, 12331, 12331, 12331, 12331, 12331, 10251, 10251, 10251, 10251, 10251, 10251, 10251, 10251]

var coeffToken0_1 : array<int> const = [0, 0, 0, 0, 16490, 12362, 10282, 8202, 14441, 14441, 10313, 10313, 8233, 8233, 6153, 6153, 12392, 12392, 12392, 12392, 8264, 8264, 8264, 8264, 6184, 6184, 6184, 6184, 4104, 4104, 4104, 4104, 10343, 10343, 10343, 10343, 10343, 10343, 10343, 10343, 6215, 6215, 6215, 6215, 6215, 6215, 6215, 6215]

var coeffToken0_0 : array<int> const = [0, 0, 0, 8294, 4134, 2054, 6245, 6245, 4163, 4163, 4163, 4163, 4163, 4163, 4163, 4163, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082, 2082]

[export]
def h264bsdDecodeVuiParameters(var pStrmData_7 : strmData_t?; var pVuiParameters : vuiParameters_t?) : uint {
    var tmp_4 : uint
    memset(unsafe(unsafe(reinterpret<uint64>(pVuiParameters))), 0, 4)
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh5_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh5_h264bsd = 1
    } else {
        c2da_fresh5_h264bsd = 0
    }
    pVuiParameters.aspectRatioPresentFlag = uint(uint(c2da_fresh5_h264bsd))
    pVuiParameters.aspectRatioPresentFlag
    if (pVuiParameters.aspectRatioPresentFlag != 0x0) {
        tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(8)))
        tmp_4
        if (tmp_4 == 0xffffffff) {
            return uint(1)
        }
        pVuiParameters.aspectRatioIdc = uint(tmp_4)
        pVuiParameters.aspectRatioIdc
        if (pVuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_EXTENDED_SAR)) {
            tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(16)))
            tmp_4
            if (tmp_4 == 0xffffffff) {
                return uint(1)
            }
            pVuiParameters.sarWidth = uint(tmp_4)
            pVuiParameters.sarWidth
            tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(16)))
            tmp_4
            if (tmp_4 == 0xffffffff) {
                return uint(1)
            }
            pVuiParameters.sarHeight = uint(tmp_4)
            pVuiParameters.sarHeight
        }
    }
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh6_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh6_h264bsd = 1
    } else {
        c2da_fresh6_h264bsd = 0
    }
    pVuiParameters.overscanInfoPresentFlag = uint(uint(c2da_fresh6_h264bsd))
    pVuiParameters.overscanInfoPresentFlag
    if (pVuiParameters.overscanInfoPresentFlag != 0x0) {
        tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
        tmp_4
        if (tmp_4 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh7_h264bsd : int = 0
        if (tmp_4 == uint(1)) {
            c2da_fresh7_h264bsd = 1
        } else {
            c2da_fresh7_h264bsd = 0
        }
        pVuiParameters.overscanAppropriateFlag = uint(uint(c2da_fresh7_h264bsd))
        pVuiParameters.overscanAppropriateFlag
    }
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh8_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh8_h264bsd = 1
    } else {
        c2da_fresh8_h264bsd = 0
    }
    pVuiParameters.videoSignalTypePresentFlag = uint(uint(c2da_fresh8_h264bsd))
    pVuiParameters.videoSignalTypePresentFlag
    if (pVuiParameters.videoSignalTypePresentFlag != 0x0) {
        tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(3)))
        tmp_4
        if (tmp_4 == 0xffffffff) {
            return uint(1)
        }
        pVuiParameters.videoFormat = uint(tmp_4)
        pVuiParameters.videoFormat
        tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
        tmp_4
        if (tmp_4 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh9_h264bsd : int = 0
        if (tmp_4 == uint(1)) {
            c2da_fresh9_h264bsd = 1
        } else {
            c2da_fresh9_h264bsd = 0
        }
        pVuiParameters.videoFullRangeFlag = uint(uint(c2da_fresh9_h264bsd))
        pVuiParameters.videoFullRangeFlag
        tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
        tmp_4
        if (tmp_4 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh10_h264bsd : int = 0
        if (tmp_4 == uint(1)) {
            c2da_fresh10_h264bsd = 1
        } else {
            c2da_fresh10_h264bsd = 0
        }
        pVuiParameters.colourDescriptionPresentFlag = uint(uint(c2da_fresh10_h264bsd))
        pVuiParameters.colourDescriptionPresentFlag
        if (pVuiParameters.colourDescriptionPresentFlag != 0x0) {
            tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(8)))
            tmp_4
            if (tmp_4 == 0xffffffff) {
                return uint(1)
            }
            pVuiParameters.colourPrimaries = uint(tmp_4)
            pVuiParameters.colourPrimaries
            tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(8)))
            tmp_4
            if (tmp_4 == 0xffffffff) {
                return uint(1)
            }
            pVuiParameters.transferCharacteristics = uint(tmp_4)
            pVuiParameters.transferCharacteristics
            tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(8)))
            tmp_4
            if (tmp_4 == 0xffffffff) {
                return uint(1)
            }
            pVuiParameters.matrixCoefficients = uint(tmp_4)
            pVuiParameters.matrixCoefficients
        } else {
            pVuiParameters.colourPrimaries = uint(uint(2))
            pVuiParameters.colourPrimaries
            pVuiParameters.transferCharacteristics = uint(uint(2))
            pVuiParameters.transferCharacteristics
            pVuiParameters.matrixCoefficients = uint(uint(2))
            pVuiParameters.matrixCoefficients
        }
    } else {
        pVuiParameters.videoFormat = uint(uint(5))
        pVuiParameters.videoFormat
        pVuiParameters.colourPrimaries = uint(uint(2))
        pVuiParameters.colourPrimaries
        pVuiParameters.transferCharacteristics = uint(uint(2))
        pVuiParameters.transferCharacteristics
        pVuiParameters.matrixCoefficients = uint(uint(2))
        pVuiParameters.matrixCoefficients
    }
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh11_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh11_h264bsd = 1
    } else {
        c2da_fresh11_h264bsd = 0
    }
    pVuiParameters.chromaLocInfoPresentFlag = uint(uint(c2da_fresh11_h264bsd))
    pVuiParameters.chromaLocInfoPresentFlag
    if (pVuiParameters.chromaLocInfoPresentFlag != 0x0) {
        tmp_4 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_7, unsafe(addr(pVuiParameters.chromaSampleLocTypeTopField))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
        if (pVuiParameters.chromaSampleLocTypeTopField > uint(5)) {
            return uint(1)
        }
        tmp_4 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_7, unsafe(addr(pVuiParameters.chromaSampleLocTypeBottomField))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
        if (pVuiParameters.chromaSampleLocTypeBottomField > uint(5)) {
            return uint(1)
        }
    }
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh12_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh12_h264bsd = 1
    } else {
        c2da_fresh12_h264bsd = 0
    }
    pVuiParameters.timingInfoPresentFlag = uint(uint(c2da_fresh12_h264bsd))
    pVuiParameters.timingInfoPresentFlag
    if (pVuiParameters.timingInfoPresentFlag != 0x0) {
        tmp_4 = uint(h264bsdShowBits32(pStrmData_7))
        tmp_4
        if (h264bsdFlushBits(pStrmData_7, uint(32)) == 0xffffffff) {
            return uint(1)
        }
        if (tmp_4 == uint(0)) {
            return uint(1)
        }
        pVuiParameters.numUnitsInTick = uint(tmp_4)
        pVuiParameters.numUnitsInTick
        tmp_4 = uint(h264bsdShowBits32(pStrmData_7))
        tmp_4
        if (h264bsdFlushBits(pStrmData_7, uint(32)) == 0xffffffff) {
            return uint(1)
        }
        if (tmp_4 == uint(0)) {
            return uint(1)
        }
        pVuiParameters.timeScale = uint(tmp_4)
        pVuiParameters.timeScale
        tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
        tmp_4
        if (tmp_4 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh13_h264bsd : int = 0
        if (tmp_4 == uint(1)) {
            c2da_fresh13_h264bsd = 1
        } else {
            c2da_fresh13_h264bsd = 0
        }
        pVuiParameters.fixedFrameRateFlag = uint(uint(c2da_fresh13_h264bsd))
        pVuiParameters.fixedFrameRateFlag
    }
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh14_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh14_h264bsd = 1
    } else {
        c2da_fresh14_h264bsd = 0
    }
    pVuiParameters.nalHrdParametersPresentFlag = uint(uint(c2da_fresh14_h264bsd))
    pVuiParameters.nalHrdParametersPresentFlag
    if (pVuiParameters.nalHrdParametersPresentFlag != 0x0) {
        tmp_4 = uint(DecodeHrdParameters(pStrmData_7, unsafe(addr(pVuiParameters.nalHrdParameters))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
    } else {
        pVuiParameters.nalHrdParameters.cpbCnt = uint(uint(1))
        pVuiParameters.nalHrdParameters.cpbCnt
        unsafe(unsafe(addr(pVuiParameters.nalHrdParameters.bitRateValue[0]))[0]) = uint(uint(1200 * 240000 + 1))
        unsafe(unsafe(addr(pVuiParameters.nalHrdParameters.bitRateValue[0]))[0])
        unsafe(unsafe(addr(pVuiParameters.nalHrdParameters.cpbSizeValue[0]))[0]) = uint(uint(1200 * 240000 + 1))
        unsafe(unsafe(addr(pVuiParameters.nalHrdParameters.cpbSizeValue[0]))[0])
        pVuiParameters.nalHrdParameters.initialCpbRemovalDelayLength = uint(uint(24))
        pVuiParameters.nalHrdParameters.initialCpbRemovalDelayLength
        pVuiParameters.nalHrdParameters.cpbRemovalDelayLength = uint(uint(24))
        pVuiParameters.nalHrdParameters.cpbRemovalDelayLength
        pVuiParameters.nalHrdParameters.dpbOutputDelayLength = uint(uint(24))
        pVuiParameters.nalHrdParameters.dpbOutputDelayLength
        pVuiParameters.nalHrdParameters.timeOffsetLength = uint(uint(24))
        pVuiParameters.nalHrdParameters.timeOffsetLength
    }
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh15_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh15_h264bsd = 1
    } else {
        c2da_fresh15_h264bsd = 0
    }
    pVuiParameters.vclHrdParametersPresentFlag = uint(uint(c2da_fresh15_h264bsd))
    pVuiParameters.vclHrdParametersPresentFlag
    if (pVuiParameters.vclHrdParametersPresentFlag != 0x0) {
        tmp_4 = uint(DecodeHrdParameters(pStrmData_7, unsafe(addr(pVuiParameters.vclHrdParameters))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
    } else {
        pVuiParameters.vclHrdParameters.cpbCnt = uint(uint(1))
        pVuiParameters.vclHrdParameters.cpbCnt
        unsafe(unsafe(addr(pVuiParameters.vclHrdParameters.bitRateValue[0]))[0]) = uint(uint(1000 * 240000 + 1))
        unsafe(unsafe(addr(pVuiParameters.vclHrdParameters.bitRateValue[0]))[0])
        unsafe(unsafe(addr(pVuiParameters.vclHrdParameters.cpbSizeValue[0]))[0]) = uint(uint(1000 * 240000 + 1))
        unsafe(unsafe(addr(pVuiParameters.vclHrdParameters.cpbSizeValue[0]))[0])
        pVuiParameters.vclHrdParameters.initialCpbRemovalDelayLength = uint(uint(24))
        pVuiParameters.vclHrdParameters.initialCpbRemovalDelayLength
        pVuiParameters.vclHrdParameters.cpbRemovalDelayLength = uint(uint(24))
        pVuiParameters.vclHrdParameters.cpbRemovalDelayLength
        pVuiParameters.vclHrdParameters.dpbOutputDelayLength = uint(uint(24))
        pVuiParameters.vclHrdParameters.dpbOutputDelayLength
        pVuiParameters.vclHrdParameters.timeOffsetLength = uint(uint(24))
        pVuiParameters.vclHrdParameters.timeOffsetLength
    }
    if (pVuiParameters.nalHrdParametersPresentFlag != 0x0 || pVuiParameters.vclHrdParametersPresentFlag != 0x0) {
        tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
        tmp_4
        if (tmp_4 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh16_h264bsd : int = 0
        if (tmp_4 == uint(1)) {
            c2da_fresh16_h264bsd = 1
        } else {
            c2da_fresh16_h264bsd = 0
        }
        pVuiParameters.lowDelayHrdFlag = uint(uint(c2da_fresh16_h264bsd))
        pVuiParameters.lowDelayHrdFlag
    }
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh17_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh17_h264bsd = 1
    } else {
        c2da_fresh17_h264bsd = 0
    }
    pVuiParameters.picStructPresentFlag = uint(uint(c2da_fresh17_h264bsd))
    pVuiParameters.picStructPresentFlag
    tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
    tmp_4
    if (tmp_4 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh18_h264bsd : int = 0
    if (tmp_4 == uint(1)) {
        c2da_fresh18_h264bsd = 1
    } else {
        c2da_fresh18_h264bsd = 0
    }
    pVuiParameters.bitstreamRestrictionFlag = uint(uint(c2da_fresh18_h264bsd))
    pVuiParameters.bitstreamRestrictionFlag
    if (pVuiParameters.bitstreamRestrictionFlag != 0x0) {
        tmp_4 = uint(h264bsdGetBits(pStrmData_7, uint(1)))
        tmp_4
        if (tmp_4 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh19_h264bsd : int = 0
        if (tmp_4 == uint(1)) {
            c2da_fresh19_h264bsd = 1
        } else {
            c2da_fresh19_h264bsd = 0
        }
        pVuiParameters.motionVectorsOverPicBoundariesFlag = uint(uint(c2da_fresh19_h264bsd))
        pVuiParameters.motionVectorsOverPicBoundariesFlag
        tmp_4 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_7, unsafe(addr(pVuiParameters.maxBytesPerPicDenom))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
        if (pVuiParameters.maxBytesPerPicDenom > uint(16)) {
            return uint(1)
        }
        tmp_4 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_7, unsafe(addr(pVuiParameters.maxBitsPerMbDenom))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
        if (pVuiParameters.maxBitsPerMbDenom > uint(16)) {
            return uint(1)
        }
        tmp_4 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_7, unsafe(addr(pVuiParameters.log2MaxMvLengthHorizontal))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
        if (pVuiParameters.log2MaxMvLengthHorizontal > uint(16)) {
            return uint(1)
        }
        tmp_4 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_7, unsafe(addr(pVuiParameters.log2MaxMvLengthVertical))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
        if (pVuiParameters.log2MaxMvLengthVertical > uint(16)) {
            return uint(1)
        }
        tmp_4 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_7, unsafe(addr(pVuiParameters.numReorderFrames))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
        tmp_4 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_7, unsafe(addr(pVuiParameters.maxDecFrameBuffering))))
        tmp_4
        if (tmp_4 != uint(0)) {
            return tmp_4
        }
    } else {
        pVuiParameters.motionVectorsOverPicBoundariesFlag = uint(uint(1))
        pVuiParameters.motionVectorsOverPicBoundariesFlag
        pVuiParameters.maxBytesPerPicDenom = uint(uint(2))
        pVuiParameters.maxBytesPerPicDenom
        pVuiParameters.maxBitsPerMbDenom = uint(uint(1))
        pVuiParameters.maxBitsPerMbDenom
        pVuiParameters.log2MaxMvLengthHorizontal = uint(uint(16))
        pVuiParameters.log2MaxMvLengthHorizontal
        pVuiParameters.log2MaxMvLengthVertical = uint(uint(16))
        pVuiParameters.log2MaxMvLengthVertical
        pVuiParameters.numReorderFrames = uint(uint(16))
        pVuiParameters.numReorderFrames
        pVuiParameters.maxDecFrameBuffering = uint(uint(16))
        pVuiParameters.maxDecFrameBuffering
    }
    return uint(0)
}
[export]
def h264bsdDecodeExpGolombUnsigned(var pStrmData_8 : strmData_t?; var codeNum : uint?) : uint {
    var bits_5 : uint
    var numZeros_0 : uint
    bits_5 = uint(h264bsdShowBits32(pStrmData_8))
    bits_5
    if (bits_5 >= 0x80000000) {
        h264bsdFlushBits(pStrmData_8, uint(1))
        *codeNum = uint(uint(0))
        *codeNum
        return uint(0)
    } else {
        if (bits_5 >= uint(1073741824)) {
            if (h264bsdFlushBits(pStrmData_8, uint(3)) == 0xffffffff) {
                return uint(1)
            }
            *codeNum = uint(uint(1) + uint(bits_5) >> uint(uint(29)) & uint(1))
            *codeNum
            return uint(0)
        } else {
            if (bits_5 >= uint(536870912)) {
                if (h264bsdFlushBits(pStrmData_8, uint(5)) == 0xffffffff) {
                    return uint(1)
                }
                *codeNum = uint(uint(3) + uint(bits_5) >> uint(uint(27)) & uint(3))
                *codeNum
                return uint(0)
            } else {
                if (bits_5 >= uint(268435456)) {
                    if (h264bsdFlushBits(pStrmData_8, uint(7)) == 0xffffffff) {
                        return uint(1)
                    }
                    *codeNum = uint(uint(7) + uint(bits_5) >> uint(uint(25)) & uint(7))
                    *codeNum
                    return uint(0)
                } else {
                    numZeros_0 = uint(uint(4) + h264bsdCountLeadingZeros(bits_5, uint(28)))
                    numZeros_0
                    if (numZeros_0 == uint(32)) {
                        *codeNum = uint(uint(0))
                        *codeNum
                        h264bsdFlushBits(pStrmData_8, uint(32))
                        bits_5 = uint(h264bsdGetBits(pStrmData_8, uint(1)))
                        bits_5
                        if (bits_5 == uint(1)) {
                            bits_5 = uint(h264bsdShowBits32(pStrmData_8))
                            bits_5
                            if (h264bsdFlushBits(pStrmData_8, uint(32)) == 0xffffffff) {
                                return uint(1)
                            }
                            if (bits_5 == uint(0)) {
                                *codeNum = uint(0xffffffff)
                                *codeNum
                                return uint(0)
                            } else {
                                if (bits_5 == uint(1)) {
                                    *codeNum = uint(0xffffffff)
                                    *codeNum
                                    return uint(1)
                                }
                            }
                        }
                        return uint(1)
                    } else {
                        h264bsdFlushBits(pStrmData_8, numZeros_0 + uint(1))
                    }
                    bits_5 = uint(h264bsdGetBits(pStrmData_8, numZeros_0))
                    bits_5
                    if (bits_5 == 0xffffffff) {
                        return uint(1)
                    }
                    *codeNum = uint(uint(int(1) << int(int(numZeros_0)) - 1) + bits_5)
                    *codeNum
                }
            }
        }
    }
    return uint(0)
}
[export]
def DecodeHrdParameters(var pStrmData_9 : strmData_t?; var pHrdParameters : hrdParameters_t?) : uint {
    var tmp_5 : uint
    pHrdParameters.cpbCnt = pHrdParameters.cpbCnt + 1
    pHrdParameters.cpbCnt
    if (pHrdParameters.cpbCnt > uint(32)) {
        return uint(1)
    }
    tmp_5 = uint(h264bsdGetBits(pStrmData_9, uint(4)))
    tmp_5
    if (tmp_5 == 0xffffffff) {
        return uint(1)
    }
    pHrdParameters.bitRateScale = uint(tmp_5)
    pHrdParameters.bitRateScale
    tmp_5 = uint(h264bsdGetBits(pStrmData_9, uint(4)))
    tmp_5
    if (tmp_5 == 0xffffffff) {
        return uint(1)
    }
    pHrdParameters.cpbSizeScale = uint(tmp_5)
    pHrdParameters.cpbSizeScale
    i_4 = uint(uint(0))
    i_4
    while (i_4 < pHrdParameters.cpbCnt) {
        tmp_5 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_9, unsafe(addr(unsafe(unsafe(addr(pHrdParameters.bitRateValue[0]))[i_4])))))
        tmp_5
        if (tmp_5 != uint(0)) {
            return tmp_5
        }
        if (unsafe(unsafe(addr(pHrdParameters.bitRateValue[0]))[i_4]) > 0xfffffffe) {
            return uint(1)
        }
        unsafe(unsafe(addr(pHrdParameters.bitRateValue[0]))[i_4]) = unsafe(unsafe(addr(pHrdParameters.bitRateValue[0]))[i_4]) + 1
        unsafe(unsafe(addr(pHrdParameters.bitRateValue[0]))[i_4])
        unsafe(unsafe(addr(pHrdParameters.bitRateValue[0]))[i_4]) = uint(unsafe(unsafe(addr(pHrdParameters.bitRateValue[0]))[i_4]) * uint(int(1) << int(int(uint(6) + pHrdParameters.bitRateScale))))
        unsafe(unsafe(addr(pHrdParameters.bitRateValue[0]))[i_4])
        tmp_5 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_9, unsafe(addr(unsafe(unsafe(addr(pHrdParameters.cpbSizeValue[0]))[i_4])))))
        tmp_5
        if (tmp_5 != uint(0)) {
            return tmp_5
        }
        if (unsafe(unsafe(addr(pHrdParameters.cpbSizeValue[0]))[i_4]) > 0xfffffffe) {
            return uint(1)
        }
        unsafe(unsafe(addr(pHrdParameters.cpbSizeValue[0]))[i_4]) = unsafe(unsafe(addr(pHrdParameters.cpbSizeValue[0]))[i_4]) + 1
        unsafe(unsafe(addr(pHrdParameters.cpbSizeValue[0]))[i_4])
        unsafe(unsafe(addr(pHrdParameters.cpbSizeValue[0]))[i_4]) = uint(unsafe(unsafe(addr(pHrdParameters.cpbSizeValue[0]))[i_4]) * uint(int(1) << int(int(uint(4) + pHrdParameters.cpbSizeScale))))
        unsafe(unsafe(addr(pHrdParameters.cpbSizeValue[0]))[i_4])
        tmp_5 = uint(h264bsdGetBits(pStrmData_9, uint(1)))
        tmp_5
        if (tmp_5 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh20_h264bsd : int = 0
        if (tmp_5 == uint(1)) {
            c2da_fresh20_h264bsd = 1
        } else {
            c2da_fresh20_h264bsd = 0
        }
        unsafe(unsafe(addr(pHrdParameters.cbrFlag[0]))[i_4]) = uint(uint(c2da_fresh20_h264bsd))
        unsafe(unsafe(addr(pHrdParameters.cbrFlag[0]))[i_4])
        i_4 = i_4 + 1
    }
    tmp_5 = uint(h264bsdGetBits(pStrmData_9, uint(5)))
    tmp_5
    if (tmp_5 == 0xffffffff) {
        return uint(1)
    }
    pHrdParameters.initialCpbRemovalDelayLength = uint(tmp_5 + uint(1))
    pHrdParameters.initialCpbRemovalDelayLength
    tmp_5 = uint(h264bsdGetBits(pStrmData_9, uint(5)))
    tmp_5
    if (tmp_5 == 0xffffffff) {
        return uint(1)
    }
    pHrdParameters.cpbRemovalDelayLength = uint(tmp_5 + uint(1))
    pHrdParameters.cpbRemovalDelayLength
    tmp_5 = uint(h264bsdGetBits(pStrmData_9, uint(5)))
    tmp_5
    if (tmp_5 == 0xffffffff) {
        return uint(1)
    }
    pHrdParameters.dpbOutputDelayLength = uint(tmp_5 + uint(1))
    pHrdParameters.dpbOutputDelayLength
    tmp_5 = uint(h264bsdGetBits(pStrmData_9, uint(5)))
    tmp_5
    if (tmp_5 == 0xffffffff) {
        return uint(1)
    }
    pHrdParameters.timeOffsetLength = uint(tmp_5)
    pHrdParameters.timeOffsetLength
    return uint(0)
}
[export]
def h264bsdDecodeSeqParamSet(var pStrmData_10 : strmData_t?; var pSeqParamSet : seqParamSet_t?) : uint {
    var tmp_6 : uint
    if (tmp_6 != uint(66)) {
    }
    pSeqParamSet.profileIdc = uint(tmp_6)
    pSeqParamSet.profileIdc
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
    tmp_6
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
    tmp_6
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
    tmp_6
    if (tmp_6 == 0xffffffff) {
        return uint(1)
    }
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(5)))
    tmp_6
    if (tmp_6 == 0xffffffff) {
        return uint(1)
    }
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(8)))
    tmp_6
    if (tmp_6 == 0xffffffff) {
        return uint(1)
    }
    pSeqParamSet.levelIdc = uint(tmp_6)
    pSeqParamSet.levelIdc
    tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(pSeqParamSet.seqParameterSetId))))
    tmp_6
    if (tmp_6 != uint(0)) {
        return tmp_6
    }
    if (pSeqParamSet.seqParameterSetId >= uint(32)) {
        return uint(1)
    }
    tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(value_3))))
    tmp_6
    if (tmp_6 != uint(0)) {
        return tmp_6
    }
    if (value_3 > uint(12)) {
        return uint(1)
    }
    pSeqParamSet.maxFrameNum = uint(uint(int(1) << int(int(value_3 + uint(4)))))
    pSeqParamSet.maxFrameNum
    tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(value_3))))
    tmp_6
    if (tmp_6 != uint(0)) {
        return tmp_6
    }
    if (value_3 > uint(2)) {
        return uint(1)
    }
    pSeqParamSet.picOrderCntType = uint(value_3)
    pSeqParamSet.picOrderCntType
    if (pSeqParamSet.picOrderCntType == uint(0)) {
        tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(value_3))))
        tmp_6
        if (tmp_6 != uint(0)) {
            return tmp_6
        }
        if (value_3 > uint(12)) {
            return uint(1)
        }
        pSeqParamSet.maxPicOrderCntLsb = uint(uint(int(1) << int(int(value_3 + uint(4)))))
        pSeqParamSet.maxPicOrderCntLsb
    } else {
        if (pSeqParamSet.picOrderCntType == uint(1)) {
            tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
            tmp_6
            if (tmp_6 == 0xffffffff) {
                return uint(1)
            }
            var c2da_fresh21_h264bsd : int = 0
            if (tmp_6 == uint(1)) {
                c2da_fresh21_h264bsd = 1
            } else {
                c2da_fresh21_h264bsd = 0
            }
            pSeqParamSet.deltaPicOrderAlwaysZeroFlag = uint(uint(c2da_fresh21_h264bsd))
            pSeqParamSet.deltaPicOrderAlwaysZeroFlag
            tmp_6 = uint(h264bsdDecodeExpGolombSigned(pStrmData_10, unsafe(addr(pSeqParamSet.offsetForNonRefPic))))
            tmp_6
            if (tmp_6 != uint(0)) {
                return tmp_6
            }
            tmp_6 = uint(h264bsdDecodeExpGolombSigned(pStrmData_10, unsafe(addr(pSeqParamSet.offsetForTopToBottomField))))
            tmp_6
            if (tmp_6 != uint(0)) {
                return tmp_6
            }
            tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(pSeqParamSet.numRefFramesInPicOrderCntCycle))))
            tmp_6
            if (tmp_6 != uint(0)) {
                return tmp_6
            }
            if (pSeqParamSet.numRefFramesInPicOrderCntCycle > uint(255)) {
                return uint(1)
            }
            if (pSeqParamSet.numRefFramesInPicOrderCntCycle != 0x0) {
                pSeqParamSet.offsetForRefFrame = unsafe(unsafe(reinterpret<int?>(malloc(uint64(pSeqParamSet.numRefFramesInPicOrderCntCycle) * 4))))
                pSeqParamSet.offsetForRefFrame
                if (pSeqParamSet.offsetForRefFrame == unsafe(unsafe(reinterpret<int?>(uint64(0))))) {
                    return uint(65535)
                }
                i_5 = uint(uint(0))
                i_5
                while (i_5 < pSeqParamSet.numRefFramesInPicOrderCntCycle) {
                    tmp_6 = uint(h264bsdDecodeExpGolombSigned(pStrmData_10, unsafe(pSeqParamSet.offsetForRefFrame + i_5)))
                    tmp_6
                    if (tmp_6 != uint(0)) {
                        return tmp_6
                    }
                    i_5 = i_5 + 1
                }
            } else {
                pSeqParamSet.offsetForRefFrame = null
                pSeqParamSet.offsetForRefFrame
            }
        }
    }
    tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(pSeqParamSet.numRefFrames))))
    tmp_6
    if (tmp_6 != uint(0)) {
        return tmp_6
    }
    if (pSeqParamSet.numRefFrames > uint(16)) {
        return uint(1)
    }
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
    tmp_6
    if (tmp_6 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh22_h264bsd : int = 0
    if (tmp_6 == uint(1)) {
        c2da_fresh22_h264bsd = 1
    } else {
        c2da_fresh22_h264bsd = 0
    }
    pSeqParamSet.gapsInFrameNumValueAllowedFlag = uint(uint(c2da_fresh22_h264bsd))
    pSeqParamSet.gapsInFrameNumValueAllowedFlag
    tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(value_3))))
    tmp_6
    if (tmp_6 != uint(0)) {
        return tmp_6
    }
    pSeqParamSet.picWidthInMbs = uint(value_3 + uint(1))
    pSeqParamSet.picWidthInMbs
    tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(value_3))))
    tmp_6
    if (tmp_6 != uint(0)) {
        return tmp_6
    }
    pSeqParamSet.picHeightInMbs = uint(value_3 + uint(1))
    pSeqParamSet.picHeightInMbs
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
    tmp_6
    if (tmp_6 == 0xffffffff) {
        return uint(1)
    }
    if (tmp_6 == 0) {
        return uint(1)
    }
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
    tmp_6
    if (tmp_6 == 0xffffffff) {
        return uint(1)
    }
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
    tmp_6
    if (tmp_6 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh23_h264bsd : int = 0
    if (tmp_6 == uint(1)) {
        c2da_fresh23_h264bsd = 1
    } else {
        c2da_fresh23_h264bsd = 0
    }
    pSeqParamSet.frameCroppingFlag = uint(uint(c2da_fresh23_h264bsd))
    pSeqParamSet.frameCroppingFlag
    if (pSeqParamSet.frameCroppingFlag != 0x0) {
        tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(pSeqParamSet.frameCropLeftOffset))))
        tmp_6
        if (tmp_6 != uint(0)) {
            return tmp_6
        }
        tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(pSeqParamSet.frameCropRightOffset))))
        tmp_6
        if (tmp_6 != uint(0)) {
            return tmp_6
        }
        tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(pSeqParamSet.frameCropTopOffset))))
        tmp_6
        if (tmp_6 != uint(0)) {
            return tmp_6
        }
        tmp_6 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_10, unsafe(addr(pSeqParamSet.frameCropBottomOffset))))
        tmp_6
        if (tmp_6 != uint(0)) {
            return tmp_6
        }
        if (int(pSeqParamSet.frameCropLeftOffset) > 8 * int(pSeqParamSet.picWidthInMbs) - int(pSeqParamSet.frameCropRightOffset) + 1 || int(pSeqParamSet.frameCropTopOffset) > 8 * int(pSeqParamSet.picHeightInMbs) - int(pSeqParamSet.frameCropBottomOffset) + 1) {
            return uint(1)
        }
    }
    tmp_6 = uint(pSeqParamSet.picWidthInMbs * pSeqParamSet.picHeightInMbs)
    tmp_6
    value_3 = uint(GetDpbSize(tmp_6, pSeqParamSet.levelIdc))
    value_3
    if (value_3 == uint(INVALID_DPB_SIZE) || pSeqParamSet.numRefFrames > value_3) {
        value_3 = uint(pSeqParamSet.numRefFrames)
        value_3
    }
    pSeqParamSet.maxDpbSize = uint(value_3)
    pSeqParamSet.maxDpbSize
    tmp_6 = uint(h264bsdGetBits(pStrmData_10, uint(1)))
    tmp_6
    if (tmp_6 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh24_h264bsd : int = 0
    if (tmp_6 == uint(1)) {
        c2da_fresh24_h264bsd = 1
    } else {
        c2da_fresh24_h264bsd = 0
    }
    pSeqParamSet.vuiParametersPresentFlag = uint(uint(c2da_fresh24_h264bsd))
    pSeqParamSet.vuiParametersPresentFlag
    if (pSeqParamSet.vuiParametersPresentFlag != 0x0) {
        pSeqParamSet.vuiParameters = unsafe(unsafe(reinterpret<vuiParameters_t?>(malloc(uint64(1) * 4))))
        pSeqParamSet.vuiParameters
        if (pSeqParamSet.vuiParameters == unsafe(unsafe(reinterpret<vuiParameters_t?>(uint64(0))))) {
            return uint(65535)
        }
        tmp_6 = uint(h264bsdDecodeVuiParameters(pStrmData_10, pSeqParamSet.vuiParameters))
        tmp_6
        if (tmp_6 != uint(0)) {
            return tmp_6
        }
        if (pSeqParamSet.vuiParameters.bitstreamRestrictionFlag != 0x0) {
            if (pSeqParamSet.vuiParameters.numReorderFrames > pSeqParamSet.vuiParameters.maxDecFrameBuffering || pSeqParamSet.vuiParameters.maxDecFrameBuffering < pSeqParamSet.numRefFrames || pSeqParamSet.vuiParameters.maxDecFrameBuffering > pSeqParamSet.maxDpbSize) {
                return uint(1)
            }
            var c2da_fresh25_h264bsd : int = 0
            if (uint(1) > pSeqParamSet.vuiParameters.maxDecFrameBuffering) {
                c2da_fresh25_h264bsd = uint(1)
            } else {
                c2da_fresh25_h264bsd = pSeqParamSet.vuiParameters.maxDecFrameBuffering
            }
            pSeqParamSet.maxDpbSize = uint(c2da_fresh25_h264bsd)
            pSeqParamSet.maxDpbSize
        }
    }
    tmp_6 = uint(h264bsdRbspTrailingBits(pStrmData_10))
    tmp_6
    return uint(0)
}
[export]
def GetDpbSize(var picSizeInMbs_0 : uint; var levelIdc : uint) : uint {
    var tmp_7 : uint
    var maxPicSizeInMbs : uint
    if (levelIdc == uint(10)) {
        tmp_7 = uint(uint(152064))
        tmp_7
    } elif (levelIdc == uint(11)) {
        tmp_7 = uint(uint(345600))
        tmp_7
    } elif (levelIdc == uint(12)) {
        tmp_7 = uint(uint(912384))
        tmp_7
    } elif (levelIdc == uint(13)) {
        tmp_7 = uint(uint(912384))
        tmp_7
    } elif (levelIdc == uint(20)) {
        tmp_7 = uint(uint(912384))
        tmp_7
    } elif (levelIdc == uint(21)) {
        tmp_7 = uint(uint(1824768))
        tmp_7
    } elif (levelIdc == uint(22)) {
        tmp_7 = uint(uint(3110400))
        tmp_7
    } elif (levelIdc == uint(30)) {
        tmp_7 = uint(uint(3110400))
        tmp_7
    } elif (levelIdc == uint(31)) {
        tmp_7 = uint(uint(6912000))
        tmp_7
    } elif (levelIdc == uint(32)) {
        tmp_7 = uint(uint(7864320))
        tmp_7
    } elif (levelIdc == uint(40)) {
        tmp_7 = uint(uint(12582912))
        tmp_7
    } elif (levelIdc == uint(41)) {
        tmp_7 = uint(uint(12582912))
        tmp_7
    } elif (levelIdc == uint(42)) {
        tmp_7 = uint(uint(34816 * 384))
        tmp_7
    } elif (levelIdc == uint(50)) {
        tmp_7 = uint(uint(42393600))
        tmp_7
    } elif (levelIdc == uint(51)) {
        tmp_7 = uint(uint(70778880))
        tmp_7
    } else {
        return uint(INVALID_DPB_SIZE)
    }
    if (picSizeInMbs_0 > maxPicSizeInMbs) {
        return uint(INVALID_DPB_SIZE)
    }
    tmp_7 = uint(tmp_7 / picSizeInMbs_0 * uint(384))
    tmp_7
    var c2da_fresh26_h264bsd : int = 0
    if (tmp_7 < uint(16)) {
        c2da_fresh26_h264bsd = tmp_7
    } else {
        c2da_fresh26_h264bsd = uint(16)
    }
    return c2da_fresh26_h264bsd
}
[export]
def h264bsdDecodeExpGolombSigned(var pStrmData_11 : strmData_t?; var value_4 : int?) : uint {
    var status : uint
    var codeNum_0 : uint = uint(0)
    status = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_11, unsafe(addr(codeNum_0))))
    status
    if (codeNum_0 == 0xffffffff) {
        if (status == uint(0)) {
            return uint(1)
        } else {
            *value_4 = int(0x80000000)
            *value_4
            return uint(0)
        }
    } else {
        if (status == uint(0)) {
            var c2da_fresh27_h264bsd : int = 0
            if (codeNum_0 & uint(1)) {
                c2da_fresh27_h264bsd = int(uint(codeNum_0 + uint(1)) >> uint(uint(1)))
            } else {
                c2da_fresh27_h264bsd = -int(uint(codeNum_0 + uint(1)) >> uint(uint(1)))
            }
            *value_4 = c2da_fresh27_h264bsd
            *value_4
            return uint(0)
        }
    }
    return uint(1)
}
[export]
def h264bsdCompareSeqParamSets(var pSps1 : seqParamSet_t?; var pSps2 : seqParamSet_t?) : uint {
    var i_6 : uint
    if (pSps1.profileIdc == pSps2.profileIdc && pSps1.levelIdc == pSps2.levelIdc && pSps1.maxFrameNum == pSps2.maxFrameNum && pSps1.picOrderCntType == pSps2.picOrderCntType && pSps1.numRefFrames == pSps2.numRefFrames && pSps1.gapsInFrameNumValueAllowedFlag == pSps2.gapsInFrameNumValueAllowedFlag && pSps1.picWidthInMbs == pSps2.picWidthInMbs && pSps1.picHeightInMbs == pSps2.picHeightInMbs && pSps1.frameCroppingFlag == pSps2.frameCroppingFlag && pSps1.vuiParametersPresentFlag == pSps2.vuiParametersPresentFlag) {
        if (pSps1.picOrderCntType == uint(0)) {
            if (pSps1.maxPicOrderCntLsb != pSps2.maxPicOrderCntLsb) {
                return uint(1)
            }
        } else {
            if (pSps1.picOrderCntType == uint(1)) {
                if (pSps1.deltaPicOrderAlwaysZeroFlag != pSps2.deltaPicOrderAlwaysZeroFlag || pSps1.offsetForNonRefPic != pSps2.offsetForNonRefPic || pSps1.offsetForTopToBottomField != pSps2.offsetForTopToBottomField || pSps1.numRefFramesInPicOrderCntCycle != pSps2.numRefFramesInPicOrderCntCycle) {
                    return uint(1)
                } else {
                    i_6 = uint(uint(0))
                    i_6
                    while (i_6 < pSps1.numRefFramesInPicOrderCntCycle) {
                        if (unsafe(pSps1.offsetForRefFrame[i_6]) != unsafe(pSps2.offsetForRefFrame[i_6])) {
                            return uint(1)
                        }
                        i_6 = i_6 + 1
                    }
                }
            }
        }
        if (pSps1.frameCroppingFlag != 0x0) {
            if (pSps1.frameCropLeftOffset != pSps2.frameCropLeftOffset || pSps1.frameCropRightOffset != pSps2.frameCropRightOffset || pSps1.frameCropTopOffset != pSps2.frameCropTopOffset || pSps1.frameCropBottomOffset != pSps2.frameCropBottomOffset) {
                return uint(1)
            }
        }
        return uint(0)
    }
    return uint(1)
}
[export]
def h264bsdDecodePicParamSet(var pStrmData_12 : strmData_t?; var pPicParamSet : picParamSet_t?) : uint {
    var tmp_8 : uint
    var i_7 : uint
    var value_5 : uint
    var itmp : int
    memset(unsafe(unsafe(reinterpret<uint64>(pPicParamSet))), 0, 4)
    tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(pPicParamSet.picParameterSetId))))
    tmp_8
    if (tmp_8 != uint(0)) {
        return tmp_8
    }
    if (pPicParamSet.picParameterSetId >= uint(256)) {
        return uint(1)
    }
    tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(pPicParamSet.seqParameterSetId))))
    tmp_8
    if (tmp_8 != uint(0)) {
        return tmp_8
    }
    if (pPicParamSet.seqParameterSetId >= uint(32)) {
        return uint(1)
    }
    tmp_8 = uint(h264bsdGetBits(pStrmData_12, uint(1)))
    tmp_8
    if (tmp_8 != 0x0) {
        return uint(1)
    }
    tmp_8 = uint(h264bsdGetBits(pStrmData_12, uint(1)))
    tmp_8
    if (tmp_8 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh28_h264bsd : int = 0
    if (tmp_8 == uint(1)) {
        c2da_fresh28_h264bsd = 1
    } else {
        c2da_fresh28_h264bsd = 0
    }
    pPicParamSet.picOrderPresentFlag = uint(uint(c2da_fresh28_h264bsd))
    pPicParamSet.picOrderPresentFlag
    tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(value_5))))
    tmp_8
    if (tmp_8 != uint(0)) {
        return tmp_8
    }
    pPicParamSet.numSliceGroups = uint(value_5 + uint(1))
    pPicParamSet.numSliceGroups
    if (pPicParamSet.numSliceGroups > uint(8)) {
        return uint(1)
    }
    if (pPicParamSet.numSliceGroups > uint(1)) {
        tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(pPicParamSet.sliceGroupMapType))))
        tmp_8
        if (tmp_8 != uint(0)) {
            return tmp_8
        }
        if (pPicParamSet.sliceGroupMapType > uint(6)) {
            return uint(1)
        }
        if (pPicParamSet.sliceGroupMapType == uint(0)) {
            pPicParamSet.runLength = unsafe(unsafe(reinterpret<uint?>(malloc(uint64(pPicParamSet.numSliceGroups) * 4))))
            pPicParamSet.runLength
            if (pPicParamSet.runLength == unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
                return uint(65535)
            }
            i_7 = uint(uint(0))
            i_7
            while (i_7 < pPicParamSet.numSliceGroups) {
                tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(value_5))))
                tmp_8
                if (tmp_8 != uint(0)) {
                    return tmp_8
                }
                unsafe(pPicParamSet.runLength[i_7]) = uint(value_5 + uint(1))
                unsafe(pPicParamSet.runLength[i_7])
                i_7 = i_7 + 1
            }
        } else {
            if (pPicParamSet.sliceGroupMapType == uint(2)) {
                pPicParamSet.topLeft = unsafe(unsafe(reinterpret<uint?>(malloc(uint64(pPicParamSet.numSliceGroups - uint(1)) * 4))))
                pPicParamSet.topLeft
                pPicParamSet.bottomRight = unsafe(unsafe(reinterpret<uint?>(malloc(uint64(pPicParamSet.numSliceGroups - uint(1)) * 4))))
                pPicParamSet.bottomRight
                if (pPicParamSet.topLeft == unsafe(unsafe(reinterpret<uint?>(uint64(0)))) || pPicParamSet.bottomRight == unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
                    return uint(65535)
                }
                i_7 = uint(uint(0))
                i_7
                while (i_7 < pPicParamSet.numSliceGroups - uint(1)) {
                    tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(value_5))))
                    tmp_8
                    if (tmp_8 != uint(0)) {
                        return tmp_8
                    }
                    unsafe(pPicParamSet.topLeft[i_7]) = uint(value_5)
                    unsafe(pPicParamSet.topLeft[i_7])
                    tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(value_5))))
                    tmp_8
                    if (tmp_8 != uint(0)) {
                        return tmp_8
                    }
                    unsafe(pPicParamSet.bottomRight[i_7]) = uint(value_5)
                    unsafe(pPicParamSet.bottomRight[i_7])
                    i_7 = i_7 + 1
                }
            } else {
                if (pPicParamSet.sliceGroupMapType == uint(3) || pPicParamSet.sliceGroupMapType == uint(4) || pPicParamSet.sliceGroupMapType == uint(5)) {
                    tmp_8 = uint(h264bsdGetBits(pStrmData_12, uint(1)))
                    tmp_8
                    if (tmp_8 == 0xffffffff) {
                        return uint(1)
                    }
                    var c2da_fresh29_h264bsd : int = 0
                    if (tmp_8 == uint(1)) {
                        c2da_fresh29_h264bsd = 1
                    } else {
                        c2da_fresh29_h264bsd = 0
                    }
                    pPicParamSet.sliceGroupChangeDirectionFlag = uint(uint(c2da_fresh29_h264bsd))
                    pPicParamSet.sliceGroupChangeDirectionFlag
                    tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(value_5))))
                    tmp_8
                    if (tmp_8 != uint(0)) {
                        return tmp_8
                    }
                    pPicParamSet.sliceGroupChangeRate = uint(value_5 + uint(1))
                    pPicParamSet.sliceGroupChangeRate
                } else {
                    if (pPicParamSet.sliceGroupMapType == uint(6)) {
                        tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(value_5))))
                        tmp_8
                        if (tmp_8 != uint(0)) {
                            return tmp_8
                        }
                        pPicParamSet.picSizeInMapUnits = uint(value_5 + uint(1))
                        pPicParamSet.picSizeInMapUnits
                        pPicParamSet.sliceGroupId = unsafe(unsafe(reinterpret<uint?>(malloc(uint64(pPicParamSet.picSizeInMapUnits) * 4))))
                        pPicParamSet.sliceGroupId
                        if (pPicParamSet.sliceGroupId == unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
                            return uint(65535)
                        }
                        tmp_8 = uint(unsafe(unsafe(addr(CeilLog2NumSliceGroups[0]))[pPicParamSet.numSliceGroups - uint(1)]))
                        tmp_8
                        i_7 = uint(uint(0))
                        i_7
                        while (i_7 < pPicParamSet.picSizeInMapUnits) {
                            unsafe(pPicParamSet.sliceGroupId[i_7]) = uint(h264bsdGetBits(pStrmData_12, tmp_8))
                            unsafe(pPicParamSet.sliceGroupId[i_7])
                            if (unsafe(pPicParamSet.sliceGroupId[i_7]) >= pPicParamSet.numSliceGroups) {
                                return uint(1)
                            }
                            i_7 = i_7 + 1
                        }
                    }
                }
            }
        }
    }
    tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(value_5))))
    tmp_8
    if (tmp_8 != uint(0)) {
        return tmp_8
    }
    if (value_5 > uint(31)) {
        return uint(1)
    }
    pPicParamSet.numRefIdxL0Active = uint(value_5 + uint(1))
    pPicParamSet.numRefIdxL0Active
    tmp_8 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_12, unsafe(addr(value_5))))
    tmp_8
    if (tmp_8 != uint(0)) {
        return tmp_8
    }
    if (value_5 > uint(31)) {
        return uint(1)
    }
    tmp_8 = uint(h264bsdGetBits(pStrmData_12, uint(1)))
    tmp_8
    if (tmp_8 != 0x0) {
        return uint(1)
    }
    tmp_8 = uint(h264bsdGetBits(pStrmData_12, uint(2)))
    tmp_8
    if (tmp_8 > uint(2)) {
        return uint(1)
    }
    tmp_8 = uint(h264bsdDecodeExpGolombSigned(pStrmData_12, unsafe(addr(itmp))))
    tmp_8
    if (tmp_8 != uint(0)) {
        return tmp_8
    }
    if (itmp < -26 || itmp > 25) {
        return uint(1)
    }
    pPicParamSet.picInitQp = uint(uint(itmp + 26))
    pPicParamSet.picInitQp
    tmp_8 = uint(h264bsdDecodeExpGolombSigned(pStrmData_12, unsafe(addr(itmp))))
    tmp_8
    if (tmp_8 != uint(0)) {
        return tmp_8
    }
    if (itmp < -26 || itmp > 25) {
        return uint(1)
    }
    tmp_8 = uint(h264bsdDecodeExpGolombSigned(pStrmData_12, unsafe(addr(itmp))))
    tmp_8
    if (tmp_8 != uint(0)) {
        return tmp_8
    }
    if (itmp < -12 || itmp > 12) {
        return uint(1)
    }
    pPicParamSet.chromaQpIndexOffset = itmp
    pPicParamSet.chromaQpIndexOffset
    tmp_8 = uint(h264bsdGetBits(pStrmData_12, uint(1)))
    tmp_8
    if (tmp_8 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh30_h264bsd : int = 0
    if (tmp_8 == uint(1)) {
        c2da_fresh30_h264bsd = 1
    } else {
        c2da_fresh30_h264bsd = 0
    }
    pPicParamSet.deblockingFilterControlPresentFlag = uint(uint(c2da_fresh30_h264bsd))
    pPicParamSet.deblockingFilterControlPresentFlag
    tmp_8 = uint(h264bsdGetBits(pStrmData_12, uint(1)))
    tmp_8
    if (tmp_8 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh31_h264bsd : int = 0
    if (tmp_8 == uint(1)) {
        c2da_fresh31_h264bsd = 1
    } else {
        c2da_fresh31_h264bsd = 0
    }
    pPicParamSet.constrainedIntraPredFlag = uint(uint(c2da_fresh31_h264bsd))
    pPicParamSet.constrainedIntraPredFlag
    tmp_8 = uint(h264bsdGetBits(pStrmData_12, uint(1)))
    tmp_8
    if (tmp_8 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh32_h264bsd : int = 0
    if (tmp_8 == uint(1)) {
        c2da_fresh32_h264bsd = 1
    } else {
        c2da_fresh32_h264bsd = 0
    }
    pPicParamSet.redundantPicCntPresentFlag = uint(uint(c2da_fresh32_h264bsd))
    pPicParamSet.redundantPicCntPresentFlag
    tmp_8 = uint(h264bsdRbspTrailingBits(pStrmData_12))
    tmp_8
    return uint(0)
}
var CeilLog2NumSliceGroups : array<uint> const = [uint(1), uint(1), uint(2), uint(2), uint(3), uint(3), uint(3), uint(3)]

[export]
def h264bsdDecodeNalUnit(var pStrmData_13 : strmData_t?; var pNalUnit : nalUnit_t?) : uint {
    var tmp_9 : uint
    tmp_9 = uint(h264bsdGetBits(pStrmData_13, uint(1)))
    tmp_9
    if (tmp_9 == 0xffffffff) {
        return uint(1)
    }
    tmp_9 = uint(h264bsdGetBits(pStrmData_13, uint(2)))
    tmp_9
    pNalUnit.nalRefIdc = uint(tmp_9)
    pNalUnit.nalRefIdc
    tmp_9 = uint(h264bsdGetBits(pStrmData_13, uint(5)))
    tmp_9
    pNalUnit.nalUnitType = cast<nalUnitType_e>(tmp_9)
    pNalUnit.nalUnitType
    if (tmp_9 == uint(2) || tmp_9 == uint(3) || tmp_9 == uint(4)) {
        return uint(1)
    }
    if (tmp_9 == uint(NAL_SEQ_PARAM_SET) || tmp_9 == uint(NAL_PIC_PARAM_SET) || tmp_9 == uint(NAL_CODED_SLICE_IDR) && pNalUnit.nalRefIdc == uint(0)) {
        return uint(1)
    } else {
        if (tmp_9 == uint(NAL_SEI) || tmp_9 == uint(NAL_ACCESS_UNIT_DELIMITER) || tmp_9 == uint(NAL_END_OF_SEQUENCE) || tmp_9 == uint(NAL_END_OF_STREAM) || tmp_9 == uint(NAL_FILLER_DATA) && pNalUnit.nalRefIdc != uint(0)) {
            return uint(1)
        }
    }
    return uint(0)
}
[export]
def h264bsdDecodeSliceHeader(var pStrmData_14 : strmData_t?; var pSliceHeader : sliceHeader_t?; var pSeqParamSet_0 : seqParamSet_t?; var pPicParamSet_0 : picParamSet_t?; var pNalUnit_0 : nalUnit_t?) : uint {
    var tmp_10 : uint
    var i_8 : uint
    var value_6 : uint
    var itmp_0 : int
    var picSizeInMbs_1 : uint
    memset(unsafe(unsafe(reinterpret<uint64>(pSliceHeader))), 0, 4)
    picSizeInMbs_1 = uint(pSeqParamSet_0.picWidthInMbs * pSeqParamSet_0.picHeightInMbs)
    picSizeInMbs_1
    tmp_10 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_14, unsafe(addr(value_6))))
    tmp_10
    if (tmp_10 != uint(0)) {
        return tmp_10
    }
    pSliceHeader.firstMbInSlice = uint(value_6)
    pSliceHeader.firstMbInSlice
    if (value_6 >= picSizeInMbs_1) {
        return uint(1)
    }
    tmp_10 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_14, unsafe(addr(value_6))))
    tmp_10
    if (tmp_10 != uint(0)) {
        return tmp_10
    }
    pSliceHeader.sliceType = uint(value_6)
    pSliceHeader.sliceType
    if (pSliceHeader.sliceType == uint(I_SLICE) || pSliceHeader.sliceType == uint(I_SLICE + 5) == 0 && pSliceHeader.sliceType == uint(P_SLICE) || pSliceHeader.sliceType == uint(P_SLICE + 5) == 0 || uint(pNalUnit_0.nalUnitType) == uint(NAL_CODED_SLICE_IDR) || pSeqParamSet_0.numRefFrames == 0) {
        return uint(1)
    }
    tmp_10 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_14, unsafe(addr(value_6))))
    tmp_10
    if (tmp_10 != uint(0)) {
        return tmp_10
    }
    pSliceHeader.picParameterSetId = uint(value_6)
    pSliceHeader.picParameterSetId
    if (pSliceHeader.picParameterSetId != pPicParamSet_0.picParameterSetId) {
        return uint(1)
    }
    i_8 = uint(uint(0))
    i_8
    while (pSeqParamSet_0.maxFrameNum >> i_8 != 0x0) {
        i_8 = i_8 + 1
        i_8
    }
    i_8 = i_8 - 1
    i_8
    tmp_10 = uint(h264bsdGetBits(pStrmData_14, i_8))
    tmp_10
    if (tmp_10 == 0xffffffff) {
        return uint(1)
    }
    if (uint(pNalUnit_0.nalUnitType) == uint(NAL_CODED_SLICE_IDR) && tmp_10 != uint(0)) {
        return uint(1)
    }
    pSliceHeader.frameNum = uint(tmp_10)
    pSliceHeader.frameNum
    if (uint(pNalUnit_0.nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
        tmp_10 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_14, unsafe(addr(value_6))))
        tmp_10
        if (tmp_10 != uint(0)) {
            return tmp_10
        }
        pSliceHeader.idrPicId = uint(value_6)
        pSliceHeader.idrPicId
        if (value_6 > uint(65535)) {
            return uint(1)
        }
    }
    if (pSeqParamSet_0.picOrderCntType == uint(0)) {
        i_8 = uint(uint(0))
        i_8
        while (pSeqParamSet_0.maxPicOrderCntLsb >> i_8 != 0x0) {
            i_8 = i_8 + 1
            i_8
        }
        i_8 = i_8 - 1
        i_8
        tmp_10 = uint(h264bsdGetBits(pStrmData_14, i_8))
        tmp_10
        if (tmp_10 == 0xffffffff) {
            return uint(1)
        }
        pSliceHeader.picOrderCntLsb = uint(tmp_10)
        pSliceHeader.picOrderCntLsb
        if (pPicParamSet_0.picOrderPresentFlag != 0x0) {
            tmp_10 = uint(h264bsdDecodeExpGolombSigned(pStrmData_14, unsafe(addr(itmp_0))))
            tmp_10
            if (tmp_10 != uint(0)) {
                return tmp_10
            }
            pSliceHeader.deltaPicOrderCntBottom = itmp_0
            pSliceHeader.deltaPicOrderCntBottom
        }
        if (uint(pNalUnit_0.nalUnitType) == uint(NAL_CODED_SLICE_IDR) && pSliceHeader.picOrderCntLsb > pSeqParamSet_0.maxPicOrderCntLsb / uint(2) || c2da_fresh33_h264bsd != 0) {
            return uint(1)
        }
    }
    if (pSeqParamSet_0.picOrderCntType == uint(1) && pSeqParamSet_0.deltaPicOrderAlwaysZeroFlag == 0) {
        tmp_10 = uint(h264bsdDecodeExpGolombSigned(pStrmData_14, unsafe(addr(itmp_0))))
        tmp_10
        if (tmp_10 != uint(0)) {
            return tmp_10
        }
        unsafe(unsafe(addr(pSliceHeader.deltaPicOrderCnt[0]))[0]) = itmp_0
        unsafe(unsafe(addr(pSliceHeader.deltaPicOrderCnt[0]))[0])
        if (pPicParamSet_0.picOrderPresentFlag != 0x0) {
            tmp_10 = uint(h264bsdDecodeExpGolombSigned(pStrmData_14, unsafe(addr(itmp_0))))
            tmp_10
            if (tmp_10 != uint(0)) {
                return tmp_10
            }
            unsafe(unsafe(addr(pSliceHeader.deltaPicOrderCnt[0]))[1]) = itmp_0
            unsafe(unsafe(addr(pSliceHeader.deltaPicOrderCnt[0]))[1])
        }
        if (uint(pNalUnit_0.nalUnitType) == uint(NAL_CODED_SLICE_IDR) && c2da_fresh34_h264bsd != 0) {
            return uint(1)
        }
    }
    if (pPicParamSet_0.redundantPicCntPresentFlag != 0x0) {
        tmp_10 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_14, unsafe(addr(value_6))))
        tmp_10
        if (tmp_10 != uint(0)) {
            return tmp_10
        }
        pSliceHeader.redundantPicCnt = uint(value_6)
        pSliceHeader.redundantPicCnt
        if (value_6 > uint(127)) {
            return uint(1)
        }
    }
    if (pSliceHeader.sliceType == uint(P_SLICE) || pSliceHeader.sliceType == uint(P_SLICE + 5)) {
        tmp_10 = uint(h264bsdGetBits(pStrmData_14, uint(1)))
        tmp_10
        if (tmp_10 == 0xffffffff) {
            return uint(1)
        }
        pSliceHeader.numRefIdxActiveOverrideFlag = uint(tmp_10)
        pSliceHeader.numRefIdxActiveOverrideFlag
        if (pSliceHeader.numRefIdxActiveOverrideFlag != 0x0) {
            tmp_10 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_14, unsafe(addr(value_6))))
            tmp_10
            if (tmp_10 != uint(0)) {
                return tmp_10
            }
            if (value_6 > uint(15)) {
                return uint(1)
            }
            pSliceHeader.numRefIdxL0Active = uint(value_6 + uint(1))
            pSliceHeader.numRefIdxL0Active
        } else {
            if (pPicParamSet_0.numRefIdxL0Active > uint(16)) {
                return uint(1)
            }
            pSliceHeader.numRefIdxL0Active = uint(pPicParamSet_0.numRefIdxL0Active)
            pSliceHeader.numRefIdxL0Active
        }
    }
    if (pSliceHeader.sliceType == uint(P_SLICE) || pSliceHeader.sliceType == uint(P_SLICE + 5)) {
        tmp_10 = uint(RefPicListReordering(pStrmData_14, unsafe(addr(pSliceHeader.refPicListReordering)), pSliceHeader.numRefIdxL0Active, pSeqParamSet_0.maxFrameNum))
        tmp_10
        if (tmp_10 != uint(0)) {
            return tmp_10
        }
    }
    if (pNalUnit_0.nalRefIdc != uint(0)) {
        tmp_10 = uint(DecRefPicMarking(pStrmData_14, unsafe(addr(pSliceHeader.decRefPicMarking)), pNalUnit_0.nalUnitType, pSeqParamSet_0.numRefFrames))
        tmp_10
        if (tmp_10 != uint(0)) {
            return tmp_10
        }
    }
    tmp_10 = uint(h264bsdDecodeExpGolombSigned(pStrmData_14, unsafe(addr(itmp_0))))
    tmp_10
    if (tmp_10 != uint(0)) {
        return tmp_10
    }
    pSliceHeader.sliceQpDelta = itmp_0
    pSliceHeader.sliceQpDelta
    itmp_0 = itmp_0 + int(pPicParamSet_0.picInitQp)
    itmp_0
    if (itmp_0 < 0 || itmp_0 > 51) {
        return uint(1)
    }
    if (pPicParamSet_0.deblockingFilterControlPresentFlag != 0x0) {
        tmp_10 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_14, unsafe(addr(value_6))))
        tmp_10
        if (tmp_10 != uint(0)) {
            return tmp_10
        }
        pSliceHeader.disableDeblockingFilterIdc = uint(value_6)
        pSliceHeader.disableDeblockingFilterIdc
        if (pSliceHeader.disableDeblockingFilterIdc > uint(2)) {
            return uint(1)
        }
        if (pSliceHeader.disableDeblockingFilterIdc != uint(1)) {
            tmp_10 = uint(h264bsdDecodeExpGolombSigned(pStrmData_14, unsafe(addr(itmp_0))))
            tmp_10
            if (tmp_10 != uint(0)) {
                return tmp_10
            }
            if (itmp_0 < -6 || itmp_0 > 6) {
                return uint(1)
            }
            pSliceHeader.sliceAlphaC0Offset = itmp_0 * 2
            pSliceHeader.sliceAlphaC0Offset
            tmp_10 = uint(h264bsdDecodeExpGolombSigned(pStrmData_14, unsafe(addr(itmp_0))))
            tmp_10
            if (tmp_10 != uint(0)) {
                return tmp_10
            }
            if (itmp_0 < -6 || itmp_0 > 6) {
                return uint(1)
            }
            pSliceHeader.sliceBetaOffset = itmp_0 * 2
            pSliceHeader.sliceBetaOffset
        }
    }
    if (pPicParamSet_0.numSliceGroups > uint(1) && pPicParamSet_0.sliceGroupMapType >= uint(3) && pPicParamSet_0.sliceGroupMapType <= uint(5)) {
        tmp_10 = uint(NumSliceGroupChangeCycleBits(picSizeInMbs_1, pPicParamSet_0.sliceGroupChangeRate))
        tmp_10
        value_6 = uint(h264bsdGetBits(pStrmData_14, tmp_10))
        value_6
        if (value_6 == 0xffffffff) {
            return uint(1)
        }
        pSliceHeader.sliceGroupChangeCycle = uint(value_6)
        pSliceHeader.sliceGroupChangeCycle
        tmp_10 = uint(picSizeInMbs_1 + pPicParamSet_0.sliceGroupChangeRate - uint(1) / pPicParamSet_0.sliceGroupChangeRate)
        tmp_10
        if (pSliceHeader.sliceGroupChangeCycle > tmp_10) {
            return uint(1)
        }
    }
    return uint(0)
}
[export]
def NumSliceGroupChangeCycleBits(var picSizeInMbs_2 : uint; var sliceGroupChangeRate : uint) : uint {
    var tmp_11 : uint
    var numBits_1 : uint
    var mask_0 : uint
    if (picSizeInMbs_2 % sliceGroupChangeRate != 0x0) {
        tmp_11 = uint(uint(2) + picSizeInMbs_2 / sliceGroupChangeRate)
        tmp_11
    } else {
        tmp_11 = uint(uint(1) + picSizeInMbs_2 / sliceGroupChangeRate)
        tmp_11
    }
    numBits_1 = uint(uint(0))
    numBits_1
    mask_0 = uint(~0x0)
    mask_0
    while (tmp_11 & mask_0 << numBits_1 != 0x0) {
    }
    numBits_1 = numBits_1 - 1
    numBits_1
    if (tmp_11 & uint(int(1) << int(int(numBits_1)) - 1) != 0x0) {
        numBits_1 = numBits_1 + 1
        numBits_1
    }
    return numBits_1
}
[export]
def DecRefPicMarking(var pStrmData_15 : strmData_t?; var pDecRefPicMarking : decRefPicMarking_t?; var nalUnitType : nalUnitType_e; var numRefFrames : uint) : uint {
    var tmp_12 : uint
    var value_7 : uint
    var i_9 : uint
    var operation : uint
    var num4 : uint = uint(0)
    var num5 : uint = uint(0)
    var num6 : uint = uint(0)
    var num1to3 : uint = uint(0)
    if (uint(nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
        tmp_12 = uint(h264bsdGetBits(pStrmData_15, uint(1)))
        tmp_12
        if (tmp_12 == 0xffffffff) {
            return uint(1)
        }
        pDecRefPicMarking.noOutputOfPriorPicsFlag = uint(tmp_12)
        pDecRefPicMarking.noOutputOfPriorPicsFlag
        tmp_12 = uint(h264bsdGetBits(pStrmData_15, uint(1)))
        tmp_12
        if (tmp_12 == 0xffffffff) {
            return uint(1)
        }
        pDecRefPicMarking.longTermReferenceFlag = uint(tmp_12)
        pDecRefPicMarking.longTermReferenceFlag
        if (numRefFrames == 0 && pDecRefPicMarking.longTermReferenceFlag != 0x0) {
            return uint(1)
        }
    } else {
        tmp_12 = uint(h264bsdGetBits(pStrmData_15, uint(1)))
        tmp_12
        if (tmp_12 == 0xffffffff) {
            return uint(1)
        }
        pDecRefPicMarking.adaptiveRefPicMarkingModeFlag = uint(tmp_12)
        pDecRefPicMarking.adaptiveRefPicMarkingModeFlag
        if (pDecRefPicMarking.adaptiveRefPicMarkingModeFlag != 0x0) {
            i_9 = uint(uint(0))
            i_9
            var _dw_17495 : bool = true
            while (_dw_17495 || operation != uint(0)) {
                _dw_17495 = false
                if (i_9 > uint(2) * numRefFrames + uint(2)) {
                    return uint(1)
                }
                tmp_12 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_15, unsafe(addr(operation))))
                tmp_12
                if (tmp_12 != uint(0)) {
                    return tmp_12
                }
                if (operation > uint(6)) {
                    return uint(1)
                }
                unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).memoryManagementControlOperation = uint(operation)
                unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).memoryManagementControlOperation
                if (operation == uint(1) || operation == uint(3)) {
                    tmp_12 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_15, unsafe(addr(value_7))))
                    tmp_12
                    if (tmp_12 != uint(0)) {
                        return tmp_12
                    }
                    unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).differenceOfPicNums = uint(value_7 + uint(1))
                    unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).differenceOfPicNums
                }
                if (operation == uint(2)) {
                    tmp_12 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_15, unsafe(addr(value_7))))
                    tmp_12
                    if (tmp_12 != uint(0)) {
                        return tmp_12
                    }
                    unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).longTermPicNum = uint(value_7)
                    unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).longTermPicNum
                }
                if (operation == uint(3) || operation == uint(6)) {
                    tmp_12 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_15, unsafe(addr(value_7))))
                    tmp_12
                    if (tmp_12 != uint(0)) {
                        return tmp_12
                    }
                    unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).longTermFrameIdx = uint(value_7)
                    unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).longTermFrameIdx
                }
                if (operation == uint(4)) {
                    tmp_12 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_15, unsafe(addr(value_7))))
                    tmp_12
                    if (tmp_12 != uint(0)) {
                        return tmp_12
                    }
                    if (value_7 > numRefFrames) {
                        return uint(1)
                    }
                    if (value_7 == uint(0)) {
                        unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).maxLongTermFrameIdx = uint(uint(NO_LONG_TERM_FRAME_INDICES))
                        unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).maxLongTermFrameIdx
                    } else {
                        unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).maxLongTermFrameIdx = uint(value_7 - uint(1))
                        unsafe(unsafe(addr(pDecRefPicMarking.operation[0]))[i_9]).maxLongTermFrameIdx
                    }
                    num4 = num4 + 1
                    num4
                }
                if (operation == uint(5)) {
                    num5 = num5 + 1
                    num5
                }
                if (operation != 0x0 && operation <= uint(3)) {
                    num1to3 = num1to3 + 1
                    num1to3
                }
                if (operation == uint(6)) {
                    num6 = num6 + 1
                    num6
                }
                i_9 = i_9 + 1
                i_9
            }
            if (num4 > uint(1) || num5 > uint(1) || num6 > uint(1) || num1to3 != 0x0 && num5 != 0x0) {
                return uint(1)
            }
        }
    }
    return uint(0)
}
[export]
def RefPicListReordering(var pStrmData_16 : strmData_t?; var pRefPicListReordering : refPicListReordering_t?; var numRefIdxActive : uint; var maxPicNum : uint) : uint {
    var tmp_13 : uint
    var value_8 : uint
    var i_10 : uint
    var command : uint
    tmp_13 = uint(h264bsdGetBits(pStrmData_16, uint(1)))
    tmp_13
    if (tmp_13 == 0xffffffff) {
        return uint(1)
    }
    pRefPicListReordering.refPicListReorderingFlagL0 = uint(tmp_13)
    pRefPicListReordering.refPicListReorderingFlagL0
    if (pRefPicListReordering.refPicListReorderingFlagL0 != 0x0) {
        i_10 = uint(uint(0))
        i_10
        var _dw_18025 : bool = true
        while (_dw_18025 || command != uint(3)) {
            _dw_18025 = false
            if (i_10 > numRefIdxActive) {
                return uint(1)
            }
            tmp_13 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_16, unsafe(addr(command))))
            tmp_13
            if (tmp_13 != uint(0)) {
                return tmp_13
            }
            if (command > uint(3)) {
                return uint(1)
            }
            unsafe(unsafe(addr(pRefPicListReordering.command[0]))[i_10]).reorderingOfPicNumsIdc = uint(command)
            unsafe(unsafe(addr(pRefPicListReordering.command[0]))[i_10]).reorderingOfPicNumsIdc
            if (command == uint(0) || command == uint(1)) {
                tmp_13 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_16, unsafe(addr(value_8))))
                tmp_13
                if (tmp_13 != uint(0)) {
                    return tmp_13
                }
                if (value_8 >= maxPicNum) {
                    return uint(1)
                }
                unsafe(unsafe(addr(pRefPicListReordering.command[0]))[i_10]).absDiffPicNum = uint(value_8 + uint(1))
                unsafe(unsafe(addr(pRefPicListReordering.command[0]))[i_10]).absDiffPicNum
            } else {
                if (command == uint(2)) {
                    tmp_13 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_16, unsafe(addr(value_8))))
                    tmp_13
                    if (tmp_13 != uint(0)) {
                        return tmp_13
                    }
                    unsafe(unsafe(addr(pRefPicListReordering.command[0]))[i_10]).longTermPicNum = uint(value_8)
                    unsafe(unsafe(addr(pRefPicListReordering.command[0]))[i_10]).longTermPicNum
                }
            }
            i_10 = i_10 + 1
            i_10
        }
        if (i_10 == uint(1)) {
            return uint(1)
        }
    }
    return uint(0)
}
[export]
def h264bsdCheckPpsId(var pStrmData_17 : strmData_t?; var picParamSetId : uint?) : uint {
    var tmp_14 : uint
    var value_9 : uint
    var tmpStrmData : array<strmData_t> = [0]
    *unsafe(addr(tmpStrmData[0])) = *pStrmData_17
    *unsafe(addr(tmpStrmData[0]))
    tmp_14 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData[0])), unsafe(addr(value_9))))
    tmp_14
    if (tmp_14 != uint(0)) {
        return tmp_14
    }
    tmp_14 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData[0])), unsafe(addr(value_9))))
    tmp_14
    if (tmp_14 != uint(0)) {
        return tmp_14
    }
    tmp_14 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData[0])), unsafe(addr(value_9))))
    tmp_14
    if (tmp_14 != uint(0)) {
        return tmp_14
    }
    if (value_9 >= uint(256)) {
        return uint(1)
    }
    *picParamSetId = uint(value_9)
    *picParamSetId
    return uint(0)
}
[export]
def h264bsdCheckFrameNum(var pStrmData_18 : strmData_t?; var maxFrameNum : uint; var frameNum : uint?) : uint {
    var tmp_15 : uint
    var value_10 : uint
    var i_11 : uint
    var tmpStrmData_0 : array<strmData_t> = [0]
    *unsafe(addr(tmpStrmData_0[0])) = *pStrmData_18
    *unsafe(addr(tmpStrmData_0[0]))
    tmp_15 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_0[0])), unsafe(addr(value_10))))
    tmp_15
    if (tmp_15 != uint(0)) {
        return tmp_15
    }
    tmp_15 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_0[0])), unsafe(addr(value_10))))
    tmp_15
    if (tmp_15 != uint(0)) {
        return tmp_15
    }
    tmp_15 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_0[0])), unsafe(addr(value_10))))
    tmp_15
    if (tmp_15 != uint(0)) {
        return tmp_15
    }
    i_11 = uint(uint(0))
    i_11
    while (maxFrameNum >> i_11 != 0x0) {
        i_11 = i_11 + 1
        i_11
    }
    i_11 = i_11 - 1
    i_11
    tmp_15 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_0[0])), i_11))
    tmp_15
    if (tmp_15 == 0xffffffff) {
        return uint(1)
    }
    *frameNum = uint(tmp_15)
    *frameNum
    return uint(0)
}
[export]
def h264bsdCheckIdrPicId(var pStrmData_19 : strmData_t?; var maxFrameNum_0 : uint; var nalUnitType_0 : nalUnitType_e; var idrPicId : uint?) : uint {
    var tmp_16 : uint
    var value_11 : uint
    var i_12 : uint
    var tmpStrmData_1 : array<strmData_t> = [0]
    if (uint(nalUnitType_0) != uint(NAL_CODED_SLICE_IDR)) {
        return uint(1)
    }
    *unsafe(addr(tmpStrmData_1[0])) = *pStrmData_19
    *unsafe(addr(tmpStrmData_1[0]))
    tmp_16 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_1[0])), unsafe(addr(value_11))))
    tmp_16
    if (tmp_16 != uint(0)) {
        return tmp_16
    }
    tmp_16 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_1[0])), unsafe(addr(value_11))))
    tmp_16
    if (tmp_16 != uint(0)) {
        return tmp_16
    }
    tmp_16 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_1[0])), unsafe(addr(value_11))))
    tmp_16
    if (tmp_16 != uint(0)) {
        return tmp_16
    }
    i_12 = uint(uint(0))
    i_12
    while (maxFrameNum_0 >> i_12 != 0x0) {
        i_12 = i_12 + 1
        i_12
    }
    i_12 = i_12 - 1
    i_12
    tmp_16 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_1[0])), i_12))
    tmp_16
    if (tmp_16 == 0xffffffff) {
        return uint(1)
    }
    tmp_16 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_1[0])), idrPicId))
    tmp_16
    if (tmp_16 != uint(0)) {
        return tmp_16
    }
    return uint(0)
}
[export]
def h264bsdCheckPicOrderCntLsb(var pStrmData_20 : strmData_t?; var pSeqParamSet_1 : seqParamSet_t?; var nalUnitType_1 : nalUnitType_e; var picOrderCntLsb : uint?) : uint {
    var tmp_17 : uint
    var value_12 : uint
    var i_13 : uint
    var tmpStrmData_2 : array<strmData_t> = [0]
    *unsafe(addr(tmpStrmData_2[0])) = *pStrmData_20
    *unsafe(addr(tmpStrmData_2[0]))
    tmp_17 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_2[0])), unsafe(addr(value_12))))
    tmp_17
    if (tmp_17 != uint(0)) {
        return tmp_17
    }
    tmp_17 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_2[0])), unsafe(addr(value_12))))
    tmp_17
    if (tmp_17 != uint(0)) {
        return tmp_17
    }
    tmp_17 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_2[0])), unsafe(addr(value_12))))
    tmp_17
    if (tmp_17 != uint(0)) {
        return tmp_17
    }
    i_13 = uint(uint(0))
    i_13
    while (pSeqParamSet_1.maxFrameNum >> i_13 != 0x0) {
        i_13 = i_13 + 1
        i_13
    }
    i_13 = i_13 - 1
    i_13
    tmp_17 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_2[0])), i_13))
    tmp_17
    if (tmp_17 == 0xffffffff) {
        return uint(1)
    }
    if (uint(nalUnitType_1) == uint(NAL_CODED_SLICE_IDR)) {
        tmp_17 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_2[0])), unsafe(addr(value_12))))
        tmp_17
        if (tmp_17 != uint(0)) {
            return tmp_17
        }
    }
    i_13 = uint(uint(0))
    i_13
    while (pSeqParamSet_1.maxPicOrderCntLsb >> i_13 != 0x0) {
        i_13 = i_13 + 1
        i_13
    }
    i_13 = i_13 - 1
    i_13
    tmp_17 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_2[0])), i_13))
    tmp_17
    if (tmp_17 == 0xffffffff) {
        return uint(1)
    }
    *picOrderCntLsb = uint(tmp_17)
    *picOrderCntLsb
    return uint(0)
}
[export]
def h264bsdCheckDeltaPicOrderCntBottom(var pStrmData_21 : strmData_t?; var pSeqParamSet_2 : seqParamSet_t?; var nalUnitType_2 : nalUnitType_e; var deltaPicOrderCntBottom : int?) : uint {
    var tmp_18 : uint
    var value_13 : uint
    var i_14 : uint
    var tmpStrmData_3 : array<strmData_t> = [0]
    *unsafe(addr(tmpStrmData_3[0])) = *pStrmData_21
    *unsafe(addr(tmpStrmData_3[0]))
    tmp_18 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_3[0])), unsafe(addr(value_13))))
    tmp_18
    if (tmp_18 != uint(0)) {
        return tmp_18
    }
    tmp_18 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_3[0])), unsafe(addr(value_13))))
    tmp_18
    if (tmp_18 != uint(0)) {
        return tmp_18
    }
    tmp_18 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_3[0])), unsafe(addr(value_13))))
    tmp_18
    if (tmp_18 != uint(0)) {
        return tmp_18
    }
    i_14 = uint(uint(0))
    i_14
    while (pSeqParamSet_2.maxFrameNum >> i_14 != 0x0) {
        i_14 = i_14 + 1
        i_14
    }
    i_14 = i_14 - 1
    i_14
    tmp_18 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_3[0])), i_14))
    tmp_18
    if (tmp_18 == 0xffffffff) {
        return uint(1)
    }
    if (uint(nalUnitType_2) == uint(NAL_CODED_SLICE_IDR)) {
        tmp_18 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_3[0])), unsafe(addr(value_13))))
        tmp_18
        if (tmp_18 != uint(0)) {
            return tmp_18
        }
    }
    i_14 = uint(uint(0))
    i_14
    while (pSeqParamSet_2.maxPicOrderCntLsb >> i_14 != 0x0) {
        i_14 = i_14 + 1
        i_14
    }
    i_14 = i_14 - 1
    i_14
    tmp_18 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_3[0])), i_14))
    tmp_18
    if (tmp_18 == 0xffffffff) {
        return uint(1)
    }
    tmp_18 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_3[0])), deltaPicOrderCntBottom))
    tmp_18
    if (tmp_18 != uint(0)) {
        return tmp_18
    }
    return uint(0)
}
[export]
def h264bsdCheckDeltaPicOrderCnt(var pStrmData_22 : strmData_t?; var pSeqParamSet_3 : seqParamSet_t?; var nalUnitType_3 : nalUnitType_e; var picOrderPresentFlag : uint; var deltaPicOrderCnt : int?) : uint {
    var tmp_19 : uint
    var value_14 : uint
    var i_15 : uint
    var tmpStrmData_4 : array<strmData_t> = [0]
    *unsafe(addr(tmpStrmData_4[0])) = *pStrmData_22
    *unsafe(addr(tmpStrmData_4[0]))
    tmp_19 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_4[0])), unsafe(addr(value_14))))
    tmp_19
    if (tmp_19 != uint(0)) {
        return tmp_19
    }
    tmp_19 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_4[0])), unsafe(addr(value_14))))
    tmp_19
    if (tmp_19 != uint(0)) {
        return tmp_19
    }
    tmp_19 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_4[0])), unsafe(addr(value_14))))
    tmp_19
    if (tmp_19 != uint(0)) {
        return tmp_19
    }
    i_15 = uint(uint(0))
    i_15
    while (pSeqParamSet_3.maxFrameNum >> i_15 != 0x0) {
        i_15 = i_15 + 1
        i_15
    }
    i_15 = i_15 - 1
    i_15
    tmp_19 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_4[0])), i_15))
    tmp_19
    if (tmp_19 == 0xffffffff) {
        return uint(1)
    }
    if (uint(nalUnitType_3) == uint(NAL_CODED_SLICE_IDR)) {
        tmp_19 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_4[0])), unsafe(addr(value_14))))
        tmp_19
        if (tmp_19 != uint(0)) {
            return tmp_19
        }
    }
    tmp_19 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_4[0])), unsafe(addr(unsafe(deltaPicOrderCnt[0])))))
    tmp_19
    if (tmp_19 != uint(0)) {
        return tmp_19
    }
    if (picOrderPresentFlag != 0x0) {
        tmp_19 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_4[0])), unsafe(addr(unsafe(deltaPicOrderCnt[1])))))
        tmp_19
        if (tmp_19 != uint(0)) {
            return tmp_19
        }
    }
    return uint(0)
}
[export]
def h264bsdCheckRedundantPicCnt(var pStrmData_23 : strmData_t?; var pSeqParamSet_4 : seqParamSet_t?; var pPicParamSet_1 : picParamSet_t?; var nalUnitType_4 : nalUnitType_e; var redundantPicCnt : uint?) : uint {
    var tmp_20 : uint
    var value_15 : uint
    var i_16 : uint
    var ivalue : int
    var tmpStrmData_5 : array<strmData_t> = [0]
    *unsafe(addr(tmpStrmData_5[0])) = *pStrmData_23
    *unsafe(addr(tmpStrmData_5[0]))
    tmp_20 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_5[0])), unsafe(addr(value_15))))
    tmp_20
    if (tmp_20 != uint(0)) {
        return tmp_20
    }
    tmp_20 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_5[0])), unsafe(addr(value_15))))
    tmp_20
    if (tmp_20 != uint(0)) {
        return tmp_20
    }
    tmp_20 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_5[0])), unsafe(addr(value_15))))
    tmp_20
    if (tmp_20 != uint(0)) {
        return tmp_20
    }
    i_16 = uint(uint(0))
    i_16
    while (pSeqParamSet_4.maxFrameNum >> i_16 != 0x0) {
        i_16 = i_16 + 1
        i_16
    }
    i_16 = i_16 - 1
    i_16
    tmp_20 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_5[0])), i_16))
    tmp_20
    if (tmp_20 == 0xffffffff) {
        return uint(1)
    }
    if (uint(nalUnitType_4) == uint(NAL_CODED_SLICE_IDR)) {
        tmp_20 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_5[0])), unsafe(addr(value_15))))
        tmp_20
        if (tmp_20 != uint(0)) {
            return tmp_20
        }
    }
    if (pSeqParamSet_4.picOrderCntType == uint(0)) {
        i_16 = uint(uint(0))
        i_16
        while (pSeqParamSet_4.maxPicOrderCntLsb >> i_16 != 0x0) {
            i_16 = i_16 + 1
            i_16
        }
        i_16 = i_16 - 1
        i_16
        tmp_20 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_5[0])), i_16))
        tmp_20
        if (tmp_20 == 0xffffffff) {
            return uint(1)
        }
        if (pPicParamSet_1.picOrderPresentFlag != 0x0) {
            tmp_20 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_5[0])), unsafe(addr(ivalue))))
            tmp_20
            if (tmp_20 != uint(0)) {
                return tmp_20
            }
        }
    }
    if (pSeqParamSet_4.picOrderCntType == uint(1) && pSeqParamSet_4.deltaPicOrderAlwaysZeroFlag == 0) {
        tmp_20 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_5[0])), unsafe(addr(ivalue))))
        tmp_20
        if (tmp_20 != uint(0)) {
            return tmp_20
        }
        if (pPicParamSet_1.picOrderPresentFlag != 0x0) {
            tmp_20 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_5[0])), unsafe(addr(ivalue))))
            tmp_20
            if (tmp_20 != uint(0)) {
                return tmp_20
            }
        }
    }
    tmp_20 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_5[0])), redundantPicCnt))
    tmp_20
    if (tmp_20 != uint(0)) {
        return tmp_20
    }
    return uint(0)
}
[export]
def h264bsdCheckPriorPicsFlag(var noOutputOfPriorPicsFlag : uint?; var pStrmData_24 : strmData_t const?; var pSeqParamSet_5 : seqParamSet_t const?; var pPicParamSet_2 : picParamSet_t const?; var nalUnitType_5 : nalUnitType_e) : uint {
    var tmp_21 : uint
    var value_16 : uint
    var i_17 : uint
    var ivalue_0 : int
    var tmpStrmData_6 : array<strmData_t> = [0]
    *unsafe(addr(tmpStrmData_6[0])) = *pStrmData_24
    *unsafe(addr(tmpStrmData_6[0]))
    tmp_21 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_6[0])), unsafe(addr(value_16))))
    tmp_21
    if (tmp_21 != uint(0)) {
        return tmp_21
    }
    tmp_21 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_6[0])), unsafe(addr(value_16))))
    tmp_21
    if (tmp_21 != uint(0)) {
        return tmp_21
    }
    tmp_21 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_6[0])), unsafe(addr(value_16))))
    tmp_21
    if (tmp_21 != uint(0)) {
        return tmp_21
    }
    i_17 = uint(uint(0))
    i_17
    while (pSeqParamSet_5.maxFrameNum >> i_17 != 0x0) {
        i_17 = i_17 + 1
        i_17
    }
    i_17 = i_17 - 1
    i_17
    tmp_21 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_6[0])), i_17))
    tmp_21
    if (tmp_21 == 0xffffffff) {
        return uint(1)
    }
    tmp_21 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_6[0])), unsafe(addr(value_16))))
    tmp_21
    if (tmp_21 != uint(0)) {
        return tmp_21
    }
    if (pSeqParamSet_5.picOrderCntType == uint(0)) {
        i_17 = uint(uint(0))
        i_17
        while (pSeqParamSet_5.maxPicOrderCntLsb >> i_17 != 0x0) {
            i_17 = i_17 + 1
            i_17
        }
        i_17 = i_17 - 1
        i_17
        tmp_21 = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_6[0])), i_17))
        tmp_21
        if (tmp_21 == 0xffffffff) {
            return uint(1)
        }
        if (pPicParamSet_2.picOrderPresentFlag != 0x0) {
            tmp_21 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_6[0])), unsafe(addr(ivalue_0))))
            tmp_21
            if (tmp_21 != uint(0)) {
                return tmp_21
            }
        }
    }
    if (pSeqParamSet_5.picOrderCntType == uint(1) && pSeqParamSet_5.deltaPicOrderAlwaysZeroFlag == 0) {
        tmp_21 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_6[0])), unsafe(addr(ivalue_0))))
        tmp_21
        if (tmp_21 != uint(0)) {
            return tmp_21
        }
        if (pPicParamSet_2.picOrderPresentFlag != 0x0) {
            tmp_21 = uint(h264bsdDecodeExpGolombSigned(unsafe(addr(tmpStrmData_6[0])), unsafe(addr(ivalue_0))))
            tmp_21
            if (tmp_21 != uint(0)) {
                return tmp_21
            }
        }
    }
    if (pPicParamSet_2.redundantPicCntPresentFlag != 0x0) {
        tmp_21 = uint(h264bsdDecodeExpGolombUnsigned(unsafe(addr(tmpStrmData_6[0])), unsafe(addr(value_16))))
        tmp_21
        if (tmp_21 != uint(0)) {
            return tmp_21
        }
    }
    *noOutputOfPriorPicsFlag = uint(h264bsdGetBits(unsafe(addr(tmpStrmData_6[0])), uint(1)))
    *noOutputOfPriorPicsFlag
    if (*noOutputOfPriorPicsFlag == 0xffffffff) {
        return uint(1)
    }
    return uint(0)
}
[export]
def h264bsdInitDpb(var dpb : dpbStorage_t?; var picSizeInMbs_3 : uint; var dpbSize : uint; var maxRefFrames : uint; var maxFrameNum_1 : uint; var noReordering : uint) : uint {
    var i_18 : uint
    dpb.maxLongTermFrameIdx = uint(uint(NO_LONG_TERM_FRAME_INDICES))
    dpb.maxLongTermFrameIdx
    var c2da_fresh35_h264bsd : int = 0
    if (maxRefFrames > uint(1)) {
        c2da_fresh35_h264bsd = maxRefFrames
    } else {
        c2da_fresh35_h264bsd = uint(1)
    }
    dpb.maxRefFrames = uint(c2da_fresh35_h264bsd)
    dpb.maxRefFrames
    if (noReordering != 0x0) {
        dpb.dpbSize = uint(dpb.maxRefFrames)
        dpb.dpbSize
    } else {
        dpb.dpbSize = uint(dpbSize)
        dpb.dpbSize
    }
    dpb.maxFrameNum = uint(maxFrameNum_1)
    dpb.maxFrameNum
    dpb.noReordering = uint(noReordering)
    dpb.noReordering
    dpb.fullness = uint(uint(0))
    dpb.fullness
    dpb.numRefFrames = uint(uint(0))
    dpb.numRefFrames
    dpb.prevRefFrameNum = uint(uint(0))
    dpb.prevRefFrameNum
    dpb.buffer = unsafe(unsafe(reinterpret<dpbPicture_t?>(malloc(uint64(16 + 1) * 4))))
    dpb.buffer
    if (dpb.buffer == unsafe(unsafe(reinterpret<dpbPicture_t?>(uint64(0))))) {
        return uint(65535)
    }
    memset(unsafe(unsafe(reinterpret<uint64>(dpb.buffer))), 0, uint64(16 + 1) * 4)
    i_18 = uint(uint(0))
    i_18
    while (i_18 < dpb.dpbSize + uint(1)) {
        unsafe(dpb.buffer[i_18]).pAllocatedData = unsafe(unsafe(reinterpret<uint8?>(malloc(uint64(picSizeInMbs_3 * uint(384) + uint(32) + uint(15)) * 4))))
        unsafe(dpb.buffer[i_18]).pAllocatedData
        if (unsafe(dpb.buffer[i_18]).pAllocatedData == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
            return uint(65535)
        }
        unsafe(dpb.buffer[i_18]).data = unsafe(unsafe(dpb.buffer[i_18]).pAllocatedData + cast<uintptr_t>(16) - unsafe(reinterpret<uintptr_t>(unsafe(dpb.buffer[i_18]).pAllocatedData)) & cast<uintptr_t>(16 - 1) / 4)
        unsafe(dpb.buffer[i_18]).data
        i_18 = i_18 + 1
    }
    dpb.list = unsafe(unsafe(reinterpret<dpbPicture_t??>(malloc(uint64(16 + 1) * 4))))
    dpb.list
    dpb.outBuf = unsafe(unsafe(reinterpret<dpbOutPicture_t?>(malloc(uint64(dpb.dpbSize + uint(1)) * 4))))
    dpb.outBuf
    if (dpb.list == unsafe(unsafe(reinterpret<dpbPicture_t??>(uint64(0)))) || dpb.outBuf == unsafe(unsafe(reinterpret<dpbOutPicture_t?>(uint64(0))))) {
        return uint(65535)
    }
    memset(unsafe(unsafe(reinterpret<uint64>(dpb.list))), 0, uint64(16 + 1) * 4)
    dpb.outIndex = uint(uint(0))
    dpb.numOut = uint(dpb.outIndex)
    dpb.numOut
    return uint(0)
}
[export]
def h264bsdResetDpb(var dpb_0 : dpbStorage_t?; var picSizeInMbs_4 : uint; var dpbSize_0 : uint; var maxRefFrames_0 : uint; var maxFrameNum_2 : uint; var noReordering_0 : uint) : uint {
    h264bsdFreeDpb(dpb_0)
    return h264bsdInitDpb(dpb_0, picSizeInMbs_4, dpbSize_0, maxRefFrames_0, maxFrameNum_2, noReordering_0)
}
[export]
def h264bsdFreeDpb(var dpb_1 : dpbStorage_t?) {
    var i_19 : uint
    if (dpb_1.buffer != null) {
        i_19 = uint(uint(0))
        i_19
        while (i_19 < dpb_1.dpbSize + uint(1)) {
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(dpb_1.buffer[i_19]).pAllocatedData))))
            unsafe(dpb_1.buffer[i_19]).pAllocatedData = null
            unsafe(dpb_1.buffer[i_19]).pAllocatedData
            i_19 = i_19 + 1
        }
    }
    free(unsafe(unsafe(reinterpret<uint64>(dpb_1.buffer))))
    dpb_1.buffer = null
    dpb_1.buffer
    free(unsafe(unsafe(reinterpret<uint64>(dpb_1.list))))
    dpb_1.list = null
    dpb_1.list
    free(unsafe(unsafe(reinterpret<uint64>(dpb_1.outBuf))))
    dpb_1.outBuf = null
    dpb_1.outBuf
}
[export]
def h264bsdInitRefPicList(var dpb_2 : dpbStorage_t?) {
    var i_20 : uint
    i_20 = uint(uint(0))
    i_20
    while (i_20 < dpb_2.numRefFrames) {
        unsafe(dpb_2.list[i_20]) = unsafe(addr(unsafe(dpb_2.buffer[i_20])))
        unsafe(dpb_2.list[i_20])
        i_20 = i_20 + 1
    }
}
[export]
def h264bsdAllocateDpbImage(var dpb_3 : dpbStorage_t?) : uint8? {
    dpb_3.currentOut = unsafe(dpb_3.buffer + dpb_3.dpbSize)
    dpb_3.currentOut
    return dpb_3.currentOut.data
}
[export]
def h264bsdGetRefPicData(var dpb_4 : dpbStorage_t?; var index : uint) : uint8? {
    if (index > uint(16) || unsafe(dpb_4.list[index]) == unsafe(unsafe(reinterpret<dpbPicture_t?>(uint64(0))))) {
        return null
    } else {
        if (uint(*unsafe(dpb_4.list[index]).status) > uint(NON_EXISTING) == 0) {
            return null
        } else {
            return unsafe(dpb_4.list[index]).data
        }
    }
}
[export]
def h264bsdReorderRefPicList(var dpb_5 : dpbStorage_t?; var order : refPicListReordering_t?; var currFrameNum : uint; var numRefIdxActive_0 : uint) : uint {
    var i_21 : uint
    var j : uint
    var k : uint
    var picNumPred : uint
    var refIdx : uint
    var picNum : int
    var picNumNoWrap : int
    var index_0 : int
    var isShortTerm : uint
    SetPicNums(dpb_5, currFrameNum)
    if (order.refPicListReorderingFlagL0 == 0) {
        return uint(0)
    }
    refIdx = uint(uint(0))
    refIdx
    picNumPred = uint(currFrameNum)
    picNumPred
    i_21 = uint(uint(0))
    i_21
    while (unsafe(unsafe(addr(order.command[0]))[i_21]).reorderingOfPicNumsIdc < uint(3)) {
        if (unsafe(unsafe(addr(order.command[0]))[i_21]).reorderingOfPicNumsIdc < uint(2)) {
            if (unsafe(unsafe(addr(order.command[0]))[i_21]).reorderingOfPicNumsIdc == uint(0)) {
                picNumNoWrap = int(picNumPred) - int(unsafe(unsafe(addr(order.command[0]))[i_21]).absDiffPicNum)
                picNumNoWrap
                if (picNumNoWrap < 0) {
                    picNumNoWrap = picNumNoWrap + int(dpb_5.maxFrameNum)
                    picNumNoWrap
                }
            } else {
                picNumNoWrap = int(picNumPred + unsafe(unsafe(addr(order.command[0]))[i_21]).absDiffPicNum)
                picNumNoWrap
                if (picNumNoWrap >= int(dpb_5.maxFrameNum)) {
                    picNumNoWrap = picNumNoWrap - int(dpb_5.maxFrameNum)
                    picNumNoWrap
                }
            }
            picNumPred = uint(uint(picNumNoWrap))
            picNumPred
            picNum = picNumNoWrap
            picNum
            if (uint(picNumNoWrap) > currFrameNum) {
                picNum = picNum - int(dpb_5.maxFrameNum)
                picNum
            }
            isShortTerm = uint(uint(1))
            isShortTerm
        } else {
            picNum = int(unsafe(unsafe(addr(order.command[0]))[i_21]).longTermPicNum)
            picNum
            isShortTerm = uint(uint(0))
            isShortTerm
        }
        index_0 = FindDpbPic(dpb_5, picNum, isShortTerm)
        index_0
        if (index_0 < 0 || uint(unsafe(dpb_5.buffer[index_0]).status) > uint(NON_EXISTING) == 0) {
            return uint(1)
        }
        j = uint(numRefIdxActive_0)
        j
        while (j > refIdx) {
            unsafe(dpb_5.list[j]) = unsafe(dpb_5.list[j - uint(1)])
            unsafe(dpb_5.list[j])
            j = j - 1
        }
        refIdx = refIdx + 1
        unsafe(dpb_5.list[refIdx]) = unsafe(addr(unsafe(dpb_5.buffer[index_0])))
        unsafe(dpb_5.list[refIdx])
        k = uint(refIdx)
        j = uint(k)
        j
        while (j <= numRefIdxActive_0) {
            if (unsafe(dpb_5.list[j]) != unsafe(addr(unsafe(dpb_5.buffer[index_0])))) {
                k = k + 1
                unsafe(dpb_5.list[k]) = unsafe(dpb_5.list[j])
                unsafe(dpb_5.list[k])
            }
            j = j + 1
        }
        i_21 = i_21 + 1
        i_21
    }
    return uint(0)
}
[export]
def FindDpbPic(var dpb_6 : dpbStorage_t?; var picNum_0 : int; var isShortTerm_0 : uint) : int {
    var i_22 : uint = uint(0)
    var found : uint = uint(0)
    if (isShortTerm_0 != 0x0) {
        while (i_22 < dpb_6.maxRefFrames && found == 0) {
            if (uint(unsafe(dpb_6.buffer[i_22]).status) == uint(NON_EXISTING) || uint(unsafe(dpb_6.buffer[i_22]).status) == uint(SHORT_TERM) && unsafe(dpb_6.buffer[i_22]).picNum == picNum_0) {
                found = uint(uint(1))
                found
            } else {
                i_22 = i_22 + 1
                i_22
            }
        }
    } else {
        while (i_22 < dpb_6.maxRefFrames && found == 0) {
            if (uint(unsafe(dpb_6.buffer[i_22]).status) == uint(LONG_TERM) && unsafe(dpb_6.buffer[i_22]).picNum == picNum_0) {
                found = uint(uint(1))
                found
            } else {
                i_22 = i_22 + 1
                i_22
            }
        }
    }
    if (found != 0x0) {
        return int(i_22)
    } else {
        return -1
    }
}
[export]
def SetPicNums(var dpb_7 : dpbStorage_t?; var currFrameNum_0 : uint) {
    var i_23 : uint
    var frameNumWrap : int
    i_23 = uint(uint(0))
    i_23
    while (i_23 < dpb_7.numRefFrames) {
        if (uint(unsafe(dpb_7.buffer[i_23]).status) == uint(NON_EXISTING) || uint(unsafe(dpb_7.buffer[i_23]).status) == uint(SHORT_TERM)) {
            if (unsafe(dpb_7.buffer[i_23]).frameNum > currFrameNum_0) {
                frameNumWrap = int(unsafe(dpb_7.buffer[i_23]).frameNum) - int(dpb_7.maxFrameNum)
                frameNumWrap
            } else {
                frameNumWrap = int(unsafe(dpb_7.buffer[i_23]).frameNum)
                frameNumWrap
            }
            unsafe(dpb_7.buffer[i_23]).picNum = frameNumWrap
            unsafe(dpb_7.buffer[i_23]).picNum
        }
        i_23 = i_23 + 1
    }
}
[export]
def h264bsdMarkDecRefPic(var dpb_8 : dpbStorage_t?; var mark : decRefPicMarking_t?; var image_2 : image_t?; var frameNum_0 : uint; var picOrderCnt : int; var isIdr : uint; var currentPicId : uint; var numErrMbs : uint) : uint {
    var i_24 : uint
    var status_0 : uint
    var markedAsLongTerm : uint
    var toBeDisplayed : uint
    if (image_2.data != dpb_8.currentOut.data) {
        return uint(1)
    }
    dpb_8.lastContainsMmco5 = uint(uint(0))
    dpb_8.lastContainsMmco5
    status_0 = uint(uint(0))
    status_0
    var c2da_fresh36_h264bsd : int = 0
    if (dpb_8.noReordering) {
        c2da_fresh36_h264bsd = 0
    } else {
        c2da_fresh36_h264bsd = 1
    }
    toBeDisplayed = uint(uint(c2da_fresh36_h264bsd))
    toBeDisplayed
    if (mark == unsafe(unsafe(reinterpret<decRefPicMarking_t?>(uint64(0))))) {
        dpb_8.currentOut.status = cast<dpbPictureStatus_e>(UNUSED)
        dpb_8.currentOut.status
        dpb_8.currentOut.frameNum = uint(frameNum_0)
        dpb_8.currentOut.frameNum
        dpb_8.currentOut.picNum = int(frameNum_0)
        dpb_8.currentOut.picNum
        dpb_8.currentOut.picOrderCnt = picOrderCnt
        dpb_8.currentOut.picOrderCnt
        dpb_8.currentOut.toBeDisplayed = uint(toBeDisplayed)
        dpb_8.currentOut.toBeDisplayed
        if (dpb_8.noReordering == 0) {
            dpb_8.fullness = dpb_8.fullness + 1
            dpb_8.fullness
        }
    } else {
        if (isIdr != 0x0) {
            dpb_8.outIndex = uint(uint(0))
            dpb_8.numOut = uint(dpb_8.outIndex)
            dpb_8.numOut
            Mmcop5(dpb_8)
            if (mark.noOutputOfPriorPicsFlag != 0x0 || dpb_8.noReordering != 0x0) {
                dpb_8.numOut = uint(uint(0))
                dpb_8.numOut
                dpb_8.outIndex = uint(uint(0))
                dpb_8.outIndex
            }
            if (mark.longTermReferenceFlag != 0x0) {
                dpb_8.currentOut.status = cast<dpbPictureStatus_e>(LONG_TERM)
                dpb_8.currentOut.status
                dpb_8.maxLongTermFrameIdx = uint(uint(0))
                dpb_8.maxLongTermFrameIdx
            } else {
                dpb_8.currentOut.status = cast<dpbPictureStatus_e>(SHORT_TERM)
                dpb_8.currentOut.status
                dpb_8.maxLongTermFrameIdx = uint(uint(NO_LONG_TERM_FRAME_INDICES))
                dpb_8.maxLongTermFrameIdx
            }
            dpb_8.currentOut.frameNum = uint(uint(0))
            dpb_8.currentOut.frameNum
            dpb_8.currentOut.picNum = 0
            dpb_8.currentOut.picNum
            dpb_8.currentOut.picOrderCnt = 0
            dpb_8.currentOut.picOrderCnt
            dpb_8.currentOut.toBeDisplayed = uint(toBeDisplayed)
            dpb_8.currentOut.toBeDisplayed
            dpb_8.fullness = uint(uint(1))
            dpb_8.fullness
            dpb_8.numRefFrames = uint(uint(1))
            dpb_8.numRefFrames
        } else {
            markedAsLongTerm = uint(uint(0))
            markedAsLongTerm
            if (mark.adaptiveRefPicMarkingModeFlag != 0x0) {
                i_24 = uint(uint(0))
                i_24
                while (unsafe(unsafe(addr(mark.operation[0]))[i_24]).memoryManagementControlOperation != 0x0) {
                    if (unsafe(unsafe(addr(mark.operation[0]))[i_24]).memoryManagementControlOperation == uint(1)) {
                        status_0 = uint(Mmcop1(dpb_8, frameNum_0, unsafe(unsafe(addr(mark.operation[0]))[i_24]).differenceOfPicNums))
                        status_0
                    } elif (unsafe(unsafe(addr(mark.operation[0]))[i_24]).memoryManagementControlOperation == uint(2)) {
                        status_0 = uint(Mmcop2(dpb_8, unsafe(unsafe(addr(mark.operation[0]))[i_24]).longTermPicNum))
                        status_0
                    } elif (unsafe(unsafe(addr(mark.operation[0]))[i_24]).memoryManagementControlOperation == uint(3)) {
                        status_0 = uint(Mmcop3(dpb_8, frameNum_0, unsafe(unsafe(addr(mark.operation[0]))[i_24]).differenceOfPicNums, unsafe(unsafe(addr(mark.operation[0]))[i_24]).longTermFrameIdx))
                        status_0
                    } elif (unsafe(unsafe(addr(mark.operation[0]))[i_24]).memoryManagementControlOperation == uint(4)) {
                        status_0 = uint(Mmcop4(dpb_8, unsafe(unsafe(addr(mark.operation[0]))[i_24]).maxLongTermFrameIdx))
                        status_0
                    } elif (unsafe(unsafe(addr(mark.operation[0]))[i_24]).memoryManagementControlOperation == uint(5)) {
                        status_0 = uint(Mmcop5(dpb_8))
                        status_0
                    } elif (unsafe(unsafe(addr(mark.operation[0]))[i_24]).memoryManagementControlOperation == uint(6)) {
                        status_0 = uint(Mmcop6(dpb_8, frameNum_0, picOrderCnt, unsafe(unsafe(addr(mark.operation[0]))[i_24]).longTermFrameIdx))
                        status_0
                    } else {
                        status_0 = uint(uint(1))
                        status_0
                    }
                    if (status_0 != uint(0)) {
                        break
                    }
                    i_24 = i_24 + 1
                    i_24
                }
            } else {
                status_0 = uint(SlidingWindowRefPicMarking(dpb_8))
                status_0
            }
            if (markedAsLongTerm == 0) {
                if (dpb_8.numRefFrames < dpb_8.maxRefFrames) {
                    dpb_8.currentOut.frameNum = uint(frameNum_0)
                    dpb_8.currentOut.frameNum
                    dpb_8.currentOut.picNum = int(frameNum_0)
                    dpb_8.currentOut.picNum
                    dpb_8.currentOut.picOrderCnt = picOrderCnt
                    dpb_8.currentOut.picOrderCnt
                    dpb_8.currentOut.status = cast<dpbPictureStatus_e>(SHORT_TERM)
                    dpb_8.currentOut.status
                    dpb_8.currentOut.toBeDisplayed = uint(toBeDisplayed)
                    dpb_8.currentOut.toBeDisplayed
                    dpb_8.fullness = dpb_8.fullness + 1
                    dpb_8.fullness
                    dpb_8.numRefFrames = dpb_8.numRefFrames + 1
                    dpb_8.numRefFrames
                } else {
                    status_0 = uint(uint(1))
                    status_0
                }
            }
        }
    }
    dpb_8.currentOut.isIdr = uint(isIdr)
    dpb_8.currentOut.isIdr
    dpb_8.currentOut.picId = uint(currentPicId)
    dpb_8.currentOut.picId
    dpb_8.currentOut.numErrMbs = uint(numErrMbs)
    dpb_8.currentOut.numErrMbs
    if (dpb_8.noReordering != 0x0) {
        unsafe(dpb_8.outBuf[dpb_8.numOut]).data = dpb_8.currentOut.data
        unsafe(dpb_8.outBuf[dpb_8.numOut]).data
        unsafe(dpb_8.outBuf[dpb_8.numOut]).isIdr = uint(dpb_8.currentOut.isIdr)
        unsafe(dpb_8.outBuf[dpb_8.numOut]).isIdr
        unsafe(dpb_8.outBuf[dpb_8.numOut]).picId = uint(dpb_8.currentOut.picId)
        unsafe(dpb_8.outBuf[dpb_8.numOut]).picId
        unsafe(dpb_8.outBuf[dpb_8.numOut]).numErrMbs = uint(dpb_8.currentOut.numErrMbs)
        unsafe(dpb_8.outBuf[dpb_8.numOut]).numErrMbs
        dpb_8.numOut = dpb_8.numOut + 1
        dpb_8.numOut
    } else {
        while (dpb_8.fullness > dpb_8.dpbSize) {
            i_24 = uint(OutputPicture(dpb_8))
            i_24
        }
    }
    ShellSort(dpb_8.buffer, dpb_8.dpbSize + uint(1))
    return status_0
}
[export]
def ShellSort(var pPic : dpbPicture_t?; var num : uint) {
    var i_25 : uint
    var j_0 : uint
    var step : uint
    var tmpPic : dpbPicture_t
    step = uint(uint(7))
    step
    while (step != 0x0) {
        i_25 = uint(step)
        i_25
        while (i_25 < num) {
            tmpPic = unsafe(pPic[i_25])
            tmpPic
            j_0 = uint(i_25)
            j_0
            while (j_0 >= step && ComparePictures(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(pPic + j_0) - step)))), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(tmpPic)))))) > 0) {
                unsafe(pPic[j_0]) = unsafe(pPic[j_0 - step])
                unsafe(pPic[j_0])
                j_0 = uint(j_0 - step)
                j_0
            }
            unsafe(pPic[j_0]) = tmpPic
            unsafe(pPic[j_0])
            i_25 = i_25 + 1
        }
        step = uint(step >> 1)
        step
    }
}
[export]
def ComparePictures(var ptr1 : uint64; var ptr2 : uint64) : int {
    var pic1 : dpbPicture_t?
    var pic2 : dpbPicture_t?
    pic1 = unsafe(reinterpret<dpbPicture_t?>(ptr1))
    pic1
    pic2 = unsafe(reinterpret<dpbPicture_t?>(ptr2))
    pic2
    if (!*pic1.status != 0 && !*pic2.status != 0) {
        if (pic1.toBeDisplayed != 0x0 && pic2.toBeDisplayed == 0) {
            return -1
        } else {
            if (pic1.toBeDisplayed == 0 && pic2.toBeDisplayed != 0x0) {
                return 1
            } else {
                return 0
            }
        }
    } else {
        if (!*pic2.status != 0) {
            return -1
        } else {
            if (!*pic1.status != 0) {
                return 1
            } else {
                if (uint(*pic1.status) == uint(NON_EXISTING) || uint(*pic1.status) == uint(SHORT_TERM) && uint(*pic2.status) == uint(NON_EXISTING) || uint(*pic2.status) == uint(SHORT_TERM)) {
                    if (pic1.picNum > pic2.picNum) {
                        return -1
                    } else {
                        if (pic1.picNum < pic2.picNum) {
                            return 1
                        } else {
                            return 0
                        }
                    }
                } else {
                    if (uint(*pic1.status) == uint(NON_EXISTING) || uint(*pic1.status) == uint(SHORT_TERM)) {
                        return -1
                    } else {
                        if (uint(*pic2.status) == uint(NON_EXISTING) || uint(*pic2.status) == uint(SHORT_TERM)) {
                            return 1
                        } else {
                            if (pic1.picNum > pic2.picNum) {
                                return 1
                            } else {
                                if (pic1.picNum < pic2.picNum) {
                                    return -1
                                } else {
                                    return 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
[export]
def OutputPicture(var dpb_9 : dpbStorage_t?) : uint {
    var tmp_22 : dpbPicture_t?
    if (dpb_9.noReordering != 0x0) {
        return uint(1)
    }
    tmp_22 = FindSmallestPicOrderCnt(dpb_9)
    tmp_22
    if (tmp_22 == unsafe(unsafe(reinterpret<dpbPicture_t?>(uint64(0))))) {
        return uint(1)
    }
    unsafe(dpb_9.outBuf[dpb_9.numOut]).data = tmp_22.data
    unsafe(dpb_9.outBuf[dpb_9.numOut]).data
    unsafe(dpb_9.outBuf[dpb_9.numOut]).isIdr = uint(tmp_22.isIdr)
    unsafe(dpb_9.outBuf[dpb_9.numOut]).isIdr
    unsafe(dpb_9.outBuf[dpb_9.numOut]).picId = uint(tmp_22.picId)
    unsafe(dpb_9.outBuf[dpb_9.numOut]).picId
    unsafe(dpb_9.outBuf[dpb_9.numOut]).numErrMbs = uint(tmp_22.numErrMbs)
    unsafe(dpb_9.outBuf[dpb_9.numOut]).numErrMbs
    dpb_9.numOut = dpb_9.numOut + 1
    dpb_9.numOut
    tmp_22.toBeDisplayed = uint(uint(0))
    tmp_22.toBeDisplayed
    if (!*tmp_22.status != 0) {
        dpb_9.fullness = dpb_9.fullness - 1
        dpb_9.fullness
    }
    return uint(0)
}
[export]
def FindSmallestPicOrderCnt(var dpb_10 : dpbStorage_t?) : dpbPicture_t? {
    var i_26 : uint
    var picOrderCnt_0 : int
    var tmp_23 : dpbPicture_t?
    picOrderCnt_0 = 2147483647
    picOrderCnt_0
    tmp_23 = null
    tmp_23
    i_26 = uint(uint(0))
    i_26
    while (i_26 <= dpb_10.dpbSize) {
        if (unsafe(dpb_10.buffer[i_26]).toBeDisplayed != 0x0 && unsafe(dpb_10.buffer[i_26]).picOrderCnt < picOrderCnt_0) {
            tmp_23 = unsafe(dpb_10.buffer + i_26)
            tmp_23
            picOrderCnt_0 = unsafe(dpb_10.buffer[i_26]).picOrderCnt
            picOrderCnt_0
        }
        i_26 = i_26 + 1
    }
    return tmp_23
}
[export]
def SlidingWindowRefPicMarking(var dpb_11 : dpbStorage_t?) : uint {
    var index_1 : int
    var picNum_1 : int
    var i_27 : uint
    if (dpb_11.numRefFrames < dpb_11.maxRefFrames) {
        return uint(0)
    } else {
        index_1 = -1
        index_1
        picNum_1 = 0
        picNum_1
        i_27 = uint(uint(0))
        i_27
        while (i_27 < dpb_11.numRefFrames) {
            if (uint(unsafe(dpb_11.buffer[i_27]).status) == uint(NON_EXISTING) || uint(unsafe(dpb_11.buffer[i_27]).status) == uint(SHORT_TERM)) {
                if (unsafe(dpb_11.buffer[i_27]).picNum < picNum_1 || index_1 == -1) {
                    index_1 = int(i_27)
                    index_1
                    picNum_1 = unsafe(dpb_11.buffer[i_27]).picNum
                    picNum_1
                }
            }
            i_27 = i_27 + 1
        }
        if (index_1 >= 0) {
            unsafe(dpb_11.buffer[index_1]).status = cast<dpbPictureStatus_e>(UNUSED)
            unsafe(dpb_11.buffer[index_1]).status
            dpb_11.numRefFrames = dpb_11.numRefFrames - 1
            dpb_11.numRefFrames
            if (unsafe(dpb_11.buffer[index_1]).toBeDisplayed == 0) {
                dpb_11.fullness = dpb_11.fullness - 1
                dpb_11.fullness
            }
            return uint(0)
        }
    }
    return uint(1)
}
[export]
def Mmcop6(var dpb_12 : dpbStorage_t?; var frameNum_1 : uint; var picOrderCnt_1 : int; var longTermFrameIdx : uint) : uint {
    var i_28 : uint
    if (dpb_12.maxLongTermFrameIdx == uint(NO_LONG_TERM_FRAME_INDICES) || longTermFrameIdx > dpb_12.maxLongTermFrameIdx) {
        return uint(1)
    }
    i_28 = uint(uint(0))
    i_28
    while (i_28 < dpb_12.maxRefFrames) {
        if (uint(unsafe(dpb_12.buffer[i_28]).status) == uint(LONG_TERM) && uint(unsafe(dpb_12.buffer[i_28]).picNum) == longTermFrameIdx) {
            unsafe(dpb_12.buffer[i_28]).status = cast<dpbPictureStatus_e>(UNUSED)
            unsafe(dpb_12.buffer[i_28]).status
            dpb_12.numRefFrames = dpb_12.numRefFrames - 1
            dpb_12.numRefFrames
            if (unsafe(dpb_12.buffer[i_28]).toBeDisplayed == 0) {
                dpb_12.fullness = dpb_12.fullness - 1
                dpb_12.fullness
            }
            break
        }
        i_28 = i_28 + 1
    }
    if (dpb_12.numRefFrames < dpb_12.maxRefFrames) {
        dpb_12.currentOut.frameNum = uint(frameNum_1)
        dpb_12.currentOut.frameNum
        dpb_12.currentOut.picNum = int(longTermFrameIdx)
        dpb_12.currentOut.picNum
        dpb_12.currentOut.picOrderCnt = picOrderCnt_1
        dpb_12.currentOut.picOrderCnt
        dpb_12.currentOut.status = cast<dpbPictureStatus_e>(LONG_TERM)
        dpb_12.currentOut.status
        if (dpb_12.noReordering != 0x0) {
            dpb_12.currentOut.toBeDisplayed = uint(uint(0))
            dpb_12.currentOut.toBeDisplayed
        } else {
            dpb_12.currentOut.toBeDisplayed = uint(uint(1))
            dpb_12.currentOut.toBeDisplayed
        }
        dpb_12.numRefFrames = dpb_12.numRefFrames + 1
        dpb_12.numRefFrames
        dpb_12.fullness = dpb_12.fullness + 1
        dpb_12.fullness
        return uint(0)
    } else {
        return uint(1)
    }
}
[export]
def Mmcop5(var dpb_13 : dpbStorage_t?) : uint {
    var i_29 : uint
    i_29 = uint(uint(0))
    i_29
    while (i_29 < uint(16)) {
        if (unsafe(dpb_13.buffer[i_29]).status) {
            unsafe(dpb_13.buffer[i_29]).status = cast<dpbPictureStatus_e>(UNUSED)
            unsafe(dpb_13.buffer[i_29]).status
            if (unsafe(dpb_13.buffer[i_29]).toBeDisplayed == 0) {
                dpb_13.fullness = dpb_13.fullness - 1
                dpb_13.fullness
            }
        }
        i_29 = i_29 + 1
    }
    while (OutputPicture(dpb_13) == uint(0)) {
    }
    dpb_13.numRefFrames = uint(uint(0))
    dpb_13.numRefFrames
    dpb_13.maxLongTermFrameIdx = uint(uint(NO_LONG_TERM_FRAME_INDICES))
    dpb_13.maxLongTermFrameIdx
    dpb_13.prevRefFrameNum = uint(uint(0))
    dpb_13.prevRefFrameNum
    return uint(0)
}
[export]
def Mmcop4(var dpb_14 : dpbStorage_t?; var maxLongTermFrameIdx : uint) : uint {
    var i_30 : uint
    dpb_14.maxLongTermFrameIdx = uint(maxLongTermFrameIdx)
    dpb_14.maxLongTermFrameIdx
    i_30 = uint(uint(0))
    i_30
    while (i_30 < dpb_14.maxRefFrames) {
        if (uint(unsafe(dpb_14.buffer[i_30]).status) == uint(LONG_TERM) && uint(unsafe(dpb_14.buffer[i_30]).picNum) > maxLongTermFrameIdx || dpb_14.maxLongTermFrameIdx == uint(NO_LONG_TERM_FRAME_INDICES)) {
            unsafe(dpb_14.buffer[i_30]).status = cast<dpbPictureStatus_e>(UNUSED)
            unsafe(dpb_14.buffer[i_30]).status
            dpb_14.numRefFrames = dpb_14.numRefFrames - 1
            dpb_14.numRefFrames
            if (unsafe(dpb_14.buffer[i_30]).toBeDisplayed == 0) {
                dpb_14.fullness = dpb_14.fullness - 1
                dpb_14.fullness
            }
        }
        i_30 = i_30 + 1
    }
    return uint(0)
}
[export]
def Mmcop3(var dpb_15 : dpbStorage_t?; var currPicNum : uint; var differenceOfPicNums : uint; var longTermFrameIdx_0 : uint) : uint {
    var index_2 : int
    var picNum_2 : int
    var i_31 : uint
    if (dpb_15.maxLongTermFrameIdx == uint(NO_LONG_TERM_FRAME_INDICES) || longTermFrameIdx_0 > dpb_15.maxLongTermFrameIdx) {
        return uint(1)
    }
    i_31 = uint(uint(0))
    i_31
    while (i_31 < dpb_15.maxRefFrames) {
        if (uint(unsafe(dpb_15.buffer[i_31]).status) == uint(LONG_TERM) && uint(unsafe(dpb_15.buffer[i_31]).picNum) == longTermFrameIdx_0) {
            unsafe(dpb_15.buffer[i_31]).status = cast<dpbPictureStatus_e>(UNUSED)
            unsafe(dpb_15.buffer[i_31]).status
            dpb_15.numRefFrames = dpb_15.numRefFrames - 1
            dpb_15.numRefFrames
            if (unsafe(dpb_15.buffer[i_31]).toBeDisplayed == 0) {
                dpb_15.fullness = dpb_15.fullness - 1
                dpb_15.fullness
            }
            break
        }
        i_31 = i_31 + 1
    }
    picNum_2 = int(currPicNum) - int(differenceOfPicNums)
    picNum_2
    index_2 = FindDpbPic(dpb_15, picNum_2, uint(1))
    index_2
    if (index_2 < 0) {
        return uint(1)
    }
    if (uint(unsafe(dpb_15.buffer[index_2]).status) > uint(NON_EXISTING) == 0) {
        return uint(1)
    }
    unsafe(dpb_15.buffer[index_2]).status = cast<dpbPictureStatus_e>(LONG_TERM)
    unsafe(dpb_15.buffer[index_2]).status
    unsafe(dpb_15.buffer[index_2]).picNum = int(longTermFrameIdx_0)
    unsafe(dpb_15.buffer[index_2]).picNum
    return uint(0)
}
[export]
def Mmcop2(var dpb_16 : dpbStorage_t?; var longTermPicNum : uint) : uint {
    var index_3 : int
    index_3 = FindDpbPic(dpb_16, int(longTermPicNum), uint(0))
    index_3
    if (index_3 < 0) {
        return uint(1)
    }
    unsafe(dpb_16.buffer[index_3]).status = cast<dpbPictureStatus_e>(UNUSED)
    unsafe(dpb_16.buffer[index_3]).status
    dpb_16.numRefFrames = dpb_16.numRefFrames - 1
    dpb_16.numRefFrames
    if (unsafe(dpb_16.buffer[index_3]).toBeDisplayed == 0) {
        dpb_16.fullness = dpb_16.fullness - 1
        dpb_16.fullness
    }
    return uint(0)
}
[export]
def Mmcop1(var dpb_17 : dpbStorage_t?; var currPicNum_0 : uint; var differenceOfPicNums_0 : uint) : uint {
    var index_4 : int
    var picNum_3 : int
    picNum_3 = int(currPicNum_0) - int(differenceOfPicNums_0)
    picNum_3
    index_4 = FindDpbPic(dpb_17, picNum_3, uint(1))
    index_4
    if (index_4 < 0) {
        return uint(1)
    }
    unsafe(dpb_17.buffer[index_4]).status = cast<dpbPictureStatus_e>(UNUSED)
    unsafe(dpb_17.buffer[index_4]).status
    dpb_17.numRefFrames = dpb_17.numRefFrames - 1
    dpb_17.numRefFrames
    if (unsafe(dpb_17.buffer[index_4]).toBeDisplayed == 0) {
        dpb_17.fullness = dpb_17.fullness - 1
        dpb_17.fullness
    }
    return uint(0)
}
[export]
def h264bsdCheckGapsInFrameNum(var dpb_18 : dpbStorage_t?; var frameNum_2 : uint; var isRefPic : uint; var gapsAllowed : uint) : uint {
    var unUsedShortTermFrameNum : uint
    var tmp_24 : uint8?
    dpb_18.numOut = uint(uint(0))
    dpb_18.numOut
    dpb_18.outIndex = uint(uint(0))
    dpb_18.outIndex
    if (gapsAllowed == 0) {
        return uint(0)
    }
    if (frameNum_2 != dpb_18.prevRefFrameNum && frameNum_2 != dpb_18.prevRefFrameNum + uint(1) % dpb_18.maxFrameNum) {
        unUsedShortTermFrameNum = uint(dpb_18.prevRefFrameNum + uint(1) % dpb_18.maxFrameNum)
        unUsedShortTermFrameNum
        tmp_24 = unsafe(dpb_18.buffer[dpb_18.dpbSize]).data
        tmp_24
        var _dw_24442 : bool = true
        while (_dw_24442 || unUsedShortTermFrameNum != frameNum_2) {
            _dw_24442 = false
            SetPicNums(dpb_18, unUsedShortTermFrameNum)
            if (SlidingWindowRefPicMarking(dpb_18) != uint(0)) {
                return uint(1)
            }
            while (dpb_18.fullness >= dpb_18.dpbSize) {
                OutputPicture(dpb_18)
            }
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).status = cast<dpbPictureStatus_e>(NON_EXISTING)
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).status
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).frameNum = uint(unUsedShortTermFrameNum)
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).frameNum
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).picNum = int(unUsedShortTermFrameNum)
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).picNum
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).picOrderCnt = 0
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).picOrderCnt
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).toBeDisplayed = uint(uint(0))
            unsafe(dpb_18.buffer[dpb_18.dpbSize]).toBeDisplayed
            dpb_18.fullness = dpb_18.fullness + 1
            dpb_18.fullness
            dpb_18.numRefFrames = dpb_18.numRefFrames + 1
            dpb_18.numRefFrames
            ShellSort(dpb_18.buffer, dpb_18.dpbSize + uint(1))
            unUsedShortTermFrameNum = uint(unUsedShortTermFrameNum + uint(1) % dpb_18.maxFrameNum)
            unUsedShortTermFrameNum
        }
        if (dpb_18.numOut != 0x0) {
            var i_32 : uint
            i_32 = uint(uint(0))
            i_32
            while (i_32 < dpb_18.numOut) {
                if (unsafe(dpb_18.outBuf[i_32]).data == unsafe(dpb_18.buffer[dpb_18.dpbSize]).data) {
                    i_32 = uint(uint(0))
                    i_32
                    while (i_32 < dpb_18.dpbSize) {
                        if (unsafe(dpb_18.buffer[i_32]).data == tmp_24) {
                            unsafe(dpb_18.buffer[i_32]).data = unsafe(dpb_18.buffer[dpb_18.dpbSize]).data
                            unsafe(dpb_18.buffer[i_32]).data
                            unsafe(dpb_18.buffer[dpb_18.dpbSize]).data = tmp_24
                            unsafe(dpb_18.buffer[dpb_18.dpbSize]).data
                            break
                        }
                        i_32 = i_32 + 1
                    }
                    break
                }
                i_32 = i_32 + 1
            }
        }
    } else {
        if (isRefPic != 0x0 && frameNum_2 == dpb_18.prevRefFrameNum) {
            return uint(1)
        }
    }
    if (isRefPic != 0x0) {
        dpb_18.prevRefFrameNum = uint(frameNum_2)
        dpb_18.prevRefFrameNum
    } else {
        if (frameNum_2 != dpb_18.prevRefFrameNum) {
            dpb_18.prevRefFrameNum = uint(frameNum_2 + dpb_18.maxFrameNum - uint(1) % dpb_18.maxFrameNum)
            dpb_18.prevRefFrameNum
        }
    }
    return uint(0)
}
[export]
def h264bsdDpbOutputPicture(var dpb_19 : dpbStorage_t?) : dpbOutPicture_t? {
    if (dpb_19.outIndex < dpb_19.numOut) {
        dpb_19.outIndex = dpb_19.outIndex + 1
        return unsafe(dpb_19.outBuf + dpb_19.outIndex)
    } else {
        return null
    }
}
[export]
def h264bsdFlushDpb(var dpb_20 : dpbStorage_t?) {
    if (dpb_20.buffer != null) {
        dpb_20.flushed = uint(uint(1))
        dpb_20.flushed
        while (OutputPicture(dpb_20) == uint(0)) {
        }
    }
}
[export]
def h264bsdDecodeMacroblockLayer(var pStrmData_25 : strmData_t?; var pMbLayer : macroblockLayer_t?; var pMb : mbStorage_t?; var sliceType : uint; var numRefIdxActive_1 : uint) : uint {
    var tmp_25 : uint
    var i_33 : uint
    var value_17 : uint
    var itmp_1 : int
    var partMode : mbPartPredMode_e
    memset(unsafe(unsafe(reinterpret<uint64>(pMbLayer))), 0, 4)
    tmp_25 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_25, unsafe(addr(value_17))))
    tmp_25
    if (sliceType == uint(I_SLICE) || sliceType == uint(I_SLICE + 5)) {
        if (value_17 + uint(6) > uint(31) || tmp_25 != uint(0)) {
            return uint(1)
        }
        pMbLayer.mbType = cast<mbType_e>(value_17 + uint(6))
        pMbLayer.mbType
    } else {
        if (value_17 + uint(1) > uint(31) || tmp_25 != uint(0)) {
            return uint(1)
        }
        pMbLayer.mbType = cast<mbType_e>(value_17 + uint(1))
        pMbLayer.mbType
    }
    if (uint(pMbLayer.mbType) == uint(I_PCM)) {
        var level_0 : int?
        while (h264bsdIsByteAligned(pStrmData_25) == 0) {
            tmp_25 = uint(h264bsdGetBits(pStrmData_25, uint(1)))
            tmp_25
            if (tmp_25 != 0x0) {
                return uint(1)
            }
        }
        level_0 = unsafe(addr(unsafe(unsafe(addr(pMbLayer.residual.level[0]))[0])[0]))
        level_0
        i_33 = uint(uint(0))
        i_33
        while (i_33 < uint(384)) {
            value_17 = uint(h264bsdGetBits(pStrmData_25, uint(8)))
            value_17
            if (value_17 == 0xffffffff) {
                return uint(1)
            }
            level_0 = level_0 + 1
            *level_0 = int(value_17)
            *level_0
            i_33 = i_33 + 1
        }
    } else {
        partMode = h264bsdMbPartPredMode(pMbLayer.mbType)
        partMode
        if (uint(partMode) == uint(PRED_MODE_INTER) && h264bsdNumMbPart(pMbLayer.mbType) == uint(4)) {
            tmp_25 = uint(DecodeSubMbPred(pStrmData_25, unsafe(addr(pMbLayer.subMbPred)), pMbLayer.mbType, numRefIdxActive_1))
            tmp_25
        } else {
            tmp_25 = uint(DecodeMbPred(pStrmData_25, unsafe(addr(pMbLayer.mbPred)), pMbLayer.mbType, numRefIdxActive_1))
            tmp_25
        }
        if (tmp_25 != uint(0)) {
            return tmp_25
        }
        if (uint(partMode) != uint(PRED_MODE_INTRA16x16)) {
            tmp_25 = uint(h264bsdDecodeExpGolombMapped(pStrmData_25, unsafe(addr(value_17)), uint(uint(partMode) == uint(PRED_MODE_INTRA4x4))))
            tmp_25
            if (tmp_25 != uint(0)) {
                return tmp_25
            }
            pMbLayer.codedBlockPattern = uint(value_17)
            pMbLayer.codedBlockPattern
        } else {
            pMbLayer.codedBlockPattern = uint(CbpIntra16x16(pMbLayer.mbType))
            pMbLayer.codedBlockPattern
        }
        if (pMbLayer.codedBlockPattern != 0x0 || uint(partMode) == uint(PRED_MODE_INTRA16x16)) {
            tmp_25 = uint(h264bsdDecodeExpGolombSigned(pStrmData_25, unsafe(addr(itmp_1))))
            tmp_25
            if (tmp_25 != uint(0) || itmp_1 < -26 || itmp_1 > 25) {
                return uint(1)
            }
            pMbLayer.mbQpDelta = itmp_1
            pMbLayer.mbQpDelta
            tmp_25 = uint(DecodeResidual(pStrmData_25, unsafe(addr(pMbLayer.residual)), pMb, pMbLayer.mbType, pMbLayer.codedBlockPattern))
            tmp_25
            pStrmData_25.strmBuffReadBits = uint(uint(pStrmData_25.pStrmCurrPos - pStrmData_25.pStrmBuffStart) * uint(8) + pStrmData_25.bitPosInWord)
            pStrmData_25.strmBuffReadBits
            if (tmp_25 != uint(0)) {
                return tmp_25
            }
        }
    }
    return uint(0)
}
[export]
def DecodeResidual(var pStrmData_26 : strmData_t?; var pResidual : residual_t?; var pMb_0 : mbStorage_t?; var mbType : mbType_e; var codedBlockPattern : uint) : uint {
    var i_34 : uint
    var j_1 : uint
    var tmp_26 : uint
    var nc_1 : int
    var blockCoded : uint
    var blockIndex : uint
    var is16x16 : uint
    var level_1 : array<int>?
    level_1 = unsafe(addr(pResidual.level[0]))
    level_1
    if (uint(h264bsdMbPartPredMode(mbType)) == uint(PRED_MODE_INTRA16x16)) {
        nc_1 = int(DetermineNc(pMb_0, uint(0), unsafe(addr(pResidual.totalCoeff[0]))))
        nc_1
        tmp_26 = uint(h264bsdDecodeResidualBlockCavlc(pStrmData_26, unsafe(addr(unsafe(level_1[24])[0])), nc_1, uint(16)))
        tmp_26
        if (tmp_26 & uint(15) != uint(0)) {
            return tmp_26
        }
        unsafe(unsafe(addr(pResidual.totalCoeff[0]))[24]) = int(uint(tmp_26) >> uint(uint(4)) & uint(255))
        unsafe(unsafe(addr(pResidual.totalCoeff[0]))[24])
        is16x16 = uint(uint(1))
        is16x16
    } else {
        is16x16 = uint(uint(0))
        is16x16
    }
    blockIndex = uint(uint(0))
    blockIndex
    while (i_34 != 0x0) {
        blockCoded = uint(codedBlockPattern & uint(1))
        blockCoded
        codedBlockPattern = uint(codedBlockPattern >> 1)
        codedBlockPattern
        if (blockCoded != 0x0) {
            j_1 = uint(uint(4))
            j_1
            while (j_1 != 0x0) {
                nc_1 = int(DetermineNc(pMb_0, blockIndex, unsafe(addr(pResidual.totalCoeff[0]))))
                nc_1
                if (is16x16 != 0x0) {
                    tmp_26 = uint(h264bsdDecodeResidualBlockCavlc(pStrmData_26, unsafe(unsafe(addr(unsafe(level_1[blockIndex])[0])) + 1), nc_1, uint(15)))
                    tmp_26
                    unsafe(unsafe(addr(pResidual.coeffMap[0]))[blockIndex]) = uint(uint(tmp_26) >> uint(uint(15)))
                    unsafe(unsafe(addr(pResidual.coeffMap[0]))[blockIndex])
                } else {
                    tmp_26 = uint(h264bsdDecodeResidualBlockCavlc(pStrmData_26, unsafe(addr(unsafe(level_1[blockIndex])[0])), nc_1, uint(16)))
                    tmp_26
                    unsafe(unsafe(addr(pResidual.coeffMap[0]))[blockIndex]) = uint(uint(tmp_26) >> uint(uint(16)))
                    unsafe(unsafe(addr(pResidual.coeffMap[0]))[blockIndex])
                }
                if (tmp_26 & uint(15) != uint(0)) {
                    return tmp_26
                }
                unsafe(unsafe(addr(pResidual.totalCoeff[0]))[blockIndex]) = int(uint(tmp_26) >> uint(uint(4)) & uint(255))
                unsafe(unsafe(addr(pResidual.totalCoeff[0]))[blockIndex])
                blockIndex = blockIndex + 1
            }
        } else {
            blockIndex = uint(blockIndex + uint(4))
            blockIndex
        }
    }
    blockCoded = uint(codedBlockPattern & uint(3))
    blockCoded
    if (blockCoded != 0x0) {
        tmp_26 = uint(h264bsdDecodeResidualBlockCavlc(pStrmData_26, unsafe(addr(unsafe(level_1[25])[0])), -1, uint(4)))
        tmp_26
        if (tmp_26 & uint(15) != uint(0)) {
            return tmp_26
        }
        unsafe(unsafe(addr(pResidual.totalCoeff[0]))[25]) = int(uint(tmp_26) >> uint(uint(4)) & uint(255))
        unsafe(unsafe(addr(pResidual.totalCoeff[0]))[25])
        tmp_26 = uint(h264bsdDecodeResidualBlockCavlc(pStrmData_26, unsafe(unsafe(addr(unsafe(level_1[25])[0])) + 4), -1, uint(4)))
        tmp_26
        if (tmp_26 & uint(15) != uint(0)) {
            return tmp_26
        }
        unsafe(unsafe(addr(pResidual.totalCoeff[0]))[26]) = int(uint(tmp_26) >> uint(uint(4)) & uint(255))
        unsafe(unsafe(addr(pResidual.totalCoeff[0]))[26])
    }
    blockCoded = uint(codedBlockPattern & uint(2))
    blockCoded
    if (blockCoded != 0x0) {
        i_34 = uint(uint(8))
        i_34
        while (i_34 != 0x0) {
            nc_1 = int(DetermineNc(pMb_0, blockIndex, unsafe(addr(pResidual.totalCoeff[0]))))
            nc_1
            tmp_26 = uint(h264bsdDecodeResidualBlockCavlc(pStrmData_26, unsafe(unsafe(addr(unsafe(level_1[blockIndex])[0])) + 1), nc_1, uint(15)))
            tmp_26
            if (tmp_26 & uint(15) != uint(0)) {
                return tmp_26
            }
            unsafe(unsafe(addr(pResidual.totalCoeff[0]))[blockIndex]) = int(uint(tmp_26) >> uint(uint(4)) & uint(255))
            unsafe(unsafe(addr(pResidual.totalCoeff[0]))[blockIndex])
            unsafe(unsafe(addr(pResidual.coeffMap[0]))[blockIndex]) = uint(uint(tmp_26) >> uint(uint(15)))
            unsafe(unsafe(addr(pResidual.coeffMap[0]))[blockIndex])
            blockIndex = blockIndex + 1
        }
    }
    return uint(0)
}
[export]
def DetermineNc(var pMb_1 : mbStorage_t?; var blockIndex_0 : uint; var pTotalCoeff : int?) : uint {
    var tmp_27 : uint
    var n : int
    var neighbourA : neighbour_t const?
    var neighbourB : neighbour_t const?
    var neighbourAindex : uint8
    var neighbourBindex : uint8
    neighbourA = h264bsdNeighbour4x4BlockA(blockIndex_0)
    neighbourA
    neighbourB = h264bsdNeighbour4x4BlockB(blockIndex_0)
    neighbourB
    neighbourAindex = uint8(neighbourA.index)
    neighbourAindex
    neighbourBindex = uint8(neighbourB.index)
    neighbourBindex
    if (uint(neighbourA.mb) == uint(MB_CURR) && uint(neighbourB.mb) == uint(MB_CURR)) {
        n = unsafe(pTotalCoeff[neighbourAindex]) + unsafe(pTotalCoeff[neighbourBindex]) + 1 >> 1
        n
    } else {
        if (uint(neighbourA.mb) == uint(MB_CURR)) {
            n = unsafe(pTotalCoeff[neighbourAindex])
            n
            if (h264bsdIsNeighbourAvailable(pMb_1, pMb_1.mbB) != 0x0) {
                n = n + unsafe(unsafe(addr(pMb_1.mbB.totalCoeff[0]))[neighbourBindex]) + 1 >> 1
                n
            }
        } else {
            if (uint(neighbourB.mb) == uint(MB_CURR)) {
                n = unsafe(pTotalCoeff[neighbourBindex])
                n
                if (h264bsdIsNeighbourAvailable(pMb_1, pMb_1.mbA) != 0x0) {
                    n = n + unsafe(unsafe(addr(pMb_1.mbA.totalCoeff[0]))[neighbourAindex]) + 1 >> 1
                    n
                }
            } else {
                tmp_27 = uint(uint(0))
                n = int(tmp_27)
                n
                if (h264bsdIsNeighbourAvailable(pMb_1, pMb_1.mbA) != 0x0) {
                    n = unsafe(unsafe(addr(pMb_1.mbA.totalCoeff[0]))[neighbourAindex])
                    n
                    tmp_27 = uint(uint(1))
                    tmp_27
                }
                if (h264bsdIsNeighbourAvailable(pMb_1, pMb_1.mbB) != 0x0) {
                    if (tmp_27 != 0x0) {
                        n = n + unsafe(unsafe(addr(pMb_1.mbB.totalCoeff[0]))[neighbourBindex]) + 1 >> 1
                        n
                    } else {
                        n = unsafe(unsafe(addr(pMb_1.mbB.totalCoeff[0]))[neighbourBindex])
                        n
                    }
                }
            }
        }
    }
    return uint(n)
}
[export]
def h264bsdIsNeighbourAvailable(var pMb_2 : mbStorage_t?; var pNeighbour : mbStorage_t?) : uint {
    if (pNeighbour == unsafe(unsafe(reinterpret<mbStorage_t?>(uint64(0)))) || pMb_2.sliceId != pNeighbour.sliceId) {
        return uint(0)
    } else {
        return uint(1)
    }
}
[export]
def h264bsdNeighbour4x4BlockB(var blockIndex_1 : uint) : neighbour_t const? {
    return unsafe(unsafe(addr(N_B_4x4B[0])) + blockIndex_1)
}
var N_B_4x4B : array<neighbour_t> const = [[cast<neighbourMb_e>(MB_B), uint8(10)], [cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_CURR), uint8(0)], [cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_B), uint8(15)], [cast<neighbourMb_e>(MB_CURR), uint8(4)], [cast<neighbourMb_e>(MB_CURR), uint8(5)], [cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(8)], [cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_CURR), uint8(7)], [cast<neighbourMb_e>(MB_CURR), uint8(12)], [cast<neighbourMb_e>(MB_CURR), uint8(13)], [cast<neighbourMb_e>(MB_B), uint8(18)], [cast<neighbourMb_e>(MB_B), uint8(19)], [cast<neighbourMb_e>(MB_CURR), uint8(16)], [cast<neighbourMb_e>(MB_CURR), uint8(17)], [cast<neighbourMb_e>(MB_B), uint8(22)], [cast<neighbourMb_e>(MB_B), uint8(23)], [cast<neighbourMb_e>(MB_CURR), uint8(20)], [cast<neighbourMb_e>(MB_CURR), uint8(21)]]

[export]
def h264bsdNeighbour4x4BlockA(var blockIndex_2 : uint) : neighbour_t const? {
    return unsafe(unsafe(addr(N_A_4x4B[0])) + blockIndex_2)
}
var N_A_4x4B : array<neighbour_t> const = [[cast<neighbourMb_e>(MB_A), uint8(5)], [cast<neighbourMb_e>(MB_CURR), uint8(0)], [cast<neighbourMb_e>(MB_A), uint8(7)], [cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_CURR), uint8(4)], [cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_A), uint8(13)], [cast<neighbourMb_e>(MB_CURR), uint8(8)], [cast<neighbourMb_e>(MB_A), uint8(15)], [cast<neighbourMb_e>(MB_CURR), uint8(10)], [cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_CURR), uint8(12)], [cast<neighbourMb_e>(MB_CURR), uint8(11)], [cast<neighbourMb_e>(MB_CURR), uint8(14)], [cast<neighbourMb_e>(MB_A), uint8(17)], [cast<neighbourMb_e>(MB_CURR), uint8(16)], [cast<neighbourMb_e>(MB_A), uint8(19)], [cast<neighbourMb_e>(MB_CURR), uint8(18)], [cast<neighbourMb_e>(MB_A), uint8(21)], [cast<neighbourMb_e>(MB_CURR), uint8(20)], [cast<neighbourMb_e>(MB_A), uint8(23)], [cast<neighbourMb_e>(MB_CURR), uint8(22)]]

[export]
def h264bsdMbPartPredMode(var mbType_0 : mbType_e) : mbPartPredMode_e {
    if (uint(mbType_0) <= uint(P_8x8ref0)) {
        return cast<mbPartPredMode_e>(PRED_MODE_INTER)
    } else {
        if (uint(mbType_0) == uint(I_4x4)) {
            return cast<mbPartPredMode_e>(PRED_MODE_INTRA4x4)
        } else {
            return cast<mbPartPredMode_e>(PRED_MODE_INTRA16x16)
        }
    }
}
[export]
def CbpIntra16x16(var mbType_1 : mbType_e) : uint {
    var cbp : uint
    var tmp_28 : uint
    if (uint(mbType_1) >= uint(I_16x16_0_0_1)) {
        cbp = uint(uint(15))
        cbp
    } else {
        cbp = uint(uint(0))
        cbp
    }
    tmp_28 = uint(uint(uint(mbType_1) - uint(I_16x16_0_0_0)) >> uint(uint(2)))
    tmp_28
    if (tmp_28 > uint(2)) {
        tmp_28 = uint(tmp_28 - uint(3))
        tmp_28
    }
    cbp = uint(cbp + uint(tmp_28) << uint(uint(4)))
    cbp
    return cbp
}
[export]
def h264bsdDecodeExpGolombMapped(var pStrmData_27 : strmData_t?; var value_18 : uint?; var isIntra : uint) : uint {
    var status_1 : uint
    var codeNum_1 : uint
    status_1 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_27, unsafe(addr(codeNum_1))))
    status_1
    if (status_1 != uint(0)) {
        return uint(1)
    } else {
        if (codeNum_1 > uint(47)) {
            return uint(1)
        }
        if (isIntra != 0x0) {
            *value_18 = uint(uint(unsafe(unsafe(addr(codedBlockPatternIntra4x4[0]))[codeNum_1])))
            *value_18
        } else {
            *value_18 = uint(uint(unsafe(unsafe(addr(codedBlockPatternInter[0]))[codeNum_1])))
            *value_18
        }
        return uint(0)
    }
}
var codedBlockPatternInter : array<uint8> const = [uint8(0), uint8(16), uint8(1), uint8(2), uint8(4), uint8(8), uint8(32), uint8(3), uint8(5), uint8(10), uint8(12), uint8(15), uint8(47), uint8(7), uint8(11), uint8(13), uint8(14), uint8(6), uint8(9), uint8(31), uint8(35), uint8(37), uint8(42), uint8(44), uint8(33), uint8(34), uint8(36), uint8(40), uint8(39), uint8(43), uint8(45), uint8(46), uint8(17), uint8(18), uint8(20), uint8(24), uint8(19), uint8(21), uint8(26), uint8(28), uint8(23), uint8(27), uint8(29), uint8(30), uint8(22), uint8(25), uint8(38), uint8(41)]

var codedBlockPatternIntra4x4 : array<uint8> const = [uint8(47), uint8(31), uint8(15), uint8(0), uint8(23), uint8(27), uint8(29), uint8(30), uint8(7), uint8(11), uint8(13), uint8(14), uint8(39), uint8(43), uint8(45), uint8(46), uint8(16), uint8(3), uint8(5), uint8(10), uint8(12), uint8(19), uint8(21), uint8(26), uint8(28), uint8(35), uint8(37), uint8(42), uint8(44), uint8(1), uint8(2), uint8(4), uint8(8), uint8(17), uint8(18), uint8(20), uint8(24), uint8(6), uint8(9), uint8(22), uint8(25), uint8(32), uint8(33), uint8(34), uint8(36), uint8(40), uint8(38), uint8(41)]

[export]
def DecodeMbPred(var pStrmData_28 : strmData_t?; var pMbPred : mbPred_t?; var mbType_2 : mbType_e; var numRefIdxActive_2 : uint) : uint {
    var tmp_29 : uint
    var i_35 : uint
    var j_2 : uint
    var value_19 : uint
    var itmp_2 : int
    if (uint(h264bsdMbPartPredMode(mbType_2)) == uint(PRED_MODE_INTER)) {
        if (numRefIdxActive_2 > uint(1)) {
            j_2 = uint(uint(0))
            j_2
            while (i_35 != 0x0) {
                tmp_29 = uint(h264bsdDecodeExpGolombTruncated(pStrmData_28, unsafe(addr(value_19)), uint(numRefIdxActive_2 > uint(2))))
                tmp_29
                if (tmp_29 != uint(0) || value_19 >= numRefIdxActive_2) {
                    return uint(1)
                }
                unsafe(unsafe(addr(pMbPred.refIdxL0[0]))[j_2]) = uint(value_19)
                unsafe(unsafe(addr(pMbPred.refIdxL0[0]))[j_2])
                j_2 = j_2 + 1
            }
        }
    } elif (uint(h264bsdMbPartPredMode(mbType_2)) == uint(PRED_MODE_INTRA4x4)) {
        i_35 = uint(uint(0))
        i_35
        while (itmp_2 < 2) {
            value_19 = uint(h264bsdShowBits32(pStrmData_28))
            value_19
            tmp_29 = uint(uint(0))
            tmp_29
            j_2 = uint(uint(8))
            j_2
            while (j_2 != 0x0) {
                var c2da_fresh37_h264bsd : int = 0
                if (value_19 & 0x80000000) {
                    c2da_fresh37_h264bsd = 1
                } else {
                    c2da_fresh37_h264bsd = 0
                }
                unsafe(unsafe(addr(pMbPred.prevIntra4x4PredModeFlag[0]))[i_35]) = uint(uint(c2da_fresh37_h264bsd))
                unsafe(unsafe(addr(pMbPred.prevIntra4x4PredModeFlag[0]))[i_35])
                value_19 = uint(value_19 << 1)
                value_19
                if (unsafe(unsafe(addr(pMbPred.prevIntra4x4PredModeFlag[0]))[i_35]) == 0) {
                    unsafe(unsafe(addr(pMbPred.remIntra4x4PredMode[0]))[i_35]) = uint(uint(value_19) >> uint(uint(29)))
                    unsafe(unsafe(addr(pMbPred.remIntra4x4PredMode[0]))[i_35])
                    value_19 = uint(value_19 << 3)
                    value_19
                    tmp_29 = tmp_29 + 1
                    tmp_29
                }
                i_35 = i_35 + 1
            }
            if (h264bsdFlushBits(pStrmData_28, uint(8) + uint(3) * tmp_29) == 0xffffffff) {
                return uint(1)
            }
            itmp_2 = itmp_2 + 1
        }
    } elif (uint(h264bsdMbPartPredMode(mbType_2)) == uint(PRED_MODE_INTRA16x16)) {
        tmp_29 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_28, unsafe(addr(value_19))))
        tmp_29
    }
    return uint(0)
}
[export]
def h264bsdNumMbPart(var mbType_3 : mbType_e) : uint {
    if (uint(mbType_3) == uint(P_L0_16x16) || uint(mbType_3) == uint(P_Skip)) {
        return uint(1)
    } elif (uint(mbType_3) == uint(P_L0_L0_16x8) || uint(mbType_3) == uint(P_L0_L0_8x16)) {
        return uint(2)
    } else {
        return uint(4)
    }
}
[export]
def h264bsdDecodeExpGolombTruncated(var pStrmData_29 : strmData_t?; var value_20 : uint?; var greaterThanOne : uint) : uint {
    if (greaterThanOne != 0x0) {
        return h264bsdDecodeExpGolombUnsigned(pStrmData_29, value_20)
    } else {
        *value_20 = uint(h264bsdGetBits(pStrmData_29, uint(1)))
        *value_20
        if (*value_20 == 0xffffffff) {
            return uint(1)
        }
        *value_20 = uint(*value_20 ^ uint(1))
        *value_20
    }
    return uint(0)
}
[export]
def DecodeSubMbPred(var pStrmData_30 : strmData_t?; var pSubMbPred : subMbPred_t?; var mbType_4 : mbType_e; var numRefIdxActive_3 : uint) : uint {
    var tmp_30 : uint
    var i_36 : uint
    var j_3 : uint
    var value_21 : uint
    var itmp_3 : int
    i_36 = uint(uint(0))
    i_36
    while (i_36 < uint(4)) {
        tmp_30 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_30, unsafe(addr(value_21))))
        tmp_30
        if (tmp_30 != uint(0) || value_21 > uint(3)) {
            return uint(1)
        }
        unsafe(unsafe(addr(pSubMbPred.subMbType[0]))[i_36]) = cast<subMbType_e>(value_21)
        unsafe(unsafe(addr(pSubMbPred.subMbType[0]))[i_36])
        i_36 = i_36 + 1
    }
    if (numRefIdxActive_3 > uint(1) && uint(mbType_4) != uint(P_8x8ref0)) {
        i_36 = uint(uint(0))
        i_36
        while (i_36 < uint(4)) {
            tmp_30 = uint(h264bsdDecodeExpGolombTruncated(pStrmData_30, unsafe(addr(value_21)), uint(numRefIdxActive_3 > uint(2))))
            tmp_30
            if (tmp_30 != uint(0) || value_21 >= numRefIdxActive_3) {
                return uint(1)
            }
            unsafe(unsafe(addr(pSubMbPred.refIdxL0[0]))[i_36]) = uint(value_21)
            unsafe(unsafe(addr(pSubMbPred.refIdxL0[0]))[i_36])
            i_36 = i_36 + 1
        }
    }
    i_36 = uint(uint(0))
    i_36
    while (i_36 < uint(4)) {
        j_3 = uint(uint(0))
        j_3
        value_21 = uint(h264bsdNumSubMbPart(unsafe(unsafe(addr(pSubMbPred.subMbType[0]))[i_36])))
        value_21
        while (value_21 != 0x0) {
            tmp_30 = uint(h264bsdDecodeExpGolombSigned(pStrmData_30, unsafe(addr(itmp_3))))
            tmp_30
            if (tmp_30 != uint(0)) {
                return tmp_30
            }
            unsafe(unsafe(addr(unsafe(unsafe(addr(pSubMbPred.mvdL0[0]))[i_36])[0]))[j_3]).hor = int(itmp_3)
            unsafe(unsafe(addr(unsafe(unsafe(addr(pSubMbPred.mvdL0[0]))[i_36])[0]))[j_3]).hor
            tmp_30 = uint(h264bsdDecodeExpGolombSigned(pStrmData_30, unsafe(addr(itmp_3))))
            tmp_30
            if (tmp_30 != uint(0)) {
                return tmp_30
            }
            unsafe(unsafe(addr(unsafe(unsafe(addr(pSubMbPred.mvdL0[0]))[i_36])[0]))[j_3]).ver = int(itmp_3)
            unsafe(unsafe(addr(unsafe(unsafe(addr(pSubMbPred.mvdL0[0]))[i_36])[0]))[j_3]).ver
            j_3 = j_3 + 1
        }
        i_36 = i_36 + 1
    }
    return uint(0)
}
[export]
def h264bsdNumSubMbPart(var subMbType : subMbType_e) : uint {
    if (uint(subMbType) == uint(P_L0_8x8)) {
        return uint(1)
    } elif (uint(subMbType) == uint(P_L0_8x4) || uint(subMbType) == uint(P_L0_4x8)) {
        return uint(2)
    } else {
        return uint(4)
    }
}
[export]
def h264bsdSubMbPartMode(var subMbType_0 : subMbType_e) : subMbPartMode_e {
    return cast<subMbPartMode_e>(subMbType_0)
}
[export]
def h264bsdDecodeMacroblock(var pMb_3 : mbStorage_t?; var pMbLayer_0 : macroblockLayer_t?; var currImage : image_t?; var dpb_21 : dpbStorage_t?; var qpY : int?; var mbNum_1 : uint; var constrainedIntraPredFlag : uint; var data_1 : uint8?) : uint {
    var i_37 : uint
    var tmp_31 : uint
    var mbType_5 : mbType_e
    mbType_5 = pMbLayer_0.mbType
    mbType_5
    pMb_3.mbType = mbType_5
    pMb_3.mbType
    pMb_3.decoded = pMb_3.decoded + 1
    pMb_3.decoded
    h264bsdSetCurrImageMbPointers(currImage, mbNum_1)
    if (uint(mbType_5) == uint(I_PCM)) {
        var pData : uint8? = cast<uint8?>(data_1)
        var tot : int? = unsafe(addr(pMb_3.totalCoeff[0]))
        var lev : int? = unsafe(addr(unsafe(unsafe(addr(pMbLayer_0.residual.level[0]))[0])[0]))
        pMb_3.qpY = uint(uint(0))
        pMb_3.qpY
        if (pMb_3.decoded > uint(1)) {
            i_37 = uint(uint(24))
            i_37
            while (i_37 != 0x0) {
                tot = tot + 1
                *tot = 16
                *tot
            }
            return uint(0)
        }
        i_37 = uint(uint(24))
        i_37
        while (i_37 != 0x0) {
            tot = tot + 1
            *tot = 16
            *tot
            tmp_31 = uint(uint(16))
            tmp_31
            while (tmp_31 != 0x0) {
                pData = pData + 1
                lev = lev + 1
                *pData = uint8(uint8(*lev))
                *pData
            }
        }
        h264bsdWriteMacroblock(currImage, cast<uint8?>(data_1))
        return uint(0)
    } else {
        if (uint(mbType_5) != uint(P_Skip)) {
            memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(pMb_3.totalCoeff[0]))))), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(pMbLayer_0.residual.totalCoeff[0]))))), uint64(27) * 4)
            if (pMbLayer_0.mbQpDelta != 0) {
                *qpY = *qpY + pMbLayer_0.mbQpDelta
                *qpY
                if (*qpY < 0) {
                    *qpY = *qpY + 52
                    *qpY
                } else {
                    if (*qpY >= 52) {
                        *qpY = *qpY - 52
                        *qpY
                    }
                }
            }
            pMb_3.qpY = uint(uint(*qpY))
            pMb_3.qpY
            tmp_31 = uint(ProcessResidual(pMb_3, unsafe(addr(pMbLayer_0.residual.level[0])), unsafe(addr(pMbLayer_0.residual.coeffMap[0]))))
            tmp_31
            if (tmp_31 != uint(0)) {
                return tmp_31
            }
        } else {
            memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(pMb_3.totalCoeff[0]))))), 0, uint64(27) * 4)
            pMb_3.qpY = uint(uint(*qpY))
            pMb_3.qpY
        }
        if (uint(h264bsdMbPartPredMode(mbType_5)) != uint(PRED_MODE_INTER)) {
            tmp_31 = uint(h264bsdIntraPrediction(pMb_3, pMbLayer_0, currImage, mbNum_1, constrainedIntraPredFlag, cast<uint8?>(data_1)))
            tmp_31
            if (tmp_31 != uint(0)) {
                return tmp_31
            }
        } else {
            tmp_31 = uint(h264bsdInterPrediction(pMb_3, pMbLayer_0, dpb_21, mbNum_1, currImage, cast<uint8?>(data_1)))
            tmp_31
            if (tmp_31 != uint(0)) {
                return tmp_31
            }
        }
    }
    return uint(0)
}
[export]
def h264bsdInterPrediction(var pMb_4 : mbStorage_t?; var pMbLayer_1 : macroblockLayer_t?; var dpb_22 : dpbStorage_t?; var mbNum_2 : uint; var currImage_0 : image_t?; var data_2 : uint8?) : uint {
    var i_38 : uint
    var x_0 : uint
    var y_0 : uint
    var row_1 : uint
    var col_1 : uint
    var subPartMode : subMbPartMode_e
    var refImage : image_t
    row_1 = uint(mbNum_2 / currImage_0.width)
    row_1
    col_1 = uint(mbNum_2 - row_1 * currImage_0.width)
    col_1
    row_1 = uint(row_1 * uint(16))
    row_1
    col_1 = uint(col_1 * uint(16))
    col_1
    refImage.width = uint(currImage_0.width)
    refImage.width
    refImage.height = uint(currImage_0.height)
    refImage.height
    if (uint(pMb_4.mbType) == uint(P_Skip) || uint(pMb_4.mbType) == uint(P_L0_16x16)) {
        if (MvPrediction16x16(pMb_4, unsafe(addr(pMbLayer_1.mbPred)), dpb_22) != uint(0)) {
            return uint(1)
        }
    } elif (uint(pMb_4.mbType) == uint(P_L0_L0_16x8)) {
        if (MvPrediction16x8(pMb_4, unsafe(addr(pMbLayer_1.mbPred)), dpb_22) != uint(0)) {
            return uint(1)
        }
    } elif (uint(pMb_4.mbType) == uint(P_L0_L0_8x16)) {
        if (MvPrediction8x16(pMb_4, unsafe(addr(pMbLayer_1.mbPred)), dpb_22) != uint(0)) {
            return uint(1)
        }
    } else {
        if (MvPrediction8x8(pMb_4, unsafe(addr(pMbLayer_1.subMbPred)), dpb_22) != uint(0)) {
            return uint(1)
        }
    }
    if (pMb_4.decoded > uint(1)) {
        return uint(0)
    }
    if (uint(pMb_4.mbType) != uint(P_Skip)) {
        h264bsdWriteOutputBlocks(currImage_0, mbNum_2, data_2, unsafe(addr(pMbLayer_1.residual.level[0])))
    } else {
        h264bsdWriteMacroblock(currImage_0, data_2)
    }
    return uint(0)
}
[export]
def h264bsdPredictSamples(var data_3 : uint8?; var mv : mv_t?; var refPic : image_t?; var xA : uint; var yA : uint; var partX : uint; var partY : uint; var partWidth : uint; var partHeight : uint) {
    var xFrac : uint
    var yFrac : uint
    var width_1 : uint
    var height_0 : uint
    var xInt : int
    var yInt : int
    var lumaPartData : uint8?
    lumaPartData = unsafe(unsafe(data_3 + uint(16) * partY) + partX)
    lumaPartData
    xFrac = uint(uint(mv.hor & 3))
    xFrac
    yFrac = uint(uint(mv.ver & 3))
    yFrac
    width_1 = uint(uint(16) * refPic.width)
    width_1
    height_0 = uint(uint(16) * refPic.height)
    height_0
    xInt = int(xA) + int(partX) + mv.hor >> 2
    xInt
    yInt = int(yA) + int(partY) + mv.ver >> 2
    yInt
    if (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(0)) {
        h264bsdFillBlock(refPic.data, lumaPartData, xInt, yInt, width_1, height_0, partWidth, partHeight, uint(16))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(1)) {
        h264bsdInterpolateVerQuarter(refPic.data, lumaPartData, xInt, yInt - 2, width_1, height_0, partWidth, partHeight, uint(0))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(2)) {
        h264bsdInterpolateVerHalf(refPic.data, lumaPartData, xInt, yInt - 2, width_1, height_0, partWidth, partHeight)
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(3)) {
        h264bsdInterpolateVerQuarter(refPic.data, lumaPartData, xInt, yInt - 2, width_1, height_0, partWidth, partHeight, uint(1))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(4)) {
        h264bsdInterpolateHorQuarter(refPic.data, lumaPartData, xInt - 2, yInt, width_1, height_0, partWidth, partHeight, uint(0))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(5)) {
        h264bsdInterpolateHorVerQuarter(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight, uint(0))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(6)) {
        h264bsdInterpolateMidHorQuarter(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight, uint(0))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(7)) {
        h264bsdInterpolateHorVerQuarter(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight, uint(2))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(8)) {
        h264bsdInterpolateHorHalf(refPic.data, lumaPartData, xInt - 2, yInt, width_1, height_0, partWidth, partHeight)
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(9)) {
        h264bsdInterpolateMidVerQuarter(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight, uint(0))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(10)) {
        h264bsdInterpolateMidHalf(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight)
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(11)) {
        h264bsdInterpolateMidVerQuarter(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight, uint(1))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(12)) {
        h264bsdInterpolateHorQuarter(refPic.data, lumaPartData, xInt - 2, yInt, width_1, height_0, partWidth, partHeight, uint(1))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(13)) {
        h264bsdInterpolateHorVerQuarter(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight, uint(1))
    } elif (unsafe(unsafe(addr(unsafe(unsafe(addr(lumaFracPos[0]))[xFrac])[0]))[yFrac]) == uint(14)) {
        h264bsdInterpolateMidHorQuarter(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight, uint(1))
    } else {
        h264bsdInterpolateHorVerQuarter(refPic.data, lumaPartData, xInt - 2, yInt - 2, width_1, height_0, partWidth, partHeight, uint(3))
    }
    PredictChroma(unsafe(unsafe(unsafe(data_3 + 16 * 16) + uint(partY) >> uint(uint(1)) * uint(8)) + uint(partX) >> uint(uint(1))), xA + partX, yA + partY, partWidth, partHeight, mv, refPic)
}
[export]
def PredictChroma(var mbPartChroma : uint8?; var xAL : uint; var yAL : uint; var partWidth_0 : uint; var partHeight_0 : uint; var mv_0 : mv_t?; var refPic_0 : image_t?) {
    var xFrac_0 : uint
    var yFrac_0 : uint
    var width_2 : uint
    var height_1 : uint
    var chromaPartWidth : uint
    var chromaPartHeight : uint
    var xInt_0 : int
    var yInt_0 : int
    var ref : uint8?
    width_2 = uint(uint(8) * refPic_0.width)
    width_2
    height_1 = uint(uint(8) * refPic_0.height)
    height_1
    xInt_0 = int(uint(xAL) >> uint(uint(1)) + uint(mv_0.hor >> 3))
    xInt_0
    yInt_0 = int(uint(yAL) >> uint(uint(1)) + uint(mv_0.ver >> 3))
    yInt_0
    xFrac_0 = uint(uint(mv_0.hor & 7))
    xFrac_0
    yFrac_0 = uint(uint(mv_0.ver & 7))
    yFrac_0
    chromaPartWidth = uint(uint(partWidth_0) >> uint(uint(1)))
    chromaPartWidth
    chromaPartHeight = uint(uint(partHeight_0) >> uint(uint(1)))
    chromaPartHeight
    ref = unsafe(refPic_0.data + uint(256) * refPic_0.width * refPic_0.height)
    ref
    if (xFrac_0 != 0x0 && yFrac_0 != 0x0) {
        h264bsdInterpolateChromaHorVer(ref, mbPartChroma, xInt_0, yInt_0, width_2, height_1, xFrac_0, yFrac_0, chromaPartWidth, chromaPartHeight)
    } else {
        if (xFrac_0 != 0x0) {
            h264bsdInterpolateChromaHor(ref, mbPartChroma, xInt_0, yInt_0, width_2, height_1, xFrac_0, chromaPartWidth, chromaPartHeight)
        } else {
            if (yFrac_0 != 0x0) {
                h264bsdInterpolateChromaVer(ref, mbPartChroma, xInt_0, yInt_0, width_2, height_1, yFrac_0, chromaPartWidth, chromaPartHeight)
            } else {
                h264bsdFillBlock(ref, mbPartChroma, xInt_0, yInt_0, width_2, height_1, chromaPartWidth, chromaPartHeight, uint(8))
                ref = ref + width_2 * height_1
                ref
                h264bsdFillBlock(ref, unsafe(mbPartChroma + 8 * 8), xInt_0, yInt_0, width_2, height_1, chromaPartWidth, chromaPartHeight, uint(8))
            }
        }
    }
}
[export]
def h264bsdFillBlock(var ref_0 : uint8?; var fill : uint8?; var x0 : int; var y0 : int; var width_3 : uint; var height_2 : uint; var blockWidth : uint; var blockHeight : uint; var fillScanLength : uint) {
    var xstop : int
    var ystop : int
    var fp : function?
    if (ystop < 0) {
        y0 = -int(blockHeight)
        y0
    }
    if (xstop < 0) {
        x0 = -int(blockWidth)
        x0
    }
    if (y0 > int(height_2)) {
        y0 = int(height_2)
        y0
    }
    if (x0 > int(width_3)) {
        x0 = int(width_3)
        x0
    }
    xstop = x0 + int(blockWidth)
    xstop
    ystop = y0 + int(blockHeight)
    ystop
    if (x0 > 0) {
        ref_0 = ref_0 + x0
        ref_0
    }
    if (y0 > 0) {
        ref_0 = ref_0 + y0 * int(width_3)
        ref_0
    }
    var c2da_fresh38_h264bsd : int = 0
    if (x0 < 0) {
        c2da_fresh38_h264bsd = -x0
    } else {
        c2da_fresh38_h264bsd = 0
    }
    left = c2da_fresh38_h264bsd
    left
    var c2da_fresh39_h264bsd : int = 0
    if (xstop > int(width_3)) {
        c2da_fresh39_h264bsd = xstop - int(width_3)
    } else {
        c2da_fresh39_h264bsd = 0
    }
    right = c2da_fresh39_h264bsd
    right
    x_1 = int(blockWidth) - left - right
    x_1
    var c2da_fresh40_h264bsd : int = 0
    if (y0 < 0) {
        c2da_fresh40_h264bsd = -y0
    } else {
        c2da_fresh40_h264bsd = 0
    }
    top = c2da_fresh40_h264bsd
    top
    var c2da_fresh41_h264bsd : int = 0
    if (ystop > int(height_2)) {
        c2da_fresh41_h264bsd = ystop - int(height_2)
    } else {
        c2da_fresh41_h264bsd = 0
    }
    bottom = c2da_fresh41_h264bsd
    bottom
    y_1 = int(blockHeight) - top - bottom
    y_1
    if (x0 >= 0 && xstop <= int(width_3)) {
        while (top != 0) {
            FillRow1(ref_0, fill, left, x_1, right)
            fill = fill + fillScanLength
            fill
            top = top - 1
        }
        while (top != 0) {
            FillRow1(ref_0, fill, left, x_1, right)
            top = top - 1
        }
        while (y_1 != 0) {
            FillRow1(ref_0, fill, left, x_1, right)
            ref_0 = ref_0 + width_3
            ref_0
            fill = fill + fillScanLength
            fill
            y_1 = y_1 - 1
        }
    } else {
        while (top != 0) {
            h264bsdFillRow7(ref_0, fill, left, x_1, right)
            fill = fill + fillScanLength
            fill
            top = top - 1
        }
        while (top != 0) {
            h264bsdFillRow7(ref_0, fill, left, x_1, right)
            top = top - 1
        }
        while (y_1 != 0) {
            h264bsdFillRow7(ref_0, fill, left, x_1, right)
            ref_0 = ref_0 + width_3
            ref_0
            fill = fill + fillScanLength
            fill
            y_1 = y_1 - 1
        }
    }
    ref_0 = ref_0 - width_3
    ref_0
    while (bottom != 0) {
        if (x0 >= 0 && xstop <= int(width_3)) {
            FillRow1(ref_0, fill, left, x_1, right)
        } else {
            h264bsdFillRow7(ref_0, fill, left, x_1, right)
        }
        fill = fill + fillScanLength
        fill
        bottom = bottom - 1
    }
}
[export]
def h264bsdFillRow7(var ref_1 : uint8?; var fill_0 : uint8?; var left_0 : int; var center : int; var right_0 : int) {
    var tmp_32 : uint8 = uint8(0)
    if (left_0 != 0) {
        tmp_32 = uint8(*ref_1)
        tmp_32
    }
    while (left_0 != 0) {
        fill_0 = fill_0 + 1
        *fill_0 = uint8(tmp_32)
        *fill_0
        left_0 = left_0 - 1
    }
    while (center != 0) {
        fill_0 = fill_0 + 1
        ref_1 = ref_1 + 1
        *fill_0 = uint8(*ref_1)
        *fill_0
        center = center - 1
    }
    if (right_0 != 0) {
        tmp_32 = uint8(unsafe(ref_1[-1]))
        tmp_32
    }
    while (right_0 != 0) {
        fill_0 = fill_0 + 1
        *fill_0 = uint8(tmp_32)
        *fill_0
        right_0 = right_0 - 1
    }
}
[export]
def FillRow1(var ref_2 : uint8?; var fill_1 : uint8?; var left_1 : int; var center_0 : int; var right_1 : int) {
    memcpy(unsafe(unsafe(reinterpret<uint64>(fill_1))), unsafe(unsafe(reinterpret<uint64>(ref_2))), uint64(center_0))
}
[export]
def h264bsdInterpolateChromaVer(var pRef : uint8?; var predPartChroma : uint8?; var x0_0 : int; var y0_0 : int; var width_4 : uint; var height_3 : uint; var yFrac_1 : uint; var chromaPartWidth_0 : uint; var chromaPartHeight_0 : uint) {
    var x_2 : uint
    var y_2 : uint
    var tmp1_1 : uint
    var tmp2_1 : uint
    var tmp3_0 : uint
    var c : uint
    var val : uint
    var ptrA : uint8?
    var cbr : uint8?
    var comp : uint
    var block_1 : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    if (x0_0 < 0 || uint(x0_0) + chromaPartWidth_0 > width_4 || y0_0 < 0 || uint(y0_0) + chromaPartHeight_0 + uint(1) > height_3) {
        h264bsdFillBlock(pRef, unsafe(addr(block_1[0])), x0_0, y0_0, width_4, height_3, chromaPartWidth_0, chromaPartHeight_0 + uint(1), chromaPartWidth_0)
        pRef = pRef + width_4 * height_3
        pRef
        h264bsdFillBlock(pRef, unsafe(unsafe(addr(block_1[0])) + chromaPartWidth_0 * chromaPartHeight_0 + uint(1)), x0_0, y0_0, width_4, height_3, chromaPartWidth_0, chromaPartHeight_0 + uint(1), chromaPartWidth_0)
        pRef = unsafe(addr(block_1[0]))
        pRef
        x0_0 = 0
        x0_0
        y0_0 = 0
        y0_0
        width_4 = uint(chromaPartWidth_0)
        width_4
        height_3 = uint(chromaPartHeight_0 + uint(1))
        height_3
    }
    val = uint(uint(8) - yFrac_1)
    val
    comp = uint(uint(0))
    comp
    while (comp <= uint(1)) {
        ptrA = unsafe(unsafe(pRef + comp * height_3 + uint(y0_0) * width_4) + x0_0)
        ptrA
        cbr = unsafe(predPartChroma + comp * uint(8) * uint(8))
        cbr
        y_2 = uint(uint(chromaPartHeight_0) >> uint(uint(1)))
        y_2
        while (y_2 != 0x0) {
            x_2 = uint(uint(chromaPartWidth_0) >> uint(uint(1)))
            x_2
            while (x_2 != 0x0) {
                tmp3_0 = uint(uint(unsafe(ptrA[width_4 * uint(2)])))
                tmp3_0
                tmp2_1 = uint(uint(unsafe(ptrA[width_4])))
                tmp2_1
                ptrA = ptrA + 1
                tmp1_1 = uint(uint(*ptrA))
                tmp1_1
                c = uint(uint(val * tmp2_1 + yFrac_1 * tmp3_0) << uint(uint(3)) + uint(32))
                c
                c = uint(c >> 6)
                c
                unsafe(cbr[8]) = uint8(uint8(c))
                unsafe(cbr[8])
                c = uint(uint(val * tmp1_1 + yFrac_1 * tmp2_1) << uint(uint(3)) + uint(32))
                c
                c = uint(c >> 6)
                c
                cbr = cbr + 1
                *cbr = uint8(uint8(c))
                *cbr
                tmp3_0 = uint(uint(unsafe(ptrA[width_4 * uint(2)])))
                tmp3_0
                tmp2_1 = uint(uint(unsafe(ptrA[width_4])))
                tmp2_1
                ptrA = ptrA + 1
                tmp1_1 = uint(uint(*ptrA))
                tmp1_1
                c = uint(uint(val * tmp2_1 + yFrac_1 * tmp3_0) << uint(uint(3)) + uint(32))
                c
                c = uint(c >> 6)
                c
                unsafe(cbr[8]) = uint8(uint8(c))
                unsafe(cbr[8])
                c = uint(uint(val * tmp1_1 + yFrac_1 * tmp2_1) << uint(uint(3)) + uint(32))
                c
                c = uint(c >> 6)
                c
                cbr = cbr + 1
                *cbr = uint8(uint8(c))
                *cbr
                x_2 = x_2 - 1
            }
            cbr = cbr + uint(2 * 8) - chromaPartWidth_0
            cbr
            ptrA = ptrA + uint(2) * width_4 - chromaPartWidth_0
            ptrA
            y_2 = y_2 - 1
        }
        comp = comp + 1
    }
}
[export]
def h264bsdInterpolateChromaHor(var pRef_0 : uint8?; var predPartChroma_0 : uint8?; var x0_1 : int; var y0_1 : int; var width_5 : uint; var height_4 : uint; var xFrac_1 : uint; var chromaPartWidth_1 : uint; var chromaPartHeight_1 : uint) {
    var x_3 : uint
    var y_3 : uint
    var tmp1_2 : uint
    var tmp2_2 : uint
    var tmp3_1 : uint
    var tmp4_0 : uint
    var c_0 : uint
    var val_0 : uint
    var ptrA_0 : uint8?
    var cbr_0 : uint8?
    var comp_0 : uint
    var block_2 : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    if (x0_1 < 0 || uint(x0_1) + chromaPartWidth_1 + uint(1) > width_5 || y0_1 < 0 || uint(y0_1) + chromaPartHeight_1 > height_4) {
        h264bsdFillBlock(pRef_0, unsafe(addr(block_2[0])), x0_1, y0_1, width_5, height_4, chromaPartWidth_1 + uint(1), chromaPartHeight_1, chromaPartWidth_1 + uint(1))
        pRef_0 = pRef_0 + width_5 * height_4
        pRef_0
        h264bsdFillBlock(pRef_0, unsafe(unsafe(addr(block_2[0])) + chromaPartWidth_1 + uint(1) * chromaPartHeight_1), x0_1, y0_1, width_5, height_4, chromaPartWidth_1 + uint(1), chromaPartHeight_1, chromaPartWidth_1 + uint(1))
        pRef_0 = unsafe(addr(block_2[0]))
        pRef_0
        x0_1 = 0
        x0_1
        y0_1 = 0
        y0_1
        width_5 = uint(chromaPartWidth_1 + uint(1))
        width_5
        height_4 = uint(chromaPartHeight_1)
        height_4
    }
    val_0 = uint(uint(8) - xFrac_1)
    val_0
    comp_0 = uint(uint(0))
    comp_0
    while (comp_0 <= uint(1)) {
        ptrA_0 = unsafe(unsafe(pRef_0 + comp_0 * height_4 + uint(y0_1) * width_5) + x0_1)
        ptrA_0
        cbr_0 = unsafe(predPartChroma_0 + comp_0 * uint(8) * uint(8))
        cbr_0
        y_3 = uint(uint(chromaPartHeight_1) >> uint(uint(1)))
        y_3
        while (y_3 != 0x0) {
            x_3 = uint(uint(chromaPartWidth_1) >> uint(uint(1)))
            x_3
            while (x_3 != 0x0) {
                tmp1_2 = uint(uint(unsafe(ptrA_0[width_5])))
                tmp1_2
                ptrA_0 = ptrA_0 + 1
                tmp2_2 = uint(uint(*ptrA_0))
                tmp2_2
                tmp3_1 = uint(uint(unsafe(ptrA_0[width_5])))
                tmp3_1
                ptrA_0 = ptrA_0 + 1
                tmp4_0 = uint(uint(*ptrA_0))
                tmp4_0
                c_0 = uint(uint(val_0 * tmp1_2 + xFrac_1 * tmp3_1) << uint(uint(3)) + uint(32))
                c_0
                c_0 = uint(c_0 >> 6)
                c_0
                unsafe(cbr_0[8]) = uint8(uint8(c_0))
                unsafe(cbr_0[8])
                c_0 = uint(uint(val_0 * tmp2_2 + xFrac_1 * tmp4_0) << uint(uint(3)) + uint(32))
                c_0
                c_0 = uint(c_0 >> 6)
                c_0
                cbr_0 = cbr_0 + 1
                *cbr_0 = uint8(uint8(c_0))
                *cbr_0
                tmp1_2 = uint(uint(unsafe(ptrA_0[width_5])))
                tmp1_2
                tmp2_2 = uint(uint(*ptrA_0))
                tmp2_2
                c_0 = uint(uint(val_0 * tmp3_1 + xFrac_1 * tmp1_2) << uint(uint(3)) + uint(32))
                c_0
                c_0 = uint(c_0 >> 6)
                c_0
                unsafe(cbr_0[8]) = uint8(uint8(c_0))
                unsafe(cbr_0[8])
                c_0 = uint(uint(val_0 * tmp4_0 + xFrac_1 * tmp2_2) << uint(uint(3)) + uint(32))
                c_0
                c_0 = uint(c_0 >> 6)
                c_0
                cbr_0 = cbr_0 + 1
                *cbr_0 = uint8(uint8(c_0))
                *cbr_0
                x_3 = x_3 - 1
            }
            cbr_0 = cbr_0 + uint(2 * 8) - chromaPartWidth_1
            cbr_0
            ptrA_0 = ptrA_0 + uint(2) * width_5 - chromaPartWidth_1
            ptrA_0
            y_3 = y_3 - 1
        }
        comp_0 = comp_0 + 1
    }
}
[export]
def h264bsdInterpolateChromaHorVer(var ref_3 : uint8?; var predPartChroma_1 : uint8?; var x0_2 : int; var y0_2 : int; var width_6 : uint; var height_5 : uint; var xFrac_2 : uint; var yFrac_2 : uint; var chromaPartWidth_2 : uint; var chromaPartHeight_2 : uint) {
    var block_3 : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var x_4 : uint
    var y_4 : uint
    var tmp1_3 : uint
    var tmp2_3 : uint
    var tmp3_2 : uint
    var tmp4_1 : uint
    var tmp5 : uint
    var tmp6 : uint
    var valX : uint
    var valY : uint
    var plus32 : uint = uint(32)
    var comp_1 : uint
    var ptrA_1 : uint8?
    var cbr_1 : uint8?
    if (x0_2 < 0 || uint(x0_2) + chromaPartWidth_2 + uint(1) > width_6 || y0_2 < 0 || uint(y0_2) + chromaPartHeight_2 + uint(1) > height_5) {
        h264bsdFillBlock(ref_3, unsafe(addr(block_3[0])), x0_2, y0_2, width_6, height_5, chromaPartWidth_2 + uint(1), chromaPartHeight_2 + uint(1), chromaPartWidth_2 + uint(1))
        ref_3 = ref_3 + width_6 * height_5
        ref_3
        h264bsdFillBlock(ref_3, unsafe(unsafe(addr(block_3[0])) + chromaPartWidth_2 + uint(1) * chromaPartHeight_2 + uint(1)), x0_2, y0_2, width_6, height_5, chromaPartWidth_2 + uint(1), chromaPartHeight_2 + uint(1), chromaPartWidth_2 + uint(1))
        ref_3 = unsafe(addr(block_3[0]))
        ref_3
        x0_2 = 0
        x0_2
        y0_2 = 0
        y0_2
        width_6 = uint(chromaPartWidth_2 + uint(1))
        width_6
        height_5 = uint(chromaPartHeight_2 + uint(1))
        height_5
    }
    valX = uint(uint(8) - xFrac_2)
    valX
    valY = uint(uint(8) - yFrac_2)
    valY
    comp_1 = uint(uint(0))
    comp_1
    while (comp_1 <= uint(1)) {
        ptrA_1 = unsafe(unsafe(ref_3 + comp_1 * height_5 + uint(y0_2) * width_6) + x0_2)
        ptrA_1
        cbr_1 = unsafe(predPartChroma_1 + comp_1 * uint(8) * uint(8))
        cbr_1
        y_4 = uint(uint(chromaPartHeight_2) >> uint(uint(1)))
        y_4
        while (y_4 != 0x0) {
            tmp1_3 = uint(uint(*ptrA_1))
            tmp1_3
            tmp3_2 = uint(uint(unsafe(ptrA_1[width_6])))
            tmp3_2
            tmp5 = uint(uint(unsafe(ptrA_1[width_6 * uint(2)])))
            tmp5
            tmp1_3 = uint(tmp1_3 * valY)
            tmp1_3
            tmp1_3 = uint(tmp1_3 + tmp3_2 * yFrac_2)
            tmp1_3
            tmp3_2 = uint(tmp3_2 * valY)
            tmp3_2
            tmp3_2 = uint(tmp3_2 + tmp5 * yFrac_2)
            tmp3_2
            x_4 = uint(uint(chromaPartWidth_2) >> uint(uint(1)))
            x_4
            while (x_4 != 0x0) {
                ptrA_1 = ptrA_1 + 1
                tmp2_3 = uint(uint(*ptrA_1))
                tmp2_3
                tmp4_1 = uint(uint(unsafe(ptrA_1[width_6])))
                tmp4_1
                tmp6 = uint(uint(unsafe(ptrA_1[width_6 * uint(2)])))
                tmp6
                tmp2_3 = uint(tmp2_3 * valY)
                tmp2_3
                tmp2_3 = uint(tmp2_3 + tmp4_1 * yFrac_2)
                tmp2_3
                tmp4_1 = uint(tmp4_1 * valY)
                tmp4_1
                tmp4_1 = uint(tmp4_1 + tmp6 * yFrac_2)
                tmp4_1
                tmp1_3 = uint(tmp1_3 * valX + plus32)
                tmp1_3
                tmp3_2 = uint(tmp3_2 * valX + plus32)
                tmp3_2
                tmp1_3 = uint(tmp1_3 + tmp2_3 * xFrac_2)
                tmp1_3
                tmp1_3 = uint(tmp1_3 >> 6)
                tmp1_3
                tmp3_2 = uint(tmp3_2 + tmp4_1 * xFrac_2)
                tmp3_2
                tmp3_2 = uint(tmp3_2 >> 6)
                tmp3_2
                unsafe(cbr_1[8]) = uint8(uint8(tmp3_2))
                unsafe(cbr_1[8])
                cbr_1 = cbr_1 + 1
                *cbr_1 = uint8(uint8(tmp1_3))
                *cbr_1
                ptrA_1 = ptrA_1 + 1
                tmp1_3 = uint(uint(*ptrA_1))
                tmp1_3
                tmp3_2 = uint(uint(unsafe(ptrA_1[width_6])))
                tmp3_2
                tmp5 = uint(uint(unsafe(ptrA_1[width_6 * uint(2)])))
                tmp5
                tmp1_3 = uint(tmp1_3 * valY)
                tmp1_3
                tmp1_3 = uint(tmp1_3 + tmp3_2 * yFrac_2)
                tmp1_3
                tmp3_2 = uint(tmp3_2 * valY)
                tmp3_2
                tmp3_2 = uint(tmp3_2 + tmp5 * yFrac_2)
                tmp3_2
                tmp2_3 = uint(tmp2_3 * valX + plus32)
                tmp2_3
                tmp4_1 = uint(tmp4_1 * valX + plus32)
                tmp4_1
                tmp2_3 = uint(tmp2_3 + tmp1_3 * xFrac_2)
                tmp2_3
                tmp2_3 = uint(tmp2_3 >> 6)
                tmp2_3
                tmp4_1 = uint(tmp4_1 + tmp3_2 * xFrac_2)
                tmp4_1
                tmp4_1 = uint(tmp4_1 >> 6)
                tmp4_1
                unsafe(cbr_1[8]) = uint8(uint8(tmp4_1))
                unsafe(cbr_1[8])
                cbr_1 = cbr_1 + 1
                *cbr_1 = uint8(uint8(tmp2_3))
                *cbr_1
                x_4 = x_4 - 1
            }
            cbr_1 = cbr_1 + uint(2 * 8) - chromaPartWidth_2
            cbr_1
            ptrA_1 = ptrA_1 + uint(2) * width_6 - chromaPartWidth_2
            ptrA_1
            y_4 = y_4 - 1
        }
        comp_1 = comp_1 + 1
    }
}
[export]
def h264bsdInterpolateHorVerQuarter(var ref_4 : uint8?; var mb : uint8?; var x0_3 : int; var y0_3 : int; var width_7 : uint; var height_6 : uint; var partWidth_1 : uint; var partHeight_1 : uint; var horVerOffset : uint) {
    var p1 : array<uint> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var ptrC : uint8?
    var ptrJ : uint8?
    var ptrV : uint8?
    var x_5 : uint
    var y_5 : uint
    var tmp1_4 : int
    var tmp2_4 : int
    var tmp3_3 : int
    var tmp4_2 : int
    var tmp5_0 : int
    var tmp6_0 : int
    var tmp7 : int
    var clp_0 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (x0_3 < 0 || uint(x0_3) + partWidth_1 + uint(5) > width_7 || y0_3 < 0 || uint(y0_3) + partHeight_1 + uint(5) > height_6) {
        h264bsdFillBlock(ref_4, unsafe(reinterpret<uint8?>(unsafe(addr(p1[0])))), x0_3, y0_3, width_7, height_6, partWidth_1 + uint(5), partHeight_1 + uint(5), partWidth_1 + uint(5))
        x0_3 = 0
        x0_3
        y0_3 = 0
        y0_3
        ref_4 = unsafe(reinterpret<uint8?>(unsafe(addr(p1[0]))))
        ref_4
        width_7 = uint(partWidth_1 + uint(5))
        width_7
    }
    ref_4 = ref_4 + uint(y0_3) * width_7 + uint(x0_3)
    ref_4
    ptrJ = unsafe(unsafe(ref_4 + uint(horVerOffset & uint(2)) >> uint(uint(1)) + uint(2) * width_7) + 5)
    ptrJ
    ptrC = unsafe(unsafe(unsafe(ref_4 + width_7) + 2) + horVerOffset & uint(1))
    ptrC
    y_5 = uint(partHeight_1)
    y_5
    while (y_5 != 0x0) {
        tmp6_0 = int(*unsafe(ptrJ - 5))
        tmp6_0
        tmp5_0 = int(*unsafe(ptrJ - 4))
        tmp5_0
        tmp4_2 = int(*unsafe(ptrJ - 3))
        tmp4_2
        tmp3_3 = int(*unsafe(ptrJ - 2))
        tmp3_3
        tmp2_4 = int(*unsafe(ptrJ - 1))
        tmp2_4
        x_5 = uint(uint(partWidth_1) >> uint(uint(2)))
        x_5
        while (x_5 != 0x0) {
            tmp6_0 = tmp6_0 + 16
            tmp6_0
            tmp7 = tmp3_3 + tmp4_2
            tmp7
            tmp6_0 = tmp6_0 + tmp7 << 4
            tmp6_0
            tmp6_0 = tmp6_0 + tmp7 << 2
            tmp6_0
            tmp7 = tmp2_4 + tmp5_0
            tmp7
            ptrJ = ptrJ + 1
            tmp1_4 = int(*ptrJ)
            tmp1_4
            tmp6_0 = tmp6_0 - tmp7 << 2
            tmp6_0
            tmp6_0 = tmp6_0 - tmp7
            tmp6_0
            tmp6_0 = tmp6_0 + tmp1_4
            tmp6_0
            tmp6_0 = int(unsafe(clp_0[tmp6_0 >> 5]))
            tmp6_0
            tmp5_0 = tmp5_0 + 16
            tmp5_0
            tmp7 = tmp2_4 + tmp3_3
            tmp7
            mb = mb + 1
            *mb = uint8(uint8(tmp6_0))
            *mb
            tmp5_0 = tmp5_0 + tmp7 << 4
            tmp5_0
            tmp5_0 = tmp5_0 + tmp7 << 2
            tmp5_0
            tmp7 = tmp1_4 + tmp4_2
            tmp7
            ptrJ = ptrJ + 1
            tmp6_0 = int(*ptrJ)
            tmp6_0
            tmp5_0 = tmp5_0 - tmp7 << 2
            tmp5_0
            tmp5_0 = tmp5_0 - tmp7
            tmp5_0
            tmp5_0 = tmp5_0 + tmp6_0
            tmp5_0
            tmp5_0 = int(unsafe(clp_0[tmp5_0 >> 5]))
            tmp5_0
            tmp4_2 = tmp4_2 + 16
            tmp4_2
            tmp7 = tmp1_4 + tmp2_4
            tmp7
            mb = mb + 1
            *mb = uint8(uint8(tmp5_0))
            *mb
            tmp4_2 = tmp4_2 + tmp7 << 4
            tmp4_2
            tmp4_2 = tmp4_2 + tmp7 << 2
            tmp4_2
            tmp7 = tmp6_0 + tmp3_3
            tmp7
            ptrJ = ptrJ + 1
            tmp5_0 = int(*ptrJ)
            tmp5_0
            tmp4_2 = tmp4_2 - tmp7 << 2
            tmp4_2
            tmp4_2 = tmp4_2 - tmp7
            tmp4_2
            tmp4_2 = tmp4_2 + tmp5_0
            tmp4_2
            tmp4_2 = int(unsafe(clp_0[tmp4_2 >> 5]))
            tmp4_2
            tmp3_3 = tmp3_3 + 16
            tmp3_3
            tmp7 = tmp6_0 + tmp1_4
            tmp7
            mb = mb + 1
            *mb = uint8(uint8(tmp4_2))
            *mb
            tmp3_3 = tmp3_3 + tmp7 << 4
            tmp3_3
            tmp3_3 = tmp3_3 + tmp7 << 2
            tmp3_3
            tmp7 = tmp5_0 + tmp2_4
            tmp7
            ptrJ = ptrJ + 1
            tmp4_2 = int(*ptrJ)
            tmp4_2
            tmp3_3 = tmp3_3 - tmp7 << 2
            tmp3_3
            tmp3_3 = tmp3_3 - tmp7
            tmp3_3
            tmp3_3 = tmp3_3 + tmp4_2
            tmp3_3
            tmp3_3 = int(unsafe(clp_0[tmp3_3 >> 5]))
            tmp3_3
            tmp7 = tmp4_2
            tmp7
            tmp4_2 = tmp6_0
            tmp4_2
            tmp6_0 = tmp2_4
            tmp6_0
            tmp2_4 = tmp7
            tmp2_4
            mb = mb + 1
            *mb = uint8(uint8(tmp3_3))
            *mb
            tmp3_3 = tmp5_0
            tmp3_3
            tmp5_0 = tmp1_4
            tmp5_0
            x_5 = x_5 - 1
        }
        ptrJ = ptrJ + width_7 - partWidth_1
        ptrJ
        mb = mb + uint(16) - partWidth_1
        mb
        y_5 = y_5 - 1
    }
    mb = mb - uint(16) * partHeight_1
    mb
    ptrV = unsafe(ptrC + uint(5) * width_7)
    ptrV
    y_5 = uint(uint(partHeight_1) >> uint(uint(2)))
    y_5
    while (y_5 != 0x0) {
        x_5 = uint(partWidth_1)
        x_5
        while (x_5 != 0x0) {
            tmp4_2 = int(unsafe(ptrV[-int(width_7) * 2]))
            tmp4_2
            tmp5_0 = int(unsafe(ptrV[-int(width_7)]))
            tmp5_0
            tmp1_4 = int(unsafe(ptrV[width_7]))
            tmp1_4
            tmp2_4 = int(unsafe(ptrV[width_7 * uint(2)]))
            tmp2_4
            ptrV = ptrV + 1
            tmp6_0 = int(*ptrV)
            tmp6_0
            tmp7 = tmp4_2 + tmp1_4
            tmp7
            tmp2_4 = tmp2_4 - tmp7 << 2
            tmp2_4
            tmp2_4 = tmp2_4 - tmp7
            tmp2_4
            tmp2_4 = tmp2_4 + 16
            tmp2_4
            tmp7 = tmp5_0 + tmp6_0
            tmp7
            tmp3_3 = int(unsafe(ptrC[width_7 * uint(2)]))
            tmp3_3
            tmp2_4 = tmp2_4 + tmp7 << 4
            tmp2_4
            tmp2_4 = tmp2_4 + tmp7 << 2
            tmp2_4
            tmp2_4 = tmp2_4 + tmp3_3
            tmp2_4
            tmp7 = int(unsafe(clp_0[tmp2_4 >> 5]))
            tmp7
            tmp2_4 = int(unsafe(mb[48]))
            tmp2_4
            tmp1_4 = tmp1_4 + 16
            tmp1_4
            tmp7 = tmp7 + 1
            tmp7
            unsafe(mb[48]) = uint8(uint8(tmp2_4 + tmp7 >> 1))
            unsafe(mb[48])
            tmp7 = tmp3_3 + tmp6_0
            tmp7
            tmp1_4 = tmp1_4 - tmp7 << 2
            tmp1_4
            tmp1_4 = tmp1_4 - tmp7
            tmp1_4
            tmp7 = tmp4_2 + tmp5_0
            tmp7
            tmp2_4 = int(unsafe(ptrC[width_7]))
            tmp2_4
            tmp1_4 = tmp1_4 + tmp7 << 4
            tmp1_4
            tmp1_4 = tmp1_4 + tmp7 << 2
            tmp1_4
            tmp1_4 = tmp1_4 + tmp2_4
            tmp1_4
            tmp7 = int(unsafe(clp_0[tmp1_4 >> 5]))
            tmp7
            tmp1_4 = int(unsafe(mb[32]))
            tmp1_4
            tmp6_0 = tmp6_0 + 16
            tmp6_0
            tmp7 = tmp7 + 1
            tmp7
            unsafe(mb[32]) = uint8(uint8(tmp1_4 + tmp7 >> 1))
            unsafe(mb[32])
            tmp1_4 = int(*ptrC)
            tmp1_4
            tmp7 = tmp2_4 + tmp5_0
            tmp7
            tmp6_0 = tmp6_0 - tmp7 << 2
            tmp6_0
            tmp6_0 = tmp6_0 - tmp7
            tmp6_0
            tmp7 = tmp4_2 + tmp3_3
            tmp7
            tmp6_0 = tmp6_0 + tmp7 << 4
            tmp6_0
            tmp6_0 = tmp6_0 + tmp7 << 2
            tmp6_0
            tmp6_0 = tmp6_0 + tmp1_4
            tmp6_0
            tmp7 = int(unsafe(clp_0[tmp6_0 >> 5]))
            tmp7
            tmp6_0 = int(unsafe(mb[16]))
            tmp6_0
            tmp5_0 = tmp5_0 + 16
            tmp5_0
            tmp7 = tmp7 + 1
            tmp7
            unsafe(mb[16]) = uint8(uint8(tmp6_0 + tmp7 >> 1))
            unsafe(mb[16])
            tmp6_0 = int(unsafe(ptrC[-int(width_7)]))
            tmp6_0
            tmp1_4 = tmp1_4 + tmp4_2
            tmp1_4
            tmp5_0 = tmp5_0 - tmp1_4 << 2
            tmp5_0
            tmp5_0 = tmp5_0 - tmp1_4
            tmp5_0
            tmp3_3 = tmp3_3 + tmp2_4
            tmp3_3
            tmp5_0 = tmp5_0 + tmp3_3 << 4
            tmp5_0
            tmp5_0 = tmp5_0 + tmp3_3 << 2
            tmp5_0
            tmp5_0 = tmp5_0 + tmp6_0
            tmp5_0
            tmp7 = int(unsafe(clp_0[tmp5_0 >> 5]))
            tmp7
            tmp5_0 = int(*mb)
            tmp5_0
            tmp7 = tmp7 + 1
            tmp7
            mb = mb + 1
            *mb = uint8(uint8(tmp5_0 + tmp7 >> 1))
            *mb
            ptrC = ptrC + 1
            ptrC
            x_5 = x_5 - 1
        }
        ptrC = ptrC + uint(4) * width_7 - partWidth_1
        ptrC
        ptrV = ptrV + uint(4) * width_7 - partWidth_1
        ptrV
        mb = mb + uint(4 * 16) - partWidth_1
        mb
        y_5 = y_5 - 1
    }
}
[export]
def h264bsdInterpolateMidHorQuarter(var ref_5 : uint8?; var mb_0 : uint8?; var x0_4 : int; var y0_4 : int; var width_8 : uint; var height_7 : uint; var partWidth_2 : uint; var partHeight_2 : uint; var horOffset : uint) {
    var p1_0 : array<uint> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var x_6 : uint
    var y_6 : uint
    var tmp1_5 : int
    var tmp2_5 : int
    var tmp3_4 : int
    var tmp4_3 : int
    var tmp5_1 : int
    var tmp6_1 : int
    var tmp7_0 : int
    var ptrJ_0 : int?
    var ptrInt : int?
    var h1 : int?
    var ptrC_0 : uint8?
    var ptrV_0 : uint8?
    var table_0 : array<int> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var tableWidth : int = int(partWidth_2) + 5
    var clp_1 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (x0_4 < 0 || uint(x0_4) + partWidth_2 + uint(5) > width_8 || y0_4 < 0 || uint(y0_4) + partHeight_2 + uint(5) > height_7) {
        h264bsdFillBlock(ref_5, unsafe(reinterpret<uint8?>(unsafe(addr(p1_0[0])))), x0_4, y0_4, width_8, height_7, partWidth_2 + uint(5), partHeight_2 + uint(5), partWidth_2 + uint(5))
        x0_4 = 0
        x0_4
        y0_4 = 0
        y0_4
        ref_5 = unsafe(reinterpret<uint8?>(unsafe(addr(p1_0[0]))))
        ref_5
        width_8 = uint(partWidth_2 + uint(5))
        width_8
    }
    ref_5 = ref_5 + uint(y0_4) * width_8 + uint(x0_4)
    ref_5
    h1 = unsafe(unsafe(addr(table_0[0])) + tableWidth)
    h1
    ptrC_0 = unsafe(ref_5 + width_8)
    ptrC_0
    ptrV_0 = unsafe(ptrC_0 + uint(5) * width_8)
    ptrV_0
    y_6 = uint(uint(partHeight_2) >> uint(uint(2)))
    y_6
    while (y_6 != 0x0) {
        x_6 = uint(uint(tableWidth))
        x_6
        while (x_6 != 0x0) {
            tmp4_3 = int(unsafe(ptrV_0[-int(width_8) * 2]))
            tmp4_3
            tmp5_1 = int(unsafe(ptrV_0[-int(width_8)]))
            tmp5_1
            tmp1_5 = int(unsafe(ptrV_0[width_8]))
            tmp1_5
            tmp2_5 = int(unsafe(ptrV_0[width_8 * uint(2)]))
            tmp2_5
            ptrV_0 = ptrV_0 + 1
            tmp6_1 = int(*ptrV_0)
            tmp6_1
            tmp7_0 = tmp4_3 + tmp1_5
            tmp7_0
            tmp2_5 = tmp2_5 - tmp7_0 << 2
            tmp2_5
            tmp2_5 = tmp2_5 - tmp7_0
            tmp2_5
            tmp7_0 = tmp5_1 + tmp6_1
            tmp7_0
            tmp3_4 = int(unsafe(ptrC_0[width_8 * uint(2)]))
            tmp3_4
            tmp2_5 = tmp2_5 + tmp7_0 << 4
            tmp2_5
            tmp2_5 = tmp2_5 + tmp7_0 << 2
            tmp2_5
            tmp2_5 = tmp2_5 + tmp3_4
            tmp2_5
            unsafe(h1[tableWidth * 2]) = tmp2_5
            unsafe(h1[tableWidth * 2])
            tmp7_0 = tmp3_4 + tmp6_1
            tmp7_0
            tmp1_5 = tmp1_5 - tmp7_0 << 2
            tmp1_5
            tmp1_5 = tmp1_5 - tmp7_0
            tmp1_5
            tmp7_0 = tmp4_3 + tmp5_1
            tmp7_0
            tmp2_5 = int(unsafe(ptrC_0[width_8]))
            tmp2_5
            tmp1_5 = tmp1_5 + tmp7_0 << 4
            tmp1_5
            tmp1_5 = tmp1_5 + tmp7_0 << 2
            tmp1_5
            tmp1_5 = tmp1_5 + tmp2_5
            tmp1_5
            unsafe(h1[tableWidth]) = tmp1_5
            unsafe(h1[tableWidth])
            tmp1_5 = int(*ptrC_0)
            tmp1_5
            tmp7_0 = tmp2_5 + tmp5_1
            tmp7_0
            tmp6_1 = tmp6_1 - tmp7_0 << 2
            tmp6_1
            tmp6_1 = tmp6_1 - tmp7_0
            tmp6_1
            tmp7_0 = tmp4_3 + tmp3_4
            tmp7_0
            tmp6_1 = tmp6_1 + tmp7_0 << 4
            tmp6_1
            tmp6_1 = tmp6_1 + tmp7_0 << 2
            tmp6_1
            tmp6_1 = tmp6_1 + tmp1_5
            tmp6_1
            *h1 = tmp6_1
            *h1
            tmp6_1 = int(unsafe(ptrC_0[-int(width_8)]))
            tmp6_1
            tmp1_5 = tmp1_5 + tmp4_3
            tmp1_5
            tmp5_1 = tmp5_1 - tmp1_5 << 2
            tmp5_1
            tmp5_1 = tmp5_1 - tmp1_5
            tmp5_1
            tmp3_4 = tmp3_4 + tmp2_5
            tmp3_4
            tmp5_1 = tmp5_1 + tmp3_4 << 4
            tmp5_1
            tmp5_1 = tmp5_1 + tmp3_4 << 2
            tmp5_1
            tmp5_1 = tmp5_1 + tmp6_1
            tmp5_1
            unsafe(h1[-tableWidth]) = tmp5_1
            unsafe(h1[-tableWidth])
            h1 = h1 + 1
            h1
            ptrC_0 = ptrC_0 + 1
            ptrC_0
            x_6 = x_6 - 1
        }
        ptrC_0 = ptrC_0 + uint(4) * width_8 - partWidth_2 - uint(5)
        ptrC_0
        ptrV_0 = ptrV_0 + uint(4) * width_8 - partWidth_2 - uint(5)
        ptrV_0
        h1 = h1 + 3 * tableWidth
        h1
        y_6 = y_6 - 1
    }
    ptrJ_0 = unsafe(unsafe(addr(table_0[0])) + 5)
    ptrJ_0
    ptrInt = unsafe(unsafe(unsafe(addr(table_0[0])) + 2) + horOffset)
    ptrInt
    y_6 = uint(partHeight_2)
    y_6
    while (y_6 != 0x0) {
        tmp6_1 = *unsafe(ptrJ_0 - 5)
        tmp6_1
        tmp5_1 = *unsafe(ptrJ_0 - 4)
        tmp5_1
        tmp4_3 = *unsafe(ptrJ_0 - 3)
        tmp4_3
        tmp3_4 = *unsafe(ptrJ_0 - 2)
        tmp3_4
        tmp2_5 = *unsafe(ptrJ_0 - 1)
        tmp2_5
        x_6 = uint(uint(partWidth_2) >> uint(uint(2)))
        x_6
        while (x_6 != 0x0) {
            tmp6_1 = tmp6_1 + 512
            tmp6_1
            tmp7_0 = tmp3_4 + tmp4_3
            tmp7_0
            tmp6_1 = tmp6_1 + tmp7_0 << 4
            tmp6_1
            tmp6_1 = tmp6_1 + tmp7_0 << 2
            tmp6_1
            tmp7_0 = tmp2_5 + tmp5_1
            tmp7_0
            ptrJ_0 = ptrJ_0 + 1
            tmp1_5 = *ptrJ_0
            tmp1_5
            tmp6_1 = tmp6_1 - tmp7_0 << 2
            tmp6_1
            tmp6_1 = tmp6_1 - tmp7_0
            tmp6_1
            ptrInt = ptrInt + 1
            tmp7_0 = *ptrInt
            tmp7_0
            tmp6_1 = tmp6_1 + tmp1_5
            tmp6_1
            tmp6_1 = int(unsafe(clp_1[tmp6_1 >> 10]))
            tmp6_1
            tmp7_0 = tmp7_0 + 16
            tmp7_0
            tmp7_0 = int(unsafe(clp_1[tmp7_0 >> 5]))
            tmp7_0
            tmp5_1 = tmp5_1 + 512
            tmp5_1
            tmp6_1 = tmp6_1 + 1
            tmp6_1
            mb_0 = mb_0 + 1
            *mb_0 = uint8(uint8(tmp6_1 + tmp7_0 >> 1))
            *mb_0
            tmp7_0 = tmp2_5 + tmp3_4
            tmp7_0
            tmp5_1 = tmp5_1 + tmp7_0 << 4
            tmp5_1
            tmp5_1 = tmp5_1 + tmp7_0 << 2
            tmp5_1
            tmp7_0 = tmp1_5 + tmp4_3
            tmp7_0
            ptrJ_0 = ptrJ_0 + 1
            tmp6_1 = *ptrJ_0
            tmp6_1
            tmp5_1 = tmp5_1 - tmp7_0 << 2
            tmp5_1
            tmp5_1 = tmp5_1 - tmp7_0
            tmp5_1
            ptrInt = ptrInt + 1
            tmp7_0 = *ptrInt
            tmp7_0
            tmp5_1 = tmp5_1 + tmp6_1
            tmp5_1
            tmp5_1 = int(unsafe(clp_1[tmp5_1 >> 10]))
            tmp5_1
            tmp7_0 = tmp7_0 + 16
            tmp7_0
            tmp7_0 = int(unsafe(clp_1[tmp7_0 >> 5]))
            tmp7_0
            tmp4_3 = tmp4_3 + 512
            tmp4_3
            tmp5_1 = tmp5_1 + 1
            tmp5_1
            mb_0 = mb_0 + 1
            *mb_0 = uint8(uint8(tmp5_1 + tmp7_0 >> 1))
            *mb_0
            tmp7_0 = tmp1_5 + tmp2_5
            tmp7_0
            tmp4_3 = tmp4_3 + tmp7_0 << 4
            tmp4_3
            tmp4_3 = tmp4_3 + tmp7_0 << 2
            tmp4_3
            tmp7_0 = tmp6_1 + tmp3_4
            tmp7_0
            ptrJ_0 = ptrJ_0 + 1
            tmp5_1 = *ptrJ_0
            tmp5_1
            tmp4_3 = tmp4_3 - tmp7_0 << 2
            tmp4_3
            tmp4_3 = tmp4_3 - tmp7_0
            tmp4_3
            ptrInt = ptrInt + 1
            tmp7_0 = *ptrInt
            tmp7_0
            tmp4_3 = tmp4_3 + tmp5_1
            tmp4_3
            tmp4_3 = int(unsafe(clp_1[tmp4_3 >> 10]))
            tmp4_3
            tmp7_0 = tmp7_0 + 16
            tmp7_0
            tmp7_0 = int(unsafe(clp_1[tmp7_0 >> 5]))
            tmp7_0
            tmp3_4 = tmp3_4 + 512
            tmp3_4
            tmp4_3 = tmp4_3 + 1
            tmp4_3
            mb_0 = mb_0 + 1
            *mb_0 = uint8(uint8(tmp4_3 + tmp7_0 >> 1))
            *mb_0
            tmp7_0 = tmp6_1 + tmp1_5
            tmp7_0
            tmp3_4 = tmp3_4 + tmp7_0 << 4
            tmp3_4
            tmp3_4 = tmp3_4 + tmp7_0 << 2
            tmp3_4
            tmp7_0 = tmp5_1 + tmp2_5
            tmp7_0
            ptrJ_0 = ptrJ_0 + 1
            tmp4_3 = *ptrJ_0
            tmp4_3
            tmp3_4 = tmp3_4 - tmp7_0 << 2
            tmp3_4
            tmp3_4 = tmp3_4 - tmp7_0
            tmp3_4
            ptrInt = ptrInt + 1
            tmp7_0 = *ptrInt
            tmp7_0
            tmp3_4 = tmp3_4 + tmp4_3
            tmp3_4
            tmp3_4 = int(unsafe(clp_1[tmp3_4 >> 10]))
            tmp3_4
            tmp7_0 = tmp7_0 + 16
            tmp7_0
            tmp7_0 = int(unsafe(clp_1[tmp7_0 >> 5]))
            tmp7_0
            tmp3_4 = tmp3_4 + 1
            tmp3_4
            mb_0 = mb_0 + 1
            *mb_0 = uint8(uint8(tmp3_4 + tmp7_0 >> 1))
            *mb_0
            tmp3_4 = tmp5_1
            tmp3_4
            tmp5_1 = tmp1_5
            tmp5_1
            tmp7_0 = tmp4_3
            tmp7_0
            tmp4_3 = tmp6_1
            tmp4_3
            tmp6_1 = tmp2_5
            tmp6_1
            tmp2_5 = tmp7_0
            tmp2_5
            x_6 = x_6 - 1
        }
        ptrJ_0 = ptrJ_0 + 5
        ptrJ_0
        ptrInt = ptrInt + 5
        ptrInt
        mb_0 = mb_0 + uint(16) - partWidth_2
        mb_0
        y_6 = y_6 - 1
    }
}
[export]
def h264bsdInterpolateHorQuarter(var ref_6 : uint8?; var mb_1 : uint8?; var x0_5 : int; var y0_5 : int; var width_9 : uint; var height_8 : uint; var partWidth_3 : uint; var partHeight_3 : uint; var horOffset_0 : uint) {
    var p1_1 : array<uint> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var ptrJ_1 : uint8?
    var x_7 : uint
    var y_7 : uint
    var tmp1_6 : int
    var tmp2_6 : int
    var tmp3_5 : int
    var tmp4_4 : int
    var tmp5_2 : int
    var tmp6_2 : int
    var tmp7_1 : int
    var clp_2 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (x0_5 < 0 || uint(x0_5) + partWidth_3 + uint(5) > width_9 || y0_5 < 0 || uint(y0_5) + partHeight_3 > height_8) {
        h264bsdFillBlock(ref_6, unsafe(reinterpret<uint8?>(unsafe(addr(p1_1[0])))), x0_5, y0_5, width_9, height_8, partWidth_3 + uint(5), partHeight_3, partWidth_3 + uint(5))
        x0_5 = 0
        x0_5
        y0_5 = 0
        y0_5
        ref_6 = unsafe(reinterpret<uint8?>(unsafe(addr(p1_1[0]))))
        ref_6
        width_9 = uint(partWidth_3 + uint(5))
        width_9
    }
    ref_6 = ref_6 + uint(y0_5) * width_9 + uint(x0_5)
    ref_6
    ptrJ_1 = unsafe(ref_6 + 5)
    ptrJ_1
    y_7 = uint(partHeight_3)
    y_7
    while (y_7 != 0x0) {
        tmp6_2 = int(*unsafe(ptrJ_1 - 5))
        tmp6_2
        tmp5_2 = int(*unsafe(ptrJ_1 - 4))
        tmp5_2
        tmp4_4 = int(*unsafe(ptrJ_1 - 3))
        tmp4_4
        tmp3_5 = int(*unsafe(ptrJ_1 - 2))
        tmp3_5
        tmp2_6 = int(*unsafe(ptrJ_1 - 1))
        tmp2_6
        x_7 = uint(uint(partWidth_3) >> uint(uint(2)))
        x_7
        while (x_7 != 0x0) {
            tmp6_2 = tmp6_2 + 16
            tmp6_2
            tmp7_1 = tmp3_5 + tmp4_4
            tmp7_1
            tmp6_2 = tmp6_2 + tmp7_1 << 4
            tmp6_2
            tmp6_2 = tmp6_2 + tmp7_1 << 2
            tmp6_2
            tmp7_1 = tmp2_6 + tmp5_2
            tmp7_1
            ptrJ_1 = ptrJ_1 + 1
            tmp1_6 = int(*ptrJ_1)
            tmp1_6
            tmp6_2 = tmp6_2 - tmp7_1 << 2
            tmp6_2
            tmp6_2 = tmp6_2 - tmp7_1
            tmp6_2
            tmp6_2 = tmp6_2 + tmp1_6
            tmp6_2
            tmp6_2 = int(unsafe(clp_2[tmp6_2 >> 5]))
            tmp6_2
            tmp5_2 = tmp5_2 + 16
            tmp5_2
            if (horOffset_0 == 0) {
                tmp6_2 = tmp6_2 + tmp4_4
                tmp6_2
            } else {
                tmp6_2 = tmp6_2 + tmp3_5
                tmp6_2
            }
            mb_1 = mb_1 + 1
            *mb_1 = uint8(uint8(tmp6_2 + 1 >> 1))
            *mb_1
            tmp7_1 = tmp2_6 + tmp3_5
            tmp7_1
            tmp5_2 = tmp5_2 + tmp7_1 << 4
            tmp5_2
            tmp5_2 = tmp5_2 + tmp7_1 << 2
            tmp5_2
            tmp7_1 = tmp1_6 + tmp4_4
            tmp7_1
            ptrJ_1 = ptrJ_1 + 1
            tmp6_2 = int(*ptrJ_1)
            tmp6_2
            tmp5_2 = tmp5_2 - tmp7_1 << 2
            tmp5_2
            tmp5_2 = tmp5_2 - tmp7_1
            tmp5_2
            tmp5_2 = tmp5_2 + tmp6_2
            tmp5_2
            tmp5_2 = int(unsafe(clp_2[tmp5_2 >> 5]))
            tmp5_2
            tmp4_4 = tmp4_4 + 16
            tmp4_4
            if (horOffset_0 == 0) {
                tmp5_2 = tmp5_2 + tmp3_5
                tmp5_2
            } else {
                tmp5_2 = tmp5_2 + tmp2_6
                tmp5_2
            }
            mb_1 = mb_1 + 1
            *mb_1 = uint8(uint8(tmp5_2 + 1 >> 1))
            *mb_1
            tmp7_1 = tmp1_6 + tmp2_6
            tmp7_1
            tmp4_4 = tmp4_4 + tmp7_1 << 4
            tmp4_4
            tmp4_4 = tmp4_4 + tmp7_1 << 2
            tmp4_4
            tmp7_1 = tmp6_2 + tmp3_5
            tmp7_1
            ptrJ_1 = ptrJ_1 + 1
            tmp5_2 = int(*ptrJ_1)
            tmp5_2
            tmp4_4 = tmp4_4 - tmp7_1 << 2
            tmp4_4
            tmp4_4 = tmp4_4 - tmp7_1
            tmp4_4
            tmp4_4 = tmp4_4 + tmp5_2
            tmp4_4
            tmp4_4 = int(unsafe(clp_2[tmp4_4 >> 5]))
            tmp4_4
            tmp3_5 = tmp3_5 + 16
            tmp3_5
            if (horOffset_0 == 0) {
                tmp4_4 = tmp4_4 + tmp2_6
                tmp4_4
            } else {
                tmp4_4 = tmp4_4 + tmp1_6
                tmp4_4
            }
            mb_1 = mb_1 + 1
            *mb_1 = uint8(uint8(tmp4_4 + 1 >> 1))
            *mb_1
            tmp7_1 = tmp6_2 + tmp1_6
            tmp7_1
            tmp3_5 = tmp3_5 + tmp7_1 << 4
            tmp3_5
            tmp3_5 = tmp3_5 + tmp7_1 << 2
            tmp3_5
            tmp7_1 = tmp5_2 + tmp2_6
            tmp7_1
            ptrJ_1 = ptrJ_1 + 1
            tmp4_4 = int(*ptrJ_1)
            tmp4_4
            tmp3_5 = tmp3_5 - tmp7_1 << 2
            tmp3_5
            tmp3_5 = tmp3_5 - tmp7_1
            tmp3_5
            tmp3_5 = tmp3_5 + tmp4_4
            tmp3_5
            tmp3_5 = int(unsafe(clp_2[tmp3_5 >> 5]))
            tmp3_5
            if (horOffset_0 == 0) {
                tmp3_5 = tmp3_5 + tmp1_6
                tmp3_5
            } else {
                tmp3_5 = tmp3_5 + tmp6_2
                tmp3_5
            }
            mb_1 = mb_1 + 1
            *mb_1 = uint8(uint8(tmp3_5 + 1 >> 1))
            *mb_1
            tmp3_5 = tmp5_2
            tmp3_5
            tmp5_2 = tmp1_6
            tmp5_2
            tmp7_1 = tmp4_4
            tmp7_1
            tmp4_4 = tmp6_2
            tmp4_4
            tmp6_2 = tmp2_6
            tmp6_2
            tmp2_6 = tmp7_1
            tmp2_6
            x_7 = x_7 - 1
        }
        ptrJ_1 = ptrJ_1 + width_9 - partWidth_3
        ptrJ_1
        mb_1 = mb_1 + uint(16) - partWidth_3
        mb_1
        y_7 = y_7 - 1
    }
}
[export]
def h264bsdInterpolateMidVerQuarter(var ref_7 : uint8?; var mb_2 : uint8?; var x0_6 : int; var y0_6 : int; var width_10 : uint; var height_9 : uint; var partWidth_4 : uint; var partHeight_4 : uint; var verOffset : uint) {
    var p1_2 : array<uint> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var x_8 : uint
    var y_8 : uint
    var tmp1_7 : int
    var tmp2_7 : int
    var tmp3_6 : int
    var tmp4_5 : int
    var tmp5_3 : int
    var tmp6_3 : int
    var tmp7_2 : int
    var ptrC_1 : int?
    var ptrV_1 : int?
    var ptrInt_0 : int?
    var b1 : int?
    var ptrJ_2 : uint8?
    var table_1 : array<int> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var clp_3 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (x0_6 < 0 || uint(x0_6) + partWidth_4 + uint(5) > width_10 || y0_6 < 0 || uint(y0_6) + partHeight_4 + uint(5) > height_9) {
        h264bsdFillBlock(ref_7, unsafe(reinterpret<uint8?>(unsafe(addr(p1_2[0])))), x0_6, y0_6, width_10, height_9, partWidth_4 + uint(5), partHeight_4 + uint(5), partWidth_4 + uint(5))
        x0_6 = 0
        x0_6
        y0_6 = 0
        y0_6
        ref_7 = unsafe(reinterpret<uint8?>(unsafe(addr(p1_2[0]))))
        ref_7
        width_10 = uint(partWidth_4 + uint(5))
        width_10
    }
    ref_7 = ref_7 + uint(y0_6) * width_10 + uint(x0_6)
    ref_7
    b1 = unsafe(addr(table_1[0]))
    b1
    ptrJ_2 = unsafe(ref_7 + 5)
    ptrJ_2
    y_8 = uint(partHeight_4 + uint(5))
    y_8
    while (y_8 != 0x0) {
        tmp6_3 = int(*unsafe(ptrJ_2 - 5))
        tmp6_3
        tmp5_3 = int(*unsafe(ptrJ_2 - 4))
        tmp5_3
        tmp4_5 = int(*unsafe(ptrJ_2 - 3))
        tmp4_5
        tmp3_6 = int(*unsafe(ptrJ_2 - 2))
        tmp3_6
        tmp2_7 = int(*unsafe(ptrJ_2 - 1))
        tmp2_7
        x_8 = uint(uint(partWidth_4) >> uint(uint(2)))
        x_8
        while (x_8 != 0x0) {
            tmp7_2 = tmp3_6 + tmp4_5
            tmp7_2
            tmp6_3 = tmp6_3 + tmp7_2 << 4
            tmp6_3
            tmp6_3 = tmp6_3 + tmp7_2 << 2
            tmp6_3
            tmp7_2 = tmp2_7 + tmp5_3
            tmp7_2
            ptrJ_2 = ptrJ_2 + 1
            tmp1_7 = int(*ptrJ_2)
            tmp1_7
            tmp6_3 = tmp6_3 - tmp7_2 << 2
            tmp6_3
            tmp6_3 = tmp6_3 - tmp7_2
            tmp6_3
            tmp6_3 = tmp6_3 + tmp1_7
            tmp6_3
            b1 = b1 + 1
            *b1 = tmp6_3
            *b1
            tmp7_2 = tmp2_7 + tmp3_6
            tmp7_2
            tmp5_3 = tmp5_3 + tmp7_2 << 4
            tmp5_3
            tmp5_3 = tmp5_3 + tmp7_2 << 2
            tmp5_3
            tmp7_2 = tmp1_7 + tmp4_5
            tmp7_2
            ptrJ_2 = ptrJ_2 + 1
            tmp6_3 = int(*ptrJ_2)
            tmp6_3
            tmp5_3 = tmp5_3 - tmp7_2 << 2
            tmp5_3
            tmp5_3 = tmp5_3 - tmp7_2
            tmp5_3
            tmp5_3 = tmp5_3 + tmp6_3
            tmp5_3
            b1 = b1 + 1
            *b1 = tmp5_3
            *b1
            tmp7_2 = tmp1_7 + tmp2_7
            tmp7_2
            tmp4_5 = tmp4_5 + tmp7_2 << 4
            tmp4_5
            tmp4_5 = tmp4_5 + tmp7_2 << 2
            tmp4_5
            tmp7_2 = tmp6_3 + tmp3_6
            tmp7_2
            ptrJ_2 = ptrJ_2 + 1
            tmp5_3 = int(*ptrJ_2)
            tmp5_3
            tmp4_5 = tmp4_5 - tmp7_2 << 2
            tmp4_5
            tmp4_5 = tmp4_5 - tmp7_2
            tmp4_5
            tmp4_5 = tmp4_5 + tmp5_3
            tmp4_5
            b1 = b1 + 1
            *b1 = tmp4_5
            *b1
            tmp7_2 = tmp6_3 + tmp1_7
            tmp7_2
            tmp3_6 = tmp3_6 + tmp7_2 << 4
            tmp3_6
            tmp3_6 = tmp3_6 + tmp7_2 << 2
            tmp3_6
            tmp7_2 = tmp5_3 + tmp2_7
            tmp7_2
            ptrJ_2 = ptrJ_2 + 1
            tmp4_5 = int(*ptrJ_2)
            tmp4_5
            tmp3_6 = tmp3_6 - tmp7_2 << 2
            tmp3_6
            tmp3_6 = tmp3_6 - tmp7_2
            tmp3_6
            tmp3_6 = tmp3_6 + tmp4_5
            tmp3_6
            b1 = b1 + 1
            *b1 = tmp3_6
            *b1
            tmp7_2 = tmp4_5
            tmp7_2
            tmp4_5 = tmp6_3
            tmp4_5
            tmp6_3 = tmp2_7
            tmp6_3
            tmp2_7 = tmp7_2
            tmp2_7
            tmp3_6 = tmp5_3
            tmp3_6
            tmp5_3 = tmp1_7
            tmp5_3
            x_8 = x_8 - 1
        }
        ptrJ_2 = ptrJ_2 + width_10 - partWidth_4
        ptrJ_2
        y_8 = y_8 - 1
    }
    ptrC_1 = unsafe(unsafe(addr(table_1[0])) + partWidth_4)
    ptrC_1
    ptrV_1 = unsafe(ptrC_1 + uint(5) * partWidth_4)
    ptrV_1
    ptrInt_0 = unsafe(ptrC_1 + uint(2) + verOffset * partWidth_4)
    ptrInt_0
    y_8 = uint(uint(partHeight_4) >> uint(uint(2)))
    y_8
    while (y_8 != 0x0) {
        x_8 = uint(partWidth_4)
        x_8
        while (x_8 != 0x0) {
            tmp4_5 = unsafe(ptrV_1[-int(partWidth_4) * 2])
            tmp4_5
            tmp5_3 = unsafe(ptrV_1[-int(partWidth_4)])
            tmp5_3
            tmp1_7 = unsafe(ptrV_1[partWidth_4])
            tmp1_7
            tmp2_7 = unsafe(ptrV_1[partWidth_4 * uint(2)])
            tmp2_7
            ptrV_1 = ptrV_1 + 1
            tmp6_3 = *ptrV_1
            tmp6_3
            tmp7_2 = tmp4_5 + tmp1_7
            tmp7_2
            tmp2_7 = tmp2_7 - tmp7_2 << 2
            tmp2_7
            tmp2_7 = tmp2_7 - tmp7_2
            tmp2_7
            tmp2_7 = tmp2_7 + 512
            tmp2_7
            tmp7_2 = tmp5_3 + tmp6_3
            tmp7_2
            tmp3_6 = unsafe(ptrC_1[partWidth_4 * uint(2)])
            tmp3_6
            tmp2_7 = tmp2_7 + tmp7_2 << 4
            tmp2_7
            tmp2_7 = tmp2_7 + tmp7_2 << 2
            tmp2_7
            tmp7_2 = unsafe(ptrInt_0[partWidth_4 * uint(2)])
            tmp7_2
            tmp2_7 = tmp2_7 + tmp3_6
            tmp2_7
            tmp2_7 = int(unsafe(clp_3[tmp2_7 >> 10]))
            tmp2_7
            tmp7_2 = tmp7_2 + 16
            tmp7_2
            tmp7_2 = int(unsafe(clp_3[tmp7_2 >> 5]))
            tmp7_2
            tmp1_7 = tmp1_7 + 512
            tmp1_7
            tmp2_7 = tmp2_7 + 1
            tmp2_7
            unsafe(mb_2[48]) = uint8(uint8(tmp7_2 + tmp2_7 >> 1))
            unsafe(mb_2[48])
            tmp7_2 = tmp3_6 + tmp6_3
            tmp7_2
            tmp1_7 = tmp1_7 - tmp7_2 << 2
            tmp1_7
            tmp1_7 = tmp1_7 - tmp7_2
            tmp1_7
            tmp7_2 = tmp4_5 + tmp5_3
            tmp7_2
            tmp2_7 = unsafe(ptrC_1[partWidth_4])
            tmp2_7
            tmp1_7 = tmp1_7 + tmp7_2 << 4
            tmp1_7
            tmp1_7 = tmp1_7 + tmp7_2 << 2
            tmp1_7
            tmp7_2 = unsafe(ptrInt_0[partWidth_4])
            tmp7_2
            tmp1_7 = tmp1_7 + tmp2_7
            tmp1_7
            tmp1_7 = int(unsafe(clp_3[tmp1_7 >> 10]))
            tmp1_7
            tmp7_2 = tmp7_2 + 16
            tmp7_2
            tmp7_2 = int(unsafe(clp_3[tmp7_2 >> 5]))
            tmp7_2
            tmp6_3 = tmp6_3 + 512
            tmp6_3
            tmp1_7 = tmp1_7 + 1
            tmp1_7
            unsafe(mb_2[32]) = uint8(uint8(tmp7_2 + tmp1_7 >> 1))
            unsafe(mb_2[32])
            tmp1_7 = *ptrC_1
            tmp1_7
            tmp7_2 = tmp2_7 + tmp5_3
            tmp7_2
            tmp6_3 = tmp6_3 - tmp7_2 << 2
            tmp6_3
            tmp6_3 = tmp6_3 - tmp7_2
            tmp6_3
            tmp7_2 = tmp4_5 + tmp3_6
            tmp7_2
            tmp6_3 = tmp6_3 + tmp7_2 << 4
            tmp6_3
            tmp6_3 = tmp6_3 + tmp7_2 << 2
            tmp6_3
            tmp7_2 = *ptrInt_0
            tmp7_2
            tmp6_3 = tmp6_3 + tmp1_7
            tmp6_3
            tmp6_3 = int(unsafe(clp_3[tmp6_3 >> 10]))
            tmp6_3
            tmp7_2 = tmp7_2 + 16
            tmp7_2
            tmp7_2 = int(unsafe(clp_3[tmp7_2 >> 5]))
            tmp7_2
            tmp5_3 = tmp5_3 + 512
            tmp5_3
            tmp6_3 = tmp6_3 + 1
            tmp6_3
            unsafe(mb_2[16]) = uint8(uint8(tmp7_2 + tmp6_3 >> 1))
            unsafe(mb_2[16])
            tmp6_3 = unsafe(ptrC_1[-int(partWidth_4)])
            tmp6_3
            tmp1_7 = tmp1_7 + tmp4_5
            tmp1_7
            tmp5_3 = tmp5_3 - tmp1_7 << 2
            tmp5_3
            tmp5_3 = tmp5_3 - tmp1_7
            tmp5_3
            tmp3_6 = tmp3_6 + tmp2_7
            tmp3_6
            tmp5_3 = tmp5_3 + tmp3_6 << 4
            tmp5_3
            tmp5_3 = tmp5_3 + tmp3_6 << 2
            tmp5_3
            tmp7_2 = unsafe(ptrInt_0[-int(partWidth_4)])
            tmp7_2
            tmp5_3 = tmp5_3 + tmp6_3
            tmp5_3
            tmp5_3 = int(unsafe(clp_3[tmp5_3 >> 10]))
            tmp5_3
            tmp7_2 = tmp7_2 + 16
            tmp7_2
            tmp7_2 = int(unsafe(clp_3[tmp7_2 >> 5]))
            tmp7_2
            tmp5_3 = tmp5_3 + 1
            tmp5_3
            mb_2 = mb_2 + 1
            *mb_2 = uint8(uint8(tmp7_2 + tmp5_3 >> 1))
            *mb_2
            ptrC_1 = ptrC_1 + 1
            ptrC_1
            ptrInt_0 = ptrInt_0 + 1
            ptrInt_0
            x_8 = x_8 - 1
        }
        mb_2 = mb_2 + uint(4 * 16) - partWidth_4
        mb_2
        ptrC_1 = ptrC_1 + uint(3) * partWidth_4
        ptrC_1
        ptrV_1 = ptrV_1 + uint(3) * partWidth_4
        ptrV_1
        ptrInt_0 = ptrInt_0 + uint(3) * partWidth_4
        ptrInt_0
        y_8 = y_8 - 1
    }
}
[export]
def h264bsdInterpolateMidHalf(var ref_8 : uint8?; var mb_3 : uint8?; var x0_7 : int; var y0_7 : int; var width_11 : uint; var height_10 : uint; var partWidth_5 : uint; var partHeight_5 : uint) {
    var p1_3 : array<uint> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var x_9 : uint
    var y_9 : uint
    var tmp1_8 : int
    var tmp2_8 : int
    var tmp3_7 : int
    var tmp4_6 : int
    var tmp5_4 : int
    var tmp6_4 : int
    var tmp7_3 : int
    var ptrC_2 : int?
    var ptrV_2 : int?
    var b1_0 : int?
    var ptrJ_3 : uint8?
    var table_2 : array<int> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var clp_4 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (x0_7 < 0 || uint(x0_7) + partWidth_5 + uint(5) > width_11 || y0_7 < 0 || uint(y0_7) + partHeight_5 + uint(5) > height_10) {
        h264bsdFillBlock(ref_8, unsafe(reinterpret<uint8?>(unsafe(addr(p1_3[0])))), x0_7, y0_7, width_11, height_10, partWidth_5 + uint(5), partHeight_5 + uint(5), partWidth_5 + uint(5))
        x0_7 = 0
        x0_7
        y0_7 = 0
        y0_7
        ref_8 = unsafe(reinterpret<uint8?>(unsafe(addr(p1_3[0]))))
        ref_8
        width_11 = uint(partWidth_5 + uint(5))
        width_11
    }
    ref_8 = ref_8 + uint(y0_7) * width_11 + uint(x0_7)
    ref_8
    b1_0 = unsafe(addr(table_2[0]))
    b1_0
    ptrJ_3 = unsafe(ref_8 + 5)
    ptrJ_3
    y_9 = uint(partHeight_5 + uint(5))
    y_9
    while (y_9 != 0x0) {
        tmp6_4 = int(*unsafe(ptrJ_3 - 5))
        tmp6_4
        tmp5_4 = int(*unsafe(ptrJ_3 - 4))
        tmp5_4
        tmp4_6 = int(*unsafe(ptrJ_3 - 3))
        tmp4_6
        tmp3_7 = int(*unsafe(ptrJ_3 - 2))
        tmp3_7
        tmp2_8 = int(*unsafe(ptrJ_3 - 1))
        tmp2_8
        x_9 = uint(uint(partWidth_5) >> uint(uint(2)))
        x_9
        while (x_9 != 0x0) {
            tmp7_3 = tmp3_7 + tmp4_6
            tmp7_3
            tmp6_4 = tmp6_4 + tmp7_3 << 4
            tmp6_4
            tmp6_4 = tmp6_4 + tmp7_3 << 2
            tmp6_4
            tmp7_3 = tmp2_8 + tmp5_4
            tmp7_3
            ptrJ_3 = ptrJ_3 + 1
            tmp1_8 = int(*ptrJ_3)
            tmp1_8
            tmp6_4 = tmp6_4 - tmp7_3 << 2
            tmp6_4
            tmp6_4 = tmp6_4 - tmp7_3
            tmp6_4
            tmp6_4 = tmp6_4 + tmp1_8
            tmp6_4
            b1_0 = b1_0 + 1
            *b1_0 = tmp6_4
            *b1_0
            tmp7_3 = tmp2_8 + tmp3_7
            tmp7_3
            tmp5_4 = tmp5_4 + tmp7_3 << 4
            tmp5_4
            tmp5_4 = tmp5_4 + tmp7_3 << 2
            tmp5_4
            tmp7_3 = tmp1_8 + tmp4_6
            tmp7_3
            ptrJ_3 = ptrJ_3 + 1
            tmp6_4 = int(*ptrJ_3)
            tmp6_4
            tmp5_4 = tmp5_4 - tmp7_3 << 2
            tmp5_4
            tmp5_4 = tmp5_4 - tmp7_3
            tmp5_4
            tmp5_4 = tmp5_4 + tmp6_4
            tmp5_4
            b1_0 = b1_0 + 1
            *b1_0 = tmp5_4
            *b1_0
            tmp7_3 = tmp1_8 + tmp2_8
            tmp7_3
            tmp4_6 = tmp4_6 + tmp7_3 << 4
            tmp4_6
            tmp4_6 = tmp4_6 + tmp7_3 << 2
            tmp4_6
            tmp7_3 = tmp6_4 + tmp3_7
            tmp7_3
            ptrJ_3 = ptrJ_3 + 1
            tmp5_4 = int(*ptrJ_3)
            tmp5_4
            tmp4_6 = tmp4_6 - tmp7_3 << 2
            tmp4_6
            tmp4_6 = tmp4_6 - tmp7_3
            tmp4_6
            tmp4_6 = tmp4_6 + tmp5_4
            tmp4_6
            b1_0 = b1_0 + 1
            *b1_0 = tmp4_6
            *b1_0
            tmp7_3 = tmp6_4 + tmp1_8
            tmp7_3
            tmp3_7 = tmp3_7 + tmp7_3 << 4
            tmp3_7
            tmp3_7 = tmp3_7 + tmp7_3 << 2
            tmp3_7
            tmp7_3 = tmp5_4 + tmp2_8
            tmp7_3
            ptrJ_3 = ptrJ_3 + 1
            tmp4_6 = int(*ptrJ_3)
            tmp4_6
            tmp3_7 = tmp3_7 - tmp7_3 << 2
            tmp3_7
            tmp3_7 = tmp3_7 - tmp7_3
            tmp3_7
            tmp3_7 = tmp3_7 + tmp4_6
            tmp3_7
            b1_0 = b1_0 + 1
            *b1_0 = tmp3_7
            *b1_0
            tmp7_3 = tmp4_6
            tmp7_3
            tmp4_6 = tmp6_4
            tmp4_6
            tmp6_4 = tmp2_8
            tmp6_4
            tmp2_8 = tmp7_3
            tmp2_8
            tmp3_7 = tmp5_4
            tmp3_7
            tmp5_4 = tmp1_8
            tmp5_4
            x_9 = x_9 - 1
        }
        ptrJ_3 = ptrJ_3 + width_11 - partWidth_5
        ptrJ_3
        y_9 = y_9 - 1
    }
    ptrC_2 = unsafe(unsafe(addr(table_2[0])) + partWidth_5)
    ptrC_2
    ptrV_2 = unsafe(ptrC_2 + uint(5) * partWidth_5)
    ptrV_2
    y_9 = uint(uint(partHeight_5) >> uint(uint(2)))
    y_9
    while (y_9 != 0x0) {
        x_9 = uint(partWidth_5)
        x_9
        while (x_9 != 0x0) {
            tmp4_6 = unsafe(ptrV_2[-int(partWidth_5) * 2])
            tmp4_6
            tmp5_4 = unsafe(ptrV_2[-int(partWidth_5)])
            tmp5_4
            tmp1_8 = unsafe(ptrV_2[partWidth_5])
            tmp1_8
            tmp2_8 = unsafe(ptrV_2[partWidth_5 * uint(2)])
            tmp2_8
            ptrV_2 = ptrV_2 + 1
            tmp6_4 = *ptrV_2
            tmp6_4
            tmp7_3 = tmp4_6 + tmp1_8
            tmp7_3
            tmp2_8 = tmp2_8 - tmp7_3 << 2
            tmp2_8
            tmp2_8 = tmp2_8 - tmp7_3
            tmp2_8
            tmp2_8 = tmp2_8 + 512
            tmp2_8
            tmp7_3 = tmp5_4 + tmp6_4
            tmp7_3
            tmp3_7 = unsafe(ptrC_2[partWidth_5 * uint(2)])
            tmp3_7
            tmp2_8 = tmp2_8 + tmp7_3 << 4
            tmp2_8
            tmp2_8 = tmp2_8 + tmp7_3 << 2
            tmp2_8
            tmp2_8 = tmp2_8 + tmp3_7
            tmp2_8
            tmp7_3 = int(unsafe(clp_4[tmp2_8 >> 10]))
            tmp7_3
            tmp1_8 = tmp1_8 + 512
            tmp1_8
            unsafe(mb_3[48]) = uint8(uint8(tmp7_3))
            unsafe(mb_3[48])
            tmp7_3 = tmp3_7 + tmp6_4
            tmp7_3
            tmp1_8 = tmp1_8 - tmp7_3 << 2
            tmp1_8
            tmp1_8 = tmp1_8 - tmp7_3
            tmp1_8
            tmp7_3 = tmp4_6 + tmp5_4
            tmp7_3
            tmp2_8 = unsafe(ptrC_2[partWidth_5])
            tmp2_8
            tmp1_8 = tmp1_8 + tmp7_3 << 4
            tmp1_8
            tmp1_8 = tmp1_8 + tmp7_3 << 2
            tmp1_8
            tmp1_8 = tmp1_8 + tmp2_8
            tmp1_8
            tmp7_3 = int(unsafe(clp_4[tmp1_8 >> 10]))
            tmp7_3
            tmp6_4 = tmp6_4 + 512
            tmp6_4
            unsafe(mb_3[32]) = uint8(uint8(tmp7_3))
            unsafe(mb_3[32])
            tmp1_8 = *ptrC_2
            tmp1_8
            tmp7_3 = tmp2_8 + tmp5_4
            tmp7_3
            tmp6_4 = tmp6_4 - tmp7_3 << 2
            tmp6_4
            tmp6_4 = tmp6_4 - tmp7_3
            tmp6_4
            tmp7_3 = tmp4_6 + tmp3_7
            tmp7_3
            tmp6_4 = tmp6_4 + tmp7_3 << 4
            tmp6_4
            tmp6_4 = tmp6_4 + tmp7_3 << 2
            tmp6_4
            tmp6_4 = tmp6_4 + tmp1_8
            tmp6_4
            tmp7_3 = int(unsafe(clp_4[tmp6_4 >> 10]))
            tmp7_3
            tmp5_4 = tmp5_4 + 512
            tmp5_4
            unsafe(mb_3[16]) = uint8(uint8(tmp7_3))
            unsafe(mb_3[16])
            tmp6_4 = unsafe(ptrC_2[-int(partWidth_5)])
            tmp6_4
            tmp1_8 = tmp1_8 + tmp4_6
            tmp1_8
            tmp5_4 = tmp5_4 - tmp1_8 << 2
            tmp5_4
            tmp5_4 = tmp5_4 - tmp1_8
            tmp5_4
            tmp3_7 = tmp3_7 + tmp2_8
            tmp3_7
            tmp5_4 = tmp5_4 + tmp3_7 << 4
            tmp5_4
            tmp5_4 = tmp5_4 + tmp3_7 << 2
            tmp5_4
            tmp5_4 = tmp5_4 + tmp6_4
            tmp5_4
            tmp7_3 = int(unsafe(clp_4[tmp5_4 >> 10]))
            tmp7_3
            mb_3 = mb_3 + 1
            *mb_3 = uint8(uint8(tmp7_3))
            *mb_3
            ptrC_2 = ptrC_2 + 1
            ptrC_2
            x_9 = x_9 - 1
        }
        mb_3 = mb_3 + uint(4 * 16) - partWidth_5
        mb_3
        ptrC_2 = ptrC_2 + uint(3) * partWidth_5
        ptrC_2
        ptrV_2 = ptrV_2 + uint(3) * partWidth_5
        ptrV_2
        y_9 = y_9 - 1
    }
}
[export]
def h264bsdInterpolateHorHalf(var ref_9 : uint8?; var mb_4 : uint8?; var x0_8 : int; var y0_8 : int; var width_12 : uint; var height_11 : uint; var partWidth_6 : uint; var partHeight_6 : uint) {
    var p1_4 : array<uint> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var ptrJ_4 : uint8?
    var x_10 : uint
    var y_10 : uint
    var tmp1_9 : int
    var tmp2_9 : int
    var tmp3_8 : int
    var tmp4_7 : int
    var tmp5_5 : int
    var tmp6_5 : int
    var tmp7_4 : int
    var clp_5 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (x0_8 < 0 || uint(x0_8) + partWidth_6 + uint(5) > width_12 || y0_8 < 0 || uint(y0_8) + partHeight_6 > height_11) {
        h264bsdFillBlock(ref_9, unsafe(reinterpret<uint8?>(unsafe(addr(p1_4[0])))), x0_8, y0_8, width_12, height_11, partWidth_6 + uint(5), partHeight_6, partWidth_6 + uint(5))
        x0_8 = 0
        x0_8
        y0_8 = 0
        y0_8
        ref_9 = unsafe(reinterpret<uint8?>(unsafe(addr(p1_4[0]))))
        ref_9
        width_12 = uint(partWidth_6 + uint(5))
        width_12
    }
    ref_9 = ref_9 + uint(y0_8) * width_12 + uint(x0_8)
    ref_9
    ptrJ_4 = unsafe(ref_9 + 5)
    ptrJ_4
    y_10 = uint(partHeight_6)
    y_10
    while (y_10 != 0x0) {
        tmp6_5 = int(*unsafe(ptrJ_4 - 5))
        tmp6_5
        tmp5_5 = int(*unsafe(ptrJ_4 - 4))
        tmp5_5
        tmp4_7 = int(*unsafe(ptrJ_4 - 3))
        tmp4_7
        tmp3_8 = int(*unsafe(ptrJ_4 - 2))
        tmp3_8
        tmp2_9 = int(*unsafe(ptrJ_4 - 1))
        tmp2_9
        x_10 = uint(uint(partWidth_6) >> uint(uint(2)))
        x_10
        while (x_10 != 0x0) {
            tmp6_5 = tmp6_5 + 16
            tmp6_5
            tmp7_4 = tmp3_8 + tmp4_7
            tmp7_4
            tmp6_5 = tmp6_5 + tmp7_4 << 4
            tmp6_5
            tmp6_5 = tmp6_5 + tmp7_4 << 2
            tmp6_5
            tmp7_4 = tmp2_9 + tmp5_5
            tmp7_4
            ptrJ_4 = ptrJ_4 + 1
            tmp1_9 = int(*ptrJ_4)
            tmp1_9
            tmp6_5 = tmp6_5 - tmp7_4 << 2
            tmp6_5
            tmp6_5 = tmp6_5 - tmp7_4
            tmp6_5
            tmp6_5 = tmp6_5 + tmp1_9
            tmp6_5
            tmp6_5 = int(unsafe(clp_5[tmp6_5 >> 5]))
            tmp6_5
            tmp5_5 = tmp5_5 + 16
            tmp5_5
            tmp7_4 = tmp2_9 + tmp3_8
            tmp7_4
            mb_4 = mb_4 + 1
            *mb_4 = uint8(uint8(tmp6_5))
            *mb_4
            tmp5_5 = tmp5_5 + tmp7_4 << 4
            tmp5_5
            tmp5_5 = tmp5_5 + tmp7_4 << 2
            tmp5_5
            tmp7_4 = tmp1_9 + tmp4_7
            tmp7_4
            ptrJ_4 = ptrJ_4 + 1
            tmp6_5 = int(*ptrJ_4)
            tmp6_5
            tmp5_5 = tmp5_5 - tmp7_4 << 2
            tmp5_5
            tmp5_5 = tmp5_5 - tmp7_4
            tmp5_5
            tmp5_5 = tmp5_5 + tmp6_5
            tmp5_5
            tmp5_5 = int(unsafe(clp_5[tmp5_5 >> 5]))
            tmp5_5
            tmp4_7 = tmp4_7 + 16
            tmp4_7
            tmp7_4 = tmp1_9 + tmp2_9
            tmp7_4
            mb_4 = mb_4 + 1
            *mb_4 = uint8(uint8(tmp5_5))
            *mb_4
            tmp4_7 = tmp4_7 + tmp7_4 << 4
            tmp4_7
            tmp4_7 = tmp4_7 + tmp7_4 << 2
            tmp4_7
            tmp7_4 = tmp6_5 + tmp3_8
            tmp7_4
            ptrJ_4 = ptrJ_4 + 1
            tmp5_5 = int(*ptrJ_4)
            tmp5_5
            tmp4_7 = tmp4_7 - tmp7_4 << 2
            tmp4_7
            tmp4_7 = tmp4_7 - tmp7_4
            tmp4_7
            tmp4_7 = tmp4_7 + tmp5_5
            tmp4_7
            tmp4_7 = int(unsafe(clp_5[tmp4_7 >> 5]))
            tmp4_7
            tmp3_8 = tmp3_8 + 16
            tmp3_8
            tmp7_4 = tmp6_5 + tmp1_9
            tmp7_4
            mb_4 = mb_4 + 1
            *mb_4 = uint8(uint8(tmp4_7))
            *mb_4
            tmp3_8 = tmp3_8 + tmp7_4 << 4
            tmp3_8
            tmp3_8 = tmp3_8 + tmp7_4 << 2
            tmp3_8
            tmp7_4 = tmp5_5 + tmp2_9
            tmp7_4
            ptrJ_4 = ptrJ_4 + 1
            tmp4_7 = int(*ptrJ_4)
            tmp4_7
            tmp3_8 = tmp3_8 - tmp7_4 << 2
            tmp3_8
            tmp3_8 = tmp3_8 - tmp7_4
            tmp3_8
            tmp3_8 = tmp3_8 + tmp4_7
            tmp3_8
            tmp3_8 = int(unsafe(clp_5[tmp3_8 >> 5]))
            tmp3_8
            tmp7_4 = tmp4_7
            tmp7_4
            tmp4_7 = tmp6_5
            tmp4_7
            tmp6_5 = tmp2_9
            tmp6_5
            tmp2_9 = tmp7_4
            tmp2_9
            mb_4 = mb_4 + 1
            *mb_4 = uint8(uint8(tmp3_8))
            *mb_4
            tmp3_8 = tmp5_5
            tmp3_8
            tmp5_5 = tmp1_9
            tmp5_5
            x_10 = x_10 - 1
        }
        ptrJ_4 = ptrJ_4 + width_12 - partWidth_6
        ptrJ_4
        mb_4 = mb_4 + uint(16) - partWidth_6
        mb_4
        y_10 = y_10 - 1
    }
}
[export]
def h264bsdInterpolateVerQuarter(var ref_10 : uint8?; var mb_5 : uint8?; var x0_9 : int; var y0_9 : int; var width_13 : uint; var height_12 : uint; var partWidth_7 : uint; var partHeight_7 : uint; var verOffset_0 : uint) {
    var p1_5 : array<uint> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var i_39 : uint
    var j_4 : uint
    var tmp1_10 : int
    var tmp2_10 : int
    var tmp3_9 : int
    var tmp4_8 : int
    var tmp5_6 : int
    var tmp6_6 : int
    var tmp7_5 : int
    var ptrC_3 : uint8?
    var ptrV_3 : uint8?
    var ptrInt_1 : uint8?
    var clp_6 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (x0_9 < 0 || uint(x0_9) + partWidth_7 > width_13 || y0_9 < 0 || uint(y0_9) + partHeight_7 + uint(5) > height_12) {
        h264bsdFillBlock(ref_10, unsafe(reinterpret<uint8?>(unsafe(addr(p1_5[0])))), x0_9, y0_9, width_13, height_12, partWidth_7, partHeight_7 + uint(5), partWidth_7)
        x0_9 = 0
        x0_9
        y0_9 = 0
        y0_9
        ref_10 = unsafe(reinterpret<uint8?>(unsafe(addr(p1_5[0]))))
        ref_10
        width_13 = uint(partWidth_7)
        width_13
    }
    ref_10 = ref_10 + uint(y0_9) * width_13 + uint(x0_9)
    ref_10
    ptrC_3 = unsafe(ref_10 + width_13)
    ptrC_3
    ptrV_3 = unsafe(ptrC_3 + uint(5) * width_13)
    ptrV_3
    ptrInt_1 = unsafe(ptrC_3 + uint(2) + verOffset_0 * width_13)
    ptrInt_1
    i_39 = uint(uint(partHeight_7) >> uint(uint(2)))
    i_39
    while (i_39 != 0x0) {
        j_4 = uint(partWidth_7)
        j_4
        while (j_4 != 0x0) {
            tmp4_8 = int(unsafe(ptrV_3[-int(width_13) * 2]))
            tmp4_8
            tmp5_6 = int(unsafe(ptrV_3[-int(width_13)]))
            tmp5_6
            tmp1_10 = int(unsafe(ptrV_3[width_13]))
            tmp1_10
            tmp2_10 = int(unsafe(ptrV_3[width_13 * uint(2)]))
            tmp2_10
            ptrV_3 = ptrV_3 + 1
            tmp6_6 = int(*ptrV_3)
            tmp6_6
            tmp7_5 = tmp4_8 + tmp1_10
            tmp7_5
            tmp2_10 = tmp2_10 - tmp7_5 << 2
            tmp2_10
            tmp2_10 = tmp2_10 - tmp7_5
            tmp2_10
            tmp2_10 = tmp2_10 + 16
            tmp2_10
            tmp7_5 = tmp5_6 + tmp6_6
            tmp7_5
            tmp3_9 = int(unsafe(ptrC_3[width_13 * uint(2)]))
            tmp3_9
            tmp2_10 = tmp2_10 + tmp7_5 << 4
            tmp2_10
            tmp2_10 = tmp2_10 + tmp7_5 << 2
            tmp2_10
            tmp2_10 = tmp2_10 + tmp3_9
            tmp2_10
            tmp2_10 = int(unsafe(clp_6[tmp2_10 >> 5]))
            tmp2_10
            tmp7_5 = int(unsafe(ptrInt_1[width_13 * uint(2)]))
            tmp7_5
            tmp1_10 = tmp1_10 + 16
            tmp1_10
            tmp2_10 = tmp2_10 + 1
            tmp2_10
            unsafe(mb_5[48]) = uint8(uint8(tmp2_10 + tmp7_5 >> 1))
            unsafe(mb_5[48])
            tmp7_5 = tmp3_9 + tmp6_6
            tmp7_5
            tmp1_10 = tmp1_10 - tmp7_5 << 2
            tmp1_10
            tmp1_10 = tmp1_10 - tmp7_5
            tmp1_10
            tmp7_5 = tmp4_8 + tmp5_6
            tmp7_5
            tmp2_10 = int(unsafe(ptrC_3[width_13]))
            tmp2_10
            tmp1_10 = tmp1_10 + tmp7_5 << 4
            tmp1_10
            tmp1_10 = tmp1_10 + tmp7_5 << 2
            tmp1_10
            tmp1_10 = tmp1_10 + tmp2_10
            tmp1_10
            tmp1_10 = int(unsafe(clp_6[tmp1_10 >> 5]))
            tmp1_10
            tmp7_5 = int(unsafe(ptrInt_1[width_13]))
            tmp7_5
            tmp6_6 = tmp6_6 + 16
            tmp6_6
            tmp1_10 = tmp1_10 + 1
            tmp1_10
            unsafe(mb_5[32]) = uint8(uint8(tmp1_10 + tmp7_5 >> 1))
            unsafe(mb_5[32])
            tmp7_5 = tmp2_10 + tmp5_6
            tmp7_5
            tmp6_6 = tmp6_6 - tmp7_5 << 2
            tmp6_6
            tmp6_6 = tmp6_6 - tmp7_5
            tmp6_6
            tmp7_5 = tmp4_8 + tmp3_9
            tmp7_5
            tmp1_10 = int(*ptrC_3)
            tmp1_10
            tmp6_6 = tmp6_6 + tmp7_5 << 4
            tmp6_6
            tmp6_6 = tmp6_6 + tmp7_5 << 2
            tmp6_6
            tmp6_6 = tmp6_6 + tmp1_10
            tmp6_6
            tmp6_6 = int(unsafe(clp_6[tmp6_6 >> 5]))
            tmp6_6
            tmp7_5 = int(*ptrInt_1)
            tmp7_5
            tmp5_6 = tmp5_6 + 16
            tmp5_6
            tmp6_6 = tmp6_6 + 1
            tmp6_6
            unsafe(mb_5[16]) = uint8(uint8(tmp6_6 + tmp7_5 >> 1))
            unsafe(mb_5[16])
            tmp1_10 = tmp1_10 + tmp4_8
            tmp1_10
            tmp5_6 = tmp5_6 - tmp1_10 << 2
            tmp5_6
            tmp5_6 = tmp5_6 - tmp1_10
            tmp5_6
            tmp3_9 = tmp3_9 + tmp2_10
            tmp3_9
            tmp6_6 = int(unsafe(ptrC_3[-int(width_13)]))
            tmp6_6
            tmp5_6 = tmp5_6 + tmp3_9 << 4
            tmp5_6
            tmp5_6 = tmp5_6 + tmp3_9 << 2
            tmp5_6
            tmp5_6 = tmp5_6 + tmp6_6
            tmp5_6
            tmp5_6 = int(unsafe(clp_6[tmp5_6 >> 5]))
            tmp5_6
            tmp7_5 = int(unsafe(ptrInt_1[-int(width_13)]))
            tmp7_5
            tmp5_6 = tmp5_6 + 1
            tmp5_6
            mb_5 = mb_5 + 1
            *mb_5 = uint8(uint8(tmp5_6 + tmp7_5 >> 1))
            *mb_5
            ptrC_3 = ptrC_3 + 1
            ptrC_3
            ptrInt_1 = ptrInt_1 + 1
            ptrInt_1
            j_4 = j_4 - 1
        }
        ptrC_3 = ptrC_3 + uint(4) * width_13 - partWidth_7
        ptrC_3
        ptrV_3 = ptrV_3 + uint(4) * width_13 - partWidth_7
        ptrV_3
        ptrInt_1 = ptrInt_1 + uint(4) * width_13 - partWidth_7
        ptrInt_1
        mb_5 = mb_5 + uint(4 * 16) - partWidth_7
        mb_5
        i_39 = i_39 - 1
    }
}
[export]
def h264bsdInterpolateVerHalf(var ref_11 : uint8?; var mb_6 : uint8?; var x0_10 : int; var y0_10 : int; var width_14 : uint; var height_13 : uint; var partWidth_8 : uint; var partHeight_8 : uint) {
    var p1_6 : array<uint> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var i_40 : uint
    var j_5 : uint
    var tmp1_11 : int
    var tmp2_11 : int
    var tmp3_10 : int
    var tmp4_9 : int
    var tmp5_7 : int
    var tmp6_7 : int
    var tmp7_6 : int
    var ptrC_4 : uint8?
    var ptrV_4 : uint8?
    var clp_7 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (x0_10 < 0 || uint(x0_10) + partWidth_8 > width_14 || y0_10 < 0 || uint(y0_10) + partHeight_8 + uint(5) > height_13) {
        h264bsdFillBlock(ref_11, unsafe(reinterpret<uint8?>(unsafe(addr(p1_6[0])))), x0_10, y0_10, width_14, height_13, partWidth_8, partHeight_8 + uint(5), partWidth_8)
        x0_10 = 0
        x0_10
        y0_10 = 0
        y0_10
        ref_11 = unsafe(reinterpret<uint8?>(unsafe(addr(p1_6[0]))))
        ref_11
        width_14 = uint(partWidth_8)
        width_14
    }
    ref_11 = ref_11 + uint(y0_10) * width_14 + uint(x0_10)
    ref_11
    ptrC_4 = unsafe(ref_11 + width_14)
    ptrC_4
    ptrV_4 = unsafe(ptrC_4 + uint(5) * width_14)
    ptrV_4
    i_40 = uint(uint(partHeight_8) >> uint(uint(2)))
    i_40
    while (i_40 != 0x0) {
        j_5 = uint(partWidth_8)
        j_5
        while (j_5 != 0x0) {
            tmp4_9 = int(unsafe(ptrV_4[-int(width_14) * 2]))
            tmp4_9
            tmp5_7 = int(unsafe(ptrV_4[-int(width_14)]))
            tmp5_7
            tmp1_11 = int(unsafe(ptrV_4[width_14]))
            tmp1_11
            tmp2_11 = int(unsafe(ptrV_4[width_14 * uint(2)]))
            tmp2_11
            ptrV_4 = ptrV_4 + 1
            tmp6_7 = int(*ptrV_4)
            tmp6_7
            tmp7_6 = tmp4_9 + tmp1_11
            tmp7_6
            tmp2_11 = tmp2_11 - tmp7_6 << 2
            tmp2_11
            tmp2_11 = tmp2_11 - tmp7_6
            tmp2_11
            tmp2_11 = tmp2_11 + 16
            tmp2_11
            tmp7_6 = tmp5_7 + tmp6_7
            tmp7_6
            tmp3_10 = int(unsafe(ptrC_4[width_14 * uint(2)]))
            tmp3_10
            tmp2_11 = tmp2_11 + tmp7_6 << 4
            tmp2_11
            tmp2_11 = tmp2_11 + tmp7_6 << 2
            tmp2_11
            tmp2_11 = tmp2_11 + tmp3_10
            tmp2_11
            tmp2_11 = int(unsafe(clp_7[tmp2_11 >> 5]))
            tmp2_11
            tmp1_11 = tmp1_11 + 16
            tmp1_11
            unsafe(mb_6[48]) = uint8(uint8(tmp2_11))
            unsafe(mb_6[48])
            tmp7_6 = tmp3_10 + tmp6_7
            tmp7_6
            tmp1_11 = tmp1_11 - tmp7_6 << 2
            tmp1_11
            tmp1_11 = tmp1_11 - tmp7_6
            tmp1_11
            tmp7_6 = tmp4_9 + tmp5_7
            tmp7_6
            tmp2_11 = int(unsafe(ptrC_4[width_14]))
            tmp2_11
            tmp1_11 = tmp1_11 + tmp7_6 << 4
            tmp1_11
            tmp1_11 = tmp1_11 + tmp7_6 << 2
            tmp1_11
            tmp1_11 = tmp1_11 + tmp2_11
            tmp1_11
            tmp1_11 = int(unsafe(clp_7[tmp1_11 >> 5]))
            tmp1_11
            tmp6_7 = tmp6_7 + 16
            tmp6_7
            unsafe(mb_6[32]) = uint8(uint8(tmp1_11))
            unsafe(mb_6[32])
            tmp7_6 = tmp2_11 + tmp5_7
            tmp7_6
            tmp6_7 = tmp6_7 - tmp7_6 << 2
            tmp6_7
            tmp6_7 = tmp6_7 - tmp7_6
            tmp6_7
            tmp7_6 = tmp4_9 + tmp3_10
            tmp7_6
            tmp1_11 = int(*ptrC_4)
            tmp1_11
            tmp6_7 = tmp6_7 + tmp7_6 << 4
            tmp6_7
            tmp6_7 = tmp6_7 + tmp7_6 << 2
            tmp6_7
            tmp6_7 = tmp6_7 + tmp1_11
            tmp6_7
            tmp6_7 = int(unsafe(clp_7[tmp6_7 >> 5]))
            tmp6_7
            tmp5_7 = tmp5_7 + 16
            tmp5_7
            unsafe(mb_6[16]) = uint8(uint8(tmp6_7))
            unsafe(mb_6[16])
            tmp1_11 = tmp1_11 + tmp4_9
            tmp1_11
            tmp5_7 = tmp5_7 - tmp1_11 << 2
            tmp5_7
            tmp5_7 = tmp5_7 - tmp1_11
            tmp5_7
            tmp3_10 = tmp3_10 + tmp2_11
            tmp3_10
            tmp6_7 = int(unsafe(ptrC_4[-int(width_14)]))
            tmp6_7
            tmp5_7 = tmp5_7 + tmp3_10 << 4
            tmp5_7
            tmp5_7 = tmp5_7 + tmp3_10 << 2
            tmp5_7
            tmp5_7 = tmp5_7 + tmp6_7
            tmp5_7
            tmp5_7 = int(unsafe(clp_7[tmp5_7 >> 5]))
            tmp5_7
            mb_6 = mb_6 + 1
            *mb_6 = uint8(uint8(tmp5_7))
            *mb_6
            ptrC_4 = ptrC_4 + 1
            ptrC_4
            j_5 = j_5 - 1
        }
        ptrC_4 = ptrC_4 + uint(4) * width_14 - partWidth_8
        ptrC_4
        ptrV_4 = ptrV_4 + uint(4) * width_14 - partWidth_8
        ptrV_4
        mb_6 = mb_6 + uint(4 * 16) - partWidth_8
        mb_6
        i_40 = i_40 - 1
    }
}
var lumaFracPos : array<array<uint>> const = [[uint(0), uint(1), uint(2), uint(3)], [uint(4), uint(5), uint(6), uint(7)], [uint(8), uint(9), uint(10), uint(11)], [uint(12), uint(13), uint(14), uint(15)]]

[export]
def MvPrediction8x8(var pMb_5 : mbStorage_t?; var subMbPred : subMbPred_t?; var dpb_23 : dpbStorage_t?) : uint {
    var i_41 : uint
    var j_6 : uint
    var numSubMbPart : uint
    i_41 = uint(uint(0))
    i_41
    while (i_41 < uint(4)) {
        numSubMbPart = uint(h264bsdNumSubMbPart(unsafe(unsafe(addr(subMbPred.subMbType[0]))[i_41])))
        numSubMbPart
        unsafe(unsafe(addr(pMb_5.refPic[0]))[i_41]) = uint(unsafe(unsafe(addr(subMbPred.refIdxL0[0]))[i_41]))
        unsafe(unsafe(addr(pMb_5.refPic[0]))[i_41])
        unsafe(unsafe(addr(pMb_5.refAddr[0]))[i_41]) = h264bsdGetRefPicData(dpb_23, unsafe(unsafe(addr(subMbPred.refIdxL0[0]))[i_41]))
        unsafe(unsafe(addr(pMb_5.refAddr[0]))[i_41])
        if (unsafe(unsafe(addr(pMb_5.refAddr[0]))[i_41]) == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
            return uint(1)
        }
        j_6 = uint(uint(0))
        j_6
        while (j_6 < numSubMbPart) {
            if (MvPrediction(pMb_5, subMbPred, i_41, j_6) != uint(0)) {
                return uint(1)
            }
            j_6 = j_6 + 1
        }
        i_41 = i_41 + 1
    }
    return uint(0)
}
[export]
def MvPrediction(var pMb_6 : mbStorage_t?; var subMbPred_0 : subMbPred_t?; var mbPartIdx : uint; var subMbPartIdx : uint) : uint {
    var mv_1 : mv_t
    var mvPred : mv_t
    var refIndex : uint
    var subMbPartMode : subMbPartMode_e
    var n_0 : neighbour_t const?
    var nMb : mbStorage_t?
    var a : array<interNeighbour_t> = [0, 0, 0]
    mv_1 = unsafe(unsafe(addr(unsafe(unsafe(addr(subMbPred_0.mvdL0[0]))[mbPartIdx])[0]))[subMbPartIdx])
    mv_1
    subMbPartMode = h264bsdSubMbPartMode(unsafe(unsafe(addr(subMbPred_0.subMbType[0]))[mbPartIdx]))
    subMbPartMode
    refIndex = uint(unsafe(unsafe(addr(subMbPred_0.refIdxL0[0]))[mbPartIdx]))
    refIndex
    n_0 = unsafe(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(N_A_SUB_PART[0]))[mbPartIdx])[0]))[subMbPartMode])[0])) + subMbPartIdx)
    n_0
    nMb = h264bsdGetNeighbourMb(pMb_6, n_0.mb)
    nMb
    GetInterNeighbour(pMb_6.sliceId, nMb, unsafe(addr(a[0])), uint(n_0.index))
    n_0 = unsafe(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(N_B_SUB_PART[0]))[mbPartIdx])[0]))[subMbPartMode])[0])) + subMbPartIdx)
    n_0
    nMb = h264bsdGetNeighbourMb(pMb_6, n_0.mb)
    nMb
    GetInterNeighbour(pMb_6.sliceId, nMb, unsafe(unsafe(addr(a[0])) + 1), uint(n_0.index))
    n_0 = unsafe(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(N_C_SUB_PART[0]))[mbPartIdx])[0]))[subMbPartMode])[0])) + subMbPartIdx)
    n_0
    nMb = h264bsdGetNeighbourMb(pMb_6, n_0.mb)
    nMb
    GetInterNeighbour(pMb_6.sliceId, nMb, unsafe(unsafe(addr(a[0])) + 2), uint(n_0.index))
    if (unsafe(unsafe(addr(a[0]))[2]).available == 0) {
        n_0 = unsafe(unsafe(addr(unsafe(unsafe(addr(unsafe(unsafe(addr(N_D_SUB_PART[0]))[mbPartIdx])[0]))[subMbPartMode])[0])) + subMbPartIdx)
        n_0
        nMb = h264bsdGetNeighbourMb(pMb_6, n_0.mb)
        nMb
        GetInterNeighbour(pMb_6.sliceId, nMb, unsafe(unsafe(addr(a[0])) + 2), uint(n_0.index))
    }
    GetPredictionMv(unsafe(addr(mvPred)), unsafe(addr(a[0])), refIndex)
    mv_1.hor = mv_1.hor + mvPred.hor
    mv_1.hor
    mv_1.ver = mv_1.ver + mvPred.ver
    mv_1.ver
    if (uint(int(mv_1.hor + 8192)) >= uint(16384)) {
        return uint(1)
    }
    if (uint(int(mv_1.ver + 2048)) >= uint(4096)) {
        return uint(1)
    }
    if (uint(subMbPartMode) == uint(MB_SP_8x8)) {
        unsafe(unsafe(addr(pMb_6.mv[0]))[uint(4) * mbPartIdx]) = mv_1
        unsafe(unsafe(addr(pMb_6.mv[0]))[uint(4) * mbPartIdx])
    } elif (uint(subMbPartMode) == uint(MB_SP_8x4)) {
        unsafe(unsafe(addr(pMb_6.mv[0]))[uint(4) * mbPartIdx + uint(2) * subMbPartIdx]) = mv_1
        unsafe(unsafe(addr(pMb_6.mv[0]))[uint(4) * mbPartIdx + uint(2) * subMbPartIdx])
    } elif (uint(subMbPartMode) == uint(MB_SP_4x8)) {
        unsafe(unsafe(addr(pMb_6.mv[0]))[uint(4) * mbPartIdx + subMbPartIdx]) = mv_1
        unsafe(unsafe(addr(pMb_6.mv[0]))[uint(4) * mbPartIdx + subMbPartIdx])
    } elif (uint(subMbPartMode) == uint(MB_SP_4x4)) {
        unsafe(unsafe(addr(pMb_6.mv[0]))[uint(4) * mbPartIdx + subMbPartIdx]) = mv_1
        unsafe(unsafe(addr(pMb_6.mv[0]))[uint(4) * mbPartIdx + subMbPartIdx])
    }
    return uint(0)
}
[export]
def GetPredictionMv(var mv_2 : mv_t?; var a_0 : interNeighbour_t?; var refIndex_0 : uint) {
    if (unsafe(a_0[1]).available != 0x0 || unsafe(a_0[2]).available != 0x0 || unsafe(a_0[0]).available == 0) {
        var isA : uint
        var isB : uint
        var isC : uint
        var c2da_fresh42_h264bsd : int = 0
        if (unsafe(a_0[0]).refIndex == refIndex_0) {
            c2da_fresh42_h264bsd = 1
        } else {
            c2da_fresh42_h264bsd = 0
        }
        isA = uint(uint(c2da_fresh42_h264bsd))
        isA
        var c2da_fresh43_h264bsd : int = 0
        if (unsafe(a_0[1]).refIndex == refIndex_0) {
            c2da_fresh43_h264bsd = 1
        } else {
            c2da_fresh43_h264bsd = 0
        }
        isB = uint(uint(c2da_fresh43_h264bsd))
        isB
        var c2da_fresh44_h264bsd : int = 0
        if (unsafe(a_0[2]).refIndex == refIndex_0) {
            c2da_fresh44_h264bsd = 1
        } else {
            c2da_fresh44_h264bsd = 0
        }
        isC = uint(uint(c2da_fresh44_h264bsd))
        isC
        if (uint(isA) + uint(isB) + uint(isC) != uint(1)) {
            mv_2.hor = int(MedianFilter(unsafe(a_0[0]).mv.hor, unsafe(a_0[1]).mv.hor, unsafe(a_0[2]).mv.hor))
            mv_2.hor
            mv_2.ver = int(MedianFilter(unsafe(a_0[0]).mv.ver, unsafe(a_0[1]).mv.ver, unsafe(a_0[2]).mv.ver))
            mv_2.ver
        } else {
            if (isA != 0x0) {
                *mv_2 = unsafe(a_0[0]).mv
                *mv_2
            } else {
                if (isB != 0x0) {
                    *mv_2 = unsafe(a_0[1]).mv
                    *mv_2
                } else {
                    *mv_2 = unsafe(a_0[2]).mv
                    *mv_2
                }
            }
        }
    } else {
        *mv_2 = unsafe(a_0[0]).mv
        *mv_2
    }
}
[export]
def MedianFilter(var a_1 : int; var b : int; var c_1 : int) : int {
    var max : int
    var min : int
    var med : int
    med = a_1
    min = med
    max = min
    max
    if (b > max) {
        max = b
        max
    } else {
        if (b < min) {
            min = b
            min
        }
    }
    if (c_1 > max) {
        med = max
        med
    } else {
        if (c_1 < min) {
            med = min
            med
        } else {
            med = c_1
            med
        }
    }
    return med
}
[export]
def GetInterNeighbour(var sliceId : uint; var nMb_0 : mbStorage_t?; var n_1 : interNeighbour_t?; var index_5 : uint) {
    n_1.available = uint(uint(0))
    n_1.available
    n_1.refIndex = uint(0xffffffff)
    n_1.refIndex
    n_1.mv.ver = 0
    n_1.mv.hor = n_1.mv.ver
    n_1.mv.hor
    if (nMb_0 != null && sliceId == nMb_0.sliceId) {
        var tmp_33 : uint
        var tmpMv : mv_t
        tmp_33 = uint(uint(nMb_0.mbType))
        tmp_33
        n_1.available = uint(uint(1))
        n_1.available
        if (tmp_33 <= uint(P_8x8ref0)) {
            tmpMv = unsafe(unsafe(addr(nMb_0.mv[0]))[index_5])
            tmpMv
            tmp_33 = uint(unsafe(unsafe(addr(nMb_0.refPic[0]))[uint(index_5) >> uint(uint(2))]))
            tmp_33
            n_1.refIndex = uint(tmp_33)
            n_1.refIndex
            n_1.mv = tmpMv
            n_1.mv
        }
    }
}
[export]
def h264bsdGetNeighbourMb(var pMb_7 : mbStorage_t?; var neighbour : neighbourMb_e) : mbStorage_t? {
    if (uint(neighbour) == uint(MB_A)) {
        return pMb_7.mbA
    } else {
        if (uint(neighbour) == uint(MB_B)) {
            return pMb_7.mbB
        } else {
            if (uint(neighbour) == uint(MB_C)) {
                return pMb_7.mbC
            } else {
                if (uint(neighbour) == uint(MB_D)) {
                    return pMb_7.mbD
                } else {
                    if (uint(neighbour) == uint(MB_CURR)) {
                        return pMb_7
                    } else {
                        return null
                    }
                }
            }
        }
    }
}
var N_D_SUB_PART : array<array<array<neighbour_t>>> const = [[[[cast<neighbourMb_e>(MB_D), uint8(15)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_D), uint8(15)], [cast<neighbourMb_e>(MB_A), uint8(5)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_D), uint8(15)], [cast<neighbourMb_e>(MB_B), uint8(10)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_D), uint8(15)], [cast<neighbourMb_e>(MB_B), uint8(10)], [cast<neighbourMb_e>(MB_A), uint8(5)], [cast<neighbourMb_e>(MB_CURR), uint8(0)]]], [[[cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_CURR), uint8(4)]]], [[[cast<neighbourMb_e>(MB_A), uint8(7)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(7)], [cast<neighbourMb_e>(MB_A), uint8(13)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(7)], [cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(7)], [cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_A), uint8(13)], [cast<neighbourMb_e>(MB_CURR), uint8(8)]]], [[[cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_CURR), uint8(12)]]]]

var N_C_SUB_PART : array<array<array<neighbour_t>>> const = [[[[cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_NA), uint8(4)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_NA), uint8(4)]]], [[[cast<neighbourMb_e>(MB_C), uint8(10)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_C), uint8(10)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(15)], [cast<neighbourMb_e>(MB_C), uint8(10)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(15)], [cast<neighbourMb_e>(MB_C), uint8(10)], [cast<neighbourMb_e>(MB_CURR), uint8(5)], [cast<neighbourMb_e>(MB_NA), uint8(0)]]], [[[cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_NA), uint8(12)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_NA), uint8(12)]]], [[[cast<neighbourMb_e>(MB_NA), uint8(2)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_NA), uint8(2)], [cast<neighbourMb_e>(MB_NA), uint8(8)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(7)], [cast<neighbourMb_e>(MB_NA), uint8(2)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(7)], [cast<neighbourMb_e>(MB_NA), uint8(2)], [cast<neighbourMb_e>(MB_CURR), uint8(13)], [cast<neighbourMb_e>(MB_NA), uint8(8)]]]]

var N_B_SUB_PART : array<array<array<neighbour_t>>> const = [[[[cast<neighbourMb_e>(MB_B), uint8(10)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(10)], [cast<neighbourMb_e>(MB_CURR), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(10)], [cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(10)], [cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_CURR), uint8(0)], [cast<neighbourMb_e>(MB_CURR), uint8(1)]]], [[[cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_CURR), uint8(4)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_B), uint8(15)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_B), uint8(15)], [cast<neighbourMb_e>(MB_CURR), uint8(4)], [cast<neighbourMb_e>(MB_CURR), uint8(5)]]], [[[cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_CURR), uint8(8)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(8)], [cast<neighbourMb_e>(MB_CURR), uint8(9)]]], [[[cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_CURR), uint8(12)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_CURR), uint8(7)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_CURR), uint8(7)], [cast<neighbourMb_e>(MB_CURR), uint8(12)], [cast<neighbourMb_e>(MB_CURR), uint8(13)]]]]

var N_A_SUB_PART : array<array<array<neighbour_t>>> const = [[[[cast<neighbourMb_e>(MB_A), uint8(5)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(5)], [cast<neighbourMb_e>(MB_A), uint8(7)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(5)], [cast<neighbourMb_e>(MB_CURR), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(5)], [cast<neighbourMb_e>(MB_CURR), uint8(0)], [cast<neighbourMb_e>(MB_A), uint8(7)], [cast<neighbourMb_e>(MB_CURR), uint8(2)]]], [[[cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_CURR), uint8(4)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_CURR), uint8(4)], [cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(6)]]], [[[cast<neighbourMb_e>(MB_A), uint8(13)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(13)], [cast<neighbourMb_e>(MB_A), uint8(15)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(13)], [cast<neighbourMb_e>(MB_CURR), uint8(8)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_A), uint8(13)], [cast<neighbourMb_e>(MB_CURR), uint8(8)], [cast<neighbourMb_e>(MB_A), uint8(15)], [cast<neighbourMb_e>(MB_CURR), uint8(10)]]], [[[cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_CURR), uint8(11)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_CURR), uint8(12)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_NA), uint8(0)]], [[cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_CURR), uint8(12)], [cast<neighbourMb_e>(MB_CURR), uint8(11)], [cast<neighbourMb_e>(MB_CURR), uint8(14)]]]]

[export]
def MvPrediction8x16(var pMb_8 : mbStorage_t?; var mbPred : mbPred_t?; var dpb_24 : dpbStorage_t?) : uint {
    var mv_3 : mv_t
    var mvPred_0 : mv_t
    var a_2 : array<interNeighbour_t> = [0, 0, 0]
    var refIndex_1 : uint
    var tmp_34 : uint8?
    mv_3 = unsafe(unsafe(addr(mbPred.mvdL0[0]))[0])
    mv_3
    refIndex_1 = uint(unsafe(unsafe(addr(mbPred.refIdxL0[0]))[0]))
    refIndex_1
    GetInterNeighbour(pMb_8.sliceId, pMb_8.mbA, unsafe(addr(a_2[0])), uint(5))
    if (unsafe(unsafe(addr(a_2[0]))[0]).refIndex == refIndex_1) {
        mvPred_0 = unsafe(unsafe(addr(a_2[0]))[0]).mv
        mvPred_0
    } else {
        GetInterNeighbour(pMb_8.sliceId, pMb_8.mbB, unsafe(unsafe(addr(a_2[0])) + 1), uint(10))
        GetInterNeighbour(pMb_8.sliceId, pMb_8.mbB, unsafe(unsafe(addr(a_2[0])) + 2), uint(14))
        if (unsafe(unsafe(addr(a_2[0]))[2]).available == 0) {
            GetInterNeighbour(pMb_8.sliceId, pMb_8.mbD, unsafe(unsafe(addr(a_2[0])) + 2), uint(15))
        }
        GetPredictionMv(unsafe(addr(mvPred_0)), unsafe(addr(a_2[0])), refIndex_1)
    }
    mv_3.hor = mv_3.hor + mvPred_0.hor
    mv_3.hor
    mv_3.ver = mv_3.ver + mvPred_0.ver
    mv_3.ver
    if (uint(int(mv_3.hor + 8192)) >= uint(16384)) {
        return uint(1)
    }
    if (uint(int(mv_3.ver + 2048)) >= uint(4096)) {
        return uint(1)
    }
    tmp_34 = h264bsdGetRefPicData(dpb_24, refIndex_1)
    tmp_34
    if (tmp_34 == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return uint(1)
    }
    unsafe(unsafe(addr(pMb_8.mv[0]))[11]) = mv_3
    unsafe(unsafe(addr(pMb_8.mv[0]))[10]) = unsafe(unsafe(addr(pMb_8.mv[0]))[11])
    unsafe(unsafe(addr(pMb_8.mv[0]))[9]) = unsafe(unsafe(addr(pMb_8.mv[0]))[10])
    unsafe(unsafe(addr(pMb_8.mv[0]))[8]) = unsafe(unsafe(addr(pMb_8.mv[0]))[9])
    unsafe(unsafe(addr(pMb_8.mv[0]))[3]) = unsafe(unsafe(addr(pMb_8.mv[0]))[8])
    unsafe(unsafe(addr(pMb_8.mv[0]))[2]) = unsafe(unsafe(addr(pMb_8.mv[0]))[3])
    unsafe(unsafe(addr(pMb_8.mv[0]))[1]) = unsafe(unsafe(addr(pMb_8.mv[0]))[2])
    unsafe(unsafe(addr(pMb_8.mv[0]))[0]) = unsafe(unsafe(addr(pMb_8.mv[0]))[1])
    unsafe(unsafe(addr(pMb_8.mv[0]))[0])
    unsafe(unsafe(addr(pMb_8.refPic[0]))[0]) = uint(refIndex_1)
    unsafe(unsafe(addr(pMb_8.refPic[0]))[0])
    unsafe(unsafe(addr(pMb_8.refPic[0]))[2]) = uint(refIndex_1)
    unsafe(unsafe(addr(pMb_8.refPic[0]))[2])
    unsafe(unsafe(addr(pMb_8.refAddr[0]))[0]) = tmp_34
    unsafe(unsafe(addr(pMb_8.refAddr[0]))[0])
    unsafe(unsafe(addr(pMb_8.refAddr[0]))[2]) = tmp_34
    unsafe(unsafe(addr(pMb_8.refAddr[0]))[2])
    mv_3 = unsafe(unsafe(addr(mbPred.mvdL0[0]))[1])
    mv_3
    refIndex_1 = uint(unsafe(unsafe(addr(mbPred.refIdxL0[0]))[1]))
    refIndex_1
    GetInterNeighbour(pMb_8.sliceId, pMb_8.mbC, unsafe(unsafe(addr(a_2[0])) + 2), uint(10))
    if (unsafe(unsafe(addr(a_2[0]))[2]).available == 0) {
        GetInterNeighbour(pMb_8.sliceId, pMb_8.mbB, unsafe(unsafe(addr(a_2[0])) + 2), uint(11))
    }
    if (unsafe(unsafe(addr(a_2[0]))[2]).refIndex == refIndex_1) {
        mvPred_0 = unsafe(unsafe(addr(a_2[0]))[2]).mv
        mvPred_0
    } else {
        unsafe(unsafe(addr(a_2[0]))[0]).available = uint(uint(1))
        unsafe(unsafe(addr(a_2[0]))[0]).available
        unsafe(unsafe(addr(a_2[0]))[0]).refIndex = uint(unsafe(unsafe(addr(pMb_8.refPic[0]))[0]))
        unsafe(unsafe(addr(a_2[0]))[0]).refIndex
        unsafe(unsafe(addr(a_2[0]))[0]).mv = unsafe(unsafe(addr(pMb_8.mv[0]))[0])
        unsafe(unsafe(addr(a_2[0]))[0]).mv
        GetInterNeighbour(pMb_8.sliceId, pMb_8.mbB, unsafe(unsafe(addr(a_2[0])) + 1), uint(14))
        GetPredictionMv(unsafe(addr(mvPred_0)), unsafe(addr(a_2[0])), refIndex_1)
    }
    mv_3.hor = mv_3.hor + mvPred_0.hor
    mv_3.hor
    mv_3.ver = mv_3.ver + mvPred_0.ver
    mv_3.ver
    if (uint(int(mv_3.hor + 8192)) >= uint(16384)) {
        return uint(1)
    }
    if (uint(int(mv_3.ver + 2048)) >= uint(4096)) {
        return uint(1)
    }
    tmp_34 = h264bsdGetRefPicData(dpb_24, refIndex_1)
    tmp_34
    if (tmp_34 == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return uint(1)
    }
    unsafe(unsafe(addr(pMb_8.mv[0]))[15]) = mv_3
    unsafe(unsafe(addr(pMb_8.mv[0]))[14]) = unsafe(unsafe(addr(pMb_8.mv[0]))[15])
    unsafe(unsafe(addr(pMb_8.mv[0]))[13]) = unsafe(unsafe(addr(pMb_8.mv[0]))[14])
    unsafe(unsafe(addr(pMb_8.mv[0]))[12]) = unsafe(unsafe(addr(pMb_8.mv[0]))[13])
    unsafe(unsafe(addr(pMb_8.mv[0]))[7]) = unsafe(unsafe(addr(pMb_8.mv[0]))[12])
    unsafe(unsafe(addr(pMb_8.mv[0]))[6]) = unsafe(unsafe(addr(pMb_8.mv[0]))[7])
    unsafe(unsafe(addr(pMb_8.mv[0]))[5]) = unsafe(unsafe(addr(pMb_8.mv[0]))[6])
    unsafe(unsafe(addr(pMb_8.mv[0]))[4]) = unsafe(unsafe(addr(pMb_8.mv[0]))[5])
    unsafe(unsafe(addr(pMb_8.mv[0]))[4])
    unsafe(unsafe(addr(pMb_8.refPic[0]))[1]) = uint(refIndex_1)
    unsafe(unsafe(addr(pMb_8.refPic[0]))[1])
    unsafe(unsafe(addr(pMb_8.refPic[0]))[3]) = uint(refIndex_1)
    unsafe(unsafe(addr(pMb_8.refPic[0]))[3])
    unsafe(unsafe(addr(pMb_8.refAddr[0]))[1]) = tmp_34
    unsafe(unsafe(addr(pMb_8.refAddr[0]))[1])
    unsafe(unsafe(addr(pMb_8.refAddr[0]))[3]) = tmp_34
    unsafe(unsafe(addr(pMb_8.refAddr[0]))[3])
    return uint(0)
}
[export]
def MvPrediction16x8(var pMb_9 : mbStorage_t?; var mbPred_0 : mbPred_t?; var dpb_25 : dpbStorage_t?) : uint {
    var mv_4 : mv_t
    var mvPred_1 : mv_t
    var a_3 : array<interNeighbour_t> = [0, 0, 0]
    var refIndex_2 : uint
    var tmp_35 : uint8?
    mv_4 = unsafe(unsafe(addr(mbPred_0.mvdL0[0]))[0])
    mv_4
    refIndex_2 = uint(unsafe(unsafe(addr(mbPred_0.refIdxL0[0]))[0]))
    refIndex_2
    GetInterNeighbour(pMb_9.sliceId, pMb_9.mbB, unsafe(unsafe(addr(a_3[0])) + 1), uint(10))
    if (unsafe(unsafe(addr(a_3[0]))[1]).refIndex == refIndex_2) {
        mvPred_1 = unsafe(unsafe(addr(a_3[0]))[1]).mv
        mvPred_1
    } else {
        GetInterNeighbour(pMb_9.sliceId, pMb_9.mbA, unsafe(addr(a_3[0])), uint(5))
        GetInterNeighbour(pMb_9.sliceId, pMb_9.mbC, unsafe(unsafe(addr(a_3[0])) + 2), uint(10))
        if (unsafe(unsafe(addr(a_3[0]))[2]).available == 0) {
            GetInterNeighbour(pMb_9.sliceId, pMb_9.mbD, unsafe(unsafe(addr(a_3[0])) + 2), uint(15))
        }
        GetPredictionMv(unsafe(addr(mvPred_1)), unsafe(addr(a_3[0])), refIndex_2)
    }
    mv_4.hor = mv_4.hor + mvPred_1.hor
    mv_4.hor
    mv_4.ver = mv_4.ver + mvPred_1.ver
    mv_4.ver
    if (uint(int(mv_4.hor + 8192)) >= uint(16384)) {
        return uint(1)
    }
    if (uint(int(mv_4.ver + 2048)) >= uint(4096)) {
        return uint(1)
    }
    tmp_35 = h264bsdGetRefPicData(dpb_25, refIndex_2)
    tmp_35
    if (tmp_35 == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return uint(1)
    }
    unsafe(unsafe(addr(pMb_9.mv[0]))[7]) = mv_4
    unsafe(unsafe(addr(pMb_9.mv[0]))[6]) = unsafe(unsafe(addr(pMb_9.mv[0]))[7])
    unsafe(unsafe(addr(pMb_9.mv[0]))[5]) = unsafe(unsafe(addr(pMb_9.mv[0]))[6])
    unsafe(unsafe(addr(pMb_9.mv[0]))[4]) = unsafe(unsafe(addr(pMb_9.mv[0]))[5])
    unsafe(unsafe(addr(pMb_9.mv[0]))[3]) = unsafe(unsafe(addr(pMb_9.mv[0]))[4])
    unsafe(unsafe(addr(pMb_9.mv[0]))[2]) = unsafe(unsafe(addr(pMb_9.mv[0]))[3])
    unsafe(unsafe(addr(pMb_9.mv[0]))[1]) = unsafe(unsafe(addr(pMb_9.mv[0]))[2])
    unsafe(unsafe(addr(pMb_9.mv[0]))[0]) = unsafe(unsafe(addr(pMb_9.mv[0]))[1])
    unsafe(unsafe(addr(pMb_9.mv[0]))[0])
    unsafe(unsafe(addr(pMb_9.refPic[0]))[0]) = uint(refIndex_2)
    unsafe(unsafe(addr(pMb_9.refPic[0]))[0])
    unsafe(unsafe(addr(pMb_9.refPic[0]))[1]) = uint(refIndex_2)
    unsafe(unsafe(addr(pMb_9.refPic[0]))[1])
    unsafe(unsafe(addr(pMb_9.refAddr[0]))[0]) = tmp_35
    unsafe(unsafe(addr(pMb_9.refAddr[0]))[0])
    unsafe(unsafe(addr(pMb_9.refAddr[0]))[1]) = tmp_35
    unsafe(unsafe(addr(pMb_9.refAddr[0]))[1])
    mv_4 = unsafe(unsafe(addr(mbPred_0.mvdL0[0]))[1])
    mv_4
    refIndex_2 = uint(unsafe(unsafe(addr(mbPred_0.refIdxL0[0]))[1]))
    refIndex_2
    GetInterNeighbour(pMb_9.sliceId, pMb_9.mbA, unsafe(addr(a_3[0])), uint(13))
    if (unsafe(unsafe(addr(a_3[0]))[0]).refIndex == refIndex_2) {
        mvPred_1 = unsafe(unsafe(addr(a_3[0]))[0]).mv
        mvPred_1
    } else {
        unsafe(unsafe(addr(a_3[0]))[1]).available = uint(uint(1))
        unsafe(unsafe(addr(a_3[0]))[1]).available
        unsafe(unsafe(addr(a_3[0]))[1]).refIndex = uint(unsafe(unsafe(addr(pMb_9.refPic[0]))[0]))
        unsafe(unsafe(addr(a_3[0]))[1]).refIndex
        unsafe(unsafe(addr(a_3[0]))[1]).mv = unsafe(unsafe(addr(pMb_9.mv[0]))[0])
        unsafe(unsafe(addr(a_3[0]))[1]).mv
        GetInterNeighbour(pMb_9.sliceId, pMb_9.mbA, unsafe(unsafe(addr(a_3[0])) + 2), uint(7))
        GetPredictionMv(unsafe(addr(mvPred_1)), unsafe(addr(a_3[0])), refIndex_2)
    }
    mv_4.hor = mv_4.hor + mvPred_1.hor
    mv_4.hor
    mv_4.ver = mv_4.ver + mvPred_1.ver
    mv_4.ver
    if (uint(int(mv_4.hor + 8192)) >= uint(16384)) {
        return uint(1)
    }
    if (uint(int(mv_4.ver + 2048)) >= uint(4096)) {
        return uint(1)
    }
    tmp_35 = h264bsdGetRefPicData(dpb_25, refIndex_2)
    tmp_35
    if (tmp_35 == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return uint(1)
    }
    unsafe(unsafe(addr(pMb_9.mv[0]))[15]) = mv_4
    unsafe(unsafe(addr(pMb_9.mv[0]))[14]) = unsafe(unsafe(addr(pMb_9.mv[0]))[15])
    unsafe(unsafe(addr(pMb_9.mv[0]))[13]) = unsafe(unsafe(addr(pMb_9.mv[0]))[14])
    unsafe(unsafe(addr(pMb_9.mv[0]))[12]) = unsafe(unsafe(addr(pMb_9.mv[0]))[13])
    unsafe(unsafe(addr(pMb_9.mv[0]))[11]) = unsafe(unsafe(addr(pMb_9.mv[0]))[12])
    unsafe(unsafe(addr(pMb_9.mv[0]))[10]) = unsafe(unsafe(addr(pMb_9.mv[0]))[11])
    unsafe(unsafe(addr(pMb_9.mv[0]))[9]) = unsafe(unsafe(addr(pMb_9.mv[0]))[10])
    unsafe(unsafe(addr(pMb_9.mv[0]))[8]) = unsafe(unsafe(addr(pMb_9.mv[0]))[9])
    unsafe(unsafe(addr(pMb_9.mv[0]))[8])
    unsafe(unsafe(addr(pMb_9.refPic[0]))[2]) = uint(refIndex_2)
    unsafe(unsafe(addr(pMb_9.refPic[0]))[2])
    unsafe(unsafe(addr(pMb_9.refPic[0]))[3]) = uint(refIndex_2)
    unsafe(unsafe(addr(pMb_9.refPic[0]))[3])
    unsafe(unsafe(addr(pMb_9.refAddr[0]))[2]) = tmp_35
    unsafe(unsafe(addr(pMb_9.refAddr[0]))[2])
    unsafe(unsafe(addr(pMb_9.refAddr[0]))[3]) = tmp_35
    unsafe(unsafe(addr(pMb_9.refAddr[0]))[3])
    return uint(0)
}
[export]
def MvPrediction16x16(var pMb_10 : mbStorage_t?; var mbPred_1 : mbPred_t?; var dpb_26 : dpbStorage_t?) : uint {
    var mv_5 : mv_t
    var mvPred_2 : mv_t
    var a_4 : array<interNeighbour_t> = [0, 0, 0]
    var refIndex_3 : uint
    var tmp_36 : uint8?
    var tmpMv1 : uint?
    var tmpMv2 : uint?
    refIndex_3 = uint(unsafe(unsafe(addr(mbPred_1.refIdxL0[0]))[0]))
    refIndex_3
    GetInterNeighbour(pMb_10.sliceId, pMb_10.mbA, unsafe(addr(a_4[0])), uint(5))
    GetInterNeighbour(pMb_10.sliceId, pMb_10.mbB, unsafe(unsafe(addr(a_4[0])) + 1), uint(10))
    tmpMv1 = unsafe(reinterpret<uint?>(unsafe(addr(unsafe(unsafe(addr(a_4[0]))[0]).mv))))
    tmpMv1
    tmpMv2 = unsafe(reinterpret<uint?>(unsafe(addr(unsafe(unsafe(addr(a_4[0]))[1]).mv))))
    tmpMv2
    if (uint(pMb_10.mbType) == uint(P_Skip) && unsafe(unsafe(addr(a_4[0]))[0]).available == 0 || unsafe(unsafe(addr(a_4[0]))[1]).available == 0 || unsafe(unsafe(addr(a_4[0]))[0]).refIndex == uint(0) && uint(*tmpMv1) == uint(0) || unsafe(unsafe(addr(a_4[0]))[1]).refIndex == uint(0) && uint(*tmpMv2) == uint(0)) {
        mv_5.ver = 0
        mv_5.hor = mv_5.ver
        mv_5.hor
    } else {
        mv_5 = unsafe(unsafe(addr(mbPred_1.mvdL0[0]))[0])
        mv_5
        GetInterNeighbour(pMb_10.sliceId, pMb_10.mbC, unsafe(unsafe(addr(a_4[0])) + 2), uint(10))
        if (unsafe(unsafe(addr(a_4[0]))[2]).available == 0) {
            GetInterNeighbour(pMb_10.sliceId, pMb_10.mbD, unsafe(unsafe(addr(a_4[0])) + 2), uint(15))
        }
        GetPredictionMv(unsafe(addr(mvPred_2)), unsafe(addr(a_4[0])), refIndex_3)
        mv_5.hor = mv_5.hor + mvPred_2.hor
        mv_5.hor
        mv_5.ver = mv_5.ver + mvPred_2.ver
        mv_5.ver
        if (uint(int(mv_5.hor + 8192)) >= uint(16384)) {
            return uint(1)
        }
        if (uint(int(mv_5.ver + 2048)) >= uint(4096)) {
            return uint(1)
        }
    }
    tmp_36 = h264bsdGetRefPicData(dpb_26, refIndex_3)
    tmp_36
    if (tmp_36 == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return uint(1)
    }
    unsafe(unsafe(addr(pMb_10.mv[0]))[15]) = mv_5
    unsafe(unsafe(addr(pMb_10.mv[0]))[14]) = unsafe(unsafe(addr(pMb_10.mv[0]))[15])
    unsafe(unsafe(addr(pMb_10.mv[0]))[13]) = unsafe(unsafe(addr(pMb_10.mv[0]))[14])
    unsafe(unsafe(addr(pMb_10.mv[0]))[12]) = unsafe(unsafe(addr(pMb_10.mv[0]))[13])
    unsafe(unsafe(addr(pMb_10.mv[0]))[11]) = unsafe(unsafe(addr(pMb_10.mv[0]))[12])
    unsafe(unsafe(addr(pMb_10.mv[0]))[10]) = unsafe(unsafe(addr(pMb_10.mv[0]))[11])
    unsafe(unsafe(addr(pMb_10.mv[0]))[9]) = unsafe(unsafe(addr(pMb_10.mv[0]))[10])
    unsafe(unsafe(addr(pMb_10.mv[0]))[8]) = unsafe(unsafe(addr(pMb_10.mv[0]))[9])
    unsafe(unsafe(addr(pMb_10.mv[0]))[7]) = unsafe(unsafe(addr(pMb_10.mv[0]))[8])
    unsafe(unsafe(addr(pMb_10.mv[0]))[6]) = unsafe(unsafe(addr(pMb_10.mv[0]))[7])
    unsafe(unsafe(addr(pMb_10.mv[0]))[5]) = unsafe(unsafe(addr(pMb_10.mv[0]))[6])
    unsafe(unsafe(addr(pMb_10.mv[0]))[4]) = unsafe(unsafe(addr(pMb_10.mv[0]))[5])
    unsafe(unsafe(addr(pMb_10.mv[0]))[3]) = unsafe(unsafe(addr(pMb_10.mv[0]))[4])
    unsafe(unsafe(addr(pMb_10.mv[0]))[2]) = unsafe(unsafe(addr(pMb_10.mv[0]))[3])
    unsafe(unsafe(addr(pMb_10.mv[0]))[1]) = unsafe(unsafe(addr(pMb_10.mv[0]))[2])
    unsafe(unsafe(addr(pMb_10.mv[0]))[0]) = unsafe(unsafe(addr(pMb_10.mv[0]))[1])
    unsafe(unsafe(addr(pMb_10.mv[0]))[0])
    unsafe(unsafe(addr(pMb_10.refPic[0]))[0]) = uint(refIndex_3)
    unsafe(unsafe(addr(pMb_10.refPic[0]))[0])
    unsafe(unsafe(addr(pMb_10.refPic[0]))[1]) = uint(refIndex_3)
    unsafe(unsafe(addr(pMb_10.refPic[0]))[1])
    unsafe(unsafe(addr(pMb_10.refPic[0]))[2]) = uint(refIndex_3)
    unsafe(unsafe(addr(pMb_10.refPic[0]))[2])
    unsafe(unsafe(addr(pMb_10.refPic[0]))[3]) = uint(refIndex_3)
    unsafe(unsafe(addr(pMb_10.refPic[0]))[3])
    unsafe(unsafe(addr(pMb_10.refAddr[0]))[0]) = tmp_36
    unsafe(unsafe(addr(pMb_10.refAddr[0]))[0])
    unsafe(unsafe(addr(pMb_10.refAddr[0]))[1]) = tmp_36
    unsafe(unsafe(addr(pMb_10.refAddr[0]))[1])
    unsafe(unsafe(addr(pMb_10.refAddr[0]))[2]) = tmp_36
    unsafe(unsafe(addr(pMb_10.refAddr[0]))[2])
    unsafe(unsafe(addr(pMb_10.refAddr[0]))[3]) = tmp_36
    unsafe(unsafe(addr(pMb_10.refAddr[0]))[3])
    return uint(0)
}
[export]
def h264bsdIntraPrediction(var pMb_11 : mbStorage_t?; var mbLayer : macroblockLayer_t?; var image_3 : image_t?; var mbNum_3 : uint; var constrainedIntraPred : uint; var data_4 : uint8?) : uint {
    var pelAbove : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var pelLeft : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var tmp_37 : uint
    h264bsdGetNeighbourPels(image_3, unsafe(addr(pelAbove[0])), unsafe(addr(pelLeft[0])), mbNum_3)
    if (uint(h264bsdMbPartPredMode(pMb_11.mbType)) == uint(PRED_MODE_INTRA16x16)) {
        tmp_37 = uint(h264bsdIntra16x16Prediction(pMb_11, data_4, unsafe(addr(mbLayer.residual.level[0])), unsafe(addr(pelAbove[0])), unsafe(addr(pelLeft[0])), constrainedIntraPred))
        tmp_37
        if (tmp_37 != uint(0)) {
            return tmp_37
        }
    } else {
        tmp_37 = uint(h264bsdIntra4x4Prediction(pMb_11, data_4, mbLayer, unsafe(addr(pelAbove[0])), unsafe(addr(pelLeft[0])), constrainedIntraPred))
        tmp_37
        if (tmp_37 != uint(0)) {
            return tmp_37
        }
    }
    tmp_37 = uint(h264bsdIntraChromaPrediction(pMb_11, unsafe(data_4 + 256), unsafe(unsafe(addr(mbLayer.residual.level[0])) + 16), unsafe(unsafe(addr(pelAbove[0])) + 21), unsafe(unsafe(addr(pelLeft[0])) + 16), mbLayer.mbPred.intraChromaPredMode, constrainedIntraPred))
    tmp_37
    if (tmp_37 != uint(0)) {
        return tmp_37
    }
    if (pMb_11.decoded > uint(1)) {
        return uint(0)
    }
    h264bsdWriteMacroblock(image_3, data_4)
    return uint(0)
}
[export]
def h264bsdIntraChromaPrediction(var pMb_12 : mbStorage_t?; var data_5 : uint8?; var residual_0 : array<int>?; var above : uint8?; var left_2 : uint8?; var predMode : uint; var constrainedIntraPred_0 : uint) : uint {
    var i_42 : uint
    var comp_2 : uint
    var block_4 : uint
    var availableA : uint
    var availableB : uint
    var availableD : uint
    availableA = uint(h264bsdIsNeighbourAvailable(pMb_12, pMb_12.mbA))
    availableA
    if (availableA != 0x0 && constrainedIntraPred_0 != 0x0 && uint(h264bsdMbPartPredMode(pMb_12.mbA.mbType)) == uint(PRED_MODE_INTER)) {
        availableA = uint(uint(0))
        availableA
    }
    availableB = uint(h264bsdIsNeighbourAvailable(pMb_12, pMb_12.mbB))
    availableB
    if (availableB != 0x0 && constrainedIntraPred_0 != 0x0 && uint(h264bsdMbPartPredMode(pMb_12.mbB.mbType)) == uint(PRED_MODE_INTER)) {
        availableB = uint(uint(0))
        availableB
    }
    availableD = uint(h264bsdIsNeighbourAvailable(pMb_12, pMb_12.mbD))
    availableD
    if (availableD != 0x0 && constrainedIntraPred_0 != 0x0 && uint(h264bsdMbPartPredMode(pMb_12.mbD.mbType)) == uint(PRED_MODE_INTER)) {
        availableD = uint(uint(0))
        availableD
    }
    block_4 = uint(uint(16))
    block_4
    while (comp_2 < uint(2)) {
        if (predMode == uint(0)) {
            IntraChromaDcPrediction(data_5, unsafe(above + 1), left_2, availableA, availableB)
        } elif (predMode == uint(1)) {
            if (availableA == 0) {
                return uint(1)
            }
        } elif (predMode == uint(2)) {
            if (availableB == 0) {
                return uint(1)
            }
        } else {
            if (availableA == 0 || availableB == 0 || availableD == 0) {
                return uint(1)
            }
        }
        i_42 = uint(uint(0))
        i_42
        while (i_42 < uint(4)) {
            h264bsdAddResidual(data_5, unsafe(addr(unsafe(residual_0[i_42])[0])), block_4)
            block_4 = block_4 + 1
        }
        data_5 = data_5 + 64
        data_5
        above = above + 9
        above
        left_2 = left_2 + 8
        left_2
        residual_0 = residual_0 + 4
        residual_0
        comp_2 = comp_2 + 1
    }
    return uint(0)
}
[export]
def h264bsdAddResidual(var data_6 : uint8?; var residual_1 : int?; var blockNum : uint) {
    var i_43 : uint
    var x_11 : uint
    var y_11 : uint
    var width_15 : uint
    var tmp1_12 : int
    var tmp2_12 : int
    var tmp3_11 : int
    var tmp4_10 : int
    var tmp_38 : uint8?
    var clp_8 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (unsafe(residual_1[0]) == 16777215) {
        return
    }
    if (blockNum < uint(16)) {
        width_15 = uint(uint(16))
        width_15
        x_11 = uint(unsafe(unsafe(addr(h264bsdBlockX[0]))[blockNum]))
        x_11
        y_11 = uint(unsafe(unsafe(addr(h264bsdBlockY[0]))[blockNum]))
        y_11
    } else {
        width_15 = uint(uint(8))
        width_15
        x_11 = uint(unsafe(unsafe(addr(h264bsdBlockX[0]))[blockNum & uint(3)]))
        x_11
        y_11 = uint(unsafe(unsafe(addr(h264bsdBlockY[0]))[blockNum & uint(3)]))
        y_11
    }
    tmp_38 = unsafe(unsafe(data_6 + y_11 * width_15) + x_11)
    tmp_38
    i_43 = uint(uint(4))
    i_43
    while (i_43 != 0x0) {
        residual_1 = residual_1 + 1
        tmp1_12 = *residual_1
        tmp1_12
        tmp2_12 = int(unsafe(tmp_38[0]))
        tmp2_12
        residual_1 = residual_1 + 1
        tmp3_11 = *residual_1
        tmp3_11
        tmp4_10 = int(unsafe(tmp_38[1]))
        tmp4_10
        unsafe(tmp_38[0]) = uint8(unsafe(clp_8[tmp1_12 + tmp2_12]))
        unsafe(tmp_38[0])
        residual_1 = residual_1 + 1
        tmp1_12 = *residual_1
        tmp1_12
        tmp2_12 = int(unsafe(tmp_38[2]))
        tmp2_12
        unsafe(tmp_38[1]) = uint8(unsafe(clp_8[tmp3_11 + tmp4_10]))
        unsafe(tmp_38[1])
        residual_1 = residual_1 + 1
        tmp3_11 = *residual_1
        tmp3_11
        tmp4_10 = int(unsafe(tmp_38[3]))
        tmp4_10
        tmp1_12 = int(unsafe(clp_8[tmp1_12 + tmp2_12]))
        tmp1_12
        tmp3_11 = int(unsafe(clp_8[tmp3_11 + tmp4_10]))
        tmp3_11
        unsafe(tmp_38[2]) = uint8(uint8(tmp1_12))
        unsafe(tmp_38[2])
        unsafe(tmp_38[3]) = uint8(uint8(tmp3_11))
        unsafe(tmp_38[3])
        tmp_38 = tmp_38 + width_15
        tmp_38
        i_43 = i_43 - 1
    }
}
[export]
def IntraChromaPlanePrediction(var data_7 : uint8?; var above_0 : uint8?; var left_3 : uint8?) {
    var i_44 : uint
    var a_5 : int
    var b_0 : int
    var c_2 : int
    var tmp_39 : int
    var clp_9 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    a_5 = 16 * int(unsafe(above_0[7])) + int(unsafe(left_3[7]))
    a_5
    b_0 = int(unsafe(above_0[4])) - int(unsafe(above_0[2])) + 2 * int(unsafe(above_0[5])) - int(unsafe(above_0[1])) + 3 * int(unsafe(above_0[6])) - int(unsafe(above_0[0])) + 4 * int(unsafe(above_0[7])) - int(unsafe(above_0[-1]))
    b_0
    b_0 = 17 * b_0 + 16 >> 5
    b_0
    c_2 = int(unsafe(left_3[4])) - int(unsafe(left_3[2])) + 2 * int(unsafe(left_3[5])) - int(unsafe(left_3[1])) + 3 * int(unsafe(left_3[6])) - int(unsafe(left_3[0])) + 4 * int(unsafe(left_3[7])) - int(unsafe(above_0[-1]))
    c_2
    c_2 = 17 * c_2 + 16 >> 5
    c_2
    a_5 = a_5 - 3 * c_2 + 16
    a_5
    i_44 = uint(uint(8))
    i_44
    while (i_44 != 0x0) {
        tmp_39 = a_5 - 3 * b_0
        tmp_39
        data_7 = data_7 + 1
        *data_7 = uint8(unsafe(clp_9[tmp_39 >> 5]))
        *data_7
        tmp_39 = tmp_39 + b_0
        tmp_39
        data_7 = data_7 + 1
        *data_7 = uint8(unsafe(clp_9[tmp_39 >> 5]))
        *data_7
        tmp_39 = tmp_39 + b_0
        tmp_39
        data_7 = data_7 + 1
        *data_7 = uint8(unsafe(clp_9[tmp_39 >> 5]))
        *data_7
        tmp_39 = tmp_39 + b_0
        tmp_39
        data_7 = data_7 + 1
        *data_7 = uint8(unsafe(clp_9[tmp_39 >> 5]))
        *data_7
        tmp_39 = tmp_39 + b_0
        tmp_39
        data_7 = data_7 + 1
        *data_7 = uint8(unsafe(clp_9[tmp_39 >> 5]))
        *data_7
        tmp_39 = tmp_39 + b_0
        tmp_39
        data_7 = data_7 + 1
        *data_7 = uint8(unsafe(clp_9[tmp_39 >> 5]))
        *data_7
        tmp_39 = tmp_39 + b_0
        tmp_39
        data_7 = data_7 + 1
        *data_7 = uint8(unsafe(clp_9[tmp_39 >> 5]))
        *data_7
        tmp_39 = tmp_39 + b_0
        tmp_39
        data_7 = data_7 + 1
        *data_7 = uint8(unsafe(clp_9[tmp_39 >> 5]))
        *data_7
        a_5 = a_5 + c_2
    }
}
[export]
def IntraChromaVerticalPrediction(var data_8 : uint8?; var above_1 : uint8?) {
    var i_45 : uint
    i_45 = uint(uint(8))
    i_45
    while (i_45 != 0x0) {
        unsafe(data_8[0]) = uint8(*above_1)
        unsafe(data_8[0])
        unsafe(data_8[8]) = uint8(*above_1)
        unsafe(data_8[8])
        unsafe(data_8[16]) = uint8(*above_1)
        unsafe(data_8[16])
        unsafe(data_8[24]) = uint8(*above_1)
        unsafe(data_8[24])
        unsafe(data_8[32]) = uint8(*above_1)
        unsafe(data_8[32])
        unsafe(data_8[40]) = uint8(*above_1)
        unsafe(data_8[40])
        unsafe(data_8[48]) = uint8(*above_1)
        unsafe(data_8[48])
        above_1 = above_1 + 1
        unsafe(data_8[56]) = uint8(*above_1)
        unsafe(data_8[56])
        data_8 = data_8 + 1
    }
}
[export]
def IntraChromaHorizontalPrediction(var data_9 : uint8?; var left_4 : uint8?) {
    var i_46 : uint
    i_46 = uint(uint(8))
    i_46
    while (i_46 != 0x0) {
        data_9 = data_9 + 1
        *data_9 = uint8(*left_4)
        *data_9
        data_9 = data_9 + 1
        *data_9 = uint8(*left_4)
        *data_9
        data_9 = data_9 + 1
        *data_9 = uint8(*left_4)
        *data_9
        data_9 = data_9 + 1
        *data_9 = uint8(*left_4)
        *data_9
        data_9 = data_9 + 1
        *data_9 = uint8(*left_4)
        *data_9
        data_9 = data_9 + 1
        *data_9 = uint8(*left_4)
        *data_9
        data_9 = data_9 + 1
        *data_9 = uint8(*left_4)
        *data_9
        data_9 = data_9 + 1
        left_4 = left_4 + 1
        *data_9 = uint8(*left_4)
        *data_9
    }
}
[export]
def IntraChromaDcPrediction(var data_10 : uint8?; var above_2 : uint8?; var left_5 : uint8?; var availableA_0 : uint; var availableB_0 : uint) {
    var i_47 : uint
    var tmp1_13 : uint
    var tmp2_13 : uint
    if (availableA_0 != 0x0 && availableB_0 != 0x0) {
        tmp1_13 = uint(uint(int(unsafe(above_2[0])) + int(unsafe(above_2[1])) + int(unsafe(above_2[2])) + int(unsafe(above_2[3])) + int(unsafe(left_5[0])) + int(unsafe(left_5[1])) + int(unsafe(left_5[2])) + int(unsafe(left_5[3]))))
        tmp1_13
        tmp1_13 = uint(uint(tmp1_13 + uint(4)) >> uint(uint(3)))
        tmp1_13
        tmp2_13 = uint(uint(int(unsafe(above_2[4])) + int(unsafe(above_2[5])) + int(unsafe(above_2[6])) + int(unsafe(above_2[7])) + 2 >> 2))
        tmp2_13
    } else {
        if (availableB_0 != 0x0) {
            tmp1_13 = uint(uint(int(unsafe(above_2[0])) + int(unsafe(above_2[1])) + int(unsafe(above_2[2])) + int(unsafe(above_2[3])) + 2 >> 2))
            tmp1_13
            tmp2_13 = uint(uint(int(unsafe(above_2[4])) + int(unsafe(above_2[5])) + int(unsafe(above_2[6])) + int(unsafe(above_2[7])) + 2 >> 2))
            tmp2_13
        } else {
            if (availableA_0 != 0x0) {
                tmp1_13 = uint(uint(int(unsafe(left_5[0])) + int(unsafe(left_5[1])) + int(unsafe(left_5[2])) + int(unsafe(left_5[3])) + 2 >> 2))
                tmp1_13
                tmp2_13 = uint(tmp1_13)
                tmp2_13
            } else {
                tmp2_13 = uint(uint(128))
                tmp1_13 = uint(tmp2_13)
                tmp1_13
            }
        }
    }
    i_47 = uint(uint(4))
    i_47
    while (i_47 != 0x0) {
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp1_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp1_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp1_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp1_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp2_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp2_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp2_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp2_13))
        *data_10
    }
    if (availableA_0 != 0x0) {
        tmp1_13 = uint(uint(int(unsafe(left_5[4])) + int(unsafe(left_5[5])) + int(unsafe(left_5[6])) + int(unsafe(left_5[7])) + 2 >> 2))
        tmp1_13
        if (availableB_0 != 0x0) {
            tmp2_13 = uint(uint(int(unsafe(above_2[4])) + int(unsafe(above_2[5])) + int(unsafe(above_2[6])) + int(unsafe(above_2[7])) + int(unsafe(left_5[4])) + int(unsafe(left_5[5])) + int(unsafe(left_5[6])) + int(unsafe(left_5[7]))))
            tmp2_13
            tmp2_13 = uint(uint(tmp2_13 + uint(4)) >> uint(uint(3)))
            tmp2_13
        } else {
            tmp2_13 = uint(tmp1_13)
            tmp2_13
        }
    } else {
        if (availableB_0 != 0x0) {
            tmp1_13 = uint(uint(int(unsafe(above_2[0])) + int(unsafe(above_2[1])) + int(unsafe(above_2[2])) + int(unsafe(above_2[3])) + 2 >> 2))
            tmp1_13
            tmp2_13 = uint(uint(int(unsafe(above_2[4])) + int(unsafe(above_2[5])) + int(unsafe(above_2[6])) + int(unsafe(above_2[7])) + 2 >> 2))
            tmp2_13
        } else {
            tmp2_13 = uint(uint(128))
            tmp1_13 = uint(tmp2_13)
            tmp1_13
        }
    }
    i_47 = uint(uint(4))
    i_47
    while (i_47 != 0x0) {
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp1_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp1_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp1_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp1_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp2_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp2_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp2_13))
        *data_10
        data_10 = data_10 + 1
        *data_10 = uint8(uint8(tmp2_13))
        *data_10
    }
}
[export]
def h264bsdIntra4x4Prediction(var pMb_13 : mbStorage_t?; var data_11 : uint8?; var mbLayer_0 : macroblockLayer_t?; var above_3 : uint8?; var left_6 : uint8?; var constrainedIntraPred_1 : uint) : uint {
    var block_5 : uint
    var mode : uint
    var neighbour_0 : neighbour_t
    var neighbourB_0 : neighbour_t
    var nMb_1 : mbStorage_t?
    var nMb2 : mbStorage_t?
    var a_6 : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var l : array<uint8> = [0, 0, 0, 0, 0]
    var data4x4 : array<uint> = [0, 0, 0, 0]
    var availableA_1 : uint
    var availableB_1 : uint
    var availableC : uint
    var availableD_0 : uint
    block_5 = uint(uint(0))
    block_5
    while (block_5 < uint(16)) {
        neighbour_0 = *h264bsdNeighbour4x4BlockA(block_5)
        neighbour_0
        nMb_1 = h264bsdGetNeighbourMb(pMb_13, neighbour_0.mb)
        nMb_1
        availableA_1 = uint(h264bsdIsNeighbourAvailable(pMb_13, nMb_1))
        availableA_1
        if (availableA_1 != 0x0 && constrainedIntraPred_1 != 0x0 && uint(h264bsdMbPartPredMode(nMb_1.mbType)) == uint(PRED_MODE_INTER)) {
            availableA_1 = uint(uint(0))
            availableA_1
        }
        neighbourB_0 = *h264bsdNeighbour4x4BlockB(block_5)
        neighbourB_0
        nMb2 = h264bsdGetNeighbourMb(pMb_13, neighbourB_0.mb)
        nMb2
        availableB_1 = uint(h264bsdIsNeighbourAvailable(pMb_13, nMb2))
        availableB_1
        if (availableB_1 != 0x0 && constrainedIntraPred_1 != 0x0 && uint(h264bsdMbPartPredMode(nMb2.mbType)) == uint(PRED_MODE_INTER)) {
            availableB_1 = uint(uint(0))
            availableB_1
        }
        mode = uint(DetermineIntra4x4PredMode(mbLayer_0, uint(availableA_1 != 0x0 && availableB_1 != 0x0), unsafe(addr(neighbour_0)), unsafe(addr(neighbourB_0)), block_5, nMb_1, nMb2))
        mode
        unsafe(unsafe(addr(pMb_13.intra4x4PredMode[0]))[block_5]) = uint8(uint8(mode))
        unsafe(unsafe(addr(pMb_13.intra4x4PredMode[0]))[block_5])
        neighbour_0 = *h264bsdNeighbour4x4BlockC(block_5)
        neighbour_0
        nMb_1 = h264bsdGetNeighbourMb(pMb_13, neighbour_0.mb)
        nMb_1
        availableC = uint(h264bsdIsNeighbourAvailable(pMb_13, nMb_1))
        availableC
        if (availableC != 0x0 && constrainedIntraPred_1 != 0x0 && uint(h264bsdMbPartPredMode(nMb_1.mbType)) == uint(PRED_MODE_INTER)) {
            availableC = uint(uint(0))
            availableC
        }
        neighbour_0 = *h264bsdNeighbour4x4BlockD(block_5)
        neighbour_0
        nMb_1 = h264bsdGetNeighbourMb(pMb_13, neighbour_0.mb)
        nMb_1
        availableD_0 = uint(h264bsdIsNeighbourAvailable(pMb_13, nMb_1))
        availableD_0
        if (availableD_0 != 0x0 && constrainedIntraPred_1 != 0x0 && uint(h264bsdMbPartPredMode(nMb_1.mbType)) == uint(PRED_MODE_INTER)) {
            availableD_0 = uint(uint(0))
            availableD_0
        }
        Get4x4NeighbourPels(unsafe(addr(a_6[0])), unsafe(addr(l[0])), data_11, above_3, left_6, block_5)
        if (mode == uint(0)) {
            if (availableB_1 == 0) {
                return uint(1)
            }
        } elif (mode == uint(1)) {
            if (availableA_1 == 0) {
                return uint(1)
            }
        } elif (mode == uint(2)) {
            Intra4x4DcPrediction(unsafe(reinterpret<uint8?>(unsafe(addr(data4x4[0])))), unsafe(unsafe(addr(a_6[0])) + 1), unsafe(unsafe(addr(l[0])) + 1), availableA_1, availableB_1)
        } elif (mode == uint(3)) {
            if (availableB_1 == 0) {
                return uint(1)
            }
        } elif (mode == uint(4)) {
            if (availableA_1 == 0 || availableB_1 == 0 || availableD_0 == 0) {
                return uint(1)
            }
        } elif (mode == uint(5)) {
            if (availableA_1 == 0 || availableB_1 == 0 || availableD_0 == 0) {
                return uint(1)
            }
        } elif (mode == uint(6)) {
            if (availableA_1 == 0 || availableB_1 == 0 || availableD_0 == 0) {
                return uint(1)
            }
        } elif (mode == uint(7)) {
            if (availableB_1 == 0) {
                return uint(1)
            }
        } else {
            if (availableA_1 == 0) {
                return uint(1)
            }
        }
        Write4x4To16x16(data_11, unsafe(reinterpret<uint8?>(unsafe(addr(data4x4[0])))), block_5)
        h264bsdAddResidual(data_11, unsafe(addr(unsafe(unsafe(addr(mbLayer_0.residual.level[0]))[block_5])[0])), block_5)
        block_5 = block_5 + 1
    }
    return uint(0)
}
[export]
def Write4x4To16x16(var data_12 : uint8?; var data4x4_0 : uint8?; var blockNum_0 : uint) {
    var x_12 : uint
    var y_12 : uint
    var in32_1 : uint?
    var out32_1 : uint?
    x_12 = uint(unsafe(unsafe(addr(h264bsdBlockX[0]))[blockNum_0]))
    x_12
    y_12 = uint(unsafe(unsafe(addr(h264bsdBlockY[0]))[blockNum_0]))
    y_12
    data_12 = data_12 + y_12 * uint(16) + x_12
    data_12
    out32_1 = unsafe(reinterpret<uint?>(data_12))
    out32_1
    in32_1 = unsafe(reinterpret<uint?>(data4x4_0))
    in32_1
    in32_1 = in32_1 + 1
    unsafe(out32_1[0]) = uint(*in32_1)
    unsafe(out32_1[0])
    in32_1 = in32_1 + 1
    unsafe(out32_1[4]) = uint(*in32_1)
    unsafe(out32_1[4])
    in32_1 = in32_1 + 1
    unsafe(out32_1[8]) = uint(*in32_1)
    unsafe(out32_1[8])
    in32_1 = in32_1 + 1
    unsafe(out32_1[12]) = uint(*in32_1)
    unsafe(out32_1[12])
}
[export]
def Intra4x4HorizontalUpPrediction(var data_13 : uint8?; var left_7 : uint8?) {
    unsafe(data_13[0]) = uint8(uint8(int(unsafe(left_7[0])) + int(unsafe(left_7[1])) + 1 >> 1))
    unsafe(data_13[0])
    unsafe(data_13[1]) = uint8(uint8(int(unsafe(left_7[0])) + 2 * int(unsafe(left_7[1])) + int(unsafe(left_7[2])) + 2 >> 2))
    unsafe(data_13[1])
    unsafe(data_13[2]) = uint8(uint8(int(unsafe(left_7[1])) + int(unsafe(left_7[2])) + 1 >> 1))
    unsafe(data_13[2])
    unsafe(data_13[3]) = uint8(uint8(int(unsafe(left_7[1])) + 2 * int(unsafe(left_7[2])) + int(unsafe(left_7[3])) + 2 >> 2))
    unsafe(data_13[3])
    unsafe(data_13[4]) = uint8(uint8(int(unsafe(left_7[1])) + int(unsafe(left_7[2])) + 1 >> 1))
    unsafe(data_13[4])
    unsafe(data_13[5]) = uint8(uint8(int(unsafe(left_7[1])) + 2 * int(unsafe(left_7[2])) + int(unsafe(left_7[3])) + 2 >> 2))
    unsafe(data_13[5])
    unsafe(data_13[6]) = uint8(uint8(int(unsafe(left_7[2])) + int(unsafe(left_7[3])) + 1 >> 1))
    unsafe(data_13[6])
    unsafe(data_13[7]) = uint8(uint8(int(unsafe(left_7[2])) + 3 * int(unsafe(left_7[3])) + 2 >> 2))
    unsafe(data_13[7])
    unsafe(data_13[8]) = uint8(uint8(int(unsafe(left_7[2])) + int(unsafe(left_7[3])) + 1 >> 1))
    unsafe(data_13[8])
    unsafe(data_13[9]) = uint8(uint8(int(unsafe(left_7[2])) + 3 * int(unsafe(left_7[3])) + 2 >> 2))
    unsafe(data_13[9])
    unsafe(data_13[10]) = uint8(unsafe(left_7[3]))
    unsafe(data_13[10])
    unsafe(data_13[11]) = uint8(unsafe(left_7[3]))
    unsafe(data_13[11])
    unsafe(data_13[12]) = uint8(unsafe(left_7[3]))
    unsafe(data_13[12])
    unsafe(data_13[13]) = uint8(unsafe(left_7[3]))
    unsafe(data_13[13])
    unsafe(data_13[14]) = uint8(unsafe(left_7[3]))
    unsafe(data_13[14])
    unsafe(data_13[15]) = uint8(unsafe(left_7[3]))
    unsafe(data_13[15])
}
[export]
def Intra4x4VerticalLeftPrediction(var data_14 : uint8?; var above_4 : uint8?) {
    unsafe(data_14[0]) = uint8(uint8(int(unsafe(above_4[0])) + int(unsafe(above_4[1])) + 1 >> 1))
    unsafe(data_14[0])
    unsafe(data_14[1]) = uint8(uint8(int(unsafe(above_4[1])) + int(unsafe(above_4[2])) + 1 >> 1))
    unsafe(data_14[1])
    unsafe(data_14[2]) = uint8(uint8(int(unsafe(above_4[2])) + int(unsafe(above_4[3])) + 1 >> 1))
    unsafe(data_14[2])
    unsafe(data_14[3]) = uint8(uint8(int(unsafe(above_4[3])) + int(unsafe(above_4[4])) + 1 >> 1))
    unsafe(data_14[3])
    unsafe(data_14[4]) = uint8(uint8(int(unsafe(above_4[0])) + 2 * int(unsafe(above_4[1])) + int(unsafe(above_4[2])) + 2 >> 2))
    unsafe(data_14[4])
    unsafe(data_14[5]) = uint8(uint8(int(unsafe(above_4[1])) + 2 * int(unsafe(above_4[2])) + int(unsafe(above_4[3])) + 2 >> 2))
    unsafe(data_14[5])
    unsafe(data_14[6]) = uint8(uint8(int(unsafe(above_4[2])) + 2 * int(unsafe(above_4[3])) + int(unsafe(above_4[4])) + 2 >> 2))
    unsafe(data_14[6])
    unsafe(data_14[7]) = uint8(uint8(int(unsafe(above_4[3])) + 2 * int(unsafe(above_4[4])) + int(unsafe(above_4[5])) + 2 >> 2))
    unsafe(data_14[7])
    unsafe(data_14[8]) = uint8(uint8(int(unsafe(above_4[1])) + int(unsafe(above_4[2])) + 1 >> 1))
    unsafe(data_14[8])
    unsafe(data_14[9]) = uint8(uint8(int(unsafe(above_4[2])) + int(unsafe(above_4[3])) + 1 >> 1))
    unsafe(data_14[9])
    unsafe(data_14[10]) = uint8(uint8(int(unsafe(above_4[3])) + int(unsafe(above_4[4])) + 1 >> 1))
    unsafe(data_14[10])
    unsafe(data_14[11]) = uint8(uint8(int(unsafe(above_4[4])) + int(unsafe(above_4[5])) + 1 >> 1))
    unsafe(data_14[11])
    unsafe(data_14[12]) = uint8(uint8(int(unsafe(above_4[1])) + 2 * int(unsafe(above_4[2])) + int(unsafe(above_4[3])) + 2 >> 2))
    unsafe(data_14[12])
    unsafe(data_14[13]) = uint8(uint8(int(unsafe(above_4[2])) + 2 * int(unsafe(above_4[3])) + int(unsafe(above_4[4])) + 2 >> 2))
    unsafe(data_14[13])
    unsafe(data_14[14]) = uint8(uint8(int(unsafe(above_4[3])) + 2 * int(unsafe(above_4[4])) + int(unsafe(above_4[5])) + 2 >> 2))
    unsafe(data_14[14])
    unsafe(data_14[15]) = uint8(uint8(int(unsafe(above_4[4])) + 2 * int(unsafe(above_4[5])) + int(unsafe(above_4[6])) + 2 >> 2))
    unsafe(data_14[15])
}
[export]
def Intra4x4HorizontalDownPrediction(var data_15 : uint8?; var above_5 : uint8?; var left_8 : uint8?) {
    unsafe(data_15[0]) = uint8(uint8(int(unsafe(left_8[-1])) + int(unsafe(left_8[0])) + 1 >> 1))
    unsafe(data_15[0])
    unsafe(data_15[6]) = uint8(uint8(int(unsafe(left_8[-1])) + int(unsafe(left_8[0])) + 1 >> 1))
    unsafe(data_15[6])
    unsafe(data_15[5]) = uint8(uint8(int(unsafe(left_8[-1])) + 2 * int(unsafe(left_8[0])) + int(unsafe(left_8[1])) + 2 >> 2))
    unsafe(data_15[5])
    unsafe(data_15[11]) = uint8(uint8(int(unsafe(left_8[-1])) + 2 * int(unsafe(left_8[0])) + int(unsafe(left_8[1])) + 2 >> 2))
    unsafe(data_15[11])
    unsafe(data_15[4]) = uint8(uint8(int(unsafe(left_8[0])) + int(unsafe(left_8[1])) + 1 >> 1))
    unsafe(data_15[4])
    unsafe(data_15[10]) = uint8(uint8(int(unsafe(left_8[0])) + int(unsafe(left_8[1])) + 1 >> 1))
    unsafe(data_15[10])
    unsafe(data_15[9]) = uint8(uint8(int(unsafe(left_8[0])) + 2 * int(unsafe(left_8[1])) + int(unsafe(left_8[2])) + 2 >> 2))
    unsafe(data_15[9])
    unsafe(data_15[15]) = uint8(uint8(int(unsafe(left_8[0])) + 2 * int(unsafe(left_8[1])) + int(unsafe(left_8[2])) + 2 >> 2))
    unsafe(data_15[15])
    unsafe(data_15[8]) = uint8(uint8(int(unsafe(left_8[1])) + int(unsafe(left_8[2])) + 1 >> 1))
    unsafe(data_15[8])
    unsafe(data_15[14]) = uint8(uint8(int(unsafe(left_8[1])) + int(unsafe(left_8[2])) + 1 >> 1))
    unsafe(data_15[14])
    unsafe(data_15[13]) = uint8(uint8(int(unsafe(left_8[1])) + 2 * int(unsafe(left_8[2])) + int(unsafe(left_8[3])) + 2 >> 2))
    unsafe(data_15[13])
    unsafe(data_15[12]) = uint8(uint8(int(unsafe(left_8[2])) + int(unsafe(left_8[3])) + 1 >> 1))
    unsafe(data_15[12])
    unsafe(data_15[1]) = uint8(uint8(int(unsafe(above_5[0])) + 2 * int(unsafe(above_5[-1])) + int(unsafe(left_8[0])) + 2 >> 2))
    unsafe(data_15[1])
    unsafe(data_15[7]) = uint8(uint8(int(unsafe(above_5[0])) + 2 * int(unsafe(above_5[-1])) + int(unsafe(left_8[0])) + 2 >> 2))
    unsafe(data_15[7])
    unsafe(data_15[2]) = uint8(uint8(int(unsafe(above_5[1])) + 2 * int(unsafe(above_5[0])) + int(unsafe(above_5[-1])) + 2 >> 2))
    unsafe(data_15[2])
    unsafe(data_15[3]) = uint8(uint8(int(unsafe(above_5[2])) + 2 * int(unsafe(above_5[1])) + int(unsafe(above_5[0])) + 2 >> 2))
    unsafe(data_15[3])
}
[export]
def Intra4x4VerticalRightPrediction(var data_16 : uint8?; var above_6 : uint8?; var left_9 : uint8?) {
    unsafe(data_16[0]) = uint8(uint8(int(unsafe(above_6[-1])) + int(unsafe(above_6[0])) + 1 >> 1))
    unsafe(data_16[0])
    unsafe(data_16[9]) = uint8(uint8(int(unsafe(above_6[-1])) + int(unsafe(above_6[0])) + 1 >> 1))
    unsafe(data_16[9])
    unsafe(data_16[5]) = uint8(uint8(int(unsafe(above_6[-1])) + 2 * int(unsafe(above_6[0])) + int(unsafe(above_6[1])) + 2 >> 2))
    unsafe(data_16[5])
    unsafe(data_16[14]) = uint8(uint8(int(unsafe(above_6[-1])) + 2 * int(unsafe(above_6[0])) + int(unsafe(above_6[1])) + 2 >> 2))
    unsafe(data_16[14])
    unsafe(data_16[4]) = uint8(uint8(int(unsafe(above_6[0])) + 2 * int(unsafe(above_6[-1])) + int(unsafe(left_9[0])) + 2 >> 2))
    unsafe(data_16[4])
    unsafe(data_16[13]) = uint8(uint8(int(unsafe(above_6[0])) + 2 * int(unsafe(above_6[-1])) + int(unsafe(left_9[0])) + 2 >> 2))
    unsafe(data_16[13])
    unsafe(data_16[1]) = uint8(uint8(int(unsafe(above_6[0])) + int(unsafe(above_6[1])) + 1 >> 1))
    unsafe(data_16[1])
    unsafe(data_16[10]) = uint8(uint8(int(unsafe(above_6[0])) + int(unsafe(above_6[1])) + 1 >> 1))
    unsafe(data_16[10])
    unsafe(data_16[6]) = uint8(uint8(int(unsafe(above_6[0])) + 2 * int(unsafe(above_6[1])) + int(unsafe(above_6[2])) + 2 >> 2))
    unsafe(data_16[6])
    unsafe(data_16[15]) = uint8(uint8(int(unsafe(above_6[0])) + 2 * int(unsafe(above_6[1])) + int(unsafe(above_6[2])) + 2 >> 2))
    unsafe(data_16[15])
    unsafe(data_16[2]) = uint8(uint8(int(unsafe(above_6[1])) + int(unsafe(above_6[2])) + 1 >> 1))
    unsafe(data_16[2])
    unsafe(data_16[11]) = uint8(uint8(int(unsafe(above_6[1])) + int(unsafe(above_6[2])) + 1 >> 1))
    unsafe(data_16[11])
    unsafe(data_16[7]) = uint8(uint8(int(unsafe(above_6[1])) + 2 * int(unsafe(above_6[2])) + int(unsafe(above_6[3])) + 2 >> 2))
    unsafe(data_16[7])
    unsafe(data_16[3]) = uint8(uint8(int(unsafe(above_6[2])) + int(unsafe(above_6[3])) + 1 >> 1))
    unsafe(data_16[3])
    unsafe(data_16[8]) = uint8(uint8(int(unsafe(left_9[1])) + 2 * int(unsafe(left_9[0])) + int(unsafe(left_9[-1])) + 2 >> 2))
    unsafe(data_16[8])
    unsafe(data_16[12]) = uint8(uint8(int(unsafe(left_9[2])) + 2 * int(unsafe(left_9[1])) + int(unsafe(left_9[0])) + 2 >> 2))
    unsafe(data_16[12])
}
[export]
def Intra4x4DiagonalDownRightPrediction(var data_17 : uint8?; var above_7 : uint8?; var left_10 : uint8?) {
    unsafe(data_17[0]) = uint8(uint8(int(unsafe(above_7[0])) + 2 * int(unsafe(above_7[-1])) + int(unsafe(left_10[0])) + 2 >> 2))
    unsafe(data_17[0])
    unsafe(data_17[5]) = uint8(uint8(int(unsafe(above_7[0])) + 2 * int(unsafe(above_7[-1])) + int(unsafe(left_10[0])) + 2 >> 2))
    unsafe(data_17[5])
    unsafe(data_17[10]) = uint8(uint8(int(unsafe(above_7[0])) + 2 * int(unsafe(above_7[-1])) + int(unsafe(left_10[0])) + 2 >> 2))
    unsafe(data_17[10])
    unsafe(data_17[15]) = uint8(uint8(int(unsafe(above_7[0])) + 2 * int(unsafe(above_7[-1])) + int(unsafe(left_10[0])) + 2 >> 2))
    unsafe(data_17[15])
    unsafe(data_17[1]) = uint8(uint8(int(unsafe(above_7[-1])) + 2 * int(unsafe(above_7[0])) + int(unsafe(above_7[1])) + 2 >> 2))
    unsafe(data_17[1])
    unsafe(data_17[6]) = uint8(uint8(int(unsafe(above_7[-1])) + 2 * int(unsafe(above_7[0])) + int(unsafe(above_7[1])) + 2 >> 2))
    unsafe(data_17[6])
    unsafe(data_17[11]) = uint8(uint8(int(unsafe(above_7[-1])) + 2 * int(unsafe(above_7[0])) + int(unsafe(above_7[1])) + 2 >> 2))
    unsafe(data_17[11])
    unsafe(data_17[2]) = uint8(uint8(int(unsafe(above_7[0])) + 2 * int(unsafe(above_7[1])) + int(unsafe(above_7[2])) + 2 >> 2))
    unsafe(data_17[2])
    unsafe(data_17[7]) = uint8(uint8(int(unsafe(above_7[0])) + 2 * int(unsafe(above_7[1])) + int(unsafe(above_7[2])) + 2 >> 2))
    unsafe(data_17[7])
    unsafe(data_17[3]) = uint8(uint8(int(unsafe(above_7[1])) + 2 * int(unsafe(above_7[2])) + int(unsafe(above_7[3])) + 2 >> 2))
    unsafe(data_17[3])
    unsafe(data_17[4]) = uint8(uint8(int(unsafe(left_10[-1])) + 2 * int(unsafe(left_10[0])) + int(unsafe(left_10[1])) + 2 >> 2))
    unsafe(data_17[4])
    unsafe(data_17[9]) = uint8(uint8(int(unsafe(left_10[-1])) + 2 * int(unsafe(left_10[0])) + int(unsafe(left_10[1])) + 2 >> 2))
    unsafe(data_17[9])
    unsafe(data_17[14]) = uint8(uint8(int(unsafe(left_10[-1])) + 2 * int(unsafe(left_10[0])) + int(unsafe(left_10[1])) + 2 >> 2))
    unsafe(data_17[14])
    unsafe(data_17[8]) = uint8(uint8(int(unsafe(left_10[0])) + 2 * int(unsafe(left_10[1])) + int(unsafe(left_10[2])) + 2 >> 2))
    unsafe(data_17[8])
    unsafe(data_17[13]) = uint8(uint8(int(unsafe(left_10[0])) + 2 * int(unsafe(left_10[1])) + int(unsafe(left_10[2])) + 2 >> 2))
    unsafe(data_17[13])
    unsafe(data_17[12]) = uint8(uint8(int(unsafe(left_10[1])) + 2 * int(unsafe(left_10[2])) + int(unsafe(left_10[3])) + 2 >> 2))
    unsafe(data_17[12])
}
[export]
def Intra4x4DiagonalDownLeftPrediction(var data_18 : uint8?; var above_8 : uint8?) {
    unsafe(data_18[0]) = uint8(uint8(int(unsafe(above_8[0])) + 2 * int(unsafe(above_8[1])) + int(unsafe(above_8[2])) + 2 >> 2))
    unsafe(data_18[0])
    unsafe(data_18[1]) = uint8(uint8(int(unsafe(above_8[1])) + 2 * int(unsafe(above_8[2])) + int(unsafe(above_8[3])) + 2 >> 2))
    unsafe(data_18[1])
    unsafe(data_18[4]) = uint8(uint8(int(unsafe(above_8[1])) + 2 * int(unsafe(above_8[2])) + int(unsafe(above_8[3])) + 2 >> 2))
    unsafe(data_18[4])
    unsafe(data_18[2]) = uint8(uint8(int(unsafe(above_8[2])) + 2 * int(unsafe(above_8[3])) + int(unsafe(above_8[4])) + 2 >> 2))
    unsafe(data_18[2])
    unsafe(data_18[5]) = uint8(uint8(int(unsafe(above_8[2])) + 2 * int(unsafe(above_8[3])) + int(unsafe(above_8[4])) + 2 >> 2))
    unsafe(data_18[5])
    unsafe(data_18[8]) = uint8(uint8(int(unsafe(above_8[2])) + 2 * int(unsafe(above_8[3])) + int(unsafe(above_8[4])) + 2 >> 2))
    unsafe(data_18[8])
    unsafe(data_18[3]) = uint8(uint8(int(unsafe(above_8[3])) + 2 * int(unsafe(above_8[4])) + int(unsafe(above_8[5])) + 2 >> 2))
    unsafe(data_18[3])
    unsafe(data_18[6]) = uint8(uint8(int(unsafe(above_8[3])) + 2 * int(unsafe(above_8[4])) + int(unsafe(above_8[5])) + 2 >> 2))
    unsafe(data_18[6])
    unsafe(data_18[9]) = uint8(uint8(int(unsafe(above_8[3])) + 2 * int(unsafe(above_8[4])) + int(unsafe(above_8[5])) + 2 >> 2))
    unsafe(data_18[9])
    unsafe(data_18[12]) = uint8(uint8(int(unsafe(above_8[3])) + 2 * int(unsafe(above_8[4])) + int(unsafe(above_8[5])) + 2 >> 2))
    unsafe(data_18[12])
    unsafe(data_18[7]) = uint8(uint8(int(unsafe(above_8[4])) + 2 * int(unsafe(above_8[5])) + int(unsafe(above_8[6])) + 2 >> 2))
    unsafe(data_18[7])
    unsafe(data_18[10]) = uint8(uint8(int(unsafe(above_8[4])) + 2 * int(unsafe(above_8[5])) + int(unsafe(above_8[6])) + 2 >> 2))
    unsafe(data_18[10])
    unsafe(data_18[13]) = uint8(uint8(int(unsafe(above_8[4])) + 2 * int(unsafe(above_8[5])) + int(unsafe(above_8[6])) + 2 >> 2))
    unsafe(data_18[13])
    unsafe(data_18[11]) = uint8(uint8(int(unsafe(above_8[5])) + 2 * int(unsafe(above_8[6])) + int(unsafe(above_8[7])) + 2 >> 2))
    unsafe(data_18[11])
    unsafe(data_18[14]) = uint8(uint8(int(unsafe(above_8[5])) + 2 * int(unsafe(above_8[6])) + int(unsafe(above_8[7])) + 2 >> 2))
    unsafe(data_18[14])
    unsafe(data_18[15]) = uint8(uint8(int(unsafe(above_8[6])) + 3 * int(unsafe(above_8[7])) + 2 >> 2))
    unsafe(data_18[15])
}
[export]
def Intra4x4DcPrediction(var data_19 : uint8?; var above_9 : uint8?; var left_11 : uint8?; var availableA_2 : uint; var availableB_2 : uint) {
    var tmp_40 : uint
    var t1 : uint8
    var t2 : uint8
    var t3 : uint8
    var t4 : uint8
    if (availableA_2 != 0x0 && availableB_2 != 0x0) {
        t1 = uint8(unsafe(above_9[0]))
        t1
        t2 = uint8(unsafe(above_9[1]))
        t2
        t3 = uint8(unsafe(above_9[2]))
        t3
        t4 = uint8(unsafe(above_9[3]))
        t4
        tmp_40 = uint(uint(int(t1) + int(t2) + int(t3) + int(t4)))
        tmp_40
        t1 = uint8(unsafe(left_11[0]))
        t1
        t2 = uint8(unsafe(left_11[1]))
        t2
        t3 = uint8(unsafe(left_11[2]))
        t3
        t4 = uint8(unsafe(left_11[3]))
        t4
        tmp_40 = uint(tmp_40 + uint(int(t1) + int(t2) + int(t3) + int(t4)))
        tmp_40
        tmp_40 = uint(uint(tmp_40 + uint(4)) >> uint(uint(3)))
        tmp_40
    } else {
        if (availableA_2 != 0x0) {
            t1 = uint8(unsafe(left_11[0]))
            t1
            t2 = uint8(unsafe(left_11[1]))
            t2
            t3 = uint8(unsafe(left_11[2]))
            t3
            t4 = uint8(unsafe(left_11[3]))
            t4
            tmp_40 = uint(uint(int(t1) + int(t2) + int(t3) + int(t4) + 2 >> 2))
            tmp_40
        } else {
            if (availableB_2 != 0x0) {
                t1 = uint8(unsafe(above_9[0]))
                t1
                t2 = uint8(unsafe(above_9[1]))
                t2
                t3 = uint8(unsafe(above_9[2]))
                t3
                t4 = uint8(unsafe(above_9[3]))
                t4
                tmp_40 = uint(uint(int(t1) + int(t2) + int(t3) + int(t4) + 2 >> 2))
                tmp_40
            } else {
                tmp_40 = uint(uint(128))
                tmp_40
            }
        }
    }
    unsafe(data_19[15]) = uint8(uint8(tmp_40))
    unsafe(data_19[14]) = uint8(unsafe(data_19[15]))
    unsafe(data_19[13]) = uint8(unsafe(data_19[14]))
    unsafe(data_19[12]) = uint8(unsafe(data_19[13]))
    unsafe(data_19[11]) = uint8(unsafe(data_19[12]))
    unsafe(data_19[10]) = uint8(unsafe(data_19[11]))
    unsafe(data_19[9]) = uint8(unsafe(data_19[10]))
    unsafe(data_19[8]) = uint8(unsafe(data_19[9]))
    unsafe(data_19[7]) = uint8(unsafe(data_19[8]))
    unsafe(data_19[6]) = uint8(unsafe(data_19[7]))
    unsafe(data_19[5]) = uint8(unsafe(data_19[6]))
    unsafe(data_19[4]) = uint8(unsafe(data_19[5]))
    unsafe(data_19[3]) = uint8(unsafe(data_19[4]))
    unsafe(data_19[2]) = uint8(unsafe(data_19[3]))
    unsafe(data_19[1]) = uint8(unsafe(data_19[2]))
    unsafe(data_19[0]) = uint8(unsafe(data_19[1]))
    unsafe(data_19[0])
}
[export]
def Intra4x4HorizontalPrediction(var data_20 : uint8?; var left_12 : uint8?) {
    var t1_0 : uint8
    var t2_0 : uint8
    t1_0 = uint8(unsafe(left_12[0]))
    t1_0
    t2_0 = uint8(unsafe(left_12[1]))
    t2_0
    unsafe(data_20[3]) = uint8(t1_0)
    unsafe(data_20[2]) = uint8(unsafe(data_20[3]))
    unsafe(data_20[1]) = uint8(unsafe(data_20[2]))
    unsafe(data_20[0]) = uint8(unsafe(data_20[1]))
    unsafe(data_20[0])
    unsafe(data_20[7]) = uint8(t2_0)
    unsafe(data_20[6]) = uint8(unsafe(data_20[7]))
    unsafe(data_20[5]) = uint8(unsafe(data_20[6]))
    unsafe(data_20[4]) = uint8(unsafe(data_20[5]))
    unsafe(data_20[4])
    t1_0 = uint8(unsafe(left_12[2]))
    t1_0
    t2_0 = uint8(unsafe(left_12[3]))
    t2_0
    unsafe(data_20[11]) = uint8(t1_0)
    unsafe(data_20[10]) = uint8(unsafe(data_20[11]))
    unsafe(data_20[9]) = uint8(unsafe(data_20[10]))
    unsafe(data_20[8]) = uint8(unsafe(data_20[9]))
    unsafe(data_20[8])
    unsafe(data_20[15]) = uint8(t2_0)
    unsafe(data_20[14]) = uint8(unsafe(data_20[15]))
    unsafe(data_20[13]) = uint8(unsafe(data_20[14]))
    unsafe(data_20[12]) = uint8(unsafe(data_20[13]))
    unsafe(data_20[12])
}
[export]
def Intra4x4VerticalPrediction(var data_21 : uint8?; var above_10 : uint8?) {
    var t1_1 : uint8
    var t2_1 : uint8
    t1_1 = uint8(unsafe(above_10[0]))
    t1_1
    t2_1 = uint8(unsafe(above_10[1]))
    t2_1
    unsafe(data_21[12]) = uint8(t1_1)
    unsafe(data_21[8]) = uint8(unsafe(data_21[12]))
    unsafe(data_21[4]) = uint8(unsafe(data_21[8]))
    unsafe(data_21[0]) = uint8(unsafe(data_21[4]))
    unsafe(data_21[0])
    unsafe(data_21[13]) = uint8(t2_1)
    unsafe(data_21[9]) = uint8(unsafe(data_21[13]))
    unsafe(data_21[5]) = uint8(unsafe(data_21[9]))
    unsafe(data_21[1]) = uint8(unsafe(data_21[5]))
    unsafe(data_21[1])
    t1_1 = uint8(unsafe(above_10[2]))
    t1_1
    t2_1 = uint8(unsafe(above_10[3]))
    t2_1
    unsafe(data_21[14]) = uint8(t1_1)
    unsafe(data_21[10]) = uint8(unsafe(data_21[14]))
    unsafe(data_21[6]) = uint8(unsafe(data_21[10]))
    unsafe(data_21[2]) = uint8(unsafe(data_21[6]))
    unsafe(data_21[2])
    unsafe(data_21[15]) = uint8(t2_1)
    unsafe(data_21[11]) = uint8(unsafe(data_21[15]))
    unsafe(data_21[7]) = uint8(unsafe(data_21[11]))
    unsafe(data_21[3]) = uint8(unsafe(data_21[7]))
    unsafe(data_21[3])
}
[export]
def Get4x4NeighbourPels(var a_7 : uint8?; var l_0 : uint8?; var data_22 : uint8?; var above_11 : uint8?; var left_13 : uint8?; var blockNum_1 : uint) {
    var x_13 : uint
    var y_13 : uint
    var t1_2 : uint8
    var t2_2 : uint8
    x_13 = uint(unsafe(unsafe(addr(h264bsdBlockX[0]))[blockNum_1]))
    x_13
    y_13 = uint(unsafe(unsafe(addr(h264bsdBlockY[0]))[blockNum_1]))
    y_13
    if (x_13 == uint(0)) {
        t1_2 = uint8(unsafe(left_13[y_13]))
        t1_2
        t2_2 = uint8(unsafe(left_13[y_13 + uint(1)]))
        t2_2
        unsafe(l_0[1]) = uint8(t1_2)
        unsafe(l_0[1])
        unsafe(l_0[2]) = uint8(t2_2)
        unsafe(l_0[2])
        t1_2 = uint8(unsafe(left_13[y_13 + uint(2)]))
        t1_2
        t2_2 = uint8(unsafe(left_13[y_13 + uint(3)]))
        t2_2
        unsafe(l_0[3]) = uint8(t1_2)
        unsafe(l_0[3])
        unsafe(l_0[4]) = uint8(t2_2)
        unsafe(l_0[4])
    } else {
        t1_2 = uint8(unsafe(data_22[y_13 * uint(16) + x_13 - uint(1)]))
        t1_2
        t2_2 = uint8(unsafe(data_22[y_13 * uint(16) + x_13 - uint(1) + uint(16)]))
        t2_2
        unsafe(l_0[1]) = uint8(t1_2)
        unsafe(l_0[1])
        unsafe(l_0[2]) = uint8(t2_2)
        unsafe(l_0[2])
        t1_2 = uint8(unsafe(data_22[y_13 * uint(16) + x_13 - uint(1) + uint(32)]))
        t1_2
        t2_2 = uint8(unsafe(data_22[y_13 * uint(16) + x_13 - uint(1) + uint(48)]))
        t2_2
        unsafe(l_0[3]) = uint8(t1_2)
        unsafe(l_0[3])
        unsafe(l_0[4]) = uint8(t2_2)
        unsafe(l_0[4])
    }
    if (y_13 == uint(0)) {
        t1_2 = uint8(unsafe(above_11[x_13]))
        t1_2
        t2_2 = uint8(unsafe(above_11[x_13]))
        t2_2
        unsafe(l_0[0]) = uint8(t1_2)
        unsafe(l_0[0])
        unsafe(a_7[0]) = uint8(t2_2)
        unsafe(a_7[0])
        t1_2 = uint8(unsafe(above_11[x_13 + uint(1)]))
        t1_2
        t2_2 = uint8(unsafe(above_11[x_13 + uint(2)]))
        t2_2
        unsafe(a_7[1]) = uint8(t1_2)
        unsafe(a_7[1])
        unsafe(a_7[2]) = uint8(t2_2)
        unsafe(a_7[2])
        t1_2 = uint8(unsafe(above_11[x_13 + uint(3)]))
        t1_2
        t2_2 = uint8(unsafe(above_11[x_13 + uint(4)]))
        t2_2
        unsafe(a_7[3]) = uint8(t1_2)
        unsafe(a_7[3])
        unsafe(a_7[4]) = uint8(t2_2)
        unsafe(a_7[4])
        t1_2 = uint8(unsafe(above_11[x_13 + uint(5)]))
        t1_2
        t2_2 = uint8(unsafe(above_11[x_13 + uint(6)]))
        t2_2
        unsafe(a_7[5]) = uint8(t1_2)
        unsafe(a_7[5])
        unsafe(a_7[6]) = uint8(t2_2)
        unsafe(a_7[6])
        t1_2 = uint8(unsafe(above_11[x_13 + uint(7)]))
        t1_2
        t2_2 = uint8(unsafe(above_11[x_13 + uint(8)]))
        t2_2
        unsafe(a_7[7]) = uint8(t1_2)
        unsafe(a_7[7])
        unsafe(a_7[8]) = uint8(t2_2)
        unsafe(a_7[8])
    } else {
        t1_2 = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13]))
        t1_2
        t2_2 = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13 + uint(1)]))
        t2_2
        unsafe(a_7[1]) = uint8(t1_2)
        unsafe(a_7[1])
        unsafe(a_7[2]) = uint8(t2_2)
        unsafe(a_7[2])
        t1_2 = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13 + uint(2)]))
        t1_2
        t2_2 = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13 + uint(3)]))
        t2_2
        unsafe(a_7[3]) = uint8(t1_2)
        unsafe(a_7[3])
        unsafe(a_7[4]) = uint8(t2_2)
        unsafe(a_7[4])
        t1_2 = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13 + uint(4)]))
        t1_2
        t2_2 = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13 + uint(5)]))
        t2_2
        unsafe(a_7[5]) = uint8(t1_2)
        unsafe(a_7[5])
        unsafe(a_7[6]) = uint8(t2_2)
        unsafe(a_7[6])
        t1_2 = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13 + uint(6)]))
        t1_2
        t2_2 = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13 + uint(7)]))
        t2_2
        unsafe(a_7[7]) = uint8(t1_2)
        unsafe(a_7[7])
        unsafe(a_7[8]) = uint8(t2_2)
        unsafe(a_7[8])
        if (x_13 == uint(0)) {
            unsafe(a_7[0]) = uint8(unsafe(left_13[y_13 - uint(1)]))
            unsafe(l_0[0]) = uint8(unsafe(a_7[0]))
            unsafe(l_0[0])
        } else {
            unsafe(a_7[0]) = uint8(unsafe(data_22[y_13 - uint(1) * uint(16) + x_13 - uint(1)]))
            unsafe(l_0[0]) = uint8(unsafe(a_7[0]))
            unsafe(l_0[0])
        }
    }
}
[export]
def h264bsdNeighbour4x4BlockD(var blockIndex_3 : uint) : neighbour_t const? {
    return unsafe(unsafe(addr(N_D_4x4B[0])) + blockIndex_3)
}
var N_D_4x4B : array<neighbour_t> const = [[cast<neighbourMb_e>(MB_D), uint8(15)], [cast<neighbourMb_e>(MB_B), uint8(10)], [cast<neighbourMb_e>(MB_A), uint8(5)], [cast<neighbourMb_e>(MB_CURR), uint8(0)], [cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_CURR), uint8(4)], [cast<neighbourMb_e>(MB_A), uint8(7)], [cast<neighbourMb_e>(MB_CURR), uint8(2)], [cast<neighbourMb_e>(MB_A), uint8(13)], [cast<neighbourMb_e>(MB_CURR), uint8(8)], [cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_CURR), uint8(12)], [cast<neighbourMb_e>(MB_D), uint8(19)], [cast<neighbourMb_e>(MB_B), uint8(18)], [cast<neighbourMb_e>(MB_A), uint8(17)], [cast<neighbourMb_e>(MB_CURR), uint8(16)], [cast<neighbourMb_e>(MB_D), uint8(23)], [cast<neighbourMb_e>(MB_B), uint8(22)], [cast<neighbourMb_e>(MB_A), uint8(21)], [cast<neighbourMb_e>(MB_CURR), uint8(20)]]

[export]
def h264bsdNeighbour4x4BlockC(var blockIndex_4 : uint) : neighbour_t const? {
    return unsafe(unsafe(addr(N_C_4x4B[0])) + blockIndex_4)
}
var N_C_4x4B : array<neighbour_t> const = [[cast<neighbourMb_e>(MB_B), uint8(11)], [cast<neighbourMb_e>(MB_B), uint8(14)], [cast<neighbourMb_e>(MB_CURR), uint8(1)], [cast<neighbourMb_e>(MB_NA), uint8(4)], [cast<neighbourMb_e>(MB_B), uint8(15)], [cast<neighbourMb_e>(MB_C), uint8(10)], [cast<neighbourMb_e>(MB_CURR), uint8(5)], [cast<neighbourMb_e>(MB_NA), uint8(0)], [cast<neighbourMb_e>(MB_CURR), uint8(3)], [cast<neighbourMb_e>(MB_CURR), uint8(6)], [cast<neighbourMb_e>(MB_CURR), uint8(9)], [cast<neighbourMb_e>(MB_NA), uint8(12)], [cast<neighbourMb_e>(MB_CURR), uint8(7)], [cast<neighbourMb_e>(MB_NA), uint8(2)], [cast<neighbourMb_e>(MB_CURR), uint8(13)], [cast<neighbourMb_e>(MB_NA), uint8(8)], [cast<neighbourMb_e>(MB_B), uint8(19)], [cast<neighbourMb_e>(MB_C), uint8(18)], [cast<neighbourMb_e>(MB_CURR), uint8(17)], [cast<neighbourMb_e>(MB_NA), uint8(16)], [cast<neighbourMb_e>(MB_B), uint8(23)], [cast<neighbourMb_e>(MB_C), uint8(22)], [cast<neighbourMb_e>(MB_CURR), uint8(21)], [cast<neighbourMb_e>(MB_NA), uint8(20)]]

[export]
def DetermineIntra4x4PredMode(var pMbLayer_2 : macroblockLayer_t?; var available : uint; var nA : neighbour_t?; var nB : neighbour_t?; var index_6 : uint; var nMbA : mbStorage_t?; var nMbB : mbStorage_t?) : uint {
    var mode1 : uint
    var mode2 : uint
    var pMb_14 : mbStorage_t?
    if (available == 0) {
        mode1 = uint(uint(2))
        mode1
    } else {
        pMb_14 = nMbA
        pMb_14
        if (uint(h264bsdMbPartPredMode(pMb_14.mbType)) == uint(PRED_MODE_INTRA4x4)) {
            mode1 = uint(uint(unsafe(unsafe(addr(pMb_14.intra4x4PredMode[0]))[nA.index])))
            mode1
        } else {
            mode1 = uint(uint(2))
            mode1
        }
        pMb_14 = nMbB
        pMb_14
        if (uint(h264bsdMbPartPredMode(pMb_14.mbType)) == uint(PRED_MODE_INTRA4x4)) {
            mode2 = uint(uint(unsafe(unsafe(addr(pMb_14.intra4x4PredMode[0]))[nB.index])))
            mode2
        } else {
            mode2 = uint(uint(2))
            mode2
        }
        var c2da_fresh45_h264bsd : int = 0
        if (mode1 < mode2) {
            c2da_fresh45_h264bsd = mode1
        } else {
            c2da_fresh45_h264bsd = mode2
        }
        mode1 = uint(c2da_fresh45_h264bsd)
        mode1
    }
    if (unsafe(unsafe(addr(pMbLayer_2.mbPred.prevIntra4x4PredModeFlag[0]))[index_6]) == 0) {
        if (unsafe(unsafe(addr(pMbLayer_2.mbPred.remIntra4x4PredMode[0]))[index_6]) < mode1) {
            mode1 = uint(unsafe(unsafe(addr(pMbLayer_2.mbPred.remIntra4x4PredMode[0]))[index_6]))
            mode1
        } else {
            mode1 = uint(unsafe(unsafe(addr(pMbLayer_2.mbPred.remIntra4x4PredMode[0]))[index_6]) + uint(1))
            mode1
        }
    }
    return mode1
}
[export]
def h264bsdIntra16x16Prediction(var pMb_15 : mbStorage_t?; var data_23 : uint8?; var residual_2 : array<int>?; var above_12 : uint8?; var left_14 : uint8?; var constrainedIntraPred_2 : uint) : uint {
    var i_48 : uint
    var availableA_3 : uint
    var availableB_3 : uint
    var availableD_1 : uint
    availableA_3 = uint(h264bsdIsNeighbourAvailable(pMb_15, pMb_15.mbA))
    availableA_3
    if (availableA_3 != 0x0 && constrainedIntraPred_2 != 0x0 && uint(h264bsdMbPartPredMode(pMb_15.mbA.mbType)) == uint(PRED_MODE_INTER)) {
        availableA_3 = uint(uint(0))
        availableA_3
    }
    availableB_3 = uint(h264bsdIsNeighbourAvailable(pMb_15, pMb_15.mbB))
    availableB_3
    if (availableB_3 != 0x0 && constrainedIntraPred_2 != 0x0 && uint(h264bsdMbPartPredMode(pMb_15.mbB.mbType)) == uint(PRED_MODE_INTER)) {
        availableB_3 = uint(uint(0))
        availableB_3
    }
    availableD_1 = uint(h264bsdIsNeighbourAvailable(pMb_15, pMb_15.mbD))
    availableD_1
    if (availableD_1 != 0x0 && constrainedIntraPred_2 != 0x0 && uint(h264bsdMbPartPredMode(pMb_15.mbD.mbType)) == uint(PRED_MODE_INTER)) {
        availableD_1 = uint(uint(0))
        availableD_1
    }
    if (h264bsdPredModeIntra16x16(pMb_15.mbType) == uint(0)) {
        if (availableB_3 == 0) {
            return uint(1)
        }
    } elif (h264bsdPredModeIntra16x16(pMb_15.mbType) == uint(1)) {
        if (availableA_3 == 0) {
            return uint(1)
        }
    } elif (h264bsdPredModeIntra16x16(pMb_15.mbType) == uint(2)) {
        Intra16x16DcPrediction(data_23, unsafe(above_12 + 1), left_14, availableA_3, availableB_3)
    } else {
        if (availableA_3 == 0 || availableB_3 == 0 || availableD_1 == 0) {
            return uint(1)
        }
    }
    i_48 = uint(uint(0))
    i_48
    while (i_48 < uint(16)) {
        h264bsdAddResidual(data_23, unsafe(addr(unsafe(residual_2[i_48])[0])), i_48)
        i_48 = i_48 + 1
    }
    return uint(0)
}
[export]
def Intra16x16PlanePrediction(var data_24 : uint8?; var above_13 : uint8?; var left_15 : uint8?) {
    var i_49 : int
    var j_7 : int
    var a_8 : int
    var b_1 : int
    var c_3 : int
    var tmp_41 : int
    a_8 = 16 * int(unsafe(above_13[15])) + int(unsafe(left_15[15]))
    a_8
    b_1 = 0
    b_1
    while (i_49 < 8) {
        b_1 = b_1 + i_49 + 1 * int(unsafe(above_13[8 + i_49])) - int(unsafe(above_13[6 - i_49]))
        b_1
        i_49 = i_49 + 1
    }
    b_1 = 5 * b_1 + 32 >> 6
    b_1
    c_3 = 0
    c_3
    while (i_49 < 7) {
        c_3 = c_3 + i_49 + 1 * int(unsafe(left_15[8 + i_49])) - int(unsafe(left_15[6 - i_49]))
        c_3
        i_49 = i_49 + 1
    }
    c_3 = c_3 + i_49 + 1 * int(unsafe(left_15[8 + i_49])) - int(unsafe(above_13[-1]))
    c_3
    c_3 = 5 * c_3 + 32 >> 6
    c_3
    i_49 = 0
    i_49
    while (i_49 < 16) {
        j_7 = 0
        j_7
        while (j_7 < 16) {
            tmp_41 = a_8 + b_1 * j_7 - 7 + c_3 * i_49 - 7 + 16 >> 5
            tmp_41
            var c2da_fresh46_h264bsd : int = 0
            if (tmp_41 > 255) {
                c2da_fresh46_h264bsd = 255
            } else {
                c2da_fresh46_h264bsd = tmp_41
            }
            var c2da_fresh47_h264bsd : int = 0
            if (tmp_41 < 0) {
                c2da_fresh47_h264bsd = 0
            } else {
                c2da_fresh47_h264bsd = c2da_fresh46_h264bsd
            }
            unsafe(data_24[i_49 * 16 + j_7]) = uint8(uint8(c2da_fresh47_h264bsd))
            unsafe(data_24[i_49 * 16 + j_7])
            j_7 = j_7 + 1
        }
        i_49 = i_49 + 1
    }
}
[export]
def Intra16x16DcPrediction(var data_25 : uint8?; var above_14 : uint8?; var left_16 : uint8?; var availableA_4 : uint; var availableB_4 : uint) {
    var i_50 : uint
    var tmp_42 : uint
    if (availableA_4 != 0x0 && availableB_4 != 0x0) {
        tmp_42 = uint(uint(0))
        tmp_42
        while (i_50 < uint(16)) {
            tmp_42 = uint(tmp_42 + uint(int(unsafe(above_14[i_50])) + int(unsafe(left_16[i_50]))))
            tmp_42
            i_50 = i_50 + 1
        }
        tmp_42 = uint(uint(tmp_42 + uint(16)) >> uint(uint(5)))
        tmp_42
    } else {
        if (availableA_4 != 0x0) {
            tmp_42 = uint(uint(0))
            tmp_42
            while (i_50 < uint(16)) {
                tmp_42 = uint(tmp_42 + uint(unsafe(left_16[i_50])))
                tmp_42
                i_50 = i_50 + 1
            }
            tmp_42 = uint(uint(tmp_42 + uint(8)) >> uint(uint(4)))
            tmp_42
        } else {
            if (availableB_4 != 0x0) {
                tmp_42 = uint(uint(0))
                tmp_42
                while (i_50 < uint(16)) {
                    tmp_42 = uint(tmp_42 + uint(unsafe(above_14[i_50])))
                    tmp_42
                    i_50 = i_50 + 1
                }
                tmp_42 = uint(uint(tmp_42 + uint(8)) >> uint(uint(4)))
                tmp_42
            } else {
                tmp_42 = uint(uint(128))
                tmp_42
            }
        }
    }
    i_50 = uint(uint(0))
    i_50
    while (i_50 < uint(256)) {
        unsafe(data_25[i_50]) = uint8(uint8(tmp_42))
        unsafe(data_25[i_50])
        i_50 = i_50 + 1
    }
}
[export]
def Intra16x16HorizontalPrediction(var data_26 : uint8?; var left_17 : uint8?) {
    var i_51 : uint
    var j_8 : uint
    i_51 = uint(uint(0))
    i_51
    while (i_51 < uint(16)) {
        j_8 = uint(uint(0))
        j_8
        while (j_8 < uint(16)) {
            data_26 = data_26 + 1
            *data_26 = uint8(unsafe(left_17[i_51]))
            *data_26
            j_8 = j_8 + 1
        }
        i_51 = i_51 + 1
    }
}
[export]
def Intra16x16VerticalPrediction(var data_27 : uint8?; var above_15 : uint8?) {
    var i_52 : uint
    var j_9 : uint
    i_52 = uint(uint(0))
    i_52
    while (i_52 < uint(16)) {
        j_9 = uint(uint(0))
        j_9
        while (j_9 < uint(16)) {
            data_27 = data_27 + 1
            *data_27 = uint8(unsafe(above_15[j_9]))
            *data_27
            j_9 = j_9 + 1
        }
        i_52 = i_52 + 1
    }
}
[export]
def h264bsdPredModeIntra16x16(var mbType_6 : mbType_e) : uint {
    var tmp_43 : uint
    tmp_43 = uint(uint(mbType_6) - uint(I_16x16_0_0_0))
    tmp_43
    return tmp_43 & uint(3)
}
[export]
def h264bsdGetNeighbourPels(var image_4 : image_t?; var above_16 : uint8?; var left_18 : uint8?; var mbNum_4 : uint) {
    var i_53 : uint
    var width_16 : uint
    var picSize_1 : uint
    var ptr_0 : uint8?
    var tmp_44 : uint8?
    var row_2 : uint
    var col_2 : uint
    if (mbNum_4 == 0) {
        return
    }
    width_16 = uint(image_4.width)
    width_16
    picSize_1 = uint(width_16 * image_4.height)
    picSize_1
    row_2 = uint(mbNum_4 / width_16)
    row_2
    col_2 = uint(mbNum_4 - row_2 * width_16)
    col_2
    width_16 = uint(width_16 * uint(16))
    width_16
    ptr_0 = unsafe(unsafe(image_4.data + row_2 * uint(16) * width_16) + col_2 * uint(16))
    ptr_0
    if (row_2 != 0x0) {
        tmp_44 = unsafe(ptr_0 - width_16 + uint(1))
        tmp_44
        i_53 = uint(uint(21))
        i_53
        while (i_53 != 0x0) {
            above_16 = above_16 + 1
            tmp_44 = tmp_44 + 1
            *above_16 = uint8(*tmp_44)
            *above_16
        }
    }
    if (col_2 != 0x0) {
        ptr_0 = ptr_0 - 1
        ptr_0
        i_53 = uint(uint(16))
        i_53
        while (i_53 != 0x0) {
            left_18 = left_18 + 1
            *left_18 = uint8(*ptr_0)
            *left_18
            ptr_0 = ptr_0 + width_16
        }
    }
    width_16 = uint(width_16 >> 1)
    width_16
    ptr_0 = unsafe(unsafe(unsafe(image_4.data + picSize_1 * uint(256)) + row_2 * uint(8) * width_16) + col_2 * uint(8))
    ptr_0
    if (row_2 != 0x0) {
        tmp_44 = unsafe(ptr_0 - width_16 + uint(1))
        tmp_44
        i_53 = uint(uint(9))
        i_53
        while (i_53 != 0x0) {
            above_16 = above_16 + 1
            tmp_44 = tmp_44 + 1
            *above_16 = uint8(*tmp_44)
            *above_16
        }
        tmp_44 = tmp_44 + picSize_1 * uint(64) - uint(9)
        tmp_44
        i_53 = uint(uint(9))
        i_53
        while (i_53 != 0x0) {
            above_16 = above_16 + 1
            tmp_44 = tmp_44 + 1
            *above_16 = uint8(*tmp_44)
            *above_16
        }
    }
    if (col_2 != 0x0) {
        ptr_0 = ptr_0 - 1
        ptr_0
        i_53 = uint(uint(8))
        i_53
        while (i_53 != 0x0) {
            left_18 = left_18 + 1
            *left_18 = uint8(*ptr_0)
            *left_18
            ptr_0 = ptr_0 + width_16
        }
        ptr_0 = ptr_0 + picSize_1 * uint(64) - uint(8) * width_16
        ptr_0
        i_53 = uint(uint(8))
        i_53
        while (i_53 != 0x0) {
            left_18 = left_18 + 1
            *left_18 = uint8(*ptr_0)
            *left_18
            ptr_0 = ptr_0 + width_16
        }
    }
}
[export]
def ProcessResidual(var pMb_16 : mbStorage_t?; var residualLevel : array<int>?; var coeffMap : uint?) : uint {
    var i_54 : uint
    var chromaQp : uint
    var blockData : array<int>?
    var blockDc : array<int>?
    var totalCoeff_1 : int?
    var chromaDc : int?
    var dcCoeffIdx : uint const?
    blockDc = unsafe(residualLevel + 24)
    blockDc
    blockData = residualLevel
    blockData
    totalCoeff_1 = unsafe(addr(pMb_16.totalCoeff[0]))
    totalCoeff_1
    if (uint(h264bsdMbPartPredMode(pMb_16.mbType)) == uint(PRED_MODE_INTRA16x16)) {
        if (unsafe(totalCoeff_1[24]) != 0) {
            h264bsdProcessLumaDc(unsafe(addr(*blockDc[0])), pMb_16.qpY)
        }
        dcCoeffIdx = unsafe(addr(dcCoeffIndex[0]))
        dcCoeffIdx
        i_54 = uint(uint(16))
        i_54
        while (i_54 != 0x0) {
            dcCoeffIdx = dcCoeffIdx + 1
            unsafe(unsafe(addr(*blockData[0]))[0]) = unsafe(unsafe(addr(*blockDc[0]))[*dcCoeffIdx])
            unsafe(unsafe(addr(*blockData[0]))[0])
            if (unsafe(unsafe(addr(*blockData[0]))[0]) != 0 || *totalCoeff_1 != 0) {
                if (h264bsdProcessBlock(unsafe(addr(*blockData[0])), pMb_16.qpY, uint(1), *coeffMap) != uint(0)) {
                    return uint(1)
                }
            } else {
                unsafe(unsafe(addr(*blockData[0]))[0]) = 16777215
                unsafe(unsafe(addr(*blockData[0]))[0])
            }
            coeffMap = coeffMap + 1
        }
    } else {
        i_54 = uint(uint(16))
        i_54
        while (i_54 != 0x0) {
            if (*totalCoeff_1 != 0) {
                if (h264bsdProcessBlock(unsafe(addr(*blockData[0])), pMb_16.qpY, uint(0), *coeffMap) != uint(0)) {
                    return uint(1)
                }
            } else {
                unsafe(unsafe(addr(*blockData[0]))[0]) = 16777215
                unsafe(unsafe(addr(*blockData[0]))[0])
            }
            coeffMap = coeffMap + 1
        }
    }
    var c2da_fresh48_h264bsd : int = 0
    if (int(pMb_16.qpY) + pMb_16.chromaQpIndexOffset > 51) {
        c2da_fresh48_h264bsd = 51
    } else {
        c2da_fresh48_h264bsd = int(pMb_16.qpY) + pMb_16.chromaQpIndexOffset
    }
    var c2da_fresh49_h264bsd : int = 0
    if (int(pMb_16.qpY) + pMb_16.chromaQpIndexOffset < 0) {
        c2da_fresh49_h264bsd = 0
    } else {
        c2da_fresh49_h264bsd = c2da_fresh48_h264bsd
    }
    chromaQp = uint(unsafe(unsafe(addr(h264bsdQpC[0]))[c2da_fresh49_h264bsd]))
    chromaQp
    if (unsafe(unsafe(addr(pMb_16.totalCoeff[0]))[25]) != 0 || unsafe(unsafe(addr(pMb_16.totalCoeff[0]))[26]) != 0) {
        h264bsdProcessChromaDc(unsafe(addr(unsafe(residualLevel[25])[0])), chromaQp)
    }
    chromaDc = unsafe(addr(unsafe(residualLevel[25])[0]))
    chromaDc
    i_54 = uint(uint(8))
    i_54
    while (i_54 != 0x0) {
        chromaDc = chromaDc + 1
        unsafe(unsafe(addr(*blockData[0]))[0]) = *chromaDc
        unsafe(unsafe(addr(*blockData[0]))[0])
        if (unsafe(unsafe(addr(*blockData[0]))[0]) != 0 || *totalCoeff_1 != 0) {
            if (h264bsdProcessBlock(unsafe(addr(*blockData[0])), chromaQp, uint(1), *coeffMap) != uint(0)) {
                return uint(1)
            }
        } else {
            unsafe(unsafe(addr(*blockData[0]))[0]) = 16777215
            unsafe(unsafe(addr(*blockData[0]))[0])
        }
        coeffMap = coeffMap + 1
    }
    return uint(0)
}
[export]
def h264bsdProcessBlock(var data_28 : int?; var qp : uint; var skip : uint; var coeffMap_0 : uint) : uint {
    var tmp0 : int
    var tmp1_14 : int
    var tmp2_14 : int
    var tmp3_12 : int
    var d1 : int
    var d2 : int
    var d3 : int
    var row_3 : uint
    var col_3 : uint
    var qpDiv : uint
    var ptr_1 : int?
    qpDiv = uint(uint(unsafe(unsafe(addr(qpDiv6[0]))[qp])))
    qpDiv
    tmp1_14 = int(unsafe(unsafe(addr(unsafe(unsafe(addr(levelScale[0]))[unsafe(unsafe(addr(qpMod6[0]))[qp])])[0]))[0])) << int(int(qpDiv))
    tmp1_14
    tmp2_14 = int(unsafe(unsafe(addr(unsafe(unsafe(addr(levelScale[0]))[unsafe(unsafe(addr(qpMod6[0]))[qp])])[0]))[1])) << int(int(qpDiv))
    tmp2_14
    tmp3_12 = int(unsafe(unsafe(addr(unsafe(unsafe(addr(levelScale[0]))[unsafe(unsafe(addr(qpMod6[0]))[qp])])[0]))[2])) << int(int(qpDiv))
    tmp3_12
    if (skip == 0) {
        unsafe(data_28[0]) = unsafe(data_28[0]) * tmp1_14
        unsafe(data_28[0])
    }
    if (coeffMap_0 & uint(65436) != 0x0) {
        d1 = unsafe(data_28[1])
        d1
        d2 = unsafe(data_28[14])
        d2
        d3 = unsafe(data_28[15])
        d3
        unsafe(data_28[1]) = d1 * tmp2_14
        unsafe(data_28[1])
        unsafe(data_28[14]) = d2 * tmp2_14
        unsafe(data_28[14])
        unsafe(data_28[15]) = d3 * tmp3_12
        unsafe(data_28[15])
        d1 = unsafe(data_28[2])
        d1
        d2 = unsafe(data_28[5])
        d2
        d3 = unsafe(data_28[4])
        d3
        unsafe(data_28[4]) = d1 * tmp2_14
        unsafe(data_28[4])
        unsafe(data_28[2]) = d2 * tmp1_14
        unsafe(data_28[2])
        unsafe(data_28[5]) = d3 * tmp3_12
        unsafe(data_28[5])
        d1 = unsafe(data_28[8])
        d1
        d2 = unsafe(data_28[3])
        d2
        d3 = unsafe(data_28[6])
        d3
        tmp0 = d1 * tmp2_14
        tmp0
        unsafe(data_28[8]) = d2 * tmp1_14
        unsafe(data_28[8])
        unsafe(data_28[3]) = d3 * tmp2_14
        unsafe(data_28[3])
        d1 = unsafe(data_28[7])
        d1
        d2 = unsafe(data_28[12])
        d2
        d3 = unsafe(data_28[9])
        d3
        unsafe(data_28[6]) = d1 * tmp2_14
        unsafe(data_28[6])
        unsafe(data_28[7]) = d2 * tmp3_12
        unsafe(data_28[7])
        unsafe(data_28[12]) = d3 * tmp2_14
        unsafe(data_28[12])
        unsafe(data_28[9]) = tmp0
        unsafe(data_28[9])
        d1 = unsafe(data_28[10])
        d1
        d2 = unsafe(data_28[11])
        d2
        d3 = unsafe(data_28[13])
        d3
        unsafe(data_28[13]) = d1 * tmp3_12
        unsafe(data_28[13])
        unsafe(data_28[10]) = d2 * tmp1_14
        unsafe(data_28[10])
        unsafe(data_28[11]) = d3 * tmp2_14
        unsafe(data_28[11])
        ptr_1 = data_28
        ptr_1
        while (row_3 != 0x0) {
            tmp0 = unsafe(ptr_1[0]) + unsafe(ptr_1[2])
            tmp0
            tmp1_14 = unsafe(ptr_1[0]) - unsafe(ptr_1[2])
            tmp1_14
            tmp2_14 = unsafe(ptr_1[1]) >> 1 - unsafe(ptr_1[3])
            tmp2_14
            tmp3_12 = unsafe(ptr_1[1]) + unsafe(ptr_1[3]) >> 1
            tmp3_12
            unsafe(ptr_1[0]) = tmp0 + tmp3_12
            unsafe(ptr_1[0])
            unsafe(ptr_1[1]) = tmp1_14 + tmp2_14
            unsafe(ptr_1[1])
            unsafe(ptr_1[2]) = tmp1_14 - tmp2_14
            unsafe(ptr_1[2])
            unsafe(ptr_1[3]) = tmp0 - tmp3_12
            unsafe(ptr_1[3])
            ptr_1 = ptr_1 + 4
        }
        col_3 = uint(uint(4))
        col_3
        while (col_3 != 0x0) {
            tmp0 = unsafe(data_28[0]) + unsafe(data_28[8])
            tmp0
            tmp1_14 = unsafe(data_28[0]) - unsafe(data_28[8])
            tmp1_14
            tmp2_14 = unsafe(data_28[4]) >> 1 - unsafe(data_28[12])
            tmp2_14
            tmp3_12 = unsafe(data_28[4]) + unsafe(data_28[12]) >> 1
            tmp3_12
            unsafe(data_28[0]) = tmp0 + tmp3_12 + 32 >> 6
            unsafe(data_28[0])
            unsafe(data_28[4]) = tmp1_14 + tmp2_14 + 32 >> 6
            unsafe(data_28[4])
            unsafe(data_28[8]) = tmp1_14 - tmp2_14 + 32 >> 6
            unsafe(data_28[8])
            unsafe(data_28[12]) = tmp0 - tmp3_12 + 32 >> 6
            unsafe(data_28[12])
            if (uint(unsafe(data_28[0]) + 512) > uint(1023) || uint(unsafe(data_28[4]) + 512) > uint(1023) || uint(unsafe(data_28[8]) + 512) > uint(1023) || uint(unsafe(data_28[12]) + 512) > uint(1023)) {
                return uint(1)
            }
            data_28 = data_28 + 1
        }
    } else {
        if (coeffMap_0 & uint(98) == uint(0)) {
            tmp0 = unsafe(data_28[0]) + 32 >> 6
            tmp0
            if (uint(tmp0 + 512) > uint(1023)) {
                return uint(1)
            }
            unsafe(data_28[15]) = tmp0
            unsafe(data_28[14]) = unsafe(data_28[15])
            unsafe(data_28[13]) = unsafe(data_28[14])
            unsafe(data_28[12]) = unsafe(data_28[13])
            unsafe(data_28[11]) = unsafe(data_28[12])
            unsafe(data_28[10]) = unsafe(data_28[11])
            unsafe(data_28[9]) = unsafe(data_28[10])
            unsafe(data_28[8]) = unsafe(data_28[9])
            unsafe(data_28[7]) = unsafe(data_28[8])
            unsafe(data_28[6]) = unsafe(data_28[7])
            unsafe(data_28[5]) = unsafe(data_28[6])
            unsafe(data_28[4]) = unsafe(data_28[5])
            unsafe(data_28[3]) = unsafe(data_28[4])
            unsafe(data_28[2]) = unsafe(data_28[3])
            unsafe(data_28[1]) = unsafe(data_28[2])
            unsafe(data_28[0]) = unsafe(data_28[1])
            unsafe(data_28[0])
        } else {
            unsafe(data_28[1]) = unsafe(data_28[1]) * tmp2_14
            unsafe(data_28[1])
            unsafe(data_28[2]) = unsafe(data_28[5]) * tmp1_14
            unsafe(data_28[2])
            unsafe(data_28[3]) = unsafe(data_28[6]) * tmp2_14
            unsafe(data_28[3])
            tmp0 = unsafe(data_28[0]) + unsafe(data_28[2])
            tmp0
            tmp1_14 = unsafe(data_28[0]) - unsafe(data_28[2])
            tmp1_14
            tmp2_14 = unsafe(data_28[1]) >> 1 - unsafe(data_28[3])
            tmp2_14
            tmp3_12 = unsafe(data_28[1]) + unsafe(data_28[3]) >> 1
            tmp3_12
            unsafe(data_28[0]) = tmp0 + tmp3_12 + 32 >> 6
            unsafe(data_28[0])
            unsafe(data_28[1]) = tmp1_14 + tmp2_14 + 32 >> 6
            unsafe(data_28[1])
            unsafe(data_28[2]) = tmp1_14 - tmp2_14 + 32 >> 6
            unsafe(data_28[2])
            unsafe(data_28[3]) = tmp0 - tmp3_12 + 32 >> 6
            unsafe(data_28[3])
            unsafe(data_28[12]) = unsafe(data_28[0])
            unsafe(data_28[8]) = unsafe(data_28[12])
            unsafe(data_28[4]) = unsafe(data_28[8])
            unsafe(data_28[4])
            unsafe(data_28[13]) = unsafe(data_28[1])
            unsafe(data_28[9]) = unsafe(data_28[13])
            unsafe(data_28[5]) = unsafe(data_28[9])
            unsafe(data_28[5])
            unsafe(data_28[14]) = unsafe(data_28[2])
            unsafe(data_28[10]) = unsafe(data_28[14])
            unsafe(data_28[6]) = unsafe(data_28[10])
            unsafe(data_28[6])
            unsafe(data_28[15]) = unsafe(data_28[3])
            unsafe(data_28[11]) = unsafe(data_28[15])
            unsafe(data_28[7]) = unsafe(data_28[11])
            unsafe(data_28[7])
            if (uint(unsafe(data_28[0]) + 512) > uint(1023) || uint(unsafe(data_28[1]) + 512) > uint(1023) || uint(unsafe(data_28[2]) + 512) > uint(1023) || uint(unsafe(data_28[3]) + 512) > uint(1023)) {
                return uint(1)
            }
        }
    }
    return uint(0)
}
var qpMod6 : array<uint8> const = [uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(0), uint8(1), uint8(2), uint8(3), uint8(4), uint8(5), uint8(0), uint8(1), uint8(2), uint8(3)]

var levelScale : array<array<int>> const = [[10, 13, 16], [11, 14, 18], [13, 16, 20], [14, 18, 23], [16, 20, 25], [18, 23, 29]]

var qpDiv6 : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(1), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(2), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(3), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(4), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(5), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(6), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(7), uint8(8), uint8(8), uint8(8), uint8(8)]

[export]
def h264bsdProcessChromaDc(var data_29 : int?; var qp_0 : uint) {
    var tmp0_0 : int
    var tmp1_15 : int
    var tmp2_15 : int
    var tmp3_13 : int
    var qpDiv_0 : uint
    var levScale : int
    var levShift : uint
    qpDiv_0 = uint(uint(unsafe(unsafe(addr(qpDiv6[0]))[qp_0])))
    qpDiv_0
    levScale = unsafe(unsafe(addr(unsafe(unsafe(addr(levelScale[0]))[unsafe(unsafe(addr(qpMod6[0]))[qp_0])])[0]))[0])
    levScale
    if (qp_0 >= uint(6)) {
        levScale = levScale << qpDiv_0 - uint(1)
        levScale
        levShift = uint(uint(0))
        levShift
    } else {
        levShift = uint(uint(1))
        levShift
    }
    tmp0_0 = unsafe(data_29[0]) + unsafe(data_29[2])
    tmp0_0
    tmp1_15 = unsafe(data_29[0]) - unsafe(data_29[2])
    tmp1_15
    tmp2_15 = unsafe(data_29[1]) - unsafe(data_29[3])
    tmp2_15
    tmp3_13 = unsafe(data_29[1]) + unsafe(data_29[3])
    tmp3_13
    unsafe(data_29[0]) = int(tmp0_0 + tmp3_13 * levScale) >> int(int(levShift))
    unsafe(data_29[0])
    unsafe(data_29[1]) = int(tmp0_0 - tmp3_13 * levScale) >> int(int(levShift))
    unsafe(data_29[1])
    unsafe(data_29[2]) = int(tmp1_15 + tmp2_15 * levScale) >> int(int(levShift))
    unsafe(data_29[2])
    unsafe(data_29[3]) = int(tmp1_15 - tmp2_15 * levScale) >> int(int(levShift))
    unsafe(data_29[3])
    tmp0_0 = unsafe(data_29[4]) + unsafe(data_29[6])
    tmp0_0
    tmp1_15 = unsafe(data_29[4]) - unsafe(data_29[6])
    tmp1_15
    tmp2_15 = unsafe(data_29[5]) - unsafe(data_29[7])
    tmp2_15
    tmp3_13 = unsafe(data_29[5]) + unsafe(data_29[7])
    tmp3_13
    unsafe(data_29[4]) = int(tmp0_0 + tmp3_13 * levScale) >> int(int(levShift))
    unsafe(data_29[4])
    unsafe(data_29[5]) = int(tmp0_0 - tmp3_13 * levScale) >> int(int(levShift))
    unsafe(data_29[5])
    unsafe(data_29[6]) = int(tmp1_15 + tmp2_15 * levScale) >> int(int(levShift))
    unsafe(data_29[6])
    unsafe(data_29[7]) = int(tmp1_15 - tmp2_15 * levScale) >> int(int(levShift))
    unsafe(data_29[7])
}
var dcCoeffIndex : array<uint> const = [uint(0), uint(1), uint(4), uint(5), uint(2), uint(3), uint(6), uint(7), uint(8), uint(9), uint(12), uint(13), uint(10), uint(11), uint(14), uint(15)]

[export]
def h264bsdProcessLumaDc(var data_30 : int?; var qp_1 : uint) {
    var tmp0_1 : int
    var tmp1_16 : int
    var tmp2_16 : int
    var tmp3_14 : int
    var row_4 : uint
    var col_4 : uint
    var qpMod : uint
    var qpDiv_1 : uint
    var levScale_0 : int
    var ptr_2 : int?
    qpMod = uint(uint(unsafe(unsafe(addr(qpMod6[0]))[qp_1])))
    qpMod
    qpDiv_1 = uint(uint(unsafe(unsafe(addr(qpDiv6[0]))[qp_1])))
    qpDiv_1
    tmp0_1 = unsafe(data_30[2])
    tmp0_1
    unsafe(data_30[2]) = unsafe(data_30[5])
    unsafe(data_30[2])
    unsafe(data_30[5]) = unsafe(data_30[4])
    unsafe(data_30[5])
    unsafe(data_30[4]) = tmp0_1
    unsafe(data_30[4])
    tmp0_1 = unsafe(data_30[8])
    tmp0_1
    unsafe(data_30[8]) = unsafe(data_30[3])
    unsafe(data_30[8])
    unsafe(data_30[3]) = unsafe(data_30[6])
    unsafe(data_30[3])
    unsafe(data_30[6]) = unsafe(data_30[7])
    unsafe(data_30[6])
    unsafe(data_30[7]) = unsafe(data_30[12])
    unsafe(data_30[7])
    unsafe(data_30[12]) = unsafe(data_30[9])
    unsafe(data_30[12])
    unsafe(data_30[9]) = tmp0_1
    unsafe(data_30[9])
    tmp0_1 = unsafe(data_30[10])
    tmp0_1
    unsafe(data_30[10]) = unsafe(data_30[11])
    unsafe(data_30[10])
    unsafe(data_30[11]) = unsafe(data_30[13])
    unsafe(data_30[11])
    unsafe(data_30[13]) = tmp0_1
    unsafe(data_30[13])
    ptr_2 = data_30
    ptr_2
    while (row_4 != 0x0) {
        tmp0_1 = unsafe(ptr_2[0]) + unsafe(ptr_2[2])
        tmp0_1
        tmp1_16 = unsafe(ptr_2[0]) - unsafe(ptr_2[2])
        tmp1_16
        tmp2_16 = unsafe(ptr_2[1]) - unsafe(ptr_2[3])
        tmp2_16
        tmp3_14 = unsafe(ptr_2[1]) + unsafe(ptr_2[3])
        tmp3_14
        unsafe(ptr_2[0]) = tmp0_1 + tmp3_14
        unsafe(ptr_2[0])
        unsafe(ptr_2[1]) = tmp1_16 + tmp2_16
        unsafe(ptr_2[1])
        unsafe(ptr_2[2]) = tmp1_16 - tmp2_16
        unsafe(ptr_2[2])
        unsafe(ptr_2[3]) = tmp0_1 - tmp3_14
        unsafe(ptr_2[3])
        ptr_2 = ptr_2 + 4
    }
    levScale_0 = unsafe(unsafe(addr(unsafe(unsafe(addr(levelScale[0]))[qpMod])[0]))[0])
    levScale_0
    if (qp_1 >= uint(12)) {
        levScale_0 = levScale_0 << qpDiv_1 - uint(2)
        levScale_0
        col_4 = uint(uint(4))
        col_4
        while (col_4 != 0x0) {
            tmp0_1 = unsafe(data_30[0]) + unsafe(data_30[8])
            tmp0_1
            tmp1_16 = unsafe(data_30[0]) - unsafe(data_30[8])
            tmp1_16
            tmp2_16 = unsafe(data_30[4]) - unsafe(data_30[12])
            tmp2_16
            tmp3_14 = unsafe(data_30[4]) + unsafe(data_30[12])
            tmp3_14
            unsafe(data_30[0]) = tmp0_1 + tmp3_14 * levScale_0
            unsafe(data_30[0])
            unsafe(data_30[4]) = tmp1_16 + tmp2_16 * levScale_0
            unsafe(data_30[4])
            unsafe(data_30[8]) = tmp1_16 - tmp2_16 * levScale_0
            unsafe(data_30[8])
            unsafe(data_30[12]) = tmp0_1 - tmp3_14 * levScale_0
            unsafe(data_30[12])
            data_30 = data_30 + 1
        }
    } else {
        var tmp_45 : int
        var c2da_fresh50_h264bsd : int = 0
        if (uint(1) - qpDiv_1 == uint(0)) {
            c2da_fresh50_h264bsd = 1
        } else {
            c2da_fresh50_h264bsd = 2
        }
        tmp_45 = c2da_fresh50_h264bsd
        tmp_45
        col_4 = uint(uint(4))
        col_4
        while (col_4 != 0x0) {
            tmp0_1 = unsafe(data_30[0]) + unsafe(data_30[8])
            tmp0_1
            tmp1_16 = unsafe(data_30[0]) - unsafe(data_30[8])
            tmp1_16
            tmp2_16 = unsafe(data_30[4]) - unsafe(data_30[12])
            tmp2_16
            tmp3_14 = unsafe(data_30[4]) + unsafe(data_30[12])
            tmp3_14
            unsafe(data_30[0]) = int(tmp0_1 + tmp3_14 * levScale_0 + tmp_45) >> int(int(uint(2) - qpDiv_1))
            unsafe(data_30[0])
            unsafe(data_30[4]) = int(tmp1_16 + tmp2_16 * levScale_0 + tmp_45) >> int(int(uint(2) - qpDiv_1))
            unsafe(data_30[4])
            unsafe(data_30[8]) = int(tmp1_16 - tmp2_16 * levScale_0 + tmp_45) >> int(int(uint(2) - qpDiv_1))
            unsafe(data_30[8])
            unsafe(data_30[12]) = int(tmp0_1 - tmp3_14 * levScale_0 + tmp_45) >> int(int(uint(2) - qpDiv_1))
            unsafe(data_30[12])
            data_30 = data_30 + 1
        }
    }
}
[export]
def h264bsdDecodePicOrderCnt(var poc : pocStorage_t?; var sps : seqParamSet_t?; var pSliceHeader_0 : sliceHeader_t?; var pNalUnit_1 : nalUnit_t?) : int {
    var i_55 : uint
    var picOrderCnt_2 : int
    var frameNumOffset : uint
    var absFrameNum : uint
    var picOrderCntCycleCnt : uint
    var frameNumInPicOrderCntCycle : uint
    var expectedDeltaPicOrderCntCycle : int
    var containsMmco5 : uint
    containsMmco5 = uint(uint(0))
    containsMmco5
    if (pSliceHeader_0.decRefPicMarking.adaptiveRefPicMarkingModeFlag != 0x0) {
        i_55 = uint(uint(0))
        i_55
        while (unsafe(unsafe(addr(pSliceHeader_0.decRefPicMarking.operation[0]))[i_55]).memoryManagementControlOperation != 0x0) {
            if (unsafe(unsafe(addr(pSliceHeader_0.decRefPicMarking.operation[0]))[i_55]).memoryManagementControlOperation == uint(5)) {
                containsMmco5 = uint(uint(1))
                containsMmco5
                break
            }
            i_55 = i_55 + 1
            i_55
        }
    }
    if (sps.picOrderCntType == uint(0)) {
        if (uint(pNalUnit_1.nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
            poc.prevPicOrderCntMsb = 0
            poc.prevPicOrderCntMsb
            poc.prevPicOrderCntLsb = uint(uint(0))
            poc.prevPicOrderCntLsb
        }
    } elif (sps.picOrderCntType == uint(1)) {
        if (uint(pNalUnit_1.nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
            frameNumOffset = uint(uint(0))
            frameNumOffset
        } else {
            if (poc.prevFrameNum > pSliceHeader_0.frameNum) {
                frameNumOffset = uint(poc.prevFrameNumOffset + sps.maxFrameNum)
                frameNumOffset
            } else {
                frameNumOffset = uint(poc.prevFrameNumOffset)
                frameNumOffset
            }
        }
    } else {
        if (uint(pNalUnit_1.nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
            frameNumOffset = uint(uint(0))
            frameNumOffset
        } else {
            if (poc.prevFrameNum > pSliceHeader_0.frameNum) {
                frameNumOffset = uint(poc.prevFrameNumOffset + sps.maxFrameNum)
                frameNumOffset
            } else {
                frameNumOffset = uint(poc.prevFrameNumOffset)
                frameNumOffset
            }
        }
    }
    return picOrderCnt_2
}
[export]
def h264bsdInitStorage(var pStorage : storage_t?) {
    memset(unsafe(unsafe(reinterpret<uint64>(pStorage))), 0, 4)
    pStorage.activeSpsId = uint(uint(32))
    pStorage.activeSpsId
    pStorage.activePpsId = uint(uint(256))
    pStorage.activePpsId
    unsafe(addr(pStorage.aub[0])).firstCallFlag = uint(uint(1))
    unsafe(addr(pStorage.aub[0])).firstCallFlag
}
[export]
def h264bsdResetStorage(var pStorage_0 : storage_t?) {
    var i_56 : uint
    unsafe(addr(pStorage_0.slice[0])).numDecodedMbs = uint(uint(0))
    unsafe(addr(pStorage_0.slice[0])).numDecodedMbs
    unsafe(addr(pStorage_0.slice[0])).sliceId = uint(uint(0))
    unsafe(addr(pStorage_0.slice[0])).sliceId
    i_56 = uint(uint(0))
    i_56
    while (i_56 < pStorage_0.picSizeInMbs) {
        unsafe(pStorage_0.mb[i_56]).sliceId = uint(uint(0))
        unsafe(pStorage_0.mb[i_56]).sliceId
        unsafe(pStorage_0.mb[i_56]).decoded = uint(uint(0))
        unsafe(pStorage_0.mb[i_56]).decoded
        i_56 = i_56 + 1
    }
}
[export]
def h264bsdIsStartOfPicture(var pStorage_1 : storage_t?) : uint {
    if (pStorage_1.validSliceInAccessUnit == uint(0)) {
        return uint(1)
    } else {
        return uint(0)
    }
}
[export]
def h264bsdIsEndOfPicture(var pStorage_2 : storage_t?) : uint {
    var i_57 : uint
    var tmp_46 : uint
    if (unsafe(unsafe(addr(pStorage_2.sliceHeader[0]))[0]).redundantPicCnt == 0) {
        if (unsafe(addr(pStorage_2.slice[0])).numDecodedMbs == pStorage_2.picSizeInMbs) {
            return uint(1)
        }
    } else {
        tmp_46 = uint(uint(0))
        tmp_46
        while (i_57 < pStorage_2.picSizeInMbs) {
            var c2da_fresh51_h264bsd : int = 0
            if (unsafe(pStorage_2.mb[i_57]).decoded) {
                c2da_fresh51_h264bsd = 1
            } else {
                c2da_fresh51_h264bsd = 0
            }
            tmp_46 = uint(tmp_46 + uint(c2da_fresh51_h264bsd))
            tmp_46
            i_57 = i_57 + 1
        }
        if (tmp_46 == pStorage_2.picSizeInMbs) {
            return uint(1)
        }
    }
    return uint(0)
}
[export]
def h264bsdStoreSeqParamSet(var pStorage_3 : storage_t?; var pSeqParamSet_6 : seqParamSet_t?) : uint {
    var id : uint
    id = uint(pSeqParamSet_6.seqParameterSetId)
    id
    if (unsafe(unsafe(addr(pStorage_3.sps[0]))[id]) == unsafe(unsafe(reinterpret<seqParamSet_t?>(uint64(0))))) {
        unsafe(unsafe(addr(pStorage_3.sps[0]))[id]) = unsafe(unsafe(reinterpret<seqParamSet_t?>(malloc(uint64(1) * 4))))
        unsafe(unsafe(addr(pStorage_3.sps[0]))[id])
        if (unsafe(unsafe(addr(pStorage_3.sps[0]))[id]) == unsafe(unsafe(reinterpret<seqParamSet_t?>(uint64(0))))) {
            return uint(65535)
        }
    } else {
        if (id == pStorage_3.activeSpsId) {
            if (h264bsdCompareSeqParamSets(pSeqParamSet_6, pStorage_3.activeSps) != uint(0)) {
                free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).offsetForRefFrame))))
                unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).offsetForRefFrame = null
                unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).offsetForRefFrame
                free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).vuiParameters))))
                unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).vuiParameters = null
                unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).vuiParameters
                pStorage_3.activeSpsId = uint(uint(32 + 1))
                pStorage_3.activeSpsId
                pStorage_3.activePpsId = uint(uint(256 + 1))
                pStorage_3.activePpsId
                pStorage_3.activeSps = null
                pStorage_3.activeSps
                pStorage_3.activePps = null
                pStorage_3.activePps
            } else {
                free(unsafe(unsafe(reinterpret<uint64>(pSeqParamSet_6.offsetForRefFrame))))
                pSeqParamSet_6.offsetForRefFrame = null
                pSeqParamSet_6.offsetForRefFrame
                free(unsafe(unsafe(reinterpret<uint64>(pSeqParamSet_6.vuiParameters))))
                pSeqParamSet_6.vuiParameters = null
                pSeqParamSet_6.vuiParameters
                return uint(0)
            }
        } else {
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).offsetForRefFrame))))
            unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).offsetForRefFrame = null
            unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).offsetForRefFrame
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).vuiParameters))))
            unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).vuiParameters = null
            unsafe(unsafe(addr(pStorage_3.sps[0]))[id]).vuiParameters
        }
    }
    *unsafe(unsafe(addr(pStorage_3.sps[0]))[id]) = *pSeqParamSet_6
    *unsafe(unsafe(addr(pStorage_3.sps[0]))[id])
    return uint(0)
}
[export]
def h264bsdStorePicParamSet(var pStorage_4 : storage_t?; var pPicParamSet_3 : picParamSet_t?) : uint {
    var id_0 : uint
    id_0 = uint(pPicParamSet_3.picParameterSetId)
    id_0
    if (unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]) == unsafe(unsafe(reinterpret<picParamSet_t?>(uint64(0))))) {
        unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]) = unsafe(unsafe(reinterpret<picParamSet_t?>(malloc(uint64(1) * 4))))
        unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0])
        if (unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]) == unsafe(unsafe(reinterpret<picParamSet_t?>(uint64(0))))) {
            return uint(65535)
        }
    } else {
        if (id_0 == pStorage_4.activePpsId) {
            if (pPicParamSet_3.seqParameterSetId != pStorage_4.activeSpsId) {
                pStorage_4.activePpsId = uint(uint(256 + 1))
                pStorage_4.activePpsId
            }
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).runLength))))
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).runLength = null
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).runLength
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).topLeft))))
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).topLeft = null
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).topLeft
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).bottomRight))))
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).bottomRight = null
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).bottomRight
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).sliceGroupId))))
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).sliceGroupId = null
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).sliceGroupId
        } else {
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).runLength))))
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).runLength = null
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).runLength
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).topLeft))))
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).topLeft = null
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).topLeft
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).bottomRight))))
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).bottomRight = null
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).bottomRight
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).sliceGroupId))))
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).sliceGroupId = null
            unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]).sliceGroupId
        }
    }
    *unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0]) = *pPicParamSet_3
    *unsafe(unsafe(addr(pStorage_4.pps[0]))[id_0])
    return uint(0)
}
[export]
def h264bsdActivateParamSets(var pStorage_5 : storage_t?; var ppsId : uint; var isIdr_0 : uint) : uint {
    var tmp_47 : uint
    var flag : uint
    if (unsafe(unsafe(addr(pStorage_5.pps[0]))[ppsId]) == unsafe(unsafe(reinterpret<picParamSet_t?>(uint64(0)))) || unsafe(unsafe(addr(pStorage_5.sps[0]))[unsafe(unsafe(addr(pStorage_5.pps[0]))[ppsId]).seqParameterSetId]) == unsafe(unsafe(reinterpret<seqParamSet_t?>(uint64(0))))) {
        return uint(1)
    }
    tmp_47 = uint(CheckPps(unsafe(unsafe(addr(pStorage_5.pps[0]))[ppsId]), unsafe(unsafe(addr(pStorage_5.sps[0]))[unsafe(unsafe(addr(pStorage_5.pps[0]))[ppsId]).seqParameterSetId])))
    tmp_47
    if (tmp_47 != uint(0)) {
        return tmp_47
    }
    if (pStorage_5.activePpsId == uint(256)) {
        pStorage_5.activePpsId = uint(ppsId)
        pStorage_5.activePpsId
        pStorage_5.activePps = unsafe(unsafe(addr(pStorage_5.pps[0]))[ppsId])
        pStorage_5.activePps
        pStorage_5.activeSpsId = uint(pStorage_5.activePps.seqParameterSetId)
        pStorage_5.activeSpsId
        pStorage_5.activeSps = unsafe(unsafe(addr(pStorage_5.sps[0]))[pStorage_5.activeSpsId])
        pStorage_5.activeSps
        pStorage_5.picSizeInMbs = uint(pStorage_5.activeSps.picWidthInMbs * pStorage_5.activeSps.picHeightInMbs)
        pStorage_5.picSizeInMbs
        unsafe(addr(pStorage_5.currImage[0])).width = uint(pStorage_5.activeSps.picWidthInMbs)
        unsafe(addr(pStorage_5.currImage[0])).width
        unsafe(addr(pStorage_5.currImage[0])).height = uint(pStorage_5.activeSps.picHeightInMbs)
        unsafe(addr(pStorage_5.currImage[0])).height
        pStorage_5.pendingActivation = uint(uint(1))
        pStorage_5.pendingActivation
    } else {
        if (pStorage_5.pendingActivation != 0x0) {
            pStorage_5.pendingActivation = uint(uint(0))
            pStorage_5.pendingActivation
            free(unsafe(unsafe(reinterpret<uint64>(pStorage_5.mb))))
            pStorage_5.mb = null
            pStorage_5.mb
            free(unsafe(unsafe(reinterpret<uint64>(pStorage_5.sliceGroupMap))))
            pStorage_5.sliceGroupMap = null
            pStorage_5.sliceGroupMap
            pStorage_5.mb = unsafe(unsafe(reinterpret<mbStorage_t?>(malloc(uint64(pStorage_5.picSizeInMbs) * 4))))
            pStorage_5.mb
            pStorage_5.sliceGroupMap = unsafe(unsafe(reinterpret<uint?>(malloc(uint64(pStorage_5.picSizeInMbs) * 4))))
            pStorage_5.sliceGroupMap
            if (pStorage_5.mb == unsafe(unsafe(reinterpret<mbStorage_t?>(uint64(0)))) || pStorage_5.sliceGroupMap == unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
                return uint(65535)
            }
            memset(unsafe(unsafe(reinterpret<uint64>(pStorage_5.mb))), 0, uint64(pStorage_5.picSizeInMbs) * 4)
            h264bsdInitMbNeighbours(pStorage_5.mb, pStorage_5.activeSps.picWidthInMbs, pStorage_5.picSizeInMbs)
            if (pStorage_5.noReordering != 0x0 || pStorage_5.activeSps.picOrderCntType == uint(2) || pStorage_5.activeSps.vuiParametersPresentFlag != 0x0 && pStorage_5.activeSps.vuiParameters.bitstreamRestrictionFlag != 0x0 && pStorage_5.activeSps.vuiParameters.numReorderFrames == 0) {
                flag = uint(uint(1))
                flag
            } else {
                flag = uint(uint(0))
                flag
            }
            tmp_47 = uint(h264bsdResetDpb(unsafe(addr(pStorage_5.dpb[0])), pStorage_5.activeSps.picWidthInMbs * pStorage_5.activeSps.picHeightInMbs, pStorage_5.activeSps.maxDpbSize, pStorage_5.activeSps.numRefFrames, pStorage_5.activeSps.maxFrameNum, flag))
            tmp_47
            if (tmp_47 != uint(0)) {
                return tmp_47
            }
        } else {
            if (ppsId != pStorage_5.activePpsId) {
                if (unsafe(unsafe(addr(pStorage_5.pps[0]))[ppsId]).seqParameterSetId != pStorage_5.activeSpsId) {
                    if (isIdr_0 != 0x0) {
                        pStorage_5.activePpsId = uint(ppsId)
                        pStorage_5.activePpsId
                        pStorage_5.activePps = unsafe(unsafe(addr(pStorage_5.pps[0]))[ppsId])
                        pStorage_5.activePps
                        pStorage_5.activeSpsId = uint(pStorage_5.activePps.seqParameterSetId)
                        pStorage_5.activeSpsId
                        pStorage_5.activeSps = unsafe(unsafe(addr(pStorage_5.sps[0]))[pStorage_5.activeSpsId])
                        pStorage_5.activeSps
                        pStorage_5.picSizeInMbs = uint(pStorage_5.activeSps.picWidthInMbs * pStorage_5.activeSps.picHeightInMbs)
                        pStorage_5.picSizeInMbs
                        unsafe(addr(pStorage_5.currImage[0])).width = uint(pStorage_5.activeSps.picWidthInMbs)
                        unsafe(addr(pStorage_5.currImage[0])).width
                        unsafe(addr(pStorage_5.currImage[0])).height = uint(pStorage_5.activeSps.picHeightInMbs)
                        unsafe(addr(pStorage_5.currImage[0])).height
                        pStorage_5.pendingActivation = uint(uint(1))
                        pStorage_5.pendingActivation
                    } else {
                        return uint(1)
                    }
                } else {
                    pStorage_5.activePpsId = uint(ppsId)
                    pStorage_5.activePpsId
                    pStorage_5.activePps = unsafe(unsafe(addr(pStorage_5.pps[0]))[ppsId])
                    pStorage_5.activePps
                }
            }
        }
    }
    return uint(0)
}
[export]
def h264bsdInitMbNeighbours(var pMbStorage : mbStorage_t?; var picWidth_0 : uint; var picSizeInMbs_5 : uint) {
    var i_58 : uint
    var row_5 : uint
    var col_5 : uint
    col_5 = uint(uint(0))
    row_5 = uint(col_5)
    row_5
    i_58 = uint(uint(0))
    i_58
    while (i_58 < picSizeInMbs_5) {
        if (col_5 != 0x0) {
            unsafe(pMbStorage[i_58]).mbA = unsafe(unsafe(pMbStorage + i_58) - 1)
            unsafe(pMbStorage[i_58]).mbA
        } else {
            unsafe(pMbStorage[i_58]).mbA = null
            unsafe(pMbStorage[i_58]).mbA
        }
        if (row_5 != 0x0) {
            unsafe(pMbStorage[i_58]).mbB = unsafe(unsafe(pMbStorage + i_58) - picWidth_0)
            unsafe(pMbStorage[i_58]).mbB
        } else {
            unsafe(pMbStorage[i_58]).mbB = null
            unsafe(pMbStorage[i_58]).mbB
        }
        if (row_5 != 0x0 && col_5 < picWidth_0 - uint(1)) {
            unsafe(pMbStorage[i_58]).mbC = unsafe(unsafe(pMbStorage + i_58) - picWidth_0 - uint(1))
            unsafe(pMbStorage[i_58]).mbC
        } else {
            unsafe(pMbStorage[i_58]).mbC = null
            unsafe(pMbStorage[i_58]).mbC
        }
        if (row_5 != 0x0 && col_5 != 0x0) {
            unsafe(pMbStorage[i_58]).mbD = unsafe(unsafe(pMbStorage + i_58) - picWidth_0 + uint(1))
            unsafe(pMbStorage[i_58]).mbD
        } else {
            unsafe(pMbStorage[i_58]).mbD = null
            unsafe(pMbStorage[i_58]).mbD
        }
        col_5 = col_5 + 1
        col_5
        if (col_5 == picWidth_0) {
            col_5 = uint(uint(0))
            col_5
            row_5 = row_5 + 1
            row_5
        }
        i_58 = i_58 + 1
    }
}
[export]
def CheckPps(var pps : picParamSet_t?; var sps_0 : seqParamSet_t?) : uint {
    var i_59 : uint
    var picSize_2 : uint
    picSize_2 = uint(sps_0.picWidthInMbs * sps_0.picHeightInMbs)
    picSize_2
    if (pps.numSliceGroups > uint(1)) {
        if (pps.sliceGroupMapType == uint(0)) {
            i_59 = uint(uint(0))
            i_59
            while (i_59 < pps.numSliceGroups) {
                if (unsafe(pps.runLength[i_59]) > picSize_2) {
                    return uint(1)
                }
                i_59 = i_59 + 1
            }
        } else {
            if (pps.sliceGroupMapType == uint(2)) {
                i_59 = uint(uint(0))
                i_59
                while (i_59 < pps.numSliceGroups - uint(1)) {
                    if (unsafe(pps.topLeft[i_59]) > unsafe(pps.bottomRight[i_59]) || unsafe(pps.bottomRight[i_59]) >= picSize_2) {
                        return uint(1)
                    }
                    if (unsafe(pps.topLeft[i_59]) % sps_0.picWidthInMbs > unsafe(pps.bottomRight[i_59]) % sps_0.picWidthInMbs) {
                        return uint(1)
                    }
                    i_59 = i_59 + 1
                }
            } else {
                if (pps.sliceGroupMapType > uint(2) && pps.sliceGroupMapType < uint(6)) {
                    if (pps.sliceGroupChangeRate > picSize_2) {
                        return uint(1)
                    }
                } else {
                    if (pps.sliceGroupMapType == uint(6) && pps.picSizeInMapUnits < picSize_2) {
                        return uint(1)
                    }
                }
            }
        }
    }
    return uint(0)
}
[export]
def h264bsdComputeSliceGroupMap(var pStorage_6 : storage_t?; var sliceGroupChangeCycle : uint) {
    h264bsdDecodeSliceGroupMap(pStorage_6.sliceGroupMap, pStorage_6.activePps, sliceGroupChangeCycle, pStorage_6.activeSps.picWidthInMbs, pStorage_6.activeSps.picHeightInMbs)
}
[export]
def h264bsdDecodeSliceGroupMap(var map : uint?; var pps_0 : picParamSet_t?; var sliceGroupChangeCycle_0 : uint; var picWidth_1 : uint; var picHeight : uint) {
    var i_60 : uint
    var picSize_3 : uint
    var unitsInSliceGroup0 : uint = uint(0)
    var sizeOfUpperLeftGroup : uint = uint(0)
    picSize_3 = uint(picWidth_1 * picHeight)
    picSize_3
    if (pps_0.numSliceGroups == uint(1)) {
        memset(unsafe(unsafe(reinterpret<uint64>(map))), 0, uint64(picSize_3) * 4)
        return
    }
    if (pps_0.sliceGroupMapType > uint(2) && pps_0.sliceGroupMapType < uint(6)) {
        var c2da_fresh52_h264bsd : int = 0
        if (sliceGroupChangeCycle_0 * pps_0.sliceGroupChangeRate < picSize_3) {
            c2da_fresh52_h264bsd = sliceGroupChangeCycle_0 * pps_0.sliceGroupChangeRate
        } else {
            c2da_fresh52_h264bsd = picSize_3
        }
        unitsInSliceGroup0 = uint(c2da_fresh52_h264bsd)
        unitsInSliceGroup0
        if (pps_0.sliceGroupMapType == uint(4) || pps_0.sliceGroupMapType == uint(5)) {
            var c2da_fresh53_h264bsd : int = 0
            if (pps_0.sliceGroupChangeDirectionFlag) {
                c2da_fresh53_h264bsd = picSize_3 - unitsInSliceGroup0
            } else {
                c2da_fresh53_h264bsd = unitsInSliceGroup0
            }
            sizeOfUpperLeftGroup = uint(c2da_fresh53_h264bsd)
            sizeOfUpperLeftGroup
        }
    }
    if (pps_0.sliceGroupMapType == uint(0)) {
        DecodeInterleavedMap(map, pps_0.numSliceGroups, pps_0.runLength, picSize_3)
    } elif (pps_0.sliceGroupMapType == uint(1)) {
        DecodeDispersedMap(map, pps_0.numSliceGroups, picWidth_1, picHeight)
    } elif (pps_0.sliceGroupMapType == uint(2)) {
        DecodeForegroundLeftOverMap(map, pps_0.numSliceGroups, pps_0.topLeft, pps_0.bottomRight, picWidth_1, picHeight)
    } elif (pps_0.sliceGroupMapType == uint(3)) {
        DecodeBoxOutMap(map, pps_0.sliceGroupChangeDirectionFlag, unitsInSliceGroup0, picWidth_1, picHeight)
    } elif (pps_0.sliceGroupMapType == uint(4)) {
        DecodeRasterScanMap(map, pps_0.sliceGroupChangeDirectionFlag, sizeOfUpperLeftGroup, picSize_3)
    } elif (pps_0.sliceGroupMapType == uint(5)) {
        DecodeWipeMap(map, pps_0.sliceGroupChangeDirectionFlag, sizeOfUpperLeftGroup, picWidth_1, picHeight)
    } else {
    }
}
[export]
def DecodeWipeMap(var map_0 : uint?; var sliceGroupChangeDirectionFlag : uint; var sizeOfUpperLeftGroup_0 : uint; var picWidth_2 : uint; var picHeight_0 : uint) {
    var i_61 : uint
    var j_10 : uint
    var k_0 : uint
    k_0 = uint(uint(0))
    k_0
    j_10 = uint(uint(0))
    j_10
    while (j_10 < picWidth_2) {
        i_61 = uint(uint(0))
        i_61
        while (i_61 < picHeight_0) {
            if (k_0 < sizeOfUpperLeftGroup_0) {
                unsafe(map_0[i_61 * picWidth_2 + j_10]) = uint(uint(sliceGroupChangeDirectionFlag))
                unsafe(map_0[i_61 * picWidth_2 + j_10])
            } else {
                unsafe(map_0[i_61 * picWidth_2 + j_10]) = uint(uint(1) - uint(sliceGroupChangeDirectionFlag))
                unsafe(map_0[i_61 * picWidth_2 + j_10])
            }
            i_61 = i_61 + 1
        }
        j_10 = j_10 + 1
    }
}
[export]
def DecodeRasterScanMap(var map_1 : uint?; var sliceGroupChangeDirectionFlag_0 : uint; var sizeOfUpperLeftGroup_1 : uint; var picSize_4 : uint) {
    var i_62 : uint
    i_62 = uint(uint(0))
    i_62
    while (i_62 < picSize_4) {
        if (i_62 < sizeOfUpperLeftGroup_1) {
            unsafe(map_1[i_62]) = uint(uint(sliceGroupChangeDirectionFlag_0))
            unsafe(map_1[i_62])
        } else {
            unsafe(map_1[i_62]) = uint(uint(1) - uint(sliceGroupChangeDirectionFlag_0))
            unsafe(map_1[i_62])
        }
        i_62 = i_62 + 1
    }
}
[export]
def DecodeBoxOutMap(var map_2 : uint?; var sliceGroupChangeDirectionFlag_1 : uint; var unitsInSliceGroup0_0 : uint; var picWidth_3 : uint; var picHeight_1 : uint) {
    var i_63 : uint
    var k_1 : uint
    var picSize_5 : uint
    var x_14 : int
    var y_14 : int
    var xDir : int
    var yDir : int
    var leftBound : int
    var topBound : int
    var rightBound : int
    var bottomBound : int
    var mapUnitVacant : uint
    picSize_5 = uint(picWidth_3 * picHeight_1)
    picSize_5
    i_63 = uint(uint(0))
    i_63
    while (i_63 < picSize_5) {
        unsafe(map_2[i_63]) = uint(uint(1))
        unsafe(map_2[i_63])
        i_63 = i_63 + 1
    }
    x_14 = int(uint(picWidth_3 - uint(sliceGroupChangeDirectionFlag_1)) >> uint(uint(1)))
    x_14
    y_14 = int(uint(picHeight_1 - uint(sliceGroupChangeDirectionFlag_1)) >> uint(uint(1)))
    y_14
    leftBound = x_14
    leftBound
    topBound = y_14
    topBound
    rightBound = x_14
    rightBound
    bottomBound = y_14
    bottomBound
    xDir = int(sliceGroupChangeDirectionFlag_1) - 1
    xDir
    yDir = int(sliceGroupChangeDirectionFlag_1)
    yDir
    k_1 = uint(uint(0))
    k_1
    while (k_1 < unitsInSliceGroup0_0) {
        var c2da_fresh54_h264bsd : int = 0
        if (unsafe(map_2[uint(y_14) * picWidth_3 + uint(x_14)]) == uint(1)) {
            c2da_fresh54_h264bsd = 1
        } else {
            c2da_fresh54_h264bsd = 0
        }
        mapUnitVacant = uint(uint(c2da_fresh54_h264bsd))
        mapUnitVacant
        if (mapUnitVacant != 0x0) {
            unsafe(map_2[uint(y_14) * picWidth_3 + uint(x_14)]) = uint(uint(0))
            unsafe(map_2[uint(y_14) * picWidth_3 + uint(x_14)])
        }
        if (xDir == -1 && x_14 == leftBound) {
            var c2da_fresh55_h264bsd : int = 0
            if (leftBound - 1 > 0) {
                c2da_fresh55_h264bsd = leftBound - 1
            } else {
                c2da_fresh55_h264bsd = 0
            }
            leftBound = c2da_fresh55_h264bsd
            leftBound
            x_14 = leftBound
            x_14
            xDir = 0
            xDir
            yDir = 2 * int(sliceGroupChangeDirectionFlag_1) - 1
            yDir
        } else {
            if (xDir == 1 && x_14 == rightBound) {
                var c2da_fresh56_h264bsd : int = 0
                if (rightBound + 1 < int(picWidth_3) - 1) {
                    c2da_fresh56_h264bsd = rightBound + 1
                } else {
                    c2da_fresh56_h264bsd = int(picWidth_3) - 1
                }
                rightBound = c2da_fresh56_h264bsd
                rightBound
                x_14 = rightBound
                x_14
                xDir = 0
                xDir
                yDir = 1 - 2 * int(sliceGroupChangeDirectionFlag_1)
                yDir
            } else {
                if (yDir == -1 && y_14 == topBound) {
                    var c2da_fresh57_h264bsd : int = 0
                    if (topBound - 1 > 0) {
                        c2da_fresh57_h264bsd = topBound - 1
                    } else {
                        c2da_fresh57_h264bsd = 0
                    }
                    topBound = c2da_fresh57_h264bsd
                    topBound
                    y_14 = topBound
                    y_14
                    xDir = 1 - 2 * int(sliceGroupChangeDirectionFlag_1)
                    xDir
                    yDir = 0
                    yDir
                } else {
                    if (yDir == 1 && y_14 == bottomBound) {
                        var c2da_fresh58_h264bsd : int = 0
                        if (bottomBound + 1 < int(picHeight_1) - 1) {
                            c2da_fresh58_h264bsd = bottomBound + 1
                        } else {
                            c2da_fresh58_h264bsd = int(picHeight_1) - 1
                        }
                        bottomBound = c2da_fresh58_h264bsd
                        bottomBound
                        y_14 = bottomBound
                        y_14
                        xDir = 2 * int(sliceGroupChangeDirectionFlag_1) - 1
                        xDir
                        yDir = 0
                        yDir
                    } else {
                        x_14 = x_14 + xDir
                        x_14
                        y_14 = y_14 + yDir
                        y_14
                    }
                }
            }
        }
        var c2da_fresh59_h264bsd : int = 0
        if (mapUnitVacant) {
            c2da_fresh59_h264bsd = 1
        } else {
            c2da_fresh59_h264bsd = 0
        }
        k_1 = uint(k_1 + uint(c2da_fresh59_h264bsd))
    }
}
[export]
def DecodeForegroundLeftOverMap(var map_3 : uint?; var numSliceGroups : uint; var topLeft : uint?; var bottomRight : uint?; var picWidth_4 : uint; var picHeight_2 : uint) {
    var i_64 : uint
    var y_15 : uint
    var x_15 : uint
    var yTopLeft : uint
    var yBottomRight : uint
    var xTopLeft : uint
    var xBottomRight : uint
    var picSize_6 : uint
    var group : uint
    picSize_6 = uint(picWidth_4 * picHeight_2)
    picSize_6
    i_64 = uint(uint(0))
    i_64
    while (i_64 < picSize_6) {
        unsafe(map_3[i_64]) = uint(numSliceGroups - uint(1))
        unsafe(map_3[i_64])
        i_64 = i_64 + 1
    }
    group = uint(numSliceGroups - uint(1))
    group
    while (group != 0x0) {
        yTopLeft = uint(unsafe(topLeft[group]) / picWidth_4)
        yTopLeft
        xTopLeft = uint(unsafe(topLeft[group]) % picWidth_4)
        xTopLeft
        yBottomRight = uint(unsafe(bottomRight[group]) / picWidth_4)
        yBottomRight
        xBottomRight = uint(unsafe(bottomRight[group]) % picWidth_4)
        xBottomRight
        y_15 = uint(yTopLeft)
        y_15
        while (y_15 <= yBottomRight) {
            x_15 = uint(xTopLeft)
            x_15
            while (x_15 <= xBottomRight) {
                unsafe(map_3[y_15 * picWidth_4 + x_15]) = uint(group)
                unsafe(map_3[y_15 * picWidth_4 + x_15])
                x_15 = x_15 + 1
            }
            y_15 = y_15 + 1
        }
    }
}
[export]
def DecodeDispersedMap(var map_4 : uint?; var numSliceGroups_0 : uint; var picWidth_5 : uint; var picHeight_3 : uint) {
    var i_65 : uint
    var picSize_7 : uint
    picSize_7 = uint(picWidth_5 * picHeight_3)
    picSize_7
    i_65 = uint(uint(0))
    i_65
    while (i_65 < picSize_7) {
        unsafe(map_4[i_65]) = uint(i_65 % picWidth_5 + uint(i_65 / picWidth_5 * numSliceGroups_0) >> uint(uint(1)) % numSliceGroups_0)
        unsafe(map_4[i_65])
        i_65 = i_65 + 1
    }
}
[export]
def DecodeInterleavedMap(var map_5 : uint?; var numSliceGroups_1 : uint; var runLength : uint?; var picSize_8 : uint) {
    var i_66 : uint
    var j_11 : uint
    var group_0 : uint
    i_66 = uint(uint(0))
    i_66
    var _dw_59191 : bool = true
    while (_dw_59191 || i_66 < picSize_8) {
        _dw_59191 = false
        group_0 = uint(uint(0))
        group_0
        while (group_0 < numSliceGroups_1 && i_66 < picSize_8) {
            j_11 = uint(uint(0))
            j_11
            while (j_11 < unsafe(runLength[group_0]) && i_66 + j_11 < picSize_8) {
                unsafe(map_5[i_66 + j_11]) = uint(group_0)
                unsafe(map_5[i_66 + j_11])
                j_11 = j_11 + 1
            }
            group_0 = group_0 + 1
            i_66 = uint(i_66 + unsafe(runLength[group_0]))
        }
    }
}
[export]
def h264bsdCheckAccessUnitBoundary(var strm : strmData_t?; var nuNext : nalUnit_t?; var storage : storage_t?; var accessUnitBoundaryFlag : uint?) : uint {
    var tmp_48 : uint
    var ppsId_0 : uint
    var frameNum_3 : uint
    var idrPicId_0 : uint
    var picOrderCntLsb_0 : uint
    var deltaPicOrderCntBottom_0 : int
    var deltaPicOrderCnt_0 : array<int> = [0, 0]
    var sps_1 : seqParamSet_t?
    var pps_1 : picParamSet_t?
    *accessUnitBoundaryFlag = uint(uint(0))
    *accessUnitBoundaryFlag
    if (uint(nuNext.nalUnitType) > uint(5) && uint(nuNext.nalUnitType) < uint(12) || uint(nuNext.nalUnitType) > uint(12) && uint(nuNext.nalUnitType) <= uint(18)) {
        *accessUnitBoundaryFlag = uint(uint(1))
        *accessUnitBoundaryFlag
        return uint(0)
    } else {
        if (uint(nuNext.nalUnitType) != uint(NAL_CODED_SLICE) && uint(nuNext.nalUnitType) != uint(NAL_CODED_SLICE_IDR)) {
            return uint(0)
        }
    }
    if (unsafe(addr(storage.aub[0])).firstCallFlag != 0x0) {
        *accessUnitBoundaryFlag = uint(uint(1))
        *accessUnitBoundaryFlag
        unsafe(addr(storage.aub[0])).firstCallFlag = uint(uint(0))
        unsafe(addr(storage.aub[0])).firstCallFlag
    }
    tmp_48 = uint(h264bsdCheckPpsId(strm, unsafe(addr(ppsId_0))))
    tmp_48
    if (tmp_48 != uint(0)) {
        return tmp_48
    }
    pps_1 = unsafe(unsafe(addr(storage.pps[0]))[ppsId_0])
    pps_1
    if (pps_1 == unsafe(unsafe(reinterpret<picParamSet_t?>(uint64(0)))) || unsafe(unsafe(addr(storage.sps[0]))[pps_1.seqParameterSetId]) == unsafe(unsafe(reinterpret<seqParamSet_t?>(uint64(0)))) || storage.activeSpsId != uint(32) && pps_1.seqParameterSetId != storage.activeSpsId && uint(nuNext.nalUnitType) != uint(NAL_CODED_SLICE_IDR)) {
        return uint(65520)
    }
    sps_1 = unsafe(unsafe(addr(storage.sps[0]))[pps_1.seqParameterSetId])
    sps_1
    if (unsafe(addr(unsafe(addr(storage.aub[0])).nuPrev[0])).nalRefIdc != nuNext.nalRefIdc && unsafe(addr(unsafe(addr(storage.aub[0])).nuPrev[0])).nalRefIdc == uint(0) || nuNext.nalRefIdc == uint(0)) {
        *accessUnitBoundaryFlag = uint(uint(1))
        *accessUnitBoundaryFlag
    }
    if (uint(unsafe(addr(unsafe(addr(storage.aub[0])).nuPrev[0])).nalUnitType) == uint(NAL_CODED_SLICE_IDR) && uint(nuNext.nalUnitType) != uint(NAL_CODED_SLICE_IDR) || uint(unsafe(addr(unsafe(addr(storage.aub[0])).nuPrev[0])).nalUnitType) != uint(NAL_CODED_SLICE_IDR) && uint(nuNext.nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
        *accessUnitBoundaryFlag = uint(uint(1))
        *accessUnitBoundaryFlag
    }
    tmp_48 = uint(h264bsdCheckFrameNum(strm, sps_1.maxFrameNum, unsafe(addr(frameNum_3))))
    tmp_48
    if (tmp_48 != uint(0)) {
        return uint(1)
    }
    if (unsafe(addr(storage.aub[0])).prevFrameNum != frameNum_3) {
        unsafe(addr(storage.aub[0])).prevFrameNum = uint(frameNum_3)
        unsafe(addr(storage.aub[0])).prevFrameNum
        *accessUnitBoundaryFlag = uint(uint(1))
        *accessUnitBoundaryFlag
    }
    if (uint(nuNext.nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
        tmp_48 = uint(h264bsdCheckIdrPicId(strm, sps_1.maxFrameNum, nuNext.nalUnitType, unsafe(addr(idrPicId_0))))
        tmp_48
        if (tmp_48 != uint(0)) {
            return uint(1)
        }
        if (uint(unsafe(addr(unsafe(addr(storage.aub[0])).nuPrev[0])).nalUnitType) == uint(NAL_CODED_SLICE_IDR) && unsafe(addr(storage.aub[0])).prevIdrPicId != idrPicId_0) {
            *accessUnitBoundaryFlag = uint(uint(1))
            *accessUnitBoundaryFlag
        }
        unsafe(addr(storage.aub[0])).prevIdrPicId = uint(idrPicId_0)
        unsafe(addr(storage.aub[0])).prevIdrPicId
    }
    if (sps_1.picOrderCntType == uint(0)) {
        tmp_48 = uint(h264bsdCheckPicOrderCntLsb(strm, sps_1, nuNext.nalUnitType, unsafe(addr(picOrderCntLsb_0))))
        tmp_48
        if (tmp_48 != uint(0)) {
            return uint(1)
        }
        if (unsafe(addr(storage.aub[0])).prevPicOrderCntLsb != picOrderCntLsb_0) {
            unsafe(addr(storage.aub[0])).prevPicOrderCntLsb = uint(picOrderCntLsb_0)
            unsafe(addr(storage.aub[0])).prevPicOrderCntLsb
            *accessUnitBoundaryFlag = uint(uint(1))
            *accessUnitBoundaryFlag
        }
        if (pps_1.picOrderPresentFlag != 0x0) {
            tmp_48 = uint(h264bsdCheckDeltaPicOrderCntBottom(strm, sps_1, nuNext.nalUnitType, unsafe(addr(deltaPicOrderCntBottom_0))))
            tmp_48
            if (tmp_48 != uint(0)) {
                return tmp_48
            }
            if (unsafe(addr(storage.aub[0])).prevDeltaPicOrderCntBottom != deltaPicOrderCntBottom_0) {
                unsafe(addr(storage.aub[0])).prevDeltaPicOrderCntBottom = deltaPicOrderCntBottom_0
                unsafe(addr(storage.aub[0])).prevDeltaPicOrderCntBottom
                *accessUnitBoundaryFlag = uint(uint(1))
                *accessUnitBoundaryFlag
            }
        }
    } else {
        if (sps_1.picOrderCntType == uint(1) && sps_1.deltaPicOrderAlwaysZeroFlag == 0) {
            tmp_48 = uint(h264bsdCheckDeltaPicOrderCnt(strm, sps_1, nuNext.nalUnitType, pps_1.picOrderPresentFlag, unsafe(addr(deltaPicOrderCnt_0[0]))))
            tmp_48
            if (tmp_48 != uint(0)) {
                return tmp_48
            }
            if (unsafe(unsafe(addr(unsafe(addr(storage.aub[0])).prevDeltaPicOrderCnt[0]))[0]) != unsafe(unsafe(addr(deltaPicOrderCnt_0[0]))[0])) {
                unsafe(unsafe(addr(unsafe(addr(storage.aub[0])).prevDeltaPicOrderCnt[0]))[0]) = unsafe(unsafe(addr(deltaPicOrderCnt_0[0]))[0])
                unsafe(unsafe(addr(unsafe(addr(storage.aub[0])).prevDeltaPicOrderCnt[0]))[0])
                *accessUnitBoundaryFlag = uint(uint(1))
                *accessUnitBoundaryFlag
            }
            if (pps_1.picOrderPresentFlag != 0x0) {
                if (unsafe(unsafe(addr(unsafe(addr(storage.aub[0])).prevDeltaPicOrderCnt[0]))[1]) != unsafe(unsafe(addr(deltaPicOrderCnt_0[0]))[1])) {
                    unsafe(unsafe(addr(unsafe(addr(storage.aub[0])).prevDeltaPicOrderCnt[0]))[1]) = unsafe(unsafe(addr(deltaPicOrderCnt_0[0]))[1])
                    unsafe(unsafe(addr(unsafe(addr(storage.aub[0])).prevDeltaPicOrderCnt[0]))[1])
                    *accessUnitBoundaryFlag = uint(uint(1))
                    *accessUnitBoundaryFlag
                }
            }
        }
    }
    *unsafe(addr(unsafe(addr(storage.aub[0])).nuPrev[0])) = *nuNext
    *unsafe(addr(unsafe(addr(storage.aub[0])).nuPrev[0]))
    return uint(0)
}
[export]
def h264bsdValidParamSets(var pStorage_7 : storage_t?) : uint {
    var i_67 : uint
    i_67 = uint(uint(0))
    i_67
    while (i_67 < uint(256)) {
        if (unsafe(unsafe(addr(pStorage_7.pps[0]))[i_67]) != null && unsafe(unsafe(addr(pStorage_7.sps[0]))[unsafe(unsafe(addr(pStorage_7.pps[0]))[i_67]).seqParameterSetId]) != null && CheckPps(unsafe(unsafe(addr(pStorage_7.pps[0]))[i_67]), unsafe(unsafe(addr(pStorage_7.sps[0]))[unsafe(unsafe(addr(pStorage_7.pps[0]))[i_67]).seqParameterSetId])) == uint(0)) {
            return uint(0)
        }
        i_67 = i_67 + 1
    }
    return uint(1)
}
[export]
def h264bsdConceal(var pStorage_8 : storage_t?; var currImage_1 : image_t?; var sliceType_0 : uint) : uint {
    var i_68 : uint
    var j_12 : uint
    var row_6 : uint
    var col_6 : uint
    var width_17 : uint
    var height_14 : uint
    var refData : uint8?
    var mb_7 : mbStorage_t?
    width_17 = uint(currImage_1.width)
    width_17
    height_14 = uint(currImage_1.height)
    height_14
    refData = null
    refData
    if (sliceType_0 == uint(P_SLICE) || sliceType_0 == uint(P_SLICE + 5) || pStorage_8.intraConcealmentFlag != uint(0)) {
        i_68 = uint(uint(0))
        i_68
        var _dw_64034 : bool = true
        while (_dw_64034 || refData == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
            _dw_64034 = false
            refData = h264bsdGetRefPicData(unsafe(addr(pStorage_8.dpb[0])), i_68)
            refData
            i_68 = i_68 + 1
            i_68
            if (i_68 >= uint(16)) {
                break
            }
        }
    }
    col_6 = uint(uint(0))
    row_6 = uint(col_6)
    i_68 = uint(row_6)
    i_68
    while (i_68 < pStorage_8.picSizeInMbs && unsafe(pStorage_8.mb[i_68]).decoded == 0) {
        i_68 = i_68 + 1
        i_68
        col_6 = col_6 + 1
        col_6
        if (col_6 == width_17) {
            row_6 = row_6 + 1
            row_6
            col_6 = uint(uint(0))
            col_6
        }
    }
    if (i_68 == pStorage_8.picSizeInMbs) {
        if (sliceType_0 == uint(I_SLICE) || sliceType_0 == uint(I_SLICE + 5) && pStorage_8.intraConcealmentFlag == uint(0) || refData == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
            memset(unsafe(unsafe(reinterpret<uint64>(currImage_1.data))), 128, uint64(width_17 * height_14 * uint(384)))
        } else {
            memcpy(unsafe(unsafe(reinterpret<uint64>(currImage_1.data))), unsafe(unsafe(reinterpret<uint64>(refData))), uint64(width_17 * height_14 * uint(384)))
        }
        pStorage_8.numConcealedMbs = uint(pStorage_8.picSizeInMbs)
        pStorage_8.numConcealedMbs
        i_68 = uint(uint(0))
        i_68
        while (i_68 < pStorage_8.picSizeInMbs) {
            unsafe(pStorage_8.mb[i_68]).disableDeblockingFilterIdc = uint(uint(1))
            unsafe(pStorage_8.mb[i_68]).disableDeblockingFilterIdc
            i_68 = i_68 + 1
        }
        return uint(0)
    }
    mb_7 = unsafe(pStorage_8.mb + row_6 * width_17)
    mb_7
    j_12 = uint(col_6)
    j_12
    while (j_12 != 0x0) {
        ConcealMb(unsafe(mb_7 + j_12), currImage_1, row_6, j_12, sliceType_0, refData)
        unsafe(mb_7[j_12]).decoded = uint(uint(1))
        unsafe(mb_7[j_12]).decoded
        pStorage_8.numConcealedMbs = pStorage_8.numConcealedMbs + 1
        pStorage_8.numConcealedMbs
    }
    j_12 = uint(col_6 + uint(1))
    j_12
    while (j_12 < width_17) {
        if (unsafe(mb_7[j_12]).decoded == 0) {
            ConcealMb(unsafe(mb_7 + j_12), currImage_1, row_6, j_12, sliceType_0, refData)
            unsafe(mb_7[j_12]).decoded = uint(uint(1))
            unsafe(mb_7[j_12]).decoded
            pStorage_8.numConcealedMbs = pStorage_8.numConcealedMbs + 1
            pStorage_8.numConcealedMbs
        }
        j_12 = j_12 + 1
    }
    if (row_6 != 0x0) {
        j_12 = uint(uint(0))
        j_12
        while (j_12 < width_17) {
            i_68 = uint(row_6 - uint(1))
            i_68
            mb_7 = unsafe(unsafe(pStorage_8.mb + i_68 * width_17) + j_12)
            mb_7
            var _dw_63672 : bool = true
            while (_dw_63672 || i_68) {
                _dw_63672 = false
                ConcealMb(mb_7, currImage_1, i_68, j_12, sliceType_0, refData)
                mb_7.decoded = uint(uint(1))
                mb_7.decoded
                pStorage_8.numConcealedMbs = pStorage_8.numConcealedMbs + 1
                pStorage_8.numConcealedMbs
                mb_7 = mb_7 - width_17
                mb_7
            }
            j_12 = j_12 + 1
        }
    }
    i_68 = uint(row_6 + uint(1))
    i_68
    while (i_68 < height_14) {
        mb_7 = unsafe(pStorage_8.mb + i_68 * width_17)
        mb_7
        j_12 = uint(uint(0))
        j_12
        while (j_12 < width_17) {
            if (unsafe(mb_7[j_12]).decoded == 0) {
                ConcealMb(unsafe(mb_7 + j_12), currImage_1, i_68, j_12, sliceType_0, refData)
                unsafe(mb_7[j_12]).decoded = uint(uint(1))
                unsafe(mb_7[j_12]).decoded
                pStorage_8.numConcealedMbs = pStorage_8.numConcealedMbs + 1
                pStorage_8.numConcealedMbs
            }
            j_12 = j_12 + 1
        }
        i_68 = i_68 + 1
    }
    return uint(0)
}
[export]
def ConcealMb(var pMb_17 : mbStorage_t?; var currImage_2 : image_t?; var row_7 : uint; var col_7 : uint; var sliceType_1 : uint; var refData_0 : uint8?) : uint {
    var i_69 : uint
    var j_13 : uint
    var comp_3 : uint
    var hor : uint
    var ver : uint
    var mbNum_5 : uint
    var width_18 : uint
    var height_15 : uint
    var mbPos : uint8?
    var data_31 : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var pData_0 : uint8?
    var tmp_49 : int
    var firstPhase : array<int> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var pTmp : int?
    var a_9 : array<int> = [0, 0, 0, 0]
    var b_2 : array<int> = [0, 0, 0, 0]
    var l_1 : array<int> = [0, 0, 0, 0]
    var r : array<int> = [0, 0, 0, 0]
    var A : uint
    var B : uint
    var L : uint
    var R : uint
    width_18 = uint(currImage_2.width)
    width_18
    height_15 = uint(currImage_2.height)
    height_15
    mbNum_5 = uint(row_7 * width_18 + col_7)
    mbNum_5
    h264bsdSetCurrImageMbPointers(currImage_2, mbNum_5)
    mbPos = unsafe(unsafe(currImage_2.data + row_7 * uint(16) * width_18 * uint(16)) + col_7 * uint(16))
    mbPos
    R = uint(uint(0))
    L = uint(R)
    B = uint(L)
    A = uint(B)
    A
    pMb_17.qpY = uint(uint(40))
    pMb_17.qpY
    pMb_17.disableDeblockingFilterIdc = uint(uint(0))
    pMb_17.disableDeblockingFilterIdc
    pMb_17.mbType = cast<mbType_e>(I_4x4)
    pMb_17.mbType
    pMb_17.filterOffsetA = 0
    pMb_17.filterOffsetA
    pMb_17.filterOffsetB = 0
    pMb_17.filterOffsetB
    pMb_17.chromaQpIndexOffset = 0
    pMb_17.chromaQpIndexOffset
    if (sliceType_1 == uint(I_SLICE) || sliceType_1 == uint(I_SLICE + 5)) {
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(data_31[0]))))), 0, 4)
    } else {
        var mv_6 : mv_t = [0, 0]
        var refImage_0 : image_t
        refImage_0.width = uint(width_18)
        refImage_0.width
        refImage_0.height = uint(height_15)
        refImage_0.height
        refImage_0.data = refData_0
        refImage_0.data
        if (refImage_0.data != null) {
            h264bsdPredictSamples(unsafe(addr(data_31[0])), unsafe(addr(mv_6)), unsafe(addr(refImage_0)), col_7 * uint(16), row_7 * uint(16), uint(0), uint(0), uint(16), uint(16))
            h264bsdWriteMacroblock(currImage_2, unsafe(addr(data_31[0])))
            return uint(0)
        } else {
            memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(data_31[0]))))), 0, 4)
        }
    }
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(firstPhase[0]))))), 0, 4)
    j_13 = uint(uint(0))
    j_13
    ver = uint(uint(0))
    hor = uint(ver)
    hor
    if (row_7 != 0x0 && unsafe(pMb_17 - width_18).decoded != 0x0) {
        A = uint(uint(1))
        A
        pData_0 = unsafe(mbPos - width_18 * uint(16))
        pData_0
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[0]) = int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[0])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[0]) = unsafe(unsafe(addr(a_9[0]))[0]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[0])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[0]) = unsafe(unsafe(addr(a_9[0]))[0]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[0])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[0]) = unsafe(unsafe(addr(a_9[0]))[0]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[0])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[1]) = int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[1])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[1]) = unsafe(unsafe(addr(a_9[0]))[1]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[1])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[1]) = unsafe(unsafe(addr(a_9[0]))[1]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[1])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[1]) = unsafe(unsafe(addr(a_9[0]))[1]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[1])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[2]) = int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[2])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[2]) = unsafe(unsafe(addr(a_9[0]))[2]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[2])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[2]) = unsafe(unsafe(addr(a_9[0]))[2]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[2])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[2]) = unsafe(unsafe(addr(a_9[0]))[2]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[2])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[3]) = int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[3])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[3]) = unsafe(unsafe(addr(a_9[0]))[3]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[3])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[3]) = unsafe(unsafe(addr(a_9[0]))[3]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[3])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(a_9[0]))[3]) = unsafe(unsafe(addr(a_9[0]))[3]) + int(*pData_0)
        unsafe(unsafe(addr(a_9[0]))[3])
        j_13 = j_13 + 1
        j_13
        hor = hor + 1
        hor
        unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) + unsafe(unsafe(addr(a_9[0]))[0]) + unsafe(unsafe(addr(a_9[0]))[1]) + unsafe(unsafe(addr(a_9[0]))[2]) + unsafe(unsafe(addr(a_9[0]))[3])
        unsafe(unsafe(addr(firstPhase[0]))[0])
        unsafe(unsafe(addr(firstPhase[0]))[1]) = unsafe(unsafe(addr(firstPhase[0]))[1]) + unsafe(unsafe(addr(a_9[0]))[0]) + unsafe(unsafe(addr(a_9[0]))[1]) - unsafe(unsafe(addr(a_9[0]))[2]) - unsafe(unsafe(addr(a_9[0]))[3])
        unsafe(unsafe(addr(firstPhase[0]))[1])
    }
    if (row_7 != height_15 - uint(1) && unsafe(pMb_17 + width_18).decoded != 0x0) {
        B = uint(uint(1))
        B
        pData_0 = unsafe(mbPos + uint(16) * width_18 * uint(16))
        pData_0
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[0]) = int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[0])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[0]) = unsafe(unsafe(addr(b_2[0]))[0]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[0])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[0]) = unsafe(unsafe(addr(b_2[0]))[0]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[0])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[0]) = unsafe(unsafe(addr(b_2[0]))[0]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[0])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[1]) = int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[1])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[1]) = unsafe(unsafe(addr(b_2[0]))[1]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[1])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[1]) = unsafe(unsafe(addr(b_2[0]))[1]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[1])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[1]) = unsafe(unsafe(addr(b_2[0]))[1]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[1])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[2]) = int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[2])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[2]) = unsafe(unsafe(addr(b_2[0]))[2]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[2])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[2]) = unsafe(unsafe(addr(b_2[0]))[2]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[2])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[2]) = unsafe(unsafe(addr(b_2[0]))[2]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[2])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[3]) = int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[3])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[3]) = unsafe(unsafe(addr(b_2[0]))[3]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[3])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[3]) = unsafe(unsafe(addr(b_2[0]))[3]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[3])
        pData_0 = pData_0 + 1
        unsafe(unsafe(addr(b_2[0]))[3]) = unsafe(unsafe(addr(b_2[0]))[3]) + int(*pData_0)
        unsafe(unsafe(addr(b_2[0]))[3])
        j_13 = j_13 + 1
        j_13
        hor = hor + 1
        hor
        unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) + unsafe(unsafe(addr(b_2[0]))[0]) + unsafe(unsafe(addr(b_2[0]))[1]) + unsafe(unsafe(addr(b_2[0]))[2]) + unsafe(unsafe(addr(b_2[0]))[3])
        unsafe(unsafe(addr(firstPhase[0]))[0])
        unsafe(unsafe(addr(firstPhase[0]))[1]) = unsafe(unsafe(addr(firstPhase[0]))[1]) + unsafe(unsafe(addr(b_2[0]))[0]) + unsafe(unsafe(addr(b_2[0]))[1]) - unsafe(unsafe(addr(b_2[0]))[2]) - unsafe(unsafe(addr(b_2[0]))[3])
        unsafe(unsafe(addr(firstPhase[0]))[1])
    }
    if (col_7 != 0x0 && unsafe(pMb_17 - 1).decoded != 0x0) {
        L = uint(uint(1))
        L
        pData_0 = unsafe(mbPos - 1)
        pData_0
        unsafe(unsafe(addr(l_1[0]))[0]) = int(unsafe(pData_0[0]))
        unsafe(unsafe(addr(l_1[0]))[0])
        unsafe(unsafe(addr(l_1[0]))[0]) = unsafe(unsafe(addr(l_1[0]))[0]) + int(unsafe(pData_0[uint(16) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[0])
        unsafe(unsafe(addr(l_1[0]))[0]) = unsafe(unsafe(addr(l_1[0]))[0]) + int(unsafe(pData_0[uint(32) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[0])
        unsafe(unsafe(addr(l_1[0]))[0]) = unsafe(unsafe(addr(l_1[0]))[0]) + int(unsafe(pData_0[uint(48) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[0])
        pData_0 = pData_0 + uint(64) * width_18
        pData_0
        unsafe(unsafe(addr(l_1[0]))[1]) = int(unsafe(pData_0[0]))
        unsafe(unsafe(addr(l_1[0]))[1])
        unsafe(unsafe(addr(l_1[0]))[1]) = unsafe(unsafe(addr(l_1[0]))[1]) + int(unsafe(pData_0[uint(16) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[1])
        unsafe(unsafe(addr(l_1[0]))[1]) = unsafe(unsafe(addr(l_1[0]))[1]) + int(unsafe(pData_0[uint(32) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[1])
        unsafe(unsafe(addr(l_1[0]))[1]) = unsafe(unsafe(addr(l_1[0]))[1]) + int(unsafe(pData_0[uint(48) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[1])
        pData_0 = pData_0 + uint(64) * width_18
        pData_0
        unsafe(unsafe(addr(l_1[0]))[2]) = int(unsafe(pData_0[0]))
        unsafe(unsafe(addr(l_1[0]))[2])
        unsafe(unsafe(addr(l_1[0]))[2]) = unsafe(unsafe(addr(l_1[0]))[2]) + int(unsafe(pData_0[uint(16) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[2])
        unsafe(unsafe(addr(l_1[0]))[2]) = unsafe(unsafe(addr(l_1[0]))[2]) + int(unsafe(pData_0[uint(32) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[2])
        unsafe(unsafe(addr(l_1[0]))[2]) = unsafe(unsafe(addr(l_1[0]))[2]) + int(unsafe(pData_0[uint(48) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[2])
        pData_0 = pData_0 + uint(64) * width_18
        pData_0
        unsafe(unsafe(addr(l_1[0]))[3]) = int(unsafe(pData_0[0]))
        unsafe(unsafe(addr(l_1[0]))[3])
        unsafe(unsafe(addr(l_1[0]))[3]) = unsafe(unsafe(addr(l_1[0]))[3]) + int(unsafe(pData_0[uint(16) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[3])
        unsafe(unsafe(addr(l_1[0]))[3]) = unsafe(unsafe(addr(l_1[0]))[3]) + int(unsafe(pData_0[uint(32) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[3])
        unsafe(unsafe(addr(l_1[0]))[3]) = unsafe(unsafe(addr(l_1[0]))[3]) + int(unsafe(pData_0[uint(48) * width_18]))
        unsafe(unsafe(addr(l_1[0]))[3])
        j_13 = j_13 + 1
        j_13
        ver = ver + 1
        ver
        unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) + unsafe(unsafe(addr(l_1[0]))[0]) + unsafe(unsafe(addr(l_1[0]))[1]) + unsafe(unsafe(addr(l_1[0]))[2]) + unsafe(unsafe(addr(l_1[0]))[3])
        unsafe(unsafe(addr(firstPhase[0]))[0])
        unsafe(unsafe(addr(firstPhase[0]))[4]) = unsafe(unsafe(addr(firstPhase[0]))[4]) + unsafe(unsafe(addr(l_1[0]))[0]) + unsafe(unsafe(addr(l_1[0]))[1]) - unsafe(unsafe(addr(l_1[0]))[2]) - unsafe(unsafe(addr(l_1[0]))[3])
        unsafe(unsafe(addr(firstPhase[0]))[4])
    }
    if (col_7 != width_18 - uint(1) && unsafe(pMb_17 + 1).decoded != 0x0) {
        R = uint(uint(1))
        R
        pData_0 = unsafe(mbPos + 16)
        pData_0
        unsafe(unsafe(addr(r[0]))[0]) = int(unsafe(pData_0[0]))
        unsafe(unsafe(addr(r[0]))[0])
        unsafe(unsafe(addr(r[0]))[0]) = unsafe(unsafe(addr(r[0]))[0]) + int(unsafe(pData_0[uint(16) * width_18]))
        unsafe(unsafe(addr(r[0]))[0])
        unsafe(unsafe(addr(r[0]))[0]) = unsafe(unsafe(addr(r[0]))[0]) + int(unsafe(pData_0[uint(32) * width_18]))
        unsafe(unsafe(addr(r[0]))[0])
        unsafe(unsafe(addr(r[0]))[0]) = unsafe(unsafe(addr(r[0]))[0]) + int(unsafe(pData_0[uint(48) * width_18]))
        unsafe(unsafe(addr(r[0]))[0])
        pData_0 = pData_0 + uint(64) * width_18
        pData_0
        unsafe(unsafe(addr(r[0]))[1]) = int(unsafe(pData_0[0]))
        unsafe(unsafe(addr(r[0]))[1])
        unsafe(unsafe(addr(r[0]))[1]) = unsafe(unsafe(addr(r[0]))[1]) + int(unsafe(pData_0[uint(16) * width_18]))
        unsafe(unsafe(addr(r[0]))[1])
        unsafe(unsafe(addr(r[0]))[1]) = unsafe(unsafe(addr(r[0]))[1]) + int(unsafe(pData_0[uint(32) * width_18]))
        unsafe(unsafe(addr(r[0]))[1])
        unsafe(unsafe(addr(r[0]))[1]) = unsafe(unsafe(addr(r[0]))[1]) + int(unsafe(pData_0[uint(48) * width_18]))
        unsafe(unsafe(addr(r[0]))[1])
        pData_0 = pData_0 + uint(64) * width_18
        pData_0
        unsafe(unsafe(addr(r[0]))[2]) = int(unsafe(pData_0[0]))
        unsafe(unsafe(addr(r[0]))[2])
        unsafe(unsafe(addr(r[0]))[2]) = unsafe(unsafe(addr(r[0]))[2]) + int(unsafe(pData_0[uint(16) * width_18]))
        unsafe(unsafe(addr(r[0]))[2])
        unsafe(unsafe(addr(r[0]))[2]) = unsafe(unsafe(addr(r[0]))[2]) + int(unsafe(pData_0[uint(32) * width_18]))
        unsafe(unsafe(addr(r[0]))[2])
        unsafe(unsafe(addr(r[0]))[2]) = unsafe(unsafe(addr(r[0]))[2]) + int(unsafe(pData_0[uint(48) * width_18]))
        unsafe(unsafe(addr(r[0]))[2])
        pData_0 = pData_0 + uint(64) * width_18
        pData_0
        unsafe(unsafe(addr(r[0]))[3]) = int(unsafe(pData_0[0]))
        unsafe(unsafe(addr(r[0]))[3])
        unsafe(unsafe(addr(r[0]))[3]) = unsafe(unsafe(addr(r[0]))[3]) + int(unsafe(pData_0[uint(16) * width_18]))
        unsafe(unsafe(addr(r[0]))[3])
        unsafe(unsafe(addr(r[0]))[3]) = unsafe(unsafe(addr(r[0]))[3]) + int(unsafe(pData_0[uint(32) * width_18]))
        unsafe(unsafe(addr(r[0]))[3])
        unsafe(unsafe(addr(r[0]))[3]) = unsafe(unsafe(addr(r[0]))[3]) + int(unsafe(pData_0[uint(48) * width_18]))
        unsafe(unsafe(addr(r[0]))[3])
        j_13 = j_13 + 1
        j_13
        ver = ver + 1
        ver
        unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) + unsafe(unsafe(addr(r[0]))[0]) + unsafe(unsafe(addr(r[0]))[1]) + unsafe(unsafe(addr(r[0]))[2]) + unsafe(unsafe(addr(r[0]))[3])
        unsafe(unsafe(addr(firstPhase[0]))[0])
        unsafe(unsafe(addr(firstPhase[0]))[4]) = unsafe(unsafe(addr(firstPhase[0]))[4]) + unsafe(unsafe(addr(r[0]))[0]) + unsafe(unsafe(addr(r[0]))[1]) - unsafe(unsafe(addr(r[0]))[2]) - unsafe(unsafe(addr(r[0]))[3])
        unsafe(unsafe(addr(firstPhase[0]))[4])
    }
    if (hor == 0 && L != 0x0 && R != 0x0) {
        unsafe(unsafe(addr(firstPhase[0]))[1]) = unsafe(unsafe(addr(l_1[0]))[0]) + unsafe(unsafe(addr(l_1[0]))[1]) + unsafe(unsafe(addr(l_1[0]))[2]) + unsafe(unsafe(addr(l_1[0]))[3]) - unsafe(unsafe(addr(r[0]))[0]) - unsafe(unsafe(addr(r[0]))[1]) - unsafe(unsafe(addr(r[0]))[2]) - unsafe(unsafe(addr(r[0]))[3]) >> 5
        unsafe(unsafe(addr(firstPhase[0]))[1])
    } else {
        if (hor != 0x0) {
            unsafe(unsafe(addr(firstPhase[0]))[1]) = unsafe(unsafe(addr(firstPhase[0]))[1]) >> uint(3) + hor
            unsafe(unsafe(addr(firstPhase[0]))[1])
        }
    }
    if (ver == 0 && A != 0x0 && B != 0x0) {
        unsafe(unsafe(addr(firstPhase[0]))[4]) = unsafe(unsafe(addr(a_9[0]))[0]) + unsafe(unsafe(addr(a_9[0]))[1]) + unsafe(unsafe(addr(a_9[0]))[2]) + unsafe(unsafe(addr(a_9[0]))[3]) - unsafe(unsafe(addr(b_2[0]))[0]) - unsafe(unsafe(addr(b_2[0]))[1]) - unsafe(unsafe(addr(b_2[0]))[2]) - unsafe(unsafe(addr(b_2[0]))[3]) >> 5
        unsafe(unsafe(addr(firstPhase[0]))[4])
    } else {
        if (ver != 0x0) {
            unsafe(unsafe(addr(firstPhase[0]))[4]) = unsafe(unsafe(addr(firstPhase[0]))[4]) >> uint(3) + ver
            unsafe(unsafe(addr(firstPhase[0]))[4])
        }
    }
    if (j_13 == uint(1)) {
        unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) >> 4
        unsafe(unsafe(addr(firstPhase[0]))[0])
    } elif (j_13 == uint(2)) {
        unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) >> 5
        unsafe(unsafe(addr(firstPhase[0]))[0])
    } elif (j_13 == uint(3)) {
        unsafe(unsafe(addr(firstPhase[0]))[0]) = 21 * unsafe(unsafe(addr(firstPhase[0]))[0]) >> 10
        unsafe(unsafe(addr(firstPhase[0]))[0])
    } else {
        unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) >> 6
        unsafe(unsafe(addr(firstPhase[0]))[0])
    }
    Transform(unsafe(addr(firstPhase[0])))
    pTmp = unsafe(addr(firstPhase[0]))
    pTmp
    while (i_69 < uint(256)) {
        tmp_49 = unsafe(pTmp[uint(i_69 & uint(15)) >> uint(uint(2))])
        tmp_49
        pData_0 = pData_0 + 1
        var c2da_fresh60_h264bsd : int = 0
        if (tmp_49 > 255) {
            c2da_fresh60_h264bsd = 255
        } else {
            c2da_fresh60_h264bsd = tmp_49
        }
        var c2da_fresh61_h264bsd : int = 0
        if (tmp_49 < 0) {
            c2da_fresh61_h264bsd = 0
        } else {
            c2da_fresh61_h264bsd = c2da_fresh60_h264bsd
        }
        *pData_0 = uint8(uint8(c2da_fresh61_h264bsd))
        *pData_0
        i_69 = i_69 + 1
        i_69
        if (i_69 & uint(63) == 0) {
            pTmp = pTmp + 4
            pTmp
        }
    }
    mbPos = unsafe(unsafe(unsafe(currImage_2.data + width_18 * height_15 * uint(256)) + row_7 * uint(8) * width_18 * uint(8)) + col_7 * uint(8))
    mbPos
    comp_3 = uint(uint(0))
    comp_3
    while (comp_3 < uint(2)) {
        memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(firstPhase[0]))))), 0, 4)
        j_13 = uint(uint(0))
        j_13
        ver = uint(uint(0))
        hor = uint(ver)
        hor
        if (A != 0x0) {
            pData_0 = unsafe(mbPos - width_18 * uint(8))
            pData_0
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(a_9[0]))[0]) = int(*pData_0)
            unsafe(unsafe(addr(a_9[0]))[0])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(a_9[0]))[0]) = unsafe(unsafe(addr(a_9[0]))[0]) + int(*pData_0)
            unsafe(unsafe(addr(a_9[0]))[0])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(a_9[0]))[1]) = int(*pData_0)
            unsafe(unsafe(addr(a_9[0]))[1])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(a_9[0]))[1]) = unsafe(unsafe(addr(a_9[0]))[1]) + int(*pData_0)
            unsafe(unsafe(addr(a_9[0]))[1])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(a_9[0]))[2]) = int(*pData_0)
            unsafe(unsafe(addr(a_9[0]))[2])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(a_9[0]))[2]) = unsafe(unsafe(addr(a_9[0]))[2]) + int(*pData_0)
            unsafe(unsafe(addr(a_9[0]))[2])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(a_9[0]))[3]) = int(*pData_0)
            unsafe(unsafe(addr(a_9[0]))[3])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(a_9[0]))[3]) = unsafe(unsafe(addr(a_9[0]))[3]) + int(*pData_0)
            unsafe(unsafe(addr(a_9[0]))[3])
            j_13 = j_13 + 1
            j_13
            hor = hor + 1
            hor
            unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) + unsafe(unsafe(addr(a_9[0]))[0]) + unsafe(unsafe(addr(a_9[0]))[1]) + unsafe(unsafe(addr(a_9[0]))[2]) + unsafe(unsafe(addr(a_9[0]))[3])
            unsafe(unsafe(addr(firstPhase[0]))[0])
            unsafe(unsafe(addr(firstPhase[0]))[1]) = unsafe(unsafe(addr(firstPhase[0]))[1]) + unsafe(unsafe(addr(a_9[0]))[0]) + unsafe(unsafe(addr(a_9[0]))[1]) - unsafe(unsafe(addr(a_9[0]))[2]) - unsafe(unsafe(addr(a_9[0]))[3])
            unsafe(unsafe(addr(firstPhase[0]))[1])
        }
        if (B != 0x0) {
            pData_0 = unsafe(mbPos + uint(8) * width_18 * uint(8))
            pData_0
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(b_2[0]))[0]) = int(*pData_0)
            unsafe(unsafe(addr(b_2[0]))[0])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(b_2[0]))[0]) = unsafe(unsafe(addr(b_2[0]))[0]) + int(*pData_0)
            unsafe(unsafe(addr(b_2[0]))[0])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(b_2[0]))[1]) = int(*pData_0)
            unsafe(unsafe(addr(b_2[0]))[1])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(b_2[0]))[1]) = unsafe(unsafe(addr(b_2[0]))[1]) + int(*pData_0)
            unsafe(unsafe(addr(b_2[0]))[1])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(b_2[0]))[2]) = int(*pData_0)
            unsafe(unsafe(addr(b_2[0]))[2])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(b_2[0]))[2]) = unsafe(unsafe(addr(b_2[0]))[2]) + int(*pData_0)
            unsafe(unsafe(addr(b_2[0]))[2])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(b_2[0]))[3]) = int(*pData_0)
            unsafe(unsafe(addr(b_2[0]))[3])
            pData_0 = pData_0 + 1
            unsafe(unsafe(addr(b_2[0]))[3]) = unsafe(unsafe(addr(b_2[0]))[3]) + int(*pData_0)
            unsafe(unsafe(addr(b_2[0]))[3])
            j_13 = j_13 + 1
            j_13
            hor = hor + 1
            hor
            unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) + unsafe(unsafe(addr(b_2[0]))[0]) + unsafe(unsafe(addr(b_2[0]))[1]) + unsafe(unsafe(addr(b_2[0]))[2]) + unsafe(unsafe(addr(b_2[0]))[3])
            unsafe(unsafe(addr(firstPhase[0]))[0])
            unsafe(unsafe(addr(firstPhase[0]))[1]) = unsafe(unsafe(addr(firstPhase[0]))[1]) + unsafe(unsafe(addr(b_2[0]))[0]) + unsafe(unsafe(addr(b_2[0]))[1]) - unsafe(unsafe(addr(b_2[0]))[2]) - unsafe(unsafe(addr(b_2[0]))[3])
            unsafe(unsafe(addr(firstPhase[0]))[1])
        }
        if (L != 0x0) {
            pData_0 = unsafe(mbPos - 1)
            pData_0
            unsafe(unsafe(addr(l_1[0]))[0]) = int(unsafe(pData_0[0]))
            unsafe(unsafe(addr(l_1[0]))[0])
            unsafe(unsafe(addr(l_1[0]))[0]) = unsafe(unsafe(addr(l_1[0]))[0]) + int(unsafe(pData_0[uint(8) * width_18]))
            unsafe(unsafe(addr(l_1[0]))[0])
            pData_0 = pData_0 + uint(16) * width_18
            pData_0
            unsafe(unsafe(addr(l_1[0]))[1]) = int(unsafe(pData_0[0]))
            unsafe(unsafe(addr(l_1[0]))[1])
            unsafe(unsafe(addr(l_1[0]))[1]) = unsafe(unsafe(addr(l_1[0]))[1]) + int(unsafe(pData_0[uint(8) * width_18]))
            unsafe(unsafe(addr(l_1[0]))[1])
            pData_0 = pData_0 + uint(16) * width_18
            pData_0
            unsafe(unsafe(addr(l_1[0]))[2]) = int(unsafe(pData_0[0]))
            unsafe(unsafe(addr(l_1[0]))[2])
            unsafe(unsafe(addr(l_1[0]))[2]) = unsafe(unsafe(addr(l_1[0]))[2]) + int(unsafe(pData_0[uint(8) * width_18]))
            unsafe(unsafe(addr(l_1[0]))[2])
            pData_0 = pData_0 + uint(16) * width_18
            pData_0
            unsafe(unsafe(addr(l_1[0]))[3]) = int(unsafe(pData_0[0]))
            unsafe(unsafe(addr(l_1[0]))[3])
            unsafe(unsafe(addr(l_1[0]))[3]) = unsafe(unsafe(addr(l_1[0]))[3]) + int(unsafe(pData_0[uint(8) * width_18]))
            unsafe(unsafe(addr(l_1[0]))[3])
            j_13 = j_13 + 1
            j_13
            ver = ver + 1
            ver
            unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) + unsafe(unsafe(addr(l_1[0]))[0]) + unsafe(unsafe(addr(l_1[0]))[1]) + unsafe(unsafe(addr(l_1[0]))[2]) + unsafe(unsafe(addr(l_1[0]))[3])
            unsafe(unsafe(addr(firstPhase[0]))[0])
            unsafe(unsafe(addr(firstPhase[0]))[4]) = unsafe(unsafe(addr(firstPhase[0]))[4]) + unsafe(unsafe(addr(l_1[0]))[0]) + unsafe(unsafe(addr(l_1[0]))[1]) - unsafe(unsafe(addr(l_1[0]))[2]) - unsafe(unsafe(addr(l_1[0]))[3])
            unsafe(unsafe(addr(firstPhase[0]))[4])
        }
        if (R != 0x0) {
            pData_0 = unsafe(mbPos + 8)
            pData_0
            unsafe(unsafe(addr(r[0]))[0]) = int(unsafe(pData_0[0]))
            unsafe(unsafe(addr(r[0]))[0])
            unsafe(unsafe(addr(r[0]))[0]) = unsafe(unsafe(addr(r[0]))[0]) + int(unsafe(pData_0[uint(8) * width_18]))
            unsafe(unsafe(addr(r[0]))[0])
            pData_0 = pData_0 + uint(16) * width_18
            pData_0
            unsafe(unsafe(addr(r[0]))[1]) = int(unsafe(pData_0[0]))
            unsafe(unsafe(addr(r[0]))[1])
            unsafe(unsafe(addr(r[0]))[1]) = unsafe(unsafe(addr(r[0]))[1]) + int(unsafe(pData_0[uint(8) * width_18]))
            unsafe(unsafe(addr(r[0]))[1])
            pData_0 = pData_0 + uint(16) * width_18
            pData_0
            unsafe(unsafe(addr(r[0]))[2]) = int(unsafe(pData_0[0]))
            unsafe(unsafe(addr(r[0]))[2])
            unsafe(unsafe(addr(r[0]))[2]) = unsafe(unsafe(addr(r[0]))[2]) + int(unsafe(pData_0[uint(8) * width_18]))
            unsafe(unsafe(addr(r[0]))[2])
            pData_0 = pData_0 + uint(16) * width_18
            pData_0
            unsafe(unsafe(addr(r[0]))[3]) = int(unsafe(pData_0[0]))
            unsafe(unsafe(addr(r[0]))[3])
            unsafe(unsafe(addr(r[0]))[3]) = unsafe(unsafe(addr(r[0]))[3]) + int(unsafe(pData_0[uint(8) * width_18]))
            unsafe(unsafe(addr(r[0]))[3])
            j_13 = j_13 + 1
            j_13
            ver = ver + 1
            ver
            unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) + unsafe(unsafe(addr(r[0]))[0]) + unsafe(unsafe(addr(r[0]))[1]) + unsafe(unsafe(addr(r[0]))[2]) + unsafe(unsafe(addr(r[0]))[3])
            unsafe(unsafe(addr(firstPhase[0]))[0])
            unsafe(unsafe(addr(firstPhase[0]))[4]) = unsafe(unsafe(addr(firstPhase[0]))[4]) + unsafe(unsafe(addr(r[0]))[0]) + unsafe(unsafe(addr(r[0]))[1]) - unsafe(unsafe(addr(r[0]))[2]) - unsafe(unsafe(addr(r[0]))[3])
            unsafe(unsafe(addr(firstPhase[0]))[4])
        }
        if (hor == 0 && L != 0x0 && R != 0x0) {
            unsafe(unsafe(addr(firstPhase[0]))[1]) = unsafe(unsafe(addr(l_1[0]))[0]) + unsafe(unsafe(addr(l_1[0]))[1]) + unsafe(unsafe(addr(l_1[0]))[2]) + unsafe(unsafe(addr(l_1[0]))[3]) - unsafe(unsafe(addr(r[0]))[0]) - unsafe(unsafe(addr(r[0]))[1]) - unsafe(unsafe(addr(r[0]))[2]) - unsafe(unsafe(addr(r[0]))[3]) >> 4
            unsafe(unsafe(addr(firstPhase[0]))[1])
        } else {
            if (hor != 0x0) {
                unsafe(unsafe(addr(firstPhase[0]))[1]) = unsafe(unsafe(addr(firstPhase[0]))[1]) >> uint(2) + hor
                unsafe(unsafe(addr(firstPhase[0]))[1])
            }
        }
        if (ver == 0 && A != 0x0 && B != 0x0) {
            unsafe(unsafe(addr(firstPhase[0]))[4]) = unsafe(unsafe(addr(a_9[0]))[0]) + unsafe(unsafe(addr(a_9[0]))[1]) + unsafe(unsafe(addr(a_9[0]))[2]) + unsafe(unsafe(addr(a_9[0]))[3]) - unsafe(unsafe(addr(b_2[0]))[0]) - unsafe(unsafe(addr(b_2[0]))[1]) - unsafe(unsafe(addr(b_2[0]))[2]) - unsafe(unsafe(addr(b_2[0]))[3]) >> 4
            unsafe(unsafe(addr(firstPhase[0]))[4])
        } else {
            if (ver != 0x0) {
                unsafe(unsafe(addr(firstPhase[0]))[4]) = unsafe(unsafe(addr(firstPhase[0]))[4]) >> uint(2) + ver
                unsafe(unsafe(addr(firstPhase[0]))[4])
            }
        }
        if (j_13 == uint(1)) {
            unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) >> 3
            unsafe(unsafe(addr(firstPhase[0]))[0])
        } elif (j_13 == uint(2)) {
            unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) >> 4
            unsafe(unsafe(addr(firstPhase[0]))[0])
        } elif (j_13 == uint(3)) {
            unsafe(unsafe(addr(firstPhase[0]))[0]) = 21 * unsafe(unsafe(addr(firstPhase[0]))[0]) >> 9
            unsafe(unsafe(addr(firstPhase[0]))[0])
        } else {
            unsafe(unsafe(addr(firstPhase[0]))[0]) = unsafe(unsafe(addr(firstPhase[0]))[0]) >> 5
            unsafe(unsafe(addr(firstPhase[0]))[0])
        }
        Transform(unsafe(addr(firstPhase[0])))
        pData_0 = unsafe(unsafe(unsafe(addr(data_31[0])) + 256) + comp_3 * uint(64))
        pData_0
        pTmp = unsafe(addr(firstPhase[0]))
        pTmp
        while (i_69 < uint(64)) {
            tmp_49 = unsafe(pTmp[uint(i_69 & uint(7)) >> uint(uint(1))])
            tmp_49
            pData_0 = pData_0 + 1
            var c2da_fresh62_h264bsd : int = 0
            if (tmp_49 > 255) {
                c2da_fresh62_h264bsd = 255
            } else {
                c2da_fresh62_h264bsd = tmp_49
            }
            var c2da_fresh63_h264bsd : int = 0
            if (tmp_49 < 0) {
                c2da_fresh63_h264bsd = 0
            } else {
                c2da_fresh63_h264bsd = c2da_fresh62_h264bsd
            }
            *pData_0 = uint8(uint8(c2da_fresh63_h264bsd))
            *pData_0
            i_69 = i_69 + 1
            i_69
            if (i_69 & uint(15) == 0) {
                pTmp = pTmp + 4
                pTmp
            }
        }
        mbPos = mbPos + width_18 * height_15 * uint(64)
        mbPos
        comp_3 = comp_3 + 1
    }
    h264bsdWriteMacroblock(currImage_2, unsafe(addr(data_31[0])))
    return uint(0)
}
[export]
def Transform(var data_32 : int?) {
    var col_8 : uint
    var tmp0_2 : int
    var tmp1_17 : int
    if (unsafe(data_32[1]) == 0 && unsafe(data_32[4]) == 0) {
        unsafe(data_32[15]) = unsafe(data_32[0])
        unsafe(data_32[14]) = unsafe(data_32[15])
        unsafe(data_32[13]) = unsafe(data_32[14])
        unsafe(data_32[12]) = unsafe(data_32[13])
        unsafe(data_32[11]) = unsafe(data_32[12])
        unsafe(data_32[10]) = unsafe(data_32[11])
        unsafe(data_32[9]) = unsafe(data_32[10])
        unsafe(data_32[8]) = unsafe(data_32[9])
        unsafe(data_32[7]) = unsafe(data_32[8])
        unsafe(data_32[6]) = unsafe(data_32[7])
        unsafe(data_32[5]) = unsafe(data_32[6])
        unsafe(data_32[4]) = unsafe(data_32[5])
        unsafe(data_32[3]) = unsafe(data_32[4])
        unsafe(data_32[2]) = unsafe(data_32[3])
        unsafe(data_32[1]) = unsafe(data_32[2])
        unsafe(data_32[1])
        return
    }
    tmp0_2 = unsafe(data_32[0])
    tmp0_2
    tmp1_17 = unsafe(data_32[1])
    tmp1_17
    unsafe(data_32[0]) = tmp0_2 + tmp1_17
    unsafe(data_32[0])
    unsafe(data_32[1]) = tmp0_2 + tmp1_17 >> 1
    unsafe(data_32[1])
    unsafe(data_32[2]) = tmp0_2 - tmp1_17 >> 1
    unsafe(data_32[2])
    unsafe(data_32[3]) = tmp0_2 - tmp1_17
    unsafe(data_32[3])
    tmp0_2 = unsafe(data_32[4])
    tmp0_2
    unsafe(data_32[5]) = tmp0_2
    unsafe(data_32[5])
    unsafe(data_32[6]) = tmp0_2
    unsafe(data_32[6])
    unsafe(data_32[7]) = tmp0_2
    unsafe(data_32[7])
    col_8 = uint(uint(4))
    col_8
    while (col_8 != 0x0) {
        tmp0_2 = unsafe(data_32[0])
        tmp0_2
        tmp1_17 = unsafe(data_32[4])
        tmp1_17
        unsafe(data_32[0]) = tmp0_2 + tmp1_17
        unsafe(data_32[0])
        unsafe(data_32[4]) = tmp0_2 + tmp1_17 >> 1
        unsafe(data_32[4])
        unsafe(data_32[8]) = tmp0_2 - tmp1_17 >> 1
        unsafe(data_32[8])
        unsafe(data_32[12]) = tmp0_2 - tmp1_17
        unsafe(data_32[12])
        data_32 = data_32 + 1
    }
}
[export]
def h264bsdFilterPicture(var image_5 : image_t?; var mb_8 : mbStorage_t?) {
    var flags : uint
    var picSizeInMbs_6 : uint
    var mbRow : uint
    var mbCol : uint
    var picWidthInMbs : uint
    var data_33 : uint8?
    var pMb_18 : mbStorage_t?
    var bS : array<bS_t> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var thresholds : array<edgeThreshold_t> = [0, 0, 0]
    picWidthInMbs = uint(image_5.width)
    picWidthInMbs
    data_33 = image_5.data
    data_33
    picSizeInMbs_6 = uint(picWidthInMbs * image_5.height)
    picSizeInMbs_6
    pMb_18 = mb_8
    pMb_18
    mbCol = uint(uint(0))
    mbCol
    while (mbRow < image_5.height) {
        flags = uint(GetMbFilteringFlags(pMb_18))
        flags
        if (flags != 0x0) {
            if (GetBoundaryStrengths(pMb_18, unsafe(addr(bS[0])), flags) != 0x0) {
                GetLumaEdgeThresholds(unsafe(addr(thresholds[0])), pMb_18, flags)
                data_33 = unsafe(unsafe(image_5.data + mbRow * picWidthInMbs * uint(256)) + mbCol * uint(16))
                data_33
                FilterLuma(cast<uint8?>(data_33), unsafe(addr(bS[0])), unsafe(addr(thresholds[0])), picWidthInMbs * uint(16))
                GetChromaEdgeThresholds(unsafe(addr(thresholds[0])), pMb_18, flags, pMb_18.chromaQpIndexOffset)
                data_33 = unsafe(unsafe(unsafe(image_5.data + picSizeInMbs_6 * uint(256)) + mbRow * picWidthInMbs * uint(64)) + mbCol * uint(8))
                data_33
                FilterChroma(cast<uint8?>(data_33), unsafe(data_33 + uint(64) * picSizeInMbs_6), unsafe(addr(bS[0])), unsafe(addr(thresholds[0])), picWidthInMbs * uint(8))
            }
        }
        mbCol = mbCol + 1
        mbCol
        if (mbCol == picWidthInMbs) {
            mbCol = uint(uint(0))
            mbCol
            mbRow = mbRow + 1
            mbRow
        }
        pMb_18 = pMb_18 + 1
    }
}
[export]
def FilterChroma(var dataCb : uint8?; var dataCr : uint8?; var bS_0 : bS_t?; var thresholds_0 : edgeThreshold_t?; var width_19 : uint) {
    var vblock : uint
    var tmp_50 : bS_t?
    var offset : uint
    tmp_50 = bS_0
    tmp_50
    offset = uint(uint(TOP))
    offset
    vblock = uint(uint(0))
    vblock
    while (vblock < uint(2)) {
        if (unsafe(tmp_50[0]).left != 0x0) {
            FilterVerChromaEdge(dataCb, unsafe(tmp_50[0]).left, unsafe(thresholds_0 + LEFT), width_19)
            FilterVerChromaEdge(dataCr, unsafe(tmp_50[0]).left, unsafe(thresholds_0 + LEFT), width_19)
        }
        if (unsafe(tmp_50[4]).left != 0x0) {
            FilterVerChromaEdge(unsafe(dataCb + uint(2) * width_19), unsafe(tmp_50[4]).left, unsafe(thresholds_0 + LEFT), width_19)
            FilterVerChromaEdge(unsafe(dataCr + uint(2) * width_19), unsafe(tmp_50[4]).left, unsafe(thresholds_0 + LEFT), width_19)
        }
        if (unsafe(tmp_50[2]).left != 0x0) {
            FilterVerChromaEdge(unsafe(dataCb + 4), unsafe(tmp_50[2]).left, unsafe(thresholds_0 + INNER), width_19)
            FilterVerChromaEdge(unsafe(dataCr + 4), unsafe(tmp_50[2]).left, unsafe(thresholds_0 + INNER), width_19)
        }
        if (unsafe(tmp_50[6]).left != 0x0) {
            FilterVerChromaEdge(unsafe(unsafe(dataCb + uint(2) * width_19) + 4), unsafe(tmp_50[6]).left, unsafe(thresholds_0 + INNER), width_19)
            FilterVerChromaEdge(unsafe(unsafe(dataCr + uint(2) * width_19) + 4), unsafe(tmp_50[6]).left, unsafe(thresholds_0 + INNER), width_19)
        }
        if (unsafe(tmp_50[0]).top == unsafe(tmp_50[1]).top && unsafe(tmp_50[1]).top == unsafe(tmp_50[2]).top && unsafe(tmp_50[2]).top == unsafe(tmp_50[3]).top) {
            if (unsafe(tmp_50[0]).top != 0x0) {
                FilterHorChroma(dataCb, unsafe(tmp_50[0]).top, unsafe(thresholds_0 + offset), int(width_19))
                FilterHorChroma(dataCr, unsafe(tmp_50[0]).top, unsafe(thresholds_0 + offset), int(width_19))
            }
        } else {
            if (unsafe(tmp_50[0]).top != 0x0) {
                FilterHorChromaEdge(dataCb, unsafe(tmp_50[0]).top, unsafe(thresholds_0 + offset), int(width_19))
                FilterHorChromaEdge(dataCr, unsafe(tmp_50[0]).top, unsafe(thresholds_0 + offset), int(width_19))
            }
            if (unsafe(tmp_50[1]).top != 0x0) {
                FilterHorChromaEdge(unsafe(dataCb + 2), unsafe(tmp_50[1]).top, unsafe(thresholds_0 + offset), int(width_19))
                FilterHorChromaEdge(unsafe(dataCr + 2), unsafe(tmp_50[1]).top, unsafe(thresholds_0 + offset), int(width_19))
            }
            if (unsafe(tmp_50[2]).top != 0x0) {
                FilterHorChromaEdge(unsafe(dataCb + 4), unsafe(tmp_50[2]).top, unsafe(thresholds_0 + offset), int(width_19))
                FilterHorChromaEdge(unsafe(dataCr + 4), unsafe(tmp_50[2]).top, unsafe(thresholds_0 + offset), int(width_19))
            }
            if (unsafe(tmp_50[3]).top != 0x0) {
                FilterHorChromaEdge(unsafe(dataCb + 6), unsafe(tmp_50[3]).top, unsafe(thresholds_0 + offset), int(width_19))
                FilterHorChromaEdge(unsafe(dataCr + 6), unsafe(tmp_50[3]).top, unsafe(thresholds_0 + offset), int(width_19))
            }
        }
        tmp_50 = tmp_50 + 8
        tmp_50
        dataCb = dataCb + width_19 * uint(4)
        dataCb
        dataCr = dataCr + width_19 * uint(4)
        dataCr
        offset = uint(uint(INNER))
        offset
        vblock = vblock + 1
    }
}
[export]
def FilterHorChromaEdge(var data_34 : uint8?; var bS_1 : uint; var thresholds_1 : edgeThreshold_t?; var width_20 : int) {
    var delta : int
    var tc : int
    var i_70 : uint
    var p0 : uint8
    var q0 : uint8
    var p1_7 : uint8
    var q1 : uint8
    var clp_10 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    tc = int(unsafe(thresholds_1.tc0[bS_1 - uint(1)])) + 1
    tc
    i_70 = uint(uint(2))
    i_70
    while (i_70 != 0x0) {
        p1_7 = uint8(unsafe(data_34[-width_20 * 2]))
        p1_7
        p0 = uint8(unsafe(data_34[-width_20]))
        p0
        q0 = uint8(unsafe(data_34[0]))
        q0
        q1 = uint8(unsafe(data_34[width_20]))
        q1
        if (uint(c2da_fresh64_h264bsd) < thresholds_1.alpha && uint(c2da_fresh65_h264bsd) < thresholds_1.beta && uint(c2da_fresh66_h264bsd) < thresholds_1.beta) {
            var c2da_fresh67_h264bsd : int = 0
            if (int(q0) - int(p0) << 2 + int(p1_7) - int(q1) + 4 >> 3 > tc) {
                c2da_fresh67_h264bsd = tc
            } else {
                c2da_fresh67_h264bsd = int(q0) - int(p0) << 2 + int(p1_7) - int(q1) + 4 >> 3
            }
            var c2da_fresh68_h264bsd : int = 0
            if (int(q0) - int(p0) << 2 + int(p1_7) - int(q1) + 4 >> 3 < -tc) {
                c2da_fresh68_h264bsd = -tc
            } else {
                c2da_fresh68_h264bsd = c2da_fresh67_h264bsd
            }
            delta = c2da_fresh68_h264bsd
            delta
            p0 = uint8(unsafe(clp_10[int(p0) + delta]))
            p0
            q0 = uint8(unsafe(clp_10[int(q0) - delta]))
            q0
            unsafe(data_34[-width_20]) = uint8(p0)
            unsafe(data_34[-width_20])
            unsafe(data_34[0]) = uint8(q0)
            unsafe(data_34[0])
        }
        data_34 = data_34 + 1
    }
}
[export]
def FilterHorChroma(var data_35 : uint8?; var bS_2 : uint; var thresholds_2 : edgeThreshold_t?; var width_21 : int) {
    var delta_0 : int
    var tc_0 : int
    var i_71 : uint
    var p0_0 : uint8
    var q0_0 : uint8
    var p1_8 : uint8
    var q1_0 : uint8
    var clp_11 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    if (bS_2 < uint(4)) {
        tc_0 = int(unsafe(thresholds_2.tc0[bS_2 - uint(1)])) + 1
        tc_0
        i_71 = uint(uint(8))
        i_71
        while (i_71 != 0x0) {
            p1_8 = uint8(unsafe(data_35[-width_21 * 2]))
            p1_8
            p0_0 = uint8(unsafe(data_35[-width_21]))
            p0_0
            q0_0 = uint8(unsafe(data_35[0]))
            q0_0
            q1_0 = uint8(unsafe(data_35[width_21]))
            q1_0
            if (uint(c2da_fresh69_h264bsd) < thresholds_2.alpha && uint(c2da_fresh70_h264bsd) < thresholds_2.beta && uint(c2da_fresh71_h264bsd) < thresholds_2.beta) {
                var c2da_fresh72_h264bsd : int = 0
                if (int(q0_0) - int(p0_0) << 2 + int(p1_8) - int(q1_0) + 4 >> 3 > tc_0) {
                    c2da_fresh72_h264bsd = tc_0
                } else {
                    c2da_fresh72_h264bsd = int(q0_0) - int(p0_0) << 2 + int(p1_8) - int(q1_0) + 4 >> 3
                }
                var c2da_fresh73_h264bsd : int = 0
                if (int(q0_0) - int(p0_0) << 2 + int(p1_8) - int(q1_0) + 4 >> 3 < -tc_0) {
                    c2da_fresh73_h264bsd = -tc_0
                } else {
                    c2da_fresh73_h264bsd = c2da_fresh72_h264bsd
                }
                delta_0 = c2da_fresh73_h264bsd
                delta_0
                p0_0 = uint8(unsafe(clp_11[int(p0_0) + delta_0]))
                p0_0
                q0_0 = uint8(unsafe(clp_11[int(q0_0) - delta_0]))
                q0_0
                unsafe(data_35[-width_21]) = uint8(p0_0)
                unsafe(data_35[-width_21])
                unsafe(data_35[0]) = uint8(q0_0)
                unsafe(data_35[0])
            }
            data_35 = data_35 + 1
        }
    } else {
        i_71 = uint(uint(8))
        i_71
        while (i_71 != 0x0) {
            p1_8 = uint8(unsafe(data_35[-width_21 * 2]))
            p1_8
            p0_0 = uint8(unsafe(data_35[-width_21]))
            p0_0
            q0_0 = uint8(unsafe(data_35[0]))
            q0_0
            q1_0 = uint8(unsafe(data_35[width_21]))
            q1_0
            if (uint(c2da_fresh74_h264bsd) < thresholds_2.alpha && uint(c2da_fresh75_h264bsd) < thresholds_2.beta && uint(c2da_fresh76_h264bsd) < thresholds_2.beta) {
                unsafe(data_35[-width_21]) = uint8(uint8(2 * int(p1_8) + int(p0_0) + int(q1_0) + 2 >> 2))
                unsafe(data_35[-width_21])
                unsafe(data_35[0]) = uint8(uint8(2 * int(q1_0) + int(q0_0) + int(p1_8) + 2 >> 2))
                unsafe(data_35[0])
            }
            data_35 = data_35 + 1
        }
    }
}
[export]
def FilterVerChromaEdge(var data_36 : uint8?; var bS_3 : uint; var thresholds_3 : edgeThreshold_t?; var width_22 : uint) {
    var delta_1 : int
    var tc_1 : int
    var p0_1 : uint8
    var q0_1 : uint8
    var p1_9 : uint8
    var q1_1 : uint8
    var clp_12 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    p1_9 = uint8(unsafe(data_36[-2]))
    p1_9
    p0_1 = uint8(unsafe(data_36[-1]))
    p0_1
    q0_1 = uint8(unsafe(data_36[0]))
    q0_1
    q1_1 = uint8(unsafe(data_36[1]))
    q1_1
    if (uint(c2da_fresh77_h264bsd) < thresholds_3.alpha && uint(c2da_fresh78_h264bsd) < thresholds_3.beta && uint(c2da_fresh79_h264bsd) < thresholds_3.beta) {
        if (bS_3 < uint(4)) {
            tc_1 = int(unsafe(thresholds_3.tc0[bS_3 - uint(1)])) + 1
            tc_1
            var c2da_fresh80_h264bsd : int = 0
            if (int(q0_1) - int(p0_1) << 2 + int(p1_9) - int(q1_1) + 4 >> 3 > tc_1) {
                c2da_fresh80_h264bsd = tc_1
            } else {
                c2da_fresh80_h264bsd = int(q0_1) - int(p0_1) << 2 + int(p1_9) - int(q1_1) + 4 >> 3
            }
            var c2da_fresh81_h264bsd : int = 0
            if (int(q0_1) - int(p0_1) << 2 + int(p1_9) - int(q1_1) + 4 >> 3 < -tc_1) {
                c2da_fresh81_h264bsd = -tc_1
            } else {
                c2da_fresh81_h264bsd = c2da_fresh80_h264bsd
            }
            delta_1 = c2da_fresh81_h264bsd
            delta_1
            p0_1 = uint8(unsafe(clp_12[int(p0_1) + delta_1]))
            p0_1
            q0_1 = uint8(unsafe(clp_12[int(q0_1) - delta_1]))
            q0_1
            unsafe(data_36[-1]) = uint8(p0_1)
            unsafe(data_36[-1])
            unsafe(data_36[0]) = uint8(q0_1)
            unsafe(data_36[0])
        } else {
            unsafe(data_36[-1]) = uint8(uint8(2 * int(p1_9) + int(p0_1) + int(q1_1) + 2 >> 2))
            unsafe(data_36[-1])
            unsafe(data_36[0]) = uint8(uint8(2 * int(q1_1) + int(q0_1) + int(p1_9) + 2 >> 2))
            unsafe(data_36[0])
        }
    }
    data_36 = data_36 + width_22
    data_36
    p1_9 = uint8(unsafe(data_36[-2]))
    p1_9
    p0_1 = uint8(unsafe(data_36[-1]))
    p0_1
    q0_1 = uint8(unsafe(data_36[0]))
    q0_1
    q1_1 = uint8(unsafe(data_36[1]))
    q1_1
    if (uint(c2da_fresh82_h264bsd) < thresholds_3.alpha && uint(c2da_fresh83_h264bsd) < thresholds_3.beta && uint(c2da_fresh84_h264bsd) < thresholds_3.beta) {
        if (bS_3 < uint(4)) {
            tc_1 = int(unsafe(thresholds_3.tc0[bS_3 - uint(1)])) + 1
            tc_1
            var c2da_fresh85_h264bsd : int = 0
            if (int(q0_1) - int(p0_1) << 2 + int(p1_9) - int(q1_1) + 4 >> 3 > tc_1) {
                c2da_fresh85_h264bsd = tc_1
            } else {
                c2da_fresh85_h264bsd = int(q0_1) - int(p0_1) << 2 + int(p1_9) - int(q1_1) + 4 >> 3
            }
            var c2da_fresh86_h264bsd : int = 0
            if (int(q0_1) - int(p0_1) << 2 + int(p1_9) - int(q1_1) + 4 >> 3 < -tc_1) {
                c2da_fresh86_h264bsd = -tc_1
            } else {
                c2da_fresh86_h264bsd = c2da_fresh85_h264bsd
            }
            delta_1 = c2da_fresh86_h264bsd
            delta_1
            p0_1 = uint8(unsafe(clp_12[int(p0_1) + delta_1]))
            p0_1
            q0_1 = uint8(unsafe(clp_12[int(q0_1) - delta_1]))
            q0_1
            unsafe(data_36[-1]) = uint8(p0_1)
            unsafe(data_36[-1])
            unsafe(data_36[0]) = uint8(q0_1)
            unsafe(data_36[0])
        } else {
            unsafe(data_36[-1]) = uint8(uint8(2 * int(p1_9) + int(p0_1) + int(q1_1) + 2 >> 2))
            unsafe(data_36[-1])
            unsafe(data_36[0]) = uint8(uint8(2 * int(q1_1) + int(q0_1) + int(p1_9) + 2 >> 2))
            unsafe(data_36[0])
        }
    }
}
[export]
def GetChromaEdgeThresholds(var thresholds_4 : edgeThreshold_t?; var mb_9 : mbStorage_t?; var filteringFlags : uint; var chromaQpIndexOffset : int) {
    var indexA : uint
    var indexB : uint
    var qpAv : uint
    var qp_2 : uint
    var qpTmp : uint
    qp_2 = uint(mb_9.qpY)
    qp_2
    var c2da_fresh87_h264bsd : int = 0
    if (int(qp_2) + chromaQpIndexOffset > 51) {
        c2da_fresh87_h264bsd = 51
    } else {
        c2da_fresh87_h264bsd = int(qp_2) + chromaQpIndexOffset
    }
    var c2da_fresh88_h264bsd : int = 0
    if (int(qp_2) + chromaQpIndexOffset < 0) {
        c2da_fresh88_h264bsd = 0
    } else {
        c2da_fresh88_h264bsd = c2da_fresh87_h264bsd
    }
    qp_2 = uint(unsafe(unsafe(addr(h264bsdQpC[0]))[c2da_fresh88_h264bsd]))
    qp_2
    var c2da_fresh89_h264bsd : int = 0
    if (int(qp_2) + mb_9.filterOffsetA > 51) {
        c2da_fresh89_h264bsd = 51
    } else {
        c2da_fresh89_h264bsd = int(qp_2) + mb_9.filterOffsetA
    }
    var c2da_fresh90_h264bsd : int = 0
    if (int(qp_2) + mb_9.filterOffsetA < 0) {
        c2da_fresh90_h264bsd = 0
    } else {
        c2da_fresh90_h264bsd = c2da_fresh89_h264bsd
    }
    indexA = uint(uint(c2da_fresh90_h264bsd))
    indexA
    var c2da_fresh91_h264bsd : int = 0
    if (int(qp_2) + mb_9.filterOffsetB > 51) {
        c2da_fresh91_h264bsd = 51
    } else {
        c2da_fresh91_h264bsd = int(qp_2) + mb_9.filterOffsetB
    }
    var c2da_fresh92_h264bsd : int = 0
    if (int(qp_2) + mb_9.filterOffsetB < 0) {
        c2da_fresh92_h264bsd = 0
    } else {
        c2da_fresh92_h264bsd = c2da_fresh91_h264bsd
    }
    indexB = uint(uint(c2da_fresh92_h264bsd))
    indexB
    unsafe(thresholds_4[INNER]).alpha = uint(uint(unsafe(unsafe(addr(alphas[0]))[indexA])))
    unsafe(thresholds_4[INNER]).alpha
    unsafe(thresholds_4[INNER]).beta = uint(uint(unsafe(unsafe(addr(betas[0]))[indexB])))
    unsafe(thresholds_4[INNER]).beta
    unsafe(thresholds_4[INNER]).tc0 = unsafe(addr(unsafe(unsafe(addr(tc0[0]))[indexA])[0]))
    unsafe(thresholds_4[INNER]).tc0
    if (filteringFlags & uint(2) != 0x0) {
        qpTmp = uint(mb_9.mbB.qpY)
        qpTmp
        if (qpTmp != mb_9.qpY) {
            var c2da_fresh93_h264bsd : int = 0
            if (int(qpTmp) + chromaQpIndexOffset > 51) {
                c2da_fresh93_h264bsd = 51
            } else {
                c2da_fresh93_h264bsd = int(qpTmp) + chromaQpIndexOffset
            }
            var c2da_fresh94_h264bsd : int = 0
            if (int(qpTmp) + chromaQpIndexOffset < 0) {
                c2da_fresh94_h264bsd = 0
            } else {
                c2da_fresh94_h264bsd = c2da_fresh93_h264bsd
            }
            qpTmp = uint(unsafe(unsafe(addr(h264bsdQpC[0]))[c2da_fresh94_h264bsd]))
            qpTmp
            qpAv = uint(uint(qp_2 + qpTmp + uint(1)) >> uint(uint(1)))
            qpAv
            var c2da_fresh95_h264bsd : int = 0
            if (int(qpAv) + mb_9.filterOffsetA > 51) {
                c2da_fresh95_h264bsd = 51
            } else {
                c2da_fresh95_h264bsd = int(qpAv) + mb_9.filterOffsetA
            }
            var c2da_fresh96_h264bsd : int = 0
            if (int(qpAv) + mb_9.filterOffsetA < 0) {
                c2da_fresh96_h264bsd = 0
            } else {
                c2da_fresh96_h264bsd = c2da_fresh95_h264bsd
            }
            indexA = uint(uint(c2da_fresh96_h264bsd))
            indexA
            var c2da_fresh97_h264bsd : int = 0
            if (int(qpAv) + mb_9.filterOffsetB > 51) {
                c2da_fresh97_h264bsd = 51
            } else {
                c2da_fresh97_h264bsd = int(qpAv) + mb_9.filterOffsetB
            }
            var c2da_fresh98_h264bsd : int = 0
            if (int(qpAv) + mb_9.filterOffsetB < 0) {
                c2da_fresh98_h264bsd = 0
            } else {
                c2da_fresh98_h264bsd = c2da_fresh97_h264bsd
            }
            indexB = uint(uint(c2da_fresh98_h264bsd))
            indexB
            unsafe(thresholds_4[TOP]).alpha = uint(uint(unsafe(unsafe(addr(alphas[0]))[indexA])))
            unsafe(thresholds_4[TOP]).alpha
            unsafe(thresholds_4[TOP]).beta = uint(uint(unsafe(unsafe(addr(betas[0]))[indexB])))
            unsafe(thresholds_4[TOP]).beta
            unsafe(thresholds_4[TOP]).tc0 = unsafe(addr(unsafe(unsafe(addr(tc0[0]))[indexA])[0]))
            unsafe(thresholds_4[TOP]).tc0
        } else {
            unsafe(thresholds_4[TOP]).alpha = uint(unsafe(thresholds_4[INNER]).alpha)
            unsafe(thresholds_4[TOP]).alpha
            unsafe(thresholds_4[TOP]).beta = uint(unsafe(thresholds_4[INNER]).beta)
            unsafe(thresholds_4[TOP]).beta
            unsafe(thresholds_4[TOP]).tc0 = unsafe(thresholds_4[INNER]).tc0
            unsafe(thresholds_4[TOP]).tc0
        }
    }
    if (filteringFlags & uint(4) != 0x0) {
        qpTmp = uint(mb_9.mbA.qpY)
        qpTmp
        if (qpTmp != mb_9.qpY) {
            var c2da_fresh99_h264bsd : int = 0
            if (int(qpTmp) + chromaQpIndexOffset > 51) {
                c2da_fresh99_h264bsd = 51
            } else {
                c2da_fresh99_h264bsd = int(qpTmp) + chromaQpIndexOffset
            }
            var c2da_fresh100_h264bsd : int = 0
            if (int(qpTmp) + chromaQpIndexOffset < 0) {
                c2da_fresh100_h264bsd = 0
            } else {
                c2da_fresh100_h264bsd = c2da_fresh99_h264bsd
            }
            qpTmp = uint(unsafe(unsafe(addr(h264bsdQpC[0]))[c2da_fresh100_h264bsd]))
            qpTmp
            qpAv = uint(uint(qp_2 + qpTmp + uint(1)) >> uint(uint(1)))
            qpAv
            var c2da_fresh101_h264bsd : int = 0
            if (int(qpAv) + mb_9.filterOffsetA > 51) {
                c2da_fresh101_h264bsd = 51
            } else {
                c2da_fresh101_h264bsd = int(qpAv) + mb_9.filterOffsetA
            }
            var c2da_fresh102_h264bsd : int = 0
            if (int(qpAv) + mb_9.filterOffsetA < 0) {
                c2da_fresh102_h264bsd = 0
            } else {
                c2da_fresh102_h264bsd = c2da_fresh101_h264bsd
            }
            indexA = uint(uint(c2da_fresh102_h264bsd))
            indexA
            var c2da_fresh103_h264bsd : int = 0
            if (int(qpAv) + mb_9.filterOffsetB > 51) {
                c2da_fresh103_h264bsd = 51
            } else {
                c2da_fresh103_h264bsd = int(qpAv) + mb_9.filterOffsetB
            }
            var c2da_fresh104_h264bsd : int = 0
            if (int(qpAv) + mb_9.filterOffsetB < 0) {
                c2da_fresh104_h264bsd = 0
            } else {
                c2da_fresh104_h264bsd = c2da_fresh103_h264bsd
            }
            indexB = uint(uint(c2da_fresh104_h264bsd))
            indexB
            unsafe(thresholds_4[LEFT]).alpha = uint(uint(unsafe(unsafe(addr(alphas[0]))[indexA])))
            unsafe(thresholds_4[LEFT]).alpha
            unsafe(thresholds_4[LEFT]).beta = uint(uint(unsafe(unsafe(addr(betas[0]))[indexB])))
            unsafe(thresholds_4[LEFT]).beta
            unsafe(thresholds_4[LEFT]).tc0 = unsafe(addr(unsafe(unsafe(addr(tc0[0]))[indexA])[0]))
            unsafe(thresholds_4[LEFT]).tc0
        } else {
            unsafe(thresholds_4[LEFT]).alpha = uint(unsafe(thresholds_4[INNER]).alpha)
            unsafe(thresholds_4[LEFT]).alpha
            unsafe(thresholds_4[LEFT]).beta = uint(unsafe(thresholds_4[INNER]).beta)
            unsafe(thresholds_4[LEFT]).beta
            unsafe(thresholds_4[LEFT]).tc0 = unsafe(thresholds_4[INNER]).tc0
            unsafe(thresholds_4[LEFT]).tc0
        }
    }
}
var tc0 : array<array<uint8>> const = [[uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(0)], [uint8(0), uint8(0), uint8(1)], [uint8(0), uint8(0), uint8(1)], [uint8(0), uint8(0), uint8(1)], [uint8(0), uint8(0), uint8(1)], [uint8(0), uint8(1), uint8(1)], [uint8(0), uint8(1), uint8(1)], [uint8(1), uint8(1), uint8(1)], [uint8(1), uint8(1), uint8(1)], [uint8(1), uint8(1), uint8(1)], [uint8(1), uint8(1), uint8(1)], [uint8(1), uint8(1), uint8(2)], [uint8(1), uint8(1), uint8(2)], [uint8(1), uint8(1), uint8(2)], [uint8(1), uint8(1), uint8(2)], [uint8(1), uint8(2), uint8(3)], [uint8(1), uint8(2), uint8(3)], [uint8(2), uint8(2), uint8(3)], [uint8(2), uint8(2), uint8(4)], [uint8(2), uint8(3), uint8(4)], [uint8(2), uint8(3), uint8(4)], [uint8(3), uint8(3), uint8(5)], [uint8(3), uint8(4), uint8(6)], [uint8(3), uint8(4), uint8(6)], [uint8(4), uint8(5), uint8(7)], [uint8(4), uint8(5), uint8(8)], [uint8(4), uint8(6), uint8(9)], [uint8(5), uint8(7), uint8(10)], [uint8(6), uint8(8), uint8(11)], [uint8(6), uint8(8), uint8(13)], [uint8(7), uint8(10), uint8(14)], [uint8(8), uint8(11), uint8(16)], [uint8(9), uint8(12), uint8(18)], [uint8(10), uint8(13), uint8(20)], [uint8(11), uint8(15), uint8(23)], [uint8(13), uint8(17), uint8(25)]]

var betas : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(2), uint8(2), uint8(2), uint8(3), uint8(3), uint8(3), uint8(3), uint8(4), uint8(4), uint8(4), uint8(6), uint8(6), uint8(7), uint8(7), uint8(8), uint8(8), uint8(9), uint8(9), uint8(10), uint8(10), uint8(11), uint8(11), uint8(12), uint8(12), uint8(13), uint8(13), uint8(14), uint8(14), uint8(15), uint8(15), uint8(16), uint8(16), uint8(17), uint8(17), uint8(18), uint8(18)]

var alphas : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(4), uint8(4), uint8(5), uint8(6), uint8(7), uint8(8), uint8(9), uint8(10), uint8(12), uint8(13), uint8(15), uint8(17), uint8(20), uint8(22), uint8(25), uint8(28), uint8(32), uint8(36), uint8(40), uint8(45), uint8(50), uint8(56), uint8(63), uint8(71), uint8(80), uint8(90), uint8(101), uint8(113), uint8(127), uint8(144), uint8(162), uint8(182), uint8(203), uint8(226), uint8(255), uint8(255)]

[export]
def FilterLuma(var data_37 : uint8?; var bS_4 : bS_t?; var thresholds_5 : edgeThreshold_t?; var width_23 : uint) {
    var vblock_0 : uint
    var tmp_51 : bS_t?
    var ptr_3 : uint8?
    var offset_0 : uint
    ptr_3 = data_37
    ptr_3
    tmp_51 = bS_4
    tmp_51
    offset_0 = uint(uint(TOP))
    offset_0
    vblock_0 = uint(uint(4))
    vblock_0
    while (vblock_0 != 0x0) {
        if (unsafe(tmp_51[0]).left != 0x0) {
            FilterVerLumaEdge(ptr_3, unsafe(tmp_51[0]).left, unsafe(thresholds_5 + LEFT), width_23)
        }
        if (unsafe(tmp_51[1]).left != 0x0) {
            FilterVerLumaEdge(unsafe(ptr_3 + 4), unsafe(tmp_51[1]).left, unsafe(thresholds_5 + INNER), width_23)
        }
        if (unsafe(tmp_51[2]).left != 0x0) {
            FilterVerLumaEdge(unsafe(ptr_3 + 8), unsafe(tmp_51[2]).left, unsafe(thresholds_5 + INNER), width_23)
        }
        if (unsafe(tmp_51[3]).left != 0x0) {
            FilterVerLumaEdge(unsafe(ptr_3 + 12), unsafe(tmp_51[3]).left, unsafe(thresholds_5 + INNER), width_23)
        }
        if (unsafe(tmp_51[0]).top == unsafe(tmp_51[1]).top && unsafe(tmp_51[1]).top == unsafe(tmp_51[2]).top && unsafe(tmp_51[2]).top == unsafe(tmp_51[3]).top) {
            if (unsafe(tmp_51[0]).top != 0x0) {
                FilterHorLuma(ptr_3, unsafe(tmp_51[0]).top, unsafe(thresholds_5 + offset_0), int(width_23))
            }
        } else {
            if (unsafe(tmp_51[0]).top != 0x0) {
                FilterHorLumaEdge(ptr_3, unsafe(tmp_51[0]).top, unsafe(thresholds_5 + offset_0), int(width_23))
            }
            if (unsafe(tmp_51[1]).top != 0x0) {
                FilterHorLumaEdge(unsafe(ptr_3 + 4), unsafe(tmp_51[1]).top, unsafe(thresholds_5 + offset_0), int(width_23))
            }
            if (unsafe(tmp_51[2]).top != 0x0) {
                FilterHorLumaEdge(unsafe(ptr_3 + 8), unsafe(tmp_51[2]).top, unsafe(thresholds_5 + offset_0), int(width_23))
            }
            if (unsafe(tmp_51[3]).top != 0x0) {
                FilterHorLumaEdge(unsafe(ptr_3 + 12), unsafe(tmp_51[3]).top, unsafe(thresholds_5 + offset_0), int(width_23))
            }
        }
        ptr_3 = ptr_3 + width_23 * uint(4)
        ptr_3
        tmp_51 = tmp_51 + 4
        tmp_51
        offset_0 = uint(uint(INNER))
        offset_0
    }
}
[export]
def FilterHorLumaEdge(var data_38 : uint8?; var bS_5 : uint; var thresholds_6 : edgeThreshold_t?; var imageWidth : int) {
    var delta_2 : int
    var tc_2 : int
    var tmp_52 : int
    var i_72 : uint
    var p0_2 : uint8
    var q0_2 : uint8
    var p1_10 : uint8
    var q1_2 : uint8
    var p2 : uint8
    var q2 : uint8
    var clp_13 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    var val_1 : int
    tc_2 = int(unsafe(thresholds_6.tc0[bS_5 - uint(1)]))
    tc_2
    tmp_52 = tc_2
    tmp_52
    i_72 = uint(uint(4))
    i_72
    while (i_72 != 0x0) {
        p1_10 = uint8(unsafe(data_38[-imageWidth * 2]))
        p1_10
        p0_2 = uint8(unsafe(data_38[-imageWidth]))
        p0_2
        q0_2 = uint8(unsafe(data_38[0]))
        q0_2
        q1_2 = uint8(unsafe(data_38[imageWidth]))
        q1_2
        if (uint(c2da_fresh105_h264bsd) < thresholds_6.alpha && uint(c2da_fresh106_h264bsd) < thresholds_6.beta && uint(c2da_fresh107_h264bsd) < thresholds_6.beta) {
            p2 = uint8(unsafe(data_38[-imageWidth * 3]))
            p2
            if (uint(c2da_fresh108_h264bsd) < thresholds_6.beta) {
                val_1 = int(p2) + int(p0_2) + int(q0_2) + 1 >> 1 - int(p1_10) << 1 >> 1
                val_1
                var c2da_fresh109_h264bsd : int = 0
                if (val_1 > tc_2) {
                    c2da_fresh109_h264bsd = tc_2
                } else {
                    c2da_fresh109_h264bsd = val_1
                }
                var c2da_fresh110_h264bsd : int = 0
                if (val_1 < -tc_2) {
                    c2da_fresh110_h264bsd = -tc_2
                } else {
                    c2da_fresh110_h264bsd = c2da_fresh109_h264bsd
                }
                unsafe(data_38[-imageWidth * 2]) = uint8(uint8(int(p1_10) + c2da_fresh110_h264bsd))
                unsafe(data_38[-imageWidth * 2])
                tmp_52 = tmp_52 + 1
                tmp_52
            }
            q2 = uint8(unsafe(data_38[imageWidth * 2]))
            q2
            if (uint(c2da_fresh111_h264bsd) < thresholds_6.beta) {
                val_1 = int(q2) + int(p0_2) + int(q0_2) + 1 >> 1 - int(q1_2) << 1 >> 1
                val_1
                var c2da_fresh112_h264bsd : int = 0
                if (val_1 > tc_2) {
                    c2da_fresh112_h264bsd = tc_2
                } else {
                    c2da_fresh112_h264bsd = val_1
                }
                var c2da_fresh113_h264bsd : int = 0
                if (val_1 < -tc_2) {
                    c2da_fresh113_h264bsd = -tc_2
                } else {
                    c2da_fresh113_h264bsd = c2da_fresh112_h264bsd
                }
                unsafe(data_38[imageWidth]) = uint8(uint8(int(q1_2) + c2da_fresh113_h264bsd))
                unsafe(data_38[imageWidth])
                tmp_52 = tmp_52 + 1
                tmp_52
            }
            val_1 = int(q0_2) - int(p0_2) << 2 + int(p1_10) - int(q1_2) + 4 >> 3
            val_1
            var c2da_fresh114_h264bsd : int = 0
            if (val_1 > tmp_52) {
                c2da_fresh114_h264bsd = tmp_52
            } else {
                c2da_fresh114_h264bsd = val_1
            }
            var c2da_fresh115_h264bsd : int = 0
            if (val_1 < -tmp_52) {
                c2da_fresh115_h264bsd = -tmp_52
            } else {
                c2da_fresh115_h264bsd = c2da_fresh114_h264bsd
            }
            delta_2 = c2da_fresh115_h264bsd
            delta_2
            p0_2 = uint8(unsafe(clp_13[int(p0_2) + delta_2]))
            p0_2
            q0_2 = uint8(unsafe(clp_13[int(q0_2) - delta_2]))
            q0_2
            tmp_52 = tc_2
            tmp_52
            unsafe(data_38[-imageWidth]) = uint8(p0_2)
            unsafe(data_38[-imageWidth])
            unsafe(data_38[0]) = uint8(q0_2)
            unsafe(data_38[0])
        }
        data_38 = data_38 + 1
    }
}
[export]
def FilterHorLuma(var data_39 : uint8?; var bS_6 : uint; var thresholds_7 : edgeThreshold_t?; var imageWidth_0 : int) {
    var delta_3 : int
    var tc_3 : int
    var tmp_53 : int
    var i_73 : uint
    var p0_3 : int
    var q0_3 : int
    var p1_11 : int
    var q1_3 : int
    var p2_0 : int
    var q2_0 : int
    var tmpFlag : uint
    var clp_14 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    var alpha : uint = thresholds_7.alpha
    var beta : uint = thresholds_7.beta
    var val_2 : int
    if (bS_6 < uint(4)) {
        tc_3 = int(unsafe(thresholds_7.tc0[bS_6 - uint(1)]))
        tc_3
        tmp_53 = tc_3
        tmp_53
        i_73 = uint(uint(16))
        i_73
        while (i_73 != 0x0) {
            p1_11 = int(unsafe(data_39[-imageWidth_0 * 2]))
            p1_11
            p0_3 = int(unsafe(data_39[-imageWidth_0]))
            p0_3
            q0_3 = int(unsafe(data_39[0]))
            q0_3
            q1_3 = int(unsafe(data_39[imageWidth_0]))
            q1_3
            if (uint(c2da_fresh116_h264bsd) < alpha && uint(c2da_fresh117_h264bsd) < beta && uint(c2da_fresh118_h264bsd) < beta) {
                p2_0 = int(unsafe(data_39[-imageWidth_0 * 3]))
                p2_0
                if (uint(c2da_fresh119_h264bsd) < beta) {
                    val_2 = p2_0 + p0_3 + q0_3 + 1 >> 1 - p1_11 << 1 >> 1
                    val_2
                    var c2da_fresh120_h264bsd : int = 0
                    if (val_2 > tc_3) {
                        c2da_fresh120_h264bsd = tc_3
                    } else {
                        c2da_fresh120_h264bsd = val_2
                    }
                    var c2da_fresh121_h264bsd : int = 0
                    if (val_2 < -tc_3) {
                        c2da_fresh121_h264bsd = -tc_3
                    } else {
                        c2da_fresh121_h264bsd = c2da_fresh120_h264bsd
                    }
                    unsafe(data_39[-imageWidth_0 * 2]) = uint8(uint8(p1_11 + c2da_fresh121_h264bsd))
                    unsafe(data_39[-imageWidth_0 * 2])
                    tmp_53 = tmp_53 + 1
                    tmp_53
                }
                q2_0 = int(unsafe(data_39[imageWidth_0 * 2]))
                q2_0
                if (uint(c2da_fresh122_h264bsd) < beta) {
                    val_2 = q2_0 + p0_3 + q0_3 + 1 >> 1 - q1_3 << 1 >> 1
                    val_2
                    var c2da_fresh123_h264bsd : int = 0
                    if (val_2 > tc_3) {
                        c2da_fresh123_h264bsd = tc_3
                    } else {
                        c2da_fresh123_h264bsd = val_2
                    }
                    var c2da_fresh124_h264bsd : int = 0
                    if (val_2 < -tc_3) {
                        c2da_fresh124_h264bsd = -tc_3
                    } else {
                        c2da_fresh124_h264bsd = c2da_fresh123_h264bsd
                    }
                    unsafe(data_39[imageWidth_0]) = uint8(uint8(q1_3 + c2da_fresh124_h264bsd))
                    unsafe(data_39[imageWidth_0])
                    tmp_53 = tmp_53 + 1
                    tmp_53
                }
                val_2 = q0_3 - p0_3 << 2 + p1_11 - q1_3 + 4 >> 3
                val_2
                var c2da_fresh125_h264bsd : int = 0
                if (val_2 > tmp_53) {
                    c2da_fresh125_h264bsd = tmp_53
                } else {
                    c2da_fresh125_h264bsd = val_2
                }
                var c2da_fresh126_h264bsd : int = 0
                if (val_2 < -tmp_53) {
                    c2da_fresh126_h264bsd = -tmp_53
                } else {
                    c2da_fresh126_h264bsd = c2da_fresh125_h264bsd
                }
                delta_3 = c2da_fresh126_h264bsd
                delta_3
                p0_3 = int(unsafe(clp_14[p0_3 + delta_3]))
                p0_3
                q0_3 = int(unsafe(clp_14[q0_3 - delta_3]))
                q0_3
                tmp_53 = tc_3
                tmp_53
                unsafe(data_39[-imageWidth_0]) = uint8(uint8(p0_3))
                unsafe(data_39[-imageWidth_0])
                unsafe(data_39[0]) = uint8(uint8(q0_3))
                unsafe(data_39[0])
            }
            data_39 = data_39 + 1
        }
    } else {
        i_73 = uint(uint(16))
        i_73
        while (i_73 != 0x0) {
            p1_11 = int(unsafe(data_39[-imageWidth_0 * 2]))
            p1_11
            p0_3 = int(unsafe(data_39[-imageWidth_0]))
            p0_3
            q0_3 = int(unsafe(data_39[0]))
            q0_3
            q1_3 = int(unsafe(data_39[imageWidth_0]))
            q1_3
            if (uint(c2da_fresh127_h264bsd) < alpha && uint(c2da_fresh128_h264bsd) < beta && uint(c2da_fresh129_h264bsd) < beta) {
                var c2da_fresh130_h264bsd : int = 0
                if (p0_3 - q0_3 < 0) {
                    c2da_fresh130_h264bsd = -p0_3 - q0_3
                } else {
                    c2da_fresh130_h264bsd = p0_3 - q0_3
                }
                var c2da_fresh131_h264bsd : int = 0
                if (uint(c2da_fresh130_h264bsd) < uint(alpha) >> uint(uint(2)) + uint(2)) {
                    c2da_fresh131_h264bsd = 1
                } else {
                    c2da_fresh131_h264bsd = 0
                }
                tmpFlag = uint(uint(c2da_fresh131_h264bsd))
                tmpFlag
                p2_0 = int(unsafe(data_39[-imageWidth_0 * 3]))
                p2_0
                q2_0 = int(unsafe(data_39[imageWidth_0 * 2]))
                q2_0
                if (tmpFlag != 0x0 && uint(c2da_fresh132_h264bsd) < beta) {
                    tmp_53 = p1_11 + p0_3 + q0_3
                    tmp_53
                    unsafe(data_39[-imageWidth_0]) = uint8(uint8(p2_0 + 2 * tmp_53 + q1_3 + 4 >> 3))
                    unsafe(data_39[-imageWidth_0])
                    unsafe(data_39[-imageWidth_0 * 2]) = uint8(uint8(p2_0 + tmp_53 + 2 >> 2))
                    unsafe(data_39[-imageWidth_0 * 2])
                    unsafe(data_39[-imageWidth_0 * 3]) = uint8(uint8(2 * int(unsafe(data_39[-imageWidth_0 * 4])) + 3 * p2_0 + tmp_53 + 4 >> 3))
                    unsafe(data_39[-imageWidth_0 * 3])
                } else {
                    unsafe(data_39[-imageWidth_0]) = uint8(uint8(2 * p1_11 + p0_3 + q1_3 + 2 >> 2))
                    unsafe(data_39[-imageWidth_0])
                }
                if (tmpFlag != 0x0 && uint(c2da_fresh133_h264bsd) < beta) {
                    tmp_53 = p0_3 + q0_3 + q1_3
                    tmp_53
                    unsafe(data_39[0]) = uint8(uint8(p1_11 + 2 * tmp_53 + q2_0 + 4 >> 3))
                    unsafe(data_39[0])
                    unsafe(data_39[imageWidth_0]) = uint8(uint8(tmp_53 + q2_0 + 2 >> 2))
                    unsafe(data_39[imageWidth_0])
                    unsafe(data_39[imageWidth_0 * 2]) = uint8(uint8(2 * int(unsafe(data_39[imageWidth_0 * 3])) + 3 * q2_0 + tmp_53 + 4 >> 3))
                    unsafe(data_39[imageWidth_0 * 2])
                } else {
                    unsafe(data_39[0]) = uint8(uint8(2 * q1_3 + q0_3 + p1_11 + 2 >> 2))
                    unsafe(data_39[0])
                }
            }
            data_39 = data_39 + 1
        }
    }
}
[export]
def FilterVerLumaEdge(var data_40 : uint8?; var bS_7 : uint; var thresholds_8 : edgeThreshold_t?; var imageWidth_1 : uint) {
    var delta_4 : int
    var tc_4 : int
    var tmp_54 : int
    var i_74 : uint
    var p0_4 : int
    var q0_4 : int
    var p1_12 : int
    var q1_4 : int
    var p2_1 : int
    var q2_1 : int
    var tmpFlag_0 : uint
    var clp_15 : uint8 const? = unsafe(unsafe(addr(h264bsdClip[0])) + 512)
    var alpha_0 : uint = thresholds_8.alpha
    var beta_0 : uint = thresholds_8.beta
    var val_3 : int
    if (bS_7 < uint(4)) {
        tc_4 = int(unsafe(thresholds_8.tc0[bS_7 - uint(1)]))
        tc_4
        tmp_54 = tc_4
        tmp_54
        i_74 = uint(uint(4))
        i_74
        while (i_74 != 0x0) {
            p1_12 = int(unsafe(data_40[-2]))
            p1_12
            p0_4 = int(unsafe(data_40[-1]))
            p0_4
            q0_4 = int(unsafe(data_40[0]))
            q0_4
            q1_4 = int(unsafe(data_40[1]))
            q1_4
            if (uint(c2da_fresh134_h264bsd) < alpha_0 && uint(c2da_fresh135_h264bsd) < beta_0 && uint(c2da_fresh136_h264bsd) < beta_0) {
                p2_1 = int(unsafe(data_40[-3]))
                p2_1
                q2_1 = int(unsafe(data_40[2]))
                q2_1
                if (uint(c2da_fresh137_h264bsd) < beta_0) {
                    val_3 = p2_1 + p0_4 + q0_4 + 1 >> 1 - p1_12 << 1 >> 1
                    val_3
                    var c2da_fresh138_h264bsd : int = 0
                    if (val_3 > tc_4) {
                        c2da_fresh138_h264bsd = tc_4
                    } else {
                        c2da_fresh138_h264bsd = val_3
                    }
                    var c2da_fresh139_h264bsd : int = 0
                    if (val_3 < -tc_4) {
                        c2da_fresh139_h264bsd = -tc_4
                    } else {
                        c2da_fresh139_h264bsd = c2da_fresh138_h264bsd
                    }
                    unsafe(data_40[-2]) = uint8(uint8(p1_12 + c2da_fresh139_h264bsd))
                    unsafe(data_40[-2])
                    tmp_54 = tmp_54 + 1
                    tmp_54
                }
                if (uint(c2da_fresh140_h264bsd) < beta_0) {
                    val_3 = q2_1 + p0_4 + q0_4 + 1 >> 1 - q1_4 << 1 >> 1
                    val_3
                    var c2da_fresh141_h264bsd : int = 0
                    if (val_3 > tc_4) {
                        c2da_fresh141_h264bsd = tc_4
                    } else {
                        c2da_fresh141_h264bsd = val_3
                    }
                    var c2da_fresh142_h264bsd : int = 0
                    if (val_3 < -tc_4) {
                        c2da_fresh142_h264bsd = -tc_4
                    } else {
                        c2da_fresh142_h264bsd = c2da_fresh141_h264bsd
                    }
                    unsafe(data_40[1]) = uint8(uint8(q1_4 + c2da_fresh142_h264bsd))
                    unsafe(data_40[1])
                    tmp_54 = tmp_54 + 1
                    tmp_54
                }
                val_3 = q0_4 - p0_4 << 2 + p1_12 - q1_4 + 4 >> 3
                val_3
                var c2da_fresh143_h264bsd : int = 0
                if (val_3 > tmp_54) {
                    c2da_fresh143_h264bsd = tmp_54
                } else {
                    c2da_fresh143_h264bsd = val_3
                }
                var c2da_fresh144_h264bsd : int = 0
                if (val_3 < -tmp_54) {
                    c2da_fresh144_h264bsd = -tmp_54
                } else {
                    c2da_fresh144_h264bsd = c2da_fresh143_h264bsd
                }
                delta_4 = c2da_fresh144_h264bsd
                delta_4
                p0_4 = int(unsafe(clp_15[p0_4 + delta_4]))
                p0_4
                q0_4 = int(unsafe(clp_15[q0_4 - delta_4]))
                q0_4
                tmp_54 = tc_4
                tmp_54
                unsafe(data_40[-1]) = uint8(uint8(p0_4))
                unsafe(data_40[-1])
                unsafe(data_40[0]) = uint8(uint8(q0_4))
                unsafe(data_40[0])
            }
            data_40 = data_40 + imageWidth_1
        }
    } else {
        i_74 = uint(uint(4))
        i_74
        while (i_74 != 0x0) {
            p1_12 = int(unsafe(data_40[-2]))
            p1_12
            p0_4 = int(unsafe(data_40[-1]))
            p0_4
            q0_4 = int(unsafe(data_40[0]))
            q0_4
            q1_4 = int(unsafe(data_40[1]))
            q1_4
            if (uint(c2da_fresh145_h264bsd) < alpha_0 && uint(c2da_fresh146_h264bsd) < beta_0 && uint(c2da_fresh147_h264bsd) < beta_0) {
                var c2da_fresh148_h264bsd : int = 0
                if (p0_4 - q0_4 < 0) {
                    c2da_fresh148_h264bsd = -p0_4 - q0_4
                } else {
                    c2da_fresh148_h264bsd = p0_4 - q0_4
                }
                var c2da_fresh149_h264bsd : int = 0
                if (uint(c2da_fresh148_h264bsd) < uint(alpha_0) >> uint(uint(2)) + uint(2)) {
                    c2da_fresh149_h264bsd = 1
                } else {
                    c2da_fresh149_h264bsd = 0
                }
                tmpFlag_0 = uint(uint(c2da_fresh149_h264bsd))
                tmpFlag_0
                p2_1 = int(unsafe(data_40[-3]))
                p2_1
                q2_1 = int(unsafe(data_40[2]))
                q2_1
                if (tmpFlag_0 != 0x0 && uint(c2da_fresh150_h264bsd) < beta_0) {
                    tmp_54 = p1_12 + p0_4 + q0_4
                    tmp_54
                    unsafe(data_40[-1]) = uint8(uint8(p2_1 + 2 * tmp_54 + q1_4 + 4 >> 3))
                    unsafe(data_40[-1])
                    unsafe(data_40[-2]) = uint8(uint8(p2_1 + tmp_54 + 2 >> 2))
                    unsafe(data_40[-2])
                    unsafe(data_40[-3]) = uint8(uint8(2 * int(unsafe(data_40[-4])) + 3 * p2_1 + tmp_54 + 4 >> 3))
                    unsafe(data_40[-3])
                } else {
                    unsafe(data_40[-1]) = uint8(uint8(2 * p1_12 + p0_4 + q1_4 + 2 >> 2))
                    unsafe(data_40[-1])
                }
                if (tmpFlag_0 != 0x0 && uint(c2da_fresh151_h264bsd) < beta_0) {
                    tmp_54 = p0_4 + q0_4 + q1_4
                    tmp_54
                    unsafe(data_40[0]) = uint8(uint8(p1_12 + 2 * tmp_54 + q2_1 + 4 >> 3))
                    unsafe(data_40[0])
                    unsafe(data_40[1]) = uint8(uint8(tmp_54 + q2_1 + 2 >> 2))
                    unsafe(data_40[1])
                    unsafe(data_40[2]) = uint8(uint8(2 * int(unsafe(data_40[3])) + 3 * q2_1 + tmp_54 + 4 >> 3))
                    unsafe(data_40[2])
                } else {
                    unsafe(data_40[0]) = uint8(uint8(2 * q1_4 + q0_4 + p1_12 + 2 >> 2))
                    unsafe(data_40[0])
                }
            }
            data_40 = data_40 + imageWidth_1
        }
    }
}
[export]
def GetLumaEdgeThresholds(var thresholds_9 : edgeThreshold_t?; var mb_10 : mbStorage_t?; var filteringFlags_0 : uint) {
    var indexA_0 : uint
    var indexB_0 : uint
    var qpAv_0 : uint
    var qp_3 : uint
    var qpTmp_0 : uint
    qp_3 = uint(mb_10.qpY)
    qp_3
    var c2da_fresh152_h264bsd : int = 0
    if (int(qp_3) + mb_10.filterOffsetA > 51) {
        c2da_fresh152_h264bsd = 51
    } else {
        c2da_fresh152_h264bsd = int(qp_3) + mb_10.filterOffsetA
    }
    var c2da_fresh153_h264bsd : int = 0
    if (int(qp_3) + mb_10.filterOffsetA < 0) {
        c2da_fresh153_h264bsd = 0
    } else {
        c2da_fresh153_h264bsd = c2da_fresh152_h264bsd
    }
    indexA_0 = uint(uint(c2da_fresh153_h264bsd))
    indexA_0
    var c2da_fresh154_h264bsd : int = 0
    if (int(qp_3) + mb_10.filterOffsetB > 51) {
        c2da_fresh154_h264bsd = 51
    } else {
        c2da_fresh154_h264bsd = int(qp_3) + mb_10.filterOffsetB
    }
    var c2da_fresh155_h264bsd : int = 0
    if (int(qp_3) + mb_10.filterOffsetB < 0) {
        c2da_fresh155_h264bsd = 0
    } else {
        c2da_fresh155_h264bsd = c2da_fresh154_h264bsd
    }
    indexB_0 = uint(uint(c2da_fresh155_h264bsd))
    indexB_0
    unsafe(thresholds_9[INNER]).alpha = uint(uint(unsafe(unsafe(addr(alphas[0]))[indexA_0])))
    unsafe(thresholds_9[INNER]).alpha
    unsafe(thresholds_9[INNER]).beta = uint(uint(unsafe(unsafe(addr(betas[0]))[indexB_0])))
    unsafe(thresholds_9[INNER]).beta
    unsafe(thresholds_9[INNER]).tc0 = unsafe(addr(unsafe(unsafe(addr(tc0[0]))[indexA_0])[0]))
    unsafe(thresholds_9[INNER]).tc0
    if (filteringFlags_0 & uint(2) != 0x0) {
        qpTmp_0 = uint(mb_10.mbB.qpY)
        qpTmp_0
        if (qpTmp_0 != qp_3) {
            qpAv_0 = uint(uint(qp_3 + qpTmp_0 + uint(1)) >> uint(uint(1)))
            qpAv_0
            var c2da_fresh156_h264bsd : int = 0
            if (int(qpAv_0) + mb_10.filterOffsetA > 51) {
                c2da_fresh156_h264bsd = 51
            } else {
                c2da_fresh156_h264bsd = int(qpAv_0) + mb_10.filterOffsetA
            }
            var c2da_fresh157_h264bsd : int = 0
            if (int(qpAv_0) + mb_10.filterOffsetA < 0) {
                c2da_fresh157_h264bsd = 0
            } else {
                c2da_fresh157_h264bsd = c2da_fresh156_h264bsd
            }
            indexA_0 = uint(uint(c2da_fresh157_h264bsd))
            indexA_0
            var c2da_fresh158_h264bsd : int = 0
            if (int(qpAv_0) + mb_10.filterOffsetB > 51) {
                c2da_fresh158_h264bsd = 51
            } else {
                c2da_fresh158_h264bsd = int(qpAv_0) + mb_10.filterOffsetB
            }
            var c2da_fresh159_h264bsd : int = 0
            if (int(qpAv_0) + mb_10.filterOffsetB < 0) {
                c2da_fresh159_h264bsd = 0
            } else {
                c2da_fresh159_h264bsd = c2da_fresh158_h264bsd
            }
            indexB_0 = uint(uint(c2da_fresh159_h264bsd))
            indexB_0
            unsafe(thresholds_9[TOP]).alpha = uint(uint(unsafe(unsafe(addr(alphas[0]))[indexA_0])))
            unsafe(thresholds_9[TOP]).alpha
            unsafe(thresholds_9[TOP]).beta = uint(uint(unsafe(unsafe(addr(betas[0]))[indexB_0])))
            unsafe(thresholds_9[TOP]).beta
            unsafe(thresholds_9[TOP]).tc0 = unsafe(addr(unsafe(unsafe(addr(tc0[0]))[indexA_0])[0]))
            unsafe(thresholds_9[TOP]).tc0
        } else {
            unsafe(thresholds_9[TOP]).alpha = uint(unsafe(thresholds_9[INNER]).alpha)
            unsafe(thresholds_9[TOP]).alpha
            unsafe(thresholds_9[TOP]).beta = uint(unsafe(thresholds_9[INNER]).beta)
            unsafe(thresholds_9[TOP]).beta
            unsafe(thresholds_9[TOP]).tc0 = unsafe(thresholds_9[INNER]).tc0
            unsafe(thresholds_9[TOP]).tc0
        }
    }
    if (filteringFlags_0 & uint(4) != 0x0) {
        qpTmp_0 = uint(mb_10.mbA.qpY)
        qpTmp_0
        if (qpTmp_0 != qp_3) {
            qpAv_0 = uint(uint(qp_3 + qpTmp_0 + uint(1)) >> uint(uint(1)))
            qpAv_0
            var c2da_fresh160_h264bsd : int = 0
            if (int(qpAv_0) + mb_10.filterOffsetA > 51) {
                c2da_fresh160_h264bsd = 51
            } else {
                c2da_fresh160_h264bsd = int(qpAv_0) + mb_10.filterOffsetA
            }
            var c2da_fresh161_h264bsd : int = 0
            if (int(qpAv_0) + mb_10.filterOffsetA < 0) {
                c2da_fresh161_h264bsd = 0
            } else {
                c2da_fresh161_h264bsd = c2da_fresh160_h264bsd
            }
            indexA_0 = uint(uint(c2da_fresh161_h264bsd))
            indexA_0
            var c2da_fresh162_h264bsd : int = 0
            if (int(qpAv_0) + mb_10.filterOffsetB > 51) {
                c2da_fresh162_h264bsd = 51
            } else {
                c2da_fresh162_h264bsd = int(qpAv_0) + mb_10.filterOffsetB
            }
            var c2da_fresh163_h264bsd : int = 0
            if (int(qpAv_0) + mb_10.filterOffsetB < 0) {
                c2da_fresh163_h264bsd = 0
            } else {
                c2da_fresh163_h264bsd = c2da_fresh162_h264bsd
            }
            indexB_0 = uint(uint(c2da_fresh163_h264bsd))
            indexB_0
            unsafe(thresholds_9[LEFT]).alpha = uint(uint(unsafe(unsafe(addr(alphas[0]))[indexA_0])))
            unsafe(thresholds_9[LEFT]).alpha
            unsafe(thresholds_9[LEFT]).beta = uint(uint(unsafe(unsafe(addr(betas[0]))[indexB_0])))
            unsafe(thresholds_9[LEFT]).beta
            unsafe(thresholds_9[LEFT]).tc0 = unsafe(addr(unsafe(unsafe(addr(tc0[0]))[indexA_0])[0]))
            unsafe(thresholds_9[LEFT]).tc0
        } else {
            unsafe(thresholds_9[LEFT]).alpha = uint(unsafe(thresholds_9[INNER]).alpha)
            unsafe(thresholds_9[LEFT]).alpha
            unsafe(thresholds_9[LEFT]).beta = uint(unsafe(thresholds_9[INNER]).beta)
            unsafe(thresholds_9[LEFT]).beta
            unsafe(thresholds_9[LEFT]).tc0 = unsafe(thresholds_9[INNER]).tc0
            unsafe(thresholds_9[LEFT]).tc0
        }
    }
}
[export]
def GetBoundaryStrengths(var mb_11 : mbStorage_t?; var bS_8 : bS_t?; var flags_0 : uint) : uint {
    var nonZeroBs : uint = uint(0)
    if (flags_0 & uint(2) != 0x0) {
        if (uint(*mb_11.mbType) > uint(5) || uint(*mb_11.mbB.mbType) > uint(5)) {
            unsafe(bS_8[3]).top = uint(uint(4))
            unsafe(bS_8[2]).top = uint(unsafe(bS_8[3]).top)
            unsafe(bS_8[1]).top = uint(unsafe(bS_8[2]).top)
            unsafe(bS_8[0]).top = uint(unsafe(bS_8[1]).top)
            unsafe(bS_8[0]).top
            nonZeroBs = uint(uint(1))
            nonZeroBs
        } else {
            unsafe(bS_8[0]).top = uint(EdgeBoundaryStrength(mb_11, mb_11.mbB, uint(0), uint(10)))
            unsafe(bS_8[0]).top
            unsafe(bS_8[1]).top = uint(EdgeBoundaryStrength(mb_11, mb_11.mbB, uint(1), uint(11)))
            unsafe(bS_8[1]).top
            unsafe(bS_8[2]).top = uint(EdgeBoundaryStrength(mb_11, mb_11.mbB, uint(4), uint(14)))
            unsafe(bS_8[2]).top
            unsafe(bS_8[3]).top = uint(EdgeBoundaryStrength(mb_11, mb_11.mbB, uint(5), uint(15)))
            unsafe(bS_8[3]).top
            if (unsafe(bS_8[0]).top != 0x0 || unsafe(bS_8[1]).top != 0x0 || unsafe(bS_8[2]).top != 0x0 || unsafe(bS_8[3]).top != 0x0) {
                nonZeroBs = uint(uint(1))
                nonZeroBs
            }
        }
    } else {
        unsafe(bS_8[3]).top = uint(uint(0))
        unsafe(bS_8[2]).top = uint(unsafe(bS_8[3]).top)
        unsafe(bS_8[1]).top = uint(unsafe(bS_8[2]).top)
        unsafe(bS_8[0]).top = uint(unsafe(bS_8[1]).top)
        unsafe(bS_8[0]).top
    }
    if (flags_0 & uint(4) != 0x0) {
        if (uint(*mb_11.mbType) > uint(5) || uint(*mb_11.mbA.mbType) > uint(5)) {
            unsafe(bS_8[12]).left = uint(uint(4))
            unsafe(bS_8[8]).left = uint(unsafe(bS_8[12]).left)
            unsafe(bS_8[4]).left = uint(unsafe(bS_8[8]).left)
            unsafe(bS_8[0]).left = uint(unsafe(bS_8[4]).left)
            unsafe(bS_8[0]).left
            nonZeroBs = uint(uint(1))
            nonZeroBs
        } else {
            unsafe(bS_8[0]).left = uint(EdgeBoundaryStrength(mb_11, mb_11.mbA, uint(0), uint(5)))
            unsafe(bS_8[0]).left
            unsafe(bS_8[4]).left = uint(EdgeBoundaryStrength(mb_11, mb_11.mbA, uint(2), uint(7)))
            unsafe(bS_8[4]).left
            unsafe(bS_8[8]).left = uint(EdgeBoundaryStrength(mb_11, mb_11.mbA, uint(8), uint(13)))
            unsafe(bS_8[8]).left
            unsafe(bS_8[12]).left = uint(EdgeBoundaryStrength(mb_11, mb_11.mbA, uint(10), uint(15)))
            unsafe(bS_8[12]).left
            if (nonZeroBs == 0 && unsafe(bS_8[0]).left != 0x0 || unsafe(bS_8[4]).left != 0x0 || unsafe(bS_8[8]).left != 0x0 || unsafe(bS_8[12]).left != 0x0) {
                nonZeroBs = uint(uint(1))
                nonZeroBs
            }
        }
    } else {
        unsafe(bS_8[12]).left = uint(uint(0))
        unsafe(bS_8[8]).left = uint(unsafe(bS_8[12]).left)
        unsafe(bS_8[4]).left = uint(unsafe(bS_8[8]).left)
        unsafe(bS_8[0]).left = uint(unsafe(bS_8[4]).left)
        unsafe(bS_8[0]).left
    }
    if (uint(*mb_11.mbType) > uint(5)) {
        unsafe(bS_8[15]).top = uint(uint(3))
        unsafe(bS_8[14]).top = uint(unsafe(bS_8[15]).top)
        unsafe(bS_8[13]).top = uint(unsafe(bS_8[14]).top)
        unsafe(bS_8[12]).top = uint(unsafe(bS_8[13]).top)
        unsafe(bS_8[11]).top = uint(unsafe(bS_8[12]).top)
        unsafe(bS_8[10]).top = uint(unsafe(bS_8[11]).top)
        unsafe(bS_8[9]).top = uint(unsafe(bS_8[10]).top)
        unsafe(bS_8[8]).top = uint(unsafe(bS_8[9]).top)
        unsafe(bS_8[7]).top = uint(unsafe(bS_8[8]).top)
        unsafe(bS_8[6]).top = uint(unsafe(bS_8[7]).top)
        unsafe(bS_8[5]).top = uint(unsafe(bS_8[6]).top)
        unsafe(bS_8[4]).top = uint(unsafe(bS_8[5]).top)
        unsafe(bS_8[4]).top
        unsafe(bS_8[15]).left = uint(uint(3))
        unsafe(bS_8[14]).left = uint(unsafe(bS_8[15]).left)
        unsafe(bS_8[13]).left = uint(unsafe(bS_8[14]).left)
        unsafe(bS_8[11]).left = uint(unsafe(bS_8[13]).left)
        unsafe(bS_8[10]).left = uint(unsafe(bS_8[11]).left)
        unsafe(bS_8[9]).left = uint(unsafe(bS_8[10]).left)
        unsafe(bS_8[7]).left = uint(unsafe(bS_8[9]).left)
        unsafe(bS_8[6]).left = uint(unsafe(bS_8[7]).left)
        unsafe(bS_8[5]).left = uint(unsafe(bS_8[6]).left)
        unsafe(bS_8[3]).left = uint(unsafe(bS_8[5]).left)
        unsafe(bS_8[2]).left = uint(unsafe(bS_8[3]).left)
        unsafe(bS_8[1]).left = uint(unsafe(bS_8[2]).left)
        unsafe(bS_8[1]).left
        nonZeroBs = uint(uint(1))
        nonZeroBs
    } else {
        if (h264bsdNumMbPart(mb_11.mbType) == uint(1)) {
            GetBoundaryStrengthsA(mb_11, bS_8)
        } else {
            if (uint(mb_11.mbType) == uint(P_L0_L0_16x8)) {
                var c2da_fresh164_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[2]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[0]) != 0) {
                    c2da_fresh164_h264bsd = 2
                } else {
                    c2da_fresh164_h264bsd = 0
                }
                unsafe(bS_8[4]).top = uint(uint(c2da_fresh164_h264bsd))
                unsafe(bS_8[4]).top
                var c2da_fresh165_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[3]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[1]) != 0) {
                    c2da_fresh165_h264bsd = 2
                } else {
                    c2da_fresh165_h264bsd = 0
                }
                unsafe(bS_8[5]).top = uint(uint(c2da_fresh165_h264bsd))
                unsafe(bS_8[5]).top
                var c2da_fresh166_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[6]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[4]) != 0) {
                    c2da_fresh166_h264bsd = 2
                } else {
                    c2da_fresh166_h264bsd = 0
                }
                unsafe(bS_8[6]).top = uint(uint(c2da_fresh166_h264bsd))
                unsafe(bS_8[6]).top
                var c2da_fresh167_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[7]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[5]) != 0) {
                    c2da_fresh167_h264bsd = 2
                } else {
                    c2da_fresh167_h264bsd = 0
                }
                unsafe(bS_8[7]).top = uint(uint(c2da_fresh167_h264bsd))
                unsafe(bS_8[7]).top
                var c2da_fresh168_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[10]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[8]) != 0) {
                    c2da_fresh168_h264bsd = 2
                } else {
                    c2da_fresh168_h264bsd = 0
                }
                unsafe(bS_8[12]).top = uint(uint(c2da_fresh168_h264bsd))
                unsafe(bS_8[12]).top
                var c2da_fresh169_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[11]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[9]) != 0) {
                    c2da_fresh169_h264bsd = 2
                } else {
                    c2da_fresh169_h264bsd = 0
                }
                unsafe(bS_8[13]).top = uint(uint(c2da_fresh169_h264bsd))
                unsafe(bS_8[13]).top
                var c2da_fresh170_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[14]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[12]) != 0) {
                    c2da_fresh170_h264bsd = 2
                } else {
                    c2da_fresh170_h264bsd = 0
                }
                unsafe(bS_8[14]).top = uint(uint(c2da_fresh170_h264bsd))
                unsafe(bS_8[14]).top
                var c2da_fresh171_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[15]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[13]) != 0) {
                    c2da_fresh171_h264bsd = 2
                } else {
                    c2da_fresh171_h264bsd = 0
                }
                unsafe(bS_8[15]).top = uint(uint(c2da_fresh171_h264bsd))
                unsafe(bS_8[15]).top
                unsafe(bS_8[8]).top = uint(InnerBoundaryStrength(mb_11, uint(8), uint(2)))
                unsafe(bS_8[8]).top
                unsafe(bS_8[9]).top = uint(InnerBoundaryStrength(mb_11, uint(9), uint(3)))
                unsafe(bS_8[9]).top
                unsafe(bS_8[10]).top = uint(InnerBoundaryStrength(mb_11, uint(12), uint(6)))
                unsafe(bS_8[10]).top
                unsafe(bS_8[11]).top = uint(InnerBoundaryStrength(mb_11, uint(13), uint(7)))
                unsafe(bS_8[11]).top
                var c2da_fresh172_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[1]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[0]) != 0) {
                    c2da_fresh172_h264bsd = 2
                } else {
                    c2da_fresh172_h264bsd = 0
                }
                unsafe(bS_8[1]).left = uint(uint(c2da_fresh172_h264bsd))
                unsafe(bS_8[1]).left
                var c2da_fresh173_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[4]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[1]) != 0) {
                    c2da_fresh173_h264bsd = 2
                } else {
                    c2da_fresh173_h264bsd = 0
                }
                unsafe(bS_8[2]).left = uint(uint(c2da_fresh173_h264bsd))
                unsafe(bS_8[2]).left
                var c2da_fresh174_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[5]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[4]) != 0) {
                    c2da_fresh174_h264bsd = 2
                } else {
                    c2da_fresh174_h264bsd = 0
                }
                unsafe(bS_8[3]).left = uint(uint(c2da_fresh174_h264bsd))
                unsafe(bS_8[3]).left
                var c2da_fresh175_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[3]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[2]) != 0) {
                    c2da_fresh175_h264bsd = 2
                } else {
                    c2da_fresh175_h264bsd = 0
                }
                unsafe(bS_8[5]).left = uint(uint(c2da_fresh175_h264bsd))
                unsafe(bS_8[5]).left
                var c2da_fresh176_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[6]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[3]) != 0) {
                    c2da_fresh176_h264bsd = 2
                } else {
                    c2da_fresh176_h264bsd = 0
                }
                unsafe(bS_8[6]).left = uint(uint(c2da_fresh176_h264bsd))
                unsafe(bS_8[6]).left
                var c2da_fresh177_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[7]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[6]) != 0) {
                    c2da_fresh177_h264bsd = 2
                } else {
                    c2da_fresh177_h264bsd = 0
                }
                unsafe(bS_8[7]).left = uint(uint(c2da_fresh177_h264bsd))
                unsafe(bS_8[7]).left
                var c2da_fresh178_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[9]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[8]) != 0) {
                    c2da_fresh178_h264bsd = 2
                } else {
                    c2da_fresh178_h264bsd = 0
                }
                unsafe(bS_8[9]).left = uint(uint(c2da_fresh178_h264bsd))
                unsafe(bS_8[9]).left
                var c2da_fresh179_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[12]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[9]) != 0) {
                    c2da_fresh179_h264bsd = 2
                } else {
                    c2da_fresh179_h264bsd = 0
                }
                unsafe(bS_8[10]).left = uint(uint(c2da_fresh179_h264bsd))
                unsafe(bS_8[10]).left
                var c2da_fresh180_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[13]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[12]) != 0) {
                    c2da_fresh180_h264bsd = 2
                } else {
                    c2da_fresh180_h264bsd = 0
                }
                unsafe(bS_8[11]).left = uint(uint(c2da_fresh180_h264bsd))
                unsafe(bS_8[11]).left
                var c2da_fresh181_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[11]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[10]) != 0) {
                    c2da_fresh181_h264bsd = 2
                } else {
                    c2da_fresh181_h264bsd = 0
                }
                unsafe(bS_8[13]).left = uint(uint(c2da_fresh181_h264bsd))
                unsafe(bS_8[13]).left
                var c2da_fresh182_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[14]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[11]) != 0) {
                    c2da_fresh182_h264bsd = 2
                } else {
                    c2da_fresh182_h264bsd = 0
                }
                unsafe(bS_8[14]).left = uint(uint(c2da_fresh182_h264bsd))
                unsafe(bS_8[14]).left
                var c2da_fresh183_h264bsd : int = 0
                if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[15]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[14]) != 0) {
                    c2da_fresh183_h264bsd = 2
                } else {
                    c2da_fresh183_h264bsd = 0
                }
                unsafe(bS_8[15]).left = uint(uint(c2da_fresh183_h264bsd))
                unsafe(bS_8[15]).left
            } else {
                if (uint(mb_11.mbType) == uint(P_L0_L0_8x16)) {
                    var c2da_fresh184_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[2]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[0]) != 0) {
                        c2da_fresh184_h264bsd = 2
                    } else {
                        c2da_fresh184_h264bsd = 0
                    }
                    unsafe(bS_8[4]).top = uint(uint(c2da_fresh184_h264bsd))
                    unsafe(bS_8[4]).top
                    var c2da_fresh185_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[3]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[1]) != 0) {
                        c2da_fresh185_h264bsd = 2
                    } else {
                        c2da_fresh185_h264bsd = 0
                    }
                    unsafe(bS_8[5]).top = uint(uint(c2da_fresh185_h264bsd))
                    unsafe(bS_8[5]).top
                    var c2da_fresh186_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[6]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[4]) != 0) {
                        c2da_fresh186_h264bsd = 2
                    } else {
                        c2da_fresh186_h264bsd = 0
                    }
                    unsafe(bS_8[6]).top = uint(uint(c2da_fresh186_h264bsd))
                    unsafe(bS_8[6]).top
                    var c2da_fresh187_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[7]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[5]) != 0) {
                        c2da_fresh187_h264bsd = 2
                    } else {
                        c2da_fresh187_h264bsd = 0
                    }
                    unsafe(bS_8[7]).top = uint(uint(c2da_fresh187_h264bsd))
                    unsafe(bS_8[7]).top
                    var c2da_fresh188_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[8]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[2]) != 0) {
                        c2da_fresh188_h264bsd = 2
                    } else {
                        c2da_fresh188_h264bsd = 0
                    }
                    unsafe(bS_8[8]).top = uint(uint(c2da_fresh188_h264bsd))
                    unsafe(bS_8[8]).top
                    var c2da_fresh189_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[9]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[3]) != 0) {
                        c2da_fresh189_h264bsd = 2
                    } else {
                        c2da_fresh189_h264bsd = 0
                    }
                    unsafe(bS_8[9]).top = uint(uint(c2da_fresh189_h264bsd))
                    unsafe(bS_8[9]).top
                    var c2da_fresh190_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[12]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[6]) != 0) {
                        c2da_fresh190_h264bsd = 2
                    } else {
                        c2da_fresh190_h264bsd = 0
                    }
                    unsafe(bS_8[10]).top = uint(uint(c2da_fresh190_h264bsd))
                    unsafe(bS_8[10]).top
                    var c2da_fresh191_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[13]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[7]) != 0) {
                        c2da_fresh191_h264bsd = 2
                    } else {
                        c2da_fresh191_h264bsd = 0
                    }
                    unsafe(bS_8[11]).top = uint(uint(c2da_fresh191_h264bsd))
                    unsafe(bS_8[11]).top
                    var c2da_fresh192_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[10]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[8]) != 0) {
                        c2da_fresh192_h264bsd = 2
                    } else {
                        c2da_fresh192_h264bsd = 0
                    }
                    unsafe(bS_8[12]).top = uint(uint(c2da_fresh192_h264bsd))
                    unsafe(bS_8[12]).top
                    var c2da_fresh193_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[11]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[9]) != 0) {
                        c2da_fresh193_h264bsd = 2
                    } else {
                        c2da_fresh193_h264bsd = 0
                    }
                    unsafe(bS_8[13]).top = uint(uint(c2da_fresh193_h264bsd))
                    unsafe(bS_8[13]).top
                    var c2da_fresh194_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[14]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[12]) != 0) {
                        c2da_fresh194_h264bsd = 2
                    } else {
                        c2da_fresh194_h264bsd = 0
                    }
                    unsafe(bS_8[14]).top = uint(uint(c2da_fresh194_h264bsd))
                    unsafe(bS_8[14]).top
                    var c2da_fresh195_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[15]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[13]) != 0) {
                        c2da_fresh195_h264bsd = 2
                    } else {
                        c2da_fresh195_h264bsd = 0
                    }
                    unsafe(bS_8[15]).top = uint(uint(c2da_fresh195_h264bsd))
                    unsafe(bS_8[15]).top
                    var c2da_fresh196_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[1]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[0]) != 0) {
                        c2da_fresh196_h264bsd = 2
                    } else {
                        c2da_fresh196_h264bsd = 0
                    }
                    unsafe(bS_8[1]).left = uint(uint(c2da_fresh196_h264bsd))
                    unsafe(bS_8[1]).left
                    var c2da_fresh197_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[5]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[4]) != 0) {
                        c2da_fresh197_h264bsd = 2
                    } else {
                        c2da_fresh197_h264bsd = 0
                    }
                    unsafe(bS_8[3]).left = uint(uint(c2da_fresh197_h264bsd))
                    unsafe(bS_8[3]).left
                    var c2da_fresh198_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[3]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[2]) != 0) {
                        c2da_fresh198_h264bsd = 2
                    } else {
                        c2da_fresh198_h264bsd = 0
                    }
                    unsafe(bS_8[5]).left = uint(uint(c2da_fresh198_h264bsd))
                    unsafe(bS_8[5]).left
                    var c2da_fresh199_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[7]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[6]) != 0) {
                        c2da_fresh199_h264bsd = 2
                    } else {
                        c2da_fresh199_h264bsd = 0
                    }
                    unsafe(bS_8[7]).left = uint(uint(c2da_fresh199_h264bsd))
                    unsafe(bS_8[7]).left
                    var c2da_fresh200_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[9]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[8]) != 0) {
                        c2da_fresh200_h264bsd = 2
                    } else {
                        c2da_fresh200_h264bsd = 0
                    }
                    unsafe(bS_8[9]).left = uint(uint(c2da_fresh200_h264bsd))
                    unsafe(bS_8[9]).left
                    var c2da_fresh201_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[13]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[12]) != 0) {
                        c2da_fresh201_h264bsd = 2
                    } else {
                        c2da_fresh201_h264bsd = 0
                    }
                    unsafe(bS_8[11]).left = uint(uint(c2da_fresh201_h264bsd))
                    unsafe(bS_8[11]).left
                    var c2da_fresh202_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[11]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[10]) != 0) {
                        c2da_fresh202_h264bsd = 2
                    } else {
                        c2da_fresh202_h264bsd = 0
                    }
                    unsafe(bS_8[13]).left = uint(uint(c2da_fresh202_h264bsd))
                    unsafe(bS_8[13]).left
                    var c2da_fresh203_h264bsd : int = 0
                    if (unsafe(unsafe(addr(mb_11.totalCoeff[0]))[15]) != 0 || unsafe(unsafe(addr(mb_11.totalCoeff[0]))[14]) != 0) {
                        c2da_fresh203_h264bsd = 2
                    } else {
                        c2da_fresh203_h264bsd = 0
                    }
                    unsafe(bS_8[15]).left = uint(uint(c2da_fresh203_h264bsd))
                    unsafe(bS_8[15]).left
                    unsafe(bS_8[2]).left = uint(InnerBoundaryStrength(mb_11, uint(4), uint(1)))
                    unsafe(bS_8[2]).left
                    unsafe(bS_8[6]).left = uint(InnerBoundaryStrength(mb_11, uint(6), uint(3)))
                    unsafe(bS_8[6]).left
                    unsafe(bS_8[10]).left = uint(InnerBoundaryStrength(mb_11, uint(12), uint(9)))
                    unsafe(bS_8[10]).left
                    unsafe(bS_8[14]).left = uint(InnerBoundaryStrength(mb_11, uint(14), uint(11)))
                    unsafe(bS_8[14]).left
                } else {
                    unsafe(bS_8[4]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[4]), unsafe(unsafe(addr(mb4x4Index[0]))[0])))
                    unsafe(bS_8[4]).top
                    unsafe(bS_8[5]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[5]), unsafe(unsafe(addr(mb4x4Index[0]))[1])))
                    unsafe(bS_8[5]).top
                    unsafe(bS_8[6]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[6]), unsafe(unsafe(addr(mb4x4Index[0]))[2])))
                    unsafe(bS_8[6]).top
                    unsafe(bS_8[7]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[7]), unsafe(unsafe(addr(mb4x4Index[0]))[3])))
                    unsafe(bS_8[7]).top
                    unsafe(bS_8[8]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[8]), unsafe(unsafe(addr(mb4x4Index[0]))[4])))
                    unsafe(bS_8[8]).top
                    unsafe(bS_8[9]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[9]), unsafe(unsafe(addr(mb4x4Index[0]))[5])))
                    unsafe(bS_8[9]).top
                    unsafe(bS_8[10]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[10]), unsafe(unsafe(addr(mb4x4Index[0]))[6])))
                    unsafe(bS_8[10]).top
                    unsafe(bS_8[11]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[11]), unsafe(unsafe(addr(mb4x4Index[0]))[7])))
                    unsafe(bS_8[11]).top
                    unsafe(bS_8[12]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[12]), unsafe(unsafe(addr(mb4x4Index[0]))[8])))
                    unsafe(bS_8[12]).top
                    unsafe(bS_8[13]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[13]), unsafe(unsafe(addr(mb4x4Index[0]))[9])))
                    unsafe(bS_8[13]).top
                    unsafe(bS_8[14]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[14]), unsafe(unsafe(addr(mb4x4Index[0]))[10])))
                    unsafe(bS_8[14]).top
                    unsafe(bS_8[15]).top = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[15]), unsafe(unsafe(addr(mb4x4Index[0]))[11])))
                    unsafe(bS_8[15]).top
                    unsafe(bS_8[1]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[1]), unsafe(unsafe(addr(mb4x4Index[0]))[0])))
                    unsafe(bS_8[1]).left
                    unsafe(bS_8[2]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[2]), unsafe(unsafe(addr(mb4x4Index[0]))[1])))
                    unsafe(bS_8[2]).left
                    unsafe(bS_8[3]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[3]), unsafe(unsafe(addr(mb4x4Index[0]))[2])))
                    unsafe(bS_8[3]).left
                    unsafe(bS_8[5]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[5]), unsafe(unsafe(addr(mb4x4Index[0]))[4])))
                    unsafe(bS_8[5]).left
                    unsafe(bS_8[6]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[6]), unsafe(unsafe(addr(mb4x4Index[0]))[5])))
                    unsafe(bS_8[6]).left
                    unsafe(bS_8[7]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[7]), unsafe(unsafe(addr(mb4x4Index[0]))[6])))
                    unsafe(bS_8[7]).left
                    unsafe(bS_8[9]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[9]), unsafe(unsafe(addr(mb4x4Index[0]))[8])))
                    unsafe(bS_8[9]).left
                    unsafe(bS_8[10]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[10]), unsafe(unsafe(addr(mb4x4Index[0]))[9])))
                    unsafe(bS_8[10]).left
                    unsafe(bS_8[11]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[11]), unsafe(unsafe(addr(mb4x4Index[0]))[10])))
                    unsafe(bS_8[11]).left
                    unsafe(bS_8[13]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[13]), unsafe(unsafe(addr(mb4x4Index[0]))[12])))
                    unsafe(bS_8[13]).left
                    unsafe(bS_8[14]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[14]), unsafe(unsafe(addr(mb4x4Index[0]))[13])))
                    unsafe(bS_8[14]).left
                    unsafe(bS_8[15]).left = uint(InnerBoundaryStrength(mb_11, unsafe(unsafe(addr(mb4x4Index[0]))[15]), unsafe(unsafe(addr(mb4x4Index[0]))[14])))
                    unsafe(bS_8[15]).left
                }
            }
        }
        if (nonZeroBs == 0 && unsafe(bS_8[4]).top != 0x0 || unsafe(bS_8[5]).top != 0x0 || unsafe(bS_8[6]).top != 0x0 || unsafe(bS_8[7]).top != 0x0 || unsafe(bS_8[8]).top != 0x0 || unsafe(bS_8[9]).top != 0x0 || unsafe(bS_8[10]).top != 0x0 || unsafe(bS_8[11]).top != 0x0 || unsafe(bS_8[12]).top != 0x0 || unsafe(bS_8[13]).top != 0x0 || unsafe(bS_8[14]).top != 0x0 || unsafe(bS_8[15]).top != 0x0 || unsafe(bS_8[1]).left != 0x0 || unsafe(bS_8[2]).left != 0x0 || unsafe(bS_8[3]).left != 0x0 || unsafe(bS_8[5]).left != 0x0 || unsafe(bS_8[6]).left != 0x0 || unsafe(bS_8[7]).left != 0x0 || unsafe(bS_8[9]).left != 0x0 || unsafe(bS_8[10]).left != 0x0 || unsafe(bS_8[11]).left != 0x0 || unsafe(bS_8[13]).left != 0x0 || unsafe(bS_8[14]).left != 0x0 || unsafe(bS_8[15]).left != 0x0) {
            nonZeroBs = uint(uint(1))
            nonZeroBs
        }
    }
    return nonZeroBs
}
var mb4x4Index : array<uint> const = [uint(0), uint(1), uint(4), uint(5), uint(2), uint(3), uint(6), uint(7), uint(8), uint(9), uint(12), uint(13), uint(10), uint(11), uint(14), uint(15)]

[export]
def InnerBoundaryStrength(var mb1 : mbStorage_t?; var ind1 : uint; var ind2 : uint) : uint {
    var tmp1_18 : int
    var tmp2_17 : int
    var mv1 : int
    var mv2 : int
    var mv3 : int
    var mv4 : int
    tmp1_18 = unsafe(unsafe(addr(mb1.totalCoeff[0]))[ind1])
    tmp1_18
    tmp2_17 = unsafe(unsafe(addr(mb1.totalCoeff[0]))[ind2])
    tmp2_17
    mv1 = unsafe(unsafe(addr(mb1.mv[0]))[ind1]).hor
    mv1
    mv2 = unsafe(unsafe(addr(mb1.mv[0]))[ind2]).hor
    mv2
    mv3 = unsafe(unsafe(addr(mb1.mv[0]))[ind1]).ver
    mv3
    mv4 = unsafe(unsafe(addr(mb1.mv[0]))[ind2]).ver
    mv4
    if (tmp1_18 != 0 || tmp2_17 != 0) {
        return uint(2)
    } else {
        if (uint(c2da_fresh204_h264bsd) >= uint(4) || uint(c2da_fresh205_h264bsd) >= uint(4) || unsafe(unsafe(addr(mb1.refAddr[0]))[uint(ind1) >> uint(uint(2))]) != unsafe(unsafe(addr(mb1.refAddr[0]))[uint(ind2) >> uint(uint(2))])) {
            return uint(1)
        } else {
            return uint(0)
        }
    }
}
[export]
def GetBoundaryStrengthsA(var mb_12 : mbStorage_t?; var bS_9 : bS_t?) {
    var c2da_fresh206_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[2]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[0]) != 0) {
        c2da_fresh206_h264bsd = 2
    } else {
        c2da_fresh206_h264bsd = 0
    }
    unsafe(bS_9[4]).top = uint(uint(c2da_fresh206_h264bsd))
    unsafe(bS_9[4]).top
    var c2da_fresh207_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[3]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[1]) != 0) {
        c2da_fresh207_h264bsd = 2
    } else {
        c2da_fresh207_h264bsd = 0
    }
    unsafe(bS_9[5]).top = uint(uint(c2da_fresh207_h264bsd))
    unsafe(bS_9[5]).top
    var c2da_fresh208_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[6]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[4]) != 0) {
        c2da_fresh208_h264bsd = 2
    } else {
        c2da_fresh208_h264bsd = 0
    }
    unsafe(bS_9[6]).top = uint(uint(c2da_fresh208_h264bsd))
    unsafe(bS_9[6]).top
    var c2da_fresh209_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[7]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[5]) != 0) {
        c2da_fresh209_h264bsd = 2
    } else {
        c2da_fresh209_h264bsd = 0
    }
    unsafe(bS_9[7]).top = uint(uint(c2da_fresh209_h264bsd))
    unsafe(bS_9[7]).top
    var c2da_fresh210_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[8]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[2]) != 0) {
        c2da_fresh210_h264bsd = 2
    } else {
        c2da_fresh210_h264bsd = 0
    }
    unsafe(bS_9[8]).top = uint(uint(c2da_fresh210_h264bsd))
    unsafe(bS_9[8]).top
    var c2da_fresh211_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[9]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[3]) != 0) {
        c2da_fresh211_h264bsd = 2
    } else {
        c2da_fresh211_h264bsd = 0
    }
    unsafe(bS_9[9]).top = uint(uint(c2da_fresh211_h264bsd))
    unsafe(bS_9[9]).top
    var c2da_fresh212_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[12]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[6]) != 0) {
        c2da_fresh212_h264bsd = 2
    } else {
        c2da_fresh212_h264bsd = 0
    }
    unsafe(bS_9[10]).top = uint(uint(c2da_fresh212_h264bsd))
    unsafe(bS_9[10]).top
    var c2da_fresh213_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[13]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[7]) != 0) {
        c2da_fresh213_h264bsd = 2
    } else {
        c2da_fresh213_h264bsd = 0
    }
    unsafe(bS_9[11]).top = uint(uint(c2da_fresh213_h264bsd))
    unsafe(bS_9[11]).top
    var c2da_fresh214_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[10]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[8]) != 0) {
        c2da_fresh214_h264bsd = 2
    } else {
        c2da_fresh214_h264bsd = 0
    }
    unsafe(bS_9[12]).top = uint(uint(c2da_fresh214_h264bsd))
    unsafe(bS_9[12]).top
    var c2da_fresh215_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[11]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[9]) != 0) {
        c2da_fresh215_h264bsd = 2
    } else {
        c2da_fresh215_h264bsd = 0
    }
    unsafe(bS_9[13]).top = uint(uint(c2da_fresh215_h264bsd))
    unsafe(bS_9[13]).top
    var c2da_fresh216_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[14]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[12]) != 0) {
        c2da_fresh216_h264bsd = 2
    } else {
        c2da_fresh216_h264bsd = 0
    }
    unsafe(bS_9[14]).top = uint(uint(c2da_fresh216_h264bsd))
    unsafe(bS_9[14]).top
    var c2da_fresh217_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[15]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[13]) != 0) {
        c2da_fresh217_h264bsd = 2
    } else {
        c2da_fresh217_h264bsd = 0
    }
    unsafe(bS_9[15]).top = uint(uint(c2da_fresh217_h264bsd))
    unsafe(bS_9[15]).top
    var c2da_fresh218_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[1]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[0]) != 0) {
        c2da_fresh218_h264bsd = 2
    } else {
        c2da_fresh218_h264bsd = 0
    }
    unsafe(bS_9[1]).left = uint(uint(c2da_fresh218_h264bsd))
    unsafe(bS_9[1]).left
    var c2da_fresh219_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[4]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[1]) != 0) {
        c2da_fresh219_h264bsd = 2
    } else {
        c2da_fresh219_h264bsd = 0
    }
    unsafe(bS_9[2]).left = uint(uint(c2da_fresh219_h264bsd))
    unsafe(bS_9[2]).left
    var c2da_fresh220_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[5]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[4]) != 0) {
        c2da_fresh220_h264bsd = 2
    } else {
        c2da_fresh220_h264bsd = 0
    }
    unsafe(bS_9[3]).left = uint(uint(c2da_fresh220_h264bsd))
    unsafe(bS_9[3]).left
    var c2da_fresh221_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[3]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[2]) != 0) {
        c2da_fresh221_h264bsd = 2
    } else {
        c2da_fresh221_h264bsd = 0
    }
    unsafe(bS_9[5]).left = uint(uint(c2da_fresh221_h264bsd))
    unsafe(bS_9[5]).left
    var c2da_fresh222_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[6]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[3]) != 0) {
        c2da_fresh222_h264bsd = 2
    } else {
        c2da_fresh222_h264bsd = 0
    }
    unsafe(bS_9[6]).left = uint(uint(c2da_fresh222_h264bsd))
    unsafe(bS_9[6]).left
    var c2da_fresh223_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[7]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[6]) != 0) {
        c2da_fresh223_h264bsd = 2
    } else {
        c2da_fresh223_h264bsd = 0
    }
    unsafe(bS_9[7]).left = uint(uint(c2da_fresh223_h264bsd))
    unsafe(bS_9[7]).left
    var c2da_fresh224_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[9]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[8]) != 0) {
        c2da_fresh224_h264bsd = 2
    } else {
        c2da_fresh224_h264bsd = 0
    }
    unsafe(bS_9[9]).left = uint(uint(c2da_fresh224_h264bsd))
    unsafe(bS_9[9]).left
    var c2da_fresh225_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[12]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[9]) != 0) {
        c2da_fresh225_h264bsd = 2
    } else {
        c2da_fresh225_h264bsd = 0
    }
    unsafe(bS_9[10]).left = uint(uint(c2da_fresh225_h264bsd))
    unsafe(bS_9[10]).left
    var c2da_fresh226_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[13]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[12]) != 0) {
        c2da_fresh226_h264bsd = 2
    } else {
        c2da_fresh226_h264bsd = 0
    }
    unsafe(bS_9[11]).left = uint(uint(c2da_fresh226_h264bsd))
    unsafe(bS_9[11]).left
    var c2da_fresh227_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[11]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[10]) != 0) {
        c2da_fresh227_h264bsd = 2
    } else {
        c2da_fresh227_h264bsd = 0
    }
    unsafe(bS_9[13]).left = uint(uint(c2da_fresh227_h264bsd))
    unsafe(bS_9[13]).left
    var c2da_fresh228_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[14]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[11]) != 0) {
        c2da_fresh228_h264bsd = 2
    } else {
        c2da_fresh228_h264bsd = 0
    }
    unsafe(bS_9[14]).left = uint(uint(c2da_fresh228_h264bsd))
    unsafe(bS_9[14]).left
    var c2da_fresh229_h264bsd : int = 0
    if (unsafe(unsafe(addr(mb_12.totalCoeff[0]))[15]) != 0 || unsafe(unsafe(addr(mb_12.totalCoeff[0]))[14]) != 0) {
        c2da_fresh229_h264bsd = 2
    } else {
        c2da_fresh229_h264bsd = 0
    }
    unsafe(bS_9[15]).left = uint(uint(c2da_fresh229_h264bsd))
    unsafe(bS_9[15]).left
}
[export]
def EdgeBoundaryStrength(var mb1_0 : mbStorage_t?; var mb2 : mbStorage_t?; var ind1_0 : uint; var ind2_0 : uint) : uint {
    if (unsafe(unsafe(addr(mb1_0.totalCoeff[0]))[ind1_0]) != 0 || unsafe(unsafe(addr(mb2.totalCoeff[0]))[ind2_0]) != 0) {
        return uint(2)
    } else {
        if (unsafe(unsafe(addr(mb1_0.refAddr[0]))[uint(ind1_0) >> uint(uint(2))]) != unsafe(unsafe(addr(mb2.refAddr[0]))[uint(ind2_0) >> uint(uint(2))]) || uint(c2da_fresh230_h264bsd) >= uint(4) || uint(c2da_fresh231_h264bsd) >= uint(4)) {
            return uint(1)
        } else {
            return uint(0)
        }
    }
}
[export]
def GetMbFilteringFlags(var mb_13 : mbStorage_t?) : uint {
    var flags_1 : uint = uint(0)
    if (mb_13.disableDeblockingFilterIdc != uint(1)) {
        flags_1 = uint(flags_1 | uint(1))
        flags_1
        if (mb_13.mbA != null && mb_13.disableDeblockingFilterIdc != uint(2) || IsSliceBoundaryOnLeft(mb_13) == 0) {
            flags_1 = uint(flags_1 | uint(4))
            flags_1
        }
        if (mb_13.mbB != null && mb_13.disableDeblockingFilterIdc != uint(2) || IsSliceBoundaryOnTop(mb_13) == 0) {
            flags_1 = uint(flags_1 | uint(2))
            flags_1
        }
    }
    return flags_1
}
[export]
def IsSliceBoundaryOnTop(var mb_14 : mbStorage_t?) : uint {
    if (mb_14.sliceId != mb_14.mbB.sliceId) {
        return uint(1)
    } else {
        return uint(0)
    }
}
[export]
def IsSliceBoundaryOnLeft(var mb_15 : mbStorage_t?) : uint {
    if (mb_15.sliceId != mb_15.mbA.sliceId) {
        return uint(1)
    } else {
        return uint(0)
    }
}
[export]
def InnerBoundaryStrength2(var mb1_1 : mbStorage_t?; var ind1_1 : uint; var ind2_1 : uint) : uint {
    var tmp1_19 : int
    var tmp2_18 : int
    var tmp3_15 : int
    var tmp4_11 : int
    tmp1_19 = unsafe(unsafe(addr(mb1_1.mv[0]))[ind1_1]).hor
    tmp1_19
    tmp2_18 = unsafe(unsafe(addr(mb1_1.mv[0]))[ind2_1]).hor
    tmp2_18
    tmp3_15 = unsafe(unsafe(addr(mb1_1.mv[0]))[ind1_1]).ver
    tmp3_15
    tmp4_11 = unsafe(unsafe(addr(mb1_1.mv[0]))[ind2_1]).ver
    tmp4_11
    if (uint(c2da_fresh232_h264bsd) >= uint(4) || uint(c2da_fresh233_h264bsd) >= uint(4) || unsafe(unsafe(addr(mb1_1.refAddr[0]))[uint(ind1_1) >> uint(uint(2))]) != unsafe(unsafe(addr(mb1_1.refAddr[0]))[uint(ind2_1) >> uint(uint(2))])) {
        return uint(1)
    } else {
        return uint(0)
    }
}
var sample : int = 0

var hashA : uint = uint(0)

var hashB : uint = uint(0)

var hashC : uint = uint(0)

var hashD : uint = uint(0)

[export]
def h264bsdInit(var pStorage_9 : storage_t?; var noOutputReordering : uint) : uint {
    var size : uint
    h264bsdInitStorage(pStorage_9)
    size = uint(uint(4 + uint64(63) & uint64(~63)))
    size
    pStorage_9.mbLayer = unsafe(reinterpret<macroblockLayer_t?>(malloc(uint64(size))))
    pStorage_9.mbLayer
    if (pStorage_9.mbLayer == null) {
        return uint(1)
    }
    if (noOutputReordering != 0x0) {
        pStorage_9.noReordering = uint(uint(1))
        pStorage_9.noReordering
    }
    return uint(0)
}
[export]
def h264bsdDecode(var pStorage_10 : storage_t?; var byteStrm : uint8?; var len_0 : uint; var picId : uint; var readBytes_0 : uint?) : uint {
    var tmp_55 : uint
    var ppsId_1 : uint
    var spsId : uint
    var picOrderCnt_3 : int
    var nalUnit : nalUnit_t
    var seqParamSet : seqParamSet_t
    var picParamSet : picParamSet_t
    var strm_0 : strmData_t
    var accessUnitBoundaryFlag_0 : uint = uint(0)
    var picReady : uint = uint(0)
    if (pStorage_10.prevBufNotFinished != 0x0 && byteStrm == pStorage_10.prevBufPointer) {
        strm_0 = unsafe(unsafe(addr(pStorage_10.strm[0]))[0])
        strm_0
        strm_0.pStrmCurrPos = strm_0.pStrmBuffStart
        strm_0.pStrmCurrPos
        strm_0.bitPosInWord = uint(uint(0))
        strm_0.strmBuffReadBits = uint(strm_0.bitPosInWord)
        strm_0.strmBuffReadBits
        *readBytes_0 = uint(pStorage_10.prevBytesConsumed)
        *readBytes_0
    } else {
        tmp_55 = uint(h264bsdExtractNalUnit(byteStrm, len_0, unsafe(addr(strm_0)), readBytes_0))
        tmp_55
        if (tmp_55 != uint(0)) {
            return uint(H264BSD_ERROR)
        }
        unsafe(unsafe(addr(pStorage_10.strm[0]))[0]) = strm_0
        unsafe(unsafe(addr(pStorage_10.strm[0]))[0])
        pStorage_10.prevBytesConsumed = uint(*readBytes_0)
        pStorage_10.prevBytesConsumed
        pStorage_10.prevBufPointer = byteStrm
        pStorage_10.prevBufPointer
    }
    pStorage_10.prevBufNotFinished = uint(uint(0))
    pStorage_10.prevBufNotFinished
    tmp_55 = uint(h264bsdDecodeNalUnit(unsafe(addr(strm_0)), unsafe(addr(nalUnit))))
    tmp_55
    if (tmp_55 != uint(0)) {
        return uint(H264BSD_ERROR)
    }
    if (uint(nalUnit.nalUnitType) == uint(0) || uint(nalUnit.nalUnitType) >= uint(13)) {
        return uint(H264BSD_RDY)
    }
    tmp_55 = uint(h264bsdCheckAccessUnitBoundary(unsafe(addr(strm_0)), unsafe(addr(nalUnit)), pStorage_10, unsafe(addr(accessUnitBoundaryFlag_0))))
    tmp_55
    if (tmp_55 != uint(0)) {
        if (tmp_55 == uint(65520)) {
            return uint(H264BSD_PARAM_SET_ERROR)
        } else {
            return uint(H264BSD_ERROR)
        }
    }
    if (accessUnitBoundaryFlag_0 != 0x0) {
        if (pStorage_10.picStarted != 0x0 && pStorage_10.activeSps != unsafe(unsafe(reinterpret<seqParamSet_t?>(uint64(0))))) {
            if (pStorage_10.pendingActivation != 0x0) {
                return uint(H264BSD_ERROR)
            }
            if (pStorage_10.validSliceInAccessUnit == 0) {
                unsafe(addr(pStorage_10.currImage[0])).data = h264bsdAllocateDpbImage(unsafe(addr(pStorage_10.dpb[0])))
                unsafe(addr(pStorage_10.currImage[0])).data
                h264bsdInitRefPicList(unsafe(addr(pStorage_10.dpb[0])))
                tmp_55 = uint(h264bsdConceal(pStorage_10, unsafe(addr(pStorage_10.currImage[0])), uint(P_SLICE)))
                tmp_55
            } else {
                tmp_55 = uint(h264bsdConceal(pStorage_10, unsafe(addr(pStorage_10.currImage[0])), unsafe(addr(pStorage_10.sliceHeader[0])).sliceType))
                tmp_55
            }
            picReady = uint(uint(1))
            picReady
            *readBytes_0 = uint(uint(0))
            *readBytes_0
            pStorage_10.prevBufNotFinished = uint(uint(1))
            pStorage_10.prevBufNotFinished
        } else {
            pStorage_10.validSliceInAccessUnit = uint(uint(0))
            pStorage_10.validSliceInAccessUnit
        }
        pStorage_10.skipRedundantSlices = uint(uint(0))
        pStorage_10.skipRedundantSlices
    }
    if (picReady == 0) {
        if (uint(nalUnit.nalUnitType) == uint(NAL_SEQ_PARAM_SET) || uint(nalUnit.nalUnitType) == uint(NAL_PIC_PARAM_SET) || uint(nalUnit.nalUnitType) == uint(NAL_CODED_SLICE_IDR) || uint(nalUnit.nalUnitType) == uint(NAL_CODED_SLICE) || uint(nalUnit.nalUnitType) == uint(NAL_SEI)) {
        }
    }
    if (picReady != 0x0) {
        h264bsdFilterPicture(unsafe(addr(pStorage_10.currImage[0])), pStorage_10.mb)
        h264bsdResetStorage(pStorage_10)
        picOrderCnt_3 = h264bsdDecodePicOrderCnt(unsafe(addr(pStorage_10.poc[0])), pStorage_10.activeSps, unsafe(addr(pStorage_10.sliceHeader[0])), unsafe(addr(pStorage_10.prevNalUnit[0])))
        picOrderCnt_3
        if (pStorage_10.validSliceInAccessUnit != 0x0) {
            if (unsafe(addr(pStorage_10.prevNalUnit[0])).nalRefIdc != 0x0) {
                var c2da_fresh234_h264bsd : int = 0
                if (uint(unsafe(addr(pStorage_10.prevNalUnit[0])).nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
                    c2da_fresh234_h264bsd = 1
                } else {
                    c2da_fresh234_h264bsd = 0
                }
                tmp_55 = uint(h264bsdMarkDecRefPic(unsafe(addr(pStorage_10.dpb[0])), unsafe(addr(unsafe(addr(pStorage_10.sliceHeader[0])).decRefPicMarking)), unsafe(addr(pStorage_10.currImage[0])), unsafe(addr(pStorage_10.sliceHeader[0])).frameNum, picOrderCnt_3, uint(c2da_fresh234_h264bsd), pStorage_10.currentPicId, pStorage_10.numConcealedMbs))
                tmp_55
            } else {
                var c2da_fresh235_h264bsd : int = 0
                if (uint(unsafe(addr(pStorage_10.prevNalUnit[0])).nalUnitType) == uint(NAL_CODED_SLICE_IDR)) {
                    c2da_fresh235_h264bsd = 1
                } else {
                    c2da_fresh235_h264bsd = 0
                }
                tmp_55 = uint(h264bsdMarkDecRefPic(unsafe(addr(pStorage_10.dpb[0])), null, unsafe(addr(pStorage_10.currImage[0])), unsafe(addr(pStorage_10.sliceHeader[0])).frameNum, picOrderCnt_3, uint(c2da_fresh235_h264bsd), pStorage_10.currentPicId, pStorage_10.numConcealedMbs))
                tmp_55
            }
        }
        pStorage_10.picStarted = uint(uint(0))
        pStorage_10.picStarted
        pStorage_10.validSliceInAccessUnit = uint(uint(0))
        pStorage_10.validSliceInAccessUnit
        return uint(H264BSD_PIC_RDY)
    } else {
        return uint(H264BSD_RDY)
    }
}
[export]
def h264bsdMarkSliceCorrupted(var pStorage_11 : storage_t?; var firstMbInSlice : uint) {
    var tmp_56 : uint
    var i_75 : uint
    var sliceId_0 : uint
    var currMbAddr_0 : uint
    currMbAddr_0 = uint(firstMbInSlice)
    currMbAddr_0
    sliceId_0 = uint(unsafe(addr(pStorage_11.slice[0])).sliceId)
    sliceId_0
    if (unsafe(addr(pStorage_11.slice[0])).lastMbAddr != 0x0) {
        i_75 = uint(unsafe(addr(pStorage_11.slice[0])).lastMbAddr - uint(1))
        i_75
        tmp_56 = uint(uint(0))
        tmp_56
        while (i_75 > currMbAddr_0) {
            if (unsafe(pStorage_11.mb[i_75]).sliceId == sliceId_0) {
                tmp_56 = tmp_56 + 1
                tmp_56
                if (tmp_56 >= c2da_fresh236_h264bsd) {
                    break
                }
            }
            i_75 = i_75 - 1
            i_75
        }
        currMbAddr_0 = uint(i_75)
        currMbAddr_0
    }
    var _dw_76118 : bool = true
    while (_dw_76118 || currMbAddr_0) {
        _dw_76118 = false
        if (unsafe(pStorage_11.mb[currMbAddr_0]).sliceId == sliceId_0 && unsafe(pStorage_11.mb[currMbAddr_0]).decoded != 0x0) {
            unsafe(pStorage_11.mb[currMbAddr_0]).decoded = unsafe(pStorage_11.mb[currMbAddr_0]).decoded - 1
            unsafe(pStorage_11.mb[currMbAddr_0]).decoded
        } else {
            break
        }
        currMbAddr_0 = uint(h264bsdNextMbAddress(pStorage_11.sliceGroupMap, pStorage_11.picSizeInMbs, currMbAddr_0))
        currMbAddr_0
    }
}
[export]
def h264bsdDecodeSliceData(var pStrmData_31 : strmData_t?; var pStorage_12 : storage_t?; var currImage_3 : image_t?; var pSliceHeader_1 : sliceHeader_t?) : uint {
    var mbData : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var data_41 : uint8?
    var tmp_57 : uint
    var skipRun : uint
    var prevSkipped : uint
    var currMbAddr_1 : uint
    var moreMbs : uint
    var mbCount : uint
    var qpY_0 : int
    var mbLayer_1 : macroblockLayer_t?
    data_41 = cast<uint8?>(unsafe(unsafe(addr(mbData[0])) + cast<uintptr_t>(16) - unsafe(reinterpret<uintptr_t>(unsafe(addr(mbData[0])))) & cast<uintptr_t>(16 - 1) / 4))
    data_41
    mbLayer_1 = pStorage_12.mbLayer
    mbLayer_1
    currMbAddr_1 = uint(pSliceHeader_1.firstMbInSlice)
    currMbAddr_1
    skipRun = uint(uint(0))
    skipRun
    prevSkipped = uint(uint(0))
    prevSkipped
    unsafe(addr(pStorage_12.slice[0])).sliceId = unsafe(addr(pStorage_12.slice[0])).sliceId + 1
    unsafe(addr(pStorage_12.slice[0])).sliceId
    unsafe(addr(pStorage_12.slice[0])).lastMbAddr = uint(uint(0))
    unsafe(addr(pStorage_12.slice[0])).lastMbAddr
    mbCount = uint(uint(0))
    mbCount
    qpY_0 = int(pStorage_12.activePps.picInitQp) + pSliceHeader_1.sliceQpDelta
    qpY_0
    var _dw_76333 : bool = true
    while (_dw_76333 || moreMbs) {
        _dw_76333 = false
        if (pSliceHeader_1.redundantPicCnt == 0 && unsafe(pStorage_12.mb[currMbAddr_1]).decoded != 0x0) {
            return uint(1)
        }
        SetMbParams(unsafe(pStorage_12.mb + currMbAddr_1), pSliceHeader_1, unsafe(addr(pStorage_12.slice[0])).sliceId, pStorage_12.activePps.chromaQpIndexOffset)
        if (pSliceHeader_1.sliceType == uint(I_SLICE) || pSliceHeader_1.sliceType == uint(I_SLICE + 5) == 0) {
            if (prevSkipped == 0) {
                tmp_57 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_31, unsafe(addr(skipRun))))
                tmp_57
                if (tmp_57 != uint(0)) {
                    return tmp_57
                }
                if (skipRun > pStorage_12.picSizeInMbs - currMbAddr_1) {
                    return uint(1)
                }
                if (skipRun != 0x0) {
                    prevSkipped = uint(uint(1))
                    prevSkipped
                    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mbLayer_1.mbPred))))), 0, 4)
                    mbLayer_1.mbType = cast<mbType_e>(P_Skip)
                    mbLayer_1.mbType
                }
            }
        }
        if (skipRun != 0x0) {
            skipRun = skipRun - 1
            skipRun
        } else {
            prevSkipped = uint(uint(0))
            prevSkipped
            tmp_57 = uint(h264bsdDecodeMacroblockLayer(pStrmData_31, mbLayer_1, unsafe(pStorage_12.mb + currMbAddr_1), pSliceHeader_1.sliceType, pSliceHeader_1.numRefIdxL0Active))
            tmp_57
            if (tmp_57 != uint(0)) {
                return tmp_57
            }
        }
        tmp_57 = uint(h264bsdDecodeMacroblock(unsafe(pStorage_12.mb + currMbAddr_1), mbLayer_1, currImage_3, unsafe(addr(pStorage_12.dpb[0])), unsafe(addr(qpY_0)), currMbAddr_1, pStorage_12.activePps.constrainedIntraPredFlag, data_41))
        tmp_57
        if (tmp_57 != uint(0)) {
            return tmp_57
        }
        if (unsafe(pStorage_12.mb[currMbAddr_1]).decoded == uint(1)) {
            mbCount = mbCount + 1
            mbCount
        }
        var c2da_fresh237_h264bsd : int = 0
        if (h264bsdMoreRbspData(pStrmData_31) != 0x0 || skipRun != 0x0) {
            c2da_fresh237_h264bsd = 1
        } else {
            c2da_fresh237_h264bsd = 0
        }
        moreMbs = uint(uint(c2da_fresh237_h264bsd))
        moreMbs
        if (pSliceHeader_1.sliceType == uint(I_SLICE) || pSliceHeader_1.sliceType == uint(I_SLICE + 5)) {
            unsafe(addr(pStorage_12.slice[0])).lastMbAddr = uint(currMbAddr_1)
            unsafe(addr(pStorage_12.slice[0])).lastMbAddr
        }
        currMbAddr_1 = uint(h264bsdNextMbAddress(pStorage_12.sliceGroupMap, pStorage_12.picSizeInMbs, currMbAddr_1))
        currMbAddr_1
        if (moreMbs != 0x0 && currMbAddr_1 == 0) {
            return uint(1)
        }
    }
    if (unsafe(addr(pStorage_12.slice[0])).numDecodedMbs + mbCount > pStorage_12.picSizeInMbs) {
        return uint(1)
    }
    unsafe(addr(pStorage_12.slice[0])).numDecodedMbs = uint(unsafe(addr(pStorage_12.slice[0])).numDecodedMbs + mbCount)
    unsafe(addr(pStorage_12.slice[0])).numDecodedMbs
    return uint(0)
}
[export]
def SetMbParams(var pMb_19 : mbStorage_t?; var pSlice : sliceHeader_t?; var sliceId_1 : uint; var chromaQpIndexOffset_0 : int) {
    var tmp1_20 : uint
    var tmp2_19 : int
    var tmp3_16 : int
    tmp1_20 = uint(pSlice.disableDeblockingFilterIdc)
    tmp1_20
    tmp2_19 = pSlice.sliceAlphaC0Offset
    tmp2_19
    tmp3_16 = pSlice.sliceBetaOffset
    tmp3_16
    pMb_19.sliceId = uint(sliceId_1)
    pMb_19.sliceId
    pMb_19.disableDeblockingFilterIdc = uint(tmp1_20)
    pMb_19.disableDeblockingFilterIdc
    pMb_19.filterOffsetA = tmp2_19
    pMb_19.filterOffsetA
    pMb_19.filterOffsetB = tmp3_16
    pMb_19.filterOffsetB
    pMb_19.chromaQpIndexOffset = chromaQpIndexOffset_0
    pMb_19.chromaQpIndexOffset
}
[export]
def h264bsdShutdown(var pStorage_13 : storage_t?) {
    var i_76 : uint
    i_76 = uint(uint(0))
    i_76
    while (i_76 < uint(32)) {
        if (unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76]) != null) {
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76]).offsetForRefFrame))))
            unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76]).offsetForRefFrame = null
            unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76]).offsetForRefFrame
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76]).vuiParameters))))
            unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76]).vuiParameters = null
            unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76]).vuiParameters
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76])))))
            unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76]) = null
            unsafe(unsafe(addr(pStorage_13.sps[0]))[i_76])
        }
        i_76 = i_76 + 1
    }
    i_76 = uint(uint(0))
    i_76
    while (i_76 < uint(256)) {
        if (unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]) != null) {
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).runLength))))
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).runLength = null
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).runLength
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).topLeft))))
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).topLeft = null
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).topLeft
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).bottomRight))))
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).bottomRight = null
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).bottomRight
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).sliceGroupId))))
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).sliceGroupId = null
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]).sliceGroupId
            free(unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76])))))
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76]) = null
            unsafe(unsafe(addr(pStorage_13.pps[0]))[i_76])
        }
        i_76 = i_76 + 1
    }
    free(unsafe(unsafe(reinterpret<uint64>(pStorage_13.mbLayer))))
    pStorage_13.mbLayer = null
    pStorage_13.mbLayer
    free(unsafe(unsafe(reinterpret<uint64>(pStorage_13.mb))))
    pStorage_13.mb = null
    pStorage_13.mb
    free(unsafe(unsafe(reinterpret<uint64>(pStorage_13.sliceGroupMap))))
    pStorage_13.sliceGroupMap = null
    pStorage_13.sliceGroupMap
    if (pStorage_13.conversionBuffer != unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
        free(unsafe(unsafe(reinterpret<uint64>(pStorage_13.conversionBuffer))))
        pStorage_13.conversionBuffer = null
        pStorage_13.conversionBuffer
    }
    h264bsdFreeDpb(unsafe(addr(pStorage_13.dpb[0])))
}
[export]
def h264bsdNextOutputPicture(var pStorage_14 : storage_t?; var picId_0 : uint?; var isIdrPic : uint?; var numErrMbs_0 : uint?) : uint8? {
    var pOut : dpbOutPicture_t?
    pOut = h264bsdDpbOutputPicture(unsafe(addr(pStorage_14.dpb[0])))
    pOut
    if (pOut != unsafe(unsafe(reinterpret<dpbOutPicture_t?>(uint64(0))))) {
        *picId_0 = uint(pOut.picId)
        *picId_0
        *isIdrPic = uint(pOut.isIdr)
        *isIdrPic
        *numErrMbs_0 = uint(pOut.numErrMbs)
        *numErrMbs_0
        return pOut.data
    } else {
        return null
    }
}
[export]
def h264bsdNextOutputPictureRGBA(var pStorage_15 : storage_t?; var picId_1 : uint?; var isIdrPic_0 : uint?; var numErrMbs_1 : uint?) : uint? {
    var width_24 : uint = h264bsdPicWidth(pStorage_15) * uint(16)
    var height_16 : uint = h264bsdPicHeight(pStorage_15) * uint(16)
    var data_42 : uint8? = h264bsdNextOutputPicture(pStorage_15, picId_1, isIdrPic_0, numErrMbs_1)
    var rgbSize : size_t = 4 * uint64(width_24) * uint64(height_16)
    if (data_42 == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return null
    }
    if (pStorage_15.conversionBufferSize < rgbSize) {
        if (pStorage_15.conversionBuffer != unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
            free(unsafe(unsafe(reinterpret<uint64>(pStorage_15.conversionBuffer))))
        }
        pStorage_15.conversionBufferSize = uint64(rgbSize)
        pStorage_15.conversionBufferSize
        pStorage_15.conversionBuffer = unsafe(reinterpret<uint?>(malloc(rgbSize)))
        pStorage_15.conversionBuffer
    }
    h264bsdConvertToRGBA(width_24, height_16, data_42, pStorage_15.conversionBuffer)
    return pStorage_15.conversionBuffer
}
[export]
def h264bsdPicHeight(var pStorage_16 : storage_t?) : uint {
    if (pStorage_16.activeSps != null) {
        return pStorage_16.activeSps.picHeightInMbs
    } else {
        return uint(0)
    }
}
[export]
def h264bsdPicWidth(var pStorage_17 : storage_t?) : uint {
    if (pStorage_17.activeSps != null) {
        return pStorage_17.activeSps.picWidthInMbs
    } else {
        return uint(0)
    }
}
[export]
def h264bsdConvertToRGBA(var width_25 : uint; var height_17 : uint; var data_43 : uint8?; var pOutput : uint?) {
    var w : int const = int(width_25)
    var h : int const = int(height_17)
    var x_16 : int = 0
    var y_16 : int = 0
    var ySize : size_t = cast<size_t>(w * h)
    var cbSize : size_t = cast<size_t>(w / 2 * h / 2)
    var luma : uint8? = data_43
    var cb_1 : uint8? = unsafe(data_43 + ySize)
    var cr_1 : uint8? = unsafe(unsafe(data_43 + ySize) + cbSize)
    var rgba : uint? = pOutput
    while (y_16 < h) {
        var c_4 : int = int(*luma) - 16
        var d : int = int(*cb_1) - 128
        var e : int = int(*cr_1) - 128
        var r_0 : uint = uint(c2da_fresh239_h264bsd)
        var g : uint = uint(c2da_fresh241_h264bsd)
        var b_3 : uint = uint(c2da_fresh243_h264bsd)
        var pixel : uint = uint(255)
        pixel = uint(uint(pixel) << uint(uint(8)) + b_3)
        pixel
        pixel = uint(uint(pixel) << uint(uint(8)) + g)
        pixel
        pixel = uint(uint(pixel) << uint(uint(8)) + r_0)
        pixel
        *rgba = uint(pixel)
        *rgba
        x_16 = x_16 + 1
        x_16
        rgba = rgba + 1
        rgba
        luma = luma + 1
        luma
        if (x_16 & 1 == 0) {
            cb_1 = cb_1 + 1
            cb_1
            cr_1 = cr_1 + 1
            cr_1
        }
        if (x_16 < w) {
            continue
        }
        x_16 = 0
        x_16
        y_16 = y_16 + 1
        y_16
        if (y_16 & 1 != 0) {
            cb_1 = cb_1 - w / 2
            cb_1
            cr_1 = cr_1 - w / 2
            cr_1
        }
    }
}
[export]
def h264bsdNextOutputPictureBGRA(var pStorage_18 : storage_t?; var picId_2 : uint?; var isIdrPic_1 : uint?; var numErrMbs_2 : uint?) : uint? {
    var width_26 : uint = h264bsdPicWidth(pStorage_18) * uint(16)
    var height_18 : uint = h264bsdPicHeight(pStorage_18) * uint(16)
    var data_44 : uint8? = h264bsdNextOutputPicture(pStorage_18, picId_2, isIdrPic_1, numErrMbs_2)
    var rgbSize_0 : size_t = 4 * uint64(width_26) * uint64(height_18)
    if (data_44 == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return null
    }
    if (pStorage_18.conversionBufferSize < rgbSize_0) {
        if (pStorage_18.conversionBuffer != unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
            free(unsafe(unsafe(reinterpret<uint64>(pStorage_18.conversionBuffer))))
        }
        pStorage_18.conversionBufferSize = uint64(rgbSize_0)
        pStorage_18.conversionBufferSize
        pStorage_18.conversionBuffer = unsafe(reinterpret<uint?>(malloc(rgbSize_0)))
        pStorage_18.conversionBuffer
    }
    h264bsdConvertToBGRA(width_26, height_18, data_44, pStorage_18.conversionBuffer)
    return pStorage_18.conversionBuffer
}
[export]
def h264bsdConvertToBGRA(var width_27 : uint; var height_19 : uint; var data_45 : uint8?; var pOutput_0 : uint?) {
    var w_0 : int const = int(width_27)
    var h_0 : int const = int(height_19)
    var x_17 : int = 0
    var y_17 : int = 0
    var ySize_0 : size_t = cast<size_t>(w_0 * h_0)
    var cbSize_0 : size_t = cast<size_t>(w_0 / 2 * h_0 / 2)
    var luma_0 : uint8? = data_45
    var cb_2 : uint8? = unsafe(data_45 + ySize_0)
    var cr_2 : uint8? = unsafe(unsafe(data_45 + ySize_0) + cbSize_0)
    var bgra : uint? = pOutput_0
    while (y_17 < h_0) {
        var c_5 : int = int(*luma_0) - 16
        var d_0 : int = int(*cb_2) - 128
        var e_0 : int = int(*cr_2) - 128
        var r_1 : uint = uint(c2da_fresh245_h264bsd)
        var g_0 : uint = uint(c2da_fresh247_h264bsd)
        var b_4 : uint = uint(c2da_fresh249_h264bsd)
        var pixel_0 : uint = uint(255)
        pixel_0 = uint(uint(pixel_0) << uint(uint(8)) + r_1)
        pixel_0
        pixel_0 = uint(uint(pixel_0) << uint(uint(8)) + g_0)
        pixel_0
        pixel_0 = uint(uint(pixel_0) << uint(uint(8)) + b_4)
        pixel_0
        *bgra = uint(pixel_0)
        *bgra
        x_17 = x_17 + 1
        x_17
        bgra = bgra + 1
        bgra
        luma_0 = luma_0 + 1
        luma_0
        if (x_17 & 1 == 0) {
            cb_2 = cb_2 + 1
            cb_2
            cr_2 = cr_2 + 1
            cr_2
        }
        if (x_17 < w_0) {
            continue
        }
        x_17 = 0
        x_17
        y_17 = y_17 + 1
        y_17
        if (y_17 & 1 != 0) {
            cb_2 = cb_2 - w_0 / 2
            cb_2
            cr_2 = cr_2 - w_0 / 2
            cr_2
        }
    }
}
[export]
def h264bsdNextOutputPictureYCbCrA(var pStorage_19 : storage_t?; var picId_3 : uint?; var isIdrPic_2 : uint?; var numErrMbs_3 : uint?) : uint? {
    var width_28 : uint = h264bsdPicWidth(pStorage_19) * uint(16)
    var height_20 : uint = h264bsdPicHeight(pStorage_19) * uint(16)
    var data_46 : uint8? = h264bsdNextOutputPicture(pStorage_19, picId_3, isIdrPic_2, numErrMbs_3)
    var rgbSize_1 : size_t = 4 * uint64(width_28) * uint64(height_20)
    if (data_46 == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return null
    }
    if (pStorage_19.conversionBufferSize < rgbSize_1) {
        if (pStorage_19.conversionBuffer != unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
            free(unsafe(unsafe(reinterpret<uint64>(pStorage_19.conversionBuffer))))
        }
        pStorage_19.conversionBufferSize = uint64(rgbSize_1)
        pStorage_19.conversionBufferSize
        pStorage_19.conversionBuffer = unsafe(reinterpret<uint?>(malloc(rgbSize_1)))
        pStorage_19.conversionBuffer
    }
    h264bsdConvertToYCbCrA(width_28, height_20, data_46, pStorage_19.conversionBuffer)
    return pStorage_19.conversionBuffer
}
[export]
def h264bsdConvertToYCbCrA(var width_29 : uint; var height_21 : uint; var data_47 : uint8?; var pOutput_1 : uint?) {
    var w_1 : int const = int(width_29)
    var h_1 : int const = int(height_21)
    var x_18 : int = 0
    var y_18 : int = 0
    var ySize_1 : size_t = cast<size_t>(w_1 * h_1)
    var cbSize_1 : size_t = cast<size_t>(w_1 / 2 * h_1 / 2)
    var luma_1 : uint8? = data_47
    var cb_3 : uint8? = unsafe(data_47 + ySize_1)
    var cr_3 : uint8? = unsafe(unsafe(data_47 + ySize_1) + cbSize_1)
    var yCbCr : uint? = pOutput_1
    while (y_18 < h_1) {
        var pixel_1 : uint = uint(255)
        pixel_1 = uint(uint(pixel_1) << uint(uint(8)) + uint(*cr_3))
        pixel_1
        pixel_1 = uint(uint(pixel_1) << uint(uint(8)) + uint(*cb_3))
        pixel_1
        pixel_1 = uint(uint(pixel_1) << uint(uint(8)) + uint(*luma_1))
        pixel_1
        *yCbCr = uint(pixel_1)
        *yCbCr
        x_18 = x_18 + 1
        x_18
        yCbCr = yCbCr + 1
        yCbCr
        luma_1 = luma_1 + 1
        luma_1
        if (x_18 & 1 == 0) {
            cb_3 = cb_3 + 1
            cb_3
            cr_3 = cr_3 + 1
            cr_3
        }
        if (x_18 < w_1) {
            continue
        }
        x_18 = 0
        x_18
        y_18 = y_18 + 1
        y_18
        if (y_18 & 1 != 0) {
            cb_3 = cb_3 - w_1 / 2
            cb_3
            cr_3 = cr_3 - w_1 / 2
            cr_3
        }
    }
}
[export]
def h264bsdVideoRange(var pStorage_20 : storage_t?) : uint {
    if (pStorage_20.activeSps != null && pStorage_20.activeSps.vuiParametersPresentFlag != 0x0 && pStorage_20.activeSps.vuiParameters != null && pStorage_20.activeSps.vuiParameters.videoSignalTypePresentFlag != 0x0 && pStorage_20.activeSps.vuiParameters.videoFullRangeFlag != 0x0) {
        return uint(1)
    } else {
        return uint(0)
    }
}
[export]
def h264bsdMatrixCoefficients(var pStorage_21 : storage_t?) : uint {
    if (pStorage_21.activeSps != null && pStorage_21.activeSps.vuiParametersPresentFlag != 0x0 && pStorage_21.activeSps.vuiParameters != null && pStorage_21.activeSps.vuiParameters.videoSignalTypePresentFlag != 0x0 && pStorage_21.activeSps.vuiParameters.colourDescriptionPresentFlag != 0x0) {
        return pStorage_21.activeSps.vuiParameters.matrixCoefficients
    } else {
        return uint(2)
    }
}
[export]
def h264bsdCroppingParams(var pStorage_22 : storage_t?; var croppingFlag : uint?; var leftOffset : uint?; var width_30 : uint?; var topOffset : uint?; var height_22 : uint?) {
    if (pStorage_22.activeSps != null && pStorage_22.activeSps.frameCroppingFlag != 0x0) {
        *croppingFlag = uint(uint(1))
        *croppingFlag
        *leftOffset = uint(uint(2) * pStorage_22.activeSps.frameCropLeftOffset)
        *leftOffset
        *width_30 = uint(uint(16) * pStorage_22.activeSps.picWidthInMbs - uint(2) * pStorage_22.activeSps.frameCropLeftOffset + pStorage_22.activeSps.frameCropRightOffset)
        *width_30
        *topOffset = uint(uint(2) * pStorage_22.activeSps.frameCropTopOffset)
        *topOffset
        *height_22 = uint(uint(16) * pStorage_22.activeSps.picHeightInMbs - uint(2) * pStorage_22.activeSps.frameCropTopOffset + pStorage_22.activeSps.frameCropBottomOffset)
        *height_22
    } else {
        *croppingFlag = uint(uint(0))
        *croppingFlag
        *leftOffset = uint(uint(0))
        *leftOffset
        *width_30 = uint(uint(0))
        *width_30
        *topOffset = uint(uint(0))
        *topOffset
        *height_22 = uint(uint(0))
        *height_22
    }
}
[export]
def h264bsdSampleAspectRatio(var pStorage_23 : storage_t?; var sarWidth : uint?; var sarHeight : uint?) {
    var w_2 : uint = uint(1)
    var h_2 : uint = uint(1)
    if (pStorage_23.activeSps != null && pStorage_23.activeSps.vuiParametersPresentFlag != 0x0 && pStorage_23.activeSps.vuiParameters != null && pStorage_23.activeSps.vuiParameters.aspectRatioPresentFlag != 0x0) {
        if (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_UNSPECIFIED)) {
            w_2 = uint(uint(0))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_1_1)) {
            w_2 = uint(uint(1))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_12_11)) {
            w_2 = uint(uint(12))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_10_11)) {
            w_2 = uint(uint(10))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_16_11)) {
            w_2 = uint(uint(16))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_40_33)) {
            w_2 = uint(uint(40))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_24_11)) {
            w_2 = uint(uint(24))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_20_11)) {
            w_2 = uint(uint(20))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_32_11)) {
            w_2 = uint(uint(32))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_80_33)) {
            w_2 = uint(uint(80))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_18_11)) {
            w_2 = uint(uint(18))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_15_11)) {
            w_2 = uint(uint(15))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_64_33)) {
            w_2 = uint(uint(64))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_160_99)) {
            w_2 = uint(uint(160))
            w_2
        } elif (pStorage_23.activeSps.vuiParameters.aspectRatioIdc == uint(ASPECT_RATIO_EXTENDED_SAR)) {
            w_2 = uint(pStorage_23.activeSps.vuiParameters.sarWidth)
            w_2
        } else {
            w_2 = uint(uint(0))
            w_2
        }
    }
    *sarWidth = uint(w_2)
    *sarWidth
    *sarHeight = uint(h_2)
    *sarHeight
}
[export]
def h264bsdCheckValidParamSets(var pStorage_24 : storage_t?) : uint {
    var c2da_fresh250_h264bsd : int = 0
    if (h264bsdValidParamSets(pStorage_24) == uint(0)) {
        c2da_fresh250_h264bsd = 1
    } else {
        c2da_fresh250_h264bsd = 0
    }
    return uint(c2da_fresh250_h264bsd)
}
[export]
def h264bsdFlushBuffer(var pStorage_25 : storage_t?) {
    h264bsdFlushDpb(unsafe(addr(pStorage_25.dpb[0])))
}
[export]
def h264bsdProfile(var pStorage_26 : storage_t?) : uint {
    if (pStorage_26.activeSps != null) {
        return pStorage_26.activeSps.profileIdc
    } else {
        return uint(0)
    }
}
[export]
def h264bsdAlloc() : storage_t? {
    return unsafe(reinterpret<storage_t?>(malloc(4)))
}
[export]
def h264bsdFree(var pStorage_27 : storage_t?) {
    free(unsafe(unsafe(reinterpret<uint64>(pStorage_27))))
}
[export]
def get_h264bsdClip() : uint8? {
    return cast<uint8?>(unsafe(addr(h264bsdClip[0])))
}
[export]
def h264bsdDecodeSeiMessage(var pStrmData_32 : strmData_t?; var pSeqParamSet_7 : seqParamSet_t?; var pSeiMessage : seiMessage_t?; var numSliceGroups_2 : uint) : uint {
    var tmp_58 : uint
    var payloadType : uint
    var payloadSize : uint
    var status_2 : uint
    memset(unsafe(unsafe(reinterpret<uint64>(pSeiMessage))), 0, 4)
    var _dw_80899 : bool = true
    while (_dw_80899 || h264bsdMoreRbspData(pStrmData_32)) {
        _dw_80899 = false
        payloadType = uint(uint(0))
        payloadType
        while (tmp_58 == uint(255)) {
            payloadType = uint(payloadType + uint(255))
            payloadType
        }
        if (tmp_58 == 0xffffffff) {
            return uint(1)
        }
        payloadType = uint(payloadType + tmp_58)
        payloadType
        payloadSize = uint(uint(0))
        payloadSize
        while (tmp_58 == uint(255)) {
            payloadSize = uint(payloadSize + uint(255))
            payloadSize
        }
        if (tmp_58 == 0xffffffff) {
            return uint(1)
        }
        payloadSize = uint(payloadSize + tmp_58)
        payloadSize
        pSeiMessage.payloadType = uint(payloadType)
        pSeiMessage.payloadType
        if (payloadType == uint(0) || payloadType == uint(1) || payloadType == uint(2)) {
            status_2 = uint(DecodePanScanRectangle(pStrmData_32, unsafe(addr(pSeiMessage.panScanRect))))
            status_2
        } elif (payloadType == uint(3)) {
            status_2 = uint(DecodeFillerPayload(pStrmData_32, payloadSize))
            status_2
        } elif (payloadType == uint(4)) {
            status_2 = uint(DecodeUserDataRegisteredITuTT35(pStrmData_32, unsafe(addr(pSeiMessage.userDataRegisteredItuTT35)), payloadSize))
            status_2
        } elif (payloadType == uint(5)) {
            status_2 = uint(DecodeUserDataUnregistered(pStrmData_32, unsafe(addr(pSeiMessage.userDataUnregistered)), payloadSize))
            status_2
        } elif (payloadType == uint(6)) {
            status_2 = uint(DecodeRecoveryPoint(pStrmData_32, unsafe(addr(pSeiMessage.recoveryPoint))))
            status_2
        } elif (payloadType == uint(7)) {
            status_2 = uint(DecodeDecRefPicMarkingRepetition(pStrmData_32, unsafe(addr(pSeiMessage.decRefPicMarkingRepetition)), pSeqParamSet_7.numRefFrames))
            status_2
        } elif (payloadType == uint(8) || payloadType == uint(9)) {
            status_2 = uint(DecodeSceneInfo(pStrmData_32, unsafe(addr(pSeiMessage.sceneInfo))))
            status_2
        } elif (payloadType == uint(10)) {
            status_2 = uint(DecodeSubSeqInfo(pStrmData_32, unsafe(addr(pSeiMessage.subSeqInfo))))
            status_2
        } elif (payloadType == uint(11)) {
            status_2 = uint(DecodeSubSeqLayerCharacteristics(pStrmData_32, unsafe(addr(pSeiMessage.subSeqLayerCharacteristics))))
            status_2
        } elif (payloadType == uint(12)) {
            status_2 = uint(DecodeSubSeqCharacteristics(pStrmData_32, unsafe(addr(pSeiMessage.subSeqCharacteristics))))
            status_2
        } elif (payloadType == uint(13)) {
            status_2 = uint(DecodeFullFrameFreeze(pStrmData_32, unsafe(addr(pSeiMessage.fullFrameFreeze))))
            status_2
        } elif (payloadType == uint(14)) {
            status_2 = uint(uint(0))
            status_2
        } elif (payloadType == uint(15)) {
            status_2 = uint(DecodeFullFrameSnapshot(pStrmData_32, unsafe(addr(pSeiMessage.fullFrameSnapshot))))
            status_2
        } elif (payloadType == uint(16)) {
            status_2 = uint(DecodeProgressiveRefinementSegmentStart(pStrmData_32, unsafe(addr(pSeiMessage.progressiveRefinementSegmentStart))))
            status_2
        } elif (payloadType == uint(17)) {
            status_2 = uint(DecodeProgressiveRefinementSegmentEnd(pStrmData_32, unsafe(addr(pSeiMessage.progressiveRefinementSegmentEnd))))
            status_2
        } elif (payloadType == uint(18)) {
            status_2 = uint(DecodeReservedSeiMessage(pStrmData_32, unsafe(addr(pSeiMessage.reservedSeiMessage)), payloadSize))
            status_2
        }
        if (status_2 != uint(0)) {
            return status_2
        }
        while (h264bsdIsByteAligned(pStrmData_32) == 0) {
            if (h264bsdGetBits(pStrmData_32, uint(1)) != uint(1)) {
                return uint(1)
            }
            while (h264bsdIsByteAligned(pStrmData_32) == 0) {
                if (h264bsdGetBits(pStrmData_32, uint(1)) != uint(0)) {
                    return uint(1)
                }
            }
        }
    }
    return h264bsdRbspTrailingBits(pStrmData_32)
}
[export]
def DecodeReservedSeiMessage(var pStrmData_33 : strmData_t?; var pReservedSeiMessage : seiReservedSeiMessage_t?; var payloadSize_0 : uint) : uint {
    var i_77 : uint
    var tmp_59 : uint
    pReservedSeiMessage.reservedSeiMessagePayloadByte = unsafe(unsafe(reinterpret<uint8?>(malloc(uint64(payloadSize_0) * 4))))
    pReservedSeiMessage.reservedSeiMessagePayloadByte
    if (pReservedSeiMessage.reservedSeiMessagePayloadByte == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return uint(65535)
    }
    pReservedSeiMessage.numPayloadBytes = uint(payloadSize_0)
    pReservedSeiMessage.numPayloadBytes
    i_77 = uint(uint(0))
    i_77
    while (i_77 < payloadSize_0) {
        tmp_59 = uint(h264bsdGetBits(pStrmData_33, uint(8)))
        tmp_59
        if (tmp_59 == 0xffffffff) {
            return uint(1)
        }
        unsafe(pReservedSeiMessage.reservedSeiMessagePayloadByte[i_77]) = uint8(uint8(tmp_59))
        unsafe(pReservedSeiMessage.reservedSeiMessagePayloadByte[i_77])
        i_77 = i_77 + 1
    }
    return uint(0)
}
[export]
def DecodeMotionConstrainedSliceGroupSet(var pStrmData_34 : strmData_t?; var pMotionConstrainedSliceGroupSet : seiMotionConstrainedSliceGroupSet_t?; var numSliceGroups_3 : uint) : uint {
    var tmp_60 : uint
    var i_78 : uint
    tmp_60 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_34, unsafe(addr(pMotionConstrainedSliceGroupSet.numSliceGroupsInSet))))
    tmp_60
    if (tmp_60 != uint(0)) {
        return tmp_60
    }
    pMotionConstrainedSliceGroupSet.numSliceGroupsInSet = pMotionConstrainedSliceGroupSet.numSliceGroupsInSet + 1
    pMotionConstrainedSliceGroupSet.numSliceGroupsInSet
    if (pMotionConstrainedSliceGroupSet.numSliceGroupsInSet > numSliceGroups_3) {
        return uint(1)
    }
    i_78 = uint(uint(0))
    i_78
    while (i_78 < pMotionConstrainedSliceGroupSet.numSliceGroupsInSet) {
        tmp_60 = uint(h264bsdGetBits(pStrmData_34, unsafe(unsafe(addr(ceilLog2NumSliceGroups[0]))[numSliceGroups_3])))
        tmp_60
        if (tmp_60 == 0xffffffff) {
            return uint(1)
        }
        unsafe(unsafe(addr(pMotionConstrainedSliceGroupSet.sliceGroupId[0]))[i_78]) = uint(tmp_60)
        unsafe(unsafe(addr(pMotionConstrainedSliceGroupSet.sliceGroupId[0]))[i_78])
        if (unsafe(unsafe(addr(pMotionConstrainedSliceGroupSet.sliceGroupId[0]))[i_78]) > pMotionConstrainedSliceGroupSet.numSliceGroupsInSet - uint(1)) {
            return uint(1)
        }
        i_78 = i_78 + 1
    }
    tmp_60 = uint(h264bsdGetBits(pStrmData_34, uint(1)))
    tmp_60
    if (tmp_60 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh251_h264bsd : int = 0
    if (tmp_60 == uint(1)) {
        c2da_fresh251_h264bsd = 1
    } else {
        c2da_fresh251_h264bsd = 0
    }
    pMotionConstrainedSliceGroupSet.exactSampleValueMatchFlag = uint(uint(c2da_fresh251_h264bsd))
    pMotionConstrainedSliceGroupSet.exactSampleValueMatchFlag
    tmp_60 = uint(h264bsdGetBits(pStrmData_34, uint(1)))
    tmp_60
    if (tmp_60 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh252_h264bsd : int = 0
    if (tmp_60 == uint(1)) {
        c2da_fresh252_h264bsd = 1
    } else {
        c2da_fresh252_h264bsd = 0
    }
    pMotionConstrainedSliceGroupSet.panScanRectFlag = uint(uint(c2da_fresh252_h264bsd))
    pMotionConstrainedSliceGroupSet.panScanRectFlag
    if (pMotionConstrainedSliceGroupSet.panScanRectFlag != 0x0) {
        tmp_60 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_34, unsafe(addr(pMotionConstrainedSliceGroupSet.panScanRectId))))
        tmp_60
        if (tmp_60 != uint(0)) {
            return tmp_60
        }
    }
    return uint(0)
}
var ceilLog2NumSliceGroups : array<uint> const = [uint(0), uint(1), uint(1), uint(2), uint(2), uint(3), uint(3), uint(3), uint(3)]

[export]
def DecodeProgressiveRefinementSegmentEnd(var pStrmData_35 : strmData_t?; var pProgressiveRefinementSegmentEnd : seiProgressiveRefinementSegmentEnd_t?) : uint {
    var tmp_61 : uint
    tmp_61 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_35, unsafe(addr(pProgressiveRefinementSegmentEnd.progressiveRefinementId))))
    tmp_61
    if (tmp_61 != uint(0)) {
        return tmp_61
    }
    return uint(0)
}
[export]
def DecodeProgressiveRefinementSegmentStart(var pStrmData_36 : strmData_t?; var pProgressiveRefinementSegmentStart : seiProgressiveRefinementSegmentStart_t?) : uint {
    var tmp_62 : uint
    tmp_62 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_36, unsafe(addr(pProgressiveRefinementSegmentStart.progressiveRefinementId))))
    tmp_62
    if (tmp_62 != uint(0)) {
        return tmp_62
    }
    tmp_62 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_36, unsafe(addr(pProgressiveRefinementSegmentStart.numRefinementSteps))))
    tmp_62
    if (tmp_62 != uint(0)) {
        return tmp_62
    }
    pProgressiveRefinementSegmentStart.numRefinementSteps = pProgressiveRefinementSegmentStart.numRefinementSteps + 1
    pProgressiveRefinementSegmentStart.numRefinementSteps
    return uint(0)
}
[export]
def DecodeFullFrameSnapshot(var pStrmData_37 : strmData_t?; var pFullFrameSnapshot : seiFullFrameSnapshot_t?) : uint {
    var tmp_63 : uint
    tmp_63 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_37, unsafe(addr(pFullFrameSnapshot.snapShotId))))
    tmp_63
    if (tmp_63 != uint(0)) {
        return tmp_63
    }
    return uint(0)
}
[export]
def DecodeFullFrameFreeze(var pStrmData_38 : strmData_t?; var pFullFrameFreeze : seiFullFrameFreeze_t?) : uint {
    var tmp_64 : uint
    tmp_64 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_38, unsafe(addr(pFullFrameFreeze.fullFrameFreezeRepetitionPeriod))))
    tmp_64
    if (tmp_64 != uint(0)) {
        return tmp_64
    }
    if (pFullFrameFreeze.fullFrameFreezeRepetitionPeriod > uint(16384)) {
        return uint(1)
    }
    return uint(0)
}
[export]
def DecodeSubSeqCharacteristics(var pStrmData_39 : strmData_t?; var pSubSeqCharacteristics : seiSubSeqCharacteristics_t?) : uint {
    var tmp_65 : uint
    var i_79 : uint
    tmp_65 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_39, unsafe(addr(pSubSeqCharacteristics.subSeqLayerNum))))
    tmp_65
    if (tmp_65 != uint(0)) {
        return tmp_65
    }
    if (pSubSeqCharacteristics.subSeqLayerNum > uint(256 - 1)) {
        return uint(1)
    }
    tmp_65 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_39, unsafe(addr(pSubSeqCharacteristics.subSeqId))))
    tmp_65
    if (tmp_65 != uint(0)) {
        return tmp_65
    }
    if (pSubSeqCharacteristics.subSeqId > uint(65535)) {
        return uint(1)
    }
    tmp_65 = uint(h264bsdGetBits(pStrmData_39, uint(1)))
    tmp_65
    if (tmp_65 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh253_h264bsd : int = 0
    if (tmp_65 == uint(1)) {
        c2da_fresh253_h264bsd = 1
    } else {
        c2da_fresh253_h264bsd = 0
    }
    pSubSeqCharacteristics.durationFlag = uint(uint(c2da_fresh253_h264bsd))
    pSubSeqCharacteristics.durationFlag
    if (pSubSeqCharacteristics.durationFlag != 0x0) {
        pSubSeqCharacteristics.subSeqDuration = uint(h264bsdShowBits32(pStrmData_39))
        pSubSeqCharacteristics.subSeqDuration
        if (h264bsdFlushBits(pStrmData_39, uint(32)) == 0xffffffff) {
            return uint(1)
        }
    }
    tmp_65 = uint(h264bsdGetBits(pStrmData_39, uint(1)))
    tmp_65
    if (tmp_65 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh254_h264bsd : int = 0
    if (tmp_65 == uint(1)) {
        c2da_fresh254_h264bsd = 1
    } else {
        c2da_fresh254_h264bsd = 0
    }
    pSubSeqCharacteristics.averageRateFlag = uint(uint(c2da_fresh254_h264bsd))
    pSubSeqCharacteristics.averageRateFlag
    if (pSubSeqCharacteristics.averageRateFlag != 0x0) {
        tmp_65 = uint(h264bsdGetBits(pStrmData_39, uint(1)))
        tmp_65
        if (tmp_65 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh255_h264bsd : int = 0
        if (tmp_65 == uint(1)) {
            c2da_fresh255_h264bsd = 1
        } else {
            c2da_fresh255_h264bsd = 0
        }
        pSubSeqCharacteristics.accurateStatisticsFlag = uint(uint(c2da_fresh255_h264bsd))
        pSubSeqCharacteristics.accurateStatisticsFlag
        tmp_65 = uint(h264bsdGetBits(pStrmData_39, uint(16)))
        tmp_65
        if (tmp_65 == 0xffffffff) {
            return uint(1)
        }
        pSubSeqCharacteristics.averageBitRate = uint(tmp_65)
        pSubSeqCharacteristics.averageBitRate
        tmp_65 = uint(h264bsdGetBits(pStrmData_39, uint(16)))
        tmp_65
        if (tmp_65 == 0xffffffff) {
            return uint(1)
        }
        pSubSeqCharacteristics.averageFrameRate = uint(tmp_65)
        pSubSeqCharacteristics.averageFrameRate
    }
    tmp_65 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_39, unsafe(addr(pSubSeqCharacteristics.numReferencedSubseqs))))
    tmp_65
    if (tmp_65 != uint(0)) {
        return tmp_65
    }
    if (pSubSeqCharacteristics.numReferencedSubseqs > uint(256 - 1)) {
        return uint(1)
    }
    i_79 = uint(uint(0))
    i_79
    while (i_79 < pSubSeqCharacteristics.numReferencedSubseqs) {
        tmp_65 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_39, unsafe(addr(unsafe(unsafe(addr(pSubSeqCharacteristics.refSubSeqLayerNum[0]))[i_79])))))
        tmp_65
        if (tmp_65 != uint(0)) {
            return tmp_65
        }
        tmp_65 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_39, unsafe(addr(unsafe(unsafe(addr(pSubSeqCharacteristics.refSubSeqId[0]))[i_79])))))
        tmp_65
        if (tmp_65 != uint(0)) {
            return tmp_65
        }
        tmp_65 = uint(h264bsdGetBits(pStrmData_39, uint(1)))
        tmp_65
        if (tmp_65 == 0xffffffff) {
            return uint(1)
        }
        unsafe(unsafe(addr(pSubSeqCharacteristics.refSubSeqDirection[0]))[i_79]) = uint(tmp_65)
        unsafe(unsafe(addr(pSubSeqCharacteristics.refSubSeqDirection[0]))[i_79])
        i_79 = i_79 + 1
    }
    return uint(0)
}
[export]
def DecodeSubSeqLayerCharacteristics(var pStrmData_40 : strmData_t?; var pSubSeqLayerCharacteristics : seiSubSeqLayerCharacteristics_t?) : uint {
    var tmp_66 : uint
    var i_80 : uint
    tmp_66 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_40, unsafe(addr(pSubSeqLayerCharacteristics.numSubSeqLayers))))
    tmp_66
    if (tmp_66 != uint(0)) {
        return tmp_66
    }
    pSubSeqLayerCharacteristics.numSubSeqLayers = pSubSeqLayerCharacteristics.numSubSeqLayers + 1
    pSubSeqLayerCharacteristics.numSubSeqLayers
    if (pSubSeqLayerCharacteristics.numSubSeqLayers > uint(256)) {
        return uint(1)
    }
    i_80 = uint(uint(0))
    i_80
    while (i_80 < pSubSeqLayerCharacteristics.numSubSeqLayers) {
        tmp_66 = uint(h264bsdGetBits(pStrmData_40, uint(1)))
        tmp_66
        if (tmp_66 == 0xffffffff) {
            return uint(1)
        }
        var c2da_fresh256_h264bsd : int = 0
        if (tmp_66 == uint(1)) {
            c2da_fresh256_h264bsd = 1
        } else {
            c2da_fresh256_h264bsd = 0
        }
        unsafe(unsafe(addr(pSubSeqLayerCharacteristics.accurateStatisticsFlag[0]))[i_80]) = uint(uint(c2da_fresh256_h264bsd))
        unsafe(unsafe(addr(pSubSeqLayerCharacteristics.accurateStatisticsFlag[0]))[i_80])
        tmp_66 = uint(h264bsdGetBits(pStrmData_40, uint(16)))
        tmp_66
        if (tmp_66 == 0xffffffff) {
            return uint(1)
        }
        unsafe(unsafe(addr(pSubSeqLayerCharacteristics.averageBitRate[0]))[i_80]) = uint(tmp_66)
        unsafe(unsafe(addr(pSubSeqLayerCharacteristics.averageBitRate[0]))[i_80])
        tmp_66 = uint(h264bsdGetBits(pStrmData_40, uint(16)))
        tmp_66
        if (tmp_66 == 0xffffffff) {
            return uint(1)
        }
        unsafe(unsafe(addr(pSubSeqLayerCharacteristics.averageFrameRate[0]))[i_80]) = uint(tmp_66)
        unsafe(unsafe(addr(pSubSeqLayerCharacteristics.averageFrameRate[0]))[i_80])
        i_80 = i_80 + 1
    }
    return uint(0)
}
[export]
def DecodeSubSeqInfo(var pStrmData_41 : strmData_t?; var pSubSeqInfo : seiSubSeqInfo_t?) : uint {
    var tmp_67 : uint
    tmp_67 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_41, unsafe(addr(pSubSeqInfo.subSeqLayerNum))))
    tmp_67
    if (tmp_67 != uint(0)) {
        return tmp_67
    }
    if (pSubSeqInfo.subSeqLayerNum > uint(255)) {
        return uint(1)
    }
    tmp_67 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_41, unsafe(addr(pSubSeqInfo.subSeqId))))
    tmp_67
    if (tmp_67 != uint(0)) {
        return tmp_67
    }
    if (pSubSeqInfo.subSeqId > uint(65535)) {
        return uint(1)
    }
    tmp_67 = uint(h264bsdGetBits(pStrmData_41, uint(1)))
    tmp_67
    if (tmp_67 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh257_h264bsd : int = 0
    if (tmp_67 == uint(1)) {
        c2da_fresh257_h264bsd = 1
    } else {
        c2da_fresh257_h264bsd = 0
    }
    pSubSeqInfo.firstRefPicFlag = uint(uint(c2da_fresh257_h264bsd))
    pSubSeqInfo.firstRefPicFlag
    tmp_67 = uint(h264bsdGetBits(pStrmData_41, uint(1)))
    tmp_67
    if (tmp_67 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh258_h264bsd : int = 0
    if (tmp_67 == uint(1)) {
        c2da_fresh258_h264bsd = 1
    } else {
        c2da_fresh258_h264bsd = 0
    }
    pSubSeqInfo.leadingNonRefPicFlag = uint(uint(c2da_fresh258_h264bsd))
    pSubSeqInfo.leadingNonRefPicFlag
    tmp_67 = uint(h264bsdGetBits(pStrmData_41, uint(1)))
    tmp_67
    if (tmp_67 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh259_h264bsd : int = 0
    if (tmp_67 == uint(1)) {
        c2da_fresh259_h264bsd = 1
    } else {
        c2da_fresh259_h264bsd = 0
    }
    pSubSeqInfo.lastPicFlag = uint(uint(c2da_fresh259_h264bsd))
    pSubSeqInfo.lastPicFlag
    tmp_67 = uint(h264bsdGetBits(pStrmData_41, uint(1)))
    tmp_67
    if (tmp_67 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh260_h264bsd : int = 0
    if (tmp_67 == uint(1)) {
        c2da_fresh260_h264bsd = 1
    } else {
        c2da_fresh260_h264bsd = 0
    }
    pSubSeqInfo.subSeqFrameNumFlag = uint(uint(c2da_fresh260_h264bsd))
    pSubSeqInfo.subSeqFrameNumFlag
    if (pSubSeqInfo.subSeqFrameNumFlag != 0x0) {
        tmp_67 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_41, unsafe(addr(pSubSeqInfo.subSeqFrameNum))))
        tmp_67
        if (tmp_67 != uint(0)) {
            return tmp_67
        }
    }
    return uint(0)
}
[export]
def DecodeSceneInfo(var pStrmData_42 : strmData_t?; var pSceneInfo : seiSceneInfo_t?) : uint {
    var tmp_68 : uint
    tmp_68 = uint(h264bsdGetBits(pStrmData_42, uint(1)))
    tmp_68
    if (tmp_68 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh261_h264bsd : int = 0
    if (tmp_68 == uint(1)) {
        c2da_fresh261_h264bsd = 1
    } else {
        c2da_fresh261_h264bsd = 0
    }
    pSceneInfo.sceneInfoPresentFlag = uint(uint(c2da_fresh261_h264bsd))
    pSceneInfo.sceneInfoPresentFlag
    if (pSceneInfo.sceneInfoPresentFlag != 0x0) {
        tmp_68 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_42, unsafe(addr(pSceneInfo.sceneId))))
        tmp_68
        if (tmp_68 != uint(0)) {
            return tmp_68
        }
        tmp_68 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_42, unsafe(addr(pSceneInfo.sceneTransitionType))))
        tmp_68
        if (tmp_68 != uint(0)) {
            return tmp_68
        }
        if (pSceneInfo.sceneTransitionType > uint(6)) {
            return uint(1)
        }
        if (pSceneInfo.sceneTransitionType != 0x0) {
            tmp_68 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_42, unsafe(addr(pSceneInfo.secondSceneId))))
            tmp_68
            if (tmp_68 != uint(0)) {
                return tmp_68
            }
        }
    }
    return uint(0)
}
[export]
def DecodeSparePic(var pStrmData_43 : strmData_t?; var pSparePic : seiSparePic_t?; var picSizeInMapUnits : uint) : uint {
    var tmp_69 : uint
    var i_81 : uint
    var j_14 : uint
    var mapUnitCnt : uint
    tmp_69 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_43, unsafe(addr(pSparePic.targetFrameNum))))
    tmp_69
    if (tmp_69 != uint(0)) {
        return tmp_69
    }
    tmp_69 = uint(h264bsdGetBits(pStrmData_43, uint(1)))
    tmp_69
    if (tmp_69 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh262_h264bsd : int = 0
    if (tmp_69 == uint(1)) {
        c2da_fresh262_h264bsd = 1
    } else {
        c2da_fresh262_h264bsd = 0
    }
    pSparePic.spareFieldFlag = uint(uint(c2da_fresh262_h264bsd))
    pSparePic.spareFieldFlag
    if (pSparePic.spareFieldFlag != 0x0) {
        return uint(1)
    }
    tmp_69 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_43, unsafe(addr(pSparePic.numSparePics))))
    tmp_69
    if (tmp_69 != uint(0)) {
        return tmp_69
    }
    pSparePic.numSparePics = pSparePic.numSparePics + 1
    pSparePic.numSparePics
    if (pSparePic.numSparePics > uint(16)) {
        return uint(1)
    }
    i_81 = uint(uint(0))
    i_81
    while (i_81 < pSparePic.numSparePics) {
        tmp_69 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_43, unsafe(addr(unsafe(unsafe(addr(pSparePic.deltaSpareFrameNum[0]))[i_81])))))
        tmp_69
        if (tmp_69 != uint(0)) {
            return tmp_69
        }
        tmp_69 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_43, unsafe(addr(unsafe(unsafe(addr(pSparePic.spareAreaIdc[0]))[i_81])))))
        tmp_69
        if (tmp_69 != uint(0)) {
            return tmp_69
        }
        if (unsafe(unsafe(addr(pSparePic.spareAreaIdc[0]))[i_81]) > uint(2)) {
            return uint(1)
        }
        if (unsafe(unsafe(addr(pSparePic.spareAreaIdc[0]))[i_81]) == uint(1)) {
            unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81]) = unsafe(unsafe(reinterpret<uint?>(malloc(uint64(picSizeInMapUnits) * 4))))
            unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81])
            if (unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81]) == unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
                return uint(65535)
            }
            unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81]) = null
            unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81])
            j_14 = uint(uint(0))
            j_14
            while (j_14 < picSizeInMapUnits) {
                tmp_69 = uint(h264bsdGetBits(pStrmData_43, uint(1)))
                tmp_69
                if (tmp_69 == 0xffffffff) {
                    return uint(1)
                }
                var c2da_fresh263_h264bsd : int = 0
                if (tmp_69 == uint(1)) {
                    c2da_fresh263_h264bsd = 1
                } else {
                    c2da_fresh263_h264bsd = 0
                }
                unsafe(unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81])[j_14]) = uint(uint(c2da_fresh263_h264bsd))
                unsafe(unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81])[j_14])
                j_14 = j_14 + 1
            }
        } else {
            if (unsafe(unsafe(addr(pSparePic.spareAreaIdc[0]))[i_81]) == uint(2)) {
                unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81]) = unsafe(unsafe(reinterpret<uint?>(malloc(uint64(picSizeInMapUnits) * 4))))
                unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81])
                if (unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81]) == unsafe(unsafe(reinterpret<uint?>(uint64(0))))) {
                    return uint(65535)
                }
                unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81]) = null
                unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81])
                mapUnitCnt = uint(uint(0))
                mapUnitCnt
                while (mapUnitCnt < picSizeInMapUnits) {
                    tmp_69 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_43, unsafe(addr(unsafe(unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81])[j_14])))))
                    tmp_69
                    if (tmp_69 != uint(0)) {
                        return tmp_69
                    }
                    mapUnitCnt = uint(mapUnitCnt + unsafe(unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81])[j_14]) + uint(1))
                    mapUnitCnt
                    j_14 = j_14 + 1
                }
            }
        }
        i_81 = i_81 + 1
    }
    i_81 = uint(pSparePic.numSparePics)
    i_81
    while (i_81 < uint(16)) {
        unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81]) = null
        unsafe(unsafe(addr(pSparePic.spareUnitFlag[0]))[i_81])
        unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81]) = null
        unsafe(unsafe(addr(pSparePic.zeroRunLength[0]))[i_81])
        i_81 = i_81 + 1
    }
    return uint(0)
}
[export]
def DecodeDecRefPicMarkingRepetition(var pStrmData_44 : strmData_t?; var pDecRefPicMarkingRepetition : seiDecRefPicMarkingRepetition_t?; var numRefFrames_0 : uint) : uint {
    var tmp_70 : uint
    tmp_70 = uint(h264bsdGetBits(pStrmData_44, uint(1)))
    tmp_70
    if (tmp_70 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh264_h264bsd : int = 0
    if (tmp_70 == uint(1)) {
        c2da_fresh264_h264bsd = 1
    } else {
        c2da_fresh264_h264bsd = 0
    }
    pDecRefPicMarkingRepetition.originalIdrFlag = uint(uint(c2da_fresh264_h264bsd))
    pDecRefPicMarkingRepetition.originalIdrFlag
    tmp_70 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_44, unsafe(addr(pDecRefPicMarkingRepetition.originalFrameNum))))
    tmp_70
    if (tmp_70 != uint(0)) {
        return tmp_70
    }
    return uint(1)
    return tmp_70
}
[export]
def DecodeRecoveryPoint(var pStrmData_45 : strmData_t?; var pRecoveryPoint : seiRecoveryPoint_t?) : uint {
    var tmp_71 : uint
    tmp_71 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_45, unsafe(addr(pRecoveryPoint.recoveryFrameCnt))))
    tmp_71
    if (tmp_71 != uint(0)) {
        return tmp_71
    }
    tmp_71 = uint(h264bsdGetBits(pStrmData_45, uint(1)))
    tmp_71
    if (tmp_71 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh265_h264bsd : int = 0
    if (tmp_71 == uint(1)) {
        c2da_fresh265_h264bsd = 1
    } else {
        c2da_fresh265_h264bsd = 0
    }
    pRecoveryPoint.exactMatchFlag = uint(uint(c2da_fresh265_h264bsd))
    pRecoveryPoint.exactMatchFlag
    tmp_71 = uint(h264bsdGetBits(pStrmData_45, uint(1)))
    tmp_71
    if (tmp_71 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh266_h264bsd : int = 0
    if (tmp_71 == uint(1)) {
        c2da_fresh266_h264bsd = 1
    } else {
        c2da_fresh266_h264bsd = 0
    }
    pRecoveryPoint.brokenLinkFlag = uint(uint(c2da_fresh266_h264bsd))
    pRecoveryPoint.brokenLinkFlag
    tmp_71 = uint(h264bsdGetBits(pStrmData_45, uint(2)))
    tmp_71
    if (tmp_71 == 0xffffffff) {
        return uint(1)
    }
    if (tmp_71 > uint(2)) {
        return uint(1)
    }
    pRecoveryPoint.changingSliceGroupIdc = uint(tmp_71)
    pRecoveryPoint.changingSliceGroupIdc
    return uint(0)
}
[export]
def DecodeUserDataUnregistered(var pStrmData_46 : strmData_t?; var pUserDataUnregistered : seiUserDataUnregistered_t?; var payloadSize_1 : uint) : uint {
    var i_82 : uint
    var tmp_72 : uint
    i_82 = uint(uint(0))
    i_82
    while (i_82 < uint(4)) {
        unsafe(unsafe(addr(pUserDataUnregistered.uuidIsoIec11578[0]))[i_82]) = uint(h264bsdShowBits32(pStrmData_46))
        unsafe(unsafe(addr(pUserDataUnregistered.uuidIsoIec11578[0]))[i_82])
        if (h264bsdFlushBits(pStrmData_46, uint(32)) == 0xffffffff) {
            return uint(1)
        }
        i_82 = i_82 + 1
    }
    pUserDataUnregistered.userDataPayloadByte = unsafe(unsafe(reinterpret<uint8?>(malloc(uint64(payloadSize_1 - uint(16)) * 4))))
    pUserDataUnregistered.userDataPayloadByte
    if (pUserDataUnregistered.userDataPayloadByte == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return uint(65535)
    }
    pUserDataUnregistered.numPayloadBytes = uint(payloadSize_1 - uint(16))
    pUserDataUnregistered.numPayloadBytes
    i_82 = uint(uint(0))
    i_82
    while (i_82 < payloadSize_1 - uint(16)) {
        tmp_72 = uint(h264bsdGetBits(pStrmData_46, uint(8)))
        tmp_72
        if (tmp_72 == 0xffffffff) {
            return uint(1)
        }
        unsafe(pUserDataUnregistered.userDataPayloadByte[i_82]) = uint8(uint8(tmp_72))
        unsafe(pUserDataUnregistered.userDataPayloadByte[i_82])
        i_82 = i_82 + 1
    }
    return uint(0)
}
[export]
def DecodeUserDataRegisteredITuTT35(var pStrmData_47 : strmData_t?; var pUserDataRegisteredItuTT35 : seiUserDataRegisteredItuTT35_t?; var payloadSize_2 : uint) : uint {
    var tmp_73 : uint
    var i_83 : uint
    var j_15 : uint
    tmp_73 = uint(h264bsdGetBits(pStrmData_47, uint(8)))
    tmp_73
    if (tmp_73 == 0xffffffff) {
        return uint(1)
    }
    pUserDataRegisteredItuTT35.ituTT35CountryCode = uint(tmp_73)
    pUserDataRegisteredItuTT35.ituTT35CountryCode
    if (pUserDataRegisteredItuTT35.ituTT35CountryCode != uint(255)) {
        i_83 = uint(uint(1))
        i_83
    } else {
        tmp_73 = uint(h264bsdGetBits(pStrmData_47, uint(8)))
        tmp_73
        if (tmp_73 == 0xffffffff) {
            return uint(1)
        }
        pUserDataRegisteredItuTT35.ituTT35CountryCodeExtensionByte = uint(tmp_73)
        pUserDataRegisteredItuTT35.ituTT35CountryCodeExtensionByte
        i_83 = uint(uint(2))
        i_83
    }
    pUserDataRegisteredItuTT35.ituTT35PayloadByte = unsafe(unsafe(reinterpret<uint8?>(malloc(uint64(payloadSize_2 - i_83) * 4))))
    pUserDataRegisteredItuTT35.ituTT35PayloadByte
    pUserDataRegisteredItuTT35.numPayloadBytes = uint(payloadSize_2 - i_83)
    pUserDataRegisteredItuTT35.numPayloadBytes
    if (pUserDataRegisteredItuTT35.ituTT35PayloadByte == unsafe(unsafe(reinterpret<uint8?>(uint64(0))))) {
        return uint(65535)
    }
    j_15 = uint(uint(0))
    j_15
    var _dw_83703 : bool = true
    while (_dw_83703 || i_83 < payloadSize_2) {
        _dw_83703 = false
        tmp_73 = uint(h264bsdGetBits(pStrmData_47, uint(8)))
        tmp_73
        if (tmp_73 == 0xffffffff) {
            return uint(1)
        }
        unsafe(pUserDataRegisteredItuTT35.ituTT35PayloadByte[j_15]) = uint8(uint8(tmp_73))
        unsafe(pUserDataRegisteredItuTT35.ituTT35PayloadByte[j_15])
        i_83 = i_83 + 1
        i_83
        j_15 = j_15 + 1
        j_15
    }
    return uint(0)
}
[export]
def DecodeFillerPayload(var pStrmData_48 : strmData_t?; var payloadSize_3 : uint) : uint {
    if (payloadSize_3 != 0x0) {
        if (h264bsdFlushBits(pStrmData_48, uint(8) * payloadSize_3) == 0xffffffff) {
            return uint(1)
        }
    }
    return uint(0)
}
[export]
def DecodePanScanRectangle(var pStrmData_49 : strmData_t?; var pPanScanRectangle : seiPanScanRect_t?) : uint {
    var tmp_74 : uint
    var i_84 : uint
    tmp_74 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_49, unsafe(addr(pPanScanRectangle.panScanRectId))))
    tmp_74
    if (tmp_74 != uint(0)) {
        return tmp_74
    }
    tmp_74 = uint(h264bsdGetBits(pStrmData_49, uint(1)))
    tmp_74
    if (tmp_74 == 0xffffffff) {
        return uint(1)
    }
    var c2da_fresh267_h264bsd : int = 0
    if (tmp_74 == uint(1)) {
        c2da_fresh267_h264bsd = 1
    } else {
        c2da_fresh267_h264bsd = 0
    }
    pPanScanRectangle.panScanRectCancelFlag = uint(uint(c2da_fresh267_h264bsd))
    pPanScanRectangle.panScanRectCancelFlag
    if (pPanScanRectangle.panScanRectCancelFlag == 0) {
        tmp_74 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_49, unsafe(addr(pPanScanRectangle.panScanCnt))))
        tmp_74
        if (tmp_74 != uint(0)) {
            return tmp_74
        }
        if (pPanScanRectangle.panScanCnt > uint(2)) {
            return uint(1)
        }
        pPanScanRectangle.panScanCnt = pPanScanRectangle.panScanCnt + 1
        pPanScanRectangle.panScanCnt
        i_84 = uint(uint(0))
        i_84
        while (i_84 < pPanScanRectangle.panScanCnt) {
            tmp_74 = uint(h264bsdDecodeExpGolombSigned(pStrmData_49, unsafe(addr(unsafe(unsafe(addr(pPanScanRectangle.panScanRectLeftOffset[0]))[i_84])))))
            tmp_74
            if (tmp_74 != uint(0)) {
                return tmp_74
            }
            tmp_74 = uint(h264bsdDecodeExpGolombSigned(pStrmData_49, unsafe(addr(unsafe(unsafe(addr(pPanScanRectangle.panScanRectRightOffset[0]))[i_84])))))
            tmp_74
            if (tmp_74 != uint(0)) {
                return tmp_74
            }
            tmp_74 = uint(h264bsdDecodeExpGolombSigned(pStrmData_49, unsafe(addr(unsafe(unsafe(addr(pPanScanRectangle.panScanRectTopOffset[0]))[i_84])))))
            tmp_74
            if (tmp_74 != uint(0)) {
                return tmp_74
            }
            tmp_74 = uint(h264bsdDecodeExpGolombSigned(pStrmData_49, unsafe(addr(unsafe(unsafe(addr(pPanScanRectangle.panScanRectBottomOffset[0]))[i_84])))))
            tmp_74
            if (tmp_74 != uint(0)) {
                return tmp_74
            }
            i_84 = i_84 + 1
        }
        tmp_74 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_49, unsafe(addr(pPanScanRectangle.panScanRectRepetitionPeriod))))
        tmp_74
        if (tmp_74 != uint(0)) {
            return tmp_74
        }
        if (pPanScanRectangle.panScanRectRepetitionPeriod > uint(16384)) {
            return uint(1)
        }
        if (pPanScanRectangle.panScanCnt > uint(1) && pPanScanRectangle.panScanRectRepetitionPeriod > uint(1)) {
            return uint(1)
        }
    }
    return uint(0)
}
[export]
def DecodePictureTiming(var pStrmData_50 : strmData_t?; var pPicTiming : seiPicTiming_t?; var cpbRemovalDelayLength : uint; var dpbOutputDelayLength : uint; var timeOffsetLength : uint; var cpbDpbDelaysPresentFlag : uint; var picStructPresentFlag : uint) : uint {
    var tmp_75 : uint
    var i_85 : uint
    var itmp_4 : int
    if (cpbDpbDelaysPresentFlag != 0x0) {
        tmp_75 = uint(h264bsdGetBits(pStrmData_50, cpbRemovalDelayLength))
        tmp_75
        if (tmp_75 == 0xffffffff) {
            return uint(1)
        }
        pPicTiming.cpbRemovalDelay = uint(tmp_75)
        pPicTiming.cpbRemovalDelay
        tmp_75 = uint(h264bsdGetBits(pStrmData_50, dpbOutputDelayLength))
        tmp_75
        if (tmp_75 == 0xffffffff) {
            return uint(1)
        }
        pPicTiming.dpbOutputDelay = uint(tmp_75)
        pPicTiming.dpbOutputDelay
    }
    if (picStructPresentFlag != 0x0) {
        tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(4)))
        tmp_75
        if (tmp_75 == 0xffffffff) {
            return uint(1)
        }
        if (tmp_75 > uint(8)) {
            return uint(1)
        }
        pPicTiming.picStruct = uint(tmp_75)
        pPicTiming.picStruct
        i_85 = uint(uint(0))
        i_85
        while (i_85 < unsafe(unsafe(addr(numClockTS[0]))[pPicTiming.picStruct])) {
            tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(1)))
            tmp_75
            if (tmp_75 == 0xffffffff) {
                return uint(1)
            }
            var c2da_fresh268_h264bsd : int = 0
            if (tmp_75 == uint(1)) {
                c2da_fresh268_h264bsd = 1
            } else {
                c2da_fresh268_h264bsd = 0
            }
            unsafe(unsafe(addr(pPicTiming.clockTimeStampFlag[0]))[i_85]) = uint(uint(c2da_fresh268_h264bsd))
            unsafe(unsafe(addr(pPicTiming.clockTimeStampFlag[0]))[i_85])
            if (unsafe(unsafe(addr(pPicTiming.clockTimeStampFlag[0]))[i_85]) != 0x0) {
                tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(2)))
                tmp_75
                if (tmp_75 == 0xffffffff) {
                    return uint(1)
                }
                unsafe(unsafe(addr(pPicTiming.ctType[0]))[i_85]) = uint(tmp_75)
                unsafe(unsafe(addr(pPicTiming.ctType[0]))[i_85])
                tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(1)))
                tmp_75
                if (tmp_75 == 0xffffffff) {
                    return uint(1)
                }
                var c2da_fresh269_h264bsd : int = 0
                if (tmp_75 == uint(1)) {
                    c2da_fresh269_h264bsd = 1
                } else {
                    c2da_fresh269_h264bsd = 0
                }
                unsafe(unsafe(addr(pPicTiming.nuitFieldBasedFlag[0]))[i_85]) = uint(uint(c2da_fresh269_h264bsd))
                unsafe(unsafe(addr(pPicTiming.nuitFieldBasedFlag[0]))[i_85])
                tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(5)))
                tmp_75
                if (tmp_75 == 0xffffffff) {
                    return uint(1)
                }
                if (tmp_75 > uint(6)) {
                    return uint(1)
                }
                unsafe(unsafe(addr(pPicTiming.countingType[0]))[i_85]) = uint(tmp_75)
                unsafe(unsafe(addr(pPicTiming.countingType[0]))[i_85])
                tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(1)))
                tmp_75
                if (tmp_75 == 0xffffffff) {
                    return uint(1)
                }
                var c2da_fresh270_h264bsd : int = 0
                if (tmp_75 == uint(1)) {
                    c2da_fresh270_h264bsd = 1
                } else {
                    c2da_fresh270_h264bsd = 0
                }
                unsafe(unsafe(addr(pPicTiming.fullTimeStampFlag[0]))[i_85]) = uint(uint(c2da_fresh270_h264bsd))
                unsafe(unsafe(addr(pPicTiming.fullTimeStampFlag[0]))[i_85])
                tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(1)))
                tmp_75
                if (tmp_75 == 0xffffffff) {
                    return uint(1)
                }
                var c2da_fresh271_h264bsd : int = 0
                if (tmp_75 == uint(1)) {
                    c2da_fresh271_h264bsd = 1
                } else {
                    c2da_fresh271_h264bsd = 0
                }
                unsafe(unsafe(addr(pPicTiming.discontinuityFlag[0]))[i_85]) = uint(uint(c2da_fresh271_h264bsd))
                unsafe(unsafe(addr(pPicTiming.discontinuityFlag[0]))[i_85])
                tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(1)))
                tmp_75
                if (tmp_75 == 0xffffffff) {
                    return uint(1)
                }
                var c2da_fresh272_h264bsd : int = 0
                if (tmp_75 == uint(1)) {
                    c2da_fresh272_h264bsd = 1
                } else {
                    c2da_fresh272_h264bsd = 0
                }
                unsafe(unsafe(addr(pPicTiming.cntDroppedFlag[0]))[i_85]) = uint(uint(c2da_fresh272_h264bsd))
                unsafe(unsafe(addr(pPicTiming.cntDroppedFlag[0]))[i_85])
                tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(8)))
                tmp_75
                if (tmp_75 == 0xffffffff) {
                    return uint(1)
                }
                unsafe(unsafe(addr(pPicTiming.nFrames[0]))[i_85]) = uint(tmp_75)
                unsafe(unsafe(addr(pPicTiming.nFrames[0]))[i_85])
                if (unsafe(unsafe(addr(pPicTiming.fullTimeStampFlag[0]))[i_85]) != 0x0) {
                    tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(6)))
                    tmp_75
                    if (tmp_75 == 0xffffffff) {
                        return uint(1)
                    }
                    if (tmp_75 > uint(59)) {
                        return uint(1)
                    }
                    unsafe(unsafe(addr(pPicTiming.secondsValue[0]))[i_85]) = uint(tmp_75)
                    unsafe(unsafe(addr(pPicTiming.secondsValue[0]))[i_85])
                    tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(6)))
                    tmp_75
                    if (tmp_75 == 0xffffffff) {
                        return uint(1)
                    }
                    if (tmp_75 > uint(59)) {
                        return uint(1)
                    }
                    unsafe(unsafe(addr(pPicTiming.minutesValue[0]))[i_85]) = uint(tmp_75)
                    unsafe(unsafe(addr(pPicTiming.minutesValue[0]))[i_85])
                    tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(5)))
                    tmp_75
                    if (tmp_75 == 0xffffffff) {
                        return uint(1)
                    }
                    if (tmp_75 > uint(23)) {
                        return uint(1)
                    }
                    unsafe(unsafe(addr(pPicTiming.hoursValue[0]))[i_85]) = uint(tmp_75)
                    unsafe(unsafe(addr(pPicTiming.hoursValue[0]))[i_85])
                } else {
                    tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(1)))
                    tmp_75
                    if (tmp_75 == 0xffffffff) {
                        return uint(1)
                    }
                    var c2da_fresh273_h264bsd : int = 0
                    if (tmp_75 == uint(1)) {
                        c2da_fresh273_h264bsd = 1
                    } else {
                        c2da_fresh273_h264bsd = 0
                    }
                    unsafe(unsafe(addr(pPicTiming.secondsFlag[0]))[i_85]) = uint(uint(c2da_fresh273_h264bsd))
                    unsafe(unsafe(addr(pPicTiming.secondsFlag[0]))[i_85])
                    if (unsafe(unsafe(addr(pPicTiming.secondsFlag[0]))[i_85]) != 0x0) {
                        tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(6)))
                        tmp_75
                        if (tmp_75 == 0xffffffff) {
                            return uint(1)
                        }
                        if (tmp_75 > uint(59)) {
                            return uint(1)
                        }
                        unsafe(unsafe(addr(pPicTiming.secondsValue[0]))[i_85]) = uint(tmp_75)
                        unsafe(unsafe(addr(pPicTiming.secondsValue[0]))[i_85])
                        tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(1)))
                        tmp_75
                        if (tmp_75 == 0xffffffff) {
                            return uint(1)
                        }
                        var c2da_fresh274_h264bsd : int = 0
                        if (tmp_75 == uint(1)) {
                            c2da_fresh274_h264bsd = 1
                        } else {
                            c2da_fresh274_h264bsd = 0
                        }
                        unsafe(unsafe(addr(pPicTiming.minutesFlag[0]))[i_85]) = uint(uint(c2da_fresh274_h264bsd))
                        unsafe(unsafe(addr(pPicTiming.minutesFlag[0]))[i_85])
                        if (unsafe(unsafe(addr(pPicTiming.minutesFlag[0]))[i_85]) != 0x0) {
                            tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(6)))
                            tmp_75
                            if (tmp_75 == 0xffffffff) {
                                return uint(1)
                            }
                            if (tmp_75 > uint(59)) {
                                return uint(1)
                            }
                            unsafe(unsafe(addr(pPicTiming.minutesValue[0]))[i_85]) = uint(tmp_75)
                            unsafe(unsafe(addr(pPicTiming.minutesValue[0]))[i_85])
                            tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(1)))
                            tmp_75
                            if (tmp_75 == 0xffffffff) {
                                return uint(1)
                            }
                            var c2da_fresh275_h264bsd : int = 0
                            if (tmp_75 == uint(1)) {
                                c2da_fresh275_h264bsd = 1
                            } else {
                                c2da_fresh275_h264bsd = 0
                            }
                            unsafe(unsafe(addr(pPicTiming.hoursFlag[0]))[i_85]) = uint(uint(c2da_fresh275_h264bsd))
                            unsafe(unsafe(addr(pPicTiming.hoursFlag[0]))[i_85])
                            if (unsafe(unsafe(addr(pPicTiming.hoursFlag[0]))[i_85]) != 0x0) {
                                tmp_75 = uint(h264bsdGetBits(pStrmData_50, uint(5)))
                                tmp_75
                                if (tmp_75 == 0xffffffff) {
                                    return uint(1)
                                }
                                if (tmp_75 > uint(23)) {
                                    return uint(1)
                                }
                                unsafe(unsafe(addr(pPicTiming.hoursValue[0]))[i_85]) = uint(tmp_75)
                                unsafe(unsafe(addr(pPicTiming.hoursValue[0]))[i_85])
                            }
                        }
                    }
                }
                if (timeOffsetLength != 0x0) {
                    tmp_75 = uint(h264bsdGetBits(pStrmData_50, timeOffsetLength))
                    tmp_75
                    if (tmp_75 == 0xffffffff) {
                        return uint(1)
                    }
                    itmp_4 = int(tmp_75)
                    itmp_4
                    itmp_4 = itmp_4 << uint(32) - timeOffsetLength
                    itmp_4
                    itmp_4 = itmp_4 >> uint(32) - timeOffsetLength
                    itmp_4
                    unsafe(unsafe(addr(pPicTiming.timeOffset[0]))[i_85]) = itmp_4
                    unsafe(unsafe(addr(pPicTiming.timeOffset[0]))[i_85])
                } else {
                    unsafe(unsafe(addr(pPicTiming.timeOffset[0]))[i_85]) = 0
                    unsafe(unsafe(addr(pPicTiming.timeOffset[0]))[i_85])
                }
            }
            i_85 = i_85 + 1
        }
    }
    return uint(0)
}
var numClockTS : array<uint> const = [uint(1), uint(1), uint(1), uint(2), uint(2), uint(3), uint(3), uint(2), uint(3)]

[export]
def DecodeBufferingPeriod(var pStrmData_51 : strmData_t?; var pBufferingPeriod : seiBufferingPeriod_t?; var cpbCnt : uint; var initialCpbRemovalDelayLength : uint; var nalHrdBpPresentFlag : uint; var vclHrdBpPresentFlag : uint) : uint {
    var tmp_76 : uint
    var i_86 : uint
    tmp_76 = uint(h264bsdDecodeExpGolombUnsigned(pStrmData_51, unsafe(addr(pBufferingPeriod.seqParameterSetId))))
    tmp_76
    if (tmp_76 != uint(0)) {
        return tmp_76
    }
    if (pBufferingPeriod.seqParameterSetId > uint(31)) {
        return uint(1)
    }
    if (nalHrdBpPresentFlag != 0x0) {
        i_86 = uint(uint(0))
        i_86
        while (i_86 < cpbCnt) {
            tmp_76 = uint(h264bsdGetBits(pStrmData_51, initialCpbRemovalDelayLength))
            tmp_76
            if (tmp_76 == 0xffffffff) {
                return uint(1)
            }
            if (tmp_76 == uint(0)) {
                return uint(1)
            }
            unsafe(unsafe(addr(pBufferingPeriod.initialCpbRemovalDelay[0]))[i_86]) = uint(tmp_76)
            unsafe(unsafe(addr(pBufferingPeriod.initialCpbRemovalDelay[0]))[i_86])
            tmp_76 = uint(h264bsdGetBits(pStrmData_51, initialCpbRemovalDelayLength))
            tmp_76
            if (tmp_76 == 0xffffffff) {
                return uint(1)
            }
            unsafe(unsafe(addr(pBufferingPeriod.initialCpbRemovalDelayOffset[0]))[i_86]) = uint(tmp_76)
            unsafe(unsafe(addr(pBufferingPeriod.initialCpbRemovalDelayOffset[0]))[i_86])
            i_86 = i_86 + 1
        }
    }
    if (vclHrdBpPresentFlag != 0x0) {
        i_86 = uint(uint(0))
        i_86
        while (i_86 < cpbCnt) {
            tmp_76 = uint(h264bsdGetBits(pStrmData_51, initialCpbRemovalDelayLength))
            tmp_76
            if (tmp_76 == 0xffffffff) {
                return uint(1)
            }
            unsafe(unsafe(addr(pBufferingPeriod.initialCpbRemovalDelay[0]))[i_86]) = uint(tmp_76)
            unsafe(unsafe(addr(pBufferingPeriod.initialCpbRemovalDelay[0]))[i_86])
            tmp_76 = uint(h264bsdGetBits(pStrmData_51, initialCpbRemovalDelayLength))
            tmp_76
            if (tmp_76 == 0xffffffff) {
                return uint(1)
            }
            unsafe(unsafe(addr(pBufferingPeriod.initialCpbRemovalDelayOffset[0]))[i_86]) = uint(tmp_76)
            unsafe(unsafe(addr(pBufferingPeriod.initialCpbRemovalDelayOffset[0]))[i_86])
            i_86 = i_86 + 1
        }
    }
    return uint(0)
}
var ASPECT_RATIO_EXTENDED_SAR : int = 255

var ASPECT_RATIO_160_99 : int = 13

var ASPECT_RATIO_64_33 : int = 12

var ASPECT_RATIO_15_11 : int = 11

var ASPECT_RATIO_18_11 : int = 10

var ASPECT_RATIO_80_33 : int = 9

var ASPECT_RATIO_32_11 : int = 8

var ASPECT_RATIO_20_11 : int = 7

var ASPECT_RATIO_24_11 : int = 6

var ASPECT_RATIO_40_33 : int = 5

var ASPECT_RATIO_16_11 : int = 4

var ASPECT_RATIO_10_11 : int = 3

var ASPECT_RATIO_12_11 : int = 2

var ASPECT_RATIO_1_1 : int = 1

var ASPECT_RATIO_UNSPECIFIED : int = 0

var INVALID_DPB_SIZE : int = 2147483647

var NAL_MAX_TYPE_VALUE : int = 31

var NAL_FILLER_DATA : int = 12

var NAL_END_OF_STREAM : int = 11

var NAL_END_OF_SEQUENCE : int = 10

var NAL_ACCESS_UNIT_DELIMITER : int = 9

var NAL_PIC_PARAM_SET : int = 8

var NAL_SEQ_PARAM_SET : int = 7

var NAL_SEI : int = 6

var NAL_CODED_SLICE_IDR : int = 5

var NAL_CODED_SLICE : int = 1

var I_SLICE : int = 2

var P_SLICE : int = 0

var NO_LONG_TERM_FRAME_INDICES : int = 65535

var LONG_TERM : int = 3

var SHORT_TERM : int = 2

var NON_EXISTING : int = 1

var UNUSED : int = 0

var I_PCM : int = 31

var I_16x16_3_2_1 : int = 30

var I_16x16_2_2_1 : int = 29

var I_16x16_1_2_1 : int = 28

var I_16x16_0_2_1 : int = 27

var I_16x16_3_1_1 : int = 26

var I_16x16_2_1_1 : int = 25

var I_16x16_1_1_1 : int = 24

var I_16x16_0_1_1 : int = 23

var I_16x16_3_0_1 : int = 22

var I_16x16_2_0_1 : int = 21

var I_16x16_1_0_1 : int = 20

var I_16x16_0_0_1 : int = 19

var I_16x16_3_2_0 : int = 18

var I_16x16_2_2_0 : int = 17

var I_16x16_1_2_0 : int = 16

var I_16x16_0_2_0 : int = 15

var I_16x16_3_1_0 : int = 14

var I_16x16_2_1_0 : int = 13

var I_16x16_1_1_0 : int = 12

var I_16x16_0_1_0 : int = 11

var I_16x16_3_0_0 : int = 10

var I_16x16_2_0_0 : int = 9

var I_16x16_1_0_0 : int = 8

var I_16x16_0_0_0 : int = 7

var I_4x4 : int = 6

var P_8x8ref0 : int = 5

var P_8x8 : int = 4

var P_L0_L0_8x16 : int = 3

var P_L0_L0_16x8 : int = 2

var P_L0_16x16 : int = 1

var P_Skip : int = 0

var P_L0_4x4 : int = 3

var P_L0_4x8 : int = 2

var P_L0_8x4 : int = 1

var P_L0_8x8 : int = 0

var MB_SP_4x4 : int = 3

var MB_SP_4x8 : int = 2

var MB_SP_8x4 : int = 1

var MB_SP_8x8 : int = 0

var PRED_MODE_INTER : int = 2

var PRED_MODE_INTRA16x16 : int = 1

var PRED_MODE_INTRA4x4 : int = 0

var MB_CURR : int = 4

var MB_NA : int = 255

var MB_D : int = 3

var MB_C : int = 2

var MB_B : int = 1

var MB_A : int = 0

var INNER : int = 2

var LEFT : int = 1

var TOP : int = 0

var H264BSD_MEMALLOC_ERROR : int = 5

var H264BSD_PARAM_SET_ERROR : int = 4

var H264BSD_ERROR : int = 3

var H264BSD_HDRS_RDY : int = 2

var H264BSD_PIC_RDY : int = 1

var H264BSD_RDY : int = 0



typedef uint8_t = uint8
typedef uint16_t = uint16
typedef uint32_t = uint
typedef uint64_t = uint64
typedef boxsize_t = uint64
typedef MP4D_file_offset_t = uint64
struct MP4E_mux_tag {
    tracks : minimp4_vector_t
    write_pos : int64
    write_callback : function?
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
    tracks : minimp4_vector_t
    write_pos : int64
    write_callback : function?
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
    width : int
    height : int
}
struct Unnamed_0 {
    channelcount : uint
}
struct MP4E_track_t {
    object_type_indication : uint
    language : array<uint8>
    track_media_kind : track_media_kind_t
    time_scale : uint
    default_duration : uint
    u : Unnamed_1
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
    language : array<uint8>
    stream_type : uint
    SampleDescription : Unnamed_4
    entry_size : uint?
    sample_to_chunk_count : uint
    sample_to_chunk : MP4D_sample_to_chunk_t_tag?
    chunk_count : uint
    chunk_offset : uint64?
    timestamp : uint?
    duration : uint?
}
struct MP4D_demux_tag {
    read_pos : int64
    read_size : int64
    track : MP4D_track_t?
    read_callback : function?
    token : uint64
    track_count : uint
    duration_hi : uint
    duration_lo : uint
    timescale : uint
    tag : Unnamed_5
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
    track : MP4D_track_t?
    read_callback : function?
    token : uint64
    track_count : uint
    duration_hi : uint
    duration_lo : uint
    timescale : uint
    tag : Unnamed_5
}
struct h264_sps_id_patcher_t {
    sps_cache : array<uint64>
    pps_cache : array<uint64>
    sps_bytes : array<int>
    pps_bytes : array<int>
    map_sps : array<int>
    map_pps : array<int>
}
struct mp4_h26x_writer_tag {
    sps_patcher : h264_sps_id_patcher_t
    mux : MP4E_mux_t?
    mux_track_id : int
    is_hevc : int
    need_vps : int
    need_sps : int
    need_pps : int
    need_idr : int
}
struct mp4_h26x_writer_t {
    sps_patcher : h264_sps_id_patcher_t
    mux : MP4E_mux_t?
    mux_track_id : int
    is_hevc : int
    need_vps : int
    need_sps : int
    need_pps : int
    need_idr : int
}
struct track_t {
    info : MP4E_track_t
    smpl : minimp4_vector_t
    pending_sample : minimp4_vector_t
    vsps : minimp4_vector_t
    vpps : minimp4_vector_t
    vvps : minimp4_vector_t
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
typedef bs_item_t = uint
struct Unnamed_6 {
    bytes : uint64
    format : boxtype_t
}
enum boxtype_t {
    BOX_ATOM = 0
    BOX_OD = 1
}
struct Unnamed_7 {
    name : uint
    type_0 : boxtype_t
}
struct Unnamed_8 {
    name : uint
    max_version : uint
    use_track_flag : uint
}
[export]
def mp4_h26x_write_init(var h : mp4_h26x_writer_t?; var mux : MP4E_mux_t?; var width : int; var height : int; var is_hevc : int) : int {
    var tr : MP4E_track_t
    tr.track_media_kind = cast<track_media_kind_t>(e_video)
    tr.track_media_kind
    unsafe(unsafe(addr(tr.language[0]))[0]) = uint8(uint8(117))
    unsafe(unsafe(addr(tr.language[0]))[0])
    unsafe(unsafe(addr(tr.language[0]))[1]) = uint8(uint8(110))
    unsafe(unsafe(addr(tr.language[0]))[1])
    unsafe(unsafe(addr(tr.language[0]))[2]) = uint8(uint8(100))
    unsafe(unsafe(addr(tr.language[0]))[2])
    unsafe(unsafe(addr(tr.language[0]))[3]) = uint8(uint8(0))
    unsafe(unsafe(addr(tr.language[0]))[3])
    var c2da_fresh0_minimp4 : int = 0
    if (is_hevc) {
        c2da_fresh0_minimp4 = 35
    } else {
        c2da_fresh0_minimp4 = 33
    }
    tr.object_type_indication = uint(uint(c2da_fresh0_minimp4))
    tr.object_type_indication
    tr.time_scale = uint(uint(90000))
    tr.time_scale
    tr.default_duration = uint(uint(0))
    tr.default_duration
    tr.u.v.width = width
    tr.u.v.width
    tr.u.v.height = height
    tr.u.v.height
    h.mux_track_id = MP4E_add_track(mux, unsafe(addr(tr)))
    h.mux_track_id
    h.mux = mux
    h.mux
    h.is_hevc = is_hevc
    h.is_hevc
    h.need_vps = is_hevc
    h.need_vps
    h.need_sps = 1
    h.need_sps
    h.need_pps = 1
    h.need_pps
    h.need_idr = 1
    h.need_idr
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(h.sps_patcher))))), 0, 4)
    return 0
}
[export]
def MP4E_add_track(var mux_0 : MP4E_mux_t?; var track_data : MP4E_track_t const?) : int {
    var tr_0 : track_t?
    var ntr : int = int(uint64(mux_0.tracks.bytes) / 4)
    if (mux_0 == null || track_data == null) {
        return -1
    }
    tr_0 = unsafe(reinterpret<track_t?>(minimp4_vector_alloc_tail(unsafe(addr(mux_0.tracks)), int(4))))
    tr_0
    if (tr_0 == null) {
        return -2
    }
    memset(unsafe(unsafe(reinterpret<uint64>(tr_0))), 0, 4)
    memcpy(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(tr_0.info))))), unsafe(unsafe(reinterpret<uint64>(track_data))), 4)
    if (minimp4_vector_init(unsafe(addr(tr_0.smpl)), 256) == 0) {
        return -2
    }
    minimp4_vector_init(unsafe(addr(tr_0.vsps)), 0)
    minimp4_vector_init(unsafe(addr(tr_0.vpps)), 0)
    minimp4_vector_init(unsafe(addr(tr_0.pending_sample)), 0)
    return ntr
}
[export]
def minimp4_vector_init(var h_0 : minimp4_vector_t?; var capacity : int) : int {
    h_0.bytes = 0
    h_0.bytes
    h_0.capacity = capacity
    h_0.capacity
    var c2da_fresh1_minimp4 : int = 0
    if (capacity) {
        c2da_fresh1_minimp4 = unsafe(reinterpret<uint8?>(malloc(uint64(capacity))))
    } else {
        c2da_fresh1_minimp4 = null
    }
    h_0.data = c2da_fresh1_minimp4
    h_0.data
    return capacity == 0 || h_0.data == null == 0
}
[export]
def minimp4_vector_alloc_tail(var h_1 : minimp4_vector_t?; var bytes : int) : uint8? {
    var p : uint8?
    if (h_1.data == null && minimp4_vector_init(h_1, 2 * bytes + 1024) == 0) {
        return null
    }
    if (h_1.capacity - h_1.bytes < bytes && minimp4_vector_grow(h_1, bytes) == 0) {
        return null
    }
    {
        if (h_1.data != null) {
        } else {
            c2da___assert_fail(unsafe(addr("h->data"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(787), unsafe(addr("unsigned char *minimp4_vector_alloc_tail(minimp4_vector_t *, int)"[0])))
        }
    }
    {
        if (h_1.capacity - h_1.bytes >= bytes) {
        } else {
            c2da___assert_fail(unsafe(addr("(h->capacity - h->bytes) >= bytes"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(788), unsafe(addr("unsigned char *minimp4_vector_alloc_tail(minimp4_vector_t *, int)"[0])))
        }
    }
    p = unsafe(h_1.data + h_1.bytes)
    p
    h_1.bytes = h_1.bytes + bytes
    h_1.bytes
    return p
}
[export]
def minimp4_vector_grow(var h_2 : minimp4_vector_t?; var bytes_0 : int) : int {
    var p_0 : uint64
    var new_size : int = h_2.capacity * 2 + 1024
    if (new_size < h_2.capacity + bytes_0) {
        new_size = h_2.capacity + bytes_0 + 1024
        new_size
    }
    p_0 = realloc(unsafe(unsafe(reinterpret<uint64>(h_2.data))), uint64(new_size))
    p_0
    if (p_0 == null) {
        return 0
    }
    h_2.data = unsafe(reinterpret<uint8?>(p_0))
    h_2.data
    h_2.capacity = new_size
    h_2.capacity
    return 1
}
[export]
def mp4_h26x_write_close(var h_3 : mp4_h26x_writer_t?) {
    var p_1 : h264_sps_id_patcher_t? = unsafe(addr(h_3.sps_patcher))
    i = 0
    i
    while (i < 256) {
        if (unsafe(unsafe(addr(p_1.pps_cache[0]))[i]) != null) {
            free(unsafe(unsafe(addr(p_1.pps_cache[0]))[i]))
        }
        i = i + 1
    }
    memset(unsafe(unsafe(reinterpret<uint64>(h_3))), 0, 4)
}
[export]
def mp4_h26x_write_nal(var h_4 : mp4_h26x_writer_t?; var nal : uint8 const?; var length : int; var timeStamp90kHz_next : uint) : int {
    var eof : uint8 const? = unsafe(nal + length)
    var payload_type : int
    var sizeof_nal : int
    var err : int = 0
    while (true) {
        var nal1 : uint8?
        var nal2 : uint8?
        nal = find_nal_unit(nal, int(eof - nal), unsafe(addr(sizeof_nal)))
        nal
        if (sizeof_nal == 0) {
            break
        }
        if (h_4.is_hevc != 0) {
            var err_0 : int = mp4_h265_write_nal(h_4, nal, sizeof_nal, timeStamp90kHz_next)
            if (err_0 != 0) {
                return err_0
            }
            continue
        }
        payload_type = int(unsafe(nal[0])) & 31
        payload_type
        if (9 == payload_type) {
            continue
        }
        nal1 = unsafe(reinterpret<uint8?>(malloc(uint64(sizeof_nal * 17 / 16 + 32))))
        nal1
        if (nal1 == null) {
            return -2
        }
        nal2 = unsafe(reinterpret<uint8?>(malloc(uint64(sizeof_nal * 17 / 16 + 32))))
        nal2
        if (nal2 == null) {
            free(unsafe(unsafe(reinterpret<uint64>(nal1))))
            return -2
        }
        sizeof_nal = remove_nal_escapes(nal2, nal, sizeof_nal)
        sizeof_nal
        if (sizeof_nal == 0) {
            label 75716:
            free(unsafe(unsafe(reinterpret<uint64>(nal1))))
            free(unsafe(unsafe(reinterpret<uint64>(nal2))))
            return -1
        }
        sizeof_nal = transcode_nalu(unsafe(addr(h_4.sps_patcher)), nal2, sizeof_nal, nal1)
        sizeof_nal
        sizeof_nal = nal_put_esc(nal2, nal1, sizeof_nal)
        sizeof_nal
        if (payload_type == 7) {
            MP4E_set_sps(h_4.mux, h_4.mux_track_id, unsafe(unsafe(reinterpret<uint64>(unsafe(nal2 + 4)))), sizeof_nal - 4)
        } elif (payload_type == 8) {
            if (h_4.need_sps != 0) {
                goto label 75716
            }
        } elif (payload_type == 5) {
            if (h_4.need_sps != 0) {
                goto label 75716
            }
        } else {
            if (h_4.need_sps != 0) {
                goto label 75716
            }
        }
        free(unsafe(unsafe(reinterpret<uint64>(nal1))))
        free(unsafe(unsafe(reinterpret<uint64>(nal2))))
        if (err != 0) {
            break
        }
        nal = nal + 1
    }
    return err
}
[export]
def MP4E_put_sample(var mux_1 : MP4E_mux_t?; var track_num : int; var data : uint64; var data_bytes : int; var duration : int; var kind : int) : int {
    var tr_1 : track_t?
    if (mux_1 == null || data == null) {
        return -1
    }
    tr_1 = unsafe(unsafe(reinterpret<track_t?>(mux_1.tracks.data)) + track_num)
    tr_1
    if (mux_1.enable_fragmentation != 0) {
        if (mux_1.fragments_count == 0) {
            var err_1 : int = mp4e_flush_index(mux_1)
            if (err_1 != 0) {
                return err_1
            }
        }
        var err_2 : int = mp4e_write_fragment_header(mux_1, track_num, data_bytes, duration, kind)
        if (err_2 != 0) {
            return err_2
        }
        var err_3 : int = mp4e_write_mdat_box(mux_1, uint(data_bytes + 8))
        if (err_3 != 0) {
            return err_3
        }
        var err_4 : int = mux_1.write_callback(mux_1.write_pos, data, cast<size_t>(data_bytes), mux_1.token)
        if (err_4 != 0) {
            return err_4
        }
        mux_1.write_pos = int64(mux_1.write_pos + int64(data_bytes))
        mux_1.write_pos
        return 0
    }
    if (kind != 2) {
        if (mux_1.sequential_mode_flag != 0) {
            var err_5 : int = write_pending_data(mux_1, tr_1)
            if (err_5 != 0) {
                return err_5
            }
        }
        if (add_sample_descriptor(mux_1, tr_1, data_bytes, duration, kind) == 0) {
            return -2
        }
    } else {
        if (mux_1.sequential_mode_flag == 0) {
            var smpl_desc : sample_t?
            if (uint64(tr_1.smpl.bytes) < 4) {
                return -2
            }
            smpl_desc = unsafe(unsafe(reinterpret<sample_t?>(unsafe(tr_1.smpl.data + tr_1.smpl.bytes))) - 1)
            smpl_desc
            smpl_desc.size = uint64(smpl_desc.size + uint64(data_bytes))
            smpl_desc.size
        }
    }
    if (mux_1.sequential_mode_flag != 0) {
        if (minimp4_vector_put(unsafe(addr(tr_1.pending_sample)), data, data_bytes) == null) {
            return -2
        }
    } else {
        var err_6 : int = mux_1.write_callback(mux_1.write_pos, data, cast<size_t>(data_bytes), mux_1.token)
        if (err_6 != 0) {
            return err_6
        }
        mux_1.write_pos = int64(mux_1.write_pos + int64(data_bytes))
        mux_1.write_pos
    }
    return 0
}
[export]
def minimp4_vector_put(var h_5 : minimp4_vector_t?; var buf : uint64; var bytes_1 : int) : uint8? {
    var tail : uint8? = minimp4_vector_alloc_tail(h_5, bytes_1)
    if (tail != null) {
        memcpy(unsafe(unsafe(reinterpret<uint64>(tail))), buf, uint64(bytes_1))
    }
    return tail
}
[export]
def add_sample_descriptor(var mux_2 : MP4E_mux_t?; var tr_2 : track_t?; var data_bytes_0 : int; var duration_0 : int; var kind_0 : int) : int {
    var smp : sample_t
    smp.size = uint64(uint64(data_bytes_0))
    smp.size
    smp.offset = uint64(uint64(mux_2.write_pos))
    smp.offset
    var c2da_fresh2_minimp4 : int = 0
    if (duration_0) {
        c2da_fresh2_minimp4 = uint(duration_0)
    } else {
        c2da_fresh2_minimp4 = tr_2.info.default_duration
    }
    smp.duration = uint(c2da_fresh2_minimp4)
    smp.duration
    smp.flag_random_access = uint(uint(kind_0 == 1))
    smp.flag_random_access
    return unsafe(unsafe(reinterpret<uint8?>(uint64(0)))) != minimp4_vector_put(unsafe(addr(tr_2.smpl)), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(smp))))), int(4))
}
[export]
def write_pending_data(var mux_3 : MP4E_mux_t?; var tr_3 : track_t?) : int {
    if (tr_3.pending_sample.bytes > 0 && uint64(tr_3.smpl.bytes) >= 4) {
        var smpl_desc_0 : sample_t?
        var base : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0]
        var p_2 : uint8? = unsafe(addr(base[0]))
        {
            if (mux_3.sequential_mode_flag != 0) {
            } else {
                c2da___assert_fail(unsafe(addr("mux->sequential_mode_flag"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(953), unsafe(addr("int write_pending_data(MP4E_mux_t *, track_t *)"[0])))
            }
        }
        {
            if (mux_3.sequential_mode_flag != 0) {
            } else {
                c2da___assert_fail(unsafe(addr("mux->sequential_mode_flag"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(956), unsafe(addr("int write_pending_data(MP4E_mux_t *, track_t *)"[0])))
            }
        }
        p_2 = p_2 + 1
        *p_2 = uint8(uint8(tr_3.pending_sample.bytes + 8 >> 8 * 3))
        *p_2
        p_2 = p_2 + 1
        *p_2 = uint8(uint8(tr_3.pending_sample.bytes + 8 >> 8 * 2))
        *p_2
        p_2 = p_2 + 1
        *p_2 = uint8(uint8(tr_3.pending_sample.bytes + 8 >> 8 * 1))
        *p_2
        p_2 = p_2 + 1
        *p_2 = uint8(uint8(tr_3.pending_sample.bytes + 8 >> 8 * 0))
        *p_2
        p_2 = p_2 + 1
        *p_2 = uint8(uint8(BOX_mdat >> 8 * 3))
        *p_2
        p_2 = p_2 + 1
        *p_2 = uint8(uint8(BOX_mdat >> 8 * 2))
        *p_2
        p_2 = p_2 + 1
        *p_2 = uint8(uint8(BOX_mdat >> 8 * 1))
        *p_2
        p_2 = p_2 + 1
        *p_2 = uint8(uint8(BOX_mdat >> 8 * 0))
        *p_2
        var err_7 : int = mux_3.write_callback(mux_3.write_pos, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(base[0]))))), cast<size_t>(p_2 - unsafe(addr(base[0]))), mux_3.token)
        if (err_7 != 0) {
            return err_7
        }
        mux_3.write_pos = int64(mux_3.write_pos + p_2 - unsafe(addr(base[0])))
        mux_3.write_pos
        smpl_desc_0 = unsafe(unsafe(reinterpret<sample_t?>(minimp4_vector_alloc_tail(unsafe(addr(tr_3.smpl)), 0))) - 1)
        smpl_desc_0
        smpl_desc_0.size = uint64(uint64(tr_3.pending_sample.bytes))
        smpl_desc_0.size
        smpl_desc_0.offset = uint64(uint64(mux_3.write_pos))
        smpl_desc_0.offset
        var err_8 : int = mux_3.write_callback(mux_3.write_pos, unsafe(unsafe(reinterpret<uint64>(tr_3.pending_sample.data))), cast<size_t>(tr_3.pending_sample.bytes), mux_3.token)
        if (err_8 != 0) {
            return err_8
        }
        mux_3.write_pos = int64(mux_3.write_pos + int64(tr_3.pending_sample.bytes))
        mux_3.write_pos
        tr_3.pending_sample.bytes = 0
        tr_3.pending_sample.bytes
    }
    return 0
}
[export]
def mp4e_write_mdat_box(var mux_4 : MP4E_mux_t?; var size : uint) : int {
    var base_0 : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0]
    var p_3 : uint8? = unsafe(addr(base_0[0]))
    p_3 = p_3 + 1
    *p_3 = uint8(uint8(uint(size) >> uint(uint(8 * 3))))
    *p_3
    p_3 = p_3 + 1
    *p_3 = uint8(uint8(uint(size) >> uint(uint(8 * 2))))
    *p_3
    p_3 = p_3 + 1
    *p_3 = uint8(uint8(uint(size) >> uint(uint(8 * 1))))
    *p_3
    p_3 = p_3 + 1
    *p_3 = uint8(uint8(uint(size) >> uint(uint(8 * 0))))
    *p_3
    p_3 = p_3 + 1
    *p_3 = uint8(uint8(BOX_mdat >> 8 * 3))
    *p_3
    p_3 = p_3 + 1
    *p_3 = uint8(uint8(BOX_mdat >> 8 * 2))
    *p_3
    p_3 = p_3 + 1
    *p_3 = uint8(uint8(BOX_mdat >> 8 * 1))
    *p_3
    p_3 = p_3 + 1
    *p_3 = uint8(uint8(BOX_mdat >> 8 * 0))
    *p_3
    var err_9 : int = mux_4.write_callback(mux_4.write_pos, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(base_0[0]))))), cast<size_t>(p_3 - unsafe(addr(base_0[0]))), mux_4.token)
    if (err_9 != 0) {
        return err_9
    }
    mux_4.write_pos = int64(mux_4.write_pos + p_3 - unsafe(addr(base_0[0])))
    mux_4.write_pos
    return 0
}
[export]
def mp4e_write_fragment_header(var mux_5 : MP4E_mux_t?; var track_num_0 : int; var data_bytes_1 : int; var duration_1 : int; var kind_1 : int) : int {
    var base_1 : array<uint8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var p_4 : uint8? = unsafe(addr(base_1[0]))
    var stack_base : array<uint8?> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var stack : uint8?? = unsafe(addr(stack_base[0]))
    var pdata_offset : uint8?
    var c2da_fresh3_minimp4 : int = 0
    if (uint(tr_4.info.track_media_kind) == uint(e_video)) {
        c2da_fresh3_minimp4 = 131104
    } else {
        c2da_fresh3_minimp4 = 131080
    }
    flags = uint(uint(c2da_fresh3_minimp4))
    flags
    stack = stack + 1
    *stack = p_4
    *stack
    p_4 = p_4 + 4
    p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(BOX_tfhd >> 8 * 3))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(BOX_tfhd >> 8 * 2))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(BOX_tfhd >> 8 * 1))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(BOX_tfhd >> 8 * 0))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 3))))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 2))))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 1))))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 0))))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(track_num_0 + 1 >> 8 * 3))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(track_num_0 + 1 >> 8 * 2))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(track_num_0 + 1 >> 8 * 1))
    *p_4
    p_4 = p_4 + 1
    *p_4 = uint8(uint8(track_num_0 + 1 >> 8 * 0))
    *p_4
    if (uint(tr_4.info.track_media_kind) == uint(e_video)) {
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(16842752 >> 8 * 3))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(16842752 >> 8 * 2))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(16842752 >> 8 * 1))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(16842752 >> 8 * 0))
        *p_4
    } else {
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(duration_1 >> 8 * 3))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(duration_1 >> 8 * 2))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(duration_1 >> 8 * 1))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(duration_1 >> 8 * 0))
        *p_4
    }
    stack = stack - 1
    stack
    unsafe(cast<uint8?>(*stack)[0]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 3)))))
    unsafe(cast<uint8?>(*stack)[0])
    unsafe(cast<uint8?>(*stack)[1]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 2)))))
    unsafe(cast<uint8?>(*stack)[1])
    unsafe(cast<uint8?>(*stack)[2]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 1)))))
    unsafe(cast<uint8?>(*stack)[2])
    unsafe(cast<uint8?>(*stack)[3]) = uint8(uint8(int8(p_4 - *stack)))
    unsafe(cast<uint8?>(*stack)[3])
    if (uint(tr_4.info.track_media_kind) == uint(e_audio)) {
        flags = uint(uint(0))
        flags
        flags = uint(flags | uint(1))
        flags
        flags = uint(flags | uint(512))
        flags
        stack = stack + 1
        *stack = p_4
        *stack
        p_4 = p_4 + 4
        p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(BOX_trun >> 8 * 3))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(BOX_trun >> 8 * 2))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(BOX_trun >> 8 * 1))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(BOX_trun >> 8 * 0))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 3))))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 2))))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 1))))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 0))))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(1 >> 8 * 3))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(1 >> 8 * 2))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(1 >> 8 * 1))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(1 >> 8 * 0))
        *p_4
        pdata_offset = p_4
        pdata_offset
        p_4 = p_4 + 4
        p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(data_bytes_1 >> 8 * 3))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(data_bytes_1 >> 8 * 2))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(data_bytes_1 >> 8 * 1))
        *p_4
        p_4 = p_4 + 1
        *p_4 = uint8(uint8(data_bytes_1 >> 8 * 0))
        *p_4
        stack = stack - 1
        stack
        unsafe(cast<uint8?>(*stack)[0]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack)[0])
        unsafe(cast<uint8?>(*stack)[1]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack)[1])
        unsafe(cast<uint8?>(*stack)[2]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack)[2])
        unsafe(cast<uint8?>(*stack)[3]) = uint8(uint8(int8(p_4 - *stack)))
        unsafe(cast<uint8?>(*stack)[3])
    } else {
        if (kind_1 == 1) {
            flags = uint(uint(0))
            flags
            flags = uint(flags | uint(1))
            flags
            flags = uint(flags | uint(4))
            flags
            flags = uint(flags | uint(256))
            flags
            flags = uint(flags | uint(512))
            flags
            stack = stack + 1
            *stack = p_4
            *stack
            p_4 = p_4 + 4
            p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(BOX_trun >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(BOX_trun >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(BOX_trun >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(BOX_trun >> 8 * 0))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 3))))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 2))))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 1))))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 0))))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(1 >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(1 >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(1 >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(1 >> 8 * 0))
            *p_4
            pdata_offset = p_4
            pdata_offset
            p_4 = p_4 + 4
            p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(33554432 >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(33554432 >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(33554432 >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(33554432 >> 8 * 0))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(duration_1 >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(duration_1 >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(duration_1 >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(duration_1 >> 8 * 0))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(data_bytes_1 >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(data_bytes_1 >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(data_bytes_1 >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(data_bytes_1 >> 8 * 0))
            *p_4
            stack = stack - 1
            stack
            unsafe(cast<uint8?>(*stack)[0]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack)[0])
            unsafe(cast<uint8?>(*stack)[1]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack)[1])
            unsafe(cast<uint8?>(*stack)[2]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack)[2])
            unsafe(cast<uint8?>(*stack)[3]) = uint8(uint8(int8(p_4 - *stack)))
            unsafe(cast<uint8?>(*stack)[3])
        } else {
            flags = uint(uint(0))
            flags
            flags = uint(flags | uint(1))
            flags
            flags = uint(flags | uint(256))
            flags
            flags = uint(flags | uint(512))
            flags
            stack = stack + 1
            *stack = p_4
            *stack
            p_4 = p_4 + 4
            p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(BOX_trun >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(BOX_trun >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(BOX_trun >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(BOX_trun >> 8 * 0))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 3))))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 2))))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 1))))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(uint(flags) >> uint(uint(8 * 0))))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(1 >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(1 >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(1 >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(1 >> 8 * 0))
            *p_4
            pdata_offset = p_4
            pdata_offset
            p_4 = p_4 + 4
            p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(duration_1 >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(duration_1 >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(duration_1 >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(duration_1 >> 8 * 0))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(data_bytes_1 >> 8 * 3))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(data_bytes_1 >> 8 * 2))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(data_bytes_1 >> 8 * 1))
            *p_4
            p_4 = p_4 + 1
            *p_4 = uint8(uint8(data_bytes_1 >> 8 * 0))
            *p_4
            stack = stack - 1
            stack
            unsafe(cast<uint8?>(*stack)[0]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack)[0])
            unsafe(cast<uint8?>(*stack)[1]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack)[1])
            unsafe(cast<uint8?>(*stack)[2]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack)[2])
            unsafe(cast<uint8?>(*stack)[3]) = uint8(uint8(int8(p_4 - *stack)))
            unsafe(cast<uint8?>(*stack)[3])
        }
    }
    stack = stack - 1
    stack
    unsafe(cast<uint8?>(*stack)[0]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 3)))))
    unsafe(cast<uint8?>(*stack)[0])
    unsafe(cast<uint8?>(*stack)[1]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 2)))))
    unsafe(cast<uint8?>(*stack)[1])
    unsafe(cast<uint8?>(*stack)[2]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 1)))))
    unsafe(cast<uint8?>(*stack)[2])
    unsafe(cast<uint8?>(*stack)[3]) = uint8(uint8(int8(p_4 - *stack)))
    unsafe(cast<uint8?>(*stack)[3])
    stack = stack - 1
    stack
    unsafe(cast<uint8?>(*stack)[0]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 3)))))
    unsafe(cast<uint8?>(*stack)[0])
    unsafe(cast<uint8?>(*stack)[1]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 2)))))
    unsafe(cast<uint8?>(*stack)[1])
    unsafe(cast<uint8?>(*stack)[2]) = uint8(uint8(int8(int64(p_4 - *stack) >> int64(int64(8 * 1)))))
    unsafe(cast<uint8?>(*stack)[2])
    unsafe(cast<uint8?>(*stack)[3]) = uint8(uint8(int8(p_4 - *stack)))
    unsafe(cast<uint8?>(*stack)[3])
    unsafe(pdata_offset[0]) = uint8(uint8(int8(int64(p_4 - unsafe(addr(base_1[0])) + int64(8)) >> int64(int64(8 * 3)))))
    unsafe(pdata_offset[0])
    unsafe(pdata_offset[1]) = uint8(uint8(int8(int64(p_4 - unsafe(addr(base_1[0])) + int64(8)) >> int64(int64(8 * 2)))))
    unsafe(pdata_offset[1])
    unsafe(pdata_offset[2]) = uint8(uint8(int8(int64(p_4 - unsafe(addr(base_1[0])) + int64(8)) >> int64(int64(8 * 1)))))
    unsafe(pdata_offset[2])
    unsafe(pdata_offset[3]) = uint8(uint8(int8(p_4 - unsafe(addr(base_1[0])) + int64(8))))
    unsafe(pdata_offset[3])
    var err_10 : int = mux_5.write_callback(mux_5.write_pos, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(base_1[0]))))), cast<size_t>(p_4 - unsafe(addr(base_1[0]))), mux_5.token)
    if (err_10 != 0) {
        return err_10
    }
    mux_5.write_pos = int64(mux_5.write_pos + p_4 - unsafe(addr(base_1[0])))
    mux_5.write_pos
    return 0
}
[export]
def mp4e_flush_index(var mux_6 : MP4E_mux_t?) : int {
    var stack_base_0 : array<uint8?> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var stack_0 : uint8?? = unsafe(addr(stack_base_0[0]))
    var base_2 : uint8?
    var p_5 : uint8?
    var ntr_0 : uint
    var index_bytes : uint
    var ntracks : uint = uint(uint64(mux_6.tracks.bytes) / 4)
    ntr_0 = uint(uint(0))
    ntr_0
    while (ntr_0 < ntracks) {
        var tr_5 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_6.tracks.data)) + ntr_0)
        index_bytes = uint(index_bytes + uint(512))
        index_bytes
        index_bytes = uint(index_bytes + uint64(tr_5.smpl.bytes) * 4 + uint64(4) + uint64(4) / 4)
        index_bytes
        index_bytes = uint(index_bytes + uint(tr_5.vsps.bytes))
        index_bytes
        index_bytes = uint(index_bytes + uint(tr_5.vpps.bytes))
        index_bytes
        var err_12 : int = write_pending_data(mux_6, tr_5)
        if (err_12 != 0) {
            return err_12
        }
        ntr_0 = ntr_0 + 1
    }
    base_2 = unsafe(reinterpret<uint8?>(malloc(uint64(index_bytes))))
    base_2
    if (base_2 == null) {
        return -2
    }
    p_5 = base_2
    p_5
    if (mux_6.sequential_mode_flag == 0) {
        var size_0 : int64 = int64(uint64(mux_6.write_pos) - 4)
        var size_limit : int64 const = int64(uint64(0xfffffffe))
        if (size_0 > size_limit) {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_mdat >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_mdat >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_mdat >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_mdat >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(int64(size_0) >> int64(int64(32)) & int64(0xffffffff)) >> int64(int64(8 * 3))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(int64(size_0) >> int64(int64(32)) & int64(0xffffffff)) >> int64(int64(8 * 2))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(int64(size_0) >> int64(int64(32)) & int64(0xffffffff)) >> int64(int64(8 * 1))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(int64(size_0) >> int64(int64(32)) & int64(0xffffffff)) >> int64(int64(8 * 0))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(size_0 & int64(0xffffffff)) >> int64(int64(8 * 3))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(size_0 & int64(0xffffffff)) >> int64(int64(8 * 2))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(size_0 & int64(0xffffffff)) >> int64(int64(8 * 1))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(size_0 & int64(0xffffffff)) >> int64(int64(8 * 0))))
            *p_5
        } else {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(8 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(8 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(8 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(8 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_free >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_free >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_free >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_free >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(size_0 - int64(8)) >> int64(int64(8 * 3))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(size_0 - int64(8)) >> int64(int64(8 * 2))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(size_0 - int64(8)) >> int64(int64(8 * 1))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int64(size_0 - int64(8)) >> int64(int64(8 * 0))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_mdat >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_mdat >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_mdat >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_mdat >> 8 * 0))
            *p_5
        }
        var err_13 : int = mux_6.write_callback(int64(4), unsafe(unsafe(reinterpret<uint64>(base_2))), cast<size_t>(p_5 - base_2), mux_6.token)
        if (err_13 != 0) {
            return err_13
        }
        p_5 = base_2
        p_5
    }
    stack_0 = stack_0 + 1
    *stack_0 = p_5
    *stack_0
    p_5 = p_5 + 4
    p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(BOX_moov >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(BOX_moov >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(BOX_moov >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(BOX_moov >> 8 * 0))
    *p_5
    stack_0 = stack_0 + 1
    *stack_0 = p_5
    *stack_0
    p_5 = p_5 + 4
    p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(BOX_mvhd >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(BOX_mvhd >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(BOX_mvhd >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(BOX_mvhd >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    if (ntracks != 0x0) {
        var tr_6 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_6.tracks.data)) + 0)
        var duration_2 : uint = get_duration(tr_6)
        duration_2 = uint(uint(int64(duration_2) * 1 * int64(1000) / int64(tr_6.info.time_scale)))
        duration_2
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1000 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1000 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1000 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1000 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(duration_2) >> uint(uint(8 * 3))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(duration_2) >> uint(uint(8 * 2))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(duration_2) >> uint(uint(8 * 1))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(duration_2) >> uint(uint(8 * 0))))
        *p_5
    }
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(256 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(256 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(65536 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(1073741824 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(1073741824 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(1073741824 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(1073741824 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 3))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 2))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 1))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(0 >> 8 * 0))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(uint(ntracks + uint(1)) >> uint(uint(8 * 3))))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(uint(ntracks + uint(1)) >> uint(uint(8 * 2))))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(uint(ntracks + uint(1)) >> uint(uint(8 * 1))))
    *p_5
    p_5 = p_5 + 1
    *p_5 = uint8(uint8(uint(ntracks + uint(1)) >> uint(uint(8 * 0))))
    *p_5
    stack_0 = stack_0 - 1
    stack_0
    unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
    unsafe(cast<uint8?>(*stack_0)[0])
    unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
    unsafe(cast<uint8?>(*stack_0)[1])
    unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
    unsafe(cast<uint8?>(*stack_0)[2])
    unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
    unsafe(cast<uint8?>(*stack_0)[3])
    ntr_0 = uint(uint(0))
    ntr_0
    while (ntr_0 < ntracks) {
        var tr_7 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_6.tracks.data)) + ntr_0)
        var duration_3 : uint = get_duration(tr_7)
        var samples_count : int = int(uint64(tr_7.smpl.bytes) / 4)
        if (uint(tr_7.info.track_media_kind) == uint(e_audio)) {
            handler_type = uint(uint(1936684398))
            handler_type
        } elif (uint(tr_7.info.track_media_kind) == uint(e_video)) {
            handler_type = uint(uint(1986618469))
            handler_type
        } elif (uint(tr_7.info.track_media_kind) == uint(e_private)) {
            handler_type = uint(uint(1734701933))
            handler_type
        } else {
            return -1
        }
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_trak >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_trak >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_trak >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_trak >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_tkhd >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_tkhd >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_tkhd >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_tkhd >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(7 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(7 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(7 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(7 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(ntr_0 + uint(1)) >> uint(uint(8 * 3))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(ntr_0 + uint(1)) >> uint(uint(8 * 2))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(ntr_0 + uint(1)) >> uint(uint(8 * 1))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(ntr_0 + uint(1)) >> uint(uint(8 * 0))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(uint(int64(duration_3) * 1 * int64(1000) / int64(tr_7.info.time_scale))) >> uint(uint(8 * 3))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(uint(int64(duration_3) * 1 * int64(1000) / int64(tr_7.info.time_scale))) >> uint(uint(8 * 2))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(uint(int64(duration_3) * 1 * int64(1000) / int64(tr_7.info.time_scale))) >> uint(uint(8 * 1))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(uint(int64(duration_3) * 1 * int64(1000) / int64(tr_7.info.time_scale))) >> uint(uint(8 * 0))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(256 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(256 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(65536 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(65536 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(65536 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(65536 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(65536 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(65536 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(65536 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(65536 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1073741824 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1073741824 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1073741824 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1073741824 >> 8 * 0))
        *p_5
        if (uint(tr_7.info.track_media_kind) == uint(e_audio) || uint(tr_7.info.track_media_kind) == uint(e_private)) {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
        } else {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.width * 65536 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.width * 65536 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.width * 65536 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.width * 65536 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.height * 65536 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.height * 65536 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.height * 65536 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.height * 65536 >> 8 * 0))
            *p_5
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mdia >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mdia >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mdia >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mdia >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mdhd >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mdhd >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mdhd >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mdhd >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(tr_7.info.time_scale) >> uint(uint(8 * 3))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(tr_7.info.time_scale) >> uint(uint(8 * 2))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(tr_7.info.time_scale) >> uint(uint(8 * 1))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(tr_7.info.time_scale) >> uint(uint(8 * 0))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(duration_3) >> uint(uint(8 * 3))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(duration_3) >> uint(uint(8 * 2))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(duration_3) >> uint(uint(8 * 1))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(duration_3) >> uint(uint(8 * 0))))
        *p_5
        var lang_code : int = int(unsafe(unsafe(addr(tr_7.info.language[0]))[0])) & 31 << 10 | int(unsafe(unsafe(addr(tr_7.info.language[0]))[1])) & 31 << 5 | int(unsafe(unsafe(addr(tr_7.info.language[0]))[2])) & 31
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(lang_code >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(lang_code >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_hdlr >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_hdlr >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_hdlr >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_hdlr >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(handler_type) >> uint(uint(8 * 3))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(handler_type) >> uint(uint(8 * 2))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(handler_type) >> uint(uint(8 * 1))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(handler_type) >> uint(uint(8 * 0))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        if (handler_ascii != null) {
            i_0 = 0
            i_0
            while (i_0 < int(strlen(handler_ascii)) + 1) {
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(int(unsafe(handler_ascii[i_0])) >> 8 * 0))
                *p_5
                i_0 = i_0 + 1
            }
        } else {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_minf >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_minf >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_minf >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_minf >> 8 * 0))
        *p_5
        if (uint(tr_7.info.track_media_kind) == uint(e_audio)) {
            stack_0 = stack_0 + 1
            *stack_0 = p_5
            *stack_0
            p_5 = p_5 + 4
            p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_smhd >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_smhd >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_smhd >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_smhd >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            stack_0 = stack_0 - 1
            stack_0
            unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack_0)[0])
            unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack_0)[1])
            unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack_0)[2])
            unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
            unsafe(cast<uint8?>(*stack_0)[3])
        }
        if (uint(tr_7.info.track_media_kind) == uint(e_video)) {
            stack_0 = stack_0 + 1
            *stack_0 = p_5
            *stack_0
            p_5 = p_5 + 4
            p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_vmhd >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_vmhd >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_vmhd >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_vmhd >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            stack_0 = stack_0 - 1
            stack_0
            unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack_0)[0])
            unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack_0)[1])
            unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack_0)[2])
            unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
            unsafe(cast<uint8?>(*stack_0)[3])
        }
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_dinf >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_dinf >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_dinf >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_dinf >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_dref >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_dref >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_dref >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_dref >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_url >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_url >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_url >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_url >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 0))
        *p_5
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stbl >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stbl >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stbl >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stbl >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsd >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsd >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsd >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsd >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 0))
        *p_5
        if (uint(tr_7.info.track_media_kind) == uint(e_audio) || uint(tr_7.info.track_media_kind) == uint(e_private)) {
            if (uint(tr_7.info.track_media_kind) == uint(e_audio)) {
                stack_0 = stack_0 + 1
                *stack_0 = p_5
                *stack_0
                p_5 = p_5 + 4
                p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_mp4a >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_mp4a >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_mp4a >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_mp4a >> 8 * 0))
                *p_5
            } else {
                stack_0 = stack_0 + 1
                *stack_0 = p_5
                *stack_0
                p_5 = p_5 + 4
                p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_mp4s >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_mp4s >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_mp4s >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_mp4s >> 8 * 0))
                *p_5
            }
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            if (uint(tr_7.info.track_media_kind) == uint(e_audio)) {
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(tr_7.info.u.a.channelcount) >> uint(uint(8 * 1))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(tr_7.info.u.a.channelcount) >> uint(uint(8 * 0))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(16 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(16 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(uint(tr_7.info.time_scale) << uint(uint(16))) >> uint(uint(8 * 3))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(uint(tr_7.info.time_scale) << uint(uint(16))) >> uint(uint(8 * 2))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(uint(tr_7.info.time_scale) << uint(uint(16))) >> uint(uint(8 * 1))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(uint(tr_7.info.time_scale) << uint(uint(16))) >> uint(uint(8 * 0))))
                *p_5
            }
            stack_0 = stack_0 + 1
            *stack_0 = p_5
            *stack_0
            p_5 = p_5 + 4
            p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_esds >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_esds >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_esds >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_esds >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            if (tr_7.vsps.bytes > 0) {
                var dsi_bytes : int = tr_7.vsps.bytes - 2
                var dsi_size_size : int = od_size_of_size(dsi_bytes)
                var dcd_bytes : int = dsi_bytes + dsi_size_size + 1 + 1 + 1 + 3 + 4 + 4
                var dcd_size_size : int = od_size_of_size(dcd_bytes)
                var esd_bytes : int = dcd_bytes + dcd_size_size + 1 + 3
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(3 >> 8 * 0))
                *p_5
                if (esd_bytes > 127) {
                    var _dw_15800 : bool = true
                    while (_dw_15800 || esd_bytes > 127) {
                        _dw_15800 = false
                        esd_bytes = esd_bytes - 127
                        esd_bytes
                        p_5 = p_5 + 1
                        *p_5 = uint8(uint8(255 >> 8 * 0))
                        *p_5
                    }
                }
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(esd_bytes >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(4 >> 8 * 0))
                *p_5
                if (dcd_bytes > 127) {
                    var _dw_15695 : bool = true
                    while (_dw_15695 || dcd_bytes > 127) {
                        _dw_15695 = false
                        dcd_bytes = dcd_bytes - 127
                        dcd_bytes
                        p_5 = p_5 + 1
                        *p_5 = uint8(uint8(255 >> 8 * 0))
                        *p_5
                    }
                }
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(dcd_bytes >> 8 * 0))
                *p_5
                if (uint(tr_7.info.track_media_kind) == uint(e_audio)) {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(64 >> 8 * 0))
                    *p_5
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(5 << 2 >> 8 * 0))
                    *p_5
                } else {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(208 >> 8 * 0))
                    *p_5
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(32 << 2 >> 8 * 0))
                    *p_5
                }
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(tr_7.info.u.a.channelcount * uint(6144) / uint(8)) >> uint(uint(8 * 2))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(tr_7.info.u.a.channelcount * uint(6144) / uint(8)) >> uint(uint(8 * 1))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(tr_7.info.u.a.channelcount * uint(6144) / uint(8)) >> uint(uint(8 * 0))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(5 >> 8 * 0))
                *p_5
                if (dsi_bytes > 127) {
                    var _dw_15351 : bool = true
                    while (_dw_15351 || dsi_bytes > 127) {
                        _dw_15351 = false
                        dsi_bytes = dsi_bytes - 127
                        dsi_bytes
                        p_5 = p_5 + 1
                        *p_5 = uint8(uint8(255 >> 8 * 0))
                        *p_5
                    }
                }
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(dsi_bytes >> 8 * 0))
                *p_5
                i_0 = 0
                i_0
                while (i_0 < dsi_bytes) {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(int(unsafe(tr_7.vsps.data[2 + i_0])) >> 8 * 0))
                    *p_5
                    i_0 = i_0 + 1
                }
            }
            stack_0 = stack_0 - 1
            stack_0
            unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack_0)[0])
            unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack_0)[1])
            unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack_0)[2])
            unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
            unsafe(cast<uint8?>(*stack_0)[3])
            stack_0 = stack_0 - 1
            stack_0
            unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack_0)[0])
            unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack_0)[1])
            unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack_0)[2])
            unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
            unsafe(cast<uint8?>(*stack_0)[3])
        }
        if (uint(tr_7.info.track_media_kind) == uint(e_video) && uint(33) == tr_7.info.object_type_indication || uint(35) == tr_7.info.object_type_indication) {
            var numOfSequenceParameterSets : int = items_count(unsafe(addr(tr_7.vsps)))
            var numOfPictureParameterSets : int = items_count(unsafe(addr(tr_7.vpps)))
            if (uint(33) == tr_7.info.object_type_indication) {
                stack_0 = stack_0 + 1
                *stack_0 = p_5
                *stack_0
                p_5 = p_5 + 4
                p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_avc1 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_avc1 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_avc1 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_avc1 >> 8 * 0))
                *p_5
            } else {
                stack_0 = stack_0 + 1
                *stack_0 = p_5
                *stack_0
                p_5 = p_5 + 4
                p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_hvc1 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_hvc1 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_hvc1 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_hvc1 >> 8 * 0))
                *p_5
            }
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.width >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.width >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.height >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(tr_7.info.u.v.height >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(4718592 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(4718592 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(4718592 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(4718592 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(4718592 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(4718592 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(4718592 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(4718592 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            i_0 = 0
            i_0
            while (i_0 < 32) {
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                i_0 = i_0 + 1
            }
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(24 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(24 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(-1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(-1 >> 8 * 0))
            *p_5
            if (uint(33) == tr_7.info.object_type_indication) {
                stack_0 = stack_0 + 1
                *stack_0 = p_5
                *stack_0
                p_5 = p_5 + 4
                p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_avcC >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_avcC >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_avcC >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_avcC >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(int(unsafe(tr_7.vsps.data[2 + 1])) >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(int(unsafe(tr_7.vsps.data[2 + 2])) >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(int(unsafe(tr_7.vsps.data[2 + 3])) >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(255 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(224 | numOfSequenceParameterSets >> 8 * 0))
                *p_5
                i_0 = 0
                i_0
                while (i_0 < tr_7.vsps.bytes) {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(int(unsafe(tr_7.vsps.data[i_0])) >> 8 * 0))
                    *p_5
                    i_0 = i_0 + 1
                }
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(numOfPictureParameterSets >> 8 * 0))
                *p_5
                i_0 = 0
                i_0
                while (i_0 < tr_7.vpps.bytes) {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(int(unsafe(tr_7.vpps.data[i_0])) >> 8 * 0))
                    *p_5
                    i_0 = i_0 + 1
                }
            } else {
                var numOfVPS : int = items_count(unsafe(addr(tr_7.vpps)))
                stack_0 = stack_0 + 1
                *stack_0 = p_5
                *stack_0
                p_5 = p_5 + 4
                p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_hvcC >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_hvcC >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_hvcC >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(BOX_hvcC >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1610612736 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1610612736 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1610612736 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1610612736 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(61440 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(61440 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(252 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(252 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(248 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(248 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(0 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(3 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(3 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1 << 7 | 32 & 63 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(numOfVPS >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(numOfVPS >> 8 * 0))
                *p_5
                i_0 = 0
                i_0
                while (i_0 < tr_7.vvps.bytes) {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(int(unsafe(tr_7.vvps.data[i_0])) >> 8 * 0))
                    *p_5
                    i_0 = i_0 + 1
                }
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1 << 7 | 33 & 63 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(numOfSequenceParameterSets >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(numOfSequenceParameterSets >> 8 * 0))
                *p_5
                i_0 = 0
                i_0
                while (i_0 < tr_7.vsps.bytes) {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(int(unsafe(tr_7.vsps.data[i_0])) >> 8 * 0))
                    *p_5
                    i_0 = i_0 + 1
                }
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(1 << 7 | 34 & 63 >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(numOfPictureParameterSets >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(numOfPictureParameterSets >> 8 * 0))
                *p_5
                i_0 = 0
                i_0
                while (i_0 < tr_7.vpps.bytes) {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(int(unsafe(tr_7.vpps.data[i_0])) >> 8 * 0))
                    *p_5
                    i_0 = i_0 + 1
                }
            }
            stack_0 = stack_0 - 1
            stack_0
            unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack_0)[0])
            unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack_0)[1])
            unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack_0)[2])
            unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
            unsafe(cast<uint8?>(*stack_0)[3])
            stack_0 = stack_0 - 1
            stack_0
            unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack_0)[0])
            unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack_0)[1])
            unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack_0)[2])
            unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
            unsafe(cast<uint8?>(*stack_0)[3])
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stts >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stts >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stts >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stts >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        var pentry_count : uint8? = p_5
        var cnt : int = 1
        var entry_count : int = 0
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        i_0 = 0
        i_0
        while (i_0 < samples_count) {
            if (i_0 == samples_count - 1 || unsafe(sample[i_0]).duration != unsafe(sample[i_0 + 1]).duration) {
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(cnt >> 8 * 3))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(cnt >> 8 * 2))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(cnt >> 8 * 1))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(cnt >> 8 * 0))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(unsafe(sample[i_0]).duration) >> uint(uint(8 * 3))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(unsafe(sample[i_0]).duration) >> uint(uint(8 * 2))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(unsafe(sample[i_0]).duration) >> uint(uint(8 * 1))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint(unsafe(sample[i_0]).duration) >> uint(uint(8 * 0))))
                *p_5
                cnt = 0
                cnt
                entry_count = entry_count + 1
                entry_count
            }
            cnt = cnt + 1
        }
        unsafe(pentry_count[0]) = uint8(uint8(int8(entry_count >> 8 * 3)))
        unsafe(pentry_count[0])
        unsafe(pentry_count[1]) = uint8(uint8(int8(entry_count >> 8 * 2)))
        unsafe(pentry_count[1])
        unsafe(pentry_count[2]) = uint8(uint8(int8(entry_count >> 8 * 1)))
        unsafe(pentry_count[2])
        unsafe(pentry_count[3]) = uint8(uint8(int8(entry_count)))
        unsafe(pentry_count[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsc >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsc >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsc >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsc >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        if (mux_6.enable_fragmentation != 0) {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
        } else {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsz >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsz >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsz >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_stsz >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(samples_count >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(samples_count >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(samples_count >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(samples_count >> 8 * 0))
        *p_5
        i_0 = 0
        i_0
        while (i_0 < samples_count) {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).size) >> uint64(uint64(8 * 3))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).size) >> uint64(uint64(8 * 2))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).size) >> uint64(uint64(8 * 1))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).size) >> uint64(uint64(8 * 0))))
            *p_5
            i_0 = i_0 + 1
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        var is_64_bit : int = 0
        if (samples_count != 0 && unsafe(sample[samples_count - 1]).offset > uint64(0xffffffff)) {
            is_64_bit = 1
            is_64_bit
        }
        if (is_64_bit == 0) {
            stack_0 = stack_0 + 1
            *stack_0 = p_5
            *stack_0
            p_5 = p_5 + 4
            p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_stco >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_stco >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_stco >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_stco >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(samples_count >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(samples_count >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(samples_count >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(samples_count >> 8 * 0))
            *p_5
            i_0 = 0
            i_0
            while (i_0 < samples_count) {
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).offset) >> uint64(uint64(8 * 3))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).offset) >> uint64(uint64(8 * 2))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).offset) >> uint64(uint64(8 * 1))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).offset) >> uint64(uint64(8 * 0))))
                *p_5
                i_0 = i_0 + 1
            }
        } else {
            stack_0 = stack_0 + 1
            *stack_0 = p_5
            *stack_0
            p_5 = p_5 + 4
            p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_co64 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_co64 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_co64 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_co64 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(samples_count >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(samples_count >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(samples_count >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(samples_count >> 8 * 0))
            *p_5
            i_0 = 0
            i_0
            while (i_0 < samples_count) {
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(uint64(unsafe(sample[i_0]).offset) >> uint64(uint64(32)) & uint64(0xffffffff)) >> uint64(uint64(8 * 3))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(uint64(unsafe(sample[i_0]).offset) >> uint64(uint64(32)) & uint64(0xffffffff)) >> uint64(uint64(8 * 2))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(uint64(unsafe(sample[i_0]).offset) >> uint64(uint64(32)) & uint64(0xffffffff)) >> uint64(uint64(8 * 1))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(uint64(unsafe(sample[i_0]).offset) >> uint64(uint64(32)) & uint64(0xffffffff)) >> uint64(uint64(8 * 0))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).offset & uint64(0xffffffff)) >> uint64(uint64(8 * 3))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).offset & uint64(0xffffffff)) >> uint64(uint64(8 * 2))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).offset & uint64(0xffffffff)) >> uint64(uint64(8 * 1))))
                *p_5
                p_5 = p_5 + 1
                *p_5 = uint8(uint8(uint64(unsafe(sample[i_0]).offset & uint64(0xffffffff)) >> uint64(uint64(8 * 0))))
                *p_5
                i_0 = i_0 + 1
            }
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        var ra_count : int = 0
        i_0 = 0
        i_0
        while (i_0 < samples_count) {
            ra_count = ra_count + unsafe(sample[i_0]).flag_random_access == 0 == 0
            ra_count
            i_0 = i_0 + 1
        }
        if (ra_count != samples_count) {
            stack_0 = stack_0 + 1
            *stack_0 = p_5
            *stack_0
            p_5 = p_5 + 4
            p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_stss >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_stss >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_stss >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_stss >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(ra_count >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(ra_count >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(ra_count >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(ra_count >> 8 * 0))
            *p_5
            i_0 = 0
            i_0
            while (i_0 < samples_count) {
                if (unsafe(sample[i_0]).flag_random_access != 0x0) {
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(i_0 + 1 >> 8 * 3))
                    *p_5
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(i_0 + 1 >> 8 * 2))
                    *p_5
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(i_0 + 1 >> 8 * 1))
                    *p_5
                    p_5 = p_5 + 1
                    *p_5 = uint8(uint8(i_0 + 1 >> 8 * 0))
                    *p_5
                }
                i_0 = i_0 + 1
            }
            stack_0 = stack_0 - 1
            stack_0
            unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack_0)[0])
            unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack_0)[1])
            unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack_0)[2])
            unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
            unsafe(cast<uint8?>(*stack_0)[3])
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        ntr_0 = ntr_0 + 1
    }
    if (mux_6.text_comment != null) {
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_udta >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_udta >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_udta >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_udta >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_meta >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_meta >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_meta >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_meta >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_hdlr >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_hdlr >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_hdlr >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_hdlr >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1835297138 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1835297138 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1835297138 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1835297138 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_ilst >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_ilst >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_ilst >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_ilst >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(BOX_ccmt) >> uint(uint(8 * 3))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(BOX_ccmt) >> uint(uint(8 * 2))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(BOX_ccmt) >> uint(uint(8 * 1))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(BOX_ccmt) >> uint(uint(8 * 0))))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_data >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_data >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_data >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_data >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(1 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        i_0 = 0
        i_0
        while (i_0 < int(strlen(mux_6.text_comment)) + 1) {
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(int(unsafe(mux_6.text_comment[i_0])) >> 8 * 0))
            *p_5
            i_0 = i_0 + 1
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
    }
    if (mux_6.enable_fragmentation != 0) {
        var tr_8 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_6.tracks.data)) + 0)
        var movie_duration : uint = get_duration(tr_8)
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mvex >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mvex >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mvex >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mvex >> 8 * 0))
        *p_5
        stack_0 = stack_0 + 1
        *stack_0 = p_5
        *stack_0
        p_5 = p_5 + 4
        p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mehd >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mehd >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mehd >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(BOX_mehd >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 3))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 2))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 1))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(0 >> 8 * 0))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(movie_duration) >> uint(uint(8 * 3))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(movie_duration) >> uint(uint(8 * 2))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(movie_duration) >> uint(uint(8 * 1))))
        *p_5
        p_5 = p_5 + 1
        *p_5 = uint8(uint8(uint(movie_duration) >> uint(uint(8 * 0))))
        *p_5
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
        ntr_0 = uint(uint(0))
        ntr_0
        while (ntr_0 < ntracks) {
            stack_0 = stack_0 + 1
            *stack_0 = p_5
            *stack_0
            p_5 = p_5 + 4
            p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_trex >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_trex >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_trex >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(BOX_trex >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(uint(ntr_0 + uint(1)) >> uint(uint(8 * 3))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(uint(ntr_0 + uint(1)) >> uint(uint(8 * 2))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(uint(ntr_0 + uint(1)) >> uint(uint(8 * 1))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(uint(ntr_0 + uint(1)) >> uint(uint(8 * 0))))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(1 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 3))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 2))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 1))
            *p_5
            p_5 = p_5 + 1
            *p_5 = uint8(uint8(0 >> 8 * 0))
            *p_5
            stack_0 = stack_0 - 1
            stack_0
            unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
            unsafe(cast<uint8?>(*stack_0)[0])
            unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
            unsafe(cast<uint8?>(*stack_0)[1])
            unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
            unsafe(cast<uint8?>(*stack_0)[2])
            unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
            unsafe(cast<uint8?>(*stack_0)[3])
            ntr_0 = ntr_0 + 1
        }
        stack_0 = stack_0 - 1
        stack_0
        unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
        unsafe(cast<uint8?>(*stack_0)[0])
        unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
        unsafe(cast<uint8?>(*stack_0)[1])
        unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
        unsafe(cast<uint8?>(*stack_0)[2])
        unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
        unsafe(cast<uint8?>(*stack_0)[3])
    }
    stack_0 = stack_0 - 1
    stack_0
    unsafe(cast<uint8?>(*stack_0)[0]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 3)))))
    unsafe(cast<uint8?>(*stack_0)[0])
    unsafe(cast<uint8?>(*stack_0)[1]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 2)))))
    unsafe(cast<uint8?>(*stack_0)[1])
    unsafe(cast<uint8?>(*stack_0)[2]) = uint8(uint8(int8(int64(p_5 - *stack_0) >> int64(int64(8 * 1)))))
    unsafe(cast<uint8?>(*stack_0)[2])
    unsafe(cast<uint8?>(*stack_0)[3]) = uint8(uint8(int8(p_5 - *stack_0)))
    unsafe(cast<uint8?>(*stack_0)[3])
    {
        if (uint(p_5 - base_2) <= index_bytes) {
        } else {
            c2da___assert_fail(unsafe(addr("(unsigned)(p - base) <= index_bytes"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1734), unsafe(addr("int mp4e_flush_index(MP4E_mux_t *)"[0])))
        }
    }
    err_11 = mux_6.write_callback(mux_6.write_pos, unsafe(unsafe(reinterpret<uint64>(base_2))), cast<size_t>(p_5 - base_2), mux_6.token)
    err_11
    mux_6.write_pos = int64(mux_6.write_pos + p_5 - base_2)
    mux_6.write_pos
    free(unsafe(unsafe(reinterpret<uint64>(base_2))))
    return err_11
}
[export]
def get_duration(var tr_9 : track_t const?) : uint {
    return sum_duration
}
[export]
def items_count(var v : minimp4_vector_t?) : int {
    return count
}
[export]
def od_size_of_size(var size_1 : int) : int {
    return size_of_size
}
var box_ftyp : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(24), uint8(102), uint8(116), uint8(121), uint8(112), uint8(109), uint8(112), uint8(52), uint8(50), uint8(0), uint8(0), uint8(0), uint8(0), uint8(109), uint8(112), uint8(52), uint8(50), uint8(105), uint8(115), uint8(111), uint8(109)]

[export]
def ue_bits(var bs : bit_reader_t?) : int {
    var clz : int
    var c2da_fresh4_minimp4 : int = 0
    if (clz) {
        c2da_fresh4_minimp4 = get_bits(bs, clz)
    } else {
        c2da_fresh4_minimp4 = uint(0)
    }
    val = int(uint(1 << clz - 1) + c2da_fresh4_minimp4)
    val
    return val
}
[export]
def get_bits(var bs_0 : bit_reader_t?; var n : int) : uint {
    var retval : uint = show_bits(bs_0, n)
    flush_bits(bs_0, n)
    return retval
}
[export]
def show_bits(var bs_1 : bit_reader_t?; var n_0 : int) : uint {
    var retval_0 : uint
    {
        if (n_0 > 0 && n_0 <= 16) {
        } else {
            c2da___assert_fail(unsafe(addr("n > 0 && n <= 16"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1794), unsafe(addr("unsigned int show_bits(bit_reader_t *, int)"[0])))
        }
    }
    retval_0 = uint(uint(uint(bs_1.cache) >> uint(uint(32 - n_0))))
    retval_0
    return retval_0
}
[export]
def flush_bits(var bs_2 : bit_reader_t?; var n_1 : int) {
    {
        if (n_1 >= 0 && n_1 <= 16) {
        } else {
            c2da___assert_fail(unsafe(addr("n >= 0 && n <= 16"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1801), unsafe(addr("void flush_bits(bit_reader_t *, int)"[0])))
        }
    }
    bs_2.cache = uint(bs_2.cache << n_1)
    bs_2.cache
    bs_2.cache_free_bits = bs_2.cache_free_bits + n_1
    bs_2.cache_free_bits
    if (bs_2.cache_free_bits >= 0) {
        bs_2.cache = uint(bs_2.cache | uint(uint(int(uint16(int(*bs_2.buf) << 8)) | int(*bs_2.buf) >> 8)) << uint(uint(bs_2.cache_free_bits)))
        bs_2.cache
        bs_2.buf = bs_2.buf + 1
        bs_2.buf
        bs_2.cache_free_bits = bs_2.cache_free_bits - 16
        bs_2.cache_free_bits
    }
}
[export]
def init_bits(var bs_3 : bit_reader_t?; var data_0 : uint64; var data_bytes_2 : uint) {
    bs_3.origin = unsafe(reinterpret<uint16 const?>(data_0))
    bs_3.origin
    bs_3.origin_bytes = uint(data_bytes_2)
    bs_3.origin_bytes
    set_pos_bits(bs_3, uint(0))
}
[export]
def set_pos_bits(var bs_4 : bit_reader_t?; var pos_bits : uint) {
    {
        if (int(pos_bits) >= 0) {
        } else {
            c2da___assert_fail(unsafe(addr("(int)pos_bits >= 0"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1821), unsafe(addr("void set_pos_bits(bit_reader_t *, unsigned int)"[0])))
        }
    }
    bs_4.buf = unsafe(bs_4.origin + pos_bits / uint(16))
    bs_4.buf
    bs_4.cache = uint(uint(0))
    bs_4.cache
    bs_4.cache_free_bits = 16
    bs_4.cache_free_bits
    flush_bits(bs_4, 0)
    flush_bits(bs_4, int(pos_bits & uint(15)))
}
[export]
def MP4E_set_pps(var mux_7 : MP4E_mux_t?; var track_id : int; var pps : uint64; var bytes_2 : int) : int {
    var tr_10 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_7.tracks.data)) + track_id)
    {
        if (uint(tr_10.info.track_media_kind) == uint(e_video)) {
        } else {
            c2da___assert_fail(unsafe(addr("tr->info.track_media_kind == e_video"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(929), unsafe(addr("int MP4E_set_pps(MP4E_mux_t *, int, const void *, int)"[0])))
        }
    }
    var c2da_fresh5_minimp4 : int = 0
    if (append_mem(unsafe(addr(tr_10.vpps)), pps, bytes_2)) {
        c2da_fresh5_minimp4 = 0
    } else {
        c2da_fresh5_minimp4 = -2
    }
    return c2da_fresh5_minimp4
}
[export]
def append_mem(var v_0 : minimp4_vector_t?; var mem : uint64; var bytes_3 : int) : int {
    unsafe(unsafe(addr(size_2[0]))[0]) = uint8(uint8(bytes_3 >> 8))
    unsafe(unsafe(addr(size_2[0]))[0])
    unsafe(unsafe(addr(size_2[0]))[1]) = uint8(uint8(bytes_3))
    unsafe(unsafe(addr(size_2[0]))[1])
    return minimp4_vector_put(v_0, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(size_2[0]))))), 2) != null && minimp4_vector_put(v_0, mem, bytes_3) != null
}
[export]
def MP4E_set_sps(var mux_8 : MP4E_mux_t?; var track_id_0 : int; var sps : uint64; var bytes_4 : int) : int {
    var tr_11 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_8.tracks.data)) + track_id_0)
    {
        if (uint(tr_11.info.track_media_kind) == uint(e_video)) {
        } else {
            c2da___assert_fail(unsafe(addr("tr->info.track_media_kind == e_video"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(922), unsafe(addr("int MP4E_set_sps(MP4E_mux_t *, int, const void *, int)"[0])))
        }
    }
    var c2da_fresh6_minimp4 : int = 0
    if (append_mem(unsafe(addr(tr_11.vsps)), sps, bytes_4)) {
        c2da_fresh6_minimp4 = 0
    } else {
        c2da_fresh6_minimp4 = -2
    }
    return c2da_fresh6_minimp4
}
[export]
def nal_put_esc(var d : uint8?; var s_0 : uint8 const?; var n_2 : int) : int {
    return j
}
[export]
def transcode_nalu(var h_6 : h264_sps_id_patcher_t?; var src : uint8 const?; var nalu_bytes : int; var dst : uint8?) : int {
    var old_id : int
    var bst : array<bit_reader_t> = [0]
    var bdt : array<bs_t> = [0]
    var bs_5 : array<bit_reader_t> = [0]
    var bd : array<bs_t> = [0]
    var payload_type_0 : int = int(unsafe(src[0])) & 31
    *dst = uint8(*src)
    *dst
    h264e_bs_init_bits(unsafe(addr(bd[0])), unsafe(unsafe(reinterpret<uint64>(unsafe(dst + 1)))))
    init_bits(unsafe(addr(bs_5[0])), unsafe(unsafe(reinterpret<uint64>(unsafe(src + 1)))), uint(nalu_bytes - 1))
    h264e_bs_init_bits(unsafe(addr(bdt[0])), unsafe(unsafe(reinterpret<uint64>(unsafe(dst + 1)))))
    init_bits(unsafe(addr(bst[0])), unsafe(unsafe(reinterpret<uint64>(unsafe(src + 1)))), uint(nalu_bytes - 1))
    if (payload_type_0 == 7) {
        unsafe(unsafe(addr(h_6.map_sps[0]))[old_id]) = id
        unsafe(unsafe(addr(h_6.map_sps[0]))[old_id])
        change_sps_id(unsafe(addr(bs_5[0])), unsafe(addr(bd[0])), id, unsafe(addr(old_id)))
    } elif (payload_type_0 == 8) {
        unsafe(unsafe(addr(h_6.map_pps[0]))[old_id]) = id_0
        unsafe(unsafe(addr(h_6.map_pps[0]))[old_id])
        patch_pps(h_6, unsafe(addr(bs_5[0])), unsafe(addr(bd[0])), id_0, unsafe(addr(old_id)))
    } elif (payload_type_0 == 1 || payload_type_0 == 2 || payload_type_0 == 5) {
        patch_slice_header(h_6, unsafe(addr(bs_5[0])), unsafe(addr(bd[0])))
    } else {
        memcpy(unsafe(unsafe(reinterpret<uint64>(dst))), unsafe(unsafe(reinterpret<uint64>(src))), uint64(nalu_bytes))
    }
    nalu_bytes = int(uint(1) + h264e_bs_byte_align(unsafe(addr(bd[0]))) / uint(8))
    nalu_bytes
    h264e_bs_flush(unsafe(addr(bd[0])))
    return nalu_bytes
}
[export]
def h264e_bs_flush(var bs_6 : bs_t?) {
    *bs_6.buf = uint(uint(uint(bs_6.cache) >> uint(uint(24)) & uint(255) | uint(bs_6.cache) >> uint(uint(8)) & uint(65280) | uint(bs_6.cache) << uint(uint(8)) & uint(16711680) | uint(bs_6.cache & uint(255)) << uint(uint(24))))
    *bs_6.buf
}
[export]
def h264e_bs_byte_align(var bs_7 : bs_t?) : uint {
    var pos : int = int(h264e_bs_get_pos_bits(bs_7))
    h264e_bs_put_bits(bs_7, uint(-pos & 7), uint(0))
    return uint(pos + -pos & 7)
}
[export]
def h264e_bs_get_pos_bits(var bs_8 : bs_t const?) : uint {
    var pos_bits_0 : uint = uint(bs_8.buf - bs_8.origin * int64(32))
    pos_bits_0 = uint(pos_bits_0 + uint(32 - bs_8.shift))
    pos_bits_0
    {
        if (int(pos_bits_0) >= 0) {
        } else {
            c2da___assert_fail(unsafe(addr("(int)pos_bits >= 0"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1908), unsafe(addr("unsigned int h264e_bs_get_pos_bits(const bs_t *)"[0])))
        }
    }
    return pos_bits_0
}
[export]
def h264e_bs_put_bits(var bs_9 : bs_t?; var n_3 : uint; var val_0 : uint) {
    {
        if (val_0 >> n_3 == 0) {
        } else {
            c2da___assert_fail(unsafe(addr("!(val >> n)"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1885), unsafe(addr("void h264e_bs_put_bits(bs_t *, unsigned int, unsigned int)"[0])))
        }
    }
    bs_9.shift = bs_9.shift - n_3
    bs_9.shift
    {
        if (uint(n_3) <= uint(32)) {
        } else {
            c2da___assert_fail(unsafe(addr("(unsigned)n <= 32"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1887), unsafe(addr("void h264e_bs_put_bits(bs_t *, unsigned int, unsigned int)"[0])))
        }
    }
    if (bs_9.shift < 0) {
        {
            if (-bs_9.shift < 32) {
            } else {
                c2da___assert_fail(unsafe(addr("-bs->shift < 32"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1890), unsafe(addr("void h264e_bs_put_bits(bs_t *, unsigned int, unsigned int)"[0])))
            }
        }
        bs_9.cache = uint(bs_9.cache | uint(val_0) >> uint(uint(-bs_9.shift)))
        bs_9.cache
        bs_9.buf = bs_9.buf + 1
        *bs_9.buf = uint(uint(uint(bs_9.cache) >> uint(uint(24)) & uint(255) | uint(bs_9.cache) >> uint(uint(8)) & uint(65280) | uint(bs_9.cache) << uint(uint(8)) & uint(16711680) | uint(bs_9.cache & uint(255)) << uint(uint(24))))
        *bs_9.buf
        bs_9.shift = 32 + bs_9.shift
        bs_9.shift
        bs_9.cache = uint(uint(0))
        bs_9.cache
    }
    bs_9.cache = uint(bs_9.cache | uint(val_0) << uint(uint(bs_9.shift)))
    bs_9.cache
}
[export]
def patch_slice_header(var h_7 : h264_sps_id_patcher_t?; var bs_10 : bit_reader_t?; var bd_0 : bs_t?) {
    var first_mb_in_slice : uint = uint(ue_bits(bs_10))
    var slice_type : uint = uint(ue_bits(bs_10))
    var pps_id : uint = uint(ue_bits(bs_10))
    pps_id = uint(uint(unsafe(unsafe(addr(h_7.map_pps[0]))[pps_id])))
    pps_id
    {
        if (pps_id <= uint(255)) {
        } else {
            c2da___assert_fail(unsafe(addr("pps_id <= 255"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(2116), unsafe(addr("void patch_slice_header(h264_sps_id_patcher_t *, bit_reader_t *, bs_t *)"[0])))
        }
    }
    h264e_bs_put_golomb(bd_0, first_mb_in_slice)
    h264e_bs_put_golomb(bd_0, slice_type)
    h264e_bs_put_golomb(bd_0, pps_id)
    copy_bits(bs_10, bd_0)
}
[export]
def copy_bits(var bs_11 : bit_reader_t?; var bd_1 : bs_t?) {
    bits = uint(get_bits(bs_11, bit_count))
    bits
    while (bit_count != 0 && ~bits & uint(1) != 0x0) {
        bits = uint(bits >> 1)
        bits
        bit_count = bit_count - 1
    }
    if (bit_count != 0) {
        h264e_bs_put_bits(bd_1, uint(bit_count), bits)
    }
}
[export]
def remaining_bits(var bs_12 : bit_reader_t const?) : int {
    return int(bs_12.origin_bytes * uint(8) - get_pos_bits(bs_12))
}
[export]
def get_pos_bits(var bs_13 : bit_reader_t const?) : uint {
    var pos_bits_1 : uint = uint(bs_13.buf - bs_13.origin) * uint(16)
    pos_bits_1 = uint(pos_bits_1 - uint(16 - bs_13.cache_free_bits))
    pos_bits_1
    {
        if (int(pos_bits_1) >= 0) {
        } else {
            c2da___assert_fail(unsafe(addr("(int)pos_bits >= 0"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(1837), unsafe(addr("unsigned int get_pos_bits(const bit_reader_t *)"[0])))
        }
    }
    return pos_bits_1
}
[export]
def h264e_bs_put_golomb(var bs_14 : bs_t?; var val_1 : uint) {
    var size_3 : int = 0
    var t : uint = val_1 + uint(1)
    var _dw_24811 : bool = true
    while (_dw_24811 || t) {
        _dw_24811 = false
        size_3 = size_3 + 1
        size_3
    }
    h264e_bs_put_bits(bs_14, uint(2 * size_3 - 1), val_1 + uint(1))
}
[export]
def patch_pps(var h_8 : h264_sps_id_patcher_t?; var bs_15 : bit_reader_t?; var bd_2 : bs_t?; var new_pps_id : int; var old_id_0 : int?) : int {
    var bytes_5 : int
    var pps_id_0 : uint = uint(ue_bits(bs_15))
    var sps_id : uint = uint(ue_bits(bs_15))
    *old_id_0 = int(pps_id_0)
    *old_id_0
    sps_id = uint(uint(unsafe(unsafe(addr(h_8.map_sps[0]))[sps_id])))
    sps_id
    pps_id_0 = uint(uint(new_pps_id))
    pps_id_0
    {
        if (sps_id <= uint(31)) {
        } else {
            c2da___assert_fail(unsafe(addr("sps_id <= 31"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(2096), unsafe(addr("int patch_pps(h264_sps_id_patcher_t *, bit_reader_t *, bs_t *, int, int *)"[0])))
        }
    }
    {
        if (pps_id_0 <= uint(255)) {
        } else {
            c2da___assert_fail(unsafe(addr("pps_id <= 255"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(2097), unsafe(addr("int patch_pps(h264_sps_id_patcher_t *, bit_reader_t *, bs_t *, int, int *)"[0])))
        }
    }
    h264e_bs_put_golomb(bd_2, pps_id_0)
    h264e_bs_put_golomb(bd_2, sps_id)
    copy_bits(bs_15, bd_2)
    bytes_5 = int(h264e_bs_byte_align(bd_2) / uint(8))
    bytes_5
    h264e_bs_flush(bd_2)
    return bytes_5
}
[export]
def find_mem_cache(var cache : uint64?; var cache_bytes : int?; var cache_size : int; var mem_0 : uint64; var bytes_6 : int) : int {
    i_6 = 0
    i_6
    while (i_6 < cache_size) {
        if (unsafe(cache_bytes[i_6]) == bytes_6 && memcmp(mem_0, unsafe(cache[i_6]), uint64(bytes_6)) == 0) {
            return i_6
        }
        i_6 = i_6 + 1
    }
    i_6 = 0
    i_6
    while (i_6 < cache_size) {
        if (unsafe(cache_bytes[i_6]) == 0) {
            unsafe(cache[i_6]) = malloc(uint64(bytes_6))
            unsafe(cache[i_6])
            if (unsafe(cache[i_6]) != null) {
                memcpy(unsafe(cache[i_6]), mem_0, uint64(bytes_6))
                unsafe(cache_bytes[i_6]) = bytes_6
                unsafe(cache_bytes[i_6])
            }
            return i_6
        }
        i_6 = i_6 + 1
    }
    return -1
}
[export]
def change_sps_id(var bs_16 : bit_reader_t?; var bd_3 : bs_t?; var new_id : int; var old_id_1 : int?) : int {
    sps_id_0 = uint(uint(ue_bits(bs_16)))
    sps_id_0
    *old_id_1 = int(sps_id_0)
    *old_id_1
    sps_id_0 = uint(uint(new_id))
    sps_id_0
    {
        if (sps_id_0 <= uint(31)) {
        } else {
            c2da___assert_fail(unsafe(addr("sps_id <= 31"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(2076), unsafe(addr("int change_sps_id(bit_reader_t *, bs_t *, int, int *)"[0])))
        }
    }
    h264e_bs_put_golomb(bd_3, sps_id_0)
    copy_bits(bs_16, bd_3)
    bytes_7 = uint(h264e_bs_byte_align(bd_3) / uint(8))
    bytes_7
    h264e_bs_flush(bd_3)
    return int(bytes_7)
}
[export]
def h264e_bs_init_bits(var bs_17 : bs_t?; var data_1 : uint64) {
    bs_17.origin = unsafe(reinterpret<uint?>(data_1))
    bs_17.origin
    bs_17.buf = bs_17.origin
    bs_17.buf
    bs_17.shift = 32
    bs_17.shift
    bs_17.cache = uint(uint(0))
    bs_17.cache
}
[export]
def remove_nal_escapes(var dst_0 : uint8?; var src_0 : uint8 const?; var h264_data_bytes : int) : int {
    return i_8
}
[export]
def mp4_h265_write_nal(var h_9 : mp4_h26x_writer_t?; var nal_0 : uint8 const?; var sizeof_nal_0 : int; var timeStamp90kHz_next_0 : uint) : int {
    var payload_type_1 : int = int(unsafe(nal_0[0])) >> 1 & 63
    var is_intra : int = payload_type_1 >= 16 && payload_type_1 <= 21
    var err_14 : int = 0
    if (is_intra != 0 && h_9.need_sps == 0 && h_9.need_pps == 0 && h_9.need_vps == 0) {
        h_9.need_idr = 0
        h_9.need_idr
    }
    if (payload_type_1 == 32) {
        MP4E_set_vps(h_9.mux, h_9.mux_track_id, unsafe(unsafe(reinterpret<uint64>(nal_0))), sizeof_nal_0)
    } elif (payload_type_1 == 33) {
        MP4E_set_sps(h_9.mux, h_9.mux_track_id, unsafe(unsafe(reinterpret<uint64>(nal_0))), sizeof_nal_0)
    } elif (payload_type_1 == 34) {
        MP4E_set_pps(h_9.mux, h_9.mux_track_id, unsafe(unsafe(reinterpret<uint64>(nal_0))), sizeof_nal_0)
    } else {
        if (h_9.need_vps != 0 || h_9.need_sps != 0 || h_9.need_pps != 0 || h_9.need_idr != 0) {
            return -1
        }
    }
    return err_14
}
[export]
def MP4E_set_vps(var mux_9 : MP4E_mux_t?; var track_id_1 : int; var vps : uint64; var bytes_8 : int) : int {
    var tr_12 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_9.tracks.data)) + track_id_1)
    {
        if (uint(tr_12.info.track_media_kind) == uint(e_video)) {
        } else {
            c2da___assert_fail(unsafe(addr("tr->info.track_media_kind == e_video"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(915), unsafe(addr("int MP4E_set_vps(MP4E_mux_t *, int, const void *, int)"[0])))
        }
    }
    var c2da_fresh8_minimp4 : int = 0
    if (append_mem(unsafe(addr(tr_12.vvps)), vps, bytes_8)) {
        c2da_fresh8_minimp4 = 0
    } else {
        c2da_fresh8_minimp4 = -2
    }
    return c2da_fresh8_minimp4
}
[export]
def find_nal_unit(var h264_data : uint8 const?; var h264_data_bytes_0 : int; var pnal_unit_bytes : int?) : uint8 const? {
    var eof_0 : uint8 const? = unsafe(h264_data + h264_data_bytes_0)
    var zcount : int
    var start : uint8 const? = find_start_code(h264_data, h264_data_bytes_0, unsafe(addr(zcount)))
    var stop : uint8 const? = start
    if (start != null) {
        stop = find_start_code(start, int(eof_0 - start), unsafe(addr(zcount)))
        stop
        while (stop > start && unsafe(stop[-1]) == 0) {
            stop = stop - 1
            stop
        }
    }
    *pnal_unit_bytes = int(stop - start - int64(zcount))
    *pnal_unit_bytes
    return start
}
[export]
def find_start_code(var h264_data_0 : uint8 const?; var h264_data_bytes_1 : int; var zcount_0 : int?) : uint8 const? {
    var eof_1 : uint8 const? = unsafe(h264_data_0 + h264_data_bytes_1)
    var p_8 : uint8 const? = h264_data_0
    var _dw_26316 : bool = true
    while (_dw_26316 || p_8 < eof_1) {
        _dw_26316 = false
        var zero_cnt_0 : int = 1
        p_8 = c2da_fresh9_minimp4
        p_8
        while (unsafe(p_8 + zero_cnt_0) < eof_1 && unsafe(p_8[zero_cnt_0]) == 0) {
            zero_cnt_0 = zero_cnt_0 + 1
            zero_cnt_0
        }
        if (zero_cnt_0 >= 2 && int(unsafe(p_8[zero_cnt_0])) == 1) {
            *zcount_0 = zero_cnt_0 + 1
            *zcount_0
            return unsafe(unsafe(p_8 + zero_cnt_0) + 1)
        }
        p_8 = p_8 + zero_cnt_0
        p_8
    }
    *zcount_0 = 0
    *zcount_0
    return eof_1
}
[export]
def MP4D_open(var mp4 : MP4D_demux_t?; var read_callback : function?; var token : uint64; var file_size : int64) : int {
    var depth : int = 0
    var eof_flag : int = 0
    memset(unsafe(unsafe(reinterpret<uint64>(mp4))), 0, 4)
    mp4.read_callback = read_callback
    mp4.read_callback
    mp4.token = token
    mp4.token
    mp4.read_size = int64(file_size)
    mp4.read_size
    unsafe(unsafe(addr(stack_1[0]))[0]).format = cast<boxtype_t>(BOX_ATOM)
    unsafe(unsafe(addr(stack_1[0]))[0]).format
    unsafe(unsafe(addr(stack_1[0]))[0]).bytes = uint64(uint64(0))
    unsafe(unsafe(addr(stack_1[0]))[0]).bytes
    var _dw_26515 : bool = true
    while (_dw_26515 || eof_flag == 0) {
        _dw_26515 = false
        var FullAtomVersionAndFlags : uint = uint(0)
        var payload_bytes : uint64
        var box_bytes : uint64
        var box_name : uint
        var ptag : uint8?? = null
        var read_bytes : int = 0
        if (uint(unsafe(unsafe(addr(stack_1[0]))[depth]).format) == uint(BOX_ATOM)) {
            box_bytes = uint64(uint64(minimp4_read(mp4, 4, unsafe(addr(eof_flag)))))
            box_bytes
            label 52577:
            if (eof_flag != 0) {
                break
            }
            if (box_bytes >= uint64(2) && box_bytes < uint64(8)) {
                if (depth == 0) {
                    break
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
            box_name = uint(minimp4_read(mp4, 4, unsafe(addr(eof_flag))))
            box_name
            read_bytes = 8
            read_bytes
            if (box_bytes == uint64(0) || box_bytes == uint64(0xffffffff)) {
                box_bytes = uint64(~uint64(0))
                box_bytes
            }
            payload_bytes = uint64(box_bytes - uint64(8))
            payload_bytes
            if (box_bytes == uint64(1)) {
                box_bytes = uint64(uint64(minimp4_read(mp4, 4, unsafe(addr(eof_flag)))))
                box_bytes
                if (box_bytes != 0x0) {
                    if (depth == 0) {
                        break
                    } else {
                        MP4D_close(mp4)
                        return 0
                    }
                }
                box_bytes = uint64(uint64(minimp4_read(mp4, 4, unsafe(addr(eof_flag)))))
                box_bytes
                if (box_bytes < uint64(16)) {
                    if (depth == 0) {
                        break
                    } else {
                        MP4D_close(mp4)
                        return 0
                    }
                }
                payload_bytes = uint64(box_bytes - uint64(16))
                payload_bytes
            }
            i_9 = uint(uint(0))
            i_9
            while (uint64(i_9) < 4 / 4) {
                if (box_name == unsafe(unsafe(addr(g_fullbox[0]))[i_9]).name) {
                    FullAtomVersionAndFlags = uint(read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
                    FullAtomVersionAndFlags
                    read_bytes = read_bytes + 4
                    read_bytes
                    if (box_name == uint(BOX_meta)) {
                        if (FullAtomVersionAndFlags >= uint(8) && uint64(FullAtomVersionAndFlags) < payload_bytes) {
                            if (box_bytes > unsafe(unsafe(addr(stack_1[0]))[depth]).bytes) {
                                if (depth == 0) {
                                    break
                                } else {
                                    MP4D_close(mp4)
                                    return 0
                                }
                            }
                            unsafe(unsafe(addr(stack_1[0]))[depth]).bytes = uint64(unsafe(unsafe(addr(stack_1[0]))[depth]).bytes - box_bytes)
                            unsafe(unsafe(addr(stack_1[0]))[depth]).bytes
                            depth = depth + 1
                            depth
                            unsafe(unsafe(addr(stack_1[0]))[depth]).bytes = uint64(payload_bytes + uint64(4))
                            unsafe(unsafe(addr(stack_1[0]))[depth]).bytes
                            unsafe(unsafe(addr(stack_1[0]))[depth]).format = cast<boxtype_t>(BOX_ATOM)
                            unsafe(unsafe(addr(stack_1[0]))[depth]).format
                            box_bytes = uint64(uint64(FullAtomVersionAndFlags))
                            box_bytes
                            goto label 52577
                        }
                    }
                    if (uint(FullAtomVersionAndFlags) >> uint(uint(24)) > unsafe(unsafe(addr(g_fullbox[0]))[i_9]).max_version) {
                        if (depth == 0) {
                            break
                        } else {
                            MP4D_close(mp4)
                            return 0
                        }
                    }
                    if (unsafe(unsafe(addr(g_fullbox[0]))[i_9]).use_track_flag != 0x0 && tr_13 == null) {
                        if (depth == 0) {
                            break
                        } else {
                            MP4D_close(mp4)
                            return 0
                        }
                    }
                }
                i_9 = i_9 + 1
            }
        } else {
            payload_bytes = uint64(uint64(0))
            payload_bytes
            box_bytes = uint64(uint64(1))
            box_bytes
            var _dw_30484 : bool = true
            while (_dw_30484 || val_2 & 128) {
                _dw_30484 = false
                val_2 = int(minimp4_read(mp4, 1, unsafe(addr(eof_flag))))
                val_2
                read_bytes = read_bytes + 1
                read_bytes
                if (eof_flag != 0) {
                    if (depth == 0) {
                        break
                    } else {
                        MP4D_close(mp4)
                        return 0
                    }
                }
                payload_bytes = uint64(uint64(payload_bytes) << uint64(uint64(7)) | uint64(val_2 & 127))
                payload_bytes
                box_bytes = box_bytes + 1
                box_bytes
            }
            box_bytes = uint64(box_bytes + payload_bytes)
            box_bytes
        }
        if (depth != 0) {
            {
                if (box_bytes > uint64(0)) {
                } else {
                    c2da___assert_fail(unsafe(addr("box_bytes > 0"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(2790), unsafe(addr("int MP4D_open(MP4D_demux_t *, int (*)(int64_t, void *, size_t, void *), void *, int64_t)"[0])))
                }
            }
            if (box_bytes > unsafe(unsafe(addr(stack_1[0]))[depth]).bytes) {
                box_bytes = uint64(unsafe(unsafe(addr(stack_1[0]))[depth]).bytes)
                box_bytes
                box_name = uint(uint(0))
                box_name
                payload_bytes = uint64(box_bytes - uint64(read_bytes))
                payload_bytes
            }
            unsafe(unsafe(addr(stack_1[0]))[depth]).bytes = uint64(unsafe(unsafe(addr(stack_1[0]))[depth]).bytes - box_bytes)
            unsafe(unsafe(addr(stack_1[0]))[depth]).bytes
        }
        if (box_name == uint(BOX_stz2) || box_name == uint(BOX_stsz)) {
            var size_4 : int = 0
            var sample_size : uint = read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag)))
            tr_13.sample_count = uint(read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
            tr_13.sample_count
            tr_13.entry_size = unsafe(reinterpret<uint?>(malloc(uint64(tr_13.sample_count * uint(4)))))
            tr_13.entry_size
            if (tr_13.entry_size == null) {
                if (depth == 0) {
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
            i_9 = uint(uint(0))
            i_9
            while (i_9 < tr_13.sample_count) {
                if (box_name == uint(BOX_stsz)) {
                    var c2da_fresh10_minimp4 : int = 0
                    if (sample_size) {
                        c2da_fresh10_minimp4 = sample_size
                    } else {
                        c2da_fresh10_minimp4 = read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag)))
                    }
                    unsafe(tr_13.entry_size[i_9]) = uint(c2da_fresh10_minimp4)
                    unsafe(tr_13.entry_size[i_9])
                } else {
                    if (sample_size & uint(255) == uint(16)) {
                        unsafe(tr_13.entry_size[i_9]) = uint(read_payload(mp4, uint(2), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
                        unsafe(tr_13.entry_size[i_9])
                    } elif (sample_size & uint(255) == uint(8)) {
                        unsafe(tr_13.entry_size[i_9]) = uint(read_payload(mp4, uint(1), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
                        unsafe(tr_13.entry_size[i_9])
                    } elif (sample_size & uint(255) == uint(4)) {
                        if (i_9 & uint(1) != 0x0) {
                            unsafe(tr_13.entry_size[i_9]) = uint(uint(size_4 & 15))
                            unsafe(tr_13.entry_size[i_9])
                        } else {
                            size_4 = int(read_payload(mp4, uint(1), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
                            size_4
                            unsafe(tr_13.entry_size[i_9]) = uint(uint(size_4 >> 4))
                            unsafe(tr_13.entry_size[i_9])
                        }
                    }
                }
                i_9 = i_9 + 1
            }
        } elif (box_name == uint(BOX_stsc)) {
            tr_13.sample_to_chunk_count = uint(read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
            tr_13.sample_to_chunk_count
        } elif (box_name == uint(BOX_stts)) {
            var count_0 : uint = read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag)))
            tr_13.duration = unsafe(reinterpret<uint?>(malloc(uint64(ts_count * uint(4)))))
            tr_13.duration
            if (tr_13.duration == null) {
                if (depth == 0) {
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
            i_9 = uint(uint(0))
            i_9
            while (i_9 < count_0) {
                var sc : uint = read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag)))
                j_1 = uint(uint(0))
                j_1
                while (j_1 < sc) {
                    unsafe(tr_13.duration[k]) = uint(uint(d_0))
                    unsafe(tr_13.duration[k])
                    k = k + 1
                    unsafe(tr_13.timestamp[k]) = uint(ts)
                    unsafe(tr_13.timestamp[k])
                    ts = uint(ts + uint(d_0))
                    ts
                    j_1 = j_1 + 1
                }
                i_9 = i_9 + 1
            }
        } elif (box_name == uint(BOX_ctts)) {
            var count_1 : uint = read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag)))
            i_9 = uint(uint(0))
            i_9
            while (i_9 < count_1) {
                var sc_0 : int = int(read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
                var d_1 : int = int(read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
                sc_0
                d_1
                i_9 = i_9 + 1
            }
        } elif (box_name == uint(BOX_stco) || box_name == uint(BOX_co64)) {
            tr_13.chunk_count = uint(read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
            tr_13.chunk_count
        } elif (box_name == uint(BOX_mvhd)) {
            var t_0 : uint64 = c2da_fresh13_minimp4
            my_fseek(mp4, t_0, unsafe(addr(eof_flag)))
            payload_bytes = uint64(payload_bytes - t_0)
            payload_bytes
        } elif (box_name == uint(BOX_mdhd)) {
            var t_1 : uint64 = c2da_fresh16_minimp4
            my_fseek(mp4, t_1, unsafe(addr(eof_flag)))
            payload_bytes = uint64(payload_bytes - t_1)
            payload_bytes
        } elif (box_name == uint(BOX_hdlr)) {
            if (tr_13 != null) {
                var t_2 : uint64 = c2da_fresh17_minimp4
                my_fseek(mp4, t_2, unsafe(addr(eof_flag)))
                payload_bytes = uint64(payload_bytes - t_2)
                payload_bytes
                tr_13.handler_type = uint(read_payload(mp4, uint(4), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag))))
                tr_13.handler_type
            }
        } elif (box_name == uint(BOX_btrt)) {
            if (tr_13 == null) {
                if (depth == 0) {
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
        } elif (box_name == BOX_calb) {
            ptag = unsafe(addr(mp4.tag.album))
            ptag
        } elif (box_name == BOX_cART) {
            ptag = unsafe(addr(mp4.tag.artist))
            ptag
        } elif (box_name == BOX_cnam) {
            ptag = unsafe(addr(mp4.tag.title))
            ptag
        } elif (box_name == BOX_cday) {
            ptag = unsafe(addr(mp4.tag.year))
            ptag
        } elif (box_name == BOX_ccmt) {
            ptag = unsafe(addr(mp4.tag.comment))
            ptag
        } elif (box_name == BOX_cgen) {
            ptag = unsafe(addr(mp4.tag.genre))
            ptag
        } elif (box_name == uint(BOX_stsd)) {
            var t_3 : uint64 = c2da_fresh18_minimp4
            my_fseek(mp4, t_3, unsafe(addr(eof_flag)))
            payload_bytes = uint64(payload_bytes - t_3)
            payload_bytes
        } elif (box_name == uint(BOX_mp4s)) {
            if (tr_13 == null) {
                if (depth == 0) {
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
        } elif (box_name == uint(BOX_mp4a)) {
            if (tr_13 == null) {
                if (depth == 0) {
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
        } elif (box_name == uint(BOX_avc1) || box_name == uint(BOX_mp4v)) {
            if (tr_13 == null) {
                if (depth == 0) {
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
        } elif (box_name == uint(BOX_avcC)) {
            tr_13.object_type_indication = uint(uint(33))
            tr_13.object_type_indication
        } elif (box_name == uint(OD_ESD)) {
            var flags_0 : uint = read_payload(mp4, uint(3), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag)))
            if (flags_0 & uint(128) != 0x0) {
                var t_4 : uint64 = c2da_fresh19_minimp4
                my_fseek(mp4, t_4, unsafe(addr(eof_flag)))
                payload_bytes = uint64(payload_bytes - t_4)
                payload_bytes
            }
            if (flags_0 & uint(64) != 0x0) {
                var bytecount : uint = read_payload(mp4, uint(1), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag)))
                var t_5 : uint64 = c2da_fresh20_minimp4
                my_fseek(mp4, t_5, unsafe(addr(eof_flag)))
                payload_bytes = uint64(payload_bytes - t_5)
                payload_bytes
            }
            if (flags_0 & uint(32) != 0x0) {
                var t_6 : uint64 = c2da_fresh21_minimp4
                my_fseek(mp4, t_6, unsafe(addr(eof_flag)))
                payload_bytes = uint64(payload_bytes - t_6)
                payload_bytes
            }
        } elif (box_name == uint(OD_DCD)) {
            {
                if (tr_13 != null) {
                } else {
                    c2da___assert_fail(unsafe(addr("tr"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(3094), unsafe(addr("int MP4D_open(MP4D_demux_t *, int (*)(int64_t, void *, size_t, void *), void *, int64_t)"[0])))
                }
            }
        } elif (box_name == uint(OD_DSI)) {
            {
                if (tr_13 != null) {
                } else {
                    c2da___assert_fail(unsafe(addr("tr"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(3106), unsafe(addr("int MP4D_open(MP4D_demux_t *, int (*)(int64_t, void *, size_t, void *), void *, int64_t)"[0])))
                }
            }
        } else {
        }
        if (ptag != null && *ptag == null && payload_bytes > uint64(16)) {
            var t_7 : uint64 = c2da_fresh22_minimp4
            my_fseek(mp4, t_7, unsafe(addr(eof_flag)))
            payload_bytes = uint64(payload_bytes - t_7)
            payload_bytes
            *ptag = unsafe(reinterpret<uint8?>(malloc(uint64(uint(payload_bytes) + uint(1)))))
            *ptag
            if (*ptag == null) {
                if (depth == 0) {
                    break
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
            i_9 = uint(uint(0))
            i_9
            while (payload_bytes != uint64(0)) {
                unsafe(*ptag[i_9]) = uint8(uint8(read_payload(mp4, uint(1), unsafe(addr(payload_bytes)), unsafe(addr(eof_flag)))))
                unsafe(*ptag[i_9])
                i_9 = i_9 + 1
            }
            unsafe(*ptag[i_9]) = uint8(uint8(0))
            unsafe(*ptag[i_9])
        }
        if (box_name == uint(BOX_trak)) {
            var mem_1 : uint64 = realloc(unsafe(unsafe(reinterpret<uint64>(mp4.track))), uint64(mp4.track_count + uint(1)) * 4)
            if (mem_1 == null) {
                if (depth == 0) {
                    break
                } else {
                    MP4D_close(mp4)
                    return 0
                }
            }
            mp4.track = unsafe(reinterpret<MP4D_track_t?>(mem_1))
            mp4.track
            mp4.track_count = mp4.track_count + 1
            tr_13 = unsafe(mp4.track + mp4.track_count)
            tr_13
            memset(unsafe(unsafe(reinterpret<uint64>(tr_13))), 0, 4)
        } else {
            if (box_name == uint(BOX_meta)) {
                tr_13 = null
                tr_13
            }
        }
        i_9 = uint(uint(0))
        i_9
        while (uint64(i_9) < 4 / 4) {
            if (box_name == unsafe(unsafe(addr(g_envelope_box[0]))[i_9]).name) {
                if (depth >= 64) {
                    if (depth == 0) {
                        break
                    } else {
                        MP4D_close(mp4)
                        return 0
                    }
                }
                unsafe(unsafe(addr(stack_1[0]))[depth]).bytes = uint64(payload_bytes)
                unsafe(unsafe(addr(stack_1[0]))[depth]).bytes
                unsafe(unsafe(addr(stack_1[0]))[depth]).format = unsafe(unsafe(addr(g_envelope_box[0]))[i_9]).type_0
                unsafe(unsafe(addr(stack_1[0]))[depth]).format
                break
            }
            i_9 = i_9 + 1
        }
        if (uint64(i_9) == 4 / 4) {
            if (payload_bytes > uint64(file_size)) {
                eof_flag = 1
                eof_flag
            } else {
                var t_8 : uint64 = c2da_fresh23_minimp4
                my_fseek(mp4, t_8, unsafe(addr(eof_flag)))
                payload_bytes = uint64(payload_bytes - t_8)
                payload_bytes
            }
        }
        while (depth > 0 && unsafe(unsafe(addr(stack_1[0]))[depth]).bytes == 0) {
            depth = depth - 1
            depth
        }
    }
    if (mp4.track_count == 0) {
        MP4D_close(mp4)
        return 0
    }
    return 1
}
[export]
def MP4D_close(var mp4_0 : MP4D_demux_t?) {
    while (mp4_0.track_count != 0x0) {
        var tr_14 : MP4D_track_t? = unsafe(mp4_0.track + mp4_0.track_count)
        if (tr_14.entry_size != null) {
            free(unsafe(unsafe(reinterpret<uint64>(tr_14.entry_size))))
            tr_14.entry_size = null
            tr_14.entry_size
        }
        if (tr_14.timestamp != null) {
            free(unsafe(unsafe(reinterpret<uint64>(tr_14.timestamp))))
            tr_14.timestamp = null
            tr_14.timestamp
        }
        if (tr_14.duration != null) {
            free(unsafe(unsafe(reinterpret<uint64>(tr_14.duration))))
            tr_14.duration = null
            tr_14.duration
        }
        if (tr_14.sample_to_chunk != null) {
            free(unsafe(unsafe(reinterpret<uint64>(tr_14.sample_to_chunk))))
            tr_14.sample_to_chunk = null
            tr_14.sample_to_chunk
        }
        if (tr_14.chunk_offset != null) {
            free(unsafe(unsafe(reinterpret<uint64>(tr_14.chunk_offset))))
            tr_14.chunk_offset = null
            tr_14.chunk_offset
        }
        if (tr_14.dsi != null) {
            free(unsafe(unsafe(reinterpret<uint64>(tr_14.dsi))))
            tr_14.dsi = null
            tr_14.dsi
        }
    }
    if (mp4_0.track != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mp4_0.track))))
        mp4_0.track = null
        mp4_0.track
    }
    if (mp4_0.tag.title != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mp4_0.tag.title))))
        mp4_0.tag.title = null
        mp4_0.tag.title
    }
    if (mp4_0.tag.artist != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mp4_0.tag.artist))))
        mp4_0.tag.artist = null
        mp4_0.tag.artist
    }
    if (mp4_0.tag.album != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mp4_0.tag.album))))
        mp4_0.tag.album = null
        mp4_0.tag.album
    }
    if (mp4_0.tag.year != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mp4_0.tag.year))))
        mp4_0.tag.year = null
        mp4_0.tag.year
    }
    if (mp4_0.tag.comment != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mp4_0.tag.comment))))
        mp4_0.tag.comment = null
        mp4_0.tag.comment
    }
    if (mp4_0.tag.genre != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mp4_0.tag.genre))))
        mp4_0.tag.genre = null
        mp4_0.tag.genre
    }
}
[export]
def my_fseek(var mp4_1 : MP4D_demux_t?; var pos_0 : uint64; var eof_flag_0 : int?) {
    mp4_1.read_pos = int64(mp4_1.read_pos + pos_0)
    mp4_1.read_pos
    if (mp4_1.read_pos >= mp4_1.read_size) {
        *eof_flag_0 = 1
        *eof_flag_0
    }
}
[export]
def read_payload(var mp4_2 : MP4D_demux_t?; var nb : uint; var payload_bytes_0 : uint64?; var eof_flag_1 : int?) : uint {
    if (*payload_bytes_0 < uint64(nb)) {
        *eof_flag_1 = 1
        *eof_flag_1
        nb = uint(uint(int(*payload_bytes_0)))
        nb
    }
    *payload_bytes_0 = uint64(*payload_bytes_0 - uint64(nb))
    *payload_bytes_0
    return minimp4_read(mp4_2, int(nb), eof_flag_1)
}
[export]
def minimp4_read(var mp4_3 : MP4D_demux_t?; var nb_0 : int; var eof_flag_2 : int?) : uint {
    var v_1 : uint = uint(0)
    var last_byte : int
    if (nb_0 == 4) {
        v_1 = uint(uint(v_1) << uint(uint(8)) | uint(minimp4_fgets(mp4_3)))
        v_1
    } elif (nb_0 == 3) {
        v_1 = uint(uint(v_1) << uint(uint(8)) | uint(minimp4_fgets(mp4_3)))
        v_1
    } elif (nb_0 == 2) {
        v_1 = uint(uint(v_1) << uint(uint(8)) | uint(minimp4_fgets(mp4_3)))
        v_1
    } else {
    }
    if (last_byte < 0) {
        *eof_flag_2 = 1
        *eof_flag_2
    }
    return v_1
}
[export]
def minimp4_fgets(var mp4_4 : MP4D_demux_t?) : int {
    mp4_4.read_pos = mp4_4.read_pos + 1
    mp4_4.read_pos
    return int(c)
}
[export]
def MP4D_frame_offset(var mp4_5 : MP4D_demux_t const?; var ntrack : uint; var nsample : uint; var frame_bytes : uint?; var timestamp : uint?; var duration_4 : uint?) : uint64 {
    var tr_15 : MP4D_track_t? = unsafe(mp4_5.track + ntrack)
    var ns : uint
    var nchunk : int = sample_to_chunk(tr_15, nsample, unsafe(addr(ns)))
    offset = uint64(unsafe(tr_15.chunk_offset[nchunk]))
    offset
    while (ns < nsample) {
        offset = uint64(offset + uint64(unsafe(tr_15.entry_size[ns])))
        offset
        ns = ns + 1
    }
    *frame_bytes = uint(unsafe(tr_15.entry_size[ns]))
    *frame_bytes
    if (timestamp != null) {
        *timestamp = uint(unsafe(tr_15.timestamp[ns]))
        *timestamp
    }
    if (duration_4 != null) {
        *duration_4 = uint(unsafe(tr_15.duration[ns]))
        *duration_4
    }
    return offset
}
[export]
def sample_to_chunk(var tr_16 : MP4D_track_t?; var nsample_0 : uint; var nfirst_sample_in_chunk : uint?) : int {
    var chunk_group : uint = uint(0)
    var nc : uint
    var sum : uint = uint(0)
    *nfirst_sample_in_chunk = uint(uint(0))
    *nfirst_sample_in_chunk
    if (tr_16.chunk_count <= uint(1)) {
        return 0
    }
    nc = uint(uint(0))
    nc
    while (nc < tr_16.chunk_count) {
        if (chunk_group + uint(1) < tr_16.sample_to_chunk_count && nc + uint(1) == unsafe(tr_16.sample_to_chunk[chunk_group + uint(1)]).first_chunk) {
            chunk_group = chunk_group + 1
            chunk_group
        }
        sum = uint(sum + unsafe(tr_16.sample_to_chunk[chunk_group]).samples_per_chunk)
        sum
        if (nsample_0 < sum) {
            return int(nc)
        }
        *nfirst_sample_in_chunk = uint(sum)
        *nfirst_sample_in_chunk
        nc = nc + 1
    }
    return -1
}
[export]
def MP4D_read_sps(var mp4_6 : MP4D_demux_t const?; var ntrack_0 : uint; var nsps : int; var sps_bytes : int?) : uint64 {
    return MP4D_read_spspps(mp4_6, ntrack_0, 0, nsps, sps_bytes)
}
[export]
def MP4D_read_spspps(var mp4_7 : MP4D_demux_t const?; var ntrack_1 : uint; var pps_flag : int; var nsps_0 : int; var sps_bytes_0 : int?) : uint64 {
    var sps_count : int
    var skip_bytes : int
    var bytepos : int = 0
    var p_9 : uint8? = unsafe(mp4_7.track[ntrack_1]).dsi
    if (ntrack_1 >= mp4_7.track_count) {
        return null
    }
    if (unsafe(mp4_7.track[ntrack_1]).object_type_indication != uint(33)) {
        return null
    }
    if (pps_flag != 0) {
        bytepos = bytepos + 1
        sps_count = int(unsafe(p_9[bytepos]))
        sps_count
        skip_bytes = skip_spspps(unsafe(p_9 + bytepos), int(unsafe(mp4_7.track[ntrack_1]).dsi_bytes - uint(bytepos)), sps_count)
        skip_bytes
        if (skip_bytes < 0) {
            return null
        }
        bytepos = bytepos + skip_bytes
        bytepos
    }
    bytepos = bytepos + 1
    sps_count = int(unsafe(p_9[bytepos]))
    sps_count
    if (nsps_0 >= sps_count) {
        return null
    }
    skip_bytes = skip_spspps(unsafe(p_9 + bytepos), int(unsafe(mp4_7.track[ntrack_1]).dsi_bytes - uint(bytepos)), nsps_0)
    skip_bytes
    if (skip_bytes < 0) {
        return null
    }
    bytepos = bytepos + skip_bytes
    bytepos
    *sps_bytes_0 = int(unsafe(p_9[bytepos])) * 256 + int(unsafe(p_9[bytepos + 1]))
    *sps_bytes_0
    return unsafe(unsafe(reinterpret<uint64>(unsafe(unsafe(p_9 + bytepos) + 2))))
}
[export]
def skip_spspps(var p_10 : uint8 const?; var nbytes : int; var nskip : int) : int {
    return k_0
}
[export]
def MP4D_read_pps(var mp4_8 : MP4D_demux_t const?; var ntrack_2 : uint; var npps : int; var pps_bytes : int?) : uint64 {
    return MP4D_read_spspps(mp4_8, ntrack_2, 1, npps, pps_bytes)
}
[export]
def MP4E_open(var sequential_mode_flag : int; var enable_fragmentation : int; var token_0 : uint64; var write_callback : function?) : MP4E_mux_t? {
    if (write_callback(int64(0), unsafe(unsafe(reinterpret<uint64>(unsafe(addr(box_ftyp[0]))))), 4, token_0) != 0) {
        return null
    }
    var mux_10 : MP4E_mux_t? = unsafe(reinterpret<MP4E_mux_t?>(malloc(4)))
    if (mux_10 == null) {
        return mux_10
    }
    mux_10.sequential_mode_flag = sequential_mode_flag != 0 || enable_fragmentation != 0
    mux_10.sequential_mode_flag
    mux_10.enable_fragmentation = enable_fragmentation
    mux_10.enable_fragmentation
    mux_10.fragments_count = 0
    mux_10.fragments_count
    mux_10.write_callback = write_callback
    mux_10.write_callback
    mux_10.token = token_0
    mux_10.token
    mux_10.text_comment = null
    mux_10.text_comment
    mux_10.write_pos = int64(int64(4))
    mux_10.write_pos
    if (mux_10.sequential_mode_flag == 0) {
        if (mux_10.write_callback(mux_10.write_pos, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(box_ftyp[0]))))), cast<size_t>(8), mux_10.token) != 0) {
            free(unsafe(unsafe(reinterpret<uint64>(mux_10))))
            return null
        }
        mux_10.write_pos = int64(mux_10.write_pos + int64(16))
        mux_10.write_pos
    }
    minimp4_vector_init(unsafe(addr(mux_10.tracks)), int(uint64(2) * 4))
    return mux_10
}
[export]
def MP4E_close(var mux_11 : MP4E_mux_t?) : int {
    var err_15 : int = 0
    var ntr_1 : uint
    var ntracks_0 : uint
    if (mux_11 == null) {
        return -1
    }
    if (mux_11.enable_fragmentation == 0) {
        err_15 = mp4e_flush_index(mux_11)
        err_15
    }
    if (mux_11.text_comment != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mux_11.text_comment))))
    }
    ntracks_0 = uint(uint(uint64(mux_11.tracks.bytes) / 4))
    ntracks_0
    ntr_1 = uint(uint(0))
    ntr_1
    while (ntr_1 < ntracks_0) {
        var tr_17 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_11.tracks.data)) + ntr_1)
        minimp4_vector_reset(unsafe(addr(tr_17.vsps)))
        minimp4_vector_reset(unsafe(addr(tr_17.vpps)))
        minimp4_vector_reset(unsafe(addr(tr_17.smpl)))
        minimp4_vector_reset(unsafe(addr(tr_17.pending_sample)))
        ntr_1 = ntr_1 + 1
    }
    minimp4_vector_reset(unsafe(addr(mux_11.tracks)))
    free(unsafe(unsafe(reinterpret<uint64>(mux_11))))
    return err_15
}
[export]
def minimp4_vector_reset(var h_10 : minimp4_vector_t?) {
    if (h_10.data != null) {
        free(unsafe(unsafe(reinterpret<uint64>(h_10.data))))
    }
    memset(unsafe(unsafe(reinterpret<uint64>(h_10))), 0, 4)
}
[export]
def MP4E_set_dsi(var mux_12 : MP4E_mux_t?; var track_id_2 : int; var dsi : uint64; var bytes_9 : int) : int {
    var tr_18 : track_t? = unsafe(unsafe(reinterpret<track_t?>(mux_12.tracks.data)) + track_id_2)
    {
        if (uint(tr_18.info.track_media_kind) == uint(e_audio) || uint(tr_18.info.track_media_kind) == uint(e_private)) {
        } else {
            c2da___assert_fail(unsafe(addr("tr->info.track_media_kind == e_audio || tr->info.track_media_kind == e_private"[0])), unsafe(addr("/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/../upstream/minimp4/minimp4.h"[0])), uint(906), unsafe(addr("int MP4E_set_dsi(MP4E_mux_t *, int, const void *, int)"[0])))
        }
    }
    if (tr_18.vsps.bytes != 0) {
        return -4
    }
    var c2da_fresh24_minimp4 : int = 0
    if (append_mem(unsafe(addr(tr_18.vsps)), dsi, bytes_9)) {
        c2da_fresh24_minimp4 = 0
    } else {
        c2da_fresh24_minimp4 = -2
    }
    return c2da_fresh24_minimp4
}
[export]
def MP4E_set_text_comment(var mux_13 : MP4E_mux_t?; var comment : int8 const?) : int {
    if (mux_13 == null || comment == null) {
        return -1
    }
    if (mux_13.text_comment != null) {
        free(unsafe(unsafe(reinterpret<uint64>(mux_13.text_comment))))
    }
    mux_13.text_comment = strdup(comment)
    mux_13.text_comment
    if (mux_13.text_comment == null) {
        return -2
    }
    return 0
}
[export]
def next_dsi(var p_11 : uint8 const?; var end : uint8 const?; var bytes_10 : int?) : uint8 const? {
    if (p_11 < unsafe(end + 2)) {
        *bytes_10 = int(unsafe(p_11[0])) * 256 + int(unsafe(p_11[1]))
        *bytes_10
        return unsafe(p_11 + 2)
    } else {
        return null
    }
}
var e_private : int = 2

var e_video : int = 1

var e_audio : int = 0

var BOX_mdat : int = 1835295092

var BOX_trun : int = 1953658222

var BOX_tfhd : int = 1952868452

var BOX_traf : int = 1953653094

var BOX_mfhd : int = 1835427940

var BOX_moof : int = 1836019558

var default_sample_flags_present : int = 32

var default_sample_duration_present : int = 8

var BOX_trex : int = 1953654136

var BOX_mehd : int = 1835362404

var BOX_mvex : int = 1836475768

var BOX_data : int = 1684108385

var BOX_ccmt : int = 0xa9636d74

var BOX_ilst : int = 1768715124

var BOX_hdlr : int = 1751411826

var BOX_meta : int = 1835365473

var BOX_udta : int = 1969517665

var BOX_stss : int = 1937011571

var BOX_co64 : int = 1668232756

var BOX_stco : int = 1937007471

var BOX_stsz : int = 1937011578

var BOX_stsc : int = 1937011555

var BOX_stts : int = 1937011827

var BOX_hvcC : int = 1752589123

var BOX_avcC : int = 1635148611

var BOX_hvc1 : int = 1752589105

var BOX_avc1 : int = 1635148593

var BOX_esds : int = 1702061171

var BOX_mp4s : int = 1836070003

var BOX_mp4a : int = 1836069985

var BOX_stsd : int = 1937011556

var BOX_stbl : int = 1937007212

var BOX_url : int = 1970433056

var BOX_dref : int = 1685218662

var BOX_dinf : int = 1684631142

var BOX_vmhd : int = 1986881636

var BOX_smhd : int = 1936549988

var BOX_minf : int = 1835626086

var BOX_mdhd : int = 1835296868

var BOX_mdia : int = 1835297121

var BOX_tkhd : int = 1953196132

var BOX_trak : int = 1953653099

var BOX_mvhd : int = 1836476516

var BOX_moov : int = 1836019574

var BOX_free : int = 1718773093

var BOX_OD : int = 1

var BOX_ATOM : int = 0

var BOX_mp4v : int = 1836070006

var BOX_tref : int = 1953654118

var OD_DSI : int = 606348341

var OD_DCD : int = 606348340

var OD_ESD : int = 606348339

var BOX_cgen : int = 0xa967656e

var BOX_cday : int = 0xa9646179

var BOX_cnam : int = 0xa96e616d

var BOX_cART : int = 0xa9415254

var BOX_calb : int = 0xa9616c62

var BOX_btrt : int = 1651798644

var BOX_ctts : int = 1668576371

var BOX_stz2 : int = 1937013298

var OD_BASE : int = 606348336

var BOX_yrrc : int = 2037543523

var BOX_albm : int = 1634493037

var BOX_name : int = 1851878757

var BOX_mean : int = 1835360622

var BOX_perf : int = 1885696614

var BOX_dscp : int = 1685283696

var BOX_titl : int = 1953068140

var BOX_auth : int = 1635087464

var BOX_gnre : int = 1735291493

var BOX_pgap : int = 1885823344

var BOX_purd : int = 1886745188

var BOX_tvsn : int = 1953919854

var BOX_tvsh : int = 1953919848

var BOX_tvnn : int = 1953918574

var BOX_tves : int = 1953916275

var BOX_tven : int = 1953916270

var BOX_clyr : int = 0xa96c7972

var BOX_desc : int = 1684370275

var BOX_egid : int = 1701276004

var BOX_purl : int = 1886745196

var BOX_keyw : int = 1801812343

var BOX_catg : int = 1667331175

var BOX_pcst : int = 1885565812

var BOX_stik : int = 1937009003

var BOX_cgrp : int = 0xa9677270

var BOX_rtng : int = 1920233063

var BOX_covr : int = 1668249202

var BOX_cpil : int = 1668311404

var BOX_tmpo : int = 1953329263

var BOX_ctoo : int = 0xa9746f6f

var BOX_cwrt : int = 0xa9777274

var BOX_disk : int = 1684632427

var BOX_trkn : int = 1953655662

var BOX_aART : int = 1631670868

var BOX_cart : int = 0xa9617274

var OD_SLC : int = 606348342

var BOX_tfdt : int = 1952867444

var BOX_d263 : int = 1681012275

var BOX_s263 : int = 1932670515

var BOX_damr : int = 1684106610

var BOX_sawb : int = 1935767394

var BOX_samr : int = 1935764850

var BOX_hev1 : int = 1751479857

var BOX_seib : int = 1936025954

var BOX_m4ds : int = 1832150131

var BOX_svcC : int = 1937138499

var BOX_svc1 : int = 1937138481

var BOX_avc2 : int = 1635148594

var BOX_ipir : int = 1768974706

var BOX_sync : int = 1937337955

var BOX_nmhd : int = 1852663908

var BOX_mpod : int = 1836085092

var BOX_odhd : int = 1868851300

var BOX_iods : int = 1768907891

var BOX_dpnd : int = 1685089892

var BOX_sdhd : int = 1935960164

var BOX_padb : int = 1885430882

var BOX_ftyp : int = 1718909296

var BOX_gnra : int = 1735291489

var BOX_gnrv : int = 1735291510

var BOX_urn : int = 1970433568

var BOX_skip : int = 1936419184

var BOX_stsh : int = 1937011560

var BOX_hint : int = 1751740020

var BOX_hmhd : int = 1752000612

var BOX_uuid : int = 1970628964

var BOX_elst : int = 1701606260

var BOX_edts : int = 1701082227

var BOX_stdp : int = 1937007728

var BOX_urn_ : int = 1970433568

var BOX_url_ : int = 1970433056

var BOX_cprt : int = 1668313716

var BOX_crhd : int = 1668442212



typedef int64_t = int64
struct image_t {
    data : uint8?
    width : uint
    height : uint
    luma : uint8?
    cb : uint8?
    cr : uint8?
}
struct DecodeSummary {
    combined_hash : uint
    first_hash : uint
    last_hash : uint
    frame_count : int
    width : int
    height : int
}
struct DecoderState {
    storage : storage_t?
    width : int
    height : int
    picture : uint8?
}
struct MemoryInput {
    bytes : uint8 const?
    length : int
}
var sample_mp4_len : uint const = 0x1f6c

var sample_mp4_bytes : array<uint8> const = [uint8(0), uint8(0), uint8(0), uint8(32), uint8(102), uint8(116), uint8(121), uint8(112), uint8(105), uint8(115), uint8(111), uint8(109), uint8(0), uint8(0), uint8(2), uint8(0), uint8(105), uint8(115), uint8(111), uint8(109), uint8(105), uint8(115), uint8(111), uint8(50), uint8(97), uint8(118), uint8(99), uint8(49), uint8(109), uint8(112), uint8(52), uint8(49), uint8(0), uint8(0), uint8(0), uint8(8), uint8(102), uint8(114), uint8(101), uint8(101), uint8(0), uint8(0), uint8(27), uint8(241), uint8(109), uint8(100), uint8(97), uint8(116), uint8(0), uint8(0), uint8(2), uint8(113), uint8(6), uint8(5), uint8(255), uint8(255), uint8(109), uint8(220), uint8(69), uint8(233), uint8(189), uint8(230), uint8(217), uint8(72), uint8(183), uint8(150), uint8(44), uint8(216), uint8(32), uint8(217), uint8(35), uint8(238), uint8(239), uint8(120), uint8(50), uint8(54), uint8(52), uint8(32), uint8(45), uint8(32), uint8(99), uint8(111), uint8(114), uint8(101), uint8(32), uint8(49), uint8(54), uint8(53), uint8(32), uint8(114), uint8(51), uint8(50), uint8(50), uint8(50), uint8(32), uint8(98), uint8(51), uint8(53), uint8(54), uint8(48), uint8(53), uint8(97), uint8(32), uint8(45), uint8(32), uint8(72), uint8(46), uint8(50), uint8(54), uint8(52), uint8(47), uint8(77), uint8(80), uint8(69), uint8(71), uint8(45), uint8(52), uint8(32), uint8(65), uint8(86), uint8(67), uint8(32), uint8(99), uint8(111), uint8(100), uint8(101), uint8(99), uint8(32), uint8(45), uint8(32), uint8(67), uint8(111), uint8(112), uint8(121), uint8(108), uint8(101), uint8(102), uint8(116), uint8(32), uint8(50), uint8(48), uint8(48), uint8(51), uint8(45), uint8(50), uint8(48), uint8(50), uint8(53), uint8(32), uint8(45), uint8(32), uint8(104), uint8(116), uint8(116), uint8(112), uint8(58), uint8(47), uint8(47), uint8(119), uint8(119), uint8(119), uint8(46), uint8(118), uint8(105), uint8(100), uint8(101), uint8(111), uint8(108), uint8(97), uint8(110), uint8(46), uint8(111), uint8(114), uint8(103), uint8(47), uint8(120), uint8(50), uint8(54), uint8(52), uint8(46), uint8(104), uint8(116), uint8(109), uint8(108), uint8(32), uint8(45), uint8(32), uint8(111), uint8(112), uint8(116), uint8(105), uint8(111), uint8(110), uint8(115), uint8(58), uint8(32), uint8(99), uint8(97), uint8(98), uint8(97), uint8(99), uint8(61), uint8(48), uint8(32), uint8(114), uint8(101), uint8(102), uint8(61), uint8(51), uint8(32), uint8(100), uint8(101), uint8(98), uint8(108), uint8(111), uint8(99), uint8(107), uint8(61), uint8(49), uint8(58), uint8(48), uint8(58), uint8(48), uint8(32), uint8(97), uint8(110), uint8(97), uint8(108), uint8(121), uint8(115), uint8(101), uint8(61), uint8(48), uint8(120), uint8(49), uint8(58), uint8(48), uint8(120), uint8(49), uint8(49), uint8(49), uint8(32), uint8(109), uint8(101), uint8(61), uint8(104), uint8(101), uint8(120), uint8(32), uint8(115), uint8(117), uint8(98), uint8(109), uint8(101), uint8(61), uint8(55), uint8(32), uint8(112), uint8(115), uint8(121), uint8(61), uint8(49), uint8(32), uint8(112), uint8(115), uint8(121), uint8(95), uint8(114), uint8(100), uint8(61), uint8(49), uint8(46), uint8(48), uint8(48), uint8(58), uint8(48), uint8(46), uint8(48), uint8(48), uint8(32), uint8(109), uint8(105), uint8(120), uint8(101), uint8(100), uint8(95), uint8(114), uint8(101), uint8(102), uint8(61), uint8(49), uint8(32), uint8(109), uint8(101), uint8(95), uint8(114), uint8(97), uint8(110), uint8(103), uint8(101), uint8(61), uint8(49), uint8(54), uint8(32), uint8(99), uint8(104), uint8(114), uint8(111), uint8(109), uint8(97), uint8(95), uint8(109), uint8(101), uint8(61), uint8(49), uint8(32), uint8(116), uint8(114), uint8(101), uint8(108), uint8(108), uint8(105), uint8(115), uint8(61), uint8(49), uint8(32), uint8(56), uint8(120), uint8(56), uint8(100), uint8(99), uint8(116), uint8(61), uint8(48), uint8(32), uint8(99), uint8(113), uint8(109), uint8(61), uint8(48), uint8(32), uint8(100), uint8(101), uint8(97), uint8(100), uint8(122), uint8(111), uint8(110), uint8(101), uint8(61), uint8(50), uint8(49), uint8(44), uint8(49), uint8(49), uint8(32), uint8(102), uint8(97), uint8(115), uint8(116), uint8(95), uint8(112), uint8(115), uint8(107), uint8(105), uint8(112), uint8(61), uint8(49), uint8(32), uint8(99), uint8(104), uint8(114), uint8(111), uint8(109), uint8(97), uint8(95), uint8(113), uint8(112), uint8(95), uint8(111), uint8(102), uint8(102), uint8(115), uint8(101), uint8(116), uint8(61), uint8(45), uint8(50), uint8(32), uint8(116), uint8(104), uint8(114), uint8(101), uint8(97), uint8(100), uint8(115), uint8(61), uint8(50), uint8(32), uint8(108), uint8(111), uint8(111), uint8(107), uint8(97), uint8(104), uint8(101), uint8(97), uint8(100), uint8(95), uint8(116), uint8(104), uint8(114), uint8(101), uint8(97), uint8(100), uint8(115), uint8(61), uint8(49), uint8(32), uint8(115), uint8(108), uint8(105), uint8(99), uint8(101), uint8(100), uint8(95), uint8(116), uint8(104), uint8(114), uint8(101), uint8(97), uint8(100), uint8(115), uint8(61), uint8(48), uint8(32), uint8(110), uint8(114), uint8(61), uint8(48), uint8(32), uint8(100), uint8(101), uint8(99), uint8(105), uint8(109), uint8(97), uint8(116), uint8(101), uint8(61), uint8(49), uint8(32), uint8(105), uint8(110), uint8(116), uint8(101), uint8(114), uint8(108), uint8(97), uint8(99), uint8(101), uint8(100), uint8(61), uint8(48), uint8(32), uint8(98), uint8(108), uint8(117), uint8(114), uint8(97), uint8(121), uint8(95), uint8(99), uint8(111), uint8(109), uint8(112), uint8(97), uint8(116), uint8(61), uint8(48), uint8(32), uint8(99), uint8(111), uint8(110), uint8(115), uint8(116), uint8(114), uint8(97), uint8(105), uint8(110), uint8(101), uint8(100), uint8(95), uint8(105), uint8(110), uint8(116), uint8(114), uint8(97), uint8(61), uint8(48), uint8(32), uint8(98), uint8(102), uint8(114), uint8(97), uint8(109), uint8(101), uint8(115), uint8(61), uint8(48), uint8(32), uint8(119), uint8(101), uint8(105), uint8(103), uint8(104), uint8(116), uint8(112), uint8(61), uint8(48), uint8(32), uint8(107), uint8(101), uint8(121), uint8(105), uint8(110), uint8(116), uint8(61), uint8(50), uint8(53), uint8(48), uint8(32), uint8(107), uint8(101), uint8(121), uint8(105), uint8(110), uint8(116), uint8(95), uint8(109), uint8(105), uint8(110), uint8(61), uint8(49), uint8(50), uint8(32), uint8(115), uint8(99), uint8(101), uint8(110), uint8(101), uint8(99), uint8(117), uint8(116), uint8(61), uint8(52), uint8(48), uint8(32), uint8(105), uint8(110), uint8(116), uint8(114), uint8(97), uint8(95), uint8(114), uint8(101), uint8(102), uint8(114), uint8(101), uint8(115), uint8(104), uint8(61), uint8(48), uint8(32), uint8(114), uint8(99), uint8(95), uint8(108), uint8(111), uint8(111), uint8(107), uint8(97), uint8(104), uint8(101), uint8(97), uint8(100), uint8(61), uint8(52), uint8(48), uint8(32), uint8(114), uint8(99), uint8(61), uint8(99), uint8(114), uint8(102), uint8(32), uint8(109), uint8(98), uint8(116), uint8(114), uint8(101), uint8(101), uint8(61), uint8(49), uint8(32), uint8(99), uint8(114), uint8(102), uint8(61), uint8(50), uint8(51), uint8(46), uint8(48), uint8(32), uint8(113), uint8(99), uint8(111), uint8(109), uint8(112), uint8(61), uint8(48), uint8(46), uint8(54), uint8(48), uint8(32), uint8(113), uint8(112), uint8(109), uint8(105), uint8(110), uint8(61), uint8(48), uint8(32), uint8(113), uint8(112), uint8(109), uint8(97), uint8(120), uint8(61), uint8(54), uint8(57), uint8(32), uint8(113), uint8(112), uint8(115), uint8(116), uint8(101), uint8(112), uint8(61), uint8(52), uint8(32), uint8(105), uint8(112), uint8(95), uint8(114), uint8(97), uint8(116), uint8(105), uint8(111), uint8(61), uint8(49), uint8(46), uint8(52), uint8(48), uint8(32), uint8(97), uint8(113), uint8(61), uint8(49), uint8(58), uint8(49), uint8(46), uint8(48), uint8(48), uint8(0), uint8(128), uint8(0), uint8(0), uint8(6), uint8(205), uint8(101), uint8(136), uint8(132), uint8(55), uint8(196), uint8(34), uint8(42), uint8(224), uint8(192), uint8(133), uint8(248), uint8(8), uint8(83), uint8(34), uint8(0), uint8(1), uint8(0), uint8(154), uint8(212), uint8(24), uint8(96), uint8(0), uint8(241), uint8(120), uint8(206), uint8(140), uint8(104), uint8(232), uint8(23), uint8(221), uint8(255), uint8(226), uint8(103), uint8(220), uint8(153), uint8(17), uint8(138), uint8(191), uint8(176), uint8(111), uint8(254), uint8(210), uint8(94), uint8(97), uint8(162), uint8(50), uint8(176), uint8(246), uint8(207), uint8(251), uint8(8), uint8(252), uint8(69), uint8(150), uint8(100), uint8(62), uint8(206), uint8(66), uint8(95), uint8(246), uint8(11), uint8(52), uint8(184), uint8(169), uint8(4), uint8(178), uint8(39), uint8(251), uint8(107), uint8(141), uint8(67), uint8(19), uint8(147), uint8(229), uint8(225), uint8(234), uint8(245), uint8(43), uint8(140), uint8(26), uint8(50), uint8(132), uint8(221), uint8(94), uint8(160), uint8(117), uint8(153), uint8(180), uint8(112), uint8(95), uint8(143), uint8(239), uint8(148), uint8(28), uint8(84), uint8(93), uint8(84), uint8(19), uint8(55), uint8(251), uint8(224), uint8(64), uint8(0), uint8(88), uint8(0), uint8(193), uint8(77), uint8(132), uint8(0), uint8(9), uint8(120), uint8(0), uint8(8), uint8(4), uint8(0), uint8(9), uint8(243), uint8(48), uint8(171), uint8(49), uint8(208), uint8(33), uint8(23), uint8(202), uint8(155), uint8(7), uint8(134), uint8(185), uint8(209), uint8(164), uint8(247), uint8(32), uint8(56), uint8(159), uint8(255), uint8(180), uint8(224), uint8(87), uint8(49), uint8(37), uint8(136), uint8(210), uint8(0), uint8(55), uint8(92), uint8(81), uint8(85), uint8(133), uint8(69), uint8(160), uint8(2), uint8(13), uint8(42), uint8(116), uint8(189), uint8(86), uint8(192), uint8(35), uint8(13), uint8(255), uint8(251), uint8(199), uint8(1), uint8(78), uint8(229), uint8(178), uint8(35), uint8(74), uint8(34), uint8(160), uint8(35), uint8(241), uint8(118), uint8(166), uint8(80), uint8(56), uint8(128), uint8(64), uint8(51), uint8(47), uint8(249), uint8(50), uint8(18), uint8(147), uint8(188), uint8(117), uint8(131), uint8(7), uint8(192), uint8(1), uint8(226), uint8(240), uint8(206), uint8(140), uint8(108), uint8(84), uint8(11), uint8(229), uint8(127), uint8(250), uint8(227), uint8(80), uint8(198), uint8(228), uint8(249), uint8(104), uint8(61), uint8(94), uint8(6), uint8(173), uint8(98), uint8(86), uint8(43), uint8(20), uint8(33), uint8(234), uint8(244), uint8(128), uint8(53), uint8(153), uint8(146), uint8(56), uint8(63), uint8(191), uint8(191), uint8(245), uint8(194), uint8(50), uint8(43), uint8(57), uint8(74), uint8(131), uint8(168), uint8(7), uint8(235), uint8(120), uint8(179), uint8(103), uint8(124), uint8(93), uint8(148), uint8(89), uint8(102), uint8(131), uint8(169), uint8(143), uint8(33), uint8(239), uint8(244), uint8(224), uint8(134), uint8(116), uint8(33), uint8(76), uint8(232), uint8(58), uint8(172), uint8(26), uint8(124), uint8(84), uint8(176), uint8(37), uint8(186), uint8(127), uint8(190), uint8(3), uint8(3), uint8(120), uint8(72), uint8(0), uint8(8), uint8(24), uint8(160), uint8(0), uint8(8), uint8(19), uint8(134), uint8(194), uint8(236), uint8(128), uint8(51), uint8(240), uint8(122), uint8(108), uint8(85), uint8(152), uint8(6), uint8(45), uint8(3), uint8(216), uint8(75), uint8(38), uint8(82), uint8(5), uint8(165), uint8(127), uint8(223), uint8(96), uint8(212), uint8(102), uint8(122), uint8(3), uint8(214), uint8(183), uint8(239), uint8(130), uint8(108), uint8(6), uint8(214), uint8(20), uint8(160), uint8(63), uint8(39), uint8(213), uint8(80), uint8(26), uint8(248), uint8(199), uint8(1), uint8(117), uint8(62), uint8(193), uint8(184), uint8(200), uint8(217), uint8(128), uint8(253), uint8(134), uint8(253), uint8(246), uint8(4), uint8(188), uint8(140), uint8(215), uint8(40), uint8(37), uint8(194), uint8(127), uint8(252), uint8(136), uint8(171), uint8(136), uint8(168), uint8(19), uint8(101), uint8(97), uint8(224), uint8(113), uint8(0), uint8(128), uint8(102), uint8(95), uint8(242), uint8(100), uint8(152), uint8(93), uint8(226), uint8(252), uint8(55), uint8(17), uint8(120), uint8(203), uint8(152), uint8(145), uint8(240), uint8(254), uint8(239), uint8(255), uint8(127), uint8(201), uint8(145), uint8(24), uint8(93), uint8(239), uint8(249), uint8(3), uint8(184), uint8(212), uint8(49), uint8(185), uint8(62), uint8(90), uint8(143), uint8(87), uint8(182), uint8(82), uint8(57), uint8(32), uint8(123), uint8(59), uint8(51), uint8(255), uint8(168), uint8(15), uint8(144), uint8(140), uint8(152), uint8(160), uint8(47), uint8(223), uint8(247), uint8(203), uint8(3), uint8(206), uint8(71), uint8(74), uint8(80), uint8(36), uint8(102), uint8(255), uint8(125), uint8(113), uint8(168), uint8(99), uint8(114), uint8(124), uint8(190), uint8(61), uint8(94), uint8(6), uint8(186), uint8(197), uint8(216), uint8(172), uint8(86), uint8(61), uint8(94), uint8(160), uint8(107), uint8(146), uint8(145), uint8(7), uint8(151), uint8(239), uint8(251), uint8(211), uint8(145), uint8(147), uint8(179), uint8(151), uint8(160), uint8(234), uint8(14), uint8(96), uint8(6), uint8(4), uint8(128), uint8(72), uint8(0), uint8(6), uint8(105), uint8(1), uint8(212), uint8(10), uint8(88), uint8(218), uint8(152), uint8(108), uint8(0), uint8(249), uint8(112), uint8(57), uint8(246), uint8(15), uint8(48), uint8(5), uint8(241), uint8(13), uint8(184), uint8(218), uint8(158), uint8(9), uint8(50), uint8(52), uint8(136), uint8(41), uint8(58), uint8(254), uint8(243), uint8(62), uint8(208), uint8(37), uint8(27), uint8(83), uint8(26), uint8(248), uint8(197), uint8(159), uint8(93), uint8(140), uint8(12), uint8(215), uint8(193), uint8(101), uint8(241), uint8(189), uint8(57), uint8(129), uint8(252), uint8(232), uint8(189), uint8(69), uint8(153), uint8(174), uint8(253), uint8(236), uint8(113), uint8(21), uint8(123), uint8(36), uint8(191), uint8(6), uint8(144), uint8(0), uint8(16), uint8(53), uint8(101), uint8(224), uint8(0), uint8(240), uint8(189), uint8(56), uint8(188), uint8(167), uint8(82), uint8(248), uint8(213), uint8(157), uint8(255), uint8(239), uint8(205), uint8(72), uint8(50), uint8(51), uint8(137), uint8(107), uint8(157), uint8(218), uint8(238), uint8(33), uint8(122), uint8(113), uint8(121), uint8(78), uint8(165), uint8(241), uint8(235), uint8(59), uint8(255), uint8(192), uint8(174), uint8(47), uint8(204), uint8(198), uint8(17), uint8(78), uint8(81), uint8(234), uint8(247), uint8(59), uint8(9), uint8(31), uint8(35), uint8(15), uint8(156), uint8(182), uint8(43), uint8(255), uint8(214), uint8(28), uint8(22), uint8(31), uint8(85), uint8(156), uint8(222), uint8(151), uint8(127), uint8(172), uint8(13), uint8(186), uint8(11), uint8(211), uint8(6), uint8(105), uint8(215), uint8(253), uint8(245), uint8(168), uint8(123), uint8(28), uint8(17), uint8(77), uint8(88), uint8(222), uint8(30), uint8(175), uint8(91), uint8(133), uint8(241), uint8(193), uint8(84), uint8(197), uint8(140), uint8(233), uint8(234), uint8(244), uint8(128), uint8(0), uint8(243), uint8(24), uint8(205), uint8(142), uint8(0), uint8(171), uint8(127), uint8(127), uint8(237), uint8(0), uint8(120), uint8(230), uint8(59), uint8(115), uint8(128), uint8(34), uint8(151), uint8(253), uint8(240), uint8(32), uint8(64), uint8(0), uint8(64), uint8(33), uint8(128), uint8(0), uint8(160), uint8(136), uint8(6), uint8(91), uint8(147), uint8(176), uint8(9), uint8(180), uint8(229), uint8(16), uint8(42), uint8(196), uint8(196), uint8(192), uint8(9), uint8(149), uint8(128), uint8(12), uint8(54), uint8(167), uint8(128), uint8(217), uint8(14), uint8(83), uint8(169), uint8(0), uint8(185), uint8(54), uint8(239), uint8(223), uint8(48), uint8(0), uint8(4), uint8(142), uint8(193), uint8(132), uint8(82), uint8(99), uint8(106), uint8(115), uint8(86), uint8(248), uint8(131), uint8(243), uint8(236), uint8(206), uint8(53), uint8(200), uint8(56), uint8(218), uint8(158), uint8(5), uint8(251), uint8(35), uint8(101), uint8(9), uint8(113), uint8(9), uint8(253), uint8(243), uint8(0), uint8(2), uint8(202), uint8(41), uint8(55), uint8(3), uint8(106), uint8(113), uint8(21), uint8(1), uint8(31), uint8(109), uint8(141), uint8(51), uint8(1), uint8(208), uint8(32), uint8(102), uint8(95), uint8(114), uint8(100), uint8(152), uint8(187), uint8(175), uint8(198), uint8(255), uint8(224), uint8(248), uint8(0), uint8(82), uint8(241), uint8(190), uint8(98), uint8(71), uint8(194), uint8(251), uint8(191), uint8(253), uint8(75), uint8(163), uint8(4), uint8(142), uint8(161), uint8(85), uint8(171), uint8(199), uint8(157), uint8(7), uint8(230), uint8(100), uint8(135), uint8(226), uint8(207), uint8(246), uint8(192), uint8(229), uint8(198), uint8(200), uint8(74), uint8(233), uint8(171), uint8(203), uint8(105), uint8(78), uint8(80), uint8(27), uint8(16), uint8(226), uint8(111), uint8(244), uint8(9), uint8(101), uint8(180), uint8(159), uint8(165), uint8(84), uint8(30), uint8(185), uint8(210), uint8(195), uint8(113), uint8(191), uint8(190), uint8(192), uint8(193), uint8(167), uint8(10), uint8(0), uint8(11), uint8(129), uint8(131), uint8(16), uint8(31), uint8(42), uint8(32), uint8(75), uint8(79), uint8(171), uint8(96), uint8(116), uint8(170), uint8(129), uint8(41), uint8(62), uint8(194), uint8(45), uint8(28), uint8(161), uint8(25), uint8(41), uint8(127), uint8(252), uint8(211), uint8(22), uint8(95), uint8(245), uint8(97), uint8(242), uint8(169), uint8(15), uint8(255), uint8(21), uint8(54), uint8(4), uint8(36), uint8(79), uint8(10), uint8(30), uint8(2), uint8(18), uint8(103), uint8(128), uint8(110), uint8(115), uint8(45), uint8(227), uint8(58), uint8(194), uint8(127), uint8(249), uint8(133), uint8(229), uint8(144), uint8(210), uint8(201), uint8(143), uint8(212), uint8(69), uint8(92), uint8(69), uint8(65), uint8(220), uint8(164), uint8(62), uint8(96), uint8(58), uint8(33), uint8(153), uint8(123), uint8(197), uint8(90), uint8(219), uint8(226), uint8(223), uint8(224), uint8(40), uint8(137), uint8(200), uint8(167), uint8(15), uint8(183), uint8(127), uint8(176), uint8(26), uint8(90), uint8(76), uint8(183), uint8(186), uint8(255), uint8(237), uint8(200), uint8(156), uint8(138), uint8(112), uint8(251), uint8(119), uint8(250), uint8(185), uint8(98), uint8(77), uint8(159), uint8(151), uint8(236), uint8(84), uint8(234), uint8(58), uint8(105), uint8(95), uint8(245), uint8(15), uint8(73), uint8(83), uint8(3), uint8(251), uint8(251), uint8(229), uint8(14), uint8(105), uint8(219), uint8(2), uint8(223), uint8(251), uint8(229), uint8(106), uint8(197), uint8(151), uint8(159), uint8(106), uint8(245), uint8(102), uint8(199), uint8(147), uint8(155), uint8(234), uint8(244), uint8(131), uint8(164), uint8(169), uint8(129), uint8(247), uint8(247), uint8(254), uint8(208), uint8(230), uint8(157), uint8(176), uint8(44), uint8(191), uint8(223), uint8(4), uint8(8), uint8(116), uint8(32), uint8(0), uint8(8), uint8(1), uint8(128), uint8(14), uint8(154), uint8(74), uint8(240), uint8(67), uint8(106), uint8(100), uint8(165), uint8(120), uint8(33), uint8(181), uint8(54), uint8(2), uint8(185), uint8(137), uint8(40), uint8(218), uint8(152), uint8(128), uint8(174), uint8(98), uint8(74), uint8(54), uint8(166), uint8(76), uint8(3), uint8(231), uint8(14), uint8(54), uint8(166), uint8(76), uint8(3), uint8(231), uint8(14), uint8(54), uint8(166), uint8(192), uint8(10), uint8(114), uint8(158), uint8(193), uint8(181), uint8(49), uint8(0), uint8(41), uint8(202), uint8(123), uint8(6), uint8(212), uint8(224), uint8(0), uint8(2), uint8(53), uint8(8), uint8(125), uint8(134), uint8(133), uint8(185), uint8(123), uint8(55), uint8(192), uint8(31), uint8(183), uint8(130), uint8(39), uint8(213), uint8(117), uint8(3), uint8(32), uint8(48), uint8(0), uint8(129), uint8(89), uint8(0), uint8(12), uint8(72), uint8(14), uint8(5), uint8(128), uint8(124), uint8(71), uint8(128), uint8(112), uint8(28), uint8(3), uint8(96), uint8(32), uint8(138), uint8(11), uint8(64), uint8(5), uint8(96), uint8(104), uint8(226), uint8(80), uint8(28), uint8(1), uint8(176), uint8(226), uint8(32), uint8(28), uint8(48), uint8(241), uint8(197), uint8(231), uint8(182), uint8(76), uint8(203), uint8(243), uint8(223), uint8(124), uint8(12), uint8(1), uint8(57), uint8(3), uint8(8), uint8(16), uint8(0), uint8(148), uint8(93), uint8(248), uint8(63), uint8(104), uint8(100), uint8(212), uint8(249), uint8(192), uint8(252), uint8(155), uint8(255), uint8(235), uint8(133), uint8(13), uint8(55), uint8(127), uint8(243), uint8(254), uint8(40), uint8(28), uint8(13), uint8(6), uint8(16), uint8(52), uint8(52), uint8(125), uint8(246), uint8(15), uint8(248), uint8(135), uint8(163), uint8(158), uint8(127), uint8(128), uint8(147), uint8(225), uint8(196), uint8(127), uint8(70), uint8(187), uint8(154), uint8(239), uint8(38), uint8(62), uint8(35), uint8(254), uint8(131), uint8(66), uint8(76), uint8(251), uint8(117), uint8(127), uint8(252), uint8(129), uint8(94), uint8(155), uint8(32), uint8(78), uint8(203), uint8(206), uint8(244), uint8(195), uint8(2), uint8(112), uint8(26), uint8(32), uint8(0), uint8(128), uint8(150), uint8(183), uint8(73), uint8(136), uint8(151), uint8(225), uint8(111), uint8(61), uint8(225), uint8(31), uint8(255), uint8(162), uint8(53), uint8(137), uint8(126), uint8(43), uint8(84), uint8(157), uint8(88), uint8(174), uint8(59), uint8(195), uint8(30), uint8(187), uint8(160), uint8(0), uint8(79), uint8(134), uint8(176), uint8(169), uint8(217), uint8(37), uint8(240), uint8(206), uint8(51), uint8(104), uint8(63), uint8(156), uint8(186), uint8(146), uint8(195), uint8(0), uint8(20), uint8(5), uint8(132), uint8(1), uint8(87), uint8(1), uint8(155), uint8(56), uint8(104), uint8(101), uint8(17), uint8(197), uint8(104), uint8(216), uint8(60), uint8(230), uint8(92), uint8(46), uint8(202), uint8(13), uint8(33), uint8(57), uint8(91), uint8(247), uint8(119), uint8(31), uint8(52), uint8(140), uint8(93), uint8(142), uint8(80), uint8(26), uint8(122), uint8(103), uint8(56), uint8(120), uint8(96), uint8(22), uint8(4), uint8(198), uint8(30), uint8(126), uint8(171), uint8(254), uint8(160), uint8(1), uint8(75), uint8(204), uint8(121), uint8(26), uint8(46), uint8(58), uint8(147), uint8(255), uint8(218), uint8(135), uint8(125), uint8(164), uint8(167), uint8(65), uint8(163), uint8(20), uint8(219), uint8(239), uint8(86), uint8(11), uint8(107), uint8(70), uint8(160), uint8(185), uint8(175), uint8(246), uint8(193), uint8(8), uint8(1), uint8(41), uint8(128), uint8(192), uint8(3), uint8(192), uint8(14), uint8(24), uint8(204), uint8(109), uint8(180), uint8(129), uint8(236), uint8(23), uint8(146), uint8(54), uint8(226), uint8(13), uint8(13), uint8(255), uint8(251), uint8(192), uint8(195), uint8(34), uint8(248), uint8(147), uint8(105), uint8(240), uint8(2), uint8(29), uint8(93), uint8(124), uint8(7), uint8(29), uint8(194), uint8(51), uint8(22), uint8(159), uint8(41), uint8(31), uint8(206), uint8(88), uint8(97), uint8(128), uint8(127), uint8(193), uint8(88), uint8(156), uint8(4), uint8(200), uint8(157), uint8(137), uint8(90), uint8(187), uint8(3), uint8(128), uint8(1), uint8(12), uint8(3), uint8(132), uint8(16), uint8(0), uint8(118), uint8(128), uint8(10), uint8(0), uint8(202), uint8(109), uint8(158), uint8(100), uint8(96), uint8(68), uint8(100), uint8(150), uint8(30), uint8(0), uint8(66), uint8(104), uint8(208), uint8(106), uint8(132), uint8(27), uint8(156), uint8(89), uint8(68), uint8(0), uint8(8), uint8(97), uint8(50), uint8(195), uint8(248), uint8(6), uint8(0), uint8(28), uint8(3), uint8(97), uint8(178), uint8(96), uint8(114), uint8(3), uint8(6), uint8(101), uint8(226), uint8(128), uint8(60), uint8(72), uint8(0), uint8(104), uint8(72), uint8(0), uint8(8), uint8(1), uint8(160), uint8(228), uint8(24), uint8(146), uint8(195), uint8(144), uint8(98), uint8(75), uint8(28), uint8(32), uint8(118), uint8(7), uint8(4), uint8(12), uint8(192), uint8(112), uint8(138), uint8(68), uint8(176), uint8(225), uint8(20), uint8(137), uint8(99), uint8(128), uint8(64), uint8(43), uint8(3), uint8(128), uint8(32), uint8(17), uint8(142), uint8(1), uint8(0), uint8(255), uint8(193), uint8(89), uint8(48), uint8(60), uint8(24), uint8(102), uint8(88), uint8(72), uint8(16), uint8(192), uint8(240), uint8(128), uint8(64), uint8(10), uint8(192), uint8(12), uint8(14), uint8(19), uint8(141), uint8(44), uint8(128), uint8(156), uint8(105), uint8(127), uint8(174), uint8(235), uint8(190), uint8(64), uint8(1), uint8(128), uint8(127), uint8(176), uint8(86), uint8(80), uint8(21), uint8(99), uint8(14), uint8(100), uint8(74), uint8(178), uint8(40), uint8(41), uint8(149), uint8(134), uint8(0), uint8(2), uint8(2), uint8(108), uint8(0), uint8(2), uint8(4), uint8(144), uint8(200), uint8(180), uint8(28), uint8(1), uint8(16), uint8(250), uint8(160), uint8(28), uint8(4), uint8(99), uint8(98), uint8(137), uint8(145), uint8(65), uint8(73), uint8(43), uint8(122), uint8(105), uint8(158), uint8(3), uint8(128), uint8(67), uint8(190), uint8(73), uint8(48), uint8(60), uint8(6), uint8(51), uint8(35), uint8(129), uint8(35), uint8(134), uint8(204), uint8(131), uint8(182), uint8(95), uint8(162), uint8(123), uint8(224), uint8(96), uint8(3), uint8(67), uint8(132), uint8(128), uint8(0), uint8(128), uint8(139), uint8(0), uint8(0), uint8(128), uint8(0), uint8(24), uint8(240), uint8(86), uint8(207), uint8(8), uint8(66), uint8(178), uint8(207), uint8(2), uint8(206), uint8(0), uint8(153), uint8(0), uint8(150), uint8(102), uint8(88), uint8(216), uint8(233), uint8(187), uint8(74), uint8(60), uint8(65), uint8(221), uint8(156), uint8(181), uint8(102), uint8(115), uint8(157), uint8(192), uint8(32), uint8(16), uint8(130), uint8(225), uint8(39), uint8(196), uint8(241), uint8(254), uint8(92), uint8(123), uint8(138), uint8(0), uint8(7), uint8(160), uint8(9), uint8(237), uint8(41), uint8(85), uint8(175), uint8(159), uint8(216), uint8(66), uint8(5), uint8(134), uint8(8), uint8(0), uint8(10), uint8(0), uint8(135), uint8(135), uint8(154), uint8(135), uint8(217), uint8(202), uint8(73), uint8(164), uint8(184), uint8(85), uint8(32), uint8(209), uint8(54), uint8(16), uint8(32), uint8(150), uint8(89), uint8(2), uint8(9), uint8(229), uint8(128), uint8(172), uint8(36), uint8(206), uint8(47), uint8(163), uint8(119), uint8(179), uint8(192), uint8(35), uint8(116), uint8(100), uint8(50), uint8(24), uint8(124), uint8(41), uint8(227), uint8(17), uint8(221), uint8(163), uint8(65), uint8(44), uint8(99), uint8(24), uint8(255), uint8(240), uint8(195), uint8(176), uint8(84), uint8(9), uint8(4), uint8(0), uint8(2), uint8(128), uint8(168), uint8(64), uint8(0), uint8(52), uint8(2), uint8(172), uint8(28), uint8(64), uint8(9), uint8(128), uint8(114), uint8(0), uint8(108), uint8(96), uint8(224), uint8(32), uint8(102), uint8(1), uint8(192), uint8(129), uint8(216), uint8(51), uint8(4), uint8(113), uint8(172), uint8(96), uint8(3), uint8(195), uint8(0), uint8(255), uint8(216), uint8(43), uint8(131), uint8(145), uint8(255), uint8(68), uint8(148), uint8(92), uint8(92), uint8(92), uint8(92), uint8(92), uint8(92), uint8(92), uint8(95), uint8(12), uint8(3), uint8(255), uint8(96), uint8(174), uint8(47), uint8(196), uint8(0), uint8(18), uint8(68), uint8(0), uint8(8), uint8(145), uint8(89), uint8(108), uint8(86), uint8(43), uint8(17), uint8(96), uint8(128), uint8(4), uint8(186), uint8(225), uint8(214), uint8(3), uint8(128), uint8(37), uint8(215), uint8(32), uint8(28), uint8(63), uint8(246), uint8(10), uint8(226), uint8(191), uint8(196), uint8(0), uint8(1), uint8(6), uint8(80), uint8(0), uint8(16), uint8(68), uint8(136), uint8(0), uint8(2), uint8(60), uint8(0), uint8(0), uint8(35), uint8(147), uint8(45), uint8(25), uint8(96), uint8(16), uint8(0), uint8(16), uint8(49), uint8(96), uint8(84), uint8(99), uint8(128), uint8(64), uint8(0), uint8(64), uint8(197), uint8(130), uint8(0), uint8(151), uint8(92), uint8(32), uint8(0), uint8(4), uint8(35), uint8(232), uint8(0), uint8(8), uint8(200), uint8(92), uint8(14), uint8(4), uint8(186), uint8(224), uint8(112), uint8(0), uint8(16), uint8(143), uint8(160), uint8(0), uint8(35), uint8(33), uint8(114), uint8(0), uint8(0), uint8(1), uint8(202), uint8(65), uint8(154), uint8(56), uint8(111), uint8(227), uint8(97), uint8(110), uint8(34), uint8(31), uint8(127), uint8(2), uint8(20), uint8(241), uint8(202), uint8(12), uint8(156), uint8(247), uint8(153), uint8(35), uint8(13), uint8(60), uint8(189), uint8(247), uint8(191), uint8(132), uint8(0), uint8(6), uint8(65), uint8(196), uint8(162), uint8(16), uint8(1), uint8(17), uint8(72), uint8(0), uint8(10), uint8(72), uint8(136), uint8(129), uint8(145), uint8(133), uint8(45), uint8(5), uint8(158), uint8(123), uint8(120), uint8(189), uint8(36), uint8(210), uint8(215), uint8(126), uint8(150), uint8(219), uint8(87), uint8(141), uint8(82), uint8(169), uint8(112), uint8(0), uint8(103), uint8(23), uint8(137), uint8(122), uint8(17), uint8(76), uint8(35), uint8(35), uint8(159), uint8(252), uint8(186), uint8(195), uint8(121), uint8(254), uint8(22), uint8(47), uint8(33), uint8(76), uint8(195), uint8(47), uint8(8), uint8(214), uint8(151), uint8(69), uint8(127), uint8(253), uint8(59), uint8(249), uint8(226), uint8(95), uint8(218), uint8(95), uint8(225), uint8(142), uint8(18), uint8(81), uint8(175), uint8(4), uint8(93), uint8(26), uint8(171), uint8(137), uint8(151), uint8(4), uint8(126), uint8(79), uint8(222), uint8(1), uint8(15), uint8(151), uint8(57), uint8(234), uint8(94), uint8(127), uint8(111), uint8(52), uint8(104), uint8(206), uint8(0), uint8(21), uint8(232), uint8(148), uint8(220), uint8(126), uint8(87), uint8(221), uint8(26), uint8(166), uint8(141), uint8(124), uint8(231), uint8(187), uint8(246), uint8(110), uint8(50), uint8(40), uint8(251), uint8(246), uint8(244), uint8(9), uint8(90), uint8(53), uint8(238), uint8(118), uint8(83), uint8(250), uint8(94), uint8(100), uint8(207), uint8(1), uint8(56), uint8(227), uint8(230), uint8(6), uint8(220), uint8(53), uint8(248), uint8(163), uint8(131), uint8(84), uint8(195), uint8(197), uint8(104), uint8(186), uint8(187), uint8(162), uint8(76), uint8(246), uint8(56), uint8(191), uint8(168), uint8(10), uint8(220), uint8(18), uint8(72), uint8(195), uint8(169), uint8(119), uint8(221), uint8(75), uint8(188), uint8(45), uint8(226), uint8(254), uint8(66), uint8(162), uint8(120), uint8(125), uint8(45), uint8(231), uint8(6), uint8(165), uint8(223), uint8(106), uint8(93), uint8(232), uint8(201), uint8(127), uint8(3), uint8(34), uint8(98), uint8(134), uint8(203), uint8(63), uint8(231), uint8(120), uint8(84), uint8(90), uint8(137), uint8(231), uint8(131), uint8(73), uint8(50), uint8(23), uint8(11), uint8(22), uint8(64), uint8(173), uint8(8), uint8(180), uint8(31), uint8(245), uint8(132), uint8(154), uint8(195), uint8(208), uint8(236), uint8(120), uint8(88), uint8(248), uint8(233), uint8(98), uint8(186), uint8(90), uint8(69), uint8(242), uint8(125), uint8(207), uint8(208), uint8(66), uint8(18), uint8(130), uint8(243), uint8(96), uint8(245), uint8(159), uint8(15), uint8(120), uint8(113), uint8(128), uint8(184), uint8(74), uint8(83), uint8(107), uint8(188), uint8(255), uint8(137), uint8(69), uint8(46), uint8(120), uint8(9), uint8(127), uint8(165), uint8(242), uint8(248), uint8(75), uint8(139), uint8(225), uint8(83), uint8(129), uint8(8), uint8(36), uint8(77), uint8(4), uint8(145), uint8(163), uint8(58), uint8(92), uint8(207), uint8(3), uint8(7), uint8(28), uint8(133), uint8(184), uint8(149), uint8(209), uint8(96), uint8(220), uint8(215), uint8(239), uint8(36), uint8(191), uint8(143), uint8(161), uint8(61), uint8(247), uint8(245), uint8(137), uint8(8), uint8(133), uint8(120), uint8(48), uint8(68), uint8(203), uint8(151), uint8(250), uint8(8), uint8(129), uint8(222), uint8(63), uint8(192), uint8(70), uint8(90), uint8(107), uint8(188), uint8(255), uint8(203), uint8(248), uint8(156), uint8(34), uint8(23), uint8(8), uint8(135), uint8(6), uint8(64), uint8(5), uint8(249), uint8(214), uint8(195), uint8(65), uint8(183), uint8(183), uint8(104), uint8(62), uint8(108), uint8(93), uint8(81), uint8(244), uint8(92), uint8(226), uint8(161), uint8(119), uint8(248), uint8(4), uint8(167), uint8(159), uint8(15), uint8(159), uint8(192), uint8(20), uint8(21), uint8(233), uint8(49), uint8(201), uint8(132), uint8(32), uint8(140), uint8(114), uint8(43), uint8(113), uint8(51), uint8(152), uint8(227), uint8(224), uint8(142), uint8(189), uint8(159), uint8(4), uint8(139), uint8(182), uint8(123), uint8(9), uint8(97), uint8(0), uint8(74), uint8(112), uint8(85), uint8(92), uint8(152), uint8(247), uint8(242), uint8(97), uint8(32), uint8(116), uint8(117), uint8(112), uint8(140), uint8(32), uint8(30), uint8(224), uint8(192), uint8(89), uint8(144), uint8(120), uint8(102), uint8(101), uint8(202), uint8(129), uint8(199), uint8(30), uint8(77), uint8(206), uint8(16), uint8(81), uint8(152), uint8(52), uint8(166), uint8(7), uint8(4), uint8(98), uint8(229), uint8(252), uint8(56), uint8(227), uint8(69), uint8(128), uint8(19), uint8(190), uint8(247), uint8(63), uint8(189), uint8(82), uint8(8), uint8(3), uint8(8), uint8(32), uint8(52), uint8(185), uint8(102), uint8(170), uint8(171), uint8(123), uint8(132), uint8(32), uint8(241), uint8(129), uint8(10), uint8(213), uint8(247), uint8(32), uint8(35), uint8(181), uint8(220), uint8(60), uint8(59), uint8(105), uint8(77), uint8(221), uint8(231), uint8(250), uint8(97), uint8(8), uint8(70), uint8(190), uint8(145), uint8(224), uint8(196), uint8(35), uint8(128), uint8(0), uint8(0), uint8(1), uint8(220), uint8(65), uint8(154), uint8(84), uint8(27), uint8(252), uint8(110), uint8(164), uint8(254), uint8(50), uint8(166), uint8(14), uint8(177), uint8(185), uint8(62), uint8(197), uint8(81), uint8(75), uint8(77), uint8(234), uint8(248), uint8(59), uint8(177), uint8(50), uint8(0), uint8(29), uint8(203), uint8(170), uint8(92), uint8(135), uint8(192), uint8(247), uint8(167), uint8(145), uint8(133), uint8(183), uint8(111), uint8(229), uint8(19), uint8(218), uint8(220), uint8(132), uint8(191), uint8(99), uint8(130), uint8(243), uint8(211), uint8(225), uint8(141), uint8(247), uint8(155), uint8(157), uint8(239), uint8(165), uint8(65), uint8(254), uint8(11), uint8(187), uint8(218), uint8(255), uint8(13), uint8(240), uint8(223), uint8(167), uint8(147), uint8(248), uint8(79), uint8(229), uint8(250), uint8(47), uint8(226), uint8(120), uint8(92), uint8(34), uint8(28), uint8(34), uint8(128), uint8(11), uint8(243), uint8(172), uint8(195), uint8(97), uint8(181), uint8(27), uint8(176), uint8(0), uint8(231), uint8(70), uint8(136), uint8(106), uint8(137), uint8(171), uint8(210), uint8(77), uint8(139), uint8(170), uint8(23), uint8(69), uint8(206), uint8(1), uint8(4), uint8(203), uint8(128), uint8(38), uint8(107), uint8(209), uint8(223), uint8(215), uint8(196), uint8(96), uint8(0), uint8(59), uint8(255), uint8(205), uint8(55), uint8(233), uint8(210), uint8(123), uint8(136), uint8(154), uint8(244), uint8(52), uint8(152), uint8(0), uint8(151), uint8(77), uint8(15), uint8(53), uint8(211), uint8(189), uint8(190), uint8(252), uint8(2), uint8(90), uint8(49), uint8(87), uint8(154), uint8(162), uint8(224), uint8(255), uint8(5), uint8(158), uint8(36), uint8(0), uint8(71), uint8(109), uint8(14), uint8(117), uint8(189), uint8(61), uint8(254), uint8(133), uint8(43), uint8(202), uint8(185), uint8(141), uint8(184), uint8(214), uint8(254), uint8(141), uint8(123), uint8(228), uint8(239), uint8(107), uint8(4), uint8(78), uint8(89), uint8(210), uint8(8), uint8(133), uint8(142), uint8(249), uint8(154), uint8(239), uint8(248), uint8(127), uint8(135), uint8(221), uint8(127), uint8(75), uint8(22), uint8(164), uint8(11), uint8(141), uint8(252), uint8(3), uint8(16), uint8(75), uint8(29), uint8(249), uint8(21), uint8(229), uint8(210), uint8(10), uint8(179), uint8(216), uint8(27), uint8(220), uint8(255), uint8(59), uint8(169), uint8(101), uint8(146), uint8(105), uint8(47), uint8(87), uint8(22), uint8(196), uint8(123), uint8(214), uint8(230), uint8(3), uint8(150), uint8(181), uint8(32), uint8(38), uint8(158), uint8(254), uint8(244), uint8(162), uint8(112), uint8(254), uint8(235), uint8(234), uint8(186), uint8(79), uint8(220), uint8(37), uint8(225), uint8(16), uint8(168), uint8(182), uint8(115), uint8(102), uint8(15), uint8(89), uint8(131), uint8(1), uint8(70), uint8(89), uint8(210), uint8(13), uint8(151), uint8(124), uint8(103), uint8(189), uint8(98), uint8(186), uint8(47), uint8(35), uint8(175), uint8(51), uint8(10), uint8(240), uint8(233), uint8(238), uint8(60), uint8(176), uint8(29), uint8(89), uint8(80), uint8(172), uint8(140), uint8(14), uint8(116), uint8(4), uint8(191), uint8(155), uint8(13), uint8(6), uint8(27), uint8(157), uint8(126), uint8(254), uint8(4), uint8(185), uint8(215), uint8(236), uint8(84), uint8(53), uint8(35), uint8(82), uint8(252), uint8(191), uint8(229), uint8(240), uint8(69), uint8(252), uint8(42), uint8(92), uint8(4), uint8(194), uint8(70), uint8(85), uint8(106), uint8(45), uint8(89), uint8(131), uint8(73), uint8(178), uint8(127), uint8(1), uint8(102), uint8(47), uint8(144), uint8(118), uint8(62), uint8(102), uint8(175), uint8(231), uint8(196), uint8(221), uint8(216), uint8(255), uint8(175), uint8(56), uint8(68), uint8(51), uint8(47), uint8(254), uint8(71), uint8(254), uint8(1), uint8(159), uint8(63), uint8(170), uint8(28), uint8(31), uint8(232), uint8(21), uint8(18), uint8(9), uint8(195), uint8(131), uint8(32), uint8(2), uint8(39), uint8(167), uint8(169), uint8(247), uint8(191), uint8(208), uint8(68), uint8(109), uint8(180), uint8(154), uint8(220), uint8(239), uint8(190), uint8(126), uint8(234), uint8(93), uint8(242), uint8(47), uint8(143), uint8(143), uint8(62), uint8(212), uint8(187), uint8(228), uint8(38), uint8(207), uint8(143), uint8(19), uint8(194), uint8(16), uint8(184), uint8(75), uint8(207), uint8(13), uint8(24), uint8(248), uint8(248), uint8(11), uint8(0), uint8(151), uint8(5), uint8(106), uint8(125), uint8(237), uint8(143), uint8(189), uint8(124), uint8(190), uint8(16), uint8(234), uint8(38), uint8(21), uint8(18), uint8(170), uint8(6), uint8(221), uint8(197), uint8(105), uint8(150), uint8(15), uint8(7), uint8(132), uint8(145), uint8(55), uint8(142), uint8(132), uint8(90), uint8(110), uint8(132), uint8(167), uint8(231), uint8(67), uint8(139), uint8(5), uint8(108), uint8(158), uint8(207), uint8(172), uint8(193), uint8(8), uint8(68), uint8(18), uint8(85), uint8(116), uint8(202), uint8(95), uint8(195), uint8(88), uint8(68), uint8(176), uint8(174), uint8(29), uint8(247), uint8(203), uint8(18), uint8(197), uint8(197), uint8(136), uint8(41), uint8(199), uint8(3), uint8(179), uint8(187), uint8(103), uint8(0), uint8(12), uint8(94), uint8(238), uint8(211), uint8(116), uint8(33), uint8(71), uint8(162), uint8(105), uint8(90), uint8(15), uint8(180), uint8(95), uint8(4), uint8(1), uint8(144), uint8(66), uint8(17), uint8(130), uint8(104), uint8(38), uint8(71), uint8(74), uint8(151), uint8(17), uint8(208), uint8(129), uint8(193), uint8(121), uint8(108), uint8(46), uint8(220), uint8(147), uint8(183), uint8(61), uint8(64), uint8(0), uint8(0), uint8(1), uint8(159), uint8(65), uint8(154), uint8(96), uint8(223), uint8(225), uint8(254), uint8(121), uint8(75), uint8(58), uint8(220), uint8(38), uint8(255), uint8(215), uint8(6), uint8(124), uint8(0), uint8(78), uint8(105), uint8(121), uint8(244), uint8(96), uint8(191), uint8(235), uint8(94), uint8(142), uint8(21), uint8(111), uint8(50), uint8(240), uint8(96), uint8(64), uint8(255), uint8(206), uint8(239), uint8(102), uint8(110), uint8(151), uint8(240), uint8(222), uint8(222), uint8(124), uint8(201), uint8(80), uint8(127), uint8(227), uint8(214), uint8(183), uint8(180), uint8(190), uint8(23), uint8(39), uint8(0), uint8(6), uint8(156), uint8(66), uint8(93), uint8(149), uint8(115), uint8(250), uint8(72), uint8(190), uint8(98), uint8(215), uint8(95), uint8(209), uint8(185), uint8(184), uint8(92), uint8(78), uint8(0), uint8(113), uint8(199), uint8(165), uint8(192), uint8(205), uint8(58), uint8(225), uint8(133), uint8(128), uint8(155), uint8(124), uint8(191), uint8(23), uint8(192), uint8(204), uint8(41), uint8(98), uint8(247), uint8(101), uint8(218), uint8(183), uint8(0), uint8(40), uint8(205), uint8(23), uint8(99), uint8(250), uint8(254), uint8(79), uint8(91), uint8(198), uint8(215), uint8(26), uint8(76), uint8(48), uint8(3), uint8(23), uint8(239), uint8(171), uint8(238), uint8(218), uint8(189), uint8(224), uint8(105), uint8(91), uint8(47), uint8(198), uint8(252), uint8(217), uint8(35), uint8(174), uint8(188), uint8(245), uint8(160), uint8(190), uint8(237), uint8(47), uint8(27), uint8(44), uint8(159), uint8(217), uint8(67), uint8(177), uint8(106), uint8(122), uint8(190), uint8(255), uint8(154), uint8(35), uint8(230), uint8(50), uint8(189), uint8(123), uint8(103), uint8(5), uint8(48), uint8(138), uint8(251), uint8(140), uint8(214), uint8(239), uint8(131), uint8(125), uint8(128), uint8(242), uint8(179), uint8(28), uint8(31), uint8(239), uint8(136), uint8(164), uint8(33), uint8(105), uint8(117), uint8(227), uint8(247), uint8(151), uint8(202), uint8(117), uint8(172), uint8(118), uint8(183), uint8(172), uint8(13), uint8(181), uint8(99), uint8(121), uint8(52), uint8(216), uint8(9), uint8(254), uint8(111), uint8(147), uint8(242), uint8(243), uint8(220), uint8(20), uint8(141), uint8(243), uint8(3), uint8(9), uint8(244), uint8(19), uint8(123), uint8(239), uint8(201), uint8(63), uint8(124), uint8(158), uint8(17), uint8(4), uint8(34), uint8(196), uint8(122), uint8(146), uint8(114), uint8(29), uint8(89), uint8(192), uint8(118), uint8(181), uint8(242), uint8(248), uint8(46), uint8(242), uint8(225), uint8(168), uint8(158), uint8(98), uint8(56), uint8(32), uint8(61), uint8(1), uint8(250), uint8(38), uint8(129), uint8(96), uint8(244), uint8(27), uint8(151), uint8(192), uint8(192), uint8(115), uint8(133), uint8(175), uint8(151), uint8(193), uint8(135), uint8(225), uint8(16), uint8(86), uint8(47), uint8(4), uint8(109), uint8(36), uint8(189), uint8(238), uint8(247), uint8(115), uint8(43), uint8(95), uint8(133), uint8(255), uint8(146), uint8(47), uint8(181), uint8(164), uint8(255), uint8(0), uint8(11), uint8(231), uint8(93), uint8(223), uint8(219), uint8(131), uint8(252), uint8(159), uint8(215), uint8(227), uint8(66), uint8(33), uint8(192), uint8(132), uint8(1), uint8(10), uint8(215), uint8(61), uint8(15), uint8(237), uint8(130), uint8(150), uint8(20), uint8(46), uint8(246), uint8(10), uint8(237), uint8(253), uint8(133), uint8(171), uint8(127), uint8(224), uint8(3), uint8(32), uint8(171), uint8(231), uint8(148), uint8(63), uint8(224), uint8(1), uint8(183), uint8(167), uint8(214), uint8(72), uint8(242), uint8(159), uint8(8), uint8(118), uint8(208), uint8(32), uint8(132), uint8(73), uint8(147), uint8(215), uint8(2), uint8(135), uint8(8), uint8(240), uint8(201), uint8(143), uint8(143), uint8(128), uint8(177), uint8(22), uint8(160), uint8(118), uint8(109), uint8(121), uint8(210), uint8(141), uint8(53), uint8(242), uint8(248), uint8(91), uint8(8), uint8(112), uint8(136), uint8(100), uint8(74), uint8(168), uint8(2), uint8(22), uint8(144), uint8(34), uint8(156), uint8(106), uint8(212), uint8(210), uint8(76), uint8(52), uint8(51), uint8(230), uint8(9), uint8(109), uint8(132), uint8(183), uint8(129), uint8(41), uint8(154), uint8(200), uint8(255), uint8(83), uint8(255), uint8(128), uint8(202), uint8(99), uint8(147), uint8(43), uint8(250), uint8(223), uint8(254), uint8(179), uint8(4), uint8(20), uint8(20), uint8(107), uint8(85), uint8(93), uint8(50), uint8(172), uint8(24), uint8(112), uint8(175), uint8(54), uint8(47), uint8(224), uint8(210), uint8(76), uint8(128), uint8(192), uint8(98), uint8(1), uint8(153), uint8(129), uint8(212), uint8(57), uint8(104), uint8(251), uint8(172), uint8(95), uint8(13), uint8(139), uint8(126), uint8(164), uint8(206), uint8(191), uint8(94), uint8(17), uint8(239), uint8(253), uint8(120), uint8(67), uint8(123), uint8(162), uint8(29), uint8(48), uint8(0), uint8(0), uint8(1), uint8(135), uint8(65), uint8(154), uint8(128), uint8(223), uint8(225), uint8(254), uint8(25), uint8(123), uint8(217), uint8(77), uint8(156), uint8(9), uint8(174), uint8(217), uint8(218), uint8(87), uint8(205), uint8(9), uint8(109), uint8(52), uint8(84), uint8(7), uint8(31), uint8(20), uint8(32), uint8(2), uint8(239), uint8(249), uint8(210), uint8(12), uint8(252), uint8(107), uint8(73), uint8(159), uint8(122), uint8(56), uint8(245), uint8(183), uint8(31), uint8(248), uint8(94), uint8(31), uint8(158), uint8(177), uint8(215), uint8(8), uint8(133), uint8(250), uint8(126), uint8(223), uint8(127), uint8(4), uint8(126), uint8(251), uint8(202), uint8(215), uint8(0), uint8(10), uint8(252), uint8(56), uint8(72), uint8(0), uint8(58), uint8(99), uint8(202), uint8(196), uint8(147), uint8(185), uint8(118), uint8(189), uint8(230), uint8(154), uint8(65), uint8(36), uint8(52), uint8(149), uint8(202), uint8(63), uint8(252), uint8(6), uint8(120), uint8(4), uint8(120), uint8(0), uint8(215), uint8(229), uint8(87), uint8(191), uint8(62), uint8(224), uint8(7), uint8(239), uint8(114), uint8(149), uint8(235), uint8(111), uint8(13), uint8(147), uint8(93), uint8(38), uint8(156), uint8(24), uint8(88), uint8(167), uint8(95), uint8(239), uint8(128), uint8(98), uint8(165), uint8(226), uint8(150), uint8(209), uint8(95), uint8(206), uint8(124), uint8(124), uint8(172), uint8(199), uint8(7), uint8(250), uint8(248), uint8(140), uint8(174), uint8(90), uint8(212), uint8(18), uint8(209), uint8(5), uint8(77), uint8(224), uint8(230), uint8(156), uint8(96), uint8(59), uint8(209), uint8(123), uint8(111), uint8(48), uint8(62), uint8(176), uint8(85), uint8(102), uint8(178), uint8(1), uint8(76), uint8(169), uint8(237), uint8(190), uint8(190), uint8(17), uint8(12), uint8(137), uint8(103), uint8(241), uint8(122), uint8(233), uint8(252), uint8(187), uint8(79), uint8(227), uint8(184), uint8(252), uint8(190), uint8(35), uint8(160), uint8(142), uint8(27), uint8(62), uint8(95), uint8(127), uint8(234), uint8(111), uint8(47), uint8(130), uint8(239), uint8(146), uint8(21), uint8(35), uint8(87), uint8(181), uint8(17), uint8(193), uint8(60), uint8(3), uint8(12), uint8(96), uint8(114), uint8(210), uint8(96), uint8(14), uint8(142), uint8(76), uint8(164), uint8(124), uint8(191), uint8(1), uint8(164), uint8(227), uint8(120), uint8(39), uint8(203), uint8(225), uint8(14), uint8(112), uint8(140), uint8(34), uint8(81), uint8(165), uint8(199), uint8(119), uint8(175), uint8(195), uint8(38), uint8(159), uint8(254), uint8(255), uint8(0), uint8(33), uint8(31), uint8(239), uint8(175), uint8(251), uint8(248), uint8(127), uint8(147), uint8(211), uint8(241), uint8(60), uint8(76), uint8(56), uint8(42), uint8(0), uint8(100), uint8(2), uint8(191), uint8(160), uint8(47), uint8(20), uint8(238), uint8(148), uint8(62), uint8(210), uint8(99), uint8(35), uint8(129), uint8(246), uint8(195), uint8(130), uint8(101), uint8(133), uint8(61), uint8(126), uint8(0), uint8(31), uint8(101), uint8(177), uint8(146), uint8(217), uint8(186), uint8(127), uint8(175), uint8(192), uint8(5), uint8(231), uint8(33), uint8(22), uint8(111), uint8(226), uint8(239), uint8(170), uint8(225), uint8(0), uint8(134), uint8(150), uint8(225), uint8(24), uint8(84), uint8(67), uint8(190), uint8(243), uint8(224), uint8(52), uint8(134), uint8(200), uint8(36), uint8(153), uint8(5), uint8(52), uint8(99), uint8(179), uint8(64), uint8(26), uint8(156), uint8(56), uint8(200), uint8(119), uint8(251), uint8(95), uint8(154), uint8(192), uint8(13), uint8(152), uint8(177), uint8(246), uint8(79), uint8(181), uint8(250), uint8(194), uint8(1), uint8(0), uint8(128), uint8(68), uint8(24), uint8(9), uint8(207), uint8(225), uint8(176), uint8(81), uint8(191), uint8(144), uint8(223), uint8(255), uint8(197), uint8(47), uint8(211), uint8(173), uint8(4), uint8(20), uint8(17), uint8(241), uint8(172), uint8(73), uint8(80), uint8(218), uint8(172), uint8(24), uint8(4), uint8(18), uint8(10), uint8(241), uint8(60), uint8(95), uint8(192), uint8(225), uint8(5), uint8(57), uint8(144), uint8(129), uint8(68), uint8(16), uint8(18), uint8(144), uint8(160), uint8(210), uint8(28), uint8(185), uint8(208), uint8(185), uint8(4), uint8(127), uint8(246), uint8(190), uint8(83), uint8(5), uint8(198), uint8(35), uint8(152), uint8(38), uint8(158), uint8(72), uint8(132), uint8(55), uint8(107), uint8(245), uint8(225), uint8(29), uint8(47), uint8(250), uint8(132), uint8(54), uint8(185), uint8(100), uint8(8), uint8(132), uint8(219), uint8(205), uint8(254), uint8(218), uint8(11), uint8(29), uint8(48), uint8(0), uint8(0), uint8(1), uint8(168), uint8(65), uint8(154), uint8(160), uint8(222), uint8(171), uint8(195), uint8(16), uint8(53), uint8(109), uint8(37), uint8(19), uint8(170), uint8(6), uint8(190), uint8(224), uint8(176), uint8(152), uint8(112), uint8(128), uint8(76), uint8(217), uint8(67), uint8(70), uint8(250), uint8(4), uint8(21), uint8(89), uint8(97), uint8(19), uint8(71), uint8(48), uint8(33), uint8(181), uint8(107), uint8(192), uint8(127), uint8(57), uint8(100), uint8(219), uint8(174), uint8(122), uint8(28), uint8(78), uint8(24), uint8(33), uint8(172), uint8(196), uint8(112), uint8(254), uint8(27), uint8(243), uint8(118), uint8(112), uint8(174), uint8(191), uint8(255), uint8(193), uint8(54), uint8(71), uint8(253), uint8(110), uint8(219), uint8(120), uint8(152), uint8(96), uint8(150), uint8(231), uint8(234), uint8(0), uint8(29), uint8(40), uint8(140), uint8(235), uint8(234), uint8(241), uint8(112), uint8(87), uint8(127), uint8(128), uint8(36), uint8(58), uint8(172), uint8(153), uint8(63), uint8(124), uint8(189), uint8(243), uint8(165), uint8(211), uint8(59), uint8(212), uint8(192), uint8(68), uint8(195), uint8(158), uint8(0), uint8(1), uint8(246), uint8(155), uint8(81), uint8(162), uint8(131), uint8(221), uint8(216), uint8(30), uint8(221), uint8(192), uint8(8), uint8(107), uint8(73), uint8(211), uint8(119), uint8(239), uint8(231), uint8(182), uint8(241), uint8(81), uint8(166), uint8(1), uint8(6), uint8(146), uint8(143), uint8(7), uint8(252), uint8(0), uint8(115), uint8(181), uint8(29), uint8(169), uint8(102), uint8(129), uint8(176), uint8(147), uint8(235), uint8(174), uint8(250), uint8(252), uint8(8), uint8(125), uint8(182), uint8(0), uint8(170), uint8(35), uint8(173), uint8(175), uint8(122), uint8(254), uint8(183), uint8(52), uint8(80), uint8(237), uint8(196), uint8(113), uint8(174), uint8(183), uint8(117), uint8(83), uint8(158), uint8(153), uint8(2), uint8(204), uint8(151), uint8(251), uint8(251), uint8(33), uint8(250), uint8(70), uint8(52), uint8(69), uint8(222), uint8(176), uint8(166), uint8(50), uint8(53), uint8(129), uint8(140), uint8(197), uint8(101), uint8(160), uint8(53), uint8(92), uint8(59), uint8(87), uint8(105), uint8(58), uint8(241), uint8(233), uint8(192), uint8(1), uint8(221), uint8(223), uint8(159), uint8(189), uint8(155), uint8(13), uint8(131), uint8(86), uint8(81), uint8(68), uint8(25), uint8(40), uint8(210), uint8(168), uint8(116), uint8(92), uint8(191), uint8(136), uint8(194), uint8(40), uint8(34), uint8(9), uint8(133), uint8(206), uint8(78), uint8(178), uint8(185), uint8(226), uint8(242), uint8(188), uint8(68), uint8(42), uint8(124), uint8(75), uint8(155), uint8(191), uint8(19), uint8(175), uint8(71), uint8(31), uint8(229), uint8(240), uint8(93), uint8(241), uint8(97), uint8(16), uint8(247), uint8(49), uint8(18), uint8(199), uint8(19), uint8(197), uint8(115), uint8(17), uint8(197), uint8(104), uint8(21), uint8(66), uint8(216), uint8(17), uint8(22), uint8(78), uint8(215), uint8(224), uint8(21), uint8(180), uint8(107), uint8(163), uint8(242), uint8(255), uint8(194), uint8(48), uint8(152), uint8(43), uint8(23), uint8(203), uint8(143), uint8(110), uint8(238), uint8(231), uint8(165), uint8(182), uint8(79), uint8(174), uint8(32), uint8(78), uint8(17), uint8(116), uint8(71), uint8(221), uint8(10), uint8(184), uint8(92), uint8(33), uint8(252), uint8(0), uint8(41), uint8(126), uint8(83), uint8(229), uint8(233), uint8(127), uint8(253), uint8(189), uint8(81), uint8(177), uint8(43), uint8(12), uint8(67), uint8(245), uint8(240), uint8(16), uint8(66), uint8(238), uint8(208), uint8(67), uint8(122), uint8(128), uint8(116), uint8(98), uint8(53), uint8(102), uint8(191), uint8(50), uint8(35), uint8(231), uint8(255), uint8(212), uint8(2), uint8(226), uint8(181), uint8(91), uint8(244), uint8(255), uint8(190), uint8(174), uint8(16), uint8(8), uint8(104), uint8(191), uint8(133), uint8(2), uint8(1), uint8(28), uint8(34), uint8(21), uint8(17), uint8(184), uint8(45), uint8(125), uint8(138), uint8(63), uint8(72), uint8(0), uint8(64), uint8(238), uint8(192), uint8(8), uint8(217), uint8(190), uint8(38), uint8(223), uint8(124), uint8(12), uint8(78), uint8(186), uint8(118), uint8(135), uint8(248), uint8(0), uint8(200), uint8(189), uint8(41), uint8(181), uint8(126), uint8(248), uint8(25), uint8(119), uint8(109), uint8(53), uint8(143), uint8(250), uint8(208), uint8(67), uint8(5), uint8(2), uint8(220), uint8(67), uint8(157), uint8(222), uint8(218), uint8(208), uint8(64), uint8(208), uint8(74), uint8(89), uint8(51), uint8(166), uint8(211), uint8(73), uint8(21), uint8(96), uint8(186), uint8(120), uint8(100), uint8(70), uint8(108), uint8(129), uint8(181), uint8(192), uint8(149), uint8(78), uint8(176), uint8(63), uint8(255), uint8(175), uint8(8), uint8(233), uint8(127), uint8(240), uint8(65), uint8(244), uint8(32), uint8(104), uint8(118), uint8(79), uint8(216), uint8(75), uint8(140), uint8(203), uint8(255), uint8(208), uint8(225), uint8(109), uint8(128), uint8(0), uint8(0), uint8(1), uint8(179), uint8(65), uint8(154), uint8(192), uint8(223), uint8(225), uint8(184), uint8(25), uint8(111), uint8(183), uint8(250), uint8(9), uint8(134), uint8(226), uint8(65), uint8(50), uint8(204), uint8(178), uint8(7), uint8(192), uint8(44), uint8(230), uint8(221), uint8(243), uint8(9), uint8(184), uint8(200), uint8(208), uint8(106), uint8(62), uint8(27), uint8(128), uint8(155), uint8(95), uint8(30), uint8(249), uint8(107), uint8(110), uint8(216), uint8(13), uint8(112), uint8(151), uint8(181), uint8(126), uint8(180), uint8(223), uint8(145), uint8(253), uint8(31), uint8(45), uint8(186), uint8(240), uint8(65), uint8(224), uint8(0), uint8(203), uint8(217), uint8(17), uint8(185), uint8(54), uint8(201), uint8(19), uint8(151), uint8(147), uint8(125), uint8(236), uint8(161), uint8(169), uint8(20), uint8(67), uint8(4), uint8(63), uint8(93), uint8(184), uint8(74), uint8(38), uint8(34), uint8(134), uint8(0), uint8(66), uint8(247), uint8(221), uint8(110), uint8(240), uint8(236), uint8(228), uint8(136), uint8(226), uint8(46), uint8(221), uint8(219), uint8(242), uint8(26), uint8(151), uint8(72), uint8(74), uint8(92), uint8(126), uint8(3), uint8(206), uint8(155), uint8(19), uint8(221), uint8(143), uint8(122), uint8(79), uint8(164), uint8(205), uint8(23), uint8(241), uint8(162), uint8(58), uint8(95), uint8(22), uint8(141), uint8(27), uint8(127), uint8(95), uint8(104), uint8(51), uint8(229), uint8(55), uint8(203), uint8(25), uint8(133), uint8(189), uint8(104), uint8(238), uint8(139), uint8(210), uint8(238), uint8(90), uint8(11), uint8(59), uint8(151), uint8(75), uint8(121), uint8(155), uint8(97), uint8(233), uint8(134), uint8(35), uint8(223), uint8(239), uint8(4), uint8(51), uint8(35), uint8(172), uint8(21), uint8(52), uint8(109), uint8(172), uint8(217), uint8(104), uint8(50), uint8(55), uint8(195), uint8(177), uint8(187), uint8(224), uint8(223), uint8(128), uint8(113), uint8(29), uint8(206), uint8(15), uint8(247), uint8(196), uint8(180), uint8(34), uint8(144), uint8(104), uint8(64), uint8(154), uint8(54), uint8(144), uint8(211), uint8(37), uint8(111), uint8(192), uint8(107), uint8(62), uint8(19), uint8(91), uint8(238), uint8(203), uint8(178), uint8(233), uint8(217), uint8(96), uint8(54), uint8(108), uint8(91), uint8(169), uint8(23), uint8(172), uint8(127), uint8(202), uint8(174), uint8(152), uint8(111), uint8(180), uint8(222), uint8(250), uint8(190), uint8(17), uint8(26), uint8(37), uint8(98), uint8(14), uint8(86), uint8(32), uint8(144), uint8(30), uint8(211), uint8(224), uint8(240), uint8(221), uint8(151), uint8(147), uint8(80), uint8(78), uint8(146), uint8(212), uint8(156), uint8(37), uint8(59), uint8(210), uint8(2), uint8(187), uint8(175), uint8(246), uint8(66), uint8(227), uint8(97), uint8(247), uint8(151), uint8(94), uint8(188), uint8(66), uint8(12), uint8(149), uint8(4), uint8(125), uint8(233), uint8(93), uint8(192), uint8(218), uint8(58), uint8(220), uint8(105), uint8(84), uint8(162), uint8(142), uint8(126), uint8(130), uint8(90), uint8(87), uint8(229), uint8(240), uint8(109), uint8(229), uint8(18), uint8(17), uint8(13), uint8(231), uint8(143), uint8(220), uint8(17), uint8(251), uint8(219), uint8(194), uint8(47), uint8(15), uint8(125), uint8(126), uint8(81), uint8(239), uint8(119), uint8(248), uint8(100), uint8(68), uint8(30), uint8(253), uint8(208), uint8(0), uint8(255), uint8(129), uint8(9), uint8(201), uint8(163), uint8(70), uint8(120), uint8(63), uint8(201), uint8(233), uint8(248), uint8(159), uint8(97), uint8(192), uint8(132), uint8(0), uint8(217), uint8(44), uint8(237), uint8(43), uint8(165), uint8(111), uint8(16), uint8(68), uint8(99), uint8(85), uint8(32), uint8(17), uint8(0), uint8(255), uint8(240), uint8(2), uint8(105), uint8(249), uint8(165), uint8(95), uint8(158), uint8(255), uint8(128), uint8(18), uint8(181), uint8(17), uint8(207), uint8(255), uint8(42), uint8(225), uint8(0), uint8(132), uint8(152), uint8(119), uint8(223), uint8(137), uint8(32), uint8(100), uint8(172), uint8(197), uint8(248), uint8(1), uint8(240), uint8(193), uint8(128), uint8(255), uint8(47), uint8(129), uint8(4), uint8(140), uint8(32), uint8(62), uint8(16), uint8(8), uint8(134), uint8(77), uint8(169), uint8(176), uint8(41), uint8(17), uint8(112), uint8(180), uint8(222), uint8(31), uint8(253), uint8(100), uint8(8), uint8(96), uint8(160), uint8(162), uint8(183), uint8(119), uint8(63), uint8(63), uint8(45), uint8(191), uint8(154), uint8(101), uint8(47), uint8(142), uint8(230), uint8(225), uint8(146), uint8(147), uint8(21), uint8(223), uint8(47), uint8(133), uint8(47), uint8(87), uint8(30), uint8(245), uint8(131), uint8(9), uint8(194), uint8(40), uint8(197), uint8(77), uint8(120), uint8(71), uint8(75), uint8(254), uint8(240), uint8(208), uint8(118), uint8(3), uint8(169), uint8(174), uint8(237), uint8(248), uint8(0), uint8(135), uint8(238), uint8(231), uint8(89), uint8(249), uint8(124), uint8(225), uint8(19), uint8(125), uint8(4), uint8(146), uint8(42), uint8(198), uint8(112), uint8(208), uint8(169), uint8(188), uint8(222), uint8(181), uint8(135), uint8(240), uint8(15), uint8(128), uint8(0), uint8(0), uint8(1), uint8(30), uint8(65), uint8(154), uint8(224), uint8(71), uint8(248), uint8(111), uint8(128), uint8(160), uint8(189), uint8(170), uint8(74), uint8(114), uint8(155), uint8(156), uint8(116), uint8(57), uint8(14), uint8(55), uint8(252), uint8(55), uint8(88), uint8(113), uint8(237), uint8(112), uint8(32), uint8(255), uint8(110), uint8(231), uint8(255), uint8(4), uint8(111), uint8(143), uint8(59), uint8(144), uint8(159), uint8(118), uint8(34), uint8(39), uint8(225), uint8(99), uint8(96), uint8(1), uint8(118), uint8(251), uint8(171), uint8(254), uint8(254), uint8(239), uint8(240), uint8(1), uint8(127), uint8(25), uint8(20), uint8(125), uint8(251), uint8(122), uint8(6), uint8(164), uint8(107), uint8(220), uint8(236), uint8(171), uint8(238), uint8(142), uint8(174), uint8(18), uint8(61), uint8(119), uint8(172), uint8(243), uint8(9), uint8(96), uint8(140), uint8(250), uint8(254), uint8(79), uint8(47), uint8(227), uint8(176), uint8(138), uint8(133), uint8(68), uint8(233), uint8(249), uint8(193), uint8(160), uint8(74), uint8(203), uint8(130), uint8(150), uint8(10), uint8(93), uint8(128), uint8(228), uint8(232), uint8(198), uint8(189), uint8(243), uint8(124), uint8(239), uint8(8), uint8(42), uint8(199), uint8(86), uint8(117), uint8(255), uint8(12), uint8(209), uint8(148), uint8(14), uint8(149), uint8(238), uint8(22), uint8(73), uint8(219), uint8(246), uint8(222), uint8(245), uint8(145), uint8(31), uint8(243), uint8(59), uint8(212), uint8(181), uint8(255), uint8(151), uint8(253), uint8(132), uint8(225), uint8(16), uint8(80), uint8(115), uint8(17), uint8(93), uint8(109), uint8(107), uint8(95), uint8(130), uint8(0), uint8(138), uint8(61), uint8(203), uint8(232), uint8(174), uint8(250), uint8(59), uint8(252), uint8(103), uint8(180), uint8(79), uint8(107), uint8(252), uint8(34), uint8(8), uint8(122), uint8(195), uint8(65), uint8(192), uint8(105), uint8(38), uint8(72), uint8(64), uint8(247), uint8(192), uint8(2), uint8(98), uint8(93), uint8(240), uint8(84), uint8(97), uint8(254), uint8(72), uint8(100), uint8(167), uint8(243), uint8(83), uint8(137), uint8(23), uint8(173), uint8(107), uint8(62), uint8(95), uint8(132), uint8(5), uint8(4), uint8(6), uint8(20), uint8(88), uint8(68), uint8(54), uint8(104), uint8(6), uint8(188), uint8(140), uint8(46), uint8(101), uint8(184), uint8(0), uint8(115), uint8(180), uint8(213), uint8(223), uint8(110), uint8(252), uint8(0), uint8(100), uint8(178), uint8(220), uint8(209), uint8(45), uint8(255), uint8(187), uint8(151), uint8(197), uint8(4), uint8(56), uint8(68), uint8(208), uint8(70), uint8(113), uint8(88), uint8(172), uint8(119), uint8(5), uint8(188), uint8(128), uint8(198), uint8(95), uint8(21), uint8(127), uint8(10), uint8(205), uint8(154), uint8(90), uint8(170), uint8(69), uint8(227), uint8(173), uint8(87), uint8(119), uint8(215), uint8(156), uint8(34), uint8(9), uint8(13), uint8(195), uint8(126), uint8(139), uint8(175), uint8(175), uint8(175), uint8(107), uint8(156), uint8(34), uint8(26), uint8(9), uint8(159), uint8(13), uint8(244), uint8(5), uint8(192), uint8(143), uint8(85), uint8(95), uint8(136), uint8(239), uint8(240), uint8(168), uint8(133), uint8(90), uint8(75), uint8(89), uint8(208), uint8(148), uint8(191), uint8(142), uint8(172), uint8(255), uint8(130), uint8(113), uint8(78), uint8(239), uint8(89), uint8(190), uint8(59), uint8(152), uint8(0), uint8(0), uint8(1), uint8(196), uint8(65), uint8(155), uint8(0), uint8(71), uint8(248), uint8(111), uint8(128), uint8(180), uint8(153), uint8(213), uint8(98), uint8(198), uint8(101), uint8(141), uint8(96), uint8(5), uint8(29), uint8(127), uint8(39), uint8(195), uint8(214), uint8(27), uint8(248), uint8(201), uint8(195), uint8(96), uint8(248), uint8(111), uint8(134), uint8(60), uint8(133), uint8(229), uint8(204), uint8(162), uint8(154), uint8(77), uint8(15), uint8(157), uint8(248), uint8(12), uint8(70), uint8(229), uint8(249), uint8(236), uint8(191), uint8(139), uint8(248), uint8(92), uint8(156), uint8(0), uint8(62), uint8(91), uint8(250), uint8(186), uint8(223), uint8(187), uint8(232), uint8(198), uint8(115), uint8(33), uint8(162), uint8(118), uint8(173), uint8(232), uint8(136), uint8(67), uint8(86), uint8(160), uint8(17), uint8(10), uint8(218), uint8(224), uint8(7), uint8(151), uint8(237), uint8(42), uint8(170), uint8(220), uint8(0), uint8(160), uint8(170), uint8(139), uint8(155), uint8(87), uint8(242), uint8(122), uint8(118), uint8(42), uint8(187), uint8(141), uint8(38), uint8(30), uint8(89), uint8(233), uint8(38), uint8(109), uint8(77), uint8(248), uint8(33), uint8(252), uint8(254), uint8(170), uint8(7), uint8(0), uint8(16), uint8(107), uint8(235), uint8(245), uint8(115), uint8(254), uint8(227), uint8(83), uint8(70), uint8(14), uint8(186), uint8(251), uint8(251), uint8(240), uint8(70), uint8(41), uint8(10), uint8(163), uint8(221), uint8(215), uint8(213), uint8(123), uint8(150), uint8(127), uint8(2), uint8(154), uint8(30), uint8(156), uint8(253), uint8(24), uint8(0), uint8(215), uint8(252), uint8(85), uint8(228), uint8(254), uint8(176), uint8(65), uint8(133), uint8(68), uint8(67), uint8(162), uint8(118), uint8(208), uint8(49), uint8(156), uint8(140), uint8(255), uint8(128), uint8(246), uint8(190), uint8(103), uint8(86), uint8(121), uint8(11), uint8(204), uint8(14), uint8(90), uint8(140), uint8(49), uint8(149), uint8(175), uint8(26), uint8(151), uint8(142), uint8(255), uint8(215), uint8(210), uint8(205), uint8(175), uint8(147), uint8(245), uint8(8), uint8(255), uint8(12), uint8(252), uint8(160), uint8(134), uint8(201), uint8(56), uint8(60), uint8(21), uint8(36), uint8(197), uint8(69), uint8(106), uint8(249), uint8(95), uint8(175), uint8(249), uint8(235), uint8(71), uint8(235), uint8(225), uint8(16), uint8(192), uint8(209), uint8(165), uint8(158), uint8(179), uint8(17), uint8(39), uint8(108), uint8(165), uint8(129), uint8(23), uint8(207), uint8(172), uint8(178), uint8(184), uint8(143), uint8(175), uint8(198), uint8(135), uint8(67), uint8(197), uint8(202), uint8(113), uint8(177), uint8(91), uint8(169), uint8(67), uint8(41), uint8(144), uint8(156), uint8(207), uint8(106), uint8(45), uint8(127), uint8(92), uint8(173), uint8(2), uint8(207), uint8(24), uint8(30), uint8(15), uint8(236), uint8(57), uint8(38), uint8(87), uint8(127), uint8(27), uint8(249), uint8(38), uint8(64), uint8(156), uint8(62), uint8(99), uint8(154), uint8(104), uint8(75), uint8(30), uint8(47), uint8(58), uint8(240), uint8(248), uint8(134), uint8(203), uint8(36), uint8(5), uint8(93), uint8(226), uint8(58), uint8(185), uint8(172), uint8(50), uint8(30), uint8(75), uint8(239), uint8(253), uint8(0), uint8(193), uint8(234), uint8(127), uint8(236), uint8(15), uint8(255), uint8(244), uint8(144), uint8(142), uint8(28), uint8(25), uint8(0), uint8(11), uint8(233), uint8(154), uint8(190), uint8(166), uint8(219), uint8(235), uint8(90), uint8(46), uint8(171), uint8(67), uint8(217), uint8(41), uint8(136), uint8(93), uint8(81), uint8(67), uint8(110), uint8(171), uint8(133), uint8(2), uint8(48), uint8(175), uint8(6), uint8(211), uint8(46), uint8(80), uint8(73), uint8(146), uint8(99), uint8(218), uint8(95), uint8(29), uint8(0), uint8(67), uint8(241), uint8(191), uint8(159), uint8(191), uint8(240), uint8(207), uint8(179), uint8(1), uint8(210), uint8(196), uint8(0), uint8(248), uint8(8), uint8(134), uint8(159), uint8(117), uint8(47), uint8(252), uint8(190), uint8(40), uint8(33), uint8(8), uint8(4), uint8(10), uint8(44), uint8(34), uint8(24), uint8(33), uint8(239), uint8(0), uint8(79), uint8(213), uint8(174), uint8(181), uint8(125), uint8(208), uint8(22), uint8(242), uint8(248), uint8(0), uint8(62), uint8(169), uint8(180), uint8(190), uint8(95), uint8(135), uint8(128), uint8(5), uint8(207), uint8(210), uint8(250), uint8(106), uint8(79), uint8(254), uint8(250), uint8(200), uint8(16), uint8(52), uint8(18), uint8(156), uint8(52), uint8(243), uint8(243), uint8(221), uint8(189), uint8(155), uint8(212), uint8(240), uint8(175), uint8(38), uint8(3), uint8(137), uint8(102), uint8(108), uint8(241), uint8(66), uint8(188), uint8(213), uint8(0), uint8(136), uint8(106), uint8(125), uint8(210), uint8(215), uint8(127), uint8(75), uint8(194), uint8(40), uint8(197), uint8(23), uint8(125), uint8(60), uint8(33), uint8(63), uint8(207), uint8(10), uint8(139), uint8(159), uint8(49), uint8(42), uint8(133), uint8(233), uint8(196), uint8(154), uint8(74), uint8(127), uint8(91), uint8(8), uint8(194), uint8(193), uint8(158), uint8(26), uint8(73), uint8(76), uint8(246), uint8(176), uint8(133), uint8(185), uint8(255), uint8(11), uint8(138), uint8(173), uint8(93), uint8(98), uint8(124), uint8(22), uint8(169), uint8(252), uint8(94), uint8(176), uint8(0), uint8(0), uint8(1), uint8(178), uint8(65), uint8(155), uint8(32), uint8(87), uint8(87), uint8(134), uint8(235), uint8(12), uint8(123), uint8(238), uint8(2), uint8(22), uint8(166), uint8(215), uint8(251), uint8(39), uint8(223), uint8(248), uint8(68), uint8(16), uint8(135), uint8(49), uint8(112), uint8(3), uint8(20), uint8(209), uint8(13), uint8(89), uint8(53), uint8(123), uint8(192), uint8(68), uint8(37), uint8(39), uint8(192), uint8(35), uint8(220), uint8(180), uint8(95), uint8(239), uint8(128), uint8(1), uint8(255), uint8(92), uint8(168), uint8(225), uint8(39), uint8(170), uint8(106), uint8(63), uint8(110), uint8(52), uint8(152), uint8(1), uint8(247), uint8(20), uint8(105), uint8(164), uint8(189), uint8(140), uint8(127), uint8(233), uint8(199), uint8(14), uint8(111), uint8(196), uint8(40), uint8(80), uint8(122), uint8(65), uint8(26), uint8(212), uint8(7), uint8(159), uint8(147), uint8(99), uint8(124), uint8(236), uint8(204), uint8(191), uint8(140), uint8(189), uint8(231), uint8(140), uint8(165), uint8(5), uint8(148), uint8(23), uint8(239), uint8(33), uint8(86), uint8(204), uint8(103), uint8(122), uint8(246), uint8(206), uint8(10), uint8(97), uint8(21), uint8(247), uint8(25), uint8(173), uint8(223), uint8(6), uint8(251), uint8(1), uint8(229), uint8(102), uint8(56), uint8(63), uint8(223), uint8(13), uint8(52), uint8(132), uint8(232), uint8(4), uint8(47), uint8(119), uint8(187), uint8(135), uint8(51), uint8(235), uint8(51), uint8(27), uint8(94), uint8(248), uint8(54), uint8(213), uint8(141), uint8(228), uint8(211), uint8(96), uint8(4), uint8(127), uint8(157), uint8(82), uint8(15), uint8(57), uint8(59), uint8(226), uint8(19), uint8(79), uint8(224), uint8(75), uint8(122), uint8(9), uint8(191), uint8(187), uint8(223), uint8(124), uint8(58), uint8(112), uint8(32), uint8(5), uint8(230), uint8(134), uint8(69), uint8(207), uint8(57), uint8(156), uint8(24), uint8(11), uint8(178), uint8(28), uint8(23), uint8(130), uint8(197), uint8(228), uint8(16), uint8(63), uint8(147), uint8(0), uint8(35), uint8(103), uint8(205), uint8(26), uint8(111), uint8(247), uint8(194), uint8(151), uint8(168), uint8(72), uint8(207), uint8(117), uint8(106), uint8(254), uint8(79), uint8(92), uint8(16), uint8(255), uint8(12), uint8(248), uint8(160), uint8(0), uint8(70), uint8(40), uint8(0), uint8(48), uint8(130), uint8(204), uint8(65), uint8(67), uint8(18), uint8(3), uint8(51), uint8(255), uint8(201), uint8(235), uint8(146), uint8(19), uint8(160), uint8(136), uint8(68), uint8(62), uint8(22), uint8(8), uint8(227), uint8(213), uint8(74), uint8(124), uint8(103), uint8(252), uint8(254), uint8(9), uint8(94), uint8(94), uint8(125), uint8(181), uint8(85), uint8(10), uint8(135), uint8(2), uint8(80), uint8(0), uint8(111), uint8(232), uint8(98), uint8(42), uint8(46), uint8(213), uint8(63), uint8(17), uint8(212), uint8(202), uint8(140), uint8(214), uint8(102), uint8(38), uint8(175), uint8(255), uint8(47), uint8(252), uint8(1), uint8(50), uint8(157), uint8(180), uint8(248), uint8(254), uint8(255), uint8(224), uint8(2), uint8(89), uint8(167), uint8(73), uint8(245), uint8(223), uint8(233), uint8(127), uint8(25), uint8(194), uint8(48), uint8(169), uint8(0), uint8(122), uint8(133), uint8(199), uint8(243), uint8(248), uint8(60), uint8(176), uint8(2), uint8(110), uint8(155), uint8(21), uint8(60), uint8(1), uint8(8), uint8(189), uint8(182), uint8(26), uint8(227), uint8(246), uint8(195), uint8(141), uint8(55), uint8(173), uint8(112), uint8(200), uint8(190), uint8(10), uint8(28), uint8(52), uint8(179), uint8(206), uint8(33), uint8(101), uint8(24), uint8(159), uint8(4), uint8(34), uint8(63), uint8(0), uint8(217), uint8(101), uint8(141), uint8(138), uint8(223), uint8(107), uint8(255), uint8(92), uint8(32), uint8(22), uint8(8), uint8(130), uint8(241), uint8(82), uint8(101), uint8(194), uint8(17), uint8(127), uint8(222), uint8(3), uint8(98), uint8(230), uint8(101), uint8(30), uint8(178), uint8(147), uint8(145), uint8(74), uint8(112), uint8(20), uint8(238), uint8(176), uint8(0), uint8(109), uint8(156), uint8(86), uint8(82), uint8(255), uint8(15), uint8(4), uint8(123), uint8(216), uint8(0), uint8(199), uint8(34), uint8(22), uint8(70), uint8(187), uint8(190), uint8(31), uint8(52), uint8(42), uint8(81), uint8(44), uint8(31), uint8(203), uint8(226), uint8(31), uint8(18), uint8(15), uint8(227), uint8(19), uint8(135), uint8(47), uint8(130), uint8(107), uint8(148), uint8(34), uint8(224), uint8(146), uint8(170), uint8(182), uint8(240), uint8(97), uint8(57), uint8(12), uint8(159), uint8(135), uint8(116), uint8(87), uint8(254), uint8(255), uint8(240), uint8(135), uint8(120), uint8(66), uint8(112), uint8(137), uint8(202), uint8(190), uint8(25), uint8(181), uint8(127), uint8(249), uint8(124), uint8(225), uint8(18), uint8(124), uint8(18), uint8(148), uint8(60), uint8(41), uint8(23), uint8(206), uint8(191), uint8(137), uint8(21), uint8(100), uint8(210), uint8(225), uint8(172), uint8(20), uint8(236), uint8(46), uint8(33), uint8(239), uint8(171), uint8(169), uint8(83), uint8(249), uint8(161), uint8(88), uint8(0), uint8(0), uint8(1), uint8(251), uint8(65), uint8(155), uint8(64), uint8(103), uint8(41), uint8(63), uint8(173), uint8(252), uint8(47), uint8(224), uint8(7), uint8(169), uint8(234), uint8(189), uint8(63), uint8(135), uint8(1), uint8(61), uint8(38), uint8(213), uint8(245), uint8(55), uint8(25), uint8(2), uint8(175), uint8(14), uint8(195), uint8(253), uint8(224), uint8(9), uint8(95), uint8(250), uint8(113), uint8(57), uint8(39), uint8(182), uint8(154), uint8(254), uint8(22), uint8(38), uint8(4), uint8(229), uint8(71), uint8(53), uint8(228), uint8(235), uint8(251), uint8(189), uint8(100), uint8(23), uint8(102), uint8(46), uint8(144), uint8(120), uint8(12), uint8(116), uint8(29), uint8(132), uint8(17), uint8(187), uint8(189), uint8(106), uint8(23), uint8(32), uint8(5), uint8(13), uint8(220), uint8(175), uint8(8), uint8(102), uint8(241), uint8(47), uint8(235), uint8(255), uint8(223), uint8(121), uint8(235), uint8(130), uint8(53), uint8(61), uint8(64), uint8(211), uint8(35), uint8(127), uint8(247), uint8(223), uint8(47), uint8(224), uint8(219), uint8(194), uint8(33), uint8(99), uint8(128), uint8(158), uint8(145), uint8(157), uint8(106), uint8(243), uint8(233), uint8(73), uint8(148), uint8(19), uint8(101), uint8(167), uint8(217), uint8(225), uint8(1), uint8(86), uint8(112), uint8(145), uint8(116), uint8(45), uint8(140), uint8(92), uint8(188), uint8(56), uint8(194), uint8(223), uint8(250), uint8(93), uint8(126), uint8(25), uint8(131), uint8(105), uint8(144), uint8(245), uint8(156), uint8(7), uint8(64), uint8(116), uint8(58), uint8(99), uint8(151), uint8(240), uint8(106), uint8(28), uint8(190), uint8(45), uint8(224), uint8(64), uint8(227), uint8(65), uint8(56), uint8(31), uint8(166), uint8(82), uint8(95), uint8(3), uint8(244), uint8(202), uint8(75), uint8(225), uint8(147), uint8(145), uint8(220), uint8(201), uint8(197), uint8(223), uint8(208), uint8(156), uint8(142), uint8(230), uint8(78), uint8(46), uint8(254), uint8(54), uint8(135), uint8(192), uint8(16), uint8(147), uint8(83), uint8(213), uint8(127), uint8(176), uint8(244), uint8(154), uint8(158), uint8(171), uint8(253), uint8(165), uint8(28), uint8(135), uint8(106), uint8(82), uint8(142), uint8(67), uint8(181), uint8(32), uint8(23), uint8(21), uint8(201), uint8(253), uint8(50), uint8(113), uint8(92), uint8(159), uint8(211), uint8(50), uint8(223), uint8(187), uint8(226), uint8(59), uint8(126), uint8(239), uint8(134), uint8(168), uint8(78), uint8(134), uint8(130), uint8(143), uint8(192), uint8(8), uint8(143), uint8(194), uint8(142), uint8(236), uint8(126), uint8(108), uint8(49), uint8(90), uint8(70), uint8(200), uint8(181), uint8(123), uint8(225), uint8(85), uint8(25), uint8(164), uint8(64), uint8(198), uint8(92), uint8(232), uint8(62), uint8(217), uint8(26), uint8(70), uint8(12), uint8(101), uint8(206), uint8(48), uint8(132), uint8(98), uint8(38), uint8(0), uint8(26), uint8(156), uint8(26), uint8(246), uint8(219), uint8(201), uint8(184), uint8(31), uint8(108), uint8(137), uint8(35), uint8(4), uint8(34), uint8(231), uint8(80), uint8(204), uint8(189), uint8(106), uint8(126), uint8(253), uint8(194), uint8(16), uint8(208), uint8(128), uint8(145), uint8(1), uint8(69), uint8(234), uint8(183), uint8(209), uint8(87), uint8(71), uint8(84), uint8(130), uint8(194), uint8(245), uint8(24), uint8(241), uint8(240), uint8(239), uint8(164), uint8(17), uint8(175), uint8(226), uint8(182), uint8(233), uint8(175), uint8(220), uint8(228), uint8(156), uint8(160), uint8(253), uint8(64), uint8(198), uint8(110), uint8(112), uint8(86), uint8(55), uint8(223), uint8(210), uint8(254), uint8(12), uint8(130), uint8(24), uint8(70), uint8(30), uint8(134), uint8(166), uint8(68), uint8(107), uint8(228), uint8(30), uint8(177), uint8(85), uint8(25), uint8(226), uint8(137), uint8(50), uint8(192), uint8(93), uint8(52), uint8(25), uint8(142), uint8(106), uint8(213), uint8(241), uint8(22), uint8(131), uint8(5), uint8(59), uint8(13), uint8(225), uint8(127), uint8(128), uint8(8), uint8(141), uint8(221), uint8(175), uint8(128), uint8(140), uint8(85), uint8(118), uint8(86), uint8(114), uint8(252), uint8(0), uint8(40), uint8(181), uint8(145), uint8(204), uint8(153), uint8(151), uint8(6), uint8(124), uint8(190), uint8(110), uint8(18), uint8(8), uint8(216), uint8(47), uint8(196), uint8(39), uint8(137), uint8(222), uint8(238), uint8(31), uint8(48), uint8(15), uint8(210), uint8(93), uint8(192), uint8(241), uint8(121), uint8(192), uint8(159), uint8(203), uint8(201), uint8(114), uint8(190), uint8(159), uint8(175), uint8(112), uint8(85), uint8(27), uint8(91), uint8(183), uint8(203), uint8(137), uint8(67), uint8(79), uint8(123), uint8(50), uint8(249), uint8(34), uint8(236), uint8(34), uint8(231), uint8(233), uint8(151), uint8(241), uint8(123), uint8(176), uint8(117), uint8(7), uint8(12), uint8(57), uint8(192), uint8(64), uint8(143), uint8(182), uint8(173), uint8(90), uint8(196), uint8(47), uint8(193), uint8(41), uint8(63), uint8(224), uint8(4), uint8(94), uint8(186), uint8(61), uint8(62), uint8(251), uint8(248), uint8(0), uint8(81), uint8(50), uint8(26), uint8(35), uint8(147), uint8(185), uint8(28), uint8(143), uint8(194), uint8(58), uint8(120), uint8(46), uint8(148), uint8(120), uint8(34), uint8(196), uint8(57), uint8(225), uint8(238), uint8(21), uint8(43), uint8(138), uint8(231), uint8(199), uint8(191), uint8(168), uint8(1), uint8(34), uint8(54), uint8(175), uint8(242), uint8(249), uint8(42), uint8(94), uint8(190), uint8(201), uint8(239), uint8(96), uint8(150), uint8(10), uint8(230), uint8(8), uint8(140), uint8(97), uint8(114), uint8(123), uint8(115), uint8(113), uint8(15), uint8(63), uint8(192), uint8(27), uint8(197), uint8(216), uint8(175), uint8(68), uint8(138), uint8(178), uint8(89), uint8(135), uint8(211), uint8(1), uint8(45), uint8(204), uint8(175), uint8(238), uint8(225), uint8(192), uint8(1), uint8(243), uint8(70), uint8(37), uint8(236), uint8(92), uint8(133), uint8(202), uint8(36), uint8(0), uint8(0), uint8(1), uint8(193), uint8(65), uint8(155), uint8(96), uint8(33), uint8(203), uint8(225), uint8(204), uint8(1), uint8(144), uint8(100), uint8(201), uint8(190), uint8(212), uint8(40), uint8(180), uint8(154), uint8(96), uint8(197), uint8(237), uint8(0), uint8(112), uint8(17), uint8(224), uint8(6), uint8(108), uint8(157), uint8(249), uint8(206), uint8(0), uint8(59), uint8(47), uint8(205), uint8(114), uint8(222), uint8(253), uint8(118), uint8(234), uint8(55), uint8(154), uint8(32), uint8(0), uint8(217), uint8(122), uint8(49), uint8(248), uint8(141), uint8(162), uint8(252), uint8(251), uint8(155), uint8(112), uint8(69), uint8(238), uint8(157), uint8(244), uint8(110), uint8(204), uint8(54), uint8(91), uint8(109), uint8(98), uint8(103), uint8(105), uint8(149), uint8(101), uint8(24), uint8(245), uint8(201), uint8(95), uint8(238), uint8(176), uint8(155), uint8(101), uint8(98), uint8(179), uint8(22), uint8(75), uint8(185), uint8(233), uint8(144), uint8(40), uint8(201), uint8(239), uint8(239), uint8(236), uint8(135), uint8(121), uint8(16), uint8(106), uint8(171), uint8(235), uint8(175), uint8(20), uint8(176), uint8(158), uint8(130), uint8(110), uint8(252), uint8(255), uint8(142), uint8(231), uint8(52), uint8(59), uint8(217), uint8(193), uint8(72), uint8(22), uint8(113), uint8(103), uint8(252), uint8(195), uint8(107), uint8(209), uint8(206), uint8(168), uint8(111), uint8(122), uint8(248), uint8(68), uint8(16), uint8(240), uint8(20), uint8(23), uint8(156), uint8(200), uint8(123), uint8(200), uint8(144), uint8(214), uint8(225), uint8(24), uint8(116), uint8(72), uint8(58), uint8(88), uint8(14), uint8(172), uint8(7), uint8(175), uint8(224), uint8(196), uint8(208), uint8(96), uint8(218), uint8(65), uint8(219), uint8(132), uint8(15), uint8(117), uint8(7), uint8(5), uint8(192), uint8(3), uint8(96), uint8(203), uint8(242), uint8(95), uint8(73), uint8(183), uint8(54), uint8(185), uint8(237), uint8(255), uint8(128), uint8(37), uint8(55), uint8(164), uint8(125), uint8(125), uint8(26), uint8(251), uint8(60), uint8(98), uint8(29), uint8(182), uint8(205), uint8(60), uint8(27), uint8(126), uint8(62), uint8(240), uint8(247), uint8(191), uint8(80), uint8(185), uint8(191), uint8(0), uint8(11), uint8(212), uint8(153), uint8(158), uint8(74), uint8(190), uint8(161), uint8(63), uint8(72), uint8(208), uint8(64), uint8(191), uint8(191), uint8(80), uint8(52), uint8(177), uint8(110), uint8(221), uint8(133), uint8(173), uint8(125), uint8(216), uint8(3), uint8(129), uint8(95), uint8(213), uint8(2), uint8(184), uint8(2), uint8(93), uint8(87), uint8(48), uint8(143), uint8(63), uint8(255), uint8(244), uint8(7), uint8(229), uint8(5), uint8(112), uint8(5), uint8(233), uint8(61), uint8(205), uint8(3), uint8(38), uint8(191), uint8(253), uint8(201), uint8(250), uint8(194), uint8(8), uint8(33), uint8(194), uint8(33), uint8(157), uint8(64), uint8(58), uint8(193), uint8(83), uint8(22), uint8(64), uint8(57), uint8(0), uint8(232), uint8(105), uint8(2), uint8(125), uint8(132), uint8(182), uint8(192), uint8(34), uint8(25), uint8(108), uint8(175), uint8(252), uint8(254), uint8(28), uint8(1), uint8(150), uint8(229), uint8(177), uint8(95), uint8(254), uint8(127), uint8(15), uint8(194), uint8(16), uint8(220), uint8(14), uint8(132), uint8(68), uint8(25), uint8(223), uint8(10), uint8(152), uint8(194), uint8(167), uint8(224), uint8(113), uint8(12), uint8(91), uint8(159), uint8(192), uint8(26), uint8(216), uint8(246), uint8(47), uint8(61), uint8(245), uint8(226), uint8(225), uint8(89), uint8(49), uint8(117), uint8(193), uint8(246), uint8(3), uint8(45), uint8(9), uint8(144), uint8(149), uint8(40), uint8(28), uint8(228), uint8(215), uint8(134), uint8(12), uint8(237), uint8(107), uint8(95), uint8(147), uint8(223), uint8(6), uint8(159), uint8(56), uint8(68), uint8(51), uint8(120), uint8(85), uint8(209), uint8(41), uint8(218), uint8(253), uint8(171), uint8(99), uint8(93), uint8(95), uint8(130), uint8(141), uint8(86), uint8(181), uint8(246), uint8(95), uint8(240), uint8(97), uint8(132), uint8(14), uint8(76), uint8(63), uint8(4), uint8(223), uint8(217), uint8(255), uint8(84), uint8(120), uint8(84), uint8(224), uint8(245), uint8(224), uint8(245), uint8(240), uint8(117), uint8(120), uint8(58), uint8(184), uint8(128), uint8(37), uint8(66), uint8(0), uint8(9), uint8(208), uint8(113), uint8(12), uint8(91), uint8(129), uint8(200), uint8(102), uint8(185), uint8(228), uint8(2), uint8(43), uint8(238), uint8(7), uint8(8), uint8(174), uint8(185), uint8(252), uint8(225), uint8(20), uint8(72), uint8(181), uint8(199), uint8(236), uint8(184), uint8(17), uint8(174), uint8(35), uint8(190), uint8(31), uint8(242), uint8(250), uint8(138), uint8(8), uint8(98), uint8(170), uint8(34), uint8(179), uint8(202), uint8(16), uint8(12), uint8(19), uint8(129), uint8(224), uint8(99), uint8(50), uint8(194), uint8(0), uint8(44), uint8(239), uint8(43), uint8(119), uint8(224), uint8(49), uint8(8), uint8(144), uint8(215), uint8(80), uint8(35), uint8(55), uint8(207), uint8(41), uint8(233), uint8(250), uint8(192), uint8(7), uint8(52), uint8(54), uint8(55), uint8(21), uint8(108), uint8(86), uint8(237), uint8(3), uint8(228), uint8(204), uint8(72), uint8(241), uint8(99), uint8(247), uint8(231), uint8(128), uint8(0), uint8(0), uint8(3), uint8(83), uint8(109), uint8(111), uint8(111), uint8(118), uint8(0), uint8(0), uint8(0), uint8(108), uint8(109), uint8(118), uint8(104), uint8(100), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(3), uint8(232), uint8(0), uint8(0), uint8(3), uint8(232), uint8(0), uint8(1), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(64), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(2), uint8(0), uint8(0), uint8(2), uint8(126), uint8(116), uint8(114), uint8(97), uint8(107), uint8(0), uint8(0), uint8(0), uint8(92), uint8(116), uint8(107), uint8(104), uint8(100), uint8(0), uint8(0), uint8(0), uint8(3), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(3), uint8(232), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(64), uint8(0), uint8(0), uint8(0), uint8(0), uint8(96), uint8(0), uint8(0), uint8(0), uint8(64), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(36), uint8(101), uint8(100), uint8(116), uint8(115), uint8(0), uint8(0), uint8(0), uint8(28), uint8(101), uint8(108), uint8(115), uint8(116), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(3), uint8(232), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(246), uint8(109), uint8(100), uint8(105), uint8(97), uint8(0), uint8(0), uint8(0), uint8(32), uint8(109), uint8(100), uint8(104), uint8(100), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(48), uint8(0), uint8(0), uint8(0), uint8(48), uint8(0), uint8(85), uint8(196), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(45), uint8(104), uint8(100), uint8(108), uint8(114), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(118), uint8(105), uint8(100), uint8(101), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(86), uint8(105), uint8(100), uint8(101), uint8(111), uint8(72), uint8(97), uint8(110), uint8(100), uint8(108), uint8(101), uint8(114), uint8(0), uint8(0), uint8(0), uint8(1), uint8(161), uint8(109), uint8(105), uint8(110), uint8(102), uint8(0), uint8(0), uint8(0), uint8(20), uint8(118), uint8(109), uint8(104), uint8(100), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(36), uint8(100), uint8(105), uint8(110), uint8(102), uint8(0), uint8(0), uint8(0), uint8(28), uint8(100), uint8(114), uint8(101), uint8(102), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(12), uint8(117), uint8(114), uint8(108), uint8(32), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(1), uint8(97), uint8(115), uint8(116), uint8(98), uint8(108), uint8(0), uint8(0), uint8(0), uint8(185), uint8(115), uint8(116), uint8(115), uint8(100), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(169), uint8(97), uint8(118), uint8(99), uint8(49), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(96), uint8(0), uint8(64), uint8(0), uint8(72), uint8(0), uint8(0), uint8(0), uint8(72), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(21), uint8(76), uint8(97), uint8(118), uint8(99), uint8(54), uint8(50), uint8(46), uint8(49), uint8(49), uint8(46), uint8(49), uint8(48), uint8(48), uint8(32), uint8(108), uint8(105), uint8(98), uint8(120), uint8(50), uint8(54), uint8(52), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(24), uint8(255), uint8(255), uint8(0), uint8(0), uint8(0), uint8(47), uint8(97), uint8(118), uint8(99), uint8(67), uint8(1), uint8(66), uint8(192), uint8(10), uint8(255), uint8(225), uint8(0), uint8(23), uint8(103), uint8(66), uint8(192), uint8(10), uint8(217), uint8(6), uint8(38), uint8(192), uint8(68), uint8(0), uint8(0), uint8(3), uint8(0), uint8(4), uint8(0), uint8(0), uint8(3), uint8(0), uint8(96), uint8(60), uint8(72), uint8(153), uint8(32), uint8(1), uint8(0), uint8(5), uint8(104), uint8(203), uint8(131), uint8(203), uint8(32), uint8(0), uint8(0), uint8(0), uint8(16), uint8(112), uint8(97), uint8(115), uint8(112), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(20), uint8(98), uint8(116), uint8(114), uint8(116), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(223), uint8(72), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(24), uint8(115), uint8(116), uint8(116), uint8(115), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(12), uint8(0), uint8(0), uint8(4), uint8(0), uint8(0), uint8(0), uint8(0), uint8(20), uint8(115), uint8(116), uint8(115), uint8(115), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(28), uint8(115), uint8(116), uint8(115), uint8(99), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(12), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(68), uint8(115), uint8(116), uint8(115), uint8(122), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(12), uint8(0), uint8(0), uint8(9), uint8(70), uint8(0), uint8(0), uint8(1), uint8(206), uint8(0), uint8(0), uint8(1), uint8(224), uint8(0), uint8(0), uint8(1), uint8(163), uint8(0), uint8(0), uint8(1), uint8(139), uint8(0), uint8(0), uint8(1), uint8(172), uint8(0), uint8(0), uint8(1), uint8(183), uint8(0), uint8(0), uint8(1), uint8(34), uint8(0), uint8(0), uint8(1), uint8(200), uint8(0), uint8(0), uint8(1), uint8(182), uint8(0), uint8(0), uint8(1), uint8(255), uint8(0), uint8(0), uint8(1), uint8(197), uint8(0), uint8(0), uint8(0), uint8(20), uint8(115), uint8(116), uint8(99), uint8(111), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(48), uint8(0), uint8(0), uint8(0), uint8(97), uint8(117), uint8(100), uint8(116), uint8(97), uint8(0), uint8(0), uint8(0), uint8(89), uint8(109), uint8(101), uint8(116), uint8(97), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(33), uint8(104), uint8(100), uint8(108), uint8(114), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(109), uint8(100), uint8(105), uint8(114), uint8(97), uint8(112), uint8(112), uint8(108), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(44), uint8(105), uint8(108), uint8(115), uint8(116), uint8(0), uint8(0), uint8(0), uint8(36), uint8(169), uint8(116), uint8(111), uint8(111), uint8(0), uint8(0), uint8(0), uint8(28), uint8(100), uint8(97), uint8(116), uint8(97), uint8(0), uint8(0), uint8(0), uint8(1), uint8(0), uint8(0), uint8(0), uint8(0), uint8(76), uint8(97), uint8(118), uint8(102), uint8(54), uint8(50), uint8(46), uint8(51), uint8(46), uint8(49), uint8(48), uint8(48)]

var host_bytes : uint8? = null

var host_length : int = 0

var host_picture : uint8? = null

var host_width : int = 0

var host_height : int = 0

var host_y_size : int = 0

var host_u_size : int = 0

var host_v_size : int = 0

[export]
def rotl32(var value : uint; var shift : uint) : uint {
    return value << shift | value >> 0x20 - shift
}
[export]
def fold_bytes(var bytes : uint8 const?; var length : int) : uint {
    var hash : uint = 0x811c9dc5
    return hash
}
[export]
def memory_read_callback(var offset : int64; var buffer : uint64; var size : size_t; var token : uint64) : int {
    var input : MemoryInput? = unsafe(reinterpret<MemoryInput?>(token))
    if (offset < int64(0)) {
        return 1
    }
    if (offset + int64(size) > int64(input.length)) {
        return 1
    }
    memcpy(buffer, unsafe(unsafe(reinterpret<uint64>(unsafe(input.bytes + cast<size_t>(offset))))), size)
    return 0
}
[export]
def find_avc_track(var mp4 : MP4D_demux_t const?) : int {
    return -1
}
[export]
def sample_annexb_size(var sample : uint8 const?; var sample_bytes : int; var length_size : int) : int {
    return total
}
[export]
def infer_length_size(var sample_0 : uint8 const?; var sample_bytes_0 : int) : int {
    var candidate : int = 0
    candidate = 4
    candidate
    while (candidate >= 1) {
        if (sample_annexb_size(sample_0, sample_bytes_0, candidate) >= 0) {
            return candidate
        }
        candidate = candidate - 1
    }
    return 0
}
[export]
def detect_track_length_size(var mp4_0 : MP4D_demux_t const?; var track_index : int; var bytes_0 : uint8 const?; var total_bytes : int) : int {
    var sample_index : uint = uint(0)
    sample_index = uint(uint(0))
    sample_index
    while (sample_index < unsafe(mp4_0.track[track_index]).sample_count) {
        var frame_bytes : uint = uint(0)
        var offset_1 : uint64 = MP4D_frame_offset(mp4_0, uint(track_index), sample_index, unsafe(addr(frame_bytes)), null, null)
        if (frame_bytes == uint(0)) {
            continue
        }
        if (offset_1 + uint64(frame_bytes) > uint64(uint(total_bytes))) {
            return 0
        }
        return infer_length_size(unsafe(bytes_0 + offset_1), int(frame_bytes))
        sample_index = sample_index + 1
    }
    return 0
}
[export]
def output_picture_width(var storage : storage_t?) : int {
    return int(h264bsdPicWidth(storage)) * 16
}
[export]
def output_picture_height(var storage_0 : storage_t?) : int {
    return int(h264bsdPicHeight(storage_0)) * 16
}
[export]
def decode_access_unit(var state : DecoderState?; var bytes_1 : uint8 const?; var length_0 : int; var picture_ready : int?) : int {
    var offset_2 : int = 0
    *picture_ready = 0
    *picture_ready
    while (offset_2 < length_0) {
        if (read_bytes == 0x0 && result_0 != uint(H264BSD_HDRS_RDY)) {
            return 0
        }
        offset_2 = offset_2 + int(read_bytes)
        offset_2
        if (result_0 == uint(H264BSD_HDRS_RDY)) {
            state.width = output_picture_width(state.storage)
            state.width
            state.height = output_picture_height(state.storage)
            state.height
        }
        if (result_0 == uint(H264BSD_PIC_RDY)) {
            var pic_id : uint = uint(0)
            var is_idr_pic : uint = uint(0)
            var num_err_mbs : uint = uint(0)
            state.picture = h264bsdNextOutputPicture(state.storage, unsafe(addr(pic_id)), unsafe(addr(is_idr_pic)), unsafe(addr(num_err_mbs)))
            state.picture
            state.width = output_picture_width(state.storage)
            state.width
            state.height = output_picture_height(state.storage)
            state.height
            *picture_ready = 1
            *picture_ready
        }
    }
    return 1
}
[export]
def decode_summary(var bytes_2 : uint8 const?; var length_1 : int; var frame_limit : int; var summary : DecodeSummary?) : int {
    var input_0 : MemoryInput
    var mp4_1 : MP4D_demux_t
    var track_index_0 : int = -1
    var track_length_size : int = 0
    var prefix_bytes : int = 0
    var max_sample_bytes : int = 0
    var scratch : uint8? = null
    var state_0 : DecoderState
    var sample_index_0 : int = 0
    memset(unsafe(unsafe(reinterpret<uint64>(summary))), 0, 4)
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_1))))), 0, 4)
    input_0.bytes = bytes_2
    input_0.bytes
    input_0.length = length_1
    input_0.length
    if (MP4D_open(unsafe(addr(mp4_1)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_0))))), int64(length_1)) == 0) {
        return 0
    }
    track_index_0 = find_avc_track(unsafe(addr(mp4_1)))
    track_index_0
    if (track_index_0 < 0) {
        MP4D_close(unsafe(addr(mp4_1)))
        return 0
    }
    track_length_size = detect_track_length_size(unsafe(addr(mp4_1)), track_index_0, bytes_2, length_1)
    track_length_size
    if (track_length_size <= 0) {
        MP4D_close(unsafe(addr(mp4_1)))
        return 0
    }
    prefix_bytes = header_annexb_size(unsafe(addr(mp4_1)), track_index_0)
    prefix_bytes
    sample_index_0 = 0
    sample_index_0
    while (sample_index_0 < int(unsafe(mp4_1.track[track_index_0]).sample_count)) {
        var frame_bytes_0 : uint = uint(0)
        var offset_3 : uint64 = MP4D_frame_offset(unsafe(addr(mp4_1)), uint(track_index_0), uint(sample_index_0), unsafe(addr(frame_bytes_0)), null, null)
        var annexb_bytes : int = 0
        if (offset_3 + uint64(frame_bytes_0) > uint64(uint(length_1))) {
            MP4D_close(unsafe(addr(mp4_1)))
            return 0
        }
        annexb_bytes = sample_annexb_size(unsafe(bytes_2 + offset_3), int(frame_bytes_0), track_length_size)
        annexb_bytes
        if (annexb_bytes < 0) {
            MP4D_close(unsafe(addr(mp4_1)))
            return 0
        }
        if (annexb_bytes + prefix_bytes > max_sample_bytes) {
            max_sample_bytes = annexb_bytes + prefix_bytes
            max_sample_bytes
        }
        sample_index_0 = sample_index_0 + 1
    }
    scratch = unsafe(reinterpret<uint8?>(malloc(cast<size_t>(max_sample_bytes))))
    scratch
    if (scratch == null) {
        MP4D_close(unsafe(addr(mp4_1)))
        return 0
    }
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(state_0))))), 0, 4)
    state_0.storage = h264bsdAlloc()
    state_0.storage
    if (state_0.storage == null) {
        MP4D_close(unsafe(addr(mp4_1)))
        return 0
    }
    if (h264bsdInit(state_0.storage, 0x0) != uint(H264BSD_RDY)) {
        h264bsdFree(state_0.storage)
        MP4D_close(unsafe(addr(mp4_1)))
        return 0
    }
    summary.combined_hash = uint(0x811c9dc5)
    summary.combined_hash
    sample_index_0 = 0
    sample_index_0
    while (sample_index_0 < int(unsafe(mp4_1.track[track_index_0]).sample_count)) {
        var frame_bytes_1 : uint = uint(0)
        var offset_4 : uint64 = MP4D_frame_offset(unsafe(addr(mp4_1)), uint(track_index_0), uint(sample_index_0), unsafe(addr(frame_bytes_1)), null, null)
        var sample_length : int = build_annexb_sample(unsafe(addr(mp4_1)), track_index_0, unsafe(bytes_2 + offset_4), int(frame_bytes_1), sample_index_0 == 0, scratch, max_sample_bytes, track_length_size)
        var picture_ready_0 : int = 0
        if (sample_length < 0) {
            h264bsdShutdown(state_0.storage)
            h264bsdFree(state_0.storage)
            MP4D_close(unsafe(addr(mp4_1)))
            return 0
        }
        if (decode_access_unit(unsafe(addr(state_0)), scratch, sample_length, unsafe(addr(picture_ready_0))) == 0) {
            h264bsdShutdown(state_0.storage)
            h264bsdFree(state_0.storage)
            MP4D_close(unsafe(addr(mp4_1)))
            return 0
        }
        if (picture_ready_0 != 0) {
            var picture_bytes : int = state_0.width * state_0.height * 3 / 2
            var frame_hash : uint = fold_bytes(state_0.picture, picture_bytes)
            if (summary.frame_count == 0) {
                summary.first_hash = uint(frame_hash)
                summary.first_hash
                summary.width = state_0.width
                summary.width
                summary.height = state_0.height
                summary.height
            }
            summary.last_hash = uint(frame_hash)
            summary.last_hash
            summary.combined_hash = uint(summary.combined_hash ^ frame_hash + uint(uint(summary.frame_count) * 0x9e3779b9))
            summary.combined_hash
            summary.combined_hash = uint(rotl32(summary.combined_hash, 0x7))
            summary.combined_hash
            summary.combined_hash = uint(summary.combined_hash + 0x7f4a7c15)
            summary.combined_hash
            summary.frame_count = summary.frame_count + 1
            summary.frame_count
            if (frame_limit > 0 && summary.frame_count >= frame_limit) {
                break
            }
        }
        sample_index_0 = sample_index_0 + 1
    }
    summary.combined_hash = uint(summary.combined_hash ^ uint(summary.width))
    summary.combined_hash
    summary.combined_hash = uint(rotl32(summary.combined_hash, 0x3))
    summary.combined_hash
    summary.combined_hash = uint(summary.combined_hash ^ uint(summary.height))
    summary.combined_hash
    summary.combined_hash = uint(rotl32(summary.combined_hash, 0x3))
    summary.combined_hash
    summary.combined_hash = uint(summary.combined_hash ^ uint(summary.frame_count))
    summary.combined_hash
    h264bsdShutdown(state_0.storage)
    h264bsdFree(state_0.storage)
    MP4D_close(unsafe(addr(mp4_1)))
    return summary.frame_count > 0
}
[export]
def decode_frame_yuv(var bytes_3 : uint8 const?; var length_2 : int; var frame_index : int; var picture : uint8??; var width : int?; var height : int?) : int {
    var input_1 : MemoryInput
    var mp4_2 : MP4D_demux_t
    var track_index_1 : int = -1
    var track_length_size_0 : int = 0
    var prefix_bytes_0 : int = 0
    var max_sample_bytes_0 : int = 0
    var scratch_0 : uint8? = null
    var state_1 : DecoderState
    var sample_index_1 : int = 0
    var picture_index : int = 0
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_2))))), 0, 4)
    input_1.bytes = bytes_3
    input_1.bytes
    input_1.length = length_2
    input_1.length
    if (MP4D_open(unsafe(addr(mp4_2)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_1))))), int64(length_2)) == 0) {
        return 0
    }
    track_index_1 = find_avc_track(unsafe(addr(mp4_2)))
    track_index_1
    if (track_index_1 < 0) {
        MP4D_close(unsafe(addr(mp4_2)))
        return 0
    }
    track_length_size_0 = detect_track_length_size(unsafe(addr(mp4_2)), track_index_1, bytes_3, length_2)
    track_length_size_0
    if (track_length_size_0 <= 0) {
        MP4D_close(unsafe(addr(mp4_2)))
        return 0
    }
    prefix_bytes_0 = header_annexb_size(unsafe(addr(mp4_2)), track_index_1)
    prefix_bytes_0
    sample_index_1 = 0
    sample_index_1
    while (sample_index_1 < int(unsafe(mp4_2.track[track_index_1]).sample_count)) {
        var frame_bytes_2 : uint = uint(0)
        var offset_5 : uint64 = MP4D_frame_offset(unsafe(addr(mp4_2)), uint(track_index_1), uint(sample_index_1), unsafe(addr(frame_bytes_2)), null, null)
        var annexb_bytes_0 : int = sample_annexb_size(unsafe(bytes_3 + offset_5), int(frame_bytes_2), track_length_size_0)
        if (annexb_bytes_0 < 0) {
            MP4D_close(unsafe(addr(mp4_2)))
            return 0
        }
        if (annexb_bytes_0 + prefix_bytes_0 > max_sample_bytes_0) {
            max_sample_bytes_0 = annexb_bytes_0 + prefix_bytes_0
            max_sample_bytes_0
        }
        sample_index_1 = sample_index_1 + 1
    }
    scratch_0 = unsafe(reinterpret<uint8?>(malloc(cast<size_t>(max_sample_bytes_0))))
    scratch_0
    if (scratch_0 == null) {
        MP4D_close(unsafe(addr(mp4_2)))
        return 0
    }
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(state_1))))), 0, 4)
    state_1.storage = h264bsdAlloc()
    state_1.storage
    if (state_1.storage == null) {
        MP4D_close(unsafe(addr(mp4_2)))
        return 0
    }
    if (h264bsdInit(state_1.storage, 0x0) != uint(H264BSD_RDY)) {
        h264bsdFree(state_1.storage)
        MP4D_close(unsafe(addr(mp4_2)))
        return 0
    }
    sample_index_1 = 0
    sample_index_1
    while (sample_index_1 < int(unsafe(mp4_2.track[track_index_1]).sample_count)) {
        var frame_bytes_3 : uint = uint(0)
        var offset_6 : uint64 = MP4D_frame_offset(unsafe(addr(mp4_2)), uint(track_index_1), uint(sample_index_1), unsafe(addr(frame_bytes_3)), null, null)
        var sample_length_0 : int = build_annexb_sample(unsafe(addr(mp4_2)), track_index_1, unsafe(bytes_3 + offset_6), int(frame_bytes_3), sample_index_1 == 0, scratch_0, max_sample_bytes_0, track_length_size_0)
        var picture_ready_1 : int = 0
        if (sample_length_0 < 0) {
            h264bsdShutdown(state_1.storage)
            h264bsdFree(state_1.storage)
            MP4D_close(unsafe(addr(mp4_2)))
            return 0
        }
        if (decode_access_unit(unsafe(addr(state_1)), scratch_0, sample_length_0, unsafe(addr(picture_ready_1))) == 0) {
            h264bsdShutdown(state_1.storage)
            h264bsdFree(state_1.storage)
            MP4D_close(unsafe(addr(mp4_2)))
            return 0
        }
        if (picture_ready_1 != 0) {
            if (picture_index == frame_index) {
                *picture = state_1.picture
                *picture
                *width = state_1.width
                *width
                *height = state_1.height
                *height
                h264bsdShutdown(state_1.storage)
                h264bsdFree(state_1.storage)
                MP4D_close(unsafe(addr(mp4_2)))
                return 1
            }
            picture_index = picture_index + 1
            picture_index
        }
        sample_index_1 = sample_index_1 + 1
    }
    h264bsdShutdown(state_1.storage)
    h264bsdFree(state_1.storage)
    MP4D_close(unsafe(addr(mp4_2)))
    return 0
}
[export]
def h264mp4_decode_hash(var frame_limit_0 : int) : int {
    var summary_0 : DecodeSummary
    shim_reset_heap()
    if (decode_summary(cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))), int(sample_mp4_len), frame_limit_0, unsafe(addr(summary_0))) == 0) {
        return -1
    }
    return int(summary_0.combined_hash)
}
[export]
def h264mp4_probe_width() : int {
    var summary_1 : DecodeSummary
    shim_reset_heap()
    if (decode_summary(cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))), int(sample_mp4_len), 1, unsafe(addr(summary_1))) == 0) {
        return -1
    }
    return summary_1.width
}
[export]
def h264mp4_probe_height() : int {
    var summary_2 : DecodeSummary
    shim_reset_heap()
    if (decode_summary(cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))), int(sample_mp4_len), 1, unsafe(addr(summary_2))) == 0) {
        return -1
    }
    return summary_2.height
}
[export]
def h264mp4_probe_frame_count(var frame_limit_1 : int) : int {
    var summary_3 : DecodeSummary
    shim_reset_heap()
    if (decode_summary(cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))), int(sample_mp4_len), frame_limit_1, unsafe(addr(summary_3))) == 0) {
        return -1
    }
    return summary_3.frame_count
}
[export]
def h264mp4_probe_first_frame_hash() : int {
    var summary_4 : DecodeSummary
    shim_reset_heap()
    if (decode_summary(cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))), int(sample_mp4_len), 1, unsafe(addr(summary_4))) == 0) {
        return -1
    }
    return int(summary_4.first_hash)
}
[export]
def h264mp4_probe_last_frame_hash(var frame_limit_2 : int) : int {
    var summary_5 : DecodeSummary
    shim_reset_heap()
    if (decode_summary(cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0]))), int(sample_mp4_len), frame_limit_2, unsafe(addr(summary_5))) == 0) {
        return -1
    }
    return int(summary_5.last_hash)
}
[export]
def h264mp4_probe_track_index() : int {
    var input_2 : MemoryInput
    var mp4_3 : MP4D_demux_t
    var track_index_2 : int = -1
    shim_reset_heap()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_3))))), 0, 4)
    input_2.bytes = cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))
    input_2.bytes
    input_2.length = int(sample_mp4_len)
    input_2.length
    if (MP4D_open(unsafe(addr(mp4_3)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_2))))), int64(sample_mp4_len)) == 0) {
        return -2
    }
    track_index_2 = find_avc_track(unsafe(addr(mp4_3)))
    track_index_2
    MP4D_close(unsafe(addr(mp4_3)))
    return track_index_2
}
[export]
def h264mp4_probe_sample0_size() : int {
    var input_3 : MemoryInput
    var mp4_4 : MP4D_demux_t
    var track_index_3 : int = -1
    var frame_bytes_4 : uint = uint(0)
    var offset_7 : uint64 = uint64(0)
    shim_reset_heap()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_4))))), 0, 4)
    input_3.bytes = cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))
    input_3.bytes
    input_3.length = int(sample_mp4_len)
    input_3.length
    if (MP4D_open(unsafe(addr(mp4_4)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_3))))), int64(sample_mp4_len)) == 0) {
        return -2
    }
    track_index_3 = find_avc_track(unsafe(addr(mp4_4)))
    track_index_3
    if (track_index_3 < 0) {
        MP4D_close(unsafe(addr(mp4_4)))
        return -1
    }
    offset_7 = uint64(MP4D_frame_offset(unsafe(addr(mp4_4)), uint(track_index_3), 0x0, unsafe(addr(frame_bytes_4)), null, null))
    offset_7
    MP4D_close(unsafe(addr(mp4_4)))
    if (offset_7 + uint64(frame_bytes_4) > uint64(sample_mp4_len)) {
        return -3
    }
    return int(frame_bytes_4)
}
[export]
def h264mp4_probe_sample_count() : int {
    var input_4 : MemoryInput
    var mp4_5 : MP4D_demux_t
    var track_index_4 : int = -1
    shim_reset_heap()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_5))))), 0, 4)
    input_4.bytes = cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))
    input_4.bytes
    input_4.length = int(sample_mp4_len)
    input_4.length
    if (MP4D_open(unsafe(addr(mp4_5)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_4))))), int64(sample_mp4_len)) == 0) {
        return -2
    }
    track_index_4 = find_avc_track(unsafe(addr(mp4_5)))
    track_index_4
    if (track_index_4 < 0) {
        MP4D_close(unsafe(addr(mp4_5)))
        return -1
    }
    return int(unsafe(mp4_5.track[track_index_4]).sample_count)
}
[export]
def h264mp4_probe_sample0_offset() : int {
    var input_5 : MemoryInput
    var mp4_6 : MP4D_demux_t
    var track_index_5 : int = -1
    var frame_bytes_5 : uint = uint(0)
    var offset_8 : uint64 = uint64(0)
    shim_reset_heap()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_6))))), 0, 4)
    input_5.bytes = cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))
    input_5.bytes
    input_5.length = int(sample_mp4_len)
    input_5.length
    if (MP4D_open(unsafe(addr(mp4_6)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_5))))), int64(sample_mp4_len)) == 0) {
        return -2
    }
    track_index_5 = find_avc_track(unsafe(addr(mp4_6)))
    track_index_5
    if (track_index_5 < 0) {
        MP4D_close(unsafe(addr(mp4_6)))
        return -1
    }
    offset_8 = uint64(MP4D_frame_offset(unsafe(addr(mp4_6)), uint(track_index_5), 0x0, unsafe(addr(frame_bytes_5)), null, null))
    offset_8
    MP4D_close(unsafe(addr(mp4_6)))
    return int(offset_8)
}
[export]
def h264mp4_probe_length_size() : int {
    var input_6 : MemoryInput
    var mp4_7 : MP4D_demux_t
    var track_index_6 : int = -1
    shim_reset_heap()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_7))))), 0, 4)
    input_6.bytes = cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))
    input_6.bytes
    input_6.length = int(sample_mp4_len)
    input_6.length
    if (MP4D_open(unsafe(addr(mp4_7)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_6))))), int64(sample_mp4_len)) == 0) {
        return -2
    }
    track_index_6 = find_avc_track(unsafe(addr(mp4_7)))
    track_index_6
    if (track_index_6 < 0) {
        MP4D_close(unsafe(addr(mp4_7)))
        return -1
    }
    return detect_track_length_size(unsafe(addr(mp4_7)), track_index_6, unsafe(addr(sample_mp4_bytes[0])), int(sample_mp4_len))
}
[export]
def h264mp4_probe_header_size() : int {
    var input_7 : MemoryInput
    var mp4_8 : MP4D_demux_t
    var track_index_7 : int = -1
    shim_reset_heap()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_8))))), 0, 4)
    input_7.bytes = cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))
    input_7.bytes
    input_7.length = int(sample_mp4_len)
    input_7.length
    if (MP4D_open(unsafe(addr(mp4_8)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_7))))), int64(sample_mp4_len)) == 0) {
        return -2
    }
    track_index_7 = find_avc_track(unsafe(addr(mp4_8)))
    track_index_7
    if (track_index_7 < 0) {
        MP4D_close(unsafe(addr(mp4_8)))
        return -1
    }
    return header_annexb_size(unsafe(addr(mp4_8)), track_index_7)
}
[export]
def h264mp4_probe_sample0_prefix() : int {
    var input_8 : MemoryInput
    var mp4_9 : MP4D_demux_t
    var track_index_8 : int = -1
    var length_size_0 : int = 0
    var frame_bytes_6 : uint = uint(0)
    var offset_9 : uint64 = uint64(0)
    track_index_8 = find_avc_track(unsafe(addr(mp4_9)))
    track_index_8
    if (track_index_8 < 0) {
        MP4D_close(unsafe(addr(mp4_9)))
        return -1
    }
    length_size_0 = detect_track_length_size(unsafe(addr(mp4_9)), track_index_8, unsafe(addr(sample_mp4_bytes[0])), int(sample_mp4_len))
    length_size_0
    offset_9 = uint64(MP4D_frame_offset(unsafe(addr(mp4_9)), uint(track_index_8), 0x0, unsafe(addr(frame_bytes_6)), null, null))
    offset_9
    if (length_size_0 <= 0 || frame_bytes_6 < uint(length_size_0)) {
        MP4D_close(unsafe(addr(mp4_9)))
        return -3
    }
    index_1 = 0
    index_1
    while (index_1 < length_size_0) {
        prefix = prefix << 8 | int(unsafe(unsafe(addr(sample_mp4_bytes[0]))[offset_9 + uint64(index_1)]))
        prefix
        index_1 = index_1 + 1
    }
    MP4D_close(unsafe(addr(mp4_9)))
    return prefix
}
[export]
def h264mp4_probe_dsi_bytes() : int {
    var input_9 : MemoryInput
    var mp4_10 : MP4D_demux_t
    var track_index_9 : int = -1
    shim_reset_heap()
    memset(unsafe(unsafe(reinterpret<uint64>(unsafe(addr(mp4_10))))), 0, 4)
    input_9.bytes = cast<uint8 const?>(unsafe(addr(sample_mp4_bytes[0])))
    input_9.bytes
    input_9.length = int(sample_mp4_len)
    input_9.length
    if (MP4D_open(unsafe(addr(mp4_10)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_9))))), int64(sample_mp4_len)) == 0) {
        return -2
    }
    track_index_9 = find_avc_track(unsafe(addr(mp4_10)))
    track_index_9
    if (track_index_9 < 0) {
        MP4D_close(unsafe(addr(mp4_10)))
        return -1
    }
    return int(unsafe(mp4_10.track[track_index_9]).dsi_bytes)
}
[export]
def h264mp4_probe_dsi_word0() : int {
    var input_10 : MemoryInput
    var mp4_11 : MP4D_demux_t
    var track_index_10 : int = -1
    track_index_10 = find_avc_track(unsafe(addr(mp4_11)))
    track_index_10
    if (track_index_10 < 0 || unsafe(mp4_11.track[track_index_10]).dsi == null || unsafe(mp4_11.track[track_index_10]).dsi_bytes < uint(4)) {
        MP4D_close(unsafe(addr(mp4_11)))
        return -1
    }
    index_2 = 0
    index_2
    while (index_2 < 4) {
        value_0 = value_0 << 8 | int(unsafe(unsafe(mp4_11.track[track_index_10]).dsi[index_2]))
        value_0
        index_2 = index_2 + 1
    }
    MP4D_close(unsafe(addr(mp4_11)))
    return value_0
}
[export]
def h264mp4_probe_dsi_word1() : int {
    var input_11 : MemoryInput
    var mp4_12 : MP4D_demux_t
    var track_index_11 : int = -1
    track_index_11 = find_avc_track(unsafe(addr(mp4_12)))
    track_index_11
    if (track_index_11 < 0 || unsafe(mp4_12.track[track_index_11]).dsi == null || unsafe(mp4_12.track[track_index_11]).dsi_bytes < uint(8)) {
        MP4D_close(unsafe(addr(mp4_12)))
        return -1
    }
    index_3 = 4
    index_3
    while (index_3 < 8) {
        value_1 = value_1 << 8 | int(unsafe(unsafe(mp4_12.track[track_index_11]).dsi[index_3]))
        value_1
        index_3 = index_3 + 1
    }
    MP4D_close(unsafe(addr(mp4_12)))
    return value_1
}
[export]
def h264mp4_probe_first_decode_result() : int {
    var input_12 : MemoryInput
    var mp4_13 : MP4D_demux_t
    var track_index_12 : int = -1
    var track_length_size_1 : int = 0
    var prefix_bytes_1 : int = 0
    var frame_bytes_7 : uint = uint(0)
    var offset_10 : uint64 = uint64(0)
    var storage_1 : storage_t? = null
    var scratch_1 : uint8? = null
    var sample_length_1 : int = 0
    var read_bytes_0 : uint = uint(0)
    track_index_12 = find_avc_track(unsafe(addr(mp4_13)))
    track_index_12
    if (track_index_12 < 0) {
        MP4D_close(unsafe(addr(mp4_13)))
        return -3
    }
    track_length_size_1 = detect_track_length_size(unsafe(addr(mp4_13)), track_index_12, unsafe(addr(sample_mp4_bytes[0])), int(sample_mp4_len))
    track_length_size_1
    prefix_bytes_1 = header_annexb_size(unsafe(addr(mp4_13)), track_index_12)
    prefix_bytes_1
    offset_10 = uint64(MP4D_frame_offset(unsafe(addr(mp4_13)), uint(track_index_12), 0x0, unsafe(addr(frame_bytes_7)), null, null))
    offset_10
    scratch_1 = unsafe(reinterpret<uint8?>(malloc(cast<size_t>(frame_bytes_7) + cast<size_t>(prefix_bytes_1) + cast<size_t>(0x40))))
    scratch_1
    storage_1 = h264bsdAlloc()
    storage_1
    if (scratch_1 == null || storage_1 == null) {
        MP4D_close(unsafe(addr(mp4_13)))
        return -4
    }
    if (h264bsdInit(storage_1, 0x0) != uint(H264BSD_RDY)) {
        h264bsdFree(storage_1)
        MP4D_close(unsafe(addr(mp4_13)))
        return -5
    }
    sample_length_1 = build_annexb_sample(unsafe(addr(mp4_13)), track_index_12, unsafe(unsafe(addr(sample_mp4_bytes[0])) + offset_10), int(frame_bytes_7), 1, scratch_1, int(frame_bytes_7) + prefix_bytes_1 + 64, track_length_size_1)
    sample_length_1
    if (sample_length_1 <= 0) {
        h264bsdShutdown(storage_1)
        h264bsdFree(storage_1)
        MP4D_close(unsafe(addr(mp4_13)))
        return -6
    }
    result_1 = uint(h264bsdDecode(storage_1, scratch_1, uint(sample_length_1), 0x0, unsafe(addr(read_bytes_0))))
    result_1
    h264bsdShutdown(storage_1)
    h264bsdFree(storage_1)
    MP4D_close(unsafe(addr(mp4_13)))
    return int(result_1)
}
[export]
def h264mp4_probe_first_decode_bytes() : int {
    var input_13 : MemoryInput
    var mp4_14 : MP4D_demux_t
    var track_index_13 : int = -1
    var track_length_size_2 : int = 0
    var prefix_bytes_2 : int = 0
    var frame_bytes_8 : uint = uint(0)
    var offset_11 : uint64 = uint64(0)
    var storage_2 : storage_t? = null
    var scratch_2 : uint8? = null
    var sample_length_2 : int = 0
    var read_bytes_1 : uint = uint(0)
    shim_reset_heap()
    input_13.bytes = unsafe(addr(sample_mp4_bytes[0]))
    input_13.bytes
    input_13.length = int(sample_mp4_len)
    input_13.length
    if (MP4D_open(unsafe(addr(mp4_14)), memory_read_callback, unsafe(unsafe(reinterpret<uint64>(unsafe(addr(input_13))))), int64(sample_mp4_len)) == 0) {
        return -2
    }
    track_index_13 = find_avc_track(unsafe(addr(mp4_14)))
    track_index_13
    if (track_index_13 < 0) {
        MP4D_close(unsafe(addr(mp4_14)))
        return -3
    }
    track_length_size_2 = detect_track_length_size(unsafe(addr(mp4_14)), track_index_13, unsafe(addr(sample_mp4_bytes[0])), int(sample_mp4_len))
    track_length_size_2
    prefix_bytes_2 = header_annexb_size(unsafe(addr(mp4_14)), track_index_13)
    prefix_bytes_2
    offset_11 = uint64(MP4D_frame_offset(unsafe(addr(mp4_14)), uint(track_index_13), 0x0, unsafe(addr(frame_bytes_8)), null, null))
    offset_11
    scratch_2 = unsafe(reinterpret<uint8?>(malloc(cast<size_t>(frame_bytes_8) + cast<size_t>(prefix_bytes_2) + cast<size_t>(0x40))))
    scratch_2
    storage_2 = h264bsdAlloc()
    storage_2
    if (scratch_2 == null || storage_2 == null) {
        MP4D_close(unsafe(addr(mp4_14)))
        return -4
    }
    if (h264bsdInit(storage_2, 0x0) != uint(H264BSD_RDY)) {
        h264bsdFree(storage_2)
        MP4D_close(unsafe(addr(mp4_14)))
        return -5
    }
    sample_length_2 = build_annexb_sample(unsafe(addr(mp4_14)), track_index_13, unsafe(unsafe(addr(sample_mp4_bytes[0])) + offset_11), int(frame_bytes_8), 1, scratch_2, int(frame_bytes_8) + prefix_bytes_2 + 64, track_length_size_2)
    sample_length_2
    if (sample_length_2 <= 0) {
        h264bsdShutdown(storage_2)
        h264bsdFree(storage_2)
        MP4D_close(unsafe(addr(mp4_14)))
        return -6
    }
    h264bsdDecode(storage_2, scratch_2, uint(sample_length_2), 0x0, unsafe(addr(read_bytes_1)))
    h264bsdShutdown(storage_2)
    h264bsdFree(storage_2)
    MP4D_close(unsafe(addr(mp4_14)))
    return int(read_bytes_1)
}
[export]
def h264mp4_host_alloc(var size_0 : int) : int {
    var result_2 : uint64 = null
    if (size_0 <= 0) {
        return 0
    }
    result_2 = malloc(cast<size_t>(size_0))
    result_2
    return int(unsafe(reinterpret<intptr_t>(result_2)))
}
[export]
def h264mp4_host_reset() : int {
    shim_reset_heap()
    host_bytes = null
    host_bytes
    host_length = 0
    host_length
    host_picture = null
    host_picture
    host_width = 0
    host_width
    host_height = 0
    host_height
    host_y_size = 0
    host_y_size
    host_u_size = 0
    host_u_size
    host_v_size = 0
    host_v_size
    return 1
}
[export]
def h264mp4_host_load(var bytes_ptr : int; var bytes_len : int) : int {
    if (bytes_ptr == 0 || bytes_len <= 0) {
        return 0
    }
    host_bytes = unsafe(reinterpret<uint8?>(cast<intptr_t>(bytes_ptr)))
    host_bytes
    host_length = bytes_len
    host_length
    host_picture = null
    host_picture
    host_width = 0
    host_width
    host_height = 0
    host_height
    host_y_size = 0
    host_y_size
    host_u_size = 0
    host_u_size
    host_v_size = 0
    host_v_size
    return 1
}
[export]
def h264mp4_host_decode_frame(var frame_index_0 : int) : int {
    var picture_0 : uint8? = null
    if (decode_frame_yuv(host_bytes, host_length, frame_index_0, unsafe(addr(picture_0)), unsafe(addr(width_0)), unsafe(addr(height_0))) == 0) {
        return 0
    }
    host_picture = picture_0
    host_picture
    host_width = width_0
    host_width
    host_height = height_0
    host_height
    host_y_size = width_0 * height_0
    host_y_size
    host_u_size = host_y_size / 4
    host_u_size
    host_v_size = host_y_size / 4
    host_v_size
    return 1
}
[export]
def h264mp4_host_get_y_ptr() : int {
    return int(unsafe(reinterpret<intptr_t>(host_picture)))
}
[export]
def h264mp4_host_get_u_ptr() : int {
    if (host_picture == null) {
        return 0
    }
    return int(unsafe(reinterpret<intptr_t>(unsafe(host_picture + host_y_size))))
}
[export]
def h264mp4_host_get_v_ptr() : int {
    if (host_picture == null) {
        return 0
    }
    return int(unsafe(reinterpret<intptr_t>(unsafe(unsafe(host_picture + host_y_size) + host_u_size))))
}
[export]
def h264mp4_host_get_y_size() : int {
    return host_y_size
}
[export]
def h264mp4_host_get_u_size() : int {
    return host_u_size
}
[export]
def h264mp4_host_get_v_size() : int {
    return host_v_size
}
[export]
def h264mp4_host_get_width() : int {
    return host_width
}
[export]
def h264mp4_host_get_height() : int {
    return host_height
}




























