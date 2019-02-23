Moog Filter
===========

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** Antti's version (nonlinearities)
- **Created:** 2005-04-27 08:54:50


.. code-block:: text
    :caption: notes

    Here is a Delphi/Object Pascal translation of Antti's Moog Filter.
    
    Antti wrote:
    
    "At last DAFX I published a paper presenting a non-linear model of the Moog ladder. For
    that, see http://dafx04.na.infn.it/WebProc/Proc/P_061.pdf
    
    I used quite different approach in that one. A half-sample delay ([0.5 0.5] FIR filter
    basically) is inserted in the feedback loop. The remaining tuning and resonance error are
    corrected with polynomials. This approach depends on using at least 2X oversampling - the
    response after nyquist/2 is abysmal but that's taken care of by the oversampling.
    
    Victor Lazzarini has implemented my model in CSound:
    http://www.csounds.com/udo/displayOpcode.php?opcode_id=32
    
    In summary: You can use various methods, but you will need some numerically derived
    correction to realize exact tuning and resonance control. If you can afford 2X
    oversampling, use Victor's CSound code - the tuning has been tested to be very close
    ideal.
    
    Ps. Remember to use real oversampling instead of the "double sampling" the CSound code
    uses."
    
    I did not implemented real oversampling, but i inserted additional noise, which simulates
    the resistance noise and also avoids denormal problems...


.. code-block:: c++
    :linenos:
    :caption: code

    http://www.savioursofsoul.de/Christian/MoogFilter.pas

Comments
--------

- **Date**: 2005-04-27 18:08:06
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    You can also listen to it (Windows-VST) here: http://www.savioursofsoul.de/Christian/VST/MoogVST.zip

- **Date**: 2005-05-06 21:57:17
- **By**: rlindner@gmx ..dot.. net

.. code-block:: text

    and here is the same thing written in C. It was written while translating the CSound Code into code for the synthmaker code module as an intermediate step to enable debugging thru gdb. The code was written to be easy adoptable for the synthmaker code module (funny defines, static vars, single sample tick function,...) Has some room for improvements, but nothing fancy for seasoned C programmers.
    
    
    
    
    #include <memory.h>
    #include <stdio.h>
    #include <math.h>
    
    
    #define polyin  float
    #define polyout float
    
    #define BUFSIZE 64
    
    float delta_func [BUFSIZE];
    float out_buffer [BUFSIZE];
    
    
    
    
    
    
    void tick ( float in, float cf, float reso, float *out ) {
    
    
    // start of sm code
    
    
    // filter based on the text "Non linear digital implementation of the moog ladder filter" by Antti Houvilainen
    // adopted from Csound code at http://www.kunstmusik.com/udo/cache/moogladder.udo 
    polyin input;
    polyin cutoff;
    polyin resonance;
    
    polyout sigout;
    
    
    // remove this line in sm
    input = in; cutoff = cf; resonance = reso;
    
    
    // resonance [0..1]
    // cutoff from 0 (0Hz) to 1 (nyquist)
    
    float pi; pi = 3.1415926535;
    float v2; v2 = 40000;   // twice the 'thermal voltage of a transistor'
    float sr; sr = 22100;
    
    float  cutoff_hz;
    cutoff_hz = cutoff * sr;
    
    static float az1;
    static float az2;
    static float az3;
    static float az4;
    static float az5;
    static float ay1;
    static float ay2;
    static float ay3;
    static float ay4;
    static float amf;
    
    
    
    float x;         // temp var: input for taylor approximations
    float xabs;
    float exp_out;
    float tanh1_out, tanh2_out;
    float kfc;
    float kf;
    float kfcr;
    float kacr;
    float k2vg;
    
    kfc  = cutoff_hz/sr; // sr is half the actual filter sampling rate
    kf   = cutoff_hz/(sr*2);
    // frequency & amplitude correction
    kfcr = 1.8730*(kfc*kfc*kfc) + 0.4955*(kfc*kfc) - 0.6490*kfc + 0.9988;
    kacr = -3.9364*(kfc*kfc)    + 1.8409*kfc       + 0.9968;
    
    x  = -2.0 * pi * kfcr * kf;
    exp_out  = expf(x);
    
    k2vg = v2*(1-exp_out); // filter tuning
    
    
    // cascade of 4 1st order sections
    float x1 = (input - 4*resonance*amf*kacr) / v2;
    float tanh1 = tanhf (x1);
    float x2 = az1/v2;
    float tanh2 = tanhf (x2);
    ay1 = az1 + k2vg * ( tanh1 - tanh2);
    
    // ay1  = az1 + k2vg * ( tanh( (input - 4*resonance*amf*kacr) / v2) - tanh(az1/v2) );
    az1  = ay1;
    
    ay2  = az2 + k2vg * ( tanh(ay1/v2) - tanh(az2/v2) );
    az2  = ay2;
    
    ay3  = az3 + k2vg * ( tanh(ay2/v2) - tanh(az3/v2) );
    az3  = ay3;
    
    ay4  = az4 + k2vg * ( tanh(ay3/v2) - tanh(az4/v2) );
    az4  = ay4;
    
    // 1/2-sample delay for phase compensation
    amf  = (ay4+az5)*0.5;
    az5  = ay4;
    
    
    
    // oversampling (repeat same block)
    ay1  = az1 + k2vg * ( tanh( (input - 4*resonance*amf*kacr) / v2) - tanh(az1/v2) );
    az1  = ay1;
    
    ay2  = az2 + k2vg * ( tanh(ay1/v2) - tanh(az2/v2) );
    az2  = ay2;
    
    ay3  = az3 + k2vg * ( tanh(ay2/v2) - tanh(az3/v2) );
    az3  = ay3;
    
    ay4  = az4 + k2vg * ( tanh(ay3/v2) - tanh(az4/v2) );
    az4  = ay4;
    
    // 1/2-sample delay for phase compensation
    amf  = (ay4+az5)*0.5;
    az5  = ay4;
    
    
    sigout = amf;
    
    
    
    // end of sm code
    
    
    *out   = sigout;
    
    } // tick
    
    
    int main ( int argc, char *argv[] )  {
    
    	// set delta function
    	memset ( delta_func, 0, sizeof(delta_func));
    	delta_func[0] = 1.0;
    
    	int i = 0;
    	for ( i = 0; i < BUFSIZE; i++ ) {
    		tick ( delta_func[i], 0.6, 0.7, out_buffer+i );
    	}
    	for ( i = 0; i < BUFSIZE; i++ ) {
    		printf ("%f;", out_buffer[i] );
    	}
        printf ( "\n" );
    
    
    } // main
    
    
    
    
    
    
    
             

