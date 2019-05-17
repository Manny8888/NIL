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
  QTag* = uint8
  QData* = distinct uint32


converter toU32 *(value: QData): uint32 = result = value.uint32
proc `$` (d: QData): string = $(d.uint32)


type
  LispQ* = object
    tag*: QTag
    data*: QData

proc `$`* (q: LispQ): string = fmt"Q: tag = {q.tag:#X} / {q.tag:#b} --- data = {q.data:#b} / {q.data:#X} / {q.data}"


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








