Fast square wave generator
==========================

- **Author or source:** Wolfgang (ed.tfoxen@redienhcsw)
- **Type:** NON-bandlimited osc...
- **Created:** 2002-02-10 12:46:22


.. code-block:: text
    :caption: notes

    Produces a square wave -1.0f .. +1.0f.
    The resulting waveform is NOT band-limited, so it's propably of not much use for syntheis.
    It's rather useful for LFOs and the like, though.


.. code-block:: c++
    :linenos:
    :caption: code

    Idea: use integer overflow to avoid conditional jumps.
    
    // init:
    typedef unsigned long ui32;
    
    float sampleRate = 44100.0f; // whatever
    float freq = 440.0f; // 440 Hz
    float one = 1.0f;
    ui32 intOver = 0L;
    ui32 intIncr = (ui32)(4294967296.0 / hostSampleRate / freq));
    
    // loop:
    (*((ui32 *)&one)) &= 0x7FFFFFFF; // mask out sign bit
    (*((ui32 *)&one)) |= (intOver & 0x80000000);
    intOver += intIncr;

Comments
--------

- **Date**: 2003-08-03 01:35:08
- **By**: moc.jecnal@psdcisum

.. code-block:: text

    So, how would I get the output into a float variable like square_out, for instance?

- **Date**: 2009-04-12 15:33:37
- **By**: moc.liamtoh@18_ogag_leafar

.. code-block:: text

    In response to lancej, yo can declare a union with a float and a int and operate the floatas as here using the int part of the union.
    
    If I remeber correctly the value for -1.f = 0xBF800000 and the value for 1.f = 0x3F800000, note the 0x80000000 difference between them that is the sign.

