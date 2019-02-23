One pole filter, LP and HP
==========================

- **Author or source:** uh.etle.fni@yfoocs
- **Type:** Simple 1 pole LP and HP filter
- **Created:** 2006-10-08 14:53:38


.. code-block:: text
    :caption: notes

    Slope: 6dB/Oct
    
    Reference: www.dspguide.com


.. code-block:: c++
    :linenos:
    :caption: code

    Process loop (lowpass):
    out = a0*in - b1*tmp;
    tmp = out;
    
    Simple HP version: subtract lowpass output from the input (has strange behaviour towards nyquist):
    out = a0*in - b1*tmp;
    tmp = out;
    hp = in-out;
    
    Coefficient calculation:
    x = exp(-2.0*pi*freq/samplerate);
    a0 = 1.0-x;
    b1 = -x;
    
    
    
    
    

Comments
--------

- **Date**: 2007-01-05 11:43:21
- **By**: moc.liamtoh@ojer_jd

.. code-block:: text

    Why don't you just say:
    
    Process loop (lowpass):
    out = a0*in + b1*tmp;
    tmp = out;
    
    Simple HP version: subtract lowpass output from the input (has strange behaviour towards nyquist):
    out = a0*in + b1*tmp;
    tmp = out;
    hp = in-out;
    
    Coefficient calculation:
    x = exp(-2.0*pi*freq/samplerate);
    a0 = 1.0-x;
    b1 = x;

- **Date**: 2007-01-06 04:12:56
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    There's a tradition among digital filter designers that the pole coefficients have a negative sign. Of course the other one is also valid, and sometimes these notations are mixed up.
    
    If you're worried about the extra negation operation, then you could say
    
    b1 = -x;
    a0 = 1.0+b1;
    
    so that there's no additional operation overhead.
    
    -- peter schoffhauzer

- **Date**: 2007-01-06 16:26:27
- **By**: moc.erehwon@ydobon

.. code-block:: text

    Of course, you don't need tmp.
    
    Process loop (lowpass):
    out = a0*in + b1*out;
    
    

- **Date**: 2007-02-16 19:27:48
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Indeed.              

- **Date**: 2009-06-18 17:29:20
- **By**: moc.boohay@bob

.. code-block:: text

    Or...
    out += a0 * (in - out);
    
    :)
    
                  

