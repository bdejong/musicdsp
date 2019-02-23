Fast in-place Walsh-Hadamard Transform
======================================

- **Author or source:** Timo H Tossavainen
- **Type:** wavelet transform
- **Created:** 2002-01-17 01:54:52


.. code-block:: text
    :caption: notes

    IIRC, They're also called walsh-hadamard transforms.
    Basically like Fourier, but the basis functions are squarewaves with different sequencies.
    I did this for a transform data compression study a while back.
    Here's some code to do a walsh hadamard transform on long ints in-place (you need to
    divide by n to get transform) the order is bit-reversed at output, IIRC.
    The inverse transform is the same as the forward transform (expects bit-reversed input).
    i.e. x = 1/n * FWHT(FWHT(x)) (x is a vector)


.. code-block:: c++
    :linenos:
    :caption: code

    void inline wht_bfly (long& a, long& b)
    {
            long tmp = a;
            a += b;
            b = tmp - b;
    }
    
    // just a integer log2
    int inline l2 (long x)
    {
            int l2;
            for (l2 = 0; x > 0; x >>=1)
            {
                    ++ l2;
            }
    
            return (l2);
    }
    
    ////////////////////////////////////////////
    // Fast in-place Walsh-Hadamard Transform //
    ////////////////////////////////////////////
    
    void FWHT (std::vector& data)
    {
      const int log2 = l2 (data.size()) - 1;
      for (int i = 0; i < log2; ++i)
      {
        for (int j = 0; j < (1 << log2); j += 1 << (i+1))
        {
           for (int k = 0; k < (1<<i); ++k)
           {
               wht_bfly (data [j + k], data [j + k + (1<<i)]);
           }
        }
      }
    }

