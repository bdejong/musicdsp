Square Waves
============

- **Author or source:** Sean Costello
- **Type:** waveform generation
- **Created:** 2002-01-15 21:26:38


.. code-block:: text
    :caption: notes

    One way to do a square wave:
    
    You need two buzz generators (see Dodge & Jerse, or the Csound source code, for
    implementation details). One of the buzz generators runs at the desired square wave
    frequency, while the second buzz generator is exactly one octave above this pitch.
    Subtract the higher octave buzz generator's output from the lower buzz generator's output
    - the result should be a signal with all odd harmonics, all at equal amplitude. Filter the
    resultant signal (maybe integrate it). Voila, a bandlimited square wave! Well, I think it
    should work...
    
    The one question I have with the above technique is whether it produces a waveform that
    truly resembles a square wave in the time domain. Even if the number of harmonics, and the
    relative ratio of the harmonics, is identical to an "ideal" bandwidth-limited square wave,
    it may have an entirely different waveshape. No big deal, unless the signal is processed
    by a nonlinearity, in which case the results of the nonlinear processing will be far
    different than the processing of a waveform that has a similar shape to a square wave.



Comments
--------

- **Date**: 2003-04-01 01:28:28
- **By**: dfl@stanford. edu

.. code-block:: text

    Actually, I don't think this would work...
    The proper way to do it is subtract a phase shifted buzz (aka BLIT) at the same frequency. This is equivalent to comb filtering, which will notch out the even harmonics. 

- **Date**: 2008-11-08 16:24:18
- **By**: moc.psdallahlav@naes

.. code-block:: text

    The above comment is correct, and my concept is inaccurate. My technique may have produced a signal with the proper harmonic structure, but it has been nearly 10 years since I wrote the post, so I can't remember what I was working with.
    
    DFL's technique can be implemented with two buzz generators, or with a single buzz generator in conjunction with a fractional delay, where the delay controls the amount of phase shift.             

