Stereo Field Rotation Via Transformation Matrix
===============================================

- **Author or source:** Michael Gruhn
- **Type:** Stereo Field Rotation
- **Created:** 2008-03-17 09:40:10


.. code-block:: text
    :caption: notes

    This work is hereby placed in the public domain for all purposes, including use in
    commercial applications.
    
    'angle' is the angle by which you want to rotate your stereo field.


.. code-block:: c++
    :linenos:
    :caption: code

    // Calculate transformation matrix's coefficients
    cos_coef = cos(angle);
    sin_coef = sin(angle);
    
    // Do this per sample
    out_left  = in_left * cos_coef - in_right * sin_coef;
    out_right = in_left * sin_coef + in_right * cos_coef;
    

Comments
--------

- **Date**: 2008-10-07 19:56:47
- **By**: moc.liamtoh@iniluigj

.. code-block:: text

    This looks like the rotation formula for a point in space. Can you explain how does it work
    for a sound signal? Let's say that angle is 90 degrees, then you formula gives
    out_left = -in_right
    out_right = in_left
    How would this be a 90 deg rotation of the sound?

- **Date**: 2008-10-15 12:16:02
- **By**: Foo

.. code-block:: text

    It IS the exact formula as rotation for a point in a 2D space (around its origin). Now this is
    applied to the stereo field. Imagine it as a left-right plot, so the values of the left and right
    channel get plotted (just like a goniometer: http://en.wikipedia.org/wiki/Goniometer_(audio)).
    So now you can see the stereo image (mono = straight line, stereo = circle, etc...). Now when you
    rotate THIS plot and then use the values of the rotated plot for the new left and right sample
    values, you rotated the stereo image.
    So just get a goniometer and look at how the signal changes when you run it through the algorithm,
    it will be pretty obvious.
    
    Hope this helps.

- **Date**: 2008-11-16 02:13:27
- **By**: Bar

.. code-block:: text

    Sorry this makes no sense at all. The rotation formula is predicated on the assumption that
    (x,y) are coordinates of two orthogonal dimensions. Now you can choose to visualize stereo
    signals anyway you like, including being on a Cartesian plan, or as polar coordinates, what have
    you... But this visualization has no relationship to the physical location of the sound. The left
    and right channels are NOT orthogonal dimensions physically. What the formula does is just some
    weird panning. As the previous comment pointed out, just plug in some easy angles like 90, 180 ...
    and see if you can make any valid interpretations out of them. You can't.

- **Date**: 2008-11-18 21:22:49
- **By**: Foo

.. code-block:: text

    So you want mathematical prove? Even though I consider this childish, because it'd take you <5
    minutes to put this in Matlab or any other DSP prototyping bench and hear the rotation effect for
    yourself. Anyway ...
    
    For 180° the output should be totally inverted. So:
    cos(180) = -1
    sin(180) =  0
    out_left = -in_left
    out_right = -in_right
    
    at 90° this means for a mono signal that the left channel will be a phase inverse of the right
    channel, so ... go directly to result, do not calculate:
    out_left = -in_right
    out_right = in_left
    
    at 45° is just like hard panning to the right (with a 3dB volume attenuation), so for a mono
    signal the expected results would be one channel silence and the other would have the signal,
    so we calculate:
    cos(45) = sqrt(2)/2
    sin(45) = sqrt(2)/2
    for mono signal we assume: mono = in_left = in_right ... so it follows:
    out_left = mono * sqrt(2)/2 - mono * sqrt(2)/2 = 0
    out_right = mono * sqrt(2)/2 + mono * sqrt(2)/2 = mono * sqrt(2) == mono * 3dB
    
    and one more, 360° means same output as input, calculate for yourself.
    
    Valid enough?

- **Date**: 2008-11-20 20:18:24
- **By**: Bar

.. code-block:: text

    Then I'm not sure what you mean by rotation. In my mind, I see two sound sources at arbitrary
    locations and I'm at the center of rotation. So the effect of a rotation would depend on the
    angle subtended by the three points to begin with, which doesn't even show up in the formula.
    Also please explains what does it mean by the two channels being orthogonal dimensions, which
    is what the formula is based on. (I assume you understand the mathematical basis of how the
    formula is derived.)
    
    No, a phase inversion on both channels don't sound 180 deg rotated. It sounds exactly the same
    as before.
    

- **Date**: 2008-11-20 21:27:25
- **By**: Bar

.. code-block:: text

    Let's try another experiment. You're in the midpoint of the line joining the two speakers and is
    the center of rotation. Your signal happens to have all zeros for the left channel. The formula
    simplifies to:
    out_left = -in_right * sin
    out_right = in_right * cos
    As you rotate from 0 to 90, sin goes from 0 to 1, cos goes from 1 to 0. So the formula predicts
    that the left channel goes from silence to a phase inverted right, and the right channel goes from
    full sound to silence. Whereas physically the sound should move from my right to directly in front of
    me. Please explain.

- **Date**: 2008-11-20 21:36:54
- **By**: Bar

.. code-block:: text

    Yet another childish thought. If one can treat signals as if they were space locations, then surely
    translations will work just as well as rotations. So to move a sound source to another location,
    one just add constants to the signals?

- **Date**: 2008-11-23 18:10:37
- **By**: Foo

.. code-block:: text

    If the source would be dead center a 180° rotation would mean the source would be behind you,
    but since in stereo there is no front or behind (just left and right), behind gets indicated by
    phase reversal (I know it doesn't reflect the position, but you can't because there is only left
    and right).
    Also the rotation is clockwise, so a positive angles shift the source to the right, which means
    for your example if you'd rotate from 0° to -90° you'd indeed get the signal one the left channel
    and the right blank. For a mono signal (both channels identical that is) and a rotation range of
    -45° to 45° is the same as panning (with a 0dB pan law).
    
    But I'll admit I was totally wrong and this entry in the musicdsp is the most faultiest that there
    ever was and isn't going to be useful at all, to no one.
    Anyway if this is not stereo field rotation, how would YOU call it? I'd happily forward the new
    terminology to the siteadmin, so the entries' description can be changed as soon as possible to
    whatever you think it is.
    
    I'm just glad that I'm not the only one that is using wrong terminology, e.g. the Waves S1-Imager's
    "Rotation" does the same as the above posted code, as does Nick Whitehurst's c_superstereo and
    others ...
    
    So tell me what it is called and I'll see if I can get the name changed, so everyone can be happy.
    Though I doubt I can get Waves nor any audio engineers to also adapt the new, correct terminology,
    that you will proved, for this kind of effect.
    
    BTW if you want to discuss this further please mail to: 1337foo42bar69@trashmail.net because there
    is no need to waste more comment space about this (I now think or at least hope that it only is a ...)
    terminology discussion, because there is nothing wrong with the code itself I posted, or is there?

- **Date**: 2009-07-17 11:02:36
- **By**: null

.. code-block:: text

    Waves S1 Rotation, as you said, does exactly this. It is stereo field rotation, but in the same
    way could be considered panning.
    
    Thanks a lot for the useful code, it will be put to good use. :)

- **Date**: 2014-03-28 12:52:38
- **By**: moc.liamg@nabihci.nasleinad

.. code-block:: text

    I just tried this out but as you rotate the field there are points where the field is flattened
    to become simply a mono signal rotated. visualize the output on a x/y vectorscope and perform the
    roation to see what I mean.  
    
    I made a correction.  The algorithm should be like this:
    
    r = rotation_angle
    
    out_left   = (in_left *  cos(r))  - (in_right * sin(r + pi));
    out_right = (in_left * -sin(r)) - (in_right * cos(r + pi));

- **Date**: 2014-06-17 22:51:38
- **By**: moc.liamg@jdcisumff

.. code-block:: text

    Why are you adding pi to the sin and cos at the end? 
    
    What will adding 3.14 to the rotation do besides move the rotation angle further 3.14? IE if rotation
    angle is 90, you're just adding 3.14 to it  equaling 93.14. Why only to the right channel? Shouldn't
    that cause problems?
    
    Wouldn't that mean that the reason this wont sound flat is because the calculations are 3.14 off?                

