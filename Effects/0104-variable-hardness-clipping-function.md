# Variable-hardness clipping function

[MusicDSP](../README.md) / [Effects](README.md) · [9 comments](#comments)

- **Author or source:** Laurent de Soras (moc.ecrofmho@tnerual)
- **Created:** 2004-04-07 09:36:46
- **Linked files:** [laurent.gif](../files/laurent.gif).

## Notes

k \>= 1 is the "clipping hardness". 1 gives a smooth clipping, and a high value gives
hardclipping.

Don't set k too high, because the formula use the pow() function, which use exp() and
would overflow easily. 100 seems to be a reasonable value for "hardclipping"

## Code

```text
f (x) = sign (x) * pow (atan (pow (abs (x), k)), (1 / k));
```

## Comments

<details>
<summary>Show 9 replies</summary>

1. **moc.liamtoh@sisehtnysorpitna** · *2003-11-15 03:56:35*

   ```cpp
   // Use this function instead of atan and see performance increase drastically :)

   inline double fastatan( double x )
   {
   	return (x / (1.0 + 0.28 * (x * x)));
   }
   ```

2. **gro.psdcisum@maps** · *2004-07-16 09:36:33*

   The greater k becomes the lesser is the change in the form of f(x, k). I recommend using
   f2(x, k2) = sign(x) \* pow(atan(pow(abs(x), 1 / k2)), k2) ,  k2 in \[0.01, 1\]
   where k2 is the "clipping softness" (k2 = 0.01 means "hardclipping", k2 = 1 means
   "softclipping"). This gives better control over the clipping effect.

3. **gro.liamon@demrofniton** · *2004-08-12 18:42:58*

   Don't know if i understood ok , but, how can i clip at diferent levels than -1.0/1.0 using this
   func? tried several ways but none seems to work

4. **moc.liamg@noteex** · *2004-08-14 04:02:00*

   The most straightforward way to adjust the level (x) at which the signal is clipped would be to
   multiply the signal by 1/x before the clipping function then multiply it again by x afterwards.

5. **ed.xmg@releuhcsc** · *2004-10-09 23:27:57*

   Atan is a nice softclipping function, but you can do without pow().

   x: input value
   a: clipping factor (0 = none, infinity = hard)
   ainv: 1/a

   ```cpp
   y = ainv * atan( x * a );
   ```

6. **uh.etle.fni@yfoocs** · *2006-05-28 20:32:49*

   Even better, you can normalize the output using:

   ```text
   shape = 1..infinity

   precalc:
     inv_atan_shape=1.0/atan(shape);
   process:
     output = inv_atan_shape * atan(input*shape);
   ```

   This gives a very soft transition from no distortion to hard clipping.

7. **moc.liamg@nalevart** · *2011-01-03 14:07:35*

   Scoofy,

   What do you mean with 'shape'?
   Is it a new parameter?

8. **moc.liamtoh@niffumtohrepus** · *2013-01-18 02:42:09*

   ```cpp
   sign (x) * pow (atan (pow (abs (x), k)), (1 / k));
   ```

   OUCH! That's a lot of pow, atan and floating point division - probably kill most CPU's :) My
   experience has been that any sigmoid function will create decent distortion if oversampled and
   eq'ed properly. You can adjust the "hardness" of the clipping by simply changing a couple
   coefficients, or by increasing/decreasing the input gain: like so:

   ```text
   y = A * tanh(B * x)
   ```

   Cascading a couple/few of these will give you bone-crushing, Megadeth/Slayer style grind while
   rolling back the gain gives a Fender Twin sound.

   Two cascaded half-wave soft clippers gives duty-cycle modulation and a transfer curve similar to
   the 3/2 power curve of tubes. I came up w/ a model based on that solution after reading reading
   this: <http://www.trueaudio.com/at_eetjlm.htm> (orig. link at www.simulanalog.org)

9. **moc.liamtoh@niffumtohrepus** · *2013-06-14 11:42:26*

   If anyone is interested, I have a working amp modeler and various c/c++ classes that model
   distortion circuits by numerical solutions to non-linear ODE's like those described by
   Yeh, Smith, Macak, Pakarinen, et al. in their PhD disertations and DAFX papers. Although
   static waveshapers/filters can give decent approximations \& cool sounds, they lack the dynamic
   properties of the actual circuits and have poor harmonics. I also have whitepapers on my
   implementations for those that think math is cool. Drop me a line for more info.

</details>
