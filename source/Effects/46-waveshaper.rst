Waveshaper
==========

- **Author or source:** Partice Tarrabia and Bram de Jong
- **Created:** 2002-01-17 02:21:49


.. code-block:: text
    :caption: notes

    amount should be in [-1..1[ Plot it and stand back in astonishment! ;)


.. code-block:: text
    :linenos:
    :caption: code

    x = input in [-1..1]
    y = output
    k = 2*amount/(1-amount);
    
    f(x) = (1+k)*x/(1+k*abs(x))

Comments
--------

- **Date**: 2002-06-27 07:15:59
- **By**: moc.noicratse@ajelak

.. code-block:: text

    I haven't compared this to the other waveshapers, but its behavior with input outside the [-1..1]
    range is interesting. With a relatively moderate shaping amounts which don't distort in-range
    signals severely, it damps extremely out-of-range signals fairly hard, e.g. x = 100,
    k = 0.1 yields y = 5.26; as x goes to infinity, y approaches 5.5. This might come in handy
    to control nonlinear processes which would otherwise be prone to computational blowup.