*--------------------------------------*
* Graphics and Sound Library Example   *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2013-06-10                          *
*--------------------------------------*

                    rel
                    dsk   demo.sys16.l
                    typ   $B3
                    use   gslib.mac
                    use   skel.macgen
                    lst   off

*--------------------------------------*
* Basic Error Macro                    *
*--------------------------------------*
_Err                mac
                    bcc   NoErr
                    do    ]0                    ; (DO if true)
                    jsr   PgmDeath              ;  this is conditionally compiled if
                    str   ]1                    ;  we pass in an error statement
                    else                        ; (ELSE)
                    jmp   PgmDeath0             ;  we just call the simpler error handler
                    fin                         ; (FIN)
NoErr               eom

*--------------------------------------*
* Initialize environment               *
*--------------------------------------*
Start               clc
                    xce
                    rep   $30                   ; set full 16-bit mode

                    phk                         ; set bank - always do this at
                    plb                         ;  the beginning of a GSOS program

                    * tsc                         ; not sure about this?
                    * sec
                    * sbc   #$10
                    * tcs
                    * inc
                    * tcd


                    _TLStartUp                  ; normal tool initialization
                    pha
                    _MMStartUp
                    _Err                        ; should never happen
                    pla
                    sta   MasterId              ; our master handle references the memory allocated to us
                    ora   #$0100                ;
                    sta   UserId                ; any memory we request must use our own id



*--------------------------------------*
* Initialize graphics                  *
*--------------------------------------*
                    jsr   AllocOneBank          ; Alloc 64KB for Load/Unpack
                    sta   BankLoad              ; Store "Bank Pointer"

                    ldx   #ImageName            ; Load+Unpack Boot Picture
                    jsr   LoadPicture           ; X=Name, A=Bank to use for loading

                    jsr   AllocOneBank          ; Alloc 64KB for Sprite binary data
                    sta   BankSprite            ; Store "Bank Pointer"
                    sta   torusBank00+2

                    ldx   #Sprite00Name         ; Pointer to filename
                    lda   BankSprite            ; "Bank Pointer" to sprite memory
                    jsr   LoadFile              ;  Load File



*--------------------------------------*
* Initialize sound                     *
*--------------------------------------*

                    pea   #0220                 ; Tool220
                    pea   $0105                 ; Version Min
                    ldx   #$0F01                ; LoadOneTool
                    jsl   $E10000
                    _Err  "Tool220 (min v1.05) not Found! : $"

                    PushLong #0                 ; Allocate Direct Page in Bank 00
                    PushLong #$000100
                    PushWord UserId
                    PushWord #$C001             ; Allocation parms
                    PushLong #0
                    _NewHandle
                    _Err  "Can't Allocate ZPage! : $"
                    pla
                    sta   $00
                    pla
                    sta   $02

                    lda   [$00]                 ; PageZero
                    pha
                    _NTStartUp
                    _Err

                    lda   #ModuleName
                    ldx   #^ModuleName
                    jsr   ReadFile
                    _Err  "Module Not Found! : $"

                    pei   $06                   ; ^@ModuleAdr
                    pei   $04                   ;  @ModuleAdr (Must be Page aligned !!!)
                    ldx   #$09DC                ; NTInitMusic
                    jsl   $E10000
                    _Err

                    _NTLaunchMusic
                    _Err

                                                ;; here?
                    jsr   StartGraphicMode      ; Display Graphic Page, activate Shadowing...

                    lda   BankLoad              ; Display Boot Picture
                    clc
                    adc   #$0080                ; offset by 128 bytes?
                    jsr   FadeIn                ; A=XX/YY00 of the image
                                                ;; to here


                    stal  $E1C010

MainLoop
:vbl                ldal  $E1C02E               ; vblank - move it
                    and   #$00FF
                    cmp   #$00D0
                    bne   :vbl



                    jsr   UpdateDemoState
                    jsr   HandleDemoState

                    pha
                    ldx   #$0BDC                ; NTUpdateSound
                    jsl   $E10000
                    _Err
                    pla                         ; EndOfMusic (0,1 or -1)

****

                    cmp   #1
                    bcs   EndMusic
                    jsr   MouseClick            ; Exit ?
                    bcs   EndMusic
                    ldal  $E1BFFF
                    bpl   MainLoop

