Drawtorus           ASL                         ; A=Sprite Number ($0000-$003C)
                    TAX                         ; Y=Target Screen Address ($2000-$9D00)
                    LDA   torusNum,X            ; Relative Sprite Number Table
                    JMP   (torusBank,X)         ; Bank Number Table

torusNum            HEX   1600,1400,0E00,1300,0400,0100,0600,1200
                    HEX   0200,0F00,0800,1800,1700,1F00,1E00,2200
                    HEX   2700,2600,3000,2D00,3600,3500,3C00,3700
                    HEX   3100,2F00,2800,2300,2000,1500,1000,0700
                    HEX   0C00,0D00,0300,0000,0500,0B00,0A00,0900
                    HEX   1100,1A00,1900,1B00,1D00,2100,2A00,2400
                    HEX   2900,2C00,2E00,3300,3900,3B00,3800,3400
                    HEX   3200,2B00,2500,1C00,3A00

torusBank           DA    torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00
                    DA    torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00
                    DA    torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00
                    DA    torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00
                    DA    torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00
                    DA    torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00
                    DA    torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00,torusBank00
                    DA    torusBank00,torusBank00,torusBank00,torusBank00,torusBank00

torusBank00         JSL   $AA0000
                    PHK
                    PLB
                    RTS

*------------------------------------------------
