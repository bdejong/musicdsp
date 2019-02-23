One zero, LP/HP
===============

- **Author or source:** Bram
- **Created:** 2002-08-29 23:18:43


.. code-block:: text
    :caption: notes

    LP is only 'valid' for cutoffs > samplerate/4
    HP is only 'valid' for cutoffs < samplerate/4
    


.. code-block:: c++
    :linenos:
    :caption: code

    theta = cutoff*2*pi / samplerate
    
    LP:
    H(z) = (1+p*z^(-1)) / (1+p)
    out[i] = 1/(1+p) * in[i] + p/(1+p) * in[i-1];
    p = (1-2*cos(theta)) - sqrt((1-2*cos(theta))^2 - 1)
    Pi/2 < theta < Pi
    
    HP:
    H(z) = (1-p*z^(-1)) / (1+p)
    out[i] = 1/(1+p) * in[i] - p/(1+p) * in[i-1];
    p = (1+2*cos(theta)) - sqrt((1+2*cos(theta))^2 - 1)
    0 < theta < Pi/2

