Sine calculation
================

- **Author or source:** Phil Burk
- **Type:** waveform generation, Taylor approximation of sin()
- **Created:** 2002-01-17 00:57:01


.. code-block:: text
    :caption: notes

    Code from JSyn for a sine wave generator based on a Taylor Expansion. It is not as
    efficient as the filter methods, but it has linear frequency control and is, therefore,
    suitable for FM or other time varying applications where accurate frequency is needed. The
    sine generated is accurate to at least 16 bits.


.. code-block:: c++
    :linenos:
    :caption: code

    for(i=0; i < nSamples ; i++)
    {
      //Generate sawtooth phasor to provide phase for sine generation
      IncrementWrapPhase(phase, freqPtr[i]);
      //Wrap phase back into region where results are more accurate
    
      if(phase > 0.5)
        yp = 1.0 - phase;
      else
      {
        if(phase < -0.5)
           yp = -1.0 - phase;
        else
            yp = phase;
      }
    
      x = yp * PI;
      x2 = x*x;
    
      //Taylor expansion out to x**9/9! factored  into multiply-adds
      fastsin = x*(x2*(x2*(x2*(x2*(1.0/362880.0)
                - (1.0/5040.0))
                + (1.0/120.0))
                - (1.0/6.0))
                + 1.0);
    
      outPtr[i] = fastsin * amplPtr[i];
    }

