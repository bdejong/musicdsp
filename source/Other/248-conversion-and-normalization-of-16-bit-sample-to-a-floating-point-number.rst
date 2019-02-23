Conversion and normalization of 16-bit sample to a floating point number
========================================================================

- **Author or source:** George Yohng
- **Created:** 2007-05-02 13:34:21



.. code-block:: c++
    :linenos:
    :caption: code

    float out;
    signed short in;
    
    // This code does the same as
    //   out = ((float)in)*(1.0f/32768.0f);
    // 
    // Depending on the architecture and conversion settings,
    // it might be more optimal, though it is always
    // advisable to check its speed against genuine 
    // algorithms.
    
    ((unsigned &)out)=0x43818000^in;
    out-=259.0f;

Comments
--------

- **Date**: 2007-05-15 06:09:54
- **By**: moc.mot@lx_iruy

.. code-block:: text

    Hi George Yohng
    
    I tried it... but it's create the heavy noise!!
              

- **Date**: 2007-09-20 17:51:12
- **By**: George Yohng

.. code-block:: text

    Correction:
        ((unsigned &)out)=0x43818000^((unsigned short)in);
        out-=259.0f;
    
    (needs to have a cast to 'unsigned short')

