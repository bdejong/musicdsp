Float to int
============

- **Author or source:** Ross Bencina
- **Created:** 2002-01-17 03:15:14


.. code-block:: text
    :caption: notes

    intel only


.. code-block:: c++
    :linenos:
    :caption: code

    int truncate(float flt)
    {
      int i;
      static const double half = 0.5f;
      _asm
      {
         fld flt
         fsub half
         fistp i
      }
      return i
    }

Comments
--------

- **Date**: 2002-06-11 20:12:11
- **By**: moc.xinortceletrams@ahaj

.. code-block:: text

    Note: Round nearest doesn't work, because the Intel FPU uses Even-Odd rounding in order to conform to the IEEE floating-point standard: when the FPU is set to use the round-nearest rule, values whose fractional part is exactly 0.5
    round toward the nearest *even* integer.  Thus, 1.5 rounds to 2, 2.5 rounds to 2, 3.5 rounds to 4. This is quite disastrous for the FLOOR/CEIL
    functions if you use the strategy you describe.
    

- **Date**: 2003-05-28 21:25:24
- **By**: moc.oohay@tuanogus

.. code-block:: text

    This version below seems to be more accurate on my Win32/P4.  Doesn't deal with the Intel FPU issue.  A faster solution than c-style casts though.  But you're not always going to get the most accurate conversion.  Like the previous comment; 2.5 will convert to 2, but 2.501 will convert to 3.
    
    int truncate(float flt)
    {
        int i;
        _asm
        {
            fld flt
            fistp i
        }
        return i
    }              

- **Date**: 2004-04-07 01:20:49
- **By**: moc.erehwon@amsuk

.. code-block:: text

    if you use msvc, just use the /QIfist compile-switch

