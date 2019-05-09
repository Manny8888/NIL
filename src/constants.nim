####################################################################################################################
##
# CPU constants
##
####################################################################################################################


type
  ####################################################################################################################
  ##
  ## TYPES tag
  ##
  ####################################################################################################################

  TagType* {.pure.} = enum
    #  Headers  special markers and forwarding pointers.
    Null = 0                  #  00 Unbound variable/function
    MonitorForward = 1        #  01 This cell being monitored
    HeaderP = 2               #  02 Structure header
    HeaderI = 3               #  03 Structure header
    ExternalValueCellPointer = 4 #  04 Invisible except for binding
    OneQForward = 5           #  05 Invisible pointer (forwards one cell)
    HeaderForward = 6         #  06 Invisible pointer (forwards whole structure)
    ElementForward = 7 #  07 Invisible pointer in element of structure

    #  Numeric data types. - All have the following bits on/off 000001xxxxxx
    Fixnum = 8                #  10 Small integer
    SmallRatio = 9            #  11 Ratio with small numerator and denominator
    SingleFloat = 10          #  12 SinglePrecision floating point
    DoubleFloat = 11          #  13 DoublePrecision floating point
    Bignum = 12               #  14 Big integer
    BigRatio = 13             #  15 Ratio with big numerator or denominator
    Complex = 14              #  16 Complex number
    SpareNumber = 15 #  17 A number to the hardware trap mechanism

    #  Instance data types.
    Instance = 16             #  20 Ordinary instance
    ListInstance = 17         #  21 Instance that masquerades as a cons
    ArrayInstance = 18        #  22 Instance that masquerades as an array
    StringInstance = 19 #  23 Instance that masquerades as a string

    #  Primitive data types.
    NIL = 20                  #  24 The symbol NIL
    List = 21                 #  25 A cons
    Array = 22                #  26 An array that is not a string
    String = 23               #  27 A string
    Symbol = 24               #  30 A symbol other than NIL
    Locative = 25             #  31 Locative pointer
    LexicalClosure = 26       #  32 Lexical closure of a function
    DynamicClosure = 27       #  33 Dynamic closure of a function
    CompiledFunction = 28     #  34 Compiled code
    GenericFunction = 29      #  35 Generic function (see later section)
    SparePointer1 = 30        #  36 Spare
    SparePointer2 = 31        #  37 Spare
    PhysicalAddress = 32      #  40 Physical address
    NativeInstruction = 33    #  41 Spare
    BoundLocation = 34        #  42 Deep bound marker
    Character = 35            #  43 Common Lisp character object
    LogicVariable = 36        #  44 Unbound logic variable marker
    GCForward = 37            #  45 ObjectMoved flag for garbage collector
    EvenPC = 38               #  46 PC at first instruction in word
    OddPC = 39 #  47 PC at second instruction in word

    #  FullWord instructions.
    CallCompiledEven = 40     #  50 Start call
    CallCompiledOdd = 41      #  51 Start call
    CallIndirect = 42         #  52 Start call
    CallGeneric = 43          #  53 Start call
    CallCompiledEvenPrefetch = 44 #  54 Like above
    CallCompiledOddPrefetch = 45 #  55 Like above
    CallIndirectPrefetch = 46 #  56 Like above
    CallGenericPrefetch = 47 #  57 Like above

    #  HalfWord (packed) instructions consume 4 bits of data type field (opcodes 60..77).
    PackedInstruction60 = 48
    TypePackedInstruction61 = 49
    TypePackedInstruction62 = 50
    PackedInstruction63 = 51
    TypePackedInstruction64 = 52
    TypePackedInstruction65 = 53
    PackedInstruction66 = 54
    TypePackedInstruction67 = 55
    TypePackedInstruction70 = 56
    PackedInstruction71 = 57
    TypePackedInstruction72 = 58
    TypePackedInstruction73 = 59
    PackedInstruction74 = 60
    TypePackedInstruction75 = 61
    TypePackedInstruction76 = 62
    PackedInstruction77 = 63

  ####################################################################################################################
  ##
  ## CDR tag
  ##
  ####################################################################################################################

