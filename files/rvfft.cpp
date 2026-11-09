//
//	                 FFT library
//
//  (one-dimensional complex and real FFTs for array 
//  lengths of 2^n)
//
//	Author: Toth Laszlo (tothl@inf.u-szeged.hu)
//  
//	Research Group on Artificial Intelligence
//  H-6720 Szeged, Aradi vertanuk tere 1, Hungary
//	
//	Last modified: 97.05.29
/////////////////////////////////////////////////////////

#include <math.h>
#include <stdlib.h>
#include "pi.h"

/////////////////////////////////////////////////////////
//Gives back "i" bit-reversed where "size" is the array
//length
//currently none of the routines call it

long bitreverse(long i, long size){

	long result,mask;

	result=0;
	for(;size>1;size>>=1){
		mask=i&1;
		i>>=1;
		result<<=1;
		result|=mask;
	}
	
/*     __asm{       the same in assebly
     mov eax,i
	 mov ecx,sizze
     mov ebx,0
   l:shr eax,1
     rcl ebx,1 
	 shr ecx,1
	 cmp ecx,1
     jnz l 
     mov result,ebx
     }*/
	 return result;
}

////////////////////////////////////////////////////////
//Bit-reverser for the Bruun FFT
//Parameters as of "bitreverse()"

long bruun_reverse(long i, long sizze){

	long result, add;

	result=0;
	add=sizze;

	while(1){
	if(i!=0) {
		while((i&1)==0) { i>>=1; add>>=1;}
		i>>=1; add>>=1;
		result+=add;
	}
	else {result<<=1;result+=add; return result;}
	if(i!=0) {
		while((i&1)==0) { i>>=1; add>>=1;}
		i>>=1; add>>=1;
		result-=add;
	}
	else {result<<=1;result-=add; return result;}
	}
}

/*assembly version
long bruun_reverse(long i, long sizze){

	long result;

	result=0;

	__asm{
		mov edx,sizze
		mov eax,i
		mov ebx,0
	 l: bsf cx,eax
		jz kesz1
		inc cx
		shr edx,cl
	    add ebx,edx
		shr eax,cl
		bsf cx,eax
		jz kesz2
		inc cx
		shr edx,cl
		sub ebx,edx
		shr eax,cl
		jmp l
kesz1:
		shl ebx,1
		
		add ebx,edx
		jmp vege
kesz2:
		shl ebx,1
		sub ebx,edx
	
  vege: mov result,ebx
	}
	return result;
}*/

/////////////////////////////////////////////////////////
// Decimation-in-freq radix-2 in-place butterfly
// data: array of doubles:
// re(0),im(0),re(1),im(1),...,re(size-1),im(size-1)
// it means that size=array_length/2 !!
// 
// suggested use:
// intput in normal order
// output in bit-reversed order
//
// Source: Rabiner-Gold: Theory and Application of DSP,
// Prentice Hall,1978

void dif_butterfly(double *data,long size){

	long angle,astep,dl;
	double xr,yr,xi,yi,wr,wi,dr,di,ang;
	double *l1, *l2, *end, *ol2;

     astep=1;
	 end=data+size+size;
     for(dl=size;dl>1;dl>>=1,astep+=astep){
					  l1=data;
					  l2=data+dl;
                      for(;l2<end;l1=l2,l2=l2+dl){
							ol2=l2;
                            for(angle=0;l1<ol2;l1+=2,l2+=2){
                               ang=2*pi*angle/size;
                               wr=cos(ang);
                               wi=-sin(ang);
                               xr=*l1+*l2;
                               xi=*(l1+1)+*(l2+1);
                               dr=*l1-*l2;
                               di=*(l1+1)-*(l2+1);
                               yr=dr*wr-di*wi;
                               yi=dr*wi+di*wr;
                               *(l1)=xr;*(l1+1)=xi;
                               *(l2)=yr;*(l2+1)=yi;
                               angle+=astep;
							   }
					  }
	 }
}

/////////////////////////////////////////////////////////
// Decimation-in-time radix-2 in-place inverse butterfly
// data: array of doubles:
// re(0),im(0),re(1),im(1),...,re(size-1),im(size-1)
// it means that size=array_length/2 !!
//
// suggested use:
// intput in bit-reversed order
// output in normal order
//
// Source: Rabiner-Gold: Theory and Application of DSP,
// Prentice Hall,1978

