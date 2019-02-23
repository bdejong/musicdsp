Karlsen
=======

- **Author or source:** Best Regards,Ove Karlsen
- **Type:** 24-dB (4-pole) lowpass
- **Created:** 2003-04-05 06:57:19


.. code-block:: text
    :caption: notes

    There's really not much voodoo going on in the filter itself, it's a simple as possible:
    
    pole1 = (in  * frequency) + (pole1 * (1 - frequency));
    
    Most of you can probably understand that math, it's very similar to how an analog
    condenser works.
    Although, I did have to do some JuJu to add resonance to it.
    While studing the other filters, I found that the feedback phase is very important to how
    the overall
    resonance level will be, and so I made a dynamic feedback path, and constant Q
    approximation by manipulation
    of the feedback phase.
    A bonus with this filter, is that you can "overdrive" it... Try high input levels..
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    // Karlsen 24dB Filter by Ove Karlsen / Synergy-7 in the year 2003.
    // b_f = frequency 0..1
    // b_q = resonance 0..50
    // b_in = input
    // to do bandpass, subtract poles from eachother, highpass subtract with input.
    
    
       float b_inSH = b_in // before the while statement.
    
    	while (b_oversample < 2) {						//2x oversampling (@44.1khz)
    		float prevfp;
    		prevfp = b_fp;
    		if (prevfp > 1) {prevfp = 1;}					// Q-limiter
    
    		b_fp = (b_fp * 0.418) + ((b_q * pole4) * 0.582);		// dynamic feedback
    		float intfp;
    		intfp = (b_fp * 0.36) + (prevfp * 0.64);			// feedback phase
    		b_in =	b_inSH - intfp;						// inverted feedback		
    					
    		pole1 = (b_in   * b_f) + (pole1 * (1 - b_f));			// pole 1
    		if (pole1 > 1) {pole1 = 1;} else if (pole1 < -1) {pole1 = -1;}  // pole 1 clipping
    		pole2 = (pole1   * b_f) + (pole2 * (1 - b_f));			// pole 2
    		pole3 = (pole2   * b_f) + (pole3 * (1 - b_f));			// pole 3
    		pole4 = (pole3   * b_f) + (pole4 * (1 - b_f));			// pole 4
    
    		b_oversample++;
    		}
    	lowpassout = b_in;
    
    
    

Comments
--------

- **Date**: 2003-08-08 18:35:52
- **By**: moc.7-ygrenys@evo

.. code-block:: text

    Hi.
    Seems to be a slight typo in my code.
    lowpassout = pole4; // ofcourse :)
    
    Best Regards,
    Ove Karlsen
    
    
    
    

- **Date**: 2003-09-20 15:31:19
- **By**: moc.tidosha@ttam

.. code-block:: text

    Hi Ove, we spoke once on the #AROS IRC channel... I'm trying to put this code into a filter object, but I'm wandering what datatype the input and output should be?
    
    I'm processing my audio data in packets of 8000 signed words (16 bits) at a time. can I put one audio sample words into this function? Since it seems to require a floating point input!
    
    Thanks

- **Date**: 2004-05-17 18:49:43
- **By**: moc.tsv-nashi@edoc_evo

.. code-block:: text

    Hi Matt.
    
    Yes, it does indeed need float inputs.
    
    Best Regards,
    Ove Karlsen.
    
    

- **Date**: 2005-03-20 11:36:07
- **By**: se.arret@htrehgraknu

.. code-block:: text

    Can somebody explain exactly howto make the band Pass and high pass, i tried as explained and don't work exactly as expected
    
    highpass = in  - pole4
    
    make "some kind of highpass", but not as expected
    cut frequency
    
    and for band pass, how we substract the poles between them ?
    
    pole4-pole3-pole2-pole1 ?
    pole1-pole2-pole3-pole4 ?
    
    Also, is there a way to get a Notch ?
    
    
    
    
    

