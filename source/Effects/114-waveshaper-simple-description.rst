Waveshaper (simple description)
===============================

- **Author or source:** Jon Watte
- **Type:** Polynomial; Distortion
- **Created:** 2002-08-15 00:45:22


.. code-block:: text
    :caption: notes

    > The other question; what's a 'waveshaper' algorithm. Is it simply another
    > word for distortion?
    
    A typical "waveshaper" is some function which takes an input sample value
    X and transforms it to an output sample X'. A typical implementation would
    be a look-up table of some number of points, and some level of interpolation
    between those points (say, cubic). When people talk about a wave shaper,
    this is most often what they mean. Note that a wave shaper, as opposed to a
    filter, does not have any state. The mapping from X -> X' is stateless.
    
    Some wave shapers are implemented as polynomials, or using other math
    functions. Hard clipping is a wave shaper implemented using the min() and
    max() functions (or the three-argument clamp() function, which is the same
    thing). A very mellow and musical-sounding distortion is implemented using
    a third-degree polynomial; something like X' = (3/2)X - (1/2)X^3. The nice
    thing with polynomial wave shapers is that you know that the maximum they
    will expand bandwidth is their order. Thus, you need to oversample 3x to
    make sure that a third-degree polynomial is aliasing free. With a lookup
    table based wave shaper, you don't know this (unless you treat an N-point
    table as an N-point polynomial :-)
    


.. code-block:: c++
    :linenos:
    :caption: code

    float waveshape_distort( float in ) {
      return 1.5f * in - 0.5f * in *in * in;
    }
    

Comments
--------

- **Date**: 2005-06-30 09:41:07
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Yes! It's one of the most simple waveshaper and you know the amount of oversampling!
    Works very nice (and fast).