Easy noise generation
=====================

- **Author or source:** moc.psd-nashi@liam
- **Type:** White Noise
- **Created:** 2006-02-23 22:40:20


.. code-block:: text
    :caption: notes

    Easy noise generation,
    in .hpp,
    b_noise = 19.1919191919191919191919191919191919191919;
    
    alternatively, the number 19 below can be replaced with a number of your choice, to get
    that particular flavour of noise.
    
    Regards,
    Ove Karlsen.
    


.. code-block:: c++
    :linenos:
    :caption: code

    	b_noise = b_noise * b_noise;
    	int i_noise = b_noise;
    	b_noise = b_noise - i_noise;
    
    	double b_noiseout;
    	b_noiseout = b_noise - 0.5;
    
     	b_noise = b_noise + 19;
    

Comments
--------

- **Date**: 2006-07-16 18:24:22
- **By**: moc.liamg@saoxyz

.. code-block:: text

                  This is quite a good PRNG! The numbers it generates exhibit a slight a pattern (obviously, since it's not very sophisticated) but they seem quite usable! The real FFT spectrum is very flat and "white" with just one or two aberrant spikes while the imaginary spectrum is almost perfect (as is the case with most PRNGs). Very nice! Either that or I need more practice with MuPad...

- **Date**: 2007-01-16 12:16:24
- **By**: moc.liamtoh@neslrakevofira

.. code-block:: text

    Alternatively you can do:
    
     		double b_noiselast = b_noise;
    		b_noise = b_noise + 19;
    		b_noise = b_noise * b_noise;
    		b_noise = b_noise + ((-b_noise + b_noiselast) * 0.5);
    		int i_noise = b_noise;
    		b_noise = b_noise - i_noise;
    
    This will remove the patterning.

- **Date**: 2007-01-16 16:56:19
- **By**: moc.erehwon@ydobon

.. code-block:: text

    >>b_noise = b_noise + ((-b_noise + b_noiselast) * 0.5);
    
    That seems to reduce to just:
    
    b_noise=(b_noise+b_noiselast) * 0.5;
    

- **Date**: 2007-01-18 22:04:19
- **By**: mymail@com

.. code-block:: text

    Hi, is this integer? Please do not disturb the forum, rather send me an email.
    
    B.i.T

- **Date**: 2007-02-01 16:21:12
- **By**: moc.liamtoh@neslrakevofira

.. code-block:: text

    The line is written like that, so you can change 0.5, to for instance 0.19.

- **Date**: 2007-02-01 16:52:21
- **By**: moc.erehwon@ydobon

.. code-block:: text

    >>The line is written like that, so you can change 0.5, to for instance 0.19.
    
    OK. Why would I do that? What's that number control?

- **Date**: 2007-02-03 15:51:46
- **By**: moc.liamtoh@neslrakevofira

.. code-block:: text

    It controls the patterning. I usually write my algorithms tweakable.
    
    You could try even lower aswell, maybe 1e-19.
    
    

