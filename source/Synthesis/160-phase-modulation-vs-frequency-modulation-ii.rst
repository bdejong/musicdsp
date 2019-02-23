Phase modulation Vs. Frequency modulation II
============================================

- **Author or source:** James McCartney
- **Created:** 2003-12-01 08:24:26


.. code-block:: text
    :caption: notes

    The difference between FM & PM in a digital oscillator is that FM is added to the
    frequency before the phase integration, while PM is added to the phase after the phase
    integration. Phase integration is when the old phase for the oscillator is added to the
    current frequency (in radians per sample) to get the new phase for the oscillator. The
    equivalent PM modulator to obtain the same waveform as FM is the integral of the FM
    modulator. Since the integral of sine waves are inverted cosine waves this is no problem.
    In modulators with multiple partials, the equivalent PM modulator will have different
    relative partial amplitudes. For example, the integral of a square wave is a triangle
    wave; they have the same harmonic content, but the relative partial amplitudes are
    different. These differences make no difference since we are not trying to exactly
    recreate FM, but real (or nonreal) instruments.
    
    The reason PM is better is because in PM and FM there can be non-zero energy produced at 0
    Hz, which in FM will produce a shift in pitch if the FM wave is used again as a modulator,
    however in PM the DC component will only produce a phase shift. Another reason PM is
    better is that the modulation index (which determines the number of sidebands produced and
    which in normal FM is calculated as the modulator amplitude divided by frequency of
    modulator) is not dependant on the frequency of the modulator, it is always equal to the
    amplitude of the modulator in radians. The benefit of solving the DC frequency shift
    problem, is that cascaded carrier-modulator pairs and feedback modulation are possible.
    The simpler calculation of modulation index makes it easier to have voices keep the same
    harmonic structure throughout all pitches.
    
    The basic mathematics of phase modulation are available in any text on electronic
    communication theory.
    
    Below is some C code for a digital oscillator that implements FM,PM,and AM. It illustrates
    the difference in implementation of FM & PM. It is only meant as an example, and not as an
    efficient implementation.


.. code-block:: c++
    :linenos:
    :caption: code

    /* Example implementation of digital oscillator with FM, PM, & AM */
    
    #define PI 3.14159265358979
    #define RADIANS_TO_INDEX (512.0 / (2.0 * PI))
    
    typedef struct{	/* oscillator data */
    	double freq;   /* oscillator frequency in radians per sample */
    	double phase;  /* accumulated oscillator phase in radians */
    	double wavetable[512]; /* waveform lookup table */
    } OscilRec;
    
    
    /* oscil - compute 1 sample of oscillator output whose freq. phase and
    *    wavetable are in the OscilRec structure pointed to by orec.
    */
    double oscil(orec, fm, pm, am)
    	OscilRec *orec;  /* pointer to the oscil's data */
    	double fm; /* frequency modulation input  in radians per sample */
    	double pm; /* phase modulation input      in radians */
    	double am; /* amplitude modulation input  in any units you want */
    {
    	long tableindex;            /* index into wavetable */
    	double instantaneous_freq;  /* oscillator freq  + freq  modulation */
    	double instantaneous_phase; /* oscillator phase + phase modulation */
    	double output;              /* oscillator output */
    	
    	instantaneous_freq  = orec->freq  + fm; /* get instantaneous freq */
    	orec->phase += instantaneous_freq;      /* accumulate phase */
    	instantaneous_phase = orec->phase + pm; /* get instantaneous phase */
    	
    	/* convert to lookup table index */
    	tableindex = RADIANS_TO_INDEX * instantaneous_phase;
    	tableindex &= 511; /* make it mod 512 === eliminate multiples of 2*k*PI */
    	
    	output = orec->wavetable[tableindex] * am; /* lookup and mult by am input */
    	
    	return (output);  /* return oscillator output */
    }

Comments
--------

- **Date**: 2011-03-08 11:29:32
- **By**: ed.redienhcsslin@mapsvulipsdcisum

.. code-block:: text

    As the PM/FM is "iterative", won't this code produce different results at different sampling rates? How can this be prevented?
    
    Any advice is highly appreciated!
     