- **Date**: 2005-03-22 14:14:21
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Below you will find an object pascal version of the filter. 
    
    L=Lowpass
    H=Highpass
    N=Notch
    B=Bandpass
    
    Regards,
    
    Christian
    
    --
    unit KarlsenUnit;
    
    interface
    
    type
      TKarlsen = class
      private
        fQ      : Single;
        fF1,fF  : Single;
        fFS     : Single;
        fTmp    : Double;
        fOS     : Byte;
        fPole   : Array[1..4] of Single;
        procedure SetFrequency(v:Single);
        procedure SetQ(v:Single);
      public
        constructor Create;
        destructor Destroy; override;
        procedure Process(const I : Single; var L,B,N,H: Single);
        property Frequency: Single read fF write SetFrequency;
        property SampleRate: Single read fFS write fFS;
        property Q: Single read fQ write SetQ;
        property OverSample: Byte read fOS write fOS;
      end;
    
    implementation
    
    uses sysutils;
    
    const kDenorm = 1.0e-24;
    
    constructor TKarlsen.Create;
    begin
     inherited;
     fFS:=44100;
     Frequency:=1000;
     fOS:=2;
     Q:=1;
    end;
    
    destructor TKarlsen.Destroy;
    begin
     inherited;
    end;
    
    procedure TKarlsen.SetFrequency(v:Single);
    begin
     if fFS<=0 then raise exception.create('Sample Rate Error!');
     if v<>fF then
      begin
       fF:=v;
       fF1:=fF/fFs; // fF1 range from 0..1
      end;
    end;
    
    procedure TKarlsen.SetQ(v:Single);
    begin
     if v<>fQ then
      begin
       if v<0  then fQ:=0 else
       if v>50 then fQ:=50 else
       fQ:=v;
      end;
    end;
    
    procedure TKarlsen.Process(const I : Single; var L,B,N,H: Single);
    var prevfp : Single;
        intfp  : Single;
        o      : Integer;
    begin
     for o:=0 to fOS-1 do
      begin
       prevfp:=fTmp;
       if (prevfp > 1) then prevfp:=1; // Q-limiter
       fTmp:=(fTmp*0.418)+((fQ*fPole[4])*0.582); // dynamic feedback
       intfp:=(fTmp*0.36)+(prevfp*0.64); // feedback phase
       fPole[1]:= (((I+kDenorm)-intfp) * fF1) + (fPole[1] * (1 - fF1));
       if (fPole[1] > 1)
        then fPole[1]:= 1
        else if fPole[1] < -1
              then fPole[1]:= -1;
       fPole[2]:=(fPole[1]*fF1)+(fPole[2]*(1-fF1)); // pole 2
       fPole[3]:=(fPole[2]*fF1)+(fPole[3]*(1-fF1)); // pole 3
       fPole[4]:=(fPole[3]*fF1)+(fPole[4]*(1-fF1)); // pole 4
      end;
     L:=fPole[4];
     B:=fPole[4]-fPole[1];
     N:=I-fPole[1];
     H:=I-fPole[4]-fPole[1];
    end;
    
    end.              

- **Date**: 2005-03-29 12:24:17
- **By**: se.sarret@htrehgraknu

.. code-block:: text

    Thanks Christian!!
    
    Anyway, i tried something similar and seems that what you call Notch is reallya Bandpass and the bandpass makes something really strange
    
    Anyway i'm having  other problems with this filter too. It seems to cut  too Loow for low pass and too high for high pass. Also, resonance sets a peak far away from the cut frequency.And last but not least, the slope isn't 24 db/oct, realkly is much lesser, but not in a consistent way: sometimes is 6, sometimes 12, sometimes 20, etc
    
    Any ideas ?
    
    
    
    
    

- **Date**: 2005-07-20 12:28:44
- **By**: moc.psd-nashi@liam