void inverse_dit_butterfly(double *data,long size){

	long angle,astep,dl;
	double xr,yr,xi,yi,wr,wi,dr,di,ang;
	double *l1, *l2, *end, *ol2;

     astep=size>>1;
	 end=data+size+size;
     for(dl=2;astep>0;dl+=dl,astep>>=1){
					  l1=data;
					  l2=data+dl;
                      for(;l2<end;l1=l2,l2=l2+dl){
							ol2=l2;
                            for(angle=0;l1<ol2;l1+=2,l2+=2){
                               ang=2*pi*angle/size;
                               wr=cos(ang);
                               wi=sin(ang);
                               xr=*l1;
                               xi=*(l1+1);
                               yr=*l2;
                               yi=*(l2+1);
                               dr=yr*wr-yi*wi;
                               di=yr*wi+yi*wr;
                               *(l1)=xr+dr;*(l1+1)=xi+di;
                               *(l2)=xr-dr;*(l2+1)=xi-di;
                               angle+=astep;
							   }
					  }
	 }
}

/////////////////////////////////////////////////////////
// data shuffling into bit-reversed order
// data: array of doubles:
// re(0),im(0),re(1),im(1),...,re(size-1),im(size-1)
// it means that size=array_length/2 !!
//
// Source: Rabiner-Gold: Theory and Application of DSP,
// Prentice Hall,1978 

void unshuffle(double *data, long size){

	long i,j,k,l,m;
	double re,im;

	//old version - turned out to be a bit slower
    /*for(i=0;i<size-1;i++){
             j=bitreverse(i,size);
             if (j>i){   //swap
                    re=data[i+i];im=data[i+i+1];
                    data[i+i]=data[j+j];data[i+i+1]=data[j+j+1];
                    data[j+j]=re;data[j+j+1]=im;
			 }
	}*/

l=size-1;
m=size>>1;
for (i=0,j=0; i<l ; i++){
	  if (i<j){
				re=data[j+j]; im=data[j+j+1];
				data[j+j]=data[i+i]; data[j+j+1]=data[i+i+1];
				data[i+i]=re; data[i+i+1]=im;
				}
	  k=m;
	  while (k<=j){
				j-=k;
				k>>=1;	
				}
	  j+=k;
      }
}

/////////////////////////////////////////////////////////
// used by realfft 
// parameters as above
//
// Source: Brigham: The Fast Fourier Transform
// Prentice Hall, ?

void realize(double *data, long size){

	double xr,yr,xi,yi,wr,wi,dr,di,ang,astep;
	double *l1, *l2;

	l1=data;
	l2=data+size+size-2;
    xr=*l1;
    xi=*(l1+1);
    *l1=xr+xi;
    *(l1+1)=xr-xi; 
	l1+=2;
	astep=pi/size;
    for(ang=astep;l1<=l2;l1+=2,l2-=2,ang+=astep){
                               xr=(*l1+*l2)/2;
                               yi=(-(*l1)+(*l2))/2;
                               yr=(*(l1+1)+*(l2+1))/2;
                               xi=(*(l1+1)-*(l2+1))/2;
                               wr=cos(ang);
                               wi=-sin(ang);
                               dr=yr*wr-yi*wi;
                               di=yr*wi+yi*wr;
                               *l1=xr+dr;
                               *(l1+1)=xi+di;      
                               *l2=xr-dr;
                               *(l2+1)=-xi+di;
	}
}

/////////////////////////////////////////////////////////
// used by inverse realfft 
// parameters as above
//
// Source: Brigham: The Fast Fourier Transform
// Prentice Hall, ?

void unrealize(double *data, long size){

	double xr,yr,xi,yi,wr,wi,dr,di,ang,astep;
	double *l1, *l2;

	l1=data;
	l2=data+size+size-2;
    xr=(*l1)/2;
    xi=(*(l1+1))/2;
    *l1=xr+xi;
    *(l1+1)=xr-xi; 
	l1+=2;
	astep=pi/size;
    for(ang=astep;l1<=l2;l1+=2,l2-=2,ang+=astep){
                               xr=(*l1+*l2)/2;
                               yi=-(-(*l1)+(*l2))/2;
                               yr=(*(l1+1)+*(l2+1))/2;
                               xi=(*(l1+1)-*(l2+1))/2;
                               wr=cos(ang);
                               wi=-sin(ang);
                               dr=yr*wr-yi*wi;
                               di=yr*wi+yi*wr;
                               *l2=xr+dr;
                               *(l1+1)=xi+di;      
                               *l1=xr-dr;
                               *(l2+1)=-xi+di;
	}
}

