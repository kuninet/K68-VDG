;
; MC6847 All ASCII CHAR List 
;   for SBC6800+SBC Adapter
;
        
	CPU	6800

TARGET:	equ	"MC6800"

        org     $0100
;
VRAM_TOP        EQU     $C000
VRAM_END        EQU     $C200
SPC             EQU     $20
;
VDG_MODE        EQU     %00000000
VDG_CTL_AD      EQU     $8110
;
MAIN:
        JSR     VDG_INIT
        JSR     VRAM_CLR
        JSR     CHAR_PRINT
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
; 全キャラクター表示
;
CHAR_PRINT:
        LDX     #VRAM_TOP
        LDAA    #0
CHAR_PRINT_LOOP:
        STAA    0,X
        INCA
        INX
        CPX     #VRAM_END
        BNE     CHAR_PRINT_LOOP
        RTS
;
        END