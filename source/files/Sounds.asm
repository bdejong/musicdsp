; Play various sounds out the DSP port controlled by HMSL
;
; Make more room for custom units at end of this file!
;
; Author: Phil Burk
; Copyright 1990
; All Rights Reserved
; May be used for non-commercial purposes with permission of the author!
;
; 00001 PLB 1/7/92 Up to 8 circuits allowable, then set back to 4.
;
;--------------------------------------------------------------------------------------------------
	nolist
	include	'IOEqu.asm'		;has equates for things like ISR etc...
	nolist
	opt	FC,MEX,MD,MU,CC

; For Device/Host Dependant Code, look for "%H"
; CUSTOM VALUES for different DACs and 56000 processors
; Comment out values you don't want.
; These Equates are for DigiDesign %H --------------------------------
CV_WAIT_STATES		EQU	$000000

; These Equates are for GMP %H----------------------------------------
;CV_WAIT_STATES	EQU	$001111
; --------------------------------------------------------------------

; X,Y,A,B = scratch
; Address Register Assignments
;	R0 = scratch, often used for passing parameters to routines, unit address
;	R1 = scratch
;	R2 = reserved for future use
;	R3 = general purpose stack used for saving registers and memory
;	R4 = scratch
;	R5 = scratch
;	R6 = reserved for sample interrupt, never use in foreground
;	R7 = reserved for Host Interface memory pointer
; Modifier Register Assignments
;	M0 = used but restored
;	M1 = used but restored
;	M2 = may not be changed, to ease use of R2 by interrupts
;	M3 = do NOT change
;	M4 = used but restored
;	M5 = used but restored
;	M6 = reserved for SSI sample interrupt, Xmit Buffer Read Pointer
;	M7 = do NOT change

;---------------------------------------------------------------------------------------------------
;Constants
;---------------------------------------------------------------------------------------------------

ProgramStart	EQU	$0040		;P: program memory start location ie the beginning

; X - System variables
HostTables	EQU	$0008	; holds address that host reads tables from
XferAddress	EQU	$0009	; used for transferring values <-> Host
BufWrPtr	EQU	$000A	; Pointer for Writing to buffer
OutputSampL	EQU	$000B	; Left Output Sample Accumulator, or MONO
OutputSampR	EQU	$000C	; Right Output Sample Accumulator
InputSampL	EQU	$000D	; save left sample input
InputSampR	EQU	$000E	; save right sample input
ControlFlags	EQU	$000E
BIT_DOIT	EQU	0	; set to 1 if new sample received
MaxCircuits	EQU	8	; maximum number of circuits 00001

; X Memory Map - Units and data structures in X
PatchBay	EQU	$0010	; external global soft connectors
DebugA		EQU	$001A
DebugB		EQU	$001B
DebugC		EQU	$001C
DebugD		EQU	$001D
; MixerLR		EQU	$0020	; room for 8 Left/Right Gain Pairs 
CircuitBase	EQU	$0040	; area for building circuits

; Y Memory Map - Waveforms and samples in Y, eg. SineWaveTable
; MixerPad	EQU	$0020	; hold samples for mixer
; warning don't run into user stack
UserStackBase	EQU	$0070	; user stack area , grows down
OutBuf		EQU	$0080	; contains sample(s) waiting to be output
OutBufMask	EQU	$007F	; size of output buffer
AudioPerK	EQU	$10	; number of audio rate samples calculated per control
OutBufWant	EQU	(OutBufMask-AudioPerK-2)	; Minimum number of samples in buffer
SineWave	EQU	$0100	; ROM (or RAM copy) sine wave, full cycle
SampleTable	EQU	$0202	; good place to put a sample waveform
DelayLine	EQU	$0800	; reverb table
DelaySize	EQU	$0700	; reverb size

;---------------------------------------------------------------------------------------------------
; Macro Definitions
;---------------------------------------------------------------------------------------------------
		
LayDown		MACRO	val
		MOVE	val,X0
		MOVE	X0,X:(R0)+
		ENDM

PushReg		MACRO	reg
		MOVE	reg,Y:-(R3)
		ENDM
		
PushMem		MACRO	addr
		MOVE	addr,Y0
		MOVE	Y0,Y:-(R3)
		ENDM

PopReg		MACRO	reg
		MOVE	Y:(R3)+,reg
		ENDM
		
PopMem		MACRO	addr
		MOVE	Y:(R3)+,Y0
		MOVE	Y0,addr
		ENDM

;---------------------------------------------------------------------------------------------------
;Interrupt Vector Table
;---------------------------------------------------------------------------------------------------
Reset		EQU	$0000
SSIRxInt	EQU	$000C
SSIRxIntEx	EQU	$000E
SSITxInt	EQU	$0010
SSITxIntEx	EQU	$0012