type
  CDR* {.pure.} = enum
    Next = 0
    Nil = 1
    Normal = 2

  ####################################################################################################################
  ##
  ## ARRAY element tags
  ##
  ####################################################################################################################

  ArrayElement* {.pure.} = enum
    Fixnum = 0
    Character = 1
    Boolean = 2
    Object = 3


  ####################################################################################################################
  ##
  ## ARRAY bit fields
  ##
  ####################################################################################################################
type
  BinField* = tuple[position: int, size: int, mask: uint32]

const
  # The top 6 bits describes the type of array
  Array_TypeField*: BinField = (26, 6, 0x0000_003F.uint32)

  # Format of those 6 bits
  Array_ElementType*: BinField = (30, 2, 0x0000_0003.uint32)
  Array_BytePacking*: BinField = (27, 3, 0x0000_0007.uint32)
  Array_ListBit*: BinField = (26, 1, 0x003F_FFFF.uint32)

  Array_NamedStructureBit*: BinField = (25, 1, 0x0000_0001.uint32)
  Array_Spare1*: BinField = (24, 1, 0x0000_0001.uint32)
  Array_LongPrefixBit*: BinField = (23, 1, 0x0000_0001.uint32)

  Array_LeaderLengthField*: BinField = (15, 8, 0x0000_FFFF.uint32)
  Array_Length*: BinField = (0, 15, 0x0000_7FFF.uint32)

  Array_DisplacedBit*: BinField = (14, 1, 0x0000_0001.uint32)
  Array_DiscontiguousBit*: BinField = (13, 1, 0x0000_0001.uint32)

  Array_LongSpare*: BinField = (3, 12, 0x0000_0FFF.uint32)
  Array_LongDimensionsField*: BinField = (0, 3, 0x0000_0007.uint32)

  Array_RegisterElementType*: BinField = (30, 2, 0x0000_0003.uint32)
  Array_RegisterBytePacking*: BinField = (27, 3, 0x0000_0007.uint32)
  Array_RegisterByteOffset*: BinField = (22, 5, 0x0000_001F.uint32)
  Array_RegisterEventCount*: BinField = (0, 22, 0x003F_FFFF.uint32)

  ####################################################################################################################
  ##
  ## FIXME What are those?
  ##
  ####################################################################################################################
type
  ValueDisposition* {.pure.} = enum
    Effect = 0
    Value = 1
    Return = 2
    Multiple = 3

  ####################################################################################################################
  ##
  ## Instructions opcode - FIXME Should be replaced by macros to include string representation, disassembly, code
  ##
  ####################################################################################################################

