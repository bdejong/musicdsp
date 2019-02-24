Bit quantization/reduction effect
=================================

- **Author or source:** Jon Watte
- **Type:** Bit-level noise-generating effect
- **Created:** 2002-04-12 13:53:03


.. code-block:: text
    :caption: notes

    This function, run on each sample, will emulate half the effect of running your signal
    through a Speak-N-Spell or similar low-bit-depth circuitry.
    
    The other half would come from downsampling with no aliasing control, i e replicating
    every N-th sample N times in the output signal.


.. code-block:: c++
    :linenos:
    :caption: code

    short keep_bits_from_16( short input, int keepBits ) {
      return (input & (-1 << (16-keepBits)));
    }
    
    

Comments
--------

- **Date**: 2005-05-30 23:01:56
- **By**: moc.liamg@codlli

.. code-block:: c++

    //I add some code to prevent offset. 
    
    // Code :
    short keep_bits_from_16( short input, int keepBits ) {
        short prevent_offset = static_cast<unsigned short>(-1) >> keepBits+1;
        input &= (-1 << (16-keepBits)));
        return input + prevent_offset
    }