# Polyphase Filters

[MusicDSP](../README.md) / [Filters](README.md) · [8 comments](#comments)

- **Author or source:** C++ source code by Dave from Muon Software
- **Type:** polyphase filters, used for up and down-sampling
- **Created:** 2002-01-17 02:14:53
- **Linked files:** [BandLimit.cpp](../files/BandLimit.cpp).
- **Linked files:** [BandLimit.h](../files/BandLimit.h).

## Comments

<details>
<summary>Read 8 archived comments</summary>

1. **ed.bew@ihsugat\_aranoias** · *2005-02-16 00:14:08*

   can someone give me a hint for a paper where this stuff is from?

2. **ABC** · *2005-03-29 20:39:59*

   From there: <http://www.cmsa.wmin.ac.uk/~artur/Poly.html>

   There is also this library, implementing the same filter, but optimised for down/upsampling and ported to SSE and 3DNow!:
   <http://ldesoras.free.fr/prod.html#src_hiir>

3. **ku.oc.nez@mahcleb.bor** · *2005-07-27 09:22:16*

   There is an error in the 12th order, steep filter coefficients. Having checked the output against that produced by HIIR (see previous comment), i have identified the source of the error - the 4th b coefficient 0.06329609551399348, should be 0.6329609551399348.

4. **bla** · *2008-04-06 08:58:52*

   you also need to delete the pointers inside the array

   ```text
   CAllPassFilterCascade::~CAllPassFilterCascade()
   {
   	for (int i=0;i<numfilters;i++)
   	{
   		delete allpassfilter[i];
   	}

   	delete[] allpassfilter;
   };
   ```

5. **moc.tob.3gall1pso1dua@0fn1** · *2008-11-05 14:50:18*

   some questions..  is it normal for these halfband filters to cause significant gain loss?  sonogram analysis shows a decrease in SNR if I have read the results correctly.

   if using these filters for oversampling and I do this:

   upsample
   halfband filter
   \*process\*
   halfband filter
   decimate (discard samples)

   then presumably the second halfband filter does the antialiasing at half the new sampling rate?

6. **moc.toohay@bob** · *2009-02-26 21:39:21*

   Hello, I'm getting the high pass from the function by subtracting the 'oldout' variable.

   ```text
   output=(filter_a->process(input)-oldout)*0.5;
   ```

   But this does not make an ideal QMF, I'm getting pass-band aliasing, so I guessing the phase is off slightly between the low and high.
   Is this the correct way of getting the high band?

   Cheers,
   Dave P

7. **bobby** · *2010-01-21 19:31:46*

   Is the cutoff at 20kHz?  What sample rate are these coefficients for?  How would I calculate suitable coefficients for arbitrary sample rates?

8. **moc.psdallahlav@naes** · *2011-06-11 18:13:28*

   It is worth noting that if these filters are being used for upsampling/downsampling, the "noble identity" can be used to reduce the CPU cost. The basic idea is that operations that can be expressed in the form:

   filter that uses z^-N for its states -\> downsample by N

   can be rearranged to use the form

   downsample by N -\> filter that uses z^-1 for its states

   The same property holds true for upsampling. See

   <http://mue.music.miami.edu/thesis/jvandekieft/jvchapter3.htm>

   for more details.

   For the above code, this would entail creating an alternative allpass process function, that uses the z^-1 for its states, and then rearranging some of the operations.

</details>
