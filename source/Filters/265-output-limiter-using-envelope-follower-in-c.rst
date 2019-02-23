Output Limiter using Envelope Follower in C++
=============================================

- **Author or source:** moc.oohay@nniveht
- **Created:** 2009-04-27 08:46:35


.. code-block:: text
    :caption: notes

    Here's a Limiter class that will automatically compress a signal if it would cause
    clipping.
    
    You can control the attack and decay parameters of the limiter. The attack determines how
    quickly the limiter will respond to a sudden increase in output level. I have found that
    attack=10ms and decay=500ms works very well for my application.
    
    This C++ example demonstrates the use of template parameters to allow the same piece of
    code to work with either floats or doubles (without needing to make a duplicate of the
    code). As well as allowing the same code to work with interleaved audio data (any number
    of channels) or linear, via the "skip" parameter. Note that even in this case, the
    compiler produces fully optimized output in the case where the template is instantiated
    for a compile-time constant value of skip.
    
    In Limiter::Process() you can see the envelope class getting called for one sample, this
    shows how even calling a function for a single sample can get fully optimized out by the
    compiler if code is structured correctly.
    
    While this is a fairly simple algorithm, I wanted to share the technique for using
    template parameters to develop routines that can work with any size floating point
    representation or multichannel audio data, while still remaining fully optimized.
    
    These classes were based on ideas found in the musicdsp.org archives.
    


.. code-block:: c++
    :linenos:
    :caption: code

    class EnvelopeFollower
    {
    public:
    	EnvelopeFollower();
    
    	void Setup( double attackMs, double releaseMs, int sampleRate );
    
    	template<class T, int skip>
    	void Process( size_t count, const T *src );
    
    	double envelope;
    
    protected:
    	double a;
    	double r;
    };
    
    //----------
    
    inline EnvelopeFollower::EnvelopeFollower()
    {
    	envelope=0;
    }
    
    inline void EnvelopeFollower::Setup( double attackMs, double releaseMs, int sampleRate )
    {
    	a = pow( 0.01, 1.0 / ( attackMs * sampleRate * 0.001 ) );
    	r = pow( 0.01, 1.0 / ( releaseMs * sampleRate * 0.001 ) );
    }
    
    template<class T, int skip>
    void EnvelopeFollower::Process( size_t count, const T *src )
    {
    	while( count-- )
    	{
    		double v=::fabs( *src );
    		src+=skip;
    		if( v>envelope )
    			envelope = a * ( envelope - v ) + v;
    		else
    			envelope = r * ( envelope - v ) + v;
    	}
    }
    
    //----------
    
    struct Limiter
    {
    	void Setup( double attackMs, double releaseMs, int sampleRate );
    
    	template<class T, int skip>
    	void Process( size_t nSamples, T *dest );
    
    private:
    	EnvelopeFollower e;
    };
    
    //----------
    
    inline void Limiter::Setup( double attackMs, double releaseMs, int sampleRate )
    {
    	e.Setup( attackMs, releaseMs, sampleRate );
    }
    
    template<class T, int skip>
    void Limiter::Process( size_t count, T *dest )
    {
    	while( count-- )
    	{
    		T v=*dest;
    		// don't worry, this should get optimized
    		e.Process<T, skip>( 1, &v );
    		if( e.envelope>1 )
    			*dest=*dest/e.envelope;
    		dest+=skip;
    	}
    }
    

