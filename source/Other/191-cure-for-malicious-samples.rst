Cure for malicious samples
==========================

- **Author or source:** moc.eh-u@sru
- **Type:** Filters Denormals, NaNs, Infinities
- **Created:** 2005-03-24 00:32:54


.. code-block:: text
    :caption: notes

    A lot of incidents can happen during processing samples. A nasty one is denormalization,
    which makes cpus consume insanely many cycles for easiest instructions.
    
    But even worse, if you have NaNs or Infinities inside recursive structures, maybe due to
    division by zero,  all subsequent samples that are multiplied with these values will get
    "infected" and become NaN or Infinity. Your sound makes BLIPPP and that was it, silence
    from the speakers.
    
    Thus I've written a small function that sets all of these cases to 0.0f.
    
    You'll notice that I treat a buffer of floats as unsigned integers. And I avaoid branches
    by using comparison results as 0 or 1.
    
    When compiled with GCC, this function should not create any "hidden" branches, but you
    should verify the assembly code anyway. Sometimes some parenthesis do the trick...
    
    ;)  Urs


.. code-block:: c++
    :linenos:
    :caption: code

    #ifndef UInt32
    #define UInt32 unsigned int
    #endif
    
    void erase_All_NaNs_Infinities_And_Denormals( float* inSamples, int& inNumberOfSamples )
    {
    	UInt32* inArrayOfFloats = (UInt32*) inSamples;
    
    	for ( int i = 0; i < inNumberOfSamples; i++ )
    	{
    		UInt32 sample = *inArrayOfFloats;
    		UInt32 exponent = sample & 0x7F800000;
    		
    			// exponent < 0x7F800000 is 0 if NaN or Infinity, otherwise 1
    			// exponent > 0 is 0 if denormalized, otherwise 1
    			
    		int aNaN = exponent < 0x7F800000;
    		int aDen = exponent > 0;
    			
    		*inArrayOfFloats++ = sample * ( aNaN & aDen );
    	
    	}
    }
    

Comments
--------

- **Date**: 2005-05-14 17:18:12
- **By**: dont-email-me

.. code-block:: text

    #include <inttypes.h>
    and use std::uint32_t
    or typedef (not #define)
    
    int const & inNumberOfSamples
    

- **Date**: 2005-10-14 18:36:07
- **By**: DevilishHabib

.. code-block:: text

    Isn't it bad to declare variables within for loop?
    If someone has VC++ standard (no optimizer included, thanks Bill :-( ) , the cycles gained by removing denormals, will be eaten by declaring 4 variables per loop cycle, so watch out !
    
    

- **Date**: 2007-05-11 05:51:36
- **By**: if.iki@xemxet

.. code-block:: text

    DevilishHabib, that's rubbish. It doesn't matter where the declaration is as long as the code works. Declaring outside the loop is the same thing (you can verify this). 
    
    Urs, nice code but you don't get rid of branches just like that. Comparision is comparision no matter what. Your code is equal to "int aNaN = exponent < 0x7F800000 ? 1 : 0;" which is equal to "int aNan = 0; if (exponent < 0x7F800000) aNan = 1;" If we are talking about x86 asm here, there is no instruction that would do the conditional assignment needed. MMX/SSE has it, though.

- **Date**: 2014-10-18 18:36:44
- **By**: none

.. code-block:: text

    texmex, nope, the result of < or > does not create any branches on x86.

