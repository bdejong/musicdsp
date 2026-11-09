# Cheap pseudo-sinusoidal lfo

[MusicDSP](../README.md) / [Other](README.md) · [2 comments](#comments)

- **Author or source:** moc.regnimmu@regnimmuf
- **Created:** 2004-04-07 09:39:28

## Notes

Although the code is written in standard C++, this algorithm is really better suited for
dsps where one can take advantage of multiply-accumulate instructions and where the
required phase accumulator can be easily implemented by masking a counter.

It provides a pretty cheap roughly sinusoidal waveform that is good enough for an lfo.

## Code

```cpp
// x should be between -1.0 and 1.0
inline
double pseudo_sine(double x)
{
    // Compute 2*(x^2-1.0)^2-1.0
    x *= x;
    x -= 1.0;
    x *= x;
    // The following lines modify the range to lie between -1.0 and 1.0.
   // If a range of between 0.0 and 1.0 is acceptable or preferable
   // (as in a modulated delay line) then you can save some cycles.
    x *= 2.0;
    x -= 1.0;
}
```

## Comments

<details>
<summary>Show 2 replies</summary>

1. **ed.bew@hakkeb** · *2004-03-31 09:08:57*

   You forgot a

   ```text
   return x;
   ```

2. **moc.regnimmu@regnimmuf** · *2004-04-05 19:43:15*

   Doh! You're right.

   -Frederick

</details>
