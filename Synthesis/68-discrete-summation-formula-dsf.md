# Discrete Summation Formula (DSF)

[MusicDSP](../README.md) / [Synthesis](README.md) · [6 comments](#comments)

- **Author or source:** Stylson, Smith and others... (Alexander Kritov)
- **Created:** 2002-02-10 12:43:30

## Notes

Buzz uses this type of synth.
For cool sounds try to use variable,
for example a=exp(-x/12000)\*0.8 // x- num.samples

## Code

```cpp
double DSF (double x,  // input
            double a,  // a<1.0
            double N,  // N<SmplFQ/2,
            double fi) // phase
{
  double s1 = pow(a,N-1.0)*sin((N-1.0)*x+fi);
  double s2 = pow(a,N)*sin(N*x+fi);
  double s3 = a*sin(x+fi);
  double s4 =1.0 - (2*a*cos(x)) +(a*a);
  if (s4==0)
     return 0;
  else
     return (sin(fi) - s3 - s2 +s1)/s4;
}
```

## Comments

<details>
<summary>Read 6 archived comments</summary>

1. **dfl\[\*AT\*\]ccrma.stanford.edu** · *2002-11-08 11:21:19*

   According to Stilson + Smith, this should be

   ```text
   double s1 = pow(a,N+1.0)*sin((N-1.0)*x+fi);
                      ^
                      !
   ```

   Could be a typo though?

2. **Alex** · *2003-03-14 17:01:46*

   yepp..

3. **TT** · *2003-03-20 04:20:51*

   So what is wrong about "double" up there?
   For DSF, do we have to update the phase (fi input) at every sample?
   Another question is what's the input x supposed to represent? Thanks!

4. **David Lowenfels** · *2003-04-01 01:45:47*

   input x should be the phase, and fi is the initial phase I guess? Seems redundant to me.
   There is nothing wrong with the double, there is a sign typo in the original posting.

5. **moc.erehwon@ydobon** · *2007-02-14 18:04:44*

   I'm not so sure that there is a sign typo. (I know--I'm five years late to this party.)

   The author of this code just seems to have an off-by-one definition of N. If you expand it all out, it looks like Stilson \& Smith's paper, except you have N here where S\&S had N+1, and you have N-1 where S\&S had N.

   I think the code is equivalent. You just have to understand how to choose N to avoid aliasing.

   I don't have it working yet, but that's how it looks to me as I prepare a DSF oscillator. More later.

6. **mysterious T** · *2008-11-02 11:47:07*

   Got it working nicely, but it took a few minutes to pluck it apart. Had to correct it for my pitch scheme, too. But it's quite amazing! Funny concept, though, it's like a generator with a built in filter. It holds up into very high pitches, too, in terms of aliasing, as far as I can tell... ehm...and without any further oversampling (so far).

   Really, really nice! I was looking for a way to give my sinus an edge! ;)

</details>
