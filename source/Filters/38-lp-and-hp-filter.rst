LP and HP filter
================

- **Author or source:** Patrice Tarrabia
- **Type:** biquad, tweaked butterworth
- **Created:** 2002-01-17 02:13:47



.. code-block:: c++
    :linenos:
    :caption: code

    r  = rez amount, from sqrt(2) to ~ 0.1
    f  = cutoff frequency
    (from ~0 Hz to SampleRate/2 - though many
    synths seem to filter only  up to SampleRate/4)
    
    The filter algo:
    out(n) = a1 * in + a2 * in(n-1) + a3 * in(n-2) - b1*out(n-1) - b2*out(n-2)
    
    Lowpass:
          c = 1.0 / tan(pi * f / sample_rate);
    
          a1 = 1.0 / ( 1.0 + r * c + c * c);
          a2 = 2* a1;
          a3 = a1;
          b1 = 2.0 * ( 1.0 - c*c) * a1;
          b2 = ( 1.0 - r * c + c * c) * a1;
    
    Hipass:
          c = tan(pi * f / sample_rate);
    
          a1 = 1.0 / ( 1.0 + r * c + c * c);
          a2 = -2*a1;
          a3 = a1;
          b1 = 2.0 * ( c*c - 1.0) * a1;
          b2 = ( 1.0 - r * c + c * c) * a1;

Comments
--------

- **Date**: 2002-03-14 15:24:20
- **By**: moc.liamtoh@lossor_ydna

.. code-block:: text

    Ok, the filter works, but how to use the resonance parameter (r)? The range from sqrt(2)-lowest to 0.1 (highest res.) is Ok for a LP with Cutoff > 3 or 4 KHz, but for lower cutoff frequencies and higher res you will get values much greater than 1! (And this means clipping like hell)
    
    So, has anybody calculated better parameters (for r, b1, b2)?

- **Date**: 2003-04-03 10:23:36
- **By**: moc.liamtoh@trahniak

.. code-block:: text

    Below is my attempt to implement the above lowpass filter in c#. I'm just a beginner at this so it's probably something that I've messed up. If anybody can offer a suggestion of what I may be doing wrong please help. I'm getting a bunch of stable staticky noise as my output of this filter currently.
    
    

- **Date**: 2003-04-03 10:25:15
- **By**: moc.liamtoh@trahniak

.. code-block:: text

    public class LowPassFilter
    {
            /// <summary>
            /// rez amount, from sqrt(2) to ~ 0.1
            /// </summary>
            float r;
            /// <summary>
            /// cutoff frequency
            /// (from ~0 Hz to SampleRate/2 - though many
            /// synths seem to filter only up to SampleRate/4)
            ///</summary>
            float f;
            float c;
    
            float a1;
            float a2;
            float a3;
            float b1;
            float b2;
    
    //      float in0 = 0;
            float in1 = 0;
            float in2 = 0;
    
    //      float out0;
            float out1 = 0;
            float out2 = 0;
    
            private int _SampleRate;
    
            public LowPassFilter(int sampleRate)
            {
                    _SampleRate = sampleRate;
    
    //              SetParams(_SampleRate / 2f, 0.1f);
                    SetParams(_SampleRate / 8f, 1f);
            }
    
    
            public float Process(float input)
            {
                    float output = a1 * input + 
                                     a2 * in1 + 
                                     a3 * in2 - 
                                     b1 * out1 - 
                                     b2 * out2;
    
                    in2 = in1;
                    in1 = input;
    
                    out2 = out1;
                    out1 = output;
    
                    Console.WriteLine(input + ", " + output);
    
                    return output;
            }
    
    

- **Date**: 2003-04-03 10:25:39
- **By**: moc.liamtoh@trahniak

.. code-block:: text

            /// <summary>
            /// 
            /// </summary>
            public float CutoffFrequency
            {
                    set
                    {
                            f = value;
                            c = (float) (1.0f / Math.Tan(Math.PI * f / _SampleRate));
                            SetParams();
                    }
                    get
                    {
                            return f;
                    }
            }
    
            /// <summary>
            /// 
            /// </summary>
            public float Resonance
            {
                    set
                    {
                            r = value;
                            SetParams();
                    }
                    get
                    {
                            return r;
                    }
            }
    
            public void SetParams(float cutoffFrequency, float resonance)
            {
                    r = resonance;
                    CutoffFrequency = cutoffFrequency;
            }
    
            /// <summary>
            /// TODO rename
            /// </summary>
            /// <param name="c"></param>
            /// <param name="resonance"></param>
            private void SetParams()
            {
                    a1 = 1f / (1f + r*c + c*c);
                    a2 = 2 * a1;
                    a3 = a1;
                    b1 = 2f * (1f - c*c) * a1;
                    b2 = (1f - r*c + c*c) * a1;
            }
    }

