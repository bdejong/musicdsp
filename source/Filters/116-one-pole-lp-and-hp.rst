One pole LP and HP
==================

- **Author or source:** Bram
- **Created:** 2002-08-26 23:33:27



.. code-block:: c++
    :linenos:
    :caption: code

    LP:
    recursion: tmp = (1-p)*in + p*tmp with output = tmp
    coefficient: p = (2-cos(x)) - sqrt((2-cos(x))^2 - 1) with x = 2*pi*cutoff/samplerate
    coeficient approximation: p = (1 - 2*cutoff/samplerate)^2
    
    HP:
    recursion: tmp = (p-1)*in - p*tmp with output = tmp
    coefficient: p = (2+cos(x)) - sqrt((2+cos(x))^2 - 1) with x = 2*pi*cutoff/samplerate
    coeficient approximation: p = (2*cutoff/samplerate)^2

Comments
--------

- **Date**: 2006-03-23 15:39:07
- **By**: moc.liamtoh@wta_sohpyks

.. code-block:: text

    coefficient: p = (2-cos(x)) - sqrt((2-cos(x))^2 - 1) with x = 2*pi*cutoff/samplerate
    
    p is always -1 using the formula above. The square eliminates the squareroot and (2-cos(x)) - (2-cos(x)) is 0.

- **Date**: 2006-03-24 09:37:19
- **By**: q@q

.. code-block:: text

    Look again. The -1 is inside the sqrt.

- **Date**: 2008-08-11 09:34:07
- **By**: batlord[.A.T.]o2[.D.O.T.]pl

.. code-block:: text

    skyphos:
    sqrt((2-cos(x))^2 - 1) doesn't equal
    sqrt((2-cos(x))^2) + sqrt(- 1)
    
    so
    
    -1 can be inside the sqrt, because (2-cos(x))^2 will be always >= one.
    

- **Date**: 2009-07-13 01:22:43
- **By**: No

.. code-block:: text

    HP is wrong!
    Or at least it does not work here. It acts like a lofi low-shelf. However this works:
    
    HP:
    recursion: tmp = (1-p)*in + p*tmp with output = in-tmp
    coefficient: p = (2-cos(x)) - sqrt((2-cos(x))^2 - 1) with x = 2*pi*cutoff/samplerate
    coeficient approximation: p = (1 - 2*cutoff/samplerate)^2
    
    

