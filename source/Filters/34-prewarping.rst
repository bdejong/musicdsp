Prewarping
==========

- **Author or source:** robert bristow-johnson (better known as "rbj" )
- **Type:** explanation
- **Created:** 2002-01-17 02:10:26


.. code-block:: text
    :caption: notes

    prewarping is simply recognizing the warping that the BLT introduces.
    to determine frequency response, we evaluate the digital H(z) at
    z=exp(j*w*T) and we evaluate the analog Ha(s) at s=j*W . the following
    will confirm the jw to unit circle mapping and will show exactly what the
    mapping is (this is the same stuff in the textbooks):
    
    the BLT says: s = (2/T) * (z-1)/(z+1)
    
    substituting: s = j*W = (2/T) * (exp(j*w*T) - 1) / (exp(j*w*T) + 1)
    
    j*W = (2/T) * (exp(j*w*T/2) - exp(-j*w*T/2)) / (exp(j*w*T/2) + exp(-j*w*T/2))
    
    = (2/T) * (j*2*sin(w*T/2)) / (2*cos(w*T/2))
    
    = j * (2/T) * tan(w*T/2)
    
    or
    
    analog W = (2/T) * tan(w*T/2)
    
    so when the real input frequency is w, the digital filter will behave with
    the same amplitude gain and phase shift as the analog filter will have at a
    hypothetical frequency of W. as w*T approaches pi (Nyquist) the digital
    filter behaves as the analog filter does as W -> inf. for each degree of
    freedom that you have in your design equations, you can adjust the analog
    design frequency to be just right so that when the deterministic BLT
    warping does its thing, the resultant warped frequency comes out just
    right. for a simple LPF, you have only one degree of freedom, the cutoff
    frequency. you can precompensate it so that the true cutoff comes out
    right but that is it, above the cutoff, you will see that the LPF dives
    down to -inf dB faster than an equivalent analog at the same frequencies.



