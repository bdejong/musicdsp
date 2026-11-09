# Hermite interpollation

[MusicDSP](../README.md) / [Other](README.md) · [9 comments](#comments)

- **Author or source:** various
- **Created:** 2002-04-09 16:55:35

## Notes

These are all different ways to do the same thing : hermite interpollation. Try'm all and
benchmark.

## Code

```cpp
// original
inline float hermite1(float x, float y0, float y1, float y2, float y3)
{
    // 4-point, 3rd-order Hermite (x-form)
    float c0 = y1;
    float c1 = 0.5f * (y2 - y0);
    float c2 = y0 - 2.5f * y1 + 2.f * y2 - 0.5f * y3;
    float c3 = 1.5f * (y1 - y2) + 0.5f * (y3 - y0);

    return ((c3 * x + c2) * x + c1) * x + c0;
}

// james mccartney
inline float hermite2(float x, float y0, float y1, float y2, float y3)
{
    // 4-point, 3rd-order Hermite (x-form)
    float c0 = y1;
    float c1 = 0.5f * (y2 - y0);
    float c3 = 1.5f * (y1 - y2) + 0.5f * (y3 - y0);
    float c2 = y0 - y1 + c1 - c3;

    return ((c3 * x + c2) * x + c1) * x + c0;
}

// james mccartney
inline float hermite3(float x, float y0, float y1, float y2, float y3)
{
        // 4-point, 3rd-order Hermite (x-form)
        float c0 = y1;
        float c1 = 0.5f * (y2 - y0);
        float y0my1 = y0 - y1;
        float c3 = (y1 - y2) + 0.5f * (y3 - y0my1 - y2);
        float c2 = y0my1 + c1 - c3;

        return ((c3 * x + c2) * x + c1) * x + c0;
}

// laurent de soras
inline float hermite4(float frac_pos, float xm1, float x0, float x1, float x2)
{
   const float    c     = (x1 - xm1) * 0.5f;
   const float    v     = x0 - x1;
   const float    w     = c + v;
   const float    a     = w + v + (x2 - x0) * 0.5f;
   const float    b_neg = w + a;

   return ((((a * frac_pos) - b_neg) * frac_pos + c) * frac_pos + x0);
}
```

## Comments

<details>
<summary>Show 9 replies</summary>

1. **theguylle** · *2002-05-25 13:37:32*

   ```text
                 great sources but what is Hermite ?
   if you don't describe what is your code made for, you will made a great sources but I don't know why?
   ```

   cheers Paul

2. **gro.psdcisum@marb** · *2002-08-15 00:48:25*

   hermite is interpollation.
   have a look around the archive, you'll see that the word 'hermite' is in more than one item ;-)

   ```text
     -bram
   ```

3. **rb.moc.rapenas@fwodlanor** · *2003-07-29 10:46:40*

   Please, would like to know of hermite code it exists in delphi.

   thankful

   Ronaldo
   Cascavel/Paraná/Brasil

4. **moc.rotces-dabMAPSON@inirgam.m** · *2003-10-10 08:36:06*

   Please,
   add, at least, the meaning of each parameter (I mean x, y0,  y1,y2,  y3)....
   m.

5. **musicdsp@\[remove this\]dsparsons.co.uk** · *2003-11-28 10:48:17*

   Ronaldo, it doesn't take much to translate these to Delphi - for float, either use single or double to your preference!

   Looking at the codes, it seems quite clear that the parameters follow a pattern of: Sample Position between middle two samples, then the sample before current, current sample, curernt sample +1, current sample +2.

   HTH
   DSP

6. **moc.liamtoh@sisehtnysorpitna** · *2004-03-28 20:51:59*

   What are all these variables standing for? Not very clear :\|

7. **George** · *2004-04-20 00:25:29*

   parameters are allright.

   xm1 ---\> x\[n-1\]
   x0  ---\> x\[n\]
   x1  ---\> x\[n+1\]
   x2  ---\> x\[n+2\]

   fractional position stands for a fraction between 0 and 1 to interpolate

8. **snehpyhehttuoekatdnatahwwonkuoy.liamg@rood-nosiop-saionarap** · *2004-10-17 01:16:50*

   Couldn't #2 be sped up a hair by commenting out

   ```text
   float c0 = y1;
   ```

   and then replacing c0 with y1 in the return line?  Or do the compilers do that kind of thing automatically when they optimize?

9. **moc.oi@htnysa** · *2007-07-13 01:52:27*

   "Couldn't #2 be sped up a hair"
   It gets optimized out.

</details>
