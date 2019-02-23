Moog VCF, variation 1
=====================

- **Author or source:** CSound source code, Stilson/Smith CCRMA paper., Paul Kellett version
- **Type:** 24db resonant lowpass
- **Created:** 2002-01-17 02:03:52


.. code-block:: text
    :caption: notes

    The second "q =" line previously used exp() - I'm not sure if what I've done is any
    faster, but this line needs playing with anyway as it controls which frequencies will
    self-oscillate. I
    think it could be tweaked to sound better than it currently does.
    
    Highpass / Bandpass :
    
    They are only 6dB/oct, but still seem musically useful - the 'fruity' sound of the
    24dB/oct lowpass is retained.


.. code-block:: c++
    :linenos:
    :caption: code

    // Moog 24 dB/oct resonant lowpass VCF
    // References: CSound source code, Stilson/Smith CCRMA paper.
    // Modified by paul.kellett@maxim.abel.co.uk July 2000
    
      float f, p, q;             //filter coefficients
      float b0, b1, b2, b3, b4;  //filter buffers (beware denormals!)
      float t1, t2;              //temporary buffers
    
    // Set coefficients given frequency & resonance [0.0...1.0]
    
      q = 1.0f - frequency;
      p = frequency + 0.8f * frequency * q;
      f = p + p - 1.0f;
      q = resonance * (1.0f + 0.5f * q * (1.0f - q + 5.6f * q * q));
    
    // Filter (in [-1.0...+1.0])
    
      in -= q * b4;                          //feedback
      t1 = b1;  b1 = (in + b0) * p - b1 * f;
      t2 = b2;  b2 = (b1 + t1) * p - b2 * f;
      t1 = b3;  b3 = (b2 + t2) * p - b3 * f;
                b4 = (b3 + t1) * p - b4 * f;
      b4 = b4 - b4 * b4 * b4 * 0.166667f;    //clipping
      b0 = in;
    
    // Lowpass  output:  b4
    // Highpass output:  in - b4;
    // Bandpass output:  3.0f * (b3 - b4);

Comments
--------

- **Date**: 2005-01-06 00:57:41
- **By**: ten.xmg@42nitram.leinad

.. code-block:: text

    I just tried the filter code and it seems like the highpass output is the same as the lowpass output, or at least another lowpass...
    
    But i´m still testing the filter code...

- **Date**: 2005-01-06 01:30:37
- **By**: ten.xmg@42nitram.leinad

.. code-block:: text

    Sorry for the Confusion, it works....
    I just had a typo in my code.
    
    One thing i did to get the HP sound nicer was
    
    HP output: (in - 3.0f * (b3 - b4))-b4
    
    But I´m a newbie to DSP Filters...
    

- **Date**: 2005-08-19 00:17:24
- **By**: ten.epacsten@0002skcuswodniw

.. code-block:: text

    Hey, thanks for this code. I'm a bit confused as to the range to the frequency and resonance. Is it really 0.0-1.0? If so, how so I specify a certain frequency, such as... 400Hz? THANKS!

- **Date**: 2005-08-20 13:28:54
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    frequency * nyquist
    or
    frequency * samplerate
    
    don't know the exact implementation.

- **Date**: 2007-02-05 18:28:48
- **By**: moc.erehwon@ydobon

.. code-block:: text

    >>Hey, thanks for this code. I'm a bit confused as to the range to the frequency and resonance. Is it really 0.0-1.0? If so, how so I specify a certain frequency, such as... 400Hz? THANKS!
    
    I'd guess it would be:
    
    frequency/(samplerate/2.f)

- **Date**: 2009-10-23 19:05:04
- **By**: moc.erehwon@yugsiht

.. code-block:: text

    The domain seems to be 0-nyquest (samplerate/2.0), but the range is 0-1
    
    A better way to get smoother non-linear mapping of frequency would be this: 
    (give you a range of 20Hz to 20kHz)
    
    freqinhz = 20.f * 1000.f ^ range;
    
    then
    
    frequency = freqinhz * (1.f/(samplerate/2.0f));

- **Date**: 2012-02-24 13:45:09
- **By**: ed.redienhcsslin@psdcisum

.. code-block:: text

    I like the sound of this one, unfortunately, it breaks quite fast, causing the internal values b1-b4 to be "infinity". Any hints?

