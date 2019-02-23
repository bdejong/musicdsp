Envelope detector
=================

- **Author or source:** Bram
- **Created:** 2002-04-12 21:37:18


.. code-block:: text
    :caption: notes

    Basicaly a one-pole LP filter with different coefficients for attack and release fed by
    the abs() of the signal. If you don't need different attack and decay settings, just use
    in->abs()->LP


.. code-block:: c++
    :linenos:
    :caption: code

    //attack and release in seconds
    float ga = (float) exp(-1/(SampleRate*attack));
    float gr = (float) exp(-1/(SampleRate*release));
    
    float envelope=0;
    
    for(...)
    {
      //get your data into 'input'
      EnvIn = std::abs(input);
    
      if(envelope < EnvIn)
      {
         envelope *= ga;
         envelope += (1-ga)*EnvIn;
      }
      else
      {
         envelope *= gr;
         envelope += (1-gr)*EnvIn;
      }
      //envelope now contains.........the envelope ;)
    }

Comments
--------

- **Date**: 2005-05-17 13:58:11
- **By**: moc.liamg@sisehtnysorpitna

.. code-block:: c++

    // Slightly faster version of the envelope follower using one multiply form.
    
    // attTime and relTime is in seconds
    
    float ga = exp(-1.0f/(sampleRate*attTime));
    float gr = exp(-1.0f/(sampleRate*relTime));
    
    float envOut = 0.0f;
    
    for( ... )
    {
        // get your data into 'input'
    
        envIn = fabs(input);
    
        if( envOut < envIn )
            envOut = envIn + ga * (envOut - envIn);
        else
            envOut = envIn + gr * (envOut - envIn);
    
        // envOut now contains the envelope
    }
