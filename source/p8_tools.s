                  org   $2000                   ; start at $2000 (all ProDOS8 system files)
                  mx    %11
                  clc
                  xce
                  rep   #$30

                  jsr   PrepareTools
                  jsr   P8Quit

******************************************
* Call this at the start of your program *
******************************************
                  mx    %00
PrepareTools      stz   MasterId                ; I haven't created a new user ID
                  _TLStartUp
                  pha
                  _MMStartUp
                  pla
                  bcc   MM_OK
* If the Memory Manager reported an error, we need to allocate our own memory first.
                  _MTStartUp
* First we need a user ID.
                  pha
                  pea   $1000
                  _GetMasterId                  ; Get me a new user ID (Application)
                  pla
                  sta   MasterId                ; Save it for later
* Now give us all of bank zero and bank one.
                  pha
                  pha                           ; Result space
                  pea   $0000
                  pea   $B800                   ; Block size
                  lda   MasterId
                  pha                           ; User ID
                  pea   $C002                   ; Attributes: locked, fixed, absolute
                  pea   $0000
                  pea   $0800                   ; Location (bank 0, $0800-$BFFF)
                  _NewHandle
                  plx
                  ply
                  _Err                          ; This shouldn't happen!
                  sty   Bnk0Hnd
                  stx   Bnk0Hnd+2               ; Save handle to bank 0 memory
                  pha
                  pha                           ; Result space
                  pea   $0000
                  pea   $B800                   ; Block size
                  lda   MasterId
                  pha                           ; User ID
                  pea   $C002                   ; Attributes: locked, fixed, absolute
                  pea   $0001
                  pea   $0800                   ; Location (bank 1, $0800-$BFFF)
                  _NewHandle
                  plx
                  ply
                  _Err                          ; This shouldn't happen!
                  sty   Bnk1Hnd
                  stx   Bnk1Hnd+2               ; Save handle to bank 0 memory
* We have the necessary memory protected.  Start up the memory manager again.
                  pha
                  _MMStartUp
                  pla
                  _Err                          ; This shouldn't happen!
MM_OK             sta   UserId                  ; Save the memory ID
                  rts

******************************************
* Basic Error Macro                      *
******************************************
_Err              mac
                  bcc   NoErr
                  do    ]0                      ; (DO if true)
                  jsr   PgmDeath                ;  this is conditionally compiled if
                  str   ]1                      ;  we pass in an error statement
                  else                          ; (ELSE)
                  jmp   PgmDeath0               ;  we just call the simpler error handler
                  fin                           ; (FIN)
NoErr             eom

****************************************
* Fatal Error Handler                  *
****************************************
PgmDeath          tax
                  pla
                  inc
                  phx
                  phk
                  pha
                  bra   ContDeath
PgmDeath0         pha
                  pea   $0000
                  pea   $0000
ContDeath         ldx   #$1503
                  jsl   $E10000


******************************************
* Standard ProDOS 8 Quit routine         *
******************************************
                  mx    %11
P8Quit            jsr   MLI                     ; first actual command, call ProDOS vector
                  dfb   $65                     ; with "quit" request ($65)
                  da    QuitParm
                  bcs   Error                   ; what's the point?  ;)
Error             brk   $00                     ; shouldn't ever  here!

QuitParm          dfb   4                       ; number of parameters
                  dfb   0                       ; standard quit type
                  da    $0000                   ; not needed when using standard quit
                  dfb   0                       ; not used
                  da    $0000                   ; not used

******************************************
* ToolCall Macros                        *
******************************************
Tool              MAC
                  LDX   #]1
                  JSL   $E10000
                  <<<
_TLStartUp        MAC
                  Tool  $201
                  <<<
_TLShutDown       MAC
                  Tool  $301
                  <<<
_NewHandle        MAC
                  Tool  $902
                  <<<
_MMStartUp        MAC
                  Tool  $202
                  <<<
_GetMasterId      MAC
                  Tool  $2003
                  <<<
_MTStartUp        MAC
                  Tool  $203
                  <<<

MasterId          ds    2
UserId            ds    2
BankLoad          hex   0000                    ; used for Load/Unpack
Bnk0Hnd           hex   00000000
Bnk1Hnd           hex   00000000
MLI               equ   $bf00

                  dsk   p8_tools.system