/////////////////////////////////////////////////////////
// in-place Radix-2 FFT for complex values
// data: array of doubles:
// re(0),im(0),re(1),im(1),...,re(size-1),im(size-1)
// it means that size=array_length/2 !!
// 
// output is in similar order, normalized by array length
//
// Source: see the routines it calls ...

void fft(double *data, long size){

	double *l, *end;

	dif_butterfly(data,size);
	unshuffle(data,size);

	end=data+size+size;
	for(l=data;l<end;l++){*l=*l/size;};
}


/////////////////////////////////////////////////////////
// in-place Radix-2 inverse FFT for complex values
// data: array of doubles:
// re(0),im(0),re(1),im(1),...,re(size-1),im(size-1)
// it means that size=array_length/2 !!
// 
// output is in similar order, NOT normalized by 
// array length
//
// Source: see the routines it calls ...

void ifft(double* data, long size){

	unshuffle(data,size);
	inverse_dit_butterfly(data,size);
}

/////////////////////////////////////////////////////////
// in-place Radix-2 FFT for real values
// (by the so-called "packing method")
// data: array of doubles:
// re(0),re(1),re(2),...,re(size-1)
// 
// output:
// re(0),re(size/2),re(1),im(1),re(2),im(2),...,re(size/2-1),im(size/2-1)
// normalized by array length
//
// Source: see the routines it calls ...

void realfft_packed(double *data, long size){

	double *l, *end;
	double div;

	size>>=1;
	dif_butterfly(data,size);
	unshuffle(data,size);
	realize(data,size);

	end=data+size+size;
	div=size+size;
	for(l=data;l<end;l++){*l=*l/div;};
}


/////////////////////////////////////////////////////////
// in-place Radix-2 inverse FFT for real values
// (by the so-called "packing method")
// data: array of doubles:
// re(0),re(size/2),re(1),im(1),re(2),im(2),...,re(size/2-1),im(size/2-1) 
// 
// output:
// re(0),re(1),re(2),...,re(size-1)
// NOT normalized by array length
//
//Source: see the routines it calls ...

void irealfft_packed(double *data, long size){

	double *l, *end;

	size>>=1;
	unrealize(data,size);
	unshuffle(data,size);
	inverse_dit_butterfly(data,size);

	end=data+size+size;
	for(l=data;l<end;l++){*l=(*l)*2;};
}


/////////////////////////////////////////////////////////
// Bruun FFT for real values
// data: array of doubles:
// re(0),re(1),re(2),...,re(size-1)
// 
// output:
// re(0),re(size/2),...,re(i),im(i)... pairs in 
// "bruun-reversed" order
// normalized by array length
//
// Source: 
// Bruun: z-Transform DFT Filters and FFT's
// IEEE Trans. ASSP, ASSP-26, No. 1, February 1978
//
// Comments:
// (this version is implemented in a manner that every 
// cosine is calculated only once;
// faster than the other version (see next)

void realfft_bruun(double *data, long size){

	double *end, *l0, *l1, *l2, *l3;
	long dl, dl2, dl_o, dl2_o, i, j, k, kk;
	double d0,d1,d2,d3,c,c2,p4;

	end=data+size;
	//first filterings, when there're only two taps
	size>>=1;
	dl=size;
	dl2=dl/2;
	for(;dl>1;dl>>=1,dl2>>=1){
		l0=data;
		l3=data+dl;
		for(i=0;i<dl;i++){
			d0=*l0;
			d2=*l3;
			*l0=d0+d2;
			*l3=d0-d2;
			l0++;
			l3++;
		}
	}
	l0=data;l1=data+1;
	d0=*l0;d1=*l1;
	*l0=d0+d1;*l1=d0-d1;
	l1+=2;
	*l1=-(*l1);
	
	//the remaining filterings
	
	p4=pi/(2*size);
	j=1;
	kk=1;
	dl_o=size/2;
	dl2_o=size/4;
	while(dl_o>1){
	for(k=0;k<kk;k++){
	c2=p4*bruun_reverse(j,size);
	c=2*cos(c2);
	c2=2*sin(c2);
	dl=dl_o;
	dl2=dl2_o;
	for(;dl>1;dl>>=1,dl2>>=1){
			l0=data+((dl*j)<<1);
			l1=l0+dl2;l2=l0+dl;l3=l1+dl;
			for(i=0;i<dl2;i++){
				d1=(*l1)*c;
				d2=(*l2)*c;
				d3=*l3+(*l1);
				d0=*l0+(*l2);
				*l0=d0+d1;
				*l1=d3+d2;
				*l2=d0-d1;
				*l3=d3-d2;
				l0++;
				l1++;
				l2++;
				l3++;
			}
		}
		//real conversion
		l3-=4;
		*l3=*l3-c*(*l0)/2;
		*l0=-c2*(*l0)/2;
		*l1=*l1+c*(*l2)/2;
		*l2=-c2*(*l2)/2;
	j++;
	}
	dl_o>>=1;
	dl2_o>>=1;
	kk<<=1;
	}

	//division with array length
	size<<=1;
	for(i=0;i<size;i++) data[i]=data[i]/size;
}

