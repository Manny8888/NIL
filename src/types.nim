####################################################################################################################
##
# Defines various types such as lisp objects variants
##
####################################################################################################################


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
  LO_Tag* = uint8
  LO_Data_Unsigned* = distinct uint32
  LO_Data_Signed* = distinct int32
  LO_Data_Float* = distinct float32

converter toU32 *(value: LO_Data_Unsigned): uint32 = result = value.uint32
converter toI32 *(value: LO_Data_Signed): int32 = result = value.int32
converter toF32 *(value: LO_Data_Float): float32 = result = value.float32

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

  LispObject* = object
    tag*: LO_Tag
    data*: LO_Content

## Constructor/setters/getters
#######################################

proc makeLispObjectU *(newTag: LO_Tag, newData: LO_Data_Unsigned): LispObject =
  var o: LispObject
  o.tag = newTag
  o.data.u = newData
  return o

proc makeLispObjectS *(newTag: LO_Tag, newData: LO_Data_Signed): LispObject =
  var o: LispObject
  o.tag = newTag
  o.data.s = newData
  return o

proc makeLispObjectF *(newTag: LO_Tag, newData: LO_Data_Float): LispObject =
  var o: LispObject
  o.tag = newTag
  o.data.f = newData
  return o

proc tag *(o: LispObject): LO_Tag =
  return o.tag

proc data *(o: LispObject): LO_Content =
  return o.data

proc setTag *(o: var LispObject, newTag: LO_Tag) = o.tag = newTag
proc setData *(o: var LispObject, newData: LO_Data_Unsigned): void =  o.data.u = newData
proc setData *(o: var LispObject, newData: LO_Data_Signed): void =  o.data.s = newData
proc setData *(o: var LispObject, newData: LO_Data_Float): void =  o.data.f = newData







