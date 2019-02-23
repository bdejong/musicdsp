	page    132,66
;**************************************************************************

;   FLASH.ASM - routine to make user code bootable from a flash eeprom
;

;   The FLASH program should be assembled separately.  Load your routine, 
;   then load FLASH, set the register R1 to indicate the end of your code 
;   (the last address) and run FLASH from program address $7FE0.
;
;
;   3 Nov. 1994 : version 1.0   rlr/ljd
;  13 Apr. 1995 :         1.1   rlr - force write to low byte (enable_prot)
;  25 Oct. 1995 :         1.2   rlr - correct conversion to sector count
;  29 Mar. 1996 :         1.3   mnw - added user discription
;  06 Feb. 1997 :         1.4   wtb - added comments from Johan Forrer
;  04 Apr. 1997 :		  1.5   updated with variable end_address by F.Kuenle & M.Maier 
; 				:	so you no longer have to manually set R1.  the code just
;					sets it to the highest legal address 
; 					for you - d.r.
;
;   copyright (C) Motorola 1994
;
;   execute with:  R1 containing last address to store

; Comments from Johan Forrer KC7WW
; 1) Assemble your aplication program with the "-l" option. Check the
;    LAST address in P. Remember ONLY P code will be saved into EEPROM, 
;    this means that coefficients or other constants need to be transferred 
;    from P->X/Y as part of the user's code.
; 2) Load this user program into EVM's memory using the debugger.
; 3) Load FLASH.CLD into the EVM's memory.
; 4) Modify register R1 to contain the LAST address as in (1). Remember that
;    the EVM only accepts the value AFTER the register contents is
;    displayed in HIGHLIGHED text.
; 5) "GO 7F00" or simply "GO" and wait till the debugger returns to diplaying
;    "DEBUG" - it may take a few seconds.
; 6) Power down or RESET and the application will now restart from 
;    FLASH EEPROM.
; 7) Reminder that the maximum address range for the FLASH EEPROM on the
;    EVM is from 8000 - FFFFh. However, the ROM bootstrap on the 56002 will
;    load 512 words starting at C000h at boot time. This then means that
;    you may only utilize the FLASH EEPROM space corresponding from
;    8000-BFFFh, a mere 4000h bytes, or 1555h 24-bit words. This will
;    be equal to saving the address range P:0000 - 1554h. The program
;    "FLASH.ASM" will write code in 64 word blocks, that means that the
;    highest P-address may only be >>>1540h<<<. This is the highest value 
;    that may be entered safely into R1 before programming the EEPROM.
;**************************************************************************


BCR             equ     $FFFE           ;Bus Control Register
PLL_CTRL        equ     $FFFD           ;PLL Control Register
begin_address   equ     $7FE0           ;The loader will be copied to p:$7fe0
end_address     equ     $153f           ;feste Userprg.endadresse

	org     p:$7F00
main
;---------------------------------------------------------------------------
;  An external boot-ROM must have the lowest byte of data at the lowest
;  address.  (i.e.,  ROM Address $C000 --- P:0000 low    byte
;                    ROM Address $C001 --- P:0000 middle byte
;                    ROM Address $C002 --- P:0000 high   byte
;                    ROM Address $C003 --- P:0001 low    byte ....)
;---------------------------------------------------------------------------

	movep   #$261009,x:PLL_CTRL     ;set PLL for MF=10, 40 MHz VCO out
	movep   #$B0B0,x:BCR            ;at 40MHz, T=25ns, 11 wait states in P:


;------ move the bootstrap loader into FLASH at P:$C000

	move    #end_address,r1         ;set end-address of userprg !!!

	move    r1,P:boot+$E            ;modify boot for length
	move    #boot,r0                ;first DSP address to save
	move    #$C000,r2               ;flash starting address
	jsr     WR_FLASH                ;save 64 words


	move    r1,A                    ;convert word cnt to sector cnt.
	rep     #6
	asr     A 
	move    A1,r1
	nop
	move    (r1)+


	move    #$8000,r2               ;address of initial FLASH address
	move    #$0000,r0               ;r0 points to input code

	do      r1,loop                 ;write sectors
	jsr     WR_FLASH
