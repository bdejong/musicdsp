Automatic PDC system
====================

- **Author or source:** Tebello Thejane
- **Type:** the type that actually works, completely
- **Created:** 2006-07-16 11:39:56

- **Linked files:** :download:`pdc.pdf <../files/pdc.pdf>`.

.. code-block:: text
    :caption: notes

    No, people, implementing PDC is actually not as difficult as you might think it is.
    
    This paper presents a solution to the problem of latency inherent in audio effects
    processors, and the two appendices give examples of the method being applied on Cubase SX
    (with an example which its native half-baked PDC fails to solve properly) as well as a
    convoluted example in FL Studio (taking advantage of the flexible routing capabilities
    introduced in version 6 of the software). All that's necessary to understand it is a grasp
    of basic algebra and an intermediate understanding of how music production software works
    (no need to understand the Laplace transform, linear processes, sigma and integral
    notation... YAY!).
    
    Please do send me any feedback (kudos, errata, flames, job offers, questions, comments)
    you might have - my email address is included in the paper - or simply use musicdsp.org's
    own commenting system.
    
    Tebello Thejane.


.. code-block:: c++
    :linenos:
    :caption: code

    (I have sent the PDF to Bram as he suggested)

Comments
--------

- **Date**: 2006-07-18 08:12:00
- **By**: moc.liamg@saoxyz

.. code-block:: text

                  Oops! RBJ's first name is Robert, not Richard! Man, that's a bad one...

- **Date**: 2006-07-21 10:24:53
- **By**: moc.liamg@saoxyz

.. code-block:: text

       Okay, I've sent a fixed version to Bram. It should be uploaded shortly. Bigger diagrams, too, so there's less aliasing in Adode Acrobat Reader. Hopefully no more embarisingly bad errors (like misspelling my own name, or something...).      

- **Date**: 2006-10-09 15:27:24
- **By**: moc.liamg@saoxyz

.. code-block:: text

                  The revised version may be found here:
    http(:)//www.vormdicht.nl /misc/PDC_paper-rev.pdf
    Naturally, you need to remove the brackets from the address.

