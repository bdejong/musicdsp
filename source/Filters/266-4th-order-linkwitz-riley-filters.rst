4th order Linkwitz-Riley filters
================================

- **Author or source:** moc.liamg@321tiloen
- **Type:** LP/HP - LR4
- **Created:** 2009-05-17 19:43:06


.. code-block:: text
    :caption: notes

    Original from T. Lossius - ttblue project
    
    Optimized version in pseudo-code.
    
    [! The filter is unstable for fast automation changes in the lower frequency range.
    Parameter interpolation and/or oversampling should fix this. !]
    
    The sum of the Linkwitz-Riley (Butterworth squared) HP and LP outputs, will result an all-
    pass filter at Fc and flat magnitude response - close to ideal for crossovers.
    
    Lubomir I. Ivanov


.. code-block:: c++
    :linenos:
    :caption: code

    //-----------------------------------------
    // [code]
    //-----------------------------------------
    
    //fc -> cutoff frequency
    //pi -> 3.14285714285714
    //srate -> sample rate
    
    //================================================
    // shared for both lp, hp; optimizations here
    //================================================
    wc=2*pi*fc;
    wc2=wc*wc;
    wc3=wc2*wc;
    wc4=wc2*wc2;
    k=wc/tan(pi*fc/srate);
    k2=k*k;
    k3=k2*k;
    k4=k2*k2;
    sqrt2=sqrt(2);
    sq_tmp1=sqrt2*wc3*k;
    sq_tmp2=sqrt2*wc*k3;
    a_tmp=4*wc2*k2+2*sq_tmp1+k4+2*sq_tmp2+wc4;
    
    b1=(4*(wc4+sq_tmp1-k4-sq_tmp2))/a_tmp;
    b2=(6*wc4-8*wc2*k2+6*k4)/a_tmp;
    b3=(4*(wc4-sq_tmp1+sq_tmp2-k4))/a_tmp;
    b4=(k4-2*sq_tmp1+wc4-2*sq_tmp2+4*wc2*k2)/a_tmp;
    
    //================================================
    // low-pass
    //================================================
    a0=wc4/a_tmp;
    a1=4*wc4/a_tmp;
    a2=6*wc4/a_tmp;
    a3=a1;
    a4=a0;
    
    //=====================================================
    // high-pass
    //=====================================================
    a0=k4/a_tmp;
    a1=-4*k4/a_tmp;
    a2=6*k4/a_tmp;
    a3=a1;
    a4=a0;
    
    //=====================================================
    // sample loop - same for lp, hp
    //=====================================================
    tempx=input;
    
    tempy=a0*tempx+a1*xm1+a2*xm2+a3*xm3+a4*xm4-b1*ym1-b2*ym2-b3*ym3-b4*ym4;
    xm4=xm3;
    xm3=xm2;
    xm2=xm1;
    xm1=tempx;
    ym4=ym3;
    ym3=ym2;
    ym2=ym1;
    ym1=tempy;
    
    output=tempy;
    

Comments
--------

- **Date**: 2009-05-29 11:09:50
- **By**: moc.liamg@321tiloen

.. code-block:: text

    LR2 with DFII:
    
    //------------------------------
    // LR2
    // fc -> cutoff frequency
    // pi -> 3.14285714285714
    // srate -> sample rate
    //------------------------------
    fpi = pi*fc;
    wc = 2*fpi;
    wc2 = wc*wc;
    wc22 = 2*wc2;
    k = wc/tan(fpi/srate);
    k2 = k*k;
    k22 = 2*k2;
    wck2 = 2*wc*k; 
    tmpk = (k2+wc2+wck2);
    //b shared
    b1 = (-k22+wc22)/tmpk;
    b2 = (-wck2+k2+wc2)/tmpk;
    //---------------
    // low-pass
    //---------------
    a0_lp = (wc2)/tmpk;
    a1_lp = (wc22)/tmpk;
    a2_lp = (wc2)/tmpk;
    //----------------
    // high-pass
    //----------------
    a0_hp = (k2)/tmpk;
    a1_hp = (-k22)/tmpk;
    a2_hp = (k2)/tmpk;
    
    //=========================
    // sample loop, in -> input
    //=========================
    //---lp
    lp_out = a0_lp*in + lp_xm0;
    lp_xm0 = a1_lp*in - b1*lp_out + lp_xm1;
    lp_xm1 = a2_lp*in - b2*lp_out;
    //---hp
    hp_out = a0_hp*in + hp_xm0;
    hp_xm0 = a1_hp*in - b1*hp_out + hp_xm1;
    hp_xm1 = a2_hp*in - b2*hp_out;
    
    // the two are with 180 degrees phase shift,
    // so you need to invert the phase of one.
    out = lp_out + hp_out*(-1);
    
    //result is allpass at Fc

