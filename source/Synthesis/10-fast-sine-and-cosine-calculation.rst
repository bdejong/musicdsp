Fast sine and cosine calculation
================================

- **Author or source:** Lot's or references... Check Julius O. SMith mainly
- **Type:** waveform generation
- **Created:** 2002-01-17 00:54:32



.. code-block:: c++
    :linenos:
    :caption: code

    init:
    float a = 2.f*(float)sin(Pi*frequency/samplerate);
    
    float s[2];
    
    s[0] = 0.5f;
    s[1] = 0.f;
    
    loop:
    s[0] = s[0] - a*s[1];
    s[1] = s[1] + a*s[0];
    output_sine = s[0];
    output_cosine = s[1]

Comments
--------

- **Date**: 2003-04-05 10:52:49
- **By**: DFL

.. code-block:: text

    Yeah, this is a cool trick! :)
    
    FYI you can set s[0] to whatever amplitude of sinewave you desire. With 0.5, you will get +/- 0.5
    

- **Date**: 2003-04-05 17:02:22
- **By**: gro.tucetontsap@kcitgib

.. code-block:: text

    After a while it may drift, so you should resync it as follows:
    const float tmp=1.5f-0.5f*(s[1]*s[1]+s[0]*s[0]);
    s[0]*=tmp; s[1]*=tmp;     
    
    This assumes you set s[0] to 1.0 initially.
    
    'Tick        

- **Date**: 2003-04-08 09:19:40
- **By**: DFL

.. code-block:: text

    Just to expalin the above "resync" equation
    (3-x)/2 is an approximation of 1/sqrt(x)
    So the above is actually renormalizing the complex magnitude.
    [ sin^2 (x) + cos^2(x) = 1 ]
    

- **Date**: 2003-05-15 08:26:22
- **By**: nigel

.. code-block:: text

    This is the Chamberlin state variable filter specialized for infinite Q oscillation. A few things to note:
    
    Like the state variable filter, the upper frequency limit for stability is around one-sixth the sample rate.
    
    The waveform symmetry is very pure at low frequencies, but gets skewed as you get near the upper limit.
    
    For low frequencies, sin(n) is very close to n, so the calculation for "a" can be reduced to a = 2*Pi*frequency/samplerate.
    
    You shouldn't need to resync the oscillator--for fixed point and IEEE floating point, errors cancel exactly, so the osciallator runs forever without drifting in amplitude or frequency.

- **Date**: 2003-11-03 00:14:34
- **By**: moc.liamtoh@sisehtnysorpitna

.. code-block:: text

    I made a nice little console 'game' using your cordic sinewave approximation. Download it at http://users.pandora.be/antipro/Other/Ascillator.zip (includes source code). Just for oldschool fun :).

- **Date**: 2004-12-22 16:52:20
- **By**: hplus

.. code-block:: text

    Note that the peaks of the waveforms will actually be between samples, and the functions will be phase offset by one half sample's worth. If you need exact phase, you can compensate by interpolating using cubic hermite interpolation.

- **Date**: 2007-07-24 20:33:12
- **By**: more on that topic...

.. code-block:: text

    ... can be found in Jon Datorro, Effect Design, Part 3, a paper that can be easily found in the web. 
    
    Funny, this is just a complex multiply that is optimized for small angles (low frequencies)
    
    When the CPU rounding mode is set to nearest, it should be stable, at least for small frequencies.

- **Date**: 2007-07-24 20:34:22
- **By**: ed.corm@liam

.. code-block:: text

    More on that can be found in Jon Datorro, Effect Design, Part 3, a paper that can be easily found in the web.
    
    Funny, this is just a complex multiply that is optimized for small angles (low frequencies)
    
    When the CPU rounding mode is set to nearest, it should be stable, at least for small frequencies.
    

- **Date**: 2008-09-21 20:16:40
- **By**: moc.foohay@bob

.. code-block:: text

    How do I set a particular phase for this? I've tried setting s[0] = cos(phase) and s[1] = sin(phase), but that didn't seem to be accurate enough.
    
    Thanks

