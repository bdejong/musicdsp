Direct form II
==============

- **Author or source:** Fuzzpilz
- **Type:** generic
- **Created:** 2004-06-28 10:42:44


.. code-block:: text
    :caption: notes

    I've noticed there's no code for direct form II filters in general here, though probably
    many of the filter examples use it. I haven't looked at them all to verify that, but there
    certainly doesn't seem to be a snippet describing this.
    
    This is a simple direct form II implementation of a k-pole, k-zero filter. It's a little
    faster than (a naive, real-time implementation of) direct form I, as well as more
    numerically accurate.


.. code-block:: c++
    :linenos:
    :caption: code

    Direct form I pseudocode:
    
    y[n] = a[0]*x[n] + a[1]*x[n-1] + .. + a[k]*x[n-k]
                     - b[1]*y[n-1] - .. - b[k]*y[n-k];
    
    Simple equivalent direct form II pseudocode:
    
    y[n] = a[0]*x[n] + d[0];
    d[0] = a[1]*x[n] - b[1]*y[n] + d[1];
    d[1] = a[2]*x[n] - b[2]*y[n] + d[2];
    .
    .
    d[k-2] = a[k-1]*x[n] - b[k-1]*y[n] + d[k-1];
    d[k-1] = a[k]*x[n] - b[k]*y[n];
    
    For example, a biquad:
    
    out = a0*in + a1*h0 + a2*h1 - b1*h2 - b2*h3;
    h1 = h0;
    h0 = in;
    h3 = h2;
    h2 = out;
    
    becomes
    
    out = a0*in + d0;
    d0 = a1*in - b1*out + d1;
    d1 = a2*in - b2*out;

Comments
--------

- **Date**: 2007-02-21 17:31:20
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    I think the per sample denormal number elimination on x87 FPUs is more difficult, since you need to check for denormals at 3 places instead of one (if I'm right).              

- **Date**: 2007-06-11 16:44:05
- **By**: moc.liamg@sgninnejtg

.. code-block:: text

    Are the constants (a and b) wrong here.  Don't they need to be switched?  If you look at like wikipedia that's the case and it makes more since.  I'm trying to implement a low pass filter at 25mhz passband edge.  I'm getting alot of fluctuation in my output more that expect.  Any suggestions?
    
    int main(int argc, char *argv[])
    {
    double b[3] = {1,2,1};
    double a1[3] = {1,-1.9995181705254206,0.99952100328066507};
    //double a1[3] = {1,-1.9252217796690612,0.95315661147483732};
    double a2[3] = {1,-1.9985996261556458,0.99860245760957123};
    double a3[3] = {1,-1.9977949691405856,0.99779779945453828};
    double a4[3] = {1,-1.9971690447494761,0.99717187417666975};
    double a5[3] = {1,-1.9967721889631873,0.9967750178281477};
    double a6[2] = {1, -0.99831813425055116};
    double d[3] = {0};
    double y[5][3] = {0};
    double out[2] = {0};
    double x[3]={0}, x1,x2,in;
    double i=0;
    char wait;
    while(i<10000000)
    {
    x1 = sin(2*10000*3.14159265*i);
    x2 = sin(2*10000*3.14159265*i-3.14159265);
    in = x1 * x2;
    
    
    x[0] = in * 7.0818881108085789e-7;
    
    y[0][0] = b[0]*x[0] + b[1]*x[1] + b[2]*x[2] - a1[1]*y[0][1] - a1[2]*y[0][1];
    y[0][1] = y[0][0];
    x[2] = x[1];
    x[1] = x[0];
    //////////////////////////////////////////////////////////////////////////////////
    y[0][0] = y[0][0] * 7.0786348128153693e-7;
    y[1][0] = b[0]*y[0][0] + b[1]*y[0][1] + b[2]*y[0][2] - a2[1]*y[1][1] - a2[2]*y[1][1];
    y[0][2] = y[0][1];
    y[0][1] = y[0][0];
    y[1][1] = y[1][0];
    //////////////////////////////////////////////////////////////////////////////////
    y[1][0] = y[1][0] * 7.0757848807506174e-7;
    y[2][0] = b[0]*y[1][0] + b[1]*y[1][1] + b[2]*y[1][2] - a3[1]*y[2][1] - a3[2]*y[2][1];
    y[1][2] = y[1][1];
    y[1][1] = y[1][0];
    y[2][1] = y[2][0];
    //////////////////////////////////////////////////////////////////////////////////
    y[2][0] = y[2][0] * 7.0735679834155469e-7;
    y[3][0] = b[0]*y[2][0] + b[1]*y[2][1] + b[2]*y[2][2] - a4[1]*y[3][1] - a4[2]*y[3][1];
    y[2][2] = y[2][1];
    y[2][1] = y[2][0];
    y[3][1] = y[3][0];
    //////////////////////////////////////////////////////////////////////////////////
    y[3][0] = y[3][0] * 7.0721624006526327e-007;
    y[4][0] = b[0]*y[3][0] + b[1]*y[3][1] + b[2]*y[3][2] - a5[1]*y[4][1] - a5[2]*y[4][1];
    y[3][2] = y[3][1];
    y[3][1] = y[3][0];
    y[4][1] = y[4][0];
    //////////////////////////////////////////////////////////////////////////////////
    /*y[4][0] = y[4][0]* 0.000840932874724457;
    out[0] = 1*y[4][0] + 1*y[4][1] - a6[1]*out[1];
    y[4][1] = y[4][0];
    out[1] = out[0];*/
    
    cout<<y[4][0]<<"\n";
    
    i+=.1;
    }

- **Date**: 2009-03-23 07:17:12
- **By**: es.tuanopx@kileib.trebor

.. code-block:: text

    Regarding denormals: Don't check for them. Prevent them by adding a small value (~1e-20) to the filter memory pipeline.

- **Date**: 2009-03-23 18:15:40
- **By**: es.tuanopx@kileib.trebor

.. code-block:: text

    Processing a single biquad doesn't benefit much (if any) from doing a DF II implementation. However, if you'd process stereo, the DF II variant is very suitable for interleaving of non-dependent calculations, making it easier for the compiler to generate effective code. Actually, the DF II stereo implementation below is more than 2 times faster than the naive DF I stereo one:
    
    struct stereo_biquad
    {
        float b0,b1,b2,a1,a2 // From rb-j's cookbook with a0 normalized to 1.0
        float lm1,lm2,rm1,rm2; // Filter state
        float dn;              // de-denormal coeff (1.0e-20f)
    };
    
    void processStereoBiquadDF2(
        struct stereo_biquad& bq,
        const float* inL,
        const float* inR,
        float* outL,
        float* outR,
        unsigned length)
    {
        for (unsigned i = 0; i < length; ++i)
        {
            register float w1 = inL[i] - bq.a1*bq.lm1 - bq.a2*bq.lm2 + bq.dn;
            register float w2 = inR[i] - bq.a1*bq.rm1 - bq.a2*bq.rm2 + bq.dn;
            outL[i] = bq.b1*bq.lm1 + bq.b2*bq.lm2 + bq.b0*w1;
            bq.lm2 = bq.lm1; bq.lm1 = w1;
            outR[i] = bq.b1*bq.rm1 + bq.b2*bq.rm2 + bq.b0*w2;
            bq.rm2 = bq.rm1; bq.rm1 = w2;
        }
        bq.dn = -bq.dn;
    }
    

