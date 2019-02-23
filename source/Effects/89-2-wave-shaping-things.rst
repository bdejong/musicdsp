2 Wave shaping things
=====================

- **Author or source:** Frederic Petrot
- **Created:** 2002-03-20 01:12:01


.. code-block:: text
    :caption: notes

    Makes nice saturations effects that can be easilly computed using cordic
    First using a atan function:
    y1 using k=16
    max is the max value you can reach (32767 would be a good guess)
    Harmonics scale down linealy and not that fast
    
    Second using the hyperbolic tangent function:
    y2 using k=2
    Harmonics scale down linealy very fast


.. code-block:: c++
    :linenos:
    :caption: code

    y1 = (max>>1) * atan(k * x/max)
    
    y2 = max * th(x/max)

Comments
--------

- **Date**: 2006-06-26 01:12:05
- **By**: ten.labolgcbs@rohtlabi

.. code-block:: text

    Why are you calling decompiled script code?BALTHOR              

- **Date**: 2013-01-18 02:20:59
- **By**: moc.liamtoh@niffumtohrepus

.. code-block:: text

    Yeah, atan & tanh, and really any sigmoid function, can create decent overdrive sound if oversampled and eq'ed properly. I've used them in some of my modelers w/ good results. For a more realistic sound, two half-wave soft clippers in series will add duty-cycle modulation and a transfer curve similar to 3/2 tube power curve. Something like: if(x < 0) y = -A * tanh(B * x); followed immediately by: if(y >= 0) y = -A * tanh(B * y); Don't forget to invert each output (-A * tanh). Coefficients A & B are left to the designer. I got this technique after reading a paper discussing a hardware implementation of this type of circuit used in Carvin amps, here: http://www.trueaudio.com/at_eetjlm.htm (original link at www.simulanalog.org)            