const
  # List manipulation
  OpcodeCar* = 0b0000000000
  OpcodeCdr* = 0b0000000001
  Opcode_SetToCar* = 0b0001100000
  Opcode_SetToCdr* = 0b0001100001
  Opcode_SetToCdrPushCar* = 0b0001100010
  Opcode_Rplaca* = 0b0010000000
  Opcode_Rplacd* = 0b0010000001
  Opcode_Rgetf* = 0b0010010101
  Opcode_Member* = 0b0010010110
  Opcode_Assoc* = 0b0010010111

  # AI Instructions
  Opcode_Dereference* = 0b0000001011
  Opcode_Unify* = 0b0010011111
  Opcode_PushLocalLogicVariables* = 0b0001000011
  Opcode_PushGlobalLogicVariable* = 0b0000101101
  Opcode_LogicTailTest* = 0b0000001100

  # Binary predicates
  Opcode_Eq* = 0b0010111000
  Opcode_EqNoPop* = 0b0010111100
  Opcode_Eql* = 0b0010110011
  Opcode_EqlNoPop* = 0b0010110111
  Opcode_EqualNumber* = 0b0010110000
  Opcode_EqualNumberNoPop* = 0b0010110100
  Opcode_Greaterp* = 0b0010110010
  Opcode_GreaterpNoPop* = 0b0010110110
  Opcode_Lessp* = 0b0010110001
  Opcode_LesspNoPop* = 0b0010110101
  Opcode_Logtest* = 0b0010111011
  Opcode_LogtestNoPop* = 0b0010111111
  Opcode_TypeMember* = 0b0000100000
  Opcode_TypeMemberNoPop* = 0b0000100100

  # Unary predicates
  Opcode_Endp* = 0b0000000010
  Opcode_Plusp* = 0b0000011110
  Opcode_Minusp* = 0b0000011101
  Opcode_Zerop* = 0b0000011100

  # Numeric operations
  Opcode_Add* = 0b0011000000
  Opcode_Sub* = 0b0011000001
  Opcode_UnaryMinus* = 0b0001001100
  Opcode_Increment* = 0b0001100011
  Opcode_Decrement* = 0b0001100100
  Opcode_Multiply* = 0b0010000010
  Opcode_Quotient* = 0b0010000011
  Opcode_Ceiling* = 0b0010000100
  Opcode_Floor* = 0b0010000101
  Opcode_Truncate* = 0b0010000110
  Opcode_Round* = 0b0010000111
  Opcode_RationalQuotient* = 0b0010001001
  Opcode_Max* = 0b0010001011
  Opcode_Min* = 0b0010001010
  Opcode_Logand* = 0b0010001101
  Opcode_Logior* = 0b0010001111
  Opcode_Logxor* = 0b0010001110
  Opcode_Ash* = 0b0010011010
  Opcode_Rot* = 0b0010010000
  Opcode_Lsh* = 0b0010010001
  Opcode_32BitPlus* = 0b0011000010
  Opcode_32BitDifference* = 0b0011000011
  Opcode_MultiplyDouble* = 0b0010010010
  Opcode_AddBignumStep* = 0b0011000100
  Opcode_SubBignumStep* = 0b0011000101
  Opcode_MultiplyBignumStep* = 0b0011000110
  Opcode_DivideBignumStep* = 0b0011000111
  Opcode_LshcBignumStep* = 0b0010010011

  # Data movement
  Opcode_Push* = 0b0001000000
  Opcode_Pop* = 0b0011100000
  Opcode_Movem* = 0b0011100001
  Opcode_PushNNils* = 0b0001000001
  Opcode_PushAddress* = 0b0001101000
  Opcode_SetSpToAddress* = 0b0001101001
  Opcode_SetSpToAddressSaveTos* = 0b0001101010
  Opcode_PushAddressSpRelative* = 0b0001000010
  Opcode_StackBlt* = 0b0010010100
  Opcode_StackBltAddress* = 0b0011101010

  # FieldExtraction instructions
  Opcode_Ldb* = 0b0001111000
  Opcode_Dpb* = 0b0011111000
  Opcode_CharLdb* = 0b0001111001
  Opcode_CharDpb* = 0b0011111001
  Opcode_PLdb* = 0b0001111010
  Opcode_PDpb* = 0b0011111010
  Opcode_PTagLdb* = 0b0001111011
  Opcode_PTagDpb* = 0b0011111011

  # Array operations
  Opcode_Aref1* = 0b0011001010
  Opcode_Aset1* = 0b0011001000
  Opcode_Aloc1* = 0b0011001011
  Opcode_Setup1DArray* = 0b0000000011
  Opcode_SetupForce1DArray* = 0b0000000100
  Opcode_FastAref1* = 0b0011101000
  Opcode_FastAset1* = 0b0011101001
  Opcode_ArrayLeader* = 0b0011001110
  Opcode_StoreArrayLeader* = 0b0011001100
  Opcode_AlocLeader* = 0b0011001111

  # Branch instructions
  Opcode_Branch* = 0b0001111100
  Opcode_BranchTrue* = 0b0000110000
  Opcode_BranchTrueElseExtraPop* = 0b0000110001
  Opcode_BranchTrueAndExtraPop* = 0b0000110010
  Opcode_BranchTrueExtraPop* = 0b0000110011
  Opcode_BranchTrueNoPop* = 0b0000110100
  Opcode_BranchTrueAndNoPop* = 0b0000110101
  Opcode_BranchTrueElseNoPop* = 0b0000110110
  Opcode_BranchTrueAndNoPopElseNoPopExtraPop* = 0b0000110111
  Opcode_BranchFalse* = 0b0000111000
  Opcode_BranchFalseElseExtraPop* = 0b0000111001
  Opcode_BranchFalseAndExtraPop* = 0b0000111010
  Opcode_BranchFalseExtraPop* = 0b0000111011
  Opcode_BranchFalseNoPop* = 0b0000111100
  Opcode_BranchFalseAndNoPop* = 0b0000111101
  Opcode_BranchFalseElseNoPop* = 0b0000111110
  Opcode_BranchFalseAndNoPopElseNoPopExtraPop* = 0b0000111111
  Opcode_LoopDecrementTos* = 0b0001111101
  Opcode_LoopIncrementTosLessThan* = 0b0011111101

  # Block instructions
  Opcode_Block0Read* = 0b0001010000
  Opcode_Block1Read* = 0b0001010001
  Opcode_Block2Read* = 0b0001010010
  Opcode_Block3Read* = 0b0001010011
  Opcode_Block0ReadShift* = 0b0001010100
  Opcode_Block1ReadShift* = 0b0001010101
  Opcode_Block2ReadShift* = 0b0001010110
  Opcode_Block3ReadShift* = 0b0001010111
  Opcode_Block0ReadAlu* = 0b0001110000
  Opcode_Block1ReadAlu* = 0b0001110001
  Opcode_Block2ReadAlu* = 0b0001110010
  Opcode_Block3ReadAlu* = 0b0001110011
  Opcode_Block0ReadTest* = 0b0001011000
  Opcode_Block1ReadTest* = 0b0001011001
  Opcode_Block2ReadTest* = 0b0001011010
  Opcode_Block3ReadTest* = 0b0001011011
  Opcode_Block0Write* = 0b0000011000
  Opcode_Block1Write* = 0b0000011001
  Opcode_Block2Write* = 0b0000011010
  Opcode_Block3Write* = 0b0000011011

  # Function calling
  Opcode_StartCall* = 0b0000001000
  Opcode_FinishCallN* = 0b0001011100
  Opcode_FinishCallNApply* = 0b0001011101
  Opcode_FinishCallTos* = 0b0001011110
  Opcode_FinishCallTosApply* = 0b0001011111
  Opcode_EntryRestAccepted* = 0b0001111110
  Opcode_EntryRestNotAccepted* = 0b0001111111
  Opcode_LocateLocals* = 0b0000101000
  Opcode_ReturnSingle* = 0b0001001101
  Opcode_ReturnMultiple* = 0b0001000100
  Opcode_ReturnKludge* = 0b0001000101
  Opcode_TakeValues* = 0b0001000110

  # Binding instructions
  Opcode_BindLocativeToValue* = 0b0010011110
  Opcode_BindLocative* = 0b0000000101
  Opcode_UnbindN* = 0b0001000111
  Opcode_RestoreBindingStack* = 0b0000000110

  # Catch
  Opcode_CatchOpen* = 0b0011111110
  Opcode_CatchClose* = 0b0000101001

  # Lexical variables - Each takes 8 opcodes
  Opcode_PushLexicalVar* = 0b0000010000
  Opcode_PopLexicalVar* = 0b0010100000
  Opcode_MovemLexicalVar* = 0b0010101000

  # Instance variables
  Opcode_PushInstanceVariable* = 0b0001001000
  Opcode_PopInstanceVariable* = 0b0011010000
  Opcode_MovemInstanceVariable* = 0b0011010001
  Opcode_PushAddressInstanceVariable* = 0b0001001001
  Opcode_PushInstanceVariableOrdered* = 0b0001001010
  Opcode_PopInstanceVariableOrdered* = 0b0011010010
  Opcode_MovemInstanceVariableOrdered* = 0b0011010011
  Opcode_PushAddressInstanceVariableOrdered* = 0b0001001011
  Opcode_InstanceRef* = 0b0011010100
  Opcode_InstanceSet* = 0b0011010101
  Opcode_InstanceLoc* = 0b0011010110

  # Sub-primitives
  Opcode_Ephemeralp* = 0b0000000111
  Opcode_UnsignedLessp* = 0b0011011001
  Opcode_UnsignedLesspNoPop* = 0b0011011101
  Opcode_Alu* = 0b0010001100
  Opcode_AllocateListBlock* = 0b0011001001
  Opcode_AllocateStructureBlock* = 0b0011001101
  Opcode_PointerPlus* = 0b0010011000
  Opcode_PointerDifference* = 0b0010011001
  Opcode_PointerIncrement* = 0b0001100101
  Opcode_ReadInternalRegister* = 0b0001101100
  Opcode_WriteInternalRegister* = 0b0001101101
  Opcode_CoprocessorRead* = 0b0001101110
  Opcode_CoprocessorWrite* = 0b0001101111
  Opcode_MemoryRead* = 0b0001001110
  Opcode_MemoryReadAddress* = 0b0001001111
  Opcode_Tag* = 0b0000001010
  Opcode_SetTag* = 0b0011010111
  Opcode_StoreConditional* = 0b0010011011
  Opcode_MemoryWrite* = 0b0010011100
  Opcode_PStoreContents* = 0b0010011101
  Opcode_SetCdrCode1* = 0b0001100110
  Opcode_SetCdrCode2* = 0b0001100111
  Opcode_MergeCdrNoPop* = 0b0011100010
  Opcode_GenericDispatch* = 0b0000101010
  Opcode_MessageDispatch* = 0b0000101011
  Opcode_Jump* = 0b0000001001
  Opcode_CheckPreemptRequest* = 0b0000101100
  Opcode_NoOp* = 0b0000101110
  Opcode_Halt* = 0b0000101111

  ####################################################################################################################
  ##
  ## FIXME What are those?
  ##
  ####################################################################################################################

