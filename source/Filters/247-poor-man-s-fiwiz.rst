Poor Man's FIWIZ
================

- **Author or source:** moc.oohay@ljbliam
- **Type:** Filter Design Utility
- **Created:** 2007-03-22 15:02:29


.. code-block:: text
    :caption: notes

    FIWIZ is a neat little filter design utility that uses a genetic programming technique
    called Differential Evolution. As useful as it is, it looks like it took about a week to
    write, and is thus very undeserving of the $70 license fee. So I decided to write my own.
    There's a freely available optimizer class that uses Differential Evolution and I patched
    it together with some filter-specific logic.
    
    Use of the utility requires the ability to do simple coding in C, but you need only revise
    a single function, which basically describes your filter specification. There's a big
    comment in the main source file that clarifies things a bit more.
    
    Although it's not as easy to use as FIWIZ, it's arguably more powerful because your
    specifications are limited only by what you can express in C, whereas FIWIZ is completely
    GUI based.
    
    Another thing: I'm afraid that due to the use of _kbhit and _getch, the code is a bit
    Microsofty, but you can take those out and the code will still be basically usable.


.. code-block:: c++
    :linenos:
    :caption: code

    // First File: DESolver.cpp
    
    #include <stdio.h>
    #include <memory.h>
    #include <conio.h>
    #include "DESolver.h"
    
    #define Element(a,b,c)  a[b*nDim+c]
    #define RowVector(a,b)  (&a[b*nDim])
    #define CopyVector(a,b) memcpy((a),(b),nDim*sizeof(double))
    
    DESolver::DESolver(int dim,int popSize) :
    					nDim(dim), nPop(popSize),
    					generations(0), strategy(stRand1Exp),
    					scale(0.7), probability(0.5), bestEnergy(0.0),
    					trialSolution(0), bestSolution(0),
    					popEnergy(0), population(0)
    {
    	trialSolution = new double[nDim];
    	bestSolution  = new double[nDim];
    	popEnergy	  = new double[nPop];
    	population	  = new double[nPop * nDim];
    
    	return;
    }
    
    DESolver::~DESolver(void)
    {
    	if (trialSolution) delete trialSolution;
    	if (bestSolution) delete bestSolution;
    	if (popEnergy) delete popEnergy;
    	if (population) delete population;
    
    	trialSolution = bestSolution = popEnergy = population = 0;
    	return;
    }
    
    void DESolver::Setup(double *min,double *max,
    						int deStrategy,double diffScale,double crossoverProb)
    {
    	int i;
    
    	strategy	= deStrategy;
    	scale		= diffScale;
    	probability = crossoverProb;
    	
    	for (i=0; i < nPop; i++)
    	{
    		for (int j=0; j < nDim; j++)
    			Element(population,i,j) = RandomUniform(min[j],max[j]);
    
    		popEnergy[i] = 1.0E20;
    	}
    
    	for (i=0; i < nDim; i++)
    		bestSolution[i] = 0.0;
    
    	switch (strategy)
    	{
    		case stBest1Exp:
          calcTrialSolution = &DESolver::Best1Exp;
    			break;
    
    		case stRand1Exp:
    			calcTrialSolution = &DESolver::Rand1Exp;
    			break;
    
    		case stRandToBest1Exp:
    			calcTrialSolution = &DESolver::RandToBest1Exp;
    			break;
    
    		case stBest2Exp:
    			calcTrialSolution = &DESolver::Best2Exp;
    			break;
    
    		case stRand2Exp:
    			calcTrialSolution = &DESolver::Rand2Exp;
    			break;
    
    		case stBest1Bin:
    			calcTrialSolution = &DESolver::Best1Bin;
    			break;
    
    		case stRand1Bin:
    			calcTrialSolution = &DESolver::Rand1Bin;
    			break;
    
    		case stRandToBest1Bin:
    			calcTrialSolution = &DESolver::RandToBest1Bin;
    			break;
    
    		case stBest2Bin:
    			calcTrialSolution = &DESolver::Best2Bin;
    			break;
    
    		case stRand2Bin:
    			calcTrialSolution = &DESolver::Rand2Bin;
    			break;
    	}
    
    	return;
    }
    
    bool DESolver::Solve(int maxGenerations)
    {
    	int generation;
    	int candidate;
    	bool bAtSolution;
      int generationsPerLoop = 10;
    
    	bestEnergy = 1.0E20;
    	bAtSolution = false;
    
    	for (generation=0;
           (generation < maxGenerations) && !bAtSolution && (0 == _kbhit());
           generation++)
      {
    		for (candidate=0; candidate < nPop; candidate++)
    		{
    			(this->*calcTrialSolution)(candidate);
    			trialEnergy = EnergyFunction(trialSolution,bAtSolution);
    
    			if (trialEnergy < popEnergy[candidate])
    			{
    				// New low for this candidate
    				popEnergy[candidate] = trialEnergy;
    				CopyVector(RowVector(population,candidate),trialSolution);
    
    				// Check if all-time low
    				if (trialEnergy < bestEnergy)
    				{
    					bestEnergy = trialEnergy;
    					CopyVector(bestSolution,trialSolution);
    				}
    			}
    		}
    
        if ((generation % generationsPerLoop) == (generationsPerLoop - 1))
        {
          printf("Gens %u Cost %.15g\n", generation+1, Energy());
        }
      }
    
      if (0 != _kbhit())
      {
        _getch();
      }
    
    	generations = generation;
    	return(bAtSolution);
    }
    
    void DESolver::Best1Exp(int candidate)
    {
    	int r1, r2;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; (RandomUniform(0.0,1.0) < probability) && (i < nDim); i++) 
    	{
    		trialSolution[n] = bestSolution[n]
    							+ scale * (Element(population,r1,n)
    							- Element(population,r2,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::Rand1Exp(int candidate)
    {
    	int r1, r2, r3;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2,&r3);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; (RandomUniform(0.0,1.0) < probability) && (i < nDim); i++) 
    	{
    		trialSolution[n] = Element(population,r1,n)
    							+ scale * (Element(population,r2,n)
    							- Element(population,r3,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::RandToBest1Exp(int candidate)
    {
    	int r1, r2;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; (RandomUniform(0.0,1.0) < probability) && (i < nDim); i++) 
    	{
    		trialSolution[n] += scale * (bestSolution[n] - trialSolution[n])
    							 + scale * (Element(population,r1,n)
    							 - Element(population,r2,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::Best2Exp(int candidate)
    {
    	int r1, r2, r3, r4;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2,&r3,&r4);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; (RandomUniform(0.0,1.0) < probability) && (i < nDim); i++) 
    	{
    		trialSolution[n] = bestSolution[n] +
    							scale * (Element(population,r1,n)
    										+ Element(population,r2,n)
    										- Element(population,r3,n)
    										- Element(population,r4,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::Rand2Exp(int candidate)
    {
    	int r1, r2, r3, r4, r5;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2,&r3,&r4,&r5);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; (RandomUniform(0.0,1.0) < probability) && (i < nDim); i++) 
    	{
    		trialSolution[n] = Element(population,r1,n)
    							+ scale * (Element(population,r2,n)
    										+ Element(population,r3,n)
    										- Element(population,r4,n)
    										- Element(population,r5,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::Best1Bin(int candidate)
    {
    	int r1, r2;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; i < nDim; i++) 
    	{
    		if ((RandomUniform(0.0,1.0) < probability) || (i == (nDim - 1)))
    			trialSolution[n] = bestSolution[n]
    								+ scale * (Element(population,r1,n)
    											- Element(population,r2,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::Rand1Bin(int candidate)
    {
    	int r1, r2, r3;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2,&r3);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; i < nDim; i++) 
    	{
    		if ((RandomUniform(0.0,1.0) < probability) || (i  == (nDim - 1)))
    			trialSolution[n] = Element(population,r1,n)
    								+ scale * (Element(population,r2,n)
    												- Element(population,r3,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::RandToBest1Bin(int candidate)
    {
    	int r1, r2;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; i < nDim; i++) 
    	{
    		if ((RandomUniform(0.0,1.0) < probability) || (i  == (nDim - 1)))
    			trialSolution[n] += scale * (bestSolution[n] - trialSolution[n])
    									+ scale * (Element(population,r1,n)
    												- Element(population,r2,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::Best2Bin(int candidate)
    {
    	int r1, r2, r3, r4;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2,&r3,&r4);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; i < nDim; i++) 
    	{
    		if ((RandomUniform(0.0,1.0) < probability) || (i  == (nDim - 1)))
    			trialSolution[n] = bestSolution[n]
    								+ scale * (Element(population,r1,n)
    											+ Element(population,r2,n)
    											- Element(population,r3,n)
    											- Element(population,r4,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::Rand2Bin(int candidate)
    {
    	int r1, r2, r3, r4, r5;
    	int n;
    
    	SelectSamples(candidate,&r1,&r2,&r3,&r4,&r5);
    	n = (int)RandomUniform(0.0,(double)nDim);
    
    	CopyVector(trialSolution,RowVector(population,candidate));
    	for (int i=0; i < nDim; i++) 
    	{
    		if ((RandomUniform(0.0,1.0) < probability) || (i  == (nDim - 1)))
    			trialSolution[n] = Element(population,r1,n)
    								+ scale * (Element(population,r2,n)
    											+ Element(population,r3,n)
    											- Element(population,r4,n)
    											- Element(population,r5,n));
    		n = (n + 1) % nDim;
    	}
    
    	return;
    }
    
    void DESolver::SelectSamples(int candidate,int *r1,int *r2,
    										int *r3,int *r4,int *r5)
    {
    	if (r1)
    	{
    		do
    		{
    			*r1 = (int)RandomUniform(0.0,(double)nPop);
    		}
    		while (*r1 == candidate);
    	}
    
    	if (r2)
    	{
    		do
    		{
    			*r2 = (int)RandomUniform(0.0,(double)nPop);
    		}
    		while ((*r2 == candidate) || (*r2 == *r1));
    	}
    
    	if (r3)
    	{
    		do
    		{
    			*r3 = (int)RandomUniform(0.0,(double)nPop);
    		}
    		while ((*r3 == candidate) || (*r3 == *r2) || (*r3 == *r1));
    	}
    
    	if (r4)
    	{
    		do
    		{
    			*r4 = (int)RandomUniform(0.0,(double)nPop);
    		}
    		while ((*r4 == candidate) || (*r4 == *r3) || (*r4 == *r2) || (*r4 == *r1));
    	}
    
    	if (r5)
    	{
    		do
    		{
    			*r5 = (int)RandomUniform(0.0,(double)nPop);
    		}
    		while ((*r5 == candidate) || (*r5 == *r4) || (*r5 == *r3)
    													|| (*r5 == *r2) || (*r5 == *r1));
    	}
    
    	return;
    }
    
    /*------Constants for RandomUniform()---------------------------------------*/
    #define SEED 3
    #define IM1 2147483563
    #define IM2 2147483399
    #define AM (1.0/IM1)
    #define IMM1 (IM1-1)
    #define IA1 40014
    #define IA2 40692
    #define IQ1 53668
    #define IQ2 52774
    #define IR1 12211
    #define IR2 3791
    #define NTAB 32
    #define NDIV (1+IMM1/NTAB)
    #define EPS 1.2e-7
    #define RNMX (1.0-EPS)
    
    double DESolver::RandomUniform(double minValue,double maxValue)
    {
    	long j;
    	long k;
    	static long idum;
    	static long idum2=123456789;
    	static long iy=0;
    	static long iv[NTAB];
    	double result;
    
    	if (iy == 0)
    		idum = SEED;
    
    	if (idum <= 0)
    	{
    		if (-idum < 1)
    			idum = 1;
    		else
    			idum = -idum;
    
    		idum2 = idum;
    
    		for (j=NTAB+7; j>=0; j--)
    		{
    			k = idum / IQ1;
    			idum = IA1 * (idum - k*IQ1) - k*IR1;
    			if (idum < 0) idum += IM1;
    			if (j < NTAB) iv[j] = idum;
    		}
    
    		iy = iv[0];
    	}
    
    	k = idum / IQ1;
    	idum = IA1 * (idum - k*IQ1) - k*IR1;
    
    	if (idum < 0)
    		idum += IM1;
    
    	k = idum2 / IQ2;
    	idum2 = IA2 * (idum2 - k*IQ2) - k*IR2;
    
    	if (idum2 < 0)
    		idum2 += IM2;
    
    	j = iy / NDIV;
    	iy = iv[j] - idum2;
    	iv[j] = idum;
    
    	if (iy < 1)
    		iy += IMM1;
    
    	result = AM * iy;
    
    	if (result > RNMX)
    		result = RNMX;
    
    	result = minValue + result * (maxValue - minValue);
    	return(result);
    }
    
    // END FIRST FILE
    
    // BEGIN SECOND FILE: DESolver.h
    // Differential Evolution Solver Class
    // Based on algorithms developed by Dr. Rainer Storn & Kenneth Price
    // Written By: Lester E. Godwin
    //             PushCorp, Inc.
    //             Dallas, Texas
    //             972-840-0208 x102
    //             godwin@pushcorp.com
    // Created: 6/8/98
    // Last Modified: 6/8/98
    // Revision: 1.0
    
    #if !defined(_DESOLVER_H)
    #define _DESOLVER_H
    
    #define stBest1Exp			0
    #define stRand1Exp			1
    #define stRandToBest1Exp	2
    #define stBest2Exp			3
    #define stRand2Exp			4
    #define stBest1Bin			5
    #define stRand1Bin			6
    #define stRandToBest1Bin	7
    #define stBest2Bin			8
    #define stRand2Bin			9
    
    class DESolver;
    
    typedef void (DESolver::*StrategyFunction)(int);
    
    class DESolver
    {
    public:
    	DESolver(int dim,int popSize);
    	~DESolver(void);
    	
    	// Setup() must be called before solve to set min, max, strategy etc.
    	void Setup(double min[],double max[],int deStrategy,
    							double diffScale,double crossoverProb);
    
    	// Solve() returns true if EnergyFunction() returns true.
    	// Otherwise it runs maxGenerations generations and returns false.
    	virtual bool Solve(int maxGenerations);
    
    	// EnergyFunction must be overridden for problem to solve
    	// testSolution[] is nDim array for a candidate solution
    	// setting bAtSolution = true indicates solution is found
    	// and Solve() immediately returns true.
    	virtual double EnergyFunction(double testSolution[],bool &bAtSolution) = 0;
    	
    	int Dimension(void) { return(nDim); }
    	int Population(void) { return(nPop); }
    
    	// Call these functions after Solve() to get results.
    	double Energy(void) { return(bestEnergy); }
    	double *Solution(void) { return(bestSolution); }
    
    	int Generations(void) { return(generations); }
    
    protected:
    	void SelectSamples(int candidate,int *r1,int *r2=0,int *r3=0,
    												int *r4=0,int *r5=0);
    	double RandomUniform(double min,double max);
    
    	int nDim;
    	int nPop;
    	int generations;
    
    	int strategy;
    	StrategyFunction calcTrialSolution;
    	double scale;
    	double probability;
    
    	double trialEnergy;
    	double bestEnergy;
    
    	double *trialSolution;
    	double *bestSolution;
    	double *popEnergy;
    	double *population;
    
    private:
    	void Best1Exp(int candidate);
    	void Rand1Exp(int candidate);
    	void RandToBest1Exp(int candidate);
    	void Best2Exp(int candidate);
    	void Rand2Exp(int candidate);
    	void Best1Bin(int candidate);
    	void Rand1Bin(int candidate);
    	void RandToBest1Bin(int candidate);
    	void Best2Bin(int candidate);
    	void Rand2Bin(int candidate);
    };
    
    
    // I added the following stuff 19 March 2007
    // Brent Lehman
    
    struct ASpectrum
    {
      unsigned mNumValues;
      double* mReals;
      double* mImags;
    };
    
    bool ComputeSpectrum(double* evenZeros, unsigned numEvenZeros, double* oddZero,
                         double* evenPoles, unsigned numEvenPoles, double* oddPole,
                         double gain, ASpectrum* spectrum);
    
    class FilterSolver : public DESolver
    {
    public:
      FilterSolver(int dim, int popSize, int spectrumSize,
                   unsigned numZeros, unsigned numPoles, bool minimumPhase) :
        DESolver(dim, popSize)
      { 
        mSpectrum.mNumValues = spectrumSize;
        mSpectrum.mReals = new double[spectrumSize];
        mSpectrum.mImags = new double[spectrumSize];
        mNumZeros = numZeros; 
        mNumPoles = numPoles;
        mMinimumPhase = minimumPhase;
      }
      virtual ~FilterSolver()
      {
        delete[] mSpectrum.mReals;
        delete[] mSpectrum.mImags;
      }
    	virtual double EnergyFunction(double testSolution[], bool& bAtSolution);
      virtual ASpectrum* Spectrum() {return &mSpectrum;}
    private:
      unsigned  mNumZeros;
      unsigned  mNumPoles;
      bool      mMinimumPhase;
      ASpectrum mSpectrum;
    };
    
    
    #endif // _DESOLVER_H
    
    // END SECOND FILE DESolver.h
    
    // BEGIN FINAL FILE: FilterDesign.cpp
    /*
     *
     *  Filter Design Utility
     *  Source
     *
     *  Brent Lehman
     *  16 March 2007
     *
     *
     */
    
    
    ////////////////////////////////////////////////////////////////////
    //                                                                //
    //  The idea is that an optimization algorithm passes a bunch of  //
    //  different filter specifications to the function               //
    //  "EnergyFunction" below.  That function is supposed to         //
    //  compute an "error" or "cost" value for each specification     //
    //  it receives, which the algorithm uses to decide on other      //
    //  filter specifications to try.  Over the course of several     //
    //  thousand different specifications, the algorithm will         //
    //  eventually converge on a single best one.  This one has the   //
    //  lowest error value of all possible specifications.  Thus,     //
    //  you effectively tell the optimization algorithm what it's     //
    //  looking for through code that you put into EnergyFunction.    //
    //                                                                //
    //  Look for a note in the code like this one to see what part    //
    //  you need to change for your own uses.                         //
    //                                                                //
    ////////////////////////////////////////////////////////////////////
    
    
    #include <stdlib.h>
    #include <stdio.h>
    #include <memory.h>
    #include <conio.h>
    #include <math.h>
    #include <time.h>
    #include "DESolver.h"
    
    
    #define kIntIsOdd(x) (((x) & 0x00000001) == 1)
    
    
    double FilterSolver::EnergyFunction(double testSolution[], bool& bAtSolution)
    {
      unsigned i;
      double   tempReal;
      double   tempImag;
    
      // You probably will want to keep this if statement and its contents
      if (mMinimumPhase)
      {
        // Make sure there are no zeros outside the unit circle
        unsigned lastEvenZero = (mNumZeros & 0xfffffffe) - 1;
        for (i = 0; i <= lastEvenZero; i+=2)
        {
          tempReal = testSolution[i];
          tempImag = testSolution[i+1];
          if ((tempReal*tempReal + tempImag*tempImag) > 1.0)
          {
            return 1.0e+300;
          }
        }
    
        if (kIntIsOdd(mNumZeros))
        {
          tempReal = testSolution[mNumZeros - 1];
          if ((tempReal * tempReal) > 1.0)
          {
            return 1.0e+300;
          }
        }
      }
    
      // Make sure there are no poles on or outside the unit circle
      // You probably will want to keep this too
      unsigned lastEvenPole = mNumZeros + (mNumPoles & 0xfffffffe) - 2;
      for (i = mNumZeros; i <= lastEvenPole; i+=2)
      {
        tempReal = testSolution[i];
        tempImag = testSolution[i+1];
        if ((tempReal*tempReal + tempImag*tempImag) > 0.999999999)
        {
          return 1.0e+300;
        }
      }
    
      // If you keep the for loop above, keep this too
      if (kIntIsOdd(mNumPoles))
      {
        tempReal = testSolution[mNumZeros + mNumPoles - 1];
        if ((tempReal * tempReal) > 1.0)
        {
          return 1.0e+300;
        }
      }
    
      double* evenZeros = &(testSolution[0]);
      double* evenPoles = &(testSolution[mNumZeros]);
      double* oddZero   = NULL;
      double* oddPole   = NULL;
      double  gain = testSolution[mNumZeros + mNumPoles];
    
      if (kIntIsOdd(mNumZeros))
      {
        oddZero = &(testSolution[mNumZeros - 1]);
      }
    
      if (kIntIsOdd(mNumPoles))
      {
        oddPole = &(testSolution[mNumZeros + mNumPoles - 1]);
      }
    
      ComputeSpectrum(evenZeros, mNumZeros & 0xfffffffe, oddZero,
                      evenPoles, mNumPoles & 0xfffffffe, oddPole,
                      gain, &mSpectrum);
    
      unsigned numPoints = mSpectrum.mNumValues;
    
    /////////////////////////////////////////////////////////////////
    //                                                             //
    //   Use the impulse response, held in the variable            //
    //   "mSpectrum", to compute a score for the solution that     //
    //   has been passed into this function.  You probably don't   //
    //   want to touch any of the code above this point, but       //
    //   from here to the end of this function, it's all you!      //
    //                                                             //
    /////////////////////////////////////////////////////////////////
    
      #define kLnTwoToThe127 88.02969193111305
      #define kRecipLn10      0.4342944819032518
    
      // Compute square sum of errors for magnitude
      double magnitudeError = 0.0;
      double magnitude = 0.0;
      double logMagnitude = 0.0;
      tempReal = mSpectrum.mReals[0];
      tempImag = mSpectrum.mImags[0];
      magnitude = tempReal*tempReal + tempImag*tempImag;
      double baseMagnitude = 0.0;
      if (0.0 == magnitude)
      {
        baseMagnitude = -kLnTwoToThe127;
      }
      else
      {
        baseMagnitude = log(magnitude) * kRecipLn10;
        baseMagnitude *= 0.5;
      }
    
      for (i = 0; i < numPoints; i++)
      {
        tempReal = mSpectrum.mReals[i];
        tempImag = mSpectrum.mImags[i];
        magnitude = tempReal*tempReal + tempImag*tempImag;
        if (0.0 == magnitude)
        {
          logMagnitude = -kLnTwoToThe127;
        }
        else
        {
          logMagnitude = log(magnitude) * kRecipLn10;
          logMagnitude *= 0.5;  // Half the log because it's mag squared
        }
    
        logMagnitude -= baseMagnitude;
        magnitudeError += logMagnitude * logMagnitude;
      }
    
      // Compute errors for phase
      double phaseError = 0.0;
      double phase = 0.0;
      double componentError = 0.0;
      double degree = 1;//((mNumZeros + 1) & 0xfffffffe) - 1;
      double angleSpacing = -3.141592653589793 * 0.5 / numPoints * degree;
      double targetPhase = 0.0;
      double oldPhase = 0.0;
      double phaseDifference = 0;
      double totalPhaseTraversal = 0.0;
      double traversalError = 0.0;
      for (i = 0; i < (numPoints - 5); i++)
      {
        tempReal = mSpectrum.mReals[i];
        tempImag = mSpectrum.mImags[i];
        oldPhase = phase;
        phase = atan2(tempImag, tempReal);
        phaseDifference = phase - oldPhase;
        if (phaseDifference > 3.141592653589793)
        {
          phaseDifference -= 3.141592653589793;
          phaseDifference -= 3.141592653589793;
        }
        else if (phaseDifference < -3.141592653589793)
        {
          phaseDifference += 3.141592653589793;
          phaseDifference += 3.141592653589793;
        }
        totalPhaseTraversal += phaseDifference;
        componentError = cosh(200.0*(phaseDifference - angleSpacing)) - 0.5;
        phaseError += componentError * componentError;
        targetPhase += angleSpacing;
        if (targetPhase < -3.141592653589793)
        {
          targetPhase += 3.141592653589793;
          targetPhase += 3.141592653589793;
        }
      }
    
      traversalError = totalPhaseTraversal - angleSpacing * numPoints;
      traversalError *= traversalError;
    
      double baseMagnitudeError = baseMagnitude * baseMagnitude;
    
      // Compute weighted sum of the two subtotals
      // Take square root
      return sqrt(baseMagnitudeError*1.0 + magnitudeError*100.0 +
                  phaseError*400.0 + traversalError*4000000.0);
    }
    
    
    ///////////////////////////////
    int main(int argc, char** argv)
    {
      srand((unsigned)time(NULL));
    
      unsigned numZeros;
      unsigned numPoles;
      bool     minimumPhase;
    
      if (argc < 4)
      {
        printf("Usage: FilterDesign.exe <minimumPhase?> <numZeros> <numPoles>\n");
        return 0;
      }
      else
      {
        if (0 == atoi(argv[1]))
        {
          minimumPhase = false;
        }
        else
        {
          minimumPhase = true;
        }
    
        numZeros = (unsigned)atoi(argv[2]);
        if (0 == numZeros)
        {
          numZeros = 1;
        }
    
        numPoles = (unsigned)atoi(argv[3]);
      }
    
      unsigned vectorLength   = numZeros + numPoles + 1;
      unsigned populationSize = vectorLength * 10;
      FilterSolver theSolver(vectorLength, populationSize, 200,
                             numZeros, numPoles, minimumPhase);
    
      double* minimumSolution = new double[vectorLength];
      unsigned i;
      if (minimumPhase)
      {
        for (i = 0; i < numZeros; i++)
        {
          minimumSolution[i] = -sqrt(0.5);
        }
      }
      else
      {
        for (i = 0; i < numZeros; i++)
        {
          minimumSolution[i] = -10.0;
        }
      }
    
      for (; i < (vectorLength - 1); i++)
      {
        minimumSolution[i] = -sqrt(0.5);
      }
    
      minimumSolution[vectorLength - 1] = 0.0;
    
      double* maximumSolution = new double[vectorLength];
      if (minimumPhase)
      {
        for (i = 0; i < numZeros; i++)
        {
          maximumSolution[i] = sqrt(0.5);
        }
      }
      else
      {
        for (i = 0; i < numZeros; i++)
        {
          maximumSolution[i] = 10.0;
        }
      }
    
      for (i = 0; i < (vectorLength - 1); i++)
      {
        maximumSolution[i] = sqrt(0.5);
      }
    
      maximumSolution[vectorLength - 1] = 2.0;
    
      theSolver.Setup(minimumSolution, maximumSolution, 0, 0.5, 0.75);
      theSolver.Solve(1000000);
    
      double* bestSolution = theSolver.Solution();
      printf("\nZeros:\n");
      unsigned numEvenZeros = numZeros & 0xfffffffe;
      for (i = 0; i < numEvenZeros; i+=2)
      {
        printf("%.10f +/- %.10fi\n", bestSolution[i], bestSolution[i+1]);
      }
    
      if (kIntIsOdd(numZeros))
      {
        printf("%.10f\n", bestSolution[numZeros-1]);
      }
    
      printf("Poles:\n");
      unsigned lastEvenPole = numZeros + (numPoles & 0xfffffffe) - 2;
      for (i = numZeros; i <= lastEvenPole; i+=2)
      {
        printf("%.10f +/- %.10fi\n", bestSolution[i], bestSolution[i+1]);
      }
    
      unsigned numRoots = numZeros + numPoles;
      if (kIntIsOdd(numPoles))
      {
        printf("%.10f\n", bestSolution[numRoots-1]);
      }
    
      double gain = bestSolution[numRoots];
      printf("Gain: %.10f\n", gain);
    
      _getch();
      unsigned j;
      ASpectrum* spectrum = theSolver.Spectrum();
      double logMagnitude;
      printf("Magnitude Response, millibels:\n");
      for (i = 0; i < 20; i++)
      {
        for (j = 0; j < 10; j++)
        {
          logMagnitude = kRecipLn10 *
             log(spectrum->mReals[i*10 + j] * spectrum->mReals[i*10 + j] +
                 spectrum->mImags[i*10 + j] * spectrum->mImags[i*10 + j]);
          if (logMagnitude < -9.999)
          {
            logMagnitude = -9.999;
          }
          printf("%+5.0f ", logMagnitude*1000);
        }
        printf("\n");
      }
    
      _getch();
      double phase;
      printf("Phase Response, milliradians:\n");
      for (i = 0; i < 20; i++)
      {
        for (j = 0; j < 10; j++)
        {
          phase = atan2(spectrum->mImags[i*10 + j], spectrum->mReals[i*10 + j]);
          printf("%+5.0f ", phase*1000);
        }
        printf("\n");
      }
    
      _getch();
      printf("Biquad Sections:\n");
      unsigned numBiquadSections =
        (numZeros > numPoles) ? ((numZeros + 1) >> 1) : ((numPoles + 1) >> 1);
      double x0, x1, x2;
      double y0, y1, y2;
      if (numZeros >=2)
      {
        x0 = (bestSolution[0]*bestSolution[0] + bestSolution[1]*bestSolution[1]) *
             gain;
        x1 = 2.0 * bestSolution[0] * gain;
        x2 = gain;
      }
      else if (1 == numZeros)
      {
        x0 = bestSolution[0] * gain;
        x1 = gain;
        x2 = 0.0;
      }
      else
      {
        x0 = gain;
        x1 = 0.0;
        x2 = 0.0;
      }
    
      if (numPoles >= 2)
      {
        y0 = (bestSolution[numZeros]*bestSolution[numZeros] +
              bestSolution[numZeros+1]*bestSolution[numZeros+1]);
        y1 = 2.0 * bestSolution[numZeros];
        y2 = 1.0;
      }
      else if (1 == numPoles)
      {
        y0 = bestSolution[numZeros];
        y1 = 1.0;
        y2 = 0.0;
      }
      else
      {
        y0 = 1.0;
        y1 = 0.0;
        y2 = 0.0;
      }
    
      x0 /= y0;
      x1 /= y0;
      x2 /= y0;
      y1 /= y0;
      y2 /= y0;
    
      printf("y[n] = %.10fx[n]", x0);
      if (numZeros > 0)
      {
        printf(" + %.10fx[n-1]", x1);
      }
      if (numZeros > 1)
      {
        printf(" + %.10fx[n-2]", x2);
      }
      printf("\n");
    
      if (numPoles > 0)
      {
        printf("                   + %.10fy[n-1]", y1);
      }
      if (numPoles > 1)
      {
        printf(" + &.10fy[n-2]", y2);
      }
      if (numPoles > 0)
      {
        printf("\n");
      }
    
      int numRemainingZeros = numZeros - 2;
      int numRemainingPoles = numPoles - 2;
      for (i = 1; i < numBiquadSections; i++)
      {
        if (numRemainingZeros >= 2)
        {
          x0 = (bestSolution[i*2]   * bestSolution[i*2] +
                bestSolution[i*2+1] * bestSolution[i*2+1]);
          x1 = -2.0 * bestSolution[i*2];
          x2 = 1.0;
        }
        else if (numRemainingZeros >= 1)
        {
          x0 = bestSolution[i*2];
          x1 = 1.0;
          x2 = 0.0;
        }
        else
        {
          x0 = 1.0;
          x1 = 0.0;
          x2 = 0.0;
        }
     
        if (numRemainingPoles >= 2)
        {
          y0 = (bestSolution[i*2+numZeros]   * bestSolution[i*2+numZeros] +
                bestSolution[i*2+numZeros+1] * bestSolution[i*2+numZeros+1]);
          y1 = -2.0 * bestSolution[i*2+numZeros];
          y2 = 1.0;
        }
        else if (numRemainingPoles >= 1)
        {
          y0 = bestSolution[i*2+numZeros];
          y1 = 1.0;
          y2 = 0.0;
        }
        else
        {
          y0 = 1.0;
          y1 = 0.0;
          y2 = 0.0;
        }
    
        x0 /= y0;
        x1 /= y0;
        x2 /= y0;
        y1 /= y0;
        y2 /= y0;
     
        printf("y[n] = %.10fx[n]", x0);
        if (numRemainingZeros > 0)
        {
          printf(" + %.10fx[n-1]", x1);
        }
        if (numRemainingZeros > 1)
        {
          printf(" + %.10fx[n-2]", x2);
        }
        printf("\n");
    
        if (numRemainingPoles > 0)
        {
          printf("                   + %.10fy[n-1]", -y1);
        }
        if (numRemainingPoles > 1)
        {
          printf(" + %.10fy[n-2]", -y2);
        }
        if (numRemainingPoles > 0)
        {
          printf("\n");
        }
    
        numRemainingZeros -= 2;
        numRemainingPoles -= 2;
      }
    
      _getch();
      printf("Full Expansion:\n");
      double* xpolynomial = new double[numRoots + 1];
      memset(xpolynomial, 0, sizeof(double) * (numRoots + 1));
      xpolynomial[0] = 1.0;
      if (numZeros >= 2)
      {
        xpolynomial[0] = bestSolution[0] * bestSolution[0] +
                         bestSolution[1] * bestSolution[1];
        xpolynomial[1] = -2.0 * bestSolution[0];
        xpolynomial[2] = 1.0;
      }
      else if (numZeros == 1)
      {
        xpolynomial[0] = bestSolution[0];
        xpolynomial[1] = 1.0;
      }
      else
      {
        xpolynomial[0] = 1.0;
      }
    
      for (i  = 2, numRemainingZeros = numZeros; numRemainingZeros >= 2;
           i += 2, numRemainingZeros-=2)
      {
        x2 = 1.0;
        x1 = -2.0 * bestSolution[i];
        x0 = bestSolution[i]   * bestSolution[i] +
             bestSolution[i+1] * bestSolution[i+1];
        for (j = numRoots; j > 1; j--)
        {
          xpolynomial[j] = xpolynomial[j-2] + xpolynomial[j-1] * x1 +
                           xpolynomial[j] * x0;
        }
        xpolynomial[1]  = xpolynomial[0] * x1 + xpolynomial[1] * x0;
        xpolynomial[0] *= x0;
      }
    
      if (numRemainingZeros > 0)
      {
        x1 = 1.0;
        x0 = bestSolution[numZeros-1];
        for (j = numRoots; j > 0; j--)
        {
          xpolynomial[j] = xpolynomial[j-1] + xpolynomial[j] * x0;
        }
        xpolynomial[0] *= x0;
      }
    
      double* ypolynomial = new double[numRoots + 1];
      memset(ypolynomial, 0, sizeof(double) * (numRoots + 1));
      ypolynomial[0] = 1.0;
      if (numPoles >= 2)
      {
        ypolynomial[0] = bestSolution[numZeros]   * bestSolution[numZeros] +
                         bestSolution[numZeros+1] * bestSolution[numZeros+1];
        ypolynomial[1] = -2.0 * bestSolution[numZeros];
        ypolynomial[2] = 1.0;
      }
      else if (numPoles == 1)
      {
        ypolynomial[0] = bestSolution[numZeros];
        ypolynomial[1] = 1.0;
      }
      else
      {
        xpolynomial[0] = 1.0;
      }
    
      for (i  = 2, numRemainingPoles = numPoles; numRemainingPoles >= 2;
           i += 2, numRemainingPoles-=2)
      {
        y2 = 1.0;
        y1 = -2.0 * bestSolution[numZeros+i];
        y0 = bestSolution[numZeros+i]   * bestSolution[numZeros+i] +
             bestSolution[numZeros+i+1] * bestSolution[numZeros+i+1];
        for (j = numRoots; j > 1; j--)
        {
          ypolynomial[j] = ypolynomial[j-2] + ypolynomial[j-1] * y1 +
                           ypolynomial[j] * y0;
        }
        ypolynomial[1]  = ypolynomial[0] * y1 + ypolynomial[1] * y0;
        ypolynomial[0] *= y0;
      }
    
      if (numRemainingPoles > 0)
      {
        y1 = 1.0;
        y0 = bestSolution[numZeros+numPoles-1];
        for (j = numRoots; j > 0; j--)
        {
          ypolynomial[j] = ypolynomial[j-1] + ypolynomial[j] * y0;
        }
        ypolynomial[0] *= y0;
      }
    
      y0 = ypolynomial[0];
      for (i = 0; i <= numRoots; i++)
      {
        xpolynomial[i] /= y0;
        ypolynomial[i] /= y0;
      }
    
      printf("y[n] = %.10fx[n]", xpolynomial[0]*gain);
      for (i = 1; i <= numZeros; i++)
      {
        printf(" + %.10fx[n-%d]", xpolynomial[i]*gain, i);
        if ((i % 3) == 2)
        {
          printf("\n");
        }
      }
    
      if ((i % 3) != 0)
      {
        printf("\n");
      }
    
      if (numPoles > 0)
      {
        printf("                 ");
      }
    
      for (i = 1; i <= numPoles; i++)
      {
        printf(" + %.10fy[n-%d]", -ypolynomial[i], i);
        if ((i % 3) == 2)
        {
          printf("\n");
        }
      }
    
      if ((i % 3) != 0)
      {
        printf("\n");
      }
    
      delete[] minimumSolution;
      delete[] maximumSolution;
      delete[] xpolynomial;
      delete[] ypolynomial;
    }
    
    
    bool ComputeSpectrum(double* evenZeros, unsigned numEvenZeros, double* oddZero,
                         double* evenPoles, unsigned numEvenPoles, double* oddPole,
                         double gain, ASpectrum* spectrum)
    {
      unsigned i, j;
    
      // For equally spaced points on the unit circle
      unsigned numPoints = spectrum->mNumValues;
      double   spacingAngle = 3.141592653589793 / (numPoints - 1);
      double   pointArgument = 0.0;
      double   pointReal = 0.0;
      double   pointImag = 0.0;
      double   rootReal = 0.0;
      double   rootImag = 0.0;
      double   differenceReal = 0.0;
      double   differenceImag = 0.0;
      double   responseReal = 1.0;
      double   responseImag = 0.0;
      double   recipSquareMagnitude = 0.0;
      double   recipReal = 0.0;
      double   recipImag = 0.0;
      double   tempRealReal = 0.0;
      double   tempRealImag = 0.0;
      double   tempImagReal = 0.0;
      double   tempImagImag = 0.0;
    
      for (i = 0; i < numPoints; i++)
      {
        responseReal = 1.0;
        responseImag = 0.0;
    
        // The imaginary component is negated because we're using 1/z, not z
        pointReal =  cos(pointArgument);
        pointImag = -sin(pointArgument);
    
        // For each even zero
        for (j = 0; j < numEvenZeros; j+=2)
        {
          rootReal = evenZeros[j];
          rootImag = evenZeros[j + 1];
          // Compute distance from that zero to that point
          differenceReal = pointReal - rootReal;
          differenceImag = pointImag - rootImag;
          // Multiply that distance by the accumulating product
          tempRealReal = responseReal * differenceReal;
          tempRealImag = responseReal * differenceImag;
          tempImagReal = responseImag * differenceReal;
          tempImagImag = responseImag * differenceImag;
          responseReal = tempRealReal - tempImagImag;
          responseImag = tempRealImag + tempImagReal;
          // Do the same with the conjugate root
          differenceImag = pointImag + rootImag;
          tempRealReal = responseReal * differenceReal;
          tempRealImag = responseReal * differenceImag;
          tempImagReal = responseImag * differenceReal;
          tempImagImag = responseImag * differenceImag;
          responseReal = tempRealReal - tempImagImag;
          responseImag = tempRealImag + tempImagReal;
          // The following way is little faster, if any
          // response *= (1/z - r) * (1/z - conj(r))
          //          *= r*conj(r) - (r + conj(r))/z + 1/(z*z)
          //          *= real(r)*real(r) + imag(r)*imag(r) - 2*real(r)/z + 1/(z*z)
          //          *= ... - 2*real(r)*conj(z) + conj(z)*conj(z)
          //          *= ... - 2*real(r)*real(z) + 2i*real(r)*imag(z) +
          //             real(z)*real(z) - 2i*real(z)*imag(z) + imag(z)*imag(z)
          //          *= real(r)*real(r) + imag(r)*imag(r) - 2*real(r)*real(z) +
          //             real(z)*real(z) + imag(z)*imag(z) +
          //              2i * imag(z) * (real(r) - real(z))
          //          *= (real(r) - real(z))^2  + imag(r)^2 + imag(z)^2 +
          //              2i * imag(z) * (real(r) - real(z))
          // This ends up being 8 multiplications, 6 additions
        }
    
        if (NULL != oddZero)
        {
          rootReal = *oddZero;
          // Compute distance from that zero to that point
          differenceReal = pointReal - rootReal;
          differenceImag = pointImag;
          // Multiply that distance by the accumulating product
          tempRealReal = responseReal * differenceReal;
          tempRealImag = responseReal * differenceImag;
          tempImagReal = responseImag * differenceReal;
          tempImagImag = responseImag * differenceImag;
          responseReal = tempRealReal - tempImagImag;
          responseImag = tempRealImag + tempImagReal;
        }
    
        // For each pole
        for (j = 0; j < numEvenPoles; j+=2)
        {
          rootReal = evenPoles[j];
          rootImag = evenPoles[j + 1];
          // Compute distance from that pole to that point
          differenceReal = pointReal - rootReal;
          differenceImag = pointImag - rootImag;
          // Multiply the reciprocal of that distance by the accumulating product
          recipSquareMagnitude = 1.0 / (differenceReal * differenceReal +
                                        differenceImag * differenceImag);
          recipReal =  differenceReal * recipSquareMagnitude;
          recipImag = -differenceImag * recipSquareMagnitude;
          tempRealReal = responseReal * recipReal;
          tempRealImag = responseReal * recipImag;
          tempImagReal = responseImag * recipReal;
          tempImagImag = responseImag * recipImag;
          responseReal = tempRealReal - tempImagImag;
          responseImag = tempRealImag + tempImagReal;
          // Do the same with the conjugate root
          differenceImag = pointImag + rootImag;
          recipSquareMagnitude = 1.0 / (differenceReal * differenceReal +
                                        differenceImag * differenceImag);
          recipReal =  differenceReal * recipSquareMagnitude;
          recipImag = -differenceImag * recipSquareMagnitude;
          tempRealReal = responseReal * recipReal;
          tempRealImag = responseReal * recipImag;
          tempImagReal = responseImag * recipReal;
          tempImagImag = responseImag * recipImag;
          responseReal = tempRealReal - tempImagImag;
          responseImag = tempRealImag + tempImagReal;
        }
    
        if (NULL != oddPole)
        {
          rootReal = *oddPole;
          // Compute distance from that point to that zero
          differenceReal = pointReal - rootReal;
          differenceImag = pointImag;
          // Multiply the reciprocal of that distance by the accumulating product
          recipSquareMagnitude = 1.0 / (differenceReal * differenceReal +
                                        differenceImag * differenceImag);
          recipReal =  differenceReal * recipSquareMagnitude;
          recipImag = -differenceImag * recipSquareMagnitude;
          tempRealReal = responseReal * recipReal;
          tempRealImag = responseReal * recipImag;
          tempImagReal = responseImag * recipReal;
          tempImagImag = responseImag * recipImag;
          responseReal = tempRealReal - tempImagImag;
          responseImag = tempRealImag + tempImagReal;
        }
    
        // Multiply by the gain
        responseReal *= gain;
        responseImag *= gain;
    
        spectrum->mReals[i] = responseReal;
        spectrum->mImags[i] = responseImag;
    
        pointArgument += spacingAngle;
      }
    
      return true;
    }
    
    // Half-band lowpass
    /*
      #define kLnTwoToThe127 88.02969193111305
      #define kRecipLn10      0.4342944819032518
    
      // Compute square sum of errors for bottom half band
      unsigned numLoBandPoints = numPoints >> 1;
      double loBandError = 0.0;
      double magnitude = 0.0;
      double logMagnitude = 0.0;
      for (i = 0; i < numLoBandPoints; i++)
      {
        tempReal = mSpectrum.mReals[i];
        tempImag = mSpectrum.mImags[i];
        magnitude = tempReal*tempReal + tempImag*tempImag;
        if (0.0 == magnitude)
        {
          logMagnitude = -kLnTwoToThe127;
        }
        else
        {
          logMagnitude = log(magnitude) * kRecipLn10;
          logMagnitude *= 0.5;  // Half the log because it's mag squared
        }
    
        loBandError += logMagnitude * logMagnitude;
      }
    
      // Compute errors for top half of band
      double hiBandError = 0.0;
      for ( ; i < numPoints; i++)
      {
        tempReal = mSpectrum.mReals[i];
        tempImag = mSpectrum.mImags[i];
        magnitude = tempReal*tempReal + tempImag*tempImag;
        hiBandError += magnitude; // Already a squared value
      }
    
      // Compute weighted sum of the two subtotals
      // Take square root
      return sqrt(loBandError + 5000.0 * hiBandError);
    */
    

