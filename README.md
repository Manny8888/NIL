This project is a way to learn more about Nim by translating the Symbolics virtual lisp machine.


*Note that:*
- The nimble file is useless. Simply run *nim compile --checks:on --run src/NimMachine.nim* for the moment.

- The runtime creates a log to track what's happening. The log is in the top level directory and is hard-coded as "runLog.log"

- The name/location of the band is hard-coded as "../Genera-8-5-xlib-patched.vlod". Finding the band is a Google/Duckduck/Bing easy search away.



The current strategy is to follow the world.c code to load the band in with the right values. Execution will follow later.

Things to explore:
- ncurses (to start with) interface to present all the information spilled out. With tabs to inspect different aspects. Probably something tree-like for the torrent of information.

- Removed the initial data structure using variants. Currently adds complexity for no obvious gain. To be revisited when opcodes are actually executed.

