1 pole LPF for smooth parameter changes
=======================================

- **Author or source:** moc.liamg@odiugoiz
- **Type:** 1-pole LPF class
- **Created:** 2008-09-22 20:27:06


.. code-block:: text
    :caption: notes

    This is a very simple class that I'm using in my plugins for smoothing parameter changes
    that directly affect audio stream.
    It's a 1-pole LPF, very easy on CPU.
    
    Change the value of variable "a" (0~1) for slower or a faster response.
    
    Of course you can also use it as a lowpass filter for audio signals.


.. code-block:: c++
    :linenos:
    :caption: code

    class CParamSmooth
    {
    public:
    	CParamSmooth() { a = 0.99f; b = 1.f - a; z = 0; };
    	~CParamSmooth();
    	inline float Process(float in) { z = (in * b) + (z * a); return z; }
    private:
    	float a, b, z;
    };
    

Comments
--------

- **Date**: 2011-09-30 15:46:04
- **By**: moc.oohay@ygobatem

.. code-block:: text

    I've used this a lot, but here's an important thing: it won't work the same for multiple sample rates, so if you set a to 0.9995 for example, this will be lower if the sample rate is higher than you intended. I fix it by doing this:
    
    /*must compensate this factor for sample rate change*/
    
    float srCompensate;
    srCompensate = sr/44100.0f;
    float compensated_a;
    compensated_a = powf(a, (1.0f/srCompensate));
    		b = 1.0f-compensated_a;
    
    Then if you start with a built in value (or range) designed for 44100hz, it will scale up with the sample rate so you will get the same amount of smoothing. I'm not sure if this is mathematically correct, but I came up with it very quickly and it works a charm for me.
    
    Good work, very useful and easy to use filter.

- **Date**: 2011-09-30 15:47:29
- **By**: moc.oohay@ygobatem

.. code-block:: text

    *edit, a won't be LOWER if the sample rate changes, but it won't have the same effect. 

- **Date**: 2014-12-16 12:14:59
- **By**: moc.liamg@earixela

.. code-block:: text

    New version, now you can specify the speed response of the parameter in ms. and sampling rate:
    
    class CParamSmooth
    {
    public:
        CParamSmooth(float smoothingTimeInMs, float samplingRate)
        {
            const float c_twoPi = 6.283185307179586476925286766559f;
            
            a = exp(-c_twoPi / (smoothingTimeInMs * 0.001f * samplingRate));
            b = 1.0f - a;
            z = 0.0f;
        }
    
        ~CParamSmooth()
        {
            
        }
    
        inline float process(float in)
        {
            z = (in * b) + (z * a);
            return z;
        }
    
    private:
        float a;
        float b;
        float z;
    };

