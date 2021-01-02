#!/bin/sh
lwasm -9 -b engine.asm -oengine.bin
decb dskini engine.dsk
decb copy -2 -b engine.bin engine.dsk,ENGINE.BIN
#decb copy -3 -a -l engine.asm engine.dsk,ENGINE.ASM