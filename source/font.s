****************************************
* FONT ENGINE (v3?)                    *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2013-07-20                          *
****************************************
* Note that this is not particularly   *
* optimized.  But it's meant to be a   *
* straightforward implementation that  *
* is easy to understand.               *
****************************************
* A= ptr to string preceded by length  *
* X= screen location                   *
****************************************
; each char:
;  draw char at loc
;  update loc
;  see if length hit - no? back to draw char
              mx %00
]F_Length     ds 2          ;length of string (only one byte currently used)
]F_CharIdx    ds 2          ;index of current character
]F_CurrentPos ds 2          ;current top left char position
]F_StrPtr     equ $00       ;pointer to string (including length byte) / DP


DrawString    sta ]F_StrPtr ;store at dp 0 ($00) for indirect loads
              stx ]F_CurrentPos
              stz ]F_CharIdx
              lda (]F_StrPtr)
              and #$00ff    ;strip off first char (len is only one byte)
              sta ]F_Length ;get our length byte
              
NextChar      lda ]F_CharIdx
              cmp ]F_Length
              bne :notDone
              rts           ;DONE! Return to caller
              
:notDone      inc ]F_CharIdx
              ldy ]F_CharIdx          
              lda ($00),y   ;get next char!
              and #$00FF    ;mask high byte
              sec
              sbc #' '      ;our table starts with space ' '
              asl           ;*2
              tay
              ldx ]F_CurrentPos
              jsr :drawChar
              inc ]F_CurrentPos           ;compare to addition time (?)
              inc ]F_CurrentPos           
              inc ]F_CurrentPos           
              inc ]F_CurrentPos           ;update screen pos (2 words=8 pixels)
              bra NextChar

;x = TopLeft screen pos
;y = char table offset
:drawChar     lda FontTable,y             ;get real address of char data
              sec 
              sbc #FontData  ;pivot offset - now a is offset of fontdata
              tay           ;so we'll index with that
              lda FontData,y
              stal $E12000,x
              lda FontData+2,y
              stal #2+$E12000,x
              lda FontData+4,y
              stal #160+$E12000,x
              lda FontData+6,y
              stal #160+2+$E12000,x
              lda FontData+8,y
              stal #160*2+$E12000,x
              lda FontData+10,y
              stal #160*2+2+$E12000,x
              lda FontData+12,y
              stal #160*3+$E12000,x
              lda FontData+14,y
              stal #160*3+2+$E12000,x
              lda FontData+16,y
              stal #160*4+$E12000,x
              lda FontData+18,y
              stal #160*4+2+$E12000,x
              lda FontData+20,y
              stal #160*5+$E12000,x
              lda FontData+22,y
              stal #160*5+2+$E12000,x
              rts





FontTable     dw s_Space
          dw s_Exclaim
          dw s_Quote
          dw s_Number
          dw s_Dollar
          dw s_Percent
          dw s_Amper
          dw s_Single
          dw s_OpenParen
          dw s_CloseParen
          dw s_Asterix
          dw s_Plus
          dw s_Comma
          dw s_Minus
          dw s_Period
          dw s_Slash
          dw s_N0
          dw s_N1
          dw s_N2
          dw s_N3
          dw s_N4
          dw s_N5
          dw s_N6
          dw s_N7
          dw s_N8
          dw s_N9
          dw s_Colon
          dw s_Semi
          dw s_LAngle
          dw s_Equal
          dw s_RAngle
          dw s_Question
          dw s_At
          dw s_A
          dw s_B
          dw s_C
          dw s_D
          dw s_E
          dw s_F
          dw s_G
          dw s_H
          dw s_I
          dw s_J
          dw s_K
          dw s_L
          dw s_M
          dw s_N
          dw s_O
          dw s_P
          dw s_Q
          dw s_R
          dw s_S
          dw s_T
          dw s_U
          dw s_V
          dw s_W
          dw s_X
          dw s_Y
          dw s_Z
          dw s_LBracket
          dw s_BackSlash
          dw s_RBracket
          dw s_Carot
          dw s_UnderLine

FontData      = *
s_Space	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000

s_Exclaim	hex 000FF000
	hex 000FF000
	hex 000FF000
	hex 000FF000
	hex 00000000
	hex 000FF000

s_Quote	hex 0FF00FF0
	hex 00F000F0
	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000

s_Number	hex 00000000
	hex 00F00F00
	hex 0FFFFFF0
	hex 00F00F00
	hex 0FFFFFF0
	hex 00F00F00

