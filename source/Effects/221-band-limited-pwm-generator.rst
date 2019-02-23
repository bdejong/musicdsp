Band Limited PWM Generator
==========================

- **Author or source:** rf.liamtoh@57eninres_luap
- **Type:** PWM generator
- **Created:** 2006-05-11 19:09:04


.. code-block:: text
    :caption: notes

    This is a commented and deobfuscated version of my 1st April fish. It is based on a
    tutorial code by Thierry Rochebois. I just translated and added comments.
    
    Regards,
    
    Paul Sernine.


.. code-block:: c++
    :linenos:
    :caption: code

    // SelfPMpwm.cpp
    
    // Antialised PWM oscillator
    
    // Based on a tutorial code by Thierry Rochebois (98).
    // Itself inspired by US patent 4249447 by Norio Tomisawa (81).
    // Comments added/translated by P.Sernine (06).
    
    // This program generates a 44100Hz-raw-PCM-mono-wavefile.
    // It is based on Tomisawa's self-phase-modulated sinewave generators.
    // Rochebois uses a common phase accumulator to feed two half-Tomisawa-
    // oscillators. Each half-Tomisawa-oscillator generates a bandlimited
    // sawtooth (band limitation depending on the feedback coeff B).
    // These half oscillators are phase offseted according to the desired
    // pulse width. They are finally combined to obtain the PW signal.
    // Note: the anti-"hunting" filter is a critical feature of a good
    // implementation of Tomisawa's method.
    #include <math.h>
    #include <stdio.h>
    const float pi=3.14159265359f;
    int main()
    {
      float freq,dphi; //!< frequency (Hz) and phase increment(rad/sample)
      float dphif=0;   //!< filtered (anti click) phase increment
      float phi=-pi;   //!< phase
      float Y0=0,Y1=0; //!< feedback memories
      float PW=pi;     //!< pulse width ]0,2pi[
      float B=2.3f;    //!< feedback coef
      FILE *f=fopen("SelfPMpwm.pcm","wb");
      // séquence ('a'=mi=E)
      // you can edit this if you prefer another melody.
      static char seq[]="aiakahiafahadfaiakahiahafahadf"; //!< sequence
      int note=sizeof(seq)-2;  //!< note number in the sequence
      int octave=0;     //!< octave number
      float env,envf=0; //!< envelopped and filtered envelopped
      for(int ns=0;ns<8*(sizeof(seq)-1)*44100/6;ns++)
      {
    //waveform control --------------------------------------------------
        //Frequency
        //freq=27.5f*powf(2.0f,8*ns/(8*30*44100.0f/6)); //sweep
        freq=27.5f*powf(2.0f,octave+(seq[note]-'a'-5)/12.0f);
        //freq*=(1.0f+0.01f*sinf(ns*0.0015f));        //vibrato
        dphi=freq*(pi/22050.0f);   // phase increment
        dphif+=0.1f*(dphi-dphif);
        //notes and enveloppe trigger
        if((ns%(44100/6))==0)
        {
          note++;
          if(note>=(sizeof(seq)-1))// sequence loop
          {
            note=0;
            octave++;
          }
          env=1; //env set
          //PW=pi*(0.4+0.5f*(rand()%1000)/1000.0f); //random PW
        }
        env*=0.9998f;              // exp enveloppe
        envf+=0.1f*(env-envf);     // de-clicked enveloppe
        B=1.0f;                    // feedback coefficient
        //try this for a nice bass sound:
        //B*=envf*envf;              // feedback controlled by enveloppe
        B*=2.3f*(1-0.0001f*freq);  // feedback limitation
        if(B<0)
          B=0;
    
    //waveform generation -----------------------------------------------
        //Common phase
        phi+=dphif;                 // phase increment
        if(phi>=pi)
          phi-=2*pi;               // phase wrapping
    
        // "phase"    half Tomisawa generator 0
        // B*Y0 -> self phase modulation
        float out0=cosf(phi+B*Y0); // half-output 0
        Y0=0.5f*(out0+Y0);         // anti "hunting" filter
    
        // "phase+PW" half Tomisawa generator 1
        // B*Y1 -> self phase modulation
        // PW   -> phase offset
        float out1=cosf(phi+B*Y1+PW); // half-output 1
        Y1=0.5f*(out1+Y1);            // anti "hunting" filter
    
        // combination, enveloppe and output
        short s=short(15000.0f*(out0-out1)*envf);
        fwrite(&s,2,1,f);          // file output
      }
      fclose(f);
      return 0;
    }
    

Comments
--------

- **Date**: 2006-05-23 09:31:44
- **By**: ---

.. code-block:: text

    Did anyone try this?
    
    How is the antialiasing compared to applying phaserror between two oscs in zerocross, one aliasing the other not (but pitcherror).
    
    Best Regards,
    Arif Ove Karlsen.
    

- **Date**: 2010-02-04 08:37:45
- **By**: ude.notecnirp.inmula@esornep

.. code-block:: text

     
    The implementation certainly produces aliased waveforms -- they are glaring on a spectrogram at -60dB and faint at -30dB.  But it is a remarkably efficient algorithm. The aliasing can be mitigated somewhat by using a smaller feedback coefficient.

