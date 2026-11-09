# Denormal DOUBLE variables, macro

[MusicDSP](../README.md) / [Other](README.md) · [1 comment](#comments)

- **Author or source:** Jon Watte
- **Created:** 2002-03-17 15:44:31

## Notes

Use this macro if you want to find denormal numbers and you're using doubles...

## Code

```cpp
#if PLATFORM_IS_BIG_ENDIAN
#define INDEX 0
#else
#define INDEX 1
#endif
inline bool is_denormal( double const & d ) {
  assert( sizeof( d ) == 2*sizeof( int ) );
  int l = ((int *)&d)[INDEX];
  return (l&0x7fe00000) != 0;
}
```

## Comments

<details>
<summary>Read 1 archived comment</summary>

1. **dont-email-me** · *2005-05-14 17:19:48*

   put the #if inside the function itself

</details>
