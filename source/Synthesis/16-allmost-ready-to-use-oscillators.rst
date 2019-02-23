(Allmost) Ready-to-use oscillators
==================================

- **Author or source:** Ross Bencina, Olli Niemitalo, ...
- **Type:** waveform generation
- **Created:** 2002-01-17 01:01:39


.. code-block:: text
    :caption: notes

    Ross Bencina: original source code poster
    Olli Niemitalo: UpdateWithCubicInterpolation


.. code-block:: c++
    :linenos:
    :caption: code

    //this code is meant as an EXAMPLE
    
    //uncomment if you need an FM oscillator
    //define FM_OSCILLATOR
    
    /*
    members are:
    
    float phase;
    int TableSize;
    float sampleRate;
    
    float *table, dtable0, dtable1, dtable2, dtable3;
    
    ->these should be filled as folows... (remember to wrap around!!!)
    table[i] = the wave-shape
    dtable0[i] = table[i+1] - table[i];
    dtable1[i] = (3.f*(table[i]-table[i+1])-table[i-1]+table[i+2])/2.f
    dtable2[i] = 2.f*table[i+1]+table[i-1]-(5.f*table[i]+table[i+2])/2.f
    dtable3[i] = (table[i+1]-table[i-1])/2.f
    */
    
    float Oscillator::UpdateWithoutInterpolation(float frequency)
    {
            int i = (int) phase;
    
            phase += (sampleRate/(float TableSize)/frequency;
    
            if(phase >= (float)TableSize)
                    phase -= (float)TableSize;
    
    #ifdef FM_OSCILLATOR
            if(phase < 0.f)
                    phase += (float)TableSize;
    #endif
    
            return table[i] ;
    }
    
    float Oscillator::UpdateWithLinearInterpolation(float frequency)
    {
            int i = (int) phase;
            float alpha = phase - (float) i;
    
            phase += (sampleRate/(float)TableSize)/frequency;
    
            if(phase >= (float)TableSize)
                    phase -= (float)TableSize;
    
    #ifdef FM_OSCILLATOR
            if(phase < 0.f)
                    phase += (float)TableSize;
    #endif
    
            /*
            dtable0[i] = table[i+1] - table[i]; //remember to wrap around!!!
            */
    
            return table[i] + dtable0[i]*alpha;
    }
    
    float Oscillator::UpdateWithCubicInterpolation( float frequency )
    {
            int i = (int) phase;
            float alpha = phase - (float) i;
    
            phase += (sampleRate/(float)TableSize)/frequency;
    
            if(phase >= (float)TableSize)
                    phase -= (float)TableSize;
    
    #ifdef FM_OSCILLATOR
            if(phase < 0.f)
                    phase += (float)TableSize;
    #endif
    
            /* //remember to wrap around!!!
            dtable1[i] = (3.f*(table[i]-table[i+1])-table[i-1]+table[i+2])/2.f
            dtable2[i] = 2.f*table[i+1]+table[i-1]-(5.f*table[i]+table[i+2])/2.f
            dtable3[i] = (table[i+1]-table[i-1])/2.f
            */
    
            return ((dtable1[i]*alpha + dtable2[i])*alpha + dtable3[i])*alpha+table[i];
    }