/////////////////////////////////////////////////////////
// Bruun FFT for real values
// data: array of doubles:
// re(0),re(1),re(2),...,re(size-1)
// 
// output:
// re(0),re(size/2),re(1),im(1),re(2),im(2),...,re(size/2-1),im(size/2-1)
// normalized by array length
//
// Source: see the routines it calls ...
void realfft_bruun_unshuffled(double *data, long size){

	double *data2;
	long i,j,k;

	realfft_bruun(data,size);
	//unshuffling - cannot be done in-place (?)
	data2=(double *)malloc(size*sizeof(double));
	for(i=1,k=size>>1;i<k;i++){
		j=bruun_reverse(i,k);
		data2[j+j]=data[i+i];
		data2[j+j+1]=data[i+i+1];
	}
	for(i=2;i<size;i++) data[i]=data2[i];
	free(data2);
}


/////////////////////////////////////////////////////////
// Bruun FFT for real values
// data: array of doubles:
// re(0),re(1),re(2),...,re(size-1)
// 
// output:
// re(0),re(size/2),...,re(i),im(i)... pairs in 
// "bruun-reversed" order
// normalized by array length
//
// Source: 
// Bruun: z-Transform DFT Filters and FFT's
// IEEE Trans. ASSP, ASSP-26, No. 1, February 1978
//
// Comments:
// (this version is implemented in a row-by-row manner;
// control structure is simpler, but there are too
// much cosine calls - with a cosine lookup table
// probably this would be slightly faster than bruun_fft

/*void realfft_bruun2(double *data, long size){

	double *end, *l0, *l1, *l2, *l3;
	long dl, dl2, i, j;
	double d0,d1,d2,d3,c,c2,p4;

	end=data+size;
	p4=pi/(size);
	size>>=1;
	dl=size;
	dl2=dl/2;
	//first filtering, when there're only two taps
	for(;dl>1;dl>>=1,dl2>>=1){
		l0=data;
		l3=data+dl;
		for(i=0;i<dl;i++){
			d0=*l0;
			d2=*l3;
			*l0=d0+d2;
			*l3=d0-d2;
			l0++;
			l3++;
		}
		//the remaining filterings
		j=1;
		while(l3<end){
			l0=l3;l1=l0+dl2;l2=l0+dl;l3=l1+dl;
			c=2*cos(p4*bruun_reverse(j,size));
			for(i=0;i<dl2;i++){
				d0=*l0;
				d1=*l1;
				d2=*l2;
				d3=*l3;
				*l0=d0+c*d1+d2;
				*l2=d0-c*d1+d2;
				*l1=d1+c*d2+d3;
				*l3=d1-c*d2+d3;
				l0++;
				l1++;
				l2++;
				l3++;
			}
			j++;
		}
	}

	//the last row: transform of real data	
	//the first two cells 
	l0=data;l1=data+1;
	d0=*l0;d1=*l1;
	*l0=d0+d1;*l1=d0-d1;
	l1+=2;
	*l1=-(*l1);
	l0+=4;l1+=2;
	//the remaining cells
	j=1;
	while(l0<end){
			c=p4*bruun_reverse(j,size);
			c2=sin(c);
			c=cos(c);
			*l0=*l0-c*(*l1);
			*l1=-c2*(*l1);
			l0+=2;
			l1+=2;
			*l0=*l0+c*(*l1);
			*l1=-c2*(*l1);
			l0+=2;
			l1+=2;
			j++;
			}
	//division with array length
	for(i=0;i<size;i++) data[i]=data[i]/size;
}
*/

