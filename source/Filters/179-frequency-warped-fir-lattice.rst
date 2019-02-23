Frequency warped FIR lattice
============================

- **Author or source:** ten.enegatum@liam
- **Type:** FIR using allpass chain
- **Created:** 2004-08-24 11:39:28


.. code-block:: text
    :caption: notes

    Not at all optimized and pretty hungry in terms of arrays and overhead (function requires
    two arrays containing lattice filter's internal state and ouputs to another two arrays
    with their next states).  In this implementation I think you'll have to juggle
    taps1/newtaps in your processing loop, alternating between one set of arrays and the other
    for which to send to wfirlattice).
    
    A frequency-warped lattice filter is just a lattice filter where every delay has been
    replaced with an allpass filter.  By adjusting the allpass filters, the frequency response
    of the filter can be adjusted (e.g., design an FIR that approximates some filter.  Play
    with with warping coefficient to "sweep" the FIR up and down without changing any other
    coefficients).  Much more on warped filters can be found on Aki Harma's website (
    http://www.acoustics.hut.fi/~aqi/ )


.. code-block:: c++
    :linenos:
    :caption: code

    float wfirlattice(float input, float *taps1, float *taps2, float *reflcof, float lambda, float *newtaps1, float *newtaps2, int P)
    // input is filter input
    // taps1,taps2 are previous filter states (init to 0)
    // reflcof are reflection coefficients.  abs(reflcof) < 1 for stable filter
    // lamba is warping (0 = no warping, 0.75 is close to bark scale at 44.1 kHz)
    // newtaps1, newtaps2 are new filter states
    // P is the order of the filter
    {
    	float forward;
    	float topline;
    
    	forward = input;
    	topline = forward;
    
    	for (int i=0;i<P;i++)
    	{
    		newtaps2[i] = topline;
    		newtaps1[i] = float(lambda)*(-topline + taps1[i]) + taps2[i];
    		topline = newtaps1[i]+forward*(reflcof[i]);
    		forward += newtaps1[i]*(reflcof[i]);
    		taps1[i]=newtaps1[i];
    		taps2[i]=newtaps2[i];
    	}
    	return forward;
    }

Comments
--------

- **Date**: 2004-08-24 17:26:59
- **By**: ten.xmg@zlipzzuf

.. code-block:: text

    Couldn't you easily do away with newtaps entirely? As in:
    
    for(int i=0;i&lt;P;i++)
    {
        taps1[i]=lambda*(taps1[i]-topline)+taps2[i];
        taps2[i]=topline;
        topline=taps1[i]+forward*reflcof[i];
        forward+=taps1[i]*reflcof[i];
    }
    
    I haven't had time to try this in a plugin yet, but if Maple is to be trusted at all, that works.
    
    (2WarpDelay is nice, by the way)

- **Date**: 2004-08-25 07:32:40
- **By**: ten.enegatum@liam

.. code-block:: text

    haha, thanks, that's awesome!  how embarassing ;)
    
    (glad you like 2warpdelay!  the warped IIR lattice is up on harma's site too, though you might save yourself time if you read the errata: http://www.acoustics.hut.fi/~aqi/papers/oops.html :( )

- **Date**: 2008-11-12 01:15:07
- **By**: moc.toohay@ttevad

.. code-block:: text

    This looks really interesting.
    How do I get the coeffs for it, and how do I invert it to get back to the original signal?
    Thanks,
    DaveT
    
    
    

