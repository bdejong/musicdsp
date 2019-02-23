Reverberation techniques
========================

- **Author or source:** Sean Costello
- **Created:** 2002-02-10 20:00:11


.. code-block:: text
    :caption: notes

    * Parallel comb filters, followed by series allpass filters. This was the original design
    by Schroeder, and was extended by Moorer. Has a VERY metallic sound for sharp transients.
    
    * Several allpass filters in serie (also proposed by Schroeder). Also suffers from
    metallic sound.
    
    * 2nd-order comb and allpass filters (described by Moorer). Not supposed to give much of
    an advantage over first order sections.
    
    * Nested allpass filters, where an allpass filter will replace the delay line in another
    allpass filter. Pioneered by Gardner. Haven't heard the results.
    
    * Strange allpass amp delay line based structure in Jon Dattorro article (JAES). Four
    allpass filters are used as an input to a cool "figure-8" feedback loop, where four
    allpass reverberators are used in series with
    a few delay lines. Outputs derived from various taps in structure. Supposedly based on a
    Lexicon reverb design. Modulating delay lines are used in some of the allpass structures
    to "spread out" the eigentones.
    
    * Feedback Delay Networks. Pioneered by Puckette/Stautner, with Jot conducting extensive
    recent research. Sound VERY good, based on initial experiments. Modulating delay lines and
    feedback matrixes used to spread out eigentones.
    
    * Waveguide-based reverbs, where the reverb structure is based upon the junction of many
    waveguides. Julius Smith developed these. Recently, these have been shown to be
    essentially equivalent to the feedback delay network reverbs. Also sound very nice.
    Modulating delay lines and scattering values used to spread out eigentones.
    
    * Convolution-based reverbs, where the sound to be reverbed is convolved with the impulse
    response of a room, or with exponentially-decaying white noise. Supposedly the best sound,
    but very computationally expensive, and not very flexible.
    
    * FIR-based reverbs. Essentially the same as convolution. Probably not used, but shorter
    FIR filters are probably used in combination with many of the above techniques, to provide
    early reflections.



Comments
--------

- **Date**: 2007-08-29 15:47:43
- **By**: ti.oohay@azuab_naitsirk

.. code-block:: text

    Hello I am doing de algorith of moore in Matlab simulink and I compare direntes reverb processor to improve something but i dont find anything to  improve i ask if you have some idea to make something better in C++  a library DLL and  making a plugin....
    thanks              

- **Date**: 2009-04-24 22:21:46
- **By**: ten.tenih.51sm@srk

.. code-block:: text

                  matlab reverb ..thanks

- **Date**: 2013-01-18 02:54:43
- **By**: moc.liamtoh@niffumtohrepus

.. code-block:: text

    Hi, after trying a bunch of Schroeder/Moorer designs which never really sounded great, I stumbled upon a "loop" topology that I whipped up in a coffee-fueled coding frenzy at Starbuck's one night. It sounded great - like a real guitar amp reverb. Still uses delays/comb filters and the usual nonsense, but w/ a different topology. Drop me a line and I can send my source. It's fully commented, including "ASCII art" signal flow diagrams. Michael B.

- **Date**: 2015-11-24 00:02:45
- **By**: moc.liamtoh@niffumtohrepus

.. code-block:: text

    I've received a lot of requests about my `Gardner' topology so I've placed a copy of the comments from my source files on OneDrive here: https://onedrive.live.com/redir?resid=76918537984b2b01!173&authkey=!AIZax2NmDKPcS8w&ithint=file%2ctxt
    
    Note that this is a plain text file containing ASCII art diagrams which probably won't render correctly in every text editor/browser so you might have to do a little editing. Send me an email if you have problems.         

