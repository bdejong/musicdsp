Gaussian White Noise
====================

- **Author or source:** uh.atsopten@egamer
- **Created:** 2002-08-07 16:23:28


.. code-block:: text
    :caption: notes

    SOURCE:
    
    Steven W. Smith:
    The Scientist and Engineer's Guide to Digital Signal Processing
    http://www.dspguide.com


.. code-block:: c++
    :linenos:
    :caption: code

    #define PI 3.1415926536f
    
    float R1 = (float) rand() / (float) RAND_MAX;
    float R2 = (float) rand() / (float) RAND_MAX;
    
    float X = (float) sqrt( -2.0f * log( R1 )) * cos( 2.0f * PI * R2 );
    

Comments
--------

- **Date**: 2002-08-28 02:05:50
- **By**: gro.sdikgninnips@nap

.. code-block:: text

    The previous one seems better for me, since it requires only a rand, half log and half sqrt per sample.
    Actually, I used that one, but I can't remember where I found it, too. Maybe on Knuth's book.

