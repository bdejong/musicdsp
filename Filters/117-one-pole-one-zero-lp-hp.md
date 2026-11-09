# One pole, one zero LP/HP

[MusicDSP](../README.md) / [Filters](README.md) · [6 comments](#comments)

- **Author or source:** ti.dniwni@tretsim
- **Created:** 2002-08-26 23:34:48

## Code

```cpp
void SetLPF(float fCut, float fSampling)
{
    float w = 2.0 * fSampling;
    float Norm;

    fCut *= 2.0F * PI;
    Norm = 1.0 / (fCut + w);
    b1 = (w - fCut) * Norm;
    a0 = a1 = fCut * Norm;
}

void SetHPF(float fCut, float fSampling)
{
    float w = 2.0 * fSampling;
    float Norm;

    fCut *= 2.0F * PI;
    Norm = 1.0 / (fCut + w);
    a0 = w * Norm;
    a1 = -a0;
    b1 = (w - fCut) * Norm;
}

Where
out[n] = in[n]*a0 + in[n-1]*a1 + out[n-1]*b1;
```

## Comments

<details>
<summary>Read 6 archived comments</summary>

1. **ten.tramepyh@renietsretep** · *2006-01-15 01:12:26*

   what is n? lol...sorry but i mean this seriously! ;)

2. **ku.oc.snosrapsd@psdcisum** · *2006-01-16 14:17:35*

   n is the index of sample being considered.

   ```text
   out[] is an array of samples being output, and in[] is the input array. you would construct a loop such that:
   [Pseudocode]
   loop n{0..numsamples-1}
     out[n] = in[n]*a0 + in[n-1]*a1 + out[n-1]*b1;
   end loop;
   [/Pseudocode]
   ```

   You will need some cleverness so that \[n-1\] doesn't cause an index error when n=0, but I'll leave that to you :)

3. **ten.tramepyh@renietsretep** · *2006-01-18 09:28:30*

   whoops - sorry, of course n = number... stupid me ;)
   interesting code, i will see if can adapt that to delphi, shouldn´t be a big deal :)

   i assume i dont need to place either setHPF or LPF into the samples loop, just the block itself?

4. **ku.oc.snosrapsd@psdcisum** · *2006-01-23 10:57:26*

   absolutey - set the coefficients outside of the loop. There is the case of changes being made whilst the loop is running, depends what platform/host you are writing for.

   I'm a delphi code as well. Feel free to use my posted address if you need to :) DSP

5. **moc.oohay@keelanej** · *2006-07-21 09:07:12*

   Shouldn't that be float w = 2\*PI\*fSampling; ???

   In which case we can simplify:

   ```text
   void SetLPF(float fCut, float fSampling)
   {
   a0 = fCut/(fSampling+fCut);
   a1 = a0;
   b1 = (fSampling-fCut)/(fSampling+fCut);
   }

   void SetHPF(float fCut, float fSampling)
   {
   a0 = fSampling/(fSampling+fCut);
   a1 = -a0;
   b1 = (fSampling-fCut)/(fSampling+fCut);
   }
   ```

   You can keep the norm = 1/(fSampling+fCut) if you like.

6. **JoergBitzer** · *2020-05-23*

   ```text
   The equation of the original contributor is correct. It is a first order Butterworth-Filter
   H(s') = 1/(1+s') and then denormalized s' = s/wcut and transformed by the bilinear transform
   s = 2f_s (z-1)/(z+1). Only the tan-prewarp is missing for fcut/wcut.
   ```

</details>
