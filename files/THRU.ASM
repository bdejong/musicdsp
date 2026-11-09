	page	255
	opt	mex,cex
	lstcol	8,8,10,13,13
;set tab spacing to 10
;****************************************************************************
;	THRU.ASM
;	Initialization program for EVM56002 to communicate with CS4215
;	input connected to Mic inputs
;
;	Copywrite (c) MOTOROLA 1994
;		      Semiconductor Products Sector 
;		      Digital Signal Processing Division
;
;	Modified extensively from CODEC.ASM to use fast SSI interrupts and 
;	to group I/O samples into 4 sample CHUNKs to increase processing 
;	efficiency.  Note that registers r7 and m7 are committed for use 
;	for the fast SSI interrupts and cannot be used or changed in any 
;	user code.  All other normal DSP registers are available for use 
;	by the user in the process_chunk subroutine.
;
;	Copywrite (c) Robert Bristow-Johnson 1995
;
;****************************************************************************
;
;      portc usage:
;     	bit8: SSI TX (from DSP to Codec)
;	bit7:
;	bit6:
;	bit5:
;	bit4: codec reset (from DSP to Codec)
;	bit3:
;     	bit2: data/control bar
;             0=control
;             1=data
;
;
;  PROGRAM OUTLINE:
;
;1 program fsync and sclk == output
;2 write pc0 = 0 (control mode)
;3 send 64 bit frame x times, with dcb bit = 0, keep doing until read back as 0
;4 send 64 bit frame x times, with dcb bit = 1, keep doing until read back as 1
;5 re-program fsync and sclk == input
;6 write pc0 = 1 (data mode)
;7 receive/send data (echo slots 1,2,3,4; slots 5,6,7,8 == DIP switched)
; 
;****************************************************************************
       PAGE 255

NO_PREAMP       equ     $100000 
LO_OUT_DRV      equ     $080000
HI_PASS_FILT    equ     $008000
SAMP_RATE_9     equ     $003800
SAMP_RATE_48    equ     $003000
SAMP_RATE_32    equ     $001800
SAMP_RATE_27    equ     $001000
SAMP_RATE_16    equ     $000800
SAMP_RATE_8     equ     $000000
STEREO          equ     $000400
DATA_8LIN       equ     $200300
DATA_8A         equ     $200200
DATA_8U         equ     $200100
DATA_16         equ     $200000
IMMED_3STATE    equ     $800000
XTAL2_SELECT    equ     $200000
BITS_64         equ     $000000
BITS_128        equ     $040000
BITS_256        equ     $080000
CODEC_MASTER    equ     $020000
CODEC_TX_OFF    equ     $010000

CTRL_WD_12      equ     NO_PREAMP+HI_PASS_FILT+SAMP_RATE_48+STEREO+DATA_16   ;CLB=0
CTRL_WD_34      equ     IMMED_3STATE+XTAL2_SELECT+BITS_64+CODEC_MASTER
CTRL_WD_56      equ     $000000
CTRL_WD_78      equ     $000000

HEADPHONE_EN    equ     $800000
LINEOUT_EN      equ     $400000
LEFT_ATTN       equ     $010000 ;63*LEFT_ATTN   = -94.5 dB, 1.5 dB steps
SPEAKER_EN      equ     $004000
RIGHT_ATTN      equ     $000100 ;63*RIGHT_ATTN  = -94.5 dB, 1.5 dB steps
MIC_IN_SELECT   equ     $100000
LEFT_GAIN       equ     $010000 ;15*LEFT_GAIN    = 22.5 dB, 1.5 dB steps
MONITOR_ATTN    equ     $001000 ;15*MONITOR_ATTN = mute,    6   dB steps
RIGHT_GAIN      equ     $000100 ;15*RIGHT_GAIN   = 22.5 dB, 1.5 dB steps
OUTPUT_SET      equ     HEADPHONE_EN+LINEOUT_EN+(LEFT_ATTN*4)
INPUT_SET       equ     MIC_IN_SELECT+(15*MONITOR_ATTN)+(RIGHT_ATTN*4)

