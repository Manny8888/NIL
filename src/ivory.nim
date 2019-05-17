####################################################################################################################
##
# IVORY system excluding CPU (i.e. what would be on the addon card inside a Mac)
##
####################################################################################################################




import constants, types, memory, cpu

const
  Address_NIL*: VM_Address = 0xF8041200.VM_Address
  Address_T*: VM_Address = 0xF8041208.VM_Address


type
  Ivory* = object of RootObj
    processor*: CPU
    tagSpace*: array[Memory_TotalSize, QTag]
    dataSpace*: array[Memory_TotalSize, LO_Content]


proc VM_Read *(m: var Ivory, vma: VM_Address): LispObject =
  var address = toIndex(vma)
  result = makeLispObjectU(m.tagSpace[address], m.dataSpace[address].u)

proc VM_Write *(m: var Ivory, vma: VM_Address, obj: LispObject) =
  var address = toIndex(vma)
  m.tagSpace[address] = obj.tag
  m.dataSpace[address] = obj.data

proc VM_ReadBlock *(m: var Ivory, vma: VM_Address, count: VM_Address):
                    array[LispObject] =
  var res: array[LispObject]
  var i: VM_Address
  res = new(array[count])
  for i in [0 ..< count]:
    res[i] = VM_Read(m, vma + i)
  return res

proc VM_WriteBlockConstant *(m: var Ivory, vma: VM_Address,
                             obj: LispObject, count: VM_Address) =
  var i: VM_Address
  for i in [0 ..< count]:
    VM_Write(m, vma + i, obj)
  return res