s_Dollar	hex 000F0F00
	hex 00FFFFF0
	hex 0F0F0F00
	hex 00FFFF00
	hex 000F0FF0
	hex 0FFFFF00

s_Percent	hex 0FF000F0
	hex 00000F00
	hex 0000F000
	hex 000F0000
	hex 00F00000
	hex 0F000FF0

s_Amper	hex 000FF000
	hex 00F00F00
	hex 0F00F000
	hex 00F000F0
	hex 0F0FFF00
	hex 00F0F000

s_Single	hex 000FF000
	hex 0000F000
	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000

s_OpenParen	hex 000FF000
	hex 00FF0000
	hex 0FF00000
	hex 0FF00000
	hex 00FF0000
	hex 000FF000

s_CloseParen	hex 000FF000
	hex 0000FF00
	hex 00000FF0
	hex 00000FF0
	hex 0000FF00
	hex 000FF000


s_Asterix	hex 00000000
	hex 00F0F0F0
	hex 000FFF00
	hex 00FFFFF0
	hex 000FFF00
	hex 00F0F0F0

s_Plus	hex 000F0000
	hex 000F0000
	hex 0FFFFF00
	hex 000F0000
	hex 000F0000
	hex 00000000

s_Comma	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000
	hex 0000FF00
	hex 0000F000

s_Minus	hex 00000000
	hex 00000000
	hex 0FFFFF00
	hex 00000000
	hex 00000000
	hex 00000000


s_Period	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000
	hex 0000FF00
	hex 0000FF00

s_Slash	hex 000000F0
	hex 00000F00
	hex 0000F000
	hex 000F0000
	hex 00F00000
	hex 0F000000

s_N0	hex 00FFFF00
	hex 0F000FF0
	hex 0F00F0F0
	hex 0F0F00F0
	hex 0FF000F0
	hex 00FFFF00

s_N1	hex 000F0000
	hex 00FF0000
	hex 000F0000
	hex 000F0000
	hex 000F0000
	hex 00FFF000

s_N2	hex 00FFFF00
	hex 0F0000F0
	hex 00000F00
	hex 000FF000
	hex 00F00000
	hex 0FFFFFF0

s_N3	hex 00FFFF00
	hex 000000F0
	hex 000FFF00
	hex 000000F0
	hex 000000F0
	hex 00FFFF00

s_N4	hex 0000FF00
	hex 000F0F00
	hex 00F00F00
	hex 0FFFFFF0
	hex 00000F00
	hex 00000F00

s_N5	hex 0FFFFFF0
	hex 0F000000
	hex 0FFFFF00
	hex 000000F0
	hex 0F0000F0
	hex 00FFFF00

s_N6	hex 000FFF00
	hex 00F00000
	hex 0F000000
	hex 0FFFFF00
	hex 0F0000F0
	hex 00FFFFF0

s_N7	hex 0FFFFFF0
	hex 000000F0
	hex 00000F00
	hex 0000F000
	hex 000F0000
	hex 000F0000

s_N8	hex 00FFFF00
	hex 0F0000F0
	hex 00FFFF00
	hex 0F0000F0
	hex 0F0000F0
	hex 00FFFF00

s_N9	hex 00FFFF00
	hex 0F0000F0
	hex 00FFFF00
	hex 0000F000
	hex 000F0000
	hex 00F00000

s_Colon	hex 000FF000
	hex 000FF000
	hex 00000000
	hex 000FF000
	hex 000FF000
	hex 00000000

s_Semi	hex 00000000
	hex 000FF000
	hex 000FF000
	hex 00000000
	hex 000FF000
	hex 000F0000

s_LAngle	hex 0000F000
	hex 000F0000
	hex 00F00000
	hex 000F0000
	hex 0000F000
	hex 00000000

s_Equal	hex 00000000
	hex 00000000
	hex 0FFFFF00
	hex 00000000
	hex 0FFFFF00
	hex 00000000

s_RAngle	hex 0000F000
	hex 00000F00
	hex 000000F0
	hex 00000F00
	hex 0000F000
	hex 00000000

s_Question	hex 00FFF000
	hex 0F000F00
	hex 00000F00
	hex 000FF000
	hex 00000000
	hex 000FF000

s_At	hex 00FFFF00
	hex 0F0000F0
	hex 0F00F0F0
	hex 0FFFF0F0
	hex 000000F0
	hex 0FFFFF00

