#!/bin/sh
lwasm -9 -b engine.asm -oengine.bin
rm -f engine.dsk.bak
mv engine.dsk engine.dsk.bak
decb dskini engine.dsk
decb copy -2 -b engine.bin engine.dsk,ENGINE.BIN
#decb copy -3 -a -l engine.asm engine.dsk,ENGINE.ASM