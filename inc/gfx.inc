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

.include "../inc/defs.inc"

.proc LOADPALETTES
    LDX #$00
LOOP:
    LDA PALETTEDATA, X
    STA PPUDATA ; Store palette data into the PPU memory.
    INX
    CPX #$20 ; 32 in decimal.
    BNE LOOP
    LDX #$00
    RTS
.endproc

.proc READCONTROLLER1
    LDA #$01 ; Read controller 1 input
    STA $4016
    LDA #$00
    STA $4016
    LDX #$00
CONTROLLER1LOOP:
    LDA $4016
    AND #%00000001
    STA controlleronein, X
    INX
    CPX #$08
    BNE CONTROLLER1LOOP
    RTS
.endproc

.proc LOADNAM
    ; Get ready for the loop.
    BIT PPUSTAT ; Setup the PPU for the nametable data.
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDX #$00
    LDY #$00
LOOP:
    ; Copy the data.
    LDA (backgroundpos), Y
    STA PPUDATA
    INY
    ; Check if we need to continue.
    CPX #$04
    BNE XLOOP
    CPY #$01
    BEQ END
XLOOP:
    ; X loop.
    CPY #$00
    BNE LOOP
    INX
    INC backgroundpos+1
    JMP LOOP
END:
    RTS
.endproc

.proc LOADNAMINGAME
    SEI
    LDA #$00
    STA PPUCTRL ; Zero at PPU registers.
    STA PPUMASK
    ; Get ready for the loop.
    BIT PPUSTAT ; Setup the PPU for the nametable data.
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    STA PPUCTRL ; Zero at PPU registers.
    STA PPUMASK
    LDX #$00
    LDY #$00
LOOP:
    ; Copy the data.
    LDA (backgroundpos), Y
    STA PPUDATA
    INY
    ; Check if we need to continue.
    CPX #$04
    BNE XLOOP
    CPY #$01
    BEQ END
XLOOP:
    ; X loop.
    CPY #$00
    BNE LOOP
    INX
    INC backgroundpos+1
    JMP LOOP
END:
    LDA #%10010000 ; Setting up the PPU.
    STA PPUCTRL
    LDA #%00011110 ; Enabling drawings.
    STA PPUMASK
    CLI
    RTS
.endproc

.proc DRAWSCORE
    SEI
    LDA #$00
    STA PPUCTRL ; Zero at PPU registers.
    STA PPUMASK
    ; Get ready for the loop.
    BIT PPUSTAT ; Setup the PPU for the nametable data.
    LDA #$20
    STA PPUADDR
    LDA #$48
    STA PPUADDR
    STA PPUCTRL ; Zero at PPU registers.
    STA PPUMASK
    LDX #$00
    ; Set the tiles
SLOOP:
    LDA score, X
    CLC
    ADC #$30
    STA PPUDATA
    INX
    CPX #$08
    BNE SLOOP
    ; Load the hiscore
    LDA #$20
    STA PPUADDR
    LDA #$57
    STA PPUADDR
    LDX #$00
HLOOP:
    LDA hi, X
    CLC
    ADC #$30
    STA PPUDATA
    INX
    CPX #$08
    BNE HLOOP
    ; Enable drawing etc.
    LDA #%10010000 ; Setting up the PPU.
    STA PPUCTRL
    LDA #%00011110 ; Enabling drawings.
    STA PPUMASK
    CLI
    RTS
.endproc

.proc DRAWSCOREGAMEOVER
    SEI
    LDA #$00
    STA PPUCTRL ; Zero at PPU registers.
    STA PPUMASK
    ; Get ready for the loop.
    BIT PPUSTAT ; Setup the PPU for the nametable data.
    LDA #$21
    STA PPUADDR
    LDA #$89
    STA PPUADDR
    STA PPUCTRL ; Zero at PPU registers.
    STA PPUMASK
    LDX #$00
    ; Set the tiles
SLOOP:
    LDA score, X
    CLC
    ADC #$30
    STA PPUDATA
    INX
    CPX #$08
    BNE SLOOP
    ; Load the hiscore
    LDA #$21
    STA PPUADDR
    LDA #$96
    STA PPUADDR
    LDX #$00
HLOOP:
    LDA hi, X
    CLC
    ADC #$30
    STA PPUDATA
    INX
    CPX #$08
    BNE HLOOP
    ; Enable drawing etc.
    LDA #%10010000 ; Setting up the PPU.
    STA PPUCTRL
    LDA #%00011110 ; Enabling drawings.
    STA PPUMASK
    CLI
    RTS
.endproc

