# Cascaded resonant lp/hp filter

[MusicDSP](../README.md) / [Filters](README.md) · [5 comments](#comments)

- **Author or source:** ed.bew@raebybot
- **Type:** lp+hp
- **Created:** 2002-12-16 19:02:11

## Notes

```text
// Cascaded resonant lowpass/hipass combi-filter
// The original source for this filter is from Paul Kellet from
// the archive. This is a cascaded version in Delphi where the
// output of the lowpass is fed into the highpass filter.
// Cutoff frequencies are in the range of 0<=x<1 which maps to
// 0..nyquist frequency

// input variables are:
// cut_lp: cutoff frequency of the lowpass (0..1)
// cut_hp: cutoff frequency of the hipass (0..1)
// res_lp: resonance of the lowpass (0..1)
// res_hp: resonance of the hipass (0..1)
```

## Code

```cpp
var n1,n2,n3,n4:single; // filter delay, init these with 0!
    fb_lp,fb_hp:single; // storage for calculated feedback
const p4=1.0e-24; // Pentium 4 denormal problem elimination

function dofilter(inp,cut_lp,res_lp,cut_hp,res_hp:single):single;
begin
 fb_lp:=res_lp+res_lp/(1-cut_lp);
 fb_hp:=res_hp+res_hp/(1-cut_lp);
 n1:=n1+cut_lp*(inp-n1+fb_lp*(n1-n2))+p4;
 n2:=n2+cut_lp*(n1-n2);
 n3:=n3+cut_hp*(n2-n3+fb_hp*(n3-n4))+p4;
 n4:=n4+cut_hp*(n3-n4);
 result:=i-n4;
end;
```

## Comments

<details>
<summary>Show 5 replies</summary>

1. **moc.biesnnamreh@eciffo** · *2003-07-13 07:43:17*

   ```text
   I guess the last line should read
     result:=inp-n4;
   ```

   Right?

   Bye,

   ```text
     Hermann
   ```

2. **moc.liamtoh@tsvreiruoc** · *2003-12-26 19:56:21*

   excuse me which type is? 6db/oct or 12 or what?

   thanks

3. **ed.xmg@suahtlanaitsirhc** · *2004-02-02 15:43:00*

   result := n2-n4

   :)

4. **ten.raenila@ssov** · *2011-01-25 17:52:08*

   WOW this is old but handy. Anyway what to do about the divide-by-zero caused by the feedback calc if the cutoff is set to 1.0?

   Also, should the feedback for the hpf be:

   ```text
   fb_hp:=res_hp+res_hp/(1-cut_hp);
   ```

   not:

   ```text
   fb_hp:=res_hp+res_hp/(1-cut_lp);
   ```

   ?

   Thanks
   NV

5. **moc.liamg@dnuosG** · *2017-03-17 08:28:07*

   Nobody can see ?

   There is two lowpass filters in series, no differences between them.

</details>
