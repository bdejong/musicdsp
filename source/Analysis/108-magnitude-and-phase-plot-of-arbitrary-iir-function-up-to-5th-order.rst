Magnitude and phase plot of arbitrary IIR function, up to 5th order
===================================================================

- **Author or source:** George Yohng
- **Type:** magnitude and phase at any frequency
- **Created:** 2002-08-01 00:43:57


.. code-block:: text
    :caption: notes

    Amplitude and phase calculation of IIR equation
    run at sample rate "sampleRate" at frequency "F".
    
    AMPLITUDE
    -----------
    cf_mag(F,sampleRate,
           a0,a1,a2,a3,a4,a5,
           b0,b1,b2,b3,b4,b5)
    -----------
    
    PHASE
    -----------
    cf_phi(F,sampleRate,
           a0,a1,a2,a3,a4,a5,
           b0,b1,b2,b3,b4,b5)
    -----------
    
    If you need a frequency diagram, draw a plot for
    F=0...sampleRate/2
    
    If you need amplitude in dB, use cf_lin2db(cf_mag(.......))
    
    Set b0=-1 if you have such function:
    
    y[n] = a0*x[n] + a1*x[n-1] + a2*x[n-2] + a3*x[n-3] + a4*x[n-4] + a5*x[n-5] +
                   + b1*y[n-1] + b2*y[n-2] + b3*y[n-3] + b4*y[n-4] + b5*y[n-5];
    
    Set b0=1  if you have such function:
    
    y[n] = a0*x[n] + a1*x[n-1] + a2*x[n-2] + a3*x[n-3] + a4*x[n-4] + a5*x[n-5] +
                   - b1*y[n-1] - b2*y[n-2] - b3*y[n-3] - b4*y[n-4] - b5*y[n-5];
    
    Do not try to reverse engineer these formulae - they don't give any sense
    other than they are derived from transfer function, and they work. :)
    