;---DSP56002 on-chip peripheral addresses
PCD             equ     $FFE5
PCDDR           equ     $FFE3
PCC             equ     $FFE1
PBC             equ     $FFE0
CRA             equ     $FFEC
CRB             equ     $FFED
SSIDR           equ     $FFEF
IPR             equ     $FFFF
BCR             equ     $FFFE
SSISR           equ     $FFEE
PLL             equ     $FFFD


CHUNK_SIZE	equ	4

	org	y:$40
RX_data_1_2	ds	1	;data time slot 1/2 for RX ISR (rx left)
TX_data_5_6	ds	1	;data time slot 5/6 for TX ISR
RX_data_3_4	ds	1	;data time slot 3/4 for RX ISR (rx right)
TX_data_7_8	ds	1	;data time slot 7/8 for TX ISR
RX_data_5_6	ds	1	;data time slot 5/6 for RX ISR
TX_data_1_2	ds	1	;data time slot 1/2 for TX ISR (tx left)
RX_data_7_8	ds	1	;data time slot 7/8 for RX ISR
TX_data_3_4	ds	1	;data time slot 3/4 for TX ISR (tx right)
		ds	(CHUNK_SIZE-1)*8	; additional time slots for the CHUNK


	org	p:$0
	jmp	>boot

	org	p:$C
	movep	x:SSIDR,y:(r7)+		; Read out received data to buffer.	
	movep	y:(r7)+,x:SSIDR		; SSI transfer data register.
	movep	x:SSIDR,y:(r7)+		; Read out received data to buffer.	
	movep	y:(r7)+,x:SSIDR		; SSI transfer data register.


;******************************************************************************
	org	x:$40
left_in	  ds	CHUNK_SIZE
right_in  ds	CHUNK_SIZE
left_out  ds	CHUNK_SIZE
right_out ds	CHUNK_SIZE


	org	p:$7F00

;******************************************************************************
;
;	This boot-up code may be overwritten, once it's used.
;
boot
	ori	#3,mr			;disable interrupts
	movep	#$261009,x:PLL		;set PLL for MPY of 10x
	movep	#$0000,x:BCR		; number of wait states
	movec	#0,sp
	move	#0,omr			; single chip mode

	move	#($10000-1),m0
	move	m0,m1
	move	m0,m2
	move	m0,m3
	move	m0,m4
	move	m0,m5
	move	m0,m6

	move	#(8-1),m7		; Modulo 8 buffer for now.
	move	#RX_data_1_2,r7

;***************************************************************************
;*****                initialize the CS4215 codec                      *****
;***************************************************************************
; headphones and line out, and set up for no gain or attenuation, and no 
; monitor feedback.
;***************************************************************************
;***************************************************************************
;
;	initialize ssi -- fsync and sclk ==> outputs
;
	movep	#$0000,x:PCC	; turn off ssi port 
	movep	#$4303,x:CRA	; 40MHz/16 = 2.5MHz SCLK, WL=16 bits, 4W/F
	movep	#$BB30,x:CRB	; RIE,	RE,TE, NTWK, SYN, FSR/RSR->bit
	movep	#$14,x:PCDDR	; setup pc2 and pc4 as outputs
	movep	#$0,x:PCD	; D/C~ and RESET~ = 0 ==> control mode
				;----reset delay for codec ----
	do	#500,_delay_loop
	rep	#2000		; 100 us delay
	nop
_delay_loop
	bset	#4,x:PCD	; RESET~ = 1
	movep	#$3000,x:IPR	; set interrupt priority level
	andi	#$FC,mr		; enable interrupts

