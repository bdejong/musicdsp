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

Comments
--------

- **Date**: 2005-05-25 23:08:34
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    This one doesn't work for me. What have i done wrong? On positive inputs, the output get messed up (usually one constant instead of a sine-like function)              

- **Date**: 2006-10-30 23:01:57
- **By**: moc.erehwon@ydobon

.. code-block:: text

    >>This one doesn't work for me. 
    
    I haven't tried it yet, but it's always possible your compiler decided the constants are ints instead of floats. Try "1.0f" everywhere you see "1". May not be it, but you never know.
    
    Anyone have any luck with this one?

- **Date**: 2014-05-30 09:46:18
- **By**: moc.liamtoh@ertekul

.. code-block:: text

    It works fine for me..thank you!

- **Date**: 2017-04-05 14:15:21
- **By**: moc.liamg@oiduaolfmail

.. code-block:: text

                  Hello, Getting an error as 'f' is an undeclared function- any idea of why this is happening? 
    

