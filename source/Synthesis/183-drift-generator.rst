Drift generator
===============

- **Author or source:** ti.oohay@odrasotniuq
- **Type:** Random
- **Created:** 2004-09-23 16:07:34


.. code-block:: text
    :caption: notes

    I use this drift to modulate any sound parameter of my synth.
    It is very effective if it slightly modulates amplitude or frequency of an FM modulator.
    It is based on an incremental random variable, sine-warped.
    I like it because it is "continuous" (as opposite to "sample and hold"), and I can set
    variation rate and max variation.
    It can go to upper or lower constraint (+/- max drift) but it gradually decreases rate of
    variation when approaching to the limit.
    I use it exactly as an LFO (-1.f .. +1.f)
    I use a table for sin instead of sin() function because this way I can change random
    distribution, by selecting a different curve (different table) from sine...
    
    I hope that it is clear ... (sigh... :-)
    Bye!!!
    P.S. Thank you for help in previous submission ;-)


.. code-block:: c++
    :linenos:
    :caption: code

    const int kSamples //Number of samples in fSinTable below
    float fSinTable[kSamples] // Tabulated sin() [0 - 2pi[ amplitude [-1.f .. 1.f]
    float fWhere// Index
    float fRate // Max rate of variation
    float fLimit //max or min value
    float fDrift // Output
    
    //I assume that random() is a number from 0.f to 1.f, otherwise scale it
    
    fWhere += fRate * random()
    //I update this drift in a long-term cycle, so I don't care of branches
    if (fWhere >= 1.f) fWhere -= 1.f
    else if (fWhere < 0.f) sWhere += 1.f
    
    fDrift = fLimit * fSinTable[(long) (fWhere * kSamples)]
    

Comments
--------

- **Date**: 2004-09-24 17:37:38
- **By**: ti.oohay@odrasotniuq

.. code-block:: text

    ...sorry...
    random() must be in [-1..+1] !!!

