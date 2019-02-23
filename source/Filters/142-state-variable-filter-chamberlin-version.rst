State Variable Filter (Chamberlin version)
==========================================

- **Author or source:** Hal Chamberlin, "Musical Applications of Microprocessors," 2nd Ed, Hayden Book Company 1985. pp 490-492.
- **Created:** 2003-04-14 18:33:53



.. code-block:: c++
    :linenos:
    :caption: code

    //Input/Output
    	I - input sample
    	L - lowpass output sample
    	B - bandpass output sample
    	H - highpass output sample
    	N - notch output sample
    	F1 - Frequency control parameter
    	Q1 - Q control parameter
    	D1 - delay associated with bandpass output
    	D2 - delay associated with low-pass output
    	
    // parameters:
    	Q1 = 1/Q 
    	// where Q1 goes from 2 to 0, ie Q goes from .5 to infinity
    	
    	// simple frequency tuning with error towards nyquist
    	// F is the filter's center frequency, and Fs is the sampling rate
    	F1 = 2*pi*F/Fs
    
    	// ideal tuning:
    	F1 = 2 * sin( pi * F / Fs )
    
    // algorithm
    	// loop
    	L = D2 + F1 * D1
    	H = I - L - Q1*D1
    	B = F1 * H + D1
    	N = H + L
    	
    	// store delays
    	D1 = B
    	D2 = L
    
    	// outputs
    	L,H,B,N

Comments
--------

- **Date**: 2005-03-21 00:08:03
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Object Pascal Implementation
    ----------------------------
    -denormal fixed
    -not optimized
    
    
    
    unit SVFUnit;
    
    interface
    
    type
      TFrequencyTuningMethod= (ftmSimple, ftmIdeal);
      TSVF = class
      private
        fQ1,fQ  : Single;
        fF1,fF  : Single;
        fFS     : Single;
        fD1,fD2 : Single;
        fFTM    : TFrequencyTuningMethod;
        procedure SetFrequency(v:Single);
        procedure SetQ(v:Single);
      public
        constructor Create;
        destructor Destroy; override;
        procedure Process(const I : Single; var L,B,N,H: Single);
        property Frequency: Single read fF write SetFrequency;
        property SampleRate: Single read fFS write fFS;
        property Q: Single read fQ write SetQ;
        property FrequencyTuningMethod: TFrequencyTuningMethod read fFTM write fFTM;
      end;
    
    implementation
    
    uses sysutils;
    
    const kDenorm = 1.0e-24;
    
    constructor TSVF.Create;
    begin
     inherited;
     fQ1:=1;
     fF1:=1000;
     fFS:=44100;
     fFTM:=ftmIdeal;
    end;
    
    destructor TSVF.Destroy;
    begin
     inherited;
    end;
    
    procedure TSVF.SetFrequency(v:Single);
    begin
     if fFS<=0 then raise exception.create('Sample Rate Error!');
     if v<>fF then
      begin
       fF:=v;
       case fFTM of
        ftmSimple:
         begin
          // simple frequency tuning with error towards nyquist
          // F is the filter's center frequency, and Fs is the sampling rate
          fF1:=2*pi*fF/fFS;
         end;
        ftmIdeal:
         begin
          // ideal tuning:
         fF1:=2*sin(pi*fF/fFS);
         end;
       end;
      end;
    end;
    
    procedure TSVF.SetQ(v:Single);
    begin
     if v<>fQ then
      begin
       if v>=0.5
        then fQ:=v
        else fQ:=0.5;
       fQ1:=1/fQ;
      end;
    end;
    
    procedure TSVF.Process(const I : Single; var L,B,N,H: Single);
    begin
     L:=fD2+fF1*fD1-kDenorm;
     H:=I-L-fQ1*fD1;
     B:=fF1*H+fD1;
     N:=H+L;
     // store delays
     fD1:=B;
     fD2:=kDenorm+L;
    end;
    
    end.
    

- **Date**: 2005-03-21 14:32:24
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Ups, there are still denormal bugs in it...
    (zu früh gefreut...)              

