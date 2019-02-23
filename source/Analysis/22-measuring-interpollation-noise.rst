Measuring interpollation noise
==============================

- **Author or source:** Jon Watte
- **Created:** 2002-01-17 02:00:09


.. code-block:: text
    :caption: notes

    You can easily estimate the error by evaluating the actual function and
    evaluating your interpolator at each of the mid-points between your
    samples. The absolute difference between these values, over the absolute
    value of the "correct" value, is your relative error. log10 of your relative
    error times 20 is an estimate of your quantization noise in dB. Example:
    
    You have a table for every 0.5 "index units". The value at index unit 72.0
    is 0.995 and the value at index unit 72.5 is 0.999. The interpolated value
    at index 72.25 is 0.997. Suppose the actual function value at that point was
    0.998; you would have an error of 0.001 which is a relative error of 0.001002004..
    log10(error) is about -2.99913, which times 20 is about -59.98. Thus, that's
    your quantization noise at that position in the table. Repeat for each pair of
    samples in the table.
    
    Note: I said "quantization noise" not "aliasing noise". The aliasing noise will,
    as far as I know, only happen when you start up-sampling without band-limiting
    and get frequency aliasing (wrap-around), and thus is mostly independent of
    what specific interpolation mechanism you're using.