- **Date**: 2011-07-13 11:48:20
- **By**: moc.kauqkiuq@evad

.. code-block:: text

    I've converted this Linkwits Riley 4 into intrinsics. It's set up with the cross over point and the sample rate. The function 'ProcessSplit' returns the low and high parts. It uses _mm_malloc to align the variables to 16 bytes, as putting them into the class as __m128 vars doesn't guarantee alignment.
    Enjoy!  :)
    
    
    //-----------------------------------------------
    //-----------------------------------------------
    //-----------------------------------------------
    //FIL_Linkwitz_Riley4.h
    
    #pragma once
    
    #include <xmmintrin.h>
    
    class   FIL_Linkwitz_Riley4
    {
    	__m128 *ab;
    	__m128 *al;
    	__m128 *ah;
    	__m128 *xm;
    	__m128 *yml;
    	__m128 *ymh;
    
    	float a0l;
    	float a0h;
    
    public:
    
    	FIL_Linkwitz_Riley4::FIL_Linkwitz_Riley4(float fc, float srate);
    	~FIL_Linkwitz_Riley4();
    
    	void ResetSplit();
    
    	__inline void FIL_Linkwitz_Riley4::ProcessSplit(const float in, float &low, float &high)
    	{
    		__m128 m1;
    
    		m1 = _mm_sub_ps(_mm_mul_ps(*al, *xm), _mm_mul_ps(*ab, *yml));
    		low  = a0l * in + m1.m128_f32[0] + m1.m128_f32[1] + m1.m128_f32[2] + m1.m128_f32[3];
    
    		m1 = _mm_sub_ps(_mm_mul_ps(*ah, *xm), _mm_mul_ps(*ab, *ymh));
    		high = a0h * in + m1.m128_f32[0] + m1.m128_f32[1] + m1.m128_f32[2] + m1.m128_f32[3];
    
    		*xm  = _mm_shuffle_ps(*xm, *xm, _MM_SHUFFLE(2,1,0,0));
    		(*xm).m128_f32[0] = in;
    		*yml = _mm_shuffle_ps(*yml, *yml, _MM_SHUFFLE(2,1,0,0));
    		(*yml).m128_f32[0] = low;
    		*ymh = _mm_shuffle_ps(*ymh, *ymh, _MM_SHUFFLE(2,1,0,0));
    		(*ymh).m128_f32[0] = high;
    	}
    
    
    };
    
    //-----------------------------------------------
    //-----------------------------------------------
    //-----------------------------------------------
    
    
    // FIL_Linkwitz_Riley4.cpp
    
    #include "FIL_Linkwitz_Riley4.h"
    #include <math.h>
    
    
    FIL_Linkwitz_Riley4::FIL_Linkwitz_Riley4(float fc, float srate)
    {
    	ab  = (__m128*)_mm_malloc(16, 16);
    	al  = (__m128*)_mm_malloc(16, 16);
    	ah  = (__m128*)_mm_malloc(16, 16);
    	xm  = (__m128*)_mm_malloc(16, 16);
    	yml = (__m128*)_mm_malloc(16, 16);
    	ymh = (__m128*)_mm_malloc(16, 16);
    
    	float wc  = 2.0f * PI * fc;
    	float wc2 = wc*wc;
    	float wc3 = wc2*wc;
    	float wc4 = wc2*wc2;
    	float k  = wc / tanf(PI * fc / srate);
    	float k2 = k*k;
    	float k3 = k2*k;
    	float k4 = k2*k2;
    	float sqrt2   = sqrtf(2.0f);
    	float sq_tmp1 = sqrt2 *wc3 * k;
    	float sq_tmp2 = sqrt2 *wc * k3;
    	float a_tmp	  = 4.0f * wc2 * k2 + 2.0f * sq_tmp1 + k4 + 2.0f * sq_tmp2 + wc4;
    			    
    	(*ab).m128_f32[0] = (4.0f *(wc4+sq_tmp1-k4-sq_tmp2))/a_tmp;
    	(*ab).m128_f32[1] = (6.0f *wc4-8*wc2*k2+6*k4)/a_tmp;
    	(*ab).m128_f32[2] = (4.0f *(wc4-sq_tmp1+sq_tmp2-k4))/a_tmp;
    	(*ab).m128_f32[3] = (k4 -2.0f * sq_tmp1 + wc4 - 2.0f * sq_tmp2 + 4.0f * wc2 * k2) / a_tmp;
    
    	//================================================
    	// low-pass
    	//================================================
    	a0l	  = wc4/a_tmp;
    	(*al).m128_f32[0] = 4.0f * wc4 / a_tmp;
    	(*al).m128_f32[1] = 6.0f * wc4 / a_tmp;
    	(*al).m128_f32[2] = (*al).m128_f32[0];
    	(*al).m128_f32[3] = a0l;
    
    	//=====================================================
    	// high-pass
    	//=====================================================
    	a0h	  = k4 / a_tmp;
    	(*ah).m128_f32[0] = -4.0f * k4 / a_tmp;
    	(*ah).m128_f32[1] =  6.0f * k4 / a_tmp;
    	(*ah).m128_f32[2] = (*ah).m128_f32[0];
    	(*ah).m128_f32[3] = a0h;
    
    	ResetSplit();
    }
    
    FIL_Linkwitz_Riley4::~FIL_Linkwitz_Riley4()
    {
    	_mm_free((void*)ab);
    	_mm_free((void*)al);
    	_mm_free((void*)ah);
    	_mm_free((void*)xm);
    	_mm_free((void*)yml);
    	_mm_free((void*)ymh);
    }
    
    
    void FIL_Linkwitz_Riley4::ResetSplit()
    {
    	// Reset history...
    	*xm  = _mm_set1_ps(0.0f);
    	*yml = _mm_set1_ps(0.0f);
    	*ymh = _mm_set1_ps(0.0f);
    }
    //-----------------------------------------------
    //-----------------------------------------------
    //-----------------------------------------------
    
    

