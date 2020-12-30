#!/bin/sh
lwasm -9 -b animatesg8.asm -oanimatesg8.bin -l -s
xroar -trace animatesg8.bin > trace.log
