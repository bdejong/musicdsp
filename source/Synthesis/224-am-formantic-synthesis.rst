AM Formantic Synthesis
======================

- **Author or source:** Paul Sernine
- **Created:** 2006-07-05 20:14:14


.. code-block:: text
    :caption: notes

    Here is another tutorial from Doc Rochebois.
    It performs formantic synthesis without filters and without grains. Instead, it uses
    "double carrier amplitude modulation" to pitch shift formantic waveforms. Just beware the
    phase relationships to avoid interferences. Some patches of the DX7 used the same trick
    but phase interferences were a problem. Here, Thierry Rochebois avoids them by using
    cosine-phased waveforms.
    
    Various formantic waveforms are precalculated and put in tables, they correspond to
    different formant widths.
    The runtime uses many intances (here 4) of these and pitch shifts them with double
    carriers (to preserve the harmonicity of the signal).
    
    This is a tutorial code, it can be optimized in many ways.
    Have Fun
    
    Paul


.. code-block:: c++
    :linenos:
    :caption: code

    // FormantsAM.cpp
    
    // Thierry Rochebois' "Formantic Synthesis by Double Amplitude Modulation"
    
    // Based on a tutorial by Thierry Rochebois.
    // Comments by Paul Sernine.
    
    // The spectral content of the signal is obtained by adding amplitude modulated formantic
    // waveforms. The amplitude modulations spectraly shift the formantic waveforms.
    // Continuous spectral shift, without losing the harmonic structure, is obtained
    // by using crossfaded double carriers (multiple of the base frequency).
    // To avoid  unwanted interference artifacts, phase relationships must be of the
    // "cosine type".
    
    // The output is a 44100Hz 16bit stereo PCM file.
    
    #include <math.h>
    #include <stdio.h>
    #include <stdlib.h>
    
    //Approximates cos(pi*x) for x in [-1,1].
    inline float fast_cos(const float x)
    {
      float x2=x*x;
      return 1+x2*(-4+2*x2);
    }
    
    //Length of the table
    #define L_TABLE (256+1) //The last entry of the table equals the first (to avoid a modulo)
    //Maximal formant width
    #define I_MAX 64
    //Table of formants
    float TF[L_TABLE*I_MAX];
    
    //Formantic function of width I (used to fill the table of formants)
    float fonc_formant(float p,const float I)
    {
      float a=0.5f;
      int hmax=int(10*I)>L_TABLE/2?L_TABLE/2:int(10*I);
      float phi=0.0f;
      for(int h=1;h<hmax;h++)
      {
        phi+=3.14159265359f*p;
        float hann=0.5f+0.5f*fast_cos(h*(1.0f/hmax));
        float gaussienne=0.85f*exp(-h*h/(I*I));
        float jupe=0.15f;
        float harmonique=cosf(phi);
        a+=hann*(gaussienne+jupe)*harmonique;
       }
      return a;
    }
    
    //Initialisation of the table TF with the fonction fonc_formant.
    void init_formant(void)
    { float coef=2.0f/(L_TABLE-1);
      for(int I=0;I<I_MAX;I++)
        for(int P=0;P<L_TABLE;P++)
          TF[P+I*L_TABLE]=fonc_formant(-1+P*coef,float(I));
    }
    
    //This function emulates the function fonc_formant
    // thanks to the table TF. A bilinear interpolation is
    // performed
    float formant(float p,float i)
    {
      i=i<0?0:i>I_MAX-2?I_MAX-2:i;    // width limitation
    	float P=(L_TABLE-1)*(p+1)*0.5f; // phase normalisation
    	int P0=(int)P; 	float fP=P-P0;  // Integer and fractional
    	int I0=(int)i; 	float fI=i-I0;  // parts of the phase (p) and width (i).
    	int i00=P0+L_TABLE*I0; 	int i10=i00+L_TABLE;
    	//bilinear interpolation.
    	return (1-fI)*(TF[i00] + fP*(TF[i00+1]-TF[i00]))
            +    fI*(TF[i10] + fP*(TF[i10+1]-TF[i10]));
    }
    
    // Double carrier.
    // h : position (float harmonic number)
    // p : phase
    float porteuse(const float h,const float p)
    {
      float h0=floor(h);  //integer and
      float hf=h-h0;      //decimal part of harmonic number.
      // modulos pour ramener p*h0 et p*(h0+1) dans [-1,1]
      float phi0=fmodf(p* h0   +1+1000,2.0f)-1.0f;
      float phi1=fmodf(p*(h0+1)+1+1000,2.0f)-1.0f;
      // two carriers.
      float Porteuse0=fast_cos(phi0);  float Porteuse1=fast_cos(phi1);
      // crossfade between the two carriers.
      return Porteuse0+hf*(Porteuse1-Porteuse0);
    }
    int main()
    {
      //Formant table for various french vowels (you can add your own)
      float F1[]={  730,  200,  400,  250,  190,  350,  550,  550,  450};
      float A1[]={ 1.0f, 0.5f, 1.0f, 1.0f, 0.7f, 1.0f, 1.0f, 0.3f, 1.0f};
      float F2[]={ 1090, 2100,  900, 1700,  800, 1900, 1600,  850, 1100};
      float A2[]={ 2.0f, 0.5f, 0.7f, 0.7f,0.35f, 0.3f, 0.5f, 1.0f, 0.7f};
      float F3[]={ 2440, 3100, 2300, 2100, 2000, 2500, 2250, 1900, 1500};
      float A3[]={ 0.3f,0.15f, 0.2f, 0.4f, 0.1f, 0.3f, 0.7f, 0.2f, 0.2f};
      float F4[]={ 3400, 4700, 3000, 3300, 3400, 3700, 3200, 3000, 3000};
      float A4[]={ 0.2f, 0.1f, 0.2f, 0.3f, 0.1f, 0.1f, 0.3f, 0.2f, 0.3f};
    
      float f0,dp0,p0=0.0f;
      int F=7; //number of the current formant preset
      float f1,f2,f3,f4,a1,a2,a3,a4;
      f1=f2=f3=f4=100.0f;a1=a2=a3=a4=0.0f;
    
      init_formant();
      FILE *f=fopen("sortie.pcm","wb");
      for(int ns=0;ns<10*44100;ns++)
      {
        if(0==(ns%11025)){F++;F%=8;} //formant change
        f0=12*powf(2.0f,4-4*ns/(10*44100.0f)); //sweep
        f0*=(1.0f+0.01f*sinf(ns*0.0015f));        //vibrato
        dp0=f0*(1/22050.0f);
        float un_f0=1.0f/f0;
        p0+=dp0;  //phase increment
        p0-=2*(p0>1);
        { //smoothing of the commands.
          float r=0.001f;
          f1+=r*(F1[F]-f1);f2+=r*(F2[F]-f2);f3+=r*(F3[F]-f3);f4+=r*(F4[F]-f4);
          a1+=r*(A1[F]-a1);a2+=r*(A2[F]-a2);a3+=r*(A3[F]-a3);a4+=r*(A4[F]-a4);
        }
    
        //The f0/fn coefficients stand for a -3dB/oct spectral enveloppe
        float out=
               a1*(f0/f1)*formant(p0,100*un_f0)*porteuse(f1*un_f0,p0)
         +0.7f*a2*(f0/f2)*formant(p0,120*un_f0)*porteuse(f2*un_f0,p0)
         +     a3*(f0/f3)*formant(p0,150*un_f0)*porteuse(f3*un_f0,p0)
         +     a4*(f0/f4)*formant(p0,300*un_f0)*porteuse(f4*un_f0,p0);
    
        short s=short(15000.0f*out);
        fwrite(&s,2,1,f);fwrite(&s,2,1,f); //fichier raw pcm stereo
      }
      fclose(f);
      return 0;
    }
    

Comments
--------

- **Date**: 2007-04-24 12:04:12
- **By**: Baltazar

.. code-block:: text

    Quite interesting and efficient for an algo that does not use any filter ;-)              

- **Date**: 2007-08-14 11:30:14
- **By**: phoenix-69

.. code-block:: text

    Very funny sound !

- **Date**: 2008-08-19 20:51:30
- **By**: Wait.

.. code-block:: text

                  What header files are you including?

