####################################################################################################################
##
# Memory mechanics
##
####################################################################################################################


import strformat, math
import types



####################################################################################################################
# Defines a distinct type to be different from the other uses of uint32, but automatically converted to uint32

const
  VMArchitecture_In_Bits* : uint8 = 32

type
  QAddress* = distinct uint32

# return type should be the same as aboove
converter toU32 *(vma: QAddress): uint32 = result = vma.uint32
converter toU64 *(vma: QAddress): uint64 = result = vma.uint64
proc toIndex* (vma: QAddress): uint32 = result = vma.uint32
proc `+`* (vma1, vma2: QAddress): QAddress {.borrow.}
proc `-`* (vma1, vma2: QAddress): QAddress {.borrow.}
proc `$`*(vma: QAddress): string = fmt"{vma:#X}"


####################################################################################################################
# Address specified in bytes - when reading a load band for example
type
  ByteAddress* = distinct uint32

# return type should be the same as aboove
converter toU32 *(vma: ByteAddress): uint32 = result = vma.uint32
proc toIndex* (vma: ByteAddress): uint32 = result = vma.uint32
proc `+`* (vma1, vma2: ByteAddress): ByteAddress {.borrow.}
proc `-`* (vma1, vma2: ByteAddress): ByteAddress {.borrow.}
proc `$`*(vma: ByteAddress): string = fmt"{vma:#X}"



####################################################################################################################
##
## Utility functions
##
####################################################################################################################


# returns integers with the bottom nBits set to 1 (rest at 0)
proc bottomMask_U32 * (nBits:uint8):uint32 = return uint32(2^nBits - 1)
proc bottomMask_U64 * (nBits:uint8):uint64 = return uint64(2^nBits - 1)
proc bottomMask * (nBits:uint8):QAddress = 
  if VMArchitecture_In_Bits == 32:
    return bottomMask_U32(nBits).QAddress
  elif VMArchitecture_In_Bits == 64:
    return bottomMask_U64(nBits).QAddress
  

# returns integers with the bottom nBits set to 0 (rest at 1)
proc topMask_U32 * (nBits:uint8):uint32 = return bottomMask_U32(nBits) xor 0xFFFF_FFFF.uint32
proc topMask_U64 * (nBits:uint8):uint64 = return bottomMask_U64(nBits) xor 0xFFFF_FFFF_FFFF_FFFF.uint64
proc topMask * (nBits:uint8):QAddress = 
  if VMArchitecture_In_Bits == 32:
    return topMask_U32(nBits).QAddress
  elif VMArchitecture_In_Bits == 64:
    return topMask_U64(nBits).QAddress
  

####################################################################################################################

const
  # size reflects 'count from 0' array indices
  Memory_TotalSize*: QAddress = bottomMask(0)

  # Page size is 13 bits = 0x2000 = 8,192
  MemoryPage_AddressShift* :uint8 = 13
  MemoryPage_Size*: ByteAddress = (2^MemoryPage_AddressShift).ByteAddress
  MemoryPage_Total* : QAddress = (2 ^ (VMArchitecture_In_Bits - MemoryPage_AddressShift)).QAddress

  PageSize* = 0x100
  PageNumberMask* = topMask(8)
  PageOffsetMask* = bottomMask(8)
  PageAddressShift* = 8

  AddressQuantumShift* = 20
  QuantumSize* = 2^AddressQuantumShift


type
  VM_PageNumber* = int32

  VM_PageData* = array[PageSize, QData]
  VM_PageTag* = array[PageSize, QTag]

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

type
  VMAttribute* = uint8

const
  EnableIDS : bool = false
  VMAttribute_AccessFault*: uint8 = 0b00000001
  VMAttribute_WriteFault*: uint8 = 0b00000010
  VMAttribute_TransportFault*: uint8 = 0b00000100
  VMAttribute_TransportDisable*: uint8 = 0b00001000
  VMAttribute_Ephemeral*: uint8 = 0b00010000
  VMAttribute_Modified*: uint8 = 0b00100000
  VMAttribute_Exists*: uint8 = 0b01000000

  VMCreatedDefault*: uint8 = (VMAttributeAccessFault or
      VMAttributeTransportFault or VMAttributeExists)

proc DefaultAttributes(faultp:bool, worldp:bool) : VMAttribute = 

  var
    attr1: VMAttribute 
    attr2: VMAttribute

  if faultp: 
    attr1 = VMAttributeAccessFault
  else:
    attr1 = 0

  if EnableIDS and worldp:
    attr2 = 0
  else:
    attr2 = VMAttribute_Modified

  return VMAttribute_Exists or VMAttribute_Ephemeral or attr1  or attr2



