Stereo Width Control (Obtained Via Transfromation Matrix)
=========================================================

- **Author or source:** Michael Gruhn
- **Type:** Stereo Widener
- **Created:** 2008-03-17 16:54:42


.. code-block:: text
    :caption: notes

    (I was quite surprised that this wasn't already in the archive, so here it is.)
    
    This work is hereby placed in the public domain for all purposes, including use in
    commercial applications.
    
    'width' is the stretch factor of the stereo field:
    width < 1: decrease in stereo width
    width = 1: no change
    width > 1: increase in stereo width
    width = 0: mono


.. code-block:: c++
    :linenos:
    :caption: code

    // calculate scale coefficient
    coef_S = width*0.5;
    
    // then do this per sample
    m = (in_left  + in_right)*0.5;
    s = (in_right - in_left )*coef_S;
    
    out_left  = m - s;
    out_right = m + s;
    

Comments
--------

- **Date**: 2008-04-06 11:32:43
- **By**: ku.oc.oohay@895rennacs

.. code-block:: text

    Nice peace of code. I would add the following code at the end of the source to compensate for the
    loss/gain of amplitude:
    
    out_left  /= 0.5 + coef_S;
    out_right /= 0.5 + coef_S;
    

- **Date**: 2008-04-06 17:40:29
- **By**: -

.. code-block:: text

    Scanner, no I wouldn't add that. First off it is unnecessary calculation you can rescale the MS
    matrix to your liking already! Plus your methode will cause a boost by 6dBs when you set the width
    to 0 = mono. So mono signals get boosted by 6dB which I'm sure isn't what you intented.
    
    Note: My original code is correct that is, when you'd look at an audio signal on a goniometer it
    would scale the audio signal at the S-axis and leaving everything else unaffected.
    
    But as I don't want people that add the additional calculation that scanner requested (sorry not
    trying to mock you), an volume adjusted version.
    
    [code]
    // calc coefs
    tmp = 1/max(1 + width,2);
    coef_M = 1 * tmp;
    coef_S = width * tmp;
    
    // then do this per sample
    m = (in_left + in_right)*coef_M;
    s = (in_right - in_left )*coef_S;
    
    out_left = m - s;
    out_right = m + s;
    [/code]

- **Date**: 2008-04-06 21:42:16
- **By**: ku.oc.oohay@895rennacs

.. code-block:: text

    Hi Michael,
    
    Thanks for the correction, I have build your solution in PureData and it is better than my
    suggestion was. B.t.w. there was already a posting on stereo enhancement on this site, you can
    find it under the effects section.

- **Date**: 2008-04-07 22:47:14
- **By**: -

.. code-block:: text

    Scanner, no problem and yes I've seen the "Stereo Enhancer" entry, though (even though it
    seems to try to achieve the same as this here) it is (as far as I can see) broken.

