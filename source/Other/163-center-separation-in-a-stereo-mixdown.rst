Center separation in a stereo mixdown
=====================================

- **Author or source:** Thiburce BELAVENTURE
- **Created:** 2004-02-11 14:00:08


.. code-block:: text
    :caption: notes

    One year ago, i found a little trick to isolate or remove the center in a stereo mixdown.
    
    My method use the time-frequency representation (FFT). I use a min fuction between left
    and right channels (for each bin) to create the pseudo center. I apply a phase correction,
    and i substract this signal to the left and right signals.
    
    Then, we can remix them after treatments (or without) to produce a stereo signal in
    output.
    
    This algorithm (I called it "TBIsolator") is not perfect, but the result is very nice,
    better than the phase technic (L substract R...). I know that it is not mathematically
    correct, but as an estimation of the center, the exact match is very hard to obtain. So,
    it is not so bad (just listen the result and see).
    
    My implementation use a 4096 FFT size, with overlap-add method (factor 2). With a lower
    FFT size, the sound will be more dirty, and with a 16384 FFT size, the center will have
    too much high frequency (I don't explore why this thing appears).
    
    I just post the TBIsolator code (see FFTReal in this site for implement the FFT engine).
    
    pIns and pOuts buffers use the representation of the FFTReal class (0 to N/2-1: real
    parts, N/2 to N-1: imaginary parts).
    
    Have fun with the TBIsolator algorithm ! I hope you enjoy it and if you enhance it,
    contact me (it's my baby...).
    
    P.S.: the following function is not optimized.


.. code-block:: c++
    :linenos:
    :caption: code

    /* ============================================================= */
    /* nFFTSize must be a power of 2                                 */
    /* ============================================================= */
    /* Usage examples:                                               */
    /* - suppress the center:  fAmpL = 1.f, fAmpC = 0.f, fAmpR = 1.f */
    /* - keep only the center: fAmpL = 0.f, fAmpC = 1.f, fAmpR = 0.f */
    /* ============================================================= */
    
    void processTBIsolator(float *pIns[2], float *pOuts[2], long nFFTSize, float fAmpL, float fAmpC, float fAmpR)
    {
    	float fModL, fModR;
    	float fRealL, fRealC, fRealR;
    	float fImagL, fImagC, fImagR;
    	double u;
    
    	for ( long i = 0, j = nFFTSize / 2; i < nFFTSize / 2; i++ )
    	{
    		fModL = pIns[0][i] * pIns[0][i] + pIns[0][j] * pIns[0][j];
    		fModR = pIns[1][i] * pIns[1][i] + pIns[1][j] * pIns[1][j];
    
    		// min on complex numbers
    		if ( fModL > fModR )
    		{
    			fRealC = fRealR;
    			fImagC = fImagR;
    		}
    		else
    		{
    			fRealC = fRealL;
    			fImagC = fImagL;
    		}
    
    		// phase correction...
    		u = fabs(atan2(pIns[0][j], pIns[0][i]) - atan2(pIns[1][j], pIns[1][i])) / 3.141592653589;
    
    		if ( u >= 1 ) u -= 1.;
    
    		u = pow(1 - u*u*u, 24);
    
    		fRealC *= (float) u;
    		fImagC *= (float) u;
    
    		// center extraction...
    		fRealL = pIns[0][i] - fRealC;
    		fImagL = pIns[0][j] - fImagC;
    
    		fRealR = pIns[1][i] - fRealC;
    		fImagR = pIns[1][j] - fImagC;
    
    		// You can do some treatments here...
    
    		pOuts[0][i] = fRealL * fAmpL + fRealC * fAmpC;
    		pOuts[0][j] = fImagL * fAmpL + fImagC * fAmpC;
    
    		pOuts[1][i] = fRealR * fAmpR + fRealC * fAmpC;
    		pOuts[1][j] = fImagR * fAmpR + fImagC * fAmpC;
    	}
    }
    

Comments
--------

- **Date**: 2004-02-11 18:40:30
- **By**: moc.ecrubiht@cehcnamf

.. code-block:: text

    I am sorry, my source code is not totally correct.
    
    1 - the for is:
    
    for ( long i = 0, j = nFFTSize / 2; i < nFFTSize / 2; i++, j++ )
    
    2 - the correct min is:
    
    if ( fModL > fModR )
    {
        fRealC = pIns[1][i];
        fImagC = pIns[1][j];
    }
    else
    {
        fRealC = pIns[0][i];
        fImagC = pIns[0][j];
    }
    
    3 - in the phase correction:
    
    if ( u >= 1 ) u -= 1.;
    
    must be replaced by:
    
    if ( u >= 1 ) u = 2 - u;
    
    Thiburce 'TB' BELAVENTURE
    

