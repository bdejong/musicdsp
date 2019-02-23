Waveform generator using MinBLEPS
=================================

- **Author or source:** ku.oc.nomed.nafgpr@ekcol
- **Created:** 2002-08-05 18:44:50

- **Linked files:** :download:`MinBLEPS.zip <../files/MinBLEPS.zip>`.

.. code-block:: text
    :caption: notes

    C code and project file for MSVC6 for a bandwidth-limited saw/square (with PWM) generator
    using MinBLEPS.
    
    This code is based on Eli's MATLAB MinBLEP code and uses his original minblep.mat file.
    Instead of keeping a list of all active MinBLEPS, the output of each MinBLEP is stored in
    a buffer, in which all consequent MinBLEPS and the waveform output are added together.
    This optimization makes it fast enough to be used realtime.
    
    Produces slight aliasing when sweeping high frequencies. I don't know wether Eli's
    original code does the same, because I don't have MATLAB. Any help would be appreciated.
    
    The project name is 'hardsync', because it's easy to generate hardsync using MinBLEPS.


.. code-block:: c++
    :linenos:
    :caption: code

    
    
    

Comments
--------

- **Date**: 2004-07-02 22:31:36
- **By**: moc.oiduaesionetihw@ofni

.. code-block:: text

    http://www.slack.net/~ant/bl-synth/windowed-impulse/ 
    
    This page also describes a similar algorithm for generating waves. Could the aliasing be due to the fact that the blep only occurs after the discontinuity? On this page the blep also occurs in the opposite direction as well, leading up to the discontinuity.

- **Date**: 2008-02-11 18:42:15
- **By**: kernel[@}audiospillage.com

.. code-block:: text

    The sawtooth is a nice oscillator but I can't seem to get the square wave to work properly.  Anyone else had any luck with this?  Also, it's worth noting that the code assumes it is running on a little endian architecture.              

- **Date**: 2009-07-07 04:45:40
- **By**: moc.enecslatnemirepxe@leinad

.. code-block:: text

    I have written GPLv3 C++ source code for a MinBLEP oscillator and also public domain C++ source code for generating the MinBLEP without MatLab.
    
    http://www.experimentalscene.com/articles/minbleps.php - Article and Code
    
    http://www.experimentalscene.com/source.php - Look in DarkWave / latest version / CoreMachines / VCO.cpp

