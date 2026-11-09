# Clipping without branching

[MusicDSP](../README.md) / [Other](README.md) · [6 comments](#comments)

- **Author or source:** Laurent de Soras (moc.ecrofmho@tnerual)
- **Type:** Min, max and clip
- **Created:** 2004-04-07 09:35:57

## Notes

It may reduce accuracy for small numbers. I.e. if you clip to \[-1; 1\], fractional part of
the result will be quantized to 23 bits (or more, depending on the bit depth of the
temporary results). Thus, 1e-20 will be rounded to 0. The other (positive) side effect is
the denormal number elimination.

## Code

```cpp
float max (float x, float a)
{
   x -= a;
   x += fabs (x);
   x *= 0.5;
   x += a;
   return (x);
}

float min (float x, float b)
{
   x = b - x;
   x += fabs (x)
   x *= 0.5;
   x = b - x;
   return (x);
}

float clip (float x, float a, float b)
{
   x1 = fabs (x-a);
   x2 = fabs (x-b);
   x = x1 + (a+b);
   x -= x2;
   x *= 0.5;
   return (x);
}
```

## Comments

<details>
<summary>Show 6 replies</summary>

1. **ten.xfer@spelk** · *2002-04-15 04:05:45*

   AFAIK, the fabs() is using if()...

2. **moc.tecollev@ydna** · *2002-05-27 11:48:41*

   ```text
   fabs/fabsf do not use if and are quicker than:
   if (x<0) x = -x;
   Do the speed tests yourself if you don't believe me!
   ```

3. **moc.noicratse@ajelak** · *2002-06-26 09:55:50*

   Depends on CPU and optimization options, but yes, Visual C++/x86/full optimization uses intrinsic fabs, which is very cool.

4. **moc.semag-allirreug@regninned.trannel** · *2003-10-21 15:38:40*

   And ofcourse you could always use one of those nifty bit-tricks for fabs :)

   (Handy when you don't want to link with the math-library, like when coding a softsynth for a 4Kb-executable demo :))

5. **moc.dh2a@ydna** · *2004-01-31 04:24:22*

   according to my benchmarks (using the cpu clock cycle counter), fabs and the 'nifty bit tricks' have identicle performance characterstics, EXCEPT that with the nifty bit trick, sometimes it has a -horrible- penalty, which depends on the context..., maybe it does not optimize consistently?  I use libmath fabs now.  (i'm using gcc-3.3/linux on a P3)

6. **moc.noicratse@ajelak** · *2004-04-12 05:07:58*

   Precision can be a major problem with these. In particular, if you have an algorithm that blows up with negative input, don't guard via clip( in, 0.0, 1.0 ) - it will occasionally go negative.

</details>
