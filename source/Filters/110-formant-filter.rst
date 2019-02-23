Formant filter
==============

- **Author or source:** Alex
- **Created:** 2002-08-02 18:26:59



.. code-block:: c++
    :linenos:
    :caption: code

    /*
    Public source code by alex@smartelectronix.com
    Simple example of implementation of formant filter
    Vowelnum can be 0,1,2,3,4 <=> A,E,I,O,U
    Good for spectral rich input like saw or square 
    */
    //-------------------------------------------------------------VOWEL COEFFICIENTS
    const double coeff[5][11]= {
    { 8.11044e-06,
    8.943665402,	-36.83889529,	92.01697887,	-154.337906,	181.6233289,
    -151.8651235,   89.09614114,	-35.10298511,	8.388101016,	-0.923313471  ///A
    },
    {4.36215e-06,
    8.90438318,	-36.55179099,	91.05750846,	-152.422234,	179.1170248,  ///E
    -149.6496211,87.78352223,	-34.60687431,	8.282228154,	-0.914150747
    },
    { 3.33819e-06,
    8.893102966,	-36.49532826,	90.96543286,	-152.4545478,	179.4835618,
    -150.315433,	88.43409371,	-34.98612086,	8.407803364,	-0.932568035  ///I
    },
    {1.13572e-06,
    8.994734087,	-37.2084849,	93.22900521,	-156.6929844,	184.596544,   ///O
    -154.3755513,	90.49663749,	-35.58964535,	8.478996281,	-0.929252233
    },
    {4.09431e-07,
    8.997322763,	-37.20218544,	93.11385476,	-156.2530937,	183.7080141,  ///U
    -153.2631681,	89.59539726,	-35.12454591,	8.338655623,	-0.910251753
    }
    }; 
    //---------------------------------------------------------------------------------
    static double memory[10]={0,0,0,0,0,0,0,0,0,0};
    //---------------------------------------------------------------------------------
    float formant_filter(float *in, int vowelnum)
    {
    		    res= (float) ( coeff[vowelnum][0]  *in +
    					 coeff[vowelnum][1]  *memory[0] +  
    					 coeff[vowelnum][2]  *memory[1] +
    					 coeff[vowelnum][3]  *memory[2] +
    					 coeff[vowelnum][4]  *memory[3] +
    					 coeff[vowelnum][5]  *memory[4] +
    					 coeff[vowelnum][6]  *memory[5] +
    					 coeff[vowelnum][7]  *memory[6] +
    					 coeff[vowelnum][8]  *memory[7] +
    					 coeff[vowelnum][9]  *memory[8] +
    					 coeff[vowelnum][10] *memory[9] );
    
    memory[9]= memory[8];
    memory[8]= memory[7];
    memory[7]= memory[6];
    memory[6]= memory[5];
    memory[5]= memory[4];
    memory[4]= memory[3];
    memory[3]= memory[2];
    memory[2]= memory[1];					 
    memory[1]= memory[0];
    memory[0]=(double) res;
    return res;
    }

Comments
--------

- **Date**: 2002-08-21 04:47:36
- **By**: moc.oohay@nosrednattehr

.. code-block:: text

    Where did the coefficients come from? Do they relate to frequencies somehow? Are they male or female? Etc.

- **Date**: 2002-09-20 02:45:20
- **By**: es.umu.gni@nhs89le

.. code-block:: text

    And are the coeffiecients for 44k1hz?
    /stefancrs

- **Date**: 2002-11-17 09:16:51
- **By**: ten.ooleem@ooleem

.. code-block:: text

    It seem to be ok at 44KHz although I get quite lot of distortion with this filter. 
    There are typos in the given code too, the correct version looks like this i think:
    float formant_filter(float *in, int vowelnum) 
    { 
      float res= (float) ( coeff[vowelnum][0]* (*in) + 
      coeff[vowelnum][1] *memory[0] + 
      coeff[vowelnum][2] *memory[1] +  
      coeff[vowelnum][3] *memory[2] + 
      coeff[vowelnum][4] *memory[3] + 
      coeff[vowelnum][5] *memory[4] + 
      coeff[vowelnum][6] *memory[5] + 
      coeff[vowelnum][7] *memory[6] + 
      coeff[vowelnum][8] *memory[7] + 
      coeff[vowelnum][9] *memory[8] + 
      coeff[vowelnum][10] *memory[9] );  
    ...
    
    (missing type and asterisk in the first calc line ;).
    
    I tried morphing from one vowel to another and it works ok except in between 'A' and 'U' as I get a lot of distortion and sometime (depending on the signal) the filter goes into auto-oscilation.
    
    Sebastien Metrot
    
    

- **Date**: 2002-12-17 20:22:08
- **By**: gro.kale@ybsral

.. code-block:: text

    How did you get the coeffiecients?
    
    Did I miss something?
    
    /Larsby

- **Date**: 2003-01-22 15:22:02
- **By**: es.ecid@nellah.nafets

.. code-block:: text

    Yeah, morphing lineary between the coefficients works just fine. The distortion I only get when not lowering the amplitude of the input. So I lower it :)
    
    Larsby, you can approximate filter curves quite easily, check your dsp literature :)
    
    

- **Date**: 2003-07-07 08:45:53
- **By**: moc.xinortceletrams@xela

.. code-block:: text

    Correct, it is for sampling rate of 44kHz.
    It supposed to be female (soprano), approximated with its five formants.
    
    --Alex.

- **Date**: 2003-08-21 03:21:28
- **By**: moc.liamtoh@33reniur

.. code-block:: text

    Can you tell us how you calculated the coefficients?

- **Date**: 2003-10-04 18:42:31
- **By**: moc.liamtoh@sisehtnysorpitna

.. code-block:: text

    The distorting/sharp A vowel can be toned down easy by just changing the first coeff from 8.11044e-06 to 3.11044e-06. Sounds much better that way.

- **Date**: 2005-05-04 22:40:18
- **By**: moc.liamg@grebronj

.. code-block:: text

    Hi, I get the last formant (U) to self-oscillate and distort out of control whatever I feed it with. all the other ones sound fine...
    
    any sugesstions?
    
    Thanks,
    Jonas

- **Date**: 2006-04-12 22:07:35
- **By**: if.iki@xemxet

.. code-block:: text

    I was playing around this filter, and after hours of debugging finally noticed that converting those coeffecients to float just won't do it. The resulting filter is not stable anymore. Doh...
    
    I don't have any idea how to convert them, though. 

- **Date**: 2008-10-29 00:35:27
- **By**: mysterious T

.. code-block:: text

    Fantastic, it's all I can say! Done the linear blending and open blending matrix (a-e, a-i, a-o, a-u, e-i, e-o...etc..etc..). Too much fun!
    
    Thanks a lot, Alex!

- **Date**: 2010-12-14 13:16:19
- **By**: johnny

.. code-block:: text

    What about input and output range? When I feed the filter with audio data in -1 to 1 range, output doesn't stay in the same range. Maybe the input or output needs to be scaled?

