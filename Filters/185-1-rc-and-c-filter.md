# 1-RC and C filter

[MusicDSP](../README.md) / [Filters](README.md)

- **Author or source:** ac.nortoediv@niarbdam
- **Type:** Simple 2-pole LP
- **Created:** 2004-11-14 22:42:18

## Notes

This filter is called 1-RC and C since it uses these two parameters. C and R correspond to
raw cutoff and inverted resonance, and have a range from 0 to 1.

## Code

```cpp
//Parameter calculation
//cutoff and resonance are from 0 to 127

  c = pow(0.5, (128-cutoff)   / 16.0);
  r = pow(0.5, (resonance+24) / 16.0);

//Loop:

  v0 =  (1-r*c)*v0  -  (c)*v1  + (c)*input;
  v1 =  (1-r*c)*v1  +  (c)*v0;

  output = v1;
```

## Comments

**yes** · 2005-01-13 18:25:57

input is not in 0 - 1 range.

for cutoff i guess 128.

for reso the same ?

**uh.etle.fni@yfoocs** · 2006-08-31 14:28:33

Nice. This is very similar to a state variable filter in many ways. Relationship between c and frequency:

```text
c = 2*sin(pi*freq/samplerate)
```

You can approximate this (tuning error towards nyquist):

```text
c = 2*pi*freq/samplerate
```

Relationship between r and q factor:

```text
r = 1/q
```

This filter has stability issues for high r values. State variable filter stability limits seem to work fine here. It can also be oversampled for better stability and wider frequency range (use 0.5\*original frequency):

```text
//Loop:

v0 = (1-r*c)*v0 - c*v1 + c*input;
v1 = (1-r*c)*v1 + c*v0;
tmp = v1;

v0 = (1-r*c)*v0 - c*v1 + c*input;
v1 = (1-r*c)*v1 + c*v0;
output = (tmp+v1)*0.5;
```

-- peter schoffhauzer
