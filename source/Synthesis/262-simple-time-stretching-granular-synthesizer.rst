Simple Time Stretching-Granular Synthesizer
===========================================

- **Author or source:** Harry-Chris
- **Created:** 2008-12-18 07:08:20


.. code-block:: text
    :caption: notes

    Matlab function that implements crude time stretching - granulizing function, by overlap
    add in time domain.


.. code-block:: c++
    :linenos:
    :caption: code

    function y = gran_func(x, w, H,H2, Fs, tr_amount)
    
    
    % x -> input signal
    % w -> Envelope - Window Vector
    % H1 -> Original Hop Size
    % H2 -> Synthesis Hop Size
    % Fs -> Sample Rate
    % str_amount -> time stretching factor
    
    
    M = length(w);
    
    pin = 1;
    pend = length(x) - M;
    
    
    y = zeros(1, floor( str_amount * length(x)) +M);
    
    
    count = 1;
    idx = 1;
    
    while pin < pend 
           
        input = x(pin : pin+M-1) .* w';
    
    
        y(idx : idx + M - 1) = y(idx : idx + M - 1) + input;
    
        pin = pin + H;
        count = count + 1;
        idx = idx + H2;
        
    end
    
    

