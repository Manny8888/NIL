
import constants
import types

const

  # FIXME The definitions are ugly hacks to go around casting errors. 
  # If the constants are left normal, they are cast as int64 for no understandable (to me) reason
  # This doesn't work   Address_NIL*: uint32 = 0xF8041200
  Address_NIL*: uint32 = 0xF80412 shl 8 # 0xF8041200
  Address_T*: uint32 = (0xF80412 shl 8) + 8 # 0xF8041208

