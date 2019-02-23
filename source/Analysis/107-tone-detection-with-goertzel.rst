Tone detection with Goertzel
============================

- **Author or source:** on.biu.ii@rnepse
- **Type:** Goertzel
- **Created:** 2004-04-07 09:37:10

- **Linked files:** :download:`http://www.ii.uib.no/~espenr/tonedetect.zip <../files/http://www.ii.uib.no/~espenr/tonedetect.zip>`.

.. code-block:: text
    :caption: notes

    Goertzel is basically DFT of parts of a spectrum not the total spectrum as you normally do
    with FFT. So if you just want to check out the power for some frequencies this could be
    better. Is good for DTFM detection I've heard.
    
    The WNk isn't calculated 100% correctly, but it seems to work so ;) Yeah and the code is
    C++ so you might have to do some small adjustment to compile it as C.


.. code-block:: c++
    :linenos:
    :caption: code

    /** Tone detect by Goertzel algorithm
     *
     * This program basically searches for tones (sines) in a sample and reports the different dB it finds for
     * different frequencies. Can easily be extended with some thresholding to report true/false on detection.
     * I'm far from certain goertzel it implemented 100% correct, but it works :)
     * 
     * Hint, the SAMPLERATE, BUFFERSIZE, FREQUENCY, NOISE and SIGNALVOLUME all affects the outcome of the reported dB. Tweak
     * em to find the settings best for your application. Also, seems to be pretty sensitive to noise (whitenoise anyway) which
     * is a bit sad. Also I don't know if the goertzel really likes float values for the frequency ... And using 44100 as
     * samplerate for detecting 6000 Hz tone is kinda silly I know :)
     * 
     * Written by: Espen Riskedal, espenr@ii.uib.no, july-2002
     */
    
    #include <iostream>
    #include <cmath>
    #include <cstdlib>
    
    using std::rand;
    // math stuff
    using std::cos;
    using std::abs;
    using std::exp;
    using std::log10;
    // iostream stuff
    using std::cout;
    using std::endl;
    
    #define PI 3.14159265358979323844
    // change the defines if you want to
    #define SAMPLERATE 44100
    #define BUFFERSIZE 8820
    #define FREQUENCY 6000
    #define NOISE 0.05
    #define SIGNALVOLUME 0.8
    
    /**  The Goertzel algorithm computes the k-th DFT coefficient of the input signal using a second-order filter. 
     *   http://ptolemy.eecs.berkeley.edu/papers/96/dtmf_ict/www/node3.html. 
     *   Basiclly it just does a DFT of the frequency we want to check, and none of the others (FFT calculates for all frequencies).
     */
    float goertzel(float *x, int N, float frequency, int samplerate) {
        float Skn, Skn1, Skn2;
        Skn = Skn1 = Skn2 = 0;
        
        for (int i=0; i<N; i++) {
    	Skn2 = Skn1;
    	Skn1 = Skn;
    	Skn = 2*cos(2*PI*frequency/samplerate)*Skn1 - Skn2 + x[i];
        }
        
        float WNk = exp(-2*PI*frequency/samplerate); // this one ignores complex stuff
        //float WNk = exp(-2*j*PI*k/N);
        return (Skn - WNk*Skn1);
    }
    
    /** Generates a tone of the specified frequency 
     *  Gotten from: http://groups.google.com/groups?hl=en&lr=&ie=UTF-8&oe=UTF-8&safe=off&selm=3c641e%243jn%40uicsl.csl.uiuc.edu
     */
    float *makeTone(int samplerate, float frequency, int length, float gain=1.0) {
        //y(n) = 2 * cos(A) * y(n-1) - y(n-2)
        //A= (frequency of interest) * 2 * PI / (sampling frequency)
        //A is in radians.
        // frequency of interest MUST be <= 1/2 the sampling frequency.
        float *tone = new float[length];
        float A = frequency*2*PI/samplerate;
        
        for (int i=0; i<length; i++) {
    	if (i > 1) tone[i]= 2*cos(A)*tone[i-1] - tone[i-2];
    	else if (i > 0) tone[i] = 2*cos(A)*tone[i-1] - (cos(A));
    	else tone[i] = 2*cos(A)*cos(A) - cos(2*A);
        }
    
        for (int i=0; i<length; i++) tone[i] = tone[i]*gain;
        
        return tone;
    }
    
    /** adds whitenoise to a sample */
    void *addNoise(float *sample, int length, float gain=1.0) {
        for (int i=0; i<length; i++) sample[i] += (2*(rand()/(float)RAND_MAX)-1)*gain;
    }
    
    /** returns the signal power/dB */
    float power(float value) {
        return 20*log10(abs(value));
    }
    
    int main(int argc, const char* argv) {
        cout << "Samplerate: " << SAMPLERATE << "Hz\n";
        cout << "Buffersize: " << BUFFERSIZE << " samples\n";
        cout << "Correct frequency is: " << FREQUENCY << "Hz\n";
        cout << " - signal volume: " << SIGNALVOLUME*100 << "%\n";
        cout << " - white noise: " << NOISE*100 << "%\n";
        
        float *tone = makeTone(SAMPLERATE, FREQUENCY, BUFFERSIZE, SIGNALVOLUME);
        addNoise(tone, BUFFERSIZE,NOISE);
    
        int stepsize = FREQUENCY/5;
    
        for (int i=0; i<10; i++) {
    	int freq = stepsize*i;
    	cout << "Trying freq: " << freq << "Hz  ->  dB: " << power(goertzel(tone, BUFFERSIZE, freq, SAMPLERATE)) << endl;
        }
        delete tone;
        
        return 0;
    }
    

Comments
--------

- **Date**: 2004-04-12 22:03:56
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: delphi

    // yet untested Delphi translation of the algorithm:
    
    function Goertzel(Buffer:array of Single; frequency, samplerate: single):single;
    var Skn, Skn1, Skn2 : Single;
        i               : Integer;
        temp1, temp2    : Single;
    begin
     skn:=0;
     skn1:=0;
     skn2:=0;
     temp1:=2*PI*frequency/samplerate;
     temp2:=Cos(temp1);
     for i:=0 to Length(Buffer) do
      begin
       Skn2 = Skn1;
       Skn1 = Skn;
       Skn = 2*temp2*Skn1 - Skn2 + Buffer[i];
      end;
     Result:=(Skn - exp(-temp1)*Skn1);
    end;
    
    // Maybe someone can use it...
    //
    // Christian