Karlsen Fast Ladder
===================

- **Author or source:** moc.liamtoh@neslrakevofira
- **Type:** 4 pole ladder emulation
- **Created:** 2007-01-08 10:49:56


.. code-block:: text
    :caption: notes

    ATTN Admin: You should remove the old version named "Karlsen" on your website, and rather
    include this one instead.


.. code-block:: c++
    :linenos:
    :caption: code

    // An updated version of "Karlsen 24dB Filter"
    // This time, the fastest incarnation possible.
    // The very best greetings, Arif Ove Karlsen.
    // arifovekarlsen->hotmail.com
    
    b_rscl = b_buf4; if (b_rscl > 1) {b_rscl = 1;}
    b_in = (-b_rscl * b_rez) + b_in;
    b_buf1 = ((-b_buf1 + b_in1) * b_cut) + b_buf1;
    b_buf2 = ((-b_buf2 + b_buf1) * b_cut) + b_buf2;
    b_buf3 = ((-b_buf3 + b_buf2) * b_cut) + b_buf3;
    b_buf4 = ((-b_buf4 + b_buf3) * b_cut) + b_buf4;
    b_lpout = b_buf4;

Comments
--------

- **Date**: 2007-01-08 18:42:24
- **By**: moc.erehwon@ydobon

.. code-block:: text

    Where are the coefficients? How do I set the cutoff frequency?

- **Date**: 2007-01-09 09:49:18
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    The parameters are:
    b_cut - cutoff freq
    b_rez - resonance
    b_in1 - input
    
    Cutoff is normalized frequency in rads (2*pi*cutoff/samplerate). Stability limit for b_cut is around 0.7-0.8.
    
    There's a typo, the input is sometimes b_in, sometimes b_in1. Anyways why do you use a b_ prefix for all your variables? Wouldn't it be more easy to read like this:
    
    resoclip = buf4; if (resoclip > 1) resoclip = 1;
    in = in - (resoclip * res);
    buf1 = ((in - buf1) * cut) + buf1;
    buf2 = ((buf1 - buf2) * cut) + buf2;
    buf3 = ((buf2 - buf3) * cut) + buf3;
    buf4 = ((buf3 - buf4) * cut) + buf4;
    lpout = buf4;
    
    Also note that asymmetrical clipping gives you DC offset (at least that's what I get), so symmetrical clipping is better (and gives a much smoother sound).
    
    -- peter schoffhauzer

- **Date**: 2007-06-26 16:23:57
- **By**: moc.psd8rts@fira

.. code-block:: text

    Tee b_prefix is simply a procedure I began using when I started programming C. Influenced by the BEOS operating system. However it seemed to also make my code more readable, atleast to me. So I started using various prefixes for various things, making the variables easily reckognizable. Peter, everyone, I am now reachable on www.str8dsp.com - Do also check out the plugin offers there!

- **Date**: 2007-07-17 20:21:47
- **By**: moc.psd8rts@koa

.. code-block:: text

    Here's even another filter, I will probably never get around to making any product with this one so here it is, pseudo-vintage diode ladder.
    
    			Diode Ladder, (unbuffered)
    
    			// limit resonance, rzl, tweak smearing with fltw, 0.3230 seems to be a good vintage sound.
    			in = in - rzl;
    			in = in + ((-in +kbuf1) * cutoff);  
    			kbuf1 = in + ((-in + kbuf1) * fltw);
    			in = in + ((-in +kbuf2) * cutoff);  
    			kbuf2 = in + ((-in + kbuf2) * fltw);
    			etc..
    

- **Date**: 2007-09-09 22:37:08
- **By**: moc.oiduatniopxf@ved

.. code-block:: text

    "Cutoff is normalized frequency in rads (2*pi*cutoff/samplerate):
    
    This seems to be valid for very low ( < 200 Hz ) frequencies - higher sample rates seem to be "Closer"
    
    thanks 

- **Date**: 2010-07-17 09:25:41
- **By**: moc.liamerofegapkcehc@liamerofegapkcehc

.. code-block:: text

    I also did a 9th order gaussian filter (minimal phase), using only 5 orders, for my limiter, which is released under the GPL LICENCE. http://www.paradoxuncreated.com

- **Date**: 2012-11-14 08:15:06
- **By**: Generalized perfect digital "ladder" filter, with the desired aspects of analog.

.. code-block:: text

    Hi, I have now generalized the ladder filter, into fast code, and with the desired aspects of analog, but retaining digital perfectness.
    
    Please see my blog: http://paradoxuncreated.com/Blog/wordpress/?p=1360
    
    Peace Be With You.

- **Date**: 2013-06-21 14:44:18
- **By**: moc.golb@eesesaelp

.. code-block:: text

    I have also moved domains now, and consolidated the information on this ultimate digital filter, with "analog sound", here: 
    
    http://ovekarlsen.com/Blog/abdullah-filter/
    
    Peace Be With You!

- **Date**: 2016-02-14 01:31:32
- **By**: ove hy karlsen @ facebook.com

.. code-block:: text

    Karlsen Fast Ladder III - inspired by "transistors set to work as diode" type Roland filters. The best fast and non-nonsensical approximation of popular analog filter sound, as in for instance Roland SH-5, and the smaller TB-303.
    
    //Coupled with oversampling and simple oscs you will probably get the best analog approximation.
    
    //		// for nice low sat, or sharper type low deemphasis saturation, one can use a onepole shelf before the filter.
    //		b_lf = b_lf + ((-b_lf + b_v) * b_lfcut); // b_lfcut 0..1
    //		double b_lfhp = b_v - b_lf;
    //		b_v = b_lf + (b_lf1hp * ((b_lfgain*0.5)+1));   
    
    		double b_rez = b_aflt4 - b_v; // no attenuation with rez, makes a stabler filter.
    		b_v = b_v - (b_rez*b_fres); // b_fres = resonance amount. 0..4 typical "to selfoscillation", 0.6 covers a more saturated range.
    
    		double b_vnc = b_v; // clip, and adding back some nonclipped, to get a dynamic like analog.
    		if (b_v > 1) {b_v = 1;} else if (b_v < -1) {b_v = -1;}
    		b_v = b_vnc + ((-b_vnc + b_v) * 0.9840);
    
    		b_aflt1 = b_aflt1 + ((-b_aflt1 + b_v) * b_fenv); // straightforward 4 pole filter, (4 normalized feedback paths in series)
    		b_aflt2 = b_aflt2 + ((-b_aflt2 + b_aflt1) * b_fenv);
    		b_aflt3 = b_aflt3 + ((-b_aflt3 + b_aflt2) * b_fenv);
    		b_aflt4 = b_aflt4 + ((-b_aflt4 + b_aflt3) * b_fenv);
    		b_v = b_aflt4;
    
    // Behave.
    // Ove Hy Karlsen.

- **Date**: 2018-03-12 09:34:57
- **By**: moc.liamtoh@06rorrexatnys

.. code-block:: text

    Hey Ove
    
    I am wondering about the last filter the  Fast ladder diode III. Where is the input supposed to go?
    
    Sorry, I am still learning and thanks for some great filters, btw :) 
    
    Thanks, Jakob

