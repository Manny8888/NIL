import memory

# Common world format format definitions
const
  VersionAndArchitectureQ* = 0

# VLM world file format definitions
const
  VLMWorldSuffix* = ".vlod"

  VLMWorldFileCookie* = 0xA38A8988
  VLMWorldFileCookieSwapped* = 0x88898AA3
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


var isLittleEndian: bool = true

# A single load map entry -- See SYS:NETBOOT;WORLD-SUBSTRATE.LISP for details

type
  LoadMapEntry = object
    address*: VM_Address      # VMA to be filled in by this load map entry
    count*: VM_Address # FIXME  = 24.VM_Address # Number of words to be filled in by this entry
    opcode*: uint # FIXME  = 8 # An LoadMapEntryOpcode specifying how to do so
    data*: VM_PageData        # FIXME # Interpretation is based on the opcode
    world*: ref World # -> World from which this entry was obtained 


# Description of an open world file
  World* = object
    pathname*: string         # -> Pathname of the world file
    fd*: File                 # Unix filedes # if the world file is open
    format: uint # FIXME # A LoadFileFormat indicating the type of file
    isByteSwapped: bool       # World is byte swapped on this machine (VLM only)
    vlmDataPageBase*: VM_PageNumber # Block number of first page of data (VLM only)
    vlmTagsPageBase*: VM_PageNumber # Block number of first page of tags (VLM only)
    vlmDataPage*: VM_PageData # -> The data of the current VLM format page
    vlmTagPage*: VM_PageTag # -> The tags of the current VLM format page 
    # FIXMEbyte *ivoryDataPage* :  # -> The data of the current Ivory format page
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

