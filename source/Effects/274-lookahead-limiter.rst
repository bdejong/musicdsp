Lookahead Limiter
=================

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** Limiter
- **Created:** 2009-11-16 08:45:47


.. code-block:: text
    :caption: notes

    I've been thinking about this for a long time and this is the best I came up with so far.
    I might be all wrong, but according to some simulations this looks quite nice (as I want
    it to be).
    
    The below algorithm is written in prosa. It's up to you to transfer it into code.


.. code-block:: c++
    :linenos:
    :caption: code

    Ingredients:
    ------------
    
    1 circular buffers (size of the look ahead time)
    2 circular buffers (half the size of the look ahead time)
    4 parameters ('Lookahead Time [s]', 'Input Gain [dB]', 'Output Gain [dB]' and 'Release Time [s])
    a handfull state variables
    
    Recipe:
    -------
    
    0. Make sure all buffers are properly initialized and do not contain any dirt (pure zeros are what
    we need).
    
    For each sample do the following procedure:
    
    1. Store current sample in the lookahead time circular buffer, for later use (and retrieve the value
    that falls out as the preliminary 'Output')
    
    2. Find maximum within this circular buffer. This can also be implemented efficiently with an hold
    algorithm.
    
    3. Gain this maximum by the 'Input Gain [dB]' parameter
    
    4. Calculate necessary gain reduction factor (=1, if no gain reduction takes place and <1 for any
    signal above 0 dBFS)
    
    5. Eventually subtract this value from 1 for a better numerical stability. (MUST BE UNDONE LATER!)
    
    6. Add this gain reduction value to the first of the smaller circular buffers to calculate the short
    time sum (add this value to a sum and subtract the value that felt out of the circular buffer).
    
    7. normalize the sum by dividing it by the length of the circular buffer (-> / ('Lookahead Time'
    [samples] / 2))
    
    8. repeat step 6 & 7 with this sum in the second circular buffer. The reason for these steps is to
    transform dirac impulses to a triangle (dirac -> rect -> triangle)
    
    9. apply the release time (release time -> release slew rate 'factor' -> multiply by that factor) to
    the 'Maximum Gain Reduction' state variable
    
    10. check whether the currently calculated gain reduction is higher than the 'Maximum Gain Reduction'.
    If so, replace!
    
    11. eventually remove (1 - x) from step 5 here
    
    12. calculate effective gain reduction by the above value gained by input and output gain.
    
    13. Apply this gain reduction to the preliminary 'Output' from step 1
    
    Repeat the above procedure (step 1-13) for all samples!

