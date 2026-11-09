# Fast Exponential Envelope Generator

[MusicDSP](../README.md) / [Synthesis](README.md)

- **Author or source:** Christian Schoenebeck
- **Created:** 2005-03-03 14:44:11

## Notes

The naive way to implement this would be to use a exp() call for each point
of the envelope. Unfortunately exp() is quite a heavy function for most
CPUs, so here is a numerical, much faster way to compute an exponential
envelope (performance gain measured in benchmark: about factor 100 with a
Intel P4, gcc -O3 --fast-math -march=i686 -mcpu=i686).

Note: you can't use a value of 0.0 for levelEnd. Instead you have to use an
appropriate, very small value (e.g. 0.001 should be sufficiently small
enough).

## Code

```cpp
const float sampleRate = 44100;
float coeff;
float currentLevel;

void init(float levelBegin, float levelEnd, float releaseTime) {
    currentLevel = levelBegin;
    coeff = (log(levelEnd) - log(levelBegin)) /
            (releaseTime * sampleRate);
}

inline void calculateEnvelope(int samplePoints) {
    for (int i = 0; i < samplePoints; i++) {
        currentLevel += coeff * currentLevel;
        // do something with 'currentLevel' here
        ...
    }
}
```

## Comments

**moc.erawknuhc@knuhcnezitic** · 2005-03-03 21:16:41

is there a typo in the runtime equation? or am i missing something in the implementation?

**schoenebeck (@) software ( minus ) engineering.org** · 2005-03-04 15:13:56

Why should there be a typo?

Here is my benchmark code btw:
<http://stud.fh-heilbronn.de/~cschoene/studienarbeit/benchmarks/exp.cpp>

**moc.erawknuhc@knuhcnezitic** · 2005-03-04 16:20:41

ok, i think i get it. this can only work on blocks of samples, right? not per-sample calc?

i was confused because i could not find the input sample(s) in the runtime code. but now i see that the equation does not take an input; it merely generates a defined envelope accross the number of samples. my bad.

**schoenebeck (@) software ( minus ) engineering.org** · 2005-03-04 19:16:29

Well, the code above is only meant to show the principle. Of course you
would adjust it for your application. The question if you are calculating
on a per-sample basis or applying the envelope to a block of samples
within a tight loop doesn't really matter; it would just mean an
adjustment of the interface of the execution code, which is trivial.

**ten.ooleem@ooleem** · 2005-03-05 10:26:44

This is not working for long envelopes because of numerical accury problems. Try calculating is over 10 seconds @ 192KHz to see what I mean: it drifts.
I have an equivalent system that permits to have linear to log and to exp curves with a simple parameter. I may submit it one of these days...

Sebastien Metrot
\--
<http://www.usbsounds.com>

**schoenebeck (@) software ( minus ) engineering.org** · 2005-03-05 13:48:12

No, here is a test app which shows the introduced drift:
<http://stud.fh-heilbronn.de/~cschoene/studienarbeit/benchmarks/expaccuracy.cpp>

Even with an envelope duration of 30s, which is really quite long, a sample
rate of 192kHz and single-precision floating point calculation I get this
result:

Calculated sample points: 5764846
Demanded duration: 30.000000 s
Actual duration: 30.025240 s

So the envelope just drifts about 25ms for that long envelope!

**ten.ooleem@ooleem** · 2005-03-09 11:44:31

```text
I believe you are seeing unrealistic results with this test because on x86 the fpu's internal format is 80bits and your compiler probably optimises this cases quite easily. Try doing the same test, calculating the same envelope, but by breaking the calculation in blocks of 256 or 512 samples at a time and then storing in memory the temp values for the next block. In this case you may see diferent results and a much bigger drift (that's my experience with the same algo).
Anyway my algo is a bit diferent as it permits to change the curent type with a parameter, this makes the formula looks like
value = value * coef + contant;
May be this leads to more calculation errors :).
```

**schoenebeck (@) software ( minus ) engineering.org** · 2005-03-09 13:33:43

