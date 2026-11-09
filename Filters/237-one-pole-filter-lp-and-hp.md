# One pole filter, LP and HP

[MusicDSP](../README.md) / [Filters](README.md)

- **Author or source:** uh.etle.fni@yfoocs
- **Type:** Simple 1 pole LP and HP filter
- **Created:** 2006-10-08 14:53:38

## Notes

Slope: 6dB/Oct

Reference: www.dspguide.com

## Code

```cpp
Process loop (lowpass):
out = a0*in - b1*tmp;
tmp = out;

Simple HP version: subtract lowpass output from the input (has strange behaviour towards nyquist):
out = a0*in - b1*tmp;
tmp = out;
hp = in-out;

Coefficient calculation:
x = exp(-2.0*pi*freq/samplerate);
a0 = 1.0-x;
b1 = -x;
```

## Comments

**moc.liamtoh@ojer\_jd** · 2007-01-05 11:43:21

Why don't you just say:

```text
Process loop (lowpass):
out = a0*in + b1*tmp;
tmp = out;

Simple HP version: subtract lowpass output from the input (has strange behaviour towards nyquist):
out = a0*in + b1*tmp;
tmp = out;
hp = in-out;

Coefficient calculation:
x = exp(-2.0*pi*freq/samplerate);
a0 = 1.0-x;
b1 = x;
```

**uh.etle.fni@yfoocs** · 2007-01-06 04:12:56

There's a tradition among digital filter designers that the pole coefficients have a negative sign. Of course the other one is also valid, and sometimes these notations are mixed up.

If you're worried about the extra negation operation, then you could say

```text
b1 = -x;
a0 = 1.0+b1;
```

so that there's no additional operation overhead.

-- peter schoffhauzer

**moc.erehwon@ydobon** · 2007-01-06 16:26:27

Of course, you don't need tmp.

```text
Process loop (lowpass):
out = a0*in + b1*out;
```

**uh.etle.fni@yfoocs** · 2007-02-16 19:27:48

Indeed.

**moc.boohay@bob** · 2009-06-18 17:29:20

```text
Or...
out += a0 * (in - out);
```

:)
