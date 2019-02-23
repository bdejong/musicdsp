PRNG for non-uniformly distributed values from trigonometric identity
=====================================================================

- **Author or source:** moc.liamg@321tiloen
- **Type:** pseudo-random number generator
- **Created:** 2009-09-02 07:16:14


.. code-block:: text
    :caption: notes

    a method, which generates random numbers in the [-1,+1] range, while having a probability
    density function with less concentration of values near zero for sin().
    you can use an approximation of sin() and/or experiment with such an equation for
    different distributions. using tan() will accordingly invert the pdf graph i.e. more
    concentration near zero, but the output range will be also affected.
    
    extended read on similar methods:
    http://www.stat.wisc.edu/~larget/math496/random2.html
    
    regards
    lubomir


.. code-block:: c++
    :linenos:
    :caption: code

    //init
    x=y=1;
    
    //sampleloop
    y=sin((x+=1)*y);
    

