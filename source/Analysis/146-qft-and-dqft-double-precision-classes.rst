QFT and DQFT (double precision) classes
=======================================

- **Author or source:** Joshua Scholar
- **Created:** 2003-05-17 16:17:35

- **Linked files:** :download:`qft.tar_1.gz <../files/qft.tar_1.gz>`.

.. code-block:: text
    :caption: notes

    Since it's a Visual C++ project (though it has relatively portable C++) I
    guess the main audience are PC users.  As such I'm including a zip file.
    Some PC users wouldn't know what to do with a tgz file.
    
    The QFT and DQFT (double precision) classes supply the following functions:
    
      1. Real valued FFT and inverse FFT functions.  Note that separate arraysare used
         for real and imaginary component of the resulting spectrum.
    
      2. Decomposition of a spectrum into a separate spectrum of the evensamples
         and a spectrum of the odd samples.  This can be useful for buildingfilter banks.
    
      3. Reconstituting a spectrum from separate spectrums of the even samples
         and odd samples.  This can be useful for building filter banks.
    
      4. A discrete Sin transform (a QFT decomposes an FFT into a DST and DCT).
    
      5. A discrete Cos transfrom.
    
      6. Since a QFT does it's last stage calculating from the outside in thelast part
         can be left unpacked and only calculated as needed in the case wherethe entire
      spectrum isn't needed (I used this for calculating correlations andconvolutions
      where I only needed half of the results).
      ReverseNoUnpack()
      UnpackStep()
      and NegUnpackStep()
      implement this functionality
    
      NOTE Reverse() normalizes its results (divides by one half the blocklength), but
      ReverseNoUnpack() does not.
    
      7. Also if you only want the first half of the results you can call ReverseHalf()
    
      NOTE Reverse() normalizes its results (divides by one half the blocklength), but
      ReverseHalf() does not.
    
      8. QFT is less numerically stable than regular FFTs.  With singleprecision calculations,
         a block length of 2^15 brings the accuracy down to being barelyaccurate enough.
      At that size, single precision calculations tested sound files wouldoccasionally have
      a sample off by 2, and a couple off by 1 per block. Full volume whitenoise would
    generate
      a few samples off by as much as 6 per block at the end, beginning and middle.
    
      No matter what the inputs the errors are always at the same positions in the block.
      There some sort of cancelation that gets more delicate as the block size gets bigger.
    
      For the sake of doing convolutions and the like where the forward transform is
      done only once for one of the inputs, I created a AccurateForward() function.
      It uses a regular FFT algorithm for blocks larger than 2^12, and decomposes into even
    and
      odd FFTs recursively.
    
      In any case you can always use the double precision routines to get more accuracy.
      DQFT even has routines that take floats as inputs and return double precision
      spectrum outputs.
    
    As for portability:
    
    1. The files qft.cpp and dqft.cpp start with defines:
    #define _USE_ASM
    
    If you comment those define out, then what's left is C++ with no assembly language.
    
    2. There is unnecessary windows specific code in "criticalSection.h"
    I used a critical section because objects are not reentrant (each object has
    permanent scratch pad memory), but obviously critical sections are operating
    system specific.  In any case that code can easily be taken out.
    
    
    If you look at my code and see that there's an a test built in the examples
    that makes sure that the results are in the ballpark of being right. It
    wasn't that I expected the answers to be far off, it was that I uncommenting
    the "no assembly language" versions of some routines and I wanted to make
    sure that they weren't broken.



