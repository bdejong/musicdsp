# Direct Form II biquad

[MusicDSP](../README.md) / [Filters](README.md) · [2 comments](#comments)

- **Author or source:** es.tuanopx@kileib.trebor
- **Created:** 2009-11-16 08:46:12

## Notes

The nominal implementation for biquads is the Direct Form I variant. But the Direct Form
II is actually more suited for calculating the biquad since it needs only 2 memory
locations, and the multiplications can be pipelined better by the compiler. In release
build, I've noted a considerable speedup when compared to DF I. When processing stereo,
the code below was \~ 2X faster. Until I develop a SIMD biquad that is faster, this will
do.

## Code

```cpp
// b0, b1, b2, a1, a2 calculated via r.b-j's cookbook
// formulae.
// m1, m2 are the memory locations
// dn is the de-denormal coeff (=1.0e-20f)

void processBiquad(const float* in, float* out, unsigned length)
{
    for(unsigned i = 0; i < length; ++i)
    {
        register float w = in[i] - a1*m1 - a2*m2 + dn;
        out[i] = b1*m1 + b2*m2 + b0*w;
        m2 = m1; m1 = w;
    }
    dn = -dn;
}

void processBiquadStereo(const float* inL,
   const float* inR,
   float* outL,
   float* outR,
   unsigned length)
{
    for(unsigned i = 0; i < length; ++i)
    {
        register float wL = inL[i] - a1*m1L - a2*m2L + dn;
        register float wR = inR[i] - a1*m1R - a2*m2R + dn;
        outL[i] = b1*m1L + b2*m2L + b0*wL;
        m2L = m1L; m1L = wL;
        outR[i] = b1*m1R + b2*m2R + b0*wR;
        m2R = m1R; m1R = wR;
    }
    dn = -dn;
}
```

## Comments

<details>
<summary>Show 2 replies</summary>

1. **moc.suomyn@ona** · *2010-01-13 13:44:09*

   true, this structure is faster. but it is also (even) more sensitive to coefficients changes, so it becomes unstable quite fast compaerd to the DF I form. I'd really like to know if there's a way to change coefficients and at the same time time changing the history of the filter for avoiding unstability.

2. **earlevel** · *2012-01-31 20:43:12*

   Use direct form I (single accumulation point) when using fixed-point processors. For floating point, use direct form II transposed, which has superior numerical characteristics to direct form II (non-transposed).

</details>
