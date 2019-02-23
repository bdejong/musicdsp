State variable
==============

- **Author or source:** Effect Deisgn Part 1, Jon Dattorro, J. Audio Eng. Soc., Vol 45, No. 9, 1997 September
- **Type:** 12db resonant low, high or bandpass
- **Created:** 2002-01-17 02:01:50


.. code-block:: text
    :caption: notes

    Digital approximation of Chamberlin two-pole low pass. Easy to calculate coefficients,
    easy to process algorithm.


.. code-block:: c++
    :linenos:
    :caption: code

    cutoff = cutoff freq in Hz
    fs = sampling frequency //(e.g. 44100Hz)
    f = 2 sin (pi * cutoff / fs) //[approximately]
    q = resonance/bandwidth [0 < q <= 1]  most res: q=1, less: q=0
    low = lowpass output
    high = highpass output
    band = bandpass output
    notch = notch output
    
    scale = q
    
    low=high=band=0;
    
    //--beginloop
    low = low + f * band;
    high = scale * input - low - q*band;
    band = f * high + band;
    notch = high + low;
    //--endloop

Comments
--------

- **Date**: 2006-01-11 15:06:56
- **By**: nope

.. code-block:: text

    Wow, great. Sounds good, thanks.

- **Date**: 2007-02-13 13:45:02
- **By**: es.aelp@maps.on

.. code-block:: text

    The variable "high" doesn't have to be initialised, does it? It looks to me like the only variables that need to be kept around between iterations are "low" and "band".

- **Date**: 2007-02-13 15:28:30
- **By**: moc.erehwon@ydobon

.. code-block:: text

    Right. High and notch are calculated from low and band every iteration.

- **Date**: 2007-07-18 11:34:21
- **By**: og.on@alal

.. code-block:: text

    Anyone know what the difference is between q and scale?

- **Date**: 2007-07-29 17:17:16
- **By**: moc.liamtoh@rebbadrebbaj

.. code-block:: text

    "most res: q=1, less: q=0"
    
    Someone correct me if I'm wrong, but isn't that backwards? q=0 is max res, q=1 is min res.
    
    q and scale are the same value. What the algorithm is doing is scaling the input the higher the resonance is turned up to prevent clipping. One reason why I think 0 equals max resonance and 1 equals no resonance. 
    
    So as q approaches zero, the input is attenuated more and more. In other words, as you turn up the resonance, the input is turned down. 

- **Date**: 2007-11-16 12:58:03
- **By**: rettam.ton@seod

.. code-block:: text

    scale = sqrt(q);
    
    and
    
    //value (0;100) - for example
    q = sqrt(1.0 - atan(sqrt(value)) * 2.0 / PI);
    f = frqHz / sampleRate*4.;
    
    uffffffff :)
    
    Now enjoy!

- **Date**: 2008-11-29 20:04:47
- **By**: gro.ybbek@bk

.. code-block:: text

    One drawback of this is that the cutoff frequency can only go up to SR/4 instead of SR/2 - but you can easily compensate it by using 2x oversampling, eg. simply running this thing twice per sample (apply input interpolation or further output filtering ad lib, but from my experience simple linear interpolation of the input values (in and (in+lastin)/2) works well enough).

- **Date**: 2009-03-05 13:24:35
- **By**: moc.liamg@321tiloen

.. code-block:: text

    here is the filter with 2x oversampling + some x,y pad functionality to morph between states:
    like this fx (uses different filter)
    
    http://img299.imageshack.us/img299/4690/statevarible.png
    
    smoothing with interpolation is suggest for most parameters:
    
    //sr: samplerate;
    //cutoff: 20 - 20k;
    //qvalue: 0 - 100;
    //x, y: 0 - 1
    
    q = sqrt(1 - atan(sqrt(qvalue)) * 2 / pi);
    scale = sqrt(q);
    f = slider1 / sr * 2; // * 2 here instead of 4
    
    //----------sample loop
    
    //set 'input' here
    
    //os x2
    for (i=0; i<2; i++) {
    low = low + f * band;
    high = scale * input - low - q * band;
    band = f * high + band; 
    notch = high + low;
    );
    
    //  x,y pad scheme
    //     
    //  high -- notch
    //  |           |
    //  |           |
    //  low ---- band
    //
    //
    // use two pairs
    
    //low, high
    pair1 = low * y + high * (1-y);
    //band, notch
    pair2 = band * y + notch * (1-y);
    
    //out
    out = pair2 * x + pair1 * (1-x);
    
    //----------sample loop

