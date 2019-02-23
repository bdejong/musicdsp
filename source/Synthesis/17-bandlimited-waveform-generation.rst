Bandlimited waveform generation
===============================

- **Author or source:** Joe Wright
- **Type:** waveform generation
- **Created:** 2002-01-17 01:06:49

- **Linked files:** :download:`bandlimited.cpp <../files/bandlimited.cpp>`.
- **Linked files:** :download:`bandlimited.pdf <../files/bandlimited.pdf>`.

.. code-block:: text
    :caption: notes

    (see linkfile)



Comments
--------

- **Date**: 2012-02-10 16:26:11
- **By**: ed.redienhcsslin@psdcisum

.. code-block:: text

    The code to reduce the gibbs effect causes aliasing if a transition is made from wavetable A with x partials to wavetable B with y partials.
    
    The aliasing can clearly be seen in a spectral view.
    
    The problem is, that the volume modification for partial N is different depending on the number of partials the wavetable row contains
    

