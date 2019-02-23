Inverted parabolic envelope
===========================

- **Author or source:** James McCartney
- **Type:** envellope generation
- **Created:** 2002-01-17 00:57:43



.. code-block:: c++
    :linenos:
    :caption: code

    dur = duration in samples
    midlevel = amplitude at midpoint
    beglevel = beginning and ending level (typically zero)
    
    amp = midlevel - beglevel;
    
    rdur = 1.0 / dur;
    rdur2 = rdur * rdur;
    
    level = beglevel;
    slope = 4.0 * amp * (rdur - rdur2);
    curve = -8.0 * amp * rdur2;
    
    ...
    
    for (i=0; i<dur; ++i) {
            level += slope;
            slope += curve;
    }

Comments
--------

- **Date**: 2002-04-11 17:20:10
- **By**: ti.orebil@erognekark

.. code-block:: text

    This parabola approximation seems more like a linear than a parab/expo envelope... or i'm mistaking something but i tryed everything and is only linear.

- **Date**: 2002-04-13 23:51:49
- **By**: moc.liamtoh@r0x0r0xe

.. code-block:: text

    slope is linear, but 'slope' is a function of 'curve'. If you imagine you threw a ball upwards, think of 'curve' as the gravity, 'slope' as the vertical velocity, and 'level' as the vertical displacement.

- **Date**: 2005-01-17 07:39:28
- **By**: asynth(at)io(dot)com

.. code-block:: text

    This is not an approximation of a parabola, it IS a parabola.
    This entry has become corrupted since it was first posted. Should be:
    
    for (i=0; i<dur; ++i) {
        out = level;
        level += slope;
        slope += curve;
    }

