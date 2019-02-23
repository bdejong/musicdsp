Simple Compressor class (C++)
=============================

- **Author or source:** Citizen Chunk
- **Type:** stereo, feed-forward, peak compressor
- **Created:** 2005-05-28 19:11:42

- **Linked files:** :download:`http://www.chunkware.com/opensource/SimpleComp.zip <../files/http://www.chunkware.com/opensource/SimpleComp.zip>`.

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

    This code works perfectly, and I have tried a number of sound and each worked correctly. The conversion is linear in logarithm domain.
    
    The code has been written in such a professional style, can not believe it is FREE!!
    
    Keep it up. Two super huge thumbs up.
    
    Ting
    

- **Date**: 2005-12-09 08:45:30
- **By**: moc.liamg@tuhpzzucs

.. code-block:: text

    source file seems to be down :-(
    anyone have a local copy ???              

- **Date**: 2006-02-07 21:27:22
- **By**: moc.erawknuhc@knuhcnezitic

.. code-block:: text

    there are some updates: mainly, there is now a SimpleGate class, which implements a simple gate. other than that, minor changes to the code -- but all public functions should work the same.
    
    *** NEW FILE NAME: http://www.chunkware.com/opensource/SimpleCompGate.zip

- **Date**: 2006-02-28 08:14:43
- **By**: moc.oohay@10021002gnijnij

.. code-block:: text

    hello everybady!
    I am a Chinese student, I want to download the code from http://www.chunkware.com/opensource/SimpleCompGate.zip  but because  the server can not do his job well,I have no chance to download the code.I really hope kind people who have been have the code can tansfer a copy to me!I will be appreciated very much.
    my emial is listed as following:
     jinjing20012001@yahoo.com
    I am looking for your reply as soon as possible.
        

- **Date**: 2006-05-08 16:40:24
- **By**: moc.erawknuhc@knuhcnezitic

.. code-block:: text

    sorry about the link. the new source is at
    http://www.chunkware.com/downloads/simpleSource.zip
    

- **Date**: 2008-03-12 06:35:38
- **By**: moc.ocsevneb@neb

.. code-block:: text

    MIRROR: http://www.benvesco.com/dump/simpleSource.zip
    
    This code has been missing for some time at the posted locations. I found someone with a copy and am now mirroring these files for download on my server. I believe the software license allows this mirroring. The code is unchanged and belongs to the original owner.

- **Date**: 2011-08-15 21:57:40
- **By**: moc.oohay@cibuh_dej

.. code-block:: text

    Thank you Ben! This help me wrap my head around DSP a bit more. It's a shame this site is essentially dead...              

- **Date**: 2012-04-15 21:53:15
- **By**: moc.liamg@wejweht

.. code-block:: text

                is this code still available?   

- **Date**: 2012-04-23 20:47:29
- **By**: moc.liamg@negarhcs.naitsirhc

.. code-block:: text

    I'm new in programming. how do I embed this code to my project? vst sdk is already loaded from the steinberg developer site. can somebody give me a step by step guide? 

- **Date**: 2013-05-24 08:09:12
- **By**: moc.kcollubeimaj@eimaj

.. code-block:: text

     It loos like the Chunkware code can now be found on GitHub: https://github.com/music-dsp-collection/chunkware-simple-dynamics/tree/master/simpleSource

- **Date**: 2014-01-29 14:44:18
- **By**: moc.osurazzagekim@ekim

.. code-block:: text

                  Hi, may i know the range of values to set in SimpleComp? Expecially those for Threshold and Ratio. I set them to 2 and -30 but my sound get incredibly distorted after that. Thanks.

