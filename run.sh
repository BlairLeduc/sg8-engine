#!/bin/sh
lwasm -9 -b engine.asm -oengine.bin -l -s
xroar engine.bin
