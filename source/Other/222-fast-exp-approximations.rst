Fast exp() approximations
=========================

- **Author or source:** uh.etle.fni@yfoocs
- **Type:** Taylor series approximation
- **Created:** 2006-05-26 04:54:44


.. code-block:: text
    :caption: notes

    I needed a fast exp() approximation in the -3.14..3.14 range, so I made some
    approximations based on the tanh() code posted in the archive by Fuzzpilz. Should be
    pretty straightforward, but someone may find this useful.
    
    The increasing numbers in the name of the function means increasing precision. Maximum
    error in the -1..1 range:
    fastexp3: 0.05      (1.8%)
    fastexp4: 0.01      (0.36%)
    fastexp5: 0.0016152 (0.59%)
    fastexp6: 0.0002263 (0.0083%)
    fastexp7: 0.0000279 (0.001%)
    fastexp8: 0.0000031 (0.00011%)
    fastexp9: 0.0000003 (0.000011%)
    
    Maximum error in the -3.14..3.14 range:
    fastexp3: 8.8742 (38.4%)
    fastexp4: 4.8237 (20.8%)
    fastexp5: 2.28   (9.8%)
    fastexp6: 0.9488 (4.1%)
    fastexp7: 0.3516 (1.5%)
    fastexp8: 0.1172 (0.5%)
    fastexp9: 0.0355 (0.15%)
    
    These were done using the Taylor series, for example I got fastexp4 by using:
    exp(x) = 1 + x + x^2/2 + x^3/6 + x^4/24 + ...
    = (24 + 24x + x^2*12 + x^3*4 + x^4) / 24
    (using Horner-scheme:)
    = (24 + x * (24 + x * (12 + x * (4 + x)))) * 0.041666666f
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    inline float fastexp3(float x) { 
        return (6+x*(6+x*(3+x)))*0.16666666f; 
    }
    
    inline float fastexp4(float x) {
        return (24+x*(24+x*(12+x*(4+x))))*0.041666666f;
    }
    
    inline float fastexp5(float x) {
        return (120+x*(120+x*(60+x*(20+x*(5+x)))))*0.0083333333f;
    }
    
    inline float fastexp6(float x) {
        return 720+x*(720+x*(360+x*(120+x*(30+x*(6+x))))))*0.0013888888f;
    }
    
    inline float fastexp7(float x) {
        return (5040+x*(5040+x*(2520+x*(840+x*(210+x*(42+x*(7+x)))))))*0.00019841269f;
    }
    
    inline float fastexp8(float x) {
        return (40320+x*(40320+x*(20160+x*(6720+x*(1680+x*(336+x*(56+x*(8+x))))))))*2.4801587301e-5;
    }
    
    inline float fastexp9(float x) {
      return (362880+x*(362880+x*(181440+x*(60480+x*(15120+x*(3024+x*(504+x*(72+x*(9+x)))))))))*2.75573192e-6;
    }
    

Comments
--------

- **Date**: 2006-07-03 00:40:15
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    These series converge fast only near zero. But there is an identity:
    
     exp(x) = exp(a) * exp(x-a)
    
    So, if you want a relatively fast polynomial approximation for exp(x) for 0 to ~7.5, you can use:
    
    // max error in the 0 .. 7.5 range: ~0.45%
    inline float fastexp(float const &x)
    {
      if (x<2.5)
          return 2.7182818f * fastexp5(x-1.f); 
      else if (x<5) 
          return 33.115452f * fastexp5(x-3.5f); 
      else 
          return 403.42879f * fastexp5(x-6.f); 
    }
    
    where 2.7182.. = exp(1), 33.1154.. = exp(3.5) and 403.428.. = exp(6). I chose these values because fastexp5 has a maximum error of 0.45% between -1 - 1.5 (using fastexp6, the maximum error is 0.09%).
    
    Using the identity
    
      pow(a,x) = exp(x * log(a))
    
    you can use any base, for example to get 2^x:
    
    // max error in the 0-10.58 range: ~0.45%
    inline float fastpow2(float const &x)
    {
      float const log_two = 0.6931472f;
      return fastexp(x * log_two);
    }
    
    These functions are about 3x faster than exp().
    
    -- Peter Schoffhauzer
    

