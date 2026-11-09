# Gaussian White Noise

[MusicDSP](../README.md) / [Synthesis](README.md) · [1 comment](#comments)

- **Author or source:** uh.atsopten@egamer
- **Created:** 2002-08-07 16:23:28

## Notes

SOURCE:

Steven W. Smith:
The Scientist and Engineer's Guide to Digital Signal Processing
<http://www.dspguide.com>

## Code

```c
#define PI 3.1415926536f

float R1 = (float) rand() / (float) RAND_MAX;
float R2 = (float) rand() / (float) RAND_MAX;

float X = (float) sqrt( -2.0f * log( R1 )) * cos( 2.0f * PI * R2 );
```

## Comments

<details>
<summary>Show 1 reply</summary>

1. **gro.sdikgninnips@nap** · *2002-08-28 02:05:50*

   The previous one seems better for me, since it requires only a rand, half log and half sqrt per sample.
   Actually, I used that one, but I can't remember where I found it, too. Maybe on Knuth's book.

</details>
