Reasonably accurate/fastish tanh approximation
==============================================

- **Author or source:** Fuzzpilz
- **Created:** 2004-08-17 22:56:29


.. code-block:: text
    :caption: notes

    Fairly obvious, but maybe not obvious enough, since I've seen calls to tanh() in code
    snippets here.
    
    It's this, basically:
    
    tanh(x) = sinh(x)/cosh(x)
            = (exp(x) - exp(-x))/(exp(x) + exp(-x))
            = (exp(2x) - 1)/(exp(2x) + 1)
    
    Combine this with a somewhat less accurate approximation for exp than usual (I use a
    third-order Taylor approximation below), and you're set. Useful for waveshaping.
    
    Notes on the exp approximation:
    
    It only works properly for input values above x, but since tanh is odd, that isn't a
    problem.
    
    exp(x) = 1 + x + x^2/(2!) + x^3/(3!) + ...
    
    Breaking the Taylor series off after the third term, I get
    
    1 + x + x^2/2 + x^3/6.
    
    I can save some multiplications by using
    
    6 + x * (6 + x * (3 + x))
    
    instead; a division by 6 becomes necessary, but is lumped into the additions in the tanh
    part:
    
    (a/6 - 1)/(a/6 + 1) = (a - 6)/(a + 6).
    
    Accuracy:
    
    I haven't looked at this in very great detail, but it's always <= the real tanh (>= for
    x<0), and the greatest deviation occurs at about +/- 1.46, where the result is ca. .95
    times the correct value.
    
    
    This is still faster than tanh if you use a better approximation for the exponential, even
    if you simply call exp.
    There are probably additional ways of improving parts of this, and naturally if you're
    going to use it you'll want to figure out whether your particular application offers
    additional ways of simplifying it, but it's a good start.


.. code-block:: c++
    :linenos:
    :caption: code

    /* single precision absolute value, a lot faster than fabsf() (if you use MSVC++ 6 Standard - others' implementations might be less slow) */
    float sabs(float a)
    {
    int b=(*((int *)(&a)))&0x7FFFFFFF;
    return *((float *)(&b));
    }
    
    /* approximates tanh(x/2) rather than tanh(x) - depending on how you're using this, fixing that could well be wasting a multiplication (though that isn't much, and it could be done with an integer addition in sabs instead)  */
    float tanh2(float x)
    {
    float a=sabs(x);
    a=6+a*(6+a*(3+a));
    return ((x<0)?-1:1)*(a-6)/(a+6); /* instead of using <, you can also check directly whether the sign bit is set ((*((int *)(&x)))&0x80000000), but it's not really worth it */
    }

Comments
--------

- **Date**: 2004-09-19 03:08:02
- **By**: ten.xmg@zlipzzuf

.. code-block:: text

    Not sure why this didn't occur to me earlier, but you can easily save another two adds as follows:
    
    a*=(6+a*(3+a));
    return ((x<0)?-1:1)*a/(a+12);

- **Date**: 2004-10-06 22:46:23
- **By**: moc.noicratse@ajelak

.. code-block:: text

    You shouldn't need the sabs() on VC6 - you just need to add:
    
    #pragma intrinsic( fabs )
    
    before calling fabsf(), and it should go optimally fast. 
    
    

- **Date**: 2004-10-07 10:56:45
- **By**: Laurent de Soras

.. code-block:: text

    You can optimise it a bit more by using the fact that tanh (x) = 1 - 2 / (exp (2*x) + 1)

- **Date**: 2004-10-07 11:38:00
- **By**: ten.xmg@zlipzzuf

.. code-block:: text

    AFAIK intrinsics aren't supported by VC6 Standard, but limited to Professional and Enterprise. Might be wrong, though, in which case I am a silly person. (no time to check now)

- **Date**: 2005-03-23 22:48:34
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Delphi Code:
    
    // approximates tanh(x/2) rather than tanh(x) - depending on how you're using
    // this, fixing that could well be wasting a multiplication
    function tanh2(x:single):Single;
    var a : single;
    begin
     a:=f_abs(x);
     a:=a*(12+a*(6+a*(3+a)));
     if (x<0)
      then result:=-a/(a+24)
      else result:= a/(a+24);
    end;              

