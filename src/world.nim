

import logging, strformat

import memory, types, globalstate, world_types

# Read 4 bytes from a particular location and swaps the bytes as appropriate
proc readAndSwap*(w: var World, byteArray: var openArray[uint8],
  address: uint64): QData =
  var
    returnValue: uint64
    i: uint64 = 0
    shiftSize: int = 0

  if isLittleEndian:
    shiftSize = 0.int
  else:
    shiftSize = ((DataSizeInBytes - 1) * 8).int

  for i in address .. (address + DataSizeInBytes-1).uint64:
    returnValue = returnValue + (byteArray[i.int].uint64) shl shiftSize

    if isLittleEndian:
      shiftSize = shiftSize + 8
    else:
      shiftSize = shiftSize - 8

  log(ivoryPageReadLog, lvlInfo, fmt"{DataSizeInBytes}- byte value read from address (in byte) {address:#X} is {returnValue:#X}")

  return returnValue.QData



# Read the specified page from the world file using Ivory file format settings
proc readIvoryWorldFilePage* (w: var World, pageNumber: VM_PageNumber): bool =

  if isNil(w.fd):
    log(ivoryPageReadLog, lvlFatal,
      "Read Ivory File Page: No file descriptor in world definition")
    return false

  if (w.currentPageNumber == pageNumber):
    log(ivoryPageReadLog, lvlInfo, fmt"Loading page {pageNumber:#X} from world file: Page already loaded.")
    return true

  log(ivoryPageReadLog, lvlDebug, fmt"Read Ivory File Page. Current file position is: {getFilePos(w.fd)}")
  log(ivoryPageReadLog, lvlDebug, fmt"Read Ivory File Page. Seeking position: {(pageNumber * IvoryPageSizeBytes):#X}")

  # The starting position of pages are shifted by 4 being the magic number 4 bytes at the beginning of the file.
  setFilePos(w.fd, pageNumber * IvoryPageSizeBytes.int64 + 4, fspSet)
  if readBytes(w.fd, w.ivoryDataPage, 0,
    IvoryPageSizeBytes).uint32 < IvoryPageSizeBytes:
    log(ivoryPageReadLog, lvlFatal, fmt"Loading page {pageNumber:#X} from world file. Could not read enough bytes.")
    return false

  w.currentPageNumber = pageNumber
  return true


# WARNING: Here, the caller provides a location to store the Q that will be read. 
# The C code allocates a new Q within this function and returns a pointer to it.
proc readIvoryWorldFileQ*(w: var World, address: QAddress,
                          q: var LispQ): bool =

  log(ivoryPageReadLog, lvlInfo, fmt"readIvoryWorldFileQ. Attempting read at Q address {address}")

  # Check the address to be loaded is within the size of the page
  if (address < 0) or (address >= IvoryPageSizeQs): # The negative test should not be neede, but who knows...
    log(ivoryPageReadLog, lvlFatal,
      fmt"Invalid word number {address} for world file {w.pathname}")
    return false

  #
  # The address of the Q object needs to be converted to bytes.
  #
  # In the load file the formats is done by groups of 4 Q values. 
  # Each Q value requires 5 bytes: 4 for the data, 1 for the tag.
  # Lets call Q1 .. Q4 the values, D1..D4 and T1..T4 the corresponding data and tags.
  #
  # They are stored as:
  #     D1, D2, D3, D4,   T1, T2, T3, T4
  #     <- 16 bytes ->    <-  4 bytes ->
  # 
  # After those 20 bytes, another group of 4 Q values is stored.
  #
  # Of course, each D is stored little/big endian depending on the initial file magic number
  #

  const
    # Each quad is 20 bytes = 5 * 4 
    #                       = (4 + 1) * 4
    #                       = (DataSizeInBytes + TagSizeInBytes)+ DataSizeInBytes
    QuadSizeInBytes = (DataSizeInBytes + TagSizeInBytes) * DataSizeInBytes

  var
    # for a given address, quad is the group of 4 Q values to which it belongs (starting from 0)
    quad: uint64 = address div 4

    # for a given address, quadPosition is the position of the Q value within the group of 4 (starting from 0)
    quadPosition: uint64 = address mod 4

    pointerBytesOffset: uint64
    tagBytesOffset: uint64


  pointerBytesOffset = quad * QuadSizeInBytes + quadPosition *
      DataSizeInBytes
  tagBytesOffset = quad * QuadSizeInBytes + DataSizeInBytes * 4 +
      quadPosition


  log(ivoryPageReadLog, lvlInfo,
    fmt"Reading address {address:#X} - quad: {quad:#X} position in quad {quadPosition:#X}" &
    fmt" --- Tag offset: {tagBytesOffset:#X} --- Pointer offset: {pointerBytesOffset:#X}")

  q.tag = w.ivoryDataPage[tagBytesOffset.uint32].QTag
  q.data = readAndSwap(w, w.ivoryDataPage, pointerBytesOffset)

  return true


