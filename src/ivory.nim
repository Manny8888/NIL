import constants, types, memory, processor_state, cpu


type
  Ivory* = object
    processor*: CPU
    dataSpace*: array[0 .. Memory_TotalSize, LO_Content]
    tagSpace*: array[0 .. Memory_TotalSize, LO_Tag]


proc VM_Read *(m: var Ivory, vma: VM_Address): LispObject =
  result = makeLispObjectU(m.tagSpace[vma], m.dataSpace[vma].u)

proc VM_Write *(m: var Ivory, vma: VM_Address, o: LispObject) =
  m.tagSpace[toU32(vma)] = o.tag

proc VM_ReadBlock *(m: var Ivory, vma: VM_Address, count: VM_Address):
                    array[LispObject] =
  var res: array[LispObject]
  var i: VM_Address

  res = new(array[count])
  for i in 0 ..< count:
    res[i] = VM_Read(m, vma+i)

  return res


