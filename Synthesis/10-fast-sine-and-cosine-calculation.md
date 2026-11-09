# Fast sine and cosine calculation

[MusicDSP](../README.md) / [Synthesis](README.md) · [9 comments](#comments)

- **Author or source:** Lot's or references... Check Julius O. SMith mainly
- **Type:** waveform generation
- **Created:** 2002-01-17 00:54:32

## Code

```cpp
init:
float a = 2.f*(float)sin(Pi*frequency/samplerate);

float s[2];

s[0] = 0.5f;
s[1] = 0.f;

loop:
s[0] = s[0] - a*s[1];
s[1] = s[1] + a*s[0];
output_sine = s[0];
output_cosine = s[1]
```

## Comments

<details>
<summary>Read 9 archived comments</summary>

1. **DFL** · *2003-04-05 10:52:49*

   Yeah, this is a cool trick! :)

   FYI you can set s\[0\] to whatever amplitude of sinewave you desire. With 0.5, you will get +/- 0.5

2. **gro.tucetontsap@kcitgib** · *2003-04-05 17:02:22*

   ```text
   After a while it may drift, so you should resync it as follows:
   const float tmp=1.5f-0.5f*(s[1]*s[1]+s[0]*s[0]);
   s[0]*=tmp; s[1]*=tmp;
   ```

   This assumes you set s\[0\] to 1.0 initially.

   'Tick

3. **DFL** · *2003-04-08 09:19:40*

   Just to expalin the above "resync" equation
   (3-x)/2 is an approximation of 1/sqrt(x)
   So the above is actually renormalizing the complex magnitude.
   \[ sin^2 (x) + cos^2(x) = 1 \]

4. **nigel** · *2003-05-15 08:26:22*

   This is the Chamberlin state variable filter specialized for infinite Q oscillation. A few things to note:

   Like the state variable filter, the upper frequency limit for stability is around one-sixth the sample rate.

   The waveform symmetry is very pure at low frequencies, but gets skewed as you get near the upper limit.

   For low frequencies, sin(n) is very close to n, so the calculation for "a" can be reduced to a = 2\*Pi\*frequency/samplerate.

   You shouldn't need to resync the oscillator--for fixed point and IEEE floating point, errors cancel exactly, so the osciallator runs forever without drifting in amplitude or frequency.

5. **moc.liamtoh@sisehtnysorpitna** · *2003-11-03 00:14:34*

   I made a nice little console 'game' using your cordic sinewave approximation. Download it at <http://users.pandora.be/antipro/Other/Ascillator.zip> (includes source code). Just for oldschool fun :).

6. **hplus** · *2004-12-22 16:52:20*

   Note that the peaks of the waveforms will actually be between samples, and the functions will be phase offset by one half sample's worth. If you need exact phase, you can compensate by interpolating using cubic hermite interpolation.

7. **more on that topic...** · *2007-07-24 20:33:12*

   ... can be found in Jon Datorro, Effect Design, Part 3, a paper that can be easily found in the web.

   Funny, this is just a complex multiply that is optimized for small angles (low frequencies)

   When the CPU rounding mode is set to nearest, it should be stable, at least for small frequencies.

8. **ed.corm@liam** · *2007-07-24 20:34:22*

   More on that can be found in Jon Datorro, Effect Design, Part 3, a paper that can be easily found in the web.

   Funny, this is just a complex multiply that is optimized for small angles (low frequencies)

   When the CPU rounding mode is set to nearest, it should be stable, at least for small frequencies.

9. **moc.foohay@bob** · *2008-09-21 20:16:40*

   How do I set a particular phase for this? I've tried setting s\[0\] = cos(phase) and s\[1\] = sin(phase), but that didn't seem to be accurate enough.

   Thanks

</details>
