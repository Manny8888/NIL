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
  VLMBlocksPerDataPage* = dataSizeInBytes
  VLMBlocksPerTagsPage* = tagSizeInBytes
  VLMMaximumHeaderBlocks* = 14
  VLMDataPageSizeBytes* = 4 * VLMPageSizeQs
  VLMTagsPageSizeBytes* = VLMPageSizeQs

  VLMVersion1AndArchitecture*: LO_Data_Unsigned = 0x800080.LO_Data_Unsigned # 0o40000200
  VLMWorldFileV1WiredCountQ*: QAddress = 1.QAddress
  VLMWorldFileV1UnwiredCountQ*: uint32 = 0
  VLMWorldFileV1PageBasesQ*: QAddress = 3.QAddress
  VLMWorldFileV1FirstSysoutQ*: QAddress = 0.QAddress
  VLMWorldFileV1FirstMapQ*: uint32 = 8

  VLMVersion2AndArchitecture*: LO_Data_Unsigned = 0x800081.LO_Data_Unsigned # 0o40000200
  VLMWorldFileV2WiredCountQ*: QAddress = 1.QAddress
  VLMWorldFileV2UnwiredCountQ*: uint32 = 0
  VLMWorldFileV2PageBasesQ*: QAddress = 2.QAddress
  VLMWorldFileV2FirstSysoutQ*: QAddress = 3.QAddress
  VLMWorldFileV2FirstMapQ*: uint32 = 8

  # A page is 256 Q values stored on file as 256 uint32, 256 tags (as bytes)
  IvoryPageSizeQs*: QAddress = 256.QAddress
  IvoryPageSizeBytes*: uint32 = IvoryPageSizeQs.uint32 *
                                (dataSizeInBytes+tagSizeInBytes).uint32
  IvoryWorldFileWiredCountQ* = 1
  IvoryWorldFileUnwiredCountQ* = 2
  IvoryWorldFileFirstSysoutQ* = 0
  IvoryWorldFileFirstMapQ* = 8


type
  SaveWorldEntry = object
    startAddress: QAddress    # VMA of data (usually a region) to be saved
    wordCount: QAddress # Number of words starting at this address to save

  # SaveWorldData = object
  #   pathnameString: string # Pathname of the world file (a DTP-STRING)


# A single load map entry -- See SYS:NETBOOT;WORLD-SUBSTRATE.LISP for details

type
  LoadMapEntry* = object
    loadAddress*: QAddress # FIXME: Not Sure about the type # VMA to be filled in by this load map entry
    count*: QAddress # FIXME  = 24.VM_Address # Number of words to be filled in by this entry
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
    currentQAddress*: QAddress # Address of the Q within the current page to be read

    parentWorld*: ref World   # -> Parent of this world if it's an IDS
    sysoutGeneration*: LO_Data_Unsigned # Generation number of this world (> 0 if IDS)
    sysoutTimestamp1*: LO_Data_Unsigned # Unique ID of this world, part 1 ...
    sysoutTimestamp2*: LO_Data_Unsigned # ... part 2
    sysoutParentTimestamp1*: LO_Data_Unsigned # Unique ID of this world's parent, part 1 ...
    sysoutParentTimestamp2*: LO_Data_Unsigned # ... part 2

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
    returnValue: uint32
    i: uint32 = 0
    shiftSize: uint32 = 0

  for i in address.uint32 .. (address + dataSizeInBytes-1).uint32:
    if isLittleEndian:
      shiftSize = (i * 8).uint32
    else:
      shiftSize = ((dataSizeInBytes - i) * 8).uint32

    returnValue = returnValue + (byteArray[i.int].uint32) shl shiftSize

  log(consoleLog, lvlDebug, fmt"{dataSizeInBytes}-byte value read from byte {address:#X} is {returnValue:#X}")

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


# WARNING: Here, the caller provides a location to store the Q that will be read. 
# The C code allocates a new Q within this function and returns a pointer to it.
proc readIvoryWorldFileQ*(w: var World, qAddress: QAddress,
                          q: var LispQ): bool =

  log(consoleLog, lvlDebug, fmt"readIvoryWorldFileQ. Reading at Q address {qAddress}")

  # Check the address to be loaded is within the size of the page
  if (qAddress < 0) or (qAddress >= IvoryPageSizeQs): # The negative test should not be neede, but who knows...
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
    # addressInBytes is in bytes not size of data Qs (normally 4 since uint32) - The C code uses pointer arithmetic instead

    lowbits = qAddress and lowMask
    addressInBytes: uint32 = (qAddress and highMask) *
                             (tagSizeInBytes + dataSizeInBytes) +
                             lowBits

    # FIXME: The original C code 'x 4' makes no sense to me for the moment given the layout a few lines above
    # However, pointerOffset is manipulated with pointer arithmetic where it is 4-byte long. That's the likely 
    # explanation. But then again...
    tagBytesOffset = addressInBytes * dataSizeInBytes
    pointerBytesOffset = (addressInBytes + 1) * dataSizeInBytes


    tag: LO_Tag
    datum: LO_Data_Unsigned

  log(consoleLog, lvlDebug, fmt"Byte address: {addressInBytes:#X} --- Low bits: {lowBits:#X} --- Tag offset: {tagBytesOffset:#X} --- Pointer offset: {pointerBytesOffset:#X}")

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

  tag = w.ivoryDataPage[tagBytesOffset]
  datum = readAndSwap(w, w.ivoryDataPage, pointerBytesOffset)
  q.tag = tag
  q.data.u = datum

  return true


