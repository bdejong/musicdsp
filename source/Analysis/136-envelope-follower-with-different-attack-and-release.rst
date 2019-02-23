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

.. code-block:: c++

    // the expressions of the form:
    
    xxxx_coef = exp(log(0.01)/( xxxx_in_ms * samplerate * 0.001)); 
    
    // can be simplified a little bit to:
    
    xxxx_coef = pow(0.01, 1.0/( xxxx_in_ms * samplerate * 0.001)); 
    

- **Date**: 2007-07-01 19:05:26
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Here the definition of the attack/release time is the time for the envelope to fall from 100% to 1%.
    In the other version, the definition is for the envelope to fall from 100% to 36.7%. So in this one
    the envelope is about 4.6 times faster.
