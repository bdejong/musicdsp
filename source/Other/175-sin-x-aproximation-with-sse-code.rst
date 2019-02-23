Sin(x) Aproximation (with SSE code)
===================================

- **Author or source:** moc.kisuw@kmailliw
- **Created:** 2004-07-14 10:13:26


.. code-block:: text
    :caption: notes

    Sin Aproximation: sin(x) = x + ( x * (-x * x / 6));
    
    This is very handy and fast, but not precise. Below you will find a simple SSE code.
    
    Remember that all movaps command requires 16 bit aligned variables.
    


.. code-block:: c++
    :linenos:
    :caption: code

    SSE code for computing only ONE value (scalar)
    Replace all "ss" with "ps" if you want to calculate 4 values. And instead of "movps" use "movaps".
    
    movss	xmm1,	xmm0						; xmm0 = x
    mulss	xmm1,	Filter_GenVal[k_n1]			; * -1
    mulss	xmm1,	xmm0						; -x * x
    divss	xmm1,	Filter_GenVal[k_6]			; / 6
    mulss	xmm1,	xmm0
    addss	xmm0,	xmm1

Comments
--------

- **Date**: 2004-10-06 22:47:58
- **By**: moc.noicratse@ajelak

.. code-block:: text

    Divides hurt. Change your constant 6 to a constant (1.0/6.0) and change divss to mulss.
    

- **Date**: 2005-05-31 05:04:05
- **By**: little%moc.loa@ykee02

.. code-block:: text

    error about 7.5% by +/- pi/2
    you can improve this considerably by
    fitting cubic at points -pi/2, 0, pi/2 i.e: 
    sin(x) = x - x^3 / 6.7901358

