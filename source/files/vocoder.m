function [S] = vocoder(E,Nfft,over,alpha)

% Phase vocoder time-scaling :

% - E     : input vector
% - Nfft  : size per frame
% - over  : overlapp ( between 0 et 1 )
% - alpha : time-expansion/compression factor ( alpha < 1 : compression; alpha > 1 : expansion ).
%
% 30.11.02. Cournapeau David.
%
% Time expansion using standart phase vocoder technique. Based on Dolson and Laroche's paper : 
% "NEW PHASE-VOCODER TECHNIQUES FOR PITCH-SHIFTING, HARMONIZING AND
% OTHER EXOTIC EFFECTS", in 


%===================================================================%
% The synthesis signal's length isn't exactly alpha*input's length. %
%===================================================================%


% Verifiy the overlapp

if( over < 0 | over >= 1 )
   error('error : overlapp must be between 0 and 1');
end;

if ( alpha <= 0)
    error('alpha must be strictly positive');
end;

E    = E(:);
N    = length(E);
Nfft = 2^(nextpow2(Nfft));

% Computing vocoder's parameters :
% - La        : number of samples to "advance" for each anamysis frame : analysis hop size.
% - nb_frames : number of frames to compute
% - Ls        : number of samples ot "advance" for each synthesis frame : synthesis hop size.
% - S         : S is the result vector
% - h         : hanning window

La        = floor((1-over) * Nfft);
nb_frames = floor((N-Nfft) / La);
max 	  = (nb_frames-2)*La + Nfft;
ls        = floor(alpha * La);

S         = zeros(floor(max*alpha),1);
h         = hanning(Nfft);

% Init process :

X     = h.*E(1:Nfft);
tX    = fft(X,Nfft);
Phis1 = angle(tX)
Phia1 = Phis1;

for loop=2:nb_frames-1
   
    %===============================================================================
    % ( classic analysis part of a phase vocoder )
    
    % Take a frame, and windowing it
    
    X  = h.*E((loop-1) * La + 1:(loop-1)*La + Nfft); 
   
    % XI is the amplitude spectrum, and Phia2 the phase spectrum.
    
    tX    = fft(X, Nfft);
	Xi    = abs(tX);
    Phia2 = angle(tX);
    
    %================================================================================
    % the part which actually does the time scaling
    
    % One compute the actual pulsations, and shift them. The tricky part is here...
    
    omega = mod( (Phia2-Phia1)-2*pi*([0:Nfft-1].')/Nfft * La + pi, 2*pi) - pi;
    omega = 2 * pi * ([0:Nfft-1].') / Nfft + omega / La;
    Phis2 = Phis1 + lss_frame*omega;
 
    % The new phases values  :
    
    Phis1 = Phis2;
    Phia1 = Phia2;
    
    %==============================================================================
    %  Synthetise the frame, thanks to the computed phase and amplitude spectrum :
    % ( classic synthetisis part of a phase vocoder )
    
    tfs = Xi.*exp(j*Phis2);
    Xr  = real(ifft(tfs)).*h;
    
    % overlapp-add the synthetised frame Xr 
    
    S((loop-1)*lss_frame+1:(loop-1)*lss_frame+Nfft) ...
      = S((loop-1)*lss_frame+1:(loop-1)*lss_frame+Nfft) + Xr;
    
end;



