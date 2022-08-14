****************************************
* SHR1                                 *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2013-07-17                          *
****************************************

                    rel                         ; Compile
                    dsk   SHR1.l                ; Save Name
                    typ   $B3
                    mx    %00                   ; Program starts in 16-bit mode

                    phk                         ; Set Data Bank to Program Bank
                    plb                         ; Always do this first!

GraphicsOn          sep   #$30                  ; 8-bit mode
                    lda   #$81
                    stal  $00C029               ; Turn on SHR mode
                    rep   #$30                  ; back to 16-bit mode

                    jsr   WaitKey               ; pause



ClearNaive          ldx   #$0000                ; Start at first pixel
                    lda   #$0000                ; store zeros
:clearloop          stal  $E12000,x             ; screen location
                    inx
                    inx
                    cpx   #$8000                ; see if we've filled entire frame/colors/scbs
                    bne   :clearloop            ; pause


                    jsr   WaitKey



ClearFaster         ldx   #$7FFE                ; start at top this time
                    lda   #$0000                ; store zeros
:clearloop          stal  $E12000,x             ; screen location
                    dex
                    dex
                                                ; avoid 16K "compare X's" for  80K cycle savings
                    bne   :clearloop            ; loop until we've worked our way down to 0
                    jsr   WaitKey


                    jsl   $E100A8               ; Prodos 16 entry point
                    da    $29                   ; Quit code
                    adrl  QuitParm              ; address of parameter table
                    bcs   Error                 ; never taken

Error               brk                         ; should never get here

QuitParm            adrl  $0000                 ; pointer to pathname (not used here)
                    da    $00                   ; quit type (absolute quite)

WaitKey             sep   #$30                  ; good old apple ii key wait routine
:wait               ldal  $00C000               ;  but called using long addressing modes
                    bpl   :wait                 ;  in 8-bit mode
                    stal  $00C010
                    rep   #$30
                    rts


