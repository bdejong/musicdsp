16-to-8-bit first-order dither
==============================

- **Author or source:** Jon Watte
- **Type:** First order error feedforward dithering code
- **Created:** 2002-04-12 13:52:36


.. code-block:: text
    :caption: notes

    This is about as simple a dithering algorithm as you can implement, but it's likely to
    sound better than just truncating to N bits.
    
    Note that you might not want to carry forward the full difference for infinity. It's
    probably likely that the worst performance hit comes from the saturation conditionals,
    which can be avoided with appropriate instructions on many DSPs and integer SIMD type
    instructions, or CMOV.
    
    Last, if sound quality is paramount (such as when going from > 16 bits to 16 bits) you
    probably want to use a higher-order dither function found elsewhere on this site.
    


.. code-block:: c++
    :linenos:
    :caption: code

    // This code will down-convert and dither a 16-bit signed short 
    // mono signal into an 8-bit unsigned char signal, using a first 
    // order forward-feeding error term dither.
    
    #define uchar unsigned char
    
    void dither_one_channel_16_to_8( short * input, uchar * output, int count, int * memory )
    {
      int m = *memory;
      while( count-- > 0 ) {
        int i = *input++;
        i += m;
        int j = i + 32768 - 128;
        uchar o;
        if( j < 0 ) {
          o = 0;
        }
        else if( j > 65535 ) {
          o = 255;
        }
        else {
          o = (uchar)((j>>8)&0xff);
        }
        m = ((j-32768+128)-i);
        *output++ = o;
      }
      *memory = m;
    }
    

