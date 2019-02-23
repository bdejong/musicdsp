Digital RIAA equalization filter coefficients
=============================================

- **Author or source:** Frederick Umminger
- **Type:** RIAA
- **Created:** 2002-10-14 16:33:34


.. code-block:: text
    :caption: notes

    Use at your own risk. Confirm correctness before using. Don't assume I didn't goof
    something up.
    
    -Frederick Umminger


.. code-block:: c++
    :linenos:
    :caption: code

    The "turntable-input software" thread inspired me to generate some coefficients for a digital RIAA equalization filter. These coefficients were found by matching the magnitude response of the s-domain transfer function using some proprietary Matlab scripts. The phase response may or may not be totally whacked.
    
    The s-domain transfer function is
    
    R3(1+R1*C1*s)(1+R2*C2*s)/(R1(1+R2*C2*s) + R2(1+R1*C1*s) + R3(1+R1*C1*s)(1+R2*C2*s))
    
    where
    
    R1 = 883.3k
    R2 = 75k
    R3 = 604
    C1 = 3.6n
    C2 = 1n
    
    This is based on the reference circuit found in http://www.hagtech.com/pdf/riaa.pdf
    
    The coefficients of the digital transfer function b(z^-1)/a(z^-1) in descending powers of z, are:
    
    44.1kHz
    b = [ 0.02675918611906  -0.04592084787595   0.01921229297239]
    a = [ 1.00000000000000  -0.73845850035973  -0.17951755477430]
    error +/- 0.25dB
    
    48kHz
    b = [  0.02675918611906  -0.04592084787595   0.01921229297239]
    a = [  1.00000000000000  -0.73845850035973  -0.17951755477430]
    error +/- 0.15dB
    
    88.2kHz
    b = [  0.04872204977233  -0.09076930609195   0.04202280710877]
    a = [ 1.00000000000000  -0.85197860443215  -0.10921171201431]
    error +/- 0.01dB
    
    
    96kHz
    b = [ 0.05265477122714  -0.09864197097385   0.04596474352090  ]
    a = [  1.00000000000000  -0.85835597216218  -0.10600020417219 ]
    error +/- 0.006dB
    
    

Comments
--------

- **Date**: 2007-02-24 13:55:58
- **By**: moc.liamtoh@0691_ptj

.. code-block:: text

    Hmm... since I'm having lack in knowledge of utilizing this type of 'data' in programming, could someone be kind and give a short code example of its usage (@ some samplerate), lets say, using Basic/VB language (though, C-C++/Pascal-Delphi/Java goes as well)?
    
    
    JT
    

- **Date**: 2007-03-01 13:20:51
- **By**: ku.oc.snosrapsdTUOEMEKAT@psdcisum

.. code-block:: text

    they are coefficients to plug into a std biquad. look through the filters section of musicdsp you'll find a load of examples of biquads (essentially two quadratic equations which are solved together to do the DSP stuff).
    
    It's of the form
    out = b0*in[0] + b1*in[-1] + b2*in[-2] - a1*out[-1] - a2*out[-2]
    
    where in[0,-1,-2] are the current input and the previous 2; and out[-1,-2] are the last two outputs.
    
    Generally the previous output coefficients are subtracted, but sometimes the signs are swapped, and they are added like the inputs.
    
    some algorithms use a for ins and b for outs, others use them the other way around. Generally (but not always) there are 3 input and 2 output coeffs, so you can work out which is which.
    
    HTH
    DSP

- **Date**: 2007-03-02 03:31:08
- **By**: moc.erehwon@ydobon

.. code-block:: text

    I don't get it. How do you set the frequency, Kenneth?
    
    What frequencies are being passed?

- **Date**: 2007-03-03 09:09:29
- **By**: moc.liamtoh@0691_ptj

.. code-block:: text

    Hmm...
    
    Since no links allowed here, I have started a topic on this matter @ KVR 
    
    topic number: 170235
    topic name: "Coefficients of the digital transfer function ... How to ?"
    
    I tried the 44.1/48kHz version and it produced quite 'bad' results .. lots of rattle in audio and the RIAA curve form is not as it should be (should be: 20Hz; ±19.27dB ... ~1kHz; ±0dB ... 20kHz; ±19.62dB). (couple of pictures linked in KVR topic).
    
    Also, .. if this is the result in anyway, this is the 'production curve' used in mastering process ... how can it be changed to 'opposite' ...
    
    JT

- **Date**: 2007-03-04 22:52:32
- **By**: moc.liamtoh@0691_ptj

