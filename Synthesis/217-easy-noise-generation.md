# Easy noise generation

[MusicDSP](../README.md) / [Synthesis](README.md)

- **Author or source:** moc.psd-nashi@liam
- **Type:** White Noise
- **Created:** 2006-02-23 22:40:20

## Notes

```text
Easy noise generation,
in .hpp,
b_noise = 19.1919191919191919191919191919191919191919;
```

alternatively, the number 19 below can be replaced with a number of your choice, to get
that particular flavour of noise.

Regards,
Ove Karlsen.

## Code

```cpp
	b_noise = b_noise * b_noise;
	int i_noise = b_noise;
	b_noise = b_noise - i_noise;

	double b_noiseout;
	b_noiseout = b_noise - 0.5;

 	b_noise = b_noise + 19;
```

## Comments

**moc.liamg@saoxyz** · 2006-07-16 18:24:22

This is quite a good PRNG! The numbers it generates exhibit a slight a pattern (obviously, since it's not very sophisticated) but they seem quite usable! The real FFT spectrum is very flat and "white" with just one or two aberrant spikes while the imaginary spectrum is almost perfect (as is the case with most PRNGs). Very nice! Either that or I need more practice with MuPad...

**moc.liamtoh@neslrakevofira** · 2007-01-16 12:16:24

Alternatively you can do:

```text
 		double b_noiselast = b_noise;
		b_noise = b_noise + 19;
		b_noise = b_noise * b_noise;
		b_noise = b_noise + ((-b_noise + b_noiselast) * 0.5);
		int i_noise = b_noise;
		b_noise = b_noise - i_noise;
```

This will remove the patterning.

**moc.erehwon@ydobon** · 2007-01-16 16:56:19

```text
>>b_noise = b_noise + ((-b_noise + b_noiselast) * 0.5);
```

That seems to reduce to just:

```text
b_noise=(b_noise+b_noiselast) * 0.5;
```

**mymail@com** · 2007-01-18 22:04:19

Hi, is this integer? Please do not disturb the forum, rather send me an email.

B.i.T

**moc.liamtoh@neslrakevofira** · 2007-02-01 16:21:12

The line is written like that, so you can change 0.5, to for instance 0.19.

**moc.erehwon@ydobon** · 2007-02-01 16:52:21

\>\>The line is written like that, so you can change 0.5, to for instance 0.19.

OK. Why would I do that? What's that number control?

**moc.liamtoh@neslrakevofira** · 2007-02-03 15:51:46

It controls the patterning. I usually write my algorithms tweakable.

You could try even lower aswell, maybe 1e-19.
