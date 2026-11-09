# Fast log2

[MusicDSP](../README.md) / [Other](README.md)

- **Author or source:** Laurent de Soras
- **Created:** 2002-02-10 12:31:20

## Code

```cpp
inline float fast_log2 (float val)
{
   assert (val > 0);

   int * const  exp_ptr = reinterpret_cast <int *> (&val);
   int          x = *exp_ptr;
   const int    log_2 = ((x >> 23) & 255) - 128;
   x &= ~(255 << 23);
   x += 127 << 23;
   *exp_ptr = x;

   return (val + log_2);
}
```

## Comments

**ed.bew@raebybot** · 2002-12-18 20:13:06

And here is some native Delphi/Pascal code that
does the same thing:

```text
function fast_log2(val:single):single;
var log2,x:longint;
begin
 x:=longint((@val)^);
 log2:=((x shr 23) and 255)-128;
 x:=x and (not(255 shl 23));
 x:=x+127 shl 23;
 result:=single((@x)^)+log2;
end;
```

Cheers

Toby

www.tobybear.de

**ed.sulydroc@yrneh** · 2003-02-07 23:54:32

instead of using this pointer casting expressions one can also use a enum like this:

```text
enum FloatInt
{
float f;
```

**ed.sulydroc@yrneh** · 2003-02-07 23:55:27

instead of using this pointer casting expressions one can also use a enum like this:

```text
enum FloatInt
{
float f;
int l;
} p;
```

and then access the data with:

```text
p.f = x;
p.l >>= 23;
```

Greetings, Henry

**ed.sulydroc@yrneh** · 2003-02-07 23:56:11

Sorry :

didnt mean enum, ment UNION !!!

**Laurent de Soras** · 2005-10-18 10:03:47

More precision can be obtained by adding the following line just before the return() :

```text
val = map_lin_2_exp (val, 1.0f / 2);
```

Below is the function (everything is constant, so most operations should be done at compile time) :

```text
inline float map_lin_2_exp (float val, float k)
{
   const float a = (k - 1) / (k + 1);
   const float b = (4 - 2*k) / (k + 1);	// 1 - 3*a
   const float c = 2*a;
   val = (a * val + b) * val + c;

   return (val);
}
```

You can do the mapping you want for the range \[1;2\] -\> \[1;2\] to approximate the function log(x)/log(2).

**Laurent de Soras** · 2005-10-18 10:05:48

Sorry I meant log(x)/log(2) + 1
