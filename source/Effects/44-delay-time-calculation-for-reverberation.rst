Delay time calculation for reverberation
========================================

- **Author or source:** Andy Mucho
- **Created:** 2002-01-17 02:19:54


.. code-block:: text
    :caption: notes

    This is from some notes I had scribbled down from a while back on
    automatically calculating diffuse delays. Given an intial delay line gain
    and time, calculate the times and feedback gain for numlines delay lines..


.. code-block:: c++
    :linenos:
    :caption: code

    int   numlines = 8;
    float t1 = 50.0;        // d0 time
    float g1 = 0.75;        // d0 gain
    float rev = -3*t1 / log10 (g1);
    
    for (int n = 0; n < numlines; ++n)
    {
      float dt = t1 / pow (2, (float (n) / numlines));
      float g = pow (10, -((3*dt) / rev));
      printf ("d%d t=%.3f g=%.3f\n", n, dt, g);
    }
    
    /*
    The above with t1=50.0 and g1=0.75 yields:
    
     d0 t=50.000 g=0.750
     d1 t=45.850 g=0.768
     d2 t=42.045 g=0.785
     d3 t=38.555 g=0.801
     d4 t=35.355 g=0.816
     d5 t=32.421 g=0.830
     d6 t=29.730 g=0.843
     d7 t=27.263 g=0.855
    
    To go more diffuse, chuck in dual feedback paths with a one cycle delay
    effectively creating a phase-shifter in the feedback path, then things get
    more exciting.. Though what the optimum phase shifts would be I couldn't
    tell you right now..
    */