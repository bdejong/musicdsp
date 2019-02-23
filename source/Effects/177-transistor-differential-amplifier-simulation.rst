Transistor differential amplifier simulation
============================================

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** Waveshaper
- **Created:** 2004-08-09 07:46:11


.. code-block:: text
    :caption: notes

    Writting an exam about electronic components, i learned several equations about simulating
    that stuff. One simplified equation was the tanh(x) formula for the differential
    amplifier. It is not exact, but since the amplifiers are driven with only small amplitudes
    the behaviour is most often  even advanced linear.
    The fact, that the amp is differential, means, that the 2n order is eliminated, so the
    sound is also similar to a tube.
    For a very fast use, this code is in pure assembly language (not optimized with SSE-Code
    yet) and performs in VST-Plugins very fast.
    The code was written in delphi and if you want to translate the assembly code, you should
    know, the the parameters passing is done via registers. So pinp=EAX pout=EDX sf=ECX.


.. code-block:: c++
    :linenos:
    :caption: code

    procedure Transistor(pinp,pout : PSingle; sf:Integer; Faktor: Single);
    asm
     fld Faktor
    @Start:
     fld [eax].single
     fmul st(0),st(1)
    
     fldl2e
     fmul
     fld st(0)
     frndint
     fsub st(1),st
     fxch st(1)
     f2xm1
     fld1
     fadd
     fscale     { result := z * 2**i }
     fstp st(1)
    
     fld st(0)
     fmulp
    
     fld st(0)
     fld1
     faddp
     fld1
     fsubp st(2),st(0)
     fdivp
    
     fstp [edx].single
    
     add eax,4
     add edx,4
     loop    @Start
     fstp st(0)
    end;

