Compressor
==========

- **Author or source:** ur.liam@cnihsalf
- **Type:** Hardknee compressor with RMS look-ahead envelope calculation and adjustable attack/decay
- **Created:** 2004-05-26 16:02:59


.. code-block:: text
    :caption: notes

    RMS is a true way to estimate _musical_ signal energy,
    our ears behaves in a same way.
    
    to making all it work,
    try this values (as is, routine accepts percents and milliseconds) for first time:
    
    threshold = 50%
    slope = 50%
    RMS window width = 1 ms
    lookahead = 3 ms
    attack time = 0.1 ms
    release time = 300 ms
    
    This code can be significantly improved in speed by
    changing RMS calculation loop to 'running summ'
    (keeping the summ in 'window' -
    adding next newest sample and subtracting oldest on each step)
    


.. code-block:: c++
    :linenos:
    :caption: code

    void compress
        (
            float*  wav_in,     // signal
            int     n,          // N samples
            double  threshold,  // threshold (percents)
            double  slope,      // slope angle (percents)
            int     sr,         // sample rate (smp/sec)
            double  tla,        // lookahead  (ms)
            double  twnd,       // window time (ms)
            double  tatt,       // attack time  (ms)
            double  trel        // release time (ms)
        )
    {
        typedef float   stereodata[2];
        stereodata*     wav = (stereodata*) wav_in; // our stereo signal
        threshold *= 0.01;          // threshold to unity (0...1)
        slope *= 0.01;              // slope to unity
        tla *= 1e-3;                // lookahead time to seconds
        twnd *= 1e-3;               // window time to seconds
        tatt *= 1e-3;               // attack time to seconds
        trel *= 1e-3;               // release time to seconds
    
        // attack and release "per sample decay"
        double  att = (tatt == 0.0) ? (0.0) : exp (-1.0 / (sr * tatt));
        double  rel = (trel == 0.0) ? (0.0) : exp (-1.0 / (sr * trel));
    
        // envelope
        double  env = 0.0;
    
        // sample offset to lookahead wnd start
        int     lhsmp = (int) (sr * tla);
    
        // samples count in lookahead window
        int     nrms = (int) (sr * twnd);
    
        // for each sample...
        for (int i = 0; i < n; ++i)
        {
            // now compute RMS
            double  summ = 0;
    
            // for each sample in window
            for (int j = 0; j < nrms; ++j)
            {
                int     lki = i + j + lhsmp;
                double  smp;
    
                // if we in bounds of signal?
                // if so, convert to mono
                if (lki < n)
                    smp = 0.5 * wav[lki][0] + 0.5 * wav[lki][1];
                else
                    smp = 0.0;      // if we out of bounds we just get zero in smp
    
                summ += smp * smp;  // square em..
            }
    
            double  rms = sqrt (summ / nrms);   // root-mean-square
    
            // dynamic selection: attack or release?
            double  theta = rms > env ? att : rel;
    
            // smoothing with capacitor, envelope extraction...
            // here be aware of pIV denormal numbers glitch
            env = (1.0 - theta) * rms + theta * env;
    
            // the very easy hard knee 1:N compressor
            double  gain = 1.0;
            if (env > threshold)
                gain = gain - (env - threshold) * slope;
    
            // result - two hard kneed compressed channels...
            float  leftchannel = wav[i][0] * gain;
            float  rightchannel = wav[i][1] * gain;
        }
    }
    

Comments
--------

- **Date**: 2004-06-10 21:31:18
- **By**: moc.regnimmu@psd-cisum

.. code-block:: text

    My comments:
    
    A rectangular window is not physical. It would make more physical sense, and be a lot cheaper, to use a 1-pole low pass filter to do the RMS averaging. A 1-pole filter means you can lose the bounds checks in the RMS calculation.
    
    It does not make sense to convert to mono before squaring, you should square each channel separately and then add them together to get the total signal power.
    
    You might also consider whether you even need any filtering other than the attack/release filter. You could modify the attack/release rates appropriately, place the sqrt after the attack/release, and lose the rms averager entirely.
    
    I don't think your compressor actually approaches a linear slope in the decibel domain. You need a gain law more like
    
    double gain = exp(max(0.0,log(env)-log(thresh))*slope);
    
    
    Sincerely,
         Frederick Umminger
    

