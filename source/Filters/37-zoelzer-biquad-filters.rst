Zoelzer biquad filters
======================

- **Author or source:** Udo Zoelzer: Digital Audio Signal Processing (John Wiley & Sons, ISBN 0 471 97226 6), Chris Townsend
- **Type:** biquad IIR
- **Created:** 2002-01-17 02:13:13


.. code-block:: text
    :caption: notes

    Here's the formulas for the Low Pass, Peaking, and Low Shelf, which should
    cover the basics. I tried to convert the formulas so they are little more consistent.
    Also, the Zolzer low pass/shelf formulas didn't have adjustable Q, so I added that for
    consistency with Roberts formulas as well. I think someone may want to check that I did
    it right.
    ------------ Chris Townsend
    I mistranscribed the low shelf cut formulas.
    Hopefully this is correct. Thanks to James McCartney for noticing.
    ------------ Chris Townsend


.. code-block:: c++
    :linenos:
    :caption: code

    omega = 2*PI*frequency/sample_rate
    
    K=tan(omega/2)
    Q=Quality Factor
    V=gain
    
    LPF:   b0 =  K^2
           b1 =  2*K^2
           b2 =  K^2
           a0 =  1 + K/Q + K^2
           a1 =  2*(K^2 - 1)
           a2 =  1 - K/Q + K^2
    
    peakingEQ:
          boost:
          b0 =  1 + V*K/Q + K^2
          b1 =  2*(K^2 - 1)
          b2 =  1 - V*K/Q + K^2
          a0 =  1 + K/Q + K^2
          a1 =  2*(K^2 - 1)
          a2 =  1 - K/Q + K^2
    
          cut:
          b0 =  1 + K/Q + K^2
          b1 =  2*(K^2 - 1)
          b2 =  1 - K/Q + K^2
          a0 =  1 + V*K/Q + K^2
          a1 =  2*(K^2 - 1)
          a2 =  1 - V*K/Q + K^2
    
    lowShelf:
         boost:
           b0 =  1 + sqrt(2*V)*K + V*K^2
           b1 =  2*(V*K^2 - 1)
           b2 =  1 - sqrt(2*V)*K + V*K^2
           a0 =  1 + K/Q + K^2
           a1 =  2*(K^2 - 1)
           a2 =  1 - K/Q + K^2
    
         cut:
           b0 =  1 + K/Q + K^2
           b1 =  2*(K^2 - 1)
           b2 =  1 - K/Q + K^2
           a0 =  1 + sqrt(2*V)*K + V*K^2
           a1 =  2*(v*K^2 - 1)
           a2 =  1 - sqrt(2*V)*K + V*K^2

Comments
--------

- **Date**: 2002-04-11 10:33:20
- **By**: moc.oohay@bdorezlangis

.. code-block:: text

    I get a different result for the low-shelf boost with parametric control.
    Zolzer builds his lp shelf from a pair of poles and a pair of zeros at:
    poles = Q(-1 +- j)
    zeros = sqrt(V)Q(-1 +- j)
    Where (in the book) Q=1/sqrt(2)
    So,
           s^2 + 2sqrt(V)Qs + 2VQ^2
    H(s) = ------------------------
               s^2 + 2Qs +2Q^2
    
    If you analyse this in terms of:
    H(s) = LPF(s) + 1, it sort of falls apart, as we've gained a zero in the LPF. (as does zolzers)
    
    Then, if we bilinear transform that, we get:
    
    a0= 1 + 2*sqrt(V)*Q*K + 2*V*Q^2*K^2
    a1= 2 ( 2*V*Q^2*K^2 - 1 )
    a2= 1 - 2*sqrt(V)*Q*K + 2*V*Q^2*K^2
    b0= 1 + 2*Q*K + 2*Q^2*K^2
    b1= 2 ( 2*Q^2*K^2 - 1)
    b2= 1 - 2*Q*K + 2*Q^2*K^2
    
    For:
    H(z) = a0z^2 + a1z +a2 / b0z^2 + b1z + b2
    
    Which, i /think/ is right...
    
    Dave.