- **Date**: 2005-03-23 23:01:49
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Laurent de Soras wrote:
    "You can optimise it a bit more by using the fact that tanh (x) = 1 - 2 / (exp (2*x) + 1)"
    
    It's not faster, because you'll need 3 more cycles. The routine would then look like this:
    
    function tanh2(x:single):Single;
    var a : single;
    begin
     a:=f_abs(x);
     a:=24+a*(12+a*(6+a*(3+a)));
     if (x<0)
      then result:= (-1+24/a)
      else result:=  (1-24/a);
    end;

- **Date**: 2005-05-09 02:37:33
- **By**: eb.tenyks@didid

.. code-block:: text

    I must have missed this one.. 
    but why is the comparison needed?
    
    a simpler version would be:
    a:=Abs(x)
    Result:=x*(6+a*(3+a))/(a+12)
    
    no?
    
    So in asm:
    
    function Tanh2(x:Single):Single;
    const c3 :Single=3;
          c6 :Single=6;
          c12:Single=12;
    Asm
            FLD     x
            FLD     ST(0)
            FABS
            FLD     c3
            FADD    ST(0),ST(1)
            FMUL    ST(0),ST(1)
            FADD    c6
            FMULP   ST(2),ST(0)
            FADD    c12
            FDIVP   ST(1),ST(0)
    End;
    
    ..but almost all the CPU is wasted by the division anyway
    

- **Date**: 2005-05-09 03:11:16
- **By**: eb.tenyks@didid

.. code-block:: text

    wait.. has anyone tested this function?
    
    Here's a test plot:
    http://www.flstudio.com/gol/tanh.gif
    
    Red=TanH
    
    Green=the approximation suggested in this thread
    
    Blue=another approximation that does:
    
    function TanH3(x:Single):Single;
    Begin
    Result:=x - x*x*x/3 + 2*x*x*x*x*x/15;
    end;
    
    If I didn't do anything wrong, the green one is VERY far from TanH. Blue is both closer & computationally more efficient. 
    
    But ok, this plot is for a normalized 0..1. When you go above, the blue like goes crazy. 
    But now considering that -1..1 is what matters the most for what we do, the input could still be clipped. 
    
    
    

- **Date**: 2005-05-09 03:23:10
- **By**: eb.tenyks@didid

.. code-block:: text

    forget all this :)
    
    it's all embarrassing bullshit and I obviously need some sleep :)
    
    

- **Date**: 2005-05-09 03:46:09
- **By**: eb.tenyks@didid

.. code-block:: text

    Ok ignore my above crap that I can't delete, I swear that this one does work :)
    
    First I hadn't seen that this function was assuming x*2, so my graph was scaled by 2..
    
    Second, the other algo (blue line) is still not to be neglected (because no FDIV) when the input is in the -1..1 range, and it does work.
    
    Third, I'm suggesting here a version without the comparison/branching, but still, the CPU difference is neglectable because of the FDIV. 
    
                  
    Here it is (this one does NOT assume a premultiplied x)..
    
    plain code:
    
    function Tanh2(x:Single):Single;
    var   a,b:Single;
    begin
    x:=x*2;
    a:=abs(x);
    b:=(6+a*(3+a));
    Result:=(x*b)/(a*b+12);
    end;
    
    
    asm:
    
    function Tanh22(x:Single):Single;
    const c3  :Single=3;
          c6  :Single=6;
          c12 :Single=12;
          Mul2:Single=2;
    Asm
            FLD     x
            FMUL    Mul2
            FLD     ST(0)
            FABS                 // a
            FLD     c3
            FADD    ST(0),ST(1)
            FMUL    ST(0),ST(1)
            FADD    c6           // b
            FMUL    ST(2),ST(0)  // x*b
            FMULP   ST(1),ST(0)  // a*b
            FADD    c12
            FDIVP   ST(1),ST(0)
    End;
    

