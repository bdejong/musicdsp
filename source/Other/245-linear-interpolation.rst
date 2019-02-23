Linear interpolation
====================

- **Author or source:** uh.etle.fni@yfoocs
- **Type:** Linear interpolators for oversampled audio
- **Created:** 2007-02-19 10:02:41


.. code-block:: text
    :caption: notes

    Simple, fast linear interpolators for upsampling a signal by a factor of 2,4,8,16 or 32.
    Not very usable on their own since they introduce aliasing (but still better than zero
    order hold). These are best used with already oversampled signals.
    
    -- Peter Schoffhauzer


.. code-block:: c++
    :linenos:
    :caption: code

    #ifndef __LIN_INTERPOLATOR_H_
    #define __LIN_INTERPOLATOR_H_
    
    /************************************************************************
    *	Linear interpolator class											*
    ************************************************************************/
    
    class interpolator_linear
    {
    public:
    	interpolator_linear() { 
    		reset_hist();
    	}
    	
    	// reset history
    	void reset_hist() {
    		d1 = 0.f;
    	}
    
    	// 2x interpolator
    	// out: pointer to float[2]
    	inline void process2x(float const in, float *out) {
    		out[0] = d1 + 0.5f*(in-d1);	// interpolate
    		out[1] = in;
    		d1 = in; // store delay
    	}
    
    	// 4x interpolator
    	// out: pointer to float[4]
    	inline void process4x(float const in, float *out) {
    		float y = in-d1;
    		out[0] = d1 + 0.25f*y;	// interpolate
    		out[1] = d1 + 0.5f*y;
    		out[2] = d1 + 0.75f*y;
    		out[3] = in;
    		d1 = in; // store delay
    	}
    
    	// 8x interpolator
    	// out: pointer to float[8]
    	inline void process8x(float const in, float *out) {
    		float y = in-d1;
    		out[0] = d1 + 0.125f*y;	// interpolate
    		out[1] = d1 + 0.25f*y;
    		out[2] = d1 + 0.375f*y;
    		out[3] = d1 + 0.5f*y;
    		out[4] = d1 + 0.625f*y;
    		out[5] = d1 + 0.75f*y;
    		out[6] = d1 + 0.875f*y;
    		out[7] = in;
    		d1 = in; // store delay
    	}
    
    	// 16x interpolator
    	// out: pointer to float[16]
    	inline void process16x(float const in, float *out) {
    		float y = in-d1;
    		out[0] = d1 + (1.0f/16.0f)*y;	// interpolate
    		out[1] = d1 + (2.0f/16.0f)*y;	
    		out[2] = d1 + (3.0f/16.0f)*y;	
    		out[3] = d1 + (4.0f/16.0f)*y;	
    		out[4] = d1 + (5.0f/16.0f)*y;	
    		out[5] = d1 + (6.0f/16.0f)*y;	
    		out[6] = d1 + (7.0f/16.0f)*y;	
    		out[7] = d1 + (8.0f/16.0f)*y;	
    		out[8] = d1 + (9.0f/16.0f)*y;	
    		out[9] = d1 + (10.0f/16.0f)*y;	
    		out[10] = d1 + (11.0f/16.0f)*y;	
    		out[11] = d1 + (12.0f/16.0f)*y;	
    		out[12] = d1 + (13.0f/16.0f)*y;	
    		out[13] = d1 + (14.0f/16.0f)*y;	
    		out[14] = d1 + (15.0f/16.0f)*y;	
    		out[15] = in;		
    		d1 = in; // store delay
    	}
    
    	// 32x interpolator
    	// out: pointer to float[32]
    	inline void process32x(float const in, float *out) {
    		float y = in-d1;
    		out[0] = d1 + (1.0f/32.0f)*y;	// interpolate
    		out[1] = d1 + (2.0f/32.0f)*y;	
    		out[2] = d1 + (3.0f/32.0f)*y;	
    		out[3] = d1 + (4.0f/32.0f)*y;	
    		out[4] = d1 + (5.0f/32.0f)*y;	
    		out[5] = d1 + (6.0f/32.0f)*y;	
    		out[6] = d1 + (7.0f/32.0f)*y;	
    		out[7] = d1 + (8.0f/32.0f)*y;	
    		out[8] = d1 + (9.0f/32.0f)*y;	
    		out[9] = d1 + (10.0f/32.0f)*y;	
    		out[10] = d1 + (11.0f/32.0f)*y;	
    		out[11] = d1 + (12.0f/32.0f)*y;	
    		out[12] = d1 + (13.0f/32.0f)*y;	
    		out[13] = d1 + (14.0f/32.0f)*y;	
    		out[14] = d1 + (15.0f/32.0f)*y;	
    		out[15] = d1 + (16.0f/32.0f)*y;	
    		out[16] = d1 + (17.0f/32.0f)*y;	
    		out[17] = d1 + (18.0f/32.0f)*y;	
    		out[18] = d1 + (19.0f/32.0f)*y;	
    		out[19] = d1 + (20.0f/32.0f)*y;	
    		out[20] = d1 + (21.0f/32.0f)*y;	
    		out[21] = d1 + (22.0f/32.0f)*y;	
    		out[22] = d1 + (23.0f/32.0f)*y;	
    		out[23] = d1 + (24.0f/32.0f)*y;	
    		out[24] = d1 + (25.0f/32.0f)*y;	
    		out[25] = d1 + (26.0f/32.0f)*y;	
    		out[26] = d1 + (27.0f/32.0f)*y;	
    		out[27] = d1 + (28.0f/32.0f)*y;	
    		out[28] = d1 + (29.0f/32.0f)*y;	
    		out[29] = d1 + (30.0f/32.0f)*y;	
    		out[30] = d1 + (31.0f/32.0f)*y;	
    		out[31] = in;		
    		d1 = in; // store delay
    	}
    
    private:
    	float d1; // previous input
    };
    
    #endif
    

