Gaussian White noise
====================

- **Author or source:** Alexey Menshikov
- **Created:** 2002-08-01 01:13:47


.. code-block:: text
    :caption: notes

    Code I use sometimes, but don't remember where I ripped it from.
    
     - Alexey Menshikov


.. code-block:: c++
    :linenos:
    :caption: code

    #define ranf() ((float) rand() / (float) RAND_MAX)
    
    float ranfGauss (int m, float s)
    {
       static int pass = 0;
       static float y2;
       float x1, x2, w, y1;
    
       if (pass)
       {
          y1 = y2;
       } else  {
          do {
             x1 = 2.0f * ranf () - 1.0f;
             x2 = 2.0f * ranf () - 1.0f;
             w = x1 * x1 + x2 * x2;
          } while (w >= 1.0f);
    
          w = (float)sqrt (-2.0 * log (w) / w);
          y1 = x1 * w;
          y2 = x2 * w;
       }
       pass = !pass;
    
       return ( (y1 * s + (float) m));
    }

Comments
--------

- **Date**: 2004-01-29 15:41:35
- **By**: davidchristenATgmxDOTnet

.. code-block:: text

    White Noise does !not! consist of uniformly distributed values. Because in white noise, the power of the frequencies are uniformly distributed. The values must be normal (or gaussian) distributed. This is achieved by the Box-Muller Transformation. This function is the polar form of the Box-Muller Transformation. It is faster and numeriacally more stable than the basic form. The basic form is coded in the other (second) post.
    Detailed information on this topic:
    http://www.taygeta.com/random/gaussian.html
    http://www.eece.unm.edu/faculty/bsanthan/EECE-541/white2.pdf
    
    Cheers David

- **Date**: 2007-09-06 04:09:52
- **By**: moc.dlrownepotb@wahs.a.kcin

.. code-block:: text

    I'm trying to implement this in C#, but y2 isn't initialized. Is this a typo?         

- **Date**: 2010-07-17 20:35:18
- **By**: ed.rab@oof

.. code-block:: text

    @nick: Way to late, but y2 will always be initialized as in the first run "pass" is 0 (i.e. false). The C# compiler just can't prove it.

- **Date**: 2011-09-03 20:43:59
- **By**: moc.liamg@htnysa

.. code-block:: text

    David is wrong. The distribution of the sample values is irrelevant. 'white' simply describes the spectrum. Any series of sequentially independent random values -- whatever their distribution -- will have a white spectrum.

