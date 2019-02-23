Fast sine wave calculation
==========================

- **Author or source:** James McCartney in Computer Music Journal, also the Julius O. Smith paper
- **Type:** waveform generation
- **Created:** 2002-01-17 00:52:33


.. code-block:: text
    :caption: notes

    (posted by Niels Gorisse)
    If you change the frequency, the amplitude rises (pitch lower) or lowers (pitch rise) a
    LOT I fixed the first problem by thinking about what actually goes wrong. The answer was
    to recalculate the phase for that frequency and the last value, and then continue
    normally.


.. code-block:: c++
    :linenos:
    :caption: code

    Variables:
    ip = phase of the first output sample in radians
    w = freq*pi / samplerate
    b1 = 2.0 * cos(w)
    
    Init:
    y1=sin(ip-w)
    y2=sin(ip-2*w)
    
    Loop:
    y0 = b1*y1 - y2
    y2 = y1
    y1 = y0
    
    output is in y0 (y0 = sin(ip + n*freq*pi / samplerate), n= 0, 1, 2, ... I *think*)
    
    Later note by James McCartney:
    if you unroll such a loop by 3 you can even eliminate the assigns!!
    
    y0 = b1*y1 - y2
    y2 = b1*y0 - y1
    y1 = b1*y2 - y0

Comments
--------

- **Date**: 2003-04-22 15:05:21
- **By**: moc.liamtoh@trahniak

.. code-block:: text

    try using this to make sine waves with frequency less that 1. I did and it gives very rough half triangle-like waves. Is there any way to fix this? I want to use a sine generated for LFO so I need one that works for low frequencies.

- **Date**: 2006-10-24 22:34:59
- **By**: moc.oi@htnysa

.. code-block:: text

    looks like the formula has gotten munged.
    w = freq * twopi / samplerate
    