loop

	movep  #$0000,x:BCR
	debug
	jmp    *


;************************************************************************
;   WR_FLASH
;   This routine writes 64 (24-bit) words from DSP RAM to FLASH EEPROM
; 
;       enter with:     r2 pointing to starting EEPROM Byte Address
;                       r0 pointing to first DSP word to save
;
;-------------------------------------------------------------------------
;   first, move 64 bytes - this includes 21 words + low byte of 22nd
;-------------------------------------------------------------------------
WR_FLASH
	jsr     disable_protect

	do      #21,move_codeA          ;move 63 bytes
	move    P:(r0)+,A               ;get 3 byte word
	move            A1,x:(r2)+      ;move low  byte to FLASH EEPROM
	rep     #8
	lsr     A       
	move            A1,x:(r2)+      ;move mid  byte to FLASH EEPROM
	rep     #8
	lsr     A       
	move            A1,x:(r2)+      ;move high byte
move_codeA
					;*** 64th byte
	move    P:(r0)+,A               ;get next 3 byte word
	move            A1,x:(r2)+      ;move low  byte

	jsr     delay_200u              ;wait 200 microseconds to enter 
					;...program cycle
	jsr     program_complete        ;wait for programming cycle to 
					;...finish
;-------------------------------------------------------------------------
;   then, move another 64 bytes - mid and high bytes of 22nd word followed
;                                 by 20 words and then the low and mid
;                                 bytes of the next word
;-------------------------------------------------------------------------
	jsr     disable_protect

	rep     #8                      
	lsr     A       
	move            A1,x:(r2)+      ;move mid  byte to FLASH EEPROM
	rep     #8
	lsr     A       
	move            A1,x:(r2)+      ;move high byte


	do      #20,move_codeB          ;move 60 bytes
	move    P:(r0)+,A               ;get 3 byte word
	move            A1,x:(r2)+      ;move low  byte to FLASH EEPROM
	rep     #8
	lsr     A       
	move            A1,x:(r2)+      ;move mid  byte to FLASH EEPROM
	rep     #8
	lsr     A       
	move            A1,x:(r2)+      ;move high byte
move_codeB
					;*** 63rd byte ***
	move    P:(r0)+,A               ;get next 3 byte word
	move            A1,x:(r2)+      ;move low byte
	rep     #8
	lsr     A                       ;*** 64th byte ***
	move            A1,x:(r2)+      ;move mid  byte to FLASH EEPROM

	jsr     delay_200u              ;wait 200 microseconds to enter 
					;...program cycle
	jsr     program_complete        ;wait for programming cycle to 




;-------------------------------------------------------------------------
;   lastly, move another 64 bytes - high bytes of last word followed
;                                 by 21 words
;-------------------------------------------------------------------------
	jsr     disable_protect

	rep     #8
	lsr     A       
	move            A1,x:(r2)+      ;move high byte of last word


	do      #21,move_codeC          ;move 63 bytes
	move    P:(r0)+,A               ;get 3 byte word
	move            A1,x:(r2)+      ;move low  byte to FLASH EEPROM
	rep     #8
	lsr     A       
	move            A1,x:(r2)+      ;move mid  byte to FLASH EEPROM
	rep     #8
	lsr     A       
	move            A1,x:(r2)+      ;move high byte
move_codeC

	jsr     delay_200u              ;wait 200 microseconds to enter 
					;...program cycle
	jsr     program_complete        ;wait for programming cycle to 
					;...finish

	jsr     enable_protect
	rts
;***************************************************************************

