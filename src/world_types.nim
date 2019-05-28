####################################################################################################################
##
# Types associated with Worlds
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
  VLMBlocksPerDataPage* = DataSizeInBytes
  VLMBlocksPerTagsPage* = TagSizeInBytes
  VLMMaximumHeaderBlocks* = 14
  VLMDataPageSizeBytes* = 4 * VLMPageSizeQs
  VLMTagsPageSizeBytes* = VLMPageSizeQs

  VLMVersion1AndArchitecture*: QData = 0x800080.QData # 0o40000200
  VLMWorldFileV1WiredCountQ*: QAddress = 1.QAddress
  VLMWorldFileV1UnwiredCountQ*: uint32 = 0
  VLMWorldFileV1PageBasesQ*: QAddress = 3.QAddress
  VLMWorldFileV1FirstSysoutQ*: QAddress = 0.QAddress
  VLMWorldFileV1FirstMapQ*: QAddress = 8.QAddress

  VLMVersion2AndArchitecture*: QData = 0x800081.QData # 0o40000200
  VLMWorldFileV2WiredCountQ*: QAddress = 1.QAddress
  VLMWorldFileV2UnwiredCountQ*: uint32 = 0
  VLMWorldFileV2PageBasesQ*: QAddress = 2.QAddress
  VLMWorldFileV2FirstSysoutQ*: QAddress = 3.QAddress
  VLMWorldFileV2FirstMapQ*: QAddress = 8.QAddress

  # A page is 256 Q values stored on file as 256 uint32, 256 tags (as bytes)
  IvoryPageSizeQs*: QAddress = 256.QAddress
  IvoryPageSizeBytes*: uint32 = IvoryPageSizeQs.uint32 *
                                (DataSizeInBytes+TagSizeInBytes).uint32
  IvoryWorldFileWiredCountQ* = 1
  IvoryWorldFileUnwiredCountQ* = 2
  IvoryWorldFileFirstSysoutQ* = 0
  IvoryWorldFileFirstMapQ* = 8


type
  SaveWorldEntry* = object
    startAddress: QAddress    # VMA of data (usually a region) to be saved
    wordCount: QAddress # Number of words starting at this address to save

  # SaveWorldData = object
  #   pathnameString: string # Pathname of the world file (a DTP-STRING)


  # A single load map entry -- See SYS:NETBOOT;WORLD-SUBSTRATE.LISP for details
  LoadMapEntryOpCode* = enum
    LoadMapDataPages          # Load data pages from the file
    LoadMapConstant           # Store a constant into memory
    LoadMapConstantIncremented # Store an auto-incrementing constant into memory
    LoadMapCopy               # Copy an existing piece of memory

  LoadMapEntry* = object
    loadAddress*: QAddress    # VMA to be filled in by this load map entry
    count*: QAddress # Number of words to be filled in by this entry. Specified as a 24-bit field originally
    opcode*: LoadMapEntryOpCode # An LoadMapEntryOpcode specifying how to do so. Specified as an 8-bit field originally
    data*: LispQ              # FIXME # Interpretation is based on the opcode
    world*: ref World # -> World from which this entry was obtained



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
    sysoutGeneration*: QData  # Generation number of this world (> 0 if IDS)
    sysoutTimestamp1*: QData  # Unique ID of this world, part 1 ...
    sysoutTimestamp2*: QData  # ... part 2
    sysoutParentTimestamp1*: QData # Unique ID of this world's parent, part 1 ...
    sysoutParentTimestamp2*: QData # ... part 2

    nWiredMapEntries*: LispQ
    wiredMapEntries*: seq[LoadMapEntry] # -> The wired load map entries

    nMergedWiredMapEntries*: LispQ
    mergedWiredMapEntries*: seq[LoadMapEntry] # ..

    nUnwiredMapEntries*: LispQ
    unwiredMapEntries*: seq[LoadMapEntry] # -> The unwired load map entries (Ivory only)

    nMergedUnwiredMapEntries*: LispQ
    mergedUnwiredMapEntries*: seq[LoadMapEntry] # ..

