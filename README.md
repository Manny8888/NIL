This project is a way to learn more about Nim by translating the Symbolics virtual lisp machine.


*Note that:*
- The nimble file is useless. Simply run *nim compile --checks:on --run src/NimMachine.nim* for the moment. 

- The runtime creates 2 logs to track what's happening. They are in the top level directory hard-coded as ``ivoryPageLog.log`` for memory reads and ``runLog.log`` for everything else. (Alternatively, run ``true > runLog.log ; true > ivoryPageLog.log ; nim compile --checks:on --run src/NimMachine.nim`` if the log files are opened in a text editor with auto-reload (``true > file`` clears the content of a file without clearing the inode which prevents the auto-reload from getting confused.))

- The name/location of the band is hard-coded as ``../Genera-8-5-xlib-patched.vlod``. Finding the band is a Google/Duckduck/Bing easy search away.



The current strategy is to follow the ``world.c`` code to load the band in with the right values. Execution will follow later.

Things to explore:
- ncurses (to start with) interface to present all the information spilled out. With tabs to inspect different aspects. Probably something tree-like for the torrent of information.

- Removed the initial data structure using variants. Currently adds complexity for no obvious gain. To be revisited when opcodes are actually executed.

