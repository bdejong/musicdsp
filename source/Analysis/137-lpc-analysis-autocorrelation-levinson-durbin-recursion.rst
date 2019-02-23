LPC analysis (autocorrelation + Levinson-Durbin recursion)
==========================================================

- **Author or source:** ten.enegatum@liam
- **Created:** 2004-04-07 09:37:51


.. code-block:: text
    :caption: notes

    The autocorrelation function implements a warped autocorrelation, so that frequency
    resolution can be specified by the variable 'lambda'.  Levinson-Durbin recursion
    calculates autoregression coefficients a and reflection coefficients (for lattice filter
    implementation) K.  Comments for Levinson-Durbin function implement matlab version of the
    same function.
    
    No optimizations.


.. code-block:: c++
    :linenos:
    :caption: code

    //find the order-P autocorrelation array, R, for the sequence x of length L and warping of lambda
    //wAutocorrelate(&pfSrc[stIndex],siglen,R,P,0);
    wAutocorrelate(float * x, unsigned int L, float * R, unsigned int P, float lambda)
    {
    	double	* dl = new double [L];
    	double	* Rt = new double [L];
    	double r1,r2,r1t;
    	R[0]=0;
    	Rt[0]=0;
    	r1=0;
    	r2=0;
    	r1t=0;
    	for(unsigned int k=0; k<L;k++)
    	{
    			Rt[0]+=double(x[k])*double(x[k]);
    
    			dl[k]=r1-double(lambda)*double(x[k]-r2);
    			r1 = x[k];
    			r2 = dl[k];
    	}
    	for(unsigned int i=1; i<=P; i++)
    	{
    		Rt[i]=0;
    		r1=0;
    		r2=0;
    		for(unsigned int k=0; k<L;k++)
    		{
    			Rt[i]+=double(dl[k])*double(x[k]);
    			
    			r1t = dl[k];
    			dl[k]=r1-double(lambda)*double(r1t-r2);
    			r1 = r1t;
    			r2 = dl[k];
    		}
    	}
    	for(i=0; i<=P; i++)
    		R[i]=float(Rt[i]);
    	delete[] dl;
    	delete[] Rt;
    }
    
    // Calculate the Levinson-Durbin recursion for the autocorrelation sequence R of length P+1 and return the autocorrelation coefficients a and reflection coefficients K
    LevinsonRecursion(unsigned int P, float *R, float *A, float *K)
    {
    	double Am1[62];
    
    	if(R[0]==0.0) { 
    		for(unsigned int i=1; i<=P; i++) 
    		{
    			K[i]=0.0; 
    			A[i]=0.0;
    		}}
        else {
    		double km,Em1,Em;
    		unsigned int k,s,m;
    		for (k=0;k<=P;k++){
    			A[0]=0;
    			Am1[0]=0; }
    		A[0]=1;
    		Am1[0]=1;
    		km=0;
    		Em1=R[0];
    		for (m=1;m<=P;m++)					//m=2:N+1
    		{
    			double err=0.0f;					//err = 0;
    			for (k=1;k<=m-1;k++)			//for k=2:m-1
    				err += Am1[k]*R[m-k];		// err = err + am1(k)*R(m-k+1);
    			km = (R[m]-err)/Em1;			//km=(R(m)-err)/Em1;
    			K[m-1] = -float(km);
    			A[m]=(float)km;						//am(m)=km;
    			for (k=1;k<=m-1;k++)			//for k=2:m-1
    				A[k]=float(Am1[k]-km*Am1[m-k]);  // am(k)=am1(k)-km*am1(m-k+1);
    			Em=(1-km*km)*Em1;				//Em=(1-km*km)*Em1;
    			for(s=0;s<=P;s++)				//for s=1:N+1
    				Am1[s] = A[s];			    // am1(s) = am(s)
    			Em1 = Em;						//Em1 = Em;
    		}
    	}
    	return 0;
    }
    

Comments
--------

- **Date**: 2005-03-31 15:16:20
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: delphi

    // Blind Object Pascal Translation:
    // --------------------------------
    
    // unit Levinson;
    
    // interface
    
    // type
    //  TDoubleArray = array of Double;
    //  TSingleArray = array of Single;
    
    // implementation
    
    //find the P-order autocorrelation array, R, for the sequence x of length L and warping of lambda
    procedure Autocorrelate(x,R : TSingleArray; P : Integer; lambda : Single; l: Integer = -1);
    var dl,Rt     : TDoubleArray;
        r1,r2,r1t : Double;
        k,i       : Integer;
    begin
     // Initialization
     if l=-1 then l:=Length(x);
     SetLength(dl,l);
     SetLength(Rt,l);
     R[0]:=0;
     Rt[0]:=0;
     r1:=0;
     r2:=0;
     r1t:=0;
    
     for k:=0 to l-1 do
      begin
       Rt[0]:=Rt[0]+x[k]*x[k];
       dl[k]:=r1-lambda*(x[k]-r2);
       r1:= x[k];
       r2:= dl[k];
      end;
    
     for i:=1 to P do
      begin
       Rt[i]:=0;
       r1:=0;
       r2:=0;
       for k:=0 to L-1 do
        begin
         Rt[i]:=Rt[i]+dl[k]*x[k];
         r1t:= dl[k];
         dl[k]:=r1-lambda*(r1t-r2);
         r1:=r1t;
         r2:=dl[k];
        end;
      end;
    
     for i:=1 to P do R[i]:=Rt[i];
     setlength(Rt,0);
     setlength(dl,0);
    end;
    
    // Calculate the Levinson-Durbin recursion for the autocorrelation sequence
    // R of length P+1 and return the autocorrelation coefficients a and reflection coefficients K
    procedure LevinsonRecursion(P : Integer; R,A,K : TSingleArray);
    var Am1       : TDoubleArray;
        i,j,s,m   : Integer;
        km,Em1,Em : Double;
        err       : Double;
    begin
     SetLength(Am1,62);
     if (R[0]=0.0) then
      begin
       for i:=1 to P do
        begin
         K[i]:=0.0;
         A[i]:=0.0;
        end;
      end
     else
      begin
       for j:=0 to P do
        begin
         A[0]:=0;
         Am1[0]:=0;
        end;
       A[0]:=1;
       Am1[0]:=1;
       km:=0;
       Em1:=R[0];
       for m:=1 to P do
        begin
         err:=0.0;
         for j:=1 to m-1 do err:=err+Am1[j]*R[m-j];
         km:=(R[m]-err)/Em1;
         K[m-1]:=-km;
         A[m]:=km;
         for j:=1 to m-1 do A[j]:=Am1[j]-km*Am1[m-j];
         Em:=(1-km*km)*Em1;
         for s:=0 to P do Am1[s]:=A[s];
         Em1:=Em;
        end;
      end;
    end;
    
    // end.

