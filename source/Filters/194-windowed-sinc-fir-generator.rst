Windowed Sinc FIR Generator
===========================

- **Author or source:** Bob Maling
- **Type:** LP, HP, BP, BS
- **Created:** 2005-04-12 20:19:47

- **Linked files:** :download:`wsfir.h <../files/wsfir.h>`.

.. code-block:: text
    :caption: notes

    This code generates FIR coefficients for lowpass, highpass, bandpass, and bandstop filters
    by windowing a sinc function.
    
    The purpose of this code is to show how windowed sinc filter coefficients are generated.
    Also shown is how highpass, bandpass, and bandstop filters can be made from lowpass
    filters.
    
    Included windows are Blackman, Hanning, and Hamming. Other windows can be added by
    following the structure outlined in the opening comments of the header file.



Comments
--------

- **Date**: 2005-04-15 00:02:33
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    // Object Pascal Port...
    
    unit SincFIR;
    
    (* Windowed Sinc FIR Generator
       Bob Maling (BobM.DSP@gmail.com)
       Contributed to musicdsp.org Source Code Archive
       Last Updated: April 12, 2005
       Translated to Object Pascal by Christian-W. Budde
    
       Usage:
       Lowpass:wsfirLP(H, WindowType, CutOff)
       Highpass:wsfirHP(H, WindowType, CutOff)
       Bandpass:wsfirBP(H, WindowType, LowCutOff, HighCutOff)
       Bandstop:wsfirBS(H, WindowType, LowCutOff, HighCutOff)
    
       where:
       H (TDoubleArray): empty filter coefficient table (SetLength(H,DesiredLength)!)
       WindowType (TWindowType): wtBlackman, wtHanning, wtHamming
       CutOff (double): cutoff (0 < CutOff < 0.5, CutOff = f/fs)
       --> for fs=48kHz and cutoff f=12kHz, CutOff = 12k/48k => 0.25
    
       LowCutOff (double):low cutoff (0 < CutOff < 0.5, CutOff = f/fs)
       HighCutOff (double):high cutoff (0 < CutOff < 0.5, CutOff = f/fs)
    
       Windows included here are Blackman, Blackman-Harris, Gaussian, Hanning
       and Hamming.*)
    
    interface
    
    uses Math;
    
    type TDoubleArray = array of Double;
         TWindowType = (wtBlackman, wtHanning, wtHamming, wtBlackmanHarris,
                        wtGaussian); // Window type contstants
    
    // Function prototypes
    procedure wsfirLP(var H : TDoubleArray; const WindowType : TWindowType; const CutOff : Double);
    procedure wsfirHP(var H : TDoubleArray; const WindowType : TWindowType; const CutOff : Double);
    procedure wsfirBS(var H : TDoubleArray; const WindowType : TWindowType; const LowCutOff, HighCutOff : Double);
    procedure wsfirBP(var H : TDoubleArray; const WindowType : TWindowType; const LowCutOff, HighCutOff : Double);
    procedure genSinc(var Sinc : TDoubleArray; const CutOff : Double);
    procedure wGaussian(var W : TDoubleArray);
    procedure wBlackmanHarris(var W : TDoubleArray);
    procedure wBlackman(var W : TDoubleArray);
    procedure wHanning(var W : TDoubleArray);
    procedure wHamming(var W : TDoubleArray);
    
    implementation
    
    // Generate lowpass filter
    // This is done by generating a sinc function and then windowing it
    procedure wsfirLP(var H : TDoubleArray; const WindowType : TWindowType; const CutOff : Double);
    begin
     genSinc(H, CutOff);     // 1. Generate Sinc function
     case WindowType of  // 2. Generate Window function -> lowpass filter!
      wtBlackman: wBlackman(H);
      wtHanning: wHanning(H);
      wtHamming: wHamming(H);
      wtGaussian: wGaussian(H);
      wtBlackmanHarris: wBlackmanHarris(H);
     end;
    end;
    
    // Generate highpass filter
    // This is done by generating a lowpass filter and then spectrally inverting it
    procedure wsfirHP(var H : TDoubleArray; const WindowType : TWindowType; const CutOff : Double);
    var i : Integer;
    begin
     wsfirLP(H, WindowType, CutOff); // 1. Generate lowpass filter
    
     // 2. Spectrally invert (negate all samples and add 1 to center sample) lowpass filter
     // = delta[n-((N-1)/2)] - h[n], in the time domain
     for i:=0 to Length(H)-1
      do H[i]:=H[i]*-1.0;
     H[(Length(H)-1) div 2]:=H[(Length(H)-1) div 2]+1.0;
    end;
    
    // Generate bandstop filter
    // This is done by generating a lowpass and highpass filter and adding them
    procedure wsfirBS(var H : TDoubleArray; const WindowType : TWindowType; const LowCutOff, HighCutOff : Double);
    var i  : Integer;
        H2 : TDoubleArray;
    begin
     SetLength(H2,Length(H));
    
     // 1. Generate lowpass filter at first (low) cutoff frequency
     wsfirLP(H, WindowType, LowCutOff);
    
     // 2. Generate highpass filter at second (high) cutoff frequency
     wsfirHP(H2, WindowType, HighCutOff);
    
     // 3. Add the 2 filters together
     for i:=0 to Length(H)-1
      do H[i]:=H[i]+H2[i];
    
     SetLength(H2,0);
    end;
    
    // Generate bandpass filter
    // This is done by generating a bandstop filter and spectrally inverting it
    procedure wsfirBP(var H : TDoubleArray; const WindowType : TWindowType; const LowCutOff, HighCutOff : Double);
    var i : Integer;
    begin
     wsfirBS(H, WindowType, LowCutOff, HighCutOff); // 1. Generate bandstop filter
    
     // 2. Spectrally invert (negate all samples and add 1 to center sample) lowpass filter
     // = delta[n-((N-1)/2)] - h[n], in the time domain
     for i:=0 to Length(H)-1
      do H[i]:=H[i]*-1.0;
     H[(Length(H)-1) div 2]:=H[(Length(H)-1) div 2]+1.0;
    end;
    
    // Generate sinc function - used for making lowpass filter
    procedure genSinc(var Sinc : TDoubleArray; const Cutoff : Double);
    var i,j  : Integer;
        n,k  : Double;
    begin
     j:=Length(Sinc)-1;
     k:=1/j;
     // Generate sinc delayed by (N-1)/2
     for i:=0 to j do
      if (i=j div 2)
       then Sinc[i]:=2.0*Cutoff
       else
        begin
         n:=i-j/2.0;
         Sinc[i]:=sin(2.0*PI*Cutoff*n)/(PI*n);
        end;
    end;
    
    // Generate window function (Gaussian)
    procedure wGaussian(var W : TDoubleArray);
    var i,j : Integer;
        k   : Double;
    begin
     j:=Length(W)-1;
     k:=1/j;
     for i:=0 to j
      do W[i]:=W[i]*(exp(-5.0/(sqr(j))*(2*i-j)*(2*i-j)));
    end;
    
    // Generate window function (Blackman-Harris)
    procedure wBlackmanHarris(var W : TDoubleArray);
    var i,j : Integer;
        k   : Double;
    begin
     j:=Length(W)-1;
     k:=1/j;
     for i:=0 to j
      do W[i]:=W[i]*(0.35875-0.48829*cos(2*PI*(i+0.5)*k)+0.14128*cos(4*PI*(i+0.5)*k)-0.01168*cos(6*PI*(i+0.5)*k));
    end;
    
    // Generate window function (Blackman)
    procedure wBlackman(var W : TDoubleArray);
    var i,j : Integer;
        k   : Double;
    begin
     j:=Length(W)-1;
     k:=1/j;
     for i:=0 to j
      do W[i]:=W[i]*(0.42-(0.5*cos(2*PI*i*k))+(0.08*cos(4*PI*i*k)));
    end;
    
    // Generate window function (Hanning)
    procedure wHanning(var W : TDoubleArray);
    var i,j : Integer;
        k   : Double;
    begin
     j:=Length(W)-1;
     k:=1/j;
     for i:=0 to j
      do W[i]:=W[i]*(0.5*(1.0-cos(2*PI*i*k)));
    end;
    
    // Generate window function (Hamming)
    procedure wHamming(var W : TDoubleArray);
    var i,j : Integer;
        k   : Double;
    begin
     j:=Length(W)-1;
     k:=1/j;
     for i:=0 to j
      do W[i]:=W[i]*(0.54-(0.46*cos(2*PI*i*k)));
    end;
    
    end.              

