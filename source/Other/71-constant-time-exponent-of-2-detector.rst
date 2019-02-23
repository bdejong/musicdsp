Constant-time exponent of 2 detector
====================================

- **Author or source:** Brent Lehman (moc.oohay@ljbliam)
- **Created:** 2002-02-10 12:53:15


.. code-block:: text
    :caption: notes

    In your common FFT program, you want to make sure that the frame you're working with has a
    size that is a power of 2.  This tells you in just a few operations.  Granted, you won't
    be using this algorithm inside a loop, so the savings aren't that great, but every little
    hack helps  ;)


.. code-block:: c++
    :linenos:
    :caption: code

    // Quit if size isn't a power of 2
    if ((-size ^ size) & size) return;
    
    // If size is an unsigned int, the above might not compile.
    // You'd want to use this instead:
    if (((~size + 1) ^ size) & size) return;

Comments
--------

- **Date**: 2002-02-12 03:20:11
- **By**: moc.oohay@xrotcnuf

.. code-block:: text

    I think I prefer:
    
    if (! (size & (size - 1))) return;
    
    I'm not positive this is fewer instructions than the above, but I think it's easier to see why it works (n and n-1 will share bits unless n is a power of two), and it doesn't require two's-complement.
    
     - Tom 7
    

