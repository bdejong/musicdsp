Simple peak follower
====================

- **Author or source:** Phil Burk
- **Type:** amplitude analysis
- **Created:** 2002-01-17 01:57:19


.. code-block:: text
    :caption: notes

    This simple peak follower will give track the peaks of a signal. It will rise rapidly when
    the input is rising, and then decay exponentially when the input drops. It can be used to
    drive VU meters, or used in an automatic gain control circuit.


.. code-block:: c++
    :linenos:
    :caption: code

    // halfLife = time in seconds for output to decay to half value after an impulse
    
    static float output = 0.0;
    
    float scalar = pow( 0.5, 1.0/(halfLife * sampleRate)));
    
    if( input < 0.0 )
      input = -input;  /* Absolute value. */
    
    if ( input >= output )
    {
       /* When we hit a peak, ride the peak to the top. */
       output = input;
    }
    else
    {
       /* Exponential decay of output when signal is low. */
       output = output * scalar;
       /*
       ** When current gets close to 0.0, set current to 0.0 to prevent FP underflow
       ** which can cause a severe performance degradation due to a flood
       ** of interrupts.
       */
       if( output < VERY_SMALL_FLOAT ) output = 0.0;
    }

Comments
--------

- **Date**: 2013-01-26 09:48:15
- **By**: moc.liamg@osoromaerfac

.. code-block:: text

    #ifndef VERY_SMALL_FLOAT
    #define VERY_SMALL_FLOAT 1.0e-30F
    #endif

