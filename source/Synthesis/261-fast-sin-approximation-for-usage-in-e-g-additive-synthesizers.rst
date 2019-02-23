Fast SIN approximation for usage in e.g. additive synthesizers
==============================================================

- **Author or source:** neotec
- **Created:** 2008-12-09 11:56:33


.. code-block:: text
    :caption: notes

    This code presents 2 'fastsin' functions. fastsin2 is less accurate than fastsin. In fact
    it's a simple taylor series, but optimized for integer phase.
    
    phase is in 0 -> (2^32)-1 range and maps to 0 -> ~2PI
    
    I get about 55000000 fastsin's per second on my P4,3.2GHz which would give a nice Kawai K5
    emulation using 64 harmonics and 8->16 voices.
    


.. code-block:: c++
    :linenos:
    :caption: code

    float fastsin(UINT32 phase)
    {
    	const float frf3 = -1.0f / 6.0f;
    	const float frf5 = 1.0f / 120.0f;
    	const float frf7 = -1.0f / 5040.0f;
    	const float frf9 = 1.0f / 362880.0f;
    	const float f0pi5 = 1.570796327f;
    	float x, x2, asin;
    	UINT32 tmp = 0x3f800000 | (phase >> 7);
    	if (phase & 0x40000000)
    		tmp ^= 0x007fffff;
    	x = (*((float*)&tmp) - 1.0f) * f0pi5;
    	x2 = x * x;
    	asin = ((((frf9 * x2 + frf7) * x2 + frf5) * x2 + frf3) * x2 + 1.0f) * x;
    	return (phase & 0x80000000) ? -asin : asin;
    }
    
    float fastsin2(UINT32 phase)
    {
    	const float frf3 = -1.0f / 6.0f;
    	const float frf5 = 1.0f / 120.0f;
    	const float frf7 = -1.0f / 5040.0f;
    	const float f0pi5 = 1.570796327f;
    	float x, x2, asin;
    	UINT32 tmp = 0x3f800000 | (phase >> 7);
    	if (phase & 0x40000000)
    		tmp ^= 0x007fffff;
    	x = (*((float*)&tmp) - 1.0f) * f0pi5;
    	x2 = x * x;
    	asin = (((frf7 * x2 + frf5) * x2 + frf3) * x2 + 1.0f) * x;
    	return (phase & 0x80000000) ? -asin : asin;
    }
    

Comments
--------

- **Date**: 2008-12-09 12:11:11
- **By**: neotec

.. code-block:: text

    PS: To use this as an OSC you'll need the following vars/equ's:
    
    UINT32 phase = 0;
    UINT32 step = frequency * powf(2.0f, 32.0f) / samplerate;
    
    Then it's just:
    ...
    out = fastsin(phase);
    phase += step;
    ...
    

- **Date**: 2008-12-14 20:04:10
- **By**: moc.toohay@bob

.. code-block:: text

    Woah! Seven multiplies, on top of those adds and memory lookup. Is this really all that fast?