.. code-block:: c++
    :linenos:
    :caption: code

    /*
     C file can be downloaded from
     http://www.yohng.com/dsp/cfsmp.c
    */
    
    
    #define C_PI 3.14159265358979323846264
    
    double cf_mag(double f,double rate,
                  double a0,double a1,double a2,double a3,double a4,double a5,
                  double b0,double b1,double b2,double b3,double b4,double b5)
    {
        return
            sqrt((a0*a0 + a1*a1 + a2*a2 + a3*a3 + a4*a4 + a5*a5 + 
                  2*(a0*a1 + a1*a2 + a2*a3 + a3*a4 + a4*a5)*cos((2*f*C_PI)/rate) + 
                  2*(a0*a2 + a1*a3 + a2*a4 + a3*a5)*cos((4*f*C_PI)/rate) +
                  2*a0*a3*cos((6*f*C_PI)/rate) + 2*a1*a4*cos((6*f*C_PI)/rate) +
                  2*a2*a5*cos((6*f*C_PI)/rate) + 2*a0*a4*cos((8*f*C_PI)/rate) + 
                  2*a1*a5*cos((8*f*C_PI)/rate) + 2*a0*a5*cos((10*f*C_PI)/rate))/
                  (b0*b0 + b1*b1 + b2*b2 + b3*b3 + b4*b4 + b5*b5 + 
                  2*(b0*b1 + b1*b2 + b2*b3 + b3*b4 + b4*b5)*cos((2*f*C_PI)/rate) + 
                  2*(b0*b2 + b1*b3 + b2*b4 + b3*b5)*cos((4*f*C_PI)/rate) +
                  2*b0*b3*cos((6*f*C_PI)/rate) + 2*b1*b4*cos((6*f*C_PI)/rate) +
                  2*b2*b5*cos((6*f*C_PI)/rate) + 2*b0*b4*cos((8*f*C_PI)/rate) + 
                  2*b1*b5*cos((8*f*C_PI)/rate) + 2*b0*b5*cos((10*f*C_PI)/rate)));
    }
    
    
    double cf_phi(double f,double rate,
                  double a0,double a1,double a2,double a3,double a4,double a5,
                  double b0,double b1,double b2,double b3,double b4,double b5)
    {
            atan2((a0*b0 + a1*b1 + a2*b2 + a3*b3 + a4*b4 + a5*b5 + 
                  (a0*b1 + a1*(b0 + b2) + a2*(b1 + b3) + a5*b4 + a3*(b2 + b4) +
                  a4*(b3 + b5))*cos((2*f*C_PI)/rate) +
                  ((a0 + a4)*b2 + (a1 + a5)*b3 + a2*(b0 + b4) +
                  a3*(b1 + b5))*cos((4*f*C_PI)/rate) + a3*b0*cos((6*f*C_PI)/rate) +
                  a4*b1*cos((6*f*C_PI)/rate) + a5*b2*cos((6*f*C_PI)/rate) + 
                  a0*b3*cos((6*f*C_PI)/rate) + a1*b4*cos((6*f*C_PI)/rate) +
                  a2*b5*cos((6*f*C_PI)/rate) + a4*b0*cos((8*f*C_PI)/rate) +
                  a5*b1*cos((8*f*C_PI)/rate) + a0*b4*cos((8*f*C_PI)/rate) + 
                  a1*b5*cos((8*f*C_PI)/rate) +
                  (a5*b0 + a0*b5)*cos((10*f*C_PI)/rate))/
                  (b0*b0 + b1*b1 + b2*b2 + b3*b3 + b4*b4 + b5*b5 + 
                  2*((b0*b1 + b1*b2 + b3*(b2 + b4) + b4*b5)*cos((2*f*C_PI)/rate) + 
                  (b2*(b0 + b4) + b3*(b1 + b5))*cos((4*f*C_PI)/rate) +
                  (b0*b3 + b1*b4 + b2*b5)*cos((6*f*C_PI)/rate) + 
                  (b0*b4 + b1*b5)*cos((8*f*C_PI)/rate) +
                  b0*b5*cos((10*f*C_PI)/rate))),
    
                 ((a1*b0 + a3*b0 + a5*b0 - a0*b1 + a2*b1 + a4*b1 - a1*b2 +
                  a3*b2 + a5*b2 - a0*b3 - a2*b3 + a4*b3 - 
                  a1*b4 - a3*b4 + a5*b4 - a0*b5 - a2*b5 - a4*b5 + 
                  2*(a3*b1 + a5*b1 - a0*b2 + a4*(b0 + b2) - a1*b3 + a5*b3 +
                  a2*(b0 - b4) - a0*b4 - a1*b5 - a3*b5)*cos((2*f*C_PI)/rate) +
                  2*(a3*b0 + a4*b1 + a5*(b0 + b2) - a0*b3 - a1*b4 - a0*b5 - a2*b5)*
                  cos((4*f*C_PI)/rate) + 2*a4*b0*cos((6*f*C_PI)/rate) +
                  2*a5*b1*cos((6*f*C_PI)/rate) - 2*a0*b4*cos((6*f*C_PI)/rate) -
                  2*a1*b5*cos((6*f*C_PI)/rate) + 2*a5*b0*cos((8*f*C_PI)/rate) - 
                  2*a0*b5*cos((8*f*C_PI)/rate))*sin((2*f*C_PI)/rate))/
                  (b0*b0 + b1*b1 + b2*b2 + b3*b3 + b4*b4 + b5*b5 + 
                  2*(b0*b1 + b1*b2 + b2*b3 + b3*b4 + b4*b5)*cos((2*f*C_PI)/rate) + 
                  2*(b0*b2 + b1*b3 + b2*b4 + b3*b5)*cos((4*f*C_PI)/rate) +
                  2*b0*b3*cos((6*f*C_PI)/rate) + 2*b1*b4*cos((6*f*C_PI)/rate) +
                  2*b2*b5*cos((6*f*C_PI)/rate) + 2*b0*b4*cos((8*f*C_PI)/rate) + 
                  2*b1*b5*cos((8*f*C_PI)/rate) + 2*b0*b5*cos((10*f*C_PI)/rate)));
    }
    
    double cf_lin2db(double lin)
    {
        if (lin<9e-51) return -1000; /* prevent invalid operation */
        return 20*log10(lin);
    }
    
    

