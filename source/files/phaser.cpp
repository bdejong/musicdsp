/* 
Date: Mon, 24 Aug 1998 07:02:40 -0700
Reply-To: music-dsp
Originator: music-dsp@shoko.calarts.edu
Sender: music-dsp
Precedence: bulk
From: "Ross Bencina" <rbencina@hotmail.com>
To: Multiple recipients of list <music-dsp>
Subject: Re: Phaser revisited [code included]
X-Comment:  Music Hackers Unite! http://shoko.calarts.edu/~glmrboy/musicdsp/music-dsp.html 
Status: RO

Hi again,

Thanks to Chris Towsend and Marc Lindahl for their helpful 
contributions. I now have a working phaser and it sounds great! It seems 
my main error was using a 'sub-sampled' all-pass reverberator instead of 
a single sample all-pass filter [what was I thinking? :)].

I have included a working prototype (C++) below for anyone who is 
interested. My only remaining doubt is whether the conversion from 
frequency to delay time [ _dmin = fMin / (SR/2.f); ] makes any sense 
what-so-ever.

Ross B.
*/
/*
    class: Phaser
    implemented by: Ross Bencina <rossb@kagi.com>
    date: 24/8/98

    Phaser is a six stage phase shifter, intended to reproduce the
    sound of a traditional analogue phaser effect.
    This implementation uses six first order all-pass filters in
    series, with delay time modulated by a sinusoidal.

    This implementation was created to be clear, not efficient.
    Obvious modifications include using a table lookup for the lfo,
    not updating the filter delay times every sample, and not
    tuning all of the filters to the same delay time.

    Thanks to:
    The nice folks on the music-dsp mailing list, including...
    Chris Towsend and Marc Lindahl
    
    ...and Scott Lehman's Phase Shifting page at harmony central:
    http://www.harmony-central.com/Effects/Articles/Phase_Shifting/

*/

#define SR (44100.f)  //sample rate
#define F_PI (3.14159f)

class Phaser{
public:
	Phaser()  //initialise to some usefull defaults...
    	: _fb( .7f )
    	, _lfoPhase( 0.f )
    	, _depth( 1.f )
        , _zm1( 0.f )
    {
    	Range( 440.f, 1600.f );
    	Rate( .5f );
    }

    void Range( float fMin, float fMax ){ // Hz
    	_dmin = fMin / (SR/2.f);
        _dmax = fMax / (SR/2.f);
    }

    void Rate( float rate ){ // cps
    	_lfoInc = 2.f * F_PI * (rate / SR);
    }

    void Feedback( float fb ){ // 0 -> <1.
    	_fb = fb;
    }

    void Depth( float depth ){  // 0 -> 1.
     	_depth = depth;
    }

    float Update( float inSamp ){
    	//calculate and update phaser sweep lfo...
        float d  = _dmin + (_dmax-_dmin) * ((sin( _lfoPhase ) + 
1.f)/2.f);
        _lfoPhase += _lfoInc;
        if( _lfoPhase >= F_PI * 2.f )
        	_lfoPhase -= F_PI * 2.f;

        //update filter coeffs
        for( int i=0; i<6; i++ )
        	_alps[i].Delay( d );

        //calculate output
        float y = 	_alps[0].Update(
        			 _alps[1].Update(
                      _alps[2].Update(
                       _alps[3].Update(
                        _alps[4].Update(
                         _alps[5].Update( inSamp + _zm1 * _fb ))))));
        _zm1 = y;

        return inSamp + y * _depth;
    }
private:
	class AllpassDelay{
    public:
    	AllpassDelay()
        	: _a1( 0.f )
            , _zm1( 0.f )
            {}

        void Delay( float delay ){ //sample delay time
        	_a1 = (1.f - delay) / (1.f + delay);
        }

        float Update( float inSamp ){
        	float y = inSamp * -_a1 + _zm1;
        	_zm1 = y * _a1 + inSamp;

            return y;
        }
    private:
    	float _a1, _zm1;
    };

    AllpassDelay _alps[6];

    float _dmin, _dmax; //range
    float _fb; //feedback
    float _lfoPhase;
    float _lfoInc;
    float _depth;

    float _zm1;
};
