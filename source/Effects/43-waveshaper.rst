Waveshaper
==========

- **Author or source:** Jon Watte
- **Type:** waveshaper
- **Created:** 2002-01-17 02:19:17


.. code-block:: text
    :caption: notes

    A favourite of mine is using a sin() function instead.
    This will have the "unfortunate" side effect of removing
    odd harmonics if you take it to the extreme: a triangle
    wave gets mapped to a pure sine wave.
    This will work with a going from .1 or so to a= 5 and bigger!
    The mathematical limits for a = 0 actually turns it into a linear
    function at that point, but unfortunately FPUs aren't that good
    with calculus :-) Once a goes above 1, you start getting clipping
    in addition to the "soft" wave shaping. It starts getting into
    more of an effect and less of a mastering tool, though :-)
    
    Seeing as this is just various forms of wave shaping, you
    could do it all with a look-up table, too. In my version, that would
    get rid of the somewhat-expensive sin() function.


.. code-block:: c++
    :linenos:
    :caption: code

    (input: a == "overdrive amount")
    
    z = M_PI * a;
    s = 1/sin(z)
    b = 1/a
    
    if (x > b)
      f(x) = 1
    else
      f(x) = sin(z*x)*s

    

