Fast sign for 32 bit floats
===========================

- **Author or source:** Peter Schoffhauzer
- **Created:** 2007-05-14 10:15:43


.. code-block:: text
    :caption: notes

    Fast functions which give the sign of a 32 bit floating point number by checking the sign
    bit. There are two versions, one which gives the value as a float, and the other gives an
    int.
    
    The _nozero versions are faster, but they give incorrect 1 or -1 for zero (depending on
    the sign bit set in the number). The int version should be faster than the Tobybear one in
    the archive, since this one doesn't have an addition, just bit operations.
    


.. code-block:: c++
    :linenos:
    :caption: code

    /*------------------------------------------------------------------------------------
       fast sign, returns float
    ------------------------------------------------------------------------------------*/
    
    // returns 1.0f for positive floats, -1.0f for negative floats
    // for zero it does not work (may gives 1.0f or -1.0f), but it's faster 
    inline float fast_sign_nozero(float f) {
        float r = 1.0f;
        (int&)r |= ((int&)f & 0x80000000); // mask sign bit in f, set it in r if necessary
        return r;
    }
    
    // returns 1.0f for positive floats, -1.0f for negative floats, 0.0f for zero
    inline float fast_sign(float f) {
        if (((int&)f & 0x7FFFFFFF)==0) return 0.f; // test exponent & mantissa bits: is input zero?
        else {
            float r = 1.0f;
            (int&)r |= ((int&)f & 0x80000000); // mask sign bit in f, set it in r if necessary
            return r;
        }
    }
    
    /*------------------------------------------------------------------------------------
       fast sign, returns int
    ------------------------------------------------------------------------------------*/
    
    // returns 1 for positive floats, -1 for negative floats
    // for 0.0f input it does not work (may give 1 or -1), but it's faster 
    inline int fast_sign_int_nozero(float f) {
          return (signed((int&)f & 0x80000000) >> 31 ) | 1;
    }
    
    // returns 1 for positive floats, -1 for negative floats, 0 for 0.0f
    inline int fast_sign_int(float f) {
        if (((int&)f & 0x7FFFFFFF)==0) return 0; // test exponent & mantissa bits: is input zero?
        return (signed((int&)f & 0x80000000) >> 31 ) | 1;
    }

Comments
--------

- **Date**: 2007-05-15 16:49:02
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Now consider when you want to multiply a number by the sign of another:
    
      if (a>0.f) b = b; 
        else b = -b;
    
    This involves 1) a comparison, 2) a branch, 3) an inversion (multiply or bit flip) in one branch. Another method for calculating the same:
    
      b *= fast_sign_nozero_(a);
      
    This involves 1) a bitwise and, 2) a bitwise or 3) and a multiply. Using only bit operations, the branch and/or multiply can be totally eliminated:
    
    // equivalent to dest *= sgn(source)
    inline void mul_sign(float &dest, float &source) {
    	(int&)dest &= 0x7FFFFFFF; // clear sign bit 
    	(int&)dest |= ((int&)dest ^ (int&)source) & 0x80000000f; // set sign bit if necessary
    }
    
    This function has only three bitwise operations, which should be very fast. Usage:
    
      mul_sign(b,a); // b = b*sign(a)
      
    The speed increase with all these functions greatly depends on the predictability of the branches. If the branch is highly predictable (a lot of positive numbers, then a lot of negative numbers, without mixing them), then an if/else solution is pretty fast. If the branch is unpredictable (random numbers, or audio similar to white noise) then bit operations should perform significantly better on today's most CPUs with multi-level pipelines.
    
    -- Peter Schoffhauzer        

- **Date**: 2007-07-01 19:14:04
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Sorry, there is a bug in the above code. Correctly:
    
    // equivalent to dest *= sgn(source)
    inline void mul_sign_nozero(float &dest, float const &source) {
    	int sign_mask = ((int&)dest ^ (int&)source) & 0x80000000; // XOR and mask
    	(int&)dest &= 0x7FFFFFFF; // clear sign bit
    	(int&)dest |= sign_mask; // set sign bit if necessary
    }
    

