# Simple biquad filter from apple.com

[MusicDSP](../README.md) / [Filters](README.md) · [2 comments](#comments)

- **Author or source:** moc.liamg@321tiloen
- **Type:** LP
- **Created:** 2008-10-27 10:15:16

## Notes

Simple Biquad LP filter from the AU tutorial at apple.com

## Code

```cpp
//cutoff_slider range 20-20000hz
//res_slider range -25/25db
//srate - sample rate

//init
mX1 = 0;
mX2 = 0;
mY1 = 0;
mY2 = 0;
pi = 22/7;

//coefficients
cutoff = cutoff_slider;
res = res_slider;

cutoff = 2 * cutoff_slider / srate;
res = pow(10, 0.05 * -res_slider);
k = 0.5 * res * sin(pi * cutoff);
c1 = 0.5 * (1 - k) / (1 + k);
c2 = (0.5 + c1) * cos(pi * cutoff);
c3 = (0.5 + c1 - c2) * 0.25;

mA0 = 2 * c3;
mA1 = 2 * 2 * c3;
mA2 = 2 * c3;
mB1 = 2 * -c2;
mB2 = 2 * c1;

//loop
output = mA0*input + mA1*mX1 + mA2*mX2 - mB1*mY1 - mB2*mY2;

mX2 = mX1;
mX1 = input;
mY2 = mY1;
mY1 = output;
```

## Comments

<details>
<summary>Read 2 archived comments</summary>

1. **moc.liamg@321tiloen** · *2009-03-05 13:44:24*

   here are coefficients for the hp version.
   the br,bp \& peak are also easy to calculate:

   ```text
   k = 0.5*res*sin(pi*cutoff);
   c1 = 0.5*(1-k)/(1+k);
   c2 = (0.5+c1)*cos(pi*cutoff);
   c3 = (0.5+c1+c2)*0.25;

   a0 = 2*c3;
   a1 = -4*c3;
   a2 = 2*c3;
   b1 = -2*c2;
   b2 = 2*c1;
   ```

   if you wish to create a cascade, use the this:

   ```text
   //----sample loop

   //mem: buffer array
   //N: number of biquads, n=4 -> 48dB/oct

   //set input here

   for (i=0;i<N;i++) {
   output = a0 * input + a1 * mem[4*i+1] + a2 * mem[4*i+2] - b1 * mem[4*i+3] - b2 * mem[4*i+4];
   mem[4*i+2] = mem[4*i+1];
   mem[4*i+1] = input;
   mem[4*i+4] = mem[4*i+3];
   mem[4*i+3] = output;
   );

   //----sample loop
   ```

2. **moc.liamg@321tiloen** · *2009-04-20 11:44:26*

   i've missed a line:

   ```text
   ===========================
   mem[4*i+3] = output;

   //>>> insert here
   input = output;
   //>>> insert here

   );
   //----sample loop
   ===========================
   ```

   lubomir

</details>
