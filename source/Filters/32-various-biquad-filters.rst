Various Biquad filters
======================

- **Author or source:** JAES, Vol. 31, No. 11, 1983 November
- **Created:** 2002-01-17 02:08:47

- **Linked files:** :download:`filters003.txt <../files/filters003.txt>`.

.. code-block:: text
    :caption: notes

    (see linkfile)
    Filters included are:
    presence
    shelvelowpass
    2polebp
    peaknotch
    peaknotch2



Comments
--------

- **Date**: 2008-10-19 23:02:44
- **By**: moc.liamg@321tiloen

.. code-block:: text

    I'm kinda stuck trying to figure out the 'pointer' 'structure pointer' loop in the presence EQ.
    
    Can someone explain:
    
    ...
    
      *a0 = a2plus1 + alphan*ma2plus1;
      *a1 = 4.0*a;
      *a2 = a2plus1 - alphan*ma2plus1;
    
      b0 = a2plus1 + alphad*ma2plus1;
      *b2 = a2plus1 - alphad*ma2plus1;
    
      recipb0 = 1.0/b0;
      *a0 *= recipb0;
      *a1 *= recipb0;
      *a2 *= recipb0;
      *b1 = *a1;
      *b2 *= recipb0;
    
    ....
    
    void setfilter_presence(f,freq,boost,bw)
    filter *f;
    double freq,boost,bw;
    {
      presence(freq/(double)SR,boost,bw/(double)SR,
               &f->cx,&f->cx1,&f->cx2,&f->cy1,&f->cy2);
      f->cy1 = -f->cy1;
      f->cy2 = -f->cy2;
    }
    
    
    How can this be translated into something more easy to understand.
    
    Input = ...
    Output = ...

- **Date**: 2008-10-28 12:15:21
- **By**: moc.liamg@321tiloen

.. code-block:: text

    Managed to port the presence eq properly. And its sounds great!
    
    Altho I did some changes to some of the code.
    
    changed "d /= mag" to "d = mag"
    "bw/srate" to "bw"
    
    There results I got are stable within there parameters:
    
    freq: 3100-18500hz
    boost: 0-15db
    bw: 0.07-0.40
    
    Really good sound from this filter!

