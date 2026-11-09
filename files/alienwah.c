/*
 Alien-Wah by Nasca Octavian Paul from Tg. Mures, Romania
 e-mail:  <paulnasca@email.ro> or <paulnasca@yahoo.com>.
*/

/*
 The algorithm was found by me by mistake(I was looking for something else);
 I called this effect "Alien Wah" because sounds a bit like wahwah, but more strange.
 The ideea of this effect is very simple: It is a feedback delay who uses complex numbers.
 If x[] represents the input and y[] is the output, so a simple feedback delay looks like this:
 y[n]=y[n-delay]*fb+x[n]*(1-fb)
 
 'fb' is a real number between 0 and 1.
 If you change the fb with a complex number who has the MODULUS smaller than 1, it will look like this.

 fb=R*(cos(alpha)+i*sin(alpha));  i^2=-1; R<1;
 y[n]=y[n-delay]*R*(cos(alpha)+i*sin(alpha))+x[n]*(1-R);

 alpha is the phase of the number and is controlled by the LFO(Low Frequency Oscillator).
 If the 'delay' parameter is low, the effect sounds more like wah-wah,
 but if it is big, the effect will sound very interesting.
 The input x[n] has the real part of the samples from the wavefile and the imaginary part is zero.
 The output of this effect is the real part of y[n].

 Here it is a simple and unoptimised implementation of the effect. All parameters should be changed at compile time.
 It was tested only with Borland C++ 3.1.

 Please send me your opinions about this effect.
 Hope you like it (especially if you are play to guitar).
 Paul.
*/

/*
Alien Wah Parameters

 freq       - "Alien Wah" LFO frequency
 startphase - "Alien Wah" LFO startphase (radians), needed for stereo
 fb         - "Alien Wah" FeedBack (0.0 - low feedback, 1.0 = 100% high feedback)
 delay      -  delay in samples at 44100 KHz (recomanded from 5 to 50...)
*/

#include <complex.h>
#include <fcntl.h>
#include <sys\stat.h>
#include <io.h>
#include <stdio.h>
#include <math.h>

/*
 .raw files are raw files (without header), signed 16 bit,mono
*/
#define infile "a.raw" //input file
#define outfile "b.raw" //input file
#define samplerate 44100

#define bufsize 1024
int buf1[bufsize];//input buffer
int buf2[bufsize];//output buffer


#define lfoskipsamples 25 // How many samples are processed before compute the lfo value again

struct params
{
   float freq,startphase,fb;
   int delay;
} awparams;
//alien wah internal parameters

struct alienwahinternals
{
 complex *delaybuf;
 float lfoskip;
 long int t;
 complex c;
 int k;
} awint;

//effect initialisation
void init(float freq,float startphase,float fb,int delay){
  awparams.freq=freq;
  awparams.startphase=startphase;
  awparams.fb=fb/4+0.74;
  awparams.delay=(int)(delay/44100.0*samplerate);
  if (delay<1) delay=1;
  awint.delaybuf=new complex[awparams.delay];
  int i;
  for (i=0;i<delay;i++) awint.delaybuf[i]=complex(0,0);
  awint.lfoskip=freq*2*3.141592653589/samplerate;
  awint.t=0;
}

//process buffer
void process()
{
 int i;
 float lfo,out;
 complex outc;
 for(i=0;i<bufsize;i++)
 {
   if (awint.t++%lfoskipsamples==0)
   {
      lfo=(1+cos(awint.t*awint.lfoskip+awparams.startphase));
      awint.c=complex(cos(lfo)*awparams.fb,sin(lfo)*awparams.fb);
   };
   outc=awint.c*awint.delaybuf[awint.k]+(1-awparams.fb)*buf1[i];
   awint.delaybuf[awint.k]=outc;
   if ((++awint.k)>=awparams.delay)
      awint.k=0;
   out=real(outc)*3;  //take real part of outc
   if (out<-32768) out=-32768;
   else if (out>32767) out=32767; //Prevents clipping
   buf2[i]=out;
 };
}

int main()
{
  char f1,f2;
  int readed;
  long int filereaded=0;
  printf("\n");
  f1=open(infile,O_RDONLY|O_BINARY);
  remove(outfile);
  f2=open(outfile,O_BINARY|O_CREAT,S_IWRITE);
  long int i;

  init(0.6,0,0.5,20);  //effects parameters

  do
  {
    readed=read(f1,buf1,bufsize*2);

    process();

    write(f2,buf2,readed);
    printf("%ld  bytes \r",filereaded);
    filereaded+=readed;
  }while (readed==bufsize*2);

  delete(awint.delaybuf);
  close(f1);
  close(f2);
  printf("\n\n");

  return(0);
}