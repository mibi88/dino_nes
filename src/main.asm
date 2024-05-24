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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NES Dino                                          ;;
;; by mibi88                                         ;;
;; ------------------------------------------------- ;;
;; v.1.0-PAL                                         ;;
;; ------------------------------------------------- ;;
;; License: GNU GPL v2                               ;;
;; ------------------------------------------------- ;;
;; 2024/05/19:                                       ;;
;; I just put it together these last days using some ;;
;; code I wrote a while ago.                         ;;
;; Have fun when playing this small PAL NES game. I  ;;
;; will adapt it for NTSC later.                     ;;
;; ------------------------------------------------- ;;
;; 2022/01/05 - 2024/05/20                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;------------------------------------;
.include "../inc/header.inc"
;------------------------------------;
.segment "ZEROPAGE"

; For the game
backgroundpos: .res 2
state: .res 1
seed: .res 1
random: .res 1
jump: .res 2
fall: .res 2
playersuby: .res 1
change: .res 1
scroll: .res 2
tick: .res 1
oldx: .res 1
loopx: .res 1
extra: .res 1
nmi: .res 1
ntsc: .res 1
max_tick: .res 1
night: .res 1
pnight: .res 1
tmp: .res 1
objlimit: .res 1
loopy: .res 1

; Less used variables
.segment "BSS"
controlleronein: .res 8
score: .res 8
hi: .res 8
playerspeed: .res 2
jumpspeed: .res 2
fallspeed: .res 2
extraspeedsub: .res 1
wait: .res 6
extraspeed: .res 6
speedsub: .res 6
animspeed: .res 1

;------------------------------------;

.segment "STARTUP"

.include "../inc/gfx.inc"

.proc RAND
    LDX seed
    LDA LOOP, X
    EOR seed
    AND #%00111111
    ORA #%00000100
    STA random
    LDA seed
    SEC
    ADC random
    STA seed
    RTS
.endproc

.proc FADEIN
    LDA night
    CMP BLACK_NIGHT
    BNE LOOP
    RTS
LOOP:
    LDA nmi
    CMP #$01
    BNE LOOP
    LDA #$00
    STA nmi
    ; Handle ticks
    LDX tick
    INX
    CPX max_tick
    BEQ RESETTICK
    STX tick
    JMP LOOP
RESETTICK:
    LDX #$00
    STX tick
    ; Fade in
    INC night
    LDA night
    CMP BLACK_NIGHT
    BNE LOOP
    RTS
.endproc

.proc FADEOUT
    LDA BLACK_NIGHT
    STA night
LOOP:
    LDA nmi
    CMP #$01
    BNE LOOP
    LDA #$00
    STA nmi
    ; Handle ticks
    LDX tick
    INX
    CPX max_tick
    BEQ RESETTICK
    STX tick
    JMP LOOP
RESETTICK:
    LDX #$00
    STX tick
    ; Fade in
    DEC night
    LDA night
    CMP #$00
    BNE LOOP
    RTS
.endproc

.proc PLAYERANIM
    LDA #$12
    STA PLAYERTILE
ANIMLOOP:
    LDA nmi
    CMP #$01
    BNE ANIMLOOP
    LDA #$00
    STA nmi
    LDA PLAYERY
    CLC
    ADC animspeed
    STA PLAYERY
    CMP FLOOR
    BCC ANIMLOOP
    ; Animation end
    LDA FLOOR
    STA PLAYERY
    LDA #$0A
    STA PLAYERTILE
    RTS
.endproc
    

RESET: ; Start.
    SEI ; Disable the interrupts.
    CLD ; Disable decimal mode.
    LDX #$40 ; Disable the sound IRQ.
    STX $4017
    LDX #$FF ; Initializing the stack register.
    TXS
    INX ; X goes to 0.
    STX PPUCTRL ; Zero at PPU registers.
    STX PPUMASK
    STX $4010 ; Disaling PCM channels (APU).
    LDX #$00
