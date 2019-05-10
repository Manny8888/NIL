
import world


const
  worldFileName: string = "../Genera-8-5-xlib-patched.vlod" # FIXME: hardcoded for the moment - should be an option or
                                                             # a file chooser window

echo "Start with world file:"
echo worldFileName
flushFile(stdout)

var
  isOK: bool
  currentWorld: World

(isOK, currentWorld) = loadWorld(worldFileName)



