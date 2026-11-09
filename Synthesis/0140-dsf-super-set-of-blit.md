# DSF (super-set of BLIT)

[MusicDSP](../README.md) / [Synthesis](README.md) · [1 comment](#comments)

- **Author or source:** David Lowenfels
- **Type:** matlab code
- **Created:** 2003-04-02 23:59:24

## Notes

Discrete Summation Formula ala Moorer

computes equivalent to sum{k=0:N-1}(a^k \* sin(beta + k\*theta))
modified from Emanuel Landeholm's C code
output should never clip past \[-1,1\]

```text
If using for BLIT synthesis for virtual analog:
N = maxN;
a = attn_at_Nyquist ^ (1/maxN); %hide top harmonic popping in and out when sweeping
frequency
beta = pi/2;
num = 1 - a^N * cos(N*theta) - a*( cos(theta) - a^N * cos(N*theta - theta) ); %don't waste
time on beta
```

You can also get growing harmonics if a \> 1, but the min statement in the code must be
removed, and the scaling will be weird.

## Code

```cpp
function output = dsf( freq, a, H, samples, beta)
%a = rolloff coeffecient
%H = number of harmonic overtones (fundamental not included)
%beta = harmonic phase shift

samplerate = 44.1e3;
freq = freq/samplerate; %normalize frequency

bandlimit = samplerate / 2; %Nyquist
maxN = 1 + floor( bandlimit / freq ); %prevent aliasing
N = min(H+2,maxN);

theta = 2*pi * phasor(freq, samples);

epsilon = 1e-6;
a = min(a, 1-epsilon); %prevent divide by zero

num = sin(beta) - a*sin(beta-theta) - a^N*sin(beta + N*theta) + a^(N+1)*sin(beta+(N-1)*theta);
den = (1 + a * ( a - 2*cos(theta) ));

output = 2*(num ./ den - 1) * freq; %subtract by one to remove DC, scale by freq to normalize
output = output * maxN/N;           %OPTIONAL: rescale to give louder output as rolloff increases

function out = phasor(normfreq, samples);
out = mod( (0:samples-1)*normfreq , 1);
out = out * 2 - 1;                  %make bipolar
```

## Comments

<details>
<summary>Show 1 reply</summary>

1. **David Lowenfels** · *2003-04-03 15:05:42*

   oops, there's an error in this version. frequency should not be normalized until after the maxN calculation is done.

</details>
