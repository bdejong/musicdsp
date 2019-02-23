Quick and dirty sine generator
==============================

- **Author or source:** moc.liamtoh@tsvreiruoc
- **Type:** sine generator
- **Created:** 2004-01-06 19:57:44


.. code-block:: text
    :caption: notes

    this is part of my library, although I've seen a lot of sine generators, I've never seen
    the simplest one, so I try to do it,
    tell me something, I've try it and work so tell me something about it
    
    
    
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    PSPsample PSPsin1::doOsc(int numCh)
    {
    
    	double x=0;
    	double t=0;
    
    	if(m_time[numCh]>m_sampleRate)	//re-init cycle
    		m_time[numCh]=0;
    	
    	if(m_time[numCh]>0)
    	{
    		t =(double)(((double)m_time[numCh])/(double)m_sampleRate);
    		
    		x=(m_2PI *(double)(t)*m_freq);
    	}
    	else 
    		x=0;
    
    	
    	PSPsample r=(PSPsample) sin(x+m_phase)*m_amp;
    	
    	m_time[numCh]++;
    
    	return 	r;
    
    }

Comments
--------

- **Date**: 2004-01-08 13:51:26
- **By**: moc.sulp.52retsinnab@etep

.. code-block:: text

    isn't the sin() function a little bit heavyweight?  Since this is based upon slices of time, would it not be much more processor efficient to use a state variable filter that is self oscillating?
    
    
    The operation:
    t =(double)(((double)m_time[numCh])/(double)m_sampleRate);
    
    also seems a little bit much, since t could be calculated by adding an interval value, which would eliminate the divide (needs more clocks).  The divide would then only need to be done once.
    An FDIV may take 39 clock cycles minimum(depending on the operands), whilst an FADD is far faster (3 clocks).  An FMUL is comparable to an add, which would be a predominant instruction if using the SVF method.
    
    FSIN may take between 16-126 clock cylces.
    
    (clock cycle info nabbed from: http://www.singlix.com/trdos/pentium.txt)
    

- **Date**: 2004-01-09 21:19:37
- **By**: moc.hclumoidua@bssor

.. code-block:: text

    See also the fun with sinusoids page:
    http://www.audiomulch.com/~rossb/code/sinusoids/

- **Date**: 2014-11-18 07:37:27
- **By**: moc.oohay@trawets.tna

.. code-block:: text

    For audio generation, sines are expensive i think, they are so perfect and take up more processing. it's rare to find a synth that sounds nicer with a sine compared to a parabol wave. My favourite parabolic wave is simply triangle wave with x*x with one of the half periods flipped. x*x is a very fast!!!

- **Date**: 2014-12-06 12:06:58
- **By**: ed.xmg@retsneum.ellak

.. code-block:: text

    hmm... x*x second half flipped...
    very cool ! i'll give it a try!!