- **Date**: 2005-05-10 00:37:16
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Any suggestions about improving the 3DNow Divide-Operation??? I simply hate my code...
    
    procedure Transistor2_3DNow(pinp,pout : PSingle; Samples:Integer;Scalar:Single);
    const ng   : Array [0..1] of Integer = ($7FFFFFFF,$7FFFFFFF);
          pg   : Array [0..1] of Integer = ($80000000,$80000000);
          c2   : Array [0..1] of Single = (2,2);
          c3   : Array [0..1] of Single = (3,3);
          c6   : Array [0..1] of Single = (6,6);
          c12  : Array [0..1] of Single = (12,12);
          c24  : Array [0..1] of Single = (24,24);
    asm
     shr ecx,1
     femms
     movd       mm1, Scalar.Single
     punpckldq  mm1, mm1
     movq       mm0, c2
     pfmul      mm0, mm1
    
     movq       mm3, c3
     movq       mm4, c6
     movq       mm5, c12
     movq       mm6, c24
    
    @Start:
     movq       mm1, [eax] //mm1=input
     pfmul      mm1, mm0   //mm1=a
     movq       mm2, mm1   //mm1=a,   mm2=a
    
     pand       mm2, ng    //mm1=a,   mm2=|a|
    
     pfadd      mm3, c3    //mm1=a,   mm2=|a|, mm3=|a|+3
     pfmul      mm3, mm2   //mm1=a,   mm2=|a|, mm3=|a|*(|a|+3)
     pfadd      mm3, c6    //mm1=a,   mm2=|a|, mm3=6+|a|*(3+|a|)
     pfmul      mm3, mm2   //mm1=a,   mm2=|a|, mm3=|a|*(6+|a|*(3+|a|))
     pfadd      mm3, c12   //mm1=a,   mm2=|a|, mm3=b=12+|a|*(6+|a|*(3+|a|))
     pfmul      mm1, mm3   //mm1=a*b, mm2=|a|, mm3=a*(12+|a|*(6+|a|*(3+|a|)))
     pfmul      mm2, mm3   //mm1=a*b, mm2=|a|*b
     pfadd      mm2, c24   //mm1=a*b, mm2=|a|*b+24
    
    
     movq       mm3, mm2
     pfrcp      mm4, mm3
     punpckldq  mm3, mm3
     pfrcpit1   mm3, mm4
     pfrcpit2   mm3, mm4
     movq       mm4, mm2
     punpckhdq  mm4, mm4
     pfrcp      mm5, mm4
     pfrcpit1   mm4, mm5
     pfrcpit2   mm4, mm5
     punpckldq  mm4, mm5
     pfmul      mm1, mm4
     movq       [edx],mm1
     add        eax,8
     add        edx,8
     loop    @Start
     femms
    end;

- **Date**: 2005-05-10 02:26:36
- **By**: eb.tenyks@didid

.. code-block:: text

    mmh why the loop? You can't process more than 2 Tanh in parallel in this filter, can you?
    What CPU gain did you get btw?
    
    Anyway, sucks that 3Dnow doesn't provide division.. SSE does, though.. DIVPS (or DIVPD to get a double accuracy in this case) would work here. Only problem is that on an AMD I usually get better performances out of 3DNow than SSE/SSE2. 

- **Date**: 2005-05-10 11:00:10
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    The loop works perfectly well, but it's of course for Tanh() processing of a whole block instead of inside the moog filter.
    
    The thing, that 3DNow doesn't provide division really sucks. Anyway, this way i will save a small amount of performance, but it's not huge. But i believe one can optimize the 12 lines of division further more. Also data prefetching might help a little. Or restructuring, because on AMD the order does matter!
    
    I'll SSE/SSE2 the code tonight. I think SSE gives a good performance boost, but SSE2 precisition would be needed, if the thing is inside the moog filter (IIR Filter coefficients should allways stay 64bit to avoid digital artifacts).
    
    Cheers,
    
    Christian

- **Date**: 2005-05-11 16:41:26
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Here's the Analog Devices "Sharc" DSP translation of the tanh function (inline processing of register f0):
    
    f11 = 2.;
    f0  = f0 * f11;
    f11 = abs f0;
    f3  = 3.;	
    f12 = f11+f3;
    f12 = f11*f2;
    f3  = 6.;
    f12 = f12+f3;
    f0  = f0*f12;
    f12 = f11*f12;
    f7  = 12.;
    f12 = f12+f3;
    f11 = 2.;
    f0 = recips f12, f7=f0;
    f12=f0*f12;
    f7=f0*f7, f0=f11-f12;
    f12=f0*f12;
    f7=f0*f7, f0=f11-f12;
    f12=f0*f12;
    rts(db);
    f7=f0*f7, f0=f11-f12;    
    f0=f0*f7;
    
    it can be optimized further more, but hey...

- **Date**: 2006-02-25 09:57:21
- **By**: Gene

.. code-block:: text

    tanh(x/2)~ x/(abs(x)+3/(2+x*x))
    
    better...
    

- **Date**: 2006-02-25 11:53:34
- **By**: Gene

.. code-block:: text

    tanh(x/2) ~ x/(abs(x)+2/(2.12-1.44*abs(x)+x*x))
    
    Maximum normalized difference 0.0063 from real tanh (x/2) - good enough now.

