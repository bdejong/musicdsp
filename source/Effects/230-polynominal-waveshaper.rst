Polynominal Waveshaper
======================

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** (discrete harmonics)
- **Created:** 2006-07-28 17:58:54


.. code-block:: text
    :caption: notes

    The following code will describe how to excite discrete harmonics and only these
    harmonics. A simple polynominal waveshaper for processing the data is included as well.
    However the code don't claim to be optimized. Using a horner scheme with precalculated
    coefficients should be your choice here.
    Also remember to oversample the data (optimal in the order of the harmonics) to have them
    alias free.


.. code-block:: text
    :linenos:
    :caption: code

    We assume the input is a sinewave (works for any input signal, but this makes everything more clear).
    Then we have x = sin(a)
    
    the first harmonic is plain simple (using trigonometric identities):
    
    cos(2*a)= cos^2(a) - sin^2(a) = 1 - 2 sin^2(a)
    
    using the general trigonometric identities:
    
    sin(x + y) = sin(x)*cos(y) + sin(y)*cos(x)
    cos(x + y) = cos(x)*cos(y) - sin(y)*sin(x)
    
    together with some math, you can easily calculate: sin(3x), cos(4x), sin(5x), and so on...
    
    
    Here's how the resulting waveshaper may look like:
    
    // o = output, i = input
    o = fPhase[1]*     i                                                                  * fGains[0]+
        fPhase[1]*(  2*i*i             -   1                                            ) * fGains[1]+
        fPhase[2]*(  4*i*i*i           -   3*i                                          ) * fGains[2]+
        fPhase[3]*(  8*i*i*i*i         -   8*i*i         +   1                          ) * fGains[3]-
        fPhase[4]*( 16*i*i*i*i*i       -  20*i*i*i       +   5 * i                      ) * fGains[4]+
        fPhase[5]*( 32*i*i*i*i*i*i     -  48*i*i*i*i     +  18 * i*i     -  1           ) * fGains[5]-
        fPhase[6]*( 64*i*i*i*i*i*i*i   - 112*i*i*i*i*i   +  56 * i*i*i   -  7 * i       ) * fGains[6]+
        fPhase[7]*(128*i*i*i*i*i*i*i*i - 256*i*i*i*i*i*i + 160 * i*i*i*i - 32 * i*i + 1 ) * fGains[7];
    
    fPhase[..] is the sign array and fGains[..] is the gain factor array.
    
    P.S.: I don't want to see a single comment about the fact that the code above is unoptimized. I know that!

Comments
--------

- **Date**: 2006-07-28 22:16:36
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Here's the more math like version:
    
    // o = output, i = input
    o = fPhase[1]* i * fGains[0]+
        fPhase[1]*(  2*i^2 - 1 ) * fGains[1]+
        fPhase[2]*(  4*i^3 - 3*i ) * fGains[2]+
        fPhase[3]*(  8*i^4 - 8*i^2 + 1 ) * fGains[3]-
        fPhase[4]*( 16*i^5 - 20*i^3 + 5*i ) * fGains[4]+
        fPhase[5]*( 32*i^6 - 48*i^4 + 18 * i^2 - 1 ) * fGains[5]-
        fPhase[6]*( 64*i^7 - 112*i^5 + 56 * i^3 - 7 * i ) * fGains[6]+
        fPhase[7]*(128*i^8 - 256*i^6 + 160 * i^4 - 32 * i^2 + 1 ) * fGains[7];
        

- **Date**: 2006-07-28 23:29:49
- **By**: ten.xmg@zlipzzuf

.. code-block:: text

    Actually, this *doesn't* work in the way described on any input, only on single sinusoids of
    amplitude 1. It's nonlinear - (a+b)^n is not the same thing as a^n+b^n, nor are (a*b)^n and a*(b^n).
    Even just a sum of two sinusoids or a single sinusoid of a different amplitude breaks the
    chosen-harmonics-only thing.

- **Date**: 2006-07-29 10:30:46
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Do'oh. You're right. Once more I got fooled by the way of my measurement. That explains a
    lot of things... Thanks for the clarification!

- **Date**: 2006-07-29 20:34:11
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Btw. the coeffitients follow the chebyshev polynomials. Just in case you wonder about the
    logic behind. Maybe we can call it chebyshev waveshaper from now on...

- **Date**: 2008-01-23 01:56:21
- **By**: ten.enilnotpo@kcirtscisyhp

.. code-block:: text

    I played with this idea for a while yesterday to no avail before discovering this post tonight.
    I thought I could excite any harmonic I wanted using select Chebyshev Polynomials. But you are
    totally right - it doesn't work that way. Any complex waveform that can be broken down into a
    Fourier series is a linear sum of terms. Squaring or cubing the waveform, and therefor this sum,
    leads to multiple cross terms which introduce additional frequencies. It does only work with
    normalized single sinusoids . . .which is too bad.
    
    Right now, the only way I can see to do this sort of thing where you excite select harmonics at will
    is to run an FFT and then work from there in the frequency domain. 
    
    But my question is, if we are looking to simulate tube saturation, is the Chebyshev method good
    enough. What, after all, do tubes do? Does a tube amp actually add discrete harmonics or is it
    introducing all of those cross term frequencies as well? 
    

- **Date**: 2009-05-19 22:26:03
- **By**: moc.liamg@neklov.neivalf

.. code-block:: text

    According to another post, the tube is simply a non linear function, for example a tan(x).
    Actually by saturating any signal you will get harmonics (any but a pure square which cannot
    be more saturated of couse...). As tan(x) is not linear, you should get harmonics… that's all.
    Now if you want to pass only the high frequencies,just split the signal into 2 frequencies using
    a lowpass vs highpass = signal - lowpass and process the frequencies you want to.              

- **Date**: 2010-09-16 19:17:13
- **By**: moc.liamg@libojyr

.. code-block:: text

    I would like to add that this method could result in an approximated harmonic exciter using an
    array of filters sufficiently narrow and steep to approximately single out individual frequencies
    composing the original signal.
    
    As such, it would be processing intensive because the polynomial would need to be calculated on
    each band.  
    
    What you have presented is not completely bad.  You only need to take into consideration that you're
    getting frequency terms that are not necessarily harmonics.  Steve Harris has a LADSPA plugin that
    uses the chebychev polynomial as a waveshaper...and he calls it a harmonic exciter.
    
    To user physicstrick:  Tube emulation is much more than waveshaping.  Bias conditions change with
    signal dynamics, and you essentially get signal-power modulated duty cycle.  I have found some good
    articles about this and also there is a commercial product that claims to solve the discretized
    system of ODE's in real time.  This model eats CPU like you would not imagine.
    
    My simple "trick" is to include the nonlinear function in a 1rst order filter calculation and
    also to modulate the filter time constants with the filter state variable amplitude.  This is not
    quite right, but it produces an emulation that is more pleasing than plain waveshaping.

- **Date**: 2013-01-18 02:31:27
- **By**: moc.liamtoh@niffumtohrepus

.. code-block:: text

    If I'm correct, you're describing the same technique achievable by use of Chebyschev polynomials,
    i.e. generating any integral harmonic of the original signal. I've experimented with these,
    synthesizing only the second, third, fourth, etc. harmonics, but could never get a realistic
    sound, probably because overdiven tubes/transistors don't work this way and there's no intermodulation
    distortion, only the pure harmonics.          

