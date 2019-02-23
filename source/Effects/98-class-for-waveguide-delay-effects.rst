Class for waveguide/delay effects
=================================

- **Author or source:** moc.xinortceletrams@urugra
- **Type:** IIR filter
- **Created:** 2002-04-23 06:46:34


.. code-block:: text
    :caption: notes

    Flexible-time, non-sample quantized delay , can be used for stuff like waveguide synthesis
    or time-based (chorus/flanger) fx.
    
    MAX_WG_DELAY is a constant determining MAX buffer size (in samples)


.. code-block:: c++
    :linenos:
    :caption: code

    class cwaveguide  
    {
    public:
    	cwaveguide(){clear();}
    	virtual ~cwaveguide(){};
    	
    	void clear()
    	{
    		counter=0;
    		for(int s=0;s<MAX_WG_DELAY;s++)
    			buffer[s]=0;
    	}
    	
    	inline float feed(float const in,float const feedback,double const delay)
    	{
    		// calculate delay offset
    		double back=(double)counter-delay;
    		
    		// clip lookback buffer-bound
    		if(back<0.0)
    			back=MAX_WG_DELAY+back;
    		
    		// compute interpolation left-floor
    		int const index0=floor_int(back);
    		
    		// compute interpolation right-floor
    		int index_1=index0-1;
    		int index1=index0+1;
    		int index2=index0+2;
    		
    		// clip interp. buffer-bound
    		if(index_1<0)index_1=MAX_WG_DELAY-1;
    		if(index1>=MAX_WG_DELAY)index1=0;
    		if(index2>=MAX_WG_DELAY)index2=0;
    		
    		// get neighbourgh samples
    		float const y_1= buffer [index_1];
    		float const y0 = buffer [index0];
    		float const y1 = buffer [index1];
    		float const y2 = buffer [index2];
    		
    		// compute interpolation x
    		float const x=(float)back-(float)index0;
    		
    		// calculate
    		float const c0 = y0;
    		float const c1 = 0.5f*(y1-y_1);
    		float const c2 = y_1 - 2.5f*y0 + 2.0f*y1 - 0.5f*y2;
    		float const c3 = 0.5f*(y2-y_1) + 1.5f*(y0-y1);
    		
    		float const output=((c3*x+c2)*x+c1)*x+c0;
    		
    		// add to delay buffer
    		buffer[counter]=in+output*feedback;
    		
    		// increment delay counter
    		counter++;
    		
    		// clip delay counter
    		if(counter>=MAX_WG_DELAY)
    			counter=0;
    		
    		// return output
    		return output;
    	}
    	
    	float	buffer[MAX_WG_DELAY];
    	int		counter;
    };
    