Comments
--------

- **Date**: 2004-01-02 08:46:35
- **By**: Rob

.. code-block:: matlab

    % Actually it is simpler to simply take the zero-padded b and a coefficients and do real->complex
    % FFT like this (matlab code):
    
    H_complex=fft(b,N)./fft(a,N);
    phase=angle(H_complex);
    Magn=abs(H_complex);
    
    % This will give you N/2 points from 0 to pi angle freq (or 0 to nyquist freq).
    % /Rob
    

- **Date**: 2004-10-01 00:55:09
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: c++

    // Here are the formulas if you only have a biquad. But i am not sure, if maybe the
    // phase is shifted with pi/2...
    
    20*Log10(
             sqrt(
                  (a0*a0+a1*a1+a2*a2+
                   2*(a0*a1+a1*a2)*cos(w)+ 
                   2*(a0*a2)* cos(2*w)
                  )
                  /
                  (
                   1 + b1*b1 + b2*b2 +
                   2*(b1 + b1*b2)*cos(w)+
                   2*b2*cos(2*w)
                  )
                 )
            )
    
    
    ArcTan2(
            (
              a0+a1*b1+a2*b2+
             (a0*b1+a1*(1+b2)+a2*b1)*cos(w)+
             (a0*b2+a2)*cos(2*w)
            )
            /
            (
              1+b1*b1+b2*b2+
              2*
              (
               (b1+b1*b2)*cos(w)+ b2*cos(2*w)
              )
            )
            ,
            (
             (
               a1-a0*b1+a2*b1-a1*b2+
               2*(-a0*b2+a2)*cos(w)
             )*sin(w)
             /
             (
               1+b1*b1+b2*b2+
               2*(b1 + b1*b2)*cos(w)+
               2*b2*cos(2*w)
             )
            )
           )

- **Date**: 2005-03-28 22:43:17
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: delphi

    // Recursive Delphi Code with arbitrary order:
    
    unit Plot;
    
    // interface
    
    type TArrayOfDouble = Array of Double;
    
    function MagnitudeCalc(f,rate : Double; a,b : TArrayOfDouble): Double;
    
    // implementation
    
    uses Math;
    
    function MulVectCalc(const v: TArrayOfDouble; const Z, N : Integer) : Double;
    begin
     if N=0
      then result:=0
      else result:=(v[N-1]*v[N-1+Z])+MulVectCalc(v,Z,N-1);
    end;
    
    function MagCascadeCalc(const v: TArrayOfDouble; const w : double; N, Order : Integer ): Double;
    begin
     if N=1
      then result:=(MulVectCalc(v,0,Order))
      else result:=((MulVectCalc(v,N-1,1+Order-N)*(2*cos((N-1)*w))+MagCascadeCalc(v, w, N-1, Order )));
    end;
    
    function MagnitudeCalc(f,rate : Double; a,b : TArrayOfDouble): Double;
    var w : Double;
    begin
     w:=(2*f*pi)/rate;
     result:=sqrt(MagCascadeCalc(a, w, Length(a),Length(a))/MagCascadeCalc(b, w, Length(b),Length(b)));
    end;
    
    end.

- **Date**: 2005-07-27 12:39:52
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: delphi

    function CalcMagPart(w: Double; C : TDoubleArray):Double;
    var i,j,l : Integer;
        temp  : Double;
    begin
     l:=Length(C);
     temp:=0;
     for j:=0 to l-1
      do temp:=temp+C[j]*C[j];
     result:=temp;
     for i:=1 to l-1 do
      begin
       temp:=0;
       for j:=0 to l-i-1
        do temp:=temp+C[j]*C[j+i];
       result:=Result+2*temp*cos(i*w);
      end;
    end;
    
    function CalcMagnitude_dB(const f,rate: Double; const A,B: TDoubleArray): Double;
    var w : Double;
    begin
     w:=(2*f*pi)/rate;
     result:=10*log10(CalcMagPart(w,A)/CalcMagPart(w,B));
    end;
    
    // Here's a really fast function for an arbitrary IIR with high order without stack overflows
    // or recursion. And specially for John without sqrt.

