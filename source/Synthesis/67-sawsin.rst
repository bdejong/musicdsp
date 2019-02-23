SawSin
======

- **Author or source:** Alexander Kritov
- **Type:** Oscillator shape
- **Created:** 2002-02-10 12:40:59



.. code-block:: c++
    :linenos:
    :caption: code

    double sawsin(double x)
    {
       double t = fmod(x/(2*M_PI),(double)1.0);
       if (t>0.5)
           return -sin(x);
       if (t<=0.5)
           return (double)2.0*t-1.0;
    }

