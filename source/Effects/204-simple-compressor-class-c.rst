Simple Compressor class (C++)
=============================

- **Author or source:** Citizen Chunk
- **Type:** stereo, feed-forward, peak compressor
- **Created:** 2005-05-28 19:11:42

- **Linked files:** :download:`simpleSource.zip <../files/simpleSource.zip>`.

.. code-block:: text
    :caption: notes

    Everyone seems to want to make their own compressor plugin these days, but very few know
    where to start. After replying to so many questions on the KVR Dev Forum, I figured I
    might as well just post some ready-to-use C++ source code.
    
    This is a C++ implementation of a simple, stereo, peak compressor. It uses a feed-forward
    topology, detecting the sidechain level pre-gain reduction. The sidechain detects the
    rectified peak level, with stereo linking to preserve imaging. The attack/release uses the
    EnvelopeDetector class (posted in the Analysis section).
    
    Notes:
    - Make sure to call initRuntime() before processing starts (i.e. call it in resume()).
    - The process function takes a stereo input.
    - VST params must be mapped to a practical range when setting compressor parameters. (i.e.
    don't try setAttack( 0.f ).)
    
    (see linked files)



Comments
--------

- **Date**: 2005-11-26 01:56:48
- **By**: moc.liamtoh@361_lt

.. code-block:: text

    This code works perfectly, and I have tried a number of sound and each worked correctly. The
    conversion is linear in logarithm domain.
    
    The code has been written in such a professional style, can not believe it is FREE!!
    
    Keep it up. Two super huge thumbs up.
    
    Ting