# Fast Downsampling With Antialiasing

[MusicDSP](../README.md) / [Filters](README.md)

- **Author or source:** moc.liamg@tramum
- **Created:** 2005-12-22 20:34:58

## Notes

A quick and simple method of downsampling a signal by a factor of two with a useful amount
of antialiasing. Each source sample is convolved with { 0.25, 0.5, 0.25 } before
downsampling.

## Code

```cpp
int filter_state;

/* input_buf can be equal to output_buf */
void downsample( int *input_buf, int *output_buf, int output_count ) {
	int input_idx, input_end, output_idx, output_sam;
	input_idx = output_idx = 0;
	input_end = output_count * 2;
	while( input_idx < input_end ) {
		output_sam = filter_state + ( input_buf[ input_idx++ ] >> 1 );
		filter_state = input_buf[ input_idx++ ] >> 2;
		output_buf[ output_idx++ ] = output_sam + filter_state;
	}
}
```

## Comments

**ku.oc.mapson.snosrapsd@psd** · 2006-01-06 11:22:36

I see this is designed for integers; what are you thoughts on altering it to floats and doing simple division rather than bit shifts?

**moc.liamg@tramum** · 2006-01-07 01:35:56

It will work fine in floating point. I would probably use multiplication rather than division though, as I would expect that to be faster (ie. \>\> 1 --\> \*0.5, \>\>2 --\> \*0.25).

**ude.drofnats.amrcc@lfd** · 2006-03-12 01:55:30

this triangular window is still not the greatest antialiaser... but it's probably fine for something like an oversampled lowpass filter!

**moc.liamg@tramum** · 2006-03-17 23:36:31

```text
For my purposes(modelling a first-order-hold dac) it was fine. The counterpart to it I suppose is this one - a classic exponential decay, which gives a lovely warm sound. Each sample is convolved with { 0.5, 0.25, 0.125, ...etc }

int filter_state;

void downsample( int *input_buf, int *output_buf, int output_count ) {
	int input_idx, output_idx, input_ep1;
	output_idx = 0;
	input_idx = 0;
	input_ep1 = output_count * 2;
	while( input_idx < input_ep1 ) {
		filter_state = ( filter_state + input_buf[ input_idx ] ) >> 1;
		output_buf[ output_idx ] = filter_state;
		filter_state = ( filter_state + input_buf[ input_idx + 1 ] ) >> 1;
		input_idx += 2;
		output_idx += 1;
	}
}
```

I'm not a great fan of all these high-order filters, the mathematics are more than I can cope with :)

Cheers,
Martin

**ed.bew@ehcsa-k** · 2008-11-05 14:12:10

Hi @ all,

what is a good initialization value of filter\_state?

Greetings

Karsten

**moc.liamg@tramum** · 2009-05-02 23:38:31

filter\_state is the previous input sample \* 0.25, so zero is a good starting value for a non-periodic waveform.

**moc.oohay@bob** · 2009-07-07 12:02:32

I'm curious - as you're generating 1 sample for every 2, is it possible to then upsample with zero padding to get a half band filter at the original sample rate?

Cheers
B
