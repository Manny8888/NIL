
import logging, globalstate, world


const
  worldFileName: string = "../Genera-8-5-xlib-patched.vlod" # FIXME: hardcoded for the moment - should be an option or
                                                             # a file chooser window


echo "Start with world file:"
echo worldFileName

var
  isOK: bool
  currentWorld: World

(isOK, currentWorld) = openWorldFile(worldFileName)



# Just in case...
flushFile(stdout)

