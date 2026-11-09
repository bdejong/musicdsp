# Waveshaper :: Gloubi-boulga

[MusicDSP](../README.md) / [Effects](README.md) · [10 comments](#comments)

- **Author or source:** Laurent de Soras on IRC
- **Created:** 2002-03-17 15:40:13

## Notes

Multiply input by gain before processing

## Code

```c
const double x = input * 0.686306;
const double a = 1 + exp (sqrt (fabs (x)) * -0.75);
output = (exp (x) - exp (-x * a)) / (exp (x) + exp (-x));
```

## Comments

<details>
<summary>Show 10 replies</summary>

1. **ten.etelirt@gnihtliam** · *2004-09-25 21:42:39*

   you can use a taylor series approximation for the exp , save time by realizing that
   exp(-x) = 1/exp(x), use newton's method to calculate the sqrt with less precision...
   and if you use SIMD instructions, you can calculate several values in parallel. dunno
   what the savings would be like, but it would surely be faster.

2. **ed.luosfosruoivas@naitsirhC** · *2005-05-25 22:32:21*

   ```delphi
   // Maybe something like this:

   function GloubiBoulga(x:Single):Single;
   var a,b:Single;
   begin
    x:=x*0.686306;
    a:=1+exp(sqrt(f_abs(x))*-0.75);
    b:=exp(x);
    Result:=(b-exp(-x*a))*b/(b*b+1);
   end;

   still expensive, but...
   ```

3. **ed.luosfosruoivas@naitsirhC** · *2005-05-28 00:49:48*

   A Taylor series doesn't work very well, because the approximation effects the result very early due to
   a) numerical critical additions \& subtractions of approximations
   b) approximating approximated "a" makes the result evene more worse.

   The above version has already been improved, by removing 2 of 5 exp() functions.

   You can also try to express the exp(x)+exp(-x) as cosh(x) with its approximation. So:

   ```delphi
   b:=exp(x);
   Result:=(b-exp(-x*a))*b/(b*b+1);
   ```

   would be:

   ```delphi
   Result:=(exp(x)-exp(-x*a))*20160/40320+x*x*(20160+ x*x*(1680+x*x*(56+x*x)));
   ```

   but this is again more worse. Anyone else?

4. **llun.ved@regguHwodahS** · *2005-09-13 09:55:55*

   Use table lookup with interpolation.

5. **ten.baltg@liced** · *2005-09-22 01:07:58*

   IMHO, you can use
   x - 0.15 \* x^2 - 0.15 \* x^3
   instead of this scary formula.

   I try to explain my position with this small graph:
   <http://liteprint.com/download/replacment.png>

   This is only first step, if you want to get more correct result you can use interpolation
   method called method of minimal squares (this is translation from russian, maybe in england
   it has another name)

6. **ku.oc.snosrapsd@psdcisum** · *2005-09-22 07:19:07*

   That's much better decil - thx for that!

   DSP

7. **ten.baltg@liced** · *2005-09-22 11:05:07*

   You are welcome :)

   Now I've working under plugin with wapeshapping processing like this. I've put a link to it
   here, when I've done it.

8. **ten.baltg@liced** · *2005-09-24 01:15:38*

   You can check my version:
   <http://liteprint.com/download/SweetyVST.zip>

   Please, send comments and suggestions to my email.

   Dmitry.

9. **moc.liamtoh@12\_namyaj** · *2005-10-27 09:57:44*

   Which formula exactly did you use decil, for your plugin? How do you get different harmonics
   from this algo. thanx

   jay

10. **ten.etelirt@liam** · *2005-11-15 09:09:48*

    wow, blast from the past seeing this turn up on kvraudio.

    christian - i'd have thought that an advantage of using a taylor series approximation would be
    that it limits the order of the polynomial (and the resulting bandwidth) somewhat.  it's been ages
    since i tested, but i thought i got some reasonable sounding results using the taylor series
    approximation.  maybe not.

    decil - isn't that a completely unrelated polynomial (similar to the common and cheap x - a x^3 ?).
    i'd think you'd have to do something about the dc from the x^2 term, too (or do a sign(x)\*x^2).
    anyway, your plugin sounds to be popular so i look forward to checking it out later at home.

</details>
