Hermite interpollation
======================

- **Author or source:** various
- **Created:** 2002-04-09 16:55:35


.. code-block:: text
    :caption: notes

    These are all different ways to do the same thing : hermite interpollation. Try'm all and
    benchmark.


.. code-block:: c++
    :linenos:
    :caption: code

    // original
    inline float hermite1(float x, float y0, float y1, float y2, float y3)
    {
        // 4-point, 3rd-order Hermite (x-form)
        float c0 = y1;
        float c1 = 0.5f * (y2 - y0);
        float c2 = y0 - 2.5f * y1 + 2.f * y2 - 0.5f * y3;
        float c3 = 1.5f * (y1 - y2) + 0.5f * (y3 - y0);
    
        return ((c3 * x + c2) * x + c1) * x + c0;
    }
    
    // james mccartney
    inline float hermite2(float x, float y0, float y1, float y2, float y3)
    {
        // 4-point, 3rd-order Hermite (x-form)
        float c0 = y1;
        float c1 = 0.5f * (y2 - y0);
        float c3 = 1.5f * (y1 - y2) + 0.5f * (y3 - y0);
        float c2 = y0 - y1 + c1 - c3;
    
        return ((c3 * x + c2) * x + c1) * x + c0;
    }
    
    // james mccartney
    inline float hermite3(float x, float y0, float y1, float y2, float y3)
    {
            // 4-point, 3rd-order Hermite (x-form)
            float c0 = y1;
            float c1 = 0.5f * (y2 - y0);
            float y0my1 = y0 - y1;
            float c3 = (y1 - y2) + 0.5f * (y3 - y0my1 - y2);
            float c2 = y0my1 + c1 - c3;
    
            return ((c3 * x + c2) * x + c1) * x + c0;
    }
    
    // laurent de soras
    inline float hermite4(float frac_pos, float xm1, float x0, float x1, float x2)
    {
       const float    c     = (x1 - xm1) * 0.5f;
       const float    v     = x0 - x1;
       const float    w     = c + v;
       const float    a     = w + v + (x2 - x0) * 0.5f;
       const float    b_neg = w + a;
    
       return ((((a * frac_pos) - b_neg) * frac_pos + c) * frac_pos + x0);
    }

Comments
--------

- **Date**: 2002-05-25 13:37:32
- **By**: theguylle

.. code-block:: text

                  great sources but what is Hermite ?
    if you don't describe what is your code made for, you will made a great sources but I don't know why?
    
    cheers Paul

- **Date**: 2002-08-15 00:48:25
- **By**: gro.psdcisum@marb

.. code-block:: text

    hermite is interpollation.
    have a look around the archive, you'll see that the word 'hermite' is in more than one item ;-)
    
      -bram

- **Date**: 2003-07-29 10:46:40
- **By**: rb.moc.rapenas@fwodlanor

.. code-block:: text

    Please, would like to know of hermite code it exists in delphi.
      
    thankful
    
    Ronaldo
    Cascavel/Paraná/Brasil

- **Date**: 2003-10-10 08:36:06
- **By**: moc.rotces-dabMAPSON@inirgam.m

.. code-block:: text

    Please,
    add, at least, the meaning of each parameter (I mean x, y0,  y1,y2,  y3)....
    m.         

- **Date**: 2003-11-28 10:48:17
- **By**: musicdsp@[remove this]dsparsons.co.uk

.. code-block:: text

    Ronaldo, it doesn't take much to translate these to Delphi - for float, either use single or double to your preference!
    
    Looking at the codes, it seems quite clear that the parameters follow a pattern of: Sample Position between middle two samples, then the sample before current, current sample, curernt sample +1, current sample +2.
    
    HTH
    DSP            

- **Date**: 2004-03-28 20:51:59
- **By**: moc.liamtoh@sisehtnysorpitna

.. code-block:: text

    What are all these variables standing for? Not very clear :|

- **Date**: 2004-04-20 00:25:29
- **By**: George

.. code-block:: text

    parameters are allright. 
    
    xm1 ---> x[n-1]
    x0  ---> x[n]
    x1  ---> x[n+1]
    x2  ---> x[n+2]
    
    fractional position stands for a fraction between 0 and 1 to interpolate

- **Date**: 2004-10-17 01:16:50
- **By**: snehpyhehttuoekatdnatahwwonkuoy.liamg@rood-nosiop-saionarap

.. code-block:: text

    Couldn't #2 be sped up a hair by commenting out
    
    float c0 = y1; 
    
    and then replacing c0 with y1 in the return line?  Or do the compilers do that kind of thing automatically when they optimize?

- **Date**: 2007-07-13 01:52:27
- **By**: moc.oi@htnysa

.. code-block:: text

    "Couldn't #2 be sped up a hair"
    It gets optimized out.

