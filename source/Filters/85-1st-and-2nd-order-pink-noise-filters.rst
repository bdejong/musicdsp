1st and 2nd order pink noise filters
====================================

- **Author or source:** moc.regnimmu@regnimmu
- **Type:** Pink noise
- **Created:** 2004-04-07 09:36:23


.. code-block:: text
    :caption: notes

    Here are some new lower-order pink noise filter coefficients.
    
    These have approximately equiripple error in decibels from 20hz to 20khz at a 44.1khz
    sampling rate.
    
    1st order, ~ +/- 3 dB error (not recommended!)
    num = [0.05338071119116  -0.03752455712906]
    den = [1.00000000000000  -0.97712493947102]
    
    2nd order, ~ +/- 0.9 dB error
    num = [ 0.04957526213389  -0.06305581334498   0.01483220320740 ]
    den = [ 1.00000000000000  -1.80116083982126   0.80257737639225 ]