;----------------------------------------------------------------------------
;  enable_protect - Software data Protection routine
;
;----------------------------------------------------------------------------
enable_protect  
	move    #>$AA,x0
	move            x0,x:$D555   ;Atmel needs $5555
	move    #>$55,x0
	move            x0,x:$AAAA   ;Atmel needs $2AAA
	move    #>$A0,x0
	move            x0,x:$D555   ;writes are now enabled
	rts
	   
;---------------------------------------------------------------------------
;  disable_protect - Disables Software Data protection
; 
;  This code writes the appropriate data to the FLASH part that disables
;  the write protection from the FLASH and allows the part to be loaded.
;
;---------------------------------------------------------------------------
disable_protect
	move    #>$AA,x0
	move            x0,x:$D555
	move    #>$55,x0
	move            x0,x:$AAAA
	move    #>$80,x0
	move            x0,x:$D555
	move    #>$AA,x0
	move            x0,x:$D555
	move    #>$55,x0
	move            x0,x:$AAAA
	move    #>$20,x0
	move            x0,x:$D555      ;exit data protect state
	rts

;---------------------------------------------------------------------------
; delay routine to be used to satisfy tBLC time requirement which is
; a minimum of 150 microseconds.
; Write Pulse Width, Write Pulse Width High requires a minimum of
; 3000 Icycles for 40MHz clock.  (50ns/Icycle)
;---------------------------------------------------------------------------
delay_200u  
	rep    #4000      ; delay of 200 micro seconds.
	nop
	rts
   
;---------------------------------------------------------------------------
;  program_complete - routine to poll for the end of the programming cycle
;
;  The AT29C256 will toggle bit 6 on successive reads until the program
;  cycle completes.  When bit 6 stabilizes, the device is no longer in
;  a programming cycle.
;---------------------------------------------------------------------------
program_complete
	btst    #6,x:$8000              ;check the initial status of bit 6
	jcs     check_set
check_clr                               ;---go here if bit 6 is clear---
	jsr     delay_200u              ;no need to hurry, give it a rest
	btst    #6,x:$8000              ;test bit 6...it was clear
	jcs     check_set               ;if it is now set, continue...
	rts
check_set                               ;---go here if bit 6 is set---
	jsr     delay_200u              
	btst    #6,x:$8000              ;test bit 6...it was set
	jcc     check_clr               ;if it is now clear, continue...
	rts

;**************************************************************************

;  this is the bootstrap loader
;  it is loaded into the memory at boot time and then moves the 
;  application code into DSP RAM
;
boot
	org     p:0,p:*
;----------------------------------------------------------------------------
;The following code moves the loader code from the P:RAM.
;----------------------------------------------------------------------------
begin   
	move    #reloc,r0               ; R0 points to loader code.
	move    #begin_address,r1       ; R1 points to runtime loader loc.
	do      #load_length,_move_code ; Move loader code to runtime loc.
	move    p:(r0)+,x0              ; Read loader code from load    loc.
	move    x0,p:(r1)+              ; Write loader code to  runtime loc.
_move_code
;----------------------------------------------------------------------------
;The following code moves the user's code from the flash to P:RAM.
;----------------------------------------------------------------------------
	jmp     load

reloc
	org     p:begin_address,p:
load    move    #$0000,r0               ; copy EEPROM into P:RAM @ $0000
	move    #$8000,r1               ; R1 points to the code in flash
	move    #1000,r2                ; R2 contains the length of code 
					; in words.
	do      r2,_ld_loop1            ; Loop once for each word of code.
	do      #3,_ld_loop2            ; Loop 3 times for each word.
	movem   p:(r1)+,a2              ; Load byte from flash.
	rep     #8                      ; Shift eight times to move
	asr     a                       ; byte into correct position.
_ld_loop2
	movem   a1,p:(r0)+              ; Stores 24-bit word.
_ld_loop1
	jmp     0                       ; Jump to the reset vector.
load_length     equ     *-load


	end