MEMORYCLEAR:
    LDA #$00
    STA $0000, X ; $0000 > $00FF
    STA $0100, X ; $0100 > $01FF
    STA $0300, X ; $0300 > $03FF
    STA $0400, X ; $0400 > $04FF
    STA $0500, X ; $0500 > $05FF
    STA $0600, X ; $0600 > $06FF
    STA $0700, X ; $0700 > $07FF
    ; Clear the start of the BSS
    STA $6000, X
    LDA #$FF ; I will store sprites in $0200 to $02FF.
    STA $0200, X ; $0200 > $02FF
    INX
    BNE MEMORYCLEAR
    STA jump
    STA fall
    BIT PPUSTAT
VBLANKCHECK:
    BIT PPUSTAT ; Waiting for VBLANK.
    BPL VBLANKCHECK
    ; Checking TV System as described in
    ; https://forums.nesdev.org/viewtopic.php?p=163258#p163258
    LDX #$00
    LDY #$00
XLOOP:
    INX
    BNE SKIPY ; Branch if X != 0
    INY
SKIPY:
    ; Check for vblank
    BIT PPUSTAT ; Waiting for VBLANK.
    BPL XLOOP
    ; Adapt speed to the region
    CPY #$09
    BEQ NTSC
    CPY #$13
    BEQ NTSC
    ; PAL or Dendy
    LDA PLAYERSPEEDPAL
    STA playerspeed
    LDA PLAYERSPEEDSUBPAL
    STA playerspeed+1
    LDA JUMPSPEEDPAL
    STA jumpspeed
    LDA JUMPSPEEDSUBPAL
    STA jumpspeed+1
    LDA FALLSPEEDPAL
    STA fallspeed
    LDA FALLSPEEDSUBPAL
    STA fallspeed+1
    LDA TICKMAXPAL
    STA max_tick
    LDA EXTRASPEEDSUBPAL
    STA extraspeedsub
    LDA ANIMPAL
    STA animspeed
    JMP VBLANKCHECKB
NTSC:
    LDA PLAYERSPEEDNTSC
    STA playerspeed
    LDA PLAYERSPEEDSUBNTSC
    STA playerspeed+1
    LDA JUMPSPEEDNTSC
    STA jumpspeed
    LDA JUMPSPEEDSUBNTSC
    STA jumpspeed+1
    LDA FALLSPEEDNTSC
    STA fallspeed
    LDA FALLSPEEDSUBNTSC
    STA fallspeed+1
    LDA TICKMAXNTSC
    STA max_tick
    LDA EXTRASPEEDSUBNTSC
    STA extraspeedsub
    LDA ANIMNTSC
    STA animspeed
    ; Change the sprite
    LDA NTSCSPRITE
    STA ntsc
    LDA #$00
VBLANKCHECKB:
    BIT PPUSTAT ; Waiting for VBLANK.
    BPL VBLANKCHECKB
    LDA #$02
    STA $4014
    NOP
    ; Adress $3F00 (Universal background) from the PPU.
    LDA #$3F
    STA PPUADDR ; Asking to write in the memory of the PPU.
    LDA #$00
    STA PPUADDR
    LDX #$00 ; Prepairing for a loop.
    JSR LOADPALETTES
    ; Load title.
LOADTITLE:
    LDA #<TITLEDATA ; Get the low byte of the bg data.
    STA backgroundpos
    LDA #>TITLEDATA ; Get the high byte.
    STA backgroundpos+1
    JSR LOADNAM
    LDX #$00
LOADSPRITES:
    LDA SPRITEDATA, X
    STA $0200, X
    INX
    CPX SPRITELEN ; 20 for 8 sprites > 32 in decimal.
    BNE LOADSPRITES
    CLI ; Interrupts enabled.
    LDA #%10010000 ; Setting up the PPU.
    STA PPUCTRL
    LDA #%00011110 ; Enabling drawings.
    STA PPUMASK
    ; Set region sprite
    LDA ntsc
    CMP NTSCSPRITE
    BNE LOOP
    STA REGIONTILE
LOOP:
    ; Check for NMI
    LDA nmi
    CMP #$01
    BNE LOOP
    LDA #$00
    STA nmi
    ; Read the controller input
    JSR READCONTROLLER1
    ; State 0
    LDA state
    CMP #$01
    BCC STATE0
    BEQ STATEJUMP
    BCS STATEJUMP2
STATEJUMP:
    JMP STATE1
STATEJUMP2:
    JMP STATE2
STATE0:
    INC seed
    LDA controlleronein+3
    CMP #$00
    BNE CHANGESCREEN
    JMP STATE0END