# This could be a sparse array, should someone want to implement it 
var 
  VMAttributeTable : array[0..(2 ^ (MemoryPage_Total.uint64 - 1)), VMAttribute]
  


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



####################################################################################################################
##
## WADs
##
####################################################################################################################

# Wads are clusters of pages for swap contiguity.  The current value is
# chosen so that all the attributes of a wad fit in one long
# In other words: VLM architecture is 32-bits, i.e. 8 bytes which each contains the attributes.
# 8 = 2^3 hence the additional shift by that number

const 
  MemoryWad_AddressShift = MemoryPage_AddressShift + 3 # = 16. 
  MemoryWad_Size :QAddress= (2 ^ MemoryPage_AddressShift).QAddress
  WadExistsMask = 0x4040_4040_4040_4040 # f-ing poor excuse for a macro language dixit in the original
  
proc MemoryWadNumber(vma:QAddress) : VM_PageNumber = 
  return (vma.uint64 shr MemoryWad_AddressShift.uint8).VM_PageNumber

proc MemoryWadOffset(vma:QAddress): QAddress = 
  return (vma.uint64 and (MemoryWad_Size - 1).uint8).QAddress

proc WadNumberMemory(vpn:VM_PageNumber):QAddress = 
  return (vpn.uint64 shl MemoryWad_AddressShift.uint8).QAddress


# FIXME C code uses pointers???
#define WadCreated(vma) ((((int64_t *)VMAttributeTable)[MemoryWadNumber(vma)]) & WadExistsMask)
proc WadCreated(address:QAddress) : bool = 
  var 
    i:int
  
  for i in 0..7:
    if (VMAttributeTable[MemoryWadNumber(address + i.QAddress)] and VMAttribute_Exists) == 0:
      return false
  
  return true



####################################################################################################################
##
## More complicated utility functions
##
####################################################################################################################

# We know underlying machine uses 8192-byte pages, we have to create a page at a time, and tags are char (byte) 
# sized,  we have to create a page of tags at a time
proc MemoryPageNumber(vma:QAddress) : VM_PageNumber = 
  return (vma.uint64 shr MemoryPage_AddressShift.uint8).VM_PageNumber

proc MemoryPageOffset(vma:QAddress): QAddress = 
  return (vma.uint64 and (MemoryPage_Size - 1).uint8).QAddress

proc PageNumberMemory(vpn:VM_PageNumber):QAddress = 
  return (vpn.uint64 shl MemoryPage_AddressShift.uint8).QAddress

proc ceiling (n:SomeNumber, d: SomeNumber): VM_PageNumber = 
  var
    nf = float64(n)
    df = float64(d)

  return ((nf + (df-1)) / df).VM_PageNumber


####################################################################################################################
##
## *** Virtual memory system ****
##
####################################################################################################################

# Computes the PROT_XXX setting for a particular combination of
# VMAttribute's.  C.f., segv_handler, which translates resulting segfault
# back to appropriate Lisp fault 
# Constants are copied from /usr/include/x86_64-linux-gnu/bits/mman-linux.h line 31+
const
  PROT_NONE : uint8 = 0x0 # Page can not be accessed.  
  PROT_READ : uint8 = 0x1 # Page can be read.  
  PROT_WRITE : uint8 = 0x2 # Page can be written.  
  PROT_EXEC : uint8 = 0x4 # Page can be executed.  

proc computeProtection(attr : VMAttribute) : uint8 = 
  var
    newAttr : VMAttribute = attr

  # Don't cause transport faults if they are overridden 
  if (attr and VMAttribute_TransportDisable) != 0 : 
        newAttr = attr and not(VMAttribute_TransportDisable)
  
  if (attr and (VMAttributeExists or VMAttributeTransportFault or VMAttribute_AccessFault)) != VMAttributeExists: 
    return PROT_NONE

  return PROT_READ or PROT_WRITE or PROT_EXEC


proc AdjustProtection(address:QAddress, new_attr: VMAttribute) = 
  discard

# void AdjustProtection(Integer vma, VMAttribute new_attr)
# {
#     VMAttribute *attr = &VMAttributeTable[MemoryPageNumber(vma)];
#     int oldAttribute, newAttribute;
#     VMAttribute oa = *attr;

#     oldAttribute = ComputeProtection(oa);
#     newAttribute = ComputeProtection(new_attr);

