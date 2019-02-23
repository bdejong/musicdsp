DC filter
=========

- **Author or source:** hc.niweulb@lossor.ydna
- **Type:** 1-pole/1-zero DC filter
- **Created:** 2003-01-04 01:18:23


.. code-block:: text
    :caption: notes

    This is based on code found in the document:
    "Introduction to Digital Filters (DRAFT)"
    Julius O. Smith III (jos@ccrma.stanford.edu)
    (http://www-ccrma.stanford.edu/~jos/filters/)
    ---
    
    Some audio algorithms (asymmetric waveshaping, cascaded filters, ...) can produce DC
    offset. This offset can accumulate and reduce the signal/noise ratio.
    
    So, how to fix it? The example code from Julius O. Smith's document is:
    ...
    y(n) = x(n) - x(n-1) + R * y(n-1)
    // "R" between 0.9 .. 1
    // n=current (n-1)=previous in/out value
    ...
    "R" depends on sampling rate and the low frequency point. Do not set "R" to a fixed value
    (e.g. 0.99) if you don't know the sample rate. Instead set R to:
    (-3dB @ 40Hz): R = 1-(250/samplerate)
    (-3dB @ 30Hz): R = 1-(190/samplerate)
    (-3dB @ 20Hz): R = 1-(126/samplerate)
    



Comments
--------

- **Date**: 2003-01-04 01:58:04
- **By**: hc.niweulb@lossor.ydna

.. code-block:: text

    I just received a mail from a musicdsp reader:
    
    'How to calculate "R" for a given (-3dB) low frequency point?'
    
    R = 1 - (pi*2 * frequency /samplerate)
    
    (pi=3.14159265358979)

- **Date**: 2003-05-10 09:11:42
- **By**: ten.labolgfrus@jbr

.. code-block:: text

    particularly if fixed-point arithmetic is used, this simple high-pass filter can create it's own DC offset because of limit-cycles.  to cure that look at
    
    http://www.dspguru.com/comp.dsp/tricks/alg/dc_block.htm
    
    this trick uses the concept of "noise-shaping" to prevent DC in any limit-cycles.
    
    r b-j
    