HostCmdInt0	EQU	$0024		;Mac host command $FF92
HostCmdInt1	EQU	$0026		;Mac host command $FF93
HostCmdInt2	EQU	$0028		;Mac host command $FF94
HostCmdInt3	EQU	$002A		;Mac host command $FF95
HostCmdInt4	EQU	$002C		;Mac host command $FF96
HostCmdInt5	EQU	$002E		;Mac host command $FF97
HostCmdInt6	EQU	$0030		;Mac host command $FF98
HostCmdInt7	EQU	$0032		;Mac host command $FF99
HostCmdInt8	EQU	$0034		;Mac host command $FF9A
HostCmdInt9	EQU	$0036		;Mac host command $FF9B
HostCmdInt10	EQU	$0038		;Mac host command $FF9C
HostCmdInt11	EQU	$003A		;Mac host command $FF9D
HostCmdInt12	EQU	$003C		;Mac host command $FF9E
HostCmdInt13	EQU	$003E		;Mac host command $FF9F

;---------------------------------------------------------------------------------------------------
;Host Command Jump Table
;---------------------------------------------------------------------------------------------------
	ORG	P:Reset
	JMP	ProgramStart

; DSPBUG has a problem with missing small ORG sections
; thus we give it one big area
	ORG	P:SSIRxInt
;	JSR	HandleSSIRxInt
	JSR	HandleSampleIn
;	ORG	P:SSIRxIntEx
	JSR	HandleSSIRxIntEx
	
;	ORG	P:SSITxInt
	MOVEP	Y:(R6)+,X:M_TX	; send the sample out to the SSI port -> the DAC
	NOP
;	ORG	P:SSITxIntEx
	JSR	HandleSSITxIntEx
	NOP		; $14
	NOP
	NOP		; $16
	NOP
	NOP		; $18
	NOP
	NOP		; $1A
	NOP
	NOP		; $1C
	NOP
	NOP		; $1E
	NOP
	NOP		; $20
	NOP
	NOP		; $22
	NOP
	NOP		; $24 - Host Command Int 0
	NOP
	NOP		; $26 - Host COmmand Int 0
	NOP

	DEFINE	XFER_REG	'R7'
	ORG	P:HostCmdInt2
 	MOVEP	X:M_HRX,XFER_REG	;set address in R7
	NOP
	
	ORG	P:HostCmdInt3
 	MOVEP	X:M_HRX,X:(XFER_REG)+	;set X memory
	NOP
	
	ORG	P:HostCmdInt4
 	MOVEP	X:M_HRX,Y:(XFER_REG)+		;put data in Y memory
	NOP

	ORG	P:HostCmdInt5
	JSR	LoadPMemory
	
	ORG	P:HostCmdInt6
 	MOVEP	X:(XFER_REG)+,X:M_HTX		;read data from X memory
	NOP
	
	ORG	P:HostCmdInt7
 	MOVEP	Y:(XFER_REG)+,X:M_HTX		;read data from Y memory
	NOP
	
	ORG	P:HostCmdInt8
	JSR	ReadPMemory
	
	NOP		; $36
	NOP
	NOP		; $38
	NOP
	NOP		; $3A
	NOP
	NOP		; $3C
	NOP
	NOP		; $3E
	NOP
	
;---------------------------------------------------------------------------------------------------
;Main Program
;---------------------------------------------------------------------------------------------------
	ORG	P:ProgramStart

	MOVEP	#CV_WAIT_STATES,X:M_BCR		;  wait states !!!!!
	JSR	InitSystem

	MOVE	#HostTables,R0
	LayDown	#HostRecord

JumpToMode
	JMP	GenOutput			; comment out one to enable desired mode %H
;	JMP	ProcessInput

; ---------------------------------------------------------------------
; Process input during Receive interrupt, send directly to output.
ProcessInput
	JSR	SetupPortsProcess
_loop	WAIT				; foreground does nothing!
	JMP	_loop
	
ProcessLoop
	WAIT
; an interrupt has just been received, do we have a new sample
	BCLR	#BIT_DOIT,X:ControlFlags
	JCC	ProcessLoop
;
; process left or right sample
	JCLR	#1,X:M_PCD,_left		;check for left/right channel %?
	JSR	MultiCircuits_A
	JMP	ProcessLoop
_left
	JSR	MultiCircuits_K
	JMP	ProcessLoop