- **Date**: 2003-04-03 11:58:51
- **By**: moc.liamtoh@trahniak

.. code-block:: text

    Nevermind I think I solved my problem. I was missing parens around the coefficients and the variables ...(a1 * input)...

- **Date**: 2003-04-22 17:30:14
- **By**: moc.liamtoh@trahniak

.. code-block:: text

    After implementing the lowpass algorithm I get a loud ringing noise on some frequencies both high and low. Any ideas?

- **Date**: 2006-03-29 14:10:59
- **By**: ed.xmg@lhadl

.. code-block:: text

    hi,
    since this is the best filter i found on the net, i really need bandpass and bandstop!!! can anyone help me with the coefficents?

- **Date**: 2006-05-23 18:25:18
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    AFAIK there's no separate bandpass and bandstop version of Butterworth filters. Instead, bandpass is usually done by cascading a HP and a LP filter, and bandstop is the mixed output of a HP and a LP filter. However, there's bandpass biquad code (for example RBJ biquad filters). Cheers Peter

- **Date**: 2006-05-28 20:15:48
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    You can save two divisions for lowpass using 
      c = tan((0.5 - (f * inv_samplerate))*pi);
    instead of
      c = 1.0 / tan(pi * f / sample_rate);
    where inv_samplerate is 1.0/samplerate precalculated. (mul is faster than div)
    
    However, the latter form can be approximated very well below 4kHz (at 44kHz samplerate) with 
      c = 1.0 / (pi * f * inv_sample_rate);
    which is far better than both of the previous two equations, because it does not use any transcendental functions. So, an optimized form is:
    
    f0 = f * inv_sample_rate;
    if (f0 < 0.1) c = 1.0 / (f0 * pi); // below 4.4k
    else c = tan((0.5 - f0) * pi);
    
    This needs only about ~60% CPU below 4.4kHz. Probably using lookup tables could make it even faster...
    
    Mapping resonance range 0..1 to 0..self-osc:
      float const sqrt_two = 1.41421356;
      r = sqrt_two - resonance * sqrt_two;
    
    Setting resonance in the conventional q form (like in RBJ biquads):
      r = 1.0/q;
    
    Cheers, Peter
    
    
    
    
    
    
    
    
    

- **Date**: 2006-05-28 20:43:28
- **By**: uh.etle@yfoocs

.. code-block:: text

    However I find that this algorythm has a slight tuning error regardless of using approximation or not. 'inv_samplerate = 0.95 * samplerate' seems to give a more accurate frequency tuning.

- **Date**: 2006-05-29 15:50:13
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    You can use the same trick for highpass:
    
    precalc when setting up the filter:
      inv_samplerate = 1.0 / samplerate * 0.957;
    (multipying by 0.957 seems to give the most precise tuning)
    
    and then calculating c:
    
    f0 = f * inv_samplerate;
    if (f0 < 0.05) c = (f0 * pi); 
    else c = tan(f0 * pi);
    
    Now I used 0.05 instead of 0.1, thats 0.05 * 44100  = 2.2k instead of 4.4k. So, this is a bit more precise than 0.1, becuase around 3-4k it had a slight error, however, only noticeable on the analyzer when compared to the original version. This is still about two third of the logarithmic frequency scale, so it's quite a bit of a speed improvement. You can use either precision for both lowpass and highpass.
    
    For calculating tan(), you can take some quick sin() approximation, and use:
      tan(x)=sin(x)/sin(half_pi-x)
    
    There are many good pieces of code for that in the archive.
    
    I tried to make some 1/x based approximations for 1.0/tan(x), here is one:
    
    inline float tan_inv_approx(float x)
    {
        float const two_div_pi = 2.0f/3.141592654f;
        if (x<0.5f) return 1.0f/x; 
        else return 1.467f*(1.0f/x-two_div_pi);
    }
    
    This one is pretty fast, however it is a quite rough estimate; it has some 1-2 semitones frequency tuning error around 5-8 kHz and above 10kHz. Might be usable for synths, however, or somewhere where scientific precision is not needed.
    
    Cheers, Peter

- **Date**: 2006-05-30 21:12:13
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Sorry, forget the * 0.957 tuning, this algorythm is precise without that, the mistake was in my program. Everything else is valid, I hope.

- **Date**: 2008-03-11 13:31:52
- **By**: ur.kb@sexof

.. code-block:: text

    Optimization for Hipass:
    
    c = tan(pi * f / sample_rate);
    
    c = ( c + r ) * c;
    a1 = 1.0 / ( 1.0 + c );
    b1 = ( 1.0 - c );
    
    out(n) = ( a1 * out(n-1) + in - in(n-1) ) * b1;              

