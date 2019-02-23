3 Band Equaliser
================

- **Author or source:** Neil C
- **Created:** 2006-08-29 20:34:25


.. code-block:: text
    :caption: notes

    Simple 3 band equaliser with adjustable low and high frequencies ...
    
    Fairly fast algo, good quality output (seems to be accoustically transparent with all
    gains set to 1.0)
    
    How to use ...
    
    1. First you need to declare a state for your eq
    
      EQSTATE eq;
    
    2. Now initialise the state (we'll assume your output frequency is 48Khz)
    
      set_3band_state(eq,880,5000,480000);
    
      Your EQ bands are now as follows (approximatley!)
    
      low  band = 0Hz to 880Hz
      mid  band = 880Hz to 5000Hz
      high band = 5000Hz to 24000Hz
    
    3. Set the gains to some values ...
    
      eq.lg = 1.5;  // Boost bass by 50%
      eq.mg = 0.75; // Cut mid by 25%
      eq.hg = 1.0;  // Leave high band alone
    
    4. You can now EQ some samples
    
       out_sample = do_3band(eq,in_sample)
    
    
    Have fun and mail me if any problems ...  etanza at lycos dot co dot uk
    
    
    Neil C / Etanza Systems, 2006 :)
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    First the header file ....
    //---------------------------------------------------------------------------
    //
    //                                3 Band EQ :)
    //
    // EQ.H - Header file for 3 band EQ
    //
    // (c) Neil C / Etanza Systems / 2K6
    //
    // Shouts / Loves / Moans = etanza at lycos dot co dot uk 
    //
    // This work is hereby placed in the public domain for all purposes, including
    // use in commercial applications.
    //
    // The author assumes NO RESPONSIBILITY for any problems caused by the use of
    // this software.
    //
    //----------------------------------------------------------------------------
    
    #ifndef __EQ3BAND__
    #define __EQ3BAND__
    
    
    // ------------
    //| Structures |
    // ------------
    
    typedef struct
    {
      // Filter #1 (Low band)
    
      double  lf;       // Frequency
      double  f1p0;     // Poles ...
      double  f1p1;     
      double  f1p2;
      double  f1p3;
    
      // Filter #2 (High band)
    
      double  hf;       // Frequency
      double  f2p0;     // Poles ...
      double  f2p1;
      double  f2p2;
      double  f2p3;
    
      // Sample history buffer
    
      double  sdm1;     // Sample data minus 1
      double  sdm2;     //                   2
      double  sdm3;     //                   3
    
      // Gain Controls
    
      double  lg;       // low  gain
      double  mg;       // mid  gain
      double  hg;       // high gain
      
    } EQSTATE;  
    
    
    // ---------
    //| Exports |
    // ---------
    
    extern void   init_3band_state(EQSTATE* es, int lowfreq, int highfreq, int mixfreq);
    extern double do_3band(EQSTATE* es, double sample);
    
    
    #endif // #ifndef __EQ3BAND__
    //---------------------------------------------------------------------------
    
    Now the source ...
    //----------------------------------------------------------------------------
    //
    //                                3 Band EQ :)
    //
    // EQ.C - Main Source file for 3 band EQ
    //
    // (c) Neil C / Etanza Systems / 2K6
    //
    // Shouts / Loves / Moans = etanza at lycos dot co dot uk 
    //
    // This work is hereby placed in the public domain for all purposes, including
    // use in commercial applications.
    //
    // The author assumes NO RESPONSIBILITY for any problems caused by the use of
    // this software.
    //
    //----------------------------------------------------------------------------
    
    // NOTES :
    //
    // - Original filter code by Paul Kellet (musicdsp.pdf)
    //
    // - Uses 4 first order filters in series, should give 24dB per octave
    //
    // - Now with P4 Denormal fix :)
    
    
    //----------------------------------------------------------------------------
    
    // ----------
    //| Includes |
    // ----------
    
    #include <math.h>
    #include "eq.h"
    
    
    // -----------
    //| Constants |
    // -----------
    
    static double vsa = (1.0 / 4294967295.0);   // Very small amount (Denormal Fix)
    
    
    // ---------------
    //| Initialise EQ |
    // ---------------
    
    // Recommended frequencies are ...
    //
    //  lowfreq  = 880  Hz
    //  highfreq = 5000 Hz
    //
    // Set mixfreq to whatever rate your system is using (eg 48Khz)
    
    void init_3band_state(EQSTATE* es, int lowfreq, int highfreq, int mixfreq)
    {
      // Clear state 
    
      memset(es,0,sizeof(EQSTATE));
    
      // Set Low/Mid/High gains to unity
    
      es->lg = 1.0;
      es->mg = 1.0;
      es->hg = 1.0;
    
      // Calculate filter cutoff frequencies
    
      es->lf = 2 * sin(M_PI * ((double)lowfreq / (double)mixfreq)); 
      es->hf = 2 * sin(M_PI * ((double)highfreq / (double)mixfreq));
    }
    
    
    // ---------------
    //| EQ one sample |
    // ---------------
    
    // - sample can be any range you like :)
    //
    // Note that the output will depend on the gain settings for each band 
    // (especially the bass) so may require clipping before output, but you 
    // knew that anyway :)
    
    double do_3band(EQSTATE* es, double sample)
    {
      // Locals
    
      double  l,m,h;      // Low / Mid / High - Sample Values
    
      // Filter #1 (lowpass)
    
      es->f1p0  += (es->lf * (sample   - es->f1p0)) + vsa;
      es->f1p1  += (es->lf * (es->f1p0 - es->f1p1));
      es->f1p2  += (es->lf * (es->f1p1 - es->f1p2));
      es->f1p3  += (es->lf * (es->f1p2 - es->f1p3));
    
      l          = es->f1p3;
    
      // Filter #2 (highpass)
      
      es->f2p0  += (es->hf * (sample   - es->f2p0)) + vsa;
      es->f2p1  += (es->hf * (es->f2p0 - es->f2p1));
      es->f2p2  += (es->hf * (es->f2p1 - es->f2p2));
      es->f2p3  += (es->hf * (es->f2p2 - es->f2p3));
    
      h          = es->sdm3 - es->f2p3;
    
      // Calculate midrange (signal - (low + high))
    
      m          = es->sdm3 - (h + l);
    
      // Scale, Combine and store
    
      l         *= es->lg;
      m         *= es->mg;
      h         *= es->hg;
    
      // Shuffle history buffer 
    
      es->sdm3   = es->sdm2;
      es->sdm2   = es->sdm1;
      es->sdm1   = sample;                
    
      // Return result
    
      return(l + m + h);
    }
    
    
    //----------------------------------------------------------------------------

