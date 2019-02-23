Time domain convolution with O(n^log2(3))
=========================================

- **Author or source:** Magnus Jonsson
- **Created:** 2002-09-07 23:23:50


.. code-block:: text
    :caption: notes

    [see other code by Wilfried Welti too!]


.. code-block:: c++
    :linenos:
    :caption: code

    void mul_brute(float *r, float *a, float *b, int w) 
    { 
        for (int i = 0; i < w+w; i++) 
            r[i] = 0; 
        for (int i = 0; i < w; i++) 
        {
            float *rr = r+i; 
            float ai = a[i]; 
            for (int j = 0; j < w; j++) 
                rr[j] += ai*b[j]; 
        } 
    }
    
    // tmp must be of length 2*w 
    void mul_knuth(float *r, float *a, float *b, int w, float *tmp) 
    { 
        if (w < 30) 
        {
            mul_brute(r, a, b, w); 
        }
        else 
        {
            int m = w>>1; 
        
            for (int i = 0; i < m; i++) 
            { 
                r[i  ] = a[m+i]-a[i  ]; 
                r[i+m] = b[i  ]-b[m+i]; 
            }
        
            mul_knuth(tmp, r  , r+m, m, tmp+w); 
            mul_knuth(r  , a  , b  , m, tmp+w); 
            mul_knuth(r+w, a+m, b+m, m, tmp+w); 
        
            for (int i = 0; i < m; i++) 
            { 
                float bla = r[m+i]+r[w+i]; 
                r[m+i] = bla+r[i    ]+tmp[i  ]; 
                r[w+i] = bla+r[w+m+i]+tmp[i+m]; 
            }
        }
    }

