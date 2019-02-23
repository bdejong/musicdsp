LPF 24dB/Oct
============

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** Chebyshev
- **Created:** 2006-07-28 17:58:33



.. code-block:: c++
    :linenos:
    :caption: code

    First calculate the prewarped digital frequency: 
    
    K = tan(Pi * Frequency / Samplerate); 
    
    Now we calc some Coefficients: 
    
    sg = Sinh(PassbandRipple); 
    cg = Cosh(PassbandRipple);
    cg *= cg;
    
    Coeff[0] = 1 / (cg-0.85355339059327376220042218105097);
    Coeff[1] = K * Coeff[0]*sg*1.847759065022573512256366378792;
    Coeff[2] = 1 / (cg-0.14644660940672623779957781894758);
    Coeff[3] = K * Coeff[2]*sg*0.76536686473017954345691996806;
    
    K *= K; // (just to optimize it a little bit) 
    
    Calculate the first biquad: 
    
    A0 =   (Coeff[1]+K+Coeff[0]);
    A1 = 2*(Coeff[0]-K)*t;
    A2 =   (Coeff[1]-K-Coeff[0])*t;
    B0 = t*K;
    B1 = 2*B0;
    B2 = B0;
    
    Calculate the second biquad: 
    
    A3 =   (Coeff[3]+K+Coeff[2]);
    A4 = 2*(Coeff[2]-K)*t;
    A5 =   (Coeff[3]-K-Coeff[2])*t;
    B3 = t*K;
    B4 = 2*B3;
    B5 = B3;
    
    Then calculate the output as follows: 
    
    Stage1 = B0*Input + State0; 
    State0 = B1*Input + A1/A0*Stage1 + State1; 
    State1 = B2*Input + A2/A0*Stage1; 
    
    Output = B3*Stage1 + State2; 
    State2 = B4*Stage1 + A4/A3*Output + State2; 
    State3 = B5*Stage1 + A5/A3*Output;

Comments
--------

- **Date**: 2006-09-14 10:36:43
- **By**: musicdsp@Nospam dsparsons.co.uk

.. code-block:: text

    You've used two notations here (as admitted on KVR!)..
    Updated calculation code reads:
    
    =-=-=-= Start =-=-=-=
    
    Calculate the first biquad: 
    
    //A0 =   (Coeff[1]+K+Coeff[0]);
    t  = 1/(Coeff[1]+K+Coeff[0]);
    A1 = 2*(Coeff[0]-K)*t;
    A2 =   (Coeff[1]-K-Coeff[0])*t;
    B0 = t*K;
    B1 = 2*B0;
    B2 = B0;
    
    Calculate the second biquad: 
    
    //A3 =   (Coeff[3]+K+Coeff[2]);
    t  = 1/(Coeff[3]+K+Coeff[2]);
    A4 = 2*(Coeff[2]-K)*t;
    A5 =   (Coeff[3]-K-Coeff[2])*t;
    B3 = t*K;
    B4 = 2*B3;
    B5 = B3;
    
    Then calculate the output as follows: 
    
    Stage1 = B0*Input + State0; 
    State0 = B1*Input + A1*Stage1 + State1; 
    State1 = B2*Input + A2*Stage1; 
    
    Output = B3*Stage1 + State2; 
    State2 = B4*Stage1 + A4*Output + State2; 
    State3 = B5*Stage1 + A5*Output;
    
    =-=-=-=  End  =-=-=-=
    
    Hope that clears up any confusion for future readers :-)

- **Date**: 2008-06-24 13:57:19
- **By**: moc.liamg@tnemelCssoR

.. code-block:: text

    The variable State3 is assigned a value, but is never used anywhere. Is there a reason for this?

- **Date**: 2008-10-17 00:40:33
- **By**: moc.liamg@321tiloen

.. code-block:: text

    Just ported this into Reaper's native JesuSonic.
    
    There are errors in both of the codes above :D
    Use this:
    
    //start
    
    A0  = 1/(Coeff[1]+K+Coeff[0]);
    A1 = 2*(Coeff[0]-K)*A0;
    A2 = (Coeff[1]-K-Coeff[0])*A0;
    B0 = A0*K;
    B1 = 2*B0;
    B2 = B0;
    
    A3  = 1/(Coeff[3]+K+Coeff[2]);
    A4 = 2*(Coeff[2]-K)*A3;
    A5 = (Coeff[3]-K-Coeff[2])*A3;
    B3 = A3*K;
    B4 = 2*B3;
    B5 = B3;
    
    Stage1 = B0*Input + State0;
    State0 = B1*Input + A1*Stage1 + State1;
    State1 = B2*Input + A2*Stage1;
    Output = B3*Stage1 + State2;
    State2 = B4*Stage1 + A4*Output + State3;
    State3 = B5*Stage1 + A5*Output;
    
    //end
    
    @RossClement[ AT ]gmail[ DOT ]com
    'State3' should be added in this line
    -> State2 = B4*Stage1 + A4*Output + State3;
    
    

