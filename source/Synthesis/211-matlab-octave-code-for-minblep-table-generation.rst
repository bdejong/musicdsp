Matlab/octave code for minblep table generation
===============================================

- **Author or source:** ude.drofnats.amrcc@lfd
- **Created:** 2005-11-15 22:27:53


.. code-block:: text
    :caption: notes

    When I tested this code, it was running with each function in a separate file... so it
    might need some tweaking (endfunction statements?) if you try and run it all as one file.
    
    Enjoy!
    
    PS There's a C++ version by Daniel Werner here.
    http://www.experimentalscene.com/?type=2&id=1
    Not sure if it the output is any different than my version.
    (eg no thresholding in minphase calculation)


.. code-block:: c++
    :linenos:
    :caption: code

    % Octave/Matlab code to generate a minblep table for bandlimited synthesis
    %% original minblep technique described by Eli Brandt:
    %% http://www.cs.cmu.edu/~eli/L/icmc01/hardsync.html
    
    % (c) David Lowenfels 2004
    % you may use this code freely to generate your tables,
    % but please send me a free copy of the software that you 
    % make with it, or at least send me an email to say hello
    % and put my name in the software credits :)
    % (IIRC: mps and clipdb functions are from Julius Smith)
    
    % usage:
    %  fc = dilation factor
    %  Nzc = number of zero crossings
    %  omega = oversampling factor
    %  thresh = dB threshold for minimum phase calc
    
    mbtable = minblep( fc, Nzc, omega, thresh );
    mblen = length( mbtable );
    save -binary mbtable.mat mbtable ktable nzc mblen;
    
    *********************************************
    function [out] = minblep( fc, Nzc, omega, thresh )
    
    out = filter( 1, [1 -1], minblip( fc, Nzc, omega, thresh ) );
    
    len = length( out );
    normal = mean( out( floor(len*0.7):len ) )
    out = out / normal; %% normalize
    
    %% now truncate so it ends at proper phase cycle for minimum discontinuity
    thresh = 1e-6;
    for i = len:-1:len-1000
    %  pause
      a = out(i) - thresh - 1;
    	b = out(i-1) - thresh - 1;
    %	i
    	if(  (abs(a) < thresh) & (a > b) )
    	  break;
    	endif
    endfor
    
    %out = out';
    out = out(1:i);
    
    
    *********************************************
    
    
    function [out] = minblip( fc, Nzc, omega, thresh )
    if (nargin < 4 )
      thresh = -100;
    end
    if (nargin < 3 )
      omega = 64;
    end
    if (nargin < 2 )
      Nzc = 16;
    end
    if (nargin < 1 )
      fc = 0.9;
    end
    
    blip = sinctable( omega, Nzc, fc );
    %% length(blip) must be nextpow2! (if fc < 1 );
    
    mag = fft( blip );
    out = real( ifft( mps( mag, thresh ) ) );
    
    *********************************************
    
    function [sm] = mps(s, thresh) 
    % [sm] = mps(s)
    % create minimum-phase spectrum sm from complex spectrum s 
    
    if (nargin < 2 )
      thresh = -100;
    endif
    
    s = clipdb(s, thresh);
    sm = exp( fft( fold( ifft( log( s )))));
    
    *********************************************
    function [clipped] = clipdb(s,cutoff)
    % [clipped] = clipdb(s,cutoff)
    % Clip magnitude of s at its maximum + cutoff in dB.
    % Example: clip(s,-100) makes sure the minimum magnitude
    % of s is not more than 100dB below its maximum magnitude.
    % If s is zero, nothing is done.
    
    as = abs(s);
    mas = max(as(:));
    if mas==0, return; end
    if cutoff >= 0, return; end
    thresh = mas*10^(cutoff/20); % db to linear
    toosmall = find(as < thresh);
    clipped = s;
    clipped(toosmall) = thresh;
    *********************************************
    
    function [out, phase] = sinctable( omega, Nzc, fc )
    
    if (nargin < 3 )
      fc = 1.0 %% cutoff frequency
    end %if
    if (nargin < 2 )
      Nzc = 16  %% number of zero crossings
    end %if
    if (nargin < 1 )
      omega = 64 %% oversampling factor
    end %if
    
    Nzc = Nzc / fc %% This ensures more flatness at the ends.
    
    phase = linspace( -Nzc, Nzc, Nzc*omega*2 );
    
    %sinc = sin( pi * fc * phase) ./ (pi * fc * phase);
    
    num = sin( pi*fc*phase );
    den = pi*fc*phase;
    
    len = length( phase );
    sinc = zeros( len, 1 );
    
    %sinc = num ./ den;
    
    for i=1:len
      if ( den(i) ~= 0 )
        sinc(i) = num(i) / den(i);
    	else
        sinc(i) = 1;
      end
    end %for
    
    out = sinc;
    window = blackman( len );
    out = out .* window;
    
    

