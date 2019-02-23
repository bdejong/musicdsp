DFT
===

- **Author or source:** Andy Mucho
- **Type:** fourier transform
- **Created:** 2002-01-17 01:59:38



.. code-block:: c++
    :linenos:
    :caption: code

    AnalyseWaveform(float *waveform, int framesize)
    {
       float aa[MaxPartials];
       float bb[MaxPartials];
       for(int i=0;i<partials;i++)
       {
         aa[i]=0;
         bb[i]=0;
       }
    
       int hfs=framesize/2;
       float pd=pi/hfs;
       for (i=0;i<framesize;i++)
       {
         float w=waveform[i];
         int im = i-hfs;
         for(int h=0;h<partials;h++)
         {
            float th=(pd*(h+1))*im;
            aa[h]+=w*cos(th);
            bb[h]+=w*sin(th);
         }
       }
       for (int h=0;h<partials;h++)
           amp[h]= sqrt(aa[h]*aa[h]+bb[h]*bb[h])/hfs;
    }
