C# Oscilator class
==================

- **Author or source:** neotec
- **Type:** Sine, Saw, Variable Pulse, Triangle, C64 Noise
- **Created:** 2007-01-08 10:49:36


.. code-block:: text
    :caption: notes

    Parameters:
    
    Pitch: The Osc's pitch in Cents [0 - 14399] startig at A -> 6.875Hz
    Pulsewidth: [0 - 65535] -> 0% to 99.99%
    Value: The last Output value, a set to this property 'syncs' the Oscilator


.. code-block:: c++
    :linenos:
    :caption: code

    public class SynthOscilator
    {
        public enum OscWaveformType
        {
            SAW, PULSE, TRI, NOISE, SINE
        }
    
        public int Pitch
        {
            get
            {
                return this._Pitch;
            }
            set
            {
                this._Pitch = this.MinMax(0, value, 14399);
                this.OscStep = WaveSteps[this._Pitch];
            }
        }
    
        public int PulseWidth
        {
            get
            {
                return this._PulseWidth;
            }
            set
            {
                this._PulseWidth = this.MinMax(0, value, 65535);
            }
        }
    
        public OscWaveformType Waveform
        {
            get
            {
                return this._WaveForm;
            }
            set
            {
                this._WaveForm = value;
            }
        }
    
        public int Value
        {
            get
            {
                return this._Value;
            }
            set
            {
                this._Value = 0;
                this.OscNow = 0;
            }
        }
    
        private int _Pitch;
        private int _PulseWidth;
        private int _Value;
        private OscWaveformType _WaveForm;
    
        private int OscNow;
        private int OscStep;
        private int ShiftRegister;
    
        public const double BaseFrequence = 6.875;
    	public const int SampleRate = 44100;
        public static int[] WaveSteps = new int[0];
        public static int[] SineTable = new int[0];
    	
        public SynthOscilator()
        {
            if (WaveSteps.Length == 0)
                this.CalcSteps();
    
            if (SineTable.Length == 0)
                this.CalcSine();
    
            this._Pitch = 7200;
            this._PulseWidth = 32768;
            this._WaveForm = OscWaveformType.SAW;
    
            this.ShiftRegister = 0x7ffff8;
    
            this.OscNow = 0;
            this.OscStep = WaveSteps[this._Pitch];
            this._Value = 0;
        }
    
        private void CalcSteps()
        {
            WaveSteps = new int[14400];
    
            for (int i = 0; i < 14400; i++)
            {
                double t0, t1, t2;
    
                t0 = Math.Pow(2.0, (double)i / 1200.0);
                t1 = BaseFrequence * t0;
                t2 = (t1 * 65536.0) / (double)this.SampleRate;
    
                WaveSteps[i] = (int)Math.Round(t2 * 4096.0);
            }
        }
    
    	private void CalcSine()
    	{
            SineTable = new int[65536];
    
            double s = Math.PI / 32768.0;
    
            for (int i = 0; i < 65536; i++)
            {
                double v = Math.Sin((double)i * s) * 32768.0;
    
                int t = (int)Math.Round(v) + 32768;
    
                if (t < 0)
                    t = 0;
                else if (t > 65535)
                    t = 65535;
    
                SineTable[i] = t;
            }
    	}
    	
        public override int Run()
        {
            int ret = 32768;
            int osc = this.OscNow >> 12;
    
            switch (this._WaveForm)
            {
                case OscWaveformType.SAW:
                    ret = osc;
                    break;
                case OscWaveformType.PULSE:
                    if (osc < this.PulseWidth)
                        ret = 65535;
                    else
                        ret = 0;
                    break;
                case OscWaveformType.TRI:
                    if (osc < 32768)
                        ret = osc << 1;
                    else
                        ret = 131071 - (osc << 1);
                    break;
                case OscWaveformType.NOISE:
                    ret = ((this.ShiftRegister & 0x400000) >> 11) |
                      ((this.ShiftRegister & 0x100000) >> 10) |
                      ((this.ShiftRegister & 0x010000) >> 7) |
                      ((this.ShiftRegister & 0x002000) >> 5) |
                      ((this.ShiftRegister & 0x000800) >> 4) |
                      ((this.ShiftRegister & 0x000080) >> 1) |
                      ((this.ShiftRegister & 0x000010) << 1) |
                      ((this.ShiftRegister & 0x000004) << 2);
                    ret <<= 4;
                    break;
                case OscWaveformType.SINE:
                    ret = SynthTools.SineTable[osc];
                    break;
                default:
                    break;
            }
    
            this.OscNow += this.OscStep;
    
            if (this.OscNow > 0xfffffff)
            {
                int bit0 = ((this.ShiftRegister >> 22) ^ (this.ShiftRegister >> 17)) & 0x1;
                this.ShiftRegister <<= 1;
                this.ShiftRegister &= 0x7fffff;
                this.ShiftRegister |= bit0;
            }
    
            this.OscNow &= 0xfffffff;
    
            this._Value = ret - 32768;
    
            return this._Value;
        }
    
        public int MinMax(int a, int b, int c)
        {
            if (b < a)
                return a;
            else if (b > c)
                return c;
            else
                return b;
        }
    }
    

