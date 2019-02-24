WaveShaper
==========

- **Author or source:** Bram de Jong
- **Type:** waveshaper
- **Created:** 2002-01-17 02:17:49


.. code-block:: text
    :caption: notes

    where x (in [-1..1] will be distorted and a is a distortion parameter that goes from 1 to
    infinity
    The equation is valid for positive and negativ values.
    If a is 1, it results in a slight distortion and with bigger a's the signal get's more
    funky.
    
    A good thing about the shaper is that feeding it with bigger-than-one
    values, doesn't create strange fx. The maximum this function will reach is
    1.2 for a=1.


.. code-block:: c++
    :linenos:
    :caption: code

    f(x,a) = x*(abs(x) + a)/(x^2 + (a-1)*abs(x) + 1)