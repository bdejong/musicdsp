Resampling
==========

- **Author or source:** ed.corm@liam
- **Type:** linear interpolated aliased resampling of a wave file
- **Created:** 2004-04-07 09:39:12


.. code-block:: text
    :caption: notes

    som resampling stuff. the code is heavily used in MSynth, but do not lough about ;-)
    
    perhaps, prefiltering would reduce aliasing.


.. code-block:: c++
    :linenos:
    :caption: code

    signed short* pSample = ...;
    unsigned int sampleLength = ...;
    
    // stretch sample to length of one bar...
    float playPosDelta = sampleLength / ( ( 240.0f / bpm ) * samplingRate );
    
    // requires for position calculation...
    float playpos1 = 0.0f;
    unsigned int iter = 0;
    
    // required for interpolation...
    unsigned int i1, i2;
    
    float* pDest = ....;
    float* pDestStop = pDest + len;
    for( float *pt=pDest;pt<pDestStop;++pt )
    {
    	// linear interpolation...
    	i1 = (unsigned int)playpos;
    	i2 = i1 + 1;
    	(*pt) = ((pSample[i2]-pSample[i1]) * (playpos - i1) + pSample[i1]);
    
    	// position calculation preventing float sumation error...
    	playpos1 = (++iter) * playposIncrement; 
    }
    ...

Comments
--------

- **Date**: 2004-02-15 12:01:50
- **By**: Gog

.. code-block:: text

    Linear interpolation normally introduces a lot of artefacts. An easy way to improve upon this is to use the hermite interpolator instead. The improvement is _dramatic_!

- **Date**: 2004-05-04 16:57:06
- **By**: moc.sulp.52retsinnab@etep

.. code-block:: text

    i1 = (unsigned int)playpos;
    i2 = i1 + 1;
    
    would this be better as:
    
    i1 = (unsigned int) floor(playpos);
    i2 = (unsigned int) ceil(i1 + playposIncrement);
    
    ?
    
    if you are actually decimating rather than interpolating (which is what would give aliasing), then the second interpolation point in the input could potentially be more than i1 + 1.
    
    

- **Date**: 2004-05-05 11:26:57
- **By**: moc.sulp.52retsinnab@etep

.. code-block:: text

    no, sorry it wouldn't :%|

- **Date**: 2004-08-13 23:45:16
- **By**: ed.corm@liam

.. code-block:: text

    yes, a more sophisticated interpolation would
    improve the sound and prefiltering would
    terminate the aliasing. but everything with
    hi runtime overhead.

