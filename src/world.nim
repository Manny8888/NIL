####################################################################################################################
##
# Manipulation of WORLD file
##
####################################################################################################################


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

  VLMVersion1AndArchitecture* = 0o40000200
  VLMWorldFileV1WiredCountQ* = 1
  VLMWorldFileV1UnwiredCountQ* = 0
  VLMWorldFileV1PageBasesQ* = 3
  VLMWorldFileV1FirstSysoutQ* = 0
  VLMWorldFileV1FirstMapQ* = 8

  VLMVersion2AndArchitecture* = 0o40000201
  VLMWorldFileV2WiredCountQ* = 1
  VLMWorldFileV2UnwiredCountQ* = 0
  VLMWorldFileV2PageBasesQ* = 2
  VLMWorldFileV2FirstSysoutQ* = 3
  VLMWorldFileV2FirstMapQ* = 8

  IvoryPageSizeBytes* = 1280
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


var
  isLittleEndian*: bool = true

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
    currentQNumber*: uint     # FIXME # Q number within the page to be read

    parentWorld*: ref World   # -> Parent of this world if it's an IDS
    sysoutGeneration*: uint # FIXME  # Generation number of this world (> 0 if IDS)
    sysoutTimestamp1*: uint64 # Unique ID of this world, part 1 ...
    sysoutTimestamp2*: uint64 # ... part 2
    sysoutParentTimestamp1*: uint64 # Unique ID of this world's parent, part 1 ...
    sysoutParentTimestamp2*: uint64 # ... part 2

    nWiredMapEntries*: uint   # FIXME # Number of wired load map entries
    wiredMapEntries*: seq[LoadMapEntry] # -> The wired load map entries

    nMergedWiredMapEntries*: uint # As above but after merging with parent worlds
    mergedWiredMapEntries*: seq[LoadMapEntry] # ..

    nUnwiredMapEntries*: uint # FIXME # Number of unwired load map entries (Ivory only)
    unwiredMapEntries*: seq[LoadMapEntry] # -> The unwired load map entries (Ivory only)

    nMergedUnwiredMapEntries*: uint # FIXME # As above but after merging with parent worlds
    mergedUnwiredMapEntries*: seq[LoadMapEntry] # ..


# Read the specified page from the world file using Ivory file format settings
proc readIvoryWorldFilePage* (w: var World, pageNumber: VM_PageNumber): bool =

  if isNil(w.fd):
    log(consoleLog, lvlFatal,
        "Read Ivory File Page: No file descriptor in world definition")
    return false

  if (w.currentPageNumber == pageNumber):
    log(consoleLog, lvlInfo, "Loading page " & $pageNumber &
        " from world file: Page already loaded.")
    return true

  setFilePos(w.fd, (pageNumber * IvoryPageSizeBytes - 1), fspSet)
  if readBytes(w.fd, w.ivoryDataPage, 0,
      IvoryPageSizeBytes) < IvoryPageSizeBytes:
    echo "Loading page " & $pageNumber &
        " from world file: Error - could not read enough bytes."
    return false

  w.currentPageNumber = pageNumber
  return true


# Returns true/false if everything is OK or not.
# If OK returns a valid world structure
proc openWorldFile* (path: string): (bool, World) =
  var
    wFile: File
    w: World
    isOK: bool
    fileResult: int
    magicNumber: array[4, uint8]

  # Open the world file
  w.pathname = path
  log(consoleLog, lvlInfo, "Opening world file " & path)
  if open(wFile, w.pathname) == false:
    log(consoleLog, lvlFatal, "Error opening the world file")
    return (false, w)
  w.fd = wFile


  # Check the magic number and corresponding endianness
  log(consoleLog, lvlInfo, "Reading magic number")
  if readBytes(wFile, magicNumber, 0, 4) < 4:
    log(consoleLog, lvlFatal, "Magic number: read less than 4 bytes")
    return (false, w)

  if magicNumber == VLMWorldFileMagic:
    isLittleEndian = false
    log(consoleLog, lvlInfo, "Magic number " & $magicNumber &
        " is big-endian.")
  elif magicNumber == VLMWorldFileMagicSwapped:
    isLittleEndian = true
    log(consoleLog, lvlInfo, "Magic number " & $magicNumber &
        " is little-endian (swapped).")
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

  return (true, w)

