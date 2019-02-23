Simple biquad filter from apple.com
===================================

- **Author or source:** moc.liamg@321tiloen
- **Type:** LP
- **Created:** 2008-10-27 10:15:16


.. code-block:: text
    :caption: notes

    Simple Biquad LP filter from the AU tutorial at apple.com


.. code-block:: c++
    :linenos:
    :caption: code

    //cutoff_slider range 20-20000hz
    //res_slider range -25/25db
    //srate - sample rate
    
    //init
    mX1 = 0;
    mX2 = 0;
    mY1 = 0;
    mY2 = 0;
    pi = 22/7;
    
    //coefficients
    cutoff = cutoff_slider;
    res = res_slider;
    
    cutoff = 2 * cutoff_slider / srate;
    res = pow(10, 0.05 * -res_slider);
    k = 0.5 * res * sin(pi * cutoff);
    c1 = 0.5 * (1 - k) / (1 + k);
    c2 = (0.5 + c1) * cos(pi * cutoff);
    c3 = (0.5 + c1 - c2) * 0.25;
        
    mA0 = 2 * c3;
    mA1 = 2 * 2 * c3;
    mA2 = 2 * c3;
    mB1 = 2 * -c2;
    mB2 = 2 * c1;
    
    //loop
    output = mA0*input + mA1*mX1 + mA2*mX2 - mB1*mY1 - mB2*mY2;
    
    mX2 = mX1;
    mX1 = input;
    mY2 = mY1;
    mY1 = output;

Comments
--------

- **Date**: 2009-03-05 13:44:24
- **By**: moc.liamg@321tiloen

.. code-block:: text

    here are coefficients for the hp version.
    the br,bp & peak are also easy to calculate:
    
    k = 0.5*res*sin(pi*cutoff);
    c1 = 0.5*(1-k)/(1+k);
    c2 = (0.5+c1)*cos(pi*cutoff);
    c3 = (0.5+c1+c2)*0.25;
    
    a0 = 2*c3;
    a1 = -4*c3;
    a2 = 2*c3;
    b1 = -2*c2;
    b2 = 2*c1;
    
    if you wish to create a cascade, use the this:
    
    //----sample loop
    
    //mem: buffer array
    //N: number of biquads, n=4 -> 48dB/oct
    
    //set input here 
    
    for (i=0;i<N;i++) {
    output = a0 * input + a1 * mem[4*i+1] + a2 * mem[4*i+2] - b1 * mem[4*i+3] - b2 * mem[4*i+4];
    mem[4*i+2] = mem[4*i+1];
    mem[4*i+1] = input;
    mem[4*i+4] = mem[4*i+3];
    mem[4*i+3] = output;
    );
    
    //----sample loop

- **Date**: 2009-04-20 11:44:26
- **By**: moc.liamg@321tiloen

.. code-block:: text

    i've missed a line:
    
    ===========================
    mem[4*i+3] = output;
    
    //>>> insert here
    input = output;
    //>>> insert here
    
    );
    //----sample loop
    ===========================
    
    lubomir

