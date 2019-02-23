Branchless Clipping
===================

- **Author or source:** ku.oc.snosrapsd@psdcisum
- **Type:** Clipping at 0dB, with none of the usual 'if..then..'
- **Created:** 2005-10-30 10:33:19


.. code-block:: text
    :caption: notes

    I was working on something that I wanted to ensure that the signal never went above 0dB,
    and a branchless solution occurred to me.
    
    It works by playing with the structure of a single type, shifting the sign bit down to
    make a new mulitplicand.
    
    calling MaxZerodB(mydBSample) will ensure that it will never stray over 0dB.
    By playing with signs or adding/removing offsets, this offers a complete branchless
    limiting solution, no matter whether dB or not (after all, they're all just numbers...).
    
    eg:
    Limit to <=0   : sample:=MaxZerodB(sample);
    Limit to <=3   : sample:=MaxZerodB(sample-3)+3;
    Limit to <=-4  : sample:=MaxZerodB(sample+4)-4;
    
    Limit to >=0   : sample:=-MaxZerodB(-sample);
    Limit to >=2   : sample:=-MaxZerodB(-sample+2)+2;
    Limit to >=-1.5: sample:=-MaxZerodB(-sample-1.5)-1.5;
    
    Whether it actually saves any CPU cycles remains to be seen, but it was an interesting
    diversion for half an hour :)
    
    [Translating from pascal to other languages shouldn't be too hard, and for doubles, you'll
    need to fiddle it abit :)]


.. code-block:: c++
    :linenos:
    :caption: code

    function MaxZerodB(dBin:single):single;
    var tmp:longint;
    begin
         //given that leftmost bit of a longint indicates the negative,
         //  if we shift that down to bit0, and multiply dBin by that
         //  it will return dBin, or zero :)
         tmp:=(longint((@dBin)^) and $80000000) shr 31;
         result:=dBin*tmp;
    end;

Comments
--------

- **Date**: 2005-11-29 18:33:09
- **By**: hotpop.com@blargg

.. code-block:: text

    Since most processors include a sign-preserving right shift, you can right shift by 31 to end up with either -1 (all bits set) or 0, then mask the original value with it:
    
    out = (in >> 31) & in;
    

- **Date**: 2005-12-01 20:33:28
- **By**: moc.liamg@tramum

.. code-block:: text

    I prefer this method, using a sign-preserving shift, as it can clip a signal to arbitrary bounds:
    
    over = upper_limit - samp
    mask = over >> 31
    over = over & mask
    samp = samp + over
    over = samp - lower_limit
    mask = over >> 31
    over = over & mask
    samp = samp - over
    
    Is it faster? Maybe on modern machines with 20-plus-stage pipelines and if the signal is clipped often, as the branches are not predictable.
    
    

- **Date**: 2006-03-22 17:53:44
- **By**: ku.oc.snosrapsd@psdcisum

.. code-block:: text

    hmm.. Did some looking into the sign preserving thing. My laptop has an P3 which didn't preserve as mentioned, and my work PC (P4HT) didn't either. Maybe its an AMD or motorola thing :)
    
    unless it's how delphi interprets the shr.. what does a C++ compiler generate for '>>' ?

- **Date**: 2006-03-28 14:42:44
- **By**: moc.liamg@tramum

.. code-block:: text

    C and C++ have sign-preserving shifts. If the value is negative, a right shift will add ones onto the left hand side (thus -2 becomes -1 etc).
    
    Java also has a non-sign-preserving right shift operator (>>>).
    
    I tried googling for information on how Delphi handles shifts, but nothing turned up. Looks like you might need to use in-line assembly :/

- **Date**: 2006-03-30 02:47:35
- **By**: ed.ko0@oreb

.. code-block:: text

    Here my SAR function for Delphi+FreePascal
    
    FUNCTION SAR(Value,Shift:INTEGER):INTEGER; {$IFDEF CPU386}ASSEMBLER; REGISTER;{$ELSE}{$IFDEF FPC}INLINE;{$ELSE}REGISTER;{$ENDIF}{$ENDIF} 
    {$IFDEF CPU386}
    ASM
     MOV ECX,EDX
     SAR EAX,CL
    END;
    {$ELSE}
    BEGIN
     RESULT:=(Value SHR Shift) OR (($FFFFFFFF+(1-((Value AND (1 SHL 31)) SHR 31) AND ORD(Shift<>0))) SHL (32-Shift));
    END;
    {$ENDIF}
    

- **Date**: 2006-03-30 03:19:59
- **By**: ed.ko0@oreb

.. code-block:: text

    Ny branchless clipping functions (the first is faster than the second)
    
    FUNCTION Clip(Value,Min,Max:SINGLE):SINGLE; ASSEMBLER; STDCALL;
    CONST Constant0Dot5:SINGLE=0.5;
    ASM
     FLD DWORD PTR Value
     FLD DWORD PTR Min
     FLD DWORD PTR Max
    
     FLD ST(2)
     FSUB ST(0),ST(2)
     FABS
     FADD ST(0),ST(2)
     FADD ST(0),ST(1)
    
     FLD ST(3)
     FSUB ST(0),ST(2)
     FABS
     FSUBP ST(1),ST(0)
     FMUL DWORD PTR Constant0Dot5
    
     FFREE ST(4)
     FFREE ST(3)
     FFREE ST(2)
     FFREE ST(1)
    END;
    
    FUNCTION ClipDSP(Value:SINGLE):SINGLE; {$IFDEF CPU386} ASSEMBLER; REGISTER;
    ASM
     MOV EAX,DWORD PTR Value
     AND EAX,$80000000
    
     AND DWORD PTR Value,$7FFFFFFF
    
     FLD DWORD PTR Value
     FLD1
     FSUBP ST(1),ST(0)
     FSTP DWORD PTR Value
    
     MOV EDX,DWORD PTR Value
     AND EDX,$80000000
     SHR EDX,31
     NEG EDX
     AND DWORD PTR Value,EDX
    
     FLD DWORD PTR Value
     FLD1
     FADDP ST(1),ST(0)
     FSTP DWORD PTR Value
    
     OR DWORD PTR Value,EAX
    
     FLD DWORD PTR Value
    END;
    {$ELSE}
    VAR ValueCasted:LONGWORD ABSOLUTE Value;
        Sign:LONGWORD;
    BEGIN
     Sign:=ValueCasted AND $80000000;
     ValueCasted:=ValueCasted AND $7FFFFFFF;
     Value:=Value-1;
     ValueCasted:=ValueCasted AND (-LONGWORD((ValueCasted AND $80000000) SHR 31));
     Value:=Value+1;
     ValueCasted:=ValueCasted OR Sign;
     RESULT:=Value;
    END;
    {$ENDIF}
    
                  

