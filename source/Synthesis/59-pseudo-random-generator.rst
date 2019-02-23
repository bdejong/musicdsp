Pseudo-Random generator
=======================

- **Author or source:** Hal Chamberlain, "Musical Applications of Microprocessors" (Phil Burk)
- **Type:** Linear Congruential, 32bit
- **Created:** 2002-01-17 03:11:50


.. code-block:: text
    :caption: notes

    This can be used to generate random numeric sequences or to synthesise a white noise audio
    signal.
    If you only use some of the bits, use the most significant bits by shifting right.
    Do not just mask off the low bits.


.. code-block:: c++
    :linenos:
    :caption: code

    /* Calculate pseudo-random 32 bit number based on linear congruential method. */
    unsigned long GenerateRandomNumber( void )
    {
       /* Change this for different random sequences. */
       static unsigned long randSeed = 22222;
       randSeed = (randSeed * 196314165) + 907633515;
       return randSeed;
    }

