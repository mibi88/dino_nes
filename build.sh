#!/bin/bash

echo "=====> Building 'src/main.asm' with ca65 ... <====="
ca65 ./src/main.asm -o ./bin/main.o -W 2 -t nes
ld65 ./bin/main.o -o ./bin/dino.nes -t nes
rm ./bin/*.o
echo "=====> Done ! <====="
