Tone detection with Goertzel (x86 ASM)
======================================

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** Tone detection with Goertzel in x86 assembly
- **Created:** 2004-06-27 22:43:46


.. code-block:: text
    :caption: notes

    This is an "assemblified" version of the Goertzel Tone Detector. It is about 2 times
    faster than the original code.
    
    The code has been tested and it works fine.
    
    Hope you can use it. I'm gonna try to build a Tuner (as VST-Plugin). I hope, that this
    will work :-\ If anyone is intrested, please let me know.
    
    Christian


.. code-block:: delphi
    :linenos:
    :caption: code

    function Goertzel_x87(Buffer :Psingle; BLength:Integer; frequency: Single; samplerate: Single):Single;
    asm
     mov ecx,BLength
     mov eax,Buffer
     fld x2
     fldpi
     fmulp
     fmul frequency
     fdiv samplerate
     fld st(0)
     fcos
     fld x2
     fmulp
     fxch st(1)
     fldz
     fsub st(0),st(1)
     fstp st(1)
    
     fldl2e
     fmul
     fld st(0)
     frndint
     fsub st(1),st(0)
     fxch st(1)
     f2xm1
     fld1
     fadd
     fscale
     fstp st(1)
    
     fldz
     fldz
     fldz
    @loopStart:
     fxch st(1)
     fxch st(2)
     fstp st(0)
     fld st(3)
     fmul st(0),st(1)
     fsub st(0),st(2)
     fld [eax].Single
     faddp
     add eax,4
     loop @loopStart
    @loopEnd:
    
     fxch st(3)
     fmulp st(2), st(0)
     fsub st(0),st(1)
     fstp result
     ffree st(2)
     ffree st(1)
     ffree st(0)
    end;

Comments
--------

- **Date**: 2005-08-17 17:20:02
- **By**: moc.yddaht@yddaht

.. code-block:: delphi

    // Here's a variant on the theme that compensates for harmonics:
    
    Function Goertzel(.Buffer: array of double; frequency, samplerate: double):.double;
    var
    Qkn, Qkn1, Qkn2, Wkn, Mk: double;
    i: integer;
    begin
    Qkn:=0; Qkn1:=0;
    Wkn:=2*.PI*.frequency/samplerate;
    Mk:=2*.Cos(.Wkn);
    for i:=0 to High(.Buffer) do begin
      Qkn2: = Qkn1; Qkn1: = Qkn;
      Qkn  : = Buffer[.i ] + Mk*.Qkn1 - Qkn2;
    end;
    Result: = sqrt(.Qkn*.Qkn + Qkn1*.Qkn1 - Mk*.Qkn*.Qkn1);
    end;
    
    // Posted on www.delphimaster.ru by Jeer
