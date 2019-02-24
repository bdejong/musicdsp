Soft saturation
===============

- **Author or source:** Bram de Jong
- **Type:** waveshaper
- **Created:** 2002-01-17 02:18:37


.. code-block:: text
    :caption: notes

    This only works for positive values of x. a should be in the range 0..1


.. code-block:: c++
    :linenos:
    :caption: code

    x < a:
      f(x) = x
    x > a:
      f(x) = a + (x-a)/(1+((x-a)/(1-a))^2)
    x > 1:
      f(x) = (a+1)/2

Comments
--------

- **Date**: 2005-09-09 21:17:55
- **By**: gro.esabnaeco@euarg

.. code-block:: text

    This is a most excellent waveshaper.
    
    I have implemented it as an effect for the music tracker Psycle, and so far I am very pleased with the
    results. Thanks for sharing this knowledge, Bram!

- **Date**: 2006-03-12 02:35:16
- **By**: moc.erawtfosnetpot@nosniborb

.. code-block:: text

    I'm wondering about the >1 condition here.  If a is 0.8, values <1 approach 0.85 but values >1
    are clamped to 0.9  (there's a gap)
    
    If you substitute x=1 to the equation for x>a you get: a+((1-a)/4) not (a+1)/2
    
    Have I missed something or is there a reason for this? 
    
    (Go easy I'm new to all of this)

- **Date**: 2006-08-23 06:19:05
- **By**: moc.liamg@ubibik

.. code-block:: text

    Substituting x=1 into equation 2 (taking many steps)
    
    f(x) = a + (x-a)/(1+ ((x-a)/(1-a))^2)
         = a + (1-a)/(1+ ((1-a)/(1-a))^2)
         = a + (1-a)/(1+ 1^2)
         = a + (1-a)/2
         = 2a/2 + (1-a)/2
         = (2a + 1 - a) /2
         = (a+1) / 2

- **Date**: 2006-08-24 11:03:04
- **By**: musicdsp@Nospam dsparsons.co.uk

.. code-block:: text

    You can normalise the output:
    f(x)'=f(x)*(1/((a+1)/2))
    
    This gives a nice variable shaper with smooth curve upto clipping at 0dBFS

