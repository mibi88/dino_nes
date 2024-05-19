#!/bin/bash

bash build.sh
echo "=====> Running in FCEUX (PAL) <====="
fceux --pal 1 ./bin/dino.nes
echo "=====> Done ! <====="
