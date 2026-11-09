;june, 1997
;
;++++++++++++++++++++
;
;This 56000 assembly code was once part of HMSL, the Forth based
;Hierarchical Music Specification Language. HMSL was developed by Phil
;Burk, Larry Polansky and David Rosenboom. This 56K code provides several
;unit generators including a state variable filter, breakpoint envelope
;generator, interpolating delay unit, wavetable oscillator, wave shaper,
;slew rate limiter, ramp generator, etc.  Each unit generator subroutine
;is passed a structure pointer in R0.  To use the unit, construct the
;necessary data structure then call the unit code. Look in "Units.asm"
;for the unit source. The code is controlled by host interface interrupts
;in "Sounds.asm".  There are vectors for reading and writing X,Y and P
;memory.
;
;Analyse it. Enjoy it. Pick it apart like vultures feeding on a dead
;hyena. Make lots of cool music with it but please do not use it for
;commercial purposes.  Authorship and copyright information should
;accompany the code when you cut and paste.
;
;
;Enjoy,
;Phil Burk
;
;

 ;---------------------------------------------------------------------------------------------------
; Unit Generators
;
; Author: Phil Burk
; Copyright 1990
; All Rights Reserved
; May be used for non-commercial purposes with permission of the author!
;
;---------------------------------------------------------------------------------------------------
; Slew Rate Limiter 
;---------------------------------------------------------------------------------------------------
; Input:   ( target -- current )
;   R0 = Slew Limiter Unit
;		0 = Current Value
;		1 = Delta
; Output:
;   R0 = Slew Limiter Unit
;		0 = Updated Value  (!)
;		1 = Delta
SlewLimiter
	MOVE	X:(R0)+,B	; current -> B
	CMP		B,A	X:(R0)-,X0	; above or below target , get delta
	JGT		_Below
	JEQ		_Done
; current > target
	SUB		X0,B
	CMP		B,A
	JGE		_Done
	MOVE	B,X:(R0)	; save current
	MOVE	B,A			; return current
	RTS
_Below	; current < target
	ADD		X0,B
	CMP		B,A
	JLE		_Done
	MOVE	B,X:(R0)	; save current
	MOVE	B,A			; return current
	RTS
_Done
	MOVE	A,X:(R0)
	RTS
	
InitSlewLimiter
	LayDown	#0
	LayDown	#$100
	RTS

;---------------------------------------------------------------------------------------------------
;Generate a simple linear or exponential segmented envelope.
; When it finishes its last segment, it calls a function with an address in R0.
; This can be used for turning off a circuit.
;    
;---------------------------------------------------------------------------------------------------
; Accum:	( -- value )
; Input:
;   R0 = Envelope Unit
;	0 = Current Value
;	1 = Current Increment
;	2 = Current Count
;	4 = Address of Next Segment
;	5 = User function -- CircuitOff
;	6 = User data -- slot# * 2 + 1
;
;	Segment0
;		Count
;		Increment or Multiplier
;	.....
;	SegmentN
;		Count
;		Increment
;		0 - signifies end!
;
; Output:
;   A = New Value
	
LinEnvelope
	MOVE	R0,R1		; save R0
	MOVE	X:(R0)+,A	; current value
	MOVE	X:(R0)+,X0	; current increment , calc next value
	ADD		X0,A
	MOVE	A,X:(R1)	; save current value
	MOVE	X:(R0),B	; count
	MOVE	#>$1,X1		; for decrementing
	SUB		X1,B
	MOVE	B1,X:(R0)+	; write decremented count
	JLE		NextSegment
	RTS
	
ExpEnvelope
	MOVE	R0,R1		; save R0
	MOVE	X:(R0)+,X0	; current value
	MOVE	X:(R0)+,X1	; current increment , calc next value
	MPYR	X0,X1,A
	ASL		A
	MOVE	A,X:(R1)	; save current value
	MOVE	X:(R0),B	; count
	MOVE	#>$1,X1		; for decrementing
	SUB		X1,B
	MOVE	B1,X:(R0)+	; write decremented count
	JLE		NextSegment
	RTS

