#!/bin/sh
lwasm -9 -b animatesg8.asm -oanimatesg8.bin
decb dskini animate.dsk
decb copy -2 -b animatesg8.bin animate.dsk,ANIMATE.BIN
decb copy -3 -a -l animatesg8.asm animate.dsk,ANIMATE.ASM