Smooth random LFO Generator
===========================

- **Author or source:** Rob Belcham
- **Created:** 2009-06-30 08:31:24


.. code-block:: text
    :caption: notes

    I've been after a random LFO that's suitable for modulating a delay line for ages ( e.g
    for chorus / reverb modulation) , so after i rolled my own, i thought i'd better make it
    my first contribution to the music-dsp community.
    
    My aim was to achive a sinusoidal based random but smooth waveform with a frequency
    control that has no discontinuities and stays within a -1:1 range. If you listen to it, it
    sounds quite like brown noise, or wind through a microphone (at rate = 100Hz for example)
    
    It's written as a matlab m function, so shouldn't be too hard to port to C.
    
    The oscillator generates a random level stepped waveform with random time spent at each
    step (within bounds). These levels are linearly interpolated between and used to drive the
    frequency of a sinewave. To achive amplitude variation, at each zero crossing a new random
    amplitude scale factor is generated. The amplitude coefficient is ramped to this value
    with a simple exponential.
    
    An example call would be,
    t = 4; Fs = 44100;
    y = random_lfo(100, t*Fs, Fs);
    axis([0, t*Fs, -1, 1]);
    plot(y)
    
    Enjoy !


.. code-block:: c++
    :linenos:
    :caption: code

    % Random LFO Generator
    % creates a random sinusoidal waveform with no discontinuities
    %   rate = average rate in Hz
    %   N = run length in samples
    %   Fs = sample frequency in Hz
    function y = random_lfo(rate, N, Fs)
    
    step_freq_scale = Fs / (1*rate); 
    min_Cn = 0.1 * step_freq_scale;
    An = 0;
    lastA = 0;
    Astep = 0; 
    y = zeros(1,N); % output
    x = 0;  % sine phase
    lastSign = 0;
    amp_scale = 0.6;
    new_amp_scale = 0.6;
    amp_scale_ramp = exp(1000/Fs)-1;
    for (n=1:N)
        if (An == 0) || (An>=Cn)
            % generate a new random freq scale factor
            Cn = floor(step_freq_scale * rand());
            % limit to prevent rapid transitions
            Cn = max(Cn, min_Cn);
            % generate new value & step coefficient
            newA = 0.1 + 0.9*rand();
            Astep = (newA - lastA) / Cn;
            A = lastA;
            lastA = newA;
            % reset counter
            An = 0;
        end
        An = An + 1;
        % generate output
        y(n) = sin(x) * amp_scale;
        % ramp amplitude 
        amp_scale = amp_scale + ( new_amp_scale - amp_scale ) * amp_scale_ramp;
        sin_inc = 2*pi*rate*A/Fs;
        A = A + Astep;
        % increment phase 
        x = x + sin_inc;
        if (x >= 2*pi)
            x = x - 2*pi;
        end
        % scale at each zero crossing
        if (sign(y(n)) ~= 0) && (sign(y(n)) ~= lastSign)
            lastSign = sign(y(n));
            new_amp_scale = 0.25 + 0.75*rand();
        end;
    end;
        