- **Date**: 2007-01-06 04:23:59
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    The Hanning window is often incorrecty referred to as 'Hanning', since it was named after a guy called Julius von Hann. So it's more appropriate to call it 'Hann' window.
    

- **Date**: 2007-09-02 20:33:31
- **By**: Dave in sinc land

.. code-block:: text

    I've seen a BASIC version of the same genSinc code.
    Shouldn't a 'sin(2.0*Cutoff)' be used when the divide by zero check is 0?
    ...
      if (i=j div 2)
       then Sinc[i]:=2.0*Cutoff
       else
        begin
         n:=i-j/2.0;
         Sinc[i]:=sin(2.0*PI*Cutoff*n)/(PI*n);
        end;
    ...

- **Date**: 2007-09-02 21:22:35
- **By**: Dave in sinc land

.. code-block:: text

    Scrap that, I've just FFT'd the response, and it appears to be correct as it was. Hey it just looked wrong o.k.  ;)

- **Date**: 2008-09-08 00:57:52
- **By**: moc.liamg@olleocisuor

.. code-block:: text

    What do I have to do to apply this windowed sinc filter to a signal "Y" for example... what is the code for this?
    Imagine signal "Y" is a stereo song which means that I have Y1 from channel 1 and Y2 from channel 2.. help me please as soon as posible because at least i want to know how to aplly the filter to any signal... 

