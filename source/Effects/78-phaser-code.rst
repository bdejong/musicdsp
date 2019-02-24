Phaser code
===========

- **Author or source:** Ross Bencina
- **Created:** 2002-02-11 17:41:53

- **Linked files:** :download:`phaser.cpp <../files/phaser.cpp>`.

.. code-block:: text
    :caption: notes

    (see linked file)



Comments
--------

- **Date**: 2005-06-01 22:48:17
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: delphi

    // Delphi / Object Pascal Translation:
    // -----------------------------------
    
    unit Phaser;
    
    // Still not efficient, but avoiding denormalisation.
    
    interface
    
    type
      TAllPass=class(TObject)
      private
        fDelay : Single;
        fA1, fZM1 : Single;
        fSampleRate : Single;
        procedure SetDelay(v:Single);
      public
        constructor Create;
        destructor Destroy; override;
        function Process(const x:single):single;
        property SampleRate : Single read fSampleRate write fSampleRate;
        property Delay: Single read fDelay write SetDelay;
      end;
    
      TPhaser=class(TObject)
      private
        fZM1 : Single;
        fDepth : Single;
        fLFOInc : Single;
        fLFOPhase : Single;
        fFeedBack : Single;
        fRate : Single;
        fMinimum: Single;
        fMaximum: Single;
        fMin: Single;
        fMax: Single;
        fSampleRate : Single;
        fAllpassDelay: array[0..5] of TAllPass;
        procedure SetSampleRate(v:Single);
        procedure SetMinimum(v:Single);
        procedure SetMaximum(v:Single);
        procedure SetRate(v:Single);
        procedure Calculate;
      public
        constructor Create;
        destructor Destroy; override;
        function Process(const x:single):single;
        property SampleRate : Single read fSampleRate write SetSampleRate;
        property Depth: Single read fDepth write fDepth; //0..1
        property Feedback: Single read fFeedback write fFeedback; // 0..<1
        property Minimum: Single read fMin write SetMinimum;
        property Maximum: Single read fMax write SetMaximum;
        property Rate: Single read fRate write SetRate;
      end;
    
    implementation
    
    uses DDSPUtils;
    
    const kDenorm=1E-25;
    
    constructor TAllpass.Create;
    begin
     inherited;
     fA1:=0;
     fZM1:=0;
    end;
    
    destructor TAllpass.Destroy;
    begin
     inherited;
    end;
    
    function TAllpass.Process(const x:single):single;
    begin
     Result:=x*-fA1+fZM1;
     fZM1:=Result*fA1+x;
    end;
    
    procedure TAllpass.SetDelay(v:Single);
    begin
     fDelay:=v;
     fA1:=(1-v)/(1+v);
    end;
    
    constructor TPhaser.Create;
    var i : Integer;
    begin
     inherited;
     fSampleRate:=44100;
     fFeedBack:=0.7;
     fLFOPhase:=0;
     fDepth:=1;
     fZM1:=0;
     Minimum:=440;
     Maximum:=1600;
     Rate:=5;
     for i:=0 to Length(fAllpassDelay)-1
      do fAllpassDelay[i]:=TAllpass.Create;
    end;
    
    destructor TPhaser.Destroy;
    var i : Integer;
    begin
     for i:=0 to Length(fAllpassDelay)-1
      do fAllpassDelay[i].Free;
     inherited;
    end;
    
    procedure TPhaser.SetRate(v:Single);
    begin
     fLFOInc:=2*Pi*(v/SampleRate);
    end;
    
    procedure TPhaser.Calculate;
    begin
     fMin:= fMinimum / (fSampleRate/2);
     fMax:= fMinimum / (fSampleRate/2);
    end;
    
    procedure TPhaser.SetMinimum(v:Single);
    begin
     fMinimum:=v;
     Calculate;
    end;
    
    procedure TPhaser.SetMaximum(v:Single);
    begin
     fMaximum:=v;
     Calculate;
    end;
    
    function TPhaser.Process(const x:single):single;
    var d: Single;
        i: Integer;
    begin
     //calculate and update phaser sweep lfo...
     d := fMin + (fMax-fMin) * ((sin( fLFOPhase )+1)/2);
     fLFOPhase := fLFOPhase + fLFOInc;
     if fLFOPhase>=Pi*2
      then fLFOPhase:=fLFOPhase-Pi*2;
    
     //update filter coeffs
     for i:=0 to 5 do fAllpassDelay[i].Delay:=d;
    
     //calculate output
     Result:= fAllpassDelay[0].Process(
              fAllpassDelay[1].Process(
              fAllpassDelay[2].Process(
              fAllpassDelay[3].Process(
              fAllpassDelay[4].Process(
              fAllpassDelay[5].Process(kDenorm + x + fZM1 * fFeedBack ))))));
     fZM1:=tanh2a(Result);
    
     Result:=tanh2a(1.4*(x + Result * fDepth));
    end;
    
    procedure TPhaser.SetSampleRate(v:Single);
    begin
     fSampleRate:=v;
    end;
    
    end.

