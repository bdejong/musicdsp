Denormal DOUBLE variables, macro
================================

- **Author or source:** Jon Watte
- **Created:** 2002-03-17 15:44:31


.. code-block:: text
    :caption: notes

    Use this macro if you want to find denormal numbers and you're using doubles...


.. code-block:: c++
    :linenos:
    :caption: code

    #if PLATFORM_IS_BIG_ENDIAN
    #define INDEX 0
    #else
    #define INDEX 1
    #endif
    inline bool is_denormal( double const & d ) {
      assert( sizeof( d ) == 2*sizeof( int ) );
      int l = ((int *)&d)[INDEX];
      return (l&0x7fe00000) != 0;
    }

Comments
--------

- **Date**: 2005-05-14 17:19:48
- **By**: dont-email-me

.. code-block:: text

    put the #if inside the function itself

