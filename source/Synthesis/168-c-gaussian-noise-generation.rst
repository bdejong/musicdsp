C++ gaussian noise generation
=============================

- **Author or source:** ku.oc.latigidpxe@luap
- **Type:** gaussian noise generation
- **Created:** 2004-05-20 09:12:55


.. code-block:: text
    :caption: notes

    References :
    Tobybears delphi noise generator was the basis. Simply converted it to C++.
    Link for original is:
    http://www.musicdsp.org/archive.php?classid=0#129
    The output is in noise.


.. code-block:: c++
    :linenos:
    :caption: code

    /* Include requisits */
    #include <cstdlib>
    #include <ctime>
    
    /* Generate a new random seed from system time - do this once in your constructor */
    srand(time(0));
    
    /* Setup constants */
    const static int q = 15;
    const static float c1 = (1 << q) - 1;
    const static float c2 = ((int)(c1 / 3)) + 1;
    const static float c3 = 1.f / c1;
    
    /* random number in range 0 - 1 not including 1 */
    float random = 0.f;
    
    /* the white noise */
    float noise = 0.f;
    
    for (int i = 0; i < numSamples; i++)
    {
    	random = ((float)rand() / (float)(RAND_MAX + 1));
    	noise = (2.f * ((random * c2) + (random * c2) + (random * c2)) - 3.f * (c2 - 1.f)) * c3;
    }

Comments
--------

- **Date**: 2009-07-10 17:39:39
- **By**: moc.enon@enon

.. code-block:: text

    What's the difference between the much simpler noise generator: 
    
    randSeed = (randSeed * 196314165) + 907633515;	out=((int)randSeed)*0.0000000004656612873077392578125f;
    
    and this one? they both sound the same to my ears...

- **Date**: 2011-07-22 11:07:12
- **By**: moc.nwonknu@nwonknu

.. code-block:: text

    How can you change the variance (sigma)?

- **Date**: 2013-06-12 12:30:33
- **By**: moc.enon@lubeb

.. code-block:: text

    This is NOT a good code to generate Gaussian Noice. Look into:
      (random * c2) + (random * c2) + (random * c2)
    It is all nonsense! The reason of adding three numbers it the Central Limit Theorem to aproximate Gaussian distribution. But the random numbers inside must differ, which is not the case. The code on original link http://www.musicdsp.org/archive.php?classid=0#129 is correct.

