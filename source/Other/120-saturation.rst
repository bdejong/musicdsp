Saturation
==========

- **Author or source:** Bram
- **Type:** Waveshaper
- **Created:** 2002-09-19 14:27:46


.. code-block:: text
    :caption: notes

    when the input is below a certain threshold (t) these functions return the input, if it
    goes over that threshold, they return a soft shaped saturation.
    Neigther claims to be fast ;-)


.. code-block:: c++
    :linenos:
    :caption: code

    float saturate(float x, float t)
    {
        if(fabs(x)<t)
            return x
        else
        {
            if(x > 0.f);
                return t + (1.f-t)*tanh((x-t)/(1-t));
            else
                return -(t + (1.f-t)*tanh((-x-t)/(1-t)));
     }
    }
    
    or
    
    float sigmoid(x)
    {
        if(fabs(x)<1)
            return x*(1.5f - 0.5f*x*x);
        else
            return x > 0.f ? 1.f : -1.f;
    }
    
    float saturate(float x, float t)
    {
        if(abs(x)<t)
            return x
        else
        {
            if(x > 0.f);
                return t + (1.f-t)*sigmoid((x-t)/((1-t)*1.5f));
            else
                return -(t + (1.f-t)*sigmoid((-x-t)/((1-t)*1.5f)));
        }
    }
    

Comments
--------

- **Date**: 2002-10-15 17:22:22
- **By**: moc.oohay@yrret

.. code-block:: text

                 But My question is
    BUT HAVE YOU TRIED YOUR CODE!!!!!!!!!!!!!!!!????
    I think no, 'cos give a compiling error.
    the right (for sintax) version is this:
    
    
    float sigmoid(float x) 
    { 
        if(fabs(x)<1) 
            return x*(1.5f - 0.5f*x*x); 
        else 
            return x > 0.f ? 1.f : -1.f; 
    } 
    
    float saturate(float x, float t) 
    { 
        if(abs(x)<t) 
            return x; 
        else 
        { 
            if(x > 0.f) 
                return t + (1.f-t)*sigmoid((x-t)/((1-t)*1.5f)); 
            else 
                return -(t + (1.f-t)*sigmoid((-x-t)/((1-t)*1.5f))); 
        } 
    }  

- **Date**: 2003-11-18 10:16:14
- **By**: moc.liamtoh@tnuhhcaebmi

.. code-block:: text

    except for the missing parenthesis of course =)
    the first line of saturate should be either
    
    if(fabs(x)) return x;
    
    or
    
    if(abs(x)) return x;
    
    depending on whether you're looking at the first or second saturate function (in the orig post)

- **Date**: 2021-01-01 11:50:14
- **By**: DKDiveDude

.. code-block:: text
The first function seems to be only a unnecessary complicated brick limit function. See below how I implemented the first function's code. Left is a sample between -1 and 1, positiveThreshold and negativeThreshold should be self explanatory.

if (left > positiveThreshold)
	left = positiveThreshold + (1 - positiveThreshold) * tanh ((left - positiveThreshold) / (1 - positiveThreshold));
else if (left < negativeThreshold)
	left = -(positiveThreshold + (1 - positiveThreshold) * tanh ((-left - positiveThreshold) / (1 - positiveThreshold)));