;*****************************************************************************
; The following data sets up the CS4215 control mode data:
;	(CTS = Control Time Slot, U/LN = upper/lower Nibble)
;
;	+------ CTS1-UN:	0	0	1	MLB	0 0 0 0 
;	|+----- CTS1-LN:	OLB	CLB	X	X	0 0 0 0 
;	||+---- CTS2-UN:	HPF	X	DFR2	DFR1	0 0 1 0
;	|||+--- CTS2-LN:	DFR0	ST	DF1	DF0	1 1 0 0
; x0 = $002Cxx
;
;	+------ CTS3-UN:	ITS	MCK2	MCK1	MCK0	1 0 0 0
;	|+----- CTS3-LN:	BSEL1	BSEL0	XCLK	XEN	1 0 0 0 
;	||+---- CTS4-UN:	TEST	TEST	TEST	TEST	(TEST MUST BE 0)
;	|||+--- CTS4-LN:	TEST	TEST	ENL	DAD	0 0 0 0 
; x0 = $8800xx
;*****************************************************************************

;--- set up buffer with control mode data
	move	#TX_data_5_6,r0
	move	#2,n0
	move	#CTRL_WD_12,x0
	move	#CTRL_WD_34,x1
	move	#CTRL_WD_56,y0
	move	#CTRL_WD_78,y1
	move		y0,y:(r0)+n0
	move		y1,y:(r0)+n0
	move		x0,y:(r0)+n0
	move		x1,y:(r0)+n0

	movep	#$01E8,x:PCC	; Turn on ssi port

;
; CLB == 0
;
	jclr	#3,x:SSISR,*		; wait until rx frame bit==1
	jset	#3,x:SSISR,*		; wait until rx frame bit==0
	jclr	#3,x:SSISR,*		; wait until rx frame bit==1
_CLB_test_loop
	btst	#18,y:RX_data_1_2
	jcs	_CLB_test_loop

;
; CLB == 1
;
	bset	#18,y:TX_data_1_2	;set CLB
	do	#4,_CLB_wait_loop
	jclr	#2,x:SSISR,*		; wait until tx frame bit==1
	jset	#2,x:SSISR,*		; wait until tx frame bit==0
_CLB_wait_loop
	movep	#0,x:PCC		;disable, reset SSI

;*****************************************************************************
;	now CLB should be 1 -- re-program fsync and sclk direction (i/p)
;
	movep	#$4303,x:CRA	; 16bits,4 word/frame, /2/4/2=2.5 MHz
	movep	#$BB00,x:CRB	; rcv,xmt & rcv int ena,netwk,syn,sclk==i/p,msb 1st
	movep	#$14,x:PCD	; D/C~ pin = 1	==> data mode

	move	#HEADPHONE_EN+LINEOUT_EN+(4*LEFT_ATTN)+(4*RIGHT_ATTN),y0
	move	#MIC_IN_SELECT+(15*MONITOR_ATTN),y1
	clr	a	#TX_data_5_6,r0
	do	#CHUNK_SIZE,_init_cntl_data2
	move		y0,y:(r0)+n0		; TX_data_5_6
	move		y1,y:(r0)+n0		; TX_data_7_8
	move		a,y:(r0)+n0		; TX_data_1_2
	move		a,y:(r0)+n0		; TX_data_3_4
_init_cntl_data2

	move	#<(8*CHUNK_SIZE-1),m7		; Modulo 8*CHUNK_SIZE buffer
	
	movep	#$01E8,x:PCC			; turn on ssi port

	move	#0,r0
	move	#0,r1
	move	#0,r2
	move	#0,r3
	move	#0,r4
	move	#0,r5
	move	#0,r6
	
	move	#0,n0
	move	#0,n1
	move	#0,n2
	move	#0,n3
	move	#0,n4
	move	#0,n5
	move	#0,n6
	move	#0,n7
		
	clr	a
	clr	b
	
	move	#0,x0
	move	#0,x1
	move	#0,y0
	move	#0,y1
	
	jmp	main_loop
	
	
	org	p:$7FE0		; butt this up at the end of external p: space

