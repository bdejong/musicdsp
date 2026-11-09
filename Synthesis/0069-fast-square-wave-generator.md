# Fast square wave generator

[MusicDSP](../README.md) / [Synthesis](README.md) · [2 comments](#comments)

- **Author or source:** Wolfgang (ed.tfoxen@redienhcsw)
- **Type:** NON-bandlimited osc...
- **Created:** 2002-02-10 12:46:22

## Notes

Produces a square wave -1.0f .. +1.0f.
The resulting waveform is NOT band-limited, so it's propably of not much use for syntheis.
It's rather useful for LFOs and the like, though.

## Code

```cpp
Idea: use integer overflow to avoid conditional jumps.

// init:
typedef unsigned long ui32;

float sampleRate = 44100.0f; // whatever
float freq = 440.0f; // 440 Hz
float one = 1.0f;
ui32 intOver = 0L;
ui32 intIncr = (ui32)(4294967296.0 / hostSampleRate / freq));

// loop:
(*((ui32 *)&one)) &= 0x7FFFFFFF; // mask out sign bit
(*((ui32 *)&one)) |= (intOver & 0x80000000);
intOver += intIncr;
```

## Comments

<details>
<summary>Show 2 replies</summary>

1. **moc.jecnal@psdcisum** · *2003-08-03 01:35:08*

   So, how would I get the output into a float variable like square\_out, for instance?

2. **moc.liamtoh@18\_ogag\_leafar** · *2009-04-12 15:33:37*

   In response to lancej, yo can declare a union with a float and a int and operate the floatas as here using the int part of the union.

   If I remeber correctly the value for -1.f = 0xBF800000 and the value for 1.f = 0x3F800000, note the 0x80000000 difference between them that is the sign.

</details>
