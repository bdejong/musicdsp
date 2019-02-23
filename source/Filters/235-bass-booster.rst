Bass Booster
============

- **Author or source:** Johny Dupej
- **Type:** LP and SUM
- **Created:** 2006-08-11 12:47:34


.. code-block:: text
    :caption: notes

    This function adds a low-passed signal to the original signal. The low-pass has a quite
    wide response.
    
    Params:
    selectivity - frequency response of the LP (higher value gives a steeper one) [70.0 to
    140.0 sounds good]
    ratio - how much of the filtered signal is mixed to the original
    gain2 - adjusts the final volume to handle cut-offs (might be good to set dynamically)


.. code-block:: c++
    :linenos:
    :caption: code

    #define saturate(x) __min(__max(-1.0,x),1.0)
    
    float BassBoosta(float sample)
    {
    static float selectivity, gain1, gain2, ratio, cap;
    gain1 = 1.0/(selectivity + 1.0);
    
    cap= (sample + cap*selectivity )*gain1;
    sample = saturate((sample + cap*ratio)*gain2);
    
    return sample;
    }

