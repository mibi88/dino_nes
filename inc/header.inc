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

.segment "HEADER"
.byte "NES"
.byte $1a
.byte $01 ; PRG ROM
.byte $01 ; CHR ROM
.byte %00000000 ; mapper + mirorring
.byte $00
.byte $00
.byte %00000001
.byte $00
.byte $00, $01, $00, $00, $00
