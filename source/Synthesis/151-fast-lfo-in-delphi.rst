Fast LFO in Delphi...
=====================

- **Author or source:** Dambrin Didier ( moc.tcerideciffo-e@log )
- **Created:** 2003-07-15 09:01:18

- **Linked files:** :download:`LFOGenerator.zip <../files/LFOGenerator.zip>`.

.. code-block:: text
    :caption: notes

    [from Didier's mail...]
    [see attached zip file too!]
    
    I was working on a flanger, & needed an LFO for it. I first used a Sin(), but it was too
    slow, then tried a big wavetable, but it wasn't accurate enough.
    I then checked the alternate sine generators from your web site, & while they're good,
    they all can drift, so you're also wasting too much CPU in branching for the drift checks.
    So I made a quick & easy linear LFO, then a sine-like version of it. Can be useful for
    LFO's, not to output as sound.
    If has no branching & is rather simple. 2 Abs() but apparently they're fast. In all cases
    faster than a Sin()
    It's in delphi, but if you understand it you can translate it if you want.
    It uses a 32bit integer counter that overflows, & a power for the sine output.
    If you don't know delphi, $ is for hex (h at the end in c++?), Single is 32bit float,
    integer is 32bit integer (signed, normally).
    


.. code-block:: c++
    :linenos:
    :caption: code

    unit Unit1;
    
    interface
    
    uses
      Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
      StdCtrls, ExtCtrls, ComCtrls;
    
    type
      TForm1 = class(TForm)
        PaintBox1: TPaintBox;
        Bevel1: TBevel;
        procedure PaintBox1Paint(Sender: TObject);
      private
        { Private declarations }
      public
        { Public declarations }
      end;
    
    var
      Form1: TForm1;
    
    implementation
    
    {$R *.DFM}
    
    procedure TForm1.PaintBox1Paint(Sender: TObject);
    var n,Pos,Speed:Integer;
        Output,Scale,HalfScale,PosMul:Single;
        OurSpeed,OurScale:Single;
    begin
    OurSpeed:=100;  // 100 samples per cycle
    OurScale:=100;  // output in -100..100
    
    Pos:=0;  // position in our linear LFO
    Speed:=Round($100000000/OurSpeed);
    
    
    // --- triangle LFO ---
    Scale:=OurScale*2;
    PosMul:=Scale/$80000000;
    
    // loop
    for n:=0 to 299 do
      Begin
      // inc our 32bit integer LFO pos & let it overflow. It will be seen as signed when read by the math unit
      Pos:=Pos+Speed;
    
      Output:=Abs(Pos*PosMul)-OurScale;
    
      // visual
      Paintbox1.Canvas.Pixels[n,Round(100+Output)]:=clRed;
      End;
    
    
    // --- sine-like LFO ---
    Scale:=Sqrt(OurScale*4);
    PosMul:=Scale/$80000000;
    HalfScale:=Scale/2;
    
    // loop
    for n:=0 to 299 do
      Begin
      // inc our 32bit integer LFO pos & let it overflow. It will be seen as signed when read by the math unit
      Pos:=Pos+Speed;
    
      Output:=Abs(Pos*PosMul)-HalfScale;
      Output:=Output*(Scale-Abs(Output));
    
      // visual
      Paintbox1.Canvas.Pixels[n,Round(100+Output)]:=clBlue;
      End;
    end;
    
    end.
    

Comments
--------

- **Date**: 2004-04-29 09:18:58
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    LFO Class...
    
    unit Unit1;
    
    interface
    
    uses
      Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
      StdCtrls, ExtCtrls, ComCtrls;
    
    type
      TLFOType = (lfoTriangle,lfoSine);
      TLFO = class(TObject)
      private
        iSpeed     : Integer;
        fSpeed     : Single;
        fMax, fMin : Single;
        fValue     : Single;
        fPos       : Integer;
        fType      : TLFOType;
        fScale     : Single;
        fPosMul    : Single;
        fHalfScale : Single;
        function GetValue:Single;
        procedure SetType(tt: TLFOType);
        procedure SetMin(v:Single);
        procedure SetMax(v:Single);
      public
        { Public declarations }
        constructor Create;
      published
        property Value:Single read GetValue;
        property Speed:Single read FSpeed Write FSpeed;
        property Min:Single read FMin write SetMin;
        property Max:Single read FMax Write SetMax;
        property LFO:TLFOType read fType Write SetType;
      end;
    
      TForm1 = class(TForm)
        Bevel1: TBevel;
        PaintBox1: TPaintBox;
        procedure PaintBox1Paint(Sender: TObject);
      private
        { Private declarations }
      public
        { Public declarations }
      end;
    
    var
      Form1: TForm1;
    
    implementation
    
    {$R *.DFM}
    
    constructor TLFO.Create;
    begin
     fSpeed:=100;
     fMax:=1;
     fMin:=0;
     fValue:=0;
     fPos:=0;
     iSpeed:=Round($100000000/fSpeed);
     fType:=lfoTriangle;
     fScale:=fMax-((fMin+fMax)/2);
    end;
    
    procedure TLFO.SetType(tt: TLFOType);
    begin
     fType:=tt;
     if fType = lfoSine then
      begin
       fPosMul:=(Sqrt(fScale*2))/$80000000;
       fHalfScale:=(Sqrt(fScale*2))/2;
      end
     else
      begin
       fPosMul:=fScale/$80000000;
      end;
    end;
    
    procedure TLFO.SetMin(v: Single);
    begin
     fMin:=v;
     fScale:=fMax-((fMin+fMax)/2);
    end;
    
    procedure TLFO.SetMax(v: Single);
    begin
     fMax:=v;
     fScale:=fMax-((fMin+fMax)/2);
    end;
    
    function TLFO.GetValue:Single;
    begin
     if fType = lfoSine then
      begin
       Result:=Abs(fPos*fPosMul)-fHalfScale;
       Result:=Result*(fHalfScale*2-Abs(Result))*2;
       Result:=Result+((fMin+fMax)/2);
      end
     else
      begin
        Result:=Abs(fPos*(2*fPosMul))+fMin;
      end;
     fPos:=fPos+iSpeed;
    end;
    
    procedure TForm1.PaintBox1Paint(Sender: TObject);
    var n    : Integer;
        LFO1 : TLFO;
    begin
    
    LFO1:=TLFO.Create;
    LFO1.Min:=-100;
    LFO1.Max:=100;
    LFO1.Speed:=100;
    LFO1.LFO:=lfoTriangle;
    
    // --- triangle LFO ---
    for n:=0 to 299 do Paintbox1.Canvas.Pixels[n,Round(100+LFO1.Value)]:=clRed;
    
    
    LFO1.LFO:=lfoSine;
    // --- sine-like LFO ---
    for n:=0 to 299 do Paintbox1.Canvas.Pixels[n,Round(100+LFO1.Value)]:=clBlue;
    end;
    
    end.             

- **Date**: 2005-06-01 23:36:15
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Ups, i forgot something:
    
      TLFO = class(TObject)
      private
        ...
        procedure SetSpeed(v:Single);
      public
        ...
      published
        ...
        property Speed:Single read FSpeed Write SetSpeed;
        ...
      end;
    
    ...
    
    constructor TLFO.Create;
    begin
     ...
     Speed:=100;
     ...
    end;
    
    procedure TLFO.SetSpeed(v:Single);
    begin
     fSpeed:=v;
     iSpeed:=Round($100000000/fSpeed);
    end;
    
    ...