- **Date**: 2005-05-07 03:56:13
- **By**: eb.tenyks@didid

.. code-block:: text

    I think that a better speed optimization of Tanh2 would be to extract the sign bit (using integer) instead of abs, and add it back to the final result, to avoid FABS, FCOMP and the branching

- **Date**: 2005-05-08 19:03:40
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    After reading some more assembler documents for university, i had the same idea...
    Now: Coding!

- **Date**: 2005-05-08 22:42:55
- **By**: eb.tenyks@didid

.. code-block:: text

    Btw1, is the idea to get rid of the "*0.5" in the "1/2 sample delay" block by using *2 instead of *4 in the first filter?
    
    Btw2, following the same simplification, you can also precompute "-2*fQ*fAcr" outside.

- **Date**: 2005-05-09 01:49:49
- **By**: eb.tenyks@didid

.. code-block:: text

    Forget the sign bit thing, actually your Tanh could already have been much faster at the source:
    
     a:=f_abs(x);
     a:=a*(6+a*(3+a));
     if (x<0)
      then Result:=-a/(a+12)
      else Result:= a/(a+12);
    
    can be written as the much simpler:
    
    Result:=x*(6+Abs(x)*(3+Abs(x))/(Abs(x)+12)
    
    ..so in asm:
    
    function Tanh2(x:Single):Single;
    const c3 :Single=3;
          c6 :Single=6;
          c12:Single=12;
    Asm
            FLD     x
            FLD     ST(0)
            FABS
            FLD     c3
            FADD    ST(0),ST(1)
            FMUL    ST(0),ST(1)
            FADD    c6
            FMUL    ST(0),ST(2)
            FXCH    ST(1)
            FADD    c12
            FDIVP   ST(1),ST(0)
            FSTP    ST(1)
    End;
    
    
    ..but it won't be much faster than your code, because:
    -of the slow FDIV
    -it's still a function call. Since our dumb Delphi doesn't support assembler macro's, you waste a lot in the function call. You can still try to inline a plain pascal code, but since our dumb Delphi isn't good at compiling float code neither.. 
    
    Solutions:
    -a lookup table for the TanH
    -you write the filter processing in asm as well, and you put the TanH code in a separate file (without the header, and assuming in & out are ST(0)). You then $I to insert that file when the function call is needed. Poorman's macro's in Delphi :)
    
    Still, that's a lot of FDIV for a filter..

