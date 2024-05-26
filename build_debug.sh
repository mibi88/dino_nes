#!/bin/bash

echo "=====> Building 'src/main.asm' with ca65 ... <====="
ca65 ./src/main.asm -o ./bin/main.o -W 2 -t nes -g
od65 -S ./bin/main.o
ld65 ./bin/main.o -o ./bin/dino.nes -C nrom.cfg --dbgfile dino.dbg
rm ./bin/*.o
echo "=====> Done ! <====="
