VST SDK GUI Switch without
==========================

- **Author or source:** ti.oohay@odrasotniuq
- **Created:** 2004-09-08 12:49:11


.. code-block:: text
    :caption: notes

    In VST GUI an on-vaue is represented by 1.0 and off by 0.0.


.. code-block:: c++
    :linenos:
    :caption: code

    Say you have two signals you want to switch between when the user changes a switch.
    You could do:
    
    if(fSwitch == 0.f) //fSwitch is either 0.0 or 1.0
        output = input1
    else
        output = input2
    
    However, you can avoid the branch by doing:
    
    output = input1 * (1.f - fSwitch) + input2 * fSwitch
    
    Which would be like a quick mix. You could make the change clickless by adding a simple one-pole filter:
    
    smooth = filter(fSwitch)
    output = input1 * (1.f - smooth) + input2 * smooth
    

Comments
--------

- **Date**: 2004-09-17 04:12:08
- **By**: moc.liamg@knuhcnezitic

.. code-block:: text

    Not trying to be incredulous, but ... Is this really worth it? Assuming that you pre-calc the (1-fSwitch), you still have 2 multiplies and 1 add, instead of just an assignment. Are branches really bad enough to justify spending those cycles?
    
    Also, does it matter where in the signal flow the branch is? For instance, if it were at the output, the branch wouldn't be such a problem. But at the input, with many calculations downstream, would it matter more?
    
    Also, what if your branches are much more complicated--i.e. multiple lines per case?

- **Date**: 2004-09-24 17:46:57
- **By**: ti.oohay@odrasotniuq

.. code-block:: text

    I use it when I have to compute the (1-fSwitch) signal anyway.
    Example: apply a LFO to amplitude and not to frequency. I compute LFO anyway, then I apply (1-fSwitch) to frequency and (fSwitch) to amplitude.
    
    Yes, branches are really bad!:-)
    This is because you "break" your cache waiting for a decision
    Even if the branch is at the end of your routine, you are leaving a branch to successive code (i.e. to host)
    
    Anyway, this is not ever worth to use, just consider single cases...

- **Date**: 2004-10-07 03:29:01
- **By**: moc.noicratse@ajelak

.. code-block:: text

    Kids, kids, you're both wrong!
    
    chunk: Two multiples and an add are really cheap on modern hardware - P2/P3 take about 2 clocks for fmul and 1 clock for fadd.
    
    quintosardo: Modern hardware also has good branch prediction, so if the switch is, e.g., a VST parameter that only changes once per process() block, it will branch the same way on the order of 100 times in a row. Correcly predicted branches are basically free; mispredicted branches blow the instruction pipeline, which is a penalty of about 20 cycles or so. If you spread the cost of a single missed prediction over 100 samples, it's cheap enough to not worry about. So yes, use this "predicate transform" to optimize away branches which are unpredictable, but don't worry about branches which are predictable. 

- **Date**: 2014-02-07 08:22:56
- **By**: ten.rotaniliam@akcalabbuh

.. code-block:: text

    And today it is even more ridiculous to think about cycles! 