EndMusic            jsr   ExitGraphic
                    _NTStopMusic
                    _Err
                    _NTShutDown
                    _Err
                    lda   UserId
                    pha
                    ldx   #$1102                ; Dispose All
                    jsl   $E10000
                    _Err
                    lda   MasterId
                    pha
                    _MMShutDown
                    _Err

                    jsl   $E100A8
                    da    $0029
                    adrl  QuitParm

QuitParm            da    0
                    adrl  0
                    da    0

MasterId            ds    2
UserId              ds    2

ExitGraphic         lda   #$0
                    ldx   #$7cfe
:loop               stal  $e12000,x
                    dex
                    dex
                    bpl   :loop
                    lda   #Str9
                    ldx   #0
                    jsr   DrawString
                    rts

DemoCounter         hex   0000
RepeatIndex         hex   0000                  ; stupid frame skip mechanism
TorusLoc1           equ   #160*70+5+$2000
TorusLoc2           equ   #160*70+14+$2000
TorusLoc3           equ   #160*70+22+$2000

Torii               dw    #07
TorusLocs           dw    #160*70+5+$2000+10
                    dw    #160*70+25+$2000+10
                    dw    #160*70+45+$2000+10
                    dw    #160*70+65+$2000+10
                    dw    #160*70+85+$2000+10
                    dw    #160*70+105+$2000+10
                    dw    #160*70+125+$2000+10
TorusFrames         dw    #00
                    dw    #10
                    dw    #08
                    dw    #16
                    dw    #20
                    dw    #30
                    dw    #44



UndrawTorii
                    ldx   Torii
:nextUndraw         dex                         ;switch natural number to 0-index
                    phx

                    txa
                    asl
                    tax
                    lda   TorusLocs,x
                    tay
                    lda   #60
                    jsr   Drawtorus             ;blackout
                    plx
                    cpx   #$0                   ;done?
                    bne   :nextUndraw
                    rts

DrawTorii
                    ldx   Torii
:next               dex                         ;switch natural number to 0-index
                    phx

                    txa
                    asl
                    tax
                    lda   TorusLocs,x
                    tay
                    lda   TorusFrames,x
                    jsr   Drawtorus
                    plx
                    cpx   #$0                   ;done drawing all torii
                    bne   :next
                    rts

UpdateTorii
                    ldy   Torii
:nextUpdate         dey                         ;switch natural number to 0-index

                    tya
                    asl
                    tax
                    lda   TorusFrames,x
                    inc
                    cmp   #60                   ;reset frame counter
                    bne   :not
                    lda   #$0
:not                sta   TorusFrames,x

                    cpy   #$0
                    bne   :nextUpdate
                    rts

UpdateSprite
                    jsr   UndrawTorii

                    jsr   DrawTorii

                    inc   RepeatIndex           ; ghetto fram skip
                    lda   RepeatIndex
                    cmp   #04
                    bne   :noAdvance
                    stz   RepeatIndex
                                                ;; do stuff
                    jsr   UpdateTorii
:noAdvance
:done               rts


ScrollTop           equ   $e12000+#160*80
Scroll
                    ldx   #$00
                    ldy   #158
:scloop             ldal  ScrollTop+2,x         ;#80*160
                    stal  ScrollTop,x
                    ldal  ScrollTop+2+160,x     ;2
                    stal  ScrollTop+160,x
                    ldal  ScrollTop+2+320,x     ;3
                    stal  ScrollTop+320,x
                    ldal  ScrollTop+2+480,x     ;4
                    stal  ScrollTop+480,x
                    ldal  ScrollTop+2+640,x     ;5
                    stal  ScrollTop+640,x
                    ldal  ScrollTop+2+800,x     ;6
                    stal  ScrollTop+800,x
* ldal ScrollTop+2+960,x ;7
* stal ScrollTop+960,x
* ldal ScrollTop+2+1120,x ;7
* stal ScrollTop+1120,x
* ldal ScrollTop+2+1280,x ;7
* stal ScrollTop+1280,x
* ldal ScrollTop+2+1440,x ;7
* stal ScrollTop+1440,x
* ldal ScrollTop+2+1600,x ;7
* stal ScrollTop+1600,x
* ldal ScrollTop+2+1760,x ;7
* stal ScrollTop+1760,x
* ldal ScrollTop+2+1920,x ;7
* stal ScrollTop+1920,x
* ldal ScrollTop+2+2080,x ;7
* stal ScrollTop+2080,x
* ldal ScrollTop+2+2240,x ;7
* stal ScrollTop+2240,x
* ldal ScrollTop+2+2400,x ;7
* stal ScrollTop+2400,x
* ldal ScrollTop+2+2560,x ;7
* stal ScrollTop+2560,x
* ldal ScrollTop+2+2720,x ;7
* stal ScrollTop+2720,x
* ldal ScrollTop+2+2880,x ;7
* stal ScrollTop+2880,x
* ldal ScrollTop+2+3040,x ;7
* stal ScrollTop+3040,x
                    inx
                    inx
                    dey
                    dey
                    beq   :done
                    brl   :scloop