And again... no! :)

Replace the C equation by:

```text
    asm volatile (
        "movss %1,%%xmm0      # load coeff\n\t"
        "movss %2,%%xmm1      # load currentLevel\n\t"
        "mulss %%xmm1,%%xmm0  # coeff *= currentLevel\n\t"
        "addss %%xmm0,%%xmm1  # currentLevel += coeff * currentLevel\n\t"
        "movss %%xmm1,%0      # store currentLevel\n\t"
        : "=m" (currentLevel) /* %0 */
        : "m" (coeff),        /* %1 */
          "m" (currentLevel)  /* %2 */
    );
```

This is a SSE1 assembly implementation. The SSE registers are only 32 bit
large by guarantee. And this is the result I get:

Calculated sample points: 5764845
Demanded duration: 30.000000 s
Actual duration: 30.025234 s

So this result differs just 1 sample point from the x86 FPU solution! So
believe me, this numerical solution is safe!

(Of course the assembly code above is NOT meant as optimization, it's just
to demonstrate the accuracy even for 32 bit / single precision FP
calculation)

**m (at) mindplay (dot) dk** · 2005-03-23 22:42:06

in my tests, the following code produced the exact same results, and saves one operation (the addition) per sample - so it should be faster:

```text
const float sampleRate = 44100;
float coeff;
float currentLevel;

void init(float levelBegin, float levelEnd, float releaseTime) {
    currentLevel = levelBegin;
    coeff = exp(log(levelEnd)) /
            (releaseTime * sampleRate);
}

inline void calculateEnvelope(int samplePoints) {
    for (int i = 0; i < samplePoints; i++) {
        currentLevel *= coeff;
        // do something with 'currentLevel' here
        ...
    }
}

...
```

Also, assuming that your startLevel is 1.0, to calculate an appropriate endLevel, you can use something like:

```text
endLevel = 10 ^ dB/20;
```

where dB is your endLevel in decibels (and must be a negative value of course) - for amplitude envelopes, -90 dB should be a suitable level for "near inaudible"...

**schoenebeck (@) software ( minus ) engineering.org** · 2005-03-31 14:45:51

```text
              Sorry, you are right of course; that simplification of the execution
equation works here because we are calculating all points with linear
discretization. But you will agree that your init() function is not good,
because exp(log(x)) == x and it's not generalized at all. Usually you might
have more than one exp segment in your EG and maybe even have an exp attack
segment. So we arrive at the following solution:

const float sampleRate = 44100;
float coeff;
float currentLevel;

void init(float levelBegin, float levelEnd, float releaseTime) {
    currentLevel = levelBegin;
    coeff = 1.0f + (log(levelEnd) - log(levelBegin)) /
                   (releaseTime * sampleRate);
}

inline void calculateEnvelope(int samplePoints) {
    for (int i = 0; i < samplePoints; i++) {
        currentLevel *= coeff;
        // do something with 'currentLevel' here
        ...
    }
}
```

You can use a dB conversion for both startLevel and endLevel of course.

**na** · 2006-03-10 01:53:44

```text
i would say that calculation of coeff is still wrong. It should be :
coeff = pow( levelEnd / levelBegin, 1 / N );
```

**na\[ eldar # starman # ee\]** · 2006-03-10 02:23:29

```text
or coeff = exp(log(levelEnd/levelBegin) /
            (releaseTime * sampleRate) );
not sure but it looks computationally more expensive
```

**hc.xmg@.i.l.e** · 2006-11-26 15:44:04

```text
what's about?
coeff = 1.0f + (log(levelEnd) - log(levelBegin)) /
                   (releaseTime * sampleRate - 1);
```

**hc.xmg@.i.l.e** · 2006-11-26 15:55:12

```text
sorry for the double post. and i'm now almost sure, that it should be:
coeff = 1.0f + (log(levelEnd) - log(levelBegin)) /
                   (releaseTime * sampleRate + 1);
```
