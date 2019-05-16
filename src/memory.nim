####################################################################################################################
##
# Memory mechanics
##
####################################################################################################################


import strformat
import types

# Defines a distinct type to be different from the other uses of uint32, but automatically converted to uint32
type
  VM_AddressOLD* = distinct uint32

# return type should be the same as aboove
converter toU32 *(vma: VM_AddressOLD): uint32 = result = vma.uint32
proc toIndex* (vma: VM_AddressOLD): uint32 = result = vma.uint32
proc `+`* (vma1, vma2: VM_AddressOLD): VM_AddressOLD {.borrow.}
proc `-`* (vma1, vma2: VM_AddressOLD): VM_AddressOLD {.borrow.}
proc `$`*(vma: VM_AddressOLD): string = fmt"{vma:#X}"

type
  QAddress* = distinct uint32

# return type should be the same as aboove
converter toU32 *(vma: QAddress): uint32 = result = vma.uint32
proc toIndex* (vma: QAddress): uint32 = result = vma.uint32
proc `+`* (vma1, vma2: QAddress): QAddress {.borrow.}
proc `-`* (vma1, vma2: QAddress): QAddress {.borrow.}
proc `$`*(vma: QAddress): string = fmt"{vma:#X}"

type
  ByteAddress* = distinct uint32

# return type should be the same as aboove
converter toU32 *(vma: ByteAddress): uint32 = result = vma.uint32
proc toIndex* (vma: ByteAddress): uint32 = result = vma.uint32
proc `+`* (vma1, vma2: ByteAddress): ByteAddress {.borrow.}
proc `-`* (vma1, vma2: ByteAddress): ByteAddress {.borrow.}
proc `$`*(vma: ByteAddress): string = fmt"{vma:#X}"


const
  # size reflects 'count from 0' array indices
  Memory_TotalSize*: QAddress = ((1 shl 32) - 1).QAddress

  # Page size is 13 bits = 0x2000 = 8,192
  MemoryPage_AddressShift*: uint8 = 13
  MemoryPage_Size*: ByteAddress = (1 shl 13).ByteAddress

  PageSize* = 0x100
  PageNumberMask* = 0xffffff00
  PageOffsetMask* = 0xff
  PageAddressShift* = 8

  AddressQuantumShift* = 20
  QuantumSize* = 1 shl AddressQuantumShift


type
  VM_PageNumber* = int32

  VM_PageData* = array[PageSize, LO_Content]
  VM_PageTag* = array[PageSize, LO_Tag]

converter toI32*(vpn: VM_PageNumber): int32 = result = vpn.int32
converter toU32*(vpn: VM_PageNumber): uint32 = result = vpn.uint32
converter toI64*(vpn: VM_PageNumber): int64 = result = vpn.int64
proc `$`*(vpn: VM_PageNumber): string = fmt"{vpn:#X}"

# FIXME: Note sure if the type is the correct one
proc addressPageNumber *(vma: ByteAddress): VM_PageNumber =
  return (toIndex(vma) shr (PageAddressShift)).VM_PageNumber



####################################################################################################################
##
## Virtual memory attributes
##
####################################################################################################################

const
  VMAttribute_AccessFault*: uint8 = 0b00000001
  VMAttribute_WriteFault*: uint8 = 0b00000010
  VMAttribute_TransportFault*: uint8 = 0b00000100
  VMAttribute_TransportDisable*: uint8 = 0b00001000
  VMAttribute_Ephemeral*: uint8 = 0b00010000
  VMAttribute_Modified*: uint8 = 0b00100000
  VMAttribute_Exists*: uint8 = 0b01000000

  VMCreatedDefault*: uint8 = (VMAttributeAccessFault or
      VMAttributeTransportFault or VMAttributeExists)


####################################################################################################################
##
## Memory reading cycles
##
####################################################################################################################

const
  Cycle_DataRead*: uint8 = 0
  Cycle_DataWrite*: uint8 = 1
  Cycle_BindRead*: uint8 = 2
  Cycle_BindWrite*: uint8 = 3
  Cycle_BindReadNoMonitor*: uint8 = 4
  Cycle_BindWriteNoMonitor*: uint8 = 5
  Cycle_Header*: uint8 = 6
  Cycle_StructureOffset*: uint8 = 7
  Cycle_Scavenge*: uint8 = 8
  Cycle_Cdr*: uint8 = 9
  Cycle_GCCopy*: uint8 = 10
  Cycle_Raw*: uint8 = 11
  Cycle_RawTranslate*: uint8 = 12

####################################################################################################################
##
## FIXME What are those?
##
####################################################################################################################

const
  MemoryAction_None*: uint8 = 0b000000
  MemoryAction_Indirect*: uint8 = 0b000001
  MemoryAction_Monitor*: uint8 = 0b000010
  MemoryAction_Transport*: uint8 = 0b000100
  MemoryAction_Trap*: uint8 = 0b001000
  MemoryAction_Transform*: uint8 = 0b010000
  MemoryAction_Binding*: uint8 = 0b100000
