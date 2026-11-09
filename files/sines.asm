;sines.asm
;
;douglas irving repetto   april.97
;glmrboy@shoko.calarts.edu
;
;demonstrates:
;
;using the sci serial port for i/o
;using multiple table lookup oscillators
;simple mixing
;ring modulation
;
;on the motorola 56002EVM
;
;
;creates 4 sinewave oscillators using y:100 sine table in ROM
;pitch is controlled by:
;up = 1 2 3 4
;down = ! @ # $
;amplitude controlled by:
;up = q w e r
;down = Q W E R
;mode controlled by:
;mix = m
;ring mod (1x2 3x4) = M
;
;to use it:
;
;assemble sines.asm
;you need these files (they come with the EVM software):
;     ada_init.asm
;     txrx_isr.asm
;
;load and run sines.cld on the EVM
;switch to a terminal program
;make sure the terminal program's serial port is talking to the
;EVM's sci serial port
;use:
;1 start
;8 data
;1 stop
;no parity
;19200 baud
;
;
;you need to put some jumpers on the 56002EVM for the sci serial port to work:
;PC0 (J10)
;PC1 (J10)
;J8 - all four sets of pins should be jumpered in the same direction 
;
;you also need to solder a D connector the the host P5 space on the PC board
;P5 is the sci serial port




START   EQU     $40
SCR		EQU	$FFF0
SSR		EQU	$FFF1
SCCR	EQU	$FFF2
SRX		EQU	$FFF4
STX		EQU	$FFF4
RXBUF	EQU	$100
TXBUF	EQU	$200
NUMOSC	EQU	$4

		org		x:$10
storage
	ds	1
storage2
	ds	1
storage3
	ds	1
storage4
	ds	1
mode
	ds	1
oscil1
	ds	5
oscil2
	ds	5
oscil3
	ds	5
oscil4
	ds	5
	
        org     p:$0
        jmp     START

        org     p:$000c
        jsr     ssi_rx_isr      ;SSI receive data
        jsr     ssi_rx_isr      ;SSI receive data with exception
        jsr     ssi_tx_isr      ;SSI transmit data
        jsr     ssi_tx_isr      ;SSI transmit with exception

        org     p:START

        movep   #$261009,x:PLL  ;these labels are defined in the 
        movep   #0000,x:BCR     ;ada_init.asm program
        ori     #3,mr           ;mask interrupts
        movec   #0,sp           ;clear hardware stack pointer
        move    #04,omr          ;operating mode -use y:100 sinewave
        move    #$40,r6         ; initialise stack pointer
        move    #-1,m6          ; linear addressing

        include 'ada_init.asm'

TONE_OUTPUT     EQU     HEADPHONE_EN+LINEOUT_EN+(4*LEFT_ATTN)+(4*RIGHT_ATTN)
TONE_INPUT      EQU     MIC_IN_SELECT+(15*MONITOR_ATTN)

;INITIALIZE THE SCI PORT AND RX, TX BUFFER POINTERS   
		movep   #0,x:PCC ;turn off ssi/sci     
		MOVEP	#$f000,X:IPR	;set inturrupt priorities
		MOVEP	#$0302,X:SCR	;enable TX/RX, set 1,8,1
		MOVEP	#$0020,X:SCCR	;19200 baud
		MOVEP	#>$1eb,X:PCC  ;turn on ssi/sci

		bset	#0,x:mode	;start in mix mode
		move	#oscil1,R0 ;oscil1 data
		
		do		#NUMOSC,done1		;fill in oscilator tables
		move	#0,y0		
		move	y0,x:(R0)+	;freq
		move	#0.5,y0
		move	y0,x:(R0)+ ;amplitude  skip freq
		move	#0,y0
		move	y0,x:(R0)+ ;initial phase
		move	#>$80,y0
		move	y0,x:(R0)+ ;table/2
		move	#>$180,y0
		move	y0,x:(R0)+ ;middle of sine table
		
