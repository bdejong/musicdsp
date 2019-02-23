Type : LPF 24dB/Oct
===================

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** Bessel Lowpass
- **Created:** 2006-07-28 17:59:18


.. code-block:: text
    :caption: notes

    The filter tends to be unsable for low frequencies in the way, that it seems to flutter,
    but it never explode. At least here it doesn't.


.. code-block:: c++
    :linenos:
    :caption: code

    First calculate the prewarped digital frequency: 
    
    K  = tan(Pi * Frequency / Samplerate); 
    K2 = K*K; // speed improvement
    
    Then calc the digital filter coefficients:
    
    A0 =  ((((105*K + 105)*K + 45)*K + 10)*K + 1);
    A1 = -( ((420*K + 210)*K2        - 20)*K - 4)*t;
    A2 = -(  (630*K2         - 90)*K2        + 6)*t;
    A3 = -( ((420*K - 210)*K2        + 20)*K - 4)*t;
    A4 = -((((105*K - 105)*K + 45)*K - 10)*K + 1)*t;
    
    B0 = 105*K2*K2;
    B1 = 420*K2*K2;
    B2 = 630*K2*K2;
    B3 = 420*K2*K2;
    B4 = 105*K2*K2;
    
    Per sample calculate:
    
    Output = B0*Input                + State0;
    State0 = B1*Input + A1/A0*Output + State1;
    State1 = B2*Input + A2/A0*Output + State2;
    State2 = B3*Input + A3/A0*Output + State3;
    State3 = B4*Input + A4/A0*Output;
    
    For high speed substitude A1/A0 with A1' = A1/A0...

Comments
--------

- **Date**: 2006-07-28 22:21:29
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    It turns out, that the filter is only unstable if the coefficient/state precision isn't high enough. Using double instead of single precision already makes it a lot more stable.

- **Date**: 2006-10-16 00:42:11
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Just found out, that I forgot to remove the temporary variable 't'. It was used in my code for the speedup. You can simply ignore and delete it.

- **Date**: 2009-02-13 14:24:41
- **By**: kd.oohay@eeffocetarak

.. code-block:: text

    Changing the frequency also seems to affect the volume quite a lot. That can't be right? Maybe you should re-post this (and remove the "t" this time)?  ;)

- **Date**: 2013-02-13 11:58:19
- **By**: ur.sgn@fez_jd

.. code-block:: text

                  Your filter does not work! Arise overload in the calculation of coefficients A and B in the cutoff frequency of approximately 10 khz. At low frequencies, the coefficient of the gain increases proportional to the frequency cutoff, which causes congestion. I also noticed that the filter on this basis, the package of ASIO/DSP - DDspBesselFilter.pas does not work, although Butterworth (DDspButterworthFilter.pas) and Chebyshev (DDspChebyshevFilter.pas) work perfectly!