- **Date**: 2005-06-01 22:51:25
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Ups, forgot to remove my special, magic incredients "tanh2a(1.4*(". It's just
    to make the sound even warmer.
    
    The frequency range i used for Minimum and Maximum is 0..22000. But I believe there
    is still an error in that formula. The input range doesn't matter (if you remove my special
    incredient), because it is a linear system.

- **Date**: 2005-06-05 21:40:35
- **By**: moc.yddaht@yddaht

.. code-block:: delphi

    // I thought I already posted this but here's my interpretation for Delphi and KOL.
    // The reason I repost this, is that it is rather efficient and has no denormal problems.
    
    unit Phaser;
    {
    
           Unit: Phaser
        purpose: Phaser is a six stage phase shifter, intended to reproduce the
                 sound of a traditional analogue phaser effect.
         Author: Thaddy de Koning, based on a musicdsp.pdf C++ Phaser by
                 Ross Bencina.http://www.musicdsp.org/musicdsp.pdf
      Copyright: This version (c) 2003, Thaddy de Koning
                 Copyrighted Freeware
    
        Remarks: his implementation uses six first order all-pass filters in
                 series, with delay time modulated by a sinusoidal.
                 This implementation was created to be clear, not efficient.
                 Obvious modifications include using a table lookup for the lfo,
                 not updating the filter delay times every sample, and not
                 tuning all of the filters to the same delay time.
    
                 It sounds sensationally good!
    }
    
    interface
    
    uses Kol, AudioUtils, SimpleAllpass;
    
    type
      PPhaser = ^TPhaser;
      TPhaser = object(Tobj)
      private
        FSamplerate: single;
        FFeedback: single;
        FlfoPhase: single;
        FDepth: single;
        FOldOutput: single;
        FMinDelta: single;
        FMaxDelta: single;
        FLfoStep: single;
        FAllpDelays: array[0..5] of PAllpassdelay;
        FLowFrequency: single;
        FHighFrequency: single;
        procedure SetRate(TheRate: single); // cps
        procedure SetFeedback(TheFeedback: single); // 0 -> <1.
        procedure SetDepth(TheDepth: single);
        procedure SetHighFrequency(const Value: single);
        procedure SetLowFrequency(const Value: single); // 0 -> 1.
        procedure SetRange(LowFreq, HighFreq: single); // Hz
      public
        destructor Destroy; virtual;
        function Process(inSamp: single): single;
        property Rate: single write setrate;//In Cycles per second
        property Depth: single read Fdepth write setdepth;//0.. 1
        property Feedback: single read FFeedback write setfeedback; //0..< 1
        property Samplerate: single read Fsamplerate write Fsamplerate;
        property LowFrequency: single read FLowFrequency write SetLowFrequency;
        property HighFrequency: single read FHighFrequency write SetHighFrequency;
      end;
    
    function NewPhaser: PPhaser;
    
    implementation
    
    
    
    { TPhaser }
    function NewPhaser: PPhaser;
    var
      i: integer;
    begin
      New(Result, Create);
      with Result^ do
      begin
        Fsamplerate := 44100;
        FFeedback := 0.7;
        FlfoPhase := 0;
        Fdepth := 1;
        FOldOutput := 0;
        setrange(440,1720);
        setrate(0.5);
        for i := 0 to 5 do
          FAllpDelays[i] := NewAllpassDelay;
      end;
    end;
    
    destructor TPhaser.Destroy;
    var
      i: integer;
    begin
      for i := 5 downto 0 do FAllpDelays[i].Free;
      inherited;
    end;
    
    procedure TPhaser.SetDepth(TheDepth: single); // 0 -> 1.
    begin
      Fdepth := TheDepth;
    end;
    
    procedure TPhaser.SetFeedback(TheFeedback: single);//0..1;
    begin
      FFeedback := TheFeedback;
    end;
    
    procedure TPhaser.SetRange(LowFreq, HighFreq: single);
    begin
      FMinDelta := LowFreq / (FsampleRate / 2);
      FMaxDelta := HighFreq / (FsampleRate / 2);
    end;
    
    procedure TPhaser.SetRate(TheRate: single);
    begin
      FLfoStep := 2 * _PI * (Therate / FsampleRate);
    end;
    
    const
      _1:single=1;
      _2:single=2;
    function TPhaser.Process(inSamp: single): single;
    var
      Delaytime, Output: single;
      i: integer;
    begin
     
      //calculate and Process phaser sweep lfo...
      Delaytime := FMinDelta + (FMaxDelta - FMinDelta) * ((sin(FlfoPhase) + 1) / 2);
      FlfoPhase := FlfoPhase + FLfoStep;
      if (FlfoPhase >= _PI * 2) then
        FlfoPhase := FlfoPhase - _PI * 2;
      //Process filter coeffs
      for i := 0 to 5 do
        FAllpDelays[i].setdelay(Delaytime);
      //calculate output
      Output := FAllpDelays[0].Process(FAllpDelays[1].Process
        (FAllpDelays[2].Process(FAllpDelays[3].Process(FAllpDelays[4].Process
        (FAllpDelays[5].Process(inSamp + FOldOutput * FFeedback))))));
      FOldOutput := Output;
      Result := kDenorm + inSamp + Output * Fdepth;
    end;
    
    procedure TPhaser.SetHighFrequency(const Value: single);
    begin
      FHighFrequency := Value;
      setrange(FlowFrequency, FHighFrequency);
    end;
    
    procedure TPhaser.SetLowFrequency(const Value: single);
    begin
      FLowFrequency := Value;
      setrange(FlowFrequency, FHighFrequency);
    end;
    
    end.
    