- **Date**: 2012-06-10 07:57:12
- **By**: ten.xoc@53namhsima

.. code-block:: text

    Here is a FIR filter that works with up to about 80 coefficients on a Sony PSP running at 280 Megahertz. The multipliers (8191.0 and 32767.0) may need to be incremented by one, or not. You need to call 'fir_filter' with the sample to process in 'sample' and the floating point coefficents in '*coefs' and how long the entire filter is in 'len' and the returned sample is a 16 bit audio (signed short) sample. When it is first run it will normalize the filter.
    
    /* code starts here, remove spaces between the includes */
    #include < math.h >
    #include < string.h >
    #include < stdio.h >
    #include < stdlib.h >
                  void normalizeCoefs(signed short *firshort, signed short *outfilter, unsigned long len)
    {
    	// filter gain at uniform frequency intervals
    	double *g=NULL;
    	double *dtemp=NULL;
    	double theta, s, c, sac, sas;
    	double gMax = -100.0;
    	double sc = 10.0/log(10.0);
    	double t = M_PI / len;
    	long i=0;
    	long n=len-1;
    	double normFactor =0;
    	g=(double*)malloc((len+1)*sizeof(double));
    	dtemp=(double*)malloc((len+1)*sizeof(double));
    	for (i=0; i<len; i++) 
    	{
    		dtemp[i]=firshort[i]/32768.0;
    	}
    	for (i=0; i<len; i++) 
    	{
    		theta = i*t;
    		sac = 0.0;
    		sas = 0.0;
    		long k=0;
    		for (k=0; k<len; k++) 
    		{
    			c =cos(k*theta);
    			s =sin(k*theta);
    			sac += c*(dtemp[k]);
    			sas += s*(dtemp[k]);
    		}
    		g[i] = sc*log(sac*sac + sas*sas);
    		if(g[i]>gMax)
    		{
    			gMax=g[i];
    		}      
    	}
    	// normalise to 0 dB maximum gain
    	for (i=0; i<len; i++)
    	{
    		g[i] -= gMax;
    	}
    	// normalise coefficients
    	normFactor =0;pow(10.0, -0.05*gMax);
    	for (i=0; i<len; i++)
    	{
    		dtemp[i] *= normFactor;
    	}
    	n=len-1;
    	for (i=0; i<len; i++)
    	{
    		outfilter[i]=dtemp[n--]*32767.0;
    	}
    	free(dtemp);
    	free(g);
      }
      
    signed short generalFIR(short input, short *coefs, unsigned long len,unsigned char resetit)
    {
    	
    	static signed short *delay_line=NULL;
    	static unsigned int first=1;
    	static signed long reacc=0;
    	unsigned long filtcnt=0;
    	static int consumer=1;
    	static int producer=0;
    	unsigned long tx=0;
    	if(resetit==1)
    	{
    		first=1;
    	}
    	if(first==1)
    	{
    		if(delay_line!=NULL)
    			free(delay_line);
    		producer=0;
    		consumer=1;
    		delay_line=(signed short*)malloc(reallen*sizeof(signed short));
    		first=0;
    	}
    	reacc=0;
    	delay_line[producer++]=input;
    	if(producer>len-1)
    	{
    		producer-=len;
    	}
    	int filtptr=consumer;
    	for(tx=0;tx<len;tx++)
    	{
    		reacc+=(delay_line[filtptr++]*coefs[tx]);
    		if(filtptr>len-1)
    		{
    			filtptr-=len;
    		}
    		
    	}
    	consumer++;
    	if(consumer>len-1)
    	{
    		consumer-=len;
    	}
    	reacc = reacc >> 15;
    	if(reacc<-32768)
    		reacc= -32768;
    	if(reacc>32767)
    		reacc=32767;
    	return (signed short)reacc;
    }
    
    
    signed short fir_filter(signed short sample,double *coefs,unsigned long len)
    {
    	static unsigned char first=1;
    	static signed short *newfir=NULL;
    	if(first==1)
    	{
    		unsigned long i=0;
    		if(newfir!=NULL)
    		{
    			free(newfir);
    			newfir=NULL;
    		}
    		newfir=(signed short*)malloc((filterorder+1) * sizeof(signed short));
    		if(newfir==NULL)
    		{
    			return 0;
    		}
    		for(k=0;k<len;k++)
    		{
    			newfir[k]=coefs[k] * 8191.0;
    		}
    		normalizeCoefs(newfir,newfir,len);
    		generalFIR(0,newfir,len,1);
    		first=0;
    	}
    	return generalFIR(sample,newfir,len,0);
    }
    

