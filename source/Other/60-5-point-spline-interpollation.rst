5-point spline interpollation
=============================

- **Author or source:** Joshua Scholar,David Waugh
- **Type:** interpollation
- **Created:** 2002-01-17 03:12:34



.. code-block:: c++
    :linenos:
    :caption: code

    //nMask = sizeofwavetable-1 where sizeofwavetable is a power of two.
    double interpolate(double* wavetable, int nMask, double location)
    {
        /* 5-point spline*/
    
        int nearest_sample = (int) location;
        double x = location - (double) nearest_sample;
    
        double p0=wavetable[(nearest_sample-2)&nMask];
        double p1=wavetable[(nearest_sample-1)&nMask];
        double p2=wavetable[nearest_sample];
        double p3=wavetable[(nearest_sample+1)&nMask];
        double p4=wavetable[(nearest_sample+2)&nMask];
        double p5=wavetable[(nearest_sample+3)&nMask];
    
        return p2 + 0.04166666666*x*((p3-p1)*16.0+(p0-p4)*2.0
        + x *((p3+p1)*16.0-p0-p2*30.0- p4
        + x *(p3*66.0-p2*70.0-p4*33.0+p1*39.0+ p5*7.0- p0*9.0
        + x *( p2*126.0-p3*124.0+p4*61.0-p1*64.0- p5*12.0+p0*13.0
        + x *((p3-p2)*50.0+(p1-p4)*25.0+(p5-p0)*5.0)))));
    };

Comments
--------

- **Date**: 2003-05-27 12:20:46
- **By**: moc.oohay@SIHTEVOMERralohcshsoj

.. code-block:: text

    The code works much better if you oversample before interpolating. If you oversample enough (maybe 4 to 6 times oversampling) then the results are audiophile quality.    

- **Date**: 2010-08-26 20:55:45
- **By**: moc.oohay@xofirgomsnart

.. code-block:: text

    This looks old...but if anybody reads this:
    What do you mean by oversample first?  That is practically what you are doing with interpolation.  For example, if you want to oversample 6x, you would interpolate 5 evenly spaced points in between p2 and p3 using 5 points at base frequency centered around p2.  The 5-point spline interpolation seems like a lower CPU algorithm than a good sinc interpolation, and as a bonus it does not have much of a transient response (only 5 samples worth).  
    
    My main target application for something like this is delay line interpolation where there is a concern regarding high frequency notch depth...5th order interpolation is certainly an improvement over linear interpolation :)              

- **Date**: 2012-10-04 08:00:31
- **By**: Josh Scholar

.. code-block:: text

    By oversample I meant do a windowed sinc doubling oversample a couple times.
    
    The point is that a 4 times oversample can be based on table values and only gives you points exactly 1/4, 1/2 and 3/4 between the samples.
    
    Then the spline can be used to interpolate totally arbitrary points between those, say speeding up and slowing down as needed, at very high quality.
    
    If you don't oversample first, you'll get an audible amount of aliasing, though not as much as a linear interpolation. Unless the source has a lot of roll off (which is equivalent to it being oversampled anyway).

- **Date**: 2014-08-16 17:55:33
- **By**: moc.liamg@rellimennad.sirhc

.. code-block:: text

    Can any explain the derivation of this?              