CHANGESCREEN:
    JSR FADEIN
    LDA #$01
    STA state
    ; Load the background
    LDA #<GAMEDATA ; Get the low byte of the bg data.
    STA backgroundpos
    LDA #>GAMEDATA ; Get the high byte.
    STA backgroundpos+1
    JSR LOADNAMINGAME
    LDA FLOOR
    STA PLAYERY
    LDA STARTLIMIT
    STA objlimit
    LDX #$00
    LDY #$00
OBJINITLOOP:
    LDA FLOOR
    STA OBJECTY, X
    LDA #$FF
    STA OBJECTX, X
    STX loopx
    JSR RAND
    LDA random
    STA wait, Y
    JSR RAND
    LDA random
    STA tmp
    JSR RAND
    LDX loopx
    LDA VOIDSPRITE
    STA OBJECTTILE, X
    CPX BIRDSTART
    BCC SETHEIGHT
    LDA FLOOR
    SEC
    SBC random
    STA OBJECTY, X
    LDA tmp
    AND #%00000011
    CLC
    ADC #$01
    STA extraspeed, Y
    JMP CONTINUEINIT
SETHEIGHT:
    LDA FLOOR
    STA OBJECTY, X
    LDA #$00
    STA extraspeed, Y
CONTINUEINIT:
    INY
    ; Increase X by 4
    INX
    INX
    INX
    INX
    CPX OBJECTLEN
    BNE OBJINITLOOP
    LDA #$00
    STA scroll
    LDA #$80
    STA PLAYERX
    ; Reset the score
    LDA #$00
    TAX
RESETLOOP:
    STA score, X
    INX
    CPX #$08
    BNE RESETLOOP
    LDA VOIDSPRITE
    STA PLAYERTILE
    JSR FADEOUT
    ; A little animation
    LDA #$00
    STA PLAYERY
    JSR PLAYERANIM
STATE0END:
    JMP LOOP
STATE2:
    LDA change
    CMP #$00
    BNE CHANGECHECK
    LDA controlleronein+3
    STA change
    CMP #$00
    BEQ STATE2END
CHANGECHECK:
    LDA controlleronein+3
    CMP #$00
    BNE STATE2END
    JSR FADEIN
    LDA #$00
    STA state
    ; Load the background
    LDA #<TITLEDATA ; Get the low byte of the bg data.
    STA backgroundpos
    LDA #>TITLEDATA ; Get the high byte.
    STA backgroundpos+1
    JSR LOADNAMINGAME
    JSR FADEOUT
STATE2END:
    JMP LOOP
STATE1: ; In the game
    ; Jump decrease
    LDA #$00
    CMP jump
    BEQ FALL
    LDA jump+1
    SEC
    SBC fallspeed+1
    STA jump+1
    LDA jump
    SBC fallspeed
    STA jump
    JMP CHECKUP
FALL:
    LDA #$00
    STA jump
    STA jump+1
    ; Fall increase
    LDA fall+1
    CLC
    ADC fallspeed+1
    STA fall+1
    LDA fall
    ADC fallspeed
    STA fall
CHECKUP:
    LDY controlleronein ; A button
    CPY #$01
    BNE CHECKDOWN
    ; Jump
    LDA PLAYERY; Check if the player is on the floor
    CMP FLOOR
    BNE CHECKDOWN
    LDA jumpspeed
    STA jump
CHECKDOWN:
    LDY controlleronein+1 ; B button
    CPY #$01
    BNE COLLISIONCHECK
    ; TODO: Crouch
COLLISIONCHECK:
    ; Adapt the player position for collision check
    LDA PLAYERY
    CLC
    ADC #$04
    STA PLAYERY
    LDA PLAYERX
    CLC
    ADC #$04
    STA PLAYERX
    ; Check for collision for all objects
    LDY #$00
CHECKLOOP:
    LDA OBJECTY, Y
    CMP PLAYERY
    BCS CHECKNEXT
    CLC
    ADC OBJECTSIZE
    CMP PLAYERY
    BCC CHECKNEXT
    ; Check on the X axis
    LDA OBJECTX, Y
    TAX
    CLC
    ADC #$08
    CMP PLAYERX
    BCC CHECKNEXT
    CPX PLAYERX
    BCS CHECKNEXT
    JMP ISCOLLISION
