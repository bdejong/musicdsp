# Rational tanh approximation

[MusicDSP](../README.md) / [Other](README.md) · [5 comments](#comments)

- **Author or source:** cschueler
- **Type:** saturation
- **Created:** 2006-11-15 17:29:12

## Notes

This is a rational function to approximate a tanh-like soft clipper. It is based on the
pade-approximation of the tanh function with tweaked coefficients.

The function is in the range x=-3..3 and outputs the range y=-1..1. Beyond this range the
output must be clamped to -1..1.

The first to derivatives of the function vanish at -3 and 3, so the transition to the hard
clipped region is C2-continuous.

## Code

```c
float rational_tanh(x)
{
    if( x < -3 )
        return -1;
    else if( x > 3 )
        return 1;
    else
        return x * ( 27 + x * x ) / ( 27 + 9 * x * x );
}
```

## Comments

<details>
<summary>Show 5 replies</summary>

1. **uh.etle.fni@yfoocs** · *2006-11-24 16:24:54*

   Works fine. If you want only a little overdrive, you don't even need the clipping, just the last line for faster processing.

   ```c
   float rational_tanh_noclip(x)
   {
     return x * ( 27 + x * x ) / ( 27 + 9 * x * x );
   }
   ```

   The maximum error of this function in the -4.5 .. 4.5 range is about 2.6%.

2. **uh.etle.fni@yfoocs** · *2006-11-30 15:59:33*

   By the way this is the fastest tanh() approximation in the archive so far.

3. **cschueler** · *2006-12-08 21:21:02*

   Yep, I thought so.
   That's why I thought it would be worth sharing.

   Especially fast when using SSE you can do a 4-way parallel implementation, with MIN/MAX and the RCP instruction.

4. **mdsp** · *2007-01-26 12:13:50*

   nice one

   BTW if you google about "pade-approximation" you'll find a nice page with many solutions for common functions.

   there's exp, log, sin, cos, tan, gaussian...

5. **uh.etle.fni@yfoocs** · *2007-02-18 03:35:13*

   Yep, but the RCP increases the noise floor somewhat, giving a quantized sound, so I'd refrain from using it for high quality audio.

</details>