- **Date**: 2004-07-30 05:31:36
- **By**: moc.liamg@noteex

.. code-block:: text

    To sum up (and maybe augment) the RMS calculation method, this question and answer may be of use...
    
    **********
    
    music-dsp@shoko.calarts.edu writes:
    I am looking at gain processing algorithms. I haven't found much in the way of reference material on this, any pointers? In the level detection code, if one is doing peak detection, how many samples does one generally average over (if at all)? What kind of window size for RMS level detection? Is the RMS level detection generally the same algo. as peak, but with a bigger window?
    
    The peak detector can be easily implemented as a one-pole low pass, you just have modify it, so that it tracks the peaks and gently falls down afterwards. RMS detection is done squaring the input signal, averaging with a lowpass and taking the root afterwards.
    
    Hope this helps.
    
    Kind regards
    
    Steffan Diedrichsen
    
    DSP developer
    
    emagic GmbH 
    
    **********
    
    I found the thread by searching old [music-dsp] forum posts. Hope it helps.

- **Date**: 2006-11-07 01:52:17
- **By**: gro.esabnaeco@euarg

.. code-block:: text

    How would you use a 1-pole lowpass filter to do RMS averaging? How do you pick a coefficient to use?
    

- **Date**: 2006-11-09 01:19:41
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Use x = exp(-1/d), where d is the time constant in samples. A 1 pole IIR filter has an infinite impulse response, so instead of window width, this coeff determines the time when the impulse response reaches 36.8% of the original value.
    
    Coeffs:
    a0 = 1.0-x;
    b1 = -x;
    
    Loop:
    out = a0*in - b1*tmp;
    tmp = out;
    
    -- peter schoffhauzer

- **Date**: 2008-11-20 08:30:28
- **By**: moc.361@oatuxt

.. code-block:: text

    I am looking at gain processing algorithms£º
    There are too such sentences : 
    double att = (tatt == 0.0) ? (0.0) : exp (-1.0 / (sr * tatt));
    double rel = (trel == 0.0) ? (0.0) : exp (-1.0 / (sr * trel)); 
    
    can you tell me something about the exp (-1.0 / (sr * tatt))? 
    
    New day ~~
    thanks 
    

- **Date**: 2010-04-28 15:12:47
- **By**: moc.liamg@enin.kap

.. code-block:: text

    This is a useful reference, however the RMS calculations are pretty dodgy. Firstly there is a bug where is calculates the number of samples to use:
    
    int sr, // sample rate (smp/sec)
    ...
    double twnd, // window time (ms)
    ...
    // samples count in lookahead window
    int nrms = (int) (sr * twnd);
    
    The units are mixed when calculating the number of samples in the RMS window. The window time needs to be converted to seconds before multiplying by the sample rate.
    
    As others have mentioned the RMS calculation is also really expensive, and in my tests I found it was pretty innacurate unless you use a LOT of samples (you basically need a (sample rate)/2 window of samples in your RMS calculation to accurately measure the power of all frequencies). 
    
    I ended up using the 1 pole low pass filter approach suggested here, and it is a good cheap approximation of power. I did, however, end up mulitplying it by root(2) (the RMS of a sine wave, which seemed like a reasonable normalisation factor) in order to get it between 0 and 1, which is a more useful range.
    
    Another slightly more accurate way to caculate the RMS without iterating over and entire window  for each sample is to keep a running total of the squared sums of samples.
    
    for( i = 0; i < NumSamples; ++i )
    {
      NewSample = Sample[i];
      OldSample = Sample[i - RMSWindowSize];
    
      SquaredSum = SquaredSum + NewSample * NewSample;
      SquaredSum = SquaredSum - OldSample * OldSample;
    
      RMS = sqrt( SquaredSum / RMSWindowSize );
    
      // etc...
    }
    
    Calculating the power in the signal is definately the awkward part of this DSP!

