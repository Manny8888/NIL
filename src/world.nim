####################################################################################################################
##
# Manipulation of WORLD file
##
####################################################################################################################


import math, strformat
import memory, types, logging, globalstate

# Common world format format definitions
const
  VersionAndArchitectureQ* = 0

  # VLM world file format definitions
  # Note: the magic numbers were defined in octal in the original sources
  VLMWorldFileMagic*: array[4, uint8] =
    [0xA3.uint8, 0x8A.uint8, 0x89.uint8, 0x88.uint8]
  VLMWorldFileMagicSwapped*: array[4, uint8] =
    [0x88.uint8, 0x89.uint8, 0x8A.uint8, 0xA3.uint8]

  VLMWorldSuffix* = ".vlod"

  VLMPageSizeQs* = 0x2000
  VLMBlockSize* = 0x2000
  VLMBlocksPerDataPage* = 4
  VLMBlocksPerTagsPage* = 1
  VLMMaximumHeaderBlocks* = 14
  VLMDataPageSizeBytes* = 4 * VLMPageSizeQs
  VLMTagsPageSizeBytes* = VLMPageSizeQs

  VLMVersion1AndArchitecture*: LO_Data_Unsigned = 0o40000200.LO_Data_Unsigned
  VLMWorldFileV1WiredCountQ*: uint32 = 1
  VLMWorldFileV1UnwiredCountQ*: uint32 = 0
  VLMWorldFileV1PageBasesQ*: uint32 = 3
  VLMWorldFileV1FirstSysoutQ*: uint32 = 0
  VLMWorldFileV1FirstMapQ*: uint32 = 8

  VLMVersion2AndArchitecture*: LO_Data_Unsigned = 0o40000201.LO_Data_Unsigned
  VLMWorldFileV2WiredCountQ*: uint32 = 1
  VLMWorldFileV2UnwiredCountQ*: uint32 = 0
  VLMWorldFileV2PageBasesQ*: uint32 = 2
  VLMWorldFileV2FirstSysoutQ*: uint32 = 3
  VLMWorldFileV2FirstMapQ*: uint32 = 8

  # A page is 256 Q values stored on file as 256 uint32, 256 tags (as bytes)
  IvoryPageSizeBytes*: uint32 = 256.uint32 * (
      dataSizeInBytes+tagSizeInBytes).uint32
  IvoryPageSizeQs*: uint32 = 256
  IvoryWorldFileWiredCountQ* = 1
  IvoryWorldFileUnwiredCountQ* = 2
  IvoryWorldFileFirstSysoutQ* = 0
  IvoryWorldFileFirstMapQ* = 8


type
  SaveWorldEntry = object
    startAddress: VM_Address  # VMA of data (usually a region) to be saved
    wordCount: VM_Address # Number of words starting at this address to save

  # SaveWorldData = object
  #   pathnameString: string # Pathname of the world file (a DTP-STRING)


# A single load map entry -- See SYS:NETBOOT;WORLD-SUBSTRATE.LISP for details

type
  LoadMapEntry* = object
    loadAddress*: VM_Address  # VMA to be filled in by this load map entry
    count*: VM_Address # FIXME  = 24.VM_Address # Number of words to be filled in by this entry
    opcode*: uint # FIXME  = 8 # An LoadMapEntryOpcode specifying how to do so
    data*: VM_PageData        # FIXME # Interpretation is based on the opcode
    world*: ref World         # -> World from which this entry was obtained

  LoadMapEntryOpCode* = enum
    LoadMapDataPages          # Load data pages from the file
    LoadMapConstant           # Store a constant into memory
    LoadMapConstantIncremented # Store an auto-incrementing constant into memory
    LoadMapCopy # Copy an existing piece of memory 


# Description of an open world file
  World* = object
    pathname*: string         # -> Pathname of the world file
    fd*: File                 # Unix file descriptor if the world file is open
    format*: uint # FIXME # A LoadFileFormat indicating the type of file
    isByteSwapped*: bool      # World is byte swapped on this machine (VLM only)
    vlmDataPageBase*: VM_PageNumber # Block number of first page of data (VLM only)
    vlmTagsPageBase*: VM_PageNumber # Block number of first page of tags (VLM only)
    vlmDataPage*: VM_PageData # -> The data of the current VLM format page
    vlmTagPage*: VM_PageTag   # -> The tags of the current VLM format page
    ivoryDataPage*: array[IvoryPageSizeBytes, uint8] # -> The data of the current Ivory format page
    currentPageNumber*: VM_PageNumber # Page number of the page in the buffer, if any
    currentqAddress*: uint    # FIXME # Q number within the page to be read

    parentWorld*: ref World   # -> Parent of this world if it's an IDS
    sysoutGeneration*: uint # FIXME  # Generation number of this world (> 0 if IDS)
    sysoutTimestamp1*: uint64 # Unique ID of this world, part 1 ...
    sysoutTimestamp2*: uint64 # ... part 2
    sysoutParentTimestamp1*: uint64 # Unique ID of this world's parent, part 1 ...
    sysoutParentTimestamp2*: uint64 # ... part 2

    nWiredMapEntries*: LispQ
    wiredMapEntries*: seq[LoadMapEntry] # -> The wired load map entries

    nMergedWiredMapEntries*: LispQ
    mergedWiredMapEntries*: seq[LoadMapEntry] # ..

    nUnwiredMapEntries*: LispQ
    unwiredMapEntries*: seq[LoadMapEntry] # -> The unwired load map entries (Ivory only)

    nMergedUnwiredMapEntries*: LispQ
    mergedUnwiredMapEntries*: seq[LoadMapEntry] # ..



