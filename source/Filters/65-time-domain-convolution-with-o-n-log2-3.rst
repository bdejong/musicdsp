Time domain convolution with O(n^log2(3))
=========================================

- **Author or source:** Wilfried Welti
- **Created:** 2002-02-10 12:38:01


.. code-block:: text
    :caption: notes

    [Quoted from Wilfrieds mail...]
    I found last weekend that it is possible to do convolution in time domain (no complex
    numbers, 100% exact result with int) with O(n^log2(3))  (about O(n^1.58)).
    
    Due to smaller overhead compared to FFT-based convolution, it should be the fastest
    algorithm for medium sized FIR's.
    Though, it's slower as FFT-based convolution for large n.
    
    It's pretty easy:
    
    Let's say we have two finite signals of length 2n, which we want convolve : A and B. Now
    we split both signals into parts of size n, so we get A = A1 + A2, and B = B1 +B2.
    
    Now we can write:
    
    (1)  A*B = (A1+A2)*(B1+B2) = A1*B1 + A2*B1 + A1*B2 + A2*B2
    
    where * means convolution.
    
    This we knew already: We can split a convolution into four convolutions of halved size.
    
    Things become interesting when we start shifting blocks in time:
    
    Be z a signal which has the value 1 at x=1 and zero elsewhere. Convoluting a signal X with
    z is equivalent to shifting X by one rightwards. When I define z^n as n-fold convolution
    of z with itself, like: z^1 = z, z^2 = z*z, z^0 =  z shifted leftwards by 1 = impulse at
    x=0,  and so on, I can use it to shift signals:
    
    X * z^n  means shifting the signal X by the value n rightwards.
    X * z^-n means shifting the signal X by the value n leftwards.
    
    Now we look at the following term:
    
    (2)  (A1 + A2 * z^-n) * (B1 + B2 * z^-n)
    
    This is a convolution of two blocks of size n: We shift A2 by n leftwards so it completely
    overlaps A1, then we add them.
    We do the same thing with B1 and B2. Then we convolute the two resulting blocks.
    
    now let's transform this term:
    
    (3)  (A1 + A2 * z^-n) * (B1 + B2 * z^-n)
         = A1*B1 + A1*B2*z^-n + A2*z^-n*B1 + A2*z^ n*B2*z^-n
         = A1*B1 + (A1*B2 + A2*B1)*z^-n + A2*B2*z^-2n
    
    (4)  (A1 + A2 * z^-n) * (B1 + B2 * z^-n) - A1*B1 - A2*B2*z^-2n
    
         = (A1*B2 + A2*B1)*z^-n
    
    Now we convolute both sides of the equation (4) by z^n:
    
    (5)  (A1 + A2 * z^-n)*(B1 + B2 * z^-n)*z^n - A1*B1*z^n - A2*B2*z^-n
    
         = (A1*B2 + A2*B1)
    
    Now we see that the right part of equation (5) appears within equation (1), so we can
    replace this appearance by the left part of eq (5).
    
    (6) A*B = (A1+A2)*(B1+B2) = A1*B1 + A2*B1 + A1*B2 + A2*B2
       =  A1*B1
        + (A1 + A2 * z^-n)*(B1 + B2 * z^-n)*z^n - A1*B1*z^n - A2*B2*z^-n
        + A2*B2
    
    Voila!
    
    We have constructed the convolution of A*B with only three convolutions of halved size.
    (Since the convolutions with z^n and z^-n are only shifts
    of blocks with size n, they of course need only n operations for processing :)
    
    This can be used to construct an easy recursive algorithm of Order O(n^log2(3))


