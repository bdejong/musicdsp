Dither code
===========

- **Author or source:** Paul Kellett
- **Type:** Dither with noise-shaping
- **Created:** 2002-01-17 03:13:20


.. code-block:: text
    :caption: notes

    This is a simple implementation of highpass triangular-PDF dither (a good general-purpose
    dither) with optional 2nd-order noise shaping (which lowers the noise floor by 11dB below
    0.1 Fs).
    The code assumes input data is in the range +1 to -1 and doesn't check for overloads!
    
    To save time when generating dither for multiple channels you can re-use lower bits of a
    previous random number instead of calling rand() again. e.g. r3=(r1 & 0x7F)<<8;


.. code-block:: c++
    :linenos:
    :caption: code

      int   r1, r2;                //rectangular-PDF random numbers
      float s1, s2;                //error feedback buffers
      float s = 0.5f;              //set to 0.0f for no noise shaping
      float w = pow(2.0,bits-1);   //word length (usually bits=16)
      float wi= 1.0f/w;
      float d = wi / RAND_MAX;     //dither amplitude (2 lsb)
      float o = wi * 0.5f;         //remove dc offset
      float in, tmp;
      int   out;
    
    //for each sample...
    
      r2=r1;                               //can make HP-TRI dither by
      r1=rand();                           //subtracting previous rand()
    
      in += s * (s1 + s1 - s2);            //error feedback
      tmp = in + o + d * (float)(r1 - r2); //dc offset and dither
    
      out = (int)(w * tmp);                //truncate downwards
      if(tmp<0.0f) out--;                  //this is faster than floor()
    
      s2 = s1;
      s1 = in - wi * (float)out;           //error