- **Date**: 2005-05-09 03:24:44
- **By**: eb.tenyks@didid

.. code-block:: text

    forget it, I was all wrong :)
    gonna re-post a working version later
    
    still I think that most of the CPU will always be wasted by the division.

- **Date**: 2005-05-09 03:48:33
- **By**: eb.tenyks@didid

.. code-block:: text

    Ignore the above, here it is working (for this code, assuming a premultiplied x):
    
    
    function Tanh2(x:Single):Single;
    const c3  :Single=3;
          c6  :Single=6;
          c12 :Single=12;
    Asm
            FLD     x
            FLD     ST(0)
            FABS                 // a
            FLD     c3
            FADD    ST(0),ST(1)
            FMUL    ST(0),ST(1)
            FADD    c6           // b
            FMUL    ST(2),ST(0)  // x*b
            FMULP   ST(1),ST(0)  // a*b
            FADD    c12
            FDIVP   ST(1),ST(0)
    End;   

- **Date**: 2005-05-09 07:59:40
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    That code is nice and very fast! But it's not that accurate. But indeed very fast! Thanks for the code. My approach was a lot slower.

- **Date**: 2005-05-09 15:05:28
- **By**: eb.tenyks@didid

.. code-block:: text

    But it should be as accurate as the one in your pascal code: it's the same approximation as Tanh2_pas2. Of course we're still talking about a Tanh approximation. You can still take it up to /24 for cheap. 
    Of course, don't try the first one I posted, it's completely wrong. 
    
    Btw it's also more accurate than pascal code, since it keeps values in the 80bit FPU registers, while the Delphi compiler will put them back to the 32bit variables in-between.
    
    Btw2 I implemented the {$I macro.inc} trick, works pretty well. The whole thing speeded up the code by almost 2. For more you could 3DNow 2 Tanh at once, it'd be easy in that filter.

- **Date**: 2005-05-09 21:20:06
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    OK, it's indeed my tanh2_pas2 approximation, but i've plotted both functions once and i found out, that the /24 version is much more accurate and that it is worth to calculate the additional macc operation.
    
    But of course the assembler version is much more accurate indeed.
    
    After assembler optimization, i could only speedup the whole thing to a factor of 1.5 the speed (measured with an impulse) and up to a factor of 1.7 measured with noise and the initial version with the branch.
    
    I will now do the 3DNow/SSE optimisation, let's see how it can be speeded up further more...

- **Date**: 2005-05-11 04:19:47
- **By**: eb.tenyks@didid

.. code-block:: text

    something bugs me about this filter.. I was assuming that it was made for a standard -1..1 normalized input. But looking at the 1/40000 drive gain, isn't it made for a -32768..32767 input? Otherwise I don't see what the Tanh drive is doing, it's basically linear for such low values, and I can't hear any difference with or without it. 

- **Date**: 2005-05-11 11:00:39
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Usually the tanh component wasn't a desired feature in the analog filter design. They trie to keep the input of a differential amplifier very low to retain the linearity.
    I have uploaded some plots from my VST Plugin Analyser Pro:
    http://www.savioursofsoul.de/Christian/VST/filter4.png (with -1..+1)
    http://www.savioursofsoul.de/Christian/VST/filter5.png (with -32768..+32767)
    
    http://www.savioursofsoul.de/Christian/VST/
    filter1.png (other...)
    http://www.savioursofsoul.de/Christian/VST/filter2.png (other...)
    http://www.savioursofsoul.de/Christian/VST/filter3.png (other...)
    
    Additionally i have updated the VST with a new slider for a gain multiplication (http://www.savioursofsoul.de/Christian/VST/MoogVST.zip)

- **Date**: 2005-11-28 10:09:19
- **By**: moc.liamg@dwod_niatnif

.. code-block:: text

    There is an error in the C implementation above,
    sr = 44100Hz, half the rate of the filter which is oversampled at a rate of 88200Hz. So the 22100 needs to be changed.
    Christians MoogFilter.pas implements it correctly.

