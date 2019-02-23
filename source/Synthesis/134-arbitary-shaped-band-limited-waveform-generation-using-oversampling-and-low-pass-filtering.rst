Arbitary shaped band-limited waveform generation (using oversampling and low-pass filtering)
============================================================================================

- **Author or source:** uh.doilop.cak@egamer
- **Created:** 2003-01-02 20:27:18



.. code-block:: c++
    :linenos:
    :caption: code

    Arbitary shaped band-limited waveform generation
    (using oversampling and low-pass filtering)
    
    There are many articles about band-limited waveform synthesis techniques, that provide correct and fast methods for generating classic analogue waveforms, such as saw, pulse, and triangle wave.  However, generating arbitary shaped band-limited waveforms, such as the "sawsin" shape (found in this source-code archive), seems to be quite hard using these techniques.
    
    My analogue waveforms are generated in a _very_ high sampling rate (actually it's 1.4112 GHz for 44.1 kHz waveforms, using 32x oversampling).  Using this sample-rate, the amplitude of the aliasing harmonics are negligible (the base analogue waveforms has exponentially decreasing harmonics amplitudes).
    
    Using a 511-tap windowed sync FIR filter (with Blackman-Harris window, and 12 kHz cutoff frequency) the harmonics above 20 kHz are killed, the higher harmonics (that cause the sharp overshoot at step response) are dampened.
    
    The filtered signal downsampled to 44.1 kHz contains the audible (non-aliased) harmonics only.
    
    This waveform synthesis is performed for wavetables of 4096, 2048, 1024, ... 8, 4, 2 samples.  The real-time signal is interpolated from these waveform-tables, using Hermite-(cubic-)interpolation for the waveforms, and linear interpolation between the two wavetables near the required note.
    
    This procedure is quite time-consuming, but the whole waveform (or, in my implementation, the whole waveform-set) can be precalculated (or saved at first launch of the synth) and reloaded at synth initialization.
    
    I don't know if this is a theoretically correct solution, but the waveforms sound good (no audible aliasing).  Please let me know if I'm wrong...

Comments
--------

- **Date**: 2003-01-23 13:26:38
- **By**: moc.xinortceletrams@xelA

.. code-block:: text

    Why can't you use fft/ifft
    to synthesis directly wavetables of 2048,1024,..?
    It'd be not so 
    "time consuming" comparing to FIR filtering.
    Further cubic interpolation still might give you audible
    distortion in some cases. 
    --Alex.
    
    

- **Date**: 2003-02-02 19:24:23
- **By**: uh.doilop.cak@egamer

.. code-block:: text

    What should I use instead of cubic interpolation? (I had already some aliasing problems with cubic interpolation, but that can be solved by oversampling 4x the realtime signal generation)
    Is this theory of generating waves from wavetables of 4096, 2084, ... 8, 4, 2 samples wrong?

- **Date**: 2003-02-19 17:12:42
- **By**: moc.xinortceletrams@xelA

.. code-block:: text

    I think tablesize should not vary
    depending on tone (4096,2048...)
    and you'd better stay with the same table size for all notes (for example 4096, 4096...). 
    
    To avoid interpolation noise 
    (it's NOT caused by aliasing)
    try to increase wavetable size
    and be sure that waveform spectrum has
    steep roll off 
    (don't forget Gibbs phenomena as well).
                  

- **Date**: 2004-08-24 08:04:28
- **By**: es.tensse@idarozs.szalab

.. code-block:: text

    you say that the higher harmonics (that cause the sharp overshoot at step response) are dampened.
    How ? Or is it a result of the filtering ?
                  

- **Date**: 2005-04-03 07:10:58
- **By**: uh.doilop.scakam@egamer

.. code-block:: text

    Yes. The FIR-filter cutoff is set to 12 kHz, so it dampens the audible frequencies too. This way the frequncies above 20 kHz are about -90 dB (don't remember exactly, but killing all harmonics above 20 kHz was the main reason to set the cutoff to 12 kHz).
    
    Anyway, as Alex suggested, FFT/IFFT seems to be a better solution to this problem.