Comments
--------

- **Date**: 2007-03-28 03:33:04
- **By**: moc.mot@lx_iruy

.. code-block:: text

    Great Thanks!
    I have one problem the below:
      double  f2p0;     // Poles ...
      double  f2p1;
      double  f2p2;
      double  f2p3;
    that I want to know the starting value 
    about f2p0,f2p1,...!
      

- **Date**: 2007-04-14 12:02:27
- **By**: moc.oohay@knuf_red_retavttog_nuarb_semaj

.. code-block:: text

    yuri:
    
    The invocation of memset() during the initialization method sets all the the members of the struct to zero.  

- **Date**: 2007-05-22 19:05:47
- **By**: moc.liamtoh@cnamlleh

.. code-block:: text

    This is great -- I want to develop a compressor/limiter/expander and have been looking long and hard for bandpass / eq filtering code.  Here it is!
    
    I am sure we could easily expand this into an x band eq.
    
    Thanks!

- **Date**: 2007-07-05 06:49:45
- **By**: tom tom

.. code-block:: text

    Hi !
    
    I've just transposed your code under Delphi.
    
    It works well if the gain is under 1, but if i put gain > 1 i get clipping (annoying sound clips), even at 1.1;
    
    Is it normal ?
    
    I convert my smallint (44100 16 bits) to double before process, and convert the obtained value back to smallint with clipping (if < -32768 i set it to -32768, and if > 32768 i set it to 32768).
    
    What did i do wrong ?
    
    Regards
    
    Tom

- **Date**: 2007-07-21 14:24:53
- **By**: ed.xmg@7trebreh

.. code-block:: text

    Hi.
    
    Maybe the answer is quite easy. The upper limit is 32767 not 32768.
    
    Regards
    
    Herbert

- **Date**: 2007-08-23 02:39:23
- **By**: moc.oohay@3617100aggna

.. code-block:: text

    Hi, Can U send me a full source code for this 3 band state eq from start to end ?? 
    Please !!!!
    I really need it for my study in school.
    I hope you can send me, to my email.
    
    thanks you.
    regard
    
    
    angga

- **Date**: 2009-05-05 16:37:21
- **By**: moc.liamg@2156niahv

.. code-block:: text

    How can I expand this 3 Band EQ into X Band EQ..?!
    
    Anybody answer me, or email me..

- **Date**: 2009-05-22 13:27:00
- **By**: moc.boohay@bob

.. code-block:: text

    For more bands, you could take the low-pass and repeat the process on that.

- **Date**: 2009-05-23 18:46:04
- **By**: moc.yabtsalb@pilihp

