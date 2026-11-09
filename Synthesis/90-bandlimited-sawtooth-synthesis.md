# Bandlimited sawtooth synthesis

[MusicDSP](../README.md) / [Synthesis](README.md) · [2 comments](#comments)

- **Author or source:** moc.ailet@mlohednal.leuname
- **Type:** DSF BLIT
- **Created:** 2002-03-29 18:06:44
- **Linked files:** [synthesis002.txt](../files/synthesis002.txt).

## Notes

This is working code for synthesizing a bandlimited sawtooth waveform. The algorithm is
DSF BLIT + leaky integrator. Includes driver code.

There are two parameters you may tweak:

1\) Desired attenuation at nyquist. A low value yields a duller sawtooth but gets rid of
those annoying CLICKS when sweeping the frequency up real high. Must be strictly less than
1.0!

2\) Integrator leakiness/cut off. Affects the shape of the waveform to some extent, esp. at
the low end. Ideally you would want to set this low, but too low a setting will give you
problems with DC.

Have fun!
/Emanuel Landeholm

(see linked file)

## Comments

<details>
<summary>Read 2 archived comments</summary>

1. **moc.liamtoh@hsats\_wobniar** · *2003-02-26 00:58:41*

   ```text
   there is no need to use a butterworth design for a simple leaky integrator, in this case actually the
   variable curcps can be used directly in a simple: leak += curcps * (blit - leak);
   ```

   this produces a nearly perfect saw shape in almost all cases

2. **pj.oc.liamtoh@evawtuah** · *2011-05-31 05:25:01*

   The square wave type will be able to be generated from this source.
   Please teach if it is possible.

</details>