done1
		nop	

		move	#oscil1,R0	;put in initial freqs
		move	#0.02,y0
		move	y0,x:(R0)
		move	#oscil2,R0	
		move	#0.025,y0
		move	y0,x:(R0)
		move	#oscil3,R0	
		move	#0.01,y0
		move	y0,x:(R0)
		move	#oscil4,R0	
		move	#0.015,y0
		move	y0,x:(R0)
		
loop_1

		JSET	#$2,X:SSR,CHANGE	;jump when serial data received
        
        jset    #2,x:SSISR,*    ;wait for frame sync to pass
        jclr    #2,x:SSISR,*    ;wait for frame sync

        move    x:RX_BUFF_BASE,a        ;receive left
        move    x:RX_BUFF_BASE+1,b      ;receive right
    
        
        move	#oscil1,R0
        
        jsr		Oscillator
        asr		a
        move	a,x:storage
        
        jsr		Oscillator
        asr		a
        move	a,x:storage2
        
        jsr		Oscillator
        asr		a
        move	a,x:storage3
        
        jsr		Oscillator
        asr		a
        move	a,x:storage4
   
   		JCLR	#0,x:mode,MOD	;check for mode
        
MIX
        move	x:storage,x0
        move	x:storage2,a
        add		x0,a
        
        move	x:storage3,x0
        move	x:storage4,b
        add		x0,b
        jmp		OUTPUT
        
MOD
        move	x:storage,a
        move	x:storage2,x0
        move	a,y0
        mpy		x0,y0,a
        
        move	x:storage3,b
        move	x:storage4,x0
        move	b,y0
        mpy		x0,y0,b	
        
OUTPUT
        move    a,x:TX_BUFF_BASE        ;transmit left
        move    b,x:TX_BUFF_BASE+1      ;transmit right
        
        move    #TONE_OUTPUT,y0 ;set up control words
        move    y0,x:TX_BUFF_BASE+2
        move    #TONE_INPUT,y0
        move    y0,x:TX_BUFF_BASE+3

		nop
        jmp     loop_1


;---------------------------------------------------------------------------------------------------
;Arbitrary Waveform Oscillator - Non Interpolating 
;by phil burke
;modified by douglas repetto  april.97
;---------------------------------------------------------------------------------------------------
; (old)Accum: ( freq -- sample )
; accum: ( xxx -- sample )
; R0 = address of oscillator data record
				; 0 = phase  ( fractional , -1 to 1 is one wavelength )
				; 1 = size of table/2
				; 2 = address of middle of table
				; 3 = amplitude
				; 4 = frequency


Oscillator
	move	x:(r0)+,a		; put freq in a
	move	x:(r0)+,y0		; amplitude in y0
	MOVE	X:(R0),X1  		; add to phase
	ADD		X1,A			; add phase increment to phase
	MOVE	A1,X0			; clip to -1,1  , without limiting
	MOVE	X0,X:(R0)+		; update phase in memory
	MOVE	X:(R0)+,Y1		; get size/2
	MOVE	X:(R0)+,A		; calc offset of sample, get mid address
	MAC		Y1,X0,A			; sa = (size/2)*phase + size/2 + base
	MOVE	A1,R4			; move to address register, fraction in A0
	NOP
	MOVE	Y:(R4),x0		; get sample from Y memory
	mpy		y0,x0,a			; scale by amplitude
	RTS
	

