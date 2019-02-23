Frequency response from biquad coefficients
===========================================

- **Author or source:** moc.feercinos@retep
- **Type:** biquad
- **Created:** 2004-11-29 09:49:47


.. code-block:: text
    :caption: notes

    Here is a formula for plotting the frequency response of a biquad filter. Depending on the
    coefficients that you have, you might have to use negative values for the b- coefficients.
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    //w = frequency (0 < w < PI)
    //square(x) = x*x
    
    y = 20*log((sqrt(square(a0*square(cos(w))-a0*square(sin(w))+a1*cos(w)+a2)+square(2*a0*cos(w)*sin(w)+a1*(sin(w))))/
    			      sqrt(square(square(cos(w))-   square(sin(w))+b1*cos(w)+b2)+square(2*   cos(w)*sin(w)+b1*(sin(w))))));
    

Comments
--------

- **Date**: 2004-12-20 21:07:20
- **By**: Sergey

.. code-block:: text

    There is a better formula of a higher order by George Yohng available on this site

- **Date**: 2006-03-16 19:36:32
- **By**: ude.drofnats.amrcc@lfd

.. code-block:: text

    this formula can have roundoff errors with frequencies close to zero... (especially a problem with high samplerate filters)
    
    here is a better formula:
    
    from RBJ @ http://groups.google.com/group/comp.dsp/browse_frm/thread/8c0fa8d396aeb444/a1bc5b63ac56b686
    
     20*log10[|H(e^jw)|] =
     10*log10[ (b0+b1+b2)^2 - 4*(b0*b1 + 4*b0*b2 + b1*b2)*phi + 16*b0*b2*phi^2 ]
    -10*log10[ (a0+a1+a2)^2 - 4*(a0*a1 + 4*a0*a2 + a1*a2)*phi + 16*a0*a2*phi^2 ]
    
    where phi = sin^2(w/2)
    

