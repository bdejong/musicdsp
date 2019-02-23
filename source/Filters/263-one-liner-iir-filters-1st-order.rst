One-Liner IIR Filters (1st order)
=================================

- **Author or source:** moc.edocseira@sirhc
- **Type:** IIR 1-pole
- **Created:** 2009-01-18 10:53:44


.. code-block:: text
    :caption: notes

    Here is a collection of one liner IIR filters.
    Each filter has been transformed into a single C++ expression.
    
    The filter parameter is f or g, and the state variable that needs to be kept around
    between interations is s.
    
    - Christian


.. code-block:: c++
    :linenos:
    :caption: code

        101 Leaky Integrator
    
            a0 = 1
            b1 = 1 - f
    
            out = s += in - f * s;
    
    
        102 Basic Lowpass (all-pole)
    
            A first order lowpass filter, by finite difference appoximation (differentials --> differences).
    
        	a0 = f
    	b1 = 1 - f
    
        	out = s += f * ( in - s );
    
    
        103 Lowpass with inverted control
    
    	Same as above, except for different filter parameter is now inverted.
            In this case, g equals the location of the pole.
    
        	a0 = g - 1
    	b1 = g
    
        	out = s = in + g * ( s - in );
    
    
        104 Lowpass with zero at Nyquist
    
            A first order lowpass filter, by via the conformal map of the z-plane (0..infinity --> 0..Nyquist).
    
            a0 = f
            a1 = f
            b1 = 1 - 2 * f
    
    	s = temp + ( out = s + ( temp = f * ( in - s ) ) );
    
    
        105 Basic Highpass (DC-blocker)
    
            Input complement to basic lowpass, yields a finite difference highpass filter.
    
            a0 = 1 - f
            a1 = f - 1
            b1 = 1 - f
    
            out = in - ( s += f * ( in - s ) );
    
    
        106 Highpass with forced unity gain at Nyquist
    
            Input complement to filter 104, yields a conformal map highpass filter.
    
        	a0 = 1 - f
        	a1 = f - 1
        	b1 = 1 - 2 * f
    
            out = in + temp - ( s += 2 * ( temp = f * ( in - s ) ) );
    
    
        107 Basic Allpass
    
            This corresponds to a first order allpass filter,
            where g is the location of the pole in the range -1..1.
    
            a0 = -g
            a1 = 1
            b1 = g
    
    	s = in + g * ( out = s - g * in );
    
    
    
    
    

Comments
--------

- **Date**: 2016-03-31 14:21:04
- **By**: moc.liamg@1ydarbfmot

.. code-block:: text

    Great help, although could you advise as to where the parameters a0, a1 and b1 are used for the high pass filter 105?
    
    Thanks