.. code-block:: text

    This is a great little filter, I am using it in an application but when I first started playing with it I noticed some problems. The mid range didn't seem to be calculated properly, a friend of mine who knows more about dsp than I do took a quick look at it and suggested the following change:
    
      m          = es->sdm3 - (h + l);
    
    Should be:
    
      m          = sample - (h + l);
    
    I've tested it with this small fix and everything works perfectly now. Just thought I'd bring this to your attention... Thanks for a great code snippet!              

- **Date**: 2009-05-24 15:27:11
- **By**: moc.boohay@bob

.. code-block:: text

    What problems were you getting? Doesn't removing the delay cause phase problems?
    

- **Date**: 2009-06-25 10:34:44
- **By**: moc.limagy@ec.rahceb

.. code-block:: text

    Hi Great Stuff,
    
    how to create 6 band equalizer, is any algorithm for 6 band same like 3 band, please help me if any one
    
    thanks in advance
    

- **Date**: 2010-05-06 20:21:20
- **By**: moc.liamg@anesejiw

.. code-block:: text

    How to extend this to 6 band equalizer?              

- **Date**: 2010-05-27 21:45:44
- **By**: moc.liamtoh@aanaibas_nairam

.. code-block:: text

    hello! thanks for your code!!
    i tried to use the code in my project of guitar distortions in real time (in C) and i could'nt, i'm in linux using jack audio server, and it starts to have x-runs everytime i turn on the equalizer. do you any idea of how solving this? (from 5 to 50 milliseconds o x-runs)
    i was thinking of coding it in assembler but i don't know if that would be the solution.
    excuse me for my english, i'm from argentina and it's been a while since i last wrote in this language!
    thanks in advance, hoping to see any answer!
    mariano

- **Date**: 2010-11-03 14:19:25
- **By**: moc.oohay@56_drow

.. code-block:: text

    Dev c++ can not run it? any suggesstions, how to run it?

- **Date**: 2011-02-23 13:24:53
- **By**: moc.liamg@kniniurb.tnecniv

.. code-block:: text

    This example is exactly what i've been looking for. This little piece of code executes faster then the one I have been using before.
    
    FYI,
    
    I will use the code in a 3 band compressor / limiter / clipper for FM broadcasting.
    
    Thanks for sharing.
    
    Best regards,
    
    Vincent Bruinink.      

- **Date**: 2011-03-21 18:03:15
- **By**: moc.liamg@liamtsil.mtp

.. code-block:: text

    I've got this filtering audio on iOS by running my sample through do_3band in the render callback. However, I'm getting a fair amount of distortion. Here's an example with my EQ3Band gains all set to 1.0: 
    
    http://www.youtube.com/watch?v=W_6JaNUvUjA
    
    Here's the code for my implementation: 
    
    https://github.com/tassock/mixerhost/commit/4b8b87028bfffe352ed67609f747858059a3e89b
    
    I assume others using this aren't having this same distortion issue? If so, what sort of audio sample formats are you using (big/little endian, float/integer samples, etc). Thanks! 

- **Date**: 2011-04-30 20:17:58
- **By**: moc.liamg@enohpi.senarab

.. code-block:: text

    hi,
    I got also distorsion even though my all my gains are set to 1. Please help
    
    Lucie

- **Date**: 2012-06-05 07:19:56
- **By**: moc.liamg@solbaidcod

.. code-block:: text

          I've made an implementation of 3 band Equalizer to read a wave file,apply filtering and then save wave  outputfile.
    With your code I have a lot of distortion,I think the problem maybe coefficient calculation:
    
    es->f1p0  += (es->lf * (sample   - es->f1p0))+vsa ;
      ...
    
    
    
    Can anyone resolve distortion?
            

- **Date**: 2013-01-11 16:43:12
- **By**: es.dnargvelk@nahoj

