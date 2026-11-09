# Bandlimited waveform generation

[MusicDSP](../README.md) / [Synthesis](README.md) · [1 comment](#comments)

- **Author or source:** Joe Wright
- **Type:** waveform generation
- **Created:** 2002-01-17 01:06:49
- **Linked files:** [bandlimited.cpp](../files/bandlimited.cpp).
- **Linked files:** [bandlimited.pdf](../files/bandlimited.pdf).

## Notes

(see linkfile)

## Comments

<details>
<summary>Read 1 archived comment</summary>

1. **ed.redienhcsslin@psdcisum** · *2012-02-10 16:26:11*

   The code to reduce the gibbs effect causes aliasing if a transition is made from wavetable A with x partials to wavetable B with y partials.

   The aliasing can clearly be seen in a spectral view.

   The problem is, that the volume modification for partial N is different depending on the number of partials the wavetable row contains

</details>
