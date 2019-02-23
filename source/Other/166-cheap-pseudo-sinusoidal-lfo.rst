Cheap pseudo-sinusoidal lfo
===========================

- **Author or source:** moc.regnimmu@regnimmuf
- **Created:** 2004-04-07 09:39:28


.. code-block:: text
    :caption: notes

    Although the code is written in standard C++, this algorithm is really better suited for
    dsps where one can take advantage of multiply-accumulate instructions and where the
    required phase accumulator can be easily implemented by masking a counter.
    
    It provides a pretty cheap roughly sinusoidal waveform that is good enough for an lfo.


.. code-block:: c++
    :linenos:
    :caption: code

    // x should be between -1.0 and 1.0
    inline
    double pseudo_sine(double x)
    {
        // Compute 2*(x^2-1.0)^2-1.0
        x *= x; 
        x -= 1.0;
        x *= x;
        // The following lines modify the range to lie between -1.0 and 1.0.
       // If a range of between 0.0 and 1.0 is acceptable or preferable
       // (as in a modulated delay line) then you can save some cycles.
        x *= 2.0;
        x -= 1.0;
    }

Comments
--------

- **Date**: 2004-03-31 09:08:57
- **By**: ed.bew@hakkeb

.. code-block:: text

    You forgot a 
    
    return x;

- **Date**: 2004-04-05 19:43:15
- **By**: moc.regnimmu@regnimmuf

.. code-block:: text

    Doh! You're right.
    
    -Frederick

