Butterworth
===========

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** LPF 24dB/Oct
- **Created:** 2006-07-16 11:39:35



.. code-block:: c++
    :linenos:
    :caption: code

    First calculate the prewarped digital frequency: 
    
    K = tan(Pi * Frequency / Samplerate); 
    
    Now calc some intermediate variables: (see 'Factors of Polynoms' at http://en.wikipedia.org/wiki/Butterworth_filter, especially if you want a higher order like 48dB/Oct) 
    a = 0.76536686473 * Q * K; 
    b = 1.84775906502 * Q * K; 
    
    K = K*K; (to optimize it a little bit) 
    
    Calculate the first biquad: 
    
    A0 = (K+a+1); 
    A1 = 2*(1-K); 
    A2 =(a-K-1); 
    B0 = K; 
    B1 = 2*B0; 
    B2 = B0; 
    
    Calculate the second biquad: 
    
    A3 = (K+b+1); 
    A4 = 2*(1-K); 
    A5 = (b-K-1); 
    B3 = K; 
    B4 = 2*B3; 
    B5 = B3; 
    
    Then calculate the output as follows: 
    
    Stage1 = B0*Input + State0; 
    State0 = B1*Input + A1/A0*Stage1 + State1; 
    State1 = B2*Input + A2/A0*Stage1; 
    
    Output = B3*Stage1 + State2; 
    State2 = B4*Stage1 + A4/A3*Output + State2; 
    State3 = B5*Stage1 + A5/A3*Output;

Comments
--------

- **Date**: 2006-07-18 18:44:09
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    If you have a Q factor different than 1, then filter won't be a Butterworth filter (in terms of maximally flat passpand). So, your filter is a kind of a tweaked Butterworth filter with added resonance.
    
    Highpass version should be:
    
    A0 = (K+a+1); 
    A1 = 2*(1-K); 
    A2 =(a-K-1);
    B0 = 1; 
    B1 = -2; 
    B2 = 1; 
    
    Calculate the second biquad: 
    
    A3 = (K+b+1); 
    A4 = 2*(1-K); 
    A5 = (b-K-1);
    B3 = 1; 
    B4 = -2; 
    B5 = 1;
    
    The rest is the same. You might want to leave out B0, B2, B3 and B5 completely, because they all equal to 1, and optimize the highpass loop as:
    
    Stage1 = Input + State0; 
    State0 = B1*Input + A1/A0*Stage1 + State1; 
    State1 = Input + A2/A0*Stage1; 
    
    Output = Stage1 + State2; 
    State2 = B4*Stage1 + A4/A3*Output + State2; 
    State3 = Stage1 + A5/A3*Output;
    
    Anyone confirms this code works? (Being too lazy to throw this into a compiler...)
    
    Cheers,
    Peter
    

- **Date**: 2006-07-21 11:15:06
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    And of course it is not a good idea to do divisions in the process loop, because they are very heavy, so the best is to precalculate A1/A0, A2/A0, A4/A3 and A5/A3 after the calculation of coefficients:
    
    inv_A0 = 1.0/A0;
    A1A0 = A1 * inv_A0;
    A2A0 = A2 * inv_A0;
    
    inv_A3 = 1.0/A3;
    A4A3 = A4 * inv_A3;
    A5A3 = A5 * inv_A3;
    
    (The above should be faster than writing
    
    A1A0 = A1/A0;
    A2A0 = A2/A0;
    A4A3 = A4/A3;
    A5A3 = A5/A3;
    
    but I think some compilers do this optimization automatically.)
    
    Then the lowpass process loop becomes
    
    Stage1 = B0*Input + State0; 
    State0 = B1*Input + A1A0*Stage1 + State1; 
    State1 = B2*Input + A2A0*Stage1; 
    
    Output = B3*Stage1 + State2; 
    State2 = B4*Stage1 + A4A3*Output + State2; 
    State3 = B5*Stage1 + A5A3*Output;
    
    Much faster, isn't it?
    

- **Date**: 2006-07-31 22:48:39
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Once you figured it out, it's even possible to do higher order butterworth shelving filters. Here's an example of an 8th order lowshelf.
    
    First we start as usual prewarping the cutoff frequency:
    
    K = tan(fW0*0.5);
    
    Then we settle up the Coefficient V:
    
    V = Power(GainFactor,-1/4)-1;
    
    Finally here's the loop to calculate the filter coefficients:
    
    for i = 0 to 3
    {
    cm = cos(PI*(i*2+1) / (2*8) );
    
    B[3*i+0] = 1/ ( 1 + 2*K*cm + K*K + 2*V*K*K + 2*V*K*cm + V*V*K*K);
    B[3*i+1] = 2 * ( 1 - K*K - 2*V*K*K - V*V*K*K);
    B[3*i+2] = (-1 + 2*K*cm - K*K - 2*V*K*K + 2*V*K*cm - V*V*K*K);
    A[3*i+0] = ( 1-2*K*cm+K*K);
    A[3*i+1] = 2*(-1 +K*K);
    A[3*i+2] = ( 1+2*K*cm+K*K);
    }

- **Date**: 2006-08-01 23:35:12
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Hmm... interesting. I guess the phase response/group delay gets quite funky, which is generally unwanted for an equalizer.
    
    I think the 1/ is not necessary for the first B coefficient! (of course you divide all the other coeffs with the inverse of that coeff at the end...)
    
    I guess the next will be Chebyshev shelving filters ;)
    
    BTW did you check whether my 4 pole highpass Butterworth code is correct?
    
    Peter