CHECKNEXT:
    ; Increase Y by 4
    INY
    INY
    INY
    INY
    CPY OBJECTLEN
    BNE CHECKLOOP
    JMP MOVEOBJECT
ISCOLLISION: ; If there is a collision
    JSR PLAYERANIM
    JSR FADEIN
    ; Change to the game over screen
    LDA #$02
    STA state
    ; Reset change because START was not pressed.
    LDA #$00
    STA change
    ; Reset palette
    LDA #$00
    STA night
    JSR LOADPALETTESINGAME
    ; Load the game over nametable
    LDA #<GAMEOVERDATA ; Get the low byte of the bg data.
    STA backgroundpos
    LDA #>GAMEOVERDATA ; Get the high byte.
    STA backgroundpos+1
    JSR LOADNAMINGAME
    ; Hide sprites
    LDA #$FF
    STA PLAYERY
    LDX #$00
HIDEOBJLOOP:
    STA OBJECTY, X
    ; Increase X by 4
    INX
    INX
    INX
    INX
    CPX OBJECTLEN
    BNE HIDEOBJLOOP
    ; Set scroll to 0 to keep the title and game over screens displayed at 0, 0
    STA scroll
    ; Set the hiscore
    LDX #$00
HISCORELOOP:
    LDA score, X
    CMP hi, X
    BCC GAMEEND
    CMP hi, X
    BEQ CONTINUE
    JMP HISCORELOOPEND
CONTINUE:
    INX
    CPX #$08
    BNE HISCORELOOP
HISCORELOOPEND:
    LDX #$00
HISETLOOP:
    LDA score, X
    STA hi, X
    INX
    CPX #$08
    BNE HISETLOOP
GAMEEND:
    JSR FADEOUT
    JMP LOOP
MOVEOBJECT:
    ; Restore the player position after collision check
    LDA PLAYERY
    SEC
    SBC #$04
    STA PLAYERY
    LDA PLAYERX
    SEC
    SBC #$04
    STA PLAYERX
    LDX #$00
    LDY #$00
MOVEOBJLOOP:
    LDA wait, Y
    CMP #$00
    BEQ MOVE
    SEC
    SBC #$01
    STA wait, Y
    JMP MOVELOOPEND
MOVE:
    LDA OBJECTTILE, X
    CMP VOIDSPRITE
    BNE UPDATEX
    LDA #$0C
    STA OBJECTTILE, X
UPDATEX:
    ; Apply the extra speed
    LDA extraspeed, Y
    CMP #$00
    BEQ SCROLL
    STA loopx ; Loop maximum
    STY loopy ; Save Y
    LDY #$00
EXTRALOOP:
    STX tmp
    LDX loopy
    LDA speedsub, X
    SEC
    SBC extraspeedsub
    STA speedsub, X
    LDX tmp
    LDA OBJECTX, X
    SBC #$00
    STA OBJECTX, X
INCSKIP:
    INY
    CPY loopx
    BCC EXTRALOOP
    LDY loopy
SCROLL:
    ; Scroll to the left
    LDA OBJECTX, X
    STA oldx
    SEC
    SBC playerspeed
    STA OBJECTX, X
    LDA extra
    CMP #$01
    BNE MOVECONTINUE
    DEC OBJECTX, X
MOVECONTINUE:
    LDA OBJECTX, X
    CMP oldx
    BCC MOVELOOPEND
    BEQ MOVELOOPEND
    LDA #$FF
    STA OBJECTX, X
    STX loopx
    JSR RAND
    LDA random
    STA wait, Y
    JSR RAND
    LDA random
    STA tmp
    JSR RAND
    LDX loopx
    LDA VOIDSPRITE
    STA OBJECTTILE, X
    CPX BIRDSTART
    BCC MOVELOOPEND
    LDA FLOOR
    SEC
    SBC random
    STA OBJECTY, X
    LDA tmp
    AND #%00000011
    CLC
    ADC #$01
    STA extraspeed, Y
MOVELOOPEND:
    INY
    ; Increase X by 4
    INX
    INX
    INX
    INX
    CPX objlimit
    BEQ MOVEEND
    JMP MOVEOBJLOOP
MOVEEND:
    LDA #$00
    STA extra