- **Date**: 2011-07-13 15:00:08
- **By**: moc.kauqkiuq@evad

.. code-block:: text

    I've no idea why I'm accessing those pointers like that! But never mind. :)

- **Date**: 2012-07-04 13:45:19
- **By**: ac.cisum-mutnauq@noidc

.. code-block:: text

    Your pi value is wrong:
    pi -> 3.14285714285714
    
    It should be 3.1415692 ect.

- **Date**: 2012-12-31 15:10:16
- **By**: moc.kauqkiuq@evad

.. code-block:: text

    Or even 3.1415926535!
    LOL.
    

- **Date**: 2013-07-29 09:35:15
- **By**: moc.snoitcudorpnrec@mij

.. code-block:: text

    I don't think this is unstable for changes in frequency.  It's unstable for low frequencies.  
    
    Here's my implementation. 
    
    
    #include <iostream>
    #include <stdio.h>
    #include <math.h>
    #include <assert.h>
    
    class LRCrossoverFilter { // LR4 crossover filter
    private:
        struct filterCoefficents {
            float a0, a1, a2, a3, a4;
        } lpco, hpco;
        
        float b1co, b2co, b3co, b4co;
        
        struct {
            float xm1 = 0.0f;
            float xm2 = 0.0f;
            float xm3 = 0.0f;
            float xm4 = 0.0f;
            float ym1 = 0.0f, ym2 = 0.0f, ym3 = 0.0f, ym4 = 0.0f;
        } hptemp, lptemp;
        
        float coFreqRunningAv = 100.0f;
    public:
        void setup(float crossoverFrequency, float sr);
        void processBlock(float * in, float * outHP, float * outLP, int numSamples);
        void dumpCoefficents(struct filterCoefficents x) {
            std::cout << "a0: " << x.a0 << "\n";
            std::cout << "a1: " << x.a1 << "\n";
            std::cout << "a2: " << x.a2 << "\n";
            std::cout << "a3: " << x.a3 << "\n";
            std::cout << "a4: " << x.a4 << "\n";
        }
        void dumpInformation() {
            std::cout << "-----\nfrequency: "<< coFreqRunningAv << "\n";
            std::cout << "lpco:\n";
            dumpCoefficents(lpco);
            std::cout << "hpco:\n";
            dumpCoefficents(hpco);
            std::cout << "bco:\nb1: ";
            std::cout << b1co << "\nb2: " << b2co << "\nb3: " <<  b3co << "\nb4: " << b4co << "\n";
        }
        
    
    };
    
    
    void LRCrossoverFilter::setup(float crossoverFrequency, float sr) {
        
        const float pi = 3.141f;
        
        coFreqRunningAv = crossoverFrequency;
        
        float cowc=2*pi*coFreqRunningAv;
        float cowc2=cowc*cowc;
        float cowc3=cowc2*cowc;
        float cowc4=cowc2*cowc2;
        
        float cok=cowc/tan(pi*coFreqRunningAv/sr);
        float cok2=cok*cok;
        float cok3=cok2*cok;
        float cok4=cok2*cok2;
        float sqrt2=sqrt(2);
        float sq_tmp1 = sqrt2 * cowc3 * cok;
        float sq_tmp2 = sqrt2 * cowc * cok3;
        float a_tmp = 4*cowc2*cok2 + 2*sq_tmp1 + cok4 + 2*sq_tmp2+cowc4;
        
        b1co=(4*(cowc4+sq_tmp1-cok4-sq_tmp2))/a_tmp;
    
        
        b2co=(6*cowc4-8*cowc2*cok2+6*cok4)/a_tmp;
    
        
        b3co=(4*(cowc4-sq_tmp1+sq_tmp2-cok4))/a_tmp;
    
        
        b4co=(cok4-2*sq_tmp1+cowc4-2*sq_tmp2+4*cowc2*cok2)/a_tmp;
    
        
        
        //================================================
        // low-pass
        //================================================
        lpco.a0=cowc4/a_tmp;
        lpco.a1=4*cowc4/a_tmp;
        lpco.a2=6*cowc4/a_tmp;
        lpco.a3=lpco.a1;
        lpco.a4=lpco.a0;
        
        //=====================================================
        // high-pass
        //=====================================================
        hpco.a0=cok4/a_tmp;
        hpco.a1=-4*cok4/a_tmp;
        hpco.a2=6*cok4/a_tmp;
        hpco.a3=hpco.a1;
        hpco.a4=hpco.a0;
        
        
    }
    
    void LRCrossoverFilter::processBlock(float * in, float * outHP, float * outLP, int numSamples) {
        
        float tempx, tempy;
        for (int i = 0; i<numSamples; i++) {
            tempx=in[i];
            
            // High pass
            
            tempy = hpco.a0*tempx +
            hpco.a1*hptemp.xm1 +
            hpco.a2*hptemp.xm2 +
            hpco.a3*hptemp.xm3 +
            hpco.a4*hptemp.xm4 -
            b1co*hptemp.ym1 -
            b2co*hptemp.ym2 -
            b3co*hptemp.ym3 -
            b4co*hptemp.ym4;
            
            hptemp.xm4=hptemp.xm3;
            hptemp.xm3=hptemp.xm2;
            hptemp.xm2=hptemp.xm1;
            hptemp.xm1=tempx;
            hptemp.ym4=hptemp.ym3;
            hptemp.ym3=hptemp.ym2;
            hptemp.ym2=hptemp.ym1;
            hptemp.ym1=tempy;
            outHP[i]=tempy;
    
            assert(tempy<10000000);
            
            // Low pass
            
            tempy = lpco.a0*tempx +
            lpco.a1*lptemp.xm1 +
            lpco.a2*lptemp.xm2 +
            lpco.a3*lptemp.xm3 +
            lpco.a4*lptemp.xm4 -
            b1co*lptemp.ym1 -
            b2co*lptemp.ym2 -
            b3co*lptemp.ym3 -
            b4co*lptemp.ym4;
            
            lptemp.xm4=lptemp.xm3; // these are the same as hptemp and could be optimised away
            lptemp.xm3=lptemp.xm2;
            lptemp.xm2=lptemp.xm1;
            lptemp.xm1=tempx;
            lptemp.ym4=lptemp.ym3;
            lptemp.ym3=lptemp.ym2;
            lptemp.ym2=lptemp.ym1;
            lptemp.ym1=tempy;
            outLP[i] = tempy;
            
            assert(!isnan(outLP[i]));
        }
    }
    
    
    int main () {
        LRCrossoverFilter filter;
        float data[2000];
        float lp[2000], hp[2000]; 
        
        filter.setup(50.0, 44100.0f);
        filter.dumpInformation();
        
        for (int i = 0; i<2000; i++) {
            data[i] = sinf(i/100.f);
        }
        filter.processBlock(data, hp, lp, 2000);
        
    }
    
    I'll try and fix it, but this kind of work is new to me, so all suggestions appreciated (Including "You Fool, you've copied the code wrong"). cheers!              

- **Date**: 2013-09-03 22:35:23
- **By**: ku.oc.9f.yrreksirhc@kc

.. code-block:: text

    I tried this code for a crossover - firstly the SSE intrinsics version then the full original version. Both have problems with the HPF output.
    With a crossover frequency of 200Hz and a pure sine tone input (any pitch) I get loud (-16dBFS)low frequency noise in the HPF output. This noise level reduces as the crossover frequency increases but it is unusable in its current state.
    Can anyone post a solution for this problem?
    Thanks.....Chris

- **Date**: 2013-09-04 10:37:34
- **By**: ku.oc.9f.yrreksirhc@kc

.. code-block:: text

    I also tried the LR2 code, this works better but there is still low frequency noise (-56dBFS & Xover 200Hz) in the HPF output.
    Seems there is a fundamental problem with the HPF coefficients in this code :(
    The LF Noise for both LR2 and LR4 appears to be a modulating DC offset - maybe that can guide the Filter Gurus to identify and solve the problem.
    Cheers.....Chris    