# Read 4 bytes from a particular location and swaps the bytes as appropriate
proc readAndSwap*(w: var World,
                  byteArray: var openArray[uint8], # array for bytes from which to read
                  address: uint32): LO_Data_Unsigned =
  var
    temp1, temp2: uint32
    returnValue: uint32
    i: uint32 = 0
    shiftSize: uint32 = 0

  for i in address.uint32 .. (address + dataSizeInBytes-1).uint32:
    if isLittleEndian:
      shiftSize = (i * 8).uint32
    else:
      shiftSize = ((dataSizeInBytes - i) * 8).uint32

    returnValue = returnValue + (byteArray[i.int].uint32) shl shiftSize

  log(consoleLog, lvlDebug, fmt"Value read at {address:#X} is {returnValue:#X}")

  return returnValue.LO_Data_Unsigned



# Read the specified page from the world file using Ivory file format settings
proc readIvoryWorldFilePage* (w: var World, pageNumber: VM_PageNumber): bool =

  if isNil(w.fd):
    log(consoleLog, lvlFatal,
        "Read Ivory File Page: No file descriptor in world definition")
    return false

  if (w.currentPageNumber == pageNumber):
    log(consoleLog, lvlInfo, fmt"Loading page {$pageNumber:#X} from world file: Page already loaded.")
    return true

  log(consoleLog, lvlDebug,
      "Read Ivory File Page. Current file position is:" & $getFilePos(w.fd))
  log(consoleLog, lvlDebug, "Read Ivory File Page. Seeking position:" &
      $(pageNumber * IvoryPageSizeBytes))
  setFilePos(w.fd, pageNumber * IvoryPageSizeBytes.int64, fspSet)
  if readBytes(w.fd, w.ivoryDataPage, 0,
      IvoryPageSizeBytes).uint32 < IvoryPageSizeBytes:
    log(consoleLog, lvlFatal, fmt"Loading page {$pageNumber:#X} from world file. Could not read enough bytes.")
    return false

  w.currentPageNumber = pageNumber
  return true



proc readIvoryWorldFileQ*(w: var World, qAddress: VM_Address,
                          q: var LispQ): bool =


  log(consoleLog, lvlDebug, fmt"readIvoryWorldFileQ. Reading at address {qAddress} for world file {w.pathname}")

  # Check the address to be loaded is within the size of the page
  if (qAddress < 0) or (qAddress >= IvoryPageSizeQs.uint32):
    log(consoleLog, lvlError,
        fmt"Invalid word number {qAddress} for world file {w.pathname}")
    return false

  #
  # The address of the Q object needs to be converted
  # 
  # Q Address (Addr) increase 4 by 4 (since uint32) - Tags are not included
  #
  #            N/A    Addr     Addr+1   Addr+2   Addr+3
  #          | TAG  | BYTE 0 | BYTE 1 | BYTE 2 | BYTE 3 |  
  #            extA   extA+1   extA+2   extA+3   extA+4
  #
  # Resulting extended address (extA) increase 5 by 5 and include tags.
  #
  const
    maskBits = 2
    lowMask = (2 ^ 2 - 1).uint32
    highMask = (2 ^ 32 - 1).uint32 - lowMask

  var
    # tagSizeInBytes + dataSizeInBytes = 1 + 4 = 5
    # extendedBaseAddress is in bytes not size of data Qs (normally 4 since uint32)
    extendedBaseAddress: uint32 = (qAddress shr maskBits) *
                                  (tagSizeInBytes + dataSizeInBytes)
    lowBits: uint32 = qAddress and lowMask

    # FIXME: The 'x 4' akes no sense to me for the moment given the layout a few lines above
    tagOffset = extendedBaseAddress + lowBits
    pointerOffset = extendedBaseAddress + lowBits + 1


    tag: LO_Tag
    datum: LO_Data_Unsigned

  log(consoleLog, lvlDebug, fmt"Extended address: {extendedBaseAddress:#X}")
  log(consoleLog, lvlDebug, fmt"Low bits: {lowBits:#X}")
  log(consoleLog, lvlDebug, fmt"Pointer offset: {pointerOffset:#X}")
  log(consoleLog, lvlDebug, fmt"Tag offset: {tagOffset:#X}")

  # NOTE FROM THE ORIGINAL C CODE: 
  # The following code that byte reverses the tags isn't needed. I've 
  #       left it here in case I discover later that I'm wrong
  #        so I don't have to derive the correct code again.
  #
  #  #if BYTE_ORDER == LITTLE_ENDIAN
  #  	tagOffset = 4 * 5 * (qAddress >> 2) + (qAddress & 3);
  #  #else
  #  	tagOffset = 4 * 5 * (qAddress >> 2) + 3 - (qAddress & 3);
  #  #endif

  tag = w.ivoryDataPage[tagOffset * dataSizeInBytes]
  datum = readAndSwap(w, w.ivoryDataPage, pointerOffset * dataSizeInBytes)
  q.tag = tag
  q.data.u = datum

  return true



