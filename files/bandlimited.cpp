// An example of generating the sawtooth and parabola wavetables
// for storage to disk.
//
// SPEED=sampling rate, e.g. 44100.0f
// TUNING=pitch of concert A, e.g. 440.0f

///////////////////////////
// Wavetable reverse lookup
// Given a playback rate of the wavetable, what is wavetables index?
//
// rate = f.wavesize/fs e.g. 4096f/44100
// max partials = nyquist/f = wavesize/2rate  e.g. 2048/rate
//
// using max partials we could then do a lookup to find the wavetables index
// in a pre-calculated table
//
// however, we could skip max partials, and lookup a table based on a
// function of f (or rate)
//
// the first few midi notes (0 - 9) differ by < 1 so there are duplicates
// values of (int) f.
// therefore, to get an index to our table (that indexes the wavetables)
// we need 2f
//
// to get 2f from rate we multiply by the constant
// 2f = 2.fs/wavesize  e.g. 88200/4096
//
// our lookup table will have a length>25087 to cover the midi range
// we'll make it 32768 in length for easy processing


	int a,b,n;
	float* data;
	float* sinetable=new float[4096];
	float* datap;
	for(b=0;b<4096;b++)
		sinetable[b]=sin(TWOPI*(float)b/4096.0f);
	int partials;
	int partial;
	int partialindex,reverseindex,lastnumpartials;
	float max,m;
	int* reverse;

	// sawtooth

		data=new float[128*4096];
		reverse=new int[32768];

		reverseindex=0;
		partialindex=0;
		lastnumpartials=-1;

		for(n=0;n<128;n++)
		{
			partials=(int)((SPEED*0.5f)/float(TUNING*(float)pow(2,(float) (n-69)/12.0f))); //(int) NYQUIST/f
			if(partials!=lastnumpartials)
			{
				datap=&data[partialindex*4096];
				for(b=0;b<4096;b++)
					datap[b]=0.0f;  //blank wavetable
				for(a=0;a<partials;a++)
				{
					partial=a+1;
					m=cos((float)a*HALFPI/(float)partials);  //gibbs
					m*=m;  //gibbs
					m/=(float)partial;
					for(b=0;b<4096;b++)
						datap[b]+=m*sinetable[(b*partial)%4096];
				}
				lastnumpartials=partials;
				a=int(2.0f*TUNING*(float)pow(2,(float) (n-69)/12.0f)); //2f
				for(b=reverseindex;b<=a;b++)
					reverse[b]=partialindex;
				reverseindex=a+1;
				partialindex++;
			}
		}

		for(b=reverseindex;b<32768;b++)
			reverse[b]=partialindex-1;

		ar << (int) partialindex; //number of waveforms
		ar << (int) 4096; //waveform size (in samples)

		max=0.0;
		for(b=0;b<4096;b++)
		{
			if(fabs(*(data+b))>max)  //normalise to richest waveform (0)
				max=(float)fabs(*(data+b));
		}
		for(b=0;b<4096*partialindex;b++)
		{
			*(data+b)/=max;
		}

		//ar.Write(data,4096*partialindex*sizeof(float));
		//ar.Write(reverse,32768*sizeof(int));

		delete [] data;
		delete [] reverse;
	}
	// end sawtooth

	// parabola

		data=new float[128*4096];
		reverse=new int[32768];

		reverseindex=0;
		partialindex=0;
		lastnumpartials=-1;

		float sign;

		for(n=0;n<128;n++)
		{
			partials=(int)((SPEED*0.5f)/float(TUNING*(float)pow(2,(float) (n-69)/12.0f)));
			if(partials!=lastnumpartials)
			{
				datap=&data[partialindex*4096];
				for(b=0;b<4096;b++)
					datap[b]=PI*PI/3.0f;
				sign=-1.0f;
				for(a=0;a<partials;a++)
				{
					partial=a+1;
					m=cos((float)a*HALFPI/(float)partials); //gibbs
					m*=m;  //gibbs
					m/=(float)(partial*partial);
					m*=4.0f*sign;
					for(b=0;b<4096;b++)
						datap[b]+=m*sinetable[((b*partial)+1024)%4096]; //note, parabola uses cos
					sign=-sign;
				}
				lastnumpartials=partials;
				a=int(2.0f*TUNING*(float)pow(2,(float) (n-69)/12.0f)); //2f
				for(b=reverseindex;b<=a;b++)
					reverse[b]=partialindex;
				reverseindex=a+1;
				partialindex++;
			}
		}

		for(b=reverseindex;b<32768;b++)
			reverse[b]=partialindex-1;

		ar << (int) partialindex; //number of waveforms
		ar << (int) 4096; //waveform size (in samples)

		max=0.0;
		for(b=0;b<4096;b++)
		{
			if(fabs(*(data+b))>max)  //normalise to richest waveform (0)
				max=(float)fabs(*(data+b));
		}
		max*=0.5;
		for(b=0;b<4096*partialindex;b++)
		{
			*(data+b)/=max;
			*(data+b)-=1.0f;
		}

		//ar.Write(data,4096*partialindex*sizeof(float));
		//ar.Write(reverse,32768*sizeof(int));

		delete [] data;
		delete [] reverse;
	}
	// end parabola


/////////////////////////////////////////////////////////////////////////
// An example of playback of a sawtooth wave
// This is not optimised for easy reading
// When optimising you'll need to get this in assembly (especially those
// float to int conversions)
/////////////////////////////////////////////////////////

#define WAVETABLE_SIZE		(1 << 12)
#define WAVETABLE_SIZEF		WAVETABLE_SIZE.0f
#define WAVETABLE_MASK		(WAVETABLE_SIZE - 1)

float index;
float rate;
int wavetableindex;
float ratetofloatfactor;
float* wavetable;

void setupnote(int midinote /*0 - 127*/)
{
	float f=TUNING*(float)pow(2,(float) (midinote-69)/12.0f));
	rate=f*WAVETABLE_SIZEF/SPEED;
	ratetofloatfactor=2.0f*SPEED/WAVETABLE_SIZEF;
	index=0.0f;
	wavetableindex=reverse[(int)(2.0f*f)];
	wavetable=&sawtoothdata[wavetableindex*WAVETABLE_SIZE];
}

void generatesample(float* buffer,int length)
{
	int currentsample,
	int nextsample;
	float m;
	float temprate;
	while(length--)
	{
		currentsample=(int) index;
		nextsample=(currentsample+1) & WAVETABLE_MASK;
		m=index-(float) currentsample; //fractional part
		*buffer++=(1.0f-m)*wavetable[currentsample]+m*wavetable[nextsample]; //linear interpolation
		rate*=slide; //slide coeffecient if required
		temprate=rate*fm; //frequency modulation if required
		index+=temprate;
		if(index>WAVETABLE_SIZEF)
		{
			//new cycle, respecify wavetable for sliding
			wavetableindex=reverse[(int)(ratetofloatfactor*temprate)];
			wavetable=&sawtoothdata[wavetableindex*WAVETABLE_SIZE];
			index-=WAVETABLE_SIZEF;
		}
	}
}