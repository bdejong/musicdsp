C-Weighed Filter
================

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** digital implementation (after bilinear transform)
- **Created:** 2006-07-12 19:12:16


.. code-block:: text
    :caption: notes

    unoptimized version!


.. code-block:: c++
    :linenos:
    :caption: code

    First prewarp the frequency of both poles:
    
    K1 = tan(0.5*Pi*20.6 / SampleRate) // for 20.6Hz
    K2 = tan(0.5*Pi*12200 / SampleRate) // for 12200Hz
    
    Then calculate the both biquads:
    
     b0 = 1
     b1 = 0
     b2 =-1
     a0 = ((K1+1)*(K1+1)*(K2+1)*(K2+1));
     a1 =-4*(K1*K1*K2*K2+K1*K1*K2+K1*K2*K2-K1-K2-1)*t;
     a2 =-  ((K1-1)*(K1-1)*(K2-1)*(K2-1))*t;
    
    and:
    
     b3 = 1
     b4 = 0
     b5 =-1
     a3 = ((K1+1)*(K1+1)*(K2+1)*(K2+1));
     a4 =-4*(K1*K1*K2*K2+K1*K1*K2+K1*K2*K2-K1-K2-1)*t;
     a5 =-  ((K1-1)*(K1-1)*(K2-1)*(K2-1))*t;
    
    Now use an equation for calculating the biquads like this:
    
    Stage1 = b0*Input                 + State0;
    State0 =           + a1/a0*Stage1 + State1;
    State1 = b2*Input  + a2/a0*Stage1;
    
    Output = b3*Stage1                + State2;
    State2 =           + a4/a3*Output + State2;
    State3 = b5*Stage1 + a5/a3*Output;

Comments
--------

- **Date**: 2006-07-12 21:07:28
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    You might still need to normalize the filter output. You can do this easily by multipliing either the b0 and b2 or the b3 and b5 with a constant.
    Typically the filter is normalized to have a gain of 0dB at 1kHz
    
    Also oversampling of this filter might be useful.