# Read the next Q from within the world file, advancing to the next page if needed, using Ivory file format settings
proc readIvoryWorldFileNextQ(w: var World, q: var LispQ): bool =

  log(ivoryPageReadLog, lvlInfo, fmt"Reading next Q at address {w.currentQAddress}")

  # Checking if the address is in the current page
  if w.currentQAddress >= IvoryPageSizeQs:

    # If above page size, increase the page number ...
    w.currentPageNumber = w.currentPageNumber + 1
    log(ivoryPageReadLog, lvlInfo, fmt"Q address is beyond current page. Loading next page with number {w.currentPageNumber}")

    # ... loads it ...
    var isOK = readIvoryWorldFilePage(w, w.currentPageNumber)
    if not(isOK):
      log(ivoryPageReadLog, lvlFatal, fmt"Failed to read next page.")
      return false

    # ... and resets the index within the page.
    w.currentQAddress = w.currentQAddress - IvoryPageSizeQs


  var isOK = readIvoryWorldFileQ(w, w.currentQAddress, q)
  if not(isOK):
    log(ivoryPageReadLog, lvlFatal, fmt"Could not read Q at address {w.currentQAddress}")

  w.currentQAddress = w.currentQAddress + 1.QAddress
  return true



# Read a load map from the world load file
proc readLoadMap(w: var World, nMapEntries: uint32, mapEntries: var seq[
    LoadMapEntry]): bool =
  var
    q: LispQ
    i: int
    isOK: bool

  if i==0:
    return true

  for i in 0..<nMapEntries:
    log(runLog, lvlInfo, fmt"")
    log(runLog, lvlInfo, fmt"readLoadMap: Map Entry # {i+1} of {nMapEntries}")
    log(runLog, lvlInfo, fmt"readLoadMap: reading address {w.currentQAddress}")

    isOK = readIvoryWorldFileNextQ(w, q)
    # mapEntries[i].loadAddress = q.data.QAddress
    log(runLog, lvlInfo, fmt"readLoadMap: Map Entry # {i+1} -- Load address: {q}")

    isOK = readIvoryWorldFileNextQ(w, q)
    # mapEntries[i].op = q.data.QAddress
    log(runLog, lvlInfo, fmt"readLoadMap: Map Entry # {i+1} -- opcode and count: {q}")

    isOK = readIvoryWorldFileNextQ(w, q)
    # mapEntries[i].data = q
    log(runLog, lvlInfo, fmt"readLoadMap: Map Entry # {i+1} -- data: {q}")

  return true


