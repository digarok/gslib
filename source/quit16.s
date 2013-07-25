****************************************
* Quit16                               *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2013-06-10                          *
****************************************

	rel	; compile as relocatable code 
	dsk Quit16.l	; Save Name

	phk	; Set Data Bank to Program Bank
	plb	; Always do this first!

	jsl $E100A8	; Prodos 16 entry point
	da $29	; Quit code
	adrl QuitParm	; address of parameter table
	bcs Error	; never taken

Error	brk	; should never get here

QuitParm	adrl $0000	; pointer to pathname (not used here)
	da $00	; quit type (absolute quit)




