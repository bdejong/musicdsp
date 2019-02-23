Sin, Cos, Tan approximation
===========================

- **Author or source:** http://www.wild-magic.com
- **Created:** 2003-04-26 00:17:56

- **Linked files:** :download:`approx.h <../files/approx.h>`.

.. code-block:: text
    :caption: notes

    Code for approximation of cos, sin, tan and inv sin, etc.
    Surprisingly accurate and very usable.
    
    [edit by bram]
    this code is taken literaly from
    http://www.wild-magic.com/SourceCode.html
    Go have a look at the MgcMath.h and MgcMath.cpp files in their library...
    [/edit]
    



Comments
--------

- **Date**: 2002-09-01 00:06:40
- **By**: moc.oi@htnysa

.. code-block:: text

    It'd be nice to have a note on the domain of these functions. I assume Sin0 is meant to be used about zero and Sin1 about 1. But a note to that effect would be good.
    Thanks,
    
    james mccartney
    

- **Date**: 2003-05-31 18:39:50
- **By**: ten.xmg@mapsedocm

.. code-block:: text

    Sin0 is faster but less accurate than Sin1, same for the other pairs. The domains are:
    
    Sin/Cos [0, pi/2]
    Tan [0,pi/4]
    InvSin/Cos [0, 1]
    InvTan [-1, 1]
    
    This comes from the original header file.

