# Waveform generator using MinBLEPS

[MusicDSP](../README.md) / [Synthesis](README.md) · [3 comments](#comments)

- **Author or source:** ku.oc.nomed.nafgpr@ekcol
- **Created:** 2002-08-05 18:44:50
- **Linked files:** [MinBLEPS.zip](../files/MinBLEPS.zip).

## Notes

C code and project file for MSVC6 for a bandwidth-limited saw/square (with PWM) generator
using MinBLEPS.

This code is based on Eli's MATLAB MinBLEP code and uses his original minblep.mat file.
Instead of keeping a list of all active MinBLEPS, the output of each MinBLEP is stored in
a buffer, in which all consequent MinBLEPS and the waveform output are added together.
This optimization makes it fast enough to be used realtime.

Produces slight aliasing when sweeping high frequencies. I don't know wether Eli's
original code does the same, because I don't have MATLAB. Any help would be appreciated.

The project name is 'hardsync', because it's easy to generate hardsync using MinBLEPS.

## Comments

<details>
<summary>Show 3 replies</summary>

1. **moc.oiduaesionetihw@ofni** · *2004-07-02 22:31:36*

   <http://www.slack.net/~ant/bl-synth/windowed-impulse/>

   This page also describes a similar algorithm for generating waves. Could the aliasing be due to the fact that the blep only occurs after the discontinuity? On this page the blep also occurs in the opposite direction as well, leading up to the discontinuity.

2. **kernel\[@}audiospillage.com** · *2008-02-11 18:42:15*

   The sawtooth is a nice oscillator but I can't seem to get the square wave to work properly.  Anyone else had any luck with this?  Also, it's worth noting that the code assumes it is running on a little endian architecture.

3. **moc.enecslatnemirepxe@leinad** · *2009-07-07 04:45:40*

   I have written GPLv3 C++ source code for a MinBLEP oscillator and also public domain C++ source code for generating the MinBLEP without MatLab.

   <http://www.experimentalscene.com/articles/minbleps.php> - Article and Code

   <http://www.experimentalscene.com/source.php> - Look in DarkWave / latest version / CoreMachines / VCO.cpp

</details>
