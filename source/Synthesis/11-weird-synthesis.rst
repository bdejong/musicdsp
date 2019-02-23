Weird synthesis
===============

- **Author or source:** Andy M00cho
- **Created:** 2002-01-17 00:55:09


.. code-block:: text
    :caption: notes

    (quoted from Andy's mail...)
    What I've done in a soft-synth I've been working on is used what I've termed Fooglers, no
    reason, just liked the name :) Anyway all I've done is use a *VERY* short delay line of
    256 samples and then use 2 controllable taps into the delay with High Frequency Damping,
    and a feedback parameter.
    
    Using a tiny fixed delay size of approx. 4.8ms (really 256 samples/1k memory with floats)
    means this costs, in terms of cpu consumption practically nothing, and the filter is a
    real simple 1 pole low-pass filter. Maybe not DSP'litically correct but all I wanted was
    to avoid the high frequencies trashing the delay line when high feedbacks (99%->99.9%) are
    used (when the fun starts ;).
    
    I've been getting some really sexy sounds out of this idea, and of course you can have the
    delay line tuneable if you choose to use fractional taps, but I'm happy with it as it is..
    1 nice simple, yet powerful addition to the base oscillators.
    
    In reality you don't need 2 taps, but I found that using 2 added that extra element of
    funkiness...



Comments
--------

- **Date**: 2002-07-18 18:57:00
- **By**: moc.loa@attongamlihp

.. code-block:: text

    Andy:
    I'm curious about your delay line. It's length is
    4.8 m.sec.fixed. What are the variables in the two controllable taps and is the 6dB filter variable frequency wise? 
    Phil              

- **Date**: 2003-01-03 20:01:34
- **By**: moc.oohay@poportcele

.. code-block:: text

    What you have there is the core of a physical modelling algorithm.  I have done virtually the same thing to model plucked string instruments in Reaktor.  It's amazingly realistic.  See http://joeorgren.com