:done               rts



ReadFile            sta   Parm0
                    stx   Parm0+2
                    jsl   $E100A8
                    da    $10                   ; Open
                    adrl  Params
                    bcc   *+3
                    rts
                    jsl   $E100A8
                    da    $19
                    adrl  Params
                    bcc   No_ErrGetEof
                    pha
                    jsr   Go_Close
                    pla
                    sec
                    rts
No_ErrGetEof        pha
                    pha
                    lda   Parm0+2
                    sta   Parm1+2
                    pha
                    lda   Parm0
                    sta   Parm1
                    pha
                    lda   UserId
                    pha
                    pea   $C00C                 ; Page Aligned!!!
                    pea   $0
                    pea   $0
                    ldx   #$0902                ; NewHandle
                    jsl   $E10000
                    _Err  "Out Of Memory Error! : $"
                    pla
                    sta   $00
                    pla
                    sta   $02
                    ldy   #2
                    lda   [$00],Y
                    sta   Parm0+2
                    tax
                    lda   [$00]
                    sta   Parm0
                    sta   $04
                    stx   $06
                    jsl   $E100A8
                    da    $12                   ; Read
                    adrl  Params
                    bcc   Go_Close
                    pha
                    pei   $02                   ; Free mem
                    pei   $00
                    ldx   #$1002                ; Dispose
                    jsl   $E10000
                    _Err
                    jsr   Go_Close
                    pla
                    sec
                    rts
Go_Close            jsl   $E100A8
                    da    $14                   ; Close
                    adrl  Params
                    rts

Params              da    0
Parm0               adrl  0
Parm1               adrl  0
                    adrl  0

*-------------------------------------------------
PgmDeath            tax
                    pla
                    inc
                    phx
                    phk
                    pha
                    bra   ContDeath
PgmDeath0           pha
                    pea   $0000
                    pea   $0000
ContDeath           ldx   #$1503
                    jsl   $E10000

** SPRITE / PIC / MEMORY STUFF

BankLoad            hex   0000                  ; used for Load/Unpack
BankSprite          hex   0000
StackAddress        hex   0000
ImageName           strl  '1/KFEST2013B.PAK'
Sprite00Name        strl  '1/torus00.bin'
ModuleName          str   'SONG3.NT'             ; Module to be played

*****
* NEW NEW NEW
* NEWNEW
*****

Str1                str   'GREETINGS FROM KANSASFEST' ;30
Str2                str   'GREETINGS TO OZKFEST' ;40
Str3                str   'SORRY IT',27,'S NOT A BIGGER DEMO' ;24

Str4                str   'THANKS TO BRUTAL DELUXE' ;34
Str6                str   'THANKS TO KFEST STAFF & ATTENDEES!' ;14
Str5                str   'MEGA THANKS TO YOU THE VIEWER!!' ;26
Str7                str   'OK... I',27,'M TIRED  ;)' ;42
Str8                str   'DIGAROK - 2013'       ;52
Str9                str   'THAT',27,'S ALL FOLKS'

MODE_NOP            equ   0000
MODE_TORUS          equ   0001
MODE_STR1           equ   0002
MODE_STR2           equ   0003
MODE_SCROLL         equ   0009

MODE                dw    0000
seconds             equ   #60

UpdateDemoState
                    inc   DemoCounter
                    lda   DemoCounter


* Draw Str1
                    cmp   #3*seconds-5
                    bne   :next1
                    lda   #Str1                 ;draw str1 @ 2 second
                    ldx   #80*160+30
                    jsr   DrawString
                    lda   #MODE_NOP
                    sta   MODE
                    rts

:next1              cmp   #5*seconds-20         ;start scroll at 3 second
                    bne   :next2
                    lda   #MODE_SCROLL
                    sta   MODE
                    rts

:next2              cmp   #7*seconds            ;draw torii
                    bne   :next3a
                    lda   #MODE_TORUS
                    sta   MODE
                    rts
:next3a             cmp   #14*seconds
                    bne   :next3

                    lda   #MODE_NOP
                    sta   MODE
                    jsr   UndrawTorii
                    rts

