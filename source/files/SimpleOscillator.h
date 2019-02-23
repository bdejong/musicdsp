////////////////////////////////////////////////////
//
// this code was NEVER MEANT TO BE USED.
//
// use as EXPLANATION ONLY for the difference between
// Phase Modulation and Frequency Modulation.
// there are MANY ways to speed this code up.
//
// bram@musicdsp.org | bram@smartelectronix.com
//
// ps:
// we use the 'previous' value of the phase in all the algo's to make sure that
// the first call to the getSampleXX() function returns the wave at phase 'zero'
//
////////////////////////////////////////////////////

#include "math.h";

#define Pi 3.141592f

class SimpleOscillator
{
	SimpleOscillator(const float sampleRate = 44100.f, const long tableSize = 4096)
	{
		this->tableSize = tableSize;
		this->sampleRate = sampleRate;

		phase = 0.f;

		makeTable();
	}

	~SimpleOscillator()
	{
		delete [] table;
	}

	
	// normal oscillator, no modulation
	//
	float generateSample(const float frequency)
	{
		float lookupPhase = phase;

		phase += frequency * (float)tableSize / sampleRate;
		wrap(phase);

		return lookup(lookupPhase);
	}

	
	// frequency modulation
	// the fm input should be in HZ.
	//
	// example:
	// osc1.getSampleFM(440.f, osc2.getSample(0.5f) * 5.f )
	// would give a signal where the frequency of the signal is
	// modulated between 435hz and 445hz at a 0.5hz rate
	//
	float generateSampleFM(const float frequency, const float fm)
	{
		float lookupPhase = phase;

		phase += (frequency + fm) * (float)tableSize / sampleRate;
		wrap(phase);

		return lookup(lookupPhase);
	}


	// phase modulation
	//
	// a phase mod value of 1.f will increase the "phase" of the wave by a full cycle
	// i.e. calling getSamplePM(440.f,1.f) will result in the "same" wave as getSamplePM(440.f,0.f)
	//
	float generateSamplePM(const float frequency, const float pm)
	{
		float lookupPhase = phase + (float)tableSize * pm;
		wrap(lookupPhase)

		phase += frequency * (float)tableSize / sampleRate;
		wrap(phase);
		
		return lookup(lookupPhase);
	}


	// do the lookup in the table
	// you could use different methods here
	// like linear interpollation or higher order...
	// see musicdsp.org
	//
	float lookup(const float phase)
	{
		return table[(long)phase];
	}


	// wrap around
	//
	void wrap(float &in)
	{
		while(in < 0.f)
			in += (float)tableSize;

		while(in >= (float)tableSize)
			in -= (float)tableSize;

		return in;
	}


	// set the sample rate
	//
	void setSampleRate(const float sampleRate)
	{
		this->sampleRate = sampleRate;
	}


	// sets the phase of the oscillator
	// phase should probably be in 0..Pi*2
	//
	void setPhase(const float phase)
	{
		this->phase = phase / (2.f * Pi) * (float)tableSize;
		wrap(phase);
	}

private:

	float sampleRate;
	float phase;

	float *table;
	long tableSize;

	void makeTable()
	{
		table = new float[tableSize];
		for(long i=0;i<tableSize;i++)
		{
			float x = Pi * 2.f * (float)i / (float)tableSize;
			table[i] = (float)sin(x);
		}
	}
}