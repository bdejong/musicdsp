Another LFO class
=================

- **Author or source:** mdsp
- **Created:** 2003-08-26 14:56:14

- **Linked files:** :download:`LFO.zip <../files/LFO.zip>`.

.. code-block:: text
    :caption: notes

    This LFO uses an unsigned 32-bit phase and increment whose 8 Most Significant Bits adress
    a Look-up table while the 24 Least Significant Bits are used as the fractionnal part.
    Note: As the phase overflow automatically, the index is always in the range 0-255.
    
    It performs linear interpolation, but it is easy to add other types of interpolation.
    
    Don't know how good it could be as an oscillator, but I found it good enough for a LFO.
    BTW there is also different kind of waveforms.
    
    Modifications:
    We could use phase on 64-bit or change the proportion of bits used by the index and the
    fractionnal part.



Comments
--------

- **Date**: 2004-09-07 13:52:17
- **By**: ku.oc.enydranos@aja

.. code-block:: text

    This type of oscillator is know as a numerically controlled oscillator(nco) or phase accumulator sythesiser. Integrated circuits that implement it in hardware are available such as the AD7008 from Analog Devices.
    The frequency resolution is very high and is = (SampleRate)/32^2. So if clocked at 44.1Khz the frequency resolution would be 0.00001026Hz!
    As you said the output waveform can be whatever shape you choose to put in the lookup table. The phase register is already in saw tooth form.
    
    Regards,
    Tony

- **Date**: 2004-12-22 08:40:40
- **By**: moc.yddaht@yddaht

