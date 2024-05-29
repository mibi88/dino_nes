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

.define BIRDSTART #$0C
.define BIRDEND OBJECTLEN
.define OBJECTLEN #$18 ; 6*4
.define CLOUDLEN #$18 ; 6*4
.define SPRITELEN #$40 ; 16*4
.define FLOOR #$7C
.define OBJECTSIZE #$08
.define OBJECTTOP #$74 ; FLOOR - OBJECTSIZE
.define NIGHT_MAX #$02
.define BLACK_NIGHT NIGHT_MAX+1
.define CYCLEDIGIT 5

.define STARTLIMIT #$0C ; 3*4
.define BIRDDIGIT 6
.define BIRDDIGITMIN #$05

; PAL speeds
.define PLAYERSPEEDPAL #$01
.define PLAYERSPEEDSUBPAL #$FE

.define JUMPSPEEDPAL #$08
.define JUMPSPEEDSUBPAL #$00

.define FALLSPEEDPAL #$00
.define FALLSPEEDSUBPAL #$F0

.define EXTRASPEEDSUBPAL #$B4

.define TICKMAXPAL #$0A

.define ANIMPAL #$06

; NTSC speeds
.define PLAYERSPEEDNTSC #$01
.define PLAYERSPEEDSUBNTSC #$A9

.define JUMPSPEEDNTSC #$08
.define JUMPSPEEDSUBNTSC #$00

.define FALLSPEEDNTSC #$00
.define FALLSPEEDSUBNTSC #$C8

.define EXTRASPEEDSUBNTSC #$96

.define TICKMAXNTSC #$0C

.define ANIMNTSC #$05

.define NTSCSPRITE #$0F

.define VOIDSPRITE #$FF

.define CLOUDTICKMAX #$04
.define CLOUDTILESTART #$13
.define CLOUDXSTART 39

.define DEADPLAYER #$19

.define SELECTSTARTX #$68
.define SELECTSTARTY #$98

.define SELECTMAX #$03

.define CURSOR #$1A

.define TEXTCOLOR1 #$05
.define TEXTCOLOR2 #$06

.define NIGHTTEXT1 #$30
.define NIGHTTEXT2 #$32

.define LOADINGSPEEDPAL #%01111111
.define LOADINGSPEEDNTSC #%00000011

; 1662607/(440*16)-1 = 440 Hz wave on PAL
.define PERIODPAL #$EB
; 1789773/(440*16)-1 = 440 Hz wave on NTSC
.define PERIODNTSC #$FD

PLAYERX = $0207
PLAYERY = $0204
PLAYERTILE = $0205
OBJECTX  = $020B
OBJECTTILE  = $0209
OBJECTY  = $0208
REGIONTILE = $0221
CLOUDTILE = $0225
CLOUDX = $0227
SELECTX = $023F
SELECTY = $023C
SELECTTILE = $023D

APUFLAGS = $4015
APUSQ1LO = $4002
APUSQ1HI = $4003
APUSQ1ENV = $4000
