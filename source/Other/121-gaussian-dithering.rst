Gaussian dithering
==================

- **Author or source:** Aleksey Vaneev (ur.liam@redocip)
- **Type:** Dithering
- **Created:** 2002-09-29 23:02:52


.. code-block:: text
    :caption: notes

    It is a more sophisticated dithering than simple RND. It gives the most low noise floor
    for the whole spectrum even without noise-shaping. You can use as big N as you can afford
    (it will not hurt), but 4 or 5 is generally enough.


.. code-block:: c++
    :linenos:
    :caption: code

    Basically, next value is calculated this way (for RND going from -0.5 to 0.5):
    
    dither = (RND+RND+...+RND) / N.
               \           /
                \_________/
                  N times
    
    If your RND goes from 0 to 1, then this code is applicable:
    
    dither = (RND+RND+...+RND - 0.5*N) / N.
    

