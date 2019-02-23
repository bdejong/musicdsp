Float-to-int, coverting an array of floats
==========================================

- **Author or source:** Stefan Stenzel
- **Created:** 2002-01-17 03:10:32


.. code-block:: text
    :caption: notes

    intel only


.. code-block:: c++
    :linenos:
    :caption: code

    void f2short(float *fptr,short *iptr,int n)
    {
    _asm {
        mov     ebx,n
        mov     esi,fptr
        mov     edi,iptr
        lea     ebx,[esi+ebx*4]   ; ptr after last
        mov     edx,0x80008000    ; damn endianess confuses...
        mov     ecx,0x4b004b00    ; damn endianess confuses...
        mov     eax,[ebx]         ; get last value
        push    eax
        mov     eax,0x4b014B01
        mov     [ebx],eax              ; mark end
        mov     ax,[esi+2]
        jmp     startf2slp
    
    ;   Pad with nops to make loop start at address divisible
    ;   by 16 + 2, e.g. 0x01408062, don't ask why, but this
    ;   gives best performance. Unfortumately "align 16" does
    ;   not seem to work with my VC.
    ;   below I noted the measured execution times for different
    ;   nop-paddings on my Pentium Pro, 100 conversions.
    ;   saturation:  off pos neg
    
    
       nop         ;355 546 563 <- seems to be best
    ;   nop         ;951 547 544
    ;   nop         ;444 646 643
    ;   nop         ;444 646 643
    ;   nop         ;944 951 950
    ;   nop         ;358 447 644
    ;   nop         ;358 447 643
    ;   nop         ;358 544 643
    ;   nop         ;543 447 643
    ;   nop         ;643 447 643
    ;   nop         ;1047 546 746
    ;   nop         ;545 954 1253
    ;   nop         ;545 547 661
    ;   nop         ;544 547 746
    ;   nop         ;444 947 1147
    ;   nop         ;444 548 545
    in_range:
        mov     eax,[esi]
        xor     eax,edx
    saturate:
        lea     esi,[esi+4]
        mov     [edi],ax
        mov     ax,[esi+2]
        add     edi,2
    startf2slp:
        cmp     ax,cx
        je      in_range
        mov     eax,edx
        js      saturate     ; saturate neg -> 0x8000
        dec     eax          ; saturate pos -> 0x7FFF
        cmp     esi,ebx      ; end reached ?
        jb      saturate
        pop     eax
        mov     [ebx],eax    ; restore end flag
        }
    }

Comments
--------

- **Date**: 2003-01-22 20:20:20
- **By**: moc.xinortceletrams@sungam

.. code-block:: text

    
    _asm { 
    mov ebx,n 
    mov esi,fptr 
    mov edi,iptr 
    lea ebx,[esi+ebx*4] ; ptr after last 
    mov edx,0x80008000 ; damn endianess confuses... 
    mov ecx,0x4b004b00 ; damn endianess confuses... 
    mov eax,[ebx] ; get last value 
    
    I think the last line here reads outside the buffer.

