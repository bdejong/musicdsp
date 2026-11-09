Hello and welcome to Tobybear MadShifta!

This is a VST plugin (PC only) by Tobybear (www.tobybear.de) and 
Bram (www.smartelectronix.com) with full Delphi source included!
It is available on Bram's truly excellent DSP source code page 
www.musicdsp.org!

1. What does it do?
Well, as Bram puts it: it is a "ultrafast and lofi pitchshifter",
where the pitch of the audio is changed in realtime while the
tempo is preserved.
You can adjust the pitch in semitones (+/- 24 semitones) and
with finetuning. Furthermore a delay line with feedback is
included and the obligatory LP/HP filter with resonance!
Extra special feature: you can use MIDI note messages to pitch
the audio in realtime up or down, relatively to a root key.
Furthermore a randomizer, dry/wet and output adjustments enhance
the fun :-)

Note: Our main intention here was to make clear how such an algorithm
could be implemented, but the way it is presented here may not
necessarily be the most performance-oriented way, so there is always
room for improvement.

2. The controls:
tune: pitch audio stream up/or down with up to 24 semitones
fine: fine tuning of the pitching
root: root note, if MIDI "Note on" messages are received the
audio is pitched relatively to that note in semitones
hold/back: describes MIDI behaviour: "hold" means the relative
distance between root and current note stays the current pitch,
if "back" is set, it falls back to the original pitch once a "note off"
is received
delay: delay amount, logarithmic scale
feedback: feedback amount of the delay
cutoff: filter cutoff
resonance: filter resonance
LP/HP: sets filter type (lowpass or highpass)
dry/wet: controls amount of processed (pitched) signal in relation
to the original signal
outvol: the output volume

Click on "VS" to switch text display on/off
Click on the bear to the left to randomize all parameters
Click on the note to the right to randomize only pitch

3. Why is the source code in Delphi?
Well, Delphi is still a very underestimated and underrated DSP langauge,
but it is in my opinion equally powerful as C++. Check out my other plugins
at www.tobybear.de, they are all coded in Delphi too.
So, first of all, to show people that it is also possible to compile
VST plugins without a C++ compiler, secondly because there aren't that 
much Delphi open source DSP codes floating around.

4. What can I do with the source code?
Look through it, learn from it, enhance it, add new features, but always
give proper credits to both of us! I say it again: this plugin and its
source code are mainly meant as a learning resource!
Some possible extensions:
- stereo mode/delay
- variable buffer sizes
- other filter modes
- sync to host
- filter/delay routing
- longer delay times
- LFOs

5. What do I need to compile this plugin?
A Delphi version, naturally :-), 3.0 or above should work. I coded it 
with the Delphi 6 PE Edition that is available for free at 
www.borland.com (150MB though!). This is the whole compiler/editor/IDE 
with no restrictions, but just for personal use, you are not allowed to 
sell any programs created with it.

Furthermore you need to install the tobygauges.pas component also 
included with this package before attempting to compile the MadShifta 
project. Just use "Component - Install Component", enter path to 
tobygauges.pas in "Unit file name", then "OK". This component adds 
mouseover and mousedown events to the standard Delphi gauge as well as 
eliminating the need for the trunc() function.

6. Final words
None of us is responsible if anything goes wrong with this plugin, you 
use it at your own risk. Of course we tried to prevent any possible harm, 
after all it is just a simple pitchshifter :-)

Contact:
tobybear@web.de
bram@smartelectronix.com

www.tobybear.de
www.smartelectronix.com
www.musicdsp.org

 