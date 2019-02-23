Resonant IIR lowpass (12dB/oct)
===============================

- **Author or source:** Olli Niemitalo
- **Type:** Resonant IIR lowpass (12dB/oct)
- **Created:** 2002-01-17 02:05:38


.. code-block:: text
    :caption: notes

    Hard to calculate coefficients, easy to process algorithm


.. code-block:: c++
    :linenos:
    :caption: code

    resofreq = pole frequency
    amp = magnitude at pole frequency (approx)
    
    double pi = 3.141592654;
    
    /* Parameters. Change these! */
    double resofreq = 5000;
    double amp = 1.0;
    
    DOUBLEWORD streamofs;
    double w = 2.0*pi*resofreq/samplerate; // Pole angle
    double q = 1.0-w/(2.0*(amp+0.5/(1.0+w))+w-2.0); // Pole magnitude
    double r = q*q;
    double c = r+1.0-2.0*cos(w)*q;
    double vibrapos = 0;
    double vibraspeed = 0;
    
    /* Main loop */
    for (streamofs = 0; streamofs < streamsize; streamofs++) {
    
      /* Accelerate vibra by signal-vibra, multiplied by lowpasscutoff */
      vibraspeed += (fromstream[streamofs] - vibrapos) * c;
    
      /* Add velocity to vibra's position */
      vibrapos += vibraspeed;
    
      /* Attenuate/amplify vibra's velocity by resonance */
      vibraspeed *= r;
    
      /* Check clipping */
      temp = vibrapos;
      if (temp > 32767) {
        temp = 32767;
      } else if (temp < -32768) temp = -32768;
    
      /* Store new value */
      tostream[streamofs] = temp;
    }

Comments
--------

- **Date**: 2002-05-05 08:59:19
- **By**: moc.ibtta@suocuar

.. code-block:: text

    This looks similar to the low-pass filter I used in FilterKing (http://home.attbi.com/~spaztek4/) Can you cruft up a high-pass example for me?
    
    Thanks,
    __e

- **Date**: 2006-05-18 17:01:21
- **By**: faster init

.. code-block:: text

    thank you! works nicely...
    here a simplified init version for faster changes of the filter properties for amps = 1.0
    
    void init( double resofreq )
    {
    static const double FAC = pi * 2.0 /samplerate;
    double q, w;
    
    w = FAC * resofreq;
    q = 1.0f - w /( ( 3.0 /( 1.0+w ) ) + w - 2.0 );
    
    _r = q * q;
    _c = r + 1.0f - 2.0f * cos(w) * q;
    }
    