# Returns true/false if everything is OK or not. If OK returns a valid world structure
proc openWorldFile* (path: string): (bool, World) =
  var
    wFile: File
    w: World
    isOK: bool
    fileResult: int
    pageBases: QData
    magicNumber: array[4, uint8]
    q: LispQ

  # Open the world file
  w.pathname = path
  log(runLog, lvlInfo, fmt"Opening world file {path}")
  if open(wFile, w.pathname) == false:
    log(runLog, lvlFatal, "Error opening the world file")
    return (false, w)

  w.fd = wFile
  log(runLog, lvlInfo,
    fmt"openWorldFile. Current file size is: {getFileSize(w.fd):#X} eq. to {getFileSize(w.fd)} bytes")
  log(runLog, lvlInfo,
    fmt"openWorldFile. Current file position is: {getFilePos(w.fd):#X} eq. to {getFilePos(w.fd)}")


  # Check the magic number and corresponding endianness
  log(runLog, lvlInfo, "Reading magic number")
  if readBytes(wFile, magicNumber, 0, 4) < 4:
    log(runLog, lvlFatal, "Magic number: read less than 4 bytes")
    return (false, w)

  if magicNumber == VLMWorldFileMagic:
    isLittleEndian = false
    log(runLog, lvlInfo,
    fmt"Magic number {magicNumber[0]:#X} {magicNumber[1]:#X} {magicNumber[2]:#X} {magicNumber[3]:#X} is big-endian.")
  elif magicNumber == VLMWorldFileMagicSwapped:
    isLittleEndian = true
    log(runLog, lvlInfo,
    fmt"Magic number {magicNumber[0]:#X} {magicNumber[1]:#X} {magicNumber[2]:#X} {magicNumber[3]:#X} is little-endian (swapped).")
  else:
    log(runLog, lvlFatal, "Magic number is not recognised.")
    return (false, w)

  # The header and load maps for both VLM and Ivory world files are stored using Ivory file format settings 
  # (i.e., 56 s per 1280 byte page)
  log(runLog, lvlInfo, "Loading page 0.")
  w.currentPageNumber = -1
  if not(readIvoryWorldFilePage(w, 0.VM_PageNumber)):
    log(runLog, lvlFatal, "Page 0 not loaded.")
    return(false, w)


  # Check VLM version
  log(runLog, lvlInfo, "Loading the version and architecture numbers.")
  if not(readIvoryWorldFileQ(w, VersionAndArchitectureQ.QAddress, q)):
    log(runLog, lvlFatal, "Cannot read version and architecture numbers.")
    return(false, w)
  log(runLog, lvlInfo, fmt"Version is: {q.data:#X}")

  var
    unwiredCountQ: uint32
    firstMapQ, wiredCountQ, pagesBaseQ, firstSysoutQ: QAddress

  case q.data:
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
    log(runLog, lvlFatal, "Unknown version and architecture numbers.")
    return(false, w)


  if not(readIvoryWorldFileQ(w, wiredCountQ, q)):
    log(runLog, lvlFatal, "Cannot read wiredCountQ.")
    return(false, w)
  w.nWiredMapEntries = q

  # NOTE: No memory allocation of nWiredMapEntries since defined as a sequence
  # NOTE: No memoty allocation of nUnwiredMapEntries since unwiredCountQ is defined as 0

  if not(readIvoryWorldFileQ(w, pagesBaseQ, q)):
    log(runLog, lvlFatal, "Cannot read Page Base")
  pageBases = data(q)
  log(runLog, lvlInfo, fmt"Page Base = {pageBases:#X}")

  w.vlmDataPageBase = (pageBases.uint64 and
      DataSizeMask.uint64).VM_PageNumber
  w.vlmTagsPageBase = ((pageBases.uint64 and
      TagSizeMask.uint64) shr DataSizeInBits).VM_PageNumber

  log(runLog, lvlInfo, fmt"Page Base data value = {w.vlmDataPageBase:#X}")
  log(runLog, lvlInfo, fmt"Page Base tag value = {w.vlmTagsPageBase:#X}")


  if firstSysoutQ==0:
    w.sysoutGeneration = 0.QData
    w.sysoutTimestamp1 = 0.QData
    w.sysoutTimestamp2 = 0.QData
    w.sysoutParentTimestamp1 = 0.QData
    w.sysoutParentTimestamp2 = 0.QData
  else:
    w.currentQAddress = firstSysoutQ

  log(runLog, lvlInfo, fmt"Reading sysOutGeneration at address {w.currentQAddress}")
  if not(readIvoryWorldFileNextQ(w, q)):
    log(runLog, lvlFatal, fmt"Could not read sysOutGeneration.")
  w.sysoutGeneration = q.data
  log(runLog, lvlInfo, fmt"value read = {q}")


  log(runLog, lvlInfo, fmt"Reading sysOutTimeStamp1 at address {w.currentQAddress}")
  if not(readIvoryWorldFileNextQ(w, q)):
    log(runLog, lvlFatal, fmt"Could not read sysOutTimeStamp1.")
  w.sysoutTimestamp1 = q.data
  log(runLog, lvlInfo, fmt"value read = {q}")

  log(runLog, lvlInfo, fmt"Reading sysOutTimeStamp2 at address {w.currentQAddress}")
  if not(readIvoryWorldFileNextQ(w, q)):
    log(runLog, lvlFatal, fmt"Could not read sysOutTimeStamp2.")
  w.sysoutTimestamp2 = q.data
  log(runLog, lvlInfo, fmt"value read = {q}")

  log(runLog, lvlInfo, fmt"Reading sysOutParentTimeStamp1 at address {w.currentQAddress}")
  if not(readIvoryWorldFileNextQ(w, q)):
    log(runLog, lvlFatal, fmt"Could not read sysOutParentTimeStamp1.")
  w.sysoutParentTimestamp1 = q.data
  log(runLog, lvlInfo, fmt"value read = {q}")

  log(runLog, lvlInfo, fmt"Reading sysOutParentTimeStamp2 at address {w.currentQAddress}")
  if not(readIvoryWorldFileNextQ(w, q)):
    log(runLog, lvlFatal, fmt"Could not read sysOutParentTimeStamp2.")
  log(runLog, lvlInfo, fmt"value read = {q}")


  w.currentQAddress = firstMapQ
  if w.nWiredMapEntries.data==0:
    log(runLog, lvlInfo, fmt"Starting readLoadMap for Wired Map Entries --- 0 entries.")
  else:
    log(runLog, lvlInfo, fmt"Starting readLoadMap for Wired Map Entries --- {w.nWiredMapEntries.data} entries.")
    isOK = readLoadMap(w, w.nWiredMapEntries.data, w.wiredMapEntries)
    if (isOK):
      log(runLog, lvlInfo, fmt"Read OK.")

  if w.nUnwiredMapEntries.data==0:
    log(runLog, lvlInfo, fmt"Starting readLoadMap for Unwired Map Entries --- 0 entries.")
  else:
    log(runLog, lvlInfo, fmt"Starting readLoadMap for Unwired Map Entries --- {w.nUnwiredMapEntries.data} entries..")
    isOK = readLoadMap(w, w.nUnwiredMapEntries.data, w.unwiredMapEntries)
    if (isOK):
      log(runLog, lvlInfo, fmt"Read OK.")


  return (true, w)


