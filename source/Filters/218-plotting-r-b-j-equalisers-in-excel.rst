Plotting R B-J Equalisers in Excel
==================================

- **Author or source:** Web Surf
- **Created:** 2006-03-07 09:32:57

- **Linked files:** :download:`rbj_eq.xls <../files/rbj_eq.xls>`.

.. code-block:: text
    :caption: notes

    Interactive XL sheet that shows frequency response of the R B-K high pass/low pass,
    Peaking and Shelf filters
    
    Useful if --
    --You want to validate your implementation against mine
    
    --You want to convert given Biquad coefficients into Fo/Q/dBgain by visual curve fitting.
    
    --You want the Coefficients to implement a particular fixed filter
    
    -- Educational aid
    
    Many thanks to R B-J for his personal support !!
    Web Surf   WebsurffATgmailDOTcom


.. code-block:: c++
    :linenos:
    :caption: code

    see attached file

Comments
--------

- **Date**: 2006-04-14 07:07:00
- **By**: rf.liamtoh@57eninreS_luaP

.. code-block:: text

    It also works perfectly with the openoffice2.02 suite :-)              

- **Date**: 2007-07-24 15:00:09
- **By**: jackmattson att gmial

.. code-block:: text

                  Ok, so I'm about to make my first filter so I really have no idea about coefficients yet but damn this is the coolest .xls I've ever seen! And I see a bunch every day. :?

- **Date**: 2007-09-13 05:54:54
- **By**: WebsurffATgmailDOTcom

.. code-block:: text

    Thanks,
    
    It's just an implementation of the R B-J cookbook formulae for parametric equalisers. RB-J personally assisted me while I was writing this XLS. The real Kudos goes out to him !!
    
    I wrote this as in intermediate tool while I was writing some Guitar effect DSP routines.
    
    One prob it has : If the Q is too sharp, the peak filters have a very sharp tip. It is possible then as you slide the F sliders, that the chosen F is not one of the data points that I am plotting.
    
    The net result is that the peak of a hi-Q filter seems to increase/decrease as you move F. This is a shortcoming of the way I programmed my XLS and is not a problem with the R B-J equations.
    
    PS : I saw the same problem with other similar S/W on the net !!!
    
    
    PS : Anyone know how to do curve fitting so that we enter in some points through which the frequency response must pass, and it generates best set of F,G,Q ? 

- **Date**: 2011-04-18 02:30:51
- **By**: WebsurffATgmailDOTcom

.. code-block:: text

    Date: Sun, 17 Apr 2011 12:34:09 
    Subject: RBJ Filter Plotter Spreadsheet
    From: Robert Bonini <XXXXXXXXXX@gmail.com>
    To: websurff @ gmail . com
    
    
    Just wanted to complement you on the good work.  I came across your RBJ filter plotter spreadsheet, and it's quite good.  
    
    The version I have is dated Feb.2006, so this may have been addressed already but I did notice a small issue with the sample frequency input.  
    
    Anything other than 44.1 KHz would cause the response curves to peak at incorrect values on the x axis.  The normalized frequency 'w' was
    being referenced to 44100, and not to the Fs cell. I modified the formula to absolute reference B56 and it solved that problem.  
    
    Thanks for your great work,  
    -robert             

