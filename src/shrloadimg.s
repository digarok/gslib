****************************************
* SHRLOADIMG                           *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*               2013-07-21             *
****************************************

                    rel                         ; Compile
                    dsk   SHRLOADIMG.l          ; Save Name
                    typ   $B3
                    use   shrloadimg.m
                    mx    %00                   ; Program starts in 16-bit mode

****************************************
* Basic Error Macro                    *
****************************************
_Err                mac
                    bcc   NoErr
                    do    ]0                    ; (DO if true)
                    jsr   PgmDeath              ;  this is conditionally compiled if
                    str   ]1                    ;  we pass in an error statement
                    else                        ; (ELSE)
                    jmp   PgmDeath0             ;  we just call the simpler error handler
                    fin                         ; (FIN)
NoErr               eom


****************************************
* Program Start                        *
****************************************
                    phk                         ; Set Data Bank to Program Bank
                    plb                         ; Always do this first!


****************************************
* Typical tool startup                 *
****************************************
                    _TLStartUp                  ; normal tool initialization
                    pha
                    _MMStartUp
                    _Err                        ; should never happen
                    pla
                    sta   MasterId              ; our master handle references the memory allocated to us
                    ora   #$0100                ; set auxID = $01  (valid values $01-0f)
                    sta   UserId                ; any memory we request must use our own id

****************************************
* Initialize graphics                  *
****************************************
                    jsr   AllocOneBank          ; Alloc 64KB for Load/Unpack
                    sta   BankLoad              ; Store "Bank Pointer"

                    ldx   #ImageName            ; Load+Unpack Boot Picture
                    jsr   LoadPicture           ; X=Name, A=Bank to use for loading

                    lda   BankLoad              ; get address of loaded/uncompressed picture
                    clc
                    adc   #$0080                ; skip header?
                    sta   :copySHR+2            ;  and store that over the 'ldal' address below
                    ldx   #$7FFE                ; copy all image data
:copySHR            ldal  $000000,x             ; load from BankLoad we allocated
                    stal  $E12000,x             ; store to SHR screen
                    dex
                    dex
                    bpl   :copySHR

                    jsr   GraphicsOn

                    jsr   WaitKey

                    bra   Quit

ImageName           strl  '1/KFEST2013.PAK'
MasterId            ds    2
UserId              ds    2
BankLoad            hex   0000                  ; used for Load/Unpack

Quit                jsl   $E100A8               ; Prodos 16 entry point
                    da    $29                   ; Quit code
                    adrl  QuitParm              ; address of parameter table
                    bcs   Error                 ; never taken

Error               brk                         ; should never get here

QuitParm            adrl  $0000                 ; pointer to pathname (not used here)
                    da    $00                   ; quit type (absolute quite)

****************************************
* AllocOneBank                         *
* This is a custom allocation function *
* that makes use of the fact that we   *
* request an entire locked bank and so *
* simply returns the bank in the       *
* accumulator. (basically dereference  *
* the Handle to get the pointer)       *
****************************************
AllocOneBank        PushLong #0
                    PushLong #$10000
                    PushWord UserId
                    PushWord #%11000000_00011100
                    PushLong #0
                    _NewHandle                  ; returns LONG Handle on stack
                    plx                         ; base address of the new handle
                    pla                         ; high address 00XX of the new handle (bank)
                    xba                         ; swap accumulator bytes to XX00
                    sta   :bank+2               ; store as bank for next op (overwrite $XX00)
:bank               ldal  $000001,X             ; recover the bank address in A=XX/00
                    rts

****************************************
* Graphics Helpers                     *
****************************************
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

****************************************
* Turn on SHR mode                     *
****************************************
GraphicsOn          sep   #$30                  ; 8-bit mode
                    lda   #$C1
                    stal  $00C029               ; Turn on SHR mode
                    rep   #$30                  ; back to 16-bit mode
                    rts

WaitKey             sep   #$30
:wait               ldal  $00C000
                    bpl   :wait
                    stal  $00C010
                    rep   #$30
                    rts



****************************************
* Fatal Error Handler                  *
****************************************
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


****************************************
* Normal GSOS Quit                     *
****************************************
Exit                jsl   GSOS
                    dw    $2029
                    adrl  QuitGS


****************************************
* GS/OS / ProDOS 16 File Routines      *
****************************************
GSOS                =     $E100A8

LoadFile            stx   OpenGS+4              ; X=File, A=Bank/Page XX/00
                    sta   ReadGS+5

:openFile           jsl   GSOS                  ; Open File
                    dw    $2010
                    adrl  OpenGS
                    bcs   :openReadErr
                    lda   OpenGS+2
                    sta   GetEOFGS+2
                    sta   ReadGS+2

                    jsl   GSOS                  ; Get File Size
                    dw    $2019
                    adrl  GetEOFGS
                    lda   GetEOFGS+4
                    sta   ReadGS+8
                    lda   GetEOFGS+6
                    sta   ReadGS+10

                    jsl   GSOS                  ; Read File Content
                    dw    $2012
                    adrl  ReadGS
                    bcs   :openReadErr

:closeFile          jsl   GSOS                  ; Close File
                    dw    $2014
                    adrl  CloseGS
                    clc
                    lda   GetEOFGS+4            ; File Size
                    rts

:openReadErr        jsr   :closeFile
                    nop
                    nop

                    PushWord #0
                    PushLong #msgLine1
                    PushLong #msgLine2
                    PushLong #msgLine3
                    PushLong #msgLine4
                    _TLTextMountVol             ; actualname is TLTextMountVolume
                    pla
                    cmp   #1
                    bne   :loadFileErr
                    brl   :openFile
:loadFileErr        sec
                    rts

msgLine1            str   'Unable to load File'
msgLine2            str   'Press a key :'
msgLine3            str   ' -> Return to Try Again'
msgLine4            str   ' -> Esc to Quit'


OpenGS              dw    2                     ; pCount
                    ds    2                     ; refNum
                    adrl  ImageName             ; pathname

GetEOFGS            dw    2                     ; pCount
                    ds    2                     ; refNum
                    ds    4                     ; eof

ReadGS              dw    4                     ; pCount
                    ds    2                     ; refNum
                    ds    4                     ; dataBuffer
                    ds    4                     ; requestCount
                    ds    4                     ; transferCount

CloseGS             dw    1                     ; pCount
                    ds    2                     ; refNum

QuitGS              dw    2                     ; pCount
                    ds    4                     ; pathname
                    ds    2                     ; flags