.. code-block:: text

    It works great!
    Here's a Delphi version I just knocked up. Both VCL and KOL supported.
    
    code:
    unit PALFO;
    //
    // purpose: LUT based LFO
    //  author: © 2004, Thaddy de Koning
    // Remarks: Translated from c++ sources by Remy Mueller, www.musicdsp.org
    
    interface
    uses
    {$IFDEF KOL}
      Windows, Kol,KolMath;
    {$ELSE}
      Windows, math;
    {$ENDIF}
    
    const
     k1Div24lowerBits = 1/(1 shl 24);
    
     WFStrings:array[0..4] of string =
     ('triangle','sinus', 'sawtooth', 'square', 'exponent');
    
    type
       Twaveform = (triangle, sinus, sawtooth, square, exponent);
    
    
    
    {$IFDEF KOL}
       PPaLfo = ^TPALfo;
       TPaLfo = object(TObj)
    {$ELSE}
       TPaLfo = class
    {$ENDIF}
       private
         FTable:array[0..256] of Single;// 1 more for linear interpolation
         FPhase,
         FInc:Single;
         FRate: Single;
         FSampleRate: Single;
         FWaveForm: TWaveForm;
         procedure SetRate(const Value: Single);
         procedure SetSampleRate(const Value: Single);
         procedure SetWaveForm(const Value: TWaveForm);
       public
    {$IFNDEF KOL}
         constructor create(SampleRate:Single);virtual;
    {$ENDIF}
          // increments the phase and outputs the new LFO value.
          // return the new LFO value between [-1;+1]
         function WaveformName:String;
         function Tick:Single;
         // The rate in Hz
         property Rate:Single read FRate write SetRate;
         // The Samplerate
         property SampleRate:Single read FSampleRate write SetSampleRate;
         property WaveForm:TWaveForm read FWaveForm write SetWaveForm;
       end;
    
    {$IFDEF KOL}
    function NewPaLfo(aSamplerate:Single):PPaLfo;
    {$ENDIF}
    
    implementation
    
    { TPaLfo }
    {$IFDEF KOL}
    function NewPaLfo(aSamplerate:Single):PPaLfo;
    begin
      New(Result,Create);
      with Result^ do
      begin
        FPhase:=0;
        Finc:=0;
        FSamplerate:=aSamplerate;
        SetWaveform(triangle);
        FRate:=1;
      end;
    end;
    {$ELSE}
    constructor TPaLfo.create(SampleRate: Single);
    begin
        inherited create;
        FPhase:=0;
        Finc:=0;
        FSamplerate:=aSamplerate;
        SetWaveform(triangle);
        FRate:=1;
    end;
    {$ENDIF}
    
    
    procedure TPaLfo.SetRate(const Value: Single);
    begin
      FRate := Value;
      // the rate in Hz is converted to a phase increment with the following formula
      // f[ inc = (256*rate/samplerate) * 2^24]
      Finc :=  (256 * Frate / Fsamplerate) * (1 shl 24);
    end;
    
    procedure TPaLfo.SetSampleRate(const Value: Single);
    begin
      FSampleRate := Value;
    end;
    
    procedure TPaLfo.SetWaveForm(const Value: TWaveForm);
    var
      i:integer;
    begin
      FWaveForm := Value;
      Case Fwaveform of
      sinus:
    	      for i:=0 to 256 do
    	        FTable[i] := sin(2*pi*(i/256));
      triangle:
          begin
    	      for i:=0 to 63 do
            begin
    	        FTable[i] := i / 64;
    	        FTable[i+64] :=(64-i) / 64;
    	        FTable[i+128] := - i / 64;
    	        FTable[i+192] := - (64-i) / 64;
    	      end;
    	      FTable[256] := 0;
    	    end;
      sawtooth:
          begin
    	      for i:=0 to 255 do
    	        FTable[i] := 2*(i/255) - 1;
    	      FTable[256] := -1;
          end;
      square:
          begin
    	      for i:=0 to 127 do
    	      begin
    	        FTable[i]     :=  1;
    	        FTable[i+128] := -1;
    	      end;
    	      FTable[256] := 1;
          end;
      exponent:
          begin
    	      // symetric exponent similar to triangle
    	      for i:=0 to 127 do
            begin
    	        FTable[i] := 2 * ((exp(i/128) - 1) / (exp(1) - 1)) - 1  ;
    	        FTable[i+128] := 2 * ((exp((128-i)/128) - 1) / (exp(1) - 1)) - 1  ;
    	      end;
    	      FTable[256] := -1;
          end;
      end;
    end;
    
    function TPaLfo.WaveformName:String;
    begin
      result:=WFStrings[Ord(Fwaveform)];
    end;
    
    function TPaLfo.Tick: Single;
    var
      i:integer;
      frac:Single;
    begin
      // the 8 MSB are the index in the table in the range 0-255
      i := Pinteger(Fphase)^ shr 24;
      // and the 24 LSB are the fractionnal part
      frac := (PInteger(Fphase)^ and $00FFFFFF) * k1Div24lowerBits;
      // increment the phase for the next tick
      Fphase :=FPhase + Finc; // the phase overflows itself
      Result:= Ftable[i]*(1-frac) + Ftable[i+1]* frac; // linear interpolation
    end;
    
    end.
    
    
    

- **Date**: 2004-12-22 12:43:17
- **By**: moc.yddaht@yddaht