; This next routine is Steve's, O- merge this with HandleSSIRxInt
HandleSampleIn	; Handle interrupt for stereo receive and send SDC 2/15/92 
;	JSET	#0,X:M_SR,RightChan		;jump over next code if right channel
	JSET	#1,X:M_PCD,RightChan		;check for left/right channel
	
	MOVEP	X:M_RX,Y0			; save input value
	MOVE	Y0,X:InputSampL			

	JSR	MultiCircuits_A			; do audio 
;
; transmit previously calculated value
	MOVE	X:OutputSampL,Y0			
	MOVEP	Y0,X:M_TX	; send the sample out to the SSI port -> the DAC

	MOVE	#0,A		; clear out mixer sum
	MOVE	A,X:OutputSampL
	RTI

RightChan
	MOVEP	X:M_RX,Y0			; save input value
	MOVE	Y0,X:InputSampR			
	JSR	MultiCircuits_K			; do control
;
; transmit previously calculated value
	MOVE	X:OutputSampR,Y0			
	MOVEP	Y0,X:M_TX	; send the sample out to the SSI port -> the DAC

	MOVE	#0,A		; clear out mixer sum
	MOVE	A,X:OutputSampR
	RTI

; ---------------------------------------------------------------------
; Only generate output so we use buffered output and synthesise in foreground.
GenOutput
	JSR	SetupPortsGen
	
StereoMultiLoop
; execute active control circuits
	JSR	MultiCircuits_K
	DO	#AudioPerK,_AudioLoop
	MOVE	#0,A
	MOVE	A,X:OutputSampL
	MOVE	A,X:OutputSampR
; execute active audio circuits
	JSR	MultiCircuits_A
; send mixed result to output buffer
	MOVE	X:OutputSampL,A
	MOVE	X:OutputSampR,B
	JSR	OutputSamplePair
_AudioLoop
	JSR	WaitForNeed
	JMP	StereoMultiLoop

; ---------------------------------------------------------------------
; Circuit JSR Tables
; These JSRs will be replaced by JSRs to real circuits.

; Audio Rate circuits or Right Channel Processing
MultiCircuits_A
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	JSR	<<NullCircuit		; 00001, must match MaxCircuits EQU
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	RTS

; Control Rate circuits or Left Channel Processing
MultiCircuits_K
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	JSR	<<NullCircuit		; 00001
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	JSR	<<NullCircuit
	RTS

NullCircuit
	RTS
;----------------------------------------------------------------
; INCLUDE related files
	INCLUDE		'units.asm'
	INCLUDE		'56000_control.asm'
	
; Include Specific Host Related Code %H
	INCLUDE		'DigiDesign.asm'
;	INCLUDE		'PCM1700.asm'
;	INCLUDE		'CS4328.asm'


; Circuit Support ---------------------------------------------------------
; This routine can be called by an envelope to turn off a circuit.
CircuitOff
; Clear Slot in Active Circuit Lists
; R0 = slot index
	MOVE	#MultiCircuits_A,N0	; address of audio list
	MOVE	#($0D0000|NullCircuit),X0	; opcode for JSR NullCircuit
	MOVE	X0,P:(R0+N0)		; store in MultiCircuits_A list
	MOVE	#MultiCircuits_K,N0	; address of control list
	NOP
	MOVE	X0,P:(R0+N0)		; store in MultiCircuits_K list
	MOVE	#0,N0
	RTS

; -------------------------------------------------------------
; Define tables in Memory for Host Linkage
HostRecord
	DC	HostCircuits	; where Host Circuits go
	DC	MaxCircuits	; maximum number of circuits
	DS	3		; reserved
	DC	(LastUnitFunction-UnitFunctions) ; number of functions listed
UnitFunctions
	DC	NullCircuit
	DC	MultiCircuits_A
	DC	MultiCircuits_K
	DC	CircuitOff
	DC	MixMono
	DC	MixStereo
	DC	ScaleMix
	DC	OutputSampL
	DC	OutputSampR
	DC	InputSampL
	DC	InputSampR
	DC	NullCircuit	; Reserved
	DC	NullCircuit	; Reserved
	DC	NullCircuit	; Reserved
	DC	Oscillator
	DC	OscillatorI
	DC	OscillatorDual
	DC	OscillatorDualI
	DC	SawTooth
	DC	WaveShaper
	DC	WaveShaperI
	DC	Impulse
	DC	SVFilter
	DC	IIRFilter
	DC	FIRFilter
	DC	Noise
	DC	Chaos
	DC	SlewLimiter
	DC	LineSeg
	DC	LinEnvelope
	DC	ExpEnvelope
	DC	GatedEnvelope
	DC	Reverb
	DC	ReverbI
	DC	KarplusStrong
	DC	Scope
	DC	JumpToMode
	DC	SampAndHold
LastUnitFunction
	DS	4		; room for custom units

HostCircuits

	END
