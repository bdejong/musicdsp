# Bit quantization/reduction effect

[MusicDSP](../README.md) / [Effects](README.md) · [1 comment](#comments)

- **Author or source:** Jon Watte
- **Type:** Bit-level noise-generating effect
- **Created:** 2002-04-12 13:53:03

## Notes

This function, run on each sample, will emulate half the effect of running your signal
through a Speak-N-Spell or similar low-bit-depth circuitry.

The other half would come from downsampling with no aliasing control, i e replicating
every N-th sample N times in the output signal.

## Code

```cpp
short keep_bits_from_16( short input, int keepBits ) {
  return (input & (-1 << (16-keepBits)));
}
```

## Comments

<details>
<summary>Read 1 archived comment</summary>

1. **moc.liamg@codlli** · *2005-05-30 23:01:56*

   ```cpp
   //I add some code to prevent offset.

   // Code :
   short keep_bits_from_16( short input, int keepBits ) {
       short prevent_offset = static_cast<unsigned short>(-1) >> keepBits+1;
       input &= (-1 << (16-keepBits)));
       return input + prevent_offset
   }
   ```

</details>
