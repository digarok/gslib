****************************************
* Quit8                                *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2013-06-24                          *
****************************************

	org $2000	; start at $2000 (all ProDOS8 system files)
	dsk quit8.system ; tell compiler what name for output file
	typ $ff	; set P8 type ($ff = "SYS") for output file

MLI	equ $bf00



Quit	jsr MLI	; first actual command, call ProDOS vector
	dfb $65	; with "quit" request ($65)
	da QuitParm
	bcs Error
	brk $00	; shouldn't ever  here!

QuitParm	dfb 4	; number of parameters
	dfb 0	; standard quit type
	da $0000	; not needed when using standard quit
	dfb 0	; not used
	da $0000	; not used


Error	brk $00	; shouldn't be here either
