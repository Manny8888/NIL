####################################################################################################################
##
# Defines various types such as lisp objects variants
##
####################################################################################################################


import constants
import strformat

####################################################################################################################
# 
# Lisp Objects: 2 parts of 32 bits each
#
####################################################################################################################

## Type declaration
#######################################

# tags are stored as 8 bits for the moment

const
  # Just to be explicit in pointer calculations
  # And maybe one day allow for more tags and 64-bit lisp machines......
  # The size in bits needs to be enough to store all the bits.
  dataSizeInBits*: uint32 = 28
  dataSizeInBytes*: uint32 = 4
  dataSizeMask*: uint32 = 0b0000_1111_1111_1111_1111_1111_1111_1111.uint32

  tagSizeInBits*: uint32 = 32.uint32 - dataSizeInBits
  tagSizeInBytes*: uint32 = 1
  tagSizeMask*: uint32 = 0b1111_0000_0000_0000_0000_0000_0000_0000.uint32

type
  # Those types reflects the sizes just above
  LO_Tag* = uint8
  LO_Data_Unsigned* = distinct uint32
  LO_Data_Signed* = distinct int32
  LO_Data_Float* = distinct float32

converter toU32 *(value: LO_Data_Unsigned): uint32 = result = value.uint32
converter toI32 *(value: LO_Data_Signed): int32 = result = value.int32
converter toF32 *(value: LO_Data_Float): float32 = result = value.float32
proc `$`* (v: LO_Data_Unsigned): string = $(v.uint32)
proc `$`* (v: LO_Data_Signed): string = $(v.int32)
proc `$`* (v: LO_Data_Float): string = $(v.float32)


type
  LO_ContentKind* = enum
    LO_UInt,
    LO_SInt,
    LO_Float

  LO_Content* = object
    case kind: LO_ContentKind
    of LO_UInt: u*: LO_Data_Unsigned
    of LO_SInt: s*: LO_Data_Signed
    of LO_Float: f*: LO_Data_Float # for signed float... Just because cannot use Float

  LispQ* = object
    tag*: LO_Tag
    data*: LO_Content


proc `$`* (q: LispQ): string =
  # echo fmt"Q: tag = {q.tag:#X} / {q.tag:#b} --- data: u = {q.data.u:#X} / {q.data.u}  s = {q.data.s:#H} / {q.data.s}   f = {q.data.f}"
  echo fmt"Q: tag = {q.tag:#X} / {q.tag:#b} --- data: u = {q.data.u:#X} / {q.data.u}"


## Constructor/setters/getters
#######################################

proc makeLispObjectU *(newTag: LO_Tag, newData: LO_Data_Unsigned): LispQ =
  var o: LispQ
  o.tag = newTag
  o.data.u = newData
  return o

proc makeLispObjectS *(newTag: LO_Tag, newData: LO_Data_Signed): LispQ =
  var o: LispQ
  o.tag = newTag
  o.data.s = newData
  return o

proc makeLispObjectF *(newTag: LO_Tag, newData: LO_Data_Float): LispQ =
  var o: LispQ
  o.tag = newTag
  o.data.f = newData
  return o

proc tag *(o: LispQ): LO_Tag =
  return o.tag

proc data *(o: LispQ): LO_Content =
  return o.data

proc setTag *(o: var LispQ, newTag: LO_Tag) = o.tag = newTag
proc setData *(o: var LispQ, newData: LO_Data_Unsigned): void = o.data.u = newData
proc setData *(o: var LispQ, newData: LO_Data_Signed): void = o.data.s = newData
proc setData *(o: var LispQ, newData: LO_Data_Float): void = o.data.f = newData