- **Date**: 2005-06-05 21:44:47
- **By**: moc.yddaht@yddaht

.. code-block:: delphi

    // And here the allpass:
    unit SimpleAllpass;
    {
           Unit: SimpleAllpass
        purpose: Simple allpass delay for creating reverbs and phasing/flanging
         Author:
      Copyright:
        Remarks:
    }
    interface
    uses kol, audioutils;
    
    type
      PAllpassDelay = ^TAllpassDelay;
      TAllpassdelay = object(Tobj)
      protected
        Fa1,
        Fzm1: single;
      public
        procedure SetDelay(delay: single);//sample delay time
        function Process(inSamp: single): single;
      end;
    
    function NewAllpassDelay: PAllpassDelay;
    
    
    implementation
    
    function NewAllpassDelay: PAllpassDelay;
    begin
      New(Result, Create);
      with Result^ do
      begin
        Fa1 := 0;
        Fzm1 := 0;
      end;
    end;
    
    function TallpassDelay.Process(Insamp: single): single;
    begin
      Result := kDenorm+inSamp * -Fa1 + Fzm1;
      Fzm1 := Result * Fa1 + inSamp + kDenorm;
    end;
    
    procedure TAllpassDelay.setdelay(delay: single);// In sample time
    begin
      Fa1 := (1 - delay) / (1 + delay);
    end;
    
    end.

- **Date**: 2005-06-06 08:15:37
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    // You'll get a good performance boost by combining the 6 allpasses to one and rewriting
    // that one to FPU code. Heavy speed increase AND you can make the number of allpasses
    // variable as well.
    
    // This would look similar to this:
    
    function TMasterAllpass.Process(const x:single):single;
    var a : array[0..1] of Single;
        b : Single;
        i : Integer;
    begin
     a[0]:=x*fA1+fY[0];
     b:=a[0]*fA1;
     fY[0]:=b-x;
    
     i:=0;
     while i<fStages do
      begin
       a[1]:=b-fY[i+1];
       b:=a[1]*fA1;
       fY[i+1]:=a[0]-b;
       a[0]:=b-fY[i+2];
       b:=a[0]*fA1;
       fY[i+2]:=a[1]-b;
       Inc(i,2);
      end;
    
     a[1]:=b-fY[5];
     b:=a[1]*fA1;
     fY[5]:=a[0]-b;
     Result:=a[1];
    end;
    
    Now all you have to do is crawling into the FPU registers...

- **Date**: 2005-06-07 11:31:05
- **By**: moc.yddaht@yddaht

.. code-block:: text

    Point taken ;)
    Maybe we should combine all the stuff ;)        
    Btw:
    It's lots of fun working from each others code, don't you think?
    