NextSegment			; need to go to next segment, if there is one
; R0 points to indirect address of next segment
	MOVE	X:(R0),R4	; Next Segment Address
	NOP
	MOVE	X:(R4)+,B	; next count
	TST		B			; if it's zero
	JEQ		_NoMore		; we're past last segment, exit
	MOVE	X:(R4)+,X0	; next increment
	MOVE	R4,X:(R0)	; update next segment pointer
	MOVE	X:(R1)+,X1	; bump past current value *
	MOVE	X0,X:(R1)+	; write increment
	MOVE	B1,X:(R1)+	; write count
	RTS

_NoMore
; R0 = Next Segment Address Plug
	MOVE	R0,R4
	MOVE	X:(R0)+,B	; skip Next Seg *
	MOVE	X:(R0)+,R1	; user function
	MOVE	X:(R0)+,X0	; user data
	MOVE	R0,X:(R4)	; reset Next Segment Address
	MOVE	X0,R0		; pass to user function
	JSR		(R1)
	RTS
;---------------------------------------------------------------------------------------------------
; Generate Noise using a 24 bit shift register.
; Based on Hal Chamberlain's book
;---------------------------------------------------------------------------------------------------
; Accum:	( xx -- random )
; Input:
;	R0 = address of noise unit
;		0 = state/output
; Output:
;	set (R0)
;	sample in A
Noise
	MOVE	X:(R0),B				; get state
	ASL	B				; shift bits
	JEC	_noxor				; was the high bit set
	MOVE	#$1D872B,X1			; if so, xor with mask
	EOR	X1,B
_noxor	MOVE	B1,X:(R0)			; save state
	MOVE	B1,A				; leave result on stack
	RTS

;---------------------------------------------------------------------------------------------------
; Sawtooth Oscillator
;---------------------------------------------------------------------------------------------------
; Accum: ( freq -- sample )
; R0 = address of oscillator data record
				; 0 = phase  ( fractional , -1 to 1 is one wavelength )
SawTooth
	MOVE	X:(R0),X1  		; add to phase
	ADD	X1,A			; add phase increment to phase
	MOVE	A1,A			; clip to -1,1  , without limiting
	MOVE	A1,X:(R0)		; update phase in memory
	RTS
	
;---------------------------------------------------------------------------------------------------
; Triangle Oscillator
;---------------------------------------------------------------------------------------------------
; Accum: ( freq -- sample )
; R0 = address of oscillator data record
				; 0 = phase  ( fractional , -1 to 1 is one wavelength )
; Increment (Frequency) is in A
TriangleOsc
		MOVE	X:(R0),X0	; get phase
		ADD	X0,A		; add value to accum to calc triangle
		ABS	A		A1,X:(R0)		; 2*
		ASL	A		#$80,X0
		ADD	X0,A
_Exit		RTS

;---------------------------------------------------------------------------------------------------
;Arbitrary Waveform Oscillator - Non Interpolating & Interpolating
;---------------------------------------------------------------------------------------------------
; Accum: ( freq -- sample )
; R0 = address of oscillator data record
				; 0 = phase  ( fractional , -1 to 1 is one wavelength )
				; 1 = size of table/2
OSC_TABLE	EQU	2	; 2 = address of middle of table

Oscillator
	MOVE	X:(R0),X1  		; add to phase
	ADD	X1,A			; add phase increment to phase
	MOVE	A1,X0			; clip to -1,1  , without limiting
	MOVE	X0,X:(R0)+		; update phase in memory
	MOVE	X:(R0)+,Y1		; get size/2
	MOVE	X:(R0)+,A		; calc offset of sample, get mid address
	MAC	Y1,X0,A			; sa = (size/2)*phase + size/2 + base
	MOVE	A1,R4			; move to address register, fraction in A0
	NOP
	MOVE	Y:(R4),A		; get sample from Y memory
	RTS

