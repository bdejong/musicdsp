Pow(x,4) approximation
======================

- **Author or source:** Stefan Stenzel
- **Created:** 2002-01-17 03:09:20


.. code-block:: text
    :caption: notes

    Very hacked, but it gives a rough estimate of x**4 by modifying exponent and mantissa.


.. code-block:: c++
    :linenos:
    :caption: code

    float p4fast(float in)
    {
      long *lp,l;
    
      lp=(long *)(&in);
      l=*lp;
    
      l-=0x3F800000l; /* un-bias */
      l<<=2;          /* **4 */
      l+=0x3F800000l; /* bias */
      *lp=l;
    
      /* compiler will read this from memory since & operator had been used */
      return in;
    }