- **Date**: 2002-04-13 08:14:38
- **By**: moc.oohay@bdorezlangis

.. code-block:: text

    Very sorry, I interpreted Zolzer's s-plane poles as z-plane poles. Too much digital stuff.
    
    After getting back to grips with s-plane maths :) and much graphing to test that it's right, I still get slightly different results.
    
    b0 = 1 + sqrt(V)*K/Q + V*K^2 
    b1 = 2*(V*K^2 - 1) 
    b2 = 1 - sqrt(V)*K/Q + V*K^2 
    a0 = 1 + K/Q + K^2 
    a1 = 2*(K^2 - 1) 
    a2 = 1 - K/Q + K^2
    The way the filter works is to have two poles on a unit circle around the origin in the s-plane, and two zeros that start at the poles at V0=1, and move outwards. The above co-efficients represent that. Chris's original results put the poles in the right place, but put the zeros at the location where the poles would be if they were butterworth, and move out from there - yielding some rather strange results...
    
    But I've graphed that extensively, and it works fine now :)
    
    Dave.
    

- **Date**: 2005-01-17 07:21:21
- **By**: asynth(at)io(dot)com

.. code-block:: text

    Once you divide through by a0, the Zoelzer LPF gives coefficient values that are _identical_ to the RBJ LPF.
    This one is a cheaper formulation because there is only one transcendental function call (tan) instead of two (sin, cos) for RBJ.
    -- james mccartney

- **Date**: 2005-01-18 02:33:04
- **By**: asynth(at)io(dot)com

.. code-block:: text

    Actually, sin and cos are pretty cheap when done via taylor series, so I take that last bit back.
    -- james mccartney

- **Date**: 2005-05-04 14:23:01
- **By**: se.arret@htrehgraknu

.. code-block:: text

     Anybody know the formulation for Band Pass, High Pass and High shelf ?            

- **Date**: 2005-05-04 16:57:08
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Have a look at tobybear's Filter Explorer: http://www.tobybear.de/p_filterexp.html
    
    Usually you can derivate a highpass from a lowpass and vice versa.

- **Date**: 2005-05-05 11:15:46
- **By**: se.arret@htrehgraknu

.. code-block:: text

    Thanks Christian, lots of things solved now !!
    
    Unfortunately, Bandpass continues missing. I don't know if it's really posible to obtain a Bandpass filter out of this ( my filters math knowlegde isn't so deep), but i asked for it because would be nice to have the complete set of Zoeltzer filters
    
    I supose thta YOU can derive one from another as you stated, but this is not my case. Anyway, lots of thanks for your help
    
    

- **Date**: 2005-05-20 21:04:10
- **By**: moc.noitanigamioidua@jbr

.. code-block:: text

    >Actually, sin and cos are pretty cheap when done via taylor series, so I take that last bit back
    -----------------------------------------------
    
    also, James, the sin() and cos() are less of a problem for implementing in a fixed-point context.  tan() is a bitch.
    
    r b-j
    

- **Date**: 2006-06-27 17:32:53
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Highpass version:
    
    HPF: 
    b0 = 1 - K^2
    b1 = -2*K^2
    b2 = 1 - K^2
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    Bandpass version:
    
    BPF1 (peak gain = Q):
    b0 = K
    b1 = 0
    b2 = -K
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    BPF2 (peak gain = zero):
    
    b0 = K/Q
    b1 = 0
    b2 = -K/Q
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    Couldn't figure out the notch coeffs yet...
    
    -- peter schoffhauzer

- **Date**: 2006-06-28 00:07:25
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Got the notch too finally ;)
    
    Notch
    
    b0 = 1 + K^2
    b1 = 2*(K^2 - 1)
    b2 = 1 + K^2
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    The HPF seems to have an error in the previous post. The correct HPF version:
    
    HPF:
    b0 = 1 + K/Q
    b1 = -2
    b2 = 1 - K/Q
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    Hopefully it works now. Anyone confirms?
    The set is complete now. Happy coding :)
    
    -- peter schoffhauzer

