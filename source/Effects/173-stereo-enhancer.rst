Stereo Enhancer
===============

- **Author or source:** vl.xobni@ksimruk
- **Created:** 2004-06-27 22:44:16


.. code-block:: text
    :caption: notes

    Stereo Enhanca

.. code-block:: c++
    :linenos:
    :caption: code

    
    // WideCoeff  0.0 .... 1.5
    
    #define StereoEnhanca(SamplL,SamplR,MonoSign, \
      DeltaLeft,WideCoeff ) \
      MonoSign = (SamplL + SamplR)/2.0; \
      DeltaLeft = SamplL - MonoSign; \
      DeltaLeft = DeltaLeft * WideCoeff; \
      SamplL=SamplL + DeltaLeft; \
      SamplR=SamplR - DeltaLeft;      

Comments
--------

- **Date**: 2004-08-20 17:45:38
- **By**: moc.liamg@noteex

.. code-block:: text

    #define StereoEnhanca(SamplL,SamplR,MonoSign,
      DeltaLeft,DeltaRight,WideCoeff )
      MonoSign = (SamplL + SamplR)/2.0;
    
      DeltaLeft = SamplL - MonoSign;
      DeltaLeft *= WideCoeff;
      DeltaRight = SamplR - MonoSign;
      DeltaRight *= WideCoeff;
    
      SamplL += DeltaLeft;
      SamplR += DeltaRight;
    
    I think this is more along the lines of what you were trying to accomplish. I doubt this is
    the correct way of implementing this type of thing however.

- **Date**: 2004-08-24 15:40:31
- **By**: moc.noomyab@grubmah_kram

.. code-block:: text

    I believe both pieces of code do the same thing. Since MonoSign is set equal to the average
    of the two signals, in the second case DeltaRight = -DeltaLeft.

- **Date**: 2005-01-07 10:20:20
- **By**: thaddy[@]thaddy.com

.. code-block:: delphi

                
    // Here's an implementation of the classic stereo enhancer in Delphi BASM
    // Values below 0.1 have a narrowing effect
    // Values abouve 0.1 widens
    parameters:
    Buffer = eax
    Amount = edx
    Samples = ecx
    
    const
      Spread:single =  6.5536;
    
    procedure Sound3d32f(Buffer:PSingle;Amount:Single;Samples:integer);
    asm
      fld     Amount
      fmul    spread
      mov     ecx, edx       // move samples to ecx
      shr     ecx, 1         // divide by two, stereo = 2 samples
    @Start:
      fld     [eax].dword    // left sample
      fld     [eax+4].dword  // right sample, whole calculation runs on the stack
      fld     st(0)          // copy
      fadd    st(0), st(2)
      fmul    half           // average =st(0), right sample = st(1), left = st(2), amount=st(3)
      fld     st(0)          // copy average
      fsubr   st(0), st(3)   // left diffence
      fmul    st(0), st(4)   // amount
      fadd    st(0), st(1)   // add average
      fadd    st(0), st(3)   // add original
      fmul    half           // divide by two
      fstp    [eax].dword    // and store
      fld     st(0)
      fsubr   st(0), st(2)   // right difference
      fmul    st(0), st(4)   // amount
      faddp                  // add average
      faddp                  // add original
      fmul    half           // divide by 2
      fstp    [eax+4].dword; // and store
      fxch                   // Dangling average?? remove it later, tdk
      ffree   st(1)
      add     eax, 8         // advance to next stereo pair
      loop    @Start
      ffree   st(0);         // Cleanup amount
    end;
      

- **Date**: 2005-03-24 09:45:09
- **By**: moc.yddaht@yddaht

.. code-block:: text

    Note 'half' is defined as const half:single = 0.5;          
    This is an ommission in the above posting 

- **Date**: 2005-04-21 22:04:02
- **By**: moc.liamtoh@gorpketg

.. code-block:: text

    This original code makes indeed no sense.
    
    >#define StereoEnhanca(SamplL,SamplR,MonoSign, \
    >DeltaLeft,WideCoeff ) \
    >MonoSign = (SamplL + SamplR)/2.0; \
    >DeltaLeft = SamplL - MonoSign; \
    >DeltaLeft = DeltaLeft * WideCoeff; \
    >SamplL=SamplL + DeltaLeft; \
    >SamplR=SamplR - DeltaLeft; 
    
    Deltaleft hold no stereoinformation.
    explained: Deltaleft=L-(L+R) = R!!!
    So, in this example your stereo image would slide to the right more as you put widecoeff higher.
    
    A better implementation is the following code.
    #define StereoEnhanca(SamplL,SamplR,MonoSign, \
    stereo,WideCoeff ) \
    MonoSign = (SamplL + SamplR)/2.0; \
    stereo = SamplL - Sampl1L; \
    stereo = DeltaLeft * WideCoeff; \
    SamplL=SamplR + stereo; // R+Stereo = L
    SamplR=SamplL - stereo; // L-Stereo = R
    
    This way of stereoenhancement will lead to exaggerated reverberation effects ( snaredrums).
    This is not the best way to do widening, but it is the easiest.
    
    Gtekprog.
    
    Evert Verduin
    

- **Date**: 2005-04-21 22:06:51
- **By**: moc.liamtoh@gorpketg

.. code-block:: text

    oops,
    
    stereo = SamplL - Sampl1L;
    needs ofcourse to be
    stereo = SamplL - Sampl1R;
    
    and
    
    stereo = DeltaLeft * WideCoeff; \
    needs to be
    stereo = stereo * WideCoeff; \
    
    Again the correct code:
    
    #define StereoEnhanca(SamplL,SamplR,MonoSign, \
    stereo,WideCoeff ) \
    MonoSign = (SamplL + SamplR)/2.0; \
    stereo = SamplL - Sampl1R; \
    stereo = stereo * WideCoeff; \
    SamplL=SamplR + stereo; // R+Stereo = L
    SamplR=SamplL - stereo; // L-Stereo = R
    
    This will do.
    
    Evert

- **Date**: 2009-04-17 13:16:42
- **By**: moc.liamg@nostohnotyalc

.. code-block:: text

    You mean to use MonoSign variable somewhere - as in:
    
       #define StereoEnhanca(SamplL,SamplR,MonoSign, \
    stereo,WideCoeff ) \
    MonoSign = (SamplL + SamplR)/2.0; \
    stereo = SamplL - Sampl1R; \
    stereo = stereo * WideCoeff; \
    
    SamplL = MonoSign + stereo; // R+Stereo = L
    SamplR = MonoSign - stereo; // L-Stereo = R
    
    Or some variation?
    
    Clayton

