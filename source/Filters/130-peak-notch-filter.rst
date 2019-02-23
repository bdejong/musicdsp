Peak/Notch filter
=================

- **Author or source:** ed.bew@raebybot
- **Type:** peak/notch
- **Created:** 2002-12-16 19:01:28


.. code-block:: text
    :caption: notes

    // Peak/Notch filter
    // I don't know anymore where this came from, just found it on
    // my hard drive :-)
    // Seems to be a peak/notch filter with adjustable slope
    // steepness, though slope gets rather wide the lower the
    // frequency is.
    // "cut" and "steep" range is from 0..1
    // Try to feed it with white noise, then the peak output does
    // rather well eliminate all other frequencies except the given
    // frequency in higher frequency ranges.
    


.. code-block:: c++
    :linenos:
    :caption: code

    var f,r:single;
        outp,outp1,outp2:single; // init these with 0!
    const p4=1.0e-24; // Pentium 4 denormal problem elimination
    
    function PeakNotch(inp,cut,steep:single;ftype:integer):single;
    begin
     r:=steep*0.99609375;
     f:=cos(pi*cut);
     a0:=(1-r)*sqrt(r*(r-4*(f*f)+2)+1);
     b1:=2*f*r;
     b2:=-(r*r);
     outp:=a0*inp+b1*outp1+b2*outp2+p4;
     outp2:=outp1;
     outp1:=outp;
     if ftype=0 then 
      result:=outp //peak
     else 
      result:=inp-outp; //notch
    end;
    

Comments
--------

- **Date**: 2010-03-02 03:19:21
- **By**: slo77y (at) yahoo.de

.. code-block:: text

    this code sounds bitcrushed like hell translated to c++, any suggestions ?
    
    	float pi = 3.141592654;
    	float r = dQFactor*0.99609375;
    	float f = cos(pi*iFreq);
    	float a0 = (1-r) * sqrt ( r * ( r-4 * ( f * f ) + 2 ) + 1 );
    	float b1 = 2 * f * r;
    	float b2 = - ( r * r );
    	float outp = 0.0, outp1 = 0.0, outp2 = 0.0;
    
    	for (i = 0; i < iSamples; i++) 
    	{
    		float inp = fInput[i];
    
    		outp = a0 * inp + b1 * outp1 + b2 * outp2 + p4;
    		outp2 = outp1;
    		outp1 = outp;
    	
    		fOutput[i] = (inp-outp); //notch
    	}

- **Date**: 2012-05-05 08:22:08
- **By**: ten.xoc@53namhsima

.. code-block:: text

    After about 3 hours wondering why I was getting back the original un-altered audio, I finally got this version of a keeper filter, which I used with absurdly good success on a power grid comb filter. When the power grid filter was fed with audio from a lamp cord with one 1 Megohm resistor on each prong, all sorts of cool sounds become audio when the output is amplified 40 dB. For wall cord audio, use 60.0 for the cutoff.
    ---the function is below---
    double keeper_1(double input, double cutoff,double rate,double *magnitude)
    {
    	const double steepness=1.0;
    	const double p4=1.0e-24;
    	static unsigned char first=1;
    	static double nfreq=0.1;
    	static double old_cutoff=0.0;
    	static double the_magnitude=0;
    	static double average=0.0;
    	static int average_count=0;
    	static double a=0.0;
    	static double r=0.0;
    	static double coeff=0.0;
    	static double delay[3]={0.0,0.0,0.0};
    	static double delay1[3]={0.0,0.0,0.0};
    	static double delay2[3]={0.0,0.0,0.0};
    	static double delay3[3]={0.0,0.0,0.0};
    	static double b[3]={0.0,0.0,0.0};
    	if(first==1 || cutoff!=old_cutoff )
    	{
    		r=steepness * 0.99609375;
    		nfreq=(cutoff/(double)rate) * 2.0 ;
    		coeff= cos( M_PI * nfreq);
    		a=(1.0 - r) * sqrt(r * (r - 4 * (coeff * coeff) + 2) +1);
    		b[1]=2 * coeff * r;
    		b[2]=-(r * r);
    	
    		first=0;
    	}
    	
    	delay3[0] = a * input + b[1] * delay3[1] + b[2] * delay3[2] + p4;
    	
    	delay3[2]=delay3[1];
    	delay3[1]=delay3[0];
    	
    	
    	delay2[0] = a * delay3[0] + b[1] * delay2[1] + b[2] * delay2[2] + p4;
    	
    	delay2[2]=delay2[1];
    	delay2[1]=delay2[0];
    	
    	
    	
    	delay1[0] = a * delay2[0] + b[1] * delay1[1] + b[2] * delay1[2] + p4;
    	
    	delay1[2]=delay1[1];
    	delay1[1]=delay1[0];
    	
    	
    	delay[0] = a * delay1[0] + b[1] * delay[1] + b[2] * delay[2] + p4;
    	
    	delay[2]=delay[1];
    	delay[1]=delay[0];
    	average+=delay[0];
    	average_count++;
    	if(average_count>dft_size-1)
    	{
    		double aver=average/(double)dft_size;
    		the_magnitude=sqrt(aver * aver); /* we're only interested in the root mean square */
    		average=0.0;
    		average_count=0;
    	}
    	magnitude[0]=the_magnitude;
    	old_cutoff=cutoff;
    	return delay[0];
    }

