Noise Shaping Class
===================

- **Author or source:** ude.anaidni@iehsc
- **Type:** Dithering with 9th order noise shaping
- **Created:** 2002-04-23 06:49:06

- **Linked files:** :download:`NS9dither16.h <../files/NS9dither16.h>`.

.. code-block:: text
    :caption: notes

    This is an implemetation of a 9th order noise shaping & dithering class, that runs quite
    fast (it has one function that uses Intel x86 assembly, but you can replace it with a
    different rounding function if you are running on a non-Intel platform).  _aligned_malloc
    and _aligned_free require the MSVC++ Processor Pack, available from www.microsoft.com.
    You can replace them with "new" and "delete," but allocating aligned memory seems to make
    it run faster.  Also, you can replace ZeroMemory with a memset that sets the memory to 0
    if you aren't using Win32.
    Input should be floats from -32768 to 32767 (processS will clip at these points for you,
    but clipping is bad when you are trying to convert floats to shorts).  Note to reviewer -
    it would probably be better if you put the code in a file such as NSDither.h and have a
    link to it - it's rather long.
    
    (see linked file)



Comments
--------

- **Date**: 2003-05-14 14:01:22
- **By**: mail[ns]@mutagene.net

.. code-block:: text

    I haven't tried this class out, but it looks like there's a typo in the unrolled loop -- shouldn't it read "c[2]*EH[HistPos+2]"?  This might this also account for the 3 clock cycle improvement on a P-III.
    
    // This arrangement seems to execute 3 clock cycles faster on a P-III
    samp -= c[8]*EH[HistPos+8] + c[7]*EH[HistPos+7] + c[6]*EH[HistPos+6] +
    c[5]*EH[HistPos+5] + c[4]*EH[HistPos+4] + c[3]*EH[HistPos+3] + c[2]*EH[HistPos+1] +
    c[1]*EH[HistPos+1] + c[0]*EH[HistPos];             
    
     

- **Date**: 2005-02-15 15:18:55
- **By**: moc.tnemarkas@vokiahc

.. code-block:: text

    Great class! But I found one more mistake: function my_mod(9, 9) gives 9 instead of 0 (9 % 9 = 0). 
    
    HistPos = my_mod((HistPos+8), order);
    EH[HistPos+9] = EH[HistPos] = output - samp;
    
     -> HistPos + 9 = 18 (max EH index is 17) which leads to out of array boundary and crash.
    
    So my_mod should look like:
    
    __inline my_mod(int x, int n)
    {
        if(x >= n) x-=n;
        return x;
    }
    
    

