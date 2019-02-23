Fast cube root, square root, and reciprocal for x86/SSE CPUs.
=============================================================

- **Author or source:** moc.noicratse@ajelak
- **Created:** 2005-05-29 18:36:40


.. code-block:: text
    :caption: notes

    All of these methods use SSE instructions or bit twiddling tricks to get a rough
    approximation to cube root, square root, or reciprocal, which is then refined with one or
    more Newton-Raphson approximation steps.
    
    Each is named to indicate its approximate level of accuracy and a comment describes its
    performance relative to the conventional versions.
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    // These functions approximate reciprocal, square root, and 
    // cube root to varying degrees of precision substantially 
    // faster than the straightforward methods 1/x, sqrtf(x), 
    // and powf( x, 1.0f/3.0f ). All require SSE-enabled CPU & OS.
    // Unlike the powf() solution, the cube roots also correctly
    // handle negative inputs.  
    
    #define REALLY_INLINE __forceinline
    
    // ~34 clocks on Pentium M vs. ~360 for powf 
    REALLY_INLINE float cuberoot_sse_8bits( float x )
    {
    	float z;
    	static const float three = 3.0f;
    	_asm
    	{
    		mov		eax, x				// x as bits
    		movss	xmm2, x				// x2: x
    		movss	xmm1, three			// x1: 3
    		// Magic floating point cube root done with integer math.
    		// The exponent is divided by three in such a way that 
    		// remainder bits get shoved into the top of the normalized 
    		// mantissa. 
    		mov		ecx, eax			// copy of x
    		and		eax, 0x7FFFFFFF		// exponent & mantissa of x in biased-127
    		sub     eax, 0x3F800000		// exponent & mantissa of x in 2's comp
    		sar     eax, 10				// 
    		imul    eax, 341			// 341/1024 ~= .333
    		add		eax, 0x3F800000		// back to biased-127
    		and     eax, 0x7FFFFFFF		// remask
    		and		ecx, 0x80000000		// original sign and mantissa
    		or      eax, ecx			// masked new exponent, old sign and mantissa
    		mov		z, eax				// 
    		
    		// use SSE to refine the first approximation
    		movss	xmm0, z				;// x0: z
    		movss	xmm3, xmm0			;// x3: z
    		mulss	xmm3, xmm0			;// x3: z*z
    		movss	xmm4, xmm3			;// x4: z*z
    		mulss   xmm3, xmm1			;// x3: 3*z*z
    		rcpss	xmm3, xmm3			;// x3: ~ 1/(3*z*z)
    		mulss   xmm4, xmm0			;// x4: z*z*z
    		subss	xmm4, xmm2			;// x4: z*z*z-x
    		mulss	xmm4, xmm3			;// x4: (z*z*z-x) / (3*z*z)
    		subss	xmm0, xmm4			;// x0: z' accurate to within about 0.3%
    		movss	z, xmm0
    	}
    
    	return z;
    }
    
    // ~60 clocks on Pentium M vs. ~360 for powf
    REALLY_INLINE float cuberoot_sse_16bits( float x )
    {
    	float z;
    	static const float three = 3.0f;
    	_asm
    	{
    		mov		eax, x				// x as bits
    		movss	xmm2, x				// x2: x
    		movss	xmm1, three			// x1: 3
    		// Magic floating point cube root done with integer math.
    		// The exponent is divided by three in such a way that 
    		// remainder bits get shoved into the top of the normalized 
    		// mantissa. 
    		mov		ecx, eax			// copy of x
    		and		eax, 0x7FFFFFFF		// exponent & mantissa of x in biased-127
    		sub     eax, 0x3F800000		// exponent & mantissa of x in 2's comp
    		sar     eax, 10				// 
    		imul    eax, 341			// 341/1024 ~= .333
    		add		eax, 0x3F800000		// back to biased-127
    		and     eax, 0x7FFFFFFF		// remask
    		and		ecx, 0x80000000		// original sign and mantissa
    		or      eax, ecx			// masked new exponent, old sign and mantissa
    		mov		z, eax				// 
    		
    		// use SSE to refine the first approximation
    		movss	xmm0, z				;// x0: z
    		movss	xmm3, xmm0			;// x3: z
    		mulss	xmm3, xmm0			;// x3: z*z
    		movss	xmm4, xmm3			;// x4: z*z
    		mulss   xmm3, xmm1			;// x3: 3*z*z
    		rcpss	xmm3, xmm3			;// x3: ~ 1/(3*z*z)
    		mulss   xmm4, xmm0			;// x4: z*z*z
    		subss	xmm4, xmm2			;// x4: z*z*z-x
    		mulss	xmm4, xmm3			;// x4: (z*z*z-x) / (3*z*z)
    		subss	xmm0, xmm4			;// x0: z' accurate to within about 0.3%
    
    		movss	xmm3, xmm0			;// x3: z
    		mulss	xmm3, xmm0			;// x3: z*z
    		movss	xmm4, xmm3			;// x4: z*z
    		mulss   xmm3, xmm1			;// x3: 3*z*z
    		rcpss	xmm3, xmm3			;// x3: ~ 1/(3*z*z)
    		mulss   xmm4, xmm0			;// x4: z*z*z
    		subss	xmm4, xmm2			;// x4: z*z*z-x
    		mulss	xmm4, xmm3			;// x4: (z*z*z-x) / (3*z*z)
    		subss	xmm0, xmm4			;// x0: z'' accurate to within about 0.001%
    
    		movss	z, xmm0
    	}
    	
    	return z;
    }
    
    // ~77 clocks on Pentium M vs. ~360 for powf
    REALLY_INLINE float cuberoot_sse_22bits( float x )
    {
    	float z;
    	static const float three = 3.0f;
    	_asm
    	{
    		mov		eax, x				// x as bits
    		movss	xmm2, x				// x2: x
    		movss	xmm1, three			// x1: 3
    		// Magic floating point cube root done with integer math.
    		// The exponent is divided by three in such a way that 
    		// remainder bits get shoved into the top of the normalized 
    		// mantissa. 
    		mov		ecx, eax			// copy of x
    		and		eax, 0x7FFFFFFF		// exponent & mantissa of x in biased-127
    		sub     eax, 0x3F800000		// exponent & mantissa of x in 2's comp
    		sar     eax, 10				// 
    		imul    eax, 341			// 341/1024 ~= .333
    		add		eax, 0x3F800000		// back to biased-127
    		and     eax, 0x7FFFFFFF		// remask
    		and		ecx, 0x80000000		// original sign and mantissa
    		or      eax, ecx			// masked new exponent, old sign and mantissa
    		mov		z, eax				// 
    		
    		// use SSE to refine the first approximation
    		movss	xmm0, z				// x0: z
    		movss	xmm3, xmm0			// x3: z
    		mulss	xmm3, xmm0			// x3: z*z
    		movss	xmm4, xmm3			// x4: z*z
    		mulss   xmm3, xmm1			// x3: 3*z*z
    		rcpss	xmm3, xmm3			// x3: ~ 1/(3*z*z)
    		mulss   xmm4, xmm0			// x4: z*z*z
    		subss	xmm4, xmm2			// x4: z*z*z-x
    		mulss	xmm4, xmm3			// x4: (z*z*z-x) / (3*z*z)
    		subss	xmm0, xmm4			// x0: z' accurate to within about 0.3%
    		
    		movss	xmm3, xmm0			// x3: z
    		mulss	xmm3, xmm0			// x3: z*z
    		movss	xmm4, xmm3			// x4: z*z
    		mulss   xmm3, xmm1			// x3: 3*z*z
    		rcpss	xmm3, xmm3			// x3: ~ 1/(3*z*z)
    		mulss   xmm4, xmm0			// x4: z*z*z
    		subss	xmm4, xmm2			// x4: z*z*z-x
    		mulss	xmm4, xmm3			// x4: (z*z*z-x) / (3*z*z)
    		subss	xmm0, xmm4			// x0: z'' accurate to within about 0.001%
    
    		movss	xmm3, xmm0			// x3: z
    		mulss	xmm3, xmm0			// x3: z*z
    		movss	xmm4, xmm3			// x4: z*z
    		mulss   xmm3, xmm1			// x3: 3*z*z
    		rcpss	xmm3, xmm3			// x3: ~ 1/(3*z*z)
    		mulss   xmm4, xmm0			// x4: z*z*z
    		subss	xmm4, xmm2			// x4: z*z*z-x
    		mulss	xmm4, xmm3			// x4: (z*z*z-x) / (3*z*z)
    		subss	xmm0, xmm4			// x0: z''' accurate to within about 0.000012%
    		
    		movss	z, xmm0
    	}
    	
    	return z;
    }
    
    // ~6 clocks on Pentium M vs. ~24 for single precision sqrtf
    REALLY_INLINE float squareroot_sse_11bits( float x )
    {
    	float z;
    	_asm
    	{
    		rsqrtss xmm0, x
    		rcpss	xmm0, xmm0
    		movss	z, xmm0			// z ~= sqrt(x) to 0.038%
    	}
    	return z;
    }
    
    // ~19 clocks on Pentium M vs. ~24 for single precision sqrtf
    REALLY_INLINE float squareroot_sse_22bits( float x )
    {
    	static float half = 0.5f;
    	float z;
    	_asm
    	{
     		movss	xmm1, x			// x1: x 
    		rsqrtss xmm2, xmm1		// x2: ~1/sqrt(x) = 1/z
    		rcpss	xmm0, xmm2		// x0: z == ~sqrt(x) to 0.05%
    		
    		movss	xmm4, xmm0		// x4: z
    		movss	xmm3, half
     		mulss	xmm4, xmm4		// x4: z*z
    		mulss	xmm2, xmm3		// x2: 1 / 2z
    		subss	xmm4, xmm1		// x4: z*z-x
    		mulss	xmm4, xmm2		// x4: (z*z-x)/2z
    		subss	xmm0, xmm4		// x0: z' to 0.000015%
    		
    		movss	z, xmm0		   
    	}
    	return z;
    }
    
    // ~12 clocks on Pentium M vs. ~16 for single precision divide
    REALLY_INLINE float reciprocal_sse_22bits( float x )
    {
    	float z;
    	_asm
    	{
    		rcpss	xmm0, x			// x0: z ~= 1/x
    		movss	xmm2, x			// x2: x
    		movss	xmm1, xmm0		// x1: z ~= 1/x
    		addss	xmm0, xmm0		// x0: 2z
    		mulss	xmm1, xmm1		// x1: z^2
    		mulss	xmm1, xmm2		// x1: xz^2
    		subss	xmm0, xmm1		// x0: z' ~= 1/x to 0.000012%
    
    		movss	z, xmm0		   
    	}
    	return z;
    }
    