//the same as realfft_bruun_unshuffled,
//but calls realfft_bruun2
/*void realfft_bruun_unshuffled2(double *data, long size){

	double *data2;
	long i,j,k;

	realfft_bruun2(data,size);
	//unshuffling - cannot be done in-place (?)
	data2=(double *)malloc(size*sizeof(double));
	for(i=1,k=size>>1;i<k;i++){
		j=bruun_reverse(i,k);
		data2[j+j]=data[i+i];
		data2[j+j+1]=data[i+i+1];
	}
	for(i=2;i<size;i++) data[i]=data2[i];
	free(data2);
}*/

/////////////////////////////////////////////////////////
// Sorensen in-place split-radix FFT for real values
// data: array of doubles:
// re(0),re(1),re(2),...,re(size-1)
// 
// output:
// re(0),re(1),re(2),...,re(size/2),im(size/2-1),...,im(1)
// normalized by array length
//
// Source: 
// Sorensen et al: Real-Valued Fast Fourier Transform Algorithms,
// IEEE Trans. ASSP, ASSP-35, No. 6, June 1987

void realfft_split(double *data,long n){

  long i,j,k,i5,i6,i7,i8,i0,id,i1,i2,i3,i4,n2,n4,n8;
  double t1,t2,t3,t4,t5,t6,a3,ss1,ss3,cc1,cc3,a,e,sqrt2;
  
  sqrt2=sqrt(2.0);
  n4=n-1;
  
  //data shuffling
      for (i=0,j=0,n2=n/2; i<n4 ; i++){
	  if (i<j){
				t1=data[j];
				data[j]=data[i];
				data[i]=t1;
				}
	  k=n2;
	  while (k<=j){
				j-=k;
				k>>=1;	
				}
	  j+=k;
      }
	
/*----------------------*/
	
	//length two butterflies	
	i0=0;
	id=4;
   do{
       for (; i0<n4; i0+=id){ 
			i1=i0+1;
			t1=data[i0];
			data[i0]=t1+data[i1];
			data[i1]=t1-data[i1];
		}
	   id<<=1;
       i0=id-2;
       id<<=1;
    } while ( i0<n4 );

   /*----------------------*/
   //L shaped butterflies
n2=2;
for(k=n;k>2;k>>=1){  
	n2<<=1;
	n4=n2>>2;
	n8=n2>>3;
	e = 2*pi/(n2);
	i1=0;
	id=n2<<1;
	do{ 
	    for (; i1<n; i1+=id){
			i2=i1+n4;
			i3=i2+n4;
			i4=i3+n4;
			t1=data[i4]+data[i3];
			data[i4]-=data[i3];
			data[i3]=data[i1]-t1;
			data[i1]+=t1;
			if (n4!=1){
				i0=i1+n8;
				i2+=n8;
				i3+=n8;
				i4+=n8;
				t1=(data[i3]+data[i4])/sqrt2;
				t2=(data[i3]-data[i4])/sqrt2;
				data[i4]=data[i2]-t1;
				data[i3]=-data[i2]-t1;
				data[i2]=data[i0]-t2;
				data[i0]+=t2;
			}
	     }
		 id<<=1;
	     i1=id-n2;
	     id<<=1;
	  } while ( i1<n );
	a=e;
	for (j=2; j<=n8; j++){  
	      a3=3*a;
	      cc1=cos(a);
	      ss1=sin(a);
	      cc3=cos(a3);
	      ss3=sin(a3);
	      a=j*e;
	      i=0;
	      id=n2<<1;
	      do{
		   for (; i<n; i+=id){  
			  i1=i+j-1;
			  i2=i1+n4;
			  i3=i2+n4;
			  i4=i3+n4;
			  i5=i+n4-j+1;
			  i6=i5+n4;
			  i7=i6+n4;
			  i8=i7+n4;
			  t1=data[i3]*cc1+data[i7]*ss1;
			  t2=data[i7]*cc1-data[i3]*ss1;
			  t3=data[i4]*cc3+data[i8]*ss3;
			  t4=data[i8]*cc3-data[i4]*ss3;
			  t5=t1+t3;
			  t6=t2+t4;
			  t3=t1-t3;
			  t4=t2-t4;
			  t2=data[i6]+t6;
			  data[i3]=t6-data[i6];
			  data[i8]=t2;
			  t2=data[i2]-t3;
			  data[i7]=-data[i2]-t3;
			  data[i4]=t2;
			  t1=data[i1]+t5;
			  data[i6]=data[i1]-t5;
			  data[i1]=t1;
			  t1=data[i5]+t4;
			  data[i5]-=t4;
			  data[i2]=t1;
		     }
		   id<<=1;
		   i=id-n2;
		   id<<=1;
		 } while(i<n);
	   }
      }

	//division with array length
   for(i=0;i<n;i++) data[i]/=n;
}


