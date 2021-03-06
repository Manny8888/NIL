####################################################################################################################
##
# Defines various types such as lisp objects variants
##
####################################################################################################################


import math, strformat
import constants

####################################################################################################################
# 
# Lisp Objects: 2 parts of 32 bits each
#
####################################################################################################################

## Type declaration
#######################################

# tags are stored as 8 bits for the moment

type
  # Those types reflects the sizes just above
  QTag* = uint8
  QData* = distinct uint32

  LispQ* = object
    tag*: QTag
    data*: QData


converter toU8 *(value: QTag): uint8 = result = value.uint8
converter toU32 *(value: QData): uint32 = result = value.uint32
converter toU64 *(value: QData): uint64 = result = value.uint64

proc `$`* (t: QTag): string =
  if t.uint8 > 63.uint8:
    return "Unknown_Tag"
  else:
    return $(t.TagType)

proc `$` (d: QData): string {.borrow.}
proc `$`* (q: LispQ): string = fmt"Q: tag = {q.tag:#X} / {q.tag:#b} --- data =  {q.data} / {q.data:#X} / {q.data:#b}"


const
  # Just to be explicit in pointer calculations
  # And maybe one day allow for more tags and 64-bit lisp machines......
  # The size in bits needs to be enough to store all the bits.
  DataSizeInBits*: uint64 = 28
  DataSizeInBytes*: uint64 = sizeof(QData).uint64
  DataSizeMask*: uint64 = (2 ^ DataSizeInBits - 1).uint64

  TagSizeInBits*: uint64 = 32.uint64 - DataSizeInBits
  TagSizeInBytes*: uint64 = sizeof(QTag).uint64
  TagSizeMask*: uint64 = ((2 ^ TagSizeInBits - 1) shl DataSizeInBits).uint64



## Constructor/setters/getters
#######################################

proc makeLispObject* (newTag: QTag, newData: QData): LispQ =
  var o: LispQ
  o.tag = newTag
  o.data = newData
  return o

proc tag *(o: LispQ): QTag =
  return o.tag

proc data *(o: LispQ): QData =
  return o.data

proc setTag *(o: var LispQ, newTag: QTag) = o.tag = newTag
proc setData *(o: var LispQ, newData: QData): void = o.data = newData