# Returns true/false if everything is OK or not. If OK returns a valid world structure
proc openWorldFile* (path: string): (bool, World) =
  var
    wFile: File
    w: World
    isOK: bool
    fileResult: int
    pageBases: LO_Content
    magicNumber: array[4, uint8]
    q: LispQ

  # Open the world file
  w.pathname = path
  log(consoleLog, lvlInfo, fmt"Opening world file {path}")
  if open(wFile, w.pathname) == false:
    log(consoleLog, lvlFatal, "Error opening the world file")
    return (false, w)
  w.fd = wFile
  log(consoleLog, lvlDebug,
      fmt"openWorldFile. Current file size is: {getFileSize(w.fd):#X} eq. to {getFileSize(w.fd)} bytes")
  log(consoleLog, lvlDebug,
      fmt"openWorldFile. Current file position is: {getFilePos(w.fd):#X} eq. to {getFilePos(w.fd)}")


  # Check the magic number and corresponding endianness
  log(consoleLog, lvlInfo, "Reading magic number")
  if readBytes(wFile, magicNumber, 0, 4) < 4:
    log(consoleLog, lvlFatal, "Magic number: read less than 4 bytes")
    return (false, w)

  if magicNumber == VLMWorldFileMagic:
    isLittleEndian = false
    log(consoleLog, lvlInfo,
        fmt"Magic number {magicNumber[0]:#X} {magicNumber[1]:#X} {magicNumber[2]:#X} {magicNumber[3]:#X} is big-endian.")
  elif magicNumber == VLMWorldFileMagicSwapped:
    isLittleEndian = true
    log(consoleLog, lvlInfo,
        fmt"Magic number {magicNumber[0]:#X} {magicNumber[1]:#X} {magicNumber[2]:#X} {magicNumber[3]:#X} is little-endian (swapped).")
  else:
    log(consoleLog, lvlFatal, "Magic number is not recognised.")
    return (false, w)

  # The header and load maps for both VLM and Ivory world files are stored using Ivory file format settings 
  # (i.e., 56 s per 1280 byte page)
  log(consoleLog, lvlInfo, "Loading page 0.")
  w.currentPageNumber = -1
  if not(readIvoryWorldFilePage(w, 0.VM_PageNumber)):
    log(consoleLog, lvlFatal, "Page 0 not loaded.")
    return(false, w)


  # Check VLM version
  log(consoleLog, lvlInfo, "Loading the version and architecture numbers.")
  if not(readIvoryWorldFileQ(w, VersionAndArchitectureQ.VM_Address, q)):
    log(consoleLog, lvlFatal, "Cannot read version and architecture numbers.")
    return(false, w)
  log(consoleLog, lvlInfo, fmt"Version is: {q.data.u:#X}")

  var
    wiredCountQ, unwiredCountQ, pagesBaseQ, firstSysoutQ, firstMapQ: uint32

  case q.data.u:
  of VLMVersion1AndArchitecture:
    wiredCountQ = VLMWorldFileV1WiredCountQ;
    unwiredCountQ = VLMWorldFileV1UnwiredCountQ;
    pagesBaseQ = VLMWorldFileV1PageBasesQ;
    firstSysoutQ = VLMWorldFileV1FirstSysoutQ;
    firstMapQ = VLMWorldFileV1FirstMapQ;

  of VLMVersion2AndArchitecture:
    wiredCountQ = VLMWorldFileV2WiredCountQ;
    unwiredCountQ = VLMWorldFileV2UnwiredCountQ;
    pagesBaseQ = VLMWorldFileV2PageBasesQ;
    firstSysoutQ = VLMWorldFileV2FirstSysoutQ;
    firstMapQ = VLMWorldFileV2FirstMapQ;

  else:
    log(consoleLog, lvlFatal, "Unknown version and architecture numbers.")
    return(false, w)


  if not(readIvoryWorldFileQ(w, wiredCountQ.VM_Address, q)):
    log(consoleLog, lvlFatal, "Cannot read wiredCountQ.")
    return(false, w)
  w.nWiredMapEntries = q

  # NOTE: No memory allocation of nWiredMapEntries since defined as a sequence
  # NOTE: No memoty allocation of nUnwiredMapEntries since unwiredCountQ is defined as 0

  if not(readIvoryWorldFileQ(w, pagesBaseQ.VM_Address, q)):
    log(consoleLog, lvlFatal, "Cannot read Page Base")
  pageBases = data(q)
  log(consoleLog, lvlInfo, fmt"Page Base = {pageBases.u:#X}")



  return (true, w)

