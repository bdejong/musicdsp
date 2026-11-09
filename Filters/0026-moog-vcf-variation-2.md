# Moog VCF, variation 2

[MusicDSP](../README.md) / [Filters](README.md) · [11 comments](#comments)

- **Author or source:** CSound source code, Stilson/Smith CCRMA paper., Timo Tossavainen (?) version
- **Type:** 24db resonant lowpass
- **Created:** 2002-01-17 02:04:57

## Notes

in\[x\] and out\[x\] are member variables, init to 0.0 the controls:

```text
fc = cutoff, nearly linear [0,1] -> [0, fs/2]
res = resonance [0, 4] -> [no resonance, self-oscillation]
```

## Code

```cpp
Tdouble MoogVCF::run(double input, double fc, double res)
{
  double f = fc * 1.16;
  double fb = res * (1.0 - 0.15 * f * f);
  input -= out4 * fb;
  input *= 0.35013 * (f*f)*(f*f);
  out1 = input + 0.3 * in1 + (1 - f) * out1; // Pole 1
  in1  = input;
  out2 = out1 + 0.3 * in2 + (1 - f) * out2;  // Pole 2
  in2  = out1;
  out3 = out2 + 0.3 * in3 + (1 - f) * out3;  // Pole 3
  in3  = out2;
  out4 = out3 + 0.3 * in4 + (1 - f) * out4;  // Pole 4
  in4  = out3;
  return out4;
}
```

## Comments

<details>
<summary>Show 11 replies</summary>

1. **rf.oohay@elahwyksa** · *2003-03-29 21:50:47*

   This one works pretty well, thanks !

2. **moc.liamtoh@serpudr** · *2003-11-08 06:14:19*

   could somebody explain, what means this

   ```cpp
   input -= out4 * fb;
   input *= 0.35013 * (f*f)*(f*f);
   ```

   is "input-" and "input \*"  the name of an variable ??
   or is this an Csound specific parameter ??
   I want to translate this piece to Assemblercode
   Robert Dupres

3. **ten.bjc.fieltednabpop@cnahoj** · *2003-11-11 11:05:42*

   input is name of a variable with type double.

   ```cpp
   input -= out4 * fb;
   ```

   is just a shorter way for writing:

   ```cpp
   input = input - out4 * fb;
   ```

   and the \*= operator is works similar:

   ```cpp
   input *= 0.35013 * (f*f)*(f*f);
   ```

   is equal to

   ```cpp
   input = input * 0.35013 * (f*f)*(f*f);
   ```

   / Johan

4. **ude.drofnats.amrcc@lfd** · *2004-07-12 22:11:20*

   I've found this filter is unstable at low frequencies, namely when changing quickly from high to low frequencies...

5. **moc.kisuw@kmailliw** · *2004-07-17 13:39:23*

   I'm trying to double-sample this filter, like the Variable-State one. But so far no success, any tips?

   Wk

6. **ten.enegatum@liam** · *2004-08-25 08:51:08*

   What do you mean no success?  What happens?  Have you tried doing the usual oversampling tricks (sinc/hermite/mix-with-zeros-and-filter), call the moogVCF twice (with fc = fc\*0.5) and then filter and decimate afterwards?

   I'm been trying to find a good waveshaper to put in the feedback path but haven't found a good sounding stable one yet.  I had one version of the filter that tracked the envelope of out4 and used it to control the degree to which values below some threshold (say 0.08) would get squashed towards zero.  That sounded ok (actually quite good for very high inputs), but wasn't entirely stable and was glitching for low frequencies.  Then I tried a \*out4 = (1+d)\* (\*out4)/(1 + d\* (\*out4)) waveshaper, but that just aliased horribly and made the filter sound mushy and noisy.

   Plain old polynomial (x = x-x\*x\*x) saturation sounds dull.  There must be something better out there, though...  and I'd much prefer not to have to oversample to get it, though I guess that might be unavoidable.

7. **moc.liamg@fIezees** · *2006-01-30 15:52:54*

   Excuse me but just a basic question from a young
   developper
   in line  " input -= out4 \* fb;  "
   i don't understand when and how "out4" is initialised
   is it the "out4" return by the previous execution?
   which initialisation for the first execution?

8. **musicdsp@\[remove this\]dsparsons.co.uk** · *2006-01-31 17:15:24*

   all the outs should be initialised to zero, so first time around, nothing is subtracted. However, thereafter, the previous output is multiplied and subtracted from the input.

   HTH

9. **moc.liamg@gulcidrab** · *2009-11-10 16:02:55*

   YAND (Yet Another Newbie Developer) here -

   This filter sounds good, and with the addition of a 2nd harmonic waveshaper in the feedback loop, it sounds VERY good.

   I was hoping I could make it into a HP filter through the normal return in-out4 - but that strategy doesn't work for this method.  I'm afraid I'm at a loss as to what to try next - anyone have a suggestion?

   --Coz

10. **http://www.myspace.com/paradoxuncreated** · *2010-01-08 19:32:16*

    You have to subract each filter, from the input in the cascade.

    Check also the Karlsen filters, which I made a few years ago, when going through this stage in DSP.

11. **moc.llun@ved** · *2012-03-02 12:05:25*

    The best sounding LP i've found here. Any suggestions how to extract HP/BP?

    in - out4 doesn't work, as stated above, but "You have to subtract each filter, fron the input in the cascade", what does this mean?

    in - out4 - out3 - out2 - out1 doesn't work either

</details>
