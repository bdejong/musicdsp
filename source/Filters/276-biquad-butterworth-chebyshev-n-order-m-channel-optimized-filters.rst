Biquad, Butterworth, Chebyshev N-order, M-channel  optimized filters
====================================================================

- **Author or source:** moc.oohay@nniveht
- **Type:** LP, HP, BP, BS, Shelf, Notch, Boost
- **Created:** 2009-11-16 08:46:34



.. code-block:: c++
    :linenos:
    :caption: code

    /*
    
    "A Collection of Useful C++ Classes for Digital Signal Processing"
    By Vincent Falco
    
    Please direct all comments to either the music-dsp mailing list or
    the DSP and Plug-in Development forum:
    
    	http://music.columbia.edu/cmc/music-dsp/
    	
    	http://www.kvraudio.com/forum/viewforum.php?f=33
    	http://www.kvraudio.com/forum/
    
    Support is provided for performing N-order Dsp floating point filter
    operations on M-channel data with a caller specified floating point type.
    The implementation breaks a high order IIR filter down into a series of
    cascaded second order stages. Tests conclude that numerical stability is
    maintained even at higher orders. For example the Butterworth low pass
    filter is stable at up to 53 poles.
    
    Processing functions are provided to use either Direct Form I or Direct
    Form II of the filter transfer function. Direct Form II is slightly faster
    but can cause discontinuities in the output if filter parameters are changed
    during processing. Direct Form I is slightly slower, but maintains fidelity
    even when parameters are changed during processing.
    
    To support fast parameter changes, filters provide two functions for
    adjusting parameters. A high accuracy Setup() function, and a faster
    form called SetupFast() that uses approximations for trigonometric
    functions. The approximations work quite well and should be suitable for
    most applications.
    
    Channels are stored in an interleaved format with M samples per frame
    arranged contiguously. A single class instance can process all M channels
    simultaneously in an efficient manner. A 'skip' parameter causes the
    processing function to advance by skip additional samples in the destination
    buffer in between every frame. Through manipulation of the skip paramter it
    is possible to exclude channels from processing (for example, only processing
    the left half of stereo interleaved data). For multichannel data which is
    not interleaved, it will be necessary to instantiate multiple instance of
    the filter and set skip=0.
    
    There are a few other utility classes and functions included that may prove useful.
    
    Classes:
    
    Complex
    CascadeStages
    	Biquad
    		BiquadLowPass
    		BiquadHighPass
    		BiquadBandPass1
    		BiquadBandPass2
    		BiquadBandStop
    		BiquadAllPass
    		BiquadPeakEq
    		BiquadLowShelf
    		BiquadHighShelf
    	PoleFilter
    		Butterworth
    			ButterLowPass
    			ButterHighPass
    			ButterBandPass
    			ButterBandStop
    		Chebyshev1
    			Cheby1LowPass
    			Cheby1HighPass
    			Cheby1BandPass
    			Cheby1BandStop
    		Chebyshev2
    			Cheby2LowPass
    			Cheby2HighPass
    			Cheby2BandPass
    			Cheby2BandStop
    EnvelopeFollower
    AutoLimiter
    
    Functions:
    
    	zero()
    	copy()
    	mix()
    	scale()
    
    	interleave()
    	deinterleave()
    
    Order for PoleFilter derived classes is specified in the number of poles,
    except for band pass and band stop filters, for which the number of pole pairs
    is specified.
    
    For some filters there are two versions of Setup(), the one called
    SetupFast() uses approximations to trigonometric functions for speed.
    This is an option if you are doing frequent parameter changes to the filter.
    
    There is an example function at the bottom that shows how to use the classes.
    
    Filter ideas are based on a java applet (http://www.falstad.com/dfilter/)
    developed by Paul Falstad.
    
    All of this code was written by the author Vincent Falco except where marked.
    
    --------------------------------------------------------------------------------
    
    License: MIT License (http://www.opensource.org/licenses/mit-license.php)
    Copyright (c) 2009 by Vincent Falco
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
     *
     */
    /*
    	To Do:
    
    	- Shelving, peak, all-pass for Butterworth, Chebyshev, and Elliptic.
    
    		The Biquads have these versions and I would like the others to have them
    		as well. It would also be super awesome if higher order filters could
    		have a "Q" parameter for resonance but I'm not expecting miracles, it
    		would require redistributing the poles and zeroes. But if there's
    		a research paper or code out there...I could incorporate it.
    
    	- Denormal testing and fixing
    
    		I'd like to know if denormals are a problem. And if so, it would be nice
    		to have a small function that can reproduce the denormal problem. This
    		way I can test the fix under all conditions. I will include the function
    		as a "unit test" object in the header file so anyone can verify its
    		correctness. But I'm a little lost.
    
    	- Optimized template specializations for stages=1, channels={1,2}
    
    		There are some pretty obvious optimizations I am saving for "the end".
    		I don't want to do them until the code is finalized.
    
    	- Optimized template specializations for SSE, other special instructions
    
    	- Optimized trigonometric functions for fast parameter changes
    
    	- Elliptic curve based filter coefficients
    
    	- More utility functions for manipulating sample buffers
    
    	- Need fast version of pow( 10, x )
    */
    
    #ifndef __DSP_FILTER__
    #define __DSP_FILTER__
    
    #include <cmath>
    #include <cfloat>
    #include <assert.h>
    #include <memory.h>
    #include <stdlib.h>
    
    //#define DSP_USE_STD_COMPLEX
    
    #ifdef DSP_USE_STD_COMPLEX
    #include <complex>
    #endif
    
    #define DSP_SSE3_OPTIMIZED
    
    #ifdef DSP_SSE3_OPTIMIZED
    	//#include <xmmintrin.h>
    	//#include <emmintrin.h>
    	#include <pmmintrin.h>
    #endif
    
    namespace Dsp
    {
    	//--------------------------------------------------------------------------
    	// WARNING: Here there be templates
    	//--------------------------------------------------------------------------
    
    	//--------------------------------------------------------------------------
    	//
    	//	Configuration
    	//
    	//--------------------------------------------------------------------------
    
    	// Regardless of the type of sample that the filter operates on (e.g.
    	// float or double), all calculations are performed using double (or
    	// better) for stability and accuracy. This controls the underlying
    	// type used for calculations:
    	typedef double CalcT;
    
    	typedef int		Int32;	// Must be 32 bits
    	typedef __int64 Int64;	// Must be 64 bits
    
    	// This is used to prevent denormalization. 
    	const CalcT vsa=1.0 / 4294967295.0; // for CalcT as float
    
    	// These constants are so important, I made my own copy. If you improve
    	// the resolution of CalcT be sure to add more significant digits to these.
    	const CalcT kPi		=3.1415926535897932384626433832795;
    	const CalcT kPi_2	=1.57079632679489661923;
    	const CalcT kLn2    =0.693147180559945309417;
    	const CalcT kLn10	=2.30258509299404568402;
    
    	//--------------------------------------------------------------------------
    
    	// Some functions missing from <math.h>
    	template<typename T>
    	inline T acosh( T x )
    	{
    		return log( x+::sqrt(x*x-1) );
    	}
    
    	//--------------------------------------------------------------------------
    	//
    	//	Fast Trigonometric Functions
    	//
    	//--------------------------------------------------------------------------
    
    	// Three approximations for both sine and cosine at a given angle.
    	// The faster the routine, the larger the error.
    	// From http://lab.polygonal.de/2007/07/18/fast-and-accurate-sinecosine-approximation/
    
    	// Tuned for maximum pole stability. r must be in the range 0..pi
    	// This one breaks down considerably at the higher angles. It is
    	// included only for educational purposes.
    	inline void fastestsincos( CalcT r, CalcT *sn, CalcT *cs )
    	{
    		const CalcT c=0.70710678118654752440; // sqrt(2)/2
    		CalcT v=(2-4*c)*r*r+c;
    		if(r<kPi_2)
    		{
    			*sn=v+r; *cs=v-r;
    		}
    		else
    		{
    			*sn=r+v; *cs=r-v;
    		}
    	}
    
    	// Lower precision than ::fastsincos() but still decent
    	inline void fastersincos( CalcT x, CalcT *sn, CalcT *cs )
    	{
    		//always wrap input angle to -PI..PI
    		if		(x < -kPi) x += 2*kPi;
    		else if (x >  kPi) x -= 2*kPi;
    		//compute sine
    		if (x < 0)	*sn = 1.27323954 * x + 0.405284735 * x * x;
    		else		*sn = 1.27323954 * x - 0.405284735 * x * x;
    		//compute cosine: sin(x + PI/2) = cos(x)
    		x += kPi_2;
    		if (x > kPi ) x -= 2*kPi;
    		if (x < 0)	*cs = 1.27323954 * x + 0.405284735 * x * x;
    		else		*cs = 1.27323954 * x - 0.405284735 * x * x;
    	}
    
    	// Slower than ::fastersincos() but still faster than
    	// sin(), and with the best accuracy of these routines.
    	inline void fastsincos( CalcT x, CalcT *sn, CalcT *cs )
    	{
    		CalcT s, c;
    		//always wrap input angle to -PI..PI
    			 if (x < -kPi) x += 2*kPi;
    		else if (x >  kPi) x -= 2*kPi;
    		//compute sine
    		if (x < 0)
    		{
    			s = 1.27323954 * x + .405284735 * x * x;
    			if (s < 0)	s = .225 * (s * -s - s) + s;
    			else		s = .225 * (s *  s - s) + s;
    		}
    		else
    		{
    			s = 1.27323954 * x - 0.405284735 * x * x;
    			if (s < 0)	s = .225 * (s * -s - s) + s;
    			else		s = .225 * (s *  s - s) + s;
    		}
    		*sn=s;
    		//compute cosine: sin(x + PI/2) = cos(x)
    		x += kPi_2;
    		if (x > kPi ) x -= 2*kPi;
    		if (x < 0)
    		{
    			c = 1.27323954 * x + 0.405284735 * x * x;
    			if (c < 0)	c = .225 * (c * -c - c) + c;
    			else		c = .225 * (c *  c - c) + c;
    		}
    		else
    		{
    			c = 1.27323954 * x - 0.405284735 * x * x;
    			if (c < 0)	c = .225 * (c * -c - c) + c;
    			else		c = .225 * (c *  c - c) + c;
    		}
    		*cs=c;
    	}
    
    	// Faster approximations to sqrt()
    	//	From http://ilab.usc.edu/wiki/index.php/Fast_Square_Root
    	//	The faster the routine, the more error in the approximation.
    
    	// Log Base 2 Approximation
    	// 5 times faster than sqrt()
    
    	inline float fastsqrt1( float x )  
    	{
    		union { Int32 i; float x; } u;
    		u.x = x;
    		u.i = (Int32(1)<<29) + (u.i >> 1) - (Int32(1)<<22); 
    		return u.x;
    	}
    
    	inline double fastsqrt1( double x )  
    	{
    		union { Int64 i; double x; } u;
    		u.x = x;
    		u.i = (Int64(1)<<61) + (u.i >> 1) - (Int64(1)<<51); 
    		return u.x;
    	}
    
    	// Log Base 2 Approximation with one extra Babylonian Step
    	// 2 times faster than sqrt()
    
    	inline float fastsqrt2( float x )  
    	{
    		float v=fastsqrt1( x );
    		v = 0.5f * (v + x/v); // One Babylonian step
    		return v;
    	}
    
    	inline double fastsqrt2(const double x)  
    	{
    		double v=fastsqrt1( x );
    		v = 0.5f * (v + x/v); // One Babylonian step
    		return v;
    	}
    
    	// Log Base 2 Approximation with two extra Babylonian Steps
    	// 50% faster than sqrt()
    
    	inline float fastsqrt3( float x )  
    	{
    		float v=fastsqrt1( x );
    		v =		   v + x/v;
    		v = 0.25f* v + x/v; // Two Babylonian steps
    		return v;
    	}
    
    	inline double fastsqrt3(const double x)  
    	{
    		double v=fastsqrt1( x );
    		v =		   v + x/v;
    		v = 0.25 * v + x/v; // Two Babylonian steps
    		return v;
    	}
    
    	//--------------------------------------------------------------------------
    	//
    	//	Complex
    	//
    	//--------------------------------------------------------------------------
    
    #ifdef DSP_USE_STD_COMPLEX
    
    	template<typename T>
    	inline std::complex<T> polar( const T &m, const T &a )
    	{
    		return std::polar( m, a );
    	}
    
    	template<typename T>
    	inline T norm( const std::complex<T> &c )
    	{
    		return std::norm( c );
    	}
    
    	template<typename T>
    	inline T abs( const std::complex<T> &c )
    	{
    		return std::abs(c);
    	}
    
    	template<typename T, typename To>
    	inline std::complex<T> addmul( const std::complex<T> &c, T v, const std::complex<To> &c1 )
    	{
    		return std::complex<T>( c.real()+v*c1.real(), c.imag()+v*c1.imag() );
    	}
    
    	template<typename T>
    	inline T arg( const std::complex<T> &c )
    	{
    		return std::arg( c );
    	}
    
    	template<typename T>
    	inline std::complex<T> recip( const std::complex<T> &c )
    	{
    		T n=1.0/Dsp::norm(c);
    		return std::complex<T>( n*c.real(), n*c.imag() );
    	}
    	template<typename T>
    	inline std::complex<T> sqrt( const std::complex<T> &c )
    	{
    		return std::sqrt( c );
    	}
    
    	typedef std::complex<CalcT> Complex;
    
    #else
    
    	//--------------------------------------------------------------------------
    
    	// "Its always good to have a few extra wheels in case one goes flat."
    
    	template<typename T>
    	struct ComplexT
    	{
    		ComplexT();
    		ComplexT( T r_, T i_=0 );
    
    		template<typename To>
    		ComplexT( const ComplexT<To> &c );
    
    		T			imag		( void ) const;
    		T			real		( void ) const;
    
    		ComplexT &	neg			( void );
    		ComplexT &	conj		( void );
    
    		template<typename To>
    		ComplexT &	add			( const ComplexT<To> &c );
    		template<typename To>
    		ComplexT &	sub			( const ComplexT<To> &c );
    		template<typename To>
    		ComplexT &	mul			( const ComplexT<To> &c );
    		template<typename To>
    		ComplexT &	div			( const ComplexT<To> &c );
    		template<typename To>
    		ComplexT &	addmul		( T v, const ComplexT<To> &c );
    
    		ComplexT	operator-	( void ) const;
    
    		ComplexT	operator+	( T v ) const;
    		ComplexT	operator-	( T v ) const;
    		ComplexT	operator*	( T v ) const;
    		ComplexT	operator/	( T v ) const;
    
    		ComplexT &	operator+=	( T v );
    		ComplexT &	operator-=	( T v );
    		ComplexT &	operator*=	( T v );
    		ComplexT &	operator/=	( T v );
    
    		template<typename To>
    		ComplexT	operator+	( const ComplexT<To> &c ) const;
    		template<typename To>
    		ComplexT	operator-	( const ComplexT<To> &c ) const;
    		template<typename To>
    		ComplexT	operator*	( const ComplexT<To> &c ) const;
    		template<typename To>
    		ComplexT	operator/	( const ComplexT<To> &c ) const;
    
    		template<typename To>
    		ComplexT &	operator+=	( const ComplexT<To> &c );
    		template<typename To>
    		ComplexT &	operator-=	( const ComplexT<To> &c );
    		template<typename To>
    		ComplexT &	operator*=	( const ComplexT<To> &c );
    		template<typename To>
    		ComplexT &	operator/=	( const ComplexT<To> &c );
    
    	private:
    		ComplexT &	add			( T v );
    		ComplexT &	sub			( T v );
    		ComplexT &	mul			( T c, T d );
    		ComplexT &	mul			( T v );
    		ComplexT &	div			( T v );
    
    		T r;
    		T i;
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<typename T>
    	inline ComplexT<T>::ComplexT()
    	{
    	}
    
    	template<typename T>
    	inline ComplexT<T>::ComplexT( T r_, T i_ )
    	{
    		r=r_;
    		i=i_;
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T>::ComplexT( const ComplexT<To> &c )
    	{
    		r=c.r;
    		i=c.i;
    	}
    
    	template<typename T>
    	inline T ComplexT<T>::imag( void ) const
    	{
    		return i;
    	}
    
    	template<typename T>
    	inline T ComplexT<T>::real( void ) const
    	{
    		return r;
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::neg( void )
    	{
    		r=-r;
    		i=-i;
    		return *this;
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::conj( void )
    	{
    		i=-i;
    		return *this;
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::add( T v )
    	{
    		r+=v;
    		return *this;
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::sub( T v )
    	{
    		r-=v;
    		return *this;
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::mul( T c, T d )
    	{
    		T ac=r*c;
    		T bd=i*d;
    		// must do i first
    		i=(r+i)*(c+d)-(ac+bd);
    		r=ac-bd;
    		return *this;
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::mul( T v )
    	{
    		r*=v;
    		i*=v;
    		return *this;
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::div( T v )
    	{
    		r/=v;
    		i/=v;
    		return *this;
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> &ComplexT<T>::add( const ComplexT<To> &c )
    	{
    		r+=c.r;
    		i+=c.i;
    		return *this;
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> &ComplexT<T>::sub( const ComplexT<To> &c )
    	{
    		r-=c.r;
    		i-=c.i;
    		return *this;
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> &ComplexT<T>::mul( const ComplexT<To> &c )
    	{
    		return mul( c.r, c.i );
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> &ComplexT<T>::div( const ComplexT<To> &c )
    	{
    		T s=1.0/norm(c);
    		return mul( c.r*s, -c.i*s );
    	}
    
    	template<typename T>
    	inline ComplexT<T> ComplexT<T>::operator-( void ) const
    	{
    		return ComplexT<T>(*this).neg();
    	}
    
    	template<typename T>
    	inline ComplexT<T> ComplexT<T>::operator+( T v ) const
    	{
    		return ComplexT<T>(*this).add( v );
    	}
    
    	template<typename T>
    	inline ComplexT<T> ComplexT<T>::operator-( T v ) const
    	{
    		return ComplexT<T>(*this).sub( v );
    	}
    
    	template<typename T>
    	inline ComplexT<T> ComplexT<T>::operator*( T v ) const
    	{
    		return ComplexT<T>(*this).mul( v );
    	}
    
    	template<typename T>
    	inline ComplexT<T> ComplexT<T>::operator/( T v ) const
    	{
    		return ComplexT<T>(*this).div( v );
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::operator+=( T v )
    	{
    		return add( v );
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::operator-=( T v )
    	{
    		return sub( v );
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::operator*=( T v )
    	{
    		return mul( v );
    	}
    
    	template<typename T>
    	inline ComplexT<T> &ComplexT<T>::operator/=( T v )
    	{
    		return div( v );
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> ComplexT<T>::operator+( const ComplexT<To> &c ) const
    	{
    		return ComplexT<T>(*this).add(c);
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> ComplexT<T>::operator-( const ComplexT<To> &c ) const
    	{
    		return ComplexT<T>(*this).sub(c);
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> ComplexT<T>::operator*( const ComplexT<To> &c ) const
    	{
    		return ComplexT<T>(*this).mul(c);
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> ComplexT<T>::operator/( const ComplexT<To> &c ) const
    	{
    		return ComplexT<T>(*this).div(c);
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> &ComplexT<T>::operator+=( const ComplexT<To> &c )
    	{
    		return add( c );
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> &ComplexT<T>::operator-=( const ComplexT<To> &c )
    	{
    		return sub( c );
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> &ComplexT<T>::operator*=( const ComplexT<To> &c )
    	{
    		return mul( c );
    	}
    
    	template<typename T>
    	template<typename To>
    	inline ComplexT<T> &ComplexT<T>::operator/=( const ComplexT<To> &c )
    	{
    		return div( c );
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<typename T>
    	inline ComplexT<T> polar( const T &m, const T &a )
    	{
    		return ComplexT<T>( m*cos(a), m*sin(a) );
    	}
    
    	template<typename T>
    	inline T norm( const ComplexT<T> &c )
    	{
    		return c.real()*c.real()+c.imag()*c.imag();
    	}
    
    	template<typename T>
    	inline T abs( const ComplexT<T> &c )
    	{
    		return ::sqrt( c.real()*c.real()+c.imag()*c.imag() );
    	}
    
    	template<typename T, typename To>
    	inline ComplexT<T> addmul( const ComplexT<T> &c, T v, const ComplexT<To> &c1 )
    	{
    		return ComplexT<T>( c.real()+v*c1.real(), c.imag()+v*c1.imag() );
    	}
    
    	template<typename T>
    	inline T arg( const ComplexT<T> &c )
    	{
    		return atan2( c.imag(), c.real() );
    	}
    
    	template<typename T>
    	inline ComplexT<T> recip( const ComplexT<T> &c )
    	{
    		T n=1.0/norm(c);
    		return ComplexT<T>( n*c.real(), -n*c.imag() );
    	}
    
    	template<typename T>
    	inline ComplexT<T> sqrt( const ComplexT<T> &c )
    	{
    		return polar( ::sqrt(abs(c)), arg(c)*0.5 );
    	}
    
    	//--------------------------------------------------------------------------
    
    	typedef ComplexT<CalcT> Complex;
    
    #endif
    
    	//--------------------------------------------------------------------------
    	//
    	//	Numerical Analysis
    	//
    	//--------------------------------------------------------------------------
    
    	// Implementation of Brent's Method provided by
    	// John D. Cook (http://www.johndcook.com/)
    
    	// The return value of Minimize is the minimum of the function f.
    	// The location where f takes its minimum is returned in the variable minLoc.
    	// Notation and implementation based on Chapter 5 of Richard Brent's book
    	// "Algorithms for Minimization Without Derivatives".
    
    	template<class TFunction>
    	CalcT BrentMinimize
    	(
    		TFunction& f,	// [in] objective function to minimize
    		CalcT leftEnd,	// [in] smaller value of bracketing interval
    		CalcT rightEnd,	// [in] larger value of bracketing interval
    		CalcT epsilon,	// [in] stopping tolerance
    		CalcT& minLoc	// [out] location of minimum
    	)
    	{
    		CalcT d, e, m, p, q, r, tol, t2, u, v, w, fu, fv, fw, fx;
    		static const CalcT c = 0.5*(3.0 - ::sqrt(5.0));
    		static const CalcT SQRT_DBL_EPSILON = ::sqrt(DBL_EPSILON);
    
    		CalcT& a = leftEnd; CalcT& b = rightEnd; CalcT& x = minLoc;
    
    		v = w = x = a + c*(b - a); d = e = 0.0;
    		fv = fw = fx = f(x);
    		int counter = 0;
    	loop:
    		counter++;
    		m = 0.5*(a + b);
    		tol = SQRT_DBL_EPSILON*::fabs(x) + epsilon; t2 = 2.0*tol;
    		// Check stopping criteria
    		if (::fabs(x - m) > t2 - 0.5*(b - a))
    		{
    			p = q = r = 0.0;
    			if (::fabs(e) > tol)
    			{
    				// fit parabola
    				r = (x - w)*(fx - fv);
    				q = (x - v)*(fx - fw);
    				p = (x - v)*q - (x - w)*r;
    				q = 2.0*(q - r);
    				(q > 0.0) ? p = -p : q = -q;
    				r = e; e = d;
    			}
    			if (::fabs(p) < ::fabs(0.5*q*r) && p < q*(a - x) && p < q*(b - x))
    			{
    				// A parabolic interpolation step
    				d = p/q;
    				u = x + d;
    				// f must not be evaluated too close to a or b
    				if (u - a < t2 || b - u < t2)
    					d = (x < m) ? tol : -tol;
    			}
    			else
    			{
    				// A golden section step
    				e = (x < m) ? b : a;
    				e -= x;
    				d = c*e;
    			}
    			// f must not be evaluated too close to x
    			if (::fabs(d) >= tol)
    				u = x + d;
    			else if (d > 0.0)
    				u = x + tol;
    			else
    				u = x - tol;
    			fu = f(u);
    			// Update a, b, v, w, and x
    			if (fu <= fx)
    			{
    				(u < x) ? b = x : a = x;
    				v = w; fv = fw; 
    				w = x; fw = fx; 
    				x = u; fx = fu;
    			}
    			else
    			{
    				(u < x) ? a = u : b = u;
    				if (fu <= fw || w == x)
    				{
    					v = w; fv = fw; 
    					w = u; fw = fu;
    				}
    				else if (fu <= fv || v == x || v == w)
    				{
    					v = u; fv = fu;
    				}
    			}
    			goto loop;  // Yes, the dreaded goto statement. But the code
    						// here is faithful to Brent's orginal pseudocode.
    		}
    		return  fx;
    	}
    
    	//--------------------------------------------------------------------------
    	//
    	//	Infinite Impulse Response Filters
    	//
    	//--------------------------------------------------------------------------
    
    	// IIR filter implementation using multiple second-order stages.
    
    	class CascadeFilter
    	{
    	public:
    		// Process data in place using Direct Form I
    		// skip is added after each frame.
    		// Direct Form I is more suitable when the filter parameters
    		// are changed often. However, it is slightly slower.
    		template<typename T>
    		void ProcessI( size_t frames, T *dest, int skip=0 );
    
    		// Process data in place using Direct Form II
    		// skip is added after each frame.
    		// Direct Form II is slightly faster than Direct Form I,
    		// but changing filter parameters on stream can result
    		// in discontinuities in the output. It is best suited
    		// for a filter whose parameters are set only once.
    		template<typename T>
    		void ProcessII( size_t frames, T *dest, int skip=0 );
    
    		// Convenience function that just calls ProcessI.
    		// Feel free to change the implementation.
    		template<typename T>
    		void Process( size_t frames, T *dest, int skip=0 );
    
    		// Determine response at angular frequency (0<=w<=kPi)
    		Complex	Response( CalcT w );
    
    		// Clear the history buffer.
    		void Clear( void );
    
    	protected:
    		struct Hist;
    		struct Stage;
    
    		// for m_nchan==2
    #ifdef DSP_SSE3_OPTIMIZED
    		template<typename T>
    		void ProcessISSEStageStereo( size_t frames, T *dest, Stage *stage, Hist *h, int skip );
    
    		template<typename T>
    		void ProcessISSEStereo( size_t frames, T *dest, int skip );
    #endif
    
    	protected:
    		void Reset		( void );
    		void Normalize	( CalcT scale );
    		void SetAStage	( CalcT x1, CalcT x2 );
    		void SetBStage	( CalcT x0, CalcT x1, CalcT x2 );
    		void SetStage	( CalcT a1, CalcT a2, CalcT b0, CalcT b1, CalcT b2 );
    
    	protected:
    		struct Hist
    		{
    			CalcT v[4];
    		};
    
    		struct Stage
    		{
    			CalcT a[3];	// a[0] unused
    			CalcT b[3];
    			void Reset( void );
    		};
    
    		struct ResponseFunctor
    		{
    			CascadeFilter *m_filter;
    			CalcT operator()( CalcT w );
    			ResponseFunctor( CascadeFilter *filter );
    		};
    
    		int		m_nchan;
    		int		m_nstage;
    		Stage *	m_stagep;
    		Hist *	m_histp;
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<typename T>
    	void CascadeFilter::ProcessI( size_t frames, T *dest, int skip )
    	{
    #ifdef DSP_SSE3_OPTIMIZED
    		if( m_nchan==2 )
    			ProcessISSEStereo( frames, dest, skip );
    		else
    #endif
    		while( frames-- )
    		{
    			Hist *h=m_histp;
    			for( int j=m_nchan;j;j-- )
    			{
    				CalcT in=CalcT(*dest);
    				Stage *s=m_stagep;
    				for( int i=m_nstage;i;i--,h++,s++ )
    				{
    					CalcT out;
    					out=s->b[0]*in		+ s->b[1]*h->v[0] + s->b[2]*h->v[1] +
    						s->a[1]*h->v[2] + s->a[2]*h->v[3];
    					h->v[1]=h->v[0]; h->v[0]=in;
    					h->v[3]=h->v[2]; h->v[2]=out;
    					in=out;
    				}
    				*dest++=T(in);
    			}
    			dest+=skip;
    		}
    	}
    
    	// A good compiler already produces code that is optimized even for
    	// the general case. The only way to make it go faster is to
    	// to implement it in assembler or special instructions. Like this:
    
    #ifdef DSP_SSE3_OPTIMIZED
    	// ALL SSE OPTIMIZATIONS ASSUME CalcT as double
    	template<typename T>
    	inline void CascadeFilter::ProcessISSEStageStereo(
    		size_t frames, T *dest, Stage *s, Hist *h, int skip )
    	{
    		assert( m_nchan==2 );
    
    #if 1
    		CalcT b0=s->b[0];
    
    		__m128d m0=_mm_loadu_pd( &s->a[1] );	// a1 , a2
    		__m128d m1=_mm_loadu_pd( &s->b[1] );	// b1 , b2
    		__m128d m2=_mm_loadu_pd( &h[0].v[0] );	// h->v[0] , h->v[1]
    		__m128d m3=_mm_loadu_pd( &h[0].v[2] );	// h->v[2] , h->v[3]
    		__m128d m4=_mm_loadu_pd( &h[1].v[0] );	// h->v[0] , h->v[1]
    		__m128d m5=_mm_loadu_pd( &h[1].v[2] );	// h->v[2] , h->v[3]
    
    		while( frames-- )
    		{
    			CalcT in, b0in, out;
    
    			__m128d m6;
    			__m128d m7;
    
    			in=CalcT(*dest);
    			b0in=b0*in;
    
    			m6=_mm_mul_pd ( m1, m2 );	// b1*h->v[0] , b2*h->v[1]
    			m7=_mm_mul_pd ( m0, m3 );	// a1*h->v[2] , a2*h->v[3]
    			m6=_mm_add_pd ( m6, m7 );	// b1*h->v[0] + a1*h->v[2], b2*h->v[1] + a2*h->v[3]
    			m7=_mm_load_sd( &b0in );	// b0*in , 0
    			m6=_mm_add_sd ( m6, m7 );	// b1*h->v[0] + a1*h->v[2] + in*b0 , b2*h->v[1] + a2*h->v[3] + 0
    			m6=_mm_hadd_pd( m6, m7 );	// b1*h->v[0] + a1*h->v[2] + in*b0 + b2*h->v[1] + a2*h->v[3], in*b0
    			   _mm_store_sd( &out, m6 );
    			m6=_mm_loadh_pd( m6, &in );	// out , in
    			m2=_mm_shuffle_pd( m6, m2, _MM_SHUFFLE2( 0, 1 ) ); // h->v[0]=in , h->v[1]=h->v[0]
    			m3=_mm_shuffle_pd( m6, m3, _MM_SHUFFLE2( 0, 0 ) ); // h->v[2]=out, h->v[3]=h->v[2]
    
    			*dest++=T(out);
    
    			in=CalcT(*dest);
    			b0in=b0*in;
    
    			m6=_mm_mul_pd ( m1, m4 );	// b1*h->v[0] , b2*h->v[1]
    			m7=_mm_mul_pd ( m0, m5 );	// a1*h->v[2] , a2*h->v[3]
    			m6=_mm_add_pd ( m6, m7 );	// b1*h->v[0] + a1*h->v[2], b2*h->v[1] + a2*h->v[3]
    			m7=_mm_load_sd( &b0in );	// b0*in , 0
    			m6=_mm_add_sd ( m6, m7 );	// b1*h->v[0] + a1*h->v[2] + in*b0 , b2*h->v[1] + a2*h->v[3] + 0
    			m6=_mm_hadd_pd( m6, m7 );	// b1*h->v[0] + a1*h->v[2] + in*b0 + b2*h->v[1] + a2*h->v[3], in*b0
    			   _mm_store_sd( &out, m6 );
    			m6=_mm_loadh_pd( m6, &in );	// out , in
    			m4=_mm_shuffle_pd( m6, m4, _MM_SHUFFLE2( 0, 1 ) ); // h->v[0]=in , h->v[1]=h->v[0]
    			m5=_mm_shuffle_pd( m6, m5, _MM_SHUFFLE2( 0, 0 ) ); // h->v[2]=out, h->v[3]=h->v[2]
    
    			*dest++=T(out);
    
    			dest+=skip;
    		}
    
    		// move history from registers back to state
    		_mm_storeu_pd( &h[0].v[0], m2 );
    		_mm_storeu_pd( &h[0].v[2], m3 );
    		_mm_storeu_pd( &h[1].v[0], m4 );
    		_mm_storeu_pd( &h[1].v[2], m5 );
    
    #else
    		// Template-specialized version from which the assembly was modeled
    		CalcT a1=s->a[1];
    		CalcT a2=s->a[2];
    		CalcT b0=s->b[0];
    		CalcT b1=s->b[1];
    		CalcT b2=s->b[2];
    		while( frames-- )
    		{
    			CalcT in, out;
    
    			in=CalcT(*dest);
    			out=b0*in+b1*h[0].v[0]+b2*h[0].v[1] +a1*h[0].v[2]+a2*h[0].v[3];
    			h[0].v[1]=h[0].v[0]; h[0].v[0]=in;
    			h[0].v[3]=h[0].v[2]; h[0].v[2]=out;
    			in=out;
    			*dest++=T(in);
    
    			in=CalcT(*dest);
    			out=b0*in+b1*h[1].v[0]+b2*h[1].v[1] +a1*h[1].v[2]+a2*h[1].v[3];
    			h[1].v[1]=h[1].v[0]; h[1].v[0]=in;
    			h[1].v[3]=h[1].v[2]; h[1].v[2]=out;
    			in=out;
    			*dest++=T(in);
    
    			dest+=skip;
    		}
    #endif
    	}
    
    	// Note there could be a loss of accuracy here. Unlike the original version
    	// of Process...() we are applying each stage to all of the input data.
    	// Since the underlying type T could be float, the results from this function
    	// may be different than the unoptimized version. However, it is much faster.
    	template<typename T>
    	void CascadeFilter::ProcessISSEStereo( size_t frames, T *dest, int skip )
    	{
    		assert( m_nchan==2 );
    		Stage *s=m_stagep;
    		Hist *h=m_histp;
    		for( int i=m_nstage;i;i--,h+=2,s++ )
    		{
    			ProcessISSEStageStereo( frames, dest, s, h, skip );
    		}
    	}
    
    #endif
    
    	template<typename T>
    	void CascadeFilter::ProcessII( size_t frames, T *dest, int skip )
    	{
    		while( frames-- )
    		{
    			Hist *h=m_histp;
    			for( int j=m_nchan;j;j-- )
    			{
    				CalcT in=CalcT(*dest);
    				Stage *s=m_stagep;
    				for( int i=m_nstage;i;i--,h++,s++ )
    				{
    					CalcT d2=h->v[2]=h->v[1];
    					CalcT d1=h->v[1]=h->v[0];
    					CalcT d0=h->v[0]=
    						in+s->a[1]*d1 + s->a[2]*d2;
    						in=s->b[0]*d0 + s->b[1]*d1 + s->b[2]*d2;
    				}
    				*dest++=T(in);
    			}
    			dest+=skip;
    		}
    	}
    
    	template<typename T>
    	inline void CascadeFilter::Process( size_t frames, T *dest, int skip )
    	{
    		ProcessI( frames, dest, skip );
    	}
    
    	inline Complex CascadeFilter::Response( CalcT w )
    	{
    		Complex ch( 1 );
    		Complex cbot( 1 );
    		Complex czn1=polar( 1., -w );
    		Complex czn2=polar( 1., -2*w );
    
    		Stage *s=m_stagep;
    		for( int i=m_nstage;i;i-- )
    		{
    			Complex ct( s->b[0] );
    			Complex cb( 1 );
    			ct=addmul( ct,  s->b[1], czn1 );
    			cb=addmul( cb, -s->a[1], czn1 );
    			ct=addmul( ct,  s->b[2], czn2 );
    			cb=addmul( cb, -s->a[2], czn2 );
    			ch*=ct;
    			cbot*=cb;
    			s++;
    		}
    
    		return ch/cbot;
    	}
    
    	inline void CascadeFilter::Clear( void )
    	{
    		::memset( m_histp, 0, m_nstage*m_nchan*sizeof(m_histp[0]) );
    	}
    
    	inline void CascadeFilter::Stage::Reset( void )
    	{
    				a[1]=0; a[2]=0;
    		b[0]=1; b[1]=0; b[2]=0;
    	}
    
    	inline void CascadeFilter::Reset( void )
    	{
    		Stage *s=m_stagep;
    		for( int i=m_nstage;i;i--,s++ )
    			s->Reset();
    	}
    
    	// Apply scale factor to stage coefficients.
    	inline void CascadeFilter::Normalize( CalcT scale )
    	{
    		// We are throwing the normalization into the first
    		// stage. In theory it might be nice to spread it around
    		// to preserve numerical accuracy.
    		Stage *s=m_stagep;
    		s->b[0]*=scale; s->b[1]*=scale; s->b[2]*=scale;
    	}
    
    	inline void CascadeFilter::SetAStage( CalcT x1, CalcT x2 )
    	{
    		Stage *s=m_stagep;
    		for( int i=m_nstage;i;i-- )
    		{
    			if( s->a[1]==0 && s->a[2]==0 )
    			{
    				s->a[1]=x1;
    				s->a[2]=x2;
    				s=0;
    				break;
    			}
    			if( s->a[2]==0 && x2==0 )
    			{
    				s->a[2]=-s->a[1]*x1;
    				s->a[1]+=x1;
    				s=0;
    				break;
    			}
    			s++;
    		}
    		assert( s==0 );
    	}
    
    	inline void CascadeFilter::SetBStage( CalcT x0, CalcT x1, CalcT x2 )
    	{
    		Stage *s=m_stagep;
    		for( int i=m_nstage;i;i-- )
    		{
    			if( s->b[1]==0 && s->b[2]==0 )
    			{
    				s->b[0]=x0;
    				s->b[1]=x1;
    				s->b[2]=x2;
    				s=0;
    				break;
    			}
    			if( s->b[2]==0 && x2==0 )
    			{
    				// (b0 + z b1)(x0 + z x1) = (b0 x0 + (b1 x0+b0 x1) z + b1 x1 z^2)
    				s->b[2]=s->b[1]*x1;
    				s->b[1]=s->b[1]*x0+s->b[0]*x1;
    				s->b[0]*=x0;
    				s=0;
    				break;
    			}
    			s++;
    		}
    		assert( s==0 );
    	}
    	
    	// Optimized version for Biquads
    	inline void CascadeFilter::SetStage(
    		CalcT a1, CalcT a2, CalcT b0, CalcT b1, CalcT b2 )
    	{
    		assert( m_nstage==1 );
    		Stage *s=&m_stagep[0];
    					s->a[1]=a1; s->a[2]=a2;
    		s->b[0]=b0; s->b[1]=b1; s->b[2]=b2;
    	}
    
    	inline CalcT CascadeFilter::ResponseFunctor::operator()( CalcT w )
    	{
    		return -Dsp::abs(m_filter->Response( w ));
    	}
    
    	inline CascadeFilter::ResponseFunctor::ResponseFunctor( CascadeFilter *filter )
    	{
    		m_filter=filter;
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<int stages, int channels>
    	class CascadeStages : public CascadeFilter
    	{
    	public:
    		CascadeStages();
    
    	private:
    		Hist	m_hist	[stages*channels];
    		Stage	m_stage	[stages];
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int stages, int channels>
    	CascadeStages<stages, channels>::CascadeStages( void )
    	{
    		m_nchan=channels;
    		m_nstage=stages;
    		m_stagep=m_stage;
    		m_histp=m_hist;
    		Clear();
    	}
    
    	//--------------------------------------------------------------------------
    	//
    	//	Biquad Second Order IIR Filters
    	//
    	//--------------------------------------------------------------------------
    
    	// Formulas from http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt
    	template<int channels>
    	class Biquad : public CascadeStages<1, channels>
    	{
    	protected:
    		void Setup( const CalcT a[3], const CalcT b[3] );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	inline void Biquad<channels>::Setup( const CalcT a[3], const CalcT b[3] )
    	{
    		Reset();
    		// transform Biquad coefficients
    		CalcT ra0=1/a[0];
    		SetAStage( -a[1]*ra0, -a[2]*ra0 );
    		SetBStage(  b[0]*ra0,  b[1]*ra0, b[2]*ra0 );
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	class BiquadLowPass : public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT q );
    		void SetupFast		( CalcT normFreq, CalcT q );
    	protected:
    		void SetupCommon	( CalcT sn, CalcT cs, CalcT q );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	inline void BiquadLowPass<channels>::SetupCommon( CalcT sn, CalcT cs, CalcT q  )
    	{
    		CalcT alph = sn / ( 2 * q );
    		CalcT a0 =  1 / ( 1 + alph );
    		CalcT b1 =  1 - cs;
    		CalcT b0 = a0 * b1 * 0.5;
    		CalcT a1 =  2 * cs;
    		CalcT a2 = alph - 1;
    		SetStage( a1*a0, a2*a0, b0, b1*a0, b0 );
    	}
    
    	template<int channels>
    	void BiquadLowPass<channels>::Setup( CalcT normFreq, CalcT q  )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    		SetupCommon( sn, cs, q );
    	}
    
    	template<int channels>
    	void BiquadLowPass<channels>::SetupFast( CalcT normFreq, CalcT q  )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    		SetupCommon( sn, cs, q );
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	class BiquadHighPass : public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT q );
    		void SetupFast		( CalcT normFreq, CalcT q );
    	protected:
    		void SetupCommon	( CalcT sn, CalcT cs, CalcT q );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	inline void BiquadHighPass<channels>::SetupCommon( CalcT sn, CalcT cs, CalcT q  )
    	{
    		CalcT alph = sn / ( 2 * q );
    		CalcT a0 = -1 / ( 1 + alph );
    		CalcT b1 = -( 1 + cs );
    		CalcT b0 = a0 * b1 * -0.5;
    		CalcT a1 = -2 * cs;
    		CalcT a2 =  1 - alph;
    		SetStage( a1*a0, a2*a0, b0, b1*a0, b0 );
    	}
    
    	template<int channels>
    	void BiquadHighPass<channels>::Setup( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    		SetupCommon( sn, cs, q );
    	}
    
    	template<int channels>
    	void BiquadHighPass<channels>::SetupFast( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    		SetupCommon( sn, cs, q );
    	}
    
    	//--------------------------------------------------------------------------
    
    	// Constant skirt gain, peak gain=Q
    	template<int channels>
    	class BiquadBandPass1 : public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT q );
    		void SetupFast		( CalcT normFreq, CalcT q );
    	protected:
    		void SetupCommon	( CalcT sn, CalcT cs, CalcT q );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	inline void BiquadBandPass1<channels>::SetupCommon( CalcT sn, CalcT cs, CalcT q  )
    	{
    		CalcT alph = sn / ( 2 * q );
    		CalcT a0 = -1 / ( 1 + alph );
    		CalcT b0 = a0 * ( sn * -0.5 );
    		CalcT a1 = -2 * cs;
    		CalcT a2 =  1 - alph;
    		SetStage( a1*a0, a2*a0, b0, 0, -b0 );
    	}
    
    	template<int channels>
    	void BiquadBandPass1<channels>::Setup( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    		SetupCommon( sn, cs, q );
    	}
    
    	template<int channels>
    	void BiquadBandPass1<channels>::SetupFast( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    		SetupCommon( sn, cs, q );
    	}
    
    	//--------------------------------------------------------------------------
    
    	// Constant 0dB peak gain
    	template<int channels>
    	class BiquadBandPass2 : public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT q );
    		void SetupFast		( CalcT normFreq, CalcT q );
    	protected:
    		void SetupCommon	( CalcT sn, CalcT cs, CalcT q );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	inline void BiquadBandPass2<channels>::SetupCommon( CalcT sn, CalcT cs, CalcT q  )
    	{
    		CalcT alph = sn / ( 2 * q );
    		CalcT b0 = -alph;
    		CalcT b2 =  alph;
    		CalcT a0 = -1 / ( 1 + alph );
    		CalcT a1 = -2 * cs;
    		CalcT a2 =  1 - alph;
    		SetStage( a1*a0, a2*a0, b0*a0, 0, b2*a0 );
    	}
    
    	template<int channels>
    	void BiquadBandPass2<channels>::Setup( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    		SetupCommon( sn, cs, q );
    	}
    
    	template<int channels>
    	void BiquadBandPass2<channels>::SetupFast( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    		SetupCommon( sn, cs, q );
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	class BiquadBandStop : public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT q );
    		void SetupFast		( CalcT normFreq, CalcT q );
    	protected:
    		void SetupCommon	( CalcT sn, CalcT cs, CalcT q );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	inline void BiquadBandStop<channels>::SetupCommon( CalcT sn, CalcT cs, CalcT q  )
    	{
    		CalcT alph = sn / ( 2 * q );
    		CalcT a0 = 1 / ( 1 + alph );
    		CalcT b1 = a0 * ( -2 * cs );
    		CalcT a2 = alph - 1;
    		SetStage( -b1, a2*a0, a0, b1, a0 );
    	}
    
    	template<int channels>
    	void BiquadBandStop<channels>::Setup( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    		SetupCommon( sn, cs, q );
    	}
    
    	template<int channels>
    	void BiquadBandStop<channels>::SetupFast( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    		SetupCommon( sn, cs, q );
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	class BiquadAllPass: public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT q );
    		void SetupFast		( CalcT normFreq, CalcT q );
    	protected:
    		void SetupCommon	( CalcT sn, CalcT cs, CalcT q );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	void BiquadAllPass<channels>::SetupCommon( CalcT sn, CalcT cs, CalcT q  )
    	{
    		CalcT alph = sn / ( 2 * q );
    		CalcT b2 =  1 + alph;
    		CalcT a0 =  1 / b2;
    		CalcT b0 =( 1 - alph ) * a0;
    		CalcT b1 = -2 * cs * a0;
    		SetStage( -b1, -b0, b0, b1, b2*a0 );
    	}
    
    	template<int channels>
    	void BiquadAllPass<channels>::Setup( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    		SetupCommon( sn, cs, q );
    	}
    
    	template<int channels>
    	void BiquadAllPass<channels>::SetupFast( CalcT normFreq, CalcT q )
    	{
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    		SetupCommon( sn, cs, q );
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	class BiquadPeakEq: public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT dB, CalcT bandWidth );
    		void SetupFast		( CalcT normFreq, CalcT dB, CalcT bandWidth );
    	protected:
    		void SetupCommon	( CalcT sn, CalcT cs, CalcT alph, CalcT A );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	inline void BiquadPeakEq<channels>::SetupCommon(
    		CalcT sn, CalcT cs, CalcT alph, CalcT A )
    	{
    		CalcT t=alph*A;
    		CalcT b0 =  1 - t;
    		CalcT b2 =  1 + t;
    		t=alph/A;
    		CalcT a0 =  1 / ( 1 + t );
    		CalcT a2 =  t - 1;
    		CalcT b1 = a0 * ( -2 * cs );
    		CalcT a1 = -b1;
    
    		SetStage( a1, a2*a0, b0*a0, b1, b2*a0 );
    	}
    
    	template<int channels>
    	void BiquadPeakEq<channels>::Setup( CalcT normFreq, CalcT dB, CalcT bandWidth )
    	{
    		CalcT A  = pow( 10, dB/40 );
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    		CalcT alph = sn * sinh( kLn2/2 * bandWidth * w0/sn );
    		SetupCommon( sn, cs, alph, A );
    	}
    
    	template<int channels>
    	void BiquadPeakEq<channels>::SetupFast( CalcT normFreq, CalcT dB, CalcT bandWidth )
    	{
    		CalcT A  = pow( 10, dB/40 );
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    		CalcT alph = sn * sinh( kLn2/2 * bandWidth * w0/sn );
    		SetupCommon( sn, cs, alph, A );
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	class BiquadLowShelf : public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT dB, CalcT shelfSlope=1.0 );
    		void SetupFast		( CalcT normFreq, CalcT dB, CalcT shelfSlope=1.0 );
    	protected:
    		void SetupCommon	( CalcT cs, CalcT A, CalcT sa );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	inline void BiquadLowShelf<channels>::SetupCommon(
    		CalcT cs, CalcT A, CalcT sa )
    	{
    		CalcT An	= A-1;
    		CalcT Ap	= A+1;
    		CalcT Ancs	= An*cs;
    		CalcT Apcs	= Ap*cs;
    		CalcT b0 =	   A * (Ap - Ancs + sa );
    		CalcT b2 =	   A * (Ap - Ancs - sa );
    		CalcT b1 = 2 * A * (An - Apcs);
    		CalcT a2 =    sa - (Ap + Ancs);
    		CalcT a0 =	   1 / (Ap + Ancs + sa );
    		CalcT a1 = 2 *	   (An + Apcs);
    		SetStage( a1*a0, a2*a0, b0*a0, b1*a0, b2*a0 );
    	}
    
    	template<int channels>
    	void BiquadLowShelf<channels>::Setup( CalcT normFreq, CalcT dB, CalcT shelfSlope )
    	{
    		CalcT A  = pow( 10, dB/40 );
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    		CalcT al = sn / 2 * ::sqrt( (A + 1/A) * (1/shelfSlope - 1) + 2 );
    		CalcT sa =		2 * ::sqrt( A ) * al;
    		SetupCommon( cs, A, sa );
    	}
    
    	// This could be optimized further
    	template<int channels>
    	void BiquadLowShelf<channels>::SetupFast( CalcT normFreq, CalcT dB, CalcT shelfSlope )
    	{
    		CalcT A  = pow( 10, dB/40 );
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    		CalcT al = sn / 2 * fastsqrt1( (A + 1/A) * (1/shelfSlope - 1) + 2 );
    		CalcT sa =		2 * fastsqrt1( A ) * al;
    		SetupCommon( cs, A, sa );
    	}
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	class BiquadHighShelf : public Biquad<channels>
    	{
    	public:
    		void Setup			( CalcT normFreq, CalcT dB, CalcT shelfSlope=1.0 );
    		void SetupFast		( CalcT normFreq, CalcT dB, CalcT shelfSlope=1.0 );
    	protected:
    		void SetupCommon	( CalcT cs, CalcT A, CalcT sa );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int channels>
    	void BiquadHighShelf<channels>::SetupCommon(
    		CalcT cs, CalcT A, CalcT sa )
    	{
    		CalcT An	= A-1;
    		CalcT Ap	= A+1;
    		CalcT Ancs	= An*cs;
    		CalcT Apcs	= Ap*cs;
    		CalcT b0 =		A * (Ap + Ancs + sa );
    		CalcT b1 = -2 * A * (An + Apcs);
    		CalcT b2 =		A * (Ap + Ancs - sa );
    		CalcT a0 =			(Ap - Ancs + sa );
    		CalcT a2 =			 Ancs + sa - Ap;
    		CalcT a1 = -2	*	(An - Apcs);
    		SetStage( a1/a0, a2/a0, b0/a0, b1/a0, b2/a0 );
    	}
    
    	template<int channels>
    	void BiquadHighShelf<channels>::Setup( CalcT normFreq, CalcT dB, CalcT shelfSlope )
    	{
    		CalcT A  = pow( 10, dB/40 );
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT cs = cos(w0);
    		CalcT sn = sin(w0);
    
    		CalcT alph = sn / 2 * ::sqrt( (A + 1/A) * (1/shelfSlope - 1) + 2 );
    		CalcT sa   =	  2 * ::sqrt( A ) * alph;
    		SetupCommon( cs, A, sa );
    	}
    
    	template<int channels>
    	void BiquadHighShelf<channels>::SetupFast( CalcT normFreq, CalcT dB, CalcT shelfSlope )
    	{
    		CalcT A  = pow( 10, dB/40 );
    		CalcT w0 = 2 * kPi * normFreq;
    		CalcT sn, cs;
    		fastsincos( w0, &sn, &cs );
    
    		CalcT alph = sn / 2 * fastsqrt1( (A + 1/A) * (1/shelfSlope - 1) + 2 );
    		CalcT sa   =	  2 * fastsqrt1( A ) * alph;
    		SetupCommon( cs, A, sa );
    	}
    
    	//--------------------------------------------------------------------------
    	//
    	//	General N-Pole IIR Filter
    	//
    	//--------------------------------------------------------------------------
    
    	template<int stages, int channels>
    	class PoleFilter : public CascadeStages<stages, channels>
    	{
    	public:
    		PoleFilter();
    
    		virtual int		CountPoles			( void )=0;
    		virtual int		CountZeroes			( void )=0;
    
    		virtual Complex	GetPole				( int i )=0;
    		virtual Complex	GetZero				( int i )=0;
    
    	protected:
    		virtual Complex GetSPole			( int i, CalcT wc )=0;
    
    	protected:
    		// Determines the method of obtaining
    		// unity gain coefficients in the passband.
    		enum Hint
    		{
    			// No normalizating
    			hintNone,
    			// Use Brent's method to find the maximum
    			hintBrent,
    			// Use the response at a given frequency
    			hintPassband
    		};
    
    		Complex	BilinearTransform	( const Complex &c );
    		Complex	BandStopTransform	( int i, const Complex &c );
    		Complex	BandPassTransform	( int i, const Complex &c );
    		Complex	GetBandStopPole		( int i );
    		Complex	GetBandStopZero		( int i );
    		Complex	GetBandPassPole		( int i );
    		Complex	GetBandPassZero		( int i );
    		void	Normalize			( void );
    		void	Prepare				( void );
    
    		virtual void	BrentHint	( CalcT *w0, CalcT *w1 );
    		virtual CalcT	PassbandHint( void );
    
    	protected:
    		Hint	m_hint;
    		int		m_n;
    		CalcT	m_wc;
    		CalcT	m_wc2;
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int stages, int channels>
    	inline PoleFilter<stages, channels>::PoleFilter( void )
    	{
    		m_hint=hintNone;
    	}
    
    	template<int stages, int channels>
    	inline Complex PoleFilter<stages, channels>::BilinearTransform( const Complex &c )
    	{
    		return (c+1.)/(-c+1.);
    	}
    
    	template<int stages, int channels>
    	inline Complex PoleFilter<stages, channels>::BandStopTransform( int i, const Complex &c )
    	{
    		CalcT a=cos((m_wc+m_wc2)*.5) /
    				cos((m_wc-m_wc2)*.5);
    		CalcT b=tan((m_wc-m_wc2)*.5);
    	    Complex c2(0);
    	    c2=addmul( c2, 4*(b*b+a*a-1), c );
    	    c2+=8*(b*b-a*a+1);
    	    c2*=c;
    	    c2+=4*(a*a+b*b-1);
    		c2=Dsp::sqrt( c2 );
    	    c2*=((i&1)==0)?.5:-.5;
    	    c2+=a;
    	    c2=addmul( c2, -a, c );
    	    Complex c3( b+1 );
    	    c3=addmul( c3, b-1, c );
    		return c2/c3;
    	}
    
    	template<int stages, int channels>
    	inline Complex PoleFilter<stages, channels>::BandPassTransform( int i, const Complex &c )
    	{
    		CalcT a=  cos((m_wc+m_wc2)*0.5)/
    				  cos((m_wc-m_wc2)*0.5);
    		CalcT b=1/tan((m_wc-m_wc2)*0.5);
    		Complex c2(0);
    	    c2=addmul( c2, 4*(b*b*(a*a-1)+1), c );
    	    c2+=8*(b*b*(a*a-1)-1);
    	    c2*=c;
    	    c2+=4*(b*b*(a*a-1)+1);
    		c2=Dsp::sqrt( c2 );
    	    if ((i & 1) == 0)
    			c2=-c2;
    	    c2=addmul( c2, 2*a*b, c );
    	    c2+=2*a*b;
    	    Complex c3(0);
    	    c3=addmul( c3, 2*(b-1), c );
    	    c3+=2*(1+b);
    	    return c2/c3;
    	}
    
    	template<int stages, int channels>
    	Complex PoleFilter<stages, channels>::GetBandStopPole( int i )
    	{
    		Complex c=GetSPole( i/2, kPi_2 );
    		c=BilinearTransform( c );
    		c=BandStopTransform( i, c );
    		return c;
    	}
    
    	template<int stages, int channels>
    	Complex PoleFilter<stages, channels>::GetBandStopZero( int i )
    	{
    		return BandStopTransform( i, Complex( -1 ) );
    	}
    
    	template<int stages, int channels>
    	Complex PoleFilter<stages, channels>::GetBandPassPole( int i )
    	{
    		Complex c=GetSPole( i/2, kPi_2 );
    		c=BilinearTransform( c );
    		c=BandPassTransform( i, c );
    		return c;
    	}
    
    	template<int stages, int channels>
    	Complex PoleFilter<stages, channels>::GetBandPassZero( int i )
    	{
    		return Complex( (i>=m_n)?1:-1 );
    	}
    
    	template<int stages, int channels>
    	void PoleFilter<stages, channels>::Normalize( void )
    	{
    		switch( m_hint )
    		{
    		default:
    		case hintNone:
    			break;
    
    		case hintPassband:
    			{
    				CalcT w=PassbandHint();
    				ResponseFunctor f(this);
    				CalcT mag=-f(w);
    				CascadeStages::Normalize( 1/mag );
    			}
    			break;
    
    		case hintBrent:
    			{
    				ResponseFunctor f(this);
    				CalcT w0, w1, wmin, mag;
    				BrentHint( &w0, &w1 );
    				mag=-BrentMinimize( f, w0, w1, 1e-4, wmin );
    				CascadeStages::Normalize( 1/mag );
    			}
    			break;
    		}
    	}
    
    	template<int stages, int channels>
    	void PoleFilter<stages, channels>::Prepare( void )
    	{
    		if( m_wc2<1e-8 )
    			m_wc2=1e-8;
    		if( m_wc >kPi-1e-8 )
    			m_wc =kPi-1e-8;
    
    		Reset();
    
    		Complex c;
    		int poles=CountPoles();
    		for( int i=0;i<poles;i++ )
    		{
    			c=GetPole( i );
    			if( ::abs(c.imag())<1e-6 )
    				c=Complex( c.real(), 0 );
    			if( c.imag()==0 )
    				SetAStage( c.real(), 0 );
    			else if( c.imag()>0 )
    				SetAStage( 2*c.real(), -Dsp::norm(c) );
    		}
    
    		int zeroes=CountZeroes();
    		for( int i=0;i<zeroes;i++ )
    		{
    			c=GetZero( i );
    			if( ::abs(c.imag())<1e-6 )
    				c=Complex( c.real(), 0 );
    			if( c.imag()==0 )
    				SetBStage( -c.real(), 1, 0 );
    			else if( c.imag()>0 )
    				SetBStage( Dsp::norm(c), -2*c.real(), 1 );
    		}
    
    		Normalize();
    	}
    
    	template<int stages, int channels>
    	void PoleFilter<stages, channels>::BrentHint( CalcT *w0, CalcT *w1 )
    	{
    		// best that this never executes
    		*w0=1e-4;
    		*w1=kPi-1e-4;
    	}
    
    	template<int stages, int channels>
    	CalcT PoleFilter<stages, channels>::PassbandHint( void )
    	{
    		// should never get here
    		assert( 0 );
    		return kPi_2;
    	}
    
    	//--------------------------------------------------------------------------
    	//
    	//	Butterworth Response IIR Filter
    	//
    	//--------------------------------------------------------------------------
    
    	// Butterworth filter response characteristic.
    	// Maximally flat magnitude response in the passband at the
    	// expense of a more shallow rolloff in comparison to other types.
    	template<int poles, int channels>
    	class Butterworth : public PoleFilter<int((poles+1)/2), channels>
    	{
    	public:
    		Butterworth();
    
    		// cutoffFreq = freq / sampleRate
    		void			Setup			( CalcT cutoffFreq );
    
    		virtual int		CountPoles		( void );
    		virtual int		CountZeroes		( void );
    		virtual Complex	GetPole			( int i );
    
    	protected:
    				Complex GetSPole		( int i, CalcT wc );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int poles, int channels>
    	Butterworth<poles, channels>::Butterworth( void )
    	{
    		m_hint=hintPassband;
    	}
    
    	template<int poles, int channels>
    	void Butterworth<poles, channels>::Setup( CalcT cutoffFreq )
    	{
    		m_n=poles;
    		m_wc=2*kPi*cutoffFreq;
    		Prepare();
    	}
    
    	template<int poles, int channels>
    	int Butterworth<poles, channels>::CountPoles( void )
    	{
    		return poles;
    	}
    
    	template<int poles, int channels>
    	int Butterworth<poles, channels>::CountZeroes( void )
    	{
    		return poles;
    	}
    
    	template<int poles, int channels>
    	Complex Butterworth<poles, channels>::GetPole( int i )
    	{
    		return BilinearTransform( GetSPole( i, m_wc ) );
    	}
    
    	template<int poles, int channels>
    	Complex Butterworth<poles, channels>::GetSPole( int i, CalcT wc )
    	{
    		return polar( tan(wc*0.5), kPi_2+(2*i+1)*kPi/(2*m_n) );
    	}
    
    	//--------------------------------------------------------------------------
    
    	// Low Pass Butterworth filter
    	// Stable up to 53 poles (frequency min=0.13% of Nyquist)
    	template<int poles, int channels>
    	class ButterLowPass : public Butterworth<poles, channels>
    	{
    	public:
    		Complex GetZero			( int i );
    
    	protected:
    		CalcT	PassbandHint	( void );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int poles, int channels>
    	Complex ButterLowPass<poles, channels>::GetZero( int i )
    	{
    		return Complex( -1 );
    	}
    
    	template<int poles, int channels>
    	CalcT ButterLowPass<poles, channels>::PassbandHint( void )
    	{
    		return 0;
    	}
    
    	//--------------------------------------------------------------------------
    
    	// High Pass Butterworth filter
    	// Maximally flat magnitude response in the passband.
    	// Stable up to 110 poles (frequency max=97% of Nyquist)
    	template<int poles, int channels>
    	class ButterHighPass : public Butterworth<poles, channels>
    	{
    	public:
    		Complex GetZero( int i );
    
    	protected:
    		CalcT	PassbandHint	( void );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int poles, int channels>
    	Complex ButterHighPass<poles, channels>::GetZero( int i )
    	{
    		return Complex( 1 );
    	}
    
    	template<int poles, int channels>
    	CalcT ButterHighPass<poles, channels>::PassbandHint( void )
    	{
    		return kPi;
    	}
    
    	//--------------------------------------------------------------------------
    
    	// Band Pass Butterworth filter
    	// Stable up to 80 pairs
    	template<int pairs, int channels>
    	class ButterBandPass : public Butterworth<pairs*2, channels>
    	{
    	public:
    		// centerFreq = freq / sampleRate
    		// normWidth  = freqWidth / sampleRate
    		void			Setup			( CalcT centerFreq, CalcT normWidth );
    
    		virtual int		CountPoles		( void );
    		virtual int		CountZeroes		( void );
    		virtual Complex GetPole			( int i );
    		virtual Complex GetZero			( int i );
    
    	protected:
    		CalcT	PassbandHint	( void );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int pairs, int channels>
    	void ButterBandPass<pairs, channels>::Setup( CalcT centerFreq, CalcT normWidth )
    	{
    		m_n=pairs;
    		CalcT angularWidth=2*kPi*normWidth;
    		m_wc2=2*kPi*centerFreq-(angularWidth/2);
    		m_wc =m_wc2+angularWidth;
    		Prepare();
    	}
    
    	template<int pairs, int channels>
    	int ButterBandPass<pairs, channels>::CountPoles( void )
    	{
    		return pairs*2;
    	}
    
    	template<int pairs, int channels>
    	int ButterBandPass<pairs, channels>::CountZeroes( void )
    	{
    		return pairs*2;
    	}
    
    	template<int pairs, int channels>
    	Complex ButterBandPass<pairs, channels>::GetPole( int i )
    	{
    		return GetBandPassPole( i );
    	}
    
    	template<int pairs, int channels>
    	Complex ButterBandPass<pairs, channels>::GetZero( int i )
    	{
    		return GetBandPassZero( i );
    	}
    
    	template<int poles, int channels>
    	CalcT ButterBandPass<poles, channels>::PassbandHint( void )
    	{
    		return (m_wc+m_wc2)/2;
    	}
    
    	//--------------------------------------------------------------------------
    
    	// Band Stop Butterworth filter
    	// Stable up to 109 pairs
    	template<int pairs, int channels>
    	class ButterBandStop : public Butterworth<pairs*2, channels>
    	{
    	public:
    		// centerFreq = freq / sampleRate
    		// normWidth  = freqWidth / sampleRate
    		void	Setup			( CalcT centerFreq, CalcT normWidth );
    
    		virtual int		CountPoles		( void );
    		virtual int		CountZeroes		( void );
    		virtual Complex GetPole			( int i );
    		virtual Complex GetZero			( int i );
    
    	protected:
    		CalcT	PassbandHint	( void );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int pairs, int channels>
    	void ButterBandStop<pairs, channels>::Setup( CalcT centerFreq, CalcT normWidth )
    	{
    		m_n=pairs;
    		CalcT angularWidth=2*kPi*normWidth;
    		m_wc2=2*kPi*centerFreq-(angularWidth/2);
    		m_wc =m_wc2+angularWidth;
    		Prepare();
    	}
    
    	template<int pairs, int channels>
    	int ButterBandStop<pairs, channels>::CountPoles( void )
    	{
    		return pairs*2;
    	}
    
    	template<int pairs, int channels>
    	int ButterBandStop<pairs, channels>::CountZeroes( void )
    	{
    		return pairs*2;
    	}
    
    	template<int pairs, int channels>
    	Complex ButterBandStop<pairs, channels>::GetPole( int i )
    	{
    		return GetBandStopPole( i );
    	}
    
    	template<int pairs, int channels>
    	Complex ButterBandStop<pairs, channels>::GetZero( int i )
    	{
    		return GetBandStopZero( i );
    	}
    
    	template<int poles, int channels>
    	CalcT ButterBandStop<poles, channels>::PassbandHint( void )
    	{
    		if( (m_wc+m_wc2)/2<kPi_2 )
    			return kPi;
    		else
    			return 0;
    	}
    
    	//--------------------------------------------------------------------------
    	//
    	//	Chebyshev Response IIR Filter
    	//
    	//--------------------------------------------------------------------------
    
    	// Type I Chebyshev filter characteristic.
    	// Minimum error between actual and ideal response at the expense of
    	// a user-definable amount of ripple in the passband.
    	template<int poles, int channels>
    	class Chebyshev1 : public PoleFilter<int((poles+1)/2), channels>
    	{
    	public:
    						Chebyshev1();
    
    		// cutoffFreq = freq / sampleRate
    		virtual	void	Setup			( CalcT cutoffFreq, CalcT rippleDb );
    
    		virtual int		CountPoles		( void );
    		virtual int		CountZeroes		( void );
    		virtual Complex	GetPole			( int i );
    		virtual Complex	GetZero			( int i );
    
    	protected:
    		void			SetupCommon		( CalcT rippleDb );
    		virtual	Complex GetSPole		( int i, CalcT wc );
    
    	protected:
    		CalcT	m_sgn;
    		CalcT	m_eps;
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int poles, int channels>
    	Chebyshev1<poles, channels>::Chebyshev1()
    	{
    		m_hint=hintBrent;
    	}
    
    	template<int poles, int channels>
    	void Chebyshev1<poles, channels>::Setup( CalcT cutoffFreq, CalcT rippleDb )
    	{
    		m_n=poles;
    		m_wc=2*kPi*cutoffFreq;
    		SetupCommon( rippleDb );
    	}
    
    	template<int poles, int channels>
    	void Chebyshev1<poles, channels>::SetupCommon( CalcT rippleDb )
    	{
    		m_eps=::sqrt( 1/::exp( -rippleDb*0.1*kLn10 )-1 );
    		Prepare();
    		// This moves the bottom of the ripples to 0dB gain
    		//CascadeStages::Normalize( pow( 10, rippleDb/20.0 ) );
    	}
    
    	template<int poles, int channels>
    	int	Chebyshev1<poles, channels>::CountPoles( void )
    	{
    		return poles;
    	}
    
    	template<int poles, int channels>
    	int Chebyshev1<poles, channels>::CountZeroes( void )
    	{
    		return poles;
    	}
    
    	template<int poles, int channels>
    	Complex Chebyshev1<poles, channels>::GetPole( int i )
    	{
    		return BilinearTransform( GetSPole( i, m_wc ) )*m_sgn;
    	}
    
    	template<int poles, int channels>
    	Complex Chebyshev1<poles, channels>::GetZero( int i )
    	{
    		return Complex( -m_sgn );
    	}
    
    	template<int poles, int channels>
    	Complex Chebyshev1<poles, channels>::GetSPole( int i, CalcT wc )
    	{
    		int n		= m_n;
    		CalcT ni	= 1.0/n;
    		CalcT alpha	= 1/m_eps+::sqrt(1+1/(m_eps*m_eps));
    		CalcT pn	= pow( alpha,  ni );
    		CalcT nn	= pow( alpha, -ni );
    		CalcT a		= 0.5*( pn - nn );
    		CalcT b		= 0.5*( pn + nn );
    		CalcT theta = kPi_2 + (2*i+1) * kPi/(2*n);
    		Complex c	= polar( tan( 0.5*(m_sgn==-1?(kPi-wc):wc) ), theta );
    		return Complex( a*c.real(), b*c.imag() );
    	}
    
    	//--------------------------------------------------------------------------
    
    	// Low Pass Chebyshev Type I filter
    	template<int poles, int channels>
    	class Cheby1LowPass : public Chebyshev1<poles, channels>
    	{
    	public:
    				Cheby1LowPass();
    
    		void	Setup			( CalcT cutoffFreq, CalcT rippleDb );
    
    	protected:
    		CalcT	PassbandHint	( void );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int poles, int channels>
    	Cheby1LowPass<poles, channels>::Cheby1LowPass()
    	{
    		m_sgn=1;
    		m_hint=hintPassband;
    	}
    
    	template<int poles, int channels>
    	void Cheby1LowPass<poles, channels>::Setup( CalcT cutoffFreq, CalcT rippleDb )
    	{
    		Chebyshev1::Setup( cutoffFreq, rippleDb );
    		// move peak of ripple down to 0dB
    		if( !(poles&1) )
    			CascadeStages::Normalize( pow( 10, -rippleDb/20.0 ) );
    	}
    
    	template<int poles, int channels>
    	CalcT Cheby1LowPass<poles, channels>::PassbandHint( void )
    	{
    		return 0;
    	}
    
    	//--------------------------------------------------------------------------
    
    	// High Pass Chebyshev Type I filter
    	template<int poles, int channels>
    	class Cheby1HighPass : public Chebyshev1<poles, channels>
    	{
    	public:
    		Cheby1HighPass();
    
    		void	Setup			( CalcT cutoffFreq, CalcT rippleDb );
    
    	protected:
    		CalcT	PassbandHint	( void );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int poles, int channels>
    	Cheby1HighPass<poles, channels>::Cheby1HighPass()
    	{
    		m_sgn=-1;
    		m_hint=hintPassband;
    	}
    
    	template<int poles, int channels>
    	void Cheby1HighPass<poles, channels>::Setup( CalcT cutoffFreq, CalcT rippleDb )
    	{
    		Chebyshev1::Setup( cutoffFreq, rippleDb );
    		// move peak of ripple down to 0dB
    		if( !(poles&1) )
    			CascadeStages::Normalize( pow( 10, -rippleDb/20.0 ) );
    	}
    
    	template<int poles, int channels>
    	CalcT Cheby1HighPass<poles, channels>::PassbandHint( void )
    	{
    		return kPi;
    	}
    
    	//--------------------------------------------------------------------------
    
    	// Band Pass Chebyshev Type I filter
    	template<int pairs, int channels>
    	class Cheby1BandPass : public Chebyshev1<pairs*2, channels>
    	{
    	public:
    		Cheby1BandPass();
    
    		void	Setup			( CalcT centerFreq, CalcT normWidth, CalcT rippleDb );
    
    		int		CountPoles		( void );
    		int		CountZeroes		( void );
    		Complex	GetPole			( int i );
    		Complex	GetZero			( int i );
    
    	protected:
    		void	BrentHint		( CalcT *w0, CalcT *w1 );
    		//CalcT	PassbandHint	( void );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int pairs, int channels>
    	Cheby1BandPass<pairs, channels>::Cheby1BandPass()
    	{
    		m_sgn=1;
    		m_hint=hintBrent;
    	}
    
    	template<int pairs, int channels>
    	void Cheby1BandPass<pairs, channels>::Setup( CalcT centerFreq, CalcT normWidth, CalcT rippleDb )
    	{
    		m_n=pairs;
    		CalcT angularWidth=2*kPi*normWidth;
    		m_wc2=2*kPi*centerFreq-(angularWidth/2);
    		m_wc =m_wc2+angularWidth;
    		SetupCommon( rippleDb );
    	}
    
    	template<int pairs, int channels>
    	int Cheby1BandPass<pairs, channels>::CountPoles( void )
    	{
    		return pairs*2;
    	}
    
    	template<int pairs, int channels>
    	int Cheby1BandPass<pairs, channels>::CountZeroes( void )
    	{
    		return pairs*2;
    	}
    
    	template<int pairs, int channels>
    	Complex	Cheby1BandPass<pairs, channels>::GetPole( int i )
    	{
    		return GetBandPassPole( i );
    	}
    
    	template<int pairs, int channels>
    	Complex	Cheby1BandPass<pairs, channels>::GetZero( int i )
    	{
    		return GetBandPassZero( i );
    	}
    
    	template<int poles, int channels>
    	void Cheby1BandPass<poles, channels>::BrentHint( CalcT *w0, CalcT *w1 )
    	{
    		CalcT d=1e-4*(m_wc-m_wc2)/2;
    		*w0=m_wc2+d;
    		*w1=m_wc-d;
    	}
    
    	/*
    	// Unfortunately, this doesn't work at the frequency extremes
    	// Maybe we can inverse pre-warp the center point to make sure
    	// it stays put after bilinear and bandpass transformation.
    	template<int poles, int channels>
    	CalcT Cheby1BandPass<poles, channels>::PassbandHint( void )
    	{
    		return (m_wc+m_wc2)/2;
    	}
    	*/
    
    	//--------------------------------------------------------------------------
    
    	// Band Stop Chebyshev Type I filter
    	template<int pairs, int channels>
    	class Cheby1BandStop : public Chebyshev1<pairs*2, channels>
    	{
    	public:
    		Cheby1BandStop();
    
    		void	Setup			( CalcT centerFreq, CalcT normWidth, CalcT rippleDb );
    
    		int		CountPoles		( void );
    		int		CountZeroes		( void );
    		Complex	GetPole			( int i );
    		Complex	GetZero			( int i );
    
    	protected:
    		void	BrentHint		( CalcT *w0, CalcT *w1 );
    		CalcT	PassbandHint	( void );
    	};
    
    	//--------------------------------------------------------------------------
    
    	template<int pairs, int channels>
    	Cheby1BandStop<pairs, channels>::Cheby1BandStop()
    	{
    		m_sgn=1;
    		m_hint=hintPassband;
    	}
    
    	template<int pairs, int channels>
    

Comments
--------

- **Date**: 2010-06-18 10:53:04
- **By**: ten.nozirev@nuSL

.. code-block:: text

    These codes are just what I am looking for.  Too bad they are incomplete as posted here.  Could someone direct me to a complete version?

- **Date**: 2011-02-03 16:37:34
- **By**: moc.tenalpderyrgna@nrobkcah

.. code-block:: text

    I *think* this is the project homepage:
    http://code.google.com/p/dspfilterscpp/
    although I haven't downloaded anything to verify it is and that the code is complete.              

- **Date**: 2012-05-06 01:26:08
- **By**: moc.liamg@oclaf.einniv

.. code-block:: text

    The project is here:
    https://github.com/vinniefalco/DSPFilters.git              

