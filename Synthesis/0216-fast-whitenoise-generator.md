# Fast Whitenoise Generator

[MusicDSP](../README.md) / [Synthesis](README.md) · [10 comments](#comments)

- **Author or source:** ed.bew@hcrikdlef.dreg
- **Type:** Whitenoise
- **Created:** 2006-02-23 22:39:56

## Notes

This is Whitenoise... :o)

## Code

```cpp
float g_fScale = 2.0f / 0xffffffff;
int g_x1 = 0x67452301;
int g_x2 = 0xefcdab89;

void whitenoise(
  float* _fpDstBuffer, // Pointer to buffer
  unsigned int _uiBufferSize, // Size of buffer
  float _fLevel ) // Noiselevel (0.0 ... 1.0)
{
  _fLevel *= g_fScale;

  while( _uiBufferSize-- )
  {
    g_x1 ^= g_x2;
    *_fpDstBuffer++ = g_x2 * _fLevel;
    g_x2 += g_x1;
  }
}
```

## Comments

<details>
<summary>Show 10 replies</summary>

1. **uh.etle.fni@yfoocs** · *2006-07-18 17:34:00*

   Works well! Kinda fast! The spectrum looks completely flat in an FFT analyzer.

2. **ed.bew@hcrikdlef.dreg** · *2006-11-29 20:50:44*

   As I said! :-)
   Take care

3. **moc.erehwon@ydobon** · *2006-11-30 00:57:31*

   I'm now waiting for pink and brown. :-)

4. **uh.etle.fni@yfoocs** · *2006-11-30 15:02:54*

   To get pink noise, you can apply a 3dB/Oct filter, for example the pink noise filter in the Filters section.

   To get brown noise, apply an one pole LP filter to get a 6dB/oct slope.

   Peter

5. **moc.erehwon@ydobon** · *2006-11-30 17:55:02*

   Yeah, I know how to do it with a filter. I was just looking to see if this guy had anything else clever up his sleeve.

   I'm currently using this great stuff:

   vellocet.com/dsp/noise/VRand.html

6. **moc.liamg@palbmert** · *2006-12-15 17:12:19*

   I compiled it, but I get some grainyness that a unisgned long LC algorithm does not give me...  am I the only one?

   pa

7. **uh.etle.fni@yfoocs** · *2006-12-17 18:12:42*

   Did you do everything right? It works here.

8. **ed.bew@hcrikdlef.dreg** · *2006-12-19 21:24:04*

   I've noticed that my code is similar to a so called "feedback shift register" as used in the Commodore C64 Soundchip 6581 called SID for noise generation.

   Links:
   en.wikipedia.org/wiki/Linear\_feedback\_shift\_register
   en.wikipedia.org/wiki/MOS\_Technology\_SID
   www.cc65.org/mailarchive/2003-06/3156.html

9. **---.liam@firA** · *2007-03-13 00:39:39*

   SID noise! cool.

10. **TaleTN** · *2021-06-25 11:43:00*

    I still seem to run into this noise generator from time to time, so I thought I'd provide some extra info here:

    The seed provided above will result in a sequence with a period of 3/4 \* 2^29, and with 268876131 unique output values in the \[-2147483635, 2147483642\] range. This is probably more than enough to generate white noise at any reasonable sample rate, but you can easily increase/max out the period and range, simply by using different seed values.

    If you instead use g\_x1 = 0x70f4f854 and g\_x2 = 0xe1e9f0a7, then this will result in a sequence with a period of 3/4 \* 2^32, with 1896933636 unique output values in the \[-2147483647, 2147483647\] range. This is probably the best you can do with a word size of 32 bits. Also note that only the highest bit will actually have the max period, lower bits will have increasingly shorter periods (just like with a Linear Congruential Generator).

</details>
