# Resonant filter

[MusicDSP](../README.md) / [Filters](README.md) · [3 comments](#comments)

- **Author or source:** Paul Kellett
- **Created:** 2002-01-17 02:07:02

## Notes

This filter consists of two first order low-pass filters in
series, with some of the difference between the two filter
outputs fed back to give a resonant peak.

You can use more filter stages for a steeper cutoff but the
stability criteria get more complicated if the extra stages
are within the feedback loop.

## Code

```cpp
//set feedback amount given f and q between 0 and 1
fb = q + q/(1.0 - f);

//for each sample...
buf0 = buf0 + f * (in - buf0 + fb * (buf0 - buf1));
buf1 = buf1 + f * (buf0 - buf1);
out = buf1;
```

## Comments

<details>
<summary>Show 3 replies</summary>

1. **mr.just starting** · *2006-01-18 10:59:55*

   very nice! how could i turn that into a HPF?

2. **ku.oc.mapson.snosrapsd@psd** · *2006-01-23 10:53:41*

   ```text
   The cheats way is to use HPF = sample - out;
   If you do a plot, you'll find that it isn't as good as designing an HPF from scratch, but it's good enuff for most ears.
   This would also mean that you have a quick method for splitting a signal and operating on the (in)discreet parts separately. :) DSP
   ```

3. **uh.etle.fni@yfoocs** · *2006-09-12 14:42:25*

   This filter calculates bandpass and highpass outputs too during calculation, namely bandpass is buf0 - buf1 and highpass is in - buf0. So, we can rewrite the algorithm:

   ```cpp
   // f and fb calculation
   f = 2.0*sin(pi*freq/samplerate);
   /* you can approximate this with f = 2.0*pi*freq/samplerate with tuning error towards nyquist */
   fb = q + q/(1.0 - f);

   // loop
   hp = in - buf0;
   bp = buf0 - buf1;
   buf0 = buf0 + f * (hp + fb * bp);
   buf1 = buf1 + f * (buf0 - buf1);

   out = buf1; // lowpass
   out = bp; // bandpass
   out = hp; // highpass
   ```

   The slope of the highpass out is not constant, it varies between 6 and 12 dB/Octave with different f and q settings. I'd be interested if anyone derived a proper highpass output from this algorithm.

   -- peter schoffhauzer

</details>
