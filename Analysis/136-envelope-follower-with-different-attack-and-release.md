# Envelope follower with different attack and release

[MusicDSP](../README.md) / [Analysis](README.md) · [2 comments](#comments)

- **Author or source:** Bram
- **Created:** 2003-01-15 00:21:39

## Notes

xxxx\_in\_ms is xxxx in milliseconds ;-)

## Code

```cpp
init::

attack_coef = exp(log(0.01)/( attack_in_ms * samplerate * 0.001));
release_coef = exp(log(0.01)/( release_in_ms * samplerate * 0.001));
envelope = 0.0;

loop::

tmp = fabs(in);
if(tmp > envelope)
    envelope = attack_coef * (envelope - tmp) + tmp;
else
    envelope = release_coef * (envelope - tmp) + tmp;
```

## Comments

<details>
<summary>Read 2 archived comments</summary>

1. **kd.utd.xaspmak@mj** · *2003-01-18 20:56:46*

   ```cpp
   // the expressions of the form:

   xxxx_coef = exp(log(0.01)/( xxxx_in_ms * samplerate * 0.001));

   // can be simplified a little bit to:

   xxxx_coef = pow(0.01, 1.0/( xxxx_in_ms * samplerate * 0.001));
   ```

2. **uh.etle.fni@yfoocs** · *2007-07-01 19:05:26*

   Here the definition of the attack/release time is the time for the envelope to fall from 100% to 1%.
   In the other version, the definition is for the envelope to fall from 100% to 36.7%. So in this one
   the envelope is about 4.6 times faster.

</details>
