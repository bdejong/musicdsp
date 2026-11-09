# One pole LP and HP

[MusicDSP](../README.md) / [Filters](README.md) · [4 comments](#comments)

- **Author or source:** Bram
- **Created:** 2002-08-26 23:33:27

## Code

```cpp
LP:
recursion: tmp = (1-p)*in + p*tmp with output = tmp
coefficient: p = (2-cos(x)) - sqrt((2-cos(x))^2 - 1) with x = 2*pi*cutoff/samplerate
coeficient approximation: p = (1 - 2*cutoff/samplerate)^2

HP:
recursion: tmp = (p-1)*in - p*tmp with output = tmp
coefficient: p = (2+cos(x)) - sqrt((2+cos(x))^2 - 1) with x = 2*pi*cutoff/samplerate
coeficient approximation: p = (2*cutoff/samplerate)^2
```

## Comments

<details>
<summary>Read 4 archived comments</summary>

1. **moc.liamtoh@wta\_sohpyks** · *2006-03-23 15:39:07*

   coefficient: p = (2-cos(x)) - sqrt((2-cos(x))^2 - 1) with x = 2\*pi\*cutoff/samplerate

   p is always -1 using the formula above. The square eliminates the squareroot and (2-cos(x)) - (2-cos(x)) is 0.

2. **q@q** · *2006-03-24 09:37:19*

   Look again. The -1 is inside the sqrt.

3. **batlord\[.A.T.\]o2\[.D.O.T.\]pl** · *2008-08-11 09:34:07*

   skyphos:
   sqrt((2-cos(x))^2 - 1) doesn't equal
   sqrt((2-cos(x))^2) + sqrt(- 1)

   so

   -1 can be inside the sqrt, because (2-cos(x))^2 will be always \>= one.

4. **No** · *2009-07-13 01:22:43*

   HP is wrong!
   Or at least it does not work here. It acts like a lofi low-shelf. However this works:

   HP:
   recursion: tmp = (1-p)\*in + p\*tmp with output = in-tmp
   coefficient: p = (2-cos(x)) - sqrt((2-cos(x))^2 - 1) with x = 2\*pi\*cutoff/samplerate
   coeficient approximation: p = (1 - 2\*cutoff/samplerate)^2

</details>
