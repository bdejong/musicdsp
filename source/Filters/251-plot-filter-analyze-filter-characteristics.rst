Plot Filter (Analyze filter characteristics)
============================================

- **Author or source:** ku.oc.oohay@895rennacs
- **Type:** Test
- **Created:** 2007-11-26 14:05:40


.. code-block:: text
    :caption: notes

    As a newbe, and one that has very, very little mathematical background, I wanted to see
    what all the filters posted here were doing to get a feeling of what was going on here. So
    with what I picked up from this site, I wrote a little filter test program. Hope it is of
    any use to you.
    


.. code-block:: c++
    :linenos:
    :caption: code

    //
    // plotFilter.cpp
    //
    // Simple test program to plot filter characteristics of a particular
    // filter to stdout. Nice to see how the filter behaves under various
    // conditions (cutoff/resonance/samplerate/etc.).
    //
    // Should work on any platform that supports C++ and should work on C
    // as well with a little rework. It justs prints text, so no graphical
    // stuff is used.
    //
    // Filter input and filter output should be between -1 and 1 (floating point)
    //
    // Output is a plotted graph (as text) with a logarithmic scale
    // (so half a plotted bar is half of what the human ear can hear).
    // If you dont like the vertical output, just print it and turn the paper :-)
    //
    
    #include <stdio.h>
    #include <stdlib.h>
    #include <float.h>
    #include <math.h>
    
    #define myPI 3.1415926535897932384626433832795
    
    #define FP double
    #define DWORD unsigned long
    #define CUTOFF       5000
    #define SAMPLERATE  48000
    
    // take enough samples to test the 20 herz frequency 2 times
    #define TESTSAMPLES (SAMPLERATE/20) * 2
    
    //
    // Any filter can be tested, as long as it outputs
    // between -1 and 1 (floating point). This filter
    // can be replaced with any filter you would like
    // to test.
    //
    class Filter {
    	FP sdm1;	// sample data minus 1
    	FP a0;		// multiply factor on current sample
    	FP b1;		// multiply factor on sdm1
    public:
    	Filter (void) {
    		sdm1 = 0;
    		// init on no filtering
    		a0   = 1;
    		b1   = 0;
    	}
    	void init(FP freq, FP samplerate) {
    		FP x;
    		x = exp(-2.0 * myPI * freq / samplerate);
    		sdm1 = 0;
    		a0   = 1.0 - x;
    		b1   = -x;
    	}
    	FP getSample(FP sample) {
    		FP out;
    		out = (a0 * sample) - (b1 * sdm1);
    		sdm1 = out;
    		return out;
    	}
    };
    
    int
    main(void)
    {
    	DWORD  freq;
    	DWORD  spos;
    	double sIn;
    	double sOut;
    	double tIn;
    	double tOut;
    	double dB;
    	DWORD  tmp;
    
    	// define the test filter
    	Filter filter;
    
    	printf("                  9bB     6dB            3dB                         0dB\n");
    	printf(" freq    dB        |       |              |                           | \n");
    
    	// test frequencies 20 - 20020 with 100 herz steps
    	for (freq=20; freq<20020; freq+=100) {
    
    		// (re)initialize the filter
    		filter.init(CUTOFF, SAMPLERATE);
    
    		// let the filter do it's thing here
    		tIn = tOut = 0;
    		for (spos=0; spos<TESTSAMPLES; spos++) {
    			sIn  = sin((2 * myPI * spos * freq) / SAMPLERATE);
    			sOut = filter.getSample(sIn);
    			if ((sOut>1) || (sOut<-1)) {
    				// If filter is no good, stop the test
    				printf("Error! Clipping!\n");
    				return(1);
    			}
    			if (sIn >0) tIn  += sIn;
    			if (sIn <0) tIn  -= sIn;
    			if (sOut>0) tOut += sOut;
    			if (sOut<0) tOut -= sOut;
    		}
    
    		// analyse the results
    		dB = 20*log(tIn/tOut);
    		printf("%5d %5.1f ", freq, dB);
    		tmp = (DWORD)(60.0/pow(2, (dB/3)));
    		while (tmp) {
    			putchar('#');
    			tmp--;
    		}
    		putchar('\n');
    	}
    	return 0;
    }
    

Comments
--------

- **Date**: 2008-01-01 20:45:13
- **By**: niels m.

.. code-block:: text

    You need to change the log() to log10() to get the correct answer in dB's.
    
    You can also replace the if(sIn >0) .. -= sOut; by:
    
    tIn += sIn*sIn;
    tOut += sOut*sOut;
    
    this will measure signal power instead of amplitude. If you do this, you also need to change 20*log10() to 10*log10().
    
    Nice and useful tool for exploring filters. Thanks!

