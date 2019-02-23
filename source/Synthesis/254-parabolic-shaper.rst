Parabolic shaper
================

- **Author or source:** rf.eerf@aipotreza
- **Created:** 2008-03-13 10:41:18


.. code-block:: text
    :caption: notes

    This function can be used for oscillators or shaper.
    it can be driven by a phase accumulator or an audio input.
    


.. code-block:: c++
    :linenos:
    :caption: code

    Function Parashape(inp:single):single;
    var fgh,tgh:single;
    begin
    fgh    := inp ;
    fgh    := 0.25-f_abs(fgh) ;
    tgh    := fgh ;
    tgh    := 1-2*f_abs(tgh);
    fgh    := fgh*8;
    result := fgh*tgh ;
    end;
    // f_abs is the function of ddsputils unit.

