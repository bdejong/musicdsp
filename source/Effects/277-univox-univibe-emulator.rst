UniVox Univibe Emulator
=======================

- **Author or source:** moc.liamg@libojyr
- **Type:** 4 Cascaded all-pass filters and optocoupler approximation
- **Created:** 2010-09-09 07:52:24


.. code-block:: text
    :caption: notes

    This is a class and class member functions for a 'Vibe derived by means of bilinear
    transform of the all-pass filter stages in a UniVibe.  Some unique things happen as this
    filter is modulated, so this has been somewhat involved computation of filter
    coefficients, and is based on summation of 1rst-order filter stages as algebraically
    decoupled during circuit analysis.  A second part is an approximated model of the Vactrol
    used to modulate the filters, including its time response to hopefully recapture the
    modulation shape.  It is likely there is a more efficient way to re-create the LFO shape,
    and perhaps would be best with a lookup table.   Keeping the calculation in the code makes
    it possible for other people to modify and improve the algorithm.
    
    Notice no wet/dry mix is implemented in this code block's "out" function.  Originally this
    was implemented in the calling routine, but if you use it as a stand-alone function you
    may want to add summation to the input signal as it is an important part of the "chorus"
    mode on the Vibe.  The code as is represents only the Vibrato (warble) mode.
    
    This is a module found in the Rakarrack guitar effects program.  It is GPL, so please give
    credit due and keep it free.  You can find any of the omitted parts to see more precisely
    how it is implemented with JACK on Linux by looking at the original sources at
    sourceforge.net/projects/rakarrack.


