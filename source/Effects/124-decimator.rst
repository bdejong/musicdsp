Decimator
=========

- **Author or source:** ed.bew@raeybot
- **Type:** Bit-reducer and sample&hold unit
- **Created:** 2002-11-25 18:13:49


.. code-block:: text
    :caption: notes

    This is a simple bit and sample rate reduction code, maybe some of you can use it. The
    parameters are bits (1..32) and rate (0..1, 1 is the original samplerate).
    Call the function like this:
    y=decimate(x);
    
    A VST plugin implementing this algorithm (with full Delphi source code included) can be
    downloaded from here:
    http://tobybear.phreque.com/decimator.zip
    
    Comments/suggestions/improvements are welcome, send them to: tobybear@web.de
    


.. code-block:: c++
    :linenos:
    :caption: code

    // bits: 1..32
    // rate: 0..1 (1 is original samplerate)
    
    ********** Pascal source **********
    var m:longint;
        y,cnt,rate:single;
    
    // call this at least once before calling 
    // decimate() the first time
    procedure setparams(bits:integer;shrate:single);
    begin
     m:=1 shl (bits-1);
     cnt:=1;
     rate:=shrate;
    end;
    
    function decimate(i:single):single;
    begin
     cnt:=cnt+rate;
     if (cnt>1) then
     begin
      cnt:=cnt-1;
      y:=round(i*m)/m;
     end;
     result:=y;
    end;
    
    ********** C source **********
    int bits=16;
    float rate=0.5;
     
    long int m=1<<(bits-1);
    float y=0,cnt=0;
    
    float decimate(float i)
    {
     cnt+=rate;
     if (cnt>=1)
     {
      cnt-=1;
      y=(long int)(i*m)/(float)m;
     }
     return y;
    }
    

Comments
--------

- **Date**: 2002-12-03 12:44:42
- **By**: moc.noicratse@ajelak

.. code-block:: text

    Nothing wrong with that, but you can also do fractional-bit-depth decimations, allowing 
    smooth degradation from high bit depth to 
    low and back:
    ---------------------------------------
    
    // something like this -- this is 
    // completely off the top of my head
    // precalculate the quantization level
    float bits; // effective bit depth
    float quantum = powf( 2.0f, bits );
    
    // per sample
    y = floorf( x * quantum ) / quantum;
    
    ---------------------------------------
    
    
    

- **Date**: 2003-02-14 20:04:36
- **By**: es.yarps@fek.rd

.. code-block:: text

    it looks to me like the c-line
    
    long int m=1<<(bits-1);
    
    doesnt give the correct number of quantisation levels if the number of levels is defined as 2^bits. if bits=2 for instance, the above code line returns a bit pattern of 10 (3) and not 11 (2^2) like one would expect. 
    
    please, do correct me if im wrong.
    
    /heatrof
    

