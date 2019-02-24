Dynamic convolution
===================

- **Author or source:** Risto Holopainen
- **Type:** a naive implementation in C++
- **Created:** 2005-06-05 22:05:19


.. code-block:: text
    :caption: notes

    This class illustrates the use of dynamic convolution with a set of IR:s consisting of
    exponentially damped sinusoids with glissando. There's lots of things to improve for
    efficiency.


.. code-block:: c++
    :linenos:
    :caption: code

    #include <cmath>
    
    class dynaconv
    {
      public:
    // sr=sample rate, cf=resonance frequency, 
    // dp=frq sweep or nonlinearity amount 
    		dynaconv(const int sr, float cf, float dp);
    		double operator()(double);
    	
    	private:	
    // steps: number of amplitude regions, L: length of impulse response
    		enum {steps=258, dv=steps-2, L=200};
    		double x[L];
    		double h[steps][L]; 
    		int S[L];
    		double conv(double *x, int d);
    };
    
    
    
    dynaconv::dynaconv(const int sr, float cfr, float dp)
    {
    	for(int i=0; i<L; i++)
    		x[i] = S[i] = 0;
    	
    	double sc = 6.0/L;
    	double frq = twopi*cfr/sr;
    	
    // IR's initialised here. 
    // h[0] holds the IR for samples with lowest amplitude.
    	for(int k=0; k<steps; k++)
    		{
    		double sum = 0;
    		double theta=0;
    		double w;
    		for(int i=0; i<L; i++)
    			{
    	// IR of exp. decaying sinusoid with glissando
    			h[k][i] = sin(theta)*exp(-sc*i); 
    			w = (double)i/L;
    			theta += frq*(1 + dp*w*(k - 0.4*steps)/steps);
    			sum += fabs(h[k][i]);
    			}
    			
    		double norm = 1.0/sum;
    		for(int i=0; i<L; i++)
    			h[k][i] *= norm;
    		}
    }
    
    double dynaconv::operator()(double in)
    {
    	double A = fabs(in);
    	double a, b, w, y;
    	int sel = int(dv*A);
    	
    	for(int j=L-1; j>0; j--)
    		{
    		x[j] = x[j-1];
    		S[j] = S[j-1];
    		}
    	x[0] = in;
    	S[0] = sel;		
    	
    	if(sel == 0)
    		y = conv(x, 0);
    
    	else if(sel > 0)
    		{
    		a = conv(x, 0);
    		b = conv(x, 1);
    		w = dv*A - sel;
    		y = w*a + (1-w)*b;
    		}
    
    	return y;
    }
    
    double dynaconv::conv(double *x, int d)
    {
    	double y=0;
    	for(int i=0; i<L; i++)
    		y += x[i] * h[ S[i]+d ][i];
    
    	return y;	
    }
    
    

Comments
--------

- **Date**: 2005-06-06 08:26:12
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    You can speed things up by:
    
    a) rewriting the "double dynaconv::conv(double *x, int d)" function using Assembler, SSE and 3DNow
	routines.
    
    b) instead of this
    
    "else if(sel > 0)
    {
    a = conv(x, 0);
    b = conv(x, 1);
    w = dv*A - sel;
    y = w*a + (1-w)*b;
    }"
    
    you can create a temp IR by fading the two impulse responses before convolution. Then you'll only
	need ONE CPU-expensive-convolution.
    
    c) this one only works with the upper half wave!
    
    d) only nonlinear components can be modeled. For time-variant modeling (compressor/limiter) you'll
	need more than this.
    
    e) the algo is proteced by a patent. But it's easy to find more efficient ways, which aren't
	protected by the patent.
    
    With my implementation i can fold up to 4000 Samples (IR) in realtime on my machine.

- **Date**: 2005-07-20 13:52:49
- **By**: d.tniop@noitcerroc

.. code-block:: text

    Correction to d:
    
    d) only time invariant nonlinear components can be modeled; and then adequate memory must be used.
	Compressors/Limiters can be modelled, but the memory requirements will be somewhat frightening.
	Time-variant systems, such as flangers, phasors, and sub-harmonic generators (i.e. anything
	with an internal clock) will need more than this.

