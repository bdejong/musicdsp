Simple Tilt equalizer
=====================

- **Author or source:** moc.liamg@321tiloen
- **Type:** Tilt
- **Created:** 2009-05-29 15:13:21


.. code-block:: text
    :caption: notes

    There are a few ways to implement this. (crossover, shelves, morphing shelves [hs->lp,
    ls->hp] ...etc)
    This particular one tries to mimic the behavior of the "Niveau" filter from the "Elysia:
    mPressor" compressor.
    
    [The 'Tilt' filter]:
    It uses a center frequency (F0) and then boosts one of the ranges above or below F0, while
    doing the opposite with the other range.
    
    In the case of the "mPressor" - more extreme settings turn the filter into first order
    low-pass or high-pass. This is achieved with the gain factor for one band going close to
    -1. (ex: +6db -> lp; -6db -> hp)
    
    Lubomir I. Ivanov


.. code-block:: c++
    :linenos:
    :caption: code

    //=======================
    // tilt eq settings
    //
    // srate -> sample rate
    // f0 -> 20-20khz
    // gain -> -6 / +6 db
    //=======================
    amp = 6/log(2);
    denorm = 10^-30;
    pi = 22/7;
    sr3 = 3*srate;
    
    // conditition:
    // gfactor is the proportional gain
    //
    gfactor = 5;
    if (gain > 0) {
        g1 = -gfactor*gain;
        g2 = gain;
    } else {
        g1 = -gain;
        g2 = gfactor*gain;
    };
    
    //two separate gains
    lgain = exp(g1/amp)-1;
    hgain = exp(g2/amp)-1;
    
    //filter
    omega = 2*pi*f0;
    n = 1/(sr3 + omega);
    a0 = 2*omega*n;
    b1 = (sr3 - omega)*n;
    
    //==================================
    // sample loop
    // in -> input sample
    // out -> output sample
    //==================================
    lp_out = a0*in + b1*lp_out;
    out = in + lgain*lp_out + hgain*(in - lp_out);
    
    

Comments
--------

- **Date**: 2009-05-29 19:16:18
- **By**: moc.liamg@321tiloen

.. code-block:: text

    correction:
    
    (ex: +6db -> hp; -6db -> lp)

- **Date**: 2017-04-01 09:05:48
- **By**: moc.liamg@59hsielgladsemaj

.. code-block:: text

    Where is the denorm value meant to be used in the code? The code works regardless by noise is created when the gain control being used, it may be a result of the denorm value not being used?

