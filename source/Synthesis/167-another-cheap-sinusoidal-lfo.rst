Another cheap sinusoidal LFO
============================

- **Author or source:** moc.cinohp-e@ofni
- **Created:** 2004-05-14 18:32:57


.. code-block:: text
    :caption: notes

    Some pseudo code for a easy to calculate LFO.
    
    You can even make a rough triangle wave out of this by substracting the output of 2 of
    these with different phases.
    
    PJ
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    r = the rate 0..1
    
    --------------
    p += r
    if(p > 1) p -= 2;
    out = p*(1-abs(p));
    --------------

Comments
--------

- **Date**: 2004-06-10 21:32:22
- **By**: moc.regnimmu@psd-cisum

.. code-block:: text

    Slick! I like it!
    
    Sincerely,
    Frederick Umminger

- **Date**: 2005-02-23 22:24:03
- **By**: es.tensse@idarozs.szalab

.. code-block:: text

    Great! just what I wanted a fast trinagle lfo. :D
    
    float rate = 0..1;
    float phase1 = 0;
    float phase2 = 0.1f;
    
    ---------------
    phase1 += rate;
    if (phase1>1) phase1 -= 2;
    
    phase2 += rate;
    if (phase2>1) phase2 -= 2;
    
    out = (phase1*(1-abs(phase1)) - phase2*(1-abs(phase2))) * 10;
    ---------------

- **Date**: 2006-08-02 22:10:54
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    Nice! If you want the output range to be between -1..1 then use:
    
    --------------
    p += r
    if(p > 2) p -= 4;
    out = p*(2-abs(p));
    --------------              

- **Date**: 2006-08-03 10:25:10
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    A better way of making a triangle LFO (out range is -1..1):
    
    rate = 0..1;
    p = -1;
    {
        p += rate;
        if (p>1) p -= 4.0f;
        out = abs(-(abs(p)-2))-1;
    }
                  

- **Date**: 2013-11-10 16:51:38
- **By**: ten.akionelet@isangi

.. code-block:: text

    /* this goes from -1 to +1 */
    #include <iostream>
    #include <math.h>
    
    using namespace std;
    int main(int argc, char *argv[]) {
    	
    	//r = the rate 0..1
    	float r = 0.5f;
    	float p = 0.f;
    	float result=0.f;
    	//--------------
    	for(int i=1;i<=2048;i++){
    	p += r;
    	if(p > 1) p -= 2;
    	result = 4*p*(1-fabs(p));
    	cout << result;
    	cout <<"\r";
    	}
    	}              