/////////////////////////////////////////////////////////
// Sorensen in-place split-radix FFT for real values
// data: array of doubles:
// re(0),re(1),re(2),...,re(size-1)
// 
// output:
// re(0),re(size/2),re(1),im(1),re(2),im(2),...,re(size/2-1),im(size/2-1)
// normalized by array length
//
// Source: 
// Source: see the routines it calls ...

void realfft_split_unshuffled(double *data,long n){

	double *data2;
	long i,j;

	realfft_split(data,n);
	//unshuffling - not in-place
	data2=(double *)malloc(n*sizeof(double));
	j=n/2;
	data2[0]=data[0];
	data2[1]=data[j];
	for(i=1;i<j;i++) {data2[i+i]=data[i];data2[i+i+1]=data[n-i];}
	for(i=0;i<n;i++) data[i]=data2[i];
	free(data2);
}

/////////////////////////////////////////////////////////
// Sorensen in-place inverse split-radix FFT for real values
// data: array of doubles:
// re(0),re(1),re(2),...,re(size/2),im(size/2-1),...,im(1)
// 
// output:
// re(0),re(1),re(2),...,re(size-1)
// NOT normalized by array length
//
// Source: 
// Sorensen et al: Real-Valued Fast Fourier Transform Algorithms,
// IEEE Trans. ASSP, ASSP-35, No. 6, June 1987

void irealfft_split(double *data,long n){

  long i,j,k,i5,i6,i7,i8,i0,id,i1,i2,i3,i4,n2,n4,n8,n1;
  double t1,t2,t3,t4,t5,a3,ss1,ss3,cc1,cc3,a,e,sqrt2;
  
  sqrt2=sqrt(2.0);
  
n1=n-1;
n2=n<<1;
for(k=n;k>2;k>>=1){  
	id=n2;
	n2>>=1;
	n4=n2>>2;
	n8=n2>>3;
	e = 2*pi/(n2);
	i1=0;
	do{ 
	    for (; i1<n; i1+=id){
			i2=i1+n4;
			i3=i2+n4;
			i4=i3+n4;
			t1=data[i1]-data[i3];
			data[i1]+=data[i3];
			data[i2]*=2;
			data[i3]=t1-2*data[i4];
			data[i4]=t1+2*data[i4];
			if (n4!=1){
				i0=i1+n8;
				i2+=n8;
				i3+=n8;
				i4+=n8;
				t1=(data[i2]-data[i0])/sqrt2;
				t2=(data[i4]+data[i3])/sqrt2;
				data[i0]+=data[i2];
				data[i2]=data[i4]-data[i3];
				data[i3]=2*(-t2-t1);
				data[i4]=2*(-t2+t1);
			}
	     }
		 id<<=1;
	     i1=id-n2;
	     id<<=1;
	  } while ( i1<n1 );
	a=e;
	for (j=2; j<=n8; j++){  
	      a3=3*a;
	      cc1=cos(a);
	      ss1=sin(a);
	      cc3=cos(a3);
	      ss3=sin(a3);
	      a=j*e;
	      i=0;
	      id=n2<<1;
	      do{
		   for (; i<n; i+=id){  
			  i1=i+j-1;
			  i2=i1+n4;
			  i3=i2+n4;
			  i4=i3+n4;
			  i5=i+n4-j+1;
			  i6=i5+n4;
			  i7=i6+n4;
			  i8=i7+n4;
			  t1=data[i1]-data[i6];
			  data[i1]+=data[i6];
			  t2=data[i5]-data[i2];
			  data[i5]+=data[i2];
			  t3=data[i8]+data[i3];
			  data[i6]=data[i8]-data[i3];
			  t4=data[i4]+data[i7];
			  data[i2]=data[i4]-data[i7];
			  t5=t1-t4;
			  t1+=t4;
			  t4=t2-t3;
			  t2+=t3;
			  data[i3]=t5*cc1+t4*ss1;
			  data[i7]=-t4*cc1+t5*ss1;
			  data[i4]=t1*cc3-t2*ss3;
			  data[i8]=t2*cc3+t1*ss3;
			  }
		   id<<=1;
		   i=id-n2;
		   id<<=1;
		 } while(i<n1);
	   }
	}	

   /*----------------------*/
	i0=0;
	id=4;
   do{
       for (; i0<n1; i0+=id){ 
			i1=i0+1;
			t1=data[i0];
			data[i0]=t1+data[i1];
			data[i1]=t1-data[i1];
		}
	   id<<=1;
       i0=id-2;
       id<<=1;
    } while ( i0<n1 );

/*----------------------*/

//data shuffling
      for (i=0,j=0,n2=n/2; i<n1 ; i++){
	  if (i<j){
				t1=data[j];
				data[j]=data[i];
				data[i]=t1;
				}
	  k=n2;
	  while (k<=j){
				j-=k;
				k>>=1;	
				}
	  j+=k;
      }	
}


