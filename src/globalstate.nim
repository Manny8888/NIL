
import logging
import world_types

const
  WorldFileName: string = "../Genera-8-5-xlib-patched.vlod" # FIXME: hardcoded for the moment - should be an option or
                                                             # a file chooser window

var
  isLittleEndian*: bool = true

  runLog* = newFileLogger("runLog.log")
  ivoryPageReadLog* = newFileLogger("ivoryPageLog.log")

  currentWorld*: World
  originalWorld*: World


