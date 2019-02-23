Most simple and smooth feedback delay
=====================================

- **Author or source:** moc.liamtoh@sisehtnysorpitna
- **Type:** Feedback delay
- **Created:** 2003-09-03 12:58:52


.. code-block:: text
    :caption: notes

    fDlyTime = delay time parameter (0-1)
    
    i = input index
    j = delay index


.. code-block:: c++
    :linenos:
    :caption: code

    if( i >= SampleRate )
        i = 0;
    
    j = i - (fDlyTime * SampleRate);
    
    if( j < 0 )
        j += SampleRate;
    
    Output = DlyBuffer[ i++ ] = Input + (DlyBuffer[ j ] * fFeedback);

Comments
--------

- **Date**: 2003-09-03 13:25:47
- **By**: moc.liamtoh@sisehtnysorpitna

.. code-block:: text

    This algo didn't seem to work on testing again, just change:
    -------------------------------------------------------------------
    Output = DlyBuffer[ i++ ] = Input + (DlyBuffer[ j ] * fFeedback);
    -------------------------------------------------------------------
    to
    ---------------------------------------------------------------
    Output = DlyBuffer[ i ] = Input + (DlyBuffer[ j ] * fFeedback);
    
    i++;
    ---------------------------------------------------------------
    and it will work fine.

- **Date**: 2003-09-08 12:07:22
- **By**: moc.liamtoh@sisehtnysorpitna

.. code-block:: text

    Here's a more clear source. both BufferSize and MaxDlyTime are amounts of samples. BufferSize should best be 2*MaxDlyTime to have proper sound.
    -
    if( i >= BufferSize )
        i = 0;
    
    j = i - (fDlyTime * MaxDlyTime);
    
    if( j < 0 )
        j += BufferSize;
    
    Output = DlyBuffer[ i ] = Input + (DlyBuffer[ j ] * fFeedback);
    
    i++;

- **Date**: 2006-11-06 12:50:13
- **By**: moc.oohay@firahanilama

.. code-block:: text

    hi,can anyone help me with the c code for flanging effect using C6711 DSK board?? 

- **Date**: 2016-07-01 09:29:55
- **By**: moc.trahcsas@tcatnoc

.. code-block:: text

    None of these codes did not smooth the delay's when rate change. All crackling when rate delay change.

