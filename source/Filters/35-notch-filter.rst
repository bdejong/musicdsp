Notch filter
============

- **Author or source:** Olli Niemitalo
- **Type:** 2 poles 2 zeros IIR
- **Created:** 2002-01-17 02:11:07


.. code-block:: text
    :caption: notes

    Creates a muted spot in the spectrum with adjustable steepness. A complex conjugate pair
    of zeros on the z- plane unit circle and neutralizing poles approaching at the same angles
    from inside the unit circle.


.. code-block:: c++
    :linenos:
    :caption: code

    Parameters:
    0 =< freq =< samplerate/2
    0 =< q < 1 (The higher, the narrower)
    
    AlgoAlgo=double pi = 3.141592654;
    double sqrt2 = sqrt(2.0);
    
    double freq = 2050; // Change! (zero & pole angle)
    double q = 0.4;     // Change! (pole magnitude)
    
    double z1x = cos(2*pi*freq/samplerate);
    double a0a2 = (1-q)*(1-q)/(2*(fabs(z1x)+1)) + q;
    double a1 = -2*z1x*a0a2;
    double b1 = -2*z1x*q;
    double b2 = q*q;
    double reg0, reg1, reg2;
    
    unsigned int streamofs;
    reg1 = 0;
    reg2 = 0;
    
    /* Main loop */
    for (streamofs = 0; streamofs < streamsize; streamofs++)
    {
      reg0 = a0a2 * ((double)fromstream[streamofs]
                     + fromstream[streamofs+2])
           + a1 * fromstream[streamofs+1]
           - b1 * reg1
           - b2 * reg2;
    
      reg2 = reg1;
      reg1 = reg0;
    
      int temp = reg0;
    
      /* Check clipping */
      if (temp > 32767) {
        temp = 32767;
      } else if (temp < -32768) temp = -32768;
    
      /* Store new value */
      tostream[streamofs] = temp;
    }

Comments
--------

- **Date**: 2006-09-27 09:53:49
- **By**: moc.liamtoh@18recnuor

.. code-block:: text

    i tried implementing it, failed,
    and its wierd how it looks further in time
    instead of backwards, you cant use it in
    a running rendered stream cause the end of
    it stuffs up....

- **Date**: 2006-09-27 11:43:49
- **By**: musicdsp@Nospam dsparsons.co.uk

.. code-block:: text

    I think it's a type, and should be
    =-=-=
    reg0 = a0a2 * ((double)fromstream[streamofs]
    + fromstream[streamofs-2])
    + a1 * fromstream[streamofs-1]
    - b1 * reg1
    - b2 * reg2;
    =-=-=
    In which case there is some rangechecking to be done when streamofs<2
    
    You could just use the coeffs, and stick them into whatever biquad code you have hanging around :)
    
    DSP

- **Date**: 2007-02-17 10:44:00
- **By**: moc.loa@561kluafla

.. code-block:: text

      Still doesn't work. Either way its looking one each side of a centre value, so it doesn't change the maths. Not sure what the code should be. Ideas???            

- **Date**: 2009-04-24 16:34:32
- **By**: moc.liamg@naecohsife

.. code-block:: text

    does this code work with float output?
    I really need a notch filter, i will try the code.

- **Date**: 2011-05-12 11:22:57
- **By**: moc.oohay@skinyela

.. code-block:: text

    yes, there are some errors in this source.
    
    Here is the correct version:
    
    
    // (C) Sergey Aleynik.   aleyniks@yahoo.com
       
         // BW_Coeff is changing from 0.0 to 1.0 (excluded) and the more the narrow:
         // |  BW_Coeff   |  Real BandWidth (approxim.)  |
         // |   0.975     | 0.00907 * Sampling_Frequency |
         // |   0.95      | 0.01814 * Sampling_Frequency |
         // |   0.9       | 0.03628 * Sampling_Frequency |
    
    void  Notch_Filter_Test(short int *Data_In, 
                            short int *Data_Out, 
                            long       nData_Length,
                            double     Sampling_Frequency,
                            double     CutOff_Frequency,
                            double     BW_Coeff) 
    {
      // If wrong parameters:
      if((NULL == Data_In)||(Data_Out)||(nData_Length <= 0))   return;
      if((Sampling_Frequency < 0.0)||(CutOff_Frequency < 0.0)) return;
      if(CutOff_Frequency > (Sampling_Frequency/2))            return;
      if((BW_Coeff <= 0.0)||(BW_Coeff >= 1.0))                 return; 
    
      static const double  pi = 3.141592654; 
    
      // Filter coefficients:
      double z1x = cos(2*pi*CutOff_Frequency/Sampling_Frequency); 
      double b0 = (1-BW_Coeff)*(1-BW_Coeff)/(2*(fabs(z1x)+1)) + BW_Coeff; 
      double b2 = b0;
      double b1 = -2*z1x*b0; 
      double a1 = -2*z1x*BW_Coeff; 
      double a2 = BW_Coeff*BW_Coeff; 
    
      // Filter internal vars:
      double y=0,  y1=0, y2=0; 
      double x0=0, x1=0, x2=0; 
    
      long i;
      for(i=0; i<nData_Length; i++)
      {
        y  = b0 * x0 + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2; 
        y2 = y1; 
        y1 = y;
        x2 = x1;
        x1 = x0;
        x0 = Data_In[i];
    
        if(      y >  32767) y =  32767;
        else if (y < -32768) y = -32768;
    
        Data_Out[i] = (short int)y;
      }
    } 
    
    

- **Date**: 2011-11-11 03:30:26
- **By**: rf.liamtoh@abe.yrduabreivilo

.. code-block:: text

    Just an idea on coef notch : 
     a0 = 1;
     a1 = -2 * cs;
    a2 = 1;
    b0 = 1 + alpha;
    b1 = -2 * cs;
    b2 = 1 - alpha;
     notch: H(s) = (s^2 + 1) / (s^2 + s/Q + 1);
     omega = 2*PI*cf/sample_rate;
    sn = sin(omega);
    cs = cos(omega);
    alpha = sn/(2*Q);
    

