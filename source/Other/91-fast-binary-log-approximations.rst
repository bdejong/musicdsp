Fast binary log approximations
==============================

- **Author or source:** gro.lortnocdnim@gro.psdcisum
- **Type:** C code
- **Created:** 2002-04-04 17:00:05


.. code-block:: text
    :caption: notes

    This code uses IEEE 32-bit floating point representation knowledge to quickly compute
    approximations to the log2 of a value. Both functions return under-estimates of the actual
    value, although the second flavour is less of an under-estimate than the first (and might
    be sufficient for using in, say, a dBV/FS level meter).
    
    Running the test program, here's the output:
    
    0.1: -4  -3.400000
    1:   0  0.000000
    2:   1  1.000000
    5:   2  2.250000
    100: 6  6.562500


.. code-block:: c++
    :linenos:
    :caption: code

    // Fast logarithm (2-based) approximation
    // by Jon Watte
    
    #include <assert.h>
    
    int floorOfLn2( float f ) {
      assert( f > 0. );
      assert( sizeof(f) == sizeof(int) );
      assert( sizeof(f) == 4 );
      return (((*(int *)&f)&0x7f800000)>>23)-0x7f;
    }
    
    float approxLn2( float f ) {
      assert( f > 0. );
      assert( sizeof(f) == sizeof(int) );
      assert( sizeof(f) == 4 );
      int i = (*(int *)&f);
      return (((i&0x7f800000)>>23)-0x7f)+(i&0x007fffff)/(float)0x800000;
    }
    
    // Here's a test program:
    
    #include <stdio.h>
    
    // insert code from above here
    
    int
    main()
    {
      printf( "0.1: %d  %f\n", floorOfLn2( 0.1 ), approxLn2( 0.1 ) );
      printf( "1:   %d  %f\n", floorOfLn2( 1. ), approxLn2( 1. ) );
      printf( "2:   %d  %f\n", floorOfLn2( 2. ), approxLn2( 2. ) );
      printf( "5:   %d  %f\n", floorOfLn2( 5. ), approxLn2( 5. ) );
      printf( "100: %d  %f\n", floorOfLn2( 100. ), approxLn2( 100. ) );
      return 0;
    }

Comments
--------

- **Date**: 2002-12-18 20:08:06
- **By**: ed.bew@raebybot

.. code-block:: text

    Here is some code to do this in Delphi/Pascal:
    
    function approxLn2(f:single):single;
    begin
     result:=(((longint((@f)^) and $7f800000) shr 23)-$7f)+(longint((@f)^) and $007fffff)/$800000;
    end;
    
    function floorOfLn2(f:single):longint;
    begin
     result:=(((longint((@f)^) and $7f800000) shr 23)-$7f);
    end;
    
    Cheers,
    
    Tobybear
    www.tobybear.de
    
    

