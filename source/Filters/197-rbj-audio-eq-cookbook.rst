RBJ Audio-EQ-Cookbook
=====================

- **Author or source:** Robert Bristow-Johnson
- **Type:** EQ filter kookbook
- **Created:** 2005-05-04 20:31:18

- **Linked files:** :download:`Audio-EQ-Cookbook.txt <../files/Audio-EQ-Cookbook.txt>`.

.. code-block:: text
    :caption: notes

    Equations for creating different equalization filters.
    see linked file



Comments
--------

- **Date**: 2006-08-30 22:14:22
- **By**: ude.odu@grebnesie.nitram

.. code-block:: text

    rbj writes with regard to shelving filters:
    
    > _or_ S, a "shelf slope" parameter (for shelving EQ only).  When S = 1,
    > the shelf slope is as steep as it can be and remain monotonically
    > increasing or decreasing gain with frequency.  The shelf slope, in
    > dB/octave, remains proportional to S for all other values for a
    > fixed f0/Fs and dBgain.
    
    The precise relation for both low and high shelf filters is
    
      S = -s * log_2(10)/40 * sin(w0)/w0 * (A^2+1)/(A^2-1)
      
    where s is the true shelf midpoint slope in dB/oct and w0, A are defined in
    the Cookbook just below the quoted paragraph. It's your responsibility to keep
    the overshoots in check by using sensible s values. Also make sure that s has
    the right sign -- negative for low boost or high cut, positive otherwise.
    
    To find the relation I first differentiated the dB magnitude response of the
    general transfer function in eq. 1 with regard to log frequency, inserted the
    low shelf coefficient expressions, and evaluated at w0. Second, I equated this
    derivative to s and solved for alpha. Third, I equated the result to rbj's
    expression for alpha and solved for S yielding the above formula. Finally
    I checked it with the high shelf filter.

- **Date**: 2006-08-31 17:08:27
- **By**: ude.odu@grebnesie.nitram

.. code-block:: text

    Sorry, a slight correction: rewrite the formula as
    
      S = s * log_2(10)/40 * sin(w0)/w0 * (A^2+1)/abs(A^2-1)
    
    nad make s always positive.

- **Date**: 2013-10-05 18:06:20
- **By**: moc.liamg@56rekojbm

.. code-block:: text

    This is a very famous article. I saw many are asking what is the relationship between "Q" and the resonance in low-pass and hi-pass filters.
    
    By experimenting, I found that Q should always be >= 1/2. Value < 1/2 seems to alter f0 "wherever it's happenin', man", cutting off frequencies not where it was planned. In fact Q = 1/2 is the value for which H(s) = 1 / (s^2 + s/Q + 1) gets two poles, real and coincident. In other words the filter becomes like two 1st order filters in cascade, with no resonance at all.
    
    When Q tends to infinite the poles get close to the unit circle, the gain around the cutoff frequency increases, creating resonance.
    

