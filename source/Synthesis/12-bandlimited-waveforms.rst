Bandlimited waveforms...
========================

- **Author or source:** Paul Kellet
- **Created:** 2002-01-17 00:56:04


.. code-block:: text
    :caption: notes

    (Quoted from Paul's mail)
    Below is another waveform generation method based on a train of sinc functions (actually
    an alternating loop along a sinc between t=0 and t=period/2).
    
    The code integrates the pulse train with a dc offset to get a sawtooth, but other shapes
    can be made in the usual ways... Note that 'dc' and 'leak' may need to be adjusted for
    very high or low frequencies.
    
    I don't know how original it is (I ought to read more) but it is of usable quality,
    particularly at low frequencies. There's some scope for optimisation by using a table for
    sinc, or maybe a a truncated/windowed sinc?
    
    I think it should be possible to minimise the aliasing by fine tuning 'dp' to slightly
    less than 1 so the sincs join together neatly, but I haven't found the best way to do it.
    Any comments gratefully received.


.. code-block:: c++
    :linenos:
    :caption: code

    float p=0.0f;      //current position
    float dp=1.0f;     //change in postion per sample
    float pmax;        //maximum position
    float x;           //position in sinc function
    float leak=0.995f; //leaky integrator
    float dc;          //dc offset
    float saw;         //output
    
    
    //set frequency...
    
      pmax = 0.5f * getSampleRate() / freqHz;
      dc = -0.498f/pmax;
    
    
    //for each sample...
    
      p += dp;
      if(p < 0.0f)
      {
        p = -p;
        dp = -dp;
      }
      else if(p > pmax)
      {
        p = pmax + pmax - p;
        dp = -dp;
      }
    
      x= pi * p;
      if(x < 0.00001f)
         x=0.00001f; //don't divide by 0
    
      saw = leak*saw + dc + (float)sin(x)/(x);

Comments
--------

- **Date**: 2004-09-23 00:07:02
- **By**: es.ollehc@evawenis

.. code-block:: text

    Hi,
    Has anyone managed to implement this in a VST?
    If anyone could mail me and talk me through it I'd be very grateful.  Yes, I'm a total newbie and yes, I'm after a quick-fix solution...we all have to start somewhere, eh?
    
    As it stands, where I should be getting a sawtooth I'm getting a full-on and inaudible signal...!
    
    Even a small clue would be nice.
    Cheers,
    A

- **Date**: 2012-01-01 23:17:35
- **By**: ku.oc.oohay@ekolbdiurd

.. code-block:: text

    this sounds quite nice, maybe going to use it an LV 2 plugin              

- **Date**: 2016-01-17 13:24:11
- **By**: pvdmeer [atorsomething] gmail [point] com

.. code-block:: text

    this is really amazing, and easily hacked into a lut-based algo. i'll try windowing it too, but it already looks like aliasing is well within acceptable levels. 

