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

PPUCTRL = $2000
PPUMASK = $2001
PPUSTAT = $2002
PPUADDR = $2006
PPUDATA = $2007
PPUSCRL = $2005
PPUOAM  = $4014
;;;;;;;;;;;;;;;
; TODO: Move in subpixel units

.define OBJECTLEN #$0C ; 3*4
.define SPRITELEN #$14 ; 5*4
.define PLAYERSPEED #$02
.define FLOOR #$7C
.define OBJECTSIZE #$08
.define OBJECTTOP #$74 ; FLOOR - OBJECTSIZE
; TODO: Adapt PLAYERSPEED when on NTSC
.define JUMPFORCE #$0A
; TODO: Set the JUMPFORCE to #$08 when on NTSC
PLAYERX = $0207
PLAYERY = $0204
PLAYERTILE = $0205
OBJECTX  = $020B
OBJECTTILE  = $020C
OBJECTY  = $0208
