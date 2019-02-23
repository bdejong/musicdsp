Generator
=========

- **Author or source:** Paul Sernine
- **Type:** antialiased sawtooth
- **Created:** 2006-02-23 22:38:56


.. code-block:: text
    :caption: notes

    This code generates a swept antialiasing sawtooth in a raw 16bit pcm file.
    It is based on the quad differentiation of a 5th order polynomial. The polynomial
    harmonics (and aliased harmonics) decay at 5*6 dB per oct. The differenciators correct the
    spectrum and waveform, while aliased harmonics are still attenuated.


.. code-block:: c++
    :linenos:
    :caption: code

    /* clair.c         Examen Partiel 2b
       T.Rochebois
       02/03/98
    */
    #include <stdio.h>
    #include <math.h>
    main()
    {
      double phase=0,dphase,freq,compensation;
      double aw0=0,aw1=0,ax0=0,ax1=0,ay0=0,ay1=0,az0=0,az1=0,sortie;
      short aout;
      int sr=44100;       //sample rate (Hz)
      double f_debut=55.0;//start freq (Hz)
      double f_fin=sr/6.0;//end freq (Hz)
      double octaves=log(f_fin/f_debut)/log(2.0);
      double duree=50.0;  //duration (s)
      int i;
      FILE* f;
      f=fopen("saw.pcm","wb");
      for(i=0;i<duree*sr;i++)
      {
        //exponential frequency sweep
        //Can be replaced by anything you like.
        freq=f_debut*pow(2.0,octaves*i/(duree*sr));
        dphase=freq*(2.0/sr);     //normalised phase increment
        phase+=dphase;            //phase incrementation
        if(phase>1.0) phase-=2.0; //phase wrapping (-1,+1)
    
        //polynomial calculation (extensive continuity at -1 +1)
        //        7       1  3    1   5
        //P(x) = --- x - -- x  + --- x
        //       360     36      120
        aw0=phase*(7.0/360.0 + phase*phase*(-1/36.0 + phase*phase*(1/120.0)));
        // quad differentiation (first order high pass filters)
        ax0=aw1-aw0; ay0=ax1-ax0; az0=ay1-ay0; sortie=az1-az0;
        //compensation of the attenuation of the quad differentiator
        //this can be calculated at "control rate" and linearly
        //interpolated at sample rate.
        compensation=1.0/(dphase*dphase*dphase*dphase);
        // compensation and output
        aout=(short)(15000.0*compensation*sortie);
        fwrite(&aout,1,2,f);
        //old memories of differentiators
        aw1=aw0; ax1=ax0; ay1=ay0; az1=az0;
      }
      fclose(f);
    }
    

Comments
--------

- **Date**: 2006-03-14 09:02:47
- **By**: rf.liamtoh@57eninreS_luaP

.. code-block:: text

    More infos and discussions in the KVR thread:
    http://www.kvraudio.com/forum/viewtopic.php?t=123498              

- **Date**: 2006-05-05 17:09:03
- **By**: moc.asile@nobnob

.. code-block:: text

    nice but i prefer the fishy algo, it generates less alias.
    bonaveture rosignol     