.. code-block:: text

    Oops,
    
    This one is correct:
    
    
    code:
    unit PALFO;
    //
    // purpose: LUT based LFO
    //  author: © 2004, Thaddy de Koning
    // Remarks: Translated from c++ sources by Remy Mueller, www.musicdsp.org
    
    interface
    uses
    {$IFDEF KOL}
      Windows, Kol,KolMath;
    {$ELSE}
      Windows, math;
    {$ENDIF}
    
    const
     k1Div24lowerBits = 1/(1 shl 24);
    
     WFStrings:array[0..4] of string =
     ('triangle','sinus', 'sawtooth', 'square', 'exponent');
    
    type
       Twaveform = (triangle, sinus, sawtooth, square, exponent);
    
    
    
    {$IFDEF KOL}
       PPaLfo = ^TPALfo;
       TPaLfo = object(TObj)
    {$ELSE}
       TPaLfo = class
    {$ENDIF}
       private
         FTable:array[0..256] of Single;// 1 more for linear interpolation
         FPhase,
         FInc:dword;
         FRate: Single;
         FSampleRate: Single;
         FWaveForm: TWaveForm;
         procedure SetRate(const Value: Single);
         procedure SetSampleRate(const Value: Single);
         procedure SetWaveForm(const Value: TWaveForm);
       public
    {$IFNDEF KOL}
         constructor create(SampleRate:Single);virtual;
    {$ENDIF}
          // increments the phase and outputs the new LFO value.
          // return the new LFO value between [-1;+1]
         function WaveformName:String;
         function Tick:Single;
         // The rate in Hz
         property Rate:Single read FRate write SetRate;
         // The Samplerate
         property SampleRate:Single read FSampleRate write SetSampleRate;
         property WaveForm:TWaveForm read FWaveForm write SetWaveForm;
       end;
    
    {$IFDEF KOL}
    function NewPaLfo(aSamplerate:Single):PPaLfo;
    {$ENDIF}
    
    implementation
    
    { TPaLfo }
    {$IFDEF KOL}
    function NewPaLfo(aSamplerate:Single):PPaLfo;
    begin
      New(Result,Create);
      with Result^ do
      begin
        FPhase:=0;
        FSamplerate:=aSamplerate;
        SetWaveform(sinus);
        Rate:=1;
      end;
    end;
    {$ELSE}
    constructor TPaLfo.create(SampleRate: Single);
    begin
        inherited create;
        FPhase:=0;
        FSamplerate:=aSamplerate;
        SetWaveform(sinus);
        FRate:=1;
    end;
    {$ENDIF}
    
    
    procedure TPaLfo.SetRate(const Value: Single);
    begin
      FRate := Value;
      // the rate in Hz is converted to a phase increment with the following formula
      // f[ inc = (256*rate/samplerate) * 2^24]
      Finc :=  round((256 * Frate / Fsamplerate) * (1 shl 24));
    end;
    
    procedure TPaLfo.SetSampleRate(const Value: Single);
    begin
      FSampleRate := Value;
    end;
    
    procedure TPaLfo.SetWaveForm(const Value: TWaveForm);
    var
      i:integer;
    begin
      FWaveForm := Value;
      Case Fwaveform of
      sinus:
    	      for i:=0 to 256 do
    	        FTable[i] := sin(2*pi*(i/256));
      triangle:
          begin
    	      for i:=0 to 63 do
            begin
    	        FTable[i] := i / 64;
    	        FTable[i+64] :=(64-i) / 64;
    	        FTable[i+128] := - i / 64;
    	        FTable[i+192] := - (64-i) / 64;
    	      end;
    	      FTable[256] := 0;
    	    end;
      sawtooth:
          begin
    	      for i:=0 to 255 do
    	        FTable[i] := 2*(i/255) - 1;
    	      FTable[256] := -1;
          end;
      square:
          begin
    	      for i:=0 to 127 do
    	      begin
    	        FTable[i]     :=  1;
    	        FTable[i+128] := -1;
    	      end;
    	      FTable[256] := 1;
          end;
      exponent:
          begin
    	      // symetric exponent similar to triangle
    	      for i:=0 to 127 do
            begin
    	        FTable[i] := 2 * ((exp(i/128) - 1) / (exp(1) - 1)) - 1  ;
    	        FTable[i+128] := 2 * ((exp((128-i)/128) - 1) / (exp(1) - 1)) - 1  ;
    	      end;
    	      FTable[256] := -1;
          end;
      end;
    end;
    
    function TPaLfo.WaveformName:String;
    begin
      result:=WFStrings[Ord(Fwaveform)];
    end;
    
    
    
    function TPaLfo.Tick: Single;
    var
      i:integer;
      frac:Single;
    begin
      // the 8 MSB are the index in the table in the range 0-255
      i := Fphase shr 24;
      // and the 24 LSB are the fractionnal part
      frac := (Fphase and $00FFFFFF) * k1Div24lowerBits;
      // increment the phase for the next tick
      Fphase :=FPhase + Finc; // the phase overflows itself
      Result:= Ftable[i]*(1-frac) + Ftable[i+1]* frac; // linear interpolation
    end;
    
    end.
    
    

