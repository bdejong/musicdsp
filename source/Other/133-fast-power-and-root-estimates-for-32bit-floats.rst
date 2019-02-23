Fast power and root estimates for 32bit floats
==============================================

- **Author or source:** ed.bew@raebybot
- **Type:** floating point functions
- **Created:** 2002-12-18 21:07:27


.. code-block:: text
    :caption: notes

    Original code by Stefan Stenzel (also in this archive, see "pow(x,4) approximation") -
    extended for more flexibility.
    
    fastpow(f,n) gives a rather *rough* estimate of a float number f to the power of an
    integer number n (y=f^n). It is fast but result can be quite a bit off, since we directly
    mess with the floating point exponent.-> use it only for getting rough estimates of the
    values and where precision is not that important.
    
    fastroot(f,n) gives the n-th root of f. Same thing concerning precision applies here.
    
    Cheers
    
    Toby (www.tobybear.de)


.. code-block:: c++
    :linenos:
    :caption: code

    //C/C++ source code:
    float fastpower(float f,int n)
    {
     long *lp,l;
     lp=(long*)(&f);
     l=*lp;l-=0x3F800000l;l<<=(n-1);l+=0x3F800000l;
     *lp=l;
     return f;
    }
    
    float fastroot(float f,int n)
    {
     long *lp,l;
     lp=(long*)(&f);
     l=*lp;l-=0x3F800000l;l>>=(n-1);l+=0x3F800000l;
     *lp=l;
     return f;
    }
    
    //Delphi/Pascal source code:
    function fastpower(i:single;n:integer):single;
    var l:longint;
    begin
     l:=longint((@i)^);
     l:=l-$3F800000;l:=l shl (n-1);l:=l+$3F800000;
     result:=single((@l)^);
    end;
    
    function fastroot(i:single;n:integer):single;
    var l:longint;
    begin
     l:=longint((@i)^);
     l:=l-$3F800000;l:=l shr (n-1);l:=l+$3F800000;
     result:=single((@l)^);
    end;
    