/////////////////////////////////////////////////////////
// Sorensen in-place radix-2 FFT for real values
// data: array of doubles:
// re(0),re(1),re(2),...,re(size-1)
// 
// output:
// re(0),re(1),re(2),...,re(size/2),im(size/2-1),...,im(1)
// normalized by array length
//
// Source: 
// Sorensen et al: Real-Valued Fast Fourier Transform Algorithms,
// IEEE Trans. ASSP, ASSP-35, No. 6, June 1987

void realfft_radix2(double *data,long n){

    double  xt,a,e, t1, t2, cc, ss;
    long  i, j, k, n1, n2, n3, n4, i1, i2, i3, i4;

	n4=n-1;
  //data shuffling
      for (i=0,j=0,n2=n/2; i<n4 ; i++){
	  if (i<j){
				xt=data[j];
				data[j]=data[i];
				data[i]=xt;
				}
	  k=n2;
	  while (k<=j){
				j-=k;
				k>>=1;	
				}
	  j+=k;
      }
	
/* -------------------- */
    for (i=0; i<n; i += 2)  
      {
	 xt = data[i];
	 data[i] = xt + data[i+1];
	 data[i+1] = xt - data[i+1];
      }
/* ------------------------ */
    n2 = 1;
    for (k=n;k>2;k>>=1){ 
		n4 = n2;
		n2 = n4 << 1;
		n1 = n2 << 1;
		e = 2*pi/(n1);
		for (i=0; i<n; i+=n1){  
			xt = data[i];
			data[i] = xt + data[i+n2];
			data[i+n2] = xt-data[i+n2];
			data[i+n4+n2] = -data[i+n4+n2];
			a = e;
			n3=n4-1;
			for (j = 1; j <=n3; j++){
				i1 = i+j;
				i2 = i - j + n2;
				i3 = i1 + n2;
				i4 = i - j + n1;
				cc = cos(a);
				ss = sin(a);
				a += e;
				t1 = data[i3] * cc + data[i4] * ss;
				t2 = data[i3] * ss - data[i4] * cc;
				data[i4] = data[i2] - t2;
				data[i3] = -data[i2] - t2;
				data[i2] = data[i1] - t1;
				data[i1] += t1;
		  }
	  }
  }
	
	//division with array length
   for(i=0;i<n;i++) data[i]/=n;
}


/////////////////////////////////////////////////////////
// Sorensen in-place split-radix FFT for real values
// data: array of doubles:
// re(0),re(1),re(2),...,re(size-1)
// 
// output:
// re(0),re(size/2),re(1),im(1),re(2),im(2),...,re(size/2-1),im(size/2-1)
// normalized by array length
//
// Source: 
// Source: see the routines it calls ...

void realfft_radix2_unshuffled(double *data,long n){
	
	double *data2;
	long i,j;

	//unshuffling - not in-place
	realfft_radix2(data,n);
	data2=(double *)malloc(n*sizeof(double));
	j=n/2;
	data2[0]=data[0];
	data2[1]=data[j];
	for(i=1;i<j;i++) {data2[i+i]=data[i];data2[i+i+1]=data[n-i];}
	for(i=0;i<n;i++) data[i]=data2[i];
	free(data2);
}