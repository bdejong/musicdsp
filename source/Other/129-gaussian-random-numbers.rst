Gaussian random numbers
=======================

- **Author or source:** ed.bew@raebybot
- **Type:** random number generation
- **Created:** 2002-12-16 19:01:01


.. code-block:: text
    :caption: notes

    // Gaussian random numbers
    // This algorithm (adapted from "Natur als fraktale Grafik" by
    // Reinhard Scholl) implements a generation method for gaussian
    // distributed random numbers with mean=0 and variance=1
    // (standard gaussian distribution) mapped to the range of
    // -1 to +1 with the maximum at 0.
    // For only positive results you might abs() the return value.
    // The q variable defines the precision, with q=15 the smallest
    // distance between two numbers will be 1/(2^q div 3)=1/10922
    // which usually gives good results.
    
    // Note: the random() function used is the standard random
    // function from Delphi/Pascal that produces *linear*
    // distributed numbers from 0 to parameter-1, the equivalent
    // C function is probably rand().


.. code-block:: c++
    :linenos:
    :caption: code

    const q=15;
          c1=(1 shl q)-1;
          c2=(c1 div 3)+1;
          c3=1/c1;
    
    function GRandom:single;
    begin
     result:=(2*(random(c2)+random(c2)+random(c2))-3*(c2-1))*c3;
    end;
    

