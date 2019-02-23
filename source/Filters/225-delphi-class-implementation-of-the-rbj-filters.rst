Delphi Class implementation of the RBJ filters
==============================================

- **Author or source:** moc.liamtoh@retsbomyrgnayrev
- **Type:** Delphi class implementation of the RBJ filters
- **Created:** 2006-07-11 08:16:46


.. code-block:: text
    :caption: notes

    I haven't tested this code thoroughly as it's pretty much a straight conversion from
    Arguru c++ implementation.


.. code-block:: c++
    :linenos:
    :caption: code

      {
      RBJ Audio EQ Cookbook Filters
      A pascal conversion of arguru[AT]smartelectronix[DOT]com's
      c++ implementation.
    
      WARNING:This code is not FPU undernormalization safe.
    
      Filter Types
      0-LowPass
      1-HiPass
      2-BandPass CSG
      3-BandPass CZPG
      4-Notch
      5-AllPass
      6-Peaking
      7-LowShelf
      8-HiShelf
      }
    unit uRbjEqFilters;
    
    interface
    
    uses math;
    
    type
      TRbjEqFilter=class
      private
        b0a0,b1a0,b2a0,a1a0,a2a0:single;
        in1,in2,ou1,ou2:single;
        fSampleRate:single;
        fMaxBlockSize:integer;
        fFilterType:integer;
        fFreq,fQ,fDBGain:single;
        fQIsBandWidth:boolean;
        procedure SetQ(NewQ:single);
      public
        out1:array of single;
        constructor create(SampleRate:single;MaxBlockSize:integer);
        procedure CalcFilterCoeffs(pFilterType:integer;pFreq,pQ,pDBGain:single;pQIsBandWidth:boolean);overload;
        procedure CalcFilterCoeffs;overload;
        function Process(input:single):single; overload;
        procedure Process(Input:psingle;sampleframes:integer); overload;
        property FilterType:integer read fFilterType write fFilterType;
        property Freq:single read fFreq write fFreq;
        property q:single read fQ write SetQ;
        property DBGain:single read fDBGain write fDBGain;
        property QIsBandWidth:boolean read fQIsBandWidth write fQIsBandWidth;
      end;
    
    implementation
    
    constructor TRbjEqFilter.create(SampleRate:single;MaxBlockSize:integer);
    begin
      fMaxBlockSize:=MaxBlockSize;
      setLength(out1,fMaxBlockSize);
      fSampleRate:=SampleRate;
    
      fFilterType:=0;
      fFreq:=500;
      fQ:=0.3;
      fDBGain:=0;
      fQIsBandWidth:=true;
    
      in1:=0;
      in2:=0;
      ou1:=0;
      ou2:=0;
    end;
    
    procedure TRbjEqFilter.SetQ(NewQ:single);
    begin
      fQ:=(1-NewQ)*0.98;
    end;
    
    procedure TRbjEqFilter.CalcFilterCoeffs(pFilterType:integer;pFreq,pQ,pDBGain:single;pQIsBandWidth:boolean);
    begin
      FilterType:=pFilterType;
      Freq:=pFreq;
      Q:=pQ;
      DBGain:=pDBGain;
      QIsBandWidth:=pQIsBandWidth;
    
      CalcFilterCoeffs;
    end;
    
    procedure TRbjEqFilter.CalcFilterCoeffs;
    var
      alpha,a0,a1,a2,b0,b1,b2:single;
      A,beta,omega,tsin,tcos:single;
    begin
      //peaking, LowShelf or HiShelf
      if fFilterType>=6 then
      begin
        A:=power(10.0,(DBGain/40.0));
        omega:=2*pi*fFreq/fSampleRate;
        tsin:=sin(omega);
        tcos:=cos(omega);
    
        if fQIsBandWidth then
          alpha:=tsin*sinh(log2(2.0)/2.0*fQ*omega/tsin)
        else
          alpha:=tsin/(2.0*fQ);
    
        beta:=sqrt(A)/fQ;
    
        // peaking
        if fFilterType=6 then
        begin
          b0:=1.0+alpha*A;
          b1:=-2.0*tcos;
          b2:=1.0-alpha*A;
          a0:=1.0+alpha/A;
          a1:=-2.0*tcos;
          a2:=1.0-alpha/A;
        end else
        // lowshelf
        if fFilterType=7 then
        begin
          b0:=(A*((A+1.0)-(A-1.0)*tcos+beta*tsin));
          b1:=(2.0*A*((A-1.0)-(A+1.0)*tcos));
          b2:=(A*((A+1.0)-(A-1.0)*tcos-beta*tsin));
          a0:=((A+1.0)+(A-1.0)*tcos+beta*tsin);
          a1:=(-2.0*((A-1.0)+(A+1.0)*tcos));
          a2:=((A+1.0)+(A-1.0)*tcos-beta*tsin);
        end;
        // hishelf
        if fFilterType=8 then
        begin
          b0:=(A*((A+1.0)+(A-1.0)*tcos+beta*tsin));
          b1:=(-2.0*A*((A-1.0)+(A+1.0)*tcos));
          b2:=(A*((A+1.0)+(A-1.0)*tcos-beta*tsin));
          a0:=((A+1.0)-(A-1.0)*tcos+beta*tsin);
          a1:=(2.0*((A-1.0)-(A+1.0)*tcos));
          a2:=((A+1.0)-(A-1.0)*tcos-beta*tsin);
        end;
      end else  //other filter types
      begin
        omega:=2*pi*fFreq/fSampleRate;
        tsin:=sin(omega);
        tcos:=cos(omega);
        if fQIsBandWidth then
          alpha:=tsin*sinh(log2(2)/2*fQ*omega/tsin)
        else
          alpha:=tsin/(2*fQ);
        //lowpass
        if fFilterType=0 then
        begin
          b0:=(1-tcos)/2;
          b1:=1-tcos;
          b2:=(1-tcos)/2;
          a0:=1+alpha;
          a1:=-2*tcos;
          a2:=1-alpha;
        end else //hipass
        if fFilterType=1 then
        begin
          b0:=(1+tcos)/2;
          b1:=-(1+tcos);
          b2:=(1+tcos)/2;
          a0:=1+alpha;
          a1:=-2*tcos;
          a2:=1-alpha;
        end else //bandpass CSG
        if fFilterType=2 then
        begin
          b0:=tsin/2;
          b1:=0;
          b2:=-tsin/2;
          a0:=1+alpha;
          a1:=-1*tcos;
          a2:=1-alpha;
        end else //bandpass CZPG
        if fFilterType=3 then
        begin
          b0:=alpha;
          b1:=0.0;
          b2:=-alpha;
          a0:=1.0+alpha;
          a1:=-2.0*tcos;
          a2:=1.0-alpha;
        end else  //notch
        if fFilterType=4 then
        begin
          b0:=1.0;
          b1:=-2.0*tcos;
          b2:=1.0;
          a0:=1.0+alpha;
          a1:=-2.0*tcos;
          a2:=1.0-alpha;
        end else   //allpass
        if fFilterType=5 then
        begin
          b0:=1.0-alpha;
          b1:=-2.0*tcos;
          b2:=1.0+alpha;
          a0:=1.0+alpha;
          a1:=-2.0*tcos;
          a2:=1.0-alpha;
        end;
      end;
    
      b0a0:=b0/a0;
      b1a0:=b1/a0;
      b2a0:=b2/a0;
      a1a0:=a1/a0;
      a2a0:=a2/a0;
    end;
    
    
    function TRbjEqFilter.Process(input:single):single;
    var
      LastOut:single;
    begin
      // filter
      LastOut:= b0a0*input + b1a0*in1 + b2a0*in2 - a1a0*ou1 - a2a0*ou2;
    
      // push in/out buffers
      in2:=in1;
      in1:=input;
      ou2:=ou1;
      ou1:=LastOut;
    
      // return output
      result:=LastOut;
    end;
    
    {
    the process method is overloaded.
    use Process(input:single):single;
     for per sample processing
    use Process(Input:psingle;sampleframes:integer);
     for block processing. The input is a pointer to
     the start of an array of single which contains
     the audio data.
     i.e.
     RBJFilter.Process(@WaveData[0],256);
    }
    
    procedure TRbjEqFilter.Process(Input:psingle;sampleframes:integer);
    var
      i:integer;
      LastOut:single;
    begin
      for i:=0 to SampleFrames-1 do
      begin
        // filter
        LastOut:= b0a0*(input^)+ b1a0*in1 + b2a0*in2 - a1a0*ou1 - a2a0*ou2;
        //LastOut:=input^;
        // push in/out buffers
        in2:=in1;
        in1:=input^;
        ou2:=ou1;
        ou1:=LastOut;
    
        Out1[i]:=LastOut;
    
        inc(input);
      end;
    end;
    
    end.