#     if (oldAttribute != newAttribute) {
#         caddr_t address = (caddr_t)&TagSpace[vma - MemoryPageOffset(vma)];

#         if ((mprotect_result = mprotect(address, sizeof(Tag) * MemoryPage_Size, newAttribute)))
#             vpunt("AdjustProtection", "mprotect(%lx, #, %lx) for VMA %x", address, newAttribute, (uint64_t)vma);
#     }

#     *attr = new_attr;
# }

proc SetCreated( vma:QAddress,  faultp:bool,  worldp: bool) = 

  AdjustProtection(vma, DefaultAttributes(faultp, worldp))
  discard

proc created(vma:QAddress) :bool = 
  return (VMAttributeExists and VMAttributeTable[MemoryPageNumber(vma)]) != 0

proc clearCreated(vma:QAddress) =
  AdjustProtection(vma, 0)
  discard


proc EnsureVirtualAddress(address : QAddress, faultp:bool):ByteAddress = 
  
  var 
    attr : VMAttribute = VMAttributeTable[MemoryPageNumber(address)]
    alignedVMAddress : QAddress
    protectionStatus : uint8


  if (attr and VMAttributeExists) != 0:
    # All "created" pages are modified for our purposes
    # FIXME Does it mean that created pages are considered dirty? 
    if (attr and VMAttribute_Modified) != 0:
      AdjustProtection(address, attr or VMAttribute_Modified)
    return MemoryPage_Size





  if WadCreated(address):
    SetCreated(address, faultp, false)
  else:
    alignedVMAddress = address - MemoryWadOffset(address)
    attr = DefaultAttributes(faultp, false)
    protectionStatus = computeProtection(attr)
    
#         Integer aligned_vma = vma - MemoryWadOffset(vma);
#         VMAttribute attr = DefaultAttributes(faultp, FALSE);
#         int prot = ComputeProtection(attr);
#         caddr_t data = (caddr_t)&DataSpace[aligned_vma];
#         caddr_t tag = (caddr_t)&TagSpace[aligned_vma];


  discard

# Integer EnsureVirtualAddress(Integer vma, Boolean faultp)
# {
#     VMAttribute attr = VMAttributeTable[MemoryPageNumber(vma)];

#     if (attr & VMAttribute_Exists) {
#         // All "created" pages are modified for our purposes
#         if (!(attr & VMAttribute_Modified)) {
#             AdjustProtection(vma, attr | VMAttribute_Modified);
#         }
#         return (MemoryPage_Size);
#     }

#     if (WadCreated(vma)) {
#         SetCreated(vma, faultp, FALSE);
#     } else {
#         Integer aligned_vma = vma - MemoryWadOffset(vma);
#         VMAttribute attr = DefaultAttributes(faultp, FALSE);
#         int prot = ComputeProtection(attr);
#         caddr_t data = (caddr_t)&DataSpace[aligned_vma];
#         caddr_t tag = (caddr_t)&TagSpace[aligned_vma];

#         VMAttributeTable[MemoryPageNumber(vma)] = attr;

#         if (data
#             != mmap(data, sizeof(Integer[MemoryWad_Size]), PROT_READ | PROT_WRITE | PROT_EXEC,
#                 MAP_ANONYMOUS | MAP_PRIVATE | MAP_FIXED, -1, 0)) {
#             verror(NULL, "Couldn't create data wad at %lx for VMA %x", data, vma);
#             return (0);
#         }
#         // Avoid spurious ephemeral traps by pointing null pointer into
#         // boundary zone */
#         (void)memset((unsigned char *)data, (unsigned char)-1, sizeof(Integer[MemoryWad_Size]));
#         if (tag != mmap(tag, sizeof(Tag[MemoryWad_Size]), prot, MAP_ANONYMOUS | MAP_PRIVATE | MAP_FIXED, -1, 0)) {
#             verror(NULL, "Couldn't create tag wad at %lx for VMA %x", tag, vma);
#             munmap(data, sizeof(Integer[MemoryWad_Size]));
#             return (0);
#         }
#     }

#     return (MemoryPage_Size);
# }




proc EnsureVirtualAddressRange * (vma:QAddress,  count: QAddress,  faultp:bool): ByteAddress = 
  var
    resultingRange :ByteAddress = 0.ByteAddress
    address:QAddress
    pages = ceiling(count + MemoryPageOffset(vma), MemoryPage_Size)

  for i in 1..pages:
    address = address + MemoryPage_Size.QAddress
    resultingRange =resultingRange + EnsureVirtualAddress(vma, faultp)

  return resultingRange







