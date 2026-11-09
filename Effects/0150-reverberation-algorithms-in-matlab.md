# Reverberation Algorithms in Matlab

[MusicDSP](../README.md) / [Effects](README.md) · [2 comments](#comments)

- **Author or source:** Gautham J. Mysore (moc.oohay@mjmahtuag)
- **Created:** 2003-07-15 08:58:05
- **Linked files:** [MATLABReverb.zip](../files/MATLABReverb.zip).

## Notes

These M-files implement a few reverberation algorithms (based on Schroeder's and Moorer's
algorithms). Each of the M-files include a short description.

There are 5 M-files that implement reverberation. They are:

\- schroeder1.m
\- schroeder2.m
\- schroeder3.m
\- moorer.m
\- stereoverb.m

The remaining 8 M-files implement filters, delay lines etc. Most of these are used in the
above M-files. They can also be used as building blocks for other reverberation
algorithms.

## Comments

<details>
<summary>Show 2 replies</summary>

1. **moc.loa@mnijwerb** · *2003-08-15 04:04:56*

   StereoVerb is the name of an old car stereo "enhancer" from way back. I was just trying to find
   it's roots.

2. **moc.oohay@y\_sunave** · *2004-04-02 04:44:46*

   ```text
   There is another allpass filter transfer function.
         -g+Z^(-m)
   H(z)=------------
         1-gZ^(-m)
   ```

   g is the attenuation
   m is the number of delay (in sampel)

   This allpass will give exponential decay impulse response, compare to your allpass that give
   half sinc decay impulse response.

</details>