:next3              cmp   #15*seconds+30        ;second message
                    bne   :next4

                    lda   #Str2                 ;draw str1 @ 2 second
                    ldx   #80*160+40
                    jsr   DrawString
                    rts

:next4              cmp   #18*seconds+30        ;scroll off message
                    bne   :next5
                    lda   #MODE_SCROLL
                    sta   MODE
                    rts

:next5              cmp   #20*seconds
                    bne   :next6

                    lda   #Str3
                    ldx   #80*160+24
                    jsr   DrawString
                    lda   #MODE_NOP
                    sta   MODE
                    rts

:next6              cmp   #22*seconds
                    bne   :next7
                    lda   #MODE_SCROLL
                    sta   MODE
                    rts
:next7              cmp   #23*seconds+30        ;draw torii
                    bne   :next8a
                    lda   #MODE_TORUS
                    sta   MODE
                    rts
:next8a             cmp   #26*seconds+45
                    bne   :next8
                    jsr   UndrawTorii
                    lda   #MODE_NOP
                    sta   MODE
                    rts


:next8
                    cmp   #27*seconds
                    bne   :next8scroll
                    lda   #Str4
                    ldx   #80*160+34
                    jsr   DrawString
                    rts
:next8scroll
                    cmp   #29*seconds
                    bne   :next9
                    lda   #MODE_SCROLL
                    sta   MODE
                    rts

:next9
                    cmp   #30*seconds+30
                    bne   :next9scroll
                    lda   #Str5
                    ldx   #80*160+14
                    jsr   DrawString
                    lda   #MODE_NOP
                    sta   MODE
                    rts
:next9scroll
                    cmp   #33*seconds
                    bne   :next10
                    lda   #MODE_SCROLL
                    sta   MODE
                    rts


:next10
                    cmp   #34*seconds+30
                    bne   :next10scroll
                    lda   #Str6
                    ldx   #80*160+20
                    jsr   DrawString
                    lda   #MODE_NOP
                    sta   MODE
                    rts
:next10scroll
                    cmp   #36*seconds
                    bne   :next11
                    lda   #MODE_SCROLL
                    sta   MODE
                    rts


:next11
                    cmp   #37*seconds+30
                    bne   :next11scroll
                    lda   #Str7
                    ldx   #80*160+42
                    jsr   DrawString
                    lda   #MODE_NOP
                    sta   MODE
                    rts
:next11scroll
                    cmp   #40*seconds
                    bne   :next12
                    lda   #MODE_SCROLL
                    sta   MODE
                    rts

:next12
                    cmp   #41*seconds+30
                    bne   :next12scroll
                    lda   #Str8
                    ldx   #80*160+52
                    jsr   DrawString
                    lda   #MODE_NOP
                    sta   MODE
                    rts
:next12scroll
                    cmp   #46*seconds
                    bne   :next13
                    lda   #MODE_SCROLL
                    sta   MODE
                    rts
:next13
                    cmp   #48*seconds+30
                    bne   :next14
                    lda   #MODE_TORUS
                    sta   MODE
:next14
                    rts

HandleDemoState
                    lda   MODE
                    cmp   #MODE_NOP
                    bne   :next1
                    rts

:next1              cmp   #MODE_TORUS
                    bne   :next2
                    jsr   UpdateSprite          ;does whole torus line.  get it? haahah
                    rts

:next2              cmp   #MODE_SCROLL
                    bne   :next3
                    jsr   Scroll

                    rts

:next3
                    rts




*--------------------------------------*
* GS/OS File Loading Routines          *
*--------------------------------------*
GSOS                =     $E100A8

LoadFile            stx   gsosOPEN+4            ; X=File, A=Bank XX/00
                    sta   gsosREAD+5

:openFile           jsl   GSOS                  ; Open File
                    dw    $2010
                    adrl  gsosOPEN
                    bcs   :openReadErr
                    lda   gsosOPEN+2
                    sta   gsosGETEOF+2
                    sta   gsosREAD+2

                    jsl   GSOS                  ; Get File Size
                    dw    $2019
                    adrl  gsosGETEOF
                    lda   gsosGETEOF+4
                    sta   gsosREAD+8
                    lda   gsosGETEOF+6
                    sta   gsosREAD+10

                    jsl   GSOS                  ; Read File Content
                    dw    $2012
                    adrl  gsosREAD
                    bcs   :openReadErr