OscillatorI	; Interpolating - requires copy of first sample past end of table
	MOVE	X:(R0),X0  			; get phase
	ADD		X0,A				; add phase increment to phase
	MOVE	A1,X0				; clip to -1,1  , without limiting
	MOVE	X0,X:(R0)+			; update phase in memory
	MOVE	X:(R0)+,X1			; get size/2
	MOVE	X:(R0)+,A			; get middle address
	MAC		X1,X0,A				; sa = (size/2)*phase +  middle
	MOVE	A1,R1				; move to address register, fraction in A0
	MOVE	A0,A1				; save fraction, clip off higher bits
	LSR		A			Y:(R1)+,X0	; convert to 0-1 range, get sample from Y memory
	MOVE	A1,X1				; move fraction for mult
	MPY		-X1,X0,A	Y:(R1),Y1		; -frac*s[n]   , next sample
	MAC		X1,Y1,A				; frac*s[n+1] - frac*s[n]
	ADD		X0,A				; samp = s[n] + frac*s[n+1] - frac*s[n]
	RTS

InitOscillator
; R0 = oscillator
	LayDown	#0		; initial phase	
	LayDown	#>$80		; table size/2 = 256/2
	LayDown	#>(SineWave+$80)	; table address
	RTS
;---------------------------------------------------------------------------------------------------
;Dual Oscillators - Non Interpolating & Interpolating
;---------------------------------------------------------------------------------------------------
; Dual Oscillator
; A = FREQ for OSC A
; B = FREQ for OSC B
; R0 = address of oscillator A data
; R4 = address of oscillator B data
; Per Osc		PHASE
;				SIZE/2
;				&MIDWAVE


OscillatorDual
	MOVE	X:(R0),X0  					; X:get phase
	ADD		X0,A		Y:(R4),Y0		; X:add phase inc to phase, Y:get phase
	ADD		Y0,B		A1,X0			; X:clip to -1,1 no limiting, Y: add phase inc
	MOVE				B1,Y0			; Y:clip 
	MOVE	X0,X:(R0)+					; X:update phase in memory 
	MOVE	X:(R0)+,X1	Y0,Y:(R4)+			; X:get size/2
	MOVE	X:(R0)+,A	Y:(R4)+,Y1			; X:calc offset of sample, get mid address
	MAC		X0,X1,A		Y:(R4)+,B		; sa = (size/2)*phase + middle
	MAC		Y0,Y1,B		A1,R1			; move to address register, fraction in A0
	MOVE	B1,R5						; setup address
; 
	MOVE	Y:(R1),A		; get sample from Y memory
	MOVE	Y:(R5),B		; get sample from Y memory
	RTS
	
OscillatorDualI	; Interpolating - requires copy of first sample past end of table
	MOVE	X:(R0),X0  					; X:get phase
	ADD		X0,A		Y:(R4),Y0		; X:add phase inc to phase, Y:get phase
	ADD		Y0,B		A1,X0			; X:clip to -1,1 no limiting, Y: add phase inc
	MOVE				B1,Y0			; Y:clip , B1 prevents parallel move
	MOVE	X0,X:(R0)+					; X:update phase in memory 
	MOVE	X:(R0)+,X1	Y0,Y:(R4)+			; X:get size/2
	MOVE	X:(R0)+,A	Y:(R4)+,Y1			; X:calc offset of sample, get mid address
	MAC		X0,X1,A		Y:(R4)+,B		; X:sa = (size/2)*phase + middle
								; Y:get middle address
	MAC		Y0,Y1,B		A1,R1			; X:move to address register, fraction in A0
								; Y:sa = (size/2)*phase + middle
;
	MOVE	A0,A1						; save fraction, clip off higher bits
	LSR		A			Y:(R1)+,X0	; convert to 0-1 range, get sample from Y memory
	MOVE	A1,X1						; move fraction for mult
	MPY		-X1,X0,A	Y:(R1),Y1		; -frac*s[n]   , next sample
	MAC		X1,Y1,A		B1,R5			; frac*s[n+1] - frac*s[n]
	ADD		X0,A		B0,B1			; samp = s[n] + frac*s[n+1] - frac*s[n]
;
	LSR		B			Y:(R5)+,Y0	; convert to 0-1 range, get sample from Y memory
	MOVE	B1,X1						; move fraction for mult to X1
	MPY		-X1,Y0,B	Y:(R5),Y1		; -frac*s[n]   , next sample
	MAC		X1,Y1,B					; frac*s[n+1] - frac*s[n]
	ADD		Y0,B					; samp = s[n] + frac*s[n+1] - frac*s[n]
	RTS

