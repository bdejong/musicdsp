Envelope follower with different attack and release
===================================================

- **Author or source:** Bram
- **Created:** 2003-01-15 00:21:39


.. code-block:: text
    :caption: notes

    xxxx_in_ms is xxxx in milliseconds ;-)


.. code-block:: c++
    :linenos:
    :caption: code

    init::
    
    attack_coef = exp(log(0.01)/( attack_in_ms * samplerate * 0.001));
    release_coef = exp(log(0.01)/( release_in_ms * samplerate * 0.001));
    envelope = 0.0;
    
    loop::
    
    tmp = fabs(in);
    if(tmp > envelope)
        envelope = attack_coef * (envelope - tmp) + tmp;
    else
        envelope = release_coef * (envelope - tmp) + tmp;

Comments
--------

- **Date**: 2003-01-18 20:56:46
- **By**: kd.utd.xaspmak@mj

.. code-block:: text

    the expressions of the form:
    
    xxxx_coef = exp(log(0.01)/( xxxx_in_ms * samplerate * 0.001)); 
    
    can be simplified a little bit to:
    
    xxxx_coef = pow(0.01, 1.0/( xxxx_in_ms * samplerate * 0.001)); 
    

- **Date**: 2003-03-28 10:50:36
- **By**: moc.liamtoh@trahniak

.. code-block:: text

    Excuse me if I'm asking a lame question but is the envelope variable the output for the given input sample? Also would this algorithm apply to each channel independently for a stereo signal? One more question what is an Envelope Follower, what does it sound like?

- **Date**: 2003-10-23 02:56:10
- **By**: moc.liamtoh@gnaiquynay

.. code-block:: text

    What's the difference between this one and the one you posted named 'Envelope detector'? Different definiton? What's the exact definition of release time and attack time?

- **Date**: 2007-07-01 19:05:26
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Here the definition of the attack/release time is the time for the envelope to fall from 100% to 1%. In the other version, the definition is for the envelope to fall from 100% to 36.7%. So in this one the envelope is about 4.6 times faster.

- **Date**: 2015-01-13 01:56:39
- **By**: moc.liamg@kazrteiptd

.. code-block:: text

    What if you want 0ms attack with > 0ms release? 0ms attack in the current equation results in attack_coef = exp ( log(0.01) / 0 ) ) which is not a number due to the division by 0. Would using attack_coef = 0 instead result in an accurate algorithm? 
    
    Thanks.