NMIEND:
    ; Apply gravity and jump
    ; Jump
    LDA playersuby
    SEC
    SBC jump+1
    STA playersuby
    LDA PLAYERY
    SBC jump
    STA PLAYERY
    ; Fall
    LDA playersuby
    CLC
    ADC fall+1
    STA playersuby
    LDA PLAYERY
    ADC fall
    STA PLAYERY
    ; Collision with the ground
    CMP FLOOR
    BCC FLOORCHECKEND
    ; If the player is on the floor
    LDA #$00
    STA fall
    STA fall+1
    STA jump
    STA jump+1
    LDA FLOOR
    STA PLAYERY
FLOORCHECKEND:
    ; End
    LDA scroll+1
    CLC
    ADC playerspeed+1
    STA scroll+1
    BCC ADDSPEED
    LDA #$01
    STA extra
ADDSPEED:
    LDA scroll
    ADC playerspeed
    STA scroll
    ; Handle ticks
    LDX tick
    INX
    CPX max_tick
    BEQ RESETTICK
    STX tick
    JMP LOOP
RESETTICK:
    LDX #$00
    STX tick
    ; Animate the birds
    LDX BIRDSTART
BIRDLOOP:
    LDY OBJECTTILE, X
    CPY VOIDSPRITE
    BEQ CONTINUEBIRDLOOP
    LDA #$11
    STA OBJECTTILE, X
    CPY #$11
    BNE CONTINUEBIRDLOOP
    LDA #$10
    STA OBJECTTILE, X
CONTINUEBIRDLOOP:
    INX
    INX
    INX
    INX
    CPX BIRDEND
    BCC BIRDLOOP
    ; Update the object limit
    LDA score+BIRDDIGIT
    CMP BIRDDIGITMIN
    BNE DAYNIGHT
    LDA OBJECTLEN
    STA objlimit
DAYNIGHT:
    ; Handle the day/night cycle
    LDA score+CYCLEDIGIT
    AND #%11111110
    STA tmp
    LDA score+CYCLEDIGIT
    SEC
    SBC tmp
    CMP #$00
    BNE NIGHT
    ; Day
    LDA night
    CMP #$00
    BEQ DINO
    DEC night
    JMP DINO
NIGHT:
    LDA night
    CMP NIGHT_MAX
    BEQ DINO
    INC night
DINO:
    ; Animate the dino
    LDX PLAYERTILE
    INX
    STX PLAYERTILE
    CPX #$0C
    BNE SCOREUPDATE
    LDX #$0A
    STX PLAYERTILE
SCOREUPDATE:
    ; Increase the score
    LDX #$08
SCORELOOP:
    DEX
    INC score, X
    
    LDA score, X
    CMP #$0A
    BEQ NEXT
    JMP LOOP
NEXT:
    LDA #$00
    STA score, X
    CPX #$00
    BNE SCORELOOP
    JMP LOOP

NMI: ;Non-maskable interrupt.
    PHA
    TXA
    PHA
    TYA
    PHA
    BIT PPUSTAT
    ; Update the palette
    JSR LOADPALETTESINGAME
    LDA #$01
    STA nmi
    ; Update the score
    LDA state
    CMP #$01
    BNE GAMEOVERSCORE
    JSR DRAWSCORE
GAMEOVERSCORE:
    CMP #$02
    BNE COPYSPRITES
    JSR DRAWSCOREGAMEOVER
COPYSPRITES:
    LDA #$02 ; Copy the sprite data into the PPU.
    STA PPUOAM
    ; Handle the status bar
    LDA #$00
    STA PPUSCRL ; X scroll
    STA PPUSCRL ; Y scroll
    LDA state
    CMP #$01
    BNE END
WAITS0CLEAR:
    BIT $2002
    BVS WAITS0CLEAR
WAITS0SET:
    BIT $2002
    BVC WAITS0SET
    LDA scroll
    STA PPUSCRL ; X scroll
    LDA #$00
    STA PPUSCRL ; Y scroll
END:
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI
.include "../inc/data.inc"
.include "../inc/nametables.inc"
;------------------------------------;
.segment "VECTORS"
    ; Interrupts :
    .word NMI
    .word RESET
;------------------------------------;
.segment "CHARS"
    .incbin "../inc/tiles.chr"
;------------------------------------;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
