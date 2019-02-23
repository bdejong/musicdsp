Chebyshev waveshaper (using their recursive definition)
=======================================================

- **Author or source:** mdsp
- **Type:** chebyshev
- **Created:** 2005-01-10 18:03:29


.. code-block:: text
    :caption: notes

    someone asked for it on kvr-audio.
    
    I use it in an unreleased additive synth.
    There's no oversampling needed in my case since I feed it with a pure sinusoid and I
    control the order to not have frequencies above Fs/2. Otherwise you should oversample by
    the order you'll use in the function or bandlimit the signal before the waveshaper. unless
    you really want that aliasing effect... :)
    
    I hope the code is self-explaining, otherwise there's plenty of sites explaining chebyshev
    polynoms and their applications.
    


.. code-block:: c++
    :linenos:
    :caption: code

    float chebyshev(float x, float A[], int order)
    {
       // To = 1
       // T1 = x
       // Tn = 2.x.Tn-1 - Tn-2
       // out = sum(Ai*Ti(x)) , i C {1,..,order}
       float Tn_2 = 1.0f;
       float Tn_1 = x;
       float Tn;
       float out = A[0]*Tn_1;
    
       for(int n=2;n<=order;n++)
       {
          Tn    =   2.0f*x*Tn_1 - Tn_2;
          out    +=   A[n-1]*Tn;      
          Tn_2 =   Tn_1;
          Tn_1 =  Tn;
       }
       return out;
    } 

Comments
--------

- **Date**: 2005-01-10 18:10:12
- **By**: mdsp

.. code-block:: text

    BTW you can achieve an interresting effect by feeding back the ouput in the input. it adds a kind of interresting pitched noise to the signal.
    
    I think VirSyn is using something similar in microTERA.

- **Date**: 2005-01-11 19:33:03
- **By**: ku.oc.oodanaw.eiretcab@nad

.. code-block:: text

    Hi, it was me that asked about this on KvR. It seems that it is possible to use such a waveshaper on a non-sinusoidal input without oversampling; split the input signal into bands, and use the highest frequency in each band to determine which order polynomials to send each band to. The idea about feeding back the output to the input occured to me as well, good to know that such an effect might be interesting... If I come across any other points of interest while coding this plugin, I'll be glad to mention them on here.
    
    Dan         

- **Date**: 2005-01-12 11:48:00
- **By**: mdsp

.. code-block:: text

    of course you can use it on non sinusoidal input, but you won't achieve the same result.
    
    if you express your input as a sum of sinusoids of frequencies [f0 f1 f2 ...] and use the chebyshev polynom of order 2 you won't have 2*[f0 f1 f2...] as the resulting frequencies.
    As it's a nonlinear function you can't use the superposition theorem anymore.
    
    beware that chebyshev polynoms are sensitive to 
    the range of your input. Your sinusoid has to have a gain exaclty equal to 1 in order to work as expected.
    
    that's a nice trick but it has it's limits.