proc mergeLoadMaps* =

  if currentWorld.sysoutGeneration == 0:
    originalWorld = currentWorld
    #FindParentWorlds(world, worldSearchPath)
    #MergeParentLoadMap(world)
  else:
    currentWorld.nMergedWiredMapEntries = currentWorld.nWiredMapEntries
    currentWorld.mergedWiredMapEntries = currentWorld.wiredMapEntries
    currentWorld.nMergedUnwiredMapEntries = currentWorld.nUnwiredMapEntries
    currentWorld.mergedUnwiredMapEntries = currentWorld.unwiredMapEntries

  discard

proc LoadWorld* () =
  var
    isOK: bool

  (isOK, currentWorld) = openWorldFile(WorldFileName)
  mergeLoadMaps()


  var
    worldImageSize: uint64 = 0
    i: uint64

  for i in 0..<currentWorld.nMergedWiredMapEntries.data:
    worldImageSize += VLMLoadMapData(currentWorld,
        currentWorld.mergedWiredMapEntries[i])

  for i in 0..<currentWorld.nMergedUnwiredMapEntries.data:
    worldImageSize += VLMLoadMapData(currentWorld,
        currentWorld.mergedUnwiredMapEntries[i])


    # for (i = 0; i < world.nMergedWiredMapEntries; i++) {
    #     worldImageSize += LoadMapData(&world, &world.mergedWiredMapEntries[i]);
    # }
    # for (i = 0; i < world.nMergedUnwiredMapEntries; i++) {
    #     worldImageSize += LoadMapData(&world, &world.mergedUnwiredMapEntries[i]);
    # }
    # CloseWorldFile(&world, TRUE);



  # Just in case...
  flushFile(stdout)

  discard


