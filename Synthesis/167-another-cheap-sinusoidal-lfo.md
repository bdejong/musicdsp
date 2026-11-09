# Another cheap sinusoidal LFO

[MusicDSP](../README.md) / [Synthesis](README.md) · [5 comments](#comments)

- **Author or source:** moc.cinohp-e@ofni
- **Created:** 2004-05-14 18:32:57

## Notes

Some pseudo code for a easy to calculate LFO.

You can even make a rough triangle wave out of this by substracting the output of 2 of
these with different phases.

PJ

## Code

```cpp
r = the rate 0..1

--------------
p += r
if(p > 1) p -= 2;
out = p*(1-abs(p));
--------------
```

## Comments

<details>
<summary>Read 5 archived comments</summary>

1. **moc.regnimmu@psd-cisum** · *2004-06-10 21:32:22*

   Slick! I like it!

   Sincerely,
   Frederick Umminger

2. **es.tensse@idarozs.szalab** · *2005-02-23 22:24:03*

   Great! just what I wanted a fast trinagle lfo. :D

   ```text
   float rate = 0..1;
   float phase1 = 0;
   float phase2 = 0.1f;

   ---------------
   phase1 += rate;
   if (phase1>1) phase1 -= 2;

   phase2 += rate;
   if (phase2>1) phase2 -= 2;

   out = (phase1*(1-abs(phase1)) - phase2*(1-abs(phase2))) * 10;
   ---------------
   ```

3. **uh.etle.fni@yfoocs** · *2006-08-02 22:10:54*

   Nice! If you want the output range to be between -1..1 then use:

   ```text
   --------------
   p += r
   if(p > 2) p -= 4;
   out = p*(2-abs(p));
   --------------
   ```

4. **uh.etle.fni@yfoocs** · *2006-08-03 10:25:10*

   A better way of making a triangle LFO (out range is -1..1):

   ```text
   rate = 0..1;
   p = -1;
   {
       p += rate;
       if (p>1) p -= 4.0f;
       out = abs(-(abs(p)-2))-1;
   }
   ```

5. **ten.akionelet@isangi** · *2013-11-10 16:51:38*

   ```text
   /* this goes from -1 to +1 */
   #include <iostream>
   #include <math.h>

   using namespace std;
   int main(int argc, char *argv[]) {

   	//r = the rate 0..1
   	float r = 0.5f;
   	float p = 0.f;
   	float result=0.f;
   	//--------------
   	for(int i=1;i<=2048;i++){
   	p += r;
   	if(p > 1) p -= 2;
   	result = 4*p*(1-fabs(p));
   	cout << result;
   	cout <<"\r";
   	}
   	}
   ```

</details>
