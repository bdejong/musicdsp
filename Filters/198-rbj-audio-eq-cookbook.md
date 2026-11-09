# RBJ Audio-EQ-Cookbook

[MusicDSP](../README.md) / [Filters](README.md)

- **Author or source:** Robert Bristow-Johnson
- **Created:** 2005-05-04 20:33:31
- **Linked files:** [EQ-Coefficients.pdf](../files/EQ-Coefficients.pdf).

## Notes

see attached file

## Comments

**eb.tenyks@didid** · 2005-05-14 06:35:17

Hi

In your most recent version, you write:

```text
--
    alpha = sin(w0)/(2*Q)       (case: Q)
          = sin(w0)*sinh( ln(2)/2 * BW * w0/sin(w0) )       (case: BW)
          = sin(w0)/2 * sqrt( (A + 1/A)*(1/S - 1) + 2 )        (case: S)
--
```

But the 'slope' case doesn't seem to work for me. It results in some kind of bad resonance at higher samplerates.

Now I found this 'beta' in an older version of your paper (I think), describing:

```text
--
    beta  = sqrt(A)/Q   (for shelving EQ filters only)
          = sqrt(A)*sqrt[ (A + 1/A)*(1/S - 1) + 2 ]        (if shelf slope is specified)
          = sqrt[ (A^2 + 1)/S - (A-1)^2 ]
--
```

..and here the
sqrt(A)\*sqrt\[ (A + 1/A)\*(1/S - 1) + 2 \]
formula works perfectly for me.

I must say I don't understand half of the theory, so it's probably my fault somewhere. But why the change in the newer version?

**moc.noitanigamioidua@jbr** · 2005-05-20 20:56:45

\>But why the change in the newer version?
\----------------------------------------------------------

i wanted to get rid of an extraneous intermediate variable and there was enough similarity between alpha and beta that i changed the lowShelf and highShelf coefficient equations to be in terms of alpha rather than beta.

i believe if you use the new version as shown, in terms of alpha (but remember the coef equations are changed accordingly from the old version), it will come up with the same coefficients given the same boost gain, Q (or S), and shelf frequency (and same Fs).  lemme know if you still have trouble.

r b-j
