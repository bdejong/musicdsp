Lo-Fi Crusher
=============

- **Author or source:** David Lowenfels
- **Type:** Quantizer / Decimator with smooth control
- **Created:** 2003-04-01 15:34:40


.. code-block:: text
    :caption: notes

    Yet another bitcrusher algorithm. But this one has smooth parameter control.
    
    Normfreq goes from 0 to 1.0; (freq/samplerate)
    Input is assumed to be between 0 and 1.
    Output gain is greater than unity when bits < 1.0;


.. code-block:: matlab
    :linenos:
    :caption: code

    function output = crusher( input, normfreq, bits );
        step = 1/2^(bits);
        phasor = 0;
        last = 0;
    
        for i = 1:length(input)
           phasor = phasor + normfreq;
           if (phasor >= 1.0)
              phasor = phasor - 1.0;
              last = step * floor( input(i)/step + 0.5 ); %quantize
           end
           output(i) = last; %sample and hold
        end
    end

Comments
--------

- **Date**: 2004-06-16 21:10:39
- **By**: moc.liamtoh@132197kk

.. code-block:: text

    what's the "bits" here? I tried to run the code, it seems it's a dead loop here, can not
    figure out why

- **Date**: 2005-10-26 23:25:13
- **By**: dfl

.. code-block:: text

    bits goes from 1 to 16

- **Date**: 2016-03-19 02:47:47
- **By**: moc.liamg@tnemniatretnEesneS2

.. code-block:: text

    I'm having trouble with the code as well. Is there something I'm missing?