TESTASM
; this should be legal but it won't assemble!!
;	MAC		X0,Y0,A	B,X:(R1)+	X0,B
	RTS
;---------------------------------------------------------------------------------------------------
; WaveShaper - interpolating and noninterpolating
;---------------------------------------------------------------------------------------------------
; Accum: ( sample -- sample' )
; R0 = address of waveshaper data record
				; 0 = size of table/2
				; 1 = address of middle of table
WaveShaper
	MOVE	A1,X0			; clip to -1,1  , without limiting
	MOVE	X:(R0)+,Y1		; get size/2
	MOVE	X:(R0)+,A		; calc offset of sample, get mid address
	MAC		Y1,X0,A			; sa = (size/2)*phase + size/2 + base
	MOVE	A1,R4			; move to address register, fraction in A0
	NOP
	MOVE	Y:(R4),A		; get sample from Y memory
	RTS
	
WaveShaperI	; Interpolating - requires copy of first sample past end of table
	MOVE	A1,X0				; clip to -1,1  , without limiting
	MOVE	X:(R0)+,X1			; get size/2
	MOVE	X:(R0)+,A			; get middle address
	MAC	X1,X0,A				; sa = (size/2)*phase +  middle
	MOVE	A1,R1				; move to address register, fraction in A0
	MOVE	A0,A1				; save fraction, clip off higher bits
	LSR	A		Y:(R1)+,X0	; convert to 0-1 range, get sample from Y memory
	MOVE	A1,X1				; move fraction for mult
	MPY	-X1,X0,A	Y:(R1),Y1	; -frac*s[n]   , next sample
	MAC	X1,Y1,A				; frac*s[n+1] - frac*s[n]
	ADD	X0,A				; samp = s[n] + frac*s[n+1] - frac*s[n]
	RTS

InitWaveShaper
; R0 = oscillator
	LayDown	#>$80		; table size/2 = 256/2
	LayDown	#>(SineWave+$80)	; table address
	RTS
;---------------------------------------------------------------------------------------------------
; Periodic Impulse Generator
;---------------------------------------------------------------------------------------------------
; Accum: ( freq -- sample )
; R0 = address of oscillator data record
				; 0 = phase  ( fractional , -1 to 1 is one wavelength )
Impulse
	MOVE	X:(R0),X1  		; add to phase
	ADD	X1,A			; add phase increment to phase
	MOVE	A1,X:(R0)+		; update phase in memory
	JES	_bang			
	CLR	A			; send 0 normally
	RTS
_bang	MOVE	#$7FFFFF,A		; pulse whenever 1.0 exceeded
	RTS

InitImpulse
; R0 = oscillator
	LayDown	#0		; initial phase	
	RTS
	

;---------------------------------------------------------------------------------------------------
; State Variable Filter
;---------------------------------------------------------------------------------------------------
; Accum: ( sample -- sample' )
; R0 points to:
;	F1
;	Q
;	D1 = BandPass Output
;	D2 = LowPass Output
;	H  = HighPass Output
; Register usage:
;	X0 = F1
;	X1 = L
;	Y0 = D1
;	Y1 = Q,H
;	A  = I,H
;	B  = D2,L
SVFilter
	MOVE	X:(R0)+,X0	; F1
	MOVE	X:(R0)+,Y1	; Q
	MOVE	X:(R0)+,Y0	; D1
	MOVE	X:(R0),B	; D2
	MACR	X0,Y0,B		; L=D2+F1*D1
	SUB	B,A  B,X:(R0)+	; I-L , save new D2
	MACR	-Y1,Y0,A  Y0,B	; H = I-L-Q1*D1
	MOVE	A,Y1		; save H for MPY
	MPY	X0,Y1,B	Y1,X:(R0)-	;  F1*H save H to RAM
	ADD	Y0,B  X:(R0)-,A	; B=F1*H+D1 , read back in D2 = L as return value
	MOVE	B,X:(R0)	; save BandPass
	RTS
	
InitSVFilter
	LayDown	#>$100000		; F1 = 2sin(PI*Fc/Fs)
	LayDown #>$080000
	RTS
	
;---------------------------------------------------------------------------------------------------
; Karplus Strong filter
; This is designed to operate on a wavetable that is already being played by
; an oscillator.
; Y(t) = cY(t) + dY(t-1)
;---------------------------------------------------------------------------------------------------
; R0 = address of Karplus Strong data record
				; address of previous sample filtered
				; address of last sample
				; D = multiplier for previous sample 
				; C = multiplier for current sample
				; address of first sample
; Register Usage
;	R1 = save copy of R0 for updating data record
; 	R4 = address of sample
; 	X1 = address of last sample
;	Y1 = address of first sample
;	X0 = multiplier
;	Y0 = sample data
; 	A  = calculated value
;	B  = new address, for comparison
KarplusStrong
	MOVE	R0,R1						; save for final updating
	MOVE	X:(R0)+,R4					; get sample address
	MOVE	X:(R0)+,X1					; get address of last sample
	MOVE	X:(R0)+,X0	Y:(R4)+,Y0		; get D and Y(t-1)
	MPY		X0,Y0,A		X:(R0)+,X0	Y:(R4),Y0	; get C and Y(t)
	MACR	X0,Y0,A						; Y(t) = cY(t) + dY(t-1)
	MOVE	A,Y:(R4)					; update sample in memory, might be guard point
; remaining code is mostly to wrap addresses
; cannot use M register because of special nature of guard point
	MOVE	R4,B						; move address for comparison
	CMP		X1,B		X:(R0)+,R0		; have we reached end of wave, get first address
; avoid conditional jumps because of pipeline penalty
	TGE		X1,B		R0,R4			; reset address if past end, X1,B is throwaway
	MOVE	R4,X:(R1)					; update address in data record
	MOVE	A,Y:(R4)					; just in case we wrapped around, match guard point
	RTS
;---------------------------------------------------------------------------------------------------
; Reverberation
;---------------------------------------------------------------------------------------------------
; Accum: ( sample -- reverb )
; Input:
;	R0 = reverb unit
;		0	address of next position in sample table
;		1	size-1
;		2	input level
;		3	feedback level
;		4	#taps-1
;		5	delay[0]
;		6	factor[0]
;		7	delay[1]
;		8	factor[2]
;		etc.
;	A1 = input sample
; Output:
;	reverb unit
;		address of next position in sample table (MODIFIED)
;		number of taps
;		taps
;			delay0
;			factor0
;	A1 = output sample
;
; Registers:
;	R1 = save unit
;	X0 = input level
;	X1 = feedback level
;	Y0 = delayed value from table
;	Y1 = temp for mult and DO
;	R4 = next position
;	M4 = modulus

Reverb
	MOVE	R0,R1		; save unit in R1
	MOVE	X:(R0)+,R4	; R4 = next position in sample table
	MOVE	X:(R0)+,M4	; M4 = size of sample table - 1
	MOVE	X:(R0)+,X0	; X0 = input level
	MOVE	A,Y1		; Y1 = input sample
	MPY		X0,Y1,A    	; A = input_level * input_sample, scale input to reasonable level
	PushReg	A1			; save scaled input for later
	MOVE	X:(R0)+,X1	; X1 = feedback level
	MOVE	X:(R0)+,Y1	; Y1 = #taps
	MOVE	X:(R0)+,N4	; N4 = first tap delay
	CLR	A   X:(R0)+,X0	; A = 0; X0 = first factor
	MOVE	Y:(R4+N4),Y0	; Y0 = delayed sample from table
; primary loop
	DO		Y1,_Last	; for each tap
	MAC		X0,Y0,A  	; factor * sample_from_table
	MOVE	X:(R0)+,N4	; tap delay ; next tap
	MOVE	X:(R0)+,X0	; factor
	MOVE	Y:(R4+N4),Y0	; get delayed sample from table
_Last
	MACR	X0,Y0,A		; calculate final tap
	PopReg	Y1			; Y1 = scaled_input
	MOVE	A,X0		; X0 = delayed
	MPY		X0,X1,B		; B = delayed*feedbackLevel
	ADD		Y1,B		; B = scaled_input + delayed*feedback
	MOVE	B,Y:(R4)-	; save sample + feedback into delay line
	MOVE	R4,X:(R1)	; save updated sample position
	MOVE	#$FFFF,M4	; fix modifier registers
; output
;	MACR	-X1,Y1,A	; input*feedback*(-1) + delay
	MOVE	A,A			; clip A
	RTS


InitReverb
	LayDown	#DelayLine	; address of next position in sample table
	LayDown	#DelaySize-1	; size-1
	LayDown	#0.5		; input scalar
	LayDown	#0.7		; feedback level
	LayDown	#>3		; number of taps-1
	LayDown	#>$317		;    delay0
	LayDown	#0.2		;    factor0
	LayDown	#>$453		;    delay1
	LayDown	#0.2		;    factor1
	LayDown	#>$597		;    delay2
	LayDown	#0.4		;    factor2
	LayDown	#>$6F3		;    delay3
	LayDown	#0.5		;    factor3
	RTS

;---------------------------------------------------------------------------------------------------
; Fractional Reverberation
;---------------------------------------------------------------------------------------------------
; Accum: ( sample -- reverb )
; Input:
;	R0 = reverb unit
;		0	address of next position in sample table
;		1	size-1
;		2	input level
;		3	fractionalDelay
;		4	feedback level
;	A1 = input sample
; Output:
;	reverb unit
;		address of next position in sample table (MODIFIED)
;	A1 = output sample
;
; Registers:
;	R1 = save unit
;	X0 = input level
;	X1 = feedback level
;	Y0 = delayed value from table
;	Y1 = temp for mult and DO
;	R4 = next position
;	M4 = modulus

; Interpolating Reverb, use fractional tap delay of 0 to 1.0
ReverbI
	MOVE	R0,R1		; save unit address in R1
	MOVE	X:(R0)+,R4	; R4 = next position in sample table
	MOVE	R4,R5		; R5 = save next position in sample table
	MOVE	X:(R0)+,M4	; M4 = size of sample table - 1
	MOVE	X:(R0)+,X0	; X0 = input level
	MOVE	A,Y1		; Y1 = input sample
	MPY		X0,Y1,A    	; A = input_level * input_sample, scale input to reasonable level
	PushReg	A			; save scaled input for later
	MOVE	X:(R0)+,X1	; X1 = FRACTIONAL tap delay
	MOVE	M4,Y0		; Y0 = number of taps-1
	MPY		X1,Y0,B		; B = FP tap offset
	MOVE	B1,N4		; N4 = Int tap offset
	MOVE	B0,B1		; B1 = save fraction, clip off higher bits
	LSR		B		(R4)+N4	; convert to 0-1 range,
	MOVE	Y:(R4)+,X0	; X0 = delayed sample from table
	MOVE	B1,X1		; X1 = interpolating fraction
	MPY		-X1,X0,A	 ; -frac*s[n]
	MOVE	Y:(R4),Y0	; get next sample
	MAC		X1,Y0,A		X:(R0)+,X1 ; A= frac*s[n+1] - frac*s[n], X1 = feedback level
	ADD		X0,A	R5,R4	; samp = s[n] + frac*s[n+1] - frac*s[n]
;	MOVE	X0,A		; !!!! JUST TRY USING SAMPLE FROM LINE - NO INTERP
	MOVE	A,X0		; X0 = delayed
	MPY		X0,X1,B		; B = delayed*feedbackLevel
	PopReg	Y1			; Y1 = scaled input
	ADD		Y1,B		; B = scaled_input + delayed*feedback
	MOVE	B,Y:(R4)-	; save sample + feedback into delay line
	MOVE	R4,X:(R1)	; save updated sample position
	MOVE	#$FFFF,M4	; fix modifier registers
	MOVE	A,A			; clip A
	RTS

;---------------------------------------------------------------------------------------------------
;FIR Filter - transversal
;---------------------------------------------------------------------------------------------------
; Input:
;	R0 = filter unit
;		address of next position in sample table
;		address of coefficients
;		size-1
;	A1 = input sample
; Output:
;	filter unit
;		address of next position in sample table (MODIFIED)
;		address of coefficients
;		size-1
;	A1 = output sample
;		
FIRFilter
	PushReg	R5
	MOVE	R0,R5		; save unit in R5
	MOVE	X:(R0)+,R4	; next position in sample table
	MOVE	X:(R0)+,R1	; pointer to coefficients
	MOVE	X:(R0)+,M4	; size of sample table - 1
	MOVE	M4,M1		; number of coefficients - 1
	MOVE	A1,Y:(R4)+	; now R1 points to oldest sample

	CLR	A	X:(R1)+,X0	Y:(R4)+,Y0
	REP	M4		; repeat for each coefficient
	MAC	X0,Y0,A		X:(R1)+,X0	Y:(R4)+,Y0
	MACR	X0,Y0,A
	MOVE	R4,X:(R5)	; update sample position in table
	MOVE	#$FFFF,M1	; fix modifier registers
	MOVE	M1,M4
	PopReg	R5
	RTS
	
;---------------------------------------------------------------------------------------------------
;Scope
;---------------------------------------------------------------------------------------------------
; Input: ( sample -- sample )
;	R0 = scope unit
;		cell 0 = next empty address
;		cell 1 = limit address
Scope
	MOVE	X:(R0)+,X0			; address to store next sample to
	MOVE	X:(R0)-,B			; limit address
	CMP		X0,B		X0,R1	; B-X0, is next address before limit?
	JLT		_nosave
	MOVE	A,X:(R1)+			; save and advance pointer
	MOVE	R1,X:(R0)			; save new pointer
_nosave
	RTS

;---------------------------------------------------------------------------------------------------
;OffsetFollow  keep track of DC offset
;---------------------------------------------------------------------------------------------------
; Input: ( sample -- sample )
;	R0 = envelope follower unit
;		cell 0 = DC offset
;		cell 1 = leakage_rate

OffsetFollow
		MOVE	L:(R0)+,B				;B=ENVELOPE
		MOVE	X:(R0)-,X0	B,Y1			;X0=TIME CONSTANT
		MAC	-X0,Y1,B	A,Y1			;DECAY ENVELOPE
		MAC	X0,Y1,B					;CHARGE ENVELOPE
		MOVE	B,L:(R0)					;SAVE ENVELOPE
		RTS

;---------------------------------------------------------------------------------------------------
;EnvFollow  simple envelope follower
;---------------------------------------------------------------------------------------------------
; Input: ( sample -- sample )
;	R0 = envelope follower unit
;		cell 0 = level
;		cell 1 = charge_rate

EnvFollow
		ABS	A		X:(R0)+,B	A,Y0	;B=ENVELOPE; Y1 HOLDS A
		MOVE	X:(R0)-,X0	B,Y1			;X1=TIME CONSTANT
		MACR	-X0,Y1,B	A,Y1			;DECAY ENVELOPE
		MACR	X0,Y1,B		Y0,A			;CHARGE ENVELOPE AND RESTORE A
		MOVE	B,X:(R0)					;SAVE ENVELOPE
		RTS

;---------------------------------------------------------------------------------------------------
;PeakDetect envelope follower with attack and decay rates
;---------------------------------------------------------------------------------------------------
; Input: ( sample -- sample )
;	R0 = envelope follower unit
;		cell 0 = level
;		cell 1 = attack_charge_rate
;		cell 2 = decay_charge_rate


PeakDetect
		ABS	A		X:(R0)+,B	A,Y0		;B=ENVELOPE
		CMP	A,B		X:(R0)+,X0	B,Y1		;X0=TIME CONSTANT
		JLT	_ATTACK
		MOVE	X:(R0),X0	
_ATTACK	MACR	-X0,Y1,B	A,X1		Y:(R0)-,A	;DECAY ENVELOPE
		MACR	X0,X1,B		X:(R0)-,A			;CHARGE ENVELOPE 
		MOVE	B,X:(R0)						;SAVE ENVELOPE
		MOVE	Y0,A						;RESTORE SAMPLE
		RTS

;---------------------------------------------------------------------------------------------------
;Experimental Limiter with attack and decay rates
;---------------------------------------------------------------------------------------------------
; Input: ( sample -- sample )
;	R0 = envelope follower unit
;		cell 0 = level
;		cell 1 = attack_charge_rate
;		cell 2 = decay_charge_rate
;		cell 3 = trigger level, nominally .5 ($3FFFFF)
;		cell 4 = depth, nominally 1 ($7FFFFF)
;		cell 5 = 1 ($7FFFFF)
;  limiting factor is either 1 or 1 - scale-factor *(envelope-triglevel)]
; the scale factor ranges from 0 to 1.999...


Limiter
		ABS	A		X:(R0)+,B	A,Y0		;B=ENVELOPE
		CMP	A,B		X:(R0)+,X0	B,Y1		;X0=TIME CONSTANT
		JLT	_ATTACK
		MOVE	X:(R0),X0		
_ATTACK	MACR	-X0,Y1,B	A,X1		Y:(R0)+,A	;DECAY ENVELOPE
		MACR	X0,X1,B		#-4,N0				;CHARGE ENVELOPE
		MOVE	X:(R0)+,A
		SUB	B,A		B,X:(R0+N0)			;SAVE ENVELOPE
		JPL	_NOLIMIT
		;-----------the limiter code-----------
		MOVE	X:(R0)+,X1	A,Y1				;X1=SCALING Y1=LIMITING 
		MPY	X1,Y1,A		X:(R0)+,B			;SCALE LIMITING B=.9999999
		ADDL	B,A						;LIMITING=1 - 2 * (SCALED VALUE)
		MOVE	A,X0
		MPY	Y0,X0,A
		RTS
_NOLIMIT	MOVE	Y0,A
		RTS

;---------------------------------------------------------------------------------------------------
; Multi-waveform Oscillator
;---------------------------------------------------------------------------------------------------
; Accum: ( freq -- sample )
; R0 = address of oscillator data record
				; 0 = phase  ( fractional , -1 to 1 is one wavelength )
				; 1 = pulse width
				; 2 = DC offset
				; 3 = pulse wave volume
				; 4 = triangle wave volume
				; 5 = ramp wave volume
; Increment (Frequency) is in A
MultiOsc
		MOVE	X:(R0),X0					
		ADD	X0,A		#$80,Y0				
		ABS	A		A1,X0		
		ASL	A		X0,X:(R0)+		;save phase
		ADD	Y0,A		X:(R0)+,B		;get pulse width
		CMP	X0,B		X:(R0)+,B		;get DC offset
		JGT		_NEG
		MOVE	#$7F,Y0
_NEG
		MOVE	A1,X1		
		MOVE	X:(R0)+,Y1				;pulse gain
		MAC	Y0,Y1,B		X:(R0)+,Y1		;triangle gain
		MAC	X1,Y1,B		X:(R0)+,Y1		;ramp gain
		MAC	X0,Y1,B
		MOVE	B,A
_Exit	RTS

;---------------------------------------------------------------------------------------------------
; Generate Chaotic Data using    X = 4*W*X*(1-X)
; W normally ranges from 0.75 to 1.0 
;---------------------------------------------------------------------------------------------------
; Stack	( W -- sample )
; Input:
;	R0 = address of noise unit
;		0 = state/output
; Output:
;	set (R0)
;	sample in A
Chaos
	MOVE	A,X1	
	MOVE	X:(R0),X0	; X in X0
	MOVE	#$7FFFFF,B	; 1 in B
	SUB		X0,B		; 1-X
	MOVE	B,Y0
	MPY	X0,Y0,A		; X*(1-X)
	MOVE	A,X0
	MPY	X0,X1,A		; *W
	ASL	A
	ASL	A		; *4
	MOVE	A,X:(R0)	; translate output to -1.0 to 1.0
	MOVE	#0.5,Y0
	SUB	Y0,A
	ASL	A
	RTS

InitChaos
	MOVE	#$123456,X0			; set initial state
	MOVE	X0,X:(R0)
	RTS

; stubs for disabled routines
IIRFilter
NoiseLC
GatedEnvelope
LineSeg
StereoMixer44
	RTS



