Envelope Detector class (C++)
=============================

- **Author or source:** Citizen Chunk
- **Type:** envelope detector
- **Created:** 2005-05-28 19:12:28

- **Linked files:** :download:`http://www.chunkware.com/opensource/EnvelopeDetector.zip <../files/http://www.chunkware.com/opensource/EnvelopeDetector.zip>`.

.. code-block:: text
    :caption: notes

    This is a C++ implementation of a simple envelope detector. The time constant (ms)
    represents the time it takes for the envelope to charge/discharge 63% (RC time constant).
    
    (see linked files)



Comments
--------

- **Date**: 2005-06-04 10:52:51
- **By**: moc.erawknuhc@knuhcnezitic

.. code-block:: text

    due to popular demand, i have added an AttRelEnvelope class to this source, implementing a typical attack/release envelope.
    
    for my own taste, i prefer to keep the state variable separate from the envelope detector. however, if you prefer to have it as a member variable, you can easily inherit these classes and add them. (but please remember to add a function for initializing the state before runtime.)

- **Date**: 2006-05-08 16:41:27
- **By**: moc.erawknuhc@knuhcnezitic

.. code-block:: text

    link moved:
    
    http://www.chunkware.com/downloads/simpleSource.zip
    

- **Date**: 2011-01-15 13:17:42
- **By**: moc.oohay@ddedrawrof

.. code-block:: text

    hi, all, 
    
    could someone add new link, because the old one is not working any more.. or I'm stupid and can not open t properly.. 
    
    Thanks a lot.

- **Date**: 2012-05-02 20:43:15
- **By**: ten.tluassaaidem@rednammoc

.. code-block:: text

    chunkware.com is dead
    
    Could someone who downloaded this back when chunkware.com was still a live site please upload it? 
    
    Thank you.

- **Date**: 2013-06-15 00:32:21
- **By**: moc.liamg@eduddloytsurc

.. code-block:: text

    This web archive might help              http://web.archive.org/web/20060819044036/http://www.chunkware.com/?page_id=5

- **Date**: 2013-06-15 00:37:06
- **By**: moc.liamg@eduddloytsurc

.. code-block:: text

    You may want to use something a bit more precise. This Matlab explanation is very good and they also remove group delay introduced by LP filtering.
    http://www.mathworks.com.au/help/dsp/examples/envelope-detection.html

