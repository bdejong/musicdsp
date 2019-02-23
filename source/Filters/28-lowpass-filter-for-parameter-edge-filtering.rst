Lowpass filter for parameter edge filtering
===========================================

- **Author or source:** Olli Niemitalo
- **Created:** 2002-01-17 02:06:29

- **Linked files:** :download:`filter001.gif <../files/filter001.gif>`.

.. code-block:: text
    :caption: notes

    use this filter to smooth sudden parameter changes
    (see linkfile!)


.. code-block:: c++
    :linenos:
    :caption: code

    /* - Three one-poles combined in parallel
     * - Output stays within input limits
     * - 18 dB/oct (approx) frequency response rolloff
     * - Quite fast, 2x3 parallel multiplications/sample, no internal buffers
     * - Time-scalable, allowing use with different samplerates
     * - Impulse and edge responses have continuous differential
     * - Requires high internal numerical precision
     */
    {
            /* Parameters */
            // Number of samples from start of edge to halfway to new value
            const double        scale = 100;
            // 0 < Smoothness < 1. High is better, but may cause precision problems
            const double        smoothness = 0.999;
    
            /* Precalc variables */
            double                a = 1.0-(2.4/scale); // Could also be set directly
            double                b = smoothness;      //         -"-
            double                acoef = a;
            double                bcoef = a*b;
            double                ccoef = a*b*b;
            double                mastergain = 1.0 / (-1.0/(log(a)+2.0*log(b))+2.0/
                            (log(a)+log(b))-1.0/log(a));
            double                again = mastergain;
            double                bgain = mastergain * (log(a*b*b)*(log(a)-log(a*b)) /
                                ((log(a*b*b)-log(a*b))*log(a*b))
                                - log(a)/log(a*b));
            double                cgain = mastergain * (-(log(a)-log(a*b)) /
                            (log(a*b*b)-log(a*b)));
    
            /* Runtime variables */
            long                streamofs;
            double                areg = 0;
            double                breg = 0;
            double                creg = 0;
    
            /* Main loop */
            for (streamofs = 0; streamofs < streamsize; streamofs++)
            {
                    /* Update filters */
                    areg = acoef * areg + fromstream [streamofs];
                    breg = bcoef * breg + fromstream [streamofs];
                    creg = ccoef * creg + fromstream [streamofs];
    
                    /* Combine filters in parallel */
                    long                temp =   again * areg
                                           + bgain * breg
                                           + cgain * creg;
    
                    /* Check clipping */
                    if (temp > 32767)
                    {
                            temp = 32767;
                    }
                    else if (temp < -32768)
                    {
                            temp = -32768;
                    }
    
                    /* Store new value */
                    tostream [streamofs] = temp;
            }
    }

Comments
--------

- **Date**: 2007-01-06 04:19:27
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Wouldn't just one pole with a low cutoff suit this purpose? At least that's what I usually do for smoothing parameter changes, and it works fine.

- **Date**: 2014-07-14 22:02:46
- **By**: moc.liamg@uttrep.imas

.. code-block:: text

    Works nicely, thanks. The gain calculations can be simplified quite a bit, to just one gain parameter.
    
    gain = 1.0 / (-1.0 / log(a) + 2.0 / log(a * b) - 1.0 / log(a * b * b))
    
    Then,
    
    again = gain,
    bgain = -2.0 * gain, and
    cgain = gain.
    

