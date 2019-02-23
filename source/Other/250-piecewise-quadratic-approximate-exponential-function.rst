Piecewise quadratic approximate exponential function
====================================================

- **Author or source:** Johannes M.-R.
- **Type:** Approximation of base-2 exponential function
- **Created:** 2007-06-18 08:09:58


.. code-block:: text
    :caption: notes

    The code assumes round-to-zero mode, and ieee 754 float.
    To achieve other bases, multiply the input by the logarithmus dualis of the base.


.. code-block:: c++
    :linenos:
    :caption: code

    inline float fpow2(const float y)
    {
    	union
    	{
    		float f;
    		int i;
    	} c;
    
    	int integer = (int)y;
    	if(y < 0)
    		integer = integer-1;
    
    	float frac = y - (float)integer;
    
    	c.i = (integer+127) << 23;
    	c.f *= 0.33977f*frac*frac + (1.0f-0.33977f)*frac + 1.0f;
    
    	return c.f;
    }

