;
; MV6847 ビデオボード エコーバック
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
SPC             EQU     $60
ESC             EQU     $1B
CR              EQU     $0D
CURSOR          EQU     $CF
BS              EQU     $08
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
CONIN           EQU     $FFA0
CONOUT          EQU     $FF90

MAIN:
        LDX     #VRAM_TOP
        STX     WK_VRAM
;
        JSR     VDG_INIT
        JSR     VRAM_CLR
        JSR     DISP_CURSOR
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
;
; 内部CGにあわせて キャラクターコード変換
;
; 英小文字は大文字変換
        CMPA    #$60
        BGE     SUB20
; 英大文字はそのまま出力
        CMPA    #$40
        BGE     ECHO1
; 特殊記号はリバースキャラへ変更
        CMPA    #$20
        BGE     ADD40
        BRA     ECHO1
SUB20:
        SUBA    #$20
        BRA     ECHO1
ADD40:
        ADDA    #$40
        BRA     ECHO1
ECHO1:
        JSR     VRAM_OUT
        BRA     ECHO
;
ECHO_END:
        RTS
;
; BS処理
;
BS_RTN:
        CPX     #VRAM_TOP
        BEQ     VRAM_OUT_END
;
        JSR     CLR_CURSOR
        LDX     WK_VRAM
        DEX
        STX     WK_VRAM
        JSR     DISP_CURSOR
        BRA     VRAM_OUT_END
;
; VRAM出力ルーチン
;
VRAM_OUT:
        CMPA    #CR
        BEQ     VRAM_CR
        CMPA    #BS
        BEQ     BS_RTN
;
        LDX     WK_VRAM
        STAA    0,X
        LDAA    #CURSOR
        STAA    1,X
        INX
        STX     WK_VRAM
        CPX     #VRAM_END       ; 画面右下まできた?
        BNE     VRAM_OUT_END
;
; スクロール処理
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
; CR($0D)が押されたら改行処理
;
VRAM_CR:
        JSR     CLR_CURSOR
;
        LDAA    WK_VRAM+1
        ANDA    #$E0
        LDAB    WK_VRAM
        ADDA    #$20
        ADCB    #0
        CMPB    #$A2            ; VRAMはみ出す?
        BEQ     VRAM_SCR1       ; スクロール処理へ
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