- **Date**: 2006-08-02 02:19:57
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    The 1/ is of course an error here. It's left of my own implementation, where I divide directly. Also I think A and B is exchanged.
    
    I've already nearly done all the different filter types (except elliptic filters), but I won't post too much here.
    The highpass maybe a highpass, but not the exact complementary. At least my (working) implementation looks different.
    
    The lowpass<->highpass transform is to replace s with 1/s and by doing this, more than one sign is changing.

- **Date**: 2006-08-02 12:32:01
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Different authors tend to mix up A and B coeffs.
    
    If I take this lowpass derived by bilinear transform and change B0 and B2 to 1, and B1 to -2 then I get a perfect highpass. At least that's what I see in FilterExplorer. Probably you could get the same by replacing s with 1/s and deriving it by bilinear transform.
    
    Well, there are many ways to get a filter working, for example if I replace tan(PI*w) with 1.0/tan(PI*w), inverse the sign of B1, and replace A1 = 2*(1-K) with A1 = 2*(K-1), I also get the same highpass. 
    
    Well, the reason for the sign inversion is that the coeffs you named B1 and B2 here are responsible for the locations of the zeroes. B1 is responsible for the angle, and B2 is for the radius, so if you invert B1 then the zeroes get on the opposite side of the unit circle, so you get a highpass filter. You then need to adjust the gain coefficient (B0) so that the passband gain is 1. Well, this is not a very precise explanation, but this is the reason why this works.
    

- **Date**: 2006-08-02 14:17:19
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Ok, you're right. I've been doing too much stuff these days that I missed that simple thing. Your version is even numerical better, because there is less potential of annihilation. Thanks for that.
    
    Btw. the group delay really get a little bit 'funky', i've also noticed that, but for not too high orders it doesn't hurt that much.

- **Date**: 2006-08-02 20:29:36
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Well, it isn't a big problem unless you start modulating the filter very fast... then you get this strange pitch-shifting effect ;)
    
    Well, I read sometimes that when you do EQing, phase is a very important factor. I guess that's why ppl sell a lot of linear phase EQ plugins. Or just the marketing? Don't know, haven't compared linear and non-linear phase stuff very much..

- **Date**: 2010-03-05 18:45:57
- **By**: moc.xocmdj@xocmdj

.. code-block:: text

    State2 = B4*Stage1 + A4/A3*Output + State2;
    should read
    State2 = B4*Stage1 + A4/A3*Output + State3;

