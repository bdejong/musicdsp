State Variable Filter (Double Sampled, Stable)
==============================================

- **Author or source:** Andrew Simper
- **Type:** 2 Pole Low, High, Band, Notch and  Peaking
- **Created:** 2003-10-11 01:57:00


.. code-block:: text
    :caption: notes

    Thanks to Laurent de Soras for the stability limit
    and Steffan Diedrichsen for the correct notch output.
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    input  = input buffer;
    output = output buffer;
    fs     = sampling frequency; 
    fc     = cutoff frequency normally something like: 
             440.0*pow(2.0, (midi_note - 69.0)/12.0); 
    res    = resonance 0 to 1; 
    drive  = internal distortion 0 to 0.1
    freq   = 2.0*sin(PI*MIN(0.25, fc/(fs*2)));  // the fs*2 is because it's double sampled
    damp   = MIN(2.0*(1.0 - pow(res, 0.25)), MIN(2.0, 2.0/freq - freq*0.5));
    notch  = notch output 
    low    = low pass output 
    high   = high pass output 
    band   = band pass output 
    peak   = peaking output = low - high
    --
    double sampled svf loop:
    for (i=0; i<numSamples; i++)
    {
      in    = input[i]; 
      notch = in - damp*band;
      low   = low + freq*band;
      high  = notch - low;
      band  = freq*high + band - drive*band*band*band;
      out   = 0.5*(notch or low or high or band or peak);
      notch = in - damp*band;
      low   = low + freq*band;
      high  = notch - low;
      band  = freq*high + band - drive*band*band*band;
      out  += 0.5*(same out as above);
      output[i] = out;
    }

Comments
--------

- **Date**: 2004-11-19 13:30:07
- **By**: eb.tenyks@didid

.. code-block:: text

    Correct me if I'm wrong, but the double-sampling here looks like doubling the input, which is a bad resampling introducing aliasing, followed by an averaging of the 2 outputs, thus filtering that aliasing.
    It works, but I think it (the averaging) has the side effect of smoothing up the high freqs in the source material, thus with this filter you can't really fully open it and have the original signal.
    At least, it's what seems to happen practically in my tests.
    
    Problem is that this SVF indeed has a crap stability near nyquist, but I can't think of any better way to make it work better, unless you use a better but much more costy upsampling/downsampling.
    
    Anyone confirms?

- **Date**: 2004-11-26 09:45:28
- **By**: kd.utd.xaspmak@mj

.. code-block:: text

    Interesting that this question pops up right now. Lately I have been wondering about the same thing, not so much about the (possibly limited) frequency range, but about stability problems of the filter that I have had (even when using smoothed control signals). The non-linearity introduced by the "drive*band*band*band" factor does not seem to be covered by the stability measurements.
    In particular I would like to know, how the filter graphs in http://vellocet.com/dsp/svf/svf-stability.html and http://www-2.cs.cmu.edu/~eli/tmp/svf/stability.png were obtained? Would you like to post the code that generated the stability graph to the musicdsp archive?
    For the double-sampling scheme, wouldn't it make more sense to zero-stuff the input signal (that is interleave all input samples with zeros) instead of doubling the samples?
    

- **Date**: 2004-11-27 00:07:09
- **By**: kd.utd.xaspmak@mj

.. code-block:: text

    Oh, just noticed that Eli's SVF stability measurement code has already been made available at http://www-2.cs.cmu.edu/~eli/tmp/svf/
    However, I think it is up to him to decide whether he wants to include it in the archive or not.

- **Date**: 2007-12-13 11:01:38
- **By**: moc.kisuw@kmailliw

.. code-block:: text

    I was having problems with this filter when DRIVE is set to MAX and Rezonance is set to MIN. A quick way to fix it was to make DRIVE*REZO, so when there's no resonance, there's no need for DRIVE anyway. That fixed the problem.

- **Date**: 2017-05-11 21:39:28
- **By**: moc.liamg@libojyr

.. code-block:: text

    Here is how I am handling the resampling.  I know from trying this zero padding is nasty (terrible noise) without a good filter for downsampling back to base rate.  
    
    Below the input is linear interpolated input.  This is a slight improvement on what Nigel Redmon suggests here: http://www.earlevel.com/main/2003/03/02/the-digital-state-variable-filter/
    
    Which is simply to tick the filter twice per sample with the same input.  This is very similar to above code except that there should not be averaging of the two outputs.  You just tick the filter twice with the same input and take the output.  The state variables take care of the band limiting.  Remember the aliased terms are multiples of the sample rate so they fall on 0 and nyquist frequencies, not really having more severe artefacts than what you get from running the filter at base sample rate.
    
    For the low pass and bandpass outputs the filter itself performs the band-limiting necessary for clean decimation.  Intuitively the high pass output is due to a phase cancellation with the dual-integrator loop, so it should be about as clean as the LP and BP outputs.  The dual integrator is band-limiting in nature...just some thoughts.
    
    //-- Here's the Code --//
    //x[i] = input
    //x1 = x[i-1] = last input
    //Run 1 : Linear interpolate between x[n-1] and x[i]
    lpf = lpf + f* bpf;
    hpf = 0.5 * g * (x[i] + x1) - lpf - q*bpf;
    bpf = f* hpf + bpf;
    
    //Run 2
    lpf = lpf + f* bpf;
    hpf = g * x[i] - lpf - q*bpf;
    bpf = f* hpf + bpf;
    
    x1 = x[i];
    
    // Coefficients on each state variable
    // allows for any filter response function possible
    // with a biquad filter structure
    x[i] = lmix*lpf + hmix*hpf + bmix*bpf;              