type
  Control* {.pure.} = enum
    ArgumentSize = 0o000000377
    ExtraArgument = 0o000000400
    CallerFrameSize = 0o000077000
    Apply = 0o000400000
    ValueDisposition = 0o003000000
    CallStarted = 0o020000000
    CleanupBits = 0o700000000

  ####################################################################################################################
  ##
  ## CPU internal registers
  ##
  ####################################################################################################################

  InternalRegister* {.pure.} = enum
    EAOpcode_EqualNumber = 0o0
    FP = 0o1
    LP = 0o2
    SP = 0o3
    MacroSP = 0o4
    StackCacheLowerBound = 0o5

    BAR0 = 0o6
    PHTHash0 = 0o7

    EPC = 0o10
    DPC = 0o11

    Continuation = 0o12
    AluAndRotateControl = 0o13
    ControlRegister = 0o14
    CRArgumentSize = 0o15
    EphemeralOldspaceRegister = 0o16
    ZoneOldspaceRegister = 0o17
    ChipRevision = 0o20
    FPCoprocessorPresent = 0o21
    PreemptRegister = 0o23
    IcacheControl = 0o24
    PrefetcherControl = 0o25
    MapCacheControl = 0o26
    MemoryControl = 0o27
    ECCLog = 0o30
    ECCLogAddress = 0o31

    InvalidateMap0 = 0o32
    LoadMap0 = 0o33

    StackCacheOverflowLimit = 0o34
    UcodeROMContents = 0o35
    AddressMask = 0o37
    EntryMaximumArguments = 0o40
    LexicalVariable = 0o41
    Instruction = 0o42
    MemoryData = 0o44
    DataPins = 0o45
    ExtensionRegister = 0o46
    MicrosecondClock = 0o47
    ArrayHeaderLength = 0o50

    LoadBAR0 = 0o52

    BAR1 = 0o206
    PHTHash1 = 0o207
    InvalidateMap1 = 0o232
    LoadMap1 = 0o233
    LoadBAR1 = 0o252

    BAR2 = 0o406
    PHTHash2 = 0o407
    InvalidateMap2 = 0o432
    LoadMap2 = 0o433
    LoadBAR2 = 0o452

    BAR3 = 0o606
    PHTHash3 = 0o607
    InvalidateMap3 = 0o632
    LoadMap3 = 0o633
    LoadBAR3 = 0o652

    TOS = 0o1000
    EventCount = 0o1001
    BindingStackPointer = 0o1002
    CatchBlockList = 0o1003

    ControlStackLimit = 0o1004
    ControlStackExtraLimit = 0o1005
    BindingStackLimit = 0o1006

    PHTBase = 0o1007
    PHTMask = 0o1010

    CountMapReloads = 0o1011

    ListCacheArea = 0o1012
    ListCacheAddress = 0o1013
    ListCacheLength = 0o1014

    StructureCacheArea = 0o1015
    StructureCacheAddress = 0o1016
    StructureCacheLength = 0o1017

    DynamicBindingCacheBase = 0o1020
    DynamicBindingCacheMask = 0o1021

    ChoicePointer = 0o1022
    StructureStackChoicePointer = 0o1023

    FEPModeTrapVectorAddress = 0o1024

    MappingTableCache = 0o1026
    MappingTableLength = 0o1027

    StackFrameMaximumSize = 0o1030
    StackCacheDumpQuantum = 0o1031

    ConstantNIL = 0o1040
    ConstantT = 0o1041

  ####################################################################################################################
  ##
  ## Coprocessor registers
  ##
  ####################################################################################################################

  CoprocessorRegister* {.pure.} = enum
    MicrosecondClock = 514
    HostInterrupt = 520

    VMRegisterCommand = 576
    VMRegisterAddress = 577
    VMRegisterExtent = 578
    VMRegisterAttributes = 579
    VMRegisterDestination = 580
    VMRegisterData = 581
    VMRegisterMaskLow = 582
    VMRegisterMaskHigh = 583
    VMRegisterCommandBlock = 584

    StackSwitch = 640
    FlushStackCache = 641
    FlushIDCaches = 642
    CalendarClock = 643
    FlushCachesForVMA = 644
    FlipToStack = 645
    UnwindStackForRestartOrApply = 646

    SaveWorld = 647
    ConsoleInputAvailableP = 648
    WaitForEvent = 649
    FlushHiddenArrayRegisters = 650
    ConsoleIO = 651
    AttachDiskChannel = 652
    GrowDiskPartition = 653
    DetachDiskChannel = 654

  ####################################################################################################################
  ##
  ## Arithmetic / logical unit condition constants
  ##
  ####################################################################################################################

  ALUCondition* {.pure.} = enum
    SignedLessThanOrEqual = 0
    SignedLessThan = 1
    Negative = 2
    SignedOverflow = 3
    UnsignedLessThanOrEqual = 4
    UnsignedLessThan = 5
    Zero = 6
    High25Zero = 7
    Eq = 8

    Op1Ephemeralp = 9
    Op1TypeAcceptable = 10
    Op1TypeCondition = 11

    ResultTypeNil = 12
    Op2Fixnum = 13
    False = 14
    ResultCdrLow = 15
    CleanupBitsSet = 16
    AddressInStackCache = 17
    PendingSequenceBreakEnabled = 18
    ExtraStackMode = 19
    FepMode = 20
    FpCoprocessorPresent = 21
    Op1Oldspacep = 22
    StackCacheOverflow = 23
    OrLogicVariable = 24

  ALUAdderOP2* {.pure.} = enum
    Op2 = 0
    Zero = 1
    Invert = 2
    MinusOne = 3

  ALUByteFunction* {.pure.} = enum
    Dpb = 0
    Ldb = 1

  ALUByteBackground* {.pure.} = enum
    Op1 = 0
    RotateLatch = 1
    Zero = 2

  Boole* {.pure.} = enum
    Clear = 0
    And = 1
    AndC1 = 2
    Boole2 = 3
    AndC2 = 4
    Boole1 = 5
    Xor = 6
    Ior = 7
    Nor = 8
    Equiv = 9
    C1 = 10
    OrC1 = 11
    C2 = 12
    OrC2 = 13
    Nand = 14
    Set = 15

  ALUFunction* {.pure.} = enum
    Boolean = 0
    Byte = 1
    Adder = 2
    MultiplyDivide = 3


  ####################################################################################################################
  ##
  ## FIXME What are those?
  ##
  ####################################################################################################################

  TrapMode* {.pure.} = enum
    Emulator = 0
    ExtraStack = 1
    IO = 2
    FEP = 3

  ####################################################################################################################
  ##
  ## Exceptions
  ##
  ####################################################################################################################

  ReturnValue* {.pure.} = enum
    Normal = 0
    Exception = 1
    IllegalOperand = 2

  HaltReason* {.pure.} = enum
    IllInstn = 1
    Halted = 2
    SpyCalled = 3
    FatalStackOverflow = 4
    IllegalTrapVector = 5

  TrapReason* {.pure.} = enum
    HighPrioritySequenceBreak = 1
    LowPrioritySequenceBreak = 2

  DoubleFloatOp* {.pure.} = enum
    Add = 0
    Sub = 1
    Multiply = 2
    Divide = 3