.. code-block:: text

    Your problem sounds a bit strange, maybe you should check your implementation.
    
    Nice to see a pascal version too, Christian!
    
    Although I really recommend one set a lower denormal threshold, maybe a 1/100, it really affects the sound of the filter. The best is probably tweaking that value in realtime to see what sounds best.
    Also, doubles for the buffers.. :)
    
    Very Best Regards,
    Ove Karlsen

- **Date**: 2005-09-20 12:26:37
- **By**: ku.oc.snosrapsd@psdcisum

.. code-block:: text

    Christian, shouldn't your code end:
    L:=fPole[4];
    B:=fPole[4]-fPole[1];
    //CWB posted
    //N:=I-fPole[1];
    //B:=I-fPole[4]-fPole[1];
    
    //DSP posted
    H:=I-fPole[4]; //Surely pole 4 would give a 24dB/Oct HP, rather than the 6dB version posted
    N:=I-fPole[4]-fPole[1]; //Inverse of BP
    
    Any thoughts, anyone?
    
    DSP

- **Date**: 2005-09-23 11:15:32
- **By**: moc.psd-nashi@liam

.. code-block:: text

    This filter was really written mostly to demonstrate the Q-limiter though, and also, to write it in the most computationally effiecent way.
    Here is a little more featured version.
    ---------------------------------------
    // Karlsen, Second Order SVF type filter.
    
    // b_in1, b_in2 stereo input
    // fvar01 cutoff 
    // fvar02 slope 
    // fvar03 mode 
    // fvar04 res 
    // fvar05 cutoff/res compensation
    
    // inits, all doubles
    //	b_noise = 19.1919191919191919191919191919191919191919;
    // 	filterbuffers = 0;
    
    	b_noise = b_noise * b_noise;
    	int i_noise = b_noise;
    	b_noise = b_noise - i_noise;
    	
    	double b_lnoise = (b_noise - 0.5) * 2;
    	double b_rnoise = ((1-b_noise) - 0.5) * 2;
    
    	b_noise = b_noise + 19;
    
    	b_lnoise = b_lnoise * 65536;
    	b_rnoise = b_rnoise * 65536;
    	if (b_lnoise > 1) {b_lnoise = 1;} else if (b_lnoise < -1) {b_lnoise = -1;}
    	if (b_rnoise > 1) {b_rnoise = 1;} else if (b_rnoise < -1) {b_rnoise = -1;}
    
    	b_lnoise = b_lnoise * 1e-24; // find optimal value
    	b_rnoise = b_rnoise * 1e-24;
    
    	b_in1 = b_in1 + (b_lnoise);  // denormal prevention (also doubling as dither and analog noise).
    	b_in2 = b_in2 + (b_rnoise);
     
     
    	float b_slope = (1-fvar2) + 0.5;
    	float b_cut = ((fvar1    * fvar1) + ((fvar1 / (b_slope)) * (1 - fvar1))) / ((1 * fvar1) + ((1 / (b_slope)) * (1 - fvar1)));
    	b_cut = b_cut*b_cut; // linearize this
    	float b_res = fvar4 * 100;
    	int i_kmode = fvar3 * 100;
     
    	if (b_cut > 1) {b_cut = 1;}
    	if (b_cut < 0) {b_cut = 0;}
     
    	b_in1 = (b_in1 + b_lbuffb1);
    	b_in2 = (b_in2 + b_lbuffb2);
    
    	b_lbuf09 = ((b_in1    * b_cut) + ((b_lbuf09 / b_slope) * (1 - b_cut))) / ((1 * b_cut) + ((1 / b_slope) * (1 - b_cut)));
     	b_lbuf10 = ((b_in2    * b_cut) + ((b_lbuf10 / b_slope) * (1 - b_cut))) / ((1 * b_cut) + ((1 / b_slope) * (1 - b_cut)));
     
    	b_lbuf11 = ((b_lbuf09    * b_cut) + ((b_lbuf11 / b_slope) * (1 - b_cut))) / ((1 * b_cut) + ((1 / b_slope) * (1 - b_cut)));
     	b_lbuf12 = ((b_lbuf10    * b_cut) + ((b_lbuf12 / b_slope) * (1 - b_cut))) / ((1 * b_cut) + ((1 / b_slope) * (1 - b_cut)));
     
    	if (i_kmode == 0) { //lowpass
    		b_in1 = b_lbuf11;
    		b_in2 = b_lbuf12;
    	}
    	else if (i_kmode == 1) { // bandpass
    		b_in1 = b_lbuf09 - b_lbuf11;
    		b_in2 = b_lbuf10 - b_lbuf12;
    	}
    	else if (i_kmode == 2) { // highpass
    		b_in1 = b_in1 - b_lbuf11;
    		b_in2 = b_in2 - b_lbuf12;
    	}
    
    	b_lbuffb1 = ((b_lbuf09 - b_lbuf11) * ((b_cut * fvar5) + 1)) * b_res;
    	b_lbuffb2 = ((b_lbuf10 - b_lbuf12) * ((b_cut * fvar5) + 1)) * b_res;
    
    	b_lbuffb1 = atan(b_lbuffb1);
    	b_lbuffb2 = atan(b_lbuffb2);
    ---------------------------------------------
    Works really well with control signals, where you keep the cutoff at a constant level.
    Also, a bit more useful with audio, if you linearize the cutoff.
    
    Best Regards,
    Ove Karlsen.
    