s_A	hex 000FF000
	hex 00F00F00
	hex 0F0000F0
	hex 0FFFFFF0
	hex 0F0000F0
	hex 0F0000F0

s_B	hex 0FFFFF00
	hex 0F0000F0
	hex 0FFFFF00
	hex 0F0000F0
	hex 0F0000F0
	hex 0FFFFF00

s_C	hex 00FFFFF0
	hex 0F000000
	hex 0F000000
	hex 0F000000
	hex 0F000000
	hex 00FFFFF0

s_D	hex 0FFFFF00
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 0FFFFF00

s_E	hex 0FFFFFF0
	hex 0F000000
	hex 0FFFF000
	hex 0F000000
	hex 0F000000
	hex 0FFFFFF0

s_F	hex 0FFFFFF0
	hex 0F000000
	hex 0FFFF000
	hex 0F000000
	hex 0F000000
	hex 0F000000

s_G	hex 00FFFFF0
	hex 0F000000
	hex 0F000000
	hex 0F00FFF0
	hex 0F0000F0
	hex 00FFFF00

s_H	hex 0F0000F0
	hex 0F0000F0
	hex 0FFFFFF0
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0

s_I	hex 0FFFFF00
	hex 000F0000
	hex 000F0000
	hex 000F0000
	hex 000F0000
	hex 0FFFFF00

s_J	hex 000000F0
	hex 000000F0
	hex 000000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 00FFFF00

s_K	hex 0F000F00
	hex 0F00F000
	hex 0FFF0000
	hex 0F00F000
	hex 0F000F00
	hex 0F000F00

s_L	hex 0F000000
	hex 0F000000
	hex 0F000000
	hex 0F000000
	hex 0F000000
	hex 0FFFFFF0

s_M	hex 0F0000F0
	hex 0FF00FF0
	hex 0F0FF0F0
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0

s_N	hex 0F0000F0
	hex 0FF000F0
	hex 0F0F00F0
	hex 0F00F0F0
	hex 0F000FF0
	hex 0F0000F0

s_O	hex 00FFFF00
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 00FFFF00

s_P	hex 0FFFFF00
	hex 0F0000F0
	hex 0FFFFF00
	hex 0F000000
	hex 0F000000
	hex 0F000000

s_Q	hex 00FFFF00
	hex 0F0000F0
	hex 0F0000F0
	hex 0F00F0F0
	hex 0F000FF0
	hex 00FFFFF0

s_R	hex 0FFFFF00
	hex 0F0000F0
	hex 0FFFFF00
	hex 0F000F00
	hex 0F0000F0
	hex 0F0000F0

s_S	hex 00FFFFF0
	hex 0F000000
	hex 00FFFF00
	hex 000000F0
	hex 000000F0
	hex 0FFFFF00

s_T	hex 0FFFFF00
	hex 000F0000
	hex 000F0000
	hex 000F0000
	hex 000F0000
	hex 000F0000

s_U	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 00FFFF00

s_V	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 00F00F00
	hex 000FF000

s_W	hex 0F0000F0
	hex 0F0000F0
	hex 0F0000F0
	hex 0F0FF0F0
	hex 0FF00FF0
	hex 0F0000F0

s_X	hex 0F0000F0
	hex 00F00F00
	hex 000FF000
	hex 000FF000
	hex 00F00F00
	hex 0F0000F0

s_Y	hex F00000F0
	hex 0F000F00
	hex 00F0F000
	hex 000F0000
	hex 000F0000
	hex 000F0000

s_Z	hex 0FFFFFF0
	hex 00000F00
	hex 0000F000
	hex 000F0000
	hex 00F00000
	hex 0FFFFFF0

s_LBracket	hex 000FFF00
	hex 000F0000
	hex 000F0000
	hex 000F0000
	hex 000F0000
	hex 000FFF00

s_BackSlash	hex 0F000000
	hex 00F00000
	hex 000F0000
	hex 0000F000
	hex 00000F00
	hex 000000F0

s_RBracket	hex 00FFF000
	hex 0000F000
	hex 0000F000
	hex 0000F000
	hex 0000F000
	hex 00FFF000

s_Carot	hex 0000F000
	hex 000F0F00
	hex 00F000F0
	hex 00000000
	hex 00000000
	hex 00000000

s_UnderLine	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000
	hex FFFFFFF0

s_Template	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000
	hex 00000000

