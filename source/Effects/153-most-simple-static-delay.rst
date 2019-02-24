Most simple static delay
========================

- **Author or source:** moc.liamtoh@sisehtnysorpitna
- **Type:** Static delay
- **Created:** 2003-09-02 06:21:15


.. code-block:: text
    :caption: notes

    This is the most simple static delay (just delays the input sound an amount of samples).
    Very useful for newbies also probably very easy to change in a feedback delay (for comb
    filters for example).
    
    Note: fDlyTime is the delay time parameter (0 to 1)
    
    i = input index
    j = output index


.. code-block:: c++
    :linenos:
    :caption: code

    if( i >= SampleRate )
        i = 0;
    
    DlyBuffer[ i ] = Input;
    
    j = i - (fDlyTime * SampleRate);
    
    i++;
    
    if( j < 0 )
        j = SampleRate + j;
    
    Output = DlyBuffer[ j ];

Comments
--------

- **Date**: 2003-09-02 09:17:47
- **By**: moc.liamtoh@sisehtnysorpitna

.. code-block:: text

    Another note: The delay time will be 0 if fDlyTime is 0 or 1.

- **Date**: 2003-09-08 12:21:20
- **By**: gro.ekaf@suomynona

.. code-block:: c++

    // I think you should be careful with mixing floats and integers that way (error-prone,
    // slow float-to-int conversions, etc).
    
    // This should also work (haven't checked, not best way of doing it):
    
    // ... (initializing) ..
    
    float numSecondsDelay = 0.3f;
    int numSamplesDelay_ = (int)(numSecondsDelay * sampleRate); // maybe want to round to an integer instead of truncating..
    
    float *buffer_ = new float[2*numSamplesDelay];
    
    for (int i = 0; i < numSamplesDelay_; ++i)
    {
      buffer_[i] = 0.f;
    }
    
    int readPtr_ = 0;
    int writePtr_ = numSamplesDelay_;
    
    // ... (processing) ...
    
    for (i = each sample)
    {
      buffer_[writePtr_] = input[i];
      output[i] = buffer_[readPtr_];
    
      ++writePtr_;
      if (writePtr_ >= 2*numSamplesDelay_)
        writePtr_ = 0;
    
      ++readPtr_;
      if (readPtr_ >= 2*numSamplesDelay_)
        readPtr_ = 0;
    } 

- **Date**: 2004-08-24 19:31:45
- **By**: moc.liamg@noteex

.. code-block:: text

    I may be missing something, but I think it gets a little simpler than the previous two examples.
    The difference in result is that actual delay will be 1 if d is 0 or 1. 
    
    i = input/output index
    d = delay (in samples)
    
    Code:
    
    out = buffer[i];
    buffer[i] = in;
    i++;
    if(i >= delay) i = 0;

- **Date**: 2005-12-18 02:35:00
- **By**: moc.liamg@noteex

.. code-block:: text

    or even in three lines...
    
    out = buffer[i];
    buffer[i++] = in;
    if(i >= delay) i = 0;

- **Date**: 2006-12-30 16:29:07
- **By**: ku.oc.etativarg-jd@etativarg

.. code-block:: text

    The only problem with this implementation, is that it is not really an audio effect! all this
    will do is to delay the input signal by a given number of samples! ...why would you ever want
    to do that? ...this would only ever work if you had a DSP and speakers both connected to the
    audio source and run them at the same time, so the speakers would be playing the original sorce
    and the DSP containing the delayed source connected to another set of speakers! this is not
    really an audio efffect! 
    
    ...Here is a pseudo code example of a delay effect that will mix both the original sound with
    the delayed sound:
    
    Pseudo Code implementation for simple delay:
     - This implementation will put the current audio signal to the 
       left channel and the delayed audio signal to the right channel.
       this is suitable for any stereo codec!
    
    delay_function {
    
      left_channel   // for stereo left
      right_channel  // for stereo right
      mono           // mono representation of stereo input
      delay_time     // amount of time to delay input  
      counter = 0    // counter
    
      //setup an array that is the same length as the maximum delay time:
      delay_array[max delay time]  // array containing delayed data
    
      // convert stereo to mono:
      (left_channel + right_channel) / 2
      
      // initalise time to delay signal - maybe input from user
      delay_time = x
      
      if (delay_time = 0){
        left_out = mono
        right_out = mono
      }
      else {
        // put current input data to left channel:
        left_out = mono
        // put oldest delayed input data to right channel:
        right_out = delay_array[index]
        
        // overwrite with newest input:
        delay_array[index] = mono;    
    
        // is index at end of delay buffer? if not increment, else set to zero
        if (index < delay_time) index++
        else index = 0
      }
    
    }
