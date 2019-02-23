Beat Detector Class
===================

- **Author or source:** rf.eerf@retsaMPSD
- **Created:** 2005-05-12 14:35:52


.. code-block:: text
    :caption: notes

    This class was designed for a VST plugin. Basically, it's just a 2nd order LP filter,
    followed by an enveloppe detector (thanks Bram), feeding a Schmitt trigger. The rising
    edge detector provides a 1-sample pulse each time a beat is detected. Code is self
    documented...
    Note : The class uses a fixed comparison level, you may need to change it.


.. code-block:: c++
    :linenos:
    :caption: code

    // ***** BEATDETECTOR.H *****
    #ifndef BeatDetectorH
    #define BeatDetectorH
    
    class TBeatDetector
    {
    private:
      float KBeatFilter;        // Filter coefficient
      float Filter1Out, Filter2Out;
      float BeatRelease;        // Release time coefficient
      float PeakEnv;            // Peak enveloppe follower
      bool BeatTrigger;         // Schmitt trigger output
      bool PrevBeatPulse;       // Rising edge memory
    public:
      bool BeatPulse;           // Beat detector output
    
      TBeatDetector();
      ~TBeatDetector();
      virtual void setSampleRate(float SampleRate);
      virtual void AudioProcess (float input);
    };
    #endif
    
    
    // ***** BEATDETECTOR.CPP *****
    #include "BeatDetector.h"
    #include "math.h"
    
    #define FREQ_LP_BEAT 150.0f    // Low Pass filter frequency
    #define T_FILTER 1.0f/(2.0f*M_PI*FREQ_LP_BEAT)  // Low Pass filter time constant
    #define BEAT_RTIME 0.02f  // Release time of enveloppe detector in second
    
    TBeatDetector::TBeatDetector()
    // Beat detector constructor
    {
      Filter1Out=0.0;
      Filter2Out=0.0;
      PeakEnv=0.0;
      BeatTrigger=false;
      PrevBeatPulse=false;
      setSampleRate(44100);
    }
    
    TBeatDetector::~TBeatDetector()
    {
      // Nothing specific to do...
    }
    
    void TBeatDetector::setSampleRate (float sampleRate)
    // Compute all sample frequency related coeffs
    {
      KBeatFilter=1.0/(sampleRate*T_FILTER);
      BeatRelease=(float)exp(-1.0f/(sampleRate*BEAT_RTIME));
    }
    
    void TBeatDetector::AudioProcess (float input)
    // Process incoming signal
    {
      float EnvIn;
    
      // Step 1 : 2nd order low pass filter (made of two 1st order RC filter)
      Filter1Out=Filter1Out+(KBeatFilter*(input-Filter1Out));
      Filter2Out=Filter2Out+(KBeatFilter*(Filter1Out-Filter2Out));
    
      // Step 2 : peak detector
      EnvIn=fabs(Filter2Out);
      if (EnvIn>PeakEnv) PeakEnv=EnvIn;  // Attack time = 0
      else
      {
        PeakEnv*=BeatRelease;
        PeakEnv+=(1.0f-BeatRelease)*EnvIn;
      }
    
      // Step 3 : Schmitt trigger
      if (!BeatTrigger)
      {
        if (PeakEnv>0.3) BeatTrigger=true;
      }
      else
      {
        if (PeakEnv<0.15) BeatTrigger=false;
      }
    
      // Step 4 : rising edge detector
      BeatPulse=false;
      if ((BeatTrigger)&&(!PrevBeatPulse))
        BeatPulse=true;
      PrevBeatPulse=BeatTrigger;
    }
    

Comments
--------

- **Date**: 2005-05-18 22:59:08
- **By**: moc.yddaht@yddaht

.. code-block:: delphi

    // Nice work!
    //Here's a Delphi and freepascal version:             
    unit beattrigger;
    
    interface
    
    type
    TBeatDetector = class
    private
      KBeatFilter,               // Filter coefficient
      Filter1Out,
      Filter2Out,
      BeatRelease,               // Release time coefficient
      PeakEnv:single;            // Peak enveloppe follower
      BeatTrigger,               // Schmitt trigger output
      PrevBeatPulse:Boolean;     // Rising edge memory
    public
      BeatPulse:Boolean;            // Beat detector output
      constructor Create;
      procedure setSampleRate(SampleRate:single);
      procedure AudioProcess (input:single);
    end;
    
    function fabs(value:single):Single;
    
    implementation
    
    
    const
     FREQ_LP_BEAT = 150.0;                    // Low Pass filter frequency
     T_FILTER = 1.0/(2.0 * PI*FREQ_LP_BEAT);  // Low Pass filter time constant
     BEAT_RTIME = 0.02;   // Release time of enveloppe detector in second
    
    constructor TBeatDetector.create;
    // Beat detector constructor
    begin
      inherited;
      Filter1Out:=0.0;
      Filter2Out:=0.0;
      PeakEnv:=0.0;
      BeatTrigger:=false;
      PrevBeatPulse:=false;
      setSampleRate(44100);
    end;
    
    
    procedure TBeatDetector.setSampleRate (sampleRate:single);
    // Compute all sample frequency related coeffs
    begin
      KBeatFilter:=1.0/(sampleRate*T_FILTER);
      BeatRelease:= exp(-1.0/(sampleRate*BEAT_RTIME));
    end;
    
    function fabs(value:single):Single;
    asm
     fld value
     fabs
     fwait
    end;
    
    procedure  TBeatDetector.AudioProcess (input:single);
    var
     EnvIn:Single;
    // Process incoming signal
    begin
      // Step 1 : 2nd order low pass filter (made of two 1st order RC filter)
      Filter1Out:=Filter1Out+(KBeatFilter*(input-Filter1Out));
      Filter2Out:=Filter2Out+(KBeatFilter*(Filter1Out-Filter2Out));
      // Step 2 : peak detector
      EnvIn:=fabs(Filter2Out);
      if EnvIn>PeakEnv then PeakEnv:=EnvIn  // Attack time = 0
      else
      begin
        PeakEnv:=PeakEnv*BeatRelease;
        PeakEnv:=PeakEnv+(1.0-BeatRelease)*EnvIn;
      end;
      // Step 3 : Schmitt trigger
      if not BeatTrigger then
      begin
        if PeakEnv>0.3 then BeatTrigger:=true;
      end
      else
      begin
        if PeakEnv<0.15 then BeatTrigger:=false;
      end;
    
      // Step 4 : rising edge detector
      BeatPulse:=false;
      if (BeatTrigger = true ) and( not PrevBeatPulse) then
        BeatPulse:=true;
      PrevBeatPulse:=BeatTrigger;
    end;
    
    end.

