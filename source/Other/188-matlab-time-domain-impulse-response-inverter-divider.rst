Matlab Time Domain Impulse Response Inverter/Divider
====================================================

- **Author or source:** moc.sdohtemenacra@enacra
- **Created:** 2005-01-19 22:27:15


.. code-block:: text
    :caption: notes

    Matlab code for time domain inversion of an impulse response or the division of two of
    them (transfer function.)  The main teoplitz function is given both as a .m file and as a
    .c file for Matlab'w MEX compilation.  The latter is much faster.
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    function inv=invimplms(den,n,d)
    % syntax inv=invimplms(den,n,d)
    %         den - denominator impulse
    %         n   - length of result
    %         d   - delay of result
    %         inv - inverse impulse response of length n with delay d
    %
    % Levinson-Durbin algorithm from Proakis and Manolokis p.865
    %
    % Author: Bob Cain, May 1, 2001 arcane[AT]arcanemethods[DOT]com
    
    	m=xcorr(den,n-1);
    	m=m(n:end);
    	b=[den(d+1:-1:1);zeros(n-d-1,1)];
    	inv=toepsolve(m,b);
    
    
    
    function quo=divimplms(num,den,n,d)
    %Syntax quo=divimplms(num,den,n,d)
    %       num - numerator impulse
    %       den - denominator impulse
    %       n   - length of result
    %       d   - delay of result
    %		quo - quotient impulse response of length n delayed by d
    %
    % Levinson-Durbin algorithm from Proakis and Manolokis p.865
    %
    % Author: Bob Cain, May 1, 2001 arcane@arcanemethods.com
    
    	m=xcorr(den,n-1);
    	m=m(n:end);
    	b=xcorr([zeros(d,1);num],den,n-1);
    	b=b(n:-1:1);
    	quo=toepsolve(m,b);
    
    
    function hinv=toepsolve(r,q)
    % Solve Toeplitz system of equations.
    %    Solves R*hinv = q, where R is the symmetric Toeplitz matrix
    %    whos first column is r
    %    Assumes all inputs are real
    %    Inputs:  
    %       r - first column of Toeplitz matrix, length n
    %       q - rhs vector, length n
    %    Outputs:
    %       hinv - length n solution
    %
    %   Algorithm from Roberts & Mullis, p.233
    %
    %   Author: T. Krauss, Sept 10, 1997
    %
    %   Modified: R. Cain, Dec 16, 2004 to remove a pair of transposes
    %             that caused errors.
    
    	n=length(q);
    	a=zeros(n+1,2);
    	a(1,1)=1;
    
    	hinv=zeros(n,1);
    	hinv(1)=q(1)/r(1);
    
    	alpha=r(1);
    	c=1;
    	d=2;
    
    	for k=1:n-1,
    	   a(k+1,c)=0;
    	   a(1,d)=1;
    	   beta=0;
    	   j=1:k;
    	   beta=sum(r(k+2-j).*a(j,c))/alpha;
    	   a(j+1,d)=a(j+1,c)-beta*a(k+1-j,c);
    	   alpha=alpha*(1-beta^2);
    	   hinv(k+1,1)=(q(k+1)-sum(r(k+2-j).*hinv(j,1)))/alpha;
    	   hinv(j)=hinv(j)+a(k+2-j,d)*hinv(k+1);
    	   temp=c;
    	   c=d;
    	   d=temp;
    	end
    
    
    -----What follows is the .c version of toepsolve--------
    
    #include <math.h>
    #include "mex.h"
    
    /*  function hinv = toepsolve(r,q);
     *  TOEPSOLVE  Solve Toeplitz system of equations.
     *    Solves R*hinv = q, where R is the symmetric Toeplitz matrix
     *    whos first column is r
     *    Assumes all inputs are real
     *    Inputs:  
     *       r - first column of Toeplitz matrix, length n
     *       q - rhs vector, length n
     *    Outputs:
     *       hinv - length n solution
     *
     *   Algorithm from Roberts & Mullis, p.233
     *
     *   Author: T. Krauss, Sept 10, 1997
     *
     *   Modified: R. Cain, Dec 16, 2004 to replace unnecessasary
     *             n by n matrix allocation for a with an n by 2 rotating
     *             buffer and to more closely match the .m function.
     */
    void mexFunction(
        int nlhs,
        mxArray *plhs[],
        int nrhs,
        const mxArray *prhs[]
    )
    {
       double (*a)[2],*hinv,alpha,beta;
       int c,d,temp,j,k;
       
       double eps = mxGetEps();
       int n = (mxGetN(prhs[0])>=mxGetM(prhs[0])) ? mxGetN(prhs[0]) : mxGetM(prhs[0]) ;
       double *r = mxGetPr(prhs[0]);
       double *q = mxGetPr(prhs[1]);
       
       a = (double (*)[2])mxCalloc((n+1)*2,sizeof(double));
       if (a == NULL) {
           mexErrMsgTxt("Sorry, failed to allocate buffer.");
       }
       a[0][0]=1.0;
       
       plhs[0] = mxCreateDoubleMatrix(n,1,0);
       hinv = mxGetPr(plhs[0]);
       hinv[0] = q[0]/r[0];
       
       alpha=r[0];
       c=0;
       d=1;
       
       for (k = 1; k < n; k++) {
           a[k][c] = 0;
           a[0][d] = 1.0;
           beta = 0.0;
           for (j = 1; j <= k; j++) {
               beta += r[k+1-j]*a[j-1][c];
           }
           beta /= alpha;
           for (j = 1; j <= k; j++) {
               a[j][d] = a[j][c] - beta*a[k-j][c];
           }
           alpha *= (1 - beta*beta);
           hinv[k] = q[k];
           for (j = 1; j <= k; j++) {
               hinv[k] -= r[k+1-j]*hinv[j-1];
           }
           hinv[k] /= alpha;
           for (j = 1; j <= k; j++) {
               hinv[j-1] += a[k+1-j][d]*hinv[k];
           }
    	   temp=c;
    	   c=d;
    	   d=temp;
       } /* loop over k */
       
       mxFree(a);
    
       return;
    }
    
    
    
    