Comments
--------

- **Date**: 2013-03-31 20:45:21
- **By**: moc.liamg@jdcisumff

.. code-block:: text

    I incorporated the 32x interpolator with something along this 
    
    void process32x(float const in_l, float const in_r, float *out_l, float *out_r) 
    {
            float y_l = in_l-f_d1_l;
            out_l[0] = f_d1_l + (1.0f/32.0f)*y_l;    // interpolate
            out_l[1] = f_d1_l + (2.0f/32.0f)*y_l;    
            out_l[2] = f_d1_l + (3.0f/32.0f)*y_l;    
            out_l[3] = f_d1_l + (4.0f/32.0f)*y_l;    
            out_l[4] = f_d1_l + (5.0f/32.0f)*y_l;    
            out_l[5] = f_d1_l + (6.0f/32.0f)*y_l;    
            out_l[6] = f_d1_l + (7.0f/32.0f)*y_l;    
            out_l[7] = f_d1_l + (8.0f/32.0f)*y_l;    
            out_l[8] = f_d1_l + (9.0f/32.0f)*y_l;    
            out_l[9] = f_d1_l + (10.0f/32.0f)*y_l;    
            out_l[10] = f_d1_l + (11.0f/32.0f)*y_l;    
            out_l[11] = f_d1_l + (12.0f/32.0f)*y_l;    
            out_l[12] = f_d1_l + (13.0f/32.0f)*y_l;    
            out_l[13] = f_d1_l + (14.0f/32.0f)*y_l;    
            out_l[14] = f_d1_l + (15.0f/32.0f)*y_l;    
            out_l[15] = f_d1_l + (16.0f/32.0f)*y_l;    
            out_l[16] = f_d1_l + (17.0f/32.0f)*y_l;    
            out_l[17] = f_d1_l + (18.0f/32.0f)*y_l;    
            out_l[18] = f_d1_l + (19.0f/32.0f)*y_l;    
            out_l[19] = f_d1_l + (20.0f/32.0f)*y_l;    
            out_l[20] = f_d1_l + (21.0f/32.0f)*y_l;    
            out_l[21] = f_d1_l + (22.0f/32.0f)*y_l;    
            out_l[22] = f_d1_l + (23.0f/32.0f)*y_l;    
            out_l[23] = f_d1_l + (24.0f/32.0f)*y_l;    
            out_l[24] = f_d1_l + (25.0f/32.0f)*y_l;    
            out_l[25] = f_d1_l + (26.0f/32.0f)*y_l;    
            out_l[26] = f_d1_l + (27.0f/32.0f)*y_l;    
            out_l[27] = f_d1_l + (28.0f/32.0f)*y_l;    
            out_l[28] = f_d1_l + (29.0f/32.0f)*y_l;    
            out_l[29] = f_d1_l + (30.0f/32.0f)*y_l;    
            out_l[30] = f_d1_l + (31.0f/32.0f)*y_l;    
            out_l[31] = in_l;        
            f_d1_l = in_l; // store delay_l
    
    		float y_r = in_r-f_d1_r;
            out_r[0] = f_d1_r + (1.0f/32.0f)*y_r;    // inrterpolate
            out_r[1] = f_d1_r + (2.0f/32.0f)*y_r;    
            out_r[2] = f_d1_r + (3.0f/32.0f)*y_r;    
            out_r[3] = f_d1_r + (4.0f/32.0f)*y_r;    
            out_r[4] = f_d1_r + (5.0f/32.0f)*y_r;    
            out_r[5] = f_d1_r + (6.0f/32.0f)*y_r;    
            out_r[6] = f_d1_r + (7.0f/32.0f)*y_r;    
            out_r[7] = f_d1_r + (8.0f/32.0f)*y_r;    
            out_r[8] = f_d1_r + (9.0f/32.0f)*y_r;    
            out_r[9] = f_d1_r + (10.0f/32.0f)*y_r;    
            out_r[10] = f_d1_r + (11.0f/32.0f)*y_r;    
            out_r[11] = f_d1_r + (12.0f/32.0f)*y_r;    
            out_r[12] = f_d1_r + (13.0f/32.0f)*y_r;    
            out_r[13] = f_d1_r + (14.0f/32.0f)*y_r;    
            out_r[14] = f_d1_r + (15.0f/32.0f)*y_r;    
            out_r[15] = f_d1_r + (16.0f/32.0f)*y_r;    
            out_r[16] = f_d1_r + (17.0f/32.0f)*y_r;    
            out_r[17] = f_d1_r + (18.0f/32.0f)*y_r;    
            out_r[18] = f_d1_r + (19.0f/32.0f)*y_r;    
            out_r[19] = f_d1_r + (20.0f/32.0f)*y_r;    
            out_r[20] = f_d1_r + (21.0f/32.0f)*y_r;    
            out_r[21] = f_d1_r + (22.0f/32.0f)*y_r;    
            out_r[22] = f_d1_r + (23.0f/32.0f)*y_r;    
            out_r[23] = f_d1_r + (24.0f/32.0f)*y_r;    
            out_r[24] = f_d1_r + (25.0f/32.0f)*y_r;    
            out_r[25] = f_d1_r + (26.0f/32.0f)*y_r;    
            out_r[26] = f_d1_r + (27.0f/32.0f)*y_r;    
            out_r[27] = f_d1_r + (28.0f/32.0f)*y_r;    
            out_r[28] = f_d1_r + (29.0f/32.0f)*y_r;    
            out_r[29] = f_d1_r + (30.0f/32.0f)*y_r;    
            out_r[30] = f_d1_r + (31.0f/32.0f)*y_r;    
            out_r[31] = in_r;        
            f_d1_r = in_r; // store delay_r
    }
    
    Unfortunately, I am doing something crazy wrong. When I close my plug-in, my DAW freezes. I'm fairly new to programming and am not sure what I'm doing wrong. 
    
    I'm using your function to write to an audio buffer which is being set to a delay. This is what the call looks like.
    process32x((fLeftAudioBuffer[i] * decay), (fRightAudioBuffer[i] * decay), 
    			&fCircularLeftAudioBuffer[(fCircularBufferPosition + delayFrames)%kCircularBufferSize], 
    			&fCircularRightAudioBuffer[(fCircularBufferPosition + delayFrames)%kCircularBufferSize]);
    
    I would love to use this function because it's one line less than how I usually do it. It works great with no problems. 
    fCircularLeftAudioBuffer[(fCircularBufferPosition + delayFrames)%kCircularBufferSize] = fLeftAudioBuffer[jh] * decay;
    fCircularRightAudioBuffer[(fCircularBufferPosition + delayFrames)%kCircularBufferSize] = fRightAudioBuffer[jh] * decay;
    
               
    Everything seems simple, but I'm puzzled as to what may be wrong. Thanks. 

- **Date**: 2013-03-31 22:18:36
- **By**: moc.liamg@jdcisumff

.. code-block:: text

    Never mind. I was calling the function from the wrong place. Works like a charm. 
    
    Thank you.               

