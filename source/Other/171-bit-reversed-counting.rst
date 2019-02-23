Bit-Reversed Counting
=====================

- **Author or source:** moc.oohay@ljbliam
- **Created:** 2004-06-19 10:10:39


.. code-block:: text
    :caption: notes

    Bit-reversed ordering comes up frequently in FFT implementations.  Here is a non-branching
    algorithm (given in C) that increments the variable "s" bit-reversedly from 0 to N-1,
    where N is a power of 2.


.. code-block:: c++
    :linenos:
    :caption: code

    int r = 0;        // counter
    int s = 0;        // bit-reversal of r/2
    int N = 256;      // N can be any power of 2
    int N2 = N << 1;  // N<<1 == N*2
    
    do {
      printf("%u ", s);
      r += 2;
      s ^= N - (N / (r&-r));
    }
    while (r < N2);
    

Comments
--------

- **Date**: 2005-08-10 07:20:50
- **By**: moc.oohay@r_adihaw

.. code-block:: text

       This will give the bit reversal of N number of elements(where N is a power of 2). If we want reversal of a particular number out of N,is there any optimised way other than doing bit wise operations           

- **Date**: 2006-03-30 23:17:55
- **By**: moc.oohay@ljbliam

.. code-block:: text

    There's a better way that doesn't require counting, branching, or division.  It's probably the fastest way of doing bit reversal without a special instruction.  I got this from Jörg's FXT book:
    
    unsigned r; // value to be bit-reversed
    
    // Assume r is 32 bits
    r = ((r & 0x55555555) << 1) | ((r & 0xaaaaaaaa) >> 1);
    r = ((r & 0x33333333) << 2) | ((r & 0xcccccccc) >> 2);
    r = ((r & 0x0f0f0f0f) << 4) | ((r & 0xf0f0f0f0) >> 4);
    r = ((r & 0x00ff00ff) << 8) | ((r & 0xff00ff00) >> 8);
    r = ((r & 0x0000ffff) << 16) | ((r & 0xffff0000) >> 16);

- **Date**: 2010-09-20 15:22:09
- **By**: ed.bew@mfyknarf

.. code-block:: text

    The way mentioned in the comment might be faster but is fixed to 32 bits. If you do a FFT with 1024 points you need 10 bits bit-reversal. Thus the originally mentioned algorithm is more flexible because it works for any bit width. If you use it for FFT (that's actually the only case you normally use bit-reversal) you either need to calculate the bit-reversal for each array index, so counting upwards in bit-reversal order is not such a bad way. I'm not sure whether the second algorithm is really faster than the counter if you consider the whole array. (There are 5 instructions per line making 25 instructions in sum for each calculated index with the second algorithm compared to 7 instructions in the counting algorithm)     