:closeFile          jsl   GSOS                  ; Close File
                    dw    $2014
                    adrl  gsosCLOSE
                    clc
                    lda   gsosGETEOF+4          ; File Size
                    rts

:openReadErr        jsr   :closeFile
                    nop
                    nop

                    PushWord #0
                    PushLong #msgLine1
                    PushLong #msgLine2
                    PushLong #msgLine3
                    PushLong #msgLine4
                                                ; _TLTextMountVolume
                                                ; TODO
                    pla
                    cmp   #1
                    bne   LF_Err1
                    brl   :openFile
LF_Err1             sec
                    rts

msgLine1            str   'Unable to load File'
msgLine2            str   'Press a key :'
msgLine3            str   ' -> Return to Try Again'
msgLine4            str   ' -> Esc to Quit'

*-------

Exit                jsl   GSOS
                    dw    $2029
                    adrl  gsosQUIT

*-------

gsosOPEN            dw    2                     ; pCount
                    ds    2                     ; refNum
                    adrl  ImageName             ; pathname

gsosGETEOF          dw    2                     ; pCount
                    ds    2                     ; refNum
                    ds    4                     ; eof

gsosREAD            dw    4                     ; pCount
                    ds    2                     ; refNum
                    ds    4                     ; dataBuffer
                    ds    4                     ; requestCount
                    ds    4                     ; transferCount

gsosCLOSE           dw    1                     ;  pCount
                    ds    2                     ;  refNum

gsosQUIT            dw    2                     ; pCount
                    ds    4                     ; pathname
                    ds    2                     ; flags



*--------------------------------------*
* Graphics Helpers                     *
*--------------------------------------*
LoadPicture         jsr   LoadFile              ; X=Nom Image, A=Banc de chargement XX/00
                    bcc   :loadOK
                    brl   Exit
:loadOK             jsr   UnpackPicture         ; A=Packed Size
                    rts


UnpackPicture       sta   UP_PackedSize         ; Size of Packed Data
                    lda   #$8000                ; Size of output Data Buffer
                    sta   UP_UnPackedSize
                    lda   BankLoad              ; Banc de chargement / Decompression
                    sta   UP_Packed+1           ; Packed Data
                    clc
                    adc   #$0080
                    stz   UP_UnPacked           ; On remet a zero car modifie par l'appel
                    stz   UP_UnPacked+2
                    sta   UP_UnPacked+1         ; Unpacked Data buffer

                    PushWord #0                 ; Space for Result : Number of bytes unpacked
                    PushLong UP_Packed          ; Pointer to buffer containing the packed data
                    PushWord UP_PackedSize      ; Size of the Packed Data
                    PushLong #UP_UnPacked       ; Pointer to Pointer to unpacked buffer
                    PushLong #UP_UnPackedSize   ; Pointer to a Word containing size of unpacked data
                    _UnPackBytes
                    pla                         ; Number of byte unpacked
                    rts

UP_Packed           hex   00000000              ; Address of Packed Data
UP_PackedSize       hex   0000                  ; Size of Packed Data
UP_UnPacked         hex   00000000              ; Address of Unpacked Data Buffer (modified)
UP_UnPackedSize     hex   0000                  ; Size of Unpacked Data Buffer (modified)

*--------------------------------------*
* Misc Graphics  Subroutines           *
*--------------------------------------*
StartGraphicMode    sep   #$30
                    lda   #$41                  ; Linearise la page graphique
                    stal  $00C029
                    rep   #$30

                    ldx   #$7FFE                ; Efface l'Ecran
                    lda   #$0000
SGM_1               stal  $E12000,X
                    dex
                    dex
                    bpl   SGM_1

                    sep   #$30

                    lda   #$F0                  ; Fond Noir
                    stal  $00C022
                    lda   #$00
                    stal  $00C034               ; Bordure Noire

                    lda   #$A1                  ; Affiche la page graphique
                    stal  $00C029

                    lda   #$00                  ; Active le Shadowing
                    stal  $00C035
                    rep   #$30
                    rts

*--------------

FadeIn              sta   FI_00+2               ; A=XX/YY00 de l'image
                    clc
                    adc   #$007E
                    sta   FI_3+2
                    sta   FI_5+2
                    sta   FI_7+2

                    ldx   #$01FE
                    lda   #$0000                ; NETTOYAGE PREALABLE DES PALETTES en $01/2000
FI_0                stal  $019E00,X
                    dex
                    dex
                    bpl   FI_0

                    ldx   #$7DFE                ; RECOPIE LES POINTS + SCB en $01/2000
