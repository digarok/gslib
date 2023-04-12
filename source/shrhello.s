****************************************
* SHRHELLO                             *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2013-07-21                          *
****************************************

                rel                         ; Compile
                dsk   SHRHello.Sys16        ; Save Name
                typ   $B3                   ; S16, GS/OS Application
                mx    %00
                phk                         ; Set Data Bank to Program Bank
                plb                         ; Always do this first!

                lda   #$0FFF                ; WHITE color
                ldx   #$000F                ; palette index 1 (NOT zero)
                jsr   SetPaletteColor
                lda   #$0589                ; other color
                ldx   #$0001                ; palette index 1 (NOT zero)
                jsr   SetPaletteColor
                lda   #$0000
                jsr   SetSCBs               ; set all SCBs to 00 (320 mode, pal 0, no fill, no interrupt)
                jsr   GraphicsOn


                lda   #$0000                ; clear screen to color 0 and turn on SHR graphics
                jsr   ClearToColor
                lda   #HelloStr
                ldx   #60*160+30
                jsr   DrawString
                jsr   WaitKey

                lda   #$1111                ; clear screen to color 1
                jsr   ClearToColor
                lda   #HelloStr
                ldx   #60*160+30
                jsr   DrawString
                jsr   WaitKey



                jsl   $E100A8               ; Prodos 16 entry point
                da    $29                   ; Quit code
                adrl  QuitParm              ; address of parameter table
                bcs   Error                 ; never taken

Error           brk                         ; should never get here

QuitParm        adrl  $0000                 ; pointer to pathname (not used here)
                da    $00                   ; quit type (absolute quite)

HelloStr        str   'HELLO KANSASFEST'

****************************************
* Turn on SHR mode                     *
****************************************
GraphicsOn      sep   #$30                  ;8-bit mode
                lda   #$81                  ;%1000 0001
                stal  $00C029               ;Turn on SHR mode
                rep   #$30                  ;back to 16-bit mode
                rts

****************************************
* A= color values (0RGB)               *
* X= color/palette offset              *
*   (0-F = pal0, 10-1F = pal1, etc.)   *
****************************************
SetPaletteColor pha                         ;save accumulator
                txa
                asl                         ;X*2 = real offset to color table
                tax
                pla
                stal  $E19E00,x             ;palettes are stored from $E19E00-FF
                rts                         ;yup, that's it

****************************************
* A= color values (0RGB)               *
****************************************
ClearToColor    ldx   #$7D00                ;start at top of pixel data! ($2000-9D00)
:clearloop      dex
                dex
                stal  $E12000,x             ;screen location
                bne   :clearloop            ;loop until we've worked our way down to 0
                rts

SetSCBs         ldx   #$0100                ;set all $100 scbs to A
:scbloop        dex
                dex
                stal  $E19D00,x
                bne   :scbloop
                rts

WaitKey         sep   #$30
:wait           ldal  $00c000
                bpl   :wait
                stal  $00c010
                rep   #$30
                rts

                use   FONT                  ;include our font library
