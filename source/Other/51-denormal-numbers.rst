Denormal numbers
================

- **Author or source:** Compiled by Merlijn Blaauw
- **Created:** 2002-01-17 03:06:39

- **Linked files:** :download:`other001.txt <../files/other001.txt>`.

.. code-block:: text
    :caption: notes

     this text describes some ways to avoid denormalisation. Denormalisation happens when
    FPU's go mad processing very small numbers



Comments
--------

- **Date**: 2004-01-31 05:20:38
- **By**: moc.dh2a@ydna

.. code-block:: text

    See also the entry about 'branchless min, max and clip' by Laurent Soras in this section,
    
    Using the following function,
                 
    float clip (float x, float a, float b)
    {
       x1 = fabs (x-a);
       x2 = fabs (x-b);
       x = x1 + (a+b);
       x -= x2;
       x *= 0.5;
       return (x);
    }
    
    If you apply clipping from -1.0 to 1.0 will have a side effect of squashing denormal numbers to zero due to loss of precision on the order of ~1.0.e-20.  The upside is that it is branchless, but possibly more expensive than adding noise and certainly more so than adding a DC offset.
    

