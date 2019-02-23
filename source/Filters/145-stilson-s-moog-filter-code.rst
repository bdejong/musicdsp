Stilson's Moog filter code
==========================

- **Author or source:** DFL
- **Type:** 4-pole LP, with fruity BP/HP
- **Created:** 2003-05-15 14:23:51


.. code-block:: text
    :caption: notes

    Mind your p's and Q's...
    
    This code was borrowed from Tim Stilson, and rewritten by me into a pd extern (moog~)
    available here:
    http://www-ccrma.stanford.edu/~dfl/pd/index.htm
    
    I ripped out the essential code and pasted it here...


.. code-block:: c++
    :linenos:
    :caption: code

    WARNING: messy code follows ;)
    
    // table to fixup Q in order to remain constant for various pole frequencies, from Tim Stilson's code @ CCRMA (also in CLM distribution)
    
    static float gaintable[199] = { 0.999969, 0.990082, 0.980347, 0.970764, 0.961304, 0.951996, 0.94281, 0.933777, 0.924866, 0.916077, 0.90741, 0.898865, 0.89044
    2, 0.882141 , 0.873962, 0.865906, 0.857941, 0.850067, 0.842346, 0.834686, 0.827148, 0.819733, 0.812378, 0.805145, 0.798004, 0.790955, 0.783997, 0.77713, 0.77
    0355, 0.763672, 0.75708 , 0.75058, 0.744141, 0.737793, 0.731537, 0.725342, 0.719238, 0.713196, 0.707245, 0.701355, 0.695557, 0.689819, 0.684174, 0.678558, 0.
    673035, 0.667572, 0.66217, 0.65686, 0.651581, 0.646393, 0.641235, 0.636169, 0.631134, 0.62619, 0.621277, 0.616425, 0.611633, 0.606903, 0.602234, 0.597626, 0.
    593048, 0.588531, 0.584045, 0.579651, 0.575287 , 0.570953, 0.566681, 0.562469, 0.558289, 0.554169, 0.550079, 0.546051, 0.542053, 0.538116, 0.53421, 0.530334,
     0.52652, 0.522736, 0.518982, 0.515289, 0.511627, 0.507996 , 0.504425, 0.500885, 0.497375, 0.493896, 0.490448, 0.487061, 0.483704, 0.480377, 0.477081, 0.4738
    16, 0.470581, 0.467377, 0.464203, 0.46109, 0.457977, 0.454926, 0.451874, 0.448883, 0.445892, 0.442932, 0.440033, 0.437134, 0.434265, 0.431427, 0.428619, 0.42
    5842, 0.423096, 0.42038, 0.417664, 0.415009, 0.412354, 0.409729, 0.407135, 0.404572, 0.402008, 0.399506, 0.397003, 0.394501, 0.392059, 0.389618, 0.387207, 0.
    384827, 0.382477, 0.380127, 0.377808, 0.375488, 0.37323, 0.370972, 0.368713, 0.366516, 0.364319, 0.362122, 0.359985, 0.357849, 0.355713, 0.353607, 0.351532, 
    0.349457, 0.347412, 0.345398, 0.343384, 0.34137, 0.339417, 0.337463, 0.33551, 0.333588, 0.331665, 0.329773, 0.327911, 0.32605, 0.324188, 0.322357, 0.320557, 
    0.318756, 0.316986, 0.315216, 0.313446, 0.311707, 0.309998, 0.308289, 0.30658, 0.304901, 0.303223, 0.301575, 0.299927, 0.298309, 0.296692, 0.295074, 0.293488
    , 0.291931, 0.290375, 0.288818, 0.287262, 0.285736, 0.284241, 0.282715, 0.28125, 0.279755, 0.27829, 0.276825, 0.275391, 0.273956, 0.272552, 0.271118, 0.26974
    5, 0.268341, 0.266968, 0.265594, 0.264252, 0.262909, 0.261566, 0.260223, 0.258911, 0.257599, 0.256317, 0.255035, 0.25375 };
    
    static inline float saturate( float input ) { //clamp without branching
    #define _limit 0.95
      float x1 = fabsf( input + _limit );
      float x2 = fabsf( input - _limit );
      return 0.5 * (x1 - x2);
    }
    
    static inline float crossfade( float amount, float a, float b ) {
      return (1-amount)*a + amount*b;
    }
    
    //code for setting Q
            float ix, ixfrac;
            int ixint;
            ix = x->p * 99;
            ixint = floor( ix );
            ixfrac = ix - ixint;
        	Q = resonance * crossfade( ixfrac, gaintable[ ixint + 99 ], gaintable[ ixint + 100 ] );
    
    //code for setting pole coefficient based on frequency
        float fc = 2 * frequency / x->srate;
        float x2 = fc*fc;
        float x3 = fc*x2;
        p = -0.69346 * x3 - 0.59515 * x2 + 3.2937 * fc - 1.0072; //cubic fit by DFL, not 100% accurate but better than nothing...
    }
    
    
    process loop:
      float state[4], output; //should be global scope / preserved between calls
      int i,pole;
      float temp, input;
    
      for ( i=0; i < numSamples; i++ ) {
              input = *(in++);
              output = 0.25 * ( input - output ); //negative feedback
              
              for( pole = 0; pole < 4; pole++) {
                      temp = state[pole];
                      output = saturate( output + p * (output - temp));
                      state[pole] = output;
                      output = saturate( output + temp );
              }
              lowpass = output;
              highpass = input - output;
              bandpass = 3 * x->state[2] - x->lowpass; //got this one from paul kellet
              *out++ = lowpass;
    
              output *= Q;  //scale the feedback
      }

Comments
--------

- **Date**: 2004-06-07 08:01:13
- **By**: ku.oc.sdnuosdionamuh@nhoj

.. code-block:: text

    What is "x->p" in the code for setting Q?        

- **Date**: 2004-06-09 07:19:43
- **By**: DFL

.. code-block:: text

    you should set the frequency first, to get the value of p.
    Then use that value to get the normalized Q value.
    

- **Date**: 2004-06-09 12:22:00
- **By**: ku.oc.sdnuosdionamuh@nhoj

.. code-block:: text

    Ah! That p. Thanks.

- **Date**: 2009-01-06 13:35:18
- **By**: soeren.parton->soerenskleinewelt,de

.. code-block:: text

    Hi!
    
    My Output gets stuck at about 1E-7 even when the input is way below. Is that a quantisation problem? Looks as if it´s the saturation´s fault...
    
    Cheers
    Sören

- **Date**: 2010-10-27 15:51:42
- **By**: ten.reknirdaet@cisum

.. code-block:: text

    I have not tested, but it looks like gaintable and interpolation can be replaced using approx:
     1 / (x * 1.48 + 0.85) - 0.1765
    
    (range 0 -> 1)
    
    Peace
    /Martin
    