;*****************************************************************************
;
;	Main (foreground) loop that waits for a CHUNK to be I/O,
;	then swaps (and interlaces) samples with user's CHUNKs,
;	then executes user's process_chunk routine and loops back.
;
;	This code must not be overwritten.
;	
main_loop
	clr	a	r7,x0
	move		#<RX_data_1_2+CHUNK_SIZE*8-4,a1
_wait_loop
	cmp	x0,a	r7,x0
	jge	_wait_loop
;	jset	#2,x:SSISR,*		; Wait for frame sync to pass.
	jclr	#2,x:SSISR,*		; Wait for frame sync.
	
	move		#<RX_data_1_2,r7	; If frame sync, reset base pointer.

	move		#$10000-1,m0		; make sure it's linear modulo
	move		m0,m1
	move		m0,m4
	move		m0,m5
	
	move		#<8,n4
	move		#<8,n5
		
	move		#<left_in,r0
	move		#<left_out,r1
	move		#<RX_data_1_2,r4
	move		#<TX_data_1_2,r5
	do	#CHUNK_SIZE,_left_loop
	move		x:(r1)+,b	y:(r4)+n4,a	; get out and in samples
	move		a,x:(r0)+	b,y:(r5)+n5	; put in and out samples
_left_loop
	
;	move		#<right_in,r0
;	move		#<right_out,r1
	move		#<RX_data_3_4,r4
	move		#<TX_data_3_4,r5
	do	#CHUNK_SIZE,_right_loop
	move		x:(r1)+,b	y:(r4)+n4,a	; get out and in samples
	move		a,x:(r0)+	b,y:(r5)+n5	; put in and out samples
_right_loop
	
	jsr	<process_chunk	; Process the CHUNK of samples

	jmp	main_loop	; When done processing, just loop back.



;******************************************************************************
	org	p:$40

process_chunk
;
;	Process x:left_in and x:right_in CHUNKs into x:left_out 
;	and x:right_out CHUNKs here.
;
;	This process_chunk code can take all of the internal 
;	p: space that it needs.
;
;	At 40 MHz or 20 MIPs and 48 kHz sampling frequency, we have
;	1666 instructions per CHUNK (if CHUNK_SIZE is 4).  114 
;	instructions are overhead leaving 1550 instructions and an 
;	RTS to process the 4 stereo sample CHUNK.
;
;	The measured system delay appears to be 845 microseconds.
;	This can be broken down into 333 uS each for the ADC and
;	DAC, 4 samples delay for the I/O buffer and one 4 sample
;	CHUNK delay for the process_chunk code.  12 uS (approx.
;	1/2 sample) seem to be left over probably due to analog
;	filtering of which about 4 uS can be accounted for in the
;	EVM circuit schematic.  There is also a 180 degree phase 
;	shift at low frequencies implying a polarity inversion.
;	The delay difference between left and right channels is 
;	measured to be negligible which means we have properly 
;	aligned the samples in our CHUNK I/O.
;

	move		#>(1550-35),n0		;2 The max number of instructions
	nop					;1   that we can waste.
	do	n0,_waste_time			;3
	nop					;1550-35
_waste_time
	
	move		#($10000-1),m0		;2 make sure addressing is linear
	move		m0,m1			;1
	
	move		#<left_in,r0		;1
	move		#<left_out,r1		;1
	do	#CHUNK_SIZE,_left_wire_loop	;3  Just a straight wire
	move		x:(r0)+,a		;4 = CHUNK_SIZE
	move		a,x:(r1)+		;4 = CHUNK_SIZE
_left_wire_loop
	
	move		#<right_in,r0		;1
	move		#<right_out,r1		;1
	do	#CHUNK_SIZE,_right_wire_loop	;3  Just a straight wire
	move		x:(r0)+,a		;4 = CHUNK_SIZE
	move		a,x:(r1)+		;4 = CHUNK_SIZE
_right_wire_loop
						;____
						;1550 = TOTAL (and MAX) number of 
						;         instructions per CHUNK
	rts

	end