.. code-block:: text

    Thanks to all so far.
    
    I found this quote from another forum:
     
    QUOTE:
    "All you should need to do to get the complementary curve is swap the a and b 
    vectors, and then multiply both vectors by 1/a(0) to normalize. That will 
    give the coefficients for the inverse filter.".
    /QUOTE
    
    w/ a note that it was taken from one of those OPs (Frederick Umminger's) postings ... but the reference link was dead so I couldn't read the whole story. If OP or anyone else can give some light in this matter of how to make that swap w/ normalization (fully) so I could try w/ higher SR data. I did try and got values like -20.1287341287123, etc.. 
    
    I actually got the 44.1/48kHz curve managed w/ help from a post in another forum. But there were nothing explained fully.
    
    QUOTE:
    "
    ; Filter coefficients (48kHz) for RIAA curve from Frederick
    ; Umminger; see 
    ;
    ;  b = [  0.02675918611906  -0.04592084787595   0.01921229297239]
    ;  a = [  1.00000000000000  -0.73845850035973  -0.17951755477430]
    ;  error +/- 0.15dB
    
    ; inverted filter for phono playback (48kHz):
    ;
    ;  b = [ 0.2275882473429072 -0.1680644758323426 -0.0408560856583673 ]
    ;  a = [ 1.0000000000000000 -1.7160778983199925  0.7179700042784745 ]
    ;
    ; since a[1] is too large, it must be splitted into a11 and a12
    
    static b0=0.2275882473429072, b1=-0.1680644758323426, b2=-0.0408560856583673
    static a1=.85803894915999625, a2=-0.7179700042784745
    "
    /QUOTE
    
    just lots of numbers ....
    
    JT
    
    

- **Date**: 2007-03-15 00:41:09
- **By**: moc.liamtoh@0691_ptj

.. code-block:: text

    This seem to become a monologue but, ... I'm still having issues w/ those 88.2kHz and 96kHz filter coefficients when inverted. 
    
    Noticed that when those coefficients for 88.2kHz and 96kHz are inverted, in both cases, a1 and a2 gets values which maybe are not good in equation 
    
    y[i] = b0x[i] + b1x[i-1] + b2x[i-2] - a1y[i-1] - a2y[i-1]
    
    because of, a1 gets a negative value and its decimal part is bigger than a2 is --> " --a1y[i-1] - a2y[i-2]" --> looks like y[i] starts growing after every sample calculation. This is not an issue w/ data for 44.1kHz and 48kHz. When I change those a1/a2 decimal parts so that the abs(a1)-a2 =< 1 becomes true then filter works well (though not right recults). Also, while analyzing the VST plugin, using C.W.Buddes VST PluginAnalyzer, Delphi tracer (Watch) shows y[i] become over 1.0 after ~830 sampleframes and after 8192 sampleframes, y[i] has value of 2.488847401e+11 already (i.e. 248884740100). This shouldn't be a coding problem since a friend of mine tested these w/ SynthMaker (no coding needed) and the results were equal.
    
    If this "-a1x[i-1]-a2x[i-2] > 1" is an issue, are there any methods to get it fixed w/o loosing the accuracy OP got into those original coefficients?
    
    jtp
    

- **Date**: 2007-03-15 22:41:37
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Try to plot the poles and zeroes. If there are poles outside the unit circle, your filter will be unstable!
    To eliminate poles outside the unit circle, construct an allpass filter which has zeroes at the same position as the unwanted poles. They are now canceling out themself, so that you only have poles inside the unit circle. Your filter should be stable now!
    
    All you need to know now is how to transform the filter coefficients into poles and zeroes and vice versa. If you're using delphi, you might want to have a look into the DFilter class of the open source project 'Delphi ASIO & VST Packages'.

- **Date**: 2007-03-24 11:53:25
- **By**: moc.liamtoh@0691_ptj

.. code-block:: text

    Thanks for your suggestion Christian. 
    I didn't try this allpass method because of
    
    - I managed to get this issue rounded through another way (I have now 3rd-4th order filters working here as VST and standalone for all those four samplerates mentioned here and I'm also considering to add ones for 174.6 kHz and 192 kHz as well) 
    
    - as I'm learning these filter matters and delphi programming, I would have needed some good examples to do this 
    
    
    My final thoughts over those coefficients listed in F. Ummingers post:
    
    As those coefficients needs to be inversed before getting the RIAA reproduction done, I can't say 100% sure if any of those works properly then (maybe one set does). 
    When inversion is done as was suggested elsewhere: 
    - swap a/b vectors, 
    - multiply all with 1/a0 and 
    - optional: 'normalize' b's by dividing every b with sum of b's
    , only coefficients for 44.1kHz and 48kHz seem to become stable but, which one is the right one then since, those original coefficients are same for both? I suppose those can't be equal coefficients because this is sample accurate filter in question, or can those?. If not then, which one is the correct one ... you can find it out by trying (least the resulting sound quality should tell this). Maybe Hannes Rohde (quote in my 3rd post) went through this and found the right ones or just used those given for 48kHz (SoundBlaster DSP is internally 48kHz).
    
    What's wrong with those others? It seems that both, 88.2kHz and 96kHz coefficients as inversed, produces unstable filter which won't work (see my previous post)
    
    jtp
    

- **Date**: 2007-04-22 12:03:52
- **By**: moc.liamtoh@0691_ptj

.. code-block:: text

    FYI, here are working filter coefficients for biquad implementation of RIAA EQ Reproduction filters:
    
    44.1kHz:
    a = [ 1.0000000000 -1.7007240000  0.7029381524 ]
    b = [ 1.0000000000 -0.7218922000 -0.1860520545 ]
    error ~0.23dB
    
    48kHz:
    a = [ 1.0000000000 -1.7327655000  0.7345534436 ]
    b = [ 1.0000000000 -0.7555521000 -0.1646257113 ]
    error ~0.14dB
    
    88.2kHz:
    a = [ 1.0000000000 -1.8554648000  0.8559721393 ]
    b = [ 1.0000000000 -0.8479577000 -0.1127631993 ]
    error 0.008dB
    
    and 96kHz:
    a = [ 1.0000000000 -1.8666083000  0.8670382873 ]
    b = [ 1.0000000000 -0.8535331000 -0.1104595113 ]
    error ~0.006dB
    
    
    NOTES:
    
    # - By swapping the a1<->b1 and a2<->b2 you'll get the production filter.
    
    # - All these given filter coefficients produces a bit gained filter (~+12.5dB or so) so, if you like to adjust the 1 kHz = 0dB, it can be done quite accurately by finding linear difference using software like Tobybear's FilterExplorer. Enter coefficients into FilterExplorer, by moving mouse cursor over the plotted magnitude curve in magnitude plot window, find/point the ~1kHz position and then check the magnitude value (value inside the brackets) found in info field. Use this value as divider for b coefficients.
    
    
    jtp
    jiiteepee@yahoo.se
    

- **Date**: 2009-08-07 18:43:49
- **By**: ude.nretsewhtron.ece@ztub

.. code-block:: text

    The amplitude response of Umminger's Fs = 48 kHz filter gives an excellent approximation to the RIAA amplitude response curve but Umminger suggests the phase response may be "totally whacked". Actually, the phase response is pretty good, provided "phase response" is interpreted properly.
    Umminger's filters are carelessly presented. The 44.1 kHz version is not there at all, and the 88.2 kHz and 96 kHz cases have reproduction filter poles > 1 that should be replaced by their reciprocals. For that reason I shall use the coefficients given by jtp, though the general approach is Umminger's. 
    When computing phase of the digital filter, a linear phase term may be added to the computation as convenient, as such a term corresponds to time shift. That is, two phase responses are for our practical purposes equivalent if they differ only by a phase linear in frequency f. The RIAA analog filter has an asymptotic phase of –90 deg and Umminger's asymptotic (Fs/2) phase is 0, so one may conjecture that a term 2Df/Fs ought to be added to the computation of the digital filter phase, where D = -90. Actually, there is no reason to restrict D to multiples of 90. 
    In jtp's Fs=44.1 kHz case, an adjustment to the computed phase using D = -65.5 results in maximum computed phase error < 1.5 deg over the range 30 Hz – 10 kHz, while the computation using D = -75.75 results in maximum computed phase error < 5.2 deg over the range 30 Hz – 20 kHz. Of course the digital filter itself is independent of D, which is used only to interpret the phase response. One is, in effect, comparing the output of the digital filter with the output of the RIAA analog filter delayed by D/180 sample intervals. The digital filter itself remains as given by jtp. 
    In jtp's Fs=48 kHz case use D = -68 for a phase error < 1.2 deg  over the range 30 Hz – 10 kHz, and D = -75 for a phase error < 3.8 deg over the range 30 Hz – 20 kHz.
    In jtp's Fs=88.2 kHz case use D = -72 for a phase error < 0.31 deg  over the range 30 Hz – 10 kHz, and D = -72.8 for a phase error < 0.5 deg over the range 30 Hz – 20 kHz.
    In jtp's Fs=96 kHz case use D = -72.4 for a phase error < 0.30 deg  over the range 30 Hz – 10 kHz, and D = -72.8 for a phase error < 0.375 deg over the range 30 Hz – 20 kHz.
    In the Fs = 44.1 or 48 kHz cases, if a max phase error, over 30 Hz – 20 kHz, of about 0.5 deg is wanted, then one can double the sample rate in the usual way using a linear phase FIR interpolating filter, then do equalization at sample rate 88.2 or 96 kHz, decimating the output by a factor 2. August 7, 2009
                  

