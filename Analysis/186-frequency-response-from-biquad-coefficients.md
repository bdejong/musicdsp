# Frequency response from biquad coefficients

[MusicDSP](../README.md) / [Analysis](README.md) · [1 comment](#comments)

- **Author or source:** moc.feercinos@retep
- **Type:** biquad
- **Created:** 2004-11-29 09:49:47

## Notes

Here is a formula for plotting the frequency response of a biquad filter. Depending on the
coefficients that you have, you might have to use negative values for the b- coefficients.

## Code

```cpp
//w = frequency (0 < w < PI)
//square(x) = x*x

y = 20*log((sqrt(square(a0*square(cos(w))-a0*square(sin(w))+a1*cos(w)+a2)+square(2*a0*cos(w)*sin(w)+a1*(sin(w))))/
			      sqrt(square(square(cos(w))-   square(sin(w))+b1*cos(w)+b2)+square(2*   cos(w)*sin(w)+b1*(sin(w))))));
```

## Comments

<details>
<summary>Read 1 archived comment</summary>

1. **ude.drofnats.amrcc@lfd** · *2006-03-16 19:36:32*

   this formula can have roundoff errors with frequencies close to zero... (especially a problem
   with high samplerate filters)

   here is a better formula:

   from RBJ @ <http://groups.google.com/group/comp.dsp/browse_frm/thread/8c0fa8d396aeb444/a1bc5b63ac56b686>

   ```text
    20*log10[|H(e^jw)|] =
    10*log10[ (b0+b1+b2)^2 - 4*(b0*b1 + 4*b0*b2 + b1*b2)*phi + 16*b0*b2*phi^2 ]
   -10*log10[ (a0+a1+a2)^2 - 4*(a0*a1 + 4*a0*a2 + a1*a2)*phi + 16*a0*a2*phi^2 ]
   ```

   where phi = sin^2(w/2)

</details>
