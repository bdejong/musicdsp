Cubic interpollation
====================

- **Author or source:** Olli Niemitalo
- **Type:** interpollation
- **Created:** 2002-01-17 03:05:33

- **Linked files:** :download:`other001.gif <../files/other001.gif>`.

.. code-block:: text
    :caption: notes

    (see linkfile)
    finpos is the fractional, inpos the integer part.
    


.. code-block:: c++
    :linenos:
    :caption: code

    xm1 = x [inpos - 1];
    x0  = x [inpos + 0];
    x1  = x [inpos + 1];
    x2  = x [inpos + 2];
    a = (3 * (x0-x1) - xm1 + x2) / 2;
    b = 2*x1 + xm1 - (5*x0 + x2) / 2;
    c = (x1 - xm1) / 2;
    y [outpos] = (((a * finpos) + b) * finpos + c) * finpos + x0;

