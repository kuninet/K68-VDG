;
; SAMPLE Drv
;
    ORG $0E00
;
; MIKBUG関係
;
INEEE    EQU $E1AC   ; MIKBUG シリアル入力
SPSAVE   EQU $A008   ; SPセーブ域
BEGAD    EQU $A004   ; PRINT/PUNCH開始アドレス
ENDAD    EQU $A004   ; PRINT/PUNCH最終アドレス
INCNT    EQU $A00E   ; CHAR COUNT (INADD)
TEMP1    EQU $A00F   ; ?
;
; VRAMアドレス
;
SCRFIRST EQU $2C40   ; VRAM先頭アドレス
LASTLINE EQU $2F40   ; VRAM最終行?
VRAMLAST EQU $3000   ; VRAM最終アドレス
;
; 出力?
;
OT:
  STX   SPSAVE
  CMPA #$0A         ; LF?
  BEQ  P1
  CMPA #$0D         ; CR?
  BNE  P2
  LDX  LASTLINE
  BRA  Q1
;
P1:
  BSR  LF_PROC
  BRA  Q2
;
P2:
  CMPA #$0F
  BNE  P3
  LDX  ENDAD
  DEX
  LDAB #$20      ; SPACE
  STAB 0,X
  BRA  Q1
;
P3:
  CMPA #$20
  BLT  Q2
  BRA  CH
;
; 入力?
;
IN:
  JMP  INEEE      ; INをCallされることを想定している。電大版BASICならBSRにする
  STX  SPSAVE
  BSR  P2
  RTS
;
; LF受信時のスクロール処理
;
LF_PROC:
  LDX  SCRFIRST
P4:
  LDAA  #$40,X
  STAA  0,X
  INX
  CPX   LASTLINE
  BNE   P4
  LDAA  #$20
;
P5:
  STAA  0,X
  INX
  CPX   VRAMLAST
  BNE   P5
  RTS
; 



H4:

CH:

Q1:
  STX  ENDAD 
Q2:
  LDX  SPSAVE
  RTS
;
DS:
  LDX  BEGAD
  NOP
B1:
  LDAA #$0D             ; CR
  JSR  OT
  LDAA #$0A             ; LF
  JSR  OT
  CLRB
  STX  INCNT
  JSR  D2
  LDAA TEMP1
  JSR  D2
  JSR  SP

