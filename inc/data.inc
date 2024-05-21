; Dino NES - A small NES game, heavily inspired by the chrome dino.
; Copyright (C) 2024  Mibi88
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program. If not, see https://www.gnu.org/licenses/.

PALETTEDATA:
    .incbin "../pal/bgpal1.pal"
    .byte $31, $1D, $2B, $2A, $31, $31, $2B, $2A, $31, $1D, $2B, $2A, $31, $1D, $2B, $2A
SPRITEDATA:
    ; Sprite 0
    .byte $1F, $0D, %00000001, $0 ; First byte = y, second = number of the tile, last = x.
    ; Player
    .byte $FF, $0A, %00000000, $FF
    ; Object 1
    .byte $FF, $0C, %00100000, $FF
    ; Object 2
    .byte $FF, $0C, %00100000, $FF
    ; Object 3
    .byte $FF, $0C, %00100000, $FF
    ; Region
    .byte $E2, $0E, %00000000, $E2