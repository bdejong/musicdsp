Denormalization preventer
=========================

- **Author or source:** gol
- **Created:** 2005-03-31 16:57:07


.. code-block:: text
    :caption: notes

    A fast tiny numbers sweeper using integer math. Only for 32bit floats. Den_Thres is your
    32bit (normalized) float threshold, something small enough but big enough to prevent
    future denormalizations.
    
    EAX=input buffer
    EDX=length
    (adapt to your compiler)


.. code-block:: c++
    :linenos:
    :caption: code

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