FI_00               ldal  $000000,X
                    stal  $012000,X
                    dex
                    dex
                    bpl   FI_00

                    ldy   #$000F                ; ON FAIT UN FADE IN SUR LES 16 PALETTES
FI_1                ldx   #$01FE

FI_2                ldal  $019E00,X             ; COMPOSANTE BLEUE
                    and   #$000F
                    sta   FI_33+1
FI_3                ldal  $06FE00,X
                    and   #$000F
FI_33               cmp   #$0000
                    beq   FI_4
                    ldal  $019E00,X
                    clc
                    adc   #$0001
                    stal  $019E00,X

FI_4                ldal  $019E00,X             ; COMPOSANTE VERTE
                    and   #$00F0
                    sta   FI_55+1
FI_5                ldal  $06FE00,X
                    and   #$00F0
FI_55               cmp   #$0000
                    beq   FI_6
                    ldal  $019E00,X
                    clc
                    adc   #$0010
                    stal  $019E00,X

FI_6                ldal  $019E00,X             ; COMPOSANTE ROUGE
                    and   #$0F00
                    sta   FI_77+1
FI_7                ldal  $06FE00,X
                    and   #$0F00
FI_77               cmp   #$0000
                    beq   FI_8
                    ldal  $019E00,X
                    clc
                    adc   #$0100
                    stal  $019E00,X

FI_8                dex
                    dex
                    bpl   FI_2
                    jsr   WaitForVBL            ; TEMPO
                    jsr   WaitForVBL
                    dey
                    bpl   FI_1
                    rts

*--------------

FadeOut             ldy   #$000F                ; Fade Out de l'Ecran 01/2000
FO_0                ldx   #$01FE

FO_1                ldal  $E19E00,X             ; COMPOSANTE BLEUE
                    and   #$000F
                    beq   FO_2
                    ldal  $E19E00,X
                    sec
                    sbc   #$0001
                    stal  $E19E00,X

FO_2                ldal  $E19E00,X             ; COMPOSANTE VERTE
                    and   #$00F0
                    beq   FO_3
                    ldal  $E19E00,X
                    sec
                    sbc   #$0010
                    stal  $E19E00,X

FO_3                ldal  $E19E00,X             ; COMPOSANTE ROUGE
                    and   #$0F00
                    beq   FO_4
                    ldal  $E19E00,X
                    sec
                    sbc   #$0100
                    stal  $E19E00,X

FO_4                dex
                    dex
                    bpl   FO_1
                    dey
                    jsr   WaitForVBL            ; TEMPO
                    jsr   WaitForVBL
                    bpl   FO_0
                    rts

*--------------

WaitForVBL          sep   #$30                  ; Wait fr VBL
:wait1              ldal  $00C019
                    bmi   :wait1
:wait2              ldal  $00C019
                    bpl   :wait2
                    rep   #$30
                    rts



*--------------------------------------*
* Misc Subroutines and helpers         *
*--------------------------------------*
WaitForKey          sep   #$30
:wait               ldal  $00c000
                    bpl   :wait
                    stal  $00c010
                    rep   #$30
                    rts


MouseClick          clc                         ; BOUTON SOURIS ENFONCE ?
                    ldal  $E0C026
                    bmi   MC_1
                    rts
MC_1                ldal  $E0C023
                    ldal  $E0C023
                    bpl   MC_2
                    rts
MC_2                sec
                    rts


*--------------------------------------*
* Memory allocation routines           *
*--------------------------------------*

*--------------------------------------*
* AllocOneBank                         *
* This is a custom allocation function *
* that makes use of the fact that we   *
* request an entire locked bank and so *
* simply returns the bank in the       *
* accumulator. (basically dereference  *
* the Handle to get the pointer)       *
*--------------------------------------*
AllocOneBank        PushLong #0
                    PushLong #$10000
                    PushWord UserId
                    PushWord #%11000000_00011100
                    PushLong #0
                    _NewHandle                  ; returns LONG Handle on stack
                    plx                         ; base address of the new handle
                    pla                         ; high address 00XX of the new handle (bank)
                    xba                         ; swab accumulator bytes to XX00
                    sta   :bank+2               ; store as bank for next op (overwrite $XX00)
:bank               ldal  $000001,X             ; recover the bank address in A=XX/00
                    rts

*--------------------------------------*
* Subroutine Includes                  *
*--------------------------------------*
                    use   TORUS
                    use   FONT

                    lst   on
