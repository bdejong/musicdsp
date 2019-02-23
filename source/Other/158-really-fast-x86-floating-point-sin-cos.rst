Really fast x86 floating point sin/cos
======================================

- **Author or source:** moc.nsm@seivadrer
- **Created:** 2003-11-25 17:43:28

- **Linked files:** :download:`sincos.zip <../files/sincos.zip>`.

.. code-block:: text
    :caption: notes

    Frightful code from the Intel Performance optimization front. Not for the squeamish.
    
    The following code calculates sin and cos of a floating point value on x86 platforms to 20
    bits precision with 2 multiplies and two adds. The basic principle is to use sin(x+y) and
    cos(x+y) identities to generate the result from lookup tables. Each lookup table takes
    care of 10 bits of precision in the input. The same principle can be used to generate
    sin/cos to full (! Really. Full!) 24-bit float precision using two 8-bit tables, and one
    10 bit table (to provide guard bits), for a net speed gain of about 4x over fsin/fcos, and
    8x if you want both sin and cos. Note that microsoft compilers have trouble keeping
    doubles aligned properly  on the stack (they must be 8-byte aligned in order not to incur
    a massive alignment penalty). As a result, this class should NOT be allocated on the
    stack. Add it as a member variable to any class that uses it.
    
    e.g.
      class CSomeClass {
          CQuickTrig m_QuickTrig;
       ...
           mQuickTrig.QuickSinCos(dAngle,fSin,fCos);
       ...
       }
    


.. code-block:: c++
    :linenos:
    :caption: code

    (see attached file)

