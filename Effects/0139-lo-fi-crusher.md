# Lo-Fi Crusher

[MusicDSP](../README.md) / [Effects](README.md) · [3 comments](#comments)

- **Author or source:** David Lowenfels
- **Type:** Quantizer / Decimator with smooth control
- **Created:** 2003-04-01 15:34:40

## Notes

Yet another bitcrusher algorithm. But this one has smooth parameter control.

```text
Normfreq goes from 0 to 1.0; (freq/samplerate)
Input is assumed to be between 0 and 1.
Output gain is greater than unity when bits < 1.0;
```

## Code

```matlab
function output = crusher( input, normfreq, bits );
    step = 1/2^(bits);
    phasor = 0;
    last = 0;

    for i = 1:length(input)
       phasor = phasor + normfreq;
       if (phasor >= 1.0)
          phasor = phasor - 1.0;
          last = step * floor( input(i)/step + 0.5 ); %quantize
       end
       output(i) = last; %sample and hold
    end
end
```

## Comments

<details>
<summary>Show 3 replies</summary>

1. **moc.liamtoh@132197kk** · *2004-06-16 21:10:39*

   what's the "bits" here? I tried to run the code, it seems it's a dead loop here, can not
   figure out why

2. **dfl** · *2005-10-26 23:25:13*

   bits goes from 1 to 16

3. **moc.liamg@tnemniatretnEesneS2** · *2016-03-19 02:47:47*

   I'm having trouble with the code as well. Is there something I'm missing?

</details>
