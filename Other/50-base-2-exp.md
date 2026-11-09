# Base-2 exp

[MusicDSP](../README.md) / [Other](README.md) · [1 comment](#comments)

- **Author or source:** Laurent de Soras
- **Created:** 2002-01-17 03:06:08

## Notes

Linear approx. between 2 integer values of val. Uses 32-bit integers. Not very efficient
but fastest than exp()
This code was designed for x86 (little endian), but could be adapted for big endian
processors.
Laurent thinks you just have to change the (\*(1 + (int \*) \&ret)) expressions and replace
it by (\*(int \*) \&ret). However, He didn't test it.

## Code

```cpp
inline double fast_exp2 (const double val)
{
   int    e;
   double ret;

   if (val >= 0)
   {
      e = int (val);
      ret = val - (e - 1);
      ((*(1 + (int *) &ret)) &= ~(2047 << 20)) += (e + 1023) << 20;
   }
   else
   {
      e = int (val + 1023);
      ret = val - (e - 1024);
      ((*(1 + (int *) &ret)) &= ~(2047 << 20)) += e << 20;
   }
   return (ret);
}
```

## Comments

<details>
<summary>Read 1 archived comment</summary>

1. **gro.ecruosrv@cimotabus** · *2002-04-10 02:48:33*

   Here is the code to detect little endian processor:

   ```text
            union
            {
               short   val;
               char    ch[sizeof( short )];
            } un;
            un.val = 256; // 0x10;

            if (un.ch[1] == 1)
            {
               // then we're little
            }
   ```

   I've tested the fast\_exp2() on both little and big endian (intel, AMD, and motorola) processors, and the comment is correct.

   Here is the completed function that works on all endian systems:

   ```text
   inline double fast_exp2( const double val )
   {
      // is the machine little endian?
      union
      {
         short   val;
         char    ch[sizeof( short )];
      } un;
      un.val = 256; // 0x10;
      // if un.ch[1] == 1 then we're little

      // return 2 to the power of val (exp base2)
      int    e;
      double ret;

      if (val >= 0)
      {
         e = int (val);
         ret = val - (e - 1);

         if (un.ch[1] == 1)
            ((*(1 + (int *) &ret)) &= ~(2047 << 20)) += (e + 1023) << 20;
         else
            ((*((int *) &ret)) &= ~(2047 << 20)) += (e + 1023) << 20;
      }
      else
      {
         e = int (val + 1023);
         ret = val - (e - 1024);

         if (un.ch[1] == 1)
            ((*(1 + (int *) &ret)) &= ~(2047 << 20)) += e << 20;
         else
            ((*((int *) &ret)) &= ~(2047 << 20)) += e << 20;
      }

      return ret;
   }
   ```

</details>
