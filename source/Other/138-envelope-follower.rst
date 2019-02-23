Envelope Follower
=================

- **Author or source:** ers
- **Created:** 2003-03-12 04:08:16



.. code-block:: c++
    :linenos:
    :caption: code

    #define V_ENVELOPE_FOLLOWER_NUM_POINTS	2000
    class vEnvelopeFollower :
    {
          public:
    		vEnvelopeFollower();
    		virtual ~vEnvelopeFollower();
    		inline void Calculate(float *b)
    		{
    			envelopeVal -= *buff;
    			if (*b < 0)
    				envelopeVal += *buff = -*b;
    			else
    				envelopeVal += *buff = *b;
    			if (buff++ == bufferEnd)
    				buff = buffer;
    		}
    		void SetBufferSize(float value);
    		void GetControlValue(){return envelopeVal / (float)bufferSize;}
    
    	private:
    		float	buffer[V_ENVELOPE_FOLLOWER_NUM_POINTS];
    		float	*bufferEnd, *buff, envelopeVal;
    		int	bufferSize;
          float	val;
    };
    
    vEnvelopeFollower::vEnvelopeFollower()
    {
    	bufferEnd = buffer + V_ENVELOPE_FOLLOWER_NUM_POINTS-1;
    	buff = buffer;
    	val = 0;
    	float *b = buffer;
    	do
    	{
    		*b++ = 0;
    	}while (b <= bufferEnd);
    	bufferSize = V_ENVELOPE_FOLLOWER_NUM_POINTS;
    	envelopeVal= 0;
    }
    
    vEnvelopeFollower::~vEnvelopeFollower()
    {
    
    }
    
    void vEnvelopeFollower::SetBufferSize(float value)
    {
    
    	bufferEnd = buffer + (bufferSize = 100 + (int)(value * ((float)V_ENVELOPE_FOLLOWER_NUM_POINTS-102)));
    	buff = buffer;
    	float val =  envelopeVal / bufferSize;
    	do
    	{
    		*buff++ = val;
    	}while (buff <= bufferEnd);
    	buff = buffer;
    }
    

Comments
--------

- **Date**: 2007-01-17 13:46:04
- **By**: gro.akeeb@evets

.. code-block:: text

    Nice contribution, but I have a couple of questions...
    
    Looks like there is a typo on GetControlValue... should return a float. Also, I am not clear on the reason for it taking a pointer to a float.
    
    Is there any noticeable speed improvement with the "if (*b < 0)" code, as opposed to using fabs? I would hope that a decent compiler library would inline this (but haven't cracked open the disassembler to find out).
    