# Read the next Q from within the world file, advancing to the next page if needed, using Ivory file format settings
proc readIvoryWorldFileNextQ(w: var World, q: var LispQ): bool =

  log(consoleLog, lvlInfo, fmt"Reading next Q at address {w.currentQAddress}")
  if w.currentQAddress >= IvoryPageSizeQs:
    log(consoleLog, lvlInfo, fmt"Q address is beyond current page. Loading next page with number {w.currentPageNumber + 1}")
    w.currentPageNumber = w.currentPageNumber + 1
    w.currentQAddress = w.currentQAddress - IvoryPageSizeQs
    var isOK = readIvoryWorldFilePage(w, w.currentPageNumber)
    if not(isOK):
      log(consoleLog, lvlFatal, fmt"Failed to read next page.")
      return false

  var isOK = readIvoryWorldFileQ(w, w.currentQAddress, q)
  if not(isOK):
    log(consoleLog, lvlFatal, fmt"Could not read Q at address {w.currentQAddress}")

  w.currentQAddress = w.currentQAddress + 1.QAddress
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
  if not(readIvoryWorldFileQ(w, VersionAndArchitectureQ.QAddress, q)):
    log(consoleLog, lvlFatal, "Cannot read version and architecture numbers.")
    return(false, w)
  log(consoleLog, lvlInfo, fmt"Version is: {q.data.u:#X}")

  var
    unwiredCountQ, firstMapQ: uint32
    wiredCountQ, pagesBaseQ, firstSysoutQ: QAddress

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


  if not(readIvoryWorldFileQ(w, wiredCountQ, q)):
    log(consoleLog, lvlFatal, "Cannot read wiredCountQ.")
    return(false, w)
  w.nWiredMapEntries = q

  # NOTE: No memory allocation of nWiredMapEntries since defined as a sequence
  # NOTE: No memoty allocation of nUnwiredMapEntries since unwiredCountQ is defined as 0

  if not(readIvoryWorldFileQ(w, pagesBaseQ, q)):
    log(consoleLog, lvlFatal, "Cannot read Page Base")
  pageBases = data(q)
  log(consoleLog, lvlInfo, fmt"Page Base = {pageBases.u:#X}")

  w.vlmDataPageBase = (pageBases.u.uint32 and
      dataSizeMask.uint32).VM_PageNumber
  w.vlmTagsPageBase = ((pageBases.u.uint32 and
      tagSizeMask) shr dataSizeInBits).VM_PageNumber

  log(consoleLog, lvlInfo, fmt"Page Base data value = {w.vlmDataPageBase:#X}")
  log(consoleLog, lvlInfo, fmt"Page Base tag value = {w.vlmTagsPageBase:#X}")


  if firstSysoutQ==0:
    w.sysoutGeneration = 0.LO_Data_Unsigned
    w.sysoutTimestamp1 = 0.LO_Data_Unsigned
    w.sysoutTimestamp2 = 0.LO_Data_Unsigned
    w.sysoutParentTimestamp1 = 0.LO_Data_Unsigned
    w.sysoutParentTimestamp2 = 0.LO_Data_Unsigned
  else:
    w.currentQAddress = firstSysoutQ

    log(consoleLog, lvlInfo, fmt"Reading sysOutGeneration at address {w.currentQAddress}")
    if not(readIvoryWorldFileNextQ(w, q)):
      log(consoleLog, lvlFatal, fmt"Could not read sysOutGeneration.")

    log(consoleLog, lvlInfo, fmt"Reading sysOutGeneration at address {w.currentQAddress}")
    if not(readIvoryWorldFileNextQ(w, q)):
      log(consoleLog, lvlFatal, fmt"Could not read sysOutGeneration.")
    w.sysoutGeneration = q.data.u

    log(consoleLog, lvlInfo, fmt"Reading sysOutTimeStamp1 at address {w.currentQAddress}")
    if not(readIvoryWorldFileNextQ(w, q)):
      log(consoleLog, lvlFatal, fmt"Could not read sysOutTimeStamp1.")
    w.sysoutTimestamp1 = q.data.u

    log(consoleLog, lvlInfo, fmt"Reading sysOutTimeStamp2 at address {w.currentQAddress}")
    if not(readIvoryWorldFileNextQ(w, q)):
      log(consoleLog, lvlFatal, fmt"Could not read sysOutTimeStamp2.")
    w.sysoutTimestamp2 = q.data.u

    log(consoleLog, lvlInfo, fmt"Reading sysOutParentTimeStamp1 at address {w.currentQAddress}")
    if not(readIvoryWorldFileNextQ(w, q)):
      log(consoleLog, lvlFatal, fmt"Could not read sysOutParentTimeStamp1.")
    w.sysoutParentTimestamp1 = q.data.u

    log(consoleLog, lvlInfo, fmt"Reading sysOutParentTimeStamp2 at address {w.currentQAddress}")
    if not(readIvoryWorldFileNextQ(w, q)):
      log(consoleLog, lvlFatal, fmt"Could not read sysOutParentTimeStamp2.")
    w.sysoutParentTimestamp2 = q.data.u






  return (true, w)

