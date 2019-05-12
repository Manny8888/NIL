####################################################################################################################
##
# CPU mechanics
##
####################################################################################################################



import memory, types

const
  InstructionCacheSize* = 2048
  InstructionCacheLineSize* = 64


type
  Bar* = object
    address: VM_Address
    mapped: VM_Address

  InstructionCacheLine* = object
    PC: VM_Address
    nextPC: VM_Address
    code: uint32
    operand: uint32
    nextCacheLine: ref InstructionCacheLine

  CPU* = object
    SP: VM_Address
    RestartsP: VM_Address
    FP: VM_Address
    LP: VM_Address

    # This counter increases 1 by 1 and therefore alternates between even
    # and odd addresses. The tag memory and data memory spaces are separate. 
    # Therefore, loading 64 bits will
    # load 2 consecutive tags and 2 consecutive addresses (think cons or list structure).
    PC: VM_Address
    Continuation: VM_Address
    InstructionCache: InstructionCacheLine
    StackCache: VM_Address
    StackCacheLimit: VM_Address
    Bar: array[0..3, Bar]
    ListCacheArea: VM_Address
    ListCacheAddress: VM_Address
    StructureCacheArea: VM_Address
    StructureCacheAddress: VM_Address
    CatchBlockPointer: VM_Address

    # Integer fields were at the end for better alignment - but their size now matches architecture size (32 or 64 bits
    Control: uint32
    StackCacheBase: uint32
    ArrayEventCount: uint32
    ListCacheLength: uint32
    StructureCacheLength: uint32
    BindingStackPointer: VM_Address
    BindingStackLimit: uint32
    DeepBoundP: bool
    PreemptRegister: uint32
    AluAndRotateControl: uint32
    AluOp: uint32             # FIXME Should be a funciton pointer
    ByteSize: uint32
    ByteRotate: uint32
    RotateLatch: uint32
    ALUOverflow: bool
    ALUBorrow: bool
    ALULessThan: bool
    EphemeralOldspaceRegister: LispObject
    ZoneOldspaceRegister: LispObject
    ControlStackLimit: uint32
    ControlStackExtraLimit: uint32
    DynamicBindingCacheBase: uint32
    DynamicBindingCacheMask: uint32
    FEPModeTrapVectorAddress: VM_Address
    MappingTableCache: uint32
    MappingTableLength: uint32
    RunningP: bool
    Instruction_count: uint64
