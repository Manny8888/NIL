
# CPU constants

const
  ####################################################################################################################
  ##
  ## TYPES tag
  ##
  ####################################################################################################################

  #  Headers  special markers and forwarding pointers.
  Type_Null*: uint8 = 0       #  00 Unbound variable/function
  Type_MonitorForward*: uint8 = 1 #  01 This cell being monitored
  Type_HeaderP*: uint8 = 2    #  02 Structure header
  Type_HeaderI*: uint8 = 3    #  03 Structure header
  Type_ExternalValueCellPointer*: uint8 = 4 #  04 Invisible except for binding
  Type_OneQForward*: uint8 = 5 #  05 Invisible pointer (forwards one cell)
  Type_HeaderForward*: uint8 = 6 #  06 Invisible pointer (forwards whole structure)
  Type_ElementForward*: uint8 = 7 #  07 Invisible pointer in element of structure

  #  Numeric data types. - All have the following bits on/off 000001xxxxxx
  Type_Fixnum*: uint8 = 8     #  10 Small integer
  Type_SmallRatio*: uint8 = 9 #  11 Ratio with small numerator and denominator
  Type_SingleFloat*: uint8 = 10 #  12 SinglePrecision floating point
  Type_DoubleFloat*: uint8 = 11 #  13 DoublePrecision floating point
  Type_Bignum*: uint8 = 12    #  14 Big integer
  Type_BigRatio*: uint8 = 13  #  15 Ratio with big numerator or denominator
  Type_Complex*: uint8 = 14   #  16 Complex number
  Type_SpareNumber*: uint8 = 15 #  17 A number to the hardware trap mechanism

  #  Instance data types.
  Type_Instance*: uint8 = 16  #  20 Ordinary instance
  Type_ListInstance*: uint8 = 17 #  21 Instance that masquerades as a cons
  Type_ArrayInstance*: uint8 = 18 #  22 Instance that masquerades as an array
  Type_StringInstance*: uint8 = 19 #  23 Instance that masquerades as a string

  #  Primitive data types.
  Type_NIL*: uint8 = 20       #  24 The symbol NIL
  Type_List*: uint8 = 21      #  25 A cons
  Type_Array*: uint8 = 22     #  26 An array that is not a string
  Type_String*: uint8 = 23    #  27 A string
  Type_Symbol*: uint8 = 24    #  30 A symbol other than NIL
  Type_Locative*: uint8 = 25  #  31 Locative pointer
  Type_LexicalClosure*: uint8 = 26 #  32 Lexical closure of a function
  Type_DynamicClosure*: uint8 = 27 #  33 Dynamic closure of a function
  Type_CompiledFunction*: uint8 = 28 #  34 Compiled code
  Type_GenericFunction*: uint8 = 29 #  35 Generic function (see later section)
  Type_SparePointer1*: uint8 = 30 #  36 Spare
  Type_SparePointer2*: uint8 = 31 #  37 Spare
  Type_PhysicalAddress*: uint8 = 32 #  40 Physical address
  Type_NativeInstruction*: uint8 = 33 #  41 Spare
  Type_BoundLocation*: uint8 = 34 #  42 Deep bound marker
  Type_Character*: uint8 = 35 #  43 Common Lisp character object
  Type_LogicVariable*: uint8 = 36 #  44 Unbound logic variable marker
  Type_GCForward*: uint8 = 37 #  45 ObjectMoved flag for garbage collector
  Type_EvenPC*: uint8 = 38    #  46 PC at first instruction in word
  Type_OddPC*: uint8 = 39 #  47 PC at second instruction in word

  #  FullWord instructions.
  Type_CallCompiledEven*: uint8 = 40 #  50 Start call
  Type_CallCompiledOdd*: uint8 = 41 #  51 Start call
  Type_CallIndirect*: uint8 = 42 #  52 Start call
  Type_CallGeneric*: uint8 = 43 #  53 Start call
  Type_CallCompiledEvenPrefetch*: uint8 = 44 #  54 Like above
  Type_CallCompiledOddPrefetch*: uint8 = 45 #  55 Like above
  Type_CallIndirectPrefetch*: uint8 = 46 #  56 Like above
  Type_CallGenericPrefetch*: uint8 = 47 #  57 Like above

  #  HalfWord (packed) instructions consume 4 bits of data type field (opcodes 60..77).
  Type_PackedInstruction60*: uint8 = 48
  Type_TypePackedInstruction61*: uint8 = 49
  Type_TypePackedInstruction62*: uint8 = 50
  Type_PackedInstruction63*: uint8 = 51
  Type_TypePackedInstruction64*: uint8 = 52
  Type_TypePackedInstruction65*: uint8 = 53
  Type_PackedInstruction66*: uint8 = 54
  Type_TypePackedInstruction67*: uint8 = 55
  Type_TypePackedInstruction70*: uint8 = 56
  Type_PackedInstruction71*: uint8 = 57
  Type_TypePackedInstruction72*: uint8 = 58
  Type_TypePackedInstruction73*: uint8 = 59
  Type_PackedInstruction74*: uint8 = 60
  Type_TypePackedInstruction75*: uint8 = 61
  Type_TypePackedInstruction76*: uint8 = 62
  Type_PackedInstruction77*: uint8 = 63

  ####################################################################################################################
  ##
  ## CDR tag
  ##
  ####################################################################################################################

  Cdr_Next*: uint8 = 0
  Cdr_Nil*: uint8 = 1
  Cdr_Normal*: uint8 = 2

  ####################################################################################################################
  ##
  ## ARRAY element tags
  ##
  ####################################################################################################################

  Array_ElementTypeFixnum*: uint8 = 0
  Array_ElementTypeCharacter*: uint8 = 1
  Array_ElementTypeBoolean*: uint8 = 2
  Array_ElementTypeObject*: uint8 = 3

  ####################################################################################################################
  ##
  ## ARRAY bit fields
  ##
  ####################################################################################################################

  Array_TypeFieldPos*: uint8 = 26
  Array_TypeFieldSize*: uint8 = 6
  Array_TypeFieldMask*: uint32 = 63
  Array_ElementTypePos*: uint8 = 30
  Array_ElementTypeSize*: uint8 = 2
  Array_ElementTypeMask*: uint32 = 3
  Array_BytePackingPos*: uint8 = 27
  Array_BytePackingSize*: uint8 = 3
  Array_BytePackingMask*: uint32 = 7
  Array_ListBitPos*: uint8 = 26
  Array_ListBitSize*: uint8 = 1
  Array_ListBitMask*: uint32 = 1
  Array_NamedStructureBitPos*: uint8 = 25
  Array_NamedStructureBitSize*: uint8 = 1
  Array_NamedStructureBitMask*: uint32 = 1
  Array_Spare1Pos*: uint8 = 24
  Array_Spare1Size*: uint8 = 1
  Array_Spare1Mask*: uint32 = 1
  Array_LongPrefixBitPos*: uint8 = 23
  Array_LongPrefixBitSize*: uint8 = 1
  Array_LongPrefixBitMask*: uint32 = 1
  Array_LeaderLengthFieldPos*: uint8 = 15
  Array_LeaderLengthFieldSize*: uint8 = 8
  Array_LeaderLengthFieldMask*: uint32 = 0xFF
  Array_LengthPos*: uint8 = 0
  Array_LengthSize*: uint8 = 15
  Array_LengthMask*: uint32 = 32767
  Array_DisplacedBitPos*: uint8 = 14
  Array_DisplacedBitSize*: uint8 = 1
  Array_DisplacedBitMask*: uint32 = 1
  Array_DiscontiguousBitPos*: uint8 = 13
  Array_DiscontinuousBitSize*: uint8 = 1
  Array_DiscontiguousBitMask*: uint32 = 1
  Array_LongSparePos*: uint8 = 3
  Array_LongSpareSize*: uint8 = 12
  Array_LongSpareMask*: uint32 = 0x0FFF
  Array_LongDimensionsFieldPos*: uint8 = 0
  Array_LongDimensionsFieldSize*: uint8 = 3
  Array_LongDimensionsFieldMask*: uint32 = 7
  Array_RegisterElementTypePos*: uint8 = 30
  Array_RegisterElementTypeSize*: uint8 = 2
  Array_RegisterElementTypeMask*: uint32 = 3
  Array_RegisterBytePackingPos*: uint8 = 27
  Array_RegisterBytePackingSize*: uint8 = 3
  Array_RegisterBytePackingMask*: uint32 = 7
  Array_RegisterByteOffsetPos*: uint8 = 22
  Array_RegisterByteOffsetSize*: uint8 = 5
  Array_RegisterByteOffsetMask*: uint32 = 31
  Array_RegisterEventCountPos*: uint8 = 0
  Array_RegisterEventCountSize*: uint8 = 22
  Array_RegisterEventCountMask*: uint32 = 0x3FFFFF

  ####################################################################################################################
  ##
  ## FIXME What are those?
  ##
  ####################################################################################################################

  ValueDisposition_Effect*: uint8 = 0
  ValueDisposition_Value*: uint8 = 1
  ValueDisposition_Return*: uint8 = 2
  ValueDisposition_Multiple*: uint8 = 3

  ####################################################################################################################
  ##
  ## Instructions opcode - FIXME Should be replaced by macros to include string representation, disassembly, code
  ##
  ####################################################################################################################

  # List manipulation
  OpcodeCar*: uint16 = 0b0000000000
  OpcodeCdr*: uint16 = 0b0000000001
  Opcode_SetToCar*: uint16 = 0b0001100000
  Opcode_SetToCdr*: uint16 = 0b0001100001
  Opcode_SetToCdrPushCar*: uint16 = 0b0001100010
  Opcode_Rplaca*: uint16 = 0b0010000000
  Opcode_Rplacd*: uint16 = 0b0010000001
  Opcode_Rgetf*: uint16 = 0b0010010101
  Opcode_Member*: uint16 = 0b0010010110
  Opcode_Assoc*: uint16 = 0b0010010111

  # AI Instructions
  Opcode_Dereference*: uint16 = 0b0000001011
  Opcode_Unify*: uint16 = 0b0010011111
  Opcode_PushLocalLogicVariables*: uint16 = 0b0001000011
  Opcode_PushGlobalLogicVariable*: uint16 = 0b0000101101
  Opcode_LogicTailTest*: uint16 = 0b0000001100

  # Binary predicates
  Opcode_Eq*: uint16 = 0b0010111000
  Opcode_EqNoPop*: uint16 = 0b0010111100
  Opcode_Eql*: uint16 = 0b0010110011
  Opcode_EqlNoPop*: uint16 = 0b0010110111
  Opcode_EqualNumber*: uint16 = 0b0010110000
  Opcode_EqualNumberNoPop*: uint16 = 0b0010110100
  Opcode_Greaterp*: uint16 = 0b0010110010
  Opcode_GreaterpNoPop*: uint16 = 0b0010110110
  Opcode_Lessp*: uint16 = 0b0010110001
  Opcode_LesspNoPop*: uint16 = 0b0010110101
  Opcode_Logtest*: uint16 = 0b0010111011
  Opcode_LogtestNoPop*: uint16 = 0b0010111111
  Opcode_TypeMember*: uint16 = 0b0000100000
  Opcode_TypeMemberNoPop*: uint16 = 0b0000100100

  # Unary predicates
  Opcode_Endp*: uint16 = 0b0000000010
  Opcode_Plusp*: uint16 = 0b0000011110
  Opcode_Minusp*: uint16 = 0b0000011101
  Opcode_Zerop*: uint16 = 0b0000011100

  # Numeric operations
  Opcode_Add*: uint16 = 0b0011000000
  Opcode_Sub*: uint16 = 0b0011000001
  Opcode_UnaryMinus*: uint16 = 0b0001001100
  Opcode_Increment*: uint16 = 0b0001100011
  Opcode_Decrement*: uint16 = 0b0001100100
  Opcode_Multiply*: uint16 = 0b0010000010
  Opcode_Quotient*: uint16 = 0b0010000011
  Opcode_Ceiling*: uint16 = 0b0010000100
  Opcode_Floor*: uint16 = 0b0010000101
  Opcode_Truncate*: uint16 = 0b0010000110
  Opcode_Round*: uint16 = 0b0010000111
  Opcode_RationalQuotient*: uint16 = 0b0010001001
  Opcode_Max*: uint16 = 0b0010001011
  Opcode_Min*: uint16 = 0b0010001010
  Opcode_Logand*: uint16 = 0b0010001101
  Opcode_Logior*: uint16 = 0b0010001111
  Opcode_Logxor*: uint16 = 0b0010001110
  Opcode_Ash*: uint16 = 0b0010011010
  Opcode_Rot*: uint16 = 0b0010010000
  Opcode_Lsh*: uint16 = 0b0010010001
  Opcode_32BitPlus*: uint16 = 0b0011000010
  Opcode_32BitDifference*: uint16 = 0b0011000011
  Opcode_MultiplyDouble*: uint16 = 0b0010010010
  Opcode_AddBignumStep*: uint16 = 0b0011000100
  Opcode_SubBignumStep*: uint16 = 0b0011000101
  Opcode_MultiplyBignumStep*: uint16 = 0b0011000110
  Opcode_DivideBignumStep*: uint16 = 0b0011000111
  Opcode_LshcBignumStep*: uint16 = 0b0010010011

  # Data movement
  Opcode_Push*: uint16 = 0b0001000000
  Opcode_Pop*: uint16 = 0b0011100000
  Opcode_Movem*: uint16 = 0b0011100001
  Opcode_PushNNils*: uint16 = 0b0001000001
  Opcode_PushAddress*: uint16 = 0b0001101000
  Opcode_SetSpToAddress*: uint16 = 0b0001101001
  Opcode_SetSpToAddressSaveTos*: uint16 = 0b0001101010
  Opcode_PushAddressSpRelative*: uint16 = 0b0001000010
  Opcode_StackBlt*: uint16 = 0b0010010100
  Opcode_StackBltAddress*: uint16 = 0b0011101010

  # FieldExtraction instructions
  Opcode_Ldb*: uint16 = 0b0001111000
  Opcode_Dpb*: uint16 = 0b0011111000
  Opcode_CharLdb*: uint16 = 0b0001111001
  Opcode_CharDpb*: uint16 = 0b0011111001
  Opcode_PLdb*: uint16 = 0b0001111010
  Opcode_PDpb*: uint16 = 0b0011111010
  Opcode_PTagLdb*: uint16 = 0b0001111011
  Opcode_PTagDpb*: uint16 = 0b0011111011

  # Array operations
  Opcode_Aref1*: uint16 = 0b0011001010
  Opcode_Aset1*: uint16 = 0b0011001000
  Opcode_Aloc1*: uint16 = 0b0011001011
  Opcode_Setup1DArray*: uint16 = 0b0000000011
  Opcode_SetupForce1DArray*: uint16 = 0b0000000100
  Opcode_FastAref1*: uint16 = 0b0011101000
  Opcode_FastAset1*: uint16 = 0b0011101001
  Opcode_ArrayLeader*: uint16 = 0b0011001110
  Opcode_StoreArrayLeader*: uint16 = 0b0011001100
  Opcode_AlocLeader*: uint16 = 0b0011001111

  # Branch instructions
  Opcode_Branch*: uint16 = 0b0001111100
  Opcode_BranchTrue*: uint16 = 0b0000110000
  Opcode_BranchTrueElseExtraPop*: uint16 = 0b0000110001
  Opcode_BranchTrueAndExtraPop*: uint16 = 0b0000110010
  Opcode_BranchTrueExtraPop*: uint16 = 0b0000110011
  Opcode_BranchTrueNoPop*: uint16 = 0b0000110100
  Opcode_BranchTrueAndNoPop*: uint16 = 0b0000110101
  Opcode_BranchTrueElseNoPop*: uint16 = 0b0000110110
  Opcode_BranchTrueAndNoPopElseNoPopExtraPop*: uint16 = 0b0000110111
  Opcode_BranchFalse*: uint16 = 0b0000111000
  Opcode_BranchFalseElseExtraPop*: uint16 = 0b0000111001
  Opcode_BranchFalseAndExtraPop*: uint16 = 0b0000111010
  Opcode_BranchFalseExtraPop*: uint16 = 0b0000111011
  Opcode_BranchFalseNoPop*: uint16 = 0b0000111100
  Opcode_BranchFalseAndNoPop*: uint16 = 0b0000111101
  Opcode_BranchFalseElseNoPop*: uint16 = 0b0000111110
  Opcode_BranchFalseAndNoPopElseNoPopExtraPop*: uint16 = 0b0000111111
  Opcode_LoopDecrementTos*: uint16 = 0b0001111101
  Opcode_LoopIncrementTosLessThan*: uint16 = 0b0011111101

  # Block instructions
  Opcode_Block0Read*: uint16 = 0b0001010000
  Opcode_Block1Read*: uint16 = 0b0001010001
  Opcode_Block2Read*: uint16 = 0b0001010010
  Opcode_Block3Read*: uint16 = 0b0001010011
  Opcode_Block0ReadShift*: uint16 = 0b0001010100
  Opcode_Block1ReadShift*: uint16 = 0b0001010101
  Opcode_Block2ReadShift*: uint16 = 0b0001010110
  Opcode_Block3ReadShift*: uint16 = 0b0001010111
  Opcode_Block0ReadAlu*: uint16 = 0b0001110000
  Opcode_Block1ReadAlu*: uint16 = 0b0001110001
  Opcode_Block2ReadAlu*: uint16 = 0b0001110010
  Opcode_Block3ReadAlu*: uint16 = 0b0001110011
  Opcode_Block0ReadTest*: uint16 = 0b0001011000
  Opcode_Block1ReadTest*: uint16 = 0b0001011001
  Opcode_Block2ReadTest*: uint16 = 0b0001011010
  Opcode_Block3ReadTest*: uint16 = 0b0001011011
  Opcode_Block0Write*: uint16 = 0b0000011000
  Opcode_Block1Write*: uint16 = 0b0000011001
  Opcode_Block2Write*: uint16 = 0b0000011010
  Opcode_Block3Write*: uint16 = 0b0000011011

  # Function calling
  Opcode_StartCall*: uint16 = 0b0000001000
  Opcode_FinishCallN*: uint16 = 0b0001011100
  Opcode_FinishCallNApply*: uint16 = 0b0001011101
  Opcode_FinishCallTos*: uint16 = 0b0001011110
  Opcode_FinishCallTosApply*: uint16 = 0b0001011111
  Opcode_EntryRestAccepted*: uint16 = 0b0001111110
  Opcode_EntryRestNotAccepted*: uint16 = 0b0001111111
  Opcode_LocateLocals*: uint16 = 0b0000101000
  Opcode_ReturnSingle*: uint16 = 0b0001001101
  Opcode_ReturnMultiple*: uint16 = 0b0001000100
  Opcode_ReturnKludge*: uint16 = 0b0001000101
  Opcode_TakeValues*: uint16 = 0b0001000110

  # Binding instructions
  Opcode_BindLocativeToValue*: uint16 = 0b0010011110
  Opcode_BindLocative*: uint16 = 0b0000000101
  Opcode_UnbindN*: uint16 = 0b0001000111
  Opcode_RestoreBindingStack*: uint16 = 0b0000000110

  # Catch
  Opcode_CatchOpen*: uint16 = 0b0011111110
  Opcode_CatchClose*: uint16 = 0b0000101001

  # Lexical variables - Each takes 8 opcodes
  Opcode_PushLexicalVar*: uint16 = 0b0000010000
  Opcode_PopLexicalVar*: uint16 = 0b0010100000
  Opcode_MovemLexicalVar*: uint16 = 0b0010101000

  # Instance variables
  Opcode_PushInstanceVariable*: uint16 = 0b0001001000
  Opcode_PopInstanceVariable*: uint16 = 0b0011010000
  Opcode_MovemInstanceVariable*: uint16 = 0b0011010001
  Opcode_PushAddressInstanceVariable*: uint16 = 0b0001001001
  Opcode_PushInstanceVariableOrdered*: uint16 = 0b0001001010
  Opcode_PopInstanceVariableOrdered*: uint16 = 0b0011010010
  Opcode_MovemInstanceVariableOrdered*: uint16 = 0b0011010011
  Opcode_PushAddressInstanceVariableOrdered*: uint16 = 0b0001001011
  Opcode_InstanceRef*: uint16 = 0b0011010100
  Opcode_InstanceSet*: uint16 = 0b0011010101
  Opcode_InstanceLoc*: uint16 = 0b0011010110

  # Sub-primitives
  Opcode_Ephemeralp*: uint16 = 0b0000000111
  Opcode_UnsignedLessp*: uint16 = 0b0011011001
  Opcode_UnsignedLesspNoPop*: uint16 = 0b0011011101
  Opcode_Alu*: uint16 = 0b0010001100
  Opcode_AllocateListBlock*: uint16 = 0b0011001001
  Opcode_AllocateStructureBlock*: uint16 = 0b0011001101
  Opcode_PointerPlus*: uint16 = 0b0010011000
  Opcode_PointerDifference*: uint16 = 0b0010011001
  Opcode_PointerIncrement*: uint16 = 0b0001100101
  Opcode_ReadInternalRegister*: uint16 = 0b0001101100
  Opcode_WriteInternalRegister*: uint16 = 0b0001101101
  Opcode_CoprocessorRead*: uint16 = 0b0001101110
  Opcode_CoprocessorWrite*: uint16 = 0b0001101111
  Opcode_MemoryRead*: uint16 = 0b0001001110
  Opcode_MemoryReadAddress*: uint16 = 0b0001001111
  Opcode_Tag*: uint16 = 0b0000001010
  Opcode_SetTag*: uint16 = 0b0011010111
  Opcode_StoreConditional*: uint16 = 0b0010011011
  Opcode_MemoryWrite*: uint16 = 0b0010011100
  Opcode_PStoreContents*: uint16 = 0b0010011101
  Opcode_SetCdrCode1*: uint16 = 0b0001100110
  Opcode_SetCdrCode2*: uint16 = 0b0001100111
  Opcode_MergeCdrNoPop*: uint16 = 0b0011100010
  Opcode_GenericDispatch*: uint16 = 0b0000101010
  Opcode_MessageDispatch*: uint16 = 0b0000101011
  Opcode_Jump*: uint16 = 0b0000001001
  Opcode_CheckPreemptRequest*: uint16 = 0b0000101100
  Opcode_NoOp*: uint16 = 0b0000101110
  Opcode_Halt*: uint16 = 0b0000101111

  ####################################################################################################################
  ##
  ## FIXME What are those?
  ##
  ####################################################################################################################

  Control_Apply* = 0000400000
  Control_CleanupBits* = 0700000000
  Control_CallStarted* = 0020000000
  Control_ExtraArgument* = 0000000400
  Control_ArgumentSize* = 0000000377
  Control_CallerFrameSize* = 0000077000
  Control_ValueDisposition* = 0003000000

  ####################################################################################################################
  ##
  ## CPU internal registers
  ##
  ####################################################################################################################

  InternalRegister_EA* = 00
  InternalRegister_FP* = 01
  InternalRegister_LP* = 02
  InternalRegister_SP* = 03
  InternalRegister_MacroSP* = 04
  InternalRegister_StackCacheLowerBound* = 05
  InternalRegister_BAR0* = 06
  InternalRegister_BAR1* = 0206
  InternalRegister_BAR2* = 0406
  InternalRegister_BAR3* = 0606
  InternalRegister_PHTHash0* = 07
  InternalRegister_PHTHash1* = 0207
  InternalRegister_PHTHash2* = 0407
  InternalRegister_PHTHash3* = 0607
  InternalRegister_EPC* = 010
  InternalRegister_DPC* = 011
  InternalRegister_Continuation* = 012
  InternalRegister_AluAndRotateControl* = 013
  InternalRegister_ControlRegister* = 014
  InternalRegister_CRArgumentSize* = 015
  InternalRegister_EphemeralOldspaceRegister* = 016
  InternalRegister_ZoneOldspaceRegister* = 017
  InternalRegister_ChipRevision* = 020
  InternalRegister_FPCoprocessorPresent* = 021
  InternalRegister_PreemptRegister* = 023
  InternalRegister_IcacheControl* = 024
  InternalRegister_PrefetcherControl* = 025
  InternalRegister_MapCacheControl* = 026
  InternalRegister_MemoryControl* = 027
  InternalRegister_ECCLog* = 030
  InternalRegister_ECCLogAddress* = 031
  InternalRegister_InvalidateMap0* = 032
  InternalRegister_InvalidateMap1* = 0232
  InternalRegister_InvalidateMap2* = 0432
  InternalRegister_InvalidateMap3* = 0632
  InternalRegister_LoadMap0* = 033
  InternalRegister_LoadMap1* = 0233
  InternalRegister_LoadMap2* = 0433
  InternalRegister_LoadMap3* = 0633
  InternalRegister_StackCacheOverflowLimit* = 034
  InternalRegister_UcodeROMContents* = 035
  InternalRegister_AddressMask* = 037
  InternalRegister_EntryMaximumArguments* = 040
  InternalRegister_LexicalVariable* = 041
  InternalRegister_Instruction* = 042
  InternalRegister_MemoryData* = 044
  InternalRegister_DataPins* = 045
  InternalRegister_ExtensionRegister* = 046
  InternalRegister_MicrosecondClock* = 047
  InternalRegister_ArrayHeaderLength* = 050
  InternalRegister_LoadBAR0* = 052
  InternalRegister_LoadBAR1* = 0252
  InternalRegister_LoadBAR2* = 0452
  InternalRegister_LoadBAR3* = 0652
  InternalRegister_TOS* = 01000
  InternalRegister_EventCount* = 01001
  InternalRegister_BindingStackPointer* = 01002
  InternalRegister_CatchBlockList* = 01003
  InternalRegister_ControlStackLimit* = 01004
  InternalRegister_ControlStackExtraLimit* = 01005
  InternalRegister_BindingStackLimit* = 01006
  InternalRegister_PHTBase* = 01007
  InternalRegister_PHTMask* = 01010
  InternalRegister_CountMapReloads* = 01011
  InternalRegister_ListCacheArea* = 01012
  InternalRegister_ListCacheAddress* = 01013
  InternalRegister_ListCacheLength* = 01014
  InternalRegister_StructureCacheArea* = 01015
  InternalRegister_StructureCacheAddress* = 01016
  InternalRegister_StructureCacheLength* = 01017
  InternalRegister_DynamicBindingCacheBase* = 01020
  InternalRegister_DynamicBindingCacheMask* = 01021
  InternalRegister_ChoicePointer* = 01022
  InternalRegister_StructureStackChoicePointer* = 01023
  InternalRegister_FEPModeTrapVectorAddress* = 01024
  InternalRegister_MappingTableCache* = 01026
  InternalRegister_MappingTableLength* = 01027
  InternalRegister_StackFrameMaximumSize* = 01030
  InternalRegister_StackCacheDumpQuantum* = 01031
  InternalRegister_ConstantNIL* = 01040
  InternalRegister_ConstantT* = 01041

  ####################################################################################################################
  ##
  ## Coprocessor registers
  ##
  ####################################################################################################################

  CoprocessorRegister_MicrosecondClock*: uint32 = 514
  CoprocessorRegister_HostInterrupt*: uint32 = 520
  CoprocessorRegister_VMRegisterCommand*: uint32 = 576
  CoprocessorRegister_VMRegisterAddress*: uint32 = 577
  CoprocessorRegister_VMRegisterExtent*: uint32 = 578
  CoprocessorRegister_VMRegisterAttributes*: uint32 = 579
  CoprocessorRegister_VMRegisterDestination*: uint32 = 580
  CoprocessorRegister_VMRegisterData*: uint32 = 581
  CoprocessorRegister_VMRegisterMaskLow*: uint32 = 582
  CoprocessorRegister_VMRegisterMaskHigh*: uint32 = 583
  CoprocessorRegister_VMRegisterCommandBlock*: uint32 = 584
  CoprocessorRegister_StackSwitch*: uint32 = 640
  CoprocessorRegister_FlushStackCache*: uint32 = 641
  CoprocessorRegister_FlushIDCaches*: uint32 = 642
  CoprocessorRegister_CalendarClock*: uint32 = 643
  CoprocessorRegister_FlushCachesForVMA*: uint32 = 644
  CoprocessorRegister_FlipToStack*: uint32 = 645
  CoprocessorRegister_UnwindStackForRestartOrApply*: uint32 = 646
  CoprocessorRegister_SaveWorld*: uint32 = 647
  CoprocessorRegister_ConsoleInputAvailableP*: uint32 = 648
  CoprocessorRegister_WaitForEvent*: uint32 = 649
  CoprocessorRegister_FlushHiddenArrayRegisters*: uint32 = 650
  CoprocessorRegister_ConsoleIO*: uint32 = 651
  CoprocessorRegister_AttachDiskChannel*: uint32 = 652
  CoprocessorRegister_GrowDiskPartition*: uint32 = 653
  CoprocessorRegister_DetachDiskChannel*: uint32 = 654

  ####################################################################################################################
  ##
  ## Arithmetic / logical unit condition constants
  ##
  ####################################################################################################################

  ALUCondition_SignedLessThanOrEqual*: uint8 = 0
  ALUCondition_SignedLessThan*: uint8 = 1
  ALUCondition_Negative*: uint8 = 2
  ALUCondition_SignedOverflow*: uint8 = 3
  ALUCondition_UnsignedLessThanOrEqual*: uint8 = 4
  ALUCondition_UnsignedLessThan*: uint8 = 5
  ALUCondition_Zero*: uint8 = 6
  ALUCondition_High25Zero*: uint8 = 7
  ALUCondition_Eq*: uint8 = 8
  ALUCondition_Op1Ephemeralp*: uint8 = 9
  ALUCondition_Op1TypeAcceptable*: uint8 = 10
  ALUCondition_Op1TypeCondition*: uint8 = 11
  ALUCondition_ResultTypeNil*: uint8 = 12
  ALUCondition_Op2Fixnum*: uint8 = 13
  ALUCondition_False*: uint8 = 14
  ALUCondition_ResultCdrLow*: uint8 = 15
  ALUCondition_CleanupBitsSet*: uint8 = 16
  ALUCondition_AddressInStackCache*: uint8 = 17
  ALUCondition_PendingSequenceBreakEnabled*: uint8 = 18
  ALUCondition_ExtraStackMode*: uint8 = 19
  ALUCondition_FepMode*: uint8 = 20
  ALUCondition_FpCoprocessorPresent*: uint8 = 21
  ALUCondition_Op1Oldspacep*: uint8 = 22
  ALUCondition_StackCacheOverflow*: uint8 = 23
  ALUCondition_OrLogicVariable*: uint8 = 24

  ALUAdderOp2_Op2*: uint8 = 0
  ALUAdderOp2_Zero*: uint8 = 1
  ALUAdderOp2_Invert*: uint8 = 2
  ALUAdderOp2_MinusOne*: uint8 = 3

  ALUByteFunction_Dpb*: uint8 = 0
  ALUByteFunction_Ldb*: uint8 = 1
  ALUByteBackground_Op1*: uint8 = 0
  ALUByteBackground_RotateLatch*: uint8 = 1
  ALUByteBackground_Zero*: uint8 = 2

  Boole_Clear*: uint8 = 0
  Boole_And*: uint8 = 1
  Boole_AndC1*: uint8 = 2
  Boole_2*: uint8 = 3
  Boole_AndC2*: uint8 = 4
  Boole_1*: uint8 = 5
  Boole_Xor*: uint8 = 6
  Boole_Ior*: uint8 = 7
  Boole_Nor*: uint8 = 8
  Boole_Equiv*: uint8 = 9
  Boole_C1*: uint8 = 10
  Boole_OrC1*: uint8 = 11
  Boole_C2*: uint8 = 12
  Boole_OrC2*: uint8 = 13
  Boole_Nand*: uint8 = 14
  Boole_Set*: uint8 = 15

  ALUFunction_Boolean*: uint8 = 0
  ALUFunction_Byte*: uint8 = 1
  ALUFunction_Adder*: uint8 = 2
  ALUFunction_MultiplyDivide*: uint8 = 3


  ####################################################################################################################
  ##
  ## FIXME What are those?
  ##
  ####################################################################################################################

  TrapMode_Emulator*: uint8 = 0
  TrapMode_ExtraStack*: uint8 = 1
  TrapMode_IO*: uint8 = 2
  TrapMode_FEP*: uint8 = 3

  ####################################################################################################################
  ##
  ## Exceptions
  ##
  ####################################################################################################################

  ReturnValue_Normal*: uint8 = 0
  ReturnValue_Exception*: uint8 = 1
  ReturnValue_IllegalOperand*: uint8 = 2

  HaltReason_IllInstn*: uint8 = 1
  HaltReason_Halted*: uint8 = 2
  HaltReason_SpyCalled*: uint8 = 3
  HaltReason_FatalStackOverflow*: uint8 = 4
  HaltReason_IllegalTrapVector*: uint8 = 5

  TrapReason_HighPrioritySequenceBreak*: uint8 = 1
  TrapReason_LowPrioritySequenceBreak*: uint8 = 2

  DoubleFloatOp_Add*: uint8 = 0
  DoubleFloatOp_Sub*: uint8 = 1
  DoubleFloatOp_Multiply*: uint8 = 2
  DoubleFloatOp_Divide*: uint8 = 3

