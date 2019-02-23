Fast Float Random Numbers
=========================

- **Author or source:** moc.liamg@seir.kinimod
- **Created:** 2009-10-29 13:39:29


.. code-block:: text
    :caption: notes

    a small and fast implementation for random float numbers in the range [-1,1], usable as
    white noise oscillator.
    
    compared to the naive usage of the rand() function it gives a speedup factor of 9-10.
    
    compared to a direct implementation of the rand() function (visual studio implementation)
    it still gives a speedup by a factor of 2-3.
    
    apart from beeing faster it also provides more precision for the resulting floats since
    its base values use full 32bit precision.
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    // set the initial seed to whatever you like
    static int RandSeed = 1;
    
    // using rand() (16bit precision)
    // takes about 110 seconds for 2 billion calls
    float RandFloat1() 
    {  
        return ((float)rand()/RAND_MAX) * 2.0f - 1.0f;  
    } 
    
    // direct implementation of rand() (16 bit precision)
    // takes about 32 seconds for 2 billion calls
    float RandFloat2() 
    {  
        return ((float)(((RandSeed = RandSeed * 214013L + 2531011L) >> 16) & 0x7fff)/RAND_MAX) * 2.0f - 1.0f;  
    }  
    
    // fast rand float, using full 32bit precision
    // takes about 12 seconds for 2 billion calls
    float Fast_RandFloat()
    {
        RandSeed *= 16807;
        return (float)RandSeed * 4.6566129e-010f;
    }

Comments
--------

- **Date**: 2009-11-20 23:40:37
- **By**: judahmenter@gee mail.com

.. code-block:: text

    There is no doubt that implementation 3 is fast, but the problem I had with it is that there's no obvious way to limit the amplitude of the generated signal.
    
    So instead I tried implementation 2 and ran into a different problem. The code is written such that it assumes that RAND_MAX is equal to 0x7FFF, which was not true on my system (it was 0x7FFFFFFF). Fortunately, this was easy to fix. I simply removed the >> 16 and worked fine for me. My final implementation was:
    
    return (float)(RandSeed = RandSeed * 214013L + 2531011L) / 0x7FFFFFFF * 2.0f * amp - amp;
    
    where "amp" is the desired amplitude.

- **Date**: 2009-12-29 22:53:23
- **By**: earlevel [] earlevel [] com

.. code-block:: text

    It should be noted in the code that for method #3, you must initialize the seed to non-zero before using it.

- **Date**: 2010-01-24 16:36:03
- **By**: moc.boohay@bob

.. code-block:: text

    I don't understand Judahmenter's comment about 3 not limiting the amplitude. As it stands it returns a value -1 to 1, so just multiply by your 'amp' value.
    This turns into a handy 0-1 random number if you take off the sign bit:
    (float)(RandSeed & 0x7FFFFFFF) * 4.6566129e-010f;
    
    