CHANGE		;figure out what was received, and what to do about it . . .
			;pitch controlled by 1 2 3 4
			;                    ! @ # $
			;amp controlled by	q w e r
			;                   Q W E R
			;mode controlled by   m
			;                     M
			
		movep	x:SRX,a  ;move serial data to a
		clr		b
		move	#$31,b1   ;move ascii '1' to b
		movep	a,x:STX  ;echo data
		cmp		a,b		 ;see if a=b
		jeq		U_ONE	 ;if it does we got a '1'
		
		move	#$32,b1   ;ascii '2'
		cmp		a,b		 
		jeq		U_TWO
		
		move	#$33,b1   ;ascii '3'
		cmp		a,b		 
		jeq		U_THREE
		
		move	#$34,b1   ;ascii '4'
		cmp		a,b		 
		jeq		U_FOUR
		
		move	#$21,b1   ;ascii '!'
		cmp		a,b		 
		jeq		D_ONE
		
		move	#$40,b1   ;ascii '@'  - this is for a mac keyboard!  = (shift)2
		cmp		a,b		 
		jeq		D_TWO
		
		move	#$23,b1   ;ascii '#'
		cmp		a,b		 
		jeq		D_THREE
		
		move	#$24,b1   ;ascii '$'
		cmp		a,b		 
		jeq		D_FOUR
		
		move	#$71,b1		;ascii 'q'
		cmp		a,b
		jeq		VU_ONE
		
		move	#$77,b1		;ascii 'w'
		cmp		a,b
		jeq		VU_TWO
		
		move	#$65,b1		;ascii 'e'
		cmp		a,b
		jeq		VU_THREE
		
		move	#$72,b1		;ascii 'r'
		cmp		a,b
		jeq		VU_FOUR
		
		move	#$51,b1		;ascii 'Q'
		cmp		a,b
		jeq		VD_ONE
		
		move	#$57,b1		;ascii 'W'
		cmp		a,b
		jeq		VD_TWO
		
		move	#$45,b1		;ascii 'E'
		cmp		a,b
		jeq		VD_THREE
		
		move	#$52,b1		;ascii 'R'
		cmp		a,b
		jeq		VD_FOUR
		
		move	#$6D,b1		;ascii 'm'
		cmp		a,b
		jeq		MODE_MIX
		
		move	#$4D,b1		;ascii 'M'
		cmp		a,b
		jeq		MODE_MOD
		
		jmp		loop_1		;none of the above
		

		
U_ONE	
		move	#oscil1,R0	
		jmp		UP
U_TWO
		move	#oscil2,R0			
		jmp		UP
U_THREE
		move	#oscil3,R0		
		jmp		UP
U_FOUR
		move	#oscil4,R0
		jmp		UP
		

D_ONE
		move	#oscil1,R0
		jmp		DOWN
D_TWO
		move	#oscil2,R0
		jmp		DOWN
D_THREE
		move	#oscil3,R0
		jmp		DOWN
D_FOUR
		move	#oscil4,R0
		jmp		DOWN
		
VU_ONE	
		move	#oscil1+1,R0
		jmp		VUP		
VU_TWO	
		move	#oscil2+1,R0
		jmp		VUP		
VU_THREE	
		move	#oscil3+1,R0
		jmp		VUP		
VU_FOUR	
		move	#oscil4+1,R0
		jmp		VUP		
		
VD_ONE	
		move	#oscil1+1,R0
		jmp		VDOWN		
VD_TWO	
		move	#oscil2+1,R0
		jmp		VDOWN		
VD_THREE	
		move	#oscil3+1,R0
		jmp		VDOWN		
VD_FOUR	
		move	#oscil4+1,R0
		jmp		VDOWN		

MODE_MIX	
		bset	#0,x:mode
		jmp		loop_1
MODE_MOD
		bclr	#0,x:mode
		jmp		loop_1
		
UP
		move	#0.0001,b
		move	x:(R0),a
		add		b,a
		move	a,x:(R0)
		jmp		loop_1
		
DOWN	move	#0.0001,b
		move	x:(R0),a
		sub		b,a
		move	a,x:(R0)
		jmp		loop_1
		
VUP		move	#0.05,b
		move	x:(R0),a
		add		b,a
		move	a,x:(R0)
		jmp		loop_1
		
VDOWN	move	#0.05,b
		move	x:(R0),a
		sub		b,a
		move	a,x:(R0)
		jmp		loop_1
	
        include 'txrx_isr.asm'

        end

