
import types, ivory

# Defines a distinct type to be different from the other uses of uint32, but automatically converted to uint32
type
  VM_Address* = distinct uint32

converter toU32(vma: VM_Address): uint32 = result = vma.uint32
converter toI32(vma: VM_Address): int32 = result = vma.int32

const
  # size reflects 'count from 0' array indices
  Memory_TotalSize*: VM_Address = ((1 shl 32) - 1).VM_Address

  # Page size is 13 bits = 0x2000 = 8,192
  MemoryPage_AddressShift*: uint8 = 13
  MemoryPage_Size*: VM_Address = (1 shl 13).VM_Address

  PageSize* = 0x100
  PageNumberMask* = 0xffffff00
  PageOffsetMask* = 0xff
  PageAddressShift* = 8

  AddressQuantumShift* = 20
  QuantumSize* = 1 shl AddressQuantumShift


  ####################################################################################################################
  ##
  ## Virtual memory attributes
  ##
  ####################################################################################################################

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

  MemoryAction_None*: uint8 = 0b000000
  MemoryAction_Indirect*: uint8 = 0b000001
  MemoryAction_Monitor*: uint8 = 0b000010
  MemoryAction_Transport*: uint8 = 0b000100
  MemoryAction_Trap*: uint8 = 0b001000
  MemoryAction_Transform*: uint8 = 0b010000
  MemoryAction_Binding*: uint8 = 0b100000


type
  VM_PageNumber* = uint32

proc addressPageNumber *(vma: VM_Address): VM_PageNumber =
  return vma shr toU32(PageAddressShift)


