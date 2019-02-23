MIDI note/frequency conversion
==============================

- **Author or source:** ed.bew@raebybot
- **Type:** -
- **Created:** 2002-11-25 18:14:17


.. code-block:: text
    :caption: notes

    I get often asked about simple things like MIDI note/frequency conversion, so I thought I
    could as well post some source code about this.
    The following is Pascal/Delphi syntax, but it shouldn't be a problem to convert it to
    almost any language in no time.
    
    Uses for this code are mainly for initializing oscillators to the right frequency based
    upon a given MIDI note, but you might also check what MIDI note is closest to a given
    frequency for pitch detection etc.
    In realtime applications it might be a good idea to get rid of the power and log2
    calculations and generate a lookup table on initialization.
    
    A full Pascal/Delphi unit with these functions (including lookup table generation) and a
    simple demo application can be downloaded here:
    http://tobybear.phreque.com/dsp_conv.zip
    
    If you have any comments/suggestions, please send them to: tobybear@web.de
    


.. code-block:: c++
    :linenos:
    :caption: code

    // MIDI NOTE/FREQUENCY CONVERSIONS
    
    const notes:array[0..11] of string= ('C ','C#','D ','D#','E ','F ','F#','G ','G#','A ','A#','B ');
    const base_a4=440; // set A4=440Hz
    
    // converts from MIDI note number to frequency
    // example: NoteToFrequency(12)=32.703
    function NoteToFrequency(n:integer):double;
    begin
     if (n>=0)and(n<=119) then
      result:=base_a4*power(2,(n-57)/12)
     else result:=-1;
    end;
    
    // converts from MIDI note number to string
    // example: NoteToName(12)='C 1'
    function NoteToName(n:integer):string;
    begin
     if (n>=0)and(n<=119) then
      result:=notes[n mod 12]+inttostr(n div 12)
     else result:='---';
    end;
    
    // converts from frequency to closest MIDI note
    // example: FrequencyToNote(443)=57 (A 4)
    function FrequencyToNote(f:double):integer;
    begin
     result:=round(12*log2(f/base_a4))+57;
    end;
    
    // converts from string to MIDI note
    // example: NameToNote('A4')=57
    function NameToNote(s:string):integer;
    var c,i:integer;
    begin
     if length(s)=2 then s:=s[1]+' '+s[2];
     if length(s)<>3 then begin result:=-1;exit end;
     s:=uppercase(s);
     c:=-1;
     for i:=0 to 11 do
      if notes[i]=copy(s,1,2) then
      begin
       c:=i;
       break
      end;
     try
      i:=strtoint(s[3]);
      result:=i*12+c;
     except
      result:=-1;
     end;
     if c<0 then result:=-1;
    end;
    

Comments
--------

- **Date**: 2002-11-29 17:34:28
- **By**: ed.bew@raebybot

.. code-block:: text

    For the sake of completeness, here is octave fraction notation and pitch class notation:
    
    // converts from MIDI note to octave fraction notation
    // the integer part of the result is the octave number, where
    // 8 is the octave starting with middle C. The fractional part
    // is the note within the octave, where 1/12 represents a semitone.
    // example: NoteToOct(57)=7.75 
    function NoteToOct(i:integer):double;
    begin
     result:=3+(i div 12)+(i mod 12)/12;
    end;
     
    // converts from MIDI note to pitch class notation
    // the integer part of the number is the octave number, where
    // 8 is the octave starting with middle C. The
    fractional part
    // is the note within the octave, where a 0.01 increment is a
    // semitone.
    // example: NoteToPch(57)=7.09
    function NoteToPch(i:integer):double;
    begin
     result:=3+(i div 12)+(i mod 12)*0.01;
    end;
    

- **Date**: 2002-12-03 12:36:05
- **By**: moc.noicratse@ajelak

.. code-block:: text

    I thought most sources gave A-440Hz = MIDI note 69. MIDI 60 = middle C = ~262Hz, A-440 = "A above middle C". Not so? 

- **Date**: 2003-05-14 03:24:58
- **By**: DFL

.. code-block:: text

    Kaleja is correct. Here is some C code:
    
      double MIDItoFreq( char keynum ) { 
        return 440.0 * pow( 2.0, ((double)keynum - 69.0) / 12.0 );
      }
    
    you can double-check the table here:
    http://tomscarff.tripod.com/midi_analyser/midi_note_frequency.htm

