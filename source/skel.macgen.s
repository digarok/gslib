_TLStartUp          MAC
                    Tool  $201
                    <<<
_MMStartUp          MAC
                    Tool  $202
                    <<<
_MMShutDown         MAC
                    Tool  $302
                    <<<
_NewHandle          MAC
                    Tool  $902
                    <<<
_UnPackBytes        MAC
                    Tool  $2703
                    <<<
PushLong            MAC
                    IF    #=]1
                    PushWord #^]1
                    ELSE
                    PushWord ]1+2
                    FIN
                    PushWord ]1
                    <<<
PushWord            MAC
                    IF    #=]1
                    PEA   ]1
                    ELSE
                    IF    MX/2
                    LDA   ]1+1
                    PHA
                    FIN
                    LDA   ]1
                    PHA
                    FIN
                    <<<
Tool                MAC
                    LDX   #]1
                    JSL   $E10000
                    <<<
