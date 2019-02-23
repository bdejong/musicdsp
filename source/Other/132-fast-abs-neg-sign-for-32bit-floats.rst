Fast abs/neg/sign for 32bit floats
==================================

- **Author or source:** ed.bew@raebybot
- **Type:** floating point functions
- **Created:** 2002-12-18 20:27:04


.. code-block:: text
    :caption: notes

    Haven't seen this elsewhere, probably because it is too obvious? Anyway, these functions
    are intended for 32-bit floating point numbers only and should work a bit faster than the
    regular ones.
    
    fastabs() gives you the absolute value of a float
    fastneg() gives you the negative number (faster than multiplying with -1)
    fastsgn() gives back +1 for 0 or positive numbers, -1 for negative numbers
    
    Comments are welcome (tobybear[AT]web[DOT]de)
    
    Cheers
    
    Toby (www.tobybear.de)


.. code-block:: c++
    :linenos:
    :caption: code

    // C/C++ code:
    float fastabs(float f) 
    {int i=((*(int*)&f)&0x7fffffff);return (*(float*)&i);}
    
    float fastneg(float f) 
    {int i=((*(int*)&f)^0x80000000);return (*(float*)&i);}
    
    int fastsgn(float f) 
    {return 1+(((*(int*)&f)>>31)<<1);}
    
    //Delphi/Pascal code:
    function fastabs(f:single):single;
    begin i:=longint((@f)^) and $7FFFFFFF;result:=single((@i)^) end;
    
    function fastneg(f:single):single;
    begin i:=longint((@f)^) xor $80000000;result:=single((@i)^) end;
    
    function fastsgn(f:single):longint;
    begin result:=1+((longint((@f)^) shr 31)shl 1) end;
    
    

Comments
--------

- **Date**: 2003-01-05 05:01:59
- **By**: ed.bew@raebybot

.. code-block:: text

    Matthias (bekkah[AT]web[DOT]de) wrote me a mail with the following further improvements for the C++ parts of the code:
    
    // C++ code:
    inline float fastabs(const float f)
    {int i=((*(int*)&f)&0x7fffffff);return (*(float*)&i);}
    
    inline float fastneg(const float f)
    {int i=((*(int*)&f)^0x80000000);return (*(float*)&i);}
    
    inline int fastsgn(const float f)
    {return 1+(((*(int*)&f)>>31)<<1);}
    
    Thanks!

- **Date**: 2003-01-11 15:53:56
- **By**: ur.liam@redocip

.. code-block:: text

    Too bad these 'tricks' need two additional FWAITs to work in a raw FPU code. Maybe standard fabs and fneg are better? Although, that fastsgn() could be useful since there's no FPU equivalent for it.
    
    Cheers,
    Aleksey.
    

- **Date**: 2003-01-11 15:55:35
- **By**: ur.liam@redocip

.. code-block:: text

    I meant 'fchs' in place of 'fneg'.

- **Date**: 2003-05-05 20:49:34
- **By**: ten.llavnnarb@divad

.. code-block:: text

    I don't know if this is any faster, but atleast you can avoid some typecasting.
    
    function fastabs(f: Single): Single; var i: Integer absolute f;
    begin i := i and $7fffffff; Result := f; end;

- **Date**: 2003-07-29 04:55:55
- **By**: moc.oidua-m@sirhc

.. code-block:: text

    Note that a reasonable compiler should be able to perform these optimizations for you. I seem to recall that GCC in particular has the capability to replace calls to [f]abs() with instructions optimized for the platform.

- **Date**: 2005-05-25 20:22:59
- **By**: moc.noicratse@ajelak

.. code-block:: text

    On MS compilers for x86, just do:
    #pragma intrinsic(fabs)
    
    ...and then use fabs() for doubles, fabsf() for floats. The compiler will generate the FABS instruction, which is generally 1 cycle on modern x86 FPUs. (Internally, the FPU just masks the bit.)

