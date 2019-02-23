Denormalization preventer
=========================

- **Author or source:** eb.tenyks@didid
- **Created:** 2006-08-05 16:37:20


.. code-block:: text
    :caption: notes

    Because I still see people adding noise or offset to their signal to avoid slow
    denormalization, here's a piece of code to zero out (near) tiny numbers instead.
    
    Why zeroing out is better? Because a fully silent signal is better than a little offset,
    or noise. A host or effect can detect silent signals and choose not to process them in a
    safe way.
    Plus, adding an offset or noise reduces huge packets of denormalization, but still leaves
    some behind.
    Also, truncating is what the DAZ (Denormals Are Zero) SSE flag does.
    
    This code uses integer comparison, and a CMOV, so you need a Pentium Pro or higher.
    There's no need for an SSE version, as if you have SSE code you're probably already using
    the DAZ flag instead (but I advise plugins not to mess with the SSE flags, as the host is
    likely to have DAZ switched on already). This is for FPU code. Should work much faster
    than crap FPU comparison.
    
    Den_Thres is your threshold, it cannot be denormalized (would be pointless). The function
    is Delphi, if you want to adapt, just make sure EAX is the buffer and EDX is length
    (Delphi register calling convention - it's not the same in C++).


.. code-block:: c++
    :linenos:
    :caption: code

    const  Den_Thres:Single=1/$1000000;
    
    procedure PrevFPUDen_Buffer(Buffer:Pointer;Length:Integer);
    asm
        PUSH  ESI
        PUSH  EDI
        PUSH  EBX
    
        MOV   ECX,EDX
        LEA   EDI,[EAX+4*ECX]
        NEG   ECX
        MOV   EDX,Den_Thres
        SHL   EDX,1
        XOR   ESI,ESI
    
        @Loop:
        MOV   EAX,[EDI+4*ECX]
        LEA   EBX,[EAX*2]
        CMP   EBX,EDX
        CMOVB EAX,ESI
        MOV   [EDI+4*ECX],EAX
    
        INC   ECX
        JNZ   @Loop
    
        POP   EBX
        POP   EDI
        POP   ESI
    End;
    

Comments
--------

- **Date**: 2006-08-14 05:36:29
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    You can zero out denormals by adding and subtracting a small number. 
    
    void kill_denormal_by_quantization(float &val)
    {
      static const float anti_denormal = 1e-18;
      val += anti_denormal;
      val -= anti_denormal;
    }
    
    Reference: Laurent de Soras' great article on denormal numbers:
    ldesoras.free.fr/doc/articles/denormal-en.pdf
    
    I tend to add DC because it is faster than quantization. A slight DC offset (0.000000000000000001) won't hurt. That's -360 decibels...              

- **Date**: 2006-08-14 09:20:43
- **By**: gol

.. code-block:: text

    >>You can zero out denormals by adding and subtracting a small number 
    
    But with drawbacks as explained in his paper.
    
    As for the speed, not sure which is the faster. Especially since the FPU speed is too manufacturer-dependant (read: it's crap in pentiums), and mine is using integer. 
    
    >>A slight DC offset (0.000000000000000001) won't hurt
    
    As I wrote, it really does.. hurt the sequencer, that can't detect pure silence and optimize things accordingly. A host can detect near-silence, but it can't know which offset value YOU chose, so may use a lower threshold.
    
    

- **Date**: 2006-08-14 09:33:35
- **By**: gol

.. code-block:: text

    Btw, I happen to see I had already posted this code, probably years ago, doh!
    
    Anyway this version gives more explanation. 
    
    And here's more: 
    The LEA EBX,[EAX*2] is to get rid of the sign bit.
    And the integer comparison of float values can be done providing both are the same sign (I'm not quite sure it works on denormals, but we don't care, since they're the ones we want to zero out, so our threshold won't be denormalized). 
    

- **Date**: 2010-03-10 13:29:06
- **By**: moc.liamg@sisehtnysorpitna

.. code-block:: text

    You could also add input noise and assure output samples are reset to 0 if they're below a certain treshold, slightly higher than your noise volume. That ensures hosts can do proper tail detection and it's cheap.

