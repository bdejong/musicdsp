Cubic polynomial envelopes
==========================

- **Author or source:** Andy Mucho
- **Type:** envellope generation
- **Created:** 2002-01-17 00:59:16


.. code-block:: text
    :caption: notes

    This function runs from:
    startlevel at Time=0
    midlevel at Time/2
    endlevel at Time
    At moments of extreme change over small time, the function can generate out
    of range (of the 3 input level) numbers, but isn't really a problem in
    actual use with real numbers, and sensible/real times..


.. code-block:: c++
    :linenos:
    :caption: code

    time = 32
    startlevel = 0
    midlevel = 100
    endlevel = 120
    k = startlevel + endlevel - (midlevel * 2)
    r = startlevel
    s = (endlevel - startlevel - (2 * k)) / time
    t = (2 * k) / (time * time)
    bigr = r
    bigs = s + t
    bigt = 2 * t
    
    for(int i=0;i<time;i++)
    {
     bigr = bigr + bigs
     bigs = bigs + bigt
    }

Comments
--------

- **Date**: 2004-01-13 12:31:55
- **By**: ti.otinifni@reiruoceht

.. code-block:: text

    I have try this and it works fine, but what hell is bigs?????
    
    bye bye
    
    
                  	float time = (float)pRect.Width();		   //time in sampleframes
    	float startlevel = (float)pRect.Height();  //max h vedi ma 1.0
    	float midlevel = 500.f;
    	float endlevel = 0.f;
    	
    	float k = startlevel + endlevel - (midlevel * 2);
    	float r = startlevel;
    	float s = (endlevel - startlevel - (2 * k)) / time;
    	float t= (2 * k) / (time * time);
    
    	float bigr = r;
    	float bigs = s + t;
    	float bigt = 2 * t;
    
    	
    	for(int i=0;i<time;i++)
    	{
    		bigr = bigr + bigs;
    		bigs = bigs + bigt;							//bigs? co'è
    		pDC->SetPixel(i,(int)bigr,RGB (0, 0, 0));
    	}

- **Date**: 2006-10-08 17:50:48
- **By**: if.iki@xemxet

.. code-block:: text

    the method uses a technique called forward differencing, which is based on the fact that a successive values of an polynomial function can be calculated using only additions instead of evaluating the whole polynomial which would require huge amount of multiplications.
    
    Actually the method presented here uses only a quadratic curve, not cubic. The number of the variables in the adder is N+1, where N is the order of the polynomial to be generated. In this example we have only three, thus second order function. For linear we would have two variables: the current value and the constant adder.
    
    The trickiest part is to set up the adder variables...
    
    Check out forward difference in mathworld for more info.

