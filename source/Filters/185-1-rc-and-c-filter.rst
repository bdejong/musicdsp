1-RC and C filter
=================

- **Author or source:** ac.nortoediv@niarbdam
- **Type:** Simple 2-pole LP
- **Created:** 2004-11-14 22:42:18


.. code-block:: text
    :caption: notes

    This filter is called 1-RC and C since it uses these two parameters. C and R correspond to
    raw cutoff and inverted resonance, and have a range from 0 to 1.
    


.. code-block:: c++
    :linenos:
    :caption: code

    //Parameter calculation
    //cutoff and resonance are from 0 to 127
    
      c = pow(0.5, (128-cutoff)   / 16.0);
      r = pow(0.5, (resonance+24) / 16.0);
    
    //Loop:
    
      v0 =  (1-r*c)*v0  -  (c)*v1  + (c)*input;
      v1 =  (1-r*c)*v1  +  (c)*v0;
    
      output = v1;
    

Comments
--------

- **Date**: 2005-01-13 18:25:57
- **By**: yes

.. code-block:: text

    input is not in 0 - 1 range.
    
    for cutoff i guess 128.
    
    for reso the same ?

- **Date**: 2006-08-31 14:28:33
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Nice. This is very similar to a state variable filter in many ways. Relationship between c and frequency:
    
    c = 2*sin(pi*freq/samplerate)
    
    You can approximate this (tuning error towards nyquist):
    
    c = 2*pi*freq/samplerate
    
    Relationship between r and q factor:
    
    r = 1/q
    
    This filter has stability issues for high r values. State variable filter stability limits seem to work fine here. It can also be oversampled for better stability and wider frequency range (use 0.5*original frequency):
    
    //Loop:
    
    v0 = (1-r*c)*v0 - c*v1 + c*input;
    v1 = (1-r*c)*v1 + c*v0;
    tmp = v1;
    
    v0 = (1-r*c)*v0 - c*v1 + c*input;
    v1 = (1-r*c)*v1 + c*v0;
    output = (tmp+v1)*0.5;
    
    -- peter schoffhauzer
    