- **Date**: 2005-10-13 14:00:39
- **By**: ku.oc.snosrapsd@psdcisum

.. code-block:: text

    I was looking at the b_cut assignment, and was going through looking 
    at optimising it and found this:
    
    float b_cut = ((fvar1    * fvar1) + ((fvar1 / (b_slope)) * (1 - fvar1)))
    / ((1 * fvar1) + ((1 / (b_slope)) * (1 - fvar1)));
    
    Rename for convenience and clarity
    fvar1=co
    b_slope=sl
    
    => (co^2+(co(1-co)))
              --------
                 sl
        ---------------
         (1*co)+(1-co)
                 ----
                  sl
    
    multiply numerator & denominator by sl to even things up
    
    => (sl*co^2+(co(1-co)))
        ------------------
          (sl*co)+(1-co)
    
    expand brackets
    
    =>  sl*co^2+co-co^2
        ---------------
          sl*co+1-co
    
    refactor
    
    =>  co(sl*co+1-co)
        ---------------
          sl*co+1-co
    
    (sl*co+1-co) cancels out, leaving..
    
    => co
    
    
    if I've got anything wrong here, please pipe up..
    
    Duncan

- **Date**: 2005-10-13 14:06:02
- **By**: ku.oc.snosrapsd@psdcisum

.. code-block:: text

    (actually, typing the assigment into Excel reveals the same as my proof..)

- **Date**: 2006-02-17 13:23:47
- **By**: moc.psd-nashi@liam

