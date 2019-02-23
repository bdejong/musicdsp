Trammell Pink Noise (C++ class)
===============================

- **Author or source:** ude.drofnats.amrcc@lfd
- **Type:** pink noise generator
- **Created:** 2006-05-06 08:40:38



.. code-block:: c++
    :linenos:
    :caption: code

    #ifndef _PinkNoise_H
    #define _PinkNoise_H
    
    // Technique by Larry "RidgeRat" Trammell 3/2006
    // http://home.earthlink.net/~ltrammell/tech/pinkalg.htm
    // implementation and optimization by David Lowenfels
    
    #include <cstdlib>
    #include <ctime>
    
    #define PINK_NOISE_NUM_STAGES 3
    
    class PinkNoise {
    public:
      PinkNoise() {
      srand ( time(NULL) ); // initialize random generator
        clear();
      }
    
      void clear() {
        for( size_t i=0; i< PINK_NOISE_NUM_STAGES; i++ )
          state[ i ] = 0.0;
        }
    	
      float tick() {
        static const float RMI2 = 2.0 / float(RAND_MAX); // + 1.0; // change for range [0,1)
        static const float offset = A[0] + A[1] + A[2];
    
      // unrolled loop
        float temp = float( rand() );
        state[0] = P[0] * (state[0] - temp) + temp;
        temp = float( rand() );
        state[1] = P[1] * (state[1] - temp) + temp;
        temp = float( rand() );		
        state[2] = P[2] * (state[2] - temp) + temp;
        return ( A[0]*state[0] + A[1]*state[1] + A[2]*state[2] )*RMI2 - offset;
      }
    
    protected:
      float state[ PINK_NOISE_NUM_STAGES ];
      static const float A[ PINK_NOISE_NUM_STAGES ];
      static const float P[ PINK_NOISE_NUM_STAGES ];
    };
    
    const float PinkNoise::A[] = { 0.02109238, 0.07113478, 0.68873558 }; // rescaled by (1+P)/(1-P)
    const float PinkNoise::P[] = { 0.3190,  0.7756,  0.9613  };
    
    #endif
    

Comments
--------

- **Date**: 2007-02-09 06:15:59
- **By**: ten.knilhtrae@6741emmartl

.. code-block:: text

     Many thanks to David Lowenfels for posting this implementation of the early experimental version. I recommend switching to the new algorithm form described in 'newpink.htm' -- better range to 9+ octaves, better accuracy to +-0.25 dB, and leveled computational loading.  So where is MY submission to the archive? Um...  well, it's coming... if he doesn't beat me to the punch again and post his code first! -- Larry Trammell (the RidgeRat)             

