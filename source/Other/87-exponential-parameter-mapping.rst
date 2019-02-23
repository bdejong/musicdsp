Exponential parameter mapping
=============================

- **Author or source:** Russell Borogove
- **Created:** 2002-03-17 15:42:33


.. code-block:: text
    :caption: notes

    Use this if you want to do an exponential map of a parameter (mParam) to a range (mMin -
    mMax).
    Output is in mData...


.. code-block:: c++
    :linenos:
    :caption: code

    float logmax = log10f( mMax );
    float logmin = log10f( mMin );
    float logdata = (mParam * (logmax-logmin)) + logmin;
    
    mData = powf( 10.0f, logdata );
    if (mData < mMin)
    {
      mData = mMin;
    }
    if (mData > mMax)
    {
      mData = mMax;
    }

Comments
--------

- **Date**: 2002-03-26 00:28:53
- **By**: moc.nsm@seivadrer

.. code-block:: text

    No point in using heavy functions when lighter-weight functions work just as well. Use ln instead of log10f, and exp instead of pow(10,x). Log-linear is the same, no matter which base you're using, and base e is way more efficient than base 10.

- **Date**: 2002-12-06 01:31:55
- **By**: moc.noicratse@ajelak

.. code-block:: text

    Thanks for the tip. A set of VST param wrapper classes which offers linear float, exponential float, integer selection, and text selection controls, using this technique for the exponential response, can be found in the VST source code archive -- finally. 

- **Date**: 2003-08-21 16:01:01
- **By**: moc.oohay@noi_tca

.. code-block:: text

    Just made my day!
    pretty useful :) cheers Aktion

- **Date**: 2006-09-08 18:27:33
- **By**: agillesp@gmail

.. code-block:: text

    You can trade an (expensive) ln for a (cheaper) divide here because of the logarithmic identity:
    
    ln(x) - ln(y) == ln(x/y)
        

