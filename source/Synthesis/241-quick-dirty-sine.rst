Quick & Dirty Sine
==================

- **Author or source:** MisterToast
- **Type:** Sine Wave Synthesis
- **Created:** 2007-01-08 10:50:10


.. code-block:: text
    :caption: notes

    This is proof of concept only (but code works--I have it in my synth now).
    
    Note that x must come in as 0<x<=4096. If you want to scale it to something else (like
    0<x<=2*M_PI), do it in the call. Or do the math to scale the constants properly.
    
    There's not much noise in here. A few little peaks here and there. When the signal is at
    -20dB, the worst noise is at around -90dB.
    
    For speed, you can go all floats without much difference. You can get rid of that unitary
    negate pretty easily, as well. A couple other tricks can speed it up further--I went for
    clarity in the code.
    
    The result comes out a bit shy of the range -1<x<1. That is, the peak is something like
    0.999.
    
    Where did this come from? I'm experimenting with getting rid of my waveform tables, which
    require huge amounts of memory. Once I had the Hamming anti-ringing code in, it looked
    like all my waveforms were smooth enough to approximate with curves. So I started with
    sine. Pulled my table data into Excel and then threw the data into a curve-fitting
    application.
    
    This would be fine for a synth. The noise is low enough that you could easily get away
    with it. Ideal for a low-memory situation. My final code will be a bit harder to
    understand, as I'll break the curve up and curve-fit smaller sections.


.. code-block:: c++
    :linenos:
    :caption: code

    float xSin(double x)
    {
    	//x is scaled 0<=x<4096
    	const double A=-0.015959964859;
    	const double B=217.68468676;
    	const double C=0.000028716332164;
    	const double D=-0.0030591066066;
    	const double E=-7.3316892871734489e-005;
    	double y;
    
    	bool negate=false;
    	if (x>2048)
    	{
    		negate=true;
    		x-=2048;
    	}
    	if (x>1024)
    		x=2048-x;
    	if (negate)
    		y=-((A+x)/(B+C*x*x)+D*x-E);
    	else
    		y=(A+x)/(B+C*x*x)+D*x-E;
    	return (float)y;
    }

Comments
--------

- **Date**: 2007-01-08 18:39:26
- **By**: moc.dniftnacuoyerehwemos@tsaot

.. code-block:: text

    Improved version:
    
    float xSin(double x)
    {
    	//x is scaled 0<=x<4096
    	const double A=-0.40319426317E-08;
    	const double B=0.21683205691E+03;
    	const double C=0.28463350538E-04;
    	const double D=-0.30774648337E-02;
    	double y;
    
    	bool negate=false;
    	if (x>2048)
    	{
    		negate=true;
    		x-=2048;
    	}
    	if (x>1024)
    		x=2048-x;
    	y=(A+x)/(B+C*x*x)+D*x;
    	if (negate)
    		return (float)(-y);
    	else
    		return (float)y;
    }

- **Date**: 2007-04-15 23:54:56
- **By**: ten.zo@1otniped

.. code-block:: text

    %This is Matlab code. you can convert it to C
    %All it take to make a high quality sine
    %wave is 1 multiply and one subtract.
    %You first have to initialize the 2 unit delays
    % and the coefficient
     
    Fs = 48000;      %Sample rate
    oscfreq = 1000.0; %Oscillator frequency in Hz
    c1 = 2 * cos(2 * pi * oscfreq / Fs);
    %Initialize the unit delays
    d1 = sin(2 * pi * oscfreq / Fs);   
    d2 = 0;
    %Initialization done here is the oscillator loop
    % which generates a sinewave
    for j=1:100
       output = d1;        %This is the sine value   
       fprintf(1, '%f\n', output);
       %one multiply and one subtract is all it takes 
       d0 = d1 * c1 - d2;
       d2 = d1;   %Shift the unit delays
       d1 = d0;   
    end            

- **Date**: 2008-02-09 20:54:10
- **By**: moc.liamg@iratuusala.osuuj

.. code-block:: text

    Hi,
    
    Can I use this code in a GPL2 or GPL3 licensed program (a soft synth project called Snarl)? In other words, will you grant permission for me to re-license your code? And what name should I write down as copyright holder in the headers?
    
    Thanks,
    Juuso Alasuutari

- **Date**: 2009-06-23 03:12:13
- **By**: by moc.dniftnacuoyerehwemos@tsaot

.. code-block:: text

    Juuso,
    
    Absolutely!
    
    Toast

