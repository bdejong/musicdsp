#pragma once

#include <malloc.h>
#include <rounding.h>

// F-weighted
//static const float or3Fc[3] = {1.623f, -0.982f, 0.109f};
static const float or9Fc[9] = {2.412f, -3.370f, 3.937f, -4.174f, 3.353f, -2.205f, 1.281f, -0.569f, 0.0847f};

// modified-E weighted
//static const float or2MEc[2] = {1.537f, -0.8367f};
//static const float or3MEc[3] = {1.652f, -1.049f, 0.1382f};
//static const float or9MEc[9] = {1.662f, -1.263f, 0.4827f, -0.2913f, 0.1268f, -0.1124f, 0.03252f, -0.01265f, -0.03524f};

// improved-E weighted
//static const float or5IEc[5] = {2.033f, -2.165f, 1.959f, -1.590f, 0.6149f};
//static const float or9IEc[9] = {2.847f, -4.685f, 6.214f, -7.184f, 6.639f, -5.032f, 3.263f, -1.632f, 0.4191f};

// Simple 2nd order
//static const float or2Sc[2] = {1.0f, -0.5f};

// Much faster than C's % operator (anyway, x will never be > 2*n in this case so this is very simple and fast)
// Tell the compiler to try to inline as much as possible, since it makes it run so much faster since these functions get called at least once per sample
__inline my_mod(int x, int n)
{
	if(x > n) x-=n;
	return x;
}

__inline int round(float f)
{
	int r;
	__asm {
		fld f
		fistp r
	}
	return r;
}

__inline short ltos(long l)
{
	return (short)((l==(short)l) ? l : (l>>31)^0x7FFF);
}

__inline float frand()
{
	// Linear Congruential Method - got it from the book "Algorithms," by Robert Sedgewick
	static unsigned long a = 0xDEADBEEF;

	a = a * 140359821 + 1;
	return a * (1.0f / 0xFFFFFFFF);
}

class NS9dither16
{
public:
	NS9dither16();
	~NS9dither16();
	short processS(float samp);
	int processI(float samp);
	void reset();

private:	
	int order;
	int HistPos;

	float* c;	// Coeffs
	float* EH;	// Error History
};

__inline NS9dither16::NS9dither16()
{
	order = 9;

	//c=new float[order];  // if you don't have _aligned_malloc
	c = (float*)_aligned_malloc(order*sizeof(float), 16);
	CopyMemory(c, or9Fc, order*sizeof(float));

	//EH = new float[2*order];	// if you don't have _aligned_malloc
	EH = (float*)_aligned_malloc(2*order*sizeof(float), 16);
	ZeroMemory(EH, 2*order*sizeof(float));

	// Start at top of error history - you can make it start anywhere from 0-8 if you really want to
	HistPos=8;
}

__inline NS9dither16::~NS9dither16()
{	
	//if(c) delete [] c;	// if you don't have _aligned_free
	//if(EH) delete [] EH;	// if you don't have _aligned_free
	if(c) _aligned_free(c);	// don't really need "if," since it is OK to free null pointer, but still...
	if(EH) _aligned_free(EH);
}

__inline void NS9dither16::reset()
{
	ZeroMemory(EH, 2*order*sizeof(float));
	// Start at top of error history - you can make it start anywhere from 0-8 if you really want to
	HistPos=8;
}

// Force inline because VC++.NET doesn't inline for some reason (VC++ 6 does)
__forceinline short NS9dither16::processS(float samp)
{
	int output;

	/*for(int x=0; x<order; x++)
	{
		//samp -= c[x] * EH[(HistPos+x) % order];
		samp -= c[x] * EH[HistPos+x];
	}*/
	// Unrolled loop for faster execution
	/*samp -= c[0]*EH[HistPos] + c[1]*EH[HistPos+1] + c[2]*EH[HistPos+2] +
			c[3]*EH[HistPos+3] + c[4]*EH[HistPos+4] + c[5]*EH[HistPos+5] +
			c[6]*EH[HistPos+6] + c[7]*EH[HistPos+7] + c[8]*EH[HistPos+8];*/
	// This arrangement seems to execute 3 clock cycles faster on a P-III
	samp -= c[8]*EH[HistPos+8] + c[7]*EH[HistPos+7] + c[6]*EH[HistPos+6] +
			c[5]*EH[HistPos+5] + c[4]*EH[HistPos+4] + c[3]*EH[HistPos+3] +
			c[2]*EH[HistPos+1] + c[1]*EH[HistPos+1] + c[0]*EH[HistPos];

	output = round(samp + (frand() + frand() - 1));

	//HistPos =(HistPos+8) % order;	// The % operator is really slow
	HistPos = my_mod((HistPos+8), order);
	// Update buffer (both copies)
	EH[HistPos+9] = EH[HistPos] = output - samp;

	return ltos(output);
}

__forceinline int NS9dither16::processI(float samp)
{
	int output;

	/*for(int x=0; x<order; x++)
	{
		//samp -= c[x] * EH[(HistPos+x) % order];
		samp -= c[x] * EH[HistPos+x];
	}*/
	// Unrolled loop for faster execution
	/*samp -= c[0]*EH[HistPos] + c[1]*EH[HistPos+1] + c[2]*EH[HistPos+2] +
			c[3]*EH[HistPos+3] + c[4]*EH[HistPos+4] + c[5]*EH[HistPos+5] +
			c[6]*EH[HistPos+6] + c[7]*EH[HistPos+7] + c[8]*EH[HistPos+8];*/
	// This arrangement seems to execute 3 clock cycles faster on a P-III
	samp -= c[8]*EH[HistPos+8] + c[7]*EH[HistPos+7] + c[6]*EH[HistPos+6] +
			c[5]*EH[HistPos+5] + c[4]*EH[HistPos+4] + c[3]*EH[HistPos+3] +
			c[2]*EH[HistPos+1] + c[1]*EH[HistPos+1] + c[0]*EH[HistPos];

	output = round(samp + (frand() + frand() - 1));

	//HistPos =(HistPos+8) % order;	// The % operator is really slow
	HistPos = my_mod((HistPos+8), order);
	// Update buffer (both copies)
	EH[HistPos+9] = EH[HistPos] = output - samp;

	return output;
}