.. code-block:: text

                  Works fine for me on iOS. Maybe you feed a interleaved stereo signal with the same EQSTATE instance (you'll need one EQSTATE for each channel)?

- **Date**: 2013-04-07 17:50:46
- **By**: ta.erehthgir@liameon

.. code-block:: text

     It's all about WHERE you init you EQ.  Try a little :) If you don't find out yourself, I'll help you.

- **Date**: 2013-06-18 14:00:45
- **By**: moc.laimtoh@inaam_riamu

.. code-block:: text

    I added this code to my xcode project. But where i can pass the values and method. May be its funny question for you guyz but please help me. Its loking good to me but in xcode , i am using avaudio player for play sound and making sound app.
    Thanks            

- **Date**: 2013-07-01 23:07:05
- **By**: moc.liamg@iaznabi

.. code-block:: text

    The distortion will occur of you are trying to adapt this to stereo and do so by simply adding an outer loop per channel. Doing so will cause the filter values to compound and cause distortion. Instead, you will need to duplicate all the filter values and keep them separate from the other channel.

- **Date**: 2013-08-21 14:09:08
- **By**: moc.liamg@nurb.luap

.. code-block:: text

    Any good x-band equalizer equivalents for C# that I can use?              

- **Date**: 2014-08-05 22:57:07
- **By**: ed.xmg@retsneum.ellak

.. code-block:: text

    s'cool thanks!
    have portet to c#
    works fine!
    
    

- **Date**: 2015-09-28 07:53:37
- **By**: az.oc.sseccadipar@sook

.. code-block:: text

                  
    Converted Neil's C Code 3 band equalizer to Delphi class, for those who are interested.
    
     
    1. Create instance of class
       Public
         eq:TEQ;
    
    2. On form create
    
        eq := TEq.Create;
    
        //Initialize
        init_3band_state(880,5000,44100,50,-25,0);
    
        //init_3band_state(lowfreq,highfreq,mixfreq:integer;BassGain,MidGain,HighGain:Double);
    
    
    3. process: pass Raw 16Bit PCM to eq
    
    eq.Equalize(const Data: Pointer; DataSize: DWORD);
    
    Works like a charm form me
    
    ***********************************************
      TEq=Class
      private
        lf,f1p0,f1p1,f1p2,f1p3:double;
        hf,f2p0,f2p1,f2p2,f2p3:double;
        sdm1,sdm2,sdm3:double;
        vsa:double;
        lg,mg,hg:double;
        Function do_3band(sample:Smallint):Smallint;
      public
        constructor create;
        destructor destroy;override;
        procedure init_3band_state(lowfreq,highfreq,mixfreq:integer;BassGain,MidGain,HighGain:Double);
        procedure Equalize(const Data: Pointer; DataSize: DWORD);
      end;
    
    
    constructor TEQ.create;
    begin
      inherited create;
      vsa := (1.0 / 4294967295.0);
      lg := 1.0;
      mg := 1.0;
      hg := 1.0;
    
    end;
    
    
    destructor TEQ.destroy;
    begin
      inherited destroy;
    end;
    
    procedure TEQ.init_3band_state(lowfreq,highfreq,mixfreq:integer;BassGain,MidGain,HighGain:Double);
    begin
    
     {(880,5000,44100,1.5,0.75,1.0)
     eq.lg = 1.5; // Boost bass by 50%
     eq.mg = 0.75; // Cut mid by 25%
     eq.hg = 1.0; // Leave high band alone }
    
     lg := 1+(BassGain/100);
     mg := 1+(MidGain/100);
     hg := 1+(HighGain/100);
    
    // Calculate filter cutoff frequencies
    
     lf := 2 * sin(PI * (lowfreq / mixfreq));
     hf := 2 * sin(PI * (highfreq / mixfreq));
    end;
    
    Function TEQ.do_3band(sample:Smallint):Smallint;
    var l,m,h:double;
        res:integer;
    begin
    
    // Filter #1 (lowpass)
    
      f1p0 := f1p0 + (lf * (sample - f1p0)) + vsa;
      f1p1 := f1p1 + (lf * (f1p0 - f1p1));
      f1p2 := f1p2 + (lf * (f1p1 - f1p2));
      f1p3 := f1p3 + (lf * (f1p2 - f1p3));
    
      l := f1p3;
    
    // Filter #2 (highpass)
    
      f2p0 := f2p0 + (hf * (sample - f2p0)) + vsa;
      f2p1 := f2p1 + (hf * (f2p0 - f2p1));
      f2p2 := f2p2 + (hf * (f2p1 - f2p2));
      f2p3 := f2p3 + (hf * (f2p2 - f2p3));
    
      h := sdm3 - f2p3;
    
    // Calculate midrange (signal - (low + high))
    
      m := sdm3 - (h + l);
    
    // Scale, Combine and store
    
      l := l * lg;
      m := m * mg;
      h := h * hg;
    
    // Shuffle history buffer
    
      sdm3 := sdm2;
      sdm2 := sdm1;
      sdm1 := sample;
    
    // Return result
      res := trunc(l+m+h);
      if res > 32767 then res := 32767 else if res < -32768 then res := -32768;
    
      result := res;
    end;
    
    procedure TEQ.Equalize(const Data: Pointer; DataSize: DWORD);
    var pSample: PSmallInt;
    begin
      pSample := Data;
      while DataSize > 0 do
      begin
        pSample^ := do_3band(pSample^);
        Inc(pSample);
        Dec(DataSize, 2);
      end;
    end;
    

