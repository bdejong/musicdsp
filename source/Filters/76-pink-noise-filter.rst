Pink noise filter
=================

- **Author or source:** Paul Kellett
- **Created:** 2002-02-11 17:40:39

- **Linked files:** :download:`pink.txt <../files/pink.txt>`.

.. code-block:: text
    :caption: notes

    (see linked file)



Comments
--------

- **Date**: 2005-02-10 12:23:55
- **By**: ed.ap-ymot@ymoT

.. code-block:: text

                 Hi, first of all thanks a lot for this parameters. 
    I'm new to digital fitering, and need a 3dB highpass to correct a pink spectrum which is used for measurement back to white for displaying the impulseresponse.
    I checked some pages, but all demand a fixed ratio between d0 and d1 for a 6db lowpass. But this ratio is not given on your filters, so I'm not able to transform them into highpasses.
    Any hints?
    
    Tomy

- **Date**: 2005-02-10 19:58:16
- **By**: ed.ap-ymot@ymoT

.. code-block:: text

                 Hi, first of all thanks a lot for this parameters. I'm new to digital fitering, and need a 3dB highpass to correct a pink spectrum which is used for measurement back to white for displaying the impulseresponse.I checked some pages, but all demand a fixed ratio between d0 and d1 for a 6db lowpass. But this ratio is not given on your filters, so I'm not able to transform them into highpasses.Any hints?Tomy

- **Date**: 2005-02-14 14:57:04
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    If computing power doesn't matter, than you may want do design the pink noise in the frequency domain and transform it backt to timedomain via fft.
    Christian              

- **Date**: 2005-03-03 16:34:49
- **By**: rf.oohay@dejamdaddah

.. code-block:: text

    HI, could you please give me a code matlab to have a pink noise. I
    tested a code where one did all into frequential mode then made an ifft.
    Thank you

- **Date**: 2009-03-15 21:56:21
- **By**: moc.liamg@321tiloen

.. code-block:: text

    Here is a slightly less efficient implementation, which can be used to calculate coefficients for different samplerates (in ranges).
    
    Note: You may also want to check the sample-and-hold method.
    
    //trc - test rate coeff, srate - samplerate
    trc = 1;
    sr = srate*trc;
    
    //f0-f6 - freq array in hz
    //
    //---------------------
    //samplerate <= 48100hz
    f0 = 4752.456;
    f1 = 4030.961;
    f2 = 2784.711;
    f3 = 1538.461;
    f4 = 357.681;
    f5 = 70;
    f6 = 30;
    //---------------------
    //samplerate > 44800hz && samplerate <= 96000hz
    f0 = 8227.219;
    f1 = 8227.219;
    f2 = 6388.570;
    f3 = 3302.754;
    f4 = 479.412;
    f5 = 151.070;
    f6 = 54.264;
    //---------------------
    //samplerate > 96000khz && samplerate < 192000khz
    f0 = 9211.912;
    f1 = 8621.096;
    f2 = 8555.228;
    f3 = 8292.754;
    f4 = 518.334;
    f5 = 163.712;
    f6 = 240.241;
    //---------------------
    //samplerate >= 192000hz
    f0 = 10000;
    f1 = 10000;
    f2 = 10000;
    f3 = 10000;
    f4 = 544.948;
    f5 = 142.088;
    f6 = 211.616;
    
    //----------------------
    //calculate coefficients
    k0 = exp(-2*$pi*f0/sr);
    k1 = exp(-2*$pi*f1/sr);
    k2 = exp(-2*$pi*f2/sr);
    k3 = exp(-2*$pi*f3/sr);
    k4 = exp(-2*$pi*f4/sr);
    k5 = exp(-2*$pi*f5/sr);
    k6 = exp(-2*$pi*f6/sr);
    
    --- sample loop ---
    //white - noise input
    b0 = k0*white+k0*b0;
    b1 = k1*white+k1*b1;
    b2 = k2*white+k2*b2;
    b3 = k3*white+k3*b3;
    b4 = k4*white+k4*b4;
    b5 = k5*white+k5*b5;
    b6 = k6*white+k6*b6;
    pink = (b0+b1+b2+b3+b4+b5+white-b6);
    
    output = pink;
    --- sample loop ---
    
    Basically if you use the same coefficients, if comparing some outputs, you would notice a degradation in the filter at higher sample rates - Thus the different ranges. But the quality of your white noise (PRNG) may be important also.
    
    These 'should' work...They do fairly well, at least mathematically for rendered outputs.
    
    Lubomir

