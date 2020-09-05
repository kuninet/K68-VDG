;
; エコーバック
;  for SBC6800+SBC adapter & universal Monitor
;
	CPU	6800

TARGET:	equ	"MC6800"

        org     $0100
;
VRAM_TOP        EQU     $A000
VRAM_END        EQU     $A200
VRAM_SCREND     EQU     VRAM_END-$20
;
SPC             EQU     $20
ESC             EQU     $1B
CR              EQU     $0D
CURSOR          EQU     $8F
;
CHAR_A          EQU     $40
CHAR_UNS        EQU     $5F
;
CHAR_S_A        EQU     $60
CHAR_END        EQU     $7F
;
VDG_MODE        EQU     %00000000
VDG_CTL_AD      EQU     $8110
;
CONIN           EQU     $E75D
CONOUT          EQU     $E76E

MAIN:
        LDX     #VRAM_TOP
        STX     WK_VRAM
        JSR     DISP_CURSOR
;
        JSR     VDG_INIT
        JSR     VRAM_CLR
        JSR     ECHO
        SWI
;
; MC6747初期化
;
VDG_INIT:
        LDAA    #VDG_MODE
        STAA    VDG_CTL_AD
        RTS
;
; VRAMクリア
;
VRAM_CLR:
        LDX #VRAM_TOP
        LDAA #SPC
VRAM_CLR_LOOP:
        STAA 0,X
        INX
        CPX     #VRAM_END
        BNE     VRAM_CLR_LOOP
        RTS
;
; キー入力エコー
;
ECHO:
        JSR     CONIN
        CMPA    #ESC
        BEQ     ECHO_END
        JSR     CONOUT
        JSR     VRAM_OUT
        BRA     ECHO
ECHO_END:
        RTS
;
VRAM_OUT:
        CMPA    #CR
        BEQ     VRAM_CR
;
        LDX     WK_VRAM
        STAA    0,X
        LDAA    #CURSOR
        STAA    1,X
        INX
        STX     WK_VRAM
        CPX     #VRAM_END
        BNE     VRAM_OUT_END
;
VRAM_SCR1:
        LDX     #VRAM_TOP
        STX     WK_VRAM
VRAM_SCR:
        LDAA    $20,X
        STAA    0,X
        INX
        CPX     #VRAM_SCREND
        BNE     VRAM_SCR
;
        LDAA    #SPC
LINE_CLR:
        STAA    0,X
        INX
        CPX     #VRAM_END
        BNE     LINE_CLR
        LDX     #VRAM_SCREND
        STX     WK_VRAM
        JSR     DISP_CURSOR
        BRA     VRAM_OUT_END
;
VRAM_CR:
        JSR     CLR_CURSOR
;
        LDAA    WK_VRAM+1
        ANDA    #$E0
        LDAB    WK_VRAM
        ADDA    #$20
        ADCB    #0
        CMPB    #$A2
        BEQ     VRAM_SCR1
        STAB    WK_VRAM
        STAA    WK_VRAM+1
        JSR     DISP_CURSOR
        BRA     VRAM_OUT_END
;
VRAM_OUT_END:
        RTS
;
; カーソル表示
;
DISP_CURSOR:
        LDAA    #CURSOR
        LDX     WK_VRAM
        STAA    0,X
        RTS
;
; カーソル消去
;
CLR_CURSOR:
        LDAA    #SPC
        LDX     WK_VRAM
        STAA    0,X
        RTS
;
WK_VRAM FCB     2
;
        END
