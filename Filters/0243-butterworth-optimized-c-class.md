# Butterworth Optimized C++ Class

[MusicDSP](../README.md) / [Filters](README.md) · [13 comments](#comments)

- **Author or source:** neotec
- **Type:** 24db Resonant Lowpass
- **Created:** 2007-01-20 22:41:06

## Notes

This ist exactly the same as posted by "Zxform" (filters004.txt). The only difference is,
that this version is an optimized one.

Parameters:
Cutoff \[0.f -\> Nyquist.f\]
Resonance \[0.f -\> 1.f\]

There are some minima and maxima defined, to make ist sound nice in all situations. This
class is part of some of my VST Plugins, and works well and executes fast.

## Code

```cpp
// FilterButterworth24db.h

#pragma once

class CFilterButterworth24db
{
public:
	CFilterButterworth24db(void);
	~CFilterButterworth24db(void);
	void SetSampleRate(float fs);
	void Set(float cutoff, float q);
	float Run(float input);

private:
	float t0, t1, t2, t3;
	float coef0, coef1, coef2, coef3;
	float history1, history2, history3, history4;
	float gain;
	float min_cutoff, max_cutoff;
};

// FilterButterworth24db.cpp

#include <math.h>

#define BUDDA_Q_SCALE 6.f

#include "FilterButterworth24db.h"

CFilterButterworth24db::CFilterButterworth24db(void)
{
	this->history1 = 0.f;
	this->history2 = 0.f;
	this->history3 = 0.f;
	this->history4 = 0.f;

	this->SetSampleRate(44100.f);
	this->Set(22050.f, 0.0);
}

CFilterButterworth24db::~CFilterButterworth24db(void)
{
}

void CFilterButterworth24db::SetSampleRate(float fs)
{
	float pi = 4.f * atanf(1.f);

	this->t0 = 4.f * fs * fs;
	this->t1 = 8.f * fs * fs;
	this->t2 = 2.f * fs;
	this->t3 = pi / fs;

	this->min_cutoff = fs * 0.01f;
	this->max_cutoff = fs * 0.45f;
}

void CFilterButterworth24db::Set(float cutoff, float q)
{
	if (cutoff < this->min_cutoff)
		cutoff = this->min_cutoff;
	else if(cutoff > this->max_cutoff)
		cutoff = this->max_cutoff;

	if(q < 0.f)
		q = 0.f;
	else if(q > 1.f)
		q = 1.f;

	float wp = this->t2 * tanf(this->t3 * cutoff);
	float bd, bd_tmp, b1, b2;

	q *= BUDDA_Q_SCALE;
	q += 1.f;

	b1 = (0.765367f / q) / wp;
	b2 = 1.f / (wp * wp);

	bd_tmp = this->t0 * b2 + 1.f;

	bd = 1.f / (bd_tmp + this->t2 * b1);

	this->gain = bd * 0.5f;

	this->coef2 = (2.f - this->t1 * b2);

	this->coef0 = this->coef2 * bd;
	this->coef1 = (bd_tmp - this->t2 * b1) * bd;

	b1 = (1.847759f / q) / wp;

	bd = 1.f / (bd_tmp + this->t2 * b1);

	this->gain *= bd;
	this->coef2 *= bd;
	this->coef3 = (bd_tmp - this->t2 * b1) * bd;
}

float CFilterButterworth24db::Run(float input)
{
	float output = input * this->gain;
	float new_hist;

	output -= this->history1 * this->coef0;
	new_hist = output - this->history2 * this->coef1;

	output = new_hist + this->history1 * 2.f;
	output += this->history2;

	this->history2 = this->history1;
	this->history1 = new_hist;

	output -= this->history3 * this->coef2;
	new_hist = output - this->history4 * this->coef3;

	output = new_hist + this->history3 * 2.f;
	output += this->history4;

	this->history4 = this->history3;
	this->history3 = new_hist;

	return output;
}
```

## Comments

<details>
<summary>Show 13 replies</summary>

1. **moc.oohay@bob** · *2007-01-22 18:38:23*

   This sounds really nice, especially with resonance. Although it becomes unstable below 4K (at 44100 s/r), which explains why the min\_cutoff value has been set quite high. Would using doubles help stabilise it?
   Also, I can't figure out how to get a high pass out of this, can anybody help?
   Cheers.

2. **neotec** · *2007-01-22 19:54:21*

   I have checked the peak output of this filter and especially for low frequences ... there is a simple fix, which makes it sound better with low frequences: change the line in Set(...) that reads 'this-\>gain = bd \* 0.5f;' to 'this-\>gain = bd;'

3. **moc.oohay@bob** · *2007-01-22 22:27:11*

   Thanks for the quick reply. I've tried your change and it's made a slight tonal difference here, but the tests were not particularly scientific. I've discovered more detail in the problem, and it's one that has been commented on with other filters: If I sweep the filter quickly up or down the low frequencies it blows out really badly, even with zero Q. I'm new to filter math, so excuse my ignorance if this is a common thing with Butterworth.

4. **neotec** · *2007-01-23 12:54:03*

   Yep ... this filter reacts very extreme on fast cutoff changes. I've added a function to my VST Synthesizer, which 'fades' the cutoff value from actual value to the desired one in about 0.05 seconds. My modulation envelopes do have similar restrictions concerning speed.

5. **neotec** · *2007-01-23 16:35:51*

   If you want to know how this filter sounds, visit the kvraudio forum, and search here: "KVR Forum » Instruments" for "Cetone VST Plugins".

6. **moc.erehwon@ydobon** · *2007-01-29 21:57:52*

   I'm wondering about that tanh in the "Set."

   Could replace with a pade appromimation, maybe. What is the range of inputs going into it?

   In other words, how small and big does this get?...

   this-\>t3 \* cutoff

7. **moc.dniftnacuoyerehwemos@tsaot** · *2007-01-29 22:06:28*

   Possible small optimization. It depends on how smart your compiler is, but sections like this...

   ```text
       output = new_hist + this->history3 * 2.f;
       output += this->history4;
   ```

   can be changed to this to change the multiply to an addition:

   ```text
   output = this->history3;
   output += output+new_Hist+this->history4;
   ```

8. **moc.dniftnacuoyerehwemos@tsaot** · *2007-01-30 03:05:05*

   While I'm at it, one of these divisions can easily be switched to a multiply...

   ```text
    b1 = (1.847759f / q) / wp;

   b1=(1.847759f/(q*wp);
   ```

9. **moc.oohay@bob** · *2007-02-04 19:32:55*

   Four times oversampling removes the problems with fast cut-off sweeps at low values.
   This filter has the same shape as a normal biquad filter, with a more pronounced resonance boost.

10. **gro.lortnocdnim@gro.psdcisum** · *2008-01-12 20:42:34*

    Why would oversampling solve the problem? If you over-sample, the poles have to reach even further into the relative frequencies, and stability would become more of a problem AFAICT.

11. **moc.oohay@bob** · *2008-01-21 14:58:55*

    It just seems to. If you 4X over-sample, then it gives it a 4X chance to recover from each sweep change, presuming you're not changing the filter cut-off at 4X also.

12. **erehwon.ku.oc.snosrapsd@psdcisum** · *2008-01-25 14:46:31*

    thing is with 4X oversampling on this is that you'll be reducing precision on omega (wp here), and so should probably shift to double rather than float to help accuracy.

13. **moc.liam@ttocs** · *2013-04-24 02:48:07*

    Did anyone figure out how to get a high pass out of this?

    Thanks!

</details>