.. code-block:: c++
    :linenos:
    :caption: code

    /*
      Copyright (C) 2008-2010 Ryan Billing
      Author: Ryan Billing
    
    
     This program is free software; you can redistribute it and/or modify
     it under the terms of version 2 of the GNU General Public License
     as published by the Free Software Foundation.
    
     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License (version 2) for more details.
    
     You should have received a copy of the GNU General Public License
     (version2)  along with this program; if not, write to the Free Software
     Foundation,
     Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
    
    */
    
    class Vibe
    {
    
    public:
    
      Vibe (float * efxoutl_, float * efxoutr_);
      ~Vibe ();
    //note some of these functions not pasted below to improve clarity
    //and to save space
      void out (float * smpsl, float * smpsr);
      void setvolume(int value);
      void setpanning(int value);
      void setpreset (int npreset);
      void changepar (int npar, int value);
      int getpar (int npar);
      void cleanup ();
    
      float outvolume;
      float *efxoutl;
      float *efxoutr;
    
    
    private:
      int Pwidth;
      int Pfb;
      int Plrcross;
      int Pdepth;
      int Ppanning;
      int Pvolume;
       //all the ints above are the parameters to modify with a proper function.
    
      float fwidth;
      float fdepth;
      float rpanning, lpanning; 
      float flrcross, fcross;
      float fb;
      EffectLFO lfo; //EffectLFO is an object that calculates the next sample from the LFO each time it's called
      
      float Ra, Rb, b, dTC, dRCl, dRCr, lampTC, ilampTC, minTC, alphal, alphar, stepl, stepr, oldstepl, oldstepr;
      float fbr, fbl;
      float dalphal, dalphar;
      float lstep,rstep;
      float cperiod;
      float gl, oldgl;
      float gr, oldgr; 
      
      class fparams {
      public:
      float x1;
      float y1;
      //filter coefficients
      float n0;
      float n1;
      float d0;
      float d1; 
      } vc[8], vcvo[8], ecvc[8], vevo[8], bootstrap[8];
    
      float vibefilter(float data, fparams *ftype, int stage); 
      void init_vibes();
      void modulate(float ldrl, float ldrr);
      float bjt_shape(float data);
    
    float R1;
    float Rv;
    float C2;
    float C1[8];
    float beta;  //transistor forward gain.
    float gain, k;
    float oldcvolt[8] ;
    float en1[8], en0[8], ed1[8], ed0[8];
    float cn1[8], cn0[8], cd1[8], cd0[8];
    float ecn1[8], ecn0[8], ecd1[8], ecd0[8];
    float on1[8], on0[8], od1[8], od0[8];
    
       class FPreset *Fpre;
    
    
    };
    
    
    Vibe::Vibe (float * efxoutl_, float * efxoutr_)
    {
      efxoutl = efxoutl_;
      efxoutr = efxoutr_;
    
    //Swing was measured on operating device of: 10K to 250k.  
    //400K is reported to sound better for the "low end" (high resistance) 
    //Because of time response, Rb needs to be driven further.
    //End resistance will max out to around 10k for most LFO freqs.
    //pushing low end a little lower for kicks and giggles
    Ra = 500000.0f;  //Cds cell dark resistance.
    Ra = logf(Ra);		//this is done for clarity 
    Rb = 600.0f;         //Cds cell full illumination
    b = exp(Ra/logf(Rb)) - CNST_E;
    dTC = 0.085f;
    dRCl = dTC;
    dRCr = dTC;   //Right & left channel dynamic time contsants
    minTC = logf(0.005f/dTC);
    //cSAMPLE_RATE is 1/SAMPLE_RATE
    alphal = 1.0f - cSAMPLE_RATE/(dRCl + cSAMPLE_RATE);
    alphar = alphal;
    dalphal = dalphar = alphal;
    lampTC = cSAMPLE_RATE/(0.02 + cSAMPLE_RATE);  //guessing 10ms
    ilampTC = 1.0f - lampTC;
    lstep = 0.0f;
    rstep = 0.0f;
    Pdepth = 127;
    Ppanning = 64;
    lpanning = 1.0f;
    rpanning = 1.0f;
    fdepth = 1.0f;  
    oldgl = 0.0f;
    oldgr = 0.0f;
    gl = 0.0f;
    gr = 0.0f;
    for(int jj = 0; jj<8; jj++) oldcvolt[jj] = 0.0f;
    cperiod = 1.0f/fPERIOD;
    
    init_vibes();
    cleanup();
    
    }
    
    Vibe::~Vibe ()
    {
    }
    
    
    void
    Vibe::cleanup ()
    {
    //Yeah, clean up some stuff
    
    };
    
    void
    Vibe::out (float *smpsl, float *smpsr)
    {
    
      int i,j;
      float lfol, lfor, xl, xr, fxl, fxr;
      float vbe,vin;
      float cvolt, ocvolt, evolt, input;
      float emitterfb = 0.0f;
      float outl, outr;
      
      input = cvolt = ocvolt = evolt = 0.0f;
      
      lfo.effectlfoout (&lfol, &lfor);
    
      lfol = fdepth + lfol*fwidth;
      lfor = fdepth + lfor*fwidth;   
      
       if (lfol > 1.0f)
        lfol = 1.0f;
      else if (lfol < 0.0f)
        lfol = 0.0f;
      if (lfor > 1.0f)
        lfor = 1.0f;
      else if (lfor < 0.0f)
        lfor = 0.0f;  
        
        lfor = 2.0f - 2.0f/(lfor + 1.0f);   // 
        lfol = 2.0f - 2.0f/(lfol + 1.0f); //emulate lamp turn on/off characteristic by typical curves 
          
      for (i = 0; i < PERIOD; i++)
        {
        //Left Lamp
         gl = lfol*lampTC + oldgl*ilampTC; 
         oldgl = gl;  
        //Right Lamp
         gr = lfor*lampTC + oldgr*ilampTC; 
         oldgr = gr;   
           
        //Left Cds   
        stepl = gl*alphal + dalphal*oldstepl;
        oldstepl = stepl;
        dRCl = dTC*expf(stepl*minTC);
        alphal = cSAMPLE_RATE/(dRCl + cSAMPLE_RATE);  
        dalphal = 1.0f - cSAMPLE_RATE/(0.5f*dRCl + cSAMPLE_RATE);     //different attack & release character
        xl = CNST_E + stepl*b;
        fxl = expf(Ra/logf(xl));   
        
        //Right Cds   
        stepr = gr*alphar + dalphar*oldstepr;
        oldstepr = stepr;
        dRCr = dTC*expf(stepr*minTC);
        alphar = cSAMPLE_RATE/(dRCr + cSAMPLE_RATE);  
        dalphar = 1.0f - cSAMPLE_RATE/(0.5f*dRCr + cSAMPLE_RATE);      //different attack & release character
        xr = CNST_E + stepr*b;
        fxr = expf(Ra/logf(xr));
    
        if(i%16 == 0)  modulate(fxl, fxr);   
         
        //Left Channel  
    
       input = bjt_shape(fbl + smpsl[i]);  
    
        
        emitterfb = 25.0f/fxl;     
        for(j=0;j<4;j++) //4 stages phasing
        {
       cvolt = vibefilter(input,ecvc,j) + vibefilter(input + emitterfb*oldcvolt[j],vc,j);
       ocvolt = vibefilter(cvolt,vcvo,j);
       oldcvolt[j] = ocvolt;
       evolt = vibefilter(input, vevo,j);
        
       input = bjt_shape(ocvolt + evolt);
        }
        fbl = fb*ocvolt;
        outl = lpanning*input;    
        
        //Right channel
    
        input = bjt_shape(fbr + smpsr[i]);    
        
        emitterfb = 25.0f/fxr;     
        for(j=4;j<8;j++) //4 stages phasing
        {
       cvolt = vibefilter(input,ecvc,j) + vibefilter(input + emitterfb*oldcvolt[j],vc,j);
       ocvolt = vibefilter(cvolt,vcvo,j);
       oldcvolt[j] = ocvolt;
       evolt = vibefilter(input, vevo,j);
        
       input = bjt_shape(ocvolt + evolt);
        }
        
        fbr = fb*ocvolt;
        outr = rpanning*input;  
        
        efxoutl[i] = outl*fcross + outr*flrcross;
        efxoutr[i] = outr*fcross + outl*flrcross;
        
        };
     
    };
    
    float 
    Vibe::vibefilter(float data, fparams *ftype, int stage)
    {
    float y0 = 0.0f;
    y0 = data*ftype[stage].n0 + ftype[stage].x1*ftype[stage].n1 - ftype[stage].y1*ftype[stage].d1;
    ftype[stage].y1 = y0 + DENORMAL_GUARD;
    ftype[stage].x1 = data; 
    return y0;
    };
    
    float 
    Vibe::bjt_shape(float data)
    {
    float vbe, vout;
    float vin = 7.5f*(1.0f + data);
    if(vin<0.0f) vin = 0.0f;
    if(vin>15.0f) vin = 15.0f;
    vbe = 0.8f - 0.8f/(vin + 1.0f);  //really rough, simplistic bjt turn-on emulator
    vout = vin - vbe;
    vout = vout*0.1333333333f -0.90588f;  //some magic numbers to return gain to unity & zero the DC
    return vout;
    }
    
    void
    Vibe::init_vibes()
    {
    k = 2.0f*fSAMPLE_RATE;
    float tmpgain = 1.0f;
     R1 = 4700.0f;
     Rv = 4700.0f;
     C2 = 1e-6f;
     beta = 150.0f;  //transistor forward gain.
     gain = -beta/(beta + 1.0f); 
    
    //Univibe cap values 0.015uF, 0.22uF, 470pF, and 0.0047uF
    C1[0] = 0.015e-6f;
    C1[1] = 0.22e-6f;
    C1[2] = 470e-12f;
    C1[3] = 0.0047e-6f;
    C1[4] = 0.015e-6f;
    C1[5] = 0.22e-6f;
    C1[6] = 470e-12f;
    C1[7] = 0.0047e-6f;
    
    for(int i =0; i<8; i++)
    {
    //Vo/Ve driven from emitter
    en1[i] = k*R1*C1[i];
    en0[i] = 1.0f;
    ed1[i] = k*(R1 + Rv)*C1[i];
    ed0[i] = 1.0f + C1[i]/C2;
    
    // Vc~=Ve/(Ic*Re*alpha^2) collector voltage from current input.  
    //Output here represents voltage at the collector
    
    cn1[i] = k*gain*Rv*C1[i];
    cn0[i] = gain*(1.0f + C1[i]/C2);
    cd1[i] = k*(R1 + Rv)*C1[i];
    cd0[i] = 1.0f + C1[i]/C2;
    
    //Contribution from emitter load through passive filter network
    ecn1[i] = k*gain*R1*(R1 + Rv)*C1[i]*C2/(Rv*(C2 + C1[i]));
    ecn0[i] = 0.0f;
    ecd1[i] = k*(R1 + Rv)*C1[i]*C2/(C2 + C1[i]);
    ecd0[i] = 1.0f;
    
    // %Represents Vo/Vc.  Output over collector voltage
    on1[i] = k*Rv*C2;
    on0[i] = 1.0f;
    od1[i] = k*Rv*C2;
    od0[i] = 1.0f + C2/C1[i];
    
    //%Bilinear xform stuff
    tmpgain =  1.0f/(cd1[i] + cd0[i]);
    vc[i].n1 = tmpgain*(cn0[i] - cn1[i]);
    vc[i].n0 = tmpgain*(cn1[i] + cn0[i]);
    vc[i].d1 = tmpgain*(cd0[i] - cd1[i]);
    vc[i].d0 = 1.0f;
    
    tmpgain =  1.0f/(ecd1[i] + ecd0[i]);
    ecvc[i].n1 = tmpgain*(ecn0[i] - ecn1[i]);
    ecvc[i].n0 = tmpgain*(ecn1[i] + ecn0[i]);
    ecvc[i].d1 = tmpgain*(ecd0[i] - ecd1[i]);
    ecvc[i].d0 = 1.0f;
    
    tmpgain =  1.0f/(od1[i] + od0[i]);
    vcvo[i].n1 = tmpgain*(on0[i] - on1[i]);
    vcvo[i].n0 = tmpgain*(on1[i] + on0[i]);
    vcvo[i].d1 = tmpgain*(od0[i] - od1[i]);
    vcvo[i].d0 = 1.0f;
    
    tmpgain =  1.0f/(ed1[i] + ed0[i]);
    vevo[i].n1 = tmpgain*(en0[i] - en1[i]);
    vevo[i].n0 = tmpgain*(en1[i] + en0[i]);
    vevo[i].d1 = tmpgain*(ed0[i] - ed1[i]);
    vevo[i].d0 = 1.0f;
    
    // bootstrap[i].n1
    // bootstrap[i].n0
    // bootstrap[i].d1
    }
    
    
    };
    
    void
    Vibe::modulate(float ldrl, float ldrr)
    {
    float tmpgain;
    float R1pRv;
    float C2pC1;
    Rv = 4700.0f + ldrl;
    R1pRv = R1 + Rv;
    
    
    for(int i =0; i<8; i++)
    {
    if(i==4) {
    Rv = 4700.0f + ldrr;
    R1pRv = R1 + Rv;
    }
    
    C2pC1 = C2 + C1[i];
    //Vo/Ve driven from emitter
    ed1[i] = k*(R1pRv)*C1[i];
    //ed1[i] = R1pRv*kC1[i];
    
    // Vc~=Ve/(Ic*Re*alpha^2) collector voltage from current input.  
    //Output here represents voltage at the collector
    cn1[i] = k*gain*Rv*C1[i];
    //cn1[i] = kgainCl[i]*Rv;
    //cd1[i] = (R1pRv)*C1[i];
    cd1[i]=ed1[i];
    
    //Contribution from emitter load through passive filter network
    ecn1[i] = k*gain*R1*cd1[i]*C2/(Rv*(C2pC1));
    //ecn1[i] = iC2pC1[i]*kgainR1C2*cd1[i]/Rv;
    ecd1[i] = k*cd1[i]*C2/(C2pC1);
    //ecd1[i] = iC2pC1[i]*k*cd1[i]*C2/(C2pC1);
    
    // %Represents Vo/Vc.  Output over collector voltage
    on1[i] = k*Rv*C2;
    od1[i] = on1[i];
    
    //%Bilinear xform stuff
    tmpgain =  1.0f/(cd1[i] + cd0[i]);
    vc[i].n1 = tmpgain*(cn0[i] - cn1[i]);
    vc[i].n0 = tmpgain*(cn1[i] + cn0[i]);
    vc[i].d1 = tmpgain*(cd0[i] - cd1[i]);
    
    tmpgain =  1.0f/(ecd1[i] + ecd0[i]);
    ecvc[i].n1 = tmpgain*(ecn0[i] - ecn1[i]);
    ecvc[i].n0 = tmpgain*(ecn1[i] + ecn0[i]);
    ecvc[i].d1 = tmpgain*(ecd0[i] - ecd1[i]);
    ecvc[i].d0 = 1.0f;
    
    tmpgain =  1.0f/(od1[i] + od0[i]);
    vcvo[i].n1 = tmpgain*(on0[i] - on1[i]);
    vcvo[i].n0 = tmpgain*(on1[i] + on0[i]);
    vcvo[i].d1 = tmpgain*(od0[i] - od1[i]);
    
    tmpgain =  1.0f/(ed1[i] + ed0[i]);
    vevo[i].n1 = tmpgain*(en0[i] - en1[i]);
    vevo[i].n0 = tmpgain*(en1[i] + en0[i]);
    vevo[i].d1 = tmpgain*(ed0[i] - ed1[i]);
    
    }
    
    
    };

