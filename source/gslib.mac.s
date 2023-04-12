* GSLIB APP HELPER MACROS


* NOISETRACKER MACROS

_NTStartUp          MAC
                    LDX   #$02DC
                    JSL   $E10000
                    <<<

*_NTInitMusic MAC
* <<<

_NTLaunchMusic      MAC
                    LDX   #$0ADC
                    JSL   $E10000
                    <<<

*_NTStartMusic MAC
* <<<

_NTStopMusic        MAC
                    LDX   #$0CDC
                    JSL   $E10000
                    <<<

_NTShutDown         MAC
                    LDX   #$03DC
                    JSL   $E10000
                    <<<


