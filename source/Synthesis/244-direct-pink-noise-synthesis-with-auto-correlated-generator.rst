Direct pink noise synthesis with auto-correlated generator
==========================================================

- **Author or source:** RidgeRat <ten.knilhtrae@6741emmartl>
- **Type:** 16-bit fixed-point
- **Created:** 2007-02-11 20:15:42


.. code-block:: text
    :caption: notes

    Canonical C++ class with minimum system dependencies, BUT you must provide your own
    uniform random number generator. Accurate range is a little over 9 octaves, degrading
    gracefully beyond this. Estimated deviations +-0.25 dB from ideal 1/f curve in range.
    Scaled to fit signed 16-bit range.


.. code-block:: c++
    :linenos:
    :caption: code

    // Pink noise class using the autocorrelated generator method.
    // Method proposed and described by Larry Trammell "the RidgeRat" --
    // see http://home.earthlink.net/~ltrammell/tech/newpink.htm
    // There are no restrictions.
    //
    // ------------------------------------------------------------------
    //
    // This is a canonical, 16-bit fixed-point implementation of the
    // generator in 32-bit arithmetic. There are only a few system
    // dependencies. 
    //
    //   -- access to an allocator 'malloc' for operator new
    //   -- access to definition of 'size_t'
    //   -- assumes 32-bit two's complement arithmetic
    //   -- assumes long int is 32 bits, short int is 16 bits
    //   -- assumes that signed right shift propagates the sign bit 
    //
    // It needs a separate URand class to provide uniform 16-bit random
    // numbers on interval [1,65535]. The assumed class must provide
    // methods to query and set the current seed value, establish a
    // scrambled initial seed value, and evaluate uniform random values. 
    // 
    //
    // ----------- header -----------------------------------------------
    // pinkgen.h
    
    #ifndef  _pinkgen_h_
    #define  _pinkgen_h_  1
    
    #include  <stddef.h>
    #include  <alloc.h>
    
    // You must provide the uniform random generator class.
    #ifndef  _URand_h_
    #include  "URand.h"
    #endif
    
    class PinkNoise {
      private:
        // Coefficients (fixed)
        static long int const pA[5];
        static short int const pPSUM[5];
    
        // Internal pink generator state
        long int   contrib[5];   // stage contributions
        long int   accum;        // combined generators
        void       internal_clear( );           
    
        // Include a UNoise component
        URand     ugen;
    
      public:
        PinkNoise( );
        PinkNoise( PinkNoise & );
        ~PinkNoise( );
        void *  operator new( size_t );
        void  pinkclear( );
        short int  pinkrand( );
    } ;
    #endif
    
    // ----------- implementation ---------------------------------------
    // pinkgen.cpp
    
    #include  "pinkgen.h"
    
    // Static class data
    long int const PinkNoise::pA[5] = 
        { 14055, 12759, 10733, 12273, 15716 };
    short int const PinkNoise::pPSUM[5] =
        { 22347, 27917, 29523, 29942, 30007 };
    
    // Clear generator to a zero state.
    void   PinkNoise::pinkclear( )
    {
        int  i;
        for  (i=0; i<5; ++i)  { contrib[i]=0L; }
        accum = 0L;
    }
    
    // PRIVATE, clear generator and also scramble the internal
    // uniform generator seed.
    void   PinkNoise::internal_clear( )
    {
        pinkclear();
        ugen.seed(0);    // Randomizes the seed!
    }
    
    // Constructor. Guarantee that initial state is cleared
    // and uniform generator scrambled.
    PinkNoise::PinkNoise( )
    {
        internal_clear();
    }
    
    // Copy constructor. Preserve generator state from the source
    // object, including the uniform generator seed.
    PinkNoise::PinkNoise( PinkNoise & Source )
    {
        int  i;
        for (i=0; i<5; ++i)  contrib[i]=Source.contrib[i];
        accum = Source.accum;
        ugen.seed( Source.ugen.seed( ) );
    }
    
    // Operator new. Just fetch required object storage.
    void *   PinkNoise::operator new( size_t size )
    {
        return   malloc(size);
    }
    
    // Destructor. No special action required.
    PinkNoise::~PinkNoise( )  { /* NIL */ }
    
    // Coding artifact for convenience
    #define   UPDATE_CONTRIB(n)  \
         {                                   \
           accum -= contrib[n];              \
           contrib[n] = (long)randv * pA[n]; \
           accum += contrib[n];              \
           break;                            \
         }                                   
    
    // Evaluate next randomized 'pink' number with uniform CPU loading.
    short int   PinkNoise::pinkrand( )
    {
        short int  randu = ugen.urand() & 0x7fff;     // U[0,32767]
        short int  randv = (short int) ugen.urand();  // U[-32768,32767]
    
        // Structured block, at most one update is performed
        while (1) 
        {
          if (randu < pPSUM[0]) UPDATE_CONTRIB(0);
          if (randu < pPSUM[1]) UPDATE_CONTRIB(1);
          if (randu < pPSUM[2]) UPDATE_CONTRIB(2);
          if (randu < pPSUM[3]) UPDATE_CONTRIB(3);
          if (randu < pPSUM[4]) UPDATE_CONTRIB(4);
          break;
        }
        return (short int) (accum >> 16);
    }
    
    // ----------- application   -------------------------------
    
    short int    pink_signal[1024];
    
    void   example(void)
    {
        PinkNoise    pinkgen;
        int  i;
        for  (i=0; i<1024; ++i)   pink_signal[i] = pinkgen.pinkrand();
    }
    

