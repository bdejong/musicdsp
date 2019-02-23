DIRAC - Free C/C++ Library for Time and Pitch Manipulation of Audio Based on Time-Frequency Transforms
======================================================================================================

- **Author or source:** Stephan M. Bernsee
- **Type:** Time Stretch / Pitch Shift
- **Created:** 2005-05-24 07:42:44


.. code-block:: text
    :caption: notes

    This is an availability notification for a free object library, no source code.


.. code-block:: c++
    :linenos:
    :caption: code

    Past research has shown time domain [pitch] synchronized overlap-add ([P]SOLA) algorithms for independent time and pitch manipulation of audio ("time stretching" and "pitch shifting") to be the method of choice for single-pitched sounds such as voice and musically monophonic instrument recordings due to the prominent periodicity at the fundamental period. On the other hand, frequency domain methods have recently evolved around the concept of the phase vocoder that have proven to be vastly superior for multi-pitched sounds and entire musical pieces.
    
    "Dirac" is a free cross-platform C/C++ object library that exploits the good localization of time-frequency transforms in both domains to build an algorithm for time and pitch manipulation that uses an arbitrary time-frequency tiling depending on the underlying signal. Additionally, the time and frequency localization parameter of the basis can be user-defined, making the algorithm smoothly scalable to provide either the phase coherence properties of a time domain process or the good frequency resolution of the phase vocoder.
    
    The basic "Dirac" library comes as a free download off the DSPdimension web site and is currently available for Microsoft Visual C6+, CodeWarrior 8.x on Windows and MacOS, and for Xcode 2.x on MacOS X. Optional "Studio" and "Pro" versions with increased feature set are available commercially from the author.
    
    
    More information and download at http://www.dspdimension.com

Comments
--------

- **Date**: 2005-05-24 07:26:29
- **By**: hc.onitsop@emohat

.. code-block:: text

    The quality of this is just amazing!!! I'm using Stefan's TimeFactory on a daily basis but this is even better imho. I hope it will be upgraded to use dirac soon!

- **Date**: 2005-07-02 21:32:25
- **By**: moc.ec@ec

.. code-block:: text

    Awesome, but I need a Windows CE-library using integer math. 

- **Date**: 2005-09-18 06:35:17
- **By**: moc.d3otni@ofni

.. code-block:: text

                  Anyone has a VST framework for this?

- **Date**: 2006-01-05 23:15:24
- **By**: moc.serac@ohw

.. code-block:: text

     I hate false publicity... There's no free code. 

- **Date**: 2008-11-25 08:01:52
- **By**: hc.onitsop@emohat

.. code-block:: text

    Why not?

- **Date**: 2009-08-29 01:15:12
- **By**: moc..pu@hs

.. code-block:: text

    This site is called music dsp SOURCE CODE archive. 

- **Date**: 2009-11-11 21:09:04
- **By**: moc.liamg@hawzit

.. code-block:: text

    ...there is source code included, see http://www.dspdimension.com/download/

