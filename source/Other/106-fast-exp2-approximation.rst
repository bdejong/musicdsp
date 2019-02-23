Fast exp2 approximation
=======================

- **Author or source:** Laurent de Soras (moc.ecrofmho@tnerual)
- **Created:** 2002-07-29 18:42:23


.. code-block:: text
    :caption: notes

    Partial approximation of exp2 in fixed-point arithmetic. It is exactly :
    [0 ; 1[ -> [0.5 ; 1[
    f : x |-> 2^(x-1)
    To get the full exp2 function, you have to separate the integer and fractionnal part of
    the number. The integer part may be processed by bitshifting. Process the fractionnal part
    with the function, and multiply the two results.
    Maximum error is only 0.3 % which is pretty good for two mul ! You get also the continuity
    of the first derivate.
    
    -- Laurent


.. code-block:: c++
    :linenos:
    :caption: code

    // val is a 16-bit fixed-point value in 0x0 - 0xFFFF ([0 ; 1[)
    // Returns a 32-bit fixed-point value in 0x80000000 - 0xFFFFFFFF ([0.5 ; 1[)
    unsigned int fast_partial_exp2 (int val)
    {
       unsigned int   result;
    
       __asm
       {
          mov eax, val
          shl eax, 15           ; eax = input [31/31 bits]
          or  eax, 080000000h   ; eax = input + 1  [32/31 bits]
          mul eax
          mov eax, edx          ; eax = (input + 1) ^ 2 [32/30 bits]
          mov edx, 2863311531   ; 2/3 [32/32 bits], rounded to +oo
          mul edx               ; eax = 2/3 (input + 1) ^ 2 [32/30 bits]
          add edx, 1431655766   ; + 4/3 [32/30 bits] + 1
          mov result, edx
       }
    
       return (result);
    }
    

