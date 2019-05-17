
import logging

var
  isLittleEndian*: bool = true

  runLog* = newFileLogger("runLog.log")
  ivoryPageReadLog* = newFileLogger("ivoryPageLog.log")

