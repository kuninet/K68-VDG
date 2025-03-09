;
; SAMPLE Drv
;
    ORG $0E00
;
; MIKBUG関係
;
INEEE    EQU $E1AC   ; MIKBUG シリアル入力
BEGAD    EQU $A002   ; PRINT/PUNCH開始アドレス
ENDAD    EQU $A004   ; PRINT/PUNCH最終アドレス
xxxxx    EQU $A006   ; 
SPSAVE   EQU $A008   ; SPセーブ域
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
  BSR D2
H2:
  BSR D2
SP:
  LDAA #$20      ; SPACE
  BRA  CH
D2:
  LDA 0,X
  PSH A
  LSR A
  LSR A
  LSR A
  LSR A
  BSR AS
  PUL A
  AND #$0F
  BSR AS
  INX
  RTS
AS:
  SUB A,#$9
  BGT CH
  ADD A,#$39
CH:
  STX SPSAVE
  LDX ENDAD
  STX 0,X
  INX
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
  LDA  A,INCNT
  JSR  D2
  ;
  LDAA TEMP1
  JSR  D2
  JSR  SP
  DEX
  DEX
  NOP
  JSR  H2
  CPX  #$A006
  BEQ  ED
  CMP  #$07
  BEQ  B3
  INC  B
  BRA  B2
ED:
  SWI
B3:
  JSR  SP
  JSR  SP
  JSR  SP
  BRA  B1

