# Cool Sounding Lowpass With Decibel Measured Resonance

[MusicDSP](../README.md) / [Filters](README.md) · [7 comments](#comments)

- **Author or source:** ua.moc.ohay@renrew\_bocaj\_leinad
- **Type:** LP 2-pole resonant tweaked butterworth
- **Created:** 2004-09-01 17:56:44

## Notes

This algorithm is a modified version of the tweaked butterworth lowpass filter by Patrice
Tarrabia posted on musicdsp.org's archives. It calculates the coefficients for a second
order IIR filter. The resonance is specified in decibels above the DC gain. It can be made
suitable to use as a SoundFont 2.0 filter by scaling the output so the overall gain
matches the specification (i.e. if resonance is 6dB then you should scale the output by
-3dB). Note that you can replace the sqrt(2) values in the standard butterworth highpass
algorithm with my "q =" line of code to get a highpass also. How it works: normally q is
the constant sqrt(2), and this value controls resonance. At sqrt(2) resonance is 0dB,
smaller values increase resonance. By multiplying sqrt(2) by a power ratio we can specify
the resonant gain at the cutoff frequency. The resonance power ratio is calculated with a
standard formula to convert between decibels and power ratios (the powf statement...).

Good Luck,
Daniel Werner
<http://experimentalscene.com/>

## Code

```c
float c, csq, resonance, q, a0, a1, a2, b1, b2;

c = 1.0f / (tanf(pi * (cutoff / samplerate)));
csq = c * c;
resonance = powf(10.0f, -(resonancedB * 0.1f));
q = sqrt(2.0f) * resonance;
a0 = 1.0f / (1.0f + (q * c) + (csq));
a1 = 2.0f * a0;
a2 = a0;
b1 = (2.0f * a0) * (1.0f - csq);
b2 = a0 * (1.0f - (q * c) + csq);
```

## Comments

<details>
<summary>Show 7 replies</summary>

1. **acid\_mutant\[aat\]yahoo\[doot\]com** · *2005-11-24 17:59:36*

   For some reason when I tested this algorithm, even though the frequency response looked OK in my graphs - i.e. it should resonate the output didn't seem to be very resonant - it could be a phase issue, I'll keep checking.

   (BTW: I use an impulse, then FFT, then display the power bands returned)

2. **moc.snad@snad** · *2006-03-09 18:38:39*

   shouldn't it be

   ```c
   resonance = powf(10.0f, -(resonancedB * 0.05f));
   ```

   instead of

   ```c
   resonance = powf(10.0f, -(resonancedB * 0.1f));
   ```

   to get correct dB gain?

   ... since gain = 10^(dB/20) ...

3. **uh.etle.fni@yfoocs** · *2007-01-06 04:29:10*

   Agree with the last post.

4. **moc.enecslatnemirepxe.ecnuob@ton.em.maps.renrewd** · *2007-08-21 14:00:21*

   The algorithm was developed with a digital signal of 32-bit floating point pseudo-random white noise running through it. The level of resonance was measured by visually plotting the output of the FFT of the signal. I half agree with the second last post, i.e. dB in acoustics is not the same as dB in digital audio. Correct me if I am wrong, it is a long time since I thought about this.

5. **moc.oohay@tsvsoxox** · *2010-12-10 23:53:27*

   there is something very wrong with this code as it is printed here, i don't expect anyone is going to make any effort to correct it or verify it.

6. **moc.halb@halb** · *2015-09-14 18:11:21*

   You need to use 0.5 in the power function to convert from the db to the linear.

   You can apply a GAIN reduction by doing the same thing but make it smaller.

   ```c
   GAIN = powf(10.0f, -((resonance*0.25) * 0.05 ));
   ```

   The use the GAIN to the input of the filter. If you use it to the output and change resonance rapidly it will click.

   For the gain you can change the 0.25 to 0.125 or 0.075 if you feel that it is to quiet when you turn the resonance up.

7. **moc.halb@halb** · *2015-09-14 18:14:36*

   Correction to me previous post, I meant 0.05 in the first line.

   Convert resonance as dB to q for use in filter, use this formula.

   ```c
     q = powf(10.0f, -(resonanceDb * 0.05) );
   ```

   It will give you a value from 0 to 1. But for most butterworth you do not want zero and you want it to go a little more than one to fully exploit the resonance, so scale it like below.

   ```text
   For me this works to scale the q
     q = 0.1 + q * 1.5
   ```

   For example, the 1.5 and 0.1 can be adjusted to suit your preference.

</details>
