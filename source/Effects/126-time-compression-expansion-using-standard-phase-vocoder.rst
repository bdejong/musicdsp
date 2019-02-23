Time compression-expansion using standard phase vocoder
=======================================================

- **Author or source:** Cournape
- **Type:** vocoder phase time stretching
- **Created:** 2002-12-01 21:15:54

- **Linked files:** :download:`vocoder.m <../files/vocoder.m>`.

.. code-block:: text
    :caption: notes

    Standard phase vocoder. For imporved techniques ( faster ), see paper of Laroche :
    "Improved phase vocoder time-scale modification of audio"
    Laroche, J.; Dolson, M.
    Speech and Audio Processing, IEEE Transactions on , Volume: 7 Issue: 3 , May 1999
    Page(s): 323 -332



Comments
--------

- **Date**: 2002-12-05 21:18:04
- **By**: ten.ximyr@psd

.. code-block:: text

    Anyone know what language this is in? It really would be nice to understand the syntax.

- **Date**: 2002-12-19 02:41:46
- **By**: llun.llun@llun

.. code-block:: text

    It's matlab code see <a href="http://www.mathworks.com/">mathworks</a>.
    /Daniel

- **Date**: 2003-01-05 04:20:17
- **By**: ten.ximyr@psd

.. code-block:: text

    thanks =)

- **Date**: 2003-01-11 05:32:02
- **By**: ericlee280.at.hotmail.com

.. code-block:: text

    The code seems to contain an undefined variable lss_frame, can someone explain what this is?

- **Date**: 2003-06-08 07:41:42
- **By**: wt.ude.hcetnuy.le.dac@cyy

.. code-block:: text

                  The code seems to contain an undefined variable lss_frame, can someone explain what this is?
    

- **Date**: 2003-08-22 18:29:08
- **By**: rf.tsne@epanruoc

.. code-block:: text

    There is indeed an error in the script. I will post the correction to the administrator.
    
    For now, here is the correction. You have to replace
    lss_frame by Ls ( which is properly defined before the main loop in the script which is online ). When I checked the code, there can be also some out of range error for the output vector : a change in the max variable definition seems to solve the problem ( at least for overlapp below 0.75 ).
    
    replace max = (nb_frame-2)*La+Nfft
    by      max = (nb_frame)*La+Nfft.
    
    

- **Date**: 2004-02-17 07:27:43
- **By**: wt.ude.hcetnuy.le.dac@cyy

.. code-block:: text

    is it really follow this paper "Improved phase vocoder time-scale modification of audio"??
    
    because i get the another source code for original phase vocoder on net, and the performence is better than the code....
    
    it is let me confuse....
    
    have anyone can slove my question?
    
    and thanks......
    ps:the sorce code from"http://www.ee.columbia.edu/~dpwe/resources/matlab/pvoc/" .