.. code-block:: text

    Final version, Stenseth, 17. february, 2006.
    
    // Fast differential amplifier approximation
    
    	double b_inr = b_in * b_filterdrive;
    	if (b_inr < 0) {b_inr = -b_inr;}
    	double b_inrns = b_inr;
    	if (b_inr > 1) {b_inr = 1;}
    	double b_dax = b_inr - ((b_inr * b_inr) * 0.5);
    	b_dax = b_dax - b_inr;
    	b_inr = b_inr + b_dax;
    
    	b_inr = b_inr * 0.24;
    
    	if (b_inr > 1) {b_inr = 1;}
    	b_dax = b_inr - ((b_inr * 0.33333333) * (b_inr * b_inr));
    	b_dax = b_dax - b_inr;
    	b_inr = b_inr + b_dax;
    
    	b_inr = b_inr / 0.24;
    
    	double b_mul = b_inrns / b_inr; // beware of zero
    	b_sbuf1 = ((b_sbuf1 - (b_sbuf1 * 0.4300)) + (b_mul * 0.4300));
    
    	b_mul = b_sbuf1 + ((b_mul - b_sbuf1) * 0.6910);
    	b_in = b_in / b_mul;
    
    // This method sounds the best here..
    // About denormals, it does not seem to be much of an issue here, probably because I input the filters with oscillators, and not samples, or other, where the level may drop below the denormal threshold for extended periods of time. However, if you do, you probably want to quantize out the information below the threshold, in the buffers, and raise/lower the inputlevel before/after the filter. Adding low levels of noise may be effective aswell. This is described somewhere else on this site.
    
    	double b_cutsc = pow(1024,b_cut) / 1024; // perfect tracking..
    
    	b_fbuf1 = ((b_fbuf1 - (b_fbuf1 * b_cutsc)) + (b_in * b_cutsc));
    	b_in = b_fbuf1;
    	b_fbuf2 = ((b_fbuf2 - (b_fbuf2 * b_cutsc)) + (b_in * b_cutsc));
    	b_in = b_fbuf2;
    	b_fbuf3 = ((b_fbuf3 - (b_fbuf3 * b_cutsc)) + (b_in * b_cutsc));
    	b_in = b_fbuf3;
    	b_fbuf4 = ((b_fbuf4 - (b_fbuf4 * b_cutsc)) + (b_in * b_cutsc));
    	b_in = b_fbuf4;
    
    Soundwise, it's somewhere between a transistor ladder, and a diode ladder..
    Enjoy!
    
    Ove Karlsen.
    PS: I prefer IRL communication these days, so if you need to reach me, please dial my cellphone, +047 928 50 803.
    

- **Date**: 2006-11-03 03:51:29
- **By**: read@bw

.. code-block:: text

    Another iteration, please delete all other posts than this.
    
    Arif Ove Karlsen's 24dB Ladder Approximation, 3.nov 2007
    
    As you may know, The traditional 4-pole Ladder found in vintage hardware synths,
    had a particular sound. The nonlinearities inherent in the suboptimal components, often
    added a particular flavour to the sound.
    Digital does mathematical calculations much better than any analog solution, and therefore, when the filter was emulated by digital filter types, some of the character got lost.
    I believe this mainly boils down to the resonance limiting occuring in the analog version.
    Therefore I have written a very fast ladder approximation, not emulating any of what may seem neccesary, such as pole saturaion, which in turn results in nonlinear cutoff frequency, and loss of volume at lower cutoffs. However this can be implemented, if wanted, by putting the neccesary saturation functions inside the code. If you seek the true analog sound, you may want to do a full differential amplifier emulation aswell.
    But - I believe in the end, you would end up wanting a perfect filter, with just the touch that makes it sound analog, resonance limiting.
    
    So here it is, Karlsen Ladder, v4. A very resource effiecent ladder. Can furthermore be optimized with asm.
    
    rez = pole4 * rezamount; if (rez > 1) {rez = 1;}
    input = input - rez;
    pole1 = pole1 + ((-pole1 + input) * cutoffreq);
    pole2 = pole2 + ((-pole2 + pole1) * cutoffreq);
    pole3 = pole3 + ((-pole3 + pole2) * cutoffreq);
    pole4 = pole4 + ((-pole4 + pole3) * cutoffreq);
    output = pole4;
    
    --
    
    I can be reached by email @ 1a2r4i54f5o5v2ek1a1r5ls6en@3ho2tm6ail1.c5o6m!no!nums
    
    

- **Date**: 2013-06-21 14:42:33
- **By**: pleasee@otherpost

.. code-block:: text

    Please see
                  http://musicdsp.org/showArchiveComment.php?ArchiveID=240
    
    for the ultimate development of this filter.
    
    Peace Be With You,
    Ove Karlsen