.. code-block:: c++
    :linenos:
    :caption: code

    void convolution(value* in1, value* in2, value* out, value* buffer, int size)
    {
      value* temp1 = buffer;
      value* temp2 = buffer + size/2;
      int i;
    
      // clear output.
      for (i=0; i<size*2; i++) out[i] = 0;
    
      // Break condition for recursion: 1x1 convolution is multiplication.
    
      if (size == 1)
      {
        out[0] = in1[0] * in2[0];
        return;
      }
    
      // first calculate (A1 + A2 * z^-n)*(B1 + B2 * z^-n)*z^n
    
      signal_add(in1, in1+size/2, temp1, size/2);
      signal_add(in2, in2+size/2, temp2, size/2);
      convolution(temp1, temp2, out+size/2, buffer+size, size/2);
    
      // then add A1*B1 and substract A1*B1*z^n
    
      convolution(in1, in2, temp1, buffer+size, size/2);
      signal_add_to(out, temp1, size);
      signal_sub_from(out+size/2, temp1, size);
    
      // then add A2*B2 and substract A2*B2*z^-n
    
      convolution(in1+size/2, in2+size/2, temp1, buffer+size, size/2);
      signal_add_to(out+size, temp1, size);
      signal_sub_from(out+size/2, temp1, size);
    }
    
    "value" may be a suitable type like int or float.
    Parameter "size" is the size of the input signals and must be a power of 2. out and buffer must point to arrays of size 2*n.
    
    Just to be complete, the helper functions:
    
    void signal_add(value* in1, value* in2, value* out, int size)
    {
      int i;
      for (i=0; i<size; i++) out[i] = in1[i] + in2[i];
    }
    
    void signal_sub_from(value* out, value* in, int size)
    {
      int i;
      for (i=0; i<size; i++) out[i] -= in[i];
    }
    
    void signal_add_to(value* out, value* in, int size)
    {
      int i;
      for (i=0; i<size; i++) out[i] += in[i];
    }

Comments
--------

- **Date**: 2003-11-05 11:53:05
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Here is a delphi translation of the code:
    
    // "value" may be a suitable type like int or float.
    // Parameter "size" is the size of the input signals and must be a power of 2.
    // out and buffer must point to arrays of size 2*n.
    
    procedure signal_add(in1, in2, ou1 :PValue; Size:Integer);
    var i            : Integer;
    begin
     for i:=0 to Size-1 do
      begin
       ou1^[i] := in1^[i] + in2^[i];
      end;
    end;
    
    procedure signal_sub_from(in1, ou1 :PValue; Size:Integer);
    var i       : Integer;
    begin
     for i:=0 to Size-1 do
      begin
       ou1^[i] := ou1^[i] - in1^[i];
      end;
    end;
    
    procedure signal_add_to(in1, ou1: PValue; Size:Integer);
    var i       : Integer;
        po, pi1 : PValue;
    begin
     po:=ou1;
     pi1:=in1;
     for i:=0 to Size-1 do
      begin
       ou1^[i] := ou1^[i] + in1^[i];
       Inc(po);
       Inc(pi1);
      end;
    end;
    
    procedure convolution(in1, in2, ou1, buffer :PValue; Size:Integer);
    var tmp1, tmp2 : PValue;
        i          : Integer;
    begin
     tmp1:=Buffer;
     tmp2:=@(Buffer^[(Size div 2)]);
    
     // clear output.
     for i:=0 to size*2 do ou1^[i]:=0;
    
     // Break condition for recursion: 1x1 convolution is multiplication.
     if Size = 1 then
      begin
       ou1^[0] := in1^[0] * in2^[0];
       exit;
      end;
    
     // first calculate (A1 + A2 * z^-n)*(B1 + B2 * z^-n)*z^n
     signal_add(in1, @(in1^[(Size div 2)]), tmp1, Size div 2);
     signal_add(in2, @(in1^[(Size div 2)]), tmp2, Size div 2);
     convolution(tmp1, tmp2, @(ou1^[(Size div 2)]), @(Buffer^[Size]), Size div 2);
    
     // then add A1*B1 and substract A1*B1*z^n
     convolution(in1, in2, tmp1, @(Buffer^[Size]), Size div 2);
     signal_add_to(ou1, tmp1, size);
     signal_sub_from(@(ou1^[(Size div 2)]), tmp1, size);
    
     // then add A2*B2 and substract A2*B2*z^-n
     convolution(@(in1^[(Size div 2)]), @(in2^[(Size div 2)]), tmp1, @(Buffer^[Size]), Size div 2);
     signal_add_to(@(ou1^[Size]), tmp1, size);
     signal_sub_from(@(ou1^[Size]), tmp1, size);
    end;

- **Date**: 2003-11-05 12:19:05
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Sorry, i forgot the definitions:
    
    type
      Values = Array[0..0] of Single;
      PValue = ^Values;             

- **Date**: 2004-04-19 19:47:52
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    I have implemented a Suround-Plugin using this Source-Code.
    Basicly a FIR-Filter with 512 Taps, bundled with some HRTF's for sourround panning
    
    http://www.savioursofsoul.de/Christian/ITA-HRTF.EXE             
    
    (Delphi Sourcecode available on request)