- **Date**: 2006-06-28 20:22:23
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    For sake of completeness ;)
    
    Allpass:
    
    b0 = 1 - K/Q + K^2
    b1 = 2*(K^2 - 1)
    b2 = 1
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    -- peter schoffhauzer
    
    

- **Date**: 2006-06-30 00:59:04
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    What was wrong with the first version:
    
    HPF: 
    b0 = 1 - K^2
    b1 = -2 (!!)
    b2 = 1 - K^2
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    you only have to delete K^2. In the other version the cutoff frequency depends on the Q!

- **Date**: 2006-06-30 01:50:50
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Also the Allpass should be symmetrical:
    
    b0 = 1 - K/Q + K^2
    b1 = 2*(K^2 - 1)
    b2 = 1 + K/Q + K^2  (!!)
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    If you divide by a0 (to reduce a coefficient) b2 will get 1 of course.

- **Date**: 2006-06-30 11:33:24
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Ah, thanks for the allpass correction! I used TobyBear Filter Explorer, where I see only 5 coeffs instead of six, that was the source of confusion.
    
    However, the highpass is still not perfect. In my 2nd version, the cutoff is not dependent of Q, because the cutoff is determined by the pole positions, which are set by a1 and a2. Instead, as the zero positions change according to Q, the cutoff slope varies. So it has an interesting behaviour, for low Qs it has a 6dB/Oct slope, for infinite resonance, the slope becomes 12dB/Oct.
    
    However, with your suggested HPF version, I got only a strange highshelf-like filter. So here is my 3rd version, which I hope works fine:
    
    HPF:
    b0 = 1
    b1 = -2
    b2 = 1
    a0 = 1 + K/Q + K^2
    a1 = 2*(K^2 - 1)
    a2 = 1 - K/Q + K^2
    
    Quite simple isn't it? ;)
    
    Cheers
    Peter
    

- **Date**: 2006-06-30 12:25:36
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    james mccartney:
    
    Tan can also be approximated using Taylor series (approx sin and cos with Taylor, then tan(x)=sin(x)/cos(x)) well, there's a heavy division that you can't get rid of... well, that's not true in all cases. The advantage of tan() is that you can use that tan(x) ~= x when x is small. So you can get coefficients without any transcendental functions for low and middle frequencies.
    
    Peter
    

- **Date**: 2006-06-30 13:20:44
- **By**: rf.eerf@navi.neflow

.. code-block:: text

    I think it is possible to get a Taylor serie of the tan() function ? And it is possible to do a polynomial division of the sin & cos series to get rid of the division, you get the same thing...

- **Date**: 2006-07-01 00:20:28
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Yes, there is a Taylor serie for tan(x), but near pi/2, it converges very slowly, so high frequencies is a problem again. 
    
    Let's suppose you approximate sin(x) with x-x^3/6+x^5/120, and cos(x) with 1-x^2/2+x^4/24.
    
    So tan(x) would be
    
     x - x^3/6 + x^5/120
    ---------------------
     1 - x^2/2 + x^4/24
    
    How do you do a polynomial division for that?

- **Date**: 2006-07-10 19:21:54
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Here's also a highshelf filters for completeness
    
    K:=tan(fW0*0.5);
    t2:=; 
    t3:=K*fQ; t6:=(V);
    t5:=sqrt(2*V)*K;
    t1:=1/;
    
    b0 =   (K*K + sqrt(2*V)*K + V);
    b1 = 2*(K*K               - V);
    b2 =   (K*K - sqrt(2*V)*K + V);
    a0 =   (K*K + K*fQ + 1)
    a1 =-2*(K*K        - 1);
    a2 =-  (K*K - K*fQ + 1);

