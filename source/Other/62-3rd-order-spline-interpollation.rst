3rd order Spline interpollation
===============================

- **Author or source:** Dave from Muon Software, originally from Josh Scholar
- **Created:** 2002-01-17 03:14:54


.. code-block:: text
    :caption: notes

    (from Joshua Scholar about Spline interpollation in general...)
    According to sampling theory, a perfect interpolation could be found by replacing each
    sample with a sinc function centered on that sample, ringing at your target nyquest
    frequency, and at each target point you just sum all of contributions from the sinc
    functions of every single point in source.
    The sinc function has ringing that dies away very slowly, so each target sample will have
    to have contributions from a large neighborhood of source samples. Luckily, by definition
    the sinc function is bandwidth limited, so once we have a source that is prefilitered for
    our target nyquest frequency and reasonably oversampled relative to our nyquest frequency,
    ordinary interpolation techniques are quite fruitful even though they would be pretty
    useless if we hadn't oversampled.
    
    We want an interpolation routine that at very least has the following characteristics:
    
    1. Obviously it's continuous. But since finite differencing a signal (I don't really know
    about true differentiation) is equivalent to a low frequency attenuator that drops only
    about 6 dB per octave, continuity at the higher derivatives is important too.
    
    2. It has to be stiff enough to find peaks when our oversampling missed them. This is
    where what I said about the combination the sinc function's limited bandwidth and
    oversampling making interpolation possible comes into play.
    
    I've read some papers on splines, but most stuff on splines relates to graphics and uses a
    control point descriptions that is completely irrelevant to our sort of interpolation. In
    reading this stuff I quickly came to the conclusion that splines:
    
    1. Are just piecewise functions made of polynomials designed to have some higher order
    continuity at the transition points.
    
    2. Splines are highly arbitrary, because you can choose arbitrary derivatives (to any
    order) at each transition. Of course the more you specify the higher order the polynomials
    will be.
    
    3. I already know enough about polynomials to construct any sort of spline. A polynomial
    through 'n' points with a derivative specified at 'm[1]' points and second derivatives
    specified at 'm[2]' points etc. will be a polynomial of the order n-1+m[1]+m[2]...
    
    A way to construct third order splines (that admittedly doesn't help you construct higher
    order splines), is to linear interpolate between two parabolas. At each point (they are
    called knots) you have a parabola going through that point, the previous and the next
    point. Between each point you linearly interpolate between the polynomials for each point.
    This may help you imagine splines.
    
    As a starting point I used a polynomial through 5 points for each knot and used MuPad (a
    free Mathematica like program) to derive a polynomial going through two points (knots)
    where at each point it has the same first two derivatives as a 4th order polynomial
    through the surrounding 5 points. My intuition was that basing it on polynomials through 3
    points wouldn't be enough of a neighborhood to get good continuity. When I tested it, I
    found that not only did basing it on 5 point polynomials do much better than basing it on
    3 point ones, but that 7 point ones did nearly as badly as 3 point ones. 5 points seems to
    be a sweet spot.
    
    However, I could have set the derivatives to a nearly arbitrary values - basing the values
    on those of polynomials through the surrounding points was just a guess.
    
    I've read that the math of sampling theory has different interpretation to the sinc
    function one where you could upsample by making a polynomial through every point at the
    same order as the number of points and this would give you the same answer as sinc
    function interpolation (but this only converges perfectly when there are an infinite
    number of points). Your head is probably spinning right now - the only point of mentioning
    that is to point out that perfect interpolation is exactly as stiff as a polynomial
    through the target points of the same order as the number of target points.


.. code-block:: c++
    :linenos:
    :caption: code

    //interpolates between L0 and H0 taking the previous (L1) and next (H1)
    points into account
    inline float ThirdInterp(const float x,const float L1,const float L0,const
    float H0,const float H1)
    {
        return
        L0 +
        .5f*
        x*(H0-L1 +
           x*(H0 + L0*(-2) + L1 +
              x*( (H0 - L0)*9 + (L1 - H1)*3 +
                 x*((L0 - H0)*15 + (H1 -  L1)*5 +
                    x*((H0 - L0)*6 + (L1 - H1)*2 )))));
    }

Comments
--------

- **Date**: 2002-05-21 06:14:20
- **By**: moc.a@a

.. code-block:: text

    What is x ?

- **Date**: 2002-06-09 19:45:59
- **By**: yahoo.co.uk@sewar_ekim

.. code-block:: text

    The samples being interpolated represent the wave amplitude at a particular instant of time, T - an impulse train. So each sample is the amplitude at T=0,1,2,3 etc.
    
    The purpose of interpolation is to determine the amplitude, a, for an arbitrary t, where t is any real number:
    
       p1      p0  a   n0      n1
       :       :   :   :       :
       0-------1---t---2-------3------> T
               :   :
               :   : 
               <-x->
                   
    x = t - T(p0)
    
    - 
    myk
    

- **Date**: 2002-06-09 19:53:03
- **By**: yahoo.co.uk@sewar_ekim

.. code-block:: text

    Dang! My nice diagram had its spacing stolen, and it now makes no sense!
    
    p1, p0, n0, n1 are supposed to line up with 0,1,2,3 respectively. a is supposed to line up with the t. And finally, <-x-> spans between 1 and t.
    
    - 
    myk

- **Date**: 2002-09-16 02:34:30
- **By**: lc.arret@assenacf

.. code-block:: text

    1.- What is 5f ?
    
    2.- How I can test this procedure?.
    
    Thank you
    
    

- **Date**: 2003-04-15 10:59:26
- **By**: moc.oohay@SIHT_EVOMER_ralohcshsoj

.. code-block:: text

    This is years later. but just in case anyone has the same problem as fcanessa...  In C or C++ you can append an 'f' to a number to make it single precision, so .5f is the same as .5
    

- **Date**: 2012-07-10 13:51:17
- **By**: ac.cisum-mutnauq@noidc

.. code-block:: text

    About that thing you've said "5 point seems to be the sweet spot". Well, it might depends on the sampling rate.

